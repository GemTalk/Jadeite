"Filed out from Dolphin Smalltalk 7"!

RowanService subclass: #RowanDebuggerService
	instanceVariableNames: 'initialProcessOop processes name'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanDebuggerService guid: (GUID fromString: '{d8a038cb-84e2-4e03-bff9-1dc3bf097d57}')!
RowanDebuggerService comment: ''!
!RowanDebuggerService categoriesForClass!Kernel-Objects! !
!RowanDebuggerService methodsFor!

displayName
	"for logging. for now"

	^name!

initialize: aGsProcess

	initialProcessOop := aGsProcess oopType value.
!

name
	^name!

name: aString
	name := aString asString!

processes
	^processes!

processListUpdate: aPresenter
	aPresenter parentPresenter gsProcess ifNil:[^self]. 
	aPresenter parentPresenter gsProcess oop = processes first oop ifFalse: [^self].
	aPresenter list: processes!

sortAspect

	^name! !
!RowanDebuggerService categoriesFor: #displayName!displaying!public! !
!RowanDebuggerService categoriesFor: #initialize:!public! !
!RowanDebuggerService categoriesFor: #name!accessing!public! !
!RowanDebuggerService categoriesFor: #name:!accessing!public! !
!RowanDebuggerService categoriesFor: #processes!accessing!public! !
!RowanDebuggerService categoriesFor: #processListUpdate:!Debugger!public!updating! !
!RowanDebuggerService categoriesFor: #sortAspect!accessing!public! !

!RowanDebuggerService class methodsFor!

onProcess: aGsProcess

	^self basicNew
		initialize: aGsProcess;
		yourself! !
!RowanDebuggerService class categoriesFor: #onProcess:!public! !

