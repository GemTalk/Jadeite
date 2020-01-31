"Filed out from Dolphin Smalltalk 7"!

JadeiteProjectBrowserAbstractTestCase subclass: #JadeiteProjectBrowserDictionaryDataCuratorTestCase
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteProjectBrowserDictionaryDataCuratorTestCase guid: (GUID fromString: '{a61bd899-d4eb-426b-ad96-8310f15a0ec1}')!
JadeiteProjectBrowserDictionaryDataCuratorTestCase comment: ''!
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesForClass!Unclassified! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase methodsFor!

assertDictionaryInList: dictionaryName
	self denyIsNil: (self dictionaryPresenter list
				detect: [:dictionaryService | dictionaryService name = dictionaryName]
				ifNone: [])!

assertDictionaryNotInList: dictionaryName
	self assertIsNil: (self dictionaryPresenter list
				detect: [:dictionaryService | dictionaryService name = dictionaryName]
				ifNone: [])!

setUp
	user ifNil: [user := 'DataCurator'].
	super setUp!

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
	self selectRowanSample1Test.
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

test_fullHierarchyExpansion
	| hierarchyClassNames |
	self testsIssue: #issue640 withTitle: 'Double click no longer expands hierarchy view'.
	self selectNoneProject.
	self selectServiceNamed: 'Globals' in: self dictionaryPresenter.
	self selectClassListTab. 
	self selectServiceNamed: 'AbstractException' in: self classListPresenter.
	self selectHierarchyTab.
	hierarchyClassNames := self classHierarchyPresenter model asArray
				collect: [:classService | classService name].
	self assert: hierarchyClassNames
		equals: #('Object' 'AbstractException' 'Exception' 'RubyBreakException' 'RubyThrowException').
	self selectClassInHierarchyNamed: 'AbstractException'.
	self projectsPresenter expandFullHierarchy.
	hierarchyClassNames := self classHierarchyPresenter model asArray do: 
					[:classService |
					self assert: (session
								executeString: '
							| hierarchy |
							hierarchy := (AbstractException allSuperclasses collect: [:cls | cls name]) asArray. 
							hierarchy add: #AbstractException. 
							hierarchy addAll: (AbstractException allSubclasses collect: [:cls | cls name]) asArray. 
							hierarchy includes: '
										, classService name asSymbol printString)]!

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
	inspector := JadeiteInspector allInstances first.
	self assert: inspector documentPresenter value equals: 'false'.
	inspector instVarListPresenter selectionByIndex: #(2).
	self assert: inspector documentPresenter value equals: '12'.
	self assert: inspector instVarListPresenter selections first key equals: '-.asOop']
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
	self assert: inspector documentPresenter value equals: 'true'.
	inspector instVarListPresenter selectionByIndex: #(2).
	self assert: inspector documentPresenter value equals: '268'.
	self assert: inspector instVarListPresenter selections first key equals: '-.asOop']
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
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #assertDictionaryInList:!private!support! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #assertDictionaryNotInList:!private!support! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #setUp!public!setup teardown! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_abortInTranscriptRemovesDictionaryInBrowser!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_addDictionary!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_addSubclassNoSuperclassPackage!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_addSubclassNoSuperclassPackageGoesToNewClass!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_addSubclassWithPackage!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_allClassesBlackInDictionaryView!public! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_baseClassPurpleInPackageView!public! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_canSelectUnauthorizedObjectStub!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_changeMethodInDictionaryViewShowsDirtyInProject!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_commitAfterDictionaryAddOrRemove!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_dictionaryNameIsString!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_dictionarySelectionChangesTab!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_dictionarySelectionIndependentInTab!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_dictionaryWithoutClassHasClassTemplate!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_findClassNotInProject!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_firstClickDictionaries!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_fullHierarchyExpansion!public!test class hierarchy! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_globalRemove!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_globalsBrowseClassMenuItem!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_globalsBrowseReferencesMenuItem!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_globalsDoubleClick!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_globalsInspectMenuItem!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_globalsTabHandlesBadPrintString!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_globalsTabHeaders!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_globalsTabValues!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_gotoDictionary!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_gotoDictionaryClassTab!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_gotoDictionaryHierarchyView!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_gotoDictionaryHierarchyViewClassTab!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_gotoDictionaryMenuItem!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_gotoDictionaryMenuItemClassTab!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_insertDictionaryMenuItemEnablement!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_insertDictionaryRandomly!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_minimumClassStateReturned!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_minimumProjectList!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_noneProjectNotRemovedOnUpdate!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_noneProjectRetainsSelectionWhenNewTabAdded!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_packageDictionaryCardsTabName!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_projectInfoTabMenuCopy!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_projectInfoTabMenuItemNames!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_projectListMenuItemsEnabled!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_projectSingleSelection!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_protectedDictionaryNames!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_removeDictionary!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_removeDictionaryMenuItemEnablement!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_removeDictionaryNoSelection!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_renameClassInDictionaryView!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_systemTabsShowDictionariesAndProjects!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_textTabsChange!public!test issue 217! !
!JadeiteProjectBrowserDictionaryDataCuratorTestCase categoriesFor: #test_textTabSelectedWithProjectChange!public!test issue 217! !

