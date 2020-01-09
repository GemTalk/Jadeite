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

aboutToChange: aSelectionChangingEvent
	aSelectionChangingEvent value ifTrue: [
		aSelectionChangingEvent value: self isOkayToChange.
	].
!

additionalAccelerators
	^#(#(#fileSave 'Ctrl+S'))!

addObject
	| string |
	"might have inserted a string into another string so it won't find the object"
	model isVariable ifFalse: [^MessageBox notify: 'Cannot add elements to this object'].
	string := Prompter
				on: String new asValue
				prompt: 'Entry will be compiled and added to the object'
				caption: 'Add Object ...'.
	string ifNil: [^self].
	model isDictionary ifTrue: [^self basicAddKey: string].
	self basicAddObject: string!

addOop: oop
	oop isNil ifTrue: [^self].
	(oopsCollection includes: oop) ifTrue: [^self].
	oopsCollection resize: objectIndex + 1.
	oopsCollection at: objectIndex + 1 put: oop.
	objectIndex := objectIndex + 1!

basicAddKey: string
	| addedObject newSelectionIndex |
	"might have inserted a string into another string so it won't find the object"
	model
		command: #addKey:;
		commandArgs: (Array with: string).
	self issueCommand: (Array with: model).
	addedObject := model objects
				detect: [:assoc | (assoc value isKindOf: Array) and: [assoc value first = model selectionOop]]
				ifNone: [].
	newSelectionIndex := model objects indexOf: addedObject.
	newSelectionIndex := newSelectionIndex + 2. "inst vars & dynamic inst vars already included in objects" 
	self displayObjectSelecting: newSelectionIndex!

basicAddObject: string
	| addedObject additionIndex newSelectionIndex |
	additionIndex := self indexedOffsetFromInstVarList: instVarListPresenter selectionByIndex.
	model
		command: #addObject:after:;
		commandArgs: (Array with: string with: additionIndex).
	self issueCommand: (Array with: model).
	addedObject := model objects detect: [:assoc | assoc value = model selectionOop] ifNone: [].
	newSelectionIndex := model objects indexOf: addedObject.
	newSelectionIndex := newSelectionIndex = 0
				ifTrue: [1	"might have inserted a string into another string so it won't find the object"]
				ifFalse: [newSelectionIndex + 2].
	self displayObjectSelecting: newSelectionIndex!

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
	self model removeIndexedInstVarAt: (self indexedOffsetFromInstVarList: index) session: gciSession.
	newSelectionIndex := index
				min: model indexedSize + model instVarNames size + self dynamicInstVars size + 2.
	self displayObjectSelecting: newSelectionIndex.
	oopsCollection remove: selection value ifAbsent: [^self].
	objectIndex := objectIndex - 1!

basicRemoveOop: oop
	| selection selectionIndex |
	selection := instVarListPresenter selection.
	self model removeOop: oop session: gciSession.
	selectionIndex := instVarListPresenter selectionByIndex min: model objects size + 2.
	self displayObjectSelecting: selectionIndex.
	oopsCollection remove: selection value ifAbsent: [^self].
	objectIndex := objectIndex - 1!

canSave
	^self isSelfSelected not and: [self isAsOopSelected not]!

createComponents

	super createComponents. 
	statusTextPresenter := self add: TextPresenter new name: 'statusText'.
!

createSchematicWiring
	super createSchematicWiring.
	instVarListPresenter
		when: #selectionChanging:
		send: #aboutToChange:
		to: self!

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
	self displayObjectSelecting:  instVarListPresenter selectionByIndex!

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
	contents := model objects copy.	"otherwise the presenter list will notice it's the same object and not update the view"
	(contents isEmpty or: [contents first ~= model myself])
		ifTrue: 
			[contents addFirst: '-.asOop' -> model oop printString.
			contents addFirst: model myself].
	instVarListPresenter list: contents.
	instVarListPresenter selectionByIndex: (selectionIndex ifNil: [1] ifNotNil: [selectionIndex]).
	model indexedSize > 0
		ifTrue: 
			[statusTextPresenter
				value: 'Displaying ' , model visibleIndices printString , ' of ' , model indexedSize printString
						, (model isDictionary ifTrue: [' keys'] ifFalse: [' indexed inst vars'])]
		ifFalse: [statusTextPresenter value: nil].
	className := model className!

dynamicInstVars
	^instVarListPresenter list select: [:instVar | '--*' match: instVar key]!

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

indexedOffsetFromInstVarList: index
	^index - model instVarNames size - self dynamicInstVars size - 2 max: 0	"2 = self + asOop"!

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
	"instVarListPresenter selection is <anAssociation>"
	(self isSelfSelected or:[self isAsOopSelected]) ifTrue:[^self]. 
	oop := instVarListPresenter selection value.
	(oop isKindOf: Array) ifTrue: [oop := oop last].	"a dictionary entry will hold oop of key and oop of value"
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

instVarListIndexFromIndexedOffset: index
	^index + model instVarNames size + self dynamicInstVars size + 2	"2 = self + asOop"!

isAsOopSelected
	^instVarListPresenter selection key = '-.asOop'!

isDynamicInstVarSelected
	^'--*' match: (instVarListPresenter selectionIfNone: [^false]) key!

isNamedInstVarSelected
	^model instVarNames includes: self selectedNamedInstVar!

isOkayToChange
	documentPresenter view isModified
		ifTrue: [(MessageBox confirm: 'Keep unsaved changes?' caption: 'Unsaved Changes') ifTrue: [^false]].
	documentPresenter view isModified: false. 
	^true!

isProtectedItemSelected
	| index selection |
	index := instVarListPresenter selectionByIndex.
	index = 1 ifTrue: [^true].
	selection := instVarListPresenter selectionIfNone: [^true].
	^'-*' match: selection key!

isSelfSelected
	^instVarListPresenter selection key = 'self'!

objectIsVariable
	| answeringService |
	model command: #isVariable.
	answeringService := BrowserUpdate current issueCommands: (Array with: self) session: gciSession.
	^answeringService answer!

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
	command = #fileSave
		ifTrue: 
			[self shouldEnableFileSave: query.
			^true].
	(command = #displayMore or: [command = #displayAll])
		ifTrue: 
			[model isShowingAllIndexedVars
				ifTrue: 
					[query isEnabled: false.
					^true]].
	command = #addObject
		ifTrue: 
			[view isWindowVisible ifTrue: [query isEnabled: model isVariable].
			^true].
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
	model isDictionary ifTrue: [^self basicRemoveFromDictionary].
	('-*' match: instVarListPresenter selection key) ifTrue: [^MessageBox notify: 'Cannot remove inst var'].	"inst var"
	model isUnordered ifTrue: [^self basicRemoveOop: instVarListPresenter selection value].
	index - model instVarNames size <= 0 ifTrue: [^self].
	self basicRemoveObjectAt: index!

saveDictionaryElement
	| keyOop |
	keyOop := instVarListPresenter selection value first.
	model
		command: #saveKey:value:;
		commandArgs: (Array with: keyOop with: documentPresenter value).
	self issueCommand: (Array with: model).
	self displayObjectSelecting: instVarListPresenter selectionByIndex!

saveDocument
	(self isSelfSelected or: [self isAsOopSelected])
		ifTrue: [^MessageBox notify: 'Cannot modify Self or the oop'].
	self isDynamicInstVarSelected ifTrue: [^self saveDynamicInstVar].
	self isNamedInstVarSelected ifTrue: [^self saveNamedInstVar].
	model isDictionary ifTrue: [^self saveDictionaryElement].
	model isUnordered ifTrue: [^self saveUnorderedElement].
	self saveIndexedElement!

saveDynamicInstVar
	| instVarName |
	instVarName := self selectedDynamicInstVar.
	model
		command: #save:dynamicInstVar:;
		commandArgs: (Array with: documentPresenter value with: instVarName).
	self issueCommand: (Array with: model).
	self displayObjectSelecting: instVarListPresenter selectionByIndex!

saveIndexedElement
	| index |
	index := self indexedOffsetFromInstVarList: instVarListPresenter selectionByIndex.
	model
		command: #save:indexedVarAt:;
		commandArgs: (Array with: documentPresenter value with: index).
	self issueCommand: (Array with: model).
	self displayObjectSelecting: (self instVarListIndexFromIndexedOffset: index)!

saveNamedInstVar
	| index instVarName |
	instVarName := self selectedNamedInstVar. 
	model
		command: #save:namedInstVar:;
		commandArgs: (Array with: documentPresenter value with: instVarName).
	self issueCommand: (Array with: model).
	index := model instVarNames indexOf: instVarName.
	self displayObjectSelecting: index + 2!

saveUnorderedElement
	| oop addedObject newSelectionIndex |
	oop := instVarListPresenter selection value.
	model
		command: #replaceElement:with:;
		commandArgs: (Array with: oop with: documentPresenter value).
	self issueCommand: (Array with: model).
	addedObject := model objects detect: [:assoc | assoc value = model selectionOop] ifNone: [].
	newSelectionIndex := model objects indexOf: addedObject.
	self displayObjectSelecting: newSelectionIndex + 2!

selectedDynamicInstVar
	"if a named inst var is selected, return it's name as a symbol"

	| key |
	key := instVarListPresenter selection key.
	^(instVarListPresenter selection key copyFrom: 3 to: key size) asSymbol!

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

selectedNamedInstVar
	"if a named inst var is selected, return it's name as a symbol"

	^(instVarListPresenter selection key copyWithout: $-) asSymbol!

setNewInspectedObject
	| oop |
	oop := oopsCollection at: objectIndex.
	self inspectOop: oop!

shouldEnableFileSave: query
	(instVarListPresenter selectionIfNone: [])
		ifNil: [query isEnabled: false]
		ifNotNil: [query isEnabled: (self isSelfSelected not and: [self isAsOopSelected not])]!

showOn: service
	model := service.
	self showShell.
	self displayObjectSelecting: nil.
	self updateCaption.
	self addOop: self model oop!

statusText
	^statusTextPresenter value! !
!JadeiteInspector categoriesFor: #aboutToChange:!event handlers!private! !
!JadeiteInspector categoriesFor: #additionalAccelerators!constants!public! !
!JadeiteInspector categoriesFor: #addObject!menu handlers!operations!public! !
!JadeiteInspector categoriesFor: #addOop:!public! !
!JadeiteInspector categoriesFor: #basicAddKey:!menu handlers!operations!private! !
!JadeiteInspector categoriesFor: #basicAddObject:!menu handlers!operations!private! !
!JadeiteInspector categoriesFor: #basicRemoveFromDictionary!operations!private! !
!JadeiteInspector categoriesFor: #basicRemoveObjectAt:!operations!private! !
!JadeiteInspector categoriesFor: #basicRemoveOop:!operations!private! !
!JadeiteInspector categoriesFor: #canSave!private!testing! !
!JadeiteInspector categoriesFor: #createComponents!initialize!public! !
!JadeiteInspector categoriesFor: #createSchematicWiring!initialize!private! !
!JadeiteInspector categoriesFor: #displayAll!displaying!menu handlers!public! !
!JadeiteInspector categoriesFor: #displayMore!displaying!menu handlers!public! !
!JadeiteInspector categoriesFor: #displayObjectSelecting:!displaying!private! !
!JadeiteInspector categoriesFor: #dynamicInstVars!accessing!public! !
!JadeiteInspector categoriesFor: #evaluateSelectedTextIn:thenInspectInContext:!inspecting!public! !
!JadeiteInspector categoriesFor: #evaluateSelectedTextIn:thenInspectInContext:debugger:!inspecting!public! !
!JadeiteInspector categoriesFor: #expectedModelClass!private! !
!JadeiteInspector categoriesFor: #indexedOffsetFromInstVarList:!operations!private! !
!JadeiteInspector categoriesFor: #initialize!initialize!public! !
!JadeiteInspector categoriesFor: #inspect:inContext:!inspecting!public! !
!JadeiteInspector categoriesFor: #inspectInstVar!inspecting!public! !
!JadeiteInspector categoriesFor: #inspectOop:!inspecting!public! !
!JadeiteInspector categoriesFor: #instVarListIndexFromIndexedOffset:!operations!private! !
!JadeiteInspector categoriesFor: #isAsOopSelected!private!testing! !
!JadeiteInspector categoriesFor: #isDynamicInstVarSelected!private!testing! !
!JadeiteInspector categoriesFor: #isNamedInstVarSelected!private!testing! !
!JadeiteInspector categoriesFor: #isOkayToChange!private!testing! !
!JadeiteInspector categoriesFor: #isProtectedItemSelected!private!testing! !
!JadeiteInspector categoriesFor: #isSelfSelected!private!testing! !
!JadeiteInspector categoriesFor: #objectIsVariable!private!testing! !
!JadeiteInspector categoriesFor: #printInstVar!displaying!private! !
!JadeiteInspector categoriesFor: #queryCommand:!menu handlers support!private! !
!JadeiteInspector categoriesFor: #registerWindow:rootObject:!private! !
!JadeiteInspector categoriesFor: #removeObject!menu handlers!operations!public! !
!JadeiteInspector categoriesFor: #saveDictionaryElement!menu handlers support!private! !
!JadeiteInspector categoriesFor: #saveDocument!menu handlers!public! !
!JadeiteInspector categoriesFor: #saveDynamicInstVar!menu handlers support!private! !
!JadeiteInspector categoriesFor: #saveIndexedElement!menu handlers support!private! !
!JadeiteInspector categoriesFor: #saveNamedInstVar!menu handlers support!private! !
!JadeiteInspector categoriesFor: #saveUnorderedElement!menu handlers support!private! !
!JadeiteInspector categoriesFor: #selectedDynamicInstVar!private! !
!JadeiteInspector categoriesFor: #selectedInstVar!accessing!event handlers!private! !
!JadeiteInspector categoriesFor: #selectedNamedInstVar!private! !
!JadeiteInspector categoriesFor: #setNewInspectedObject!public! !
!JadeiteInspector categoriesFor: #shouldEnableFileSave:!menu handlers support!private!testing! !
!JadeiteInspector categoriesFor: #showOn:!displaying!public! !
!JadeiteInspector categoriesFor: #statusText!accessing!public! !

!JadeiteInspector class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 1201 901 551 nil nil nil 416 788230 ##(Smalltalk.BorderLayout) 1 1 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 576 nil 721158 ##(Smalltalk.SystemColor) 31 nil 7 nil nil nil 576 1180166 ##(Smalltalk.ProportionalLayout) 170 176 8 #() false 170 192 720 nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 1 1 514 1169 49 576 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 24 0 0 0] 34 1 410 ##(Smalltalk.Toolbar) 34 25 nil 576 34 2 8 1409288972 131137 960 nil 466 8 4278190080 nil 519 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 514 193 193 nil 960 466 1040 8 4294902767 170 192 720 170 192 34 10 44485 1115910 ##(Smalltalk.ToolbarIconButton) 44485 nil 960 1 1180998 4 ##(Smalltalk.CommandDescription) #getPreviousObject 8 'Previous Object' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'HistoryBack.ico' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil 395334 3 ##(Smalltalk.Bitmap) nil true nil nil nil nil 3 514 33 33 1 44487 1234 44487 nil 960 1 1266 #getNextObject 8 'Next Object' 1 1 1314 nil true 1360 8 'HistoryForward.ico' 1408 1442 nil true nil nil nil nil 3 514 33 33 1 44489 1234 44489 nil 960 1 1266 #removeObject 8 'Remove Object' 1 1 1314 nil true 1360 8 'False.ico' 1408 1442 nil true nil nil nil nil 3 514 33 33 1 44491 1234 44491 nil 960 1 1266 #addObject 8 'Add Object' 1 1 1314 nil true 1360 8 'C:\Users\ewinger\source\repos\Dolphin\Core\DolphinVM\Res\CompiledMethodPublic.ico' nil 1442 nil true nil nil nil nil 3 514 33 33 1 44493 1234 44493 nil 960 1 1266 #openNavigationInspector 8 'Open Navigation Inspector' 1 1 1314 nil true 1360 8 'BasicInspector.ico' 1408 1442 nil true nil nil nil nil 3 514 33 33 1 34 7 1248 1488 1050118 ##(Smalltalk.ToolbarSeparator) nil nil 960 3 nil 1 1600 1712 1954 nil nil 960 3 nil 1 1824 170 176 34 10 1568 3 1680 5 1792 7 1456 1 1904 9 nil 1 nil 514 33 33 514 45 45 nil 656198 1 ##(Smalltalk.FlowLayout) 1 1 1 754 138 144 34 2 818 #createAt:extent: 34 2 514 1 1 514 1169 49 960 818 #updateSizePosted 720 960 898 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 24 0 0 0] 8 #() 514 193 193 nil 27 2272 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 2288 nil nil nil 7 nil nil nil 2288 nil 170 192 34 2 410 ##(Smalltalk.StaticText) 34 16 nil 2288 34 2 8 1140850944 65 2384 nil nil nil 7 nil nil nil 2384 nil 8 1687849632 852486 ##(Smalltalk.NullConverter) nil nil nil 754 138 144 34 2 818 #createAt:extent: 34 2 514 1 1 514 1169 47 2384 818 #text: 34 1 8 'Static Text' 2384 898 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 23 0 0 0] 8 #() 2272 nil 27 8 'statusText' nil 754 138 144 34 1 818 #createAt:extent: 34 2 514 1 733 514 1169 51 2288 898 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 110 1 0 0 72 2 0 0 135 1 0 0] 34 1 2384 2272 nil 27 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 2880 nil 642 31 nil 7 nil nil nil 2880 674 170 176 34 2 410 ##(Smalltalk.ReferenceView) 34 14 nil 2880 34 2 8 1140850688 131073 3008 nil 466 8 4278190080 nil 7 nil nil nil 3008 1180166 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.CodeSourcePresenter) #resource_Default_view nil 754 138 144 34 1 818 #createAt:extent: 34 2 514 397 1 514 773 685 3008 898 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 198 0 0 0 0 0 0 0 72 2 0 0 86 1 0 0] 720 2272 nil 27 5 false 170 192 34 4 410 ##(Smalltalk.ListBox) 34 17 nil 2880 34 2 8 1144062209 1025 3312 590662 2 ##(Smalltalk.ListModel) 138 144 720 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 466 8 4278190080 nil 7 265030 4 ##(Smalltalk.Menu) nil true 34 5 984134 2 ##(Smalltalk.CommandMenuItem) 1 1266 #removeObject 8 'Remove Object' 1 1 nil nil nil 3538 1 1266 #addObject 8 'Add Object' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 3538 1 1266 #displayMore 8 'Display More' 1025 1 nil nil nil 3538 1 1266 #displayAll 8 'Display All' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 3312 nil 8 4294903835 459270 ##(Smalltalk.Message) #key 8 #() 720 false 754 138 144 34 3 818 #createAt:extent: 34 2 514 1 1 514 387 685 3312 818 #contextMenu: 34 1 3504 3312 818 #horizontalExtent: 8 #(0) 3312 898 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 193 0 0 0 86 1 0 0] 8 #() 2272 nil 27 8 'instVarList' 3008 8 'codePane' nil 754 138 144 34 1 818 #createAt:extent: 34 2 514 1 49 514 1169 685 2880 898 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 24 0 0 0 72 2 0 0 110 1 0 0] 34 3 3312 410 ##(Smalltalk.Splitter) 34 12 nil 2880 34 2 8 1140850688 1 4272 nil 466 8 4278190080 nil 519 nil nil nil 4272 754 138 144 34 1 818 #createAt:extent: 34 2 514 387 1 514 11 685 4272 898 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 193 0 0 0 0 0 0 0 198 0 0 0 86 1 0 0] 8 #() 2272 nil 27 3008 2272 nil 27 170 192 720 nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 2 3490 nil true 34 15 3538 1 1266 #undo 8 '&Undo' 9397 1 nil nil nil 3538 1 1266 #redo 8 'R&edo' 9395 1 nil nil nil 3650 4097 3538 1 1266 #editCut 8 'Cu&t' 9393 1 nil nil nil 3538 1 1266 #editCopy 8 '&Copy' 9351 1 nil nil nil 3538 1 1266 #editPaste 8 '&Paste' 9389 1 nil nil nil 3538 1 1266 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 3538 1 1266 #editDelete 8 '&Delete' 1629 1 nil nil nil 3650 4097 3538 1 1266 #editFind 8 '&Find...' 9357 1 nil nil nil 3538 1 1266 #editFindNext 8 'Find &Next' 9359 1 nil nil nil 3538 1 1266 #editReplace 8 '&Replace...' 9361 1 nil nil nil 3650 4097 3538 1 1266 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 3538 1 1266 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 8 '&Edit' nil 1 nil nil 44463 nil nil 3490 nil true 34 12 3538 1 1266 #abortTransaction 8 '&Abort Transaction' 1 1 nil nil nil 3538 1 1266 #commitTransaction 8 '&Commit Transaction' 1 1 nil nil nil 3650 4097 3538 1 1266 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 3538 1 1266 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 3538 1 1266 #jadeExecute 8 '&Execute' 9355 1 nil nil nil 3538 1 1266 #fileIn 8 'Fi&le In' 1 1 nil nil nil 3650 4097 3538 1 1266 #browseClass 8 '&Browse Class' 9377 1 nil nil nil 3650 4097 3538 1 1266 #displayMore nil 1025 1 nil nil nil 3538 1 1266 #displayAll nil 1 1 nil nil nil 8 '&Jadeite' nil 1 nil nil 44483 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 754 138 144 34 3 818 #createAt:extent: 34 2 514 7679 21 514 1201 901 416 818 #text: 34 1 8 'Jade Object Navigation Inspector' 416 818 #updateMenuBar 720 416 898 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 87 17 0 0 204 1 0 0] 34 3 576 2880 2288 2272 nil 27 )!

showOn: oop session: aGciSession
	| inspector |
	inspector := self new gciSession: aGciSession.
	^inspector inspect: oop inContext: aGciSession oopNil! !
!JadeiteInspector class categoriesFor: #resource_Default_view!public!resources-views! !
!JadeiteInspector class categoriesFor: #showOn:session:!public! !

