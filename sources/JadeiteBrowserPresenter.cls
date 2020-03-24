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
	^self basicAllSelectedProjectsDirty: projectListPresenter!

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
		to: self.
	comparisonPresenter beforePresenter
		when: #dragOver:
			send: #onDragOverSource:
			to: self;
		when: #drop:
			send: #onDropOnBefore:
			to: self.
	comparisonPresenter afterPresenter
		when: #dragOver:
			send: #onDragOverSource:
			to: self;
		when: #drop:
			send: #onDropOnAfter:
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

onDragOverSource: aDragDropSession
	aDragDropSession operation: nil.
	aDragDropSession dragObjects isEmpty ifTrue: [^self].
	aDragDropSession suggestedTarget isNil ifTrue: [^self].
	self setDragOperationsFor: aDragDropSession!

onDropOnAfter: aDragDropSession
	comparisonPresenter afterPresenter value: aDragDropSession suggestedSource source.
	comparisonPresenter refresh.
	aDragDropSession suggestedTarget: nil.	"nil out the suggestedTarget so the TextPresenter does not try to act on the drop"!

onDropOnBefore: aDragDropSession
	comparisonPresenter beforePresenter value: aDragDropSession suggestedSource source.
	comparisonPresenter refresh.
	aDragDropSession suggestedTarget: nil.	"nil out the suggestedTarget so the TextPresenter does not try to act on the drop"!

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
	update replicateFrom: classService.
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
!JadeiteBrowserPresenter categoriesFor: #editRevert!menu handlers!public! !
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
!JadeiteBrowserPresenter categoriesFor: #methodSelectionChanged!event handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #methodsMenuStrings!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #methodsUpdate:!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #methodToReformat!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #methodValueChanged!event handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #noClassSelectedInEitherPresenter!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #onDragMethod:!drag & drop!public! !
!JadeiteBrowserPresenter categoriesFor: #onDragOverSource:!drag & drop!public! !
!JadeiteBrowserPresenter categoriesFor: #onDropOnAfter:!drag & drop!public! !
!JadeiteBrowserPresenter categoriesFor: #onDropOnBefore:!drag & drop!public! !
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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil 328198 ##(Smalltalk.Point) 2241 1401 517 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 6 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 576 nil 327686 ##(Smalltalk.Color) #default nil 5 nil nil nil 576 655878 ##(Smalltalk.CardLayout) 138 144 34 5 721414 ##(Smalltalk.Association) 590662 1 ##(Smalltalk.CardLabel) 8 'SUnit' 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 4 1 816 8 'doIt' 8 '[Icon fromId: ''icons\UnitTestPlugin.ico'']' 8 #[32 105 45 30 178 106] 983558 ##(Smalltalk.VariableBinding) #Icon ##(Smalltalk.Icon) 8 'icons\UnitTestPlugin.ico' #fromId: 832 7 1 nil nil 410 ##(Smalltalk.ReferenceView) 34 14 nil 576 34 2 8 1140850688 131073 976 nil 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 nil nil nil 976 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteSUnitInClassPresenter) #resource_Default_view nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 482 9 53 482 2225 615 976 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 92 4 0 0 77 1 0 0] 8 #() 482 193 193 nil 27 738 770 8 'Class Definition' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 576 34 2 8 1445007428 1025 1376 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 1042 26337781 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 11 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #editSave 8 '&Save' 9383 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 1570 1 1602 #editUndo 8 '&Undo' 9397 1 nil nil nil 1570 1 1602 #editRedo 8 '&Redo' 9395 1 nil nil nil 1650 4097 1570 1 1602 #editCut 8 'Cu&t' 9393 1 nil nil nil 1570 1 1602 #editCopy 8 '&Copy' 9351 1 nil nil nil 1570 1 1602 #editPaste 8 '&Paste' 9389 1 nil nil nil 1570 1 1602 #editDelete 8 '&Delete' 1629 1 nil nil nil 1650 4097 1570 1 1602 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 1376 nil 8 1428148671 852486 ##(Smalltalk.NullConverter) nil nil 13 nil 170 192 34 4 #normal 1182790 1 ##(Smalltalk.ScintillaTextStyle) 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 2242 77 642 #gray 642 #white 1 nil nil nil nil #callTip nil nil nil 34 256 2256 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 2272 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1639686 ##(Smalltalk.SmalltalkExpressionStyler) 1 nil nil false 138 144 1296 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 1376 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1296 nil 170 176 1296 9215 nil nil nil nil 642 #silver nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 2256 nil nil nil nil 1 nil 170 192 34 6 1 1510470 3 ##(Smalltalk.ScintillaIndicatorStyle) 1 1376 1042 65025 3 false 1 nil nil nil nil nil nil 3 2690 3 1376 642 #blue 5 false 3 nil nil nil nil nil nil 5 2690 5 1376 642 #red 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 2242 1027 1042 60239 1042 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2242 1031 1042 335 1042 31317503 1 nil nil nil nil #Error nil nil nil #Notification 2242 1029 nil 1042 31185883 1 nil nil nil nil #Notification nil nil nil nil 1106 138 144 34 9 1170 #createAt:extent: 34 2 482 9 53 482 2225 615 1376 1170 #contextMenu: 34 1 1536 1376 1170 #textLimit: 8 #(1073741823) 1376 1170 #caretPeriod: 8 #(530) 1376 1170 #wordWrap: 8 #(true) 1376 1170 #margins: 34 1 34 3 985158 3 ##(Smalltalk.ScintillaMargin) 1 1376 1 3 nil nil 5 nil 3250 3 1376 33 nil 3 67108863 5 nil 3250 5 1376 1 nil 3 -67108863 5 nil 1376 1170 #tabWidth: 8 #(4) 1376 1170 #maxCompletionListHeight: 8 #(9) 1376 1170 #edgeColumn: 8 #(1) 1376 1250 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1312 nil 29 738 770 8 'Class Documentation' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 576 34 2 8 1445007428 1025 3504 1442 nil false 1488 nil 1042 26337781 nil 5 1522 nil true 34 1 1570 1 1602 #editSaveClassComment 8 'Save' 1025 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 2066 nil true 2098 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 3504 nil 8 1428148671 2178 nil nil 15 nil 170 192 34 4 #normal 2242 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 2242 77 2288 2304 1 nil nil nil nil #callTip nil nil nil 34 256 3824 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3840 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 2418 1 nil nil nil 3504 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1296 nil 170 176 1296 9215 nil nil nil nil 2480 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 3824 nil nil nil nil 1 nil 170 192 34 6 1 2690 1 3504 1042 65025 3 false 1 nil nil nil nil nil nil 3 2690 3 3504 2752 5 false 3 nil nil nil nil nil nil 5 2690 5 3504 2784 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 2242 1027 1042 60239 1042 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2242 1031 1042 335 1042 31317503 1 nil nil nil nil #Error nil nil nil #Notification 2242 1029 nil 1042 31185883 1 nil nil nil nil #Notification nil nil nil nil 1106 138 144 34 10 1170 #createAt:extent: 34 2 482 9 53 482 2225 615 3504 1170 #contextMenu: 34 1 3600 3504 1170 #textLimit: 8 #(1073741823) 3504 1170 #hoverTime: 8 #(1000000) 3504 1170 #caretPeriod: 8 #(530) 3504 1170 #wordWrap: 8 #(true) 3504 1170 #margins: 34 1 34 3 3250 1 3504 1 3 nil nil 5 nil 3250 3 3504 33 nil 3 67108863 5 nil 3250 5 3504 1 nil 3 -67108863 5 nil 3504 1170 #tabWidth: 8 #(4) 3504 1170 #maxCompletionListHeight: 8 #(9) 3504 1170 #edgeColumn: 8 #(1) 3504 1250 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1312 nil 29 738 770 8 'Method Source' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 576 34 2 8 1445007428 1025 4880 1442 nil false 1488 nil 1042 26337781 nil 5 nil 2066 nil true 2098 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 4880 nil 8 1428148671 2178 nil nil 13 nil 170 192 34 4 #normal 2242 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 2242 77 2288 2304 1 nil nil nil nil #callTip nil nil nil 34 256 5104 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 5120 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 1296 170 192 34 2 #default 2418 1 nil nil nil 4880 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1296 nil 170 176 1296 9215 nil nil nil nil 2480 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 4 #normal 5104 #callTip 5120 nil nil nil nil 1 nil 170 192 34 12 1 2690 1 4880 1042 65025 3 false 1 nil nil nil nil nil nil 8 'indicator10' 2690 21 4880 2784 3 nil nil nil nil nil nil nil nil 8 'indicator9' 2690 19 4880 2784 13 nil nil nil nil nil nil nil nil 3 2690 3 4880 2752 5 false 3 nil nil nil nil nil nil 8 'indicator8' 2690 17 4880 2480 1 nil nil nil nil nil nil nil nil 5 2690 5 4880 2784 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 2242 1027 1042 60239 1042 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2242 1031 1042 335 1042 31317503 1 nil nil nil nil #Error nil nil nil #Notification 2242 1029 nil 1042 31185883 1 nil nil nil nil #Notification nil nil nil nil 1106 138 144 34 9 1170 #createAt:extent: 34 2 482 9 53 482 2225 615 4880 1170 #textLimit: 8 #(1073741823) 4880 1170 #hoverTime: 8 #(500) 4880 1170 #caretPeriod: 8 #(530) 4880 1170 #wordWrap: 8 #(true) 4880 1170 #margins: 34 1 34 3 3250 1 4880 61 3 nil nil 5 nil 3250 3 4880 1 nil 3 67108863 nil nil 3250 5 4880 1 nil 3 -67108863 nil nil 4880 1170 #tabWidth: 8 #(4) 4880 1170 #maxCompletionListHeight: 8 #(9) 4880 1170 #edgeColumn: 8 #(1) 4880 1250 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1312 nil 29 738 770 8 'Comparison' nil nil 410 ##(Smalltalk.ShellView) 34 27 nil 576 34 2 8 1078919168 131073 6320 nil 656 nil 517 nil nil nil 6320 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 6320 34 2 8 1140850688 131073 6416 nil 1042 26337781 nil 5 1522 nil true 34 5 1570 1 1602 #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 1570 1 1602 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 1570 1 1602 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 1570 1 1602 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 1570 1 1602 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 6416 514 170 176 1296 false 170 192 1296 nil 1106 138 144 34 2 1170 #createAt:extent: 34 2 482 1 1 482 2193 583 6416 1170 #contextMenu: 34 1 6496 6416 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 4 0 0 35 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 6416 34 2 8 1140850688 131073 7024 nil 656 nil 5 nil nil nil 7024 6386 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 7024 34 2 8 1140850945 262145 7104 nil nil nil 21 nil nil nil 7104 nil 8 1650166432 2178 nil nil nil 1106 138 144 34 2 1170 #createAt:extent: 34 2 482 1 543 482 1091 41 7104 1170 #text: 34 1 8 '
' 7104 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 15 1 0 0 33 2 0 0 35 1 0 0] 8 #() 1312 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 7024 34 2 8 1140920580 1025 7408 1442 nil false 1488 nil 1042 26337781 nil 21 nil nil nil 7408 nil 8 1428148671 2178 nil nil 11 nil 170 192 34 12 #lineNumber 2242 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 2242 77 2288 2304 1 nil nil nil nil #callTip nil nil nil #indentGuide 2242 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #normal 2242 1 nil nil 1 nil nil nil nil #normal nil nil nil #whitespace 2242 3 642 #teal nil 1 nil nil nil nil #whitespace nil nil nil #diff 2242 5 nil 1042 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 7616 7632 7664 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 7568 nil nil nil 7600 nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 2418 1 nil nil nil 7408 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1296 nil 170 176 1296 9215 nil nil nil nil 2480 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 7536 nil nil nil nil 1 nil 170 192 34 2 #diff 2690 1 7408 642 #yellow 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 2242 1027 1042 60239 1042 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2242 1031 1042 335 1042 31317503 1 nil nil nil nil #Error nil nil nil #Notification 2242 1029 nil 1042 31185883 1 nil nil nil nil #Notification nil nil nil nil 1106 138 144 34 8 1170 #createAt:extent: 34 2 482 1 1 482 1091 543 7408 1170 #textLimit: 8 #(1073741823) 7408 1170 #caretPeriod: 8 #(530) 7408 1170 #wordWrap: 8 #(true) 7408 1170 #margins: 34 1 34 3 3250 1 7408 49 3 nil nil nil nil 3250 3 7408 1 nil nil 67108863 nil nil 3250 5 7408 1 nil nil nil nil nil 7408 1170 #canHScroll: 8 #(false) 7408 1170 #maxCompletionListHeight: 8 #(9) 7408 1170 #edgeColumn: 8 #(1) 7408 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 15 1 0 0] 8 #() 1312 nil 29 170 192 34 4 7408 8 'before' 7104 8 'beforeTitle' nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 1 482 1091 583 7024 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 35 1 0 0] 34 2 7408 7104 1312 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 6416 34 2 8 1140850688 1 8784 nil 1042 66047 nil 517 nil nil nil 1510470 1 ##(Smalltalk.DraggableViewInteractor) 8784 nil 1 #left nil nil nil 482 1 1 482 9 9 nil 8896 nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1091 1 482 11 583 8784 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 33 2 0 0 0 0 0 0 38 2 0 0 35 1 0 0] 8 #() 1312 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 6416 34 2 8 1140850688 131073 9088 nil 656 nil 5 nil nil nil 9088 6386 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 9088 34 2 8 1140850945 262145 9168 nil nil nil 21 nil nil nil 9168 nil 8 1650166432 2178 nil nil nil 1106 138 144 34 2 1170 #createAt:extent: 34 2 482 1 543 482 1093 41 9168 1170 #text: 34 1 8 '
' 9168 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 15 1 0 0 34 2 0 0 35 1 0 0] 8 #() 1312 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 9088 34 2 8 1140920580 1025 9472 1442 nil false 1488 nil 1042 26337781 nil 21 nil nil nil 9472 nil 8 1428148671 2178 nil nil 11 nil 170 192 34 12 #lineNumber 2242 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 2242 77 2288 2304 1 nil nil nil nil #callTip nil nil nil #indentGuide 2242 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #normal 2242 1 nil nil 1 nil nil nil nil #normal nil nil nil #whitespace 2242 3 7648 nil 1 nil nil nil nil #whitespace nil nil nil #diff 2242 5 nil 1042 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 9680 9696 9712 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 9632 nil nil nil 9664 nil nil 7714 7744 170 192 34 2 #default 2418 1 nil nil nil 9472 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1296 nil 170 176 1296 9215 nil nil nil nil 2480 nil nil 65 nil nil nil 7840 3 170 192 34 2 #container 9600 nil nil nil nil 1 nil 170 192 34 2 #diff 2690 1 9472 7936 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 2242 1027 1042 60239 1042 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2242 1031 1042 335 1042 31317503 1 nil nil nil nil #Error nil nil nil #Notification 2242 1029 nil 1042 31185883 1 nil nil nil nil #Notification nil nil nil nil 1106 138 144 34 8 1170 #createAt:extent: 34 2 482 1 1 482 1093 543 9472 1170 #textLimit: 8 #(1073741823) 9472 1170 #caretPeriod: 8 #(530) 9472 1170 #wordWrap: 8 #(true) 9472 1170 #margins: 34 1 34 3 3250 1 9472 49 3 nil nil nil nil 3250 3 9472 1 nil nil 67108863 nil nil 3250 5 9472 1 nil nil nil nil nil 9472 1170 #canHScroll: 8 #(false) 9472 1170 #maxCompletionListHeight: 8 #(9) 9472 1170 #edgeColumn: 8 #(1) 9472 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 34 2 0 0 15 1 0 0] 8 #() 1312 nil 29 170 192 34 4 9472 8 'after' 9168 8 'afterTitle' nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1101 1 482 1093 583 9088 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 38 2 0 0 0 0 0 0 72 4 0 0 35 1 0 0] 34 2 9472 9168 1312 nil 27 1312 nil 27 170 192 34 2 6416 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 1522 nil true 34 4 1570 1 1602 #selectUpper 8 'Select &upper' 1 1 nil nil nil 1570 1 1602 #selectLower 8 'Select &lower' 1 1 nil nil nil 1650 4097 1570 1 1602 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 22735 nil nil 1522 nil true 34 3 1570 1 1602 #character 8 '&Character' 1 1 nil nil nil 1570 1 1602 #word 8 '&Word' 1 1 nil nil nil 1570 1 1602 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 22737 nil nil 1522 nil true 34 1 1570 1 1602 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 22739 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1106 138 144 34 3 1170 #createAt:extent: 34 2 482 9 53 482 2225 615 6320 1170 #text: 34 1 8 'Comparison' 6320 1170 #updateMenuBar 1296 6320 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 92 4 0 0 77 1 0 0] 34 1 6416 1312 nil 27 6320 170 192 34 10 6320 8 'comparisonTab' 1376 8 'classDefinition' 4880 8 'methodSource' 976 8 'sunit' 3504 8 'classDocumentation' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 576 34 2 8 1140916736 1 11712 590662 2 ##(Smalltalk.ListModel) 138 144 34 5 1344 3472 4848 784 6288 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) nil nil 1 nil nil nil 11712 nil 8 1650396656 818 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 11888 7 257 nil 818 0 nil 11906 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 11952 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #smallIcons nil nil nil nil nil 1106 138 144 34 3 1170 #createAt:extent: 34 2 482 1 1 482 2241 675 11712 1170 #basicSelectionsByIndex: 34 1 8 #(5) 11712 1170 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 11712 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 8 #() 1312 nil 27 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 685 482 2241 675 576 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 86 1 0 0 96 4 0 0 167 2 0 0] 34 6 1376 3504 4880 976 6320 11712 1312 nil 27 524806 ##(Smalltalk.Fraction) 3 5 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 12464 nil nil nil 5 nil nil nil 12464 514 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 12464 34 2 8 1140850688 131073 12576 nil nil nil 5 nil nil nil 12576 514 170 176 34 6 410 ##(Smalltalk.ContainerView) 34 15 nil 12576 34 2 8 1140850688 131073 12688 nil nil nil 5 nil nil nil 12688 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.PushButton) 34 20 nil 12688 34 2 8 1140858880 1 12816 nil 2480 nil 5 nil nil nil 12816 nil 8 1650168896 1602 #gotoClassDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 625 482 511 51 12816 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 255 0 0 0 81 1 0 0] 8 #() 1312 nil 29 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 13106 #fixedParentRight 1 13106 #fixedParentBottom -49 13152 1 410 ##(Smalltalk.CardContainer) 34 16 nil 12688 34 2 8 1409286144 131073 13168 nil 656 nil 5 nil nil nil 13168 674 138 144 34 2 738 770 8 'Hierarchy' nil nil 410 ##(Smalltalk.TreeView) 34 27 nil 13168 34 2 8 1409356327 1025 13328 590918 3 ##(Smalltalk.TreeModel) nil 11856 525062 ##(Smalltalk.TreeNode) nil nil nil 170 192 1296 656 nil 21 nil nil nil 13328 nil 8 1650630720 818 0 nil 850 2 1 816 8 'doIt' 8 '[:each | each displayString]' 8 #[30 105 226 0 106] #displayString 13488 7 257 nil ##(Smalltalk.IconicListAbstract) 12016 nil 818 0 nil 850 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 13568 7 257 nil 818 0 nil 850 5 1 816 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 13648 7 257 nil nil nil 170 176 1296 33 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 1296 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 9 53 482 495 515 13328 1250 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 251 0 0 0 27 1 0 0] 8 #() 1312 nil 27 738 770 8 'Classes' nil nil 410 ##(Smalltalk.ListView) 34 30 nil 13168 34 2 8 1409372237 1025 13968 11778 138 144 1296 nil 11856 656 nil 21 nil nil nil 13968 nil 8 1650059376 459270 ##(Smalltalk.Message) #displayString 8 #() nil 12016 nil nil nil nil nil nil 138 144 34 1 920646 5 ##(Smalltalk.ListViewColumn) 8 '' 487 #left 14082 #displayString 8 #() 14082 #<= 8 #() nil nil 13968 nil 3 nil 818 0 nil 850 5 1 816 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 14272 7 257 nil #report 1296 nil 131169 nil 34 4 nil nil 482 1 1 nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 9 53 482 495 515 13968 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 251 0 0 0 27 1 0 0] 8 #() 1312 nil 27 13968 170 192 34 4 13328 8 'classHierarchy' 13968 8 'classList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 13168 34 2 8 1140916736 1 14608 11778 138 144 34 2 13936 13296 nil 11856 nil nil 1 nil nil nil 14608 nil 8 1650396656 818 0 nil 11906 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 14736 7 257 nil 818 0 nil 11906 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 14784 7 257 nil 12016 nil nil nil nil nil #smallIcons nil nil nil nil nil 1106 138 144 34 3 1170 #createAt:extent: 34 2 482 1 1 482 511 575 14608 1170 #basicSelectionsByIndex: 34 1 8 #(1) 14608 1170 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 14608 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 31 1 0 0] 8 #() 1312 nil 27 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 1 482 511 575 13168 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 31 1 0 0] 34 3 13968 13328 14608 1312 nil 27 13074 13120 1 13136 1 13106 #fixedParentTop 1 13152 -99 410 ##(Smalltalk.CardContainer) 34 16 nil 12688 34 2 8 1409286144 131073 15264 nil 656 nil 5 nil nil nil 15264 674 138 144 34 2 738 770 8 'Class' nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 15264 34 2 8 1140850688 131073 15424 nil nil nil 5 nil nil nil 15424 nil 170 192 1296 nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 9 9 482 495 1 15424 1250 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 251 0 0 0 4 0 0 0] 8 #() 1312 nil 27 738 770 8 'Instance' nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 15264 34 2 8 1140850688 131073 15712 nil nil nil 5 nil nil nil 15712 nil 170 192 1296 nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 9 9 482 495 1 15712 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 251 0 0 0 4 0 0 0] 8 #() 1312 nil 27 15712 170 192 34 4 15712 8 'instanceTab' 15424 8 'classTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 15264 34 2 8 1140916738 1 16016 11778 138 144 34 2 15680 15392 nil 11856 nil nil 1 nil nil nil 16016 nil 8 1650396656 818 0 nil 11906 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 16144 7 257 nil 818 0 nil 11906 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 16192 7 257 nil 12016 nil nil nil nil nil #smallIcons nil nil nil nil nil 1106 138 144 34 3 1170 #createAt:extent: 34 2 482 1 1 482 511 51 16016 1170 #basicSelectionsByIndex: 34 1 8 #(1) 16016 1170 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 16016 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 25 0 0 0] 8 #() 1312 nil 27 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 575 482 511 51 15264 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 31 1 0 0 255 0 0 0 56 1 0 0] 34 3 15712 15424 16016 1312 nil 27 13074 13120 1 13136 1 13152 -99 13106 #fixedViewTop 51 170 192 34 6 12816 8 'definedPackageClassText' 13168 8 'classHierarchyTabs' 15264 8 'instanceClassTabs' nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 871 1 482 511 675 12688 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 179 1 0 0 0 0 0 0 178 2 0 0 81 1 0 0] 34 3 13168 15264 12816 1312 nil 27 12434 7 11 410 ##(Smalltalk.ContainerView) 34 15 nil 12576 34 2 8 1140850688 131073 16928 nil nil nil 5 nil nil nil 16928 514 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 16928 34 2 8 1409286144 131073 17040 nil 656 nil 5 nil nil nil 17040 674 138 144 1296 nil 170 192 1296 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 17040 34 2 8 1140916736 1 17152 11778 138 144 1296 nil 11856 nil nil 1 nil nil nil 17152 nil 8 1650396656 818 0 nil 11906 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 17264 7 257 nil 818 0 nil 11906 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 17312 7 257 nil 12016 nil nil nil nil nil #noIcons nil nil nil nil nil 1106 138 144 34 2 1170 #createAt:extent: 34 2 482 1 1 482 511 675 17152 1170 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 17152 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 81 1 0 0] 8 #() 1312 nil 27 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 1 482 511 675 17040 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 81 1 0 0] 34 1 17152 1312 nil 27 3 false 170 192 34 2 17040 8 'packageDictionaryCards' nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 351 1 482 511 675 16928 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 175 0 0 0 0 0 0 0 174 1 0 0 81 1 0 0] 34 1 17040 1312 nil 27 12434 7 11 410 ##(Smalltalk.ListView) 34 30 nil 12576 34 2 8 1409405261 1025 17936 11778 138 144 1296 nil 11856 656 nil 5 nil nil nil 17936 nil 8 1650059376 14082 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 12016 nil nil nil nil nil nil 138 144 34 1 14162 8 'Column 1' 333 #left 818 0 nil 850 2 1 816 8 'doIt' 8 '[:each | each displayName]' 8 #[30 105 226 0 106] #displayName 18144 7 257 nil ##(Smalltalk.SortedCollection) nil nil 17936 nil 3 818 0 nil 850 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 18224 7 257 nil 818 0 nil 850 3 1 816 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 18304 7 257 nil #report 1296 nil 133217 nil 34 4 nil nil 482 1 1 nil 1106 138 144 34 2 1170 #createAt:extent: 34 2 482 1 1 482 341 675 17936 1170 #text: 34 1 8 'Column 1' 17936 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 170 0 0 0 81 1 0 0] 8 #() 1312 nil 27 12434 5 11 false 170 192 34 2 17936 8 'projectList' nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 1 482 2241 675 12576 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 7 17936 410 ##(Smalltalk.Splitter) 34 12 nil 12576 34 2 8 1140850688 1 18848 nil 656 nil 517 nil nil nil 8866 18848 nil 1 #left nil nil nil 8896 8912 nil 8896 nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 341 1 482 11 675 18848 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 170 0 0 0 0 0 0 0 175 0 0 0 81 1 0 0] 8 #() 1312 nil 27 16928 410 ##(Smalltalk.Splitter) 34 12 nil 12576 34 2 8 1140850688 1 19088 nil 656 nil 517 nil nil nil 8866 19088 nil 1 #left nil nil nil 8896 8912 nil 8896 nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 861 1 482 11 675 19088 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 174 1 0 0 0 0 0 0 179 1 0 0 81 1 0 0] 8 #() 1312 nil 27 12688 410 ##(Smalltalk.Splitter) 34 12 nil 12576 34 2 8 1140850688 1 19328 nil 656 nil 517 nil nil nil 8866 19328 nil 1 #left nil nil nil 8896 8912 nil 8896 nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1381 1 482 11 675 19328 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 178 2 0 0 0 0 0 0 183 2 0 0 81 1 0 0] 8 #() 1312 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 12576 34 2 8 1140850688 131073 19568 nil nil nil 5 nil nil nil 19568 514 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 19568 34 2 8 1140850688 131073 19680 nil nil nil 5 nil nil nil 19680 12754 170 176 34 6 410 ##(Smalltalk.ListView) 34 30 nil 19680 34 2 8 1409372233 1025 19792 11778 138 144 1296 nil 11856 656 nil 13 nil nil nil 19792 nil 8 1650059376 14082 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 12016 nil nil nil nil nil nil 138 144 34 2 14162 8 '' 41 #left 1170 #empty 8 #() 16 14082 #<= 8 #() nil nil 19792 818 0 nil 850 2 1 816 8 'doIt' 8 '[:each | each subSuperIcon]' 8 #[30 105 226 0 106] #subSuperIcon 20064 7 257 nil 1 nil nil 14162 8 'Selector' 421 #left 14082 #displayString 19920 ##(Smalltalk.SortedCollection) nil nil 19792 nil 3 nil 818 0 nil 850 5 1 816 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 20192 7 257 nil #report 1296 nil 133221 nil 34 4 nil nil 482 1 1 nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 55 482 469 571 19792 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 27 0 0 0 234 0 0 0 56 1 0 0] 8 #() 1312 nil 27 13074 13120 1 13136 1 15248 55 13152 -49 410 ##(Smalltalk.PushButton) 34 20 nil 19680 34 2 8 1140858880 1 20480 nil 656 nil 5 nil nil nil 20480 nil 8 1650168896 1602 #gotoMethodDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 625 482 469 51 20480 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 234 0 0 0 81 1 0 0] 8 #() 1312 nil 29 13074 13120 1 13136 1 13152 -49 13152 1 410 ##(Smalltalk.TextEdit) 34 16 nil 19680 34 2 8 1140916352 1025 20752 nil 656 nil 5 nil nil nil 20752 nil 8 1650007552 2178 nil nil 3 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 1 482 469 51 20752 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 234 0 0 0 25 0 0 0] 8 #() 1312 nil 27 13074 13120 1 13136 1 15248 1 15248 51 170 192 34 6 19792 8 'methodList' 20480 8 'definedPackageMethodText' 20752 8 'categoryMethodText' nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 383 1 482 469 675 19680 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 191 0 0 0 0 0 0 0 169 1 0 0 81 1 0 0] 34 3 19792 20480 20752 1312 nil 27 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 244 63 false 170 192 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 19568 34 2 8 1409286144 131073 21328 nil 656 nil 5 nil nil nil 21328 674 138 144 34 2 738 8 'Category' 410 ##(Smalltalk.ListView) 34 30 nil 21328 34 2 8 1409372233 1025 21472 11778 138 144 1296 nil 11856 656 nil 21 nil nil nil 21472 nil 8 1650059376 14082 #displayString 8 #() nil 12016 nil nil nil nil nil nil 138 144 34 1 14162 8 'Column 1' 349 #left 14082 #displayString 8 #() ##(Smalltalk.SortedCollection) 818 0 nil 850 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each]' 1779525917 21712 7 257 nil nil 21472 nil 3 nil nil #report 1296 nil 131169 nil 34 4 nil nil 482 1 1 nil 1106 138 144 34 2 1170 #createAt:extent: 34 2 482 9 53 482 357 615 21472 1170 #text: 34 1 8 'Column 1' 21472 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 182 0 0 0 77 1 0 0] 8 #() 1312 nil 27 738 8 'Variables' 410 ##(Smalltalk.ListView) 34 30 nil 21328 34 2 8 1409372233 1025 22048 11778 138 144 1296 nil 11856 656 nil 21 nil nil nil 22048 nil 8 1650059376 14082 #displayString 8 #() nil 12016 nil nil 818 0 nil 850 4 1 816 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 22192 7 257 nil nil nil nil 138 144 34 1 14162 8 'Column 1' 349 #left 14082 #displayString 22176 ##(Smalltalk.SortedCollection) nil nil 22048 nil 3 nil 818 0 nil 850 4 1 816 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 22352 7 257 nil #report 1296 nil 131169 nil 34 4 nil nil 482 1 1 nil 1106 138 144 34 2 1170 #createAt:extent: 34 2 482 9 53 482 357 615 22048 1170 #text: 34 1 8 'Column 1' 22048 1250 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 182 0 0 0 77 1 0 0] 8 #() 1312 nil 27 21472 170 192 34 4 21472 8 'categoryList' 22048 8 'variableList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 21328 34 2 8 1140916736 1 22736 11778 138 144 34 2 21456 22032 nil 11856 nil nil 1 nil nil nil 22736 nil 8 1650396656 818 0 nil 11906 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 22864 7 257 nil 818 0 nil 11906 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 22912 7 257 nil 12016 nil nil nil nil nil #noIcons nil nil nil nil nil 1106 138 144 34 3 1170 #createAt:extent: 34 2 482 1 1 482 373 675 22736 1170 #basicSelectionsByIndex: 34 1 8 #(1) 22736 1170 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 22736 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 186 0 0 0 81 1 0 0] 8 #() 1312 nil 27 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 1 482 373 675 21328 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 186 0 0 0 81 1 0 0] 34 3 21472 22048 22736 1312 nil 27 8 'methodFilterTabs' nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1391 1 482 851 675 19568 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 183 2 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 3 21328 410 ##(Smalltalk.Splitter) 34 12 nil 19568 34 2 8 1140850688 1 23536 nil 656 nil 517 nil nil nil 8866 23536 nil 1 #left nil nil nil 8896 8912 nil 8896 nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 373 1 482 11 675 23536 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 186 0 0 0 0 0 0 0 191 0 0 0 81 1 0 0] 8 #() 1312 nil 27 19680 1312 nil 27 1312 nil 27 7 false 170 192 1296 nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 1 482 2241 675 12464 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 1 12576 1312 nil 27 12434 3 5 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 23968 nil nil 482 2241 43 517 nil nil nil 23968 12754 170 176 34 4 410 ##(Smalltalk.ToolButton) 34 14 nil 23968 34 2 8 1140850688 131073 24096 nil nil nil 1029 nil nil nil 24096 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 24096 34 2 8 1140853580 131137 24160 nil nil 482 43 43 513 nil nil nil 24160 nil 8 1650109728 nil 170 192 34 2 18553 1115206 1 ##(Smalltalk.ToolbarIconButton) 24160 1 1602 #flipAutoCommit 8 'Auto Commit' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons/camera16_light_icon.ico' nil 18553 34 1 24304 nil nil 3 nil 482 33 33 482 33 33 nil nil 1106 138 144 34 2 1170 #createAt:extent: 34 2 482 1 1 482 43 43 24160 1170 #updateSizePosted 1296 24160 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 8 #() 1312 nil 27 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 1 482 43 43 24096 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 34 1 24160 1312 nil 27 13074 13120 1 13106 #fixedViewLeft 43 15248 1 16656 43 410 ##(Smalltalk.TextEdit) 34 16 nil 23968 34 2 8 1140850688 1 24848 nil 656 482 2199 43 517 nil 2066 nil true 2098 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 482 193 193 nil 24848 642 #black 8 1650007552 2178 nil nil 67 1106 138 144 34 2 1170 #createAt:extent: 34 2 482 43 1 482 2199 43 24848 1170 #setMarginWidths: 34 1 8 #(3 3) 24848 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 21 0 0 0 0 0 0 0 96 4 0 0 21 0 0 0] 8 #() 1312 nil 27 13074 13120 43 13136 1 15248 1 13152 1 170 192 34 4 24096 8 'autoCommitButton' 24848 8 'statusBarField' nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 1359 482 2241 43 23968 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 167 2 0 0 96 4 0 0 188 2 0 0] 34 2 24096 24848 1312 nil 27 21266 8 184 30 133 235 81 184 158 63 true 170 192 34 4 576 8 'textAreaTabs' 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 25552 nil 656 nil 517 nil nil nil 8866 25552 nil 1 #left nil nil nil 8896 8912 nil 8896 nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 675 482 2241 11 25552 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 81 1 0 0 96 4 0 0 86 1 0 0] 8 #() 1312 nil 27 8 'splitter' nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 2879 21 482 2241 1401 416 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 159 5 0 0 10 0 0 0 255 9 0 0 198 2 0 0] 34 4 12464 25552 576 23968 1312 nil 27 )! !
!JadeiteBrowserPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

