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
	super tearDown.
	inspector ifNotNil: [self destroy: inspector view].!

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

test_adHocInspect
	| workspace |
	self testsIssue: #issue427 withTitle: '(3.0.60) autocommit not done after successful doits'.
	workspace := JadeWorkspace showOnSession: session.
	
	[self assert: (workspace isKindOf: JadeWorkspace).
	workspace setDocumentData: '123'.
	workspace setFocus.
	inspector := workspace codePane jadeInspect.
	self assert: inspector documentPresenter model value equals: '123'.
	self assert: inspector instVarListPresenter selection key equals: 'self']
			ensure: 
				[workspace isModified: false.
				workspace view close]!

test_adHocInspectComplexObject
	| workspace |
	self testsIssue: #issue464 withTitle: '(3.0.67) String does not understand #format: ... during doit'.
	workspace := JadeWorkspace showOnSession: session.
	
	[self assert: (workspace isKindOf: JadeWorkspace).
	workspace setDocumentData: 'RowanSample1Test new setTestSelector: #test1'.
	workspace setFocus.
	inspector := workspace codePane jadeInspect.
	self assert: inspector documentPresenter model value equals: 'RowanSample1Test>>#test1'.
	self assert: inspector instVarListPresenter selection key equals: 'self']
			ensure: 
				[workspace isModified: false.
				workspace view close]!

test_autoCommitInAdHocInspect
	| workspace |
	self testsIssue: #issue427 withTitle: '(3.0.60) autocommit not done after successful doits'.
	workspace := JadeWorkspace showOnSession: session.
	
	[self setAutoCommit: true.
	session executeString: 'UserGlobals at: #TestCommit put: true'.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	workspace setDocumentData: '123'.
	workspace setFocus.
	inspector := workspace codePane jadeInspect.
	self assert: inspector documentPresenter model value equals: '123'.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]')]
			ensure: 
				[inspector topShell primaryPresenter view close.
				workspace isModified: false.
				workspace view close.
				self setAutoCommit: false	"should have committed already"].
	
	[self abortTransaction.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]')]
			ensure: 
				[session executeString: 'UserGlobals removeKey: #TestCommit'.
				self commitTransaction]!

test_autoCommitOffInAdHocInspect
	| workspace |
	self testsIssue: #issue427 withTitle: '(3.0.60) autocommit not done after successful doits'.
	workspace := JadeWorkspace showOnSession: session.
	
	[self setAutoCommit: false.
	session executeString: 'UserGlobals at: #TestCommit put: true'.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	workspace setDocumentData: '123'.
	workspace setFocus.
	inspector := workspace codePane jadeInspect.
	self assert: inspector documentPresenter model value equals: '123'.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]')]
			ensure: 
				[inspector topShell primaryPresenter view close.
				workspace isModified: false.
				workspace view close].
	
	[self abortTransaction.
	self assertIsNil: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]')]
			ensure: [self commitTransaction]!

test_basicInspectorDisplayedSizeLimit
	| remoteObject inspectorService |
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
	inspectorService := inspector model.
	self assert: inspectorService indexedSize equals: 100000.
	self assert: inspectorService visibleIndices equals: 1000.
	inspector displayAll.
	self assert: inspector instVarListPresenter list last key equals: '100000'. 
	self assert: inspector instVarListPresenter list last value equals:( session
				executeString: '$X asOop'). 
	self assert: inspector instVarListPresenter list last key equals: '100000'. 
	self assert: inspectorService indexedSize equals: 100000!

test_caption
	| remoteObject |
	remoteObject := session
				executeString: '123'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	self assert: ('Inspector on SmallInteger for*' match: inspector caption).!

test_captionChange
	| remoteObject |
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
	self assertProjectInList: 'RowanSample1'.
	remoteObject := session
				executeString: '123'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	jadeiteMenu := self itemNamed: 'Jadeite' in: inspector view menuBar.
	commitItem := self itemNamed: 'Commit Transaction' in: jadeiteMenu.
	commitItem commandDescription performAgainst: inspector.
	self assertProjectInList: 'RowanSample1'.
	abortItem := self itemNamed: 'Abort Transaction' in: jadeiteMenu.
	abortItem commandDescription performAgainst: inspector.
	self assertProjectInList: 'RowanSample1'.
	self unloadSampleProject.
	commitItem commandDescription performAgainst: inspector.
	self denyProjectInList: 'RowanSample1'.
	self cloneRowanSample1.
	self ensureRowanSample1Loaded!

test_commitTransactionInNavigationInspectorFocusCodePane
	| remoteObject jadeiteMenu commitItem abortItem |
	self testsIssue: #issue383 withTitle: '(3.0.53) the commit button on the SUnit browser is silent'.
	self cloneRowanSample1.
	self ensureRowanSample1Loaded.
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
	self assertProjectInList: 'RowanSample1'.
	abortItem := self itemNamed: 'Abort Transaction' in: jadeiteMenu.
	abortItem commandDescription performAgainst: inspector.
	self assertProjectInList: 'RowanSample1'.
	self unloadSampleProject.
	commitItem commandDescription performAgainst: inspector.
	self denyProjectInList: 'RowanSample1'.
	self cloneRowanSample1.
	self ensureRowanSample1Loaded!

test_commitTransactionInNavigationInspectorFocusInstVars
	| remoteObject jadeiteMenu commitItem abortItem |
	self testsIssue: #issue383 withTitle: '(3.0.53) the commit button on the SUnit browser is silent'.
	self cloneRowanSample1.
	self ensureRowanSample1Loaded.
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
	self assertProjectInList: 'RowanSample1'.
	abortItem := self itemNamed: 'Abort Transaction' in: jadeiteMenu.
	abortItem commandDescription performAgainst: inspector.
	self assertProjectInList: 'RowanSample1'.
	self unloadSampleProject.
	commitItem commandDescription performAgainst: inspector.
	self denyProjectInList: 'RowanSample1'.
	self cloneRowanSample1.
	self ensureRowanSample1Loaded!

test_displayAll
	| remoteObject |
	self testsIssue: #issue668 withTitle: 'More efficient handling of large collections. #668'.
	remoteObject := session
				executeString: '| coll oop inspectorService |
coll := Array new.
1 to: 20000 do: [:i |
coll add: ''entry'', i asString].
oop := coll asOop.
coll
 '
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	self assert: inspector statusText equals: 'Displaying 1000 of 20000 indexed inst vars'.
	self assert: inspector instVarListPresenter list size equals: 1002.
	inspector displayAll.
	self assert: inspector statusText equals: 'Displaying 20000 of 20000 indexed inst vars'.
	self assert: inspector instVarListPresenter list size equals: 20002!

test_displayMore
	| remoteObject |
	self testsIssue: #issue668 withTitle: 'More efficient handling of large collections. #668'.
	remoteObject := session
				executeString: '| coll oop inspectorService |
coll := Array new.
1 to: 20000 do: [:i |
coll add: ''entry'', i asString].
oop := coll asOop.
coll
 '
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	1 to: 20
		do: 
			[:index |
			| thousand |
			thousand := index * 1000.
			self assert: inspector statusText
				equals: 'Displaying ' , thousand printString , ' of 20000 indexed inst vars'.
			self assert: inspector instVarListPresenter list size equals: thousand + 2.
			inspector displayMore].
	self assert: inspector statusText equals: 'Displaying 20000 of 20000 indexed inst vars'.
	self assert: inspector instVarListPresenter list size equals: 20002!

test_displayMoreBigCollection
	| remoteObject |
	self testsIssue: #issue668 withTitle: 'More efficient handling of large collections. #668'.
	remoteObject := session
				executeString: '| coll oop inspectorService |
coll := Array new.
1 to: 200000 do: [:i |
coll add: ''entry'', i asString].
oop := coll asOop.
coll
 '
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	1 to: 200
		do: 
			[:index |
			| thousand |
			thousand := index * 1000.
			self assert: inspector statusText
				equals: 'Displaying ' , thousand printString , ' of 200000 indexed inst vars'.
			self assert: inspector instVarListPresenter list size equals: thousand + 2.
			inspector displayMore].
	self assert: inspector statusText equals: 'Displaying 200000 of 200000 indexed inst vars'.
	self assert: inspector instVarListPresenter list size equals: 200002!

test_dive
	| workspace index |
	workspace := JadeWorkspace showOnSession: session.
	
	[workspace setDocumentData: 'ClassOrganizer new'.
	workspace setFocus.
	inspector := workspace codePane jadeInspect.
	self assert: (inspector model isKindOf: RowanInspectorService).
	self assert: inspector instVarListPresenter selection key equals: 'self'.
	self assert: inspector instVarListPresenter selection value equals: 'aClassOrganizer'.
	inspector instVarListPresenter selectionByIndex: 8.
	self assert: inspector instVarListPresenter selection key equals: '-rootClass'.
	inspector instVarListPresenter view onActionPerformed.	"event for double click"
	self assert: inspector instVarListPresenter selection key equals: 'self'.
	self assert: inspector documentPresenter value equals: 'Object'.
	index := (inspector instVarListPresenter list collect: [:assoc | assoc key]) indexOf: '-name'.
	inspector instVarListPresenter selectionByIndex: index.
	self assert: inspector documentPresenter value equals: '#''Object''']
			ensure: 
				[workspace isModified: false.
				workspace view close]!

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

test_fullInspectArray
	| remoteObject list |
	self testsIssue: #issue657
		withTitle: 'Cannot inspect all of an array with more than 200 items (3.0.91)'.
	remoteObject := session
				executeString: '| coll |
coll := Array new.
1 to: 500 do: [:i |
	coll add: ''entry'', i asString].
coll
'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	list := inspector instVarListPresenter list.
	self assert: list size equals: 502.	"500 elements + self + asOop"
	3 to: list size
		do: 
			[:index |
			inspector instVarListPresenter selectionByIndex: index.
			self
				assert: (inspector documentPresenter model value equals: '''entry' , (index - 2) printString , '''')]!

test_inspectorHandlesError
	| remoteObject |
	self testsIssue: #issue433 withTitle: 'Walkback on new inspector in presence of #size method'.
	remoteObject := session
				executeString: 'RowanSample1 new'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	[self assert: ('Inspector on RowanSample1*' match: inspector caption)]
		ensure: [self destroy: inspector].
	self
		saveMethod: 'printString    self error: ''throw an error'''
		in: 'RowanSample1'
		category: 'printing'.
	remoteObject := session
				executeString: 'RowanSample1 new'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	
	[self
		assert: ('Error printing object with oop *. Error text: a UserDefinedError occurred (error 2318), reason:halt, throw an error'
				match: inspector documentPresenter value).	"must show underlying error"
	inspector instVarListPresenter selectionByIndex: 2.
	self assert: inspector documentPresenter value isKindOf: Integer]
			ensure: [self destroy: inspector].
	remoteObject := session
				executeString: 'Array with: RowanSample1 new'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	
	[self assert: ('Inspector on Array*' match: inspector caption).
	inspector instVarListPresenter selectionByIndex: 3.
	self assert: ('Error inspecting object*' match: inspector documentPresenter value).	"should show the oop"
	self assert: ('*throw an error*' match: inspector documentPresenter value)	"must show underlying error"]
			ensure: [self destroy: inspector]!

test_inspectorRootObjectRegistered
	| remoteObject inspectorHandle |
	self testsIssue: #issue385 withTitle: 'Inspector should keep associated root object alive'.
	remoteObject := session executeString: 'Object new'.
	inspector := JadeInspector showOn: remoteObject session: session.
	inspectorHandle := inspector view handle value.
	self assert: (session
				executeString: '(RowanBrowserService new openWindows at: ' , inspectorHandle printString
						, ' ifAbsent:[]) asOop')
		equals: remoteObject value.
	inspector view close.
	self assertIsNil: (session
				executeString: 'RowanBrowserService new openWindows at: ' , inspectorHandle printString
						, ' ifAbsent:[]')!

test_inspectorRootSpecialObjectNotRegistered
	| remoteObject inspectorHandle |
	self testsIssue: #issue385 withTitle: 'Inspector should keep associated root object alive'.
	remoteObject := session executeString: '$a'.
	inspector := JadeInspector showOn: remoteObject session: session.
	inspectorHandle := inspector view handle value.
	self assert: (session
				executeString: 'RowanBrowserService new openWindows at: ' , inspectorHandle printString
						, ' ifAbsent:[]')
		equals: $a!

test_inspectString
	| remoteObject |
	remoteObject := session
				executeString: '''abc'''
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	self assert: (inspector isKindOf: JadeInspector).
	self
		assert: (session executeString: 'Object _objectForOop: ' , inspector model oop printString) = 'abc'!

test_interactionInspect
	"user can send #inspect to any object in server code and Jadeite should 
	open an inspector properly."

	| answeringService |
	self testsIssue: #issue303 withTitle: 'Need to handle confirm:'.
	self closeExistingInspectors.
	self assert: JadeiteInspector allInstances size equals: 0.
	answeringService := RowanAnsweringService new.
	answeringService
		command: #exec:;
		commandArgs: (Array with: 'UserGlobals inspect. nil').
	self issueCommand: answeringService.
	inspector := JadeiteInspector allInstances first.
	self assert: JadeiteInspector allInstances size equals: 1.
	self assert: ('Inspector on SymbolDictionary for*' match: inspector caption)!

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
	[self assert: (shell isKindOf: JadeiteBrowser)] ensure: [self destroy: shell]!

test_openDictionaryBrowserOnClass
	| remoteObject shell |
	remoteObject := session
				executeString: 'OrderedCollection'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	shell := inspector browseClass.
	[self assert: (shell isKindOf: JadeiteBrowser)] ensure: [self destroy: shell]!

test_openNavigationInspectorOnBoolean
	| remoteObject |
	self testsIssue: #issue398 withTitle: 'String Inspectors don''t display lfs'.
	remoteObject := session
				executeString: 'true'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	
	[self assert: (inspector isKindOf: JadeiteInspector).
	self assert: inspector documentPresenter model value equals: 'true'.
	inspector instVarListPresenter selectionByIndex: 2.	"asOop"
	self assert: inspector documentPresenter model value equals: 268]
			ensure: [self destroy: inspector].
	remoteObject := session
				executeString: 'false'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	self assert: (inspector isKindOf: JadeiteInspector).
	self assert: inspector documentPresenter model value equals: 'false'.
	inspector instVarListPresenter selectionByIndex: 2.	"asOop"
	self assert: inspector documentPresenter model value equals: 12!

test_openNavigationInspectorOnCharacter
	| remoteObject |
	self testsIssue: #issue398 withTitle: 'String Inspectors don''t display lfs'.
	remoteObject := session
				executeString: '$c'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	self assert: (inspector isKindOf: JadeiteInspector).
	self assert: inspector documentPresenter model value equals: '$c'.
	inspector instVarListPresenter selectionByIndex: 2.	"asOop"
	self assert: inspector documentPresenter model value equals: 25372!

test_openNavigationInspectorOnFloat
	| remoteObject |
	self testsIssue: #issue398 withTitle: 'String Inspectors don''t display lfs'.
	remoteObject := session
				executeString: '123.345'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	self assert: (inspector isKindOf: JadeiteInspector).
	self assert: inspector documentPresenter model value equals: '1.2334500000000000E02'.
	inspector instVarListPresenter selectionByIndex: 2.	"asOop"
	self assert: inspector documentPresenter model value equals: 9650476537015991014!

test_openNavigationInspectorOnNil
	| remoteObject |
	self testsIssue: #issue398 withTitle: 'String Inspectors don''t display lfs'.
	remoteObject := session
				executeString: 'nil'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	self assert: (inspector isKindOf: JadeiteInspector).
	self assert: inspector documentPresenter model value equals: 'nil'.
	inspector instVarListPresenter selectionByIndex: 2.	"asOop"
	self assert: inspector documentPresenter model value equals: 20!

test_openNavigationInspectorOnSmallInteger
	| remoteObject |
	self testsIssue: #issue398 withTitle: 'String Inspectors don''t display lfs'.
	remoteObject := session
				executeString: '123'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	self assert: (inspector isKindOf: JadeiteInspector).
	self assert: inspector documentPresenter model value equals: '123'.
	inspector instVarListPresenter selectionByIndex: 2. "asOop"
	self assert: inspector documentPresenter model value equals: 986.!

test_openNavigationInspectorOnSymbol
	| remoteObject |
	self testsIssue: #issue398 withTitle: 'String Inspectors don''t display lfs'.
	remoteObject := session
				executeString: '#abc'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	self assert: (inspector isKindOf: JadeiteInspector).
	self assert: inspector documentPresenter model value equals: '#''abc'''.
	inspector instVarListPresenter selectionByIndex: 2.	"asOop"
	self assert: inspector documentPresenter model value equals: 14351873!

test_openProjectsBrowser
	| remoteObject shell |
	remoteObject := session
				executeString: 'RowanClassService new'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	shell := inspector browseClass.
	[self assert: (shell isKindOf: JadeiteBrowser)] ensure: [self destroy: shell]!

test_openProjectsBrowserOnClass
	| remoteObject shell |
	remoteObject := session
				executeString: 'RowanClassService'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	shell := inspector browseClass.
	[self assert: (shell isKindOf: JadeiteBrowser)] ensure: [self destroy: shell]!

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
	self destroy: inspector.
	inspector := nil.
	self assert: BrowserUpdate current registeredPresenters size equals: registeredPresenters!

test_removeFromDictionary
	| remoteObject |
	remoteObject := session
				executeString: '| dictionary |
dictionary := Dictionary new.
UserGlobals at: #dictionary put: Dictionary new. 
1 to: 12 do: [:i |
dictionary at: i printString put: ''value'', i printString]. 
dictionary'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	inspector instVarListPresenter selectionByIndex: 3.
	self assert: inspector documentPresenter value equals: '''value11'''.
	inspector basicRemoveFromDictionary.
	self assert: inspector instVarListPresenter selectionByIndex equals: 3.
	self assert: inspector documentPresenter value equals: '''value1'''!

test_removeFromSymbolDictionary
	| remoteObject selection selectionIndex before after |
	remoteObject := session
				executeString: 'UserGlobals at: #ffoo put: ''bbarr''.  UserGlobals '
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	selection := inspector instVarListPresenter list detect: [:assoc | assoc key = '#''ffoo'''].
	inspector instVarListPresenter selection: selection.
	selectionIndex := inspector instVarListPresenter selectionByIndex.
	self assert: inspector documentPresenter value equals: '''bbarr'''.
	selectionIndex = inspector instVarListPresenter list size
		ifTrue: 
			[before := inspector instVarListPresenter list at: selectionIndex - 1.
			self deny: before equals: selection.
			inspector basicRemoveFromDictionary.
			self assertIsNil: (inspector instVarListPresenter list detect: [:assoc | assoc key = '#''ffoo''']
						ifNone: []).
			self assert: inspector instVarListPresenter selection equals: before.
			^self].
	before := inspector instVarListPresenter list at: selectionIndex - 1.
	after := inspector instVarListPresenter list at: selectionIndex + 1.
	self deny: before equals: after.
	self deny: before equals: selection.
	self deny: after equals: selection.
	inspector basicRemoveFromDictionary.
	self assertIsNil: (inspector instVarListPresenter list detect: [:assoc | assoc key = '#''ffoo''']
				ifNone: []).
	self assert: inspector instVarListPresenter selection equals: after.
	selectionIndex := inspector instVarListPresenter selectionByIndex.
	self assert: (inspector instVarListPresenter list at: selectionIndex - 1) equals: before!

test_removeIndexedInstVar
	| remoteObject |
	remoteObject := session
				executeString: '| coll oop inspectorService |
coll := Array new.
1 to: 50 do: [:i |
coll add: ''entry'', i asString].
oop := coll asOop.
coll'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	inspector instVarListPresenter selectionByIndex: 3.
	self assert: inspector documentPresenter value equals: '''entry1'''.
	self assert: inspector statusText equals: 'Displaying 50 of 50 indexed inst vars'.
	inspector basicRemoveObjectAt: 3.
	self assert: inspector instVarListPresenter selectionByIndex equals: 3.
	self assert: inspector documentPresenter value equals: '''entry2'''.
	self assert: inspector statusText equals: 'Displaying 49 of 49 indexed inst vars'!

test_removeItemEnabled
	| remoteObject removeObjectItem query |
	self testsIssue: #issue212 withTitle: '`Copy` menu item grayed out in inspector when text selected'.
	remoteObject := session
				executeString: '''abc'' copy'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	inspector instVarListPresenter selectionByIndex: 1.	"self"
	removeObjectItem := inspector instVarListPresenter view contextMenu items
				detect: [:item | item command = #removeObject].
	query := CommandQuery commandDescription: removeObjectItem commandDescription source: inspector view.
	inspector queryCommand: query.
	self deny: query isEnabled.
	inspector instVarListPresenter selectionByIndex: 2.	"-.asOop"
	inspector queryCommand: query.
	self deny: query isEnabled.
	3 to: 5
		do: 
			[:index |
			inspector instVarListPresenter selectionByIndex: index.
			inspector queryCommand: query.
			self assert: query isEnabled]!

test_removeLastElementFromDictionary
	| remoteObject |
	remoteObject := session
				executeString: '| dictionary |
dictionary := Dictionary new.
UserGlobals at: #dictionary put: Dictionary new. 
1 to: 12 do: [:i |
dictionary at: i printString put: ''value'', i printString]. 
dictionary'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	inspector instVarListPresenter selectionByIndex: 14.
	self assert: inspector documentPresenter value equals: '''value12'''.
	inspector basicRemoveFromDictionary.
	self assert: inspector instVarListPresenter selectionByIndex equals: 13.
	self assert: inspector documentPresenter value equals: '''value10'''!

test_removeLastIndexedInstVar
	| remoteObject |
	remoteObject := session
				executeString: '
''abc'' copy '
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	inspector instVarListPresenter selectionByIndex: 5.
	self assert: inspector documentPresenter value equals: '$c'.
	self assert: inspector statusText equals: 'Displaying 3 of 3 indexed inst vars'.
	inspector basicRemoveObjectAt: 5.
	self assert: inspector instVarListPresenter selectionByIndex equals: 4.
	self assert: inspector documentPresenter value equals: '$b'.
	self assert: inspector statusText equals: 'Displaying 2 of 2 indexed inst vars'!

test_showReturnsNavigationInspector
	| remoteObject |
	self testsIssue: #issue398 withTitle: 'String Inspectors don''t display lfs'.
	remoteObject := session
				executeString: 'Array with: ''abc
def'''
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	self assert: (inspector isKindOf: JadeiteInspector).
	self assert: inspector documentPresenter model value equals: 'anArray( ''abc
def'')'  replaceCrLfWithLf.
	inspector instVarListPresenter selectionByIndex: 3.	"first element of array"
	self assert: inspector documentPresenter model value equals: '''abc
def''' replaceCrLfWithLf!

test_showReturnsStringInspector
	| remoteObject |
	self testsIssue: #issue398 withTitle: 'String Inspectors don''t display lfs'.
	remoteObject := session
				executeString: '''abc
def'''
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	self assert: (inspector isKindOf: JadeInspector).
	self assert: inspector documentPresenter value equals: '''abc
def'''!

test_unicodeInspect1
	| remoteObject |
	self testsIssue: #issue651 withTitle: 'Inspecting dictionary with double byte string fails'.
	session
		executeString: '| dbs d|
dbs := ''a'', (String with: (Character withValue: 353)), ''b''.
d := Dictionary new.
d at: #key put: (''a'', dbs) asString.
UserGlobals at: #aDict1 put: d.'.
	
	[remoteObject := session executeString: 'UserGlobals at: #aDict1'.
	inspector := JadeInspector showOn: remoteObject session: session.
	inspector instVarListPresenter selectionByIndex: 3.
	self assert: inspector documentPresenter value equals: '''aa?b''']
			ensure: [session executeString: 'UserGlobals removeKey: #aDict1']!

test_unicodeInspect2
	| remoteObject |
	self testsIssue: #issue651 withTitle: 'Inspecting dictionary with double byte string fails'.
	session
		executeString: '
| dbs d|
dbs := ''a'', (String with: (Character withValue: 353)), ''b''.
d := Dictionary new.
d at: (''d'', dbs) asString put: 23.
UserGlobals at: #aDict4 put: d.'.
	
	[remoteObject := session executeString: 'UserGlobals at: #aDict4'.
	inspector := JadeInspector showOn: remoteObject session: session.
	self assert: (inspector instVarListPresenter list at: 3) key equals: '''da?b''']
			ensure: [session executeString: 'UserGlobals removeKey: #aDict4']! !
!JadeiteInspectorTestCase categoriesFor: #commandQueryOn:!private! !
!JadeiteInspectorTestCase categoriesFor: #enableForward:andBack:!private! !
!JadeiteInspectorTestCase categoriesFor: #inspectInstVarAt:!private! !
!JadeiteInspectorTestCase categoriesFor: #tearDown!private! !
!JadeiteInspectorTestCase categoriesFor: #test_abortTransactionInBasicInspector!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_abortTransactionInNavigationInspector!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_adHocInspect!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_adHocInspectComplexObject!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_autoCommitInAdHocInspect!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_autoCommitOffInAdHocInspect!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_basicInspectorDisplayedSizeLimit!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_caption!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_captionChange!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_commitTransactionInBasicInspector!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_commitTransactionInNavigationInspectorFocusCodePane!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_commitTransactionInNavigationInspectorFocusInstVars!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_displayAll!public!tests!tests menu bar! !
!JadeiteInspectorTestCase categoriesFor: #test_displayMore!public!tests!tests menu bar! !
!JadeiteInspectorTestCase categoriesFor: #test_displayMoreBigCollection!public!tests!tests menu bar! !
!JadeiteInspectorTestCase categoriesFor: #test_dive!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_forwardBack!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_fullInspectArray!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_inspectorHandlesError!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_inspectorRootObjectRegistered!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_inspectorRootSpecialObjectNotRegistered!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_inspectString!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_interactionInspect!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_menuBarItemNames!public!tests!tests menu bar! !
!JadeiteInspectorTestCase categoriesFor: #test_menuItemsEnabled!public!tests!tests menu bar! !
!JadeiteInspectorTestCase categoriesFor: #test_navigationInspectorDisplayedSizeLimit!public!tests!tests menu bar! !
!JadeiteInspectorTestCase categoriesFor: #test_openDictionaryBrowser!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_openDictionaryBrowserOnClass!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_openNavigationInspectorOnBoolean!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_openNavigationInspectorOnCharacter!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_openNavigationInspectorOnFloat!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_openNavigationInspectorOnNil!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_openNavigationInspectorOnSmallInteger!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_openNavigationInspectorOnSymbol!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_openProjectsBrowser!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_openProjectsBrowserOnClass!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_registeredPresentersInInspectorCleanedUp!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_removeFromDictionary!public!tests!tests menu bar! !
!JadeiteInspectorTestCase categoriesFor: #test_removeFromSymbolDictionary!public!tests!tests menu bar! !
!JadeiteInspectorTestCase categoriesFor: #test_removeIndexedInstVar!public!tests!tests menu bar! !
!JadeiteInspectorTestCase categoriesFor: #test_removeItemEnabled!public!tests!tests menu bar! !
!JadeiteInspectorTestCase categoriesFor: #test_removeLastElementFromDictionary!public!tests!tests menu bar! !
!JadeiteInspectorTestCase categoriesFor: #test_removeLastIndexedInstVar!public!tests!tests menu bar! !
!JadeiteInspectorTestCase categoriesFor: #test_showReturnsNavigationInspector!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_showReturnsStringInspector!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_unicodeInspect1!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_unicodeInspect2!public!tests! !

