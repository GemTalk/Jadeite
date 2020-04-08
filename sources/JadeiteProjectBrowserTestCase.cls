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

assertVariableTabSorted
	^self assert: self projectsPresenter variableListPresenter list asOrderedCollection
		equals: self projectsPresenter variableListPresenter list asSortedCollection asOrderedCollection!

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

issue261createTestProject
	"Private - support method for issue 261"

	self testsIssue: #issue261 withTitle: 'Project tab should display reason for project font styling'.
	session
		executeString: '| proj pkg cls meth |
proj := RwProjectDefinition newForGitBasedProjectNamed: ''Izmir''.
proj repositoryRootPath: ''$ROWAN_PROJECTS_HOME/Izmir''.
Rowan projectTools create createProjectFor: proj.'.
	self auditAll.
	self projectsPresenter refreshFromServer!

issue284methodCreation
	self methodSourcePresenter value: 'addedMethod  ^5'.
	self projectsPresenter editSaveMethod: self classListPresenter selection!

loadProjectNamed: projectName
	| projectService |
	projectService := RowanProjectService new name: projectName.
	RowanBrowserService new reloadProjects: (Array with: projectService) presenter: self projectsPresenter!

loginOtherSession
	(Delay forSeconds: 1) wait.	"not sure if this is necessary"
	session
		executeString: 'UserGlobals at: #otherSession put: (GsExternalSession gemNRS: ''' , session gemNRS
				, ''' stoneNRS: ''' , session stoneName
				, ''' username: ''SystemUser'' password: ''swordfish'') login'!

logoutOtherSession
	^session executeString: '
				(UserGlobals at: #otherSession) logout.'!

logoutOtherSystemUsersSessions
	^session
		executeString: '
				| profiles |
				profiles := System _currentSessionProfiles.
				1 to: profiles size by: 2 do:[:index | 
					| sessionNumber profile |
					sessionNumber := profiles at: index. 
					profile := profiles at: index + 1. 
					(GsCurrentSession currentSession userProfile ~~ profile 
						and:[profile userId = ''SystemUser'']) ifTrue:[System stopSession: sessionNumber]]'!

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

saveTestClass
	self saveTestClassWithInstVars: Array new package: 'Rowan-Services-Tests'!

selectCommentTab
	self projectsPresenter classCommentPresenter ensureVisible!

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

test_additionalAccelerators
	"No way yet to adequately test accelerators function
	but we can assert that we tell Dolphin to set them up"

	self testsIssue: #issue329 withTitle: 'Need accelerator key tests'.
	self assert: self projectsPresenter additionalAccelerators first first equals: #insertIfFalse.
	self assert: self projectsPresenter additionalAccelerators second first equals: #insertIfTrue.
	self assert: self projectsPresenter additionalAccelerators last first equals: #raiseConsole.
	self assert: self projectsPresenter additionalAccelerators first last equals: 'Ctrl+Shift+D'.
	self assert: self projectsPresenter additionalAccelerators second last equals: 'Ctrl+Shift+T'.
	self assert: self projectsPresenter additionalAccelerators last last equals: 'Ctrl+F7'.
	self assert: self projectsPresenter additionalAccelerators size equals: 3	"should fail if we add a new one"!

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

test_adHocContextClassSide
	| classService |
	self testsIssue: #issue517 withTitle: 'Context of non-debugger source panes should be the class'.
	self selectRowanSample1Test.
	self selectClassTab.
	classService := RowanClassService named: 'RowanSample1Test'.
	classService meta: true.
	classService
		saveMethod: 'fnoodle  ^#fnoodle'
		category: 'deleteMe'
		session: session.
	self selectMethodNamed: #fnoodle.
	self assert: self methodListPresenter selection selector equals: #fnoodle.
	self methodSourcePresenter value: 'self fnoodle'.
	self methodSourcePresenter setFocus.
	
	[self methodSourcePresenter view selectAll.
	self projectsPresenter jadeDisplay.
	self assert: self methodSourcePresenter value equals: 'self fnoodle #''fnoodle''']
			ensure: 
				[self assert: self methodListPresenter selection selector equals: #fnoodle.
				self methodSourcePresenter view isModified: false.
				self projectsPresenter basicRemoveMethods]!

test_adHocContextInstanceSide
	self testsIssue: #issue517 withTitle: 'Context of non-debugger source panes should be the class'.
	self selectRowanSample1Test.
	self
		saveMethod: 'fnoodle  ^#fnoodle'
		in: 'RowanSample1Test'
		category: 'deleteMe'.
	self selectMethodNamed: #fnoodle.
	self assert: self methodListPresenter selection selector equals: #fnoodle.
	self methodSourcePresenter value: 'self new fnoodle'.
	self methodSourcePresenter setFocus.
	
	[self methodSourcePresenter view selectAll.
	self projectsPresenter jadeDisplay.
	self assert: self methodSourcePresenter value equals: 'self new fnoodle #''fnoodle''']
			ensure: 
				[self assert: self methodListPresenter selection selector equals: #fnoodle.
				self methodSourcePresenter view isModified: false.
				self projectsPresenter basicRemoveMethods]!

test_adHocInspectComplexObjectInProjectBrowser
	| inspector |
	self testsIssue: #issue464 withTitle: '(3.0.67) String does not understand #format: ... during doit'.
	self methodSourcePresenter value: 'RowanSample1Test new setTestSelector: #test1'.
	self methodSourcePresenter setFocus.
	
	[inspector := self projectsPresenter jadeInspect.
	self assert: (inspector model oop isKindOf: Integer).	"the oop"
	self assert: inspector instVarListPresenter selections first key equals: 'self'.
	self assert: inspector instVarListPresenter selections first value
		equals: 'RowanSample1Test>>#test1'.
	inspector instVarListPresenter selectionByIndex: #(2).
	self assert: inspector instVarListPresenter selections first key equals: '-.asOop'.
	self assert: inspector instVarListPresenter selections first value
		equals: inspector model oop printString.
	inspector instVarListPresenter selectionByIndex: #(3).
	self assert: inspector instVarListPresenter selections first key equals: '-testSelector'.
	self assert: (inspector instVarListPresenter selections first value isKindOf: Integer)]
			ensure: 
				[inspector view close.
				self methodSourcePresenter value: String new.
				self methodSourcePresenter view isModified: false]!

test_adHocInspectComplexObjectInProjectBrowser2
	| inspector |
	self testsIssue: #issue464 withTitle: '(3.0.67) String does not understand #format: ... during doit'.
	self methodSourcePresenter value: 'ClassOrganizer new'.
	self methodSourcePresenter setFocus.
	
	[inspector := self projectsPresenter jadeInspect.
	self assert: (inspector model oop isKindOf: Integer).	"the oop"
	self assert: inspector instVarListPresenter selections first key equals: 'self'.
	self assert: inspector instVarListPresenter selections first value equals: 'aClassOrganizer'.
	inspector instVarListPresenter selectionByIndex: #(2).
	self assert: inspector instVarListPresenter selections first key equals: '-.asOop'.
	self assert: inspector instVarListPresenter selections first value
		equals: inspector model oop printString.
	inspector instVarListPresenter selectionByIndex: #(3).
	self assert: inspector instVarListPresenter selections first key equals: '-classes'.
	self assert: (inspector instVarListPresenter selections first value isKindOf: Integer).
	self assert: ('aClassSet(*' match: inspector documentPresenter value).
	inspector instVarListPresenter selectionByIndex: #(4).
	self assert: inspector instVarListPresenter selections first key equals: '-classNames'.
	self assert: inspector instVarListPresenter selections first value equals: 20.
	self assert: inspector documentPresenter value equals: 'nil'.
	inspector instVarListPresenter selectionByIndex: #(5).
	self assert: inspector instVarListPresenter selections first key equals: '-user'.
	self assert: (inspector instVarListPresenter selections first value isKindOf: Integer).
	self assert: ('aSymbolList( aSymbolDictionary(*' match: inspector documentPresenter value).
	inspector instVarListPresenter selectionByIndex: #(8).
	self assert: inspector instVarListPresenter selections first key equals: '-rootClass'.
	self assert: (inspector instVarListPresenter selections first value isKindOf: Integer).
	self assert: inspector documentPresenter value equals: 'Object']
			ensure: 
				[inspector view close.
				self methodSourcePresenter value: String new.
				self methodSourcePresenter view isModified: false]!

test_allSpacesCategory
	self testsIssue: #issue724 withTitle: 'Add a method category with a name of only spaces, get errors (3.0.93-5)'.
	self selectRowanSample1Class.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[TestPrompter plannedResult: '     '.
	TestMessageBox plannedResult: #ok.
	self projectsPresenter addMethodCategory.
	self assertIsNil: TestMessageBox plannedResult.
	self assert: TestMessageBox lastMessageBox text equals: 'Category name must not be blank'. 
	self assert: TestPrompter lastPrompt equals: 'New method category?'.
	TestPrompter plannedResult: 'grubnik'.
	self projectsPresenter addMethodCategory.
	self assert: self categoryListPresenter selection equals: 'grubnik']
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

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
	self logoutOtherSystemUsersSessions.
	self assert: (projectsBrowser view viewNamed: 'autoCommitButton') backcolor equals: Color default.
	session executeString: 'UserGlobals at: #autoCommitTest put: (#key -> #value)'.
	self commitTransaction.
	self loginOtherSession.
	
	[self selectRowanSample1Test.
	self selectMethodNamed: #test1.	"must select method prior to setting up commit failure"
	RowanAnsweringService new setAutoCommit: true for: session.
	self
		executeStringInOtherSession: 'abort;
			executeString: ''(UserGlobals at: #autoCommitTest) value: #newValue'';
			commit'.
	session executeString: '(UserGlobals at: #autoCommitTest) value: #stillAnotherNewValue'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[TestMessageBox plannedResult: #no.	"don't abort so we can test that the autoCommitButton is red"
	self
		saveMethod: 'test1 ^123'
		in: 'RowanSample1Test'
		category: 'tests'.
	self assert: (projectsBrowser view viewNamed: 'autoCommitButton') backcolor equals: Color red.
	self assert: self projectsPresenter autoCommit equals: #failed]
			ensure: 
				[TestMessageBox disableJadeiteTestMessageBox.
				JadeiteInspector allInstances do: 
						[:inspector |
						('Transaction Conflicts*' match: inspector view caption)
							ifTrue: [inspector view close	"transaction conflics inspector opens because we pressed 'no' earlier"]]].
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
	
	[self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	RowanAnsweringService new setAutoCommit: true for: session.
	self
		executeStringInOtherSession: 'abort;
			executeString: ''(UserGlobals at: #autoCommitTest) value: #newValue'';
			commit'.
	session executeString: '(UserGlobals at: #autoCommitTest) value: #stillAnotherNewValue'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[TestMessageBox plannedResult: #no.	"don't abort so we can test that the autoCommitButton is red"
	self
		saveMethod: 'test1 ^123'
		in: 'RowanSample1Test'
		category: 'tests'.
	self assert: (projectsBrowser view viewNamed: 'autoCommitButton') backcolor equals: Color red.
	self assert: self projectsPresenter autoCommit equals: #failed]
			ensure: 
				[TestMessageBox disableJadeiteTestMessageBox.
				JadeiteInspector allInstances do: 
						[:inspector |
						('Transaction Conflicts*' match: inspector view caption)
							ifTrue: [inspector view close	"transaction conflics inspector opens because we pressed 'no' earlier"]]].
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
	| transactionConflictInspector |
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
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #no.	"will raise an inspector on System>transactionConflicts"
	[RowanAnsweringService new exec: '3+4' in: session	"forces a round trip & auto commit failure"]
		ensure: [TestMessageBox disableJadeiteTestMessageBox].
	
	[(transactionConflictInspector := JadeiteInspector allInstances
				detect: [:inspector | 'Transaction Conflicts*' match: inspector view caption]
				ifNone: []) isNil]
			whileTrue: [(Delay forMilliseconds: 2) wait].
	
	[self denyIsNil: (transactionConflictInspector instVarListPresenter list
				detect: [:assoc | assoc key equals: '#''Write-Write''']
				ifNone: [])]
			ensure: [transactionConflictInspector view close].
	self assert: (projectsBrowser view viewNamed: 'autoCommitButton') backcolor equals: Color red.
	self assert: self projectsPresenter autoCommit equals: #failed]
			ensure: 
				[self logoutOtherSession.
				self abortTransaction.
				session executeString: 'UserGlobals removeKey: #autoCommitTest'.
				RowanAnsweringService new setAutoCommit: false for: session.
				self commitTransaction]!

test_autoCommitFailureAndAbort
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
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #yes.	"will do an abort"
	[RowanAnsweringService new exec: '3+4' in: session	"forces a round trip & auto commit failure"]
		ensure: [TestMessageBox disableJadeiteTestMessageBox].
	self assert: (session executeString: '(UserGlobals at: #autoCommitTest) value') equals: #newValue. "abort should have restored value" 
	self assert: (projectsBrowser view viewNamed: 'autoCommitButton') backcolor equals: Color green. "abort should restore auto commit's state from #failed"
	self assert: self projectsPresenter autoCommit equals: true]
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

test_browseCategoryMethodsMenuEnablement
	| commandQuery source |
	self testsIssue: #issue693
		withTitle: 'Would like to be able to open method browser on all methods in selected categories'.
	self selectRowanSample1Test.
	source := 'flub1
| array |
array := Array new. 
array add: ''blerf''.
array add: ''blerf''. 
array add: ''blerf''. 
^array'.
	self projectsPresenter selectMethodSourceTab.
	self projectsPresenter methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self projectsPresenter categoryListPresenter selections: #().
	commandQuery := self
				queryCommand: #browseSelectedCategoryMethods
				inPresenter: self projectsPresenter
				view: self categoryListPresenter view.
	self deny: commandQuery isEnabled.
	self projectsPresenter categoryListPresenter selection: 'other'.
	commandQuery := self
				queryCommand: #browseSelectedCategoryMethods
				inPresenter: self projectsPresenter
				view: self categoryListPresenter view.
	self assert: commandQuery isEnabled.
	self projectsPresenter categoryListPresenter selections: #('tests' 'other').
	commandQuery := self
				queryCommand: #browseSelectedCategoryMethods
				inPresenter: self projectsPresenter
				view: self categoryListPresenter view.
	self assert: commandQuery isEnabled.
	self assert: self methodListPresenter selections size equals: 1.
	self assert: self methodListPresenter selections first selector equals: #flub1.
	self projectsPresenter removeMethods: self classListPresenter selections.
	self assert: self methodListPresenter selections size equals: 0.
	self assertIsNil: (self methodListPresenter list
				detect: [:methodService | methodService selector = #flub1]
				ifNone: [])!

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

test_checkoutTagRefresh
	| projectService |
	self testsIssue: #issue425
		withTitle: 'Jadeite should be able to check out a git tag not just branch'.
	projectService := self projectListPresenter list detect: [:service | service name = 'Rowan'].
	self projectsPresenter basicCheckoutTagAndRefresh: 'Oscar-3.0.93' for: projectService.
	self assert: projectService branch equals: '(HEAD detached at Oscar-3.0.93)'.
	self assert: projectService isSkew.
	#('Cypress' 'STON' 'Tonel') do: 
			[:projectName |
			| dependentService |
			dependentService := transcript projectListPresenter projectListPresenter list
						detect: [:service | service name = projectName].	"the transcript will display the tag. Make sure it's updated"
			self assert: dependentService branch equals: '(HEAD detached at Oscar-3.0.93)'.
			self assert: dependentService isSkew].
	projectService basicCheckout: 'oscar' using: self projectsPresenter.
	self assert: projectService branch equals: 'oscar'.
	self deny: projectService isSkew.
	#('Cypress' 'STON' 'Tonel') do: 
			[:projectName |
			| dependentService |
			dependentService := transcript projectListPresenter projectListPresenter list
						detect: [:service | service name = projectName].	"the transcript will display the branch. Make sure it's updated"
			self assert: dependentService branch equals: 'oscar'.
			self deny: dependentService isSkew]!

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
				self loginWithRetry: JadeiteLoginShell allInstances first.
				self resources do: 
						[:resource |
						resource current
							tearDown;
							setUp]]!

test_closeConsoleValidSession
	| sunitPresenter workspace dictionaryBrowser hierarchyListBrowser simpleInspector complexInspector methodHistoryBrowser |
	"Exit Jadeite. Make sure all Jadeite windows close"
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
	methodHistoryBrowser := JadeiteMethodHistoryBrowser
				showOnClass: self projectsPresenter selectedClass
				selector: self methodListPresenter selections first.
	self assert: sunitPresenter isOpen.
	self assert: projectsBrowser isOpen.
	self assert: methodListBrowser isOpen.
	self assert: hierarchyListBrowser isOpen.
	self assert: dictionaryBrowser isOpen.
	self assert: simpleInspector isOpen.
	self assert: complexInspector isOpen.
	self assert: methodHistoryBrowser isOpen.
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
	self deny: methodHistoryBrowser isOpen]
			ensure: 
				[projectsBrowser := nil.
				GciSession current: nil.
				self loginWithRetry: JadeiteLoginShell allInstances first.
				self resources do: 
						[:resource |
						resource current
							tearDown;
							setUp]]!

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

test_copyClassEnablement
	| commandQuery |
	self selectRowanSample1Test.
	commandQuery := self
				queryCommand: #copyClass
				inPresenter: self projectsPresenter
				view: self classListPresenter view.
	self assert: commandQuery isEnabled.
	self deselectProjects.
	commandQuery := self
				queryCommand: #copyClass
				inPresenter: self projectsPresenter
				view: self classListPresenter view.
	self deny: commandQuery isEnabled!

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

test_dirtyPackages
	self testsIssue: #issue539 withTitle: '(3.077) package not shown as dirty until it is reselected'.
	self selectRowanSample1Test.
	self assert: self projectListPresenter selections first name equals: 'RowanSample1'.
	self deny: self projectListPresenter selections first isDirty.
	self assert: self packageListPresenter selections first name equals: 'RowanSample1-Tests'.
	self deny: self packageListPresenter selections first isDirty.
	self selectMethodNamed: #test1.
	self
		saveMethod: 'test1 self assert: true'
		in: 'RowanSample1Test'
		category: 'tests'.
	self assert: self projectListPresenter selections first name equals: 'RowanSample1'.
	self assert: self projectListPresenter selections first isDirty.
	self assert: self packageListPresenter selections first name equals: 'RowanSample1-Tests'.
	self assert: self packageListPresenter selections first isDirty.
	self selectRowanSample1Class.
	self assert: self packageListPresenter selections first name equals: 'RowanSample1-Core'.
	self deny: self packageListPresenter selections first isDirty.
	self selectMethodNamed: #foo.
	self
		saveMethod: 'foo ^1'
		in: 'RowanSample1'
		category: 'accessing'.
	self assert: self packageListPresenter selections first name equals: 'RowanSample1-Core'.
	self assert: self packageListPresenter selections first isDirty!

test_dirtyProjectOnDisk
	| rowanSample1Project |
	self testsIssue: #issue323 withTitle: 'would like git status supported in Rowan'.
	self selectRowanSample1Test.
	rowanSample1Project := transcript projectListPresenter projectListPresenter list
				detect: [:projectService | projectService name = 'RowanSample1'].
	transcript projectListPresenter projectListPresenter selection: rowanSample1Project.
	self projectListPresenter selection
		performGitCommand: 'reset'
		with: '--hard'
		in: session.
	
	[self assert: self projectListPresenter selection displayName equals: 'RowanSample1'.
	self assert: transcript projectListPresenter projectListPresenter selections first displayName
		equals: 'RowanSample1'.
	self
		saveMethod: 'deleteThisMethod

	self assert: RowanSample1 new foo = ''foo''
	Transcript cr; show: ''fnoodle''. 
	^String new.'
		in: self projectsPresenter selectedClass name
		category: 'deleteMe'.
	self answerYesToDialogDuring: [self projectsPresenter writeProject].
	self assert: self projectListPresenter selection displayName equals: 'RowanSample1*'.
	self assert: transcript projectListPresenter projectListPresenter selections first displayName
		equals: 'RowanSample1*']
			ensure: 
				[self projectsPresenter removeMethodSelector: #deleteThisMethod.
				self projectListPresenter selection
					performGitCommand: 'reset'
					with: '--hard'
					in: session.
				self assert: self projectListPresenter selection displayName equals: 'RowanSample1'.
				self assert: transcript projectListPresenter projectListPresenter selections first displayName
					equals: 'RowanSample1']!

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

test_emptyStringCategory
	self testsIssue: #issue715 withTitle: 'Add category without text gets error'.
	self selectRowanSample1Class.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[TestPrompter plannedResult: String new.
	TestMessageBox plannedResult: #ok.
	self projectsPresenter addMethodCategory.
	self assertIsNil: TestMessageBox plannedResult.
	self assert: TestMessageBox lastMessageBox text equals: 'Category name must not be blank'.
	self assert: TestPrompter lastPrompt equals: 'New method category?'.
	TestPrompter plannedResult: 'grubnik'.
	self projectsPresenter addMethodCategory.
	self assert: self categoryListPresenter selection equals: 'grubnik']
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

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
				self loginWithRetry: JadeiteLoginShell allInstances first.
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
				self loginWithRetry: JadeiteLoginShell allInstances first.
				self resources do: 
						[:resource |
						resource current
							tearDown;
							setUp]]!

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

test_goToDefinedClassFromClassListViaButton
	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Services-Extensions') in: self packageListPresenter.
	self selectServicesNamed: (Array with: 'RwGsPlatform') in: self classListPresenter.
	self assert: self projectsPresenter isClassListTabSelected.
	self assert: self projectsPresenter definedClassPackageText view command
		equals: #gotoClassDefinedPackageViaButton.
	self projectsPresenter gotoClassDefinedPackageViaButton.
	self assert: self classListPresenter selection name = 'RwGsPlatform'.
	self assert: self packageListPresenter selection name = 'Rowan-GemStone-Core'!

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

test_goToDefinedPackageNoClassSelected
	self testsIssue: #issue501 withTitle: 'Make defined package text into a clickable button'.
	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Services-Extensions') in: self packageListPresenter.
	self assertIsNil: (self classListPresenter selectionIfNone: []).
	self projectsPresenter gotoClassDefinedPackage.	"walkback occurred here"
	self assertIsNil: (self classListPresenter selectionIfNone: [])!

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

test_instVarReaders
	"should browse the whole hierarchy"

	| list |
	self selectRowanSample1Class.
	self
		saveClass: 'Foo'
		superclass: 'Object'
		instVars: (Array with: 'fooInstVar')
		package: 'RowanSample1-Core'.
	self selectServiceNamed: 'Foo' in: self classListPresenter.
	self
		saveClass: 'FooSub'
		superclass: 'Foo'
		instVars: Array new
		package: 'RowanSample1-Core'.
	self selectServiceNamed: 'Foo' in: self classListPresenter.
	self
		saveMethod: 'fooInstVar ^fooInstVar'
		in: 'Foo'
		category: 'other'.
	self
		saveMethod: 'fooInstVarSize ^fooInstVar size'
		in: 'Foo'
		category: 'other'.
	self selectServiceNamed: 'FooSub' in: self classListPresenter.
	self
		saveMethod: 'fooInstVarSubSize ^fooInstVar size'
		in: 'FooSub'
		category: 'other'.
	self
		saveMethod: 'doesNotShowUpInList ^1'
		in: 'FooSub'
		category: 'other'.
	self projectsPresenter selectVariableTab.
	self projectsPresenter variableListPresenter selection: 'fooInstVar'.
	methodListBrowser := self projectsPresenter browseInstVarReaders.
	list := methodListBrowser primaryPresenter methodListPresenter methodListPresenter list.
	self assert: list size equals: 3.
	self assert: (list select: [:methodService | methodService className = 'Foo']) size equals: 2.
	self assert: (list select: [:methodService | methodService className = 'FooSub']) size equals: 1.
	self assert: (list collect: [:methodService | methodService selector]) asArray
		equals: #(#fooInstVar #fooInstVarSize #fooInstVarSubSize)!

test_instVarWriters
	"should browse the whole hierarchy"

	| list |
	self selectRowanSample1Class.
	self
		saveClass: 'Foo'
		superclass: 'Object'
		instVars: (Array with: 'fooInstVar')
		package: 'RowanSample1-Core'.
	self selectServiceNamed: 'Foo' in: self classListPresenter.
	self
		saveClass: 'FooSub'
		superclass: 'Foo'
		instVars: Array new
		package: 'RowanSample1-Core'.
	self selectServiceNamed: 'Foo' in: self classListPresenter.
	self
		saveMethod: 'fooInstVar: anObject fooInstVar := anObject'
		in: 'Foo'
		category: 'other'.
	self
		saveMethod: 'fooInstVarSize fooInstVar := fooInstVar size'
		in: 'Foo'
		category: 'other'.
	self selectServiceNamed: 'FooSub' in: self classListPresenter.
	self
		saveMethod: 'fooInstVarSubSize fooInstVar := fooInstVar size'
		in: 'FooSub'
		category: 'other'.
	self
		saveMethod: 'doesNotShowUpInList ^1'
		in: 'FooSub'
		category: 'other'.
	self projectsPresenter selectVariableTab.
	self projectsPresenter variableListPresenter selection: 'fooInstVar'.
	methodListBrowser := self projectsPresenter browseInstVarWriters.
	list := methodListBrowser primaryPresenter methodListPresenter methodListPresenter list.
	self assert: list size equals: 3.
	self assert: (list select: [:methodService | methodService className = 'Foo']) size equals: 2.
	self assert: (list select: [:methodService | methodService className = 'FooSub']) size equals: 1.
	self assert: (list collect: [:methodService | methodService selector]) asArray
		equals: #(#fooInstVar: #fooInstVarSize #fooInstVarSubSize)!

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

test_maximizeCode
	"the arrangement proportions are somewhat arbitrary in appearance.
	Good enough to test that the tabView got doubled in size"

	| tabView |
	self testsIssue: #issue495 withTitle: 'minor error dialogs (3.0.73)'.
	tabView := (self projectsPresenter view viewNamed: 'textAreaTabs') parentView.
	self assert: tabView arrangement equals: 12.
	projectsBrowser maximizeCode.
	self assert: tabView arrangement equals: 24.
	self assert: self projectsPresenter previousTabViewArrangement equals: 12.
	projectsBrowser maximizeCode.	"minimizes tabView"
	self assert: tabView arrangement equals: 12.
	self selectSUnitTab.
	projectsBrowser maximizeCode.
	self assert: tabView arrangement equals: 24.
	self assert: self projectsPresenter previousTabViewArrangement equals: 12.
	projectsBrowser maximizeCode.	"minimizes tabView"
	self assert: tabView arrangement equals: 12!

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

test_openChangesBrowser
	| changesBrowser changesItem |
	self testsIssue: #issue384
		withTitle: '(3.0.53) sort by `type` in changes view does not do complete job'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	changesItem := self projectListPresenter view queryContextMenu items
				detect: [:menuItem | menuItem command == #projectChanges].
	changesBrowser := changesItem commandDescription performAgainst: self projectsPresenter.
	[self assert: (changesBrowser isKindOf: JadeiteChangesBrowser)]
		ensure: [self destroy: changesBrowser]!

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

	self disableInteractionsWhile: 
			[self denyIsNil: (self projectNamed: 'RowanSample1').
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
					ensure: [self loadRowanSample1InProjectList]]!

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
	self auditAll.
	
	[self selectServicesNamed: (Array with: 'RowanSample1') in: self projectListPresenter.	"expect project to disappear but not walkback"
	sampleProject := self projectNamed: 'RowanSample1'.
	self assertIsNil: sampleProject]
			ensure: 
				[self cloneRowanSample1.
				self ensureRowanSample1Loaded]!

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
	secondBrowser := self projectsPresenter newBrowser. 
	secondPresenter := secondBrowser currentCard.
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

test_sunitPresenterResetAfterPackageSelection
	self selectRowanSample1Test.
	self assert: self projectsPresenter sunitPresenter methodListPresenter list size > 0.
	self selectRowanSample1Class.
	self assert: self projectsPresenter sunitPresenter methodListPresenter list size equals: 0.
	self selectRowanSample1Test.
	self assert: self projectsPresenter sunitPresenter methodListPresenter list size > 0!

test_sunitPresenterResetAfterProjectSelection
	self selectRowanSample1Test.
	self assert: self projectsPresenter sunitPresenter methodListPresenter list size > 0.
	self selectServiceNamed: 'STON' in: self projectListPresenter.
	self assert: self projectsPresenter sunitPresenter methodListPresenter list size equals: 0.
	self selectRowanSample1Test.
	self assert: self projectsPresenter sunitPresenter methodListPresenter list size > 0!

test_switchToVariableWithUnsavedChanges
	"no confirmation dialogs raised when switching between category and variable tabs"

	self testsIssue: #issue493
		withTitle: '(oddity) change from category tab to variables tab should not give "method has unsaved changes" prompt'.
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	self methodSourcePresenter view isModified: false.	"in case a test was left hanging around"
	
	[self deny: self methodSourcePresenter view isModified.
	self methodSourcePresenter value: 'test1 ^''aaaa'''.
	self methodSourcePresenter view isModified: true.
	self assert: self methodSourcePresenter view isModified.
	self projectsPresenter selectVariableTab.
	self assert: self methodSourcePresenter view isModified.
	self assert: self methodSourcePresenter value equals: 'test1 ^''aaaa'''.
	self projectsPresenter selectCategoryTab.
	self assert: self methodSourcePresenter view isModified.
	self assert: self methodSourcePresenter value equals: 'test1 ^''aaaa''']
			ensure: [self methodSourcePresenter view isModified: false]!

test_symbolsLowerCaseMatch
	| symbols search |
	self testsIssue: #issue636 withTitle: 'make autocomplete case insensitive'.
	search := JadeiteSearch new.
	symbols := search autocompleteSymbolsFrom: 'FOO'.
	self assert: (symbols includes: #foo).
	symbols := search autocompleteSymbolsFrom: 'FO'.
	self assert: (symbols includes: #foo).
	symbols := search autocompleteSymbolsFrom: 'foo'.
	self assert: (symbols includes: #foo).
	symbols := search autocompleteSymbolsFrom: 'fo'.
	self assert: (symbols includes: #foo)!

test_symbolsWithoutImplementorsFound
	"I think the only way for a symbol to get added to AllSymbols is to commit it"

	| symbols search |
	self testsIssue: #issue258
		withTitle: 'wildcard senders and implentors don''t return proper selection list'.
	search := JadeiteSearch new.
	self selectRowanSample1Class.
	self saveMethodWithUnimplementedSelector.
	self commitTransaction.
	symbols := search autocompleteSymbolsFrom: 'fnoodley1'.
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
	self testsIssue: #issue186 withTitle: 'icon in console menu'.
	self selectRowanSample1Class.
	self saveHooMethod.
	textTabs := self projectsPresenter textTabs.
	self assert: textTabs size equals: 6.
	self assert: (textTabs at: 1) text equals: 'Class Definition'.
	self assert: (textTabs at: 2) text equals: 'Class Documentation'.
	self assert: (textTabs at: 3) text equals: 'Method Source'.
	self assert: (textTabs at: 4) text equals: 'SUnit'.
	self assert: (textTabs at: 5) text equals: 'Comparison'.	"for some as yet unknown reason, this is created differently"
	self assert: (textTabs at: 6) text equals: 'Project'!

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
	self assert: (projectTabs at: index) arrangement text equals: index printString , ' Projects'.
	self selectRowanSample1Class.
	self assert: (projectTabs at: index) arrangement text equals: index printString , ' RowanSample1'. "display class name" 
	self selectCategoryNamed: 'accessing'.
	self assert: (projectTabs at: index) arrangement text equals: index printString , ' RowanSample1'.	"no change. this was a bug"
	self projectsPresenter topShell addSystemBrowser.
	projectTabs := self projectsPresenter parentPresenter view cards.
	index := 2.
	self assert: (projectTabs at: index) arrangement text equals: index printString , ' Projects'.
	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Services-Core') in: self packageListPresenter.
	self selectServicesNamed: (Array with: 'RowanAnsweringService') in: self classListPresenter.
	self assert: (projectTabs at: index) arrangement text equals: index printString , ' RowanAnsweringService'.
	self selectCategoryNamed: 'client commands'.
	self assert: (projectTabs at: index) arrangement text equals: index printString , ' RowanAnsweringService'.	"no change. this was a bug"
	index := 1.
	self assert: (projectTabs at: index) arrangement text equals: index printString , ' RowanSample1'	"not affected by other tab"!

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
	transcript projectListPresenter projectListPresenter selections: #().	"to ensure project list has no selection"
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
	self assert: methodSource view backcolor
		equals: JadeiteTextStyles default colorForUndisplayableSource]
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
		equals: JadeiteTextStyles default colorForUndisplayableSource]
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

test_variableTabSortOrder
	self testsIssue: #issue382 withTitle: 'Add Accessors menu item is disabled'.
	self selectRowanSample1Class.
	self
		saveClass: 'RowanSample2Test'
		superclass: 'RowanSample1Test'
		instVars: #('_var1' 'var2' 'var3')
		package: 'RowanSample1-Tests'.
	
	[self projectsPresenter selectVariableTab.
	self assert: self variableListPresenter list asArray equals: #('_var1' 'testSelector' 'var2' 'var3').
	self selectHierarchyTab.
	self selectClassInHierarchyNamed: 'RowanSample1Test'.
	self selectClassInHierarchyNamed: 'RowanSample2Test'.
	self assert: self variableListPresenter list asArray equals: #('_var1' 'testSelector' 'var2' 'var3').
	self projectsPresenter selectCategoryTab.
	self projectsPresenter selectVariableTab.
	self assert: self variableListPresenter list asArray equals: #('_var1' 'testSelector' 'var2' 'var3')]
			ensure: [self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass]!

test_variableTabSortOrder2
	self testsIssue: #issue575 withTitle: 'variables tab sort order inconsistency'.
	self projectsPresenter updateAfterFindClass: (RowanClassService new name: 'Object').
	self projectsPresenter selectVariableTab.
	projectsBrowser ifNotNil: [self assertVariableTabSorted].
	self projectsPresenter selectCategoryTab.
	projectsBrowser ifNotNil: [self assertVariableTabSorted].
	self projectsPresenter selectVariableTab.
	projectsBrowser ifNotNil: [self assertVariableTabSorted].
	self selectClassTab.
	projectsBrowser ifNotNil: [self assertVariableTabSorted].
	self selectInstanceTab.
	projectsBrowser ifNotNil: [self assertVariableTabSorted].
	self selectHierarchyTab.
	projectsBrowser ifNotNil: [self assertVariableTabSorted].
	self selectClassListTab.
	projectsBrowser ifNotNil: [self assertVariableTabSorted]!

test_verifyValidCategory
	self testsIssue: #issue205 withTitle: 'misspelled extension category name causes trouble'.
	self assert: (self projectsPresenter verifyValidCategory: '*Rowan-Kernel') .
	self assert: (self projectsPresenter verifyValidCategory: '*rowan-kernel') .
	self assert: (self projectsPresenter verifyValidCategory: 'aaa') .
	self deny: (self projectsPresenter verifyValidCategory: '*rowankernel') .
	self deny: (self projectsPresenter verifyValidCategory: '*rowankernelx') .!

waitForPresenter: presenter
	[presenter list isEmpty] whileTrue: [(Delay forMilliseconds: 50) wait]! !
!JadeiteProjectBrowserTestCase categoriesFor: #addSampleMethodGoo!dirty project!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #addSampleMethodHoo!dirty project!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #assertAncestry:in:!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #assertVariableTabSorted!private!support! !
!JadeiteProjectBrowserTestCase categoriesFor: #currentTabView!public!views! !
!JadeiteProjectBrowserTestCase categoriesFor: #dirtyProjectForChangeBrowser!dirty project!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #executeStringInOtherSession:!public!support! !
!JadeiteProjectBrowserTestCase categoriesFor: #family:ofNodesIn:!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #issue261createTestProject!issue test support!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #issue284methodCreation!issue test support!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #loadProjectNamed:!private!project support! !
!JadeiteProjectBrowserTestCase categoriesFor: #loginOtherSession!public!support! !
!JadeiteProjectBrowserTestCase categoriesFor: #logoutOtherSession!public!support! !
!JadeiteProjectBrowserTestCase categoriesFor: #logoutOtherSystemUsersSessions!public!support! !
!JadeiteProjectBrowserTestCase categoriesFor: #modifySampleMethodFoo!dirty project!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #nextTabView!public!views! !
!JadeiteProjectBrowserTestCase categoriesFor: #packageNamed:!private!project support! !
!JadeiteProjectBrowserTestCase categoriesFor: #previousTabView!public!views! !
!JadeiteProjectBrowserTestCase categoriesFor: #projectList!private!project support! !
!JadeiteProjectBrowserTestCase categoriesFor: #projectNamed:!private!project support! !
!JadeiteProjectBrowserTestCase categoriesFor: #rowanProjectNames!constants!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #saveHooMethod!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #saveMethodWithUnimplementedSelector!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #saveTestClass!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #selectCommentTab!private!selection! !
!JadeiteProjectBrowserTestCase categoriesFor: #selectVariableListEntryForcingEvent:!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_abortOnVariablesTab!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_acceptDefinedMethodInExtensionClass!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_addAccessors!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_addAccessorsClassTab!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_addAccessorsVariablesStaySelected!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_addAccessorsVerifySource!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_addDuplicatePackage!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_addInstVarVariablesStaySorted!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_addInstVarWithVariablesTabOpen!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_additionalAccelerators!public!test menus! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_addPackageReloadProject!public!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_addRemoveCategory!public!test categories!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_adHocContextClassSide!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_adHocContextInstanceSide!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_adHocInspectComplexObjectInProjectBrowser!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_adHocInspectComplexObjectInProjectBrowser2!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_allSpacesCategory!public!test categories!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_autoCommit!public!test auto commit!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_autoCommitButtonFailureResetOnAbort!public!test auto commit!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_autoCommitClickButtonAfterFailure!public!test auto commit!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_autoCommitFailure!public!test auto commit!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_autoCommitFailureAndAbort!public!test auto commit!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_autoDirtyDisplayMoveMethodsToCategory!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_autoDirtyDisplayRemoveMethod!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_blankCategoryRenameInvalid!public!test categories!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_browseCategoryMethodsMenuEnablement!public!test categories! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_browseClass!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_browseLiteralReferences!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_browseSameClassCategoriesCorrect!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_browseSelectedMethods!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_cannotSelectMultipleProjects!public!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_categoryTextDisplay!public!test categories!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_changeClassComment!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_changeListSortOrder!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_changeVariableWithModifiedMethodSource!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_checkoutTagRefresh!public!test projects! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_classDefinitionUpdatesAcrossTabs!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_classListSelectionShouldNotUpdateOtherHierarchy!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_closeConsoleInvalidSession!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_closeConsoleValidSession!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_confirmOverrideExistingAccessorMethods!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_copyClassEnablement!public!test menus!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_definedClassMenuItem!public!test defined package!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_deselectAllVariables!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_dirtyPackages!public!test packages! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_dirtyProjectOnDisk!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_dontChangeTabOnMethodSave!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_dontOverrideExistingAccessorMethods!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_dontUpdateWithDifferentMeta!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_dragClassDoesNotWalkback!public!test drag drop!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_emptyStringCategory!public!test categories!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_exitJadeiteInvalidSession!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_exitJadeiteValidSession!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_findDialogBasic!public!test find! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_findMethodChangesCategories!public!test categories!test find!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_findMethodDoesNotChangeCategories!public!test categories!test find!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_findMethodDoesNothingWhenClassNotSelected!public!test find!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_findMethodShowsAllMethods!public!test find!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_findMethodShowsOnlyOneSide!public!test find!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_findMethodSUnitBrowser!public!test find!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_findUsedEverywhere!public!test find! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_gitBranchesDoesNotShowHead!public!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_goToDefinedClassFromClassList!public!test defined package!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_goToDefinedClassFromClassListViaButton!public!test defined package!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_goToDefinedMethodFromClassListClassSide!public!test defined package!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_gotoDefinedMethodNotSameAsClass!public!test defined package!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_gotoDefinedPackage!public!test defined package!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_goToDefinedPackageNoClassSelected!public!test defined package!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_hierarchyFindsAllSubclassImplementors!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_hierarchyImplementors!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_hierarchyImplementorsFromMethodList!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_hierarchyImplementorsSendersCaption!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_hierarchySenders!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_hierarchySendersFromMethodList!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_implementorsSendersCaption!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_instVarReaders!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_instVarWriters!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_issue261!public!test menus!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_loadProjectRemovingClass!public!test projects! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_maximizeCode!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_menuAddPackageOnProjectMenu!public!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_menuEnablementDoesNotBreak!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_menusDontAddBreaks!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_multiplePackageSelection!public!test packages!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_openChangesBrowser!public!test menus!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_openNewProjectBrowser!public!test menus!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_openNewProjectTab!public!test menus!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_openProjectsBrowser!public!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_openProjectsBrowserFromMethodList!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_packagesShownInMultipleProjects!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_projectDisplaysSync!public!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_projectInfoTab!public!test menus!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_projectMenuGitCommitMenuItem!public!test menus! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_projectRemoved!public!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_refreshAfterAbortMethodList!public!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_refreshAfterAbortMethodListLeaveCommitted!public!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_refreshAfterReloadInProjectsBrowserWithAddedMethod!public!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_refreshAfterReloadWithAddedMethod!public!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_registeredPresentersInMethodBrowserCleanedUp!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_registeredPresentersInProjectBrowserCleanedUp!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_removeAbortedClass!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_removeInstVarVariablesStaySorted!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_removeProject!public!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_renameCategory!public!test categories!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_renameDisabledWithMultipleCategoriesSelected!public!test categories!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_selectMultiplePackages!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_selectVariable!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_separationOfClassAndInstance!public!test two browsers!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_setAndClearBreakpoint!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_sunitPresenterResetAfterPackageSelection!public!test packages!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_sunitPresenterResetAfterProjectSelection!public!test projects! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_switchToVariableWithUnsavedChanges!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_symbolsLowerCaseMatch!public!tests! !
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
!JadeiteProjectBrowserTestCase categoriesFor: #test_variableTabSortOrder!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_variableTabSortOrder2!public!test variable tab!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_verifyValidCategory!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #waitForPresenter:!private!selection! !

