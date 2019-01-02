"Filed out from Dolphin Smalltalk 7"!

JadeiteAbstractTestCase subclass: #JadeiteSUnitSupportTestCase
	instanceVariableNames: 'sunitBrowser'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteSUnitSupportTestCase guid: (GUID fromString: '{afd06491-29d7-4988-bf71-09264248baaa}')!
JadeiteSUnitSupportTestCase comment: ''!
!JadeiteSUnitSupportTestCase categoriesForClass!Unclassified! !
!JadeiteSUnitSupportTestCase methodsFor!

assertPackageInList: name
	self denyIsNil: (sunitBrowser primaryPresenter packageListPresenter list
				detect: [:packageService | packageService name = name]
				ifNone: [])!

denyPackageInList: name
	self assertIsNil: (sunitBrowser primaryPresenter packageListPresenter list
				detect: [:packageService | packageService name = name]
				ifNone: [])!

isSampleProjectLoaded
	^(transcript projectListPresenter projectListPresenter list
		detect: [:projectService | projectService name = self sampleProjectName]
		ifNone: []) notNil!

methodListPresenter

	^self sunitPresenter methodListPresenter!

setUp
	super setUp. 
	sunitBrowser := self openWindow: [transcript jadeBrowseTests].
	transcript projectListPresenter refresh!

sunitPresenter
	^sunitBrowser primaryPresenter!

tearDown
	sunitBrowser destroy.!

test_abortNoSelections
	| abortCommand |
	self testsIssue: #issue383 withTitle: '(3.0.53) the commit button on the SUnit browser is silent'.
	self assertPackageInList: 'RowanSample1-Tests'.
	abortCommand := ((sunitBrowser view viewNamed: 'toolbar') itemAtIndex: 1) command.
	sunitBrowser primaryPresenter perform: abortCommand.
	[self denyPackageInList: 'RowanSample1-Tests'] ensure: 
			[self cloneRowanSample1.
			self ensureRowanSample1Loaded]!

test_abortWithSelections
	| abortCommand |
	self testsIssue: #issue383 withTitle: '(3.0.53) the commit button on the SUnit browser is silent'.
	sunitBrowser primaryPresenter selectPackageNamed: 'Rowan-Services-Tests'.
	sunitBrowser primaryPresenter selectClassNamed: 'RowanClassServiceTest'.
	sunitBrowser primaryPresenter selectMethodNamed: #testAddCategory.
	abortCommand := ((sunitBrowser view viewNamed: 'toolbar') itemAtIndex: 1) command.
	sunitBrowser primaryPresenter perform: abortCommand.
	
	[self assert: sunitBrowser primaryPresenter packageListPresenter selection name
		equals: 'Rowan-Services-Tests'.
	self assert: sunitBrowser primaryPresenter classListPresenter selection name
		equals: 'RowanClassServiceTest'.
	self assert: sunitBrowser primaryPresenter methodListPresenter selections size equals: 1.
	self assert: sunitBrowser primaryPresenter methodListPresenter selections first selector
		equals: #testAddCategory]
			ensure: 
				[self cloneRowanSample1.
				self ensureRowanSample1Loaded]!

test_browseMethods
	| browseMethodMenuItem browser selectors |
	self testsIssue: #issue207 withTitle: 'should be able to browe source for test from SUit browser'.
	self selectServiceNamed: 'Rowan-Services-Tests' in: self sunitPresenter packageListPresenter.
	self selectServiceNamed: 'JadeServerTest' in: self sunitPresenter classListPresenter.
	selectors := self sunitPresenter methodListPresenter list collect: [:service | service selector].
	self selectMethodsNamed: selectors.
	browseMethodMenuItem := self sunitPresenter methodListPresenter view contextMenu items
				detect: [:item | item isDivider not and: ['*Browse*Methods*' match: item description]]
				ifNone: [].
	browser := browseMethodMenuItem commandDescription performAgainst: self sunitPresenter.
	
	[self assert: (browser isKindOf: JadeiteMethodListBrowser).
	self assert: browser primaryPresenter methodListPresenter methodListPresenter list size
		equals: selectors size]
			ensure: [browser view close]!

test_browseSunitClass
	| browseClassMenuItem browser |
	self testsIssue: #issue207 withTitle: 'should be able to browe source for test from SUit browser'.
	self selectServiceNamed: 'Rowan-Services-Tests' in: self sunitPresenter packageListPresenter.
	self selectServiceNamed: 'JadeServerTest' in: self sunitPresenter classListPresenter.
	browseClassMenuItem := self sunitPresenter classListPresenter view contextMenu items
				detect: [:item | '*Browse*Class*' match: item description]
				ifNone: [].
	browser := browseClassMenuItem commandDescription performAgainst: self sunitPresenter.
	
	[self assert: (browser isKindOf: JadeiteProjectsSystemBrowser).
	self assert: browser currentCard classListPresenter selection name = 'JadeServerTest']
			ensure: [browser view close]!

test_commitNoSelections
	| commitCommand abortCommand |
	self testsIssue: #issue383 withTitle: '(3.0.53) the commit button on the SUnit browser is silent'.
	transcript projectListPresenter refreshProjects.
	self assertPackageInList: 'RowanSample1-Tests'.
	commitCommand := ((sunitBrowser view viewNamed: 'toolbar') itemAtIndex: 2) command.
	sunitBrowser primaryPresenter perform: commitCommand.
	
	[self assertPackageInList: 'RowanSample1-Tests'.
	abortCommand := ((sunitBrowser view viewNamed: 'toolbar') itemAtIndex: 1) command.
	sunitBrowser primaryPresenter perform: abortCommand.
	self assertPackageInList: 'RowanSample1-Tests']
			ensure: 
				["don't want committed sample project in tests"
				self unloadSampleProject.
				sunitBrowser primaryPresenter perform: commitCommand.
				self cloneRowanSample1.
				self ensureRowanSample1Loaded]!

test_commitWithSelections
	| commitCommand |
	self testsIssue: #issue383 withTitle: '(3.0.53) the commit button on the SUnit browser is silent'.
	transcript projectListPresenter refreshProjects.
	sunitBrowser primaryPresenter selectPackageNamed: 'Rowan-Services-Tests'.
	sunitBrowser primaryPresenter selectClassNamed: 'RowanClassServiceTest'.
	sunitBrowser primaryPresenter selectMethodNamed: #testAddCategory.
	commitCommand := ((sunitBrowser view viewNamed: 'toolbar') itemAtIndex: 2) command.
	sunitBrowser primaryPresenter perform: commitCommand.
	
	[self assert: sunitBrowser primaryPresenter packageListPresenter selection name
		equals: 'Rowan-Services-Tests'.
	self assert: sunitBrowser primaryPresenter classListPresenter selection name
		equals: 'RowanClassServiceTest'.
	self assert: sunitBrowser primaryPresenter methodListPresenter selections size equals: 1.
	self assert: sunitBrowser primaryPresenter methodListPresenter selections first selector
		equals: #testAddCategory]
			ensure: 
				["don't want committed sample project in tests"
				self unloadSampleProject.
				sunitBrowser primaryPresenter perform: commitCommand.
				self cloneRowanSample1.
				self ensureRowanSample1Loaded]!

test_inheritedTests
	| classTestSelectors testClassTestSelectors |
	self testsIssue: #issue211 withTitle: 'SUnit browser and SUnit tab in Project browser missing inherited test cases'.
	self selectServiceNamed: 'Rowan-Services-Tests' in: self sunitPresenter packageListPresenter.
	self selectServiceNamed: 'RowanClassServiceTest' in: self sunitPresenter classListPresenter.
	classTestSelectors := self sunitPresenter methodListPresenter list collect: [:service | service selector].
	self selectServiceNamed: 'RowanTestClassServiceTest' in: self sunitPresenter classListPresenter.
	self assert: (session executeString: 'RowanTestClassServiceTest shouldInheritSelectors').  "required to see the superclass non-abstract methods" 
	testClassTestSelectors := self sunitPresenter methodListPresenter list collect: [:service | service selector].
	self assert: testClassTestSelectors size > classTestSelectors size.  "the subclass inherits the super class's tests"
	classTestSelectors do:[:selector |
		self assert: (testClassTestSelectors includes: selector)].
	!

test_multiSelectClasses
	| jadeServerTestCount  rowanClassServiceTestCount|
	self selectServiceNamed: 'Rowan-Services-Tests' in: self sunitPresenter packageListPresenter.
	self selectServiceNamed: 'JadeServerTest' in: self sunitPresenter classListPresenter.
	self assert: self sunitPresenter classListPresenter selections size equals: 1.
	jadeServerTestCount := self sunitPresenter methodListPresenter list size. 
		self selectServiceNamed: 'RowanClassServiceTest' in: self sunitPresenter classListPresenter.
	self assert: self sunitPresenter classListPresenter selections size equals: 1.
	rowanClassServiceTestCount := self sunitPresenter methodListPresenter list size. 
	self selectServicesNamed: #('JadeServerTest' 'RowanClassServiceTest')
		in: self sunitPresenter classListPresenter.
	self assert: self sunitPresenter classListPresenter selections size equals: 2. 
	self assert: self sunitPresenter methodListPresenter list size equals: jadeServerTestCount + rowanClassServiceTestCount
	
!

test_multiSelectNoDuplicates
	
	self testsIssue: #issue336 withTitle: 'S-Unit Tests In an abstract class and its subclasses are not managed properly'.
	self selectServiceNamed: 'Rowan-Services-Tests' in:  self sunitPresenter packageListPresenter.
	self selectServicesNamed: #('RowanClassServiceTest' 'RowanTestClassServiceTest') in: self sunitPresenter classListPresenter.
	self assert: self sunitPresenter methodListPresenter list size =  self sunitPresenter methodListPresenter list asSet size
	!

test_openSunitBrowser
	"browser opened in setup"

	self assert: (sunitBrowser isKindOf: JadeiteSUnitBrowser)!

test_refresh
	| source newMethod |
	self testsIssue: #issue279 withTitle: 'Sunit browser refresh, auto or manual'.
	projectsBrowser
		ifNil: [projectsBrowser := self openWindow: [transcript openJadeiteProjectsBrowser]].
	
	[self selectServiceNamed: 'RowanSample1-Tests' in: self sunitPresenter packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: self sunitPresenter classListPresenter.
	self assert: self sunitPresenter methodListPresenter list size equals: 4.
	newMethod := self sunitPresenter methodListPresenter list
				detect: [:methodService | methodService selector == #testMethod]
				ifNone: [].
	self assertIsNil: newMethod.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Tests' in: self packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: self classListPresenter.
	source := 'testMethod  
		self assert: true'.
	self projectsPresenter methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self projectsPresenter classListPresenter selection.
	newMethod := self sunitPresenter methodListPresenter list
				detect: [:methodService | methodService selector == #testMethod]
				ifNone: [].
	self denyIsNil: newMethod.
	self assert: self sunitPresenter methodListPresenter list size equals: 5]
			ensure: [projectsBrowser destroy]!

test_runClassTests
	self testsIssue: #issue341 withTitle: 'Run sunit tests from class pass when they should not'.
	projectsBrowser
		ifNil: [projectsBrowser := self openWindow: [transcript openJadeiteProjectsBrowser]].
	
	[self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Tests' in: self packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: self classListPresenter.
	self projectsPresenter selectSUnitTab.
	[self projectsPresenter runClassTests] on: Error
		do: 
			[:ex |
			self assert: ex messageText
				equals: 'a MessageNotUnderstood occurred (error 2010), a RowanSample1 does not understand  #''bar'''].
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Tests' in: self packageListPresenter.
	self selectServiceNamed: 'RowanAnsweringServiceTest' in: self classListPresenter.
	self projectsPresenter selectSUnitTab.
	self projectsPresenter runClassTests.
	self methodListPresenter list do: [:methodService | self assert: methodService passed]]
			ensure: [projectsBrowser destroy]!

test_sunitBrowserHasRowanPackages
	self assert: (self sunitPresenter isKindOf: JadeiteSUnitPresenter).	"a different presenter is used in the projects browser"
	self assert: self sunitPresenter packageListPresenter list size > 0.
	self denyIsNil: (self serviceNamed: 'Rowan-Tests' in: self sunitPresenter packageListPresenter).
	self
		denyIsNil: (self serviceNamed: 'Rowan-Services-Tests' in: self sunitPresenter packageListPresenter)!

test_sunitBrowserHasRowanTestClasses
	self assert: self sunitPresenter classListPresenter list size = 0.
	self selectServiceNamed: 'Rowan-Tests' in: self sunitPresenter packageListPresenter.
	self denyIsNil: (self serviceNamed: 'RwMoveTest' in: self sunitPresenter classListPresenter).
	self assert: self sunitPresenter classListPresenter list size > 0.
	self denyIsNil: (self serviceNamed: 'RwBrowserToolApiTest' in: self sunitPresenter classListPresenter).!

test_sunitBrowserHasRowanTestMethods
	self selectServiceNamed: 'Rowan-Tests' in: self sunitPresenter packageListPresenter.
	self assert: self sunitPresenter methodListPresenter list size = 0.
	self selectServiceNamed: 'RwMoveTest' in: self sunitPresenter classListPresenter.
	self assert: self sunitPresenter methodListPresenter list size > 0.!

test_sunitBrowserPassingDebugTestShowsResult
	self testsIssue: #issue218 withTitle: 'Ctl-B does not `debug` selected test in SUnit browser'.
	self selectServiceNamed: 'RowanSample1-Tests' in: self sunitPresenter packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: self sunitPresenter classListPresenter.
	self selectServiceNamed: 'test1' in: self sunitPresenter methodListPresenter.
	self assert: self sunitPresenter methodListPresenter selections size equals: 1.
	self assert: self sunitPresenter methodListPresenter selection first selector equals: #test1.
	self assertIsNil: self sunitPresenter methodListPresenter selections first testResult.
	self sunitPresenter debug.
	self assert: self sunitPresenter methodListPresenter selection first selector equals: #test1.
	self assert: self sunitPresenter methodListPresenter selections size equals: 1.
	self assert: self sunitPresenter methodListPresenter selections first testResult equals: 'passed'!

test_sunitTabPassingDebugTestShowsResult
	| methodService |
	self testsIssue: #issue218 withTitle: 'Ctl-B does not `debug` selected test in SUnit browser'.
	projectsBrowser
		ifNil: [projectsBrowser := self openWindow: [transcript openJadeiteProjectsBrowser]].
	
	[self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Tests' in: self packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: self classListPresenter.
	self projectsPresenter selectSUnitTab.
	methodService := self projectsPresenter sunitPresenter methodListPresenter list first.
	self projectsPresenter sunitPresenter methodListPresenter selection: (Array with: methodService).
	self projectsPresenter sunitPresenter debug.
	self assert: methodService testResult equals: 'passed']
			ensure: [projectsBrowser destroy]!

unloadSampleProject
	| projectService |
	self isSampleProjectLoaded
		ifTrue: 
			[projectService := transcript projectListPresenter projectListPresenter list
						detect: [:service | service name = 'RowanSample1'].
			transcript projectListPresenter projectListPresenter selection: projectService.
			transcript projectListPresenter basicUnloadProjects: (Array with: self sampleProjectName)]! !
!JadeiteSUnitSupportTestCase categoriesFor: #assertPackageInList:!private!support! !
!JadeiteSUnitSupportTestCase categoriesFor: #denyPackageInList:!private!support! !
!JadeiteSUnitSupportTestCase categoriesFor: #isSampleProjectLoaded!private!support! !
!JadeiteSUnitSupportTestCase categoriesFor: #methodListPresenter!public!support! !
!JadeiteSUnitSupportTestCase categoriesFor: #setUp!public!support! !
!JadeiteSUnitSupportTestCase categoriesFor: #sunitPresenter!public!support! !
!JadeiteSUnitSupportTestCase categoriesFor: #tearDown!public!support! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_abortNoSelections!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_abortWithSelections!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_browseMethods!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_browseSunitClass!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_commitNoSelections!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_commitWithSelections!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_inheritedTests!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_multiSelectClasses!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_multiSelectNoDuplicates!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_openSunitBrowser!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_refresh!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_runClassTests!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_sunitBrowserHasRowanPackages!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_sunitBrowserHasRowanTestClasses!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_sunitBrowserHasRowanTestMethods!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_sunitBrowserPassingDebugTestShowsResult!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_sunitTabPassingDebugTestShowsResult!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #unloadSampleProject!private!support! !

