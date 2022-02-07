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

path
	^path!

path: anObject
	path := anObject!

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
			string]! !
!RowanFileService categoriesForMethods!
directoryContents!commands!public! !
excludedInstVars!private!ston! !
path!accessing!private! !
path:!accessing!public! !
session!accessing!private! !
session:!accessing!private! !
shortNames!accessing!private! !
!

