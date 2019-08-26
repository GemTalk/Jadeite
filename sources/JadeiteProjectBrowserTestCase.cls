"Filed out from Dolphin Smalltalk 7"!

JadeiteProjectBrowserAbstractTestCase subclass: #JadeiteProjectBrowserTestCase
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteProjectBrowserTestCase guid: (GUID fromString: '{1d6db475-c257-442b-9f91-d1574b03aee2}')!
JadeiteProjectBrowserTestCase comment: 'General Jadeite tests. Assumes a logged in session and transcript present. 

When running tests from SUnit Browser Tool, make sure to turn on Auto Initialize Resources.'!
!JadeiteProjectBrowserTestCase categoriesForClass!Unclassified! !
!JadeiteProjectBrowserTestCase methodsFor!

addSampleMethodGoo

	| source |
	source := 'goo
	"RowanSample1 new goo"
	^Array with: #goo'. 
	self methodSourcePresenter value: source. 
	self projectsPresenter editSaveMethod: self classListPresenter selection. 

	!

addSampleMethodHoo

	| source |
	source := 'hoo
	^Bag with: ''hoo'''. 
	self methodSourcePresenter value: source. 
	self projectsPresenter editSaveMethod: self classListPresenter selection. 

	!

assertAncestry: family in: presenter
	"given a dictionary of class names where the key 
	is the parent and the value is a collection of children,
	assert the tree has the same structure"

	(self family: family ofNodesIn: presenter) keysAndValuesDo: 
			[:parent :children |
			self assert: children asOrderedCollection equals: (presenter model childrenOf: parent)]!

cleanupExistingWindows
	JadeWorkspace allInstances do: [:ws | self cleanupTextPaneForClose: ws].	"otherwise the test will hang"
	JadeiteTranscript allInstances do: [:text | self cleanupTextPaneForClose: text].
	JadeiteBrowserPresenter allInstances do: 
			[:presenter |
			presenter methodSourcePresenter view isModified: false.
			presenter classDefinitionPresenter view isModified: false]!

cleanupTextPaneForClose: ws
	^ws codePane documentPresenter view isModified
		ifTrue: 
			[ws codePane documentPresenter view isModified: false.
			ws codePane documentPresenter value: nil]!

currentTabView
	^self projectsPresenter topShell cardsPresenter view cardLayout currentCard!

dirtyProjectForChangeBrowser
	self selectRowanSample1Class.
	self modifySampleMethodFoo.
	self addSampleMethodGoo.
	self addSampleMethodHoo.
	self
		saveClass: 'DirtyProject1'
		withInstVars: Array new
		package: 'RowanSample1-Tests'.
	self
		saveClass: 'DirtyProject2'
		withInstVars: Array new
		package: 'RowanSample1-Tests'.
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	self projectsPresenter basicRemoveMethods!

executeStringInOtherSession: string
	| executionString |
	executionString := '(UserGlobals at: #otherSession) '.
	executionString := executionString , string.
	session executeString: executionString!

family: family ofNodesIn: presenter
	| nodeFamily services |
	nodeFamily := Dictionary new. 
	services := presenter model asBag.
	family keysAndValuesDo: 
			[:parentName :childrenNames |
			| parentNode childrenNodeArray |
			parentNode := services detect: [:service | service name = parentName].
			childrenNodeArray := childrenNames
						collect: [:childName | services detect: [:service | service name = childName]].
			nodeFamily at: parentNode put: childrenNodeArray].
	^nodeFamily!

issue170methodCreation
	| source |
	self methodSourcePresenter value: (source := 'another  ^5').
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self methodSourcePresenter value: (source := 'interesting  ^5').
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self methodSourcePresenter value: (source := 'test  ^5').
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self methodSourcePresenter value: (source := 'try  ^5').
	self projectsPresenter editSaveMethod: self classListPresenter selection!

issue261createTestProject
	"Private - support method for issue 261"

	self testsIssue: #issue261 withTitle: 'Project tab should display reason for project font styling'.
	session
		executeString: '| proj pkg cls meth |
proj := RwProjectDefinition newForGitBasedProjectNamed: ''Izmir''.
proj repositoryRootPath: ''$ROWAN_PROJECTS_HOME/Izmir''.
Rowan projectTools create createProjectFor: proj.'.
	self projectsPresenter refreshFromServer!

issue284methodCreation
	self methodSourcePresenter value: 'addedMethod  ^5'.
	self projectsPresenter editSaveMethod: self classListPresenter selection!

loadProjectNamed: projectName
	| browserService projectService |
	browserService := RowanBrowserService new.
	projectService := RowanProjectService new name: projectName.
	projectService command: #update.
	browserService
		command: #reloadProjects:andUpdateServices:;
		commandArgs: (Array with: (Array with: projectService) with: BrowserUpdate current selectedServices).
	BrowserUpdate current issueCommand: (Array with: browserService) session: session!

loginOtherSession
	(Delay forSeconds: 1) wait.	"not sure if this is necessary"
	session
		executeString: 'UserGlobals at: #otherSession put: (GsExternalSession gemNRS: ''' , session gemNRS
				, ''' stoneNRS: ''' , session stoneName
				, ''' username: ''SystemUser'' password: ''swordfish'') login'!

logoutOtherSession
	^session executeString: '
				(UserGlobals at: #otherSession) logout.'!

modifySampleMethodFoo

	| source |
	source := 'foo
	"RowanSample1 new foo"
	^1 + 2 + 3'. 
	self methodSourcePresenter value: source. 
	self projectsPresenter editSaveMethod: self classListPresenter selection. 

	!

nextTabView
	self projectsPresenter topShell cardsPresenter view cardLayout cycleNextCard!

packageNamed: aString
	^self packageListPresenter list
		detect: [:projectService | projectService name = aString]
		ifNone: []!

previousTabView
	self projectsPresenter topShell cardsPresenter view cardLayout cyclePreviousCard!

projectList
	^self projectListPresenter list!

projectNamed: aString
	^self projectsPresenter projectListPresenter list
		detect: [:projectService | projectService name = aString]
		ifNone: []!

rowanProjectNames
	"this may change"

	^#('Cypress' 'Rowan' 'STON' 'Tonel')!

saveHooMethod

	| source |
	source := 'hoo
	"RowanSample1 new hoo"
	^self goo'. 
	self methodSourcePresenter value: source. 
	self projectsPresenter editSaveMethod: self classListPresenter selection. 

	!

saveMethodWithUnimplementedSelector

	| source |
	source := 'theTestMethod
		^self fnoodley1'.
	self methodSourcePresenter value: source. 
	self projectsPresenter editSaveMethod: self classListPresenter selection. 

	!

saveMethodWithUniqueString

	| source |
	source := 'gloop
	"I be unique"
	^self gloop'. 
	self methodSourcePresenter value: source. 
	self projectsPresenter editSaveMethod: self classListPresenter selection. 

	!

saveTestClass
	self saveTestClassWithInstVars: Array new package: 'Rowan-Services-Tests'!

selectCommentTab
	self projectsPresenter classCommentPresenter ensureVisible!

selectSUnitTab
	self projectsPresenter sunitPresenter ensureVisible!

selectVariableListEntryForcingEvent: variable
	| event index |
	index := self variableListPresenter list indexOf: variable.
	event := (SelectionChangingEvent forSource: self)
				oldSelections: self variableListPresenter selections;
				newSelections: (Array with: (self variableListPresenter list at: index));
				cause: #test;
				yourself.
	self variableListPresenter onSelectionChanging: event.
	event value
		ifTrue: [self variableListPresenter selection: (self variableListPresenter list at: index)]!

test_abortOnVariablesTab
	self unloadSampleProject.
	self commitTransaction.	"if sample project was loaded and committed outside test, test will fail"
	self cloneRowanSample1.
	self ensureRowanSample1Loaded.
	self selectRowanSample1Test.
	self projectsPresenter selectVariableTab.
	self projectsPresenter variableListPresenter selectionByIndex: 1.
	self abortTransaction.
	
	[self assert: self projectsPresenter variableListPresenter list isEmpty.
	self assert: self classListPresenter list isEmpty.
	self assert: self packageListPresenter list isEmpty]
			ensure: 
				[self cloneRowanSample1.
				self ensureRowanSample1Loaded]!

test_abstractTestsShown
	| commandQuery methodService |
	self testsIssue: #issue336
		withTitle: 'S-Unit Tests In an abstract class and its subclasses are not managed properly'.
	self loadProjectNamed: 'Tonel'.	"ensure tests are present"
	self selectServiceNamed: 'Tonel' in: self projectListPresenter.
	self selectServiceNamed: 'Tonel-Tests' in: self packageListPresenter.
	self selectServiceNamed: 'TonelAbstractWriterTest' in: self classListPresenter.
	self assert: (session executeString: 'TonelAbstractWriterTest isAbstract').
	self selectCategoryNamed: 'tests'.
	methodService := self methodListPresenter list
				detect: [:method | method selector == #testWriteSnapshot]
				ifNone: [].
	self denyIsNil: methodService.
	self methodListPresenter selection: methodService.
	commandQuery := self
				queryCommand: #runMethodTests
				inPresenter: self projectsPresenter
				view: self methodListPresenter view.
	self deny: commandQuery isEnabled	"run test menu item disabled in the abstract class"!

test_acceptDefinedMethodInExtensionClass
	self testsIssue: #issue375
		withTitle: '(3.0.53) accept non-extension method in an extension package .... lose selected class'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Extensions' in: self packageListPresenter.
	self selectServiceNamed: self sampleClassName in: self classListPresenter.
	self selectMethodNamed: #foo.	"select a method defined in it's class package while the extension class is selected"
	self methodSourcePresenter value: 'foo   ^foot'.
	self assert: self methodSourcePresenter value equals: 'foo   ^foot'.
	self assert: self methodListPresenter selection selector equals: #foo.
	self assert: self classListPresenter selection name equals: 'RowanSample1'.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Extensions'.
	self methodSourcePresenter value: 'foo   ^footy'.
	self assert: self methodSourcePresenter value equals: 'foo   ^footy'.
	self assert: self methodListPresenter selection selector equals: #foo.
	self assert: self classListPresenter selection name equals: 'RowanSample1'.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Extensions'!

test_addAccessors
	self testsIssue: #issue382 withTitle: 'Add Accessors menu item is disabled'.
	self selectRowanSample1Class.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #('var1' 'var2' 'var3')
		package: 'RowanSample1-Core'.
	
	[self projectsPresenter selectVariableTab.
	self variableListPresenter selections: #('var1' 'var3').
	self projectsPresenter addVariableAccessors.
	self selectMethodNamed: #var1.
	self assert: self methodListPresenter selections first selector equals: #var1.
	self selectMethodNamed: #var1:.
	self assert: self methodListPresenter selections first selector equals: #var1:.
	self selectMethodNamed: #var3.
	self assert: self methodListPresenter selections first selector equals: #var3.
	self selectMethodNamed: #var3:.
	self assert: self methodListPresenter selections first selector equals: #var3:.
	self
		assertIsNil: (self methodListPresenter list detect: [:methodService | methodService selector = #var2]
				ifNone: []).
	self assertIsNil: (self methodListPresenter list
				detect: [:methodService | methodService selector = #var2:]
				ifNone: [])]
			ensure: [self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass]!

test_addAccessorsClassTab
	self testsIssue: #issue382 withTitle: 'Add Accessors menu item is disabled'.
	self selectRowanSample1Class.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #()
		package: 'RowanSample1-Core'.
	
	[self projectsPresenter selectClassTab.
	self projectsPresenter selectVariableTab.
	self variableListPresenter selections: #('format').
	self projectsPresenter addVariableAccessors.
	self selectMethodNamed: #format.
	self assert: self methodListPresenter selections first selector equals: #format.
	self selectMethodNamed: #format:.
	self assert: self methodListPresenter selections first selector equals: #format:]
			ensure: [self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass]!

test_addAccessorsHierarchyTab
	self testsIssue: #issue382 withTitle: 'Add Accessors menu item is disabled'.
	self selectRowanSample1Class.
	self selectHierarchyTab.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #('var1' 'var2' 'var3')
		package: 'RowanSample1-Core'.
	
	[self projectsPresenter selectVariableTab.
	self variableListPresenter selections: #('var1' 'var3').
	self projectsPresenter addVariableAccessors.
	self selectMethodNamed: #var1.
	self assert: self methodListPresenter selections first selector equals: #var1.
	self selectMethodNamed: #var1:.
	self assert: self methodListPresenter selections first selector equals: #var1:.
	self selectMethodNamed: #var3.
	self assert: self methodListPresenter selections first selector equals: #var3.
	self selectMethodNamed: #var3:.
	self assert: self methodListPresenter selections first selector equals: #var3:.
	self
		assertIsNil: (self methodListPresenter list detect: [:methodService | methodService selector = #var2]
				ifNone: []).
	self assertIsNil: (self methodListPresenter list
				detect: [:methodService | methodService selector = #var2:]
				ifNone: [])]
			ensure: [self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass]!

test_addAccessorsHierarchyTabVerifySource
	self testsIssue: #issue382 withTitle: 'Add Accessors menu item is disabled'.
	self selectRowanSample1Class.
	self selectHierarchyTab.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #('var1' 'var2' 'var3')
		package: 'RowanSample1-Core'.
	
	[self projectsPresenter selectVariableTab.
	self variableListPresenter selections: #('var1').
	self projectsPresenter addVariableAccessors.
	self selectMethodNamed: #var1.
	self assert: self methodSourcePresenter value equals: 'var1
	^var1'.
	self selectMethodNamed: #var1:.
	self assert: self methodSourcePresenter value equals: 'var1: object
	var1 := object']
			ensure: [self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass]!

test_addAccessorsVariablesStaySelected
	self testsIssue: #issue382 withTitle: 'Add Accessors menu item is disabled'.
	self selectRowanSample1Class.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #('var1' 'var2' 'var3')
		package: 'RowanSample1-Core'.
	
	[self projectsPresenter selectVariableTab.
	self variableListPresenter selections: #('var1' 'var3').
	self projectsPresenter addVariableAccessors.
	self assert: self variableListPresenter selections equals: #('var1' 'var3')]
			ensure: [self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass]!

test_addAccessorsVerifySource
	self testsIssue: #issue382 withTitle: 'Add Accessors menu item is disabled'.
	self selectRowanSample1Class.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #('var1' 'var2' 'var3')
		package: 'RowanSample1-Core'.
	
	[self projectsPresenter selectVariableTab.
	self variableListPresenter selections: #('var1').
	self projectsPresenter addVariableAccessors.
	self selectMethodNamed: #var1.
	self assert: self methodSourcePresenter value equals: 'var1
	^var1'.
	self selectMethodNamed: #var1:.
	self assert: self methodSourcePresenter value equals: 'var1: object
	var1 := object']
			ensure: [self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass]!

test_addDuplicatePackage
	| projectService addPackageResult packageName |
	self testsIssue: #issue266
		withTitle: 'Add package with existing name results in package in two projects'.
	
	[packageName := 'NewPackage'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	projectService := self projectListPresenter selection.
	projectService addPackageNamed: packageName using: self projectsPresenter.
	self assert: self packageListPresenter selection name equals: packageName.
	self assert: (self packageListPresenter list select: [:service | service name = packageName]) size
		equals: 1.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[TestMessageBox plannedResult: #failed.
	addPackageResult := projectService addPackageNamed: packageName using: self projectsPresenter.
	self assert: addPackageResult equals: MessageBox. "notify: does not return the result, sadly" 
	self assert: (self packageListPresenter list select: [:service | service name = packageName]) size
		equals: 1]
			ensure: [TestMessageBox disableJadeiteTestMessageBox]]
			ensure: 
				[self unloadSampleProject.	"we can't yet unload packages so unload the project and reload"
				self cloneRowanSample1.
				self ensureRowanSample1Loaded]!

test_addInstVarVariablesStaySorted
	self selectRowanSample1Test.
	self projectsPresenter selectVariableTab.
	self assert: self projectsPresenter methodFilterListPresenter list
		equals: (OrderedCollection with: 'testSelector').
	self
		saveClass: 'RowanSample1Test'
		superclass: 'TestCase'
		instVars: #('foo' 'bar')
		package: 'RowanSample1-Tests'.
	self assert: self projectsPresenter methodFilterListPresenter list asArray
		equals: (Array
				with: 'bar'
				with: 'foo'
				with: 'testSelector').
	self
		saveClass: 'RowanSample1Test'
		superclass: 'TestCase'
		instVars: #('foo' 'bar' 'abc')
		package: 'RowanSample1-Tests'.
	self assert: self projectsPresenter methodFilterListPresenter list asArray
		equals: (Array
				with: 'abc'
				with: 'bar'
				with: 'foo'
				with: 'testSelector')!

test_addInstVarWithVariablesTabOpen
	self testsIssue: #issue447 withTitle: '(3.0.63) more odd behavior with add instance variable'.
	self selectRowanSample1Test.
	self projectsPresenter selectVariableTab.
	self assert: self projectsPresenter methodFilterListPresenter list
		equals: (OrderedCollection with: 'testSelector').
	self
		saveClass: 'RowanSample1Test'
		superclass: 'TestCase'
		instVars: #('foo' 'bar')
		package: 'RowanSample1-Tests'.
	self assert: self projectsPresenter methodFilterListPresenter list
		equals: (SortedCollection
				with: 'bar'
				with: 'foo'
				with: 'testSelector').
	self projectsPresenter textAreaTabs currentCard name = 'classDefinition'	"don't change tab to Method Source"!

test_addPackageReloadProject
	self testsIssue: #issue183
		withTitle: 'Add package but don''t write it to disk then reload - walkback'.
	self selectServicesNamed: (Array with: 'RowanSample1') in: self projectListPresenter.
	self assertIsNil: (self packageNamed: 'NewPackage').
	self projectListPresenter selection addPackageNamed: 'NewPackage' using: self projectsPresenter.
	self denyIsNil: (self packageNamed: 'NewPackage').
	TestMessageBox enableJadeiteTestMessageBox.
	
	[TestMessageBox plannedResult: #yes.	"confirm we want to reload project"
	self projectsPresenter loadProjects.
	self assertIsNil: (self packageNamed: 'NewPackage')]
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

test_addRemoveCategory
	self selectRowanSample1Class.
	self deny: (self categoryListPresenter list includes: 'jadeite test').
	self projectsPresenter basicAddMethodCategory: 'jadeite test'.
	self assert: (self categoryListPresenter list includes: 'jadeite test').
	self assert: self categoryListPresenter selection = 'jadeite test'.
	self projectsPresenter basicRemoveMethodCategories.
	self deny: (self categoryListPresenter list includes: 'jadeite test')!

test_addRemoveHierarchyCategory
	self testsIssue: #issue215 withTitle: 'add category in hierarchy view'.
	self selectServicesNamed: (Array with: 'RowanSample1') in: self projectListPresenter.
	self selectServicesNamed: #('RowanSample1-Core') in: self packageListPresenter.
	self selectHierarchyTab.
	self selectClassInHierarchyNamed: self sampleClassName.
	self deny: (self categoryListPresenter list includes: 'jadeite test').
	self projectsPresenter basicAddMethodCategory: 'jadeite test'.
	self assert: (self categoryListPresenter list includes: 'jadeite test').
	self assert: self categoryListPresenter selection = 'jadeite test'.
	self projectsPresenter basicRemoveMethodCategories.
	self deny: (self categoryListPresenter list includes: 'jadeite test')!

test_addSubclass
	self testsIssue: #issue422
		withTitle: '(3.0.58) Add subclass in hierachy view adds to wrong class (or does not work)'.
	self selectRowanSample1Test.
	self selectHierarchyTab.
	self selectClassInHierarchyNamed: 'TestCase'.
	
	[self projectsPresenter addSubclass.
	self assert: self projectsPresenter classDefinitionPresenter value
		equals: 'TestCase rwSubclass: ''NewSubclass''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''Superclass is not packaged. Enter the desired package name''
	options: #()
'
				replaceCrLfWithLf]
			ensure: [self projectsPresenter classDefinitionPresenter view isModified: false]!

test_adHocInspectComplexObjectInProjectBrowser
	| inspector |
	self testsIssue: #issue464 withTitle: '(3.0.67) String does not understand #format: ... during doit'.
	self methodSourcePresenter value: 'RowanSample1Test new setTestSelector: #test1'.
	self methodSourcePresenter setFocus.
	
	[inspector := self projectsPresenter jadeInspect.
	self assert: (inspector model value isKindOf: Integer).	"the oop"
	self assert: inspector instVarListPresenter selection key equals: 'self'.
	self assert: inspector instVarListPresenter selection value equals: 'RowanSample1Test>>#test1'.
	inspector instVarListPresenter selectionByIndex: 2.
	self assert: inspector instVarListPresenter selection key equals: '-.asOop'.
	self assert: inspector instVarListPresenter selection value
		equals: inspector model value printString.
	inspector instVarListPresenter selectionByIndex: 3.
	self assert: inspector instVarListPresenter selection key equals: '-testSelector'.
	self assert: (inspector instVarListPresenter selection value isKindOf: OopType64)]
			ensure: 
				[inspector view close.
				self methodSourcePresenter view isModified: false]!

test_adHocInspectComplexObjectInProjectBrowser2
	| inspector |
	self testsIssue: #issue464 withTitle: '(3.0.67) String does not understand #format: ... during doit'.
	self methodSourcePresenter value: 'ClassOrganizer new'.
	self methodSourcePresenter setFocus.
	
	[inspector := self projectsPresenter jadeInspect.
	self assert: (inspector model value isKindOf: Integer).	"the oop"
	self assert: inspector instVarListPresenter selection key equals: 'self'.
	self assert: inspector instVarListPresenter selection value equals: 'aClassOrganizer'.
	inspector instVarListPresenter selectionByIndex: 2.
	self assert: inspector instVarListPresenter selection key equals: '-.asOop'.
	self assert: inspector instVarListPresenter selection value
		equals: inspector model value printString.
	inspector instVarListPresenter selectionByIndex: 3.
	self assert: inspector instVarListPresenter selection key equals: '-classes'. 
	self assert: (inspector instVarListPresenter selection value isKindOf: OopType64).
	self assert: ('aClassSet(*' match: inspector documentPresenter value).
	inspector instVarListPresenter selectionByIndex: 4.
	self assert: inspector instVarListPresenter selection key equals: '-classNames'. 
	self assert: inspector instVarListPresenter selection value equals: (OopType64 fromInteger: 20).
	self assert: inspector documentPresenter value equals: 'nil'.
	inspector instVarListPresenter selectionByIndex: 5.
	self assert: inspector instVarListPresenter selection key equals: '-user'.
	self assert: (inspector instVarListPresenter selection value isKindOf: OopType64).
	self assert: ('aSymbolList( aSymbolDictionary(*' match: inspector documentPresenter value).
	inspector instVarListPresenter selectionByIndex: 8.
	self assert: inspector instVarListPresenter selection key equals: '-rootClass'. 
	self assert: (inspector instVarListPresenter selection value isKindOf: OopType64).
	self assert: inspector documentPresenter value equals: 'Object'
	]
			ensure: 
				[inspector view close.
				self methodSourcePresenter view isModified: false]!

test_allClassesAutoCommitOn
	"all classes is used by findClass and was returning
	an empty list when auto commit was turned on"

	| classCount |
	self testsIssue: #issue484 withTitle: '(Oscar-3.0.72) Empty Find Class dialog'.
	self setAutoCommit: false.
	self assert: self projectsPresenter allClasses notEmpty.
	classCount := session executeString: 'ClassOrganizer new classes size'.
	self assert: self projectsPresenter allClasses size equals: classCount.
	self setAutoCommit: true.
	
	[self assert: self projectsPresenter allClasses notEmpty.
	classCount := session executeString: 'ClassOrganizer new classes size'.
	self assert: self projectsPresenter allClasses size equals: classCount]
			ensure: [self setAutoCommit: false]!

test_autoCommit
	| methodListPresenter autoCommit |
	self testsIssue: #issue421 withTitle: 'Need a way to know if you are in autocommit'.
	methodListBrowser := JadePresenter browseImplementorsOf: #size session: session.
	methodListPresenter := methodListBrowser primaryPresenter.
	autoCommit := self projectsPresenter remoteAutoCommit.
	self assert: self projectsPresenter autoCommit equals: autoCommit.
	self assert: methodListPresenter autoCommit equals: autoCommit.
	self assert: transcript autoCommit equals: autoCommit.
	self projectsPresenter flipAutoCommit.
	self assert: self projectsPresenter remoteAutoCommit.
	self assert: self projectsPresenter autoCommit.
	self assert: methodListPresenter autoCommit.
	self assert: transcript autoCommit.
	methodListPresenter flipAutoCommit.
	self deny: (autoCommit := self projectsPresenter remoteAutoCommit).
	self deny: self projectsPresenter autoCommit.
	self deny: methodListPresenter autoCommit.
	self deny: transcript autoCommit.
	transcript flipAutoCommit.
	self assert: self projectsPresenter remoteAutoCommit.
	self assert: self projectsPresenter autoCommit.
	self assert: methodListPresenter autoCommit.
	self assert: transcript autoCommit.
!

test_autoCommitButtonFailureResetOnAbort
	self testsIssue: #issue462
		withTitle: '(3.0.66) silent commit conflict/failure when auto commit is enabled'.
	self assert: (projectsBrowser view viewNamed: 'autoCommitButton') backcolor equals: Color default.
	session executeString: 'UserGlobals at: #autoCommitTest put: (#key -> #value)'.
	self commitTransaction.
	self loginOtherSession.
	
	[RowanAnsweringService new setAutoCommit: true for: session.
	self
		executeStringInOtherSession: 'abort;
			executeString: ''(UserGlobals at: #autoCommitTest) value: #newValue'';
			commit'.
	session executeString: '(UserGlobals at: #autoCommitTest) value: #stillAnotherNewValue'.
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	self
		saveMethod: 'test1 ^123'
		in: 'RowanSample1Test'
		category: 'tests'.
	self assert: (projectsBrowser view viewNamed: 'autoCommitButton') backcolor equals: Color red.
	self assert: self projectsPresenter autoCommit equals: #failed.
	self abortTransaction.
	self assert: (projectsBrowser view viewNamed: 'autoCommitButton') backcolor equals: Color green]
			ensure: 
				[self logoutOtherSession.
				self abortTransaction.
				session executeString: 'UserGlobals removeKey: #autoCommitTest'.
				RowanAnsweringService new setAutoCommit: false for: session.
				self commitTransaction]!

test_autoCommitClickButtonAfterFailure
	self testsIssue: #issue462
		withTitle: '(3.0.66) silent commit conflict/failure when auto commit is enabled'.
	self assert: (projectsBrowser view viewNamed: 'autoCommitButton') backcolor equals: Color default.
	session executeString: 'UserGlobals at: #autoCommitTest put: (#key -> #value)'.
	self commitTransaction.
	self loginOtherSession.
	
	[RowanAnsweringService new setAutoCommit: true for: session.
	self
		executeStringInOtherSession: 'abort;
			executeString: ''(UserGlobals at: #autoCommitTest) value: #newValue'';
			commit'.
	session executeString: '(UserGlobals at: #autoCommitTest) value: #stillAnotherNewValue'.
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	self
		saveMethod: 'test1 ^123'
		in: 'RowanSample1Test'
		category: 'tests'.
	self assert: (projectsBrowser view viewNamed: 'autoCommitButton') backcolor equals: Color red.
	self assert: self projectsPresenter autoCommit equals: #failed.
	"flipAutoCommit is sent from the menu or button"
	self projectsPresenter flipAutoCommit.
	self deny: self projectsPresenter autoCommit.
	self assert: (projectsBrowser view viewNamed: 'autoCommitButton') backcolor equals: Color default]
			ensure: 
				[self logoutOtherSession.
				self abortTransaction.
				session executeString: 'UserGlobals removeKey: #autoCommitTest'.
				RowanAnsweringService new setAutoCommit: false for: session.
				self commitTransaction]!

test_autoCommitFailure
	self testsIssue: #issue462
		withTitle: '(3.0.66) silent commit conflict/failure when auto commit is enabled'.
	self assert: (projectsBrowser view viewNamed: 'autoCommitButton') backcolor equals: Color default.
	session executeString: 'UserGlobals at: #autoCommitTest put: (#key -> #value)'.
	self commitTransaction.
	self loginOtherSession.
	
	[RowanAnsweringService new setAutoCommit: true for: session.
	self
		executeStringInOtherSession: 'abort;
			executeString: ''(UserGlobals at: #autoCommitTest) value: #newValue'';
			commit'.
	session executeString: '(UserGlobals at: #autoCommitTest) value: #stillAnotherNewValue'.
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	self
		saveMethod: 'test1 ^123'
		in: 'RowanSample1Test'
		category: 'tests'.
	self assert: (projectsBrowser view viewNamed: 'autoCommitButton') backcolor equals: Color red.
	self assert: self projectsPresenter autoCommit equals: #failed]
			ensure: 
				[self logoutOtherSession.
				self abortTransaction.
				session executeString: 'UserGlobals removeKey: #autoCommitTest'.
				RowanAnsweringService new setAutoCommit: false for: session.
				self commitTransaction]!

test_autoDirtyDisplayMoveMethodsToCategory
	self testsIssue: #issue16 withTitle: 'Review/revisit semantics of font color/italic/bold etc.'.
	self selectServicesNamed: #('RowanSample1') in: self projectListPresenter.
	self selectServicesNamed: #('RowanSample1-Core') in: self packageListPresenter.
	self deny: self projectListPresenter selection isDirty.
	self deny: self packageListPresenter selection isDirty.
	self selectRowanSample1Class.
	self projectsPresenter basicAddMethodCategory: 'newCategory'.
	self selectCategoriesNamed: #('accessing').
	self selectMethodsNamed: #(#foo).
	self projectsPresenter moveMethods: self methodListPresenter selections toCategory: 'newCategory'.
	self assert: self projectListPresenter selection name = 'RowanSample1'.
	self assert: self projectListPresenter selection isDirty.
	self assert: self packageListPresenter selection name = 'RowanSample1-Core'.
	self assert: self packageListPresenter selection isDirty.
	"verify method moved"
	self selectCategoriesNamed: #('newCategory').
	self selectMethodsNamed: #(#foo).
	self assert: self methodListPresenter selection selector = #foo!

test_autoDirtyDisplayRemoveMethod
	self testsIssue: #issue16 withTitle: 'Review/revisit semantics of font color/italic/bold etc.'.
	self selectServicesNamed: #('RowanSample1') in: self projectListPresenter.
	self selectServicesNamed: #('RowanSample1-Core') in: self packageListPresenter.
	self deny: self projectListPresenter selection isDirty.
	self deny: self packageListPresenter selection isDirty.
	self selectRowanSample1Class.
	self selectCategoriesNamed: #('accessing').
	self selectMethodsNamed: #(#foo).
	self projectsPresenter removeMethods: self classListPresenter selections.
	self assert: self projectListPresenter selection name = 'RowanSample1'.
	self assert: self projectListPresenter selection isDirty.
	self assert: self packageListPresenter selection name = 'RowanSample1-Core'.
	self assert: self packageListPresenter selection isDirty!

test_blankCategoryRenameInvalid
	self testsIssue: #issue380
		withTitle: '(3.0.53) rename protocol is broken: `UndefinedObject does not understand #''select:''`'.
	self selectRowanSample1Class.
	self categoryListPresenter selection: 'accessing'.
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #ok. 
	[self projectsPresenter basicRenameCategoryFrom: 'accessing' to: String new.
	self assert: self categoryListPresenter selection equals: 'accessing']
		ensure: [TestMessageBox disableJadeiteTestMessageBox]!

test_browseClass
	| dictionaryPresenter |
	self testsIssue: #issue429 withTitle: '(3.0.60) ''Browse Class'' on Transcript gets walkback'.
	self selectRowanSample1Test.
	self
		saveMethod: 'deleteThisMethod

	self assert: RowanSample1 new foo = ''foo''
	Transcript cr; show: ''fnoodle''. 
	String new.'
		in: self projectsPresenter selectedClass name
		category: 'deleteMe'.
	self selectMethodNamed: #deleteThisMethod.
	self methodSourcePresenter view selectionRange: (35 to: 46).
	secondPresenter := self projectsPresenter browseSelectedClass.
	
	[self assert: self projectsPresenter selectedClass name equals: 'RowanSample1Test'.
	self deny: secondPresenter sameAs: self projectsPresenter.
	self assert: secondPresenter selectedClass name equals: 'RowanSample1']
			ensure: [self destroy: secondPresenter topShell].
	self selectRowanSample1Test.
	self selectMethodNamed: #deleteThisMethod.
	self methodSourcePresenter view selectionRange: (66 to: 75).
	dictionaryPresenter := self projectsPresenter browseSelectedClass.
	[self assert: dictionaryPresenter selectedClassName equals: 'TranscriptStreamPortable']
		ensure: [self destroy: dictionaryPresenter topShell].
	self methodSourcePresenter view selectionRange: (101 to: 106).
	dictionaryPresenter := self projectsPresenter browseSelectedClass.
	[self assert: ('String*' match: dictionaryPresenter selectedClassName)]
		ensure: [self destroy: dictionaryPresenter topShell]!

test_browseHierarchyImplementorsEnablement
	| commandQuery |
	self testsIssue: #issue399
		withTitle: 'The "exactly one object" warning may also provide an unrelated debugger stack'.
	self selectRowanSample1Test.
	self selectCategoryNamed: 'tests'.
	self selectMethodNamed: #test1.
	commandQuery := self
				queryCommand: #browseHierarchyImplementors
				inPresenter: self projectsPresenter
				view: self methodListPresenter view.
	self assert: commandQuery isEnabled.
	self selectMethodsNamed: #(#test1 #test2).
	commandQuery := self
				queryCommand: #browseHierarchyImplementors
				inPresenter: self projectsPresenter
				view: self methodListPresenter view.
	self deny: commandQuery isEnabled.
	self selectMethodsNamed: #().
	commandQuery := self
				queryCommand: #browseHierarchyImplementors
				inPresenter: self projectsPresenter
				view: self methodListPresenter view.
	self deny: commandQuery isEnabled!

test_browseHierarchySendersEnablement
	| commandQuery |
	self testsIssue: #issue399
		withTitle: 'The "exactly one object" warning may also provide an unrelated debugger stack'.
	self selectRowanSample1Test.
	self selectCategoryNamed: 'tests'.
	self selectMethodNamed: #test1.
	commandQuery := self
				queryCommand: #browseHierarchySenders
				inPresenter: self projectsPresenter
				view: self methodListPresenter view.
	self assert: commandQuery isEnabled.
	self selectMethodsNamed: #(#test1 #test2).
	commandQuery := self
				queryCommand: #browseHierarchySenders
				inPresenter: self projectsPresenter
				view: self methodListPresenter view.
	self deny: commandQuery isEnabled.
	self selectMethodsNamed: #().
	commandQuery := self
				queryCommand: #browseHierarchySenders
				inPresenter: self projectsPresenter
				view: self methodListPresenter view.
	self deny: commandQuery isEnabled!

test_browseImplementorsEnablement
	| commandQuery |
	self testsIssue: #issue399
		withTitle: 'The "exactly one object" warning may also provide an unrelated debugger stack'.
	self selectRowanSample1Test.
	self selectCategoryNamed: 'tests'.
	self selectMethodNamed: #test1.
	commandQuery := self
				queryCommand: #browseImplementors
				inPresenter: self projectsPresenter
				view: self methodListPresenter view.
	self assert: commandQuery isEnabled.
	self selectMethodsNamed: #(#test1 #test2).
	commandQuery := self
				queryCommand: #browseImplementors
				inPresenter: self projectsPresenter
				view: self methodListPresenter view.
	self deny: commandQuery isEnabled.
	self selectMethodsNamed: #().
	commandQuery := self
				queryCommand: #browseImplementors
				inPresenter: self projectsPresenter
				view: self methodListPresenter view.
	self deny: commandQuery isEnabled!

test_browseLiteralReferences
	| methodListPresenter source |
	self testsIssue: #issue256
		withTitle: 'Find string literals in addition to ''methods containing string'' would be useful'.
	self selectRowanSample1Class.
	source := 'theAString ^''apple'''.
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	source := 'invokeA ^self apple'.
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	source := 'theASymbol ^#apple'.
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self selectMethodNamed: #theAString.
	self selectMethodNamed: #invokeA.
	methodListBrowser := JadePresenter browseLiteralReferences: '''apple''' session: session.
	methodListPresenter := methodListBrowser primaryPresenter methodListPresenter methodListPresenter.
	self assert: methodListPresenter list size equals: 1.
	self assert: methodListPresenter selection selector equals: #theAString.
	methodListPresenter list
		do: [:methodService | self assert: ('*''apple''*' match: methodService source)]!

test_browseSameClassCategoriesCorrect
	"related bug found while fixing issue #344"

	| methodInSameClass newBrowser |
	self testsIssue: #issue344
		withTitle: 'Can''t use method menu in method list browser method list pane'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Definitions' in: self packageListPresenter.
	self selectServiceNamed: 'RwClassExtensionDefinition' in: self classListPresenter.
	self selectCategoryNamed: 'comparing'.
	self assert: self methodListPresenter list size equals: 1.
	self selectMethodNamed: #compareDictionary:againstBaseDictionary:into:elementClass:isMeta:.
	methodListBrowser := self projectsPresenter browseImplementors.
	self assert: self methodListPresenter list size equals: 1.	"original browser method list doesn't change"
	methodInSameClass := methodListBrowser primaryPresenter methodListPresenter methodListPresenter
				list detect: [:methodService | methodService className = 'RwClassExtensionDefinition'] ifNone: [].
	self denyIsNil: methodInSameClass.
	methodListBrowser primaryPresenter methodListPresenter methodListPresenter
		selection: methodInSameClass.
	newBrowser := methodListBrowser primaryPresenter methodListPresenter browseClass.
	
	[self assert: self methodListPresenter list size equals: 1.	"original browser method list doesn't change"
	self assert: newBrowser currentCard categoryListPresenter list notEmpty.
	self assert: self projectsPresenter categoryListPresenter list notEmpty.
	self assert: newBrowser currentCard categoryListPresenter list
		equals: self projectsPresenter categoryListPresenter list]
			ensure: [self destroy: newBrowser]!

test_browseSelectedMethods
	| methodListPresenter  commandQuery |
	self testsIssue: #issue388
		withTitle: '(3.0.53) useful to be able to open method browser on selected methods in project browser'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Core' in: self packageListPresenter.
	self selectServiceNamed: 'RowanClassService' in: self classListPresenter.
	self selectCategoryNamed: 'client commands'.
	commandQuery := self
				queryCommand: #browseSelectedMethods
				inPresenter: self projectsPresenter
				view: self methodListPresenter view.
	self deny: commandQuery isEnabled.
	self selectMethodsNamed: (Array
				with: #fileoutClass
				with: #removeMethods:
				with: #addCategory:).
	methodListBrowser := self projectsPresenter browseSelectedMethods.
	methodListPresenter := methodListBrowser primaryPresenter methodListPresenter methodListPresenter.
	self assert: methodListPresenter list size equals: 3.
	self assert: methodListPresenter list first selector equals: #addCategory:.
	self assert: methodListPresenter list second selector equals: #fileoutClass.
	self assert: methodListPresenter list third selector equals: #removeMethods:.
	self assert: ('Selected Methods*' match: methodListBrowser caption).
	commandQuery := self
				queryCommand: #browseSelectedMethods
				inPresenter: self projectsPresenter
				view: self methodListPresenter view.
	self assert: commandQuery isEnabled.
!

test_browseSendersEnablement
	| commandQuery |
	self testsIssue: #issue399
		withTitle: 'The "exactly one object" warning may also provide an unrelated debugger stack'.
	self selectRowanSample1Test.
	self selectCategoryNamed: 'tests'.
	self selectMethodNamed: #test1.
	commandQuery := self
				queryCommand: #browseSenders
				inPresenter: self projectsPresenter
				view: self methodListPresenter view.
	self assert: commandQuery isEnabled.
	self selectMethodsNamed: #(#test1 #test2).
	commandQuery := self
				queryCommand: #browseSenders
				inPresenter: self projectsPresenter
				view: self methodListPresenter view.
	self deny: commandQuery isEnabled.
	self selectMethodsNamed: #().
	commandQuery := self
				queryCommand: #browseSenders
				inPresenter: self projectsPresenter
				view: self methodListPresenter view.
	self deny: commandQuery isEnabled!

test_cannotSelectMultipleProjects
	self selectServicesNamed: #() in: self projectListPresenter.
	self assert: self projectListPresenter selections isEmpty.
	self selectServicesNamed: self rowanProjectNames in: self projectListPresenter.
	self assert: self rowanProjectNames size > 1. 
	self assert: self projectListPresenter selections size = 1!

test_categoryTextDisplay
	self testsIssue: #issue232 withTitle: 'cannot tell which `category` a method is in (Oscar-3.0.41)'.
	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Services-Core') in: self packageListPresenter.
	self selectServicesNamed: (Array with: 'RowanClassService') in: self classListPresenter.
	self assert: self projectsPresenter methodCategoryText value equals: String new.
	self selectCategoryNamed: 'client commands'.
	self assert: self projectsPresenter methodCategoryText value equals: String new.
	self selectMethodNamed: #removeMethods:.
	self assert: self projectsPresenter methodCategoryText value equals: 'Category: client commands'.
	self selectMethodsNamed: (Array
				with: #removeMethods:
				with: #renameCategoryFrom:to:
				with: #addCategory:).
	self assert: self projectsPresenter methodCategoryText value equals: 'Category: client commands'.	"category is shown if all selected methods are in same category"
	self selectServicesNamed: (Array with: 'RowanService') in: self classListPresenter.
	self assert: self projectsPresenter methodListPresenter list notEmpty.
	self assert: self projectsPresenter methodCategoryText value equals: String new.
	self selectMethodsNamed: (Array with: #browserTool with: #initialize).
	self assert: self projectsPresenter methodCategoryText value equals: 'Categories: (Multiple)'!

test_changeClassComment
	| comment okToChange |
	self testsIssue: #issue424 withTitle: 'Background colors of text pane '.
	self selectRowanSample1Class.
	comment := self projectsPresenter selectedClass comment.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[self selectCommentTab.
	self projectsPresenter classCommentPresenter value: 'change coming'.
	self assert: self projectsPresenter selectedClass comment equals: comment.
	self projectsPresenter classCommentPresenter value equals: 'change coming'.
	TestMessageBox plannedResult: #yes.	"keep changes"
	okToChange := self projectsPresenter isOkayToChange.
	self deny: okToChange.
	self projectsPresenter editSaveClassComment.
	okToChange := self projectsPresenter isOkayToChange.
	self assert: okToChange]
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

test_changeListSortOrder
	| changesBrowser |
	self testsIssue: #issue384
		withTitle: '(3.0.53) sort by `type` in changes view does not do complete job'.
	self dirtyProjectForChangeBrowser.
	changesBrowser := (RowanProjectService new name: 'RowanSample1') changesUsing: session.
	
	[changesBrowser operationListPresenter view columnClicked: 1.	"ascending Type"
	self assert: (changesBrowser operationListPresenter model collect: [:patch | patch typeString])
		equals: #('Addition' 'Addition' 'Addition' 'Addition' 'Modification' 'Removal') asOrderedCollection.
	changesBrowser operationListPresenter view columnClicked: 1.	"descending Type"
	self assert: (changesBrowser operationListPresenter model collect: [:patch | patch typeString])
		equals: #('Removal' 'Modification' 'Addition' 'Addition' 'Addition' 'Addition') asOrderedCollection.
	changesBrowser operationListPresenter view columnClicked: 2.	"ascending class name"
	self assert: (changesBrowser operationListPresenter model collect: [:patch | patch className])
		equals: #('DirtyProject1' 'DirtyProject2' 'RowanSample1' 'RowanSample1' 'RowanSample1' 'RowanSample1Test')
				asOrderedCollection.
	changesBrowser operationListPresenter view columnClicked: 2.	"descending class name"
	self assert: (changesBrowser operationListPresenter model collect: [:patch | patch className])
		equals: #('RowanSample1Test' 'RowanSample1' 'RowanSample1' 'RowanSample1' 'DirtyProject2' 'DirtyProject1')
				asOrderedCollection.
	changesBrowser operationListPresenter view columnClicked: 3.	"ascending selector"
	self assert: (changesBrowser operationListPresenter model collect: [:patch | patch selector])
		equals: #('' '' 'foo' 'goo' 'hoo' 'test1') asOrderedCollection.
	changesBrowser operationListPresenter view columnClicked: 3.	"descending selector"
	self assert: (changesBrowser operationListPresenter model collect: [:patch | patch selector])
		equals: #('test1' 'hoo' 'goo' 'foo' '' '') asOrderedCollection.
	changesBrowser operationListPresenter view columnClicked: 4.	"ascending details"
	self assert: (changesBrowser operationListPresenter model collect: [:patch | patch detailsString])
		equals: #('Class Definition' 'Class Definition' 'other' 'other' 'other' 'tests') asOrderedCollection.
	changesBrowser operationListPresenter view columnClicked: 4.	"descending details"
	self assert: (changesBrowser operationListPresenter model collect: [:patch | patch detailsString])
		equals: #('tests' 'other' 'other' 'other' 'Class Definition' 'Class Definition') asOrderedCollection]
			ensure: [self destroy: changesBrowser]!

test_changeVariableWithModifiedMethodSource
	self testsIssue: #issue454 withTitle: 'Variables tab, change variable selection, are not prompted to save method'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Core' in: self packageListPresenter.
	self selectServiceNamed: 'RowanClassService' in: self classListPresenter.
	self projectsPresenter selectVariableTab.
	self projectsPresenter variableListPresenter selection: 'instVarNames'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[self methodSourcePresenter value: 'foo ^1'.
	self methodSourcePresenter view isModified: true.
	TestMessageBox plannedResult: #no.
	self projectsPresenter variableListPresenter selection: 'classVarNames'.
	self selectVariableListEntryForcingEvent: 'classVarNames'.
	self assert: self projectsPresenter variableListPresenter selection equals: 'classVarNames'.
	self methodSourcePresenter value: 'foo ^2'.
	self methodSourcePresenter view isModified: true.
	TestMessageBox plannedResult: #yes.
	self selectVariableListEntryForcingEvent: 'instVarNames'.
	self assert: self projectsPresenter variableListPresenter selection equals: 'classVarNames']
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

test_classColoring
	| classService sunitBrowser |
	self testsIssue: #issue426 withTitle: 'Strange case of classes turning purple'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Tests' in: self packageListPresenter.
	sunitBrowser := self openWindow: [transcript jadeBrowseTests].
	
	[sunitBrowser primaryPresenter selectPackageNamed: 'Rowan-Services-Tests'.
	sunitBrowser primaryPresenter selectClassNamed: 'RowanClassServiceTest'.
	classService := self classListPresenter list
				detect: [:service | service name = 'RowanClassServiceTest'].
	self deny: (classService shouldColorAsExtension: self projectsPresenter).
	sunitBrowser primaryPresenter selectClassNamed: 'RowanPackageServiceTest'.
	classService := self classListPresenter list
				detect: [:service | service name = 'RowanPackageServiceTest'].
	self deny: (classService shouldColorAsExtension: self projectsPresenter).
	self selectHierarchyTab.
	classService := self classHierarchyPresenter model asBag
				detect: [:service | service name = 'RowanClassServiceTest'].
	self deny: (classService shouldColorAsExtension: self projectsPresenter).
	classService := self classHierarchyPresenter model asBag
				detect: [:service | service name = 'RowanPackageServiceTest'].
	self deny: (classService shouldColorAsExtension: self projectsPresenter)]
			ensure: [self destroy: sunitBrowser]!

test_classColoringExtension
	| classService sunitBrowser |
	self testsIssue: #issue426 withTitle: 'Strange case of classes turning purple'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Tests' in: self packageListPresenter.
	sunitBrowser := self openWindow: [transcript jadeBrowseTests].
	
	[sunitBrowser primaryPresenter selectPackageNamed: 'Rowan-Services-Tests'.
	sunitBrowser primaryPresenter selectClassNamed: 'RwRowanProjectIssuesTest'.
	classService := self classListPresenter list
				detect: [:service | service name = 'RwRowanProjectIssuesTest'].
	self assert: (classService shouldColorAsExtension: self projectsPresenter).
	self selectHierarchyTab.
	classService := self classHierarchyPresenter model asBag
				detect: [:service | service name = 'RwRowanProjectIssuesTest'].
	self assert: (classService shouldColorAsExtension: self projectsPresenter)]
			ensure: [self destroy: sunitBrowser]!

test_classDefinitionTemplateAfterRemove
	self testsIssue: #issue449 withTitle: '(3.0.63) missing class definition template in empty package'.
	self selectRowanSample1Test.
	self
		saveClass: 'Gnoofle'
		withInstVars: #()
		package: 'RowanSample1-Tests'.
	self assert: self projectsPresenter selectedClass name equals: 'Gnoofle'.
	self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass.
	self assert: self projectsPresenter classDefinitionPresenter value replaceCrLfWithLf
		equals: 'Object rwSubclass: ''NameOfSubclass''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''RowanSample1-Tests''
	options: #()
'
				replaceCrLfWithLf	"show the typical default template"!

test_classDefinitionTemplateAfterRemoveInHierarchy
	self testsIssue: #issue449 withTitle: '(3.0.63) missing class definition template in empty package'.
	self selectRowanSample1Test.
	self
		saveClass: 'Gnoofle'
		withInstVars: #()
		package: 'RowanSample1-Tests'.
	self selectHierarchyTab.
	self assert: self projectsPresenter selectedClass name equals: 'Gnoofle'.
	self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass.
	self assert: self projectsPresenter classDefinitionPresenter value replaceCrLfWithLf
		equals: 'nil subclass: ''Object''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	inDictionary: Globals
	options: #()
'
				replaceCrLfWithLf.	"leave the class template for convenience"
	self selectClassListTab.
	self assert: self projectsPresenter classDefinitionPresenter value replaceCrLfWithLf
		equals: 'Object rwSubclass: ''NameOfSubclass''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''RowanSample1-Tests''
	options: #()
'
				replaceCrLfWithLf	"show the typical default template"!

test_classDefinitionUpdatesAcrossTabs
	| source firstTab secondTab newSource |
	self testsIssue: #issue412 withTitle: '(3.0.56) incorrect project browser update on method accept '.
	firstTab := self projectsPresenter topShell cardsPresenter view cardLayout currentCard.
	self selectRowanSample1Test.
	self projectsPresenter addSystemBrowser.
	secondTab := self projectsPresenter topShell cardsPresenter view cardLayout currentCard.
	self selectRowanSample1Test.
	source := 'TestCase rwSubclass: ''RowanSample1Test''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''RowanSample1-Tests''
	options: #()
'.
	self assert: self projectsPresenter classDefinitionPresenter value equals: source replaceCrLfWithLf.
	self projectsPresenter topShell cardsPresenter view cardLayout cyclePreviousCard.
	newSource := 'TestCase rwSubclass: ''RowanSample1Test''
	instVarNames: #( abc)
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''RowanSample1-Tests''
	options: #()
'.
	self projectsPresenter classDefinitionPresenter value: newSource replaceCrLfWithLf.
	self projectsPresenter editSaveClass.
	self assert: self projectsPresenter topShell cardsPresenter view cardLayout currentCard
		sameAs: firstTab.
	self assert: self projectsPresenter classDefinitionPresenter value equals: newSource replaceCrLfWithLf.
	self projectsPresenter topShell cardsPresenter view cardLayout cycleNextCard. 
	self assert: self projectsPresenter topShell cardsPresenter view cardLayout currentCard
		sameAs: secondTab.
	self assert: self projectsPresenter classDefinitionPresenter value equals: newSource replaceCrLfWithLf!

test_classDeselection
	| packageClassDefinition |
	self testsIssue: #issue475 withTitle: '(3.0.69) ''incorrect'' class creation template'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Core-Definitions-Extensions' in: self packageListPresenter.
	packageClassDefinition := 'Object rwSubclass: ''NameOfSubclass''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''Rowan-Core-Definitions-Extensions''
	options: #()
'
				replaceCrLfWithLf.
	self assert: self projectsPresenter classDefinitionPresenter value equals: packageClassDefinition.
	self selectServiceNamed: 'RwDefinition' in: self classListPresenter.	"extension class"
	self assert: self projectsPresenter classDefinitionPresenter value
		equals: 'Object rwSubclass: ''RwDefinition''
	instVarNames: #( properties)
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''Rowan-Definitions''
	options: #()
'
				replaceCrLfWithLf.
	self selectServicesNamed: #() in: self classListPresenter.
	self assert: self projectsPresenter classDefinitionPresenter value equals: packageClassDefinition!

test_classHierarchyDeselection
	| packageClassDefinition |
	self testsIssue: #issue475 withTitle: '(3.0.69) ''incorrect'' class creation template'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Core-Definitions-Extensions' in: self packageListPresenter.
	packageClassDefinition := 'Object rwSubclass: ''NameOfSubclass''
	instVarNames: #()
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''Rowan-Core-Definitions-Extensions''
	options: #()
'
				replaceCrLfWithLf.
	self assert: self projectsPresenter classDefinitionPresenter value equals: packageClassDefinition.
	self selectHierarchyTab.
	self selectClassInHierarchyNamed: 'RwDefinition'.	"extension class"
	self assert: self projectsPresenter classDefinitionPresenter value
		equals: 'Object rwSubclass: ''RwDefinition''
	instVarNames: #( properties)
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''Rowan-Definitions''
	options: #()
'
				replaceCrLfWithLf.
	self selectServicesNamed: #() in: self classHierarchyPresenter.
	self assert: self projectsPresenter classDefinitionPresenter value equals: packageClassDefinition!

test_classListNotBlank
	| rowanClass |
	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Services-Core') in: self packageListPresenter.
	self selectServicesNamed: (Array with: 'RowanClassService') in: self classListPresenter.
	self selectHierarchyTabIn: self projectsPresenter.
	self assert: self projectsPresenter classHierarchyPresenter selection name = 'RowanClassService'.
	self selectServicesNamed: #('Rowan-Kernel') in: self packageListPresenter.
	self selectClassListTab.
	self assert: self projectsPresenter classListPresenter list notEmpty. 
	rowanClass := self projectsPresenter classListPresenter list detect:[:classService | classService name = 'Rowan'] ifNone:[].
	self denyIsNil: rowanClass
	
	!

test_classListSelectionShouldNotUpdateOtherHierarchy
	self testsIssue: #issue374
		withTitle: '(3.0.53) selecting package in one project browser causes sympathetic update in other'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Definitions' in: self packageListPresenter.
	self selectServiceNamed: 'RwClassDefinition' in: self classListPresenter.
	self selectHierarchyTab.
	self
		assertLinearAncestry: #('Object' 'RwDefinition' 'RwAbstractClassDefinition' 'RwClassDefinition')
		in: self classHierarchyPresenter.
	self openSecondBrowser.
	
	[self selectServiceNamed: 'Rowan' in: secondBrowser currentCard projectListPresenter.
	self selectServiceNamed: 'Rowan-Definitions' in: secondBrowser currentCard packageListPresenter.
	self selectServiceNamed: 'RwMethodDefinition' in: secondBrowser currentCard classListPresenter.
	self
		assertLinearAncestry: #('Object' 'RwDefinition' 'RwAbstractClassDefinition' 'RwClassDefinition')
		in: self classHierarchyPresenter.
	self selectServiceNamed: 'RwPackageDefinition' in: secondBrowser currentCard classListPresenter.
	self
		assertLinearAncestry: #('Object' 'RwDefinition' 'RwAbstractClassDefinition' 'RwClassDefinition')
		in: self classHierarchyPresenter.
	self selectServiceNamed: 'RwClassExtensionDefinition' in: secondBrowser currentCard classListPresenter.
	self
		assertLinearAncestry: #('Object' 'RwDefinition' 'RwAbstractClassDefinition' 'RwClassDefinition')
		in: self classHierarchyPresenter.
	]
			ensure: [secondBrowser topShell exit]!

test_classRenameNoReferences
	self testsIssue: #issue439 withTitle: '`rename` class menu item would be useful'.
	self selectRowanSample1Test.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #('inst1')
		package: 'RowanSample1-Tests'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[self projectsPresenter selectClassNamed: 'TestClass'.
	TestMessageBox plannedResult: #ok.	"expect dialog box saying class was renamed"
	self projectsPresenter basicRenameClass: self projectsPresenter selectedClass to: 'RenamedClass'.
	self assertIsNil: (self classListPresenter list
				detect: [:classService | classService name asString = 'TestClass']
				ifNone: []).
	self assert: self classListPresenter selection name equals: 'RenamedClass']
			ensure: 
				[TestMessageBox disableJadeiteTestMessageBox.
				self projectsPresenter basicRemoveClass: self classListPresenter selection]!

test_classRenameNoReferencesHierarchy
	self testsIssue: #issue439 withTitle: '`rename` class menu item would be useful'.
	self selectRowanSample1Test.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #('inst1')
		package: 'RowanSample1-Tests'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[self projectsPresenter selectClassNamed: 'TestClass'.
	self selectHierarchyTab.
	self assert: self classHierarchyPresenter selection name equals: 'TestClass'.
	TestMessageBox plannedResult: #ok.	"expect dialog box saying class was renamed"
	self projectsPresenter basicRenameClass: self projectsPresenter selectedClass to: 'RenamedClass'.
	self assertIsNil: (self classListPresenter list
				detect: [:classService | classService name asString = 'TestClass']
				ifNone: []).
	self assert: self classHierarchyPresenter selection name equals: 'RenamedClass']
			ensure: 
				[TestMessageBox disableJadeiteTestMessageBox.
				self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass]!

test_classRenameResetsClassDefinition
	self testsIssue: #issue439 withTitle: '`rename` class menu item would be useful'.
	self selectRowanSample1Test.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #('inst1')
		package: 'RowanSample1-Tests'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[self projectsPresenter selectClassNamed: 'TestClass'.
	TestMessageBox plannedResult: #ok.	"expect dialog box saying class was renamed"
	self projectsPresenter basicRenameClass: self projectsPresenter selectedClass to: 'RenamedClass'.
	self assert: ('*Object rwSubclass: ''RenamedClass''*'
				match: self projectsPresenter classDefinitionPresenter value)]
			ensure: 
				[TestMessageBox disableJadeiteTestMessageBox.
				self projectsPresenter basicRemoveClass: self classListPresenter selection]!

test_classRenameWithReferences
	| list |
	self testsIssue: #issue439 withTitle: '`rename` class menu item would be useful'.
	self selectRowanSample1Test.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #('inst1')
		package: 'RowanSample1-Tests'.
	self
		saveClass: 'RefersToTestClass'
		superclass: 'Object'
		instVars: #('inst1')
		package: 'RowanSample1-Tests'.
	self
		saveMethod: 'meth  ^TestClass'
		in: 'RefersToTestClass'
		category: 'foo'.
	
	[self projectsPresenter selectClassNamed: 'TestClass'.
	methodListBrowser := self projectsPresenter basicRenameClass: self projectsPresenter selectedClass
				to: 'RenamedClass'.
	self assert: self classListPresenter selection name equals: 'RenamedClass'.
	list := methodListBrowser primaryPresenter methodListPresenter methodListPresenter list.
	self assert: list size equals: 1.
	self assert: list first selector equals: #meth.
	self assert: methodListBrowser primaryPresenter methodSourcePresenter documentPresenter selection equals: 'RenamedClass'. 
	]
			ensure: [self projectsPresenter basicRemoveClass: self classListPresenter selection]!

test_classRenameWithReferencesFailingCompile
	| list |
	self testsIssue: #issue439 withTitle: '`rename` class menu item would be useful'.
	self selectRowanSample1Test.
	self
		saveClass: 'Sub'
		superclass: 'Object'
		instVars: #('inst1')
		package: 'RowanSample1-Tests'.
	self
		saveClass: 'SubString'
		superclass: 'Object'
		instVars: #('inst1')
		package: 'RowanSample1-Tests'.
	self
		saveClass: 'RefersToTestClass'
		superclass: 'Object'
		instVars: #('inst1')
		package: 'RowanSample1-Tests'.
	self
		saveMethod: 'meth  | subString | subString := SubString. ^Sub'
		in: 'RefersToTestClass'
		category: 'wontCompile'.	"method refers to both. Will fail compilation
							based on current limitations in recompile method server code"
	
	[self projectsPresenter selectClassNamed: 'Sub'.
	methodListBrowser := self projectsPresenter basicRenameClass: self projectsPresenter selectedClass
				to: 'RenamedClass'.
	self assert: self classListPresenter selection name equals: 'RenamedClass'.
	list := methodListBrowser primaryPresenter methodListPresenter methodListPresenter list.
	self assert: list size equals: 1.
	self assert: list first selector equals: #meth.
	self assert: list first failedCompile.  "should show up as red. No way to easily test that" 
	self assert: methodListBrowser primaryPresenter methodSourcePresenter documentPresenter selectionRange  equals: (46 to: 48). "select old class on compile"
	]
			ensure: [self projectsPresenter basicRemoveClass: self classListPresenter selection]!

test_classRenameWithReferencesHierarchy
	| list |
	self testsIssue: #issue439 withTitle: '`rename` class menu item would be useful'.
	self selectRowanSample1Test.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #('inst1')
		package: 'RowanSample1-Tests'.
	self
		saveClass: 'RefersToTestClass'
		superclass: 'Object'
		instVars: #('inst1')
		package: 'RowanSample1-Tests'.
	self
		saveMethod: 'meth  ^TestClass'
		in: 'RefersToTestClass'
		category: 'foo'.
	
	[self projectsPresenter selectClassNamed: 'TestClass'.
	self selectHierarchyTab.
	self assert: self classHierarchyPresenter selection name equals: 'TestClass'.
	methodListBrowser := self projectsPresenter basicRenameClass: self projectsPresenter selectedClass
				to: 'RenamedClass'.
	self assert: self classHierarchyPresenter selection name equals: 'RenamedClass'.
	list := methodListBrowser primaryPresenter methodListPresenter methodListPresenter list.
	self assert: list size equals: 1.
	self assert: list first selector equals: #meth.
	self assert: methodListBrowser primaryPresenter methodSourcePresenter documentPresenter selection
		equals: 'RenamedClass']
			ensure: [self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass]!

test_classRenameWithReferencesSimilarNameButNoFailCompile
	| list |
	self testsIssue: #issue439 withTitle: '`rename` class menu item would be useful'.
	self selectRowanSample1Test.
	self
		saveClass: 'Sub'
		superclass: 'Object'
		instVars: #('inst1')
		package: 'RowanSample1-Tests'.
	self
		saveClass: 'SubString'
		superclass: 'Object'
		instVars: #('inst1')
		package: 'RowanSample1-Tests'.
	self
		saveClass: 'RefersToTestClass'
		superclass: 'Object'
		instVars: #('inst1')
		package: 'RowanSample1-Tests'.
	self
		saveMethod: 'meth  | subString | subString := SubString. ^Sub'
		in: 'RefersToTestClass'
		category: 'foo'.
	
	[self projectsPresenter selectClassNamed: 'SubString'.
	methodListBrowser := self projectsPresenter basicRenameClass: self projectsPresenter selectedClass
				to: 'RenamedClass'.
	self assert: self classListPresenter selection name equals: 'RenamedClass'.
	list := methodListBrowser primaryPresenter methodListPresenter methodListPresenter list.
	self assert: list size equals: 1.
	self assert: list first selector equals: #meth.
	self assert: methodListBrowser primaryPresenter methodSourcePresenter documentPresenter selection
		equals: 'RenamedClass']
			ensure: [self projectsPresenter basicRemoveClass: self classListPresenter selection]!

test_classSideSelection
	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Services-Core') in: self packageListPresenter.
	self selectServicesNamed: (Array with: 'RowanService') in: self classListPresenter.
	"select methods in class list view"
	self selectMethodsNamed: (Array with: #stonStringFor:).	"pick some methods that hopefully won't go away someday"
	self assert: self methodListPresenter selection selector == #stonStringFor:.
	self selectMethodsNamed: (Array with: #stonOn:).
	self assert: self methodListPresenter selection selector == #stonOn:.
	self selectMethodsNamed: (Array with: #command:).
	self assert: self methodListPresenter selection selector == #command:.
	"see same methods in hierarchy view"
	self selectHierarchyTab.
	self selectMethodsNamed: (Array with: #stonStringFor:).
	self assert: self methodListPresenter selection selector == #stonStringFor:.
	self selectMethodsNamed: (Array with: #stonOn:).
	self assert: self methodListPresenter selection selector == #stonOn:.
	self selectMethodsNamed: (Array with: #command:).
	self assert: self methodListPresenter selection selector == #command:.
	"see methods in class list view on class side"
	self selectClassListTab.
	self selectClassTab.
	self selectMethodsNamed: (Array with: #new).
	self assert: self methodListPresenter selection selector == #new.
	self methodListPresenter resetSelection.
	self assertIsNil: (self methodListPresenter list
				detect: [:methodService | methodService selector = #stonStringFor:]
				ifNone: []).
	self selectHierarchyTab.
	self selectMethodsNamed: (Array with: #new).
	self assert: self methodListPresenter selection selector == #new.
	self assertIsNil: (self methodListPresenter list
				detect: [:methodService | methodService selector = #stonStringFor:]
				ifNone: [])!

test_classTemplateWhenNoPackagesSelected
	"#resetClassTemplate is not a public method but still test that we
	don't walkback if no packages are selected when the projects presenter
	sends it"

	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self projectsPresenter selectClassDefinitionTab.
	self projectsPresenter resetClassTemplate.
	self assert: self projectsPresenter classDefinitionPresenter value isEmpty!

test_classVersionIncrementedInClassList
	self testsIssue: #issue228
		withTitle: 'lose selected class in project browser when new version created'.
	self selectServicesNamed: (Array with: 'RowanSample1') in: self projectListPresenter.
	self selectServicesNamed: #('RowanSample1-Tests') in: self packageListPresenter.
	self saveTestClassWithInstVars: Array new package: 'RowanSample1-Tests'.
	self selectServiceNamed: 'TestClass' in: self classListPresenter.
	self assert: self classListPresenter selection displayString equals: 'TestClass'.
	self saveTestClassWithInstVars: (Array with: 'a') package: 'RowanSample1-Tests'.
	self assert: self classListPresenter selection displayString equals: 'TestClass (2/2)'.
	self saveTestClassWithInstVars: (Array with: 'a' with: 'b') package: 'RowanSample1-Tests'.
	self assert: self classListPresenter selection displayString equals: 'TestClass (3/3)'.
	self saveTestClassWithInstVars: (Array
				with: 'a'
				with: 'b'
				with: 'c')
		package: 'RowanSample1-Tests'.
	self assert: self classListPresenter selection displayString equals: 'TestClass (4/4)'.
	self saveTestClassWithInstVars: Array new package: 'RowanSample1-Tests'.
	self assert: self classListPresenter selection displayString equals: 'TestClass (5/5)'!

test_classVersionIncrementedInHierarchy
	self testsIssue: #issue228
		withTitle: 'lose selected class in project browser when new version created'.
	self selectServicesNamed: (Array with: 'RowanSample1') in: self projectListPresenter.
	self selectServicesNamed: #('RowanSample1-Tests') in: self packageListPresenter.
	self saveTestClassWithInstVars: Array new package: 'RowanSample1-Tests'.
	self selectServiceNamed: 'TestClass' in: self classListPresenter.
	self assert: self classListPresenter selection displayString equals: 'TestClass'.
	self selectHierarchyTab.
	self saveTestClassWithInstVars: (Array with: 'a') package: 'RowanSample1-Tests'.
	self assert: self classListPresenter selection displayString equals: 'TestClass (2/2)'.
	self saveTestClassWithInstVars: (Array with: 'a' with: 'b') package: 'RowanSample1-Tests'.
	self assert: self classListPresenter selection displayString equals: 'TestClass (3/3)'.
	self saveTestClassWithInstVars: (Array
				with: 'a'
				with: 'b'
				with: 'c')
		package: 'RowanSample1-Tests'.
	self assert: self classListPresenter selection displayString equals: 'TestClass (4/4)'.
	self saveTestClassWithInstVars: Array new package: 'RowanSample1-Tests'.
	self assert: self classListPresenter selection displayString equals: 'TestClass (5/5)'!

test_closeConsoleInvalidSession
	| sunitPresenter workspace dictionaryBrowser hierarchyListBrowser simpleInspector complexInspector |
	"poison session and exit Jadeite. Make sure all Jadeite windows close"

	"otherwise the test will hang"
	self testsIssue: #issue267 withTitle: 'logout closes project browsers but not method list browsers'.
	self cleanupExistingWindows.
	self selectRowanSample1Class.
	self selectMethodNamed: #foo.
	methodListBrowser := self projectsPresenter browseImplementors.
	hierarchyListBrowser := self projectsPresenter browseHierarchyImplementors.
	sunitPresenter := transcript jadeBrowseTests.
	workspace := projectsBrowser addWorkspace.
	dictionaryBrowser := transcript openDictionaryBrowser.
	simpleInspector := JadeInspector showOn: (session
						executeString: '123'
						fromContext: nil
						environment: 0)
				session: session.
	complexInspector := JadeInspector showOn: (session
						executeString: 'Array new'
						fromContext: nil
						environment: 0)
				session: session.
	self assert: sunitPresenter isOpen.
	self assert: projectsBrowser isOpen.
	self assert: methodListBrowser isOpen.
	self assert: hierarchyListBrowser isOpen.
	self assert: dictionaryBrowser isOpen.
	self assert: simpleInspector isOpen.
	self assert: complexInspector isOpen.
	session beInvalidSession.
	
	[transcript onCloseRequested.
	self deny: sunitPresenter isOpen.
	self deny: projectsBrowser isOpen.
	self deny: methodListBrowser isOpen.
	self deny: hierarchyListBrowser isOpen.
	self deny: workspace isOpen.
	self deny: dictionaryBrowser isOpen.
	self deny: simpleInspector isOpen.
	self deny: complexInspector isOpen]
			ensure: 
				[projectsBrowser := nil.
				GciSession current: nil.
				JadeiteLoginShell allInstances first login.
				self resources do: 
						[:resource |
						resource current
							tearDown;
							setUp]]!

test_closeConsoleValidSession
	| sunitPresenter workspace dictionaryBrowser hierarchyListBrowser simpleInspector complexInspector |
	"poison session and exit Jadeite. Make sure all Jadeite windows close"
	self testsIssue: #issue267 withTitle: 'logout closes project browsers but not method list browsers'.
	self cleanupExistingWindows.
	self selectRowanSample1Class.
	self selectMethodNamed: #foo.
	methodListBrowser := self projectsPresenter browseImplementors.
	hierarchyListBrowser := self projectsPresenter browseHierarchyImplementors.
	sunitPresenter := transcript jadeBrowseTests.
	workspace := projectsBrowser addWorkspace.
	dictionaryBrowser := transcript openDictionaryBrowser.
	simpleInspector := JadeInspector showOn: (session
						executeString: '123'
						fromContext: nil
						environment: 0)
				session: session.
	complexInspector := JadeInspector showOn: (session
						executeString: 'Array new'
						fromContext: nil
						environment: 0)
				session: session.
	self assert: sunitPresenter isOpen.
	self assert: projectsBrowser isOpen.
	self assert: methodListBrowser isOpen.
	self assert: hierarchyListBrowser isOpen.
	self assert: dictionaryBrowser isOpen.
	self assert: simpleInspector isOpen.
	self assert: complexInspector isOpen.
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #yes.
	
	[[transcript onCloseRequested] ensure: [TestMessageBox disableJadeiteTestMessageBox].
	self deny: sunitPresenter isOpen.
	self deny: projectsBrowser isOpen.
	self deny: methodListBrowser isOpen.
	self deny: hierarchyListBrowser isOpen.
	self deny: workspace isOpen.
	self deny: dictionaryBrowser isOpen.
	self deny: simpleInspector isOpen.
	self deny: complexInspector isOpen]
			ensure: 
				[projectsBrowser := nil.
				GciSession current: nil.
				JadeiteLoginShell allInstances first login.
				self resources do: 
						[:resource |
						resource current
							tearDown;
							setUp]]!

test_comparisonTabMultimethod
	self testsIssue: #issue264
		withTitle: 'Method List Browser Comparison tab contents are sticky (3.0.74)'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Core' in: self packageListPresenter.
	self selectServiceNamed: 'RowanAnsweringService' in: self classListPresenter.
	self selectMethodsNamed: #(#answer #answer:).
	self projectsPresenter selectComparisonTab.
	self assert: self projectsPresenter comparisonPresenter beforeTitlePresenter value
		equals: 'RowanAnsweringService>>answer'.
	self assert: self projectsPresenter comparisonPresenter beforePresenter value
		equals: 'answer

	^answer' replaceCrLfWithLf.
	self assert: self projectsPresenter comparisonPresenter afterTitlePresenter value
		equals: 'RowanAnsweringService>>answer:'.
	self assert: self projectsPresenter comparisonPresenter afterPresenter value
		equals: 'answer: anObject

	answer := anObject' replaceCrLfWithLf!

test_comparisonTabNoMethodSelected
	self testsIssue: #issue264
		withTitle: 'Method List Browser Comparison tab contents are sticky (3.0.74)'.
	self selectRowanSample1Test.
	self projectsPresenter selectComparisonTab.
	self assert: self projectsPresenter comparisonPresenter beforeTitlePresenter value
		equals: String new.
	self assert: self projectsPresenter comparisonPresenter beforePresenter value equals: String new.
	self assert: self projectsPresenter comparisonPresenter afterTitlePresenter value equals: String new.
	self assert: self projectsPresenter comparisonPresenter afterPresenter value equals: String new!

test_comparisonTabSuperclass
	self testsIssue: #issue264
		withTitle: 'Method List Browser Comparison tab contents are sticky (3.0.74)'.
	self setupSupclassComparisonMethods.
	self selectServiceNamed: 'RowanSubClass' in: self classListPresenter.
	self selectMethodNamed: #comparisonMethod.
	self projectsPresenter selectComparisonTab.
	self assert: self projectsPresenter comparisonPresenter beforeTitlePresenter value
		equals: 'RowanSubClass>>comparisonMethod'.	"selected class on left"
	self assert: self projectsPresenter comparisonPresenter beforePresenter value
		equals: 'comparisonMethod  ^3 + 4'.
	self assert: self projectsPresenter comparisonPresenter afterTitlePresenter value
		equals: 'RowanSample1>>comparisonMethod'.	"superclass on left"
	self assert: self projectsPresenter comparisonPresenter afterPresenter value
		equals: 'comparisonMethod  ^self subclassResponsibility'!

test_compileClass
	self testsIssue: #issue390 withTitle: 'Rename instance variable with accessor method is... wonky'.
	self selectRowanSample1Class.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #('abc')
		package: 'RowanSample1-Core'.
	[self assert: self projectsPresenter selectedClass name = 'TestClass']
		ensure: [self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass]!

test_compileClassCompilerError
	"class definition string has a compile error. 
	Should get handled by the project browser"

	self testsIssue: #issue390 withTitle: 'Rename instance variable with accessor method is... wonky'.
	self selectRowanSample1Class.
	self projectsPresenter classDefinitionPresenter
		value: 'Object rwSubclass: ''TestClass''
	instVarNames: # abc )
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''RowanSample1-Core''
	options: #()'.
	self projectsPresenter editSaveClass.
	
	[self assert: self projectsPresenter classDefinitionPresenter value
		equals: 'Object rwSubclass: ''TestClass''
	instVarNames:  invalid pound sign # abc )
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''RowanSample1-Core''
	options: #()']
			ensure: 
				[self projectsPresenter classDefinitionPresenter view isModified: false.
				self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass]!

test_confirmOverrideExistingAccessorMethods
	self testsIssue: #issue382 withTitle: 'Add Accessors menu item is disabled'.
	self selectRowanSample1Class.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #('abc')
		package: 'RowanSample1-Core'.
	
	[self
		saveMethod: 'abc  ^123'
		in: 'TestClass'
		category: 'accessing'.
	self
		saveMethod: 'abc: foo ^123'
		in: 'TestClass'
		category: 'accessing'.
	self projectsPresenter selectVariableTab.
	self variableListPresenter selections: #('abc').
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #yes.	"proceed with accessor creation"
	[self projectsPresenter addVariableAccessors] ensure: [TestMessageBox disableJadeiteTestMessageBox].
	self selectMethodNamed: #abc.
	self assert: self methodSourcePresenter value equals: 'abc
	^abc'.
	self selectMethodNamed: #abc:.
	self assert: self methodSourcePresenter value equals: 'abc: object
	abc := object']
			ensure: [self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass]!

test_definedClassMenuItem
	| classMenuItem menuLabel |
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Core-Definitions-Extensions' in: self packageListPresenter.
	self selectServiceNamed: 'RwClassDefinition' in: self classListPresenter.
	menuLabel := 'Go To Defining Package (Rowan-Definitions)'.
	self assert: self projectsPresenter definedClassMenuItemLabel equals: menuLabel.
	self projectsPresenter updateClassMenu: self classListPresenter view contextMenu.	"triggered just before pop-up menu opens"
	classMenuItem := self classListPresenter view contextMenu items
				detect: [:commandItem | commandItem commandDescription command = #gotoClassDefinedPackage]
				ifNone: [^self error: 'go to defined package not found'].
	self assert: classMenuItem description equals: menuLabel.
	menuLabel := 'Go To Defining Package (Rowan-Core)'.
	self selectServiceNamed: 'Rowan-GemStone-Loader-Extensions' in: self packageListPresenter.
	self selectServiceNamed: 'RwClassModification' in: self classListPresenter.
	self assert: self projectsPresenter definedClassMenuItemLabel equals: menuLabel.
	self projectsPresenter updateClassMenu: self classListPresenter view contextMenu.	"triggered just before pop-up menu opens"
	self assert: classMenuItem description equals: menuLabel!

test_deselectAllVariables
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Core' in: self packageListPresenter.
	self selectServiceNamed: 'RowanClassService' in: self classListPresenter.
	self projectsPresenter selectVariableTab.
	self assert: self methodListPresenter list size
		equals: self projectsPresenter selectedClass methods size.
	self projectsPresenter variableListPresenter selection: 'instVarNames'.
	self deny: self methodListPresenter list size
		equals: self projectsPresenter selectedClass methods size.
	self projectsPresenter variableListPresenter selectionByIndex: 0.
	self assert: self methodListPresenter list size
		equals: self projectsPresenter selectedClass methods size!

test_dontChangeTabOnMethodSave
	| source firstTab secondTab |
	self testsIssue: #issue412 withTitle: '(3.0.56) incorrect project browser update on method accept '.
	firstTab := self currentTabView.
	self selectClassListTab.
	self selectRowanSample1Class.
	self selectMethodNamed: #foo.
	self projectsPresenter addSystemBrowser.
	secondTab := self currentTabView.
	self selectClassListTab.
	self selectRowanSample1Class.	"select class/method in new tab"
	self selectMethodNamed: #foo.
	self previousTabView.	"go to tab 1"
	source := 'foo ^''fooChanged'''.
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self assert: self methodSourcePresenter value equals: source.
	self assert: self currentTabView sameAs: firstTab.	"still on tab 1"
	self nextTabView.	"go to tab 2"
	self assert: self currentTabView sameAs: secondTab.
	self assert: self methodSourcePresenter value equals: source!

test_dontOverrideExistingAccessorMethods
	self testsIssue: #issue382 withTitle: 'Add Accessors menu item is disabled'.
	self selectRowanSample1Class.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #('abc')
		package: 'RowanSample1-Core'.
	
	[self
		saveMethod: 'abc  ^123'
		in: 'TestClass'
		category: 'accessing'.
	self
		saveMethod: 'abc: foo ^123'
		in: 'TestClass'
		category: 'accessing'.
	self projectsPresenter selectVariableTab.
	self variableListPresenter selections: #('abc').
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #no.	"do not create accessors"
	[self projectsPresenter addVariableAccessors] ensure: [TestMessageBox disableJadeiteTestMessageBox].
	self variableListPresenter selections: #().
	self selectMethodNamed: #abc.
	self assert: self methodSourcePresenter value equals: 'abc  ^123'.
	self selectMethodNamed: #abc:.
	self assert: self methodSourcePresenter value equals: 'abc: foo ^123']
			ensure: [self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass]!

test_dontUpdateWithDifferentMeta
	"don't update method or categories if the meta of the new
	class service is different than the selected class/instance tab"

	self testsIssue: #issue417 withTitle: '(3.0.56) extra method entries in project browser on accesp'.
	self selectRowanSample1Test.
	self assert: self categoryListPresenter list asArray equals: #('tests').
	self
		assert: (self methodListPresenter list collect: [:methodService | methodService selector]) asArray
		equals: #(#test1 #test2 #testError #testFailure).
	self openSecondBrowser.
	self selectRowanSample1Test.
	self assert: self categoryListPresenter list asArray equals: #('tests').
	self
		assert: (self methodListPresenter list collect: [:methodService | methodService selector]) asArray
		equals: #(#test1 #test2 #testError #testFailure).
	self selectClassTabIn: secondPresenter.
	self assert: self categoryListPresenter list asArray equals: #('tests').
	self
		assert: (self methodListPresenter list collect: [:methodService | methodService selector]) asArray
		equals: #(#test1 #test2 #testError #testFailure).
	self selectClassTab.
	self assert: secondPresenter categoryListPresenter list asArray equals: #().
	self
		assert: (secondPresenter methodListPresenter list collect: [:methodService | methodService selector])
				asArray
		equals: #()!

test_doubleClickIncludesColon
	"It's difficult to fake up a mouse event so ensure the method that grabs the colon
	is setup as an event and includes the colon after being called"

	self testsIssue: #issue301 withTitle: '(3.0.50) inconsistent selector selection on double-click'.
	self
		assert: (self methodSourcePresenter events at: #leftButtonDoubleClicked:) messages first asSymbol
		equals: #methodDoubleClicked:.
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	self methodSourcePresenter selectionRange: (14 to: 19).
	self assert: self methodSourcePresenter selection equals: 'assert'.
	self projectsPresenter methodDoubleClicked: nil.
	self assert: self methodSourcePresenter selectionRange equals: (14 to: 20).
	self assert: self methodSourcePresenter selection equals: 'assert:'!

test_dragClassDoesNotWalkback
	"Not really a drag drop but make sure that 
		class list is hooked up to the drag method we expect
		and we do not get an error in the expected drag method"

	| dragDropSession |
	self testsIssue: #issue334
		withTitle: 'Error on add subclass if that class is not not explicitly selected'.
	self selectRowanSample1Class.
	(self classListPresenter getEvents at: #drag:)
		messagesDo: [:message | self assert: message asSymbol equals: #onDragClass:].
	self saveTestClassWithInstVars: Array new package: 'RowanSample1-Tests'.
	dragDropSession := self classListPresenter view dragDropSessionClass new.
	self projectsPresenter onDragClass: dragDropSession.	"walkback occurred here"
	dragDropSession suggestedTarget: (self serviceNamed: 'TestClass' in: self classListPresenter).
	dragDropSession suggestedSource: (self serviceNamed: 'RowanSample1' in: self classListPresenter).
	"right now, this is testing the early-out condition. Just make sure it doesn't walkback."
	self assert: (self projectsPresenter onDragOverClassList: dragDropSession)
		equals: self projectsPresenter!

test_dragClassInHierarchyDoesNotWalkback
	"Not really a drag drop but make sure that 
		class list is hooked up to the drag method we expect
		and we do not get an error in the expected drag method"

	| dragDropSession |
	self testsIssue: #issue334
		withTitle: 'Error on add subclass if that class is not not explicitly selected'.
	self selectRowanSample1Class.
	(self classHierarchyPresenter getEvents at: #drag:)
		messagesDo: [:message | self assert: message asSymbol equals: #onDragClass:].
	self selectHierarchyTab.
	self assert: self classHierarchyPresenter selection name equals: 'RowanSample1'.
	self saveTestClassWithInstVars: Array new package: 'RowanSample1-Tests'.
	dragDropSession := self classHierarchyPresenter view dragDropSessionClass new.
	self projectsPresenter onDragClass: dragDropSession.	"walkback occurred here"
	dragDropSession suggestedTarget: (self serviceNamed: 'TestClass' in: self classListPresenter).
	dragDropSession suggestedSource: (self serviceNamed: 'RowanSample1' in: self classListPresenter).
	"right now, this is testing the early-out condition. Just make sure it doesn't walkback."
	self assert: (self projectsPresenter onDragClassHierarchy: dragDropSession)
		equals: self projectsPresenter!

test_dragDropMethodFailCompile
	| dragDropSession source |
	self testsIssue: #issue286
		withTitle: '(3.0.50) method drag drop only drags a single method when multiple methods selected?'.
	self selectRowanSample1Class.
	self projectsPresenter classDefinitionPresenter
		value: 'Object rwSubclass: ''Def''
	instVarNames: #(def)
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''RowanSample1-Core''
	options: #()
'.
	self projectsPresenter editSaveClass.
	self projectsPresenter classDefinitionPresenter
		value: 'Object rwSubclass: ''Abc''
	instVarNames: #(abc)
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''RowanSample1-Core''
	options: #()
'.
	self projectsPresenter editSaveClass.
	self assert: self classListPresenter selection name equals: 'Abc'.
	source := 'dragMe  ^abc'.
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	dragDropSession := self classListPresenter view dragDropSessionClass new.
	self projectsPresenter onDragMethod: dragDropSession.
	dragDropSession suggestedTarget: (self serviceNamed: 'Def' in: self classListPresenter).
	dragDropSession suggestedSource: self methodListPresenter selections.
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #ok.
	
	[self projectsPresenter onDropOnClassList: dragDropSession.	"should raise fail dialog here. answer ok"
	self assert: self projectsPresenter selectedClass name equals: 'Abc'.	"stay on drag source class"
	self assert: self methodListPresenter selections size equals: 1	"don't lose selection"]
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

test_dragDropMultipleMethods
	"don't really drop but we can simulate it and exercise the methods involved"

	| dragDropSession source |
	self testsIssue: #issue86
		withTitle: '(3.0.50) method drag drop only drags a single method when multiple methods selected?'.
	self selectRowanSample1Class.
	self selectCategoriesNamed: (Array with: 'accessing').
	source := 'dragMe1  ^1'.
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	source := 'dragMe2  ^2'.
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	source := 'dragMe3  ^3'.
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self selectMethodsNamed: #(#dragMe1 #dragMe2 #dragMe3).
	dragDropSession := self classHierarchyPresenter view dragDropSessionClass new.
	self projectsPresenter onDragMethod: dragDropSession.
	dragDropSession suggestedTarget: (self serviceNamed: 'RowanSubClass' in: self classListPresenter).
	dragDropSession suggestedSource: self methodListPresenter selections. 
	self projectsPresenter onDropOnClassList: dragDropSession.
	self assert: self projectsPresenter selectedClass name equals: 'RowanSubClass'.
	self assert: self methodListPresenter selections size equals: 3. 
	self assert: self methodListPresenter selections first selector equals: #dragMe1. 
	self assert: self methodListPresenter selections second selector equals: #dragMe2. 
	self assert: self methodListPresenter selections third selector equals: #dragMe3.!

test_dragDropMultipleMethodsHierarchy
	"don't really drop but we can simulate it and exercise the methods involved"

	| dragDropSession source |
	self testsIssue: #issue86
		withTitle: '(3.0.50) method drag drop only drags a single method when multiple methods selected?'.
	self selectRowanSample1Class.
	self selectCategoriesNamed: (Array with: 'accessing').
	source := 'dragMe1  ^1'.
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	source := 'dragMe2  ^2'.
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	source := 'dragMe3  ^3'.
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self selectHierarchyTab.
	self selectMethodsNamed: #(#dragMe1 #dragMe2 #dragMe3).
	dragDropSession := self classHierarchyPresenter view dragDropSessionClass new.
	self projectsPresenter onDragMethod: dragDropSession.
	dragDropSession suggestedTarget: (self serviceNamed: 'RowanSubClass' in: self classListPresenter).
	dragDropSession suggestedSource: self methodListPresenter selections. 
	self projectsPresenter onDropMethodsOnClassHierarchy: dragDropSession.
	self assert: self projectsPresenter selectedClass name equals: 'RowanSubClass'.
	self assert: self methodListPresenter selections size equals: 3. 
	self assert: self methodListPresenter selections first selector equals: #dragMe1. 
	self assert: self methodListPresenter selections second selector equals: #dragMe2. 
	self assert: self methodListPresenter selections third selector equals: #dragMe3.!

test_dropMethodOnClassHierarchy
	"don't really drop but we can simulate it and exercise the methods involved"

	| dragDropSession  newMethodService |
	self testsIssue: #issue213 withTitle: 'Cannot drag methods to class when using hierarchy view?'.
	self testsIssue: #issue354 withTitle: '(3.0.52) drag/drop of instance method ends up on class side'. 
	self selectServicesNamed: (Array with: 'RowanSample1') in: self projectListPresenter.
	self selectServicesNamed: #('RowanSample1-Core') in: self packageListPresenter.
	self selectHierarchyTab.
	self projectsPresenter selectClassNamed: self sampleClassName.
	self selectMethodNamed: #foo.
	dragDropSession := self classHierarchyPresenter view dragDropSessionClass new.
	self projectsPresenter onDragMethod: dragDropSession.
	dragDropSession suggestedTarget: (self serviceNamed: 'RowanSubClass' in: self classListPresenter).
	dragDropSession suggestedSource: (self serviceNamed: 'foo' in: self methodListPresenter).
	self projectsPresenter onDropMethodsOnClassHierarchy: dragDropSession.
	self assert: self projectsPresenter selectedClass name equals: 'RowanSubClass'.
	newMethodService :=  self methodListPresenter selections first.
	self assert: newMethodService selector equals: #foo.
	self deny: newMethodService meta. !

test_dropMethodOnClassList
	"don't really drop but we can simulate it and exercise the methods involved"

	| dragDropSession newMethodService |
	self testsIssue: #issue213 withTitle: 'Cannot drag methods to class when using hierarchy view?'.
	self testsIssue: #issue354 withTitle: '(3.0.52) drag/drop of instance method ends up on class side'. 
	self selectServicesNamed: (Array with: 'RowanSample1') in: self projectListPresenter.
	self selectServicesNamed: #('RowanSample1-Core') in: self packageListPresenter.
	self projectsPresenter selectClassNamed: self sampleClassName.
	self selectMethodNamed: #foo.
	dragDropSession := self classHierarchyPresenter view dragDropSessionClass new.
	self projectsPresenter onDragMethod: dragDropSession.
	dragDropSession suggestedTarget: (self serviceNamed: 'RowanSubClass' in: self classListPresenter).
	dragDropSession suggestedSource: (self serviceNamed: 'foo' in: self methodListPresenter).
	self projectsPresenter onDropMethodsOnClassHierarchy: dragDropSession.
	self assert: self projectsPresenter selectedClass name equals: 'RowanSubClass'.
	newMethodService :=  self methodListPresenter selections first.
	self assert: newMethodService selector equals: #foo.
	self deny: newMethodService meta. !

test_dropNonSelectedMethod
	"don't really drop but we can simulate it and exercise the methods involved"

	| dragDropSession newMethodService |
	self testsIssue: #issue443 withTitle: '(3.0.62) Error drag/drop of method'.
	self selectRowanSample1Class.
	dragDropSession := self classHierarchyPresenter view dragDropSessionClass new.
	self projectsPresenter onDragMethod: dragDropSession.
	dragDropSession suggestedTarget: (self serviceNamed: 'RowanSubClass' in: self classListPresenter).
	dragDropSession dragObjects add: (InternalDragDropObject object: (self serviceNamed: 'foo' in: self methodListPresenter)).
	self projectsPresenter onDropOnClassList: dragDropSession.
	self assert: self projectsPresenter selectedClass name equals: 'RowanSubClass'.
	newMethodService := self methodListPresenter selections first.
	self assert: newMethodService selector equals: #foo.
	self deny: newMethodService meta!

test_exitJadeiteInvalidSession
	| sunitPresenter workspace dictionaryBrowser hierarchyListBrowser simpleInspector complexInspector log |
	"poison session and exit Jadeite. Make sure all Jadeite windows close"
	self testsIssue: #issue267 withTitle: 'logout closes project browsers but not method list browsers'.
	self selectRowanSample1Class.
	self selectMethodNamed: #foo.
	methodListBrowser := self projectsPresenter browseImplementors.
	hierarchyListBrowser := self projectsPresenter browseHierarchyImplementors.
	sunitPresenter := transcript jadeBrowseTests.
	workspace := projectsBrowser addWorkspace.
	dictionaryBrowser := transcript openDictionaryBrowser.
	log := self projectsPresenter projectLog. 
	simpleInspector := JadeInspector showOn: (session
						executeString: '123'
						fromContext: nil
						environment: 0)
				session: session.
	complexInspector := JadeInspector showOn: (session
						executeString: 'Array new'
						fromContext: nil
						environment: 0)
				session: session.
	self assert: sunitPresenter isOpen.
	self assert: projectsBrowser isOpen.
	self assert: methodListBrowser isOpen.
	self assert: hierarchyListBrowser isOpen.
	self assert: dictionaryBrowser isOpen.
	self assert: simpleInspector isOpen.
	self assert: complexInspector isOpen.
	self assert: log isOpen. 
	session beInvalidSession.
	
	[transcript exit.
	self deny: sunitPresenter isOpen.
	self deny: projectsBrowser isOpen.
	self deny: methodListBrowser isOpen.
	self deny: hierarchyListBrowser isOpen.
	self deny: workspace isOpen.
	self deny: dictionaryBrowser isOpen.
	self deny: simpleInspector isOpen.
	self deny: complexInspector isOpen.
	self deny: log isOpen.]
			ensure: 
				[projectsBrowser := nil.
				GciSession current: nil.
				(Delay forSeconds: 1) wait. "not sure if this is necessary"
				JadeiteLoginShell allInstances first login.
				self resources do: 
						[:resource |
						resource current
							tearDown;
							setUp]]!

test_exitJadeiteValidSession
	| sunitPresenter workspace dictionaryBrowser hierarchyListBrowser simpleInspector complexInspector log |
	"poison session and exit Jadeite. Make sure all Jadeite windows close"
	self testsIssue: #issue267 withTitle: 'logout closes project browsers but not method list browsers'.
	self selectRowanSample1Class.
	self selectMethodNamed: #foo.
	methodListBrowser := self projectsPresenter browseImplementors.
	hierarchyListBrowser := self projectsPresenter browseHierarchyImplementors.
	sunitPresenter := transcript jadeBrowseTests.
	workspace := projectsBrowser addWorkspace.
	dictionaryBrowser := transcript openDictionaryBrowser.
	log := self projectsPresenter projectLog.
	simpleInspector := JadeInspector showOn: (session
						executeString: '123'
						fromContext: nil
						environment: 0)
				session: session.
	complexInspector := JadeInspector showOn: (session
						executeString: 'Array new'
						fromContext: nil
						environment: 0)
				session: session.
	self assert: sunitPresenter isOpen.
	self assert: projectsBrowser isOpen.
	self assert: methodListBrowser isOpen.
	self assert: hierarchyListBrowser isOpen.
	self assert: dictionaryBrowser isOpen.
	self assert: simpleInspector isOpen.
	self assert: complexInspector isOpen.
	self assert: log isOpen.
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #yes.
	
	[[transcript onCloseRequested] ensure: [TestMessageBox disableJadeiteTestMessageBox].
	self deny: sunitPresenter isOpen.
	self deny: projectsBrowser isOpen.
	self deny: methodListBrowser isOpen.
	self deny: hierarchyListBrowser isOpen.
	self deny: workspace isOpen.
	self deny: dictionaryBrowser isOpen.
	self deny: simpleInspector isOpen.
	self deny: complexInspector isOpen.
	self deny: log isOpen]
			ensure: 
				[projectsBrowser := nil.
				GciSession current: nil.
				(Delay forSeconds: 1) wait.	"not sure if this is necessary"
				JadeiteLoginShell allInstances first login.
				self resources do: 
						[:resource |
						resource current
							tearDown;
							setUp]]!

test_expansion
	"When no classes are selected and the hierarchy tab is chosen, we should
	see a hierarchy showing all superclasses of the packaged classes. 
	Subclasses are available with the > arrow. 
	"
	self testsIssue: #issue156 withTitle: 'Double click on hierarchy class should expand list #156'.
	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Kernel') in: self packageListPresenter.
	self assert: self classListPresenter model size equals: 2.
	self assert: self classListPresenter model first name equals: 'Rowan'.
	self assert: self classListPresenter model last name equals: 'RwPlatform'.
	self selectHierarchyTab.
	self assert: (self classHierarchyPresenter model asArray at: 1) name equals: 'Object'.
	self assert: (self classHierarchyPresenter model asArray at: 1) expand.
	self assert: (self classHierarchyPresenter model asArray at: 2) name equals: 'Rowan'.
	self deny: (self classHierarchyPresenter model asArray at: 2) expand.
	self assert: (self classHierarchyPresenter model asArray at: 3) name equals: 'RwPlatform'. "not expanded beyond packaged class"
	self deny: (self classHierarchyPresenter model asArray at: 3) expand.
	self assert: (self classHierarchyPresenter model asArray at: 4) name equals: 'RwGsPlatform'. "subclass in list available by > in super"
	self deny: (self classHierarchyPresenter model asArray at: 4) expand!

test_extensionColoringInHierarchy
	| testClass |
	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Specifications') in: self packageListPresenter.
	self selectServicesNamed: (Array with: 'RwPlatformSpecification') in: self classListPresenter.
	testClass := self classListPresenter list
				detect: [:classService | classService name = 'RwGemStoneSpecification']
				ifNone: [].
	self assertIsNil: testClass.	"Our guy is an extension"
	self selectHierarchyTab.
	self
		assert: self projectsPresenter classHierarchyPresenter selection name = 'RwPlatformSpecification'.
	self deny: (self projectsPresenter classHierarchyPresenter selection
				shouldColorAsExtension: self projectsPresenter).
	self selectClassInHierarchyNamed: 'RwGemStoneSpecification'.
	self assert: (self projectsPresenter classHierarchyPresenter selection
				shouldColorAsExtension: self projectsPresenter)!

test_extensionMethodSelection
	| source |
	self testsIssue: #issue352
		withTitle: 'Create method on class not in selected package, method disappears'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-GemStone-Loader-Extensions' in: self packageListPresenter.
	self selectServiceNamed: 'RwClassMove' in: self classListPresenter.
	self selectMethodNamed: #addMovedClassToPatchSet:.
	self assert: self classListPresenter selection name equals: 'RwClassMove'.
	self assert: self methodListPresenter selection selector equals: #addMovedClassToPatchSet:.
	self assert: ('addMovedClassToPatchSet:*' match: self methodSourcePresenter model value).
	self assert: self methodListPresenter selection category first equals: $*.	"extension method category"
	source := 'addMovedClassToPatchSet2 
		^#thisIsATestMethod'.
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self denyIsNil: (self methodListPresenter list
				detect: [:methodService | methodService selector = #addMovedClassToPatchSet:]
				ifNone: []).
	self assert: self methodListPresenter selection selector equals: #addMovedClassToPatchSet2.
	self assert: self categoryListPresenter selection equals: '*rowan-gemstone-loader-extensions'.
	self assert: self classListPresenter selection name equals: 'RwClassMove'.
	self assert: self projectsPresenter definedMethodPackageText value
		equals: 'Defined Package: Rowan-GemStone-Loader-Extensions'.
	self assert: self projectsPresenter methodCategoryText value
		equals: 'Category: *rowan-gemstone-loader-extensions'.
	transcript projectListPresenter abortTransaction.	"clean up Rowan project"
	[] ensure: 
			[self cloneRowanSample1.
			self ensureRowanSample1Loaded]!

test_failMethodCompile
	| source |
	self testsIssue: #issue458 withTitle: '(3.0.64) category error'.
	self selectRowanSample1Test.
	self projectsPresenter basicAddMethodCategory: 'newCategory'.
	
	[source := 'failCompile  aaaaa'.
	self methodSourcePresenter value: source.
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #ok.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self selectCategoryNamed: 'tests'.	"error happened here"
	self assertIsNil: (self methodListPresenter list
				detect: [:methodService | methodService selector = #failCompile]
				ifNone: [])]
			ensure: [self projectsPresenter basicRemoveMethodCategories]!

test_filtersUpdatedInHierarchyView
	| selectedClass browserServiceCategories |
	self testsIssue: #issue343 withTitle: 'Category/Variables tab not updating correctly'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Core' in: self packageListPresenter.
	self selectServiceNamed: 'RowanBrowserService' in: self classListPresenter.
	self selectHierarchyTab.
	self assert: self projectsPresenter isCategoryTabSelected.
	self assert: self categoryListPresenter list notEmpty.
	browserServiceCategories := self categoryListPresenter list.
	self projectsPresenter selectVariableTab.
	self assert: self variableListPresenter list notEmpty.
	selectedClass := self projectsPresenter selectedClass.
	self assert: selectedClass name equals: 'RowanBrowserService'.
	selectedClass instVarNames
		do: [:instVar | self assert: (self variableListPresenter list includes: instVar asString)].
	self selectClassInHierarchyNamed: 'RowanService'.
	self assert: self variableListPresenter list notEmpty.
	selectedClass := self projectsPresenter selectedClass.
	self assert: selectedClass name equals: 'RowanService'.
	selectedClass instVarNames
		do: [:instVar | self assert: (self variableListPresenter list includes: instVar asString)].
	self projectsPresenter selectCategoryTab. 
	self deny: browserServiceCategories size equals: self categoryListPresenter list size. "At least test that something changed since the categories will change" !

test_findClass
	self projectsPresenter updateAfterFindClass: (RowanClassService new name: 'RwGsPlatform').
	self assert: self classListPresenter selection name equals: 'RwGsPlatform'.
	self assert: self classListPresenter selection definedPackageName equals: 'Rowan-GemStone-Core'.
	self assert: self packageListPresenter selection name equals: 'Rowan-GemStone-Core'.
	self assert: self projectListPresenter selection name equals: 'Rowan'.
	self projectsPresenter updateAfterFindClass: (RowanClassService new name: 'CypressClassDefinition').
	self assert: self classListPresenter selection name equals: 'CypressClassDefinition'.
	self assert: self classListPresenter selection definedPackageName equals: 'Cypress-Definitions'.
	self assert: self packageListPresenter selection name equals: 'Cypress-Definitions'.
	self assert: self projectListPresenter selection name equals: 'Cypress'!

test_findDialogBasic
	| methodSourceView findView |
	self testsIssue: #issue468 withTitle: 'Find text dialog does not highlight correctly'.
	self selectRowanSample1Test.
	self selectMethodNamed: #testError.
	methodSourceView := self projectsPresenter methodSourcePresenter view.
	findView := methodSourceView findPrompt: 'RowanSample1'.
	
	[self assert: self methodSourcePresenter selection equals: String new.
	self assert: findView patternPresenter value equals: 'RowanSample1'.
	findView findNext.
	self assert: self methodSourcePresenter selection equals: 'RowanSample1']
			ensure: [findView view close]!

test_findMethodChangesCategories
	| methodService | 
	self testsIssue: #issue420 withTitle: 'Customer requests "Find Method" feature'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Core' in: self packageListPresenter.
	self selectServiceNamed: 'RowanClassService' in: self classListPresenter.
	self assertMethodInList: #behavior. 
	self assert: self methodListPresenter selections isEmpty. 
	methodService  := self projectsPresenter methodListPresenter list detect:[:svc | svc selector = #behavior].
	self selectCategoryNamed: 'client commands'. 
	self denyMethodInList: #behavior. 
	JadePresenter basicBrowseMethod: methodService presenter: self projectsPresenter.
	self assert: self categoryListPresenter selection equals: 'Accessing'. 
	self assert: self methodListPresenter selection selector equals: #behavior. !

test_findMethodDisabled
	| commandQuery |
	self testsIssue: #issue420 withTitle: 'Customer requests "Find Method" feature'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Tests' in: self packageListPresenter.
	commandQuery := self
				queryCommand: #findMethod
				inPresenter: self projectsPresenter
				view: self classListPresenter view.
	self deny: commandQuery isEnabled.
	self selectRowanSample1Test.
	commandQuery := self
				queryCommand: #findMethod
				inPresenter: self projectsPresenter
				view: self classListPresenter view.
	self assert: commandQuery isEnabled.!

test_findMethodDoesNotChangeCategories
	| methodService | 
	self testsIssue: #issue420 withTitle: 'Customer requests "Find Method" feature'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Core' in: self packageListPresenter.
	self selectServiceNamed: 'RowanClassService' in: self classListPresenter.
	self assertMethodInList: #behavior. 
	self assert: self methodListPresenter selections isEmpty. 
	methodService  := self projectsPresenter methodListPresenter list detect:[:svc | svc selector = #filters].
	self selectCategoryNamed: 'Accessing'. 
	self assertMethodInList: #behavior. 
	JadePresenter basicBrowseMethod: methodService presenter: self projectsPresenter.
	self assert: self categoryListPresenter selection equals: 'Accessing'. 
	self assert: self methodListPresenter selection selector equals: #filters. !

test_findMethodDoesNothingWhenClassNotSelected
	self testsIssue: #issue420 withTitle: 'Customer requests "Find Method" feature'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Core' in: self packageListPresenter.
	self assert: self projectsPresenter findMethod equals: self projectsPresenter. "would normally raise a dialog" !

test_findMethodShowsAllMethods
	| methodListSize unopenedDialog |
	self testsIssue: #issue420 withTitle: 'Customer requests "Find Method" feature'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Core' in: self packageListPresenter.
	self selectServiceNamed: 'RowanClassService' in: self classListPresenter.
	self selectCategoryNamed: 'other'.
	methodListSize := self methodListPresenter list size.
	unopenedDialog := JadeiteFindMethodDialog create: 'DefaultView'
				on: self projectsPresenter selectedClass.
	self assert: unopenedDialog listPresenter list size
		equals: self projectsPresenter selectedClass methods size.
	self assert: unopenedDialog listPresenter list size > methodListSize!

test_findMethodShowsOnlyOneSide
	| unopenedDialog |
	self testsIssue: #issue420 withTitle: 'Customer requests "Find Method" feature'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Core' in: self packageListPresenter.
	self selectServiceNamed: 'RowanService' in: self classListPresenter.
	unopenedDialog := JadeiteFindMethodDialog create: 'DefaultView'
				on: self projectsPresenter selectedClass.
	self assertIsNil: (unopenedDialog listPresenter list
				detect: [:methodService | methodService selector = #autoCommit]
				ifNone: []).
	self denyIsNil: (unopenedDialog listPresenter list
				detect: [:methodService | methodService selector = #answer:]
				ifNone: []). 
	self projectsPresenter selectClassTab.
	unopenedDialog := JadeiteFindMethodDialog create: 'DefaultView'
				on: self projectsPresenter selectedClass.
	self denyIsNil: (unopenedDialog listPresenter list
				detect: [:methodService | methodService selector = #autoCommit]
				ifNone: []).
	self assertIsNil: (unopenedDialog listPresenter list
				detect: [:methodService | methodService selector = #answer:]
				ifNone: []). !

test_findMethodSUnitBrowser
	"make sure find method works when sunit is open" 
	self testsIssue: #issue420 withTitle: 'Customer requests "Find Method" feature'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Core' in: self packageListPresenter.
	self selectSUnitTab.
	self assert: self projectsPresenter findMethod equals: self projectsPresenter. "error occurred just calling the method" !

test_findUsedEverywhere
	"Want to pick up the Jadeite Find Dialog in any text pane"

	| workspace |
	self testsIssue: #issue468 withTitle: 'Find text dialog does not highlight correctly'.
	self assert: self projectsPresenter methodSourcePresenter view isKindOf: JadeiteScintillaView.
	self assert: self projectsPresenter classDefinitionPresenter view isKindOf: JadeiteScintillaView.
	self assert: self projectsPresenter classCommentPresenter view isKindOf: JadeiteScintillaView.
	self assert: self projectsPresenter comparisonPresenter beforePresenter view
		isKindOf: JadeiteScintillaView.
	self assert: self projectsPresenter comparisonPresenter afterPresenter view
		isKindOf: JadeiteScintillaView.
	methodListBrowser := JadePresenter browseImplementorsOf: #setUp session: session.
	
	[self assert: methodListBrowser primaryPresenter methodSourcePresenter documentPresenter view
		isKindOf: JadeiteScintillaView.
	self assert: methodListBrowser primaryPresenter comparisonPresenter beforePresenter view
		isKindOf: JadeiteScintillaView.
	self assert: methodListBrowser primaryPresenter comparisonPresenter afterPresenter view
		isKindOf: JadeiteScintillaView]
			ensure: [methodListBrowser view close].
	self assert: transcript transcriptPresenter documentPresenter view isKindOf: JadeiteScintillaView.
	self assert: transcript codePane documentPresenter view isKindOf: JadeiteScintillaView.
	workspace := JadeWorkspace showOnSession: session.
	[self assert: workspace codePane documentPresenter view isKindOf: JadeiteScintillaView]
		ensure: [workspace view close]!

test_getClassCommentWithDeprecationsOn
	"code was trying to use deprecated method #description"

	self testsIssue: #issue507 withTitle: '(NONE) package browsing invokes deprecated method (3.0.74)'.
	session executeString: 'Deprecated doErrorOnDeprecated'.
	
	[self selectNoneProject.
	self selectServiceNamed: 'Globals' in: self dictionaryPresenter.
	self selectServiceNamed: 'AbstractException' in: self classListPresenter.
	self assert: self projectsPresenter selectedClass comment notEmpty.
	self selectServiceNamed: 'AbstractDictionary' in: self classListPresenter.
	self assert: self projectsPresenter selectedClass comment notEmpty.
	self selectClassTab.
	self selectServiceNamed: 'AbstractException' in: self classListPresenter.
	self assert: self projectsPresenter selectedClass comment notEmpty.
	self selectServiceNamed: 'AbstractDictionary' in: self classListPresenter.
	self assert: self projectsPresenter selectedClass comment notEmpty.
	self selectHierarchyTab.
	self selectServiceNamed: 'AbstractException' in: self classListPresenter.
	self assert: self projectsPresenter selectedClass comment notEmpty.
	self selectClassTab.
	self assert: self projectsPresenter selectedClass comment notEmpty]
			ensure: [session executeString: 'Deprecated doNothingOnDeprecated']!

test_gitBranchesDoesNotShowHead
	"this may be a brittle test because it assumes RowanSample1 has only the master branch.
	But it's based on the local checkout so the test runner can control this. "

	| branchesString branches |
	self testsIssue: #issue311
		withTitle: 'improper `checkout list` display, when any tag is checked out (walkback in 3.0.56)'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	branchesString := session
				executeString: 'Rowan gitTools gitbranchIn: (RwProject newNamed: ''RowanSample1'') repositoryRootPath with: '''''.
	self assert: (branchesString copyWithout: Character lf) equals: '* master'.
	branches := (RowanProjectService new name: 'RowanSample1')
				basicCheckoutUsing: self projectsPresenter.
	self assert: branches isKindOf: Collection.
	self assert: branches first equals: '*master'!

test_goToDefinedClassFromClassList
	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Services-Extensions') in: self packageListPresenter.
	self selectServicesNamed: (Array with: 'RwGsPlatform') in: self classListPresenter.
	self assert: self projectsPresenter isClassListTabSelected.
	self projectsPresenter gotoClassDefinedPackage.
	self assert: self classListPresenter selection name = 'RwGsPlatform'.
	self assert: self packageListPresenter selection name = 'Rowan-GemStone-Core'!

test_goToDefinedClassFromHierarchy
	| gotoClass |
	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Specifications') in: self packageListPresenter.
	self selectServicesNamed: (Array with: 'RwPlatformSpecification') in: self classListPresenter.
	gotoClass := self classListPresenter list
				detect: [:classService | classService name = 'RwGemStoneSpecification']
				ifNone: [].
	self assertIsNil: gotoClass.	"Our guy is an extension"
	self selectHierarchyTab.
	self deny: self projectsPresenter isClassListTabSelected.
	self selectClassInHierarchyNamed: 'RwGemStoneSpecification'.
	self projectsPresenter gotoClassDefinedPackage.
	self assert: self packageListPresenter selection name = 'Rowan-GemStone-Specifications'!

test_goToDefinedMethodFromClassList
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Extensions' in: self packageListPresenter.
	self selectServiceNamed: 'RwGsPlatform' in: self classListPresenter.
	self selectCategoryNamed: '*rowan-services-extensions'.
	self selectMethodNamed: #classServiceClass.
	self assert: self projectsPresenter isClassListTabSelected.
	self projectsPresenter gotoMethodDefinedPackage.
	self assert: self packageListPresenter selection name = 'Rowan-Services-Extensions'.
	self assert: self classListPresenter selection name = 'RwGsPlatform'.
	self assert: self categoryListPresenter selection = '*rowan-services-extensions'.
	self assert: self methodListPresenter selection selector = #classServiceClass.
	self assert: self projectsPresenter isClassListTabSelected!

test_goToDefinedMethodFromClassListClassSide
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-GemStone-Loader-Extensions' in: self packageListPresenter.
	self selectServiceNamed: 'RwGsImage' in: self classListPresenter.
	self selectClassTab.
	self selectCategoryNamed: '*rowan-gemstone-loader-extensions'.
	self selectMethodNamed: #_shouldCloneRowanLoader:.
	self assert: self projectsPresenter isClassListTabSelected.
	self projectsPresenter gotoMethodDefinedPackage.
	self assert: self packageListPresenter selection name = 'Rowan-GemStone-Loader-Extensions'.
	self assert: self classListPresenter selection name = 'RwGsImage'.
	self assert: self categoryListPresenter selection = '*rowan-gemstone-loader-extensions'.
	self assert: self methodListPresenter selection selector = #_shouldCloneRowanLoader:.
	self assert: self projectsPresenter isClassListTabSelected.
	self assert: self projectsPresenter isClassSideSelected!

test_goToDefinedMethodFromHierarchy
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Extensions' in: self packageListPresenter.
	self selectServiceNamed: 'RwGsPlatform' in: self classListPresenter.
	self selectHierarchyTab.
	self selectCategoryNamed: '*rowan-services-extensions'.
	self selectMethodNamed: #classServiceClass.
	self deny: self projectsPresenter isClassListTabSelected.
	self projectsPresenter gotoMethodDefinedPackage.
	self assert: self packageListPresenter selection name = 'Rowan-Services-Extensions'.
	self assert: self classListPresenter selection name = 'RwGsPlatform'.
	self assert: self categoryListPresenter selection = '*rowan-services-extensions'.
	self assert: self methodListPresenter selection selector = #classServiceClass.
	self assert: self projectsPresenter isClassListTabSelected	"make my life easier by forcing the class side to be seleted"!

test_gotoDefinedMethodNotSameAsClass
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Definitions' in: self packageListPresenter.
	self selectServiceNamed: 'RwClassDefinition' in: self classListPresenter.
	self selectCategoryNamed: '*rowan-core-definitions-extensions'.
	self selectMethodNamed: #_methodsModificationClass.
	self projectsPresenter gotoMethodDefinedPackage.
	self assert: self packageListPresenter selection name = 'Rowan-Core-Definitions-Extensions'.
	self assert: self classListPresenter selection name = 'RwClassDefinition'.
	self assert: self categoryListPresenter selection = '*rowan-core-definitions-extensions'.
	self assert: self methodListPresenter selection selector = #_methodsModificationClass!

test_gotoDefinedPackage
	self testsIssue: #issue150 withTitle: 'Go to defining package -> Not found: a BlockClosure'.
	"different project within projects browser"
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Tools-Kernel' in: self packageListPresenter.
	self selectServiceNamed: 'CypressDefinition' in: self classListPresenter.
	self projectsPresenter gotoClassDefinedPackage.
	self assert: self projectListPresenter selection name = 'Cypress'.
	self assert: self packageListPresenter selection name = 'Cypress-Definitions'.
	self assert: self classListPresenter selection name = 'CypressDefinition'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-GemStone-Kernel' in: self packageListPresenter.
	self selectServiceNamed: 'ByteArray' in: self classListPresenter.
	self projectsPresenter gotoClassDefinedPackage.
	self assert: self dictionaryPresenter selection name = 'Globals'.
	self assert: self classListPresenter selection name = 'ByteArray'!

test_hierarchyCleanedUpAfterUnload
	"hierarchy classes were being left in the display
	after project was unloaded"

	self selectRowanSample1Test.
	self selectHierarchyTab.
	self deny: self classHierarchyPresenter model isEmpty.
	self projectsPresenter basicUnloadProjects: (self projectsPresenter projectListPresenter selections
				collect: [:service | service name]).
	[self assert: self classHierarchyPresenter model isEmpty]
		ensure: [self cloneRowanSample1	"rest of tests expect project to be available"]!

test_hierarchyFindsAllSubclassImplementors
	| listPresenter | 
	self testsIssue: #issue242 withTitle: '`implementors in hierarchy` doesn''t include method in the currently selected class?'.

	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Core') in: self packageListPresenter.
	self selectServicesNamed: (Array with: 'RwLoadedThing') in: self classListPresenter.
	self selectMethodNamed: #initialize.
	methodListBrowser := self projectsPresenter browseHierarchyImplementors.
	
	self assert: ('Hierarchy Implementors of ''initialize'' for *' match: methodListBrowser caption).
	listPresenter := methodListBrowser primaryPresenter methodListPresenter methodListPresenter. 
	self assert: listPresenter list size equals: 6.	
	listPresenter list do:[:methodService | self assert: methodService selector equals: #initialize]. 
	listPresenter list do:[:methodService |
		| classService | 
		classService := RowanClassService named: methodService className.
		classService command: #classHierarchy. 
		self issueCommand: classService. 
		self assert: (classService hierarchyClassServiceNames includes: 'RwLoadedThing')
		]. 
!

test_hierarchyImplementors
	"a little risky testing base code that might change but it is convenient"

	| methodListPresenter hierarchyListSize |
	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Core') in: self packageListPresenter.
	self selectServicesNamed: (Array with: 'RwModification') in: self classListPresenter.
	self selectMethodNamed: #isEmpty.
	methodListBrowser := self projectsPresenter browseHierarchyImplementors.
	
	[self assert: ('Hierarchy Implementors of ''isEmpty'' for *' match: methodListBrowser caption).
	methodListPresenter := methodListBrowser primaryPresenter methodListPresenter methodListPresenter.
	hierarchyListSize := methodListPresenter list size]
			ensure: [self destroy: methodListBrowser].
	methodListBrowser := self projectsPresenter browseImplementors.
	
	[self assert: ('Implementors of ''isEmpty'' for *' match: methodListBrowser caption).
	methodListPresenter := methodListBrowser primaryPresenter methodListPresenter methodListPresenter.
	self assert: methodListPresenter list size > hierarchyListSize	"always a superset"]
			ensure: [self destroy: methodListBrowser]!

test_hierarchyImplementorsFromMethodList
	"a little risky testing base code that might change but it is convenient"

	| methodListPresenter hierarchyMethodListPresenter |
	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Core') in: self packageListPresenter.
	self selectServicesNamed: (Array with: 'RwModification') in: self classListPresenter.
	self selectMethodNamed: #isEmpty.
	methodListBrowser := self projectsPresenter browseImplementors.
	methodListPresenter := methodListBrowser primaryPresenter methodListPresenter.
	hierarchyMethodListPresenter := methodListPresenter browseHierarchyImplementors.	"first element should be selected"
	
	[self assert: methodListPresenter methodListPresenter list size
				>= hierarchyMethodListPresenter primaryPresenter methodListPresenter methodListPresenter list size	"always a superset"]
			ensure: 
				[self destroy: methodListBrowser.
				self destroy: hierarchyMethodListPresenter]!

test_hierarchyImplementorsSendersCaption
	self testsIssue: #issue209 withTitle: 'MethodListBrowser needs the token in the title bar'.
	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Services-Core') in: self packageListPresenter.
	self selectServicesNamed: (Array with: 'RowanProjectService') in: self classListPresenter.
	self selectMethodNamed: #branch.
	methodListBrowser := self projectsPresenter browseHierarchyImplementors.
	[self assert: ('Hierarchy Implementors of ''branch'' for *' match: methodListBrowser caption)]
		ensure: [self destroy: methodListBrowser].
	methodListBrowser := self projectsPresenter browseHierarchySenders.
	[self assert: ('Hierarchy Senders of ''branch'' for *' match: methodListBrowser caption)]
		ensure: [self destroy: methodListBrowser]!

test_hierarchyMethodsNotDisplayed
	| className source |
	self testsIssue: #issue290
		withTitle: '(3.0.50) wrong methods displayed when switching from a superclass to subclass'.
	self selectRowanSample1Test.
	self selectHierarchyTab.
	className := 'TestTestClass'.
	self
		saveClass: className
		superclass: 'RowanSample1Test'
		instVars: Array new
		package: 'RowanSample1-Tests'.
	self selectClassInHierarchyNamed: className.
	self projectsPresenter basicAddMethodCategory: 'tests'.
	source := 'subclassMethod1  ^#aaa'.
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self projectsPresenter classHierarchyPresenter selection.
	self assert: self methodListPresenter selection selector equals: #subclassMethod1.
	self projectsPresenter basicAddMethodCategory: 'zzz'.
	source := 'subclassMethod2  ^#foo'.
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self projectsPresenter classHierarchyPresenter selection.
	self assert: self methodListPresenter list size equals: 1.
	self assert: self methodListPresenter list first selector equals: #subclassMethod2.
	self selectClassInHierarchyNamed: 'RowanSample1Test'.
	self assertIsNil: self categoryListPresenter selectionOrNil.	"no zzz category in super"
	self assert: self methodListPresenter list size equals: 4.
	self assert: (self methodListPresenter list at: 1) selector equals: #test1.
	self assert: (self methodListPresenter list at: 2) selector equals: #test2.
	self assert: (self methodListPresenter list at: 3) selector equals: #testError.
	self assert: (self methodListPresenter list at: 4) selector equals: #testFailure.
	self selectClassInHierarchyNamed: className.
	self assertIsNil: self categoryListPresenter selectionOrNil.	"no category was previously selected"
	self assert: self methodListPresenter list size equals: 2.
	self assert: self methodListPresenter list first selector equals: #subclassMethod1.
	self assert: self methodListPresenter list last selector equals: #subclassMethod2!

test_hierarchySelectTwoBrowsers
	| firstBrowser |
	self testsIssue: #issue122 withTitle: 'Hierarchy tab selection updates incorrectly.'.
	firstBrowser := projectsBrowser.	"for easier reading"
	self openSecondBrowser. 
	
	[self selectRowanSample1Class.
	self selectServicesNamed: (Array with: 'RowanSample1')
		in: secondBrowser currentCard projectListPresenter.
	self selectServicesNamed: #('RowanSample1-Tests') in: secondBrowser currentCard packageListPresenter.
	self selectServicesNamed: (Array with: 'RowanSample1Test')
		in: secondBrowser currentCard classListPresenter.
	self selectHierarchyTabIn: firstBrowser currentCard.
	self assert: firstBrowser currentCard classHierarchyPresenter selection name = 'RowanSample1'.
	self selectHierarchyTabIn: secondBrowser currentCard.
	self assert: firstBrowser currentCard classHierarchyPresenter selection name = 'RowanSample1'.
	self assert: (firstBrowser currentCard classHierarchyPresenter isKindOf: TreePresenter).
	self assert: secondBrowser currentCard classHierarchyPresenter selection name = 'RowanSample1Test'.
	self assert: (secondBrowser currentCard classHierarchyPresenter isKindOf: TreePresenter)]
			ensure: [self destroy: secondBrowser]!

test_hierarchySenders
	"a little risky testing base code that might change but it is convenient"

	| methodListPresenter hierarchyListSize |
	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Core') in: self packageListPresenter.
	self selectServicesNamed: (Array with: 'RwModification') in: self classListPresenter.
	self selectMethodNamed: #isEmpty.
	methodListBrowser := self projectsPresenter browseHierarchySenders.
	
	[self assert: ('Hierarchy Senders of ''isEmpty'' for *' match: methodListBrowser caption).
	methodListPresenter := methodListBrowser primaryPresenter methodListPresenter methodListPresenter.
	hierarchyListSize := methodListPresenter list size]
			ensure: [self destroy: methodListBrowser].
	methodListBrowser := self projectsPresenter browseSenders.
	
	[self assert: ('Senders of ''isEmpty'' for *' match: methodListBrowser caption).
	methodListPresenter := methodListBrowser primaryPresenter methodListPresenter methodListPresenter.
	self assert: methodListPresenter list size >= hierarchyListSize	"always a superset"]
			ensure: [self destroy: methodListBrowser]!

test_hierarchySendersFromMethodList
	"a little risky testing base code that might change but it is convenient"

	| methodListPresenter hierarchyMethodListBrowser methodList classService hierarchyClassNames |
	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Core') in: self packageListPresenter.
	self selectServicesNamed: (Array with: 'RwModification') in: self classListPresenter.
	self selectMethodNamed: #isEmpty.
	methodListBrowser := self projectsPresenter browseHierarchyImplementors.
	methodListPresenter := methodListBrowser primaryPresenter methodListPresenter.
	hierarchyMethodListBrowser := methodListPresenter browseHierarchySenders.	"first element should be selected"
	
	[classService := RowanClassService named: 'RwModification'.
	classService command: #classHierarchy.
	self issueCommand: classService.
	methodList := hierarchyMethodListBrowser primaryPresenter methodListPresenter methodListPresenter
				list.
	hierarchyClassNames := classService hierarchyClassServiceNames.
	methodList
		do: [:methodService | self assert: (hierarchyClassNames includes: methodService className asString)]]
			ensure: 
				[self destroy: methodListBrowser.
				self destroy: hierarchyMethodListBrowser]!

test_hierarchyWithNonResolvableClass
	| unresolvableClassService |
	self testsIssue: #issue442
		withTitle: '(3.0.62) odd (but legal) class hierarchy causes trouble for Project Browser'.
	session executeString: 'RowanClassServiceTest new createHierarchyWithNonResolvableClass'.
	
	[self projectsPresenter refreshFromServer.
	self selectServiceNamed: 'Issue470' in: self projectListPresenter.
	self selectServiceNamed: 'Issue470-Core' in: self packageListPresenter.
	self selectServiceNamed: 'Issue470Class3' in: self classListPresenter.
	self selectHierarchyTab.
	self assert: self projectsPresenter selectedClass name equals: 'Issue470Class3'.
	unresolvableClassService := self projectsPresenter classHierarchyPresenter model asArray at: 3.
	self assert: unresolvableClassService name equals: 'Issue470Class2'.
	self assert: ('Issue470Class2 {*}' match: unresolvableClassService displayString).
	self deny: unresolvableClassService isInSymbolList]
			ensure: [self projectsPresenter basicUnloadProjects: #('Issue470')]!

test_implementorsSendersCaption
	self testsIssue: #issue209 withTitle: 'MethodListBrowser needs the token in the title bar'.
	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Services-Core') in: self packageListPresenter.
	self selectServicesNamed: (Array with: 'RowanProjectService') in: self classListPresenter.
	self selectMethodNamed: #branch.
	methodListBrowser := self projectsPresenter browseImplementors.
	[self assert: ('Implementors of ''branch'' for *' match: methodListBrowser caption)]
		ensure: [self destroy: methodListBrowser].
	methodListBrowser := self projectsPresenter browseSenders.
	[self assert: ('Senders of ''branch'' for *' match: methodListBrowser caption)]
		ensure: [self destroy: methodListBrowser]!

test_issue261
	"create a loaded project and test the info display"
	| view |
	self testsIssue: #issue261 withTitle: 'Project tab should display reason for project font styling'.
	self issue261createTestProject.
	
	[self selectServiceNamed: 'Izmir' in: self projectListPresenter.
	view := self projectsPresenter projectInfoTab view.
	self assert: (view columns first contentFromRow: (view list at: 3)) equals: 'Izmir'.
	self assert: (view columns first contentFromRow: (view list at: 7)).	"isDirty"]
			ensure: [self projectsPresenter basicUnloadProjects: #('Izmir')]!

test_loadProjectRemovingClass
	self selectRowanSample1Test.
	self assert: self classListPresenter list size equals: 1.
	self
		saveClass: 'FooTest'
		superclass: 'RowanSample1Test'
		instVars: #()
		package: 'RowanSample1-Tests'.
	self assert: self classListPresenter selection name equals: 'FooTest'.
	self loadProjectNamed: 'RowanSample1'.
	self assert: self classListPresenter selections isEmpty.
	self assert: self classListPresenter list size equals: 1!

test_makeDefault
	| nonDefaultService |
	self selectServicesNamed: (Array with: 'RowanSample1') in: self projectListPresenter.
	self projectsPresenter makeDefault.
	self assert: self projectListPresenter selection displayName = 'RowanSample1*'.
	nonDefaultService := self projectListPresenter list
				detect: [:projectService | projectService name = 'Rowan'].
	self assert: nonDefaultService displayName = 'Rowan'.
	self assert: self projectListPresenter selection displayName = 'RowanSample1*'.
	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self projectsPresenter makeDefault.
	nonDefaultService := self projectListPresenter list
				detect: [:projectService | projectService name = 'RowanSample1'].
	self assert: self projectListPresenter selection displayName = 'Rowan*'!

test_maximizeCode
	self testsIssue: #issue495 withTitle: 'minor error dialogs (3.0.73)'.
	projectsBrowser maximizeCode.
	self assert: (self projectsPresenter view viewNamed: 'textAreaTabs') arrangement equals: 100.
	projectsBrowser maximizeCode.
	self deny: (self projectsPresenter view viewNamed: 'textAreaTabs') arrangement equals: 100.
	self selectSUnitTab.
	projectsBrowser maximizeCode.
	self assert: (self projectsPresenter view viewNamed: 'textAreaTabs') arrangement equals: 100.
	projectsBrowser maximizeCode.
	self deny: (self projectsPresenter view viewNamed: 'textAreaTabs') arrangement equals: 100!

test_menuAddPackageOnProjectMenu
	| transcriptProjectMenu transcriptCommands |
	self testsIssue: #issue171 withTitle: 'Project menu quibbles'.
	self assert: ((self projectsPresenter projectMenu items collect: [:each | each command])
				includes: #addPackage).	"on projects menu in browser"
	transcriptProjectMenu := transcript projectListPresenter projectListPresenter view parentView
				contextMenu.
	transcriptCommands := transcriptProjectMenu items collect: [:each | each command].
	self deny: (transcriptCommands includes: #addPackage)!

test_menuEnablementDoesNotBreak
	"the bug in the issue was a bad enablement test in a menu item
	during the query. If nothing else, test that we can always query
	all the menus in the toolbar without error regardless if a class is 
	selected or not."

	| view |
	self testsIssue: #issue172 withTitle: 'Classes menu error if no Class selected'.
	view := projectsBrowser view.
	self selectRowanSample1Class.
	self denyIsNil: self classListPresenter selectionOrNil.
	view menuBar items do: [:menu | menu queryAllFromView: view].
	self selectServiceNamed: 'Cypress' in: self projectListPresenter.	"this will deselect the class."
	self assertIsNil: self classListPresenter selectionOrNil.
	view menuBar items do: [:menu | menu queryAllFromView: view]!

test_menusDontAddBreaks
	"incomplete test - make sure we don't add a breakpoint menu item in 
	the menu bar"

	| menuBar jadeiteMenu methodsMenu |
	self testsIssue: #issue162 withTitle: 'In method list browser, get new breakpoint menu items'.
	menuBar := projectsBrowser view menuBar.
	jadeiteMenu := self itemNamed: 'Jadeite' in: menuBar.
	methodsMenu := self itemNamed: 'Methods' in: menuBar.
	self noBreakIn: jadeiteMenu.
	self noBreakIn: methodsMenu.
	self selectRowanSample1Class.
	self saveInterestingLoopMethod.
	self selectMethodNamed: #interestingLoop.
	self methodListPresenter selection appendToSourceMenu: jadeiteMenu
		presenter: self methodSourcePresenter view.
	self noBreakIn: jadeiteMenu.
	self methodListPresenter selection appendToSourceMenu: methodsMenu
		presenter: self methodSourcePresenter view.
	self noBreakIn: methodsMenu!

test_methodsContaining
	| methodListPresenter sourcePresenter |
	self testsIssue: #issue220
		withTitle: 'Verify using Jadeite method list browser for senders of "methods containing"'.
	self selectRowanSample1Class.
	self saveMethodWithUniqueString.
	methodListBrowser := JadePresenter browseMethodsContaining: 'I be unique' session: session. 
	"the method list browser contains the BasicMethodListPresenter which is of questionable value now. 
	That's why there are two methodListPresenter message sends"
	methodListPresenter := methodListBrowser primaryPresenter methodListPresenter methodListPresenter.
	sourcePresenter := methodListBrowser primaryPresenter  methodSourcePresenter documentPresenter.
	self assert: methodListPresenter list size equals: 1.
	self assert: sourcePresenter view selection = 'I be unique'. !

test_methodsContainingCaption
	self testsIssue: #issue209 withTitle: 'MethodListBrowser needs the token in the title bar'.
	methodListBrowser := JadePresenter browseMethodsContaining: 'updateFromSton:' session: session.
	[self assert: ('Methods containing ''updateFromSton:'' for *' match: methodListBrowser caption)]
		ensure: [self destroy: methodListBrowser]!

test_methodTabSelected
	"when a method is changed the method source tab should be selected"

	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Tests' in: self packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: self classListPresenter.
	self assert: self projectsPresenter textAreaTabs currentCard name = 'classDefinition'.
	self selectMethodNamed: #test1.
	self assert: self projectsPresenter textAreaTabs currentCard name = 'methodSource'.
	self selectHierarchyTab.
	self assert: self projectsPresenter textAreaTabs currentCard name = 'classDefinition'. "presume user is thinking classes so show class def"
	self selectMethodNamed: #test2.
	self assert: self projectsPresenter textAreaTabs currentCard name = 'methodSource'.
	self selectSUnitTab. 
	self assert: self projectsPresenter textAreaTabs currentCard name = 'sunit'.
	self selectMethodNamed: #test1.
	self assert: self projectsPresenter textAreaTabs currentCard name = 'methodSource'.
	self selectClassTab. "effectively deselect method go back to class def" 
	self assert: self projectsPresenter textAreaTabs currentCard name = 'classDefinition'. 
	self selectInstanceTab. 
	self assert: self projectsPresenter textAreaTabs currentCard name = 'classDefinition'.
	self selectMethodNamed: #test1.
	self assert: self projectsPresenter textAreaTabs currentCard name = 'methodSource'.


	
	!

test_modifiedSourceShouldNotChange
	| source originalSource |
	self testsIssue: #issue400
		withTitle: '(3.0.55) Selecting class in one project browser loses method edits in another'.
	self selectRowanSample1Class.
	self selectMethodNamed: #foo.
	originalSource := 'foo ^''foo'''.
	self assert: self methodSourcePresenter value equals: originalSource.
	source := 'foo  ^''I am changed'''.
	self methodSourcePresenter value: source.
	self methodSourcePresenter view isModified: true.
	self openSecondBrowser.
	
	[| methodServices |
	self selectServiceNamed: 'RowanSample1' in: secondBrowser currentCard projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Core' in: secondBrowser currentCard packageListPresenter.
	self selectServiceNamed: self sampleClassName in: secondBrowser currentCard classListPresenter.
	self assert: self methodSourcePresenter value equals: source.	"unchanged"
	secondBrowser currentCard methodListPresenter resetSelection.
	methodServices := (Array with: #foo)
				collect: [:selector | secondBrowser currentCard methodListPresenter list detect: [:svc | svc selector = selector]].
	secondBrowser currentCard methodListPresenter selections: methodServices.
	self assert: self methodSourcePresenter value equals: source.	"unchanged"
	self assert: secondBrowser currentCard methodSourcePresenter value equals: originalSource]
			ensure: 
				[self methodSourcePresenter value: originalSource.
				self methodSourcePresenter view isModified: false.
				secondBrowser topShell exit]!

test_modifiedSourceShouldNotChangeMethodList
	| source originalSource |
	self testsIssue: #issue400
		withTitle: '(3.0.55) Selecting class in one project browser loses method edits in another'.
	self selectRowanSample1Class.
	self selectMethodNamed: #foo.
	originalSource := 'foo ^''foo'''.
	self assert: self methodSourcePresenter value equals: originalSource.
	source := 'foo  ^''I am changed'''.
	self methodSourcePresenter value: source.
	self methodSourcePresenter view isModified: true.
	
	[methodListBrowser := self projectsPresenter browseImplementorsOf: #foo.
	self assert: methodListBrowser primaryPresenter methodListPresenter methodListPresenter selection
				selector
		equals: #foo.
	self assert: self methodSourcePresenter value equals: source.	"unchanged"
	self assert: methodListBrowser primaryPresenter methodSourcePresenter documentPresenter value
		equals: originalSource]
			ensure: 
				[self methodSourcePresenter value: originalSource.
				self methodSourcePresenter view isModified: false]!

test_multipleCompileMethod
	self testsIssue: #issue170
		withTitle: 'Editing methods to create new method and updating created method gets errors'.
	self selectRowanSample1Class.
	self issue170methodCreation.
	self selectMethodNamed: #test.
	self methodSourcePresenter value: 'pest  ^55'.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	"run through the list of methods"
	self selectMethodNamed: #another.
	self selectMethodNamed: #interesting.
	self selectMethodNamed: #test.
	self selectMethodNamed: #try.
	self selectMethodNamed: #test.
	self selectMethodNamed: #interesting.
	self selectMethodNamed: #another.
	self selectMethodNamed: #pest.
	self assert: self methodSourcePresenter value equals: 'pest  ^55'.
	self methodSourcePresenter value: 'pest  ^55 + 1'.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self selectMethodNamed: #another.
	self selectMethodNamed: #interesting.
	self selectMethodNamed: #test.
	self selectMethodNamed: #try.
	self selectMethodNamed: #test.
	self selectMethodNamed: #interesting.
	self selectMethodNamed: #another.
	self selectMethodNamed: #pest.	"<< bug occurred here"
	self assert: self methodSourcePresenter value equals: 'pest  ^55 + 1'!

test_multiplePackageSelection
	"verify package selection shows packages in both packages and alphabetizes them"

	| coreClassNames testClassNames sortedClassNames |
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Core' in: self packageListPresenter.
	coreClassNames := self classListPresenter list collect: [:classService | classService name].
	self selectServiceNamed: 'Rowan-Services-Tests' in: self packageListPresenter.
	testClassNames := self classListPresenter list collect: [:classService | classService name].
	sortedClassNames := SortedCollection withAll: coreClassNames , testClassNames.
	self selectServicesNamed: (Array with: 'Rowan-Services-Core' with: 'Rowan-Services-Tests')
		in: self packageListPresenter.
	self assert: (self classListPresenter list collect: [:classService | classService name]) asArray
		equals: sortedClassNames asArray!

test_newBrowserRetainsClassAndMethod
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	secondBrowser := self projectsPresenter newBrowser.
	self assert: secondBrowser currentCard methodListPresenter selection selector equals: #test1.
	self assert: secondBrowser currentCard classListPresenter selection name equals: 'RowanSample1Test'!

test_newBrowserRetainsClassAndMethodClassSide
	self selectRowanSample1Class.
	self selectClassTab.
	self selectMethodNamed: #bar.
	secondBrowser := self projectsPresenter newBrowser.
	self assert: secondBrowser currentCard methodListPresenter selection selector equals: #bar.
	self assert: secondBrowser currentCard classListPresenter selection name equals: 'RowanSample1'!

test_noSelectionHierarchy
	| roots children childrensNames grandchildren grandchildrensNames |
	self testsIssue: #issue125 withTitle: 'Hierarchy view empty if class not selected'.
	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Services-Core') in: self packageListPresenter.
	self assertIsNil: self projectsPresenter selectedClass.
	self selectHierarchyTab.
	self assert: self classHierarchyPresenter model notEmpty.
	roots := self classHierarchyPresenter model roots.
	self assert: roots size = 1.
	self assert: roots first name = 'Object'.
	children := self classHierarchyPresenter model getChildrenOf: roots first.
	childrensNames := children collect: [:classService | classService name].
	self assert: (childrensNames includes: 'RowanCommandResult').
	self assert: (childrensNames includes: 'RowanService').
	self deny: (childrensNames includes: 'RowanClassService').
	grandchildren := self classHierarchyPresenter model getChildrenOf: (children detect: [:classService | classService name = 'RowanService']).
	self assert: grandchildren size equals: 15. "this will probably change but it's a nice test to ensure all the expected services are present"
	grandchildrensNames := grandchildren collect: [:classService | classService name].
	self assert: (grandchildrensNames at: 1) equals: 'RowanAnsweringService'.
	self assert: (grandchildrensNames at: 2) equals: 'RowanAutoCommitService'.
	self assert: (grandchildrensNames at: 3) equals: 'RowanBrowserService'.
	self assert: (grandchildrensNames at: 4) equals: 'RowanClassService'.
	self assert: (grandchildrensNames at: 5) equals: 'RowanDebuggerService'.
	self assert: (grandchildrensNames at: 6) equals: 'RowanDictionaryService'.
	self assert: (grandchildrensNames at: 7) equals: 'RowanFrameService'.
	self assert: (grandchildrensNames at: 8) equals: 'RowanLoggingService'.
	self assert: (grandchildrensNames at: 9) equals: 'RowanMethodService'.
	self assert: (grandchildrensNames at: 10) equals: 'RowanPackageService'.
	self assert: (grandchildrensNames at: 11) equals: 'RowanProcessService'.
	self assert: (grandchildrensNames at: 12) equals: 'RowanProjectService'.
	self assert: (grandchildrensNames at: 13) equals: 'RowanQueryService'.
	self assert: (grandchildrensNames at: 14) equals: 'RowanTestService'.
	self assert: (grandchildrensNames at: 15) equals: 'RowanVariableService'.

!

test_openChangesBrowser
	| changesBrowser changesItem |
	self testsIssue: #issue384
		withTitle: '(3.0.53) sort by `type` in changes view does not do complete job'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	changesItem := self projectListPresenter view queryContextMenu items
				detect: [:menuItem | menuItem command == #projectChanges].
	changesBrowser := changesItem commandDescription performAgainst: self projectsPresenter.
	[self assert: (changesBrowser isKindOf: RowanPatchBrowser)] ensure: [self destroy: changesBrowser]!

test_openNewBrowserTabWhileSUnitTabSelected
	| addBrowserButton jadeMenu cards index |
	self testsIssue: #issue389 withTitle: 'Add Browser Panel (Tab) when in Sunit Subpanel fails'.
	[self projectsPresenter parentPresenter view cards size > 1] whileTrue:[projectsBrowser closeCard]. 
	self selectRowanSample1Class.
	self selectSUnitTab.
	jadeMenu := projectsBrowser view menuBar items detect: [:menu | '*Jadeite*' match: menu text]
				ifNone: [].
	addBrowserButton := jadeMenu items
				detect: [:item | #addSystemBrowser match: item commandDescription command]
				ifNone: [].
	addBrowserButton commandDescription performAgainst: self projectsPresenter.
	cards := self projectsPresenter parentPresenter view cards.
	self assert: cards size equals: 2.
	index := cards indexOf: self projectsPresenter view.
	self assert: index equals: 2.
	self assert: self projectsPresenter view arrangement equals: '2 Projects'!

test_openNewProjectBrowser
	"make sure that we can open a new project browser from an existing browser"

	| newBrowser menu item |
	self testsIssue: #issue243
		withTitle: '`browse class` menu in method view of project browser leaves method and goes to class'.
	menu := Menu fromStrings: self projectsPresenter jadeMenuStrings.
	self
		denyIsNil: (item := menu items detect: [:menuItem | menuItem command == #newBrowser] ifNone: []).
	newBrowser := item commandDescription performAgainst: self projectsPresenter.
	[self assert: newBrowser isKindOf: JadeiteBrowser] ensure: [newBrowser exit]!

test_openNewProjectTab
	| menu item firstCard cardCount |
	self testsIssue: #issue243
		withTitle: '`browse class` menu in method view of project browser leaves method and goes to class'.
	cardCount := self projectsPresenter parentPresenter view cards size.
	self assert: self projectsPresenter parentPresenter view cards size equals: cardCount.
	menu := Menu fromStrings: self projectsPresenter jadeMenuStrings.
	self
		denyIsNil: (item := menu items detect: [:menuItem | menuItem command == #addSystemBrowser] ifNone: []).
	firstCard := projectsBrowser currentCard.
	item commandDescription performAgainst: projectsBrowser.
	self assert: self projectsPresenter parentPresenter view cards size equals: cardCount + 1.
	self deny: projectsBrowser currentCard == firstCard!

test_openProjectsBrowser
	"project browser opened in setup"

	self assert: projectsBrowser class equals: JadeiteBrowser.
	self
		denyIsNil: (self projectList detect: [:projectService | projectService name = 'Rowan'] ifNone: [])!

test_openProjectsBrowserFromMethodList
	| secondProjectsBrowser |
	self testsIssue: #issue192
		withTitle: 'Oscar-3.0.40: `browse object class` menu item in inspector (debugger) opens dictionary browser...'.
	self selectRowanSample1Class.
	self selectMethodNamed: #foo.
	methodListBrowser := self projectsPresenter browseImplementors.
	self assert: methodListBrowser primaryPresenter methodListPresenter methodListPresenter selection
				selector
		equals: #foo.
	secondProjectsBrowser := methodListBrowser primaryPresenter methodListPresenter browseClass.
	[self assert: (secondProjectsBrowser isKindOf: JadeiteBrowser)]
		ensure: [self destroy: secondProjectsBrowser]!

test_packagesShownInMultipleProjects
	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self assertIsNil: (self serviceNamed: 'RowanService' in: self classListPresenter).
	self selectServicesNamed: #('Rowan-Services-Core') in: self packageListPresenter.
	self denyIsNil: (self serviceNamed: 'RowanService' in: self classListPresenter).
	self assertIsNil: (self serviceNamed: 'JadeServer' in: self classListPresenter).
	self selectServicesNamed: #('Rowan-JadeServer') in: self packageListPresenter.
	self denyIsNil: (self serviceNamed: 'JadeServer' in: self classListPresenter)!

test_projectDisplaysSync
	"the projects browser and project list in the transcript should
	stay sync'ed automaticall"

	"project removal in projects browser"
	self denyIsNil: (self projectNamed: 'RowanSample1').
	self assert: self transcriptTab isKindOf: JadeiteProjectListPresenter.
	self denyIsNil: (self transcriptProjectNamed: 'RowanSample1').
	self unloadSampleProject.
	self assertIsNil: (self projectNamed: 'RowanSample1').
	self assertIsNil: (self transcriptProjectNamed: 'RowanSample1').
	"project addition in projects browser"
	self cloneRowanSample1. 
	self ensureRowanSample1Loaded. 
	[self denyIsNil: (self transcriptProjectNamed: 'RowanSample1').
	self denyIsNil: (self projectNamed: 'RowanSample1')]
			ensure: [self unloadSampleProject].
	self assertIsNil: (self projectNamed: 'RowanSample1').
	self assertIsNil: (self transcriptProjectNamed: 'RowanSample1').
	"project addition in project list"
	self loadRowanSample1InProjectList.
	self denyIsNil: (self transcriptProjectNamed: 'RowanSample1').
	self denyIsNil: (self projectNamed: 'RowanSample1').
	"project removal in project list"
	(self transcriptTab projectListPresenter list
		detect: [:projectService | projectService name = self sampleProjectName]
		ifNone: []) notNil
		ifTrue: [self transcriptTab basicUnloadProjects: (Array with: self sampleProjectName)].
	
	[self assertIsNil: (self projectNamed: 'RowanSample1').
	self assertIsNil: (self transcriptProjectNamed: 'RowanSample1')]
			ensure: [self loadRowanSample1InProjectList]!

test_projectInfoTab
	| view |
	self testsIssue: #issue261 withTitle: 'Project tab should display reason for project font styling'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self assert: (self projectsPresenter projectInfoTab view getItemText: 1) equals: 'rowanProjectsHome'.
	self assert: (self projectsPresenter projectInfoTab view getItemText: 3) equals: 'name'.
	self assert: (self projectsPresenter projectInfoTab view getItemText: 4) equals: 'sha'.
	self assert: (self projectsPresenter projectInfoTab view getItemText: 5) equals: 'branch'.
	self assert: (self projectsPresenter projectInfoTab view getItemText: 6) equals: 'isSkew'.
	self assert: (self projectsPresenter projectInfoTab view getItemText: 7) equals: 'isDirty'.
	view := self projectsPresenter projectInfoTab view.
	self assert: (view columns first contentFromRow: (view list at: 3)) equals: 'Rowan'. "don't know the state of the rowan project so just test the name"!

test_projectMenuGitCommitMenuItem
	| gitCommitMenuItem query |
	self testsIssue: #issue317 withTitle: 'Commit when no changes results in walkback'.
	gitCommitMenuItem := self projectListPresenter view queryContextMenu items
				detect: [:menu | '*Commit to Git*' match: menu text]
				ifNone: [].
	self denyIsNil: gitCommitMenuItem.
	self assert: gitCommitMenuItem command equals: #gitCommit.
	self assert: (self projectsPresenter class canUnderstand: #gitCommit).
	query := CommandQuery commandDescription: gitCommitMenuItem source: self projectListPresenter view.
	self projectListPresenter list do: 
			[:projectService |
			self projectListPresenter selection: projectService.
			self projectsPresenter queryCommand: query.
			projectService isDirty ifTrue: [self assert: query isEnabled] ifFalse: [self deny: query isEnabled]]!

test_projectRemoved
	"Gracefully remove a project from the project list if it was 
	removed behind the tool's back"

	| sampleProject |
	self selectServicesNamed: (Array with: 'RowanSample1') in: self projectListPresenter.
	sampleProject := self projectNamed: 'RowanSample1'.
	self denyIsNil: sampleProject.
	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	session executeString: 'Rowan projectTools delete deleteProjectNamed: ''RowanSample1'''.	"delete project behind tool's back"
	
	[self selectServicesNamed: (Array with: 'RowanSample1') in: self projectListPresenter.	"expect project to disappear but not walkback"
	sampleProject := self projectNamed: 'RowanSample1'.
	self assertIsNil: sampleProject]
			ensure: 
				[self cloneRowanSample1.
				self ensureRowanSample1Loaded]!

test_reformatSource
	self testsIssue: #issue345 withTitle: 'Jadeite format option (server ready) #345'.
	self selectRowanSample1Test.
	self
		saveMethod: 'reformatSourceTemporaryMethod ^#test'
		in: 'RowanSample1Test'
		category: 'other'.
	[self selectMethodNamed: #reformatSourceTemporaryMethod.
	self assert: self methodSourcePresenter value equals: 'reformatSourceTemporaryMethod ^#test'.
	self projectsPresenter reformatSource.
	self assert: self methodSourcePresenter view isModified.
	self assert: self methodSourcePresenter value
		equals: 'reformatSourceTemporaryMethod
  ^ #''test''' replaceCrLfWithLf] ensure:[
		self projectsPresenter removeMethods: self classListPresenter selections]!

test_reformatSourceAppliesOnlyToCurrentBrowser
	| methodServices |
	self testsIssue: #issue345 withTitle: 'Jadeite format option (server ready) #345'.
	self selectRowanSample1Class.
	self methodSourcePresenter value: nil. 
	self methodSourcePresenter isModified: false. 
	self
		saveMethod: 'reformatSourceTemporaryMethod ^#test'
		in: 'RowanSample1'
		category: 'other'.
	self selectMethodNamed: #reformatSourceTemporaryMethod.
	self assert: self methodSourcePresenter value equals: 'reformatSourceTemporaryMethod ^#test'.
	self openSecondBrowser.
	self selectServiceNamed: 'RowanSample1' in: secondPresenter projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Core' in: secondPresenter packageListPresenter.
	self selectServiceNamed: self sampleClassName in: secondPresenter classListPresenter.
	methodServices := (Array with: #reformatSourceTemporaryMethod)
				collect: [:selector | secondPresenter methodListPresenter list detect: [:svc | svc selector = selector]].
	secondPresenter methodListPresenter selections: methodServices.
	self assert: secondPresenter methodSourcePresenter value
		equals: 'reformatSourceTemporaryMethod ^#test'.
	self projectsPresenter reformatSource.
	self assert: self methodSourcePresenter view isModified.
	self assert: self methodSourcePresenter value
		equals: 'reformatSourceTemporaryMethod
  ^ #''test''' replaceCrLfWithLf.
	self assert: secondPresenter methodSourcePresenter value
		equals: 'reformatSourceTemporaryMethod ^#test'.
	self methodSourcePresenter isModified: false. !

test_refreshAfterAbortMethodList
	"method lists should remove deleted methods after an abort."

	| projectListPresenter abortItem |
	self testsIssue: #issue284
		withTitle: '(3.0.49 and 3.0.50) project browser not updated properly on reload of project.'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Core' in: self packageListPresenter.
	self selectServiceNamed: 'RowanBrowserService' in: self classListPresenter.
	self methodSourcePresenter value: 'five  ^5'.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self selectServiceNamed: 'RowanAnsweringService' in: self classListPresenter.
	self methodSourcePresenter value: 'five  ^''five'''.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self selectMethodNamed: #five.
	methodListBrowser := self projectsPresenter browseImplementors.
	self denyIsNil: (methodListBrowser primaryPresenter methodListPresenter methodListPresenter list
				detect: [:methodService | methodService selector = #five]
				ifNone: []).
	self assert: methodListBrowser primaryPresenter methodListPresenter methodListPresenter list size
		equals: 2.
	projectListPresenter := transcript projectListPresenter projectListPresenter.
	abortItem := transcript view menuBar items third items
				detect: [:menuItem | menuItem command == #abortTransaction]. "jadeite menu" 
	abortItem commandDescription performAgainst: transcript projectListPresenter.
	[self assert: methodListBrowser primaryPresenter methodListPresenter methodListPresenter list isEmpty]
		ensure: 
			[self cloneRowanSample1.
			self ensureRowanSample1Loaded]!

test_refreshAfterAbortMethodListLeaveCommitted
	"method lists should remove deleted methods after an abort
	but committed objects should stay."

	| abortItem beforeSize afterSize list |
	self testsIssue: #issue284
		withTitle: '(3.0.49 and 3.0.50) project browser not updated properly on reload of project.'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Core' in: self packageListPresenter.
	self selectServiceNamed: 'RowanMethodService' in: self classListPresenter.
	self selectMethodNamed: #classFromName.
	methodListBrowser := self projectsPresenter browseImplementors.
	
	[list := methodListBrowser primaryPresenter methodListPresenter methodListPresenter list.
	beforeSize := list size.
	self assert: beforeSize = 1.
	self
		assertIsNil: (list detect: [:methodService | methodService className = 'RowanService'] ifNone: [])]
			ensure: [self destroy: methodListBrowser].
	self selectServiceNamed: 'RowanService' in: self classListPresenter.
	self methodSourcePresenter value: 'classFromName  "do nothing"'.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self selectMethodNamed: #classFromName.
	methodListBrowser := self projectsPresenter browseImplementors.
	list := methodListBrowser primaryPresenter methodListPresenter methodListPresenter list.
	afterSize := list size.
	self assert: afterSize equals: beforeSize + 1.
	self
		denyIsNil: (list detect: [:methodService | methodService className = 'RowanService'] ifNone: []).
	abortItem := transcript view menuBar items third items
				detect: [:menuItem | menuItem command == #abortTransaction].	"jadeite menu"
	abortItem commandDescription performAgainst: transcript projectListPresenter.
	
	[self assert: methodListBrowser primaryPresenter methodListPresenter methodListPresenter list size
		equals: beforeSize]
			ensure: 
				[self cloneRowanSample1.
				self ensureRowanSample1Loaded]!

test_refreshAfterReloadInProjectsBrowserWithAddedMethod
	"add a method in a project, then reload from the project browser.
	Expect the browsers to remove the method on update but keep
	the class and package selections. "

	| loadProjectsMenuItem |
	self testsIssue: #issue284
		withTitle: '(3.0.49 and 3.0.50) project browser not updated properly on reload of project.'.
	self selectRowanSample1Class.
	self issue284methodCreation.
	self selectMethodNamed: #addedMethod.
	loadProjectsMenuItem := self projectListPresenter view queryContextMenu items
				detect: [:menuItem | menuItem command == #loadProjects].
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #yes.	"confirm we want to load project"
	
	[loadProjectsMenuItem commandDescription performAgainst: self projectsPresenter.
	self assertIsNil: (self methodListPresenter list
				detect: [:methodService | methodService selector == #addedMethod]
				ifNone: []).
	self assert: self classListPresenter selection name equals: 'RowanSample1'.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Core'.
	self assert: self projectListPresenter selection name equals: 'RowanSample1']
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

test_refreshAfterReloadWithAddedMethod
	"add a method in a project, then refresh from the project list.
	Expect the browsers to remove the method on update"

	| projectListPresenter sampleProjectInList refreshItem |
	self testsIssue: #issue284
		withTitle: '(3.0.49 and 3.0.50) project browser not updated properly on reload of project.'.
	self selectRowanSample1Class.
	self issue284methodCreation.
	self selectMethodNamed: #addedMethod.
	methodListBrowser := self projectsPresenter browseImplementors.
	self denyIsNil: (methodListBrowser primaryPresenter methodListPresenter methodListPresenter list
				detect: [:methodService | methodService selector = #addedMethod]
				ifNone: []).
	projectListPresenter := transcript projectListPresenter projectListPresenter.
	sampleProjectInList := projectListPresenter list
				detect: [:projectService | projectService name = 'RowanSample1']
				ifNone: [].
	self denyIsNil: sampleProjectInList.
	projectListPresenter selection: sampleProjectInList.
	refreshItem := projectListPresenter view queryContextMenu items
				detect: [:menuItem | menuItem command == #loadProjects].
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #yes.	"confirm we want to load project"
	
	[refreshItem commandDescription performAgainst: transcript projectListPresenter.
	self assertIsNil: (self methodListPresenter list
				detect: [:methodService | methodService selector == #addedMethod]
				ifNone: []).
	self assertIsNil: (methodListBrowser primaryPresenter methodListPresenter methodListPresenter list
				detect: [:methodService | methodService selector = #addedMethod]
				ifNone: [])]
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

test_refreshFromServer
	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Services-Core') in: self packageListPresenter.
	self selectServicesNamed: (Array with: 'RowanPackageService') in: self classListPresenter.
	self selectCategoryNamed: 'client commands'.
	self selectServiceNamed: 'classHierarchy' in: self methodListPresenter.
	self projectsPresenter refreshFromServer.
	self assert: self projectsPresenter selectedMethodName equals: #classHierarchy.
	self assert: self projectsPresenter categoryListPresenter selection equals: 'client commands'.
	self assert: self projectsPresenter selectedClass name equals: 'RowanPackageService'.
	self assert: self projectsPresenter packageListPresenter selection name equals: 'Rowan-Services-Core'.
	self assert: self projectsPresenter projectListPresenter selection name equals: 'Rowan'.
	"hierarchy tab" 
	self selectHierarchyTab. "selections remain" 
	self projectsPresenter refreshFromServer.
	self assert: self projectsPresenter selectedMethodName equals: #classHierarchy.
	self assert: self projectsPresenter categoryListPresenter selection equals: 'client commands'.
	self assert: self projectsPresenter selectedClass name equals: 'RowanPackageService'.
	self assert: self projectsPresenter packageListPresenter selection name equals: 'Rowan-Services-Core'.
	self assert: self projectsPresenter projectListPresenter selection name equals: 'Rowan'
	!

test_registeredPresentersInMethodBrowserCleanedUp
	| registeredPresenters |
	registeredPresenters := BrowserUpdate current registeredPresenters.
	methodListBrowser := self projectsPresenter browseImplementorsOf: #size.
	self assert: BrowserUpdate current registeredPresenters size > registeredPresenters size.
	methodListBrowser view close.
	methodListBrowser := nil.
	"difference := BrowserUpdate current registeredPresenters difference: registeredPresenters. uncomment to figure out which presenters are left around"
	self assert: BrowserUpdate current registeredPresenters size equals: registeredPresenters size!

test_registeredPresentersInProjectBrowserCleanedUp
	| registeredPresenters |
	registeredPresenters := BrowserUpdate current registeredPresenters.
	secondBrowser := JadeiteBrowser showOnSession: session.
	self assert: BrowserUpdate current registeredPresenters size > registeredPresenters size.
	self destroy: secondBrowser.
	secondBrowser := nil.
	"difference := BrowserUpdate current registeredPresenters difference: registeredPresenters. uncomment to figure out which presenters are left around"
	self assert: BrowserUpdate current registeredPresenters size equals: registeredPresenters size!

test_removeAbortedClass
	"make sure we can safely remove an aborted class during post-abort refresh"

	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Services-Tests') in: self packageListPresenter.
	self selectServicesNamed: (Array with: 'RowanServicesTest') in: self classListPresenter.
	self saveTestClass.
	[self assert: self projectsPresenter selectedClass name = 'TestClass']
		ensure: [self projectsPresenter topShell abortTransaction].
	
	[self
		assertIsNil: (self classListPresenter list detect: [:service | service name = 'TestClass'] ifNone: [])]
			ensure: 
				[self cloneRowanSample1.
				self ensureRowanSample1Loaded].
	self saveTestClass.
	self assert: self projectsPresenter selectedClass name = 'TestClass'.	"abort from a different browser"
	transcript projectListPresenter abortTransaction.
	
	[self
		assertIsNil: (self classListPresenter list detect: [:service | service name = 'TestClass'] ifNone: [])]
			ensure: 
				[self cloneRowanSample1.
				self ensureRowanSample1Loaded]!

test_removeClassFromHierarchy
	self testsIssue: #issue377 withTitle: '(3.0.53) remove class in hierarchy class view does not work'.
	self selectRowanSample1Test.
	self selectHierarchyTab.
	self assertLinearAncestry: #('Object' 'TestAsserter' 'TestCase' 'RowanSample1Test')
		in: self classHierarchyPresenter.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[TestMessageBox plannedResult: #yes.
	self projectsPresenter removeClass.
	self assertLinearAncestry: #('Object' 'TestAsserter' 'TestCase') in: self classHierarchyPresenter]
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

test_removeClassFromList
	self testsIssue: #issue377 withTitle: '(3.0.53) remove class in hierarchy class view does not work'.
	self selectRowanSample1Test.
	self denyIsNil: (self classListPresenter list
				detect: [:classService | classService name = 'RowanSample1Test']
				ifNone: []).
	TestMessageBox enableJadeiteTestMessageBox.
	
	[TestMessageBox plannedResult: #yes.
	self projectsPresenter removeClass.
	self assertIsNil: (self classListPresenter list
				detect: [:classService | classService name = 'RowanSample1Test']
				ifNone: [])]
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

test_removeInstVarVariablesStaySorted
	self selectRowanSample1Test.
	self projectsPresenter selectVariableTab.
	self assert: self projectsPresenter methodFilterListPresenter list
		equals: (OrderedCollection with: 'testSelector').
	self
		saveClass: 'RowanSample1Test'
		superclass: 'TestCase'
		instVars: #('foo' 'bar')
		package: 'RowanSample1-Tests'.
	self assert: self projectsPresenter methodFilterListPresenter list asArray
		equals: (Array
				with: 'bar'
				with: 'foo'
				with: 'testSelector').
	self
		saveClass: 'RowanSample1Test'
		superclass: 'TestCase'
		instVars: #('foo')
		package: 'RowanSample1-Tests'.
	self assert: self projectsPresenter methodFilterListPresenter list asArray
		equals: (Array with: 'foo' with: 'testSelector')!

test_removeProject
	| targetProject |
	self testsIssue: #issue129 withTitle: 'Expose unload project.'.
	targetProject := self projectListPresenter list
				detect: [:projectService | projectService name = self sampleProjectName]
				ifNone: [].
	self denyIsNil: targetProject.
	self projectListPresenter selection: targetProject.
	"just select an element in each list to test cleanup after removal"
	self packageListPresenter selection: self packageListPresenter list first.
	self classListPresenter selection: self classListPresenter list first.
	self categoryListPresenter selection: self categoryListPresenter list first.
	self methodListPresenter selection: self methodListPresenter list first.
	self projectsPresenter basicUnloadProjects: (Array with: self projectListPresenter selection name).
	targetProject := self projectListPresenter list
				detect: [:projectService | projectService name = self sampleProjectName]
				ifNone: [].
	self assertIsNil: targetProject.
	"make sure browser cleans itself up"
	
	[self assert: self projectListPresenter selections isEmpty.
	self assert: self packageListPresenter list isEmpty.
	self assert: self classListPresenter list isEmpty.
	self assert: self categoryListPresenter list isEmpty.
	self assert: self methodListPresenter list isEmpty]
			ensure: 
				[self cloneRowanSample1.
				self ensureRowanSample1Loaded]!

test_renameCategory
	self testsIssue: #issue380
		withTitle: '(3.0.53) rename protocol is broken: `UndefinedObject does not understand #''select:''`'.
	self selectRowanSample1Class.
	self categoryListPresenter selection: 'accessing'.
	self assert: self categoryListPresenter list size equals: 1.
	self assert: self categoryListPresenter selection equals: 'accessing'.
	self projectsPresenter basicRenameCategoryFrom: 'accessing' to: 'accessingNew'.
	self assert: self categoryListPresenter list size equals: 1.
	self assert: self categoryListPresenter selection equals: 'accessingNew'!

test_renameClassMethodListUpdates
	self testsIssue: #issue439 withTitle: '`rename` class menu item would be useful'.
	self testsIssue: #issue465 withTitle: '(3.067) error after rename class in hierarchy view'.
	self selectRowanSample1Test.
	methodListBrowser := JadePresenter browseImplementorsOf: 'test1' session: session.
	self assert: methodListBrowser primaryPresenter methodListPresenter methodListPresenter list size
		equals: 1.
	self assert: methodListBrowser primaryPresenter methodListPresenter methodListPresenter list first
				className
		equals: 'RowanSample1Test'.
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #ok.
	self projectsPresenter basicRenameClass: self classListPresenter selection to: 'TestClassWasRenamed'.
	
	[self assert: methodListBrowser primaryPresenter methodListPresenter methodListPresenter list size
		equals: 1.
	self assert: methodListBrowser primaryPresenter methodListPresenter methodListPresenter list first
				className
		equals: 'TestClassWasRenamed']
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

test_renameClassShowsAsDefiniedInPackage
	self testsIssue: #issue439 withTitle: '`rename` class menu item would be useful'.
	self testsIssue: #issue465 withTitle: '(3.067) error after rename class in hierarchy view'.
	self selectRowanSample1Class.
	self deny: self classListPresenter selection isExtension.
	self assert: self classListPresenter selection name equals: 'RowanSample1'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[TestMessageBox plannedResult: #ok.
	self projectsPresenter basicRenameClass: self classListPresenter selection to: 'TestClassWasRenamed']
			ensure: [TestMessageBox disableJadeiteTestMessageBox].
	JadeiteRenameClassMethodListBrowser allInstances do: [:browser | browser view close].	"referenced methods browser is opened"
	self deny: self classListPresenter selection isExtension.
	self assert: self classListPresenter selection name equals: 'TestClassWasRenamed'.
	self selectServiceNamed: 'RowanSample1-Extensions' in: self packageListPresenter.
	self selectServiceNamed: 'TestClassWasRenamed' in: self classListPresenter.
	self assert: self classListPresenter selection isExtension.
	self selectHierarchyTab. 
	self assert: self classHierarchyPresenter selection isExtension.
	self assert: self classHierarchyPresenter selection name equals: 'TestClassWasRenamed'.
	self selectClassListTab.
	
	[TestMessageBox plannedResult: #ok.
	self projectsPresenter basicRenameClass: self classListPresenter selection
		to: 'TestClassWasRenamedAgain']
			ensure: [TestMessageBox disableJadeiteTestMessageBox].
	JadeiteRenameClassMethodListBrowser allInstances do: [:browser | browser view close].	"referenced methods browser is opened"
	self assert: self classListPresenter selection isExtension.
	self assert: self classListPresenter selection name equals: 'TestClassWasRenamedAgain'.
	self selectHierarchyTab. 
	self assert: self classHierarchyPresenter selection isExtension.
	self assert: self classHierarchyPresenter selection name equals: 'TestClassWasRenamedAgain'.
	self selectClassListTab.
	!

test_renameClassSUnitBrowserUpdates
	| sunitBrowser |
	self testsIssue: #issue439 withTitle: '`rename` class menu item would be useful'.
	self testsIssue: #issue465 withTitle: '(3.067) error after rename class in hierarchy view'.
	self selectRowanSample1Test.
	sunitBrowser := JadeiteSUnitBrowser showOnSession: session.
	
	[self selectServiceNamed: 'RowanSample1-Tests' in: sunitBrowser primaryPresenter packageListPresenter.
	self assert: sunitBrowser primaryPresenter classListPresenter list size equals: 1.
	self assert: sunitBrowser primaryPresenter classListPresenter list first name
		equals: 'RowanSample1Test'.
	TestMessageBox enableJadeiteTestMessageBox.
	[TestMessageBox plannedResult: #ok.
	self projectsPresenter basicRenameClass: self classListPresenter selection to: 'TestClassWasRenamed']
			ensure: [TestMessageBox disableJadeiteTestMessageBox].
	self assert: sunitBrowser primaryPresenter classListPresenter list size equals: 1.
	self assert: sunitBrowser primaryPresenter classListPresenter list first name
		equals: 'TestClassWasRenamed']
			ensure: [sunitBrowser view close]!

test_renameClassSwitchToHierarchyOk
	self testsIssue: #issue439 withTitle: '`rename` class menu item would be useful'.
	self testsIssue: #issue465 withTitle: '(3.067) error after rename class in hierarchy view'.
	self selectRowanSample1Class.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[TestMessageBox plannedResult: #ok.
	self projectsPresenter basicRenameClass: self classListPresenter selection to: 'TestClassWasRenamed']
			ensure: [TestMessageBox disableJadeiteTestMessageBox].
	JadeiteRenameClassMethodListBrowser allInstances do: [:browser | browser view close].	"referenced methods browser is opened"
	self assert: self classListPresenter selection name equals: 'TestClassWasRenamed'.
	self selectHierarchyTab.
	self assert: self classHierarchyPresenter selection name equals: 'TestClassWasRenamed'.
	
	[TestMessageBox plannedResult: #ok.
	self projectsPresenter basicRenameClass: self classListPresenter selection
		to: 'TestClassWasRenamedAgain']
			ensure: [TestMessageBox disableJadeiteTestMessageBox].
	JadeiteRenameClassMethodListBrowser allInstances do: [:browser | browser view close].	"referenced methods browser is opened"
	self assert: self classHierarchyPresenter selection name equals: 'TestClassWasRenamedAgain'.
	self selectClassListTab.
	self assert: self classHierarchyPresenter selection name equals: 'TestClassWasRenamedAgain'!

test_renameClassUpdatedInSecondBrowser
	self testsIssue: #issue439 withTitle: '`rename` class menu item would be useful'.
	self testsIssue: #issue465 withTitle: '(3.067) error after rename class in hierarchy view'.
	self selectRowanSample1Class.
	self openSecondBrowser.
	self selectServiceNamed: 'RowanSample1' in: secondPresenter projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Core' in: secondPresenter packageListPresenter.
	self selectServiceNamed: self sampleClassName in: secondPresenter classListPresenter.
	self assert: self classListPresenter selection name equals: 'RowanSample1'.
	self assert: secondPresenter classListPresenter selection name equals: 'RowanSample1'. 
	TestMessageBox enableJadeiteTestMessageBox.
	
	[TestMessageBox plannedResult: #ok.
	self projectsPresenter basicRenameClass: self classListPresenter selection to: 'TestClassWasRenamed']
			ensure: [TestMessageBox disableJadeiteTestMessageBox].
	JadeiteRenameClassMethodListBrowser allInstances do: [:browser | browser view close].	"referenced methods browser is opened"
	self assert: self classListPresenter selection name equals: 'TestClassWasRenamed'.
	self assert: secondPresenter classListPresenter selection name equals: 'TestClassWasRenamed'. 

	!

test_renameClassUpdatedInSecondBrowserHierarchy
	self testsIssue: #issue439 withTitle: '`rename` class menu item would be useful'.
	self testsIssue: #issue465 withTitle: '(3.067) error after rename class in hierarchy view'.
	self selectRowanSample1Class.
	self openSecondBrowser.
	self selectServiceNamed: 'RowanSample1' in: secondPresenter projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Core' in: secondPresenter packageListPresenter.
	self selectServiceNamed: self sampleClassName in: secondPresenter classListPresenter.
	self selectHierarchyTabIn: secondPresenter.
	self assert: self classListPresenter selection name equals: 'RowanSample1'.
	self assert: secondPresenter classListPresenter selection name equals: 'RowanSample1'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[TestMessageBox plannedResult: #ok.
	self projectsPresenter basicRenameClass: self classListPresenter selection to: 'TestClassWasRenamed']
			ensure: [TestMessageBox disableJadeiteTestMessageBox].
	JadeiteRenameClassMethodListBrowser allInstances do: [:browser | browser view close].	"referenced methods browser is opened"
	self assert: self classListPresenter selection name equals: 'TestClassWasRenamed'.
	self assert: secondPresenter classListPresenter selection name equals: 'TestClassWasRenamed'!

test_renameDisabledWithMultipleCategoriesSelected
	| commandQuery |
	self testsIssue: #issue380
		withTitle: '(3.0.53) rename protocol is broken: `UndefinedObject does not understand #''select:''`'.
	self selectRowanSample1Class.
	self categoryListPresenter selection: 'accessing'.
	self assert: self categoryListPresenter selections size equals: 1.
	commandQuery := self
				queryCommand: #renameMethodCategory
				inPresenter: self projectsPresenter
				view: self categoryListPresenter view.
	self assert: commandQuery isEnabled.
	self projectsPresenter basicAddMethodCategory: 'added'.
	self categoryListPresenter selections: #('added' 'accessing').
	self assert: self categoryListPresenter selections size equals: 2.
	commandQuery := self
				queryCommand: #renameMethodCategory
				inPresenter: self projectsPresenter
				view: self categoryListPresenter view.
	self deny: commandQuery isEnabled!

test_renameInClassListWithMethodListOpen
	self testsIssue: #issue465 withTitle: '(3.067) error after rename class in hierarchy view'.
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	methodListBrowser := self projectsPresenter browseSelectedMethods.
	TestMessageBox enableJadeiteTestMessageBox.
	self projectsPresenter basicRenameClass: self projectsPresenter selectedClass to: 'Fnoodly'.
	
	[TestMessageBox plannedResult: #ok.
	self assert: self projectsPresenter selectedClass name = 'Fnoodly']
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

test_renameInHierarchyWithMethodListOpen
	self testsIssue: #issue465 withTitle: '(3.067) error after rename class in hierarchy view'.
	self selectRowanSample1Test.
	self selectHierarchyTab.
	self selectMethodNamed: #test1.
	methodListBrowser := self projectsPresenter browseSelectedMethods.
	TestMessageBox enableJadeiteTestMessageBox.
	self projectsPresenter basicRenameClass: self projectsPresenter selectedClass to: 'Fnoodly'.
	
	[TestMessageBox plannedResult: #ok.
	self assert: self projectsPresenter selectedClass name = 'Fnoodly'.
	self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass]
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

test_rowanTestsHierarchy
	
	self testsIssue: #issue239 withTitle: 'long update times possible when selecting a package with `hierarchy` tab selected'.
	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self selectHierarchyTab.
 	self selectServicesNamed: #('Rowan-Tests') in: self packageListPresenter. "<-- infinite recursion occured here"
	self assert: self projectsPresenter classListPresenter selections isEmpty.  
	self selectTreeServicesNamed: (Array with: 'TestCase') in: self classHierarchyPresenter.
	self assert: self projectsPresenter classHierarchyPresenter selection name = 'TestCase'. 
	self selectClassListTab.
	self assert: self projectsPresenter classListPresenter selections isEmpty.  "TestCase not in project"
	self selectHierarchyTab.
	self assert: self projectsPresenter classListPresenter selections isEmpty.  
	self selectTreeServicesNamed: (Array with: 'RwEditToolTest') in: self classHierarchyPresenter.
	self assert: self projectsPresenter classHierarchyPresenter selection name = 'RwEditToolTest'. 
	self selectClassListTab.
	self selectServicesNamed: (Array with: 'RwEditToolTest') in: self classListPresenter.
!

test_saveClassCommentInClassList
	self selectRowanSample1Class.
	self projectsPresenter selectCommentTab.
	self projectsPresenter classCommentPresenter value equals: String new.
	self projectsPresenter classCommentPresenter value: 'testing'.
	self projectsPresenter editSaveClassComment.
	self selectHierarchyTab.
	self projectsPresenter selectCommentTab.
	self projectsPresenter classCommentPresenter value equals: 'testing'!

test_saveClassCommentInHierarchy
	self selectRowanSample1Class.
	self selectHierarchyTab.
	self projectsPresenter selectCommentTab.
	self projectsPresenter classCommentPresenter value equals: String new.
	self projectsPresenter classCommentPresenter value: 'this is a test'.
	self projectsPresenter editSaveClassComment.
	self selectClassTab.
	self projectsPresenter selectCommentTab.
	self projectsPresenter classCommentPresenter value equals: 'this is a test'!

test_saveClassMethod
	| source |
	self selectRowanSample1Class.
	self selectClassTab.
	self projectsPresenter basicAddMethodCategory: 'class side category'.
	self assert: self categoryListPresenter selection = 'class side category'.
	source := 'classSideMethod  ^#classSide'.
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self selectServicesNamed: (Array with: 'classSideMethod') in: self methodListPresenter.
	self assert: self methodListPresenter selection selector = #classSideMethod.
	self assert: (session executeString: 'RowanSample1 classSideMethod') = #classSide!

test_saveClassMethodHierarchy
	| source |
	self testsIssue: #issue121
		withTitle: 'Package Browser (3.0.20): hierarchy class view and classes defined in different pacakge oddity'.
	self selectRowanSample1Class.
	self assert: self classListPresenter selection name = 'RowanSample1'.
	self selectHierarchyTab.
	self selectClassTab.
	self projectsPresenter basicAddMethodCategory: 'class side category'.
	self assert: self categoryListPresenter selection = 'class side category'.
	source := 'classSideMethod  ^''on the class side'''.
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self projectsPresenter classHierarchyPresenter selection.
	self selectServicesNamed: (Array with: 'classSideMethod') in: self methodListPresenter.
	self assert: self methodListPresenter selection selector = #classSideMethod.
	self assert: (session executeString: 'RowanSample1 classSideMethod') = 'on the class side'!

test_saveMethod
	self selectRowanSample1Class.
	self projectsPresenter basicAddMethodCategory: 'test_saveMethod'.
	self saveSampleMethod.
	self selectServicesNamed: (Array with: 'sampleMethod') in: self methodListPresenter.
	self assert: (session executeString: 'RowanSample1 new sampleMethod') = 123!

test_saveMethodAndUpdateSUnitTab
	| source methodService |
	self selectServicesNamed: #('Rowan') in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Services-Tests') in: self packageListPresenter.
	self selectServicesNamed: #('RowanServicesTest') in: self classListPresenter.
	self projectsPresenter basicAddMethodCategory: 'test_saveMethod'.
	source := 'test_testMethod  
		self assert: true'.
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod.
	
	[self projectsPresenter selectSUnitTab.
	methodService := self projectsPresenter sunitPresenter methodListPresenter list
				detect: [:service | service selector = #test_testMethod]
				ifNone: [].
	self assert: methodService selector equals: #test_testMethod]
			ensure: [self projectsPresenter basicRemoveMethods]!

test_saveMethodHierarchy
	| source |
	self testsIssue: #issue121 withTitle: 'Package Browser (3.0.20): hierarchy class view and classes defined in different pacakge oddity'.
	self selectRowanSample1Class.
	self selectHierarchyTab.
	self selectCategoriesNamed: #('accessing').
	self saveSampleMethod.
	self selectServicesNamed: (Array with: 'sampleMethod') in: self methodListPresenter.
	self assert: self methodListPresenter selection selector = #sampleMethod.
	self assert: (session executeString: 'RowanSample1 new sampleMethod') = 123!

test_selectionsRetainedFromClassListToHierarchy
	self testsIssue: #issue448 withTitle: 'Class selection not retained from Hierarchy->Class view'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Core' in: self packageListPresenter.
	self selectServiceNamed: 'RowanAnsweringService' in: self classListPresenter.
	self selectCategoryNamed: 'other'.
	self selectMethodNamed: #answer.
	self selectHierarchyTab.
	self assert: self projectsPresenter selectedClass name equals: 'RowanAnsweringService'.
	self assert: self categoryListPresenter selection equals: 'other'.
	self assert: self methodListPresenter selection selector equals: #answer.
	self projectsPresenter selectClassListTab.
	self assert: self projectsPresenter selectedClass name equals: 'RowanAnsweringService'.
	self assert: self categoryListPresenter selection equals: 'other'.
	self assert: self methodListPresenter selection selector equals: #answer.
	self selectHierarchyTab.
	self assert: self projectsPresenter selectedClass name equals: 'RowanAnsweringService'.
	self assert: self categoryListPresenter selection equals: 'other'.
	self assert: self methodListPresenter selection selector equals: #answer.
	!

test_selectionsRetainedFromHierarchyToClassList
	self testsIssue: #issue448 withTitle: 'Class selection not retained from Hierarchy->Class view'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Core' in: self packageListPresenter.
	self selectServiceNamed: 'RowanService' in: self classListPresenter.
	self selectHierarchyTab.
	self selectClassInHierarchyNamed: 'RowanAnsweringService'.
	self selectCategoryNamed: 'other'.
	self selectMethodNamed: #answer.
	self projectsPresenter selectClassListTab.
	self assert: self projectsPresenter selectedClass name equals: 'RowanAnsweringService'.
	self assert: self categoryListPresenter selection equals: 'other'.
	self assert: self methodListPresenter selection selector equals: #answer.
	self selectHierarchyTab.
	self selectCategoryNamed: 'other'.
	self selectMethodNamed: #answer.
	self projectsPresenter selectClassListTab.
	self projectsPresenter selectClassListTab.
	self assert: self projectsPresenter selectedClass name equals: 'RowanAnsweringService'.
	self assert: self categoryListPresenter selection equals: 'other'.
	self assert: self methodListPresenter selection selector equals: #answer.!

test_selectMultiplePackages
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self selectServicesNamed: #() in: self projectListPresenter.
	self assert: self packageListPresenter list isEmpty.
	self selectServicesNamed: #('Rowan') in: self projectListPresenter.
	self deny: self packageListPresenter list isEmpty.
	self serviceNamed: 'Rowan-Services-Core' in: self packageListPresenter.
	self serviceNamed: 'Rowan-JadeServer' in: self packageListPresenter.
	self selectServicesNamed: #('Rowan-Services-Core' 'Rowan-JadeServer') in: self packageListPresenter!

test_selectVariable
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Core' in: self packageListPresenter.
	self selectServiceNamed: 'RowanClassService' in: self classListPresenter.
	self projectsPresenter selectVariableTab.
	self projectsPresenter variableListPresenter selection: 'instVarNames'.
	self methodListPresenter list
		do: [:methodService | self assert: (methodService source subStrings includes: 'instVarNames')].
	self projectsPresenter variableListPresenter selection: 'isNewClass'.
	self methodListPresenter list
		do: [:methodService | self assert: (methodService source subStrings includes: 'isNewClass')]!

test_separationOfClassAndInstance
	self testsIssue: #issue418
		withTitle: 'Navigating and category creation in class hiearchy view can''t keep class side/instance side straight'.
	self selectRowanSample1Test.
	self selectHierarchyTab.	"on instance/hierarchy"
	self assertLinearAncestry: #('Object' 'TestAsserter' 'TestCase' 'RowanSample1Test')
		in: self classHierarchyPresenter.
	self openSecondBrowser.
	self selectServiceNamed: 'RowanSample1' in: secondPresenter projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Tests' in: secondPresenter packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: secondPresenter classListPresenter.
	self selectHierarchyTabIn: secondPresenter.
	self assertLinearAncestry: #('Object' 'TestAsserter' 'TestCase' 'RowanSample1Test')
		in: secondPresenter classHierarchyPresenter.
	self selectClassTabIn: secondPresenter.
	self assertLinearAncestry: #('Object' 'TestAsserter' 'TestCase' 'RowanSample1Test')
		in: secondPresenter classHierarchyPresenter.
	self assertLinearAncestry: #('Object' 'TestAsserter' 'TestCase' 'RowanSample1Test')
		in: self classHierarchyPresenter.
	secondPresenter basicAddMethodCategory: 'tests'.
	self assert: secondPresenter methodListPresenter list isEmpty.
	self assert: self methodListPresenter list notEmpty. 
	self projectsPresenter selectCategoryNamed: 'tests'.	"select category in instance"
	self assert: self methodListPresenter list notEmpty.
	self assert: self methodListPresenter list first selector equals: #test1.
	self selectInstanceTabIn: secondPresenter.
	self assert: self methodListPresenter list notEmpty.
	self assert: self methodListPresenter list first selector equals: #test1.
	self assert: secondPresenter methodListPresenter list notEmpty.
	self assert: secondPresenter methodListPresenter list first selector equals: #test1.
	self selectClassTab.
	self assert: self methodListPresenter list isEmpty.
	self assert: secondPresenter methodListPresenter list notEmpty.
	self assert: secondPresenter methodListPresenter list first selector equals: #test1!

test_setAndClearBreakpoint
	" at least set breakpoints in the projects browser and method list browser for now"

	| methodListPresenter |
	self selectRowanSample1Class.
	self saveHooMethod.
	self assert: self methodListPresenter selection breakPoints size equals: 0.
	self projectsPresenter setBreakPointAt: 2 in: self projectsPresenter.
	self assert: self methodListPresenter selection breakPoints size equals: 1.
	self assert: self methodListPresenter selection breakPoints first equals: 2.
	self projectsPresenter clearBreakPointAt: 2 in: self projectsPresenter.
	self assert: self methodListPresenter selection breakPoints size equals: 0.
	"set breaks in method list browser"
	methodListBrowser := self projectsPresenter browseImplementorsOf: #hoo.
	self assert: (methodListBrowser isKindOf: JadeiteMethodListBrowser).
	methodListPresenter := methodListBrowser primaryPresenter.
	self assert: methodListPresenter methodListPresenter selection breakPoints size equals: 0.
	methodListPresenter setBreakPointAt: 2 in: methodListPresenter.
	self assert: methodListPresenter methodListPresenter selection breakPoints size equals: 1.
	self assert: methodListPresenter methodListPresenter selection breakPoints first equals: 2.
	methodListPresenter clearBreakPointAt: 2 in: methodListPresenter.
	self assert: methodListPresenter methodListPresenter selection breakPoints size equals: 0!

test_showMethodsFailingClassRecompilation
	"show a method list browser with as much compile information as possible"

	| failService |
	self testsIssue: #issue390 withTitle: 'Rename instance variable with accessor method is... wonky'.
	self selectRowanSample1Test.
	self
		saveClass: 'FailCompile'
		superclass: 'Object'
		instVars: #(#aaa)
		package: 'RowanSample1-Core'.
	
	[self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Core' in: self packageListPresenter.
	self selectServiceNamed: 'FailCompile' in: self classListPresenter.
	self projectsPresenter selectVariableTab.
	self projectsPresenter variableListPresenter selection: 'aaa'.
	self projectsPresenter addVariableAccessors.
	self projectsPresenter classDefinitionPresenter
		value: 'Object rwSubclass: ''FailCompile''
	instVarNames: #(#bbb)
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''RowanSample1-Core''
	options: #()'.
	methodListBrowser := self projectsPresenter editSaveClass.
	failService := methodListBrowser primaryPresenter methodListPresenter methodListPresenter list
				first.
	self assert: methodListBrowser primaryPresenter methodListPresenter methodListPresenter list size
		equals: 1.
	self assert: failService className = 'FailCompile'.
	self assert: failService selector = #methodFailingRecompile.
	self assert: failService category = 'other'.
	self assert: ('*aaa*aaa*' match: failService source)]
			ensure: 
				[self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass.
				methodListBrowser view close]!

test_simpleHierarchyTest
	"just make sure that we can select different classes and the hierarchy browser updates"

	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Services-Core') in: self packageListPresenter.
	self selectServicesNamed: (Array with: 'RowanService') in: self classListPresenter.
	self selectHierarchyTab.
	self assert: self projectsPresenter classHierarchyPresenter selection name = 'RowanService'.
	self selectClassListTab.
	self assert: self projectsPresenter classListPresenter selection name = 'RowanService'.
	self selectServicesNamed: (Array with: 'RowanProjectService') in: self classListPresenter.
	self selectHierarchyTab.
	self assert: self projectsPresenter classHierarchyPresenter selection name = 'RowanProjectService'.
	self selectClassListTab.
	self assert: self projectsPresenter classListPresenter selection name = 'RowanProjectService'!

test_sunitBarEnabledOnEntry
	self testsIssue: #issue179 withTitle: 'SUnit tab issues'.
	self selectRowanSample1Test.
	self selectSUnitTab.
	self assert: self projectsPresenter textAreaTabs currentCard name equals: 'sunit'.
	"this is a proxy for testing the enablement of the sunit bar. We just have
	to trust that when the methodListPresenter is enabled, the sunit bar is enabled."
	self assert: self projectsPresenter sunitPresenter methodListPresenter view hasFocus!

test_sunitBarEnabledOnReEntry
	self testsIssue: #issue179 withTitle: 'SUnit tab issues'.
	self selectRowanSample1Test.
	self selectSUnitTab.
	self assert: self projectsPresenter textAreaTabs currentCard name equals: 'sunit'.
	"this is a proxy for testing the enablement of the sunit bar. We just have
	to trust that when the methodListPresenter is enabled, the sunit bar is enabled."
	self assert: self projectsPresenter sunitPresenter methodListPresenter view hasFocus.
	self projectsPresenter selectCommentTab.
	self selectSUnitTab.
	self assert: self projectsPresenter sunitPresenter methodListPresenter view hasFocus!

test_sunitBrowserForTestClass
	| sunitItem sunitBrowser |
	self testsIssue: #issue336
		withTitle: 'S-Unit Tests In an abstract class and its subclasses are not managed properly'.
	self selectRowanSample1Test.
	sunitItem := self classListPresenter view queryContextMenu items
				detect: [:menuItem | menuItem command == #showSUnitBrowserOnClass].
	sunitBrowser := sunitItem commandDescription performAgainst: self projectsPresenter.
	
	[self assert: (sunitBrowser isKindOf: JadeiteSUnitBrowser).
	self assert: sunitBrowser primaryPresenter classListPresenter selection name
		equals: 'RowanSample1Test'.
	self assert: sunitBrowser primaryPresenter packageListPresenter selection name
		equals: 'RowanSample1-Tests']
			ensure: [self destroy: sunitBrowser]!

test_sunitBrowserIsEnabledForTestClass
	| commandQuery |
	self testsIssue: #issue336
		withTitle: 'S-Unit Tests In an abstract class and its subclasses are not managed properly'.
	self selectRowanSample1Test.
	commandQuery := self
				queryCommand: #showSUnitBrowserOnClass
				inPresenter: self projectsPresenter
				view: self classListPresenter view.
	self assert: commandQuery isEnabled.
	self selectRowanSample1Class.
	commandQuery := self
				queryCommand: #showSUnitBrowserOnClass
				inPresenter: self projectsPresenter
				view: self classListPresenter view.
	self deny: commandQuery isEnabled!

test_sunitBrowserNoSelectedTest
	"If there is no selected class, the menu item should not be enabled"

	| commandQuery |
	self testsIssue: #issue336
		withTitle: 'S-Unit Tests In an abstract class and its subclasses are not managed properly'.
	self deselectProjects.
	self assertIsNil: self projectsPresenter selectedClass.
	commandQuery := self
				queryCommand: #showSUnitBrowserOnClass
				inPresenter: self projectsPresenter
				view: self classListPresenter view.
	self deny: commandQuery isEnabled!

test_sunitCtrlB
	self testsIssue: #issue218 withTitle: 'Ctl-B does not `debug` selected test in SUnit browser'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Tests' in: self packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: self classListPresenter.
	self selectSUnitTab.
	self projectsPresenter sunitPresenter methodListPresenter selectionByIndex: #(1).	"test1 - select by index implicitly tests sorted order"
	self projectsPresenter sunitPresenter jadeDebug.	"What is sent when Ctrl-B is pressed."
	self assert: self projectsPresenter sunitPresenter methodListPresenter selection first testResult
		equals: 'passed'!

test_sunitInheritedTests
	| classTestSelectors testClassTestSelectors |
	self testsIssue: #issue211
		withTitle: 'SUnit browser and SUnit tab in Project browser missing inherited test cases'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Tests' in: self packageListPresenter.
	self selectServiceNamed: 'RowanClassServiceTest' in: self classListPresenter.
	self selectSUnitTab.
	classTestSelectors := self projectsPresenter sunitPresenter methodListPresenter list
				collect: [:service | service selector].
	self selectServiceNamed: 'RowanTestClassServiceTest' in: self classListPresenter.
	testClassTestSelectors := self projectsPresenter sunitPresenter methodListPresenter list
				collect: [:service | service selector].
	self assert: testClassTestSelectors size > classTestSelectors size.	"the subclass inherits the super class's tests"
	classTestSelectors do: [:selector | self assert: (testClassTestSelectors includes: selector)]!

test_sunitOnlyRunTestMethods
	self testsIssue: #issue218 withTitle: 'Ctl-B does not `debug` selected test in SUnit browser'.
	self selectRowanSample1Test.
	self
		saveMethod: 'nonTestMethod  ^123'
		in: 'RowanSample1Test'
		category: 'deleteMe'.
	[self selectMethodsNamed: #(#nonTestMethod #test1). 
	self projectsPresenter jadeDebug. 
	self assert: self projectsPresenter isSunitTabSelected. 
	self assert: self projectsPresenter sunitPresenter methodListPresenter selections size equals: 1. 
	self assert: self projectsPresenter sunitPresenter methodListPresenter selections first selector equals: #test1. 
	self assert: self projectsPresenter sunitPresenter textResultPresenter  value equals: '1 run, 1 passed, 0 failures, 0 errors'. 
	] ensure: 
			[self selectMethodNamed: #nonTestMethod.
			self projectsPresenter removeMethods: self classListPresenter selections]!

test_sunitRunAndMeasureTime
	| runSelectedItem selection |
	self testsIssue: #issue391 withTitle: '(3.0.53) SUnit browser running test method in wrong class'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[self selectRowanSample1Test.
	self selectSUnitTab.
	self projectsPresenter sunitPresenter reset.
	runSelectedItem := self projectsPresenter sunitPresenter methodListPresenter view queryContextMenu
				items detect: [:menuItem | menuItem command == #runAndMesureTime].
	selection := self projectsPresenter sunitPresenter methodListPresenter list
				detect: [:methodService | methodService selector = #test1].
	self projectsPresenter sunitPresenter methodListPresenter selections: (Array with: selection).
	self assert: self projectsPresenter sunitPresenter methodListPresenter selections first testResult
		equals: nil.
	TestMessageBox plannedResult: #ok.
	runSelectedItem commandDescription performAgainst: self projectsPresenter sunitPresenter.
	self assert: self projectsPresenter sunitPresenter methodListPresenter selections first testResult
		equals: 'passed']
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

test_sunitRunSelected
	| runSelectedItem selection |
	self testsIssue: #issue391 withTitle: '(3.0.53) SUnit browser running test method in wrong class'.
	self selectRowanSample1Test.
	self selectSUnitTab.
	runSelectedItem := self projectsPresenter sunitPresenter methodListPresenter view queryContextMenu
				items detect: [:menuItem | menuItem command == #runSelected].
	selection := self projectsPresenter sunitPresenter methodListPresenter list
				detect: [:methodService | methodService selector = #test1].
	self projectsPresenter sunitPresenter methodListPresenter selections: (Array with: selection).
	self projectsPresenter sunitPresenter reset. 
	self assert: self projectsPresenter sunitPresenter methodListPresenter selections first testResult equals: nil. 
	runSelectedItem commandDescription performAgainst: self projectsPresenter sunitPresenter.
	self assert: self projectsPresenter sunitPresenter methodListPresenter selections first testResult equals: 'passed'.
	
	runSelectedItem := self projectsPresenter methodListPresenter view queryContextMenu
				items detect: [:menuItem | menuItem command == #runMethodTests].
	self selectMethodNamed: #test2. 
	runSelectedItem commandDescription performAgainst: self projectsPresenter.
	self assert: self projectsPresenter sunitPresenter methodListPresenter selections first testResult equals: 'passed'.
	self assert: self projectsPresenter sunitPresenter methodListPresenter selections first selector equals: #test2. !

test_sunitTabCanRefresh
	self testsIssue: #issue279 withTitle: 'Sunit browser refresh, auto or manual'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Tests' in: self packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: self classListPresenter.
	self selectSUnitTab.
	self assert: self projectsPresenter sunitPresenter methodListPresenter list size equals: 4. 
	self projectsPresenter sunitPresenter refresh. "sent by context menu"
	self assert: self projectsPresenter sunitPresenter methodListPresenter list size equals: 4.  "just make sure we have a refresh available that doesn't blow up"
!

test_sUnitTabHandlesShortSelector
	self testsIssue: #issue173 withTitle: 'new SUnit browser code walksback on short selector'.
	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Services-Tests') in: self packageListPresenter.
	self selectServiceNamed: 'RwRowanProjectIssuesTest' in: self classListPresenter.
	self selectHierarchyTab.
	self selectClassInHierarchyNamed: 'TestCase'.	"<<< bug occurred here"
	self assert: self projectsPresenter selectedClass name = 'TestCase'!

test_sUnitTabRefresh
	| jadeiteMenu refreshItem |
	self testsIssue: #issue263 withTitle: 'With class selected, but not method selected, in SUnit tab, project refresh gets error'.
	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Services-Tests') in: self packageListPresenter.
	self selectServiceNamed: 'RowanServicesTest' in: self classListPresenter.
	self projectsPresenter selectSUnitTab.
	jadeiteMenu := self itemNamed: 'Jadeite' in: projectsBrowser view menuBar. 
	refreshItem := self itemNamed: 'Refresh' in: jadeiteMenu.
	refreshItem commandDescription performAgainst: self projectsPresenter. "<<< walkback occurred here"
	self assert: self projectsPresenter selectedClass name equals: 'RowanServicesTest'.
	self assert: self projectsPresenter sunitPresenter methodListPresenter list isEmpty "no tests in the abstract class" !

test_sunitUpdatesProperly
	| secondBrowser source newMethodService |
	self testsIssue: #issue279 withTitle: 'Sunit browser refresh, auto or manual'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Tests' in: self packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: self classListPresenter.
	self selectSUnitTab.
	self assert: self projectsPresenter sunitPresenter methodListPresenter list size equals: 4.	"should be four after project load"
	secondBrowser := self openWindow: [transcript openJadeiteProjectsBrowser].
	
	[self selectServiceNamed: 'RowanSample1' in: secondBrowser currentCard projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Tests' in: secondBrowser currentCard packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: secondBrowser currentCard classListPresenter.
	secondBrowser currentCard selectCategoryNamed: 'tests'.
	source := 'testMethod  
		self assert: true'.
	secondBrowser currentCard methodSourcePresenter value: source.
	secondBrowser currentCard editSaveMethod: secondBrowser currentCard classListPresenter selection.
	self assert: self projectsPresenter textAreaTabs currentCard name = 'sunit'.
	self assert: self projectsPresenter sunitPresenter methodListPresenter list size equals: 5.
	newMethodService := self projectsPresenter sunitPresenter methodListPresenter list
				detect: [:methodService | methodService selector == #testMethod]
				ifNone: [].
	self denyIsNil: newMethodService.
	"select a method in first browser and add another method"
	self selectMethodNamed: #test1.
	secondBrowser currentCard selectCategoryNamed: 'tests'.
	source := 'testMethod2
		self assert: true'.
	secondBrowser currentCard methodSourcePresenter value: source.
	secondBrowser currentCard editSaveMethod: secondBrowser currentCard classListPresenter selection.
	"self assert: self projectsPresenter textAreaTabs currentCard name = 'sunit'."
	self assert: self projectsPresenter sunitPresenter methodListPresenter list size equals: 6.
	newMethodService := self projectsPresenter sunitPresenter methodListPresenter list
				detect: [:methodService | methodService selector == #testMethod2]
				ifNone: [].
	self denyIsNil: newMethodService]
			ensure: [self destroy: secondBrowser]!

test_switchToVariableWithUnsavedChanges
	"no confirmation dialogs raised when switching between category and variable tabs"

	self testsIssue: #issue493
		withTitle: '(oddity) change from category tab to variables tab should not give "method has unsaved changes" prompt'.
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	self deny: self methodSourcePresenter view isModified.
	self methodSourcePresenter value: 'test1 ^''aaaa'''.
	self assert: self methodSourcePresenter view isModified.
	self projectsPresenter selectVariableTab.
	self assert: self methodSourcePresenter view isModified.
	self assert: self methodSourcePresenter value equals: 'test1 ^''aaaa'''.
	self projectsPresenter selectCategoryTab.
	self assert: self methodSourcePresenter view isModified.
	self assert: self methodSourcePresenter value equals: 'test1 ^''aaaa'''!

test_symbolsWithoutImplementorsFound
	"I think the only way for a symbol to get added to AllSymbols is to commit it"

	| symbols |
	self testsIssue: #issue258
		withTitle: 'wildcard senders and implentors don''t return proper selection list'.
	self selectRowanSample1Class.
	self saveMethodWithUnimplementedSelector.
	self commitTransaction.
	symbols := JadePresenter symbolsFrom: 'fnoodley1' session: session.
	self assert: symbols size equals: 1.
	self assert: symbols first = #fnoodley1!

test_tabNames
	| textTabs |
	self testsIssue: #issue186 withTitle: 'icon in console menu'.
	self selectRowanSample1Class.
	self saveHooMethod.
	methodListBrowser := self projectsPresenter browseImplementorsOf: #hoo.
	textTabs := methodListBrowser primaryPresenter textTabs. 
	self assert: textTabs size equals: 2. 
	self assert: textTabs first equals: 'Method Source'. 
	self assert: textTabs last equals: 'Comparison'. 
	!

test_tabNames_projectsBrowser
	| textTabs |
	self rowanFixMe.	"fix the oddity that one tab is created differently"
	self testsIssue: #issue186 withTitle: 'icon in console menu'.
	self selectRowanSample1Class.
	self saveHooMethod.
	textTabs := self projectsPresenter textTabs.
	self assert: textTabs size equals: 6.
	self assert: (textTabs at: 1) text equals: 'Class Definition'.
	self assert: (textTabs at: 2) text equals: 'Class Documentation'.
	self assert: (textTabs at: 3) text equals: 'Method Source'.
	self assert: (textTabs at: 4) text equals: 'SUnit'.
	self assert: (textTabs at: 5) equals: 'Comparison'.	"for some as yet unknown reason, this is created differently"
	self assert: (textTabs at: 6) equals: 'Project'!

test_tabNames_projectsBrowserNotLost
	"why we have to put the text in the arrangement field is beyond me"

	| projectTabs index |
	self testsIssue: #issue229
		withTitle: 'project browser tabs appear to randomly display just `Rowan` or package name'.
	[self projectsPresenter parentPresenter view cards size = 1] whileFalse: 
			[self projectsPresenter parentPresenter view
				removeSubView: self projectsPresenter parentPresenter view lastCard].
	projectTabs := self projectsPresenter parentPresenter view cards.
	self projectsPresenter projectListPresenter resetSelection.
	index := 1.
	self assert: (projectTabs at: index) arrangement equals: index printString , ' Projects'.
	self selectRowanSample1Class.
	self assert: (projectTabs at: index) arrangement equals: index printString , ' RowanSample1-Core'.
	self selectCategoryNamed: 'accessing'.
	self assert: (projectTabs at: index) arrangement equals: index printString , ' RowanSample1-Core'.	"no change. this was a bug"
	self projectsPresenter topShell addSystemBrowser.
	projectTabs := self projectsPresenter parentPresenter view cards.
	index := 2.
	self assert: (projectTabs at: index) arrangement equals: index printString , ' Projects'.
	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Services-Core') in: self packageListPresenter.
	self selectServicesNamed: (Array with: 'RowanAnsweringService') in: self classListPresenter.
	self assert: (projectTabs at: index) arrangement equals: index printString , ' Rowan-Services-Core'.
	self selectCategoryNamed: 'client commands'.
	self assert: (projectTabs at: index) arrangement equals: index printString , ' Rowan-Services-Core'.	"no change. this was a bug"
	index := 1.
	self assert: (projectTabs at: index) arrangement equals: index printString , ' RowanSample1-Core'	"not affected by other tab"!

test_twoBrowsersAddedClassAppears
	"if the same package is selected, a new class appears but the existing
	class selection doesn't change"

	self testsIssue: #issue374
		withTitle: '(3.0.53) selecting package in one project browser causes sympathetic update in other'.
	self selectRowanSample1Class.
	self openSecondBrowser.
	self selectServiceNamed: 'RowanSample1' in: secondPresenter projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Core' in: secondPresenter packageListPresenter.
	self selectServiceNamed: self sampleClassName in: secondPresenter classListPresenter.
	self assert: secondPresenter classListPresenter list size equals: 2.
	self assertIsNil: (secondPresenter classListPresenter list
				detect: [:classService | classService name = 'TestClass']
				ifNone: []).
	self saveTestClassWithInstVars: Array new package: 'RowanSample1-Core'.	"add new class in first browser"
	self assert: self classListPresenter selection name = 'TestClass'.
	self assert: secondPresenter classListPresenter selection name equals: 'RowanSample1'.	"no selection change in second browser ..."
	self assert: secondPresenter classListPresenter list size equals: 3.	"... but new class shows up"
	self assert: secondPresenter classListPresenter list last name equals: 'TestClass'!

test_twoBrowsersAddedClassAppearsInHierarchy1
	| family |
	self testsIssue: #issue374
		withTitle: '(3.0.53) selecting package in one project browser causes sympathetic update in other'.
	self selectRowanSample1Class.
	self selectHierarchyTab.
	self openSecondBrowser.
	self selectServiceNamed: 'RowanSample1' in: secondPresenter projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Core' in: secondPresenter packageListPresenter.
	self selectServiceNamed: self sampleClassName in: secondPresenter classListPresenter.
	self selectHierarchyTabIn: secondPresenter.
	self assert: secondPresenter classHierarchyPresenter model size equals: 3.
	self assertLinearAncestry: #('Object' 'RowanSample1' 'RowanSubClass')
		in: secondPresenter classHierarchyPresenter.
	self assertIsNil: (secondPresenter classHierarchyPresenter model asBag
				detect: [:classService | classService name = 'TestClass']
				ifNone: []).
	self
		saveClass: 'TestClass'
		superclass: 'RowanSample1'
		instVars: Array new
		package: 'RowanSample1-Core'.
	self assert: self classHierarchyPresenter selection name = 'TestClass'.
	self assert: secondPresenter classHierarchyPresenter selection name equals: 'RowanSample1'.
	self assert: secondPresenter classHierarchyPresenter model size equals: 4.
	self denyIsNil: (secondPresenter classHierarchyPresenter model asBag
				detect: [:classService | classService name = 'TestClass']
				ifNone: []).
	family := Dictionary new.
	family at: 'Object' put: (Array with: 'RowanSample1').
	family at: 'RowanSample1' put: (Array with: 'RowanSubClass' with: 'TestClass').
	family at: 'RowanSubClass' put: Array new.
	family at: 'TestClass' put: Array new.
	self assertAncestry: family in: secondPresenter classHierarchyPresenter!

test_twoBrowsersAddedClassAppearsInHierarchy2
	| family |
	self testsIssue: #issue374
		withTitle: '(3.0.53) selecting package in one project browser causes sympathetic update in other'.
	self selectRowanSample1Class.
	self selectHierarchyTab.
	self openSecondBrowser.
	self selectServiceNamed: 'RowanSample1' in: secondPresenter projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Core' in: secondPresenter packageListPresenter.
	self selectServiceNamed: self sampleClassName in: secondPresenter classListPresenter.
	self selectHierarchyTabIn: secondPresenter.
	self assert: secondPresenter classHierarchyPresenter model size equals: 3.
	self assertLinearAncestry: #('Object' 'RowanSample1' 'RowanSubClass')
		in: secondPresenter classHierarchyPresenter.
	self assertIsNil: (secondPresenter classHierarchyPresenter model asBag
				detect: [:classService | classService name = 'TestClass']
				ifNone: []).
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: Array new
		package: 'RowanSample1-Core'.
	self assert: self classHierarchyPresenter selection name = 'TestClass'.
	self
		saveClass: 'SubSubSub'
		superclass: 'RowanSubClass'
		instVars: Array new
		package: 'RowanSample1-Core'.
	self assert: self classHierarchyPresenter selection name = 'SubSubSub'.
	self assert: secondPresenter classHierarchyPresenter selection name equals: 'RowanSample1'.
	self assert: secondPresenter classHierarchyPresenter model size equals: 5.
	family := Dictionary new.
	family at: 'Object' put: (Array with: 'RowanSample1' with: 'TestClass').
	family at: 'RowanSample1' put: (Array with: 'RowanSubClass').
	family at: 'RowanSubClass' put: (Array with: 'SubSubSub').
	family at: 'TestClass' put: Array new.
	self assertAncestry: family in: secondPresenter classHierarchyPresenter!

test_twoBrowsersAddedClassDoesNotAppearInDifferentHierarchy
	self testsIssue: #issue374
		withTitle: '(3.0.53) selecting package in one project browser causes sympathetic update in other'.
	self selectRowanSample1Class.
	self selectHierarchyTab.
	self openSecondBrowser.
	self selectServiceNamed: 'RowanSample1' in: secondPresenter projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Core' in: secondPresenter packageListPresenter.
	self selectServiceNamed: self sampleClassName in: secondPresenter classListPresenter.
	self selectHierarchyTabIn: secondPresenter.
	self assert: secondPresenter classHierarchyPresenter model size equals: 3.
	self assertLinearAncestry: #('Object' 'RowanSample1' 'RowanSubClass')
		in: secondPresenter classHierarchyPresenter.
	self assertIsNil: (secondPresenter classHierarchyPresenter model asBag
				detect: [:classService | classService name = 'TestClass']
				ifNone: []).
	self saveTestClassWithInstVars: Array new package: 'RowanSample1-Core'.	"add new class in first browser"
	self assert: self classHierarchyPresenter selection name = 'TestClass'.
	self assert: secondPresenter classHierarchyPresenter selection name equals: 'RowanSample1'	"no change in second browser because new class not in hierarchy"!

test_twoBrowsersAddedClassRearrangesItselfInHierarchy
	| family |
	self testsIssue: #issue374
		withTitle: '(3.0.53) selecting package in one project browser causes sympathetic update in other'.
	self selectRowanSample1Class.
	self selectHierarchyTab.
	self openSecondBrowser.
	self selectServiceNamed: 'RowanSample1' in: secondPresenter projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Core' in: secondPresenter packageListPresenter.
	self selectServiceNamed: self sampleClassName in: secondPresenter classListPresenter.
	self selectHierarchyTabIn: secondPresenter.
	self assert: secondPresenter classHierarchyPresenter model size equals: 3.
	self assertLinearAncestry: #('Object' 'RowanSample1' 'RowanSubClass')
		in: secondPresenter classHierarchyPresenter.
	self assertIsNil: (secondPresenter classHierarchyPresenter model asBag
				detect: [:classService | classService name = 'TestClass']
				ifNone: []).
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: Array new
		package: 'RowanSample1-Core'.
	self assert: self classHierarchyPresenter selection name = 'TestClass'.
	self assert: secondPresenter classHierarchyPresenter selection name equals: 'RowanSample1'.
	self assert: secondPresenter classHierarchyPresenter model size equals: 4.
	family := Dictionary new.
	family at: 'Object' put: (Array with: 'RowanSample1' with: 'TestClass').
	family at: 'RowanSample1' put: (Array with: 'RowanSubClass').
	family at: 'RowanSubClass' put: Array new.
	family at: 'TestClass' put: Array new.
	self assertAncestry: family in: secondPresenter classHierarchyPresenter.
	self
		saveClass: 'TestClass'
		superclass: 'RowanSubClass'
		instVars: Array new
		package: 'RowanSample1-Core'.	"changed superclass"
	self assert: secondPresenter classHierarchyPresenter selection name equals: 'RowanSample1'.
	self assert: secondPresenter classHierarchyPresenter model size equals: 4.
	family := Dictionary new.
	family at: 'Object' put: (Array with: 'RowanSample1').
	family at: 'RowanSample1' put: (Array with: 'RowanSubClass').
	family at: 'RowanSubClass' put: (Array with: 'TestClass').
	family at: 'TestClass' put: Array new.
	self assertAncestry: family in: secondPresenter classHierarchyPresenter!

test_twoBrowsersAddSameCategoryToClassAndInstance
	self testsIssue: #issue418
		withTitle: 'Navigating and category creation in class hiearchy view can''t keep class side/instance side straight'.
	self selectRowanSample1Test.
	self selectHierarchyTab.	"on instance/hierarchy"
	self openSecondBrowser.
	self selectServiceNamed: 'RowanSample1' in: secondPresenter projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Tests' in: secondPresenter packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: secondPresenter classListPresenter. 
	self selectHierarchyTabIn: secondPresenter.
	self selectClassTab.	"second browser on class/hierarchy"
	self deny: (self projectsPresenter categoryListPresenter list includes: 'fnoodle').
	self deny: (secondPresenter categoryListPresenter list includes: 'fnoodle').
	self projectsPresenter basicAddMethodCategory: 'fnoodle'.
	self assert: self projectsPresenter categoryListPresenter selection equals: 'fnoodle'.
	self deny: (secondPresenter categoryListPresenter list includes: 'fnoodle').
	secondPresenter basicAddMethodCategory: 'fnoodle'.
	self assert: secondPresenter categoryListPresenter selection equals: 'fnoodle'.
	self assert: (self categoryListPresenter list includes: 'fnoodle')!

test_twoBrowsersDontClearMethodList
	self testsIssue: #issue418
		withTitle: 'Navigating and category creation in class hiearchy view can''t keep class side/instance side straight'.
	self selectRowanSample1Test.
	self selectHierarchyTab.
	self assert: self classHierarchyPresenter selection name equals: 'RowanSample1Test'.
	self assert: self methodListPresenter list first selector equals: #test1.
	self openSecondBrowser.
	self selectServiceNamed: 'RowanSample1' in: secondPresenter projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Tests' in: secondPresenter packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: secondPresenter classListPresenter.
	self assert: secondPresenter classListPresenter selection name equals: 'RowanSample1Test'.
	self selectHierarchyTabIn: secondPresenter.
	self assert: self classHierarchyPresenter selection name equals: 'RowanSample1Test'.
	self assert: self methodListPresenter list first selector equals: #test1.
	self deny: self methodListPresenter list isEmpty.
	self assert: secondPresenter classHierarchyPresenter selection name equals: 'RowanSample1Test'.
	self assert: secondPresenter methodListPresenter list first selector equals: #test1.!

test_twoBrowsersNoUpdateWithoutPackageSelection
	self testsIssue: #issue374
		withTitle: '(3.0.53) selecting package in one project browser causes sympathetic update in other'.
	self selectRowanSample1Class.
	self openSecondBrowser.
	self assert: secondPresenter projectListPresenter selections isEmpty.
	self assert: secondPresenter packageListPresenter model isEmpty.
	self assert: secondPresenter classListPresenter model isEmpty.
	self assert: secondPresenter classHierarchyPresenter model isEmpty.
	self assert: secondPresenter categoryListPresenter model isEmpty.
	self assert: secondPresenter variableListPresenter model isEmpty.
	self assert: secondPresenter methodListPresenter model isEmpty.
	self
		saveClass: 'TestClass'
		superclass: 'RowanSample1'
		instVars: Array new
		package: 'RowanSample1-Core'.
	self assert: self classListPresenter selection name = 'TestClass'.
	self assert: secondPresenter projectListPresenter selections isEmpty.
	self assert: secondPresenter packageListPresenter model isEmpty.
	self assert: secondPresenter classListPresenter model isEmpty.
	self assert: secondPresenter classHierarchyPresenter model isEmpty.
	self assert: secondPresenter categoryListPresenter model isEmpty.
	self assert: secondPresenter variableListPresenter model isEmpty.
	self assert: secondPresenter methodListPresenter model isEmpty!

test_twoBrowsersRemoveMethod
	self testsIssue: #issue404 withTitle: 'Removing a method using method browser'.
	self selectRowanSample1Class.
	self openSecondBrowser.
	self selectServiceNamed: 'RowanSample1' in: secondPresenter projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Core' in: secondPresenter packageListPresenter.
	self selectServiceNamed: self sampleClassName in: secondPresenter classListPresenter.
	self denyMethodInList: #sampleMethod presenter: secondPresenter methodListPresenter.
	self denyMethodInList: #sampleMethod.
	self saveSampleMethod.
	self assertMethodInList: #sampleMethod.
	self assert: self methodListPresenter selection selector equals: #sampleMethod.
	self assertMethodInList: #sampleMethod presenter: secondPresenter methodListPresenter.
	self projectsPresenter basicRemoveMethods.
	self denyMethodInList: #sampleMethod presenter: secondPresenter methodListPresenter.
	self denyMethodInList: #sampleMethod!

test_twoBrowsersUpdate
	self testsIssue: #issue374
		withTitle: '(3.0.53) selecting package in one project browser causes sympathetic update in other'.
	self selectRowanSample1Class.
	self assert: self classListPresenter selection name equals: 'RowanSample1'.
	self assert: self classListPresenter list size equals: 2.
	self assert: self classListPresenter list first name equals: 'RowanSample1'.
	self assert: self classListPresenter list last name equals: 'RowanSubClass'.
	self openSecondBrowser.
	self selectServiceNamed: 'RowanSample1' in: secondPresenter projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Core' in: secondPresenter packageListPresenter.
	self selectServiceNamed: self sampleClassName in: secondPresenter classListPresenter.
	self assert: self classListPresenter selection name equals: 'RowanSample1'.
	self assert: self classListPresenter list size equals: 2.
	self assert: self classListPresenter list first name equals: 'RowanSample1'.
	self assert: self classListPresenter list last name equals: 'RowanSubClass'.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Core'.
	self assert: secondPresenter classListPresenter selection name equals: 'RowanSample1'.
	self assert: secondPresenter classListPresenter list size equals: 2.
	self assert: secondPresenter classListPresenter list first name equals: 'RowanSample1'.
	self assert: secondPresenter classListPresenter list last name equals: 'RowanSubClass'.
	self assert: secondPresenter packageListPresenter selection name equals: 'RowanSample1-Core'.
	self selectRowanSample1Test.
	self assert: self classListPresenter selection name equals: 'RowanSample1Test'.
	self assert: self classListPresenter list size equals: 1.
	self assert: self classListPresenter list first name equals: 'RowanSample1Test'.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Tests'.
	self assert: secondPresenter classListPresenter selection name equals: 'RowanSample1'.
	self assert: secondPresenter classListPresenter list size equals: 2.
	self assert: secondPresenter classListPresenter list first name equals: 'RowanSample1'.
	self assert: secondPresenter classListPresenter list last name equals: 'RowanSubClass'.
	self assert: secondPresenter packageListPresenter selection name equals: 'RowanSample1-Core'!

test_twoBrowsersUpdateClassHierarchyDifferentDictionarySelected
	self selectRowanSample1Class.
	self openSecondBrowser.
	"no dictionary selected"
	self selectServiceNamed: RowanProjectService noneProject name
		in: secondPresenter projectListPresenter.
	self selectServiceNamed: 'Published' in: secondPresenter dictionaryPresenter.
	self selectHierarchyTabIn: secondPresenter.
	self assertLinearAncestry: #('Object' 'Rowan') in: secondPresenter classHierarchyPresenter.
	self selectHierarchyTab.	"in first browser"
	self assertLinearAncestry: #('Object' 'RowanSample1' 'RowanSubClass')
		in: self classHierarchyPresenter.
	self assertLinearAncestry: #('Object' 'Rowan') in: secondPresenter classHierarchyPresenter!

test_twoBrowsersUpdateClassHierarchyDifferentPackageSelected
	self openSecondBrowser.

	"different package selected"
	self selectRowanSample1Class.
	self selectServiceNamed: 'RowanSample1' in: secondPresenter projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Tests' in: secondPresenter packageListPresenter.
	self selectHierarchyTabIn: secondPresenter.
	self assertLinearAncestry: #('Object' 'TestAsserter' 'TestCase' 'RowanSample1Test')
		in: secondPresenter classHierarchyPresenter.
	self selectHierarchyTab.	"in first browser"
	self assertLinearAncestry: #('Object' 'RowanSample1' 'RowanSubClass')
		in: self classHierarchyPresenter.
	self assertLinearAncestry: #('Object' 'TestAsserter' 'TestCase' 'RowanSample1Test')
		in: secondPresenter classHierarchyPresenter!

test_twoBrowsersUpdateClassHierarchyNoDictionarySelected
	self selectRowanSample1Class. 
	self openSecondBrowser.
	"no dictionary selected"
	self selectServiceNamed: RowanProjectService noneProject name
		in: secondPresenter projectListPresenter.
	secondPresenter dictionaryPresenter resetSelection.
	self selectHierarchyTabIn: secondPresenter.
	self assert: secondPresenter classHierarchyPresenter model isEmpty.
	self selectHierarchyTab.	"in first browser"
	self assertLinearAncestry: #('Object' 'RowanSample1' 'RowanSubClass')
		in: self classHierarchyPresenter.
	self assert: secondPresenter classHierarchyPresenter model isEmpty!

test_twoBrowsersUpdateClassHierarchyNoPackageSelected
	self openSecondBrowser.
	"no package selected"
	self selectRowanSample1Class.
	self selectServiceNamed: 'RowanSample1' in: secondPresenter projectListPresenter.
	secondPresenter packageListPresenter resetSelection.
	self selectHierarchyTabIn: secondPresenter.
	self assert: secondPresenter classHierarchyPresenter model isEmpty.
	self selectHierarchyTab.	"in first browser"
	self assertLinearAncestry: #('Object' 'RowanSample1' 'RowanSubClass')
		in: self classHierarchyPresenter.
	self assert: secondPresenter classHierarchyPresenter model isEmpty!

test_twoBrowsersUpdateClassHierarchyNoProjectSelected
	self selectRowanSample1Class.
	self openSecondBrowser.
	"no project selected"
	secondPresenter projectListPresenter resetSelection.
	self selectHierarchyTabIn: secondPresenter.
	self assert: secondPresenter classHierarchyPresenter model isEmpty.
	self selectHierarchyTab.	"in first browser"
	self assertLinearAncestry: #('Object' 'RowanSample1' 'RowanSubClass')
		in: self classHierarchyPresenter.
	self assert: secondPresenter classHierarchyPresenter model isEmpty.
!

test_twoBrowsersUpdateHierarchy
	self testsIssue: #issue374
		withTitle: '(3.0.53) selecting package in one project browser causes sympathetic update in other'.
	self selectRowanSample1Class.
	self selectHierarchyTab.
	self assertLinearAncestry: #('Object' 'RowanSample1' 'RowanSubClass')
		in: self classHierarchyPresenter.
	self openSecondBrowser.
	self selectServiceNamed: 'RowanSample1' in: secondPresenter projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Core' in: secondPresenter packageListPresenter.
	self selectHierarchyTabIn: secondPresenter.
	self selectTreeServicesNamed: (Array with: self sampleClassName)
		in: secondPresenter classHierarchyPresenter.
	self assert: self classHierarchyPresenter selection name equals: 'RowanSample1'.
	self assertLinearAncestry: #('Object' 'RowanSample1' 'RowanSubClass')
		in: self classHierarchyPresenter.
	self assertLinearAncestry: #('Object' 'RowanSample1' 'RowanSubClass')
		in: secondPresenter classHierarchyPresenter.
	self selectRowanSample1Test.
	self assertLinearAncestry: #('Object' 'TestAsserter' 'TestCase' 'RowanSample1Test')
		in: self classHierarchyPresenter.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Tests'.
	self assert: secondPresenter classHierarchyPresenter selection name equals: 'RowanSample1'.
	self assertLinearAncestry: #('Object' 'RowanSample1' 'RowanSubClass')
		in: secondPresenter classHierarchyPresenter!

test_twoTabsHaveIndependentCompileErrors
	self testsIssue: #issue440
		withTitle: '(3.0.62) error message from previous compile error hangs around after error fixed'.
	projectsBrowser addSystemBrowser.
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	
	[| source |
	source := 'gloop
	"I be unique"
	^'.
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self assert: self projectsPresenter statusBarText view backcolor equals: Color red faded.
	self assert: self projectsPresenter statusBarText value equals: 'expected start of a statement; '.
	self previousTabView.
	self deny: self projectsPresenter statusBarText view backcolor equals: Color red faded.
	self deny: self projectsPresenter statusBarText value equals: 'expected start of a statement; '.
	self selectRowanSample1Test.
	source := 'gloop
	"I be unique"
	^''abc'.
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self assert: self projectsPresenter statusBarText view backcolor equals: Color red faded.
	self assert: self projectsPresenter statusBarText value
		equals: 'missing end of literal mark (prime); expected start of a statement; '.
	self nextTabView.
	self assert: self projectsPresenter statusBarText view backcolor equals: Color red faded.
	self assert: self projectsPresenter statusBarText value equals: 'expected start of a statement; ']
			ensure: 
				[self methodSourcePresenter view isModified: false.
				projectsBrowser closeCard.
				self methodSourcePresenter view isModified: false.
				projectsBrowser view close.
				projectsBrowser := JadeiteTestResource current openProjectsBrowser]!

test_unicodeDisplayMethod
	| methodSource secondMethodListBrowser |
	self testsIssue: #issue
		withTitle: '(3.0.65) browse methods containing `%` yields "Can''t hold $\x3B1" Dollphin error'.
	session executeString: 'RowanServicesTest new compileUnicodeMethod'.
	
	[self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Tests' in: self packageListPresenter.
	self selectServiceNamed: 'RowanServicesTest' in: self classListPresenter.
	self selectMethodNamed: #iAmAUnicodeMethod.
	self assert: ('*METHOD SOURCE CANNOT BE DISPLAYED*' match: self methodSourcePresenter value).
	self assert: self methodSourcePresenter view backcolor equals: Color red faded faded.
	methodListBrowser := self projectsPresenter browseImplementors.
	methodSource := methodListBrowser primaryPresenter methodSourcePresenter documentPresenter.
	self assert: ('*METHOD SOURCE CANNOT BE DISPLAYED*' match: methodSource value).
	self assert: methodSource view backcolor equals: Color red faded faded.
	secondMethodListBrowser := methodListBrowser primaryPresenter methodListPresenter
				browseImplementors.
	
	[methodSource := secondMethodListBrowser primaryPresenter methodSourcePresenter documentPresenter.
	self assert: ('*METHOD SOURCE CANNOT BE DISPLAYED*' match: methodSource value).
	self assert: methodSource view backcolor equals: JadeTextStyles default colorForUndisplayableSource]
			ensure: 
				[self projectsPresenter basicRemoveMethods.
				secondMethodListBrowser view close]]
			ensure: 
				[self abortTransaction.
				self cloneRowanSample1.
				self ensureRowanSample1Loaded]!

test_unicodeSpecialMethodNotRed
	"the method that generates the non-displayable source message
	should itself not be colored red"

	self testsIssue: #issue
		withTitle: '(3.0.65) browse methods containing `%` yields "Can''t hold $\x3B1" Dollphin error'.
	session executeString: 'RowanServicesTest new compileUnicodeMethod'.
	
	[self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Core' in: self packageListPresenter.
	self selectServiceNamed: 'RowanMethodService' in: self classListPresenter.
	self selectClassTab.
	self selectMethodNamed: #removeUnicode:.
	self deny: self methodSourcePresenter view backcolor
		equals: JadeTextStyles default colorForUndisplayableSource]
			ensure: 
				[self selectInstanceTab.
				self selectServiceNamed: 'Rowan-Services-Tests' in: self packageListPresenter.
				self selectServiceNamed: 'RowanServicesTest' in: self classListPresenter.
				self selectMethodNamed: #iAmAUnicodeMethod.
				self projectsPresenter basicRemoveMethods]!

test_UnsavedChangesActionChangeSelectionIgnoreChanges
	self testsIssue: #issue388
		withTitle: '(3.0.53) useful to be able to open method browser on selected methods in project browser'.
	TestMessageBox enableJadeiteTestMessageBox.
	[| source |
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Core' in: self packageListPresenter.
	self selectServiceNamed: self sampleClassName in: self classListPresenter.
	self selectCategoryNamed: 'accessing'.
	source := 'sampleMethod  
		| aaa | 
		aaa := 123. 
		^aaa'.
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self assert: self methodListPresenter selection selector equals: #sampleMethod.
	self methodSourcePresenter value: 'new text'.
	self methodSourcePresenter view isModified: true.
	TestMessageBox plannedResult: #no.	"answer that we want to ignore changes"
	self selectWithChangeEventMethodNamed: #foo.
	self assert: self methodListPresenter selection selector equals: #foo]
			ensure: 
				[TestMessageBox disableJadeiteTestMessageBox.
				self projectsPresenter basicRemoveMethods	"for next test"]!

test_UnsavedChangesActionChangeSelectionStayOnMethod
	self testsIssue: #issue386
		withTitle: '(3.0.53) no warning about unsaved changes in method browser when clicking on different method'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[| source |
	self selectRowanSample1Class.
	self selectCategoryNamed: 'accessing'.
	source := 'sampleMethod  
		| aaa | 
		aaa := 123. 
		^aaa'.
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self assert: self methodListPresenter selection selector equals: #sampleMethod.
	self methodSourcePresenter value: 'new text'.
	self methodSourcePresenter view isModified: true.
	TestMessageBox plannedResult: #yes.	"answer that we want to stay on method"
	self selectWithChangeEventMethodNamed: #foo.
	self assert: self methodListPresenter selection selector equals: #sampleMethod]
			ensure: 
				[TestMessageBox disableJadeiteTestMessageBox.
				self projectsPresenter basicRemoveMethods]!

test_UnsavedChangesActionCloseWindow
	self testsIssue: #issue386
		withTitle: '(3.0.53) no warning about unsaved changes in method browser when clicking on different method'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[| source |
	self selectRowanSample1Class.
	self selectCategoryNamed: 'accessing'.
	source := 'sampleMethod  
		| aaa | 
		aaa := 123. 
		^aaa'.
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self assert: self methodListPresenter selection selector equals: #sampleMethod.
	self methodSourcePresenter value: 'new text'.
	self methodSourcePresenter view isModified: true.
	TestMessageBox plannedResult: #no.	"answer that we want to ignore changes"
	projectsBrowser view close.
	self deny: projectsBrowser isOpen]
			ensure: 
				[TestMessageBox disableJadeiteTestMessageBox.
				JadeiteTestResource current projectsBrowser: nil.
				projectsBrowser := JadeiteTestResource current openProjectsBrowser	"for next test"]!

test_UnsavedChangesActionCloseWindowStayOnMethod
	self testsIssue: #issue386
		withTitle: '(3.0.53) no warning about unsaved changes in method browser when clicking on different method'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[| source |
	self selectRowanSample1Class.
	self selectCategoryNamed: 'accessing'.
	source := 'sampleMethod  
		| aaa | 
		aaa := 123. 
		^aaa'.
	self methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self assert: self methodListPresenter selection selector equals: #sampleMethod.
	self methodSourcePresenter value: 'new text'.
	self methodSourcePresenter view isModified: true.
	TestMessageBox plannedResult: #yes.	"answer that we want to stay on selection"
	projectsBrowser view close.
	self assert: projectsBrowser isOpen.
	self assert: self methodListPresenter selection selector equals: #sampleMethod]
			ensure: 
				[TestMessageBox disableJadeiteTestMessageBox.
				self projectsPresenter basicRemoveMethods]!

test_updateHierarchyAfterClassRecompile
	| selection |
	self selectRowanSample1Test.
	self selectHierarchyTab.
	self
		saveClass: 'RowanSample1Test'
		superclass: 'TestCase'
		instVars: #('ab')
		package: 'RowanSample1-Tests'.
	
	[selection := self classHierarchyPresenter selection.
	self assert: selection name equals: 'RowanSample1Test'.
	self assert: selection version equals: 2.
	self assert: selection versions equals: 2.
	self classHierarchyPresenter selection displayString equals: 'RowanSample1Test (2/2)'.
	self assert: self projectsPresenter classDefinitionPresenter value
		equals: 'TestCase rwSubclass: ''RowanSample1Test''
	instVarNames: #( ab)
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ''RowanSample1-Tests''
	options: #()
'
				replaceCrLfWithLf]
			ensure: 
				["restore the class"
				self
					saveClass: 'RowanSample1Test'
					superclass: 'TestCase'
					instVars: #()
					package: 'RowanSample1-Tests']!

test_variablesTab
	"at least do something with the variables tab"

	| selectedMethod methodListSize dictionaryBrowser variableSize |
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Core' in: self packageListPresenter.
	self selectServiceNamed: 'RowanClassService' in: self classListPresenter.
	self projectsPresenter selectVariableTab.
	self projectsPresenter variableListPresenter selection: 'variables'.
	methodListSize := self methodListPresenter list size.
	self denyIsNil: (selectedMethod := self methodListPresenter list
						detect: [:service | service selector = #initializeVariablesFor:]
						ifNone: []).
	self methodListPresenter selection: selectedMethod.
	methodListBrowser := JadePresenter browseImplementorsOf: 'allInstVarNames' session: session.	"selected method sends this"
	self assert: methodListBrowser primaryPresenter methodListPresenter methodListPresenter selection
				selector
		equals: #allInstVarNames.
	dictionaryBrowser := methodListBrowser primaryPresenter methodListPresenter browseClass.
	[self assert: self methodListPresenter list size equals: methodListSize] ensure: 
			[self destroy: dictionaryBrowser.
			self destroy: methodListBrowser].
	variableSize := self projectsPresenter variableListPresenter list size.
	self selectHierarchyTab.
	self assert: self projectsPresenter variableListPresenter list size equals: variableSize.
	self assert: self projectsPresenter variableListPresenter selection equals: 'variables'.
	self assert: self methodListPresenter selection equals: selectedMethod.	"assert selections & lists stay the same switching to hierarchy view ..."
	self selectClassListTab.
	self assert: self projectsPresenter variableListPresenter list size equals: variableSize.
	self assert: self projectsPresenter variableListPresenter selection equals: 'variables'.
	self assert: self methodListPresenter selection equals: selectedMethod	"... and back"!

test_variablesUpdatedOnClassSaveInClassList
	self testsIssue: #issue445 withTitle: '(3.0.63) class def / instance var oddities'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Core' in: self packageListPresenter.
	self
		saveClass: 'TempClass'
		superclass: 'Object'
		instVars: #()
		package: 'RowanSample1-Core'.
	self projectsPresenter selectVariableTab.
	self assert: self categoryListPresenter list isEmpty.
	self projectsPresenter selectCategoryTab.
	self
		saveClass: 'TempClass'
		superclass: 'Object'
		instVars: #('aaa')
		package: 'RowanSample1-Core'.
	self projectsPresenter selectVariableTab.
	self assert: self categoryListPresenter list size equals: 1.
	self assert: (self categoryListPresenter list includes: 'aaa')!

test_variablesUpdatedOnClassSaveInHierarchy
	self testsIssue: #issue445 withTitle: '(3.0.63) class def / instance var oddities'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Core' in: self packageListPresenter.
	self selectHierarchyTab.
	self
		saveClass: 'TempClass'
		superclass: 'Object'
		instVars: #()
		package: 'RowanSample1-Core'.
	self projectsPresenter selectVariableTab.
	self assert: self categoryListPresenter list isEmpty.
	self projectsPresenter selectCategoryTab.
	self
		saveClass: 'TempClass'
		superclass: 'Object'
		instVars: #('aaa')
		package: 'RowanSample1-Core'.
	self projectsPresenter selectVariableTab.
	self assert: self categoryListPresenter list size equals: 1.
	self assert: (self categoryListPresenter list includes: 'aaa')!

test_verifyValidCategory
	self testsIssue: #issue205 withTitle: 'misspelled extension category name causes trouble'.
	self assert: (self projectsPresenter verifyValidCategory: '*Rowan-Kernel') .
	self assert: (self projectsPresenter verifyValidCategory: '*rowan-kernel') .
	self assert: (self projectsPresenter verifyValidCategory: 'aaa') .
	self deny: (self projectsPresenter verifyValidCategory: '*rowankernel') .
	self deny: (self projectsPresenter verifyValidCategory: '*rowankernelx') .!

test_zzznoStepPoints
	"see corresponding server test. Character ranges should be the same."
	"test broken"

	| classService methodService |
	self selectRowanSample1Class.
	classService := self projectsPresenter selectedClass.
	classService
		command: #saveMethodSource:category:;
		commandArgs: (Array with: 'abc' with: 'test step points').
	self issueCommand: classService.
	methodService := (self selectMethodNamed: #abc) first.
	self assert: methodService stepPoints size equals: 0!

test_zzzstepPoint1
	"see corresponding server test. Character ranges should be the same."

	"test broken"

	| sourceString classService methodService |
	self selectRowanSample1Class.
	sourceString := session executeString: 'RowanMethodServiceTest new stepPoint1Source'.
	classService := self projectsPresenter selectedClass.
	classService
		command: #saveMethodSource:category:;
		commandArgs: (Array with: sourceString with: 'test step points').
	self issueCommand: classService.
	methodService := (self selectMethodNamed: #simpleMethod) first.
	self assert: methodService stepPoints size equals: 4.
	self assert: (methodService source copyFrom: 42 to: 44) asSymbol
		equals: (methodService stepPoints at: 1) value.	"#new"
	self assert: (methodService stepPoints at: 1) key equals: (42 to: 44).
	self assert: (methodService source copyFrom: 89 to: 91) asSymbol
		equals: (methodService stepPoints at: 2) value.	"#new"
	self assert: (methodService stepPoints at: 2) key equals: (89 to: 91).
	self assert: (methodService source copyFrom: 66 to: 69) asSymbol
		equals: (methodService stepPoints at: 3) value.	"#add:"
	self assert: (methodService stepPoints at: 3) key equals: (66 to: 69).
	self assert: (methodService source copyFrom: 121 to: 124) asSymbol
		equals: (methodService stepPoints at: 4) value.	"#size"
	self assert: (methodService stepPoints at: 4) key equals: (121 to: 124)!

test_zzzstepPoint2
	"see corresponding server test. Character ranges should be the same."

	"test broken"

	| sourceString classService methodService |
	self selectRowanSample1Class.
	sourceString := session executeString: 'RowanMethodServiceTest new stepPoint2Source'.
	classService := self projectsPresenter selectedClass.
	classService
		command: #saveMethodSource:category:;
		commandArgs: (Array with: sourceString with: 'test step points').
	self issueCommand: classService.
	methodService := (self selectMethodNamed: #simpleMethod2) first.
	self assert: methodService stepPoints size equals: 7.
	self assert: (methodService source copyFrom: 43 to: 45) asSymbol
		equals: (methodService stepPoints at: 1) value.	"#new"
	self assert: (methodService stepPoints at: 1) key equals: (43 to: 45).
	self assert: (methodService source copyFrom: 91 to: 104) asSymbol
		equals: (methodService stepPoints at: 2) value.	"#forClassNamed:"
	self assert: (methodService stepPoints at: 2) key equals: (91 to: 104).
	self assert: (methodService source copyFrom: 67 to: 70) asSymbol
		equals: (methodService stepPoints at: 3) value.	"#add:"
	self assert: (methodService stepPoints at: 3) key equals: (67 to: 70).
	self assert: (methodService source copyFrom: 145 to: 147) asSymbol
		equals: (methodService stepPoints at: 4) value.	"#do:"
	self assert: (methodService stepPoints at: 4) key equals: (145 to: 147).
	self assert: (methodService source copyFrom: 295 to: 298) asSymbol
		equals: (methodService stepPoints at: 5) value.	"#size"
	self assert: (methodService stepPoints at: 5) key equals: (295 to: 298).
	self assert: (methodService source copyFrom: 225 to: 234) asSymbol
		equals: (methodService stepPoints at: 6) value.	"#stepPoints"
	self assert: (methodService stepPoints at: 6) key equals: (225 to: 234).
	self assert: (methodService source copyFrom: 268 to: 271) asSymbol
		equals: (methodService stepPoints at: 7) value.	"#size"
	self assert: (methodService stepPoints at: 7) key equals: (268 to: 271)!

test_zzzstepPoint3
	"see corresponding server test. Character ranges should be the same."

	"test broken"

	| sourceString classService methodService |
	self selectRowanSample1Class.
	sourceString := session executeString: 'RowanMethodServiceTest new stepPoint3Source'.
	classService := self projectsPresenter selectedClass.
	classService
		command: #saveMethodSource:category:;
		commandArgs: (Array with: sourceString with: 'test step points').
	self issueCommand: classService.
	methodService := (self selectMethodNamed: #initialize:status:) first.
	self assert: methodService stepPoints size equals: 9.
	self assert: (methodService source copyFrom: 109 to: 111) asSymbol
		equals: (methodService stepPoints at: 1) value.
	self assert: (methodService stepPoints at: 1) value equals: #new.
	self assert: (methodService stepPoints at: 1) key equals: (109 to: 111).
	self assert: (methodService source copyFrom: 165 to: 174) asSymbol
		equals: (methodService stepPoints at: 2) value.
	self assert: (methodService stepPoints at: 2) value equals: #stackDepth.
	self assert: (methodService stepPoints at: 2) key equals: (165 to: 174).
	self assert: (methodService source copyFrom: 149 to: 152) asSymbol
		equals: (methodService stepPoints at: 3) value.
	self assert: (methodService stepPoints at: 3) value equals: #new:.
	self assert: (methodService stepPoints at: 3) key equals: (149 to: 152).
	self assert: (methodService source copyFrom: 216 to: 225) asSymbol
		equals: (methodService stepPoints at: 4) value.
	self assert: (methodService stepPoints at: 4) value equals: #stackDepth.
	self assert: (methodService stepPoints at: 4) key equals: (216 to: 225).
	self assert: (methodService source copyFrom: 290 to: 297) asSymbol equals: #process:.
	self assert: (methodService stepPoints at: 5) value equals: #process:level:organizer:.
	self assert: (methodService stepPoints at: 5) key equals: (290 to: 297).
	self assert: (methodService source copyFrom: 260 to: 262) asSymbol equals: #at:.
	self assert: (methodService stepPoints at: 6) value equals: #at:put:.
	self assert: (methodService stepPoints at: 6) key equals: (260 to: 262).

	"7 & 8 are present in 3.2.15 but are incorrect presumably due to optimization. Later server versions may get this fixed"
	self assert: (methodService source copyFrom: 392 to: 396) asSymbol
		equals: (methodService stepPoints at: 9) value.	"#asOop"
	self assert: (methodService stepPoints at: 9) value equals: #asOop.
	self assert: (methodService stepPoints at: 9) key equals: (392 to: 396)!

waitForPresenter: presenter
	[presenter list isEmpty] whileTrue: [(Delay forMilliseconds: 50) wait]! !
!JadeiteProjectBrowserTestCase categoriesFor: #addSampleMethodGoo!dirty project!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #addSampleMethodHoo!dirty project!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #assertAncestry:in:!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #cleanupExistingWindows!public!support! !
!JadeiteProjectBrowserTestCase categoriesFor: #cleanupTextPaneForClose:!public!support! !
!JadeiteProjectBrowserTestCase categoriesFor: #currentTabView!public!views! !
!JadeiteProjectBrowserTestCase categoriesFor: #dirtyProjectForChangeBrowser!dirty project!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #executeStringInOtherSession:!public!support! !
!JadeiteProjectBrowserTestCase categoriesFor: #family:ofNodesIn:!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #issue170methodCreation!issue test support!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #issue261createTestProject!issue test support!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #issue284methodCreation!issue test support!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #loadProjectNamed:!private!project support! !
!JadeiteProjectBrowserTestCase categoriesFor: #loginOtherSession!public!support! !
!JadeiteProjectBrowserTestCase categoriesFor: #logoutOtherSession!public!support! !
!JadeiteProjectBrowserTestCase categoriesFor: #modifySampleMethodFoo!dirty project!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #nextTabView!public!views! !
!JadeiteProjectBrowserTestCase categoriesFor: #packageNamed:!private!project support! !
!JadeiteProjectBrowserTestCase categoriesFor: #previousTabView!public!views! !
!JadeiteProjectBrowserTestCase categoriesFor: #projectList!private!project support! !
!JadeiteProjectBrowserTestCase categoriesFor: #projectNamed:!private!project support! !
!JadeiteProjectBrowserTestCase categoriesFor: #rowanProjectNames!constants!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #saveHooMethod!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #saveMethodWithUnimplementedSelector!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #saveMethodWithUniqueString!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #saveTestClass!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #selectCommentTab!private!selection! !
!JadeiteProjectBrowserTestCase categoriesFor: #selectSUnitTab!private!selection! !
!JadeiteProjectBrowserTestCase categoriesFor: #selectVariableListEntryForcingEvent:!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_abortOnVariablesTab!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_abstractTestsShown!public!test sunit tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_acceptDefinedMethodInExtensionClass!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_addAccessors!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_addAccessorsClassTab!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_addAccessorsHierarchyTab!public!test class hierarchy!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_addAccessorsHierarchyTabVerifySource!public!test class hierarchy!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_addAccessorsVariablesStaySelected!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_addAccessorsVerifySource!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_addDuplicatePackage!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_addInstVarVariablesStaySorted!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_addInstVarWithVariablesTabOpen!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_addPackageReloadProject!public!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_addRemoveCategory!public!test categories!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_addRemoveHierarchyCategory!public!test class hierarchy!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_addSubclass!public!test class hierarchy!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_adHocInspectComplexObjectInProjectBrowser!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_adHocInspectComplexObjectInProjectBrowser2!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_allClassesAutoCommitOn!public!test class list!test find!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_autoCommit!public!test auto commit!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_autoCommitButtonFailureResetOnAbort!public!test auto commit!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_autoCommitClickButtonAfterFailure!public!test auto commit!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_autoCommitFailure!public!test auto commit!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_autoDirtyDisplayMoveMethodsToCategory!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_autoDirtyDisplayRemoveMethod!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_blankCategoryRenameInvalid!public!test categories!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_browseClass!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_browseHierarchyImplementorsEnablement!public!test menus!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_browseHierarchySendersEnablement!public!test menus!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_browseImplementorsEnablement!public!test menus!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_browseLiteralReferences!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_browseSameClassCategoriesCorrect!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_browseSelectedMethods!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_browseSendersEnablement!public!test menus!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_cannotSelectMultipleProjects!public!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_categoryTextDisplay!public!test categories!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_changeClassComment!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_changeListSortOrder!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_changeVariableWithModifiedMethodSource!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_classColoring!public!test class hierarchy!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_classColoringExtension!public!test class hierarchy!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_classDefinitionTemplateAfterRemove!public!test class list!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_classDefinitionTemplateAfterRemoveInHierarchy!public!test class hierarchy!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_classDefinitionUpdatesAcrossTabs!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_classDeselection!public!test class list!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_classHierarchyDeselection!public!test class hierarchy!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_classListNotBlank!public!test class list!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_classListSelectionShouldNotUpdateOtherHierarchy!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_classRenameNoReferences!public!test rename class!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_classRenameNoReferencesHierarchy!public!test rename class!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_classRenameResetsClassDefinition!public!test rename class!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_classRenameWithReferences!public!test rename class!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_classRenameWithReferencesFailingCompile!public!test rename class!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_classRenameWithReferencesHierarchy!public!test rename class!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_classRenameWithReferencesSimilarNameButNoFailCompile!public!test rename class!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_classSideSelection!public!test class hierarchy!test class list!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_classTemplateWhenNoPackagesSelected!public!test class list!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_classVersionIncrementedInClassList!public!test class list!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_classVersionIncrementedInHierarchy!public!test class hierarchy!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_closeConsoleInvalidSession!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_closeConsoleValidSession!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_comparisonTabMultimethod!public!test comparison tab! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_comparisonTabNoMethodSelected!public!test comparison tab! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_comparisonTabSuperclass!public!test comparison tab! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_compileClass!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_compileClassCompilerError!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_confirmOverrideExistingAccessorMethods!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_definedClassMenuItem!public!test defined package!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_deselectAllVariables!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_dontChangeTabOnMethodSave!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_dontOverrideExistingAccessorMethods!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_dontUpdateWithDifferentMeta!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_doubleClickIncludesColon!public!test source! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_dragClassDoesNotWalkback!public!test drag drop!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_dragClassInHierarchyDoesNotWalkback!public!test class hierarchy!test drag drop!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_dragDropMethodFailCompile!public!test class hierarchy!test drag drop!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_dragDropMultipleMethods!public!test class hierarchy!test drag drop!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_dragDropMultipleMethodsHierarchy!public!test class hierarchy!test drag drop!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_dropMethodOnClassHierarchy!public!test class hierarchy!test drag drop!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_dropMethodOnClassList!public!test class list!test drag drop!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_dropNonSelectedMethod!public!test class list!test drag drop!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_exitJadeiteInvalidSession!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_exitJadeiteValidSession!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_expansion!public!test class hierarchy!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_extensionColoringInHierarchy!public!test class hierarchy!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_extensionMethodSelection!public!test class list!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_failMethodCompile!public!test class list!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_filtersUpdatedInHierarchyView!public!test class hierarchy!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_findClass!public!test class list!test find!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_findDialogBasic!public!test find! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_findMethodChangesCategories!public!test categories!test find!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_findMethodDisabled!public!test find!test menus!test sunit tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_findMethodDoesNotChangeCategories!public!test categories!test find!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_findMethodDoesNothingWhenClassNotSelected!public!test find!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_findMethodShowsAllMethods!public!test find!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_findMethodShowsOnlyOneSide!public!test find!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_findMethodSUnitBrowser!public!test find!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_findUsedEverywhere!public!test find! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_getClassCommentWithDeprecationsOn!public!test class list!test deprecated!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_gitBranchesDoesNotShowHead!public!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_goToDefinedClassFromClassList!public!test defined package!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_goToDefinedClassFromHierarchy!public!test class hierarchy!test defined package!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_goToDefinedMethodFromClassList!public!test class list!test defined package!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_goToDefinedMethodFromClassListClassSide!public!test defined package!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_goToDefinedMethodFromHierarchy!public!test class hierarchy!test defined package!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_gotoDefinedMethodNotSameAsClass!public!test defined package!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_gotoDefinedPackage!public!test defined package!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_hierarchyCleanedUpAfterUnload!public!test class hierarchy!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_hierarchyFindsAllSubclassImplementors!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_hierarchyImplementors!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_hierarchyImplementorsFromMethodList!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_hierarchyImplementorsSendersCaption!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_hierarchyMethodsNotDisplayed!public!test class hierarchy!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_hierarchySelectTwoBrowsers!public!test class hierarchy!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_hierarchySenders!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_hierarchySendersFromMethodList!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_hierarchyWithNonResolvableClass!public!test class hierarchy!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_implementorsSendersCaption!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_issue261!public!test menus!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_loadProjectRemovingClass!public!test projects! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_makeDefault!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_maximizeCode!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_menuAddPackageOnProjectMenu!public!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_menuEnablementDoesNotBreak!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_menusDontAddBreaks!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_methodsContaining!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_methodsContainingCaption!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_methodTabSelected!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_modifiedSourceShouldNotChange!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_modifiedSourceShouldNotChangeMethodList!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_multipleCompileMethod!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_multiplePackageSelection!public!test packages!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_newBrowserRetainsClassAndMethod!public!test class hierarchy!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_newBrowserRetainsClassAndMethodClassSide!public!test class hierarchy!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_noSelectionHierarchy!public!test class hierarchy!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_openChangesBrowser!public!test menus!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_openNewBrowserTabWhileSUnitTabSelected!public!test sunit tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_openNewProjectBrowser!public!test menus!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_openNewProjectTab!public!test menus!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_openProjectsBrowser!public!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_openProjectsBrowserFromMethodList!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_packagesShownInMultipleProjects!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_projectDisplaysSync!public!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_projectInfoTab!public!test menus!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_projectMenuGitCommitMenuItem!public!test menus! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_projectRemoved!public!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_reformatSource!public!test source! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_reformatSourceAppliesOnlyToCurrentBrowser!public!test source! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_refreshAfterAbortMethodList!public!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_refreshAfterAbortMethodListLeaveCommitted!public!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_refreshAfterReloadInProjectsBrowserWithAddedMethod!public!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_refreshAfterReloadWithAddedMethod!public!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_refreshFromServer!public!test class hierarchy!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_registeredPresentersInMethodBrowserCleanedUp!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_registeredPresentersInProjectBrowserCleanedUp!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_removeAbortedClass!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_removeClassFromHierarchy!public!test class hierarchy!test class list!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_removeClassFromList!public!test class hierarchy!test class list!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_removeInstVarVariablesStaySorted!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_removeProject!public!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_renameCategory!public!test categories!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_renameClassMethodListUpdates!public!test rename class! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_renameClassShowsAsDefiniedInPackage!public!test rename class! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_renameClassSUnitBrowserUpdates!public!test rename class! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_renameClassSwitchToHierarchyOk!public!test rename class! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_renameClassUpdatedInSecondBrowser!public!test rename class! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_renameClassUpdatedInSecondBrowserHierarchy!public!test rename class! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_renameDisabledWithMultipleCategoriesSelected!public!test categories!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_renameInClassListWithMethodListOpen!public!test class list!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_renameInHierarchyWithMethodListOpen!public!test class hierarchy!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_rowanTestsHierarchy!public!test class hierarchy!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_saveClassCommentInClassList!public!test class list!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_saveClassCommentInHierarchy!public!test class hierarchy!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_saveClassMethod!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_saveClassMethodHierarchy!public!test class hierarchy!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_saveMethod!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_saveMethodAndUpdateSUnitTab!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_saveMethodHierarchy!public!test class hierarchy!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_selectionsRetainedFromClassListToHierarchy!public!test class list!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_selectionsRetainedFromHierarchyToClassList!public!test class list!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_selectMultiplePackages!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_selectVariable!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_separationOfClassAndInstance!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_setAndClearBreakpoint!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_showMethodsFailingClassRecompilation!public!test class list! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_simpleHierarchyTest!public!test class hierarchy!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_sunitBarEnabledOnEntry!public!test sunit tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_sunitBarEnabledOnReEntry!public!test sunit tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_sunitBrowserForTestClass!public!test menus!test sunit tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_sunitBrowserIsEnabledForTestClass!public!test menus!test sunit tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_sunitBrowserNoSelectedTest!public!test menus!test sunit tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_sunitCtrlB!public!test sunit tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_sunitInheritedTests!public!test sunit tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_sunitOnlyRunTestMethods!public!test sunit tab! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_sunitRunAndMeasureTime!public!test sunit tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_sunitRunSelected!public!test sunit tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_sunitTabCanRefresh!public!test menus!test sunit tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_sUnitTabHandlesShortSelector!public!test class hierarchy!test sunit tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_sUnitTabRefresh!public!test menus!test sunit tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_sunitUpdatesProperly!public!test sunit tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_switchToVariableWithUnsavedChanges!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_symbolsWithoutImplementorsFound!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_tabNames!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_tabNames_projectsBrowser!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_tabNames_projectsBrowserNotLost!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_twoBrowsersAddedClassAppears!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_twoBrowsersAddedClassAppearsInHierarchy1!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_twoBrowsersAddedClassAppearsInHierarchy2!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_twoBrowsersAddedClassDoesNotAppearInDifferentHierarchy!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_twoBrowsersAddedClassRearrangesItselfInHierarchy!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_twoBrowsersAddSameCategoryToClassAndInstance!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_twoBrowsersDontClearMethodList!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_twoBrowsersNoUpdateWithoutPackageSelection!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_twoBrowsersRemoveMethod!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_twoBrowsersUpdate!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_twoBrowsersUpdateClassHierarchyDifferentDictionarySelected!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_twoBrowsersUpdateClassHierarchyDifferentPackageSelected!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_twoBrowsersUpdateClassHierarchyNoDictionarySelected!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_twoBrowsersUpdateClassHierarchyNoPackageSelected!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_twoBrowsersUpdateClassHierarchyNoProjectSelected!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_twoBrowsersUpdateHierarchy!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_twoTabsHaveIndependentCompileErrors!public!test two browsers! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_unicodeDisplayMethod!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_unicodeSpecialMethodNotRed!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_UnsavedChangesActionChangeSelectionIgnoreChanges!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_UnsavedChangesActionChangeSelectionStayOnMethod!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_UnsavedChangesActionCloseWindow!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_UnsavedChangesActionCloseWindowStayOnMethod!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_updateHierarchyAfterClassRecompile!public!test class hierarchy!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_variablesTab!public!test class list!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_variablesUpdatedOnClassSaveInClassList!public!test class list!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_variablesUpdatedOnClassSaveInHierarchy!public!test class list!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_verifyValidCategory!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_zzznoStepPoints!public!test step points!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_zzzstepPoint1!public!test step points!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_zzzstepPoint2!public!test step points!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_zzzstepPoint3!public!test step points!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #waitForPresenter:!private!selection! !

