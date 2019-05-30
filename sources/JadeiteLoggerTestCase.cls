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

	| commandQuery loggingItem isLogging jadeiteItem browseItem loggerItem logger |
	self testsIssue: #issue250 withTitle: 'Need logging capability in Jadeite'.
	commandQuery := self
				queryCommand: #flipLogging
				inPresenter: transcript
				view: transcript view.
	self assert: commandQuery isEnabled.
	isLogging := BrowserUpdate current isLogging.
	
	[jadeiteItem := transcript view menuBar items detect: [:menuItem | '*Jadeite*' match: menuItem text].
	loggingItem := jadeiteItem items
				detect: [:item | (item class canUnderstand: #description) and: [item description = 'Logging']].
	loggingItem commandDescription performAgainst: transcript.	"this will reset the log file. That seems ok for now"
	self assert: BrowserUpdate current isLogging equals: isLogging not]
			ensure: [BrowserUpdate current isLogging: isLogging].
	commandQuery := self
				queryCommand: #browseJadeiteLogs
				inPresenter: transcript
				view: transcript view.
	self assert: commandQuery isEnabled.
	browseItem := transcript view menuBar items detect: [:menuItem | '*Browse*' match: menuItem text].
	loggerItem := browseItem items
				detect: [:item | (item class canUnderstand: #description) and: [item description = 'Browse Jadeite Logs']].
	logger := loggerItem commandDescription performAgainst: transcript.
	[self assert: (logger isKindOf: JadeiteLoggerShell)] ensure: [logger view close]!

test_newLoggingServiceCreated
	| loggingService service |
	"every service call should create a new logging service regardless of logging enablement."
	self testsIssue: #issue250 withTitle: 'Need logging capability in Jadeite'.
	loggingService := BrowserUpdate current loggingService.
	service := RowanBrowserService new
				command: #packagesWithTests;
				commandArgs: Array new.
	self issueCommand: service.
	self deny: BrowserUpdate current loggingService sameAs: loggingService.
	self assert: (BrowserUpdate current loggingService isKindOf: RowanLoggingService)! !
!JadeiteLoggerTestCase categoriesFor: #test_loggerContainsServices!public! !
!JadeiteLoggerTestCase categoriesFor: #test_loggerMenuEnablement!public! !
!JadeiteLoggerTestCase categoriesFor: #test_newLoggingServiceCreated!public! !

