"Filed out from Dolphin Smallalk"!

JadeiteAbstractTestCase subclass: #JadeiteWorkspaceTestCase
	instanceVariableNames: 'workspace'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteWorkspaceTestCase guid: (GUID fromString: '{0bb5d350-7787-42bc-ab14-e419cd4eec79}')!
JadeiteWorkspaceTestCase comment: ''!
!JadeiteWorkspaceTestCase categoriesForClass!Unclassified! !
!JadeiteWorkspaceTestCase methodsFor!

tearDown
	super tearDown.
	workspace
		ifNotNil: 
			[workspace codePane documentPresenter view isModified: false.
			self destroy: workspace]!

test_workspaceAdHocDisplayUnicodeCharacters
	self testsIssue: #issue678
		withTitle: 'Print-it for out of range characters is... peculiar (3.0.92.3)'.
	workspace := (JadeWorkspace showOnSession: session)
				caption: 'Jade Workspace - Test Unicode Characters'.
	workspace codePane documentPresenter
		value: '''aa'', (String with: (Character withValue: 353)), ''bb''  '.
	workspace codePane selectAll.
	workspace activeTextEdit setFocus.
	workspace codePane jadeDisplay.
	self assert: workspace codePane documentPresenter selection equals: ' ''aašbb'''.
	self assert: workspace codePane documentPresenter value
		equals: '''aa'', (String with: (Character withValue: 353)), ''bb''   ''aašbb'''.!

test_workspaceBrowseProjects
	| jadeiteMenu browseProjectsItem |
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
	| result |
	self testsIssue: #issue303 withTitle: 'Need to handle confirm:'.
	TestMessageBox enableJadeiteTestMessageBox.
	workspace := (JadeWorkspace showOnSession: session) caption: 'Jade Workspace - Test Interactions'.
	workspace codePane documentPresenter value: 'self confirm: ''hi'''.
	workspace codePane selectAll.
	
	[TestMessageBox plannedResult: #no.
	result := workspace executeSelectionOrLine.	"JadeTextDocument>>jadeExecuteAndDisplay: creates a new process which is hard to test. Send the underlying
										commands instead which do not fork"
	workspace
		jadeExecuteAndDisplay: true
		result: result
		view: nil.
	self assert: workspace codePane documentPresenter value equals: 'self confirm: ''hi''false'.
	workspace codePane documentPresenter value: 'self confirm: ''hi'''.
	workspace codePane selectAll.
	TestMessageBox plannedResult: #yes.
	result := workspace executeSelectionOrLine.
	workspace
		jadeExecuteAndDisplay: true
		result: result
		view: nil.
	self assert: workspace codePane documentPresenter value equals: 'self confirm: ''hi''true'.
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

test_workspaceImplementorsMenuNotTooLong
	"The workspace allows you to pick arbitray code and search for implementors. 
	If it encounters a space, truncate the menu item display while still searching
	for the actual selection"

	| item |
	self testsIssue: #issue568
		withTitle: 'Workspace popup menu gets ridiculously long menu items for Browse Senders/Implementors'.
	workspace := (JadeWorkspace showOnSession: session)
				caption: 'Jadeite Workspace - Test Menu Item Length'.
	workspace codePane documentPresenter value: 'some random bunch of 123text'.
	workspace codePane documentPresenter view selectAll.
	self assert: workspace codePane documentPresenter selection equals: 'some random bunch of 123text'.
	workspace codePane methodMenuBreak: workspace codePane documentPresenter view contextMenu.
	item := self itemNamed: 'Browse Implementors of #somerandombunchof123text'
				in: workspace codePane documentPresenter view contextMenu.
	self assert: item command asSymbol equals: #browseImplementorsOf:!

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
	workspace
		jadeExecuteAndDisplay: false
		result: result
		view: nil.
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

test_workspaceSendersMenuNotTooLong
	"The workspace allows you to pick arbitray code and search for Senders. 
	If it encounters a space, truncate the menu item display while still searching
	for the actual selection"

	| item |
	self testsIssue: #issue568
		withTitle: 'Workspace popup menu gets ridiculously long menu items for Browse Senders/Senders'.
	workspace := (JadeWorkspace showOnSession: session)
				caption: 'Jadeite Workspace - Test Menu Item Length'.
	workspace codePane documentPresenter value: 'some random bunch of 123text'.
	workspace codePane documentPresenter view selectAll.
	self assert: workspace codePane documentPresenter selection equals: 'some random bunch of 123text'.
	workspace codePane methodMenuBreak: workspace codePane documentPresenter view contextMenu.
	item := self itemNamed: 'Browse Senders of #somerandombunchof123text'
				in: workspace codePane documentPresenter view contextMenu.
	self assert: item command asSymbol equals: #browseSendersOf:!

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
	workspace := (JadeWorkspace showOnSession: session) caption: 'Jade Workspace - Test Senders'.
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

test_workspaceSymbolSendersLeadingQuote
	| methodListBrowser browseSendersItem menu |
	self testsIssue: #issue520 withTitle: '(3.0.77) `browse senders`has inconsistent behavior'.
	workspace := (JadeWorkspace showOnSession: session)
				caption: 'Jade Workspace - test_workspaceSymbolSendersLeadingQuote'.
	workspace codePane documentPresenter value: '''abcde'' perform: #copyFrom:to: with: 2 with: 3'.
	workspace codePane selectAll.
	menu := workspace codePane documentPresenter view contextMenu.
	workspace codePane methodMenu: menu.
	browseSendersItem := menu items
				detect: [:menuItem | menuItem isDivider not and: [menuItem command asSymbol = #browseSendersOf:]]
				ifNone: [].
	self assert: browseSendersItem text equals: 'Browse Senders of #perform:with:with:'.
	methodListBrowser := workspace codePane browseSenders.
	[self assert: ('Senders of ''perform:with:with:''*' match: methodListBrowser caption)]
		ensure: [methodListBrowser view close]!

test_workspaceSymbolSendersRemoveSpaces
	| methodListBrowser browseSendersItem menu |
	self testsIssue: #issue520 withTitle: '(3.0.77) `browse senders`has inconsistent behavior'.
	workspace := (JadeWorkspace showOnSession: session)
				caption: 'Jade Workspace - test_workspaceSymbolSendersRemoveSpaces'.
	workspace codePane documentPresenter value: 'perform: with:'.	"has a space between keywords"
	workspace codePane selectAll.
	menu := workspace codePane documentPresenter view contextMenu.
	workspace codePane methodMenu: menu.
	browseSendersItem := menu items
				detect: [:menuItem | menuItem isDivider not and: [menuItem command asSymbol = #browseSendersOf:]]
				ifNone: [].
	self assert: browseSendersItem text equals: 'Browse Senders of #perform:with:'.
	methodListBrowser := browseSendersItem command value.
	[self assert: ('Senders of ''perform:with:''*' match: methodListBrowser caption)]
		ensure: [methodListBrowser view close].
	workspace codePane documentPresenter value: 'abc: def eft'.	"spaces within quotes"
	workspace codePane selectAll.
	menu := workspace codePane documentPresenter view contextMenu.
	workspace codePane methodMenu: menu.
	browseSendersItem := menu items
				detect: [:menuItem | menuItem isDivider not and: [menuItem command asSymbol = #browseSendersOf:]]
				ifNone: [].
	self assert: browseSendersItem text equals: 'Browse Senders of #abc:'.
	methodListBrowser := browseSendersItem command value.
	[self assert: ('Senders of ''abc:''*' match: methodListBrowser caption)]
		ensure: [methodListBrowser view close]!

test_workspaceSymbolSendersTruncateLongSelectors
	| methodListBrowser browseSendersItem menu |
	self testsIssue: #issue520 withTitle: '(3.0.77) `browse senders`has inconsistent behavior'.
	workspace := (JadeWorkspace showOnSession: session)
				caption: 'Jade Workspace - test_workspaceSymbolSendersRemoveSpaces'.
	workspace codePane documentPresenter
		value: 'abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz'.
	workspace codePane selectAll.
	menu := workspace codePane documentPresenter view contextMenu.
	workspace codePane methodMenu: menu.
	browseSendersItem := menu items
				detect: [:menuItem | menuItem isDivider not and: [menuItem command asSymbol = #browseSendersOf:]]
				ifNone: [].
	self assert: browseSendersItem text
		equals: 'Browse Senders of #abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwx ...'.
	methodListBrowser := browseSendersItem command value.
	[self assert: ('Senders of ''abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz''*' match: methodListBrowser caption)]
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

test_workspaceUnsavedChanges
	| caption |
	self testsIssue: #issue747
		withTitle: 'would be nice if "unsaved changes" dialog would include the window title in the message'.
	workspace := (JadeWorkspace showOnSession: session) caption: 'Jade Workspace - Test Unsaved Changes'.
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #no.
	
	[workspace setDocumentData: 'stuff'.
	workspace codePane documentPresenter view isModified: true.
	caption := JadePresenter defaultCaptionText: workspace view.
	self assert: ('*Jade Workspace*' match: caption). 
	workspace view close.
	self assert: TestMessageBox lastMessageBox caption equals: caption.
	self assert: TestMessageBox lastMessageBox text equals: JadePresenter defaultUnsavedChangesWithSaveText ]
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

test_workspaceUnsavedChangesStayOnCancel
	| caption |
	self testsIssue: #issue781 withTitle: 'Unsaved changes dialog is missing option to cancel'.
	workspace := (JadeWorkspace showOnSession: session) caption: 'Jade Workspace - Test Unsaved Changes'.
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #cancel.
	
	[workspace setDocumentData: 'stuff'.
	workspace codePane documentPresenter view isModified: true.
	caption := JadePresenter defaultCaptionText: workspace view.
	self deny: workspace promptToSaveChanges.	"cancel will return false and leave the workspace open"
	self assert: workspace codePane documentPresenter view isModified.
	self assert: TestMessageBox lastMessageBox caption equals: caption.
	self assert: TestMessageBox lastMessageBox text
		equals: JadePresenter defaultUnsavedChangesWithSaveText.
	TestMessageBox plannedResult: #no.
	self assert: workspace promptToSaveChanges.
	self deny: workspace codePane documentPresenter view isModified.
	self assert: TestMessageBox lastMessageBox caption equals: caption.
	self assert: TestMessageBox lastMessageBox text
		equals: JadePresenter defaultUnsavedChangesWithSaveText.
	TestFileSaveDialog enableJadeiteTestFileSaveDialog.
	TestFileSaveDialog plannedResult: #cancel.
	TestMessageBox plannedResult: #yes.
	workspace codePane documentPresenter view isModified: true.
	self deny: workspace promptToSaveChanges.
	self assertIsNil:  TestFileSaveDialog lastMessageBox model value. "maybe this means operation cancelled?" ]
			ensure: 
				[self destroy: workspace.
				TestFileSaveDialog disableJadeiteTestFileSaveDialog.
				TestMessageBox disableJadeiteTestMessageBox]! !
!JadeiteWorkspaceTestCase categoriesForMethods!
tearDown!private!support! !
test_workspaceAdHocDisplayUnicodeCharacters!public!test!test menus!test workspaces! !
test_workspaceBrowseProjects!public!test!test menus!test workspaces! !
test_workspaceConfirmInteraction!public!test!test menus!test workspaces! !
test_workspaceDoubleClickIncludesColon!public!test!test workspaces! !
test_workspaceImplementorsMenuNotTooLong!public!test workspaces! !
test_workspaceInformInteraction!public!test!test menus!test workspaces! !
test_workspaceJadeiteMenuAdHocExecutionItems!public!test!test menus!test workspaces! !
test_workspaceMessageImplementors!public!test browse!test workspaces! !
test_workspaceMessageImplementorsWithEndingQuote!public!test browse!test workspaces! !
test_workspaceMessageSenders!public!test browse!test workspaces! !
test_workspaceMessageSendersWithEndingQuote!public!test browse!test workspaces! !
test_workspacePlainStringImplementors!public!test browse!test workspaces! !
test_workspacePlainStringSenders!public!test browse!test workspaces! !
test_workspaceSendersMenuNotTooLong!public!test workspaces! !
test_workspaceStringWithQuotesImplementors!public!test browse!test workspaces! !
test_workspaceStringWithQuotesSenders!public!test browse!test workspaces! !
test_workspaceSymbolImplementors!public!test browse!test workspaces! !
test_workspaceSymbolSenders!public!test browse!test workspaces! !
test_workspaceSymbolSendersLeadingQuote!public!test browse!test workspaces! !
test_workspaceSymbolSendersRemoveSpaces!public!test browse!test workspaces! !
test_workspaceSymbolSendersTruncateLongSelectors!public!test browse!test workspaces! !
test_workspaceSymbolWithQuotesImplementors!public!test browse!test workspaces! !
test_workspaceSymbolWithQuotesSenders!public!test browse!test workspaces! !
test_workspaceUnsavedChanges!public!test!test workspaces! !
test_workspaceUnsavedChangesStayOnCancel!public!test!test workspaces! !
!

