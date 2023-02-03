"Filed out from Dolphin Smallalk"!

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

makeLotsOfChanges
	self
		saveMethod: 'aaa  ^123'
		in: 'RowanSample1Test'
		category: 'deleteMe'.
	self
		saveMethod: 'zzz  ^123'
		in: 'RowanSample1Test'
		category: 'deleteMe'.
	self
		saveMethod: 'mmm  ^123'
		in: 'RowanSample1Test'
		category: 'deleteMe'.
	self
		saveMethod: 'test1 ^$f'
		in: 'RowanSample1Test'
		category: 'deleteMe'.
	self
		saveMethod: 'test2 ^$f'
		in: 'RowanSample1Test'
		category: 'deleteMe'.
	self selectMethodNamed: #testFailure.
	self projectsPresenter removeMethods: (Array with: self projectsPresenter selectedClass).
	self
		saveMethod: 'notAnotherMethod  ^123'
		in: 'RowanSample1'
		category: 'ulp'.
	self
		saveMethod: 'yesIndeed  ^123'
		in: 'RowanSample1'
		category: 'ulp'!

setUp
	super setUp.
	projectsBrowser
		ifNil: [projectsBrowser := self openWindow: [JadeiteBrowser showOnSession: session]]!

tearDown
	super tearDown.
	changesBrowser ifNotNil: [self destroy: changesBrowser].
	projectsBrowser ifNotNil: [self destroy: projectsBrowser]!

test_additionalAccelerators
	"No way yet to adequately test accelerators function
	but we can assert that we tell Dolphin to set them up"

	self testsIssue: #issue329 withTitle: 'Need accelerator key tests'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	changesBrowser := self projectListPresenter selection changesUsing: session.
	self assert: (changesBrowser additionalAccelerators includes: #(#raiseConsole 'Ctrl+F7')).
	self assert: changesBrowser additionalAccelerators size equals: 1	"should fail if we add a new one"!

test_browseImplementors
	| methodListBrowser |
	self testsIssue: #issue407
		withTitle: '(3.0.56) would like option to browse class OR method from changes window'.
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

test_browseImplementorsOfRemovedMethod
	| methodListBrowser |
	self testsIssue: #issue837
		withTitle: '(3.1.0) Should be legal to `browser implementors or senders` of a removed method from changes browser'.
	self selectRowanSample1Class.
	self
		saveMethod: 'test2  ^123'
		in: 'RowanSample1'
		category: 'deleteMe'.
	self selectRowanSample1Test.
	self selectMethodNamed: #test2.
	self projectsPresenter removeMethods: (Array with: self projectsPresenter selectedClass).
	changesBrowser := self projectListPresenter selection changesUsing: session.
	self assert: changesBrowser operationListPresenter list last isKindOf: MCRemoval.
	changesBrowser operationListPresenter selectionByIndex: 2. 
	self assert: changesBrowser operationListPresenter selection isKindOf: MCRemoval.
	changesBrowser operationListPresenter selection: (changesBrowser operationListPresenter list
				detect: [:chg | chg definition className = 'RowanSample1Test']).
	self assert: changesBrowser operationListPresenter selection className equals: 'RowanSample1Test'.
	self assert: changesBrowser operationListPresenter selection selector equals: 'test2'.
	self assert: changesBrowser operationListPresenter selection isMethodRemoval.
	methodListBrowser := changesBrowser browseImplementors.
	
	[self assert: methodListBrowser primaryPresenter methodListPresenter selection selector
		equals: #test2.
	self assert: methodListBrowser primaryPresenter methodListPresenter selection className
		equals: 'RowanSample1'.
	self assert: methodListBrowser primaryPresenter methodListPresenter methodListPresenter list size equals: 1.
	self assert: methodListBrowser primaryPresenter methodListPresenter methodListPresenter selection source
		equals: 'test2  ^123']
			ensure: 
				[self destroy: methodListBrowser.
				self destroy: projectsBrowser]!

test_browseImplementorsOfRevertedChange
	| methodListBrowser |
	self testsIssue: #issue686
		withTitle: 'Changes Browser Browse senders/implementors doesn''t work after reverting changes (3.0.92)'.
	self selectRowanSample1Test.
	self
		saveMethod: 'test2  ^123'
		in: 'RowanSample1Test'
		category: 'deleteMe'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	changesBrowser := self projectListPresenter selection changesUsing: session.
	self assert: changesBrowser operationListPresenter list first isKindOf: MCModification.
	changesBrowser operationListPresenter selection: changesBrowser operationListPresenter list first.
	self assert: changesBrowser operationListPresenter selection className equals: 'RowanSample1Test'.
	self assert: changesBrowser operationListPresenter selection selector equals: 'test2'.
	self assert: changesBrowser operationListPresenter selection typeString equals: 'Modification'. 
	changesBrowser revert.
	self assert: changesBrowser operationListPresenter selection typeString equals: 'Modification (reverted)'.
	methodListBrowser := changesBrowser browseImplementors.
	
	[self assert: methodListBrowser primaryPresenter methodListPresenter selection selector
		equals: #test2]
			ensure: 
				[self destroy: methodListBrowser.
				self destroy: projectsBrowser]!

test_browseImplementorsSelectsChangedMethod
	| methodListBrowser |
	self testsIssue: #issue407
		withTitle: '(3.0.56) would like option to browse class OR method from changes window'.
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

test_browseOfRevertedChange
	| secondProjectBrowser |
	self testsIssue: #issue686
		withTitle: 'Changes Browser Browse senders/implementors doesn''t work after reverting changes (3.0.92)'.
	self selectRowanSample1Test.
	self
		saveMethod: 'test2  ^123'
		in: 'RowanSample1Test'
		category: 'deleteMe'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	changesBrowser := self projectListPresenter selection changesUsing: session.
	self assert: changesBrowser operationListPresenter list first isKindOf: MCModification.
	changesBrowser operationListPresenter selection: changesBrowser operationListPresenter list first.
	self assert: changesBrowser operationListPresenter selection className equals: 'RowanSample1Test'.
	self assert: changesBrowser operationListPresenter selection selector equals: 'test2'.
	self assert: changesBrowser operationListPresenter selection typeString equals: 'Modification'. 
	changesBrowser revert.
	self assert: changesBrowser operationListPresenter selection typeString equals: 'Modification (reverted)'.
	secondProjectBrowser := changesBrowser browseChangedThing.
	[self assert: secondProjectBrowser currentCard methodListPresenter selection selector equals: #test2] ensure: 
			[self destroy: secondProjectBrowser.
			self destroy: projectsBrowser]!

test_browseSenders
	| methodListBrowser |
	self testsIssue: #issue407
		withTitle: '(3.0.56) would like option to browse class OR method from changes window'.
	self selectRowanSample1Class.
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
			ensure: [self destroy: methodListBrowser]!

test_browseSendersOfRevertedChange
	| methodListBrowser |
	self testsIssue: #issue686
		withTitle: 'Changes Browser Browse senders/implementors doesn''t work after reverting changes (3.0.92)'.
	self selectRowanSample1Test.
	self
		saveMethod: 'test2  ^123'
		in: 'RowanSample1Test'
		category: 'deleteMe'.
	self
		saveMethod: 'zzzSendTest2  ^self test2'
		in: 'RowanSample1Test'
		category: 'deleteMe'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	changesBrowser := self projectListPresenter selection changesUsing: session.
	self assert: changesBrowser operationListPresenter list first isKindOf: MCModification.
	changesBrowser operationListPresenter selection: changesBrowser operationListPresenter list first.
	self assert: changesBrowser operationListPresenter selection className equals: 'RowanSample1Test'.
	self assert: changesBrowser operationListPresenter selection selector equals: 'test2'.
	self assert: changesBrowser operationListPresenter selection typeString equals: 'Modification'. 
	changesBrowser revert.
	self assert: changesBrowser operationListPresenter selection typeString equals: 'Modification (reverted)'.
	methodListBrowser := changesBrowser browseSenders.
	
	[self assert: methodListBrowser primaryPresenter methodListPresenter selection selector
		equals: #zzzSendTest2]
			ensure: 
				[self destroy: methodListBrowser.
				self destroy: projectsBrowser]!

test_changesAlphabetized
	"alphabetize by class then method"

	self selectRowanSample1Test.
	self makeLotsOfChanges.
	
	[changesBrowser := self projectListPresenter selection changesUsing: session.
	self assert: (changesBrowser operationListPresenter list collect: [:patch | patch selector]) asArray
		equals: #('notAnotherMethod' 'yesIndeed' 'aaa' 'mmm' 'test1' 'test2' 'testFailure' 'zzz')	"first two are in RowanSample1"	"last few are in RowanSample1Test"]
			ensure: [self destroy: projectsBrowser]!

test_identicalSource
	self testsIssue: #issue764
		withTitle: 'Changes Browser confusing handling of newlines in method text (3.1.pr3)'.
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	"save method with functionally equivalent source"
	self
		saveMethod: 'test1

	self assert: 
RowanSample1 
new foo = ''foo'''
		in: 'RowanSample1Test'
		category: 'deleteMe'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	changesBrowser := self projectListPresenter selection changesUsing: session.
	self assert: changesBrowser operationListPresenter list first isKindOf: MCModification.
	changesBrowser operationListPresenter selection: changesBrowser operationListPresenter list first.
	changesBrowser includeIdenticalPresenter value: false.
	self assert: changesBrowser operationListPresenter list isEmpty.
	changesBrowser includeIdenticalPresenter value: true.
	self assert: changesBrowser operationListPresenter list size equals: 1.
	changesBrowser operationListPresenter selection: changesBrowser operationListPresenter list first.
	self assert: changesBrowser operationListPresenter selection className equals: 'RowanSample1Test'.
	self assert: changesBrowser operationListPresenter selection selector equals: 'test1'!

test_noExtraLF
	| change |
	self testsIssue: #issue742 withTitle: '(3.0.93) Incomple revert in changes browser'.
	self selectRowanSample1Test.
	self
		saveMethod: 'test1  ^123'
		in: 'RowanSample1Test'
		category: 'deleteMe'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	changesBrowser := self projectListPresenter selection changesUsing: session.
	change := changesBrowser operationListPresenter list first.
	changesBrowser operationListPresenter selectionByIndex: 1.
	self assert: change isMethodModification.
	self assert: change modification source equals: 'test1  ^123'.
	self deny: change modification source last equals: Character lf.
	self deny: change obsoletion source last equals: Character lf.
	self assert: change obsoletion source replaceLfWithCrLf
		equals: 'test1

	self assert: RowanSample1 new foo = ''foo'''.
	changesBrowser operationListPresenter selection: change.
	self assert: changesBrowser operationListPresenter selection modification selector equals: 'test1'.
	self assert: changesBrowser operationListPresenter selection typeString equals: 'Modification'. 
	changesBrowser revert.
	self assert: change modification source replaceLfWithCrLf
		equals: 'test1

	self assert: RowanSample1 new foo = ''foo'''.
	self assert: changesBrowser operationListPresenter selection typeString equals: 'Modification (reverted)'. 
	self assert: changesBrowser diffsPresenter afterTitlePresenter value equals: 'Image (no change)'!

test_packageNameShowsMovedMethod
	| addition removal |
	self testsIssue: #issue302 withTitle: 'Need to add Package to Rowan Project Changes list'.
	self selectRowanSample1Class.
	self selectMethodNamed: #foo.
	self assert: self methodListPresenter selection packageName equals: 'RowanSample1-Core'.
	self projectsPresenter moveMethodsToPackageNamed: 'RowanSample1-Extensions'.
	self assert: self methodListPresenter selection selector equals: #foo.
	self assert: self methodListPresenter selection packageName equals: 'RowanSample1-Extensions'.
	changesBrowser := self projectListPresenter selection changesUsing: session.
	self assert: changesBrowser operationListPresenter list size equals: 2.
	addition := changesBrowser operationListPresenter list first.
	self assert: addition packageName equals: 'RowanSample1-Extensions'.
	self assert: addition selector equals: #foo.
	self assert: addition detailsString equals: '*rowansample1-extensions'.
	self assert: addition className equals: 'RowanSample1'.
	self assert: addition isMethodAddition.
	removal := changesBrowser operationListPresenter list second.
	self assert: removal packageName equals: 'RowanSample1-Core'.
	self assert: removal selector equals: #foo.
	self assert: removal detailsString equals: 'accessing'.
	self assert: removal className equals: 'RowanSample1'.
	self assert: removal isMethodRemoval!

test_packageNamesInClassChanges
	| change |
	self testsIssue: #issue302 withTitle: 'Need to add Package to Rowan Project Changes list'.
	self selectRowanSample1Class.
	self
		saveClass: 'Fnoodle'
		superclass: 'RowanSample1'
		instVars: #()
		package: 'RowanSample1-Core'.
	changesBrowser := self projectListPresenter selection changesUsing: session.
	self assert: changesBrowser operationListPresenter list size equals: 1.
	change := changesBrowser operationListPresenter list first.
	self assert: change packageName equals: 'RowanSample1-Core'.
	self selectRowanSample1Test.
	self
		saveClass: 'RowanSample1Test'
		superclass: 'TestCase'
		instVars: #('erp')
		package: 'RowanSample1-Tests'.
	changesBrowser refresh.
	self assert: changesBrowser operationListPresenter list size equals: 2.
	change := changesBrowser operationListPresenter list second.
	self assert: change modification className equals: 'RowanSample1Test'.
	self assert: change packageName equals: 'RowanSample1-Tests'.
	self selectRowanSample1Class.
	self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass.
	changesBrowser refresh.
	self assert: changesBrowser operationListPresenter list size equals: 5.	"add 3 changes. Class removal + 2 method removals"
	change := changesBrowser operationListPresenter list fourth.
	self assert: change definition className equals: 'RowanSample1'.
	self assert: change packageName equals: 'RowanSample1-Core'!

test_packageNamesInMethodChanges
	| change |
	self testsIssue: #issue302 withTitle: 'Need to add Package to Rowan Project Changes list'.
	self selectRowanSample1Test.
	self
		saveMethod: 'test1  ^456'
		in: 'RowanSample1Test'
		category: 'deleteMe'.
	changesBrowser := self projectListPresenter selection changesUsing: session.
	self assert: changesBrowser operationListPresenter list size equals: 1.
	change := changesBrowser operationListPresenter list first.
	self assert: change packageName equals: 'RowanSample1-Tests'.
	self assert: change isMethodModification.
	self assert: change modification source equals: 'test1  ^456'.
	self selectMethodNamed: #testError.
	self projectsPresenter basicRemoveMethods.
	changesBrowser refresh.
	self assert: changesBrowser operationListPresenter list size equals: 2.
	change := changesBrowser operationListPresenter list second.
	self assert: change isMethodRemoval.
	self assert: change definition selector equals: #testError.
	self assert: change packageName equals: 'RowanSample1-Tests'.
	self
		saveMethod: 'testNewMethod  ^456'
		in: 'RowanSample1Test'
		category: 'deleteMe'.
	changesBrowser refresh.
	self assert: changesBrowser operationListPresenter list size equals: 3.
	change := changesBrowser operationListPresenter list third.
	self assert: change isMethodAddition.
	self assert: change definition selector equals: #testNewMethod.
	self assert: change packageName equals: 'RowanSample1-Tests'!

test_revertClassMethod
	| secondProjectBrowser |
	self testsIssue: #issue867
		withTitle: '(Oscar-3.1.1-release1) revert of a class method restores as an instance method (apparently)'.
	self selectRowanSample1Class.
	self
		saveClassMethod: 'bar  ^123'
		in: 'RowanSample1'
		category: 'deleteMe'.
	changesBrowser := self projectListPresenter selection changesUsing: session.
	self assert: changesBrowser operationListPresenter list first isKindOf: MCModification.
	changesBrowser operationListPresenter selection: changesBrowser operationListPresenter list first.
	self assert: changesBrowser operationListPresenter selection className equals: 'RowanSample1 class'.
	self assert: changesBrowser operationListPresenter selection obsoletion classIsMeta. 
	self assert: changesBrowser operationListPresenter selection selector equals: 'bar'.
	self assert: changesBrowser operationListPresenter selection typeString equals: 'Modification'. 
	changesBrowser revert.
	self assert: changesBrowser operationListPresenter selection typeString equals: 'Modification (reverted)'.
	secondProjectBrowser := changesBrowser browseChangedThing.
	[self assert: secondProjectBrowser currentCard methodListPresenter selection selector equals: #bar] ensure: 
			[self destroy: secondProjectBrowser.
			self destroy: projectsBrowser]!

test_revertMethodAddition
	| change |
	self testsIssue: #issue624
		withTitle: '(3.0.85) A revert menu item in the changes browser would be useful'.
	self selectRowanSample1Test.
	self
		saveMethod: 'ooble  ^123'
		in: 'RowanSample1Test'
		category: 'deleteMe'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	changesBrowser := self projectListPresenter selection changesUsing: session.
	change := changesBrowser operationListPresenter list first.
	self assert: change isMethodAddition.
	self assert: change definition source trimBlanks equals: 'ooble  ^123'.
	changesBrowser operationListPresenter selection: change.
	changesBrowser revert.
	self assert: change definition selector equals: 'ooble (removed)'!

test_revertMethodModification
	| change |
	self testsIssue: #issue624
		withTitle: '(3.0.85) A revert menu item in the changes browser would be useful'.
	self selectRowanSample1Test.
	self
		saveMethod: 'test1  ^123'
		in: 'RowanSample1Test'
		category: 'deleteMe'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	changesBrowser := self projectListPresenter selection changesUsing: session.
	change := changesBrowser operationListPresenter list first.
	self assert: change isMethodModification.
	self assert: change modification source trimBlanks equals: 'test1  ^123'.
	self assert: change obsoletion source trimBlanks replaceLfWithCrLf
		equals: 'test1

	self assert: RowanSample1 new foo = ''foo'''.
	changesBrowser operationListPresenter selection: change.
	self assert: changesBrowser operationListPresenter selection modification selector equals: 'test1'.
	self assert: changesBrowser operationListPresenter selection typeString equals: 'Modification'. 
	changesBrowser revert.
	self assert: change modification source trimBlanks replaceLfWithCrLf
		equals: 'test1

	self assert: RowanSample1 new foo = ''foo'''.
	self assert: changesBrowser operationListPresenter selection typeString equals: 'Modification (reverted)'.
	self assert: changesBrowser diffsPresenter afterTitlePresenter value equals: 'Image (no change)'!

test_revertMethodRemoval
	| change |
	self testsIssue: #issue624
		withTitle: '(3.0.85) A revert menu item in the changes browser would be useful'.
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	self projectsPresenter removeMethods: self classListPresenter selections.
	self assertIsNil: (self methodListPresenter list
				detect: [:methodService | methodService selector = #test1]
				ifNone: []).
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	changesBrowser := self projectListPresenter selection changesUsing: session.
	change := changesBrowser operationListPresenter list first.
	self assert: change isMethodRemoval.
	changesBrowser operationListPresenter selection: change.
	self assert: change definition source trimBlanks replaceLfWithCrLf
		equals: 'test1

	self assert: RowanSample1 new foo = ''foo'''.
	changesBrowser revert.
	self selectRowanSample1Test.
	self
		denyIsNil: (self methodListPresenter list detect: [:methodService | methodService selector = #test1]
				ifNone: []).
	self assert: change definition selector equals: 'test1 (restored)'.
	self assert: (changesBrowser operationListPresenter view getItemText: 1) equals: 'Removal (reverted)'.!

test_unicodeSource
	| source change |
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	source := 'test1

	self assert: RowanSample1 new foo = ''¶'''.
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	changesBrowser := self projectListPresenter selection changesUsing: session.
	change := changesBrowser operationListPresenter list first.
	self assert: change isMethodModification.
	changesBrowser operationListPresenter selection: change.
	self assert: change modification source trimBlanks replaceLfWithCrLf
		equals: 'test1

	self assert: RowanSample1 new foo = ''¶'''.
	self assert: change obsoletion source trimBlanks replaceLfWithCrLf
		equals: 'test1

	self assert: RowanSample1 new foo = ''foo'''! !
!JadeiteChangesBrowserTestCase categoriesForMethods!
addNewClass!private! !
addNewMethod!private! !
makeLotsOfChanges!public!support!tests! !
setUp!private!setup teardown! !
tearDown!private!setup teardown! !
test_additionalAccelerators!public!tests! !
test_browseImplementors!public!tests! !
test_browseImplementorsOfRemovedMethod!public!tests! !
test_browseImplementorsOfRevertedChange!public!tests! !
test_browseImplementorsSelectsChangedMethod!public!tests! !
test_browseMethodSelectsAddedClass!public!tests! !
test_browseMethodSelectsAddedMethod!public!tests! !
test_browseOfRevertedChange!public!tests! !
test_browseSenders!public!tests! !
test_browseSendersOfRevertedChange!public!tests! !
test_changesAlphabetized!public!tests! !
test_identicalSource!public!tests! !
test_noExtraLF!public!tests! !
test_packageNameShowsMovedMethod!public!tests! !
test_packageNamesInClassChanges!public!tests! !
test_packageNamesInMethodChanges!public!tests! !
test_revertClassMethod!public!tests! !
test_revertMethodAddition!public!tests! !
test_revertMethodModification!public!tests! !
test_revertMethodRemoval!public!tests! !
test_unicodeSource!public!tests! !
!

