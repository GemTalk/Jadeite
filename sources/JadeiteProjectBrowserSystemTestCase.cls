"Filed out from Dolphin Smalltalk 7"!

JadeiteProjectBrowserAbstractTestCase subclass: #JadeiteProjectBrowserSystemTestCase
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteProjectBrowserSystemTestCase guid: (GUID fromString: '{f91d5582-0bb4-4c4e-866a-69bc4de30f87}')!
JadeiteProjectBrowserSystemTestCase comment: ''!
!JadeiteProjectBrowserSystemTestCase categoriesForClass!Unclassified! !
!JadeiteProjectBrowserSystemTestCase methodsFor!

test_addSystemTab
	self deselectProjects.
	self selectRowanSample1Class.
	self selectCategoryNamed: 'accessing'. 
	self selectMethodNamed: #foo.
	self assert: self projectListPresenter selection name equals: 'RowanSample1'.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Core'.
	self assert: self classListPresenter selection name equals: 'RowanSample1'.
	self assert: self categoryListPresenter selection equals: 'accessing'.
	self assert: self methodListPresenter selection selector equals: #foo.
	self projectsPresenter addSystemBrowser.
	self assert: self projectListPresenter selection name equals: 'RowanSample1'.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Core'.
	self assert: self classListPresenter selection name equals: 'RowanSample1'.
	self assert: self categoryListPresenter selection equals: 'accessing'.
	self assert: self methodListPresenter selection selector equals: #foo.
	projectsBrowser closeCard.
	"make sure previous card selections didn't change"
	self assert: self projectListPresenter selection name equals: 'RowanSample1'.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Core'.
	self assert: self classListPresenter selection name equals: 'RowanSample1'.
	self assert: self categoryListPresenter selection equals: 'accessing'.
	self assert: self methodListPresenter selection selector equals: #foo!

test_addSystemTabBrowserPosition
	"browser should not move to default position when tab is opened" 
	| newPosition |
	self testsIssue: #issue735
		withTitle: 'In multi-monitor setupt, inconsistent locations for opening windows (3.0.93-7)'.
	self assert: projectsBrowser view position
		equals: transcript view position + JadePresenter defaultWindowOffset.
	newPosition := projectsBrowser view position + (100 @ 100).
	projectsBrowser view position: newPosition.
	self deny: projectsBrowser view position
		equals: transcript view position + JadePresenter defaultWindowOffset.
	self assert: projectsBrowser view position equals: newPosition.
	self projectsPresenter addSystemBrowser.
	self assert: projectsBrowser view position equals: newPosition.
	projectsBrowser closeCard.
	self assert: projectsBrowser view position equals: newPosition!

test_addSystemTabClassSelection
	self deselectProjects.
	self selectRowanSample1Class.
	self assert: self projectListPresenter selection name equals: 'RowanSample1'.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Core'.
	self assert: self classListPresenter selection name equals: 'RowanSample1'.
	self deny: self classListPresenter selection meta.
	self projectsPresenter addSystemBrowser.
	self assert: self projectListPresenter selection name equals: 'RowanSample1'.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Core'.
	self assert: self classListPresenter selection name equals: 'RowanSample1'.
	self deny: self classListPresenter selection meta.
	projectsBrowser closeCard.
	"make sure previous card selections didn't change"
	self assert: self projectListPresenter selection name equals: 'RowanSample1'.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Core'.
	self assert: self classListPresenter selection name equals: 'RowanSample1'.
	self deny: self classListPresenter selection meta!

test_addSystemTabClassSelectionClassSide
	self deselectProjects.
	self selectRowanSample1Class.
	self selectClassTab.
	self selectCategoriesNamed: (Array with: '*rowansample1-extensions').
	self selectMethodNamed: #bar.
	self assert: self projectListPresenter selection name equals: 'RowanSample1'.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Core'.
	self assert: self classListPresenter selection name equals: 'RowanSample1'.
	self assert: self classListPresenter selection meta.
	self assert: self categoryListPresenter selection equals: '*rowansample1-extensions'.
	self assert: self methodListPresenter selection selector equals: #bar.
	self projectsPresenter addSystemBrowser.
	self assert: self projectListPresenter selection name equals: 'RowanSample1'.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Core'.
	self assert: self classListPresenter selection name equals: 'RowanSample1'.
	self assert: self classListPresenter selection meta.
	self assert: self categoryListPresenter selection equals: '*rowansample1-extensions'.
	self assert: self methodListPresenter selection selector equals: #bar.
	projectsBrowser closeCard.

	"make sure previous card selections didn't change"
	self assert: self projectListPresenter selection name equals: 'RowanSample1'.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Core'.
	self assert: self classListPresenter selection name equals: 'RowanSample1'.
	self assert: self classListPresenter selection meta.
	self assert: self categoryListPresenter selection equals: '*rowansample1-extensions'.
	self assert: self methodListPresenter selection selector equals: #bar!

test_addSystemTabNoSelections
	self deselectProjects.
	self assertIsNil: (self projectListPresenter selectionIfNone:[]).
	self assertIsNil: (self packageListPresenter selectionIfNone:[]).
	self assertIsNil: (self classListPresenter selectionIfNone:[]).
	self assertIsNil: (self categoryListPresenter selectionIfNone:[]).
	self assertIsNil: (self methodListPresenter selectionIfNone:[]).
	self projectsPresenter addSystemBrowser.
	self assertIsNil: (self projectListPresenter selectionIfNone:[]).
	self assertIsNil: (self packageListPresenter selectionIfNone:[]).
	self assertIsNil: (self classListPresenter selectionIfNone:[]).
	self assertIsNil: (self categoryListPresenter selectionIfNone:[]).
	self assertIsNil: (self methodListPresenter selectionIfNone:[]).
	projectsBrowser closeCard.
	"make sure previous card selections didn't change"
	self assertIsNil: (self projectListPresenter selectionIfNone:[]).
	self assertIsNil: (self packageListPresenter selectionIfNone:[]).
	self assertIsNil: (self classListPresenter selectionIfNone:[]).
	self assertIsNil: (self categoryListPresenter selectionIfNone:[]).
	self assertIsNil: (self methodListPresenter selectionIfNone:[]).!

test_browserPosition
	self testsIssue: #issue735
		withTitle: 'In multi-monitor setupt, inconsistent locations for opening windows (3.0.93-7)'.
	self assert: projectsBrowser view position
		equals: transcript view position + JadePresenter defaultWindowOffset!

test_deselectProjectOnly
	"make sure it updates the tab label"

	self deselectProjects.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text equals: '1 Projects'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text equals: '1 Rowan'.
	self deselectProjects.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text equals: '1 Projects'!

test_modifiedSystemTab
	| cardLabel |
	self testsIssue: #issue584 withTitle: 'Would like changed method indicator on tab'.
	self selectRowanSample1Class.
	self selectCategoryNamed: 'accessing'.
	self selectMethodNamed: #foo.
	cardLabel := projectsBrowser cardsPresenter view currentCard arrangement.
	self assert: cardLabel text equals: '1 RowanSample1'.
	self methodSourcePresenter value: 'foo ^''foot'''.
	self methodSourcePresenter view isModified: true.
	self methodSourcePresenter trigger: #valueChanged.
	cardLabel := projectsBrowser cardsPresenter view currentCard arrangement.
	self assert: (cardLabel isKindOf: CardLabel).
	self assert: cardLabel iconBlock value isKindOf: Icon.
	self assert: cardLabel iconBlock value identifier equals: 'Changed.ico'.	" showing changed icon "
	self
		saveMethod: 'foo ^''foot'''
		in: 'RowanSample1'
		category: 'accessing'.
	self methodSourcePresenter view isModified: false.
	self methodSourcePresenter trigger: #valueChanged.
	cardLabel := projectsBrowser cardsPresenter view currentCard arrangement.
	self assert: cardLabel text equals: '1 RowanSample1'!

test_moveTabsWithSUnitTabselected
	self testsIssue: #issue556 withTitle: 'Funny orange boxes enabled for Sunit tab, but error'.
	projectsBrowser closeCard.
	projectsBrowser addSystemBrowser.
	self selectSUnitTab.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text equals: '1 Projects'.
	projectsBrowser addSystemBrowser.
	self assert: projectsBrowser cardsPresenter view cards size equals: 2.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text equals: '2 Projects'.
	self selectRowanSample1Class.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text
		equals: '2 RowanSample1'.
	projectsBrowser moveCardLeft.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text
		equals: '2 RowanSample1'.
	self assert: projectsBrowser cardsPresenter view cards size equals: 2.
	projectsBrowser moveCardRight.
	self assert: projectsBrowser cardsPresenter view cards size equals: 2.
	projectsBrowser closeCard.
	self assert: projectsBrowser cardsPresenter view cards size equals: 1.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text equals: '1 Projects'!

test_systemTabNamesDictionaryClass
	self testsIssue: #issue381
		withTitle: '(3.0.53) useful to have class displayed when code pane is maximized'.
	self deselectProjects.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text equals: '1 Projects'.
	self selectNoneProject.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text equals: '1 (NONE)'.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text
		equals: '1 UserGlobals'.
	self selectServiceNamed: 'JadeServer' in: self classListPresenter.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text equals: '1 JadeServer'!

test_systemTabNamesDictionaryClassHierarchy
	self testsIssue: #issue381
		withTitle: '(3.0.53) useful to have class displayed when code pane is maximized'.
	self deselectProjects.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text equals: '1 Projects'.
	self selectNoneProject.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text equals: '1 (NONE)'.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text
		equals: '1 UserGlobals'.
	self selectHierarchyTab.
	self selectClassInHierarchyNamed: 'JadeServer'.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text equals: '1 JadeServer'!

test_systemTabNamesProjectClassHierarchy
	self testsIssue: #issue381
		withTitle: '(3.0.53) useful to have class displayed when code pane is maximized'.
	self deselectProjects.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text equals: '1 Projects'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text
		equals: '1 RowanSample1'.
	self selectServiceNamed: 'RowanSample1-Core' in: self packageListPresenter.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text
		equals: '1 RowanSample1-Core'.
	self selectHierarchyTab.
	self selectClassInHierarchyNamed: 'RowanSample1'.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text
		equals: '1 RowanSample1'!

test_systemTabNamesProjectClassList
	self testsIssue: #issue381
		withTitle: '(3.0.53) useful to have class displayed when code pane is maximized'.
	self deselectProjects.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text equals: '1 Projects'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text
		equals: '1 RowanSample1'.
	self selectServiceNamed: 'RowanSample1-Core' in: self packageListPresenter.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text
		equals: '1 RowanSample1-Core'.
	self selectServiceNamed: 'RowanSample1' in: self classListPresenter.
	self assert: projectsBrowser cardsPresenter view currentCard arrangement text
		equals: '1 RowanSample1'! !
!JadeiteProjectBrowserSystemTestCase categoriesFor: #test_addSystemTab!public!test system tabs! !
!JadeiteProjectBrowserSystemTestCase categoriesFor: #test_addSystemTabBrowserPosition!public!test system tabs! !
!JadeiteProjectBrowserSystemTestCase categoriesFor: #test_addSystemTabClassSelection!public!test system tabs! !
!JadeiteProjectBrowserSystemTestCase categoriesFor: #test_addSystemTabClassSelectionClassSide!public!test system tabs! !
!JadeiteProjectBrowserSystemTestCase categoriesFor: #test_addSystemTabNoSelections!public!test system tabs! !
!JadeiteProjectBrowserSystemTestCase categoriesFor: #test_browserPosition!public!test system tabs! !
!JadeiteProjectBrowserSystemTestCase categoriesFor: #test_deselectProjectOnly!public!test system tabs! !
!JadeiteProjectBrowserSystemTestCase categoriesFor: #test_modifiedSystemTab!public!test system tabs! !
!JadeiteProjectBrowserSystemTestCase categoriesFor: #test_moveTabsWithSUnitTabselected!public!test system tabs! !
!JadeiteProjectBrowserSystemTestCase categoriesFor: #test_systemTabNamesDictionaryClass!public!test system tabs! !
!JadeiteProjectBrowserSystemTestCase categoriesFor: #test_systemTabNamesDictionaryClassHierarchy!public!test system tabs! !
!JadeiteProjectBrowserSystemTestCase categoriesFor: #test_systemTabNamesProjectClassHierarchy!public!test system tabs! !
!JadeiteProjectBrowserSystemTestCase categoriesFor: #test_systemTabNamesProjectClassList!public!test system tabs! !

