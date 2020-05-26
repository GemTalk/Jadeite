"Filed out from Dolphin Smalltalk 7"!

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
!RowanVariableService categoriesFor: #_key!public! !
!RowanVariableService categoriesFor: #className!public! !
!RowanVariableService categoriesFor: #displayName!displaying!public! !
!RowanVariableService categoriesFor: #isUpdatableService!public!testing! !
!RowanVariableService categoriesFor: #key!public! !
!RowanVariableService categoriesFor: #name!accessing!public! !
!RowanVariableService categoriesFor: #name:!accessing!public! !
!RowanVariableService categoriesFor: #oop!public! !
!RowanVariableService categoriesFor: #printOn:!printing!public! !
!RowanVariableService categoriesFor: #sortAspect!accessing!public! !
!RowanVariableService categoriesFor: #updateVariable:debugger:!public!updating! !
!RowanVariableService categoriesFor: #value!public! !

