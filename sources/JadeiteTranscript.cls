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

autoCompleteEnabled: boolean
	"for testing"

	JadeiteSearch autoCompleteEnabled: boolean.
	autoCompleteEnabled value: boolean!

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
		register: self selector: #updateSymbols:!

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
!JadeiteTranscript categoriesFor: #autoCompleteEnabled:!accessing!private! !
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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1201 801 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.ReferenceView) 34 14 nil 416 34 2 8 1140850688 131073 592 nil nil nil 7 nil nil nil 592 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeToolsToolBarPresenter) #resource_Default_view nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 1 1 498 1169 51 592 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 25 0 0 0] 8 #() 498 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 946 #fixedParentRight 1 946 #fixedParentTop 1 946 #fixedViewTop 51 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1140850688 131073 1024 nil 480 nil 7 nil nil nil 1024 655878 ##(Smalltalk.CardLayout) 138 144 34 7 721414 ##(Smalltalk.Association) 8 'Workspace' 410 ##(Smalltalk.ReferenceView) 34 14 nil 1024 34 2 8 1140850688 131073 1200 nil 480 nil 5 nil nil nil 1200 658 ##(Smalltalk.CodeSourcePresenter) #resource_Default_view nil 690 138 144 34 1 754 #createAt:extent: 34 2 498 9 53 498 1153 573 1200 834 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 68 2 0 0 56 1 0 0] 880 896 nil 27 1154 8 'My Session' 410 ##(Smalltalk.ReferenceView) 34 14 nil 1024 34 2 8 1140850688 131073 1456 nil nil nil 5 nil nil nil 1456 658 ##(Smalltalk.MySessionPresenter) #resource_Default_view nil 690 138 144 34 1 754 #createAt:extent: 34 2 498 9 53 498 1153 573 1456 834 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 68 2 0 0 56 1 0 0] 880 896 nil 27 1154 8 'All Sessions' 410 ##(Smalltalk.ReferenceView) 34 14 nil 1024 34 2 8 1140850688 131073 1712 nil nil nil 5 nil nil nil 1712 658 ##(Smalltalk.AllSessionsPresenter) #resource_Default_view nil 690 138 144 34 1 754 #createAt:extent: 34 2 498 9 53 498 1153 573 1712 834 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 68 2 0 0 56 1 0 0] 880 896 nil 27 1154 8 'Transcript' 410 ##(Smalltalk.ReferenceView) 34 14 nil 1024 34 2 8 1140916224 131073 1968 nil 480 nil 5 nil nil nil 1968 658 ##(Smalltalk.TranscriptPresenter) #resource_Default_view nil 690 138 144 34 1 754 #createAt:extent: 34 2 498 9 53 498 1153 573 1968 834 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 68 2 0 0 56 1 0 0] 880 896 nil 27 1154 8 'History' 410 ##(Smalltalk.MultilineTextEdit) 34 16 nil 1024 34 2 8 1143017796 1025 2224 nil 480 nil 5 nil nil nil 2224 nil 8 1660100096 852486 ##(Smalltalk.NullConverter) nil nil 11 690 138 144 34 1 754 #createAt:extent: 34 2 498 9 53 498 1153 573 2224 834 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 68 2 0 0 56 1 0 0] 8 #() 896 nil 27 1154 ##(Smalltalk.Stone) 410 ##(Smalltalk.ReferenceView) 34 14 nil 1024 34 2 8 1140850688 131073 2512 nil nil nil 5 nil nil nil 2512 658 ##(Smalltalk.StoneInfoPresenter) #resource_Default_view nil 690 138 144 34 1 754 #createAt:extent: 34 2 498 9 53 498 1153 573 2512 834 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 68 2 0 0 56 1 0 0] 880 896 nil 27 1154 8 'Projects' 410 ##(Smalltalk.ShellView) 34 27 nil 1024 34 2 8 1078919168 131073 2768 nil 480 498 1201 801 551 265030 4 ##(Smalltalk.Menu) nil true 34 17 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #makeDefault 8 'Make Default' 1 1 nil nil nil 2898 1 2930 #browseProject 8 'Browse' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 2898 1 2930 #cloneProject 8 'Clone Git Project ...' 1 1 nil nil nil 2898 1 2930 #loadProjects 8 'Load' 1 1 nil nil nil 2898 1 2930 #unloadProjects 8 'Unload' 1 1 nil nil nil 3026 4097 2898 1 2930 #pullFromGit 8 'Pull from Git' 1 1 nil nil nil 2898 1 2930 #gitCommit 8 'Commit to Git ...' 1 1 nil nil nil 2898 1 2930 #pushToGit 8 'Push to Git' 1 1 nil nil nil 3026 4097 2898 1 2930 #projectChanges 8 'Changes' 1 1 nil nil nil 2898 1 2930 #writeProject 8 'Write' 1 1 nil nil nil 2898 1 2930 #checkout 8 'Checkout Git Branch ...' 1 1 nil nil nil 3026 4097 2898 1 2930 #projectLog 8 'Git Log' 1 1 nil nil nil 2898 1 2930 #refresh 8 'Refresh' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 2768 1180166 ##(Smalltalk.ProportionalLayout) 170 176 880 false 170 192 34 2 410 ##(Smalltalk.ListView) 34 30 nil 2768 34 2 8 1140920649 1025 3728 590662 2 ##(Smalltalk.ListModel) 138 144 880 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 nil nil nil 3728 nil 8 1660151920 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 3 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Project Name' 371 #left 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.SortedCollection) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 4048 8 'doIt' 8 '[:project | project displayName]' 8 #[30 105 226 0 106] #displayName 4064 7 257 nil nil 3728 nil 3 nil 4050 0 nil 4082 3 1 4048 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 4160 7 257 nil false nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 4256 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 4256 nil nil 2306 nil 8 '' 3 nil nil nil nil nil nil nil nil nil 3954 8 'Loaded Sha' 373 #left 4002 #displayString 8 #() 4002 #<= 4432 4050 0 nil 4082 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:project | project sha]' 8 #[30 105 226 0 106] #sha 4464 7 257 nil nil 3728 nil 3 nil nil false nil 4242 nil nil 8 #(67174528 0) 4544 4290 nil false 4336 nil 480 nil 5 nil nil nil 4544 nil nil 2306 nil 8 '' 3 nil nil nil nil nil nil nil nil nil 3954 8 'Branch' 371 #left 4002 #displayString 4432 4002 #<= 4432 4050 0 nil 4082 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:project | project branch]' 8 #[30 105 226 0 106] #branch 4688 7 257 nil nil 3728 nil 3 nil nil false nil 4242 nil nil 8 #(67174528 0) 4768 4290 nil false 4336 nil 480 nil 5 nil nil nil 4768 nil nil 2306 nil 8 '' 3 nil nil nil nil nil nil nil nil nil #report 880 nil 131171 498 129 129 34 4 nil nil 498 1 1 nil 690 138 144 34 2 754 #createAt:extent: 34 2 498 1 1 498 1121 541 3728 754 #text: 34 1 8 'Project Name' 3728 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 48 2 0 0 14 1 0 0] 8 #() 896 nil 27 8 'projectList' nil nil nil nil nil 1 nil nil nil nil 1 nil nil 690 138 144 34 4 754 #createAt:extent: 34 2 498 9 53 498 1153 573 2768 754 #contextMenu: 34 1 2864 2768 754 #text: 34 1 8 'Rowan Project List' 2768 754 #updateMenuBar 880 2768 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 68 2 0 0 56 1 0 0] 34 1 3728 896 nil 27 2768 170 192 34 14 1200 8 'codePane' 2224 8 'history' 1456 8 'My Session' 2768 8 'projectsList' 2512 8 'Stone' 1712 8 'All Sessions' 1968 8 'Transcript' nil 410 ##(Smalltalk.TabView) 34 23 nil 1024 34 2 8 1140916736 1 5520 3794 138 144 34 7 1952 2208 ##(Smalltalk.Stone) 1440 1696 1184 2752 nil 3856 466 #face3d nil 1 nil nil nil 5520 nil 8 1660489200 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 3904 nil nil nil nil nil #noIcons 690 138 144 34 3 754 #createAt:extent: 34 2 498 1 1 498 1169 633 5520 754 #basicSelectionsByIndex: 34 1 8 #(7) 5520 754 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 5520 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 60 1 0 0] 8 #() 896 nil 27 690 138 144 34 1 754 #createAt:extent: 34 2 498 1 51 498 1169 633 1024 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 72 2 0 0 85 1 0 0] 34 8 1968 2224 2512 1456 1712 1200 2768 5520 896 nil 27 914 960 1 976 1 992 51 946 #fixedParentBottom 1 170 192 34 4 592 8 'Toolbar' 1024 8 'cardContainer' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 5 2850 nil true 34 9 2898 1 2930 #fileNew 8 '&New Workspace' 9373 1 nil nil nil 2898 1 2930 #fileOpen 8 '&Open Workspace...' 9375 1 nil nil nil 2898 1 2930 #fileSave 8 '&Save' 9383 1 nil nil nil 2898 1 2930 #fileSaveAs 8 'Save &As...' 1 1 nil nil nil 2898 1 2930 #fileRevert 8 '&Revert' 1025 1 nil nil nil 3026 4097 2898 1 2930 #resetCursor 8 'Reset &Cursor' 1025 1 nil nil nil 3026 4097 2898 1 2930 #exit 8 'E&xit Jadeite' 17639 1 nil nil nil 8 '&File' nil 1 nil nil 18945 nil nil 2850 nil true 34 22 2898 1 2930 #undo 8 '&Undo' 9397 1 nil nil nil 2898 1 2930 #redo 8 'R&edo' 9395 1 nil nil nil 3026 4097 2898 1 2930 #editCut 8 'Cu&t' 9393 1 nil nil nil 2898 1 2930 #editCopy 8 '&Copy' 9351 1 nil nil nil 2898 1 2930 #editPaste 8 '&Paste' 9389 1 nil nil nil 2898 1 2930 #editDelete 8 '&Delete' 1629 1 nil nil nil 3026 4097 2898 1 2930 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 3026 4097 2898 1 2930 #editFind 8 '&Find...' 9357 1 nil nil nil 2898 1 2930 #editFindNext 8 'Find &Next' 1253 1 nil nil nil 2898 1 2930 #editReplace 8 '&Replace...' 9361 1 nil nil nil 3026 4097 2898 1 2930 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 2898 1 2930 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 2898 1 2930 #jadeExecute 8 '&Execute' 9355 1 nil nil nil 2898 1 2930 #jadeDebug 8 'Debug' 9349 1 nil nil nil 2898 1 2930 #fileIn 8 'Fi&le In' 1 1 nil nil nil 3026 4097 2898 1 2930 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 2898 1 2930 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 8 '&Edit' nil 1 nil nil 18981 nil nil 2850 nil true 34 12 2898 1 2930 #abortTransaction 8 '&Abort Transaction' 1 1 nil nil nil 2898 1 2930 #commitTransaction 8 '&Commit Transaction' 1 1 nil nil nil 2898 1 2930 #disableNativeCode 8 'Disable Native Code' 1 1 nil nil nil 3026 4097 2898 1 2930 #inspectOop 8 'Inspect Oop ...' 1 1 nil nil nil 2898 1 2930 #describeErrorNumber 8 'Description for Error Number ...' 1025 1 nil nil nil 3026 4097 2898 1025 2930 #flipAutoCommit 8 'AutoCommit enabled' 1025 1 nil nil nil 2898 1025 2930 #flipAutocomplete 8 'Autocomplete enabled' 1025 1 nil nil nil 2898 1025 2930 #flipBreakpointsEnabled 8 'Breakpoints enabled' 1025 1 nil nil nil 2898 1025 2930 #flipLogging 8 'Logging Enabled' 1025 1 nil nil nil 2898 1025 2930 #flipTranscript 8 'Transcript writes enabled' 1025 1 nil nil nil 8 '&Jadeite' nil 1 nil nil 19003 nil nil 2850 nil true 34 14 2898 1 2930 #openJadeiteProjectsBrowser 8 'Browse &Projects' 9377 1 nil nil nil 2898 1 2930 #browseProcesses 8 'Browse P&rocesses' 9381 1 nil nil nil 2898 1 2930 #jadeBrowseTests 8 'Browse SUnit &Tests' 1 1 nil nil nil 3026 4097 2898 1 2930 #browseClass 8 'Find Class ...' 13453 1 nil nil nil 2898 1 2930 #browseClassReferences 8 'Browse &Class References ...' 13447 1 nil nil nil 2898 1 2930 #browseImplementorsOf 8 'Browse &Implementors of ...' 13459 1 nil nil nil 2898 1 2930 #browseSendersOf 8 'Browse &Senders of ...' 13479 1 nil nil nil 2898 1 2930 #browseMethodsContaining 8 'Browse &Methods Containing ...' 1 1 nil nil nil 2898 1 2930 #browseLiteralReferences 8 'Browse &Literal References ...' 1 1 nil nil nil 2898 1 2930 #browseBreakpoints 8 'Browse Breakpoints' 1 1 nil nil nil 3026 4097 2898 1025 2930 #browseJadeiteLogs 8 'Browse Logs' 1025 1 nil nil nil 2898 1025 2930 #browseJadeitePrefs 8 'Browse Preferences File' 1025 1 nil nil nil 8 '&Browse' nil 134217729 nil nil 19029 nil nil 2850 nil true 34 4 2898 1 2930 #openGitHubJadeiteProject 8 '&Jadiete GitHub Project' 1025 1 nil nil nil 2898 1 2930 #openGitHubRowanProject 8 '&Rowan GitHub Project' 1025 1 nil nil nil 3026 4097 2898 1 2930 #aboutJadeite 8 '&About Jadeite' 1 1 nil nil nil 8 '&Help' nil 1 nil nil 19037 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons\GS32.ico' nil 9010 nil true 9056 8 'icons\GS16.ico' nil nil nil 1 nil nil 690 138 144 34 3 754 #createAt:extent: 34 2 498 7679 21 498 1201 801 416 754 #text: 34 1 8 'Jadeite Session' 416 754 #updateMenuBar 880 416 834 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 87 17 0 0 154 1 0 0] 34 2 592 1024 896 nil 27 )! !
!JadeiteTranscript class categoriesFor: #resource_Default_view!public!resources-views! !

