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

assertDictionaryInList: dictionaryName
	self denyIsNil: (self dictionaryPresenter list
				detect: [:dictionaryService | dictionaryService name = dictionaryName]
				ifNone: [])!

assertDictionaryNotInList: dictionaryName
	self assertIsNil: (self dictionaryPresenter list
				detect: [:dictionaryService | dictionaryService name = dictionaryName]
				ifNone: [])!

test_abortInTranscriptRemovesDictionaryInBrowser
	"This test will not work currently because of issue
	https://github.com/GemTalk/Rowan/issues/349

	Work around was to commit after a dictionary add
	or removal"

	true ifTrue: [^self].
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
				[self auditAll.
				self cloneRowanSample1.
				self ensureRowanSample1Loaded]!

test_addDictionary
	| dictionaryName |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	dictionaryName := 'Test_addDictionary'.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.
	self projectsPresenter basicAddDictionaryNamed: dictionaryName.
	self assert: (self dictionaryPresenter list at: 2) name equals: dictionaryName.
	self assert: self dictionaryPresenter selection name equals: dictionaryName.
	self projectsPresenter basicRemoveDictionaries: (Array with: dictionaryName).
	self assertIsNil: (self dictionaryPresenter list
				detect: [:dictionaryService | dictionaryService name = dictionaryName]
				ifNone: [])!

test_addSubclassNoSuperclassPackage
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	self selectServiceNamed: 'Globals' in: self dictionaryPresenter.
	self projectsPresenter selectClassNamed: 'Dictionary'.
	self assert: self projectsPresenter selectedClass packageName
		equals: RowanService notRowanizedPackageName.
	self projectsPresenter addSubclass.
	
	[self assert: self projectsPresenter classDefinitionPresenter view isModified.
	self assert: self projectsPresenter classDefinitionPresenter value
		equals: 'Dictionary rwSubclass: ''NewSubclass''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''Superclass is not packaged. Enter the desired package name''
	options: #()
'
				replaceCrLfWithLf]
			ensure: [self projectsPresenter classDefinitionPresenter view isModified: false]!

test_addSubclassNoSuperclassPackageGoesToNewClass
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	self selectServiceNamed: 'Globals' in: self dictionaryPresenter.
	self projectsPresenter selectClassNamed: 'Dictionary'.
	self assert: self projectsPresenter selectedClass packageName
		equals: RowanService notRowanizedPackageName.
	self projectsPresenter addSubclass.
	self assert: self projectsPresenter classDefinitionPresenter view isModified.
	self assert: self projectsPresenter classDefinitionPresenter value
		equals: 'Dictionary rwSubclass: ''NewSubclass''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''Superclass is not packaged. Enter the desired package name''
	options: #()
'
				replaceCrLfWithLf.
	self projectsPresenter classDefinitionPresenter
		value: 'Dictionary rwSubclass: ''NewSubclassAbc''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''RowanSample1-Tests''
	options: #()
'.
	self projectsPresenter editSaveClass.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Tests'.
	self assert: self projectsPresenter selectedClass name equals: 'NewSubclassAbc'.
	self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass!

test_addSubclassWithPackage
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectRowanSample1Test.
	self assert: self projectsPresenter selectedClass packageName equals: 'RowanSample1-Tests'.
	self projectsPresenter addSubclass.
	
	[self assert: self projectsPresenter classDefinitionPresenter view isModified.
	self assert: self projectsPresenter classDefinitionPresenter value
		equals: 'RowanSample1Test rwSubclass: ''NewSubclass''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''RowanSample1-Tests''
	options: #()
'
				replaceCrLfWithLf]
			ensure: [self projectsPresenter classDefinitionPresenter view isModified: false]!

test_allClassesBlackInDictionaryView
	"dictionary view should never show a purple (extension) class"

	self testsIssue: #issue497
		withTitle: 'Base classes with extension methods should be purple in the package containing the method'.
	self selectNoneProject.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.
	self classListPresenter list
		do: [:classService | self deny: (classService shouldColorAsExtension: self projectsPresenter)]!

test_baseClassPurpleInPackageView
	self testsIssue: #issue497
		withTitle: 'Base classes with extension methods should be purple in the package containing the method'.
	self selectServiceNamed: 'Cypress' in: self projectListPresenter.
	self selectServiceNamed: 'Cypress-Environmental-Tools' in: self packageListPresenter.
	self selectServiceNamed: 'Behavior' in: self classListPresenter.
	self assert: (self classListPresenter selection shouldColorAsExtension: self projectsPresenter)!

test_canSelectUnauthorizedObjectStub
	"RowanClassService instVarNames was getting set to a STONReference
	for a few classes in the hierarchy browser. Made UnauthorizedObjectStub
	inaccessible. Add a sanity check so it doesn't get broken again"

	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	self selectServiceNamed: 'Globals' in: self dictionaryPresenter.
	self selectHierarchyTab.
	self selectClassInHierarchyNamed: 'UnauthorizedObjectStub'.
	self assert: ('*UnauthorizedObjectStub*' match: self projectsPresenter classDefinitionPresenter value)!

test_changeMethodInDictionaryViewShowsDirtyInProject
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectRowanSample1Test.
	self cloneRowanSample1.
	self ensureRowanSample1Loaded.	"make sure project is not dirty"
	self deny: self projectListPresenter selection isDirty.
	
	[self
		saveMethod: 'test3 ^3'
		in: 'RowanSample1Test'
		category: 'tests'.
	self assert: self projectListPresenter selection isDirty]
			ensure: 
				[self abortTransaction.
				self cloneRowanSample1.
				self ensureRowanSample1Loaded]!

test_commitAfterDictionaryAddOrRemove
	"Tests workaround for issue
	https://github.com/GemTalk/Rowan/issues/349

	Work around was to commit after a dictionary add
	or removal"

	| dictionaryName |
	
	[self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	dictionaryName := 'Test_CommitAfterAdd'.
	self projectsPresenter basicAddDictionaryNamed: dictionaryName.
	self assertDictionaryInList: dictionaryName.
	transcript toolbarPresenter abort.
	self assertDictionaryInList: dictionaryName.
	self projectsPresenter basicRemoveDictionaries: (Array with: dictionaryName).
	self assertDictionaryNotInList: dictionaryName.
	transcript toolbarPresenter abort.
	self assertDictionaryNotInList: dictionaryName]
			ensure: 
				[self auditAll.
				self cloneRowanSample1.
				self ensureRowanSample1Loaded]!

test_compileMethodInNonPackagedClass
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self testsRowanIssue: #issue499
		withTitle: 'RwPrjBrowserTool>>addOrUpdateMethod:inProtocol:forClassNamed:isMeta: returns nil'.	"Rowan issue"
	self selectNoneProject.
	self selectServiceNamed: 'Globals' in: self dictionaryPresenter.
	self selectServiceNamed: 'Array' in: self classListPresenter.
	self methodSourcePresenter value: 'foo ^''foo'''.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	
	[self assert: self methodListPresenter selection selector equals: #foo.
	self assert: self methodSourcePresenter value equals: 'foo ^''foo'''.
	self assert: (session executeString: 'Array includesSelector: #foo')]
			ensure: 
				[self abortTransaction.
				self cloneRowanSample1.
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

test_dictionaryWithoutClassHasClassTemplate
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.
	self projectsPresenter selectClassDefinitionTab.
	self assertIsNil: self projectsPresenter selectedClass.
	self rowanFixMe.
	self assert: self projectsPresenter classDefinitionPresenter value notEmpty	"not sure what this should be yet"!

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

test_globalsTabHandlesBadPrintString
	| badPrintEntry |
	self testsIssue: #issue492
		withTitle: 'In (NONE), there are bad-printstring walkbacks under conditions of issue #433 (3.0.73)'.
	self projectsPresenter classDefinitionPresenter
		value: 'Object rwSubclass: ''BadPrintString''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''RowanSample1-Tests''
	options: #()
'.
	self projectsPresenter editSaveClass.
	self
		saveMethod: 'printOn: aStream   aStream nextPutAll: self fnoodle'
		in: 'BadPrintString'
		category: 'printing'.
	session executeString: 'UserGlobals at: #badPrint put: BadPrintString new'.
	self selectNoneProject.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.
	badPrintEntry := self projectsPresenter globalsTab list
				detect: [:array | array first = 'UserGlobals.badPrint'].
	self assert: ('*unprintable string*' match: (badPrintEntry at: 4)).
	session executeString: 'UserGlobals removeKey: #badPrint'.
	self selectServiceNamed: 'BadPrintString' in: self classListPresenter.
	self projectsPresenter basicRemoveClass: self classListPresenter selection!

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

test_gotoDictionary
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self testsIssue: #issue491 withTitle: '(Oscar 3.0.73) need a way to find class in the dictionary '.
	self selectRowanSample1Class.
	self assert: self projectsPresenter selectedClass dictionaryName equals: 'UserGlobals'.
	self projectsPresenter gotoDictionary.
	self assert: self dictionaryPresenter selection name equals: 'UserGlobals'.
	self assert: self projectsPresenter selectedClass name equals: 'RowanSample1'.
	self projectsPresenter gotoClassDefinedPackage.
	self assert: self projectListPresenter selection name equals: 'RowanSample1'.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Core'.
	self assert: self classListPresenter selection name equals: self sampleClassName!

test_gotoDictionaryClassTab
	self testsIssue: #issue530 withTitle: '(3.0.77) Go to containing dictionary ... doesn''t'.
	self selectRowanSample1Class.
	self selectClassTab. 
	self selectClassTab.
	self assert: self projectsPresenter selectedClass dictionaryName equals: 'UserGlobals'.
	self projectsPresenter gotoDictionary.
	self assert: self dictionaryPresenter selection name equals: 'UserGlobals'.
	self assert: self projectsPresenter selectedClass name equals: 'RowanSample1'.
	self projectsPresenter gotoClassDefinedPackage.
	self assert: self projectListPresenter selection name equals: 'RowanSample1'.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Core'.
	self assert: self classListPresenter selection name equals: self sampleClassName!

test_gotoDictionaryHierarchyView
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self testsIssue: #issue491 withTitle: '(Oscar 3.0.73) need a way to find class in the dictionary '.
	self selectRowanSample1Class.
	self selectHierarchyTab.
	self assert: self projectsPresenter selectedClass dictionaryName equals: 'UserGlobals'.
	self projectsPresenter gotoDictionary.
	self assert: self dictionaryPresenter selection name equals: 'UserGlobals'.
	self assert: self projectsPresenter selectedClass name equals: 'RowanSample1'.
	self projectsPresenter gotoClassDefinedPackage.
	self assert: self projectListPresenter selection name equals: 'RowanSample1'.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Core'.
	self assert: self classListPresenter selection name equals: self sampleClassName!

test_gotoDictionaryHierarchyViewClassTab
	self testsIssue: #issue530 withTitle: '(3.0.77) Go to containing dictionary ... doesn''t'.
	self selectRowanSample1Class.
	self selectClassTab. 
	self selectHierarchyTab.
	self assert: self projectsPresenter selectedClass dictionaryName equals: 'UserGlobals'.
	self projectsPresenter gotoDictionary.
	self assert: self dictionaryPresenter selection name equals: 'UserGlobals'.
	self assert: self projectsPresenter selectedClass name equals: 'RowanSample1'.
	self projectsPresenter gotoClassDefinedPackage.
	self assert: self projectListPresenter selection name equals: 'RowanSample1'.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Core'.
	self assert: self classListPresenter selection name equals: self sampleClassName!

test_gotoDictionaryMenuItem
	| commandQuery gotoItem |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self testsIssue: #issue491 withTitle: '(Oscar 3.0.73) need a way to find class in the dictionary '.
	self selectRowanSample1Class.
	commandQuery := self
				queryCommand: #gotoDictionary
				inPresenter: self projectsPresenter
				view: self classListPresenter view.
	self assert: commandQuery isEnabled.
	self projectsPresenter updateClassMenu: self classListPresenter view queryContextMenu.
	gotoItem := self classListPresenter view queryContextMenu items
				detect: [:menuItem | menuItem command == #gotoDictionary].
	self assert: gotoItem description equals: 'Go To Containing Dictionary (UserGlobals)'.
	gotoItem commandDescription performAgainst: self projectsPresenter.
	commandQuery := self
				queryCommand: #gotoDictionary
				inPresenter: self projectsPresenter
				view: self classListPresenter view.
	self deny: commandQuery isEnabled!

test_gotoDictionaryMenuItemClassTab
	| commandQuery gotoItem |
	self testsIssue: #issue530 withTitle: '(3.0.77) Go to containing dictionary ... doesn''t'.
	self selectRowanSample1Class.
	self selectClassTab.
	commandQuery := self
				queryCommand: #gotoDictionary
				inPresenter: self projectsPresenter
				view: self classListPresenter view.
	self assert: commandQuery isEnabled.
	self projectsPresenter updateClassMenu: self classListPresenter view queryContextMenu.
	gotoItem := self classListPresenter view queryContextMenu items
				detect: [:menuItem | menuItem command == #gotoDictionary].
	self assert: gotoItem description equals: 'Go To Containing Dictionary (UserGlobals)'.
	gotoItem commandDescription performAgainst: self projectsPresenter.
	commandQuery := self
				queryCommand: #gotoDictionary
				inPresenter: self projectsPresenter
				view: self classListPresenter view.
	self deny: commandQuery isEnabled!

test_gotoPackageMenuItem
	| commandQuery gotoItem |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self testsIssue: #issue491 withTitle: '(Oscar 3.0.73) need a way to find class in the dictionary '.
	self selectNoneProject.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter. 
	self selectServiceNamed: 'JadeServer' in: self classListPresenter.
	commandQuery := self
				queryCommand: #gotoClassDefinedPackage
				inPresenter: self projectsPresenter
				view: self classListPresenter view.
	self assert: commandQuery isEnabled.
	self projectsPresenter updateClassMenu: self classListPresenter view queryContextMenu. "done by menu building infrastructure"
	gotoItem := self classListPresenter view queryContextMenu items
				detect: [:menuItem | menuItem command == #gotoClassDefinedPackage].
	self assert: gotoItem description equals: 'Go To Defining Package (Rowan-JadeServer)'.
	gotoItem commandDescription performAgainst: self projectsPresenter.
	commandQuery := self
				queryCommand: #gotoClassDefinedPackage
				inPresenter: self projectsPresenter
				view: self classListPresenter view.
	self deny: commandQuery isEnabled!

test_gotoPackageMenuItemHierarchyTab
	| commandQuery gotoItem |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self testsIssue: #issue491 withTitle: '(Oscar 3.0.73) need a way to find class in the dictionary '.
	self selectNoneProject.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter. 
	self selectServiceNamed: 'JadeServer' in: self classListPresenter.
	self selectHierarchyTab.
	commandQuery := self
				queryCommand: #gotoClassDefinedPackage
				inPresenter: self projectsPresenter
				view: self classListPresenter view.
	self assert: commandQuery isEnabled.
	self projectsPresenter updateClassMenu: self classListPresenter view queryContextMenu. "done by menu building infrastructure"
	gotoItem := self classListPresenter view queryContextMenu items
				detect: [:menuItem | menuItem command == #gotoClassDefinedPackage].
	self assert: gotoItem description equals: 'Go To Defining Package (Rowan-JadeServer)'.
	gotoItem commandDescription performAgainst: self projectsPresenter.
	commandQuery := self
				queryCommand: #gotoClassDefinedPackage
				inPresenter: self projectsPresenter
				view: self classListPresenter view.
	self deny: commandQuery isEnabled!

test_insertDictionaryMenuItemEnablement
	| commandQuery |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.
	commandQuery := self
				queryCommand: #addDictionary
				inPresenter: self projectsPresenter
				view: self dictionaryPresenter view.
	self assert: commandQuery isEnabled.
	self dictionaryPresenter resetSelection.
	commandQuery := self
				queryCommand: #addDictionary
				inPresenter: self projectsPresenter
				view: self dictionaryPresenter view.
	self assert: commandQuery isEnabled!

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
	self projectsPresenter
		basicRemoveDictionaries: #('AddedDictionary2' 'AddedDictionary3' 'AddedDictionaryLast').
	self assertIsNil: (self dictionaryPresenter list
				detect: [:dictionaryService | dictionaryService name = 'AddedDictionary2']
				ifNone: []).
	self assertIsNil: (self dictionaryPresenter list
				detect: [:dictionaryService | dictionaryService name = 'AddedDictionary3']
				ifNone: []).
	self assertIsNil: (self dictionaryPresenter list
				detect: [:dictionaryService | dictionaryService name = 'AddedDictionaryLast']
				ifNone: [])!

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
	self assert: classService categories isEmpty. "initialized on server now" 
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

test_mutliSelectDictionaryHierarchy
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self testsIssue: #issue489 withTitle: '(3.0.73) package multi-select is not functional'.
	self selectNoneProject.
	self selectServicesNamed: #('UserGlobals' 'Published') in: self dictionaryPresenter.
	self assert: (self classListPresenter list collect: [:classService | classService name]) asArray
		equals: #('JadeServer' 'JadeServer64bit' 'JadeServer64bit24' 'JadeServer64bit32' 'JadeServer64bit35' 'JadeServer64bit3x' 'Rowan' 'RowanSample1' 'RowanSample1Test' 'RowanSubClass').
	self selectHierarchyTab.
	self
		assert: (self classHierarchyPresenter model asArray collect: [:classService | classService name])
		equals: #('Object' 'JadeServer' 'JadeServer64bit' 'JadeServer64bit24' 'JadeServer64bit3x' 'JadeServer64bit32' 'JadeServer64bit35' 'Rowan' 'RowanSample1' 'RowanSubClass' 'TestAsserter' 'TestCase' 'RowanSample1Test')!

test_mutliSelectPackageHierarchy
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self testsIssue: #issue489 withTitle: '(3.0.73) package multi-select is not functional'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Kernel' 'Rowan-Services-Extensions')
		in: self packageListPresenter.
	self assert: (self classListPresenter list collect: [:classService | classService name]) asArray
		equals: #('Rowan' 'RwGsPlatform' 'RwPlatform').
	self selectHierarchyTab.
	self
		assert: (self classHierarchyPresenter model asArray collect: [:classService | classService name])
		equals: #('Object' 'Rowan' 'RwPlatform' 'RwGsPlatform')!

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

test_projectInfoTabMenuCopy
	| copyItem |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectServiceNamed: 'Tonel' in: self projectListPresenter.
	copyItem := self projectsPresenter projectInfoTab view contextMenu items
				detect: [:item | item text = 'Copy'].
	self assert: copyItem command equals: #copyProjectInfo.
	self projectsPresenter projectInfoTab selectionByIndex: 1.
	self projectsPresenter copyProjectInfo.
	self assert: (self projectsPresenter projectInfoTab selection at: 2) equals: 'rowanProjectsHome'.
	"we don't know what the path is so just ensure it's not equal to the answer to the next assert:"
	self deny: Clipboard current getText equals: 'false'.
	self projectsPresenter projectInfoTab selectionByIndex: 7.
	self assert: (self projectsPresenter projectInfoTab selection at: 2) equals: 'isDirty'.
	self projectsPresenter copyProjectInfo.	"Tonel isn't usually changed so probably safe to assume answer is false"
	self assert: Clipboard current getText equals: 'false'!

test_projectInfoTabMenuItemNames
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectServiceNamed: 'Tonel' in: self projectListPresenter.
	self projectsPresenter projectInfoTab selectionByIndex: 1.
	self assert: (self projectsPresenter projectInfoTab selection at: 2) equals: 'rowanProjectsHome'.
	self projectsPresenter projectInfoTab selectionByIndex: 2.
	self assert: (self projectsPresenter projectInfoTab selection at: 2) equals: nil.
	self projectsPresenter projectInfoTab selectionByIndex: 3.
	self assert: (self projectsPresenter projectInfoTab selection at: 2) equals: 'name'.
	self projectsPresenter projectInfoTab selectionByIndex: 4.
	self assert: (self projectsPresenter projectInfoTab selection at: 2) equals: 'sha'.
	self projectsPresenter projectInfoTab selectionByIndex: 5.
	self assert: (self projectsPresenter projectInfoTab selection at: 2) equals: 'branch'.
	self projectsPresenter projectInfoTab selectionByIndex: 6.
	self assert: (self projectsPresenter projectInfoTab selection at: 2) equals: 'isSkew'.
	self projectsPresenter projectInfoTab selectionByIndex: 7.
	self assert: (self projectsPresenter projectInfoTab selection at: 2) equals: 'isDirty'.
	self projectsPresenter projectInfoTab selectionByIndex: 8.
	self assert: (self projectsPresenter projectInfoTab selection at: 2) equals: 'projectUrl'!

test_projectListMenuItemsEnabled
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self projectListPresenter view contextMenu itemsDo: 
			[:item |
			| query |
			query := CommandQuery commandDescription: item source: self projectListPresenter view.
			self projectsPresenter queryCommand: query.
			query command = #gitCommit ifFalse: [self assert: query isEnabled]].
	self selectNoneProject.
	self projectListPresenter view contextMenu itemsDo: 
			[:item |
			| query |
			query := CommandQuery commandDescription: item source: self projectListPresenter view.
			self projectsPresenter queryCommand: query.
			(('*Refresh*' match: item text) or: ['*Clone Git Project*' match: item text])
				ifTrue: [self assert: query isEnabled]
				ifFalse: [self deny: query isEnabled]].
	self projectListPresenter resetSelection.
	self projectListPresenter view contextMenu itemsDo: 
			[:item |
			| query |
			query := CommandQuery commandDescription: item source: self projectListPresenter view.
			self projectsPresenter queryCommand: query.
			(('*Refresh*' match: item text) or: ['*Clone Git Project*' match: item text])
				ifTrue: [self assert: query isEnabled]
				ifFalse: [self deny: query isEnabled]]!

test_projectSingleSelection
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self deny: self projectsPresenter projectListPresenter view isMultiSelect!

test_protectedDictionaryNames
	self assert: self projectsPresenter protectedDictionaries
		equals: #('Published' 'Globals' 'UserGlobals')!

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

test_removeDictionaryMenuItemEnablement
	| commandQuery |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.
	commandQuery := self
				queryCommand: #removeDictionaries
				inPresenter: self projectsPresenter
				view: self dictionaryPresenter view.
	self assert: commandQuery isEnabled.
	self dictionaryPresenter resetSelection.
	commandQuery := self
				queryCommand: #removeDictionaries
				inPresenter: self projectsPresenter
				view: self dictionaryPresenter view.
	self deny: commandQuery isEnabled!

test_removeDictionaryNoSelection
	| dictionaryNames |
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	dictionaryNames := self dictionaryPresenter list collect: [:dictionaryService | dictionaryService name].
	self projectsPresenter removeDictionaries.	"should be no-op"
	self assert: (self dictionaryPresenter list collect: [:dictionaryService | dictionaryService name])
		equals: dictionaryNames!

test_removeMethodInNonPackagedClass
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	self selectServiceNamed: 'Globals' in: self dictionaryPresenter.
	self selectServiceNamed: 'Array' in: self classListPresenter.
	self methodSourcePresenter value: 'foo ^''foo'''.
	
	[self projectsPresenter editSaveMethod: self classListPresenter selection.
	self assert: self methodListPresenter selection selector equals: #foo.
	self projectsPresenter removeMethods: self classListPresenter selections.
	self deny: (self methodListPresenter selectionIfNone: [false])]
			ensure: 
				[self dictionaryPresenter resetSelection.	"to avoid long refresh"
				self abortTransaction.
				self cloneRowanSample1.
				self ensureRowanSample1Loaded]!

test_renameClassInDictionaryView
	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self selectNoneProject.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.
	self projectsPresenter selectClassNamed: 'RowanSample1Test'.
	self assert: self projectsPresenter selectedClass name equals: 'RowanSample1Test'.
	self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass.
	self assertIsNil: self projectsPresenter selectedClass.
	self assert: self projectsPresenter isClassDefinitionTabSelected.
	self rowanFixMe. 
	self assert: self projectsPresenter classDefinitionPresenter value notEmpty	"not sure what this should be yet"!

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
	self assert: self projectsPresenter textAreaTabs currentCard displayString equals: 'globalsTab'!

test_unicodeKeyInUserGlobals
	| selection |
	self testsIssue: #issue582
		withTitle: 'SymbolDictionary browser completely broken by an unreadable value in a Global '.
	session executeString: 'RowanServicesTest new addUnicodeSymbolKeyToUserGlobals'.
	
	[self selectNoneProject.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.	"bug occurred here"
	selection := self projectsPresenter globalsTab list
				detect: [:array | array first = 'UserGlobals.<<unprintable string. charSize > 1>>'].
	self projectsPresenter globalsTab selection: selection.
	self assert: (selection at: 2) equals: #String.
	self assert: ((selection at: 3) isKindOf: Integer).
	self assert: (selection at: 4) equals: '''fnoodle''']
			ensure: [session executeString: 'RowanServicesTest new removeUnicodeSymbolsFromUserGlobals']!

test_unicodeValueInUserGlobals
	| selection |
	self testsIssue: #issue582
		withTitle: 'SymbolDictionary browser completely broken by an unreadable value in a Global '.
	session executeString: 'RowanServicesTest new addUnicodeValueToUserGlobals'.
	
	[self selectNoneProject.
	self selectServiceNamed: 'UserGlobals' in: self dictionaryPresenter.	"bug occurred here"
	selection := self projectsPresenter globalsTab list
				detect: [:array | array first = 'UserGlobals.bad'].
	self projectsPresenter globalsTab selection: selection.
	self assert: (selection at: 2) equals: #Symbol.
	self assert: ((selection at: 3) isKindOf: Integer).
	self assert: (selection at: 4) equals: '#''£¥š''']
			ensure: [session executeString: 'RowanServicesTest new removeUnicodeSymbolsFromUserGlobals']! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #assertDictionaryInList:!private!support! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #assertDictionaryNotInList:!private!support! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_abortInTranscriptRemovesDictionaryInBrowser!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_addDictionary!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_addSubclassNoSuperclassPackage!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_addSubclassNoSuperclassPackageGoesToNewClass!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_addSubclassWithPackage!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_allClassesBlackInDictionaryView!public! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_baseClassPurpleInPackageView!public! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_canSelectUnauthorizedObjectStub!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_changeMethodInDictionaryViewShowsDirtyInProject!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_commitAfterDictionaryAddOrRemove!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_compileMethodInNonPackagedClass!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_dictionaryNameIsString!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_dictionarySelectionChangesTab!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_dictionarySelectionIndependentInTab!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_dictionaryViewClassHierarchy!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_dictionaryViewClassHierarchySelectedClass!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_dictionaryWithoutClassHasClassTemplate!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_findClassNotInProject!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_firstClickDictionaries!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_globalRemove!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_globalsBrowseClassMenuItem!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_globalsBrowseReferencesMenuItem!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_globalsDoubleClick!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_globalsInspectMenuItem!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_globalsTabHandlesBadPrintString!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_globalsTabHeaders!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_globalsTabValues!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_gotoDictionary!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_gotoDictionaryClassTab!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_gotoDictionaryHierarchyView!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_gotoDictionaryHierarchyViewClassTab!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_gotoDictionaryMenuItem!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_gotoDictionaryMenuItemClassTab!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_gotoPackageMenuItem!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_gotoPackageMenuItemHierarchyTab!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_insertDictionaryMenuItemEnablement!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_insertDictionaryRandomly!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_minimumClassStateReturned!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_minimumProjectList!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_multipleBrowsersUpdateClassList!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_mutliSelectDictionaryHierarchy!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_mutliSelectPackageHierarchy!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_noneProjectNotRemovedOnUpdate!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_noneProjectRetainsSelectionWhenNewTabAdded!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_packageAndDictionaryViewClass!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_packageDictionaryCardsTabName!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_projectInfoTabMenuCopy!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_projectInfoTabMenuItemNames!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_projectListMenuItemsEnabled!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_projectSingleSelection!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_protectedDictionaryNames!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_removeDictionary!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_removeDictionaryMenuItemEnablement!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_removeDictionaryNoSelection!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_removeMethodInNonPackagedClass!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_renameClassInDictionaryView!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_selectProjectClearHierarchy!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_systemTabsShowDictionariesAndProjects!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_textTabsChange!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_textTabSelectedWithProjectChange!public!test issue 217! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_unicodeKeyInUserGlobals!public!test unreadable code! !
!JadeiteProjectBrowserDictionaryTestCase categoriesFor: #test_unicodeValueInUserGlobals!public!test unreadable code! !

