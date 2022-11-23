"Filed out from Dolphin Smallalk"!

RowanService subclass: #RowanVariableService
	instanceVariableNames: 'oop key value className name'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanVariableService guid: (GUID fromString: '{7fef01ea-b803-4a8a-bb67-843c948bbc31}')!
RowanVariableService comment: ''!
!RowanVariableService categoriesForClass!Kernel-Objects! !
!RowanVariableService methodsFor!

_key

	^key!

className

	^className!

displayName
	"for logging. for now"

	^name!

displayOop

	^oop printString!

displayStringOn: displayThing!

isDisplayLabel
	^false!

isUpdatableService
	^false!

key
	"provided to match expectation of UI for JadeDebugger"

	^oop printString -> key!

name
	^name!

name: aString
	name := aString asString!

oop

	^oop!

printOn: aStream
	super printOn: aStream.
	aStream
		nextPutAll: '( ';
		print: key;
		space;
		nextPutAll: '->';
		space;
		print: value;
		nextPutAll: ' )'!

sortAspect

	^name!

updateVariable: listPresenter debugger: debugger
	listPresenter list
		do: [:variableService | variableService _key = key ifTrue: [variableService replicateFrom: self]].
	listPresenter list: listPresenter list.
	listPresenter view invalidate.!

value
	^value! !
!RowanVariableService categoriesForMethods!
_key!public! !
className!public! !
displayName!displaying!public! !
displayOop!printing!public! !
displayStringOn:!printing!public! !
isDisplayLabel!public!testing! !
isUpdatableService!public!testing! !
key!public! !
name!accessing!public! !
name:!accessing!public! !
oop!public! !
printOn:!printing!public! !
sortAspect!accessing!public! !
updateVariable:debugger:!public!updating! !
value!public! !
!

