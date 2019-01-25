"Filed out from Dolphin Smalltalk 7"!

TestCase subclass: #JadeiteAbstractTestCase
	instanceVariableNames: 'session transcript projectsBrowser'
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

categoryListPresenter
	^self projectsPresenter categoryListPresenter!

classHierarchyPresenter
	^self projectsPresenter classHierarchyPresenter!

classListPresenter
	^self projectsPresenter classListPresenter!

cloneRowanSample1
	JadeiteTestResource current cloneRowanSample1!

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

	self projectListPresenter selectionByIndex: 0.!

ensureRowanSample1Loaded
	self loadProjectNamed: self sampleProjectName.!

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

	^JadePresenter issueCommand: services session: session!

itemNamed: menuName in: menuBar
	^menuBar items detect: [:item | '*' , menuName , '*' match: item text]!

loadProjectNamed: projectName
	| projectService |
	projectService := RowanProjectService new name: projectName.
	projectService
		command: #reloadProject;
		commandArgs: nil.
	JadePresenter issueCommand: (Array with: projectService) session: session!

loadRowanSample1InProjectList
	| sample1Path root selections |
	sample1Path := self rowanSample1Path.
	root := self rowanProjectsHome.
	self transcriptTab basicCloneProject: sample1Path root: root.
	self transcriptTab refresh.
	self selectServicesNamed: (Array with: self sampleProjectName)
		in: self transcriptTab projectListPresenter.
	selections := self transcriptTab projectListPresenter selections.
	RowanBrowserService new reloadProjects: selections presenter: self transcriptTab.
	self transcriptTab refresh!

methodListPresenter
	^self projectsPresenter methodListPresenter!

methodSourceForTest
	^'test
		^3'!

methodSourcePresenter
	^self projectsPresenter methodSourcePresenter!

noBreakIn: aMenu
	self assertIsNil: (aMenu items detect: [:command | '*Break*' match: command text] ifNone: [])!

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

projectListPresenter
	^self projectsPresenter projectListPresenter!

projectsPresenter
	^projectsBrowser currentCard!

rowanProjectsHome
	^'$ROWAN_PROJECTS_HOME'!

rowanSample1Path
	^'file:$ROWAN_PROJECTS_HOME/Rowan/samples/RowanSample1.ston'!

sampleClassName
	^'RowanSample1'!

sampleProjectName
	^'RowanSample1'!

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
	self projectsPresenter editSaveClass!

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

selectClassTab
	self selectClassTabIn: self projectsPresenter!

selectClassTabIn: presenter
	presenter instanceClassTabs lastCard!

selectInstanceTab
	self selectInstanceTabIn: self projectsPresenter!

selectInstanceTabIn: presenter
	presenter instanceClassTabs firstCard!

selectMethodNamed: selector
	^self selectMethodsNamed: (Array with: selector)!

selectMethodsNamed: selectors
	| methodServices |
	self methodListPresenter resetSelection.
	methodServices := selectors
				collect: [:selector | self methodListPresenter list detect: [:svc | svc selector = selector]].
	self methodListPresenter selections: methodServices.
	^methodServices!

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

setUp
	super setUp.
	session := JadeiteTestResource current session.
	transcript := JadeiteTestResource current transcript.
	self ensureRowanSample1Loaded. !

testsIssue: aSymbol withTitle: anObject
	"send this to help identify which tests test which issues"

	" a helpful parameter format is #issue<issueNumber>"

	"Issues currently reside in: 
		https://github.com/GemTalk/Jadeite/issues"

	!

transcript
	^transcript!

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

variableListPresenter
	^self projectsPresenter variableListPresenter.! !
!JadeiteAbstractTestCase categoriesFor: #abortTransaction!private!setup teardown! !
!JadeiteAbstractTestCase categoriesFor: #anotherNumberMethodSource!constants!private! !
!JadeiteAbstractTestCase categoriesFor: #assertMethodInList:!private!support! !
!JadeiteAbstractTestCase categoriesFor: #assertMethodInList:presenter:!private!support! !
!JadeiteAbstractTestCase categoriesFor: #assertProjectInList:!private!support! !
!JadeiteAbstractTestCase categoriesFor: #categoryListPresenter!private!project browser support! !
!JadeiteAbstractTestCase categoriesFor: #classHierarchyPresenter!private!project browser support! !
!JadeiteAbstractTestCase categoriesFor: #classListPresenter!private!project browser support! !
!JadeiteAbstractTestCase categoriesFor: #cloneRowanSample1!private!project support! !
!JadeiteAbstractTestCase categoriesFor: #commitTransaction!private!setup teardown! !
!JadeiteAbstractTestCase categoriesFor: #createDebuggerTestMethod!issue test support!private! !
!JadeiteAbstractTestCase categoriesFor: #createNewTestProjectNamed:!public!support! !
!JadeiteAbstractTestCase categoriesFor: #denyMethodInList:!private!support! !
!JadeiteAbstractTestCase categoriesFor: #denyMethodInList:presenter:!private!support! !
!JadeiteAbstractTestCase categoriesFor: #denyProjectInList:!private!support! !
!JadeiteAbstractTestCase categoriesFor: #deselectProjects!private!project browser support!selection! !
!JadeiteAbstractTestCase categoriesFor: #ensureRowanSample1Loaded!private!project support! !
!JadeiteAbstractTestCase categoriesFor: #fail:!asserting!public! !
!JadeiteAbstractTestCase categoriesFor: #interestingLoopMethodSource!constants!private! !
!JadeiteAbstractTestCase categoriesFor: #isSampleProjectLoaded!private!private testing!project support! !
!JadeiteAbstractTestCase categoriesFor: #issueCommand:!issue test support!public!support! !
!JadeiteAbstractTestCase categoriesFor: #issueCommands:!issue test support!public!support! !
!JadeiteAbstractTestCase categoriesFor: #itemNamed:in:!issue test support!private! !
!JadeiteAbstractTestCase categoriesFor: #loadProjectNamed:!private!project support! !
!JadeiteAbstractTestCase categoriesFor: #loadRowanSample1InProjectList!private!project support! !
!JadeiteAbstractTestCase categoriesFor: #methodListPresenter!private!project browser support! !
!JadeiteAbstractTestCase categoriesFor: #methodSourceForTest!constants!private! !
!JadeiteAbstractTestCase categoriesFor: #methodSourcePresenter!private!project browser support! !
!JadeiteAbstractTestCase categoriesFor: #noBreakIn:!issue test support!private! !
!JadeiteAbstractTestCase categoriesFor: #openWindow:!browser test support!private! !
!JadeiteAbstractTestCase categoriesFor: #packageListPresenter!private!project browser support! !
!JadeiteAbstractTestCase categoriesFor: #projectListPresenter!private!project browser support! !
!JadeiteAbstractTestCase categoriesFor: #projectsPresenter!private!project browser support! !
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
!JadeiteAbstractTestCase categoriesFor: #selectCategoriesNamed:!private!project browser support!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectCategoryNamed:!private!project browser support!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectClassTab!private!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectClassTabIn:!private!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectInstanceTab!private!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectInstanceTabIn:!private!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectMethodNamed:!private!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectMethodsNamed:!private!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectRowanSample1Class!private!project browser support!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectRowanSample1Test!private!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectServiceNamed:in:!private!project browser support!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectServicesNamed:in:!private!project browser support!selection! !
!JadeiteAbstractTestCase categoriesFor: #selectWithChangeEventMethodNamed:!private!selection! !
!JadeiteAbstractTestCase categoriesFor: #serviceNamed:in:!private!selection! !
!JadeiteAbstractTestCase categoriesFor: #setUp!private!setup teardown! !
!JadeiteAbstractTestCase categoriesFor: #testsIssue:withTitle:!issue test support!public!support! !
!JadeiteAbstractTestCase categoriesFor: #transcript!public!transcript support! !
!JadeiteAbstractTestCase categoriesFor: #transcriptProjectList!public!transcript support! !
!JadeiteAbstractTestCase categoriesFor: #transcriptProjectNamed:!public!transcript support! !
!JadeiteAbstractTestCase categoriesFor: #transcriptTab!public!transcript support! !
!JadeiteAbstractTestCase categoriesFor: #unloadSampleProject!private!project support! !
!JadeiteAbstractTestCase categoriesFor: #variableListPresenter!private!project browser support! !

!JadeiteAbstractTestCase class methodsFor!

isAbstract
	^self == JadeiteAbstractTestCase!

resources
	^IdentitySet with: JadeiteTestResource! !
!JadeiteAbstractTestCase class categoriesFor: #isAbstract!public! !
!JadeiteAbstractTestCase class categoriesFor: #resources!public! !

