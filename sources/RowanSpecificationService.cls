"Filed out from Dolphin Smallalk"!

RowanInspectorService subclass: #RowanSpecificationService
	instanceVariableNames: 'loadSpecOop loadSpecPath session'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanSpecificationService guid: (GUID fromString: '{c09518cc-ba47-4785-b288-a1bea7cfaac6}')!
RowanSpecificationService comment: ''!
!RowanSpecificationService categoriesForClass!Unclassified! !
!RowanSpecificationService methodsFor!

excludedInstVars

	^super excludedInstVars , #('session')!

loadSpecPath
	^loadSpecPath!

loadSpecPath: anObject
	loadSpecPath := anObject!

session
	^session!

session: anObject
	session := anObject! !
!RowanSpecificationService categoriesForMethods!
excludedInstVars!private!ston! !
loadSpecPath!accessing!private! !
loadSpecPath:!accessing!private! !
session!accessing!private! !
session:!accessing!private! !
!

