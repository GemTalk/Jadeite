"Filed out from Dolphin Smalltalk 7"!

JadeiteProjectBrowserAbstractTestCase subclass: #JadeiteProjectBrowserLowerTabsTestCase
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteProjectBrowserLowerTabsTestCase guid: (GUID fromString: '{403703bd-0162-430b-bab9-fd69bc53883c}')!
JadeiteProjectBrowserLowerTabsTestCase comment: ''!
!JadeiteProjectBrowserLowerTabsTestCase categoriesForClass!Unclassified! !
!JadeiteProjectBrowserLowerTabsTestCase methodsFor!

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

test_classCopy
	self testsIssue: #issue506 withTitle: 'Usefful to be able to copy a class ...'.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Core' in: self packageListPresenter.
	self projectsPresenter isHierarchyTabSelected
		ifTrue: [self selectTreeServicesNamed: (Array with: 'RowanSample1') in: self classHierarchyPresenter]
		ifFalse: [self selectServiceNamed: 'RowanSample1' in: self classListPresenter].
	self projectsPresenter basicCopyClass: self projectsPresenter selectedClass to: 'Fnoodle'.
	self assert: self projectsPresenter selectedClass name equals: 'Fnoodle'.
	self assert: self categoryListPresenter list first equals: 'accessing'.
	self assert: self methodListPresenter list first selector equals: #foo.
	self selectClassTab.
	self assert: self categoryListPresenter list first equals: '*rowansample1-extensions'.
	self assert: self methodListPresenter list first selector equals: #bar!

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

test_compileClassDirtiesPackageAndProject
	self ensureRowanSample1Loaded.	"reload to control dirty state"
	self selectRowanSample1Class.
	self deny: self projectListPresenter selection isDirty.
	self deny: self packageListPresenter selection isDirty.
	self
		saveClass: 'RowanSample1'
		superclass: 'Object'
		instVars: #('abc')
		package: 'RowanSample1-Core'.
	self assert: self projectListPresenter selection isDirty.
	self assert: self packageListPresenter selection isDirty!

test_compileClassExistingInAnotherPackage
	self testsIssue: #issue516 withTitle: 'Rename instance variable with accessor method is... wonky'.
	self
		assert: (session executeString: '(Rowan image symbolList resolveSymbol: #RowanSample1Test) notNil').
	self selectRowanSample1Class.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[TestMessageBox plannedResult: #yes.	"create and move class"
	self
		saveClass: 'RowanSample1Test'
		superclass: 'Object'
		instVars: #('erbleldy')
		package: 'RowanSample1-Core'.	"this will force a confirmation dialog"
	self
		assert: (session executeString: '(Rowan image symbolList resolveSymbol: #RowanSample1Test) notNil').
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Tests' in: self packageListPresenter.
	self assertIsNil: (self classListPresenter list
				detect: [:classService | classService name = 'RowanSample1Test']
				ifNone: []).
	self selectServiceNamed: 'RowanSample1-Core' in: self packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: self classListPresenter.	"class has moved"
	self assert: (self classListPresenter selection instVarNames includes: #erbleldy)]
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

test_compileClassWithMethodWarnings
	self testsIssue: #issue569
		withTitle: 'Method Compile on class update should not warn about unused temps (3.0.79)'.
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #yes.
	self selectRowanSample1Class.
	self assertIsNil: (self methodListPresenter list
				detect: [:methodService | methodService selector = #methodWithUnusedTemp]
				ifNone: []).
	self
		saveMethod: 'methodWithUnusedTemp  | unused | ^123'
		in: 'RowanSample1'
		category: 'other'.
	self
		saveClass: 'RowanSample1'
		superclass: 'Object'
		instVars: #('abc')
		package: 'RowanSample1-Core'.
	self assert: TestMessageBox plannedResult equals: #yes.	"no dialog was raised"
	
	[self denyIsNil: (self methodListPresenter list
				detect: [:methodService | methodService selector = #methodWithUnusedTemp]
				ifNone: [])]
			ensure: 
				[TestMessageBox disableJadeiteTestMessageBox.
				self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass]!

test_compileErrorDisplay
	| source |
	self testsIssue: #issue459 withTitle: 'CompileWarnings should be more noticable ... '.
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	source := 'test1 self assert: RowanSample1 new foo = ''abc'.	"won't compile"
	self methodSourcePresenter value: source.
	self assert: self methodSourcePresenter isModified.
	self projectsPresenter editSaveMethod. 
	
	[self assert: self methodSourcePresenter view selectionRange equals: (37 to: 47).
	self assert: self projectsPresenter statusBarText view forecolor equals: Color black.
	self assert: self projectsPresenter statusBarText view backcolor equals: Color red faded]
			ensure: [self unloadSampleProject]!

test_confirmationDialogDuringCompileClassExistingInAnotherPackage
	self testsIssue: #issue516 withTitle: 'Rename instance variable with accessor method is... wonky'.
	self
		assert: (session executeString: '(Rowan image symbolList resolveSymbol: #RowanSample1Test) notNil').
	self selectRowanSample1Class.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[TestMessageBox plannedResult: #no.	"don't create class"
	self
		saveClass: 'RowanSample1Test'
		superclass: 'Object'
		instVars: #('erbleldy')
		package: 'RowanSample1-Core'.	"this will force a confirmation dialog"
	self
		assert: (session executeString: '(Rowan image symbolList resolveSymbol: #RowanSample1Test) notNil').	"class still exists"
	self selectRowanSample1Test.
	self assert: self classListPresenter selection name equals: 'RowanSample1Test'.
	self assert: self packageListPresenter selection name equals: 'RowanSample1-Tests'	"class still in test package"]
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

test_dontDuplicateBreakpoints
	| breakpointBrowser |
	self testsIssue: #issue533
		withTitle: 'Breakpoint browser seems muddled: method browser with duplicate methods'.
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	self projectsPresenter setBreakPointAt: 1 in: self projectsPresenter.
	self projectsPresenter setBreakPointAt: 2 in: self projectsPresenter.
	self assert: self methodListPresenter selection breakPoints size = 2.
	self assert: self methodListPresenter selection breakPoints = #(1 2) asOrderedCollection.
	
	[breakpointBrowser := self projectsPresenter browseBreakpoints.
	self assert: breakpointBrowser primaryPresenter methodListPresenter methodListPresenter list size equals: 1.
	self assert: breakpointBrowser primaryPresenter methodListPresenter selection selector = #test1.
	self assert: breakpointBrowser primaryPresenter methodListPresenter selection breakPoints = #(1 2) asOrderedCollection]
			ensure: 
				[breakpointBrowser view close.
				self projectsPresenter clearMethodBreakpoints]!

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

test_reformatIllegalSource
	self testsIssue: #issue345 withTitle: 'Jadeite format option (server ready) #345'.
	self selectRowanSample1Test.
	self
		saveMethod: 'reformatSourceTemporaryMethod ^#test'
		in: 'RowanSample1Test'
		category: 'other'.
	self selectMethodNamed: #reformatSourceTemporaryMethod.
	
	[self assert: self methodSourcePresenter value equals: 'reformatSourceTemporaryMethod ^#test'.
	self methodSourcePresenter value: 'reformatSourceTemporaryMethod ^#'.
	self projectsPresenter reformatSource.
	self assert: self projectsPresenter statusBarText value
		equals: 'Reformat failed. Illegal source' replaceCrLfWithLf.
	self assert: self projectsPresenter statusBarText view backcolor equals: Color red faded.
	self assert: self methodSourcePresenter view isModified.
	self assert: self methodSourcePresenter value equals: 'reformatSourceTemporaryMethod ^#'	"unchanged"]
			ensure: [self methodSourcePresenter view isModified: false]!

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

test_reformatSourceIsUndoable
	self testsIssue: #issue550
		withTitle: '"Reformat source" without save is not working right in method browsers (3.0.78)'.
	self selectRowanSample1Test.
	self
		saveMethod: 'reformatSourceTemporaryMethod | abc | abc := #abc. ^abc'
		in: 'RowanSample1Test'
		category: 'other'.
	
	[self selectMethodNamed: #reformatSourceTemporaryMethod.
	self assert: self methodSourcePresenter value
		equals: 'reformatSourceTemporaryMethod | abc | abc := #abc. ^abc'.
	self projectsPresenter reformatSource.
	self assert: self methodSourcePresenter view isModified.
	self assert: self methodSourcePresenter value
		equals: 'reformatSourceTemporaryMethod
  | abc |
  abc := #''abc''.
  ^ abc' replaceCrLfWithLf.
	self methodSourcePresenter view undo.
	self assert: self methodSourcePresenter value
		equals: 'reformatSourceTemporaryMethod | abc | abc := #abc. ^abc']
			ensure: [self projectsPresenter removeMethods: self classListPresenter selections]!

test_reloadAfterClassCompile
	self testsIssue: #issue516 withTitle: 'Rename instance variable with accessor method is... wonky'.
	self selectRowanSample1Test.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[TestMessageBox plannedResult: #yes.
	self
		saveClass: 'RowanSample1Test'
		superclass: 'TestCase'
		instVars: #('erbleldy')
		package: 'RowanSample1-Tests'.
	self assert: self classListPresenter selection version equals: 2.
	self projectsPresenter loadProjects.
	self assert: self classListPresenter selection version equals: 3	"see https://github.com/GemTalk/Rowan/issues/506"]
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

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
			ensure: [self destroy: secondBrowser]! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_abstractTestsShown!public!test sunit tab!tests! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_classCopy!public!test class list!test sunit tab!tests! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_comparisonTabMultimethod!public!test comparison tab! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_comparisonTabNoMethodSelected!public!test comparison tab! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_comparisonTabSuperclass!public!test comparison tab! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_compileClass!public!test compiling!tests! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_compileClassCompilerError!public!test compiling!tests! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_compileClassDirtiesPackageAndProject!public!test compiling! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_compileClassExistingInAnotherPackage!public!test compiling!tests! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_compileClassWithMethodWarnings!public!test compiling!tests! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_compileErrorDisplay!public!test compiling!tests! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_confirmationDialogDuringCompileClassExistingInAnotherPackage!public!test compiling!tests! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_dontDuplicateBreakpoints!public!test breakpoints! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_doubleClickIncludesColon!public!test source! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_findMethodDisabled!public!test find!test menus!test sunit tab!tests! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_modifiedSourceShouldNotChange!public!test two browsers!tests! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_modifiedSourceShouldNotChangeMethodList!public!test two browsers!tests! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_openNewBrowserTabWhileSUnitTabSelected!public!test sunit tab!tests! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_reformatIllegalSource!public!test source! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_reformatSource!public!test source! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_reformatSourceAppliesOnlyToCurrentBrowser!public!test source! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_reformatSourceIsUndoable!public!test source! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_reloadAfterClassCompile!public!test compiling!tests! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_sunitBarEnabledOnEntry!public!test sunit tab!tests! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_sunitBarEnabledOnReEntry!public!test sunit tab!tests! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_sunitBrowserForTestClass!public!test menus!test sunit tab!tests! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_sunitBrowserIsEnabledForTestClass!public!test menus!test sunit tab!tests! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_sunitBrowserNoSelectedTest!public!test menus!test sunit tab!tests! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_sunitCtrlB!public!test sunit tab!tests! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_sunitInheritedTests!public!test sunit tab!tests! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_sunitOnlyRunTestMethods!public!test sunit tab! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_sunitRunAndMeasureTime!public!test sunit tab!tests! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_sunitRunSelected!public!test sunit tab!tests! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_sunitTabCanRefresh!public!test menus!test sunit tab!tests! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_sUnitTabHandlesShortSelector!public!test class hierarchy!test sunit tab!tests! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_sUnitTabRefresh!public!test menus!test sunit tab!tests! !
!JadeiteProjectBrowserLowerTabsTestCase categoriesFor: #test_sunitUpdatesProperly!public!test sunit tab!tests! !

