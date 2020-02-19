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
	^#(#(#fileSave 'Ctrl+S') #(#selectAll 'Ctrl+A') #(#jadeDebug 'Ctrl+B'))!

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
	additionIndex := (self indexedOffsetFromInstVarList: instVarListPresenter selectionByIndex) first.
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

basicRemoveDynamicInstVars
	"remove dynamics, but let sender remove non-dynamics"

	| dynamicInstVarNames firstSelectionIndex nonDynamicsWereSelected selectionIndicesOfDynamics |
	firstSelectionIndex := instVarListPresenter selectionsByIndex first.
	selectionIndicesOfDynamics := instVarListPresenter selectionsByIndex
				select: [:index | '--*' match: (instVarListPresenter list at: index) key].
	dynamicInstVarNames := self selectedDynamicInstVars.
	nonDynamicsWereSelected := instVarListPresenter selections size - dynamicInstVarNames size > 0.
	model removeDynamicInstVarsNamed: dynamicInstVarNames session: gciSession.
	instVarListPresenter
		selectionByIndex: (instVarListPresenter selectionsByIndex difference: selectionIndicesOfDynamics).
	nonDynamicsWereSelected ifFalse: [self displayObjectSelecting: firstSelectionIndex - 1].
	^nonDynamicsWereSelected!

basicRemoveFromDictionary
	| selections newSelectionIndex |
	selections := instVarListPresenter selections collect: [:sel | sel value at: 1].
	self model removeKeys: selections session: gciSession.
	newSelectionIndex := instVarListPresenter selectionByIndex first min: model objects size + 2.
	self displayObjectSelecting: newSelectionIndex.
	(oopsCollection intersection: selections) do: 
			[:removedOop |
			oopsCollection remove: removedOop.
			objectIndex := objectIndex - selections size]!

basicRemoveObjects
	| indices |
	model instVarsAreRemovable ifFalse: [^self].
	self isDynamicInstVarSelected
		ifTrue: [self basicRemoveDynamicInstVars ifFalse: [^self]	"might need to remove other elements"].
	indices := instVarListPresenter selectionByIndex.
	model isDictionary ifTrue: [^self basicRemoveFromDictionary].
	self isNamedInstVarSelected ifTrue: [^MessageBox notify: 'Cannot remove inst var'].	"inst var"
	model isUnordered ifTrue: [^self basicRemoveOop: instVarListPresenter selection value].
	indices first - model instVarNames size <= 0 ifTrue: [^self].
	self basicRemoveObjectsAt: indices!

basicRemoveObjectsAt: indices
	| selections newSelectionIndex |
	selections := instVarListPresenter selections.
	model removeIndexedInstVarsAt: (self indexedOffsetFromInstVarList: indices) session: gciSession.
	newSelectionIndex := indices first
				min: model indexedSize + model instVarNames size + self dynamicInstVars size + 2.
	self displayObjectSelecting: newSelectionIndex.
	(selections collect: [:sel | sel value]) do: 
			[:oop |
			(oopsCollection includes: oop)
				ifTrue: 
					[oopsCollection remove: oop.
					objectIndex := objectIndex - 1]]!

basicRemoveOop: oop
	| selection selectionIndex |
	selection := instVarListPresenter selection.
	self model removeOop: oop session: gciSession.
	selectionIndex := instVarListPresenter selectionByIndex first min: model objects size + 2.
	self displayObjectSelecting: selectionIndex.
	oopsCollection remove: selection first value ifAbsent: [^self].
	objectIndex := objectIndex - 1!

canSave
	^instVarListPresenter selections size = 1
		and: [self isSelfSelected not and: [self isAsOopSelected not]]!

computedListSelections
	^instVarListPresenter selections difference: self nonComputedListSelections!

contextObject
	^model oop!

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
	^self displayMore: model indexedSize!

displayMore
	^self displayMore: model maxIndexedVars + model visibleIndices!

displayMore: stop
	| service |
	service := RowanInspectorService new
				oop: model oop;
				indexedSize: model indexedSize.
	service
		nextIndexedVarsFrom: model visibleIndices + 1
		to: stop
		session: gciSession.
	model objects addAll: service nextIndices.
	model visibleIndices: service visibleIndices.
	self displayObjectSelecting: instVarListPresenter selectionByIndex!

displayObjectSelecting: selectionIndex
	| contents reachedMax |
	contents := model objects copy.	"otherwise the presenter list will notice it's the same object and not update the view"
	(contents isEmpty or: [contents first ~= model myself])
		ifTrue: 
			[contents addFirst: '-.asOop' -> model oop printString.
			contents addFirst: model myself].
	instVarListPresenter list: contents.
	instVarListPresenter selectionByIndex: (selectionIndex
				ifNil: [#(1)]
				ifNotNil: [selectionIndex isNumber ifTrue: [Array with: selectionIndex] ifFalse: [selectionIndex]]).
	reachedMax := model visibleIndices = self maxVariables
				ifTrue: [' (max displayable)']
				ifFalse: [String new].
	model statusText
		ifNil: 
			[model indexedSize > 0
				ifTrue: 
					[statusTextPresenter
						value: 'Displaying ' , model visibleIndices printString , reachedMax , ' of '
								, model indexedSize printString
									, (model isDictionary ifTrue: [' keys'] ifFalse: [' variable inst vars'])]
				ifFalse: [statusTextPresenter value: nil]]
		ifNotNil: [statusTextPresenter value: model statusText].
	className := model className.
	documentPresenter view isModified: false!

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

indexedOffsetFromInstVarList: indices
	^indices
		collect: [:index | index - model instVarNames size - self dynamicInstVars size - 2 max: 0	"2 = self + asOop"]!

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

inspectInNewWindow
	| inspector key oop |
	inspector := JadeiteInspector new gciSession: gciSession.
	oop := instVarListPresenter selections first value.
	key := instVarListPresenter selections first key.
	key = 'self' ifTrue: [oop := model oop].
	key = '-.asOop' ifTrue: [oop := oop asNumber].
	^inspector inspect: (OopType64  fromInteger: oop) inContext: gciSession oopNil value!

inspectInstVar
	| oop |
	"instVarListPresenter selection is <anAssociation>"
	(self isSelfSelected or:[self isAsOopSelected]) ifTrue:[^self]. 
	oop := instVarListPresenter selections first value.
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
	^(instVarListPresenter selections detect: [:assoc | assoc key = '-.asOop'] ifNone: []) notNil!

isDynamicInstVarSelected
	instVarListPresenter selections isEmpty ifTrue: [^false].
	^'--*' match: instVarListPresenter selections first key!

isNamedInstVarSelected
	^model instVarNames includesAnyOf: self selectedNamedInstVars!

isOkayToChange
	documentPresenter view isModified
		ifTrue: [(MessageBox confirm: 'Keep unsaved changes?' caption: 'Unsaved Changes') ifTrue: [^false]].
	documentPresenter view isModified: false. 
	^true!

isProtectedItemSelected
	instVarListPresenter selections isEmpty ifTrue: [^false].
	(instVarListPresenter selectionsByIndex includesAnyOf: #(1 2)) ifTrue: [^true].
	instVarListPresenter selections
		do: [:selection | (('-*' match: selection key) and: [('--*' match: selection key) not]) ifTrue: [^true]].
	^false!

isSelectionComputed: assoc
	^assoc key = 'self' or: [assoc key = '-.asOop']!

isSelfSelected
	^instVarListPresenter selections first key = 'self'!

maxVariables
	"sync with server method RowanInspectorService>>maxVariables"

	^65000!

multipleInstVarsSelected
	| writeStream oops answeringService computedSelections contents boldNeeded |
	documentPresenter view stylerClass: NullScintillaStyler.
	writeStream := WriteStream on: String new.
	oops := self valueOops.	"dictionary"
	answeringService := RowanAnsweringService new.
	answeringService
		command: #printStringOfOops:toMaxSize:;
		commandArgs: (Array with: oops with: self maxPrintStringSize).
	self issueCommand: (Array with: answeringService).
	computedSelections := self computedListSelections.
	boldNeeded := OrderedCollection new.
	computedSelections do: 
			[:assoc |
			boldNeeded add: (writeStream position to: writeStream position + assoc key size).
			writeStream
				nextPutAll: assoc key;
				nextPut: $:;
				space;
				nextPutAll: assoc value;
				cr].
	1 to: oops size
		do: 
			[:index |
			| key |
			key := (instVarListPresenter selections at: index + computedSelections size) key.
			boldNeeded add: (writeStream position to: writeStream position + key size).
			writeStream
				nextPutAll: key;
				nextPut: $:;
				space;
				nextPutAll: (answeringService answer at: index);
				cr].
	contents := writeStream contents.
	contents last = Character lf
		ifTrue: [contents := contents copyFrom: 1 to: contents size - 2	"crlf"].
	documentPresenter value: contents.
	documentPresenter view removeAllStyling.
	boldNeeded do: 
			[:interval |
			documentPresenter view startStylingFrom: interval start.
			documentPresenter view applyStyle: #literalArray toNext: interval size	"serves as a cheap way to get bold text"]!

nonComputedListSelections
	| computedSelections |
	computedSelections := instVarListPresenter selections
				reject: [:assoc | self isSelectionComputed: assoc].
	^computedSelections!

objectIsVariable
	| answeringService |
	model command: #isVariable.
	answeringService := BrowserUpdate current issueCommands: (Array with: self) session: gciSession.
	^answeringService answer!

onCloseRequested: boolValueHolder
	self isOkayToChange ifFalse:[boolValueHolder value: false]. !

printInstVar
	| answeringService printString value |
	^
	[answeringService := RowanAnsweringService new.
	value := instVarListPresenter selections first value. "oop or Array" 
	printString := (value isKindOf: Array) ifTrue: [value at: 2] ifFalse: [value].
	answeringService
		command: #printStringOf:toMaxSize:;
		commandArgs: (Array with: printString with: self maxPrintStringSize).
	self issueCommand: (Array with: answeringService).
	answeringService answer]
			on: Error
			do: [:ex | self displayInstVarError: ex instVar: instVarListPresenter selections first value]!

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
	command = #removeObjects
		ifTrue: 
			[self isProtectedItemSelected
				ifTrue: 
					[query isEnabled: false.
					^true]].
	command = #inspectInNewWindow
		ifTrue: 
			[query isEnabled: instVarListPresenter selections size = 1.
			^true].
	^super queryCommand: query!

registerWindow: handle rootObject: oop
	^RowanBrowserService new
		registerWindow: handle value
		rootObject: oop
		session: self gciSession!

removeObjects
	(MessageBox confirm: 'Really remove selection(s)?') ifFalse: [^self].
	^self basicRemoveObjects!

reportCompileError: ex
	| position text |
	text := (ex list first at: 3) , '>>>>>'.
	position := ex list first at: 2.
	documentPresenter view caretPosition: position.
	documentPresenter view insertText: text at: position.
	^documentPresenter view selectionRange: (position to: position + text size - 1)!

saveDictionaryElement
	| keyOop |
	keyOop := instVarListPresenter selection first value first.
	model
		command: #saveKey:value:;
		commandArgs: (Array with: keyOop with: documentPresenter value).
	self issueCommand: (Array with: model).
	self displayObjectSelecting: instVarListPresenter selectionByIndex!

saveDocument
	(self isSelfSelected or: [self isAsOopSelected])
		ifTrue: [^MessageBox notify: 'Cannot modify Self or the oop'].
	
	[self isDynamicInstVarSelected ifTrue: [^self saveDynamicInstVar].
	self isNamedInstVarSelected ifTrue: [^self saveNamedInstVar].
	model isDictionary ifTrue: [^self saveDictionaryElement].
	model isUnordered ifTrue: [^self saveUnorderedElement].
	self saveIndexedElement]
			on: GsCompileError
			do: [:ex | self reportCompileError: ex]!

saveDynamicInstVar
	| instVarName |
	instVarName := self selectedDynamicInstVars first. "only save when one object selected"
	model
		command: #save:dynamicInstVar:;
		commandArgs: (Array with: documentPresenter value with: instVarName).
	self issueCommand: (Array with: model).
	self displayObjectSelecting: instVarListPresenter selectionByIndex!

saveIndexedElement
	| indices |
	indices := self indexedOffsetFromInstVarList: instVarListPresenter selectionsByIndex.	"should always be one if we get here"
	model
		command: #save:indexedVarAt:;
		commandArgs: (Array with: documentPresenter value with: indices first).
	self issueCommand: (Array with: model).
	self displayObjectSelecting: (self instVarListIndexFromIndexedOffset: indices first)!

saveNamedInstVar
	| index instVarName |
	instVarName := self selectedNamedInstVars first.
	model
		command: #save:namedInstVar:;
		commandArgs: (Array with: documentPresenter value with: instVarName).
	self issueCommand: (Array with: model).
	index := model instVarNames indexOf: instVarName.
	self displayObjectSelecting: index + 2!

saveUnorderedElement
	| oop addedObject newSelectionIndex |
	oop := instVarListPresenter selection first value.
	model
		command: #replaceElement:with:;
		commandArgs: (Array with: oop with: documentPresenter value).
	self issueCommand: (Array with: model).
	addedObject := model objects detect: [:assoc | assoc value = model selectionOop] ifNone: [].
	newSelectionIndex := model objects indexOf: addedObject.
	self displayObjectSelecting: newSelectionIndex + 2!

selectedDynamicInstVars
	"if a named inst var is selected, return it's name as a symbol"

	^instVarListPresenter selections select: [:sel | '--*' match: sel key]
		thenCollect: [:sel | (sel key copyFrom: 3 to: sel key size) asSymbol]!

selectedInstVar
	| string key | 
	instVarListPresenter selections isEmpty
		ifTrue: 
			[documentPresenter value: String new.
			^self].
	instVarListPresenter selections size > 1 ifTrue: [ ^self multipleInstVarsSelected].
	documentPresenter view stylerClass: SmalltalkExpressionStyler.
	key := instVarListPresenter selections first key.
	(key = 'self' or: [key = '-.asOop'])
		ifTrue: 
			[documentPresenter value: instVarListPresenter selections first value.
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

selectedNamedInstVars
	"if a named inst var is selected, return it's name as a symbol"

	^instVarListPresenter selections collect: [:assoc | (assoc key copyWithout: $-) asSymbol]!

setNewInspectedObject
	| oop |
	oop := oopsCollection at: objectIndex.
	self inspectOop: oop!

shouldEnableFileSave: query
	(instVarListPresenter selectionIfNone: [])
		ifNil: [query isEnabled: false]
		ifNotNil: 
			[query
				isEnabled: (documentPresenter view isModified and: 
							[self isSelfSelected not
								and: [self isAsOopSelected not and: [instVarListPresenter selections size = 1]]])]!

showOn: service
	model := service.
	self showShell.
	self displayObjectSelecting: nil.
	self updateCaption.
	self addOop: self model oop!

statusText
	^statusTextPresenter value!

valueOops
	^self nonComputedListSelections
		collect: [:assoc | assoc value isNumber ifTrue: [assoc value] ifFalse: [assoc value last	"dictionary"]]! !
!JadeiteInspector categoriesFor: #aboutToChange:!event handlers!private! !
!JadeiteInspector categoriesFor: #additionalAccelerators!constants!public! !
!JadeiteInspector categoriesFor: #addObject!menu handlers!operations!public! !
!JadeiteInspector categoriesFor: #addOop:!public! !
!JadeiteInspector categoriesFor: #basicAddKey:!menu handlers!menu handlers support!operations!private! !
!JadeiteInspector categoriesFor: #basicAddObject:!menu handlers support!private! !
!JadeiteInspector categoriesFor: #basicRemoveDynamicInstVars!menu handlers support!operations!private! !
!JadeiteInspector categoriesFor: #basicRemoveFromDictionary!menu handlers support!operations!private! !
!JadeiteInspector categoriesFor: #basicRemoveObjects!menu handlers support!operations!private! !
!JadeiteInspector categoriesFor: #basicRemoveObjectsAt:!menu handlers support!operations!private! !
!JadeiteInspector categoriesFor: #basicRemoveOop:!menu handlers support!operations!private! !
!JadeiteInspector categoriesFor: #canSave!private!testing! !
!JadeiteInspector categoriesFor: #computedListSelections!event handlers support!private! !
!JadeiteInspector categoriesFor: #contextObject!private! !
!JadeiteInspector categoriesFor: #createComponents!initialize!public! !
!JadeiteInspector categoriesFor: #createSchematicWiring!initialize!private! !
!JadeiteInspector categoriesFor: #displayAll!displaying!menu handlers!public! !
!JadeiteInspector categoriesFor: #displayMore!displaying!menu handlers!public! !
!JadeiteInspector categoriesFor: #displayMore:!displaying!menu handlers!public! !
!JadeiteInspector categoriesFor: #displayObjectSelecting:!displaying!private! !
!JadeiteInspector categoriesFor: #dynamicInstVars!accessing!public! !
!JadeiteInspector categoriesFor: #evaluateSelectedTextIn:thenInspectInContext:!inspecting!public! !
!JadeiteInspector categoriesFor: #evaluateSelectedTextIn:thenInspectInContext:debugger:!inspecting!public! !
!JadeiteInspector categoriesFor: #expectedModelClass!private! !
!JadeiteInspector categoriesFor: #indexedOffsetFromInstVarList:!operations!private! !
!JadeiteInspector categoriesFor: #initialize!initialize!public! !
!JadeiteInspector categoriesFor: #inspect:inContext:!inspecting!public! !
!JadeiteInspector categoriesFor: #inspectInNewWindow!inspecting!menu handlers!public! !
!JadeiteInspector categoriesFor: #inspectInstVar!inspecting!public! !
!JadeiteInspector categoriesFor: #inspectOop:!inspecting!public! !
!JadeiteInspector categoriesFor: #instVarListIndexFromIndexedOffset:!operations!private! !
!JadeiteInspector categoriesFor: #isAsOopSelected!private!testing! !
!JadeiteInspector categoriesFor: #isDynamicInstVarSelected!private!testing! !
!JadeiteInspector categoriesFor: #isNamedInstVarSelected!private!testing! !
!JadeiteInspector categoriesFor: #isOkayToChange!private!testing! !
!JadeiteInspector categoriesFor: #isProtectedItemSelected!private!testing! !
!JadeiteInspector categoriesFor: #isSelectionComputed:!event handlers support!private! !
!JadeiteInspector categoriesFor: #isSelfSelected!private!testing! !
!JadeiteInspector categoriesFor: #maxVariables!constants!public! !
!JadeiteInspector categoriesFor: #multipleInstVarsSelected!event handlers support!private! !
!JadeiteInspector categoriesFor: #nonComputedListSelections!event handlers support!private! !
!JadeiteInspector categoriesFor: #objectIsVariable!private!testing! !
!JadeiteInspector categoriesFor: #onCloseRequested:!event handlers!public! !
!JadeiteInspector categoriesFor: #printInstVar!displaying!event handlers support!private! !
!JadeiteInspector categoriesFor: #queryCommand:!menu handlers support!private! !
!JadeiteInspector categoriesFor: #registerWindow:rootObject:!private! !
!JadeiteInspector categoriesFor: #removeObjects!menu handlers!operations!public! !
!JadeiteInspector categoriesFor: #reportCompileError:!menu handlers support!private! !
!JadeiteInspector categoriesFor: #saveDictionaryElement!menu handlers support!private! !
!JadeiteInspector categoriesFor: #saveDocument!menu handlers!public! !
!JadeiteInspector categoriesFor: #saveDynamicInstVar!menu handlers support!private! !
!JadeiteInspector categoriesFor: #saveIndexedElement!menu handlers support!private! !
!JadeiteInspector categoriesFor: #saveNamedInstVar!menu handlers support!private! !
!JadeiteInspector categoriesFor: #saveUnorderedElement!menu handlers support!private! !
!JadeiteInspector categoriesFor: #selectedDynamicInstVars!private! !
!JadeiteInspector categoriesFor: #selectedInstVar!accessing!event handlers!private! !
!JadeiteInspector categoriesFor: #selectedNamedInstVars!private! !
!JadeiteInspector categoriesFor: #setNewInspectedObject!public! !
!JadeiteInspector categoriesFor: #shouldEnableFileSave:!private!testing! !
!JadeiteInspector categoriesFor: #showOn:!displaying!public! !
!JadeiteInspector categoriesFor: #statusText!accessing!public! !
!JadeiteInspector categoriesFor: #valueOops!event handlers support!private! !

!JadeiteInspector class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1201 901 549 nil nil nil 416 788230 ##(Smalltalk.BorderLayout) 1 1 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 560 nil 466 #face3d nil 7 nil nil nil 560 1180166 ##(Smalltalk.ProportionalLayout) 170 176 8 #() false 170 192 688 nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 1 1 498 1169 49 560 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 24 0 0 0] 34 1 410 ##(Smalltalk.Toolbar) 34 25 nil 560 34 2 8 1409288972 131137 928 nil 480 nil 519 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 498 193 193 nil 928 480 8 1660202272 170 192 688 170 192 34 8 21951 1115206 1 ##(Smalltalk.ToolbarIconButton) 928 1 1180998 4 ##(Smalltalk.CommandDescription) #addObject 8 'Add Object' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons\CompiledMethod.ico' nil 21951 21949 1154 928 1 1186 #removeObjects 8 'Remove Objects' 1 1 1234 nil true 1280 8 'icons\False.ico' nil 21949 21947 1154 928 1 1186 #getNextObject 8 'Dive' 1 1 1234 nil true 1280 8 'HistoryForward.ico' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil 21947 21945 1154 928 1 1186 #getPreviousObject 8 'Back' 1 1 1234 nil true 1280 8 'HistoryBack.ico' 1488 21945 34 5 1520 1392 1049158 1 ##(Smalltalk.ToolbarSeparator) 928 1 1312 1168 nil nil 1 nil 498 33 33 498 45 45 nil 656198 1 ##(Smalltalk.FlowLayout) 1 1 1 722 138 144 34 2 786 #createAt:extent: 34 2 498 1 1 498 1169 49 928 786 #updateSizePosted 688 928 866 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 24 0 0 0] 8 #() 498 193 193 nil 27 1888 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 1904 nil nil nil 7 nil nil nil 1904 nil 170 192 34 2 410 ##(Smalltalk.MultilineTextEdit) 34 16 nil 1904 34 2 8 1140855044 65 2000 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 7 nil nil nil 2000 nil 8 1660100096 852486 ##(Smalltalk.NullConverter) nil nil 11 722 138 144 34 3 786 #createAt:extent: 34 2 498 1 1 498 1169 47 2000 786 #text: 34 1 8 'Static Text' 2000 786 #setMarginWidths: 34 1 8 #(3 3) 2000 866 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 23 0 0 0] 8 #() 1888 nil 27 8 'statusText' nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 1 733 498 1169 51 1904 866 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 110 1 0 0 72 2 0 0 135 1 0 0] 34 1 2000 1888 nil 27 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 2608 nil 624 nil 7 nil nil nil 2608 642 170 176 34 4 410 ##(Smalltalk.MultipleSelectionListBox) 34 17 nil 2608 34 2 8 1144064257 1025 2720 590662 2 ##(Smalltalk.ListModel) 138 144 688 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 265030 4 ##(Smalltalk.Menu) nil true 34 7 984134 2 ##(Smalltalk.CommandMenuItem) 1 1186 #removeObjects 8 'Remove Objects' 1 1 nil nil nil 2914 1 1186 #addObject 8 'Add Object' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 2914 1 1186 #displayMore 8 'Display More' 1025 1 nil nil nil 2914 1 1186 #displayAll 8 'Display All' 1 1 nil nil nil 3026 4097 2914 1 1186 #inspectInNewWindow 8 'Inspect' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 2720 nil 8 1660762976 459270 ##(Smalltalk.Message) #key 8 #() 688 nil 722 138 144 34 4 786 #createAt:extent: 34 2 498 1 1 498 387 685 2720 786 #contextMenu: 34 1 2880 2720 786 #caretIndex: 8 #(1) 2720 786 #horizontalExtent: 8 #(0) 2720 866 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 193 0 0 0 86 1 0 0] 8 #() 1888 nil 27 3 410 ##(Smalltalk.ReferenceView) 34 14 nil 2608 34 2 8 1140850688 131073 3552 nil 480 nil 7 nil nil nil 3552 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.CodeSourcePresenter) #resource_Default_view nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 397 1 498 773 685 3552 866 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 198 0 0 0 0 0 0 0 72 2 0 0 86 1 0 0] 688 1888 nil 27 5 false 170 192 34 4 2720 8 'instVarList' 3552 8 'codePane' nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 1 49 498 1169 685 2608 866 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 24 0 0 0 72 2 0 0 110 1 0 0] 34 3 2720 410 ##(Smalltalk.Splitter) 34 12 nil 2608 34 2 8 1140850688 1 4016 nil 480 nil 519 nil nil nil 1510470 1 ##(Smalltalk.DraggableViewInteractor) 4016 nil 1 #left nil nil nil 498 1 1 498 9 9 nil 4112 nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 387 1 498 11 685 4016 866 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 193 0 0 0 0 0 0 0 198 0 0 0 86 1 0 0] 8 #() 1888 nil 27 3552 1888 nil 27 170 192 688 nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 2 2866 nil true 34 15 2914 1 1186 #undo 8 '&Undo' 9397 1 nil nil nil 2914 1 1186 #redo 8 'R&edo' 9395 1 nil nil nil 3026 4097 2914 1 1186 #editCut 8 'Cu&t' 9393 1 nil nil nil 2914 1 1186 #editCopy 8 '&Copy' 9351 1 nil nil nil 2914 1 1186 #editPaste 8 '&Paste' 9389 1 nil nil nil 2914 1 1186 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 2914 1 1186 #editDelete 8 '&Delete' 1629 1 nil nil nil 3026 4097 2914 1 1186 #editFind 8 '&Find...' 9357 1 nil nil nil 2914 1 1186 #editFindNext 8 'Find &Next' 9359 1 nil nil nil 2914 1 1186 #editReplace 8 '&Replace...' 9361 1 nil nil nil 3026 4097 2914 1 1186 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 2914 1 1186 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 8 '&Edit' nil 1 nil nil 21923 nil nil 2866 nil true 34 12 2914 1 1186 #abortTransaction 8 '&Abort Transaction' 1 1 nil nil nil 2914 1 1186 #commitTransaction 8 '&Commit Transaction' 1 1 nil nil nil 3026 4097 2914 1 1186 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 2914 1 1186 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 2914 1 1186 #jadeExecute 8 '&Execute' 9355 1 nil nil nil 2914 1 1186 #fileIn 8 'Fi&le In' 1 1 nil nil nil 3026 4097 2914 1 1186 #browseClass 8 '&Browse Class' 9377 1 nil nil nil 3026 4097 2914 1 1186 #displayMore nil 1025 1 nil nil nil 2914 1 1186 #displayAll nil 1 1 nil nil nil 8 '&Jadeite' nil 1 nil nil 21943 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 722 138 144 34 3 786 #createAt:extent: 34 2 498 7679 21 498 1201 901 416 786 #text: 34 1 8 'Jade Object Navigation Inspector' 416 786 #updateMenuBar 688 416 866 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 87 17 0 0 204 1 0 0] 34 3 560 2608 1904 1888 nil 27 )!

showOn: oop session: aGciSession
	| inspector |
	inspector := self new gciSession: aGciSession.
	^inspector inspect: oop inContext: aGciSession oopNil! !
!JadeiteInspector class categoriesFor: #resource_Default_view!public!resources-views! !
!JadeiteInspector class categoriesFor: #showOn:session:!public! !

