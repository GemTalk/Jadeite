"Filed out from Dolphin Smalltalk 7"!

JadeiteAbstractTestCase subclass: #JadeiteDictionaryBrowserTestCase
	instanceVariableNames: 'dictionaryBrowser'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteDictionaryBrowserTestCase guid: (GUID fromString: '{3d66b039-3986-43f7-9e95-6a137a1473f7}')!
JadeiteDictionaryBrowserTestCase comment: ''!
!JadeiteDictionaryBrowserTestCase categoriesForClass!Unclassified! !
!JadeiteDictionaryBrowserTestCase methodsFor!

primaryPresenter
	^dictionaryBrowser currentCard!

selectClass: className
	| classPresenter selection |
	classPresenter := self primaryPresenter classListPresenter.
	classPresenter resetSelection.
	selection := classPresenter list detect: [:string | string = className]
				ifNone: [self error: 'Class ' , className , ' not found'].
	classPresenter selection: selection!

selectDictionary: dictionaryName
	| dictionaryPresenter selection |
	dictionaryPresenter := self primaryPresenter dictionaryListPresenter.
	dictionaryPresenter resetSelection.
	selection := dictionaryPresenter list detect: [:assoc | assoc key = dictionaryName]
				ifNone: [self error: 'Dictionary ' , dictionaryName , ' not found'].
	dictionaryPresenter selection: selection!

selectMethod: selector
	| methodListPresenter selection |
	methodListPresenter := self primaryPresenter methodListPresenter.
	methodListPresenter resetSelection.
	selection := methodListPresenter list detect: [:assoc | assoc first = selector]
				ifNone: [self error: 'Method ' , selector , ' not found'].
	methodListPresenter selection: selection!

selectWellKnownMethod
	"select some method in the method list pane"
	self selectDictionary: 'Globals'. 
	self selectClass: 'Behavior'. 
	self selectMethod: 'basicNew'. 
!

setUp
	super setUp.
	dictionaryBrowser := self openWindow: [transcript openDictionaryBrowser]!

tearDown
	super tearDown.
	dictionaryBrowser ifNotNil: [dictionaryBrowser destroy]!

test_browseReferences
	| methodBrowser |
	self testsIssue: #issue350
		withTitle: 'Browse references from dictionary browser doesn''t show anything'.
	self selectDictionary: 'Globals'.
	self selectClass: 'SessionTemps'.
	methodBrowser := dictionaryBrowser currentCard browseClassReferences.
	
	[self assert: (methodBrowser isKindOf: JadeiteMethodListBrowser).	"<<< bug was that no action was taken. Should get a browser back"
	self assert: ('Jadeite Method List Browser*' match: methodBrowser caption)]
			ensure: [methodBrowser destroy].
	dictionaryBrowser currentCard classHierarchyTabs lastCard.
	methodBrowser := dictionaryBrowser currentCard browseClassReferences.
	
	[self assert: (methodBrowser isKindOf: JadeiteMethodListBrowser).
	self assert: ('Jadeite Method List Browser*' match: methodBrowser caption)	"<<< bug was that no action was taken. Should get a browser back"]
			ensure: [methodBrowser destroy]!

test_browseReferencesInDictionaryBrowser
	| methodListBrowser source |
	self selectDictionary: 'Globals'.
	self selectClass: 'Date'.
	methodListBrowser := self primaryPresenter browseClassReferences.
	
	[source := methodListBrowser primaryPresenter methodSourcePresenter documentPresenter value.
	self assert: ('*Date*' match: source)]
			ensure: [methodListBrowser destroy]!

test_findClass
	| methodListSize unopenedDialog |
	self testsIssue: #issue430 withTitle: '(3.0.60) Find Class in system browser recently broken'.
	self selectDictionary: 'RowanKernel'.
	self selectClass: 'RowanAnsweringService'.
	unopenedDialog := JadeFindClassDialog create: 'ThreeColumnView' on: dictionaryBrowser currentCard findClassList.
	[self assert: unopenedDialog classListPresenter list size equals: dictionaryBrowser currentCard findClassList size] ensure: [unopenedDialog destroy]!

test_menusDontAddBreaks
	"not a great test, but make sure we don't add a breakpoint menu item in 
	the menu bar"

	| menuBar jadeMenu methodsMenu |
	self testsIssue: #issue162 withTitle: 'In method list browser, get new breakpoint menu items'.
	menuBar := dictionaryBrowser view menuBar.
	jadeMenu := self itemNamed: 'Jade' in: menuBar.
	methodsMenu := self itemNamed: 'Methods' in: menuBar.
	self noBreakIn: jadeMenu.
	self noBreakIn: methodsMenu.
	self selectWellKnownMethod.	"the method we're testing requires a selection"
	self primaryPresenter methodMenuBreak: jadeMenu.
	self primaryPresenter methodMenuBreak: methodsMenu.
	self noBreakIn: jadeMenu.
	self noBreakIn: methodsMenu!

test_selectTestClass
	self testsIssue: #issue177 withTitle: 'Dictionary browser error/s'.
	self selectDictionary: 'RowanKernel'.
	self selectClass: 'RwBrowserToolApiTest'.	"<<< walkback occurred here"
	self assert: self primaryPresenter classListPresenter selection equals: 'RwBrowserToolApiTest'! !
!JadeiteDictionaryBrowserTestCase categoriesFor: #primaryPresenter!private! !
!JadeiteDictionaryBrowserTestCase categoriesFor: #selectClass:!private!selection! !
!JadeiteDictionaryBrowserTestCase categoriesFor: #selectDictionary:!private!selection! !
!JadeiteDictionaryBrowserTestCase categoriesFor: #selectMethod:!private!selection! !
!JadeiteDictionaryBrowserTestCase categoriesFor: #selectWellKnownMethod!private!selection! !
!JadeiteDictionaryBrowserTestCase categoriesFor: #setUp!private!setup teardown! !
!JadeiteDictionaryBrowserTestCase categoriesFor: #tearDown!private!setup teardown! !
!JadeiteDictionaryBrowserTestCase categoriesFor: #test_browseReferences!public!test! !
!JadeiteDictionaryBrowserTestCase categoriesFor: #test_browseReferencesInDictionaryBrowser!public!test! !
!JadeiteDictionaryBrowserTestCase categoriesFor: #test_findClass!public!test! !
!JadeiteDictionaryBrowserTestCase categoriesFor: #test_menusDontAddBreaks!public!test!test menus! !
!JadeiteDictionaryBrowserTestCase categoriesFor: #test_selectTestClass!public!test! !

