"Filed out from Dolphin Smalltalk 7"!

RowanService subclass: #RowanLoggingService
	instanceVariableNames: 'fileName id groupId date time comment services mode location isLogging name'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanLoggingService guid: (GUID fromString: '{869571d2-e7e2-4517-b2af-6c37a999c7cd}')!
RowanLoggingService comment: 'Any service sent from the client gives it''s group id to the client send, server receive, server return, client receive. 
id is the numbering within that group for display sorting. '!
!RowanLoggingService categoriesForClass!Unclassified! !
!RowanLoggingService methodsFor!

= methodService
	(methodService isKindOf: RowanService) ifFalse: [^false].
	^methodService isLoggingService and: [groupId = methodService groupId and: [id = methodService id]]!

addServices: newServices
	services addAll: newServices!

clientDisplayString
	^location == #client ifTrue: [self displayString] ifFalse: [String new]!

clientGroupIdDisplayString

	^groupId printString!

clientIdDisplayString

	^id printString!

comment
	^comment!

comment: anObject
	comment := anObject!

date
	^date!

date: anObject
	date := anObject!

displayCommand
	| ws |
	ws := WriteStream on: String new.
	services do: 
			[:service |
			service command
				ifNil: 
					[ws nextPutAll: (service updateType ifNil: [String new] ifNotNil: [:updates | updates printString])]
				ifNotNil: 
					[ws nextPutAll: (service command ifNil: [String new] ifNotNil: [:updates | updates printString])].
			ws
				space;
				nextPutAll: (service displayName ifNil: [String new])].
	^ws contents!

displayName
	"for logging. for now"

	^name!

displayString
	| ws |
	ws := WriteStream on: String new.
	ws
		nextPutAll: date shortString;
		space.
	time printOn: ws format: 'HH:mm:ss'.
	comment
		ifNotNil: 
			[ws
				space;
				nextPutAll: comment].
	mode
		ifNotNil: 
			[ws
				space;
				nextPutAll: mode;
				space;
				nextPut: $-;
				space;
				nextPutAll: self displayCommand].
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
	^groupId hash bitXor: id hash!

id
	^id!

id: anObject
	id := anObject!

initialize
	super initialize.
	services := OrderedCollection new.
	isLogging := false. !

isLogging
	^isLogging!

isLogging: aBoolean 
	isLogging := aBoolean!

isLoggingService

	^true!

isTestLoggingService
	^false!

location
	^location!

location: anObject
	location := anObject!

logComment: aString
	| stonString ws |
	id := id + 1.
	comment := aString.
	date := Date today. 
	time := Time now.
	location := #client.
	mode := nil.
	stonString := STON toString: self.
	ws := FileStream write: fileName mode: #append.
	[ws nextPutAll: stonString] ensure: [ws close].
	comment := nil	"service may be reused. Clear comment"!

logReceivedServices: theServices
	mode := #received.
	self logServices: theServices!

logSentServices: theServices
	mode := #sent.
	self logServices: theServices!

logServices: theServices
	| stonString ws |
	id := id + 1.
	date := Date today.
	time := Time now.
	location := #client.
	stonString := STON toString: self.
	ws := FileStream write: fileName mode: #append.
	[ws nextPutAll: stonString] ensure: [ws close]!

mode
	^mode!

name
	^name!

name: aString
	name := aString asString!

printString
	^self class name , ' ' , self displayString!

serverDisplayString
	^location == #server ifTrue: [self displayString] ifFalse: [String new]!

services

	^services!

sortAspect

	^name!

time
	^time!

time: anObject
	time := anObject! !
!RowanLoggingService categoriesFor: #=!comparing!public! !
!RowanLoggingService categoriesFor: #addServices:!accessing!public! !
!RowanLoggingService categoriesFor: #clientDisplayString!displaying!public! !
!RowanLoggingService categoriesFor: #clientGroupIdDisplayString!displaying!public! !
!RowanLoggingService categoriesFor: #clientIdDisplayString!displaying!public! !
!RowanLoggingService categoriesFor: #comment!accessing!private! !
!RowanLoggingService categoriesFor: #comment:!accessing!private! !
!RowanLoggingService categoriesFor: #date!accessing!private! !
!RowanLoggingService categoriesFor: #date:!accessing!private! !
!RowanLoggingService categoriesFor: #displayCommand!displaying!public! !
!RowanLoggingService categoriesFor: #displayName!displaying!public! !
!RowanLoggingService categoriesFor: #displayString!displaying!public! !
!RowanLoggingService categoriesFor: #fileName!accessing!private! !
!RowanLoggingService categoriesFor: #fileName:!accessing!private! !
!RowanLoggingService categoriesFor: #groupId!accessing!private! !
!RowanLoggingService categoriesFor: #groupId:!accessing!private! !
!RowanLoggingService categoriesFor: #hash!comparing!public! !
!RowanLoggingService categoriesFor: #id!accessing!private! !
!RowanLoggingService categoriesFor: #id:!accessing!private! !
!RowanLoggingService categoriesFor: #initialize!initialization!public! !
!RowanLoggingService categoriesFor: #isLogging!accessing!public! !
!RowanLoggingService categoriesFor: #isLogging:!public! !
!RowanLoggingService categoriesFor: #isLoggingService!public!testing! !
!RowanLoggingService categoriesFor: #isTestLoggingService!public!testing! !
!RowanLoggingService categoriesFor: #location!accessing!private! !
!RowanLoggingService categoriesFor: #location:!accessing!private! !
!RowanLoggingService categoriesFor: #logComment:!logging!public! !
!RowanLoggingService categoriesFor: #logReceivedServices:!logging!public! !
!RowanLoggingService categoriesFor: #logSentServices:!logging!public! !
!RowanLoggingService categoriesFor: #logServices:!logging!public! !
!RowanLoggingService categoriesFor: #mode!accessing!public! !
!RowanLoggingService categoriesFor: #name!accessing!public! !
!RowanLoggingService categoriesFor: #name:!accessing!public! !
!RowanLoggingService categoriesFor: #printString!displaying!public! !
!RowanLoggingService categoriesFor: #serverDisplayString!displaying!public! !
!RowanLoggingService categoriesFor: #services!accessing!public! !
!RowanLoggingService categoriesFor: #sortAspect!accessing!public! !
!RowanLoggingService categoriesFor: #time!accessing!private! !
!RowanLoggingService categoriesFor: #time:!accessing!private! !

!RowanLoggingService class methodsFor!

basicNewWithGroupId: integer logger: logger
	| inst |
	inst := self new.
	inst
		groupId: integer;
		id: 0.
	^inst!

loggingServiceClass
	^Smalltalk at: #JadeiteTestLoggingServiceClass ifAbsent: [self]!

newWithGroupId: integer logger: logger
	^self basicNewWithGroupId: integer logger: logger! !
!RowanLoggingService class categoriesFor: #basicNewWithGroupId:logger:!instance creation!public! !
!RowanLoggingService class categoriesFor: #loggingServiceClass!accessing!public! !
!RowanLoggingService class categoriesFor: #newWithGroupId:logger:!instance creation!public! !

