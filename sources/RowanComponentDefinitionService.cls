"Filed out from Dolphin Smallalk"!

RowanDefinitionService subclass: #RowanComponentDefinitionService
	instanceVariableNames: 'subcomponentDefinitions packageNames projectDefinitionService preloadDoitName postloadDoitName projectNames comment'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanComponentDefinitionService guid: (GUID fromString: '{5843d4f0-ef18-48bc-bb42-37ec2b129736}')!
RowanComponentDefinitionService comment: ''!
!RowanComponentDefinitionService categoriesForClass!Unclassified! !
!RowanComponentDefinitionService methodsFor!

comment
	^comment!

comment: anObject
	comment := anObject!

packageNames
	^packageNames!

packageNames: anObject
	packageNames := anObject!

postloadDoitName
	^postloadDoitName!

postloadDoitName: anObject
	postloadDoitName := anObject!

preloadDoitName
	^preloadDoitName!

preloadDoitName: anObject
	preloadDoitName := anObject!

printOn: aStream
	aStream nextPutAll: name!

projectDefinitionService
	^projectDefinitionService!

projectDefinitionService: anObject
	projectDefinitionService := anObject!

projectNames
	^projectNames!

projectNames: anObject
	projectNames := anObject! !
!RowanComponentDefinitionService categoriesForMethods!
comment!accessing!private! !
comment:!accessing!private! !
packageNames!accessing!private! !
packageNames:!accessing!private! !
postloadDoitName!accessing!private! !
postloadDoitName:!accessing!private! !
preloadDoitName!accessing!private! !
preloadDoitName:!accessing!private! !
printOn:!printing!public! !
projectDefinitionService!accessing!private! !
projectDefinitionService:!accessing!private! !
projectNames!accessing!private! !
projectNames:!accessing!private! !
!

