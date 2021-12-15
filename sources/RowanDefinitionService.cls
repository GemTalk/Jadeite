"Filed out from Dolphin Smallalk"!

RowanService subclass: #RowanDefinitionService
	instanceVariableNames: 'name properties'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanDefinitionService guid: (GUID fromString: '{0b5e75f1-b946-476e-a2e0-7d358db0c680}')!
RowanDefinitionService comment: ''!
!RowanDefinitionService categoriesForClass!Unclassified! !
!RowanDefinitionService methodsFor!

= definitionService
	^definitionService isService
		and: [definitionService isDefinitionService and: [name = definitionService name]]!

hash
	^self name hash!

isDefinitionService

	^true!

name
	^name!

name: anObject
	name := anObject!

properties
	^properties!

properties: anObject
	properties := anObject! !
!RowanDefinitionService categoriesForMethods!
=!comparing!public! !
hash!comparing!public! !
isDefinitionService!public!testing! !
name!accessing!private! !
name:!accessing!private! !
properties!accessing!private! !
properties:!accessing!private! !
!

