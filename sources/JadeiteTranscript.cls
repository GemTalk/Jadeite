"Filed out from Dolphin Smalltalk 7"!

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
			session autoCommit: boolean]!

autoCompleteEnabled
	"for testing"

	^autoCompleteEnabled value!

autoCompleteEnabled: boolean
	"for testing"

	JadeiteSearch autoCompleteEnabled: boolean.
	autoCompleteEnabled value: boolean!

basicTransactionMode: aSymbol
	self parentPresenter transactionMode: aSymbol session: gciSession!

beginTransaction
	self parentPresenter beginTransaction!

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
		updateCaption: path!

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
	self initializeTransactionModeSettings.	"should have already been set when window was created ... but just in case"
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
	projectListPresenter hasSelection
		ifTrue: [^projectListPresenter browseProject topShell]
		ifFalse: 
			[gciSession hasServer ifTrue: [^(JadeiteBrowser showOnSession: gciSession)].
			MessageBox warning: 'Cannot open Jadeite Projects browser'
				caption: 'Cannot open Jadeite Projects browser']!

projectListPresenter
	^projectListPresenter!

queryCommand: query
	super queryCommand: query.
	query commandSymbol = #begin
		ifTrue: 
			[query isEnabled: self isBeginTransactionEnabled.
			^true].
	query commandSymbol = #commitTransaction
		ifTrue: 
			[query isEnabled: self isCommitEnabled.
			^true].
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
!JadeiteTranscript categoriesFor: #isBeginTransactionEnabled!public!testing! !
!JadeiteTranscript categoriesFor: #isCommitEnabled!public!testing! !
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

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 1201 851 551 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 8 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140916224 132097 608 nil 466 8 4278190080 nil 7 nil nil nil 608 546 170 176 34 8 410 ##(Smalltalk.RadioButton) 34 16 nil 608 34 2 8 1141058825 1 752 721990 2 ##(Smalltalk.ValueHolder) nil nil 1376774 ##(Smalltalk.PluggableSearchPolicy) 459270 ##(Smalltalk.Message) #= 8 #() 882 #hash 8 #() false 466 8 4278190080 nil 7 nil nil nil 752 nil 8 4294911827 852486 ##(Smalltalk.NullConverter) nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 581 3 514 233 41 752 1106 #text: 34 1 8 'Manual' 752 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 34 1 0 0 1 0 0 0 150 1 0 0 21 0 0 0] 8 #() 514 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #relativeParentWidth 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 224 63 1360 1378 8 102 102 102 102 102 102 230 63 1346 #fixedParentBottom -39 1424 1 410 ##(Smalltalk.StaticText) 34 16 nil 608 34 2 8 1140850945 65 1440 nil 466 8 4278190080 nil 7 nil nil nil 1440 nil 8 1714981536 1010 nil nil nil 1042 138 144 34 2 1106 #createAt:extent: 34 2 514 1 3 514 383 41 1440 1106 #text: 34 1 8 'Transaction Mode:
Transaction Mode:' 1440 1234 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 1 0 0 0 191 0 0 0 21 0 0 0] 8 #() 1296 nil 27 1314 1360 1 1360 1378 8 31 133 235 81 184 30 213 63 1424 -39 1424 1 410 ##(Smalltalk.RadioButton) 34 16 nil 608 34 2 8 1141058825 1 1808 818 nil nil 850 882 #= 8 #() 882 #hash 8 #() false 466 8 4278190080 nil 7 nil nil nil 1808 nil 8 4294911827 1010 nil nil nil 1042 138 144 34 2 1106 #createAt:extent: 34 2 514 383 3 514 199 41 1808 1106 #text: 34 1 8 'Auto' 1808 1234 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 191 0 0 0 1 0 0 0 34 1 0 0 21 0 0 0] 8 #() 1296 nil 27 1314 1360 1378 8 31 133 235 81 184 30 213 63 1360 1378 8 0 0 0 0 0 0 224 63 1424 -39 1424 1 410 ##(Smalltalk.RadioButton) 34 16 nil 608 34 2 8 1141058825 1 2288 818 nil nil 850 882 #= 8 #() 882 #hash 8 #() false 466 8 4278190080 nil 7 nil nil nil 2288 nil 8 4294911827 1010 nil nil nil 1042 138 144 34 2 1106 #createAt:extent: 34 2 514 813 3 514 349 41 2288 1106 #text: 34 1 8 'Transactionless' 2288 1234 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 150 1 0 0 1 0 0 0 68 2 0 0 21 0 0 0] 8 #() 1296 nil 27 1314 1360 1378 8 102 102 102 102 102 102 230 63 1360 3 1424 -39 1424 1 170 192 34 6 1808 8 'autoBegin' 2288 8 'transactionless' 752 8 'manualBegin' nil 1042 138 144 34 1 1106 #createAt:extent: 34 2 514 1 633 514 1169 51 608 1234 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 60 1 0 0 72 2 0 0 85 1 0 0] 34 4 1440 1808 752 2288 1296 nil 27 1314 1346 #fixedParentLeft 1 1346 #fixedParentRight 1 1424 -99 1424 -49 410 ##(Smalltalk.ReferenceView) 34 14 nil 416 34 2 8 1140850688 131073 3040 nil nil nil 7 nil nil nil 3040 1180166 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeToolsToolBarPresenter) #resource_Default_view nil 1042 138 144 34 1 1106 #createAt:extent: 34 2 514 1 1 514 1169 51 3040 1234 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 25 0 0 0] 8 #() 1296 nil 27 1314 3008 1 1360 3 1346 #fixedParentTop 1 1346 #fixedViewTop 51 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 3344 nil 466 8 4278190080 nil 7 nil nil nil 3344 546 170 176 34 2 410 ##(Smalltalk.StaticText) 34 16 nil 3344 34 2 8 1140855041 262209 3488 nil 466 8 4278190080 nil 7 nil nil nil 3488 196934 1 ##(Smalltalk.RGB) 10921639 8 1714981536 1010 nil nil nil 1042 138 144 34 2 1106 #createAt:extent: 34 2 514 1 1 514 1169 51 3488 1106 #text: 34 1 8 'Static Text' 3488 1234 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 25 0 0 0] 8 #() 1296 nil 27 1314 3008 1 3024 1 1424 -49 1424 1 170 192 34 2 3488 8 'lastKnownTransaction' 590342 ##(Smalltalk.Rectangle) 514 1 1 514 1 1 1042 138 144 34 1 1106 #createAt:extent: 34 2 514 1 683 514 1169 51 3344 1234 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 85 1 0 0 72 2 0 0 110 1 0 0] 34 1 3488 1296 nil 27 1314 3008 1 3024 1 1424 -49 1424 1 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1140850688 131073 4160 nil 466 496 nil 7 nil nil nil 4160 655878 ##(Smalltalk.CardLayout) 138 144 34 7 721414 ##(Smalltalk.Association) 8 'Workspace' 410 ##(Smalltalk.ReferenceView) 34 14 nil 4160 34 2 8 1140850688 131073 4352 nil 466 8 4278190080 nil 5 nil nil nil 4352 3106 ##(Smalltalk.CodeSourcePresenter) #resource_Default_view nil 1042 138 144 34 1 1106 #createAt:extent: 34 2 514 9 55 514 1153 521 4352 1234 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 31 1 0 0] 3280 1296 nil 27 4306 8 'My Session' 410 ##(Smalltalk.ReferenceView) 34 14 nil 4160 34 2 8 1140850688 131073 4640 nil nil nil 5 nil nil nil 4640 3106 ##(Smalltalk.MySessionPresenter) #resource_Default_view nil 1042 138 144 34 1 1106 #createAt:extent: 34 2 514 9 55 514 1153 521 4640 1234 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 31 1 0 0] 3280 1296 nil 27 4306 8 'All Sessions' 410 ##(Smalltalk.ReferenceView) 34 14 nil 4160 34 2 8 1140850688 131073 4896 nil nil nil 5 nil nil nil 4896 3106 ##(Smalltalk.AllSessionsPresenter) #resource_Default_view nil 1042 138 144 34 1 1106 #createAt:extent: 34 2 514 9 55 514 1153 521 4896 1234 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 31 1 0 0] 3280 1296 nil 27 4306 8 'Transcript' 410 ##(Smalltalk.ReferenceView) 34 14 nil 4160 34 2 8 1140916224 131073 5152 nil 466 8 4278190080 nil 5 nil nil nil 5152 3106 ##(Smalltalk.TranscriptPresenter) #resource_Default_view nil 1042 138 144 34 1 1106 #createAt:extent: 34 2 514 9 55 514 1153 521 5152 1234 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 31 1 0 0] 3280 1296 nil 27 4306 8 'History' 410 ##(Smalltalk.MultilineTextEdit) 34 16 nil 4160 34 2 8 1143017796 1025 5440 nil 466 8 4278190080 nil 5 nil nil nil 5440 nil 8 4294904437 1010 nil nil 11 1042 138 144 34 1 1106 #createAt:extent: 34 2 514 9 55 514 1153 521 5440 1234 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 31 1 0 0] 8 #() 1296 nil 27 4306 ##(Smalltalk.Stone) 410 ##(Smalltalk.ReferenceView) 34 14 nil 4160 34 2 8 1140850688 131073 5744 nil nil nil 5 nil nil nil 5744 3106 ##(Smalltalk.StoneInfoPresenter) #resource_Default_view nil 1042 138 144 34 1 1106 #createAt:extent: 34 2 514 9 55 514 1153 521 5744 1234 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 31 1 0 0] 3280 1296 nil 27 4306 8 'Projects' 410 ##(Smalltalk.ShellView) 34 27 nil 4160 34 2 8 1078919168 131073 6000 nil 466 8 4278190080 514 1201 801 551 265030 4 ##(Smalltalk.Menu) nil true 34 18 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #makeDefault 8 'Make Default' 1 1 nil nil nil 6162 1 6194 #browseProject 8 'Browse' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 6162 1 6194 #cloneProject 8 'Clone Git Project ...' 1 1 nil nil nil 6162 1 6194 #loadProjects 8 'Load' 1 1 nil nil nil 6162 1 6194 #unloadProjects 8 'Unload' 1 1 nil nil nil 6290 4097 6162 1 6194 #pullFromGit 8 'Pull from Git' 1 1 nil nil nil 6162 1 6194 #gitCommit 8 'Commit to Git ...' 1 1 nil nil nil 6162 1 6194 #pushToGit 8 'Push to Git' 1 1 nil nil nil 6290 4097 6162 1 6194 #projectChanges 8 'Changes' 1 1 nil nil nil 6162 1 6194 #writeProject 8 'Write' 1 1 nil nil nil 6162 1 6194 #checkout 8 'Checkout Git Branch ...' 1 1 nil nil nil 6290 4097 6162 1 6194 #projectLog 8 'Git Log' 1 1 nil nil nil 6162 1 6194 #openCommitInGitHub 8 'Browse Commit In GitHub' 1 1 nil nil nil 6162 1 6194 #refresh 8 'Refresh' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 6000 1180166 ##(Smalltalk.ProportionalLayout) 170 176 3280 false 170 192 34 2 410 ##(Smalltalk.ListView) 34 30 nil 6000 34 2 8 1140920649 1025 7040 590662 2 ##(Smalltalk.ListModel) 138 144 3280 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 466 8 4278190080 nil 7 nil nil nil 7040 nil 8 4294912595 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 3 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Project Name' 371 #left 882 #displayString 8 #() ##(Smalltalk.SortedCollection) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 7376 8 'doIt' 8 '[:project | project displayName]' 8 #[30 105 226 0 106] #displayName 7392 7 257 nil nil 7040 nil 3 nil 7378 0 nil 7410 3 1 7376 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 7488 7 257 nil false nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 7584 818 nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 7584 nil nil 1010 nil 8 '' 3 nil nil nil nil nil nil nil nil nil 7298 8 'Loaded Sha' 373 #left 882 #displayString 8 #() 882 #<= 7744 7378 0 nil 7410 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:project | project sha]' 8 #[30 105 226 0 106] #sha 7776 7 257 nil nil 7040 nil 3 nil nil false nil 7570 nil nil 8 #(67174528 0) 7856 818 nil false 7648 nil 466 8 4278190080 nil 5 nil nil nil 7856 nil nil 1010 nil 8 '' 3 nil nil nil nil nil nil nil nil nil 7298 8 'Branch' 371 #left 882 #displayString 7744 882 #<= 7744 7378 0 nil 7410 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:project | project branch]' 8 #[30 105 226 0 106] #branch 8032 7 257 nil nil 7040 nil 3 nil nil false nil 7570 nil nil 8 #(67174528 0) 8112 818 nil false 7648 nil 466 7920 nil 5 nil nil nil 8112 nil nil 1010 nil 8 '' 3 nil nil nil nil nil nil nil nil nil #report 3280 nil 131171 514 129 129 34 4 nil nil 514 1 1 nil 1042 138 144 34 2 1106 #createAt:extent: 34 2 514 1 1 514 1121 489 7040 1106 #text: 34 1 8 'Project Name' 7040 1234 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 48 2 0 0 244 0 0 0] 8 #() 1296 nil 27 8 'projectList' nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1042 138 144 34 4 1106 #createAt:extent: 34 2 514 9 55 514 1153 521 6000 1106 #contextMenu: 34 1 6128 6000 1106 #text: 34 1 8 'Rowan Project List' 6000 1106 #updateMenuBar 3280 6000 1234 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 31 1 0 0] 34 1 7040 1296 nil 27 6000 170 192 34 14 5744 8 'Stone' 5152 8 'Transcript' 4896 8 'All Sessions' 6000 8 'projectsList' 5440 8 'history' 4640 8 'My Session' 4352 8 'codePane' nil 410 ##(Smalltalk.TabView) 34 23 nil 4160 34 2 8 1140916736 1 8880 7106 138 144 34 7 5136 5424 ##(Smalltalk.Stone) 4624 4880 4336 5984 nil 7168 721158 ##(Smalltalk.SystemColor) 31 nil 1 nil nil nil 8880 nil 8 4294910233 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 7248 nil nil nil nil nil #noIcons 1042 138 144 34 3 1106 #createAt:extent: 34 2 514 1 1 514 1169 583 8880 1106 #basicSelectionsByIndex: 34 1 8 #(7) 8880 1106 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 8880 1234 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 35 1 0 0] 8 #() 1296 nil 27 1042 138 144 34 1 1106 #createAt:extent: 34 2 514 1 51 514 1169 583 4160 1234 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 72 2 0 0 60 1 0 0] 34 8 5152 5440 5744 4640 4896 4352 6000 8880 1296 nil 27 1314 3008 1 3024 1 3312 51 1424 -99 170 192 34 6 4160 8 'cardContainer' 608 8 'transactionMode' 3040 8 'Toolbar' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 5 6114 nil true 34 9 6162 1 6194 #fileNew 8 '&New Workspace' 9373 1 nil nil nil 6162 1 6194 #fileOpen 8 '&Open Workspace...' 9375 1 nil nil nil 6162 1 6194 #fileSave 8 '&Save' 9383 1 nil nil nil 6162 1 6194 #fileSaveAs 8 'Save &As...' 1 1 nil nil nil 6162 1 6194 #fileRevert 8 '&Revert' 1025 1 nil nil nil 6290 4097 6162 1 6194 #resetCursor 8 'Reset &Cursor' 1025 1 nil nil nil 6290 4097 6162 1 6194 #exit 8 'E&xit Jadeite' 17639 1 nil nil nil 8 '&File' nil 1 nil nil 46675 nil nil 6114 nil true 34 22 6162 1 6194 #undo 8 '&Undo' 9397 1 nil nil nil 6162 1 6194 #redo 8 'R&edo' 9395 1 nil nil nil 6290 4097 6162 1 6194 #editCut 8 'Cu&t' 9393 1 nil nil nil 6162 1 6194 #editCopy 8 '&Copy' 9351 1 nil nil nil 6162 1 6194 #editPaste 8 '&Paste' 9389 1 nil nil nil 6162 1 6194 #editDelete 8 '&Delete' 1629 1 nil nil nil 6290 4097 6162 1 6194 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 6290 4097 6162 1 6194 #editFind 8 '&Find...' 9357 1 nil nil nil 6162 1 6194 #editFindNext 8 'Find &Next' 1253 1 nil nil nil 6162 1 6194 #editReplace 8 '&Replace...' 9361 1 nil nil nil 6290 4097 6162 1 6194 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 6162 1 6194 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 6162 1 6194 #jadeExecute 8 '&Execute' 9355 1 nil nil nil 6162 1 6194 #jadeDebug 8 'Debug' 9349 1 nil nil nil 6162 1 6194 #fileIn 8 'Fi&le In' 1 1 nil nil nil 6290 4097 6162 1 6194 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 6162 1 6194 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 8 '&Edit' nil 1 nil nil 46711 nil nil 6114 nil true 34 13 6162 1 6194 #abortTransaction 8 '&Abort Transaction' 1 1 nil nil nil 6162 1 6194 #commitTransaction 8 '&Commit Transaction' 1 1 nil nil nil 6162 1 6194 #begin 8 'Begin Transaction' 1 1 nil nil nil 6162 1 6194 #disableNativeCode 8 'Disable Native Code' 1 1 nil nil nil 6290 4097 6162 1 6194 #inspectOop 8 'Inspect Oop ...' 1 1 nil nil nil 6162 1 6194 #describeErrorNumber 8 'Description for Error Number ...' 1025 1 nil nil nil 6290 4097 6162 1025 6194 #flipTranscript 8 'Transcript writes enabled' 1025 1 nil nil nil 6162 1025 6194 #flipAutoCommit 8 'AutoCommit enabled' 1025 1 nil nil nil 6162 1025 6194 #flipBreakpointsEnabled 8 'Breakpoints enabled' 1025 1 nil nil nil 6162 1025 6194 #flipAutocomplete 8 'Autocomplete enabled' 1025 1 nil nil nil 6162 1025 6194 #flipLogging 8 'Logging Enabled' 1025 1 nil nil nil 8 '&Jadeite' nil 1 nil nil 46735 nil nil 6114 nil true 34 14 6162 1 6194 #openJadeiteProjectsBrowser 8 'Browse &Projects' 9377 1 nil nil nil 6162 1 6194 #browseProcesses 8 'Browse P&rocesses' 9381 1 nil nil nil 6162 1 6194 #jadeBrowseTests 8 'Browse SUnit &Tests' 1 1 nil nil nil 6290 4097 6162 1 6194 #browseClass 8 'Find Class ...' 13453 1 nil nil nil 6162 1 6194 #browseClassReferences 8 'Browse &Class References ...' 13447 1 nil nil nil 6162 1 6194 #browseImplementorsOf 8 'Browse &Implementors of ...' 13459 1 nil nil nil 6162 1 6194 #browseSendersOf 8 'Browse &Senders of ...' 13479 1 nil nil nil 6162 1 6194 #browseMethodsContaining 8 'Browse &Methods Containing ...' 1 1 nil nil nil 6162 1 6194 #browseLiteralReferences 8 'Browse &Literal References ...' 1 1 nil nil nil 6162 1 6194 #browseBreakpoints nil 1 1 nil nil nil 6290 4097 6162 1025 6194 #browseJadeiteLogs 8 'Browse Logs' 1025 1 nil nil nil 6162 1025 6194 #browseJadeitePrefs 8 'Browse Preferences File' 1025 1 nil nil nil 8 '&Browse' nil 134217729 nil nil 46761 nil nil 6114 nil true 34 4 6162 1 6194 #openGitHubJadeiteProject 8 '&Jadiete GitHub Project' 1025 1 nil nil nil 6162 1 6194 #openGitHubRowanProject 8 '&Rowan GitHub Project' 1025 1 nil nil nil 6290 4097 6162 1 6194 #aboutJadeite 8 '&About Jadeite' 1 1 nil nil nil 8 '&Help' nil 1 nil nil 46769 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons\GS32.ico' nil 12418 nil true 12464 8 'icons\GS16.ico' nil nil nil 1 nil nil 1042 138 144 34 3 1106 #createAt:extent: 34 2 514 6829 21 514 1201 851 416 1106 #text: 34 1 8 'Jadeite Session' 416 1106 #updateMenuBar 3280 416 1234 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 86 13 0 0 10 0 0 0 174 15 0 0 179 1 0 0] 34 4 3040 4160 608 3344 1296 nil 27 )!

showOnSession: aGciSession
	| theTranscript |
	theTranscript := super showOnSession: aGciSession.
	theTranscript setTransactionModeFromServer.
	^theTranscript! !
!JadeiteTranscript class categoriesFor: #resource_Default_view!public!resources-views! !
!JadeiteTranscript class categoriesFor: #showOnSession:!instance creation!public! !

