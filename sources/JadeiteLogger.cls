"Filed out from Dolphin Smallalk"!

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
	Time now printOn: ws format: 'hh.mm.ss'.
	ws nextPutAll: '.txt'.
	^ws contents!

initialize
	super initialize.
	isLogging := false.
	shouldGetNewLoggerGroup := true.
	self newLoggingService.!

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

logFileName: string
	logFileName := string.
	loggingService fileName: string!

loggingService
	^loggingService!

loggingService: anObject
	loggingService := anObject.
	loggingService ifNotNil: [loggingService isLogging: isLogging]!

logReceivedServices: services
	isLogging ifTrue: [loggingService logReceivedServices: services]!

logSentServices: services
	isLogging ifTrue: [loggingService logSentServices: services]!

newLoggingService
	| inst |
	^shouldGetNewLoggerGroup
		ifTrue: 
			[inst := RowanLoggingService loggingServiceClass newWithGroupId: self nextGroupId logger: self.
			inst command: #logReceivedServices.
			inst fileName: logFileName.
			self loggingService: inst.
			inst]
		ifFalse: [loggingService]!

newServiceLoggingService
	^self newLoggingService!

newWithGroupId: integer logger: logger
	(loggingService isNil or: [loggingService isTestLoggingService not])
		ifTrue: [^RowanLoggingService loggingServiceClass basicNewWithGroupId: integer logger: logger].
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
!JadeiteLogger categoriesForMethods!
defaultLogFileName!operations!private! !
initialize!initialization!private! !
isLogging!accessing!private! !
isLogging:!accessing!private! !
logComment:!accessing!logging!public! !
logFileName!public! !
logFileName:!public! !
loggingService!accessing!private! !
loggingService:!accessing!private! !
logReceivedServices:!accessing!logging!public! !
logSentServices:!accessing!logging!public! !
newLoggingService!accessing!logging!private! !
newServiceLoggingService!accessing!logging!public! !
newWithGroupId:logger:!double dispatch!public! !
nextGroupId!accessing!public! !
shouldGetNewLoggerGroup!accessing!private! !
shouldGetNewLoggerGroup:!accessing!private! !
startLogging!operations!public! !
stopLogging!operations!public! !
!

