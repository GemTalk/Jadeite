"Filed out from Dolphin Smalltalk 7"!

JadeiteAbstractTestCase subclass: #JadeiteMiscellaneousTestCase
	instanceVariableNames: 'workspace'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteMiscellaneousTestCase guid: (GUID fromString: '{3f3dd3e4-13f5-42ea-b424-b89439a9b357}')!
JadeiteMiscellaneousTestCase comment: ''!
!JadeiteMiscellaneousTestCase categoriesForClass!Unclassified! !
!JadeiteMiscellaneousTestCase methodsFor!

tearDown
	super tearDown.
	workspace ifNotNil: [workspace view close]!

test_adHocDisplay
	| workspace |
	self testsIssue: #issue427 withTitle: '(3.0.60) autocommit not done after successful doits'.
	workspace := JadeWorkspace showOnSession: session.
	
	[self assert: (workspace isKindOf: JadeWorkspace).
	workspace setDocumentData: '123'.
	workspace codePane documentPresenter setFocus.
	workspace codePane jadeDisplay.
	self assert: workspace codePane documentPresenter value equals: '123 123']
			ensure: 
				[workspace isModified: false.
				workspace view close]!

test_adHocExecute
	| workspace |
	self testsIssue: #issue427 withTitle: '(3.0.60) autocommit not done after successful doits'.
	workspace := JadeWorkspace showOnSession: session.
	
	[self assert: (workspace isKindOf: JadeWorkspace).
	session executeString: 'UserGlobals removeKey: #foo ifAbsent:[]'.
	workspace setDocumentData: 'UserGlobals at: #foo put: ''bar'''.
	workspace codePane documentPresenter setFocus.
	workspace codePane jadeExecute.
	self assert: workspace codePane documentPresenter value equals: 'UserGlobals at: #foo put: ''bar'''.
	self assert: (session executeString: 'UserGlobals at: #foo') equals: 'bar']
			ensure: 
				[workspace isModified: false.
				workspace view close]!

test_autoCommitDoesNotMakeRoundTripWhenOpeningBrowser
	"Not a very good test but the last service logged should not be an #updateAutoCommit command which was the bug"

	projectsBrowser
		ifNil: [projectsBrowser := self openWindow: [transcript openJadeiteProjectsBrowser]].
	
	[BrowserUpdate current loggingService services
		do: [:service | self deny: service updateType = #updateAutoCommit]]
			ensure: [self destroy: projectsBrowser]!

test_autoCommitInAdHocDisplay
	| workspace |
	self testsIssue: #issue427 withTitle: '(3.0.60) autocommit not done after successful doits'.
	
	[self setAutoCommit: true.
	session executeString: 'UserGlobals at: #TestCommit put: true'.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	workspace := JadeWorkspace showOnSession: session.
	workspace setDocumentData: '123'.
	workspace codePane documentPresenter setFocus.
	workspace codePane jadeDisplay.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self abortTransaction.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self assert: workspace codePane documentPresenter value equals: '123 123']
			ensure: 
				[session executeString: 'UserGlobals removeKey: #TestCommit'.
				self commitTransaction.
				self setAutoCommit: false.
				workspace isModified: false.
				workspace view close]!

test_autoCommitInAdHocExecution
	| workspace |
	self testsIssue: #issue427 withTitle: '(3.0.60) autocommit not done after successful doits'.
	
	[self setAutoCommit: true.
	session executeString: 'UserGlobals at: #TestCommit put: true'.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	workspace := JadeWorkspace showOnSession: session.
	workspace setDocumentData: '''doSomething'''.
	workspace codePane documentPresenter setFocus.
	workspace codePane jadeExecute.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self abortTransaction.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]')	"TestCommit was committed"]
			ensure: 
				[session executeString: 'UserGlobals removeKey: #TestCommit'.
				self commitTransaction.
				self setAutoCommit: false.
				workspace isModified: false.
				workspace view close]!

test_autoCommitOffInAdHocDisplay
	| workspace |
	self testsIssue: #issue427 withTitle: '(3.0.60) autocommit not done after successful doits'.
	
	[self setAutoCommit: false.
	session executeString: 'UserGlobals at: #TestCommit put: true'.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	workspace := JadeWorkspace showOnSession: session.
	workspace setDocumentData: '123'.
	workspace codePane documentPresenter setFocus.
	workspace codePane jadeDisplay.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self abortTransaction.
	self assertIsNil: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self assert: workspace codePane documentPresenter value equals: '123 123']
			ensure: 
				[workspace isModified: false.
				workspace view close]!

test_autoCommitOffInAdHocExecution
	| workspace |
	self testsIssue: #issue427 withTitle: '(3.0.60) autocommit not done after successful doits'.
	
	[self setAutoCommit: false.
	session executeString: 'UserGlobals at: #TestCommit put: true'.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	workspace := JadeWorkspace showOnSession: session.
	workspace setDocumentData: '''doSomething'''.
	workspace codePane documentPresenter setFocus.
	workspace codePane jadeExecute.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self abortTransaction.
	self assertIsNil: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]')]
			ensure: 
				[workspace isModified: false.
				workspace view close]!

test_autoCommitUpdatedInSession
	| autoCommit |
	
	[autoCommit := session autoCommit.
	self setAutoCommit: true.
	self assert: session autoCommit.
	self setAutoCommit: false.
	self deny: session autoCommit]
			ensure: [self setAutoCommit: autoCommit]!

test_convertToPattern
	| pattern |
	self testsIssue: #issue258
		withTitle: 'wildcard senders and implentors don''t return proper selection list'.
	pattern := JadePresenter convertToPattern: '*symboldict*'. 
	self assert: pattern equals: #('' $* 'symboldict' $*).
	pattern := JadePresenter convertToPattern: '*SymbolDict*'. 
	self assert: pattern equals: #('' $* 'SymbolDict' $*).
	pattern := JadePresenter convertToPattern: '*SymbolDict*:'. 
	self assert: pattern equals: #('' $* 'SymbolDict' $* ':').
	pattern := JadePresenter convertToPattern: 'symboldict*'. 
	self assert: pattern equals: #('symboldict' $*).
	!

test_dolphinStackDumpBanners
	| timestampString stream |
	self testsIssue: #issue237 withTitle: 'time stamp at end of Dolphin stack dump would be useful'.
	timestampString := JadeSessionManager stackDumpTimeStampString.
	stream := WriteStream on: String new.
	JadeSessionManager prependStackStartMessage: timestampString on: stream.
	self assert: ('*' , timestampString , '*' match: stream contents).
	self assert: ('*Starting Dolphin stack dump at*' match: stream contents).
	stream := WriteStream on: String new.
	JadeSessionManager appendStackEndMessage: timestampString on: stream.
	self assert: ('*' , timestampString , '*' match: stream contents).
	self assert: ('*Ending Dolphin stack dump started at*' match: stream contents).!

test_findInWorkspace
	| workspace findView documentPresenter |
	self testsIssue: #issue468 withTitle: 'Find text dialog does not highlight correctly'.
	workspace := JadeWorkspace showOnSession: session.
	
	[workspace model value: '1234


1254

124'.
	documentPresenter := workspace codePane documentPresenter.
	findView := workspace codePane documentPresenter view findPrompt: '12*4'.
	findView modePresenter value: #wildcardExpression.
	findView wrapPresenter value: true.
	findView findNext.
	self assert: documentPresenter selection equals: '1234'.
	findView findNext.
	self assert: documentPresenter selection equals: '1254'.
	findView findNext.	"Last one doesn't match pattern. wrap around finds first again"
	self assert: documentPresenter selection equals: '1234']
			ensure: 
				[workspace view close.
				findView view close]!

test_releaseOops
	| remoteObject service |
	self testsIssue: #issue413 withTitle: '(3.0.56 & 3.0.62) running out vm memory quickly'.
	session releaseAllOops.
	self assert: (session executeString: 'System hiddenSetSize: 39') equals: 0.
	remoteObject := session executeString: 'Array new'.
	self assert: (session executeString: 'System hiddenSetSize: 39') = 1.
	session releaseAllOops.
	self assert: (session executeString: 'System hiddenSetSize: 39') equals: 0.
	remoteObject := session executeString: 'Dictionary new'.
	self assert: (session executeString: 'System hiddenSetSize: 39') = 1.
	service := RowanAnsweringService new.
	service command: #isTranscriptInstalled.
	self issueCommand: service.
	self assert: (session executeString: 'System hiddenSetSize: 39') equals: 0.
	remoteObject := session executeString: 'Object new'.
	self assert: (session executeString: 'System hiddenSetSize: 39') = 1.
	service := RowanProjectService new name: 'Rowan'.
	BrowserUpdate current updateServices: (Array with: service) session: session.
	self assert: (session executeString: 'System hiddenSetSize: 39') equals: 0.
	self auditAll!

test_workspaceBrowseProjects
	| workspace jadeiteMenu browseProjectsItem |
	self testsIssue: #issue265 withTitle: 'workspace could use a `browse projects` menu item ... '.
	projectsBrowser
		ifNil: [projectsBrowser := self openWindow: [transcript openJadeiteProjectsBrowser]].
	workspace := JadeWorkspace showOnSession: session.
	
	[jadeiteMenu := self itemNamed: 'Jadeite' in: workspace view menuBar.
	browseProjectsItem := self itemNamed: 'Browse Projects' in: jadeiteMenu.
	projectsBrowser := browseProjectsItem commandDescription performAgainst: workspace]
			ensure: 
				[workspace view close.
				self destroy: projectsBrowser]!

test_workspaceConfirmInteraction
	| workspace result |
	self testsIssue: #issue303 withTitle: 'Need to handle confirm:'.
	TestMessageBox enableJadeiteTestMessageBox.
	workspace := (JadeWorkspace showOnSession: session) caption: 'Jade Workspace - Test Interactions'.
	workspace codePane documentPresenter value: 'self confirm: ''hi'''.
	workspace codePane selectAll.
	
	[TestMessageBox plannedResult: #no.
	result := workspace executeSelectionOrLine.	"JadeTextDocument>>jadeExecuteAndDisplay: creates a new process which is hard to test. Send the underlying
										commands instead which do not fork"
	workspace jadeExecuteAndDisplay: true result: result.
	self assert: workspace codePane documentPresenter value equals: 'self confirm: ''hi'' false'.
	workspace codePane documentPresenter value: 'self confirm: ''hi'''.
	workspace codePane selectAll.
	TestMessageBox plannedResult: #yes.
	result := workspace executeSelectionOrLine.
	workspace jadeExecuteAndDisplay: true result: result.
	self assert: workspace codePane documentPresenter value equals: 'self confirm: ''hi'' true'.
	self assert: TestMessageBox lastMessageBox caption equals: 'Rowan Confirmation'.
	self assert: TestMessageBox lastMessageBox text equals: 'hi']
			ensure: 
				[workspace view close.
				TestMessageBox disableJadeiteTestMessageBox]!

test_workspaceDoubleClickIncludesColon
	"It's difficult to fake up a mouse event so ensure the method that grabs the colon
	is setup as an event and includes the colon after being called"

	self testsIssue: #issue301 withTitle: '(3.0.50) inconsistent selector selection on double-click'.
	workspace := (JadeWorkspace showOnSession: session) caption: 'Jade Workspace - Test Double Click'.
	workspace codePane documentPresenter value: 'Array with: 1; halt'.
	self
		assert: (workspace codePane documentPresenter events at: #leftButtonDoubleClicked:) messages first
				asSymbol
		equals: #methodDoubleClicked:.
	workspace codePane documentPresenter selectionRange: (7 to: 10).
	self assert: workspace codePane documentPresenter selection equals: 'with'.
	workspace codePane  methodDoubleClicked: nil.
	self assert: workspace codePane documentPresenter selectionRange equals: (7 to: 11).
	self assert: workspace codePane documentPresenter selection equals: 'with:'!

test_workspaceInformInteraction
	| workspace result |
	self testsIssue: #issue303 withTitle: 'Need to handle confirm:'.
	TestMessageBox enableJadeiteTestMessageBox.
	workspace := (JadeWorkspace showOnSession: session) caption: 'Jade Workspace - Test Interactions'.
	workspace codePane documentPresenter value: 'self inform: ''hi'''.
	workspace codePane selectAll.
	
	[TestMessageBox plannedResult: #ok.
	result := workspace executeSelectionOrLine.	"JadeTextDocument>>jadeExecuteAndDisplay: creates a new process which is hard to test. Send the underlying
										commands instead which do not fork"
	workspace jadeExecuteAndDisplay: false result: result.
	self assert: workspace codePane documentPresenter value equals: 'self inform: ''hi'''.
	self assert: TestMessageBox lastMessageBox caption equals: 'Rowan Notification'.
	self assert: TestMessageBox lastMessageBox text equals: 'hi']
			ensure: 
				[workspace view close.
				TestMessageBox disableJadeiteTestMessageBox]!

test_workspaceJadeiteMenuAdHocExecutionItems
	| workspace jadeiteMenu debugMenuItem executeMenuItem inspectMenuItem displayMenuItem |
	self testsIssue: #issue474 withTitle: '(3.0.69) inconsistent debug menu on workspaces'.
	workspace := (JadeWorkspace showOnSession: session) caption: 'Jade Workspace - Compile Error'.
	
	[jadeiteMenu := workspace view menuBar items detect: [:menu | '*Jadeite*' match: menu text]
				ifNone: [].
	self denyIsNil: jadeiteMenu.
	debugMenuItem := jadeiteMenu items detect: [:command | '*De&bug*' match: command text] ifNone: [].
	self denyIsNil: debugMenuItem.
	self assert: debugMenuItem command equals: #jadeDebug.
	self assert: (workspace class canUnderstand: #jadeDebug).
	self assert: debugMenuItem commandDescription acceleratorKey = 4674.	"Ctrl-B"
	executeMenuItem := jadeiteMenu items detect: [:command | '*Execute*' match: command text] ifNone: [].
	self denyIsNil: executeMenuItem.
	self assert: executeMenuItem command equals: #jadeExecute.
	self assert: (workspace class canUnderstand: #jadeExecute).
	self assert: executeMenuItem commandDescription acceleratorKey = 4677.	"Ctrl-E"
	inspectMenuItem := jadeiteMenu items detect: [:command | '*Inspect*' match: command text] ifNone: [].
	self denyIsNil: inspectMenuItem.
	self assert: inspectMenuItem command equals: #jadeInspect.
	self assert: (workspace class canUnderstand: #jadeInspect).
	self assert: inspectMenuItem commandDescription acceleratorKey = 4689.	"Ctrl-Q"
	displayMenuItem := jadeiteMenu items detect: [:command | '*Display*' match: command text] ifNone: [].
	self denyIsNil: displayMenuItem.
	self assert: displayMenuItem command equals: #jadeDisplay.
	self assert: (workspace class canUnderstand: #jadeDisplay).
	self assert: displayMenuItem commandDescription acceleratorKey = 4676	"Ctrl-D"]
			ensure: [workspace view close]!

test_workspaceMessageImplementors
	| methodListBrowser browseImplementorsItem menu |
	self testsIssue: #issue520 withTitle: '(3.0.77) `browse senders`has inconsistent behavior'.
	workspace := (JadeWorkspace showOnSession: session) caption: 'Jade Workspace - Test Implementors'.
	workspace codePane documentPresenter value: 'RBParser parseExpression: 123'.
	workspace codePane selectAll.
	menu := workspace codePane documentPresenter view contextMenu.
	workspace codePane methodMenu: menu.
	browseImplementorsItem := menu items
				detect: [:menuItem | menuItem isDivider not and: [menuItem command asSymbol = #browseImplementorsOf:]]
				ifNone: [].
	self assert: browseImplementorsItem text equals: 'Browse Implementors of #parseExpression:'.
	methodListBrowser := workspace codePane browseImplementors.
	[self assert: ('Implementors of ''parseExpression:''*' match: methodListBrowser caption)]
		ensure: [methodListBrowser view close]!

test_workspaceMessageImplementorsWithEndingQuote
	| methodListBrowser browseImplementorsItem menu |
	self testsIssue: #issue520 withTitle: '(3.0.77) `browse senders`has inconsistent behavior'.
	workspace := (JadeWorkspace showOnSession: session) caption: 'Jade Workspace - Test Implementors'.
	workspace codePane documentPresenter value: 'RBParser parseExpression: ''env:categorysDo:'''.
	workspace codePane selectAll.
	menu := workspace codePane documentPresenter view contextMenu.
	workspace codePane methodMenu: menu.
	browseImplementorsItem := menu items
				detect: [:menuItem | menuItem isDivider not and: [menuItem command asSymbol = #browseImplementorsOf:]]
				ifNone: [].
	self assert: browseImplementorsItem text equals: 'Browse Implementors of #parseExpression:'.
	methodListBrowser := workspace codePane browseImplementors.
	[self assert: ('Implementors of ''parseExpression:''*' match: methodListBrowser caption)]
		ensure: [methodListBrowser view close]!

test_workspaceMessageSenders
	| methodListBrowser browseSendersItem menu |
	self testsIssue: #issue520 withTitle: '(3.0.77) `browse senders`has inconsistent behavior'.
	workspace := (JadeWorkspace showOnSession: session) caption: 'Jade Workspace - Test Implementors'.
	workspace codePane documentPresenter value: 'RBParser parseExpression: 123'.
	workspace codePane selectAll.
	menu := workspace codePane documentPresenter view contextMenu.
	workspace codePane methodMenu: menu.
	browseSendersItem := menu items
				detect: [:menuItem | menuItem isDivider not and: [menuItem command asSymbol = #browseSendersOf:]]
				ifNone: [].
	self assert: browseSendersItem text equals: 'Browse Senders of #parseExpression:'.
	methodListBrowser := workspace codePane browseSenders.
	[self assert: ('Senders of ''parseExpression:''*' match: methodListBrowser caption)]
		ensure: [methodListBrowser view close]!

test_workspaceMessageSendersWithEndingQuote
	| methodListBrowser browseSendersItem menu |
	self testsIssue: #issue520 withTitle: '(3.0.77) `browse senders`has inconsistent behavior'.
	workspace := (JadeWorkspace showOnSession: session) caption: 'Jade Workspace - Test Implementors'.
	workspace codePane documentPresenter value: 'RBParser parseExpression: ''env:categorysDo:'''.
	workspace codePane selectAll.
	menu := workspace codePane documentPresenter view contextMenu.
	workspace codePane methodMenu: menu.
	browseSendersItem := menu items
				detect: [:menuItem | menuItem isDivider not and: [menuItem command asSymbol = #browseSendersOf:]]
				ifNone: [].
	self assert: browseSendersItem text equals: 'Browse Senders of #parseExpression:'.
	methodListBrowser := workspace codePane browseSenders.
	[self assert: ('Senders of ''parseExpression:''*' match: methodListBrowser caption)]
		ensure: [methodListBrowser view close]!

test_workspacePlainStringImplementors
	| methodListBrowser browseImplementorsItem menu |
	self testsIssue: #issue520 withTitle: '(3.0.77) `browse senders`has inconsistent behavior'.
	workspace := (JadeWorkspace showOnSession: session) caption: 'Jade Workspace - Test Implementors'.
	workspace codePane documentPresenter value: 'env:categorysDo:'.
	workspace codePane selectAll.
	menu := workspace codePane documentPresenter view contextMenu.
	workspace codePane methodMenu: menu.
	browseImplementorsItem := menu items
				detect: [:menuItem | menuItem isDivider not and: [menuItem command asSymbol = #browseImplementorsOf:]]
				ifNone: [].
	self assert: browseImplementorsItem text equals: 'Browse Implementors of #env:categorysDo:'.
	methodListBrowser := workspace codePane browseImplementors.
	[self assert: ('Implementors of ''env:categorysDo:''*' match: methodListBrowser caption)]
		ensure: [methodListBrowser view close]!

test_workspacePlainStringSenders
	| methodListBrowser browseSendersItem menu |
	self testsIssue: #issue520 withTitle: '(3.0.77) `browse senders`has inconsistent behavior'.
	workspace := (JadeWorkspace showOnSession: session) caption: 'Jade Workspace - Test Implementors'.
	workspace codePane documentPresenter value: 'env:categorysDo:'.
	workspace codePane selectAll.
	menu := workspace codePane documentPresenter view contextMenu.
	workspace codePane methodMenu: menu.
	browseSendersItem := menu items
				detect: [:menuItem | menuItem isDivider not and: [menuItem command asSymbol = #browseSendersOf:]]
				ifNone: [].
	self assert: browseSendersItem text equals: 'Browse Senders of #env:categorysDo:'.
	methodListBrowser := workspace codePane browseSenders.
	[self assert: ('Senders of ''env:categorysDo:''*' match: methodListBrowser caption)]
		ensure: [methodListBrowser view close]!

test_workspaceStringWithQuotesImplementors
	| methodListBrowser browseImplementorsItem menu |
	self testsIssue: #issue520 withTitle: '(3.0.77) `browse senders`has inconsistent behavior'.
	workspace := (JadeWorkspace showOnSession: session) caption: 'Jade Workspace - Test Implementors'.
	workspace codePane documentPresenter value: '''env:categorysDo:'''.
	workspace codePane selectAll.
	menu := workspace codePane documentPresenter view contextMenu.
	workspace codePane methodMenu: menu.
	browseImplementorsItem := menu items
				detect: [:menuItem | menuItem isDivider not and: [menuItem command asSymbol = #browseImplementorsOf:]]
				ifNone: [].
	self assert: browseImplementorsItem text equals: 'Browse Implementors of #env:categorysDo:'.
	methodListBrowser := workspace codePane browseImplementors.
	[self assert: ('Implementors of ''env:categorysDo:''*' match: methodListBrowser caption)]
		ensure: [methodListBrowser view close]!

test_workspaceStringWithQuotesSenders
	| methodListBrowser browseSendersItem menu |
	self testsIssue: #issue520 withTitle: '(3.0.77) `browse senders`has inconsistent behavior'.
	workspace := (JadeWorkspace showOnSession: session) caption: 'Jade Workspace - Test Implementors'.
	workspace codePane documentPresenter value: '''env:categorysDo:'''.
	workspace codePane selectAll.
	menu := workspace codePane documentPresenter view contextMenu.
	workspace codePane methodMenu: menu.
	browseSendersItem := menu items
				detect: [:menuItem | menuItem isDivider not and: [menuItem command asSymbol = #browseSendersOf:]]
				ifNone: [].
	self assert: browseSendersItem text equals: 'Browse Senders of #env:categorysDo:'.
	methodListBrowser := workspace codePane browseSenders.
	[self assert: ('Senders of ''env:categorysDo:''*' match: methodListBrowser caption)]
		ensure: [methodListBrowser view close]!

test_workspaceSymbolImplementors
	| methodListBrowser browseImplementorsItem menu |
	self testsIssue: #issue520 withTitle: '(3.0.77) `browse senders`has inconsistent behavior'.
	workspace := (JadeWorkspace showOnSession: session) caption: 'Jade Workspace - Test Implementors'.
	workspace codePane documentPresenter value: '#env:categorysDo:'.
	workspace codePane selectAll.
	menu := workspace codePane documentPresenter view contextMenu.
	workspace codePane methodMenu: menu.
	browseImplementorsItem := menu items
				detect: [:menuItem | menuItem isDivider not and: [menuItem command asSymbol = #browseImplementorsOf:]]
				ifNone: [].
	self assert: browseImplementorsItem text equals: 'Browse Implementors of #env:categorysDo:'.
	methodListBrowser := workspace codePane browseImplementors.
	[self assert: ('Implementors of ''env:categorysDo:''*' match: methodListBrowser caption)]
		ensure: [methodListBrowser view close]!

test_workspaceSymbolSenders
	| methodListBrowser browseSendersItem menu |
	self testsIssue: #issue520 withTitle: '(3.0.77) `browse senders`has inconsistent behavior'.
	workspace := (JadeWorkspace showOnSession: session) caption: 'Jade Workspace - Test Implementors'.
	workspace codePane documentPresenter value: '#env:categorysDo:'.
	workspace codePane selectAll.
	menu := workspace codePane documentPresenter view contextMenu.
	workspace codePane methodMenu: menu.
	browseSendersItem := menu items
				detect: [:menuItem | menuItem isDivider not and: [menuItem command asSymbol = #browseSendersOf:]]
				ifNone: [].
	self assert: browseSendersItem text equals: 'Browse Senders of #env:categorysDo:'.
	methodListBrowser := workspace codePane browseSenders.
	[self assert: ('Senders of ''env:categorysDo:''*' match: methodListBrowser caption)]
		ensure: [methodListBrowser view close]!

test_workspaceSymbolWithQuotesImplementors
	| methodListBrowser browseImplementorsItem menu |
	self testsIssue: #issue520 withTitle: '(3.0.77) `browse senders`has inconsistent behavior'.
	workspace := (JadeWorkspace showOnSession: session) caption: 'Jade Workspace - Test Implementors'.
	workspace codePane documentPresenter value: '#''env:categorysDo:'''.
	workspace codePane selectAll.
	menu := workspace codePane documentPresenter view contextMenu.
	workspace codePane methodMenu: menu.
	browseImplementorsItem := menu items
				detect: [:menuItem | menuItem isDivider not and: [menuItem command asSymbol = #browseImplementorsOf:]]
				ifNone: [].
	self assert: browseImplementorsItem text equals: 'Browse Implementors of #env:categorysDo:'.
	methodListBrowser := workspace codePane browseImplementors.
	[self assert: ('Implementors of ''env:categorysDo:''*' match: methodListBrowser caption)]
		ensure: [methodListBrowser view close]!

test_workspaceSymbolWithQuotesSenders
	| methodListBrowser browseSendersItem menu |
	self testsIssue: #issue520 withTitle: '(3.0.77) `browse senders`has inconsistent behavior'.
	workspace := (JadeWorkspace showOnSession: session) caption: 'Jade Workspace - Test Implementors'.
	workspace codePane documentPresenter value: '#''env:categorysDo:'''.
	workspace codePane selectAll.
	menu := workspace codePane documentPresenter view contextMenu.
	workspace codePane methodMenu: menu.
	browseSendersItem := menu items
				detect: [:menuItem | menuItem isDivider not and: [menuItem command asSymbol = #browseSendersOf:]]
				ifNone: [].
	self assert: browseSendersItem text equals: 'Browse Senders of #env:categorysDo:'.
	methodListBrowser := workspace codePane browseSenders.
	[self assert: ('Senders of ''env:categorysDo:''*' match: methodListBrowser caption)]
		ensure: [methodListBrowser view close]!

testClassServiceNameIsString
	| classService |
	self testsIssue: #issue441 withTitle: '(3.0.62) suspicious code in RowanClassService>>hierarchyClassServiceFor:'.
	classService := RowanClassService named: 'RowanClassServiceTest'.
	self assert: classService name isKindOf: String. 
	classService := RowanClassService new name: 'RowanClassServiceTest'.
	self assert: classService name isKindOf: String. !

testMethodServiceClassNameIsString
	| methodService |
	self testsIssue: #issue441
		withTitle: '(3.0.62) suspicious code in RowanClassService>>hierarchyClassServiceFor:'.
	methodService := RowanMethodService new
				selector: 'fnoodle';
				className: 'JadeiteMiscellaneousTestCase';
				meta: false.
	self assert: methodService className isKindOf: String.
	methodService := RowanMethodService new
				selector: 'fnoodle';
				className: #JadeiteMiscellaneousTestCase;
				meta: false.
	self assert: methodService className isKindOf: String! !
!JadeiteMiscellaneousTestCase categoriesFor: #tearDown!private!support! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_adHocDisplay!public! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_adHocExecute!public! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_autoCommitDoesNotMakeRoundTripWhenOpeningBrowser!auto commit!public! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_autoCommitInAdHocDisplay!auto commit!public! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_autoCommitInAdHocExecution!auto commit!public! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_autoCommitOffInAdHocDisplay!auto commit!public! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_autoCommitOffInAdHocExecution!auto commit!public! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_autoCommitUpdatedInSession!auto commit!public! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_convertToPattern!public!test! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_dolphinStackDumpBanners!public!test! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_findInWorkspace!public!test! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_releaseOops!public! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_workspaceBrowseProjects!public!test!test menus!test workspaces! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_workspaceConfirmInteraction!public!test!test menus!test workspaces! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_workspaceDoubleClickIncludesColon!public!test!test workspaces! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_workspaceInformInteraction!public!test!test menus!test workspaces! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_workspaceJadeiteMenuAdHocExecutionItems!public!test!test menus!test workspaces! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_workspaceMessageImplementors!public!test browse!test workspaces! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_workspaceMessageImplementorsWithEndingQuote!public!test browse!test workspaces! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_workspaceMessageSenders!public!test browse!test workspaces! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_workspaceMessageSendersWithEndingQuote!public!test browse!test workspaces! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_workspacePlainStringImplementors!public!test browse!test workspaces! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_workspacePlainStringSenders!public!test browse!test workspaces! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_workspaceStringWithQuotesImplementors!public!test browse!test workspaces! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_workspaceStringWithQuotesSenders!public!test browse!test workspaces! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_workspaceSymbolImplementors!public!test browse!test workspaces! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_workspaceSymbolSenders!public!test browse!test workspaces! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_workspaceSymbolWithQuotesImplementors!public!test browse!test workspaces! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_workspaceSymbolWithQuotesSenders!public!test browse!test workspaces! !
!JadeiteMiscellaneousTestCase categoriesFor: #testClassServiceNameIsString!public! !
!JadeiteMiscellaneousTestCase categoriesFor: #testMethodServiceClassNameIsString!public! !

