"Filed out from Dolphin Smalltalk 7"!

JadeiteAbstractTestCase subclass: #JadeiteInspectorTestCase
	instanceVariableNames: 'inspector'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteInspectorTestCase guid: (GUID fromString: '{73901ab8-5805-4614-b9e4-7092e55c6317}')!
JadeiteInspectorTestCase comment: ''!
!JadeiteInspectorTestCase categoriesForClass!Unclassified! !
!JadeiteInspectorTestCase methodsFor!

commandQueryOn: commandSymbol
	^CommandQuery new commandDescription: (CommandDescription new command: commandSymbol)
		source: inspector view!

enableForward: forwardQuery andBack: backQuery
	"menu items are disabled based on the command query. Simulate a button enablement
	by creating a command query and evaluating the enablement after passing it through the
	enabler method"

	inspector queryCommand: backQuery.
	inspector queryCommand: forwardQuery!

inspectInstVarAt: index
	| instVarPresenter |
	instVarPresenter := inspector instVarListPresenter.
	instVarPresenter selection: (instVarPresenter list at: index).
	inspector inspectInstVar. !

tearDown
	inspector ifNotNil: [inspector destroy]!

test_abortTransactionInBasicInspector
	"foolishly or wisely, Dolphin runs different code paths
	depending on which view has focus. Test each"

	| remoteObject jadeiteMenu abortItem |
	self testsIssue: #issue383 withTitle: '(3.0.53) the commit button on the SUnit browser is silent'.
	remoteObject := session
				executeString: '123'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	transcript projectListPresenter refresh.
	self assertProjectInList: 'RowanSample1'.
	jadeiteMenu := self itemNamed: 'Jadeite' in: inspector view menuBar.
	abortItem := self itemNamed: 'Abort Transaction' in: jadeiteMenu.
	abortItem commandDescription performAgainst: inspector.
	
	[transcript projectListPresenter refresh.
	self denyProjectInList: 'RowanSample1'] ensure: 
				[self cloneRowanSample1.
				self ensureRowanSample1Loaded].
!

test_abortTransactionInNavigationInspector
	| remoteObject jadeiteMenu abortItem |
	self testsIssue: #issue383 withTitle: '(3.0.53) the commit button on the SUnit browser is silent'.
	remoteObject := session
				executeString: 'Array new'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	transcript projectListPresenter refresh.
	self assertProjectInList: 'RowanSample1'.
	jadeiteMenu := self itemNamed: 'Jadeite' in: inspector view menuBar.
	abortItem := self itemNamed: 'Abort Transaction' in: jadeiteMenu.
	abortItem commandDescription performAgainst: inspector.
	
	[transcript projectListPresenter refresh.
	self denyProjectInList: 'RowanSample1'] ensure: 
				[self cloneRowanSample1.
				self ensureRowanSample1Loaded].
	"focus in code pane"
	inspector documentPresenter setFocus.
	abortItem commandDescription performAgainst: inspector.
	
	[transcript projectListPresenter refresh.
	self denyProjectInList: 'RowanSample1'] ensure: 
				[self cloneRowanSample1.
				self ensureRowanSample1Loaded].
	"focus in list pane"
	inspector instVarListPresenter setFocus.
	abortItem commandDescription performAgainst: inspector.
	
	[transcript projectListPresenter refresh.
	self denyProjectInList: 'RowanSample1'] ensure: 
				[self cloneRowanSample1.
				self ensureRowanSample1Loaded]!

test_basicInspectorDisplayedSizeLimit
	| remoteObject |
	self testsIssue: #issue361 withTitle: 'Inspectors should hold more than 5000 characters'.
	remoteObject := session
				executeString: '
		| string |
		string := String new. 
		99999 timesRepeat:[
			string := string, ''a''. 
		].
		^string, ''X'''
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	self assert: inspector model last = $X.
	self assert: inspector model size = 100000
!

test_caption
	| remoteObject |
	remoteObject := session
				executeString: '123'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	self assert: ('Inspector on SmallInteger for*' match: inspector caption).!

test_captionChange
	| remoteObject instVarPresenter |
	self testsIssue: #issue154 withTitle: 'Change inspector title on dive #154'.
	remoteObject := session
				executeString: 'Array with: (Dictionary new at: #oc put: (OrderedCollection with: #leaf); yourself)'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	self assert: ('Inspector on Array for*' match: inspector caption).
	self inspectInstVarAt: 3.
	self assert: ('Inspector on Dictionary for*' match: inspector caption).
	self inspectInstVarAt: 3.
	self assert: ('Inspector on OrderedCollection for*' match: inspector caption).
	self inspectInstVarAt: 3.
	self assert: ('Inspector on Symbol for*' match: inspector caption).
	inspector getPreviousObject.
	self assert: ('Inspector on OrderedCollection for*' match: inspector caption).
	inspector getPreviousObject.
	self assert: ('Inspector on Dictionary for*' match: inspector caption).
	inspector getPreviousObject.
	self assert: ('Inspector on Array for*' match: inspector caption)!

test_commitTransactionInBasicInspector
	| remoteObject jadeiteMenu commitItem abortItem |
	self testsIssue: #issue383 withTitle: '(3.0.53) the commit button on the SUnit browser is silent'.
	self cloneRowanSample1.
	self ensureRowanSample1Loaded.
	transcript projectListPresenter refresh.
	self assertProjectInList: 'RowanSample1'.
	remoteObject := session
				executeString: '123'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	jadeiteMenu := self itemNamed: 'Jadeite' in: inspector view menuBar.
	commitItem := self itemNamed: 'Commit Transaction' in: jadeiteMenu.
	commitItem commandDescription performAgainst: inspector.
	transcript projectListPresenter refresh.
	self assertProjectInList: 'RowanSample1'.
	abortItem := self itemNamed: 'Abort Transaction' in: jadeiteMenu.
	abortItem commandDescription performAgainst: inspector.
	transcript projectListPresenter refresh.
	self assertProjectInList: 'RowanSample1'.
	self halt. 
	self unloadSampleProject.
	commitItem commandDescription performAgainst: inspector.
	transcript projectListPresenter refresh.
	self denyProjectInList: 'RowanSample1'.
	self cloneRowanSample1.
	self ensureRowanSample1Loaded!

test_commitTransactionInNavigationInspectorFocusCodePane
	| remoteObject jadeiteMenu commitItem abortItem |
	self testsIssue: #issue383 withTitle: '(3.0.53) the commit button on the SUnit browser is silent'.
	self cloneRowanSample1.
	self ensureRowanSample1Loaded.
	transcript projectListPresenter refresh.
	self assertProjectInList: 'RowanSample1'.
	remoteObject := session
				executeString: 'Array new'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	inspector documentPresenter setFocus. 
	jadeiteMenu := self itemNamed: 'Jadeite' in: inspector view menuBar.
	commitItem := self itemNamed: 'Commit Transaction' in: jadeiteMenu.
	commitItem commandDescription performAgainst: inspector.
	transcript projectListPresenter refresh.
	self assertProjectInList: 'RowanSample1'.
	abortItem := self itemNamed: 'Abort Transaction' in: jadeiteMenu.
	abortItem commandDescription performAgainst: inspector.
	transcript projectListPresenter refresh.
	self assertProjectInList: 'RowanSample1'.
	self unloadSampleProject.
	commitItem commandDescription performAgainst: inspector.
	transcript projectListPresenter refresh.
	self denyProjectInList: 'RowanSample1'.
	self cloneRowanSample1.
	self ensureRowanSample1Loaded!

test_commitTransactionInNavigationInspectorFocusInstVars
	| remoteObject jadeiteMenu commitItem abortItem |
	self testsIssue: #issue383 withTitle: '(3.0.53) the commit button on the SUnit browser is silent'.
	self cloneRowanSample1.
	self ensureRowanSample1Loaded.
	transcript projectListPresenter refresh.
	self assertProjectInList: 'RowanSample1'.
	remoteObject := session
				executeString: 'Array new'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	inspector instVarListPresenter setFocus. 
	jadeiteMenu := self itemNamed: 'Jadeite' in: inspector view menuBar.
	commitItem := self itemNamed: 'Commit Transaction' in: jadeiteMenu.
	commitItem commandDescription performAgainst: inspector.
	transcript projectListPresenter refresh.
	self assertProjectInList: 'RowanSample1'.
	abortItem := self itemNamed: 'Abort Transaction' in: jadeiteMenu.
	abortItem commandDescription performAgainst: inspector.
	transcript projectListPresenter refresh.
	self assertProjectInList: 'RowanSample1'.
	self unloadSampleProject.
	commitItem commandDescription performAgainst: inspector.
	transcript projectListPresenter refresh.
	self denyProjectInList: 'RowanSample1'.
	self cloneRowanSample1.
	self ensureRowanSample1Loaded!

test_forwardBack
	| remoteObject backQuery forwardQuery |
	self testsIssue: #issue153 withTitle: 'Inspector Back goes too far'.
	remoteObject := session
				executeString: 'Array with: (Dictionary new at: #oc put: (OrderedCollection with: #leaf); yourself)'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	backQuery := self commandQueryOn: #getPreviousObject.
	forwardQuery := self commandQueryOn: #getNextObject.
	self enableForward: forwardQuery andBack: backQuery.
	self deny: backQuery isEnabled.
	self deny: forwardQuery isEnabled.
	self inspectInstVarAt: 3.	"dictionary"
	self enableForward: forwardQuery andBack: backQuery.
	self assert: backQuery isEnabled.
	self deny: forwardQuery isEnabled.
	self inspectInstVarAt: 3.	"ordered collection"
	self enableForward: forwardQuery andBack: backQuery.
	self assert: backQuery isEnabled.
	self deny: forwardQuery isEnabled.
	self inspectInstVarAt: 3.	"symbol"
	self enableForward: forwardQuery andBack: backQuery.
	self assert: backQuery isEnabled.
	self deny: forwardQuery isEnabled.
	inspector getPreviousObject. "ordered collection"
	self enableForward: forwardQuery andBack: backQuery.
	self assert: backQuery isEnabled.
	self assert: forwardQuery isEnabled.
	inspector getPreviousObject. "dictionary"
	self enableForward: forwardQuery andBack: backQuery.
	self assert: backQuery isEnabled.
	self assert: forwardQuery isEnabled.
	inspector getPreviousObject. "array - root" 
	self enableForward: forwardQuery andBack: backQuery.
	self deny: backQuery isEnabled.
	self assert: forwardQuery isEnabled.
!

test_inspectString
	| remoteObject |
	remoteObject := session
				executeString: '''abc'''
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	self assert: (inspector isKindOf: JadeInspector).
	self assert: inspector model = 'abc' !

test_menuBarItemNames
	| remoteObject |
	self testsIssue: #issue194 withTitle: 'Oscar-3.0.40: Wodkspace window still uses `Jade` labels'.
	remoteObject := session
				executeString: '123'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	
	[self assert: inspector view menuBar items size equals: 3.
	self assert: (inspector view menuBar items at: 1) text equals: '&File'.
	(inspector view menuBar items at: 1) items last text equals: 'E&xit Jadeite	Alt+F4'.
	self assert: (inspector view menuBar items at: 2) text equals: '&Edit'.
	self assert: (inspector view menuBar items at: 3) text equals: '&Jadeite']
			ensure: [inspector view close].
	remoteObject := session
				executeString: 'Array new'
				fromContext: nil
				environment: 0.	"navigation inspector"
	inspector := JadeInspector showOn: remoteObject session: session.
	self assert: inspector view menuBar items size equals: 3.
	self assert: (inspector view menuBar items at: 1) text equals: '&File'.
	(inspector view menuBar items at: 1) items last text equals: 'E&xit Jadeite	Alt+F4'.
	self assert: (inspector view menuBar items at: 2) text equals: '&Edit'.
	self assert: (inspector view menuBar items at: 3) text equals: '&Jadeite'!

test_menuItemsEnabled
	| remoteObject |
	self testsIssue: #issue212 withTitle: '`Copy` menu item grayed out in inspector when text selected'.
	remoteObject := session
				executeString: 'Array new'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	inspector documentPresenter view contextMenu itemsDo: 
			[:item |
			| query |
			query := CommandQuery commandDescription: item source: inspector view.
			self deny: query isEnabled].
	inspector documentPresenter setFocus.
	inspector documentPresenter view contextMenu itemsDo: 
			[:item |
			| query |
			query := CommandQuery commandDescription: item commandDescription
						source: inspector documentPresenter view.
			query commandSymbol
				ifNotNil: 
					[inspector queryCommand: query.
					(#(#undo #redo #browseImplementors #browseSenders) includes: query commandSymbol)
						ifFalse: 
							["*do doesn't require a selection for enablement"
							self assert: query isEnabled]]]!

test_navigationInspectorDisplayedSizeLimit
	"CharacterCollection>>printStringWithMaxSize: truncates at 100,000 characters
	including quotes. Hence, we allow for that in the building of the string. "

	| remoteObject instVarPresenter |
	self testsIssue: #issue361 withTitle: 'Inspectors should hold more than 5000 characters'.
	remoteObject := session
				executeString: '
		| string |
		string := String new. 
		99997 timesRepeat:[
			string := string, ''a''. 
		].
		^Array with: string, ''X'''
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	instVarPresenter := inspector instVarListPresenter.
	instVarPresenter selection: (instVarPresenter list at: 3).
	self assert: (inspector documentPresenter value last: 2) equals: 'X'''.
	self assert: inspector documentPresenter value size = 100000!

test_openDictionaryBrowser
	| remoteObject shell |
	remoteObject := session
				executeString: 'OrderedCollection with: 1 with: ''abc'' with: $3'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	shell := inspector browseClass.
	[self assert: (shell isKindOf: RowanSystemBrowser)] ensure: [shell destroy]!

test_openDictionaryBrowserOnClass
	| remoteObject shell |
	remoteObject := session
				executeString: 'OrderedCollection'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	shell := inspector browseClass.
	[self assert: (shell isKindOf: RowanSystemBrowser)] ensure: [shell destroy]!

test_openProjectsBrowser
	| remoteObject shell |
	remoteObject := session
				executeString: 'RowanClassService new'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	shell := inspector browseClass.
	[self assert: (shell isKindOf: JadeiteProjectsSystemBrowser)] ensure: [shell destroy]!

test_openProjectsBrowserOnClass
	| remoteObject shell |
	remoteObject := session
				executeString: 'RowanClassService'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	shell := inspector browseClass.
	[self assert: (shell isKindOf: JadeiteProjectsSystemBrowser)] ensure: [shell destroy]!

test_registeredPresentersInInspectorCleanedUp
	"we don't register any yet, but this test will fail if we add any. 
	That will remind us to make sure they're cleaned up"

	| registeredPresenters remoteObject |
	registeredPresenters := BrowserUpdate current registeredPresenters size.
	remoteObject := session
				executeString: 'Array new'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	self assert: BrowserUpdate current registeredPresenters size equals: registeredPresenters.
	inspector destroy.
	inspector := nil.
	self assert: BrowserUpdate current registeredPresenters size equals: registeredPresenters!

unloadSampleProject
	transcript projectListPresenter basicUnloadProjects: (Array with: self sampleProjectName)! !
!JadeiteInspectorTestCase categoriesFor: #commandQueryOn:!private! !
!JadeiteInspectorTestCase categoriesFor: #enableForward:andBack:!private! !
!JadeiteInspectorTestCase categoriesFor: #inspectInstVarAt:!private! !
!JadeiteInspectorTestCase categoriesFor: #tearDown!private! !
!JadeiteInspectorTestCase categoriesFor: #test_abortTransactionInBasicInspector!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_abortTransactionInNavigationInspector!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_basicInspectorDisplayedSizeLimit!public!test! !
!JadeiteInspectorTestCase categoriesFor: #test_caption!public!test! !
!JadeiteInspectorTestCase categoriesFor: #test_captionChange!public!test! !
!JadeiteInspectorTestCase categoriesFor: #test_commitTransactionInBasicInspector!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_commitTransactionInNavigationInspectorFocusCodePane!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_commitTransactionInNavigationInspectorFocusInstVars!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_forwardBack!public!test! !
!JadeiteInspectorTestCase categoriesFor: #test_inspectString!public!test! !
!JadeiteInspectorTestCase categoriesFor: #test_menuBarItemNames!public!test! !
!JadeiteInspectorTestCase categoriesFor: #test_menuItemsEnabled!public!test! !
!JadeiteInspectorTestCase categoriesFor: #test_navigationInspectorDisplayedSizeLimit!public!test! !
!JadeiteInspectorTestCase categoriesFor: #test_openDictionaryBrowser!public!test! !
!JadeiteInspectorTestCase categoriesFor: #test_openDictionaryBrowserOnClass!public!test! !
!JadeiteInspectorTestCase categoriesFor: #test_openProjectsBrowser!public!test! !
!JadeiteInspectorTestCase categoriesFor: #test_openProjectsBrowserOnClass!public!test! !
!JadeiteInspectorTestCase categoriesFor: #test_registeredPresentersInInspectorCleanedUp!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #unloadSampleProject!private!support! !

