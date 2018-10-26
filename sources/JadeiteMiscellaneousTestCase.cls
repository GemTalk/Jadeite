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
	symbols do: [:symbol | self assert: ('*SymbolDict*:' match: symbol ignoreCase: true)]! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_convertToPattern!public!test! !
!JadeiteMiscellaneousTestCase categoriesFor: #test_symbolsFromSelector!public!test! !

