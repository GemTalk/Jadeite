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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 1601 1201 551 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.TextEdit) 34 16 nil 416 34 2 8 1140850816 1 608 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 7 nil nil nil 608 nil 8 4294902515 852486 ##(Smalltalk.NullConverter) nil nil 3 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 381 7 514 1185 39 608 850 #text: 34 1 8 'Static Text' 608 850 #setMarginWidths: 34 1 8 #(3 3) 608 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 190 0 0 0 3 0 0 0 14 3 0 0 22 0 0 0] 8 #() 514 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 381 1138 #fixedParentRight -3 1138 #fixedParentTop 7 1138 #fixedViewTop 39 410 ##(Smalltalk.ToolbarA) 34 25 nil 416 34 2 8 1140853580 131137 1216 nil 466 8 4278190080 nil 519 nil nil nil 1216 466 8 4278190080 8 4294906689 nil 170 192 34 16 30179 1115910 ##(Smalltalk.ToolbarIconButton) 30179 nil 1216 1 1180998 4 ##(Smalltalk.CommandDescription) #showNextStatement 8 'Top Of Stack' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons\TopOfStack2.ico' nil 395334 3 ##(Smalltalk.Bitmap) nil true nil nil nil nil 3 514 33 33 1 30181 1394 30181 nil 1216 1 1426 #stepInto 8 'Step Into' 1 1 1474 nil true 1520 8 'StepInto.ico' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil 1554 nil true nil nil nil nil 3 514 33 33 1 30183 1394 30183 nil 1216 1 1426 #stepOver 8 'Step Over' 1 1 1474 nil true 1520 8 'StepOver.ico' 1696 1554 nil true nil nil nil nil 3 514 33 33 1 30185 1394 30185 nil 1216 1 1426 #stepThrough 8 'Step Through' 1 1 1474 nil true 1520 8 'bracket_down_arrow.ico' nil 1554 nil true nil nil nil nil 3 514 33 33 1 30187 1394 30187 nil 1216 1 1426 #stepOut 8 'Step Out' 1 1 1474 nil true 1520 8 'StepOut.ico' 1696 1554 nil true nil nil nil nil 3 514 33 33 1 30189 1394 30189 nil 1216 1 1426 #runToCursor 8 'Run to Cursor' 1 1 1474 nil true 1520 8 'RunToCursor.ico' 1696 1554 nil true nil nil nil nil 3 514 33 33 1 30191 1394 30191 nil 1216 1 1426 #resumeProcess 8 'Go' 1 1 1474 nil true 1520 8 'Run.ico' 1696 1554 nil true nil nil nil nil 3 514 33 33 1 30193 1394 30193 nil 1216 1 1426 #restart 8 'Restart' 13545 1 1474 nil true 1520 8 'icons\ArrowCircle.ico' nil 1554 nil true nil nil nil nil 3 514 33 33 1 34 8 1408 1600 1760 1872 1984 2096 2208 2320 170 176 34 16 2288 13 2400 15 1728 3 1840 5 1952 7 1568 1 2064 9 2176 11 nil 1 nil 514 33 33 514 45 45 nil nil 786 138 144 34 2 850 #createAt:extent: 34 2 514 1 1 514 381 51 1216 850 #updateSizePosted 8 #() 1216 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 190 0 0 0 25 0 0 0] 8 #() 1088 nil 27 1106 1152 1 1138 #fixedViewLeft 381 1184 1 1200 51 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 2736 nil nil nil 7 nil nil nil 2736 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 2 410 ##(Smalltalk.TextEdit) 34 16 nil 2736 34 2 8 1140916352 1 2864 nil 466 8 4278190080 nil 519 nil nil nil 2864 nil 8 4294902515 754 nil nil 3 786 138 144 34 1 850 #createAt:extent: 34 2 514 1 995 514 1569 39 2864 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 241 1 0 0 16 3 0 0 4 2 0 0] 8 #() 1088 nil 27 327734 ##(Smalltalk.Float) 8 51 51 51 51 51 51 179 63 true 170 192 34 4 2864 8 'statusBarField' 410 ##(Smalltalk.ReferenceView) 34 14 nil 2736 34 2 8 1140850688 131073 3232 nil 466 8 4278190080 nil 7 nil nil nil 3232 1180166 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteDebuggerMethodSourcePresenter) #resource_Default_view nil 786 138 144 34 1 850 #createAt:extent: 34 2 514 1 503 514 1569 493 3232 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 251 0 0 0 16 3 0 0 241 1 0 0] 2640 1088 nil 27 8 'codePane' nil 786 138 144 34 1 850 #createAt:extent: 34 2 514 1 51 514 1569 1033 2736 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 16 3 0 0 29 2 0 0] 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 2736 34 2 8 1140850688 131073 3680 nil 466 496 nil 7 nil nil nil 3680 2802 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 3680 34 2 8 1140850688 131073 3808 nil nil nil 7 nil nil nil 3808 546 170 176 34 6 410 ##(Smalltalk.PushButton) 34 20 nil 3808 34 2 8 1140924416 1 3920 nil nil nil 7 nil nil nil 3920 nil 8 4294904077 1426 #terminateProcess 8 'Terminate' 1 1 nil nil false nil nil nil 786 138 144 34 3 850 #createAt:extent: 34 2 514 719 1 514 141 51 3920 850 #isEnabled: 8 #(false) 3920 850 #text: 34 1 8 'Terminate' 3920 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 103 1 0 0 0 0 0 0 173 1 0 0 25 0 0 0] 8 #() 1088 nil 29 1106 1138 #fixedPreviousRight 1 1168 1 1184 1 1200 51 410 ##(Smalltalk.ListBox) 34 17 nil 3808 34 2 8 1144062209 1025 4304 590662 2 ##(Smalltalk.ListModel) 138 144 2640 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 466 496 nil 7 265030 4 ##(Smalltalk.Menu) nil true 34 3 984134 2 ##(Smalltalk.CommandMenuItem) 1 1426 #browseFrameMethod 8 '&Browse Frame Method' 1 1 nil nil nil 4514 1 1426 #browseImplementors 8 'Browse &Implementors' 1 1 nil nil nil 4514 1 1426 #browseSenders 8 'Browse &Senders' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 4304 nil 8 4294905131 ##(Smalltalk.BasicListAbstract) 2640 false 786 138 144 34 3 850 #createAt:extent: 34 2 514 1 51 514 859 443 4304 850 #contextMenu: 34 1 4480 4304 850 #horizontalExtent: 8 #(0) 4304 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 173 1 0 0 246 0 0 0] 8 #() 1088 nil 27 1106 1152 1 1168 1 1138 #fixedPreviousBottom 1 1138 #fixedParentBottom 1 410 ##(Smalltalk.ComboBox) 34 17 nil 3808 34 2 8 1412498947 1025 4976 4370 138 144 2640 nil 4432 466 8 4278190080 nil 7 nil nil nil 4976 nil 8 4294907479 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each printString]' 8 #[30 105 226 0 106] #printString 5136 7 257 nil 2640 401 786 138 144 34 1 850 #createAt:extent: 34 2 514 1 1 514 719 53 4976 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 103 1 0 0 26 0 0 0] 8 #() 1088 nil 27 1106 1152 1 1168 -139 1184 1 1200 47 170 192 34 4 4304 8 'frameList' 4976 8 'processList' nil 786 138 144 34 1 850 #createAt:extent: 34 2 514 1 1 514 859 493 3808 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 173 1 0 0 246 0 0 0] 34 3 4976 3920 4304 1088 nil 27 3 410 ##(Smalltalk.ContainerView) 34 15 nil 3680 34 2 8 1140850688 131073 5632 nil 466 496 nil 7 nil nil nil 5632 2802 170 176 34 4 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 5632 34 2 8 1174475012 1025 5760 674 nil false 720 nil 466 8 4278190080 nil 7 4466 nil true 34 20 4514 1 1426 #undo 8 '&Undo' 9397 1 nil nil nil 4514 1 1426 #redo 8 'R&edo' 9395 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 4514 1 1426 #editCut 8 'Cu&t' 9393 1 nil nil nil 4514 1 1426 #editCopy 8 '&Copy' 9351 1 nil nil nil 4514 1 1426 #editPaste 8 '&Paste' 9389 1 nil nil nil 4514 1 1426 #editDelete 8 'De&lete' 1629 1 nil nil nil 4514 1 1426 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 6002 4097 4514 1 1426 #editFind 8 '&Find...' 9357 1 nil nil nil 4514 1 1426 #editFindNext 8 'Find &Next' 9359 1 nil nil nil 4514 1 1426 #editReplace 8 '&Replace...' 9361 1 nil nil nil 6002 4097 4514 1 1426 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 4514 1 1426 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 4514 1 1426 #jadeExecute 8 'Execute' 9355 1 nil nil nil 4514 1 1426 #jadeDebug 8 'De&bug' 9349 1 nil nil nil 6002 4097 4514 1 1426 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 4514 1 1426 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 5760 nil 8 4294905095 754 nil nil 9 nil 170 192 34 8 #callTip 1182790 1 ##(Smalltalk.ScintillaTextStyle) 77 786694 ##(Smalltalk.IndexedColor) 33554457 6866 33554471 1 nil nil nil nil #callTip nil nil nil #indentGuide 6834 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #lineNumber 6834 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #normal 6834 1 nil nil 1 nil nil nil nil #normal nil nil nil 34 256 6944 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 6928 nil nil nil 6912 6848 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 1641542 1 ##(Smalltalk.ScintillaMarkerDefinition) nil nil nil nil 5760 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 2640 nil 170 176 2640 nil nil nil nil nil 6866 33554447 nil nil nil nil nil nil nil 1 170 192 2640 nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 6834 1027 nil 196934 1 ##(Smalltalk.RGB) 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 6834 1029 7186 60239 7186 31326207 1 nil nil nil nil #Warning nil nil nil #Error 6834 1031 7186 335 7186 31317503 1 nil nil nil nil #Error nil nil nil nil 786 138 144 34 8 850 #createAt:extent: 34 2 514 1 331 514 701 163 5760 850 #contextMenu: 34 1 5872 5760 850 #modificationEventMask: 8 #(3912191) 5760 850 #caretPeriod: 8 #(530) 5760 850 #wordWrap: 8 #(true) 5760 850 #margins: 34 1 34 5 985158 2 ##(Smalltalk.ScintillaMargin) 1 5760 1 3 nil nil nil nil 7602 3 5760 33 nil nil 67108863 nil nil 7602 5 5760 1 nil nil nil nil nil 7602 7 5760 1 nil nil nil nil nil 7602 9 5760 1 nil nil nil nil nil 5760 850 #canHScroll: 8 #(false) 5760 850 #maxCompletionListHeight: 8 #(9) 5760 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 165 0 0 0 94 1 0 0 246 0 0 0] 8 #() 1088 nil 29 3 410 ##(Smalltalk.ListView) 34 30 nil 5632 34 2 8 1140920397 1025 7808 4370 138 144 2640 nil 4432 466 496 nil 7 4466 nil true 34 2 4514 1 1426 #browseObjectClass 8 '&Browse Object Class' 1 1 nil nil nil 4514 1 1426 #inspectVariable 8 'Inspect' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 7808 nil 8 4294904535 ##(Smalltalk.BasicListAbstract) nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 3 920646 5 ##(Smalltalk.ListViewColumn) 8 'Variable' 201 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 5122 0 nil 5154 2 1 5120 8 'doIt' 8 '[:each | each key value]' 8 #[30 105 226 0 142 106] #key 8192 7 257 nil nil 7808 nil 1 nil nil 8146 8 'Value' 313 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 5122 0 459302 ##(Smalltalk.Context) 1 1 nil nil 5154 0 9 ##(Smalltalk.UndefinedObject) 8 'doIt' 34 2 8 '[:each | each value]' 34 1 138 ##(Smalltalk.PoolDictionary) 2640 8 #[252 1 0 1 1 5 0 17 229 32 142 106 105] 17 257 nil nil 7808 nil 3 nil nil 8146 8 'OOP' 181 #right 459270 ##(Smalltalk.Message) #displayString 8 #() 8498 #<= 8528 5122 0 nil 5154 3 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each key key asNumber]' 8 #[31 105 226 0 158 159 106] #key #asNumber 8560 7 257 nil nil 7808 nil 1 nil nil #report 2640 nil 131169 nil 34 4 nil nil 514 1 1 nil 786 138 144 34 3 850 #createAt:extent: 34 2 514 1 1 514 701 321 7808 850 #contextMenu: 34 1 7920 7808 850 #text: 34 1 8 'Variable' 7808 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 94 1 0 0 160 0 0 0] 8 #() 1088 nil 27 5 true 170 192 34 4 5760 8 'variableData' 7808 8 'variableList' nil 786 138 144 34 1 850 #createAt:extent: 34 2 514 869 1 514 701 493 5632 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 178 1 0 0 0 0 0 0 16 3 0 0 246 0 0 0] 34 3 7808 410 ##(Smalltalk.Splitter) 34 12 nil 5632 34 2 8 1140850688 1 9136 nil 466 496 nil 519 nil nil nil 9136 786 138 144 34 1 850 #createAt:extent: 34 2 514 1 321 514 701 11 9136 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 160 0 0 0 94 1 0 0 165 0 0 0] 8 #() 1088 nil 27 5760 1088 nil 27 524806 ##(Smalltalk.Fraction) 253 311 false 170 192 2640 nil 786 138 144 34 1 850 #createAt:extent: 34 2 514 1 1 514 1569 493 3680 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 3 0 0 246 0 0 0] 34 3 3808 410 ##(Smalltalk.Splitter) 34 12 nil 3680 34 2 8 1140850688 1 9584 nil 466 496 nil 519 nil nil nil 9584 786 138 144 34 1 850 #createAt:extent: 34 2 514 859 1 514 11 493 9584 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 173 1 0 0 0 0 0 0 178 1 0 0 246 0 0 0] 8 #() 1088 nil 27 5632 1088 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 2736 34 2 8 1140850688 1 9824 nil 466 496 nil 519 nil nil nil 9824 786 138 144 34 1 850 #createAt:extent: 34 2 514 1 493 514 1569 11 9824 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 246 0 0 0 16 3 0 0 251 0 0 0] 8 #() 1088 nil 27 3232 2864 1088 nil 27 1106 1152 1 1168 1 1184 51 4960 1 170 192 34 4 608 8 'errorMessage' 1216 8 'toolbar' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 2 4466 nil true 34 7 4514 1 1426 #saveMethod 8 '&Save' 9383 1 nil nil nil 4514 1 1426 #copyStack nil 1 1 nil nil nil 6002 4097 4514 1 1426 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 4514 1 1426 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 4514 1 1426 #jadeExecute 8 '&Execute' 9355 1 nil nil nil 4514 1 1426 #jadeDebug 8 'Debu&g' 9359 1 nil nil nil 8 '&Edit' nil 134217729 nil nil 30533 nil nil 4466 nil true 34 8 4514 1 1426 #showNextStatement 8 'Top of Stack' 1 1 1474 nil true 1520 8 'icons\TopOfStack2.ico' nil nil nil 4514 1 1426 #stepInto nil 1 1 1474 nil true 1520 8 'StepInto.ico' 1696 nil nil 4514 1 1426 #stepOver nil 1 1 1474 nil true 1520 8 'StepOver.ico' 1696 nil nil 4514 1 1426 #stepOut nil 1 1 1474 nil true 1520 8 'StepOut.ico' 1696 nil nil 4514 1 1426 #stepThrough nil 1 1 1474 nil true 1520 8 'bracket_down_arrow.ico' nil nil nil 4514 1 1426 #runToCursor nil 1 1 1474 nil true 1520 8 'RunToCursor.ico' 1696 nil nil 4514 1 1426 #resumeProcess 8 'Resume' 1 1 1474 nil true 1520 8 'Run.ico' 1696 nil nil 4514 1 1426 #restart nil 13545 1 1474 nil true 1520 8 'icons\ArrowCircle.ico' nil nil nil 8 '&Debug' nil 134217729 nil nil 30551 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 1474 nil true 1520 8 'bracket_down_arrow.ico' nil 1474 nil true 1520 8 'icons\GS16.ico' nil nil nil 1 nil nil 786 138 144 34 3 850 #createAt:extent: 34 2 514 7679 21 514 1601 1201 416 850 #text: 34 1 8 'Jade Debugger' 416 850 #updateMenuBar 2640 416 1026 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 31 18 0 0 98 2 0 0] 34 3 608 1216 2736 1088 nil 27 )!

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

