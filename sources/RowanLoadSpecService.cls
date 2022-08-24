"Filed out from Dolphin Smallalk"!

RowanInspectorService subclass: #RowanLoadSpecService
	instanceVariableNames: 'loadSpecOop loadSpecPath session comment conditionalAttributes platformProperties componentNames'
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

componentNames
	^componentNames!

componentNames: anObject
	componentNames := anObject!

conditionalAttributeItem: new updatedAtIndex: index
	self
		command: #setConditionalAttributes:;
		commandArgs: (Array with: self conditionalAttributes).
	self issueCommand: self session: session!

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
	^28!

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

platformPropertyItem: association updatedAtIndex: value
	self halt. 
	self
		command: #setPlatformProperty:to:;
		commandArgs: (Array with: association key with: value).
	self issueCommand: self session: session!

session
	^session!

session: anObject
	session := anObject!

setComment: aString
	self
		command: #setComment:;
		commandArgs: (Array with: aString).
	self issueCommand: self session: session!

setLoadSpecProperty: property to: value
	self
		command: #setLoadSpecProperty:to:;
		commandArgs: (Array with: property with: value).
	self issueCommand: self session: session!

setPlatformProperty: property to: value
	self
		command: #setPlatformProperty:to:;
		commandArgs: (Array with: property with: value).
	self issueCommand: self session: session!

shouldReplicateInstVarAtIndex: index newService: newService
	self indexOfSessionInstVar = index ifTrue: [^false].
	^true! !
!RowanLoadSpecService categoriesForMethods!
comment!accessing!private! !
comment:!accessing!private! !
componentNames!accessing!private! !
componentNames:!accessing!private! !
conditionalAttributeItem:updatedAtIndex:!commands!public! !
conditionalAttributes!accessing!private! !
conditionalAttributes:!accessing!private! !
excludedInstVars!private!ston! !
export!commands!public! !
indexOfSessionInstVar!constants!public! !
load!commands!public! !
loadSpecPath!accessing!private! !
loadSpecPath:!accessing!private! !
platformProperties!accessing!private! !
platformProperties:!accessing!private! !
platformPropertyItem:updatedAtIndex:!commands!public! !
session!accessing!private! !
session:!accessing!private! !
setComment:!commands!public! !
setLoadSpecProperty:to:!commands!public! !
setPlatformProperty:to:!commands!public! !
shouldReplicateInstVarAtIndex:newService:!public!ston! !
!

