"Filed out from Dolphin Smalltalk 7"!

Model subclass: #JadeiteLogger
	instanceVariableNames: 'loggingService isLogging nextId logFileName'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteLogger guid: (GUID fromString: '{58a1969b-8080-43a3-b264-4bce39ba6650}')!
JadeiteLogger comment: ''!
!JadeiteLogger categoriesForClass!MVP-Models! !
!JadeiteLogger methodsFor!

defaultLogFileName
	| ws |
	ws := WriteStream on: String new.
	ws nextPutAll: 'jadeiteCallTraceLog_'.
	Date today printOn: ws format: 'yyyy_MM_dd_'.
	Time now printOn: ws format: 'hh.ss.mmm'.
	ws nextPutAll: '.txt'.
	^ws contents!

initialize

	super initialize. 
	isLogging := false. !

isLogging
	^isLogging!

isLogging: anObject
	isLogging := anObject!

loggingService
	^loggingService!

loggingService: anObject
	loggingService := anObject!

logReceivedServices: services
	isLogging ifTrue: [loggingService logReceivedServices: services]!

logSentServices: services
	isLogging ifTrue: [loggingService logSentServices: services]!

newLoggingService
	| inst |
	inst := RowanLoggingService newWithId: self nextId.
	inst fileName: logFileName.
	loggingService := inst.
	^inst!

nextId
	^nextId ifNil: [nextId := 1] ifNotNil: [nextId := nextId + 1]!

startLogging
	nextId := nil.
	isLogging := true.
	logFileName := self defaultLogFileName!

stopLogging
	nextId := nil.
	isLogging := false.
	logFileName := nil! !
!JadeiteLogger categoriesFor: #defaultLogFileName!operations!private! !
!JadeiteLogger categoriesFor: #initialize!initialization!private! !
!JadeiteLogger categoriesFor: #isLogging!accessing!private! !
!JadeiteLogger categoriesFor: #isLogging:!accessing!private! !
!JadeiteLogger categoriesFor: #loggingService!accessing!private! !
!JadeiteLogger categoriesFor: #loggingService:!accessing!private! !
!JadeiteLogger categoriesFor: #logReceivedServices:!accessing!logging!public! !
!JadeiteLogger categoriesFor: #logSentServices:!accessing!logging!public! !
!JadeiteLogger categoriesFor: #newLoggingService!accessing!logging!public! !
!JadeiteLogger categoriesFor: #nextId!accessing!public! !
!JadeiteLogger categoriesFor: #startLogging!operations!public! !
!JadeiteLogger categoriesFor: #stopLogging!operations!public! !

