"Filed out from Dolphin Smalltalk 7"!

RowanService subclass: #RowanLoggingService
	instanceVariableNames: 'fileName id date time comment services mode location'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanLoggingService guid: (GUID fromString: '{869571d2-e7e2-4517-b2af-6c37a999c7cd}')!
RowanLoggingService comment: ''!
!RowanLoggingService categoriesForClass!Unclassified! !
!RowanLoggingService methodsFor!

date
	^date!

date: anObject
	date := anObject!

fileName
	^fileName!

fileName: anObject
	fileName := anObject!

id
	^id!

id: anObject
	id := anObject!

initialize
	super initialize.
	services := OrderedCollection new!

logReceivedServices: theServices
	mode := #received.
	self logServices: theServices!

logSentServices: theServices
	mode := #sent.
	self logServices: theServices!

logServices: theServices
	| stonString ws |
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

time
	^time!

time: anObject
	time := anObject! !
!RowanLoggingService categoriesFor: #date!accessing!private! !
!RowanLoggingService categoriesFor: #date:!accessing!private! !
!RowanLoggingService categoriesFor: #fileName!accessing!private! !
!RowanLoggingService categoriesFor: #fileName:!accessing!private! !
!RowanLoggingService categoriesFor: #id!accessing!private! !
!RowanLoggingService categoriesFor: #id:!accessing!private! !
!RowanLoggingService categoriesFor: #initialize!initialization!public! !
!RowanLoggingService categoriesFor: #logReceivedServices:!logging!public! !
!RowanLoggingService categoriesFor: #logSentServices:!logging!public! !
!RowanLoggingService categoriesFor: #logServices:!logging!public! !
!RowanLoggingService categoriesFor: #time!accessing!private! !
!RowanLoggingService categoriesFor: #time:!accessing!private! !

!RowanLoggingService class methodsFor!

newWithId: integer
	| inst |
	inst := self new.
	inst id: integer.
	^inst! !
!RowanLoggingService class categoriesFor: #newWithId:!instance creation!public! !

