"Filed out from Dolphin Smallalk"!

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
	^super additionalAccelerators , #(#(#reformatSource 'Ctrl+Shift+O') #(#jadeDebug 'Ctrl+B'))!

basicSelectedFrame
	| index |
	(index := frameListPresenter selectionByIndex) = 0 ifTrue: [^nil].
	index := index + frameListOffset.
	^gsProcess frameForLevel: index!

browseFrameMethod
	| classService shell |
	frame homeMethodSelector ifNil: [^self	"block context"].
	frame classIsResolvable ifFalse: [^self].
	classService := self classServiceFromFrame.
	BrowserUpdate current updateService: classService session: gciSession.
	shell := JadeiteBrowser showOnSession: gciSession.
	shell currentCard updateAfterFindClass: classService.
	classService meta ifTrue: [shell currentCard selectClassTab].
	shell currentCard findMethod: frame homeMethodSelector.
	^shell!

browseFrameMethodInExistingBrowser
	| classService shell |
	frame homeMethodSelector ifNil: [^self	"block context"].
	frame classIsResolvable ifFalse: [^self].
	classService := self classServiceFromFrame.
	BrowserUpdate current updateService: classService session: gciSession.
	shell := JadeiteBrowser allInstances detect: [:presenter | presenter isOpen] ifNone: [].
	shell := shell ifNil: [JadeiteBrowser showOnSession: gciSession] ifNotNil: [shell addSystemBrowser].
	shell currentCard updateAfterFindClass: classService.
	classService meta ifTrue: [shell currentCard selectClassTab].
	shell currentCard findMethod: frame homeMethodSelector.
	shell view setFocus.
	^shell!

browseImplementors
	^JadePresenter browseImplementorsOf: frame homeMethodSelector session: self gciSession!

browseObjectClass
	| shell classService selection |
	(selection := variableListPresenter selection) isDisplayLabel ifTrue: [^self].
	classService := RowanClassService new name: selection className asString subStrings first.	"strip off 'class' if meta"
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
	| variables sortedVariables receiver instVars argsAndTemps displayVariables dynamicInstVars |
	variables := frame vars.
	"we show receiver separately so take it out of the list. Distinguish it from temp vars named 'receiver' by the symbol. Other args are inst vars"
	sortedVariables := (variables reject: [:variableService | variableService _key == #receiver])
				asSortedCollection: [:x :y | (x _key asString _cmp: y _key asString) < 1].
	sortedVariables := sortedVariables asOrderedCollection.
	instVars := sortedVariables select: [:var | var _key first = $-].
	dynamicInstVars := sortedVariables select: [:var | var _key first = $.].
	argsAndTemps := sortedVariables select: [:var | var _key first ~= $- and: [var _key first ~= $.]].
	receiver := variables detect: [:variableService | variableService _key = 'receiver'] ifNone: [].
	displayVariables := OrderedCollection with: receiver.
	instVars notEmpty
		ifTrue: 
			[displayVariables add: (RowanDisplayLabelVariableService new value: 'instance variables').
			displayVariables addAll: instVars].
	dynamicInstVars notEmpty
		ifTrue: 
			[displayVariables add: (RowanDisplayLabelVariableService new value: 'dynamic instance variables').
			displayVariables addAll: dynamicInstVars].
	argsAndTemps notEmpty
		ifTrue: 
			[displayVariables add: (RowanDisplayLabelVariableService new value: 'args and temps').
			displayVariables addAll: argsAndTemps].
	variableListPresenter list: displayVariables!

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
	self issueCommand: answeringService.
	theAnswer := answeringService answer.
	theAnswer
		ifNotNil: [theAnswer key ifTrue: [theAnswer value: (OopType64 fromInteger: theAnswer value)]].
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
	debuggerService command: #updateProcesses.
	self issueCommand: debuggerService.
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

initialize
	super initialize.
	processList := OrderedCollection new. !

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
			(idleProcessSemaphore isKindOf: Semaphore)
				ifFalse: 
					[Processor activeProcess terminate
					"we do weird things to close a debugger test. If the semaphore isn't a semaphore, stop!!"].
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
	super onCloseRequested: boolValueHolder!

onIdleEntered
	idleProcessSemaphore ifNotNil: [:sem | sem signal].
	super onIdleEntered!

onViewClosed
	"Private - copied from RowanSystemBrowserPresenter>>onViewClosed"

	BrowserUpdate current logComment: 'Closing Debugger {' , self identityHash printString , '}'.
	processList := processListPresenter list.
	BrowserUpdate current removeEventsTriggeredFor: self.
	BrowserUpdate current removeEventsTriggeredFor: processListPresenter.
	BrowserUpdate current removeEventsTriggeredFor: variableListPresenter.
	BrowserUpdate current removeEventsTriggeredFor: documentPresenter.
	"Allow test to know when view is closed"
	self class signalSemaphore.
	self terminateIdleProcess.
	self class lastPosition: self view position.
	self class lastExtent: self view extent.
	super onViewClosed.
	frameListPresenter removeEventsTriggeredFor: self.
	processListPresenter removeEventsTriggeredFor: self.
	variableListPresenter removeEventsTriggeredFor: self.
	codePane documentPresenter removeEventsTriggeredFor: self!

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
	(#(#browseFrameMethod #browseImplementors #browseSenders #browseSelectedMethod #browseFrameMethodInExistingBrowser)
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
			[query
				isEnabled: (processListPresenter model notEmpty and: [processListPresenter model first ~~ gsProcess]).
			^true].
	(#(#implement) includes: query commandSymbol)
		ifTrue: 
			[query isEnabled: false.	"frameListPresenter model first subStrings first = 'MessageNotUnderstood'."
			^true].
	(#(#browseObjectClass #inspectVariable) includes: query commandSymbol)
		ifTrue: 
			[query isEnabled: (variableListPresenter hasSelection
						and: [variableListPresenter selection isDisplayLabel not]).
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
	[self issueCommand: methodService] on: Error
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
	[self issueCommand: classService] on: GsCompileError
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
!JadeiteDebugger categoriesForMethods!
_processList!public! !
_terminateProcess:!public! !
aboutToChangeFrame:!event handlers!public! !
additionalAccelerators!accessing!public! !
basicSelectedFrame!public! !
browseFrameMethod!menu handlers!private! !
browseFrameMethodInExistingBrowser!menu handlers!private! !
browseImplementors!menu handlers!private! !
browseObjectClass!menu handlers!private! !
browseSelectedMethod!menu handlers!private! !
browseSenders!menu handlers!private! !
classServiceFromFrame!menu handlers support!public! !
clearBreakPointsAt:!menu handlers support!public! !
codeSourcePresenterClass!private! !
contextObject!public! !
copyFrameString!menu handlers!private! !
createComponents!public! !
createSchematicWiring!public! !
debuggerService!accessing!private! !
disableBreakpointsWhile:!private! !
displayUncompilableSourceIn:!private! !
displayVariables!frames!private! !
documentPresenter!accessing!public! !
errorMessagePresenter!accessing!public! !
executeSelectionOrLine:!Jade!private! !
frameListPresenter!accessing!frames!public! !
gciSession:!public! !
getProcessList!public! !
homeFrame!compiling!frames!menu handlers!private! !
homeFrameOf:!frames!public! !
initialize!initialization!public! !
initializeIdleProcess!initialization!public! !
initializeProcess:message:terminateOnClose:!initialization!public! !
isOkayToChangeFrame!public!testing! !
jadeInspect!menu handlers!public! !
methodListSelection!accessing!public! !
methodSourcePresenter!public! !
methodValueChanged!event handlers!public! !
onCloseRequested:!event handlers!private! !
onIdleEntered!event handlers!private! !
onViewClosed!event handlers!private! !
onViewDestroyed!event handlers!private! !
onViewOpened!event handlers!private! !
printOn:!accessing!public! !
processListPresenter!accessing!public! !
queryCommand:!menu handlers support!public! !
reformatSource!menu handlers!private! !
refreshBreakPointsIn:!public!updating! !
registerPresentersForUpdates!public!register presenters! !
restart!menu handlers!private! !
resumeProcess!menu handlers!private! !
saveMethod!compiling!menu handlers!private! !
search!accessing!public! !
selectedFrame!frames!public! !
selectedProcess!public! !
selectHomeMethod!compiling!frames!menu handlers!private! !
setCompileErrorColor!compiling!menu handlers!private! !
setCompileWarningColor!compiling!menu handlers!private! !
statusBarText!accessing!public! !
statusBarText:!accessing!public! !
statusTextPresenter!accessing!private! !
stepInto!menu handlers!private! !
stepOut!menu handlers!private! !
stepOver!menu handlers!private! !
stepThrough!menu handlers!private! !
terminateIdleProcess!private! !
terminateProcess!menu handlers!private! !
updateMethodSource!public! !
variableDataPresenter!accessing!public! !
variableListPresenter!accessing!public! !
!

!JadeiteDebugger class methodsFor!

aboutToShowErrorShellOn: gsError
	self semaphore ifNil: [^self].
	[^self openDebuggerOnException: gsError] on: GsError
		do: 
			[:ex |
			ex debugger ifNotNil: [:debugger | debugger view close].
			MessageBox
				warning: 'Error occurred while debugging. Closing debugger. Error description: ' , ex description.
			Processor activeProcess terminate]!

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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1601 1201 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.ToolbarA) 34 25 nil 416 34 2 8 1140853580 131137 592 nil 480 nil 519 nil nil nil 592 480 8 1595846016 nil 170 192 34 14 36633 1115206 1 ##(Smalltalk.ToolbarIconButton) 592 1 1180998 4 ##(Smalltalk.CommandDescription) #resumeProcess 8 'Go' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'Run.ico' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil 36633 36629 706 592 1 738 #stepThrough 8 'Step Through' 1 1 786 nil true 832 8 'icons\bracket_down_arrow.ico' nil 36629 36625 706 592 1 738 #stepInto 8 'Step Into' 1 1 786 nil true 832 8 'StepInto.ico' 880 36625 36635 706 592 1 738 #restart 8 'Restart' 13545 1 786 nil true 832 8 'icons\ArrowCircle.ico' nil 36635 36631 706 592 1 738 #stepOut 8 'Step Out' 1 1 786 nil true 832 8 'StepOut.ico' 880 36631 36627 706 592 1 738 #stepOver 8 'Step Over' 1 1 786 nil true 832 8 'StepOver.ico' 880 36627 36623 706 592 1 738 #showNextStatement 8 'Top Of Stack' 1 1 786 nil true 832 8 'icons\TopOfStack2.ico' nil 36623 34 7 1312 992 1232 912 1152 720 1072 nil nil 1 nil 498 33 33 498 45 45 nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 5 1 498 331 49 592 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 2 0 0 0 0 0 0 0 167 0 0 0 24 0 0 0] 8 #() 498 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 5 1698 #fixedViewLeft 331 1698 #fixedParentTop 1 1698 #fixedViewTop 49 410 ##(Smalltalk.TextEdit) 34 16 nil 416 34 2 8 1140850816 1 1776 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 7 nil nil nil 1776 nil 8 1595878832 852486 ##(Smalltalk.NullConverter) nil nil 3 1442 138 144 34 3 1506 #createAt:extent: 34 2 498 335 9 498 1231 41 1776 1506 #text: 34 1 8 'Static Text' 1776 1506 #setMarginWidths: 34 1 8 #(3 3) 1776 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 167 0 0 0 4 0 0 0 14 3 0 0 24 0 0 0] 8 #() 1648 nil 27 1666 1712 335 1698 #fixedParentRight -3 1744 9 1760 41 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 2240 nil nil nil 7 nil nil nil 2240 1180166 ##(Smalltalk.ProportionalLayout) 170 176 8 #() true 170 192 2352 nil 1442 138 144 34 1 1506 #createAt:extent: 34 2 498 1 51 498 1569 1033 2240 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 16 3 0 0 29 2 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 2240 34 2 8 1140850688 131073 2544 nil 480 nil 7 nil nil nil 2544 2306 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 2544 34 2 8 1140850688 131073 2656 nil nil nil 7 nil nil nil 2656 530 170 176 34 6 410 ##(Smalltalk.PushButton) 34 20 nil 2656 34 2 8 1140924416 1 2768 nil nil nil 7 nil nil nil 2768 nil 8 1595887024 738 #terminateProcess 8 'Terminate' 1 1 nil nil false nil nil nil 1442 138 144 34 3 1506 #createAt:extent: 34 2 498 719 1 498 141 51 2768 1506 #isEnabled: 8 #(false) 2768 1506 #text: 34 1 8 'Terminate' 2768 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 103 1 0 0 0 0 0 0 173 1 0 0 25 0 0 0] 8 #() 1648 nil 29 1666 1698 #fixedPreviousRight 1 2224 1 1744 1 1744 51 410 ##(Smalltalk.ListBox) 34 17 nil 2656 34 2 8 1144062209 1025 3152 590662 2 ##(Smalltalk.ListModel) 138 144 2352 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 265030 4 ##(Smalltalk.Menu) nil true 34 7 984134 2 ##(Smalltalk.CommandMenuItem) 1 738 #browseFrameMethod 8 '&Browse' 1 1 nil nil nil 3346 1 738 #browseFrameMethodInExistingBrowser 8 'Browse In Existing Browser' 1 1 nil nil nil 3346 1 738 #browseImplementors 8 'Browse &Implementors' 1 1 nil nil nil 3346 1 738 #browseSenders 8 'Browse &Senders' 1 1 nil nil nil 3346 1 738 #browseSelectedMethod 8 'Browse Selected Method' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 3346 1 738 #copyFrameString 8 'Copy' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 3152 nil 8 1595685888 ##(Smalltalk.BasicListAbstract) 8 #() false 1442 138 144 34 3 1506 #createAt:extent: 34 2 498 1 51 498 859 461 3152 1506 #contextMenu: 34 1 3312 3152 1506 #horizontalExtent: 8 #(0) 3152 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 173 1 0 0 255 0 0 0] 8 #() 1648 nil 27 1666 1712 1 2224 1 1744 51 1698 #fixedParentBottom 1 410 ##(Smalltalk.ComboBox) 34 17 nil 2656 34 2 8 1412498947 1025 3984 3218 138 144 2352 nil 3280 480 nil 7 nil nil nil 3984 nil 8 1595678816 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each printString]' 8 #[30 105 226 0 106] #printString 4112 7 257 nil 3712 401 1442 138 144 34 1 1506 #createAt:extent: 34 2 498 1 1 498 719 51 3984 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 103 1 0 0 25 0 0 0] 8 #() 1648 nil 27 1666 1712 1 2224 -139 1744 1 1744 51 170 192 34 4 3152 8 'frameList' 3984 8 'processList' nil 1442 138 144 34 1 1506 #createAt:extent: 34 2 498 1 1 498 859 511 2656 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 173 1 0 0 255 0 0 0] 34 3 3152 3984 2768 1648 nil 27 3 410 ##(Smalltalk.ContainerView) 34 15 nil 2544 34 2 8 1140850688 131073 4608 nil 480 nil 7 nil nil nil 4608 2306 170 176 34 4 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 4608 34 2 8 1174475012 1025 4720 1842 nil false 1888 nil 480 nil 7 3298 nil true 34 20 3346 1 738 #undo 8 '&Undo' 9397 1 nil nil nil 3346 1 738 #redo 8 'R&edo' 9395 1 nil nil nil 3602 4097 3346 1 738 #editCut 8 'Cu&t' 9393 1 nil nil nil 3346 1 738 #editCopy 8 '&Copy' 9351 1 nil nil nil 3346 1 738 #editPaste 8 '&Paste' 9389 1 nil nil nil 3346 1 738 #editDelete 8 'De&lete' 1629 1 nil nil nil 3346 1 738 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 3602 4097 3346 1 738 #editFind 8 '&Find...' 9357 1 nil nil nil 3346 1 738 #editFindNext 8 'Find &Next' 9359 1 nil nil nil 3346 1 738 #editReplace 8 '&Replace...' 9361 1 nil nil nil 3602 4097 3346 1 738 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 3346 1 738 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 3346 1 738 #jadeExecute 8 'Execute' 9355 1 nil nil nil 3346 1 738 #jadeDebug 8 'De&bug' 9349 1 nil nil nil 3602 4097 3346 1 738 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 3346 1 738 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 4720 nil 8 1675443688 1922 nil nil 9 1481364353 170 192 34 8 #callTip 1182790 1 ##(Smalltalk.ScintillaTextStyle) 77 466 #gray 466 #white 1 nil nil nil nil #callTip nil nil nil #normal 5746 1 nil nil 1 nil nil nil nil #normal nil nil nil #lineNumber 5746 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #indentGuide 5746 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) nil nil nil nil 4720 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 2352 nil 170 176 2352 7824383 nil nil nil nil 466 #silver nil nil nil nil nil nil nil 1 170 192 2352 nil nil nil nil 16 nil nil nil nil 170 192 34 6 #Warning 5746 1029 196934 1 ##(Smalltalk.RGB) 60239 6066 31326207 1 nil nil nil nil #Warning nil nil nil #Error 5746 1031 6066 335 6066 31317503 1 nil nil nil nil #Error nil nil nil #Notification 5746 1027 nil 6066 31185883 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1442 138 144 34 9 1506 #createAt:extent: 34 2 498 1 343 498 701 169 4720 1506 #contextMenu: 34 1 4800 4720 1506 #caretPeriod: 8 #(530) 4720 1506 #wordWrap: 8 #(true) 4720 1506 #margins: 34 1 34 5 985158 3 ##(Smalltalk.ScintillaMargin) 1 4720 1 3 nil nil nil nil 6450 3 4720 33 nil nil 67108863 nil nil 6450 5 4720 1 nil nil nil nil nil 6450 7 4720 1 nil nil nil nil nil 6450 9 4720 1 nil nil nil nil nil 4720 1506 #canHScroll: 8 #(false) 4720 1506 #targetRange: 34 1 525062 ##(Smalltalk.Interval) 1 -1 3 4720 1506 #maxCompletionListHeight: 8 #(9) 4720 1506 #edgeColumn: 8 #(1) 4720 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 171 0 0 0 94 1 0 0 255 0 0 0] 8 #() 1648 nil 33 3 410 ##(Smalltalk.ListView) 34 45 nil 4608 34 2 8 1140920397 1025 6752 3218 138 144 2352 nil 3280 480 nil 7 3298 nil true 34 2 3346 1 738 #browseObjectClass 8 '&Browse Object Class' 1 1 nil nil nil 3346 1 738 #inspectVariable 8 'Inspect' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 6752 nil 8 1595822304 ##(Smalltalk.BasicListAbstract) nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 3 920646 5 ##(Smalltalk.ListViewColumn) 8 'Variable' 201 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 4098 0 nil 4130 2 1 4096 8 'doIt' 8 '[:each | each key value]' 8 #[30 105 226 0 142 106] #key 7120 7 257 nil nil 6752 nil 1 nil nil 7074 8 'Value' 313 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 4098 0 459302 ##(Smalltalk.Context) 1 1 nil nil 4130 0 9 ##(Smalltalk.UndefinedObject) 8 'doIt' 34 2 8 '[:each | each value]' 34 1 138 ##(Smalltalk.PoolDictionary) 2352 8 #[252 1 0 1 1 5 0 17 229 32 142 106 105] 17 257 nil nil 6752 nil 3 nil 4098 0 nil 4130 3 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:displayThing | displayThing item displayStringOn: displayThing]' 8 #[31 105 226 0 17 177 106] #item #displayStringOn: 7392 7 257 nil 7074 8 'OOP' 181 #right 459270 ##(Smalltalk.Message) #displayString 8 #() 7506 #<= 7536 4098 0 nil 4130 2 1 4096 8 'doIt' 8 '[:each | each displayOop]' 8 #[30 105 226 0 106] #displayOop 7568 7 257 nil nil 6752 nil 1 nil nil #report 3712 nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1442 138 144 34 3 1506 #createAt:extent: 34 2 498 1 1 498 701 333 6752 1506 #contextMenu: 34 1 6848 6752 1506 #text: 34 1 8 'Variable' 6752 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 94 1 0 0 166 0 0 0] 8 #() 1648 nil 35 5 true 170 192 34 4 4720 8 'variableData' 6752 8 'variableList' nil 1442 138 144 34 1 1506 #createAt:extent: 34 2 498 869 1 498 701 511 4608 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 178 1 0 0 0 0 0 0 16 3 0 0 255 0 0 0] 34 3 6752 410 ##(Smalltalk.Splitter) 34 12 nil 4608 34 2 8 1140850688 1 8112 nil 480 nil 519 nil nil nil 1510470 1 ##(Smalltalk.DraggableViewInteractor) 8112 nil 1 #left nil nil nil 498 1 1 498 9 9 nil 8208 nil 1442 138 144 34 1 1506 #createAt:extent: 34 2 498 1 333 498 701 11 8112 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 166 0 0 0 94 1 0 0 171 0 0 0] 8 #() 1648 nil 27 4720 1648 nil 27 524806 ##(Smalltalk.Fraction) 253 311 false 170 192 2352 nil 1442 138 144 34 1 1506 #createAt:extent: 34 2 498 1 1 498 1569 511 2544 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 3 0 0 255 0 0 0] 34 3 2656 410 ##(Smalltalk.Splitter) 34 12 nil 2544 34 2 8 1140850688 1 8608 nil 480 nil 519 nil nil nil 8178 8608 nil 1 #left nil nil nil 8208 8224 nil 8208 nil 1442 138 144 34 1 1506 #createAt:extent: 34 2 498 859 1 498 11 511 8608 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 173 1 0 0 0 0 0 0 178 1 0 0 255 0 0 0] 8 #() 1648 nil 27 4608 1648 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 2240 34 2 8 1140850688 1 8848 nil 480 nil 519 nil nil nil 8178 8848 nil 1 #left nil nil nil 8208 8224 nil 8208 nil 1442 138 144 34 1 1506 #createAt:extent: 34 2 498 1 511 498 1569 11 8848 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 255 0 0 0 16 3 0 0 4 1 0 0] 8 #() 1648 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 2240 34 2 8 1140850688 393217 9088 nil nil nil 7 nil nil nil 9088 530 170 176 34 4 410 ##(Smalltalk.ReferenceView) 34 14 nil 9088 34 2 8 1140850688 131073 9200 nil 480 nil 7 nil nil nil 9200 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteDebuggerMethodSourcePresenter) #resource_Default_view nil 1442 138 144 34 1 1506 #createAt:extent: 34 2 498 1 1 498 1565 469 9200 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 14 3 0 0 234 0 0 0] 2352 1648 nil 27 1666 1712 1 2224 1 1744 1 3968 -39 410 ##(Smalltalk.TextEdit) 34 16 nil 9088 34 2 8 1140916352 1 9456 nil 480 nil 519 nil nil nil 9456 nil 8 1595878832 1922 nil nil 3 1442 138 144 34 1 1506 #createAt:extent: 34 2 498 1 469 498 1565 41 9456 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 234 0 0 0 14 3 0 0 254 0 0 0] 8 #() 1648 nil 27 1666 1712 1 2224 1 3968 -39 3968 1 170 192 34 4 9200 8 'codePane' 9456 8 'statusBarField' nil 1442 138 144 34 1 1506 #createAt:extent: 34 2 498 1 521 498 1569 513 9088 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 4 1 0 0 16 3 0 0 4 2 0 0] 34 2 9200 9456 1648 nil 27 1648 nil 27 1666 1712 1 2224 1 1744 51 3968 1 170 192 34 4 1776 8 'errorMessage' 592 8 'toolbar' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 2 3298 nil true 34 7 3346 1 738 #saveMethod 8 '&Save' 9383 1 nil nil nil 3346 1 738 #copyStack nil 1 1 nil nil nil 3602 4097 3346 1 738 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 3346 1 738 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 3346 1 738 #jadeExecute 8 '&Execute' 9355 1 nil nil nil 3346 1 738 #jadeDebug 8 'Debu&g' 9359 1 nil nil nil 8 '&Edit' nil 134217729 nil nil 36673 nil nil 3298 nil true 34 7 3346 1 738 #showNextStatement 8 'Top of Stack' 1 1 786 nil true 832 8 'icons\TopOfStack2.ico' nil nil nil 3346 1 738 #stepInto nil 9461 1 786 nil true 832 8 'StepInto.ico' 880 nil nil 3346 1 738 #stepOver nil 9459 1 786 nil true 832 8 'StepOver.ico' 880 nil nil 3346 1 738 #stepThrough nil 13555 1 786 nil true 832 8 'icons\bracket_down_arrow.ico' nil nil nil 3346 1 738 #stepOut nil 13557 1 786 nil true 832 8 'StepOut.ico' 880 nil nil 3346 1 738 #resumeProcess 8 'Resume' 9449 1 786 nil true 832 8 'Run.ico' 880 nil nil 3346 1 738 #restart nil 13545 1 786 nil true 832 8 'icons\ArrowCircle.ico' nil nil nil 8 '&Debug' nil 134217729 nil nil 36689 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 786 nil true 832 8 'bracket_down_arrow.ico' nil 786 nil true 832 8 'icons\GS16.ico' nil nil nil 1 nil nil 1442 138 144 34 2 1506 #createAt:extent: 34 2 498 7183 21 498 1601 1201 416 1506 #text: 34 1 8 'Jade Debugger' 416 1586 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 7 14 0 0 10 0 0 0 39 17 0 0 98 2 0 0] 34 3 1776 592 2240 1648 nil 27 )!

semaphore
	"Support for automated testing so we know when UI is ready"

	^semaphore!

semaphore: aSemaphore
	"Support for automated testing so we know when UI is ready"

	semaphore := aSemaphore.
!

signalSemaphore
	self semaphore
		ifNotNil: 
			[:sem |
			
			[sem signal.
			SessionManager inputState prod] forkAt: Processor userBackgroundPriority]! !
!JadeiteDebugger class categoriesForMethods!
aboutToShowErrorShellOn:!public! !
debuggerClass!public! !
debuggerClass:!public! !
disableBreakpointsWhile:session:!private! !
lastExtent!accessing!private! !
lastExtent:!accessing!private! !
lastPosition!accessing!private! !
lastPosition:!accessing!private! !
openOn:message:terminateOnClose:!public! !
resource_Default_view!public!resources-views! !
semaphore!public! !
semaphore:!public! !
signalSemaphore!public! !
!

