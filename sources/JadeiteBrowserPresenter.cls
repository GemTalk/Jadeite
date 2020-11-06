"Filed out from Dolphin Smalltalk 7"!

JadeiteProjectsBrowserPresenter subclass: #JadeiteBrowserPresenter
	instanceVariableNames: 'dictionaryPresenter packageDictionaryCards globalsTab autoCommitButton search previousTabViewArrangement previousTopViewArrangement specEditor componentListPresenter'
	classVariableNames: ''
	poolDictionaries: 'ScintillaConstants'
	classInstanceVariableNames: ''!
JadeiteBrowserPresenter guid: (GUID fromString: '{c313bf86-bb5a-44fc-8c18-2671e1ac39a7}')!
JadeiteBrowserPresenter comment: ''!
!JadeiteBrowserPresenter categoriesForClass!Unclassified! !
!JadeiteBrowserPresenter methodsFor!

abortTransaction
	super abortTransaction.
	self autoCommit: (autoCommit value == #failed ifTrue: [true] ifFalse: [autoCommit value])!

addDictionary
	| newDictionaryName |
	(newDictionaryName := Prompter prompt: 'Enter new dictionary name:') isNil ifTrue: [^self].
	newDictionaryName isEmpty ifTrue: [^MessageBox notify: 'Blank dictionary names not allowed'].
	(dictionaryPresenter list detect: [:service | service name = newDictionaryName] ifNone: [])
		ifNotNil: [^MessageBox notify: 'Dictionary ' , newDictionaryName , ' already exists'].
	(MessageBox
		confirm: 'Really add dictionary ' , newDictionaryName , '? This will commit the transaction')
			ifTrue: [^self basicAddDictionaryNamed: newDictionaryName]!

additionalAccelerators
	^super additionalAccelerators , #(#(#insertIfFalse 'Ctrl+Shift+D') #(#insertIfTrue 'Ctrl+Shift+T'))!

addNoneProject
	(projectListPresenter list includes: RowanProjectService noneProject)
		ifFalse: [projectListPresenter model add: RowanProjectService noneProject]!

addSystemBrowser
	| browser position |
	position := self topShell view position.	"don't let default position takeover when adding tab"
	browser := self topShell addSystemBrowser.
	self makeSameSelectionsIn: browser currentCard as: self.
	self topShell view position: position.
	^browser!

allSelectedProjectsDirty
	^self basicAllSelectedProjectsDirty: projectListPresenter!

auditProject
	| answeringService workspace projectName |
	projectName := projectListPresenter selection name.
	answeringService := RowanAnsweringService new
				command: #auditProjectNamed:;
				commandArgs: (Array with: projectName).
	BrowserUpdate current issueCommands: (Array with: answeringService) session: self gciSession.
	workspace := JadeWorkspace showOnSession: self gciSession.
	workspace updateCaption: 'Audit Report for project ' , projectName.
	workspace model value: answeringService answer.
	^workspace!

basicAddDictionaryNamed: newDictionaryName
	| insertionIndex dictionaryService |
	insertionIndex := dictionaryPresenter selectionByIndex = 0
				ifTrue: [dictionaryPresenter list size + 1]
				ifFalse: [dictionaryPresenter selectionByIndex + 1].
	dictionaryService := RowanDictionaryService new name: newDictionaryName.
	dictionaryService
		command: #insertAt:;
		commandArgs: (Array with: insertionIndex).
	self issueCommand: (Array with: dictionaryService).
	dictionaryPresenter
		selection: (dictionaryPresenter list detect: [:newService | newService name = newDictionaryName])!

basicDictionaryTabLabel
	| label |
	label := projectListPresenter selection name.
	label := self shouldShowNoneTabLabel ifTrue: [label] ifFalse: [dictionaryPresenter selection name].
	^self selectedClass ifNil: [label] ifNotNil: [self selectedClass name]!

basicProjectTabLabel
	projectListPresenter selections isEmpty ifTrue: [^'Projects'].
	self isNoneProjectSelected ifFalse: [^super basicProjectTabLabel].
	^self basicDictionaryTabLabel!

basicRemoveClass: theClassService
	| service parentNode |
	self isHierarchyTabSelected
		ifTrue: [parentNode := classHierarchyPresenter model parentNodeOf: theClassService].
	service := self isNoneProjectSelected
				ifTrue: [dictionaryPresenter selection]
				ifFalse: [packageListPresenter selection].
	service
		command: #removeClass:;
		commandArgs: (Array with: theClassService).
	self issueCommand: (Array with: service).
	classListPresenter model: classListPresenter model.	"force a gui update"
	self isHierarchyTabSelected
		ifTrue: 
			[classHierarchyPresenter model: classHierarchyPresenter model.
			classHierarchyPresenter selection: (classHierarchyPresenter model asBag
						detect: [:classService | classService name = parentNode object name])].
	self selectedClass
		ifNil: [self resetClassTemplate	"just emptied the last class in the package"]
		ifNotNil: 
			[classDefinitionPresenter value: self selectedClass template.
			self resetClassDefinitionPane]!

basicRemoveDictionaries: dictionaryNames
	| browserService |
	browserService := RowanBrowserService new.
	browserService
		command: #removeDictionariesNamed:;
		commandArgs: (Array with: dictionaryNames).
	self issueCommand: (Array with: browserService)!

basicRemoveGlobal: qualifiedString
	| symbol rs dictionaryService globalDictionaryName |
	rs := ReadStream on: qualifiedString.
	globalDictionaryName := rs upTo: $..
	dictionaryService := dictionaryPresenter list
				detect: [:service | service name = globalDictionaryName].
	symbol := rs upToEnd asSymbol.
	dictionaryService
		command: #removeGlobalNamed:;
		commandArgs: (Array with: symbol).
	self issueCommand: (Array with: dictionaryService).
	self removeGlobalsTab.
	self buildGlobalsTab!

basicUnloadProjects: projectNames
	super basicUnloadProjects: projectNames.
	dictionaryPresenter model: ListModel new!

browseBreakpoints
	| browser |
	browser := JadeiteBreakpointBrowser showOnSession: self gciSession.
	browser breakpointListPresenter
		selections: (browser methodServicesWithBreakpoints intersection: methodListPresenter selections).
	^browser!

browseClassReferences
	^JadePresenter browseClassReferences: self selectedClassName session: self gciSession!

browseGlobalClass
	| selection |
	selection := globalsTab selectionIfNone: [^self].
	^self openBrowserInNewTab: false on: (RowanClassService new name: (selection at: 2))!

browseGlobalReferences
	| selection string |
	selection := globalsTab selectionIfNone: [^self].
	string := self selectedGlobalName: selection.
	^JadePresenter browseSymbolReferencesTo: '#' , string session: gciSession!

browseInstVarReaders
	^JadePresenter
		browseInstVarReaders: variableListPresenter selection
		in: self selectedClassName
		session: self gciSession!

browseInstVarWriters
	^JadePresenter
		browseInstVarWriters: variableListPresenter selection
		in: self selectedClassName
		session: self gciSession!

browseMethodHistory
	^JadeiteMethodHistoryBrowser showOnClass: self selectedClass
		selector: methodListPresenter selections first!

browseSelectedCategoryMethods
	"convenience menu item to display random methods in selected categories in a browser"

	| browser |
	self updateServices: methodListPresenter list.	"If categories are selected, only the methods in those categories will be visible"
	(browser := JadeiteMethodListBrowser showOnSession: gciSession) primaryPresenter
		methods: methodListPresenter list
		selecting: String new.
	browser updateCaption: 'Selected Methods in Categories - ' , categoryListPresenter list printString.
	^browser!

browseSelectedMethods
	"convenience menu item to display randomly grouped methods in a browser"

	| browser |
	self updateServices: methodListPresenter selections.
	(browser := JadeiteMethodListBrowser showOnSession: gciSession) primaryPresenter
		methods: methodListPresenter selections
		selecting: nil.
	browser updateCaption: 'Selected Methods'.
	^browser!

buildGlobalsTab
	| globalsTabView cardLabel |
	globalsTab
		ifNil: 
			[globalsTab := ListPresenter new.
			globalsTab
				when: #actionPerformed
				send: #inspectGlobal
				to: self.
			globalsTab parentPresenter: self textAreaTabs.
			globalsTabView := globalsTab createView: 'Editable list view'.
			globalsTabView backcolor: JadeiteTextStyles default colorForNoEdits.
			globalsTabView hasColumnHeaders: false.
			globalsTabView contextMenu: self globalsMenu.
			3 timesRepeat: [globalsTabView addColumn].
			1 to: 4
				do: 
					[:index |
					(globalsTabView allColumns at: index)
						isEditable: false;
						isAutoResize: true;
						getImageBlock: IconicListAbstract;
						getContentsBlock: [:each | each at: index]]]
		ifNotNil: [globalsTabView := globalsPresenter view].
	cardLabel := CardLabel text: 'Globals'.
	cardLabel iconBlock: [Icon fromId: (File composeStem: 'Dictionary' extension: 'ico')].
	globalsTabView
		arrangement: cardLabel;
		getImageBlock: nil;
		name: 'globalsTab'.
	classListPresenter list: ListModel new.
	self updateGlobalsTab!

buildProjectTab
	| projectInfoView cardLabel |
	projectInfoTab
		ifNil: 
			[projectInfoTab := ListPresenter new.
			projectInfoTab parentPresenter: self textAreaTabs.
			projectInfoView := projectInfoTab createView: 'Editable list view'.
			projectInfoView backcolor: JadeiteTextStyles default colorForNoEdits.
			projectInfoView
				contextMenu: self projectInfoMenu;
				hasColumnHeaders: false;
				hasGridLines: false;
				isMultiSelect: true.
			(projectInfoView allColumns at: 1)
				isEditable: false;
				width: 175;
				getContentsBlock: [:each | each at: 2].
			projectInfoView addColumn.
			(projectInfoView allColumns at: 2)
				isEditable: false;
				isAutoResize: true;
				getContentsBlock: [:each | (each at: 2) ifNil: [String new] ifNotNil: [:iv | (each at: 1) instVarNamed: iv]]]
		ifNotNil: [projectInfoView := projectInfoTab view].
	cardLabel := CardLabel text: 'Project'.
	cardLabel iconBlock: [Icon fromId: (File composeStem: 'Collection' extension: 'ico')].
	projectInfoView
		arrangement: cardLabel;
		getImageBlock: nil;
		name: 'projectInfoTab'.
	^projectInfoView!

categoriesMenuStrings

	false ifTrue: [
		self addMethodCategory; renameMethodCategory; removeMethodCategories; fileOutCategories.
	].
	^#(
		'&Categories'
		'&Add//addMethodCategory'
		'&Rename//renameMethodCategory'
		'&Remove//removeMethodCategories'
		'-'
		'&Browse category methods//browseSelectedCategoryMethods'
		'-'
		'&File out categories//fileOutCategories'
	)
!

checkout
	projectListPresenter selection checkoutUsing: self!

checkoutTag
	| selection |
	selection := projectListPresenter selection.
	self checkoutTag: selection!

classCommentChanged
	inUpdate ifTrue: [^self].
	self selectedClass ifNil: [^self].
	classCommentPresenter value = self selectedClass comment
		ifTrue: 
			[classCommentPresenter view
				backcolor: JadeiteTextStyles default colorForNoEdits;
				isModified: false;
				yourself]
		ifFalse: 
			[classCommentPresenter view
				backcolor: JadeiteTextStyles default colorForUnsavedEdits;
				isModified: true;
				yourself]!

classesMenuStrings
	| definedLabel containedDictionaryLabel menuStrings |
	false
		ifTrue: 
			[self
				browseClassReferences;
				fileOutClass;
				addSubclass;
				copyClass;
				renameClass;
				removeClass;
				removePriorVersions;
				showSUnitBrowserOnClass].
	definedLabel := self definedClassMenuItemLabel.
	containedDictionaryLabel := self containedDictionaryLabel.
	menuStrings := #('&Classes' '&Browse Class References//browseClassReferences' 'Browse SUnit//showSUnitBrowserOnClass' '&File Out Class//fileOutClass' 'Add &Subclass//addSubclass' '&Rename ... //renameClass' 'Copy ...//copyClass' '&Remove//removeClass' '-')
				asOrderedCollection.
	menuStrings add: '&Expand Full Hierarchy//expandFullHierarchy'.
	menuStrings add: '-'.
	menuStrings addLast: definedLabel , '//gotoClassDefinedPackage'.
	menuStrings addLast: containedDictionaryLabel , '//gotoDictionary'.
	^menuStrings!

comparisonPresenter

	^comparisonPresenter!

contextObject
	^self selectedClass ifNil: [^gciSession oopNil value] ifNotNil: [:classService | classService oop]!

createComponents
	super createComponents.
	dictionaryPresenter := self add: ListPresenter new name: 'dictionariesList'.
	packageDictionaryCards := self add: Presenter new name: 'packageDictionaryCards'.
	autoCommitButton := self add: Presenter new name: 'autoCommitButton'.
	specEditor := self add: JadeitePropertyInspector new name: 'specEditor'.
	componentListPresenter := self add: TreeListPresenter new name: 'componentTree'!

createListViewFor: newCard
	"Editable because creating the desired ListView gave 
	mysterious errors when connecting the view."

	| listView |
	listView := newCard createView: 'Editable list view'.
	listView
		isMultiSelect: true;
		hasColumnHeaders: false;
		hasGridLines: false.
	(listView allColumns at: 1)
		isEditable: false;
		getImageBlock: IconicListAbstract;
		isAutoResize: true;
		customDrawBlock: [:each | each item displayStringFor: each].
	^listView!

createNewProject
	| projectName |
	projectName := Prompter prompt: 'Enter Project Name' caption: 'Create new Rowan project'.
	projectName
		ifNotNil: 
			[self newProjectNamed: projectName.
			self selectProjectNamed: projectName]!

createSchematicWiring
	super createSchematicWiring.
	dictionaryPresenter
		when: #selectionChanged
		send: #updateDictionary
		to: self.
	classCommentPresenter
		when: #valueChanged
		send: #classCommentChanged
		to: self.
	classListPresenter
		when: #selectionChanged
		send: #updateTabLabel
		to: self.
	classHierarchyPresenter
		when: #selectionChanged
		send: #updateTabLabel
		to: self!

createSchematicWiringForMethodSource
	super createSchematicWiringForMethodSource.
	methodSourcePresenter
		when: #textChanged
			send: #updateMethodSourceColor
			to: self;
		when: #valueChanged
			send: #methodValueChanged
			to: self;
		when: #autoComplete:startingAt:accept:
			send: #onAutoComplete:startingAt:accept:
			to: self search;
		when: #timerTick:
			send: #onTimerTick:
			to: self search;
		when: #charAdded:
			send: #onCharAdded:
			to: self search!

debug
	self jadeDebug!

dictionaryMenu
	^Menu fromStrings: self dictionaryMenuStrings!

dictionaryMenuStrings
	self rowanFixMe.	"this really is a cumbersome way to build a menu."
	0 == 1
		ifTrue: 
			[self
				addDictionary;
				removeDictionaries].
	^#('Dictionaries' 'Insert Dictionary//addDictionary' 'Remove Dictionaries//removeDictionaries')!

dictionaryPresenter
	^dictionaryPresenter!

displayStringFor: methodService in: displayThing
	methodService isExtension
		ifTrue: 
			[displayThing forecolor: Color darkMagenta.
			methodService inSelectedPackage ifFalse: [displayThing font beUnderlined]]!

displayVariable: displayThing
	self selectedClass
		ifNotNil: 
			[:selectedClass |
			(selectedClass instVarNames includes: displayThing item asSymbol)
				ifTrue: [displayThing font beBold]].
	^displayThing!

editDelete

	View focus clearSelection.
	self methodValueChanged.
!

editRevert
	self isOkayToChange
		ifTrue: 
			[methodSourcePresenter value: methodListPresenter selection source.
			self displayNoMods: methodSourcePresenter]!

editSaveClass
	"a two stage class compilation is used. First stage compiles
	the class and stores an anonymous method to be used in 
	stage  two. If a compile error occurs, it is handled nicely. 
	If a compile error happens during the method recompilation
	a debugger is raised as not much information is available 
	without a stack."

	| browserService |
	browserService := RowanBrowserService new.
	browserService
		command: #compileClass:;
		commandArgs: (Array with: classDefinitionPresenter value).
	browserService selectedClass: self selectedClass name. 
	[self issueCommand: (Array with: browserService)] on: Error
		do: 
			[:ex |
			(ex isKindOf: GsCompileError)
				ifTrue: [self handleClassCompileError: ex]
				ifFalse: [self statusBarText: 'ERROR: ' , ex messageText].
			^self].
	
	[browserService
		command: #recompileMethodsAfterClassCompilation;
		commandArgs: #().
	self issueCommand: (Array with: browserService)]
			on: GsCompileError
			do: [:ex | ^self showMethodRecompilationError: ex. ].
	self resetClassDefinitionPane.
	self updateAfterFindClass: browserService selectedClass!

editSaveMethod
	| selection |
	selection := self selectedClass.
	selection ifNil: [^self].
	selection meta: self isClassSideSelected.
	self editSaveMethod: selection.
	self updateSUnitTab.
	self redrawAllViews.
	self updateSystemTab.!

editSaveMethod: classService
	| compileResult |
	compileResult := self
				editSaveMethod: classService
				in: methodSourcePresenter
				category: self targetCategory.
	compileResult == false
		ifTrue: [self updateService: classService	"If we got a compile error our methods need a refresh"].
	self statusBarText value ifNotNil:[:text | text isEmpty ifFalse:[^self]].  "don't reselect methods when status bar is full so as not to upset the compile information"
	classService selectedMethods
		ifNotNil: 
			[:methodServices |
			methodServices notEmpty
				ifTrue: 
					["there will be no method selected on a compiler error"
					self selectMethodsFrom: classService]]!

expandFullAt: classService
	Cursor wait showWhile: 
			[classService command: #fullHierarchy.
			self issueCommand: (Array with: classService).
			self selectClassNamed: classService name.
			classHierarchyPresenter view expandAll]!

expandFullHierarchy
	self expandFullAt: self selectedClass!

globalsMenu
	^Menu fromStrings: self globalsMenuStrings!

globalsMenuStrings
	self rowanFixMe.	"this really is a cumbersome way to build a menu."
	0 == 1
		ifTrue: 
			[self
				inspectGlobal;
				browseGlobalClass;
				browseGlobalReferences;
				removeGlobal].
	^#('Projects' 'Inspect//inspectGlobal' 'Browse Class//browseGlobalClass' 'Browse References//browseGlobalReferences' 'Remove Global//removeGlobal')!

globalsTab
	^globalsTab!

gotoDictionary
	" find will go to the class in the dictionary it lives"

	| selectedClass | 
	selectedClass := self selectedClass.
	self selectNoneProject.
	^self updateAfterFindClassInDictionary: selectedClass!

gotoDictionaryNamed: dictionaryName
	| dictionaryService |
	dictionaryService := dictionaryPresenter list detect: [:service | service name = dictionaryName]
				ifNone: [^self].
	dictionaryPresenter selections: (Array with: dictionaryService)!

insertCompileErrorText: string into: presenter
	"parameters ignored in this presenter"

	statusBarText value: string!

insertIfFalse
	^self insertIfFalse: methodSourcePresenter!

insertIfTrue
	^self insertIfTrue: methodSourcePresenter!

inspectGlobal
	| selection |
	selection := globalsTab selectionIfNone: [^self].
	^JadeInspector showOn: (OopType32 fromInteger: (selection at: 3)) session: gciSession!

inspectMethod
	| inspector |
	methodListPresenter selections isEmpty ifTrue: [^self].
	inspector := JadeiteInspector new gciSession: gciSession.
	^inspector inspect: (OopType64 fromInteger: methodListPresenter selections first oop)
		inContext: gciSession oopNil value!

inspectorContextObject

	^self contextObject!

isNoneProjectSelected
	^projectListPresenter selections includes: RowanProjectService noneProject!

isProjectItemEnabled: command
	(command = #refreshFromServer or: [command = #loadV2Project]) ifTrue: [^true].
	^projectListPresenter selections notEmpty
		and: [(projectListPresenter selections includes: RowanProjectService noneProject) not]!

isRowanProjectSelected
	^(self isNoneProjectSelected or: [projectListPresenter selections isEmpty]) not!

jadeInspect
	| inspector |
	inspector := JadeiteInspector new gciSession: gciSession.
	^inspector evaluateSelectedTextIn: methodSourcePresenter
		thenInspectInContext: self inspectorContextObject!

makeSameSelectionsIn: newPresenter as: previousPresenter
	| projectService packageService dictionaryService classService isMeta methodService |
	projectService := previousPresenter projectListPresenter selectionIfNone: [].
	packageService := previousPresenter packageListPresenter selectionIfNone: [].
	dictionaryService := previousPresenter dictionaryPresenter selectionIfNone: [].
	classService := previousPresenter selectedClass.
	classService
		ifNotNil: 
			[isMeta := classService meta.
			methodService := previousPresenter methodListPresenter selectionIfNone: []].
	projectService ifNil: [^self].
	newPresenter gotoProjectNamed: projectService name.
	packageService
		ifNil: 
			[dictionaryService
				ifNil: [^self]
				ifNotNil: [newPresenter gotoDictionaryNamed: dictionaryService name]]
		ifNotNil: [newPresenter gotoPackageNamed: packageService name].
	classService ifNil: [^self].
	newPresenter updateAfterFindClass: classService.
	previousPresenter isHierarchyTabSelected ifTrue: [newPresenter classHierarchyTabs lastCard].
	isMeta ifTrue: [newPresenter selectClassTab].
	methodService ifNil: [^self].
	newPresenter findMethod: methodService selector!

maxAutoCompleteListSize
	^50!

methodMenu: aMenu
	self methodMenuBreak: aMenu!

methodSelectionChanged
	self setStatusBarDefault.
	self updateMethodSource.
	methodListPresenter selections size = 1 ifTrue: [self selectMethodSourceTab].
	self isComparisonTabSelected ifTrue: [^self].
	self topShell cardsPresenter view currentCard presenter == self
		ifTrue: [methodSourcePresenter ensureVisible].
	methodListPresenter selections size > 1
		ifTrue: 
			[self updateMultiMethodComparison.
			self displayMultipleCategories.
			self selectComparisonTab]!

methodsMenuStrings
	false
		ifTrue: 
			["This helps us find senders"
			self
				browseBreakpointList;
				browseImplementors;
				browseImplementorsOf;
				browseSenders;
				browseSendersOf;
				browseHierarchyImplementors;
				browseHierarchySenders;
				browseMethodsContaining;
				browseLiteralReferences;
				browseSelectedMethods;
				browseMethodHistory;
				inspectMethod;
				clearMethodBreakpoints;
				removeMethods;
				runMethodTests;
				fileOutMethods;
				findMethod;
				runMethodTests;
				gotoMethodDefinedPackage;
				runAll;
				runSelected].
	^#('&Methods' 'Browse &Implementors//browseImplementors' 'Browse Implementors of ...//browseImplementorsOf' 'Browse &Senders//browseSenders' 'Browse Senders of ...//browseSendersOf' '-' 'Browse Hierarchy Implementors//browseHierarchyImplementors' 'Browse Hierarchy Senders//browseHierarchySenders' '-' 'Browse Methods &Containing ...//browseMethodsContaining' 'Browse Literal References ...//browseLiteralReferences' 'Browse Selected Methods//browseSelectedMethods' 'Browse Method History//browseMethodHistory' 'Inspect//inspectMethod' '-' 'Browse Breakpoints//browseBreakpoints' 'Clear Method Breakpoints//clearMethodBreakpoints' '-' 'Find Method .../Ctrl+Shift+M/findMethod' '-' '&Remove Method(s) ...//removeMethods' '-' 'Run All Tests/Ctrl+Shift+A/runAll' 'Run Selected Test(s)/Ctrl+Shift+S/runMethodTests' 'Debug Selected &Test(s)/Ctrl+B/runMethodTests' '-' 'Go To Defining Package//gotoMethodDefinedPackage')!

methodsUpdate: classService
	classService meta = self isClassSideSelected ifFalse: [^self].
	classListPresenter list isEmpty ifTrue: [classService initializePresenterList: methodListPresenter].	
	classService displayMethodsOn: methodListPresenter browser: self!

methodToReformat
	^methodListPresenter selectionIfNone: [RowanMethodService new]!

methodValueChanged
	inUpdate ifTrue: [^self].
	self methodSourceEqual
		ifTrue: 
			[methodSourcePresenter view
				backcolor: JadeiteTextStyles default colorForNoEdits;
				isModified: false;
				yourself.
			self updateMethodStepPoints.
			self statusBarText: '']
		ifFalse: 
			[methodSourcePresenter view
				backcolor: JadeiteTextStyles default colorForUnsavedEdits;
				clearContainerIndicators;
				yourself].
	self updateSystemTab.!

newProjectNamed: projectName
	RowanBrowserService new
		newProjectNamed: projectName
		session: self gciSession
		windowHandle: self view handle value!

noClassSelectedInEitherPresenter
	classListPresenter selectionIfNone: [classHierarchyPresenter selectionIfNone: [^true]].
	^false!

onDragMethod: aSession
	| list |
	list := methodListPresenter selections collect: 
					[:each |
					(aSession newDragObject: each)
						format: #method data: each;
						yourself].
	aSession
		dragObjects: list;
		supportedOperations: #(#move #copy);
		defaultOperation: #copy;
		yourself!

onViewOpened
	| inspectorService specModel |
	super onViewOpened.
	self showPackageList.
	self rowanFixMe.  "Have code to show spec service that needs to be finished"
	"specEditor isRootAspectVisible: false.
	inspectorService := RowanSpecificationService new
				executeThenInspect: 'RwSpecification fromUrl: ''file:/export//korea2/users/ewinger/shared/repos/Rowan/rowan/v2/proposed_specs/Rowan_proposed_2.ston'''
				context: self gciSession oopNil value
				session: self gciSession
				windowHandle: self view handle value.
	specModel := Dictionary new.
	inspectorService objects do: [:keyValue | specModel at: keyValue key put: keyValue value].
	specEditor model: specModel"!

openSourceStyler
	| textStyles |
	textStyles := super openSourceStyler.
	comparisonPresenter afterPresenter view textStyles: textStyles.
	comparisonPresenter beforePresenter view textStyles: textStyles!

openSpecFile
	specEditor model: (Array
				with: 1
				with: #abc
				with: $a
				with: true)!

packageDictionaryCards
	"for testing"

	^packageDictionaryCards!

possiblyClearProjectInfoTab
	self projectListPresenter
		selectionIfNone: [projectInfoTab ifNotNil: [:tab | tab list: ListModel new]]!

previousTabViewArrangement
	^previousTabViewArrangement!

previousTabViewArrangement: anObject
	previousTabViewArrangement := anObject!

previousTopViewArrangement
	^previousTopViewArrangement!

previousTopViewArrangement: anObject
	previousTopViewArrangement := anObject!

projectInfoMenu
	^Menu fromStrings: self projectInfoMenuStrings!

projectInfoMenuStrings
	self rowanFixMe.	"this really is a cumbersome way to build a menu."
	0 == 1
		ifTrue: 
			[self
				copyProjectInfo
				].
	^#('Dictionaries' 
	'Copy//copyProjectInfo'
	'Browse Commit In GitHub//openCommitInGitHub')!

projectMenu
	^Menu fromStrings: self projectMenuStrings!

projectMenuCommands
	^self projectMenu items collect: [:item | item command]!

projectMenuStrings
	self rowanFixMe.	"this really is a cumbersome way to build a menu."
	0 == 1
		ifTrue: 
			[self
				createNewProject;
				addPackage;
				loadV2Project;
				reloadV2Project; 
				unloadProjects;
				pullFromGit;
				gitCommit;
				pushToGit;
				projectChanges;
				writeProject;
				checkoutTag;
				checkout;
				auditProject;
				projectLog;
				refresh].
	^#('Projects' 'Create ...//createNewProject' 'Load Git Project ...//loadV2Project' 'Reload Project //reloadV2Project' 'Unload//unloadProjects' '-' 'Pull from Git//pullFromGit' 'Commit to Git ...//gitCommit' 'Push to Git//pushToGit' '-' '&Changes//projectChanges' 'Write//writeProject' 'Checkout Git Tag ...//checkoutTag' 'Checkout Git Branch ...//checkout' '-' '&Add Package...//addPackage' '-' 'Audit//auditProject' 'Git Log//projectLog' '&Refresh//refreshFromServer')!

protectedDictionaries
	^#('Published' 'Globals' 'UserGlobals')!

queryCommand: aCommandQuery
	| command |
	command := aCommandQuery command.
	(#(#inspectGlobal #browseGlobalClass #browseGlobalReferences) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: globalsTab selections isEmpty not.
			^true].
	(#(#removeDictionaries) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: self dictionaryPresenter selections notEmpty.
			^true].
	#browseMethodHistory = command
		ifTrue: 
			[| selections |
			selections := self methodListPresenter selections.
			aCommandQuery isEnabled: (selections size = 1 and: [selections first hasMethodHistory]).
			^true].
	(#(#reformatSource) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: self methodListPresenter selections size <= 1.
			^true].
	#gitCommit == command
		ifTrue: 
			[aCommandQuery isEnabled: self allSelectedProjectsDirty.
			^true].
	#createNewProject = command
		ifTrue: 
			[aCommandQuery isEnabled: true.
			^true].
	(self projectMenuCommands includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: (self isProjectItemEnabled: command).
			^true].
	#gotoDictionary = command
		ifTrue: 
			[self updateClassMenu: nil.
			self selectedClass
				ifNil: 
					[aCommandQuery isEnabled: false.
					^true].
			self isNoneProjectSelected
				ifTrue: 
					[aCommandQuery isEnabled: false.
					^true].
			aCommandQuery isEnabled: true.
			^true].
	(#(#browseInstVarReaders #browseInstVarWriters) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: self variableListPresenter selections size = 1.
			^true].
	#expandFullHierarchy = command
		ifTrue: 
			[aCommandQuery isEnabled: self isClassListTabSelected not.
			^true].
	#browseSelectedCategoryMethods = command
		ifTrue: 
			[aCommandQuery isEnabled: categoryListPresenter selections notEmpty.
			^true].
	#inspectMethod = command
		ifTrue: 
			[aCommandQuery isEnabled: methodListPresenter selections size = 1.
			^true].
	command == #editDelete
		ifTrue: 
			[aCommandQuery isEnabled: methodSourcePresenter hasSelection.
			^true].
	#checkoutTag == aCommandQuery command
		ifTrue: 
			[aCommandQuery isEnabled: self isNoneProjectSelected not.
			^true].
	^super queryCommand: aCommandQuery!

reformatSource
	| methodService |
	(methodService := self methodToReformat)
		source: methodSourcePresenter value;
		command: #reformatSource;
		commandArgs: Array new.
	[self issueCommand: (Array with: methodService)] on: Error
		do: 
			[:ex |
			self setCompileErrorColor.
			self statusBarText: 'Reformat failed. Illegal source'.
			^false].
	self methodSourcePresenter view performUndoableAction: 
			[self methodSourcePresenter view
				modifyText: [self methodSourcePresenter view sciSetText: methodService source]].
	methodSourcePresenter value: methodService source.
	methodSourcePresenter view isModified: true.
	self methodValueChanged.
	self setStatusBarDefault.
	self statusBarText: String new.
	^methodSourcePresenter value!

refresh
	self refreshFromServer!

refreshClass
	| selection presenter |
	presenter := self isClassListTabSelected
				ifTrue: [classListPresenter]
				ifFalse: [classHierarchyPresenter].
	self setMethodFilterFor: presenter.
	selection := presenter selectionIfNone: 
					[self noClassSelectedInEitherPresenter
						ifTrue: 
							[self resetClassTemplate.
							self resetDefinedClassPackage.
							categoryListPresenter clear.
							variableListPresenter clear.
							^methodListPresenter clear]
						ifFalse: [^self]].
	BrowserUpdate current isApplyingUpdates ifTrue: [^self].
	selection wasRemoved ifTrue: [^self].
	selection meta: self isClassSideSelected.
	self isNoneProjectSelected
		ifFalse: [selection selectedPackageServices: packageListPresenter selections browser: self].
	selection
		updateAfterCommand: false;
		command: #fastRefresh.
	self issueCommand: (Array with: selection).
	selection updateAfterCommand: true.
	self updateClassInfo!

refreshFromServer
	| services |
	services := OrderedCollection with: RowanBrowserService new.
	services addAll: projectListPresenter selections.
	services addAll: packageListPresenter selections.
	classListPresenter selectionOrNil ifNotNil: [:classService | services add: classService].
	classHierarchyPresenter selectionOrNil ifNotNil: [:classService | services add: classService].
	services addAll: methodListPresenter selections.
	self updateServices: services.
	self updateSUnitTab.
	self redrawAllViews!

refreshFromServerAfterAbort: browserService
	self autoCommit: (autoCommit value == #failed ifTrue: [true] ifFalse: [autoCommit value])!

registerPresentersForUpdates
	super registerPresentersForUpdates.
	BrowserUpdate current
		register: dictionaryPresenter selector: #dictionaryListUpdate:;
		register: classListPresenter
			selector: #renamedClass:browser:
			browser: self;
		register: classHierarchyPresenter
			selector: #renamedClassInHierarchy:browser:
			browser: self;
		register: classListPresenter selector: #addCachedSymbols:; 
		register: componentListPresenter
			selector: #componentsUpdate:browser:
			browser: self!

reloadV2Project
	"intention revealing selector"
	^self loadProjects!

removeAppropriateTab
	self isNoneProjectSelected ifTrue: [self removeProjectTab] ifFalse: [self removeGlobalsTab]!

removeDictionaries
	| dictionaryNames |
	dictionaryPresenter selections isEmpty ifTrue: [^self].
	dictionaryNames := dictionaryPresenter selections
				collect: [:dictionaryService | dictionaryService name].
	(dictionaryNames includesAnyOf: self protectedDictionaries)
		ifTrue: 
			[^MessageBox notify: 'Cannot remove protected dictionaries ' , self protectedDictionaries printString].
	(MessageBox
		confirm: 'Really remove dictionary(s) ' , (dictionaryNames fold: [:a :b | a , ' ' , b]) , ' ?
This will commit the transaction.')
			ifFalse: [^self].
	self basicRemoveDictionaries: dictionaryNames!

removeGlobal
	| selection string |
	selection := globalsTab selectionIfNone: [^self].
	string := self selectedGlobalName: selection.
	MessageBox confirm: 'Really remove #' , string , '?'.
	^self basicRemoveGlobal: (selection at: 1)!

removeGlobalsTab
	| globalsTabView |
	globalsTabView := self view viewNamed: 'globalsTab' ifNone: [nil].
	globalsTabView ifNotNil: [self textAreaTabs removeSubView: globalsTabView].
	globalsTab := nil!

removeProjectTab
	| projectInfoView |
	projectInfoView := self view viewNamed: 'projectInfoTab' ifNone: [nil].
	projectInfoView ifNotNil: [self textAreaTabs removeSubView: projectInfoView].
	projectInfoTab := nil!

resetClassTemplate
	| presenter |
	presenter := self isNoneProjectSelected
				ifTrue: [dictionaryPresenter]
				ifFalse: [packageListPresenter].
	presenter list isEmpty
		ifTrue: 
			[classDefinitionPresenter value: String new.
			classDefinitionPresenter view isModified: false.
			^self].
	classDefinitionPresenter value: (presenter selections isEmpty
				ifTrue: [String new]
				ifFalse: [presenter selections first defaultTemplate]).
	self resetClassDefinitionPane!

resetFontSize
	self setFontSizeTo: nil!

runAll
	self selectSUnitTab.
	self sunitPresenter runAll!

runSelected
	^self runMethodTests. !

search
	^search ifNil: [search := JadeiteSearch on: methodSourcePresenter view session: self gciSession]!

selectDictionaryNamed: dictionaryName
	| dictionaryService |
	dictionaryService := dictionaryPresenter list detect: [:service | service name = dictionaryName]
				ifNone: [^self].
	dictionaryPresenter selections: (Array with: dictionaryService)!

selectedDictionaryNames
	^dictionaryPresenter selections collect: [:dictionaryService | dictionaryService name]!

selectedGlobalName: selection
	| string rs |
	rs := ReadStream on: (selection at: 1).
	rs upTo: $..
	string := rs upToEnd.
	^string!

selectedPackageNames
	^packageListPresenter selections collect: [:packageService | packageService name]!

selectedPackageServices
	^packageListPresenter selections!

selectNoneProject
	projectListPresenter selection: (projectListPresenter list
				detect: [:projectService | projectService name = RowanProjectService noneProject name])!

selectPackageNamed: packageName
	| answeringService packageService selectedPackage |
	answeringService := RowanAnsweringService new.
	answeringService
		command: #newPackageNamed:;
		commandArgs: (Array with: packageName).
	self issueCommand: (Array with: answeringService).
	packageService := answeringService answer.
	self selectProjectNamed: packageService projectName.
	selectedPackage := packageListPresenter list detect: [:pkgService | pkgService name = packageName]
				ifNone: [^self].
	packageListPresenter selections: (Array with: selectedPackage).!

selectProjectNamed: projectName
	| projectService |
	projectService := projectListPresenter list detect: [:service | service name = projectName]
				ifNone: [^self].
	projectListPresenter selections: (Array with: projectService)!

setCompileErrorColor
	statusBarText view backcolor: Color red faded!

setCompileWarningColor
	statusBarText view backcolor: Color yellow faded!

setFontSize
	| fontSize |
	fontSize := IntegerPrompter create
				caption: 'Update Text Pane Font Size';
				prompt: 'Enter Font Size:';
				interval: (1 to: 50);
				showModal.
	self setFontSizeTo: fontSize!

setFontSizeTo: anIntegerOrNil
	| textStyles |
	textStyles := JadeiteTextStyles default textStyles.
	textStyles do: [:textStyle | textStyle pointSize: anIntegerOrNil].
	JadeiteScintillaView allInstances do: 
			[:scintillaView |
			( scintillaView class canUnderstand: #textStyles:)
				ifTrue: [scintillaView textStyles: textStyles]].
	!

setStatusBarDefault
	statusBarText view backcolor: statusBarText view defaultBackcolor!

shouldShowNoneTabLabel
	^dictionaryPresenter list isEmpty
		or: [dictionaryPresenter selections isEmpty or: [dictionaryPresenter selections size > 1]]!

showDictionaryList
	| newCard |
	(packageDictionaryCards view cards includes: packageListPresenter view)
		ifTrue: 
			[packageDictionaryCards view removeSubView: packageListPresenter view.
			packageListPresenter list: ListModel new].
	packageDictionaryCards view cards isEmpty
		ifTrue: 
			[newCard := packageDictionaryCards add: dictionaryPresenter.
			self createListViewFor: newCard.
			packageDictionaryCards view cards first arrangement: 'Dictionaries'.
			dictionaryPresenter view contextMenu: self dictionaryMenu.
			classListPresenter list: ListModel new.
			classHierarchyPresenter model: TreeModel new].
	self updateDictionaries!

showPackageList
	| newCard |
	(packageDictionaryCards view cards includes: dictionaryPresenter view)
		ifTrue: 
			[packageDictionaryCards view removeSubView: dictionaryPresenter view.
			dictionaryPresenter list: ListModel new].
	packageDictionaryCards view cards isEmpty
		ifTrue: 
			[newCard := packageDictionaryCards add: packageListPresenter.
			self createListViewFor: newCard.
			packageDictionaryCards view cards first arrangement: 'Packages'.
			self setupPackageMenu.
			classListPresenter list: ListModel new.
			classHierarchyPresenter model: TreeModel new]!

statusBarText
	
	^statusBarText !

statusBarText: string
	statusBarText value: string!

updateAfterFindClass: classService
	| projectService |
	classService ifNil: [^self].
	self updateService: classService.
	projectService := projectListPresenter list
				detect: [:service | service name = classService projectName]
				ifNone: 
					[^self	"may not be found if class is not in symbol list but class visible in a debugger (currently)"].
	projectListPresenter selections: (Array with: projectService).
	projectService = RowanProjectService noneProject
		ifTrue: [self updateAfterFindClassInDictionary: classService].
	self updateAfterFindClassInPackage: classService!

updateAfterFindClassInDictionary: classService
	| dictionaryService |
	Cursor wait showWhile: 
			[dictionaryService := dictionaryPresenter list
						detect: [:service | service name = classService dictionaryName]
						ifNone: [^self].
			dictionaryPresenter selections: (Array with: dictionaryService).
			self isClassListTabSelected
				ifTrue: [self selectClassNamed: classService name asString]
				ifFalse: 
					[self selectClassInClassListNamed: classService name.
					self updateHierarchy]]!

updateAfterFindClassInPackage: classService
	| packageService |
	packageService := packageListPresenter list
				detect: [:service | service name = classService definedPackageName]
				ifNone: [^self].
	packageListPresenter selections: (Array with: packageService).
	classService meta == true ifTrue: [self selectClassTab].
	self isClassListTabSelected
		ifTrue: [self selectClassNamed: classService name asString]
		ifFalse: 
			[self selectClassInClassListNamed: classService name.
			self updateHierarchy]!

updateAutoCommit
	| autoCommitButtonView |
	autoCommitButtonView := autoCommitButton view. 
	autoCommit value == #failed ifTrue: [^autoCommitButtonView backcolor: Color red].
	autoCommit value
		ifTrue: [autoCommitButtonView backcolor: Color green]
		ifFalse: [autoCommitButtonView backcolor: Color default]!

updateClass: classService
	" a class service was updated, refresh our display"

	| update |
	classService selectedPackageServices: self packageListPresenter selections browser: self.
	update := classListPresenter model asBag
				detect: [:listClassService | listClassService name = classService name]
				ifNone: [^self].
	update replicateFrom: classService.
	classListPresenter view invalidate.!

updateClasses
	self isNoneProjectSelected
		ifTrue: [self updateServices: dictionaryPresenter selections]
		ifFalse: [self updateServices: packageListPresenter selections]!

updateDictionaries
	| browserService |
	browserService := RowanBrowserService new.
	browserService command: #updateDictionaries.
	self issueCommand: (Array with: browserService).!

updateDictionary
	classListPresenter model: ListModel new.
	classHierarchyPresenter model: TreeModel new.
	self updateServices: dictionaryPresenter selections.
	self isClassListTabSelected ifFalse: [self updateHierarchy].
	self updateTabLabel.
	self updateGlobalsTab.
	dictionaryPresenter selections isEmpty ifTrue:[^self]. 
	classDefinitionPresenter value: dictionaryPresenter selections first defaultTemplate.
	self resetClassDefinitionPane.!

updateGlobalsTab
	| array |
	array := Array writeStream: 10.
	array nextPut: (Array
				with: 'Name'
				with: 'Class'
				with: 'Oop'
				with: 'Value').
	dictionaryPresenter selections isEmpty
		ifFalse: 
			[dictionaryPresenter selections
				do: [:dictionaryService | dictionaryService globals do: [:globalArray | array nextPut: globalArray]]].
	globalsTab list: array contents!

updateHierarchy
	| service |
	classHierarchyPresenter model: TreeModel new.
	projectListPresenter selectionOrNil ifNil: [^self].
	self isNoneProjectSelected
		ifTrue: [dictionaryPresenter selections isEmpty ifTrue: [^self]]
		ifFalse: [packageListPresenter selections isEmpty ifTrue: [^self]].
	Cursor wait showWhile: 
			[service := classListPresenter selectionOrNil ifNil: [^self updateHierarchyForPacktionaries].
			BrowserUpdate current applyUpdateWhile: 
					[service
						updateAfterCommand: false;
						command: #classHierarchy.
					self issueCommand: (Array with: service).
					self selectClassNamed: service name]]!

updateHierarchyForPacktionaries
	| service |
	service := RowanBrowserService new.
	self isNoneProjectSelected
		ifTrue: 
			[service
				command: #classHierarchyForDictionariesNamed:;
				commandArgs: (Array with: self selectedDictionaryNames)]
		ifFalse: 
			[service
				command: #classHierarchyForPackagesNamed:;
				commandArgs: (Array with: self selectedPackageNames)].
	self issueCommand: (Array with: service)!

updateMethodSourceColor
	"not sure why, but presenters do not seem to acknowledge that keys
	like 'Del' actually change the value. This hook, sent from #textChanged
	event makes sure we show a visible change when those characters are
	pressed.

	#postToInputQueue sent so that we don't get a gpFault if done at the 
	wrong time. That's presumably a dolphin bug."

	
	[methodSourcePresenter view isModified
		ifTrue: [methodSourcePresenter view backcolor: JadeiteTextStyles default colorForUnsavedEdits]
		ifFalse: [methodSourcePresenter view backcolor: JadeiteTextStyles default colorForNoEdits].
	methodSourcePresenter view invalidate]
			postToInputQueue!

updateProject 
	self projectListPresenter selectionIfNone: 
			[packageListPresenter clear.
			dictionaryPresenter clear.
			self possiblyClearProjectInfoTab.
			self updateTabLabel.
			^self].
	classHierarchyPresenter model: TreeModel new.
	self projectListPresenter selection name = RowanService notRowanizedPackageName
		ifTrue: 
			[self showDictionaryList.
			self updateTabLabel.
			self updateProjectInfo]
		ifFalse: 
			[self showPackageList.
			self updateTabLabel.
			super updateProject]!

updateProjectInfo
	| services |
	self removeAppropriateTab.
	self isNoneProjectSelected ifTrue: [^self buildGlobalsTab].
	self buildProjectTab.
	services := projectListPresenter selections.
	self updateTabLabel.
	services isEmpty ifTrue: [^projectInfoTab list: ListModel new].
	self updateProjectTabFor: services!

updateProjectTabFor: services
	| array |
	array := Array writeStream: services size.
	array nextPut: (Array with: services first with: 'rowanProjectsHome').
	array nextPut: (Array with: RowanProjectService new with: nil).
	services do: 
			[:service |
			array nextPut: (Array with: service with: 'name').
			array nextPut: (Array with: service with: 'sha').
			array nextPut: (Array with: service with: 'branch').
			array nextPut: (Array with: service with: 'isSkew').
			array nextPut: (Array with: service with: 'isDirty').
			array nextPut: (Array with: service with: 'projectUrl').
			service == services last ifFalse: [array nextPut: (Array with: RowanProjectService new with: nil)]].
	projectInfoTab list: array contents!

updateSystemTab
	| projectTabLabel | 
	projectTabLabel := self projectTabLabel.
	self topShell cardsPresenter view currentCard arrangement: projectTabLabel.
	self parentPresenter view updateTabs!

updateTabLabel
	self updateSystemTab!

variablesMenuStrings
	false
		ifTrue: 
			[self addVariableAccessors.
			self
				browseInstVarReaders;
				browseInstVarWriters].
	^#('&Variables' '&Add Accessors//addVariableAccessors' '&Browse Inst Var Readers//browseInstVarReaders' '&Browse Inst Var Writers//browseInstVarWriters')! !
!JadeiteBrowserPresenter categoriesFor: #abortTransaction!public!transaction management! !
!JadeiteBrowserPresenter categoriesFor: #addDictionary!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #additionalAccelerators!constants!public! !
!JadeiteBrowserPresenter categoriesFor: #addNoneProject!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #addSystemBrowser!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #allSelectedProjectsDirty!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #auditProject!project menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #basicAddDictionaryNamed:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #basicDictionaryTabLabel!displaying!private! !
!JadeiteBrowserPresenter categoriesFor: #basicProjectTabLabel!displaying!private!tabs! !
!JadeiteBrowserPresenter categoriesFor: #basicRemoveClass:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #basicRemoveDictionaries:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #basicRemoveGlobal:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #basicUnloadProjects:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #browseBreakpoints!public! !
!JadeiteBrowserPresenter categoriesFor: #browseClassReferences!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #browseGlobalClass!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #browseGlobalReferences!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #browseInstVarReaders!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #browseInstVarWriters!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #browseMethodHistory!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #browseSelectedCategoryMethods!menu handlers!public!queries! !
!JadeiteBrowserPresenter categoriesFor: #browseSelectedMethods!menu handlers!public!queries! !
!JadeiteBrowserPresenter categoriesFor: #buildGlobalsTab!private!tabs! !
!JadeiteBrowserPresenter categoriesFor: #buildProjectTab!private!tabs! !
!JadeiteBrowserPresenter categoriesFor: #categoriesMenuStrings!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #checkout!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #checkoutTag!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #classCommentChanged!event handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #classesMenuStrings!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #comparisonPresenter!accessing!public! !
!JadeiteBrowserPresenter categoriesFor: #contextObject!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #createComponents!initialize/release!public! !
!JadeiteBrowserPresenter categoriesFor: #createListViewFor:!private! !
!JadeiteBrowserPresenter categoriesFor: #createNewProject!menu handlers!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #createSchematicWiring!initialize/release!public! !
!JadeiteBrowserPresenter categoriesFor: #createSchematicWiringForMethodSource!initialize/release!public! !
!JadeiteBrowserPresenter categoriesFor: #debug!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #dictionaryMenu!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #dictionaryMenuStrings!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #dictionaryPresenter!accessing!private! !
!JadeiteBrowserPresenter categoriesFor: #displayStringFor:in:!double dispatch!public! !
!JadeiteBrowserPresenter categoriesFor: #displayVariable:!displaying!private! !
!JadeiteBrowserPresenter categoriesFor: #editDelete!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #editRevert!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #editSaveClass!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #editSaveMethod!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #editSaveMethod:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #expandFullAt:!menu handlers support!private!updating! !
!JadeiteBrowserPresenter categoriesFor: #expandFullHierarchy!menu handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #globalsMenu!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #globalsMenuStrings!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #globalsTab!accessing!private! !
!JadeiteBrowserPresenter categoriesFor: #gotoDictionary!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #gotoDictionaryNamed:!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #insertCompileErrorText:into:!compile support!public! !
!JadeiteBrowserPresenter categoriesFor: #insertIfFalse!menu handlers!must not strip!public! !
!JadeiteBrowserPresenter categoriesFor: #insertIfTrue!menu handlers!must not strip!public! !
!JadeiteBrowserPresenter categoriesFor: #inspectGlobal!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #inspectMethod!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #inspectorContextObject!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #isNoneProjectSelected!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #isProjectItemEnabled:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #isRowanProjectSelected!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #jadeInspect!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #makeSameSelectionsIn:as:!menu handlers!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #maxAutoCompleteListSize!constants!public! !
!JadeiteBrowserPresenter categoriesFor: #methodMenu:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #methodSelectionChanged!event handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #methodsMenuStrings!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #methodsUpdate:!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #methodToReformat!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #methodValueChanged!event handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #newProjectNamed:!menu handlers!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #noClassSelectedInEitherPresenter!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #onDragMethod:!drag & drop!public! !
!JadeiteBrowserPresenter categoriesFor: #onViewOpened!event handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #openSourceStyler!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #openSpecFile!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #packageDictionaryCards!accessing!private! !
!JadeiteBrowserPresenter categoriesFor: #possiblyClearProjectInfoTab!event handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #previousTabViewArrangement!accessing!private! !
!JadeiteBrowserPresenter categoriesFor: #previousTabViewArrangement:!accessing!private! !
!JadeiteBrowserPresenter categoriesFor: #previousTopViewArrangement!accessing!private! !
!JadeiteBrowserPresenter categoriesFor: #previousTopViewArrangement:!accessing!private! !
!JadeiteBrowserPresenter categoriesFor: #projectInfoMenu!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #projectInfoMenuStrings!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #projectMenu!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #projectMenuCommands!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #projectMenuStrings!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #protectedDictionaries!constants!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #queryCommand:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #reformatSource!menu handlers!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #refresh!event handlers!menu handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #refreshClass!event handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #refreshFromServer!event handlers!menu handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #refreshFromServerAfterAbort:!public! !
!JadeiteBrowserPresenter categoriesFor: #registerPresentersForUpdates!public!register presenters! !
!JadeiteBrowserPresenter categoriesFor: #reloadV2Project!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #removeAppropriateTab!private!tabs! !
!JadeiteBrowserPresenter categoriesFor: #removeDictionaries!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #removeGlobal!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #removeGlobalsTab!private!tabs! !
!JadeiteBrowserPresenter categoriesFor: #removeProjectTab!private!tabs! !
!JadeiteBrowserPresenter categoriesFor: #resetClassTemplate!private! !
!JadeiteBrowserPresenter categoriesFor: #resetFontSize!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #runAll!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #runSelected!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #search!accessing!public! !
!JadeiteBrowserPresenter categoriesFor: #selectDictionaryNamed:!public!selection! !
!JadeiteBrowserPresenter categoriesFor: #selectedDictionaryNames!public!selection! !
!JadeiteBrowserPresenter categoriesFor: #selectedGlobalName:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #selectedPackageNames!public!selection! !
!JadeiteBrowserPresenter categoriesFor: #selectedPackageServices!public!selection! !
!JadeiteBrowserPresenter categoriesFor: #selectNoneProject!public!selection! !
!JadeiteBrowserPresenter categoriesFor: #selectPackageNamed:!public!selection! !
!JadeiteBrowserPresenter categoriesFor: #selectProjectNamed:!public!selection! !
!JadeiteBrowserPresenter categoriesFor: #setCompileErrorColor!compile support!public! !
!JadeiteBrowserPresenter categoriesFor: #setCompileWarningColor!compile support!public! !
!JadeiteBrowserPresenter categoriesFor: #setFontSize!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #setFontSizeTo:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #setStatusBarDefault!compile support!public! !
!JadeiteBrowserPresenter categoriesFor: #shouldShowNoneTabLabel!displaying!private!testing! !
!JadeiteBrowserPresenter categoriesFor: #showDictionaryList!event handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #showPackageList!event handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #statusBarText!accessing!public! !
!JadeiteBrowserPresenter categoriesFor: #statusBarText:!accessing!public! !
!JadeiteBrowserPresenter categoriesFor: #updateAfterFindClass:!menu handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateAfterFindClassInDictionary:!menu handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateAfterFindClassInPackage:!menu handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateAutoCommit!public!register presenters!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateClass:!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateClasses!event handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateDictionaries!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateDictionary!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateGlobalsTab!private!tabs! !
!JadeiteBrowserPresenter categoriesFor: #updateHierarchy!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateHierarchyForPacktionaries!private!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateMethodSourceColor!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateProject!event handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateProjectInfo!private!tabs! !
!JadeiteBrowserPresenter categoriesFor: #updateProjectTabFor:!private!tabs! !
!JadeiteBrowserPresenter categoriesFor: #updateSystemTab!event handlers support!private!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateTabLabel!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #variablesMenuStrings!menus!public! !

!JadeiteBrowserPresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil 328198 ##(Smalltalk.Point) 2641 1401 517 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 576 nil nil nil 5 nil nil nil 576 514 170 176 34 10 410 ##(Smalltalk.ContainerView) 34 15 nil 576 34 2 8 1140850688 131073 688 nil nil nil 5 nil nil nil 688 514 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 688 34 2 8 1140850688 131073 800 nil nil nil 5 nil nil nil 800 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.ListView) 34 45 nil 800 34 2 8 1409372233 1025 928 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 327686 ##(Smalltalk.Color) #default nil 13 nil nil nil 928 nil 8 1730340976 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 2 920646 5 ##(Smalltalk.ListViewColumn) 8 '' 41 #left 721670 ##(Smalltalk.MessageSend) #empty 8 #() 16 1138 #<= 8 #() nil nil 928 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 1376 8 'doIt' 8 '[:each | each subSuperIcon]' 8 #[30 105 226 0 106] #subSuperIcon 1392 7 257 nil 1 nil nil 1250 8 'Selector' 549 #left 1138 #displayString 1168 ##(Smalltalk.SortedCollection) nil nil 928 nil 3 nil 1378 0 nil 1410 5 1 1376 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 1536 7 257 nil #report 8 #() nil 133221 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 1298 #createAt:extent: 34 2 482 1 55 482 597 591 928 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 27 0 0 0 42 1 0 0 66 1 0 0] 8 #() 482 193 193 nil 35 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 1874 #fixedParentRight 1 1874 #fixedParentTop 55 1874 #fixedParentBottom -49 410 ##(Smalltalk.PushButton) 34 20 nil 800 34 2 8 1140858880 1 1952 nil 1104 nil 5 nil nil nil 1952 nil 8 1730450496 1180998 4 ##(Smalltalk.CommandDescription) #gotoMethodDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 1 645 482 597 51 1952 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 66 1 0 0 42 1 0 0 91 1 0 0] 8 #() 1824 nil 29 1842 1888 1 1904 1 1936 -49 1936 1 410 ##(Smalltalk.TextEdit) 34 16 nil 800 34 2 8 1140916352 1025 2240 nil 1104 nil 5 nil nil nil 2240 nil 8 1730289152 852486 ##(Smalltalk.NullConverter) nil nil 3 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 597 51 2240 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 42 1 0 0 25 0 0 0] 8 #() 1824 nil 27 1842 1888 1 1904 1 1920 1 1920 51 170 192 34 6 928 8 'methodList' 1952 8 'definedPackageMethodText' 2240 8 'categoryMethodText' nil 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 367 1 482 597 695 800 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 183 0 0 0 0 0 0 0 225 1 0 0 91 1 0 0] 34 3 928 1952 2240 1824 nil 27 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 244 63 410 ##(Smalltalk.CardContainer) 34 16 nil 688 34 2 8 1409286144 131073 2800 nil 1104 nil 5 nil nil nil 2800 656710 1 ##(Smalltalk.CardLayout) 138 144 34 2 721414 ##(Smalltalk.Association) 8 'Category' 410 ##(Smalltalk.ListView) 34 45 nil 2800 34 2 8 1409372233 1025 2976 994 138 144 1040 nil 1072 1104 nil 21 nil nil nil 2976 nil 8 1730340976 1138 #displayString 8 #() nil 1200 nil nil nil nil nil nil 138 144 34 1 1250 8 'Column 1' 333 #left 1138 #displayString 8 #() ##(Smalltalk.SortedCollection) 1378 0 nil 1410 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each]' 1779525917 3216 7 257 nil nil 2976 nil 3 nil nil #report 1616 nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1634 138 144 34 2 1298 #createAt:extent: 34 2 482 9 53 482 341 635 2976 1298 #text: 34 1 8 'Column 1' 2976 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 174 0 0 0 87 1 0 0] 8 #() 1824 nil 35 2930 8 'Variables' 410 ##(Smalltalk.ListView) 34 45 nil 2800 34 2 8 1409372233 1025 3520 994 138 144 1040 nil 1072 1104 nil 21 nil nil nil 3520 nil 8 1730340976 1138 #displayString 8 #() nil 1200 nil nil 1378 0 nil 1410 4 1 1376 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 3664 7 257 nil nil nil nil 138 144 34 1 1250 8 'Column 1' 333 #left 1138 #displayString 3648 ##(Smalltalk.SortedCollection) nil nil 3520 nil 3 nil 1378 0 nil 1410 4 1 1376 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 3824 7 257 nil #report 1616 nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1634 138 144 34 2 1298 #createAt:extent: 34 2 482 9 53 482 341 635 3520 1298 #text: 34 1 8 'Column 1' 3520 1762 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 174 0 0 0 87 1 0 0] 8 #() 1824 nil 35 2976 nil nil nil 170 192 34 4 2976 8 'categoryList' 3520 8 'variableList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 2800 34 2 8 1140916736 1 4176 994 138 144 34 2 2960 3504 nil 1072 nil nil 1 nil nil nil 4176 nil 8 1730678256 1378 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 4304 7 257 nil 1378 0 nil 4322 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 4368 7 257 nil 1200 nil nil nil nil nil #noIcons nil nil nil nil nil 1634 138 144 34 3 1298 #createAt:extent: 34 2 482 1 1 482 357 695 4176 1298 #setSingleSelection: 8 #(1) 4176 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 4176 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 178 0 0 0 91 1 0 0] 8 #() 1824 nil 27 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 357 695 2800 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 178 0 0 0 91 1 0 0] 34 3 2976 3520 4176 1824 nil 27 2770 8 0 0 0 0 0 0 232 63 false 170 192 34 2 2800 8 'methodFilterTabs' nil 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 1679 1 482 963 695 688 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 71 3 0 0 0 0 0 0 40 5 0 0 91 1 0 0] 34 3 2800 410 ##(Smalltalk.Splitter) 34 12 nil 688 34 2 8 1140850688 1 5024 nil 1104 nil 517 nil nil nil 1510470 1 ##(Smalltalk.DraggableViewInteractor) 5024 nil 1 #left nil nil nil 482 1 1 482 9 9 nil 5120 nil 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 357 1 482 11 695 5024 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 178 0 0 0 0 0 0 0 183 0 0 0 91 1 0 0] 8 #() 1824 nil 27 800 1824 nil 27 524806 ##(Smalltalk.Fraction) 15 41 410 ##(Smalltalk.ContainerView) 34 15 nil 576 34 2 8 1140850688 131073 5344 nil nil nil 5 nil nil nil 5344 514 170 176 1040 false 170 192 34 2 410 ##(Smalltalk.ListView) 34 45 nil 5344 34 2 8 1409405261 1025 5472 994 138 144 1040 nil 1072 1104 nil 5 nil nil nil 5472 nil 8 1730340976 1138 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 1200 nil nil nil nil nil nil 138 144 34 1 1250 8 'Column 1' 405 #left 1378 0 nil 1410 2 1 1376 8 'doIt' 8 '[:each | each displayName]' 8 #[30 105 226 0 106] #displayName 5680 7 257 nil ##(Smalltalk.SortedCollection) nil nil 5472 nil 3 1378 0 nil 1410 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 5760 7 257 nil 1378 0 nil 1410 3 1 1376 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 5840 7 257 nil #report 1616 nil 133217 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1634 138 144 34 2 1298 #createAt:extent: 34 2 482 1 1 482 413 695 5472 1298 #text: 34 1 8 'Column 1' 5472 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 206 0 0 0 91 1 0 0] 8 #() 1824 nil 35 8 'projectList' nil 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 413 695 5344 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 206 0 0 0 91 1 0 0] 34 1 5472 1824 nil 27 5314 7 41 410 ##(Smalltalk.ContainerView) 34 15 nil 576 34 2 8 1140850688 131073 6320 nil nil nil 5 nil nil nil 6320 514 170 176 1040 false 170 192 1040 nil 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 413 1 482 413 695 6320 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 206 0 0 0 0 0 0 0 156 1 0 0 91 1 0 0] 34 1 410 ##(Smalltalk.CardContainer) 34 16 nil 6320 34 2 8 1409286144 131073 6592 nil 1104 nil 5 nil nil nil 6592 2866 138 144 34 1 2930 8 'Components' 410 ##(Smalltalk.TreeView) 34 27 nil 6592 34 2 8 1409352231 1025 6736 590918 3 ##(Smalltalk.TreeModel) nil 1072 525062 ##(Smalltalk.TreeNode) nil nil nil 170 192 1040 1104 nil 13 nil nil nil 6736 nil 8 1730912320 1138 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 1200 nil nil 1378 0 nil 1410 9 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:ctx | 
(ctx view presenter list includes: ctx item) 
	ifFalse: [ctx forecolor: ctx forecolor faded]]' 8 #[37 105 17 158 159 160 17 161 180 220 6 233 0 163 164 183 106 60 106] #view #presenter #list #item #includes: #forecolor #faded #forecolor: 6928 7 257 nil nil nil 170 176 1040 33 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 1040 1634 138 144 34 2 1298 #createAt:extent: 34 2 482 9 53 482 397 635 6736 1298 #text: 34 1 8 '''componentTree''' 6736 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 202 0 0 0 87 1 0 0] 8 #() 1824 nil 27 6736 nil nil nil 170 192 34 2 6736 8 '''componentTree''' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 6592 34 2 8 1140916736 1 7296 994 138 144 34 1 6720 nil 1072 nil nil 1 nil nil nil 7296 nil 8 1730678256 1378 0 nil 4322 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 7424 7 257 nil 1378 0 nil 4322 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 7472 7 257 nil 1200 nil nil nil nil nil #noIcons nil nil nil nil nil 1634 138 144 34 3 1298 #createAt:extent: 34 2 482 1 1 482 413 695 7296 1298 #setSingleSelection: 8 #(1) 7296 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 7296 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 206 0 0 0 91 1 0 0] 8 #() 1824 nil 27 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 413 695 6592 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 206 0 0 0 91 1 0 0] 34 2 6736 7296 1824 nil 27 1824 nil 27 5314 7 41 410 ##(Smalltalk.ContainerView) 34 15 nil 576 34 2 8 1140850688 131073 7920 nil nil nil 5 nil nil nil 7920 866 170 176 34 6 410 ##(Smalltalk.CardContainer) 34 16 nil 7920 34 2 8 1409286144 131073 8032 nil 1104 nil 5 nil 263174 ##(Smalltalk.Font) nil true 524550 ##(Smalltalk.LOGFONTW) 8 #[240 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 188 2 0 0 0 0 0 0 1 2 1 34 83 0 121 0 115 0 116 0 101 0 109 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 8032 2866 138 144 34 2 2930 590662 1 ##(Smalltalk.CardLabel) 8 'Class' nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 8032 34 2 8 1140850688 131073 8304 nil nil nil 5 nil nil nil 8304 nil 170 192 1040 nil 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 9 9 482 397 1 8304 1762 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 202 0 0 0 4 0 0 0] 8 #() 1824 nil 27 2930 8258 8 'Instance' nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 8032 34 2 8 1140850688 131073 8592 nil nil nil 5 nil nil nil 8592 nil 170 192 1040 nil 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 9 9 482 397 1 8592 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 202 0 0 0 4 0 0 0] 8 #() 1824 nil 27 8592 nil nil nil 170 192 34 4 8304 8 'classTab' 8592 8 'instanceTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 8032 34 2 8 1140916738 1 8896 994 138 144 34 2 8560 8272 nil 1072 nil nil 1 nil nil nil 8896 nil 8 1730678256 1378 0 nil 4322 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 9024 7 257 nil 1378 0 nil 4322 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 9072 7 257 nil 1200 nil nil nil nil nil #smallIcons nil nil nil nil nil 1634 138 144 34 3 1298 #createAt:extent: 34 2 482 1 1 482 413 51 8896 1298 #setSingleSelection: 8 #(1) 8896 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 8896 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 206 0 0 0 25 0 0 0] 8 #() 1824 nil 27 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 1 595 482 413 51 8032 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 41 1 0 0 206 0 0 0 66 1 0 0] 34 3 8592 8304 8896 1824 nil 27 1842 1888 1 1904 1 1936 -99 1874 #fixedViewTop 51 410 ##(Smalltalk.CardContainer) 34 16 nil 7920 34 2 8 1409286144 131073 9536 nil 1104 nil 5 nil nil nil 9536 2866 138 144 34 2 2930 8258 8 'Hierarchy' nil nil 410 ##(Smalltalk.TreeView) 34 27 nil 9536 34 2 8 1409356327 1025 9696 6802 nil 1072 6834 nil nil nil 170 192 1040 1104 nil 21 nil nil nil 9696 nil 8 1730912320 1378 0 nil 1410 2 1 1376 8 'doIt' 8 '[:each | each displayString]' 8 #[30 105 226 0 106] #displayString 9824 7 257 nil ##(Smalltalk.IconicListAbstract) 1200 nil 1378 0 nil 1410 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 9904 7 257 nil 1378 0 nil 1410 5 1 1376 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 9984 7 257 nil nil nil 170 176 1040 33 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 1040 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 9 53 482 397 535 9696 1762 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 202 0 0 0 37 1 0 0] 8 #() 1824 nil 27 2930 8258 8 'Classes' nil nil 410 ##(Smalltalk.ListView) 34 45 nil 9536 34 2 8 1409372237 1025 10304 994 138 144 1040 nil 1072 1104 nil 21 nil nil nil 10304 nil 8 1730340976 1138 #displayString 8 #() nil 1200 nil nil nil nil nil nil 138 144 34 1 1250 8 '' 389 #left 1138 #displayString 8 #() 1138 #<= 8 #() nil nil 10304 nil 3 nil 1378 0 nil 1410 5 1 1376 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 10576 7 257 nil #report 1616 nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 9 53 482 397 535 10304 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 202 0 0 0 37 1 0 0] 8 #() 1824 nil 35 10304 nil nil nil 170 192 34 4 9696 8 'classHierarchy' 10304 8 'classList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 9536 34 2 8 1140916736 1 10880 994 138 144 34 2 10272 9664 nil 1072 nil nil 1 nil nil nil 10880 nil 8 1730678256 1378 0 nil 4322 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 11008 7 257 nil 1378 0 nil 4322 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 11056 7 257 nil 1200 nil nil nil nil nil #smallIcons nil nil nil nil nil 1634 138 144 34 3 1298 #createAt:extent: 34 2 482 1 1 482 413 595 10880 1298 #setSingleSelection: 8 #(1) 10880 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 10880 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 206 0 0 0 41 1 0 0] 8 #() 1824 nil 27 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 413 595 9536 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 206 0 0 0 41 1 0 0] 34 3 10304 9696 10880 1824 nil 27 1842 1888 1 1904 1 1920 1 1936 -99 410 ##(Smalltalk.PushButton) 34 20 nil 7920 34 2 8 1140858880 1 11504 nil 1090 #silver nil 5 nil nil nil 11504 nil 8 1730450496 2034 #gotoClassDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 1 645 482 413 51 11504 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 66 1 0 0 206 0 0 0 91 1 0 0] 8 #() 1824 nil 29 1842 1888 1 1904 1 1936 -49 1936 1 170 192 34 6 8032 8 'instanceClassTabs' 9536 8 'classHierarchyTabs' 11504 8 'definedPackageClassText' nil 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 1257 1 482 413 695 7920 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 116 2 0 0 0 0 0 0 66 3 0 0 91 1 0 0] 34 3 9536 8032 11504 1824 nil 27 5314 7 41 410 ##(Smalltalk.ContainerView) 34 15 nil 576 34 2 8 1140850688 131073 12048 nil nil nil 5 nil nil nil 12048 514 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 12048 34 2 8 1409286144 131073 12160 nil 1104 nil 5 nil nil nil 12160 2866 138 144 1040 nil nil nil nil 170 192 1040 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 12160 34 2 8 1140916736 1 12272 994 138 144 1040 nil 1072 nil nil 1 nil nil nil 12272 nil 8 1730678256 1378 0 nil 4322 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 12384 7 257 nil 1378 0 nil 4322 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 12432 7 257 nil 1200 nil nil nil nil nil #noIcons nil nil nil nil nil 1634 138 144 34 2 1298 #createAt:extent: 34 2 482 1 1 482 413 695 12272 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 12272 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 206 0 0 0 91 1 0 0] 8 #() 1824 nil 27 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 413 695 12160 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 206 0 0 0 91 1 0 0] 34 1 12272 1824 nil 27 3 false 170 192 34 2 12160 8 'packageDictionaryCards' nil 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 835 1 482 413 695 12048 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 161 1 0 0 0 0 0 0 111 2 0 0 91 1 0 0] 34 1 12160 1824 nil 27 5314 7 41 false 170 192 1040 nil 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 2641 695 576 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 40 5 0 0 91 1 0 0] 34 8 5344 6320 410 ##(Smalltalk.Splitter) 34 12 nil 576 34 2 8 1140850688 1 13232 nil 1104 nil 517 nil nil nil 5090 13232 nil 1 #left nil nil nil 5120 5136 nil 5120 nil 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 825 1 482 11 695 13232 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 156 1 0 0 0 0 0 0 161 1 0 0 91 1 0 0] 8 #() 1824 nil 27 12048 410 ##(Smalltalk.Splitter) 34 12 nil 576 34 2 8 1140850688 1 13472 nil 1104 nil 517 nil nil nil 5090 13472 nil 1 #left nil nil nil 5120 5136 nil 5120 nil 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 1247 1 482 11 695 13472 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 111 2 0 0 0 0 0 0 116 2 0 0 91 1 0 0] 8 #() 1824 nil 27 7920 410 ##(Smalltalk.Splitter) 34 12 nil 576 34 2 8 1140850688 1 13712 nil 1104 nil 517 nil nil nil 5090 13712 nil 1 #left nil nil nil 5120 5136 nil 5120 nil 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 1669 1 482 11 695 13712 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 66 3 0 0 0 0 0 0 71 3 0 0 91 1 0 0] 8 #() 1824 nil 27 688 1824 nil 27 25 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 13952 nil nil nil 5 nil nil nil 13952 866 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 13952 34 2 8 1140850688 131073 14064 nil nil 482 2241 43 517 nil nil nil 14064 866 170 176 34 4 410 ##(Smalltalk.ToolButton) 34 14 nil 14064 34 2 8 1140850688 131073 14192 nil nil nil 1029 nil nil nil 14192 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 14192 34 2 8 1140853580 131137 14256 nil nil 482 43 43 513 nil nil nil 14256 nil 8 1730391328 nil 170 192 34 2 48365 1115206 1 ##(Smalltalk.ToolbarIconButton) 14256 1 2034 #flipAutoCommit 8 'Auto Commit' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons/camera16_light_icon.ico' nil 48365 34 1 14400 nil nil 3 nil 482 33 33 482 33 33 nil nil 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 43 43 14256 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 8 #() 1824 nil 27 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 43 43 14192 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 34 1 14256 1824 nil 27 1842 1888 1 1874 #fixedViewLeft 43 1920 1 9520 43 410 ##(Smalltalk.TextEdit) 34 16 nil 14064 34 2 8 1140850688 1 14928 nil 1104 482 2199 43 517 nil 8098 nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 482 193 193 nil 14928 1090 #black 8 1730289152 2322 nil nil 67 1634 138 144 34 2 1298 #createAt:extent: 34 2 482 43 1 482 2599 41 14928 1298 #setMarginWidths: 34 1 8 #(3 3) 14928 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 21 0 0 0 0 0 0 0 40 5 0 0 20 0 0 0] 8 #() 1824 nil 27 1842 1888 43 1904 1 1920 1 1936 1 170 192 34 4 14192 8 'autoCommitButton' 14928 8 'statusBarField' nil 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 1 657 482 2641 41 14064 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 72 1 0 0 40 5 0 0 92 1 0 0] 34 2 14192 14928 1824 nil 27 1842 1888 1 1904 1 1936 -39 1936 1 410 ##(Smalltalk.CardContainer) 34 16 nil 13952 34 2 8 1409286144 131073 15600 nil 1104 nil 5 nil nil nil 15600 2866 138 144 34 6 2930 8258 8 'SUnit' 1378 0 nil 1410 4 1 1376 8 'doIt' 8 '[Icon fromId: ''icons\UnitTestPlugin.ico'']' 8 #[32 105 45 30 178 106] 983558 ##(Smalltalk.VariableBinding) #Icon 14448 8 'icons\UnitTestPlugin.ico' #fromId: 15760 7 1 nil nil 410 ##(Smalltalk.ReferenceView) 34 14 nil 15600 34 2 8 1140850688 131073 15888 nil 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 nil nil nil 15888 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteSUnitInClassPresenter) #resource_Default_view nil 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 9 53 482 2625 597 15888 1762 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 36 5 0 0 68 1 0 0] 1040 1824 nil 27 2930 8258 8 'Class Definition' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 15600 34 2 8 1445007428 1025 16208 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 15954 26337781 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 11 984134 2 ##(Smalltalk.CommandMenuItem) 1 2034 #editSave 8 '&Save' 9383 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 16402 1 2034 #editUndo 8 '&Undo' 9397 1 nil nil nil 16402 1 2034 #editRedo 8 '&Redo' 9395 1 nil nil nil 16466 4097 16402 1 2034 #editCut 8 'Cu&t' 9393 1 nil nil nil 16402 1 2034 #editCopy 8 '&Copy' 9351 1 nil nil nil 16402 1 2034 #editPaste 8 '&Paste' 9389 1 nil nil nil 16402 1 2034 #editDelete 8 '&Delete' 1629 1 nil nil nil 16466 4097 16402 1 2034 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 8098 nil true 15026 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 16208 nil 8 1550399069 2322 nil nil 13 nil 170 192 34 4 #normal 1182790 1 ##(Smalltalk.ScintillaTextStyle) 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 17010 77 1090 #gray 1090 #white 1 nil nil nil nil #callTip nil nil nil nil 1639686 ##(Smalltalk.SmalltalkExpressionStyler) 1 nil nil false 138 144 1040 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 16208 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1040 nil 170 176 1040 9215 nil nil nil nil 11568 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 17024 nil nil nil nil 1 nil 170 192 34 6 1 1510470 3 ##(Smalltalk.ScintillaIndicatorStyle) 1 16208 15954 65025 3 false 1 nil nil nil nil nil nil 3 17426 3 16208 1090 #blue 5 false 3 nil nil nil nil nil nil 5 17426 5 16208 1090 #red 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 17010 1027 15954 60239 15954 31326207 1 nil nil nil nil #Warning nil nil nil #Error 17010 1031 15954 335 15954 31317503 1 nil nil nil nil #Error nil nil nil #Notification 17010 1029 nil 15954 31185883 1 nil nil nil nil #Notification nil nil nil nil 1634 138 144 34 9 1298 #createAt:extent: 34 2 482 9 53 482 2625 597 16208 1298 #contextMenu: 34 1 16368 16208 1298 #caretPeriod: 8 #(530) 16208 1298 #wordWrap: 8 #(true) 16208 1298 #margins: 34 1 34 3 985158 3 ##(Smalltalk.ScintillaMargin) 1 16208 1 3 nil nil 5 nil 17954 3 16208 33 nil 3 67108863 5 nil 17954 5 16208 1 nil 3 -67108863 5 nil 16208 1298 #tabWidth: 8 #(4) 16208 1298 #targetRange: 34 1 525062 ##(Smalltalk.Interval) 1 -1 3 16208 1298 #maxCompletionListHeight: 8 #(9) 16208 1298 #edgeColumn: 8 #(1) 16208 1762 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 36 5 0 0 68 1 0 0] 8 #() 1824 nil 29 2930 8258 8 'Class Documentation' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 15600 34 2 8 1445007428 1025 18272 16274 nil false 16320 nil 15954 26337781 nil 5 16354 nil true 34 1 16402 1 2034 #editSaveClassComment 8 'Save' 1025 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 8098 nil true 15026 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 18272 nil 8 1550399069 2322 nil nil 15 nil 170 192 34 4 #normal 17010 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 17010 77 17056 17072 1 nil nil nil nil #callTip nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 17170 1 nil nil nil 18272 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1040 nil 170 176 1040 9215 nil nil nil nil 11568 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 18592 nil nil nil nil 1 nil 170 192 34 6 1 17426 1 18272 15954 65025 3 false 1 nil nil nil nil nil nil 3 17426 3 18272 17488 5 false 3 nil nil nil nil nil nil 5 17426 5 18272 17520 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 17010 1027 15954 60239 15954 31326207 1 nil nil nil nil #Warning nil nil nil #Error 17010 1031 15954 335 15954 31317503 1 nil nil nil nil #Error nil nil nil #Notification 17010 1029 nil 15954 31185883 1 nil nil nil nil #Notification nil nil nil nil 1634 138 144 34 10 1298 #createAt:extent: 34 2 482 9 53 482 2625 597 18272 1298 #contextMenu: 34 1 18368 18272 1298 #hoverTime: 8 #(1000000) 18272 1298 #caretPeriod: 8 #(530) 18272 1298 #wordWrap: 8 #(true) 18272 1298 #margins: 34 1 34 3 17954 1 18272 1 3 nil nil 5 nil 17954 3 18272 33 nil 3 67108863 5 nil 17954 5 18272 1 nil 3 -67108863 5 nil 18272 1298 #tabWidth: 8 #(4) 18272 1298 #targetRange: 34 1 18082 1 -1 3 18272 1298 #maxCompletionListHeight: 8 #(9) 18272 1298 #edgeColumn: 8 #(1) 18272 1762 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 36 5 0 0 68 1 0 0] 8 #() 1824 nil 29 2930 8258 8 'Method Source' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 15600 34 2 8 1445007428 1025 19648 16274 nil false 16320 nil 15954 26337781 nil 5 nil 8098 nil true 15026 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 19648 nil 8 1550399069 2322 nil nil 13 nil 170 192 34 4 #normal 17010 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 17010 77 17056 17072 1 nil nil nil nil #callTip nil nil nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 1040 170 192 34 2 #default 17170 1 nil nil nil 19648 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1040 nil 170 176 1040 9215 nil nil nil nil 11568 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 4 #normal 19872 #callTip 19888 nil nil nil nil 1 nil 170 192 34 12 1 17426 1 19648 15954 65025 3 false 1 nil nil nil nil nil nil 8 'indicator10' 17426 21 19648 17520 3 nil nil nil nil nil nil nil nil 8 'indicator8' 17426 17 19648 11568 1 nil nil nil nil nil nil nil nil 8 'indicator9' 17426 19 19648 17520 13 nil nil nil nil nil nil nil nil 3 17426 3 19648 17488 5 false 3 nil nil nil nil nil nil 5 17426 5 19648 17520 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 17010 1027 15954 60239 15954 31326207 1 nil nil nil nil #Warning nil nil nil #Error 17010 1031 15954 335 15954 31317503 1 nil nil nil nil #Error nil nil nil #Notification 17010 1029 nil 15954 31185883 1 nil nil nil nil #Notification nil nil nil nil 1634 138 144 34 9 1298 #createAt:extent: 34 2 482 9 53 482 2625 597 19648 1298 #hoverTime: 8 #(500) 19648 1298 #caretPeriod: 8 #(530) 19648 1298 #wordWrap: 8 #(true) 19648 1298 #margins: 34 1 34 3 17954 1 19648 61 3 nil nil 5 nil 17954 3 19648 1 nil 3 67108863 nil nil 17954 5 19648 1 nil 3 -67108863 nil nil 19648 1298 #tabWidth: 8 #(4) 19648 1298 #targetRange: 34 1 18082 1 -1 3 19648 1298 #maxCompletionListHeight: 8 #(9) 19648 1298 #edgeColumn: 8 #(1) 19648 1762 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 36 5 0 0 68 1 0 0] 8 #() 1824 nil 29 2930 8258 8 'Comparison' nil nil 410 ##(Smalltalk.ShellView) 34 27 nil 15600 34 2 8 1078919168 131073 21088 nil 1104 nil 517 nil nil nil 21088 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 21088 34 2 8 1140850688 131073 21184 nil 15954 26337781 nil 5 16354 nil true 34 5 16402 1 2034 #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 16402 1 2034 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 16402 1 2034 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 16402 1 2034 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 16402 1 2034 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 21184 514 170 176 1040 false 170 192 1040 nil 1634 138 144 34 2 1298 #createAt:extent: 34 2 482 1 1 482 2193 565 21184 1298 #contextMenu: 34 1 21264 21184 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 4 0 0 26 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 21184 34 2 8 1140850688 131073 21792 nil 1104 nil 5 nil nil nil 21792 21154 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 21792 34 2 8 1140850945 262145 21872 nil nil nil 21 nil nil nil 21872 nil 8 1730448032 2322 nil nil nil 1634 138 144 34 2 1298 #createAt:extent: 34 2 482 1 525 482 1091 41 21872 1298 #text: 34 1 8 '
' 21872 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 6 1 0 0 33 2 0 0 26 1 0 0] 8 #() 1824 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 21792 34 2 8 1140920580 1025 22176 16274 nil false 16320 nil 15954 26337781 nil 21 nil nil nil 22176 nil 8 1550399069 2322 nil nil 13 nil 170 192 34 12 #callTip 17010 77 17056 17072 1 nil nil nil nil #callTip nil nil nil #indentGuide 17010 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 17010 3 1090 #teal nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 17010 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #normal 17010 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 17010 5 nil 15954 16908287 3 nil nil nil nil #diff nil 1401 nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 17170 1 nil nil nil 22176 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1040 nil 170 176 1040 9215 nil nil nil nil 11568 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 22304 nil nil nil nil 1 nil 170 192 34 2 #diff 17426 1 22176 1090 #yellow 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 17010 1027 15954 60239 15954 31326207 1 nil nil nil nil #Warning nil nil nil #Error 17010 1031 15954 335 15954 31317503 1 nil nil nil nil #Error nil nil nil #Notification 17010 1029 nil 15954 31185883 1 nil nil nil nil #Notification nil nil nil nil 1634 138 144 34 8 1298 #createAt:extent: 34 2 482 1 1 482 1091 525 22176 1298 #caretPeriod: 8 #(530) 22176 1298 #wordWrap: 8 #(true) 22176 1298 #margins: 34 1 34 3 17954 1 22176 49 3 nil nil nil nil 17954 3 22176 1 nil nil 67108863 nil nil 17954 5 22176 1 nil nil nil nil nil 22176 1298 #canHScroll: 8 #(false) 22176 1298 #targetRange: 34 1 18082 1 -1 3 22176 1298 #maxCompletionListHeight: 8 #(9) 22176 1298 #edgeColumn: 8 #(1) 22176 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 6 1 0 0] 8 #() 1824 nil 29 170 192 34 4 21872 8 'beforeTitle' 22176 8 'before' nil 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 1091 565 21792 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 26 1 0 0] 34 2 22176 21872 1824 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 21184 34 2 8 1140850688 1 23632 nil 15954 66047 nil 517 nil nil nil 5090 23632 nil 1 #left nil nil nil 5120 5136 nil 5120 nil 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 1091 1 482 11 565 23632 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 33 2 0 0 0 0 0 0 38 2 0 0 26 1 0 0] 8 #() 1824 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 21184 34 2 8 1140850688 131073 23888 nil 1104 nil 5 nil nil nil 23888 21154 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 23888 34 2 8 1140850945 262145 23968 nil nil nil 21 nil nil nil 23968 nil 8 1730448032 2322 nil nil nil 1634 138 144 34 2 1298 #createAt:extent: 34 2 482 1 525 482 1093 41 23968 1298 #text: 34 1 8 '
' 23968 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 6 1 0 0 34 2 0 0 26 1 0 0] 8 #() 1824 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 23888 34 2 8 1140920580 1025 24272 16274 nil false 16320 nil 15954 26337781 nil 21 nil nil nil 24272 nil 8 1550399069 2322 nil nil 13 nil 170 192 34 12 #callTip 17010 77 17056 17072 1 nil nil nil nil #callTip nil nil nil #indentGuide 17010 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 17010 3 22384 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 17010 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #normal 17010 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 17010 5 nil 15954 16908287 3 nil nil nil nil #diff nil 1401 nil nil 22466 22496 170 192 34 2 #default 17170 1 nil nil nil 24272 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1040 nil 170 176 1040 9215 nil nil nil nil 11568 nil nil 65 nil nil 22592 22672 3 170 192 34 2 #container 24400 nil nil nil nil 1 nil 170 192 34 2 #diff 17426 1 24272 22768 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 17010 1027 15954 60239 15954 31326207 1 nil nil nil nil #Warning nil nil nil #Error 17010 1031 15954 335 15954 31317503 1 nil nil nil nil #Error nil nil nil #Notification 17010 1029 nil 15954 31185883 1 nil nil nil nil #Notification nil nil nil nil 1634 138 144 34 8 1298 #createAt:extent: 34 2 482 1 1 482 1093 525 24272 1298 #caretPeriod: 8 #(530) 24272 1298 #wordWrap: 8 #(true) 24272 1298 #margins: 34 1 34 3 17954 1 24272 49 3 nil nil nil nil 17954 3 24272 1 nil nil 67108863 nil nil 17954 5 24272 1 nil nil nil nil nil 24272 1298 #canHScroll: 8 #(false) 24272 1298 #targetRange: 34 1 18082 1 -1 3 24272 1298 #maxCompletionListHeight: 8 #(9) 24272 1298 #edgeColumn: 8 #(1) 24272 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 34 2 0 0 6 1 0 0] 8 #() 1824 nil 29 170 192 34 4 23968 8 'afterTitle' 24272 8 'after' nil 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 1101 1 482 1093 565 23888 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 38 2 0 0 0 0 0 0 72 4 0 0 26 1 0 0] 34 2 24272 23968 1824 nil 27 1824 nil 27 170 192 34 2 21184 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 16354 nil true 34 4 16402 1 2034 #selectUpper 8 'Select &upper' 1 1 nil nil nil 16402 1 2034 #selectLower 8 'Select &lower' 1 1 nil nil nil 16466 4097 16402 1 2034 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 48453 nil nil 16354 nil true 34 3 16402 1 2034 #character 8 '&Character' 1 1 nil nil nil 16402 1 2034 #word 8 '&Word' 1 1 nil nil nil 16402 1 2034 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 48455 nil nil 16354 nil true 34 1 16402 1 2034 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 48457 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1634 138 144 34 2 1298 #createAt:extent: 34 2 482 9 53 482 2625 597 21088 1298 #text: 34 1 8 'Comparison' 21088 1762 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 36 5 0 0 68 1 0 0] 34 1 21184 1824 nil 27 2930 8258 8 'Spec' nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 15600 34 2 8 1409286144 131073 26432 nil nil nil 5 nil nil nil 26432 514 138 ##(Smalltalk.Dictionary) 34 1 2930 410 ##(Smalltalk.Splitter) 34 12 nil 26432 34 2 8 1140850688 1 26560 nil nil nil 517 nil nil nil 5090 26560 nil 1 #left nil nil nil 5120 5136 nil 5120 nil 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 1 85 482 731 11 26560 1762 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 42 0 0 0 109 1 0 0 47 0 0 0] 8 #() 1824 nil 27 1 true 170 192 34 2 410 ##(Smalltalk.ListTreeView) 34 59 nil 26432 34 2 8 1140953421 1 26832 994 138 144 1040 nil 1072 15954 26337781 nil 13 16354 nil true 34 12 16402 1 2034 #inspectIt 8 '&Inspect' 1 1 14450 nil true 14496 8 'BasicInspector.ico' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil nil nil 16402 1 2034 #inspectReferences 8 'Inspect &References' 1 1 nil nil nil 16466 4097 16402 1 2034 #browseIt 8 '&Browse It' 1 1 14450 nil true 14496 8 'ClassBrowserShell.ico' 27072 nil nil 16466 4097 16402 1 2034 #copyAspect 8 '&Copy' 1 1 nil nil nil 16402 1 2034 #pasteAspect 8 '&Paste <1d>' 1 1 nil nil nil 16466 4097 16402 1 2034 #editAspect 8 '&Edit' 1 1 nil nil nil 16402 1 2034 #nilAspect 8 'Set to &Nil' 1 1 nil nil nil 16466 4097 16402 1 2034 #refresh 8 'Re&fresh' 1 1 nil nil nil 8 '&Workspace' nil 134217729 nil nil nil nil nil nil nil 26832 nil 8 1730340976 1138 #valueText 8 #() nil 1200 nil nil nil nil nil nil 138 144 34 3 1250 8 'Property' 1293 #left 1138 #valueNameOnly 8 #() 1138 #<= 8 #() nil nil 26832 nil 3 1138 #valueNameInfo 8 #() nil 1250 8 'Value' 1293 #left 1138 #valueTextOnly 8 #() 1138 #<= 27712 nil nil 26832 1138 #valueImage 8 #() 3 nil nil 1250 8 '' 33 #center nil 1138 #<= 8 #() nil nil 26832 1378 0 nil 1410 3 1 1376 8 'doIt' 8 '[:x | PropertyInspector editButtonImageIndexFor: x ]' 8 #[31 105 29 17 177 106] ##(Smalltalk.PropertyInspector) #editButtonImageIndexFor: 27936 7 257 nil 1 nil nil #report 1616 nil 131431 482 129 129 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil false 1050438 3 ##(Smalltalk.VirtualTreeModel) nil 1072 138 144 1040 nil nil 1378 0 nil 4322 2 3 28032 #defaultHasChildrenBlock 508791331 8 #[252 1 0 0 1 4 0 65 176 159 106 105] #childrenOf: #notEmpty 17 257 28048 1378 0 nil 4322 1 83886083 28032 #defaultFilterBlock 508773827 8 #[29 105 17 157 106] 28128 7 257 nil nil 138 ##(Smalltalk.PluggableSet) 1040 138 ##(Smalltalk.IdentitySet) 1040 13 1 nil nil nil nil nil nil nil 1634 138 144 34 3 1298 #createAt:extent: 34 2 482 1 1 482 2625 597 26832 1298 #contextMenu: 34 1 26944 26832 1298 #text: 34 1 8 'Property' 26832 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 32 5 0 0 42 1 0 0] 8 #() 1824 nil 2029 8 'aspects' nil 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 9 53 482 2625 597 26432 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 36 5 0 0 68 1 0 0] 34 2 26560 26832 1824 nil 27 26432 nil nil nil 170 192 34 10 19648 8 'methodSource' 18272 8 'classDocumentation' 16208 8 'classDefinition' 15888 8 'sunit' 21088 8 'comparisonTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 15600 34 2 8 1140916736 1 28736 994 138 144 34 6 16176 18240 19616 15728 21056 26400 nil 1072 nil nil 1 nil nil nil 28736 nil 8 1730678256 1378 0 nil 4322 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 28864 7 257 nil 1378 0 nil 4322 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 28912 7 257 nil 1200 nil nil nil nil nil #smallIcons nil nil nil nil nil 1634 138 144 34 3 1298 #createAt:extent: 34 2 482 1 1 482 2641 657 28736 1298 #setSingleSelection: 8 #(6) 28736 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 28736 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 40 5 0 0 72 1 0 0] 8 #() 1824 nil 27 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 2641 657 15600 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 40 5 0 0 72 1 0 0] 34 7 16208 18272 19648 15888 21088 26432 28736 1824 nil 27 1842 1888 1 1904 1 1920 1 1936 -39 170 192 34 2 15600 8 'textAreaTabs' nil 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 1 705 482 2641 697 13952 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 96 1 0 0 40 5 0 0 188 2 0 0] 34 2 15600 14064 1824 nil 27 25 true 170 192 34 2 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 29600 nil 1104 nil 517 nil nil nil 5090 29600 nil 1 #left nil nil nil 5120 5136 nil 5120 nil 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 1 695 482 2641 11 29600 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 91 1 0 0 40 5 0 0 96 1 0 0] 8 #() 1824 nil 27 8 'splitter' nil 1634 138 144 34 1 1298 #createAt:extent: 34 2 482 7545 21 482 2641 1401 416 1762 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 188 14 0 0 10 0 0 0 228 19 0 0 198 2 0 0] 34 3 576 29600 13952 1824 nil 27 )! !
!JadeiteBrowserPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

