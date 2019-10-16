"Filed out from Dolphin Smalltalk 7"!

JadeiteAbstractTestCase subclass: #JadeiteDebuggerTestCase
	instanceVariableNames: 'debugger gsProcess process secondDebugger'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteDebuggerTestCase guid: (GUID fromString: '{f159d434-7740-414b-9e64-d9fdde995061}')!
JadeiteDebuggerTestCase comment: 'Tests the Jadeite debugger. 

It''s recommended to run this set of tests with a fresh login to avoid counting stale processes. '!
!JadeiteDebuggerTestCase categoriesForClass!SUnit! !
!JadeiteDebuggerTestCase methodsFor!

cleanupProcesses
	debugger
		ifNotNil: 
			[debugger debuggerService processes do: 
					[:processService |
					session executeString: '[(Object _objectForOop: ' , processService oop printString
								, ') terminate] on: Error do:[:ex | "ignore"]']]!

closeDebuggers
	| list semaphore |
	list := JadeiteMethodListBrowser allInstances , RowanSystemBrowser allInstances
				, JadeiteDebugger allInstances. 
	semaphore := Semaphore new.
	list do: 
			[:each |
			session removeEventsTriggeredFor: each.
			
			[
			[each view close.
			each become: Object new.
			semaphore signal.
			SessionManager inputState prod]
					on: ProcessTermination
					do: 
						[:ex |
						"A debugger wants to terminate the current process!!!!"
						
						[each become: Object new.
						semaphore signal.
						SessionManager inputState prod]
								forkAt: Processor userBackgroundPriority.
						ex pass]]
					fork.
			semaphore wait.
			debugger == each ifTrue: [debugger := nil]].
	list := JadeiteMethodListBrowser allInstances , RowanSystemBrowser allInstances
				, JadeiteDebugger allInstances.
	self assert: list isEmpty!

closeJadeiteLoginShells
	| query |
	JadeiteLoginShell allInstances do: 
			[:inst |
			query := CommandQuery commandDescription: (CommandDescription command: #login)
						source: inst loginButtonPresenter view.
			inst queryCommand: query.
			self assert: query isEnabled.	"any login shell should have a disabled login button"
			inst view close].
	^query!

createTestMethodWithBreakpoints
	self openProjectBrowser.
	self selectRowanSample1Test.
	self
		saveMethod: 'test_highlightBreaks
	"self new test_highlightBreaks"
	| var i log |

	[
		var := WriteStream on: String new.
		log := String new.
		i := 20.
		var nextPutAll: ''123''.
		log add: ''abc''.
		
	] ensure: 
	[
		log size < 5 ifTrue: [log add: ''def''].
		var contents size < 5 ifTrue: [log add: ''456''].
		i = 20 ifTrue: [ i := 3].
	].

	self assert: i = 3'
		in: 'RowanSample1Test'
		category: 'tests'.
	self selectMethodNamed: #test_highlightBreaks.
	self setBreakAt: 20.
	self setBreakAt: 25.
	self setBreakAt: 28!

debuggerDo: aBlock
	self assert: JadeiteDebugger semaphore isNil.
	JadeiteDebugger semaphore: Semaphore new.
	[aBlock value] ensure: 
			[JadeiteDebugger semaphore wait.
			JadeiteDebugger semaphore: nil]!

getClipboardContents
	"Private - `Clipboard current getText` occasionally gets an `Access is denied` error.
	Retry several times, pausing in between each attempt, until the clipboard is retrieved."

	| clipboardContents contentsRetrieved |
	contentsRetrieved := true.
	[clipboardContents := Clipboard current getText] on: Error do: [:ex | contentsRetrieved := false].
	contentsRetrieved
		ifFalse: 
			[(Delay forMilliseconds: 100) wait.
			clipboardContents := Clipboard current getText].
	^clipboardContents!

getDebugger
	"need a more definitive test to know when debugger is fully built"

	100 timesRepeat: 
			[debugger := JadeiteDebugger allInstances detect: [:each | true] ifNone: [nil].
			(debugger notNil and: 
					[debugger documentPresenter view selection notEmpty and: 
							[debugger gciSession notNil
								and: [debugger methodSourcePresenter gciSession notNil and: [debugger basicSelectedFrame notNil]]]])
				ifTrue: [^self].
			(Delay forMilliseconds: 10) wait]!

getSecondDebugger
	"Private - we opened up one debugger in the test, then another. find the second"

	100 timesRepeat: 
			[secondDebugger := JadeiteDebugger allInstances detect: [:each | true] ifNone: [nil].
			(secondDebugger notNil and: 
					[secondDebugger gsProcess notNil
						and: [secondDebugger documentPresenter view selection notEmpty and: [secondDebugger ~~ debugger]]])
				ifTrue: [^self].
			(Delay forMilliseconds: 10) wait]!

keyDownEscapeIn: view
	^view
		postMessage: 16r100
			wParam: 27
			lParam: 0;
		postMessage: 16r101
			wParam: 27
			lParam: 0;
		yourself	"WM_KEYDOWN"	"VK_ESCAPE"	"WM_KEYUP"	"VK_ESCAPE"!

menuItemIsEnabled: menuItem
	| commandPolicy commandQuery |
	commandPolicy := CommandPolicy defaultClass commandSource: debugger view.
	commandQuery := menuItem queryAlong: commandPolicy.
	^commandQuery isEnabled!

methodListBrowser

	^JadeiteMethodListBrowser allInstances detect: [:each | true] ifNone: [nil]
!

openDebuggerOn: aString
	self
		assert: JadeiteDebugger allInstances isEmpty;
		debuggerDo: [process := [session executeString: aString] forkAt: Processor activePriority + 1];
		getDebugger;
		yourself!

pressButtonIn: view
	view
		postMessage: 16r204
			wParam: 0
			lParam: 16r12C0064;
		postMessage: 16r205
			wParam: 0
			lParam: 16r12C0064;
		yourself	"WM_RBUTTONDOWN"	" (300 @ 100) "	"WM_RBUTTONUP"!

removeMethodNamed: aSymbol
	| classService methodService |
	methodService := RowanMethodService new
				selector: aSymbol;
				className: 'RowanSample1Test';
				meta: false.
	classService := RowanClassService new name: 'RowanSample1Test'.
	classService
		command: #removeMethods:;
		commandArgs: (Array with: (Array with: methodService)).
	^self issueCommand: classService!

saveMethodWithHalt
	| source |
	source := 'sampleMethodWithHalt
		| array  | 
		array := Array new halt. 
		^array'.
	self saveMethod: source in: 'RowanSample1' category: 'other'!

selectFrameAt: integer
	"foolishly, the selection changing event which needs testing
	is only sent through a button click in Dolphin. We need to 
	fake it out for the test. frustrating.

	Note - even though we are faking up the event, the event itself
	should get modified based on the debugger's state which is a
	valid test."

	| event |
	event := (SelectionChangingEvent forSource: self)
				oldSelections: debugger frameListPresenter selections;
				newSelections: (Array with: (debugger frameListPresenter list at: integer));
				cause: #test;
				yourself.
	debugger frameListPresenter onSelectionChanging: event.
	event value ifFalse:[^self]. 
	debugger frameListPresenter selection: (debugger frameListPresenter list at: integer)!

setBreakAt: anInteger
	self projectsPresenter setBreakPointAt: anInteger in: self projectsPresenter!

setUp
	super setUp.
	self closeDebuggers.
	JadeiteDebugger debuggerClass: JadeiteDebugger.
	self assertIsNil: JadeiteDebugger semaphore.
	self assert: session notNil.
	session := GciSession current!

statusBarValue
	^(debugger view viewNamed: 'statusBarField') value!

systemBrowser

	^JadeiteBrowser allInstances detect: [:each | true] ifNone: [nil]
!

tearDown
	self cleanupProcesses.
	projectsBrowser
		ifNotNil: 
			[projectsBrowser view close.
			projectsBrowser := nil].
	debugger ifNotNil: [debugger documentPresenter view isModified: false].
	secondDebugger ifNotNil: [secondDebugger documentPresenter view isModified: false].
	process
		ifNotNil: 
			[process terminate.
			process := nil].
	self
		terminateGsProcess;
		closeDebuggers;
		yourself.
	JadeiteDebugger debuggerClass: nil.
	JadeiteDebugger semaphore: nil.
	super tearDown!

terminateGsProcess
	| string |
	gsProcess ifNil: [^self].
	string := '
| gsProcess |
gsProcess := Object _objectForOop: ' , gsProcess printString
				, '.
gsProcess ifNotNil: [gsProcess terminate. (Delay forMilliseconds: 10) wait].
Processor allProcesses includes: gsProcess'.
	gsProcess := nil.
	5 timesRepeat: 
			[(debugger gciSession executeString: string) == false ifTrue: [^self]	"might not be a boolean. process could be terminated"].
	self assert: false!

test_additionalAccelerators
	"No way yet to adequately test accelerators function
	but we can assert that we tell Dolphin to set them up"

	self openDebuggerOn: 'self halt'.
	self assert: debugger additionalAccelerators first first equals: #reformatSource.
	self assert: debugger additionalAccelerators first last equals: 'Ctrl+Shift+O'.
	self assert: debugger additionalAccelerators size equals: 1	"should fail if we add a new one"!

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
	self assert: debugger variableListPresenter selection value equals: 5]
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
	self assert: (debugger variableListPresenter list at: 2) value equals: 567.
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
		equals: JadeTextStyles default colorForCompileError.
	source := 'sampleMethodWithHalt
		"this code will fail compile"
		array := Array with: 1.'.
	debugger methodSourcePresenter documentPresenter value: source.
	debugger saveMethod.
	self assert: self statusBarValue equals: 'undefined symbol'.
	self assert: debugger methodSourcePresenter documentPresenter view backcolor
		equals: JadeTextStyles default colorForCompileError!

test_breakpointHighlightingInBlocks
	| sourcePresenter |
	self createTestMethodWithBreakpoints.
	self openDebuggerOn: 'RowanSample1Test new test_highlightBreaks'.
	
	[self assert: debugger frameListPresenter selection
		equals: '[] in  ExecBlock0 (RowanSample1Test) >> test_highlightBreaks @5 line 14'.
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
	self openDebuggerOn: 'nil halt. Array with: RowanClassService new'.
	self debuggerDo: [debugger stepOver].
	self debuggerDo: [debugger stepOver].	"on with:"
	self debuggerDo: [debugger stepInto].
	debugger variableListPresenter selectionByIndex: 1.
	self assert: debugger variableDataPresenter value equals: 'Array'.
	projectsBrowser := debugger browseObjectClass.
	
	[self assert: (projectsBrowser isKindOf: JadeiteBrowser).
	self assert: projectsBrowser currentCard classListPresenter selection name equals: 'Array'	"receiver is Array class"]
			ensure: [projectsBrowser view close].
	debugger variableListPresenter selectionByIndex: 2.
	self assert: debugger variableDataPresenter value equals: 'aRowanClassService:nil'.
	projectsBrowser := debugger browseObjectClass.
	
	[self assert: (projectsBrowser isKindOf: JadeiteBrowser).
	self assert: projectsBrowser currentCard classListPresenter selection name
		equals: 'RowanClassService'	"receiver is Array class"]
			ensure: [self destroy: projectsBrowser]!

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
	self assert: (debugger frameListPresenter list at: 4) equals: '[] in  Executed Code  @2 line 1'.
	debugger documentPresenter value: '#(1 2 3) do:[:idx | self].'.
	TestMessageBox plannedResult: 'ok'.
	debugger saveMethod.
	self assert: debugger frameListPresenter selectionByIndex equals: 4.
	self assert: (debugger frameListPresenter list at: 4) equals: '[] in  Executed Code  @2 line 1']
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
	self assert: (debugger frameListPresenter list at: 4)
		equals: '[] in  ExecBlock1 (RowanSample1) >> doSomething @2 line 4'.
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
	
	[self assert: (session
				executeString: '(self at: 1) class = Object'
				fromContext: inspector model
				environment: 0).
	self assert: inspector documentPresenter value equals: 'anArray( anObject)'.
	process terminate.
	self closeDebuggers.

	"do stuff while the debugger is closed to hopefully recycle the oop (if the bug was present)"
	self openProjectBrowser.
	
	[self assert: (session
				executeString: '(self at: 1) class = Object'
				fromContext: inspector model
				environment: 0)]
			ensure: [projectsBrowser view close].
	self openProjectBrowser.
	
	[self assert: (session
				executeString: '(self at: 1) class = Object'
				fromContext: inspector model
				environment: 0)]
			ensure: [projectsBrowser view close]]
			ensure: [inspector view close]!

test_loginButtonEnablementAfterDebug
	"transcript close wasn't setting GciSession current to nil"

	| jadeiteShell query sunitPresenter |
	self testsIssue: #issue527 withTitle: 'Multiple sessions can''t keep console project list straight'.
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #no.	"don't commit"
	
	[GciSession current ifNotNil: [:sess | sess logout].
	query := self closeJadeiteLoginShells.
	jadeiteShell := JadeiteLoginShell show position: 80 @ 20.
	jadeiteShell login.
	session := GciSession current.
	transcript := JadeiteTranscript allInstances detect: [:tran | tran gciSession == session] ifNone: [].
	query := CommandQuery commandDescription: (CommandDescription command: #login)
				source: jadeiteShell view.
	jadeiteShell view queryCommand: query.
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
	jadeiteShell := JadeiteLoginShell allInstances first.
	query := CommandQuery commandDescription: (CommandDescription command: #login)
				source: jadeiteShell loginButtonPresenter view.
	jadeiteShell queryCommand: query.
	self assert: query isEnabled]
			ensure: 
				[TestMessageBox disableJadeiteTestMessageBox.
				debugger := nil.
				process terminate.
				process := nil.
				session := jadeiteShell login.
				transcript := JadeiteTranscript allInstances detect: [:tran | tran gciSession == session] ifNone: [].
				self class resources do: 
						[:resource |
						resource current
							transcript: transcript;
							session: session]]!

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
	self assert: debugger documentPresenter value
		equals: 'reformatSourceTemporaryMethod
  self halt.
  ^ #''test''' replaceCrLfWithLf]
			ensure: [debugger documentPresenter view isModified: false]!

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
	self assert: debugger documentPresenter view text
		equals: 'reformatSourceTemporaryMethod
  | abc |
  abc := #''abc''.
  ^ abc' replaceCrLfWithLf.
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

test_restartInBlock
	| restartProcess |
	self testsIssue: #issue126
		withTitle: 'Debugger opens second debugger, loses stack in original debugger'.
	self openProjectBrowser.
	self selectRowanSample1Class.
	self saveInterestingLoopMethod.
	self projectsPresenter setBreakPointAt: 8 in: self projectsPresenter.	"inside the block"
	
	[self openDebuggerOn: 'RowanSample1 new interestingLoop'.
	restartProcess := [self debuggerDo: [debugger restart]] fork.	"can't restart inside block. expect notifier"
	
	[self getSecondDebugger.
	self denyIsNil: secondDebugger.
	self deny: debugger == secondDebugger.
	self deny: debugger gsProcess oop = secondDebugger gsProcess oop.
	self deny: debugger frameListPresenter list size = secondDebugger frameListPresenter list size]
			ensure: [restartProcess terminate]]
			ensure: 
				[self projectsPresenter clearBreakPointAt: 8 in: self projectsPresenter.	"inside the block"
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
	self testsIssue: #issue166
		withTitle: 'Debugger step with unsaved edits results in empty source pane'.
	self openProjectBrowser.
	self selectRowanSample1Class.
	self saveInterestingLoopMethod.
	self projectsPresenter setBreakPointAt: 8 in: self projectsPresenter.	"inside the block"
	
	[self openDebuggerOn: 'RowanSample1 new interestingLoop'.
	self debuggerDo: [debugger stepInto].
	self assert: debugger frameListPresenter list first equals: 'RowanSample1 >> test @1 line 1'.
	self assert: (debugger frameListPresenter list at: 2)
		equals: '[] in  ExecBlock1 (RowanSample1) >> interestingLoop @2 line 8'.
	[self selectFrameAt: 2] fork.	"<<< Walkback occurred here"	"Fork so that the tests' error handler doesn't catch the expected error raised in #selectedFrame"
	(Delay forMilliseconds: 100) wait.
	[debugger documentPresenter value replaceLfWithCrLf isEmpty]
		whileTrue: [(Delay forMilliseconds: 10) wait].
	self assert: debugger documentPresenter value replaceLfWithCrLf
		equals: self interestingLoopMethodSource]
			ensure: 
				[self projectsPresenter clearBreakPointAt: 8 in: self projectsPresenter.
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
	frameContextMenu itemsDo: [:item | self deny: (self menuItemIsEnabled: item)].
	debugger frameListPresenter selection: (debugger frameListPresenter list at: 2).
	frameContextMenu itemsDo: [:item | self assert: (self menuItemIsEnabled: item)]!

test_stepOutMethod
	"not in a block. Step out to higher level method context"

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
	self debuggerDo: [debugger stepInto].
	self assert: debugger documentPresenter view selection equals: 'new:'.
	self assert: debugger frameListPresenter selection
		equals: 'Array class (SequenceableCollection class) >> with:with:with: @2 line 9'.
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

test_switchProcesses
	| activeProcesses longRunningProcess |
	activeProcesses := session executeString: 'ProcessorScheduler scheduler allProcesses size'.
	gsProcess := session executeString: '[(Delay forSeconds: 9999) wait] fork asOop.'.
	session executeString: '(Delay forSeconds: 1) wait'.	"let forked process start"
	self
		openDebuggerOn: 'nil halt';
		assert: debugger _processList size equals: activeProcesses + 1;
		assert: debugger processListPresenter list size equals: activeProcesses + 1.
	longRunningProcess := debugger processListPresenter list
				detect: [:processService | processService oop = gsProcess].
	self debuggerDo: [debugger processListPresenter selection: longRunningProcess].
	self debuggerDo: [self selectFrameAt: 6].
	self
		assert: debugger methodSourcePresenter documentPresenter value
			equals: '[(Delay forSeconds: 9999) wait] fork asOop.';
		assert: longRunningProcess oop equals: gsProcess!

test_terminateDoesNotWalkback
	"Terminate a process other than the primary one"

	| terminateProcess allProcesses |
	self testsIssue: #issue82 withTitle: 'Pressing Terminate button gives walkback'.
	allProcesses := session executeString: 'ProcessorScheduler scheduler allProcesses size'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[gsProcess := session executeString: '[(Delay forSeconds: 9999) wait] fork asOop'.
	self
		openDebuggerOn: 'nil halt';
		assert: debugger _processList size equals: allProcesses + 1;
		assert: debugger processListPresenter list size equals: allProcesses + 1;
		assert: (debugger processListPresenter selectionByIndex: allProcesses + 1) notNil.
	TestMessageBox plannedResult: #yes.	"confirm we want to terminate process"
	terminateProcess := 
			[self assert: debugger terminateProcess notNil.
			self
				assert: debugger _processList size = allProcesses
					description: '_processList size was not ' , allProcesses size printString;
				assert: debugger processListPresenter list size = allProcesses
					description: 'processListPresenter list size was not ' , allProcesses size printString]
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
	self assert: debugger methodSourcePresenter documentPresenter view backcolor equals: JadeTextStyles default colorForUndisplayableSource .
	self selectFrameAt: 1.
	self deny: debugger methodSourcePresenter documentPresenter view backcolor equals: JadeTextStyles default colorForUndisplayableSource .
	self selectFrameAt: 4.
	self assert: debugger frameListPresenter selection
		equals: 'RowanServicesTest >> iAmAUnicodeMethod @3 line 5'.
	self assert: debugger methodSourcePresenter documentPresenter view backcolor equals: JadeTextStyles default colorForUndisplayableSource .!

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
	self assert: debugger frameListPresenter selection equals: '[] in  Executed Code  @2 line 1'.
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
		assert: indicator styleName = 8;
		assert: indicator tag = 'step point #2';

		debuggerDo: [debugger methodSourcePresenter setBreakPointAt: 2 in: debugger];
		assert: (indicator := debugger methodSourcePresenter documentPresenter view indicators at: 2) notNil;
		assert: indicator range = (12 to: 15);
		assert: indicator styleName = 9;
		assert: indicator tag = 'Break at step point #2';

		debuggerDo: [debugger methodSourcePresenter clearBreakPointAt: 2 in: debugger];
		assert: (indicator := debugger methodSourcePresenter documentPresenter view indicators at: 2) notNil;
		assert: indicator range = (12 to: 15);
		assert: indicator styleName = 8;
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
!JadeiteDebuggerTestCase categoriesFor: #cleanupProcesses!private!support! !
!JadeiteDebuggerTestCase categoriesFor: #closeDebuggers!private!support! !
!JadeiteDebuggerTestCase categoriesFor: #closeJadeiteLoginShells!private!support! !
!JadeiteDebuggerTestCase categoriesFor: #createTestMethodWithBreakpoints!private!support!tests! !
!JadeiteDebuggerTestCase categoriesFor: #debuggerDo:!private!support! !
!JadeiteDebuggerTestCase categoriesFor: #getClipboardContents!private!support! !
!JadeiteDebuggerTestCase categoriesFor: #getDebugger!private!support! !
!JadeiteDebuggerTestCase categoriesFor: #getSecondDebugger!private!support! !
!JadeiteDebuggerTestCase categoriesFor: #keyDownEscapeIn:!private!tests! !
!JadeiteDebuggerTestCase categoriesFor: #menuItemIsEnabled:!private!support! !
!JadeiteDebuggerTestCase categoriesFor: #methodListBrowser!private! !
!JadeiteDebuggerTestCase categoriesFor: #openDebuggerOn:!private! !
!JadeiteDebuggerTestCase categoriesFor: #pressButtonIn:!private!tests! !
!JadeiteDebuggerTestCase categoriesFor: #removeMethodNamed:!private!test ad hoc execution! !
!JadeiteDebuggerTestCase categoriesFor: #saveMethodWithHalt!private! !
!JadeiteDebuggerTestCase categoriesFor: #selectFrameAt:!private!support! !
!JadeiteDebuggerTestCase categoriesFor: #setBreakAt:!private!support!tests! !
!JadeiteDebuggerTestCase categoriesFor: #setUp!private!setup teardown! !
!JadeiteDebuggerTestCase categoriesFor: #statusBarValue!private!support! !
!JadeiteDebuggerTestCase categoriesFor: #systemBrowser!private! !
!JadeiteDebuggerTestCase categoriesFor: #tearDown!private!setup teardown! !
!JadeiteDebuggerTestCase categoriesFor: #terminateGsProcess!private!running! !
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
!JadeiteDebuggerTestCase categoriesFor: #test_breakpointHighlightingInBlocks!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_browseClass!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_browseClassVariablePane!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_browseFrameMethod!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_bug74!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_compileError!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_compileInExecutedBlock!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_compileInExecutedBlockFailsWhenNoHomeMethod!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_compileInExecutedBlockSameSelectorOnStack!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_contextMenu!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_debugCodeWithLeadingLineReturns!public! !
!JadeiteDebuggerTestCase categoriesFor: #test_debugCodeWithLeadingLineReturnsLF!public! !
!JadeiteDebuggerTestCase categoriesFor: #test_debugCodeWithLeadingTab!public! !
!JadeiteDebuggerTestCase categoriesFor: #test_debuggerModifiedSourcePaneChangeFrame!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_debuggerModifiedSourcePaneStayOnFrame!public!tests! !
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
!JadeiteDebuggerTestCase categoriesFor: #test_loginButtonEnablementAfterDebug!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_reformatIllegalSource!public!test source! !
!JadeiteDebuggerTestCase categoriesFor: #test_reformatSource!public!test source! !
!JadeiteDebuggerTestCase categoriesFor: #test_reformatSourceIsUndoable!public!test source! !
!JadeiteDebuggerTestCase categoriesFor: #test_registeredPresentersInProjectBrowserCleanedUp!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_reloadWithDebuggerOpen!public!tests! !
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
!JadeiteDebuggerTestCase categoriesFor: #test_switchProcesses!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_terminateDoesNotWalkback!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_unicodeMethod!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_unsavedChangesActionChangeFrame!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_unsavedChangesActionChangeToHomeFrame!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_unsavedChangesActionStepping!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test1!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test2!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test3!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test4!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test5!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test6!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test7!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test8!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #testBug77!public! !

