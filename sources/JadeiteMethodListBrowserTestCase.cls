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

removeMethods: methodServices in: className
	"remove method outside the browsers for performance"

	| classService |
	classService := RowanClassService named: className.
	classService methods: (methodServices select: [:service | service className = className]).
	classService
		command: #removeMethods;
		commandArgs: Array new.
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

testUnsavedChangesActionChangeSelectionIgnoreChanges
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

testUnsavedChangesActionChangeSelectionStayOnMethod
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

testUnsavedChangesActionCloseWindow
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

testUnsavedChangesActionCloseWindowStayOnMethod
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
!JadeiteMethodListBrowserTestCase categoriesFor: #removeMethods:in:!public!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #sampleMethodSource!public!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #saveMethod:in:category:!public!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #selectListAt:!public!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #tearDown!public!setup teardown! !
!JadeiteMethodListBrowserTestCase categoriesFor: #testUnsavedChangesActionChangeSelectionIgnoreChanges!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #testUnsavedChangesActionChangeSelectionStayOnMethod!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #testUnsavedChangesActionCloseWindow!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #testUnsavedChangesActionCloseWindowStayOnMethod!public!tests! !

