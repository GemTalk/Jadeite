"Filed out from Dolphin Smallalk"!

RowanService subclass: #RowanDefinitionService
	instanceVariableNames: 'name properties session'
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

excludedInstVars

	^super excludedInstVars , #('session')!

hash
	^self name hash!

indexOfSessionInstVar
	^10!

isDefinitionService

	^true!

name
	^name!

name: anObject
	name := anObject!

properties
	^properties!

properties: anObject
	properties := anObject!

session
	^session!

session: anObject
	session := anObject!

shouldReplicateInstVarAtIndex: index newService: newService
	self indexOfSessionInstVar = index ifTrue: [^false].
	^true! !
!RowanDefinitionService categoriesForMethods!
=!comparing!public! !
excludedInstVars!public!ston! !
hash!comparing!public! !
indexOfSessionInstVar!public!replication! !
isDefinitionService!public!testing! !
name!accessing!private! !
name:!accessing!private! !
properties!accessing!private! !
properties:!accessing!private! !
session!accessing!private! !
session:!accessing!private! !
shouldReplicateInstVarAtIndex:newService:!public!replication! !
!

