"Filed out from Dolphin Smallalk"!

JadeiteAbstractTestCase subclass: #JadeiteMethodHistoryTestCase
	instanceVariableNames: 'methodHistoryBrowser'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteMethodHistoryTestCase guid: (GUID fromString: '{3d1e5e26-f82e-401c-871c-e6098811af2f}')!
JadeiteMethodHistoryTestCase comment: ''!
!JadeiteMethodHistoryTestCase categoriesForClass!Unclassified! !
!JadeiteMethodHistoryTestCase methodsFor!

removeMethodHistoryFor: methodService
	"assume method service is selected"

	| answeringService |
	answeringService := RowanAnsweringService new
				command: #removeMethodHistoryFor:;
				commandArgs: (Array with: self methodListPresenter selections first);
				yourself.
	JadePresenter issueCommands: (Array with: answeringService) session: session.
	self projectsPresenter removeMethods: (Array with: self projectsPresenter selectedClass)!

tearDown
	super tearDown.
	methodHistoryBrowser ifNotNil: [methodHistoryBrowser view close]!

test_dontAddToHistoryIfIdenticalSource
	"we were incrementing the history gui when a method 
	was selected. That made it look like the history was bigger
	than it really was"

	self setupProjectBrowser.
	self selectRowanSample1Class.
	self
		saveMethod: 'test_openMethodHistory  ^1'
		in: 'RowanSample1'
		category: 'other'.
	
	[self selectMethodNamed: #test_openMethodHistory.
	methodHistoryBrowser := self projectsPresenter browseMethodHistory.
	self assert: methodHistoryBrowser source equals: 'test_openMethodHistory  ^1'.
	self assert: methodHistoryBrowser slider value equals: 2.
	self assert: methodHistoryBrowser slider view isEnabled.
	self assert: methodHistoryBrowser history size equals: 2.
	10 timesRepeat: 
			[self selectRowanSample1Class.	"will deselect method"
			self selectMethodNamed: #test_openMethodHistory.
			self assert: methodHistoryBrowser history size equals: 2]]
			ensure: [self removeMethodHistoryFor: self methodListPresenter selections first]!

test_openMethodHistory
	self setupProjectBrowser.
	self selectRowanSample1Class.
	self
		saveMethod: 'test_openMethodHistory  ^1'
		in: 'RowanSample1'
		category: 'other'.
	
	[self selectMethodNamed: #test_openMethodHistory.
	methodHistoryBrowser := self projectsPresenter browseMethodHistory.
	self assert: methodHistoryBrowser source equals: 'test_openMethodHistory  ^1'.
	self assert: methodHistoryBrowser slider value equals: 2.
	self assert: methodHistoryBrowser slider view isEnabled]
			ensure: [self removeMethodHistoryFor: self methodListPresenter selections first]!

test_openMethodHistoryWithHistory
	| newSource |
	self setupProjectBrowser.
	self selectRowanSample1Class.
	self selectMethodNamed: #foo.
	newSource := 'foo



^1'.
	self
		saveMethod: newSource
		in: 'RowanSample1'
		category: 'other'.
	methodHistoryBrowser := self projectsPresenter browseMethodHistory.
	self assert: methodHistoryBrowser source equals: newSource.
	self assert: methodHistoryBrowser slider value equals: methodHistoryBrowser history size.
	self assert: methodHistoryBrowser slider view isEnabled.
	methodHistoryBrowser moveTo: 1.
	self assert: methodHistoryBrowser source equals: 'foo ^''foo'''!

test_sliderClick
	self setupProjectBrowser.
	self selectRowanSample1Class.
	self
		saveMethod: 'test_sliderClick  ^1'
		in: 'RowanSample1'
		category: 'other'.
	self
		saveMethod: 'test_sliderClick  ^2'
		in: 'RowanSample1'
		category: 'other'.
	
	[self selectMethodNamed: #test_sliderClick.
	methodHistoryBrowser := self projectsPresenter browseMethodHistory.
	self assert: methodHistoryBrowser source equals: 'test_sliderClick  ^2'.
	self assert: methodHistoryBrowser slider view isEnabled.
	"pretend the user has clicked on the slider directly"
	methodHistoryBrowser slider view selectionRange: (1 to: 1).	"for visual coorination with model"
	methodHistoryBrowser slider view displayValue: 1.
	methodHistoryBrowser slider model value: 1.	"trigger a #valueChanged event"
	self assert: methodHistoryBrowser source equals: 'test_sliderClick  ^1']
			ensure: [self removeMethodHistoryFor: self methodListPresenter selections first]!

test_updateAfterMethodCompile
	self setupProjectBrowser.
	self selectRowanSample1Class.
	self
		saveMethod: 'test_sliderClick  ^1'
		in: 'RowanSample1'
		category: 'other'.
	self
		saveMethod: 'test_sliderClick  ^2'
		in: 'RowanSample1'
		category: 'other'.
	
	[self selectMethodNamed: #test_sliderClick.
	methodHistoryBrowser := self projectsPresenter browseMethodHistory.
	methodHistoryBrowser moveTo: 1.
	self assert: methodHistoryBrowser source equals: 'test_sliderClick  ^1'.
	self assert: methodHistoryBrowser history size equals: 3.
	self
		saveMethod: 'test_sliderClick  ^3'
		in: 'RowanSample1'
		category: 'other'.
	self assert: methodHistoryBrowser history size equals: 4.
	self assert: methodHistoryBrowser selection equals: 1	"stay on selection but update the view with the new method"]
			ensure: [self removeMethodHistoryFor: self methodListPresenter selections first]! !
!JadeiteMethodHistoryTestCase categoriesForMethods!
removeMethodHistoryFor:!public!support! !
tearDown!public!setup teardown! !
test_dontAddToHistoryIfIdenticalSource!public!tests! !
test_openMethodHistory!public!tests! !
test_openMethodHistoryWithHistory!public!tests! !
test_sliderClick!public!tests! !
test_updateAfterMethodCompile!public!tests! !
!

