"Filed out from Dolphin Smallalk"!

RowanComponentDefinitionService subclass: #RowanPackageGroupService
	instanceVariableNames: 'condition packageServices projectName'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanPackageGroupService guid: (GUID fromString: '{b1767a68-7a64-41dd-b0d1-187de3d85dde}')!
RowanPackageGroupService comment: ''!
!RowanPackageGroupService categoriesForClass!Unclassified! !
!RowanPackageGroupService methodsFor!

allPackageGroupForProjectDefinition: projectDef
	command := #computePackageNames.
	commandArgs := Array new.
	self issueCommand: self session: session!

componentPackagesUpdate: presenter browser: browser
	wasUpdated ifFalse:[^self].
	packageServices isEmpty ifTrue:[^self]. 
	self
		packagesUpdate: presenter
		browser: browser
		parentPresenter: browser packageGroupPresenter!

condition
	^condition!

condition: anObject
	condition := anObject!

indexOfProjectDefinitionService
	^13!

packageServices
	^packageServices!

projectName: anObject
	projectName := anObject!

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
allPackageGroupForProjectDefinition:!instance creation!public! !
componentPackagesUpdate:browser:!public!updating! !
condition!accessing!private! !
condition:!accessing!private! !
indexOfProjectDefinitionService!public!replication! !
packageServices!accessing!public! !
projectName:!accessing!private! !
renamePackageGroupTo:!commands!public! !
setCondition:!commands!public! !
shouldReplicateInstVarAtIndex:newService:!public!replication! !
!

!RowanPackageGroupService class methodsFor!

allPackageGroupForProjectDefinition: projectDef 
	"special package group for displaying all packages in the project" 
	^self new allPackageGroupForProjectDefinition: projectDef ! !
!RowanPackageGroupService class categoriesForMethods!
allPackageGroupForProjectDefinition:!instance creation!public! !
!

