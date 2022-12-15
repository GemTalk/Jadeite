"Filed out from Dolphin Smallalk"!

JadeTranscript subclass: #JadeiteTranscript
	instanceVariableNames: 'projectListPresenter isTranscriptInstalled autoCommit areBreakpointsEnabled autoCompleteEnabled transactionModePresenter lastKnownTransaction cardContainer'
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

basicOpenServerFile: filePath
	^JadeiteServerFileWorkspace showOnSession: gciSession path: filePath!

basicSetFont: newFont
	JadeitePreferences displayFontFrom: newFont.
	JadeitePreferences current currentFont: newFont!

basicSetTextFont: newFont
	JadeiteScintillaView allInstances do: [:scintillaView | scintillaView font: newFont].
	JadeitePreferences current currentTextFont: newFont!

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

cardContainer
	^cardContainer!

cardContainer: anObject
	cardContainer := anObject!

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
	transactionModePresenter model: (self aspectValue: #transactionMode).
	cardContainer := self add: Presenter new name: 'cardContainer'. "for testing"!

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

jadeiteHelpFileCSSExtension
	"for testing"

	^'.css'!

jadeiteHelpFileExtension
	^'.html'!

jadeiteHelpFileName
	^self jadeiteHelpFileNameRoot , self jadeiteHelpFileExtension!

jadeiteHelpFileNameRoot
	^'JadeiteHelp'!

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

openJadeiteHelpFile
	^ShellLibrary default shellOpen: self jadeiteHelpFileName
		directory: SessionManager current installationDirectory, 'Help\'!

openJadeiteProjectsBrowser
	projectListPresenter hasSelection
		ifTrue: [^projectListPresenter browseProject]
		ifFalse: 
			[gciSession hasServer ifTrue: [^(JadeiteBrowser showOnSession: gciSession)].
			MessageBox warning: 'Cannot open Jadeite Projects browser'
				caption: 'Cannot open Jadeite Projects browser']!

openServerFile
	| filePath |
	filePath := JadeiteServerFileSelectorDialog showOnSession: gciSession
				defaultPath: JadePresenter rowanProjectsHomeEnvVarString.
	filePath ifNil: [^self].
	^self basicOpenServerFile: filePath!

projectListPresenter
	^projectListPresenter!

queryCommand: aCommandQuery
	super queryCommand: aCommandQuery.
	aCommandQuery commandSymbol = #loadProject
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
			^true].
	aCommandQuery commandSymbol = #fileSave
		ifTrue: 
			[aCommandQuery isEnabled: codePane view hasFocus .
			^true].
	aCommandQuery commandSymbol = #fileSaveAs
		ifTrue: 
			[aCommandQuery isEnabled: codePane view hasFocus .
			^true]!

refreshFromServer
	projectListPresenter refreshFromServer.
	projectListPresenter invalidate!

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

resetFonts
	JadeitePreferences current resetFont.
	JadeitePreferences current resetTextFont!

resetTransactionModeRadioButtons
	#(#autoBegin #manualBegin #transactionless)
		do: [:aSymbol | (transactionModePresenter view viewNamed: aSymbol asString) displayValue: false].
	(transactionModePresenter view viewNamed: self transactionMode asString) displayValue: true!

setFont
	| newFont currentFont |
	currentFont := JadeitePreferences current currentFont ifNil: [JadeitePreferences defaultFont].
	newFont := FontDialog showModalOn: currentFont.
	newFont ifNil: [^self].
	self basicSetFont: newFont!

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

setTextFont
	| newFont currentFont |
	currentFont := JadeitePreferences current currentTextFont
				ifNil: [JadeitePreferences defaultTextFont].
	newFont := FontDialog showModalOn: currentFont.
	newFont ifNil: [^self].
	self basicSetTextFont: newFont!

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
basicOpenServerFile:!menu handlers support!private! !
basicSetFont:!menu handlers support!preferences!private! !
basicSetTextFont:!menu handlers support!preferences!private! !
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
cardContainer!accessing!private! !
cardContainer:!accessing!private! !
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
jadeiteHelpFileCSSExtension!constants!public! !
jadeiteHelpFileExtension!constants!public! !
jadeiteHelpFileName!constants!public! !
jadeiteHelpFileNameRoot!constants!public! !
lastKnownTransaction!accessing!private! !
onCloseRequested:!event handling!public! !
onViewClosed!event handling!public! !
onViewOpened!event handling!public! !
openDictionaryBrowser!menu handlers!public! !
openGitHubJadeiteProject!event handling!menu handlers!public! !
openGitHubRowanProject!event handling!menu handlers!public! !
openJadeiteHelpFile!menu handlers!public! !
openJadeiteProjectsBrowser!menu handlers!public! !
openServerFile!menu handlers!public! !
projectListPresenter!accessing!public! !
queryCommand:!private! !
refreshFromServer!menu handlers!public! !
registerPresentersForUpdates!public!register presenters! !
reloadProject!menu handlers!public! !
remoteAutoCommit!accessing!private! !
resetFonts!menu handlers!preferences!public! !
resetTransactionModeRadioButtons!accessing!public!transaction mode! !
setFont!menu handlers!preferences!public! !
setRowanProjectsHome!menu handlers!public! !
setRowanProjectsHome:!actions!public! !
setRowanProjectsHomeIfNecessary:!actions!public! !
setTextFont!menu handlers!preferences!public! !
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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1201 851 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 8 410 ##(Smalltalk.ReferenceView) 34 14 nil 416 34 2 8 1140850688 131073 592 nil nil nil 7 nil nil nil 592 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeToolsToolBarPresenter) #resource_Default_view nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 1 1 498 1169 51 592 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 25 0 0 0] 8 #() 498 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 946 #relativeParentWidth 3 946 #fixedParentTop 1 946 #fixedViewTop 51 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140916224 132097 1024 nil 480 nil 7 nil nil nil 1024 530 170 176 34 8 410 ##(Smalltalk.RadioButton) 34 16 nil 1024 34 2 8 1141058825 1 1136 721990 2 ##(Smalltalk.ValueHolder) nil nil 1376774 ##(Smalltalk.PluggableSearchPolicy) 459270 ##(Smalltalk.Message) #= 8 #() 1266 #hash 8 #() false 480 nil 7 nil nil nil 1136 nil 8 1607683504 852486 ##(Smalltalk.NullConverter) nil nil nil 690 138 144 34 2 754 #createAt:extent: 34 2 498 581 3 498 233 41 1136 754 #text: 34 1 8 'Manual' 1136 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 34 1 0 0 1 0 0 0 150 1 0 0 21 0 0 0] 8 #() 896 nil 27 914 976 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 224 63 976 1618 8 102 102 102 102 102 102 230 63 946 #fixedParentBottom -39 1664 1 410 ##(Smalltalk.StaticText) 34 16 nil 1024 34 2 8 1140850945 65 1680 nil 480 nil 7 nil nil nil 1680 nil 8 1607531712 1362 nil nil nil 690 138 144 34 2 754 #createAt:extent: 34 2 498 1 3 498 383 41 1680 754 #text: 34 1 8 'Transaction Mode:
Transaction Mode:' 1680 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 1 0 0 0 191 0 0 0 21 0 0 0] 8 #() 896 nil 27 914 976 1 976 1618 8 31 133 235 81 184 30 213 63 1664 -39 1664 1 410 ##(Smalltalk.RadioButton) 34 16 nil 1024 34 2 8 1141058825 1 2016 1202 nil nil 1234 1266 #= 8 #() 1266 #hash 8 #() false 480 nil 7 nil nil nil 2016 nil 8 1607683504 1362 nil nil nil 690 138 144 34 2 754 #createAt:extent: 34 2 498 383 3 498 199 41 2016 754 #text: 34 1 8 'Auto' 2016 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 191 0 0 0 1 0 0 0 34 1 0 0 21 0 0 0] 8 #() 896 nil 27 914 976 1618 8 31 133 235 81 184 30 213 63 976 1618 8 0 0 0 0 0 0 224 63 1664 -39 1664 1 410 ##(Smalltalk.RadioButton) 34 16 nil 1024 34 2 8 1141058825 1 2464 1202 nil nil 1234 1266 #= 8 #() 1266 #hash 8 #() false 480 nil 7 nil nil nil 2464 nil 8 1607683504 1362 nil nil nil 690 138 144 34 2 754 #createAt:extent: 34 2 498 813 3 498 349 41 2464 754 #text: 34 1 8 'Transactionless' 2464 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 150 1 0 0 1 0 0 0 68 2 0 0 21 0 0 0] 8 #() 896 nil 27 914 976 1618 8 102 102 102 102 102 102 230 63 976 3 1664 -39 1664 1 170 192 34 6 2016 8 'autoBegin' 2464 8 'transactionless' 1136 8 'manualBegin' nil 690 138 144 34 1 754 #createAt:extent: 34 2 498 1 633 498 1169 51 1024 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 60 1 0 0 72 2 0 0 85 1 0 0] 34 4 1680 2016 1136 2464 896 nil 27 914 960 1 946 #fixedParentRight 1 1664 -99 1664 -49 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1140850688 131073 3168 nil 480 nil 7 nil nil nil 3168 656710 1 ##(Smalltalk.CardLayout) 138 144 34 7 721414 ##(Smalltalk.Association) 8 'Workspace' 410 ##(Smalltalk.ReferenceView) 34 14 nil 3168 34 2 8 1140850688 131073 3344 nil 480 nil 5 nil nil nil 3344 658 ##(Smalltalk.CodeSourcePresenter) #resource_Default_view nil 690 138 144 34 1 754 #createAt:extent: 34 2 498 9 53 498 1153 523 3344 834 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 68 2 0 0 31 1 0 0] 880 896 nil 27 3298 8 'My Session' 410 ##(Smalltalk.ReferenceView) 34 14 nil 3168 34 2 8 1140850688 131073 3600 nil nil nil 5 nil nil nil 3600 658 ##(Smalltalk.MySessionPresenter) #resource_Default_view nil 690 138 144 34 1 754 #createAt:extent: 34 2 498 9 53 498 1153 523 3600 834 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 68 2 0 0 31 1 0 0] 880 896 nil 27 3298 8 'All Sessions' 410 ##(Smalltalk.ReferenceView) 34 14 nil 3168 34 2 8 1140850688 131073 3856 nil nil nil 5 nil nil nil 3856 658 ##(Smalltalk.AllSessionsPresenter) #resource_Default_view nil 690 138 144 34 1 754 #createAt:extent: 34 2 498 9 53 498 1153 523 3856 834 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 68 2 0 0 31 1 0 0] 880 896 nil 27 3298 8 'Transcript' 410 ##(Smalltalk.ReferenceView) 34 14 nil 3168 34 2 8 1140916224 131073 4112 nil 480 nil 5 nil nil nil 4112 658 ##(Smalltalk.TranscriptPresenter) #resource_Default_view nil 690 138 144 34 1 754 #createAt:extent: 34 2 498 9 53 498 1153 523 4112 834 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 68 2 0 0 31 1 0 0] 880 896 nil 27 3298 8 'History' 410 ##(Smalltalk.MultilineTextEdit) 34 16 nil 3168 34 2 8 1143017796 1025 4368 nil 480 nil 5 nil nil nil 4368 nil 8 1607675312 1362 nil nil 11 690 138 144 34 2 754 #createAt:extent: 34 2 498 9 53 498 1153 523 4368 754 #setMarginWidths: 34 1 8 #(3 3) 4368 834 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 68 2 0 0 31 1 0 0] 8 #() 896 nil 27 3298 ##(Smalltalk.Stone) 410 ##(Smalltalk.ReferenceView) 34 14 nil 3168 34 2 8 1140850688 131073 4688 nil nil nil 5 nil nil nil 4688 658 ##(Smalltalk.StoneInfoPresenter) #resource_Default_view nil 690 138 144 34 1 754 #createAt:extent: 34 2 498 9 53 498 1153 523 4688 834 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 68 2 0 0 31 1 0 0] 880 896 nil 27 3298 8 'Projects' 410 ##(Smalltalk.ShellView) 34 27 nil 3168 34 2 8 1078919168 131073 4944 nil 480 498 1201 801 551 nil nil nil 4944 1180166 ##(Smalltalk.ProportionalLayout) 170 176 880 false 170 192 34 2 410 ##(Smalltalk.ListView) 34 45 nil 4944 34 2 8 1140920649 1025 5104 590662 2 ##(Smalltalk.ListModel) 138 144 880 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 nil nil nil 5104 nil 8 1607618784 ##(Smalltalk.BasicListAbstract) nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 3 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Project Name' 371 #left 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 5376 8 'doIt' 8 '[:project | project displayName]' 8 #[30 105 226 0 106] #displayName 5392 7 257 nil ##(Smalltalk.SortedCollection) nil nil 5104 nil 3 5378 0 nil 5410 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 5488 7 257 nil 5378 0 nil 5410 3 1 5376 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 5568 7 257 nil false nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 5664 1202 nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 5664 nil nil 1362 nil 8 '' 3 nil nil nil nil nil nil nil nil nil 5330 8 'Loaded Sha' 373 #left 5378 0 nil 5410 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:project | project sha]' 8 #[30 105 226 0 106] #sha 5808 7 257 nil 1266 #<= 8 #() nil nil 5104 nil 3 5378 0 nil 5410 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 5920 7 257 nil nil false nil 5650 nil nil 8 #(67174528 0) 6000 1202 nil false 5728 nil 480 nil 5 nil nil nil 6000 nil nil 1362 nil 8 '' 3 nil nil nil nil nil nil nil nil nil 5330 8 'Branch' 371 #left 5378 0 nil 5410 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:project | project branch]' 8 #[30 105 226 0 106] #branch 6112 7 257 nil 1266 #<= 5904 nil nil 5104 nil 3 5378 0 nil 5410 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 6208 7 257 nil nil false nil 5650 nil nil 8 #(67174528 0) 6288 1202 nil false 5728 nil 480 nil 5 nil nil nil 6288 nil nil 1362 nil 8 '' 3 nil nil nil nil nil nil nil nil nil #report 8 #() nil 133219 498 129 129 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 690 138 144 34 2 754 #createAt:extent: 34 2 498 1 1 498 1121 491 5104 754 #text: 34 1 8 'Project Name' 5104 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 48 2 0 0 245 0 0 0] 8 #() 896 nil 35 8 'projectList' nil nil nil nil nil 1 nil nil nil nil 1 nil nil 690 138 144 34 2 754 #createAt:extent: 34 2 498 9 53 498 1153 523 4944 754 #text: 34 1 8 'Rowan Project List' 4944 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 68 2 0 0 31 1 0 0] 34 1 5104 896 nil 27 4944 nil nil nil 170 192 34 14 3600 8 'My Session' 4944 8 'projectsList' 4112 8 'Transcript' 4368 8 'history' 4688 8 'Stone' 3856 8 'All Sessions' 3344 8 'codePane' nil 410 ##(Smalltalk.TabView) 34 23 nil 3168 34 2 8 1140916736 1 6976 5170 138 144 34 7 4096 4352 ##(Smalltalk.Stone) 3584 3840 3328 4928 nil 5232 466 #face3d nil 1 nil nil nil 6976 nil 8 1607388928 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 5280 nil nil nil nil nil #noIcons 690 138 144 34 3 754 #createAt:extent: 34 2 498 1 1 498 1169 583 6976 754 #setSingleSelection: 8 #(7) 6976 754 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 6976 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 35 1 0 0] 8 #() 896 nil 27 690 138 144 34 1 754 #createAt:extent: 34 2 498 1 51 498 1169 583 3168 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 72 2 0 0 60 1 0 0] 34 8 4112 4368 4688 3600 3856 3344 4944 6976 896 nil 27 914 960 1 3152 1 992 51 1664 -99 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 7520 nil 480 nil 7 nil nil nil 7520 530 170 176 34 2 410 ##(Smalltalk.StaticText) 34 16 nil 7520 34 2 8 1140855041 262209 7632 nil 480 nil 7 nil nil nil 7632 196934 1 ##(Smalltalk.RGB) 10921639 8 1607531712 1362 nil nil nil 690 138 144 34 2 754 #createAt:extent: 34 2 498 1 1 498 1169 51 7632 754 #text: 34 1 8 'Static Text' 7632 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 25 0 0 0] 8 #() 896 nil 27 914 960 1 3152 1 1664 -49 1664 1 170 192 34 2 7632 8 'lastKnownTransaction' 590342 ##(Smalltalk.Rectangle) 498 1 1 498 1 1 690 138 144 34 1 754 #createAt:extent: 34 2 498 1 683 498 1169 51 7520 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 85 1 0 0 72 2 0 0 110 1 0 0] 34 1 7632 896 nil 27 914 960 1 3152 1 1664 -49 1664 1 170 192 34 6 3168 8 'cardContainer' 1024 8 'transactionMode' 592 8 'Toolbar' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 5 265030 4 ##(Smalltalk.Menu) nil true 34 10 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #fileNew 8 '&New Workspace' 9373 1 nil nil nil 8450 1 8482 #fileOpen 8 '&Open Client File ...' 9375 1 nil nil nil 8450 1 8482 #openServerFile 8 '&Open Server File ...' 1025 1 nil nil nil 8450 1 8482 #fileIn 8 'File In Server File ...' 1 1 nil nil nil 8450 1 8482 #fileSave 8 '&Save' 9383 1 nil nil nil 8450 1 8482 #fileSaveAs 8 'Save &As...' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 8450 1 8482 #resetCursor 8 'Reset &Cursor' 1025 1 nil nil nil 8770 4097 8450 1 8482 #exit 8 'E&xit Jadeite' 17639 1 nil nil nil 8 '&File' nil 1 nil nil 9085 nil nil 8402 nil true 34 22 8450 1 8482 #undo 8 '&Undo' 9397 1 nil nil nil 8450 1 8482 #redo 8 'R&edo' 9395 1 nil nil nil 8770 4097 8450 1 8482 #editCut 8 'Cu&t' 9393 1 nil nil nil 8450 1 8482 #editCopy 8 '&Copy' 9351 1 nil nil nil 8450 1 8482 #editPaste 8 '&Paste' 9389 1 nil nil nil 8450 1 8482 #editDelete 8 '&Delete' 1629 1 nil nil nil 8770 4097 8450 1 8482 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 8770 4097 8450 1 8482 #editFind 8 '&Find...' 9357 1 nil nil nil 8450 1 8482 #editFindNext 8 'Find &Next' 1253 1 nil nil nil 8450 1 8482 #editReplace 8 '&Replace...' 9361 1 nil nil nil 8770 4097 8450 1 8482 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 8450 1 8482 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 8450 1 8482 #jadeExecute 8 '&Execute' 9355 1 nil nil nil 8450 1 8482 #jadeDebug 8 'Debug' 9349 1 nil nil nil 8450 1 8482 #fileIn 8 'Fi&le In' 1 1 nil nil nil 8770 4097 8450 1 8482 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 8450 1 8482 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 8 '&Edit' nil 1 nil nil 9121 nil nil 8402 nil true 34 18 8450 1 8482 #abortTransaction 8 '&Abort Transaction' 1 1 nil nil nil 8450 1 8482 #commitTransaction 8 '&Commit Transaction' 1 1 nil nil nil 8450 1 8482 #begin 8 'Begin Transaction' 1 1 nil nil nil 8450 1 8482 #disableNativeCode 8 'Disable Native Code' 1 1 nil nil nil 8770 4097 8450 1 8482 #inspectOop 8 'Inspect Oop ...' 1 1 nil nil nil 8450 1 8482 #describeErrorNumber 8 'Description for Error Number ...' 1025 1 nil nil nil 8450 1 8482 #setRowanProjectsHome 8 'Set Rowan Projects Home ...' 1 1 nil nil nil 8770 4097 8450 1 8482 #resetFonts nil 1 1 nil nil nil 8450 1 8482 #setFont 8 'Set Font...' 1 1 nil nil nil 8450 1 8482 #setTextFont 8 'Set Text Font...' 1 1 nil nil nil 8770 4097 8450 1025 8482 #flipTranscript 8 'Transcript writes enabled' 1025 1 nil nil nil 8450 1025 8482 #flipAutoCommit 8 'AutoCommit enabled' 1025 1 nil nil nil 8450 1025 8482 #flipBreakpointsEnabled 8 'Breakpoints enabled' 1025 1 nil nil nil 8450 1025 8482 #flipAutocomplete 8 'Autocomplete enabled' 1025 1 nil nil nil 8450 1025 8482 #flipLogging 8 'Logging Enabled' 1025 1 nil nil nil 8 '&Jadeite' nil 1 nil nil 9153 nil nil 8402 nil true 34 14 8450 1 8482 #openJadeiteProjectsBrowser 8 'Browse &Projects' 9377 1 nil nil nil 8450 1 8482 #browseProcesses 8 'Browse P&rocesses' 9381 1 nil nil nil 8450 1 8482 #jadeBrowseTests 8 'Browse SUnit &Tests' 1 1 nil nil nil 8770 4097 8450 1 8482 #browseClass 8 'Find Class ...' 13453 1 nil nil nil 8450 1 8482 #browseClassReferences 8 'Browse &Class References ...' 13447 1 nil nil nil 8450 1 8482 #browseImplementorsOf 8 'Browse &Implementors of ...' 13459 1 nil nil nil 8450 1 8482 #browseSendersOf 8 'Browse &Senders of ...' 13479 1 nil nil nil 8450 1 8482 #browseMethodsContaining 8 'Browse &Methods Containing ...' 1 1 nil nil nil 8450 1 8482 #browseLiteralReferences 8 'Browse &Literal References ...' 1 1 nil nil nil 8450 1 8482 #browseBreakpoints nil 1 1 nil nil nil 8770 4097 8450 1025 8482 #browseJadeiteLogs 8 'Browse Logs' 1025 1 nil nil nil 8450 1025 8482 #browseJadeitePrefs 8 'Browse Preferences File' 1025 1 nil nil nil 8 '&Browse' nil 134217729 nil nil 9179 nil nil 8402 nil true 34 5 8450 1 8482 #openGitHubJadeiteProject 8 '&Jadiete GitHub Project' 1025 1 nil nil nil 8450 1 8482 #openGitHubRowanProject 8 '&Rowan GitHub Project' 1025 1 nil nil nil 8770 4097 8450 1 8482 #aboutJadeite 8 '&About Jadeite' 1 1 nil nil nil 8450 1 8482 #openJadeiteHelpFile 8 'Jadeite Help' 1025 1 nil nil nil 8 '&Help' nil 1 nil nil 9189 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons\GS32.ico' nil 11586 nil true 11632 8 'icons\GS16.ico' nil nil nil 1 nil nil 690 138 144 34 2 754 #createAt:extent: 34 2 498 6987 21 498 1201 851 416 754 #text: 34 1 8 'Jadeite Session' 416 834 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 165 13 0 0 10 0 0 0 253 15 0 0 179 1 0 0] 34 4 592 3168 1024 7520 896 nil 27 )!

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

