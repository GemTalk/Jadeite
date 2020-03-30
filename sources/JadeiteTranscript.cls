"Filed out from Dolphin Smalltalk 7"!

JadeTranscript subclass: #JadeiteTranscript
	instanceVariableNames: 'projectListPresenter isTranscriptInstalled autoCommit areBreakpointsEnabled autoCompleteEnabled'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteTranscript guid: (GUID fromString: '{93b3c6ce-9a55-45db-bd1e-cc1a44a28e4e}')!
JadeiteTranscript comment: ''!
!JadeiteTranscript categoriesForClass!Unclassified! !
!JadeiteTranscript methodsFor!

abortTransaction
	super abortTransaction.
	projectListPresenter refresh.
	self autoCommit: (autoCommit value == #failed ifTrue: [true] ifFalse: [autoCommit value])!

additionalAccelerators
	^#(#(#raiseConsole 'Ctrl+F7'))!

areBreakpointsEnabled
	^areBreakpointsEnabled!

autoCommit
	"for testing"
	^autoCommit value!

autoCommit: boolean
	autoCommit value: boolean.
	gciSession autoCommit: boolean. 
	gciSession
		ifNotNil: 
			[:session |
			"not inconceivable there are dead transcripts around from test runs"
			session autoCommit: boolean].!

autoCompleteEnabled
	"for testing"

	^autoCompleteEnabled value!

browseBreakpointList
	^JadePresenter browseBreakpointsIn: self gciSession!

browseBreakpoints
	^JadeiteBreakpointBrowser showOnSession: self gciSession!

browseClass
	^JadePresenter browseClassIn: self gciSession!

browseClassReferences
	^JadePresenter browseClassReferencesInSession: self gciSession!

browseImplementorsOf
	^JadePresenter browseImplementorsIn: self gciSession!

browseJadeiteLogs
	^JadeiteLoggerShell showOnSession: self gciSession!

browseJadeitePrefs
	^JadeitePreferencesWorkspace browseJadeitePrefs: gciSession!

browseLiteralReferences
	^JadePresenter browseLiteralReferences: self gciSession!

browseMethodsContaining
	^JadePresenter browseMethodsContaining: self gciSession!

browseSendersOf
	^JadePresenter browseSendersIn: self gciSession!

commitTransaction
	^codePane commitTransaction.!

createComponents
	super createComponents.
	projectListPresenter := self add: JadeiteProjectListPresenter new name: 'Projects'!

flipAutoCommit
	| browserService |
	browserService := RowanAutoCommitService new.
	browserService
		command: #flipAutoCommit;
		commandArgs: Array new.
	self issueCommand: (Array with: browserService)!

flipAutocomplete
	| newValue confirmedValue |
	newValue := JadeiteSearch autoCompleteEnabled not.
	confirmedValue := JadeiteSearch confirmAutoCompleteEnabled: newValue in: self gciSession.
	"confirmedValue results in no change if user declines to continue"
	autoCompleteEnabled value: confirmedValue!

flipBreakpointsEnabled
	| answeringService | 
	answeringService := RowanAnsweringService new.
	answeringService setBreakpointsEnabled: areBreakpointsEnabled value not session: self gciSession!

flipDebugger
	JadeiteDebugger debuggerClass == JadeiteDebugger
		ifTrue: [JadeiteDebugger debuggerClass: JadeDebugger]
		ifFalse: [JadeiteDebugger debuggerClass: JadeiteDebugger]!

flipLogging
	BrowserUpdate current isLogging: BrowserUpdate current isLogging not!

flipTranscript
	| answeringService |
	answeringService := RowanAnsweringService new.
	answeringService flipTranscriptIn: self gciSession.
	isTranscriptInstalled := isTranscriptInstalled value: isTranscriptInstalled value not!

gciSession: aGciSession
	"don't do the force logout. We'll close us ourselves"

	gciSession := aGciSession.
	gciSession
		when: #logoutRequested:
			send: #logoutRequested:
			to: self;
		when: #logoutPending
			send: #exit
			to: self;
		yourself.
	mySessionPresenter gciSession: aGciSession.
	allSessionsPresenter gciSession: aGciSession.
	stoneInfoPresenter gciSession: aGciSession.
	toolbarPresenter gciSession: aGciSession.
	transcriptPresenter gciSession: aGciSession.
	autoCommit := ValueHolder with: aGciSession autoCommit!

initialize
	super initialize.
	isTranscriptInstalled := ValueHolder with: true.
	areBreakpointsEnabled := ValueHolder with: true.
	autoCompleteEnabled := ValueHolder with: JadeiteSearch autoCompleteEnabled!

isTranscriptInstalled
	^isTranscriptInstalled value!

isTranscriptInstalledValueHolder
	^isTranscriptInstalled!

onCloseRequested: boolValueHolder
	| answer |
	self onPromptToSaveChanges: boolValueHolder.
	boolValueHolder value ifFalse: [^self].
	gciSession isNil ifTrue: [^self].
	gciSession isValidSession
		ifFalse: 
			[gciSession trigger: #forceJadeiteWindowClose.
			^self].
	gciSession logoutRequested
		ifFalse: 
			[boolValueHolder value: false.
			^self].
	(RowanAnsweringService new needsCommit: self gciSession)
		ifTrue: 
			[answer := MessageBox new
						caption: 'Close Requested';
						confirmOrCancel: 'Commit current transaction?'.
			boolValueHolder value: (#(#yes #no) includes: answer).
			answer = #yes ifTrue: [gciSession commit]].
	boolValueHolder value ifFalse: [^self].
	allSessionsPresenter aboutToClose.
	gciSession notNil
		ifTrue: 
			[| temp |
			gciSession trigger: #forceJadeiteWindowClose.	"close all windows except me and debugger"
			temp := gciSession.	"I'm getting closed so make sure session gets logged out"
			gciSession := nil.
			temp forceLogout]!

onViewClosed
	super onViewClosed.
	BrowserUpdate current logComment: 'Closing Transcript {' , self identityHash printString , '}'.
	BrowserUpdate current removeEventsTriggeredFor: self.
	BrowserUpdate current removeEventsTriggeredFor: projectListPresenter projectListPresenter.
	GciSession current: nil!

onViewOpened
	| answeringService installed breakPointsEnabled |
	super onViewOpened.
	projectListPresenter
		gciSession: gciSession;
		refreshProjects.
	JadeiteTextStyles default resetColors.	"reset colors on login"
	answeringService := RowanAnsweringService new.
	installed := answeringService isTranscriptInstalledIn: self gciSession.
	isTranscriptInstalled value: installed.
	areBreakpointsEnabled
		value: (breakPointsEnabled := answeringService breakPointsAreEnabled: self gciSession).
	BrowserUpdate current breakpointsEnabled: breakPointsEnabled.
	self registerPresentersForUpdates.
	self autoCommit: (RowanAnsweringService new autoCommitIn: self gciSession)!

openDictionaryBrowser
	gciSession hasServer ifTrue: [^JadeiteBrowser showOnSession: gciSession]!

openGitHubJadeiteProject
	^JadePresenter openGitHubJadeiteProject!

openGitHubRowanProject
	^JadePresenter openGitHubRowanProject!

openJadeiteProjectsBrowser
	projectListPresenter hasSelection
		ifTrue: [^projectListPresenter browseProject]
		ifFalse: 
			[gciSession hasServer ifTrue: [^(JadeiteBrowser showOnSession: gciSession)].
			MessageBox warning: 'Cannot open Jadeite Projects browser'
				caption: 'Cannot open Jadeite Projects browser']!

projectListPresenter
	^projectListPresenter!

queryCommand: query
	super queryCommand: query.
	query commandSymbol = #flipTranscript
		ifTrue: 
			[query isChecked: self isTranscriptInstalled.
			^true].
	query commandSymbol = #flipAutoCommit
		ifTrue: 
			[query isChecked: autoCommit value == true.
			^true].
	query commandSymbol = #flipDebugger
		ifTrue: 
			[query isChecked: JadeiteDebugger debuggerClass = JadeiteDebugger.
			^true].
	query commandSymbol = #flipLogging
		ifTrue: 
			[query isChecked: BrowserUpdate current isLogging.
			^true].
	query commandSymbol = #flipBreakpointsEnabled
		ifTrue: 
			[query isChecked: areBreakpointsEnabled value.
			^true].
	query commandSymbol = #flipAutocomplete
		ifTrue: 
			[query isChecked: autoCompleteEnabled value.
			^true]!

registerPresentersForUpdates
	BrowserUpdate current
		register: self selector: #autoCommitUpdate:;
		register: self selector: #breakpointSettingChanged:;
		register: self selector: #updateSymbols:;
		register: projectListPresenter projectListPresenter selector: #projectsUpdate:!

remoteAutoCommit
	| answeringService |
	answeringService := RowanAnsweringService new.
	answeringService
		command: #autoCommit;
		commandArgs: Array new.
	self issueCommand: (Array with: answeringService).
	^answeringService answer!

toolbarPresenter
	^toolbarPresenter! !
!JadeiteTranscript categoriesFor: #abortTransaction!menu handlers!public! !
!JadeiteTranscript categoriesFor: #additionalAccelerators!public! !
!JadeiteTranscript categoriesFor: #areBreakpointsEnabled!accessing!private! !
!JadeiteTranscript categoriesFor: #autoCommit!accessing!private! !
!JadeiteTranscript categoriesFor: #autoCommit:!accessing!private! !
!JadeiteTranscript categoriesFor: #autoCompleteEnabled!accessing!private! !
!JadeiteTranscript categoriesFor: #browseBreakpointList!menu handlers!public! !
!JadeiteTranscript categoriesFor: #browseBreakpoints!menu handlers!public! !
!JadeiteTranscript categoriesFor: #browseClass!menu handlers!public! !
!JadeiteTranscript categoriesFor: #browseClassReferences!menu handlers!public! !
!JadeiteTranscript categoriesFor: #browseImplementorsOf!menu handlers!public! !
!JadeiteTranscript categoriesFor: #browseJadeiteLogs!menu handlers!public! !
!JadeiteTranscript categoriesFor: #browseJadeitePrefs!menu handlers!public! !
!JadeiteTranscript categoriesFor: #browseLiteralReferences!menu handlers!public! !
!JadeiteTranscript categoriesFor: #browseMethodsContaining!menu handlers!public! !
!JadeiteTranscript categoriesFor: #browseSendersOf!menu handlers!public! !
!JadeiteTranscript categoriesFor: #commitTransaction!menu handlers!public! !
!JadeiteTranscript categoriesFor: #createComponents!public! !
!JadeiteTranscript categoriesFor: #flipAutoCommit!menu handlers!public! !
!JadeiteTranscript categoriesFor: #flipAutocomplete!menu handlers!public! !
!JadeiteTranscript categoriesFor: #flipBreakpointsEnabled!menu handlers!public! !
!JadeiteTranscript categoriesFor: #flipDebugger!menu handlers!public! !
!JadeiteTranscript categoriesFor: #flipLogging!menu handlers!public! !
!JadeiteTranscript categoriesFor: #flipTranscript!menu handlers!public! !
!JadeiteTranscript categoriesFor: #gciSession:!public! !
!JadeiteTranscript categoriesFor: #initialize!initialization!public! !
!JadeiteTranscript categoriesFor: #isTranscriptInstalled!public! !
!JadeiteTranscript categoriesFor: #isTranscriptInstalledValueHolder!private! !
!JadeiteTranscript categoriesFor: #onCloseRequested:!event handling!public! !
!JadeiteTranscript categoriesFor: #onViewClosed!event handling!public! !
!JadeiteTranscript categoriesFor: #onViewOpened!event handling!public! !
!JadeiteTranscript categoriesFor: #openDictionaryBrowser!menu handlers!public! !
!JadeiteTranscript categoriesFor: #openGitHubJadeiteProject!event handling!menu handlers!public! !
!JadeiteTranscript categoriesFor: #openGitHubRowanProject!event handling!menu handlers!public! !
!JadeiteTranscript categoriesFor: #openJadeiteProjectsBrowser!menu handlers!public! !
!JadeiteTranscript categoriesFor: #projectListPresenter!accessing!public! !
!JadeiteTranscript categoriesFor: #queryCommand:!private! !
!JadeiteTranscript categoriesFor: #registerPresentersForUpdates!public!register presenters! !
!JadeiteTranscript categoriesFor: #remoteAutoCommit!accessing!private! !
!JadeiteTranscript categoriesFor: #toolbarPresenter!accessing!public! !

!JadeiteTranscript class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1201 801 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1140850688 131073 592 nil 480 nil 7 nil nil nil 592 655878 ##(Smalltalk.CardLayout) 138 144 34 7 721414 ##(Smalltalk.Association) 8 'Workspace' 410 ##(Smalltalk.ReferenceView) 34 14 nil 592 34 2 8 1140850688 131073 768 nil 480 nil 5 nil nil nil 768 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.CodeSourcePresenter) #resource_Default_view nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 9 53 498 1153 573 768 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 68 2 0 0 56 1 0 0] 8 #() 498 193 193 nil 27 722 8 'My Session' 410 ##(Smalltalk.ReferenceView) 34 14 nil 592 34 2 8 1140850688 131073 1120 nil nil nil 5 nil nil nil 1120 834 ##(Smalltalk.MySessionPresenter) #resource_Default_view nil 866 138 144 34 1 930 #createAt:extent: 34 2 498 9 53 498 1153 573 1120 1010 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 68 2 0 0 56 1 0 0] 1056 1072 nil 27 722 8 'All Sessions' 410 ##(Smalltalk.ReferenceView) 34 14 nil 592 34 2 8 1140850688 131073 1376 nil nil nil 5 nil nil nil 1376 834 ##(Smalltalk.AllSessionsPresenter) #resource_Default_view nil 866 138 144 34 1 930 #createAt:extent: 34 2 498 9 53 498 1153 573 1376 1010 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 68 2 0 0 56 1 0 0] 1056 1072 nil 27 722 8 'Transcript' 410 ##(Smalltalk.ReferenceView) 34 14 nil 592 34 2 8 1140916224 131073 1632 nil 480 nil 5 nil nil nil 1632 834 ##(Smalltalk.TranscriptPresenter) #resource_Default_view nil 866 138 144 34 1 930 #createAt:extent: 34 2 498 9 53 498 1153 573 1632 1010 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 68 2 0 0 56 1 0 0] 1056 1072 nil 27 722 8 'History' 410 ##(Smalltalk.MultilineTextEdit) 34 16 nil 592 34 2 8 1143017796 1025 1888 nil 480 nil 5 nil nil nil 1888 nil 8 1650007552 852486 ##(Smalltalk.NullConverter) nil nil 11 866 138 144 34 1 930 #createAt:extent: 34 2 498 9 53 498 1153 573 1888 1010 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 68 2 0 0 56 1 0 0] 8 #() 1072 nil 27 722 ##(Smalltalk.Stone) 410 ##(Smalltalk.ReferenceView) 34 14 nil 592 34 2 8 1140850688 131073 2176 nil nil nil 5 nil nil nil 2176 834 ##(Smalltalk.StoneInfoPresenter) #resource_Default_view nil 866 138 144 34 1 930 #createAt:extent: 34 2 498 9 53 498 1153 573 2176 1010 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 68 2 0 0 56 1 0 0] 1056 1072 nil 27 722 8 'Projects' 410 ##(Smalltalk.ShellView) 34 27 nil 592 34 2 8 1078919168 131073 2432 nil 480 498 1201 801 551 265030 4 ##(Smalltalk.Menu) nil true 34 17 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #browseProject 8 'Browse' 9377 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 2562 1 2594 #cloneProject 8 'Clone Git Project ...' 1 1 nil nil nil 2562 1 2594 #loadProjects 8 'Load' 1 1 nil nil nil 2562 1 2594 #unloadProjects 8 'Unload' 1 1 nil nil nil 2642 4097 2562 1 2594 #pullFromGit 8 'Pull from Git' 1 1 nil nil nil 2562 1 2594 #gitCommit 8 'Commit to Git ...' 1 1 nil nil nil 2562 1 2594 #pushToGit 8 'Push to Git' 1 1 nil nil nil 2642 4097 2562 1 2594 #projectChanges 8 'Changes' 1 1 nil nil nil 2562 1 2594 #writeProject 8 'Write' 1 1 nil nil nil 2562 1 2594 #checkoutTag 8 'Checkout Git Tag ...' 1 1 nil nil nil 2562 1 2594 #checkout 8 'Checkout Git Branch ...' 1 1 nil nil nil 2642 4097 2562 1 2594 #projectLog 8 'Git Log' 1 1 nil nil nil 2562 1 2594 #refresh 8 'Refresh' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 2432 1180166 ##(Smalltalk.ProportionalLayout) 170 176 1056 false 170 192 34 2 410 ##(Smalltalk.ListView) 34 30 nil 2432 34 2 8 1140920649 1025 3392 590662 2 ##(Smalltalk.ListModel) 138 144 1056 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 nil nil nil 3392 nil 8 1650059376 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 3 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Project Name' 371 #left 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.SortedCollection) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 3712 8 'doIt' 8 '[:project | project displayName]' 8 #[30 105 226 0 106] #displayName 3728 7 257 nil nil 3392 nil 3 nil 3714 0 nil 3746 3 1 3712 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 3824 7 257 nil false nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 3920 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 3920 nil nil 1970 nil 8 '' 3 nil nil nil nil nil nil nil nil nil 3618 8 'Loaded Sha' 373 #left 3666 #displayString 8 #() 3666 #<= 4096 3714 0 nil 3746 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:project | project sha]' 8 #[30 105 226 0 106] #sha 4128 7 257 nil nil 3392 nil 3 nil nil false nil 3906 nil nil 8 #(67174528 0) 4208 3954 nil false 4000 nil 480 nil 5 nil nil nil 4208 nil nil 1970 nil 8 '' 3 nil nil nil nil nil nil nil nil nil 3618 8 'Branch' 371 #left 3666 #displayString 4096 3666 #<= 4096 3714 0 nil 3746 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:project | project branch]' 8 #[30 105 226 0 106] #branch 4352 7 257 nil nil 3392 nil 3 nil nil false nil 3906 nil nil 8 #(67174528 0) 4432 3954 nil false 4000 nil 480 nil 5 nil nil nil 4432 nil nil 1970 nil 8 '' 3 nil nil nil nil nil nil nil nil nil #report 1056 nil 131171 498 129 129 34 4 nil nil 498 1 1 nil 866 138 144 34 2 930 #createAt:extent: 34 2 498 1 1 498 1121 541 3392 930 #text: 34 1 8 'Project Name' 3392 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 48 2 0 0 14 1 0 0] 8 #() 1072 nil 27 8 'projectList' nil nil nil nil nil 1 nil nil nil nil 1 nil nil 866 138 144 34 4 930 #createAt:extent: 34 2 498 9 53 498 1153 573 2432 930 #contextMenu: 34 1 2528 2432 930 #text: 34 1 8 'Rowan Project List' 2432 930 #updateMenuBar 1056 2432 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 68 2 0 0 56 1 0 0] 34 1 3392 1072 nil 27 2432 170 192 34 14 1632 8 'Transcript' 768 8 'codePane' 2432 8 'projectsList' 1888 8 'history' 2176 8 'Stone' 1120 8 'My Session' 1376 8 'All Sessions' nil 410 ##(Smalltalk.TabView) 34 23 nil 592 34 2 8 1140916736 1 5184 3458 138 144 34 7 1616 1872 ##(Smalltalk.Stone) 1104 1360 752 2416 nil 3520 466 #face3d nil 1 nil nil nil 5184 nil 8 1650396656 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 3568 nil nil nil nil nil #noIcons 866 138 144 34 3 930 #createAt:extent: 34 2 498 1 1 498 1169 633 5184 930 #basicSelectionsByIndex: 34 1 8 #(7) 5184 930 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 5184 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 60 1 0 0] 8 #() 1072 nil 27 866 138 144 34 1 930 #createAt:extent: 34 2 498 1 51 498 1169 633 592 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 72 2 0 0 85 1 0 0] 34 8 1632 1888 2176 1120 1376 768 2432 5184 1072 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 5762 #fixedParentRight 1 5762 #fixedParentTop 51 5762 #fixedParentBottom 1 410 ##(Smalltalk.ReferenceView) 34 14 nil 416 34 2 8 1140850688 131073 5840 nil nil nil 7 nil nil nil 5840 834 ##(Smalltalk.JadeToolsToolBarPresenter) #resource_Default_view nil 866 138 144 34 1 930 #createAt:extent: 34 2 498 1 1 498 1169 51 5840 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 25 0 0 0] 1056 1072 nil 27 5730 5776 1 5792 1 5808 1 5762 #fixedViewTop 51 170 192 34 4 592 8 'cardContainer' 5840 8 'Toolbar' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 5 2514 nil true 34 9 2562 1 2594 #fileNew 8 '&New Workspace' 9373 1 nil nil nil 2562 1 2594 #fileOpen 8 '&Open Workspace...' 9375 1 nil nil nil 2562 1 2594 #fileSave 8 '&Save' 9383 1 nil nil nil 2562 1 2594 #fileSaveAs 8 'Save &As...' 1 1 nil nil nil 2562 1 2594 #fileRevert 8 '&Revert' 1025 1 nil nil nil 2642 4097 2562 1 2594 #resetCursor 8 'Reset &Cursor' 1025 1 nil nil nil 2642 4097 2562 1 2594 #exit 8 'E&xit Jadeite' 17639 1 nil nil nil 8 '&File' nil 1 nil nil 17209 nil nil 2514 nil true 34 22 2562 1 2594 #undo 8 '&Undo' 9397 1 nil nil nil 2562 1 2594 #redo 8 'R&edo' 9395 1 nil nil nil 2642 4097 2562 1 2594 #editCut 8 'Cu&t' 9393 1 nil nil nil 2562 1 2594 #editCopy 8 '&Copy' 9351 1 nil nil nil 2562 1 2594 #editPaste 8 '&Paste' 9389 1 nil nil nil 2562 1 2594 #editDelete 8 '&Delete' 1629 1 nil nil nil 2642 4097 2562 1 2594 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 2642 4097 2562 1 2594 #editFind 8 '&Find...' 9357 1 nil nil nil 2562 1 2594 #editFindNext 8 'Find &Next' 1253 1 nil nil nil 2562 1 2594 #editReplace 8 '&Replace...' 9361 1 nil nil nil 2642 4097 2562 1 2594 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 2562 1 2594 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 2562 1 2594 #jadeExecute 8 '&Execute' 9355 1 nil nil nil 2562 1 2594 #jadeDebug 8 'Debug' 9349 1 nil nil nil 2562 1 2594 #fileIn 8 'Fi&le In' 1 1 nil nil nil 2642 4097 2562 1 2594 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 2562 1 2594 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 8 '&Edit' nil 1 nil nil 17245 nil nil 2514 nil true 34 12 2562 1 2594 #abortTransaction 8 '&Abort Transaction' 1 1 nil nil nil 2562 1 2594 #commitTransaction 8 '&Commit Transaction' 1 1 nil nil nil 2562 1 2594 #disableNativeCode 8 'Disable Native Code' 1 1 nil nil nil 2642 4097 2562 1 2594 #inspectOop 8 'Inspect Oop ...' 1 1 nil nil nil 2562 1 2594 #describeErrorNumber 8 'Description for Error Number ...' 1025 1 nil nil nil 2642 4097 2562 1025 2594 #flipAutoCommit 8 'AutoCommit enabled' 1025 1 nil nil nil 2562 1025 2594 #flipAutocomplete 8 'Autocomplete enabled' 1025 1 nil nil nil 2562 1025 2594 #flipBreakpointsEnabled 8 'Breakpoints enabled' 1025 1 nil nil nil 2562 1025 2594 #flipLogging 8 'Logging Enabled' 1025 1 nil nil nil 2562 1025 2594 #flipTranscript 8 'Transcript writes enabled' 1025 1 nil nil nil 8 '&Jadeite' nil 1 nil nil 17267 nil nil 2514 nil true 34 14 2562 1 2594 #openJadeiteProjectsBrowser 8 'Browse &Projects' 9377 1 nil nil nil 2562 1 2594 #browseProcesses 8 'Browse P&rocesses' 9381 1 nil nil nil 2562 1 2594 #jadeBrowseTests 8 'Browse SUnit &Tests' 1 1 nil nil nil 2642 4097 2562 1 2594 #browseClass 8 'Find Class ...' 13453 1 nil nil nil 2562 1 2594 #browseClassReferences 8 'Browse &Class References ...' 13447 1 nil nil nil 2562 1 2594 #browseImplementorsOf 8 'Browse &Implementors of ...' 13459 1 nil nil nil 2562 1 2594 #browseSendersOf 8 'Browse &Senders of ...' 13479 1 nil nil nil 2562 1 2594 #browseMethodsContaining 8 'Browse &Methods Containing ...' 1 1 nil nil nil 2562 1 2594 #browseLiteralReferences 8 'Browse &Literal References ...' 1 1 nil nil nil 2562 1 2594 #browseBreakpoints 8 'Browse Breakpoints' 1 1 nil nil nil 2642 4097 2562 1025 2594 #browseJadeiteLogs 8 'Browse Logs' 1025 1 nil nil nil 2562 1025 2594 #browseJadeitePrefs 8 'Browse Preferences File' 1025 1 nil nil nil 8 '&Browse' nil 134217729 nil nil 17293 nil nil 2514 nil true 34 4 2562 1 2594 #openGitHubJadeiteProject 8 '&Jadiete GitHub Project' 1025 1 nil nil nil 2562 1 2594 #openGitHubRowanProject 8 '&Rowan GitHub Project' 1025 1 nil nil nil 2642 4097 2562 1 2594 #aboutJadeite 8 '&About Jadeite' 1 1 nil nil nil 8 '&Help' nil 1 nil nil 17301 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons\GS32.ico' nil 9010 nil true 9056 8 'icons\GS16.ico' nil nil nil 1 nil nil 866 138 144 34 3 930 #createAt:extent: 34 2 498 2879 21 498 1201 801 416 930 #text: 34 1 8 'Jadeite Session' 416 930 #updateMenuBar 1056 416 1010 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 159 5 0 0 10 0 0 0 247 7 0 0 154 1 0 0] 34 2 5840 592 1072 nil 27 )! !
!JadeiteTranscript class categoriesFor: #resource_Default_view!public!resources-views! !

