"Filed out from Dolphin Smallalk"!

RowanService subclass: #RowanFrameService
	instanceVariableNames: 'label method stepPoint vars oop homeMethodSelector homeMethodClassName classIsResolvable name'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanFrameService guid: (GUID fromString: '{65407af5-8317-4fa0-a86d-7b9543e85cd0}')!
RowanFrameService comment: ''!
!RowanFrameService categoriesForClass!Kernel-Objects! !
!RowanFrameService methodsFor!

breaks

	^method breakPoints!

classIsResolvable
	^classIsResolvable!

copyBasicsFrom: oldService

	method := RowanMethodService new copyBasicsFrom: oldService method.
!

displayName
	"for logging. for now"

	^name!

gsMethod

	^method!

homeMethodClassName

	^homeMethodClassName!

homeMethodSelector

	^homeMethodSelector!

indexOfSubCollection: aString 

	^method source indexOfSubCollection: aString !

isExecutedBlockContext

	^method className isNil!

isUpdatableService
	^false!

label

	^label!

method
	^method!

name
	^name!

name: aString
	name := aString asString!

offsets

	^method stepPoints collect: [:each | each key start]!

oop
	^oop!

oop: anObject
	oop := anObject!

printOn: aStream

	aStream nextPutAll: (label ifNil: ['?'])
!

sortAspect

	^name!

source

	^method source!

stepPoint
	^stepPoint!

vars
	^vars! !
!RowanFrameService categoriesForMethods!
breaks!public! !
classIsResolvable!accessing!private! !
copyBasicsFrom:!public! !
displayName!displaying!public! !
gsMethod!public! !
homeMethodClassName!accessing!public! !
homeMethodSelector!accessing!public! !
indexOfSubCollection:!public! !
isExecutedBlockContext!public!testing! !
isUpdatableService!public!testing! !
label!accessing!public! !
method!public! !
name!accessing!public! !
name:!accessing!public! !
offsets!public! !
oop!accessing!private! !
oop:!accessing!private! !
printOn:!public! !
sortAspect!accessing!public! !
source!public! !
stepPoint!public! !
vars!public! !
!

