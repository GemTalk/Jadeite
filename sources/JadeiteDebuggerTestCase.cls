"Filed out from Dolphin Smalltalk 7"!

JadeiteDebuggerDataCuratorTestCase subclass: #JadeiteDebuggerTestCase
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteDebuggerTestCase guid: (GUID fromString: '{f159d434-7740-414b-9e64-d9fdde995061}')!
JadeiteDebuggerTestCase comment: 'Tests the Jadeite debugger. 

It''s recommended to run this set of tests with a fresh login to avoid counting stale processes. '!
!JadeiteDebuggerTestCase categoriesForClass!SUnit! !
!JadeiteDebuggerTestCase methodsFor!

setUp
	user := 'SystemUser'.
	super setUp.
	self closeDebuggers.
	JadeiteDebugger debuggerClass: JadeiteDebugger.
	self assertIsNil: JadeiteDebugger semaphore.
	self assert: session notNil.
	session := GciSession current!

test_additionalAccelerators
	"No way yet to adequately test accelerators function
	but we can assert that we tell Dolphin to set them up"

	self testsIssue: #issue329 withTitle: 'Need accelerator key tests'.
	self testsIssue: #issue762
		withTitle: 'Debug-it in debugger / missing menu item, failure on up arrow, and error dialog (3.1pr3)'.
	self openDebuggerOn: 'self halt'.
	self assert: (debugger additionalAccelerators includes: #(#reformatSource 'Ctrl+Shift+O')).
	self assert: (debugger additionalAccelerators includes: #(#jadeDebug 'Ctrl+B')).
	self assert: debugger additionalAccelerators size equals: 3	"should fail if we add a new one"!

test_adHocDebug
	| workspace |
	self testsIssue: #issue427 withTitle: '(3.0.60) autocommit not done after successful doits'.
	workspace := JadeWorkspace showOnSession: session.
	
	[self assert: (workspace isKindOf: JadeWorkspace).
	workspace setDocumentData: '123'.
	self debuggerDo: 
			[process := 
					[workspace codePane documentPresenter setFocus.
					workspace codePane jadeDebug]
							forkAt: Processor activePriority + 1].
	self getDebugger.
	self assert: debugger methodSourcePresenter documentPresenter value equals: 'nil halt. 123'. 
]
			ensure: 
				[workspace isModified: false.
				workspace view close]!

test_adHocExecutionEvaluatesArgs
	self
		saveMethod: 'testAdHocExecutionWith: arg1
	| temp1 |
	temp1 := arg1. 
	self halt.
	^temp1'
		in: 'RowanSample1Test'
		category: 'tests'.
	
	[self openDebuggerOn: 'RowanSample1Test new testAdHocExecutionWith: 1 '.
	debugger methodSourcePresenter documentPresenter selectionRange: (53 to: 56).
	self assert: debugger methodSourcePresenter documentPresenter selection equals: 'arg1'.
	debugger methodSourcePresenter documentPresenter view setFocus.
	debugger methodSourcePresenter jadeDisplay.
	self assert: debugger methodSourcePresenter documentPresenter selection equals: ' 1']
			ensure: [self removeMethodNamed: #testAdHocExecutionWith:]!

test_adHocExecutionEvaluatesTemp
	self
		saveMethod: 'testAdHocExecutionWith: arg1
	| temp1 |
	temp1 := arg1. 
	self halt.
	^temp1'
		in: 'RowanSample1Test'
		category: 'tests'.
	
	[self openDebuggerOn: 'RowanSample1Test new testAdHocExecutionWith: 1 '.
	debugger variableListPresenter selectionByIndex: 3.
	self assert: debugger variableListPresenter selection _key equals: #arg1.
	self assert: debugger variableListPresenter selection value equals: '1'.
	debugger variableListPresenter selectionByIndex: 4.
	self assert: debugger variableListPresenter selection _key equals: #temp1.
	self assert: debugger variableListPresenter selection value equals: '1'.
	debugger methodSourcePresenter documentPresenter selectionRange: (44 to: 57).
	self assert: debugger methodSourcePresenter documentPresenter selection equals: 'temp1 := arg1.'.
	debugger methodSourcePresenter documentPresenter replaceSelection: 'temp1 := 5.'.
	debugger methodSourcePresenter documentPresenter selectionRange: (44 to: 53).
	debugger methodSourcePresenter documentPresenter view setFocus.
	debugger methodSourcePresenter executeSelectionOrLine.
	debugger methodSourcePresenter documentPresenter selectionRange: (44 to: 48).
	self assert: debugger methodSourcePresenter documentPresenter selection equals: 'temp1'.
	debugger methodSourcePresenter jadeDisplay.
	self assert: debugger methodSourcePresenter documentPresenter selection equals: ' 5']
			ensure: [self removeMethodNamed: #testAdHocExecutionWith:]!

test_adHocExecutionSelf
	self openDebuggerOn: '''gloop'' halt'.
	debugger frameListPresenter selectionByIndex: 3.
	debugger methodSourcePresenter documentPresenter value: 'self'.
	debugger methodSourcePresenter documentPresenter view setFocus.
	self debuggerDo: 
			[
			[debugger jadeDisplay.
			debugger methodSourcePresenter documentPresenter view invalidate]
					forkAt: Processor activePriority + 1].
	[debugger methodSourcePresenter documentPresenter value = 'self ''gloop''']
		whileFalse: [(Delay forMilliseconds: 10) wait].
	self assert: debugger methodSourcePresenter documentPresenter value equals: 'self ''gloop'''.
	debugger methodSourcePresenter documentPresenter view isModified: false!

test_adHocExecutionUpdatesVariablesList
	self
		saveMethod: 'testAdHocExecutionWith: arg1
	| temp1 |
	temp1 := arg1. 
	self halt.
	^temp1'
		in: 'RowanSample1Test'
		category: 'tests'.
	
	[self openDebuggerOn: 'RowanSample1Test new testAdHocExecutionWith: 1 '.
	debugger variableListPresenter selectionByIndex: 4.
	self assert: debugger variableListPresenter selection _key equals: #temp1.
	self assert: debugger variableListPresenter selection value equals: '1'.
	debugger methodSourcePresenter documentPresenter selectionRange: (44 to: 57).
	self assert: debugger methodSourcePresenter documentPresenter selection equals: 'temp1 := arg1.'.
	debugger methodSourcePresenter documentPresenter replaceSelection: 'temp1 := 5.'.
	debugger methodSourcePresenter documentPresenter selectionRange: (44 to: 53).
	debugger methodSourcePresenter documentPresenter view setFocus.
	debugger methodSourcePresenter executeSelectionOrLine.
	debugger variableListPresenter selectionByIndex: 4.
	self assert: debugger variableListPresenter selection _key equals: #temp1.
	self assert: debugger variableListPresenter selection value equals: '5']
			ensure: [self removeMethodNamed: #testAdHocExecutionWith:]!

test_adHocVariablePaneDisplay
	self openDebuggerOn: 'self halt'.
	self assert: debugger variableDataPresenter value equals: String new.
	debugger variableDataPresenter value: '#abc'.
	self debuggerDo: 
			[
			[debugger jadeDisplay.
			debugger methodSourcePresenter documentPresenter view invalidate]
					forkAt: Processor activePriority + 1].
	[debugger variableDataPresenter value = '#abc #''abc''']
		whileFalse: [(Delay forMilliseconds: 10) wait].
	self assert: debugger variableDataPresenter value equals: '#abc #''abc'''.
	self debuggerDo: [debugger resumeProcess]!

test_adHocVariablePaneExecute
	self openDebuggerOn: '| abc | abc := 123. self halt. abc := 234'.
	self assert: (debugger variableListPresenter list at: 2) _key equals: #abc.
	self assert: (debugger variableListPresenter list at: 2) value equals: '123'.
	self assert: debugger variableDataPresenter value equals: String new.
	debugger variableDataPresenter value: 'abc := 567'.
	self debuggerDo: [debugger jadeExecute].
	self assert: (debugger variableListPresenter list at: 2) value equals: '567'.
	self debuggerDo: [debugger resumeProcess]!

test_adHocVariablePaneInspect
	| inspector inspectorOpen |
	self openDebuggerOn: 'self halt'.
	self assert: debugger variableDataPresenter value equals: String new.
	debugger variableDataPresenter value: '#abc'.
	inspectorOpen := false.
	
	[inspector := debugger jadeInspect.
	inspectorOpen := true.
	[self assert: inspector documentPresenter value equals: '#''abc'''] ensure: [inspector view close]]
			fork.
	[inspectorOpen] whileFalse: [(Delay forMilliseconds: 10) wait].
	self debuggerDo: [debugger resumeProcess]!

test_adHocVariablePaneInspect2
	| inspector inspectorOpen |
	self openDebuggerOn: 'self halt'.
	self assert: debugger variableDataPresenter value equals: String new.
	debugger variableDataPresenter value: 'OrderedCollection with: 1 with: 2'.
	inspectorOpen := false.
	
	[inspector := debugger jadeInspect.
	inspectorOpen := true.
	[self assert: inspector documentPresenter value equals: 'anOrderedCollection( 1, 2)']
		ensure: [inspector view close]]
			fork.
	[inspectorOpen] whileFalse: [(Delay forMilliseconds: 10) wait].
	self debuggerDo: [debugger resumeProcess]!

test_badCompileInDebugger
	| source |
	self testsIssue: #issue219 withTitle: 'error when saving source with compile error in debugger'.
	self saveMethodWithHalt.
	self openDebuggerOn: 'RowanSample1 new sampleMethodWithHalt'.
	[debugger frameListPresenter list size <= 0] whileTrue: [(Delay forMilliseconds: 100) wait].
	self assert: debugger frameListPresenter selection
		equals: 'RowanSample1 >> sampleMethodWithHalt @3 line 3'.
	source := 'sampleMethodWithHalt
		"this code will fail compile"
		| array  | 
		array := Array with: .
		^array'.
	debugger methodSourcePresenter documentPresenter value: source.
	debugger saveMethod.
	self assert: self statusBarValue equals: 'expected a primary expression'.
	self assert: debugger methodSourcePresenter documentPresenter view backcolor
		equals: JadeiteTextStyles default colorForCompileError.
	source := 'sampleMethodWithHalt
		"this code will fail compile"
		array := Array with: 1.'.
	debugger methodSourcePresenter documentPresenter value: source.
	debugger saveMethod.
	self assert: self statusBarValue equals: 'undefined symbol'.
	self assert: debugger methodSourcePresenter documentPresenter view backcolor
		equals: JadeiteTextStyles default colorForCompileError!

test_breakpointDisabledHighlighting
	| indicator |
	self testsIssue: #issue607 withTitle: 'Debugger does not have correct breakpoint display (3.0.84)'.
	self enableBreakpoints.
	self openProjectBrowser.
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	self setBreakAt: 2.
	
	[self openDebuggerOn: 'RowanSample1Test new test1'.
	self disableBreakpoints.
	self selectFrameAt: 2.	"remove these two lines when debugger updates bp enabled state automagically"
	self selectFrameAt: 1.
	self
		assert: (indicator := debugger methodSourcePresenter documentPresenter view indicators at: 2) notNil;
		assert: indicator range = (35 to: 37);
		assert: indicator styleName = #disabledBreakPoint;
		assert: indicator tag = 'Break at step point #2']
			ensure: 
				[self clearBreakAt: 2.
				self enableBreakpoints.
				self debuggerDo: [debugger resumeProcess]]!

test_breakpointHighlighting
	| indicator |
	self testsIssue: #issue607 withTitle: 'Debugger does not have correct breakpoint display (3.0.84)'.
	self enableBreakpoints.
	self openProjectBrowser.
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	self setBreakAt: 2.
	
	[self openDebuggerOn: 'RowanSample1Test new test1'.
	self
		assert: (indicator := debugger methodSourcePresenter documentPresenter view indicators at: 2) notNil;
		assert: indicator range = (35 to: 37);
		assert: indicator styleName = #breakPoint;
		assert: indicator tag = 'Break at step point #2']
			ensure: 
				[self clearBreakAt: 2.
				self debuggerDo: [debugger resumeProcess]]!

test_breakpointHighlightingInBlocks
	| sourcePresenter |
	self createTestMethodWithBreakpoints.
	self openDebuggerOn: 'RowanSample1Test new test_highlightBreaks'.
	
	[self assert: debugger frameListPresenter selection
		equals: '[] in RowanSample1Test >> test_highlightBreaks @22 line 14'.
	sourcePresenter := debugger methodSourcePresenter documentPresenter.
	self assert: sourcePresenter selectionRange equals: (245 to: 248).
	self assert: sourcePresenter selection equals: 'add:'.
	self assert: (sourcePresenter view styleIdAt: 244) equals: 0.	"no breakpoint indicator + blue text"
	(245 to: 248)
		do: [:idx | self deny: (sourcePresenter view styleIdAt: idx) equals: 0	"breakpoint indicator + blue text"].
	self assert: (sourcePresenter view styleIdAt: 249) equals: 0.
	self assert: (sourcePresenter view styleIdAt: 295) equals: 0.
	(296 to: 299) do: [:idx | self deny: (sourcePresenter view styleIdAt: idx) equals: 0].
	self assert: (sourcePresenter view styleIdAt: 300) equals: 0.
	self assert: (sourcePresenter view styleIdAt: 330) equals: 0.
	(331 to: 332) do: [:idx | self deny: (sourcePresenter view styleIdAt: idx) equals: 0].	"breakpoint indicator + black text"
	self assert: (sourcePresenter view styleIdAt: 333) equals: 0.
	self projectsPresenter clearMethodBreakpoints]
			ensure: [projectsBrowser view close]!

test_browseClass
	| browser |
	self testsIssue: #issue169 withTitle: 'Debugger menu option Browse Class broken'.
	self openProjectBrowser.
	self selectRowanSample1Class.
	self saveIssue169Method.
	self openDebuggerOn: 'RowanSample1 new issue169'.
	debugger documentPresenter view selectionRange: (81 to: 85).
	self debuggerDo: [browser := debugger methodSourcePresenter browseSelectedClass].
	
	[self assert: (browser isKindOf: JadeiteBrowserPresenter).
	self assert: browser classListPresenter selection name = 'Rowan']
			ensure: [self assert: browser topShell view close].
	debugger documentPresenter view selectionRange: (105 to: 110).
	self debuggerDo: [browser := debugger methodSourcePresenter browseSelectedClass].
	
	[self assert: (browser isKindOf: JadeiteBrowserPresenter).
	self assert: ('*String*' match: browser selectedClasses first name)]
			ensure: [self assert: browser topShell view close].
	debugger documentPresenter view selectionRange: (119 to: 128).
	self debuggerDo: [browser := debugger methodSourcePresenter browseSelectedClass].
	
	[self assert: (browser isKindOf: JadeiteBrowserPresenter).
	self assert: browser selectedClassName equals: 'TranscriptStreamPortable']
			ensure: 
				[self assert: browser topShell view close.
				self destroy: projectsBrowser]!

test_browseClassVariablePane
	self testsIssue: #issue192
		withTitle: 'Oscar-3.0.40: `browse object class` menu item in inspector (debugger) opens dictionary browser...'.
	self openDebuggerOn: 'nil halt. OrderedCollection with: RowanClassService new'.
	self debuggerDo: [debugger stepOver].
	self debuggerDo: [debugger stepOver].	"on with:"
	self debuggerDo: [debugger stepInto].
	debugger variableListPresenter selectionByIndex: 1.
	self assert: debugger variableDataPresenter value equals: 'OrderedCollection'.
	projectsBrowser := debugger browseObjectClass.
	
	[self assert: (projectsBrowser isKindOf: JadeiteBrowser).
	self assert: projectsBrowser currentCard classListPresenter selection name equals: 'OrderedCollection'	"receiver is OrderedCollection class"]
			ensure: [projectsBrowser view close].
	debugger variableListPresenter selectionByIndex: 2.
	self assert: debugger variableDataPresenter value equals: 'aRowanClassService:nil'.
	projectsBrowser := debugger browseObjectClass.
	
	[self assert: (projectsBrowser isKindOf: JadeiteBrowser).
	self assert: projectsBrowser currentCard classListPresenter selection name
		equals: 'RowanClassService'	"receiver is OrderedCollection class"]
			ensure: [self destroy: projectsBrowser]!

test_browseFrameClassMethod
	| browser |
	self testsIssue: #issue774
		withTitle: 'Disable Browse* debugger frame list menu options if method not visible'.
	self saveMethodWithHalt.
	self openDebuggerOn: 'RowanSample1 new sampleMethodWithHalt'.
	self selectFrameAt: debugger frameListPresenter list size.
	self isServerVersion36
		ifTrue: 
			[self assert: debugger frameListPresenter selection
				equals: 'GsNMethod class >> _gsReturnToC @1 line 11']
		ifFalse: 
			[self assert: debugger frameListPresenter selection
				equals: 'GsNMethod class >> _gsReturnToC @1 line 1'].
	browser := debugger browseFrameMethod.
	
	[self assert: browser isKindOf: JadeiteBrowser.
	self assert: browser currentCard classListPresenter selection name equals: 'GsNMethod'.
	self assert: browser currentCard methodListPresenter selection selector equals: #_gsReturnToC]
			ensure: [browser view close]!

test_browseFrameMethod
	| browser |
	self saveMethodWithHalt.
	self openDebuggerOn: 'RowanSample1 new sampleMethodWithHalt'.
	self selectFrameAt: 3.
	browser := debugger browseFrameMethod.
	
	[self assert: browser isKindOf: JadeiteBrowser.
	self assert: browser currentCard classListPresenter selection name equals: 'Object'.
	self assert: browser currentCard methodListPresenter selection selector equals: #halt]
			ensure: [browser view close]!

test_browseFrameMethodInBlock
	| browser source |
	self testsIssue: #issue287
		withTitle: '(3.0.50) debugger "browse" menu disabled when on frame on nested block ...'.
	source := 'testBlockMenuItems

	[ | def |
	def := Array new.
	def add: #abc; add: 2. 
	def size; halt. 
	] value.'.
	self
		saveMethod: source
		in: 'RowanSample1Test'
		category: 'other'.
	self openDebuggerOn: 'RowanSample1Test new testBlockMenuItems'.
	self isServerVersion36
		ifTrue: 
			[self assert: ('[] in RowanSample1Test >> testBlockMenuItems @11 line 6'
						match: debugger frameListPresenter selection)]
		ifFalse: [self assert: ('[] in  ExecBlock0 *' match: debugger frameListPresenter selection)].
	browser := debugger browseFrameMethod.
	
	[self assert: browser isKindOf: JadeiteBrowser.
	self assert: browser currentCard classListPresenter selection name equals: 'RowanSample1Test'.
	self assert: browser currentCard methodListPresenter selection selector equals: #testBlockMenuItems]
			ensure: [browser view close].
	self selectFrameAt: 5.
	self
		assert: ('RowanSample1Test >> testBlockMenuItems*' match: debugger frameListPresenter selection).
	browser := debugger browseFrameMethod.
	
	[self assert: browser isKindOf: JadeiteBrowser.
	self assert: browser currentCard classListPresenter selection name equals: 'RowanSample1Test'.
	self assert: browser currentCard methodListPresenter selection selector equals: #testBlockMenuItems]
			ensure: [browser view close]!

test_browseImplementorsInBlock
	| browser source |
	self testsIssue: #issue287
		withTitle: '(3.0.50) debugger "browse" menu disabled when on frame on nested block ...'.
	source := 'testBlockMenuItems

	[ | def |
	def := Array new.
	def add: #abc; add: 2. 
	def size; halt. 
	] value.'.
	self
		saveMethod: source
		in: 'RowanSample1Test'
		category: 'other'.
	self openDebuggerOn: 'RowanSample1Test new testBlockMenuItems'.
	self isServerVersion36
		ifTrue: 
			[self assert: ('[] in RowanSample1Test >> testBlockMenuItems @11 line 6'
						match: debugger frameListPresenter selection)]
		ifFalse: [self assert: ('[] in  ExecBlock0 *' match: debugger frameListPresenter selection)].
	browser := debugger browseImplementors.
	
	[self assert: browser isKindOf: JadeiteMethodListBrowser.
	self assert: browser primaryPresenter methodListPresenter methodListPresenter selection selector
		equals: #testBlockMenuItems.
	self assert: ('Implementors *' match: browser topShell view caption)]
			ensure: [browser view close].
	self selectFrameAt: 5.
	self
		assert: ('RowanSample1Test >> testBlockMenuItems*' match: debugger frameListPresenter selection).
	browser := debugger browseImplementors.
	
	[self assert: browser isKindOf: JadeiteMethodListBrowser.
	self assert: browser primaryPresenter methodListPresenter methodListPresenter selection selector
		equals: #testBlockMenuItems.
	self assert: ('Implementors *' match: browser topShell view caption)]
			ensure: [browser view close]!

test_browseSelectedFrameClassMethod
	| methodListBrowser |
	self testsIssue: #issue774
		withTitle: 'Disable Browse* debugger frame list menu options if method not visible'.
	self saveMethodWithHalt.
	self openDebuggerOn: 'RowanSample1 new sampleMethodWithHalt'.
	self selectFrameAt: debugger frameListPresenter list size.
	self isServerVersion36
		ifTrue: 
			[self assert: debugger frameListPresenter selection
				equals: 'GsNMethod class >> _gsReturnToC @1 line 11']
		ifFalse: 
			[self assert: debugger frameListPresenter selection
				equals: 'GsNMethod class >> _gsReturnToC @1 line 1'].
	methodListBrowser := debugger browseSelectedMethod.
	
	[self assert: methodListBrowser isKindOf: JadeiteMethodListBrowser.
	self assert: methodListBrowser primaryPresenter methodListPresenter methodListPresenter selection
				className
		equals: 'GsNMethod'.
	self assert: methodListBrowser primaryPresenter methodListPresenter methodListPresenter selection
				selector
		equals: #_gsReturnToC]
			ensure: [methodListBrowser view close]!

test_browseSelectedFrameMethod
	|  methodListBrowser |
	self testsIssue: #issue740
		withTitle: 'nice to have `Browse selected method` menu item in debugger, too'.
	self openDebuggerOn: 'self halt'.
	debugger frameListPresenter selectionByIndex: 3.
	methodListBrowser := debugger browseSelectedMethod .
	self assert: methodListBrowser primaryPresenter methodListPresenter methodListPresenter selection selector equals: #halt!

test_browseSelectedFrameMethodClassSide
	|  methodListBrowser |
	self testsIssue: #issue740
		withTitle: 'nice to have `Browse selected method` menu item in debugger, too'.
	self testsIssue: #issue765 withTitle: 'Debugger Browse Selected Method error on lower methods in stack (3.1pr3)'. 
	self openDebuggerOn: 'RowanClassService halt; forClassNamed: ''RowanLoggingService'''. 
	debugger stepOver.
	debugger stepInto. 
	debugger frameListPresenter selectionByIndex: 1.
	methodListBrowser := debugger browseSelectedMethod .
	self assert: methodListBrowser primaryPresenter methodListPresenter methodListPresenter selection selector equals: #forClassNamed:!

test_browseSendersInBlock
	| browser source |
	self testsIssue: #issue287
		withTitle: '(3.0.50) debugger "browse" menu disabled when on frame on nested block ...'.
	source := 'test1
	self testBlockMenuItems'.
	self
		saveMethod: source
		in: 'RowanSample1Test'
		category: 'tests'.
	source := 'testBlockMenuItems

	[ | def |
	def := Array new.
	def add: #abc; add: 2. 
	def size; halt. 
	] value.'.
	self
		saveMethod: source
		in: 'RowanSample1Test'
		category: 'other'.
	self openDebuggerOn: 'RowanSample1Test new testBlockMenuItems'.
	self isServerVersion36
		ifTrue: 
			[self
				assert: ('[] in RowanSample1Test >> testBlockMenuItems*' match: debugger frameListPresenter selection)]
		ifFalse: [self assert: ('[] in  ExecBlock0 *' match: debugger frameListPresenter selection)].
	browser := debugger browseSenders.
	
	[self assert: browser isKindOf: JadeiteMethodListBrowser.
	self assert: browser primaryPresenter methodListPresenter methodListPresenter selection selector
		equals: #test1.
	self assert: ('Senders *' match: browser topShell view caption)]
			ensure: [browser view close].
	self selectFrameAt: 5.
	self
		assert: ('RowanSample1Test >> testBlockMenuItems*' match: debugger frameListPresenter selection).
	browser := debugger browseSenders.
	
	[self assert: browser isKindOf: JadeiteMethodListBrowser.
	self assert: browser primaryPresenter methodListPresenter methodListPresenter selection selector
		equals: #test1.
	self assert: ('Senders *' match: browser topShell view caption)]
			ensure: [browser view close]!

test_bug74
	"Open debugger on method with breakpoint"

	session executeString: '(Repository compiledMethodAt: #pageSize) setBreakAtStepPoint: 2'.
	self
		openDebuggerOn: 'SystemRepository pageSize';
		assert: debugger documentPresenter view selection equals: 'zeroArgPrim:50';
		yourself.
	self debuggerDo: [debugger resumeProcess]!

test_compileError
	self testsIssue: #issue353
		withTitle: 'Debugger has inferior status bar, and opens dialog for unused temps (3.0.74)'.
	self openProjectBrowser.
	self selectRowanSample1Test.
	self
		saveMethod: 'testCompileError

	self assert: true'
		in: 'RowanSample1Test'
		category: 'tests'.
	self selectServiceNamed: 'testCompileError' in: self methodListPresenter.
	self projectsPresenter setBreakPointAt: 2 in: self projectsPresenter.
	
	[self openDebuggerOn: 'RowanSample1Test new testCompileError'.
	debugger documentPresenter value: 'testCompileError

	self assert: '''.
	self debuggerDo: [debugger saveMethod].
	self assert: debugger methodSourcePresenter documentPresenter view selectionRange
		equals: (24 to: 34).
	self assert: debugger statusBarText
		equals: 'missing end of literal mark (prime); expected a primary expression'.
	self assert: debugger statusTextPresenter view backcolor equals: Color red faded.
	debugger documentPresenter value: 'testCompileError
	| warning |
	self assert: true'.
	self debuggerDo: [debugger saveMethod].
	self assert: ('WARNING: unused method temp ''warning''*' match: debugger statusBarText).
	self assert: debugger statusTextPresenter view backcolor equals: Color yellow faded]
			ensure: [JadePresenter clearAllBreaksIn: session]!

test_compileInExecutedBlock
	self testsIssue: #issue498
		withTitle: 'Would like to be able to compile method in debugger when block frame selected'.
	self openProjectBrowser.
	
	[self selectRowanSample1Test.
	self
		saveMethod: 'eek

	#(1 2 3) do:[:idx |
		self halt].'
		in: 'RowanSample1Test'
		category: 'other'.
	
	[self openDebuggerOn: 'RowanSample1Test new eek'.
	debugger documentPresenter value: 'eek

	#(1 2 3) do:[:idx |
		self]'.
	self debuggerDo: [debugger saveMethod].
	self assert: debugger frameListPresenter selectionByIndex equals: 1.
	self assert: (debugger frameListPresenter list at: 1) equals: 'RowanSample1Test >> eek @1 line 1']
			ensure: [self projectsPresenter basicRemoveMethods]]
			ensure: [projectsBrowser view close]!

test_compileInExecutedBlockFailsWhenNoHomeMethod
	self testsIssue: #issue498
		withTitle: 'Would like to be able to compile method in debugger when block frame selected'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[self openDebuggerOn: '#(1 2 3) do:[:idx | self halt].'.
	self assert: debugger frameListPresenter selectionByIndex equals: 4.
	self assert: ('[] in Executed Code  * line *' match: (debugger frameListPresenter list at: 4)).
	debugger documentPresenter value: '#(1 2 3) do:[:idx | self].'.
	TestMessageBox plannedResult: 'ok'.
	debugger saveMethod.
	self assert: debugger frameListPresenter selectionByIndex equals: 4.
	self assert: ('[] in Executed Code  * line *' match: (debugger frameListPresenter list at: 4))]
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

test_compileInExecutedBlockSameSelectorOnStack
	self testsIssue: #issue498
		withTitle: 'Would like to be able to compile method in debugger when block frame selected'.
	self openProjectBrowser.
	
	[self selectRowanSample1Test.
	self
		saveMethod: 'doSomething

	#(1 2 3) do: [:idx | 
			RowanSample1 new doSomething halt]'
		in: 'RowanSample1Test'
		category: 'other'.
	self selectRowanSample1Class.
	self
		saveMethod: 'doSomething

	#(1 2 3) do:[:idx |
		self halt]'
		in: 'RowanSample1'
		category: 'other'.
	
	[self openDebuggerOn: 'RowanSample1Test new doSomething'.
	self assert: debugger frameListPresenter selectionByIndex equals: 4.
	self isServerVersion36
		ifTrue: 
			[self assert: (debugger frameListPresenter list at: 4)
				equals: '[] in RowanSample1 >> doSomething @6 line 4']
		ifFalse: 
			[self assert: (debugger frameListPresenter list at: 4)
				equals: '[] in  ExecBlock1 (RowanSample1) >> doSomething @2 line 4'].
	self assert: (debugger frameListPresenter list at: 9)
		equals: 'RowanSample1Test >> doSomething @2 line 3'.
	debugger documentPresenter value: 'doSomething
	#(1 2 3) do:[:idx |
		self]'.
	self debuggerDo: [debugger saveMethod].
	self assert: debugger frameListPresenter selectionByIndex equals: 1.
	self assert: (debugger frameListPresenter list at: 1)
		equals: 'RowanSample1 >> doSomething @1 line 1'.
	self assert: (debugger frameListPresenter list at: 4)
		equals: 'RowanSample1Test >> doSomething @2 line 3']
			ensure: [self projectsPresenter basicRemoveMethods]]
			ensure: [projectsBrowser view close]!

test_contextMenu
	| error time view |
	self testsIssue: #issue68 withTitle: 'Debuggers (old and new) text panes get error on popup menu'.
	ShortcutMenuStatus reset.
	self openDebuggerOn: 'nil halt'.
	view := debugger documentPresenter view.
	
	[| counter |
	counter := 0.
	[ShortcutMenuStatus status isNil] whileTrue: [(Delay forMilliseconds: 10) wait].
	self assert: ShortcutMenuStatus isOpen.
	
	[counter := counter + 1.
	(Delay forMilliseconds: 100) wait.
	ShortcutMenuStatus isOpen and: [counter <= 10]]
			whileTrue: [self keyDownEscapeIn: view	"WM_KEYDOWN"	"VK_ESCAPE"	"WM_KEYUP"	"VK_ESCAPE"].
	Transcript show: '
testContextMenu - counter = ' , counter printString]
			fork.
	self pressButtonIn: view.	"WM_RBUTTONDOWN"	" (300 @ 100) "	"WM_RBUTTONUP"
	time := Time millisecondClockValue + 2000.
	
	[SessionManager current inputState loopWhile: 
			[(Delay forMilliseconds: 1) wait.
			"menu wasn't always closing. These transcript writes seem to poke it into shutting down ... somehow" 
			Transcript
				cr;
				show: 'time: ';
				print: time;
				tab;
				show: 'clock: ';
				print: Time millisecondClockValue;
				flush.
			ShortcutMenuStatus isClosed not and: [Time millisecondClockValue < time]]]
			on: Error
			do: 
				[:ex |
				error := ex.
				ex return].
	self assert: error isNil!

test_copyFrameString
	| frameListSelection |
	self testsIssue: #issue704
		withTitle: 'would be nice to be able get a copy the selected frame printstring'.
	self openDebuggerOn: 'self halt'.
	frameListSelection := debugger frameListPresenter selection.
	debugger copyFrameString.
	self assert: Clipboard current getText equals: frameListSelection!

test_copyNotifierStack
	| notifierShell copiedStack |
	[RowanAnsweringService new exec: '1 zork' in: session] on: Error
		do: [:ex | notifierShell := JadeErrorShell new gsError: ex].
	copiedStack := notifierShell doCopy.
	self assert: ('a MessageNotUnderstood*' match: copiedStack).
	self assert: Clipboard current getText equals: copiedStack!

test_debugCodeWithLeadingLineReturns
	| workspace |
	self testsIssue: #issue531 withTitle: 'debug-it on ad hoc expression not working'.
	
	[workspace := (JadeWorkspace showOnSession: session) caption: 'Jade Workspace - Test #531'.
	workspace codePane documentPresenter
		value: '

| var i |
	var := WriteStream on: String new.
	i := 2.
	[i > 0] whileTrue: [
			i := i - 1. 
			var nextPut: (Character withValue: 70 - i).
			].
    var contents'.
	self debuggerDo: 
			[process := 
					[workspace codePane selectAll.
					workspace codePane jadeDebug]
							forkAt: Processor activePriority + 1].
	self getDebugger.
	self assert: debugger isKindOf: JadeiteDebugger	"just opening the debugger tests the bug fix"]
			ensure: [workspace view close]!

test_debugCodeWithLeadingLineReturnsLF
	| workspace |
	self testsIssue: #issue531 withTitle: 'debug-it on ad hoc expression not working'.
	
	[workspace := (JadeWorkspace showOnSession: session) caption: 'Jade Workspace - Test #531'.
	workspace codePane documentPresenter
		value: '

| var i |
	var := WriteStream on: String new.
	i := 2.
	[i > 0] whileTrue: [
			i := i - 1. 
			var nextPut: (Character withValue: 70 - i).
			].
    var contents'
				replaceCrLfWithLf.
	self debuggerDo: 
			[process := 
					[workspace codePane selectAll.
					workspace codePane jadeDebug]
							forkAt: Processor activePriority + 1].
	self getDebugger.
	self assert: debugger isKindOf: JadeiteDebugger	"just opening the debugger tests the bug fix"]
			ensure: [workspace view close]!

test_debugCodeWithLeadingTab
	| workspace |
	self testsIssue: #issue531 withTitle: 'debug-it on ad hoc expression not working'.
	
	[workspace := (JadeWorkspace showOnSession: session) caption: 'Jade Workspace - Test #531'.
	workspace codePane documentPresenter
		value: '	| var i |
	var := WriteStream on: String new.
	i := 2.
	[i > 0] whileTrue: [
			i := i - 1. 
			var nextPut: (Character withValue: 70 - i).
			].
    var contents'.
	self debuggerDo: 
			[process := 
					[workspace codePane selectAll.
					workspace codePane jadeDebug]
							forkAt: Processor activePriority + 1].
	self getDebugger.
	self assert: debugger isKindOf: JadeiteDebugger	"just opening the debugger tests the bug fix"]
			ensure: [workspace view close]!

test_debugFromWithinInspector
	| remoteObject inspector |
	remoteObject := session
				executeString: '''abc'''
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	
	[inspector documentPresenter value: 'self size'.
	inspector documentPresenter view selectAll.
	inspector documentPresenter view setFocus.
	self
		assert: JadeiteDebugger allInstances isEmpty;
		debuggerDo: [process := [inspector codePane jadeDebug] forkAt: Processor activePriority + 1];
		getDebugger.
	self assert: debugger model value equals: 'nil halt. self size'
		]
			ensure: [inspector view close]!

test_debuggerModifiedSourcePaneChangeFrame
	self testsIssue: #issue120 withTitle: 'Debugger, edits in text, copy to clipboard, get error'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[self openDebuggerOn: 'nil halt'.
	[debugger frameListPresenter list size <= 0] whileTrue: [(Delay forMilliseconds: 100) wait].
	self assert: debugger frameListPresenter selection equals: 'Executed Code  @2 line 1'.
	debugger methodSourcePresenter documentPresenter value: 'new text'.
	debugger methodSourcePresenter documentPresenter view isModified: true.
	TestMessageBox plannedResult: #no.	"answer that we want to stay on frame"
	[self selectFrameAt: 2] forkAt: Processor activePriority + 1.	"Fork so that the tests' error handler doesn't catch the expected error raised in #selectedFrame"
	self assert: debugger frameListPresenter selectionByIndex equals: 2]
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

test_debuggerModifiedSourcePaneStayOnFrame
	self testsIssue: #issue120 withTitle: 'Debugger, edits in text, copy to clipboard, get error'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[self openDebuggerOn: 'nil halt'.
	[debugger frameListPresenter list size <= 0] whileTrue: [(Delay forMilliseconds: 100) wait].
	self assert: debugger frameListPresenter selection equals: 'Executed Code  @2 line 1'.
	debugger methodSourcePresenter documentPresenter value: 'new text'.
	debugger methodSourcePresenter documentPresenter view isModified: true.
	TestMessageBox plannedResult: #yes.	"answer that we want to stay on frame"
	[self selectFrameAt: 2] forkAt: Processor activePriority + 1.	"Fork so that the tests' error handler doesn't catch the expected error raised in #selectedFrame"
	self assert: debugger frameListPresenter selectionByIndex equals: 4. "did not change frames"]
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

test_disablebreakpointHighlighting
	| indicator |
	self testsIssue: #issue606
		withTitle: 'On breakpoint enable/disable, breakpoint/method list browsers not updated (3.0.84)'.
	self enableBreakpoints.
	self openProjectBrowser.
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	self setBreakAt: 2.
	
	[self openDebuggerOn: 'RowanSample1Test new test1'.
	self
		assert: (indicator := debugger methodSourcePresenter documentPresenter view indicators at: 2) notNil;
		assert: indicator range = (35 to: 37);
		assert: indicator styleName = #breakPoint;
		assert: indicator tag = 'Break at step point #2'.
	self disableBreakpoints.
	self
		assert: (indicator := debugger methodSourcePresenter documentPresenter view indicators at: 2) notNil;
		assert: indicator range = (35 to: 37);
		assert: indicator styleName = #disabledBreakPoint;
		assert: indicator tag = 'Break at step point #2'.
	self enableBreakpoints.
	self
		assert: (indicator := debugger methodSourcePresenter documentPresenter view indicators at: 2) notNil;
		assert: indicator range = (35 to: 37);
		assert: indicator styleName = #breakPoint;
		assert: indicator tag = 'Break at step point #2']
			ensure: 
				[self clearBreakAt: 2.
				self debuggerDo: [debugger resumeProcess]]!

test_doubleClickIncludesColon
	"It's difficult to fake up a mouse event so ensure the method that grabs the colon
	is setup as an event and includes the colon after being called"

	self testsIssue: #issue301 withTitle: '(3.0.50) inconsistent selector selection on double-click'.
	self openDebuggerOn: 'Array with: 1; halt'.
	self
		assert: (debugger methodSourcePresenter documentPresenter events at: #leftButtonDoubleClicked:)
				messages first
				asSymbol
		equals: #methodDoubleClicked:.
	debugger methodSourcePresenter documentPresenter selectionRange: (7 to: 10).
	self assert: debugger methodSourcePresenter documentPresenter selection equals: 'with'.
	debugger methodSourcePresenter methodDoubleClicked: nil.
	self assert: debugger methodSourcePresenter documentPresenter selectionRange equals: (7 to: 11).
	self assert: debugger methodSourcePresenter documentPresenter selection equals: 'with:'!

test_duplicateInstVars
	self testsIssue: #issue228
		withTitle: 'lose selected class in project browser when new version created'.
	self openProjectBrowser.
	
	[self selectServicesNamed: (Array with: 'RowanSample1') in: self projectListPresenter.
	self selectServicesNamed: #('RowanSample1-Tests') in: self packageListPresenter.
	self saveTestClassWithInstVars: Array new package: 'RowanSample1-Tests'.
	self selectClassTab.
	self
		saveClass: 'SubClass'
		superclass: 'TestClass'
		instVars: #()
		package: 'RowanSample1-Tests'.
	self selectServiceNamed: 'SubClass' in: self classListPresenter.
	self
		saveClass: 'SubSubClass'
		superclass: 'SubClass'
		instVars: #('aa')
		package: 'RowanSample1-Tests'.
	self selectServiceNamed: 'SubClass' in: self classListPresenter.
	self debuggerDo: 
			[process := 
					[self selectServiceNamed: 'SubClass' in: self classListPresenter.
					self
						saveClass: 'SubClass'
						withInstVars: #('aa')
						package: 'RowanSample1-Tests']
							forkAt: Processor activePriority + 1].
	self getDebugger.
	self assert: debugger variableListPresenter list first key value equals: #receiver.
	self assert: debugger variableListPresenter list first className equals: 'ImproperOperation']
			ensure: 
				[self projectsPresenter classDefinitionPresenter view isModified: false.
				self selectServiceNamed: 'SubSubClass' in: self classListPresenter.
				self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass.
				self selectServiceNamed: 'SubClass' in: self classListPresenter.
				self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass.
				self destroy: projectsBrowser]!

test_duplicateInstVarsHierarchy
	self testsIssue: #issue228
		withTitle: 'lose selected class in project browser when new version created'.
	self openProjectBrowser.
	
	[self selectServicesNamed: (Array with: 'RowanSample1') in: self projectListPresenter.
	self selectServicesNamed: #('RowanSample1-Tests') in: self packageListPresenter.
	self selectHierarchyTab.
	self saveTestClassWithInstVars: Array new package: 'RowanSample1-Tests'.
	self selectClassInHierarchyNamed: 'TestClass'.
	self
		saveClass: 'SubClass'
		superclass: 'TestClass'
		instVars: #()
		package: 'RowanSample1-Tests'.
	self selectClassInHierarchyNamed: 'SubClass'.
	self
		saveClass: 'SubSubClass'
		superclass: 'SubClass'
		instVars: #('aa')
		package: 'RowanSample1-Tests'.
	self selectClassInHierarchyNamed: 'SubSubClass'.
	self debuggerDo: 
			[process := 
					[self selectClassInHierarchyNamed: 'SubClass'.
					self
						saveClass: 'SubClass'
						withInstVars: #('aa')
						package: 'RowanSample1-Tests']
							forkAt: Processor activePriority + 1].
	self getDebugger.
	self assert: debugger variableListPresenter list first key value equals: #receiver.
	self assert: debugger variableListPresenter list first className equals: 'ImproperOperation']
			ensure: 
				[self projectsPresenter classDefinitionPresenter view isModified: false.
				self selectClassInHierarchyNamed: 'SubSubClass'.
				self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass.
				self selectClassInHierarchyNamed: 'SubClass'.
				self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass.
				self destroy: projectsBrowser]!

test_duplicateInstVarsInHierarchy
	self testsIssue: #issue228
		withTitle: 'lose selected class in project browser when new version created'.
	self openProjectBrowser.
	
	[self selectServicesNamed: (Array with: 'RowanSample1') in: self projectListPresenter.
	self selectServicesNamed: #('RowanSample1-Tests') in: self packageListPresenter.
	self saveTestClassWithInstVars: Array new package: 'RowanSample1-Tests'.
	self selectHierarchyTab.
	self selectServiceNamed: 'TestClass' in: self classListPresenter.
	self
		saveClass: 'SubClass'
		superclass: 'TestClass'
		instVars: #()
		package: 'RowanSample1-Tests'.
	self selectClassInHierarchyNamed: 'SubClass'.
	self
		saveClass: 'SubSubClass'
		superclass: 'SubClass'
		instVars: #('aa')
		package: 'RowanSample1-Tests'.
	self selectClassInHierarchyNamed: 'SubSubClass'.
	self debuggerDo: 
			[process := 
					[self selectClassInHierarchyNamed: 'SubClass'.
					self
						saveClass: 'SubClass'
						withInstVars: #('aa')
						package: 'RowanSample1-Tests']
							forkAt: Processor activePriority + 1].
	self getDebugger.
	self assert: debugger variableListPresenter list first key value equals: #receiver.
	self assert: debugger variableListPresenter list first className equals: 'ImproperOperation']
			ensure: 
				[self projectsPresenter classDefinitionPresenter view isModified: false.
				self selectClassInHierarchyNamed: 'SubSubClass'.
				self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass.
				self selectClassInHierarchyNamed: 'SubClass'.
				self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass.
				self destroy: projectsBrowser]!

test_errorInPrintString

	self testsIssue: #issue49
		withTitle: 'Error during printString in debugger (inspector) makes debugger unusable'.
	self
		openDebuggerOn: '(ScaledDecimal _basicNew instVarAt: 1 put: 1; instVarAt: 2 put: nil; printString)';
		assert: debugger errorMessagePresenter value
			equals: 'a MessageNotUnderstood occurred (error 2010), a UndefinedObject does not understand  #''_generality''';
		assert: debugger frameListPresenter selection
			equals: 'SmallInteger (Number) >> _retry:coercing: @4 line 15';
		assert: (debugger frameListPresenter selectionByIndex: 6) notNil.
	debugger frameListPresenter selectionByIndex: 8.	"select ScaledDecimal frame"
	self
		assert: debugger variableListPresenter list first value
			equals: '(ScaledDecimal printString error: a MessageNotUnderstood occurred (error 2010), a UndefinedObject does not understand  #''_generality'')';
		debuggerDo: [[debugger _terminateProcess] fork];
		assert: (Delay forMilliseconds: 250) wait notNil;
		assert: (debugger isNil or: [debugger view class == DeafObject]);
		yourself!

test_frameDoubleClick
	| projectPresenter |
	self testsIssue: #issue238
		withTitle: '"RowanDebugger does not understand #browseClass" from double click on frame selection (3.0.41)'.
	self openDebuggerOn: 'RowanClassService new halt; classHierarchy'.
	self
		debuggerDo: [debugger stepOver];
		debuggerDo: [debugger stepInto].
	self assert: ('*classHierarchy*' match: debugger frameListPresenter selection).
	projectPresenter := (debugger frameListPresenter trigger: #actionPerformed) currentCard. "simulates double click"
	
	[self assert: projectPresenter classListPresenter selection name equals: 'RowanClassService'.
	self assert: projectPresenter methodListPresenter selection selector equals: #classHierarchy]
			ensure: [self assert: projectPresenter topShell view close]!

test_frameDoubleClickNoActionInBlockContext
	| projectPresenter |
	self testsIssue: #issue238
		withTitle: '"RowanDebugger does not understand #browseClass" from double click on frame selection (3.0.41)'.
	self openDebuggerOn: '[RowanClassService new halt; classHierarchy] value'.
	self assert: debugger frameListPresenter selectionByIndex equals: 4.
	self assert: (debugger frameListPresenter selection copyFrom: 1 to: 2) equals: '[]'.
	projectPresenter := debugger frameListPresenter trigger: #actionPerformed.	"simulates double click on the block context"
	self assert: projectPresenter equals: debugger	"no browser opened and no walkback"!

test_implementersFromDebugger
	| browser |
	self testsIssue: #issue216 withTitle: 'method list in method browser reorders on accept'.
	self openProjectBrowser.
	self selectRowanSample1Class.
	self saveIssue216Method.
	self openDebuggerOn: 'RowanSample1 new issue216'.
	debugger documentPresenter view selectionRange: (77 to: 89).	"Select classFromName"
	self debuggerDo: [browser := debugger methodSourcePresenter browseImplementors].
	
	[self assert: (browser isKindOf: JadeiteMethodListBrowser).
	self assert: ('*Implementors of ''classFromName''*' match: browser topShell caption)]
			ensure: 
				[self assert: browser topShell view close.
				self destroy: projectsBrowser]!

test_implementorsSendersCaption
	| methodListBrowser |
	self testsIssue: #issue209 withTitle: 'MethodListBrowser needs the token in the title bar'.
	self
		openDebuggerOn: '(RowanProjectService new name: ''Rowan'') halt; branch';
		debuggerDo: [debugger stepOver];
		debuggerDo: [debugger stepInto];
		assert: debugger frameListPresenter list first = 'RowanProjectService >> branch @1 line 1'.
	self debuggerDo: [methodListBrowser := debugger browseImplementors].
	[self assert: ('Implementors of ''branch'' for *' match: methodListBrowser caption)]
		ensure: [self assert: methodListBrowser view close].
	self debuggerDo: [methodListBrowser := debugger browseSenders].
	[self assert: ('Senders of ''branch'' for *' match: methodListBrowser caption)]
		ensure: [self assert: methodListBrowser view close]!

test_inspectedDebuggerObjectHeld
	| inspector |
	self testsIssue: #issue385 withTitle: '(3.0.53) Inspector should keep associated root object alive'.
	self
		saveMethod: 'issue385
		| abc |
		abc := Array with: Object new. 
		self halt. 
		^abc'
		in: 'RowanSample1'
		category: 'other'.
	self openDebuggerOn: 'RowanSample1 new issue385'.
	self debuggerDo: [debugger variableListPresenter selectionByIndex: 2].
	self debuggerDo: [inspector := debugger inspectVariable].
	
	[self assert: (session executeString: 'Object = Object').
	self assert: inspector documentPresenter value equals: 'anArray( anObject)'.
	process terminate.
	self closeDebuggers.

	"do stuff while the debugger is closed to hopefully recycle the oop (if the bug was present)"
	self openProjectBrowser.
	
	[self assert: (session executeString: 'Object = Object').
	self assert: inspector documentPresenter value equals: 'anArray( anObject)']
			ensure: [projectsBrowser view close].
	self openProjectBrowser.
	
	[self assert: (session executeString: 'Object = Object').
	self assert: inspector documentPresenter value equals: 'anArray( anObject)']
			ensure: [projectsBrowser view close]]
			ensure: [inspector view close]!

test_jadeItemsOnMenu
	| contextMenu theItem |
	self testsIssue: #issue762
		withTitle: 'Debug-it in debugger / missing menu item, failure on up arrow, and error dialog (3.1pr3)'.
	self openDebuggerOn: 'self halt'.
	contextMenu := debugger methodSourcePresenter documentPresenter view contextMenu.
	theItem := contextMenu items detect: [:menuItem | menuItem command = #jadeDebug] ifNone: [].
	self denyIsNil: theItem.
	theItem := contextMenu items detect: [:menuItem | menuItem command = #jadeExecute] ifNone: [].
	self denyIsNil: theItem.
	theItem := contextMenu items detect: [:menuItem | menuItem command = #jadeInspect] ifNone: [].
	self denyIsNil: theItem.
	theItem := contextMenu items detect: [:menuItem | menuItem command = #jadeDisplay] ifNone: [].
	self denyIsNil: theItem!

test_loginButtonEnablementAfterDebug
	"transcript close wasn't setting GciSession current to nil"

	| shell query sunitPresenter |
	self testsIssue: #issue527 withTitle: 'Multiple sessions can''t keep console project list straight'.
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #no.	"don't commit"
	
	[GciSession current ifNotNil: [:sess | sess logout].
	query := self closeJadeiteLoginShells.
	shell := JadeiteLoginShell show position: 80 @ 20.
	shell login.
	self denyIsNil: GciSession current.
	session := GciSession current.
	transcript := JadeiteTranscript allInstances detect: [:tran | tran gciSession == session] ifNone: [].
	query := CommandQuery commandDescription: (CommandDescription command: #login) source: shell view.
	shell view queryCommand: query.
	self deny: query isEnabled.
	sunitPresenter := (JadeiteSUnitBrowser showOnSession: session) primaryPresenter.
	"reproduce scenario in bug"
	sunitPresenter selectPackageNamed: 'Rowan-Services-Tests'.
	sunitPresenter selectClassNamed: 'RowanMethodServiceTest'.
	sunitPresenter runAll.
	self openDebuggerOn: 'RowanMethodServiceTest new test_noStepPoints'.
	self debuggerDo: [debugger resumeProcess].
	self rowanFixMe.	"without this, test somehow dies. Makes for a less useful test"
	TestMessageBox plannedResult: #no.
	transcript view close.	"closes all Jadeite windows"
	shell := JadeiteLoginShell allInstances first.
	query := CommandQuery commandDescription: (CommandDescription command: #login)
				source: shell loginButtonPresenter view.
	shell queryCommand: query.
	self assert: query isEnabled]
			ensure: 
				[TestMessageBox disableJadeiteTestMessageBox.
				debugger := nil.
				process terminate.
				process := nil.
				session := shell login.
				transcript := JadeiteTranscript allInstances detect: [:tran | tran gciSession == session] ifNone: []]!

test_openDebuggerWthBreakpointInDebuggerService
	"Basics of opening a debugger, viewing the UI, and resuming."

	| x methodService answeringService wereBreakpointsEnabled |
	self testsIssue: #issue748 withTitle: 'Debugger should ignore breakpoints'.
	answeringService := RowanAnsweringService new.
	wereBreakpointsEnabled := answeringService breakPointsAreEnabled: session.
	
	["set breakpoint in critical debugger path, expect debugger to open"
	methodService := RowanMethodService new
				className: 'RowanDebuggerService';
				selector: #update;
				meta: false.
	methodService
		command: #setBreakAt:;
		commandArgs: (Array with: 3).
	self issueCommand: methodService.
	JadePresenter enableAllBreakpointsIn: session.
	self
		openDebuggerOn: 'nil halt';
		assert: (x := debugger errorMessagePresenter value) = 'a Halt occurred (error 2709)';
		assert: (x := debugger processListPresenter list size) == 1;
		assert: (x := debugger frameListPresenter list size) == 5;
		assert: (x := debugger frameListPresenter selection) = 'Executed Code  @2 line 1';
		assert: (x := debugger variableListPresenter list size) == 1;
		assert: (x := debugger variableListPresenter list first) class == RowanVariableService;
		assert: x oop == 20;
		assert: x _key == #receiver;
		assert: x value = 'nil';
		debuggerDo: [debugger resumeProcess];
		assert: (x := debugger view) class == DeafObject;
		yourself]
			ensure: 
				[methodService
					ifNotNil: 
						[methodService
							command: #clearBreakAt:;
							commandArgs: (Array with: 3)].
				self issueCommand: methodService.
				answeringService setBreakpointsEnabled: wereBreakpointsEnabled session: session]!

test_processIsServices
	"not a great test but does look at the underlying problem with issue #762"

	self testsIssue: #issue762
		withTitle: 'Debug-it in debugger / missing menu item, failure on up arrow, and error dialog (3.1pr3)'.
	self openDebuggerOn: '| abc | 1 halt. abc := 0. abc := 1. abc := 2.'.
	self assert: debugger gsProcess isKindOf: RowanProcessService.
	debugger stepOver.
	self assert: debugger gsProcess isKindOf: RowanProcessService.
	debugger stepOver.
	self assert: debugger gsProcess isKindOf: RowanProcessService!

test_processSwitching
	| activeProcesses longRunningProcess |
	activeProcesses := session executeString: 'ProcessorScheduler scheduler allProcesses size'.
	gsProcess := session executeString: '[(Delay forSeconds: 9999) wait] fork asOop.'.
	session executeString: '(Delay forSeconds: 1) wait'.	"let forked process start"
	self
		openDebuggerOn: 'nil halt';
		assert: debugger processListPresenter list size equals: activeProcesses + 1.
	longRunningProcess := debugger processListPresenter list
				detect: [:processService | processService oop = gsProcess].
	self debuggerDo: [debugger processListPresenter selection: longRunningProcess].
	self selectFrameMatching: '*Executed Code*'. 
	self
		assert: debugger methodSourcePresenter documentPresenter value
			equals: '[(Delay forSeconds: 9999) wait] fork asOop.';
		assert: longRunningProcess oop equals: gsProcess!

test_processTermination
	| terminationProcessOop primaryProcessOop |
	self testsIssue: #issue762
		withTitle: 'Debug-it in debugger / missing menu item, failure on up arrow, and error dialog (3.1pr3)'.
	gsProcess := session executeString: '[(Delay forSeconds: 9999) wait] fork asOop.'.
	session executeString: '(Delay forSeconds: 1) wait'.	"let forked process start"
	self openDebuggerOn: 'nil halt'.
	self assert: debugger processListPresenter selectionByIndex equals: 1.	"always start on top process"
	primaryProcessOop := debugger processListPresenter selection oop.
	debugger processListPresenter selectionByIndex: 2.
	terminationProcessOop := debugger processListPresenter selection oop.
	debugger _terminateProcess.
	self assert: debugger processListPresenter list first oop equals: primaryProcessOop.	"reselect top process"
	debugger processListPresenter list
		do: [:processService | self deny: processService oop equals: terminationProcessOop]!

test_reformatIllegalSource
	self testsIssue: #issue345 withTitle: 'Jadeite format option (server ready) #345'.
	self
		saveMethod: 'reformatSourceTemporaryMethod self halt. ^#test'
		in: 'RowanSample1Test'
		category: 'other'.
	self openDebuggerOn: 'RowanSample1Test new reformatSourceTemporaryMethod'.
	
	[self assert: debugger documentPresenter value
		equals: 'reformatSourceTemporaryMethod self halt. ^#test'.
	debugger documentPresenter value: 'reformatSourceTemporaryMethod self halt. ^#'.
	debugger reformatSource.
	debugger documentPresenter view isModified: true. 
	self assert: debugger statusTextPresenter view backcolor equals: Color red faded.
	self assert: debugger documentPresenter view isModified.
	self assert: debugger statusBarText equals: 'Reformat failed. Illegal source' replaceCrLfWithLf.
	self assert: debugger documentPresenter value
		equals: 'reformatSourceTemporaryMethod self halt. ^#' replaceCrLfWithLf	"unchanged"]
			ensure: [debugger documentPresenter view isModified: false]!

test_reformatSource
	self testsIssue: #issue345 withTitle: 'Jadeite format option (server ready) #345'.
	self
		saveMethod: 'reformatSourceTemporaryMethod self halt. ^#test'
		in: 'RowanSample1Test'
		category: 'other'.
	self openDebuggerOn: 'RowanSample1Test new reformatSourceTemporaryMethod'.
	
	[self assert: debugger documentPresenter value
		equals: 'reformatSourceTemporaryMethod self halt. ^#test'.
	debugger reformatSource.
	self assert: debugger documentPresenter view isModified.
	self isServerVersion36
		ifTrue: 
			[self assert: debugger documentPresenter value
				equals: 'reformatSourceTemporaryMethod
	self halt.
	^ #''test''' replaceCrLfWithLf]
		ifFalse: 
			[self assert: debugger documentPresenter value
				equals: 'reformatSourceTemporaryMethod
  self halt.
  ^ #''test''' replaceCrLfWithLf]	"different formatting code in 3.6"]
			ensure: [debugger documentPresenter view isModified: false]!

test_reformatSourceDoesNotStick
	self testsIssue: #issue609
		withTitle: 'Debugger problems with unsaved reformat and breakpoint in block'.
	self
		saveMethod: 'reformatSourceTemporaryMethod 


self halt. ^#test'
		in: 'RowanSample1Test'
		category: 'other'.
	self openDebuggerOn: 'RowanSample1Test new reformatSourceTemporaryMethod'.
	self assert: debugger documentPresenter value
		equals: 'reformatSourceTemporaryMethod 


self halt. ^#test'.
	debugger reformatSource.
	self assert: debugger documentPresenter view isModified.
	self isServerVersion36
		ifTrue: 
			[self assert: debugger documentPresenter value
				equals: 'reformatSourceTemporaryMethod
	self halt.
	^ #''test''' replaceCrLfWithLf]
		ifFalse: 
			[self assert: debugger documentPresenter value
				equals: 'reformatSourceTemporaryMethod
  self halt.
  ^ #''test''' replaceCrLfWithLf].	"different formatting code in 3.6"
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #no.
	self selectFrameAt: 6.
	self selectFrameAt: 4.
	self assert: debugger documentPresenter value
		equals: 'reformatSourceTemporaryMethod 


self halt. ^#test'!

test_reformatSourceIsUndoable
	self testsIssue: #issue550
		withTitle: '"Reformat source" without save is not working right in method browsers (3.0.78)'.
	self openProjectBrowser.
	self selectRowanSample1Test.
	self
		saveMethod: 'reformatSourceTemporaryMethod | abc | abc := #abc. ^abc'
		in: 'RowanSample1Test'
		category: 'other'.
	
	[self selectMethodNamed: #reformatSourceTemporaryMethod.
	self projectsPresenter setBreakPointAt: 1 in: self projectsPresenter.
	self openDebuggerOn: 'RowanSample1Test new reformatSourceTemporaryMethod'.
	self assert: self methodSourcePresenter value
		equals: 'reformatSourceTemporaryMethod | abc | abc := #abc. ^abc'.
	debugger reformatSource.
	self assert: debugger documentPresenter view isModified.
	self isServerVersion36
		ifFalse: 
			[self assert: debugger documentPresenter view text
				equals: 'reformatSourceTemporaryMethod
  | abc |
  abc := #''abc''.
  ^ abc' replaceCrLfWithLf]
		ifTrue: 
			[self assert: debugger documentPresenter view text
				equals: 'reformatSourceTemporaryMethod
	| abc |
	abc := #''abc''.
	^ abc' replaceCrLfWithLf].
	debugger documentPresenter view undo.
	self assert: self methodSourcePresenter value
		equals: 'reformatSourceTemporaryMethod | abc | abc := #abc. ^abc'.
	debugger documentPresenter view isModified: false.
	self debuggerDo: [debugger resumeProcess]]
			ensure: [self projectsPresenter removeMethods: self classListPresenter selections]!

test_registeredPresentersInProjectBrowserCleanedUp
	| registeredPresenters  |
	registeredPresenters := BrowserUpdate current registeredPresenters size.
	self openDebuggerOn: 'nil halt'.
	self assert: BrowserUpdate current registeredPresenters size > registeredPresenters.
	self tearDown.  "this will close the debugger and do proper cleanup" 
	self assert: BrowserUpdate current registeredPresenters size equals: registeredPresenters!

test_reloadWithDebuggerOpen
	"reload a project with a debugger open. That was enough to trigger the error"

	self testsIssue: #issue359
		withTitle: '(3.0.52 & 3.0.62) `a UserDefinedError occurred (error 2318), reason:halt, Use on*Process: constructors` Error'.
	self openProjectBrowser. 
	
	[self selectRowanSample1Class.
	self saveIssue169Method.
	self denyIsNil: (self methodListPresenter list
				detect: [:methodService | methodService selector = #issue169]
				ifNone: []).
	self assert: self projectListPresenter selection isDirty.
	self openDebuggerOn: 'RowanSample1 new issue169'.
	RowanBrowserService new reloadProjects: self projectListPresenter selections
		presenter: self projectsPresenter.
	self deny: self projectListPresenter selection isDirty.
	self selectRowanSample1Class.
	self assertIsNil: (self methodListPresenter list
				detect: [:methodService | methodService selector = #issue169]
				ifNone: [])]
			ensure: [self assert: projectsBrowser topShell view close]!

test_reopenInLastExtent
	| newExtent |
	self testsIssue: #issue741 withTitle: '(3.0.93) would be nice if debugger remembered it''s size'.
	self openDebuggerOn: '| abc |
abc := Array new. 
self halt. 
abc add: 1.
^abc'.
	debugger view extent: (newExtent := debugger view extent + (20 @ 20)).
	self debuggerDo: [debugger resumeProcess].
	self closeDebuggers.
	self openDebuggerOn: '| abc |
abc := Array new. 
self halt. 
abc add: 1.
^abc'.
	self assert: debugger view extent equals: newExtent.
	self debuggerDo: [debugger resumeProcess]!

test_reopenInLastPosition
	| newPosition |
	self testsIssue: #issue665
		withTitle: '(3.0.91) Would like debugger to remember it''s last location after resume'.
	self openDebuggerOn: '| abc |
abc := Array new. 
self halt. 
abc add: 1.
^abc'.
	debugger view position: (newPosition := debugger view position + (20 @ 20)).
	self debuggerDo: [debugger resumeProcess].
	self closeDebuggers.
	self openDebuggerOn: '| abc |
abc := Array new. 
self halt. 
abc add: 1.
^abc'.
	self assert: debugger view position equals: newPosition.
	self debuggerDo: [debugger resumeProcess]!

test_restartInBlock
	| restartProcess breakPoint |
	self testsIssue: #issue126
		withTitle: 'Debugger opens second debugger, loses stack in original debugger'.
	self isServerVersion36 ifTrue: [^self rowanFixMe	"can't trim stack in recompiled block"].
	self openProjectBrowser.
	self selectRowanSample1Class.
	self saveInterestingLoopMethod.
	breakPoint := 8.
	self projectsPresenter setBreakPointAt: breakPoint in: self projectsPresenter.	"inside the block"
	
	[self openDebuggerOn: 'RowanSample1 new interestingLoop'.
	restartProcess := [self debuggerDo: [debugger restart]] fork.	"can't restart inside block. expect notifier"
	
	[self getSecondDebugger.
	self denyIsNil: secondDebugger.
	self deny: debugger == secondDebugger.
	self deny: debugger gsProcess oop = secondDebugger gsProcess oop.
	self deny: debugger frameListPresenter list size = secondDebugger frameListPresenter list size]
			ensure: [restartProcess terminate]]
			ensure: 
				[self projectsPresenter clearBreakPointAt: breakPoint in: self projectsPresenter.	"inside the block"
				self destroy: projectsBrowser]!

test_runningTestDoesNotLoseStepPoint
	| count |
	self testsIssue: #issue226 withTitle: 'have to reset method in order to disable a break point'.
	self openProjectBrowser.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'AST-Kernel-Tests-Core' in: self packageListPresenter.
	self projectsPresenter isHierarchyTabSelected
		ifTrue: 
			[self selectTreeServicesNamed: (Array with: 'RBGemStoneNumberParserTest')
				in: self classHierarchyPresenter]
		ifFalse: [self selectServiceNamed: 'RBGemStoneNumberParserTest' in: self classListPresenter].
	self selectMethodNamed: #testNumberParser.
	session
		executeString: '(RBGemStoneNumberParserTest compiledMethodAt: #testNumberParser) setBreakAtStepPoint: 2'.
	self projectsPresenter updateService: self methodListPresenter selection.
	
	[self
		debuggerDo: [process := [self projectsPresenter runMethodTests] forkAt: Processor activePriority + 1];
		getDebugger.
	self debuggerDo: [debugger resumeProcess].
	count := 0.
	[self projectsPresenter isSunitTabSelected not and: [count < 5]] whileTrue: 
			[(Delay forMilliseconds: 500) wait.
			count := count + 1].
	self assert: self projectsPresenter isSunitTabSelected.
	self projectsPresenter selectMethodSourceTab.
	self assert: self methodListPresenter selections first stepPoints notEmpty]
			ensure: 
				[session
					executeString: '(RBGemStoneNumberParserTest compiledMethodAt: #testNumberParser) clearBreakAtStepPoint: 2']!

test_saveMethod
	"https://github.com/GemTalk/Jadeite/issues/62"

	| number view |
	self openProjectBrowser.
	
	[self selectRowanSample1Class.
	self createDebuggerTestMethod.
	number := Time millisecondClockValue.
	session executeString: '(RowanSample1 compiledMethodAt: #testMethod) setBreakAtStepPoint: 1'.
	self
		openDebuggerOn: 'RowanSample1 new testMethod';
		assert: (view := debugger documentPresenter view) notNil;
		assert: view selection equals: 'testMethod';
		assert: (view selectionRange: (14 to: 99)) selection first equals: $^;
		assert: (view replaceSelection: '^' , number printString) notNil;
		assert: debugger saveMethod notNil;
		assert: view selection equals: 'testMethod';
		debuggerDo: [debugger resumeProcess];
		assert: (session executeString: 'RowanSample1 new testMethod') equals: number]
			ensure: [self destroy: projectsBrowser]!

test_saveMethodDuringTestRun
	| commandQuery |
	self testsIssue: #issue512
		withTitle: '"run selected" can get disabled after save in debugger (3.0.76)'.
	self openProjectBrowser. 
	
	[self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	commandQuery := self
				queryCommand: #runSelected
				inPresenter: self projectsPresenter
				view: self methodListPresenter view.
	self assert: commandQuery isEnabled.
	commandQuery := self
				queryCommand: #debug
				inPresenter: self projectsPresenter
				view: self methodListPresenter view.
	self assert: commandQuery isEnabled.
	session executeString: '(RowanSample1Test compiledMethodAt: #test1) setBreakAtStepPoint: 1'.
	self
		debuggerDo: [process := [self projectsPresenter runMethodTests] forkAt: Processor activePriority + 1];
		getDebugger.
	self debuggerDo: 
			[debugger methodSourcePresenter documentPresenter
				value: 'test1
	"add comment. no-op change"
	self assert: RowanSample1 new foo = ''foo''   '].
	self debuggerDo: [debugger saveMethod].
	self debuggerDo: [debugger resumeProcess].
	commandQuery := self
				queryCommand: #runSelected
				inPresenter: self projectsPresenter
				view: self methodListPresenter view.
	self assert: commandQuery isEnabled.
	commandQuery := self
				queryCommand: #debug
				inPresenter: self projectsPresenter
				view: self methodListPresenter view.
	self assert: commandQuery isEnabled]
			ensure: [projectsBrowser view close]!

test_selectAfterDiveNoStepPoint
	| breakpoint |
	self testsIssue: #issue166
		withTitle: 'Debugger step with unsaved edits results in empty source pane'.
	self openProjectBrowser.
	self selectRowanSample1Class.
	self saveInterestingLoopMethod.
	breakpoint := self isServerVersion36 ifTrue: [9] ifFalse: [8].
	self projectsPresenter setBreakPointAt: breakpoint in: self projectsPresenter.	"inside the block"
	
	[self openDebuggerOn: 'RowanSample1 new interestingLoop'.
	self debuggerDo: [debugger stepInto].
	self assert: debugger frameListPresenter list first equals: 'RowanSample1 >> test @1 line 1'.
	self isServerVersion36
		ifTrue: 
			[self assert: (debugger frameListPresenter list at: 2)
				equals: '[] in RowanSample1 >> interestingLoop @9 line 8']
		ifFalse: 
			[self assert: (debugger frameListPresenter list at: 2)
				equals: '[] in  ExecBlock1 (RowanSample1) >> interestingLoop @2 line 8'].
	[self selectFrameAt: 2] fork.	"<<< Walkback occurred here"	"Fork so that the tests' error handler doesn't catch the expected error raised in #selectedFrame"
	(Delay forMilliseconds: 100) wait.
	[debugger documentPresenter value replaceLfWithCrLf isEmpty]
		whileTrue: [(Delay forMilliseconds: 10) wait].
	self assert: debugger documentPresenter value replaceLfWithCrLf
		equals: self interestingLoopMethodSource]
			ensure: 
				[self projectsPresenter clearBreakPointAt: breakpoint in: self projectsPresenter.
				self destroy: projectsBrowser]!

test_selectBlockContext
	self testsIssue: #issue166
		withTitle: 'Debugger step within block and then select block context has bad behavior'.
	self openProjectBrowser.
	
	[self selectRowanSample1Class.
	self saveIssue166Method.
	self openDebuggerOn: 'RowanSample1 new issue166'.
	self debuggerDo: [debugger stepInto].
	self selectFrameAt: 2.	"<<< bug occurred here"
	self assert: ('issue166*' match: debugger documentPresenter value)]
			ensure: [self destroy: projectsBrowser]!

test_sendersFromDebugger
	| browser |
	self testsIssue: #issue216 withTitle: 'method list in method browser reorders on accept'.
	self openProjectBrowser.
	self selectRowanSample1Class.
	self saveIssue216Method.
	self openDebuggerOn: 'RowanSample1 new issue216'.
	debugger documentPresenter view selectionRange: (77 to: 89).	"Select classFromName"
	self debuggerDo: [browser := debugger methodSourcePresenter browseSenders].
	
	[self assert: (browser isKindOf: JadeiteMethodListBrowser).
	self assert: ('*Senders of ''classFromName''*' match: browser topShell caption)]
			ensure: 
				[self assert: browser topShell view close.
				self destroy: projectsBrowser]!

test_stackDumpDetailedFrame
	| stream crlf nextLine matchString |
	self testsIssue: #issue455 withTitle: 'Would like args & temps in stack dump'.
	self openDebuggerOn: 'OrderedCollection with: 1 zork'.
	debugger copyStack.
	stream := ReadStream on: Clipboard current getText.
	crlf := Character cr asString , Character lf asString.
	stream upToAll: '===============================================' , crlf.
	self assert: ('[1] MessageNotUnderstood >> defaultAction @* line *' match: (stream upToAll: crlf)).
	self assert: stream next equals: Character tab.
	self assert: ('receiver oop(*) == *' match: (stream upToAll: crlf)).
	self assert: (stream upToAll: crlf) equals: String new.
	self assert: (stream upToAll: crlf) equals: 'instance variables:'.
	matchString := Character tab asString , '*' , ' oop(*) == *'.
	[(nextLine := stream upToAll: crlf) = String new]
		whileFalse: [self assert: (matchString match: nextLine)].
	self assert: (stream upToAll: crlf) equals: 'temporary variables and parameters:'.
	[(nextLine := stream upToAll: crlf) = '----------------------------------------------------']
		whileFalse: [self assert: (matchString match: nextLine)]!

test_stackDumpHeader
	| stream crlf |
	self testsIssue: #issue455 withTitle: 'Would like args & temps in stack dump'.
	self openDebuggerOn: 'OrderedCollection with: 1 zork'.
	debugger copyStack.
	stream := ReadStream on: Clipboard current getText.
	crlf := Character cr asString , Character lf asString.
	self assert: (stream upToAll: crlf)
		equals: 'a MessageNotUnderstood occurred (error 2010), a SmallInteger does not understand  #''zork'''.
	self assert: (stream upToAll: crlf) equals: String new.	"blank line"
	1 to: 7
		do: 
			[:index |
			self assert: (stream next: 3) equals: '[' , index printString , ']'.
			stream upToAll: crlf]	"short stack up front"!

test_stackDumpTooLongString
	| stream crlf nextLine matchString |
	self testsIssue: #issue455 withTitle: 'Would like args & temps in stack dump'.
	self openDebuggerOn: '| bigStringStream |
bigStringStream := WriteStream on: String new. 
1 to: 250 do:[:idx |
	bigStringStream nextPutAll: idx printString].
OrderedCollection with:  bigStringStream contents zork'.
	debugger copyStack.
	stream := ReadStream on: Clipboard current getText.
	self assert: ('*-receiver oop(*) == ''1234567891011121314*...*' match: stream contents)!

test_stackMenuEnablement
	| frameContextMenu |
	self testsIssue: #issue103 withTitle: 'debugger, ''Executed Code'' stack frame, pop up menu items'.
	self openDebuggerOn: 'nil halt'.
	self assert: debugger frameListPresenter selection equals: 'Executed Code  @2 line 1'.
	frameContextMenu := debugger frameListPresenter view contextMenu.
	frameContextMenu itemsDo: 
			[:item |
			(item isDivider not and: [(item command = #copyFrameString) not])
				ifTrue: [self deny: (self menuItemIsEnabled: item)]].
	debugger frameListPresenter selection: (debugger frameListPresenter list at: 2).
	frameContextMenu
		itemsDo: [:item | item isDivider not ifTrue: [self assert: (self menuItemIsEnabled: item)]]!

test_stepOutMethod
	"not in a block. Step out to higher level method context"

	self
		openDebuggerOn: '| abc |
self halt.
abc := OrderedCollection with: 1 with: 2 with: 3. 
abc do:[:int |
	| array |
	array := OrderedCollection with: $a with: $b with: $c. 
	array do: [:char | 
		char size. 
		char printString].
	int size. 
	int printString. 
	int - 1]. 
abc'.
	self assert: debugger documentPresenter view selection equals: 'halt'.
	self debuggerDo: [debugger stepOver].
	self assert: debugger documentPresenter view selection equals: 'with:'.
	self debuggerDo: [debugger stepInto].
	self assert: ('OrderedCollection class (SequenceableCollection class) >> with:with:with:*'
				match: debugger frameListPresenter selection).
	self debuggerDo: [debugger stepOut].
	self assert: debugger frameListPresenter selection equals: 'Executed Code  @4 line 3'.	"on the top frame so should step one frame up"
	self assert: debugger documentPresenter view selection equals: ':='!

test_stepOutSelectedFrame1
	self
		openDebuggerOn: '| abc |
self halt.
abc := Array with: 1 with: 2 with: 3. 
abc do:[:int |
	| array |
	array := Array with: $a with: $b with: $c. 
	array do: [:char | 
		char size. 
		char printString].
	int size. 
	int printString. 
	int - 1]. 
abc'.
	self assert: debugger documentPresenter view selection equals: 'halt'.
	self debuggerDo: [debugger stepOver].
	self assert: debugger documentPresenter view selection equals: 'with:'.
	self debuggerDo: [debugger stepOver].
	self debuggerDo: [debugger stepOver].
	self debuggerDo: [debugger stepInto].
	self debuggerDo: [debugger stepOver].
	self debuggerDo: [debugger stepOver].
	self debuggerDo: [debugger stepOver].
	self debuggerDo: [debugger stepOver].
	self debuggerDo: [debugger stepInto].
	self assert: debugger documentPresenter view selection equals: 'with:'.	"inner #with:with:with:"
	debugger frameListPresenter selectionByIndex: 3.
	self debuggerDo: [debugger stepOut].
	self assert: ('Executed Code*' match: debugger frameListPresenter selection).	"on the top frame so should step one frame up"
	self assert: debugger documentPresenter view selection equals: '[:'!

test_stepOutSelectedFrame2
	self
		openDebuggerOn: '| abc |
self halt.
abc := Array with: 1 with: 2 with: 3. 
abc do:[:int |
	| array |
	array := Array with: $a with: $b with: $c. 
	array do: [:char | 
		char size. 
		char printString].
	int size. 
	int printString. 
	int - 1]. 
abc'.
	self assert: debugger documentPresenter view selection equals: 'halt'.
	self debuggerDo: [debugger stepOver].
	self assert: debugger documentPresenter view selection equals: 'with:'.
	self debuggerDo: [debugger stepOver].
	self debuggerDo: [debugger stepOver].
	self debuggerDo: [debugger stepInto].
	self debuggerDo: [debugger stepOver].
	self debuggerDo: [debugger stepOver].
	self debuggerDo: [debugger stepOver].
	self debuggerDo: [debugger stepOver].
	self debuggerDo: [debugger stepInto].
	self assert: debugger documentPresenter view selection equals: 'with:'.	"inner #with:with:with:"
	self debuggerDo: [debugger stepOver].
	self debuggerDo: [debugger stepOver].
	self debuggerDo: [debugger stepInto].
	self debuggerDo: [debugger stepOver].
	self debuggerDo: [debugger stepOver].
	self debuggerDo: [debugger stepOver].
	self debuggerDo: [debugger stepOver].
	self debuggerDo: [debugger stepInto].
	self debuggerDo: [debugger stepOver].
	self assert: debugger documentPresenter view selection equals: 'size'.	"innermost `size`"
	debugger frameListPresenter selectionByIndex: 5.	"Executed code `home frame`"
	self debuggerDo: [debugger stepOut].
	self assert: ('Executed Code*' match: debugger frameListPresenter selection).	"on the top frame so should step one frame up"
	self assert: debugger documentPresenter view selection equals: '[:'!

test_stepOutTopFrame
	self
		openDebuggerOn: '| abc |
self halt.
abc := Array with: 1 with: 2 with: 3. 
abc do:[:int |
	| array |
	array := Array with: $a with: $b with: $c. 
	array do: [:char | 
		char size. 
		char printString].
	int size. 
	int printString. 
	int - 1]. 
abc'.
	self assert: debugger documentPresenter view selection equals: 'halt'.
	self debuggerDo: [debugger stepOver].
	self assert: debugger documentPresenter view selection equals: 'with:'.
	self debuggerDo: [debugger stepOver].
	self debuggerDo: [debugger stepOver].
	self debuggerDo: [debugger stepInto].
	self debuggerDo: [debugger stepOver].
	self debuggerDo: [debugger stepOver].
	self debuggerDo: [debugger stepOver].
	self debuggerDo: [debugger stepOver].
	self debuggerDo: [debugger stepInto].
	self assert: debugger documentPresenter view selection equals: 'with:'.	"inner #with:with:with:"
	self assert: debugger frameListPresenter selectionByIndex equals: 1.
	self debuggerDo: [debugger stepOut].
	self assert: debugger frameListPresenter selection equals: 'Array (Collection) >> do: @6 line 9'.	"on the top frame so should step one frame up"
	self assert: debugger documentPresenter view selection equals: 'to:'.
	self debuggerDo: [debugger resumeProcess]!

test_stepThrough
	self testsIssue: #issue401
		withTitle: 'Step Into A Block Without going thru the detail code? Is this possible.'.
	self
		openDebuggerOn: '| array string |
array := Array with: ''abc'' with: ''def'' with: ''ghi''. 
string := String new. 
self halt. 
array do:[:theString |
	string := string, theString]. 
array'.
	self assert: debugger documentPresenter view selection equals: 'halt'.
	self debuggerDo: [debugger stepOver].
	self assert: debugger documentPresenter view selection equals: 'do:'.
	self debuggerDo: [debugger stepThrough].
	self assert: debugger documentPresenter view selection equals: ', '.	"inside block"
	self assert: debugger frameListPresenter selection equals: '[] in  Executed Code  @2 line 6'.
	self debuggerDo: [debugger stepOver].
	self assert: debugger documentPresenter view selection equals: ':='.
	self assert: debugger frameListPresenter selection equals: '[] in  Executed Code  @3 line 6'.
	self debuggerDo: [debugger resumeProcess]!

test_terminateDoesNotWalkback
	"Terminate a process other than the primary one"

	| terminateProcess allProcesses |
	self testsIssue: #issue82 withTitle: 'Pressing Terminate button gives walkback'.
	allProcesses := session executeString: 'ProcessorScheduler scheduler allProcesses size'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[gsProcess := session executeString: '[(Delay forSeconds: 9999) wait] fork asOop'.
	self
		openDebuggerOn: 'nil halt';
		assert: debugger processListPresenter list size equals: allProcesses + 1;
		assert: (debugger processListPresenter selectionByIndex: allProcesses + 1) notNil.
	TestMessageBox plannedResult: #yes.	"confirm we want to terminate process"
	terminateProcess := 
			[self assert: debugger terminateProcess notNil.
			
			[self
				assert: debugger _processList size = allProcesses
					description: '_processList size was not ' , allProcesses size printString;
				assert: debugger processListPresenter list size = allProcesses
					description: 'processListPresenter list size was not ' , allProcesses size printString]
					on: Error
					do: 
						[:ex |
						"the debugger may be gone already"
						]]
					fork.
	self debuggerDo: [debugger resumeProcess]]
			ensure: 
				[TestMessageBox disableJadeiteTestMessageBox.
				terminateProcess terminate]!

test_unicodeMethod
	self testsIssue: #issue
		withTitle: '(3.0.65) browse methods containing `%` yields "Can''t hold $\x3B1" Dollphin error'.
	session executeString: 'RowanServicesTest new compileUnicodeMethod'.
	self openDebuggerOn: 'RowanServicesTest new iAmAUnicodeMethod'.
	self assert: debugger frameListPresenter selection
		equals: 'RowanServicesTest >> iAmAUnicodeMethod @3 line 5'.
	self assert: debugger methodSourcePresenter documentPresenter view backcolor
		equals: JadeiteTextStyles default colorForUndisplayableSource.
	self selectFrameAt: 1.
	self deny: debugger methodSourcePresenter documentPresenter view backcolor
		equals: JadeiteTextStyles default colorForUndisplayableSource.
	self selectFrameAt: 4.
	self assert: debugger frameListPresenter selection
		equals: 'RowanServicesTest >> iAmAUnicodeMethod @3 line 5'.
	self assert: debugger methodSourcePresenter documentPresenter view backcolor
		equals: JadeiteTextStyles default colorForUndisplayableSource!

test_unsavedChangesActionChangeFrame
	| finished |
	self testsIssue: #issue176 withTitle: 'unsaved debugger frame method not handled well'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[self openDebuggerOn: 'nil halt'.
	self assert: debugger frameListPresenter selection equals: 'Executed Code  @2 line 1'.
	self assert: debugger frameListPresenter selectionByIndex equals: 4.
	debugger methodSourcePresenter documentPresenter value: 'new text'.
	debugger methodSourcePresenter documentPresenter view isModified: true.
	TestMessageBox plannedResult: #no.	"ignore changes"
	finished := false.
	self
		debuggerDo: [
			[debugger stepOver.
			finished := true] forkAt: Processor activePriority + 1].
	[finished] whileFalse: [(Delay forMilliseconds: 50) wait].
	self assert: debugger frameListPresenter selectionByIndex equals: 1]
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

test_unsavedChangesActionChangeToHomeFrame
	self testsIssue: #issue176 withTitle: 'unsaved debugger frame method not handled well'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[| originalSource |
	originalSource := '(Array with: 1) do:[:obj | self halt. obj size]'.
	self openDebuggerOn: originalSource.
	self isServerVersion36 ifTrue:[
	self assert: debugger frameListPresenter selection equals: '[] in Executed Code  @7 line 1'] ifFalse:[
	self assert: debugger frameListPresenter selection equals: '[] in  Executed Code  @2 line 1'].
	debugger methodSourcePresenter documentPresenter value: 'new text'.
	debugger methodSourcePresenter documentPresenter view isModified: true.
	TestMessageBox plannedResult: #no.
	debugger frameListPresenter selectionByIndex: 6.	"Executed Code home frame"
	self assert: debugger methodSourcePresenter documentPresenter value equals: originalSource]
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

test_unsavedChangesActionStepping
	| originalSource |
	self testsIssue: #issue176 withTitle: 'unsaved debugger frame method not handled well'.
	TestMessageBox enableJadeiteTestMessageBox.
	originalSource := 'nil halt. Array new. Array new. Array new.'.
	
	[self openDebuggerOn: originalSource.
	self assert: debugger frameListPresenter selection equals: 'Executed Code  @2 line 1'.
	debugger methodSourcePresenter documentPresenter value: 'step over'.
	debugger methodSourcePresenter documentPresenter view isModified: true.
	TestMessageBox plannedResult: #no.	"don't save changes"
	self debuggerDo: [debugger stepOver].
	self assert: debugger methodSourcePresenter documentPresenter value equals: originalSource.
	debugger methodSourcePresenter documentPresenter value: 'step into'.
	debugger methodSourcePresenter documentPresenter view isModified: true.
	TestMessageBox plannedResult: #yes.	"keep changes"
	self debuggerDo: [[debugger stepInto] fork].
	self assert: debugger methodSourcePresenter documentPresenter value equals: 'step into']
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

test_variableDisplayLabels
	| source |
	self testsIssue: #issue314 withTitle: 'Jadeite debugger - Alphabetical variables'.
	self openProjectBrowser.
	self selectRowanSample1Test.
	self
		saveClass: 'RowanSample1Test'
		superclass: 'TestCase'
		instVars: #(#achoo #ulp #vooey #wahoo)
		package: 'RowanSample1-Tests'.
	source := 'testBlockMenuItems
	| xyz uvw |
	uvw := Array new. 
  self
    testBlockMenuItems: [ 
      | ghi abc def |
      def := uvw.
      def
        add: #abc;
        add: 2.
		ghi := def. 
		abc := ghi. 
      xyz
        size;
        halt ]'.
	self selectCategoriesNamed: (Array with: 'tests').
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	source := 'testBlockMenuItems: block
	block value.'.
	self selectCategoriesNamed: (Array with: 'tests').
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self openDebuggerOn: 'RowanSample1Test new testBlockMenuItems'.
	"on ExecBlock frame"
	self assert: (debugger variableListPresenter list at: 2) value equals: 'args and temps'.
	self
		assert: (debugger variableListPresenter list collect: [:variableService | variableService _key])
		equals: #(#receiver '' #abc #def #ghi #uvw #xyz) asOrderedCollection.
	self selectFrameAt: 5.
	self assert: (debugger variableListPresenter list at: 2) value equals: 'instance variables'.
	self assert: (debugger variableListPresenter list at: 8) value equals: 'args and temps'.
	self
		assert: (debugger variableListPresenter list collect: [:variableService | variableService _key])
		equals: #(#receiver '' '-achoo' '-testSelector' '-ulp' '-vooey' '-wahoo' '' #block)
				asOrderedCollection.
	self selectFrameAt: 6.
	self assert: (debugger variableListPresenter list at: 2) value equals: 'instance variables'.
	self assert: (debugger variableListPresenter list at: 8) value equals: 'args and temps'.
	self isServerVersion36
		ifTrue: 
			[self
				assert: (debugger variableListPresenter list collect: [:variableService | variableService _key])
				equals: #(#receiver '' '-achoo' '-testSelector' '-ulp' '-vooey' '-wahoo' '' #uvw #xyz)
						asOrderedCollection]
		ifFalse: 
			[self
				assert: (debugger variableListPresenter list collect: [:variableService | variableService _key])
				equals: #(#receiver '' '-achoo' '-testSelector' '-ulp' '-vooey' '-wahoo' '' #uvw)
						asOrderedCollection]!

test_variablesSorted
	| source |
	self testsIssue: #issue314 withTitle: 'Jadeite debugger - Alphabetical variables'.
	self openProjectBrowser.
	self selectRowanSample1Test.
	self
		saveClass: 'RowanSample1Test'
		superclass: 'TestCase'
		instVars: #(#achoo #ulp #vooey #wahoo)
		package: 'RowanSample1-Tests'.
	source := 'testBlockMenuItems
	| xyz uvw |
	uvw := Array new. 
  self
    testBlockMenuItems: [ 
      | ghi abc def |
      def := uvw.
      def
        add: #abc;
        add: 2.
		ghi := def. 
		abc := ghi. 
      xyz
        size;
        halt ]'.
	self selectCategoriesNamed: (Array with: 'tests').
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	source := 'testBlockMenuItems: block
	block value.'.
	self selectCategoriesNamed: (Array with: 'tests').
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self openDebuggerOn: 'RowanSample1Test new testBlockMenuItems'.
	"on ExecBlock frame"
	self
		assert: (debugger variableListPresenter list collect: [:variableService | variableService _key])
		equals: #(#receiver '' #abc #def #ghi #uvw #xyz) asOrderedCollection.
	self selectFrameAt: 5.
	self
		assert: (debugger variableListPresenter list collect: [:variableService | variableService _key])
		equals: #(#receiver '' '-achoo' '-testSelector' '-ulp' '-vooey' '-wahoo' '' #block)
				asOrderedCollection.
	self selectFrameAt: 6.
	self isServerVersion36
		ifTrue: 
			[self
				assert: (debugger variableListPresenter list collect: [:variableService | variableService _key])
				equals: #(#receiver '' '-achoo' '-testSelector' '-ulp' '-vooey' '-wahoo' '' #uvw #xyz)
						asOrderedCollection]
		ifFalse: 
			[self
				assert: (debugger variableListPresenter list collect: [:variableService | variableService _key])
				equals: #(#receiver '' '-achoo' '-testSelector' '-ulp' '-vooey' '-wahoo' '' #uvw)
						asOrderedCollection]!

test1
	"Basics of opening a debugger, viewing the UI, and resuming."

	| x |
	self 
		openDebuggerOn: 'nil halt';
		assert: (x := debugger errorMessagePresenter value) = 'a Halt occurred (error 2709)';
		assert: (x := debugger processListPresenter list size) == 1;
		assert: (x := debugger frameListPresenter list size) == 5;
		assert: (x := debugger frameListPresenter selection) = 'Executed Code  @2 line 1';
		assert: (x := debugger variableListPresenter list size) == 1;
		assert: (x := debugger variableListPresenter list first) class == RowanVariableService;		assert: x oop == 20;
		assert: x _key == #'receiver';
		assert: x value = 'nil';
		debuggerDo: [debugger resumeProcess];
		assert: (x := debugger view) class == DeafObject;
		yourself.
!

test2
	"Stepping (note that 3.2.15 has some odd behaviors)"

	self 
		openDebuggerOn: '| x | 
nil halt.
x := 1 + 2 * 3.
1 == 1 ifTrue: [x := 1].
1 to: 1 by: 1 do: [:i | x := i ].
[x := 2] value.
x yourself';
		assert: (debugger errorMessagePresenter value) equals: 'a Halt occurred (error 2709)';
		assert: (debugger frameListPresenter selection) equals: 'Executed Code  @2 line 2';
		assert: (debugger documentPresenter view selection) equals: 'halt';
		debuggerDo: [debugger stepOver];
		assert: (debugger documentPresenter view selection) equals: '+ ';
		debuggerDo: [debugger stepOver];
		assert: (debugger documentPresenter view selection) equals: '* ';
		debuggerDo: [debugger stepOver];
		assert: (debugger documentPresenter view selection) equals: ':=';
		debuggerDo: [debugger stepOver];
		assert: (debugger documentPresenter view selection) equals: '==';
		debuggerDo: [debugger stepOver];
		assert: (debugger documentPresenter view selection) equals: 'ifTrue:';
		debuggerDo: [debugger stepOver];
		assert: (debugger documentPresenter view selection) = ':=';
		debuggerDo: [debugger stepOver];
		debuggerDo: [debugger stepOver];
		assert: (debugger documentPresenter view selection) = 'to:'; 
		debuggerDo: [debugger stepOver];
		assert: (debugger documentPresenter view selection) = ':=';
		debuggerDo: [debugger stepOver];
		assert: (debugger documentPresenter view selection) equals: 'to:';
		debuggerDo: [debugger stepOver];
		debuggerDo: [debugger stepOver];
		assert: (debugger documentPresenter view selection) equals: 'value'; 
		debuggerDo: [debugger stepInto];
		assert: (debugger documentPresenter view selection) equals: ':=';
		debuggerDo: [debugger stepOver];
		debuggerDo: [debugger stepOut];
		assert: (debugger documentPresenter view selection) equals: 'yourself';
		debuggerDo: [debugger resumeProcess];
		yourself.
!

test3
	"browse stack class"

	self
		openDebuggerOn: '| x | 
nil halt.
x := 1 -> 2.
x yourself';
		debuggerDo: [debugger stepOver];
		assert: debugger documentPresenter view selection equals: '->';
		debuggerDo: [debugger stepInto];
		debuggerDo: [projectsBrowser := debugger browseFrameMethod];
		assert: projectsBrowser isKindOf: JadeiteBrowser.
	
	[self
		assert: (self projectsPresenter classListPresenter selections
					collect: [:classService | classService name])
			equals: #('Object');
		assert: self projectsPresenter methodListPresenter selection name equals: '->';
		debuggerDo: [debugger resumeProcess]]
			ensure: [projectsBrowser view close]!

test4
	"browse variable class"

	| browser |
	self
		openDebuggerOn: '| x | 
nil halt.
x := 1 -> 2.
x yourself';
		debuggerDo: [debugger stepOver];
		debuggerDo: [debugger stepOver];
		debuggerDo: [debugger stepOver];
		assert: (debugger variableListPresenter selectionByIndex: 2) notNil;
		debuggerDo: [projectsBrowser := debugger browseObjectClass];
		assert: projectsBrowser isKindOf: JadeiteBrowser.
	
	[self
		assert: (self projectsPresenter classListPresenter selections
					collect: [:classService | classService name])
			equals: #('Association');
		debuggerDo: [debugger resumeProcess]]
			ensure: [projectsBrowser view close]!

test5
	"browse implementors"

	| browser list |
	self 
		openDebuggerOn: '| x | 
nil halt.
x := 1 -> 2.
x yourself';
		debuggerDo: [debugger stepOver];
		assert: debugger documentPresenter view selection equals: '->';
		debuggerDo: [debugger stepInto];

		debuggerDo: [debugger browseImplementors];
		assert: (browser := self methodListBrowser) notNil;		assert: (list := browser primaryPresenter methodListPresenter primaryPresenter list) notEmpty;
		assert: list size < 10;

		debuggerDo: [debugger resumeProcess];
		yourself.
!

test6
	"browse senders"

	| browser list |
	[
		500 timesRepeat: [
			(Delay forMilliseconds: 10) wait.
			SessionManager inputState prod.
		].
	] forkAt: Processor userBackgroundPriority.
	self 
		openDebuggerOn: '| x | 
nil halt.
x := 1 -> 2.
x yourself';
		assert: debugger documentPresenter view selection equals: 'halt';
		debuggerDo: [debugger stepOver];
		assert: debugger documentPresenter view selection equals: '->';
		debuggerDo: [debugger stepInto];

		debuggerDo: [debugger browseSenders];
		assert: (browser := self methodListBrowser) notNil;
		assert: (list := browser primaryPresenter methodListPresenter primaryPresenter list) notEmpty;
		assert: list size > 10;

		debuggerDo: [debugger resumeProcess];
		yourself.
!

test7
	"set/clear breakpoints"

	| indicator |
	self 
		openDebuggerOn: '| x | 
nil halt.
x := 1 -> 2.
x yourself';
		assert: (indicator := debugger methodSourcePresenter documentPresenter view indicators at: 2) notNil;
		assert: indicator range = (12 to: 15);
		assert: indicator styleName equals: #stepPoint;
		assert: indicator tag = 'step point #2';

		debuggerDo: [debugger methodSourcePresenter setBreakPointAt: 2 in: debugger];
		assert: (indicator := debugger methodSourcePresenter documentPresenter view indicators at: 2) notNil;
		assert: indicator range = (12 to: 15);
		assert: indicator styleName equals:  #breakPoint;
		assert: indicator tag = 'Break at step point #2';

		debuggerDo: [debugger methodSourcePresenter clearBreakPointAt: 2 in: debugger];
		assert: (indicator := debugger methodSourcePresenter documentPresenter view indicators at: 2) notNil;
		assert: indicator range = (12 to: 15);
		assert: indicator styleName equals:  #stepPoint;
		assert: indicator tag = 'step point #2';

		debuggerDo: [debugger resumeProcess];
		yourself.
!

test8
	"https://github.com/ericwinger/Jade/issues/20"

	self
		assert: JadeiteDebugger allInstances isEmpty;
		debuggerDo: 
				[process := 
						[session
							debugString: '#(abc def) do:[:symbol | symbol size]'
							fromContext: nil
							environment: 0]
								fork];
		getDebugger;
		yourself.
	self debuggerDo: [debugger resumeProcess]!

testBug77

	| string view |
	string := '"
2 + 3
x
"
| x |
x := 4 + 8.
x halt.
'.
	self 
		openDebuggerOn: string;
		assert: (view := debugger documentPresenter view) class equals: JadeiteScintillaView;
		assert: (view selectionRange: (3 to: 7)) notNil;
		"debuggerDo: [debugger jadeDisplay];
		assert: view selection equals: ' 5';
		halt;"
		yourself.
! !
!JadeiteDebuggerTestCase categoriesFor: #setUp!private!setup teardown! !
!JadeiteDebuggerTestCase categoriesFor: #test_additionalAccelerators!public!test menus! !
!JadeiteDebuggerTestCase categoriesFor: #test_adHocDebug!public!test ad hoc execution! !
!JadeiteDebuggerTestCase categoriesFor: #test_adHocExecutionEvaluatesArgs!public!test ad hoc execution! !
!JadeiteDebuggerTestCase categoriesFor: #test_adHocExecutionEvaluatesTemp!public!test ad hoc execution! !
!JadeiteDebuggerTestCase categoriesFor: #test_adHocExecutionSelf!public!test ad hoc execution! !
!JadeiteDebuggerTestCase categoriesFor: #test_adHocExecutionUpdatesVariablesList!public!test ad hoc execution! !
!JadeiteDebuggerTestCase categoriesFor: #test_adHocVariablePaneDisplay!public!test ad hoc execution! !
!JadeiteDebuggerTestCase categoriesFor: #test_adHocVariablePaneExecute!public!test ad hoc execution! !
!JadeiteDebuggerTestCase categoriesFor: #test_adHocVariablePaneInspect!public!test ad hoc execution! !
!JadeiteDebuggerTestCase categoriesFor: #test_adHocVariablePaneInspect2!public!test ad hoc execution! !
!JadeiteDebuggerTestCase categoriesFor: #test_badCompileInDebugger!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_breakpointDisabledHighlighting!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_breakpointHighlighting!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_breakpointHighlightingInBlocks!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_browseClass!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_browseClassVariablePane!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_browseFrameClassMethod!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_browseFrameMethod!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_browseFrameMethodInBlock!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_browseImplementorsInBlock!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_browseSelectedFrameClassMethod!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_browseSelectedFrameMethod!public!test menus! !
!JadeiteDebuggerTestCase categoriesFor: #test_browseSelectedFrameMethodClassSide!public!test menus! !
!JadeiteDebuggerTestCase categoriesFor: #test_browseSendersInBlock!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_bug74!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_compileError!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_compileInExecutedBlock!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_compileInExecutedBlockFailsWhenNoHomeMethod!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_compileInExecutedBlockSameSelectorOnStack!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_contextMenu!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_copyFrameString!public!test menus! !
!JadeiteDebuggerTestCase categoriesFor: #test_copyNotifierStack!public!test notifier! !
!JadeiteDebuggerTestCase categoriesFor: #test_debugCodeWithLeadingLineReturns!public! !
!JadeiteDebuggerTestCase categoriesFor: #test_debugCodeWithLeadingLineReturnsLF!public! !
!JadeiteDebuggerTestCase categoriesFor: #test_debugCodeWithLeadingTab!public! !
!JadeiteDebuggerTestCase categoriesFor: #test_debugFromWithinInspector!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_debuggerModifiedSourcePaneChangeFrame!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_debuggerModifiedSourcePaneStayOnFrame!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_disablebreakpointHighlighting!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_doubleClickIncludesColon!public!test source! !
!JadeiteDebuggerTestCase categoriesFor: #test_duplicateInstVars!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_duplicateInstVarsHierarchy!public!test class hierarchy! !
!JadeiteDebuggerTestCase categoriesFor: #test_duplicateInstVarsInHierarchy!public!test class hierarchy! !
!JadeiteDebuggerTestCase categoriesFor: #test_errorInPrintString!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_frameDoubleClick!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_frameDoubleClickNoActionInBlockContext!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_implementersFromDebugger!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_implementorsSendersCaption!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_inspectedDebuggerObjectHeld!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_jadeItemsOnMenu!public!test menus! !
!JadeiteDebuggerTestCase categoriesFor: #test_loginButtonEnablementAfterDebug!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_openDebuggerWthBreakpointInDebuggerService!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_processIsServices!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_processSwitching!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_processTermination!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_reformatIllegalSource!public!test source! !
!JadeiteDebuggerTestCase categoriesFor: #test_reformatSource!public!test source! !
!JadeiteDebuggerTestCase categoriesFor: #test_reformatSourceDoesNotStick!public!test source! !
!JadeiteDebuggerTestCase categoriesFor: #test_reformatSourceIsUndoable!public!test source! !
!JadeiteDebuggerTestCase categoriesFor: #test_registeredPresentersInProjectBrowserCleanedUp!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_reloadWithDebuggerOpen!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_reopenInLastExtent!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_reopenInLastPosition!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_restartInBlock!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_runningTestDoesNotLoseStepPoint!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_saveMethod!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_saveMethodDuringTestRun!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_selectAfterDiveNoStepPoint!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_selectBlockContext!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_sendersFromDebugger!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_stackDumpDetailedFrame!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_stackDumpHeader!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_stackDumpTooLongString!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_stackMenuEnablement!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_stepOutMethod!public!test step out! !
!JadeiteDebuggerTestCase categoriesFor: #test_stepOutSelectedFrame1!public!test step out! !
!JadeiteDebuggerTestCase categoriesFor: #test_stepOutSelectedFrame2!public!test step out! !
!JadeiteDebuggerTestCase categoriesFor: #test_stepOutTopFrame!public!test step out! !
!JadeiteDebuggerTestCase categoriesFor: #test_stepThrough!public!test step out! !
!JadeiteDebuggerTestCase categoriesFor: #test_terminateDoesNotWalkback!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_unicodeMethod!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_unsavedChangesActionChangeFrame!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_unsavedChangesActionChangeToHomeFrame!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_unsavedChangesActionStepping!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_variableDisplayLabels!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_variablesSorted!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test1!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test2!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test3!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test4!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test5!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test6!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test7!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test8!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #testBug77!public! !

