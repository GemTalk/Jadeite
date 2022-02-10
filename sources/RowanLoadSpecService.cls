"Filed out from Dolphin Smallalk"!

RowanInspectorService subclass: #RowanLoadSpecService
	instanceVariableNames: 'loadSpecOop loadSpecPath session comment conditionalAttributes platformProperties'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanLoadSpecService guid: (GUID fromString: '{c09518cc-ba47-4785-b288-a1bea7cfaac6}')!
RowanLoadSpecService comment: ''!
!RowanLoadSpecService categoriesForClass!Unclassified! !
!RowanLoadSpecService methodsFor!

comment
	^comment!

comment: anObject
	comment := anObject!

conditionalAttributes
	^conditionalAttributes!

conditionalAttributes: anObject
	conditionalAttributes := anObject!

excludedInstVars

	^super excludedInstVars , #('session')!

export
	self
		command: #export;
		commandArgs: Array new.
	self issueCommand: self session: session!

indexOfSessionInstVar
	^27!

load
	self
		command: #load;
		commandArgs: Array new.
	self issueCommand: self session: session!

loadSpecPath
	^loadSpecPath!

loadSpecPath: anObject
	loadSpecPath := anObject!

platformProperties
	^platformProperties!

platformProperties: anObject
	platformProperties := anObject!

session
	^session!

session: anObject
	session := anObject!

setLoadSpecProperty: property to: value
	self
		command: #setLoadSpecProperty:to:;
		commandArgs: (Array with: property with: value).
	self issueCommand: self session: session!

shouldReplicateInstVarAtIndex: index newService: newService
	self indexOfSessionInstVar = index ifTrue: [^false].
	^true! !
!RowanLoadSpecService categoriesForMethods!
comment!accessing!private! !
comment:!accessing!private! !
conditionalAttributes!accessing!private! !
conditionalAttributes:!accessing!private! !
excludedInstVars!private!ston! !
export!commands!public! !
indexOfSessionInstVar!public!replication! !
load!commands!public! !
loadSpecPath!accessing!private! !
loadSpecPath:!accessing!private! !
platformProperties!accessing!private! !
platformProperties:!accessing!private! !
session!accessing!private! !
session:!accessing!private! !
setLoadSpecProperty:to:!commands!public! !
shouldReplicateInstVarAtIndex:newService:!public!ston! !
!

