"Filed out from Dolphin Smalltalk 7"!

RowanService subclass: #RowanVariableService
	instanceVariableNames: 'oop key value className'
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

isUpdatableService
	^false!

key
	"provided to match expectation of UI for JadeDebugger"

	^oop printString -> key!

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

updateVariable: listPresenter debugger: debugger
	listPresenter list
		do: [:variableService | variableService _key = key ifTrue: [variableService replicateFrom: self]].
	listPresenter list: listPresenter list.
	listPresenter view invalidate.!

value

	^value! !
!RowanVariableService categoriesFor: #_key!public! !
!RowanVariableService categoriesFor: #className!public! !
!RowanVariableService categoriesFor: #isUpdatableService!public!testing! !
!RowanVariableService categoriesFor: #key!public! !
!RowanVariableService categoriesFor: #oop!public! !
!RowanVariableService categoriesFor: #printOn:!printing!public! !
!RowanVariableService categoriesFor: #updateVariable:debugger:!public!updating! !
!RowanVariableService categoriesFor: #value!public! !

