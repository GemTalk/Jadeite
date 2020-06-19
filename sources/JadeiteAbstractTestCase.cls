"Filed out from Dolphin Smalltalk 7"!

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

anotherNumberMethodSource
	^'anotherNumber

		^3'!

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

ensureRowanSample1Loaded
	JadeiteTestResource current ensureRowanSample1Loaded!

fail: aString
	TestMessageBox disableJadeiteTestMessageBox.
	^super fail: aString
	!

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

isSampleProjectLoaded
	^(transcript projectListPresenter projectListPresenter list
		detect: [:projectService | projectService name = self sampleProjectName]
		ifNone: []) notNil!

issueCommand: service

	^self issueCommands: (Array with: service)!

issueCommands: services
	^JadePresenter issueCommands: services session: session!

itemNamed: menuName in: menuBar
	^menuBar items detect: [:item | '*' , menuName , '*' match: item text]!

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
	self selectServicesNamed: (Array with: self sampleProjectName)
		in: self transcriptTab projectListPresenter.
	selections := self transcriptTab projectListPresenter selections.
	RowanBrowserService new reloadProjects: selections presenter: self transcriptTab.
	self transcriptTab refresh!

loginWithRetry: loginShell
	| loginError |
	loginError := true.
	[loginError] whileTrue: 
			[
			[loginShell loginWithoutErrorHandling.
			loginError := false] on: Error
					do: [:ex | (Delay forMilliseconds: 100) wait]]!

logoutThenLoginAs: userName
	"closing the transcript will logout the session. don't commit"
	userName ifNil: [^self].
	userName = GciSession current userID ifTrue: [^self].
	self closeTranscriptAndLogout.
	JadeiteLoginShell allInstances do: [:shell | shell view close].	"should save to the remote JadeDefaultConnection.gss file"
	jadeiteShell := JadeiteLoginShell show.
	jadeiteShell userIDPresenter value: userName.
	self loginWithRetry: jadeiteShell!

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

rowanProjectsHome
	^JadePresenter rowanProjectsHomeEnvVarString!

rowanSample1Path
	^JadePresenter rowanSample1Path!

sampleClassName
	^'RowanSample1'!

sampleProjectName
	^JadeiteTestResource sampleProjectName!

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

saveMethod: source in: className category: category
	| classService |
	classService := RowanClassService named: className.
	classService
		saveMethod: source
		category: category
		session: session!

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
	categories do: 
			[:category |
			| service |
			service := self categoryListPresenter list
						detect: [:listCategory | categories includes: listCategory]
						ifNone: [self error: 'Category ''' , category , ''' not found'].
			self categoryListPresenter selections: (self categoryListPresenter selections asOrderedCollection
						add: service;
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
	transcript := JadeiteTestResource current transcript.
	self logoutThenLoginAs: user.
	session := JadeiteTestResource current session.
	transcript := JadeiteTestResource current transcript.
	self setAutoCommit: false.
	self ensureRowanSample1Loaded!

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
		saveMethod: 'comparisonMethod  ^self subclassResponsibility'
		in: 'RowanSample1'
		category: 'test support'.
	self selectServiceNamed: 'RowanSubClass' in: self classListPresenter.
	self
		saveMethod: 'comparisonMethod  ^3 + 4'
		in: 'RowanSubClass'
		category: 'test support'!

tearDown
	super tearDown.
	SessionManager inputState pumpMessages!

test_globalAdditionalAccelerators
	self primaryTestWindow ifNil: [^self].	"not all test classes have a primaryTestWindow"
	self assert: (self primaryTestWindow additionalAccelerators includes: #(#raiseConsole 'Ctrl+F7')).
!

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

unloadSampleProject
	| browserService |
	self isSampleProjectLoaded
		ifTrue: 
			[browserService := RowanBrowserService new.
			browserService
				command: #unloadProjectsNamed:;
				commandArgs: (Array with: (Array with: self sampleProjectName)).
			self issueCommand: browserService]!

updateService: service
	service command: #update. 
	^self issueCommand: service	!

variableListPresenter
	^self projectsPresenter variableListPresenter.! !
!JadeiteAbstractTestCase categoriesFor: #abortTransaction!private!setup teardown! !
!JadeiteAbstractTestCase categoriesFor: #anotherNumberMethodSource!constants!private! !
!JadeiteAbstractTestCase categoriesFor: #answerYesToDialogDuring:!private!support! !
!JadeiteAbstractTestCase categoriesFor: #assertMethodInList:!private!support! !
!JadeiteAbstractTestCase categoriesFor: #assertMethodInList:presenter:!private!support! !
!JadeiteAbstractTestCase categoriesFor: #assertProjectInList:!private!support! !
!JadeiteAbstractTestCase categoriesFor: #auditAll!public!support! !
!JadeiteAbstractTestCase categoriesFor: #categoryListPresenter!private!project browser support! !
!JadeiteAbstractTestCase categoriesFor: #classHierarchyPresenter!private!project browser support! !
!JadeiteAbstractTestCase categoriesFor: #classListPresenter!private!project browser support! !
!JadeiteAbstractTestCase categoriesFor: #cleanupExistingWindows!public!support! !
!JadeiteAbstractTestCase categoriesFor: #cleanupTextPaneForClose:!public!support! !
!JadeiteAbstractTestCase categoriesFor: #clearBreakAt:!private!support!tests! !
!JadeiteAbstractTestCase categoriesFor: #cloneRowanSample1!private!project support! !
!JadeiteAbstractTestCase categoriesFor: #closeExistingInspectors!private!support! !
!JadeiteAbstractTestCase categoriesFor: #closeTranscriptAndLogout!private!setup teardown!support! !
!JadeiteAbstractTestCase categoriesFor: #commitTransaction!private!setup teardown! !
!JadeiteAbstractTestCase categoriesFor: #createDebuggerTestMethod!issue test support!private! !
!JadeiteAbstractTestCase categoriesFor: #createNewTestProjectNamed:!public!support! !
!JadeiteAbstractTestCase categoriesFor: #denyMethodInList:!private!support! !
!JadeiteAbstractTestCase categoriesFor: #denyMethodInList:presenter:!private!support! !
!JadeiteAbstractTestCase categoriesFor: #denyProjectInList:!private!support! !
!JadeiteAbstractTestCase categoriesFor: #deselectProjects!private!project browser support!selection! !
!JadeiteAbstractTestCase categoriesFor: #destroy:!public!setup teardown! !
!JadeiteAbstractTestCase categoriesFor: #dictionaryPresenter!private!project browser support! !
!JadeiteAbstractTestCase categoriesFor: #disableBreakpoints!public!support! !
!JadeiteAbstractTestCase categoriesFor: #disableInteractionsWhile:!private!setup teardown! !
!JadeiteAbstractTestCase categoriesFor: #enableBreakpoints!public!support! !
!JadeiteAbstractTestCase categoriesFor: #ensureOneTab!private!support! !
!JadeiteAbstractTestCase categoriesFor: #ensureRowanSample1Loaded!private!project support! !
!JadeiteAbstractTestCase categoriesFor: #fail:!asserting!public! !
!JadeiteAbstractTestCase categoriesFor: #interestingLoopMethodSource!constants!private! !
!JadeiteAbstractTestCase categoriesFor: #isSampleProjectLoaded!private!private testing!project support! !
!JadeiteAbstractTestCase categoriesFor: #issueCommand:!issue test support!public!support! !
!JadeiteAbstractTestCase categoriesFor: #issueCommands:!issue test support!public!support! !
!JadeiteAbstractTestCase categoriesFor: #itemNamed:in:!issue test support!private! !
!JadeiteAbstractTestCase categoriesFor: #loadProjectNamed:!private!project support! !
!JadeiteAbstractTestCase categoriesFor: #loadRowanSample1InProjectList!private!project support! !
!JadeiteAbstractTestCase categoriesFor: #loginWithRetry:!private!support! !
!JadeiteAbstractTestCase categoriesFor: #logoutThenLoginAs:!private!setup teardown!support! !
!JadeiteAbstractTestCase categoriesFor: #methodListPresenter!private!project browser support! !
!JadeiteAbstractTestCase categoriesFor: #methodSourceForTest!constants!private! !
!JadeiteAbstractTestCase categoriesFor: #methodSourcePresenter!private!project browser support! !
!JadeiteAbstractTestCase categoriesFor: #noBreakIn:!issue test support!private! !
!JadeiteAbstractTestCase categoriesFor: #openProjectBrowser!private!support!test methods! !
!JadeiteAbstractTestCase categoriesFor: #openWindow:!browser test support!private! !
!JadeiteAbstractTestCase categoriesFor: #packageListPresenter!private!project browser support! !
!JadeiteAbstractTestCase categoriesFor: #primaryTestWindow!accessing!public! !
!JadeiteAbstractTestCase categoriesFor: #projectListPresenter!private!project browser support! !
!JadeiteAbstractTestCase categoriesFor: #projectsPresenter!private!project browser support! !
!JadeiteAbstractTestCase categoriesFor: #queryCommand:inPresenter:view:!private! !
!JadeiteAbstractTestCase categoriesFor: #rowanProjectsHome!constants!private! !
!JadeiteAbstractTestCase categoriesFor: #rowanSample1Path!constants!private! !
!JadeiteAbstractTestCase categoriesFor: #sampleClassName!private!project browser support! !
!JadeiteAbstractTestCase categoriesFor: #sampleProjectName!constants!private! !
!JadeiteAbstractTestCase categoriesFor: #saveClass:superclass:instVars:package:!private! !
!JadeiteAbstractTestCase categoriesFor: #saveClass:withInstVars:package:!private! !
!JadeiteAbstractTestCase categoriesFor: #saveInterestingLoopMethod!browser support!private! !
!JadeiteAbstractTestCase categoriesFor: #saveIssue166Method!issue test support!private! !
!JadeiteAbstractTestCase categoriesFor: #saveIssue169Method!issue test support!private! !
!JadeiteAbstractTestCase categoriesFor: #saveIssue216Method!issue test support!private! !
!JadeiteAbstractTestCase categoriesFor: #saveMethod:in:category:!private!support! !
!JadeiteAbstractTestCase categoriesFor: #saveSampleMethod!private! !
!JadeiteAbstractTestCase categoriesFor: #saveTestClassWithInstVars:package:!private! !
!JadeiteAbstractTestCase categoriesFor: #selectCategoriesNamed:!private!project browser support!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectCategoryNamed:!private!project browser support!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectClassInHierarchyNamed:!private!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectClassListTab!private!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectClassTab!private!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectClassTabIn:!private!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectHierarchyTab!private!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectHierarchyTabIn:!private!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectInstanceTab!private!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectInstanceTabIn:!private!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectMethodNamed:!private!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectMethodNamedInProjectBrowser:!private!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectMethodsNamed:!private!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectMethodsNamed:in:!private!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectNoneProject!public!support! !
!JadeiteAbstractTestCase categoriesFor: #selectRowanSample1Class!private!project browser support!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectRowanSample1Test!private!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectServiceNamed:in:!private!project browser support!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectServicesNamed:in:!private!project browser support!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectTreeServicesNamed:in:!private!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectWithChangeEventMethodNamed:!private!selection! !
!JadeiteAbstractTestCase categoriesFor: #serviceNamed:in:!private!selection! !
!JadeiteAbstractTestCase categoriesFor: #setAutoCommit:!private!setup teardown! !
!JadeiteAbstractTestCase categoriesFor: #setBreakAt:!private!support!tests! !
!JadeiteAbstractTestCase categoriesFor: #setUp!private!setup teardown! !
!JadeiteAbstractTestCase categoriesFor: #setupProjectBrowser!private!setup teardown! !
!JadeiteAbstractTestCase categoriesFor: #setupSupclassComparisonMethods!public!support! !
!JadeiteAbstractTestCase categoriesFor: #tearDown!private!setup teardown! !
!JadeiteAbstractTestCase categoriesFor: #test_globalAdditionalAccelerators!public!tests! !
!JadeiteAbstractTestCase categoriesFor: #testsIssue:withTitle:!issue test support!public!support! !
!JadeiteAbstractTestCase categoriesFor: #testsRowanIssue:withTitle:!issue test support!public!support! !
!JadeiteAbstractTestCase categoriesFor: #transcript!public!transcript support! !
!JadeiteAbstractTestCase categoriesFor: #transcriptForCurrentSession!private!setup teardown!support! !
!JadeiteAbstractTestCase categoriesFor: #transcriptProjectList!public!transcript support! !
!JadeiteAbstractTestCase categoriesFor: #transcriptProjectNamed:!public!transcript support! !
!JadeiteAbstractTestCase categoriesFor: #transcriptTab!public!transcript support! !
!JadeiteAbstractTestCase categoriesFor: #unloadSampleProject!private!project support! !
!JadeiteAbstractTestCase categoriesFor: #updateService:!issue test support!public!support! !
!JadeiteAbstractTestCase categoriesFor: #variableListPresenter!private!project browser support! !

!JadeiteAbstractTestCase class methodsFor!

isAbstract
	^self == JadeiteAbstractTestCase!

resources
	^IdentitySet with: JadeiteTestResource! !
!JadeiteAbstractTestCase class categoriesFor: #isAbstract!public! !
!JadeiteAbstractTestCase class categoriesFor: #resources!public! !

