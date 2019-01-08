"Filed out from Dolphin Smalltalk 7"!

JadeDebugger subclass: #RowanDebugger
	instanceVariableNames: 'statusTextPresenter'
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
	aSelectionChangingEvent
		value: (codePane documentPresenter view isModified ifTrue: [self isOkayToChangeFrame] ifFalse: [true])!

basicSelectedFrame
	| index |
	(index := frameListPresenter selectionByIndex) = 0 ifTrue: [^nil].
	index := index + frameListOffset.
	^gsProcess frameForLevel: index!

browseFrameMethod
	| classService shell |
	frame gsMethod selector ifNil:[^self "block context"]. 
	classService := RowanClassService new name: frame gsMethod className.
	BrowserUpdate current updateService: classService session: gciSession.
	^classService projectName = RowanService notRowanizedPackageName
		ifTrue: 
			[Cursor wait showWhile: 
					[shell := RowanSystemBrowser showOnSession: gciSession.
					shell selectClass: classService name asString selector: frame gsMethod selector asString]]
		ifFalse: 
			[shell := JadeiteProjectsSystemBrowser showOnSession: gciSession.
			shell currentCard updateAfterFindClass: classService.
			shell currentCard findMethod: frame gsMethod selector]!

browseImplementors
	^JadePresenter browseImplementorsOf: frame gsMethod selector session: self gciSession!

browseObjectClass
	| shell classService |
	classService := RowanClassService new
				name: variableListPresenter selection className asString subStrings first.	"strip off 'class' if meta"
	BrowserUpdate current updateService: classService session: gciSession.
	classService projectName = RowanService notRowanizedPackageName
		ifTrue: 
			[shell := RowanSystemBrowser showOnSession: gciSession.
			shell selectClass: classService name asString selector: String new]
		ifFalse: 
			[shell := JadeiteProjectsSystemBrowser showOnSession: gciSession.
			shell currentCard updateAfterFindClass: classService].
	^shell!

browseSenders
	^JadePresenter browseSendersOf: frame gsMethod selector session: self gciSession!

createComponents
	super createComponents.
	statusTextPresenter := self add: TextPresenter new name: 'statusBarText'!

createSchematicWiring
	super createSchematicWiring.
	frameListPresenter when: #actionPerformed 	send: #browseFrameMethod	to: self.
	documentPresenter when: #textChanged 		send: #methodValueChanged 	to: self!

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
	debuggerService := RowanDebuggerService onProcess: gsProcess.
	self updateServices: (Array with: debuggerService).
	debuggerService processes ifNil:[^self].
	debuggerService processes notEmpty ifTrue:[
		processListPresenter selection: debuggerService processes first]!

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
		clearContainerIndicators!

onCloseRequested: boolValueHolder
	self isOkayToChangeFrame ifFalse: [^self].
	super onCloseRequested: boolValueHolder!

onIdleEntered
	"Private - Support for automated testing so we know when UI is ready"

	| cachedClass cachedSession |
	cachedClass := self class.
	cachedSession := gciSession.
	[
		[
			(Delay forMilliseconds: 10) wait.
			cachedSession isCallInProgress.
		] whileTrue: [].
		cachedClass signalSemaphore.
	] forkAt: Processor userBackgroundPriority.
	super onIdleEntered.!

onViewClosed
	"Private - copied from RowanSystemBrowserPresenter>>onViewClosed"

	processList := processListPresenter list collect: [:each | GsProcess session: gciSession oopType: each oopType].
	super onViewClosed.
	subPresenters do: [:presenter |
		BrowserUpdate current removeEventsTriggeredFor: presenter.
	].
	"Allow test to know when view is closed"
	self class signalSemaphore.
!

onViewOpened
	"Private - copied from RowanProjectsBrowserPresenter>>onViewOpened"

	super onViewOpened.
	self registerPresentersForUpdates.
	BrowserUpdate current inUpdate: false	"The debugger isn't opened in a forked process so make sure our 'semaphore' won't block updates"!

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
	(index := frameListPresenter selectionByIndex) = 0 ifTrue: [^self].
	index := index + frameListOffset.
	(frame := gsProcess frameForLevel: index) isNil ifTrue: [^self].
	frame stepPoint ifNil: [RowanDebuggerStepPointError signal].	"see comment in  RowanFrameService>>initializeProcess:level:organizer:"
	source := frame source.
	breaks := frame breaks collect: [:each | frame offsets at: each].
	breaks := breaks
				collect: [:each | ((source copyFrom: 1 to: each) select: [:char | char = Character lf]) size + 1].
	breaks := breaks asSet asSortedCollection asArray.
	variableListPresenter list: frame vars.
	documentPresenter value: frame gsMethod source.
	documentPresenter view isModified: false.
	codePane gsMethod: frame gsMethod.
	frame stepPoint ifNotNil: [codePane showStepPoint: frame stepPoint].
	(self view viewNamed: 'toolbar') update!

statusBarText

	^statusTextPresenter value!

statusBarText: aString
	(self view viewNamed: 'statusBarText') model: (ValueHolder with: aString)!

stepInto
	self isOkayToChangeFrame ifFalse:[^self].
	gciSession stepInto: (GsProcess session: gciSession oopType: gsProcess oopType)
		inFrame: frameListPresenter selectionByIndex + frameListOffset.
	[self getProcessList] on: RowanDebuggerStepPointError do: [:ex | self stepInto]!

stepOut
	self isOkayToChangeFrame ifFalse: [^self].
	gciSession stepOut: (GsProcess session: gciSession oopType: gsProcess oopType)
		inFrame: frameListPresenter selectionByIndex + frameListOffset.
	[self getProcessList] on: RowanDebuggerStepPointError do: [:ex | self stepInto]!

stepOver
	self isOkayToChangeFrame ifFalse: [^self].
	gciSession stepOver: (GsProcess session: gciSession oopType: gsProcess oopType)
		inFrame: frameListPresenter selectionByIndex + frameListOffset.
	[self getProcessList] on: RowanDebuggerStepPointError do: [:ex | self stepInto]!

terminateProcess
	(MessageBox confirm: 'Terminate process?' caption: 'GemStone/S Process Termination')
		ifFalse: [^self].
	self isOkayToChangeFrame ifFalse: [^self].
	self _terminateProcess!

updateMethodSource

	self selectedFrame!

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
!RowanDebugger categoriesFor: #documentPresenter!Accessing!public! !
!RowanDebugger categoriesFor: #errorMessagePresenter!Accessing!public! !
!RowanDebugger categoriesFor: #frameListPresenter!Accessing!frames!public! !
!RowanDebugger categoriesFor: #gciSession:!public! !
!RowanDebugger categoriesFor: #getProcessList!public! !
!RowanDebugger categoriesFor: #isOkayToChangeFrame!public!testing! !
!RowanDebugger categoriesFor: #methodListSelection!Accessing!public! !
!RowanDebugger categoriesFor: #methodSourcePresenter!public! !
!RowanDebugger categoriesFor: #methodValueChanged!event handlers!public! !
!RowanDebugger categoriesFor: #onCloseRequested:!event handlers!private! !
!RowanDebugger categoriesFor: #onIdleEntered!event handlers!private! !
!RowanDebugger categoriesFor: #onViewClosed!event handlers!private! !
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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 1601 1201 551 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.TextEdit) 34 16 nil 416 34 2 8 1140850816 1 608 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 7 nil nil nil 608 nil 8 4294911705 852486 ##(Smalltalk.NullConverter) nil nil 3 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 321 7 514 1245 39 608 850 #text: 34 1 8 'Static Text' 608 850 #setMarginWidths: 34 1 8 #(3 3) 608 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 160 0 0 0 3 0 0 0 14 3 0 0 22 0 0 0] 8 #() 514 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 321 1138 #fixedParentRight -3 1138 #fixedParentTop 7 1138 #fixedViewTop 39 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 1216 nil nil nil 7 nil nil nil 1216 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 2 410 ##(Smalltalk.TextEdit) 34 16 nil 1216 34 2 8 1140916352 1 1344 nil 466 8 4278190080 nil 519 nil nil nil 1344 nil 8 4294911705 754 nil nil 3 786 138 144 34 1 850 #createAt:extent: 34 2 514 1 995 514 1569 39 1344 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 241 1 0 0 16 3 0 0 4 2 0 0] 8 #() 1088 nil 27 327734 ##(Smalltalk.Float) 8 51 51 51 51 51 51 179 63 true 170 192 34 4 410 ##(Smalltalk.ReferenceView) 34 14 nil 1216 34 2 8 1140850688 131073 1696 nil 466 8 4278190080 nil 7 nil nil nil 1696 1180166 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteMethodSourcePresenter) #resource_Default_view nil 786 138 144 34 1 850 #createAt:extent: 34 2 514 1 503 514 1569 493 1696 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 251 0 0 0 16 3 0 0 241 1 0 0] 8 #() 1088 nil 27 8 'codePane' 1344 8 'statusBarText' nil 786 138 144 34 1 850 #createAt:extent: 34 2 514 1 51 514 1569 1033 1216 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 16 3 0 0 29 2 0 0] 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 1216 34 2 8 1140850688 131073 2176 nil 466 496 nil 7 nil nil nil 2176 1282 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 2176 34 2 8 1140850688 131073 2304 nil nil nil 7 nil nil nil 2304 546 170 176 34 6 410 ##(Smalltalk.PushButton) 34 20 nil 2304 34 2 8 1140924416 1 2416 nil nil nil 7 nil nil nil 2416 nil 8 4294912091 1180998 4 ##(Smalltalk.CommandDescription) #terminateProcess 8 'Terminate' 1 1 nil nil false nil nil nil 786 138 144 34 3 850 #createAt:extent: 34 2 514 719 1 514 141 51 2416 850 #isEnabled: 8 #(false) 2416 850 #text: 34 1 8 'Terminate' 2416 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 103 1 0 0 0 0 0 0 173 1 0 0 25 0 0 0] 8 #() 1088 nil 29 1106 1138 #fixedPreviousRight 1 1168 1 1184 1 1200 51 410 ##(Smalltalk.ListBox) 34 17 nil 2304 34 2 8 1144062209 1025 2816 590662 2 ##(Smalltalk.ListModel) 138 144 1968 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 466 496 nil 7 265030 4 ##(Smalltalk.Menu) nil true 34 3 984134 2 ##(Smalltalk.CommandMenuItem) 1 2498 #browseFrameMethod 8 '&Browse Frame Method' 1 1 nil nil nil 3026 1 2498 #browseImplementors 8 'Browse &Implementors' 1 1 nil nil nil 3026 1 2498 #browseSenders 8 'Browse &Senders' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 2816 nil 8 4294911671 ##(Smalltalk.BasicListAbstract) 1968 false 786 138 144 34 3 850 #createAt:extent: 34 2 514 1 51 514 859 443 2816 850 #contextMenu: 34 1 2992 2816 850 #horizontalExtent: 8 #(0) 2816 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 173 1 0 0 246 0 0 0] 8 #() 1088 nil 27 1106 1152 1 1168 1 1138 #fixedPreviousBottom 1 1138 #fixedParentBottom 1 410 ##(Smalltalk.ComboBox) 34 17 nil 2304 34 2 8 1412498947 1025 3488 2882 138 144 1968 nil 2944 466 8 4278190080 nil 7 nil nil nil 3488 nil 8 4294907595 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each printString]' 8 #[30 105 226 0 106] #printString 3648 7 257 nil 1968 401 786 138 144 34 1 850 #createAt:extent: 34 2 514 1 1 514 719 53 3488 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 103 1 0 0 26 0 0 0] 8 #() 1088 nil 27 1106 1152 1 1168 -139 1184 1 1200 47 170 192 34 4 2816 8 'frameList' 3488 8 'processList' nil 786 138 144 34 1 850 #createAt:extent: 34 2 514 1 1 514 859 493 2304 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 173 1 0 0 246 0 0 0] 34 3 3488 2416 2816 1088 nil 27 3 410 ##(Smalltalk.ContainerView) 34 15 nil 2176 34 2 8 1140850688 131073 4144 nil 466 496 nil 7 nil nil nil 4144 1282 170 176 34 4 410 ##(Smalltalk.MultilineTextEdit) 34 16 nil 4144 34 2 8 1140920580 1025 4272 674 nil false 720 nil 466 8 4278190080 nil 7 2978 nil true 34 20 3026 1 2498 #undo 8 '&Undo' 9397 1 nil nil nil 3026 1 2498 #redo 8 'R&edo' 9395 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 3026 1 2498 #editCut 8 'Cu&t' 9393 1 nil nil nil 3026 1 2498 #editCopy 8 '&Copy' 9351 1 nil nil nil 3026 1 2498 #editPaste 8 '&Paste' 9389 1 nil nil nil 3026 1 2498 #editDelete 8 'De&lete' 1629 1 nil nil nil 3026 1 2498 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 4514 4097 3026 1 2498 #editFind 8 '&Find...' 9357 1 nil nil nil 3026 1 2498 #editFindNext 8 'Find &Next' 9359 1 nil nil nil 3026 1 2498 #editReplace 8 '&Replace...' 9361 1 nil nil nil 4514 4097 3026 1 2498 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 3026 1 2498 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 3026 1 2498 #jadeExecute 8 'Execute' 9355 1 nil nil nil 3026 1 2498 #jadeDebug 8 'De&bug' 9349 1 nil nil nil 4514 4097 3026 1 2498 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 3026 1 2498 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 4272 nil 8 4294911705 754 nil nil 9 786 138 144 34 3 850 #createAt:extent: 34 2 514 1 331 514 701 163 4272 850 #contextMenu: 34 1 4384 4272 850 #setMarginWidths: 34 1 8 #(3 3) 4272 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 165 0 0 0 94 1 0 0 246 0 0 0] 8 #() 1088 nil 27 3 410 ##(Smalltalk.ListView) 34 30 nil 4144 34 2 8 1140920397 1025 5552 2882 138 144 1968 nil 2944 466 496 nil 7 2978 nil true 34 2 3026 1 2498 #browseObjectClass 8 '&Browse Object Class' 1 1 nil nil nil 3026 1 2498 #inspectVariable 8 'Inspect' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 5552 nil 8 4294912227 ##(Smalltalk.BasicListAbstract) nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 3 920646 5 ##(Smalltalk.ListViewColumn) 8 'Variable' 201 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 3634 0 nil 3666 2 1 3632 8 'doIt' 8 '[:each | each key value]' 8 #[30 105 226 0 142 106] #key 5936 7 257 nil nil 5552 nil 1 nil nil 5890 8 'Value' 313 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 3634 0 459302 ##(Smalltalk.Context) 1 1 nil nil 3666 0 9 ##(Smalltalk.UndefinedObject) 8 'doIt' 34 2 8 '[:each | each value]' 34 1 138 ##(Smalltalk.PoolDictionary) 1968 8 #[252 1 0 1 1 5 0 17 229 32 142 106 105] 17 257 nil nil 5552 nil 3 nil nil 5890 8 'OOP' 181 #right 459270 ##(Smalltalk.Message) #displayString 8 #() 6242 #<= 6272 3634 0 nil 3666 3 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each key key asNumber]' 8 #[31 105 226 0 158 159 106] #key #asNumber 6304 7 257 nil nil 5552 nil 1 nil nil #report 1968 nil 131169 nil 34 4 nil nil 514 1 1 nil 786 138 144 34 3 850 #createAt:extent: 34 2 514 1 1 514 701 321 5552 850 #contextMenu: 34 1 5664 5552 850 #text: 34 1 8 'Variable' 5552 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 94 1 0 0 160 0 0 0] 8 #() 1088 nil 27 5 true 170 192 34 4 4272 8 'variableData' 5552 8 'variableList' nil 786 138 144 34 1 850 #createAt:extent: 34 2 514 869 1 514 701 493 4144 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 178 1 0 0 0 0 0 0 16 3 0 0 246 0 0 0] 34 3 5552 410 ##(Smalltalk.Splitter) 34 12 nil 4144 34 2 8 1140850688 1 6880 nil 466 496 nil 519 nil nil nil 6880 786 138 144 34 1 850 #createAt:extent: 34 2 514 1 321 514 701 11 6880 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 160 0 0 0 94 1 0 0 165 0 0 0] 8 #() 1088 nil 27 4272 1088 nil 27 524806 ##(Smalltalk.Fraction) 253 311 false 170 192 1968 nil 786 138 144 34 1 850 #createAt:extent: 34 2 514 1 1 514 1569 493 2176 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 3 0 0 246 0 0 0] 34 3 2304 410 ##(Smalltalk.Splitter) 34 12 nil 2176 34 2 8 1140850688 1 7328 nil 466 496 nil 519 nil nil nil 7328 786 138 144 34 1 850 #createAt:extent: 34 2 514 859 1 514 11 493 7328 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 173 1 0 0 0 0 0 0 178 1 0 0 246 0 0 0] 8 #() 1088 nil 27 4144 1088 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 1216 34 2 8 1140850688 1 7568 nil 466 496 nil 519 nil nil nil 7568 786 138 144 34 1 850 #createAt:extent: 34 2 514 1 493 514 1569 11 7568 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 246 0 0 0 16 3 0 0 251 0 0 0] 8 #() 1088 nil 27 1696 1344 1088 nil 27 1106 1152 1 1168 1 1184 51 3472 1 410 ##(Smalltalk.ToolbarA) 34 25 nil 416 34 2 8 1140853580 131137 7824 nil 466 8 4278190080 nil 519 nil nil nil 7824 466 8 4278190080 8 4294912021 nil 170 192 34 14 59225 1115910 ##(Smalltalk.ToolbarIconButton) 59225 nil 7824 1 2498 #runToCursor 8 'Run to Cursor' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'RunToCursor.ico' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil 395334 3 ##(Smalltalk.Bitmap) nil true nil nil nil nil 3 514 33 33 1 59227 8002 59227 nil 7824 1 2498 #resumeProcess 8 'Go' 1 1 8066 nil true 8112 8 'Run.ico' 8160 8194 nil true nil nil nil nil 3 514 33 33 1 59229 8002 59229 nil 7824 1 2498 #restart 8 'Restart' 13545 1 8066 nil true 8112 8 'icons\ArrowCircle.ico' nil 8194 nil true nil nil nil nil 3 514 33 33 1 59217 8002 59217 nil 7824 1 2498 #showNextStatement 8 'Top Of Stack' 1 1 8066 nil true 8112 8 'icons\TopOfStack2.ico' nil 8194 nil true nil nil nil nil 3 514 33 33 1 59219 8002 59219 nil 7824 1 2498 #stepInto 8 'Step Into' 1 1 8066 nil true 8112 8 'StepInto.ico' 8160 8194 nil true nil nil nil nil 3 514 33 33 1 59221 8002 59221 nil 7824 1 2498 #stepOver 8 'Step Over' 1 1 8066 nil true 8112 8 'StepOver.ico' 8160 8194 nil true nil nil nil nil 3 514 33 33 1 59223 8002 59223 nil 7824 1 2498 #stepOut 8 'Step Out' 1 1 8066 nil true 8112 8 'StepOut.ico' 8160 8194 nil true nil nil nil nil 3 514 33 33 1 34 7 8464 8576 8688 8800 8016 8240 8352 170 176 34 14 8432 13 8656 3 8768 5 8880 7 8544 1 8208 9 8320 11 nil 1 nil 514 33 33 514 45 45 nil nil 786 138 144 34 2 850 #createAt:extent: 34 2 514 1 1 514 321 51 7824 850 #updateSizePosted 1968 7824 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 160 0 0 0 25 0 0 0] 8 #() 1088 nil 27 1106 1152 1 1138 #fixedViewLeft 321 1184 1 1200 51 170 192 34 4 608 8 'errorMessage' 7824 8 'toolbar' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 2 2978 nil true 34 7 3026 1 2498 #saveMethod 8 '&Save' 9383 1 nil nil nil 3026 1 2498 #copyStack nil 1 1 nil nil nil 4514 4097 3026 1 2498 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 3026 1 2498 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 3026 1 2498 #jadeExecute 8 '&Execute' 9355 1 nil nil nil 3026 1 2498 #jadeDebug 8 'Debu&g' 9359 1 nil nil nil 8 '&Edit' nil 134217729 nil nil 59199 nil nil 2978 nil true 34 7 3026 1 2498 #showNextStatement 8 'Top of Stack' 1 1 8066 nil true 8112 8 'icons\TopOfStack2.ico' nil nil nil 3026 1 2498 #stepInto nil 1 1 8066 nil true 8112 8 'StepInto.ico' 8160 nil nil 3026 1 2498 #stepOver nil 1 1 8066 nil true 8112 8 'StepOver.ico' 8160 nil nil 3026 1 2498 #stepOut nil 1 1 8066 nil true 8112 8 'StepOut.ico' 8160 nil nil 3026 1 2498 #runToCursor nil 1 1 8066 nil true 8112 8 'RunToCursor.ico' 8160 nil nil 3026 1 2498 #resumeProcess 8 'Resume' 1 1 8066 nil true 8112 8 'Run.ico' 8160 nil nil 3026 1 2498 #restart nil 13545 1 8066 nil true 8112 8 'icons\ArrowCircle.ico' nil nil nil 8 '&Debug' nil 134217729 nil nil 59215 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 8066 nil true 8112 8 'icons\GS32.ico' nil 8066 nil true 8112 8 'icons\GS16.ico' nil nil nil 1 nil nil 786 138 144 34 3 850 #createAt:extent: 34 2 514 7679 21 514 1601 1201 416 850 #text: 34 1 8 'Jade Debugger' 416 850 #updateMenuBar 1968 416 1026 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 31 18 0 0 98 2 0 0] 34 3 608 7824 1216 1088 nil 27 )!

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

