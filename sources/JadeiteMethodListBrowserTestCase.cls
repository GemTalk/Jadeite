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

selectMethodsNamed: selectors
	| methodServices methodListPresenter |
	methodListPresenter := methodListBrowser primaryPresenter methodListPresenter methodListPresenter.
	methodListPresenter resetSelection.
	methodServices := selectors
				collect: [:selector | methodListPresenter list detect: [:svc | svc selector = selector]].
	methodListPresenter selections: methodServices.
	^methodServices!

tearDown
	super tearDown.
	methodListBrowser
		ifNotNil: 
			[self destroy: methodListBrowser.
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
		ensure: [self destroy: projectsBrowser].
	self methodSourcePresenter documentPresenter view selectionRange: (55 to: 64).
	dictionaryPresenter := self methodSourcePresenter browseSelectedClass.
	[self assert: dictionaryPresenter selectedClassName equals: 'TranscriptStreamPortable']
		ensure: [self destroy: dictionaryPresenter topShell].
	self methodSourcePresenter documentPresenter view selectionRange: (90 to: 95).
	dictionaryPresenter := self methodSourcePresenter browseSelectedClass.
	[self assert: ('String*' match: dictionaryPresenter selectedClassName)]
		ensure: [self destroy: dictionaryPresenter topShell]!

test_browseHierarchyImplementorsEnablement
	| commandQuery methodListPresenter |
	self testsIssue: #issue399
		withTitle: 'The "exactly one object" warning may also provide an unrelated debugger stack'.
	methodListBrowser := JadePresenter browseSendersOf: #foo session: session.
	self selectMethodsNamed: #(#test1).
	methodListPresenter := methodListBrowser primaryPresenter methodListPresenter.
	methodListPresenter methodListPresenter selection: (methodListPresenter methodListPresenter list
				detect: [:methodService | methodService selector = #test1]).
	commandQuery := self
				queryCommand: #browseHierarchyImplementors
				inPresenter: methodListPresenter
				view: methodListPresenter view.
	self assert: commandQuery isEnabled.
	self selectMethodsNamed: #(#test1 #testFailure).
	commandQuery := self
				queryCommand: #browseHierarchyImplementors
				inPresenter: methodListPresenter
				view: methodListPresenter view.
	self deny: commandQuery isEnabled.
	self selectMethodsNamed: #().
	commandQuery := self
				queryCommand: #browseHierarchyImplementors
				inPresenter: methodListPresenter
				view: methodListPresenter view.
	self deny: commandQuery isEnabled!

test_browseHierarchySendersEnablement
	| commandQuery methodListPresenter |
	self testsIssue: #issue399
		withTitle: 'The "exactly one object" warning may also provide an unrelated debugger stack'.
	methodListBrowser := JadePresenter browseSendersOf: #foo session: session.
	self selectMethodsNamed: #(#test1).
	methodListPresenter := methodListBrowser primaryPresenter methodListPresenter.
	methodListPresenter methodListPresenter selection: (methodListPresenter methodListPresenter list
				detect: [:methodService | methodService selector = #test1]).
	commandQuery := self
				queryCommand: #browseHierarchySenders
				inPresenter: methodListPresenter
				view: methodListPresenter view.
	self assert: commandQuery isEnabled.
	self selectMethodsNamed: #(#test1 #testFailure).
	commandQuery := self
				queryCommand: #browseHierarchySenders
				inPresenter: methodListPresenter
				view: methodListPresenter view.
	self deny: commandQuery isEnabled.
	self selectMethodsNamed: #().
	commandQuery := self
				queryCommand: #browseHierarchySenders
				inPresenter: methodListPresenter
				view: methodListPresenter view.
	self deny: commandQuery isEnabled!

test_browseImplementorsEnablement
	| commandQuery methodListPresenter |
	self testsIssue: #issue399
		withTitle: 'The "exactly one object" warning may also provide an unrelated debugger stack'.
	methodListBrowser := JadePresenter browseSendersOf: #foo session: session.
	self selectMethodsNamed: #(#test1).
	methodListPresenter := methodListBrowser primaryPresenter methodListPresenter.
	methodListPresenter methodListPresenter selection: (methodListPresenter methodListPresenter list
				detect: [:methodService | methodService selector = #test1]).
	commandQuery := self
				queryCommand: #browseImplementors
				inPresenter: methodListPresenter
				view: methodListPresenter view.
	self assert: commandQuery isEnabled.
	self selectMethodsNamed: #(#test1 #testFailure).
	commandQuery := self
				queryCommand: #browseImplementors
				inPresenter: methodListPresenter
				view: methodListPresenter view.
	self deny: commandQuery isEnabled.
	self selectMethodsNamed: #().
	commandQuery := self
				queryCommand: #browseImplementors
				inPresenter: methodListPresenter
				view: methodListPresenter view.
	self deny: commandQuery isEnabled!

test_browseSendersEnablement
	| commandQuery methodListPresenter |
	self testsIssue: #issue399
		withTitle: 'The "exactly one object" warning may also provide an unrelated debugger stack'.
	methodListBrowser := JadePresenter browseSendersOf: #foo session: session.
	self selectMethodsNamed: #(#test1).
	methodListPresenter := methodListBrowser primaryPresenter methodListPresenter.
	methodListPresenter methodListPresenter selection: (methodListPresenter methodListPresenter list
				detect: [:methodService | methodService selector = #test1]).
	commandQuery := self
				queryCommand: #browseSenders
				inPresenter: methodListPresenter
				view: methodListPresenter view.
	self assert: commandQuery isEnabled.
	self selectMethodsNamed: #(#test1 #testFailure).
	commandQuery := self
				queryCommand: #browseSenders
				inPresenter: methodListPresenter
				view: methodListPresenter view.
	self deny: commandQuery isEnabled.
	self selectMethodsNamed: #().
	commandQuery := self
				queryCommand: #browseSenders
				inPresenter: methodListPresenter
				view: methodListPresenter view.
	self deny: commandQuery isEnabled!

test_compileErrorDisplay
	| source |
	self testsIssue: #issue459 withTitle: 'CompileWarnings should be more noticable ... '.
	methodListBrowser := JadePresenter browseImplementorsOf: #test1 session: session.
	self assert: methodListBrowser primaryPresenter methodListPresenter selection selector
		equals: #test1.
	source := 'test1 self assert: RowanSample1 new foo = ''abc'.	"won't compile"
	self methodListSourcePresenter documentPresenter value: source.
	self assert: self methodListSourcePresenter documentPresenter isModified.
	self methodListSourcePresenter editSaveMethod.
	self assert: (methodListBrowser view viewNamed: 'statusBarField') forecolor equals: Color black.
	self assert: (methodListBrowser view viewNamed: 'statusBarField') backcolor equals: Color red faded!

test_compileErrorDisplayGoesAway
	| source |
	self testsIssue: #issue459 withTitle: 'CompileWarnings should be more noticable ... '.
	self
		saveMethod: 'abc1  self foogle'
		in: 'RowanSample1'
		category: 'other'.
	self
		saveMethod: 'abc2  self foogle'
		in: 'RowanSample1'
		category: 'other'.
	methodListBrowser := JadePresenter browseSendersOf: #foogle session: session.
	self assert: methodListBrowser primaryPresenter methodListPresenter selection selector equals: #abc1.
	source := 'abc1  self foo #'.	"won't compile"
	self methodListSourcePresenter documentPresenter value: source.
	self assert: self methodListSourcePresenter documentPresenter isModified.
	self methodListSourcePresenter editSaveMethod.
	self assert: (methodListBrowser view viewNamed: 'statusBarField') forecolor equals: Color black.
	self assert: (methodListBrowser view viewNamed: 'statusBarField') backcolor equals: Color red faded.
	self assert: (methodListBrowser view viewNamed: 'statusBarField') model value
		equals: 'invalid pound sign'.
	methodListBrowser primaryPresenter methodListPresenter primaryPresenter selectionByIndex: 2.
	self deny: (methodListBrowser view viewNamed: 'statusBarField') backcolor equals: Color red faded.
	self assert: (methodListBrowser view viewNamed: 'statusBarField') model value equals: String new!

test_doubleClickActionClassMethod
	| methodServices methodListPresenter |
	self testsIssue: #issue403
		withTitle: 'Double click in method browser change class to show instance methods'.
	methodListBrowser := JadePresenter browseImplementorsOf: #bar session: session.
	methodListPresenter := methodListBrowser primaryPresenter methodListPresenter.
	methodListPresenter methodListPresenter resetSelection.
	methodServices := (Array with: #bar) collect: 
					[:selector |
					methodListPresenter methodListPresenter list
						detect: [:svc | svc selector = selector and: [svc className = 'RowanSample1']]].
	methodListPresenter methodListPresenter selections: methodServices.
	self assert: methodListPresenter selection meta.
	projectsBrowser := methodListPresenter browseClass.
	
	[self assert: self classListPresenter selection meta.
	self assert: self projectsPresenter isClassSideSelected.
	self assert: methodListPresenter selection selector equals: #bar]
			ensure: [self destroy: projectsBrowser]!

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
			ensure: [self destroy: projectsBrowser]!

test_methodBrowserSaveMethod
	projectsBrowser := JadeiteTestResource current openProjectsBrowser.
	
	[| source source2 selection |
	self selectRowanSample1Test.
	self selectMethodNamedInProjectBrowser: #test1.
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
			ensure: [self destroy: projectsBrowser]!

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
	self selectMethodNamedInProjectBrowser: #deleteMe.
	self projectsPresenter basicRemoveMethods.
	self denyMethodInList: #deleteMe.
	self assert: self methodListMethodListPresenter list size equals: 1.
	self assert: self methodListMethodListPresenter selections isEmpty.
	self assert: self methodListMethodListPresenter list first className asString
		equals: 'RowanSample1Test']
			ensure: [self destroy: projectsBrowser]!

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
!JadeiteMethodListBrowserTestCase categoriesFor: #selectMethodsNamed:!public!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #tearDown!public!setup teardown! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseClass!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseHierarchyImplementorsEnablement!public!test menus! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseHierarchySendersEnablement!public!test menus! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseImplementorsEnablement!public!test menus! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseSendersEnablement!public!test menus! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_compileErrorDisplay!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_compileErrorDisplayGoesAway!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_doubleClickActionClassMethod!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_doubleClickActionInstanceMethod!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_methodBrowserSaveMethod!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_removeMethod!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_removeMethodInProjectBrowser!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_UnsavedChangesActionChangeSelectionIgnoreChanges!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_UnsavedChangesActionChangeSelectionStayOnMethod!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_UnsavedChangesActionCloseWindow!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_UnsavedChangesActionCloseWindowStayOnMethod!public!tests! !

