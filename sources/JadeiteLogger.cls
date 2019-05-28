"Filed out from Dolphin Smalltalk 7"!

Model subclass: #JadeiteLogger
	instanceVariableNames: 'loggingService isLogging nextGroupId logFileName shouldGetNewLoggerGroup'
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
	isLogging := false.
	shouldGetNewLoggerGroup := true "not used yet"!

isLogging
	^isLogging!

isLogging: boolean
	isLogging := boolean.
	loggingService isLogging: boolean!

logComment: string
	self newLoggingService.
	isLogging ifTrue: [loggingService logComment: string]!

logFileName

	^logFileName!

loggingService
	^loggingService!

loggingService: anObject
	loggingService := anObject.
	loggingService isLogging: isLogging!

logReceivedServices: services
	isLogging ifTrue: [loggingService logReceivedServices: services]!

logSentServices: services
	isLogging ifTrue: [loggingService logSentServices: services]!

newLoggingService
	| inst |
	^shouldGetNewLoggerGroup
		ifTrue: 
			[inst := RowanLoggingService newWithGroupId: self nextGroupId.
			inst command: #logReceivedServices.
			inst fileName: logFileName.
			self loggingService: inst.
			inst]
		ifFalse: [loggingService]!

newServiceLoggingService
	self newLoggingService.
	^loggingService!

nextGroupId
	^nextGroupId ifNil: [nextGroupId := 1] ifNotNil: [nextGroupId := nextGroupId + 1]!

shouldGetNewLoggerGroup
	^shouldGetNewLoggerGroup!

shouldGetNewLoggerGroup: boolean
	shouldGetNewLoggerGroup := boolean!

startLogging
	nextGroupId := nil.
	self isLogging: true.
	logFileName := self defaultLogFileName!

stopLogging
	nextGroupId := nil.
	self isLogging: false! !
!JadeiteLogger categoriesFor: #defaultLogFileName!operations!private! !
!JadeiteLogger categoriesFor: #initialize!initialization!private! !
!JadeiteLogger categoriesFor: #isLogging!accessing!private! !
!JadeiteLogger categoriesFor: #isLogging:!accessing!private! !
!JadeiteLogger categoriesFor: #logComment:!accessing!logging!public! !
!JadeiteLogger categoriesFor: #logFileName!public! !
!JadeiteLogger categoriesFor: #loggingService!accessing!private! !
!JadeiteLogger categoriesFor: #loggingService:!accessing!private! !
!JadeiteLogger categoriesFor: #logReceivedServices:!accessing!logging!public! !
!JadeiteLogger categoriesFor: #logSentServices:!accessing!logging!public! !
!JadeiteLogger categoriesFor: #newLoggingService!accessing!logging!public! !
!JadeiteLogger categoriesFor: #newServiceLoggingService!accessing!logging!public! !
!JadeiteLogger categoriesFor: #nextGroupId!accessing!public! !
!JadeiteLogger categoriesFor: #shouldGetNewLoggerGroup!accessing!private! !
!JadeiteLogger categoriesFor: #shouldGetNewLoggerGroup:!accessing!private! !
!JadeiteLogger categoriesFor: #startLogging!operations!public! !
!JadeiteLogger categoriesFor: #stopLogging!operations!public! !

