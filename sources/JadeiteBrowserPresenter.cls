"Filed out from Dolphin Smalltalk 7"!

JadeiteProjectsBrowserPresenter subclass: #JadeiteBrowserPresenter
	instanceVariableNames: 'dictionaryPresenter packageDictionaryCards globalsTab autoCommitButton search'
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
	^#(#(#insertIfFalse 'Ctrl+Shift+D') #(#insertIfTrue 'Ctrl+Shift+T') #(#raiseConsole 'Ctrl+F7'))!

addNoneProject
	(projectListPresenter list includes: RowanProjectService noneProject)
		ifFalse: [projectListPresenter model add: RowanProjectService noneProject]!

addSystemBrowser
	| browser |
	browser := self topShell addSystemBrowser.
	self makeSameSelectionsIn: browser currentCard as: self.
	^browser!

allSelectedProjectsDirty
	projectListPresenter selections isEmpty ifTrue:[^false]. 
	projectListPresenter selections detect: [:projectService | projectService isDirty not]
		ifNone: [^true].
	^false!

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
	autoCommitButton := self add: Presenter new name: 'autoCommitButton'
	"searchPresenter := self
				add: SmalltalkSearchPresenter new
				name: 'search'
				helpId: 10510."!

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
	(command = #refreshFromServer or: [command = #cloneProject]) ifTrue: [^true].
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
	classService := previousPresenter classListPresenter selectionIfNone: [].
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
	isMeta ifTrue: [newPresenter selectClassTab].
	methodService ifNil: [^self].
	newPresenter findMethod: methodService selector!

maxAutoCompleteListSize
	^50!

methodMenu: aMenu
	self methodMenuBreak: aMenu!

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
				yourself]!

noClassSelectedInEitherPresenter
	classListPresenter selectionIfNone: [classHierarchyPresenter selectionIfNone: [^true]].
	^false!

onViewOpened
	super onViewOpened. 
	self showPackageList!

packageDictionaryCards
	"for testing"

	^packageDictionaryCards!

possiblyClearProjectInfoTab
	self projectListPresenter
		selectionIfNone: [projectInfoTab ifNotNil: [:tab | tab list: ListModel new]]!

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

refreshFromServerAfterAbort: browserService
	self autoCommit: (autoCommit value == #failed ifTrue: [true] ifFalse: [autoCommit value])!

registerPresentersForUpdates
	super registerPresentersForUpdates.
	BrowserUpdate current register: dictionaryPresenter selector: #dictionaryListUpdate:.
	BrowserUpdate current
		register: classListPresenter
		selector: #renamedClass:browser:
		browser: self.
	BrowserUpdate current
		register: classHierarchyPresenter
		selector: #renamedClassInHierarchy:browser:
		browser: self.
	BrowserUpdate current
		register: classListPresenter
		selector: #addCachedSymbols:
!

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

runAll
	self selectSUnitTab.
	self sunitPresenter runAll!

runSelected
	^self runMethodTests. !

search
	^search ifNil: [search := JadeiteSearch on: methodSourcePresenter view session: self gciSession]!

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
	selectedPackage := packageListPresenter list
				detect: [:packageService | packageService name = packageName]
				ifNone: [^self].
	packageListPresenter selections: (Array with: selectedPackage)!

selectProjectNamed: projectName
	| projectService |
	projectService := projectListPresenter list detect: [:service | service name = projectName]
				ifNone: [^self].
	projectListPresenter selections: (Array with: projectService)!

setCompileErrorColor
	statusBarText view backcolor: Color red faded!

setCompileWarningColor
	statusBarText view backcolor: Color yellow faded!

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
				detect: [:service | service name = classService projectName].	"it should always be found"
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
	update replicateFrom: self.
	classListPresenter view invalidate!

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
!JadeiteBrowserPresenter categoriesFor: #classCommentChanged!event handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #classesMenuStrings!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #comparisonPresenter!accessing!public! !
!JadeiteBrowserPresenter categoriesFor: #contextObject!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #createComponents!initialize/release!public! !
!JadeiteBrowserPresenter categoriesFor: #createListViewFor:!private! !
!JadeiteBrowserPresenter categoriesFor: #createSchematicWiring!create schemantic wiring!public! !
!JadeiteBrowserPresenter categoriesFor: #createSchematicWiringForMethodSource!create schemantic wiring!public! !
!JadeiteBrowserPresenter categoriesFor: #debug!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #dictionaryMenu!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #dictionaryMenuStrings!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #dictionaryPresenter!accessing!private! !
!JadeiteBrowserPresenter categoriesFor: #displayStringFor:in:!double dispatch!public! !
!JadeiteBrowserPresenter categoriesFor: #displayVariable:!displaying!private! !
!JadeiteBrowserPresenter categoriesFor: #editSaveClass!menu handlers!public! !
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
!JadeiteBrowserPresenter categoriesFor: #methodsMenuStrings!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #methodsUpdate:!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #methodToReformat!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #methodValueChanged!event handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #noClassSelectedInEitherPresenter!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #onViewOpened!event handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #packageDictionaryCards!accessing!private! !
!JadeiteBrowserPresenter categoriesFor: #possiblyClearProjectInfoTab!event handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #projectInfoMenu!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #projectInfoMenuStrings!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #protectedDictionaries!constants!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #queryCommand:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #reformatSource!menu handlers!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #refreshClass!event handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #refreshFromServerAfterAbort:!public! !
!JadeiteBrowserPresenter categoriesFor: #registerPresentersForUpdates!public!register presenters! !
!JadeiteBrowserPresenter categoriesFor: #removeAppropriateTab!private!tabs! !
!JadeiteBrowserPresenter categoriesFor: #removeDictionaries!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #removeGlobal!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #removeGlobalsTab!private!tabs! !
!JadeiteBrowserPresenter categoriesFor: #removeProjectTab!private!tabs! !
!JadeiteBrowserPresenter categoriesFor: #resetClassTemplate!private! !
!JadeiteBrowserPresenter categoriesFor: #runAll!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #runSelected!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #search!accessing!public! !
!JadeiteBrowserPresenter categoriesFor: #selectedDictionaryNames!public!selection! !
!JadeiteBrowserPresenter categoriesFor: #selectedGlobalName:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #selectedPackageNames!public!selection! !
!JadeiteBrowserPresenter categoriesFor: #selectedPackageServices!public!selection! !
!JadeiteBrowserPresenter categoriesFor: #selectNoneProject!public!selection! !
!JadeiteBrowserPresenter categoriesFor: #selectPackageNamed:!public!selection! !
!JadeiteBrowserPresenter categoriesFor: #selectProjectNamed:!public!selection! !
!JadeiteBrowserPresenter categoriesFor: #setCompileErrorColor!compile support!public! !
!JadeiteBrowserPresenter categoriesFor: #setCompileWarningColor!compile support!public! !
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
!JadeiteBrowserPresenter categoriesFor: #updateProject!event handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateProjectInfo!private!tabs! !
!JadeiteBrowserPresenter categoriesFor: #updateProjectTabFor:!private!tabs! !
!JadeiteBrowserPresenter categoriesFor: #variablesMenuStrings!menus!public! !

!JadeiteBrowserPresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil 328198 ##(Smalltalk.Point) 2241 1401 517 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 6 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 576 nil nil nil 5 nil nil nil 576 514 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 576 34 2 8 1140850688 131073 688 nil nil nil 5 nil nil nil 688 514 170 176 34 6 410 ##(Smalltalk.ContainerView) 34 15 nil 688 34 2 8 1140850688 131073 800 nil nil nil 5 nil nil nil 800 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.CardContainer) 34 16 nil 800 34 2 8 1409286144 131073 928 nil 327686 ##(Smalltalk.Color) #default nil 5 nil nil nil 928 655878 ##(Smalltalk.CardLayout) 138 144 34 2 721414 ##(Smalltalk.Association) 590662 1 ##(Smalltalk.CardLabel) 8 'Class' nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 928 34 2 8 1140850688 131073 1168 nil nil nil 5 nil nil nil 1168 nil 170 192 8 #() nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 482 9 9 482 495 1 1168 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 251 0 0 0 4 0 0 0] 8 #() 482 193 193 nil 27 1090 1122 8 'Instance' nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 928 34 2 8 1140850688 131073 1536 nil nil nil 5 nil nil nil 1536 nil 170 192 1248 nil 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 9 9 482 495 1 1536 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 251 0 0 0 4 0 0 0] 8 #() 1472 nil 27 1536 170 192 34 4 1168 8 'classTab' 1536 8 'instanceTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 928 34 2 8 1140916738 1 1840 590662 2 ##(Smalltalk.ListModel) 138 144 34 2 1504 1136 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) nil nil 1 nil nil nil 1840 nil 8 1660489200 787814 3 ##(Smalltalk.BlockClosure) 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 2032 7 257 nil 2018 0 nil 2050 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 2096 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #smallIcons nil nil nil nil nil 1266 138 144 34 3 1330 #createAt:extent: 34 2 482 1 1 482 511 51 1840 1330 #basicSelectionsByIndex: 34 1 8 #(1) 1840 1330 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 1840 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 25 0 0 0] 8 #() 1472 nil 27 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 1 575 482 511 51 928 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 31 1 0 0 255 0 0 0 56 1 0 0] 34 3 1536 1168 1840 1472 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 2610 #fixedParentRight 1 2610 #fixedParentBottom -99 2610 #fixedViewTop 51 410 ##(Smalltalk.PushButton) 34 20 nil 800 34 2 8 1140858880 1 2688 nil 994 #silver nil 5 nil nil nil 2688 nil 8 1660261440 1180998 4 ##(Smalltalk.CommandDescription) #gotoClassDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 1 625 482 511 51 2688 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 255 0 0 0 81 1 0 0] 8 #() 1472 nil 29 2578 2624 1 2640 1 2656 -49 2656 1 410 ##(Smalltalk.CardContainer) 34 16 nil 800 34 2 8 1409286144 131073 2992 nil 1008 nil 5 nil nil nil 2992 1026 138 144 34 2 1090 1122 8 'Hierarchy' nil nil 410 ##(Smalltalk.TreeView) 34 27 nil 2992 34 2 8 1409356327 1025 3152 590918 3 ##(Smalltalk.TreeModel) nil 1984 525062 ##(Smalltalk.TreeNode) nil nil nil 170 192 1248 1008 nil 21 nil nil nil 3152 nil 8 1660723264 2018 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 2016 8 'doIt' 8 '[:each | each displayString]' 8 #[30 105 226 0 106] #displayString 3312 7 257 nil ##(Smalltalk.IconicListAbstract) 2160 nil 2018 0 nil 3330 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 3408 7 257 nil 2018 0 nil 3330 5 1 2016 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 3488 7 257 nil nil nil 170 176 1248 33 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 1248 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 9 53 482 495 515 3152 1410 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 251 0 0 0 27 1 0 0] 8 #() 1472 nil 27 1090 1122 8 'Classes' nil nil 410 ##(Smalltalk.ListView) 34 30 nil 2992 34 2 8 1409372237 1025 3808 1906 138 144 1248 nil 1984 1008 nil 21 nil nil nil 3808 nil 8 1660151920 459270 ##(Smalltalk.Message) #displayString 8 #() nil 2160 nil nil nil nil nil nil 138 144 34 1 920646 5 ##(Smalltalk.ListViewColumn) 8 '' 487 #left 3922 #displayString 8 #() 3922 #<= 8 #() nil nil 3808 nil 3 nil 2018 0 nil 3330 5 1 2016 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 4112 7 257 nil #report 1248 nil 131169 nil 34 4 nil nil 482 1 1 nil 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 9 53 482 495 515 3808 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 251 0 0 0 27 1 0 0] 8 #() 1472 nil 27 3808 170 192 34 4 3808 8 'classList' 3152 8 'classHierarchy' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 2992 34 2 8 1140916736 1 4448 1906 138 144 34 2 3776 3120 nil 1984 nil nil 1 nil nil nil 4448 nil 8 1660489200 2018 0 nil 2050 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 4576 7 257 nil 2018 0 nil 2050 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 4624 7 257 nil 2160 nil nil nil nil nil #smallIcons nil nil nil nil nil 1266 138 144 34 3 1330 #createAt:extent: 34 2 482 1 1 482 511 575 4448 1330 #basicSelectionsByIndex: 34 1 8 #(1) 4448 1330 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 4448 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 31 1 0 0] 8 #() 1472 nil 27 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 1 1 482 511 575 2992 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 31 1 0 0] 34 3 3808 3152 4448 1472 nil 27 2578 2624 1 2640 1 2610 #fixedParentTop 1 2656 -99 170 192 34 6 928 8 'instanceClassTabs' 2688 8 'definedPackageClassText' 2992 8 'classHierarchyTabs' nil 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 871 1 482 511 675 800 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 179 1 0 0 0 0 0 0 178 2 0 0 81 1 0 0] 34 3 2992 928 2688 1472 nil 27 524806 ##(Smalltalk.Fraction) 7 11 410 ##(Smalltalk.ListView) 34 30 nil 688 34 2 8 1409405261 1025 5376 1906 138 144 1248 nil 1984 1008 nil 5 nil nil nil 5376 nil 8 1660151920 3922 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 2160 nil nil nil nil nil nil 138 144 34 1 4002 8 'Column 1' 333 #left 2018 0 nil 3330 2 1 2016 8 'doIt' 8 '[:each | each displayName]' 8 #[30 105 226 0 106] #displayName 5584 7 257 nil ##(Smalltalk.SortedCollection) nil nil 5376 nil 3 2018 0 nil 3330 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 5664 7 257 nil 2018 0 nil 3330 3 1 2016 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 5744 7 257 nil #report 1248 nil 133217 nil 34 4 nil nil 482 1 1 nil 1266 138 144 34 2 1330 #createAt:extent: 34 2 482 1 1 482 341 675 5376 1330 #text: 34 1 8 'Column 1' 5376 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 170 0 0 0 81 1 0 0] 8 #() 1472 nil 27 5346 5 11 410 ##(Smalltalk.ContainerView) 34 15 nil 688 34 2 8 1140850688 131073 6080 nil nil nil 5 nil nil nil 6080 514 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 6080 34 2 8 1409286144 131073 6192 nil 1008 nil 5 nil nil nil 6192 1026 138 144 1248 nil 170 192 1248 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 6192 34 2 8 1140916736 1 6304 1906 138 144 1248 nil 1984 nil nil 1 nil nil nil 6304 nil 8 1660489200 2018 0 nil 2050 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 6416 7 257 nil 2018 0 nil 2050 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 6464 7 257 nil 2160 nil nil nil nil nil #noIcons nil nil nil nil nil 1266 138 144 34 2 1330 #createAt:extent: 34 2 482 1 1 482 511 675 6304 1330 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 6304 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 81 1 0 0] 8 #() 1472 nil 27 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 1 1 482 511 675 6192 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 81 1 0 0] 34 1 6304 1472 nil 27 3 false 170 192 34 2 6192 8 'packageDictionaryCards' nil 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 351 1 482 511 675 6080 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 175 0 0 0 0 0 0 0 174 1 0 0 81 1 0 0] 34 1 6192 1472 nil 27 5346 7 11 false 170 192 34 2 5376 8 'projectList' nil 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 1 1 482 2241 675 688 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 7 5376 410 ##(Smalltalk.Splitter) 34 12 nil 688 34 2 8 1140850688 1 7296 nil 1008 nil 517 nil nil nil 1510470 1 ##(Smalltalk.DraggableViewInteractor) 7296 nil 1 #left nil nil nil 482 1 1 482 9 9 nil 7392 nil 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 341 1 482 11 675 7296 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 170 0 0 0 0 0 0 0 175 0 0 0 81 1 0 0] 8 #() 1472 nil 27 6080 410 ##(Smalltalk.Splitter) 34 12 nil 688 34 2 8 1140850688 1 7584 nil 1008 nil 517 nil nil nil 7362 7584 nil 1 #left nil nil nil 7392 7408 nil 7392 nil 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 861 1 482 11 675 7584 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 174 1 0 0 0 0 0 0 179 1 0 0 81 1 0 0] 8 #() 1472 nil 27 800 410 ##(Smalltalk.Splitter) 34 12 nil 688 34 2 8 1140850688 1 7824 nil 1008 nil 517 nil nil nil 7362 7824 nil 1 #left nil nil nil 7392 7408 nil 7392 nil 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 1381 1 482 11 675 7824 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 178 2 0 0 0 0 0 0 183 2 0 0 81 1 0 0] 8 #() 1472 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 688 34 2 8 1140850688 131073 8064 nil nil nil 5 nil nil nil 8064 514 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 8064 34 2 8 1140850688 131073 8176 nil nil nil 5 nil nil nil 8176 866 170 176 34 6 410 ##(Smalltalk.ListView) 34 30 nil 8176 34 2 8 1409372233 1025 8288 1906 138 144 1248 nil 1984 1008 nil 13 nil nil nil 8288 nil 8 1660151920 3922 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 2160 nil nil nil nil nil nil 138 144 34 2 4002 8 '' 41 #left 1330 #empty 8 #() 16 3922 #<= 8 #() nil nil 8288 2018 0 nil 3330 2 1 2016 8 'doIt' 8 '[:each | each subSuperIcon]' 8 #[30 105 226 0 106] #subSuperIcon 8560 7 257 nil 1 nil nil 4002 8 'Selector' 421 #left 3922 #displayString 8416 ##(Smalltalk.SortedCollection) nil nil 8288 nil 3 nil 2018 0 nil 3330 5 1 2016 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 8688 7 257 nil #report 1248 nil 133221 nil 34 4 nil nil 482 1 1 nil 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 1 55 482 469 571 8288 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 27 0 0 0 234 0 0 0 56 1 0 0] 8 #() 1472 nil 27 2578 2624 1 2640 1 5088 55 2656 -49 410 ##(Smalltalk.PushButton) 34 20 nil 8176 34 2 8 1140858880 1 8976 nil 1008 nil 5 nil nil nil 8976 nil 8 1660261440 2786 #gotoMethodDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 1 625 482 469 51 8976 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 234 0 0 0 81 1 0 0] 8 #() 1472 nil 29 2578 2624 1 2640 1 2656 -49 2656 1 410 ##(Smalltalk.TextEdit) 34 16 nil 8176 34 2 8 1140916352 1025 9248 nil 1008 nil 5 nil nil nil 9248 nil 8 1660100096 852486 ##(Smalltalk.NullConverter) nil nil 3 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 1 1 482 469 51 9248 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 234 0 0 0 25 0 0 0] 8 #() 1472 nil 27 2578 2624 1 2640 1 5088 1 5088 51 170 192 34 6 8288 8 'methodList' 8976 8 'definedPackageMethodText' 9248 8 'categoryMethodText' nil 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 383 1 482 469 675 8176 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 191 0 0 0 0 0 0 0 169 1 0 0 81 1 0 0] 34 3 8288 8976 9248 1472 nil 27 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 244 63 false 170 192 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 8064 34 2 8 1409286144 131073 9840 nil 1008 nil 5 nil nil nil 9840 1026 138 144 34 2 1090 8 'Category' 410 ##(Smalltalk.ListView) 34 30 nil 9840 34 2 8 1409372233 1025 9984 1906 138 144 1248 nil 1984 1008 nil 21 nil nil nil 9984 nil 8 1660151920 3922 #displayString 8 #() nil 2160 nil nil nil nil nil nil 138 144 34 1 4002 8 'Column 1' 349 #left 3922 #displayString 8 #() ##(Smalltalk.SortedCollection) 2018 0 nil 3330 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each]' 1779525917 10224 7 257 nil nil 9984 nil 3 nil nil #report 1248 nil 131169 nil 34 4 nil nil 482 1 1 nil 1266 138 144 34 2 1330 #createAt:extent: 34 2 482 9 53 482 357 615 9984 1330 #text: 34 1 8 'Column 1' 9984 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 182 0 0 0 77 1 0 0] 8 #() 1472 nil 27 1090 8 'Variables' 410 ##(Smalltalk.ListView) 34 30 nil 9840 34 2 8 1409372233 1025 10560 1906 138 144 1248 nil 1984 1008 nil 21 nil nil nil 10560 nil 8 1660151920 3922 #displayString 8 #() nil 2160 nil nil 2018 0 nil 3330 4 1 2016 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 10704 7 257 nil nil nil nil 138 144 34 1 4002 8 'Column 1' 349 #left 3922 #displayString 10688 ##(Smalltalk.SortedCollection) nil nil 10560 nil 3 nil 2018 0 nil 3330 4 1 2016 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 10864 7 257 nil #report 1248 nil 131169 nil 34 4 nil nil 482 1 1 nil 1266 138 144 34 2 1330 #createAt:extent: 34 2 482 9 53 482 357 615 10560 1330 #text: 34 1 8 'Column 1' 10560 1410 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 182 0 0 0 77 1 0 0] 8 #() 1472 nil 27 9984 170 192 34 4 10560 8 'variableList' 9984 8 'categoryList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 9840 34 2 8 1140916736 1 11248 1906 138 144 34 2 9968 10544 nil 1984 nil nil 1 nil nil nil 11248 nil 8 1660489200 2018 0 nil 2050 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 11376 7 257 nil 2018 0 nil 2050 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 11424 7 257 nil 2160 nil nil nil nil nil #noIcons nil nil nil nil nil 1266 138 144 34 3 1330 #createAt:extent: 34 2 482 1 1 482 373 675 11248 1330 #basicSelectionsByIndex: 34 1 8 #(1) 11248 1330 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 11248 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 186 0 0 0 81 1 0 0] 8 #() 1472 nil 27 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 1 1 482 373 675 9840 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 186 0 0 0 81 1 0 0] 34 3 9984 10560 11248 1472 nil 27 8 'methodFilterTabs' nil 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 1391 1 482 851 675 8064 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 183 2 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 3 9840 410 ##(Smalltalk.Splitter) 34 12 nil 8064 34 2 8 1140850688 1 12048 nil 1008 nil 517 nil nil nil 7362 12048 nil 1 #left nil nil nil 7392 7408 nil 7392 nil 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 373 1 482 11 675 12048 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 186 0 0 0 0 0 0 0 191 0 0 0 81 1 0 0] 8 #() 1472 nil 27 8176 1472 nil 27 1472 nil 27 7 false 170 192 1248 nil 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 1 1 482 2241 675 576 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 1 688 1472 nil 27 5346 3 5 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 12480 nil 1008 nil 5 nil nil nil 12480 1026 138 144 34 5 1090 1122 8 'SUnit' 2018 0 nil 3330 4 1 2016 8 'doIt' 8 '[Icon fromId: ''icons\UnitTestPlugin.ico'']' 8 #[32 105 45 30 178 106] 983558 ##(Smalltalk.VariableBinding) #Icon ##(Smalltalk.Icon) 8 'icons\UnitTestPlugin.ico' #fromId: 12640 7 1 nil nil 410 ##(Smalltalk.ReferenceView) 34 14 nil 12480 34 2 8 1140850688 131073 12768 nil 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 nil nil nil 12768 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteSUnitInClassPresenter) #resource_Default_view nil 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 9 53 482 2225 615 12768 1410 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 92 4 0 0 77 1 0 0] 1248 1472 nil 27 1090 1122 8 'Class Definition' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 12480 34 2 8 1445007428 1025 13088 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 12834 26337781 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 11 984134 2 ##(Smalltalk.CommandMenuItem) 1 2786 #editSave 8 '&Save' 9383 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 13282 1 2786 #editUndo 8 '&Undo' 9397 1 nil nil nil 13282 1 2786 #editRedo 8 '&Redo' 9395 1 nil nil nil 13346 4097 13282 1 2786 #editCut 8 'Cu&t' 9393 1 nil nil nil 13282 1 2786 #editCopy 8 '&Copy' 9351 1 nil nil nil 13282 1 2786 #editPaste 8 '&Paste' 9389 1 nil nil nil 13282 1 2786 #editDelete 8 '&Delete' 1629 1 nil nil nil 13346 4097 13282 1 2786 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 13088 nil 8 1631769023 9330 nil nil 13 nil 170 192 34 4 #normal 1182790 1 ##(Smalltalk.ScintillaTextStyle) 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 13922 77 994 #gray 994 #white 1 nil nil nil nil #callTip nil nil nil 34 256 13936 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 13952 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1639686 ##(Smalltalk.SmalltalkExpressionStyler) 1 nil nil false 138 144 1248 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 13088 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1248 nil 170 176 1248 9215 nil nil nil nil 2752 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 13936 nil nil nil nil 1 nil 170 192 34 6 1 1510470 3 ##(Smalltalk.ScintillaIndicatorStyle) 1 13088 12834 65025 3 false 1 nil nil nil nil nil nil 3 14354 3 13088 994 #blue 5 false 3 nil nil nil nil nil nil 5 14354 5 13088 994 #red 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 13922 1027 12834 60239 12834 31326207 1 nil nil nil nil #Warning nil nil nil #Error 13922 1031 12834 335 12834 31317503 1 nil nil nil nil #Error nil nil nil #Notification 13922 1029 nil 12834 31185883 1 nil nil nil nil #Notification nil nil nil nil 1266 138 144 34 9 1330 #createAt:extent: 34 2 482 9 53 482 2225 615 13088 1330 #contextMenu: 34 1 13248 13088 1330 #textLimit: 8 #(1073741823) 13088 1330 #caretPeriod: 8 #(530) 13088 1330 #wordWrap: 8 #(true) 13088 1330 #margins: 34 1 34 3 985158 3 ##(Smalltalk.ScintillaMargin) 1 13088 1 3 nil nil 5 nil 14914 3 13088 33 nil 3 67108863 5 nil 14914 5 13088 1 nil 3 -67108863 5 nil 13088 1330 #tabWidth: 8 #(4) 13088 1330 #maxCompletionListHeight: 8 #(9) 13088 1330 #edgeColumn: 8 #(1) 13088 1410 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1472 nil 29 1090 1122 8 'Class Documentation' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 12480 34 2 8 1445007428 1025 15168 13154 nil false 13200 nil 12834 26337781 nil 5 13234 nil true 34 1 13282 1 2786 #editSaveClassComment 8 'Save' 1025 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 13762 nil true 13794 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 15168 nil 8 1631769023 9330 nil nil 15 nil 170 192 34 4 #normal 13922 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 13922 77 13968 13984 1 nil nil nil nil #callTip nil nil nil 34 256 15488 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 15504 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 14098 1 nil nil nil 15168 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1248 nil 170 176 1248 9215 nil nil nil nil 2752 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 15488 nil nil nil nil 1 nil 170 192 34 6 1 14354 1 15168 12834 65025 3 false 1 nil nil nil nil nil nil 3 14354 3 15168 14416 5 false 3 nil nil nil nil nil nil 5 14354 5 15168 14448 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 13922 1027 12834 60239 12834 31326207 1 nil nil nil nil #Warning nil nil nil #Error 13922 1031 12834 335 12834 31317503 1 nil nil nil nil #Error nil nil nil #Notification 13922 1029 nil 12834 31185883 1 nil nil nil nil #Notification nil nil nil nil 1266 138 144 34 10 1330 #createAt:extent: 34 2 482 9 53 482 2225 615 15168 1330 #contextMenu: 34 1 15264 15168 1330 #textLimit: 8 #(1073741823) 15168 1330 #hoverTime: 8 #(1000000) 15168 1330 #caretPeriod: 8 #(530) 15168 1330 #wordWrap: 8 #(true) 15168 1330 #margins: 34 1 34 3 14914 1 15168 1 3 nil nil 5 nil 14914 3 15168 33 nil 3 67108863 5 nil 14914 5 15168 1 nil 3 -67108863 5 nil 15168 1330 #tabWidth: 8 #(4) 15168 1330 #maxCompletionListHeight: 8 #(9) 15168 1330 #edgeColumn: 8 #(1) 15168 1410 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1472 nil 29 1090 1122 8 'Method Source' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 12480 34 2 8 1445007428 1025 16544 13154 nil false 13200 nil 12834 26337781 nil 5 nil 13762 nil true 13794 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 16544 nil 8 1631769023 9330 nil nil 13 nil 170 192 34 4 #normal 13922 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 13922 77 13968 13984 1 nil nil nil nil #callTip nil nil nil 34 256 16768 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 16784 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 1248 170 192 34 2 #default 14098 1 nil nil nil 16544 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1248 nil 170 176 1248 9215 nil nil nil nil 2752 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 4 #normal 16768 #callTip 16784 nil nil nil nil 1 nil 170 192 34 12 1 14354 1 16544 12834 65025 3 false 1 nil nil nil nil nil nil 8 'indicator9' 14354 19 16544 14448 13 nil nil nil nil nil nil nil nil 8 'indicator10' 14354 21 16544 14448 3 nil nil nil nil nil nil nil nil 3 14354 3 16544 14416 5 false 3 nil nil nil nil nil nil 8 'indicator8' 14354 17 16544 2752 1 nil nil nil nil nil nil nil nil 5 14354 5 16544 14448 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 13922 1027 12834 60239 12834 31326207 1 nil nil nil nil #Warning nil nil nil #Error 13922 1031 12834 335 12834 31317503 1 nil nil nil nil #Error nil nil nil #Notification 13922 1029 nil 12834 31185883 1 nil nil nil nil #Notification nil nil nil nil 1266 138 144 34 9 1330 #createAt:extent: 34 2 482 9 53 482 2225 615 16544 1330 #textLimit: 8 #(1073741823) 16544 1330 #hoverTime: 8 #(500) 16544 1330 #caretPeriod: 8 #(530) 16544 1330 #wordWrap: 8 #(true) 16544 1330 #margins: 34 1 34 3 14914 1 16544 61 3 nil nil 5 nil 14914 3 16544 1 nil 3 67108863 nil nil 14914 5 16544 1 nil 3 -67108863 nil nil 16544 1330 #tabWidth: 8 #(4) 16544 1330 #maxCompletionListHeight: 8 #(9) 16544 1330 #edgeColumn: 8 #(1) 16544 1410 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1472 nil 29 1090 1122 8 'Comparison' nil nil 410 ##(Smalltalk.ShellView) 34 27 nil 12480 34 2 8 1078919168 131073 17984 nil 1008 nil 517 nil nil nil 17984 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 17984 34 2 8 1140850688 131073 18080 nil 12834 26337781 nil 5 13234 nil true 34 5 13282 1 2786 #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 13282 1 2786 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 13282 1 2786 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 13282 1 2786 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 13282 1 2786 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 18080 514 170 176 1248 false 170 192 1248 nil 1266 138 144 34 2 1330 #createAt:extent: 34 2 482 1 1 482 2193 583 18080 1330 #contextMenu: 34 1 18160 18080 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 4 0 0 35 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 18080 34 2 8 1140850688 131073 18688 nil 1008 nil 5 nil nil nil 18688 18050 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 18688 34 2 8 1140850945 262145 18768 nil nil nil 5 nil nil nil 18768 nil 8 1660258976 9330 nil nil nil 1266 138 144 34 2 1330 #createAt:extent: 34 2 482 1 543 482 1091 41 18768 1330 #text: 34 1 8 '
' 18768 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 15 1 0 0 33 2 0 0 35 1 0 0] 8 #() 1472 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 18688 34 2 8 1140920580 1025 19072 13154 nil false 13200 nil 12834 26337781 nil 5 nil nil nil 19072 nil 8 1631769023 9330 nil nil 11 nil 170 192 34 12 #lineNumber 13922 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 13922 77 13968 13984 1 nil nil nil nil #callTip nil nil nil #indentGuide 13922 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #normal 13922 1 nil nil 1 nil nil nil nil #normal nil nil nil #whitespace 13922 3 994 #teal nil 1 nil nil nil nil #whitespace nil nil nil #diff 13922 5 nil 12834 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 19280 19296 19328 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 19232 nil nil nil 19264 nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 14098 1 nil nil nil 19072 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1248 nil 170 176 1248 9215 nil nil nil nil 2752 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 19200 nil nil nil nil 1 nil 170 192 34 6 8 'indicator0' 14354 1 19072 14448 13 false nil nil nil nil nil nil nil 8 'indicator2' 14354 5 19072 14448 1 false nil nil nil nil nil nil nil 8 'indicator1' 14354 3 19072 14416 5 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 13922 1027 12834 60239 12834 31326207 1 nil nil nil nil #Warning nil nil nil #Error 13922 1031 12834 335 12834 31317503 1 nil nil nil nil #Error nil nil nil #Notification 13922 1029 nil 12834 31185883 1 nil nil nil nil #Notification nil nil nil nil 1266 138 144 34 8 1330 #createAt:extent: 34 2 482 1 1 482 1091 543 19072 1330 #textLimit: 8 #(1073741823) 19072 1330 #caretPeriod: 8 #(530) 19072 1330 #wordWrap: 8 #(true) 19072 1330 #margins: 34 1 34 3 14914 1 19072 49 3 nil nil nil nil 14914 3 19072 1 nil nil 67108863 nil nil 14914 5 19072 1 nil nil nil nil nil 19072 1330 #canHScroll: 8 #(false) 19072 1330 #maxCompletionListHeight: 8 #(9) 19072 1330 #edgeColumn: 8 #(1) 19072 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 15 1 0 0] 8 #() 1472 nil 29 170 192 34 4 18768 8 'beforeTitle' 19072 8 'before' nil 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 1 1 482 1091 583 18688 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 35 1 0 0] 34 2 19072 18768 1472 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 18080 34 2 8 1140850688 1 20512 nil 12834 66047 nil 517 nil nil nil 7362 20512 nil 1 #left nil nil nil 7392 7408 nil 7392 nil 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 1091 1 482 11 583 20512 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 33 2 0 0 0 0 0 0 38 2 0 0 35 1 0 0] 8 #() 1472 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 18080 34 2 8 1140850688 131073 20768 nil 1008 nil 5 nil nil nil 20768 18050 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 20768 34 2 8 1140850945 262145 20848 nil nil nil 5 nil nil nil 20848 nil 8 1660258976 9330 nil nil nil 1266 138 144 34 2 1330 #createAt:extent: 34 2 482 1 543 482 1093 41 20848 1330 #text: 34 1 8 '
' 20848 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 15 1 0 0 34 2 0 0 35 1 0 0] 8 #() 1472 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 20768 34 2 8 1140920580 1025 21152 13154 nil false 13200 nil 12834 26337781 nil 5 nil nil nil 21152 nil 8 1631769023 9330 nil nil 11 nil 170 192 34 12 #lineNumber 13922 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 13922 77 13968 13984 1 nil nil nil nil #callTip nil nil nil #indentGuide 13922 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #normal 13922 1 nil nil 1 nil nil nil nil #normal nil nil nil #whitespace 13922 3 19312 nil 1 nil nil nil nil #whitespace nil nil nil #diff 13922 5 nil 12834 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 21360 21376 21392 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 21312 nil nil nil 21344 nil nil 19378 19408 170 192 34 2 #default 14098 1 nil nil nil 21152 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1248 nil 170 176 1248 9215 nil nil nil nil 2752 nil nil 65 nil nil nil 19504 3 170 192 34 2 #container 21280 nil nil nil nil 1 nil 170 192 34 6 8 'indicator0' 14354 1 21152 14448 13 false nil nil nil nil nil nil nil 8 'indicator1' 14354 3 21152 14416 5 false nil nil nil nil nil nil nil 8 'indicator2' 14354 5 21152 14448 1 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 13922 1027 12834 60239 12834 31326207 1 nil nil nil nil #Warning nil nil nil #Error 13922 1031 12834 335 12834 31317503 1 nil nil nil nil #Error nil nil nil #Notification 13922 1029 nil 12834 31185883 1 nil nil nil nil #Notification nil nil nil nil 1266 138 144 34 8 1330 #createAt:extent: 34 2 482 1 1 482 1093 543 21152 1330 #textLimit: 8 #(1073741823) 21152 1330 #caretPeriod: 8 #(530) 21152 1330 #wordWrap: 8 #(true) 21152 1330 #margins: 34 1 34 3 14914 1 21152 49 3 nil nil nil nil 14914 3 21152 1 nil nil 67108863 nil nil 14914 5 21152 1 nil nil nil nil nil 21152 1330 #canHScroll: 8 #(false) 21152 1330 #maxCompletionListHeight: 8 #(9) 21152 1330 #edgeColumn: 8 #(1) 21152 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 34 2 0 0 15 1 0 0] 8 #() 1472 nil 29 170 192 34 4 20848 8 'afterTitle' 21152 8 'after' nil 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 1101 1 482 1093 583 20768 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 38 2 0 0 0 0 0 0 72 4 0 0 35 1 0 0] 34 2 21152 20848 1472 nil 27 1472 nil 27 170 192 34 2 18080 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 13234 nil true 34 4 13282 1 2786 #selectUpper 8 'Select &upper' 1 1 nil nil nil 13282 1 2786 #selectLower 8 'Select &lower' 1 1 nil nil nil 13346 4097 13282 1 2786 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 65235 nil nil 13234 nil true 34 3 13282 1 2786 #character 8 '&Character' 1 1 nil nil nil 13282 1 2786 #word 8 '&Word' 1 1 nil nil nil 13282 1 2786 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 65237 nil nil 13234 nil true 34 1 13282 1 2786 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 65239 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1266 138 144 34 3 1330 #createAt:extent: 34 2 482 9 53 482 2225 615 17984 1330 #text: 34 1 8 'Comparison' 17984 1330 #updateMenuBar 1248 17984 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 92 4 0 0 77 1 0 0] 34 1 18080 1472 nil 27 17984 170 192 34 10 13088 8 'classDefinition' 16544 8 'methodSource' 12768 8 'sunit' 17984 8 'comparisonTab' 15168 8 'classDocumentation' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 12480 34 2 8 1140916736 1 23472 1906 138 144 34 5 13056 15136 16512 12608 17952 nil 1984 nil nil 1 nil nil nil 23472 nil 8 1660489200 2018 0 nil 2050 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 23600 7 257 nil 2018 0 nil 2050 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 23648 7 257 nil 2160 nil nil nil nil nil #smallIcons nil nil nil nil nil 1266 138 144 34 3 1330 #createAt:extent: 34 2 482 1 1 482 2241 675 23472 1330 #basicSelectionsByIndex: 34 1 8 #(5) 23472 1330 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 23472 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 8 #() 1472 nil 27 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 1 685 482 2241 675 12480 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 86 1 0 0 96 4 0 0 167 2 0 0] 34 6 13088 15168 16544 12768 17984 23472 1472 nil 27 5346 3 5 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 24112 nil nil 482 2241 43 517 nil nil nil 24112 866 170 176 34 4 410 ##(Smalltalk.ToolButton) 34 14 nil 24112 34 2 8 1140850688 131073 24240 nil nil nil 1029 nil nil nil 24240 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 24240 34 2 8 1140853580 131137 24304 nil nil 482 43 43 513 nil nil nil 24304 nil 8 1660202272 nil 170 192 34 2 65131 1115206 1 ##(Smalltalk.ToolbarIconButton) 24304 1 2786 #flipAutoCommit 8 'Auto Commit' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons/camera16_light_icon.ico' nil 65131 34 1 24448 nil nil 3 nil 482 33 33 482 33 33 nil nil 1266 138 144 34 2 1330 #createAt:extent: 34 2 482 1 1 482 43 43 24304 1330 #updateSizePosted 1248 24304 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 8 #() 1472 nil 27 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 1 1 482 43 43 24240 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 34 1 24304 1472 nil 27 2578 2624 1 2610 #fixedViewLeft 43 5088 1 2672 43 410 ##(Smalltalk.TextEdit) 34 16 nil 24112 34 2 8 1140850688 1 24992 nil 1008 482 2199 43 517 nil 13762 nil true 13794 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 482 193 193 nil 24992 994 #black 8 1660100096 9330 nil nil 67 1266 138 144 34 2 1330 #createAt:extent: 34 2 482 43 1 482 2199 43 24992 1330 #setMarginWidths: 34 1 8 #(3 3) 24992 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 21 0 0 0 0 0 0 0 96 4 0 0 21 0 0 0] 8 #() 1472 nil 27 2578 2624 43 2640 1 5088 1 2656 1 170 192 34 4 24240 8 'autoCommitButton' 24992 8 'statusBarField' nil 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 1 1359 482 2241 43 24112 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 167 2 0 0 96 4 0 0 188 2 0 0] 34 2 24240 24992 1472 nil 27 9778 8 184 30 133 235 81 184 158 63 true 170 192 34 4 12480 8 'textAreaTabs' 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 25696 nil 1008 nil 517 nil nil nil 7362 25696 nil 1 #left nil nil nil 7392 7408 nil 7392 nil 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 1 675 482 2241 11 25696 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 81 1 0 0 96 4 0 0 86 1 0 0] 8 #() 1472 nil 27 8 'splitter' nil 1266 138 144 34 1 1330 #createAt:extent: 34 2 482 7679 21 482 2241 1401 416 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 95 19 0 0 198 2 0 0] 34 4 576 25696 12480 24112 1472 nil 27 )! !
!JadeiteBrowserPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

