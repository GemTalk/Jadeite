"Filed out from Dolphin Smalltalk 7"!

JadeiteProjectBrowserAbstractTestCase subclass: #JadeiteProjectBrowserClassesTestCase
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteProjectBrowserClassesTestCase guid: (GUID fromString: '{03bb9553-dd8e-4eaa-8e2c-19436754bf61}')!
JadeiteProjectBrowserClassesTestCase comment: 'General Jadeite tests. Assumes a logged in session and transcript present. 

When running tests from SUnit Browser Tool, make sure to turn on Auto Initialize Resources.

See JadeiteProjectBrowserTestCase for similar tests. Additional test class created so 
test run wouldn''t be too long to run in the test browser. '!
!JadeiteProjectBrowserClassesTestCase categoriesForClass!Unclassified! !
!JadeiteProjectBrowserClassesTestCase methodsFor!

test_abortRemovesClassAndMethod
	self testsIssue: #issue617 withTitle: 'Abort walkback if removing method from removed class'.
	self selectRowanSample1Test.
	self
		saveClass: 'TestAbortRemovesClass'
		superclass: 'Object'
		instVars: #()
		package: 'RowanSample1-Tests'.
	
	[self
		saveMethod: 'terrific ^''yippee'''
		in: 'TestAbortRemovesClass'
		category: 'deleteme'.
	self denyIsNil: (self classListPresenter list
				detect: [:classService | classService name = 'TestAbortRemovesClass']
				ifNone: []).
	self abortTransaction.
	self assertIsNil: (self classListPresenter list
				detect: [:classService | classService name = 'TestAbortRemovesClass']
				ifNone: [])]
			ensure: 
				[self cloneRowanSample1.
				self ensureRowanSample1Loaded]!

test_abortRemovesProjectAndPackage
	self selectRowanSample1Test.
	
	[self denyIsNil: (self projectListPresenter list
				detect: [:projectService | projectService name = 'RowanSample1']
				ifNone: []).
	self denyIsNil: (self packageListPresenter list
				detect: [:packageService | packageService name = 'RowanSample1-Tests']
				ifNone: []).
	self abortTransaction.
	self assertIsNil: (self projectListPresenter list
				detect: [:projectService | projectService name = 'RowanSample1']
				ifNone: []).
	self assertIsNil: (self packageListPresenter list
				detect: [:packageService | packageService name = 'RowanSample1-Tests']
				ifNone: [])]
			ensure: 
				[self cloneRowanSample1.
				self ensureRowanSample1Loaded]!

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

test_browseClassReferencesFromClassesMenu
	"run from classes menu per bug #640"

	| classesMenu browseReferencesMenuItem |
	self testsIssue: #issue640 withTitle: 'Error dialogs from PB menu items when on Sunit tab'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Core' in: self packageListPresenter.
	self projectsPresenter isHierarchyTabSelected
		ifTrue: 
			[self selectTreeServicesNamed: (Array with: 'RowanClassService') in: self classHierarchyPresenter]
		ifFalse: [self selectServiceNamed: 'RowanClassService' in: self classListPresenter].
	classesMenu := projectsBrowser topShell view menuBar items
				detect: [:item | '*Classes*' match: item text].
	browseReferencesMenuItem := classesMenu items
				detect: [:item | '*Browse Class References*' match: item text].
	self selectSUnitTab.	"must be selected for bug to occur"
	methodListBrowser := browseReferencesMenuItem commandDescription
				performAgainst: self projectsPresenter.
	self
		assert: methodListBrowser primaryPresenter methodListPresenter methodListPresenter list notEmpty.
	methodListBrowser primaryPresenter methodListPresenter methodListPresenter list
		do: [:methodService | self assert: ('*RowanClassService*' match: methodService source)]!

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

test_classCopyHierarchy
	self testsIssue: #issue506 withTitle: 'Usefful to be able to copy a class ...'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Core' in: self packageListPresenter.
	self projectsPresenter isHierarchyTabSelected
		ifTrue: [self selectTreeServicesNamed: (Array with: 'RowanSample1') in: self classHierarchyPresenter]
		ifFalse: [self selectServiceNamed: 'RowanSample1' in: self classListPresenter].
	self selectHierarchyTab.
	self projectsPresenter basicCopyClass: self projectsPresenter selectedClass to: 'Fnoodle'.
	self assert: self projectsPresenter selectedClass name equals: 'Fnoodle'.
	self assert: self categoryListPresenter list first equals: 'accessing'.
	self assert: self methodListPresenter list first selector equals: #foo.
	self selectClassTab.
	self assert: self categoryListPresenter list first equals: '*rowansample1-extensions'.
	self assert: self methodListPresenter list first selector equals: #bar!

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

test_classRenameNoReferences
	self testsIssue: #issue439 withTitle: '`rename` class menu item would be useful'.
	self selectRowanSample1Test.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #('inst1')
		package: 'RowanSample1-Tests'.
	
	[self projectsPresenter selectClassNamed: 'TestClass'.
	self projectsPresenter basicRenameClass: self projectsPresenter selectedClass to: 'RenamedClass'.
	self assertIsNil: (self classListPresenter list
				detect: [:classService | classService name asString = 'TestClass']
				ifNone: []).
	self assert: self classListPresenter selection name equals: 'RenamedClass']
			ensure: [self projectsPresenter basicRemoveClass: self classListPresenter selection]!

test_classRenameNoReferencesHierarchy
	self testsIssue: #issue439 withTitle: '`rename` class menu item would be useful'.
	self selectRowanSample1Test.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #('inst1')
		package: 'RowanSample1-Tests'.
	
	[self projectsPresenter selectClassNamed: 'TestClass'.
	self selectHierarchyTab.
	self assert: self classHierarchyPresenter selection name equals: 'TestClass'.
	self projectsPresenter basicRenameClass: self projectsPresenter selectedClass to: 'RenamedClass'.
	self assertIsNil: (self classListPresenter list
				detect: [:classService | classService name asString = 'TestClass']
				ifNone: []).
	self assert: self classHierarchyPresenter selection name equals: 'RenamedClass']
			ensure: [self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass]!

test_classRenameResetsClassDefinition
	self testsIssue: #issue439 withTitle: '`rename` class menu item would be useful'.
	self selectRowanSample1Test.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #('inst1')
		package: 'RowanSample1-Tests'.
	
	[self projectsPresenter selectClassNamed: 'TestClass'.
	self projectsPresenter basicRenameClass: self projectsPresenter selectedClass to: 'RenamedClass'.
	self assert: ('*Object rwSubclass: ''RenamedClass''*'
				match: self projectsPresenter classDefinitionPresenter value)]
			ensure: [self projectsPresenter basicRemoveClass: self classListPresenter selection]!

test_classRenameShowsMethods
	"don't lose the method display on rename"

	| methodList |
	self testsIssue: #issue439 withTitle: '`rename` class menu item would be useful'.
	"essentially by not using the test dialog box we test Jadeite's part of the fix for #513. The rest was in Rowan"
	self testsIssue: #issue513 withTitle: 'Class rename also updates method sends (3.0.76)'.
	self selectRowanSample1Test.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #('inst1')
		package: 'RowanSample1-Tests'.
	
	[self projectsPresenter selectClassNamed: 'TestClass'.
	methodList := self methodListPresenter list.
	self projectsPresenter basicRenameClass: self projectsPresenter selectedClass to: 'RenamedClass'.
	self assertIsNil: (self classListPresenter list
				detect: [:classService | classService name asString = 'TestClass']
				ifNone: []).
	self assert: self classListPresenter selection name equals: 'RenamedClass'.
	self assert: self methodListPresenter list equals: methodList]
			ensure: [self projectsPresenter basicRemoveClass: self classListPresenter selection]!

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

test_copyClassExistingClassRetry
	self testsIssue: #issue650
		withTitle: '(3.0.89) `Jadeite>>Auto Commit enabled` menu out of sync with auto commit state'.
	self selectRowanSample1Test.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[TestPrompter plannedResult: (OrderedCollection with: 'RowanSample1Test' with: 'RowanSample1Test2').	"first dialog - enter existing class name. second - enter non-existing name"
	TestMessageBox plannedResult: #ok.	"got retry option"
	self projectsPresenter copyClass.
	self assertIsNil: TestPrompter plannedResult.
	self assertIsNil: TestMessageBox plannedResult.
	self assert: self classListPresenter selection name equals: 'RowanSample1Test2']
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

test_displayCompileWarningsNicely
	self testsIssue: #issue509 withTitle: 'Warning for unused temps should be grouped better (3.0.75)'.
	self selectRowanSample1Test.
	self projectsPresenter selectMethodSourceTab.
	self selectCategoriesNamed: #('tests'). 
	self methodSourcePresenter
		value: 'failInConcreteClass
	| abc def aa ddd |
	self assert: self class name equals: ''SubTest'''.
	self projectsPresenter editSaveMethod.
	
	[self assert: self projectsPresenter statusBarText value
		equals: 'WARNING: unused method temp ''abc''; unused method temp ''def''; unused method temp ''aa''; unused method temp ''ddd''; ']
			ensure: [self projectsPresenter removeMethods: (Array with: self projectsPresenter selectedClass)]!

test_dontDuplicateClasses
	self testsIssue: #issue760 withTitle: 'Duplicate classes pop up if a class is selected (3.1prerelease2)'.
	self selectRowanSample1Test.
	self selectClassTab. 
	self assert: self classListPresenter list size equals: 1. 
	self assert: self classListPresenter list first name equals: 'RowanSample1Test'. 
	self selectServiceNamed: 'RowanSample1Test' in: self classListPresenter. 
	self assert: self classListPresenter list size equals: 1. 
	self assert: self classListPresenter list first name equals: 'RowanSample1Test'. 
	self selectInstanceTab. 
	self assert: self classListPresenter list size equals: 1. 
	self assert: self classListPresenter list first name equals: 'RowanSample1Test'. 
	self selectServiceNamed: 'RowanSample1Test' in: self classListPresenter. 
	self assert: self classListPresenter list size equals: 1. 
	self assert: self classListPresenter list first name equals: 'RowanSample1Test'. 
	!

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
	self assert: self projectsPresenter definedMethodPackageText view text
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

test_findClassDialog
	| findClassDialog |
	findClassDialog := (JadeiteFindClassDialog create: 'DefaultView'
				on: (JadePresenter allClassesIn: session)) show.	"do not open modal"
	
	[self assert: findClassDialog classListPresenter selectionByIndex equals: 1.
	findClassDialog selectNextClass.
	self assert: findClassDialog classListPresenter selectionByIndex equals: 2.
	findClassDialog classListPresenter selectionByIndex: findClassDialog classListPresenter list size.
	self assert: findClassDialog classListPresenter selectionByIndex
		equals: findClassDialog classListPresenter list size.
	findClassDialog selectNextClass.
	self assert: findClassDialog classListPresenter selectionByIndex
		equals: findClassDialog classListPresenter list size.
	findClassDialog selectPreviousClass.
	self assert: findClassDialog classListPresenter selectionByIndex
		equals: findClassDialog classListPresenter list size - 1.
	findClassDialog classListPresenter selectionByIndex: 1.
	self assert: findClassDialog classListPresenter selectionByIndex equals: 1.
	findClassDialog selectPreviousClass.
	self assert: findClassDialog classListPresenter selectionByIndex equals: 1]
			ensure: [findClassDialog view close]!

test_fullHierarchyExpansion
	| hierarchyClassNames |
	self testsIssue: #issue640 withTitle: 'Double click no longer expands hierarchy view'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Core' in: self packageListPresenter.
	self selectClassListTab. 
	self selectServiceNamed: 'RowanClassService' in: self classListPresenter.
	self selectHierarchyTab.
	hierarchyClassNames := self classHierarchyPresenter model asArray
				collect: [:classService | classService name].
	self assert: hierarchyClassNames equals: #('Object' 'RowanService' 'RowanClassService').
	self selectClassInHierarchyNamed: 'RowanService'.
	self projectsPresenter expandFullHierarchy.
	hierarchyClassNames := self classHierarchyPresenter model asArray do: 
					[:classService |
					self assert: (session
								executeString: '
							| hierarchy |
							hierarchy := (RowanService allSuperclasses collect: [:cls | cls name]) asArray. 
							hierarchy add: #RowanService. 
							hierarchy addAll: (RowanService allSubclasses collect: [:cls | cls name]) asArray. 
							hierarchy includes: '
										, classService name asSymbol printString)]!

test_fullHierarchyExpansionDoubleClock
	| hierarchyClassNames |
	self testsIssue: #issue640 withTitle: 'Double click no longer expands hierarchy view'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Core' in: self packageListPresenter.
	self selectClassListTab. 
	self selectServiceNamed: 'RowanClassService' in: self classListPresenter.
	self selectHierarchyTab.
	hierarchyClassNames := self classHierarchyPresenter model asArray
				collect: [:classService | classService name].
	self assert: hierarchyClassNames equals: #('Object' 'RowanService' 'RowanClassService').
	self selectClassInHierarchyNamed: 'RowanService'.
	self classHierarchyPresenter trigger: #actionPerformed. "double click" 
	hierarchyClassNames := self classHierarchyPresenter model asArray do: 
					[:classService |
					self assert: (session
								executeString: '
							| hierarchy |
							hierarchy := (RowanService allSuperclasses collect: [:cls | cls name]) asArray. 
							hierarchy add: #RowanService. 
							hierarchy addAll: (RowanService allSubclasses collect: [:cls | cls name]) asArray. 
							hierarchy includes: '
										, classService name asSymbol printString)]!

test_fullHierarchyExpansionManyLevels
	"JadeServer has a subclass that's many levels deep"

	| hierarchyClassNames |
	self testsIssue: #issue640 withTitle: 'Double click no longer expands hierarchy view'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-JadeServer' in: self packageListPresenter.
	self selectClassListTab. 
	self selectServiceNamed: 'JadeServer64bit' in: self classListPresenter.
	self selectHierarchyTab.
	hierarchyClassNames := self classHierarchyPresenter model asArray
				collect: [:classService | classService name].
	self assert: hierarchyClassNames
		equals: #('Object' 'JadeServer' 'JadeServer64bit' 'JadeServer64bit24').
	self selectClassInHierarchyNamed: 'JadeServer'.
	self projectsPresenter expandFullHierarchy.
	hierarchyClassNames := self classHierarchyPresenter model asArray do: 
					[:classService |
					self assert: (session
								executeString: '
							| hierarchy |
							hierarchy := (JadeServer allSuperclasses collect: [:cls | cls name]) asArray. 
							hierarchy add: #JadeServer. 
							hierarchy addAll: (JadeServer allSubclasses collect: [:cls | cls name]) asArray. 
							hierarchy includes: '
										, classService name asSymbol printString)]!

test_fullHierarchyExpansionManyLevelsDoubleClick
	"JadeServer has a subclass that's many levels deep"

	| hierarchyClassNames |
	self testsIssue: #issue640 withTitle: 'Double click no longer expands hierarchy view'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-JadeServer' in: self packageListPresenter.
	self selectClassListTab.
	self selectServiceNamed: 'JadeServer64bit' in: self classListPresenter.
	self selectHierarchyTab.
	hierarchyClassNames := self classHierarchyPresenter model asArray
				collect: [:classService | classService name].
	self assert: hierarchyClassNames
		equals: #('Object' 'JadeServer' 'JadeServer64bit' 'JadeServer64bit24').
	self selectClassInHierarchyNamed: 'JadeServer'.
	self classHierarchyPresenter trigger: #actionPerformed.	"double click"
	hierarchyClassNames := self classHierarchyPresenter model asArray do: 
					[:classService |
					self assert: (session
								executeString: '
							| hierarchy |
							hierarchy := (JadeServer allSuperclasses collect: [:cls | cls name]) asArray. 
							hierarchy add: #JadeServer. 
							hierarchy addAll: (JadeServer allSubclasses collect: [:cls | cls name]) asArray. 
							hierarchy includes: '
										, classService name asSymbol printString)]!

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

test_goToDefinedClassFromHierarchyViaButton
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
	self assert: self projectsPresenter definedClassPackageText view command
		equals: #gotoClassDefinedPackageViaButton.
	self projectsPresenter gotoClassDefinedPackageViaButton.
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

test_goToDefinedMethodFromHierarchyViaButton
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Extensions' in: self packageListPresenter.
	self selectServiceNamed: 'RwGsPlatform' in: self classListPresenter.
	self selectHierarchyTab.
	self selectCategoryNamed: '*rowan-services-extensions'.
	self selectMethodNamed: #classServiceClass.
	self deny: self projectsPresenter isClassListTabSelected.
	self assert: self projectsPresenter definedMethodPackageText view command
		equals: #gotoMethodDefinedPackageViaButton.
	self projectsPresenter gotoMethodDefinedPackageViaButton.
	self assert: self packageListPresenter selection name = 'Rowan-Services-Extensions'.
	self assert: self classListPresenter selection name = 'RwGsPlatform'.
	self assert: self categoryListPresenter selection = '*rowan-services-extensions'.
	self assert: self methodListPresenter selection selector = #classServiceClass.
	self assert: self projectsPresenter isClassListTabSelected	"make my life easier by forcing the class side to be seleted"!

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
	self assert: grandchildren size equals: 16. "this will probably change but it's a nice test to ensure all the expected services are present"
	grandchildrensNames := grandchildren collect: [:classService | classService name].
	self assert: (grandchildrensNames at: 1) equals: 'RowanAnsweringService'.
	self assert: (grandchildrensNames at: 2) equals: 'RowanAutoCommitService'.
	self assert: (grandchildrensNames at: 3) equals: 'RowanBrowserService'.
	self assert: (grandchildrensNames at: 4) equals: 'RowanClassService'.
	self assert: (grandchildrensNames at: 5) equals: 'RowanDebuggerService'.
	self assert: (grandchildrensNames at: 6) equals: 'RowanDictionaryService'.
	self assert: (grandchildrensNames at: 7) equals: 'RowanFrameService'.
	self assert: (grandchildrensNames at: 8) equals: 'RowanInspectorService'.
	self assert: (grandchildrensNames at: 9) equals: 'RowanLoggingService'.
	self assert: (grandchildrensNames at: 10) equals: 'RowanMethodService'.
	self assert: (grandchildrensNames at: 11) equals: 'RowanPackageService'.
	self assert: (grandchildrensNames at: 12) equals: 'RowanProcessService'.
	self assert: (grandchildrensNames at: 13) equals: 'RowanProjectService'.
	self assert: (grandchildrensNames at: 14) equals: 'RowanQueryService'.
	self assert: (grandchildrensNames at: 15) equals: 'RowanTestService'.
	self assert: (grandchildrensNames at: 16) equals: 'RowanVariableService'.

!

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

test_removeClassFromHierarchy
	| classReferences |
	self testsIssue: #issue377 withTitle: '(3.0.53) remove class in hierarchy class view does not work'.
	self selectRowanSample1Class.
	self
		saveMethod: 'createReference  ^RowanSample1Test'
		in: 'RowanSample1'
		category: 'deleteme'.
	self selectRowanSample1Test.
	self selectHierarchyTab.
	self assertLinearAncestry: #('Object' 'TestAsserter' 'TestCase' 'RowanSample1Test')
		in: self classHierarchyPresenter.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[TestMessageBox plannedResult: #(#yes #ok) asOrderedCollection.
	classReferences := self projectsPresenter removeClass.
	self assertLinearAncestry: #('Object' 'TestAsserter' 'TestCase') in: self classHierarchyPresenter]
			ensure: 
				[classReferences view close.
				TestMessageBox disableJadeiteTestMessageBox]!

test_removeClassFromList
	| classReferences |
	self testsIssue: #issue377 withTitle: '(3.0.53) remove class in hierarchy class view does not work'.
	self testsIssue: #issue725 withTitle: 'Handle removed class references better'.
	self selectRowanSample1Class.
	self
		saveMethod: 'createReference  ^RowanSample1Test'
		in: 'RowanSample1'
		category: 'deleteme'.
	self selectRowanSample1Test.
	self denyIsNil: (self classListPresenter list
				detect: [:classService | classService name = 'RowanSample1Test']
				ifNone: []).
	TestMessageBox enableJadeiteTestMessageBox.
	
	[TestMessageBox plannedResult: #(#yes #ok) asOrderedCollection.
	classReferences := self projectsPresenter removeClass.
	self assert: ('Class References of*' match: classReferences topShell caption).
	self assertIsNil: (self classListPresenter list
				detect: [:classService | classService name = 'RowanSample1Test']
				ifNone: [])]
			ensure: 
				[TestMessageBox disableJadeiteTestMessageBox.
				classReferences view close]!

test_removeClassNoReferences
	self testsIssue: #issue753
		withTitle: '(3.0.93) when removing a class that has no references, no need for empty method browser and notification'.
	self selectRowanSample1Test.
	self
		saveClass: 'RowanSample1TestSubClass'
		superclass: 'RowanSample1Test'
		instVars: #()
		package: 'RowanSample1-Tests'.
	self denyIsNil: (self classListPresenter list
				detect: [:classService | classService name = 'RowanSample1TestSubClass']
				ifNone: []).
	TestMessageBox enableJadeiteTestMessageBox.
	
	[TestMessageBox plannedResult: #(#yes) asOrderedCollection.
	self projectsPresenter removeClass.
	self assertIsNil: (self classListPresenter list
				detect: [:classService | classService name = 'RowanSample1TestSubClass']
				ifNone: [])	"no class references list appeared which is expected"]
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

test_removeClassWithSubclasses
	self testsIssue: #issue727 withTitle: 'Prevent class removal if subclasses present'.
	self selectRowanSample1Class.
	TestMessageBox enableJadeiteTestMessageBox.
	self
		denyIsNil: (self classListPresenter list detect: [:classService | classService name = 'RowanSample1']
				ifNone: []).
	
	[TestMessageBox plannedResult: #ok.
	self projectsPresenter removeClass.
	self assertIsNil: TestMessageBox plannedResult.	"shows dialog was raised"
	self
		denyIsNil: (self classListPresenter list detect: [:classService | classService name = 'RowanSample1']
				ifNone: [])]
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

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
	self projectsPresenter basicRenameClass: self classListPresenter selection to: 'TestClassWasRenamed'.
	self assert: methodListBrowser primaryPresenter methodListPresenter methodListPresenter list size
		equals: 1.
	self assert: methodListBrowser primaryPresenter methodListPresenter methodListPresenter list first
				className
		equals: 'TestClassWasRenamed'!

test_renameClassMethodListUpdatesFromClassesMenu
	"run from classes menu per bug #640"

	| classesMenu renameMenuItem |
	self testsIssue: #issue439 withTitle: '`rename` class menu item would be useful'.
	self testsIssue: #issue465 withTitle: '(3.067) error after rename class in hierarchy view'.
	self testsIssue: #issue640 withTitle: 'Error dialogs from PB menu items when on Sunit tab'.
	self selectRowanSample1Test.
	methodListBrowser := JadePresenter browseImplementorsOf: 'test1' session: session.
	self assert: methodListBrowser primaryPresenter methodListPresenter methodListPresenter list size
		equals: 1.
	self assert: methodListBrowser primaryPresenter methodListPresenter methodListPresenter list first
				className
		equals: 'RowanSample1Test'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[TestPrompter plannedResult: 'TestClassWasRenamed'.
	classesMenu := projectsBrowser topShell view menuBar items
				detect: [:item | '*Classes*' match: item text].
	renameMenuItem := classesMenu items detect: [:item | '*Rename*' match: item text].
	self selectSUnitTab.	"must be selected for bug to occur"
	TestMessageBox plannedResult: #yes.
	renameMenuItem commandDescription performAgainst: self projectsPresenter.
	self assert: methodListBrowser primaryPresenter methodListPresenter methodListPresenter list size
		equals: 1.
	self assert: methodListBrowser primaryPresenter methodListPresenter methodListPresenter list first
				className
		equals: 'TestClassWasRenamed']
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

test_renameClassShowsAsDefinedInPackage
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
	self projectsPresenter basicRenameClass: self classListPresenter selection
		to: 'TestClassWasRenamedAgain'.
	JadeiteRenameClassMethodListBrowser allInstances do: [:browser | browser view close].	"referenced methods browser is opened"
	self assert: self classListPresenter selection isExtension.
	self assert: self classListPresenter selection name equals: 'TestClassWasRenamedAgain'.
	self selectHierarchyTab.
	self assert: self classHierarchyPresenter selection isExtension.
	self assert: self classHierarchyPresenter selection name equals: 'TestClassWasRenamedAgain'.
	self selectClassListTab!

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
	self projectsPresenter basicRenameClass: self classListPresenter selection to: 'TestClassWasRenamed'.
	self assert: sunitBrowser primaryPresenter classListPresenter list size equals: 1.
	self assert: sunitBrowser primaryPresenter classListPresenter list first name
		equals: 'TestClassWasRenamed']
			ensure: [sunitBrowser view close]!

test_renameClassSwitchToHierarchyOk
	self testsIssue: #issue439 withTitle: '`rename` class menu item would be useful'.
	self testsIssue: #issue465 withTitle: '(3.067) error after rename class in hierarchy view'.
	self selectRowanSample1Class.
	self projectsPresenter basicRenameClass: self classListPresenter selection to: 'TestClassWasRenamed'.
	JadeiteRenameClassMethodListBrowser allInstances do: [:browser | browser view close].	"referenced methods browser is opened"
	self assert: self classListPresenter selection name equals: 'TestClassWasRenamed'.
	self selectHierarchyTab.
	self assert: self classHierarchyPresenter selection name equals: 'TestClassWasRenamed'.
	self projectsPresenter basicRenameClass: self classListPresenter selection
		to: 'TestClassWasRenamedAgain'.
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
	self projectsPresenter basicRenameClass: self classListPresenter selection to: 'TestClassWasRenamed'.
	JadeiteRenameClassMethodListBrowser allInstances do: [:browser | browser view close].	"referenced methods browser is opened"
	self assert: self classListPresenter selection name equals: 'TestClassWasRenamed'.
	self assert: secondPresenter classListPresenter selection name equals: 'TestClassWasRenamed'!

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
	self projectsPresenter basicRenameClass: self classListPresenter selection to: 'TestClassWasRenamed'.
	JadeiteRenameClassMethodListBrowser allInstances do: [:browser | browser view close].	"referenced methods browser is opened"
	self assert: self classListPresenter selection name equals: 'TestClassWasRenamed'.
	self assert: secondPresenter classListPresenter selection name equals: 'TestClassWasRenamed'!

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

test_selectionsRetainedFromClassListToHierarchy
	self testsIssue: #issue448 withTitle: 'Class selection not retained from Hierarchy->Class view'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Core' in: self packageListPresenter.
	self selectServiceNamed: 'RowanAnsweringService' in: self classListPresenter.
	self selectCategoryNamed: 'accessing'. 
	self selectMethodNamed: #answer.
	self selectHierarchyTab.
	self assert: self projectsPresenter selectedClass name equals: 'RowanAnsweringService'.
	self assert: self categoryListPresenter selection equals: 'accessing'.
	self assert: self methodListPresenter selection selector equals: #answer.
	self projectsPresenter selectClassListTab.
	self assert: self projectsPresenter selectedClass name equals: 'RowanAnsweringService'.
	self assert: self categoryListPresenter selection equals: 'accessing'.
	self assert: self methodListPresenter selection selector equals: #answer.
	self selectHierarchyTab.
	self assert: self projectsPresenter selectedClass name equals: 'RowanAnsweringService'.
	self assert: self categoryListPresenter selection equals: 'accessing'.
	self assert: self methodListPresenter selection selector equals: #answer.
	!

test_selectionsRetainedFromHierarchyToClassList
	self testsIssue: #issue448 withTitle: 'Class selection not retained from Hierarchy->Class view'.
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	self selectServiceNamed: 'Rowan-Services-Core' in: self packageListPresenter.
	self selectServiceNamed: 'RowanService' in: self classListPresenter.
	self selectHierarchyTab.
	self selectClassInHierarchyNamed: 'RowanAnsweringService'.
	self selectCategoryNamed: 'accessing'.
	self selectMethodNamed: #answer.
	self projectsPresenter selectClassListTab.
	self assert: self projectsPresenter selectedClass name equals: 'RowanAnsweringService'.
	self assert: self categoryListPresenter selection equals: 'accessing'.
	self assert: self methodListPresenter selection selector equals: #answer.
	self selectHierarchyTab.
	self selectCategoryNamed: 'accessing'.
	self selectMethodNamed: #answer.
	self projectsPresenter selectClassListTab.
	self projectsPresenter selectClassListTab.
	self assert: self projectsPresenter selectedClass name equals: 'RowanAnsweringService'.
	self assert: self categoryListPresenter selection equals: 'accessing'.
	self assert: self methodListPresenter selection selector equals: #answer.!

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
	self assert: ('aaa*' match: failService selector).
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
	self assert: (self categoryListPresenter list includes: 'aaa')! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_abortRemovesClassAndMethod!public!test class list! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_abortRemovesProjectAndPackage!public!test class list! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_addAccessorsHierarchyTab!public!test class hierarchy!test variable tab!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_addAccessorsHierarchyTabVerifySource!public!test class hierarchy!test variable tab!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_addRemoveHierarchyCategory!public!test class hierarchy!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_addSubclass!public!test class hierarchy!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_allClassesAutoCommitOn!public!test class list!test find!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_browseClassReferencesFromClassesMenu!public!test rename class! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_classColoring!public!test class hierarchy!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_classColoringExtension!public!test class hierarchy!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_classCopyHierarchy!public!test class hierarchy! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_classDefinitionTemplateAfterRemove!public!test class list!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_classDefinitionTemplateAfterRemoveInHierarchy!public!test class hierarchy!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_classDeselection!public!test class list!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_classHierarchyDeselection!public!test class hierarchy!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_classListNotBlank!public!test class list!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_classRenameNoReferences!public!test rename class!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_classRenameNoReferencesHierarchy!public!test rename class!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_classRenameResetsClassDefinition!public!test rename class!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_classRenameShowsMethods!public!test rename class!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_classRenameWithReferences!public!test rename class!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_classRenameWithReferencesFailingCompile!public!test rename class!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_classRenameWithReferencesHierarchy!public!test rename class!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_classRenameWithReferencesSimilarNameButNoFailCompile!public!test rename class!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_classSideSelection!public!test class hierarchy!test class list!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_classTemplateWhenNoPackagesSelected!public!test class list!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_classVersionIncrementedInClassList!public!test class list!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_classVersionIncrementedInHierarchy!public!test class hierarchy!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_copyClassExistingClassRetry!public!test rename class! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_displayCompileWarningsNicely!public!test class list! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_dontDuplicateClasses!public!test rename class!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_dragClassInHierarchyDoesNotWalkback!public!test class hierarchy!test drag drop!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_dragDropMethodFailCompile!public!test class hierarchy!test drag drop!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_dragDropMultipleMethods!public!test class hierarchy!test drag drop!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_dragDropMultipleMethodsHierarchy!public!test class hierarchy!test drag drop!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_dropMethodOnClassHierarchy!public!test class hierarchy!test drag drop!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_dropMethodOnClassList!public!test class list!test drag drop!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_dropNonSelectedMethod!public!test class list!test drag drop!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_expansion!public!test class hierarchy!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_extensionColoringInHierarchy!public!test class hierarchy!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_extensionMethodSelection!public!test class list!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_failMethodCompile!public!test class list!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_filtersUpdatedInHierarchyView!public!test class hierarchy!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_findClass!public!test class list!test find!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_findClassDialog!public!test class list!test find!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_fullHierarchyExpansion!public!test class hierarchy! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_fullHierarchyExpansionDoubleClock!public!test class hierarchy! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_fullHierarchyExpansionManyLevels!public!test class hierarchy! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_fullHierarchyExpansionManyLevelsDoubleClick!public!test class hierarchy! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_getClassCommentWithDeprecationsOn!public!test class list!test deprecated!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_goToDefinedClassFromHierarchy!public!test class hierarchy!test defined package!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_goToDefinedClassFromHierarchyViaButton!public!test class hierarchy!test defined package!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_goToDefinedMethodFromClassList!public!test class list!test defined package!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_goToDefinedMethodFromHierarchy!public!test class hierarchy!test defined package!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_goToDefinedMethodFromHierarchyViaButton!public!test class hierarchy!test defined package!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_hierarchyCleanedUpAfterUnload!public!test class hierarchy!test projects!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_hierarchyMethodsNotDisplayed!public!test class hierarchy!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_hierarchySelectTwoBrowsers!public!test class hierarchy!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_hierarchyWithNonResolvableClass!public!test class hierarchy!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_newBrowserRetainsClassAndMethod!public!test class hierarchy!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_newBrowserRetainsClassAndMethodClassSide!public!test class hierarchy!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_noSelectionHierarchy!public!test class hierarchy!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_refreshFromServer!public!test class hierarchy!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_removeClassFromHierarchy!public!test class hierarchy!test class list!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_removeClassFromList!public!test class hierarchy!test class list!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_removeClassNoReferences!public!test class hierarchy!test class list!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_removeClassWithSubclasses!public!test class hierarchy!test class list!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_renameClassMethodListUpdates!public!test rename class! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_renameClassMethodListUpdatesFromClassesMenu!public!test rename class! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_renameClassShowsAsDefinedInPackage!public!test rename class! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_renameClassSUnitBrowserUpdates!public!test rename class! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_renameClassSwitchToHierarchyOk!public!test rename class! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_renameClassUpdatedInSecondBrowser!public!test rename class! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_renameClassUpdatedInSecondBrowserHierarchy!public!test rename class! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_renameInClassListWithMethodListOpen!public!test class list!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_renameInHierarchyWithMethodListOpen!public!test class hierarchy!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_rowanTestsHierarchy!public!test class hierarchy!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_saveClassCommentInClassList!public!test class list!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_saveClassCommentInHierarchy!public!test class hierarchy!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_selectionsRetainedFromClassListToHierarchy!public!test class list!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_selectionsRetainedFromHierarchyToClassList!public!test class list!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_showMethodsFailingClassRecompilation!public!test class list! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_simpleHierarchyTest!public!test class hierarchy!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_updateHierarchyAfterClassRecompile!public!test class hierarchy!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_variablesTab!public!test class list!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_variablesUpdatedOnClassSaveInClassList!public!test class list!tests! !
!JadeiteProjectBrowserClassesTestCase categoriesFor: #test_variablesUpdatedOnClassSaveInHierarchy!public!test class list!tests! !

