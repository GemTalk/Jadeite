"Filed out from Dolphin Smallalk"!

TestCase subclass: #JadeiteAbstractTestCase
	instanceVariableNames: 'session transcript projectsBrowser jadeiteShell user'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteAbstractTestCase guid: (GUID fromString: '{883797a0-f9e4-49bf-8635-85de41e33c6b}')!
JadeiteAbstractTestCase comment: ''!
!JadeiteAbstractTestCase categoriesForClass!Unclassified! !
!JadeiteAbstractTestCase methodsFor!

abortTransaction
	transcript abortTransaction!

addPackageNamed: packageName
	self projectsPresenter addPackagePresenter newPackagePresenter value: packageName.
	self projectsPresenter addPackagePresenter componentPresenter selectionByIndex: 1.	"doesn't matter which component for test"
	"don't pick a symbol list so default symbol list is used"
	self projectsPresenter addPackagePresenter addPackage!

anotherNumberMethodSource
	^'anotherNumber

		^3'!

answerNoToDialogDuring: block
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #yes.
	block ensure: [TestMessageBox disableJadeiteTestMessageBox]!

answerYesToDialogDuring: block
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #yes.
	block ensure: [TestMessageBox disableJadeiteTestMessageBox]!

assertMethodInList: selector
	self assertMethodInList: selector presenter: self methodListPresenter!

assertMethodInList: selector presenter: methodListPresenter
	self
		denyIsNil: (methodListPresenter list detect: [:projectService | projectService selector = selector]
				ifNone: [])!

assertProjectInList: name
	self denyIsNil: (transcript projectListPresenter projectListPresenter list
				detect: [:projectService | projectService name = name]
				ifNone: [])!

auditAll
	self assert: (session
				executeString: '| auditResults | 
								auditResults := Rowan projectTools audit auditAll. 
								auditResults isEmpty')!

categoryListPresenter
	^self projectsPresenter categoryListPresenter!

classHierarchyPresenter
	^self projectsPresenter classHierarchyPresenter!

classListPresenter
	^self projectsPresenter classListPresenter!

cleanupExistingWindows
	JadeWorkspace allInstances do: [:ws | self cleanupTextPaneForClose: ws].	"otherwise the test will hang"
	JadeiteTranscript allInstances do: [:text | self cleanupTextPaneForClose: text].
	JadeiteBrowserPresenter allInstances do: 
			[:presenter |
			presenter methodSourcePresenter view isModified: false.
			presenter classDefinitionPresenter view isModified: false]!

cleanupTextPaneForClose: ws
	^ws codePane documentPresenter view isModified
		ifTrue: 
			[ws codePane documentPresenter view isModified: false.
			ws codePane documentPresenter value: nil]!

clearBreakAt: anInteger
	self projectsPresenter clearBreakPointAt: anInteger in: self projectsPresenter!

cloneRowanSample1
	JadeiteTestResource current cloneRowanSample1!

closeBrowser: theBrowser
	| count maxTries |
	count := 0.
	maxTries := 10.
	theBrowser
		ifNotNil: 
			[theBrowser view close.
			[theBrowser view isOpen not and: [count > maxTries]] whileFalse: 
					[(Delay forMilliseconds: 10) wait.
					count := count + 1]].
	self assert: count > maxTries description: theBrowser printString , ' did not close quickly enough'!

closeExistingInspectors
	"not so elegant way of making sure the test gets the right inspector. Close others first"

	JadeNavigationInspector allInstances do: 
			[:oldInspector |
			oldInspector view class = DeafObject
				ifTrue: [oldInspector become: String new]
				ifFalse: [oldInspector view close]].
	JadeInspector allInstances do: 
			[:oldInspector |
			oldInspector view class = DeafObject
				ifTrue: [oldInspector become: String new]
				ifFalse: [oldInspector view close]].
	JadeiteInspector allInstances do: 
			[:oldInspector |
			oldInspector view class = DeafObject
				ifTrue: [oldInspector become: String new]
				ifFalse: [oldInspector view close]]!

closeTranscriptAndLogout
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #no.	"closing the transcript will logout the session. don't commit"
	[transcript view close] ensure: [TestMessageBox disableJadeiteTestMessageBox]!

commitTransaction
	^transcript commitTransaction!

createDebuggerTestMethod
	| source |
	source := 'testMethod

	^10023614059'.
	self selectCategoriesNamed: (Array with: 'accessing'). 
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection!

createNewTestProjectNamed: projectName
	| testService |
	testService := RowanTestService command: #createNewTestProjectNamed:
				withArgs: (Array with: projectName).
	self issueCommand: testService!

denyMethodInList: selector
	self denyMethodInList: selector presenter: self methodListPresenter!

denyMethodInList: selector presenter: methodListPresenter
	self
		assertIsNil: (methodListPresenter list detect: [:projectService | projectService selector = selector]
				ifNone: [])!

denyProjectInList: name
	self assertIsNil: (transcript projectListPresenter projectListPresenter list
				detect: [:projectService | projectService name = name]
				ifNone: [])!

deselectProjects

	self projectListPresenter selectionByIndex: 0!

destroy: visualThing
	visualThing ifNil:[^self]. 
	(Delay forMilliseconds: 200) wait.
	(self class canUnderstand: #close) ifTrue: [visualThing close] ifFalse: [visualThing view close].
	(Delay forMilliseconds: 20) wait.!

dictionaryPresenter
	"dictionary list in projects browser"

	^self projectsPresenter dictionaryPresenter!

disableBreakpoints
	| answeringService |
	answeringService := RowanAnsweringService new.
	answeringService setBreakpointsEnabled: false session: session!

disableInteractionsWhile: block
	^JadeiteTestResource current disableInteractionsWhile: block!

enableBreakpoints
	| answeringService |
	answeringService := RowanAnsweringService new.
	answeringService setBreakpointsEnabled: true session: session!

ensureOneTab
	projectsBrowser ifNil: [^self].
	[projectsBrowser cardsPresenter view cards size = 1] whileFalse: [projectsBrowser closeCard]!

ensureRowanSampleProjectsLoaded
	JadeiteTestResource current unloadSampleProject1.
	JadeiteTestResource current unloadSampleProject9.
	session commit. 
	JadeiteTestResource current ensureRowanSampleProjectsLoaded!

ensureTestIsSetUpAfterLogout
	projectsBrowser := nil.
	GciSession current: nil.
	self loginWithRetry: (JadeiteLoginShell allInstances detect: [:shell | shell isOpen]).	"should only be one open"
	self resources do: 
			[:resource |
			resource current
				tearDown;
				setUp].
	self setUp!

executeStringInOtherSession: string
	| executionString |
	executionString := '(UserGlobals at: #otherSession) '.
	executionString := executionString , string.
	^session executeString: executionString!

fail: aString
	TestMessageBox disableJadeiteTestMessageBox.
	^super fail: aString
	!

haltTestForHardToCatchErrors: reason
	| proc |
	"Running test will not stop on assert. Need to do a hard halt to determine how a test can login as the wrong user"
	proc := Processor activeProcess.
	proc halt: proc topFrame sender cause: reason!

interestingLoopMethodSource
	^'interestingLoop

	| contents result |
	result := String new. 
	contents := { 23 . 55 . 45 . 999 }.
	contents select: [:n |
		| temp |
		temp := self test + n. 
		(temp / self anotherNumber) > 5
			ifTrue:[result add: ''found'']
			ifFalse: [result add: ''not found''].
		result add: '' - ''.
		n = 2.
	].
	^result'!

isSampleProject1Loaded
	^(transcript projectListPresenter projectListPresenter list
		detect: [:projectService | projectService name = self sampleProject1Name]
		ifNone: []) notNil!

issueCommand: service

	^self issueCommands: (Array with: service)!

issueCommands: services
	^JadePresenter issueCommands: services session: session!

itemNamed: menuName in: menuBar
	^menuBar items detect: [:item | '*' , menuName , '*' match: item text]!

jadeitePrefsFilePath
	^SessionManager current imageBase , 'Jadeite.prefs'!

loadProjectNamed: projectName
	| projectService |
	projectService := RowanProjectService new name: projectName.
	projectService
		command: #reloadProject;
		commandArgs: nil.
	JadePresenter issueCommands: (Array with: projectService) session: session!

loadRowanSample1InProjectList
	| sample1Path root selections |
	sample1Path := self rowanSample1Path.
	root := self rowanProjectsHome.
	self transcriptTab basicLoadV2Project: sample1Path projectsHome: root.
	self transcriptTab refresh.
	self selectServicesNamed: (Array with: self sampleProject1Name)
		in: self transcriptTab projectListPresenter.
	selections := self transcriptTab projectListPresenter selections.
	RowanBrowserService new reloadProjects: selections presenter: self transcriptTab.
	self transcriptTab refresh!

loginOtherSession
	 session
		executeString: 'UserGlobals at: #otherSession put: (GsExternalSession gemNRS: ''' , session gemNRS
				, ''' stoneNRS: ''' , session stoneName
				, ''' username: ''SystemUser'' password: ''swordfish'') login'.
!

loginWithRetry: loginShell
	| loginError maxTries count |
	loginError := true.
	maxTries := 25.
	count := 0.
	[loginError] whileTrue: 
			[
			[loginShell loginWithoutErrorHandling.
			session := GciSession current.
			loginError := false]
					on: Error
					do: 
						[:ex |
						count := count + 1.
						self assert: count < maxTries.
						(Delay forMilliseconds: 100) wait]]!

logoutOtherSession
	^session executeString: '
				(UserGlobals at: #otherSession) ifNotNil: [:sess | sess logout]'!

logoutThenLoginAs: theUser forceClose: aBoolean
	JadeiteTestResource current logoutThenLoginAs: theUser forceClose: aBoolean.
	jadeiteShell := JadeiteTestResource current jadeiteShell. !

methodListPresenter
	^self projectsPresenter methodListPresenter!

methodSourceForTest
	^'test
		^3'!

methodSourcePresenter
	^self projectsPresenter methodSourcePresenter!

noBreakIn: aMenu
	self
		assertIsNil: (aMenu items detect: 
					[:command |
					('*Break*' match: command text)
						and: [(command text = 'Browse Breakpoints') not and: [(command text = 'Clear Method Breakpoints') not]]]
				ifNone: [])!

nonSystemSessionCount
	^session
		executeString: '
(System currentSessions select:[:i |
	| username |
	username := ((System descriptionOfSession: i) at: 1) userId. 
	((username ~= ''GcUser'') and:[username ~=''SymbolUser''])]) size'!

openProjectBrowser
	projectsBrowser
		ifNil: [projectsBrowser := self openWindow: [JadeiteBrowser showOnSession: session]]!

openWindow: aBlock
	"evaluate a block which is expected to return an object that responds to #view.
	Wait until the view affirms it is open before continuing"

	| presenter count |
	presenter := aBlock value.
	count := 0.
	[presenter view isOpen] whileFalse: 
			[(Delay forMilliseconds: 50) wait.
			count := count + 1.
			count > 10 ifTrue: [^presenter]].
	^presenter!

packageListPresenter
	^self projectsPresenter packageListPresenter!

primaryTestWindow
	"Every test should have a primary window it is testing. 
	If not, just return nil"

	^projectsBrowser!

projectListPresenter
	^self projectsPresenter projectListPresenter!

projectsPresenter
	^projectsBrowser currentCard!

queryCommand: commandSymbol inPresenter: presenter view: view
	| commandQuery |
	commandQuery := CommandQuery new commandDescription: (CommandDescription new command: commandSymbol)
				source: view.
	presenter queryCommand: commandQuery.
	^commandQuery!

removePreferencesFile
	| path prefsExist |
	path := self jadeitePrefsFilePath.
	prefsExist := File exists: path.
	prefsExist
		ifTrue: 
			[self savePrefsBackup.
			(File open: path) delete].
	self deny: (File exists: path).
	^prefsExist!

restoreBackupPrefsFile: prefsExisted
	| backupStream fileStream backupPath |
	prefsExisted
		ifFalse: 
			[(File open: SessionManager current imageBase , 'Jadeite.prefs')
				close;
				delete].
	backupPath := SessionManager current imageBase , 'Jadeite.prefs.testbkp'.
	(File exists: backupPath) ifFalse: [^self].
	backupStream := FileStream read: SessionManager current imageBase , 'Jadeite.prefs.testbkp'.
	fileStream := FileStream write: SessionManager current imageBase , 'Jadeite.prefs'.
	[fileStream nextPutAll: backupStream contents] ensure: 
			[backupStream close.
			(File open: backupPath) delete.
			fileStream close]!

routeCommand: command toWindow: windowLikeThing
	"Private - see CommandDescription class comment for explanation of how it fits in the Dolphin MVP architecture.
	Route the command description through the command policy to see if it finds the right home"

	| commandDescription id |
	commandDescription := CommandDescription registry keys detect: [:key | key command = command].
	id := CommandDescription registry at: commandDescription.
	self routeCommandWithId: id inVisual: windowLikeThing!

routeCommandWithId: id inVisual: windowLikeThing
	"Private - see CommandDescription class comment for explanation of how it fits in the Dolphin MVP architecture.
	Route the command description through the command policy to see if it finds the right home"

	| commandDescription |
	commandDescription := CommandDescription withId: id ifAbsent: [].
	windowLikeThing commandPolicy route: commandDescription!

rowanProjectsHome
	^JadePresenter rowanProjectsHomeEnvVarString!

rowanSample1Path
	^JadePresenter rowanSample1Path!

sampleClassName
	^'RowanSample1'!

sampleProject1Name
	^JadeiteTestResource sampleProject1Name!

saveClass: className superclass: superName instVars: instVars package: aString
	self projectsPresenter classDefinitionPresenter
		value: superName, ' rwSubclass: ', className printString, '
	instVarNames: ' , instVars printString
				, '
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ', aString printString, '
	options: #()'.
	^self projectsPresenter editSaveClass!

saveClass: className withInstVars: instVars package: aString
	self saveClass: className superclass: 'Object' instVars: instVars package: aString!

saveClassMethod: source in: className category: category
	| classService |
	classService := RowanClassService named: className.
	classService meta: true. 
	classService
		saveMethod: source
		category: category
		session: session.
	^classService!

saveInterestingLoopMethod
	| source |
	source := self methodSourceForTest.
	self selectCategoriesNamed: (Array with: 'accessing').
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	source := self anotherNumberMethodSource.
	self selectCategoriesNamed: (Array with: 'accessing').
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	source := self interestingLoopMethodSource.
	self selectCategoriesNamed: (Array with: 'accessing').
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection!

saveIssue166Method
	| source |
	source := 'issue166

	"RowanSample1 new issue166"

	[RowanSample1 new halt; foo] value.
	^self'.
	self selectCategoriesNamed: (Array with: 'accessing'). 
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection!

saveIssue169Method
	| source |
	source := 'issue169

	"RowanSample1 new issue169"

	| image string|
	self halt. 
	image := Rowan image.
	string := String new. 
	Transcript cr. 
	^self'.
	self selectCategoriesNamed: (Array with: 'accessing'). 
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection!

saveIssue216Method
	| source |
	source := 'issue216

	"RowanSample1 new issue216"

	self halt. 
	RowanClassService new classFromName.
	^self'.
	self selectCategoriesNamed: (Array with: 'accessing'). 
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection!

saveMethod: source in: className
	^self
		saveMethod: source
		in: className
		category: 'dontCare'!

saveMethod: source in: className category: category
	| classService |
	classService := RowanClassService named: className.
	classService
		saveMethod: source
		category: category
		session: session.
	^classService!

savePrefsBackup
	| backupStream fileStream |
	backupStream := FileStream write: SessionManager current imageBase , 'Jadeite.prefs.testbkp'.
	fileStream := FileStream read: SessionManager current imageBase , 'Jadeite.prefs'.
	[backupStream nextPutAll: fileStream contents] ensure: 
			[backupStream close.
			fileStream close]!

saveSampleMethod

	| source |
	source := 'sampleMethod  
		| aaa | 
		aaa := 123. 
		^aaa'. 
	self methodSourcePresenter value: source. 
	self projectsPresenter editSaveMethod: self classListPresenter selection. 

	!

saveTestClassWithInstVars: instVars package: aString
	self
		saveClass: 'TestClass'
		withInstVars: instVars
		package: aString!

selectCategoriesNamed: categories
	self categoryListPresenter selections: Array new. 
	categories do: 
			[:category |
			| categoryString |
			categoryString := self categoryListPresenter list
						detect: [:listCategory | categories includes: listCategory]
						ifNone: [self error: 'Category ''' , category , ''' not found'].
			self categoryListPresenter selections: (self categoryListPresenter selections asOrderedCollection
						add: categoryString;
						yourself)]!

selectCategoryNamed: category
	self selectCategoriesNamed: (Array with: category)!

selectClassInHierarchyNamed: className
	self selectTreeServicesNamed: (Array with: className) in: self classHierarchyPresenter!

selectClassListTab
	self projectsPresenter selectClassListTab.!

selectClassTab
	self selectClassTabIn: self projectsPresenter!

selectClassTabIn: presenter
	presenter instanceClassTabs lastCard!

selectHierarchyTab
	self selectHierarchyTabIn: self projectsPresenter!

selectHierarchyTabIn: presenter
	presenter classHierarchyTabs
		lastCard;
		onTabChanged!

selectInstanceTab
	self selectInstanceTabIn: self projectsPresenter!

selectInstanceTabIn: presenter
	presenter instanceClassTabs firstCard!

selectMethodNamed: selector
	^self selectMethodsNamed: (Array with: selector)!

selectMethodNamedInProjectBrowser: selector
	| methodServices |
	self projectsPresenter methodListPresenter resetSelection.
	methodServices := self projectsPresenter  methodListPresenter list detect: [:svc | svc selector = selector].
	self projectsPresenter  methodListPresenter selections: (Array with: methodServices).
	^methodServices!

selectMethodsNamed: selectors
	| methodServices |
	self methodListPresenter resetSelection.
	methodServices := selectors
				collect: [:selector | self methodListPresenter list detect: [:svc | svc selector = selector]].
	self methodListPresenter selections: methodServices.
	^methodServices!

selectMethodsNamed: selectors in: presenter
	| methodServices |
	presenter resetSelection.
	methodServices := selectors
				collect: [:selector | presenter list detect: [:svc | svc selector = selector]].
	presenter selections: methodServices.
	^methodServices!

selectNoneProject
	self selectServiceNamed: RowanProjectService noneProject name in: self projectListPresenter!

selectRowanSample1Class
	"big assumption - RowanSample1 class will allways be in RowanSample1 project"

	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Core' in: self packageListPresenter.
	self selectServiceNamed: self sampleClassName in: self classListPresenter!

selectRowanSample1Test
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Tests' in: self packageListPresenter.
	self projectsPresenter isHierarchyTabSelected
		ifTrue: 
			[self selectTreeServicesNamed: (Array with: 'RowanSample1Test') in: self classHierarchyPresenter]
		ifFalse: [self selectServiceNamed: 'RowanSample1Test' in: self classListPresenter]!

selectRowanServicesPackage
	self selectServiceNamed: 'RowanClientServices' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Core' in: self packageListPresenter!

selectRowanServicesTestsPackage
	self selectServiceNamed: 'RowanClientServices' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Tests' in: self packageListPresenter!

selectServiceNamed: aString in: presenter
	self selectServicesNamed: (Array with: aString) in: presenter!

selectServicesNamed: anArray in: presenter
	presenter resetSelection.
	anArray isEmpty ifTrue:[^self].
	anArray do: 
			[:name |
			| service |
			service := presenter list detect: [:svc | svc name = name]
						ifNone: [self error: 'List element ' , name , ' not found'].
			presenter selections: (presenter selections asOrderedCollection
						add: service;
						yourself)]!

selectTreeServicesNamed: anArray in: presenter
	| bag |
	bag := presenter model asBag.
	presenter resetSelection.
	anArray do: 
			[:name |
			| service |
			service := bag detect: [:svc | svc name = name]
						ifNone: [self error: 'Tree element ' , name , ' not found'].
			presenter selections: (presenter selections asOrderedCollection
						add: service;
						yourself)]!

selectWithChangeEventMethodNamed: selector
	"foolishly, the selection changing event which needs testing
	is only sent through a button click in Dolphin. We need to 
	fake it out for the test. frustrating.

	Note - even though we are faking up the event, the event itself
	should get modified based on the debugger's state which is a
	valid test."

	| event index methodService |
	methodService := self methodListPresenter list detect: [:service | service selector = selector].
	index := self methodListPresenter list indexOf: methodService.
	event := (SelectionChangingEvent forSource: self)
				oldSelections: self methodListPresenter selections;
				newSelections: (Array with: (self methodListPresenter list at: index));
				cause: #test;
				yourself.
	self methodListPresenter onSelectionChanging: event.
	event value ifFalse: [^self].
	self methodListPresenter selection: (self methodListPresenter list at: index)!

serviceNamed: name in: presenter
	| service |
	service := presenter list detect: [:service | service name = name] ifNone: [].
	^service!

setAutoCommit: aBoolean
	| autoCommitService |
	autoCommitService := RowanAutoCommitService new
				command: #autoCommit:;
				commandArgs: (Array with: aBoolean).
	self issueCommand: autoCommitService!

setBreakAt: anInteger
	self projectsPresenter setBreakPointAt: anInteger in: self projectsPresenter!

setUp
	super setUp.
	JadeiteBrowser
		compile: 'validateUserInterface
	[self view validateUserInterface] on: Win32Error do: [:ex |].'
		categories: #(#deleteme)
		package: (Package name: 'Dolphin').	"opening / closing windows really fast can wreak havoc on the windows system"
	user ifNil: [user := 'SystemUser'].
	transcript := JadeiteTestResource current transcript.
	self logoutThenLoginAs: user forceClose: false.
	session := JadeiteTestResource current session.
	transcript := JadeiteTestResource current transcript.
	self setAutoCommit: false.
	self switchTransactionModeTo: #autoBegin.	"Ensure tests start with transaction mode that is predictable - most tests assume #autoBegin"
	self ensureRowanSampleProjectsLoaded.
	JadeiteLoginShell allInstances size > 1
		ifTrue: 
			["Running tests will not stop on assert. (Debugging tests does) Need to do a hard halt to determine how a test can login as the wrong user"
			MemoryManager current collectGarbage
			"(Delay forMilliseconds: 1000) wait.	give it a second to cleanup
			MemoryManager current collectGarbage"
			"Taking this check out.  Although we still are tripping over multiple login windows, they are going away so it should no longer be a problem.- Famous last words. 
			JadeiteLoginShell allInstances size > 1
				ifTrue: [self haltTestForHardToCatchErrors: 'Multiple JadeiteLoginShells found']"]!

setupProjectBrowser
	projectsBrowser := JadeiteTestResource current openProjectsBrowser.
	self ensureOneTab.
	self selectClassListTab.
	self selectInstanceTab.
	self projectsPresenter selectCategoryTab.
	self projectListPresenter resetSelection!

setupSupclassComparisonMethods
	self selectRowanSample1Class.
	self
		saveClass: 'RowanSubClass'
		superclass: 'RowanSample1'
		instVars: #()
		package: 'RowanSample1-Core'.
	self
		saveMethod: 'comparisonMethod  ^self subclassResponsibility'
		in: 'RowanSample1'
		category: 'test support'.
	self selectServiceNamed: 'RowanSubClass' in: self classListPresenter.
	self
		saveMethod: 'comparisonMethod  ^3 + 4'
		in: 'RowanSubClass'
		category: 'test support'!

stopOtherSessions
	session
		executeString: '	

	| sessionsToStop |
sessionsToStop :=  System currentSessions select:[:i |
	| username |
	username := ((System descriptionOfSession: i) at: 1) userId. 
	((username ~= ''GcUser'') and:[(username ~=''SymbolUser'' and:[System session ~= i])])].
sessionsToStop do:[:i | System stopSession: i]'!

switchTransactionModeTo: aSymbol
	JadeiteTestResource current switchTransactionModeTo: aSymbol!

tearDown
	| answeringService |
	super tearDown.
	"remove hook to avoid lots of error dialogs when opening/closing windows too fast. See #setUp for compilation."
	[JadeiteBrowser removeSelector: #validateUserInterface ifAbsent: []] on: Error do: [:ex |  "avoid Dolphin bug triggering method removal event"].
	SessionManager inputState pumpMessages.
	"debugging code - halt if we find a nil in the user's symbol list"
	answeringService := RowanAnsweringService new
				command: #symbolListHasNil;
				commandArgs: Array new.
	self issueCommand: answeringService.!

test_globalAdditionalAccelerators
	| command |
	self primaryTestWindow ifNil: [^self].	"not all test classes have a primaryTestWindow"
	self assert: (self primaryTestWindow class defaultAdditionalAccelerators
				includes: #(#raiseConsole 'Ctrl+F7')).
	self primaryTestWindow topShell view buildCombinedAcceleratorTable.	"lazily done by Dolphin when view is engaged"
	command := self primaryTestWindow topShell view combinedAcceleratorTable commands values
				detect: [:ea | ea command = #insertIfFalse]
				ifNone: [].
	self denyIsNil: command.
	command := self primaryTestWindow topShell view combinedAcceleratorTable commands values
				detect: [:ea | ea command = #insertIfTrue]
				ifNone: [].
	self denyIsNil: command!

testsIssue: aSymbol withTitle: anObject
	"send this to help identify which tests test which issues"

	" a helpful parameter format is #issue<issueNumber>"

	"Issues currently reside in: 
		https://github.com/GemTalk/Jadeite/issues"

	!

testsRowanIssue: aSymbol withTitle: anObject
	"send this to help identify which tests test which Rowan project issues"

	" a helpful parameter format is #issue<issueNumber>"

	"Issues currently reside in: 
		https://github.com/GemTalk/Rowan/issues"

	!

transcript
	^transcript!

transcriptForCurrentSession
	^JadeiteTranscript allInstances detect: [:tran | tran gciSession == GciSession current] ifNone: []!

transcriptProjectList
	^self transcriptTab projectListPresenter!

transcriptProjectNamed: string
	^self transcriptProjectList list detect: [:projectService | projectService name = string] ifNone: []!

transcriptTab
	^transcript projectListPresenter !

unloadSampleProject1
	| browserService |
	self isSampleProject1Loaded
		ifTrue: 
			[browserService := RowanBrowserService new.
			browserService
				command: #unloadProjectsNamed:;
				commandArgs: (Array with: (Array with: self sampleProject1Name)).
			self issueCommand: browserService]!

updateService: service
	service command: #update. 
	^self issueCommand: service	!

variableListPresenter
	^self projectsPresenter variableListPresenter.!

verifyWindowClosed: presenter
	| count maxTries |
	maxTries := 100.
	count := 0.
	[count < maxTries] whileTrue: 
			[presenter isOpen ifTrue: [count := count + 1] ifFalse: [^true].
			(Delay forMilliseconds: 10) wait].
	self deny: presenter isOpen! !
!JadeiteAbstractTestCase categoriesForMethods!
abortTransaction!private!setup teardown! !
addPackageNamed:!public!test updates from other browsers!tests! !
anotherNumberMethodSource!constants!private! !
answerNoToDialogDuring:!private!support! !
answerYesToDialogDuring:!private!support! !
assertMethodInList:!private!support! !
assertMethodInList:presenter:!private!support! !
assertProjectInList:!private!support! !
auditAll!public!support! !
categoryListPresenter!private!project browser support! !
classHierarchyPresenter!private!project browser support! !
classListPresenter!private!project browser support! !
cleanupExistingWindows!public!support! !
cleanupTextPaneForClose:!public!support! !
clearBreakAt:!private!support!tests! !
cloneRowanSample1!private!project support! !
closeBrowser:!public!support! !
closeExistingInspectors!private!support! !
closeTranscriptAndLogout!private!setup teardown!support! !
commitTransaction!private!setup teardown! !
createDebuggerTestMethod!issue test support!private! !
createNewTestProjectNamed:!public!support! !
denyMethodInList:!private!support! !
denyMethodInList:presenter:!private!support! !
denyProjectInList:!private!support! !
deselectProjects!private!project browser support!selection! !
destroy:!public!setup teardown! !
dictionaryPresenter!private!project browser support! !
disableBreakpoints!public!support! !
disableInteractionsWhile:!private!setup teardown! !
enableBreakpoints!public!support! !
ensureOneTab!private!support! !
ensureRowanSampleProjectsLoaded!private!project support! !
ensureTestIsSetUpAfterLogout!private!support!tests! !
executeStringInOtherSession:!public! !
fail:!asserting!public! !
haltTestForHardToCatchErrors:!private!setup teardown! !
interestingLoopMethodSource!constants!private! !
isSampleProject1Loaded!private!private testing!project support! !
issueCommand:!issue test support!public!support! !
issueCommands:!issue test support!public!support! !
itemNamed:in:!issue test support!private! !
jadeitePrefsFilePath!public! !
loadProjectNamed:!project support!public! !
loadRowanSample1InProjectList!private!project support! !
loginOtherSession!public! !
loginWithRetry:!private!support! !
logoutOtherSession!public! !
logoutThenLoginAs:forceClose:!private!setup teardown!support! !
methodListPresenter!private!project browser support! !
methodSourceForTest!constants!private! !
methodSourcePresenter!private!project browser support! !
noBreakIn:!issue test support!private! !
nonSystemSessionCount!public! !
openProjectBrowser!private!support!test methods! !
openWindow:!browser test support!private! !
packageListPresenter!private!project browser support! !
primaryTestWindow!accessing!public! !
projectListPresenter!private!project browser support! !
projectsPresenter!private!project browser support! !
queryCommand:inPresenter:view:!private! !
removePreferencesFile!public! !
restoreBackupPrefsFile:!public! !
routeCommand:toWindow:!helpers!private! !
routeCommandWithId:inVisual:!helpers!private! !
rowanProjectsHome!constants!private! !
rowanSample1Path!constants!private! !
sampleClassName!private!project browser support! !
sampleProject1Name!constants!private! !
saveClass:superclass:instVars:package:!private! !
saveClass:withInstVars:package:!private! !
saveClassMethod:in:category:!private!support! !
saveInterestingLoopMethod!browser support!private! !
saveIssue166Method!issue test support!private! !
saveIssue169Method!issue test support!private! !
saveIssue216Method!issue test support!private! !
saveMethod:in:!private!support! !
saveMethod:in:category:!private!support! !
savePrefsBackup!public! !
saveSampleMethod!private! !
saveTestClassWithInstVars:package:!private! !
selectCategoriesNamed:!private!project browser support!selection! !
selectCategoryNamed:!private!project browser support!selection! !
selectClassInHierarchyNamed:!private!selection! !
selectClassListTab!private!selection! !
selectClassTab!private!selection! !
selectClassTabIn:!private!selection! !
selectHierarchyTab!private!selection! !
selectHierarchyTabIn:!private!selection! !
selectInstanceTab!private!selection! !
selectInstanceTabIn:!private!selection! !
selectMethodNamed:!private!selection! !
selectMethodNamedInProjectBrowser:!private!selection! !
selectMethodsNamed:!private!selection! !
selectMethodsNamed:in:!private!selection! !
selectNoneProject!public!support! !
selectRowanSample1Class!private!project browser support!selection! !
selectRowanSample1Test!private!selection! !
selectRowanServicesPackage!private!test rename class!testing! !
selectRowanServicesTestsPackage!private!test class hierarchy!tests! !
selectServiceNamed:in:!private!project browser support!selection! !
selectServicesNamed:in:!private!project browser support!selection! !
selectTreeServicesNamed:in:!private!selection! !
selectWithChangeEventMethodNamed:!private!selection! !
serviceNamed:in:!private!selection! !
setAutoCommit:!private!setup teardown! !
setBreakAt:!private!support!tests! !
setUp!private!setup teardown! !
setupProjectBrowser!private!setup teardown! !
setupSupclassComparisonMethods!public!support! !
stopOtherSessions!public! !
switchTransactionModeTo:!private!support!tests! !
tearDown!private!setup teardown! !
test_globalAdditionalAccelerators!public!tests! !
testsIssue:withTitle:!issue test support!public!support! !
testsRowanIssue:withTitle:!issue test support!public!support! !
transcript!public!transcript support! !
transcriptForCurrentSession!private!setup teardown!support! !
transcriptProjectList!public!transcript support! !
transcriptProjectNamed:!public!transcript support! !
transcriptTab!public!transcript support! !
unloadSampleProject1!private!project support! !
updateService:!issue test support!public!support! !
variableListPresenter!private!project browser support! !
verifyWindowClosed:!private!support!tests! !
!

!JadeiteAbstractTestCase class methodsFor!

isAbstract
	^self == JadeiteAbstractTestCase!

resources
	^IdentitySet with: JadeiteTestResource! !
!JadeiteAbstractTestCase class categoriesForMethods!
isAbstract!public! !
resources!public! !
!

