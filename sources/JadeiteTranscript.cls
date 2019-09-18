"Filed out from Dolphin Smalltalk 7"!

JadeTranscript subclass: #JadeiteTranscript
	instanceVariableNames: 'projectListPresenter isTranscriptInstalled autoCommit areBreakpointsDisabled'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteTranscript guid: (GUID fromString: '{93b3c6ce-9a55-45db-bd1e-cc1a44a28e4e}')!
JadeiteTranscript comment: ''!
!JadeiteTranscript categoriesForClass!Unclassified! !
!JadeiteTranscript methodsFor!

abortTransaction
	super abortTransaction.
	projectListPresenter refresh!

areBreakpointsDisabled
	^areBreakpointsDisabled!

areBreakpointsDisabled: anObject
	areBreakpointsDisabled := anObject!

autoCommit
	"for testing"
	^autoCommit value!

autoCommit: boolean
	autoCommit value: boolean.
	gciSession
		ifNotNil: 
			[:session |
			"not inconceivable there are dead transcripts around from test runs"
			session autoCommit: boolean]!

browseBreakpoints
	| methodListBrowser menuCommand methodMenu |
	methodListBrowser := JadePresenter browseBreakpointsIn: self gciSession.
	menuCommand := MessageSend receiver: methodListBrowser primaryPresenter
				selector: #clearAllBreakpoints.
	methodMenu := methodListBrowser view menuBar items detect: [:menu | '*Methods*' match: menu text]
				ifNone: [^methodListBrowser]. 
	methodMenu addSeparator.
	methodMenu addCommand: menuCommand description: 'Clear All Breakpoints'.
	^methodListBrowser!

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

	| path fileStream file |
	path := File workingDirectory , self preferencesFile.
	(File exists: path)
		ifFalse: 
			[(MessageBox confirm: 'Jadeite.prefs does not exist in ' , File workingDirectory , '. Create it?')
				ifFalse: [^self]].
	file := File
				open: path
				mode: #open
				check: false.	"create it if it's not there"
	file close.
	fileStream := FileStream read: path.
	
	[^(JadeWorkspace showOnSession: gciSession)
		model: fileStream contents;
		isModified: false;
		updateCaption: path]
			ensure: [fileStream close]!

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

flipBreakpointsDisabled
	| answeringService |
	answeringService := RowanAnsweringService new.
	answeringService flipBreakpointsDisabledIn: self gciSession with: areBreakpointsDisabled value not.
	areBreakpointsDisabled value: areBreakpointsDisabled value not!

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
	areBreakpointsDisabled := ValueHolder with: false. !

isTranscriptInstalled
	^isTranscriptInstalled value!

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

onViewOpened
	| answeringService installed |
	super onViewOpened.
	projectListPresenter
		gciSession: gciSession;
		refreshProjects.
	JadeTextStyles default resetColors.	"reset colors on login"
	answeringService := RowanAnsweringService new.
	installed := answeringService isTranscriptInstalledIn: self gciSession.
	isTranscriptInstalled value: installed.
	areBreakpointsDisabled value: (answeringService breakPointsAreDisabled: self gciSession).
	self registerPresentersForUpdates!

openCommitInGitHub
	| projectService |
	projectService := projectListPresenter projectListPresenter selections first.
	^JadePresenter openCommit: projectService sha inGitHub: projectService!

openDictionaryBrowser
	gciSession hasServer ifTrue: [^JadeiteBrowser showOnSession: gciSession]!

openGitHubJadeiteProject
	^JadePresenter openGitHubJadeiteProject!

openGitHubRowanProject
	^JadePresenter openGitHubRowanProject!

openJadeiteProjectsBrowser
	gciSession hasServer ifTrue: [^JadeiteBrowser showOnSession: gciSession].
	MessageBox warning: 'Cannot open Jadeite Projects browser'
		caption: 'Cannot open Jadeite Projects browser'!

preferencesFile

	^'Jadeite.prefs'!

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
	query commandSymbol = #flipBreakpointsDisabled
		ifTrue: 
			[query isChecked: areBreakpointsDisabled value.
			^true]!

registerPresentersForUpdates
	BrowserUpdate current register: self selector: #autoCommitUpdate:!

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
!JadeiteTranscript categoriesFor: #areBreakpointsDisabled!accessing!private! !
!JadeiteTranscript categoriesFor: #areBreakpointsDisabled:!accessing!private! !
!JadeiteTranscript categoriesFor: #autoCommit!accessing!private! !
!JadeiteTranscript categoriesFor: #autoCommit:!accessing!private! !
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
!JadeiteTranscript categoriesFor: #flipBreakpointsDisabled!menu handlers!public! !
!JadeiteTranscript categoriesFor: #flipDebugger!menu handlers!public! !
!JadeiteTranscript categoriesFor: #flipLogging!menu handlers!public! !
!JadeiteTranscript categoriesFor: #flipTranscript!menu handlers!public! !
!JadeiteTranscript categoriesFor: #gciSession:!public! !
!JadeiteTranscript categoriesFor: #initialize!initialization!public! !
!JadeiteTranscript categoriesFor: #isTranscriptInstalled!public! !
!JadeiteTranscript categoriesFor: #onCloseRequested:!event handling!public! !
!JadeiteTranscript categoriesFor: #onViewOpened!event handling!public! !
!JadeiteTranscript categoriesFor: #openCommitInGitHub!menu handlers!public! !
!JadeiteTranscript categoriesFor: #openDictionaryBrowser!menu handlers!public! !
!JadeiteTranscript categoriesFor: #openGitHubJadeiteProject!event handling!menu handlers!public! !
!JadeiteTranscript categoriesFor: #openGitHubRowanProject!event handling!menu handlers!public! !
!JadeiteTranscript categoriesFor: #openJadeiteProjectsBrowser!menu handlers!public! !
!JadeiteTranscript categoriesFor: #preferencesFile!constants!private! !
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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 1201 801 551 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1140850688 131073 608 nil 466 496 nil 7 nil nil nil 608 655878 ##(Smalltalk.CardLayout) 138 144 34 7 721414 ##(Smalltalk.Association) 8 'Workspace' 410 ##(Smalltalk.ReferenceView) 34 14 nil 608 34 2 8 1140850688 131073 800 nil 466 8 4278190080 nil 5 nil nil nil 800 1180166 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.CodeSourcePresenter) #resource_Default_view nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 9 55 514 1153 571 800 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 56 1 0 0] 8 #() 514 193 193 nil 27 754 8 'My Session' 410 ##(Smalltalk.ReferenceView) 34 14 nil 608 34 2 8 1140850688 131073 1184 nil nil nil 5 nil nil nil 1184 898 ##(Smalltalk.MySessionPresenter) #resource_Default_view nil 930 138 144 34 1 994 #createAt:extent: 34 2 514 9 55 514 1153 571 1184 1074 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 56 1 0 0] 1120 1136 nil 27 754 8 'All Sessions' 410 ##(Smalltalk.ReferenceView) 34 14 nil 608 34 2 8 1140850688 131073 1440 nil nil nil 5 nil nil nil 1440 898 ##(Smalltalk.AllSessionsPresenter) #resource_Default_view nil 930 138 144 34 1 994 #createAt:extent: 34 2 514 9 55 514 1153 571 1440 1074 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 56 1 0 0] 1120 1136 nil 27 754 8 'Transcript' 410 ##(Smalltalk.ReferenceView) 34 14 nil 608 34 2 8 1140916224 131073 1696 nil 466 8 4278190080 nil 5 nil nil nil 1696 898 ##(Smalltalk.TranscriptPresenter) #resource_Default_view nil 930 138 144 34 1 994 #createAt:extent: 34 2 514 9 55 514 1153 571 1696 1074 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 56 1 0 0] 1120 1136 nil 27 754 8 'History' 410 ##(Smalltalk.MultilineTextEdit) 34 16 nil 608 34 2 8 1143017796 1025 1984 nil 466 8 4278190080 nil 5 nil nil nil 1984 nil 8 4294904715 852486 ##(Smalltalk.NullConverter) nil nil 11 930 138 144 34 1 994 #createAt:extent: 34 2 514 9 55 514 1153 571 1984 1074 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 56 1 0 0] 8 #() 1136 nil 27 754 ##(Smalltalk.Stone) 410 ##(Smalltalk.ReferenceView) 34 14 nil 608 34 2 8 1140850688 131073 2304 nil nil nil 5 nil nil nil 2304 898 ##(Smalltalk.StoneInfoPresenter) #resource_Default_view nil 930 138 144 34 1 994 #createAt:extent: 34 2 514 9 55 514 1153 571 2304 1074 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 56 1 0 0] 1120 1136 nil 27 754 8 'Projects' 410 ##(Smalltalk.ShellView) 34 27 nil 608 34 2 8 1078919168 131073 2560 nil 466 8 4278190080 514 1201 801 551 265030 4 ##(Smalltalk.Menu) nil true 34 18 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #makeDefault 8 'Make Default' 1 1 nil nil nil 2722 1 2754 #browseProject 8 'Browse' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 2722 1 2754 #cloneProject 8 'Clone Git Project ...' 1 1 nil nil nil 2722 1 2754 #loadProjects 8 'Load' 1 1 nil nil nil 2722 1 2754 #unloadProjects 8 'Unload' 1 1 nil nil nil 2850 4097 2722 1 2754 #pullFromGit 8 'Pull from Git' 1 1 nil nil nil 2722 1 2754 #gitCommit 8 'Commit to Git ...' 1 1 nil nil nil 2722 1 2754 #pushToGit 8 'Push to Git' 1 1 nil nil nil 2850 4097 2722 1 2754 #projectChanges 8 'Changes' 1 1 nil nil nil 2722 1 2754 #writeProject 8 'Write' 1 1 nil nil nil 2722 1 2754 #checkout 8 'Checkout Git Branch ...' 1 1 nil nil nil 2850 4097 2722 1 2754 #projectLog 8 'Git Log' 1 1 nil nil nil 2722 1 2754 #openCommitInGitHub 8 'Browse Commit In GitHub' 1 1 nil nil nil 2722 1 2754 #refresh 8 'Refresh' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 2560 1180166 ##(Smalltalk.ProportionalLayout) 170 176 1120 false 170 192 34 2 410 ##(Smalltalk.ListView) 34 30 nil 2560 34 2 8 1140920649 1025 3600 590662 2 ##(Smalltalk.ListModel) 138 144 1120 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 466 8 4278190080 nil 7 nil nil nil 3600 nil 8 4294906585 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 3 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Project Name' 371 #left 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.SortedCollection) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 3952 8 'doIt' 8 '[:project | project displayName]' 8 #[30 105 226 0 106] #displayName 3968 7 257 nil nil 3600 nil 3 nil 3954 0 nil 3986 3 1 3952 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 4064 7 257 nil false nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 4160 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 4160 nil nil 2098 nil 8 '' 3 nil nil nil nil nil nil nil nil nil 3858 8 'Loaded Sha' 373 #left 3906 #displayString 8 #() 3906 #<= 4336 3954 0 nil 3986 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:project | project sha]' 8 #[30 105 226 0 106] #sha 4368 7 257 nil nil 3600 nil 3 nil nil false nil 4146 nil nil 8 #(67174528 0) 4448 4194 nil false 4240 nil 466 8 4278190080 nil 5 nil nil nil 4448 nil nil 2098 nil 8 '' 3 nil nil nil nil nil nil nil nil nil 3858 8 'Branch' 371 #left 3906 #displayString 4336 3906 #<= 4336 3954 0 nil 3986 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:project | project branch]' 8 #[30 105 226 0 106] #branch 4624 7 257 nil nil 3600 nil 3 nil nil false nil 4146 nil nil 8 #(67174528 0) 4704 4194 nil false 4240 nil 466 4512 nil 5 nil nil nil 4704 nil nil 2098 nil 8 '' 3 nil nil nil nil nil nil nil nil nil #report 1120 nil 131171 514 129 129 34 4 nil nil 514 1 1 nil 930 138 144 34 2 994 #createAt:extent: 34 2 514 1 1 514 1121 539 3600 994 #text: 34 1 8 'Project Name' 3600 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 48 2 0 0 13 1 0 0] 8 #() 1136 nil 27 8 'projectList' nil nil nil nil nil 1 nil nil nil nil 1 nil nil 930 138 144 34 4 994 #createAt:extent: 34 2 514 9 55 514 1153 571 2560 994 #contextMenu: 34 1 2688 2560 994 #text: 34 1 8 'Rowan Project List' 2560 994 #updateMenuBar 1120 2560 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 56 1 0 0] 34 1 3600 1136 nil 27 2560 170 192 34 14 1440 8 'All Sessions' 1984 8 'history' 1184 8 'My Session' 800 8 'codePane' 2304 8 'Stone' 2560 8 'projectsList' 1696 8 'Transcript' nil 410 ##(Smalltalk.TabView) 34 23 nil 608 34 2 8 1140916736 1 5472 3666 138 144 34 7 1680 1968 ##(Smalltalk.Stone) 1168 1424 784 2544 nil 3728 721158 ##(Smalltalk.SystemColor) 31 nil 1 nil nil nil 5472 nil 8 4294907635 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 3808 nil nil nil nil nil #noIcons 930 138 144 34 3 994 #createAt:extent: 34 2 514 1 1 514 1169 633 5472 994 #basicSelectionsByIndex: 34 1 8 #(7) 5472 994 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 5472 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 60 1 0 0] 8 #() 1136 nil 27 930 138 144 34 1 994 #createAt:extent: 34 2 514 1 51 514 1169 633 608 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 72 2 0 0 85 1 0 0] 34 8 1696 1984 2304 1184 1440 800 2560 5472 1136 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 6066 #fixedParentRight 1 6066 #fixedParentTop 51 6066 #fixedParentBottom 1 410 ##(Smalltalk.ReferenceView) 34 14 nil 416 34 2 8 1140850688 131073 6144 nil nil nil 7 nil nil nil 6144 898 ##(Smalltalk.JadeToolsToolBarPresenter) #resource_Default_view nil 930 138 144 34 1 994 #createAt:extent: 34 2 514 1 1 514 1169 51 6144 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 25 0 0 0] 1120 1136 nil 27 6034 6080 1 6096 1 6112 1 6066 #fixedViewTop 51 170 192 34 4 608 8 'cardContainer' 6144 8 'Toolbar' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 5 2674 nil true 34 9 2722 1 2754 #fileNew 8 '&New Workspace' 9373 1 nil nil nil 2722 1 2754 #fileOpen 8 '&Open Workspace...' 9375 1 nil nil nil 2722 1 2754 #fileSave 8 '&Save' 9383 1 nil nil nil 2722 1 2754 #fileSaveAs 8 'Save &As...' 1 1 nil nil nil 2722 1 2754 #fileRevert 8 '&Revert' 1025 1 nil nil nil 2850 4097 2722 1 2754 #resetCursor 8 'Reset &Cursor' 1025 1 nil nil nil 2850 4097 2722 1 2754 #exit 8 'E&xit Jadeite' 17639 1 nil nil nil 8 '&File' nil 1 nil nil 37777 nil nil 2674 nil true 34 15 2722 1 2754 #undo 8 '&Undo' 9397 1 nil nil nil 2722 1 2754 #redo 8 'R&edo' 9395 1 nil nil nil 2850 4097 2722 1 2754 #editCut 8 'Cu&t' 9393 1 nil nil nil 2722 1 2754 #editCopy 8 '&Copy' 9351 1 nil nil nil 2722 1 2754 #editPaste 8 '&Paste' 9389 1 nil nil nil 2722 1 2754 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 2722 1 2754 #editDelete 8 '&Delete' 1629 1 nil nil nil 2850 4097 2722 1 2754 #editFind 8 '&Find...' 9357 1 nil nil nil 2722 1 2754 #editFindNext 8 'Find &Next' 1253 1 nil nil nil 2722 1 2754 #editReplace 8 '&Replace...' 9361 1 nil nil nil 2850 4097 2722 1 2754 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 2722 1 2754 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 8 '&Edit' nil 1 nil nil 37803 nil nil 2674 nil true 34 18 2722 1 2754 #sleepAndCommit 8 '&Sleep and Commit' 1 1 nil nil nil 2722 1 2754 #abortTransaction 8 '&Abort Transaction' 1 1 nil nil nil 2722 1 2754 #commitTransaction 8 '&Commit Transaction' 1 1 nil nil nil 2722 1 2754 #disableNativeCode 8 'Disable Native Code' 1 1 nil nil nil 2850 4097 2722 1 2754 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 2722 1 2754 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 2722 1 2754 #jadeExecute 8 '&Execute' 9355 1 nil nil nil 2722 1 2754 #jadeDebug 8 'Debug' 9349 1 nil nil nil 2722 1 2754 #fileIn 8 'Fi&le In' 1 1 nil nil nil 2850 4097 2722 1 2754 #inspectOop 8 'Inspect Oop ...' 1 1 nil nil nil 2722 1 2754 #describeErrorNumber 8 'Description for Error Number ...' 1025 1 nil nil nil 2722 1025 2754 #flipTranscript 8 'Transcript writes enabled' 1025 1 nil nil nil 2722 1025 2754 #flipAutoCommit 8 'AutoCommit enabled' 1025 1 nil nil nil 2722 1025 2754 #flipBreakpointsDisabled 8 'Breakpoints disabled' 1025 1 nil nil nil 2850 4097 2722 1025 2754 #flipLogging 8 'Logging' 1025 1 nil nil nil 8 '&Jadeite' nil 1 nil nil 37835 nil nil 2674 nil true 34 14 2722 1 2754 #openJadeiteProjectsBrowser 8 'Browse &Projects' 9377 1 nil nil nil 2722 1 2754 #browseProcesses 8 'Browse P&rocesses' 9381 1 nil nil nil 2722 1 2754 #jadeBrowseTests 8 'Browse SUnit &Tests' 1 1 nil nil nil 2850 4097 2722 1 2754 #browseClass 8 'Find Class ...' 13453 1 nil nil nil 2722 1 2754 #browseClassReferences 8 'Browse &Class References ...' 13447 1 nil nil nil 2722 1 2754 #browseImplementorsOf 8 'Browse &Implementors of ...' 13459 1 nil nil nil 2722 1 2754 #browseSendersOf 8 'Browse &Senders of ...' 13479 1 nil nil nil 2722 1 2754 #browseMethodsContaining 8 'Browse &Methods Containing ...' 1 1 nil nil nil 2722 1 2754 #browseLiteralReferences 8 'Browse &Literal References ...' 1 1 nil nil nil 2722 1 2754 #browseBreakpoints nil 1 1 nil nil nil 2850 4097 2722 1025 2754 #browseJadeiteLogs 8 'Browse Logs' 1025 1 nil nil nil 2722 1025 2754 #browseJadeitePrefs 8 'Browse Preferences File' 1025 1 nil nil nil 8 '&Browse' nil 134217729 nil nil 37861 nil nil 2674 nil true 34 4 2722 1 2754 #openGitHubJadeiteProject 8 '&Jadiete GitHub Project' 1025 1 nil nil nil 2722 1 2754 #openGitHubRowanProject 8 '&Rowan GitHub Project' 1025 1 nil nil nil 2850 4097 2722 1 2754 #aboutJadeite 8 '&About Jadeite' 1 1 nil nil nil 8 '&Help' nil 1 nil nil 37869 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons\GS32.ico' nil 9282 nil true 9328 8 'icons\GS16.ico' nil nil nil 1 nil nil 930 138 144 34 3 994 #createAt:extent: 34 2 514 7679 21 514 1201 801 416 994 #text: 34 1 8 'Jadeite Session' 416 994 #updateMenuBar 1120 416 1074 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 87 17 0 0 154 1 0 0] 34 2 6144 608 1136 nil 27 )! !
!JadeiteTranscript class categoriesFor: #resource_Default_view!public!resources-views! !

