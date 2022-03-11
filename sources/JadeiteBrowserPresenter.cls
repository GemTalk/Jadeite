"Filed out from Dolphin Smallalk"!

JadeiteProjectsBrowserPresenter subclass: #JadeiteBrowserPresenter
	instanceVariableNames: 'dictionaryPresenter packageDictionaryCards globalsTab autoCommitButton search previousTabViewArrangement previousTopViewArrangement componentListPresenter componentPackageContainer packageDictionaryContainer'
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

basicCopyClass: oldClassService to: newClassName
	oldClassService
		command: #copyClassTo:;
		commandArgs: (Array with: newClassName).
	self issueCommand: oldClassService.
	self updateAfterFindClass: (RowanClassService new name: newClassName)!

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
	service := self selectedDictionaryOrPackage.
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

buildInfoTab: infoTab
	| infoTabView |
	infoTab parentPresenter: self textAreaTabs.
	infoTabView := infoTab createView: 'Editable list view'.
	infoTabView backcolor: JadeiteTextStyles default colorForNoEdits.
	infoTabView
		hasColumnHeaders: false;
		hasGridLines: false;
		isMultiSelect: true.
	(infoTabView allColumns at: 1)
		isEditable: false;
		width: 175;
		getContentsBlock: [:each | each at: 2].
	infoTabView addColumn.
	(infoTabView allColumns at: 2)
		isEditable: false;
		isAutoResize: true;
		getContentsBlock: [:each | (each at: 2) ifNil: [String new] ifNotNil: [:iv | (each at: 1) instVarNamed: iv]].
	^infoTabView!

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
			projectInfoView := self buildInfoTab: projectInfoTab]
		ifNotNil: [projectInfoView := projectInfoTab view].
	projectInfoView contextMenu: self projectInfoMenu.
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

contextObject
	^self selectedClass ifNil: [^gciSession oopNil value] ifNotNil: [:classService | classService oop]!

copyInfo
	self copyProjectInfo
	!

copyProjectInfo
	projectInfoTab selectionIfNone: 
			[MessageBox notify: 'No selection to copy'.
			^self].
	projectInfoTab selection last ifNil: [^self].
	(projectInfoTab selection first perform: projectInfoTab selection last asSymbol) displayString
		copyToClipboard!

createComponents
	super createComponents.
	dictionaryPresenter := self add: ListPresenter new name: 'dictionariesList'.
	packageDictionaryCards := self add: Presenter new name: 'packageDictionaryCards'.
	autoCommitButton := self add: Presenter new name: 'autoCommitButton'.
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
	| projectName | self halt. 
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
		send: #updatePackageGroupPackages
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

createSchematicWiringForProjectList

	projectListPresenter 
		when: #'drag:'				send: #'onDragPackageList:'		to: self;
		when: #'dragCut:'			send: #'onDragCutPackageList:'		to: self;
		when: #'dragOver:'			send: #'onDragOverPackageList:'	to: self;
		when: #'drop:'				send: #'onDropOnPackageList:'		to: self;
		when: #'keyTyped:'			send: #'delayUpdate'				to: self;
		when: #'selectionChanging:'	send: #'aboutToChange:'			to: self;
		when: #'selectionChanging:'	send: #'releasedReferencedServices:'	to: self;
		when: #'selectionChanged' 		send: #'ensureVisible'				to: projectListPresenter;
		when: #'selectionChanged'		send: #'updateProject' 			to: self
!

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

editComponents
	| projectName |
	projectName := self projectListPresenter selectionOrNil
				ifNil: [^self]
				ifNotNil: [:projectService | projectService name].
	^JadeiteComponentEditor showOn: projectName session: self gciSession!

editDelete

	View focus clearSelection.
	self methodValueChanged.
!

editPackageGroups
	| projectName |
	projectName := self projectListPresenter selectionOrNil
				ifNil: [^self]
				ifNotNil: [:projectService | projectService name].
	^JadeitePackageGroupEditor showOn: projectName session: self gciSession!

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
	self issueCommand: browserService]
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
			[classHierarchyPresenter model removeChildrenOf: classService.
			classService command: #fullHierarchy.
			self issueCommand: classService.
			self selectClassNamed: classService name.
			classHierarchyPresenter view expandAll: classService ]!

expandFullHierarchy
	self expandFullAt: self selectedClass!

findClass
	| find |
	self isOkayToChange ifFalse:[^self]. 
	find := JadeiteFindClassDialog showModal: 'DefaultView' on: self allClasses.
	find ifNotNil: [self updateAfterFindClass: find]!

findRemovedServices
	| browserService |
	browserService := RowanBrowserService new
				command: #findRemovedServices:;
				commandArgs: (Array with: BrowserUpdate current activeServices asArray).
	BrowserUpdate current issueCommands: (Array with: browserService) session: self gciSession!

gitCommit
	| projectName message service promptResult |
	projectListPresenter selections size > 1
		ifTrue: [MessageBox notify: 'Only one project may be committed'].
	projectName := projectListPresenter selection name.
	message := String new asValue.
	promptResult := JadeiteMultilinePrompter
				on: message
				prompt: 'Enter Git commit message. (Note - This will NOT do a GemStone commit)'
				caption: 'Committing Project ' , projectName.
	promptResult isNil ifTrue: [^self].
	message value isEmpty
		ifTrue: [^MessageBox notify: 'Commit message must not be empty. Commit to local repository NOT done.'].
	service := projectListPresenter selection.
	service
		command: #commitWithMessage:;
		commandArgs: (Array with: message value asString).
	self issueCommand: service.
	MessageBox notify: 'Project ' , projectName , ' committed to local repository!!'.
	self refreshFromServer!

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

gotoClassDefinedPackage
	" find will go to the class in it's defined package project"

	| selectedCategory selectedMethod |
	selectedCategory := categoryListPresenter selectionIfNone: [].
	selectedMethod := methodListPresenter selectionIfNone: [].
	self updateAfterFindClass: self selectedClass.
	selectedCategory ifNotNil: [:category | categoryListPresenter selection: category].
	selectedMethod
		ifNotNil: 
			[methodListPresenter selection: (methodListPresenter list
						detect: [:methodService | methodService selector = selectedMethod selector]).	"It better be there"
			self updateMenuBar	"to refresh method menu"]!

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

hasCategorySelected

	^categoryListPresenter selections notEmpty!

hasExactlyOneCategorySelected

	^categoryListPresenter selections size = 1!

hasMethods
	^true!

hierarchyClassDoubleClicked
	self expandFullHierarchy!

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

isClassDefinitionTabSelected
	^textAreaTabs currentCard name = 'classDefinition'!

isClassSelected
	^self selectedClass notNil!

isComparisonTabSelected
	^textAreaTabs currentCard name = 'comparisonTab'!

isDictionariesTabSelected

	^projectDictionaryTabs currentCard name = 'dictionaryList'.
!

isHierarchyTabSelected
	^classHierarchyTabs currentCard name = 'classHierarchy'!

isLoadSpecTabSelected
	^textAreaTabs currentCard name = 'loadSpecTab'.
!

isMethodSourceTabSelected
	^textAreaTabs currentCard name = 'methodSource'!

isNoneProjectSelected
	self projectListPresenter selectionIfNone: [^false].
	^self projectListPresenter selection name = RowanService notRowanizedPackageName!

isOkayToChange
	methodSourcePresenter view isModified
		ifTrue: [(self isOkayToChangeSource: methodSourcePresenter) ifFalse: [^false]].
	classDefinitionPresenter view isModified
		ifTrue: 
			[classDefinitionPresenter ensureVisible.
			gciSession isValidSession
				ifTrue: [(JadePresenter unsavedChangesValidSessionDialogIn: self) ifTrue: [^false]]
				ifFalse: 
					[(JadePresenter unsavedChangesInvalidSessionDialogIn: self)
						ifTrue: 
							[classDefinitionPresenter
								selectAll;
								copySelection]].
			classDefinitionPresenter view isModified: false].
	classCommentPresenter view isModified
		ifTrue: 
			[classCommentPresenter ensureVisible.
			gciSession isValidSession
				ifTrue: 
					[(JadePresenter unsavedChangesValidSessionDialogIn: self
						text: 'Stay on window with unsaved changes? Class comment has unsaved changes.') ifTrue: [^false]]
				ifFalse: 
					[(JadePresenter unsavedChangesInvalidSessionDialogIn: self
						text: 'Copy changes to Clipboard? Class comment has unsaved changes')
							ifTrue: 
								[classCommentPresenter
									selectAll;
									copySelection]].
			classCommentPresenter view isModified: false].
	self postOkToChangeEvent.
	^true!

isProjectInfoTabSelected

	^textAreaTabs currentCard name = 'projectInfoTab'.
!

isProjectItemEnabled: command
	(command = #refreshFromServer or: [command = #loadV2Project]) ifTrue: [^true].
	^projectListPresenter selections notEmpty
		and: [(projectListPresenter selections includes: RowanProjectService noneProject) not]!

isRowanProjectSelected
	^(self isNoneProjectSelected or: [projectListPresenter selections isEmpty]) not!

isSourceTabSelected

	^textAreaTabs currentCard name = 'methodSource'.
!

isSunitTabSelected
	^self textAreaTabs currentCard name = 'sunit'!

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
	^#('&Methods' 'Browse &Implementors//browseImplementors' 'Browse Implementors of ...//browseImplementorsOf' 'Browse &Senders//browseSenders' 'Browse Senders of ...//browseSendersOf' '-' 'Browse Hierarchy Implementors//browseHierarchyImplementors' 'Browse Hierarchy Senders//browseHierarchySenders' '-' 'Browse Methods &Containing ...//browseMethodsContaining' 'Browse Literal References ...//browseLiteralReferences' 'Browse Selected Methods//browseSelectedMethods' 'Browse Method History//browseMethodHistory' 'Inspect//inspectMethod' '-' 'Browse Breakpoints//browseBreakpoints' 'Clear Method Breakpoints//clearMethodBreakpoints' '-' 'Find Method .../Ctrl+Shift+M/findMethod' '-' '&Remove Method(s) ...//removeMethods' 
	'-'
	'Move To Package ...//moveMethodToPackage'
	'-'
	'Run All Tests/Ctrl+Shift+A/runAll' 'Run Selected Test(s)/Ctrl+Shift+S/runMethodTests' 'Debug Selected &Test(s)/Ctrl+B/runMethodTests' '-' 'Go To Defining Package//gotoMethodDefinedPackage')!

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

moveMethodsToPackageNamed: packageName
	| packageServiceToSelect selectedClass selectedMethods |
	methodListPresenter selections isEmpty ifTrue: [^self].
	selectedClass := self selectedClass.
	selectedMethods := methodListPresenter selections.
	self selectedClass
		command: #moveMethodSelectors:toPackageNamed:;
		commandArgs: (Array with: (selectedMethods collect: [:methodService | methodService selector])
					with: packageName).
	self issueCommand: self selectedClass.
	packageServiceToSelect := packageListPresenter list
				detect: [:packageService | packageService name = packageName].
	packageListPresenter selections: (self selectedPackageServices asOrderedCollection
				add: packageServiceToSelect;
				yourself).
	self selectClassNamed: selectedClass name.
	methodListPresenter selections: selectedMethods.
	self view invalidate!

moveMethodToPackage
	| packageService |
	packageService := JadeitePackageDialog showModal: 'DefaultView'
				on: (self class allPackagesIn: self gciSession).
	packageService ifNil: [^self].
	self moveMethodsToPackageNamed: packageService name!

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
	(aSession isFormatAvailable: #package) ifTrue: [^self].
	(aSession isFormatAvailable: #class) ifTrue: [^self onDragClassOrMethodOverPackageList: aSession].
	(aSession isFormatAvailable: #method) ifTrue: [^self onDragClassOrMethodOverPackageList: aSession].
	MessageBox notify: 'Sorry, we are not yet prepared to handle ' , aSession printString , '!!'.
	SessionManager current pause!

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

onDropMethodsOnPackageList: aSession
	self onDropMethodsOnPackageList: aSession suggestedTarget session: aSession!

onDropMethodsOnPackageList: packageService session: aSession
	| methods |
	methods := aSession dragObjects collect: [:each | each format: #method].
	methods isEmpty ifFalse: [^self moveMethodsToPackageNamed: packageService name].
	MessageBox notify: 'Sorry, we are not yet prepared to handle ' , aSession printString , '!!'.
	SessionManager current pause!

onDropOnPackageList: aSession
	(aSession isFormatAvailable: #class) ifTrue: [^self onDropClassesOnPackageList: aSession].
	(aSession isFormatAvailable: #method) ifTrue: [^self onDropMethodsOnPackageList: aSession].
	MessageBox notify: 'Sorry, we are not yet prepared to handle ' , aSession printString , '!!'.
	SessionManager current pause!

onViewClosed
	super onViewClosed.
	BrowserUpdate current removeEventsTriggeredFor: componentListPresenter!

onViewOpened
	| inspectorService specModel |
	super onViewOpened.
	self showPackageList.
	self rowanFixMe.  "Have code to show spec service that needs to be finished -- maybe?"
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

projectChanges
	projectListPresenter selections isEmpty ifTrue: [^MessageBox notify: 'No project selected'].
	^projectListPresenter selection changesUsing: self gciSession!

projectInfoMenu
	^Menu fromStrings: self projectInfoMenuStrings!

projectInfoMenuStrings
	self rowanFixMe.	"this really is a cumbersome way to build a menu."
	0 == 1
		ifTrue: 
			[self
				copyInfo
				].
	^#('Dictionaries' 
	'Copy//copyInfo'
	'Browse Commit In GitHub//openCommitInGitHub')!

projectInfoTab
	^projectInfoTab!

projectLog
	projectListPresenter selection projectLogUsing: self session: gciSession
!

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
	^#('Projects' 'Create ...//createNewProject' 'Load Git Project ...//loadV2Project' 'Reload Project //reloadV2Project' 'Unload//unloadProjects' '-' 'Pull from Git//pullFromGit' 'Commit to Git ...//gitCommit' 'Push to Git//pushToGit' '-' '&Changes//projectChanges' 'Write//writeProject' 'Checkout Git Tag ...//checkoutTag' 'Checkout Git Branch ...//checkout' '-' '&Add Package...//addPackage'  'Edit Components//editComponents' '-'  'Audit//auditProject' 'Git Log//projectLog' '&Refresh//refreshFromServer')!

projectTabLabel
	"Selections get mixed up switching between system presenters unless the tabs
	have a unique label. Rather silly, but we'll give the tab a unique number"

	| cardNumber labelString numberedLabelString label |
	labelString := self basicProjectTabLabel.
	cardNumber := self parentPresenter view cards indexOf: self view.
	numberedLabelString := cardNumber printString , ' ' , labelString.
	label := CardLabel text: numberedLabelString iconBlock: nil. 
	methodSourcePresenter view isModified
		ifTrue: 
			[label := CardLabel text: numberedLabelString iconBlock: [Icon fromId: 'Changed.ico']].
	^label!

protectedDictionaries
	^#('Published' 'Globals' 'UserGlobals')!

pullFromGit
	| projectServices ws |
	projectServices := projectListPresenter selections.
	ws := WriteStream on: String new.
	projectServices do: 
			[:service |
			ws
				nextPutAll: service name;
				space].
	(MessageBox
		confirm: 'It is recommended that you commit changes before doing a pulling projects - ' , ws contents
				, ' -  from git. Really proceed?')
			ifFalse: [^self].
	projectServices do: [:service | service command: #pullFromGit].
	self issueCommands: projectServices!

pushToGit
	| projectService ws |
	projectService := projectListPresenter selection.
	ws := WriteStream on: String new.
	ws
		nextPutAll: projectService name;
		space.
	(MessageBox
		confirm: 'Push projects - ' , ws contents , '- from the local repository to the remote server?')
			ifFalse: [^self].
	projectService command: #pushToGit.
	self issueCommand: projectService.
	MessageBox notify: 'Project ' , projectService name , ' pushed to remote repository!!'!

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
	services := OrderedCollection new.
	services addAll: projectListPresenter selections.
	services addAll: packageListPresenter selections.
	classListPresenter selectionOrNil ifNotNil: [:classService | services add: classService].
	classHierarchyPresenter selectionOrNil ifNotNil: [:classService | services add: classService].
	services addAll: methodListPresenter selections.
	self updateServices: services.
	self updateSUnitTab.
	self updateProjects.	"don't like this double round trip, but also don't want RowanBrowserService to have to understand update on the server"
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
			selector: #packageGroupUpdate:browser:
			browser: self!

reloadV2Project
	"intention revealing selector"
	^self loadProjects!

removeAppropriateTab
	self isNoneProjectSelected ifTrue: [self removeProjectTab] ifFalse: [self removeGlobalsTab]!

removeClass
	| classService answeringService classReferenceBrowser queryService |
	classService := self selectedClass ifNil: [^self].
	answeringService := RowanAnsweringService new.
	answeringService
		command: #classHasSubclasses:;
		commandArgs: (Array with: classService oop).
	self issueCommand: answeringService.
	answeringService answer ifTrue: [^MessageBox notify: 'Cannot remove class with subclasses'].
	(self selectedDictionaryOrPackage confirmClassRemoval: classService) ifFalse: [^self].
	queryService := JadePresenter basicBrowseClassReferences: classService name session: self gciSession.
	queryService hasResults
		ifTrue: [classReferenceBrowser := self browseClassReferences: classService name].
	self basicRemoveClass: classService.
	queryService hasResults
		ifTrue: 
			[MessageBox notify: classService name
						, ' was removed. You will need to remove references to the class or your code may not load in the future.'].
	^classReferenceBrowser!

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

selectedDictionaryOrPackage
	^self isNoneProjectSelected
		ifTrue: [dictionaryPresenter selection]
		ifFalse: [packageListPresenter selection]!

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

selectedProjectName
	^(projectListPresenter selectionOrNil ifNil: [^nil]) name!

selectNoneProject
	projectListPresenter selection: (projectListPresenter list
				detect: [:projectService | projectService name = RowanProjectService noneProject name])!

selectPackageOrDictionaryFor: classService
	| answeringService service |
	answeringService := RowanAnsweringService new.
	answeringService
		command: #packageOrDictionaryFor:;
		commandArgs: (Array with: classService).
	self issueCommand: answeringService.
	service := answeringService answer.
	service selectIn: self!

selectPackageOrDictionaryNamed: thingName for: classService
	| answeringService service |
	answeringService := RowanAnsweringService new.
	answeringService
		command: #packageOrDictionaryNamed:;
		commandArgs: (Array with: thingName).
	self issueCommand: answeringService.
	service := answeringService answer.
	service selectIn: self!

selectProjectNamed: projectName
	| projectService |
	projectService := projectListPresenter list detect: [:service | service name = projectName]
				ifNone: [^self].
	projectListPresenter selections: (Array with: projectService).
	^projectService "return for testing"!

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
			classHierarchyPresenter model: JadeiteTreeModel new].
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
			classHierarchyPresenter model: JadeiteTreeModel new].
	packageListPresenter view isDropTarget: true. !

statusBarText
	
	^statusBarText !

statusBarText: string
	statusBarText value: string!

symbolExists: newClassName
	^(RowanAnsweringService new symbolExists: newClassName asSymbol session: self gciSession) not!

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

unloadProjects
	| projectNames ws |
	projectNames := projectListPresenter selections collect: [:projectService | projectService name].
	projectNames isEmpty ifTrue: [^self].
	ws := WriteStream on: String new.
	projectNames do: 
			[:projectName |
			ws
				space;
				nextPutAll: projectName].
	(MessageBox
		confirm: 'Really unload project(s) - ' , ws contents , '?  You will lose any unsaved changes!! '
		caption: 'UNLOAD PROJECTS WARNING!!') ifFalse: [^self].
	self basicUnloadProjects: projectNames!

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
					[self updateClass: classService.  "It's legal for the classService to not be filled in yet. That would break the hierarchy update" 
					self selectClassInClassListNamed: classService name.
					self updateHierarchy]]!

updateAfterFindClassInPackage: classService
	packageListPresenter list detect: [:service | service name = classService definedPackageName]
		ifNone: [self projectListPresenter selectionByIndex: 0	"display full list of packages"].
	self selectPackageOrDictionaryFor: classService.
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
	self issueCommand: browserService!

updateDictionary
	classListPresenter model: ListModel new.
	classHierarchyPresenter model: JadeiteTreeModel new.
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
	classHierarchyPresenter model: JadeiteTreeModel new.
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

updatePackageGroupPackages
	packageListPresenter clear.
	componentListPresenter selections isEmpty ifTrue: [^self].
	self updateServices: componentListPresenter selections.
	packageListPresenter selections: packageListPresenter list.
	self updateServices: packageListPresenter selections.
	self sundryCleanup!

updateProject
	self clearComponentList. 
	self projectListPresenter selectionIfNone: 
			[packageListPresenter clear.
			dictionaryPresenter clear.
			self possiblyClearProjectInfoTab.
			self updateTabLabel.
			^self].
	classHierarchyPresenter model: JadeiteTreeModel new.
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
	self updateProjectInfoTabFor: service!

updateProjectInfoTabFor: service
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
	^#('&Variables' '&Add Accessors//addVariableAccessors' '&Browse Inst Var Readers//browseInstVarReaders' '&Browse Inst Var Writers//browseInstVarWriters')!

writeProject
	| projectServices |
	projectServices := projectListPresenter selections.
	projectServices isEmpty ifTrue: [^MessageBox notify: 'No project selected'].
	^self basicWriteProject: projectServices! !
!JadeiteBrowserPresenter categoriesForMethods!
abortTransaction!public!transaction management! !
addDictionary!menu handlers!public! !
additionalAccelerators!constants!public! !
addNoneProject!public!updating! !
addSystemBrowser!menu handlers!public! !
allSelectedProjectsDirty!public!testing! !
auditProject!project menu handlers!public! !
basicAddDictionaryNamed:!menu handlers support!private! !
basicCopyClass:to:!menu handlers support!private! !
basicDictionaryTabLabel!displaying!private! !
basicProjectTabLabel!displaying!private!tabs! !
basicRemoveClass:!menu handlers support!private! !
basicRemoveDictionaries:!menu handlers support!private! !
basicRemoveGlobal:!menu handlers support!private! !
basicUnloadProjects:!menu handlers support!private! !
basicUpdateProject!private!updating! !
browseBreakpoints!public! !
browseClassReferences!menu handlers!public! !
browseGlobalClass!menu handlers!public! !
browseGlobalReferences!menu handlers!public! !
browseInstVarReaders!menu handlers!public! !
browseInstVarWriters!menu handlers!public! !
browseMethodHistory!menu handlers!public! !
browseSelectedCategoryMethods!menu handlers!public!queries! !
browseSelectedMethods!menu handlers!public!queries! !
buildGlobalsTab!private!tabs! !
buildInfoTab:!private!tabs! !
buildPreferencesMenu!menus!private!updating! !
buildProjectTabIfNecessary!private!tabs! !
categoriesMenuStrings!menus!public! !
checkout!menu handlers!public! !
checkoutTag!menu handlers!public! !
classCommentChanged!event handlers!public! !
classesMenuStrings!menus!public! !
clearComponentList!initialize/release!public! !
comparisonPresenter!accessing!public! !
componentListPresenter!accessing!private! !
contextObject!menu handlers support!private! !
copyInfo!menu handlers!public! !
copyProjectInfo!menu handlers!public! !
createComponents!initialize/release!public! !
createListViewFor:!private! !
createNewProject!menu handlers!menu handlers support!private! !
createSchematicWiring!create schemantic wiring!initialize/release!public! !
createSchematicWiringForClassHierarchy!create schemantic wiring!public! !
createSchematicWiringForClassList!create schemantic wiring!public! !
createSchematicWiringForMethodList!create schemantic wiring!public! !
createSchematicWiringForMethodSource!create schemantic wiring!initialize/release!public! !
createSchematicWiringForProjectList!create schemantic wiring!public! !
debug!menu handlers!public! !
dictionaryMenu!menus!public! !
dictionaryMenuStrings!menus!public! !
dictionaryPresenter!accessing!private! !
displayStringFor:in:!double dispatch!public! !
displayVariable:!displaying!private! !
editComponents!menu handlers!public! !
editDelete!menu handlers!public! !
editPackageGroups!menu handlers!public! !
editRevert!menu handlers!public! !
editSaveClass!menu handlers!public! !
editSaveMethod!menu handlers!public! !
editSaveMethod:!menu handlers support!private! !
expandFullAt:!menu handlers support!private!updating! !
expandFullHierarchy!menu handlers!public!updating! !
findClass!menu handlers!public! !
findRemovedServices!menu handlers support!private! !
gitCommit!project menu handlers!public! !
globalsMenu!menus!public! !
globalsMenuStrings!menus!public! !
globalsTab!accessing!private! !
gotoClassDefinedPackage!menu handlers!public! !
gotoDictionary!menu handlers!public! !
gotoDictionaryNamed:!menu handlers!public! !
hasCategorySelected!public!testing! !
hasExactlyOneCategorySelected!public!testing! !
hasMethods!public!testing! !
hierarchyClassDoubleClicked!menu handlers!public! !
insertCompileErrorText:into:!compile support!public! !
insertIfFalse!menu handlers!must not strip!public! !
insertIfTrue!menu handlers!must not strip!public! !
inspectGlobal!menu handlers!public! !
inspectMethod!menu handlers!public! !
inspectorContextObject!menu handlers support!private! !
isClassDefinitionTabSelected!public!testing! !
isClassSelected!public!testing! !
isComparisonTabSelected!public!testing! !
isDictionariesTabSelected!public!testing! !
isHierarchyTabSelected!public!testing! !
isLoadSpecTabSelected!public!testing! !
isMethodSourceTabSelected!public!testing! !
isNoneProjectSelected!event handlers!public!updating! !
isOkayToChange!event handlers!public!testing! !
isProjectInfoTabSelected!public!testing! !
isProjectItemEnabled:!menu handlers support!private! !
isRowanProjectSelected!public!testing! !
isSourceTabSelected!public!testing! !
isSunitTabSelected!public!testing! !
jadeInspect!menu handlers!public! !
loadProjects!menu handlers support!private! !
makeSameSelectionsIn:as:!menu handlers!menu handlers support!private! !
maxAutoCompleteListSize!constants!public! !
methodMenu:!menu handlers support!private! !
methodSelectionChanged!event handlers!public! !
methodsMenuStrings!menus!public! !
methodsUpdate:!public!updating! !
methodToReformat!menu handlers support!private! !
methodValueChanged!event handlers!public! !
moveClassToPackage!menu handlers!public! !
moveClassToPackageNamed:!menu handlers!public! !
moveMethodsToPackageNamed:!menu handlers!public! !
moveMethodToPackage!menu handlers!public! !
newProjectNamed:!menu handlers!menu handlers support!private! !
noClassSelectedInEitherPresenter!public!testing! !
onDragClass:!drag & drop!public! !
onDragMethod:!drag & drop!public! !
onDragOverPackageList:!drag & drop!public! !
onDropClassesOnPackage:session:!drag & drop!public! !
onDropClassesOnPackageList:!drag & drop!public! !
onDropMethodsOnPackageList:!drag & drop!public! !
onDropMethodsOnPackageList:session:!drag & drop!public! !
onDropOnPackageList:!drag & drop!public! !
onViewClosed!event handlers!public! !
onViewOpened!event handlers!public! !
openSourceStyler!menu handlers!public! !
packageDictionaryCards!accessing!private! !
possiblyClearProjectInfoTab!event handlers!public!updating! !
preferencesMenuStrings!menus!public! !
previousTabViewArrangement!accessing!private! !
previousTabViewArrangement:!accessing!private! !
previousTopViewArrangement!accessing!private! !
previousTopViewArrangement:!accessing!private! !
projectChanges!project menu handlers!public! !
projectInfoMenu!menus!public! !
projectInfoMenuStrings!menus!public! !
projectInfoTab!accessing!public! !
projectLog!project menu handlers!public! !
projectMenu!menus!public! !
projectMenuCommands!menus!public! !
projectMenuStrings!menus!public! !
projectTabLabel!displaying!private! !
protectedDictionaries!constants!menu handlers!public! !
pullFromGit!project menu handlers!public! !
pushToGit!project menu handlers!public! !
queryCommand:!menu handlers support!private! !
reformatSource!menu handlers!menu handlers support!private! !
refresh!event handlers!menu handlers!public!updating! !
refreshClass!event handlers!public!updating! !
refreshFromServer!event handlers!menu handlers!public!updating! !
refreshFromServerAfterAbort:!public! !
registerPresentersForUpdates!public!register presenters! !
reloadV2Project!menu handlers!public! !
removeAppropriateTab!private!tabs! !
removeClass!menu handlers!public! !
removeDictionaries!menu handlers!public! !
removeGlobal!menu handlers!public! !
removeGlobalsTab!private!tabs! !
removeProjectTab!private!tabs! !
resetClassTemplate!private! !
resetFontSize!menu handlers!public! !
runAll!menu handlers!public! !
runSelected!menu handlers!public! !
search!accessing!public! !
selectDictionaryNamed:!public!selection! !
selectedDictionaryNames!public!selection! !
selectedDictionaryOrPackage!private!selection! !
selectedGlobalName:!menu handlers support!private! !
selectedPackageNames!public!selection! !
selectedPackageServices!public!selection! !
selectedProjectName!public!selection! !
selectNoneProject!public!selection! !
selectPackageOrDictionaryFor:!public!selection! !
selectPackageOrDictionaryNamed:for:!public!selection! !
selectProjectNamed:!public!selection! !
setCompileErrorColor!compile support!public! !
setCompileWarningColor!compile support!public! !
setFontSize!menu handlers!public! !
setFontSizeTo:!menu handlers support!private! !
setStatusBarDefault!compile support!public! !
shouldShowNoneTabLabel!displaying!private!testing! !
showDictionaryList!event handlers!public!updating! !
showPackageList!event handlers!public!updating! !
statusBarText!accessing!public! !
statusBarText:!accessing!public! !
symbolExists:!public!testing! !
textTabChanged!event handlers!public! !
togglePackageDictionaryColumn!event handlers!public!updating! !
unloadProjects!project menu handlers!public! !
updateAfterFindClass:!menu handlers!public!updating! !
updateAfterFindClassInDictionary:!menu handlers!public!updating! !
updateAfterFindClassInPackage:!menu handlers!public!updating! !
updateAutoCommit!public!register presenters!updating! !
updateClass:!public!updating! !
updateClasses!event handlers!public!updating! !
updateDictionaries!public!updating! !
updateDictionary!public!updating! !
updateGlobalsTab!private!tabs! !
updateHierarchy!public!updating! !
updateHierarchyForPacktionaries!private!updating! !
updateMenuBar!menus!public!updating! !
updateMethodSourceColor!public!updating! !
updatePackageGroupPackages!event handlers!public!updating! !
updateProject!event handlers!public!updating! !
updateProjectInfo!private!tabs! !
updateProjectInfoTabFor:!private!tabs! !
updateSystemTab!event handlers support!private!updating! !
updateTabLabel!public!updating! !
variablesMenuStrings!menus!public! !
writeProject!project menu handlers!public! !
!

!JadeiteBrowserPresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil 328198 ##(Smalltalk.Point) 3001 1601 517 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 576 nil nil nil 5 nil nil nil 576 514 170 176 34 8 410 ##(Smalltalk.ContainerView) 34 15 nil 576 34 2 8 1140850688 131073 688 nil nil nil 5 nil nil nil 688 514 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 688 34 2 8 1140850688 131073 800 nil nil nil 5 nil nil nil 800 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.TextEdit) 34 16 nil 800 34 2 8 1140916352 1025 928 nil 327686 ##(Smalltalk.Color) #default nil 5 nil nil nil 928 nil 8 1591815600 852486 ##(Smalltalk.NullConverter) nil nil 3 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 482 1 1 482 629 51 928 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 58 1 0 0 25 0 0 0] 8 #() 482 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 1330 #fixedParentRight 1 1330 #fixedParentTop 1 1376 51 410 ##(Smalltalk.PushButton) 34 20 nil 800 34 2 8 1140858880 1 1392 nil 1008 nil 5 nil nil nil 1392 nil 8 1591823792 1180998 4 ##(Smalltalk.CommandDescription) #gotoMethodDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 1 745 482 629 51 1392 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 116 1 0 0 58 1 0 0 141 1 0 0] 8 #() 1280 nil 29 1298 1344 1 1360 1 1330 #fixedParentBottom -49 1680 1 410 ##(Smalltalk.ListView) 34 45 nil 800 34 2 8 1409372233 1025 1696 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 1008 nil 13 nil nil nil 1696 nil 8 1591759072 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 2 920646 5 ##(Smalltalk.ListViewColumn) 8 '' 41 #left 1138 #empty 8 #() 16 1874 #<= 8 #() nil nil 1696 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 2096 8 'doIt' 8 '[:each | each subSuperIcon]' 8 #[30 105 226 0 106] #subSuperIcon 2112 7 257 nil 1 nil nil 1986 8 'Selector' 581 #left 1874 #displayString 1904 ##(Smalltalk.SortedCollection) nil nil 1696 nil 3 nil 2098 0 nil 2130 5 1 2096 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 2256 7 257 nil #report 8 #() nil 133221 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 1 55 482 629 691 1696 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 27 0 0 0 58 1 0 0 116 1 0 0] 8 #() 1280 nil 35 1298 1344 1 1360 1 1376 55 1680 -49 170 192 34 6 928 8 'categoryMethodText' 1392 8 'definedPackageMethodText' 1696 8 'methodList' nil 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 385 1 482 629 795 800 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 192 0 0 0 0 0 0 0 250 1 0 0 141 1 0 0] 34 3 1696 1392 928 1280 nil 27 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 244 63 410 ##(Smalltalk.CardContainer) 34 16 nil 688 34 2 8 1409286144 131073 2800 nil 1008 nil 5 nil nil nil 2800 656710 1 ##(Smalltalk.CardLayout) 138 144 34 2 721414 ##(Smalltalk.Association) 8 'Category' 410 ##(Smalltalk.ListView) 34 45 nil 2800 34 2 8 1409372233 1025 2976 1762 138 144 1808 nil 1840 1008 nil 21 nil nil nil 2976 nil 8 1591759072 1874 #displayString 8 #() nil 1936 nil nil nil nil nil nil 138 144 34 1 1986 8 'Column 1' 351 #left 1874 #displayString 8 #() ##(Smalltalk.SortedCollection) 2098 0 nil 2130 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each]' 1779525917 3216 7 257 nil nil 2976 nil 3 nil nil #report 2336 nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1074 138 144 34 2 1138 #createAt:extent: 34 2 482 9 53 482 359 735 2976 1138 #text: 34 1 8 'Column 1' 2976 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 183 0 0 0 137 1 0 0] 8 #() 1280 nil 35 2930 8 'Variables' 410 ##(Smalltalk.ListView) 34 45 nil 2800 34 2 8 1409372233 1025 3520 1762 138 144 1808 nil 1840 1008 nil 21 nil nil nil 3520 nil 8 1591759072 1874 #displayString 8 #() nil 1936 nil nil 2098 0 nil 2130 4 1 2096 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 3664 7 257 nil nil nil nil 138 144 34 1 1986 8 'Column 1' 351 #left 1874 #displayString 3648 ##(Smalltalk.SortedCollection) nil nil 3520 nil 3 nil 2098 0 nil 2130 4 1 2096 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 3824 7 257 nil #report 2336 nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1074 138 144 34 2 1138 #createAt:extent: 34 2 482 9 53 482 359 735 3520 1138 #text: 34 1 8 'Column 1' 3520 1218 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 183 0 0 0 137 1 0 0] 8 #() 1280 nil 35 2976 nil nil nil 170 192 34 4 3520 8 'variableList' 2976 8 'categoryList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 2800 34 2 8 1140916736 1 4176 1762 138 144 34 2 2960 3504 nil 1840 nil nil 1 nil nil nil 4176 nil 8 1591529216 2098 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 4304 7 257 nil 2098 0 nil 4322 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 4368 7 257 nil 1936 nil nil nil nil nil #noIcons nil nil nil nil nil 1074 138 144 34 3 1138 #createAt:extent: 34 2 482 1 1 482 375 795 4176 1138 #setSingleSelection: 8 #(1) 4176 1138 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 4176 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 187 0 0 0 141 1 0 0] 8 #() 1280 nil 27 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 1 1 482 375 795 2800 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 187 0 0 0 141 1 0 0] 34 3 2976 3520 4176 1280 nil 27 2770 8 0 0 0 0 0 0 232 63 false 170 192 34 2 2800 8 'methodFilterTabs' nil 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 1989 1 482 1013 795 688 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 226 3 0 0 0 0 0 0 220 5 0 0 141 1 0 0] 34 3 2800 410 ##(Smalltalk.Splitter) 34 12 nil 688 34 2 8 1140850688 1 5024 nil 1008 nil 517 nil nil nil 1510470 1 ##(Smalltalk.DraggableViewInteractor) 5024 nil 1 #left nil nil nil 482 1 1 482 9 9 nil 5120 nil 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 375 1 482 11 795 5024 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 187 0 0 0 0 0 0 0 192 0 0 0 141 1 0 0] 8 #() 1280 nil 27 800 1280 nil 27 524806 ##(Smalltalk.Fraction) 15 41 410 ##(Smalltalk.ContainerView) 34 15 nil 576 34 2 8 1140850688 131073 5344 nil nil nil 5 nil nil nil 5344 514 170 176 1808 false 170 192 34 2 410 ##(Smalltalk.ListView) 34 45 nil 5344 34 2 8 1409405261 1025 5472 1762 138 144 1808 nil 1840 1008 nil 5 nil nil nil 5472 nil 8 1591759072 1874 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 1936 nil nil nil nil nil nil 138 144 34 1 1986 8 'Column 1' 425 #left 2098 0 nil 2130 2 1 2096 8 'doIt' 8 '[:each | each displayName]' 8 #[30 105 226 0 106] #displayName 5680 7 257 nil ##(Smalltalk.SortedCollection) nil nil 5472 nil 3 2098 0 nil 2130 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 5760 7 257 nil 2098 0 nil 2130 3 1 2096 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 5840 7 257 nil #report 2336 nil 133217 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1074 138 144 34 2 1138 #createAt:extent: 34 2 482 1 1 482 433 795 5472 1138 #text: 34 1 8 'Column 1' 5472 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 216 0 0 0 141 1 0 0] 8 #() 1280 nil 35 8 'projectList' nil 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 1 1 482 433 795 5344 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 216 0 0 0 141 1 0 0] 34 1 5472 1280 nil 27 5314 7 41 410 ##(Smalltalk.ContainerView) 34 15 nil 576 34 2 8 1140850688 131073 6320 nil nil nil 5 nil nil nil 6320 514 170 176 1808 false 170 192 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 6320 34 2 8 1140850688 131073 6448 nil nil nil 5 nil nil nil 6448 514 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 6448 34 2 8 1409286144 131073 6560 nil 1008 nil 21 nil nil nil 6560 2866 138 144 1808 nil nil nil nil 170 192 1808 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 6560 34 2 8 1140916736 1 6672 1762 138 144 1808 nil 1840 nil nil 17 nil nil nil 6672 nil 8 1591529216 2098 0 nil 4322 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 6784 7 257 nil 2098 0 nil 4322 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 6832 7 257 nil 1936 nil nil nil nil nil #noIcons nil nil nil nil nil 1074 138 144 34 2 1138 #createAt:extent: 34 2 482 1 1 482 477 795 6672 1138 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 6672 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 238 0 0 0 141 1 0 0] 8 #() 1280 nil 27 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 1 1 482 477 795 6560 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 238 0 0 0 141 1 0 0] 34 1 6672 1280 nil 27 3 false 170 192 34 2 6560 8 'packageDictionaryCards' nil 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 485 1 482 477 795 6448 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 242 0 0 0 0 0 0 0 224 1 0 0 141 1 0 0] 34 1 6560 1280 nil 27 8 'packageDictionaryContainer' nil 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 433 1 482 961 795 6320 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 216 0 0 0 0 0 0 0 184 2 0 0 141 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 6320 34 2 8 1140850688 131073 7616 nil nil nil 5 nil nil nil 7616 514 170 176 1808 false 170 192 1808 nil 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 1 1 482 475 795 7616 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 237 0 0 0 141 1 0 0] 34 1 410 ##(Smalltalk.CardContainer) 34 16 nil 7616 34 2 8 1409286144 131073 7888 nil 1008 nil 5 nil nil nil 7888 2866 138 144 34 1 2930 8 'Package Groups' 410 ##(Smalltalk.JadeiteTreeView) 34 28 nil 7888 34 2 8 1140916775 1025 8032 1049670 3 ##(Smalltalk.JadeiteTreeModel) nil 1840 984070 ##(Smalltalk.JadeiteTreeNode) nil nil nil nil 170 192 1808 1008 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 1 984134 2 ##(Smalltalk.CommandMenuItem) 1 1474 #editPackageGroups 8 'Edit Package Groups ...' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 8032 nil 8 1591603216 2098 0 nil 2130 2 1 1872 8 'doIt' 8 '[:service | service displayString]' 8 #[30 105 226 0 106] #displayString 8320 7 257 nil ##(Smalltalk.IconicListAbstract) 1936 nil nil nil nil nil 170 176 1808 33 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 1808 nil 1074 138 144 34 2 1138 #createAt:extent: 34 2 482 9 53 482 459 735 8032 1138 #contextMenu: 34 1 8192 8032 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 233 0 0 0 137 1 0 0] 8 #() 1280 nil 27 8032 nil nil nil 170 192 34 2 8032 8 'componentTree' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 7888 34 2 8 1140916736 1 8672 1762 138 144 34 1 8016 nil 1840 nil nil 1 nil nil nil 8672 nil 8 1591529216 2098 0 nil 4322 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 8800 7 257 nil 2098 0 nil 4322 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 8848 7 257 nil 1936 nil nil nil nil nil #noIcons nil nil nil nil nil 1074 138 144 34 3 1138 #createAt:extent: 34 2 482 1 1 482 475 795 8672 1138 #setSingleSelection: 8 #(1) 8672 1138 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 8672 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 237 0 0 0 141 1 0 0] 8 #() 1280 nil 27 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 1 1 482 475 795 7888 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 237 0 0 0 141 1 0 0] 34 2 8032 8672 1280 nil 27 1280 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 6320 34 2 8 1140850688 1 9280 nil 1008 nil 517 nil nil nil 5090 9280 nil 1 #left nil nil nil 5120 5136 nil 5120 nil 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 475 1 482 11 795 9280 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 237 0 0 0 0 0 0 0 242 0 0 0 141 1 0 0] 8 #() 1280 nil 27 6448 1280 nil 27 5314 3 7 410 ##(Smalltalk.ContainerView) 34 15 nil 576 34 2 8 1140850688 131073 9536 nil nil nil 5 nil nil nil 9536 866 170 176 34 6 410 ##(Smalltalk.CardContainer) 34 16 nil 9536 34 2 8 1409286144 131073 9648 nil 1008 nil 5 nil nil nil 9648 2866 138 144 34 2 2930 590662 1 ##(Smalltalk.CardLabel) 8 'Classes' nil nil 410 ##(Smalltalk.ListView) 34 45 nil 9648 34 2 8 1409372237 1025 9824 1762 138 144 1808 nil 1840 1008 nil 29 nil nil nil 9824 nil 8 1591759072 1874 #displayString 8 #() nil 1936 nil nil nil nil nil nil 138 144 34 1 1986 8 '' 553 #left 1874 #displayString 8 #() 1874 #<= 8 #() nil nil 9824 nil 3 nil 2098 0 nil 2130 5 1 2096 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 10096 7 257 nil #report 2336 nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 9 53 482 561 635 9824 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 28 1 0 0 87 1 0 0] 8 #() 1280 nil 35 2930 9778 8 'Hierarchy' nil nil 410 ##(Smalltalk.JadeiteTreeView) 34 28 nil 9648 34 2 8 1140920871 1025 10384 8098 nil 1310726 ##(Smalltalk.EqualitySearchPolicy) 8130 nil nil nil nil 170 176 1808 1008 nil 29 nil nil nil 10384 nil 8 1591603216 2098 0 nil 2130 2 1 2096 8 'doIt' 8 '[:each | each displayString]' 8 #[30 105 226 0 106] #displayString 10544 7 257 nil ##(Smalltalk.IconicListAbstract) 1936 nil 2098 0 nil 2130 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 10624 7 257 nil 2098 0 nil 2130 5 1 2096 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 10704 7 257 nil nil nil 170 176 1808 33 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 1808 nil 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 9 53 482 561 635 10384 1218 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 28 1 0 0 87 1 0 0] 8 #() 1280 nil 27 9824 nil nil nil 170 192 34 4 10384 8 'classHierarchy' 9824 8 'classList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 9648 34 2 8 1140916736 1 11040 1762 138 144 34 2 9792 10352 nil 1840 nil nil 1 nil nil nil 11040 nil 8 1591529216 2098 0 nil 4322 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 11168 7 257 nil 2098 0 nil 4322 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 11216 7 257 nil 1936 nil nil nil nil nil #smallIcons nil nil nil nil nil 1074 138 144 34 3 1138 #createAt:extent: 34 2 482 1 1 482 577 695 11040 1138 #setSingleSelection: 8 #(1) 11040 1138 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 11040 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 32 1 0 0 91 1 0 0] 8 #() 1280 nil 27 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 1 1 482 577 695 9648 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 32 1 0 0 91 1 0 0] 34 3 9824 10384 11040 1280 nil 27 1298 1344 1 1360 1 1376 1 1680 -99 410 ##(Smalltalk.CardContainer) 34 16 nil 9536 34 2 8 1409286144 131073 11664 nil 1008 nil 5 nil 263174 ##(Smalltalk.Font) nil true 524550 ##(Smalltalk.LOGFONTW) 8 #[240 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 188 2 0 0 0 0 0 0 1 2 1 34 83 0 121 0 115 0 116 0 101 0 109 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 11664 2866 138 144 34 2 2930 9778 8 'Class' nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 11664 34 2 8 1140850688 131073 11920 nil nil nil 5 nil nil nil 11920 nil 170 192 1808 nil 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 9 9 482 561 1 11920 1218 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 28 1 0 0 4 0 0 0] 8 #() 1280 nil 27 2930 9778 8 'Instance' nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 11664 34 2 8 1140850688 131073 12208 nil nil nil 5 nil nil nil 12208 nil 170 192 1808 nil 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 9 9 482 561 1 12208 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 28 1 0 0 4 0 0 0] 8 #() 1280 nil 27 12208 nil nil nil 170 192 34 4 12208 8 'instanceTab' 11920 8 'classTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 11664 34 2 8 1140916738 1 12512 1762 138 144 34 2 12176 11888 nil 1840 nil nil 1 nil nil nil 12512 nil 8 1591529216 2098 0 nil 4322 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 12640 7 257 nil 2098 0 nil 4322 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 12688 7 257 nil 1936 nil nil nil nil nil #smallIcons nil nil nil nil nil 1074 138 144 34 3 1138 #createAt:extent: 34 2 482 1 1 482 577 51 12512 1138 #setSingleSelection: 8 #(1) 12512 1138 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 12512 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 32 1 0 0 25 0 0 0] 8 #() 1280 nil 27 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 1 695 482 577 51 11664 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 91 1 0 0 32 1 0 0 116 1 0 0] 34 3 12208 11920 12512 1280 nil 27 1298 1344 1 1360 1 1680 -99 1330 #fixedViewTop 51 410 ##(Smalltalk.PushButton) 34 20 nil 9536 34 2 8 1140858880 1 13152 nil 994 #silver nil 5 nil nil nil 13152 nil 8 1591823792 1474 #gotoClassDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 1 745 482 577 51 13152 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 116 1 0 0 32 1 0 0 141 1 0 0] 8 #() 1280 nil 29 1298 1344 1 1360 1 1680 -49 1680 1 170 192 34 6 9648 8 'classHierarchyTabs' 11664 8 'instanceClassTabs' 13152 8 'definedPackageClassText' nil 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 1403 1 482 577 795 9536 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 189 2 0 0 0 0 0 0 221 3 0 0 141 1 0 0] 34 3 9648 11664 13152 1280 nil 27 5314 3 11 false 170 192 34 2 6320 8 'componentPackageContainer' nil 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 1 1 482 3001 795 576 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 220 5 0 0 141 1 0 0] 34 6 5344 6320 410 ##(Smalltalk.Splitter) 34 12 nil 576 34 2 8 1140850688 1 13904 nil 1008 nil 517 nil nil nil 5090 13904 nil 1 #left nil nil nil 5120 5136 nil 5120 nil 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 1393 1 482 11 795 13904 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 184 2 0 0 0 0 0 0 189 2 0 0 141 1 0 0] 8 #() 1280 nil 27 9536 410 ##(Smalltalk.Splitter) 34 12 nil 576 34 2 8 1140850688 1 14144 nil 1008 nil 517 nil nil nil 5090 14144 nil 1 #left nil nil nil 5120 5136 nil 5120 nil 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 1979 1 482 11 795 14144 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 221 3 0 0 0 0 0 0 226 3 0 0 141 1 0 0] 8 #() 1280 nil 27 688 1280 nil 27 25 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 14384 nil nil nil 5 nil nil nil 14384 866 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 14384 34 2 8 1140850688 131073 14496 nil nil 482 2241 43 517 nil nil nil 14496 866 170 176 34 4 410 ##(Smalltalk.TextEdit) 34 16 nil 14496 34 2 8 1140850688 1 14624 nil 1008 482 2199 43 517 nil 11730 nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 482 193 193 nil 14624 994 #black 8 1591815600 1042 nil nil 67 1074 138 144 34 2 1138 #createAt:extent: 34 2 482 43 1 482 2959 41 14624 1138 #setMarginWidths: 34 1 8 #(3 3) 14624 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 21 0 0 0 0 0 0 0 220 5 0 0 20 0 0 0] 8 #() 1280 nil 27 1298 1344 43 1360 1 1376 1 1680 1 410 ##(Smalltalk.ToolButton) 34 14 nil 14496 34 2 8 1140850688 131073 15056 nil nil nil 1029 nil nil nil 15056 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 15056 34 2 8 1140853580 131137 15120 nil nil 482 43 43 513 nil nil nil 15120 nil 8 1591782784 nil 170 192 34 2 12981 1115206 1 ##(Smalltalk.ToolbarIconButton) 15120 1 1474 #flipAutoCommit 8 'Auto Commit' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons/camera16_light_icon.ico' nil 12981 34 1 15264 nil nil 3 nil 482 33 33 482 33 33 nil nil 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 1 1 482 43 43 15120 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 8 #() 1280 nil 27 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 1 1 482 43 43 15056 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 34 1 15120 1280 nil 27 1298 1344 1 1330 #fixedViewLeft 43 1376 1 13136 43 170 192 34 4 14624 8 'statusBarField' 15056 8 'autoCommitButton' nil 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 1 757 482 3001 41 14496 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 122 1 0 0 220 5 0 0 142 1 0 0] 34 2 15056 14624 1280 nil 27 1298 1344 1 1360 1 1680 -39 1680 1 410 ##(Smalltalk.CardContainer) 34 16 nil 14384 34 2 8 1409286144 131073 16032 nil 1008 nil 5 nil nil nil 16032 2866 138 144 34 5 2930 9778 8 'SUnit' 2098 0 nil 2130 4 1 2096 8 'doIt' 8 '[Icon fromId: ''icons\UnitTestPlugin.ico'']' 8 #[32 105 45 30 178 106] 983558 ##(Smalltalk.VariableBinding) #Icon 15312 8 'icons\UnitTestPlugin.ico' #fromId: 16192 7 1 nil nil 410 ##(Smalltalk.ReferenceView) 34 14 nil 16032 34 2 8 1140850688 131073 16320 nil 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 nil nil nil 16320 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteSUnitInClassPresenter) #resource_Default_view nil 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 9 53 482 2985 697 16320 1218 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 216 5 0 0 118 1 0 0] 1808 1280 nil 27 2930 9778 8 'Class Definition' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 16032 34 2 8 1445007428 1025 16640 721990 2 ##(Smalltalk.ValueHolder) nil false 10480 nil 16386 26337781 nil 5 8178 nil true 34 11 8226 1 1474 #editSave 8 '&Save' 9383 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 8226 1 1474 #editUndo 8 '&Undo' 9397 1 nil nil nil 8226 1 1474 #editRedo 8 '&Redo' 9395 1 nil nil nil 16834 4097 8226 1 1474 #editCut 8 'Cu&t' 9393 1 nil nil nil 8226 1 1474 #editCopy 8 '&Copy' 9351 1 nil nil nil 8226 1 1474 #editPaste 8 '&Paste' 9389 1 nil nil nil 8226 1 1474 #editDelete 8 '&Delete' 1629 1 nil nil nil 16834 4097 8226 1 1474 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 11730 nil true 14722 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 16640 nil 8 1610169832 1042 nil nil 13 1555459681 170 192 34 4 #callTip 1182790 1 ##(Smalltalk.ScintillaTextStyle) 77 994 #gray 994 #white 1 nil nil nil nil #callTip nil nil nil #normal 17378 1 nil nil 1 nil nil nil nil #normal nil nil nil nil 1639686 ##(Smalltalk.SmalltalkExpressionStyler) 1 nil nil false 138 144 1808 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 16640 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1808 nil 170 176 1808 9215 nil nil nil nil 13216 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #literalArray 8 '()' #specialCharacter 8 '()[]<>' 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 17440 nil nil nil nil 16 nil 170 192 34 6 1 1510470 3 ##(Smalltalk.ScintillaIndicatorStyle) 1 16640 16386 65025 3 false 1 nil nil nil nil nil nil 3 17794 3 16640 994 #blue 5 false 3 nil nil nil nil nil nil 5 17794 5 16640 994 #red 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 17378 1027 16386 60239 16386 31326207 1 nil nil nil nil #Warning nil nil nil #Error 17378 1031 16386 335 16386 31317503 1 nil nil nil nil #Error nil nil nil #Notification 17378 1029 nil 16386 31185883 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1074 138 144 34 9 1138 #createAt:extent: 34 2 482 9 53 482 2985 697 16640 1138 #contextMenu: 34 1 16752 16640 1138 #caretPeriod: 8 #(530) 16640 1138 #wordWrap: 8 #(true) 16640 1138 #margins: 34 1 34 3 985158 3 ##(Smalltalk.ScintillaMargin) 1 16640 1 3 nil nil 5 nil 18322 3 16640 33 nil 3 67108863 5 nil 18322 5 16640 1 nil 3 -67108863 5 nil 16640 1138 #tabWidth: 8 #(4) 16640 1138 #targetRange: 34 1 525062 ##(Smalltalk.Interval) 1 -1 3 16640 1138 #maxCompletionListHeight: 8 #(9) 16640 1138 #edgeColumn: 8 #(1) 16640 1218 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 216 5 0 0 118 1 0 0] 8 #() 1280 nil 33 2930 9778 8 'Class Documentation' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 16032 34 2 8 1445007428 1025 18640 16706 nil false 10480 nil 16386 26337781 nil 5 8178 nil true 34 1 8226 1 1474 #editSaveClassComment 8 'Save' 1025 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 11730 nil true 14722 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 18640 nil 8 1610169832 1042 nil nil 15 1559337185 170 192 34 4 #callTip 17378 77 17408 17424 1 nil nil nil nil #callTip nil nil nil #normal 17378 1 nil nil 1 nil nil nil nil #normal nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 17538 1 nil nil nil 18640 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1808 nil 170 176 1808 9215 nil nil nil nil 13216 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 18976 nil nil nil nil 16 nil 170 192 34 6 1 17794 1 18640 16386 65025 3 false 1 nil nil nil nil nil nil 3 17794 3 18640 17856 5 false 3 nil nil nil nil nil nil 5 17794 5 18640 17888 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 17378 1027 16386 60239 16386 31326207 1 nil nil nil nil #Warning nil nil nil #Error 17378 1031 16386 335 16386 31317503 1 nil nil nil nil #Error nil nil nil #Notification 17378 1029 nil 16386 31185883 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1074 138 144 34 10 1138 #createAt:extent: 34 2 482 9 53 482 2985 697 18640 1138 #contextMenu: 34 1 18736 18640 1138 #hoverTime: 8 #(1000000) 18640 1138 #caretPeriod: 8 #(530) 18640 1138 #wordWrap: 8 #(true) 18640 1138 #margins: 34 1 34 3 18322 1 18640 1 3 nil nil 5 nil 18322 3 18640 33 nil 3 67108863 5 nil 18322 5 18640 1 nil 3 -67108863 5 nil 18640 1138 #tabWidth: 8 #(4) 18640 1138 #targetRange: 34 1 18450 1 -1 3 18640 1138 #maxCompletionListHeight: 8 #(9) 18640 1138 #edgeColumn: 8 #(1) 18640 1218 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 216 5 0 0 118 1 0 0] 8 #() 1280 nil 33 2930 9778 8 'Method Source' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 16032 34 2 8 1445007428 1025 20016 16706 nil false 10480 nil 16386 26337781 nil 5 nil 11730 nil true 14722 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 20016 nil 8 1610169832 1042 nil nil 13 1559319713 170 192 34 4 #callTip 17378 77 17408 17424 1 nil nil nil nil #callTip nil nil nil #normal 17378 1 nil nil 1 nil nil nil nil #normal nil nil nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 1808 170 192 34 2 #default 17538 1 nil nil nil 20016 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1808 nil 170 176 1808 9215 nil nil nil nil 13216 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #literalArray 8 '()' #specialCharacter 8 '()[]<>' 8 '' 3 170 192 34 2 #container 170 192 34 4 #callTip 20240 #normal 20256 nil nil nil nil 16 nil 170 192 34 12 1 17794 1 20016 16386 65025 3 false 1 nil nil nil nil nil nil 8 'indicator8' 17794 17 20016 13216 1 nil nil nil nil nil nil nil nil 3 17794 3 20016 17856 5 false 3 nil nil nil nil nil nil 8 'indicator10' 17794 21 20016 17888 3 nil nil nil nil nil nil nil nil 8 'indicator9' 17794 19 20016 17888 13 nil nil nil nil nil nil nil nil 5 17794 5 20016 17888 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 17378 1027 16386 60239 16386 31326207 1 nil nil nil nil #Warning nil nil nil #Error 17378 1031 16386 335 16386 31317503 1 nil nil nil nil #Error nil nil nil #Notification 17378 1029 nil 16386 31185883 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1074 138 144 34 9 1138 #createAt:extent: 34 2 482 9 53 482 2985 697 20016 1138 #hoverTime: 8 #(500) 20016 1138 #caretPeriod: 8 #(530) 20016 1138 #wordWrap: 8 #(true) 20016 1138 #margins: 34 1 34 3 18322 1 20016 61 3 nil nil 5 nil 18322 3 20016 1 nil 3 67108863 nil nil 18322 5 20016 1 nil 3 -67108863 nil nil 20016 1138 #tabWidth: 8 #(4) 20016 1138 #targetRange: 34 1 18450 1 -1 3 20016 1138 #maxCompletionListHeight: 8 #(9) 20016 1138 #edgeColumn: 8 #(1) 20016 1218 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 216 5 0 0 118 1 0 0] 8 #() 1280 nil 33 2930 9778 8 'Comparison' nil nil 410 ##(Smalltalk.ShellView) 34 27 nil 16032 34 2 8 1078919168 131073 21456 nil 1008 nil 517 nil nil nil 21456 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 21456 34 2 8 1140850688 131073 21552 nil 16386 26337781 nil 5 8178 nil true 34 5 8226 1 1474 #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 8226 1 1474 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 8226 1 1474 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 8226 1 1474 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 8226 1 1474 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 21552 514 170 176 1808 false 170 192 1808 nil 1074 138 144 34 2 1138 #createAt:extent: 34 2 482 1 1 482 2953 665 21552 1138 #contextMenu: 34 1 21632 21552 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 196 5 0 0 76 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 21552 34 2 8 1140850688 131073 22160 nil 1008 nil 5 nil nil nil 22160 21522 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 22160 34 2 8 1140850945 262145 22240 nil nil nil 21 nil nil nil 22240 nil 8 1591672000 1042 nil nil nil 1074 138 144 34 2 1138 #createAt:extent: 34 2 482 1 625 482 1471 41 22240 1138 #text: 34 1 8 '
' 22240 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 223 2 0 0 76 1 0 0] 8 #() 1280 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 22160 34 2 8 1140920580 1025 22544 16706 nil false 10480 nil 16386 26337781 nil 21 nil nil nil 22544 nil 8 1610169832 1042 nil nil 13 1559324081 170 192 34 12 #whitespace 17378 3 994 #teal nil 1 nil nil nil nil #whitespace nil nil nil #diff 17378 5 nil 16386 16908287 3 nil nil nil nil #diff nil 1401 nil #lineNumber 17378 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #normal 17378 1 nil nil 1 nil nil nil nil #normal nil nil nil #indentGuide 17378 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #callTip 17378 77 17408 17424 1 nil nil nil nil #callTip nil nil nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 17538 1 nil nil nil 22544 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1808 nil 170 176 1808 9215 nil nil nil nil 13216 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #literalArray 8 '()' #specialCharacter 8 '()[]<>' 8 '' 3 170 192 34 2 #container 22672 nil nil nil nil 16 nil 170 192 34 2 #diff 17794 1 22544 994 #yellow 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 17378 1027 16386 60239 16386 31326207 1 nil nil nil nil #Warning nil nil nil #Error 17378 1031 16386 335 16386 31317503 1 nil nil nil nil #Error nil nil nil #Notification 17378 1029 nil 16386 31185883 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1074 138 144 34 8 1138 #createAt:extent: 34 2 482 1 1 482 1471 625 22544 1138 #caretPeriod: 8 #(530) 22544 1138 #wordWrap: 8 #(true) 22544 1138 #margins: 34 1 34 3 18322 1 22544 49 3 nil nil nil nil 18322 3 22544 1 nil nil 67108863 nil nil 18322 5 22544 1 nil nil nil nil nil 22544 1138 #canHScroll: 8 #(false) 22544 1138 #targetRange: 34 1 18450 1 -1 3 22544 1138 #maxCompletionListHeight: 8 #(9) 22544 1138 #edgeColumn: 8 #(1) 22544 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 223 2 0 0 56 1 0 0] 8 #() 1280 nil 33 170 192 34 4 22240 8 'beforeTitle' 22544 8 'before' nil 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 1 1 482 1471 665 22160 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 223 2 0 0 76 1 0 0] 34 2 22544 22240 1280 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 21552 34 2 8 1140850688 1 24000 nil 16386 66047 nil 517 nil nil nil 5090 24000 nil 1 #left nil nil nil 5120 5136 nil 5120 nil 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 1471 1 482 11 665 24000 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 223 2 0 0 0 0 0 0 228 2 0 0 76 1 0 0] 8 #() 1280 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 21552 34 2 8 1140850688 131073 24256 nil 1008 nil 5 nil nil nil 24256 21522 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 24256 34 2 8 1140850945 262145 24336 nil nil nil 21 nil nil nil 24336 nil 8 1591672000 1042 nil nil nil 1074 138 144 34 2 1138 #createAt:extent: 34 2 482 1 625 482 1473 41 24336 1138 #text: 34 1 8 '
' 24336 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 224 2 0 0 76 1 0 0] 8 #() 1280 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 24256 34 2 8 1140920580 1025 24640 16706 nil false 10480 nil 16386 26337781 nil 21 nil nil nil 24640 nil 8 1610169832 1042 nil nil 13 1559328449 170 192 34 12 #whitespace 17378 3 22720 nil 1 nil nil nil nil #whitespace nil nil nil #diff 17378 5 nil 16386 16908287 3 nil nil nil nil #diff nil 1401 nil #lineNumber 17378 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #normal 17378 1 nil nil 1 nil nil nil nil #normal nil nil nil #indentGuide 17378 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #callTip 17378 77 17408 17424 1 nil nil nil nil #callTip nil nil nil nil 22834 22864 170 192 34 2 #default 17538 1 nil nil nil 24640 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1808 nil 170 176 1808 9215 nil nil nil nil 13216 nil nil 65 nil nil 22960 23040 3 170 192 34 2 #container 24768 nil nil nil nil 16 nil 170 192 34 2 #diff 17794 1 24640 23136 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 17378 1027 16386 60239 16386 31326207 1 nil nil nil nil #Warning nil nil nil #Error 17378 1031 16386 335 16386 31317503 1 nil nil nil nil #Error nil nil nil #Notification 17378 1029 nil 16386 31185883 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1074 138 144 34 8 1138 #createAt:extent: 34 2 482 1 1 482 1473 625 24640 1138 #caretPeriod: 8 #(530) 24640 1138 #wordWrap: 8 #(true) 24640 1138 #margins: 34 1 34 3 18322 1 24640 49 3 nil nil nil nil 18322 3 24640 1 nil nil 67108863 nil nil 18322 5 24640 1 nil nil nil nil nil 24640 1138 #canHScroll: 8 #(false) 24640 1138 #targetRange: 34 1 18450 1 -1 3 24640 1138 #maxCompletionListHeight: 8 #(9) 24640 1138 #edgeColumn: 8 #(1) 24640 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 224 2 0 0 56 1 0 0] 8 #() 1280 nil 33 170 192 34 4 24336 8 'afterTitle' 24640 8 'after' nil 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 1481 1 482 1473 665 24256 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 228 2 0 0 0 0 0 0 196 5 0 0 76 1 0 0] 34 2 24640 24336 1280 nil 27 1280 nil 27 170 192 34 2 21552 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 8178 nil true 34 4 8226 1 1474 #selectUpper 8 'Select &upper' 1 1 nil nil nil 8226 1 1474 #selectLower 8 'Select &lower' 1 1 nil nil nil 16834 4097 8226 1 1474 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 13185 nil nil 8178 nil true 34 3 8226 1 1474 #character 8 '&Character' 1 1 nil nil nil 8226 1 1474 #word 8 '&Word' 1 1 nil nil nil 8226 1 1474 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 13187 nil nil 8178 nil true 34 1 8226 1 1474 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 13189 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1074 138 144 34 2 1138 #createAt:extent: 34 2 482 9 53 482 2985 697 21456 1138 #text: 34 1 8 'Comparison' 21456 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 216 5 0 0 118 1 0 0] 34 1 21552 1280 nil 27 21456 nil nil nil 170 192 34 10 16640 8 'classDefinition' 20016 8 'methodSource' 16320 8 'sunit' 21456 8 'comparisonTab' 18640 8 'classDocumentation' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 16032 34 2 8 1140916736 1 26864 1762 138 144 34 5 16608 18608 19984 16160 21424 nil 1840 nil nil 1 nil nil nil 26864 nil 8 1591529216 2098 0 nil 4322 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 26992 7 257 nil 2098 0 nil 4322 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 27040 7 257 nil 1936 nil nil nil nil nil #smallIcons nil nil nil nil nil 1074 138 144 34 3 1138 #createAt:extent: 34 2 482 1 1 482 3001 757 26864 1138 #setSingleSelection: 8 #(5) 26864 1138 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 26864 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 220 5 0 0 122 1 0 0] 8 #() 1280 nil 27 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 1 1 482 3001 757 16032 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 220 5 0 0 122 1 0 0] 34 6 16640 18640 20016 16320 21456 26864 1280 nil 27 1298 1344 1 1360 1 1376 1 1680 -39 170 192 34 2 16032 8 'textAreaTabs' nil 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 1 805 482 3001 797 14384 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 146 1 0 0 220 5 0 0 32 3 0 0] 34 2 16032 14496 1280 nil 27 25 true 170 192 34 2 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 27728 nil 1008 nil 517 nil nil nil 5090 27728 nil 1 #left nil nil nil 5120 5136 nil 5120 nil 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 1 795 482 3001 11 27728 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 141 1 0 0 220 5 0 0 146 1 0 0] 8 #() 1280 nil 27 8 'splitter' nil 1074 138 144 34 1 1138 #createAt:extent: 34 2 482 6517 21 482 3001 1601 416 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 186 12 0 0 10 0 0 0 150 18 0 0 42 3 0 0] 34 3 576 27728 14384 1280 nil 27 )! !
!JadeiteBrowserPresenter class categoriesForMethods!
resource_Default_view!public!resources-views! !
!

