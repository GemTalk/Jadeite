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

addComponentNamed: componentName session: session
	command := #addComponent:.
	commandArgs := Array with: componentName.
	self issueCommand: self session: session!

componentDefinitions
	^componentDefinitions!

componentDefinitions: anObject
	componentDefinitions := anObject!

editInSession: session window: handle
	command := #editInWindow:.
	commandArgs := Array with: handle.
	self issueCommand: self session: session!

updateInSession: session
	command := #update.
	^self issueCommand: self session: session! !
!RowanProjectDefinitionService categoriesForMethods!
addComponentNamed:session:!commands!public! !
componentDefinitions!accessing!private! !
componentDefinitions:!accessing!private! !
editInSession:window:!commands!public! !
updateInSession:!commands!public! !
!

