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
	workspace := JadeWorkspace showOnSession: session.
	
	[jadeiteMenu := self itemNamed: 'Jadeite' in: workspace view menuBar.
	browseProjectsItem := self itemNamed: 'Browse Projects' in: jadeiteMenu.
	projectsBrowser := browseProjectsItem commandDescription performAgainst: workspace]
			ensure: 
				[workspace view close.
				projectsBrowser view close]! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_convertToPattern!public!test! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_dolphinStackDumpBanners!public!test! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_symbolsFromSelector!public!test! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_workspaceBrowseProjects!public!test! !

