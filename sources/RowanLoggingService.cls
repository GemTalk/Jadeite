"Filed out from Dolphin Smallalk"!

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
	isLogging := false.
	location := #client!

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
	| ws |
	id := id + 1.
	comment := aString.
	location := #client.
	mode := nil.
	ws := FileStream write: fileName mode: #append.
	
	[self logServiceDateTimeStampProcessOn: ws.
	ws
		space;
		nextPutAll: aString]
			ensure: [ws close].
	comment := nil	"service may be reused. Clear comment"!

logReceivedServices: theServices
	| ws |
	mode := #received.
	ws := self logServiceStream.
	
	[theServices do: 
			[:svc |
			self logServiceDateTimeStampProcessOn: ws.
			ws nextPutAll: svc logReceivedString]]
			ensure: [ws close]!

logSentServices: theServices
	| ws |
	mode := #sent.
	ws := self logServiceStream.
	
	[theServices do: 
			[:svc |
			self logServiceDateTimeStampProcessOn: ws.
			ws nextPutAll: svc logSentString]]
			ensure: [ws close]!

logServiceDateTimeStampProcessOn: ws
	date := Date today.
	time := Time now.
	ws
		cr;
		nextPutAll: date shortString;
		space;
		nextPutAll: time printString;
		space;
		nextPutAll: 'Process: {' , Processor activeProcess identityHash printString , '}';
		space;
		nextPutAll: 'priority: ', Processor activePriority printString;
		space.
	mode
		ifNotNil: 
			[ws
				nextPutAll: mode;
				space]!

logServiceStream
	| ws |
	id := id + 1.
	ws := FileStream write: fileName mode: #append.
	^ws!

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
!RowanLoggingService categoriesForMethods!
=!comparing!public! !
addServices:!accessing!public! !
clientDisplayString!displaying!public! !
clientGroupIdDisplayString!displaying!public! !
clientIdDisplayString!displaying!public! !
comment!accessing!private! !
comment:!accessing!private! !
date!accessing!private! !
date:!accessing!private! !
displayCommand!displaying!public! !
displayName!displaying!public! !
displayString!displaying!public! !
fileName!accessing!private! !
fileName:!accessing!private! !
groupId!accessing!private! !
groupId:!accessing!private! !
hash!comparing!public! !
id!accessing!private! !
id:!accessing!private! !
initialize!initialization!public! !
isLogging!accessing!public! !
isLogging:!public! !
isLoggingService!public!testing! !
isTestLoggingService!public!testing! !
location!accessing!private! !
location:!accessing!private! !
logComment:!logging!public! !
logReceivedServices:!logging!public! !
logSentServices:!logging!public! !
logServiceDateTimeStampProcessOn:!logging!public! !
logServiceStream!logging!public! !
mode!accessing!public! !
name!accessing!public! !
name:!accessing!public! !
printString!displaying!public! !
serverDisplayString!displaying!public! !
services!accessing!public! !
sortAspect!accessing!public! !
time!accessing!private! !
time:!accessing!private! !
!

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
!RowanLoggingService class categoriesForMethods!
basicNewWithGroupId:logger:!instance creation!public! !
loggingServiceClass!accessing!public! !
newWithGroupId:logger:!instance creation!public! !
!

