"Filed out from Dolphin Smallalk"!

JadeTextDocument subclass: #JadeDebugger
	instanceVariableNames: 'answer errorMessagePresenter frame frameListOffset frameListPresenter gsProcess processList processListPresenter terminateOnClose variableDataPresenter variableListPresenter waitingForAnswerProcess debuggerProcess'
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
	(processListPresenter list size <= 1 or: [gsProcess oop = processListPresenter list first oop])
		ifTrue: 
			[self view close.
			^self].
	processListPresenter list copy
		do: [:each | each oop = gsProcess oop ifTrue: [processListPresenter list remove: each]].
	[self _terminateProcess: cachedGsProcess] on: TerminateProcess do: [:ex | ex return: nil].
	self update.
	gsProcess := processListPresenter list first.
!

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

implement

	self halt.
!

inspectVariable
	| object selection |
	(selection := variableListPresenter selection) isDisplayLabel ifTrue: [^self].
	object := gciSession oopTypeWithOop: selection key key asNumber.
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
!

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
		'UndefinedObject (Object) >> _doesNotUnderstand:args:envId:reason: @8 line 14'
		'UndefinedObject (Object) >> _doesNotUnderstand:args:envId:reason: @12 line 17'
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

updateProcessListPresenter
	processListPresenter list: processList copy	"to ensure list gets updated"!

updateSaveMethodOop: anInteger
	"do nothing"
! !
!JadeDebugger categoriesForMethods!
_terminateProcess!public! !
_terminateProcess:!public! !
activeTextEdit!private! !
clearUI!public! !
codeSourcePresenterClass!private! !
contextObject!public! !
createComponents!public! !
createSchematicWiring!public! !
implement!public! !
inspectVariable!menu handlers!private! !
queryCommand:!public! !
runToCursor!menu handlers!private! !
saveMethod!menu handlers!private! !
selectedFrame!public! !
selectedVariable!public! !
showNextStatement!public! !
stackInitialSelection!public! !
stackInitialSelectionData!public! !
statusBarText:!public! !
stepInto!menu handlers!private! !
stepOut!menu handlers!private! !
stepOver!menu handlers!private! !
updateProcessListPresenter!private! !
updateSaveMethodOop:!public! !
!

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
			[debugger getProcessList; update.
			Processor activeProcess kill.
			self error: 'We should never get here!!'].
	(#(2709 6005) includes: gsError errorReport number)
		ifTrue: [^self openDebuggerOnException: gsError].
	self aboutToShowErrorShellOn: gsError.	"allow JadeiteDebuggerTestCase to override and skip error dialog and go straight to debugger"
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
!JadeDebugger class categoriesForMethods!
aboutToShowErrorShellOn:!public! !
debuggerFor:!public! !
debuggers!public! !
dumpStackFor:errorMessage:on:!public!stack dumping support! !
maxPrint!private!stack dumping support! !
openDebuggerOnException:!public! !
printShortFrameAt:process:on:!private!stack dumping support! !
printVar:on:!private!stack dumping support! !
printVariables:on:!private!stack dumping support! !
reportError:!public! !
resetDebuggers!public! !
!

