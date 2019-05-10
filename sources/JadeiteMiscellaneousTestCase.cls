"Filed out from Dolphin Smalltalk 7"!

JadeiteAbstractTestCase subclass: #JadeiteMiscellaneousTestCase
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteMiscellaneousTestCase guid: (GUID fromString: '{3f3dd3e4-13f5-42ea-b424-b89439a9b357}')!
JadeiteMiscellaneousTestCase comment: ''!
!JadeiteMiscellaneousTestCase categoriesForClass!Unclassified! !
!JadeiteMiscellaneousTestCase methodsFor!

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
	self assert: (session executeString: 'System hiddenSetSize: 39') equals: 0!

test_symbolsFromSelector
	| symbols wildAtFrontSymbols |
	self testsIssue: #issue258
		withTitle: 'wildcard senders and implentors don''t return proper selection list'.
	wildAtFrontSymbols := JadePresenter symbolsFrom: '*symboldict*' session: session.
	self assert: wildAtFrontSymbols notEmpty.
	wildAtFrontSymbols do: [:symbol | self assert: ('*symboldict*' match: symbol ignoreCase: true)].
	symbols := JadePresenter symbolsFrom: 'symboldict*' session: session.
	self assert: symbols size < wildAtFrontSymbols size. "should be a subset without the front asterix"
	self assert: symbols notEmpty.
	symbols do: [:symbol | self assert: ('symboldict*' match: symbol ignoreCase: true)].
	"ignore case"
	wildAtFrontSymbols := JadePresenter symbolsFrom: '*SymbolDict*' session: session.
	self assert: wildAtFrontSymbols notEmpty.
	wildAtFrontSymbols do: [:symbol | self assert: ('*SymbolDict*' match: symbol ignoreCase: true)].
	symbols := JadePresenter symbolsFrom: '*SymbolDict*:' session: session.
	self assert: symbols size < wildAtFrontSymbols size. "should be a subset without the front asterix"
	self assert: symbols notEmpty.
	symbols do: [:symbol | self assert: ('*SymbolDict*:' match: symbol ignoreCase: true)]!

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
				projectsBrowser destroy]!

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
!JadeiteMiscellaneousTestCase categoriesFor: #test_adHocDisplay!public! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_adHocExecute!public! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_autoCommitInAdHocDisplay!public! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_autoCommitInAdHocExecution!public! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_autoCommitOffInAdHocDisplay!public! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_autoCommitOffInAdHocExecution!public! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_convertToPattern!public!test! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_dolphinStackDumpBanners!public!test! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_releaseOops!public! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_symbolsFromSelector!public!test! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_workspaceBrowseProjects!public!test!test menus! !
!JadeiteMiscellaneousTestCase categoriesFor: #testClassServiceNameIsString!public! !
!JadeiteMiscellaneousTestCase categoriesFor: #testMethodServiceClassNameIsString!public! !

