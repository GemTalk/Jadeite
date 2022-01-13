"Filed out from Dolphin Smallalk"!

RowanDefinitionService subclass: #RowanProjectDefinitionService
	instanceVariableNames: 'definitionOop componentDefinitions packageDefinitions loadSpecification'
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

addSubcomponentNamed: subcomponentName toComponentNamed: componentName
	command := #addSubcomponentNamed:toComponentNamed:.
	commandArgs := Array with: subcomponentName with: componentName.
	self issueCommand: self session: session!

componentDefinitions
	^componentDefinitions!

componentDefinitions: anObject
	componentDefinitions := anObject!

editInSession: session window: handle
	command := #editInWindow:.
	commandArgs := Array with: handle.
	self issueCommand: self session: session!

removeComponentNamed: componentName
	command := #removeComponentNamed:.
	commandArgs := Array with: componentName.
	self issueCommand: self session: session!

renameComponentNamed: componentPath to: newName
	command := #renameComponent:to:.
	commandArgs := Array with: componentPath with: newName.
	self issueCommand: self session: session!

updateInSession: session
	command := #update.
	^self issueCommand: self session: session! !
!RowanProjectDefinitionService categoriesForMethods!
addComponentNamed:!commands!public! !
addPackageNamed:toComponentNamed:!commands!public! !
addSubcomponentNamed:toComponentNamed:!commands!public! !
componentDefinitions!accessing!private! !
componentDefinitions:!accessing!private! !
editInSession:window:!commands!public! !
removeComponentNamed:!commands!public! !
renameComponentNamed:to:!commands!public! !
updateInSession:!commands!public! !
!

