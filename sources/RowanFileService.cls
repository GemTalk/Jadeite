"Filed out from Dolphin Smallalk"!

RowanAnsweringService subclass: #RowanFileService
	instanceVariableNames: 'path session'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanFileService guid: (GUID fromString: '{f8bb1f45-62dd-477e-a77b-247d189c31f1}')!
RowanFileService comment: ''!
!RowanFileService categoriesForClass!Unclassified! !
!RowanFileService methodsFor!

directoryContents
	command := #directoryContents.
	commandArgs := Array new.
	self issueCommand: self session: session. 
	^answer ifNotNil: [self shortNames]!

excludedInstVars

	^super excludedInstVars , #('session')!

indexOfSessionInstVar
	^10!

isDirectory: directory
	command := #isDirectory:.
	commandArgs := Array with: path, '/', directory.
	self issueCommand: self session: session. 
	^answer!

path
	^path!

path: anObject
	path := anObject!

pop
	command := #pop.
	commandArgs := Array new.
	self issueCommand: self session: session. 
	^answer ifNotNil: [self shortNames]!

session
	^session!

session: anObject
	session := anObject!

shortNames
	^answer collect: 
			[:assoc |
			| readStream string |
			readStream := ReadStream on: assoc key.
			
			[string := readStream upTo: $/.
			readStream atEnd] whileFalse: [].
			string -> assoc value]!

shouldReplicateInstVarAtIndex: index newService: newService
	self indexOfSessionInstVar = index ifTrue: [^false].
	^true! !
!RowanFileService categoriesForMethods!
directoryContents!commands!public! !
excludedInstVars!private!ston! !
indexOfSessionInstVar!public!ston! !
isDirectory:!commands!public! !
path!accessing!private! !
path:!accessing!public! !
pop!commands!public! !
session!accessing!private! !
session:!accessing!private! !
shortNames!accessing!private! !
shouldReplicateInstVarAtIndex:newService:!public!ston! !
!

