"Filed out from Dolphin Smalltalk 7"!

JadeTextDocument subclass: #JadeDebugger
	instanceVariableNames: 'answer errorMessagePresenter frame frameListOffset frameListPresenter gsProcess processList processListPresenter terminateOnClose variableDataPresenter variableListPresenter'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: 'debuggers'!
JadeDebugger guid: (GUID fromString: '{54a4ddbf-2101-4884-8568-46d6d2790987}')!
JadeDebugger comment: ''!
!JadeDebugger categoriesForClass!Unclassified! !
!JadeDebugger methodsFor!

_terminateProcess

	| cachedGsProcess |
	cachedGsProcess := gsProcess.
	self clearUI.
	(processList size == 1 or: [gsProcess oopType = processList first oopType]) ifTrue: [self view close. ^self].
	processList copy do: [:each | each oopType = gsProcess oopType ifTrue: [processList remove: each]].
	processListPresenter list: processList.
	[
		self _terminateProcess: cachedGsProcess.
	] on: TerminateProcess do: [:ex | 
		ex return: nil.
	].
	gsProcess := processList first.
	self update.!

_terminateProcess: aGsProcess
	aGsProcess terminate.
!

activeTextEdit
	| focus theView |
	focus := View focus.
	focus name = 'document'
		ifTrue: [theView := focus]
		ifFalse: [theView := self view viewNamed: 'variableData'].
	^theView!

answer
		"It is likely that the debugger was opened by some UI command that changed the cursor to a wait cursor.
		Because we are starting a new main UI process, and because our process can be terminated, we can be
		left in a state in which the cursor is not set back to its original value.
		We mitigate that problem by changing it to the default."

	Cursor current: nil.
	SessionManager inputState loopWhile: [answer isNil].
	^answer.
!

clearUI

	frameListPresenter list: #().
	frameListOffset := 0.
	variableListPresenter list: #().
	variableDataPresenter value: ''.
	documentPresenter value: ''.
!

codeSourcePresenterClass

	^MethodSourcePresenter
!

contextObject
	^frame oop!

copyStack
	| stream |
	Cursor wait showWhile: 
			[stream := WriteStream on: String new.
			self class
				dumpStackFor: gsProcess
				errorMessage: errorMessagePresenter value
				on: stream.
			stream contents copyToClipboard]!

createComponents

	super createComponents.
	errorMessagePresenter	:= self add: TextPresenter		new name: 'errorMessage'.
	frameListPresenter 		:= self add: ListPresenter		new name: 'frameList'.
	frameListOffset		:= 0.
	processListPresenter 	:= self add: ListPresenter		new name: 'processList'.
	variableDataPresenter 	:= self add: TextPresenter		new name: 'variableData'.
	variableListPresenter		:= self add: ListPresenter		new name: 'variableList'.
!

createSchematicWiring

	super createSchematicWiring.
	frameListPresenter 		when: #selectionChanged 		send: #selectedFrameWithErrorHandling 	to: self.
	frameListPresenter 		when: #'selectionChanging:'	send: #'aboutToChangeFrame:'			to: self.
	processListPresenter 	when: #selectionChanged 		send: #selectedProcess 				to: self.
	variableListPresenter		when: #selectionChanged		send: #selectedVariable				to: self.
	variableListPresenter		when: #actionPerformed		send: #inspectVariable				to: self.
!

getProcessList

	| string lines |
	string := gciSession serverPerform: #'processes'.
	lines := (string subStrings: Character lf) asOrderedCollection.
	processList := lines removeFirst; collect: [:each | 
		| fields oopType oopValue type |
		fields := each subStrings: Character tab.
		oopValue := (fields at: 2) asNumber.
		oopType := gciSession oopTypeWithOop: oopValue.
		type := fields at: 9.	"forked or main (see JadeServer64Bit3x>>#'addProcess:to:withStatus:scheduler:')"
		(GsProcess session: gciSession oopType: oopType)
			type: type;
			yourself
	].
	processList addFirst: gsProcess.
	gsProcess type: 'active'.!

implement

	self halt.
!

inspectVariable
	| object |
	object := gciSession oopTypeWithOop: variableListPresenter selection key key asNumber.
	^JadeInspector showOn: object session: gciSession!

queryCommand: query

	(#(#'resumeProcess' #'runToCursor' #'stepInto' #'stopOut' #'stepOver') includes: query commandSymbol) ifTrue: [
		query isEnabled: (processList notNil and: [processList notEmpty and: [processList first == gsProcess]]).
		^true.
	].
	(#(#'terminateProcess') includes: query commandSymbol) ifTrue: [
		query isEnabled: (processList notNil and: [processList notEmpty and: [processList first ~~ gsProcess]]).
		^true.
	].
	(#(#'implement') includes: query commandSymbol) ifTrue: [
		query isEnabled: false. "frameListPresenter model first subStrings first = 'MessageNotUnderstood'."
		^true.
	].
	^super queryCommand: query.
!

runToCursor

	MessageBox notify: 'Sorry, this feature is not yet implemented!!'.
!

saveMethod

	| result |
	result := gciSession
		serverPerform: #'compile:frame:process:' 
		with: (self getDocumentData reject: [:each | each == Character cr])
		with: frameListPresenter selectionByIndex + frameListOffset
		with: gsProcess.
	(result isKindOf: Boolean) ifTrue: [
		result ifTrue: [
			documentPresenter isModified: false.
			gsProcess trimStackToLevel: frameListPresenter selectionByIndex + frameListOffset.
			^self update.
		] ifFalse: [
			MessageBox notify: 'New method has different selector so will not be on stack!!'.
			^self selectedFrame.
		].
	].
	MessageBox notify: result.
!

selectedFrame
	| index breaks source |
	(index := frameListPresenter selectionByIndex) = 0 ifTrue: [^self].
	index := index + frameListOffset.
	(frame := gsProcess frameForLevel: index) isNil ifTrue: [^self].
	source := frame source.
	breaks := frame breaks collect: [:each | frame offsets at: each].
	breaks := breaks
				collect: [:each | ((source copyFrom: 1 to: each) select: [:char | char = Character lf]) size + 1].
	breaks := breaks asSet asSortedCollection asArray.
	variableListPresenter list: frame vars.
	codePane
		gsMethod: frame gsMethod;
		showStepPoint: frame stepPoint;
		yourself
	"breaks do: [:each | 
		documentPresenter view 
			addMarkerType: #'breakpoint' 
			at: each.
	]."!

selectedVariable

	| data |
	variableDataPresenter value: nil.
	variableListPresenter hasSelection ifFalse: [^self].
	data := variableListPresenter selection value.
	variableDataPresenter value: data.
!

showNextStatement

	self 
		update;
		selectedFrame;
		yourself.

!

stackInitialSelection

	| list |
	list := gsProcess stack.
	self stackInitialSelectionData do: [:each | 
		1 to: list size do: [:i | 
			0 < ((list at: i) indexOfSubCollection: each) ifTrue: [^i + 1].
		].
	].
	^1.
!

stackInitialSelectionData
	"Line number to select if string included on previous line (need not be exact match)"

	^#(
		'(AbstractException) >> _signalAsync @7 line 21'
		'(Object) >> _doesNotUnderstand:args:envId:reason: @7 line 12'
		'(Object) >> _doesNotUnderstand:args:envId:reason: @8 line 13'
		'(Object) >> error: @6 line 7'
		'(Object) >> error: (envId 0) @6 line 7'
		'(Object) >> error: @6 line 7'
		'(Object) >> halt @2 line 5'
		'(Object) >> halt (envId 0) @2 line 5'
		'(Object) >> pause @2 line 7'
		'(Object)>>#_doesNotUnderstand: @1 line 6'
		'(Object)>>#error: @1 line 6'
		'(Object)>>#error: @3 line 7'
		'(Object)>>#halt @1 line 6'
		'(Object)>>#pause @2 line 8'
		'(TestCase)>>#assert: @1 line 1'
		'(TestCase)>>#deny: @2 line 3'
		'(TestCase)>>#should:raise: @10 line 9'
		'(TestCase)>>#shouldnt:raise: @4 line 2'
		'GSTestCase >> assert: @1 line 1'
		'GSTestCase >> assert: (envId 0) @1 line 1'
		'Object >> _doesNotUnderstand:'
		'Object >> _doesNotUnderstand:args:envId:reason: @7 line 12'
		'Object >> _doesNotUnderstand:args:envId:reason: (envId 0) @7 line 12'
		'Object >> _doesNotUnderstand:args:envId:reason: @8 line 13'
		'Object >> error: @6 line 7'
		'Object >> error: (envId 0) @6 line 7'
		'Object >> halt @2 line 5'
		'Object >> halt (envId 0) @2 line 5'
		'(TestAsserter) >> assert: @5 line 4'
		'TestAsserter >> assert: (envId 0) @5 line 4'
	)!

statusBarText: aString
	"called by MethodSourcePresenter"!

stepInto
	
	gsProcess stepInto: frameListPresenter selectionByIndex + frameListOffset.
	^self update!

stepOut

	gsProcess stepOut: frameListPresenter selectionByIndex + frameListOffset + 1.
	^self update!

stepOver

	gsProcess stepOver: frameListPresenter selectionByIndex + frameListOffset.
	^self update!

terminateProcess
	(MessageBox confirm: 'Terminate process?' caption: 'GemStone/S Process Termination')
		ifFalse: [^self].
	self _terminateProcess!

updateSaveMethodOop: anInteger
	"do nothing"
! !
!JadeDebugger categoriesFor: #_terminateProcess!public! !
!JadeDebugger categoriesFor: #_terminateProcess:!public! !
!JadeDebugger categoriesFor: #activeTextEdit!private! !
!JadeDebugger categoriesFor: #answer!public! !
!JadeDebugger categoriesFor: #clearUI!public! !
!JadeDebugger categoriesFor: #codeSourcePresenterClass!private! !
!JadeDebugger categoriesFor: #contextObject!public! !
!JadeDebugger categoriesFor: #copyStack!menu handlers!private! !
!JadeDebugger categoriesFor: #createComponents!public! !
!JadeDebugger categoriesFor: #createSchematicWiring!public! !
!JadeDebugger categoriesFor: #getProcessList!public! !
!JadeDebugger categoriesFor: #implement!public! !
!JadeDebugger categoriesFor: #inspectVariable!menu handlers!private! !
!JadeDebugger categoriesFor: #queryCommand:!public! !
!JadeDebugger categoriesFor: #runToCursor!menu handlers!private! !
!JadeDebugger categoriesFor: #saveMethod!menu handlers!private! !
!JadeDebugger categoriesFor: #selectedFrame!public! !
!JadeDebugger categoriesFor: #selectedVariable!public! !
!JadeDebugger categoriesFor: #showNextStatement!public! !
!JadeDebugger categoriesFor: #stackInitialSelection!public! !
!JadeDebugger categoriesFor: #stackInitialSelectionData!public! !
!JadeDebugger categoriesFor: #statusBarText:!public! !
!JadeDebugger categoriesFor: #stepInto!menu handlers!private! !
!JadeDebugger categoriesFor: #stepOut!menu handlers!private! !
!JadeDebugger categoriesFor: #stepOver!menu handlers!private! !
!JadeDebugger categoriesFor: #terminateProcess!menu handlers!private! !
!JadeDebugger categoriesFor: #updateSaveMethodOop:!public! !

!JadeDebugger class methodsFor!

aboutToShowErrorShellOn: gsError!

debuggerFor: anInteger		"aGsProcess asOop"

	^self debuggers
		at: anInteger
		ifAbsent: [nil].
!

debuggers

	debuggers isNil ifTrue: [debuggers := Dictionary new].
	^debuggers.
!

dumpStackFor: gsProcess errorMessage: errorMessage on: stream
	stream
		nextPutAll: errorMessage;
		cr.
	1 to: gsProcess stack size
		do: 
			[:index |
			self
				printShortFrameAt: index
				process: gsProcess
				on: stream].
	stream
		cr;
		nextPutAll: '==============================================='.
	1 to: gsProcess stack size
		do: 
			[:index |
			| theFrame |
			self
				printShortFrameAt: index
				process: gsProcess
				on: stream.
			(theFrame := gsProcess frameForLevel: index)
				ifNotNil: 
					[| sortedVars sortedInstVars sortedTempsAndParms |
					self printVar: theFrame vars first on: stream.
					sortedVars := (theFrame vars copyFrom: 2 to: theFrame vars size)
								asSortedCollection: [:x :y | x key value <= y key value].
					sortedInstVars := sortedVars select: [:var | var key value first = $-].
					stream
						cr;
						cr;
						nextPutAll: 'instance variables:'.
					self printVariables: sortedInstVars on: stream.
					sortedTempsAndParms := sortedVars reject: [:var | var key value first = $-].
					stream
						cr;
						cr;
						nextPutAll: 'temporary variables and parameters:'.
					self printVariables: sortedTempsAndParms on: stream].
			gsProcess stack size = index
				ifFalse: 
					[stream
						cr;
						nextPutAll: '----------------------------------------------------']]!

maxPrint
	^200!

openDebuggerOnException: gciError 

	^self
		openOn: gciError gsProcess
		message: gciError messageText
		terminateOnClose: true.
!

openOn: gsProcess message: aString terminateOnClose: aBoolean

	^(self showOnSession: gsProcess gciSession)
		initializeProcess: gsProcess message: aString terminateOnClose: aBoolean;
		answer.
!

printShortFrameAt: index process: gsProcess on: stream
	| frameString  |
	frameString := gsProcess stack at: index.
	^stream
		cr;
		nextPut: $[;
		nextPutAll: index printString;
		nextPut: $];
		space;
		nextPutAll: frameString!

printVar: var on: stream
	| valueString maxPrintSize |
	stream
		cr;
		tab;
		nextPutAll: var key value asString;
		space;
		nextPutAll: 'oop(';
		print: var key key asString asNumber;
		nextPut: $);
		space;
		nextPutAll: '==';
		space.
	valueString := var value asString.
	maxPrintSize := valueString size min: self maxPrint.
	stream nextPutAll: (valueString copyFrom: 1 to: maxPrintSize).
	valueString size > self maxPrint ifTrue: [stream nextPutAll: '...']!

printVariables: sortedVars on: stream
	sortedVars do: [:var | self printVar: var on: stream]!

reportError: gsError
	| debugger answer |
	(debugger := self debuggerFor: gsError processOop) notNil
		ifTrue: 
			[debugger update.
			Processor activeProcess terminate.
			self error: 'We should never get here!!'].
	(#(2709 6005) includes: gsError errorReport number)
		ifTrue: [^self openDebuggerOnException: gsError].
	self aboutToShowErrorShellOn: gsError.	"allow RowanDebuggerTestCase to override and skip error dialog and go straight to debugger"
	answer := (JadeErrorShell showModalOn: gsError)
				ifNil: [#terminate	"Window was closed without pressing any button!!"].
	answer = #terminate
		ifTrue: 
			[gsError terminateProcess.
			self error: 'We should never get here!!'].
	answer = #resume ifTrue: [^#resume].
	answer = #debug ifTrue: [^self openDebuggerOnException: gsError].
	self error: 'Unexpected response of ' , answer printString , '!!'!

resetDebuggers

	debuggers := nil.
! !
!JadeDebugger class categoriesFor: #aboutToShowErrorShellOn:!public! !
!JadeDebugger class categoriesFor: #debuggerFor:!public! !
!JadeDebugger class categoriesFor: #debuggers!public! !
!JadeDebugger class categoriesFor: #dumpStackFor:errorMessage:on:!public!stack dumping support! !
!JadeDebugger class categoriesFor: #maxPrint!private!stack dumping support! !
!JadeDebugger class categoriesFor: #openDebuggerOnException:!public! !
!JadeDebugger class categoriesFor: #openOn:message:terminateOnClose:!public! !
!JadeDebugger class categoriesFor: #printShortFrameAt:process:on:!private!stack dumping support! !
!JadeDebugger class categoriesFor: #printVar:on:!private!stack dumping support! !
!JadeDebugger class categoriesFor: #printVariables:on:!private!stack dumping support! !
!JadeDebugger class categoriesFor: #reportError:!public! !
!JadeDebugger class categoriesFor: #resetDebuggers!public! !

