"Filed out from Dolphin Smallalk"!

RowanComponentDefinitionService subclass: #RowanPackageGroupService
	instanceVariableNames: 'condition'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanPackageGroupService guid: (GUID fromString: '{b1767a68-7a64-41dd-b0d1-187de3d85dde}')!
RowanPackageGroupService comment: ''!
!RowanPackageGroupService categoriesForClass!Unclassified! !
!RowanPackageGroupService methodsFor!

condition
	^condition!

condition: anObject
	condition := anObject!

indexOfProjectDefinitionService
	^12!

renamePackageGroupTo: newPackageGroupName
	projectDefinitionService renamePackageGroup: name to: newPackageGroupName.
	name := newPackageGroupName!

setCondition: newCondition
	condition := newCondition. 
	projectDefinitionService addPackageGroupNamed: name condition: newCondition.!

shouldReplicateInstVarAtIndex: index newService: newService
	(super shouldReplicateInstVarAtIndex: index newService: newService) ifFalse:[^false]. 
	self indexOfProjectDefinitionService = index ifTrue: [^false].
	^true! !
!RowanPackageGroupService categoriesForMethods!
condition!accessing!private! !
condition:!accessing!private! !
indexOfProjectDefinitionService!public!replication! !
renamePackageGroupTo:!commands!public! !
setCondition:!commands!public! !
shouldReplicateInstVarAtIndex:newService:!public!replication! !
!

