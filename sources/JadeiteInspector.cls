"Filed out from Dolphin Smalltalk 7"!

JadeNavigationInspector subclass: #JadeiteInspector
	instanceVariableNames: 'statusTextPresenter'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteInspector guid: (GUID fromString: '{e2a72e04-9d21-4c3c-8464-3f402c07b537}')!
JadeiteInspector comment: ''!
!JadeiteInspector categoriesForClass!Unclassified! !
!JadeiteInspector methodsFor!

addOop: oop
	oop isNil ifTrue: [^self].
	(oopsCollection includes: oop) ifTrue: [^self].
	oopsCollection resize: objectIndex + 1.
	oopsCollection at: objectIndex + 1 put: oop.
	objectIndex := objectIndex + 1!

basicRemoveFromDictionary
	| selection newSelectionIndex |
	selection := instVarListPresenter selection.
	self model removeKey: (selection value at: 1) session: gciSession.
	newSelectionIndex := instVarListPresenter selectionByIndex min: model objects size + 2.
	self displayObjectSelecting: newSelectionIndex.
	oopsCollection remove: selection value ifAbsent: [^self].
	objectIndex := objectIndex - 1!

basicRemoveObjectAt: index
	| selection newSelectionIndex | 
	selection := instVarListPresenter selection.
	self model removeIndexedInstVarAt: (self selectedindexedVarOffset: index) session: gciSession.
	newSelectionIndex := index min: model indexedSize + model instVarNames size + 2.
	self displayObjectSelecting: newSelectionIndex.
	oopsCollection remove: selection value ifAbsent: [^self].
	objectIndex := objectIndex - 1!

createComponents

	super createComponents. 
	statusTextPresenter := self add: TextPresenter new name: 'statusText'.
!

displayAll
	| service nextIndexedVars |
	service := RowanInspectorService new
				oop: model oop;
				indexedSize: model indexedSize.
	nextIndexedVars := service
				nextIndexedVarsFrom: model visibleIndices + 1
				to: model indexedSize
				session: gciSession.
	model objects addAll: nextIndexedVars.
	model visibleIndices: model indexedSize.
	self displayObjectSelecting: nil!

displayMore
	| service nextIndexedVars |
	service := RowanInspectorService new
				oop: model oop;
				indexedSize: model indexedSize.
	nextIndexedVars := service
				nextIndexedVarsFrom: model visibleIndices + 1
				to: model maxIndexedVars + model visibleIndices
				session: gciSession.
	model objects addAll: nextIndexedVars.
	model visibleIndices: model visibleIndices + nextIndexedVars size.
	self displayObjectSelecting: instVarListPresenter selectionByIndex!

displayObjectSelecting: selectionIndex
	| contents |
	contents := model objects.
	contents first = model myself
		ifFalse: 
			[contents addFirst: '-.asOop' -> model oop.
			contents addFirst: model myself].
	instVarListPresenter list: contents.
	instVarListPresenter selectionByIndex: (selectionIndex ifNil: [1] ifNotNil: [selectionIndex]).
	model indexedSize > 0
		ifTrue: 
			[statusTextPresenter
				value: 'Displaying ' , model visibleIndices printString , ' of ' , model indexedSize printString
						, ' indexed inst vars']
		ifFalse: [statusTextPresenter value: nil].
	className := model className!

evaluateSelectedTextIn: textPresenter thenInspectInContext: context
	| service |
	self createView: self class defaultView.
	service := RowanInspectorService new
				executeThenInspect: textPresenter currentSelectionOrLine
				context: context
				session: gciSession
				windowHandle: self view handle value.
	service compileErrorArray
		ifNotNil: 
			[[^textPresenter showCompileError: service compileErrorArray first]
				ensure: [service compileErrorArray: nil]].
	^self showOn: service!

evaluateSelectedTextIn: textPresenter thenInspectInContext: context debugger: debugger
	| service |
	self createView: self class defaultView.
	service := RowanInspectorService new
				executeThenInspect: textPresenter currentSelectionOrLine
				context: context
				session: gciSession
				windowHandle: self view handle value
				debugger: debugger.
	service compileErrorArray
		ifNotNil: 
			[[^textPresenter showCompileError: service compileErrorArray first]
				ensure: [service compileErrorArray: nil]].
	^self showOn: service!

expectedModelClass
	^RowanInspectorService!

initialize
	super initialize. 
	statusTextPresenter value: nil!

inspect: oop inContext: context
	| service |
	self createView: self class defaultView.
	service := RowanInspectorService new
				inspect: oop
				session: gciSession
				inWindow: self view handle value.
	^self showOn: service!

inspectInstVar
	| oop |
	oop := instVarListPresenter selection value.	"instVarListPresenter selection is <anAssociation>"
	objectIndex = oopsCollection size
		ifFalse: [(oopsCollection at: objectIndex + 1) = oop ifTrue: [^self getNextObject]].
	self inspectOop: oop!

inspectOop: oop
	| service |
	service := RowanInspectorService new inspect: (gciSession oopTypeWithOop: oop) session: gciSession.
	self model: service.
	self addOop: oop.
	self setDocumentPresenterLabel.
	self displayObjectSelecting: nil.
	self updateCaption!

isProtectedItemSelected
	| index |
	index := instVarListPresenter selectionByIndex.
	^index = 1 or: [index = 2]	"self and -.asOop"!

printInstVar
	| answeringService printString value |
	^
	[answeringService := RowanAnsweringService new.
	value := instVarListPresenter selection value. "oop or Array" 
	printString := (value isKindOf: Array) ifTrue: [value at: 2] ifFalse: [value].
	answeringService
		command: #printStringOf:toMaxSize:;
		commandArgs: (Array with: printString with: self maxPrintStringSize).
	self issueCommand: (Array with: answeringService).
	answeringService answer]
			on: Error
			do: [:ex | self displayInstVarError: ex instVar: instVarListPresenter selection value]!

queryCommand: query
	| command |
	command := query command.
	(command = #displayMore or: [command = #displayAll])
		ifTrue: 
			[model isShowingAllIndexedVars
				ifTrue: 
					[query isEnabled: false.
					^true]].
	command = #removeObject
		ifTrue: 
			[self isProtectedItemSelected
				ifTrue: 
					[query isEnabled: false.
					^true]].
	^super queryCommand: query!

registerWindow: handle rootObject: oop
	^RowanBrowserService new
		registerWindow: handle value
		rootObject: oop
		session: self gciSession!

removeObject
	| index |
	(MessageBox confirm: 'Really remove selection?') ifFalse: [^self].
	model instVarsAreRemovable ifFalse: [^self].
	index := instVarListPresenter selectionByIndex.
	model indexedSize = 0 ifTrue: [^self basicRemoveFromDictionary].
	index - model instVarNames size <= 0 ifTrue: [^self].
	self basicRemoveObjectAt: index!

selectedindexedVarOffset: index
	^index - model instVarNames size - 2	"self + asOop"!

selectedInstVar
	| string |
	instVarListPresenter selectionIfNone: [^self]. 
	(instVarListPresenter selection key = 'self' or: [instVarListPresenter selection key = '-.asOop'])
		ifTrue: 
			[documentPresenter value: instVarListPresenter selection value.
			^self].
	string := [self printInstVar] on: GsRuntimeError
				do: 
					[:ex |
					ex errorReport number == 2106
						ifTrue: 
							["Forward reference error"
							ex return: 'an invalid or hidden object (perhaps a LargeObjectNode)'].
					ex pass].
	documentPresenter value: string!

setNewInspectedObject
	| oop |
	oop := oopsCollection at: objectIndex.
	self inspectOop: oop!

showOn: service
	model := service.
	self showShell.
	self displayObjectSelecting: nil.
	self updateCaption.
	self addOop: self model oop!

statusText
	^statusTextPresenter value! !
!JadeiteInspector categoriesFor: #addOop:!public! !
!JadeiteInspector categoriesFor: #basicRemoveFromDictionary!operations!private! !
!JadeiteInspector categoriesFor: #basicRemoveObjectAt:!operations!private! !
!JadeiteInspector categoriesFor: #createComponents!initialize!public! !
!JadeiteInspector categoriesFor: #displayAll!displaying!menu handlers!public! !
!JadeiteInspector categoriesFor: #displayMore!displaying!menu handlers!public! !
!JadeiteInspector categoriesFor: #displayObjectSelecting:!displaying!private! !
!JadeiteInspector categoriesFor: #evaluateSelectedTextIn:thenInspectInContext:!inspecting!public! !
!JadeiteInspector categoriesFor: #evaluateSelectedTextIn:thenInspectInContext:debugger:!inspecting!public! !
!JadeiteInspector categoriesFor: #expectedModelClass!private! !
!JadeiteInspector categoriesFor: #initialize!initialize!public! !
!JadeiteInspector categoriesFor: #inspect:inContext:!inspecting!public! !
!JadeiteInspector categoriesFor: #inspectInstVar!inspecting!public! !
!JadeiteInspector categoriesFor: #inspectOop:!inspecting!public! !
!JadeiteInspector categoriesFor: #isProtectedItemSelected!public!testing! !
!JadeiteInspector categoriesFor: #printInstVar!displaying!public! !
!JadeiteInspector categoriesFor: #queryCommand:!menu handlers!private! !
!JadeiteInspector categoriesFor: #registerWindow:rootObject:!private! !
!JadeiteInspector categoriesFor: #removeObject!operations!public! !
!JadeiteInspector categoriesFor: #selectedindexedVarOffset:!operations!private! !
!JadeiteInspector categoriesFor: #selectedInstVar!accessing!private! !
!JadeiteInspector categoriesFor: #setNewInspectedObject!public! !
!JadeiteInspector categoriesFor: #showOn:!displaying!public! !
!JadeiteInspector categoriesFor: #statusText!accessing!public! !

!JadeiteInspector class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 1201 901 551 nil nil nil 416 788230 ##(Smalltalk.BorderLayout) 1 1 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 576 nil 721158 ##(Smalltalk.SystemColor) 31 nil 7 nil nil nil 576 1180166 ##(Smalltalk.ProportionalLayout) 170 176 8 #() false 170 192 720 nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 1 1 514 1169 49 576 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 24 0 0 0] 34 1 410 ##(Smalltalk.Toolbar) 34 25 nil 576 34 2 8 1409288972 131137 960 nil 466 8 4278190080 nil 519 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 514 193 193 nil 960 466 1040 8 4294906073 170 192 720 170 192 34 8 22119 1115910 ##(Smalltalk.ToolbarIconButton) 22119 nil 960 1 1180998 4 ##(Smalltalk.CommandDescription) #getPreviousObject 8 'Previous Object' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'HistoryBack.ico' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil 395334 3 ##(Smalltalk.Bitmap) nil true nil nil nil nil 3 514 33 33 1 22121 1234 22121 nil 960 1 1266 #getNextObject 8 'Next Object' 1 1 1314 nil true 1360 8 'HistoryForward.ico' 1408 1442 nil true nil nil nil nil 3 514 33 33 1 22123 1234 22123 nil 960 1 1266 #removeObject 8 'Remove Object' 1 1 1314 nil true 1360 8 'False.ico' 1408 1442 nil true nil nil nil nil 3 514 33 33 1 22125 1234 22125 nil 960 1 1266 #openNavigationInspector 8 'Open Navigation Inspector' 1 1 1314 nil true 1360 8 'BasicInspector.ico' 1408 1442 nil true nil nil nil nil 3 514 33 33 1 34 6 1248 1488 1050118 ##(Smalltalk.ToolbarSeparator) nil nil 960 3 nil 1 1600 1842 nil nil 960 3 nil 1 1712 170 176 34 8 1568 3 1680 5 1792 7 1456 1 nil 1 nil 514 33 33 514 45 45 nil 656198 1 ##(Smalltalk.FlowLayout) 1 1 1 754 138 144 34 2 818 #createAt:extent: 34 2 514 1 1 514 1169 49 960 818 #updateSizePosted 720 960 898 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 24 0 0 0] 8 #() 514 193 193 nil 27 2160 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 2176 nil nil nil 7 nil nil nil 2176 nil 170 192 34 2 410 ##(Smalltalk.StaticText) 34 16 nil 2176 34 2 8 1140850944 65 2272 nil nil nil 7 nil nil nil 2272 nil 8 1663077024 852486 ##(Smalltalk.NullConverter) nil nil nil 754 138 144 34 2 818 #createAt:extent: 34 2 514 1 1 514 1169 47 2272 818 #text: 34 1 8 'Static Text' 2272 898 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 23 0 0 0] 8 #() 2160 nil 27 8 'statusText' nil 754 138 144 34 1 818 #createAt:extent: 34 2 514 1 733 514 1169 51 2176 898 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 110 1 0 0 72 2 0 0 135 1 0 0] 34 1 2272 2160 nil 27 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 2768 nil 642 31 nil 7 nil nil nil 2768 674 170 176 34 2 410 ##(Smalltalk.ReferenceView) 34 14 nil 2768 34 2 8 1140850688 131073 2896 nil 466 8 4278190080 nil 7 nil nil nil 2896 1180166 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.CodeSourcePresenter) #resource_Default_view nil 754 138 144 34 1 818 #createAt:extent: 34 2 514 397 1 514 773 685 2896 898 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 198 0 0 0 0 0 0 0 72 2 0 0 86 1 0 0] 720 2160 nil 27 5 false 170 192 34 4 410 ##(Smalltalk.ListBox) 34 17 nil 2768 34 2 8 1144062209 1025 3200 590662 2 ##(Smalltalk.ListModel) 138 144 720 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 466 8 4278190080 nil 7 265030 4 ##(Smalltalk.Menu) nil true 34 3 984134 2 ##(Smalltalk.CommandMenuItem) 1 1266 #removeObject 8 'Remove Object' 1 1 nil nil nil 3426 1 1266 #displayMore 8 'Display More' 1025 1 nil nil nil 3426 1 1266 #displayAll 8 'Display All' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 3200 nil 8 4294907119 459270 ##(Smalltalk.Message) #key 8 #() 720 false 754 138 144 34 3 818 #createAt:extent: 34 2 514 1 1 514 387 685 3200 818 #contextMenu: 34 1 3392 3200 818 #horizontalExtent: 8 #(0) 3200 898 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 193 0 0 0 86 1 0 0] 8 #() 2160 nil 27 8 'instVarList' 2896 8 'codePane' nil 754 138 144 34 1 818 #createAt:extent: 34 2 514 1 49 514 1169 685 2768 898 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 24 0 0 0 72 2 0 0 110 1 0 0] 34 3 3200 410 ##(Smalltalk.Splitter) 34 12 nil 2768 34 2 8 1140850688 1 4080 nil 466 8 4278190080 nil 519 nil nil nil 4080 754 138 144 34 1 818 #createAt:extent: 34 2 514 387 1 514 11 685 4080 898 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 193 0 0 0 0 0 0 0 198 0 0 0 86 1 0 0] 8 #() 2160 nil 27 2896 2160 nil 27 170 192 720 nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 3378 nil true 34 1 3426 1 1266 #exit 8 'E&xit' 17639 1 nil nil nil 8 '&File' nil 1 nil nil 23517 nil nil 3378 nil true 34 15 3426 1 1266 #undo 8 '&Undo' 9397 1 nil nil nil 3426 1 1266 #redo 8 'R&edo' 9395 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 3426 1 1266 #editCut 8 'Cu&t' 9393 1 nil nil nil 3426 1 1266 #editCopy 8 '&Copy' 9351 1 nil nil nil 3426 1 1266 #editPaste 8 '&Paste' 9389 1 nil nil nil 3426 1 1266 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 3426 1 1266 #editDelete 8 '&Delete' 1629 1 nil nil nil 4626 4097 3426 1 1266 #editFind 8 '&Find...' 9357 1 nil nil nil 3426 1 1266 #editFindNext 8 'Find &Next' 9359 1 nil nil nil 3426 1 1266 #editReplace 8 '&Replace...' 9361 1 nil nil nil 4626 4097 3426 1 1266 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 3426 1 1266 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 8 '&Edit' nil 1 nil nil 23543 nil nil 3378 nil true 34 12 3426 1 1266 #abortTransaction 8 '&Abort Transaction' 1 1 nil nil nil 3426 1 1266 #commitTransaction 8 '&Commit Transaction' 1 1 nil nil nil 4626 4097 3426 1 1266 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 3426 1 1266 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 3426 1 1266 #jadeExecute 8 '&Execute' 9355 1 nil nil nil 3426 1 1266 #fileIn 8 'Fi&le In' 1 1 nil nil nil 4626 4097 3426 1 1266 #browseClass 8 '&Browse Class' 9377 1 nil nil nil 4626 4097 3426 1 1266 #displayMore nil 1025 1 nil nil nil 3426 1 1266 #displayAll nil 1 1 nil nil nil 8 '&Jadeite' nil 1 nil nil 23563 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 754 138 144 34 3 818 #createAt:extent: 34 2 514 7679 21 514 1201 901 416 818 #text: 34 1 8 'Jade Object Navigation Inspector' 416 818 #updateMenuBar 720 416 898 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 87 17 0 0 204 1 0 0] 34 3 576 2768 2176 2160 nil 27 )!

showOn: oop session: aGciSession
	| inspector |
	inspector := self new gciSession: aGciSession.
	^inspector inspect: oop inContext: aGciSession oopNil! !
!JadeiteInspector class categoriesFor: #resource_Default_view!public!resources-views! !
!JadeiteInspector class categoriesFor: #showOn:session:!public! !

