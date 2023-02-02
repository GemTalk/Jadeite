"Filed out from Dolphin Smallalk"!

JadeiteAbstractTestCase subclass: #JadeiteMiscellaneousTestCase
	instanceVariableNames: 'workspace'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteMiscellaneousTestCase guid: (GUID fromString: '{3f3dd3e4-13f5-42ea-b424-b89439a9b357}')!
JadeiteMiscellaneousTestCase comment: ''!
!JadeiteMiscellaneousTestCase categoriesForClass!Unclassified! !
!JadeiteMiscellaneousTestCase methodsFor!

tearDown
	super tearDown.
	workspace
		ifNotNil: 
			[workspace codePane documentPresenter view isModified: false.
			self destroy: workspace]!

test_adHocCompileError
	self testsIssue: #issue688 withTitle: '(3.0.92) Compile Errors in Workspace broken'.
	workspace := JadeWorkspace showOnSession: session.
	workspace setDocumentData: '#(1 2'.
	workspace codePane documentPresenter setFocus.
	workspace codePane jadeExecute.
	self assert: workspace codePane documentPresenter value equals: '#(1 2expected a right parenthesis'!

test_adHocDisplay
	self testsIssue: #issue427 withTitle: '(3.0.60) autocommit not done after successful doits'.
	workspace := JadeWorkspace showOnSession: session.
	self assert: (workspace isKindOf: JadeWorkspace).
	workspace setDocumentData: '123'.
	workspace codePane documentPresenter setFocus.
	workspace codePane jadeDisplay.
	self assert: workspace codePane documentPresenter value equals: '123 123'!

test_adHocExecute
	self testsIssue: #issue427 withTitle: '(3.0.60) autocommit not done after successful doits'.
	workspace := JadeWorkspace showOnSession: session.
	self assert: (workspace isKindOf: JadeWorkspace).
	session executeString: 'UserGlobals removeKey: #foo ifAbsent:[]'.
	workspace setDocumentData: 'UserGlobals at: #foo put: ''bar'''.
	workspace codePane documentPresenter setFocus.
	workspace codePane jadeExecute.
	self assert: workspace codePane documentPresenter value equals: 'UserGlobals at: #foo put: ''bar'''.
	self assert: (session executeString: 'UserGlobals at: #foo') equals: 'bar'!

test_autoCommitDoesNotMakeRoundTripWhenOpeningBrowser
	"Not a very good test but the last service logged should not be an #updateAutoCommit command which was the bug"

	| loggingState |
	loggingState := BrowserUpdate current isLogging.
	BrowserUpdate current isLogging: true.
	
	[projectsBrowser
		ifNil: [projectsBrowser := self openWindow: [transcript openJadeiteProjectsBrowser]].
	
	[BrowserUpdate current loggingService services
		do: [:service | self deny: (service updateType includes: #updateAutoCommit)]]
			ensure: [self destroy: projectsBrowser]]
			ensure: [BrowserUpdate current isLogging: loggingState]!

test_autoCommitInAdHocDisplay
	| workspace |
	self testsIssue: #issue427 withTitle: '(3.0.60) autocommit not done after successful doits'.
	
	[self setAutoCommit: true.
	session executeString: 'UserGlobals at: #TestCommit put: true'.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	workspace := JadeWorkspace showOnSession: session.
	workspace setDocumentData: '123'.
	workspace codePane documentPresenter setFocus.
	workspace codePane jadeDisplay.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self abortTransaction.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self assert: workspace codePane documentPresenter value equals: '123 123']
			ensure: 
				[session executeString: 'UserGlobals removeKey: #TestCommit'.
				self commitTransaction.
				self setAutoCommit: false.
				workspace isModified: false.
				workspace view close]!

test_autoCommitInAdHocExecution
	| workspace |
	self testsIssue: #issue427 withTitle: '(3.0.60) autocommit not done after successful doits'.
	
	[self setAutoCommit: true.
	session executeString: 'UserGlobals at: #TestCommit put: true'.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	workspace := JadeWorkspace showOnSession: session.
	workspace setDocumentData: '''doSomething'''.
	workspace codePane documentPresenter setFocus.
	workspace codePane jadeExecute.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self abortTransaction.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]')	"TestCommit was committed"]
			ensure: 
				[session executeString: 'UserGlobals removeKey: #TestCommit'.
				self commitTransaction.
				self setAutoCommit: false.
				workspace isModified: false.
				workspace view close]!

test_autoCommitOffInAdHocDisplay
	self testsIssue: #issue427 withTitle: '(3.0.60) autocommit not done after successful doits'.
	
	[self setAutoCommit: false.
	session executeString: 'UserGlobals at: #TestCommit put: true'.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	workspace := JadeWorkspace showOnSession: session.
	workspace setDocumentData: '123'.
	workspace codePane documentPresenter setFocus.
	workspace codePane jadeDisplay.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self abortTransaction.
	self assertIsNil: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self assert: workspace codePane documentPresenter value equals: '123 123']
			ensure: 
				[workspace isModified: false.
				workspace view close]!

test_autoCommitOffInAdHocExecution
	| workspace |
	self testsIssue: #issue427 withTitle: '(3.0.60) autocommit not done after successful doits'.
	
	[self setAutoCommit: false.
	session executeString: 'UserGlobals at: #TestCommit put: true'.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	workspace := JadeWorkspace showOnSession: session.
	workspace setDocumentData: '''doSomething'''.
	workspace codePane documentPresenter setFocus.
	workspace codePane jadeExecute.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self abortTransaction.
	self assertIsNil: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]')]
			ensure: 
				[workspace isModified: false.
				workspace view close]!

test_autoCommitUpdatedInSession
	| autoCommit |
	
	[autoCommit := session autoCommit.
	self setAutoCommit: true.
	self assert: session autoCommit.
	self setAutoCommit: false.
	self deny: session autoCommit]
			ensure: [self setAutoCommit: autoCommit]!

test_autocompleteCaseInsensitiveSearch
	self testsIssue: #issue660
		withTitle: 'Class autocomplete is not case insensitive (fix #636 not complete in 3.0.91)'.
	JadeiteSearch initializeAutocompleteSymbolsIn: session.
	JadeiteSearch autoCompleteEnabled: true.
	self assert: ((JadeiteSearch new allClassesStartingWith: 'cp') includes: 'CPointer').
	self assert: ((JadeiteSearch new allClassesStartingWith: 'cp') includes: 'CPreprocessor').
	self assert: ((JadeiteSearch new allClassesStartingWith: 'e') includes: 'Error').
	self assert: ((JadeiteSearch new allClassesStartingWith: 'rowanan') includes: 'RowanAnsweringService')!

test_autocompleteClearsSymbolsOnLogout
	JadeiteSearch initializeAutocompleteSymbolsIn: session.
	self deny: JadeiteSearch allClassNames isEmpty.
	self deny: JadeiteSearch allSelectorSymbols isEmpty.
	TestMessageBox
		enableJadeiteTestMessageBox;
		plannedResult: #no.
	
	[
	[self destroy: transcript.
	self verifyWindowClosed: transcript]
			ensure: [TestMessageBox disableJadeiteTestMessageBox].
	self assert: JadeiteSearch allClassNames isEmpty.
	self assert: JadeiteSearch allSelectorSymbols isEmpty]
			ensure: [self ensureTestIsSetUpAfterLogout]!

test_autocompleteSaveClassSymbolAdded
	self testsIssue: #issue647 withTitle: 'Adding class doesn''t update autocomplete symbols'.
	self openProjectBrowser.
	JadeiteSearch initializeAutocompleteSymbolsIn: session.
	JadeiteSearch autoCompleteEnabled: true.
	self deny: (JadeiteSearch allClassNames includes: #TestCacheSaveClassName).
	self selectRowanSample1Test.
	self
		saveClass: 'TestCacheSaveClassName'
		superclass: 'Object'
		instVars: #()
		package: 'RowanSample1-Tests'.
	[self assert: (JadeiteSearch allClassNames includes: 'TestCacheSaveClassName')] ensure: 
			[self assert: self projectsPresenter selectedClass name equals: 'TestCacheSaveClassName'.
			self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass.
			JadeiteSearch allClassNames remove: 'TestCacheSaveClassName'.	"for test reruns"
			projectsBrowser view close.
			projectsBrowser := nil]!

test_autocompleteSaveMethodSymbolAdded
	self openProjectBrowser.
	JadeiteSearch initializeAutocompleteSymbolsIn: session.
	JadeiteSearch autoCompleteEnabled: true.
	self deny: (JadeiteSearch allSelectorSymbols includes: #test_autocompleteSaveMethodSymbolAdded).
	self selectRowanSample1Test.
	self
		saveMethod: 'test_autocompleteSaveMethodSymbolAdded  ^''temp method to delete'''
		in: 'RowanSample1Test'
		category: 'other'.
	[self assert: (JadeiteSearch allSelectorSymbols includes: #test_autocompleteSaveMethodSymbolAdded)]
		ensure: 
			[JadeiteSearch allSelectorSymbols remove: #test_autocompleteSaveMethodSymbolAdded.	"for test reruns"
			projectsBrowser view close.
			projectsBrowser := nil]!

test_autocompleteSort
	"shortest first"

	| search |
	search := JadeiteSearch new.
	self assert: (search sortForAutoCompletion: #('aaaaa' 'bbbb' 'ccc' 'dd')) asArray
		equals: #('dd' 'ccc' 'bbbb' 'aaaaa')!

test_autocompleteSymbolsNotAddedToIfAutocompleteOff
	self testsIssue: #issue732 withTitle: 'Wildcard method search broken if autcomplete off '.
	JadeiteSearch initializeAutocompleteSymbolsIn: session.
	JadeiteSearch autoCompleteEnabled: false.
	self assert: JadeiteSearch allSelectorSymbols isEmpty.
	self
		saveMethod: 'covid  ^19'
		in: 'RowanSample1'
		category: 'deleteme'.
	self assert: JadeiteSearch allSelectorSymbols isEmpty.	"new symbol #covid not added"
	JadeiteSearch autoCompleteEnabled: true.
	JadeiteSearch initializeAutocompleteSymbolsIn: session.
	self assert: (JadeiteSearch allSelectorSymbols includes: #covid).	"picked up the new symbol"
	self deny: (JadeiteSearch allSelectorSymbols includes: #covid19).
	self
		saveMethod: 'covid19 ^#isHappeningNow'
		in: 'RowanSample1'
		category: 'deleteme'.
	self assert: (JadeiteSearch allSelectorSymbols includes: #covid19)!

test_classServiceNameIsString
	| classService |
	self testsIssue: #issue441
		withTitle: '(3.0.62) suspicious code in RowanClassService>>hierarchyClassServiceFor:'.
	classService := RowanClassService named: 'RowanClassServiceTest'.
	self assert: classService name isKindOf: String.
	classService := RowanClassService new name: 'RowanClassServiceTest'.
	self assert: classService name isKindOf: String!

test_convertToPattern
	| pattern |
	self testsIssue: #issue258
		withTitle: 'wildcard senders and implentors don''t return proper selection list'.
	pattern := JadePresenter convertToPattern: '*symboldict*'. 
	self assert: pattern equals: #('' $* 'symboldict' $*).
	pattern := JadePresenter convertToPattern: '*SymbolDict*'. 
	self assert: pattern equals: #('' $* 'SymbolDict' $*).
	pattern := JadePresenter convertToPattern: '*SymbolDict*:'. 
	self assert: pattern equals: #('' $* 'SymbolDict' $* ':').
	pattern := JadePresenter convertToPattern: 'symboldict*'. 
	self assert: pattern equals: #('symboldict' $*).
	!

test_createProjectEditorCreateProject
	| editor presenter newProjectServiceInTranscript newProjectServiceInBrowser |
	editor := JadeiteCreateProjectEditor showOnSession: session.
	
	[presenter := editor primaryPresenter.
	presenter propertyList list first at: 2 put: 'Test_createProjectEditorCreateProject'.
	editor createProject.
	projectsBrowser := presenter browser.
	newProjectServiceInTranscript := transcript projectListPresenter projectListPresenter list
				detect: [:projectService | projectService name = #Test_createProjectEditorCreateProject]
				ifNone: [].
	self denyIsNil: newProjectServiceInTranscript.
	newProjectServiceInBrowser := self projectsPresenter projectListPresenter list
				detect: [:projectService | projectService name = #Test_createProjectEditorCreateProject]
				ifNone: [].
	self denyIsNil: newProjectServiceInBrowser]
			ensure: 
				[self abortTransaction.
				newProjectServiceInBrowser := self projectsPresenter projectListPresenter list
							detect: [:projectService | projectService name = #Test_createProjectEditorCreateProject]
							ifNone: [].
				self assertIsNil: newProjectServiceInBrowser.
				self destroy: projectsBrowser]!

test_createProjectEditorProjectsChanged
	| editor presenter |
	editor := JadeiteCreateProjectEditor showOnSession: session.
	
	[presenter := editor primaryPresenter.
	self deny: presenter propertiesAreChanged.
	self assert: (presenter propertyList list first at: 1) equals: 'projectName'.
	presenter propertyList list first at: 2 put: 'Abc'.
	self assert: presenter propertiesAreChanged]
			ensure: 
				[TestMessageBox enableJadeiteTestMessageBox.
				TestMessageBox plannedResult: #yes.	"close anyway? message"
				editor cancel.
				TestMessageBox disableJadeiteTestMessageBox]!

test_dolphinStackDumpBanners
	| timestampString stream |
	self testsIssue: #issue237 withTitle: 'time stamp at end of Dolphin stack dump would be useful'.
	timestampString := JadeSessionManager stackDumpTimeStampString.
	stream := WriteStream on: String new.
	JadeSessionManager prependStackStartMessage: timestampString on: stream.
	self assert: ('*' , timestampString , '*' match: stream contents).
	self assert: ('*Starting Dolphin stack dump at*' match: stream contents).
	stream := WriteStream on: String new.
	JadeSessionManager appendStackEndMessage: timestampString on: stream.
	self assert: ('*' , timestampString , '*' match: stream contents).
	self assert: ('*Ending Dolphin stack dump started at*' match: stream contents).!

test_fileSaveDialog
	"not much of a test but at least we exercise the save button" 
	| dialog |
	dialog := JadeiteServerFileSaveTestDialog showOnSession: session
				initialFileName: 'test_fileSaveDialog.txt'.
	dialog fileNamePresenter value: 'test_fileSaveDialog.txt2'.
	dialog save.
	self assert: dialog fileNamePresenter value equals: 'test_fileSaveDialog.txt2'!

test_fileSaveDialogBasics
	| dialog priorDirectoryContents |
	
	[dialog := JadeiteServerFileSaveTestDialog showOnSession: session
				initialFileName: 'test_fileSaveDialogBasics.txt'.
	self assert: dialog isKindOf: JadeiteServerFileSaveDialog.
	self assert: dialog pathText value equals: self rowanProjectsHome.	"default to rowan projects home directory env var"
	self assert: dialog fileNamePresenter value equals: 'test_fileSaveDialogBasics.txt'.	"initial file name should be what was passed in"
	priorDirectoryContents := dialog fileSelectorPresenter directoryContentsList list
				collect: [:assoc | assoc key].
	dialog fileSelectorPresenter pop.
	self deny: priorDirectoryContents
		equals: (dialog fileSelectorPresenter directoryContentsList list collect: [:assoc | assoc key])	"no way to know the contents of the directory so just ensure the contents changed - lousy test"]
			ensure: [dialog cancel]!

test_fileSaveFromWorkspace
	| sourcePath targetPath |
	targetPath := 'testJadeiteFileSave.txt'.
	self deny: (session executeString: 'GsFile existsOnServer: ''' , targetPath , '''').
	sourcePath := '/export/gcm/where/gemstone64/releases/3.6.1/x86_64.Linux/fast/product/version.txt'.
	workspace := JadeiteServerFileWorkspace showOnSession: session path: sourcePath.
	
	[workspace writeDocumentTo: 'testJadeiteFileSave.txt'.
	self assert: (session executeString: 'GsFile existsOnServer: ''' , targetPath , '''')]
			ensure: [session executeString: 'GsFile removeServerFile: ''' , targetPath , '''']!

test_fileSaveWithUnicode
	| service |
	self testsIssue: #issue988
		withTitle: '[3.2.13] Saving a server text file with extended characters is not good'.
	self writeUnicodeFile.
	workspace := JadeiteServerFileWorkspace showOnSession: session
				path: '/export/uffda2/users/ewinger/logs//testJadeiteUnicodeFile.txt'.
	
	[self assert: workspace codePane documentPresenter value
		equals: 'This is some unicode text
  
ý š

Another extended char - Ü  aaa œ'
				replaceCrLfWithLf.
	workspace codePane documentPresenter value: 'ò ó ô õ ö ÷ ø ù ú û'.
	workspace saveDocument]
			ensure: [self destroy: workspace].
	workspace := JadeiteServerFileWorkspace showOnSession: session
				path: '/export/uffda2/users/ewinger/logs//testJadeiteUnicodeFile.txt'.
	self assert: workspace codePane documentPresenter value
		equals: 'ò ó ô õ ö ÷ ø ù ú û' replaceCrLfWithLf.
	service := RowanFileService new.
	service
		command: #deleteFileWithUnicode;
		commandArgs: Array new.
	service issueCommand: service session: session!

test_findInWorkspace
	| workspace findView documentPresenter |
	self testsIssue: #issue468 withTitle: 'Find text dialog does not highlight correctly'.
	workspace := JadeWorkspace showOnSession: session.
	
	[workspace model value: '1234


1254

124'.
	documentPresenter := workspace codePane documentPresenter.
	findView := workspace codePane documentPresenter view findPrompt: '12*4'.
	findView modePresenter value: #wildcardExpression.
	findView wrapPresenter value: true.
	findView findNext.
	self assert: documentPresenter selection equals: '1234'.
	findView findNext.
	self assert: documentPresenter selection equals: '1254'.
	findView findNext.	"Last one doesn't match pattern. wrap around finds first again"
	self assert: documentPresenter selection equals: '1234']
			ensure: 
				[workspace view close.
				findView view close]!

test_instVarConstants
	self assert: (RowanClassService indexOfInstVar: 'meta')
		equals: RowanClassService new indexOfMetaInstVar.
	self assert: (RowanClassService indexOfInstVar: 'methods')
		equals: RowanClassService new indexOfMethodsInstVar.
	self assert: (RowanMethodService indexOfInstVar: 'testResult')
		equals: RowanMethodService new indexOfTestResultInstVar.
	self assert: (RowanMethodService indexOfInstVar: 'firstReference')
		equals: RowanMethodService new indexOfFirstReferenceInstVar!

test_logoutFatalError
	self testsIssue: #issue858 withTitle: 'better gci error reporting is needed'.
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #ok.
	
	[
	[session
		executeString: 'UserGlobals at: #foo put: Array new. 

1 to: 10000000 do:[:index | 
	(UserGlobals at: #foo) add: ''abcdefghijklmno'', index printString]']
			on: GsFatalError
			do: 
				[:ex |
				"don't pass fatal error to outer handler (TestResult) so error doesn't get recorded. Default action will execute code that we're testing"
				[ex defaultAction] on: TerminateProcess
					do: 
						[:ex2 |
						"ignore terminate signal so test continues"
						]]]
			ensure: [TestMessageBox disableJadeiteTestMessageBox].
	self assert: ('VM temporary object memory is full* old space overflow*Shutting session down'
				match: TestMessageBox lastMessageBox text).
	self deny: session isValidSession!

test_methodServiceClassNameIsString
	| methodService |
	self testsIssue: #issue441
		withTitle: '(3.0.62) suspicious code in RowanClassService>>hierarchyClassServiceFor:'.
	methodService := RowanMethodService new
				selector: 'fnoodle';
				className: 'JadeiteMiscellaneousTestCase';
				meta: false.
	self assert: methodService className isKindOf: String.
	methodService := RowanMethodService new
				selector: 'fnoodle';
				className: #JadeiteMiscellaneousTestCase;
				meta: false.
	self assert: methodService className isKindOf: String!

test_releaseOops
	| remoteObject service |
	self testsIssue: #issue413 withTitle: '(3.0.56 & 3.0.62) running out vm memory quickly'.
	session releaseAllOops.
	self assert: (session executeString: 'System hiddenSetSize: 39') equals: 0.
	remoteObject := session executeString: 'Array new'.
	self assert: (session executeString: 'System hiddenSetSize: 39') = 1.
	session releaseAllOops.
	self assert: (session executeString: 'System hiddenSetSize: 39') equals: 0.
	remoteObject := session executeString: 'Dictionary new'.
	self assert: (session executeString: 'System hiddenSetSize: 39') = 1.
	service := RowanAnsweringService new.
	service command: #isTranscriptInstalled.
	self issueCommand: service.
	self assert: (session executeString: 'System hiddenSetSize: 39') equals: 0.
	remoteObject := session executeString: 'Object new'.
	self assert: (session executeString: 'System hiddenSetSize: 39') = 1.
	service := RowanProjectService new name: 'Rowan'.
	BrowserUpdate current updateServices: (Array with: service) session: session.
	self assert: (session executeString: 'System hiddenSetSize: 39') equals: 0.
	self auditAll!

test_returnedServices
	"sanity test that we can use the returned services in other tests" 

	workspace := JadeWorkspace showOnSession: session.
	self assert: (workspace isKindOf: JadeWorkspace).
	workspace setDocumentData: '123'.
	workspace codePane documentPresenter setFocus.
	workspace codePane jadeDisplay.
	self assert: workspace codePane documentPresenter value equals: '123 123'.
	self assert: BrowserUpdate current returnedServices size equals: 1. 
	self assert: (BrowserUpdate current returnedServices first isKindOf: RowanAnsweringService). 
	self assert: BrowserUpdate current returnedServices first answer equals: '123'!

test_serviceClassBookkeeping
	"All service classes should have an entry in`Rowan platform serviceClasses`. 
	Only SystemUser can reference rowan services classes directly so other users
	must use indirection to look up the class. Hence the necessity of this extra
	bookkeeping"

	| testService remoteOop block |
	self testsIssue: #issue687 withTitle: 'inspection as DataCurator broken'.
	"check all client service classes exist on server"
	RowanService subclasses do: 
			[:subclass |
			| remoteClassExists clientClassName |
			clientClassName := subclass name.
			remoteClassExists := session
						executeString: '| serviceClass | 
								serviceClass := Rowan platform serviceClasses detect:[:ea | ea name = '
								, clientClassName printString , '] ifNone:[].
								serviceClass notNil'.
			self assert: remoteClassExists].

	"check all remote service classes exist on client"
	testService := RowanTestService new.
	remoteOop := testService remoteServiceClassNamesOop: session.
	block := 
			[:remoteName |
			| hasClientClass |
			hasClientClass := RowanService withAllSubclasses detect: [:cls | cls name = remoteName] ifNone: [].
			self denyIsNil: hasClientClass].
	testService
		execute: block
		overArrayOop: remoteOop
		session: session!

test_versionMatches
	"See RowanVersionTest for more RowanClientServices version tests"

	self testsIssue: #issue521 withTitle: 'Jadeite version check'.
	self assert: session rowanClientServicesIsSupported	"whatever we're running is actually supported"!

test_workingDirectoryEqualsImageDirectory
	"should be set after login window first opens"

	self assert: File workingDirectory equals: SessionManager current imageBase!

writeUnicodeFile
	"write out a text file with unicode characters"

	| service |
	service := RowanFileService new.
	service
		command: #writeFileWithUnicode;
		commandArgs: Array new.
	service issueCommand: service session: session! !
!JadeiteMiscellaneousTestCase categoriesForMethods!
tearDown!private!support! !
test_adHocCompileError!public! !
test_adHocDisplay!public! !
test_adHocExecute!public! !
test_autoCommitDoesNotMakeRoundTripWhenOpeningBrowser!public!test auto commit! !
test_autoCommitInAdHocDisplay!public!test auto commit! !
test_autoCommitInAdHocExecution!public!test auto commit! !
test_autoCommitOffInAdHocDisplay!public!test auto commit! !
test_autoCommitOffInAdHocExecution!public!test auto commit! !
test_autoCommitUpdatedInSession!public!test auto commit! !
test_autocompleteCaseInsensitiveSearch!public!test auto complete!test methods! !
test_autocompleteClearsSymbolsOnLogout!public!test!test auto complete! !
test_autocompleteSaveClassSymbolAdded!public!test auto complete!test methods! !
test_autocompleteSaveMethodSymbolAdded!public!test auto complete!test methods! !
test_autocompleteSort!public!test!test auto complete! !
test_autocompleteSymbolsNotAddedToIfAutocompleteOff!public!test auto complete!test methods! !
test_classServiceNameIsString!public! !
test_convertToPattern!public!test! !
test_createProjectEditorCreateProject!public!test! !
test_createProjectEditorProjectsChanged!public!test! !
test_dolphinStackDumpBanners!public!test! !
test_fileSaveDialog!public!test file! !
test_fileSaveDialogBasics!public!test file! !
test_fileSaveFromWorkspace!public!test file! !
test_fileSaveWithUnicode!public!test file! !
test_findInWorkspace!public!test! !
test_instVarConstants!public!test! !
test_logoutFatalError!public!test! !
test_methodServiceClassNameIsString!public! !
test_releaseOops!public! !
test_returnedServices!public!test!test auto complete! !
test_serviceClassBookkeeping!public! !
test_versionMatches!public!test! !
test_workingDirectoryEqualsImageDirectory!public!test! !
writeUnicodeFile!public!support! !
!

