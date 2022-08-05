"Filed out from Dolphin Smallalk"!

RowanService subclass: #RowanProcessService
	instanceVariableNames: 'frames oop status name'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanProcessService guid: (GUID fromString: '{ef0255f2-38fa-473c-8886-4f6beea18afa}')!
RowanProcessService comment: ''!
!RowanProcessService categoriesForClass!Kernel-Objects! !
!RowanProcessService methodsFor!

displayName
	"for logging. for now"

	^name!

frameForLevel: anInteger 

	^frames at: anInteger!

frames

	^frames!

gsProcessForSession: session
	^GsProcess session: session oopType: self oopType!

isUpdatableService
	^false!

name
	^name!

name: aString
	name := aString asString!

oop

	^oop!

oop: oopInteger

	oop := oopInteger!

oopType

	^OopType64 fromInteger: oop!

printOn: aStream
	aStream
		nextPutAll: 'RowanProcessService(';
		print: oop;
		nextPutAll: ')';
		yourself!

sortAspect

	^name!

stack

	^frames collect: [:each | each printString]!

terminate
	"temporary until debugger is rewritten"

	"During logout, it's possible that the session may no longer be a session"

	(GciSession current isKindOf: GciSession) ifFalse: [^self].
	(GsProcess session: GciSession current oopType: (GciSession current oopTypeWithOop: oop)) terminate! !
!RowanProcessService categoriesForMethods!
displayName!displaying!public! !
frameForLevel:!public! !
frames!public! !
gsProcessForSession:!public! !
isUpdatableService!public!testing! !
name!accessing!public! !
name:!accessing!public! !
oop!public! !
oop:!public! !
oopType!public! !
printOn:!printing!public! !
sortAspect!accessing!public! !
stack!public! !
terminate!operations!public! !
!

