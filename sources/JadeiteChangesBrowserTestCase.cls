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
	super tearDown.
	changesBrowser ifNotNil: [self destroy: changesBrowser].
	projectsBrowser ifNotNil: [self destroy: projectsBrowser]!

test_browseImplementors
	| methodListBrowser |
	self testsIssue: #issue407
		withTitle: '(3.0.56) would like option to browse class OR method from changes window'.
	projectsBrowser
		ifNil: [projectsBrowser := self openWindow: [transcript openJadeiteProjectsBrowser]].
	self selectRowanSample1Class.
	self
		saveMethod: 'fnoodle  ^123'
		in: 'RowanSample1'
		category: 'deleteMe'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	changesBrowser := self projectListPresenter selection changesUsing: session.
	self assert: changesBrowser operationListPresenter list first isKindOf: MCAddition.
	changesBrowser operationListPresenter selection: changesBrowser operationListPresenter list first.
	self assert: changesBrowser operationListPresenter selection className equals: 'RowanSample1'.
	self assert: changesBrowser operationListPresenter selection selector equals: 'fnoodle'.
	methodListBrowser := changesBrowser browseImplementors.
	
	[self assert: methodListBrowser primaryPresenter methodListPresenter selection selector
		equals: #fnoodle]
			ensure: 
				[self destroy: methodListBrowser.
				self destroy: projectsBrowser]!

test_browseImplementorsSelectsChangedMethod
	| methodListBrowser |
	self testsIssue: #issue407
		withTitle: '(3.0.56) would like option to browse class OR method from changes window'.
	projectsBrowser
		ifNil: [projectsBrowser := self openWindow: [transcript openJadeiteProjectsBrowser]].
	self selectRowanSample1Class.
	self
		saveMethod: 'size  ^super size'
		in: 'RowanSample1'
		category: 'deleteMe'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	changesBrowser := self projectListPresenter selection changesUsing: session.
	changesBrowser operationListPresenter selectionByIndex: 1.
	methodListBrowser := changesBrowser browseImplementors.
	
	[self assert: methodListBrowser primaryPresenter methodListPresenter selection selector equals: #size.
	self assert: methodListBrowser primaryPresenter methodListPresenter selection className
		equals: 'RowanSample1']
			ensure: 
				[self destroy: methodListBrowser.
				self destroy: projectsBrowser]!

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
				self destroy: secondProjectBrowser.
				self destroy: projectsBrowser]!

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
				self destroy: secondProjectBrowser]!

test_browseSenders
	| methodListBrowser |
	self testsIssue: #issue407
		withTitle: '(3.0.56) would like option to browse class OR method from changes window'.
	projectsBrowser
		ifNil: [projectsBrowser := self openWindow: [JadeiteBrowser showOnSession: session]].
	
	[self selectRowanSample1Class.
	self
		saveMethod: 'fnoodle  ^123'
		in: 'RowanSample1'
		category: 'deleteMe'.
	self
		saveMethod: 'sendsFnoodle  ^self fnoodle'
		in: 'RowanSample1'
		category: 'deleteMe'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	changesBrowser := self projectListPresenter selection changesUsing: session.
	self assert: changesBrowser operationListPresenter list first isKindOf: MCAddition.
	self assert: changesBrowser operationListPresenter list last isKindOf: MCAddition.
	changesBrowser operationListPresenter selectionByIndex: 2.
	self assert: changesBrowser operationListPresenter selection className equals: 'RowanSample1'.
	self assert: changesBrowser operationListPresenter selection selector equals: 'sendsFnoodle'.
	changesBrowser operationListPresenter selectionByIndex: 1.
	self assert: changesBrowser operationListPresenter selection className equals: 'RowanSample1'.
	self assert: changesBrowser operationListPresenter selection selector equals: 'fnoodle'.
	methodListBrowser := changesBrowser browseSenders.
	
	[self assert: methodListBrowser primaryPresenter methodListPresenter selection selector
		equals: #sendsFnoodle]
			ensure: [self destroy: methodListBrowser]]
			ensure: [self destroy: projectsBrowser]! !
!JadeiteChangesBrowserTestCase categoriesFor: #addNewClass!private! !
!JadeiteChangesBrowserTestCase categoriesFor: #addNewMethod!private! !
!JadeiteChangesBrowserTestCase categoriesFor: #tearDown!private!setup teardown! !
!JadeiteChangesBrowserTestCase categoriesFor: #test_browseImplementors!public!tests! !
!JadeiteChangesBrowserTestCase categoriesFor: #test_browseImplementorsSelectsChangedMethod!public!tests! !
!JadeiteChangesBrowserTestCase categoriesFor: #test_browseMethodSelectsAddedClass!public!tests! !
!JadeiteChangesBrowserTestCase categoriesFor: #test_browseMethodSelectsAddedMethod!public!tests! !
!JadeiteChangesBrowserTestCase categoriesFor: #test_browseSenders!public!tests! !

