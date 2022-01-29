"Filed out from Dolphin Smallalk"!

RowanDefinitionService subclass: #RowanProjectDefinitionService
	instanceVariableNames: 'definitionOop componentDefinitions packageDefinitions loadSpecification specService comment conditionalAttributes platformProperties packageGroups'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanProjectDefinitionService guid: (GUID fromString: '{4b555e92-f346-4bc3-b521-c7a308c4ac55}')!
RowanProjectDefinitionService comment: ''!
!RowanProjectDefinitionService categoriesForClass!Unclassified! !
!RowanProjectDefinitionService methodsFor!

addComponentNamed: componentName
	command := #addComponent:.
	commandArgs := Array with: componentName.
	self issueCommand: self session: session!

addPackageNamed: packageName toComponentNamed: componentName
	command := #addPackageNamed:toComponentNamed:.
	commandArgs := Array with: packageName with: componentName.
	self issueCommand: self session: session!

addPackagesNamed: packageNames toPackageGroup: packageGroupName
	command := #addPackagesNamed:toPackageGroupNamed:.
	commandArgs := Array with: packageNames with: packageGroupName.
	self issueCommand: self session: session.!

addSubcomponentNamed: subcomponentName toComponentNamed: componentName
	command := #addSubcomponentNamed:toComponentNamed:.
	commandArgs := Array with: subcomponentName with: componentName.
	self issueCommand: self session: session!

comment
	^comment!

comment: anObject
	comment := anObject!

componentDefinitions
	^componentDefinitions!

componentDefinitions: anObject
	componentDefinitions := anObject!

conditionalAttributes
	^conditionalAttributes!

conditionalAttributes: anObject
	conditionalAttributes := anObject!

editInSession: session window: handle
	command := #editInWindow:.
	commandArgs := Array with: handle.
	self issueCommand: self session: session!

excludedInstVars
	"I'm not sure this is the right thing but since packageGroups does not need to be used on the server, we'll try it"

	^super excludedInstVars , #('packageGroups')!

movePackageNamed: packageName toComponentNamed: componentName
	command := #movePackageNamed:toComponentNamed:.
	commandArgs := Array with: packageName with: componentName.
	self issueCommand: self session: session!

packageGroups
	^packageGroups!

packageGroups: anObject
	packageGroups := anObject!

platformProperties
	^platformProperties!

platformProperties: anObject
	platformProperties := anObject!

removeComponentNamed: componentName
	command := #removeComponentNamed:.
	commandArgs := Array with: componentName.
	self issueCommand: self session: session!

removePackageGroups: packageGroupServices
	command := #removePackageGroupsNamed:.
	commandArgs := Array
				with: (packageGroupServices collect: [:packageGroupService | packageGroupService name]).
	self issueCommand: self session: session!

renameComponentNamed: componentPath to: newName
	command := #renameComponent:to:.
	commandArgs := Array with: componentPath with: newName.
	self issueCommand: self session: session!

specService
	^specService!

specService: anObject
	specService := anObject!

updateInSession: session
	command := #update.
	^self issueCommand: self session: session! !
!RowanProjectDefinitionService categoriesForMethods!
addComponentNamed:!commands!public! !
addPackageNamed:toComponentNamed:!commands!public! !
addPackagesNamed:toPackageGroup:!commands!public! !
addSubcomponentNamed:toComponentNamed:!commands!public! !
comment!accessing!private! !
comment:!accessing!private! !
componentDefinitions!accessing!private! !
componentDefinitions:!accessing!private! !
conditionalAttributes!accessing!private! !
conditionalAttributes:!accessing!private! !
editInSession:window:!commands!public! !
excludedInstVars!public!ston! !
movePackageNamed:toComponentNamed:!commands!public! !
packageGroups!accessing!private! !
packageGroups:!accessing!private! !
platformProperties!accessing!private! !
platformProperties:!accessing!private! !
removeComponentNamed:!commands!public! !
removePackageGroups:!commands!public! !
renameComponentNamed:to:!commands!public! !
specService!accessing!private! !
specService:!accessing!private! !
updateInSession:!commands!public! !
!

