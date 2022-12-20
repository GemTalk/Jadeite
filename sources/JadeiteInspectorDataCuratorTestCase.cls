"Filed out from Dolphin Smallalk"!

JadeiteAbstractTestCase subclass: #JadeiteInspectorDataCuratorTestCase
	instanceVariableNames: 'inspector'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteInspectorDataCuratorTestCase guid: (GUID fromString: '{73901ab8-5805-4614-b9e4-7092e55c6317}')!
JadeiteInspectorDataCuratorTestCase comment: ''!
!JadeiteInspectorDataCuratorTestCase categoriesForClass!Unclassified! !
!JadeiteInspectorDataCuratorTestCase methodsFor!

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
	self selectInstVarAtIndex: index.
	inspector inspectInstVar!

primaryTestWindow
	^inspector!

selectInstVarAtIndex: index
	"needed an efficient way of converting a workaround for an old Dolphin selectionByIndex: bug
	When all senders of this method are converted to passing integers only, then we can remove the conditional"

	| theIndex |
	theIndex := index isInteger ifTrue: [index] ifFalse: [index first].
	inspector instVarListPresenter selectionByIndex: theIndex!

setUp
	user ifNil: [user := 'DataCurator'].
	super setUp!

tearDown
	super tearDown.
	inspector
		ifNotNil: 
			[inspector documentPresenter view isModified: false.
			self destroy: inspector view]!

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
				self ensureRowanSampleProjectsLoaded]!

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
				self ensureRowanSampleProjectsLoaded].
	"focus in code pane"
	inspector documentPresenter setFocus.
	abortItem commandDescription performAgainst: inspector.
	
	[transcript projectListPresenter refresh.
	self denyProjectInList: 'RowanSample1'] ensure: 
				[self cloneRowanSample1.
				self ensureRowanSampleProjectsLoaded].
	"focus in list pane"
	inspector instVarListPresenter setFocus.
	abortItem commandDescription performAgainst: inspector.
	
	[transcript projectListPresenter refresh.
	self denyProjectInList: 'RowanSample1'] ensure: 
				[self cloneRowanSample1.
				self ensureRowanSampleProjectsLoaded]!

test_addCharacterToString
	"add a character to a string and expect to have it highlighted"

	| remoteObject |
	remoteObject := session
				executeString: '''abc'' copy'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	self selectInstVarAtIndex: 1.
	inspector basicAddObject: '$-'.
	self assert: inspector instVarListPresenter selections first key equals: '1'.	"self was seleted. add char at 1. select first index afterwards"
	self assert: inspector documentPresenter value equals: '$-'.
	self selectInstVarAtIndex: 1.
	self assert: inspector documentPresenter value equals: '''-abc'''.
	self selectInstVarAtIndex: 6.
	inspector basicAddObject: '$d'.
	self assert: inspector instVarListPresenter selections first key equals: '5'.	"last index was seleted. add char at end. select added char afterwards"
	self selectInstVarAtIndex: 1.
	self assert: inspector documentPresenter value equals: '''-abcd'''.
	self selectInstVarAtIndex: 4.
	self assert: inspector instVarListPresenter selections first key equals: '2'.
	inspector basicAddObject: '$<'.
	self assert: inspector instVarListPresenter selections first key equals: '3'.	"last index was seleted. add char after this slot. select added char afterwards"
	self selectInstVarAtIndex: 1.
	self assert: inspector documentPresenter value equals: '''-a<bcd'''!

test_addContextSensitiveObjectToDictionary
	| remoteObject |
	self testsIssue: #issue104 withTitle: 'Inspector: be nice to be able to apply changes to the object'.
	remoteObject := session
				executeString: 'Dictionary new at: $e put: #you; at: #a put: #me; yourself'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	self selectInstVarAtIndex: #(1).
	inspector basicAddKey: 'self at: $e'.
	self assert: inspector instVarListPresenter selection key equals: '#''you'''.
	self assert: inspector documentPresenter value equals: 'nil'.
	self selectInstVarAtIndex: #(1).
	self assert: ('*$e->#''you''*' match: inspector documentPresenter value).
	self assert: ('*#''a''->#''me''*' match: inspector documentPresenter value).
	self assert: ('*#''you''->nil*' match: inspector documentPresenter value)!

test_addObjectDontOverwriteExistingKey
	| remoteObject |
	remoteObject := session
				executeString: 'Dictionary new at: $e put: #you; at: #a put: #me; yourself'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	self selectInstVarAtIndex: 1.
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
	self selectInstVarAtIndex: #(1).
	inspector basicAddObject: '$b'.
	self assert: inspector instVarListPresenter selection key equals: '1'.
	self assert: inspector documentPresenter value equals: '$b'.
	self selectInstVarAtIndex: #(1).
	self assert: inspector documentPresenter value equals: 'anArray( $b, 1, ''abc'', $a)'.
	self selectInstVarAtIndex: #(4).
	inspector basicAddObject: '99'.
	self assert: inspector instVarListPresenter selection key equals: '3'.
	self assert: inspector documentPresenter value equals: '99'.
	self selectInstVarAtIndex: #(1).
	self assert: inspector documentPresenter value equals: 'anArray( $b, 1, 99, ''abc'', $a)'.
	self selectInstVarAtIndex: #(7).
	inspector basicAddObject: '#t'.
	self assert: inspector instVarListPresenter selection key equals: '6'.
	self assert: inspector documentPresenter value equals: '#''t'''.
	self selectInstVarAtIndex: #(1).
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
	self selectInstVarAtIndex: #(1).
	inspector basicAddObject: '$b'.
	self assert: inspector instVarListPresenter selection key equals: '1'.
	self assert: inspector documentPresenter value equals: '$b'.
	self selectInstVarAtIndex: #(1).
	self assert: inspector documentPresenter value equals: 'anArray( $b, 1, ''abc'', $a)'.
	self selectInstVarAtIndex: #(4).
	inspector basicAddObject: '99'.
	self assert: inspector instVarListPresenter selection key equals: '2'.
	self assert: inspector documentPresenter value equals: '99'.
	self selectInstVarAtIndex: #(1).
	self assert: inspector documentPresenter value equals: 'anArray( $b, 99, 1, ''abc'', $a)'.
	self selectInstVarAtIndex: #(7).
	inspector basicAddObject: '#t'.
	self assert: inspector instVarListPresenter selection key equals: '5'.
	self assert: inspector documentPresenter value equals: '#''t'''.
	self selectInstVarAtIndex: #(1).
	self assert: inspector documentPresenter value equals: 'anArray( $b, 99, 1, ''abc'', #''t'', $a)'!

test_addObjectToDictionary
	| remoteObject |
	remoteObject := session
				executeString: 'Dictionary new at: $e put: #you; at: #a put: #me; yourself'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	self selectInstVarAtIndex: #(1).
	inspector basicAddKey: '''abc'''.
	self assert: inspector instVarListPresenter selection key equals: '''abc'''.
	self assert: inspector documentPresenter value equals: 'nil'.
	self selectInstVarAtIndex: #(1).
	self assert: ('aDictionary(*''abc''->nil*)' match: inspector documentPresenter value).
	self assert: ('aDictionary(*$e->#''you''*)' match: inspector documentPresenter value).
	self assert: ('aDictionary(*#''a''->#''me''*)' match: inspector documentPresenter value)!

test_addStringToString
	"add a string to a string. Select self afterwards. "

	| remoteObject |
	remoteObject := session
				executeString: '''abc'' copy'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	self selectInstVarAtIndex: #(1).
	inspector basicAddObject: '''abd'''.
	self assert: inspector instVarListPresenter selection key equals: 'self'.	"self was seleted. add string at: 1"
	self assert: inspector documentPresenter value equals: '''abdabc'''.
	self selectInstVarAtIndex: #(4).
	inspector basicAddObject: '''m'''.
	self assert: inspector instVarListPresenter selection key equals: 'self'.	"first b was seleted. add string after b"
	self assert: inspector documentPresenter value equals: '''abmdabc'''.
	self selectInstVarAtIndex: #(9).
	inspector basicAddObject: '''zzz'''.
	self assert: inspector instVarListPresenter selection key equals: 'self'.	"last char selected. add string to end"
	self assert: inspector documentPresenter value equals: '''abmdabczzz'''!

test_adHocExecution
	"sanity test that ad-hoc executions in the pane work"

	| workspace |
	workspace := JadeWorkspace showOnSession: session.
	
	[self assert: (workspace isKindOf: JadeWorkspace).
	workspace setDocumentData: 'Array with: 1 with: 2'.
	workspace setFocus.
	inspector := workspace codePane jadeInspect.
	inspector documentPresenter value: 'self size'.
	inspector codePane jadeDisplay.
	self assert: inspector documentPresenter value equals: 'self size 2']
			ensure: 
				[workspace isModified: false.
				self closeBrowser: workspace]!

test_adHocInspect
	| workspace methodListBrowser |
	self testsIssue: #issue427 withTitle: '(3.0.60) autocommit not done after successful doits'.
	self testsIssue: #issue712
		withTitle: 'Inspect UserGlobals from Method list, get ByteArray DNE asHexString'.
	workspace := JadeWorkspace showOnSession: session.
	
	[self assert: (workspace isKindOf: JadeWorkspace).
	workspace setDocumentData: '123'.
	workspace setFocus.
	inspector := workspace codePane jadeInspect.
	self assert: inspector documentPresenter model value equals: '123'.
	self assert: inspector instVarListPresenter selection key equals: 'self']
			ensure: 
				[workspace isModified: false.
				self closeBrowser: workspace.
				self closeBrowser: inspector].
	self openProjectBrowser.
	
	[self selectRowanSample1Test.
	self
		saveMethod: 'bartooee  ^UserGlobals size'
		in: 'RowanSample1Test'
		category: 'deleteme'.
	self selectMethodNamed: #bartooee.
	self projectsPresenter methodSourcePresenter view selectionRanges: (Array with: (12 to: 22)).
	self projectsPresenter methodSourcePresenter view setFocus.
	inspector := self projectsPresenter jadeInspect.
	[self assert: inspector instVarListPresenter selection key equals: 'self']
		ensure: [self closeBrowser: inspector].
	methodListBrowser := self projectsPresenter browseImplementors.
	methodListBrowser primaryPresenter methodSourcePresenter documentPresenter view
		selectionRange: (12 to: 22).
	methodListBrowser primaryPresenter methodSourcePresenter view setFocus.
	inspector := self projectsPresenter jadeInspect.
	self assert: inspector instVarListPresenter selection key equals: 'self']
			ensure: 
				[self closeBrowser: projectsBrowser.
				self closeBrowser: inspector.
				self closeBrowser: methodListBrowser]!

test_adHocInspectCompileError
	| workspace |
	self testsIssue: #issue688 withTitle: '(3.0.92) Compile Errors in Workspace broken'.
	workspace := JadeWorkspace showOnSession: session.
	
	[self assert: (workspace isKindOf: JadeWorkspace).
	workspace setDocumentData: '123'.
	workspace setFocus.
	inspector := workspace codePane jadeInspect.
	inspector documentPresenter model value: '#(1 2'.
	inspector codePane view setFocus.
	inspector codePane jadeExecute.
	self assert: inspector documentPresenter view text equals: '#(1 2expected a right parenthesis']
			ensure: 
				[workspace isModified: false.
				self closeBrowser: workspace]!

test_adHocInspectComplexObject
	| workspace |
	self testsIssue: #issue464 withTitle: '(3.0.67) String does not understand #format: ... during doit'.
	workspace := JadeWorkspace showOnSession: session.
	
	[self assert: (workspace isKindOf: JadeWorkspace).
	workspace setDocumentData: 'RowanSample1Test new setTestSelector: #test1'.
	workspace setFocus.
	inspector := workspace codePane jadeInspect.
	self assert: inspector documentPresenter model value equals: 'RowanSample1Test debug: #test1'.
	self assert: inspector instVarListPresenter selection key equals: 'self']
			ensure: 
				[workspace isModified: false.
				self closeBrowser: workspace]!

test_adHocInspectFromWithinInspector
	| remoteObject secondInspector |
	"context of inspector should be itself. Test that this basically works"
	remoteObject := session
				executeString: '''abc'''
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	inspector documentPresenter value: 'self size'.
	inspector documentPresenter view selectAll.
	inspector documentPresenter view setFocus.
	secondInspector := inspector codePane jadeInspect.
	
	[self assert: secondInspector instVarListPresenter list size equals: 2.
	self assert: secondInspector documentPresenter value equals: '3']
			ensure: [self closeBrowser: secondInspector]!

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
				[self closeBrowser: inspector topShell primaryPresenter.
				workspace isModified: false.
				self closeBrowser: workspace.
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
				[self closeBrowser: inspector topShell primaryPresenter.
				workspace isModified: false.
				self closeBrowser: workspace].
	
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
	self assert: inspector instVarListPresenter list last key equals: '65000'.
	self assert: inspector instVarListPresenter list last value
		equals: (session executeString: '$a asOop').
	self assert: inspector instVarListPresenter list last key equals: '65000'.
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

test_closeWithUnsavedChanges
	| remoteObject |
	self testsIssue: #issue722
		withTitle: 'Unsaved inspector code pane changes get lost on inspector window close'.
	remoteObject := session
				executeString: 'Bag new add: ''abc''; yourself'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	inspector documentPresenter value: 'nil'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[TestMessageBox plannedResult: #yes.
	self closeBrowser: inspector.
	self assert: inspector view isOpen.
	TestMessageBox plannedResult: #no.
	self closeBrowser: inspector.
	self deny: inspector view isOpen.
	remoteObject := session
				executeString: 'Bag new add: ''abc''; yourself'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	TestMessageBox plannedResult: #no.
	self closeBrowser: inspector.
	self assert: inspector view isOpen]
			ensure: 
				[inspector codePane view isModified: false.
				self closeBrowser: inspector.	"in case test fails before inspector is closed"
				TestMessageBox disableJadeiteTestMessageBox]!

test_commitTransactionInBasicInspector
	| remoteObject jadeiteMenu commitItem abortItem |
	self testsIssue: #issue383 withTitle: '(3.0.53) the commit button on the SUnit browser is silent'.
	self cloneRowanSample1.
	self ensureRowanSampleProjectsLoaded.
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
	self unloadSampleProject1.
	commitItem commandDescription performAgainst: inspector.
	self denyProjectInList: 'RowanSample1'.
	self cloneRowanSample1.
	self ensureRowanSampleProjectsLoaded!

test_commitTransactionInNavigationInspectorFocusCodePane
	| remoteObject jadeiteMenu commitItem abortItem |
	self testsIssue: #issue383 withTitle: '(3.0.53) the commit button on the SUnit browser is silent'.
	self cloneRowanSample1.
	self ensureRowanSampleProjectsLoaded.
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
	self unloadSampleProject1.
	commitItem commandDescription performAgainst: inspector.
	self denyProjectInList: 'RowanSample1'.
	self cloneRowanSample1.
	self ensureRowanSampleProjectsLoaded!

test_commitTransactionInNavigationInspectorFocusInstVars
	| remoteObject jadeiteMenu commitItem abortItem |
	self testsIssue: #issue383 withTitle: '(3.0.53) the commit button on the SUnit browser is silent'.
	self cloneRowanSample1.
	self ensureRowanSampleProjectsLoaded.
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
	self unloadSampleProject1.
	commitItem commandDescription performAgainst: inspector.
	self denyProjectInList: 'RowanSample1'.
	self cloneRowanSample1.
	self ensureRowanSampleProjectsLoaded!

test_compileErrorHandling
	| remoteObject |
	self testsIssue: #issue104 withTitle: 'Inspector: be nice to be able to apply changes to the object'.
	remoteObject := session
				executeString: 'Array with: 1 with: ''abc'' with: $a'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	self selectInstVarAtIndex: #(3).	"select the 1st indexed element"
	inspector documentPresenter value: '2 + '.
	inspector saveDocument.
	self assert: inspector documentPresenter value equals: '2 + expected a primary expression>>>>>'.
	inspector documentPresenter value: 'a'.
	inspector saveDocument.
	self assert: inspector documentPresenter value equals: 'undefined symbol>>>>>a'.
	inspector documentPresenter value: '''abc'.
	inspector saveDocument.
	self assert: inspector documentPresenter value
		equals: '''abcmissing end of literal mark (prime)>>>>>'.
	inspector documentPresenter value: '| a 

a := 2.
a'.
	inspector saveDocument.
	self assert: inspector documentPresenter value
		equals: '| a 

variable has already been declared>>>>>a := 2.
a'!

test_deselectClearsPane
	| remoteObject |
	remoteObject := session
				executeString: '97'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	self assert: inspector instVarListPresenter selectionByIndex equals: 1.
	self assert: inspector documentPresenter value equals: '97'.
	inspector instVarListPresenter view selectAll.
	self assert: inspector instVarListPresenter selections size equals: 2.
	self assert: inspector documentPresenter value equals: 'self: 97
-.asOop: 778'.
	inspector instVarListPresenter view selections: #().
	self assert: inspector documentPresenter value equals: String new. 
	!

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
	self assert: inspector statusText equals: 'Displaying 1000 of 20000 variable inst vars'.
	self assert: inspector instVarListPresenter list size equals: 1002.
	inspector displayAll.
	self assert: inspector statusText equals: 'Displaying 20000 of 20000 variable inst vars'.
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
				equals: 'Displaying ' , thousand printString , ' of 20000 variable inst vars'.
			self assert: inspector instVarListPresenter list size equals: thousand + 2.
			inspector displayMore].
	self assert: inspector statusText equals: 'Displaying 20000 of 20000 variable inst vars'.
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
	self selectInstVarAtIndex: #(8).
	self assert: inspector instVarListPresenter selection key equals: '-rootClass'.
	inspector instVarListPresenter view onActionPerformed.	"event for double click"
	self assert: inspector instVarListPresenter selection key equals: 'self'.
	self assert: inspector documentPresenter value equals: 'Object'.
	index := (inspector instVarListPresenter list collect: [:assoc | assoc key]) indexOf: '-name'.
	self selectInstVarAtIndex: (Array with: index).
	self assert: inspector documentPresenter value equals: '#''Object''']
			ensure: 
				[workspace isModified: false.
				self closeBrowser: workspace]!

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
	self selectInstVarAtIndex: #(3).
	inspector inspectInstVar.
	self assert: inspector documentPresenter value equals: '''aašb'''.
	self selectInstVarAtIndex: #(3).
	self assert: inspector documentPresenter value equals: '$a'.
	self selectInstVarAtIndex: #(4).
	self assert: inspector documentPresenter value equals: '$a'.
	self selectInstVarAtIndex: #(5).
	self assert: inspector documentPresenter value equals: '$š'.
	self selectInstVarAtIndex: #(6).
	self assert: inspector documentPresenter value equals: '$b'!

test_dynamicInstVars
	| workspace |
	workspace := JadeWorkspace showOnSession: session.
	
	[self assert: (workspace isKindOf: JadeWorkspace).
	workspace setDocumentData: 'Array new dynamicInstVarAt: #foo put: ''bar''; yourself'.
	workspace setFocus.
	inspector := workspace codePane jadeInspect.
	self selectInstVarAtIndex: #(3).
	self assert: inspector instVarListPresenter selection key equals: '--foo'.
	self assert: inspector documentPresenter model value equals: '''bar''']
			ensure: 
				[workspace isModified: false.
				self closeBrowser: workspace]!

test_dynamicInstVarsInDictionary
	| workspace |
	workspace := JadeWorkspace showOnSession: session.
	
	[self assert: (workspace isKindOf: JadeWorkspace).
	workspace
		setDocumentData: '| dictionary |
	dictionary := Dictionary new.
	dictionary at: #key put: ''value''. 
	dictionary dynamicInstVarAt: #foo put: ''bar''.
	dictionary'.
	workspace setFocus.
	workspace codePane selectAll.
	inspector := workspace codePane jadeInspect.
	self selectInstVarAtIndex: #(8).
	self assert: inspector instVarListPresenter selection key equals: '--foo'.
	self assert: inspector documentPresenter model value equals: '''bar'''.
	self selectInstVarAtIndex: #(9).
	self assert: inspector instVarListPresenter selection key equals: '#''key'''.
	self assert: inspector documentPresenter model value equals: '''value''']
			ensure: 
				[workspace isModified: false.
				self closeBrowser: workspace]!

test_fileSaveEnabled
	| remoteObject toolbarButton query |
	self testsIssue: #issue104 withTitle: 'Inspector: be nice to be able to apply changes to the object'.
	remoteObject := session
				executeString: 'Array with: #a'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	toolbarButton := inspector codePane view subViews first items
				detect: [:item | item isDivider not and: [item command = #fileSave]].
	query := CommandQuery commandDescription: toolbarButton commandDescription source: inspector view.
	self selectInstVarAtIndex: #(1).
	inspector queryCommand: query.
	self deny: query isEnabled.
	self selectInstVarAtIndex: #(2).
	inspector queryCommand: query.
	self deny: query isEnabled.
	self selectInstVarAtIndex: #(3).
	inspector queryCommand: query.
	self deny: query isEnabled.
	inspector documentPresenter view isModified: true.
	
	[inspector queryCommand: query.
	self assert: query isEnabled]
			ensure: [inspector documentPresenter view isModified: false]!

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
			self selectInstVarAtIndex: (Array with: index).
			self assert: inspector documentPresenter model value
				equals: '''entry' , (index - 2) printString , '''']!

test_globalAdditionalAccelerators
	| remoteObject |
	remoteObject := session
				executeString: '$X'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	self assert: (self primaryTestWindow additionalAccelerators includes: #(#raiseConsole 'Ctrl+F7'))!

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
	self selectInstVarAtIndex: 2.
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
	self selectInstVarAtIndex: #(2).
	self assert: inspector instVarListPresenter selection key equals: '-.asOop'.
	self selectInstVarAtIndex: #(3).
	self assert: inspector instVarListPresenter selection key equals: '-_varyingSize'.
	self selectInstVarAtIndex: #(4).
	self assert: inspector instVarListPresenter selection key equals: '-_numEntries'.
	self selectInstVarAtIndex: #(5).
	self assert: inspector instVarListPresenter selection key equals: '-_indexedPaths'.
	self selectInstVarAtIndex: #(6).
	self assert: inspector instVarListPresenter selection key equals: '-_levels'.
	self selectInstVarAtIndex: #(7).
	self assert: inspector instVarListPresenter selection key equals: '-dict'.
	self selectInstVarAtIndex: #(8).
	self assert: inspector instVarListPresenter selection key equals: '-size'.
	self selectInstVarAtIndex: #(9).
	self assert: inspector instVarListPresenter selection key equals: '''abc'''.
	self assert: inspector instVarListPresenter list size equals: 9!

test_inspectBytes
	| remoteObject bytesInspector |
	remoteObject := session
				executeString: '''abcŠ'' copy'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	bytesInspector := inspector inspectBytes.
	
	[self assert: bytesInspector instVarListPresenter list size equals: 10.
	self assert: ('Inspector on ByteArray*' match: bytesInspector caption).
	self assert: bytesInspector documentPresenter value
		equals: 'aByteArray( 0, 97, 0, 98, 0, 99, 1, 96)'.
	bytesInspector instVarListPresenter selectionByIndex: 3.
	self assert: bytesInspector documentPresenter value equals: '0'.
	bytesInspector instVarListPresenter selectionByIndex: 4.
	self assert: bytesInspector documentPresenter value equals: '97'.
	bytesInspector instVarListPresenter selectionByIndex: 5.
	self assert: bytesInspector documentPresenter value equals: '0'.
	bytesInspector instVarListPresenter selectionByIndex: 6.
	self assert: bytesInspector documentPresenter value equals: '98'.
	bytesInspector instVarListPresenter selectionByIndex: 7.
	self assert: bytesInspector documentPresenter value equals: '0'.
	bytesInspector instVarListPresenter selectionByIndex: 8.
	self assert: bytesInspector documentPresenter value equals: '99'.
	bytesInspector instVarListPresenter selectionByIndex: 9.
	self assert: bytesInspector documentPresenter value equals: '1'.
	bytesInspector instVarListPresenter selectionByIndex: 10.
	self assert: bytesInspector documentPresenter value equals: '96']
			ensure: [self destroy: bytesInspector]!

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
	self assert: inspector documentPresenter value equals: '''aašb'''.
	self selectInstVarAtIndex: #(3).
	self assert: inspector documentPresenter value equals: '$a'.
	self selectInstVarAtIndex: #(4).
	self assert: inspector documentPresenter value equals: '$a'.
	self selectInstVarAtIndex: #(5).
	self assert: inspector documentPresenter value equals: '$š'.
	self selectInstVarAtIndex: #(6).
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
	self selectInstVarAtIndex: #(2).
	self assert: inspector instVarListPresenter selection key equals: '-.asOop'.
	self selectInstVarAtIndex: #(3).
	self assert: inspector instVarListPresenter selection key equals: '-_varyingSize'.
	self selectInstVarAtIndex: #(4).
	self assert: inspector instVarListPresenter selection key equals: '-_numEntries'.
	self selectInstVarAtIndex: #(5).
	self assert: inspector instVarListPresenter selection key equals: '-_indexedPaths'.
	self selectInstVarAtIndex: #(6).
	self assert: inspector instVarListPresenter selection key equals: '-_levels'.
	self selectInstVarAtIndex: #(7).
	self assert: inspector instVarListPresenter selection key equals: '''abc'''.
	self selectInstVarAtIndex: #(8).
	self assert: inspector instVarListPresenter selection key equals: '''abc'''.
	self assert: inspector instVarListPresenter list size equals: 8!

test_inspectInstVarInNewWindow
	| remoteObject secondInspector |
	self testsIssue: #issue720 withTitle: 'Would like inspect button in inspector'.
	remoteObject := session
				executeString: '(Array with: 123) dynamicInstVarAt: #foo put: ''abc''; yourself'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	self selectInstVarAtIndex: #(4).
	self assert: inspector documentPresenter value equals: '123'.
	secondInspector := inspector inspectInNewWindow.
	
	[self assert: secondInspector instVarListPresenter selectionByIndex equals: 1.
	self assert: secondInspector documentPresenter value equals: '123']
			ensure: [self closeBrowser: secondInspector].
	self selectInstVarAtIndex: #(3).
	self assert: inspector documentPresenter value equals: '''abc'''.
	secondInspector := inspector inspectInNewWindow.
	
	[self assert: secondInspector instVarListPresenter selectionByIndex equals: 1.
	self assert: secondInspector documentPresenter value equals: '''abc''']
			ensure: [self closeBrowser: secondInspector].
	self selectInstVarAtIndex: 2.
	self assert: inspector instVarListPresenter selections first key equals: '-.asOop'.
	secondInspector := inspector inspectInNewWindow.
	
	[self assert: secondInspector instVarListPresenter selectionByIndex equals: 1.
	self assert: secondInspector documentPresenter value equals: 'anArray( 123)']
			ensure: [self closeBrowser: secondInspector].
	self selectInstVarAtIndex: 1.
	self assert: inspector instVarListPresenter selections first key equals: 'self'.
	secondInspector := inspector inspectInNewWindow.
	
	[self assert: secondInspector instVarListPresenter selectionByIndex equals: 1.
	self assert: secondInspector documentPresenter value equals: 'anArray( 123)']
			ensure: [self closeBrowser: secondInspector]!

test_inspectInstVarKeyInNewWindow
	| remoteObject secondInspector |
	self testsIssue: #issue745
		withTitle: '(3.0.93) would be nice to be able to inspect the keys of a dictionary'.
	remoteObject := session
				executeString: 'Dictionary new at: #foo put: ''bar''; yourself'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	self selectInstVarAtIndex: #(8).
	secondInspector := inspector inspectKeyInNewWindow.
	
	[self assert: secondInspector instVarListPresenter selectionByIndex equals: 1.
	self assert: secondInspector documentPresenter value equals: '#''foo''']
			ensure: [self closeBrowser: secondInspector]!

test_inspectKeyMenuItemEnablementArray
	| remoteObject inspectKeyMenuItem query |
	self testsIssue: #issue745
		withTitle: '(3.0.93) would be nice to be able to inspect the keys of a dictionary'.
	remoteObject := session
				executeString: 'Array with: 1'
				fromContext: nil
				environment: 0.	"inspect key should never be enabled for an Array"
	inspector := JadeInspector showOn: remoteObject session: session.
	inspector instVarListPresenter setFocus.
	inspectKeyMenuItem := inspector instVarListPresenter view contextMenu items
				detect: [:menuItem | menuItem command = #inspectKeyInNewWindow].
	query := CommandQuery commandDescription: inspectKeyMenuItem source: inspector view.
	self deny: query isEnabled.
	self selectInstVarAtIndex: #(3).
	query := CommandQuery commandDescription: inspectKeyMenuItem source: inspector view.
	self deny: query isEnabled.
	self selectInstVarAtIndex: #(1).
	query := CommandQuery commandDescription: inspectKeyMenuItem source: inspector view.
	self deny: query isEnabled!

test_inspectKeyMenuItemEnablementDictionary
	| remoteObject inspectKeyMenuItem query |
	self testsIssue: #issue745
		withTitle: '(3.0.93) would be nice to be able to inspect the keys of a dictionary'.
	remoteObject := session
				executeString: 'Dictionary new at: #foo put: ''bar''; yourself'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	inspector instVarListPresenter setFocus.
	inspectKeyMenuItem := inspector instVarListPresenter view contextMenu items
				detect: [:menuItem | menuItem command = #inspectKeyInNewWindow].
	query := CommandQuery commandDescription: inspectKeyMenuItem source: inspector view.
	inspector queryCommand: query.
	self deny: query isEnabled.
	self selectInstVarAtIndex: #(8).	"association"
	inspector queryCommand: query.
	self assert: query isEnabled.
	self selectInstVarAtIndex: #(1).	"self"
	inspector queryCommand: query.
	self deny: query isEnabled.
	self selectInstVarAtIndex: #(1 2 3 4 5 6 7 8).	"self"
	inspector queryCommand: query.
	self deny: query isEnabled!

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
	self selectInstVarAtIndex: #(2).
	self assert: inspector documentPresenter value isKindOf: String]
			ensure: [self destroy: inspector].
	remoteObject := session
				executeString: 'Array with: RowanSample1 new'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	
	[self assert: ('Inspector on Array*' match: inspector caption).
	self selectInstVarAtIndex: #(3).
	self assert: ('Error inspecting object*' match: inspector documentPresenter value).	"should show the oop"
	self assert: ('*throw an error*' match: inspector documentPresenter value)	"must show underlying error"]
			ensure: [self destroy: inspector]!

test_inspectRcIdentityBag
	| remoteObject keys |
	remoteObject := session
				executeString: 'RcIdentityBag with: 1 with: ''abc'' with: $k'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	self assert: (inspector isKindOf: JadeiteInspector).
	self assert: inspector documentPresenter value equals: 'aRcIdentityBag( 1, $k, ''abc'')'.
	keys := (inspector instVarListPresenter list collect: [:ea | ea key]) asArray.
	self assert: (keys copyFrom: 1 to: 7)
		equals: #('self' '-.asOop' '-_varyingSize' '-_numEntries' '-_indexedPaths' '-_levels' '-components').
	"not sure about order in an identity bag. Might need to test differently"
	self assert: (keys copyFrom: 8 to: 10) asSortedCollection asArray
		equals: #('$k' '1' '''abc''' ). !

test_inspectRcIdentityBagWithUnicodeKey
	| remoteObject |
	remoteObject := session
				executeString: '| dbs bag |
dbs := ''a'', (String with: (Character withValue: 353)), ''b''.
bag := RcIdentityBag new. 
bag add: (''a'', dbs) asString.
bag'.
	inspector := JadeInspector showOn: remoteObject session: session.
	self assert: inspector documentPresenter value equals: 'aRcIdentityBag( ''aašb'')'.
	self selectInstVarAtIndex: #(8).
	self assert: inspector documentPresenter value equals: '''aašb'''!

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
	self selectInstVarAtIndex: #(2).
	self assert: inspector instVarListPresenter selection key equals: '-.asOop'.
	self selectInstVarAtIndex: #(3).
	self assert: inspector instVarListPresenter selection key equals: '-_varyingSize'.
	self selectInstVarAtIndex: #(4).
	self assert: inspector instVarListPresenter selection key equals: '-_numEntries'.
	self selectInstVarAtIndex: #(5).
	self assert: inspector instVarListPresenter selection key equals: '-_indexedPaths'.
	self selectInstVarAtIndex: #(6).
	self assert: inspector instVarListPresenter selection key equals: '-_levels'.
	self selectInstVarAtIndex: #(7).
	self assert: inspector instVarListPresenter selection key equals: '-dict'.
	self selectInstVarAtIndex: #(8).
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

	| answeringService inspectorCount |
	self testsIssue: #issue303 withTitle: 'Need to handle confirm:'.
	inspectorCount := JadeiteInspector allInstances size.
	answeringService := RowanAnsweringService new exec: 'UserGlobals inspect. nil' in: session.
	self assert: inspectorCount + 1 equals: JadeiteInspector allInstances size.
	"test that at least one is inspecting UserGlobals.
	Note - Opening a browser on a Test case will create an instance of JadeiteInspector
	even if all instances are closed. Therefore it's not straightforward to find our inspector. "
	JadeiteInspector allInstances copy do: 
			[:anInspector |
			('Inspector on SymbolDictionary for*' match: anInspector caption)
				ifTrue: 
					[
					[self assert: ('Inspector on SymbolDictionary for*' match: anInspector caption).
					self denyIsNil: (anInspector instVarListPresenter list
								detect: [:item | item key = '#''UserGlobals''']
								ifNone: [])]
							ensure: [self closeBrowser: anInspector]]]!

test_menuBarItemNames
	| remoteObject |
	self testsIssue: #issue194 withTitle: 'Oscar-3.0.40: Wodkspace window still uses `Jade` labels'.
	remoteObject := session
				executeString: '123'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	
	[self assert: inspector view menuBar items size equals: 2.
	self assert: (inspector view menuBar items at: 1) text equals: '&Edit'.
	self assert: (inspector view menuBar items at: 2) text equals: '&Jadeite']
			ensure: [self closeBrowser: inspector].
	remoteObject := session
				executeString: 'Array new'
				fromContext: nil
				environment: 0.	"navigation inspector"
	inspector := JadeInspector showOn: remoteObject session: session.
	self assert: inspector view menuBar items size equals: 2.
	self assert: (inspector view menuBar items at: 1) text equals: '&Edit'.
	self assert: (inspector view menuBar items at: 2) text equals: '&Jadeite'!

test_menuItemsEnabled
	| remoteObject |
	self testsIssue: #issue212 withTitle: '`Copy` menu item grayed out in inspector when text selected'.
	remoteObject := session
				executeString: 'Array with: 1'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	inspector documentPresenter setFocus.
	inspector documentPresenter view contextMenu itemsDo: 
			[:item |
			| query |
			query := CommandQuery commandDescription: item commandDescription
						source: inspector documentPresenter view.
			query commandSymbol
				ifNotNil: 
					[inspector queryCommand: query.
					(#(#undo #redo #browseImplementors #browseSenders #fileSave #editRevert) includes: query commandSymbol)
						ifFalse: 
							["*doesn't require a selection for enablement"
							self assert: query isEnabled]]]!

test_modifyArrayElement
	| remoteObject |
	self testsIssue: #issue104 withTitle: 'Inspector: be nice to be able to apply changes to the object'.
	remoteObject := session
				executeString: 'Array with: 1 with: ''abc'' with: $a'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	self selectInstVarAtIndex: #(3).	"select the 1st indexed element"
	inspector documentPresenter value: '2'.
	inspector saveDocument.
	self assert: inspector documentPresenter value equals: '2'.
	self selectInstVarAtIndex: #(4).
	self assert: inspector documentPresenter value equals: '''abc'''.
	self selectInstVarAtIndex: #(3).
	self assert: inspector documentPresenter value equals: '2'!

test_modifyDictionaryValue
	| remoteObject |
	self testsIssue: #issue104 withTitle: 'Inspector: be nice to be able to apply changes to the object'.
	remoteObject := session
				executeString: 'Dictionary new at: #foo put: #bar; yourself'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	self selectInstVarAtIndex: #(8).	"select key #foo"
	self assert: inspector documentPresenter value equals: '#''bar'''.
	inspector documentPresenter value: '#''blah'''.
	inspector saveDocument.
	self assert: inspector documentPresenter value equals: '#''blah'''.
	self assert: inspector instVarListPresenter selectionByIndex equals: 8.
	self selectInstVarAtIndex: 7.
	self selectInstVarAtIndex: 8.
	self assert: inspector documentPresenter value equals: '#''blah'''!

test_modifyDynamicInstVar
	| remoteObject |
	self testsIssue: #issue104 withTitle: 'Inspector: be nice to be able to apply changes to the object'.
	remoteObject := session
				executeString: 'Array new dynamicInstVarAt: #foo put: ''bar''; yourself'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	self selectInstVarAtIndex: #(3).	"select dynamic inst var #foo"
	self assert: inspector documentPresenter value equals: '''bar'''.
	inspector documentPresenter value: '''ooo'''.
	inspector saveDocument.
	self assert: inspector documentPresenter value equals: '''ooo'''.
	self selectInstVarAtIndex: #(2).
	self selectInstVarAtIndex: #(3).
	self assert: inspector documentPresenter value equals: '''ooo'''.
	self assert: (session
				executeString: '(self dynamicInstVarAt: #foo) = ''ooo'''
				fromContext: remoteObject
				environment: 0)!

test_modifyNamedInstVar
	| remoteObject |
	self testsIssue: #issue104 withTitle: 'Inspector: be nice to be able to apply changes to the object'.
	remoteObject := session
				executeString: 'Interval from: 1 to: 10'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	self selectInstVarAtIndex: #(5).	"select 'by' inst var"
	self assert: inspector documentPresenter value equals: '1'.
	inspector documentPresenter value: '2'.
	inspector saveDocument.
	self assert: inspector documentPresenter value equals: '2'.
	self selectInstVarAtIndex: #(4).	"select 'to' inst var"
	self assert: inspector documentPresenter value equals: '10'.
	self selectInstVarAtIndex: #(5).
	self assert: inspector documentPresenter value equals: '2'!

test_modifyOrderedCollectionElement
	| remoteObject |
	self testsIssue: #issue104 withTitle: 'Inspector: be nice to be able to apply changes to the object'.
	remoteObject := session
				executeString: 'OrderedCollection with: 1 with: ''abc'' with: $a'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	self selectInstVarAtIndex: #(3).	"select the 1st indexed element"
	inspector documentPresenter value: '2'.
	inspector saveDocument.
	self assert: inspector documentPresenter value equals: '2'.
	self selectInstVarAtIndex: #(4).
	self assert: inspector documentPresenter value equals: '''abc'''.
	self selectInstVarAtIndex: #(3).
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
	instVarPresenter selectionByIndex: 3.
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
	self selectInstVarAtIndex: #(2).	"asOop"
	self assert: inspector documentPresenter model value equals: '268']
			ensure: [self destroy: inspector].
	remoteObject := session
				executeString: 'false'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	self assert: (inspector isKindOf: JadeiteInspector).
	self assert: inspector documentPresenter model value equals: 'false'.
	self selectInstVarAtIndex: #(2).	"asOop"
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
	self selectInstVarAtIndex: #(2).	"asOop"
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
	self assert: inspector documentPresenter model value equals: '123.345'.
	self selectInstVarAtIndex: #(2).	"asOop"
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
	self selectInstVarAtIndex: #(2).	"asOop"
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
	self selectInstVarAtIndex: #(2).	"asOop"
	self assert: inspector documentPresenter model value equals: '986'!

test_openNavigationInspectorOnSymbol
	| remoteObject |
	self testsIssue: #issue398 withTitle: 'String Inspectors don''t display lfs'.
	remoteObject := session
				executeString: '#abc'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	self assert: (inspector isKindOf: JadeiteInspector).
	self assert: inspector documentPresenter model value equals: '#''abc'''.!

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

test_removeDynamicInstVar
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
	self selectInstVarAtIndex: 3.
	self assert: inspector documentPresenter value equals: '''bar'''.
	inspector basicRemoveDynamicInstVars.
	self assert: inspector instVarListPresenter selectionByIndex equals: 2.
	self assert: inspector instVarListPresenter selection key equals: '-.asOop'!

test_removeDynamicInstVarAndIndexedVar
	| remoteObject theIndex |
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
	inspector instVarListPresenter view selectionsByIndex: #(3 4).
	self assert: inspector documentPresenter value equals: '--foo: ''bar''
1: ''entry1'''.
	inspector basicRemoveObjects.
	self assert: inspector instVarListPresenter selectionByIndex equals: 4.
	self assert: inspector statusText equals: 'Displaying 49 of 49 variable inst vars'!

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
	self selectInstVarAtIndex: (Array with: firstKeyIndex).
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
	self selectInstVarAtIndex: #(3).
	self assert: inspector documentPresenter value equals: '''entry1'''.
	self assert: inspector statusText equals: 'Displaying 50 of 50 variable inst vars'.
	inspector basicRemoveObjectsAt: #(3).
	self assert: inspector instVarListPresenter selectionByIndex equals: 3.
	self assert: inspector documentPresenter value equals: '''entry2'''.
	self assert: inspector statusText equals: 'Displaying 49 of 49 variable inst vars'!

test_removeIndexedInstVars
	| remoteObject  |
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
	inspector instVarListPresenter view selectionsByIndex: #(3 4).
	self assert: inspector documentPresenter value equals: '1: ''entry1''
2: ''entry2'''.
	self assert: inspector statusText equals: 'Displaying 50 of 50 variable inst vars'.
	inspector basicRemoveObjectsAt: #(3 4).
	self assert: inspector instVarListPresenter selectionByIndex equals: 3.
	self assert: inspector documentPresenter value equals: '''entry3'''.
	self assert: inspector statusText equals: 'Displaying 48 of 48 variable inst vars'!

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
	self selectInstVarAtIndex: #(4).
	self assert: inspector documentPresenter value equals: '''entry1'''.
	self assert: inspector statusText equals: 'Displaying 50 of 50 variable inst vars'.
	inspector basicRemoveObjectsAt: #(5).
	self assert: inspector instVarListPresenter selectionByIndex equals: 5.
	self assert: inspector documentPresenter value equals: '''entry3'''.
	self assert: inspector statusText equals: 'Displaying 49 of 49 variable inst vars'!

test_removeItemDisabledForInstVars
	| remoteObject removeObjectItem query |
	remoteObject := session
				executeString: 'Set with: $a'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	self selectInstVarAtIndex: #(1).	"self"
	removeObjectItem := inspector instVarListPresenter view contextMenu items
				detect: [:item | item command = #removeObjects].
	query := CommandQuery commandDescription: removeObjectItem commandDescription source: inspector view.
	inspector queryCommand: query.
	self deny: query isEnabled.
	self selectInstVarAtIndex: #(2).	"-.asOop"
	inspector queryCommand: query.
	self deny: query isEnabled.
	3 to: 7
		do: 
			[:index |
			self selectInstVarAtIndex: (Array with: index).
			inspector queryCommand: query.
			self deny: query isEnabled].	"inst vars"
	self selectInstVarAtIndex: #(8).
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
	self selectInstVarAtIndex: #(1).	"self"
	removeObjectItem := inspector instVarListPresenter view contextMenu items
				detect: [:item | item command = #removeObjects].
	query := CommandQuery commandDescription: removeObjectItem commandDescription source: inspector view.
	inspector queryCommand: query.
	self deny: query isEnabled.
	self selectInstVarAtIndex: #(2).	"-.asOop"
	inspector queryCommand: query.
	self deny: query isEnabled.
	3 to: 5
		do: 
			[:index |
			self selectInstVarAtIndex: (Array with: index).
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
	self selectInstVarAtIndex: (Array with: inspector instVarListPresenter list size).
	self assert: inspector documentPresenter value equals: '''value9'''.
	inspector basicRemoveFromDictionary.
	self assert: inspector instVarListPresenter selectionByIndex
		equals: inspector instVarListPresenter list size.
	self assert: inspector documentPresenter value equals: '''value8'''!

test_removeLastElementOfSet
	| remoteObject previousSize |
	remoteObject := session
				executeString: 'Set with: 1'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	self selectInstVarAtIndex: (Array with: inspector instVarListPresenter list size).
	previousSize := inspector instVarListPresenter list size.
	inspector basicRemoveOop: inspector instVarListPresenter selection value.
	self assert: inspector instVarListPresenter list size equals: previousSize - 1.
	self assert: inspector model visibleIndices equals: 0.
	self assert: inspector instVarListPresenter selection key equals: '-dict'!

test_removeLastIndexedInstVar
	| remoteObject |
	remoteObject := session
				executeString: '
''abc'' copy '
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	self selectInstVarAtIndex: #(5).
	self assert: inspector documentPresenter value equals: '$c'.
	self assert: inspector statusText equals: 'Displaying 3 of 3 variable inst vars'.
	inspector basicRemoveObjectsAt: #(5).
	self assert: inspector instVarListPresenter selectionByIndex equals: 4.
	self assert: inspector documentPresenter value equals: '$b'.
	self assert: inspector statusText equals: 'Displaying 2 of 2 variable inst vars'!

test_removeLastIndexedInstVars
	| remoteObject theIndex |
	remoteObject := session
				executeString: '
''abc'' copy '
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	inspector instVarListPresenter view selectionsByIndex: #(4 5).
	self assert: inspector documentPresenter value equals: '2: $b
3: $c'.
	self assert: inspector statusText equals: 'Displaying 3 of 3 variable inst vars'.
	inspector basicRemoveObjectsAt: #(4 5).
	self assert: inspector instVarListPresenter selectionByIndex equals: 3.
	self assert: inspector documentPresenter value equals: '$a'.
	self assert: inspector statusText equals: 'Displaying 1 of 1 variable inst vars'!

test_removeMultipleFromDictionary
	| remoteObject firstKeyIndex theIndex index |
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
	inspector instVarListPresenter view selectionsByIndex: (Array with: firstKeyIndex with: firstKeyIndex + 1).
	self assert: inspector documentPresenter value equals: '''1'': ''value1''
''10'': ''value10'''.
	inspector basicRemoveFromDictionary.
	self assert: inspector instVarListPresenter selectionByIndex equals: firstKeyIndex.
	self assert: inspector documentPresenter value equals: '''value11'''!

test_replaceSetElement
	| remoteObject valuesSorted |
	self testsIssue: #issue104 withTitle: 'Inspector: be nice to be able to apply changes to the object'.
	remoteObject := session
				executeString: 'Set with: 1 with: ''abc'' with: $a'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	self selectInstVarAtIndex: #(8).	"select the 1st indexed element"
	inspector documentPresenter value: '$z'.
	inspector saveDocument.
	valuesSorted := (inspector instVarListPresenter list copyFrom: 8 to: 10) asSortedCollection.
	self assert: valuesSorted first key = '$a'.
	self assert: valuesSorted second key = '$z'.
	self assert: valuesSorted third key = '1'!

test_replaceSetElementWhichMovesAfterSave
	"ctrl-s will replace an element in a set"

	| remoteObject |
	self testsIssue: #issue104 withTitle: 'Inspector: be nice to be able to apply changes to the object'.
	remoteObject := session
				executeString: 'Set with: 1 with: ''abc'' with: $a'
				fromContext: nil
				environment: 0.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	self selectInstVarAtIndex: #(8).	"select the variable element"
	inspector documentPresenter value: '26'.
	inspector saveDocument.
	self assert: inspector documentPresenter value equals: '26'.
	self assert: inspector instVarListPresenter selectionByIndex equals: 10.
	self selectInstVarAtIndex: #(8).	"abc is now first in sorted list"
	self assert: inspector documentPresenter value equals: '$a'.
	self selectInstVarAtIndex: #(10).
	self assert: inspector documentPresenter value equals: '26'!

test_rootObjectNotOverwritten
	| remoteObject oop savedOop handle secondInspector lastOop firstOop |
	remoteObject := session
				executeString: 'Array new'
				fromContext: nil
				environment: 0.
	oop := remoteObject value.
	inspector := JadeInspector showOn: remoteObject session: session.
	handle := inspector view handle value.
	savedOop := session
				executeString: '((SessionTemps current at: #rowanServicesWindowRegistry) at: self) first asOop '
				fromContext: handle
				environment: 0.
	self assert: oop equals: savedOop.
	inspector documentPresenter value: 'OrderedCollection with: 1'.
	inspector codePane view setFocus.
	secondInspector := inspector codePane jadeInspect.
	
	[lastOop := session
				executeString: '((SessionTemps current at: #rowanServicesWindowRegistry) at: self) last asOop '
				fromContext: handle
				environment: 0.
	self assert: lastOop equals: inspector contextObject.
	firstOop := session
				executeString: '((SessionTemps current at: #rowanServicesWindowRegistry) at: self) last asOop '
				fromContext: handle
				environment: 0.
	self assert: firstOop equals: oop	"origin root object still held"]
			ensure: [self closeBrowser: secondInspector]!

test_selectAll
	| remoteObject |
	remoteObject := session
				executeString: '97'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	inspector instVarListPresenter view selectAll.
	self assert: inspector instVarListPresenter selections size equals: 2.
	self assert: inspector documentPresenter value equals: 'self: 97
-.asOop: 778'!

test_selectAllString
	| remoteObject |
	remoteObject := session
				executeString: '''abc'' copy'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	inspector instVarListPresenter view selectAll.
	self assert: inspector instVarListPresenter selections size equals: 5.
	self
		assert: ('self: ''abc''
-.asOop: *
1: $a
2: $b
3: $c' match: inspector documentPresenter value)!

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
	self assert: inspector documentPresenter model value
		equals: 'anArray( ''abc
def'')' replaceCrLfWithLf.
	self selectInstVarAtIndex: #(3).	"first element of array"
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
def''' replaceCrLfWithLf!

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
	self selectInstVarAtIndex: (Array with: inspector instVarListPresenter list size).
	self assert: inspector documentPresenter value equals: '''aašb''']
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
		equals: '''dašb''']
			ensure: [session executeString: 'UserGlobals removeKey: #aDict4']!

test_unicodeInspectCharacterKNOWNBROKEN
	| remoteObject |
	self rowanFixMe.	"KNOWN TO FAIL - Not sure why but the size passed to the gci call is 3 but the logical size is 2. Perhaps that is the problem. 
					However, this problem seems to be limited to `executeString:` which uses a direct gci call without going through STON before 
					going to the gci. Since (eventually) all server interactions will use services, this may be a moot point. Disabling but keeping
					test around as a reminder that this is broken. "
	true ifTrue:[^self]. 
	self testsIssue: #issue963
		withTitle: '[3.2.12] Filein/fileout need to behave correctly in the presence of Characters [128..254] and [255+]'.	"not exactly the issue, but need to connect the test to something"
	remoteObject := session executeString: '$Œ'.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	self assert: inspector instVarListPresenter selection key equals: 'self'.
	self assert: inspector documentPresenter value equals: '$Œ'.
	inspector instVarListPresenter selectionByIndex: 3.
	self assert: inspector documentPresenter value equals: '$Œ'!

test_unicodeInspectCharacterWithService
	| openInspectors |
	self testsIssue: #issue963
		withTitle: '[3.2.12] Filein/fileout need to behave correctly in the presence of Characters [128..254] and [255+]'.	"not exactly the issue, but need to connect the test to something"
	openInspectors := JadeiteInspector allInstances.
	RowanAnsweringService new exec: '$Œ inspect' in: session.
	inspector := (JadeiteInspector allInstances difference: openInspectors) first.
	self assert: inspector instVarListPresenter selection key equals: 'self'.
	self assert: inspector documentPresenter value equals: '$Œ'.
	self assert: inspector instVarListPresenter list size equals: 2.
	inspector instVarListPresenter selectionByIndex: 2.
	self assert: inspector instVarListPresenter selection key equals: '-.asOop'!

test_unicodeInspectStringWithCharacter
	| remoteObject |
	self testsIssue: #issue963
		withTitle: '[3.2.12] Filein/fileout need to behave correctly in the presence of Characters [128..254] and [255+]'.	"not exactly the issue, but need to connect the test to something"
	remoteObject := session executeString: '''$Œ'''.
	inspector := JadeiteInspector showOn: remoteObject session: session.
	self assert: inspector instVarListPresenter selection key equals: 'self'.
	self assert: inspector documentPresenter value equals: '''$Œ'''.
	inspector instVarListPresenter selectionByIndex: 3.
	self assert: inspector documentPresenter value equals: '$$'.
	inspector instVarListPresenter selectionByIndex: 4.
	self assert: inspector documentPresenter value equals: '$Œ'! !
!JadeiteInspectorDataCuratorTestCase categoriesForMethods!
commandQueryOn:!private! !
enableForward:andBack:!private! !
inspectInstVarAt:!private! !
primaryTestWindow!accessing!public! !
selectInstVarAtIndex:!private!tests add remove! !
setUp!private!setup teardown! !
tearDown!private!setup teardown! !
test_abortTransactionInBasicInspector!public!tests! !
test_abortTransactionInNavigationInspector!public!tests! !
test_addCharacterToString!public!tests add remove! !
test_addContextSensitiveObjectToDictionary!public!tests add remove! !
test_addObjectDontOverwriteExistingKey!public!tests add remove! !
test_addObjectToArray!public!tests add remove! !
test_addObjectToArrayWithDynamic!public!tests add remove! !
test_addObjectToDictionary!public!tests add remove! !
test_addStringToString!public!tests add remove! !
test_adHocExecution!public!tests! !
test_adHocInspect!public!tests! !
test_adHocInspectCompileError!public!tests! !
test_adHocInspectComplexObject!public!tests! !
test_adHocInspectFromWithinInspector!public!tests!tests menu bar! !
test_autoCommitInAdHocInspect!public!tests! !
test_autoCommitOffInAdHocInspect!public!tests! !
test_basicInspectorDisplayedSizeLimit!public! !
test_caption!public! !
test_captionChange!public! !
test_closeWithUnsavedChanges!public! !
test_commitTransactionInBasicInspector!public! !
test_commitTransactionInNavigationInspectorFocusCodePane!public! !
test_commitTransactionInNavigationInspectorFocusInstVars!public! !
test_compileErrorHandling!public!tests modify object! !
test_deselectClearsPane!public!tests menu bar! !
test_displayAll!public!tests menu bar! !
test_displayAllMenuEnablement!public!tests menu bar! !
test_displayMore!public!tests menu bar! !
test_displayMoreMenuEnablement!public!tests menu bar! !
test_dive!public! !
test_diveIntoDoubleByteString!public! !
test_dynamicInstVars!public! !
test_dynamicInstVarsInDictionary!public! !
test_fileSaveEnabled!public!tests menu bar! !
test_forwardBack!public! !
test_fullInspectArray!public! !
test_globalAdditionalAccelerators!public!tests! !
test_inspectAsOopField!public! !
test_inspectBag!public! !
test_inspectBytes!public!tests! !
test_inspectDoubleByteString!public! !
test_inspectIdentityBag!public! !
test_inspectInstVarInNewWindow!public!tests add remove! !
test_inspectInstVarKeyInNewWindow!public!tests add remove! !
test_inspectKeyMenuItemEnablementArray!public!tests menu bar! !
test_inspectKeyMenuItemEnablementDictionary!public!tests menu bar! !
test_inspectorHandlesError!public! !
test_inspectRcIdentityBag!public! !
test_inspectRcIdentityBagWithUnicodeKey!public! !
test_inspectRcQueue!public! !
test_inspectSet!public! !
test_inspectString!public! !
test_interactionInspect!public! !
test_menuBarItemNames!public!tests menu bar! !
test_menuItemsEnabled!public!tests menu bar! !
test_modifyArrayElement!public!tests modify object! !
test_modifyDictionaryValue!public!tests modify object! !
test_modifyDynamicInstVar!public!tests modify object! !
test_modifyNamedInstVar!public!tests modify object! !
test_modifyOrderedCollectionElement!public!tests modify object! !
test_navigationInspectorDisplayedSizeLimit!public!tests menu bar! !
test_openDictionaryBrowser!public! !
test_openDictionaryBrowserOnClass!public! !
test_openNavigationInspectorOnBoolean!public! !
test_openNavigationInspectorOnCharacter!public! !
test_openNavigationInspectorOnFloat!public! !
test_openNavigationInspectorOnNil!public! !
test_openNavigationInspectorOnSmallInteger!public! !
test_openNavigationInspectorOnSymbol!public! !
test_registeredPresentersInInspectorCleanedUp!public! !
test_removeDynamicInstVar!public!tests add remove! !
test_removeDynamicInstVarAndIndexedVar!public!tests add remove! !
test_removeFromDictionary!public!tests add remove! !
test_removeFromSymbolDictionary!public!tests add remove! !
test_removeIndexedInstVar!public!tests add remove! !
test_removeIndexedInstVars!public!tests add remove! !
test_removeIndexedInstVarWithDynamic!public!tests add remove! !
test_removeItemDisabledForInstVars!public!tests add remove! !
test_removeItemEnabled!public!tests add remove! !
test_removeLastElementFromDictionary!public!tests add remove! !
test_removeLastElementOfSet!public!tests add remove! !
test_removeLastIndexedInstVar!public!tests add remove! !
test_removeLastIndexedInstVars!public!tests add remove! !
test_removeMultipleFromDictionary!public!tests add remove! !
test_replaceSetElement!public!tests modify object! !
test_replaceSetElementWhichMovesAfterSave!public!tests modify object! !
test_rootObjectNotOverwritten!public! !
test_selectAll!public!tests!tests menu bar! !
test_selectAllString!public!tests!tests menu bar! !
test_showReturnsNavigationInspector!public!tests! !
test_showReturnsStringInspector!public!tests! !
test_unicodeInspect1!public!tests! !
test_unicodeInspect2!public!tests! !
test_unicodeInspectCharacterKNOWNBROKEN!public!tests! !
test_unicodeInspectCharacterWithService!public!tests! !
test_unicodeInspectStringWithCharacter!public!tests! !
!

