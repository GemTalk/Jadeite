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
	self displayLastKnownCommitOrAbort!

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

toolbarPresenter
	^toolbarPresenter!

transactionMode
	^self parentPresenter transactionMode!

transactionMode: aSymbol
	"It seems Dolphin should have an event like 'aboutToChangeRadioButton' to avoid having to muck with the low level view"

	(MessageBox confirm: 'Switching transaction modes will cause an abort. Continue?')
		ifTrue: [self basicTransactionMode: aSymbol]
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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 1201 851 551 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 8 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 608 nil 466 8 4278190080 nil 7 nil nil nil 608 nil 170 192 34 2 410 ##(Smalltalk.StaticText) 34 16 nil 608 34 2 8 1140855041 262209 736 nil 466 8 4278190080 nil 7 nil nil nil 736 196934 1 ##(Smalltalk.RGB) 10921639 8 1714981536 852486 ##(Smalltalk.NullConverter) nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 1 1 514 1169 51 736 978 #text: 34 1 8 'Static Text' 736 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 25 0 0 0] 8 #() 514 193 193 nil 27 8 'lastKnownTransaction' 590342 ##(Smalltalk.Rectangle) 514 1 1 514 1 1 914 138 144 34 1 978 #createAt:extent: 34 2 514 1 683 514 1169 51 608 1106 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 85 1 0 0 72 2 0 0 110 1 0 0] 34 1 736 1168 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 1458 #fixedParentRight 1 1458 #fixedParentBottom -49 1504 1 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140916224 132097 1520 nil 466 8 4278190080 nil 7 nil nil nil 1520 546 170 176 34 8 410 ##(Smalltalk.RadioButton) 34 16 nil 1520 34 2 8 1141058825 1 1664 721990 2 ##(Smalltalk.ValueHolder) nil nil 1376774 ##(Smalltalk.PluggableSearchPolicy) 459270 ##(Smalltalk.Message) #= 8 #() 1794 #hash 8 #() false 466 8 4278190080 nil 7 nil nil nil 1664 nil 8 4294904213 882 nil nil nil 914 138 144 34 2 978 #createAt:extent: 34 2 514 813 3 514 349 41 1664 978 #text: 34 1 8 'Transactionless' 1664 1106 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 150 1 0 0 1 0 0 0 68 2 0 0 21 0 0 0] 8 #() 1168 nil 27 1426 1458 #relativeParentWidth 327734 ##(Smalltalk.Float) 8 102 102 102 102 102 102 230 63 2160 3 1504 -39 1504 1 410 ##(Smalltalk.RadioButton) 34 16 nil 1520 34 2 8 1141058825 1 2208 1730 nil nil 1762 1794 #= 8 #() 1794 #hash 8 #() false 466 8 4278190080 nil 7 nil nil nil 2208 nil 8 4294904213 882 nil nil nil 914 138 144 34 2 978 #createAt:extent: 34 2 514 383 3 514 199 41 2208 978 #text: 34 1 8 'Auto' 2208 1106 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 191 0 0 0 1 0 0 0 34 1 0 0 21 0 0 0] 8 #() 1168 nil 27 1426 2160 2178 8 31 133 235 81 184 30 213 63 2160 2178 8 0 0 0 0 0 0 224 63 1504 -39 1504 1 410 ##(Smalltalk.RadioButton) 34 16 nil 1520 34 2 8 1141058825 1 2688 1730 nil nil 1762 1794 #= 8 #() 1794 #hash 8 #() false 466 8 4278190080 nil 7 nil nil nil 2688 nil 8 4294904213 882 nil nil nil 914 138 144 34 2 978 #createAt:extent: 34 2 514 581 3 514 233 41 2688 978 #text: 34 1 8 'Manual' 2688 1106 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 34 1 0 0 1 0 0 0 150 1 0 0 21 0 0 0] 8 #() 1168 nil 27 1426 2160 2178 8 0 0 0 0 0 0 224 63 2160 2178 8 102 102 102 102 102 102 230 63 1504 -39 1504 1 410 ##(Smalltalk.StaticText) 34 16 nil 1520 34 2 8 1140850945 65 3168 nil 466 8 4278190080 nil 7 nil nil nil 3168 nil 8 1714981536 882 nil nil nil 914 138 144 34 2 978 #createAt:extent: 34 2 514 1 3 514 383 41 3168 978 #text: 34 1 8 'Transaction Mode:
Transaction Mode:' 3168 1106 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 1 0 0 0 191 0 0 0 21 0 0 0] 8 #() 1168 nil 27 1426 2160 1 2160 2178 8 31 133 235 81 184 30 213 63 1504 -39 1504 1 170 192 34 6 1664 8 'transactionless' 2208 8 'autoBegin' 2688 8 'manualBegin' nil 914 138 144 34 1 978 #createAt:extent: 34 2 514 1 633 514 1169 51 1520 1106 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 60 1 0 0 72 2 0 0 85 1 0 0] 34 4 3168 2208 2688 1664 1168 nil 27 1426 1472 1 1488 1 1504 -99 1504 -49 410 ##(Smalltalk.ReferenceView) 34 14 nil 416 34 2 8 1140850688 131073 3792 nil nil nil 7 nil nil nil 3792 1180166 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeToolsToolBarPresenter) #resource_Default_view nil 914 138 144 34 1 978 #createAt:extent: 34 2 514 1 1 514 1169 51 3792 1106 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 25 0 0 0] 8 #() 1168 nil 27 1426 1472 1 2160 3 1458 #fixedParentTop 1 1458 #fixedViewTop 51 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1140850688 131073 4096 nil 466 496 nil 7 nil nil nil 4096 655878 ##(Smalltalk.CardLayout) 138 144 34 7 721414 ##(Smalltalk.Association) 8 'Workspace' 410 ##(Smalltalk.ReferenceView) 34 14 nil 4096 34 2 8 1140850688 131073 4288 nil 466 8 4278190080 nil 5 nil nil nil 4288 3858 ##(Smalltalk.CodeSourcePresenter) #resource_Default_view nil 914 138 144 34 1 978 #createAt:extent: 34 2 514 9 55 514 1153 521 4288 1106 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 31 1 0 0] 4032 1168 nil 27 4242 8 'My Session' 410 ##(Smalltalk.ReferenceView) 34 14 nil 4096 34 2 8 1140850688 131073 4576 nil nil nil 5 nil nil nil 4576 3858 ##(Smalltalk.MySessionPresenter) #resource_Default_view nil 914 138 144 34 1 978 #createAt:extent: 34 2 514 9 55 514 1153 521 4576 1106 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 31 1 0 0] 4032 1168 nil 27 4242 8 'All Sessions' 410 ##(Smalltalk.ReferenceView) 34 14 nil 4096 34 2 8 1140850688 131073 4832 nil nil nil 5 nil nil nil 4832 3858 ##(Smalltalk.AllSessionsPresenter) #resource_Default_view nil 914 138 144 34 1 978 #createAt:extent: 34 2 514 9 55 514 1153 521 4832 1106 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 31 1 0 0] 4032 1168 nil 27 4242 8 'Transcript' 410 ##(Smalltalk.ReferenceView) 34 14 nil 4096 34 2 8 1140916224 131073 5088 nil 466 8 4278190080 nil 5 nil nil nil 5088 3858 ##(Smalltalk.TranscriptPresenter) #resource_Default_view nil 914 138 144 34 1 978 #createAt:extent: 34 2 514 9 55 514 1153 521 5088 1106 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 31 1 0 0] 4032 1168 nil 27 4242 8 'History' 410 ##(Smalltalk.MultilineTextEdit) 34 16 nil 4096 34 2 8 1143017796 1025 5376 nil 466 8 4278190080 nil 5 nil nil nil 5376 nil 8 4294902587 882 nil nil 11 914 138 144 34 1 978 #createAt:extent: 34 2 514 9 55 514 1153 521 5376 1106 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 31 1 0 0] 8 #() 1168 nil 27 4242 ##(Smalltalk.Stone) 410 ##(Smalltalk.ReferenceView) 34 14 nil 4096 34 2 8 1140850688 131073 5680 nil nil nil 5 nil nil nil 5680 3858 ##(Smalltalk.StoneInfoPresenter) #resource_Default_view nil 914 138 144 34 1 978 #createAt:extent: 34 2 514 9 55 514 1153 521 5680 1106 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 31 1 0 0] 4032 1168 nil 27 4242 8 'Projects' 410 ##(Smalltalk.ShellView) 34 27 nil 4096 34 2 8 1078919168 131073 5936 nil 466 8 4278190080 514 1201 801 551 265030 4 ##(Smalltalk.Menu) nil true 34 18 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #makeDefault 8 'Make Default' 1 1 nil nil nil 6098 1 6130 #browseProject 8 'Browse' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 6098 1 6130 #cloneProject 8 'Clone Git Project ...' 1 1 nil nil nil 6098 1 6130 #loadProjects 8 'Load' 1 1 nil nil nil 6098 1 6130 #unloadProjects 8 'Unload' 1 1 nil nil nil 6226 4097 6098 1 6130 #pullFromGit 8 'Pull from Git' 1 1 nil nil nil 6098 1 6130 #gitCommit 8 'Commit to Git ...' 1 1 nil nil nil 6098 1 6130 #pushToGit 8 'Push to Git' 1 1 nil nil nil 6226 4097 6098 1 6130 #projectChanges 8 'Changes' 1 1 nil nil nil 6098 1 6130 #writeProject 8 'Write' 1 1 nil nil nil 6098 1 6130 #checkout 8 'Checkout Git Branch ...' 1 1 nil nil nil 6226 4097 6098 1 6130 #projectLog 8 'Git Log' 1 1 nil nil nil 6098 1 6130 #openCommitInGitHub 8 'Browse Commit In GitHub' 1 1 nil nil nil 6098 1 6130 #refresh 8 'Refresh' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 5936 1180166 ##(Smalltalk.ProportionalLayout) 170 176 4032 false 170 192 34 2 410 ##(Smalltalk.ListView) 34 30 nil 5936 34 2 8 1140920649 1025 6976 590662 2 ##(Smalltalk.ListModel) 138 144 4032 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 466 8 4278190080 nil 7 nil nil nil 6976 nil 8 4294904201 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 3 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Project Name' 371 #left 1794 #displayString 8 #() ##(Smalltalk.SortedCollection) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 7312 8 'doIt' 8 '[:project | project displayName]' 8 #[30 105 226 0 106] #displayName 7328 7 257 nil nil 6976 nil 3 nil 7314 0 nil 7346 3 1 7312 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 7424 7 257 nil false nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 7520 1730 nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 7520 nil nil 882 nil 8 '' 3 nil nil nil nil nil nil nil nil nil 7234 8 'Loaded Sha' 373 #left 1794 #displayString 8 #() 1794 #<= 7680 7314 0 nil 7346 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:project | project sha]' 8 #[30 105 226 0 106] #sha 7712 7 257 nil nil 6976 nil 3 nil nil false nil 7506 nil nil 8 #(67174528 0) 7792 1730 nil false 7584 nil 466 8 4278190080 nil 5 nil nil nil 7792 nil nil 882 nil 8 '' 3 nil nil nil nil nil nil nil nil nil 7234 8 'Branch' 371 #left 1794 #displayString 7680 1794 #<= 7680 7314 0 nil 7346 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:project | project branch]' 8 #[30 105 226 0 106] #branch 7968 7 257 nil nil 6976 nil 3 nil nil false nil 7506 nil nil 8 #(67174528 0) 8048 1730 nil false 7584 nil 466 7856 nil 5 nil nil nil 8048 nil nil 882 nil 8 '' 3 nil nil nil nil nil nil nil nil nil #report 4032 nil 131171 514 129 129 34 4 nil nil 514 1 1 nil 914 138 144 34 2 978 #createAt:extent: 34 2 514 1 1 514 1121 489 6976 978 #text: 34 1 8 'Project Name' 6976 1106 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 48 2 0 0 244 0 0 0] 8 #() 1168 nil 27 8 'projectList' nil nil nil nil nil 1 nil nil nil nil 1 nil nil 914 138 144 34 4 978 #createAt:extent: 34 2 514 9 55 514 1153 521 5936 978 #contextMenu: 34 1 6064 5936 978 #text: 34 1 8 'Rowan Project List' 5936 978 #updateMenuBar 4032 5936 1106 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 68 2 0 0 31 1 0 0] 34 1 6976 1168 nil 27 5936 170 192 34 14 4576 8 'My Session' 5680 8 'Stone' 5936 8 'projectsList' 4832 8 'All Sessions' 4288 8 'codePane' 5088 8 'Transcript' 5376 8 'history' nil 410 ##(Smalltalk.TabView) 34 23 nil 4096 34 2 8 1140916736 1 8816 7042 138 144 34 7 5072 5360 ##(Smalltalk.Stone) 4560 4816 4272 5920 nil 7104 721158 ##(Smalltalk.SystemColor) 31 nil 1 nil nil nil 8816 nil 8 4294904707 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 7184 nil nil nil nil nil #noIcons 914 138 144 34 3 978 #createAt:extent: 34 2 514 1 1 514 1169 583 8816 978 #basicSelectionsByIndex: 34 1 8 #(7) 8816 978 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 8816 1106 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 35 1 0 0] 8 #() 1168 nil 27 914 138 144 34 1 978 #createAt:extent: 34 2 514 1 51 514 1169 583 4096 1106 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 72 2 0 0 60 1 0 0] 34 8 5088 5376 5680 4576 4832 4288 5936 8816 1168 nil 27 1426 1472 1 1488 1 4064 51 1504 -99 170 192 34 6 3792 8 'Toolbar' 4096 8 'cardContainer' 1520 8 'transactionMode' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 5 6050 nil true 34 9 6098 1 6130 #fileNew 8 '&New Workspace' 9373 1 nil nil nil 6098 1 6130 #fileOpen 8 '&Open Workspace...' 9375 1 nil nil nil 6098 1 6130 #fileSave 8 '&Save' 9383 1 nil nil nil 6098 1 6130 #fileSaveAs 8 'Save &As...' 1 1 nil nil nil 6098 1 6130 #fileRevert 8 '&Revert' 1025 1 nil nil nil 6226 4097 6098 1 6130 #resetCursor 8 'Reset &Cursor' 1025 1 nil nil nil 6226 4097 6098 1 6130 #exit 8 'E&xit Jadeite' 17639 1 nil nil nil 8 '&File' nil 1 nil nil 13499 nil nil 6050 nil true 34 22 6098 1 6130 #undo 8 '&Undo' 9397 1 nil nil nil 6098 1 6130 #redo 8 'R&edo' 9395 1 nil nil nil 6226 4097 6098 1 6130 #editCut 8 'Cu&t' 9393 1 nil nil nil 6098 1 6130 #editCopy 8 '&Copy' 9351 1 nil nil nil 6098 1 6130 #editPaste 8 '&Paste' 9389 1 nil nil nil 6098 1 6130 #editDelete 8 '&Delete' 1629 1 nil nil nil 6226 4097 6098 1 6130 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 6226 4097 6098 1 6130 #editFind 8 '&Find...' 9357 1 nil nil nil 6098 1 6130 #editFindNext 8 'Find &Next' 1253 1 nil nil nil 6098 1 6130 #editReplace 8 '&Replace...' 9361 1 nil nil nil 6226 4097 6098 1 6130 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 6098 1 6130 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 6098 1 6130 #jadeExecute 8 '&Execute' 9355 1 nil nil nil 6098 1 6130 #jadeDebug 8 'Debug' 9349 1 nil nil nil 6098 1 6130 #fileIn 8 'Fi&le In' 1 1 nil nil nil 6226 4097 6098 1 6130 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 6098 1 6130 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 8 '&Edit' nil 1 nil nil 13535 nil nil 6050 nil true 34 12 6098 1 6130 #abortTransaction 8 '&Abort Transaction' 1 1 nil nil nil 6098 1 6130 #commitTransaction 8 '&Commit Transaction' 1 1 nil nil nil 6098 1 6130 #disableNativeCode 8 'Disable Native Code' 1 1 nil nil nil 6226 4097 6098 1 6130 #inspectOop 8 'Inspect Oop ...' 1 1 nil nil nil 6098 1 6130 #describeErrorNumber 8 'Description for Error Number ...' 1025 1 nil nil nil 6226 4097 6098 1025 6130 #flipTranscript 8 'Transcript writes enabled' 1025 1 nil nil nil 6098 1025 6130 #flipAutoCommit 8 'AutoCommit enabled' 1025 1 nil nil nil 6098 1025 6130 #flipBreakpointsEnabled 8 'Breakpoints enabled' 1025 1 nil nil nil 6098 1025 6130 #flipAutocomplete 8 'Autocomplete enabled' 1025 1 nil nil nil 6098 1025 6130 #flipLogging 8 'Logging Enabled' 1025 1 nil nil nil 8 '&Jadeite' nil 1 nil nil 13557 nil nil 6050 nil true 34 14 6098 1 6130 #openJadeiteProjectsBrowser 8 'Browse &Projects' 9377 1 nil nil nil 6098 1 6130 #browseProcesses 8 'Browse P&rocesses' 9381 1 nil nil nil 6098 1 6130 #jadeBrowseTests 8 'Browse SUnit &Tests' 1 1 nil nil nil 6226 4097 6098 1 6130 #browseClass 8 'Find Class ...' 13453 1 nil nil nil 6098 1 6130 #browseClassReferences 8 'Browse &Class References ...' 13447 1 nil nil nil 6098 1 6130 #browseImplementorsOf 8 'Browse &Implementors of ...' 13459 1 nil nil nil 6098 1 6130 #browseSendersOf 8 'Browse &Senders of ...' 13479 1 nil nil nil 6098 1 6130 #browseMethodsContaining 8 'Browse &Methods Containing ...' 1 1 nil nil nil 6098 1 6130 #browseLiteralReferences 8 'Browse &Literal References ...' 1 1 nil nil nil 6098 1 6130 #browseBreakpoints nil 1 1 nil nil nil 6226 4097 6098 1025 6130 #browseJadeiteLogs 8 'Browse Logs' 1025 1 nil nil nil 6098 1025 6130 #browseJadeitePrefs 8 'Browse Preferences File' 1025 1 nil nil nil 8 '&Browse' nil 134217729 nil nil 13583 nil nil 6050 nil true 34 4 6098 1 6130 #openGitHubJadeiteProject 8 '&Jadiete GitHub Project' 1025 1 nil nil nil 6098 1 6130 #openGitHubRowanProject 8 '&Rowan GitHub Project' 1025 1 nil nil nil 6226 4097 6098 1 6130 #aboutJadeite 8 '&About Jadeite' 1 1 nil nil nil 8 '&Help' nil 1 nil nil 13591 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons\GS32.ico' nil 12306 nil true 12352 8 'icons\GS16.ico' nil nil nil 1 nil nil 914 138 144 34 3 978 #createAt:extent: 34 2 514 6793 21 514 1201 851 416 978 #text: 34 1 8 'Jadeite Session' 416 978 #updateMenuBar 4032 416 1106 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 68 13 0 0 10 0 0 0 156 15 0 0 179 1 0 0] 34 4 3792 4096 1520 608 1168 nil 27 )!

showOnSession: aGciSession
	| theTranscript |
	theTranscript := super showOnSession: aGciSession.
	theTranscript setTransactionModeFromServer.
	^theTranscript! !
!JadeiteTranscript class categoriesFor: #resource_Default_view!public!resources-views! !
!JadeiteTranscript class categoriesFor: #showOnSession:!instance creation!public! !

