"Filed out from Dolphin Smalltalk 7"!

JadeiteAbstractTestCase subclass: #JadeiteChangesBrowserTestCase
	instanceVariableNames: 'changesBrowser'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteChangesBrowserTestCase guid: (GUID fromString: '{e716d8ac-bd87-4da8-b84e-c8936c4a6450}')!
JadeiteChangesBrowserTestCase comment: ''!
!JadeiteChangesBrowserTestCase categoriesForClass!Unclassified! !
!JadeiteChangesBrowserTestCase methodsFor!

addNewClass
	self
		saveClass: 'NewTestClass'
		withInstVars: #('abc')
		package: 'RowanSample1-Core'!

addNewMethod
	| source |
	source := 'newMethod
	"RowanSample1 new newMethod"
	^123 + 456'.
	self
		saveMethod: source
		in: 'RowanSample1Test'
		category: 'addition'!

tearDown
	changesBrowser ifNotNil: [changesBrowser destroy]!

test_browseMethodSelectsAddedClass
	| projectService secondProjectBrowser |
	self testsIssue: #issue415 withTitle: 'Browse changes on a class definition change handled poorly'.
	projectsBrowser
		ifNil: [projectsBrowser := self openWindow: [transcript openJadeiteProjectsBrowser]].
	self selectRowanSample1Class. 
	self addNewClass.
	projectService := transcript projectListPresenter projectListPresenter list
				detect: [:service | service name = 'RowanSample1'].
	transcript projectListPresenter projectListPresenter selection: projectService.
	changesBrowser := projectService changesUsing: session.
	self assert: changesBrowser operationListPresenter list first isKindOf: MCAddition.
	changesBrowser operationListPresenter selection: changesBrowser operationListPresenter list first.
	self assert: changesBrowser operationListPresenter selection className equals: 'NewTestClass'. 
	secondProjectBrowser := changesBrowser browseChangedThing.
	
	[self assert: secondProjectBrowser currentCard classListPresenter selection name
		equals: 'NewTestClass']
			ensure: 
				[secondProjectBrowser currentCard basicRemoveMethods.
				secondProjectBrowser destroy.
				projectsBrowser destroy]!

test_browseMethodSelectsAddedMethod
	| projectService secondProjectBrowser |
	self testsIssue: #issue415 withTitle: 'Browse changes on a class definition change handled poorly'.
	self addNewMethod.
	projectService := transcript projectListPresenter projectListPresenter list
				detect: [:service | service name = 'RowanSample1'].
	transcript projectListPresenter projectListPresenter selection: projectService.
	changesBrowser := projectService changesUsing: session.
	self assert: changesBrowser operationListPresenter list first isKindOf: MCAddition.
	changesBrowser operationListPresenter selection: changesBrowser operationListPresenter list first.
	secondProjectBrowser := changesBrowser browseChangedThing.
	
	[self assert: secondProjectBrowser currentCard methodListPresenter selection selector
		equals: #newMethod.
	self assert: secondProjectBrowser currentCard classListPresenter selection name
		equals: 'RowanSample1Test']
			ensure: 
				[secondProjectBrowser currentCard basicRemoveMethods.
				secondProjectBrowser destroy]! !
!JadeiteChangesBrowserTestCase categoriesFor: #addNewClass!private! !
!JadeiteChangesBrowserTestCase categoriesFor: #addNewMethod!private! !
!JadeiteChangesBrowserTestCase categoriesFor: #tearDown!public!setup teardown! !
!JadeiteChangesBrowserTestCase categoriesFor: #test_browseMethodSelectsAddedClass!public!tests! !
!JadeiteChangesBrowserTestCase categoriesFor: #test_browseMethodSelectsAddedMethod!public!tests! !

