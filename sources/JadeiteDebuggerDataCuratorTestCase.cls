"Filed out from Dolphin Smalltalk 7"!

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

setUp
	user ifNil: [user := 'DataCurator']. "SystemUser will already be set in the subclass if not running as DataCurator" 
	super setUp!

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
	TestMessageBox disableJadeiteTestMessageBox.	"in case the test has gotten stuck while enabled"
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

test_browseMenuOptionEnablement
	"Don't enable Browse methods if the class is not resolvable"

	| contextMenu browseMenuItems |
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
	debugger frameListPresenter selectionByIndex: 6.	"RowanAnsweringService frame"
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
	self assert: debugger browseFrameMethod isKindOf: JadeiteDebugger	"returned without opening browser"! !
!JadeiteDebuggerDataCuratorTestCase categoriesFor: #cleanupProcesses!private!support! !
!JadeiteDebuggerDataCuratorTestCase categoriesFor: #closeDebuggers!private!support! !
!JadeiteDebuggerDataCuratorTestCase categoriesFor: #closeJadeiteLoginShells!private!support! !
!JadeiteDebuggerDataCuratorTestCase categoriesFor: #createTestMethodWithBreakpoints!private!support!tests! !
!JadeiteDebuggerDataCuratorTestCase categoriesFor: #debuggerDo:!private!support! !
!JadeiteDebuggerDataCuratorTestCase categoriesFor: #getClipboardContents!private!support! !
!JadeiteDebuggerDataCuratorTestCase categoriesFor: #getDebugger!private!support! !
!JadeiteDebuggerDataCuratorTestCase categoriesFor: #getSecondDebugger!private!support! !
!JadeiteDebuggerDataCuratorTestCase categoriesFor: #keyDownEscapeIn:!private!support!tests! !
!JadeiteDebuggerDataCuratorTestCase categoriesFor: #menuItemIsEnabled:!private!support! !
!JadeiteDebuggerDataCuratorTestCase categoriesFor: #methodListBrowser!private!support! !
!JadeiteDebuggerDataCuratorTestCase categoriesFor: #openDebuggerOn:!private!support! !
!JadeiteDebuggerDataCuratorTestCase categoriesFor: #pressButtonIn:!private!support!tests! !
!JadeiteDebuggerDataCuratorTestCase categoriesFor: #removeMethodNamed:!private!support!test ad hoc execution! !
!JadeiteDebuggerDataCuratorTestCase categoriesFor: #saveMethodWithHalt!private!support! !
!JadeiteDebuggerDataCuratorTestCase categoriesFor: #selectFrameAt:!private!support! !
!JadeiteDebuggerDataCuratorTestCase categoriesFor: #setUp!private!setup teardown!support! !
!JadeiteDebuggerDataCuratorTestCase categoriesFor: #statusBarValue!private!support! !
!JadeiteDebuggerDataCuratorTestCase categoriesFor: #systemBrowser!private!support! !
!JadeiteDebuggerDataCuratorTestCase categoriesFor: #tearDown!private!setup teardown!support! !
!JadeiteDebuggerDataCuratorTestCase categoriesFor: #terminateGsProcess!private!running!support! !
!JadeiteDebuggerDataCuratorTestCase categoriesFor: #test_browseMenuOptionEnablement!public!tests! !
!JadeiteDebuggerDataCuratorTestCase categoriesFor: #test_doubleClickWhenClassNotResolvable!public!tests! !

