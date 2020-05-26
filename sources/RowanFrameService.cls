"Filed out from Dolphin Smalltalk 7"!

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
!RowanFrameService categoriesFor: #breaks!public! !
!RowanFrameService categoriesFor: #classIsResolvable!accessing!private! !
!RowanFrameService categoriesFor: #copyBasicsFrom:!public! !
!RowanFrameService categoriesFor: #displayName!displaying!public! !
!RowanFrameService categoriesFor: #gsMethod!public! !
!RowanFrameService categoriesFor: #homeMethodClassName!accessing!public! !
!RowanFrameService categoriesFor: #homeMethodSelector!accessing!public! !
!RowanFrameService categoriesFor: #indexOfSubCollection:!public! !
!RowanFrameService categoriesFor: #isExecutedBlockContext!public!testing! !
!RowanFrameService categoriesFor: #isUpdatableService!public!testing! !
!RowanFrameService categoriesFor: #label!accessing!public! !
!RowanFrameService categoriesFor: #method!public! !
!RowanFrameService categoriesFor: #name!accessing!public! !
!RowanFrameService categoriesFor: #name:!accessing!public! !
!RowanFrameService categoriesFor: #offsets!public! !
!RowanFrameService categoriesFor: #oop!accessing!private! !
!RowanFrameService categoriesFor: #oop:!accessing!private! !
!RowanFrameService categoriesFor: #printOn:!public! !
!RowanFrameService categoriesFor: #sortAspect!accessing!public! !
!RowanFrameService categoriesFor: #source!public! !
!RowanFrameService categoriesFor: #stepPoint!public! !
!RowanFrameService categoriesFor: #vars!public! !

