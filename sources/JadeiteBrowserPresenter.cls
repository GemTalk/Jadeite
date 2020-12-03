"Filed out from Dolphin Smalltalk 7"!

JadeiteProjectsBrowserPresenter subclass: #JadeiteBrowserPresenter
	instanceVariableNames: 'dictionaryPresenter packageDictionaryCards globalsTab autoCommitButton search previousTabViewArrangement previousTopViewArrangement specEditor componentListPresenter componentPackageContainer packageDictionaryContainer'
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
	self issueCommand: dictionaryService.
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
	self issueCommand: service.
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
	self issueCommand: browserService!

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
	self issueCommand: dictionaryService.
	self removeGlobalsTab.
	self buildGlobalsTab!

basicUnloadProjects: projectNames
	super basicUnloadProjects: projectNames.
	dictionaryPresenter model: ListModel new!

basicUpdateProject
	self updateProjectPackages.
	self updateProjectInfo.
	projectInfoTab ensureVisible.
	self sundryCleanup!

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

buildPreferencesMenu
	| preferencesMenu showPackageItem |
	preferencesMenu := Menu fromStrings: self preferencesMenuStrings.
	preferencesMenu addSeparator.
	showPackageItem := preferencesMenu
				addItem: (CommandMenuItem command: #togglePackageDictionaryColumn description: 'Package list visible').
	showPackageItem isRadioButtonStyle: true.
	^preferencesMenu!

buildProjectTabIfNecessary
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
	menuStrings addLast: 'Move To Package ...//moveClassToPackage'.
	menuStrings add: '-'.
	menuStrings addLast: definedLabel , '//gotoClassDefinedPackage'.
	menuStrings addLast: containedDictionaryLabel , '//gotoDictionary'.
	^menuStrings!

clearComponentList
	componentListPresenter model: (JadeiteTreeModel new
				searchPolicy: SearchPolicy equality;
				reset)!

comparisonPresenter

	^comparisonPresenter!

componentListPresenter
	^componentListPresenter!

componentListPresenter: anObject
	componentListPresenter := anObject!

contextObject
	^self selectedClass ifNil: [^gciSession oopNil value] ifNotNil: [:classService | classService oop]!

copyProjectInfo
	projectInfoTab selection last ifNil:[^self]. 
	(projectInfoTab selection first perform: projectInfoTab selection last asSymbol) displayString copyToClipboard!

createComponents
	super createComponents.
	dictionaryPresenter := self add: ListPresenter new name: 'dictionariesList'.
	packageDictionaryCards := self add: Presenter new name: 'packageDictionaryCards'.
	autoCommitButton := self add: Presenter new name: 'autoCommitButton'.
	specEditor := self add: JadeitePropertyInspector new name: 'specEditor'.
	componentListPresenter := self add: JadeiteTreePresenter new name: 'componentTree'.
	componentPackageContainer := self add: Presenter new name: 'componentPackageContainer'. 
	packageDictionaryContainer := self add: Presenter new name: 'packageDictionaryContainer'.!

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
		to: self.
	componentListPresenter
		when: #selectionChanged
		send: #updateComponentPackages
		to: self.
	packageDictionaryCards
		when: #dragOver:
			send: #onDragOverPackageList:
			to: self;
		when: #drop:
			send: #onDropOnPackageList:
			to: self!

createSchematicWiringForClassHierarchy
		
	classHierarchyPresenter
		when: #drag:
			send: #onDragClass:
			to: self;
		when: #dragCut:
			send: #onDragCutClassHierarchy:
			to: self;
		when: #dragOver:
			send: #onDragOverClassHierarchy:
			to: self;
		when: #drop:
			send: #onDropOnClassHierarchy:
			to: self;
		when: #aboutToDisplayMenu:
			send: #updateClassMenu:
			to: self;
		when: #selectionChanging:
			send: #aboutToChange:
			to: self;
		when: #selectionChanging:
			send: #releasedReferencedServices:
			to: self;
		when: #selectionChanged
			send: #refreshClass
			to: self;
		when: #actionPerformed
			send: #hierarchyClassDoubleClicked
			to: self!

createSchematicWiringForClassList
	"dolphin does not consistently send #selectionChanging: events after
	the class list has been updated. It always sends #selectionChanged. 
	However, in order to avoid conflicting updates and commands to the server
	we sometimes need to update the selection on the #selectionChanging. 
	Hence, two very similar methods. See issue #334. 
	"

	classListPresenter
		when: #drag:
			send: #onDragClass:
			to: self;
		when: #dragCut:
			send: #onDragCutClassList:
			to: self;
		when: #dragOver:
			send: #onDragOverClassList:
			to: self;
		when: #drop:
			send: #onDropOnClassList:
			to: self;
		when: #keyTyped:
			send: #delayUpdate
			to: self;
		when: #aboutToDisplayMenu:
			send: #updateClassMenu:
			to: self;
		when: #selectionChanging:
			send: #aboutToChange:
			to: self;
		when: #selectionChanging:
			send: #releasedReferencedServices:
			to: self;
		when: #selectionChanged:
			send: #selectedClassChanged:
			to: self
			with: true;
		when: #selectionChanged
			send: #refreshClass
			to: self;
		when: #labelOf:changedTo:
			send: #labelOfClass:changedTo:
			to: self;
		when: #aboutToEditLabel:accept:
			send: #aboutToEditClassLabel:accept:
			to: self;
		when: #labelOf:editedTo:accept:
			send: #labelOfClass:editedTo:accept:
			to: self;
		when: #keyTyped:
			send: #selectServiceStartingWith:
			to: classListPresenter!

createSchematicWiringForMethodList
	methodListPresenter
		when: #drag: 				send: #onDragMethod: 			to: self; 
		when: #dragCut: 			send: #onDragCutMethod: 			to: self; 
		when: #keyTyped: 			send: #delayUpdate 				to: self; 
		when: #aboutToDisplayMenu: 	send: #updateMethodMenu:		to: self;
		when: #selectionChanging:		send: #aboutToChange:			to: self; 
		when: #keyTyped: 			send: #selectServiceStartingWith: 	to: methodListPresenter; 
		when: #selectionChanged 		send: #methodSelectionChanged 	to: self!

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
	[self issueCommand: browserService] on: Error
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
			do: [:ex | ^self showMethodRecompilationError: ex].
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
			self issueCommand: classService.
			self selectClassNamed: classService name.
			classHierarchyPresenter view expandAll]!

expandFullHierarchy
	self expandFullAt: self selectedClass!

findRemovedServices
	| browserService |
	browserService := RowanBrowserService new
				command: #findRemovedServices:;
				commandArgs: (Array with: BrowserUpdate current activeServices asArray).
	BrowserUpdate current issueCommands: (Array with: browserService) session: self gciSession!

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
	self projectListPresenter selectionIfNone: [^false].
	^self projectListPresenter selection name = RowanService notRowanizedPackageName!

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

loadProjects
	self loadProjectsFrom: self.
	self findRemovedServices!

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

moveClassToPackage
	| packageService |
	packageService := JadeitePackageDialog showModal: 'DefaultView'
				on: (self class allPackagesIn: self gciSession).
	packageService ifNil: [^self].
	self moveClassToPackageNamed: packageService name!

moveClassToPackageNamed: packageName
	| packageServiceToSelect |
	self selectedClass ifNil: [^self].
	self selectedClass
		command: #moveToPackageNamed:;
		commandArgs: (Array with: packageName).
	self issueCommand: self selectedClass.
	packageServiceToSelect := packageListPresenter list
				detect: [:packageService | packageService name = packageName].
	packageListPresenter selections: (self selectedPackageServices asOrderedCollection
				add: packageServiceToSelect;
				yourself)!

newProjectNamed: projectName
	RowanBrowserService new
		newProjectNamed: projectName
		session: self gciSession
		windowHandle: self view handle value!

noClassSelectedInEitherPresenter
	classListPresenter selectionIfNone: [classHierarchyPresenter selectionIfNone: [^true]].
	^false!

onDragClass: aSession
	| className |
	className := self selectedClass name.
	^self onDragClass: aSession className: className
!

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

onDragOverPackageList: aSession 
	aSession operation: nil.
	aSession dragObjects isEmpty ifTrue: [^self].
	aSession suggestedTarget isNil ifTrue: [^self].
	(aSession isFormatAvailable: #'package') ifTrue: [^self].
	(aSession isFormatAvailable: #'class') 	ifTrue: [^self onDragClassesOverPackageList: aSession].
	MessageBox notify: 'Sorry, we are not yet prepared to handle ' , aSession printString , '!!'.
	SessionManager current pause.
!

onDropClassesOnPackage: packageService session: aSession
	| classes |
	classes := aSession dragObjects collect: [:each | each format: #class].
	classes isEmpty ifFalse: [^self moveClassToPackageNamed: packageService name].
	MessageBox notify: 'Sorry, we are not yet prepared to handle ' , aSession printString , '!!'.
	SessionManager current pause!

onDropClassesOnPackageList: aSession 

	self
		onDropClassesOnPackage: aSession suggestedTarget 
		session: aSession.!

onDropOnPackageList: aSession 
	(aSession isFormatAvailable: #'class') 	ifTrue: [^self onDropClassesOnPackageList: aSession].
	MessageBox notify: 'Sorry, we are not yet prepared to handle ' , aSession printString , '!!'.
	SessionManager current pause.!

onViewClosed
	super onViewClosed.
	BrowserUpdate current removeEventsTriggeredFor: componentListPresenter!

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

preferencesMenuStrings

	false ifTrue: [		"adding explicit senders ensures that packaging will not drop methods and allows us to find references by browsing senders"
		self openSourceStyler; setColorForCompileErrors; setColorForNoEdits; setColorForUnsavedEdits.
	].
	^#(
		'&Preferences'
		'&Source Styler...//openSourceStyler'
		'-'
		'Reset &Font Size//resetFontSize'
		'Set Font Size...//setFontSize'
		'-'
		'&Reset Colors//resetColors'
		'Color for &Compile Errors...//setColorForCompileErrors'
		'Color for &No Edits...//setColorForNoEdits'
		'Color for &Unsaved Edits...//setColorForUnsavedEdits'
	).
!

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

projectInfoTab
	^projectInfoTab!

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
	#togglePackageDictionaryColumn == aCommandQuery command
		ifTrue: 
			[aCommandQuery isEnabled: true.
			aCommandQuery isChecked: packageDictionaryContainer view isWindowVisible.
			^true].
	^super queryCommand: aCommandQuery!

reformatSource
	| methodService |
	(methodService := self methodToReformat)
		source: methodSourcePresenter value;
		command: #reformatSource;
		commandArgs: Array new.
	[self issueCommand: methodService] on: Error
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
	self issueCommand: selection.
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
		register: packageListPresenter
			selector: #componentPackagesUpdate:browser:
			browser: self;
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
	self issueCommand: answeringService.
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
	self updateDictionaries.
	self clearComponentList!

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
			classHierarchyPresenter model: TreeModel new].
	packageListPresenter view isDropTarget: true. !

statusBarText
	
	^statusBarText !

statusBarText: string
	statusBarText value: string!

textTabChanged
	methodSourcePresenter view cancelCallTip.
	textAreaTabs currentCard name = 'projectInfo' ifTrue: [projectInfoTab ensureVisible].
	textAreaTabs currentCard name = 'sunit'
		ifTrue: [sunitPresenter methodListPresenter setFocus	"to ensure sunit bar is enabled"].
	self updateMenuBar!

togglePackageDictionaryColumn
	packageDictionaryContainer view isWindowVisible
		ifTrue: 
			[componentPackageContainer view arrangement: 1 / 6.
			packageDictionaryContainer view hide]
		ifFalse: 
			[componentPackageContainer view arrangement: 1 / 3.
			packageDictionaryContainer view show].
!

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

updateComponentPackages
	packageListPresenter clear.
	componentListPresenter selections isEmpty ifTrue: [^self].
	self updateServices: componentListPresenter selections.
	packageListPresenter selections: packageListPresenter list. 
	self updateServices: packageListPresenter selections.
	self sundryCleanup!

updateDictionaries
	| browserService |
	browserService := RowanBrowserService new.
	browserService command: #updateDictionaries.
	self issueCommand: browserService!

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
					self issueCommand: service.
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
	self issueCommand: service!

updateMenuBar
	| shellView menuBar methodFilterMenu textAreaMenu methodMenu |
	methodFilterMenu := Menu fromStrings: (self isCategoryTabSelected
						ifTrue: [self categoriesMenuStrings]
						ifFalse: [self variablesMenuStrings]).
	textAreaMenu := Menu fromStrings: (self isGlobalsTabSelected
						ifTrue: [self globalsMenuStrings]
						ifFalse: [self editMenuStrings]).
	shellView := self parentPresenter parentPresenter view.
	menuBar := shellView menuBar
				clear;
				addItem: (Menu fromStrings: self jadeMenuStrings);
				addItem: self projectMenu;
				addItem: (Menu fromStrings: self pkgsMenuStrings);
				addItem: (Menu fromStrings: self classesMenuStrings);
				addItem: methodFilterMenu;
				addItem: (methodMenu := Menu fromStrings: self methodsMenuStrings);
				addItem: textAreaMenu;
				addItem: self buildPreferencesMenu;
				yourself.
	shellView menuBar: menuBar.
	self updateMethodMenu: methodMenu!

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
	self clearComponentList. 
	self projectListPresenter selectionIfNone: 
			[packageListPresenter clear.
			dictionaryPresenter clear.
			self possiblyClearProjectInfoTab.
			self updateTabLabel.
			^self].
	classHierarchyPresenter model: TreeModel new.
	self isNoneProjectSelected
		ifTrue: 
			[self showDictionaryList.
			self updateTabLabel.
			self updateProjectInfo]
		ifFalse: 
			[self showPackageList.
			self updateTabLabel.
			self basicUpdateProject]!

updateProjectInfo
	| service |
	self removeAppropriateTab.
	self isNoneProjectSelected ifTrue: [^self buildGlobalsTab].
	self buildProjectTabIfNecessary.
	service := projectListPresenter selectionIfNone: [^projectInfoTab list: ListModel new].
	self updateTabLabel.
	self updateProjectTabFor: service!

updateProjectTabFor: service
	| array |
	array := Array writeStream: 1.
	array nextPut: (Array with: service with: 'rowanProjectsHome').
	array nextPut: (Array with: RowanProjectService new with: nil).
	service wasUpdated
		ifTrue: 
			[array nextPut: (Array with: service with: 'name').
			array nextPut: (Array with: service with: 'sha').
			array nextPut: (Array with: service with: 'branch').
			array nextPut: (Array with: service with: 'isSkew').
			array nextPut: (Array with: service with: 'isDirty').
			array nextPut: (Array with: service with: 'projectUrl').
			service == service ifFalse: [array nextPut: (Array with: RowanProjectService new with: nil)]].
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
!JadeiteBrowserPresenter categoriesFor: #basicUpdateProject!private!updating! !
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
!JadeiteBrowserPresenter categoriesFor: #buildPreferencesMenu!menus!private!updating! !
!JadeiteBrowserPresenter categoriesFor: #buildProjectTabIfNecessary!private!tabs! !
!JadeiteBrowserPresenter categoriesFor: #categoriesMenuStrings!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #checkout!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #checkoutTag!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #classCommentChanged!event handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #classesMenuStrings!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #clearComponentList!initialize/release!public! !
!JadeiteBrowserPresenter categoriesFor: #comparisonPresenter!accessing!public! !
!JadeiteBrowserPresenter categoriesFor: #componentListPresenter!accessing!private! !
!JadeiteBrowserPresenter categoriesFor: #componentListPresenter:!accessing!private! !
!JadeiteBrowserPresenter categoriesFor: #contextObject!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #copyProjectInfo!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #createComponents!initialize/release!public! !
!JadeiteBrowserPresenter categoriesFor: #createListViewFor:!private! !
!JadeiteBrowserPresenter categoriesFor: #createNewProject!menu handlers!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #createSchematicWiring!initialize/release!public! !
!JadeiteBrowserPresenter categoriesFor: #createSchematicWiringForClassHierarchy!create schemantic wiring!public! !
!JadeiteBrowserPresenter categoriesFor: #createSchematicWiringForClassList!create schemantic wiring!public! !
!JadeiteBrowserPresenter categoriesFor: #createSchematicWiringForMethodList!create schemantic wiring!public! !
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
!JadeiteBrowserPresenter categoriesFor: #findRemovedServices!menu handlers support!private! !
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
!JadeiteBrowserPresenter categoriesFor: #isNoneProjectSelected!event handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #isProjectItemEnabled:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #isRowanProjectSelected!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #jadeInspect!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #loadProjects!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #makeSameSelectionsIn:as:!menu handlers!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #maxAutoCompleteListSize!constants!public! !
!JadeiteBrowserPresenter categoriesFor: #methodMenu:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #methodSelectionChanged!event handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #methodsMenuStrings!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #methodsUpdate:!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #methodToReformat!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #methodValueChanged!event handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #moveClassToPackage!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #moveClassToPackageNamed:!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #newProjectNamed:!menu handlers!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #noClassSelectedInEitherPresenter!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #onDragClass:!drag & drop!public! !
!JadeiteBrowserPresenter categoriesFor: #onDragMethod:!drag & drop!public! !
!JadeiteBrowserPresenter categoriesFor: #onDragOverPackageList:!drag & drop!public! !
!JadeiteBrowserPresenter categoriesFor: #onDropClassesOnPackage:session:!drag & drop!public! !
!JadeiteBrowserPresenter categoriesFor: #onDropClassesOnPackageList:!drag & drop!public! !
!JadeiteBrowserPresenter categoriesFor: #onDropOnPackageList:!drag & drop!public! !
!JadeiteBrowserPresenter categoriesFor: #onViewClosed!event handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #onViewOpened!event handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #openSourceStyler!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #openSpecFile!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #packageDictionaryCards!accessing!private! !
!JadeiteBrowserPresenter categoriesFor: #possiblyClearProjectInfoTab!event handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #preferencesMenuStrings!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #previousTabViewArrangement!accessing!private! !
!JadeiteBrowserPresenter categoriesFor: #previousTabViewArrangement:!accessing!private! !
!JadeiteBrowserPresenter categoriesFor: #previousTopViewArrangement!accessing!private! !
!JadeiteBrowserPresenter categoriesFor: #previousTopViewArrangement:!accessing!private! !
!JadeiteBrowserPresenter categoriesFor: #projectInfoMenu!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #projectInfoMenuStrings!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #projectInfoTab!accessing!public! !
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
!JadeiteBrowserPresenter categoriesFor: #textTabChanged!event handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #togglePackageDictionaryColumn!event handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateAfterFindClass:!menu handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateAfterFindClassInDictionary:!menu handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateAfterFindClassInPackage:!menu handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateAutoCommit!public!register presenters!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateClass:!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateClasses!event handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateComponentPackages!event handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateDictionaries!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateDictionary!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateGlobalsTab!private!tabs! !
!JadeiteBrowserPresenter categoriesFor: #updateHierarchy!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateHierarchyForPacktionaries!private!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateMenuBar!menus!public!updating! !
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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil 328198 ##(Smalltalk.Point) 3001 1601 517 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 576 nil nil nil 5 nil nil nil 576 514 170 176 34 8 410 ##(Smalltalk.ContainerView) 34 15 nil 576 34 2 8 1140850688 131073 688 nil nil nil 5 nil nil nil 688 514 170 176 8 #() false 170 192 34 2 410 ##(Smalltalk.ListView) 34 45 nil 688 34 2 8 1409405261 1025 832 590662 2 ##(Smalltalk.ListModel) 138 144 784 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 327686 ##(Smalltalk.Color) #default nil 5 nil nil nil 832 nil 8 1737156720 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 1 920646 5 ##(Smalltalk.ListViewColumn) 8 'Column 1' 425 #left 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 1184 8 'doIt' 8 '[:each | each displayName]' 8 #[30 105 226 0 106] #displayName 1200 7 257 nil ##(Smalltalk.SortedCollection) nil nil 832 nil 3 1186 0 nil 1218 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 1296 7 257 nil 1186 0 nil 1218 3 1 1184 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 1376 7 257 nil #report 8 #() nil 133217 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 482 1 1 482 433 795 832 1538 #text: 34 1 8 'Column 1' 832 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 216 0 0 0 141 1 0 0] 8 #() 482 193 193 nil 35 8 'projectList' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 1 482 433 795 688 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 216 0 0 0 141 1 0 0] 34 1 832 1728 nil 27 524806 ##(Smalltalk.Fraction) 7 41 410 ##(Smalltalk.ContainerView) 34 15 nil 576 34 2 8 1140850688 131073 1952 nil nil nil 5 nil nil nil 1952 514 170 176 784 false 170 192 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 1952 34 2 8 1140850688 131073 2080 nil nil nil 5 nil nil nil 2080 514 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 2080 34 2 8 1409286144 131073 2192 nil 992 nil 21 nil nil nil 2192 656710 1 ##(Smalltalk.CardLayout) 138 144 784 nil nil nil nil 170 192 784 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 2192 34 2 8 1140916736 1 2320 898 138 144 784 nil 960 nil nil 17 nil nil nil 2320 nil 8 1737494000 1186 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 2432 7 257 nil 1186 0 nil 2450 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 2496 7 257 nil 1088 nil nil nil nil nil #noIcons nil nil nil nil nil 1474 138 144 34 2 1538 #createAt:extent: 34 2 482 1 1 482 477 795 2320 1538 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 2320 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 238 0 0 0 141 1 0 0] 8 #() 1728 nil 27 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 1 482 477 795 2192 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 238 0 0 0 141 1 0 0] 34 1 2320 1728 nil 27 3 false 170 192 34 2 2192 8 'packageDictionaryCards' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 485 1 482 477 795 2080 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 242 0 0 0 0 0 0 0 224 1 0 0 141 1 0 0] 34 1 2192 1728 nil 27 8 'packageDictionaryContainer' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 433 1 482 961 795 1952 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 216 0 0 0 0 0 0 0 184 2 0 0 141 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 1952 34 2 8 1140850688 131073 3280 nil nil nil 5 nil nil nil 3280 514 170 176 784 false 170 192 784 nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 1 482 475 795 3280 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 237 0 0 0 141 1 0 0] 34 1 410 ##(Smalltalk.CardContainer) 34 16 nil 3280 34 2 8 1409286144 131073 3552 nil 992 nil 5 nil nil nil 3552 2258 138 144 34 1 721414 ##(Smalltalk.Association) 8 'Components' 410 ##(Smalltalk.JadeiteTreeView) 34 27 nil 3552 34 2 8 1140916775 1025 3712 1049670 3 ##(Smalltalk.JadeiteTreeModel) nil 960 984070 ##(Smalltalk.JadeiteTreeNode) nil nil nil nil 170 192 784 992 nil 13 nil nil nil 3712 nil 8 1737728064 1186 0 nil 1218 2 1 1024 8 'doIt' 8 '[:service | service displayString]' 8 #[30 105 226 0 106] #displayString 3872 7 257 nil ##(Smalltalk.IconicListAbstract) 1088 nil nil nil nil nil 170 176 784 33 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 784 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 9 53 482 459 735 3712 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 233 0 0 0 137 1 0 0] 8 #() 1728 nil 27 3712 nil nil nil 170 192 34 2 3712 8 'componentTree' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 3552 34 2 8 1140916736 1 4192 898 138 144 34 1 3696 nil 960 nil nil 1 nil nil nil 4192 nil 8 1737494000 1186 0 nil 2450 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 4320 7 257 nil 1186 0 nil 2450 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 4368 7 257 nil 1088 nil nil nil nil nil #noIcons nil nil nil nil nil 1474 138 144 34 3 1538 #createAt:extent: 34 2 482 1 1 482 475 795 4192 1538 #setSingleSelection: 8 #(1) 4192 1538 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 4192 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 237 0 0 0 141 1 0 0] 8 #() 1728 nil 27 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 1 482 475 795 3552 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 237 0 0 0 141 1 0 0] 34 2 3712 4192 1728 nil 27 1728 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 1952 34 2 8 1140850688 1 4800 nil 992 nil 517 nil nil nil 1510470 1 ##(Smalltalk.DraggableViewInteractor) 4800 nil 1 #left nil nil nil 482 1 1 482 9 9 nil 4896 nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 475 1 482 11 795 4800 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 237 0 0 0 0 0 0 0 242 0 0 0 141 1 0 0] 8 #() 1728 nil 27 2080 1728 nil 27 1922 3 7 410 ##(Smalltalk.ContainerView) 34 15 nil 576 34 2 8 1140850688 131073 5104 nil nil nil 5 nil nil nil 5104 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.CardContainer) 34 16 nil 5104 34 2 8 1409286144 131073 5232 nil 992 nil 5 nil nil nil 5232 2258 138 144 34 2 3666 590662 1 ##(Smalltalk.CardLabel) 8 'Hierarchy' nil nil 410 ##(Smalltalk.TreeView) 34 27 nil 5232 34 2 8 1409356327 1025 5408 590918 3 ##(Smalltalk.TreeModel) nil 960 525062 ##(Smalltalk.TreeNode) nil nil nil 170 192 784 992 nil 29 nil nil nil 5408 nil 8 1737728064 1186 0 nil 1218 2 1 1184 8 'doIt' 8 '[:each | each displayString]' 8 #[30 105 226 0 106] #displayString 5568 7 257 nil ##(Smalltalk.IconicListAbstract) 1088 nil 1186 0 nil 1218 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 5648 7 257 nil 1186 0 nil 1218 5 1 1184 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 5728 7 257 nil nil nil 170 176 784 33 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 784 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 9 53 482 561 635 5408 1666 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 28 1 0 0 87 1 0 0] 8 #() 1728 nil 27 3666 5362 8 'Classes' nil nil 410 ##(Smalltalk.ListView) 34 45 nil 5232 34 2 8 1409372237 1025 6048 898 138 144 784 nil 960 992 nil 29 nil nil nil 6048 nil 8 1737156720 1026 #displayString 8 #() nil 1088 nil nil nil nil nil nil 138 144 34 1 1138 8 '' 553 #left 1026 #displayString 8 #() 1026 #<= 8 #() nil nil 6048 nil 3 nil 1186 0 nil 1218 5 1 1184 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 6320 7 257 nil #report 1456 nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 9 53 482 561 635 6048 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 28 1 0 0 87 1 0 0] 8 #() 1728 nil 35 6048 nil nil nil 170 192 34 4 6048 8 'classList' 5408 8 'classHierarchy' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 5232 34 2 8 1140916736 1 6624 898 138 144 34 2 6016 5376 nil 960 nil nil 1 nil nil nil 6624 nil 8 1737494000 1186 0 nil 2450 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 6752 7 257 nil 1186 0 nil 2450 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 6800 7 257 nil 1088 nil nil nil nil nil #smallIcons nil nil nil nil nil 1474 138 144 34 3 1538 #createAt:extent: 34 2 482 1 1 482 577 695 6624 1538 #setSingleSelection: 8 #(1) 6624 1538 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 6624 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 32 1 0 0 91 1 0 0] 8 #() 1728 nil 27 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 1 482 577 695 5232 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 32 1 0 0 91 1 0 0] 34 3 6048 5408 6624 1728 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 7266 #fixedParentRight 1 7266 #fixedParentTop 1 7266 #fixedParentBottom -99 410 ##(Smalltalk.PushButton) 34 20 nil 5104 34 2 8 1140858880 1 7344 nil 978 #silver nil 5 nil nil nil 7344 nil 8 1737266240 1180998 4 ##(Smalltalk.CommandDescription) #gotoClassDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 745 482 577 51 7344 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 116 1 0 0 32 1 0 0 141 1 0 0] 8 #() 1728 nil 29 7234 7280 1 7296 1 7328 -49 7328 1 410 ##(Smalltalk.CardContainer) 34 16 nil 5104 34 2 8 1409286144 131073 7648 nil 992 nil 5 nil 263174 ##(Smalltalk.Font) nil true 524550 ##(Smalltalk.LOGFONTW) 8 #[240 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 188 2 0 0 0 0 0 0 1 2 1 34 83 0 121 0 115 0 116 0 101 0 109 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 7648 2258 138 144 34 2 3666 5362 8 'Class' nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 7648 34 2 8 1140850688 131073 7904 nil nil nil 5 nil nil nil 7904 nil 170 192 784 nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 9 9 482 561 1 7904 1666 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 28 1 0 0 4 0 0 0] 8 #() 1728 nil 27 3666 5362 8 'Instance' nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 7648 34 2 8 1140850688 131073 8192 nil nil nil 5 nil nil nil 8192 nil 170 192 784 nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 9 9 482 561 1 8192 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 28 1 0 0 4 0 0 0] 8 #() 1728 nil 27 8192 nil nil nil 170 192 34 4 7904 8 'classTab' 8192 8 'instanceTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 7648 34 2 8 1140916738 1 8496 898 138 144 34 2 8160 7872 nil 960 nil nil 1 nil nil nil 8496 nil 8 1737494000 1186 0 nil 2450 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 8624 7 257 nil 1186 0 nil 2450 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 8672 7 257 nil 1088 nil nil nil nil nil #smallIcons nil nil nil nil nil 1474 138 144 34 3 1538 #createAt:extent: 34 2 482 1 1 482 577 51 8496 1538 #setSingleSelection: 8 #(1) 8496 1538 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 8496 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 32 1 0 0 25 0 0 0] 8 #() 1728 nil 27 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 695 482 577 51 7648 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 91 1 0 0 32 1 0 0 116 1 0 0] 34 3 8192 7904 8496 1728 nil 27 7234 7280 1 7296 1 7328 -99 7266 #fixedViewTop 51 170 192 34 6 5232 8 'classHierarchyTabs' 7344 8 'definedPackageClassText' 7648 8 'instanceClassTabs' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1403 1 482 577 795 5104 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 189 2 0 0 0 0 0 0 221 3 0 0 141 1 0 0] 34 3 5232 7648 7344 1728 nil 27 1922 3 11 410 ##(Smalltalk.ContainerView) 34 15 nil 576 34 2 8 1140850688 131073 9392 nil nil nil 5 nil nil nil 9392 514 170 176 34 4 410 ##(Smalltalk.CardContainer) 34 16 nil 9392 34 2 8 1409286144 131073 9504 nil 992 nil 5 nil nil nil 9504 2258 138 144 34 2 3666 8 'Category' 410 ##(Smalltalk.ListView) 34 45 nil 9504 34 2 8 1409372233 1025 9648 898 138 144 784 nil 960 992 nil 21 nil nil nil 9648 nil 8 1737156720 1026 #displayString 8 #() nil 1088 nil nil nil nil nil nil 138 144 34 1 1138 8 'Column 1' 351 #left 1026 #displayString 8 #() ##(Smalltalk.SortedCollection) 1186 0 nil 1218 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each]' 1779525917 9888 7 257 nil nil 9648 nil 3 nil nil #report 1456 nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1474 138 144 34 2 1538 #createAt:extent: 34 2 482 9 53 482 359 735 9648 1538 #text: 34 1 8 'Column 1' 9648 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 183 0 0 0 137 1 0 0] 8 #() 1728 nil 35 3666 8 'Variables' 410 ##(Smalltalk.ListView) 34 45 nil 9504 34 2 8 1409372233 1025 10192 898 138 144 784 nil 960 992 nil 21 nil nil nil 10192 nil 8 1737156720 1026 #displayString 8 #() nil 1088 nil nil 1186 0 nil 1218 4 1 1184 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 10336 7 257 nil nil nil nil 138 144 34 1 1138 8 'Column 1' 351 #left 1026 #displayString 10320 ##(Smalltalk.SortedCollection) nil nil 10192 nil 3 nil 1186 0 nil 1218 4 1 1184 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 10496 7 257 nil #report 1456 nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1474 138 144 34 2 1538 #createAt:extent: 34 2 482 9 53 482 359 735 10192 1538 #text: 34 1 8 'Column 1' 10192 1666 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 183 0 0 0 137 1 0 0] 8 #() 1728 nil 35 9648 nil nil nil 170 192 34 4 9648 8 'categoryList' 10192 8 'variableList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 9504 34 2 8 1140916736 1 10848 898 138 144 34 2 9632 10176 nil 960 nil nil 1 nil nil nil 10848 nil 8 1737494000 1186 0 nil 2450 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 10976 7 257 nil 1186 0 nil 2450 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 11024 7 257 nil 1088 nil nil nil nil nil #noIcons nil nil nil nil nil 1474 138 144 34 3 1538 #createAt:extent: 34 2 482 1 1 482 375 795 10848 1538 #setSingleSelection: 8 #(1) 10848 1538 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 10848 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 187 0 0 0 141 1 0 0] 8 #() 1728 nil 27 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 1 482 375 795 9504 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 187 0 0 0 141 1 0 0] 34 3 9648 10192 10848 1728 nil 27 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 232 63 410 ##(Smalltalk.ContainerView) 34 15 nil 9392 34 2 8 1140850688 131073 11488 nil nil nil 5 nil nil nil 11488 5170 170 176 34 6 410 ##(Smalltalk.PushButton) 34 20 nil 11488 34 2 8 1140858880 1 11600 nil 992 nil 5 nil nil nil 11600 nil 8 1737266240 7442 #gotoMethodDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 745 482 629 51 11600 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 116 1 0 0 58 1 0 0 141 1 0 0] 8 #() 1728 nil 29 7234 7280 1 7296 1 7328 -49 7328 1 410 ##(Smalltalk.ListView) 34 45 nil 11488 34 2 8 1409372233 1025 11872 898 138 144 784 nil 960 992 nil 13 nil nil nil 11872 nil 8 1737156720 1026 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 1088 nil nil nil nil nil nil 138 144 34 2 1138 8 '' 41 #left 1538 #empty 8 #() 16 1026 #<= 8 #() nil nil 11872 1186 0 nil 1218 2 1 1184 8 'doIt' 8 '[:each | each subSuperIcon]' 8 #[30 105 226 0 106] #subSuperIcon 12144 7 257 nil 1 nil nil 1138 8 'Selector' 581 #left 1026 #displayString 12000 ##(Smalltalk.SortedCollection) nil nil 11872 nil 3 nil 1186 0 nil 1218 5 1 1184 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 12272 7 257 nil #report 1456 nil 133221 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 55 482 629 691 11872 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 27 0 0 0 58 1 0 0 116 1 0 0] 8 #() 1728 nil 35 7234 7280 1 7296 1 7312 55 7328 -49 410 ##(Smalltalk.TextEdit) 34 16 nil 11488 34 2 8 1140916352 1025 12528 nil 992 nil 5 nil nil nil 12528 nil 8 1737104896 852486 ##(Smalltalk.NullConverter) nil nil 3 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 1 482 629 51 12528 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 58 1 0 0 25 0 0 0] 8 #() 1728 nil 27 7234 7280 1 7296 1 7312 1 7312 51 170 192 34 6 11600 8 'definedPackageMethodText' 11872 8 'methodList' 12528 8 'categoryMethodText' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 385 1 482 629 795 11488 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 192 0 0 0 0 0 0 0 250 1 0 0 141 1 0 0] 34 3 11872 11600 12528 1728 nil 27 11458 8 0 0 0 0 0 0 244 63 false 170 192 34 2 9504 8 'methodFilterTabs' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1989 1 482 1013 795 9392 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 226 3 0 0 0 0 0 0 220 5 0 0 141 1 0 0] 34 3 9504 410 ##(Smalltalk.Splitter) 34 12 nil 9392 34 2 8 1140850688 1 13280 nil 992 nil 517 nil nil nil 4866 13280 nil 1 #left nil nil nil 4896 4912 nil 4896 nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 375 1 482 11 795 13280 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 187 0 0 0 0 0 0 0 192 0 0 0 141 1 0 0] 8 #() 1728 nil 27 11488 1728 nil 27 1922 15 41 false 170 192 34 2 1952 8 'componentPackageContainer' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 1 482 3001 795 576 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 220 5 0 0 141 1 0 0] 34 6 688 1952 410 ##(Smalltalk.Splitter) 34 12 nil 576 34 2 8 1140850688 1 13744 nil 992 nil 517 nil nil nil 4866 13744 nil 1 #left nil nil nil 4896 4912 nil 4896 nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1393 1 482 11 795 13744 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 184 2 0 0 0 0 0 0 189 2 0 0 141 1 0 0] 8 #() 1728 nil 27 5104 410 ##(Smalltalk.Splitter) 34 12 nil 576 34 2 8 1140850688 1 13984 nil 992 nil 517 nil nil nil 4866 13984 nil 1 #left nil nil nil 4896 4912 nil 4896 nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1979 1 482 11 795 13984 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 221 3 0 0 0 0 0 0 226 3 0 0 141 1 0 0] 8 #() 1728 nil 27 9392 1728 nil 27 25 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 14224 nil nil nil 5 nil nil nil 14224 5170 170 176 34 4 410 ##(Smalltalk.CardContainer) 34 16 nil 14224 34 2 8 1409286144 131073 14336 nil 992 nil 5 nil nil nil 14336 2258 138 144 34 6 3666 5362 8 'SUnit' 1186 0 nil 1218 4 1 1184 8 'doIt' 8 '[Icon fromId: ''icons\UnitTestPlugin.ico'']' 8 #[32 105 45 30 178 106] 983558 ##(Smalltalk.VariableBinding) #Icon ##(Smalltalk.Icon) 8 'icons\UnitTestPlugin.ico' #fromId: 14496 7 1 nil nil 410 ##(Smalltalk.ReferenceView) 34 14 nil 14336 34 2 8 1140850688 131073 14624 nil 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 nil nil nil 14624 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteSUnitInClassPresenter) #resource_Default_view nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 9 53 482 2985 697 14624 1666 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 216 5 0 0 118 1 0 0] 784 1728 nil 27 3666 5362 8 'Class Definition' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 14336 34 2 8 1445007428 1025 14944 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 14690 26337781 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 11 984134 2 ##(Smalltalk.CommandMenuItem) 1 7442 #editSave 8 '&Save' 9383 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 15138 1 7442 #editUndo 8 '&Undo' 9397 1 nil nil nil 15138 1 7442 #editRedo 8 '&Redo' 9395 1 nil nil nil 15202 4097 15138 1 7442 #editCut 8 'Cu&t' 9393 1 nil nil nil 15138 1 7442 #editCopy 8 '&Copy' 9351 1 nil nil nil 15138 1 7442 #editPaste 8 '&Paste' 9389 1 nil nil nil 15138 1 7442 #editDelete 8 '&Delete' 1629 1 nil nil nil 15202 4097 15138 1 7442 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 7714 nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 14944 nil 8 1442592349 12610 nil nil 13 nil 170 192 34 4 #normal 1182790 1 ##(Smalltalk.ScintillaTextStyle) 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 15762 77 978 #gray 978 #white 1 nil nil nil nil #callTip nil nil nil nil 1639686 ##(Smalltalk.SmalltalkExpressionStyler) 1 nil nil false 138 144 784 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 14944 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 784 nil 170 176 784 9215 nil nil nil nil 7408 nil nil 65 nil nil 170 192 34 6 #literalArray 8 '()' #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 15776 nil nil nil nil 1 nil 170 192 34 6 1 1510470 3 ##(Smalltalk.ScintillaIndicatorStyle) 1 14944 14690 65025 3 false 1 nil nil nil nil nil nil 3 16178 3 14944 978 #blue 5 false 3 nil nil nil nil nil nil 5 16178 5 14944 978 #red 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 15762 1027 14690 60239 14690 31326207 1 nil nil nil nil #Warning nil nil nil #Error 15762 1031 14690 335 14690 31317503 1 nil nil nil nil #Error nil nil nil #Notification 15762 1029 nil 14690 31185883 1 nil nil nil nil #Notification nil nil nil nil 1474 138 144 34 9 1538 #createAt:extent: 34 2 482 9 53 482 2985 697 14944 1538 #contextMenu: 34 1 15104 14944 1538 #caretPeriod: 8 #(530) 14944 1538 #wordWrap: 8 #(true) 14944 1538 #margins: 34 1 34 3 985158 3 ##(Smalltalk.ScintillaMargin) 1 14944 1 3 nil nil 5 nil 16706 3 14944 33 nil 3 67108863 5 nil 16706 5 14944 1 nil 3 -67108863 5 nil 14944 1538 #tabWidth: 8 #(4) 14944 1538 #targetRange: 34 1 525062 ##(Smalltalk.Interval) 1 -1 3 14944 1538 #maxCompletionListHeight: 8 #(9) 14944 1538 #edgeColumn: 8 #(1) 14944 1666 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 216 5 0 0 118 1 0 0] 8 #() 1728 nil 29 3666 5362 8 'Class Documentation' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 14336 34 2 8 1445007428 1025 17024 15010 nil false 15056 nil 14690 26337781 nil 5 15090 nil true 34 1 15138 1 7442 #editSaveClassComment 8 'Save' 1025 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 7714 nil true 15634 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 17024 nil 8 1442592349 12610 nil nil 15 nil 170 192 34 4 #normal 15762 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 15762 77 15808 15824 1 nil nil nil nil #callTip nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 15922 1 nil nil nil 17024 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 784 nil 170 176 784 9215 nil nil nil nil 7408 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 17344 nil nil nil nil 1 nil 170 192 34 6 1 16178 1 17024 14690 65025 3 false 1 nil nil nil nil nil nil 3 16178 3 17024 16240 5 false 3 nil nil nil nil nil nil 5 16178 5 17024 16272 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 15762 1027 14690 60239 14690 31326207 1 nil nil nil nil #Warning nil nil nil #Error 15762 1031 14690 335 14690 31317503 1 nil nil nil nil #Error nil nil nil #Notification 15762 1029 nil 14690 31185883 1 nil nil nil nil #Notification nil nil nil nil 1474 138 144 34 10 1538 #createAt:extent: 34 2 482 9 53 482 2985 697 17024 1538 #contextMenu: 34 1 17120 17024 1538 #hoverTime: 8 #(1000000) 17024 1538 #caretPeriod: 8 #(530) 17024 1538 #wordWrap: 8 #(true) 17024 1538 #margins: 34 1 34 3 16706 1 17024 1 3 nil nil 5 nil 16706 3 17024 33 nil 3 67108863 5 nil 16706 5 17024 1 nil 3 -67108863 5 nil 17024 1538 #tabWidth: 8 #(4) 17024 1538 #targetRange: 34 1 16834 1 -1 3 17024 1538 #maxCompletionListHeight: 8 #(9) 17024 1538 #edgeColumn: 8 #(1) 17024 1666 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 216 5 0 0 118 1 0 0] 8 #() 1728 nil 29 3666 5362 8 'Method Source' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 14336 34 2 8 1445007428 1025 18400 15010 nil false 15056 nil 14690 26337781 nil 5 nil 7714 nil true 15634 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 18400 nil 8 1442592349 12610 nil nil 13 nil 170 192 34 4 #normal 15762 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 15762 77 15808 15824 1 nil nil nil nil #callTip nil nil nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 784 170 192 34 2 #default 15922 1 nil nil nil 18400 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 784 nil 170 176 784 9215 nil nil nil nil 7408 nil nil 65 nil nil 170 192 34 6 #literalArray 8 '()' #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' 8 '' 3 170 192 34 2 #container 170 192 34 4 #normal 18624 #callTip 18640 nil nil nil nil 1 nil 170 192 34 12 1 16178 1 18400 14690 65025 3 false 1 nil nil nil nil nil nil 8 'indicator10' 16178 21 18400 16272 3 nil nil nil nil nil nil nil nil 3 16178 3 18400 16240 5 false 3 nil nil nil nil nil nil 8 'indicator8' 16178 17 18400 7408 1 nil nil nil nil nil nil nil nil 8 'indicator9' 16178 19 18400 16272 13 nil nil nil nil nil nil nil nil 5 16178 5 18400 16272 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 15762 1027 14690 60239 14690 31326207 1 nil nil nil nil #Warning nil nil nil #Error 15762 1031 14690 335 14690 31317503 1 nil nil nil nil #Error nil nil nil #Notification 15762 1029 nil 14690 31185883 1 nil nil nil nil #Notification nil nil nil nil 1474 138 144 34 9 1538 #createAt:extent: 34 2 482 9 53 482 2985 697 18400 1538 #hoverTime: 8 #(500) 18400 1538 #caretPeriod: 8 #(530) 18400 1538 #wordWrap: 8 #(true) 18400 1538 #margins: 34 1 34 3 16706 1 18400 61 3 nil nil 5 nil 16706 3 18400 1 nil 3 67108863 nil nil 16706 5 18400 1 nil 3 -67108863 nil nil 18400 1538 #tabWidth: 8 #(4) 18400 1538 #targetRange: 34 1 16834 1 -1 3 18400 1538 #maxCompletionListHeight: 8 #(9) 18400 1538 #edgeColumn: 8 #(1) 18400 1666 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 216 5 0 0 118 1 0 0] 8 #() 1728 nil 29 3666 5362 8 'Comparison' nil nil 410 ##(Smalltalk.ShellView) 34 27 nil 14336 34 2 8 1078919168 131073 19840 nil 992 nil 517 nil nil nil 19840 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 19840 34 2 8 1140850688 131073 19936 nil 14690 26337781 nil 5 15090 nil true 34 5 15138 1 7442 #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 15138 1 7442 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 15138 1 7442 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 15138 1 7442 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 15138 1 7442 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 19936 514 170 176 784 false 170 192 784 nil 1474 138 144 34 2 1538 #createAt:extent: 34 2 482 1 1 482 2193 565 19936 1538 #contextMenu: 34 1 20016 19936 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 4 0 0 26 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 19936 34 2 8 1140850688 131073 20544 nil 992 nil 5 nil nil nil 20544 19906 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 20544 34 2 8 1140850945 262145 20624 nil nil nil 21 nil nil nil 20624 nil 8 1737263776 12610 nil nil nil 1474 138 144 34 2 1538 #createAt:extent: 34 2 482 1 525 482 1091 41 20624 1538 #text: 34 1 8 '
' 20624 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 6 1 0 0 33 2 0 0 26 1 0 0] 8 #() 1728 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 20544 34 2 8 1140920580 1025 20928 15010 nil false 15056 nil 14690 26337781 nil 21 nil nil nil 20928 nil 8 1442592349 12610 nil nil 13 nil 170 192 34 12 #callTip 15762 77 15808 15824 1 nil nil nil nil #callTip nil nil nil #indentGuide 15762 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 15762 3 978 #teal nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 15762 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #normal 15762 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 15762 5 nil 14690 16908287 3 nil nil nil nil #diff nil 1401 nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 15922 1 nil nil nil 20928 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 784 nil 170 176 784 9215 nil nil nil nil 7408 nil nil 65 nil nil 170 192 34 6 #literalArray 8 '()' #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' 8 '' 3 170 192 34 2 #container 21056 nil nil nil nil 1 nil 170 192 34 2 #diff 16178 1 20928 978 #yellow 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 15762 1027 14690 60239 14690 31326207 1 nil nil nil nil #Warning nil nil nil #Error 15762 1031 14690 335 14690 31317503 1 nil nil nil nil #Error nil nil nil #Notification 15762 1029 nil 14690 31185883 1 nil nil nil nil #Notification nil nil nil nil 1474 138 144 34 8 1538 #createAt:extent: 34 2 482 1 1 482 1091 525 20928 1538 #caretPeriod: 8 #(530) 20928 1538 #wordWrap: 8 #(true) 20928 1538 #margins: 34 1 34 3 16706 1 20928 49 3 nil nil nil nil 16706 3 20928 1 nil nil 67108863 nil nil 16706 5 20928 1 nil nil nil nil nil 20928 1538 #canHScroll: 8 #(false) 20928 1538 #targetRange: 34 1 16834 1 -1 3 20928 1538 #maxCompletionListHeight: 8 #(9) 20928 1538 #edgeColumn: 8 #(1) 20928 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 6 1 0 0] 8 #() 1728 nil 29 170 192 34 4 20928 8 'before' 20624 8 'beforeTitle' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 1 482 1091 565 20544 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 26 1 0 0] 34 2 20928 20624 1728 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 19936 34 2 8 1140850688 1 22384 nil 14690 66047 nil 517 nil nil nil 4866 22384 nil 1 #left nil nil nil 4896 4912 nil 4896 nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1091 1 482 11 565 22384 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 33 2 0 0 0 0 0 0 38 2 0 0 26 1 0 0] 8 #() 1728 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 19936 34 2 8 1140850688 131073 22640 nil 992 nil 5 nil nil nil 22640 19906 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 22640 34 2 8 1140850945 262145 22720 nil nil nil 21 nil nil nil 22720 nil 8 1737263776 12610 nil nil nil 1474 138 144 34 2 1538 #createAt:extent: 34 2 482 1 525 482 1093 41 22720 1538 #text: 34 1 8 '
' 22720 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 6 1 0 0 34 2 0 0 26 1 0 0] 8 #() 1728 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 22640 34 2 8 1140920580 1025 23024 15010 nil false 15056 nil 14690 26337781 nil 21 nil nil nil 23024 nil 8 1442592349 12610 nil nil 13 nil 170 192 34 12 #callTip 15762 77 15808 15824 1 nil nil nil nil #callTip nil nil nil #indentGuide 15762 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 15762 3 21136 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 15762 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #normal 15762 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 15762 5 nil 14690 16908287 3 nil nil nil nil #diff nil 1401 nil nil 21218 21248 170 192 34 2 #default 15922 1 nil nil nil 23024 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 784 nil 170 176 784 9215 nil nil nil nil 7408 nil nil 65 nil nil 21344 21424 3 170 192 34 2 #container 23152 nil nil nil nil 1 nil 170 192 34 2 #diff 16178 1 23024 21520 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 15762 1027 14690 60239 14690 31326207 1 nil nil nil nil #Warning nil nil nil #Error 15762 1031 14690 335 14690 31317503 1 nil nil nil nil #Error nil nil nil #Notification 15762 1029 nil 14690 31185883 1 nil nil nil nil #Notification nil nil nil nil 1474 138 144 34 8 1538 #createAt:extent: 34 2 482 1 1 482 1093 525 23024 1538 #caretPeriod: 8 #(530) 23024 1538 #wordWrap: 8 #(true) 23024 1538 #margins: 34 1 34 3 16706 1 23024 49 3 nil nil nil nil 16706 3 23024 1 nil nil 67108863 nil nil 16706 5 23024 1 nil nil nil nil nil 23024 1538 #canHScroll: 8 #(false) 23024 1538 #targetRange: 34 1 16834 1 -1 3 23024 1538 #maxCompletionListHeight: 8 #(9) 23024 1538 #edgeColumn: 8 #(1) 23024 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 34 2 0 0 6 1 0 0] 8 #() 1728 nil 29 170 192 34 4 22720 8 'afterTitle' 23024 8 'after' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1101 1 482 1093 565 22640 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 38 2 0 0 0 0 0 0 72 4 0 0 26 1 0 0] 34 2 23024 22720 1728 nil 27 1728 nil 27 170 192 34 2 19936 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 15090 nil true 34 4 15138 1 7442 #selectUpper 8 'Select &upper' 1 1 nil nil nil 15138 1 7442 #selectLower 8 'Select &lower' 1 1 nil nil nil 15202 4097 15138 1 7442 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 29201 nil nil 15090 nil true 34 3 15138 1 7442 #character 8 '&Character' 1 1 nil nil nil 15138 1 7442 #word 8 '&Word' 1 1 nil nil nil 15138 1 7442 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 29203 nil nil 15090 nil true 34 1 15138 1 7442 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 29205 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1474 138 144 34 2 1538 #createAt:extent: 34 2 482 9 53 482 2985 697 19840 1538 #text: 34 1 8 'Comparison' 19840 1666 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 216 5 0 0 118 1 0 0] 34 1 19936 1728 nil 27 3666 5362 8 'Spec' nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 14336 34 2 8 1409286144 131073 25184 nil nil nil 5 nil nil nil 25184 514 138 ##(Smalltalk.Dictionary) 34 1 3666 410 ##(Smalltalk.Splitter) 34 12 nil 25184 34 2 8 1140850688 1 25312 nil nil nil 517 nil nil nil 4866 25312 nil 1 #left nil nil nil 4896 4912 nil 4896 nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 85 482 731 11 25312 1666 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 42 0 0 0 109 1 0 0 47 0 0 0] 8 #() 1728 nil 27 1 true 170 192 34 2 410 ##(Smalltalk.ListTreeView) 34 59 nil 25184 34 2 8 1140953421 1 25584 898 138 144 784 nil 960 14690 26337781 nil 13 15090 nil true 34 12 15138 1 7442 #inspectIt 8 '&Inspect' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'BasicInspector.ico' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil nil nil 15138 1 7442 #inspectReferences 8 'Inspect &References' 1 1 nil nil nil 15202 4097 15138 1 7442 #browseIt 8 '&Browse It' 1 1 25778 nil true 25824 8 'ClassBrowserShell.ico' 25872 nil nil 15202 4097 15138 1 7442 #copyAspect 8 '&Copy' 1 1 nil nil nil 15138 1 7442 #pasteAspect 8 '&Paste <1d>' 1 1 nil nil nil 15202 4097 15138 1 7442 #editAspect 8 '&Edit' 1 1 nil nil nil 15138 1 7442 #nilAspect 8 'Set to &Nil' 1 1 nil nil nil 15202 4097 15138 1 7442 #refresh 8 'Re&fresh' 1 1 nil nil nil 8 '&Workspace' nil 134217729 nil nil nil nil nil nil nil 25584 nil 8 1737156720 1026 #valueText 8 #() nil 1088 nil nil nil nil nil nil 138 144 34 3 1138 8 'Property' 1473 #left 1026 #valueNameOnly 8 #() 1026 #<= 8 #() nil nil 25584 nil 3 1026 #valueNameInfo 8 #() nil 1138 8 'Value' 1473 #left 1026 #valueTextOnly 8 #() 1026 #<= 26512 nil nil 25584 1026 #valueImage 8 #() 3 nil nil 1138 8 '' 33 #center nil 1026 #<= 8 #() nil nil 25584 1186 0 nil 1218 3 1 1184 8 'doIt' 8 '[:x | PropertyInspector editButtonImageIndexFor: x ]' 8 #[31 105 29 17 177 106] ##(Smalltalk.PropertyInspector) #editButtonImageIndexFor: 26736 7 257 nil 1 nil nil #report 1456 nil 131431 482 129 129 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil false 1050438 3 ##(Smalltalk.VirtualTreeModel) nil 960 138 144 784 nil nil 1186 0 nil 2450 2 3 26832 #defaultHasChildrenBlock 508791331 8 #[252 1 0 0 1 4 0 65 176 159 106 105] #childrenOf: #notEmpty 17 257 26848 1186 0 nil 2450 1 83886083 26832 #defaultFilterBlock 508773827 8 #[29 105 17 157 106] 26928 7 257 nil nil 138 ##(Smalltalk.PluggableSet) 784 138 ##(Smalltalk.IdentitySet) 784 13 1 nil nil nil nil nil nil nil 1474 138 144 34 3 1538 #createAt:extent: 34 2 482 1 1 482 2985 697 25584 1538 #contextMenu: 34 1 25696 25584 1538 #text: 34 1 8 'Property' 25584 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 212 5 0 0 92 1 0 0] 8 #() 1728 nil 2029 8 'aspects' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 9 53 482 2985 697 25184 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 216 5 0 0 118 1 0 0] 34 2 25312 25584 1728 nil 27 25184 nil nil nil 170 192 34 10 17024 8 'classDocumentation' 19840 8 'comparisonTab' 14944 8 'classDefinition' 18400 8 'methodSource' 14624 8 'sunit' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 14336 34 2 8 1140916736 1 27536 898 138 144 34 6 14912 16992 18368 14464 19808 25152 nil 960 nil nil 1 nil nil nil 27536 nil 8 1737494000 1186 0 nil 2450 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 27664 7 257 nil 1186 0 nil 2450 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 27712 7 257 nil 1088 nil nil nil nil nil #smallIcons nil nil nil nil nil 1474 138 144 34 3 1538 #createAt:extent: 34 2 482 1 1 482 3001 757 27536 1538 #setSingleSelection: 8 #(6) 27536 1538 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 27536 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 220 5 0 0 122 1 0 0] 8 #() 1728 nil 27 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 1 482 3001 757 14336 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 220 5 0 0 122 1 0 0] 34 7 14944 17024 18400 14624 19840 25184 27536 1728 nil 27 7234 7280 1 7296 1 7312 1 7328 -39 410 ##(Smalltalk.ContainerView) 34 15 nil 14224 34 2 8 1140850688 131073 28160 nil nil 482 2241 43 517 nil nil nil 28160 5170 170 176 34 4 410 ##(Smalltalk.ToolButton) 34 14 nil 28160 34 2 8 1140850688 131073 28288 nil nil nil 1029 nil nil nil 28288 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 28288 34 2 8 1140853580 131137 28352 nil nil 482 43 43 513 nil nil nil 28352 nil 8 1737207072 nil 170 192 34 2 29049 1115206 1 ##(Smalltalk.ToolbarIconButton) 28352 1 7442 #flipAutoCommit 8 'Auto Commit' 1 1 25778 nil true 25824 8 'icons/camera16_light_icon.ico' nil 29049 34 1 28496 nil nil 3 nil 482 33 33 482 33 33 nil nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 1 482 43 43 28352 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 8 #() 1728 nil 27 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 1 482 43 43 28288 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 34 1 28352 1728 nil 27 7234 7280 1 7266 #fixedViewLeft 43 7312 1 9120 43 410 ##(Smalltalk.TextEdit) 34 16 nil 28160 34 2 8 1140850688 1 28976 nil 992 482 2199 43 517 nil 7714 nil true 15634 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 482 193 193 nil 28976 978 #black 8 1737104896 12610 nil nil 67 1474 138 144 34 2 1538 #createAt:extent: 34 2 482 43 1 482 2959 41 28976 1538 #setMarginWidths: 34 1 8 #(3 3) 28976 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 21 0 0 0 0 0 0 0 220 5 0 0 20 0 0 0] 8 #() 1728 nil 27 7234 7280 43 7296 1 7312 1 7328 1 170 192 34 4 28288 8 'autoCommitButton' 28976 8 'statusBarField' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 757 482 3001 41 28160 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 122 1 0 0 220 5 0 0 142 1 0 0] 34 2 28288 28976 1728 nil 27 7234 7280 1 7296 1 7328 -39 7328 1 170 192 34 2 14336 8 'textAreaTabs' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 805 482 3001 797 14224 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 146 1 0 0 220 5 0 0 32 3 0 0] 34 2 14336 28160 1728 nil 27 25 true 170 192 34 2 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 29872 nil 992 nil 517 nil nil nil 4866 29872 nil 1 #left nil nil nil 4896 4912 nil 4896 nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 795 482 3001 11 29872 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 141 1 0 0 220 5 0 0 146 1 0 0] 8 #() 1728 nil 27 8 'splitter' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 7545 21 482 3001 1601 416 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 188 14 0 0 10 0 0 0 152 20 0 0 42 3 0 0] 34 3 576 29872 14224 1728 nil 27 )! !
!JadeiteBrowserPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

