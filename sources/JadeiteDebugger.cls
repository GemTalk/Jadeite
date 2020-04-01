"Filed out from Dolphin Smalltalk 7"!

JadeDebugger subclass: #JadeiteDebugger
	instanceVariableNames: 'statusTextPresenter idleProcess idleProcessSemaphore search debuggerService'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: 'debuggerClass semaphore lastPosition'!
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
	^#(#(#raiseConsole 'Ctrl+F7') #(#reformatSource 'Ctrl+Shift+O'))!

basicSelectedFrame
	| index |
	(index := frameListPresenter selectionByIndex) = 0 ifTrue: [^nil].
	index := index + frameListOffset.
	^gsProcess frameForLevel: index!

browseFrameMethod
	| classService shell |
	frame homeMethodSelector ifNil: [^self	"block context"].
	classService := RowanClassService new name: frame homeMethodClassName.
	BrowserUpdate current updateService: classService session: gciSession.
	shell := JadeiteBrowser showOnSession: gciSession.
	shell currentCard updateAfterFindClass: classService.
	shell currentCard findMethod: frame homeMethodSelector.
	^shell!

browseImplementors
	^JadePresenter browseImplementorsOf: frame homeMethodSelector session: self gciSession!

browseObjectClass
	| shell classService |
	classService := RowanClassService new
				name: variableListPresenter selection className asString subStrings first.	"strip off 'class' if meta"
	BrowserUpdate current updateService: classService session: gciSession.
	shell := JadeiteBrowser showOnSession: gciSession.
	shell currentCard updateAfterFindClass: classService.
	^shell!

browseSelectedMethod
	"convenience menu item to display randomly grouped methods in a browser"

	| methodService browser |
	frame homeMethodSelector ifNil: [^self	"block context"].
	methodService := RowanMethodService new
				className: frame homeMethodClassName;
				selector: frame homeMethodSelector.
	BrowserUpdate current updateService: methodService session: gciSession.
	(browser := JadeiteMethodListBrowser showOnSession: gciSession) primaryPresenter
		methods: (Array with: methodService)
		selecting: nil.
	browser updateCaption: 'Selected Frame Method'.
	^browser!

browseSenders
	^JadePresenter browseSendersOf: frame homeMethodSelector session: self gciSession!

clearBreakPointsAt: stepPoint
	gsProcess frames do: 
			[:frameService |
			frameService method homeMethodOop = frame method homeMethodOop
				ifTrue: [frameService breaks remove: stepPoint ifAbsent: []]]!

codeSourcePresenterClass
	^JadeiteDebuggerMethodSourcePresenter!

contextObject
	^frame oop!

copyFrameString

	frameListPresenter selection copyToClipboard!

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
		when: #valueChanged
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

disableBreakpointsWhile: block
	| wereBreakpointsEnabled answeringService result |
	answeringService := RowanAnsweringService new.
	wereBreakpointsEnabled := answeringService breakPointsAreEnabled: self gciSession.
	answeringService setBreakpointsEnabled: false session: self gciSession.
	[result := block value]
		ensure: [answeringService setBreakpointsEnabled: wereBreakpointsEnabled session: self gciSession].
	^result!

displayUncompilableSourceIn: sourcePresenter
	sourcePresenter value size < 34 ifTrue: [^self].
	((sourcePresenter value copyFrom: 2 to: 34) = 'METHOD SOURCE CANNOT BE DISPLAYED')
		ifTrue: [sourcePresenter view backcolor: JadeiteTextStyles default colorForUndisplayableSource]!

displayVariables
	| variables sortedVariables receiver |
	variables := frame vars.
	sortedVariables := (variables reject: [:variableService | variableService _key = 'receiver'])
				asSortedCollection: [:x :y | (x _key asString _cmp: y _key asString) < 1].
	sortedVariables := sortedVariables asOrderedCollection.
	receiver := variables detect: [:variableService | variableService _key = 'receiver'] ifNone: [].
	receiver ifNotNil: [sortedVariables addFirst: receiver].
	variableListPresenter list: sortedVariables asArray!

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
	self registerWindow: self view handle rootObject: aProcess oopType.
	self disableBreakpointsWhile: 
			[
			[super
				initializeProcess: aProcess
				message: aString
				terminateOnClose: aBoolean]
					ensure: [self initializeIdleProcess]]!

isOkayToChangeFrame
	^codePane isOkayToChange!

jadeInspect
	| inspector | 
	inspector := JadeiteInspector new gciSession: gciSession.
	^inspector evaluateSelectedTextIn: self thenInspectInContext: self contextObject!

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
		backcolor: JadeiteTextStyles default colorForUnsavedEdits;
		clearContainerIndicators.
	self displayUncompilableSourceIn: codePane documentPresenter!

onCloseRequested: boolValueHolder
	self isOkayToChangeFrame ifFalse: [^self].
	self class lastPosition: self view position.
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
	super onViewClosed.
	self class lastPosition: self view position!

onViewDestroyed
	"Private - copied from RowanSystemBrowserPresenter>>onViewClosed"

	super onViewDestroyed.
	self terminateIdleProcess!

onViewOpened
	"Private - copied from RowanProjectsBrowserPresenter>>onViewOpened"

	super onViewOpened.
	self registerPresentersForUpdates.
	BrowserUpdate current logComment: 'Opening Debugger {' , self identityHash printString , '}'.
	self class lastPosition ifNotNil: [self view position: self class lastPosition. ]!

processListPresenter
	^processListPresenter!

queryCommand: query
	processList := processListPresenter list
				collect: [:each | GsProcess session: gciSession oopType: each oopType].
	(#(#browseFrameMethod #browseImplementors #browseSenders #browseSelectedMethod) includes: query commandSymbol)
		ifTrue: 
			[query isEnabled: frame homeMethodSelector notNil.
			^true].
	(#(#resumeProcess #runToCursor #stepInto #stepOut #stepOver) includes: query commandSymbol)
		ifTrue: 
			[query isEnabled: processListPresenter selectionByIndex == 1.
			^true].
	(#(#terminateProcess) includes: query commandSymbol)
		ifTrue: 
			[query isEnabled: (processList notEmpty and: [processList first ~~ gsProcess]).
			^true].
	(#(#implement) includes: query commandSymbol)
		ifTrue: 
			[query isEnabled: false.	"frameListPresenter model first subStrings first = 'MessageNotUnderstood'."
			^true].
	(#(#browseObjectClass) includes: query commandSymbol)
		ifTrue: 
			[query isEnabled: variableListPresenter hasSelection.
			^true].
	query commandSymbol == #saveMethod
		ifTrue: 
			[query isEnabled: documentPresenter view isModified.
			^true].
	(#(#copyFrameString) includes: query commandSymbol)
		ifTrue: 
			[query isEnabled: frameListPresenter hasSelection.
			^true].
	^super queryCommand: query!

reformatSource
	| methodService |
	methodService := self methodListSelection copy.
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
		backcolor: JadeiteTextStyles default colorForUnsavedEdits;
		clearContainerIndicators.
	statusTextPresenter view backcolor: statusTextPresenter view defaultBackcolor.
	self statusBarText: String new.
	^documentPresenter value!

refreshBreakPointsIn: methodSourcePresenter
	| breakPointSymbol indicators |
	breakPointSymbol := BrowserUpdate current breakpointsEnabled
				ifTrue: [#breakPoint]
				ifFalse: [#disabledBreakPoint].
	indicators := OrderedCollection new.
	methodSourcePresenter view indicators do: 
			[:indicator |
			(indicator styleName = #breakPoint or: [indicator styleName = #disabledBreakPoint])
				ifTrue: 
					[indicators add: (indicator copy
								setStyleName: breakPointSymbol
								range: indicator range
								tag: indicator tag)]
				ifFalse: [indicators add: indicator]].
	methodSourcePresenter view indicators: indicators.
	methodSourcePresenter view update!

registerPresentersForUpdates
	"copied from RowanProjectsBrowserPresenter>>registerPresentersForUpdates"

	BrowserUpdate current
		register: processListPresenter selector: #processListUpdate:;
		register: variableListPresenter
			selector: #updateVariable:debugger:
			browser: self.
	BrowserUpdate current
		register: documentPresenter
		selector: #debuggerMethodSourceUpdate:browser:
		browser: self!

restart
	self isOkayToChangeFrame ifFalse: [^self].
	(gsProcess gsProcessForSession: gciSession)
		trimStackToLevel: frameListPresenter selectionByIndex + frameListOffset.
	self getProcessList!

resumeProcess
	self isOkayToChangeFrame ifFalse: [^self].
	^super resumeProcess!

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
			[statusTextPresenter view backcolor: Color default.
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
	self displayVariables.
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
!JadeiteDebugger categoriesFor: #browseSelectedMethod!menu handlers!private! !
!JadeiteDebugger categoriesFor: #browseSenders!menu handlers!private! !
!JadeiteDebugger categoriesFor: #clearBreakPointsAt:!menu handlers support!public! !
!JadeiteDebugger categoriesFor: #codeSourcePresenterClass!private! !
!JadeiteDebugger categoriesFor: #contextObject!public! !
!JadeiteDebugger categoriesFor: #copyFrameString!menu handlers!private! !
!JadeiteDebugger categoriesFor: #createComponents!public! !
!JadeiteDebugger categoriesFor: #createSchematicWiring!public! !
!JadeiteDebugger categoriesFor: #debuggerService!accessing!private! !
!JadeiteDebugger categoriesFor: #disableBreakpointsWhile:!private! !
!JadeiteDebugger categoriesFor: #displayUncompilableSourceIn:!private! !
!JadeiteDebugger categoriesFor: #displayVariables!frames!private! !
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
!JadeiteDebugger categoriesFor: #jadeInspect!menu handlers!public! !
!JadeiteDebugger categoriesFor: #methodListSelection!accessing!public! !
!JadeiteDebugger categoriesFor: #methodSourcePresenter!public! !
!JadeiteDebugger categoriesFor: #methodValueChanged!event handlers!public! !
!JadeiteDebugger categoriesFor: #onCloseRequested:!event handlers!private! !
!JadeiteDebugger categoriesFor: #onIdleEntered!event handlers!private! !
!JadeiteDebugger categoriesFor: #onViewClosed!event handlers!private! !
!JadeiteDebugger categoriesFor: #onViewDestroyed!event handlers!private! !
!JadeiteDebugger categoriesFor: #onViewOpened!event handlers!private! !
!JadeiteDebugger categoriesFor: #processListPresenter!accessing!public! !
!JadeiteDebugger categoriesFor: #queryCommand:!menu handlers support!public! !
!JadeiteDebugger categoriesFor: #reformatSource!menu handlers!private! !
!JadeiteDebugger categoriesFor: #refreshBreakPointsIn:!public!updating! !
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

disableBreakpointsWhile: block session: session
	| wereBreakpointsEnabled answeringService result |
	answeringService := RowanAnsweringService new.
	wereBreakpointsEnabled := answeringService breakPointsAreEnabled: session.
	answeringService setBreakpointsEnabled: false session: session.
	[result := block value]
		ensure: [answeringService setBreakpointsEnabled: wereBreakpointsEnabled session: session].
	^result!

lastPosition
	^lastPosition!

lastPosition: anObject
	lastPosition := anObject!

openOn: gsProcess message: aString terminateOnClose: aBoolean
	^(self showOnSession: gsProcess gciSession)
		initializeProcess: gsProcess
			message: aString
			terminateOnClose: aBoolean;
		answer!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1601 1201 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 592 nil nil nil 7 nil nil nil 592 1180166 ##(Smalltalk.ProportionalLayout) 170 176 8 #() true 170 192 704 nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 1 51 498 1569 1033 592 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 16 3 0 0 29 2 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 592 34 2 8 1140850688 131073 944 nil 480 nil 7 nil nil nil 944 658 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 944 34 2 8 1140850688 131073 1056 nil nil nil 7 nil nil nil 1056 530 170 176 34 6 410 ##(Smalltalk.ComboBox) 34 17 nil 1056 34 2 8 1412498947 1025 1168 590662 2 ##(Smalltalk.ListModel) 138 144 704 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 nil nil nil 1168 nil 8 1650683072 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each printString]' 8 #[30 105 226 0 106] #printString 1344 7 257 nil 704 401 738 138 144 34 1 802 #createAt:extent: 34 2 498 1 1 498 719 51 1168 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 103 1 0 0 25 0 0 0] 8 #() 498 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 1650 #fixedParentRight -139 1650 #fixedParentTop 1 1650 #fixedViewTop 47 410 ##(Smalltalk.ListBox) 34 17 nil 1056 34 2 8 1144062209 1025 1728 1234 138 144 704 nil 1296 480 nil 7 265030 4 ##(Smalltalk.Menu) nil true 34 6 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #browseFrameMethod 8 '&Browse Frame Method' 1 1 nil nil nil 1874 1 1906 #browseImplementors 8 'Browse &Implementors' 1 1 nil nil nil 1874 1 1906 #browseSenders 8 'Browse &Senders' 1 1 nil nil nil 1874 1 1906 #browseSelectedMethod 8 'Browse Selected Method' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 1874 1 1906 #copyFrameString 8 'Copy' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 1728 nil 8 1650670432 ##(Smalltalk.BasicListAbstract) 704 false 738 138 144 34 3 802 #createAt:extent: 34 2 498 1 51 498 859 461 1728 802 #contextMenu: 34 1 1840 1728 802 #horizontalExtent: 8 #(0) 1728 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 173 1 0 0 255 0 0 0] 8 #() 1600 nil 27 1618 1664 1 1680 1 1650 #fixedPreviousBottom 1 1650 #fixedParentBottom 1 410 ##(Smalltalk.PushButton) 34 20 nil 1056 34 2 8 1140924416 1 2480 nil nil nil 7 nil nil nil 2480 nil 8 1650168896 1906 #terminateProcess 8 'Terminate' 1 1 nil nil false nil nil nil 738 138 144 34 3 802 #createAt:extent: 34 2 498 719 1 498 141 51 2480 802 #isEnabled: 8 #(false) 2480 802 #text: 34 1 8 'Terminate' 2480 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 103 1 0 0 0 0 0 0 173 1 0 0 25 0 0 0] 8 #() 1600 nil 29 1618 1650 #fixedPreviousRight 1 1680 1 1696 1 1712 51 170 192 34 4 1168 8 'processList' 1728 8 'frameList' nil 738 138 144 34 1 802 #createAt:extent: 34 2 498 1 1 498 859 511 1056 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 173 1 0 0 255 0 0 0] 34 3 1168 2480 1728 1600 nil 27 3 410 ##(Smalltalk.ContainerView) 34 15 nil 944 34 2 8 1140850688 131073 3088 nil 480 nil 7 nil nil nil 3088 658 170 176 34 4 410 ##(Smalltalk.ListView) 34 30 nil 3088 34 2 8 1140920397 1025 3200 1234 138 144 704 nil 1296 480 nil 7 1826 nil true 34 2 1874 1 1906 #browseObjectClass 8 '&Browse Object Class' 1 1 nil nil nil 1874 1 1906 #inspectVariable 8 'Inspect' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 3200 nil 8 1650059376 ##(Smalltalk.BasicListAbstract) nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 3 920646 5 ##(Smalltalk.ListViewColumn) 8 'Variable' 201 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 1330 0 nil 1362 2 1 1328 8 'doIt' 8 '[:each | each key value]' 8 #[30 105 226 0 142 106] #key 3568 7 257 nil nil 3200 nil 1 nil nil 3522 8 'Value' 313 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 1330 0 459302 ##(Smalltalk.Context) 1 1 nil nil 1362 0 9 ##(Smalltalk.UndefinedObject) 8 'doIt' 34 2 8 '[:each | each value]' 34 1 138 ##(Smalltalk.PoolDictionary) 704 8 #[252 1 0 1 1 5 0 17 229 32 142 106 105] 17 257 nil nil 3200 nil 3 nil nil 3522 8 'OOP' 181 #right 459270 ##(Smalltalk.Message) #displayString 8 #() 3874 #<= 3904 1330 0 nil 1362 3 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each key key asNumber]' 8 #[31 105 226 0 158 159 106] #key #asNumber 3936 7 257 nil nil 3200 nil 1 nil nil #report 704 nil 131169 nil 34 4 nil nil 498 1 1 nil 738 138 144 34 3 802 #createAt:extent: 34 2 498 1 1 498 701 333 3200 802 #contextMenu: 34 1 3296 3200 802 #text: 34 1 8 'Variable' 3200 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 94 1 0 0 166 0 0 0] 8 #() 1600 nil 27 5 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 3088 34 2 8 1174475012 1025 4288 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 480 nil 7 1826 nil true 34 20 1874 1 1906 #undo 8 '&Undo' 9397 1 nil nil nil 1874 1 1906 #redo 8 'R&edo' 9395 1 nil nil nil 2098 4097 1874 1 1906 #editCut 8 'Cu&t' 9393 1 nil nil nil 1874 1 1906 #editCopy 8 '&Copy' 9351 1 nil nil nil 1874 1 1906 #editPaste 8 '&Paste' 9389 1 nil nil nil 1874 1 1906 #editDelete 8 'De&lete' 1629 1 nil nil nil 1874 1 1906 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 2098 4097 1874 1 1906 #editFind 8 '&Find...' 9357 1 nil nil nil 1874 1 1906 #editFindNext 8 'Find &Next' 9359 1 nil nil nil 1874 1 1906 #editReplace 8 '&Replace...' 9361 1 nil nil nil 2098 4097 1874 1 1906 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 1874 1 1906 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 1874 1 1906 #jadeExecute 8 'Execute' 9355 1 nil nil nil 1874 1 1906 #jadeDebug 8 'De&bug' 9349 1 nil nil nil 2098 4097 1874 1 1906 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 1874 1 1906 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 4288 nil 8 1401475519 852486 ##(Smalltalk.NullConverter) nil nil 9 nil 170 192 34 8 #indentGuide 1182790 1 ##(Smalltalk.ScintillaTextStyle) 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #callTip 5378 77 466 #gray 466 #white 1 nil nil nil nil #callTip nil nil nil #normal 5378 1 nil nil 1 nil nil nil nil #normal nil nil nil #lineNumber 5378 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil 34 256 5456 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 5472 nil nil nil 5392 5408 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) nil nil nil nil 4288 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 704 nil 170 176 704 7824383 nil nil nil nil 466 #silver nil nil nil nil nil nil nil 1 170 192 704 nil nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 5378 1029 196934 1 ##(Smalltalk.RGB) 60239 5714 31326207 1 nil nil nil nil #Warning nil nil nil #Error 5378 1031 5714 335 5714 31317503 1 nil nil nil nil #Error nil nil nil #Notification 5378 1027 nil 5714 31185883 1 nil nil nil nil #Notification nil nil nil nil 738 138 144 34 9 802 #createAt:extent: 34 2 498 1 343 498 701 169 4288 802 #contextMenu: 34 1 4416 4288 802 #textLimit: 8 #(1073741823) 4288 802 #caretPeriod: 8 #(530) 4288 802 #wordWrap: 8 #(true) 4288 802 #margins: 34 1 34 5 985158 3 ##(Smalltalk.ScintillaMargin) 1 4288 1 3 nil nil nil nil 6130 3 4288 33 nil nil 67108863 nil nil 6130 5 4288 1 nil nil nil nil nil 6130 7 4288 1 nil nil nil nil nil 6130 9 4288 1 nil nil nil nil nil 4288 802 #canHScroll: 8 #(false) 4288 802 #maxCompletionListHeight: 8 #(9) 4288 802 #edgeColumn: 8 #(1) 4288 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 171 0 0 0 94 1 0 0 255 0 0 0] 8 #() 1600 nil 29 3 true 170 192 34 4 3200 8 'variableList' 4288 8 'variableData' nil 738 138 144 34 1 802 #createAt:extent: 34 2 498 869 1 498 701 511 3088 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 178 1 0 0 0 0 0 0 16 3 0 0 255 0 0 0] 34 3 3200 410 ##(Smalltalk.Splitter) 34 12 nil 3088 34 2 8 1140850688 1 6592 nil 480 nil 519 nil nil nil 1510470 1 ##(Smalltalk.DraggableViewInteractor) 6592 nil 1 #left nil nil nil 498 1 1 498 9 9 nil 6688 nil 738 138 144 34 1 802 #createAt:extent: 34 2 498 1 333 498 701 11 6592 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 166 0 0 0 94 1 0 0 171 0 0 0] 8 #() 1600 nil 27 4288 1600 nil 27 524806 ##(Smalltalk.Fraction) 253 311 false 170 192 704 nil 738 138 144 34 1 802 #createAt:extent: 34 2 498 1 1 498 1569 511 944 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 3 0 0 255 0 0 0] 34 3 1056 410 ##(Smalltalk.Splitter) 34 12 nil 944 34 2 8 1140850688 1 7088 nil 480 nil 519 nil nil nil 6658 7088 nil 1 #left nil nil nil 6688 6704 nil 6688 nil 738 138 144 34 1 802 #createAt:extent: 34 2 498 859 1 498 11 511 7088 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 173 1 0 0 0 0 0 0 178 1 0 0 255 0 0 0] 8 #() 1600 nil 27 3088 1600 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 592 34 2 8 1140850688 1 7328 nil 480 nil 519 nil nil nil 6658 7328 nil 1 #left nil nil nil 6688 6704 nil 6688 nil 738 138 144 34 1 802 #createAt:extent: 34 2 498 1 511 498 1569 11 7328 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 255 0 0 0 16 3 0 0 4 1 0 0] 8 #() 1600 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 592 34 2 8 1140850688 393217 7568 nil nil nil 7 nil nil nil 7568 530 170 176 34 4 410 ##(Smalltalk.TextEdit) 34 16 nil 7568 34 2 8 1140916352 1 7680 nil 480 nil 519 nil nil nil 7680 nil 8 1650007552 5314 nil nil 3 738 138 144 34 1 802 #createAt:extent: 34 2 498 1 469 498 1565 41 7680 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 234 0 0 0 14 3 0 0 254 0 0 0] 8 #() 1600 nil 27 1618 1664 1 1680 1 2464 -39 2464 1 410 ##(Smalltalk.ReferenceView) 34 14 nil 7568 34 2 8 1140850688 131073 7952 nil 480 nil 7 nil nil nil 7952 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteDebuggerMethodSourcePresenter) #resource_Default_view nil 738 138 144 34 1 802 #createAt:extent: 34 2 498 1 1 498 1565 469 7952 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 14 3 0 0 234 0 0 0] 704 1600 nil 27 1618 1664 1 1680 1 1696 1 2464 -39 170 192 34 4 7680 8 'statusBarField' 7952 8 'codePane' nil 738 138 144 34 1 802 #createAt:extent: 34 2 498 1 521 498 1569 513 7568 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 4 1 0 0 16 3 0 0 4 2 0 0] 34 2 7952 7680 1600 nil 27 1600 nil 27 1618 1664 1 1680 1 1696 51 2464 1 410 ##(Smalltalk.TextEdit) 34 16 nil 416 34 2 8 1140850816 1 8448 4354 nil false 4400 nil nil nil 7 nil nil nil 8448 nil 8 1650007552 5314 nil nil 3 738 138 144 34 3 802 #createAt:extent: 34 2 498 335 9 498 1231 41 8448 802 #text: 34 1 8 'Static Text' 8448 802 #setMarginWidths: 34 1 8 #(3 3) 8448 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 167 0 0 0 4 0 0 0 14 3 0 0 24 0 0 0] 8 #() 1600 nil 27 1618 1664 335 1680 -3 1696 9 1712 41 410 ##(Smalltalk.ToolbarA) 34 25 nil 416 34 2 8 1140853580 131137 8832 nil 480 nil 519 nil nil nil 8832 480 8 1650109728 nil 170 192 34 14 50541 1115206 1 ##(Smalltalk.ToolbarIconButton) 8832 1 1906 #restart 8 'Restart' 13545 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons\ArrowCircle.ico' nil 50541 50537 8946 8832 1 1906 #stepOut 8 'Step Out' 1 1 9010 nil true 9056 8 'StepOut.ico' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil 50537 50533 8946 8832 1 1906 #stepOver 8 'Step Over' 1 1 9010 nil true 9056 8 'StepOver.ico' 9184 50533 50529 8946 8832 1 1906 #showNextStatement 8 'Top Of Stack' 1 1 9010 nil true 9056 8 'icons\TopOfStack2.ico' nil 50529 50539 8946 8832 1 1906 #resumeProcess 8 'Go' 1 1 9010 nil true 9056 8 'Run.ico' 9184 50539 50535 8946 8832 1 1906 #stepThrough 8 'Step Through' 1 1 9010 nil true 9056 8 'icons\bracket_down_arrow.ico' nil 50535 50531 8946 8832 1 1906 #stepInto 8 'Step Into' 1 1 9010 nil true 9056 8 'StepInto.ico' 9184 50531 34 7 9296 9536 9216 9456 9088 9376 8960 nil nil 1 nil 498 33 33 498 45 45 nil nil 738 138 144 34 2 802 #createAt:extent: 34 2 498 5 1 498 331 49 8832 802 #updateSizePosted 704 8832 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 2 0 0 0 0 0 0 0 167 0 0 0 24 0 0 0] 8 #() 1600 nil 27 1618 1664 5 1650 #fixedViewLeft 331 1696 1 1712 49 170 192 34 4 8448 8 'errorMessage' 8832 8 'toolbar' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 2 1826 nil true 34 7 1874 1 1906 #saveMethod 8 '&Save' 9383 1 nil nil nil 1874 1 1906 #copyStack nil 1 1 nil nil nil 2098 4097 1874 1 1906 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 1874 1 1906 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 1874 1 1906 #jadeExecute 8 '&Execute' 9355 1 nil nil nil 1874 1 1906 #jadeDebug 8 'Debu&g' 9359 1 nil nil nil 8 '&Edit' nil 134217729 nil nil 50511 nil nil 1826 nil true 34 7 1874 1 1906 #showNextStatement 8 'Top of Stack' 1 1 9010 nil true 9056 8 'icons\TopOfStack2.ico' nil nil nil 1874 1 1906 #stepInto nil 9461 1 9010 nil true 9056 8 'StepInto.ico' 9184 nil nil 1874 1 1906 #stepOver nil 9459 1 9010 nil true 9056 8 'StepOver.ico' 9184 nil nil 1874 1 1906 #stepThrough nil 13555 1 9010 nil true 9056 8 'icons\bracket_down_arrow.ico' nil nil nil 1874 1 1906 #stepOut nil 13557 1 9010 nil true 9056 8 'StepOut.ico' 9184 nil nil 1874 1 1906 #resumeProcess 8 'Resume' 9449 1 9010 nil true 9056 8 'Run.ico' 9184 nil nil 1874 1 1906 #restart nil 13545 1 9010 nil true 9056 8 'icons\ArrowCircle.ico' nil nil nil 8 '&Debug' nil 134217729 nil nil 50527 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 9010 nil true 9056 8 'bracket_down_arrow.ico' nil 9010 nil true 9056 8 'icons\GS16.ico' nil nil nil 1 nil nil 738 138 144 34 3 802 #createAt:extent: 34 2 498 2879 21 498 1601 1201 416 802 #text: 34 1 8 'Jade Debugger' 416 802 #updateMenuBar 704 416 882 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 159 5 0 0 10 0 0 0 191 8 0 0 98 2 0 0] 34 3 8448 8832 592 1600 nil 27 )!

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
!JadeiteDebugger class categoriesFor: #disableBreakpointsWhile:session:!private! !
!JadeiteDebugger class categoriesFor: #lastPosition!accessing!private! !
!JadeiteDebugger class categoriesFor: #lastPosition:!accessing!private! !
!JadeiteDebugger class categoriesFor: #openOn:message:terminateOnClose:!public! !
!JadeiteDebugger class categoriesFor: #resource_Default_view!public!resources-views! !
!JadeiteDebugger class categoriesFor: #semaphore!public! !
!JadeiteDebugger class categoriesFor: #semaphore:!public! !
!JadeiteDebugger class categoriesFor: #signalSemaphore!public! !

