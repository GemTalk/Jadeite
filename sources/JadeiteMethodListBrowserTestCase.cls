"Filed out from Dolphin Smalltalk 7"!

JadeiteAbstractTestCase subclass: #JadeiteMethodListBrowserTestCase
	instanceVariableNames: 'methodListBrowser'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteMethodListBrowserTestCase guid: (GUID fromString: '{c29ccf97-1cb3-41d3-b4d3-41e60f3ceac9}')!
JadeiteMethodListBrowserTestCase comment: ''!
!JadeiteMethodListBrowserTestCase categoriesForClass!Unclassified! !
!JadeiteMethodListBrowserTestCase methodsFor!

methodListMethodListPresenter
	^methodListBrowser primaryPresenter methodListPresenter methodListPresenter!

methodListSourcePresenter
	^methodListBrowser primaryPresenter methodSourcePresenter!

methodSourcePresenter
	^methodListBrowser primaryPresenter methodSourcePresenter!

removeMethods: methodServices in: className
	"remove method outside the browsers for performance"

	| classService |
	classService := RowanClassService named: className.
	classService
		command: #removeMethods:;
		commandArgs: (Array
					with: (methodServices select: [:service | service className asString = className])).
	self issueCommand: classService!

sampleMethodSource
	^'sampleMethod  
		| aaa | 
		aaa := 123. 
		^aaa'. !

saveMethod: source in: className category: category
	"add method outside the browsers for performance" 
	| classService |
	classService := RowanClassService named: className.
	classService command: #saveMethodSource:category:; 
			commandArgs: (Array with: source with: category). 
	self issueCommand: classService. 
	!

selectListAt: integer
	"foolishly, the selection changing event which needs testing
	is only sent through a button click in Dolphin. We need to 
	fake it out for the test. frustrating.

	Note - even though we are faking up the event, the event itself
	should get modified based on the debugger's state which is a
	valid test."

	| event methodListPresenter |
	methodListPresenter := methodListBrowser primaryPresenter methodListPresenter methodListPresenter.
	event := (SelectionChangingEvent forSource: self)
				oldSelections: methodListPresenter selections;
				newSelections: (Array with: (methodListPresenter list at: integer));
				cause: #test;
				yourself.
	methodListPresenter onSelectionChanging: event.
	event value ifFalse: [^self].
	methodListPresenter selection: (methodListPresenter list at: integer)!

tearDown
	super tearDown.
	methodListBrowser
		ifNotNil: 
			[methodListBrowser destroy.
			methodListBrowser := nil]!

test_browseClass
	| dictionaryPresenter |
	self testsIssue: #issue429 withTitle: '(3.0.60) ''Browse Class'' on Transcript gets walkback'.
	methodListBrowser := JadePresenter browseImplementorsOf: #test1 session: session.
	self
		saveMethod: 'test1

	self assert: RowanSample1 new foo = ''foo''
	Transcript cr; show: ''fnoodle''. 
	String new.'
		in: self methodListMethodListPresenter selection className
		category: 'deleteMe'.
	self methodSourcePresenter documentPresenter view selectionRange: (24 to: 35).
	projectsBrowser := self methodSourcePresenter browseSelectedClass topShell.
	[self assert: self projectsPresenter selectedClass name equals: 'RowanSample1']
		ensure: [projectsBrowser destroy].
	self methodSourcePresenter documentPresenter view selectionRange: (55 to: 64).
	dictionaryPresenter := self methodSourcePresenter browseSelectedClass.
	[self assert: dictionaryPresenter currentCard selectedClassName equals: 'TranscriptStreamPortable']
		ensure: [dictionaryPresenter topShell destroy].
	self methodSourcePresenter documentPresenter view selectionRange: (90 to: 95).
	dictionaryPresenter := self methodSourcePresenter browseSelectedClass.
	[self assert: ('String*' match: dictionaryPresenter currentCard selectedClassName)]
		ensure: [dictionaryPresenter topShell destroy]!

test_doubleClickActionClassMethod
	self testsIssue: #issue403
		withTitle: 'Double click in method browser change class to show instance methods'.
	methodListBrowser := JadePresenter browseImplementorsOf: #bar session: session.
	self assert: self methodListMethodListPresenter list size equals: 1.
	self assert: self methodListMethodListPresenter selection meta.
	projectsBrowser := methodListBrowser primaryPresenter methodListPresenter browseClass.
	
	[self assert: self classListPresenter selection meta.
	self assert: self projectsPresenter isClassSideSelected.
	self assert: self methodListPresenter selection selector equals: #bar]
			ensure: [projectsBrowser destroy]!

test_doubleClickActionInstanceMethod
	self testsIssue: #issue403
		withTitle: 'Double click in method browser change class to show instance methods'.
	methodListBrowser := JadePresenter browseImplementorsOf: #foo session: session.
	self assert: self methodListMethodListPresenter list size equals: 1.
	self deny: self methodListMethodListPresenter selection meta.
	projectsBrowser := methodListBrowser primaryPresenter methodListPresenter browseClass.
	
	[self deny: self classListPresenter selection meta.
	self deny: self projectsPresenter isClassSideSelected.
	self assert: self methodListPresenter selection selector equals: #foo]
			ensure: [projectsBrowser destroy]!

test_methodBrowserSaveMethod
	projectsBrowser := JadeiteTestResource current openProjectsBrowser.
	
	[| source source2 selection |
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	self assert: self methodListPresenter selection selector equals: #test1.
	self assert: self methodListPresenter selections size equals: 1. 
	methodListBrowser := JadePresenter browseImplementorsOf: 'test1' session: session.
	self assert: self methodListPresenter selection selector equals: #test1.
	self assert: self methodListPresenter selections size equals: 1. 
	self assert: self methodListMethodListPresenter list size equals: 1.
	selection := self methodListMethodListPresenter selection.
	source := 'test1 self assert: RowanSample1 new foo = ''foo2'''.
	self methodListSourcePresenter documentPresenter value: source.
	self assert: self methodListSourcePresenter documentPresenter isModified.
	self methodListSourcePresenter editSaveMethod.
	self assert: self methodListSourcePresenter documentPresenter value equals: source.
	self assert: self methodSourcePresenter documentPresenter value equals: source.
	self assert: self classListPresenter selection name equals: 'RowanSample1Test'.
	self methodListMethodListPresenter selections: Array new.
	self methodListMethodListPresenter selection: selection.
	self assert: self methodListSourcePresenter documentPresenter value equals: source.
	source2 := 'test1 self assert: RowanSample1 new foo = ''changedAgain'''.
	self methodSourcePresenter value: source2.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self assert: self methodSourcePresenter documentPresenter value equals: source2.
	self assert: self methodListSourcePresenter documentPresenter value equals: source2]
			ensure: [projectsBrowser destroy]!

test_removeMethod
	self saveMethod: 'deleteMe ^123'  in: 'RowanSample1' category: 'other'. 
	self saveMethod: 'deleteMe ^#test'  in: 'RowanSample1Test' category: 'other'. 
	methodListBrowser := JadePresenter browseImplementorsOf: #deleteMe session: session.
	self assert: self methodListMethodListPresenter list size equals: 2. 
	self assert: self methodListMethodListPresenter selection className asString equals: 'RowanSample1'.  "first alphabetically"
	self removeMethods: (Array with: self methodListMethodListPresenter selection) in: 'RowanSample1'. 
	self assert: self methodListMethodListPresenter list size equals: 1. 
	self assert: self methodListMethodListPresenter selections isEmpty.
	self assert: self methodListMethodListPresenter list first className asString equals: 'RowanSample1Test'!

test_removeMethodInProjectBrowser
	self
		saveMethod: 'deleteMe ^123'
		in: 'RowanSample1'
		category: 'other'.
	self
		saveMethod: 'deleteMe ^#test'
		in: 'RowanSample1Test'
		category: 'other'.
	methodListBrowser := JadePresenter browseImplementorsOf: #deleteMe session: session.
	projectsBrowser := self openWindow: [transcript openJadeiteProjectsBrowser].
	
	[self selectRowanSample1Class.
	self selectMethodNamed: #deleteMe.
	self projectsPresenter basicRemoveMethods.
	self denyMethodInList: #deleteMe.
	self assert: self methodListMethodListPresenter list size equals: 1.
	self assert: self methodListMethodListPresenter selections isEmpty.
	self assert: self methodListMethodListPresenter list first className asString
		equals: 'RowanSample1Test']
			ensure: [projectsBrowser destroy]!

test_UnsavedChangesActionChangeSelectionIgnoreChanges
	| methodListPresenter |
	self testsIssue: #issue386
		withTitle: '(3.0.53) no warning about unsaved changes in method browser when clicking on different method'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[self
		saveMethod: self sampleMethodSource
		in: 'RowanSample1'
		category: 'other'.
	self
		saveMethod: self sampleMethodSource
		in: 'RowanSample1Test'
		category: 'other'.
	methodListBrowser := JadePresenter browseImplementorsOf: #sampleMethod session: session.
	methodListPresenter := methodListBrowser primaryPresenter methodListPresenter methodListPresenter.
	self assert: methodListPresenter selectionByIndex equals: 1.
	self assert: methodListPresenter list size equals: 2.
	methodListBrowser primaryPresenter methodSourcePresenter documentPresenter value: 'new text'.
	TestMessageBox plannedResult: #no.	"answer that we want to stay on frame"
	self selectListAt: 2.
	self assert: methodListPresenter selectionByIndex equals: 2]
			ensure: 
				[TestMessageBox disableJadeiteTestMessageBox.
				self removeMethods: methodListPresenter model asBag in: 'RowanSample1'.
				self removeMethods: methodListPresenter model asBag in: 'RowanSample1Test']!

test_UnsavedChangesActionChangeSelectionStayOnMethod
	| methodListPresenter |
	self testsIssue: #issue386
		withTitle: '(3.0.53) no warning about unsaved changes in method browser when clicking on different method'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[self
		saveMethod: self sampleMethodSource
		in: 'RowanSample1'
		category: 'other'.
	self
		saveMethod: self sampleMethodSource
		in: 'RowanSample1Test'
		category: 'other'.
	methodListBrowser := JadePresenter browseImplementorsOf: #sampleMethod session: session.
	methodListPresenter := methodListBrowser primaryPresenter methodListPresenter methodListPresenter.
	self assert: methodListPresenter selectionByIndex equals: 1.
	self assert: methodListPresenter list size equals: 2.
	methodListBrowser primaryPresenter methodSourcePresenter documentPresenter value: 'new text'.
	TestMessageBox plannedResult: #yes.	"answer that we want to stay on frame"
	self selectListAt: 2.
	self assert: methodListPresenter selectionByIndex equals: 1]
			ensure: 
				[TestMessageBox disableJadeiteTestMessageBox.
				self removeMethods: methodListPresenter model asBag in: 'RowanSample1'.
				self removeMethods: methodListPresenter model asBag in: 'RowanSample1Test']!

test_UnsavedChangesActionCloseWindow
	| methodListPresenter |
	self testsIssue: #issue386
		withTitle: '(3.0.53) no warning about unsaved changes in method browser when clicking on different method'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[self
		saveMethod: self sampleMethodSource
		in: 'RowanSample1'
		category: 'other'.
	self
		saveMethod: self sampleMethodSource
		in: 'RowanSample1Test'
		category: 'other'.
	methodListBrowser := JadePresenter browseImplementorsOf: #sampleMethod session: session.
	methodListPresenter := methodListBrowser primaryPresenter methodListPresenter methodListPresenter.
	self assert: methodListPresenter selectionByIndex equals: 1.
	self assert: methodListPresenter list size equals: 2.
	methodListBrowser primaryPresenter methodSourcePresenter documentPresenter value: 'new text'.
	TestMessageBox plannedResult: #no.	"answer that we want to stay on frame"
	methodListBrowser view close.
	self deny: methodListBrowser isOpen]
			ensure: 
				[TestMessageBox disableJadeiteTestMessageBox.
				self removeMethods: methodListPresenter model asBag in: 'RowanSample1'.
				self removeMethods: methodListPresenter model asBag in: 'RowanSample1Test']!

test_UnsavedChangesActionCloseWindowStayOnMethod
	| methodListPresenter |
	self testsIssue: #issue386
		withTitle: '(3.0.53) no warning about unsaved changes in method browser when clicking on different method'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[self
		saveMethod: self sampleMethodSource
		in: 'RowanSample1'
		category: 'other'.
	self
		saveMethod: self sampleMethodSource
		in: 'RowanSample1Test'
		category: 'other'.
	methodListBrowser := JadePresenter browseImplementorsOf: #sampleMethod session: session.
	methodListPresenter := methodListBrowser primaryPresenter methodListPresenter methodListPresenter.
	self assert: methodListPresenter selectionByIndex equals: 1.
	self assert: methodListPresenter list size equals: 2.
	methodListBrowser primaryPresenter methodSourcePresenter documentPresenter value: 'new text'.
	TestMessageBox plannedResult: #yes.	"answer that we want to stay on frame"
	methodListBrowser view close.
	self assert: methodListBrowser isOpen.
	self assert: methodListPresenter selectionByIndex equals: 1]
			ensure: 
				[TestMessageBox disableJadeiteTestMessageBox.
				self removeMethods: methodListPresenter model asBag in: 'RowanSample1'.
				self removeMethods: methodListPresenter model asBag in: 'RowanSample1Test']! !
!JadeiteMethodListBrowserTestCase categoriesFor: #methodListMethodListPresenter!private!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #methodListSourcePresenter!private!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #methodSourcePresenter!private!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #removeMethods:in:!public!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #sampleMethodSource!public!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #saveMethod:in:category:!public!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #selectListAt:!public!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #tearDown!public!setup teardown! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseClass!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_doubleClickActionClassMethod!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_doubleClickActionInstanceMethod!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_methodBrowserSaveMethod!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_removeMethod!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_removeMethodInProjectBrowser!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_UnsavedChangesActionChangeSelectionIgnoreChanges!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_UnsavedChangesActionChangeSelectionStayOnMethod!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_UnsavedChangesActionCloseWindow!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_UnsavedChangesActionCloseWindowStayOnMethod!public!tests! !

