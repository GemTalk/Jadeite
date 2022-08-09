"Filed out from Dolphin Smallalk"!

JadeTranscript subclass: #JadeiteTranscript
	instanceVariableNames: 'projectListPresenter isTranscriptInstalled autoCommit areBreakpointsEnabled autoCompleteEnabled transactionModePresenter lastKnownTransaction'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteTranscript guid: (GUID fromString: '{93b3c6ce-9a55-45db-bd1e-cc1a44a28e4e}')!
JadeiteTranscript comment: ''!
!JadeiteTranscript categoriesForClass!Unclassified! !
!JadeiteTranscript methodsFor!

abortedTransaction
	self displayLastKnownCommitOrAbort.
	self toolbarPresenter view validateUserInterface!

abortTransaction
	super abortTransaction.
	projectListPresenter refresh.
	self autoCommit: (autoCommit value == #failed ifTrue: [true] ifFalse: [autoCommit value])!

additionalAccelerators
	^super additionalAccelerators , #(#(#raiseConsole 'Ctrl+F7'))!

areBreakpointsEnabled
	^areBreakpointsEnabled!

auditProject
	projectListPresenter auditProject!

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

basicTransactionMode: aSymbol
	self parentPresenter transactionMode: aSymbol session: gciSession!

beginTransaction
	self parentPresenter beginTransaction!

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

committedTransaction
	self displayLastKnownCommitOrAbort!

commitTransaction
	^codePane commitTransaction.!

createComponents
	super createComponents.
	projectListPresenter := self add: JadeiteProjectListPresenter new name: 'Projects'.
	lastKnownTransaction := self add: TextPresenter new name: 'lastKnownTransaction'.
	lastKnownTransaction value: 'Last Known Commit or Abort: (unknown)'. 
	transactionModePresenter := self add: RadioButtonSetPresenter new name: 'transactionMode'.
	transactionModePresenter model: (self aspectValue: #transactionMode)!

createNewProject
	^projectListPresenter createNewProject!

createSchematicWiring
	super createSchematicWiring.
	self parentPresenter class
		when: #abortedTransaction
		send: #abortedTransaction
		to: self.
	self parentPresenter class
		when: #committedTransaction
		send: #committedTransaction
		to: self!

displayLastKnownCommitOrAbort
	| writeStream |
	writeStream := WriteStream on: String new.
	TimeStamp current printOn: writeStream format: 'M/d/yyyy h:mm:ss tt'.
	lastKnownTransaction value: 'Last Known Commit or Abort: ' , writeStream contents!

editComponents
	| projectName |
	projectName := projectListPresenter projectListPresenter selectionOrNil
				ifNil: [^self]
				ifNotNil: [:projectService | projectService name].
	^JadeiteComponentEditor showOn: projectName session: self gciSession!

editLoadSpecFromFile
	^JadeiteLoadSpecEditor editLoadSpecFromFileInSession: gciSession!

flipAutoCommit
	self parentPresenter flipAutoCommit!

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

gitCommit
	projectListPresenter gitCommit!

initialize
	super initialize.
	isTranscriptInstalled := ValueHolder with: true.
	areBreakpointsEnabled := ValueHolder with: true.
	autoCompleteEnabled := ValueHolder with: JadeiteSearch autoCompleteEnabled.
!

initializeTransactionModeSettings
	self transactionMode
		ifNil: 
			[self setTransactionModeFromServer	"should have already been set when window was created ... but just in case"]!

isBeginTransactionEnabled
	^self parentPresenter isBeginTransactionEnabled!

isCommitEnabled
	^self parentPresenter isCommitEnabled!

isTranscriptInstalled
	^isTranscriptInstalled value!

isTranscriptInstalledValueHolder
	^isTranscriptInstalled!

lastKnownTransaction
	^lastKnownTransaction!

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
			[self shouldAskToCommitOnLogout
				ifTrue: 
					[answer := MessageBox new
								caption: 'Close Requested';
								confirmOrCancel: 'Commit current transaction?'.
					boolValueHolder value: (#(#yes #no) includes: answer).
					answer = #yes ifTrue: [gciSession commit]]].
	boolValueHolder value ifFalse: [^self].
	allSessionsPresenter aboutToClose.
	gciSession notNil
		ifTrue: 
			[| temp |
			JadePresenter
				stopListeningForSigAborts;
				resetSigAbortProcessEnablement;
				resetSigAbortProcessInterval.
			gciSession trigger: #forceJadeiteWindowClose.	"close all windows except me and debugger"
			temp := gciSession.	"I'm getting closed so make sure session gets logged out"
			gciSession := nil.
			temp forceLogout]!

onViewClosed
	super onViewClosed.
	BrowserUpdate current logComment: 'Closing Transcript {' , self identityHash printString , '}'.
	BrowserUpdate current removeEventsTriggeredFor: self.
	BrowserUpdate current removeEventsTriggeredFor: projectListPresenter projectListPresenter.
	JadePresenter removeEventsTriggeredFor: self. 
	GciSession current: nil!

onViewOpened
	| answeringService installed breakPointsEnabled |
	super onViewOpened.
	self setRowanProjectsHomeIfNecessary: gciSession.
	self initializeTransactionModeSettings.	"should have already been set when window was created ... but just in case"
	projectListPresenter
		gciSession: gciSession;
		updateProjects.
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

queryCommand: aCommandQuery
	super queryCommand: aCommandQuery.
	aCommandQuery commandSymbol = #loadProjects
		ifTrue: 
			[aCommandQuery isEnabled: true.
			^true].
	aCommandQuery commandSymbol = #reloadProject
		ifTrue: 
			[aCommandQuery isEnabled: projectListPresenter projectListPresenter selections notEmpty.
			^true].
	aCommandQuery commandSymbol = #begin
		ifTrue: 
			[aCommandQuery isEnabled: self isBeginTransactionEnabled.
			^true].
	aCommandQuery commandSymbol = #commitTransaction
		ifTrue: 
			[aCommandQuery isEnabled: self isCommitEnabled.
			^true].
	aCommandQuery commandSymbol = #flipTranscript
		ifTrue: 
			[aCommandQuery isChecked: self isTranscriptInstalled.
			^true].
	aCommandQuery commandSymbol = #flipAutoCommit
		ifTrue: 
			[aCommandQuery
				isChecked: (GciSession current ifNil: [false] ifNotNil: [:session | session autoCommit == true]).
			^true].
	aCommandQuery commandSymbol = #flipDebugger
		ifTrue: 
			[aCommandQuery isChecked: JadeiteDebugger debuggerClass = JadeiteDebugger.
			^true].
	aCommandQuery commandSymbol = #flipLogging
		ifTrue: 
			[aCommandQuery isChecked: BrowserUpdate current isLogging.
			^true].
	aCommandQuery commandSymbol = #flipBreakpointsEnabled
		ifTrue: 
			[aCommandQuery isChecked: areBreakpointsEnabled value.
			^true].
	aCommandQuery commandSymbol = #flipAutocomplete
		ifTrue: 
			[aCommandQuery isChecked: autoCompleteEnabled value.
			^true]!

refreshFromServer
	projectListPresenter refreshFromServer!

registerPresentersForUpdates
	BrowserUpdate current
		register: self selector: #autoCommitUpdate:;
		register: self selector: #breakpointSettingChanged:;
		register: self selector: #updateSymbols:;
		register: projectListPresenter projectListPresenter selector: #projectsUpdate:;
		register: projectListPresenter projectListPresenter selector: #newProject:;
		register: self selector: #addCachedSymbols:!

reloadProject
	projectListPresenter reloadProject!

remoteAutoCommit
	| answeringService |
	answeringService := RowanAnsweringService new.
	answeringService
		command: #autoCommit;
		commandArgs: Array new.
	self issueCommand: answeringService.
	^answeringService answer!

resetTransactionModeRadioButtons
	#(#autoBegin #manualBegin #transactionless)
		do: [:aSymbol | (transactionModePresenter view viewNamed: aSymbol asString) displayValue: false].
	(transactionModePresenter view viewNamed: self transactionMode asString) displayValue: true!

setRowanProjectsHome
	self setRowanProjectsHome: gciSession!

setRowanProjectsHome: aGciSession
	| varString |
	varString := JadeiteServerFileSelectorDialog showOnSession: aGciSession
				defaultPath: JadePresenter homeEnvVarString.
	varString isNil ifTrue: [^MessageBox notify: '$ROWAN_PROJECTS_HOME was not set.'].
	aGciSession
		executeString: '(System gemEnvironmentVariable: ''ROWAN_PROJECTS_HOME'' put: ''' , varString , ''')'!

setRowanProjectsHomeIfNecessary: aGciSession
	| varSet shouldSet |
	varSet := aGciSession
				executeString: '(System gemEnvironmentVariable: ''ROWAN_PROJECTS_HOME'') notNil'.
	varSet ifTrue: [^self].
	shouldSet := MessageBox
				confirm: '$ROWAN_PROJECTS_HOME is not set. Would you like to set it? (Failure to do so will result in Jadeite errors)'.
	shouldSet ifFalse: [^self].
	self setRowanProjectsHome: aGciSession!

setTransactionModeFromServer
	"Only run this when opening the transcript.  We don't use the service mutex so it's mildly dangerous."
	self parentPresenter transactionMode: (gciSession executeString: 'System transactionMode').
	self resetTransactionModeRadioButtons.
	self parentPresenter inTransaction: (gciSession executeString: 'System inTransaction').
	self parentPresenter resetListeningForSigAborts: gciSession!

shouldAskToCommitOnLogout
	^self transactionMode = #autoBegin
		or: [self transactionMode = #manualBegin and: [self parentPresenter inTransaction]]!

toolbarPresenter
	^toolbarPresenter!

transactionMode
	^self parentPresenter transactionMode!

transactionMode: aSymbol
	"It seems Dolphin should have an event like 'aboutToChangeRadioButton' to avoid having to muck with the low level view"

	(MessageBox confirm: 'Switching transaction modes will cause an abort. Continue?')
		ifTrue: 
			[self basicTransactionMode: aSymbol.
			JadePresenter trigger: #abortedTransaction]
		ifFalse: [self resetTransactionModeRadioButtons]! !
!JadeiteTranscript categoriesForMethods!
abortedTransaction!public! !
abortTransaction!menu handlers!public! !
additionalAccelerators!public! !
areBreakpointsEnabled!accessing!private! !
auditProject!menu handlers!public! !
autoCommit!accessing!private! !
autoCommit:!accessing!private! !
autoCompleteEnabled!accessing!private! !
basicTransactionMode:!accessing!public!transaction mode! !
beginTransaction!menu handlers!public! !
browseBreakpointList!menu handlers!public! !
browseBreakpoints!menu handlers!public! !
browseClass!menu handlers!public! !
browseClassReferences!menu handlers!public! !
browseImplementorsOf!menu handlers!public! !
browseJadeiteLogs!menu handlers!public! !
browseJadeitePrefs!menu handlers!public! !
browseLiteralReferences!menu handlers!public! !
browseMethodsContaining!menu handlers!public! !
browseSendersOf!menu handlers!public! !
committedTransaction!event handling!public! !
commitTransaction!menu handlers!public! !
createComponents!initialization!public! !
createNewProject!menu handlers!public! !
createSchematicWiring!initialization!public! !
displayLastKnownCommitOrAbort!event handling!private! !
editComponents!menu handlers!public! !
editLoadSpecFromFile!menu handlers!public! !
flipAutoCommit!menu handlers!public! !
flipAutocomplete!menu handlers!public! !
flipBreakpointsEnabled!menu handlers!public! !
flipDebugger!menu handlers!public! !
flipLogging!menu handlers!public! !
flipTranscript!menu handlers!public! !
gciSession:!public! !
gitCommit!menu handlers!public! !
initialize!initialization!public! !
initializeTransactionModeSettings!initialization!public!transaction mode! !
isBeginTransactionEnabled!public!testing! !
isCommitEnabled!public!testing! !
isTranscriptInstalled!public! !
isTranscriptInstalledValueHolder!private! !
lastKnownTransaction!accessing!private! !
onCloseRequested:!event handling!public! !
onViewClosed!event handling!public! !
onViewOpened!event handling!public! !
openDictionaryBrowser!menu handlers!public! !
openGitHubJadeiteProject!event handling!menu handlers!public! !
openGitHubRowanProject!event handling!menu handlers!public! !
openJadeiteProjectsBrowser!menu handlers!public! !
projectListPresenter!accessing!public! !
queryCommand:!private! !
refreshFromServer!menu handlers!public! !
registerPresentersForUpdates!public!register presenters! !
reloadProject!menu handlers!public! !
remoteAutoCommit!accessing!private! !
resetTransactionModeRadioButtons!accessing!public!transaction mode! !
setRowanProjectsHome!menu handlers!public! !
setRowanProjectsHome:!actions!public! !
setRowanProjectsHomeIfNecessary:!actions!public! !
setTransactionModeFromServer!actions!public!transaction mode! !
shouldAskToCommitOnLogout!public!testing! !
toolbarPresenter!accessing!public! !
transactionMode!public! !
transactionMode:!public! !
!

!JadeiteTranscript class methodsFor!

defaultAdditionalAccelerators
	"Private - Even though this is specified in the context menu in JadeiteTranscript, the accelerator key is not recognized"

	^super defaultAdditionalAccelerators , #(#(#jadeExecute 'Ctrl+E'))!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1201 851 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 8 410 ##(Smalltalk.ReferenceView) 34 14 nil 416 34 2 8 1140850688 131073 592 nil nil nil 7 nil nil nil 592 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeToolsToolBarPresenter) #resource_Default_view nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 1 1 498 1169 51 592 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 25 0 0 0] 8 #() 498 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 946 #relativeParentWidth 3 946 #fixedParentTop 1 946 #fixedViewTop 51 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1140850688 131073 1024 nil 480 nil 7 nil nil nil 1024 656710 1 ##(Smalltalk.CardLayout) 138 144 34 7 721414 ##(Smalltalk.Association) 8 'Workspace' 410 ##(Smalltalk.ReferenceView) 34 14 nil 1024 34 2 8 1140850688 131073 1200 nil 480 nil 5 nil nil nil 1200 658 ##(Smalltalk.CodeSourcePresenter) #resource_Default_view nil 690 138 144 34 1 754 #createAt:extent: 34 2 498 9 53 498 1153 523 1200 834 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 68 2 0 0 31 1 0 0] 880 896 nil 27 1154 8 'My Session' 410 ##(Smalltalk.ReferenceView) 34 14 nil 1024 34 2 8 1140850688 131073 1456 nil nil nil 5 nil nil nil 1456 658 ##(Smalltalk.MySessionPresenter) #resource_Default_view nil 690 138 144 34 1 754 #createAt:extent: 34 2 498 9 53 498 1153 523 1456 834 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 68 2 0 0 31 1 0 0] 880 896 nil 27 1154 8 'All Sessions' 410 ##(Smalltalk.ReferenceView) 34 14 nil 1024 34 2 8 1140850688 131073 1712 nil nil nil 5 nil nil nil 1712 658 ##(Smalltalk.AllSessionsPresenter) #resource_Default_view nil 690 138 144 34 1 754 #createAt:extent: 34 2 498 9 53 498 1153 523 1712 834 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 68 2 0 0 31 1 0 0] 880 896 nil 27 1154 8 'Transcript' 410 ##(Smalltalk.ReferenceView) 34 14 nil 1024 34 2 8 1140916224 131073 1968 nil 480 nil 5 nil nil nil 1968 658 ##(Smalltalk.TranscriptPresenter) #resource_Default_view nil 690 138 144 34 1 754 #createAt:extent: 34 2 498 9 53 498 1153 523 1968 834 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 68 2 0 0 31 1 0 0] 880 896 nil 27 1154 8 'History' 410 ##(Smalltalk.MultilineTextEdit) 34 16 nil 1024 34 2 8 1143017796 1025 2224 nil 480 nil 5 nil nil nil 2224 nil 8 1582640560 852486 ##(Smalltalk.NullConverter) nil nil 11 690 138 144 34 1 754 #createAt:extent: 34 2 498 9 53 498 1153 523 2224 834 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 68 2 0 0 31 1 0 0] 8 #() 896 nil 27 1154 ##(Smalltalk.Stone) 410 ##(Smalltalk.ReferenceView) 34 14 nil 1024 34 2 8 1140850688 131073 2512 nil nil nil 5 nil nil nil 2512 658 ##(Smalltalk.StoneInfoPresenter) #resource_Default_view nil 690 138 144 34 1 754 #createAt:extent: 34 2 498 9 53 498 1153 523 2512 834 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 68 2 0 0 31 1 0 0] 880 896 nil 27 1154 8 'Projects' 410 ##(Smalltalk.ShellView) 34 27 nil 1024 34 2 8 1078919168 131073 2768 nil 480 498 1201 801 551 265030 4 ##(Smalltalk.Menu) nil true 34 18 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #makeDefault 8 'Make Default' 1 1 nil nil nil 2898 1 2930 #browseProject 8 'Browse' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 2898 1 2930 #cloneProject 8 'Clone Git Project ...' 1 1 nil nil nil 2898 1 2930 #loadProjects 8 'Load' 1 1 nil nil nil 2898 1 2930 #unloadProjects 8 'Unload' 1 1 nil nil nil 3026 4097 2898 1 2930 #pullFromGit 8 'Pull from Git' 1 1 nil nil nil 2898 1 2930 #gitCommit 8 'Commit to Git ...' 1 1 nil nil nil 2898 1 2930 #pushToGit 8 'Push to Git' 1 1 nil nil nil 3026 4097 2898 1 2930 #projectChanges 8 'Changes' 1 1 nil nil nil 2898 1 2930 #writeProject 8 'Write' 1 1 nil nil nil 2898 1 2930 #checkout 8 'Checkout Git Branch ...' 1 1 nil nil nil 3026 4097 2898 1 2930 #projectLog 8 'Git Log' 1 1 nil nil nil 2898 1 2930 #openCommitInGitHub 8 'Browse Commit In GitHub' 1 1 nil nil nil 2898 1 2930 #refresh 8 'Refresh' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 2768 1180166 ##(Smalltalk.ProportionalLayout) 170 176 880 false 170 192 34 2 410 ##(Smalltalk.ListView) 34 45 nil 2768 34 2 8 1140920649 1025 3776 590662 2 ##(Smalltalk.ListModel) 138 144 880 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 nil nil nil 3776 nil 8 1582584032 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 3 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Project Name' 371 #left 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.SortedCollection) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 4096 8 'doIt' 8 '[:project | project displayName]' 8 #[30 105 226 0 106] #displayName 4112 7 257 nil nil 3776 nil 3 nil 4098 0 nil 4130 3 1 4096 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 4208 7 257 nil false nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 4304 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 4304 nil nil 2306 nil 8 '' 3 nil nil nil nil nil nil nil nil nil 4002 8 'Loaded Sha' 373 #left 4050 #displayString 8 #() 4050 #<= 4480 4098 0 nil 4130 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:project | project sha]' 8 #[30 105 226 0 106] #sha 4512 7 257 nil nil 3776 nil 3 nil nil false nil 4290 nil nil 8 #(67174528 0) 4592 4338 nil false 4384 nil 480 nil 5 nil nil nil 4592 nil nil 2306 nil 8 '' 3 nil nil nil nil nil nil nil nil nil 4002 8 'Branch' 371 #left 4050 #displayString 4480 4050 #<= 4480 4098 0 nil 4130 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:project | project branch]' 8 #[30 105 226 0 106] #branch 4736 7 257 nil nil 3776 nil 3 nil nil false nil 4290 nil nil 8 #(67174528 0) 4816 4338 nil false 4384 nil 480 nil 5 nil nil nil 4816 nil nil 2306 nil 8 '' 3 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 498 129 129 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 690 138 144 34 2 754 #createAt:extent: 34 2 498 1 1 498 1121 491 3776 754 #text: 34 1 8 'Project Name' 3776 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 48 2 0 0 245 0 0 0] 8 #() 896 nil 35 8 'projectList' nil nil nil nil nil 1 nil nil nil nil 1 nil nil 690 138 144 34 3 754 #createAt:extent: 34 2 498 9 53 498 1153 523 2768 754 #contextMenu: 34 1 2864 2768 754 #text: 34 1 8 'Rowan Project List' 2768 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 68 2 0 0 31 1 0 0] 34 1 3776 896 nil 27 2768 nil nil nil 170 192 34 14 1968 8 'Transcript' 2768 8 'projectsList' 2512 8 'Stone' 1712 8 'All Sessions' 2224 8 'history' 1456 8 'My Session' 1200 8 'codePane' nil 410 ##(Smalltalk.TabView) 34 23 nil 1024 34 2 8 1140916736 1 5536 3842 138 144 34 7 1952 2208 ##(Smalltalk.Stone) 1440 1696 1184 2752 nil 3904 466 #face3d nil 1 nil nil nil 5536 nil 8 1582354176 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 3952 nil nil nil nil nil #noIcons 690 138 144 34 3 754 #createAt:extent: 34 2 498 1 1 498 1169 583 5536 754 #setSingleSelection: 8 #(7) 5536 754 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 5536 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 35 1 0 0] 8 #() 896 nil 27 690 138 144 34 1 754 #createAt:extent: 34 2 498 1 51 498 1169 583 1024 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 72 2 0 0 60 1 0 0] 34 8 1968 2224 2512 1456 1712 1200 2768 5536 896 nil 27 914 960 1 946 #fixedParentRight 1 992 51 946 #fixedParentBottom -99 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 6112 nil 480 nil 7 nil nil nil 6112 530 170 176 34 2 410 ##(Smalltalk.StaticText) 34 16 nil 6112 34 2 8 1140855041 262209 6224 nil 480 nil 7 nil nil nil 6224 196934 1 ##(Smalltalk.RGB) 10921639 8 1582496960 2306 nil nil nil 690 138 144 34 2 754 #createAt:extent: 34 2 498 1 1 498 1169 51 6224 754 #text: 34 1 8 'Static Text' 6224 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 25 0 0 0] 8 #() 896 nil 27 914 960 1 6080 1 6096 -49 6096 1 170 192 34 2 6224 8 'lastKnownTransaction' 590342 ##(Smalltalk.Rectangle) 498 1 1 498 1 1 690 138 144 34 1 754 #createAt:extent: 34 2 498 1 683 498 1169 51 6112 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 85 1 0 0 72 2 0 0 110 1 0 0] 34 1 6224 896 nil 27 914 960 1 6080 1 6096 -49 6096 1 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140916224 132097 6864 nil 480 nil 7 nil nil nil 6864 530 170 176 34 8 410 ##(Smalltalk.RadioButton) 34 16 nil 6864 34 2 8 1141058825 1 6976 4338 nil nil 1376774 ##(Smalltalk.PluggableSearchPolicy) 4050 #= 8 #() 4050 #hash 8 #() false 480 nil 7 nil nil nil 6976 nil 8 1582648752 2306 nil nil nil 690 138 144 34 2 754 #createAt:extent: 34 2 498 383 3 498 199 41 6976 754 #text: 34 1 8 'Auto' 6976 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 191 0 0 0 1 0 0 0 34 1 0 0 21 0 0 0] 8 #() 896 nil 27 914 976 327734 ##(Smalltalk.Float) 8 31 133 235 81 184 30 213 63 976 7410 8 0 0 0 0 0 0 224 63 6096 -39 6096 1 410 ##(Smalltalk.RadioButton) 34 16 nil 6864 34 2 8 1141058825 1 7456 4338 nil nil 7058 4050 #= 8 #() 4050 #hash 8 #() false 480 nil 7 nil nil nil 7456 nil 8 1582648752 2306 nil nil nil 690 138 144 34 2 754 #createAt:extent: 34 2 498 581 3 498 233 41 7456 754 #text: 34 1 8 'Manual' 7456 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 34 1 0 0 1 0 0 0 150 1 0 0 21 0 0 0] 8 #() 896 nil 27 914 976 7410 8 0 0 0 0 0 0 224 63 976 7410 8 102 102 102 102 102 102 230 63 6096 -39 6096 1 410 ##(Smalltalk.StaticText) 34 16 nil 6864 34 2 8 1140850945 65 7904 nil 480 nil 7 nil nil nil 7904 nil 8 1582496960 2306 nil nil nil 690 138 144 34 2 754 #createAt:extent: 34 2 498 1 3 498 383 41 7904 754 #text: 34 1 8 'Transaction Mode:
Transaction Mode:' 7904 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 1 0 0 0 191 0 0 0 21 0 0 0] 8 #() 896 nil 27 914 976 1 976 7410 8 31 133 235 81 184 30 213 63 6096 -39 6096 1 410 ##(Smalltalk.RadioButton) 34 16 nil 6864 34 2 8 1141058825 1 8240 4338 nil nil 7058 4050 #= 8 #() 4050 #hash 8 #() false 480 nil 7 nil nil nil 8240 nil 8 1582648752 2306 nil nil nil 690 138 144 34 2 754 #createAt:extent: 34 2 498 813 3 498 349 41 8240 754 #text: 34 1 8 'Transactionless' 8240 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 150 1 0 0 1 0 0 0 68 2 0 0 21 0 0 0] 8 #() 896 nil 27 914 976 7410 8 102 102 102 102 102 102 230 63 976 3 6096 -39 6096 1 170 192 34 6 7456 8 'manualBegin' 6976 8 'autoBegin' 8240 8 'transactionless' nil 690 138 144 34 1 754 #createAt:extent: 34 2 498 1 633 498 1169 51 6864 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 60 1 0 0 72 2 0 0 85 1 0 0] 34 4 7904 6976 7456 8240 896 nil 27 914 960 1 6080 1 6096 -99 6096 -49 170 192 34 6 592 8 'Toolbar' 1024 8 'cardContainer' 6864 8 'transactionMode' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 5 2850 nil true 34 9 2898 1 2930 #fileNew 8 '&New Workspace' 9373 1 nil nil nil 2898 1 2930 #fileOpen 8 '&Open Workspace...' 9375 1 nil nil nil 2898 1 2930 #fileSave 8 '&Save' 9383 1 nil nil nil 2898 1 2930 #fileSaveAs 8 'Save &As...' 1 1 nil nil nil 2898 1 2930 #fileRevert 8 '&Revert' 1025 1 nil nil nil 3026 4097 2898 1 2930 #resetCursor 8 'Reset &Cursor' 1025 1 nil nil nil 3026 4097 2898 1 2930 #exit 8 'E&xit Jadeite' 17639 1 nil nil nil 8 '&File' nil 1 nil nil 37779 nil nil 2850 nil true 34 22 2898 1 2930 #undo 8 '&Undo' 9397 1 nil nil nil 2898 1 2930 #redo 8 'R&edo' 9395 1 nil nil nil 3026 4097 2898 1 2930 #editCut 8 'Cu&t' 9393 1 nil nil nil 2898 1 2930 #editCopy 8 '&Copy' 9351 1 nil nil nil 2898 1 2930 #editPaste 8 '&Paste' 9389 1 nil nil nil 2898 1 2930 #editDelete 8 '&Delete' 1629 1 nil nil nil 3026 4097 2898 1 2930 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 3026 4097 2898 1 2930 #editFind 8 '&Find...' 9357 1 nil nil nil 2898 1 2930 #editFindNext 8 'Find &Next' 1253 1 nil nil nil 2898 1 2930 #editReplace 8 '&Replace...' 9361 1 nil nil nil 3026 4097 2898 1 2930 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 2898 1 2930 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 2898 1 2930 #jadeExecute 8 '&Execute' 9355 1 nil nil nil 2898 1 2930 #jadeDebug 8 'Debug' 9349 1 nil nil nil 2898 1 2930 #fileIn 8 'Fi&le In' 1 1 nil nil nil 3026 4097 2898 1 2930 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 2898 1 2930 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 8 '&Edit' nil 1 nil nil 37815 nil nil 2850 nil true 34 14 2898 1 2930 #abortTransaction 8 '&Abort Transaction' 1 1 nil nil nil 2898 1 2930 #commitTransaction 8 '&Commit Transaction' 1 1 nil nil nil 2898 1 2930 #begin 8 'Begin Transaction' 1 1 nil nil nil 2898 1 2930 #disableNativeCode 8 'Disable Native Code' 1 1 nil nil nil 3026 4097 2898 1 2930 #inspectOop 8 'Inspect Oop ...' 1 1 nil nil nil 2898 1 2930 #describeErrorNumber 8 'Description for Error Number ...' 1025 1 nil nil nil 2898 1 2930 #setRowanProjectsHome 8 'Set Rowan Projects Home ...' 1 1 nil nil nil 3026 4097 2898 1025 2930 #flipTranscript 8 'Transcript writes enabled' 1025 1 nil nil nil 2898 1025 2930 #flipAutoCommit 8 'AutoCommit enabled' 1025 1 nil nil nil 2898 1025 2930 #flipBreakpointsEnabled 8 'Breakpoints enabled' 1025 1 nil nil nil 2898 1025 2930 #flipAutocomplete 8 'Autocomplete enabled' 1025 1 nil nil nil 2898 1025 2930 #flipLogging 8 'Logging Enabled' 1025 1 nil nil nil 8 '&Jadeite' nil 1 nil nil 37841 nil nil 2850 nil true 34 14 2898 1 2930 #openJadeiteProjectsBrowser 8 'Browse &Projects' 9377 1 nil nil nil 2898 1 2930 #browseProcesses 8 'Browse P&rocesses' 9381 1 nil nil nil 2898 1 2930 #jadeBrowseTests 8 'Browse SUnit &Tests' 1 1 nil nil nil 3026 4097 2898 1 2930 #browseClass 8 'Find Class ...' 13453 1 nil nil nil 2898 1 2930 #browseClassReferences 8 'Browse &Class References ...' 13447 1 nil nil nil 2898 1 2930 #browseImplementorsOf 8 'Browse &Implementors of ...' 13459 1 nil nil nil 2898 1 2930 #browseSendersOf 8 'Browse &Senders of ...' 13479 1 nil nil nil 2898 1 2930 #browseMethodsContaining 8 'Browse &Methods Containing ...' 1 1 nil nil nil 2898 1 2930 #browseLiteralReferences 8 'Browse &Literal References ...' 1 1 nil nil nil 2898 1 2930 #browseBreakpoints nil 1 1 nil nil nil 3026 4097 2898 1025 2930 #browseJadeiteLogs 8 'Browse Logs' 1025 1 nil nil nil 2898 1025 2930 #browseJadeitePrefs 8 'Browse Preferences File' 1025 1 nil nil nil 8 '&Browse' nil 134217729 nil nil 37867 nil nil 2850 nil true 34 4 2898 1 2930 #openGitHubJadeiteProject 8 '&Jadiete GitHub Project' 1025 1 nil nil nil 2898 1 2930 #openGitHubRowanProject 8 '&Rowan GitHub Project' 1025 1 nil nil nil 3026 4097 2898 1 2930 #aboutJadeite 8 '&About Jadeite' 1 1 nil nil nil 8 '&Help' nil 1 nil nil 37875 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons\GS32.ico' nil 11938 nil true 11984 8 'icons\GS16.ico' nil nil nil 1 nil nil 690 138 144 34 2 754 #createAt:extent: 34 2 498 6683 21 498 1201 851 416 754 #text: 34 1 8 'Jadeite Session' 416 834 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 13 13 0 0 10 0 0 0 101 15 0 0 179 1 0 0] 34 4 592 1024 6864 6112 896 nil 27 )!

showOnSession: aGciSession
	| theTranscript |
	theTranscript := super showOnSession: aGciSession.
	theTranscript setTransactionModeFromServer.
	^theTranscript! !
!JadeiteTranscript class categoriesForMethods!
defaultAdditionalAccelerators!public! !
resource_Default_view!public!resources-views! !
showOnSession:!instance creation!public! !
!

