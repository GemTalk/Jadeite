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

browseBreakpoints
	^JadePresenter browseBreakpointsIn: self gciSession!

browseClass
	^JadePresenter browseClassIn: self gciSession!

browseClassReferences
	^JadePresenter browseClassReferencesInSession: self gciSession!

browseImplementorsOf
	^JadePresenter browseImplementorsIn: self gciSession!

browseJadeiteLogs
	^JadeiteLoggerShell showOnSession: self gciSession!

browseJadeitePrefs
	"Open Jadeite.prefs in the working directory"

	| path file setDefaultPrefs fileStream |
	path := SessionManager current imageBase , JadeitePreferences preferencesFile.
	setDefaultPrefs := false.
	(File exists: path)
		ifFalse: 
			[(MessageBox
				confirm: 'Jadeite.prefs does not exist in ' , SessionManager current imageBase , '. Create it?')
					ifTrue: [setDefaultPrefs := true]
					ifFalse: [^self]].
	file := File
				open: path
				mode: #open
				check: false.	"create it if it's not there"
	
	[setDefaultPrefs
		ifTrue: 
			[fileStream := FileStream on: file.
			fileStream
				nextPutAll: JadeitePreferences preferencesFileDefaultContents;
				flush]]
			ensure: [file close].
	^(JadeitePreferencesWorkspace open: path onSession: gciSession)
		isModified: false;
		caption: 'Preferences File: ', path!

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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 1201 801 551 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.ReferenceView) 34 14 nil 416 34 2 8 1140850688 131073 608 nil nil nil 7 nil nil nil 608 1180166 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeToolsToolBarPresenter) #resource_Default_view nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 1 1 514 1169 51 608 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 25 0 0 0] 8 #() 514 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 962 #fixedParentRight 1 962 #fixedParentTop 1 962 #fixedViewTop 51 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1140850688 131073 1040 nil 466 496 nil 7 nil nil nil 1040 655878 ##(Smalltalk.CardLayout) 138 144 34 7 721414 ##(Smalltalk.Association) 8 'Workspace' 410 ##(Smalltalk.ReferenceView) 34 14 nil 1040 34 2 8 1140850688 131073 1232 nil 466 8 4278190080 nil 5 nil nil nil 1232 674 ##(Smalltalk.CodeSourcePresenter) #resource_Default_view nil 706 138 144 34 1 770 #createAt:extent: 34 2 514 9 55 514 1153 571 1232 850 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 56 1 0 0] 896 912 nil 27 1186 8 'My Session' 410 ##(Smalltalk.ReferenceView) 34 14 nil 1040 34 2 8 1140850688 131073 1520 nil nil nil 5 nil nil nil 1520 674 ##(Smalltalk.MySessionPresenter) #resource_Default_view nil 706 138 144 34 1 770 #createAt:extent: 34 2 514 9 55 514 1153 571 1520 850 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 56 1 0 0] 896 912 nil 27 1186 8 'All Sessions' 410 ##(Smalltalk.ReferenceView) 34 14 nil 1040 34 2 8 1140850688 131073 1776 nil nil nil 5 nil nil nil 1776 674 ##(Smalltalk.AllSessionsPresenter) #resource_Default_view nil 706 138 144 34 1 770 #createAt:extent: 34 2 514 9 55 514 1153 571 1776 850 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 56 1 0 0] 896 912 nil 27 1186 8 'Transcript' 410 ##(Smalltalk.ReferenceView) 34 14 nil 1040 34 2 8 1140916224 131073 2032 nil 466 8 4278190080 nil 5 nil nil nil 2032 674 ##(Smalltalk.TranscriptPresenter) #resource_Default_view nil 706 138 144 34 1 770 #createAt:extent: 34 2 514 9 55 514 1153 571 2032 850 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 56 1 0 0] 896 912 nil 27 1186 8 'History' 410 ##(Smalltalk.MultilineTextEdit) 34 16 nil 1040 34 2 8 1143017796 1025 2320 nil 466 8 4278190080 nil 5 nil nil nil 2320 nil 8 4294902927 852486 ##(Smalltalk.NullConverter) nil nil 11 706 138 144 34 1 770 #createAt:extent: 34 2 514 9 55 514 1153 571 2320 850 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 56 1 0 0] 8 #() 912 nil 27 1186 ##(Smalltalk.Stone) 410 ##(Smalltalk.ReferenceView) 34 14 nil 1040 34 2 8 1140850688 131073 2640 nil nil nil 5 nil nil nil 2640 674 ##(Smalltalk.StoneInfoPresenter) #resource_Default_view nil 706 138 144 34 1 770 #createAt:extent: 34 2 514 9 55 514 1153 571 2640 850 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 56 1 0 0] 896 912 nil 27 1186 8 'Projects' 410 ##(Smalltalk.ShellView) 34 27 nil 1040 34 2 8 1078919168 131073 2896 nil 466 8 4278190080 514 1201 801 551 265030 4 ##(Smalltalk.Menu) nil true 34 17 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #makeDefault 8 'Make Default' 1 1 nil nil nil 3058 1 3090 #browseProject 8 'Browse' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 3058 1 3090 #cloneProject 8 'Clone Git Project ...' 1 1 nil nil nil 3058 1 3090 #loadProjects 8 'Load' 1 1 nil nil nil 3058 1 3090 #unloadProjects 8 'Unload' 1 1 nil nil nil 3186 4097 3058 1 3090 #pullFromGit 8 'Pull from Git' 1 1 nil nil nil 3058 1 3090 #gitCommit 8 'Commit to Git ...' 1 1 nil nil nil 3058 1 3090 #pushToGit 8 'Push to Git' 1 1 nil nil nil 3186 4097 3058 1 3090 #projectChanges 8 'Changes' 1 1 nil nil nil 3058 1 3090 #writeProject 8 'Write' 1 1 nil nil nil 3058 1 3090 #checkout 8 'Checkout Git Branch ...' 1 1 nil nil nil 3186 4097 3058 1 3090 #projectLog 8 'Git Log' 1 1 nil nil nil 3058 1 3090 #refresh 8 'Refresh' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 2896 1180166 ##(Smalltalk.ProportionalLayout) 170 176 896 false 170 192 34 2 410 ##(Smalltalk.ListView) 34 30 nil 2896 34 2 8 1140920649 1025 3888 590662 2 ##(Smalltalk.ListModel) 138 144 896 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 466 8 4278190080 nil 7 nil nil nil 3888 nil 8 4294905435 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 3 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Project Name' 371 #left 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.SortedCollection) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 4240 8 'doIt' 8 '[:project | project displayName]' 8 #[30 105 226 0 106] #displayName 4256 7 257 nil nil 3888 nil 3 nil 4242 0 nil 4274 3 1 4240 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 4352 7 257 nil false nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 4448 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 4448 nil nil 2434 nil 8 '' 3 nil nil nil nil nil nil nil nil nil 4146 8 'Loaded Sha' 373 #left 4194 #displayString 8 #() 4194 #<= 4624 4242 0 nil 4274 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:project | project sha]' 8 #[30 105 226 0 106] #sha 4656 7 257 nil nil 3888 nil 3 nil nil false nil 4434 nil nil 8 #(67174528 0) 4736 4482 nil false 4528 nil 466 8 4278190080 nil 5 nil nil nil 4736 nil nil 2434 nil 8 '' 3 nil nil nil nil nil nil nil nil nil 4146 8 'Branch' 371 #left 4194 #displayString 4624 4194 #<= 4624 4242 0 nil 4274 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:project | project branch]' 8 #[30 105 226 0 106] #branch 4912 7 257 nil nil 3888 nil 3 nil nil false nil 4434 nil nil 8 #(67174528 0) 4992 4482 nil false 4528 nil 466 4800 nil 5 nil nil nil 4992 nil nil 2434 nil 8 '' 3 nil nil nil nil nil nil nil nil nil #report 896 nil 131171 514 129 129 34 4 nil nil 514 1 1 nil 706 138 144 34 2 770 #createAt:extent: 34 2 514 1 1 514 1121 539 3888 770 #text: 34 1 8 'Project Name' 3888 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 48 2 0 0 13 1 0 0] 8 #() 912 nil 27 8 'projectList' nil nil nil nil nil 1 nil nil nil nil 1 nil nil 706 138 144 34 4 770 #createAt:extent: 34 2 514 9 55 514 1153 571 2896 770 #contextMenu: 34 1 3024 2896 770 #text: 34 1 8 'Rowan Project List' 2896 770 #updateMenuBar 896 2896 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 56 1 0 0] 34 1 3888 912 nil 27 2896 170 192 34 14 1232 8 'codePane' 2320 8 'history' 2032 8 'Transcript' 2896 8 'projectsList' 2640 8 'Stone' 1776 8 'All Sessions' 1520 8 'My Session' nil 410 ##(Smalltalk.TabView) 34 23 nil 1040 34 2 8 1140916736 1 5760 3954 138 144 34 7 2016 2304 ##(Smalltalk.Stone) 1504 1760 1216 2880 nil 4016 721158 ##(Smalltalk.SystemColor) 31 nil 1 nil nil nil 5760 nil 8 4294907159 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 4096 nil nil nil nil nil #noIcons 706 138 144 34 3 770 #createAt:extent: 34 2 514 1 1 514 1169 633 5760 770 #basicSelectionsByIndex: 34 1 8 #(7) 5760 770 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 5760 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 60 1 0 0] 8 #() 912 nil 27 706 138 144 34 1 770 #createAt:extent: 34 2 514 1 51 514 1169 633 1040 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 72 2 0 0 85 1 0 0] 34 8 2032 2320 2640 1520 1776 1232 2896 5760 912 nil 27 930 976 1 992 1 1008 51 962 #fixedParentBottom 1 170 192 34 4 608 8 'Toolbar' 1040 8 'cardContainer' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 5 3010 nil true 34 9 3058 1 3090 #fileNew 8 '&New Workspace' 9373 1 nil nil nil 3058 1 3090 #fileOpen 8 '&Open Workspace...' 9375 1 nil nil nil 3058 1 3090 #fileSave 8 '&Save' 9383 1 nil nil nil 3058 1 3090 #fileSaveAs 8 'Save &As...' 1 1 nil nil nil 3058 1 3090 #fileRevert 8 '&Revert' 1025 1 nil nil nil 3186 4097 3058 1 3090 #resetCursor 8 'Reset &Cursor' 1025 1 nil nil nil 3186 4097 3058 1 3090 #exit 8 'E&xit Jadeite' 17639 1 nil nil nil 8 '&File' nil 1 nil nil 11141 nil nil 3010 nil true 34 22 3058 1 3090 #undo 8 '&Undo' 9397 1 nil nil nil 3058 1 3090 #redo 8 'R&edo' 9395 1 nil nil nil 3186 4097 3058 1 3090 #editCut 8 'Cu&t' 9393 1 nil nil nil 3058 1 3090 #editCopy 8 '&Copy' 9351 1 nil nil nil 3058 1 3090 #editPaste 8 '&Paste' 9389 1 nil nil nil 3058 1 3090 #editDelete 8 '&Delete' 1629 1 nil nil nil 3186 4097 3058 1 3090 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 3186 4097 3058 1 3090 #editFind 8 '&Find...' 9357 1 nil nil nil 3058 1 3090 #editFindNext 8 'Find &Next' 1253 1 nil nil nil 3058 1 3090 #editReplace 8 '&Replace...' 9361 1 nil nil nil 3186 4097 3058 1 3090 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 3058 1 3090 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 3058 1 3090 #jadeExecute 8 '&Execute' 9355 1 nil nil nil 3058 1 3090 #jadeDebug 8 'Debug' 9349 1 nil nil nil 3058 1 3090 #fileIn 8 'Fi&le In' 1 1 nil nil nil 3186 4097 3058 1 3090 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 3058 1 3090 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 8 '&Edit' nil 1 nil nil 11177 nil nil 3010 nil true 34 12 3058 1 3090 #abortTransaction 8 '&Abort Transaction' 1 1 nil nil nil 3058 1 3090 #commitTransaction 8 '&Commit Transaction' 1 1 nil nil nil 3058 1 3090 #disableNativeCode 8 'Disable Native Code' 1 1 nil nil nil 3186 4097 3058 1 3090 #inspectOop 8 'Inspect Oop ...' 1 1 nil nil nil 3058 1 3090 #describeErrorNumber 8 'Description for Error Number ...' 1025 1 nil nil nil 3186 4097 3058 1025 3090 #flipAutoCommit 8 'AutoCommit enabled' 1025 1 nil nil nil 3058 1025 3090 #flipAutocomplete 8 'Autocomplete enabled' 1025 1 nil nil nil 3058 1025 3090 #flipBreakpointsEnabled 8 'Breakpoints enabled' 1025 1 nil nil nil 3058 1025 3090 #flipLogging 8 'Logging Enabled' 1025 1 nil nil nil 3058 1025 3090 #flipTranscript 8 'Transcript writes enabled' 1025 1 nil nil nil 8 '&Jadeite' nil 1 nil nil 11199 nil nil 3010 nil true 34 14 3058 1 3090 #openJadeiteProjectsBrowser 8 'Browse &Projects' 9377 1 nil nil nil 3058 1 3090 #browseProcesses 8 'Browse P&rocesses' 9381 1 nil nil nil 3058 1 3090 #jadeBrowseTests 8 'Browse SUnit &Tests' 1 1 nil nil nil 3186 4097 3058 1 3090 #browseClass 8 'Find Class ...' 13453 1 nil nil nil 3058 1 3090 #browseClassReferences 8 'Browse &Class References ...' 13447 1 nil nil nil 3058 1 3090 #browseImplementorsOf 8 'Browse &Implementors of ...' 13459 1 nil nil nil 3058 1 3090 #browseSendersOf 8 'Browse &Senders of ...' 13479 1 nil nil nil 3058 1 3090 #browseMethodsContaining 8 'Browse &Methods Containing ...' 1 1 nil nil nil 3058 1 3090 #browseLiteralReferences 8 'Browse &Literal References ...' 1 1 nil nil nil 3058 1 3090 #browseBreakpoints nil 1 1 nil nil nil 3186 4097 3058 1025 3090 #browseJadeiteLogs 8 'Browse Logs' 1025 1 nil nil nil 3058 1025 3090 #browseJadeitePrefs 8 'Browse Preferences File' 1025 1 nil nil nil 8 '&Browse' nil 134217729 nil nil 11225 nil nil 3010 nil true 34 4 3058 1 3090 #openGitHubJadeiteProject 8 '&Jadiete GitHub Project' 1025 1 nil nil nil 3058 1 3090 #openGitHubRowanProject 8 '&Rowan GitHub Project' 1025 1 nil nil nil 3186 4097 3058 1 3090 #aboutJadeite 8 '&About Jadeite' 1 1 nil nil nil 8 '&Help' nil 1 nil nil 11233 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons\GS32.ico' nil 9250 nil true 9296 8 'icons\GS16.ico' nil nil nil 1 nil nil 706 138 144 34 3 770 #createAt:extent: 34 2 514 7679 21 514 1201 801 416 770 #text: 34 1 8 'Jadeite Session' 416 770 #updateMenuBar 896 416 850 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 87 17 0 0 154 1 0 0] 34 2 608 1040 912 nil 27 )! !
!JadeiteTranscript class categoriesFor: #resource_Default_view!public!resources-views! !

