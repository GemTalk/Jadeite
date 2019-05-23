"Filed out from Dolphin Smalltalk 7"!

RowanService subclass: #RowanLoggingService
	instanceVariableNames: 'fileName id groupId date time comment services mode location isLogging'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanLoggingService guid: (GUID fromString: '{869571d2-e7e2-4517-b2af-6c37a999c7cd}')!
RowanLoggingService comment: 'Any service sent from the client gives it''s group id to the client send, server receive, server return, client receive. 
id is the numbering within that group for display sorting. '!
!RowanLoggingService categoriesForClass!Unclassified! !
!RowanLoggingService methodsFor!

= methodService
	^methodService isLoggingService and: [groupId = methodService groupId]!

basicServerDisplayString
	| ws |
	ws := WriteStream on: String new.
	ws
		nextPutAll: date shortString;
		space.
	time printOn: ws format: 'HH:mm:ss'.
	ws
		space;
		nextPutAll: mode;
		space;
		nextPut: $-;
		space;
		nextPutAll: self updateType.
	^ws contents!

clientDisplayString
	^location == #client ifTrue: [self displayString] ifFalse: [String new]!

commandSent
	| ws |
	ws := WriteStream on: String new.
	services do: 
			[:service |
			ws
				nextPutAll: (service displayName ifNil: [String new]);
				space.
			mode = #received
				ifFalse: 
					[ws
						nextPutAll: (service command ifNil: [#update]);
						nextPut: $;]].
	^ws contents!

date
	^date!

date: anObject
	date := anObject!

displayString
	| ws |
	ws := WriteStream on: String new.
	ws
		nextPutAll: date shortString;
		space.
	time printOn: ws format: 'HH:mm:ss'.
	ws
		space;
		nextPutAll: mode;
		space;
		nextPut: $-;
		space;
		nextPutAll: self commandSent.
	^ws contents!

fileName
	^fileName!

fileName: anObject
	fileName := anObject!

groupId
	^groupId!

groupId: anObject
	groupId := anObject!

hash
	^groupId hash!

id
	^id!

id: anObject
	id := anObject!

initialize
	super initialize.
	services := OrderedCollection new.
	isLogging := false. !

isLogging: aBoolean 
	isLogging := aBoolean!

isLoggingService

	^true!

logReceivedServices: theServices
	mode := #received.
	self logServices: theServices!

logSentServices: theServices
	mode := #sent.
	self logServices: theServices!

logServices: theServices
	| stonString ws |
	id := id + 1. 
	services := theServices.
	date := Date today.
	time := Time now.
	location := #client.
	stonString := STON toString: self.
	ws := FileStream
				open: fileName
				mode: #append
				text: true.
	[ws nextPutAll: stonString] ensure: [ws close]!

mode
	^mode!

printString
	^self class name , ' ' , self displayString!

serverDisplayString
	^location == #server ifTrue: [self basicServerDisplayString] ifFalse: [String new]!

services

	^services!

services: anObject
	services := anObject!

time
	^time!

time: anObject
	time := anObject!

updateType
	| ws |
	ws := WriteStream on: String new.
	services do: 
			[:service |
			ws
				nextPutAll: (service displayName ifNil: [String new]);
				space.
			mode = #sent
				ifFalse: 
					[ws
						nextPutAll: (service updateType ifNil:[String new]);
						nextPut: $;]].
	^ws contents! !
!RowanLoggingService categoriesFor: #=!comparing!public! !
!RowanLoggingService categoriesFor: #basicServerDisplayString!printing!public! !
!RowanLoggingService categoriesFor: #clientDisplayString!printing!public! !
!RowanLoggingService categoriesFor: #commandSent!printing!public! !
!RowanLoggingService categoriesFor: #date!accessing!private! !
!RowanLoggingService categoriesFor: #date:!accessing!private! !
!RowanLoggingService categoriesFor: #displayString!printing!public! !
!RowanLoggingService categoriesFor: #fileName!accessing!private! !
!RowanLoggingService categoriesFor: #fileName:!accessing!private! !
!RowanLoggingService categoriesFor: #groupId!accessing!private! !
!RowanLoggingService categoriesFor: #groupId:!accessing!private! !
!RowanLoggingService categoriesFor: #hash!comparing!public! !
!RowanLoggingService categoriesFor: #id!accessing!private! !
!RowanLoggingService categoriesFor: #id:!accessing!private! !
!RowanLoggingService categoriesFor: #initialize!initialization!public! !
!RowanLoggingService categoriesFor: #isLogging:!public! !
!RowanLoggingService categoriesFor: #isLoggingService!public!testing! !
!RowanLoggingService categoriesFor: #logReceivedServices:!logging!public! !
!RowanLoggingService categoriesFor: #logSentServices:!logging!public! !
!RowanLoggingService categoriesFor: #logServices:!logging!public! !
!RowanLoggingService categoriesFor: #mode!accessing!public! !
!RowanLoggingService categoriesFor: #printString!printing!public! !
!RowanLoggingService categoriesFor: #serverDisplayString!printing!public! !
!RowanLoggingService categoriesFor: #services!accessing!public! !
!RowanLoggingService categoriesFor: #services:!accessing!private! !
!RowanLoggingService categoriesFor: #time!accessing!private! !
!RowanLoggingService categoriesFor: #time:!accessing!private! !
!RowanLoggingService categoriesFor: #updateType!printing!public! !

!RowanLoggingService class methodsFor!

newWithGroupId: integer
	| inst |
	inst := self new.
	inst
		groupId: integer;
		id: 0.
	^inst! !
!RowanLoggingService class categoriesFor: #newWithGroupId:!instance creation!public! !

