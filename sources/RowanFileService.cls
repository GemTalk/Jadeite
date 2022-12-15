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
	self issueCommand.
	^answer ifNotNil: [self shortNames]!

directoryPath
	command := #directoryPath.
	commandArgs := Array new.
	self issueCommand.
	^answer!

excludedInstVars

	^super excludedInstVars , #('session')!

fileIn
	command := #fileIn:.
	commandArgs := Array with: path.
	self issueCommand!

fileInChunk: aString
	command := #fileInChunk:.
	commandArgs := Array with: aString.
	self issueCommand!

fileName

	command := #fileName.
	commandArgs := Array new.
	self issueCommand.
	^answer!

fileOutDictionaries: array
	self
		command: #fileoutDictionaries:;
		commandArgs: (Array with: array).
	self issueCommand!

fileOutMethods: array
	self
		command: #fileoutMethods:;
		commandArgs: (Array with: array).
	self issueCommand!

indexOfSessionInstVar
	^10!

isDirectory: directory
	command := #isDirectory:.
	commandArgs := Array with: path , '/' , directory.
	self issueCommand.
	^answer!

issueCommand
	self issueCommand: self session: session!

parentDirectoryPath

	command := #parentDirectoryPath.
	commandArgs := Array new.
	self issueCommand.
	^answer!

path
	^path!

path: anObject
	path := anObject!

pop
	command := #pop.
	commandArgs := Array new.
	self issueCommand.
	^answer ifNotNil: [self shortNames]!

remove
	command := #remove.
	commandArgs := Array new.
	self issueCommand!

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
directoryPath!commands!public! !
excludedInstVars!private!ston! !
fileIn!commands!public! !
fileInChunk:!commands!public! !
fileName!commands!public! !
fileOutDictionaries:!commands!public! !
fileOutMethods:!commands!public! !
indexOfSessionInstVar!public!ston! !
isDirectory:!commands!public! !
issueCommand!commands!public! !
parentDirectoryPath!commands!public! !
path!accessing!private! !
path:!accessing!public! !
pop!commands!public! !
remove!commands!public! !
session!accessing!private! !
session:!accessing!private! !
shortNames!accessing!private! !
shouldReplicateInstVarAtIndex:newService:!public!ston! !
!

