"Filed out from Dolphin Smalltalk 7"!

JadeiteAbstractTestCase subclass: #JadeiteTranscriptTestCase
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteTranscriptTestCase guid: (GUID fromString: '{5527e061-53db-41d8-b3ef-bea5af13e6aa}')!
JadeiteTranscriptTestCase comment: ''!
!JadeiteTranscriptTestCase categoriesForClass!Unclassified! !
!JadeiteTranscriptTestCase methodsFor!

test_abortRemovesProjectsInAllBrowsers
	| sunitBrowser |
	projectsBrowser := self openWindow: [transcript openJadeiteProjectsBrowser].
	sunitBrowser := self openWindow: [transcript jadeBrowseTests].
	
	[self denyIsNil: (self projectListPresenter list
				detect: [:projectService | projectService name = 'RowanSample1']
				ifNone: []).
	self denyIsNil: (transcript projectListPresenter projectListPresenter list
				detect: [:projectService1 | projectService1 name = 'RowanSample1']
				ifNone: []).
	self denyIsNil: (sunitBrowser primaryPresenter packageListPresenter list
				detect: [:projectService1 | projectService1 name = 'RowanSample1-Tests']
				ifNone: []).
	transcript toolbarPresenter abort.
	self assertIsNil: (self projectListPresenter list
				detect: [:projectService | projectService name = 'RowanSample1']
				ifNone: []).
	self assertIsNil: (transcript projectListPresenter projectListPresenter list
				detect: [:projectService2 | projectService2 name = 'RowanSample1']
				ifNone: []).
	self assertIsNil: (sunitBrowser primaryPresenter packageListPresenter list
				detect: [:projectService1 | projectService1 name = 'RowanSample1-Tests']
				ifNone: []).
	self cloneRowanSample1.
	self ensureRowanSample1Loaded]
			ensure: 
				[projectsBrowser destroy.
				sunitBrowser destroy]!

test_abortTransaction
	self testsIssue: #issue383 withTitle: '(3.0.53) the commit button on the SUnit browser is silent'.
	transcript projectListPresenter refresh.
	self assertProjectInList: 'RowanSample1'.
	transcript toolbarPresenter abort.
	self denyProjectInList: 'RowanSample1'.
	self cloneRowanSample1.
	self ensureRowanSample1Loaded!

test_autoCommitOff
	| answeringService |
	self testsIssue: #issue396 withTitle: 'Ability to turn on autocommit would be nice'.
	transcript autoCommit: false.
	session executeString: 'UserGlobals at: #TestCommit put: true'.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self abortTransaction.
	self assertIsNil: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	"any service call will commit the transaction"
	session executeString: 'UserGlobals at: #TestCommit put: true'.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	answeringService := RowanAnsweringService new.
	answeringService
		command: #exec:;
		commandArgs: (Array with: '3+4').
	self issueCommand: answeringService.
	self assert: answeringService answer equals: '7'.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self abortTransaction.
	
	[self assertIsNil: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]')	"autoCommit off. TestCommit was not committed"]
			ensure: 
				[self cloneRowanSample1.
				self ensureRowanSample1Loaded]!

test_autoCommitOn
	| answeringService |
	self testsIssue: #issue396 withTitle: 'Ability to turn on autocommit would be nice'.
	[transcript autoCommit: true.
	session executeString: 'UserGlobals at: #TestCommit put: true'.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self abortTransaction.
	self assertIsNil: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	"any service call will commit the transaction"
	session executeString: 'UserGlobals at: #TestCommit put: true'.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	answeringService := RowanAnsweringService new.
	answeringService
		command: #exec:;
		commandArgs: (Array with: '3+4').
	self issueCommand: answeringService.
	self assert: answeringService answer equals: '7'.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self abortTransaction.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]')	"TestCommit was committed"]
			ensure: 
				[session executeString: 'UserGlobals removeKey: #TestCommit'.
				self commitTransaction.
				transcript autoCommit: false]!

test_autoCommitSet
	self testsIssue: #issue396 withTitle: 'Ability to turn on autocommit would be nice'.
	transcript autoCommit: false.
	self assert: (session executeString: 'SessionTemps current at: #''Jadeite_AutoCommit''')
		equals: false.
	transcript autoCommit: true.
	
	[self assert: (session executeString: 'SessionTemps current at: #''Jadeite_AutoCommit''')
		equals: true]
			ensure: [transcript autoCommit: false]!

test_browseClassMenuItem
	| browseMenu browseClassItem |
	self testsIssue: #issue235 withTitle: 'Need Find Class/Method from console'.
	browseMenu := transcript view menuBar items detect: [:menu | '*Browse*' match: menu text] ifNone: [].
	self denyIsNil: browseMenu.
	browseClassItem := browseMenu items detect: [:command | '*Find*Class*' match: command text]
				ifNone: [].
	self denyIsNil: browseClassItem.
	self assert: browseClassItem command equals: #browseClass.
	self assert: (transcript class canUnderstand: #browseClass)!

test_browseFindClassMenuItem
	| browseMenu findClassMenuItem |
	self testsIssue: #issue235 withTitle: 'Need Find Class/Method from console'.
	browseMenu := transcript view menuBar items detect: [:menu | '*Browse*' match: menu text] ifNone: [].
	self denyIsNil: browseMenu.
	findClassMenuItem := browseMenu items detect: [:command | '*Find*Class*' match: command text]
				ifNone: [].
	self denyIsNil: findClassMenuItem.
	self assert: findClassMenuItem command equals: #browseClass.
	self assert: (transcript class canUnderstand: #browseClass)!

test_browseImplementors
	| methodListBrowser methodList |
	self testsIssue: #issue235 withTitle: 'Need Find Class/Method from console'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[TestPrompter plannedResult: 'size'.
	methodListBrowser := transcript browseImplementorsOf.
	methodList := methodListBrowser primaryPresenter methodListPresenter methodListPresenter list.
	self assert: methodList notEmpty.
	self assert: ('Implementors of ''size'' for*' match: methodListBrowser caption).]
			ensure: 
				[TestMessageBox disableJadeiteTestMessageBox.
				methodListBrowser destroy]!

test_browseImplementorsMenuItem
	| browseMenu browseImplementorsItem |
	self testsIssue: #issue251 withTitle: '`Browse Methods Containing` available from Console menu'.
	browseMenu := transcript view menuBar items detect: [:menu | '*Browse*' match: menu text] ifNone: [].
	self denyIsNil: browseMenu.
	browseImplementorsItem := browseMenu items
				detect: [:command | '*Browse*Implementors*' match: command text]
				ifNone: [].
	self denyIsNil: browseImplementorsItem.
	self assert: browseImplementorsItem command equals: #browseImplementorsOf.
	self assert: (transcript class canUnderstand: #browseMethodsContaining)!

test_browseLiteralsReferencesMenuItem
	| browseMenu browseLiteralReferencesItem |
	self testsIssue: #issue251 withTitle: '`Browse Methods Containing` available from Console menu'.
	browseMenu := transcript view menuBar items detect: [:menu | '*Browse*' match: menu text] ifNone: [].
	self denyIsNil: browseMenu.
	browseLiteralReferencesItem := browseMenu items
				detect: [:command | '*Browse*Literal*References*' match: command text]
				ifNone: [].
	self denyIsNil: browseLiteralReferencesItem.
	self assert: browseLiteralReferencesItem command equals: #browseLiteralReferences.
	self assert: (transcript class canUnderstand: #browseLiteralReferences)!

test_browseMethodsContainingMenuItem
	| browseMenu browseMethodsContainingItem |
	self testsIssue: #issue251 withTitle: '`Browse Methods Containing` available from Console menu'.
	browseMenu := transcript view menuBar items detect: [:menu | '*Browse*' match: menu text] ifNone: [].
	self denyIsNil: browseMenu.
	browseMethodsContainingItem := browseMenu items
				detect: [:command | '*Browse*Methods*Containing*' match: command text]
				ifNone: [].
	self denyIsNil: browseMethodsContainingItem.
	self assert: browseMethodsContainingItem command equals: #browseMethodsContaining.
	self assert: (transcript class canUnderstand: #browseMethodsContaining)!

test_browseProjectsMenuItem
	| browseMenu browseProjectsMenuItem |
	self testsIssue: #issue235 withTitle: 'Need Find Class/Method from console'.
	browseMenu := transcript view menuBar items detect: [:menu | '*Browse*' match: menu text] ifNone: [].
	self denyIsNil: browseMenu.
	browseProjectsMenuItem := browseMenu items
				detect: [:command | '*Browse*Projects*' match: command text]
				ifNone: [].
	self denyIsNil: browseProjectsMenuItem.
	self assert: browseProjectsMenuItem command equals: #openJadeiteProjectsBrowser.
	self assert: (transcript class canUnderstand: #openJadeiteProjectsBrowser)!

test_browseSenders
	| methodListBrowser methodList |
	self testsIssue: #issue235 withTitle: 'Need Find Class/Method from console'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[TestPrompter plannedResult: 'abort'.
	methodListBrowser := transcript browseSendersOf.
	methodList := methodListBrowser primaryPresenter methodListPresenter methodListPresenter list.
	self assert: methodList notEmpty.
	self assert: ('Senders of ''abort'' for*' match: methodListBrowser caption).]
			ensure: 
				[TestMessageBox disableJadeiteTestMessageBox.
				methodListBrowser destroy]!

test_browseSendersMenuItem
	| browseMenu browseSendersItem |
	self testsIssue: #issue235 withTitle: 'Need Find Class/Method from console'.
	browseMenu := transcript view menuBar items detect: [:menu | '*Browse*' match: menu text] ifNone: [].
	self denyIsNil: browseMenu.
	browseSendersItem := browseMenu items detect: [:command | '*Browse*Senders*' match: command text]
				ifNone: [].
	self denyIsNil: browseSendersItem.
	self assert: browseSendersItem command equals: #browseSendersOf.
	self assert: (transcript class canUnderstand: #browseSendersOf)!

test_commitTransaction
	self testsIssue: #issue383 withTitle: '(3.0.53) the commit button on the SUnit browser is silent'.
	self cloneRowanSample1.
	self ensureRowanSample1Loaded.
	transcript projectListPresenter refresh.
	self assertProjectInList: 'RowanSample1'.
	transcript toolbarPresenter commit.
	self assertProjectInList: 'RowanSample1'.
	transcript toolbarPresenter abort.
	self assertProjectInList: 'RowanSample1'.
	self unloadSampleProject.
	transcript toolbarPresenter commit. 
	self denyProjectInList: 'RowanSample1'.
	self cloneRowanSample1.
	self ensureRowanSample1Loaded.!

test_menuNames
	| commitMenuItem checkoutMenuItem contextMenu |
	self testsIssue: #issue342 withTitle: 'Console menu items not matching projects browser'.
	contextMenu := transcript projectListPresenter projectListPresenter view queryContextMenu.
	commitMenuItem := contextMenu items detect: [:menu | 'Commit to Git ...' = menu text] ifNone: [].
	self denyIsNil: commitMenuItem.
	self assert: commitMenuItem command equals: #commit.
	self assert: (transcript projectListPresenter class canUnderstand: #commit).
	checkoutMenuItem := contextMenu items detect: [:menu | 'Checkout Git Branch ...' = menu text]
				ifNone: [].
	self denyIsNil: checkoutMenuItem.
	self assert: checkoutMenuItem command equals: #checkout.
	self assert: (transcript projectListPresenter class canUnderstand: #checkout)!

test_multiSelectProject
	| projectServices projectCount |
	self testsIssue: #issue163
		withTitle: 'Project list in transcript/console should be multi-select for multi-load'.
	projectServices := transcript projectListPresenter projectListPresenter list.
	projectCount := projectServices size.
	transcript projectListPresenter projectListPresenter selections: projectServices.
	self assert: transcript projectListPresenter projectListPresenter selections size equals: projectCount!

test_openChangesBrowser
	| changesBrowser changesItem  projectService |
	self testsIssue: #issue384
		withTitle: '(3.0.53) sort by `type` in changes view does not do complete job'.
	projectService := transcript projectListPresenter projectListPresenter list first.
	transcript projectListPresenter projectListPresenter selection: projectService.
	changesItem := transcript projectListPresenter projectListPresenter view queryContextMenu items
				detect: [:menuItem | menuItem command == #projectChanges]. 
	changesBrowser := changesItem commandDescription performAgainst:  transcript projectListPresenter.
	[self assert: (changesBrowser isKindOf: RowanPatchBrowser)] ensure: [changesBrowser destroy]!

test_transcriptNamedConsole
	| clearTranscriptMenuItem wasInstalled |
	(wasInstalled := transcript isTranscriptInstalled) ifFalse: [transcript flipTranscript].
	
	[clearTranscriptMenuItem := transcript transcriptPresenter documentPresenter view queryContextMenu
				items detect: [:menuItem | menuItem command == #clearTranscript].
	clearTranscriptMenuItem commandDescription performAgainst: transcript transcriptPresenter.
	self assert: transcript transcriptPresenter documentPresenter value isEmpty.
	self assert: transcript transcriptPresenter documentPresenter view displayValue isEmpty.
	session executeString: 'Transcript show: ''wroteOnTranscript'''.
	self assert: transcript transcriptPresenter documentPresenter value equals: '''wroteOnTranscript'''.
	clearTranscriptMenuItem commandDescription performAgainst: transcript transcriptPresenter.
	self assert: transcript transcriptPresenter documentPresenter value isEmpty.
	self assert: transcript transcriptPresenter documentPresenter view displayValue isEmpty]
			ensure: [wasInstalled ifFalse: [transcript flipTranscript	"turn back off"]]! !
!JadeiteTranscriptTestCase categoriesFor: #test_abortRemovesProjectsInAllBrowsers!public!test menus! !
!JadeiteTranscriptTestCase categoriesFor: #test_abortTransaction!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_autoCommitOff!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_autoCommitOn!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_autoCommitSet!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_browseClassMenuItem!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_browseFindClassMenuItem!public!test menus! !
!JadeiteTranscriptTestCase categoriesFor: #test_browseImplementors!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_browseImplementorsMenuItem!public!test menus! !
!JadeiteTranscriptTestCase categoriesFor: #test_browseLiteralsReferencesMenuItem!public!test menus! !
!JadeiteTranscriptTestCase categoriesFor: #test_browseMethodsContainingMenuItem!public!test menus! !
!JadeiteTranscriptTestCase categoriesFor: #test_browseProjectsMenuItem!public!test menus! !
!JadeiteTranscriptTestCase categoriesFor: #test_browseSenders!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_browseSendersMenuItem!public!test menus! !
!JadeiteTranscriptTestCase categoriesFor: #test_commitTransaction!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_menuNames!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_multiSelectProject!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_openChangesBrowser!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_transcriptNamedConsole!public!tests! !

