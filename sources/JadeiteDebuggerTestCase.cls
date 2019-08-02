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

closeDebuggers
	| list semaphore |
	list := JadeiteMethodListBrowser allInstances , RowanSystemBrowser allInstances
				, RowanDebugger allInstances.
	JadeiteBrowser allInstances.
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
				, RowanDebugger allInstances.
	self assert: list isEmpty!

debuggerDo: aBlock

	self assert: RowanDebugger semaphore isNil.
	RowanDebugger semaphore: Semaphore new.
	aBlock value.
	RowanDebugger semaphore wait.
	RowanDebugger semaphore: nil.
!

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
			[debugger := RowanDebugger allInstances detect: [:each | true] ifNone: [nil].
			(debugger notNil and: 
					[debugger documentPresenter view selection notEmpty and: 
							[debugger gciSession notNil
								and: [debugger methodSourcePresenter gciSession notNil and: [debugger basicSelectedFrame notNil]]]])
				ifTrue: [^self].
			(Delay forMilliseconds: 10) wait]!

getSecondDebugger
	"Private - we opened up one debugger in the test, then another. find the second"

	100 timesRepeat: 
			[secondDebugger := RowanDebugger allInstances detect: [:each | true] ifNone: [nil].
			(secondDebugger notNil and: 
					[secondDebugger gsProcess notNil
						and: [secondDebugger documentPresenter view selection notEmpty and: [secondDebugger ~~ debugger]]])
				ifTrue: [^self].
			(Delay forMilliseconds: 10) wait]!

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
		assert: RowanDebugger allInstances isEmpty;
		debuggerDo: [process := [session executeString: aString] forkAt: Processor activePriority + 1];		
		getDebugger;
		yourself.
!

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

	| list1 list2 |
	super setUp.
	self closeDebuggers.
	RowanDebugger debuggerClass: RowanDebugger.
	self assertIsNil: RowanDebugger semaphore.
	list1 := JadeiteBrowser allInstances.
	list2 := RowanMethodListBrowser allInstances.
	self 
		assert: session notNil;
		assert: list1 isEmpty;
		assert: list2 isEmpty;
		yourself.
!

statusBarValue
	^(debugger view viewNamed: 'statusBarField') value!

systemBrowser

	^JadeiteBrowser allInstances detect: [:each | true] ifNone: [nil]
!

tearDown
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
	RowanDebugger debuggerClass: nil.
	RowanDebugger semaphore: nil.
	super tearDown!

terminateGsProcess

	| string |
	gsProcess ifNil: [^self].
	string := '
| gsProcess |
gsProcess := Object _objectForOop: ' ,gsProcess printString , '.
gsProcess ifNotNil: [gsProcess terminate. (Delay forMilliseconds: 10) wait].
Processor allProcesses includes: gsProcess'.
	gsProcess := nil.
	5 timesRepeat: [
		(debugger gciSession executeString: string) ifFalse: [^self].
	].
	self assert: false.
!

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

test_adHocExecutionSelf
	self openDebuggerOn: '''gloop'' halt'.
	debugger frameListPresenter selectionByIndex: 3.
	debugger methodSourcePresenter documentPresenter value: 'self'.
	debugger methodSourcePresenter documentPresenter view setFocus.
	self debuggerDo: [debugger jadeDisplay].
	self assert: debugger methodSourcePresenter documentPresenter value equals: 'self ''gloop'''.
	debugger methodSourcePresenter documentPresenter view isModified: false!

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

test_browseClass
	| browser |
	self testsIssue: #issue169 withTitle: 'Debugger menu option Browse Class broken'.
	projectsBrowser
		ifNil: [projectsBrowser := self openWindow: [transcript openJadeiteProjectsBrowser]].
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

test_compileClassRecompileMethodsCompileError
	self testsIssue: #issue390 withTitle: 'Rename instance variable with accessor method is... wonky'.
	projectsBrowser
		ifNil: [projectsBrowser := self openWindow: [transcript openJadeiteProjectsBrowser]].
	self selectRowanSample1Class.
	self projectsPresenter classDefinitionPresenter
		value: 'Object rwSubclass: ''TestClass''
	instVarNames: #( abc )
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''RowanSample1-Core''
	options: #()'.
	self projectsPresenter editSaveClass.
	self
		saveMethod: 'abc ^abc'
		in: 'TestClass'
		category: 'accessing'.
	"recompile class without needed inst var. Expect debugger."
	self debuggerDo: 
			[process := 
					[self projectsPresenter classDefinitionPresenter
						value: 'Object rwSubclass: ''TestClass''
	instVarNames: #( )
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''RowanSample1-Core''
	options: #()'.
					self projectsPresenter editSaveClass]
							forkAt: Processor activePriority + 1].
	self getDebugger.
	debugger variableListPresenter list first value
		equals: 'a CompileError occurred (error 1001), compilation errors -- parameter 1 is error descriptor'.
	[] ensure: 
			[self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass.
			self projectsPresenter classDefinitionPresenter view isModified: false.
			self destroy: projectsBrowser]!

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

test_duplicateInstVars
	self testsIssue: #issue228
		withTitle: 'lose selected class in project browser when new version created'.
	projectsBrowser
		ifNil: [projectsBrowser := self openWindow: [transcript openJadeiteProjectsBrowser]].
	
	[self selectServicesNamed: (Array with: 'RowanSample1') in: self projectListPresenter.
	self selectServicesNamed: #('RowanSample1-Tests') in: self packageListPresenter.
	self saveTestClassWithInstVars: Array new package: 'RowanSample1-Tests'.
	self selectClassTab.
	self selectServiceNamed: 'TestClass' in: self classListPresenter.
	self
		saveClass: 'SubClass'
		superclass: 'TestClass'
		instVars: #('aa')
		package: 'RowanSample1-Tests'.
	self selectServiceNamed: 'SubClass' in: self classListPresenter.
	self debuggerDo: 
			[process := 
					[self
						saveClass: 'TestClass'
						withInstVars: #('aa')
						package: 'RowanSample1-Tests']
							forkAt: Processor activePriority + 1].
	self getDebugger.
	self assert: debugger variableListPresenter list first key value equals: #receiver.
	self assert: debugger variableListPresenter list first className equals: 'ImproperOperation']
			ensure: 
				[self projectsPresenter classDefinitionPresenter view isModified: false.
				self destroy: projectsBrowser]!

test_duplicateInstVarsHierarchy
	self testsIssue: #issue228
		withTitle: 'lose selected class in project browser when new version created'.
	projectsBrowser
		ifNil: [projectsBrowser := self openWindow: [transcript openJadeiteProjectsBrowser]].
	
	[self selectServicesNamed: (Array with: 'RowanSample1') in: self projectListPresenter.
	self selectServicesNamed: #('RowanSample1-Tests') in: self packageListPresenter.
	self selectHierarchyTab.
	self saveTestClassWithInstVars: Array new package: 'RowanSample1-Tests'.
	self selectClassInHierarchyNamed: 'TestClass'.
	self
		saveClass: 'SubClass'
		superclass: 'TestClass'
		instVars: #('aa')
		package: 'RowanSample1-Tests'.
	self debuggerDo: 
			[process := 
					[self
						saveClass: 'TestClass'
						withInstVars: #('aa')
						package: 'RowanSample1-Tests']
							forkAt: Processor activePriority + 1].
	self getDebugger.
	self assert: debugger variableListPresenter list first key value equals: #receiver.
	self assert: debugger variableListPresenter list first className equals: 'ImproperOperation']
			ensure: 
				[self projectsPresenter classDefinitionPresenter view isModified: false.
				self destroy: projectsBrowser]!

test_duplicateInstVarsInHierarchy
	self testsIssue: #issue228
		withTitle: 'lose selected class in project browser when new version created'.
	projectsBrowser
		ifNil: [projectsBrowser := self openWindow: [transcript openJadeiteProjectsBrowser]].
	
	[self selectServicesNamed: (Array with: 'RowanSample1') in: self projectListPresenter.
	self selectServicesNamed: #('RowanSample1-Tests') in: self packageListPresenter.
	self saveTestClassWithInstVars: Array new package: 'RowanSample1-Tests'.
	self selectHierarchyTab.
	self selectServiceNamed: 'TestClass' in: self classListPresenter.
	self
		saveClass: 'SubClass'
		superclass: 'TestClass'
		instVars: #('aa')
		package: 'RowanSample1-Tests'.
	self selectServiceNamed: 'SubClass' in: self classListPresenter.
	self debuggerDo: 
			[process := 
					[self
						saveClass: 'TestClass'
						withInstVars: #('aa')
						package: 'RowanSample1-Tests']
							forkAt: Processor activePriority + 1].
	self getDebugger.
	self assert: debugger variableListPresenter list first key value equals: #receiver.
	self assert: debugger variableListPresenter list first className equals: 'ImproperOperation']
			ensure: 
				[self projectsPresenter classDefinitionPresenter view isModified: false.
				self destroy: projectsBrowser]!

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
	projectsBrowser
		ifNil: [projectsBrowser := self openWindow: [transcript openJadeiteProjectsBrowser]].
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
	projectsBrowser := self openWindow: [transcript openJadeiteProjectsBrowser].
	[self assert: (session
				executeString: '(self at: 1) class = Object'
				fromContext: inspector model
				environment: 0)]
			ensure: [projectsBrowser view close].
	projectsBrowser := self openWindow: [transcript openJadeiteProjectsBrowser].
	
	[self assert: (session
				executeString: '(self at: 1) class = Object'
				fromContext: inspector model
				environment: 0)]
			ensure: [projectsBrowser view close]]
			ensure: [inspector view close]!

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
	projectsBrowser
		ifNil: [projectsBrowser := self openWindow: [transcript openJadeiteProjectsBrowser]].
	
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
	projectsBrowser
		ifNil: [projectsBrowser := self openWindow: [transcript openJadeiteProjectsBrowser]].
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

test_selectAfterDiveNoStepPoint
	self testsIssue: #issue166
		withTitle: 'Debugger step with unsaved edits results in empty source pane'.
	projectsBrowser
		ifNil: [projectsBrowser := self openWindow: [transcript openJadeiteProjectsBrowser]].
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
	projectsBrowser
		ifNil: [projectsBrowser := self openWindow: [transcript openJadeiteProjectsBrowser]].
	
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
	projectsBrowser
		ifNil: [projectsBrowser := self openWindow: [transcript openJadeiteProjectsBrowser]].
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

test_switchProcesses
	gsProcess := session executeString: '[(Delay forSeconds: 9999) wait] fork asOop.'.
	session executeString: '(Delay forSeconds: 1) wait'.	"let forked process start"
	self
		openDebuggerOn: 'nil halt';
		assert: debugger _processList size equals: 2;
		assert: debugger processListPresenter list size equals: 2.
	self debuggerDo: [debugger processListPresenter selectionByIndex: 2].
	self debuggerDo: [self selectFrameAt: 6].
	self
		assert: debugger methodSourcePresenter documentPresenter value
			equals: '[(Delay forSeconds: 9999) wait] fork asOop.';
		assert: (debugger _processList at: 2) oopType value equals: gsProcess!

test_terminateDoesNotWalkback
	"Terminate a process other than the primary one"

	| terminateProcess |
	self testsIssue: #issue82 withTitle: 'Pressing Terminate button gives walkback'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[gsProcess := session executeString: '[(Delay forSeconds: 9999) wait] fork asOop'.
	self
		openDebuggerOn: 'nil halt';
		assert: debugger _processList size equals: 2;
		assert: debugger processListPresenter list size equals: 2;
		assert: (debugger processListPresenter selectionByIndex: 2) notNil;
		assert: (debugger _processList at: 2) oopType value equals: gsProcess.
	TestMessageBox plannedResult: #yes.	"confirm we want to terminate process"
	terminateProcess := 
			[self assert: debugger terminateProcess notNil.
			self
				assert: debugger _processList size = 1 description: '_processList size was not 1';
				assert: debugger processListPresenter list size = 1
					description: 'processListPresenter list size was not 1']
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

	| browser |
	self
		openDebuggerOn: '| x | 
nil halt.
x := 1 -> 2.
x yourself';
		debuggerDo: [debugger stepOver];
		assert: debugger documentPresenter view selection equals: '->';
		debuggerDo: [debugger stepInto];
		debuggerDo: [debugger browseFrameMethod];
		assert: (browser := self systemBrowser) notNil.
	
	[self
		assert: (browser currentCard selectedClasses collect: [:classService | classService name])
			equals: #('Object');
		assert: browser currentCard methodListPresenter selection name equals: '->';
		debuggerDo: [debugger resumeProcess]]
			ensure: [browser view close]!

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
		debuggerDo: [debugger browseObjectClass];
		assert: (browser := self systemBrowser) notNil.
	
	[self
		assert: (browser currentCard classListPresenter selections
					collect: [:classService | classService name])
			equals: #('Association');
		debuggerDo: [debugger resumeProcess]]
			ensure: [browser view close]!

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
		assert: RowanDebugger allInstances isEmpty;
		debuggerDo: [process := [session debugString: '#(abc def) do:[:symbol | symbol size]' fromContext: nil environment: 0] fork];
		getDebugger;
		yourself.
	self debuggerDo: [debugger resumeProcess].
!

testBug74
	"Open debugger on method with breakpoint"

	session executeString: '(Repository compiledMethodAt: #pageSize) setBreakAtStepPoint: 2'.
	self 
		openDebuggerOn: 'SystemRepository pageSize';
		assert: debugger documentPresenter view selection equals: 'zeroArgPrim:50';
		debuggerDo: [debugger resumeProcess];
		yourself.
!

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
!

testContextMenu
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
			whileTrue: 
				[view
					postMessage: 16r100
						wParam: 27
						lParam: 0;
					postMessage: 16r101
						wParam: 27
						lParam: 0;
					yourself	"WM_KEYDOWN"	"VK_ESCAPE"	"WM_KEYUP"	"VK_ESCAPE"].
	Transcript show: '
testContextMenu - counter = ' , counter printString]
			fork.
	view
		postMessage: 16r204
			wParam: 0
			lParam: 16r12C0064;
		postMessage: 16r205
			wParam: 0
			lParam: 16r12C0064;
		yourself.	"WM_RBUTTONDOWN"	" (300 @ 100) "	"WM_RBUTTONUP"
	time := Time millisecondClockValue + 2000.
	
	[SessionManager current inputState
		loopWhile: [ShortcutMenuStatus isClosed not and: [Time millisecondClockValue < time]]]
			on: Error
			do: 
				[:ex |
				error := ex.
				ex return].
	self
		assert: error isNil;
		debuggerDo: [debugger resumeProcess];
		yourself!

testErrorInPrintString
	"https://github.com/ericwinger/Jade/issues/49"

	self 
		openDebuggerOn: '(ScaledDecimal _basicNew instVarAt: 1 put: 1; instVarAt: 2 put: nil; printString)';
		assert: debugger errorMessagePresenter value equals: 'a MessageNotUnderstood occurred (error 2010), a UndefinedObject does not understand  #''_generality''';
		assert: (debugger frameListPresenter selection) equals: 'SmallInteger (Number) >> _retry:coercing: @4 line 15';
		assert: (debugger frameListPresenter selectionByIndex: 6) notNil.	debugger frameListPresenter selectionByIndex: 8. "select ScaledDecimal frame"
	self
		assert: debugger variableListPresenter list first value equals: '(ScaledDecimal printString error: a MessageNotUnderstood occurred (error 2010), a UndefinedObject does not understand  #''_generality'')';
		debuggerDo: [[debugger _terminateProcess] fork];
		assert: (Delay forMilliseconds: 50) wait notNil;
		assert: (debugger isNil or: [debugger view class == DeafObject]);
		yourself.
!

testSaveMethod
	"https://github.com/GemTalk/Jadeite/issues/62"

	| number view |
	projectsBrowser
		ifNil: [projectsBrowser := self openWindow: [transcript openJadeiteProjectsBrowser]].
	
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

testStackMenuEnablement
	| frameContextMenu |
	self testsIssue: #issue103 withTitle: 'debugger, ''Executed Code'' stack frame, pop up menu items'.
	self openDebuggerOn: 'nil halt'.
	self assert: debugger _processList size equals: 1.
	self assert: debugger frameListPresenter selection equals: 'Executed Code  @2 line 1'.
	frameContextMenu := debugger frameListPresenter view contextMenu.
	frameContextMenu itemsDo: [:item | self deny: (self menuItemIsEnabled: item)].
	debugger frameListPresenter selection: (debugger frameListPresenter list at: 2).
	frameContextMenu itemsDo: [:item | self assert: (self menuItemIsEnabled: item)].
!

testUnsavedChangesActionChangeFrame

	self testsIssue: #issue176 withTitle: 'unsaved debugger frame method not handled well'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[self openDebuggerOn: 'nil halt'.
	self assert: debugger frameListPresenter selection equals: 'Executed Code  @2 line 1'.
	self assert: debugger frameListPresenter selectionByIndex equals: 4. 
	debugger methodSourcePresenter documentPresenter value: 'new text'.
	debugger methodSourcePresenter documentPresenter view isModified: true.
	TestMessageBox plannedResult: #no. "ignore changes"
	self debuggerDo: [[debugger stepOver] forkAt: Processor activePriority + 1].
	(Delay forMilliseconds: 50) wait. 
	self assert: debugger frameListPresenter selectionByIndex equals: 1. ]
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

testUnsavedChangesActionChangeToHomeFrame

	self testsIssue: #issue176 withTitle: 'unsaved debugger frame method not handled well'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[| originalSource |
	originalSource := '(Array with: 1) do:[:obj | self halt. obj size]'.
	self openDebuggerOn: originalSource.
	self assert: debugger frameListPresenter selection equals: '[] in  Executed Code  @2 line 1'.
	debugger methodSourcePresenter documentPresenter value: 'new text'.
	debugger methodSourcePresenter documentPresenter view isModified: true.
	TestMessageBox plannedResult: #no.	
	debugger frameListPresenter selectionByIndex: 6. "Executed Code home frame"
	self assert: debugger methodSourcePresenter documentPresenter value equals: originalSource]
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

testUnsavedChangesActionStepping

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
	self assert: debugger methodSourcePresenter documentPresenter value equals:  'step into']
			ensure: [TestMessageBox disableJadeiteTestMessageBox]! !
!JadeiteDebuggerTestCase categoriesFor: #closeDebuggers!private!support! !
!JadeiteDebuggerTestCase categoriesFor: #debuggerDo:!private!support! !
!JadeiteDebuggerTestCase categoriesFor: #getClipboardContents!private!support! !
!JadeiteDebuggerTestCase categoriesFor: #getDebugger!private!support! !
!JadeiteDebuggerTestCase categoriesFor: #getSecondDebugger!private!support! !
!JadeiteDebuggerTestCase categoriesFor: #menuItemIsEnabled:!private!support! !
!JadeiteDebuggerTestCase categoriesFor: #methodListBrowser!private! !
!JadeiteDebuggerTestCase categoriesFor: #openDebuggerOn:!private! !
!JadeiteDebuggerTestCase categoriesFor: #saveMethodWithHalt!private! !
!JadeiteDebuggerTestCase categoriesFor: #selectFrameAt:!private!support! !
!JadeiteDebuggerTestCase categoriesFor: #setUp!private!setup teardown! !
!JadeiteDebuggerTestCase categoriesFor: #statusBarValue!private!support! !
!JadeiteDebuggerTestCase categoriesFor: #systemBrowser!private! !
!JadeiteDebuggerTestCase categoriesFor: #tearDown!private!setup teardown! !
!JadeiteDebuggerTestCase categoriesFor: #terminateGsProcess!private!running! !
!JadeiteDebuggerTestCase categoriesFor: #test_adHocDebug!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_adHocExecutionSelf!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_badCompileInDebugger!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_browseClass!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_browseClassVariablePane!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_browseFrameMethod!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_compileClassRecompileMethodsCompileError!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_debuggerModifiedSourcePaneChangeFrame!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_debuggerModifiedSourcePaneStayOnFrame!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_duplicateInstVars!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_duplicateInstVarsHierarchy!public!test class hierarchy! !
!JadeiteDebuggerTestCase categoriesFor: #test_duplicateInstVarsInHierarchy!public!test class hierarchy! !
!JadeiteDebuggerTestCase categoriesFor: #test_frameDoubleClick!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_frameDoubleClickNoActionInBlockContext!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_implementersFromDebugger!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_implementorsSendersCaption!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_inspectedDebuggerObjectHeld!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_registeredPresentersInProjectBrowserCleanedUp!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_reloadWithDebuggerOpen!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_restartInBlock!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_selectAfterDiveNoStepPoint!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_selectBlockContext!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_sendersFromDebugger!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_stackDumpDetailedFrame!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_stackDumpHeader!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_stackDumpTooLongString!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_switchProcesses!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_terminateDoesNotWalkback!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test_unicodeMethod!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test1!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test2!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test3!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test4!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test5!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test6!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test7!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #test8!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #testBug74!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #testBug77!public! !
!JadeiteDebuggerTestCase categoriesFor: #testContextMenu!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #testErrorInPrintString!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #testSaveMethod!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #testStackMenuEnablement!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #testUnsavedChangesActionChangeFrame!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #testUnsavedChangesActionChangeToHomeFrame!public!tests! !
!JadeiteDebuggerTestCase categoriesFor: #testUnsavedChangesActionStepping!public!tests! !

