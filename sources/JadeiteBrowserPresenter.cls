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
!JadeiteBrowserPresenter categoriesFor: #checkout!project menu handlers!public! !
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
!JadeiteBrowserPresenter categoriesFor: #refresh!event handlers!menu handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #refreshClass!event handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #refreshFromServer!event handlers!menu handlers!public!updating! !
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
!JadeiteBrowserPresenter categoriesFor: #variablesMenuStrings!menus!public! !

!JadeiteBrowserPresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil 328198 ##(Smalltalk.Point) 2241 1401 517 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 576 nil nil nil 5 nil nil nil 576 514 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 576 34 2 8 1140850688 131073 688 nil nil nil 5 nil nil nil 688 514 170 176 34 6 410 ##(Smalltalk.ContainerView) 34 15 nil 688 34 2 8 1140850688 131073 800 nil nil nil 5 nil nil nil 800 514 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 800 34 2 8 1409286144 131073 912 nil 327686 ##(Smalltalk.Color) #default nil 5 nil nil nil 912 655878 ##(Smalltalk.CardLayout) 138 144 8 #() nil 170 192 1056 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 912 34 2 8 1140916736 1 1088 590662 2 ##(Smalltalk.ListModel) 138 144 1056 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) nil nil 1 nil nil nil 1088 nil 8 1650396656 787814 3 ##(Smalltalk.BlockClosure) 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 1264 7 257 nil 1250 0 nil 1282 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 1328 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #noIcons nil nil nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 482 1 1 482 511 695 1088 1474 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 1088 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 91 1 0 0] 8 #() 482 193 193 nil 27 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 1 1 482 511 695 912 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 91 1 0 0] 34 1 1088 1648 nil 27 3 false 170 192 34 2 912 8 'packageDictionaryCards' nil 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 351 1 482 511 695 800 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 175 0 0 0 0 0 0 0 174 1 0 0 91 1 0 0] 34 1 912 1648 nil 27 524806 ##(Smalltalk.Fraction) 7 11 410 ##(Smalltalk.ListView) 34 30 nil 688 34 2 8 1409405261 1025 2064 1154 138 144 1056 nil 1216 992 nil 5 nil nil nil 2064 nil 8 1650059376 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.IconicListAbstract) 1392 nil nil nil nil nil nil 138 144 34 1 920646 5 ##(Smalltalk.ListViewColumn) 8 'Column 1' 333 #left 1250 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 1248 8 'doIt' 8 '[:each | each displayName]' 8 #[30 105 226 0 106] #displayName 2304 7 257 nil ##(Smalltalk.SortedCollection) nil nil 2064 nil 3 1250 0 nil 2322 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 2400 7 257 nil 1250 0 nil 2322 3 1 1248 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 2480 7 257 nil #report 1056 nil 133217 nil 34 4 nil nil 482 1 1 nil 1410 138 144 34 2 1474 #createAt:extent: 34 2 482 1 1 482 341 695 2064 1474 #text: 34 1 8 'Column 1' 2064 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 170 0 0 0 91 1 0 0] 8 #() 1648 nil 27 2034 5 11 410 ##(Smalltalk.ContainerView) 34 15 nil 688 34 2 8 1140850688 131073 2816 nil nil nil 5 nil nil nil 2816 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.PushButton) 34 20 nil 2816 34 2 8 1140858880 1 2944 nil 978 #silver nil 5 nil nil nil 2944 nil 8 1650168896 1180998 4 ##(Smalltalk.CommandDescription) #gotoClassDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 1 645 482 511 51 2944 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 66 1 0 0 255 0 0 0 91 1 0 0] 8 #() 1648 nil 29 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 3266 #fixedParentRight 1 3266 #fixedParentBottom -49 3312 1 410 ##(Smalltalk.CardContainer) 34 16 nil 2816 34 2 8 1409286144 131073 3328 nil 992 nil 5 nil 263174 ##(Smalltalk.Font) nil true 524550 ##(Smalltalk.LOGFONTW) 8 #[240 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 188 2 0 0 0 0 0 0 1 2 1 34 83 0 121 0 115 0 116 0 101 0 109 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 3328 1010 138 144 34 2 721414 ##(Smalltalk.Association) 590662 1 ##(Smalltalk.CardLabel) 8 'Class' nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 3328 34 2 8 1140850688 131073 3616 nil nil nil 5 nil nil nil 3616 nil 170 192 1056 nil 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 9 9 482 495 1 3616 1586 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 251 0 0 0 4 0 0 0] 8 #() 1648 nil 27 3538 3570 8 'Instance' nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 3328 34 2 8 1140850688 131073 3904 nil nil nil 5 nil nil nil 3904 nil 170 192 1056 nil 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 9 9 482 495 1 3904 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 251 0 0 0 4 0 0 0] 8 #() 1648 nil 27 3904 170 192 34 4 3904 8 'instanceTab' 3616 8 'classTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 3328 34 2 8 1140916738 1 4208 1154 138 144 34 2 3872 3584 nil 1216 nil nil 1 nil nil nil 4208 nil 8 1650396656 1250 0 nil 1282 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 4336 7 257 nil 1250 0 nil 1282 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 4384 7 257 nil 1392 nil nil nil nil nil #smallIcons nil nil nil nil nil 1410 138 144 34 3 1474 #createAt:extent: 34 2 482 1 1 482 511 51 4208 1474 #basicSelectionsByIndex: 34 1 8 #(1) 4208 1474 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 4208 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 25 0 0 0] 8 #() 1648 nil 27 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 1 595 482 511 51 3328 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 41 1 0 0 255 0 0 0 66 1 0 0] 34 3 3904 3616 4208 1648 nil 27 3234 3280 1 3296 1 3312 -99 3266 #fixedViewTop 51 410 ##(Smalltalk.CardContainer) 34 16 nil 2816 34 2 8 1409286144 131073 4864 nil 992 nil 5 nil nil nil 4864 1010 138 144 34 2 3538 3570 8 'Hierarchy' nil nil 410 ##(Smalltalk.TreeView) 34 27 nil 4864 34 2 8 1409356327 1025 5024 590918 3 ##(Smalltalk.TreeModel) nil 1216 525062 ##(Smalltalk.TreeNode) nil nil nil 170 192 1056 992 nil 21 nil nil nil 5024 nil 8 1650630720 1250 0 nil 2322 2 1 1248 8 'doIt' 8 '[:each | each displayString]' 8 #[30 105 226 0 106] #displayString 5184 7 257 nil ##(Smalltalk.IconicListAbstract) 1392 nil 1250 0 nil 2322 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 5264 7 257 nil 1250 0 nil 2322 5 1 1248 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 5344 7 257 nil nil nil 170 176 1056 33 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 1056 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 9 53 482 495 535 5024 1586 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 251 0 0 0 37 1 0 0] 8 #() 1648 nil 27 3538 3570 8 'Classes' nil nil 410 ##(Smalltalk.ListView) 34 30 nil 4864 34 2 8 1409372237 1025 5664 1154 138 144 1056 nil 1216 992 nil 21 nil nil nil 5664 nil 8 1650059376 2178 #displayString 8 #() nil 1392 nil nil nil nil nil nil 138 144 34 1 2258 8 '' 487 #left 2178 #displayString 8 #() 2178 #<= 8 #() nil nil 5664 nil 3 nil 1250 0 nil 2322 5 1 1248 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 5936 7 257 nil #report 1056 nil 131169 nil 34 4 nil nil 482 1 1 nil 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 9 53 482 495 535 5664 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 251 0 0 0 37 1 0 0] 8 #() 1648 nil 27 5664 170 192 34 4 5664 8 'classList' 5024 8 'classHierarchy' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 4864 34 2 8 1140916736 1 6272 1154 138 144 34 2 5632 4992 nil 1216 nil nil 1 nil nil nil 6272 nil 8 1650396656 1250 0 nil 1282 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 6400 7 257 nil 1250 0 nil 1282 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 6448 7 257 nil 1392 nil nil nil nil nil #smallIcons nil nil nil nil nil 1410 138 144 34 3 1474 #createAt:extent: 34 2 482 1 1 482 511 595 6272 1474 #basicSelectionsByIndex: 34 1 8 #(1) 6272 1474 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 6272 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 41 1 0 0] 8 #() 1648 nil 27 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 1 1 482 511 595 4864 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 41 1 0 0] 34 3 5664 5024 6272 1648 nil 27 3234 3280 1 3296 1 3266 #fixedParentTop 1 3312 -99 170 192 34 6 2944 8 'definedPackageClassText' 3328 8 'instanceClassTabs' 4864 8 'classHierarchyTabs' nil 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 871 1 482 511 695 2816 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 179 1 0 0 0 0 0 0 178 2 0 0 91 1 0 0] 34 3 4864 3328 2944 1648 nil 27 2034 7 11 false 170 192 34 2 2064 8 'projectList' nil 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 1 1 482 2241 695 688 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 91 1 0 0] 34 7 2064 410 ##(Smalltalk.Splitter) 34 12 nil 688 34 2 8 1140850688 1 7392 nil 992 nil 517 nil nil nil 1510470 1 ##(Smalltalk.DraggableViewInteractor) 7392 nil 1 #left nil nil nil 482 1 1 482 9 9 nil 7488 nil 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 341 1 482 11 695 7392 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 170 0 0 0 0 0 0 0 175 0 0 0 91 1 0 0] 8 #() 1648 nil 27 800 410 ##(Smalltalk.Splitter) 34 12 nil 688 34 2 8 1140850688 1 7680 nil 992 nil 517 nil nil nil 7458 7680 nil 1 #left nil nil nil 7488 7504 nil 7488 nil 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 861 1 482 11 695 7680 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 174 1 0 0 0 0 0 0 179 1 0 0 91 1 0 0] 8 #() 1648 nil 27 2816 410 ##(Smalltalk.Splitter) 34 12 nil 688 34 2 8 1140850688 1 7920 nil 992 nil 517 nil nil nil 7458 7920 nil 1 #left nil nil nil 7488 7504 nil 7488 nil 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 1381 1 482 11 695 7920 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 178 2 0 0 0 0 0 0 183 2 0 0 91 1 0 0] 8 #() 1648 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 688 34 2 8 1140850688 131073 8160 nil nil nil 5 nil nil nil 8160 514 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 8160 34 2 8 1140850688 131073 8272 nil nil nil 5 nil nil nil 8272 2882 170 176 34 6 410 ##(Smalltalk.ListView) 34 30 nil 8272 34 2 8 1409372233 1025 8384 1154 138 144 1056 nil 1216 992 nil 13 nil nil nil 8384 nil 8 1650059376 2178 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 1392 nil nil nil nil nil nil 138 144 34 2 2258 8 '' 41 #left 1474 #empty 8 #() 16 2178 #<= 8 #() nil nil 8384 1250 0 nil 2322 2 1 1248 8 'doIt' 8 '[:each | each subSuperIcon]' 8 #[30 105 226 0 106] #subSuperIcon 8656 7 257 nil 1 nil nil 2258 8 'Selector' 421 #left 2178 #displayString 8512 ##(Smalltalk.SortedCollection) nil nil 8384 nil 3 nil 1250 0 nil 2322 5 1 1248 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 8784 7 257 nil #report 1056 nil 133221 nil 34 4 nil nil 482 1 1 nil 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 1 55 482 469 591 8384 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 27 0 0 0 234 0 0 0 66 1 0 0] 8 #() 1648 nil 27 3234 3280 1 3296 1 6912 55 3312 -49 410 ##(Smalltalk.TextEdit) 34 16 nil 8272 34 2 8 1140916352 1025 9072 nil 992 nil 5 nil nil nil 9072 nil 8 1650007552 852486 ##(Smalltalk.NullConverter) nil nil 3 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 1 1 482 469 51 9072 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 234 0 0 0 25 0 0 0] 8 #() 1648 nil 27 3234 3280 1 3296 1 6912 1 6912 51 410 ##(Smalltalk.PushButton) 34 20 nil 8272 34 2 8 1140858880 1 9360 nil 992 nil 5 nil nil nil 9360 nil 8 1650168896 3042 #gotoMethodDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 1 645 482 469 51 9360 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 66 1 0 0 234 0 0 0 91 1 0 0] 8 #() 1648 nil 29 3234 3280 1 3296 1 3312 -49 3312 1 170 192 34 6 8384 8 'methodList' 9072 8 'categoryMethodText' 9360 8 'definedPackageMethodText' nil 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 383 1 482 469 695 8272 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 191 0 0 0 0 0 0 0 169 1 0 0 91 1 0 0] 34 3 8384 9360 9072 1648 nil 27 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 244 63 false 170 192 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 8160 34 2 8 1409286144 131073 9936 nil 992 nil 5 nil nil nil 9936 1010 138 144 34 2 3538 8 'Category' 410 ##(Smalltalk.ListView) 34 30 nil 9936 34 2 8 1409372233 1025 10080 1154 138 144 1056 nil 1216 992 nil 21 nil nil nil 10080 nil 8 1650059376 2178 #displayString 8 #() nil 1392 nil nil nil nil nil nil 138 144 34 1 2258 8 'Column 1' 349 #left 2178 #displayString 8 #() ##(Smalltalk.SortedCollection) 1250 0 nil 2322 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each]' 1779525917 10320 7 257 nil nil 10080 nil 3 nil nil #report 1056 nil 131169 nil 34 4 nil nil 482 1 1 nil 1410 138 144 34 2 1474 #createAt:extent: 34 2 482 9 53 482 357 635 10080 1474 #text: 34 1 8 'Column 1' 10080 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 182 0 0 0 87 1 0 0] 8 #() 1648 nil 27 3538 8 'Variables' 410 ##(Smalltalk.ListView) 34 30 nil 9936 34 2 8 1409372233 1025 10656 1154 138 144 1056 nil 1216 992 nil 21 nil nil nil 10656 nil 8 1650059376 2178 #displayString 8 #() nil 1392 nil nil 1250 0 nil 2322 4 1 1248 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 10800 7 257 nil nil nil nil 138 144 34 1 2258 8 'Column 1' 349 #left 2178 #displayString 10784 ##(Smalltalk.SortedCollection) nil nil 10656 nil 3 nil 1250 0 nil 2322 4 1 1248 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 10960 7 257 nil #report 1056 nil 131169 nil 34 4 nil nil 482 1 1 nil 1410 138 144 34 2 1474 #createAt:extent: 34 2 482 9 53 482 357 635 10656 1474 #text: 34 1 8 'Column 1' 10656 1586 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 182 0 0 0 87 1 0 0] 8 #() 1648 nil 27 10080 170 192 34 4 10080 8 'categoryList' 10656 8 'variableList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 9936 34 2 8 1140916736 1 11344 1154 138 144 34 2 10064 10640 nil 1216 nil nil 1 nil nil nil 11344 nil 8 1650396656 1250 0 nil 1282 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 11472 7 257 nil 1250 0 nil 1282 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 11520 7 257 nil 1392 nil nil nil nil nil #noIcons nil nil nil nil nil 1410 138 144 34 3 1474 #createAt:extent: 34 2 482 1 1 482 373 695 11344 1474 #basicSelectionsByIndex: 34 1 8 #(1) 11344 1474 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 11344 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 186 0 0 0 91 1 0 0] 8 #() 1648 nil 27 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 1 1 482 373 695 9936 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 186 0 0 0 91 1 0 0] 34 3 10080 10656 11344 1648 nil 27 8 'methodFilterTabs' nil 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 1391 1 482 851 695 8160 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 183 2 0 0 0 0 0 0 96 4 0 0 91 1 0 0] 34 3 9936 410 ##(Smalltalk.Splitter) 34 12 nil 8160 34 2 8 1140850688 1 12144 nil 992 nil 517 nil nil nil 7458 12144 nil 1 #left nil nil nil 7488 7504 nil 7488 nil 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 373 1 482 11 695 12144 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 186 0 0 0 0 0 0 0 191 0 0 0 91 1 0 0] 8 #() 1648 nil 27 8272 1648 nil 27 1648 nil 27 7 false 170 192 1056 nil 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 1 1 482 2241 695 576 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 91 1 0 0] 34 1 688 1648 nil 27 25 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 12560 nil nil nil 5 nil nil nil 12560 2882 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 12560 34 2 8 1140850688 131073 12672 nil nil 482 2241 43 517 nil nil nil 12672 2882 170 176 34 4 410 ##(Smalltalk.TextEdit) 34 16 nil 12672 34 2 8 1140850688 1 12800 nil 992 482 2199 43 517 nil 3394 nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 482 193 193 nil 12800 978 #black 8 1650007552 9154 nil nil 67 1410 138 144 34 2 1474 #createAt:extent: 34 2 482 43 1 482 2199 41 12800 1474 #setMarginWidths: 34 1 8 #(3 3) 12800 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 21 0 0 0 0 0 0 0 96 4 0 0 20 0 0 0] 8 #() 1648 nil 27 3234 3280 43 3296 1 6912 1 3312 1 410 ##(Smalltalk.ToolButton) 34 14 nil 12672 34 2 8 1140850688 131073 13232 nil nil nil 1029 nil nil nil 13232 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 13232 34 2 8 1140853580 131137 13296 nil nil 482 43 43 513 nil nil nil 13296 nil 8 1650109728 nil 170 192 34 2 45315 1115206 1 ##(Smalltalk.ToolbarIconButton) 13296 1 3042 #flipAutoCommit 8 'Auto Commit' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons/camera16_light_icon.ico' nil 45315 34 1 13440 nil nil 3 nil 482 33 33 482 33 33 nil nil 1410 138 144 34 2 1474 #createAt:extent: 34 2 482 1 1 482 43 43 13296 1474 #updateSizePosted 1056 13296 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 8 #() 1648 nil 27 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 1 1 482 43 43 13232 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 34 1 13296 1648 nil 27 3234 3280 1 3266 #fixedViewLeft 43 6912 1 4848 43 170 192 34 4 12800 8 'statusBarField' 13232 8 'autoCommitButton' nil 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 1 657 482 2241 41 12672 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 72 1 0 0 96 4 0 0 92 1 0 0] 34 2 13232 12800 1648 nil 27 3234 3280 1 3296 1 3312 -39 3312 1 410 ##(Smalltalk.CardContainer) 34 16 nil 12560 34 2 8 1409286144 131073 14224 nil 992 nil 5 nil nil nil 14224 1010 138 144 34 5 3538 3570 8 'SUnit' 1250 0 nil 2322 4 1 1248 8 'doIt' 8 '[Icon fromId: ''icons\UnitTestPlugin.ico'']' 8 #[32 105 45 30 178 106] 983558 ##(Smalltalk.VariableBinding) #Icon 13488 8 'icons\UnitTestPlugin.ico' #fromId: 14384 7 1 nil nil 410 ##(Smalltalk.ReferenceView) 34 14 nil 14224 34 2 8 1140850688 131073 14512 nil 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 nil nil nil 14512 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteSUnitInClassPresenter) #resource_Default_view nil 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 9 53 482 2225 597 14512 1586 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 92 4 0 0 68 1 0 0] 1056 1648 nil 27 3538 3570 8 'Class Definition' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 14224 34 2 8 1445007428 1025 14832 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 14578 26337781 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 11 984134 2 ##(Smalltalk.CommandMenuItem) 1 3042 #editSave 8 '&Save' 9383 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 15026 1 3042 #editUndo 8 '&Undo' 9397 1 nil nil nil 15026 1 3042 #editRedo 8 '&Redo' 9395 1 nil nil nil 15090 4097 15026 1 3042 #editCut 8 'Cu&t' 9393 1 nil nil nil 15026 1 3042 #editCopy 8 '&Copy' 9351 1 nil nil nil 15026 1 3042 #editPaste 8 '&Paste' 9389 1 nil nil nil 15026 1 3042 #editDelete 8 '&Delete' 1629 1 nil nil nil 15090 4097 15026 1 3042 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 3394 nil true 12898 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 14832 nil 8 1594806719 9154 nil nil 13 nil 170 192 34 4 #normal 1182790 1 ##(Smalltalk.ScintillaTextStyle) 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 15634 77 978 #gray 978 #white 1 nil nil nil nil #callTip nil nil nil 34 256 15648 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 15664 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1639686 ##(Smalltalk.SmalltalkExpressionStyler) 1 nil nil false 138 144 1056 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 14832 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1056 nil 170 176 1056 9215 nil nil nil nil 3008 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 15648 nil nil nil nil 1 nil 170 192 34 6 1 1510470 3 ##(Smalltalk.ScintillaIndicatorStyle) 1 14832 14578 65025 3 false 1 nil nil nil nil nil nil 3 16066 3 14832 978 #blue 5 false 3 nil nil nil nil nil nil 5 16066 5 14832 978 #red 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 15634 1027 14578 60239 14578 31326207 1 nil nil nil nil #Warning nil nil nil #Error 15634 1031 14578 335 14578 31317503 1 nil nil nil nil #Error nil nil nil #Notification 15634 1029 nil 14578 31185883 1 nil nil nil nil #Notification nil nil nil nil 1410 138 144 34 9 1474 #createAt:extent: 34 2 482 9 53 482 2225 597 14832 1474 #contextMenu: 34 1 14992 14832 1474 #textLimit: 8 #(1073741823) 14832 1474 #caretPeriod: 8 #(530) 14832 1474 #wordWrap: 8 #(true) 14832 1474 #margins: 34 1 34 3 985158 3 ##(Smalltalk.ScintillaMargin) 1 14832 1 3 nil nil 5 nil 16626 3 14832 33 nil 3 67108863 5 nil 16626 5 14832 1 nil 3 -67108863 5 nil 14832 1474 #tabWidth: 8 #(4) 14832 1474 #maxCompletionListHeight: 8 #(9) 14832 1474 #edgeColumn: 8 #(1) 14832 1586 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 92 4 0 0 68 1 0 0] 8 #() 1648 nil 29 3538 3570 8 'Class Documentation' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 14224 34 2 8 1445007428 1025 16880 14898 nil false 14944 nil 14578 26337781 nil 5 14978 nil true 34 1 15026 1 3042 #editSaveClassComment 8 'Save' 1025 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 3394 nil true 12898 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 16880 nil 8 1594806719 9154 nil nil 15 nil 170 192 34 4 #normal 15634 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 15634 77 15680 15696 1 nil nil nil nil #callTip nil nil nil 34 256 17200 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 17216 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 15810 1 nil nil nil 16880 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1056 nil 170 176 1056 9215 nil nil nil nil 3008 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 17200 nil nil nil nil 1 nil 170 192 34 6 1 16066 1 16880 14578 65025 3 false 1 nil nil nil nil nil nil 3 16066 3 16880 16128 5 false 3 nil nil nil nil nil nil 5 16066 5 16880 16160 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 15634 1027 14578 60239 14578 31326207 1 nil nil nil nil #Warning nil nil nil #Error 15634 1031 14578 335 14578 31317503 1 nil nil nil nil #Error nil nil nil #Notification 15634 1029 nil 14578 31185883 1 nil nil nil nil #Notification nil nil nil nil 1410 138 144 34 10 1474 #createAt:extent: 34 2 482 9 53 482 2225 597 16880 1474 #contextMenu: 34 1 16976 16880 1474 #textLimit: 8 #(1073741823) 16880 1474 #hoverTime: 8 #(1000000) 16880 1474 #caretPeriod: 8 #(530) 16880 1474 #wordWrap: 8 #(true) 16880 1474 #margins: 34 1 34 3 16626 1 16880 1 3 nil nil 5 nil 16626 3 16880 33 nil 3 67108863 5 nil 16626 5 16880 1 nil 3 -67108863 5 nil 16880 1474 #tabWidth: 8 #(4) 16880 1474 #maxCompletionListHeight: 8 #(9) 16880 1474 #edgeColumn: 8 #(1) 16880 1586 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 92 4 0 0 68 1 0 0] 8 #() 1648 nil 29 3538 3570 8 'Method Source' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 14224 34 2 8 1445007428 1025 18256 14898 nil false 14944 nil 14578 26337781 nil 5 nil 3394 nil true 12898 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 18256 nil 8 1594806719 9154 nil nil 13 nil 170 192 34 4 #normal 15634 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 15634 77 15680 15696 1 nil nil nil nil #callTip nil nil nil 34 256 18480 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 18496 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 1056 170 192 34 2 #default 15810 1 nil nil nil 18256 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1056 nil 170 176 1056 9215 nil nil nil nil 3008 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 4 #normal 18480 #callTip 18496 nil nil nil nil 1 nil 170 192 34 12 1 16066 1 18256 14578 65025 3 false 1 nil nil nil nil nil nil 8 'indicator10' 16066 21 18256 16160 3 nil nil nil nil nil nil nil nil 8 'indicator9' 16066 19 18256 16160 13 nil nil nil nil nil nil nil nil 3 16066 3 18256 16128 5 false 3 nil nil nil nil nil nil 8 'indicator8' 16066 17 18256 3008 1 nil nil nil nil nil nil nil nil 5 16066 5 18256 16160 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 15634 1027 14578 60239 14578 31326207 1 nil nil nil nil #Warning nil nil nil #Error 15634 1031 14578 335 14578 31317503 1 nil nil nil nil #Error nil nil nil #Notification 15634 1029 nil 14578 31185883 1 nil nil nil nil #Notification nil nil nil nil 1410 138 144 34 9 1474 #createAt:extent: 34 2 482 9 53 482 2225 597 18256 1474 #textLimit: 8 #(1073741823) 18256 1474 #hoverTime: 8 #(500) 18256 1474 #caretPeriod: 8 #(530) 18256 1474 #wordWrap: 8 #(true) 18256 1474 #margins: 34 1 34 3 16626 1 18256 61 3 nil nil 5 nil 16626 3 18256 1 nil 3 67108863 nil nil 16626 5 18256 1 nil 3 -67108863 nil nil 18256 1474 #tabWidth: 8 #(4) 18256 1474 #maxCompletionListHeight: 8 #(9) 18256 1474 #edgeColumn: 8 #(1) 18256 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 92 4 0 0 68 1 0 0] 8 #() 1648 nil 29 3538 3570 8 'Comparison' nil nil 410 ##(Smalltalk.ShellView) 34 27 nil 14224 34 2 8 1078919168 131073 19696 nil 992 nil 517 nil nil nil 19696 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 19696 34 2 8 1140850688 131073 19792 nil 14578 26337781 nil 5 14978 nil true 34 5 15026 1 3042 #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 15026 1 3042 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 15026 1 3042 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 15026 1 3042 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 15026 1 3042 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 19792 514 170 176 1056 false 170 192 1056 nil 1410 138 144 34 2 1474 #createAt:extent: 34 2 482 1 1 482 2193 581 19792 1474 #contextMenu: 34 1 19872 19792 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 4 0 0 34 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 19792 34 2 8 1140850688 131073 20400 nil 992 nil 5 nil nil nil 20400 19762 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 20400 34 2 8 1140850945 262145 20480 nil nil nil 21 nil nil nil 20480 nil 8 1650166432 9154 nil nil nil 1410 138 144 34 2 1474 #createAt:extent: 34 2 482 1 541 482 1091 41 20480 1474 #text: 34 1 8 '
' 20480 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 14 1 0 0 33 2 0 0 34 1 0 0] 8 #() 1648 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 20400 34 2 8 1140920580 1025 20784 14898 nil false 14944 nil 14578 26337781 nil 21 nil nil nil 20784 nil 8 1594806719 9154 nil nil 13 nil 170 192 34 12 #lineNumber 15634 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 15634 77 15680 15696 1 nil nil nil nil #callTip nil nil nil #indentGuide 15634 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #normal 15634 1 nil nil 1 nil nil nil nil #normal nil nil nil #whitespace 15634 3 978 #teal nil 1 nil nil nil nil #whitespace nil nil nil #diff 15634 5 nil 14578 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 20992 21008 21040 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 20944 nil nil nil 20976 nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 15810 1 nil nil nil 20784 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1056 nil 170 176 1056 9215 nil nil nil nil 3008 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 20912 nil nil nil nil 1 nil 170 192 34 2 #diff 16066 1 20784 978 #yellow 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 15634 1027 14578 60239 14578 31326207 1 nil nil nil nil #Warning nil nil nil #Error 15634 1031 14578 335 14578 31317503 1 nil nil nil nil #Error nil nil nil #Notification 15634 1029 nil 14578 31185883 1 nil nil nil nil #Notification nil nil nil nil 1410 138 144 34 8 1474 #createAt:extent: 34 2 482 1 1 482 1091 541 20784 1474 #textLimit: 8 #(1073741823) 20784 1474 #caretPeriod: 8 #(530) 20784 1474 #wordWrap: 8 #(true) 20784 1474 #margins: 34 1 34 3 16626 1 20784 49 3 nil nil nil nil 16626 3 20784 1 nil nil 67108863 nil nil 16626 5 20784 1 nil nil nil nil nil 20784 1474 #canHScroll: 8 #(false) 20784 1474 #maxCompletionListHeight: 8 #(9) 20784 1474 #edgeColumn: 8 #(1) 20784 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 14 1 0 0] 8 #() 1648 nil 29 170 192 34 4 20784 8 'before' 20480 8 'beforeTitle' nil 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 1 1 482 1091 581 20400 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 34 1 0 0] 34 2 20784 20480 1648 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 19792 34 2 8 1140850688 1 22240 nil 14578 66047 nil 517 nil nil nil 7458 22240 nil 1 #left nil nil nil 7488 7504 nil 7488 nil 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 1091 1 482 11 581 22240 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 33 2 0 0 0 0 0 0 38 2 0 0 34 1 0 0] 8 #() 1648 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 19792 34 2 8 1140850688 131073 22496 nil 992 nil 5 nil nil nil 22496 19762 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 22496 34 2 8 1140850945 262145 22576 nil nil nil 21 nil nil nil 22576 nil 8 1650166432 9154 nil nil nil 1410 138 144 34 2 1474 #createAt:extent: 34 2 482 1 541 482 1093 41 22576 1474 #text: 34 1 8 '
' 22576 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 14 1 0 0 34 2 0 0 34 1 0 0] 8 #() 1648 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 22496 34 2 8 1140920580 1025 22880 14898 nil false 14944 nil 14578 26337781 nil 21 nil nil nil 22880 nil 8 1594806719 9154 nil nil 13 nil 170 192 34 12 #lineNumber 15634 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 15634 77 15680 15696 1 nil nil nil nil #callTip nil nil nil #indentGuide 15634 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #normal 15634 1 nil nil 1 nil nil nil nil #normal nil nil nil #whitespace 15634 3 21024 nil 1 nil nil nil nil #whitespace nil nil nil #diff 15634 5 nil 14578 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 23088 23104 23120 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 23040 nil nil nil 23072 nil nil 21090 21120 170 192 34 2 #default 15810 1 nil nil nil 22880 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1056 nil 170 176 1056 9215 nil nil nil nil 3008 nil nil 65 nil nil 21216 21296 3 170 192 34 2 #container 23008 nil nil nil nil 1 nil 170 192 34 2 #diff 16066 1 22880 21392 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 15634 1027 14578 60239 14578 31326207 1 nil nil nil nil #Warning nil nil nil #Error 15634 1031 14578 335 14578 31317503 1 nil nil nil nil #Error nil nil nil #Notification 15634 1029 nil 14578 31185883 1 nil nil nil nil #Notification nil nil nil nil 1410 138 144 34 8 1474 #createAt:extent: 34 2 482 1 1 482 1093 541 22880 1474 #textLimit: 8 #(1073741823) 22880 1474 #caretPeriod: 8 #(530) 22880 1474 #wordWrap: 8 #(true) 22880 1474 #margins: 34 1 34 3 16626 1 22880 49 3 nil nil nil nil 16626 3 22880 1 nil nil 67108863 nil nil 16626 5 22880 1 nil nil nil nil nil 22880 1474 #canHScroll: 8 #(false) 22880 1474 #maxCompletionListHeight: 8 #(9) 22880 1474 #edgeColumn: 8 #(1) 22880 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 34 2 0 0 14 1 0 0] 8 #() 1648 nil 29 170 192 34 4 22576 8 'afterTitle' 22880 8 'after' nil 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 1101 1 482 1093 581 22496 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 38 2 0 0 0 0 0 0 72 4 0 0 34 1 0 0] 34 2 22880 22576 1648 nil 27 1648 nil 27 170 192 34 2 19792 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 14978 nil true 34 4 15026 1 3042 #selectUpper 8 'Select &upper' 1 1 nil nil nil 15026 1 3042 #selectLower 8 'Select &lower' 1 1 nil nil nil 15090 4097 15026 1 3042 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 45353 nil nil 14978 nil true 34 3 15026 1 3042 #character 8 '&Character' 1 1 nil nil nil 15026 1 3042 #word 8 '&Word' 1 1 nil nil nil 15026 1 3042 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 45355 nil nil 14978 nil true 34 1 15026 1 3042 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 45357 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1410 138 144 34 3 1474 #createAt:extent: 34 2 482 9 53 482 2225 597 19696 1474 #text: 34 1 8 'Comparison' 19696 1474 #updateMenuBar 1056 19696 1586 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 92 4 0 0 68 1 0 0] 34 1 19792 1648 nil 27 18256 170 192 34 10 18256 8 'methodSource' 16880 8 'classDocumentation' 14512 8 'sunit' 14832 8 'classDefinition' 19696 8 'comparisonTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 14224 34 2 8 1140916736 1 25120 1154 138 144 34 5 14800 16848 18224 14352 19664 nil 1216 nil nil 1 nil nil nil 25120 nil 8 1650396656 1250 0 nil 1282 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 25248 7 257 nil 1250 0 nil 1282 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 25296 7 257 nil 1392 nil nil nil nil nil #smallIcons nil nil nil nil nil 1410 138 144 34 3 1474 #createAt:extent: 34 2 482 1 1 482 2241 657 25120 1474 #basicSelectionsByIndex: 34 1 8 #(3) 25120 1474 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 25120 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 72 1 0 0] 8 #() 1648 nil 27 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 1 1 482 2241 657 14224 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 72 1 0 0] 34 6 14832 16880 18256 14512 19696 25120 1648 nil 27 3234 3280 1 3296 1 6912 1 3312 -39 170 192 34 2 14224 8 'textAreaTabs' nil 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 1 705 482 2241 697 12560 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 96 1 0 0 96 4 0 0 188 2 0 0] 34 2 14224 12672 1648 nil 27 25 true 170 192 34 2 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 26000 nil 992 nil 517 nil nil nil 7458 26000 nil 1 #left nil nil nil 7488 7504 nil 7488 nil 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 1 695 482 2241 11 26000 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 91 1 0 0 96 4 0 0 96 1 0 0] 8 #() 1648 nil 27 8 'splitter' nil 1410 138 144 34 1 1474 #createAt:extent: 34 2 482 2879 21 482 2241 1401 416 1586 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 159 5 0 0 10 0 0 0 255 9 0 0 198 2 0 0] 34 3 576 26000 12560 1648 nil 27 )! !
!JadeiteBrowserPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

