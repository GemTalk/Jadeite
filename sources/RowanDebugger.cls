"Filed out from Dolphin Smalltalk 7"!

JadeDebugger subclass: #RowanDebugger
	instanceVariableNames: 'statusTextPresenter idleProcess idleProcessSemaphore'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: 'debuggerClass semaphore'!
RowanDebugger guid: (GUID fromString: '{cae790de-8a45-49eb-813a-6cb32999cd4d}')!
RowanDebugger comment: ''!
!RowanDebugger categoriesForClass!Unclassified! !
!RowanDebugger methodsFor!

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

createComponents
	super createComponents.
	statusTextPresenter := self add: TextPresenter new name: 'statusBarField'!

createSchematicWiring
	super createSchematicWiring.
	frameListPresenter when: #actionPerformed 	send: #browseFrameMethod	to: self.
	documentPresenter when: #textChanged 		send: #methodValueChanged 	to: self!

displayUncompilableSourceIn: sourcePresenter
	sourcePresenter value size < 34 ifTrue: [^self].
	((sourcePresenter value copyFrom: 2 to: 34) equals: 'METHOD SOURCE CANNOT BE DISPLAYED')
		ifTrue: [sourcePresenter view backcolor: JadeTextStyles default colorForUndisplayableSource ]!

documentPresenter

	^documentPresenter!

errorMessagePresenter
	^errorMessagePresenter!

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

	| debuggerService |
	BrowserUpdate current logComment: 'Update debugger service'.
	debuggerService := RowanDebuggerService onProcess: gsProcess.
	self updateServices: (Array with: debuggerService).
	BrowserUpdate current logComment: 'Update debugger service complete'.
	BrowserUpdate current
		logComment: 'debuggerService processes: ' , debuggerService processes printString.
	debuggerService processes ifNil: [^self].
	debuggerService processes notEmpty
		ifTrue: [processListPresenter selection: debuggerService processes first]!

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
	super onViewClosed.
	subPresenters do: [:presenter | BrowserUpdate current removeEventsTriggeredFor: presenter].
	"Allow test to know when view is closed"
	self class signalSemaphore.
	self terminateIdleProcess!

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

registerPresentersForUpdates
	"copied from RowanProjectsBrowserPresenter>>registerPresentersForUpdates"

	BrowserUpdate current
		register: processListPresenter 
		selector: #processListUpdate:
!

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
	| classService string |
	frame isExecutedBlockContext
		ifTrue: [^MessageBox notify: 'Cannot save code in an executed block context.'].
	string := self getDocumentData reject: [:each | each == Character cr].
	classService := RowanClassService new
				name: frame method className;
				meta: frame method meta;
				yourself.
	classService
		command: #saveMethodSource:category:;
		commandArgs: (Array with: string with: frame method category).
	[self issueCommand: (Array with: classService)] on: GsCompileError
		do: [:ex | ^codePane reportCompileError: ex list in: documentPresenter ].
	self statusBarText: String new. 
	(self methodSourcePresenter compilationWarningFrom: classService selectedMethods)
		ifNotNil: [:warning | MessageBox notify: warning].
	documentPresenter isModified: false.
	(gsProcess gsProcessForSession: gciSession)
		trimStackToLevel: frameListPresenter selectionByIndex + frameListOffset.
	self getProcessList!

selectedFrame
	"Comment from RowanFrameService>>initializeProcess:level:organizer: ---- 
		'In 3.2.15 the server does some whacky things with IP, stepPoint, and nested methods.
		See http://kermit.gemtalksystems.com/bug?bug=45553 --JGF'
	When the step point error is thrown, we do a step into instead. There may be better
	solutions."

	| index breaks source |
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
	BrowserUpdate current logComment: 'did not get error. Setting source'.
	source := frame source.
	breaks := frame breaks collect: [:each | frame offsets at: each].
	breaks := breaks
				collect: [:each | ((source copyFrom: 1 to: each) select: [:char | char = Character lf]) size + 1].
	breaks := breaks asSet asSortedCollection asArray.
	BrowserUpdate current logComment: 'finished setting breaks'.
	BrowserUpdate current logComment: 'variableListPresenter list: frame vars.'.
	BrowserUpdate current logComment: frame vars printString.
	variableListPresenter list: frame vars.
	BrowserUpdate current logComment: 'documentPresenter value: frame gsMethod source.'.
	BrowserUpdate current logComment: frame gsMethod source.
	documentPresenter value: frame gsMethod source.
	BrowserUpdate current logComment: 'udpdated source pane'.
	documentPresenter view isModified: false.
	codePane gsMethod: frame gsMethod.
	self displayUncompilableSourceIn: codePane documentPresenter.
	frame stepPoint ifNotNil: [codePane showStepPoint: frame stepPoint].
	(self view viewNamed: 'toolbar') update.
	BrowserUpdate current logComment: 'finished #selectedFrame'!

statusBarText

	^statusTextPresenter value!

statusBarText: aString
	(self view topShell view viewNamed: 'statusBarField') value: aString. !

stepInto
	self isOkayToChangeFrame ifFalse:[^self].
	BrowserUpdate current logComment: '#stepInto'.
	gciSession stepInto: (GsProcess session: gciSession oopType: gsProcess oopType)
		inFrame: frameListPresenter selectionByIndex + frameListOffset.
	[self getProcessList] on: RowanDebuggerStepPointError do: [:ex | self stepInto]!

stepOut	
	self isOkayToChangeFrame ifFalse: [^self].
	BrowserUpdate current logComment: '#stepOut'.
	gciSession stepOut: (GsProcess session: gciSession oopType: gsProcess oopType)
		inFrame: frameListPresenter selectionByIndex + frameListOffset.
	[self getProcessList] on: RowanDebuggerStepPointError do: [:ex | self stepInto]!

stepOver
	self isOkayToChangeFrame ifFalse: [^self].
	BrowserUpdate current logComment: '#stepOver'.
	gciSession stepOver: (GsProcess session: gciSession oopType: gsProcess oopType)
		inFrame: frameListPresenter selectionByIndex + frameListOffset.
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
!RowanDebugger categoriesFor: #_processList!public! !
!RowanDebugger categoriesFor: #_terminateProcess:!public! !
!RowanDebugger categoriesFor: #aboutToChangeFrame:!event handlers!public! !
!RowanDebugger categoriesFor: #basicSelectedFrame!public! !
!RowanDebugger categoriesFor: #browseFrameMethod!menu handlers!private! !
!RowanDebugger categoriesFor: #browseImplementors!menu handlers!private! !
!RowanDebugger categoriesFor: #browseObjectClass!menu handlers!private! !
!RowanDebugger categoriesFor: #browseSenders!menu handlers!private! !
!RowanDebugger categoriesFor: #createComponents!public! !
!RowanDebugger categoriesFor: #createSchematicWiring!public! !
!RowanDebugger categoriesFor: #displayUncompilableSourceIn:!private! !
!RowanDebugger categoriesFor: #documentPresenter!Accessing!public! !
!RowanDebugger categoriesFor: #errorMessagePresenter!Accessing!public! !
!RowanDebugger categoriesFor: #frameListPresenter!Accessing!frames!public! !
!RowanDebugger categoriesFor: #gciSession:!public! !
!RowanDebugger categoriesFor: #getProcessList!public! !
!RowanDebugger categoriesFor: #initializeIdleProcess!initialization!public! !
!RowanDebugger categoriesFor: #initializeProcess:message:terminateOnClose:!initialization!public! !
!RowanDebugger categoriesFor: #isOkayToChangeFrame!public!testing! !
!RowanDebugger categoriesFor: #methodListSelection!Accessing!public! !
!RowanDebugger categoriesFor: #methodSourcePresenter!public! !
!RowanDebugger categoriesFor: #methodValueChanged!event handlers!public! !
!RowanDebugger categoriesFor: #onCloseRequested:!event handlers!private! !
!RowanDebugger categoriesFor: #onIdleEntered!event handlers!private! !
!RowanDebugger categoriesFor: #onViewClosed!event handlers!private! !
!RowanDebugger categoriesFor: #onViewDestroyed!event handlers!private! !
!RowanDebugger categoriesFor: #onViewOpened!event handlers!private! !
!RowanDebugger categoriesFor: #processListPresenter!Accessing!public! !
!RowanDebugger categoriesFor: #queryCommand:!menu handlers!public! !
!RowanDebugger categoriesFor: #registerPresentersForUpdates!public!register presenters! !
!RowanDebugger categoriesFor: #restart!menu handlers!private! !
!RowanDebugger categoriesFor: #resumeProcess!menu handlers!private! !
!RowanDebugger categoriesFor: #saveMethod!compiling!menu handlers!private! !
!RowanDebugger categoriesFor: #selectedFrame!frames!public! !
!RowanDebugger categoriesFor: #statusBarText!Accessing!public! !
!RowanDebugger categoriesFor: #statusBarText:!Accessing!public! !
!RowanDebugger categoriesFor: #stepInto!menu handlers!private! !
!RowanDebugger categoriesFor: #stepOut!menu handlers!private! !
!RowanDebugger categoriesFor: #stepOver!menu handlers!private! !
!RowanDebugger categoriesFor: #terminateIdleProcess!private! !
!RowanDebugger categoriesFor: #terminateProcess!menu handlers!private! !
!RowanDebugger categoriesFor: #updateMethodSource!public! !
!RowanDebugger categoriesFor: #variableDataPresenter!Accessing!public! !
!RowanDebugger categoriesFor: #variableListPresenter!Accessing!public! !

!RowanDebugger class methodsFor!

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
	^debuggerClass ifNil: [RowanDebugger]!

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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 1601 1201 551 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 608 nil nil nil 7 nil nil nil 608 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 2 410 ##(Smalltalk.TextEdit) 34 16 nil 608 34 2 8 1140916352 1 736 nil 466 8 4278190080 nil 519 nil nil nil 736 nil 8 4294904415 852486 ##(Smalltalk.NullConverter) nil nil 3 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 1 995 514 1569 39 736 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 241 1 0 0 16 3 0 0 4 2 0 0] 8 #() 514 193 193 nil 27 327734 ##(Smalltalk.Float) 8 51 51 51 51 51 51 179 63 true 170 192 34 4 410 ##(Smalltalk.ReferenceView) 34 14 nil 608 34 2 8 1140850688 131073 1168 nil 466 8 4278190080 nil 7 nil nil nil 1168 1180166 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteMethodSourcePresenter) #resource_Default_view nil 882 138 144 34 1 946 #createAt:extent: 34 2 514 1 503 514 1569 493 1168 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 251 0 0 0 16 3 0 0 241 1 0 0] 8 #() 1088 nil 27 8 'codePane' 736 8 'statusBarField' nil 882 138 144 34 1 946 #createAt:extent: 34 2 514 1 51 514 1569 1033 608 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 16 3 0 0 29 2 0 0] 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 608 34 2 8 1140850688 131073 1648 nil 466 496 nil 7 nil nil nil 1648 674 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 1648 34 2 8 1140850688 131073 1776 nil 466 496 nil 7 nil nil nil 1776 674 170 176 34 4 410 ##(Smalltalk.MultilineTextEdit) 34 16 nil 1776 34 2 8 1140920580 1025 1904 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 466 8 4278190080 nil 7 265030 4 ##(Smalltalk.Menu) nil true 34 20 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #undo 8 '&Undo' 9397 1 nil nil nil 2114 1 2146 #redo 8 'R&edo' 9395 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 2114 1 2146 #editCut 8 'Cu&t' 9393 1 nil nil nil 2114 1 2146 #editCopy 8 '&Copy' 9351 1 nil nil nil 2114 1 2146 #editPaste 8 '&Paste' 9389 1 nil nil nil 2114 1 2146 #editDelete 8 'De&lete' 1629 1 nil nil nil 2114 1 2146 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 2242 4097 2114 1 2146 #editFind 8 '&Find...' 9357 1 nil nil nil 2114 1 2146 #editFindNext 8 'Find &Next' 9359 1 nil nil nil 2114 1 2146 #editReplace 8 '&Replace...' 9361 1 nil nil nil 2242 4097 2114 1 2146 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 2114 1 2146 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 2114 1 2146 #jadeExecute 8 'Execute' 9355 1 nil nil nil 2114 1 2146 #jadeDebug 8 'De&bug' 9349 1 nil nil nil 2242 4097 2114 1 2146 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 2114 1 2146 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 1904 nil 8 4294904415 850 nil nil 9 882 138 144 34 3 946 #createAt:extent: 34 2 514 1 331 514 701 163 1904 946 #contextMenu: 34 1 2080 1904 946 #setMarginWidths: 34 1 8 #(3 3) 1904 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 165 0 0 0 94 1 0 0 246 0 0 0] 8 #() 1088 nil 27 3 410 ##(Smalltalk.ListView) 34 30 nil 1776 34 2 8 1140920397 1025 3280 590662 2 ##(Smalltalk.ListModel) 138 144 1440 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 466 496 nil 7 2066 nil true 34 2 2114 1 2146 #browseObjectClass 8 '&Browse Object Class' 1 1 nil nil nil 2114 1 2146 #inspectVariable 8 'Inspect' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 3280 nil 8 4294909875 ##(Smalltalk.BasicListAbstract) nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 3 920646 5 ##(Smalltalk.ListViewColumn) 8 'Variable' 201 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 3712 8 'doIt' 8 '[:each | each key value]' 8 #[30 105 226 0 142 106] #key 3728 7 257 nil nil 3280 nil 1 nil nil 3666 8 'Value' 313 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 3714 0 459302 ##(Smalltalk.Context) 1 1 nil nil 3746 0 9 ##(Smalltalk.UndefinedObject) 8 'doIt' 34 2 8 '[:each | each value]' 34 1 138 ##(Smalltalk.PoolDictionary) 1440 8 #[252 1 0 1 1 5 0 17 229 32 142 106 105] 17 257 nil nil 3280 nil 3 nil nil 3666 8 'OOP' 181 #right 459270 ##(Smalltalk.Message) #displayString 8 #() 4050 #<= 4080 3714 0 nil 3746 3 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each key key asNumber]' 8 #[31 105 226 0 158 159 106] #key #asNumber 4112 7 257 nil nil 3280 nil 1 nil nil #report 1440 nil 131169 nil 34 4 nil nil 514 1 1 nil 882 138 144 34 3 946 #createAt:extent: 34 2 514 1 1 514 701 321 3280 946 #contextMenu: 34 1 3440 3280 946 #text: 34 1 8 'Variable' 3280 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 94 1 0 0 160 0 0 0] 8 #() 1088 nil 27 5 true 170 192 34 4 1904 8 'variableData' 3280 8 'variableList' nil 882 138 144 34 1 946 #createAt:extent: 34 2 514 869 1 514 701 493 1776 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 178 1 0 0 0 0 0 0 16 3 0 0 246 0 0 0] 34 3 3280 410 ##(Smalltalk.Splitter) 34 12 nil 1776 34 2 8 1140850688 1 4688 nil 466 496 nil 519 nil nil nil 4688 882 138 144 34 1 946 #createAt:extent: 34 2 514 1 321 514 701 11 4688 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 160 0 0 0 94 1 0 0 165 0 0 0] 8 #() 1088 nil 27 1904 1088 nil 27 524806 ##(Smalltalk.Fraction) 253 311 410 ##(Smalltalk.ContainerView) 34 15 nil 1648 34 2 8 1140850688 131073 4960 nil nil nil 7 nil nil nil 4960 546 170 176 34 6 410 ##(Smalltalk.PushButton) 34 20 nil 4960 34 2 8 1140924416 1 5072 nil nil nil 7 nil nil nil 5072 nil 8 4294908185 2146 #terminateProcess 8 'Terminate' 1 1 nil nil false nil nil nil 882 138 144 34 3 946 #createAt:extent: 34 2 514 719 1 514 141 51 5072 946 #isEnabled: 8 #(false) 5072 946 #text: 34 1 8 'Terminate' 5072 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 103 1 0 0 0 0 0 0 173 1 0 0 25 0 0 0] 8 #() 1088 nil 29 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedPreviousRight 1 5458 #fixedParentRight 1 5458 #fixedParentTop 1 5458 #fixedViewTop 51 410 ##(Smalltalk.ListBox) 34 17 nil 4960 34 2 8 1144062209 1025 5536 3346 138 144 1440 nil 3408 466 496 nil 7 2066 nil true 34 3 2114 1 2146 #browseFrameMethod 8 '&Browse Frame Method' 1 1 nil nil nil 2114 1 2146 #browseImplementors 8 'Browse &Implementors' 1 1 nil nil nil 2114 1 2146 #browseSenders 8 'Browse &Senders' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 5536 nil 8 4294902473 ##(Smalltalk.BasicListAbstract) 1440 false 882 138 144 34 3 946 #createAt:extent: 34 2 514 1 51 514 859 443 5536 946 #contextMenu: 34 1 5648 5536 946 #horizontalExtent: 8 #(0) 5536 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 173 1 0 0 246 0 0 0] 8 #() 1088 nil 27 5426 5458 #fixedParentLeft 1 5488 1 5458 #fixedPreviousBottom 1 5458 #fixedParentBottom 1 410 ##(Smalltalk.ComboBox) 34 17 nil 4960 34 2 8 1412498947 1025 6144 3346 138 144 1440 nil 3408 466 8 4278190080 nil 7 nil nil nil 6144 nil 8 4294904635 3714 0 nil 3746 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each printString]' 8 #[30 105 226 0 106] #printString 6288 7 257 nil 1440 401 882 138 144 34 1 946 #createAt:extent: 34 2 514 1 1 514 719 53 6144 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 103 1 0 0 26 0 0 0] 8 #() 1088 nil 27 5426 6096 1 5488 -139 5504 1 5520 47 170 192 34 4 5536 8 'frameList' 6144 8 'processList' nil 882 138 144 34 1 946 #createAt:extent: 34 2 514 1 1 514 859 493 4960 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 173 1 0 0 246 0 0 0] 34 3 6144 5072 5536 1088 nil 27 3 false 170 192 1440 nil 882 138 144 34 1 946 #createAt:extent: 34 2 514 1 1 514 1569 493 1648 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 3 0 0 246 0 0 0] 34 3 4960 410 ##(Smalltalk.Splitter) 34 12 nil 1648 34 2 8 1140850688 1 6944 nil 466 496 nil 519 nil nil nil 6944 882 138 144 34 1 946 #createAt:extent: 34 2 514 859 1 514 11 493 6944 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 173 1 0 0 0 0 0 0 178 1 0 0 246 0 0 0] 8 #() 1088 nil 27 1776 1088 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 608 34 2 8 1140850688 1 7184 nil 466 496 nil 519 nil nil nil 7184 882 138 144 34 1 946 #createAt:extent: 34 2 514 1 493 514 1569 11 7184 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 246 0 0 0 16 3 0 0 251 0 0 0] 8 #() 1088 nil 27 1168 736 1088 nil 27 5426 6096 1 5488 1 5504 51 6128 1 410 ##(Smalltalk.ToolbarA) 34 25 nil 416 34 2 8 1140853580 131137 7440 nil 466 8 4278190080 nil 519 nil nil nil 7440 466 8 4278190080 8 4294910067 nil 170 192 34 14 50865 1115910 ##(Smalltalk.ToolbarIconButton) 50865 nil 7440 1 2146 #stepOut 8 'Step Out' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'StepOut.ico' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil 395334 3 ##(Smalltalk.Bitmap) nil true nil nil nil nil 3 514 33 33 1 50867 7618 50867 nil 7440 1 2146 #runToCursor 8 'Run to Cursor' 1 1 7682 nil true 7728 8 'RunToCursor.ico' 7776 7810 nil true nil nil nil nil 3 514 33 33 1 50869 7618 50869 nil 7440 1 2146 #resumeProcess 8 'Go' 1 1 7682 nil true 7728 8 'Run.ico' 7776 7810 nil true nil nil nil nil 3 514 33 33 1 50871 7618 50871 nil 7440 1 2146 #restart 8 'Restart' 13545 1 7682 nil true 7728 8 'icons\ArrowCircle.ico' nil 7810 nil true nil nil nil nil 3 514 33 33 1 50859 7618 50859 nil 7440 1 2146 #showNextStatement 8 'Top Of Stack' 1 1 7682 nil true 7728 8 'icons\TopOfStack2.ico' nil 7810 nil true nil nil nil nil 3 514 33 33 1 50861 7618 50861 nil 7440 1 2146 #stepInto 8 'Step Into' 1 1 7682 nil true 7728 8 'StepInto.ico' 7776 7810 nil true nil nil nil nil 3 514 33 33 1 50863 7618 50863 nil 7440 1 2146 #stepOver 8 'Step Over' 1 1 7682 nil true 7728 8 'StepOver.ico' 7776 7810 nil true nil nil nil nil 3 514 33 33 1 34 7 8192 8304 8416 7632 7856 7968 8080 170 176 34 14 8160 13 8384 3 8496 5 7824 7 8272 1 7936 9 8048 11 nil 1 nil 514 33 33 514 45 45 nil nil 882 138 144 34 2 946 #createAt:extent: 34 2 514 1 1 514 321 51 7440 946 #updateSizePosted 1440 7440 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 160 0 0 0 25 0 0 0] 8 #() 1088 nil 27 5426 6096 1 5458 #fixedViewLeft 321 5504 1 5520 51 410 ##(Smalltalk.TextEdit) 34 16 nil 416 34 2 8 1140850816 1 8816 1970 nil false 2016 nil nil nil 7 nil nil nil 8816 nil 8 4294904415 850 nil nil 3 882 138 144 34 3 946 #createAt:extent: 34 2 514 321 7 514 1245 39 8816 946 #text: 34 1 8 'Static Text' 8816 946 #setMarginWidths: 34 1 8 #(3 3) 8816 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 160 0 0 0 3 0 0 0 14 3 0 0 22 0 0 0] 8 #() 1088 nil 27 5426 6096 321 5488 -3 5504 7 5520 39 170 192 34 4 7440 8 'toolbar' 8816 8 'errorMessage' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 2 2066 nil true 34 7 2114 1 2146 #saveMethod 8 '&Save' 9383 1 nil nil nil 2114 1 2146 #copyStack nil 1 1 nil nil nil 2242 4097 2114 1 2146 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 2114 1 2146 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 2114 1 2146 #jadeExecute 8 '&Execute' 9355 1 nil nil nil 2114 1 2146 #jadeDebug 8 'Debu&g' 9359 1 nil nil nil 8 '&Edit' nil 134217729 nil nil 50841 nil nil 2066 nil true 34 7 2114 1 2146 #showNextStatement 8 'Top of Stack' 1 1 7682 nil true 7728 8 'icons\TopOfStack2.ico' nil nil nil 2114 1 2146 #stepInto nil 1 1 7682 nil true 7728 8 'StepInto.ico' 7776 nil nil 2114 1 2146 #stepOver nil 1 1 7682 nil true 7728 8 'StepOver.ico' 7776 nil nil 2114 1 2146 #stepOut nil 1 1 7682 nil true 7728 8 'StepOut.ico' 7776 nil nil 2114 1 2146 #runToCursor nil 1 1 7682 nil true 7728 8 'RunToCursor.ico' 7776 nil nil 2114 1 2146 #resumeProcess 8 'Resume' 1 1 7682 nil true 7728 8 'Run.ico' 7776 nil nil 2114 1 2146 #restart nil 13545 1 7682 nil true 7728 8 'icons\ArrowCircle.ico' nil nil nil 8 '&Debug' nil 134217729 nil nil 50857 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 7682 nil true 7728 8 'icons\GS32.ico' nil 7682 nil true 7728 8 'icons\GS16.ico' nil nil nil 1 nil nil 882 138 144 34 3 946 #createAt:extent: 34 2 514 7679 21 514 1601 1201 416 946 #text: 34 1 8 'Jade Debugger' 416 946 #updateMenuBar 1440 416 1026 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 31 18 0 0 98 2 0 0] 34 3 8816 7440 608 1088 nil 27 )!

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
!RowanDebugger class categoriesFor: #aboutToShowErrorShellOn:!public! !
!RowanDebugger class categoriesFor: #debuggerClass!public! !
!RowanDebugger class categoriesFor: #debuggerClass:!public! !
!RowanDebugger class categoriesFor: #resource_Default_view!public!resources-views! !
!RowanDebugger class categoriesFor: #semaphore!public! !
!RowanDebugger class categoriesFor: #semaphore:!public! !
!RowanDebugger class categoriesFor: #signalSemaphore!public! !

