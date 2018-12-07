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

test_transcriptNamedConsole
	self testsIssue: #issue161 withTitle: 'Rename transcrip to console'.
	self assert: ('Console*' match: transcript view caption)! !
!JadeiteTranscriptTestCase categoriesFor: #test_browseClassMenuItem!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_browseFindClassMenuItem!public!test menus! !
!JadeiteTranscriptTestCase categoriesFor: #test_browseImplementors!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_browseImplementorsMenuItem!public!test menus! !
!JadeiteTranscriptTestCase categoriesFor: #test_browseLiteralsReferencesMenuItem!public!test menus! !
!JadeiteTranscriptTestCase categoriesFor: #test_browseMethodsContainingMenuItem!public!test menus! !
!JadeiteTranscriptTestCase categoriesFor: #test_browseProjectsMenuItem!public!test menus! !
!JadeiteTranscriptTestCase categoriesFor: #test_browseSenders!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_browseSendersMenuItem!public!test menus! !
!JadeiteTranscriptTestCase categoriesFor: #test_menuNames!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_multiSelectProject!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_transcriptNamedConsole!public!tests! !

