"Filed out from Dolphin Smalltalk 7"!

JadeDebugger subclass: #JadeiteDebugger
	instanceVariableNames: 'statusTextPresenter idleProcess idleProcessSemaphore search debuggerService'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: 'debuggerClass semaphore lastPosition lastExtent'!
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
	^#(#(#raiseConsole 'Ctrl+F7') #(#reformatSource 'Ctrl+Shift+O') #(#jadeDebug 'Ctrl+B'))!

basicSelectedFrame
	| index |
	(index := frameListPresenter selectionByIndex) = 0 ifTrue: [^nil].
	index := index + frameListOffset.
	^gsProcess frameForLevel: index!

browseFrameMethod
	| classService shell |
	frame homeMethodSelector ifNil: [^self	"block context"].
	classService := self classServiceFromFrame.
	BrowserUpdate current updateService: classService session: gciSession.
	shell := JadeiteBrowser showOnSession: gciSession.
	shell currentCard updateAfterFindClass: classService.
	classService meta ifTrue: [shell currentCard selectClassTab].
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

	| methodService browser classService |
	frame homeMethodSelector ifNil: [^self	"block context"].
	classService := self classServiceFromFrame.
	methodService := RowanMethodService new
				className: classService name;
				meta: classService meta;
				selector: frame homeMethodSelector.
	BrowserUpdate current updateService: methodService session: gciSession.
	(browser := JadeiteMethodListBrowser showOnSession: gciSession) primaryPresenter
		methods: (Array with: methodService)
		selecting: nil.
	browser updateCaption: 'Selected Frame Method'.
	^browser!

browseSenders
	^JadePresenter browseSendersOf: frame homeMethodSelector session: self gciSession!

classServiceFromFrame
	| classService homeClassName isMeta |
	classService := RowanClassService new.
	homeClassName := frame homeMethodClassName.
	homeClassName size < 6
		ifTrue: [isMeta := false]
		ifFalse: [isMeta := (homeClassName last: 6) = ' class'	"don't yet have meta info for frames"].
	homeClassName := isMeta
				ifTrue: [homeClassName copyFrom: 1 to: homeClassName size - 6]
				ifFalse: [homeClassName].
	classService
		name: homeClassName;
		meta: isMeta.
	^classService!

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
		ifTrue: [processListPresenter selection: debuggerService processes first].!

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
	self class lastPosition: self view position.
	self class lastExtent: self view extent.
	super onViewClosed.
!

onViewDestroyed
	"Private - copied from RowanSystemBrowserPresenter>>onViewClosed"

	super onViewDestroyed.
	self terminateIdleProcess!

onViewOpened
	"Private - copied from RowanProjectsBrowserPresenter>>onViewOpened"

	super onViewOpened.
	self registerPresentersForUpdates.
	BrowserUpdate current logComment: 'Opening Debugger {' , self identityHash printString , '}'.
	self class lastPosition ifNotNil: [self view position: self class lastPosition].
	self class lastExtent ifNotNil: [self view extent: self class lastExtent]!

printOn: stream
	super printOn: stream.
	stream
		nextPutAll: ' <identityHash: ';
		nextPutAll: self identityHash printString;
		nextPutAll: '>'!

processListPresenter
	^processListPresenter!

queryCommand: query
	processList := processListPresenter list
				collect: [:each | GsProcess session: gciSession oopType: each oopType].
	(#(#browseFrameMethod #browseImplementors #browseSenders #browseSelectedMethod)
		includes: query commandSymbol)
			ifTrue: 
				[query isEnabled: (frame homeMethodSelector notNil and: [frame classIsResolvable]).
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

selectedProcess
	processListPresenter selectionOrNil ifNil: [^self].
	self clearUI.
	gsProcess := processListPresenter selectionOrNil.
	gsProcess stack isEmpty
		ifTrue: [BrowserUpdate current updateService: gsProcess session: self gciSession].
	self stack: gsProcess stack!

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
!JadeiteDebugger categoriesFor: #classServiceFromFrame!menu handlers support!public! !
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
!JadeiteDebugger categoriesFor: #printOn:!accessing!public! !
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
!JadeiteDebugger categoriesFor: #selectedProcess!public! !
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

lastExtent
	^lastExtent!

lastExtent: anObject
	lastExtent := anObject!

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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1601 1201 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.TextEdit) 34 16 nil 416 34 2 8 1140850816 1 592 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 7 nil nil nil 592 nil 8 1650007552 852486 ##(Smalltalk.NullConverter) nil nil 3 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 335 9 498 1231 41 592 834 #text: 34 1 8 'Static Text' 592 834 #setMarginWidths: 34 1 8 #(3 3) 592 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 167 0 0 0 4 0 0 0 14 3 0 0 24 0 0 0] 8 #() 498 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 335 1122 #fixedParentRight -3 1122 #fixedParentTop 9 1122 #fixedViewTop 41 410 ##(Smalltalk.ToolbarA) 34 25 nil 416 34 2 8 1140853580 131137 1200 nil 480 nil 519 nil nil nil 1200 480 8 1650109728 nil 170 192 34 14 49717 1115206 1 ##(Smalltalk.ToolbarIconButton) 1200 1 1180998 4 ##(Smalltalk.CommandDescription) #restart 8 'Restart' 13545 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons\ArrowCircle.ico' nil 49717 49713 1314 1200 1 1346 #stepOut 8 'Step Out' 1 1 1394 nil true 1440 8 'StepOut.ico' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil 49713 49709 1314 1200 1 1346 #stepOver 8 'Step Over' 1 1 1394 nil true 1440 8 'StepOver.ico' 1568 49709 49705 1314 1200 1 1346 #showNextStatement 8 'Top Of Stack' 1 1 1394 nil true 1440 8 'icons\TopOfStack2.ico' nil 49705 49715 1314 1200 1 1346 #resumeProcess 8 'Go' 1 1 1394 nil true 1440 8 'Run.ico' 1568 49715 49711 1314 1200 1 1346 #stepThrough 8 'Step Through' 1 1 1394 nil true 1440 8 'icons\bracket_down_arrow.ico' nil 49711 49707 1314 1200 1 1346 #stepInto 8 'Step Into' 1 1 1394 nil true 1440 8 'StepInto.ico' 1568 49707 34 7 1680 1920 1600 1840 1472 1760 1328 nil nil 1 nil 498 33 33 498 45 45 nil nil 770 138 144 34 2 834 #createAt:extent: 34 2 498 5 1 498 331 49 1200 834 #updateSizePosted 8 #() 1200 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 2 0 0 0 0 0 0 0 167 0 0 0 24 0 0 0] 8 #() 1072 nil 27 1090 1136 5 1122 #fixedViewLeft 331 1168 1 1184 49 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 2272 nil nil nil 7 nil nil nil 2272 1180166 ##(Smalltalk.ProportionalLayout) 170 176 2176 true 170 192 2176 nil 770 138 144 34 1 834 #createAt:extent: 34 2 498 1 51 498 1569 1033 2272 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 16 3 0 0 29 2 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 2272 34 2 8 1140850688 131073 2560 nil 480 nil 7 nil nil nil 2560 2338 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 2560 34 2 8 1140850688 131073 2672 nil nil nil 7 nil nil nil 2672 530 170 176 34 6 410 ##(Smalltalk.PushButton) 34 20 nil 2672 34 2 8 1140924416 1 2784 nil nil nil 7 nil nil nil 2784 nil 8 1650168896 1346 #terminateProcess 8 'Terminate' 1 1 nil nil false nil nil nil 770 138 144 34 3 834 #createAt:extent: 34 2 498 719 1 498 141 51 2784 834 #isEnabled: 8 #(false) 2784 834 #text: 34 1 8 'Terminate' 2784 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 103 1 0 0 0 0 0 0 173 1 0 0 25 0 0 0] 8 #() 1072 nil 29 1090 1122 #fixedPreviousRight 1 1152 1 1168 1 1168 51 410 ##(Smalltalk.ListBox) 34 17 nil 2672 34 2 8 1144062209 1025 3168 590662 2 ##(Smalltalk.ListModel) 138 144 2176 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 265030 4 ##(Smalltalk.Menu) nil true 34 6 984134 2 ##(Smalltalk.CommandMenuItem) 1 1346 #browseFrameMethod 8 '&Browse' 1 1 nil nil nil 3362 1 1346 #browseImplementors 8 'Browse &Implementors' 1 1 nil nil nil 3362 1 1346 #browseSenders 8 'Browse &Senders' 1 1 nil nil nil 3362 1 1346 #browseSelectedMethod 8 'Browse Selected Method' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 3362 1 1346 #copyFrameString 8 'Copy' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 3168 nil 8 1650670432 ##(Smalltalk.BasicListAbstract) 2176 false 770 138 144 34 3 834 #createAt:extent: 34 2 498 1 51 498 859 461 3168 834 #contextMenu: 34 1 3328 3168 834 #horizontalExtent: 8 #(0) 3168 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 173 1 0 0 255 0 0 0] 8 #() 1072 nil 27 1090 1136 1 1152 1 1168 51 1122 #fixedParentBottom 1 410 ##(Smalltalk.ComboBox) 34 17 nil 2672 34 2 8 1412498947 1025 3936 3234 138 144 2176 nil 3296 480 nil 7 nil nil nil 3936 nil 8 1650683072 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each printString]' 8 #[30 105 226 0 106] #printString 4064 7 257 nil 2176 401 770 138 144 34 1 834 #createAt:extent: 34 2 498 1 1 498 719 51 3936 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 103 1 0 0 25 0 0 0] 8 #() 1072 nil 27 1090 1136 1 1152 -139 1168 1 1168 51 170 192 34 4 3168 8 'frameList' 3936 8 'processList' nil 770 138 144 34 1 834 #createAt:extent: 34 2 498 1 1 498 859 511 2672 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 173 1 0 0 255 0 0 0] 34 3 3168 3936 2784 1072 nil 27 3 410 ##(Smalltalk.ContainerView) 34 15 nil 2560 34 2 8 1140850688 131073 4560 nil 480 nil 7 nil nil nil 4560 2338 170 176 34 4 410 ##(Smalltalk.ListView) 34 30 nil 4560 34 2 8 1140920397 1025 4672 3234 138 144 2176 nil 3296 480 nil 7 3314 nil true 34 2 3362 1 1346 #browseObjectClass 8 '&Browse Object Class' 1 1 nil nil nil 3362 1 1346 #inspectVariable 8 'Inspect' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 4672 nil 8 1650059376 ##(Smalltalk.BasicListAbstract) nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 3 920646 5 ##(Smalltalk.ListViewColumn) 8 'Variable' 201 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 4050 0 nil 4082 2 1 4048 8 'doIt' 8 '[:each | each key value]' 8 #[30 105 226 0 142 106] #key 5040 7 257 nil nil 4672 nil 1 nil nil 4994 8 'Value' 313 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 4050 0 459302 ##(Smalltalk.Context) 1 1 nil nil 4082 0 9 ##(Smalltalk.UndefinedObject) 8 'doIt' 34 2 8 '[:each | each value]' 34 1 138 ##(Smalltalk.PoolDictionary) 2176 8 #[252 1 0 1 1 5 0 17 229 32 142 106 105] 17 257 nil nil 4672 nil 3 nil nil 4994 8 'OOP' 181 #right 459270 ##(Smalltalk.Message) #displayString 8 #() 5346 #<= 5376 4050 0 nil 4082 3 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each key key asNumber]' 8 #[31 105 226 0 158 159 106] #key #asNumber 5408 7 257 nil nil 4672 nil 1 nil nil #report 2176 nil 131169 nil 34 4 nil nil 498 1 1 nil 770 138 144 34 3 834 #createAt:extent: 34 2 498 1 1 498 701 333 4672 834 #contextMenu: 34 1 4768 4672 834 #text: 34 1 8 'Variable' 4672 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 94 1 0 0 166 0 0 0] 8 #() 1072 nil 27 5 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 4560 34 2 8 1174475012 1025 5760 658 nil false 704 nil 480 nil 7 3314 nil true 34 20 3362 1 1346 #undo 8 '&Undo' 9397 1 nil nil nil 3362 1 1346 #redo 8 'R&edo' 9395 1 nil nil nil 3570 4097 3362 1 1346 #editCut 8 'Cu&t' 9393 1 nil nil nil 3362 1 1346 #editCopy 8 '&Copy' 9351 1 nil nil nil 3362 1 1346 #editPaste 8 '&Paste' 9389 1 nil nil nil 3362 1 1346 #editDelete 8 'De&lete' 1629 1 nil nil nil 3362 1 1346 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 3570 4097 3362 1 1346 #editFind 8 '&Find...' 9357 1 nil nil nil 3362 1 1346 #editFindNext 8 'Find &Next' 9359 1 nil nil nil 3362 1 1346 #editReplace 8 '&Replace...' 9361 1 nil nil nil 3570 4097 3362 1 1346 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 3362 1 1346 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 3362 1 1346 #jadeExecute 8 'Execute' 9355 1 nil nil nil 3362 1 1346 #jadeDebug 8 'De&bug' 9349 1 nil nil nil 3570 4097 3362 1 1346 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 3362 1 1346 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 5760 nil 8 1594806719 738 nil nil 9 nil 170 192 34 8 #indentGuide 1182790 1 ##(Smalltalk.ScintillaTextStyle) 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #callTip 6786 77 466 #gray 466 #white 1 nil nil nil nil #callTip nil nil nil #normal 6786 1 nil nil 1 nil nil nil nil #normal nil nil nil #lineNumber 6786 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil 34 256 6864 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 6880 nil nil nil 6800 6816 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) nil nil nil nil 5760 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 2176 nil 170 176 2176 7824383 nil nil nil nil 466 #silver nil nil nil nil nil nil nil 1 170 192 2176 nil nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 6786 1029 196934 1 ##(Smalltalk.RGB) 60239 7122 31326207 1 nil nil nil nil #Warning nil nil nil #Error 6786 1031 7122 335 7122 31317503 1 nil nil nil nil #Error nil nil nil #Notification 6786 1027 nil 7122 31185883 1 nil nil nil nil #Notification nil nil nil nil 770 138 144 34 9 834 #createAt:extent: 34 2 498 1 343 498 701 169 5760 834 #contextMenu: 34 1 5840 5760 834 #textLimit: 8 #(1073741823) 5760 834 #caretPeriod: 8 #(530) 5760 834 #wordWrap: 8 #(true) 5760 834 #margins: 34 1 34 5 985158 3 ##(Smalltalk.ScintillaMargin) 1 5760 1 3 nil nil nil nil 7538 3 5760 33 nil nil 67108863 nil nil 7538 5 5760 1 nil nil nil nil nil 7538 7 5760 1 nil nil nil nil nil 7538 9 5760 1 nil nil nil nil nil 5760 834 #canHScroll: 8 #(false) 5760 834 #maxCompletionListHeight: 8 #(9) 5760 834 #edgeColumn: 8 #(1) 5760 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 171 0 0 0 94 1 0 0 255 0 0 0] 8 #() 1072 nil 29 3 true 170 192 34 4 4672 8 'variableList' 5760 8 'variableData' nil 770 138 144 34 1 834 #createAt:extent: 34 2 498 869 1 498 701 511 4560 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 178 1 0 0 0 0 0 0 16 3 0 0 255 0 0 0] 34 3 4672 410 ##(Smalltalk.Splitter) 34 12 nil 4560 34 2 8 1140850688 1 8000 nil 480 nil 519 nil nil nil 1510470 1 ##(Smalltalk.DraggableViewInteractor) 8000 nil 1 #left nil nil nil 498 1 1 498 9 9 nil 8096 nil 770 138 144 34 1 834 #createAt:extent: 34 2 498 1 333 498 701 11 8000 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 166 0 0 0 94 1 0 0 171 0 0 0] 8 #() 1072 nil 27 5760 1072 nil 27 524806 ##(Smalltalk.Fraction) 253 311 false 170 192 2176 nil 770 138 144 34 1 834 #createAt:extent: 34 2 498 1 1 498 1569 511 2560 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 3 0 0 255 0 0 0] 34 3 2672 410 ##(Smalltalk.Splitter) 34 12 nil 2560 34 2 8 1140850688 1 8496 nil 480 nil 519 nil nil nil 8066 8496 nil 1 #left nil nil nil 8096 8112 nil 8096 nil 770 138 144 34 1 834 #createAt:extent: 34 2 498 859 1 498 11 511 8496 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 173 1 0 0 0 0 0 0 178 1 0 0 255 0 0 0] 8 #() 1072 nil 27 4560 1072 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 2272 34 2 8 1140850688 1 8736 nil 480 nil 519 nil nil nil 8066 8736 nil 1 #left nil nil nil 8096 8112 nil 8096 nil 770 138 144 34 1 834 #createAt:extent: 34 2 498 1 511 498 1569 11 8736 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 255 0 0 0 16 3 0 0 4 1 0 0] 8 #() 1072 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 2272 34 2 8 1140850688 393217 8976 nil nil nil 7 nil nil nil 8976 530 170 176 34 4 410 ##(Smalltalk.TextEdit) 34 16 nil 8976 34 2 8 1140916352 1 9088 nil 480 nil 519 nil nil nil 9088 nil 8 1650007552 738 nil nil 3 770 138 144 34 1 834 #createAt:extent: 34 2 498 1 469 498 1565 41 9088 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 234 0 0 0 14 3 0 0 254 0 0 0] 8 #() 1072 nil 27 1090 1136 1 1152 1 3920 -39 3920 1 410 ##(Smalltalk.ReferenceView) 34 14 nil 8976 34 2 8 1140850688 131073 9360 nil 480 nil 7 nil nil nil 9360 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteDebuggerMethodSourcePresenter) #resource_Default_view nil 770 138 144 34 1 834 #createAt:extent: 34 2 498 1 1 498 1565 469 9360 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 14 3 0 0 234 0 0 0] 2176 1072 nil 27 1090 1136 1 1152 1 1168 1 3920 -39 170 192 34 4 9088 8 'statusBarField' 9360 8 'codePane' nil 770 138 144 34 1 834 #createAt:extent: 34 2 498 1 521 498 1569 513 8976 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 4 1 0 0 16 3 0 0 4 2 0 0] 34 2 9360 9088 1072 nil 27 1072 nil 27 1090 1136 1 1152 1 1168 51 3920 1 170 192 34 4 592 8 'errorMessage' 1200 8 'toolbar' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 2 3314 nil true 34 7 3362 1 1346 #saveMethod 8 '&Save' 9383 1 nil nil nil 3362 1 1346 #copyStack nil 1 1 nil nil nil 3570 4097 3362 1 1346 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 3362 1 1346 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 3362 1 1346 #jadeExecute 8 '&Execute' 9355 1 nil nil nil 3362 1 1346 #jadeDebug 8 'Debu&g' 9359 1 nil nil nil 8 '&Edit' nil 134217729 nil nil 49687 nil nil 3314 nil true 34 7 3362 1 1346 #showNextStatement 8 'Top of Stack' 1 1 1394 nil true 1440 8 'icons\TopOfStack2.ico' nil nil nil 3362 1 1346 #stepInto nil 9461 1 1394 nil true 1440 8 'StepInto.ico' 1568 nil nil 3362 1 1346 #stepOver nil 9459 1 1394 nil true 1440 8 'StepOver.ico' 1568 nil nil 3362 1 1346 #stepThrough nil 13555 1 1394 nil true 1440 8 'icons\bracket_down_arrow.ico' nil nil nil 3362 1 1346 #stepOut nil 13557 1 1394 nil true 1440 8 'StepOut.ico' 1568 nil nil 3362 1 1346 #resumeProcess 8 'Resume' 9449 1 1394 nil true 1440 8 'Run.ico' 1568 nil nil 3362 1 1346 #restart nil 13545 1 1394 nil true 1440 8 'icons\ArrowCircle.ico' nil nil nil 8 '&Debug' nil 134217729 nil nil 49703 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 1394 nil true 1440 8 'bracket_down_arrow.ico' nil 1394 nil true 1440 8 'icons\GS16.ico' nil nil nil 1 nil nil 770 138 144 34 3 834 #createAt:extent: 34 2 498 2879 21 498 1601 1201 416 834 #text: 34 1 8 'Jade Debugger' 416 834 #updateMenuBar 2176 416 1010 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 159 5 0 0 10 0 0 0 191 8 0 0 98 2 0 0] 34 3 592 1200 2272 1072 nil 27 )!

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
!JadeiteDebugger class categoriesFor: #lastExtent!accessing!private! !
!JadeiteDebugger class categoriesFor: #lastExtent:!accessing!private! !
!JadeiteDebugger class categoriesFor: #lastPosition!accessing!private! !
!JadeiteDebugger class categoriesFor: #lastPosition:!accessing!private! !
!JadeiteDebugger class categoriesFor: #openOn:message:terminateOnClose:!public! !
!JadeiteDebugger class categoriesFor: #resource_Default_view!public!resources-views! !
!JadeiteDebugger class categoriesFor: #semaphore!public! !
!JadeiteDebugger class categoriesFor: #semaphore:!public! !
!JadeiteDebugger class categoriesFor: #signalSemaphore!public! !

