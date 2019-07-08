"Filed out from Dolphin Smalltalk 7"!

JadeiteProjectBrowserAbstractTestCase subclass: #JadeiteProjectBrowserDictionaryTestCase
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteProjectBrowserDictionaryTestCase guid: (GUID fromString: '{a61bd899-d4eb-426b-ad96-8310f15a0ec1}')!
JadeiteProjectBrowserDictionaryTestCase comment: ''!
!JadeiteProjectBrowserDictionaryTestCase categoriesForClass!Unclassified! !
!JadeiteProjectBrowserDictionaryTestCase methodsFor!

test_abortInTranscriptRemovesDictionaryInBrowser
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	self projectsPresenter basicAddDictionaryNamed: 'Test_Abort'.
	self denyIsNil: (self dictionaryPresenter list
				detect: [:dictionaryService | dictionaryService name = 'Test_Abort']
				ifNone: []).
	transcript toolbarPresenter abort.
	
	[self assertIsNil: (self dictionaryPresenter list
				detect: [:dictionaryService | dictionaryService name = 'Test_Abort']
				ifNone: [])]
			ensure: 
				[self cloneRowanSample1.
				self ensureRowanSample1Loaded]!

test_addDictionary
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.
	self projectsPresenter basicAddDictionaryNamed: 'Test_addDictionary'.
	self assert: (self dictionaryPresenter list at: 2) name equals: 'Test_addDictionary'.
	self assert: self dictionaryPresenter selection name equals: 'Test_addDictionary'.
	self abortTransaction.
	
	[self assertIsNil: (self dictionaryPresenter list
				detect: [:dictionaryService | dictionaryService name = 'Test_addDictionary']
				ifNone: [])]
			ensure: 
				[self cloneRowanSample1.
				self ensureRowanSample1Loaded]!

test_dictionaryNameIsString
	"for consistency, service names should be strings"
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.
	self assert: (self dictionaryPresenter selection name isKindOf: String).!

test_dictionarySelectionChangesTab
	| browserTabs |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	browserTabs := projectsBrowser cardsPresenter view.
	self selectNoneProject.
	self assert: browserTabs currentCard arrangement equals: '1 ' , RowanProjectService noneProject name.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.
	self assert: browserTabs currentCard arrangement equals: '1 UserGlobals'.
	self projectListPresenter resetSelection.
	self assert: browserTabs currentCard arrangement equals: '1 Projects'!

test_dictionarySelectionIndependentInTab
	| userGlobalsCard |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.
	userGlobalsCard := projectsBrowser cardsPresenter view currentCard.
	projectsBrowser addSystemBrowser.
	
	[self assert: userGlobalsCard presenter projectListPresenter selection name
		equals: RowanProjectService noneProject name.
	self selectNoneProject.
	self selectServiceNamed: 'Published' in: self dictionaryPresenter.
	self assert: userGlobalsCard presenter projectListPresenter selection name
		equals: RowanProjectService noneProject name]
			ensure: [projectsBrowser closeCard]!

test_dictionaryViewClassHierarchy
	| classNames |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	self selectServiceNamed: 'RowanKernel' in: self dictionaryPresenter.
	classNames := self classListPresenter list collect: [:classService | classService name].
	self selectHierarchyTab.
	
	[self assert: (self classHierarchyPresenter model isKindOf: TreeModel).
	classNames do: 
			[:className |
			self denyIsNil: (self classHierarchyPresenter model asBag
						detect: [:classService | classService name = className]
						ifNone: [])]]
			ensure: [self selectClassListTab]!

test_dictionaryViewClassHierarchySelectedClass
	| firstChild root children |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	self selectServiceNamed: 'RowanKernel' in: self dictionaryPresenter.
	self selectServiceNamed: 'GsChoiceInteraction' in: self classListPresenter.
	self selectHierarchyTab.
	
	[self assert: self classHierarchyPresenter model size equals: 3.
	#('Object' 'GsInteraction' 'GsChoiceInteraction') do: 
			[:className |
			self denyIsNil: (self classHierarchyPresenter model asBag
						detect: [:classService | classService name = className]
						ifNone: [])].
	self assert: self classHierarchyPresenter model roots size equals: 1.
	self assert: self classHierarchyPresenter model roots first name equals: 'Object'.
	root := self classHierarchyPresenter model roots first.
	self assert: (children := self classHierarchyPresenter model getChildrenOf: root) size equals: 1.
	firstChild := children first.
	self assert: firstChild name equals: 'GsInteraction'.
	self assert: (children := self classHierarchyPresenter model getChildrenOf: firstChild) size
		equals: 1.
	self assert: children size equals: 1.
	self assert: children first name equals: 'GsChoiceInteraction']
			ensure: [self selectClassListTab]!

test_findClassNotInProject
	"we no longer open the old dictionary browser"

	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self projectsPresenter updateAfterFindClass: (RowanClassService new name: 'Object').
	self assert: self classListPresenter selection name equals: 'Object'.
	self assert: self dictionaryPresenter selection name equals: 'Globals'.
	self assert: self projectListPresenter selection name equals: RowanProjectService noneProject name.
	self assert: self projectsPresenter isNoneProjectSelected.
	self projectsPresenter updateAfterFindClass: (RowanClassService new name: 'ExecBlock').
	self assert: self classListPresenter selection name equals: 'ExecBlock'.
	self assert: self dictionaryPresenter selection name equals: 'Globals'.
	self assert: self projectListPresenter selection name equals: RowanProjectService noneProject name.
	self assert: self projectsPresenter isNoneProjectSelected.
	self projectsPresenter updateAfterFindClass: (RowanClassService new name: 'CypressClassDefinition').
	self assert: self classListPresenter selection name equals: 'CypressClassDefinition'.
	self assert: self classListPresenter selection definedPackageName equals: 'Cypress-Definitions'.
	self assert: self packageListPresenter selection name equals: 'Cypress-Definitions'.
	self assert: self projectListPresenter selection name equals: 'Cypress'.
	self deny: self projectsPresenter isNoneProjectSelected!

test_firstClickDictionaries
	"make sure the first click on the (NONE) project shows the dictionaries"
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self assert: self dictionaryPresenter list isEmpty.
	self selectNoneProject.
	self assert: self dictionaryPresenter list notEmpty!

test_globalRemove
	| removeGlobalItem selection |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	removeGlobalItem := self projectsPresenter globalsTab view contextMenu items
				detect: [:item | item text = 'Remove Global'].
	self assert: removeGlobalItem command equals: #removeGlobal.
	session executeString: 'UserGlobals at: #test_removeGlobal put: ''foo'''.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.
	selection := self projectsPresenter globalsTab list
				detect: [:array | (array at: 1) equals: 'UserGlobals.test_removeGlobal'].
	self projectsPresenter globalsTab selection: selection.
	self projectsPresenter basicRemoveGlobal: selection first.
	self assertIsNil: (self projectsPresenter globalsTab list
				detect: [:array | (array at: 1) equals: 'UserGlobals.test_removeGlobal']
				ifNone: [])!

test_globalsBrowseClassMenuItem
	| browseClassItem selection |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	browseClassItem := self projectsPresenter globalsTab view contextMenu items
				detect: [:item | item text = 'Browse Class'].
	self assert: browseClassItem command equals: #browseGlobalClass.
	session executeString: 'UserGlobals at: #test_globalsBrowseClassMenuItem put: ''fnoodle'''.
	
	[self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.
	selection := self projectsPresenter globalsTab list
				detect: [:array | (array at: 1) equals: 'UserGlobals.test_globalsBrowseClassMenuItem'].
	self projectsPresenter globalsTab selection: selection.
	secondBrowser := self projectsPresenter browseGlobalClass.
	self assert: ('String*' match: secondBrowser classListPresenter selection name)]
			ensure: 
				[session executeString: 'UserGlobals removeKey: #test_globalsBrowseClassMenuItem'.
				secondBrowser topShell destroy]!

test_globalsBrowseReferencesMenuItem
	| browseRefererencesItem selection |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	browseRefererencesItem := self projectsPresenter globalsTab view contextMenu items
				detect: [:item | item text = 'Browse References'].
	self assert: browseRefererencesItem command equals: #browseGlobalReferences.
	
	[self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.
	selection := self projectsPresenter globalsTab list
				detect: [:array | (array at: 1) equals: 'UserGlobals.UserGlobals'].
	self projectsPresenter globalsTab selection: selection.
	methodListBrowser := self projectsPresenter browseGlobalReferences.
	self assert: ('*UserGlobals*'
				match: methodListBrowser primaryPresenter methodSourcePresenter documentPresenter value).
	self
		assert: methodListBrowser primaryPresenter methodListPresenter methodListPresenter list notEmpty]
			ensure: [methodListBrowser topShell destroy]!

test_globalsDoubleClick
	| selection inspector |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self closeExistingInspectors.
	self selectNoneProject.
	session executeString: 'UserGlobals at: #test_globalsDoubleClick put: false'.
	
	[self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.
	selection := self projectsPresenter globalsTab list
				detect: [:array | (array at: 1) equals: 'UserGlobals.test_globalsDoubleClick'].
	self projectsPresenter globalsTab selection: selection.
	self projectsPresenter globalsTab onActionPerformed. "double click"
	inspector := JadeNavigationInspector allInstances first.
	self assert: inspector model value equals: 12.	"false"
	self assert: inspector documentPresenter value equals: 'false'.
	inspector instVarListPresenter selectionByIndex: 2.
	self assert: inspector documentPresenter value equals: '12'.
	self assert: inspector instVarListPresenter selection key equals: '-.asOop']
			ensure: 
				[session executeString: 'UserGlobals removeKey: #test_globalsDoubleClick'.
				inspector view close]!

test_globalsInspectMenuItem
	| inspectItem selection inspector |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	inspectItem := self projectsPresenter globalsTab view contextMenu items
				detect: [:item | item text = 'Inspect'].
	self assert: inspectItem command equals: #inspectGlobal.
	session executeString: 'UserGlobals at: #test_globalsContextMenu put: true'.
	
	[self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.
	selection := self projectsPresenter globalsTab list
				detect: [:array | (array at: 1) equals: 'UserGlobals.test_globalsContextMenu'].
	self projectsPresenter globalsTab selection: selection.
	inspector := self projectsPresenter inspectGlobal.
	self assert: inspector model value equals: 268.	"true"
	self assert: inspector documentPresenter value equals: 'true'.
	inspector instVarListPresenter selectionByIndex: 2.
	self assert: inspector documentPresenter value equals: '268'.
	self assert: inspector instVarListPresenter selection key equals: '-.asOop']
			ensure: 
				[session executeString: 'UserGlobals removeKey: #test_globalsContextMenu'.
				inspector view close]!

test_globalsTabHeaders
	| globalsView header |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.
	self projectsPresenter selectGlobalsTab.
	globalsView := self projectsPresenter globalsTab.
	header := globalsView model detect: [:array | array first = 'Name'].
	self assert: header first equals: 'Name'.
	self assert: header second equals: 'Class'.
	self assert: header third equals: 'Oop'.
	self assert: header fourth equals: 'Value'!

test_globalsTabValues
	"sanity check that a few expected value are present"

	| globalsView allUsers |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	self selectServiceNamed: 'Globals' in: self dictionaryPresenter.
	self projectsPresenter selectGlobalsTab.
	globalsView := self projectsPresenter globalsTab.
	allUsers := globalsView model detect: [:array | array first = 'Globals.AllUsers'].
	self assert: allUsers second equals: #UserProfileSet.
	self assert: allUsers third isKindOf: Integer.
	self assert: ('anUserProfileSet*' match: allUsers fourth).
	allUsers := globalsView model detect: [:array | array first = 'Globals.false'].
	self assert: allUsers second equals: #Boolean.
	self assert: allUsers third isKindOf: Integer.
	self assert: allUsers fourth equals: 'false'.
	allUsers := globalsView model detect: [:array | array first = 'Globals.true'].
	self assert: allUsers second equals: #Boolean.
	self assert: allUsers third isKindOf: Integer.
	self assert: allUsers fourth equals: 'true'.
	allUsers := globalsView model detect: [:array | array first = 'Globals.nil'].
	self assert: allUsers second equals: #UndefinedObject.
	self assert: allUsers third isKindOf: Integer.
	self assert: allUsers fourth equals: 'nil'!

test_insertDictionaryRandomly
	"order matters when adding a dictionary to the list.
	Insertion done immediately following selected dictionary
	or last if none selected."

	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.
	self projectsPresenter basicAddDictionaryNamed: 'AddedDictionary2'.	"second slot"
	self assert: (self dictionaryPresenter list at: 2) name equals: 'AddedDictionary2'.
	self assert: self dictionaryPresenter selection name equals: 'AddedDictionary2'.
	self projectsPresenter basicAddDictionaryNamed: 'AddedDictionary3'.
	self assert: (self dictionaryPresenter list at: 3) name equals: 'AddedDictionary3'.
	self assert: self dictionaryPresenter selection name equals: 'AddedDictionary3'.
	self dictionaryPresenter resetSelection.
	self projectsPresenter basicAddDictionaryNamed: 'AddedDictionaryLast'.
	self assert: (self dictionaryPresenter list at: self dictionaryPresenter list size) name
		equals: 'AddedDictionaryLast'.
	self assert: self dictionaryPresenter selection name equals: 'AddedDictionaryLast'.
	self abortTransaction.
	
	[self assertIsNil: (self dictionaryPresenter list
				detect: [:dictionaryService | dictionaryService name = 'AddedDictionary2']
				ifNone: []).
	self assertIsNil: (self dictionaryPresenter list
				detect: [:dictionaryService | dictionaryService name = 'AddedDictionary3']
				ifNone: []).
	self assertIsNil: (self dictionaryPresenter list
				detect: [:dictionaryService | dictionaryService name = 'AddedDictionaryLast']
				ifNone: [])]
			ensure: 
				[self cloneRowanSample1.
				self ensureRowanSample1Loaded]!

test_minimumClassStateReturned
	"in order to speed up the retrieval of the Globals symbol dictionary,
	just return the absolute basics. Spot check a few of the internal variables."

	| classService |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	self selectServiceNamed: 'Globals' in: self dictionaryPresenter.
	classService := self classListPresenter list detect: [:clsService | clsService name = 'Boolean'].
	self assert: classService name equals: 'Boolean'.
	self assert: classService versions equals: 1.
	self assert: classService version equals: 1.
	self assert: classService methods equals: Array new.
	self assertIsNil: classService variables.
	self assertIsNil: classService categories.
	self assertIsNil: classService instVarNames.
	self assertIsNil: classService template!

test_minimumProjectList
	| projectNames |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	projectNames := self projectListPresenter list collect: [:projectService | projectService name].
	self assert: (projectNames includes: RowanProjectService noneProject name).
	self assert: (projectNames includes: 'Cypress').
	self assert: (projectNames includes: 'Rowan').
	self assert: (projectNames includes: 'STON').
	self assert: (projectNames includes: 'Tonel')!

test_multipleBrowsersUpdateClassList
	| firstClassList |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	self selectClassListTab.
	self selectServiceNamed: 'RowanKernel' in: self dictionaryPresenter.
	firstClassList := self classListPresenter list.
	self openSecondBrowser.
	self assert: self classListPresenter list equals: firstClassList.
	self selectServiceNamed: 'RowanSample1' in: secondPresenter projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Tests' in: secondPresenter packageListPresenter.
	self assert: self classListPresenter list equals: firstClassList.
	self deny: secondPresenter classListPresenter list equals: firstClassList!

test_noneProjectNotRemovedOnUpdate
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	BrowserUpdate current updateService: self projectListPresenter selection session: session.
	self assert: (self projectListPresenter list includes: RowanProjectService noneProject).
	self assert: self projectListPresenter selection name equals: RowanProjectService noneProject name!

test_noneProjectRetainsSelectionWhenNewTabAdded
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	self assert: self projectListPresenter selection equals: RowanProjectService noneProject.
	projectsBrowser addSystemBrowser.
	projectsBrowser cardsPresenter view previousCard.
	self assert: self projectListPresenter selection equals: RowanProjectService noneProject!

test_packageAndDictionaryViewClass
	"test for the same view for a consistent look and feel.
	EditableListView is a subclass of ListView"
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self assert: self projectsPresenter packageListPresenter view class equals: EditableListView.
	self selectServiceNamed: RowanProjectService noneProject name in: self projectListPresenter.
	self assert: self projectsPresenter dictionaryPresenter view class equals: EditableListView.
	self assert: self projectsPresenter projectListPresenter view class equals: ListView.
	self assert: self projectsPresenter classListPresenter view class equals: ListView.
	self assert: self projectsPresenter categoryListPresenter view class equals: ListView.
	self assert: self projectsPresenter variableListPresenter view class equals: ListView.
	self assert: self projectsPresenter methodListPresenter view class equals: ListView!

test_packageDictionaryCardsTabName
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectRowanSample1Class.
	self assert: self projectsPresenter packageDictionaryCards view currentCard arrangement equals: 'Packages'.
	self projectsPresenter updateAfterFindClass: (RowanClassService new name: 'Array').
	self assert: self projectsPresenter packageDictionaryCards view currentCard arrangement equals: 'Dictionaries'!

test_projectSingleSelection
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self deny: self projectsPresenter projectListPresenter view isMultiSelect!

test_removeDictionary
	| dictionaryName |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	dictionaryName := 'Test_removeDictionary'.
	self projectsPresenter basicAddDictionaryNamed: dictionaryName.
	self assert: self dictionaryPresenter list last name equals: dictionaryName.
	self projectsPresenter basicRemoveDictionaries: (Array with: dictionaryName).
	self assertIsNil: (self dictionaryPresenter list
				detect: [:dictionaryService | dictionaryService name = dictionaryName]
				ifNone: [])!

test_removeDictionaryNoSelection
	| dictionaryNames |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	dictionaryNames := self dictionaryPresenter list collect: [:dictionaryService | dictionaryService name].
	self projectsPresenter removeDictionaries.	"should be no-op"
	self assert: (self dictionaryPresenter list collect: [:dictionaryService | dictionaryService name])
		equals: dictionaryNames!

test_selectProjectClearHierarchy
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.
	self selectServiceNamed: 'JadeServer' in: self classListPresenter.
	self selectHierarchyTab.
	self deny: self classHierarchyPresenter model isEmpty.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self assert: self classHierarchyPresenter model isEmpty.
	self selectClassListTab.
	self assert: self classListPresenter model isEmpty!

test_systemTabsShowDictionariesAndProjects
	| browserTabs |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self ensureOneTab. 
	browserTabs := projectsBrowser cardsPresenter view.
	self selectNoneProject.
	self assert: browserTabs currentCard arrangement equals: '1 ' , RowanProjectService noneProject name.
	projectsBrowser addSystemBrowser.
	
	[self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self assert: browserTabs currentCard arrangement equals: '2 Rowan'.
	projectsBrowser cardsPresenter view previousCard.
	self assert: browserTabs currentCard arrangement equals: '1 ' , RowanProjectService noneProject name.
	projectsBrowser cardsPresenter view nextCard]
			ensure: [projectsBrowser closeCard]!

test_textTabsChange
	| tabNames |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectRowanSample1Class.
	tabNames := (self projectsPresenter textAreaTabs cards
				collect: [:card | card arrangement displayString]) asArray.
	self assert: tabNames
		equals: #('Class Definition' 'Class Documentation' 'Method Source' 'SUnit' 'Comparison' 'Project').
	self selectNoneProject.
	tabNames := (self projectsPresenter textAreaTabs cards
				collect: [:card | card arrangement displayString]) asArray.
	self assert: tabNames
		equals: #('Class Definition' 'Class Documentation' 'Method Source' 'SUnit' 'Comparison' 'Globals')!

test_textTabSelectedWithProjectChange
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self assert: self projectsPresenter textAreaTabs currentCard displayString equals: 'projectInfoTab'.
	self selectNoneProject.
	self assert: self projectsPresenter textAreaTabs currentCard displayString equals: 'globalsTab'! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_abortInTranscriptRemovesDictionaryInBrowser!public! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_addDictionary!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_dictionaryNameIsString!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_dictionarySelectionChangesTab!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_dictionarySelectionIndependentInTab!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_dictionaryViewClassHierarchy!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_dictionaryViewClassHierarchySelectedClass!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_findClassNotInProject!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_firstClickDictionaries!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_globalRemove!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_globalsBrowseClassMenuItem!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_globalsBrowseReferencesMenuItem!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_globalsDoubleClick!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_globalsInspectMenuItem!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_globalsTabHeaders!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_globalsTabValues!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_insertDictionaryRandomly!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_minimumClassStateReturned!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_minimumProjectList!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_multipleBrowsersUpdateClassList!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_noneProjectNotRemovedOnUpdate!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_noneProjectRetainsSelectionWhenNewTabAdded!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_packageAndDictionaryViewClass!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_packageDictionaryCardsTabName!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_projectSingleSelection!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_removeDictionary!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_removeDictionaryNoSelection!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_selectProjectClearHierarchy!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_systemTabsShowDictionariesAndProjects!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_textTabsChange!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_textTabSelectedWithProjectChange!public!test issue 217! !

