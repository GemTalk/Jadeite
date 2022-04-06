"Filed out from Dolphin Smallalk"!

RowanDefinitionService subclass: #RowanProjectDefinitionService
	instanceVariableNames: 'definitionOop componentDefinitions packageDefinitions specService comment conditionalAttributes platformProperties packageGroups showLoadedPackageGroupsOnly allPackagesGroupService'
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

addPackageGroupNamed: packageGroupName condition: newCondition
	command := #addPackageGroupNamed:condition:comment:.
	commandArgs := Array
				with: packageGroupName
				with: newCondition
				with: comment.
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

allPackagesGroupName
	^'All Packages'!

allPackagesGroupService
	"special package group to display all packages"

	^allPackagesGroupService
		ifNil: 
			[allPackagesGroupService := RowanPackageGroupService new
						name: self allPackagesGroupName;
						condition: String new;
						projectDefinitionService: self]!

comment
	^comment!

comment: proejctComment
	command := #comment:.
	commandArgs := Array with: proejctComment.
	self issueCommand: self session: session!

componentDefinitions
	^componentDefinitions!

componentDefinitions: anObject
	componentDefinitions := anObject!

conditionalAttributes
	^conditionalAttributes!

conditionalAttributes: anObject
	conditionalAttributes := anObject!

excludedInstVars
	"I'm not sure this is the right thing but since packageGroups does not need to be used on the server, we'll try it"

	^super excludedInstVars , #('packageGroups' 'allPackagesGroupService')!

export
	command := #export.
	commandArgs := Array new.
	self issueCommand: self session: session!

initialize
	super initialize.
	showLoadedPackageGroupsOnly := true!

movePackageNamed: packageName toComponentNamed: componentName
	command := #movePackageNamed:toComponentNamed:.
	commandArgs := Array with: packageName with: componentName.
	self issueCommand: self session: session!

packageGroups
	^packageGroups!

packageGroups: anObject
	packageGroups := anObject!

packageGroupUpdate: presenter browser: browser
	| treeModel allService |
	wasUpdated ifFalse: [^self].
	browser selectedProjectName = name ifFalse: [^self].
	treeModel := self chooseModel: presenter using: browser.
	session := browser gciSession.
	allService := self allPackagesGroupService.
	treeModel isEmpty
		ifTrue: 
			[treeModel add: allService asChildOf: nil.
			packageGroups do: [:packageGroupService | treeModel add: packageGroupService asChildOf: allService]]
		ifFalse: 
			[(treeModel childrenOf: allService)
				do: [:displayedGroup | (packageGroups includes: displayedGroup) ifFalse: [treeModel remove: displayedGroup ifAbsent: []]].
			packageGroups do: 
					[:packageGroupService |
					((treeModel childrenOf: allService) includes: packageGroupService)
						ifFalse: [treeModel add: packageGroupService asChildOf: allService]]].
	presenter view ensureSelectionVisible.
	presenter view expandAll!

platformProperties
	^platformProperties!

platformProperties: anObject
	platformProperties := anObject!

removeComponentNamed: componentName
	command := #removeComponentNamed:.
	commandArgs := Array with: componentName.
	self issueCommand: self session: session!

removeCondition: condition inSubcomponentNamed: subcomponentName
	command := #removeCondition:inSubcomponentNamed:.
	commandArgs := Array with: condition with: subcomponentName.
	self issueCommand: self session: session!

removePackageGroups: packageGroupServices
	command := #removePackageGroupsNamed:.
	commandArgs := Array
				with: (packageGroupServices collect: [:packageGroupService | packageGroupService name]).
	self issueCommand: self session: session!

removePackageGroupsNamed: packageGroupNames
	command := #removePackageGroupsNamed:.
	commandArgs := Array with: packageGroupNames.
	self issueCommand: self session: session!

removePackagesFromProjectDefinition: packageNames
	"package groups and component names are treated similarly in some cases, hence the oddly named command"

	command := #removePackagesFromProjectDefinition:.
	commandArgs := Array with: packageNames.
	self issueCommand: self session: session!

removePackagesNamed: packageNames fromPackageGroupNamed: packageGroupName
	"package groups and component names are treated similarly in some cases, hence the oddly named command"

	command := #removePackagesNamed:fromPackageGroupNamed:.
	commandArgs := Array with: packageNames with: packageGroupName.
	self issueCommand: self session: session!

renameComponentNamed: componentPath to: newName
	command := #renameComponent:to:.
	commandArgs := Array with: componentPath with: newName.
	self issueCommand: self session: session!

renamePackage: packageName to: newPackageName
	command := #renamePackageNamed:to:.
	commandArgs := Array with: packageName with: newPackageName.
	self issueCommand: self session: session!

renamePackageGroup: packageGroupName to: newPackageGroupName
	command := #renamePackageGroup:to:.
	commandArgs := Array with: packageGroupName with: newPackageGroupName.
	self issueCommand: self session: session!

showLoadedPackageGroupsOnly
	^showLoadedPackageGroupsOnly!

showLoadedPackageGroupsOnly: anObject
	showLoadedPackageGroupsOnly := anObject!

specService
	^specService!

specService: anObject
	specService := anObject!

subcomponentNamed: subcomponentName condition: condition
	command := #subcomponentNamed:condition:.
	commandArgs := Array with: subcomponentName with: condition.
	self issueCommand: self session: session!

updateInSession: session
	command := #update.
	^self issueCommand: self session: session! !
!RowanProjectDefinitionService categoriesForMethods!
addComponentNamed:!commands!public! !
addPackageGroupNamed:condition:!commands!public! !
addPackageNamed:toComponentNamed:!commands!public! !
addPackagesNamed:toPackageGroup:!commands!public! !
addSubcomponentNamed:toComponentNamed:!commands!public! !
allPackagesGroupName!constants!public! !
allPackagesGroupService!accessing!public! !
comment!accessing!private! !
comment:!commands!public! !
componentDefinitions!accessing!private! !
componentDefinitions:!accessing!private! !
conditionalAttributes!accessing!private! !
conditionalAttributes:!accessing!private! !
excludedInstVars!public!ston! !
export!commands!public! !
initialize!initialization!public! !
movePackageNamed:toComponentNamed:!commands!public! !
packageGroups!accessing!private! !
packageGroups:!accessing!private! !
packageGroupUpdate:browser:!public!updating! !
platformProperties!accessing!private! !
platformProperties:!accessing!private! !
removeComponentNamed:!commands!public! !
removeCondition:inSubcomponentNamed:!commands!public! !
removePackageGroups:!commands!public! !
removePackageGroupsNamed:!commands!public! !
removePackagesFromProjectDefinition:!commands!public! !
removePackagesNamed:fromPackageGroupNamed:!commands!public! !
renameComponentNamed:to:!commands!public! !
renamePackage:to:!commands!public! !
renamePackageGroup:to:!commands!public! !
showLoadedPackageGroupsOnly!accessing!private! !
showLoadedPackageGroupsOnly:!accessing!private! !
specService!accessing!private! !
specService:!accessing!private! !
subcomponentNamed:condition:!commands!public! !
updateInSession:!commands!public! !
!

