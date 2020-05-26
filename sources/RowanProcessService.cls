"Filed out from Dolphin Smalltalk 7"!

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
	(GsProcess session: GciSession current oopType: (GciSession current oopTypeWithOop: oop))
		terminate.
	
	! !
!RowanProcessService categoriesFor: #displayName!displaying!public! !
!RowanProcessService categoriesFor: #frameForLevel:!public! !
!RowanProcessService categoriesFor: #frames!public! !
!RowanProcessService categoriesFor: #gsProcessForSession:!public! !
!RowanProcessService categoriesFor: #isUpdatableService!public!testing! !
!RowanProcessService categoriesFor: #name!accessing!public! !
!RowanProcessService categoriesFor: #name:!accessing!public! !
!RowanProcessService categoriesFor: #oop!public! !
!RowanProcessService categoriesFor: #oop:!public! !
!RowanProcessService categoriesFor: #oopType!public! !
!RowanProcessService categoriesFor: #printOn:!printing!public! !
!RowanProcessService categoriesFor: #sortAspect!accessing!public! !
!RowanProcessService categoriesFor: #stack!public! !
!RowanProcessService categoriesFor: #terminate!operations!public! !

