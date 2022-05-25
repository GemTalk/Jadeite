"Filed out from Dolphin Smallalk"!

JadeiteAbstractTestCase subclass: #JadeiteDebuggerDataCuratorTestCase
	instanceVariableNames: 'debugger gsProcess process secondDebugger'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteDebuggerDataCuratorTestCase guid: (GUID fromString: '{9e566a6d-d1f3-4c93-81b2-ad35ed7a6999}')!
JadeiteDebuggerDataCuratorTestCase comment: ''!
!JadeiteDebuggerDataCuratorTestCase categoriesForClass!Unclassified! !
!JadeiteDebuggerDataCuratorTestCase methodsFor!

cleanupProcesses
	debugger
		ifNotNil: 
			[debugger debuggerService processes do: 
					[:processService |
					session executeString: '[(Object _objectForOop: ' , processService oop printString
								, ') terminate] on: Error do:[:ex | "ignore"]']]!

closeDebuggers
	| list semaphore |
	list := JadeiteMethodListBrowser allInstances , JadeiteBrowser allInstances
				, JadeiteDebugger allInstances.
	semaphore := Semaphore new.
	list do: 
			[:each |
			session removeEventsTriggeredFor: each.
			
			[
			[each view destroy.
			semaphore signal.
			SessionManager inputState prod] on: ProcessTermination
					do: 
						[:ex |
						"A debugger wants to terminate the current process!!!!"
						
						[semaphore signal.
						SessionManager inputState prod] forkAt: Processor userBackgroundPriority.
						ex pass]]
					fork.
			semaphore wait.
			debugger == each ifTrue: [debugger := nil]].
	list := nil.
	MemoryManager current collectGarbage.
	(Delay forMilliseconds: 300) wait.
	JadeiteMethodListBrowser allInstances
		do: [:browser | self assert: (browser view isKindOf: DeafObject)].
	JadeiteBrowser allInstances do: [:browser | self assert: (browser view isKindOf: DeafObject)].
	JadeiteDebugger allInstances
		do: [:theDebugger | self assert: (theDebugger view isKindOf: DeafObject)].
	MemoryManager current collectGarbage.
	(Delay forMilliseconds: 250) wait.
	self purgeInstances: JadeiteBrowser.
	self purgeInstances: JadeiteMethodListBrowser.
	self purgeInstances: JadeiteDebugger.
	self assert: JadeiteDebugger allInstances isEmpty.
	self assert: JadeiteMethodListBrowser allInstances isEmpty.
	self assert: JadeiteBrowser allInstances isEmpty!

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
	self setBreakAt: 22. "first add:"
	self setBreakAt: 25.
	self setBreakAt: 28!

debuggerDo: aBlock
	self assert: JadeiteDebugger semaphore isNil.
	JadeiteDebugger semaphore: Semaphore new.
	[aBlock value] ensure: 
			[SessionManager inputState processDeferredActions.
			JadeiteDebugger semaphore wait.
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
			[debugger := JadeiteDebugger allInstances detect: [:each | (each view isKindOf: DeafObject) not]
						ifNone: [nil].
			(debugger notNil and: 
					[debugger documentPresenter view selection notEmpty and: 
							[debugger gciSession notNil
								and: [debugger methodSourcePresenter gciSession notNil and: [debugger basicSelectedFrame notNil]]]])
				ifTrue: [^self].
			(Delay forMilliseconds: 10) wait]!

getSecondDebugger
	"Private - we opened up one debugger in the test, then another. find the second"

	100 timesRepeat: 
			[secondDebugger := JadeiteDebugger allInstances detect: [:aDebugger | aDebugger ~~ debugger]
						ifNone: [].
			secondDebugger notNil and: 
					[secondDebugger gsProcess notNil
						and: [secondDebugger documentPresenter view selection notEmpty ifTrue: [^true]]].
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
	JadeiteDebugger allInstances
		do: [:theDebugger | self assert: (theDebugger view isKindOf: DeafObject)].
	self
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

primaryTestWindow
	"Every test should have a primary window it is testing. 
	If not, just return nil"

	^debugger!

purgeInstances: aClass
	| count |
	count := 0.
	aClass allInstances isEmpty
		ifFalse: 
			[[count < 50] whileTrue: 
					[count := count + 1.
					MemoryManager current collectGarbage.
					SessionManager inputState pumpMessages.
					(Delay forMilliseconds: 50) wait.
					aClass allInstances isEmpty ifTrue: [^self]]].
	aClass allInstances do: [:each | each become: Object new].
	^count!

removeMethodNamed: aSymbol
	| classService methodService |
	methodService := RowanMethodService new
				selector: aSymbol;
				className: 'RowanSample1Test';
				meta: false.
	classService := RowanClassService named: 'RowanSample1Test'.
	classService updateForSession: session. 
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

selectFrameMatching: wildCardString
	"foolishly, the selection changing event which needs testing
	is only sent through a button click in Dolphin. We need to 
	fake it out for the test. frustrating.

	Note - even though we are faking up the event, the event itself
	should get modified based on the debugger's state which is a
	valid test."

	| event selectedFrame |
	selectedFrame := debugger frameListPresenter list detect: [:frame | wildCardString match: frame].
	event := (SelectionChangingEvent forSource: self)
				oldSelections: debugger frameListPresenter selections;
				newSelections: (Array with: selectedFrame);
				cause: #test;
				yourself.
	debugger frameListPresenter onSelectionChanging: event.
	event value ifFalse: [^self].
	debugger frameListPresenter selection: selectedFrame!

setUp
	user ifNil: [user := 'DataCurator']. "SystemUser will already be set in the subclass if not running as DataCurator" 
	super setUp!

statusBarValue
	^(debugger view viewNamed: 'statusBarField') value!

systemBrowser

	^JadeiteBrowser allInstances detect: [:each | true] ifNone: [nil]
!

tearDown
	self assert: (session isKindOf: GciSession).
	self cleanupProcesses.
	JadeSessionManager
		dump: 'self cleanupProcesses'
		toFileNamed: 'test6tracing.log'
		andStop: false.
	self assert: (session isKindOf: GciSession).
	projectsBrowser
		ifNotNil: 
			[projectsBrowser view close.
			projectsBrowser := nil].
	JadeSessionManager
		dump: 'projectsBrowser view close.
			projectsBrowser := nil'
		toFileNamed: 'test6tracing.log'
		andStop: false.
	debugger ifNotNil: [debugger documentPresenter view isModified: false].
	self assert: (session isKindOf: GciSession).
	secondDebugger ifNotNil: [secondDebugger documentPresenter view isModified: false].
	self assert: (session isKindOf: GciSession).
	process
		ifNotNil: 
			[process terminate.
			process := nil].
	JadeSessionManager
		dump: 'process terminate.
			process := nil'
		toFileNamed: 'test6tracing.log'
		andStop: false.
	self terminateGsProcess.
	JadeSessionManager
		dump: 'terminateGsProcess'
		toFileNamed: 'test6tracing.log'
		andStop: false.
	self assert: (session isKindOf: GciSession).
	self closeDebuggers.
	JadeSessionManager
		dump: 'closeDebuggers'
		toFileNamed: 'test6tracing.log'
		andStop: false.
	JadeiteDebugger debuggerClass: nil.
	JadeiteDebugger semaphore: nil.
	TestMessageBox disableJadeiteTestMessageBox.	"in case the test has gotten stuck while enabled"
	self assert: (session isKindOf: GciSession).
	super tearDown.
	JadeSessionManager
		dump: 'super tearDown'
		toFileNamed: 'test6tracing.log'
		andStop: false.
	JadeSessionManager
		dump: '#tearDown complete - dumping processes'
		toFileNamed: 'test6tracing.log'
		andStop: false.
	Process allInstances do: 
			[:theProcess |
			theProcess isTerminated
				ifFalse: 
					[JadeSessionManager
						dump: 'process: ' , theProcess displayString
							toFileNamed: 'test6tracing.log'
							andStop: false;
						dump: (theProcess stackTrace: 100000)
							toFileNamed: 'test6tracing.log'
							andStop: false]]!

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

test_browseMenuOptionEnablement
	"Don't enable Browse methods if the class is not resolvable"

	| contextMenu browseMenuItems frame |
	self testsIssue: #issue774
		withTitle: 'Disable Browse* debugger frame list menu options if method not visible'.
	session userID = 'DataCurator' ifFalse: [^self].	"will fail unless run as DataCurator"
	self
		openDebuggerOn: '((Rowan platform serviceClassFor: ''RowanAnsweringService'') new) exec: ''self halt'''.
	debugger frameListPresenter selectionByIndex: 1.	"halt frame"
	contextMenu := debugger frameListPresenter view contextMenu.
	browseMenuItems := contextMenu items
				select: [:theItem | theItem isDivider not and: ['*Browse*' match: theItem description]].
	browseMenuItems do: 
			[:theItem |
			| query |
			query := CommandQuery commandDescription: theItem commandDescription
						source: debugger frameListPresenter view.
			debugger queryCommand: query.
			self assert: query isEnabled].
	frame := debugger frameListPresenter list
				detect: [:frameString | '*RowanAnsweringService*' match: frameString]
				ifNone: [].
	debugger frameListPresenter selectionByIndex: (debugger frameListPresenter list indexOf: frame).
	browseMenuItems do: 
			[:theItem |
			| query |
			query := CommandQuery commandDescription: theItem commandDescription
						source: debugger frameListPresenter view.
			debugger queryCommand: query.
			self deny: query isEnabled]!

test_doubleClickWhenClassNotResolvable
	"Don't enable Browse methods if the class is not resolvable"

	self testsIssue: #issue774
		withTitle: 'Disable Browse* debugger frame list menu options if method not visible'.
	session userID = 'DataCurator' ifFalse: [^self].	"will fail unless run as DataCurator"
	self
		openDebuggerOn: '((Rowan platform serviceClassFor: ''RowanAnsweringService'') new) exec: ''self halt'''.
	debugger frameListPresenter selectionByIndex: debugger frameListPresenter list size - 2.	"Exec block frame"
	self assert: ('RowanAnsweringService >>*' match: debugger frameListPresenter selection).
	self assert: debugger browseFrameMethod isKindOf: JadeiteDebugger	"returned without opening browser"!

test_globalAdditionalAccelerators
	self openDebuggerOn: 'self halt'.
	self assert: (self primaryTestWindow additionalAccelerators includes: #(#raiseConsole 'Ctrl+F7'))! !
!JadeiteDebuggerDataCuratorTestCase categoriesForMethods!
cleanupProcesses!private!support! !
closeDebuggers!private!support! !
closeJadeiteLoginShells!private!support! !
createTestMethodWithBreakpoints!private!support!tests! !
debuggerDo:!private!support! !
getClipboardContents!private!support! !
getDebugger!private!support! !
getSecondDebugger!private!support! !
keyDownEscapeIn:!private!support!tests! !
menuItemIsEnabled:!private!support! !
methodListBrowser!private!support! !
openDebuggerOn:!private!support! !
pressButtonIn:!private!support!tests! !
primaryTestWindow!accessing!public! !
purgeInstances:!private!support! !
removeMethodNamed:!private!support!test ad hoc execution! !
saveMethodWithHalt!private!support! !
selectFrameAt:!private!support! !
selectFrameMatching:!private!support! !
setUp!private!setup teardown!support! !
statusBarValue!private!support! !
systemBrowser!private!support! !
tearDown!private!setup teardown!support! !
terminateGsProcess!private!running!support! !
test_browseMenuOptionEnablement!public!tests! !
test_doubleClickWhenClassNotResolvable!public!tests! !
test_globalAdditionalAccelerators!public!tests! !
!

