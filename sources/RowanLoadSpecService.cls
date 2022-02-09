"Filed out from Dolphin Smallalk"!

RowanInspectorService subclass: #RowanLoadSpecService
	instanceVariableNames: 'loadSpecOop loadSpecPath session comment conditionalAttributes platformProperties'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanLoadSpecService guid: (GUID fromString: '{c09518cc-ba47-4785-b288-a1bea7cfaac6}')!
RowanLoadSpecService comment: ''!
!RowanLoadSpecService categoriesForClass!Unclassified! !
!RowanLoadSpecService methodsFor!

comment
	^comment!

comment: anObject
	comment := anObject!

conditionalAttributes
	^conditionalAttributes!

conditionalAttributes: anObject
	conditionalAttributes := anObject!

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
!RowanLoadSpecService categoriesForMethods!
comment!accessing!private! !
comment:!accessing!private! !
conditionalAttributes!accessing!private! !
conditionalAttributes:!accessing!private! !
excludedInstVars!private!ston! !
loadSpecPath!accessing!private! !
loadSpecPath:!accessing!private! !
session!accessing!private! !
session:!accessing!private! !
!

