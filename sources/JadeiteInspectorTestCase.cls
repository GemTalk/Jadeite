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

test_addCharacterToString
	"add a character to a string and expect to have it highlighted"

	| remoteObject |
	remoteObject := session
				executeString: '''abc'' copy'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	inspector instVarListPresenter selectionByIndex: 1.
	inspector basicAddObject: '$-'.
	self assert: inspector instVarListPresenter selection key equals: '1'.	"self was seleted. add char at 1. select first index afterwards"
	self assert: inspector documentPresenter value equals: '$-'.
	inspector instVarListPresenter selectionByIndex: 1.
	self assert: inspector documentPresenter value equals: '''-abc'''.
	inspector instVarListPresenter selectionByIndex: 6.
	inspector basicAddObject: '$d'.
	self assert: inspector instVarListPresenter selection key equals: '5'.	"last index was seleted. add char at end. select added char afterwards"
	inspector instVarListPresenter selectionByIndex: 1.
	self assert: inspector documentPresenter value equals: '''-abcd'''.
	inspector instVarListPresenter selectionByIndex: 4.
	self assert: inspector instVarListPresenter selection key equals: '2'.
	inspector basicAddObject: '$<'.
	self assert: inspector instVarListPresenter selection key equals: '3'.	"last index was seleted. add char after this slot. select added char afterwards"
	inspector instVarListPresenter selectionByIndex: 1.
	self assert: inspector documentPresenter value equals: '''-a<bcd'''!

test_addObjectDontOverwriteExistingKey
	| remoteObject |
	remoteObject := session
				executeString: 'Dictionary new at: $e put: #you; at: #a put: #me; yourself'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	inspector instVarListPresenter selectionByIndex: 1.
	inspector basicAddKey: '$e'.
	self assert: inspector instVarListPresenter selection key equals: '$e'.
	self assert: inspector documentPresenter value equals: '#''you'''.
	inspector basicAddKey: '#oogle'.
	self assert: inspector instVarListPresenter selection key equals: '#''oogle'''.
	self assert: inspector documentPresenter value equals: 'nil'!

test_addObjectToArray
	| remoteObject |
	remoteObject := session
				executeString: 'Array with: 1 with: ''abc'' with: $a'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	inspector instVarListPresenter selectionByIndex: 1.
	inspector basicAddObject: '$b'.
	self assert: inspector instVarListPresenter selection key equals: '1'.
	self assert: inspector documentPresenter value equals: '$b'.
	inspector instVarListPresenter selectionByIndex: 1.
	self assert: inspector documentPresenter value equals: 'anArray( $b, 1, ''abc'', $a)'.
	inspector instVarListPresenter selectionByIndex: 4.
	inspector basicAddObject: '99'.
	self assert: inspector instVarListPresenter selection key equals: '3'.
	self assert: inspector documentPresenter value equals: '99'.
	inspector instVarListPresenter selectionByIndex: 1.
	self assert: inspector documentPresenter value equals: 'anArray( $b, 1, 99, ''abc'', $a)'.
	inspector instVarListPresenter selectionByIndex: 7.
	inspector basicAddObject: '#t'.
	self assert: inspector instVarListPresenter selection key equals: '6'.
	self assert: inspector documentPresenter value equals: '#''t'''.
	inspector instVarListPresenter selectionByIndex: 1.
	self assert: inspector documentPresenter value equals: 'anArray( $b, 1, 99, ''abc'', $a, #''t'')'!

test_addObjectToArrayWithDynamic
	| remoteObject |
	remoteObject := session
				executeString: '| array | 
						array := Array with: 1 with: ''abc'' with: $a.
						array dynamicInstVarAt: #foo put: ''bar''. 
						array'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	inspector instVarListPresenter selectionByIndex: 1.
	inspector basicAddObject: '$b'.
	self assert: inspector instVarListPresenter selection key equals: '1'.
	self assert: inspector documentPresenter value equals: '$b'.
	inspector instVarListPresenter selectionByIndex: 1.
	self assert: inspector documentPresenter value equals: 'anArray( $b, 1, ''abc'', $a)'.
	inspector instVarListPresenter selectionByIndex: 4.
	inspector basicAddObject: '99'.
	self assert: inspector instVarListPresenter selection key equals: '2'.
	self assert: inspector documentPresenter value equals: '99'.
	inspector instVarListPresenter selectionByIndex: 1.
	self assert: inspector documentPresenter value equals: 'anArray( $b, 99, 1, ''abc'', $a)'.
	inspector instVarListPresenter selectionByIndex: 7.
	inspector basicAddObject: '#t'.
	self assert: inspector instVarListPresenter selection key equals: '5'.
	self assert: inspector documentPresenter value equals: '#''t'''.
	inspector instVarListPresenter selectionByIndex: 1.
	self assert: inspector documentPresenter value equals: 'anArray( $b, 99, 1, ''abc'', #''t'', $a)'!

test_addObjectToDictionary
	| remoteObject |
	remoteObject := session
				executeString: 'Dictionary new at: $e put: #you; at: #a put: #me; yourself'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	inspector instVarListPresenter selectionByIndex: 1.
	inspector basicAddKey: '''abc'''.
	self assert: inspector instVarListPresenter selection key equals: '''abc'''.
	self assert: inspector documentPresenter value equals: 'nil'.
	inspector instVarListPresenter selectionByIndex: 1.
	self assert: inspector documentPresenter value
		equals: 'aDictionary( ''abc''->nil, $e->#''you'', #''a''->#''me'')'!

test_addStringToString
	"add a string to a string. Select self afterwards. "

	| remoteObject |
	remoteObject := session
				executeString: '''abc'' copy'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	inspector instVarListPresenter selectionByIndex: 1.
	inspector basicAddObject: '''abd'''.
	self assert: inspector instVarListPresenter selection key equals: 'self'.	"self was seleted. add string at: 1"
	self assert: inspector documentPresenter value equals: '''abdabc'''.
	inspector instVarListPresenter selectionByIndex: 4.
	inspector basicAddObject: '''m'''.
	self assert: inspector instVarListPresenter selection key equals: 'self'.	"first b was seleted. add string after b"
	self assert: inspector documentPresenter value equals: '''abmdabc'''.
	inspector instVarListPresenter selectionByIndex: 9.
	inspector basicAddObject: '''zzz'''.
	self assert: inspector instVarListPresenter selection key equals: 'self'.	"last char selected. add string to end"
	self assert: inspector documentPresenter value equals: '''abmdabczzz'''!

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
	| remoteObject ocIndex |
	self testsIssue: #issue154 withTitle: 'Change inspector title on dive #154'.
	remoteObject := session
				executeString: 'Array with: (Dictionary new at: #oc put: (OrderedCollection with: #leaf); yourself)'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	self assert: ('Inspector on Array for*' match: inspector caption).
	self inspectInstVarAt: 3.
	self assert: ('Inspector on Dictionary for*' match: inspector caption).
	ocIndex := inspector instVarListPresenter list
				indexOf: (inspector instVarListPresenter list detect: [:item | item key = '#''oc''']).
	self inspectInstVarAt: ocIndex.
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

test_displayAllMenuEnablement
	| remoteObject jadeiteMenu displayAlltem query |
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
	jadeiteMenu := inspector view menuBar items detect: [:menu | '*Jadeite*' match: menu text].
	displayAlltem := jadeiteMenu items detect: [:item | '*Display All*' match: item text].
	query := CommandQuery commandDescription: displayAlltem commandDescription source: inspector view.
	inspector queryCommand: query.
	self assert: query isEnabled.
	inspector displayAll.
	inspector queryCommand: query.
	self deny: query isEnabled!

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

test_displayMoreMenuEnablement
	| remoteObject jadeiteMenu displayMoreItem query |
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
	jadeiteMenu := inspector view menuBar items detect: [:menu | '*Jadeite*' match: menu text].
	displayMoreItem := jadeiteMenu items detect: [:item | '*Display More*' match: item text].
	query := CommandQuery commandDescription: displayMoreItem commandDescription source: inspector view.
	inspector queryCommand: query.
	self assert: query isEnabled.
	inspector displayAll.
	inspector queryCommand: query.
	self deny: query isEnabled!

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

test_diveIntoDoubleByteString
	| service |
	inspector := JadeiteInspector new gciSession: session.
	inspector createView: inspector class defaultView.
	service := RowanInspectorService new
				executeThenInspect: 'Array with: (''aa'', (String with: (Character withValue: 353)), ''b'')'
				context: session oopNil value
				session: session
				windowHandle: inspector view handle value.
	inspector showOn: service.
	inspector instVarListPresenter selectionByIndex: 3.
	inspector inspectInstVar.
	self assert: inspector documentPresenter value equals: '''aa?b'''.
	inspector instVarListPresenter selectionByIndex: 3.
	self assert: inspector documentPresenter value equals: '$a'.
	inspector instVarListPresenter selectionByIndex: 4.
	self assert: inspector documentPresenter value equals: '$a'.
	inspector instVarListPresenter selectionByIndex: 5.
	self assert: inspector documentPresenter value equals: '$?'.
	inspector instVarListPresenter selectionByIndex: 6.
	self assert: inspector documentPresenter value equals: '$b'!

test_dynamicInstVars
	| workspace |
	workspace := JadeWorkspace showOnSession: session.
	
	[self assert: (workspace isKindOf: JadeWorkspace).
	workspace setDocumentData: 'Array new dynamicInstVarAt: #foo put: ''bar''; yourself'.
	workspace setFocus.
	inspector := workspace codePane jadeInspect.
	inspector instVarListPresenter selectionByIndex: 3.
	self assert: inspector instVarListPresenter selection key equals: '--foo'.
	self assert: inspector documentPresenter model value equals: '''bar''']
			ensure: 
				[workspace isModified: false.
				workspace view close]!

test_dynamicInstVarsInDictionary
	| workspace |
	workspace := JadeWorkspace showOnSession: session.
	
	[self assert: (workspace isKindOf: JadeWorkspace).
	workspace setDocumentData: '| dictionary |
	dictionary := Dictionary new.
	dictionary at: #key put: ''value''. 
	dictionary dynamicInstVarAt: #foo put: ''bar''.
	dictionary'.
	workspace setFocus.
	workspace codePane selectAll. 
	inspector := workspace codePane jadeInspect. 
	inspector instVarListPresenter selectionByIndex: 8.
	self assert: inspector instVarListPresenter selection key equals: '--foo'.
	self assert: inspector documentPresenter model value equals: '''bar'''.
	inspector instVarListPresenter selectionByIndex: 9.
	self assert: inspector instVarListPresenter selection key equals: '#''key'''.
	self assert: inspector documentPresenter model value equals: '''value'''.
	]
			ensure: 
				[workspace isModified: false.
				workspace view close]!

test_forwardBack
	| remoteObject backQuery forwardQuery ocIndex |
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
	ocIndex := inspector instVarListPresenter list
				indexOf: (inspector instVarListPresenter list detect: [:item | item key = '#''oc''']).
	self inspectInstVarAt: ocIndex."ordered collection"
	self enableForward: forwardQuery andBack: backQuery.
	self assert: backQuery isEnabled.
	self deny: forwardQuery isEnabled.
	self inspectInstVarAt: 3.	"symbol"
	self enableForward: forwardQuery andBack: backQuery.
	self assert: backQuery isEnabled.
	self deny: forwardQuery isEnabled.
	inspector getPreviousObject.	"ordered collection"
	self enableForward: forwardQuery andBack: backQuery.
	self assert: backQuery isEnabled.
	self assert: forwardQuery isEnabled.
	inspector getPreviousObject.	"dictionary"
	self enableForward: forwardQuery andBack: backQuery.
	self assert: backQuery isEnabled.
	self assert: forwardQuery isEnabled.
	inspector getPreviousObject.	"array - root"
	self enableForward: forwardQuery andBack: backQuery.
	self deny: backQuery isEnabled.
	self assert: forwardQuery isEnabled!

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

test_inspectAsOopField
	"if a non-string object is put into the inspectors text pane, 
	accessing the pane may break. Make a reasonable (valiant) 
	effort to make sure the example that was breaking no longer
	does so"

	| remoteObject |
	remoteObject := session
				executeString: '$X'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	inspector instVarListPresenter selectionByIndex: 2.
	self assert: inspector instVarListPresenter selection key equals: '-.asOop'.
	self assert: inspector instVarListPresenter selection value equals: '22556'.
	self assert: (session executeString: '$X asOop') equals: 22556.
	inspector documentPresenter selectionRange: (1 to: 5).
	inspector documentPresenter selection copyToClipboard.
	self assert: Clipboard current getText equals: '22556'!

test_inspectBag
	| remoteObject |
	remoteObject := session
				executeString: 'Bag new add: ''abc''; yourself'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	self assert: inspector documentPresenter value equals: 'aBag( ''abc'')'.
	inspector instVarListPresenter selectionByIndex: 2.
	self assert: inspector instVarListPresenter selection key equals: '-.asOop'.
	inspector instVarListPresenter selectionByIndex: 3.
	self assert: inspector instVarListPresenter selection key equals: '-_varyingSize'.
	inspector instVarListPresenter selectionByIndex: 4.
	self assert: inspector instVarListPresenter selection key equals: '-_numEntries'.
	inspector instVarListPresenter selectionByIndex: 5.
	self assert: inspector instVarListPresenter selection key equals: '-_indexedPaths'.
	inspector instVarListPresenter selectionByIndex: 6.
	self assert: inspector instVarListPresenter selection key equals: '-_levels'.
	inspector instVarListPresenter selectionByIndex: 7.
	self assert: inspector instVarListPresenter selection key equals: '-dict'.
	inspector instVarListPresenter selectionByIndex: 8.
	self assert: inspector instVarListPresenter selection key equals: '-size'.
	inspector instVarListPresenter selectionByIndex: 9.
	self assert: inspector instVarListPresenter selection key equals: '''abc'''.
	self assert: inspector instVarListPresenter list size equals: 9!

test_inspectDoubleByteString
	| service |
	inspector := JadeiteInspector new gciSession: session.
	inspector createView: inspector class defaultView.
	service := RowanInspectorService new
				executeThenInspect: '''aa'', (String with: (Character withValue: 353)), ''b'''
				context: session oopNil value
				session: session
				windowHandle: inspector view handle value.
	inspector showOn: service.
	self assert: inspector documentPresenter value equals: '''aa?b'''.
	inspector instVarListPresenter selectionByIndex: 3.
	self assert: inspector documentPresenter value equals: '$a'.
	inspector instVarListPresenter selectionByIndex: 4.
	self assert: inspector documentPresenter value equals: '$a'.
	inspector instVarListPresenter selectionByIndex: 5.
	self assert: inspector documentPresenter value equals: '$?'.
	inspector instVarListPresenter selectionByIndex: 6.
	self assert: inspector documentPresenter value equals: '$b'!

test_inspectIdentityBag
	| remoteObject |
	remoteObject := session
				executeString: '| abc | 
				abc := ''abc''. 
				IdentityBag new add: abc; add: abc; yourself'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	self assert: inspector documentPresenter value equals: 'anIdentityBag( ''abc'', ''abc'')'.
	inspector instVarListPresenter selectionByIndex: 2.
	self assert: inspector instVarListPresenter selection key equals: '-.asOop'.
	inspector instVarListPresenter selectionByIndex: 3.
	self assert: inspector instVarListPresenter selection key equals: '-_varyingSize'.
	inspector instVarListPresenter selectionByIndex: 4.
	self assert: inspector instVarListPresenter selection key equals: '-_numEntries'.
	inspector instVarListPresenter selectionByIndex: 5.
	self assert: inspector instVarListPresenter selection key equals: '-_indexedPaths'.
	inspector instVarListPresenter selectionByIndex: 6.
	self assert: inspector instVarListPresenter selection key equals: '-_levels'.
	inspector instVarListPresenter selectionByIndex: 7.
	self assert: inspector instVarListPresenter selection key equals: '''abc'''.
	inspector instVarListPresenter selectionByIndex: 8.
	self assert: inspector instVarListPresenter selection key equals: '''abc'''.
	self assert: inspector instVarListPresenter list size equals: 8!

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
	self assert: inspector documentPresenter value isKindOf: String]
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

test_inspectRcIdentityBag
	| remoteObject |
	remoteObject := session
				executeString: 'RcIdentityBag with: 1 with: ''abc'' with: $k'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	self assert: (inspector isKindOf: JadeiteInspector).
	self assert: inspector documentPresenter value equals: 'aRcIdentityBag( 1, $k, ''abc'')'.
	self assert: (inspector instVarListPresenter list collect: [:ea | ea key]) asArray
		equals: #('self' '-.asOop' '-_varyingSize' '-_numEntries' '-_indexedPaths' '-_levels' '-components' '$k' '''abc''' '1').
	"not sure about order in an identity bag. Might need to test differently"
	inspector instVarListPresenter selectionByIndex: 10.
	self assert: inspector documentPresenter value equals: '1'.
	inspector instVarListPresenter selectionByIndex: 9.
	self assert: inspector documentPresenter value equals: '''abc'''.
	inspector instVarListPresenter selectionByIndex: 8.
	self assert: inspector documentPresenter value equals: '$k'!

test_inspectRcIdentityBagWithUnicodeKey
	| remoteObject |
	remoteObject := session
				executeString: '| dbs bag |
dbs := ''a'', (String with: (Character withValue: 353)), ''b''.
bag := RcIdentityBag new. 
bag add: (''a'', dbs) asString.
bag'.
	inspector := JadeInspector showOn: remoteObject session: session.
	self assert: inspector documentPresenter value equals: 'aRcIdentityBag( ''aa?b'')'.
	inspector instVarListPresenter selectionByIndex: 8.
	self assert: inspector documentPresenter value equals: '''aa?b'''!

test_inspectRcQueue
	| remoteObject |
	remoteObject := session
				executeString: 'RcQueue new add: 1; yourself'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	self assert: inspector documentPresenter value equals: 'aRcQueue( 1)'.
	self assert: inspector instVarListPresenter list size equals: 23	"self + asOop + 1 inst var + default new size 20"!

test_inspectSet
	| remoteObject |
	remoteObject := session
				executeString: 'Set new add: ''abc''; yourself'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	self assert: inspector documentPresenter value equals: 'aSet( ''abc'')'.
	inspector instVarListPresenter selectionByIndex: 2.
	self assert: inspector instVarListPresenter selection key equals: '-.asOop'.
	inspector instVarListPresenter selectionByIndex: 3.
	self assert: inspector instVarListPresenter selection key equals: '-_varyingSize'.
	inspector instVarListPresenter selectionByIndex: 4.
	self assert: inspector instVarListPresenter selection key equals: '-_numEntries'.
	inspector instVarListPresenter selectionByIndex: 5.
	self assert: inspector instVarListPresenter selection key equals: '-_indexedPaths'.
	inspector instVarListPresenter selectionByIndex: 6.
	self assert: inspector instVarListPresenter selection key equals: '-_levels'.
	inspector instVarListPresenter selectionByIndex: 7.
	self assert: inspector instVarListPresenter selection key equals: '-dict'.
	inspector instVarListPresenter selectionByIndex: 8.
	self assert: inspector instVarListPresenter selection key equals: '''abc'''.
	self assert: inspector instVarListPresenter list size equals: 8!

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

test_modifyArrayElement
	| remoteObject |
	self testsIssue: #issue104 withTitle: 'Inspector: be nice to be able to apply changes to the object'.
	remoteObject := session
				executeString: 'Array with: 1 with: ''abc'' with: $a'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	inspector instVarListPresenter selectionByIndex: 3.	"select the 1st indexed element"
	inspector documentPresenter value: '2'.
	inspector saveDocument.
	self assert: inspector documentPresenter value equals: '2'.
	inspector instVarListPresenter selectionByIndex: 4.
	self assert: inspector documentPresenter value equals: '''abc'''.
	inspector instVarListPresenter selectionByIndex: 3.
	self assert: inspector documentPresenter value equals: '2'!

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
	self assert: inspector documentPresenter model value equals: '268']
			ensure: [self destroy: inspector].
	remoteObject := session
				executeString: 'false'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	self assert: (inspector isKindOf: JadeiteInspector).
	self assert: inspector documentPresenter model value equals: 'false'.
	inspector instVarListPresenter selectionByIndex: 2.	"asOop"
	self assert: inspector documentPresenter model value equals: '12'!

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
	self assert: inspector documentPresenter model value equals: '25372'!

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
	self assert: inspector documentPresenter model value equals: '9650476537015991014'!

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
	self assert: inspector documentPresenter model value equals: '20'!

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
	self assert: inspector documentPresenter model value equals: '986'.!

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
	self assert: inspector documentPresenter model value equals: '14351873'!

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
	| remoteObject firstKeyIndex |
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
	firstKeyIndex := inspector instVarListPresenter list
				indexOf: (inspector instVarListPresenter list detect: [:item | item key = '''1''']).
	inspector instVarListPresenter selectionByIndex: firstKeyIndex.	
	self assert: inspector documentPresenter value equals: '''value1'''.
	inspector basicRemoveFromDictionary.
	self assert: inspector instVarListPresenter selectionByIndex equals: firstKeyIndex.
	self assert: inspector documentPresenter value equals: '''value10'''!

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

test_removeIndexedInstVarWithDynamic
	| remoteObject |
	remoteObject := session
				executeString: '| coll oop inspectorService |
coll := Array new.
coll dynamicInstVarAt: #foo put: ''bar''. 
1 to: 50 do: [:i |
coll add: ''entry'', i asString].
oop := coll asOop.
coll'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	inspector instVarListPresenter selectionByIndex: 4.
	self assert: inspector documentPresenter value equals: '''entry1'''.
	self assert: inspector statusText equals: 'Displaying 50 of 50 indexed inst vars'.
	inspector basicRemoveObjectAt: 5.
	self assert: inspector instVarListPresenter selectionByIndex equals: 5.
	self assert: inspector documentPresenter value equals: '''entry3'''.
	self assert: inspector statusText equals: 'Displaying 49 of 49 indexed inst vars'!

test_removeItemDisabledForInstVars
	| remoteObject removeObjectItem query |
	remoteObject := session
				executeString: 'Set with: $a'
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
	3 to: 7
		do: 
			[:index |
			inspector instVarListPresenter selectionByIndex: index.
			inspector queryCommand: query.
			self deny: query isEnabled].	"inst vars"
	inspector instVarListPresenter selectionByIndex: 8.
	inspector queryCommand: query.
	self assert: query isEnabled!

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
	inspector instVarListPresenter selectionByIndex: inspector instVarListPresenter list size.
	self assert: inspector documentPresenter value equals: '''value9'''.
	inspector basicRemoveFromDictionary.
	self assert: inspector instVarListPresenter selectionByIndex equals: inspector instVarListPresenter list size.
	self assert: inspector documentPresenter value equals: '''value8'''!

test_removeLastElementOfSet
	| remoteObject  previousSize |
	remoteObject := session
				executeString: 'Set with: 1'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	inspector instVarListPresenter selectionByIndex: inspector instVarListPresenter list size.
	previousSize := inspector instVarListPresenter list size. 
	inspector basicRemoveOop: inspector instVarListPresenter selection value.
	self assert: inspector instVarListPresenter list size equals: previousSize - 1. 
	self assert: inspector model visibleIndices equals: 0. 
	self assert: inspector instVarListPresenter selection key equals: '-dict'. 
	!

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
	inspector instVarListPresenter selectionByIndex: inspector instVarListPresenter list size.
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
	self assert: (inspector instVarListPresenter list at: inspector instVarListPresenter list size) key
		equals: '''da?b''']
			ensure: [session executeString: 'UserGlobals removeKey: #aDict4']! !
!JadeiteInspectorTestCase categoriesFor: #commandQueryOn:!private! !
!JadeiteInspectorTestCase categoriesFor: #enableForward:andBack:!private! !
!JadeiteInspectorTestCase categoriesFor: #inspectInstVarAt:!private! !
!JadeiteInspectorTestCase categoriesFor: #tearDown!private! !
!JadeiteInspectorTestCase categoriesFor: #test_abortTransactionInBasicInspector!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_abortTransactionInNavigationInspector!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_addCharacterToString!public!tests add remove! !
!JadeiteInspectorTestCase categoriesFor: #test_addObjectDontOverwriteExistingKey!public!tests add remove! !
!JadeiteInspectorTestCase categoriesFor: #test_addObjectToArray!public!tests add remove! !
!JadeiteInspectorTestCase categoriesFor: #test_addObjectToArrayWithDynamic!public!tests add remove! !
!JadeiteInspectorTestCase categoriesFor: #test_addObjectToDictionary!public!tests add remove! !
!JadeiteInspectorTestCase categoriesFor: #test_addStringToString!public!tests add remove! !
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
!JadeiteInspectorTestCase categoriesFor: #test_displayAllMenuEnablement!public!tests!tests menu bar! !
!JadeiteInspectorTestCase categoriesFor: #test_displayMore!public!tests!tests menu bar! !
!JadeiteInspectorTestCase categoriesFor: #test_displayMoreMenuEnablement!public!tests!tests menu bar! !
!JadeiteInspectorTestCase categoriesFor: #test_dive!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_diveIntoDoubleByteString!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_dynamicInstVars!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_dynamicInstVarsInDictionary!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_forwardBack!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_fullInspectArray!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_inspectAsOopField!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_inspectBag!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_inspectDoubleByteString!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_inspectIdentityBag!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_inspectorHandlesError!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_inspectorRootObjectRegistered!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_inspectorRootSpecialObjectNotRegistered!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_inspectRcIdentityBag!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_inspectRcIdentityBagWithUnicodeKey!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_inspectRcQueue!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_inspectSet!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_inspectString!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_interactionInspect!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_menuBarItemNames!public!tests!tests menu bar! !
!JadeiteInspectorTestCase categoriesFor: #test_menuItemsEnabled!public!tests!tests menu bar! !
!JadeiteInspectorTestCase categoriesFor: #test_modifyArrayElement!public!tests modify object! !
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
!JadeiteInspectorTestCase categoriesFor: #test_removeFromDictionary!public!tests!tests add remove!tests menu bar! !
!JadeiteInspectorTestCase categoriesFor: #test_removeFromSymbolDictionary!public!tests!tests add remove!tests menu bar! !
!JadeiteInspectorTestCase categoriesFor: #test_removeIndexedInstVar!public!tests!tests add remove!tests menu bar! !
!JadeiteInspectorTestCase categoriesFor: #test_removeIndexedInstVarWithDynamic!public!tests!tests add remove!tests menu bar! !
!JadeiteInspectorTestCase categoriesFor: #test_removeItemDisabledForInstVars!public!tests!tests add remove!tests menu bar! !
!JadeiteInspectorTestCase categoriesFor: #test_removeItemEnabled!public!tests!tests add remove!tests menu bar! !
!JadeiteInspectorTestCase categoriesFor: #test_removeLastElementFromDictionary!public!tests!tests add remove!tests menu bar! !
!JadeiteInspectorTestCase categoriesFor: #test_removeLastElementOfSet!public!tests add remove! !
!JadeiteInspectorTestCase categoriesFor: #test_removeLastIndexedInstVar!public!tests!tests add remove!tests menu bar! !
!JadeiteInspectorTestCase categoriesFor: #test_showReturnsNavigationInspector!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_showReturnsStringInspector!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_unicodeInspect1!public!tests! !
!JadeiteInspectorTestCase categoriesFor: #test_unicodeInspect2!public!tests! !

