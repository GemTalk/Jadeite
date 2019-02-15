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

projectsPresenter
	^projectsBrowser currentCard!

selecProjectBrowserMethodNamed: selector
	^self selecProjectBrowserMethodsNamed: (Array with: selector)!

selecProjectBrowserMethodsNamed: selectors
	| methodServices methodPresenter |
	methodPresenter := self projectsPresenter methodListPresenter.
	methodPresenter resetSelection.
	methodServices := selectors
				collect: [:selector | methodPresenter list detect: [:svc | svc selector = selector]].
	methodPresenter selections: methodServices.
	^methodServices!

selectSUnitBrowserMethodNamed: selector
	^self selectSUnitBrowserMethodsNamed: (Array with: selector)!

selectSUnitBrowserMethodsNamed: selectors
	| methodServices |
	self methodListPresenter resetSelection.
	methodServices := selectors
				collect: [:selector | self methodListPresenter list detect: [:svc | svc selector = selector]].
	self methodListPresenter selection: methodServices.
	self methodListPresenter view invalidate.
	^methodServices!

setUp
	super setUp.
	sunitBrowser := self openWindow: [transcript jadeBrowseTests].
	transcript projectListPresenter refresh!

setupRunInSelectedTestClassTest
	"setup a test in the superclass that calls a method
	defined in both the super and subclass"

	self setupTestSuperclass.
	self
		saveClass: 'RowanSample1SubClassTest'
		superclass: 'RowanSample1Test'
		instVars: Array new
		package: 'RowanSample1-Tests'.
	self methodSourcePresenter value: 'myClassName
				^#RowanSample1SubClassTest'.
	self projectsPresenter editSaveMethod: self classListPresenter selection!

setupTestSuperclass
	"setup a subclass of TestCase with a class var that can 
	record what class was actually run" 
	self selectServiceNamed: 'RowanSample1' in: self projectsPresenter projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Tests' in: self projectsPresenter packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: self projectsPresenter classListPresenter.
	self projectsPresenter classDefinitionPresenter
		value: 'TestCase' , ' rwSubclass: ' , 'RowanSample1Test' printString
				, '
	instVarNames: ' , Array new printString
				, '
	classVars: #(TestClassVar)
	classInstVars: #()
	poolDictionaries: #()
	category: '
					, 'RowanSample1-Tests' printString , '
	options: #()'.
	self projectsPresenter editSaveClass.
	self methodSourcePresenter
		value: 'test_method
				self class setMyClassName: self class name. 
				^self assert: self class name equals: self myClassName'.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self methodSourcePresenter value: 'myClassName
				^#RowanSample1Test'.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self selectClassTab.
	self methodSourcePresenter value: 'setMyClassName: aSymbol 
				TestClassVar := aSymbol'.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self methodSourcePresenter value: 'testClassVar
				^TestClassVar'.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self selectInstanceTab.
	self methodSourcePresenter
		value: 'test_method
				self class setMyClassName: self class name. 
				^self assert: self class name equals: self myClassName'.
	self projectsPresenter editSaveMethod: self classListPresenter selection!

sunitPresenter
	^sunitBrowser primaryPresenter!

tearDown
	self assert:  sunitBrowser view close.!

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
	sunitBrowser primaryPresenter selectMethodNamed: #test_addCategory.
	abortCommand := ((sunitBrowser view viewNamed: 'toolbar') itemAtIndex: 1) command.
	sunitBrowser primaryPresenter perform: abortCommand.
	
	[self assert: sunitBrowser primaryPresenter packageListPresenter selection name
		equals: 'Rowan-Services-Tests'.
	self assert: sunitBrowser primaryPresenter classListPresenter selection name
		equals: 'RowanClassServiceTest'.
	self assert: sunitBrowser primaryPresenter methodListPresenter selections size equals: 1.
	self assert: sunitBrowser primaryPresenter methodListPresenter selections first selector
		equals: #test_addCategory]
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
	sunitBrowser primaryPresenter selectPackageNamed: 'Rowan-Services-Tests'.
	sunitBrowser primaryPresenter selectClassNamed: 'RowanClassServiceTest'.
	sunitBrowser primaryPresenter selectMethodNamed: #test_addCategory.
	commitCommand := ((sunitBrowser view viewNamed: 'toolbar') itemAtIndex: 2) command.
	sunitBrowser primaryPresenter perform: commitCommand.
	
	[self assert: sunitBrowser primaryPresenter packageListPresenter selection name
		equals: 'Rowan-Services-Tests'.
	self assert: sunitBrowser primaryPresenter classListPresenter selection name
		equals: 'RowanClassServiceTest'.
	self assert: sunitBrowser primaryPresenter methodListPresenter selections size equals: 1.
	self assert: sunitBrowser primaryPresenter methodListPresenter selections first selector
		equals: #test_addCategory]
			ensure: 
				["don't want committed sample project in tests"
				self unloadSampleProject.
				sunitBrowser primaryPresenter perform: commitCommand.
				self cloneRowanSample1.
				self ensureRowanSample1Loaded]!

test_dontChangeTabs
	| methodService |
	self testsIssue: #issue405 withTitle: 'SUnit select class flips sunit pane in PB to the method'.
	projectsBrowser := JadeiteTestResource current openProjectsBrowser.
	self selectRowanSample1Test.
	methodService := self projectsPresenter methodListPresenter list
				detect: [:svc | svc selector = #test1].
	self projectsPresenter methodListPresenter selection: methodService.
	self projectsPresenter selectSUnitTab.
	self selectServiceNamed: 'RowanSample1-Tests' in: self sunitPresenter packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: self sunitPresenter classListPresenter.
	self assert: self projectsPresenter textAreaTabs currentCard
				= (self projectsPresenter view viewNamed: 'sunit')!

test_dontClearResults
	self testsIssue: #issue410
		withTitle: 'Selecting class in Project Browser changes test status icons in SUnit Browser'.
	self selectServiceNamed: 'RowanSample1-Tests' in: self sunitPresenter packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: self sunitPresenter classListPresenter.
	self assert: self sunitPresenter methodListPresenter list size equals: 4.
	self selectSUnitBrowserMethodNamed: #test1.
	self sunitPresenter runSelected.
	self assert: self sunitPresenter methodListPresenter selections first selector equals: #test1.
	self assert: self sunitPresenter methodListPresenter selections first testResult equals: 'passed'.
	projectsBrowser := JadeiteTestResource current openProjectsBrowser.
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	self assert: self methodListPresenter selections first selector equals: #test1.
	self assert: self sunitPresenter methodListPresenter selections first selector equals: #test1.
	self assert: self sunitPresenter methodListPresenter selections first testResult equals: 'passed'!

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

test_openTwoSUnitBrowsersLosingPackageSelection
	"unreported bug - losing selections if second sunit browser open"

	| secondSunitBrowser |
	self selectServiceNamed: 'RowanSample1-Tests' in: self sunitPresenter packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: self sunitPresenter classListPresenter.
	self selectSUnitBrowserMethodNamed: #test1.
	self assert: self sunitPresenter packageListPresenter selections first name
		equals: 'RowanSample1-Tests'.
	self assert: self sunitPresenter classListPresenter selections first name equals: 'RowanSample1Test'.
	self assert: self sunitPresenter methodListPresenter selections first selector equals: #test1.
	secondSunitBrowser := self openWindow: [transcript jadeBrowseTests].
	
	[self assert: self sunitPresenter packageListPresenter selections first name
		equals: 'RowanSample1-Tests'.
	self assert: self sunitPresenter classListPresenter selections first name equals: 'RowanSample1Test'.
	self assert: self sunitPresenter methodListPresenter selections first selector equals: #test1.
	self selectServiceNamed: 'RowanSample1-Tests'
		in: secondSunitBrowser primaryPresenter packageListPresenter.
	self assert: self sunitPresenter packageListPresenter selections first name
		equals: 'RowanSample1-Tests'.
	self assert: self sunitPresenter classListPresenter selections first name equals: 'RowanSample1Test'.
	self assert: self sunitPresenter methodListPresenter selections first selector equals: #test1]
			ensure: [secondSunitBrowser destroy]!

test_refresh
	| source newMethod |
	self testsIssue: #issue279 withTitle: 'Sunit browser refresh, auto or manual'.
	projectsBrowser := JadeiteTestResource current openProjectsBrowser.
	
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

test_registeredPresentersInSUnitBrowserCleanedUp
	| registeredPresenters secondBrowser |
	registeredPresenters := BrowserUpdate current registeredPresenters size.
	secondBrowser := self openWindow: [transcript jadeBrowseTests].
	self assert: BrowserUpdate current registeredPresenters size > registeredPresenters.
	secondBrowser destroy.
	secondBrowser := nil.
	self assert: BrowserUpdate current registeredPresenters size equals: registeredPresenters!

test_resetStatusBar
	self testsIssue: #issue411 withTitle: 'SUnit browser''s colored status bar is sticky'.
	self selectServiceNamed: 'Rowan-Services-Tests' in: self sunitPresenter packageListPresenter.
	self selectServiceNamed: 'JadeServerTest' in: self sunitPresenter classListPresenter.
	self sunitPresenter runAll.
	self
		assert: ('* run, * passed, 0 failures, 0 errors' match: self sunitPresenter textResultPresenter value).
	self assert: self sunitPresenter textResultPresenter view backcolor equals: Color darkGreen.
	self selectServiceNamed: 'RowanAnsweringServiceTest' in: self sunitPresenter classListPresenter.
	self assert: self sunitPresenter textResultPresenter value equals: String new.
	self assert: self sunitPresenter textResultPresenter view backcolor equals: Color face3d.
	self sunitPresenter runAll.
	self
		assert: ('* run, * passed, 0 failures, 0 errors' match: self sunitPresenter textResultPresenter value).
	self assert: self sunitPresenter textResultPresenter view backcolor equals: Color darkGreen.
	self selectServiceNamed: 'Rowan-Tests' in: self sunitPresenter packageListPresenter.
	self assert: self sunitPresenter textResultPresenter view backcolor equals: Color face3d.
	!

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

test_saveMethodInProjectBrowser
	"should show up in sunit browser and disappear when removed"

	| source |
	self testsIssue: #issue395 withTitle: '(3.0.54) Sunit can display non-test methods'.
	self selectServiceNamed: 'RowanSample1-Tests' in: self sunitPresenter packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: self sunitPresenter classListPresenter.
	self selectSUnitBrowserMethodsNamed: (Array with: #test1).
	self assertIsNil: (self sunitPresenter methodListPresenter model
				detect: [:methodService | methodService selector = #testInProjectBrowser]
				ifNone: []).
	projectsBrowser := JadeiteTestResource current openProjectsBrowser.
	self selectRowanSample1Test.
	source := 'testInProjectBrowser  
		| aaa | 
		aaa := 123. 
		^aaa'.
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	
	[self assert: self projectsPresenter methodListPresenter selection selector
		equals: #testInProjectBrowser.
	self denyIsNil: (self sunitPresenter methodListPresenter model
				detect: [:methodService | methodService selector = #testInProjectBrowser]
				ifNone: [])]
			ensure: [self projectsPresenter basicRemoveMethods].
	self assertIsNil: (self projectsPresenter methodListPresenter model
				detect: [:methodService | methodService selector = #testInProjectBrowser]
				ifNone: []).
	self assertIsNil: (self sunitPresenter methodListPresenter model
				detect: [:methodService | methodService selector = #testInProjectBrowser]
				ifNone: [])!

test_selectCategoryInProjectBrowserDoesNotUpdateSunitBrowser
	| sunitDisplayedMethodCount sunitDisplaySelectors |
	self testsIssue: #issue395 withTitle: '(3.0.54) Sunit can display non-test methods'.
	self selectServiceNamed: 'Rowan-Services-Tests' in: self sunitPresenter packageListPresenter.
	self selectServiceNamed: 'RowanClassServiceTest' in: self sunitPresenter classListPresenter.
	sunitDisplayedMethodCount := self sunitPresenter methodListPresenter list size.
	sunitDisplaySelectors := self sunitPresenter methodListPresenter list
				collect: [:methodService | methodService selector].
	projectsBrowser := JadeiteTestResource current openProjectsBrowser.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Tests' in: self packageListPresenter.
	self selectServiceNamed: 'RowanClassServiceTest' in: self classListPresenter.
	self selectCategoryNamed: 'support'.
	self assert: self sunitPresenter methodListPresenter list size equals: sunitDisplayedMethodCount.	"no changes"
	self assert: (self sunitPresenter methodListPresenter list
				collect: [:methodService | methodService selector])
		equals: sunitDisplaySelectors.
	self projectsPresenter methodListPresenter list
		do: [:methodService | self deny: ('test*' match: methodService selector asString)].
	self categoryListPresenter selections: #(). 
	self selectCategoryNamed: 'tests'.
	self assert: self sunitPresenter methodListPresenter list size equals: sunitDisplayedMethodCount.	"no changes"
	self assert: (self sunitPresenter methodListPresenter list
				collect: [:methodService | methodService selector])
		equals: sunitDisplaySelectors.
	self projectsPresenter methodListPresenter list
		do: [:methodService | self assert: ('test*' match: methodService selector asString)].

!

test_selectClassDoesNotLoseTestResults
	| secondBrowser |
	self testsIssue: #issue432
		withTitle: 'Fix for cross-browser clearing test results is incomplete in 3.0.60'.
	projectsBrowser := JadeiteTestResource current openProjectsBrowser.
	self selectRowanSample1Test.
	self projectsPresenter selectSUnitTab.
	secondBrowser := JadeiteProjectsSystemBrowser showOnSession: session.
	
	[
	self projectsPresenter sunitPresenter runAll.
	self assert: self projectsPresenter sunitPresenter methodListPresenter list first testResult
		equals: 'passed'.
	self assert: self projectsPresenter sunitPresenter methodListPresenter list second testResult
		equals: 'passed'.
	self selectServiceNamed: 'RowanSample1' in: secondBrowser currentCard projectListPresenter .
	self selectServiceNamed: 'RowanSample1-Tests' in: secondBrowser currentCard packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: secondBrowser currentCard classListPresenter.
	self assert: self projectsPresenter sunitPresenter methodListPresenter list first testResult
		equals: 'passed'.
	self assert: self projectsPresenter sunitPresenter methodListPresenter list second testResult
		equals: 'passed']
			ensure: [secondBrowser destroy]!

test_selectInProjectBrowserDoesNotUpdateSunitBrowser
	| sunitDisplayedMethodCount sunitDisplaySelectors |
	self testsIssue: #issue395 withTitle: '(3.0.54) Sunit can display non-test methods'.
	self selectServiceNamed: 'Rowan-Services-Tests' in: self sunitPresenter packageListPresenter.
	self selectServiceNamed: 'RowanClassServiceTest' in: self sunitPresenter classListPresenter.
	sunitDisplayedMethodCount := self sunitPresenter methodListPresenter list size.
	sunitDisplaySelectors := self sunitPresenter methodListPresenter list
				collect: [:methodService | methodService selector].
	projectsBrowser := JadeiteTestResource current openProjectsBrowser.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Tests' in: self packageListPresenter.
	self selectServiceNamed: 'RowanClassServiceTest' in: self classListPresenter.
	self assert: self sunitPresenter methodListPresenter list size equals: sunitDisplayedMethodCount.	"no changes"
	self assert: (self sunitPresenter methodListPresenter list
				collect: [:methodService | methodService selector])
		equals: sunitDisplaySelectors.
	self selectServiceNamed: 'RowanAnsweringServiceTest' in: self classListPresenter.	"click away in project browser and back - no changes"
	self selectServiceNamed: 'RowanClassServiceTest' in: self classListPresenter.
	self assert: self sunitPresenter methodListPresenter list size equals: sunitDisplayedMethodCount.	"no changes"
	self assert: (self sunitPresenter methodListPresenter list
				collect: [:methodService | methodService selector])
		equals: sunitDisplaySelectors!

test_selectMethodFromProjectBrowser
	self testsIssue: #issue395 withTitle: '(3.0.54) Sunit can display non-test methods'.
	self selectServiceNamed: 'RowanSample1-Tests' in: self sunitPresenter packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: self sunitPresenter classListPresenter.
	self selectSUnitBrowserMethodsNamed: (Array with: #test1).
	projectsBrowser := JadeiteTestResource current openProjectsBrowser.
	self selectRowanSample1Test.
	self selecProjectBrowserMethodNamed: #test1.
	self assert: sunitBrowser primaryPresenter methodListPresenter selections first selector
		equals: #test1.
	self assert: sunitBrowser primaryPresenter methodListPresenter selections size equals: 1.
	self assert: self methodListPresenter selections first selector equals: #test1.
	self assert: self methodListPresenter selections size equals: 1.
	self selectSUnitBrowserMethodsNamed: (Array with: #test2).
	self assert: sunitBrowser primaryPresenter methodListPresenter selections first selector
		equals: #test2.
	self assert: sunitBrowser primaryPresenter methodListPresenter selections size equals: 1.
	self assert: self projectsPresenter methodListPresenter selections first selector equals: #test1.
	self assert: self projectsPresenter methodListPresenter selections size equals: 1.
	self selecProjectBrowserMethodNamed: #test2.
	self assert: sunitBrowser primaryPresenter methodListPresenter selections first selector
		equals: #test2.
	self assert: sunitBrowser primaryPresenter methodListPresenter selections size equals: 1.
	self assert: self projectsPresenter methodListPresenter selections first selector equals: #test2.
	self assert: self projectsPresenter methodListPresenter selections size equals: 1!

test_statusBar
	"sanity check that the status bar matches what's in the method list"

	| classService |
	self selectServiceNamed: 'Rowan-Services-Tests' in: self sunitPresenter packageListPresenter.
	self selectServiceNamed: 'JadeServerTest' in: self sunitPresenter classListPresenter.
	classService := self sunitPresenter classListPresenter selections first.
	self assert: self sunitPresenter methodListPresenter list size
		equals: classService visibleTests size.
	self assert: self sunitPresenter testCasesSize
		equals: 'Test Cases:' , self sunitPresenter methodListPresenter model size printString.
	self assert: self sunitPresenter testClassesSize
		equals: 'Test Classes:' , ((session executeString: 'RowanServicesTest allSubclasses size') + 2) printString  "brittle but we can update it as test classes are added" !

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

test_sunitBrowserUpdateRightClassInHierarchy
	"inherited test runs don't impact test results of super class test runs"

	self testsIssue: #issue419 withTitle: 'Sunit confused by multiple Sunit tabs in project browser'.
	self selectServiceNamed: 'RowanSample1-Tests' in: self sunitPresenter packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: self sunitPresenter classListPresenter.
	self assert: self sunitPresenter methodListPresenter list first testResult equals: nil.
	projectsBrowser := JadeiteTestResource current openProjectsBrowser.
	self selectRowanSample1Test.
	self
		saveClass: 'RowanSample1TestSubclass'
		superclass: 'RowanSample1Test'
		instVars: #()
		package: 'RowanSample1-Tests'.
	
	[self projectsPresenter selectSUnitTab.
	self projectsPresenter sunitPresenter runAll.
	self assert: self projectsPresenter sunitPresenter methodListPresenter list first testResult
		equals: 'passed'.
	self assert: self sunitPresenter methodListPresenter list first testResult equals: nil.
	self selectServiceNamed: 'RowanSample1-Tests' in: self sunitPresenter packageListPresenter.
	self selectServiceNamed: 'RowanSample1TestSubclass' in: self sunitPresenter classListPresenter.
	self projectsPresenter sunitPresenter runAll.
	self assert: self projectsPresenter sunitPresenter methodListPresenter list first testResult
		equals: 'passed'.
	self assert: self sunitPresenter methodListPresenter list first testResult equals: 'passed']
			ensure: [self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass].!

test_sunitBrowserUpdateRightClassInHierarchy2
	"inherited test runs don't impact test results of super class test runs"

	self testsIssue: #issue419 withTitle: 'Sunit confused by multiple Sunit tabs in project browser'.
	self selectServiceNamed: 'RowanSample1-Tests' in: self sunitPresenter packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: self sunitPresenter classListPresenter.
	self assert: self sunitPresenter methodListPresenter list first testResult equals: nil.
	projectsBrowser := JadeiteTestResource current openProjectsBrowser.
	self selectRowanSample1Test.
	self
		saveClass: 'RowanSample1TestSubclass'
		superclass: 'RowanSample1Test'
		instVars: #()
		package: 'RowanSample1-Tests'.
	
	[self projectsPresenter selectSUnitTab.
	self projectsPresenter sunitPresenter reset. 
	self sunitPresenter runAll.
	self assert: self projectsPresenter sunitPresenter methodListPresenter list first testResult
		equals: nil.
	self assert: self sunitPresenter methodListPresenter list first testResult equals: 'passed'.
	self selectServiceNamed: 'RowanSample1-Tests' in: self sunitPresenter packageListPresenter.
	self selectServiceNamed: 'RowanSample1TestSubclass' in: self sunitPresenter classListPresenter.
	self sunitPresenter runAll.
	self assert: self projectsPresenter sunitPresenter methodListPresenter list first testResult
		equals: 'passed'.
	self assert: self sunitPresenter methodListPresenter list first testResult equals: 'passed']
			ensure: [self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass]!

test_sunitBrowserUpdates
	self testsIssue: #issue410
		withTitle: 'Selecting class in Project Browser changes test status icons in SUnit Browser'.
	self selectServiceNamed: 'RowanSample1-Tests' in: self sunitPresenter packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: self sunitPresenter classListPresenter.
	projectsBrowser := JadeiteTestResource current openProjectsBrowser.
	self projectsPresenter sunitPresenter reset. 
	self selectRowanSample1Test.
	self projectsPresenter selectSUnitTab.
	self assert: self projectsPresenter sunitPresenter methodListPresenter list first selector
		equals: #test1.
	self assertIsNil: self projectsPresenter sunitPresenter methodListPresenter list first testResult.
	self assert: self sunitPresenter methodListPresenter list first selector
		equals: #test1.
	self assertIsNil: self sunitPresenter methodListPresenter list first testResult.
	self projectsPresenter sunitPresenter runAll.
	"assert tests in sunit browser updated"
	self assert: self  sunitPresenter methodListPresenter list first selector
		equals: #test1.
	self assert: self sunitPresenter methodListPresenter list first testResult equals: 'passed'.
	self assert: self projectsPresenter sunitPresenter methodListPresenter list second selector
		equals: #test2.
	self assert: self projectsPresenter sunitPresenter methodListPresenter list first testResult equals: 'passed'!

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

test_sunitTabUpdates
	self testsIssue: #issue410
		withTitle: 'Selecting class in Project Browser changes test status icons in SUnit Browser'.
	self selectServiceNamed: 'RowanSample1-Tests' in: self sunitPresenter packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: self sunitPresenter classListPresenter.
	projectsBrowser := JadeiteTestResource current openProjectsBrowser.
	self projectsPresenter sunitPresenter reset. 
	self selectRowanSample1Test.
	self projectsPresenter selectSUnitTab.
	self assert: self projectsPresenter sunitPresenter methodListPresenter list first selector
		equals: #test1.
	self assertIsNil: self projectsPresenter sunitPresenter methodListPresenter list first testResult.
	self sunitPresenter runAll.
	"assert tests in project browser sunit presenter updated"
	self assert: self projectsPresenter sunitPresenter methodListPresenter list first selector
		equals: #test1.
	self assert: self sunitPresenter methodListPresenter list first testResult equals: 'passed'.
	self assert: self projectsPresenter sunitPresenter methodListPresenter list second selector
		equals: #test2.
	self assert: self projectsPresenter sunitPresenter methodListPresenter list first testResult equals: 'passed'!

test_testsRunInSelectedTestClass
	self testsIssue: #issue391 withTitle: '(3.0.53) SUnit browser running test method in wrong class'.
	projectsBrowser := self openWindow: [transcript openJadeiteProjectsBrowser].
	
	[self setupRunInSelectedTestClassTest.
	self selectServiceNamed: 'RowanSample1-Tests' in: self sunitPresenter packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: self sunitPresenter classListPresenter.
	self selectSUnitBrowserMethodsNamed: (Array with: #test_method).
	self assert: self sunitPresenter debug isKindOf: JadeiteSUnitPresenter.
	self assert: self sunitPresenter textResultPresenter view backcolor equals: Color darkGreen.
	self assert: self sunitPresenter textResultPresenter value
		equals: '1 run, 1 passed, 0 failures, 0 errors'.
	self assert: (session executeString: 'RowanSample1Test testClassVar') equals: #RowanSample1Test.
	self assert: self sunitPresenter runSelected isKindOf: JadeTestResult. "runSelected sends back the result of the last test" 
	self assert: self sunitPresenter textResultPresenter view backcolor equals: Color darkGreen.
	self assert: self sunitPresenter textResultPresenter value
		equals: '1 run, 1 passed, 0 failures, 0 errors'.
	self assert: (session executeString: 'RowanSample1Test testClassVar') equals: #RowanSample1Test.
	self assert: self sunitPresenter runAll isKindOf: JadeTestResult. "runSelected sends back the result of the last test" 
	self assert: (session executeString: 'RowanSample1Test testClassVar') equals: #RowanSample1Test.
	"set the selected class to the subclass, but the test will be run in the super.
	Ensure the test was run in the subclass" 
	self selectServiceNamed: 'RowanSample1SubClassTest' in: self sunitPresenter classListPresenter.
	self selectSUnitBrowserMethodsNamed: (Array with: #test_method).
	self assert: self sunitPresenter debug isKindOf: JadeiteSUnitPresenter.
	self assert: self sunitPresenter textResultPresenter view backcolor equals: Color darkGreen.
	self assert: self sunitPresenter textResultPresenter value
		equals: '1 run, 1 passed, 0 failures, 0 errors'.
	self assert: (session executeString: 'RowanSample1Test testClassVar') equals: #RowanSample1SubClassTest.
	self assert: self sunitPresenter runSelected isKindOf: JadeTestResult. "runSelected sends back the result of the last test" 
	self assert: self sunitPresenter textResultPresenter view backcolor equals: Color darkGreen.
	self assert: self sunitPresenter textResultPresenter value
		equals: '1 run, 1 passed, 0 failures, 0 errors'.
	self assert: (session executeString: 'RowanSample1Test testClassVar') equals: #RowanSample1SubClassTest.
	self assert: self sunitPresenter runAll isKindOf: JadeTestResult. "runSelected sends back the result of the last test" 
	self assert: (session executeString: 'RowanSample1Test testClassVar') equals: #RowanSample1SubClassTest.
	]
			ensure: [projectsBrowser destroy]! !
!JadeiteSUnitSupportTestCase categoriesFor: #assertPackageInList:!private!support! !
!JadeiteSUnitSupportTestCase categoriesFor: #denyPackageInList:!private!support! !
!JadeiteSUnitSupportTestCase categoriesFor: #isSampleProjectLoaded!private!support! !
!JadeiteSUnitSupportTestCase categoriesFor: #methodListPresenter!public!support! !
!JadeiteSUnitSupportTestCase categoriesFor: #projectsPresenter!private!support! !
!JadeiteSUnitSupportTestCase categoriesFor: #selecProjectBrowserMethodNamed:!public!support! !
!JadeiteSUnitSupportTestCase categoriesFor: #selecProjectBrowserMethodsNamed:!public!support! !
!JadeiteSUnitSupportTestCase categoriesFor: #selectSUnitBrowserMethodNamed:!public!support! !
!JadeiteSUnitSupportTestCase categoriesFor: #selectSUnitBrowserMethodsNamed:!public!support! !
!JadeiteSUnitSupportTestCase categoriesFor: #setUp!public!support! !
!JadeiteSUnitSupportTestCase categoriesFor: #setupRunInSelectedTestClassTest!private!support! !
!JadeiteSUnitSupportTestCase categoriesFor: #setupTestSuperclass!private!support! !
!JadeiteSUnitSupportTestCase categoriesFor: #sunitPresenter!public!support! !
!JadeiteSUnitSupportTestCase categoriesFor: #tearDown!public!support! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_abortNoSelections!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_abortWithSelections!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_browseMethods!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_browseSunitClass!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_commitNoSelections!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_commitWithSelections!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_dontChangeTabs!public!test updates from other browsers! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_dontClearResults!public!test updates from other browsers! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_inheritedTests!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_multiSelectClasses!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_multiSelectNoDuplicates!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_openSunitBrowser!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_openTwoSUnitBrowsersLosingPackageSelection!public!test updates from other browsers! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_refresh!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_registeredPresentersInSUnitBrowserCleanedUp!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_resetStatusBar!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_runClassTests!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_saveMethodInProjectBrowser!public!test updates from other browsers!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_selectCategoryInProjectBrowserDoesNotUpdateSunitBrowser!public!test updates from other browsers!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_selectClassDoesNotLoseTestResults!public!test updates from other browsers! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_selectInProjectBrowserDoesNotUpdateSunitBrowser!public!test updates from other browsers!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_selectMethodFromProjectBrowser!public!test updates from other browsers!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_statusBar!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_sunitBrowserHasRowanPackages!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_sunitBrowserHasRowanTestClasses!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_sunitBrowserHasRowanTestMethods!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_sunitBrowserPassingDebugTestShowsResult!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_sunitBrowserUpdateRightClassInHierarchy!public!test updates from other browsers! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_sunitBrowserUpdateRightClassInHierarchy2!public!test updates from other browsers! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_sunitBrowserUpdates!public!test updates from other browsers! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_sunitTabPassingDebugTestShowsResult!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_sunitTabUpdates!public!test updates from other browsers! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_testsRunInSelectedTestClass!public!tests! !

