"Filed out from Dolphin Smalltalk 7"!

JadeiteAbstractTestCase subclass: #JadeiteLoggerTestCase
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteLoggerTestCase guid: (GUID fromString: '{85dca851-1a99-4796-b104-5a59d659fe9d}')!
JadeiteLoggerTestCase comment: ''!
!JadeiteLoggerTestCase categoriesForClass!Unclassified! !
!JadeiteLoggerTestCase methodsFor!

openLogBrowser
	| browseItem loggerItem |
	browseItem := transcript view menuBar items detect: [:menuItem | '*Browse*' match: menuItem text].
	loggerItem := browseItem items
				detect: [:item | (item class canUnderstand: #description) and: [item description = 'Browse Logs']].
	^loggerItem commandDescription performAgainst: transcript!

setUp
	super setUp.
	BrowserUpdate current resetLoggingService.
	Smalltalk at: #JadeiteTestLoggingServiceClass put: TestLoggingService.
	BrowserUpdate current logFileName: 'jadeiteTestFilename.txt'!

tearDown
	super tearDown.
	Smalltalk removeKey: #JadeiteTestLoggingServiceClass ifAbsent: [].
	BrowserUpdate current resetLoggingService.  !

test_equality
	"sent & received logging services should have the same groupId because it's a service call.
	id will vary based on number of comments logged"

	| loggingServiceA loggingServiceB |
	self testsIssue: #issue250 withTitle: 'Need logging capability in Jadeite'.
	loggingServiceA := RowanLoggingService new
				groupId: 1;
				id: 2.
	loggingServiceB := RowanLoggingService new
				groupId: 1;
				id: 2.
	self assert: loggingServiceA equals: loggingServiceB.
	loggingServiceA := RowanLoggingService new
				groupId: 1;
				id: 1.
	loggingServiceB := RowanLoggingService new
				groupId: 1;
				id: 2.
	self deny: loggingServiceA equals: loggingServiceB.
	loggingServiceA := RowanLoggingService new
				groupId: 1;
				id: 1.
	loggingServiceB := RowanLoggingService new
				groupId: 2;
				id: 1.
	self deny: loggingServiceA equals: loggingServiceB!

test_isLoggingDefaults
	self testsIssue: #issue250 withTitle: 'Need logging capability in Jadeite'.
	Smalltalk removeKey: #JadeiteTestLoggingServiceClass ifAbsent: [].
	BrowserUpdate current resetLoggingService.
	self assert: BrowserUpdate current loggingService isLogging equals: BrowserUpdate current isLogging	"JadeiteLogger holds the global setting"!

test_logComment
	| rs filename objects wasLogging loggingService initialId file |
	self testsIssue: #issue250 withTitle: 'Need logging capability in Jadeite'.
	file := File open: BrowserUpdate current logFileName mode: #truncate check: false.	"open and truncate if existing or create a new file"
	file close.
	wasLogging := BrowserUpdate current isLogging.
	BrowserUpdate current isLogging: true.
	BrowserUpdate current resetLoggingService.
	initialId := BrowserUpdate current loggingService id.
	
	[BrowserUpdate current logComment: 'Test comment'.
	filename := BrowserUpdate current logFileName.
	objects := OrderedCollection new.
	rs := FileStream open: filename mode: #read.
	[[rs atEnd] whileFalse: [objects add: (STON fromStream: rs)]] ensure: [rs close].
	self assert: objects size equals: 1.
	loggingService := objects first.
	self assert: (loggingService isKindOf: TestLoggingService).
	self assert: loggingService comment equals: 'Test comment'.
	self assert: loggingService date equals: Date today.
	self assert: ('TestLoggingService*Test comment' match: loggingService printString).
	self assert: loggingService id equals: initialId + 1]
			ensure: 
				[file delete.
				BrowserUpdate current isLogging: wasLogging]!

test_loggerCanHandleNilFilenames
	| logger |
	self testsIssue: #issue477 withTitle: 'Opening logger for first time gets error'.
	BrowserUpdate current logFileName: nil.	"default location log file names for client & server"
	logger := self openLogBrowser.	"just opening the logger browser gets past the bug"
	
	[self assert: (logger isKindOf: JadeiteLoggerShell).
	self assert: logger primaryPresenter clientFilename isNil]
			ensure: [logger view close]!

test_loggerContainsServices
	| loggingService service |
	self testsIssue: #issue250 withTitle: 'Need logging capability in Jadeite'.
	service := (RowanProjectService new name: 'Rowan')
				command: #update;
				commandArgs: Array new.
	self issueCommand: service.
	loggingService := BrowserUpdate current loggingService.
	self assert: loggingService services size equals: 1.
	self assert: loggingService services first isProjectService.
	self assert: loggingService services first name equals: 'Rowan'!

test_loggerMenuEnablement
	"logging options should always be present, enabled, and functional"

	| commandQuery loggingItem isLogging jadeiteItem logger |
	self testsIssue: #issue250 withTitle: 'Need logging capability in Jadeite'.
	commandQuery := self
				queryCommand: #flipLogging
				inPresenter: transcript
				view: transcript view.
	self assert: commandQuery isEnabled.
	isLogging := BrowserUpdate current isLogging.
	
	[jadeiteItem := transcript view menuBar items detect: [:menuItem | '*Jadeite*' match: menuItem text].
	loggingItem := jadeiteItem items
				detect: [:item | (item class canUnderstand: #description) and: [item description = 'Logging Enabled']].
	loggingItem commandDescription performAgainst: transcript.	"this will reset the log file. That seems ok for now"
	self assert: BrowserUpdate current isLogging equals: isLogging not]
			ensure: [BrowserUpdate current isLogging: isLogging].
	commandQuery := self
				queryCommand: #browseJadeiteLogs
				inPresenter: transcript
				view: transcript view.
	self assert: commandQuery isEnabled.
	logger := self openLogBrowser.
	[self assert: (logger isKindOf: JadeiteLoggerShell)] ensure: [logger view close]!

test_loggingIds
	"sent & received logging services should have the same groupId because it's a service call.
	id will vary based on number of comments logged"

	| rs filename objects wasLogging file service sentService receivedService |
	self testsIssue: #issue250 withTitle: 'Need logging capability in Jadeite'.
	file := File
				open: BrowserUpdate current logFileName
				mode: #truncate
				check: false.	"open and truncate if existing or create a new file"
	file close.
	wasLogging := BrowserUpdate current isLogging.
	BrowserUpdate current isLogging: true.
	BrowserUpdate current resetLoggingService.
	
	[service := (RowanProjectService new name: 'Rowan')
				command: #update;
				commandArgs: Array new.
	self issueCommand: service.
	filename := BrowserUpdate current logFileName.
	objects := OrderedCollection new.
	rs := FileStream open: filename mode: #read.
	[[rs atEnd] whileFalse: [objects add: (STON fromStream: rs)]] ensure: [rs close].
	sentService := objects detect: [:loggingService | loggingService mode = #sent].
	receivedService := objects detect: [:loggingService | loggingService mode = #sent].
	self assert: receivedService groupId equals: sentService groupId]
			ensure: 
				[file delete.
				BrowserUpdate current isLogging: wasLogging]!

test_logReceivedServices
	| rs filename objects wasLogging file service receivedServices |
	self testsIssue: #issue250 withTitle: 'Need logging capability in Jadeite'.
	file := File
				open: BrowserUpdate current logFileName
				mode: #truncate
				check: false.	"open and truncate if existing or create a new file"
	file close.
	wasLogging := BrowserUpdate current isLogging.
	BrowserUpdate current isLogging: true.
	
	[service := (RowanProjectService new name: 'Rowan')
				command: #update;
				commandArgs: Array new.
	self issueCommand: service.
	filename := BrowserUpdate current logFileName.
	objects := OrderedCollection new.
	rs := FileStream open: filename mode: #read.
	[[rs atEnd] whileFalse: [objects add: (STON fromStream: rs)]] ensure: [rs close].
	receivedServices := objects select: [:loggingService | loggingService mode = #received].
	self assert: receivedServices size equals: 1.
	self assert: (receivedServices first isKindOf: TestLoggingService).
	self assert: (receivedServices first services first isKindOf: RowanProjectService).
	self assert: receivedServices first location equals: #client.
	self assert: receivedServices first mode equals: #received]
			ensure: 
				[file delete.
				BrowserUpdate current isLogging: wasLogging]!

test_logSentServices
	| rs filename objects wasLogging file service sentServices |
	self testsIssue: #issue250 withTitle: 'Need logging capability in Jadeite'.
	file := File
				open: BrowserUpdate current logFileName
				mode: #truncate
				check: false.	"open and truncate if existing or create a new file"
	file close.
	wasLogging := BrowserUpdate current isLogging.
	BrowserUpdate current isLogging: true.
	
	[service := (RowanProjectService new name: 'Rowan')
				command: #update;
				commandArgs: Array new.
	self issueCommand: service.
	filename := BrowserUpdate current logFileName.
	objects := OrderedCollection new.
	rs := FileStream open: filename mode: #read.
	[[rs atEnd] whileFalse: [objects add: (STON fromStream: rs)]] ensure: [rs close].
	sentServices := objects select: [:loggingService | loggingService mode = #sent].
	self assert: sentServices size equals: 1.
	self assert: (sentServices first isKindOf: TestLoggingService).
	self assert: (sentServices first services first isKindOf: RowanProjectService).
	self assert: sentServices first location equals: #client.
	self assert: sentServices first mode equals: #sent]
			ensure: 
				[file delete.
				BrowserUpdate current isLogging: wasLogging]!

test_newLoggingServiceCreated
	| loggingService service |
	"every service call should create a new logging service regardless of logging enablement."
	self testsIssue: #issue250 withTitle: 'Need logging capability in Jadeite'.
	Smalltalk removeKey: #JadeiteTestLoggingServiceClass ifAbsent: [].	"Make sure we don't create an instance of TestLoggingService"
	loggingService := BrowserUpdate current loggingService.
	service := RowanBrowserService new
				command: #packagesWithTests;
				commandArgs: Array new.
	self issueCommand: service.
	self deny: BrowserUpdate current loggingService sameAs: loggingService.
	self assert: (BrowserUpdate current loggingService isKindOf: RowanLoggingService)!

test_noFileWrittenWhenNotLogging
	| rs filename objects wasLogging file |
	self testsIssue: #issue250 withTitle: 'Need logging capability in Jadeite'.
	self assert: BrowserUpdate current logFileName equals: 'jadeiteTestFilename.txt'.
	file := File
				open: BrowserUpdate current logFileName
				mode: #truncate
				check: false.	"open and truncate if existing or create a new file"
	file close.
	wasLogging := BrowserUpdate current isLogging.
	BrowserUpdate current isLogging: false.
	
	[BrowserUpdate current logComment: 'Test comment'.
	filename := BrowserUpdate current logFileName.
	objects := OrderedCollection new.
	rs := FileStream open: filename mode: #read.
	[[rs atEnd] whileFalse: [objects add: (STON fromStream: rs)]] ensure: [rs close].
	self assert: objects size equals: 0]
			ensure: 
				[file delete.
				BrowserUpdate current isLogging: wasLogging]! !
!JadeiteLoggerTestCase categoriesFor: #openLogBrowser!private!support!tests! !
!JadeiteLoggerTestCase categoriesFor: #setUp!public!setup teardown! !
!JadeiteLoggerTestCase categoriesFor: #tearDown!public!setup teardown! !
!JadeiteLoggerTestCase categoriesFor: #test_equality!public!tests! !
!JadeiteLoggerTestCase categoriesFor: #test_isLoggingDefaults!public!tests! !
!JadeiteLoggerTestCase categoriesFor: #test_logComment!public!tests! !
!JadeiteLoggerTestCase categoriesFor: #test_loggerCanHandleNilFilenames!public!tests! !
!JadeiteLoggerTestCase categoriesFor: #test_loggerContainsServices!public!tests! !
!JadeiteLoggerTestCase categoriesFor: #test_loggerMenuEnablement!public!tests! !
!JadeiteLoggerTestCase categoriesFor: #test_loggingIds!public!tests! !
!JadeiteLoggerTestCase categoriesFor: #test_logReceivedServices!public!tests! !
!JadeiteLoggerTestCase categoriesFor: #test_logSentServices!public!tests! !
!JadeiteLoggerTestCase categoriesFor: #test_newLoggingServiceCreated!public!tests! !
!JadeiteLoggerTestCase categoriesFor: #test_noFileWrittenWhenNotLogging!public!tests! !

