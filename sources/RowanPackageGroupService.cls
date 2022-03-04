"Filed out from Dolphin Smallalk"!

RowanComponentDefinitionService subclass: #RowanPackageGroupService
	instanceVariableNames: 'condition packageServices'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanPackageGroupService guid: (GUID fromString: '{b1767a68-7a64-41dd-b0d1-187de3d85dde}')!
RowanPackageGroupService comment: ''!
!RowanPackageGroupService categoriesForClass!Unclassified! !
!RowanPackageGroupService methodsFor!

componentPackagesUpdate: presenter browser: browser
	wasUpdated ifFalse:[^self].
	packageServices isEmpty ifTrue:[^self]. 
	self
		packagesUpdate: presenter
		browser: browser
		parentPresenter: browser componentListPresenter!

condition
	^condition!

condition: anObject
	condition := anObject!

indexOfProjectDefinitionService
	^12!

packageServices
	^packageServices!

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
componentPackagesUpdate:browser:!public!updating! !
condition!accessing!private! !
condition:!accessing!private! !
indexOfProjectDefinitionService!public!replication! !
packageServices!accessing!public! !
renamePackageGroupTo:!commands!public! !
setCondition:!commands!public! !
shouldReplicateInstVarAtIndex:newService:!public!replication! !
!

!RowanPackageGroupService class methodsFor!

all 
	"special package group for displaying all packages in the project" 
	| inst | 
	inst := self new. 
	inst name: 'All Packages'. 
	^inst! !
!RowanPackageGroupService class categoriesForMethods!
all!instance creation!public! !
!

