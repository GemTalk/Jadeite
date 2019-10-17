"Filed out from Dolphin Smalltalk 7"!

JadeDebugger subclass: #JadeiteDebugger
	instanceVariableNames: 'statusTextPresenter idleProcess idleProcessSemaphore search debuggerService'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: 'debuggerClass semaphore'!
JadeiteDebugger guid: (GUID fromString: '{cae790de-8a45-49eb-813a-6cb32999cd4d}')!
JadeiteDebugger comment: ''!
!JadeiteDebugger categoriesForClass!Unclassified! !
!JadeiteDebugger methodsFor!

_processList

	^processList!

_terminateProcess: aGsProcess

	| string |
	BrowserUpdate current logComment: '#_terminateProcess:'.
	string := '
| gsProcess |
gsProcess := Object _objectForOop: ' , aGsProcess oopType value printString , '.
gsProcess ifNotNil: [gsProcess terminate. (Delay forMilliseconds: 10) wait].
Processor allProcesses includes: gsProcess'.
	5 timesRepeat: [
		(gciSession executeString: string) ifFalse: [^self].
	].
	self error: 'terminate process failed'.
!

aboutToChangeFrame: aSelectionChangingEvent
	BrowserUpdate current logComment: 'aboutToChangeFrame:'.
	aSelectionChangingEvent
		value: (codePane documentPresenter view isModified ifTrue: [self isOkayToChangeFrame] ifFalse: [true])!

additionalAccelerators
	^#(#(#reformatSource 'Ctrl+Shift+O'))!

basicSelectedFrame
	| index |
	(index := frameListPresenter selectionByIndex) = 0 ifTrue: [^nil].
	index := index + frameListOffset.
	^gsProcess frameForLevel: index!

browseFrameMethod
	| classService shell |
	frame gsMethod selector ifNil: [^self	"block context"].
	classService := RowanClassService new name: frame gsMethod className.
	BrowserUpdate current updateService: classService session: gciSession.
	shell := JadeiteBrowser showOnSession: gciSession.
	shell currentCard updateAfterFindClass: classService.
	shell currentCard findMethod: frame gsMethod selector.
	^shell!

browseImplementors
	^JadePresenter browseImplementorsOf: frame gsMethod selector session: self gciSession!

browseObjectClass
	| shell classService |
	classService := RowanClassService new
				name: variableListPresenter selection className asString subStrings first.	"strip off 'class' if meta"
	BrowserUpdate current updateService: classService session: gciSession.
	shell := JadeiteBrowser showOnSession: gciSession.
	shell currentCard updateAfterFindClass: classService.
	^shell!

browseSenders
	^JadePresenter browseSendersOf: frame gsMethod selector session: self gciSession!

clearBreakPointsAt: stepPoint
	gsProcess frames do: 
			[:frameService |
			frameService method homeMethodOop = frame method homeMethodOop
				ifTrue: [frameService breaks remove: stepPoint ifAbsent: []]]!

codeSourcePresenterClass
	^JadeiteDebuggerMethodSourcePresenter!

createComponents
	super createComponents.
	statusTextPresenter := self add: TextPresenter new name: 'statusBarField'!

createSchematicWiring
	super createSchematicWiring.
	frameListPresenter
		when: #actionPerformed
		send: #browseFrameMethod
		to: self.
	documentPresenter
		when: #textChanged
			send: #methodValueChanged
			to: self;
		when: #autoComplete:startingAt:accept:
			send: #onAutoComplete:startingAt:accept:
			to: self search;
		when: #timerTick:
			send: #onTimerTick:
			to: self search;
		when: #charAdded:
			send: #onCharAdded:
			to: self search!

debuggerService
	"for test usage" 
	^debuggerService!

displayUncompilableSourceIn: sourcePresenter
	sourcePresenter value size < 34 ifTrue: [^self].
	((sourcePresenter value copyFrom: 2 to: 34) equals: 'METHOD SOURCE CANNOT BE DISPLAYED')
		ifTrue: [sourcePresenter view backcolor: JadeTextStyles default colorForUndisplayableSource ]!

documentPresenter

	^documentPresenter!

errorMessagePresenter
	^errorMessagePresenter!

executeSelectionOrLine: contextObject
	| answeringService theAnswer oop |
	oop := (contextObject isKindOf: ExternalInteger)
				ifTrue: [contextObject value]
				ifFalse: [contextObject].	"services wants a local special as a context"
	oop ifNil: [oop := 20]. 
	answeringService := RowanAnsweringService new.
	answeringService
		command: #exec:inFrame:ofProcess:context:;
		commandArgs: (Array
					with: self currentSelectionOrLine
					with: frameListPresenter selectionByIndex
					with: gsProcess oop
					with: oop).
	self issueCommand: (Array with: answeringService).
	theAnswer := answeringService answer.
	theAnswer ifNotNil: [theAnswer key ifTrue: [theAnswer value: (OopType64 fromInteger: theAnswer value)]].
	^theAnswer!

frameListPresenter
	^frameListPresenter!

gciSession: aGciSession
	"don't do the force logout. If we close the debugger, the thread
	doing the termination will be terminated and other windows won't
	close."
	gciSession := aGciSession.
	gciSession
		when: #'logoutRequested:'			send: #'logoutRequested:'	to: self;
		when: #'logoutPending'			send: #'exit'			to: self;
		yourself.


!

getProcessList
	"#getProcessList copied from RowanProjectsBrowserPresenter>>updatePresenters"

	BrowserUpdate current logComment: 'Update debugger service'.
	debuggerService := RowanDebuggerService onProcess: gsProcess.
	self updateServices: (Array with: debuggerService).
	BrowserUpdate current logComment: 'Update debugger service complete'.
	BrowserUpdate current
		logComment: 'debuggerService processes: ' , debuggerService processes printString.
	debuggerService processes ifNil: [^self].
	gsProcess := debuggerService processes
				detect: [:processService | processService oop = gsProcess oop]
				ifNone: [gsProcess	"it should be found though"].
	debuggerService processes notEmpty
		ifTrue: [processListPresenter selection: debuggerService processes first]!

homeFrame
	^frameListPresenter list detect: [:str | str = (self homeFrameOf: frame) printString]!

homeFrameOf: theFrame
	^gsProcess frames detect: 
			[:frameService |
			frameService homeMethodSelector = theFrame homeMethodSelector and: 
					[frameService method selector = frameService homeMethodSelector
						and: [theFrame homeMethodClassName = frameService homeMethodClassName]]]!

initializeIdleProcess
	"Private - Support for automated testing so we know when UI is ready.
	See #onIdleEntered"

	| cachedClass cachedSession |
	idleProcessSemaphore := Semaphore forMutualExclusion.
	cachedClass := self class.
	cachedSession := gciSession.
	idleProcess := 
			[
			[
			[
			[(Delay forMilliseconds: 10) wait.
			cachedSession isCallInProgress] whileTrue: [].
			cachedClass signalSemaphore.
			idleProcessSemaphore wait]
					repeat]
					ensure: [cachedClass ifNotNil: [:cls | cls signalSemaphore]]]
					newProcess.
	idleProcess priority: Processor userBackgroundPriority.
	idleProcess resume!

initializeProcess: aProcess message: aString terminateOnClose: aBoolean
	
	[super
		initializeProcess: aProcess
		message: aString
		terminateOnClose: aBoolean]
			ensure: [self initializeIdleProcess]!

isOkayToChangeFrame
	^codePane isOkayToChange!

methodListSelection
	"really a selection from the frame list"

	| methodService |
	methodService := self basicSelectedFrame gsMethod.
	methodService command: nil.
	self updateServices: (Array with: methodService).
	^methodService!

methodSourcePresenter

	^codePane!

methodValueChanged
	frameListPresenter selectionIfNone: [^true].
	documentPresenter view
		backcolor: JadeTextStyles default colorForUnsavedEdits;
		clearContainerIndicators.
	self displayUncompilableSourceIn: codePane documentPresenter!

onCloseRequested: boolValueHolder
	self isOkayToChangeFrame ifFalse: [^self].
	super onCloseRequested: boolValueHolder!

onIdleEntered
	idleProcessSemaphore ifNotNil: [:sem | sem signal].
	super onIdleEntered!

onViewClosed
	"Private - copied from RowanSystemBrowserPresenter>>onViewClosed"
	BrowserUpdate current logComment: 'Closing Debugger {' , self identityHash printString , '}'.
	processList := processListPresenter list
				collect: [:each | GsProcess session: gciSession oopType: each oopType].
	subPresenters do: [:presenter | BrowserUpdate current removeEventsTriggeredFor: presenter].
	"Allow test to know when view is closed"
	self class signalSemaphore.
	self terminateIdleProcess.
	super onViewClosed.!

onViewDestroyed
	"Private - copied from RowanSystemBrowserPresenter>>onViewClosed"

	super onViewDestroyed.
	self terminateIdleProcess!

onViewOpened
	"Private - copied from RowanProjectsBrowserPresenter>>onViewOpened"

	super onViewOpened.
	self registerPresentersForUpdates.
	BrowserUpdate current logComment: 'Opening Debugger {' , self identityHash printString , '}'!

processListPresenter
	^processListPresenter!

queryCommand: query

	processList := processListPresenter list collect: [:each | GsProcess session: gciSession oopType: each oopType].
	(#(#browseFrameMethod #browseImplementors #browseSenders) includes: query commandSymbol) ifTrue: [
		query isEnabled: frame method selector notNil.
		^true
	].
	(#(#'resumeProcess' #'runToCursor' #'stepInto' #'stepOut' #'stepOver') includes: query commandSymbol) ifTrue: [
		query isEnabled: processListPresenter selectionByIndex == 1.
		^true
	].
	(#(#'terminateProcess') includes: query commandSymbol) ifTrue: [
		query isEnabled: (processList notEmpty and: [processList first ~~ gsProcess]).
		^true
	].
	(#(#'implement') includes: query commandSymbol) ifTrue: [
		query isEnabled: false. "frameListPresenter model first subStrings first = 'MessageNotUnderstood'."
		^true
	].
	(#(#'browseObjectClass') includes: query commandSymbol) ifTrue: [
		query isEnabled: variableListPresenter hasSelection.
		^true
	].
	(query commandSymbol ==#saveMethod) ifTrue: [
		query isEnabled: documentPresenter view isModified.
		^true
	].
	^super queryCommand: query
!

reformatSource
	| methodService |
	methodService := self methodListSelection.
	methodService
		source: documentPresenter value;
		command: #reformatSource;
		commandArgs: Array new.
	[self issueCommand: (Array with: methodService)] on: Error
		do: 
			[:ex |
			self setCompileErrorColor.
			self statusBarText: 'Reformat failed. Illegal source'.
			^false].
	documentPresenter view performUndoableAction: 
			[documentPresenter view modifyText: [documentPresenter view sciSetText: methodService source]].
	documentPresenter value: methodService source.
	documentPresenter view isModified: true.
	documentPresenter view
		backcolor: JadeTextStyles default colorForUnsavedEdits;
		clearContainerIndicators.
	statusTextPresenter view backcolor: statusTextPresenter view defaultBackcolor.
	self statusBarText: String new.
	^documentPresenter value!

registerPresentersForUpdates
	"copied from RowanProjectsBrowserPresenter>>registerPresentersForUpdates"

	BrowserUpdate current
		register: processListPresenter selector: #processListUpdate:;
		register: variableListPresenter
			selector: #updateVariable:debugger:
			browser: self!

restart
	self isOkayToChangeFrame ifFalse: [^self].
	(gsProcess gsProcessForSession: gciSession)
		trimStackToLevel: frameListPresenter selectionByIndex + frameListOffset.
	self getProcessList!

resumeProcess
	self isOkayToChangeFrame ifFalse: [^self].
	^super resumeProcess
!

saveMethod
	| classService string changedSource |
	frame isExecutedBlockContext
		ifTrue: 
			[frame homeMethodSelector = nil
				ifTrue: 
					[^MessageBox notify: 'Cannot save code in an executed block context. Home method not on stack.'].
			changedSource := documentPresenter value.
			self selectHomeMethod.
			documentPresenter value: changedSource].
	string := self getDocumentData reject: [:each | each == Character cr].
	classService := RowanClassService new
				name: frame method className;
				meta: frame method meta;
				yourself.
	classService
		command: #saveMethodSource:category:;
		commandArgs: (Array with: string with: frame method category).
	[self issueCommand: (Array with: classService)] on: GsCompileError
		do: 
			[:ex |
			self setCompileErrorColor.
			^codePane reportCompileError: ex list in: documentPresenter].
	(self methodSourcePresenter compilationWarningFrom: classService selectedMethods)
		ifNil: 
			[statusTextPresenter view backcolor: JadeTextStyles default colorForNoEdits.
			self statusBarText: String new]
		ifNotNil: 
			[:warning |
			self setCompileWarningColor.
			self statusBarText: warning].
	documentPresenter isModified: false.
	(gsProcess gsProcessForSession: gciSession)
		trimStackToLevel: frameListPresenter selectionByIndex + frameListOffset.
	self getProcessList!

search
	^search
		ifNil: 
			[search := JadeiteSearch on: documentPresenter view session: self gciSession]!

selectedFrame
	"Comment from RowanFrameService>>initializeProcess:level:organizer: ---- 
		'In 3.2.15 the server does some whacky things with IP, stepPoint, and nested methods.
		See http://kermit.gemtalksystems.com/bug?bug=45553 --JGF'
	When the step point error is thrown, we do a step into instead. There may be better
	solutions."

	| index |
	BrowserUpdate current logComment: '#selectedFrame'.
	BrowserUpdate current
		logComment: '(index := frameListPresenter selectionByIndex) = 0 ifTrue: [^self].'.
	BrowserUpdate current
		logComment: 'frameListPresenter selectionByIndex: ' , frameListPresenter selectionByIndex printString.
	(index := frameListPresenter selectionByIndex) = 0 ifTrue: [^self].
	BrowserUpdate current logComment: 'setting index: ' , index printString.
	BrowserUpdate current logComment: 'index := index + frameListOffset.'.
	index := index + frameListOffset.
	BrowserUpdate current logComment: '(frame := gsProcess frameForLevel: index) isNil ifTrue: [^self].'.
	BrowserUpdate current logComment: (gsProcess frameForLevel: index) printString.
	(frame := gsProcess frameForLevel: index) isNil ifTrue: [^self].
	BrowserUpdate current logComment: 'frame stepPoint: ' , frame stepPoint printString.
	frame stepPoint ifNil: [RowanDebuggerStepPointError signal].	"see comment in  RowanFrameService>>initializeProcess:level:organizer:"
	variableListPresenter list: frame vars.
	documentPresenter value: frame gsMethod source.
	BrowserUpdate current logComment: 'udpdated source pane'.
	documentPresenter view isModified: false.
	codePane offsets: nil.
	codePane gsMethod: frame gsMethod.
	self displayUncompilableSourceIn: codePane documentPresenter.
	frame stepPoint ifNotNil: [codePane showStepPoint: frame stepPoint].
	(self view viewNamed: 'toolbar') update.
	BrowserUpdate current logComment: 'finished #selectedFrame'!

selectHomeMethod
	frameListPresenter selection: self homeFrame!

setCompileErrorColor
	statusTextPresenter view backcolor: Color red faded!

setCompileWarningColor
	statusTextPresenter view backcolor: Color yellow faded!

statusBarText

	^statusTextPresenter value!

statusBarText: aString
	(self view topShell view viewNamed: 'statusBarField') value: aString. !

statusTextPresenter
	"Private - for testing"

	^statusTextPresenter!

stepInto
	self isOkayToChangeFrame ifFalse:[^self].
	BrowserUpdate current logComment: '#stepInto'.
	gciSession stepInto: (GsProcess session: gciSession oopType: gsProcess oopType)
		inFrame: frameListPresenter selectionByIndex + frameListOffset.
	[self getProcessList] on: RowanDebuggerStepPointError do: [:ex | self stepInto]!

stepOut
	| stepOutFrameIndex |
	self isOkayToChangeFrame ifFalse: [^self].
	BrowserUpdate current logComment: '#stepOut'.
	stepOutFrameIndex := frameListPresenter selectionByIndex.
	stepOutFrameIndex = 1 ifTrue: [stepOutFrameIndex := 2].
	gciSession stepOut: (GsProcess session: gciSession oopType: gsProcess oopType)
		inFrame: stepOutFrameIndex.
	[self getProcessList] on: RowanDebuggerStepPointError do: [:ex | self stepInto]!

stepOver
	self isOkayToChangeFrame ifFalse: [^self].
	BrowserUpdate current logComment: '#stepOver'.
	gciSession stepOver: (GsProcess session: gciSession oopType: gsProcess oopType)
		inFrame: frameListPresenter selectionByIndex + frameListOffset.
	[self getProcessList] on: RowanDebuggerStepPointError do: [:ex | self stepInto]!

stepThrough
	self isOkayToChangeFrame ifFalse: [^self].
	BrowserUpdate current logComment: '#stepThrough'.
	gciSession stepThrough: (GsProcess session: gciSession oopType: gsProcess oopType)
		inFrame: frameListPresenter selectionByIndex + frameListOffset.
	(gciSession gciVersion beginsWith: '3.2') ifFalse: [self stepOver].
	[self getProcessList] on: RowanDebuggerStepPointError do: [:ex | self stepInto]!

terminateIdleProcess
	idleProcess
		ifNotNil: 
			[idleProcess terminate.
			idleProcess := nil]!

terminateProcess
	(MessageBox confirm: 'Terminate process?' caption: 'GemStone/S Process Termination')
		ifFalse: [^self].
	self isOkayToChangeFrame ifFalse: [^self].
	^self _terminateProcess!

updateMethodSource

	self selectedFrame.
	self displayUncompilableSourceIn:  codePane documentPresenter!

variableDataPresenter
	^variableDataPresenter!

variableListPresenter
	^variableListPresenter! !
!JadeiteDebugger categoriesFor: #_processList!public! !
!JadeiteDebugger categoriesFor: #_terminateProcess:!public! !
!JadeiteDebugger categoriesFor: #aboutToChangeFrame:!event handlers!public! !
!JadeiteDebugger categoriesFor: #additionalAccelerators!accessing!public! !
!JadeiteDebugger categoriesFor: #basicSelectedFrame!public! !
!JadeiteDebugger categoriesFor: #browseFrameMethod!menu handlers!private! !
!JadeiteDebugger categoriesFor: #browseImplementors!menu handlers!private! !
!JadeiteDebugger categoriesFor: #browseObjectClass!menu handlers!private! !
!JadeiteDebugger categoriesFor: #browseSenders!menu handlers!private! !
!JadeiteDebugger categoriesFor: #clearBreakPointsAt:!menu handlers support!public! !
!JadeiteDebugger categoriesFor: #codeSourcePresenterClass!private! !
!JadeiteDebugger categoriesFor: #createComponents!public! !
!JadeiteDebugger categoriesFor: #createSchematicWiring!public! !
!JadeiteDebugger categoriesFor: #debuggerService!accessing!private! !
!JadeiteDebugger categoriesFor: #displayUncompilableSourceIn:!private! !
!JadeiteDebugger categoriesFor: #documentPresenter!accessing!public! !
!JadeiteDebugger categoriesFor: #errorMessagePresenter!accessing!public! !
!JadeiteDebugger categoriesFor: #executeSelectionOrLine:!Jade!private! !
!JadeiteDebugger categoriesFor: #frameListPresenter!accessing!frames!public! !
!JadeiteDebugger categoriesFor: #gciSession:!public! !
!JadeiteDebugger categoriesFor: #getProcessList!public! !
!JadeiteDebugger categoriesFor: #homeFrame!compiling!frames!menu handlers!private! !
!JadeiteDebugger categoriesFor: #homeFrameOf:!frames!public! !
!JadeiteDebugger categoriesFor: #initializeIdleProcess!initialization!public! !
!JadeiteDebugger categoriesFor: #initializeProcess:message:terminateOnClose:!initialization!public! !
!JadeiteDebugger categoriesFor: #isOkayToChangeFrame!public!testing! !
!JadeiteDebugger categoriesFor: #methodListSelection!accessing!public! !
!JadeiteDebugger categoriesFor: #methodSourcePresenter!public! !
!JadeiteDebugger categoriesFor: #methodValueChanged!event handlers!public! !
!JadeiteDebugger categoriesFor: #onCloseRequested:!event handlers!private! !
!JadeiteDebugger categoriesFor: #onIdleEntered!event handlers!private! !
!JadeiteDebugger categoriesFor: #onViewClosed!event handlers!private! !
!JadeiteDebugger categoriesFor: #onViewDestroyed!event handlers!private! !
!JadeiteDebugger categoriesFor: #onViewOpened!event handlers!private! !
!JadeiteDebugger categoriesFor: #processListPresenter!accessing!public! !
!JadeiteDebugger categoriesFor: #queryCommand:!menu handlers!public! !
!JadeiteDebugger categoriesFor: #reformatSource!menu handlers!private! !
!JadeiteDebugger categoriesFor: #registerPresentersForUpdates!public!register presenters! !
!JadeiteDebugger categoriesFor: #restart!menu handlers!private! !
!JadeiteDebugger categoriesFor: #resumeProcess!menu handlers!private! !
!JadeiteDebugger categoriesFor: #saveMethod!compiling!menu handlers!private! !
!JadeiteDebugger categoriesFor: #search!accessing!public! !
!JadeiteDebugger categoriesFor: #selectedFrame!frames!public! !
!JadeiteDebugger categoriesFor: #selectHomeMethod!compiling!frames!menu handlers!private! !
!JadeiteDebugger categoriesFor: #setCompileErrorColor!compiling!menu handlers!private! !
!JadeiteDebugger categoriesFor: #setCompileWarningColor!compiling!menu handlers!private! !
!JadeiteDebugger categoriesFor: #statusBarText!accessing!public! !
!JadeiteDebugger categoriesFor: #statusBarText:!accessing!public! !
!JadeiteDebugger categoriesFor: #statusTextPresenter!accessing!private! !
!JadeiteDebugger categoriesFor: #stepInto!menu handlers!private! !
!JadeiteDebugger categoriesFor: #stepOut!menu handlers!private! !
!JadeiteDebugger categoriesFor: #stepOver!menu handlers!private! !
!JadeiteDebugger categoriesFor: #stepThrough!menu handlers!private! !
!JadeiteDebugger categoriesFor: #terminateIdleProcess!private! !
!JadeiteDebugger categoriesFor: #terminateProcess!menu handlers!private! !
!JadeiteDebugger categoriesFor: #updateMethodSource!public! !
!JadeiteDebugger categoriesFor: #variableDataPresenter!accessing!public! !
!JadeiteDebugger categoriesFor: #variableListPresenter!accessing!public! !

!JadeiteDebugger class methodsFor!

aboutToShowErrorShellOn: gsError
	self semaphore ifNil: [^self].
	[
		^self openDebuggerOnException: gsError
	] on: GsError do: [:ex | 
		ex debugger view close.
		MessageBox warning: ex description.
		Processor activeProcess terminate. 
	]!

debuggerClass
	^debuggerClass ifNil: [JadeiteDebugger]!

debuggerClass: aDebugger
"
	RowanDebugger debuggerClass: nil.
	RowanDebugger debuggerClass: JadeDebugger.
	RowanDebugger debuggerClass: RowanDebugger.
"
	debuggerClass := aDebugger.
!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 1601 1201 551 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.TextEdit) 34 16 nil 416 34 2 8 1140850816 1 608 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 7 nil nil nil 608 nil 8 4294905455 852486 ##(Smalltalk.NullConverter) nil nil 3 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 321 7 514 1245 39 608 850 #text: 34 1 8 'Static Text' 608 850 #setMarginWidths: 34 1 8 #(3 3) 608 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 160 0 0 0 3 0 0 0 14 3 0 0 22 0 0 0] 8 #() 514 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 321 1138 #fixedParentRight -3 1138 #fixedParentTop 7 1138 #fixedViewTop 39 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 1216 nil nil nil 7 nil nil nil 1216 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 2 410 ##(Smalltalk.TextEdit) 34 16 nil 1216 34 2 8 1140916352 1 1344 nil 466 8 4278190080 nil 519 nil nil nil 1344 nil 8 4294905455 754 nil nil 3 786 138 144 34 1 850 #createAt:extent: 34 2 514 1 995 514 1569 39 1344 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 241 1 0 0 16 3 0 0 4 2 0 0] 8 #() 1088 nil 27 327734 ##(Smalltalk.Float) 8 51 51 51 51 51 51 179 63 true 170 192 34 4 1344 8 'statusBarField' 410 ##(Smalltalk.ReferenceView) 34 14 nil 1216 34 2 8 1140850688 131073 1712 nil 466 8 4278190080 nil 7 nil nil nil 1712 1180166 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteDebuggerMethodSourcePresenter) #resource_Default_view nil 786 138 144 34 1 850 #createAt:extent: 34 2 514 1 503 514 1569 493 1712 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 251 0 0 0 16 3 0 0 241 1 0 0] 8 #() 1088 nil 27 8 'codePane' nil 786 138 144 34 1 850 #createAt:extent: 34 2 514 1 51 514 1569 1033 1216 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 16 3 0 0 29 2 0 0] 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 1216 34 2 8 1140850688 131073 2176 nil 466 496 nil 7 nil nil nil 2176 1282 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 2176 34 2 8 1140850688 131073 2304 nil nil nil 7 nil nil nil 2304 546 170 176 34 6 410 ##(Smalltalk.PushButton) 34 20 nil 2304 34 2 8 1140924416 1 2416 nil nil nil 7 nil nil nil 2416 nil 8 4294904145 1180998 4 ##(Smalltalk.CommandDescription) #terminateProcess 8 'Terminate' 1 1 nil nil false nil nil nil 786 138 144 34 3 850 #createAt:extent: 34 2 514 719 1 514 141 51 2416 850 #isEnabled: 8 #(false) 2416 850 #text: 34 1 8 'Terminate' 2416 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 103 1 0 0 0 0 0 0 173 1 0 0 25 0 0 0] 8 #() 1088 nil 29 1106 1138 #fixedPreviousRight 1 1168 1 1184 1 1200 51 410 ##(Smalltalk.ComboBox) 34 17 nil 2304 34 2 8 1412498947 1025 2816 590662 2 ##(Smalltalk.ListModel) 138 144 1984 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 466 8 4278190080 nil 7 nil nil nil 2816 nil 8 4294905737 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each printString]' 8 #[30 105 226 0 106] #printString 3024 7 257 nil 1984 401 786 138 144 34 1 850 #createAt:extent: 34 2 514 1 1 514 719 53 2816 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 103 1 0 0 26 0 0 0] 8 #() 1088 nil 27 1106 1152 1 1168 -139 1184 1 1200 47 410 ##(Smalltalk.ListBox) 34 17 nil 2304 34 2 8 1144062209 1025 3296 2882 138 144 1984 nil 2944 466 496 nil 7 265030 4 ##(Smalltalk.Menu) nil true 34 3 984134 2 ##(Smalltalk.CommandMenuItem) 1 2498 #browseFrameMethod 8 '&Browse Frame Method' 1 1 nil nil nil 3458 1 2498 #browseImplementors 8 'Browse &Implementors' 1 1 nil nil nil 3458 1 2498 #browseSenders 8 'Browse &Senders' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 3296 nil 8 4294903829 ##(Smalltalk.BasicListAbstract) 1984 false 786 138 144 34 3 850 #createAt:extent: 34 2 514 1 51 514 859 443 3296 850 #contextMenu: 34 1 3424 3296 850 #horizontalExtent: 8 #(0) 3296 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 173 1 0 0 246 0 0 0] 8 #() 1088 nil 27 1106 1152 1 1168 1 1138 #fixedPreviousBottom 1 1138 #fixedParentBottom 1 170 192 34 4 2816 8 'processList' 3296 8 'frameList' nil 786 138 144 34 1 850 #createAt:extent: 34 2 514 1 1 514 859 493 2304 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 173 1 0 0 246 0 0 0] 34 3 2816 2416 3296 1088 nil 27 3 410 ##(Smalltalk.ContainerView) 34 15 nil 2176 34 2 8 1140850688 131073 4144 nil 466 496 nil 7 nil nil nil 4144 1282 170 176 34 4 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 4144 34 2 8 1174475012 1025 4272 674 nil false 720 nil 466 8 4278190080 nil 7 3410 nil true 34 20 3458 1 2498 #undo 8 '&Undo' 9397 1 nil nil nil 3458 1 2498 #redo 8 'R&edo' 9395 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 3458 1 2498 #editCut 8 'Cu&t' 9393 1 nil nil nil 3458 1 2498 #editCopy 8 '&Copy' 9351 1 nil nil nil 3458 1 2498 #editPaste 8 '&Paste' 9389 1 nil nil nil 3458 1 2498 #editDelete 8 'De&lete' 1629 1 nil nil nil 3458 1 2498 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 4514 4097 3458 1 2498 #editFind 8 '&Find...' 9357 1 nil nil nil 3458 1 2498 #editFindNext 8 'Find &Next' 9359 1 nil nil nil 3458 1 2498 #editReplace 8 '&Replace...' 9361 1 nil nil nil 4514 4097 3458 1 2498 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 3458 1 2498 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 3458 1 2498 #jadeExecute 8 'Execute' 9355 1 nil nil nil 3458 1 2498 #jadeDebug 8 'De&bug' 9349 1 nil nil nil 4514 4097 3458 1 2498 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 3458 1 2498 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 4272 nil 8 4294905431 754 nil nil 9 nil 170 192 34 8 #callTip 1182790 1 ##(Smalltalk.ScintillaTextStyle) 77 786694 ##(Smalltalk.IndexedColor) 33554457 5378 33554471 1 nil nil nil nil #callTip nil nil nil #indentGuide 5346 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #lineNumber 5346 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #normal 5346 1 nil nil 1 nil nil nil nil #normal nil nil nil 34 256 5456 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 5440 nil nil nil 5424 5360 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 1641542 1 ##(Smalltalk.ScintillaMarkerDefinition) nil nil nil nil 4272 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1984 nil 170 176 1984 nil nil nil nil nil 5378 33554447 nil nil nil nil nil nil nil 1 170 192 1984 nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 5346 1027 nil 196934 1 ##(Smalltalk.RGB) 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 5346 1029 5698 60239 5698 31326207 1 nil nil nil nil #Warning nil nil nil #Error 5346 1031 5698 335 5698 31317503 1 nil nil nil nil #Error nil nil nil nil 786 138 144 34 8 850 #createAt:extent: 34 2 514 1 331 514 701 163 4272 850 #contextMenu: 34 1 4384 4272 850 #modificationEventMask: 8 #(3912191) 4272 850 #caretPeriod: 8 #(530) 4272 850 #wordWrap: 8 #(true) 4272 850 #margins: 34 1 34 5 985158 2 ##(Smalltalk.ScintillaMargin) 1 4272 1 3 nil nil nil nil 6114 3 4272 33 nil nil 67108863 nil nil 6114 5 4272 1 nil nil nil nil nil 6114 7 4272 1 nil nil nil nil nil 6114 9 4272 1 nil nil nil nil nil 4272 850 #canHScroll: 8 #(false) 4272 850 #maxCompletionListHeight: 8 #(9) 4272 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 165 0 0 0 94 1 0 0 246 0 0 0] 8 #() 1088 nil 29 3 410 ##(Smalltalk.ListView) 34 30 nil 4144 34 2 8 1140920397 1025 6320 2882 138 144 1984 nil 2944 466 496 nil 7 3410 nil true 34 2 3458 1 2498 #browseObjectClass 8 '&Browse Object Class' 1 1 nil nil nil 3458 1 2498 #inspectVariable 8 'Inspect' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 6320 nil 8 4294905361 ##(Smalltalk.BasicListAbstract) nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 3 920646 5 ##(Smalltalk.ListViewColumn) 8 'Variable' 201 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 3010 0 nil 3042 2 1 3008 8 'doIt' 8 '[:each | each key value]' 8 #[30 105 226 0 142 106] #key 6704 7 257 nil nil 6320 nil 1 nil nil 6658 8 'Value' 313 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 3010 0 459302 ##(Smalltalk.Context) 1 1 nil nil 3042 0 9 ##(Smalltalk.UndefinedObject) 8 'doIt' 34 2 8 '[:each | each value]' 34 1 138 ##(Smalltalk.PoolDictionary) 1984 8 #[252 1 0 1 1 5 0 17 229 32 142 106 105] 17 257 nil nil 6320 nil 3 nil nil 6658 8 'OOP' 181 #right 459270 ##(Smalltalk.Message) #displayString 8 #() 7010 #<= 7040 3010 0 nil 3042 3 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each key key asNumber]' 8 #[31 105 226 0 158 159 106] #key #asNumber 7072 7 257 nil nil 6320 nil 1 nil nil #report 1984 nil 131169 nil 34 4 nil nil 514 1 1 nil 786 138 144 34 3 850 #createAt:extent: 34 2 514 1 1 514 701 321 6320 850 #contextMenu: 34 1 6432 6320 850 #text: 34 1 8 'Variable' 6320 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 94 1 0 0 160 0 0 0] 8 #() 1088 nil 27 5 true 170 192 34 4 4272 8 'variableData' 6320 8 'variableList' nil 786 138 144 34 1 850 #createAt:extent: 34 2 514 869 1 514 701 493 4144 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 178 1 0 0 0 0 0 0 16 3 0 0 246 0 0 0] 34 3 6320 410 ##(Smalltalk.Splitter) 34 12 nil 4144 34 2 8 1140850688 1 7648 nil 466 496 nil 519 nil nil nil 7648 786 138 144 34 1 850 #createAt:extent: 34 2 514 1 321 514 701 11 7648 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 160 0 0 0 94 1 0 0 165 0 0 0] 8 #() 1088 nil 27 4272 1088 nil 27 524806 ##(Smalltalk.Fraction) 253 311 false 170 192 1984 nil 786 138 144 34 1 850 #createAt:extent: 34 2 514 1 1 514 1569 493 2176 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 3 0 0 246 0 0 0] 34 3 2304 410 ##(Smalltalk.Splitter) 34 12 nil 2176 34 2 8 1140850688 1 8096 nil 466 496 nil 519 nil nil nil 8096 786 138 144 34 1 850 #createAt:extent: 34 2 514 859 1 514 11 493 8096 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 173 1 0 0 0 0 0 0 178 1 0 0 246 0 0 0] 8 #() 1088 nil 27 4144 1088 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 1216 34 2 8 1140850688 1 8336 nil 466 496 nil 519 nil nil nil 8336 786 138 144 34 1 850 #createAt:extent: 34 2 514 1 493 514 1569 11 8336 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 246 0 0 0 16 3 0 0 251 0 0 0] 8 #() 1088 nil 27 1712 1344 1088 nil 27 1106 1152 1 1168 1 1184 51 3904 1 410 ##(Smalltalk.ToolbarA) 34 25 nil 416 34 2 8 1140853580 131137 8592 nil 466 8 4278190080 nil 519 nil nil nil 8592 466 8 4278190080 8 4294905673 nil 170 192 34 16 41175 1115910 ##(Smalltalk.ToolbarIconButton) 41175 nil 8592 1 2498 #stepThrough 8 'Step Through' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'Object.ico' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil 395334 3 ##(Smalltalk.Bitmap) nil true nil nil nil nil 3 514 33 33 1 41043 8770 41043 nil 8592 1 2498 #showNextStatement 8 'Top Of Stack' 1 1 8834 nil true 8880 8 'icons\TopOfStack2.ico' nil 8962 nil true nil nil nil nil 3 514 33 33 1 41045 8770 41045 nil 8592 1 2498 #stepInto 8 'Step Into' 1 1 8834 nil true 8880 8 'StepInto.ico' 8928 8962 nil true nil nil nil nil 3 514 33 33 1 41047 8770 41047 nil 8592 1 2498 #stepOver 8 'Step Over' 1 1 8834 nil true 8880 8 'StepOver.ico' 8928 8962 nil true nil nil nil nil 3 514 33 33 1 41049 8770 41049 nil 8592 1 2498 #stepOut 8 'Step Out' 1 1 8834 nil true 8880 8 'StepOut.ico' 8928 8962 nil true nil nil nil nil 3 514 33 33 1 41051 8770 41051 nil 8592 1 2498 #runToCursor 8 'Run to Cursor' 1 1 8834 nil true 8880 8 'RunToCursor.ico' 8928 8962 nil true nil nil nil nil 3 514 33 33 1 41053 8770 41053 nil 8592 1 2498 #resumeProcess 8 'Go' 1 1 8834 nil true 8880 8 'Run.ico' 8928 8962 nil true nil nil nil nil 3 514 33 33 1 41055 8770 41055 nil 8592 1 2498 #restart 8 'Restart' 13545 1 8834 nil true 8880 8 'icons\ArrowCircle.ico' nil 8962 nil true nil nil nil nil 3 514 33 33 1 34 8 9008 9120 9232 8784 9344 9456 9568 9680 170 176 34 16 9648 13 9760 15 9200 3 9312 5 8976 7 9088 1 9424 9 9536 11 nil 1 nil 514 33 33 514 45 45 nil nil 786 138 144 34 2 850 #createAt:extent: 34 2 514 1 1 514 381 51 8592 850 #updateSizePosted 1984 8592 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 190 0 0 0 25 0 0 0] 8 #() 1088 nil 27 1106 1152 1 1138 #fixedViewLeft 381 1184 1 1200 51 170 192 34 4 608 8 'errorMessage' 8592 8 'toolbar' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 2 3410 nil true 34 7 3458 1 2498 #saveMethod 8 '&Save' 9383 1 nil nil nil 3458 1 2498 #copyStack nil 1 1 nil nil nil 4514 4097 3458 1 2498 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 3458 1 2498 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 3458 1 2498 #jadeExecute 8 '&Execute' 9355 1 nil nil nil 3458 1 2498 #jadeDebug 8 'Debu&g' 9359 1 nil nil nil 8 '&Edit' nil 134217729 nil nil 41025 nil nil 3410 nil true 34 7 3458 1 2498 #showNextStatement 8 'Top of Stack' 1 1 8834 nil true 8880 8 'icons\TopOfStack2.ico' nil nil nil 3458 1 2498 #stepInto nil 1 1 8834 nil true 8880 8 'StepInto.ico' 8928 nil nil 3458 1 2498 #stepOver nil 1 1 8834 nil true 8880 8 'StepOver.ico' 8928 nil nil 3458 1 2498 #stepOut nil 1 1 8834 nil true 8880 8 'StepOut.ico' 8928 nil nil 3458 1 2498 #runToCursor nil 1 1 8834 nil true 8880 8 'RunToCursor.ico' 8928 nil nil 3458 1 2498 #resumeProcess 8 'Resume' 1 1 8834 nil true 8880 8 'Run.ico' 8928 nil nil 3458 1 2498 #restart nil 13545 1 8834 nil true 8880 8 'icons\ArrowCircle.ico' nil nil nil 8 '&Debug' nil 134217729 nil nil 41041 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 8834 nil true 8880 8 'icons\GS32.ico' nil 8834 nil true 8880 8 'icons\GS16.ico' nil nil nil 1 nil nil 786 138 144 34 3 850 #createAt:extent: 34 2 514 7679 21 514 1601 1201 416 850 #text: 34 1 8 'Jade Debugger' 416 850 #updateMenuBar 1984 416 1026 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 31 18 0 0 98 2 0 0] 34 3 608 8592 1216 1088 nil 27 )!

semaphore
	"Support for automated testing so we know when UI is ready"

	^semaphore!

semaphore: aSemaphore
	"Support for automated testing so we know when UI is ready"

	semaphore := aSemaphore.
!

signalSemaphore

	self semaphore ifNotNil: [:value | 
		[
			value signal.
			SessionManager inputState prod.
		] forkAt: Processor userBackgroundPriority.
	].! !
!JadeiteDebugger class categoriesFor: #aboutToShowErrorShellOn:!public! !
!JadeiteDebugger class categoriesFor: #debuggerClass!public! !
!JadeiteDebugger class categoriesFor: #debuggerClass:!public! !
!JadeiteDebugger class categoriesFor: #resource_Default_view!public!resources-views! !
!JadeiteDebugger class categoriesFor: #semaphore!public! !
!JadeiteDebugger class categoriesFor: #semaphore:!public! !
!JadeiteDebugger class categoriesFor: #signalSemaphore!public! !

