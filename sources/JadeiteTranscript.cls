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
	self displayLastKnownCommitOrAbort!

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

browseBreakpointList
	^JadePresenter browseBreakpointsIn: self gciSession!

basicTransactionMode: aSymbol
	self parentPresenter transactionMode: aSymbol session: gciSession!

beginTransaction
	self parentPresenter beginTransaction!

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
	projectListPresenter createNewProject!

editComponents
	| projectName |
	projectName := projectListPresenter projectListPresenter selectionOrNil
				ifNil: [^self]
				ifNotNil: [:projectService | projectService name].
	^JadeiteComponentEditor showOn: projectName session: self gciSession!

editLoadSpecFromFile
	^JadeiteLoadSpecEditor editLoadSpecFromFileInSession: gciSession!

flipAutoCommit
	| browserService |
	browserService := RowanAutoCommitService new.
	browserService
		command: #flipAutoCommit;
		commandArgs: Array new.
	self issueCommand: browserService!

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
	Timestamp now
		printOn: writeStream
		timeFormat: Locale default timeFormat
		dateFormat: Locale default dateFormat.
	lastKnownTransaction value: 'Last Known Commit or Abort: ' , writeStream contents!

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

getTransactionModeFromServer
	"Only run this when opening the transcript.  We don't use the service mutex and don't want to get our server execution mixed up"

	transactionMode := gciSession executeString: 'System transactionMode'!

initialize
	super initialize.
	isTranscriptInstalled := ValueHolder with: true.
	areBreakpointsEnabled := ValueHolder with: true.
	autoCompleteEnabled := ValueHolder with: JadeiteSearch autoCompleteEnabled.
	transactionMode 
		ifNil: [transactionMode := #autoBegin    "should have already been set when window was created"]
!

initializeTransactionModeSettings
	self transactionMode
		ifNil: 
			[self basicTransactionMode: #autoBegin	"should have already been set when window was created ... but just in case"].
	!

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
	self autoCommit: (RowanAnsweringService new autoCommitIn: self gciSession).
	!

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
			[query
				isChecked: (GciSession current ifNil: [false] ifNotNil: [:session | session autoCommit == true]).
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

setTransactionModeFromServer
	"Only run this when opening the transcript.  We don't use the service mutex so it's mildly dangerous."
	self parentPresenter transactionMode: (gciSession executeString: 'System transactionMode').
	self resetTransactionModeRadioButtons.
	self parentPresenter inTransaction: (gciSession executeString: 'System inTransaction')!

shouldAskToCommitOnLogout
	^self transactionMode = #autoBegin
		or: [self transactionMode = #manualBegin and: [self parentPresenter inTransaction]]!

toolbarPresenter
	^toolbarPresenter! !
!JadeiteTranscript categoriesForMethods!
abortTransaction!menu handlers!public! !
additionalAccelerators!public! !
areBreakpointsEnabled!accessing!private! !
auditProject!menu handlers!public! !
autoCommit!accessing!private! !
autoCommit:!accessing!private! !
autoCompleteEnabled!accessing!private! !
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
commitTransaction!menu handlers!public! !
createComponents!public! !
createNewProject!menu handlers!public! !
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
isTranscriptInstalled!public! !
isTranscriptInstalledValueHolder!private! !
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
toolbarPresenter!accessing!public! !
!

transactionMode
	^self parentPresenter transactionMode!

transactionMode: aSymbol
	"It seems Dolphin should have an event like 'aboutToChangeRadioButton' to avoid having to muck with the low level view"

	(MessageBox confirm: 'Switching transaction modes will cause an abort. Continue?')
		ifTrue: 
			[self basicTransactionMode: aSymbol.
			JadePresenter trigger: #abortedTransaction]
		ifFalse: [self resetTransactionModeRadioButtons]! !
!JadeiteTranscript categoriesFor: #abortedTransaction!event handling!public! !
!JadeiteTranscript categoriesFor: #abortTransaction!menu handlers!public! !
!JadeiteTranscript categoriesFor: #additionalAccelerators!public! !
!JadeiteTranscript categoriesFor: #areBreakpointsEnabled!accessing!private! !
!JadeiteTranscript categoriesFor: #autoCommit!accessing!private! !
!JadeiteTranscript categoriesFor: #autoCommit:!accessing!private! !
!JadeiteTranscript categoriesFor: #autoCompleteEnabled!accessing!private! !
!JadeiteTranscript categoriesFor: #autoCompleteEnabled:!accessing!private! !
!JadeiteTranscript categoriesFor: #basicTransactionMode:!accessing!public!transaction mode! !
!JadeiteTranscript categoriesFor: #beginTransaction!menu handlers!public! !
!JadeiteTranscript categoriesFor: #browseBreakpoints!menu handlers!public! !
!JadeiteTranscript categoriesFor: #browseClass!menu handlers!public! !
!JadeiteTranscript categoriesFor: #browseClassReferences!menu handlers!public! !
!JadeiteTranscript categoriesFor: #browseImplementorsOf!menu handlers!public! !
!JadeiteTranscript categoriesFor: #browseJadeiteLogs!menu handlers!public! !
!JadeiteTranscript categoriesFor: #browseJadeitePrefs!menu handlers!public! !
!JadeiteTranscript categoriesFor: #browseLiteralReferences!menu handlers!public! !
!JadeiteTranscript categoriesFor: #browseMethodsContaining!menu handlers!public! !
!JadeiteTranscript categoriesFor: #browseSendersOf!menu handlers!public! !
!JadeiteTranscript categoriesFor: #committedTransaction!event handling!public! !
!JadeiteTranscript categoriesFor: #commitTransaction!menu handlers!public! !
!JadeiteTranscript categoriesFor: #createComponents!initialization!public! !
!JadeiteTranscript categoriesFor: #createSchematicWiring!initialization!public! !
!JadeiteTranscript categoriesFor: #displayLastKnownCommitOrAbort!event handling!private! !
!JadeiteTranscript categoriesFor: #flipAutoCommit!menu handlers!public! !
!JadeiteTranscript categoriesFor: #flipAutocomplete!menu handlers!public! !
!JadeiteTranscript categoriesFor: #flipBreakpointsEnabled!menu handlers!public! !
!JadeiteTranscript categoriesFor: #flipDebugger!menu handlers!public! !
!JadeiteTranscript categoriesFor: #flipLogging!menu handlers!public! !
!JadeiteTranscript categoriesFor: #flipTranscript!menu handlers!public! !
!JadeiteTranscript categoriesFor: #gciSession:!public! !
!JadeiteTranscript categoriesFor: #initialize!initialization!public! !
!JadeiteTranscript categoriesFor: #initializeTransactionModeSettings!initialization!public!transaction mode! !
!JadeiteTranscript categoriesFor: #isTranscriptInstalled!public! !
!JadeiteTranscript categoriesFor: #isTranscriptInstalledValueHolder!private! !
!JadeiteTranscript categoriesFor: #lastKnownTransaction!accessing!private! !
!JadeiteTranscript categoriesFor: #onCloseRequested:!event handling!public! !
!JadeiteTranscript categoriesFor: #onViewClosed!event handling!public! !
!JadeiteTranscript categoriesFor: #onViewOpened!event handling!public! !
!JadeiteTranscript categoriesFor: #openCommitInGitHub!menu handlers!public! !
!JadeiteTranscript categoriesFor: #openDictionaryBrowser!menu handlers!public! !
!JadeiteTranscript categoriesFor: #openGitHubJadeiteProject!event handling!menu handlers!public! !
!JadeiteTranscript categoriesFor: #openGitHubRowanProject!event handling!menu handlers!public! !
!JadeiteTranscript categoriesFor: #openJadeiteProjectsBrowser!menu handlers!public! !
!JadeiteTranscript categoriesFor: #projectListPresenter!accessing!public! !
!JadeiteTranscript categoriesFor: #queryCommand:!private! !
!JadeiteTranscript categoriesFor: #registerPresentersForUpdates!public!register presenters! !
!JadeiteTranscript categoriesFor: #remoteAutoCommit!accessing!private! !
!JadeiteTranscript categoriesFor: #resetTransactionModeRadioButtons!accessing!public!transaction mode! !
!JadeiteTranscript categoriesFor: #setTransactionModeFromServer!actions!public!transaction mode! !
!JadeiteTranscript categoriesFor: #shouldAskToCommitOnLogout!public!testing! !
!JadeiteTranscript categoriesFor: #toolbarPresenter!accessing!public! !
!JadeiteTranscript categoriesFor: #transactionMode!accessing!public!transaction mode! !
!JadeiteTranscript categoriesFor: #transactionMode:!accessing!public!transaction mode! !

!JadeiteTranscript class methodsFor!

defaultAdditionalAccelerators
	"Private - Even though this is specified in the context menu in JadeiteTranscript, the accelerator key is not recognized"

	^super defaultAdditionalAccelerators , #(#(#editComponents 'Ctrl+E'))!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"


	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 1201 851 551 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 8 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1140850688 131073 608 nil 466 496 nil 7 nil nil nil 608 655878 ##(Smalltalk.CardLayout) 138 144 34 7 721414 ##(Smalltalk.Association) 8 'Workspace' 410 ##(Smalltalk.ReferenceView) 34 14 nil 608 34 2 8 1140850688 131073 800 nil 466 8 4278190080 nil 5 nil nil nil 800 1180166 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.CodeSourcePresenter) #resource_Default_view nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 9 55 514 1153 521 800 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 31 1 0 0] 8 #() 514 193 193 nil 27 754 8 'My Session' 410 ##(Smalltalk.ReferenceView) 34 14 nil 608 34 2 8 1140850688 131073 1184 nil nil nil 5 nil nil nil 1184 898 ##(Smalltalk.MySessionPresenter) #resource_Default_view nil 930 138 144 34 1 994 #createAt:extent: 34 2 514 9 55 514 1153 521 1184 1074 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 31 1 0 0] 1120 1136 nil 27 754 8 'All Sessions' 410 ##(Smalltalk.ReferenceView) 34 14 nil 608 34 2 8 1140850688 131073 1440 nil nil nil 5 nil nil nil 1440 898 ##(Smalltalk.AllSessionsPresenter) #resource_Default_view nil 930 138 144 34 1 994 #createAt:extent: 34 2 514 9 55 514 1153 521 1440 1074 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 31 1 0 0] 1120 1136 nil 27 754 8 'Transcript' 410 ##(Smalltalk.ReferenceView) 34 14 nil 608 34 2 8 1140916224 131073 1696 nil 466 8 4278190080 nil 5 nil nil nil 1696 898 ##(Smalltalk.TranscriptPresenter) #resource_Default_view nil 930 138 144 34 1 994 #createAt:extent: 34 2 514 9 55 514 1153 521 1696 1074 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 31 1 0 0] 1120 1136 nil 27 754 8 'History' 410 ##(Smalltalk.MultilineTextEdit) 34 16 nil 608 34 2 8 1143017796 1025 1984 nil 466 8 4278190080 nil 5 nil nil nil 1984 nil 8 4294904437 852486 ##(Smalltalk.NullConverter) nil nil 11 930 138 144 34 1 994 #createAt:extent: 34 2 514 9 55 514 1153 521 1984 1074 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 31 1 0 0] 8 #() 1136 nil 27 754 ##(Smalltalk.Stone) 410 ##(Smalltalk.ReferenceView) 34 14 nil 608 34 2 8 1140850688 131073 2304 nil nil nil 5 nil nil nil 2304 898 ##(Smalltalk.StoneInfoPresenter) #resource_Default_view nil 930 138 144 34 1 994 #createAt:extent: 34 2 514 9 55 514 1153 521 2304 1074 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 31 1 0 0] 1120 1136 nil 27 754 8 'Projects' 410 ##(Smalltalk.ShellView) 34 27 nil 608 34 2 8 1078919168 131073 2560 nil 466 8 4278190080 514 1201 801 551 265030 4 ##(Smalltalk.Menu) nil true 34 18 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #makeDefault 8 'Make Default' 1 1 nil nil nil 2722 1 2754 #browseProject 8 'Browse' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 2722 1 2754 #cloneProject 8 'Clone Git Project ...' 1 1 nil nil nil 2722 1 2754 #loadProjects 8 'Load' 1 1 nil nil nil 2722 1 2754 #unloadProjects 8 'Unload' 1 1 nil nil nil 2850 4097 2722 1 2754 #pullFromGit 8 'Pull from Git' 1 1 nil nil nil 2722 1 2754 #gitCommit 8 'Commit to Git ...' 1 1 nil nil nil 2722 1 2754 #pushToGit 8 'Push to Git' 1 1 nil nil nil 2850 4097 2722 1 2754 #projectChanges 8 'Changes' 1 1 nil nil nil 2722 1 2754 #writeProject 8 'Write' 1 1 nil nil nil 2722 1 2754 #checkout 8 'Checkout Git Branch ...' 1 1 nil nil nil 2850 4097 2722 1 2754 #projectLog 8 'Git Log' 1 1 nil nil nil 2722 1 2754 #openCommitInGitHub 8 'Browse Commit In GitHub' 1 1 nil nil nil 2722 1 2754 #refresh 8 'Refresh' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 2560 1180166 ##(Smalltalk.ProportionalLayout) 170 176 1120 false 170 192 34 2 410 ##(Smalltalk.ListView) 34 30 nil 2560 34 2 8 1140920649 1025 3600 590662 2 ##(Smalltalk.ListModel) 138 144 1120 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 466 8 4278190080 nil 7 nil nil nil 3600 nil 8 4294912595 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 3 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Project Name' 371 #left 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.SortedCollection) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 3952 8 'doIt' 8 '[:project | project displayName]' 8 #[30 105 226 0 106] #displayName 3968 7 257 nil nil 3600 nil 3 nil 3954 0 nil 3986 3 1 3952 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 4064 7 257 nil false nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 4160 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 4160 nil nil 2098 nil 8 '' 3 nil nil nil nil nil nil nil nil nil 3858 8 'Loaded Sha' 373 #left 3906 #displayString 8 #() 3906 #<= 4336 3954 0 nil 3986 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:project | project sha]' 8 #[30 105 226 0 106] #sha 4368 7 257 nil nil 3600 nil 3 nil nil false nil 4146 nil nil 8 #(67174528 0) 4448 4194 nil false 4240 nil 466 8 4278190080 nil 5 nil nil nil 4448 nil nil 2098 nil 8 '' 3 nil nil nil nil nil nil nil nil nil 3858 8 'Branch' 371 #left 3906 #displayString 4336 3906 #<= 4336 3954 0 nil 3986 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:project | project branch]' 8 #[30 105 226 0 106] #branch 4624 7 257 nil nil 3600 nil 3 nil nil false nil 4146 nil nil 8 #(67174528 0) 4704 4194 nil false 4240 nil 466 4512 nil 5 nil nil nil 4704 nil nil 2098 nil 8 '' 3 nil nil nil nil nil nil nil nil nil #report 1120 nil 131171 514 129 129 34 4 nil nil 514 1 1 nil 930 138 144 34 2 994 #createAt:extent: 34 2 514 1 1 514 1121 489 3600 994 #text: 34 1 8 'Project Name' 3600 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 48 2 0 0 244 0 0 0] 8 #() 1136 nil 27 8 'projectList' nil nil nil nil nil 1 nil nil nil nil 1 nil nil 930 138 144 34 4 994 #createAt:extent: 34 2 514 9 55 514 1153 521 2560 994 #contextMenu: 34 1 2688 2560 994 #text: 34 1 8 'Rowan Project List' 2560 994 #updateMenuBar 1120 2560 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 31 1 0 0] 34 1 3600 1136 nil 27 2560 170 192 34 14 2560 8 'projectsList' 1696 8 'Transcript' 1184 8 'My Session' 1984 8 'history' 1440 8 'All Sessions' 800 8 'codePane' 2304 8 'Stone' nil 410 ##(Smalltalk.TabView) 34 23 nil 608 34 2 8 1140916736 1 5472 3666 138 144 34 7 1680 1968 ##(Smalltalk.Stone) 1168 1424 784 2544 nil 3728 721158 ##(Smalltalk.SystemColor) 31 nil 1 nil nil nil 5472 nil 8 4294910233 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 3808 nil nil nil nil nil #noIcons 930 138 144 34 3 994 #createAt:extent: 34 2 514 1 1 514 1169 583 5472 994 #basicSelectionsByIndex: 34 1 8 #(7) 5472 994 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 5472 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 35 1 0 0] 8 #() 1136 nil 27 930 138 144 34 1 994 #createAt:extent: 34 2 514 1 51 514 1169 583 608 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 72 2 0 0 60 1 0 0] 34 8 1696 1984 2304 1184 1440 800 2560 5472 1136 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 6066 #fixedParentRight 1 6066 #fixedParentTop 51 6066 #fixedParentBottom -99 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140916224 132097 6144 nil 466 8 4278190080 nil 7 nil nil nil 6144 546 170 176 34 8 410 ##(Smalltalk.StaticText) 34 16 nil 6144 34 2 8 1140850945 65 6288 nil 466 8 4278190080 nil 7 nil nil nil 6288 nil 8 1714981536 2098 nil nil nil 930 138 144 34 2 994 #createAt:extent: 34 2 514 1 3 514 383 41 6288 994 #text: 34 1 8 'Transaction Mode:
Transaction Mode:' 6288 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 1 0 0 0 191 0 0 0 21 0 0 0] 8 #() 1136 nil 27 6034 6066 #relativeParentWidth 1 6640 327734 ##(Smalltalk.Float) 8 31 133 235 81 184 30 213 63 6128 -39 6128 1 410 ##(Smalltalk.RadioButton) 34 16 nil 6144 34 2 8 1141058825 1 6688 4194 nil nil 1376774 ##(Smalltalk.PluggableSearchPolicy) 3906 #= 8 #() 3906 #hash 8 #() false 466 8 4278190080 nil 7 nil nil nil 6688 nil 8 4294911827 2098 nil nil nil 930 138 144 34 2 994 #createAt:extent: 34 2 514 581 3 514 233 41 6688 994 #text: 34 1 8 'Manual' 6688 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 34 1 0 0 1 0 0 0 150 1 0 0 21 0 0 0] 8 #() 1136 nil 27 6034 6640 6658 8 0 0 0 0 0 0 224 63 6640 6658 8 102 102 102 102 102 102 230 63 6128 -39 6128 1 410 ##(Smalltalk.RadioButton) 34 16 nil 6144 34 2 8 1141058825 1 7184 4194 nil nil 6770 3906 #= 8 #() 3906 #hash 8 #() false 466 8 4278190080 nil 7 nil nil nil 7184 nil 8 4294911827 2098 nil nil nil 930 138 144 34 2 994 #createAt:extent: 34 2 514 813 3 514 349 41 7184 994 #text: 34 1 8 'Transactionless' 7184 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 150 1 0 0 1 0 0 0 68 2 0 0 21 0 0 0] 8 #() 1136 nil 27 6034 6640 6658 8 102 102 102 102 102 102 230 63 6640 3 6128 -39 6128 1 410 ##(Smalltalk.RadioButton) 34 16 nil 6144 34 2 8 1141058825 1 7648 4194 nil nil 6770 3906 #= 8 #() 3906 #hash 8 #() false 466 8 4278190080 nil 7 nil nil nil 7648 nil 8 4294911827 2098 nil nil nil 930 138 144 34 2 994 #createAt:extent: 34 2 514 383 3 514 199 41 7648 994 #text: 34 1 8 'Auto' 7648 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 191 0 0 0 1 0 0 0 34 1 0 0 21 0 0 0] 8 #() 1136 nil 27 6034 6640 6658 8 31 133 235 81 184 30 213 63 6640 6658 8 0 0 0 0 0 0 224 63 6128 -39 6128 1 170 192 34 6 6688 8 'manualBegin' 7184 8 'transactionless' 7648 8 'autoBegin' nil 930 138 144 34 1 994 #createAt:extent: 34 2 514 1 633 514 1169 51 6144 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 60 1 0 0 72 2 0 0 85 1 0 0] 34 4 6288 7648 6688 7184 1136 nil 27 6034 6080 1 6096 1 6128 -99 6128 -49 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 8384 nil 466 8 4278190080 nil 7 nil nil nil 8384 546 170 176 34 2 410 ##(Smalltalk.StaticText) 34 16 nil 8384 34 2 8 1140855041 262209 8528 nil 466 8 4278190080 nil 7 nil nil nil 8528 196934 1 ##(Smalltalk.RGB) 10921639 8 1714981536 2098 nil nil nil 930 138 144 34 2 994 #createAt:extent: 34 2 514 1 1 514 1169 51 8528 994 #text: 34 1 8 'Static Text' 8528 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 25 0 0 0] 8 #() 1136 nil 27 6034 6080 1 6096 1 6128 -49 6128 1 170 192 34 2 8528 8 'lastKnownTransaction' 590342 ##(Smalltalk.Rectangle) 514 1 1 514 1 1 930 138 144 34 1 994 #createAt:extent: 34 2 514 1 683 514 1169 51 8384 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 85 1 0 0 72 2 0 0 110 1 0 0] 34 1 8528 1136 nil 27 6034 6080 1 6096 1 6128 -49 6128 1 410 ##(Smalltalk.ReferenceView) 34 14 nil 416 34 2 8 1140850688 131073 9200 nil nil nil 7 nil nil nil 9200 898 ##(Smalltalk.JadeToolsToolBarPresenter) #resource_Default_view nil 930 138 144 34 1 994 #createAt:extent: 34 2 514 1 1 514 1169 51 9200 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 25 0 0 0] 1120 1136 nil 27 6034 6080 1 6640 3 6112 1 6066 #fixedViewTop 51 170 192 34 6 608 8 'cardContainer' 6144 8 'transactionMode' 9200 8 'Toolbar' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 5 2674 nil true 34 9 2722 1 2754 #fileNew 8 '&New Workspace' 9373 1 nil nil nil 2722 1 2754 #fileOpen 8 '&Open Workspace...' 9375 1 nil nil nil 2722 1 2754 #fileSave 8 '&Save' 9383 1 nil nil nil 2722 1 2754 #fileSaveAs 8 'Save &As...' 1 1 nil nil nil 2722 1 2754 #fileRevert 8 '&Revert' 1025 1 nil nil nil 2850 4097 2722 1 2754 #resetCursor 8 'Reset &Cursor' 1025 1 nil nil nil 2850 4097 2722 1 2754 #exit 8 'E&xit Jadeite' 17639 1 nil nil nil 8 '&File' nil 1 nil nil 21651 nil nil 2674 nil true 34 22 2722 1 2754 #undo 8 '&Undo' 9397 1 nil nil nil 2722 1 2754 #redo 8 'R&edo' 9395 1 nil nil nil 2850 4097 2722 1 2754 #editCut 8 'Cu&t' 9393 1 nil nil nil 2722 1 2754 #editCopy 8 '&Copy' 9351 1 nil nil nil 2722 1 2754 #editPaste 8 '&Paste' 9389 1 nil nil nil 2722 1 2754 #editDelete 8 '&Delete' 1629 1 nil nil nil 2850 4097 2722 1 2754 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 2850 4097 2722 1 2754 #editFind 8 '&Find...' 9357 1 nil nil nil 2722 1 2754 #editFindNext 8 'Find &Next' 1253 1 nil nil nil 2722 1 2754 #editReplace 8 '&Replace...' 9361 1 nil nil nil 2850 4097 2722 1 2754 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 2722 1 2754 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 2722 1 2754 #jadeExecute 8 '&Execute' 9355 1 nil nil nil 2722 1 2754 #jadeDebug 8 'Debug' 9349 1 nil nil nil 2722 1 2754 #fileIn 8 'Fi&le In' 1 1 nil nil nil 2850 4097 2722 1 2754 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 2722 1 2754 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 8 '&Edit' nil 1 nil nil 21687 nil nil 2674 nil true 34 12 2722 1 2754 #abortTransaction 8 '&Abort Transaction' 1 1 nil nil nil 2722 1 2754 #commitTransaction 8 '&Commit Transaction' 1 1 nil nil nil 2722 1 2754 #disableNativeCode 8 'Disable Native Code' 1 1 nil nil nil 2850 4097 2722 1 2754 #inspectOop 8 'Inspect Oop ...' 1 1 nil nil nil 2722 1 2754 #describeErrorNumber 8 'Description for Error Number ...' 1025 1 nil nil nil 2850 4097 2722 1025 2754 #flipTranscript 8 'Transcript writes enabled' 1025 1 nil nil nil 2722 1025 2754 #flipAutoCommit 8 'AutoCommit enabled' 1025 1 nil nil nil 2722 1025 2754 #flipBreakpointsEnabled 8 'Breakpoints enabled' 1025 1 nil nil nil 2722 1025 2754 #flipAutocomplete 8 'Autocomplete enabled' 1025 1 nil nil nil 2722 1025 2754 #flipLogging 8 'Logging Enabled' 1025 1 nil nil nil 8 '&Jadeite' nil 1 nil nil 21709 nil nil 2674 nil true 34 14 2722 1 2754 #openJadeiteProjectsBrowser 8 'Browse &Projects' 9377 1 nil nil nil 2722 1 2754 #browseProcesses 8 'Browse P&rocesses' 9381 1 nil nil nil 2722 1 2754 #jadeBrowseTests 8 'Browse SUnit &Tests' 1 1 nil nil nil 2850 4097 2722 1 2754 #browseClass 8 'Find Class ...' 13453 1 nil nil nil 2722 1 2754 #browseClassReferences 8 'Browse &Class References ...' 13447 1 nil nil nil 2722 1 2754 #browseImplementorsOf 8 'Browse &Implementors of ...' 13459 1 nil nil nil 2722 1 2754 #browseSendersOf 8 'Browse &Senders of ...' 13479 1 nil nil nil 2722 1 2754 #browseMethodsContaining 8 'Browse &Methods Containing ...' 1 1 nil nil nil 2722 1 2754 #browseLiteralReferences 8 'Browse &Literal References ...' 1 1 nil nil nil 2722 1 2754 #browseBreakpoints nil 1 1 nil nil nil 2850 4097 2722 1025 2754 #browseJadeiteLogs 8 'Browse Logs' 1025 1 nil nil nil 2722 1025 2754 #browseJadeitePrefs 8 'Browse Preferences File' 1025 1 nil nil nil 8 '&Browse' nil 134217729 nil nil 21735 nil nil 2674 nil true 34 4 2722 1 2754 #openGitHubJadeiteProject 8 '&Jadiete GitHub Project' 1025 1 nil nil nil 2722 1 2754 #openGitHubRowanProject 8 '&Rowan GitHub Project' 1025 1 nil nil nil 2850 4097 2722 1 2754 #aboutJadeite 8 '&About Jadeite' 1 1 nil nil nil 8 '&Help' nil 1 nil nil 21743 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons\GS32.ico' nil 12370 nil true 12416 8 'icons\GS16.ico' nil nil nil 1 nil nil 930 138 144 34 3 994 #createAt:extent: 34 2 514 6829 21 514 1201 851 416 994 #text: 34 1 8 'Jadeite Session' 416 994 #updateMenuBar 1120 416 1074 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 86 13 0 0 10 0 0 0 174 15 0 0 179 1 0 0] 34 4 9200 608 6144 8384 1136 nil 27 )!

showOnSession: aGciSession
	| theTranscript |
	theTranscript := super showOnSession: aGciSession.
	theTranscript setTransactionModeFromServer.
	^theTranscript! !
!JadeiteTranscript class categoriesFor: #resource_Default_view!public!resources-views! !
!JadeiteTranscript class categoriesFor: #showOnSession:!instance creation!public! !

