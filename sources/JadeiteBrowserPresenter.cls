"Filed out from Dolphin Smalltalk 7"!

JadeiteProjectsBrowserPresenter subclass: #JadeiteBrowserPresenter
	instanceVariableNames: 'dictionaryPresenter packageDictionaryCards globalsTab autoCommitButton search previousTabViewArrangement previousTopViewArrangement'
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

onViewOpened
	super onViewOpened.
	self showPackageList!

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
				addPackage;
				cloneProject;
				loadProjects;
				unloadProjects;
				pullFromGit;
				gitCommit;
				pushToGit;
				projectChanges;
				writeProject;
				checkoutTag;
				checkout;
				projectLog;
				refresh].
	^#('Projects' 
		'Clone Git Project ...//cloneProject' 
		'Load//loadProjects' 'Unload//unloadProjects' 
		'-'
		'Pull from Git//pullFromGit'
		'Commit to Git ...//gitCommit'
		'Push to Git//pushToGit'
		'-'
		'&Changes//projectChanges'
		'Write//writeProject'
		'Checkout Git Tag ...//checkoutTag'
		'Checkout Git Branch ...//checkout'
		'-'
		'&Add Package...//addPackage'
		'-'
		'Git Log//projectLog'
		'&Refresh//refreshFromServer')!

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
!JadeiteBrowserPresenter categoriesFor: #checkoutTag!menu handlers!public! !
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
!JadeiteBrowserPresenter categoriesFor: #editDelete!menu handlers!public! !
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
!JadeiteBrowserPresenter categoriesFor: #onViewOpened!event handlers!public! !
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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil 328198 ##(Smalltalk.Point) 2241 1401 517 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 6 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 576 nil nil 482 2241 43 517 nil nil nil 576 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.ToolButton) 34 14 nil 576 34 2 8 1140850688 131073 720 nil nil nil 1029 nil nil nil 720 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 720 34 2 8 1140853580 131137 784 nil nil 482 43 43 513 nil nil nil 784 nil 8 1650109728 nil 170 192 34 2 25099 1115206 1 ##(Smalltalk.ToolbarIconButton) 784 1 1180998 4 ##(Smalltalk.CommandDescription) #flipAutoCommit 8 'Auto Commit' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons/camera16_light_icon.ico' nil 25099 34 1 928 nil nil 3 nil 482 33 33 482 33 33 nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 482 1 1 482 43 43 784 1186 #updateSizePosted 8 #() 784 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 8 #() 482 193 193 nil 27 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 1 482 43 43 720 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 34 1 784 1360 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 1570 #fixedViewLeft 43 1570 #fixedParentTop 1 1570 #fixedViewTop 43 410 ##(Smalltalk.TextEdit) 34 16 nil 576 34 2 8 1140850688 1 1648 nil 327686 ##(Smalltalk.Color) #default 482 2199 43 517 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 482 193 193 nil 1648 1714 #black 8 1650007552 852486 ##(Smalltalk.NullConverter) nil nil 67 1122 138 144 34 2 1186 #createAt:extent: 34 2 482 43 1 482 2199 47 1648 1186 #setMarginWidths: 34 1 8 #(3 3) 1648 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 21 0 0 0 0 0 0 0 96 4 0 0 23 0 0 0] 8 #() 1360 nil 27 1538 1584 43 1570 #fixedParentRight 1 1616 1 1570 #fixedParentBottom 1 170 192 34 4 720 8 'autoCommitButton' 1648 8 'statusBarField' nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 1355 482 2241 47 576 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 165 2 0 0 96 4 0 0 188 2 0 0] 34 2 720 1648 1360 nil 27 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 232 63 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 2432 nil nil nil 5 nil nil nil 2432 514 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 2432 34 2 8 1140850688 131073 2544 nil nil nil 5 nil nil nil 2544 514 170 176 34 6 410 ##(Smalltalk.ContainerView) 34 15 nil 2544 34 2 8 1140850688 131073 2656 nil nil nil 5 nil nil nil 2656 514 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 2656 34 2 8 1409286144 131073 2768 nil 1728 nil 5 nil nil nil 2768 655878 ##(Smalltalk.CardLayout) 138 144 1280 nil 170 192 1280 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 2768 34 2 8 1140916736 1 2896 590662 2 ##(Smalltalk.ListModel) 138 144 1280 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) nil nil 1 nil nil nil 2896 nil 8 1650396656 787814 3 ##(Smalltalk.BlockClosure) 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 3072 7 257 nil 3058 0 nil 3090 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 3136 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #noIcons nil nil nil nil nil 1122 138 144 34 2 1186 #createAt:extent: 34 2 482 1 1 482 511 673 2896 1186 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 2896 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 80 1 0 0] 8 #() 1360 nil 27 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 1 482 511 673 2768 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 80 1 0 0] 34 1 2896 1360 nil 27 3 false 170 192 34 2 2768 8 'packageDictionaryCards' nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 351 1 482 511 673 2656 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 175 0 0 0 0 0 0 0 174 1 0 0 80 1 0 0] 34 1 2768 1360 nil 27 524806 ##(Smalltalk.Fraction) 7 11 410 ##(Smalltalk.ListView) 34 30 nil 2544 34 2 8 1409405261 1025 3808 2962 138 144 1280 nil 3024 1728 nil 5 nil nil nil 3808 nil 8 1650059376 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.IconicListAbstract) 3200 nil nil nil nil nil nil 138 144 34 1 920646 5 ##(Smalltalk.ListViewColumn) 8 'Column 1' 333 #left 3058 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 3056 8 'doIt' 8 '[:each | each displayName]' 8 #[30 105 226 0 106] #displayName 4048 7 257 nil ##(Smalltalk.SortedCollection) nil nil 3808 nil 3 3058 0 nil 4066 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 4144 7 257 nil 3058 0 nil 4066 3 1 3056 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 4224 7 257 nil #report 1280 nil 133217 nil 34 4 nil nil 482 1 1 nil 1122 138 144 34 2 1186 #createAt:extent: 34 2 482 1 1 482 341 673 3808 1186 #text: 34 1 8 'Column 1' 3808 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 170 0 0 0 80 1 0 0] 8 #() 1360 nil 27 3778 5 11 410 ##(Smalltalk.ContainerView) 34 15 nil 2544 34 2 8 1140850688 131073 4560 nil nil nil 5 nil nil nil 4560 658 170 176 34 6 410 ##(Smalltalk.CardContainer) 34 16 nil 4560 34 2 8 1409286144 131073 4672 nil 1728 nil 5 nil nil nil 4672 2834 138 144 34 2 721414 ##(Smalltalk.Association) 590662 1 ##(Smalltalk.CardLabel) 8 'Class' nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 4672 34 2 8 1140850688 131073 4864 nil nil nil 5 nil nil nil 4864 nil 170 192 1280 nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 9 9 482 495 1 4864 1298 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 251 0 0 0 4 0 0 0] 8 #() 1360 nil 27 4786 4818 8 'Instance' nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 4672 34 2 8 1140850688 131073 5152 nil nil nil 5 nil nil nil 5152 nil 170 192 1280 nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 9 9 482 495 1 5152 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 251 0 0 0 4 0 0 0] 8 #() 1360 nil 27 5152 170 192 34 4 5152 8 'instanceTab' 4864 8 'classTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 4672 34 2 8 1140916738 1 5456 2962 138 144 34 2 5120 4832 nil 3024 nil nil 1 nil nil nil 5456 nil 8 1650396656 3058 0 nil 3090 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 5584 7 257 nil 3058 0 nil 3090 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 5632 7 257 nil 3200 nil nil nil nil nil #smallIcons nil nil nil nil nil 1122 138 144 34 3 1186 #createAt:extent: 34 2 482 1 1 482 511 51 5456 1186 #basicSelectionsByIndex: 34 1 8 #(1) 5456 1186 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 5456 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 25 0 0 0] 8 #() 1360 nil 27 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 573 482 511 51 4672 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 30 1 0 0 255 0 0 0 55 1 0 0] 34 3 5152 4864 5456 1360 nil 27 1538 1584 1 2144 1 2160 -99 1632 51 410 ##(Smalltalk.CardContainer) 34 16 nil 4560 34 2 8 1409286144 131073 6096 nil 1728 nil 5 nil nil nil 6096 2834 138 144 34 2 4786 4818 8 'Hierarchy' nil nil 410 ##(Smalltalk.TreeView) 34 27 nil 6096 34 2 8 1409356327 1025 6256 590918 3 ##(Smalltalk.TreeModel) nil 3024 525062 ##(Smalltalk.TreeNode) nil nil nil 170 192 1280 1728 nil 21 nil nil nil 6256 nil 8 1650630720 3058 0 nil 4066 2 1 3056 8 'doIt' 8 '[:each | each displayString]' 8 #[30 105 226 0 106] #displayString 6416 7 257 nil ##(Smalltalk.IconicListAbstract) 3200 nil 3058 0 nil 4066 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 6496 7 257 nil 3058 0 nil 4066 5 1 3056 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 6576 7 257 nil nil nil 170 176 1280 33 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 1280 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 9 53 482 495 513 6256 1298 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 251 0 0 0 26 1 0 0] 8 #() 1360 nil 27 4786 4818 8 'Classes' nil nil 410 ##(Smalltalk.ListView) 34 30 nil 6096 34 2 8 1409372237 1025 6896 2962 138 144 1280 nil 3024 1728 nil 21 nil nil nil 6896 nil 8 1650059376 3922 #displayString 8 #() nil 3200 nil nil nil nil nil nil 138 144 34 1 4002 8 '' 487 #left 3922 #displayString 8 #() 3922 #<= 8 #() nil nil 6896 nil 3 nil 3058 0 nil 4066 5 1 3056 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 7168 7 257 nil #report 1280 nil 131169 nil 34 4 nil nil 482 1 1 nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 9 53 482 495 513 6896 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 251 0 0 0 26 1 0 0] 8 #() 1360 nil 27 6896 170 192 34 4 6256 8 'classHierarchy' 6896 8 'classList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 6096 34 2 8 1140916736 1 7504 2962 138 144 34 2 6864 6224 nil 3024 nil nil 1 nil nil nil 7504 nil 8 1650396656 3058 0 nil 3090 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 7632 7 257 nil 3058 0 nil 3090 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 7680 7 257 nil 3200 nil nil nil nil nil #smallIcons nil nil nil nil nil 1122 138 144 34 3 1186 #createAt:extent: 34 2 482 1 1 482 511 573 7504 1186 #basicSelectionsByIndex: 34 1 8 #(1) 7504 1186 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 7504 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 30 1 0 0] 8 #() 1360 nil 27 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 1 482 511 573 6096 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 30 1 0 0] 34 3 6896 6256 7504 1360 nil 27 1538 1584 1 2144 1 1616 1 2160 -99 410 ##(Smalltalk.PushButton) 34 20 nil 4560 34 2 8 1140858880 1 8144 nil 1714 #silver nil 5 nil nil nil 8144 nil 8 1650168896 946 #gotoClassDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 623 482 511 51 8144 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 55 1 0 0 255 0 0 0 80 1 0 0] 8 #() 1360 nil 29 1538 1584 1 2144 1 2160 -49 2160 1 170 192 34 6 4672 8 'instanceClassTabs' 6096 8 'classHierarchyTabs' 8144 8 'definedPackageClassText' nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 871 1 482 511 673 4560 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 179 1 0 0 0 0 0 0 178 2 0 0 80 1 0 0] 34 3 6096 4672 8144 1360 nil 27 3778 7 11 false 170 192 34 2 3808 8 'projectList' nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 1 482 2241 673 2544 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 80 1 0 0] 34 7 3808 410 ##(Smalltalk.Splitter) 34 12 nil 2544 34 2 8 1140850688 1 8896 nil 1728 nil 517 nil nil nil 1510470 1 ##(Smalltalk.DraggableViewInteractor) 8896 nil 1 #left nil nil nil 482 1 1 482 9 9 nil 8992 nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 341 1 482 11 673 8896 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 170 0 0 0 0 0 0 0 175 0 0 0 80 1 0 0] 8 #() 1360 nil 27 2656 410 ##(Smalltalk.Splitter) 34 12 nil 2544 34 2 8 1140850688 1 9184 nil 1728 nil 517 nil nil nil 8962 9184 nil 1 #left nil nil nil 8992 9008 nil 8992 nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 861 1 482 11 673 9184 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 174 1 0 0 0 0 0 0 179 1 0 0 80 1 0 0] 8 #() 1360 nil 27 4560 410 ##(Smalltalk.Splitter) 34 12 nil 2544 34 2 8 1140850688 1 9424 nil 1728 nil 517 nil nil nil 8962 9424 nil 1 #left nil nil nil 8992 9008 nil 8992 nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1381 1 482 11 673 9424 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 178 2 0 0 0 0 0 0 183 2 0 0 80 1 0 0] 8 #() 1360 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 2544 34 2 8 1140850688 131073 9664 nil nil nil 5 nil nil nil 9664 514 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 9664 34 2 8 1140850688 131073 9776 nil nil nil 5 nil nil nil 9776 658 170 176 34 6 410 ##(Smalltalk.TextEdit) 34 16 nil 9776 34 2 8 1140916352 1025 9888 nil 1728 nil 5 nil nil nil 9888 nil 8 1650007552 1890 nil nil 3 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 1 482 469 51 9888 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 234 0 0 0 25 0 0 0] 8 #() 1360 nil 27 1538 1584 1 2144 1 1616 1 1616 51 410 ##(Smalltalk.PushButton) 34 20 nil 9776 34 2 8 1140858880 1 10160 nil 1728 nil 5 nil nil nil 10160 nil 8 1650168896 946 #gotoMethodDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 623 482 469 51 10160 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 55 1 0 0 234 0 0 0 80 1 0 0] 8 #() 1360 nil 29 1538 1584 1 2144 1 2160 -49 2160 1 410 ##(Smalltalk.ListView) 34 30 nil 9776 34 2 8 1409372233 1025 10432 2962 138 144 1280 nil 3024 1728 nil 13 nil nil nil 10432 nil 8 1650059376 3922 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 3200 nil nil nil nil nil nil 138 144 34 2 4002 8 '' 41 #left 1186 #empty 8 #() 16 3922 #<= 8 #() nil nil 10432 3058 0 nil 4066 2 1 3056 8 'doIt' 8 '[:each | each subSuperIcon]' 8 #[30 105 226 0 106] #subSuperIcon 10704 7 257 nil 1 nil nil 4002 8 'Selector' 421 #left 3922 #displayString 10560 ##(Smalltalk.SortedCollection) nil nil 10432 nil 3 nil 3058 0 nil 4066 5 1 3056 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 10832 7 257 nil #report 1280 nil 133221 nil 34 4 nil nil 482 1 1 nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 55 482 469 569 10432 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 27 0 0 0 234 0 0 0 55 1 0 0] 8 #() 1360 nil 27 1538 1584 1 2144 1 1616 55 2160 -49 170 192 34 6 9888 8 'categoryMethodText' 10160 8 'definedPackageMethodText' 10432 8 'methodList' nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 383 1 482 469 673 9776 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 191 0 0 0 0 0 0 0 169 1 0 0 80 1 0 0] 34 3 10432 10160 9888 1360 nil 27 2402 8 0 0 0 0 0 0 244 63 false 170 192 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 9664 34 2 8 1409286144 131073 11408 nil 1728 nil 5 nil nil nil 11408 2834 138 144 34 2 4786 8 'Category' 410 ##(Smalltalk.ListView) 34 30 nil 11408 34 2 8 1409372233 1025 11552 2962 138 144 1280 nil 3024 1728 nil 21 nil nil nil 11552 nil 8 1650059376 3922 #displayString 8 #() nil 3200 nil nil nil nil nil nil 138 144 34 1 4002 8 'Column 1' 349 #left 3922 #displayString 8 #() ##(Smalltalk.SortedCollection) 3058 0 nil 4066 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each]' 1779525917 11792 7 257 nil nil 11552 nil 3 nil nil #report 1280 nil 131169 nil 34 4 nil nil 482 1 1 nil 1122 138 144 34 2 1186 #createAt:extent: 34 2 482 9 53 482 357 613 11552 1186 #text: 34 1 8 'Column 1' 11552 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 182 0 0 0 76 1 0 0] 8 #() 1360 nil 27 4786 8 'Variables' 410 ##(Smalltalk.ListView) 34 30 nil 11408 34 2 8 1409372233 1025 12128 2962 138 144 1280 nil 3024 1728 nil 21 nil nil nil 12128 nil 8 1650059376 3922 #displayString 8 #() nil 3200 nil nil 3058 0 nil 4066 4 1 3056 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 12272 7 257 nil nil nil nil 138 144 34 1 4002 8 'Column 1' 349 #left 3922 #displayString 12256 ##(Smalltalk.SortedCollection) nil nil 12128 nil 3 nil 3058 0 nil 4066 4 1 3056 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 12432 7 257 nil #report 1280 nil 131169 nil 34 4 nil nil 482 1 1 nil 1122 138 144 34 2 1186 #createAt:extent: 34 2 482 9 53 482 357 613 12128 1186 #text: 34 1 8 'Column 1' 12128 1298 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 182 0 0 0 76 1 0 0] 8 #() 1360 nil 27 11552 170 192 34 4 11552 8 'categoryList' 12128 8 'variableList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 11408 34 2 8 1140916736 1 12816 2962 138 144 34 2 11536 12112 nil 3024 nil nil 1 nil nil nil 12816 nil 8 1650396656 3058 0 nil 3090 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 12944 7 257 nil 3058 0 nil 3090 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 12992 7 257 nil 3200 nil nil nil nil nil #noIcons nil nil nil nil nil 1122 138 144 34 3 1186 #createAt:extent: 34 2 482 1 1 482 373 673 12816 1186 #basicSelectionsByIndex: 34 1 8 #(1) 12816 1186 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 12816 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 186 0 0 0 80 1 0 0] 8 #() 1360 nil 27 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 1 482 373 673 11408 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 186 0 0 0 80 1 0 0] 34 3 11552 12128 12816 1360 nil 27 8 'methodFilterTabs' nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1391 1 482 851 673 9664 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 183 2 0 0 0 0 0 0 96 4 0 0 80 1 0 0] 34 3 11408 410 ##(Smalltalk.Splitter) 34 12 nil 9664 34 2 8 1140850688 1 13616 nil 1728 nil 517 nil nil nil 8962 13616 nil 1 #left nil nil nil 8992 9008 nil 8992 nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 373 1 482 11 673 13616 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 186 0 0 0 0 0 0 0 191 0 0 0 80 1 0 0] 8 #() 1360 nil 27 9776 1360 nil 27 1360 nil 27 7 false 170 192 1280 nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 1 482 2241 673 2432 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 80 1 0 0] 34 1 2544 1360 nil 27 25 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 14032 nil 1728 nil 5 nil nil nil 14032 2834 138 144 34 5 4786 4818 8 'SUnit' 3058 0 nil 4066 4 1 3056 8 'doIt' 8 '[Icon fromId: ''icons\UnitTestPlugin.ico'']' 8 #[32 105 45 30 178 106] 983558 ##(Smalltalk.VariableBinding) #Icon 992 8 'icons\UnitTestPlugin.ico' #fromId: 14192 7 1 nil nil 410 ##(Smalltalk.ReferenceView) 34 14 nil 14032 34 2 8 1140850688 131073 14320 nil 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 nil nil nil 14320 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteSUnitInClassPresenter) #resource_Default_view nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 9 53 482 2225 613 14320 1298 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 92 4 0 0 76 1 0 0] 1280 1360 nil 27 4786 4818 8 'Class Definition' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 14032 34 2 8 1445007428 1025 14640 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 14386 26337781 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 11 984134 2 ##(Smalltalk.CommandMenuItem) 1 946 #editSave 8 '&Save' 9383 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 14834 1 946 #editUndo 8 '&Undo' 9397 1 nil nil nil 14834 1 946 #editRedo 8 '&Redo' 9395 1 nil nil nil 14898 4097 14834 1 946 #editCut 8 'Cu&t' 9393 1 nil nil nil 14834 1 946 #editCopy 8 '&Copy' 9351 1 nil nil nil 14834 1 946 #editPaste 8 '&Paste' 9389 1 nil nil nil 14834 1 946 #editDelete 8 '&Delete' 1629 1 nil nil nil 14898 4097 14834 1 946 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 1762 nil true 1794 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 14640 nil 8 1428148671 1890 nil nil 13 nil 170 192 34 4 #normal 1182790 1 ##(Smalltalk.ScintillaTextStyle) 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 15442 77 1714 #gray 1714 #white 1 nil nil nil nil #callTip nil nil nil 34 256 15456 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 15472 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1639686 ##(Smalltalk.SmalltalkExpressionStyler) 1 nil nil false 138 144 1280 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 14640 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1280 nil 170 176 1280 9215 nil nil nil nil 8208 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 15456 nil nil nil nil 1 nil 170 192 34 6 1 1510470 3 ##(Smalltalk.ScintillaIndicatorStyle) 1 14640 14386 65025 3 false 1 nil nil nil nil nil nil 3 15874 3 14640 1714 #blue 5 false 3 nil nil nil nil nil nil 5 15874 5 14640 1714 #red 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 15442 1027 14386 60239 14386 31326207 1 nil nil nil nil #Warning nil nil nil #Error 15442 1031 14386 335 14386 31317503 1 nil nil nil nil #Error nil nil nil #Notification 15442 1029 nil 14386 31185883 1 nil nil nil nil #Notification nil nil nil nil 1122 138 144 34 9 1186 #createAt:extent: 34 2 482 9 53 482 2225 613 14640 1186 #contextMenu: 34 1 14800 14640 1186 #textLimit: 8 #(1073741823) 14640 1186 #caretPeriod: 8 #(530) 14640 1186 #wordWrap: 8 #(true) 14640 1186 #margins: 34 1 34 3 985158 3 ##(Smalltalk.ScintillaMargin) 1 14640 1 3 nil nil 5 nil 16434 3 14640 33 nil 3 67108863 5 nil 16434 5 14640 1 nil 3 -67108863 5 nil 14640 1186 #tabWidth: 8 #(4) 14640 1186 #maxCompletionListHeight: 8 #(9) 14640 1186 #edgeColumn: 8 #(1) 14640 1298 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 92 4 0 0 76 1 0 0] 8 #() 1360 nil 29 4786 4818 8 'Class Documentation' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 14032 34 2 8 1445007428 1025 16688 14706 nil false 14752 nil 14386 26337781 nil 5 14786 nil true 34 1 14834 1 946 #editSaveClassComment 8 'Save' 1025 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 1762 nil true 1794 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 16688 nil 8 1428148671 1890 nil nil 15 nil 170 192 34 4 #normal 15442 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 15442 77 15488 15504 1 nil nil nil nil #callTip nil nil nil 34 256 17008 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 17024 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 15618 1 nil nil nil 16688 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1280 nil 170 176 1280 9215 nil nil nil nil 8208 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 17008 nil nil nil nil 1 nil 170 192 34 6 1 15874 1 16688 14386 65025 3 false 1 nil nil nil nil nil nil 3 15874 3 16688 15936 5 false 3 nil nil nil nil nil nil 5 15874 5 16688 15968 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 15442 1027 14386 60239 14386 31326207 1 nil nil nil nil #Warning nil nil nil #Error 15442 1031 14386 335 14386 31317503 1 nil nil nil nil #Error nil nil nil #Notification 15442 1029 nil 14386 31185883 1 nil nil nil nil #Notification nil nil nil nil 1122 138 144 34 10 1186 #createAt:extent: 34 2 482 9 53 482 2225 613 16688 1186 #contextMenu: 34 1 16784 16688 1186 #textLimit: 8 #(1073741823) 16688 1186 #hoverTime: 8 #(1000000) 16688 1186 #caretPeriod: 8 #(530) 16688 1186 #wordWrap: 8 #(true) 16688 1186 #margins: 34 1 34 3 16434 1 16688 1 3 nil nil 5 nil 16434 3 16688 33 nil 3 67108863 5 nil 16434 5 16688 1 nil 3 -67108863 5 nil 16688 1186 #tabWidth: 8 #(4) 16688 1186 #maxCompletionListHeight: 8 #(9) 16688 1186 #edgeColumn: 8 #(1) 16688 1298 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 92 4 0 0 76 1 0 0] 8 #() 1360 nil 29 4786 4818 8 'Method Source' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 14032 34 2 8 1445007428 1025 18064 14706 nil false 14752 nil 14386 26337781 nil 5 nil 1762 nil true 1794 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 18064 nil 8 1428148671 1890 nil nil 13 nil 170 192 34 4 #normal 15442 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 15442 77 15488 15504 1 nil nil nil nil #callTip nil nil nil 34 256 18288 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 18304 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 1280 170 192 34 2 #default 15618 1 nil nil nil 18064 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1280 nil 170 176 1280 9215 nil nil nil nil 8208 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 4 #normal 18288 #callTip 18304 nil nil nil nil 1 nil 170 192 34 12 1 15874 1 18064 14386 65025 3 false 1 nil nil nil nil nil nil 8 'indicator9' 15874 19 18064 15968 13 nil nil nil nil nil nil nil nil 8 'indicator10' 15874 21 18064 15968 3 nil nil nil nil nil nil nil nil 3 15874 3 18064 15936 5 false 3 nil nil nil nil nil nil 8 'indicator8' 15874 17 18064 8208 1 nil nil nil nil nil nil nil nil 5 15874 5 18064 15968 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 15442 1027 14386 60239 14386 31326207 1 nil nil nil nil #Warning nil nil nil #Error 15442 1031 14386 335 14386 31317503 1 nil nil nil nil #Error nil nil nil #Notification 15442 1029 nil 14386 31185883 1 nil nil nil nil #Notification nil nil nil nil 1122 138 144 34 9 1186 #createAt:extent: 34 2 482 9 53 482 2225 613 18064 1186 #textLimit: 8 #(1073741823) 18064 1186 #hoverTime: 8 #(500) 18064 1186 #caretPeriod: 8 #(530) 18064 1186 #wordWrap: 8 #(true) 18064 1186 #margins: 34 1 34 3 16434 1 18064 61 3 nil nil 5 nil 16434 3 18064 1 nil 3 67108863 nil nil 16434 5 18064 1 nil 3 -67108863 nil nil 18064 1186 #tabWidth: 8 #(4) 18064 1186 #maxCompletionListHeight: 8 #(9) 18064 1186 #edgeColumn: 8 #(1) 18064 1298 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 92 4 0 0 76 1 0 0] 8 #() 1360 nil 29 4786 4818 8 'Comparison' nil nil 410 ##(Smalltalk.ShellView) 34 27 nil 14032 34 2 8 1078919168 131073 19504 nil 1728 nil 517 nil nil nil 19504 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 19504 34 2 8 1140850688 131073 19600 nil 14386 26337781 nil 5 14786 nil true 34 5 14834 1 946 #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 14834 1 946 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 14834 1 946 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 14834 1 946 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 14834 1 946 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 19600 514 170 176 1280 false 170 192 1280 nil 1122 138 144 34 2 1186 #createAt:extent: 34 2 482 1 1 482 2193 581 19600 1186 #contextMenu: 34 1 19680 19600 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 4 0 0 34 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 19600 34 2 8 1140850688 131073 20208 nil 1728 nil 5 nil nil nil 20208 19570 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 20208 34 2 8 1140850945 262145 20288 nil nil nil 21 nil nil nil 20288 nil 8 1650166432 1890 nil nil nil 1122 138 144 34 2 1186 #createAt:extent: 34 2 482 1 541 482 1091 41 20288 1186 #text: 34 1 8 '
' 20288 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 14 1 0 0 33 2 0 0 34 1 0 0] 8 #() 1360 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 20208 34 2 8 1140920580 1025 20592 14706 nil false 14752 nil 14386 26337781 nil 21 nil nil nil 20592 nil 8 1428148671 1890 nil nil 13 nil 170 192 34 12 #lineNumber 15442 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 15442 77 15488 15504 1 nil nil nil nil #callTip nil nil nil #indentGuide 15442 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #normal 15442 1 nil nil 1 nil nil nil nil #normal nil nil nil #whitespace 15442 3 1714 #teal nil 1 nil nil nil nil #whitespace nil nil nil #diff 15442 5 nil 14386 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 20800 20816 20848 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 20752 nil nil nil 20784 nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 15618 1 nil nil nil 20592 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1280 nil 170 176 1280 9215 nil nil nil nil 8208 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 20720 nil nil nil nil 1 nil 170 192 34 2 #diff 15874 1 20592 1714 #yellow 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 15442 1027 14386 60239 14386 31326207 1 nil nil nil nil #Warning nil nil nil #Error 15442 1031 14386 335 14386 31317503 1 nil nil nil nil #Error nil nil nil #Notification 15442 1029 nil 14386 31185883 1 nil nil nil nil #Notification nil nil nil nil 1122 138 144 34 8 1186 #createAt:extent: 34 2 482 1 1 482 1091 541 20592 1186 #textLimit: 8 #(1073741823) 20592 1186 #caretPeriod: 8 #(530) 20592 1186 #wordWrap: 8 #(true) 20592 1186 #margins: 34 1 34 3 16434 1 20592 49 3 nil nil nil nil 16434 3 20592 1 nil nil 67108863 nil nil 16434 5 20592 1 nil nil nil nil nil 20592 1186 #canHScroll: 8 #(false) 20592 1186 #maxCompletionListHeight: 8 #(9) 20592 1186 #edgeColumn: 8 #(1) 20592 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 14 1 0 0] 8 #() 1360 nil 29 170 192 34 4 20288 8 'beforeTitle' 20592 8 'before' nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 1 482 1091 581 20208 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 34 1 0 0] 34 2 20592 20288 1360 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 19600 34 2 8 1140850688 1 22048 nil 14386 66047 nil 517 nil nil nil 8962 22048 nil 1 #left nil nil nil 8992 9008 nil 8992 nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1091 1 482 11 581 22048 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 33 2 0 0 0 0 0 0 38 2 0 0 34 1 0 0] 8 #() 1360 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 19600 34 2 8 1140850688 131073 22304 nil 1728 nil 5 nil nil nil 22304 19570 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 22304 34 2 8 1140850945 262145 22384 nil nil nil 21 nil nil nil 22384 nil 8 1650166432 1890 nil nil nil 1122 138 144 34 2 1186 #createAt:extent: 34 2 482 1 541 482 1093 41 22384 1186 #text: 34 1 8 '
' 22384 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 14 1 0 0 34 2 0 0 34 1 0 0] 8 #() 1360 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 22304 34 2 8 1140920580 1025 22688 14706 nil false 14752 nil 14386 26337781 nil 21 nil nil nil 22688 nil 8 1428148671 1890 nil nil 13 nil 170 192 34 12 #lineNumber 15442 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 15442 77 15488 15504 1 nil nil nil nil #callTip nil nil nil #indentGuide 15442 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #normal 15442 1 nil nil 1 nil nil nil nil #normal nil nil nil #whitespace 15442 3 20832 nil 1 nil nil nil nil #whitespace nil nil nil #diff 15442 5 nil 14386 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 22896 22912 22928 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 22848 nil nil nil 22880 nil nil 20898 20928 170 192 34 2 #default 15618 1 nil nil nil 22688 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1280 nil 170 176 1280 9215 nil nil nil nil 8208 nil nil 65 nil nil 21024 21104 3 170 192 34 2 #container 22816 nil nil nil nil 1 nil 170 192 34 2 #diff 15874 1 22688 21200 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 15442 1027 14386 60239 14386 31326207 1 nil nil nil nil #Warning nil nil nil #Error 15442 1031 14386 335 14386 31317503 1 nil nil nil nil #Error nil nil nil #Notification 15442 1029 nil 14386 31185883 1 nil nil nil nil #Notification nil nil nil nil 1122 138 144 34 8 1186 #createAt:extent: 34 2 482 1 1 482 1093 541 22688 1186 #textLimit: 8 #(1073741823) 22688 1186 #caretPeriod: 8 #(530) 22688 1186 #wordWrap: 8 #(true) 22688 1186 #margins: 34 1 34 3 16434 1 22688 49 3 nil nil nil nil 16434 3 22688 1 nil nil 67108863 nil nil 16434 5 22688 1 nil nil nil nil nil 22688 1186 #canHScroll: 8 #(false) 22688 1186 #maxCompletionListHeight: 8 #(9) 22688 1186 #edgeColumn: 8 #(1) 22688 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 34 2 0 0 14 1 0 0] 8 #() 1360 nil 29 170 192 34 4 22384 8 'afterTitle' 22688 8 'after' nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1101 1 482 1093 581 22304 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 38 2 0 0 0 0 0 0 72 4 0 0 34 1 0 0] 34 2 22688 22384 1360 nil 27 1360 nil 27 170 192 34 2 19600 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 14786 nil true 34 4 14834 1 946 #selectUpper 8 'Select &upper' 1 1 nil nil nil 14834 1 946 #selectLower 8 'Select &lower' 1 1 nil nil nil 14898 4097 14834 1 946 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 31923 nil nil 14786 nil true 34 3 14834 1 946 #character 8 '&Character' 1 1 nil nil nil 14834 1 946 #word 8 '&Word' 1 1 nil nil nil 14834 1 946 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 31925 nil nil 14786 nil true 34 1 14834 1 946 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 31927 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1122 138 144 34 3 1186 #createAt:extent: 34 2 482 9 53 482 2225 613 19504 1186 #text: 34 1 8 'Comparison' 19504 1186 #updateMenuBar 1280 19504 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 92 4 0 0 76 1 0 0] 34 1 19600 1360 nil 27 19504 170 192 34 10 16688 8 'classDocumentation' 18064 8 'methodSource' 14640 8 'classDefinition' 14320 8 'sunit' 19504 8 'comparisonTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 14032 34 2 8 1140916736 1 24928 2962 138 144 34 5 14608 16656 18032 14160 19472 nil 3024 nil nil 1 nil nil nil 24928 nil 8 1650396656 3058 0 nil 3090 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 25056 7 257 nil 3058 0 nil 3090 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 25104 7 257 nil 3200 nil nil nil nil nil #smallIcons nil nil nil nil nil 1122 138 144 34 3 1186 #createAt:extent: 34 2 482 1 1 482 2241 673 24928 1186 #basicSelectionsByIndex: 34 1 8 #(5) 24928 1186 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 24928 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 80 1 0 0] 8 #() 1360 nil 27 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 683 482 2241 673 14032 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 85 1 0 0 96 4 0 0 165 2 0 0] 34 6 14640 16688 18064 14320 19504 24928 1360 nil 27 25 true 170 192 34 4 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 25584 nil 1728 nil 517 nil nil nil 8962 25584 nil 1 #left nil nil nil 8992 9008 nil 8992 nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 673 482 2241 11 25584 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 80 1 0 0 96 4 0 0 85 1 0 0] 8 #() 1360 nil 27 8 'splitter' 14032 8 'textAreaTabs' nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 2879 21 482 2241 1401 416 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 159 5 0 0 10 0 0 0 255 9 0 0 198 2 0 0] 34 4 2432 25584 14032 576 1360 nil 27 )! !
!JadeiteBrowserPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

