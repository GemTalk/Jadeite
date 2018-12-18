"Filed out from Dolphin Smalltalk 7"!

JadeiteAbstractTestCase subclass: #JadeiteProjectBrowserTestCase
	instanceVariableNames: 'transcriptWritesWereEnabled methodListBrowser'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteProjectBrowserTestCase guid: (GUID fromString: '{1d6db475-c257-442b-9f91-d1574b03aee2}')!
JadeiteProjectBrowserTestCase comment: 'General Jadeite tests. Assumes a logged in session and transcript present. 

When running tests from SUnit Browser Tool, make sure to turn on Auto Initialize Resources.'!
!JadeiteProjectBrowserTestCase categoriesForClass!Unclassified! !
!JadeiteProjectBrowserTestCase methodsFor!

cloneRowanSample1
	| sample1Path root |
	sample1Path := self rowanSample1Path.
	root := self rowanProjectsHome.
	projectsBrowser currentCard basicCloneProject: sample1Path root: root.
	self projectsPresenter refreshFromServer.!

commandQueryOn: commandSymbol view: view
	^CommandQuery new commandDescription: (CommandDescription new command: commandSymbol) source: view!

disableTranscriptWrites
	(transcriptWritesWereEnabled := transcript isTranscriptInstalled)
		ifTrue: [transcript flipTranscript]	"turn off gemstone transcript writes for performance"!

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

packageNamed: aString
	^self packageListPresenter list
		detect: [:projectService | projectService name = aString]
		ifNone: []!

projectList
	^self projectListPresenter list!

projectNamed: aString
	^self projectsPresenter projectListPresenter list
		detect: [:projectService | projectService name = aString]
		ifNone: []!

rowanProjectNames
	"this may change"

	^#('Cypress' 'Rowan' 'STON' 'Tonel')!

saveClass: className superclass: superName instVars: instVars package: aString
	self projectsPresenter classDefinitionPresenter
		value: superName, ' rwSubclass: ', className printString, '
	instVarNames: ' , instVars printString
				, '
	classVars: #()
	classInstVars: #()
	poolDictionaries: #()
	category: ', aString printString, '
	options: #()'.
	self projectsPresenter editSaveClass!

saveClass: className withInstVars: instVars package: aString
	self saveClass: className superclass: 'Object' instVars: instVars package: aString!

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

saveSampleMethod

	| source |
	source := 'sampleMethod  
		| aaa | 
		aaa := 123. 
		^aaa'. 
	self methodSourcePresenter value: source. 
	self projectsPresenter editSaveMethod: self classListPresenter selection. 

	!

saveTestClass
	self saveTestClassWithInstVars: Array new package: 'Rowan-Services-Tests'!

saveTestClassWithInstVars: instVars package: aString
	self
		saveClass: 'TestClass'
		withInstVars: instVars
		package: aString!

selectClassInHierarchyNamed: className
	self selectTreeServicesNamed: (Array with: className) in: self classHierarchyPresenter!

selectClassListTab
	^self projectsPresenter classHierarchyTabs firstCard!

selectHierarchyTab
	self selectHierarchyTabIn: self projectsPresenter!

selectHierarchyTabIn: presenter
	presenter classHierarchyTabs lastCard!

selectRowanSample1Test
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Tests' in: self packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: self classListPresenter!

selectSUnitTab
	self projectsPresenter sunitPresenter ensureVisible!

selectTreeServicesNamed: anArray in: presenter
	presenter resetSelection.
	anArray do: 
			[:name |
			| service |
			service := presenter model asBag detect: [:svc | svc name = name]
						ifNone: [self error: 'Tree element ' , name , ' not found'].
			presenter selections: (presenter selections asOrderedCollection
						add: service;
						yourself)]!

setUp
	super setUp.
	self disableTranscriptWrites.	"turn off gemstone transcript writes for performance"
	projectsBrowser := JadeiteTestResource current openProjectsBrowser.
	self selectClassListTab.
	self selectInstanceTab!

tearDown
	super tearDown.
	session isValidSession ifTrue: [transcriptWritesWereEnabled == true ifTrue: [transcript flipTranscript]].
	methodListBrowser
		ifNotNil: 
			[methodListBrowser destroy.
			methodListBrowser := nil]!

test_abstractTestsShown
	| commandQuery methodService |
	self testsIssue: #issue336
		withTitle: 'S-Unit Tests In an abstract class and its subclasses are not managed properly'.

	self loadProjectNamed: 'Tonel'.   "ensure tests are present" 
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
	commandQuery := self commandQueryOn: #runMethodTests view: self methodListPresenter view.
	self projectsPresenter queryCommand: commandQuery.
	self deny: commandQuery isEnabled	"run test menu item disabled in the abstract class"!

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
				list detect: [:methodService | methodService className == #RwClassExtensionDefinition] ifNone: [].
	self denyIsNil: methodInSameClass.
	methodListBrowser primaryPresenter methodListPresenter methodListPresenter
		selection: methodInSameClass.
	newBrowser := methodListBrowser primaryPresenter methodListPresenter browseClass.
	
	[self assert: self methodListPresenter list size equals: 1.	"original browser method list doesn't change"
	self assert: newBrowser currentCard categoryListPresenter list notEmpty.
	self assert: self projectsPresenter categoryListPresenter list notEmpty.
	self assert: newBrowser currentCard categoryListPresenter list
		equals: self projectsPresenter categoryListPresenter list]
			ensure: [newBrowser destroy]!

test_categoryTextDisplay
	self testsIssue: #issue232 withTitle: 'cannot tell which `category` a method is in (Oscar-3.0.41)'.
	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Services-Core') in: self packageListPresenter.
	self selectServicesNamed: (Array with: 'RowanClassService') in: self classListPresenter.
	self assert: self projectsPresenter methodCategoryText value equals: String new.
	self selectCategoryNamed: 'client commands'.
	self assert: self projectsPresenter methodCategoryText value equals: String new.
	self selectMethodNamed: #removeMethods.
	self assert: self projectsPresenter methodCategoryText value equals: 'Category: client commands'.
	self selectMethodsNamed: (Array
				with: #removeMethods
				with: #renameCategoryFrom:to:
				with: #addCategory:).
	self assert: self projectsPresenter methodCategoryText value equals: 'Category: client commands'.	"category is shown if all selected methods are in same category"
	self selectServicesNamed: (Array with: 'RowanService') in: self classListPresenter.
	self assert: self projectsPresenter methodListPresenter list notEmpty.
	self assert: self projectsPresenter methodCategoryText value equals: String new.
	self selectMethodsNamed: (Array with: #browserTool with: #initialize).
	self assert: self projectsPresenter methodCategoryText value equals: 'Categories: (Multiple)'!

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
	self testsIssue: #issue267 withTitle: 'logout closes project browsers but not method list browsers'.
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

test_duplicateInstVars
	self testsIssue: #issue228
		withTitle: 'lose selected class in project browser when new version created'.
	self selectServicesNamed: (Array with: 'RowanSample1') in: self projectListPresenter.
	self selectServicesNamed: #('RowanSample1-Tests') in: self packageListPresenter.
	self saveTestClassWithInstVars: Array new package: 'RowanSample1-Tests'.
	self selectClassTab.
	self selectServiceNamed: 'TestClass' in: self classListPresenter.
	self
		saveClass: 'SubClass'
		superclass: 'TestClass'
		instVars: #('aa')
		package: 'RowanSample1-Tests'.
	self selectServiceNamed: 'SubClass' in: self classListPresenter.
	self
		saveClass: 'TestClass'
		withInstVars: #('aa')
		package: 'RowanSample1-Tests'.
	self assert: ('ERROR: *' match: self projectsPresenter topShell statusBarText).
	self projectsPresenter classDefinitionPresenter view isModified: false!

test_duplicateInstVarsHierarchy
	self testsIssue: #issue228
		withTitle: 'lose selected class in project browser when new version created'.
	self selectServicesNamed: (Array with: 'RowanSample1') in: self projectListPresenter.
	self selectServicesNamed: #('RowanSample1-Tests') in: self packageListPresenter.
	self selectHierarchyTab.
	self saveTestClassWithInstVars: Array new package: 'RowanSample1-Tests'.
	self selectClassInHierarchyNamed: 'TestClass'.
	self
		saveClass: 'SubClass'
		superclass: 'TestClass'
		instVars: #('aa')
		package: 'RowanSample1-Tests'.
	self
		saveClass: 'TestClass'
		withInstVars: #('aa')
		package: 'RowanSample1-Tests'.
	[self assert: ('ERROR: *' match: self projectsPresenter topShell statusBarText)]
		ensure: [self projectsPresenter classDefinitionPresenter view isModified: false]!

test_duplicateInstVarsInHierarchy
	self testsIssue: #issue228
		withTitle: 'lose selected class in project browser when new version created'.
	self selectServicesNamed: (Array with: 'RowanSample1') in: self projectListPresenter.
	self selectServicesNamed: #('RowanSample1-Tests') in: self packageListPresenter.
	self saveTestClassWithInstVars: Array new package: 'RowanSample1-Tests'.
	self selectHierarchyTab. 
	self selectServiceNamed: 'TestClass' in: self classListPresenter.
	self
		saveClass: 'SubClass'
		superclass: 'TestClass'
		instVars: #('aa')
		package: 'RowanSample1-Tests'.
	self selectServiceNamed: 'SubClass' in: self classListPresenter.
	self
		saveClass: 'TestClass'
		withInstVars: #('aa')
		package: 'RowanSample1-Tests'.
	self assert: ('ERROR: *' match: self projectsPresenter topShell statusBarText).
	self projectsPresenter classDefinitionPresenter view isModified: false. !

test_exitJadeiteInvalidSession
	| sunitPresenter workspace dictionaryBrowser hierarchyListBrowser simpleInspector complexInspector |
	"poison session and exit Jadeite. Make sure all Jadeite windows close"
	self testsIssue: #issue267 withTitle: 'logout closes project browsers but not method list browsers'.
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
	
	[transcript exit.
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

test_exitJadeiteValidSession
	| sunitPresenter workspace dictionaryBrowser hierarchyListBrowser simpleInspector complexInspector |
	"poison session and exit Jadeite. Make sure all Jadeite windows close"
	self testsIssue: #issue267 withTitle: 'logout closes project browsers but not method list browsers'.
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
	self deny: self projectsPresenter classHierarchyPresenter selection shouldColorAsExtension.
	self selectClassInHierarchyNamed: 'RwGemStoneSpecification'.
	self assert: self projectsPresenter classHierarchyPresenter selection shouldColorAsExtension!

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
	| dictionaryPresenter |
	self testsIssue: #issue150 withTitle: 'Go to defining package -> Not found: a BlockClosure'.
	"different project within projects browser"
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Tools-Kernel' in: self packageListPresenter.
	self selectServiceNamed: 'CypressDefinition' in: self classListPresenter.
	self projectsPresenter gotoClassDefinedPackage.
	self assert: self projectListPresenter selection name = 'Cypress'.
	self assert: self packageListPresenter selection name = 'Cypress-Definitions'.
	self assert: self classListPresenter selection name = 'CypressDefinition'.

	"go to dictionary browser"
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-GemStone-Kernel' in: self packageListPresenter.
	self selectServiceNamed: 'ByteArray' in: self classListPresenter.
	dictionaryPresenter := self projectsPresenter gotoClassDefinedPackage.
	
	[self assert: dictionaryPresenter dictionaryListPresenter selection key = 'Globals'.
	self assert: dictionaryPresenter classCategoryPresenter selection value = 'Kernel'.
	self assert: dictionaryPresenter classListPresenter selection = 'ByteArray']
			ensure: [dictionaryPresenter topShell destroy]!

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
			ensure: [methodListBrowser destroy].
	methodListBrowser := self projectsPresenter browseImplementors.
	
	[self assert: ('Implementors of ''isEmpty'' for *' match: methodListBrowser caption).
	methodListPresenter := methodListBrowser primaryPresenter methodListPresenter methodListPresenter.
	self assert: methodListPresenter list size > hierarchyListSize	"always a superset"]
			ensure: [methodListBrowser destroy]!

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
				[methodListBrowser destroy.
				hierarchyMethodListPresenter destroy]!

test_hierarchyImplementorsSendersCaption
	self testsIssue: #issue209 withTitle: 'MethodListBrowser needs the token in the title bar'.
	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Services-Core') in: self packageListPresenter.
	self selectServicesNamed: (Array with: 'RowanProjectService') in: self classListPresenter.
	self selectMethodNamed: #branch.
	methodListBrowser := self projectsPresenter browseHierarchyImplementors.
	[self assert: ('Hierarchy Implementors of ''branch'' for *' match: methodListBrowser caption)]
		ensure: [methodListBrowser destroy].
	methodListBrowser := self projectsPresenter browseHierarchySenders.
	[self assert: ('Hierarchy Senders of ''branch'' for *' match: methodListBrowser caption)]
		ensure: [methodListBrowser destroy]!

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
	| secondBrowser firstBrowser |
	self testsIssue: #issue122 withTitle: 'Hierarchy tab selection updates incorrectly.'.
	firstBrowser := projectsBrowser.	"for easier reading"
	secondBrowser := self openWindow: [transcript openJadeiteProjectsBrowser].
	
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
			ensure: [secondBrowser destroy]!

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
			ensure: [methodListBrowser destroy].
	methodListBrowser := self projectsPresenter browseSenders.
	
	[self assert: ('Senders of ''isEmpty'' for *' match: methodListBrowser caption).
	methodListPresenter := methodListBrowser primaryPresenter methodListPresenter methodListPresenter.
	self assert: methodListPresenter list size >= hierarchyListSize	"always a superset"]
			ensure: [methodListBrowser destroy]!

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
				[methodListBrowser destroy.
				hierarchyMethodListBrowser destroy]!

test_implementorsSendersCaption
	self testsIssue: #issue209 withTitle: 'MethodListBrowser needs the token in the title bar'.
	self selectServicesNamed: (Array with: 'Rowan') in: self projectListPresenter.
	self selectServicesNamed: #('Rowan-Services-Core') in: self packageListPresenter.
	self selectServicesNamed: (Array with: 'RowanProjectService') in: self classListPresenter.
	self selectMethodNamed: #branch.
	methodListBrowser := self projectsPresenter browseImplementors.
	[self assert: ('Implementors of ''branch'' for *' match: methodListBrowser caption)]
		ensure: [methodListBrowser destroy].
	methodListBrowser := self projectsPresenter browseSenders.
	[self assert: ('Senders of ''branch'' for *' match: methodListBrowser caption)]
		ensure: [methodListBrowser destroy]!

test_issue261
	"create a loaded project and test the info display"
	| view |
	self testsIssue: #issue261 withTitle: 'Project tab should display reason for project font styling'.
	self issue261createTestProject.
	
	[self selectServiceNamed: 'Izmir' in: self projectListPresenter.
	view := self projectsPresenter projectInfoTab view.
	self assert: (view columns first contentFromRow: (view list at: 1)) equals: 'Izmir'.
	self assert: (view columns first contentFromRow: (view list at: 5)).	"isDirty"]
			ensure: [self projectsPresenter basicUnloadProjects: #('Izmir')]!

test_literalReferences
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
	methodListBrowser := JadePresenter browseLiteralReferences: 'apple' session: session.
	methodListPresenter := methodListBrowser primaryPresenter methodListPresenter methodListPresenter.
	self assert: methodListPresenter list size equals: 1.
	self assert: methodListPresenter selection selector equals: #theAString. 
	methodListPresenter list
		do: [:methodService | self assert: ('*''apple''*' match: methodService source)]!

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
		ensure: [methodListBrowser destroy]!

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
	self assert: grandchildren size = 12. "this will probably change but it's a nice test to ensure all the expected services are present"
	grandchildrensNames := grandchildren collect: [:classService | classService name].
	self assert: (grandchildrensNames at: 1) equals: 'RowanAnsweringService'.
	self assert: (grandchildrensNames at: 2) equals: 'RowanBrowserService'.
	self assert: (grandchildrensNames at: 3) equals: 'RowanClassService'.
	self assert: (grandchildrensNames at: 4) equals: 'RowanDebuggerService'.
	self assert: (grandchildrensNames at: 5) equals: 'RowanFrameService'.
	self assert: (grandchildrensNames at: 6) equals: 'RowanMethodService'.
	self assert: (grandchildrensNames at: 7) equals: 'RowanPackageService'.
	self assert: (grandchildrensNames at: 8) equals: 'RowanProcessService'.
	self assert: (grandchildrensNames at: 9) equals: 'RowanProjectService'.
	self assert: (grandchildrensNames at: 10) equals: 'RowanQueryService'.
	self assert: (grandchildrensNames at: 11) equals: 'RowanTestService'.
	self assert: (grandchildrensNames at: 12) equals: 'RowanVariableService'.

!

test_openNewProjectBrowser
	"make sure that we can open a new project browser from an existing browser"

	| newBrowser menu item |
	self testsIssue: #issue243
		withTitle: '`browse class` menu in method view of project browser leaves method and goes to class'.
	menu := Menu fromStrings: self projectsPresenter jadeMenuStrings.
	self
		denyIsNil: (item := menu items detect: [:menuItem | menuItem command == #newBrowser] ifNone: []).
	newBrowser := item commandDescription performAgainst: self projectsPresenter.
	[self assert: newBrowser isKindOf: JadeiteProjectsSystemBrowser] ensure: [newBrowser exit]!

test_openNewProjectTab
	| menu item firstCard |
	self testsIssue: #issue243
		withTitle: '`browse class` menu in method view of project browser leaves method and goes to class'.
	self assert: self projectsPresenter parentPresenter view cards size equals: 1. 
	menu := Menu fromStrings: self projectsPresenter jadeMenuStrings.
	self
		denyIsNil: (item := menu items detect: [:menuItem | menuItem command == #addSystemBrowser] ifNone: []).
	firstCard := projectsBrowser currentCard.
	item commandDescription performAgainst: projectsBrowser.
	self assert:self projectsPresenter parentPresenter view cards size equals: 2. 
	self deny: projectsBrowser currentCard == firstCard!

test_openProjectsBrowser
	"project browser opened in setup"

	self assert: projectsBrowser class equals: JadeiteProjectsSystemBrowser.
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
	[self assert: (secondProjectsBrowser isKindOf: JadeiteProjectsSystemBrowser)]
		ensure: [secondProjectsBrowser destroy]!

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
	self assert: (self projectsPresenter projectInfoTab view getItemText: 1) equals: 'name'.
	self assert: (self projectsPresenter projectInfoTab view getItemText: 2) equals: 'sha'.
	self assert: (self projectsPresenter projectInfoTab view getItemText: 3) equals: 'branch'.
	self assert: (self projectsPresenter projectInfoTab view getItemText: 4) equals: 'isSkew'.
	self assert: (self projectsPresenter projectInfoTab view getItemText: 5) equals: 'isDirty'.
	self assert: (self projectsPresenter projectInfoTab view getItemText: 6) equals: 'isLoaded'.
	view := self projectsPresenter projectInfoTab view.
	self assert: (view columns first contentFromRow: (view list at: 1)) equals: 'Rowan'. "don't know the state of the rowan project so just test the name"!

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
	self assert: beforeSize > 1.
	self
		assertIsNil: (list detect: [:methodService | methodService className = #RowanService] ifNone: [])]
			ensure: [methodListBrowser destroy].
	self selectServiceNamed: 'RowanService' in: self classListPresenter.
	self methodSourcePresenter value: 'classFromName  "do nothing"'.
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self selectMethodNamed: #classFromName.
	methodListBrowser := self projectsPresenter browseImplementors.
	list := methodListBrowser primaryPresenter methodListPresenter methodListPresenter list.
	afterSize := list size.
	self assert: afterSize equals: beforeSize + 1.
	self
		denyIsNil: (list detect: [:methodService | methodService className = #RowanService] ifNone: []).
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

test_selectMultiplePackages
	self selectServicesNamed: #() in: self projectListPresenter .
	self assert: self packageListPresenter list isEmpty.
	self selectServicesNamed: #('Rowan') in: self projectListPresenter.
	self deny: self packageListPresenter list isEmpty.
	self serviceNamed: 'Rowan-Services-Core' in: self packageListPresenter.
	self serviceNamed: 'Rowan-JadeServer' in: self packageListPresenter.
	self selectServicesNamed: #('Rowan-Services-Core' 'Rowan-JadeServer') in: self packageListPresenter!

test_selectMultipleProjects
	self selectServicesNamed: #() in: self projectListPresenter .
	self assert: self projectListPresenter selections isEmpty.
	self selectServicesNamed: self rowanProjectNames in: self projectListPresenter.
	self assert: self projectListPresenter selections size = 4!

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
			ensure: [secondBrowser destroy]!

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
	self rowanFixMe. "fix the oddity that one tab is created differently" 
	self testsIssue: #issue186 withTitle: 'icon in console menu'.
	self selectRowanSample1Class.
	self saveHooMethod.
	textTabs := self projectsPresenter textTabs.
	self assert: textTabs size equals: 6.
	self assert: (textTabs at: 1) text equals: 'Project'.
	self assert: (textTabs at: 2) text equals: 'Class Definition'.
	self assert: (textTabs at: 3) text equals: 'Class Documentation'.
	self assert: (textTabs at: 4) text equals: 'Method Source'.
	self assert: (textTabs at: 5) text equals: 'SUnit'.
	self assert: (textTabs at: 6)  equals: 'Comparison' "for some as yet unknown reason, this is created differently"!

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
	self selectCategoryNamed: 'commands'.
	self assert: (projectTabs at: index) arrangement equals: index printString , ' Rowan-Services-Core'.	"no change. this was a bug"
	index := 1.
	self assert: (projectTabs at: index) arrangement equals: index printString , ' RowanSample1-Core'	"not affected by other tab"!

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
			[dictionaryBrowser destroy.
			methodListBrowser destroy].
	variableSize := self projectsPresenter variableListPresenter list size.
	self selectHierarchyTab.
	self assert: self projectsPresenter variableListPresenter list size equals: variableSize.
	self assert: self projectsPresenter variableListPresenter selection equals: 'variables'.
	self assert: self methodListPresenter selection equals: selectedMethod.	"assert selections & lists stay the same switching to hierarchy view ..."
	self selectClassListTab.
	self assert: self projectsPresenter variableListPresenter list size equals: variableSize.
	self assert: self projectsPresenter variableListPresenter selection equals: 'variables'.
	self assert: self methodListPresenter selection equals: selectedMethod	"... and back"!

test_verifyValidCategory
	self testsIssue: #issue205 withTitle: 'misspelled extension category name causes trouble'.
	self assert: (self projectsPresenter verifyValidCategory: '*Rowan-Kernel') .
	self assert: (self projectsPresenter verifyValidCategory: '*rowan-kernel') .
	self assert: (self projectsPresenter verifyValidCategory: 'aaa') .
	self deny: (self projectsPresenter verifyValidCategory: '*rowankernel') .
	self deny: (self projectsPresenter verifyValidCategory: '*rowankernelx') .!

waitForPresenter: presenter
	[presenter list isEmpty] whileTrue: [(Delay forMilliseconds: 50) wait]! !
!JadeiteProjectBrowserTestCase categoriesFor: #cloneRowanSample1!private!project support! !
!JadeiteProjectBrowserTestCase categoriesFor: #commandQueryOn:view:!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #disableTranscriptWrites!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #issue170methodCreation!issue test support!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #issue261createTestProject!issue test support!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #issue284methodCreation!issue test support!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #packageNamed:!private!project support! !
!JadeiteProjectBrowserTestCase categoriesFor: #projectList!private!project support! !
!JadeiteProjectBrowserTestCase categoriesFor: #projectNamed:!private!project support! !
!JadeiteProjectBrowserTestCase categoriesFor: #rowanProjectNames!constants!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #saveClass:superclass:instVars:package:!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #saveClass:withInstVars:package:!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #saveHooMethod!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #saveMethodWithUnimplementedSelector!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #saveMethodWithUniqueString!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #saveSampleMethod!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #saveTestClass!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #saveTestClassWithInstVars:package:!private! !
!JadeiteProjectBrowserTestCase categoriesFor: #selectClassInHierarchyNamed:!private!selection! !
!JadeiteProjectBrowserTestCase categoriesFor: #selectClassListTab!private!selection! !
!JadeiteProjectBrowserTestCase categoriesFor: #selectHierarchyTab!private!selection! !
!JadeiteProjectBrowserTestCase categoriesFor: #selectHierarchyTabIn:!private!selection! !
!JadeiteProjectBrowserTestCase categoriesFor: #selectRowanSample1Test!private!selection! !
!JadeiteProjectBrowserTestCase categoriesFor: #selectSUnitTab!private!selection! !
!JadeiteProjectBrowserTestCase categoriesFor: #selectTreeServicesNamed:in:!private!selection! !
!JadeiteProjectBrowserTestCase categoriesFor: #setUp!private!setup teardown! !
!JadeiteProjectBrowserTestCase categoriesFor: #tearDown!private!setup teardown! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_abstractTestsShown!public!test sunit tab! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_addDuplicatePackage!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_addPackageReloadProject!public!test projects! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_addRemoveCategory!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_addRemoveHierarchyCategory!public!test class hierarchy! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_autoDirtyDisplayMoveMethodsToCategory!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_autoDirtyDisplayRemoveMethod!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_browseSameClassCategoriesCorrect!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_categoryTextDisplay!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_classListNotBlank!public!test class list! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_classSideSelection!public!test class hierarchy!test class list!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_classVersionIncrementedInClassList!public!test class list! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_classVersionIncrementedInHierarchy!public!test class hierarchy! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_closeConsoleInvalidSession!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_closeConsoleValidSession!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_definedClassMenuItem!public!test defined package! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_dragClassDoesNotWalkback!public!test drag drop! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_dragClassInHierarchyDoesNotWalkback!public!test class hierarchy!test drag drop! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_dropMethodOnClassHierarchy!public!test class hierarchy!test drag drop! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_dropMethodOnClassList!public!test class list!test drag drop! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_duplicateInstVars!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_duplicateInstVarsHierarchy!public!test class hierarchy! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_duplicateInstVarsInHierarchy!public!test class hierarchy! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_exitJadeiteInvalidSession!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_exitJadeiteValidSession!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_expansion!public!test class hierarchy! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_extensionColoringInHierarchy!public!test class hierarchy! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_filtersUpdatedInHierarchyView!public!test class hierarchy! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_findClass!public!test class list!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_goToDefinedClassFromClassList!public!test defined package! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_goToDefinedClassFromHierarchy!public!test class hierarchy!test defined package! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_goToDefinedMethodFromClassList!public!test class list!test defined package! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_goToDefinedMethodFromClassListClassSide!public!test defined package! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_goToDefinedMethodFromHierarchy!public!test class hierarchy!test defined package! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_gotoDefinedMethodNotSameAsClass!public!test defined package!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_gotoDefinedPackage!public!test defined package!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_hierarchyCleanedUpAfterUnload!public!test class hierarchy!test projects! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_hierarchyFindsAllSubclassImplementors!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_hierarchyImplementors!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_hierarchyImplementorsFromMethodList!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_hierarchyImplementorsSendersCaption!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_hierarchyMethodsNotDisplayed!public!test class hierarchy! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_hierarchySelectTwoBrowsers!public!test class hierarchy! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_hierarchySenders!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_hierarchySendersFromMethodList!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_implementorsSendersCaption!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_issue261!public!test menus!test projects! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_literalReferences!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_makeDefault!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_menuAddPackageOnProjectMenu!public!test projects!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_menuEnablementDoesNotBreak!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_menusDontAddBreaks!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_methodsContaining!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_methodsContainingCaption!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_methodTabSelected!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_multipleCompileMethod!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_noSelectionHierarchy!public!test class hierarchy! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_openNewProjectBrowser!public!test menus!test projects! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_openNewProjectTab!public!test menus!test projects! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_openProjectsBrowser!public!test projects! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_openProjectsBrowserFromMethodList!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_packagesShownInMultipleProjects!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_projectDisplaysSync!public!test projects! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_projectInfoTab!public!test menus!test projects! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_projectRemoved!public!test projects! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_refreshAfterAbortMethodList!public!test projects! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_refreshAfterAbortMethodListLeaveCommitted!public!test projects! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_refreshAfterReloadInProjectsBrowserWithAddedMethod!public!test projects! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_refreshAfterReloadWithAddedMethod!public!test projects! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_refreshFromServer!public!test class hierarchy!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_removeAbortedClass!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_removeProject!public!test projects! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_rowanTestsHierarchy!public!test class hierarchy! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_saveClassCommentInClassList!public!test class list!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_saveClassCommentInHierarchy!public!test class hierarchy!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_saveClassMethod!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_saveClassMethodHierarchy!public!test class hierarchy! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_saveMethod!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_saveMethodAndUpdateSUnitTab!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_saveMethodHierarchy!public!test class hierarchy! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_selectMultiplePackages!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_selectMultipleProjects!public!test projects! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_setAndClearBreakpoint!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_simpleHierarchyTest!public!test class hierarchy!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_sunitCtrlB!public!test sunit tab! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_sunitInheritedTests!public!test sunit tab! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_sunitTabCanRefresh!public!test menus!test sunit tab! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_sUnitTabHandlesShortSelector!public!test class hierarchy!test sunit tab! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_sUnitTabRefresh!public!test menus!test sunit tab! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_sunitUpdatesProperly!public!test sunit tab! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_symbolsWithoutImplementorsFound!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_tabNames!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_tabNames_projectsBrowser!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_tabNames_projectsBrowserNotLost!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_variablesTab!public!test class list! !
!JadeiteProjectBrowserTestCase categoriesFor: #test_verifyValidCategory!public!tests! !
!JadeiteProjectBrowserTestCase categoriesFor: #waitForPresenter:!private!selection! !

