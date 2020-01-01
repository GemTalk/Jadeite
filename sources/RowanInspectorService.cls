"Filed out from Dolphin Smalltalk 7"!

RowanService subclass: #RowanInspectorService
	instanceVariableNames: 'oop objects myself className indexedSize visibleIndices nextIndices maxIndexedVars compileErrorArray isOop instVarNames instVarsAreRemovable isDictionary'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanInspectorService guid: (GUID fromString: '{b80c7b87-3ce0-4b36-a288-1e52506958dd}')!
RowanInspectorService comment: ''!
!RowanInspectorService categoriesForClass!Unclassified! !
!RowanInspectorService methodsFor!

= inspectorService
	^inspectorService isInspectorService ifTrue: [oop = inspectorService oop] ifFalse: [false]!

className
	^className!

className: anObject
	className := anObject!

compileErrorArray
	^compileErrorArray!

compileErrorArray: anObject
	compileErrorArray := anObject!

defaultIndexedSize
	^1000!

executeThenInspect: string context: anOop session: session windowHandle: handle
	self
		command: #executeThenInspect:context:inWindow:;
		commandArgs: (Array
					with: string
					with: anOop
					with: handle).
	BrowserUpdate current issueCommands: (Array with: self) session: session!

executeThenInspect: string context: anOop session: session windowHandle: handle debugger: debugger
	self
		command: #executeThenInspect:inFrame:process:context:inWindow:;
		commandArgs: (Array
					with: string
					with: debugger frameListPresenter selectionByIndex
					with: debugger gsProcess oop
					with: anOop
					with: handle).
	BrowserUpdate current issueCommands: (Array with: self) session: session!

hash
	^oop hash!

indexedSize
	^indexedSize!

indexedSize: anObject
	indexedSize := anObject!

initialize
	super initialize. 
	objects := OrderedCollection new. 
	maxIndexedVars := self defaultIndexedSize.
	indexedSize := 0.
	isOop := true. 
	isDictionary := false.!

inspect: oopOrObject session: session
	oop := (oopOrObject isKindOf: ExternalInteger)
				ifTrue: [oopOrObject value]
				ifFalse: 
					[isOop := false.
					oopOrObject].
	self
		command: #inspect:;
		commandArgs: (Array with: oop).
	BrowserUpdate current issueCommands: (Array with: self) session: session!

inspect: oopOrObject session: session inWindow: handle
	oop := (oopOrObject isKindOf: ExternalInteger)
				ifTrue: [oopOrObject value]
				ifFalse: 
					[isOop := false.
					oopOrObject].
	self
		command: #inspect:inWindow:;
		commandArgs: (Array with: oop with: handle).
	BrowserUpdate current issueCommands: (Array with: self) session: session!

instVarNames
	^instVarNames!

instVarNames: anObject
	instVarNames := anObject!

instVarsAreRemovable
	^instVarsAreRemovable!

instVarsAreRemovable: anObject
	instVarsAreRemovable := anObject!

isDictionary
	^isDictionary!

isInspectorService

	^true!

isShowingAllIndexedVars

	^visibleIndices = indexedSize!

maxIndexedVars
	^maxIndexedVars!

maxIndexedVars: anObject
	maxIndexedVars := anObject!

myself
	^myself!

myself: anObject
	myself := anObject!

nextIndexedVarsFrom: indexStart to: indexStop session: session
	self
		command: #nextIndexedVarsFrom:to:;
		commandArgs: (Array with: indexStart with: indexStop).
	BrowserUpdate current issueCommands: (Array with: self) session: session.
	^nextIndices!

nextIndices
	^nextIndices!

nextIndices: anObject
	nextIndices := anObject!

objects
	^objects!

objects: anObject
	objects := anObject!

oop
	^oop!

oop: anObject
	oop := anObject!

removeIndexedInstVarAt: index session: session
	self
		command: #removeIndexedInstVarAt:;
		commandArgs: (Array with: index).
	BrowserUpdate current issueCommands: (Array with: self) session: session!

removeKey: keyOop session: session
	self
		command: #removeKey:;
		commandArgs: (Array with: keyOop).
	BrowserUpdate current issueCommands: (Array with: self) session: session!

visibleIndices
	^visibleIndices!

visibleIndices: anObject
	visibleIndices := anObject! !
!RowanInspectorService categoriesFor: #=!comparison!public! !
!RowanInspectorService categoriesFor: #className!accessing!private! !
!RowanInspectorService categoriesFor: #className:!accessing!private! !
!RowanInspectorService categoriesFor: #compileErrorArray!accessing!private! !
!RowanInspectorService categoriesFor: #compileErrorArray:!accessing!private! !
!RowanInspectorService categoriesFor: #defaultIndexedSize!constants!public! !
!RowanInspectorService categoriesFor: #executeThenInspect:context:session:windowHandle:!inspecting!public! !
!RowanInspectorService categoriesFor: #executeThenInspect:context:session:windowHandle:debugger:!inspecting!public! !
!RowanInspectorService categoriesFor: #hash!comparison!private! !
!RowanInspectorService categoriesFor: #indexedSize!accessing!private! !
!RowanInspectorService categoriesFor: #indexedSize:!accessing!private! !
!RowanInspectorService categoriesFor: #initialize!initialization!public! !
!RowanInspectorService categoriesFor: #inspect:session:!inspecting!public! !
!RowanInspectorService categoriesFor: #inspect:session:inWindow:!inspecting!public! !
!RowanInspectorService categoriesFor: #instVarNames!accessing!private! !
!RowanInspectorService categoriesFor: #instVarNames:!accessing!private! !
!RowanInspectorService categoriesFor: #instVarsAreRemovable!accessing!private! !
!RowanInspectorService categoriesFor: #instVarsAreRemovable:!accessing!private! !
!RowanInspectorService categoriesFor: #isDictionary!accessing!public! !
!RowanInspectorService categoriesFor: #isInspectorService!public!testing! !
!RowanInspectorService categoriesFor: #isShowingAllIndexedVars!public!testing! !
!RowanInspectorService categoriesFor: #maxIndexedVars!accessing!private! !
!RowanInspectorService categoriesFor: #maxIndexedVars:!accessing!private! !
!RowanInspectorService categoriesFor: #myself!accessing!private! !
!RowanInspectorService categoriesFor: #myself:!accessing!private! !
!RowanInspectorService categoriesFor: #nextIndexedVarsFrom:to:session:!inspecting!public! !
!RowanInspectorService categoriesFor: #nextIndices!accessing!private! !
!RowanInspectorService categoriesFor: #nextIndices:!accessing!private! !
!RowanInspectorService categoriesFor: #objects!accessing!private! !
!RowanInspectorService categoriesFor: #objects:!accessing!private! !
!RowanInspectorService categoriesFor: #oop!accessing!private! !
!RowanInspectorService categoriesFor: #oop:!accessing!private! !
!RowanInspectorService categoriesFor: #removeIndexedInstVarAt:session:!operations!public! !
!RowanInspectorService categoriesFor: #removeKey:session:!operations!public! !
!RowanInspectorService categoriesFor: #visibleIndices!accessing!private! !
!RowanInspectorService categoriesFor: #visibleIndices:!accessing!private! !

