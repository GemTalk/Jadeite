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

browseLiteralTest: literal
	methodListBrowser := JadePresenter browseLiteralReferences: literal printString session: session.
	
	[self selectMethodNamed: #literalRefTest.
	self assert: self methodListSelector equals: #literalRefTest.
	self assert: self sourcePresenter selection equals: literal printString]
			ensure: [methodListBrowser view close]!

methodListMethodListPresenter
	^methodListBrowser primaryPresenter methodListPresenter methodListPresenter!

methodListSelector
	^self methodListMethodListPresenter selection selector!

methodListSourcePresenter
	^methodListBrowser primaryPresenter methodSourcePresenter!

methodSourcePresenter
	^methodListBrowser primaryPresenter methodSourcePresenter!

removeMethods: methodServices in: className
	"remove method outside the browsers for performance"

	| classService |
	classService := RowanClassService named: className.
	classService meta: methodServices anyOne meta.	" assume for now that methods all have save meta"
	classService
		command: #removeMethods:;
		commandArgs: (Array
					with: (methodServices asArray select: [:service | service className asString = className])).
	self issueCommand: classService!

removeMultiKeywordSenderAndSendee
	#('jadeiteSender' 'jadeiteSendeeWith:keyword:' 'jadeiteSender2') do: 
			[:selector |
			self selectServiceNamed: selector in: self projectsPresenter methodListPresenter.
			self removeMethods: self methodListPresenter selections in: self projectsPresenter selectedClassName]!

removeTestMethodAndCloseProjectBrowser
	self removeMethods: (Array with: self projectsPresenter methodListPresenter selection)
		in: self projectsPresenter selectedClassName.
	^projectsBrowser view close!

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

selectMethodNamed: selector
	^self selectMethodsNamed: (Array with: selector) in: methodListBrowser!

selectMethodNamed: selector in: browser
	^self selectMethodsNamed: (Array with: selector) in: browser!

selectMethodsNamed: selectors
	^self selectMethodsNamed: selectors in: methodListBrowser!

selectMethodsNamed: selectors in: browser
	| methodServices methodListPresenter |
	methodListPresenter := browser primaryPresenter methodListPresenter methodListPresenter.
	methodListPresenter resetSelection.
	methodServices := selectors
				collect: [:selector | methodListPresenter list detect: [:svc | svc selector = selector]].
	methodListPresenter selections: methodServices.
	^methodServices!

setupMultiKeywordSenderAndSendee
	| source |
	source := 'jadeiteSender  ^self jadeiteSendeeWith: 1 keyword: 2'.
	self projectsPresenter selectMethodSourceTab.
	self projectsPresenter methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	source := 'jadeiteSender2  
"comment with sendee #jadeiteSendeeWith: multiple keyword:"
^self jadeiteSendeeWith: 1 keyword: 2'.
	self projectsPresenter selectMethodSourceTab.
	self projectsPresenter methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	source := 'jadeiteSendeeWith: multiple keyword: arguments	^multiple+arguments'.
	self projectsPresenter selectMethodSourceTab.
	self projectsPresenter methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection!

setupTestMethodInProjectBrowser
	| source |
	self openProjectBrowser.
	self selectRowanSample1Test.
	source := 'literalRefTest ^#(''foot'' #foot 123 nil true false)'.
	self projectsPresenter selectMethodSourceTab.
	self projectsPresenter methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection!

sourcePresenter
	^self methodListSourcePresenter documentPresenter!

tearDown
	super tearDown.
	methodListBrowser
		ifNotNil: 
			[methodListBrowser primaryPresenter methodSourcePresenter documentPresenter view isModified: false.
			self destroy: methodListBrowser.
			methodListBrowser := nil].
	projectsBrowser
		ifNotNil: 
			[projectsBrowser view close.
			projectsBrowser := nil]!

test_adHocContextClassSide
	| classService |
	self testsIssue: #issue517 withTitle: 'Context of non-debugger source panes should be the class'.
	self openProjectBrowser.
	self selectRowanSample1Test.
	self selectClassTab.
	classService := RowanClassService named: 'RowanSample1Test'.
	classService meta: true.
	classService
		saveMethod: 'fnoodle  ^#fnoodle'
		category: 'deleteMe'
		session: session.
	methodListBrowser := JadePresenter browseImplementorsOf: 'fnoodle' session: session.
	self methodSourcePresenter value: 'self fnoodle'.
	self methodSourcePresenter setFocus.
	
	[self methodSourcePresenter documentPresenter view selectAll.
	self methodSourcePresenter jadeDisplay.
	self assert: self methodSourcePresenter documentPresenter value equals: 'self fnoodle #''fnoodle''']
			ensure: 
				[self methodSourcePresenter documentPresenter view isModified: false.
				self removeMethods: self methodListMethodListPresenter selections in: 'RowanSample1Test']!

test_adHocContextInstanceSide
	| classService |
	self testsIssue: #issue517 withTitle: 'Context of non-debugger source panes should be the class'.
	self openProjectBrowser.
	self selectRowanSample1Test.
	classService := RowanClassService named: 'RowanSample1Test'.
	classService
		saveMethod: 'fnoodle  ^#fnoodle'
		category: 'deleteMe'
		session: session.
	methodListBrowser := JadePresenter browseImplementorsOf: 'fnoodle' session: session.
	self methodSourcePresenter value: 'self new fnoodle'.
	self methodSourcePresenter setFocus.
	
	[self methodSourcePresenter documentPresenter view selectAll.
	self methodSourcePresenter jadeDisplay.
	self assert: self methodSourcePresenter documentPresenter value
		equals: 'self new fnoodle #''fnoodle''']
			ensure: 
				[self methodSourcePresenter documentPresenter view isModified: false.
				self removeMethods: self methodListMethodListPresenter selections in: 'RowanSample1Test']!

test_browseBreakpoints
	| methodService |
	self testsIssue: #issue225 withTitle: 'nice to have a breakpoint browser'.
	methodListBrowser := JadePresenter browseBreakpointsIn: session.
	[self assert: self methodListMethodListPresenter list size equals: 0]
		ensure: [methodListBrowser view close].
	self openProjectBrowser.
	
	[self selectRowanSample1Test.
	methodService := self projectsPresenter methodListPresenter list
				detect: [:service | service selector = #test1].
	self projectsPresenter methodListPresenter selections: (Array with: methodService).
	self projectsPresenter setBreakPointAt: 5 in: self projectsPresenter.
	methodListBrowser := JadePresenter browseBreakpointsIn: session.
	
	[self assert: self methodListMethodListPresenter list size equals: 1.
	self assert: self methodListPresenter selection selector equals: #test1]
			ensure: [methodListBrowser view close].
	JadePresenter clearAllBreaksIn: session.
	methodListBrowser := JadePresenter browseBreakpointsIn: session.
	[self assert: self methodListMethodListPresenter list size equals: 0]
		ensure: [methodListBrowser view close]]
			ensure: [projectsBrowser view close]!

test_browseBreakpointsClearAllMenuItemFromMethodList
	| clearAllItem methodsMenu browseBreakpointsItem |
	self testsIssue: #issue515 withTitle: '(3.0.77) clear all breakpoints menu item would be useful'.
	self openProjectBrowser.
	
	[self selectRowanSample1Class.
	browseBreakpointsItem := self methodListPresenter view contextMenu items
				detect: [:command | '*Browse*Breakpoints*' match: command text]
				ifNone: [].
	self denyIsNil: browseBreakpointsItem.
	methodListBrowser := self projectsPresenter perform: browseBreakpointsItem command asSymbol.
	methodsMenu := methodListBrowser view menuBar items detect: [:menu | '*Methods*' match: menu text]
				ifNone: [].
	clearAllItem := methodsMenu items detect: [:command | '*Clear*All*Breakpoints*' match: command text]
				ifNone: [].
	self denyIsNil: clearAllItem.
	self assert: clearAllItem command asSymbol equals: #clearAllBreakpoints]
			ensure: [projectsBrowser view close]!

test_browseBreakpointsClearAllMenuItemFromTranscript
	| browseMenu clearAllItem methodsMenu browseBreakpointsItem |
	self testsIssue: #issue515 withTitle: '(3.0.77) clear all breakpoints menu item would be useful'.
	browseMenu := transcript view menuBar items detect: [:menu | '*Browse*' match: menu text] ifNone: [].
	browseBreakpointsItem := browseMenu items
				detect: [:command | '*Browse*Breakpoints*' match: command text]
				ifNone: [].
	self denyIsNil: browseBreakpointsItem.
	methodListBrowser := transcript perform: browseBreakpointsItem command asSymbol.
	methodsMenu := methodListBrowser view menuBar items detect: [:menu | '*Methods*' match: menu text]
				ifNone: [].
	clearAllItem := methodsMenu items detect: [:command | '*Clear*All*Breakpoints*' match: command text]
				ifNone: [].
	self denyIsNil: clearAllItem.
	self assert: clearAllItem command asSymbol equals: #clearAllBreakpoints!

test_browseBreakpointsFromTranscript
	| methodService |
	self testsIssue: #issue225 withTitle: 'nice to have a breakpoint browser'.
	methodListBrowser := transcript browseBreakpoints.
	[self assert: self methodListMethodListPresenter list size equals: 0]
		ensure: [methodListBrowser view close].
	self openProjectBrowser.
	
	[self selectRowanSample1Test.
	methodService := self projectsPresenter methodListPresenter list
				detect: [:service | service selector = #test1].
	self projectsPresenter methodListPresenter selections: (Array with: methodService).
	self projectsPresenter setBreakPointAt: 5 in: self projectsPresenter.
	methodListBrowser := JadePresenter browseBreakpointsIn: session.
	
	[self assert: self methodListMethodListPresenter list size equals: 1.
	self assert: self methodListPresenter selection selector equals: #test1]
			ensure: [methodListBrowser view close].
	JadePresenter clearAllBreaksIn: session.
	methodListBrowser := transcript browseBreakpoints.
	[self assert: self methodListMethodListPresenter list size equals: 0]
		ensure: [methodListBrowser view close]]
			ensure: [projectsBrowser view close]!

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

test_browseClassReferenceCaptionTitle
	methodListBrowser := JadePresenter browseClassReferences: 'AbstractCharacter' session: session.
	self assert: ('Class References of ''AbstractCharacter''*' match: methodListBrowser caption)!

test_browseClassReferences
	methodListBrowser := JadePresenter browseClassReferences: 'AbstractCharacter' session: session.
	self methodListMethodListPresenter list do: 
			[:methodService |
			self methodListMethodListPresenter selection: methodService.
			self assert: ('AbstractCharacter*' match: self methodSourcePresenter documentPresenter selection)	"use match because we might pickup a '.'"]!

test_browseClassReferencesEnablement
	| commandQuery methodListPresenter |
	methodListBrowser := JadePresenter browseImplementorsOf: #defaultAction session: session.
	self selectMethodsNamed: #(#defaultAction).
	methodListPresenter := methodListBrowser primaryPresenter methodListPresenter.
	methodListPresenter methodListPresenter selectionByIndex: 1.
	commandQuery := self
				queryCommand: #browseClassReferences
				inPresenter: methodListPresenter
				view: methodListPresenter view.
	self assert: commandQuery isEnabled.
	methodListPresenter methodListPresenter view selectionsByIndex: #(1 2).
	commandQuery := self
				queryCommand: #browseClassReferences
				inPresenter: methodListPresenter
				view: methodListPresenter view.
	self deny: commandQuery isEnabled.
	self selectMethodsNamed: #().
	commandQuery := self
				queryCommand: #browseClassReferences
				inPresenter: methodListPresenter
				view: methodListPresenter view.
	self deny: commandQuery isEnabled!

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

test_browseHierarchySenderHighlightingSameSelector
	self testsIssue: #issue500
		withTitle: '(Oscar-3.0.74) highlighting of multi-keyword selectors in senders/implementors browser is broken'.
	methodListBrowser := JadePresenter
				browseHierarchySendersOf: #servicePerform:withArguments:
				className: 'RowanService'
				session: session.
	self methodListMethodListPresenter list do: 
			[:methodService |
			self methodListMethodListPresenter selection: methodService.
			self assert: self methodSourcePresenter documentPresenter selection equals: 'servicePerform:']!

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

test_browseInstVarReaders
	self openProjectBrowser.
	self
		saveClass: 'TestInstVarReaders'
		superclass: 'Object'
		instVars: #('foo')
		package: 'RowanSample1-Core'.
	self
		saveMethod: 'foo  ^foo'
		in: 'TestInstVarReaders'
		category: 'accessing'.
	self
		saveMethod: 'foo: anObject  foo := anObject'
		in: 'TestInstVarReaders'
		category: 'accessing'.
	methodListBrowser := JadePresenter
				browseInstVarReaders: 'foo'
				in: 'TestInstVarReaders'
				session: session.
	self assert: self methodListMethodListPresenter list size equals: 1.
	self assert: self methodListMethodListPresenter list first selector = #foo!

test_browseInstVarWriters
	methodListBrowser := JadePresenter
				browseInstVarWriters: 'autoCommit'
				in: 'RowanAutoCommitService'
				session: session.
	self methodListMethodListPresenter list
		do: [:methodService | self assert: ('*autoCommit :=*' match: methodService source)]!

test_browseLiteralReferences
	self testsIssue: #issue328
		withTitle: '(3.0.50) I would have thought that the literal string ''filetree'' would have been found'.
	self setupTestMethodInProjectBrowser.
	
	[self browseLiteralTest: 'foot'.	"expect this to fail (at least in 3.2.15). The index given by the server is off by 1"
	self browseLiteralTest: #foot.
	self browseLiteralTest: 123.
	self browseLiteralTest: nil.
	self browseLiteralTest: true.
	self browseLiteralTest: false]
			ensure: [self removeTestMethodAndCloseProjectBrowser]!

test_browseLiteralReferencesBlankSearch
	"nil or an empty string can be passed into the search from the dialog. Make sure we reject those inputs"

	methodListBrowser := JadePresenter browseLiteralReferences: String new session: session.
	self assertIsNil: methodListBrowser.
	methodListBrowser := JadePresenter browseLiteralReferences: nil session: session.
	self assertIsNil: methodListBrowser!

test_browseMultiKeywordSendersHighlighting
	self testsIssue: #issue500
		withTitle: '(Oscar-3.0.74) highlighting of multi-keyword selectors in senders/implementors browser is broken'.
	self openProjectBrowser.
	
	[self selectRowanSample1Test.
	self setupMultiKeywordSenderAndSendee.
	methodListBrowser := JadePresenter browseSendersOf: #jadeiteSendeeWith:keyword: session: session.
	
	[self assert: self methodListSelector equals: #jadeiteSender.
	self assert: self sourcePresenter selection equals: 'jadeiteSendeeWith:']
			ensure: [methodListBrowser view close].
	methodListBrowser := JadePresenter
				browseHierarchySendersOf: 'jadeiteSendeeWith:keyword:'
				className: 'RowanSample1Test'
				session: session.
	
	[self assert: self methodListSelector equals: #jadeiteSender.
	self assert: self sourcePresenter selection equals: 'jadeiteSendeeWith:']
			ensure: [methodListBrowser view close]]
			ensure: 
				[self removeMultiKeywordSenderAndSendee.
				projectsBrowser view close]!

test_browseMultiKeywordSendersOnEverySender
	self testsIssue: #issue500
		withTitle: '(Oscar-3.0.74) highlighting of multi-keyword selectors in senders/implementors browser is broken'.
	self openProjectBrowser.
	
	[self selectRowanSample1Test.
	self setupMultiKeywordSenderAndSendee.
	methodListBrowser := JadePresenter browseSendersOf: #jadeiteSendeeWith:keyword: session: session.
	self assert: self methodListMethodListPresenter list size equals: 2.
	
	[self assert: self methodListSelector equals: #jadeiteSender.
	self assert: self sourcePresenter selection equals: 'jadeiteSendeeWith:'.
	self selectMethodNamed: #jadeiteSender2.
	self assert: self methodListSelector equals: #jadeiteSender2.
	self assert: self sourcePresenter selection equals: 'jadeiteSendeeWith:']
			ensure: [methodListBrowser view close]]
			ensure: 
				[self removeMultiKeywordSenderAndSendee.
				projectsBrowser view close]!

test_browseSenderHighlightedWithEveryMethod
	true
		ifTrue: 
			[^self	"test probably will error against 3.2.15. Not sure server returns proper 
	sender index when inlined blocks are presenter. See AbstractDictionary>>_reportKeyNotFound:with:
	when in a list of senders of value"].
	self testsIssue: #issue500
		withTitle: '(Oscar-3.0.74) highlighting of multi-keyword selectors in senders/implementors browser is broken'.
	methodListBrowser := JadePresenter browseSendersOf: #value session: session.
	self assert: self methodListMethodListPresenter list size > 1.	"should be many"
	self methodListMethodListPresenter list do: 
			[:methodService |
			self methodListMethodListPresenter selection: methodService.
			self assert: (self methodSourcePresenter documentPresenter selection copyFrom: 1 to: 5)
				equals: 'value'	"May select non separator characters like '.'  or ']' See JadeiteMethodListPresenter>>selecting: for details"]!

test_browseSenderHighlightingIgnoreComments
	self testsIssue: #issue500
		withTitle: '(Oscar-3.0.74) highlighting of multi-keyword selectors in senders/implementors browser is broken'.
	self openProjectBrowser.
	
	[self selectRowanSample1Test.
	self setupMultiKeywordSenderAndSendee.
	methodListBrowser := JadePresenter browseSendersOf: #jadeiteSendeeWith:keyword: session: session.
	
	[self selectMethodNamed: #jadeiteSender2.
	self assert: self methodListSelector equals: #jadeiteSender2.
	self assert: self sourcePresenter selection equals: 'jadeiteSendeeWith:'.
	self assert: self sourcePresenter selectionRange start equals: 84.	"not in the comment"
	self assert: self sourcePresenter selectionRange start
		equals: self methodListMethodListPresenter selection firstReference.
	self assert: (self sourcePresenter value copyFrom: 40 to: 57) equals: 'jadeiteSendeeWith:'	"didn't highlight the comment"]
			ensure: [methodListBrowser view close]]
			ensure: 
				[self removeMultiKeywordSenderAndSendee.
				projectsBrowser view close]!

test_browseSenderHighlightingSameSelector
	self testsIssue: #issue500
		withTitle: '(Oscar-3.0.74) highlighting of multi-keyword selectors in senders/implementors browser is broken'.
	methodListBrowser := JadePresenter browseSendersOf: #servicePerform:withArguments: session: session.
	self methodListMethodListPresenter list do: 
			[:methodService |
			self methodListMethodListPresenter selection: methodService.
			self assert: self methodSourcePresenter documentPresenter selection equals: 'servicePerform:']!

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

test_browseSendersFoo
	self testsIssue: #issue500
		withTitle: '(Oscar-3.0.74) highlighting of multi-keyword selectors in senders/implementors browser is broken'.
	methodListBrowser := JadePresenter browseSendersOf: #foo session: session.
	self methodListMethodListPresenter list do: 
			[:methodService |
			self methodListMethodListPresenter selection: methodService.
			self assert: ('foo*' match: self methodSourcePresenter documentPresenter selection)	"use match because we might pickup a '.'"]!

test_browseSendersIsDirty
	self testsIssue: #issue500
		withTitle: '(Oscar-3.0.74) highlighting of multi-keyword selectors in senders/implementors browser is broken'.
	methodListBrowser := JadePresenter browseSendersOf: #isDirty session: session.
	self methodListMethodListPresenter list do: 
			[:methodService |
			self methodListMethodListPresenter selection: methodService.
			self assert: ('isDirty*' match: self methodSourcePresenter documentPresenter selection)	"use match because we might pickup a '.'"]!

test_clearAllBreakpointsMenuItemOnMethodList
	"the clear breakpoints menu item should only show up when you've
	browsed breakpoints."

	| methodListPresenter commandQuery menuItem methodsMenu |
	self testsIssue: #issue515 withTitle: '(3.0.77) clear all breakpoints menu item would be useful'.
	methodListBrowser := transcript browseBreakpoints.
	methodsMenu := methodListBrowser view menuBar items detect: [:menu | '*Methods*' match: menu text]
				ifNone: [].
	menuItem := methodsMenu items detect: [:command | 'Clear All Breakpoints' match: command text]
				ifNone: [].
	self denyIsNil: menuItem.
	
	[methodListPresenter := methodListBrowser primaryPresenter.
	commandQuery := self
				queryCommand: #clearAllBreakpoints
				inPresenter: methodListPresenter
				view: methodListPresenter view.
	self assert: commandQuery isEnabled]
			ensure: [methodListBrowser view close].
	methodListBrowser := JadePresenter browseImplementorsOf: #size session: session.
	methodsMenu := methodListBrowser view menuBar items detect: [:menu | '*Methods*' match: menu text]
				ifNone: [].
	menuItem := methodsMenu items detect: [:command | 'Clear All Breakpoints' match: command text]
				ifNone: [].
	self assertIsNil: menuItem!

test_comparisonTabMultimethod
	self testsIssue: #issue264
		withTitle: 'Method List Browser Comparison tab contents are sticky (3.0.74)'.
	self openProjectBrowser.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Core' in: self packageListPresenter.
	self selectServiceNamed: 'RowanAnsweringService' in: self classListPresenter.
	super selectMethodsNamed: #(#answer #answer:).
	methodListBrowser := self projectsPresenter browseSelectedMethods.
	self methodListMethodListPresenter view selectionsByIndex: #(1 2).
	methodListBrowser primaryPresenter selectComparisonTab.
	self assert: methodListBrowser primaryPresenter comparisonPresenter beforeTitlePresenter value
		equals: 'RowanAnsweringService>>answer'.
	self assert: methodListBrowser primaryPresenter comparisonPresenter beforePresenter value trimBlanks
		equals: 'answer

	^answer' replaceCrLfWithLf.
	self assert: methodListBrowser primaryPresenter comparisonPresenter afterTitlePresenter value 
		equals: 'RowanAnsweringService>>answer:'.
	self assert: methodListBrowser primaryPresenter comparisonPresenter afterPresenter value trimBlanks
		equals: 'answer: anObject

	answer := anObject' replaceCrLfWithLf!

test_comparisonTabMultimethod2
	| boolean booleanIndex binaryFloat binaryFloatIndex |
	self testsIssue: #issue264
		withTitle: 'Method List Browser Comparison tab contents are sticky (3.0.74)'.
	methodListBrowser := JadePresenter browseImplementorsOf: 'asString' session: session.
	boolean := self methodListMethodListPresenter view list detect:[:item | 'Boolean' = item className]. 
	booleanIndex := self methodListMethodListPresenter view list indexOf: boolean. 
	binaryFloat := self methodListMethodListPresenter view list detect:[:item | 'BinaryFloat' = item className]. 
	binaryFloatIndex :=  self methodListMethodListPresenter view list indexOf: binaryFloat. 
	self methodListMethodListPresenter view selectionsByIndex: (Array with: binaryFloatIndex with: booleanIndex).	
	methodListBrowser primaryPresenter selectComparisonTab.
	self assert: methodListBrowser primaryPresenter comparisonPresenter beforeTitlePresenter value
		equals: 'BinaryFloat>>asString'.
	self assert: methodListBrowser primaryPresenter comparisonPresenter afterTitlePresenter value
		equals: 'Boolean>>asString'.
	self methodListMethodListPresenter view selectionsByIndex: #(1).	"AbstractException"
	methodListBrowser primaryPresenter selectComparisonTab.
	self assert: methodListBrowser primaryPresenter comparisonPresenter beforeTitlePresenter value
		equals: 'AbstractException>>asString'.
	self assert: methodListBrowser primaryPresenter comparisonPresenter afterTitlePresenter value
		equals: 'Object>>asString'!

test_comparisonTabNoMethodSelected
	self testsIssue: #issue264
		withTitle: 'Method List Browser Comparison tab contents are sticky (3.0.74)'.
	self openProjectBrowser.
	self setupSupclassComparisonMethods.
	methodListBrowser := JadePresenter browseImplementorsOf: #comparisonMethod session: session.
	self methodListMethodListPresenter resetSelection.
	methodListBrowser primaryPresenter selectComparisonTab.
	self assert: methodListBrowser primaryPresenter comparisonPresenter beforeTitlePresenter value
		equals: String new.
	self assert: methodListBrowser primaryPresenter comparisonPresenter beforePresenter value
		equals: String new.
	self assert: methodListBrowser primaryPresenter comparisonPresenter afterTitlePresenter value
		equals: String new.
	self assert: methodListBrowser primaryPresenter comparisonPresenter afterPresenter value
		equals: String new!

test_comparisonTabSuperclass
	self testsIssue: #issue264
		withTitle: 'Method List Browser Comparison tab contents are sticky (3.0.74)'.
	self openProjectBrowser.
	self setupSupclassComparisonMethods.
	methodListBrowser := JadePresenter browseImplementorsOf: #comparisonMethod session: session.
	self methodListMethodListPresenter selectionByIndex: 2.
	methodListBrowser primaryPresenter selectComparisonTab.
	self assert: methodListBrowser primaryPresenter comparisonPresenter beforeTitlePresenter value
		equals: 'RowanSubClass>>comparisonMethod'.	"selected class on left"
	self assert: methodListBrowser primaryPresenter comparisonPresenter beforePresenter value
		equals: 'comparisonMethod  ^3 + 4'.
	self assert: methodListBrowser primaryPresenter comparisonPresenter afterTitlePresenter value
		equals: 'RowanSample1>>comparisonMethod'.	"superclass on left"
	self assert: methodListBrowser primaryPresenter comparisonPresenter afterPresenter value
		equals: 'comparisonMethod  ^self subclassResponsibility'!

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
	self
		assert: methodListBrowser primaryPresenter methodSourcePresenter documentPresenter selectionRange
		equals: (7 to: 17).
	self assert: methodListBrowser primaryPresenter methodSourcePresenter documentPresenter value size
		equals: 17.	"selection goes up to end"
	self assert: (methodListBrowser view viewNamed: 'statusBarField') forecolor equals: Color black.
	self assert: (methodListBrowser view viewNamed: 'statusBarField') backcolor equals: Color red faded.
	self assert: (methodListBrowser view viewNamed: 'statusBarField') model value
		equals: 'invalid pound sign'.
	methodListBrowser primaryPresenter methodListPresenter primaryPresenter selectionByIndex: 2.
	self deny: (methodListBrowser view viewNamed: 'statusBarField') backcolor equals: Color red faded.
	self assert: (methodListBrowser view viewNamed: 'statusBarField') model value equals: String new!

test_createUnicodeSymbolThenLoadSymbols
	session executeString: 'RowanServicesTest new addUnicodeSymbolKeyToUserGlobals'.
	
	[JadeiteSearch initializeAutocompleteSymbolsIn: session.	"this likely would have errored"
	methodListBrowser := JadePresenter browseImplementorsOf: #size session: session.
	self methodListMethodListPresenter list
		do: [:methodService | self assert: methodService selector equals: #size]]
			ensure: [session executeString: 'RowanServicesTest new removeUnicodeSymbolsFromUserGlobals']!

test_doSearch
	"browse literal references on the server doesn't always work - 
	perhaps because of optimized selectors? 
	Just test that we selected the literal if it's anywhere in the source
	hence the conditional. "

	methodListBrowser := JadePresenter browseLiteralReferences: nil printString session: session.
	self assert: self methodListMethodListPresenter list size > 1.	"Always should be a lot of methods. Sanity check that our list isn't empty."
	1 to: self methodListMethodListPresenter list size
		do: 
			[:index |
			self methodListMethodListPresenter selectionByIndex: index.
			(self methodListSourcePresenter documentPresenter value subStrings includes: 'nil')
				ifTrue: [self assert: ('*nil*' match: self methodListSourcePresenter documentPresenter selection)]]!

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
	self assert: self methodListMethodListPresenter list size equals: 2.
	self deny: self methodListMethodListPresenter selection meta.
	projectsBrowser := methodListBrowser primaryPresenter methodListPresenter browseClass.
	
	[self deny: self classListPresenter selection meta.
	self deny: self projectsPresenter isClassSideSelected.
	self assert: self methodListPresenter selection selector equals: #foo]
			ensure: [self destroy: projectsBrowser]!

test_firstReferenceRemovedAfterRecompile
	"If we recompile a method in the method list browser
	reset the firstReference to nil. Although we have the
	string that was searched on, we don't know the type
	of search so it's better to show no reference than the
	wrong reference"

	| classService |
	classService := RowanClassService named: 'RowanSample1Test'.
	classService
		saveMethod: 'fnoodle  ^#fnoodle'
		category: 'deleteMe'
		session: session.
	classService
		saveMethod: 'callFnoodle ^self fnoodle'
		category: 'deleteMe'
		session: session.
	
	[methodListBrowser := JadePresenter browseSendersOf: #fnoodle session: session.
	self methodSourcePresenter value: 'callFnoodle ^1 + self fnoodle'.
	self methodSourcePresenter editSaveMethod.
	self methodListMethodListPresenter view resetSelection.
	self methodListMethodListPresenter view selectAll.
	self assertIsNil: self methodListMethodListPresenter selection firstReference]
			ensure: 
				[self methodListMethodListPresenter view selectAll.
				self removeMethods: self methodListMethodListPresenter selections in: 'RowanSample1Test']!

test_firstReferenceRetained
	| fooBrowser barBrowser |
	self testsIssue: #issue508
		withTitle: 'senders lists get highlighting confused after opening a second senders list'.
	fooBrowser := JadePresenter browseSendersOf: 'foo' session: session.
	
	[self selectMethodNamed: #testNewClassVersionB in: fooBrowser.
	self assert: fooBrowser primaryPresenter methodSourcePresenter documentPresenter selection
		equals: 'foo'.
	barBrowser := JadePresenter browseSendersOf: 'bar' session: session.
	self selectMethodNamed: #testNewClassVersionB in: barBrowser.
	self assert: barBrowser primaryPresenter methodSourcePresenter documentPresenter selection
		equals: 'bar'.
	self selectMethodNamed: #testIssue91 in: fooBrowser.
	self assert: fooBrowser primaryPresenter methodSourcePresenter documentPresenter selection
		equals: 'foo'.
	self selectMethodNamed: #testIssue72_addMethod in: barBrowser.
	self assert: barBrowser primaryPresenter methodSourcePresenter documentPresenter selection
		equals: 'bar']
			ensure: 
				[fooBrowser view close.
				barBrowser view close]!

test_insertIfFalse
	methodListBrowser := JadePresenter browseImplementorsOf: #test1 session: session.
	methodListBrowser primaryPresenter methodSourcePresenter documentPresenter selectionRange: (1 to: 0).
	methodListBrowser primaryPresenter insertIfFalse.
	self
		assert: (methodListBrowser primaryPresenter methodSourcePresenter documentPresenter value copyFrom: 1
				to: 10)
		equals: 'ifFalse:[]'.
	self
		assert: methodListBrowser primaryPresenter methodSourcePresenter documentPresenter selectionRange
		equals: (10 to: 9).
	self assert: methodListBrowser primaryPresenter additionalAccelerators first
		equals: #(#insertIfFalse 'Ctrl+Shift+D')!

test_insertIfTrue
	methodListBrowser := JadePresenter browseImplementorsOf: #test1 session: session.
	methodListBrowser primaryPresenter methodSourcePresenter documentPresenter selectionRange: (1 to: 0).
	methodListBrowser primaryPresenter insertIfTrue.
	self
		assert: (methodListBrowser primaryPresenter methodSourcePresenter documentPresenter value copyFrom: 1
				to: 9)
		equals: 'ifTrue:[]'.
	self
		assert: methodListBrowser primaryPresenter methodSourcePresenter documentPresenter selectionRange
		equals: (9 to: 8).
	self assert: methodListBrowser primaryPresenter additionalAccelerators second
		equals: #(#insertIfTrue 'Ctrl+Shift+T')!

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

test_reformatIllegalSource
	self testsIssue: #issue345 withTitle: 'Jadeite format option (server ready) #345'.
	self
		saveMethod: 'reformatSourceTemporaryMethod ^#test'
		in: 'RowanSample1Test'
		category: 'other'.
	methodListBrowser := JadePresenter browseImplementorsOf: #reformatSourceTemporaryMethod
				session: session.
	
	[self assert: self methodSourcePresenter documentPresenter value
		equals: 'reformatSourceTemporaryMethod ^#test'.
	self methodSourcePresenter documentPresenter value: 'reformatSourceTemporaryMethod ^#'.
	self methodSourcePresenter reformatSource.
	self assert: methodListBrowser statusBarText value
		equals: 'Reformat failed. Illegal source' replaceCrLfWithLf.
	self assert: methodListBrowser statusBarText view backcolor equals: Color red faded.
	self assert: self methodSourcePresenter documentPresenter view isModified.
	self assert: self methodSourcePresenter documentPresenter value
		equals: 'reformatSourceTemporaryMethod ^#'	"unchanged"]
			ensure: [self methodSourcePresenter documentPresenter view isModified: false]!

test_reformatSource
	self testsIssue: #issue345 withTitle: 'Jadeite format option (server ready) #345'.
	self
		saveMethod: 'reformatSourceTemporaryMethod ^#test'
		in: 'RowanSample1Test'
		category: 'other'.
	methodListBrowser := JadePresenter browseImplementorsOf: #reformatSourceTemporaryMethod
				session: session.
	self assert: self methodSourcePresenter documentPresenter value
		equals: 'reformatSourceTemporaryMethod ^#test'.
	self methodSourcePresenter reformatSource.
	self assert: self methodSourcePresenter documentPresenter view isModified.
	self assert: self methodSourcePresenter documentPresenter value
		equals: 'reformatSourceTemporaryMethod
  ^ #''test''' replaceCrLfWithLf!

test_reformatSourceIsUndoable
	self testsIssue: #issue550
		withTitle: '"Reformat source" without save is not working right in method browsers (3.0.78)'.
	self openProjectBrowser.
	self selectRowanSample1Test.
	self
		saveMethod: 'reformatSourceTemporaryMethod | abc | abc := #abc. ^abc'
		in: 'RowanSample1Test'
		category: 'other'.
	
	[methodListBrowser := JadePresenter browseImplementorsOf: #reformatSourceTemporaryMethod
				session: session.
	self assert: self methodSourcePresenter documentPresenter value
		equals: 'reformatSourceTemporaryMethod | abc | abc := #abc. ^abc'.
	self methodSourcePresenter reformatSource.
	self assert: self methodSourcePresenter documentPresenter view isModified.
	self assert: self methodSourcePresenter documentPresenter value
		equals: 'reformatSourceTemporaryMethod
  | abc |
  abc := #''abc''.
  ^ abc' replaceCrLfWithLf.
	self methodSourcePresenter documentPresenter view undo.
	self assert: self methodSourcePresenter documentPresenter value
		equals: 'reformatSourceTemporaryMethod | abc | abc := #abc. ^abc']
			ensure: [self projectsPresenter removeMethods: self classListPresenter selections]!

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
	self openProjectBrowser.
	
	[self selectRowanSample1Class.
	self selectMethodNamedInProjectBrowser: #deleteMe.
	self projectsPresenter basicRemoveMethods.
	self denyMethodInList: #deleteMe.
	self assert: self methodListMethodListPresenter list size equals: 1.
	self assert: self methodListMethodListPresenter selections isEmpty.
	self assert: self methodListMethodListPresenter list first className asString
		equals: 'RowanSample1Test']
			ensure: [self destroy: projectsBrowser]!

test_removeMethodOutsideServices
	"does Jadeite handle a removed selector ok?"

	| selection |
	self
		saveMethod: 'testAdHocExecutionWith: arg1
	| temp1 |
	temp1 := arg1. 
	self halt.
	^temp1'
		in: 'RowanSample1Test'
		category: 'tests'.
	methodListBrowser := JadePresenter browseImplementorsOf: #testAdHocExecutionWith: session: session.
	selection := self methodListMethodListPresenter selectionIfNone: [].
	self denyIsNil: selection.
	self assert: (self methodListMethodListPresenter list includes: selection).
	session
		executeString: 'Rowan projectTools browser removeMethod: #testAdHocExecutionWith: forClassNamed: ''RowanSample1Test'' isMeta: false'.
	self
		assert: (session executeString: '| auditResults | 
								auditResults := (RwPrjAuditTool new auditForProjectNamed: ''RowanSample1''). 
								auditResults isEmpty').
	self selectMethodNamed: #testAdHocExecutionWith:.
	self deny: (self methodListMethodListPresenter list includes: selection)!

test_symbolsInitialized
	"wildcard browse implementors and senders relies on these symbols. Make sure they
	get lazy initialized"

	| symbols |
	self testsIssue: #issue631
		withTitle: '(3.0.87) Implementors selection with wildcard displays blank window'.
	JadeiteSearch allSelectorSymbols: nil.
	symbols := JadeiteSearch
				selectorsFrom: 'siz*'
				session: session
				trailingWildcard: true.	"sent in JadePresenter class>>promptForMatchingSymbolsIn:actionBlock:promptCaption:searchType:"
	symbols do: [:symbol | self assert: (symbol beginsWith: 'siz')].
	JadeiteSearch allClassNames: nil.
	symbols := (JadeiteSearch on: View new session: session) allClassesStartingWith: 'Rowan*'.
	symbols do: [:symbol | self assert: (symbol beginsWith: 'Rowan')]!

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
!JadeiteMethodListBrowserTestCase categoriesFor: #browseLiteralTest:!private!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #methodListMethodListPresenter!private!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #methodListSelector!private!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #methodListSourcePresenter!private!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #methodSourcePresenter!private!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #removeMethods:in:!public!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #removeMultiKeywordSenderAndSendee!private!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #removeTestMethodAndCloseProjectBrowser!private!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #sampleMethodSource!public!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #saveMethod:in:category:!public!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #selectListAt:!public!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #selectMethodNamed:!public!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #selectMethodNamed:in:!public!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #selectMethodsNamed:!public!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #selectMethodsNamed:in:!public!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #setupMultiKeywordSenderAndSendee!private!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #setupTestMethodInProjectBrowser!private!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #sourcePresenter!private!support! !
!JadeiteMethodListBrowserTestCase categoriesFor: #tearDown!public!setup teardown! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_adHocContextClassSide!public!test methods! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_adHocContextInstanceSide!public!test methods! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseBreakpoints!public!test browse methods! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseBreakpointsClearAllMenuItemFromMethodList!public!test browse methods! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseBreakpointsClearAllMenuItemFromTranscript!public!test browse methods! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseBreakpointsFromTranscript!public!test browse methods! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseClass!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseClassReferenceCaptionTitle!public!test browse methods! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseClassReferences!public!test browse methods! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseClassReferencesEnablement!public!test menus! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseHierarchyImplementorsEnablement!public!test menus! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseHierarchySenderHighlightingSameSelector!public!test browse methods! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseHierarchySendersEnablement!public!test menus! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseImplementorsEnablement!public!test menus! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseInstVarReaders!public!test browse methods! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseInstVarWriters!public!test browse methods! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseLiteralReferences!public!test browse methods! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseLiteralReferencesBlankSearch!public!test browse methods! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseMultiKeywordSendersHighlighting!public!test browse methods! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseMultiKeywordSendersOnEverySender!public!test browse methods! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseSenderHighlightedWithEveryMethod!public!test browse methods! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseSenderHighlightingIgnoreComments!public!test browse methods! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseSenderHighlightingSameSelector!public!test browse methods! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseSendersEnablement!public!test menus! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseSendersFoo!public!test browse methods! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_browseSendersIsDirty!public!test browse methods! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_clearAllBreakpointsMenuItemOnMethodList!public!test menus! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_comparisonTabMultimethod!public!test comparison tab! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_comparisonTabMultimethod2!public!test comparison tab! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_comparisonTabNoMethodSelected!public!test comparison tab! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_comparisonTabSuperclass!public!test comparison tab! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_compileErrorDisplay!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_compileErrorDisplayGoesAway!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_createUnicodeSymbolThenLoadSymbols!public! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_doSearch!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_doubleClickActionClassMethod!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_doubleClickActionInstanceMethod!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_firstReferenceRemovedAfterRecompile!public!test methods! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_firstReferenceRetained!public!test browse methods! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_insertIfFalse!public!test methods! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_insertIfTrue!public!test methods! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_methodBrowserSaveMethod!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_reformatIllegalSource!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_reformatSource!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_reformatSourceIsUndoable!public!test source! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_removeMethod!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_removeMethodInProjectBrowser!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_removeMethodOutsideServices!public!test methods! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_symbolsInitialized!public!test browse methods! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_UnsavedChangesActionChangeSelectionIgnoreChanges!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_UnsavedChangesActionChangeSelectionStayOnMethod!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_UnsavedChangesActionCloseWindow!public!tests! !
!JadeiteMethodListBrowserTestCase categoriesFor: #test_UnsavedChangesActionCloseWindowStayOnMethod!public!tests! !

