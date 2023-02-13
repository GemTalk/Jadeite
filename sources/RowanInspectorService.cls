"Filed out from Dolphin Smallalk"!

RowanService subclass: #RowanInspectorService
	instanceVariableNames: 'oop objects myself className indexedSize visibleIndices nextIndices maxIndexedVars compileErrorArray isOop instVarNames instVarsAreRemovable isDictionary isVariable selectionOop isUnordered statusText name isStringObject'
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

displayName
	"for logging. for now"

	^name!

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
	isDictionary := false.
	isVariable := false. !

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

inspectBytes: oopOrObject session: session inWindow: handle
	oop := (oopOrObject isKindOf: ExternalInteger)
				ifTrue: [oopOrObject value]
				ifFalse: 
					[isOop := false.
					oopOrObject].
	self
		command: #inspectBytes:inWindow:;
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

isStringObject
	^isStringObject!

isUnordered
	^isUnordered!

isUnordered: anObject
	isUnordered := anObject!

isVariable
	^isVariable!

logReceivedOn: aStream
	| myselfString |
	myself ifNil: [^aStream nextPutAll: 'self is nil!!'].
	myselfString := myself printString leftString: 50.
	aStream
		nextPutAll: myselfString;
		space.
	myself printString size > 50 ifTrue: [aStream nextPutAll: '... '].
	aStream nextPutAll: '<oop: ' , oop printString , '>'!

maxIndexedVars
	^maxIndexedVars!

maxIndexedVars: anObject
	maxIndexedVars := anObject!

myself
	^myself!

myself: anObject
	myself := anObject!

name
	^name!

name: aString
	name := aString asString!

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

removeDynamicInstVarsNamed: dynamicInstVarNames session: session
	self
		command: #removeDynamicInstVars:;
		commandArgs: (Array with: dynamicInstVarNames).
	BrowserUpdate current issueCommands: (Array with: self) session: session!

removeIndexedInstVarsAt: indices session: session
	self
		command: #removeIndexedInstVarsAt:;
		commandArgs: (Array with: indices).
	BrowserUpdate current issueCommands: (Array with: self) session: session!

removeKeys: keyOops session: session
	self
		command: #removeKeys:;
		commandArgs: (Array with: keyOops).
	BrowserUpdate current issueCommands: (Array with: self) session: session!

removeOop: theOop session: session
	self
		command: #removeOop:;
		commandArgs: (Array with: theOop).
	BrowserUpdate current issueCommands: (Array with: self) session: session!

selectionOop
	^selectionOop!

sortAspect

	^name!

statusText
	^statusText!

statusText: anObject
	statusText := anObject!

visibleIndices
	^visibleIndices!

visibleIndices: anObject
	visibleIndices := anObject! !
!RowanInspectorService categoriesForMethods!
=!comparison!public! !
className!accessing!private! !
className:!accessing!private! !
compileErrorArray!accessing!private! !
compileErrorArray:!accessing!private! !
defaultIndexedSize!constants!public! !
displayName!displaying!public! !
executeThenInspect:context:session:windowHandle:!inspecting!public! !
executeThenInspect:context:session:windowHandle:debugger:!inspecting!public! !
hash!comparison!private! !
indexedSize!accessing!private! !
indexedSize:!accessing!private! !
initialize!initialization!public! !
inspect:session:!inspecting!public! !
inspect:session:inWindow:!inspecting!public! !
inspectBytes:session:inWindow:!inspecting!public! !
instVarNames!accessing!private! !
instVarNames:!accessing!private! !
instVarsAreRemovable!accessing!private! !
instVarsAreRemovable:!accessing!private! !
isDictionary!accessing!public! !
isInspectorService!public!testing! !
isShowingAllIndexedVars!public!testing! !
isStringObject!accessing!public! !
isUnordered!accessing!private! !
isUnordered:!accessing!private! !
isVariable!accessing!private! !
logReceivedOn:!printing!public! !
maxIndexedVars!accessing!private! !
maxIndexedVars:!accessing!private! !
myself!accessing!private! !
myself:!accessing!private! !
name!accessing!public! !
name:!accessing!public! !
nextIndexedVarsFrom:to:session:!inspecting!public! !
nextIndices!accessing!private! !
nextIndices:!accessing!private! !
objects!accessing!private! !
objects:!accessing!private! !
oop!accessing!private! !
oop:!accessing!private! !
removeDynamicInstVarsNamed:session:!operations!public! !
removeIndexedInstVarsAt:session:!operations!public! !
removeKeys:session:!operations!public! !
removeOop:session:!operations!public! !
selectionOop!accessing!private! !
sortAspect!accessing!public! !
statusText!accessing!private! !
statusText:!accessing!private! !
visibleIndices!accessing!private! !
visibleIndices:!accessing!private! !
!

