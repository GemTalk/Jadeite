"Filed out from Dolphin Smallalk"!

JadeiteProjectsBrowserPresenter subclass: #JadeiteBrowserPresenter
	instanceVariableNames: 'dictionaryPresenter packageDictionaryCards globalsTab autoCommitButton search previousTabViewArrangement previousTopViewArrangement packageGroupPresenter componentPackageContainer packageDictionaryContainer packageMethodListPresenter projectListContainer packageGroupsContainer classContainer projectInfoList addPackagePresenter projectReadMeTab'
	classVariableNames: ''
	poolDictionaries: 'ScintillaConstants'
	classInstanceVariableNames: ''!
JadeiteBrowserPresenter guid: (GUID fromString: '{c313bf86-bb5a-44fc-8c18-2671e1ac39a7}')!
JadeiteBrowserPresenter comment: ''!
!JadeiteBrowserPresenter categoriesForClass!Unclassified! !
!JadeiteBrowserPresenter methodsFor!

abortedTransaction
	self toolbarPresenter view validateUserInterface!

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

addPackagePresenter
	^addPackagePresenter!

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
	^self auditProjectFor: projectListPresenter selection name!

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

buildAddPackageView
	| addPackageView |
	addPackagePresenter := JadeiteAddPackagePresenter new
				gciSession: gciSession;
				projectService: projectListPresenter selection.
	addPackagePresenter parentPresenter: projectInfoTab.
	addPackageView := addPackagePresenter createView: 'Default view'.
	addPackageView
		arrangement: 1;
		backcolor: JadeiteTextStyles default colorForNoEdits.
	projectInfoTab view addSubView: addPackageView.
	^addPackageView!

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
	infoTabView getImageBlock: nil.
	^infoTabView!

buildPreferencesMenu
	| preferencesMenu showPackageItem showPackageGroupItem |
	preferencesMenu := Menu fromStrings: self preferencesMenuStrings.
	preferencesMenu addSeparator.
	showPackageItem := preferencesMenu
				addItem: (CommandMenuItem command: #togglePackageDictionaryColumn description: 'Package list visible').
	showPackageItem isRadioButtonStyle: true.
	showPackageGroupItem := preferencesMenu
				addItem: (CommandMenuItem command: #togglePackageGroupsColumn description: 'Package groups visible').
	showPackageGroupItem isRadioButtonStyle: true.
	^preferencesMenu!

buildProjectListView
	| listView |
	projectInfoList := ListPresenter new.
	projectInfoList parentPresenter: projectInfoTab.
	listView := self buildInfoTab: projectInfoList. 
	listView arrangement: 2. 
	projectInfoTab view addSubView: listView!

buildProjectReadMeTab
	| cardLabel |
	projectReadMeTab := TextPresenter new.
	(projectReadMeTab
		parentPresenter: self textAreaTabs presenter;
		createView: 'Scintilla view';
		view)
		wordWrap: true;
		backcolor: JadeiteTextStyles default colorForNoEdits.
	self updateProjectReadMe.
	cardLabel := CardLabel text: 'ReadMe'.
	cardLabel iconBlock: nil.
	projectReadMeTab view
		arrangement: cardLabel;
		name: 'projectReadMeTab'!

buildProjectTab
	| cardLabel |
	projectInfoTab := Presenter new.
	projectInfoTab parentPresenter: self textAreaTabs presenter.
	projectInfoTab createView: 'Container view'.
	projectInfoTab view layoutManager: ProportionalLayout new.
	self buildProjectListView.
	self buildAddPackageView.
	projectInfoList view contextMenu: self projectInfoMenu.
	cardLabel := CardLabel text: 'Project'.
	cardLabel iconBlock: nil.
	projectInfoTab view
		arrangement: cardLabel;
		name: 'projectInfoTab'!

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

cleanupProjectInfoTab
	self projectListPresenter selectionIfNone: 
			[projectInfoTab
				ifNotNil: 
					[self clearProjectTabs.
					addPackagePresenter view disable]]!

clearComponentList
	packageGroupPresenter model: (JadeiteTreeModel new
				searchPolicy: SearchPolicy equality;
				reset)!

clearMethodListPresenters
	categoryListPresenter clear.
	variableListPresenter clear.
	packageMethodListPresenter clear.
	methodListPresenter clear!

clearProjectTabs
	projectReadMeTab value: String new.
	projectInfoList list: ListModel new!

comparisonPresenter

	^comparisonPresenter!

contextObject
	^self selectedClass ifNil: [^gciSession oopNil value] ifNotNil: [:classService | classService oop]!

copyInfo
	self copyProjectInfo
	!

copyProjectInfo
	projectInfoList selectionIfNone: 
			[MessageBox notify: 'No selection to copy'.
			^self].
	projectInfoList selection last ifNil: [^self].
	(projectInfoList selection first perform: projectInfoList selection last asSymbol) displayString
		copyToClipboard!

createComponents
	super createComponents.
	dictionaryPresenter := self add: ListPresenter new name: 'dictionariesList'.
	packageDictionaryCards := self add: Presenter new name: 'packageDictionaryCards'.
	autoCommitButton := self add: Presenter new name: 'autoCommitButton'.
	packageGroupPresenter := self add: JadeiteTreePresenter new name: 'packageGroupTree'.
	componentPackageContainer := self add: Presenter new name: 'componentPackageContainer'.
	packageDictionaryContainer := self add: Presenter new name: 'packageDictionaryContainer'.
	packageGroupsContainer := self add: Presenter new name: 'packageGroupsContainer'.
	projectListContainer := self add: Presenter new name: 'projectListContainer'.
	packageMethodListPresenter := self add: ListPresenter new name: 'packageMethodList'.
	classContainer := self add: Presenter new name: 'classContainer'.!

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
	packageGroupPresenter
		when: #selectionChanged
		send: #updatePackageGroupPackages
		to: self.
	packageDictionaryCards
		when: #dragOver:
			send: #onDragOverPackageList:
			to: self;
		when: #drop:
			send: #onDropOnPackageList:
			to: self.
	packageMethodListPresenter
		when: #selectionChanged
			send: #refreshMethodsOn:
			to: self
			with: methodListPresenter;
		when: #dragOver:
			send: #onDragOverPackageList:
			to: self;
		when: #drop:
			send: #onDropOnPackageList:
			to: self.
	projectListPresenter 
		when: #selectionChanged
			send: #updateAddPackageLists
			to: self
			!

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

editSave
	| currentCard |
	currentCard := textAreaTabs view currentCard.
	currentCard = classDefinitionPresenter view ifTrue: [^self editSaveClass].
	currentCard = methodSourcePresenter view ifTrue: [^self editSaveMethod].
	currentCard = classCommentPresenter view ifTrue: [^self editSaveClassComment].
	currentCard = projectReadMeTab view ifTrue: [^self editSaveReadMe].
	MessageBox notify: 'Save menu not effective for this text area tab'!

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

editSaveReadMe
	| service |
	service := RowanFileService new
				command: #writeReadme:;
				commandArgs: (Array with: projectReadMeTab value);
				path: self projectReadmePath.
	self issueCommand: service!

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
	self gitCommit: projectListPresenter!

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
	(command = #refreshFromServer or: [command = #loadProject]) ifTrue: [^true].
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
	^#('&Methods' 'Browse &Implementors//browseImplementors' 'Browse Implementors of ...//browseImplementorsOf' 'Browse &Senders//browseSenders' 'Browse Senders of ...//browseSendersOf' '-' 'Browse Hierarchy Implementors//browseHierarchyImplementors' 'Browse Hierarchy Senders//browseHierarchySenders' '-' 'Browse Methods &Containing ...//browseMethodsContaining' 'Browse Literal References ...//browseLiteralReferences' 'Browse Selected Methods//browseSelectedMethods' 'Browse Method History//browseMethodHistory' 'Inspect//inspectMethod' '-' 'Browse Breakpoints//browseBreakpoints' 'Clear Method Breakpoints//clearMethodBreakpoints' '-' 'Find Method .../Ctrl+Shift+M/findMethod' '-' '&Remove Method(s) .../Ctrl+Shift+X/removeMethods' 
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
	| packageServiceToSelect selectedClass selectedMethods newSelectedMethods |
	methodListPresenter selections isEmpty ifTrue: [^self].
	selectedClass := self selectedClass.
	selectedMethods := methodListPresenter selections.
	self selectedClass
		command: #moveMethodSelectors:toPackageNamed:;
		commandArgs: (Array with: (selectedMethods collect: [:methodService | methodService selector])
					with: packageName).
	self issueCommand: self selectedClass.
	packageServiceToSelect := packageListPresenter list
				detect: [:packageService | packageService name = packageName] ifNone:[^self].
	packageListPresenter selections: (self selectedPackageServices asOrderedCollection
				add: packageServiceToSelect;
				yourself).
	self selectClassNamed: selectedClass name.
	newSelectedMethods := selectedMethods select:[:oldSelMethod | methodListPresenter list includes: oldSelMethod]. 
	methodListPresenter selections: newSelectedMethods.
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

onDropMethodsOnPackageList: packageServiceOrName session: aSession
	| methods |
	methods := aSession dragObjects collect: [:each | each format: #method].
	methods isEmpty
		ifFalse: 
			[^self moveMethodsToPackageNamed: ((packageServiceOrName class canUnderstand: #name)
						ifTrue: [packageServiceOrName name]
						ifFalse: [packageServiceOrName])].
	MessageBox notify: 'Sorry, we are not yet prepared to handle ' , aSession printString , '!!'.
	SessionManager current pause!

onDropOnPackageList: aSession
	(aSession isFormatAvailable: #class) ifTrue: [^self onDropClassesOnPackageList: aSession].
	(aSession isFormatAvailable: #method) ifTrue: [^self onDropMethodsOnPackageList: aSession].
	MessageBox notify: 'Sorry, we are not yet prepared to handle ' , aSession printString , '!!'.
	SessionManager current pause!

onViewClosed
	super onViewClosed.
	BrowserUpdate current removeEventsTriggeredFor: packageGroupPresenter!

onViewOpened
	super onViewOpened.
	BrowserUpdate current logComment: 'Opening Projects Browser {' , self identityHash printString , '}'.
	self registerPresentersForUpdates.
	projectListPresenter view contextMenu: self class projectMenu.
	self setupPackageMenu.
	self updateMenuBar.
	self updateProjects.
	self updateAutoCommit.
	definedClassPackageText view isMultiline: false.
	definedClassPackageText view alignment: #left.
	definedMethodPackageText view isMultiline: false.
	definedMethodPackageText view alignment: #left.
	self showPackageList!

openSourceStyler
	| textStyles |
	textStyles := super openSourceStyler.
	comparisonPresenter afterPresenter view textStyles: textStyles.
	comparisonPresenter beforePresenter view textStyles: textStyles!

packageDictionaryCards
	"for testing"

	^packageDictionaryCards!

packageGroupPresenter
	^packageGroupPresenter!

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

projectInfoList
	^projectInfoList!

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

projectMenuCommands
	^self class projectMenu items collect: [:item | item command]!

projectReadmePath
	^JadePresenter rowanProjectsHomeEnvVarString , '/' , self selectedProjectName , '/README.md'!

projectReadMeTab
	^projectReadMeTab!

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
	#loadProjects = command
		ifTrue: 
			[aCommandQuery isEnabled: true.
			^true].
	aCommandQuery commandSymbol = #beginTransaction
		ifTrue: 
			[aCommandQuery isEnabled: self isBeginTransactionEnabled.
			^true].
	command = #flipAutoCommit
		ifTrue: 
			[aCommandQuery isEnabled: self transactionMode = #autoBegin.
			^true].
	command = #beginTransaction
		ifTrue: 
			[aCommandQuery isEnabled: self isBeginTransactionEnabled.
			^true].
	command = #commitTransaction
		ifTrue: 
			[aCommandQuery isEnabled: self isCommitEnabled.
			^true].
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
	#togglePackageGroupsColumn == aCommandQuery command
		ifTrue: 
			[aCommandQuery isEnabled: true.
			aCommandQuery isChecked: packageGroupPresenter view isWindowVisible.
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
							^self clearMethodListPresenters]
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

refreshMethodsOn: presenter
	| classService |
	classService := self selectedClass ifNil: [^self].
	classService meta: self isClassSideSelected.
	self isCategoryTabSelected
		ifTrue: [classService filters: categoryListPresenter selections]
		ifFalse: 
			[self isVariablesTabSelected
				ifTrue: [classService filters: variableListPresenter selections]
				ifFalse: [classService filters: packageMethodListPresenter selections]].
	classService displayMethodsOn: presenter browser: self!

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
		register: packageListPresenter
			selector: #componentPackagesUpdate:browser:
			browser: self;
		register: packageGroupPresenter
			selector: #packageGroupUpdate:browser:
			browser: self;
		register: packageMethodListPresenter
			selector: #filterUpdate:browser:
			browser: self!

reloadProject
	"intention revealing selector"

	^self loadProjects!

removeAppropriateTab
	self isNoneProjectSelected ifTrue: [self removeProjectTabs] ifFalse: [self removeGlobalsTab]!

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

removeProjectTabs
	| projectInfoView projectReadMeView |
	projectInfoView := self view viewNamed: 'projectInfoTab' ifNone: [nil].
	projectInfoView ifNotNil: [self textAreaTabs removeSubView: projectInfoView].
	projectInfoTab := nil.
	projectReadMeView := self view viewNamed: 'projectReadMeTab' ifNone: [nil].
	projectReadMeView ifNotNil: [self textAreaTabs removeSubView: projectReadMeView].
	projectReadMeTab := nil!

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

selectedFilters
	^self isCategoryTabSelected
		ifTrue: [categoryListPresenter selections]
		ifFalse: 
			[self isVariablesTabSelected
				ifTrue: [variableListPresenter selections]
				ifFalse: [packageMethodListPresenter selections]]!

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

selectPackageNamed: packageName
	| answeringService service |
	answeringService := RowanAnsweringService new.
	answeringService
		command: #packageNamed:;
		commandArgs: (Array with: packageName).
	self issueCommand: answeringService.
	service := answeringService answer.
	service selectIn: self!

selectPackageOrDictionaryFor: classService
	| answeringService service |
	answeringService := RowanAnsweringService new.
	answeringService
		command: #packageOrDictionaryFor:;
		commandArgs: (Array with: classService).
	self issueCommand: answeringService.
	service := answeringService answer.
	service selectIn: self!

selectProjectNamed: projectName
	| projectService |
	projectService := projectListPresenter list detect: [:service | service name = projectName]
				ifNone: [^self].
	projectListPresenter selections: (Array with: projectService).
	^projectService "return for testing"!

selectProjectTab
	self selectSourceTabNamed: 'projectInfoTab'!

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

togglePackageGroupsColumn
	packageGroupPresenter view creationParentView isWindowVisible
		ifTrue: 
			[packageDictionaryContainer view arrangement: 100.
			packageGroupPresenter view creationParentView hide]
		ifFalse: 
			[classContainer view arrangement: 1 / 5.
			packageDictionaryContainer view arrangement: 0.5.
			packageGroupPresenter view creationParentView show]!

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

updateAddPackageLists
	projectListPresenter selectionOrNil ifNil: [^self].
	addPackagePresenter ifNotNil: [addPackagePresenter projectService: projectListPresenter selection]!

updateAfterFindClass: classService
	| projectService |
	classService ifNil: [^self].
	classService projectName ifNil: [self updateService: classService].
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
		ifFalse: [autoCommitButtonView backcolor: Color default].!

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
				addItem: self class projectMenu;
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
	"Do the package selection & class gathering as such for a performance improvement"

	| classes |
	packageListPresenter clear.
	packageGroupPresenter selections isEmpty ifTrue: [^self].
	self updateServices: packageGroupPresenter selections.
	packageListPresenter noEventsDo: [packageListPresenter selections: packageListPresenter list].
	classes := Set new.
	packageListPresenter selections do: [:packageService | classes addAll: packageService classes].
	classListPresenter list: classes asArray.
	self sundryCleanup!

updateProject
	self clearComponentList.
	self projectListPresenter selectionIfNone: 
			[packageListPresenter clear.
			dictionaryPresenter clear.
			self cleanupProjectInfoTab.
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
	projectInfoTab
		ifNil: 
			[self buildProjectTab.
			self buildProjectReadMeTab].
	service := projectListPresenter selectionIfNone: 
					[self clearProjectTabs.
					^self].
	self updateTabLabel.
	self updateProjectInfoTabFor: service.
	self updateProjectReadMe.
	addPackagePresenter view enable!

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
	projectInfoList list: array contents!

updateProjectReadMe
	| service |
	service := RowanFileService new
				command: #readmeContents;
				path: self projectReadmePath. 
	self issueCommand: service.
	projectReadMeTab value: service answer replaceLfWithCrLf!

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
abortedTransaction!public! !
abortTransaction!public!transaction management! !
addDictionary!menu handlers!public! !
additionalAccelerators!constants!public! !
addNoneProject!public!updating! !
addPackagePresenter!accessing!private! !
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
buildAddPackageView!private!tabs! !
buildGlobalsTab!private!tabs! !
buildInfoTab:!private!tabs! !
buildPreferencesMenu!menus!private!updating! !
buildProjectListView!private!tabs! !
buildProjectReadMeTab!private!tabs! !
buildProjectTab!private!tabs! !
categoriesMenuStrings!menus!public! !
checkout!menu handlers!public! !
checkoutTag!menu handlers!public! !
classCommentChanged!event handlers!public! !
classesMenuStrings!menus!public! !
cleanupProjectInfoTab!event handlers!public!updating! !
clearComponentList!initialize/release!public! !
clearMethodListPresenters!event handlers!private!updating! !
clearProjectTabs!private!tabs! !
comparisonPresenter!accessing!public! !
contextObject!menu handlers support!private! !
copyInfo!menu handlers!public! !
copyProjectInfo!menu handlers!public! !
createComponents!initialize/release!public! !
createListViewFor:!private! !
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
editSave!menu handlers!public! !
editSaveClass!menu handlers!public! !
editSaveMethod!menu handlers!public! !
editSaveMethod:!menu handlers support!private! !
editSaveReadMe!menu handlers!private!tabs! !
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
packageGroupPresenter!accessing!private! !
preferencesMenuStrings!menus!public! !
previousTabViewArrangement!accessing!private! !
previousTabViewArrangement:!accessing!private! !
previousTopViewArrangement!accessing!private! !
previousTopViewArrangement:!accessing!private! !
projectChanges!project menu handlers!public! !
projectInfoList!accessing!private! !
projectInfoMenu!menus!public! !
projectInfoMenuStrings!menus!public! !
projectInfoTab!accessing!public! !
projectLog!project menu handlers!public! !
projectMenuCommands!menus!public! !
projectReadmePath!menu handlers!private!tabs! !
projectReadMeTab!accessing!private! !
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
refreshMethodsOn:!event handlers!public! !
registerPresentersForUpdates!public!register presenters! !
reloadProject!menu handlers!public! !
removeAppropriateTab!private!tabs! !
removeClass!menu handlers!public! !
removeDictionaries!menu handlers!public! !
removeGlobal!menu handlers!public! !
removeGlobalsTab!private!tabs! !
removeProjectTabs!private!tabs! !
resetClassTemplate!private! !
resetFontSize!menu handlers!public! !
runAll!menu handlers!public! !
runSelected!menu handlers!public! !
search!accessing!public! !
selectDictionaryNamed:!public!selection! !
selectedDictionaryNames!public!selection! !
selectedDictionaryOrPackage!private!selection! !
selectedFilters!accessing!public! !
selectedGlobalName:!menu handlers support!private! !
selectedPackageNames!public!selection! !
selectedPackageServices!public!selection! !
selectedProjectName!public!selection! !
selectNoneProject!public!selection! !
selectPackageNamed:!public!selection! !
selectPackageOrDictionaryFor:!public!selection! !
selectProjectNamed:!public!selection! !
selectProjectTab!public! !
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
togglePackageDictionaryColumn!menu handlers!public! !
togglePackageGroupsColumn!menu handlers!public! !
unloadProjects!project menu handlers!public! !
updateAddPackageLists!public!updating! !
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
updateProjectReadMe!private!tabs! !
updateSystemTab!event handlers!private!updating! !
updateTabLabel!public!updating! !
variablesMenuStrings!menus!public! !
writeProject!project menu handlers!public! !
!

!JadeiteBrowserPresenter class methodsFor!

defaultAdditionalAccelerators
	^super defaultAdditionalAccelerators, #(#(#insertIfFalse 'Ctrl+Shift+D') #(#insertIfTrue 'Ctrl+Shift+T'))!

projectMenu
	^Menu fromStrings: self projectMenuStrings!

projectMenuStrings
	"put on the class side so it can be shared with the projectlist in the console" 
	self rowanFixMe.	"this really is a cumbersome way to build a menu."
	0 == 1
		ifTrue: 
			[self new
				createNewProject;
				addPackage;
				loadProject;
				reloadProject;
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
	^#('Projects' 'Create ...//createNewProject' 'Load Git Project ...//loadProjects' 'Reload Project //reloadProject' 'Unload//unloadProjects' '-' 'Pull from Git//pullFromGit' 'Commit to Git ...//gitCommit' 'Push to Git//pushToGit' '-' '&Changes//projectChanges' 'Write ...//writeProject' 'Checkout Git Tag ...//checkoutTag' 'Checkout Git Branch ...//checkout' '-'  'Edit Components//editComponents' '-' 'Audit//auditProject' 'Git Log//projectLog' '&Refresh//refreshFromServer')!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil 328198 ##(Smalltalk.Point) 3601 1601 517 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 576 nil nil nil 5 nil nil nil 576 514 170 176 34 8 410 ##(Smalltalk.ContainerView) 34 15 nil 576 34 2 8 1140850688 131073 688 nil nil nil 5 nil nil nil 688 514 170 176 8 #() false 170 192 34 2 410 ##(Smalltalk.ListView) 34 45 nil 688 34 2 8 1409405261 1025 832 590662 2 ##(Smalltalk.ListModel) 138 144 784 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 327686 ##(Smalltalk.Color) #default nil 5 nil nil nil 832 nil 8 1728925920 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 1 920646 5 ##(Smalltalk.ListViewColumn) 8 'Column 1' 487 #left 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 1184 8 'doIt' 8 '[:each | each displayName]' 8 #[30 105 226 0 106] #displayName 1200 7 257 nil ##(Smalltalk.SortedCollection) nil nil 832 nil 3 1186 0 nil 1218 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 1296 7 257 nil 1186 0 nil 1218 3 1 1184 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 1376 7 257 nil #report 8 #() nil 133217 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 482 1 1 482 495 795 832 1538 #text: 34 1 8 'Column 1' 832 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 247 0 0 0 141 1 0 0] 8 #() 482 193 193 nil 35 8 'projectList' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 1 482 495 795 688 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 247 0 0 0 141 1 0 0] 34 1 832 1728 nil 27 524806 ##(Smalltalk.Fraction) 7 41 410 ##(Smalltalk.ContainerView) 34 15 nil 576 34 2 8 1140850688 131073 1952 nil nil nil 5 nil nil nil 1952 514 170 176 34 4 410 ##(Smalltalk.CardContainer) 34 16 nil 1952 34 2 8 1409286144 131073 2064 nil 992 nil 5 nil nil nil 2064 656710 1 ##(Smalltalk.CardLayout) 138 144 34 3 721414 ##(Smalltalk.Association) 8 'Category' 410 ##(Smalltalk.ListView) 34 45 nil 2064 34 2 8 1409372233 1025 2240 898 138 144 784 nil 960 992 nil 21 nil nil nil 2240 nil 8 1728925920 1026 #displayString 8 #() nil 1088 nil nil nil nil nil nil 138 144 34 1 1138 8 'Column 1' 467 #left 1026 #displayString 8 #() ##(Smalltalk.SortedCollection) 1186 0 nil 1218 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each]' 1779525917 2480 7 257 nil nil 2240 nil 3 nil nil #report 1456 nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1474 138 144 34 2 1538 #createAt:extent: 34 2 482 9 53 482 475 735 2240 1538 #text: 34 1 8 'Column 1' 2240 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 241 0 0 0 137 1 0 0] 8 #() 1728 nil 35 2194 8 'Package' 410 ##(Smalltalk.ListView) 34 45 nil 2064 34 2 8 1409372233 1025 2784 898 138 144 784 nil 960 992 nil 21 nil nil nil 2784 nil 8 1728925920 1026 #displayString 2368 nil 1088 nil nil nil nil nil nil 138 144 34 1 1138 8 'Packages' 467 #left 1026 #displayString 2464 ##(Smalltalk.SortedCollection) 1186 0 nil 1218 1 83886081 ##(Smalltalk.UndefinedObject) 2512 2528 1779525917 2992 7 257 nil nil 2784 nil 3 nil nil #report 1456 nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1474 138 144 34 2 1538 #createAt:extent: 34 2 482 9 53 482 475 735 2784 1538 #text: 34 1 8 'Packages' 2784 1666 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 241 0 0 0 137 1 0 0] 8 #() 1728 nil 35 2194 8 'Variable' 410 ##(Smalltalk.ListView) 34 45 nil 2064 34 2 8 1409372233 1025 3264 898 138 144 784 nil 960 992 nil 21 nil nil nil 3264 nil 8 1728925920 1026 #displayString 8 #() nil 1088 nil nil 1186 0 nil 1218 4 1 1184 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 3408 7 257 nil nil nil nil 138 144 34 1 1138 8 'Column 1' 467 #left 1026 #displayString 3392 ##(Smalltalk.SortedCollection) nil nil 3264 nil 3 nil 1186 0 nil 1218 4 1 1184 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 3568 7 257 nil #report 1456 nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1474 138 144 34 2 1538 #createAt:extent: 34 2 482 9 53 482 475 735 3264 1538 #text: 34 1 8 'Column 1' 3264 1666 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 241 0 0 0 137 1 0 0] 8 #() 1728 nil 35 2240 nil nil nil 170 192 34 6 2784 8 'packageMethodList' 2240 8 'categoryList' 3264 8 'variableList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 2064 34 2 8 1140916736 1 3936 898 138 144 34 3 2224 3248 2768 nil 960 nil nil 1 nil nil nil 3936 nil 8 1728696064 1186 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 4064 7 257 nil 1186 0 nil 4082 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 4128 7 257 nil 1088 nil nil nil nil nil #noIcons nil nil nil nil nil 1474 138 144 34 3 1538 #createAt:extent: 34 2 482 1 1 482 491 795 3936 1538 #setSingleSelection: 8 #(1) 3936 1538 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 3936 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 245 0 0 0 141 1 0 0] 8 #() 1728 nil 27 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 1 482 491 795 2064 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 245 0 0 0 141 1 0 0] 34 4 2240 3264 2784 3936 1728 nil 27 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 232 63 410 ##(Smalltalk.ContainerView) 34 15 nil 1952 34 2 8 1140850688 131073 4592 nil nil nil 5 nil nil nil 4592 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.PushButton) 34 20 nil 4592 34 2 8 1140858880 1 4720 nil 992 nil 5 nil nil nil 4720 nil 8 1728990640 1180998 4 ##(Smalltalk.CommandDescription) #gotoMethodDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 745 482 821 51 4720 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 116 1 0 0 154 1 0 0 141 1 0 0] 8 #() 1728 nil 29 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 5026 #fixedParentRight 1 5026 #fixedParentBottom -49 5072 1 410 ##(Smalltalk.ListView) 34 45 nil 4592 34 2 8 1409372233 1025 5088 898 138 144 784 nil 960 992 nil 13 nil nil nil 5088 nil 8 1728925920 1026 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 1088 nil nil nil nil nil nil 138 144 34 2 1138 8 '' 41 #left 1538 #empty 8 #() 16 1026 #<= 8 #() nil nil 5088 1186 0 nil 1218 2 1 1184 8 'doIt' 8 '[:each | each subSuperIcon]' 8 #[30 105 226 0 106] #subSuperIcon 5360 7 257 nil 1 nil nil 1138 8 'Selector' 773 #left 1026 #displayString 5216 ##(Smalltalk.SortedCollection) nil nil 5088 nil 3 nil 1186 0 nil 1218 5 1 1184 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 5488 7 257 nil #report 1456 nil 133221 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 55 482 821 691 5088 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 27 0 0 0 154 1 0 0 116 1 0 0] 8 #() 1728 nil 35 4994 5040 1 5056 1 5026 #fixedParentTop 55 5072 -49 410 ##(Smalltalk.TextEdit) 34 16 nil 4592 34 2 8 1140916352 1025 5760 nil 992 nil 5 nil nil nil 5760 nil 8 1728982448 852486 ##(Smalltalk.NullConverter) nil nil 3 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 1 482 821 51 5760 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 154 1 0 0 25 0 0 0] 8 #() 1728 nil 27 4994 5040 1 5056 1 5744 1 5744 51 170 192 34 6 4720 8 'definedPackageMethodText' 5088 8 'methodList' 5760 8 'categoryMethodText' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 501 1 482 821 795 4592 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 250 0 0 0 0 0 0 0 148 2 0 0 141 1 0 0] 34 3 5088 4720 5760 1728 nil 27 4562 8 0 0 0 0 0 0 244 63 false 170 192 34 2 2064 8 'methodFilterTabs' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 2281 1 482 1321 795 1952 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 116 4 0 0 0 0 0 0 8 7 0 0 141 1 0 0] 34 3 2064 410 ##(Smalltalk.Splitter) 34 12 nil 1952 34 2 8 1140850688 1 6512 nil 992 nil 517 nil nil nil 1510470 1 ##(Smalltalk.DraggableViewInteractor) 6512 nil 1 #left nil nil nil 482 1 1 482 9 9 nil 6608 nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 491 1 482 11 795 6512 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 245 0 0 0 0 0 0 0 250 0 0 0 141 1 0 0] 8 #() 1728 nil 27 4592 1728 nil 27 1922 5 11 410 ##(Smalltalk.ContainerView) 34 15 nil 576 34 2 8 1140850688 131073 6816 nil nil nil 5 nil nil nil 6816 514 170 176 784 false 170 192 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 6816 34 2 8 1140850688 131073 6944 nil nil nil 5 nil nil nil 6944 514 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 6944 34 2 8 1409286144 131073 7056 nil 992 nil 21 nil nil nil 7056 2130 138 144 784 nil nil nil nil 170 192 784 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 7056 34 2 8 1140916736 1 7168 898 138 144 784 nil 960 nil nil 17 nil nil nil 7168 nil 8 1728696064 1186 0 nil 4082 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 7280 7 257 nil 1186 0 nil 4082 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 7328 7 257 nil 1088 nil nil nil nil nil #noIcons nil nil nil nil nil 1474 138 144 34 2 1538 #createAt:extent: 34 2 482 1 1 482 545 795 7168 1538 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 7168 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 1 0 0 141 1 0 0] 8 #() 1728 nil 27 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 1 482 545 795 7056 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 1 0 0 141 1 0 0] 34 1 7168 1728 nil 27 3 false 170 192 34 2 7056 8 'packageDictionaryCards' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 555 1 482 545 795 6944 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 21 1 0 0 0 0 0 0 37 2 0 0 141 1 0 0] 34 1 7056 1728 nil 27 8 'packageDictionaryContainer' 410 ##(Smalltalk.ContainerView) 34 15 nil 6816 34 2 8 1140850688 131073 7952 nil nil nil 5 nil nil nil 7952 514 170 176 784 false 170 192 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 7952 34 2 8 1409286144 131073 8080 nil 992 nil 5 nil nil nil 8080 2130 138 144 34 1 2194 8 'Package Groups' 410 ##(Smalltalk.JadeiteTreeView) 34 28 nil 8080 34 2 8 1140916775 1025 8224 1049670 3 ##(Smalltalk.JadeiteTreeModel) nil 960 984070 ##(Smalltalk.JadeiteTreeNode) nil nil nil nil 170 192 784 992 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 1 984134 2 ##(Smalltalk.CommandMenuItem) 1 4802 #editPackageGroups 8 'Edit Package Groups ...' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 8224 nil 8 1728770064 1186 0 nil 1218 2 1 1024 8 'doIt' 8 '[:service | service displayString]' 8 #[30 105 226 0 106] #displayString 8512 7 257 nil ##(Smalltalk.IconicListAbstract) 1088 nil nil nil nil nil 170 176 784 33 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 784 nil 1474 138 144 34 2 1538 #createAt:extent: 34 2 482 9 53 482 529 735 8224 1538 #contextMenu: 34 1 8384 8224 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 12 1 0 0 137 1 0 0] 8 #() 1728 nil 27 8224 nil nil nil 170 192 34 2 8224 8 'packageGroupTree' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 8080 34 2 8 1140916736 1 8864 898 138 144 34 1 8208 nil 960 nil nil 1 nil nil nil 8864 nil 8 1728696064 1186 0 nil 4082 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 8992 7 257 nil 1186 0 nil 4082 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 9040 7 257 nil 1088 nil nil nil nil nil #noIcons nil nil nil nil nil 1474 138 144 34 3 1538 #createAt:extent: 34 2 482 1 1 482 545 795 8864 1538 #setSingleSelection: 8 #(1) 8864 1538 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 8864 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 1 0 0 141 1 0 0] 8 #() 1728 nil 27 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 1 482 545 795 8080 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 1 0 0 141 1 0 0] 34 2 8224 8864 1728 nil 27 8 'packageGroupsCards' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 1 482 545 795 7952 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 1 0 0 141 1 0 0] 34 1 8080 1728 nil 27 8 'packageGroupsContainer' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 505 1 482 1099 795 6816 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 252 0 0 0 0 0 0 0 33 3 0 0 141 1 0 0] 34 3 7952 410 ##(Smalltalk.Splitter) 34 12 nil 6816 34 2 8 1140850688 1 9824 nil 992 nil 517 nil nil nil 6578 9824 nil 1 #left nil nil nil 6608 6624 nil 6608 nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 545 1 482 11 795 9824 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 16 1 0 0 0 0 0 0 21 1 0 0 141 1 0 0] 8 #() 1728 nil 27 6944 1728 nil 27 1922 3 7 410 ##(Smalltalk.ContainerView) 34 15 nil 576 34 2 8 1140850688 131073 10080 nil nil nil 5 nil nil nil 10080 4658 170 176 34 6 410 ##(Smalltalk.CardContainer) 34 16 nil 10080 34 2 8 1409286144 131073 10192 nil 992 nil 5 nil nil nil 10192 2130 138 144 34 2 2194 590662 1 ##(Smalltalk.CardLabel) 8 'Classes' nil nil 410 ##(Smalltalk.ListView) 34 45 nil 10192 34 2 8 1409372237 1025 10368 898 138 144 784 nil 960 992 nil 29 nil nil nil 10368 nil 8 1728925920 1026 #displayString 8 #() nil 1088 nil nil nil nil nil nil 138 144 34 1 1138 8 '' 635 #left 1026 #displayString 8 #() 1026 #<= 8 #() nil nil 10368 nil 3 nil 1186 0 nil 1218 5 1 1184 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 10640 7 257 nil #report 1456 nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 9 53 482 643 635 10368 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 69 1 0 0 87 1 0 0] 8 #() 1728 nil 35 2194 10322 8 'Hierarchy' nil nil 410 ##(Smalltalk.JadeiteTreeView) 34 28 nil 10192 34 2 8 1140920871 1025 10928 8290 nil 1310726 ##(Smalltalk.EqualitySearchPolicy) 8322 nil nil nil nil 170 176 784 992 nil 29 nil nil nil 10928 nil 8 1728770064 1186 0 nil 1218 2 1 1184 8 'doIt' 8 '[:each | each displayString]' 8 #[30 105 226 0 106] #displayString 11088 7 257 nil ##(Smalltalk.IconicListAbstract) 1088 nil 1186 0 nil 1218 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 11168 7 257 nil 1186 0 nil 1218 5 1 1184 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 11248 7 257 nil nil nil 170 176 784 33 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 784 nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 9 53 482 643 635 10928 1666 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 69 1 0 0 87 1 0 0] 8 #() 1728 nil 27 10368 nil nil nil 170 192 34 4 10368 8 'classList' 10928 8 'classHierarchy' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 10192 34 2 8 1140916736 1 11584 898 138 144 34 2 10336 10896 nil 960 nil nil 1 nil nil nil 11584 nil 8 1728696064 1186 0 nil 4082 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 11712 7 257 nil 1186 0 nil 4082 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 11760 7 257 nil 1088 nil nil nil nil nil #smallIcons nil nil nil nil nil 1474 138 144 34 3 1538 #createAt:extent: 34 2 482 1 1 482 659 695 11584 1538 #setSingleSelection: 8 #(1) 11584 1538 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 11584 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 73 1 0 0 91 1 0 0] 8 #() 1728 nil 27 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 1 482 659 695 10192 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 73 1 0 0 91 1 0 0] 34 3 10368 10928 11584 1728 nil 27 4994 5040 1 5056 1 5744 1 5072 -99 410 ##(Smalltalk.PushButton) 34 20 nil 10080 34 2 8 1140858880 1 12208 nil 978 #silver nil 5 nil nil nil 12208 nil 8 1728990640 4802 #gotoClassDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 745 482 659 51 12208 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 116 1 0 0 73 1 0 0 141 1 0 0] 8 #() 1728 nil 29 4994 5040 1 5056 1 5072 -49 5072 1 410 ##(Smalltalk.CardContainer) 34 16 nil 10080 34 2 8 1409286144 131073 12496 nil 992 nil 5 nil 263174 ##(Smalltalk.Font) nil true 524550 ##(Smalltalk.LOGFONTW) 8 #[240 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 188 2 0 0 0 0 0 0 1 2 1 34 83 0 121 0 115 0 116 0 101 0 109 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 12496 2130 138 144 34 2 2194 10322 8 'Class' nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 12496 34 2 8 1140850688 131073 12752 nil nil nil 5 nil nil nil 12752 nil 170 192 784 nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 9 9 482 643 1 12752 1666 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 69 1 0 0 4 0 0 0] 8 #() 1728 nil 27 2194 10322 8 'Instance' nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 12496 34 2 8 1140850688 131073 13040 nil nil nil 5 nil nil nil 13040 nil 170 192 784 nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 9 9 482 643 1 13040 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 69 1 0 0 4 0 0 0] 8 #() 1728 nil 27 13040 nil nil nil 170 192 34 4 13040 8 'instanceTab' 12752 8 'classTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 12496 34 2 8 1140916738 1 13344 898 138 144 34 2 13008 12720 nil 960 nil nil 1 nil nil nil 13344 nil 8 1728696064 1186 0 nil 4082 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 13472 7 257 nil 1186 0 nil 4082 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 13520 7 257 nil 1088 nil nil nil nil nil #smallIcons nil nil nil nil nil 1474 138 144 34 3 1538 #createAt:extent: 34 2 482 1 1 482 659 51 13344 1538 #setSingleSelection: 8 #(1) 13344 1538 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 13344 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 73 1 0 0 25 0 0 0] 8 #() 1728 nil 27 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 695 482 659 51 12496 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 91 1 0 0 73 1 0 0 116 1 0 0] 34 3 13040 12752 13344 1728 nil 27 4994 5040 1 5056 1 5072 -99 5026 #fixedViewTop 51 170 192 34 6 10192 8 'classHierarchyTabs' 12208 8 'definedPackageClassText' 12496 8 'instanceClassTabs' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1613 1 482 659 795 10080 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 38 3 0 0 0 0 0 0 111 4 0 0 141 1 0 0] 34 3 10192 12496 12208 1728 nil 27 1922 3 11 false 170 192 34 6 688 8 'projectListContainer' 6816 8 'componentPackageContainer' 10080 8 'classContainer' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 1 482 3601 795 576 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 8 7 0 0 141 1 0 0] 34 7 688 410 ##(Smalltalk.Splitter) 34 12 nil 576 34 2 8 1140850688 1 14480 nil 992 nil 517 nil nil nil 6578 14480 nil 1 #left nil nil nil 6608 6624 nil 6608 nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 495 1 482 11 795 14480 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 247 0 0 0 0 0 0 0 252 0 0 0 141 1 0 0] 8 #() 1728 nil 27 6816 410 ##(Smalltalk.Splitter) 34 12 nil 576 34 2 8 1140850688 1 14720 nil 992 nil 517 nil nil nil 6578 14720 nil 1 #left nil nil nil 6608 6624 nil 6608 nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1603 1 482 11 795 14720 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 33 3 0 0 0 0 0 0 38 3 0 0 141 1 0 0] 8 #() 1728 nil 27 10080 410 ##(Smalltalk.Splitter) 34 12 nil 576 34 2 8 1140850688 1 14960 nil 992 nil 517 nil nil nil 6578 14960 nil 1 #left nil nil nil 6608 6624 nil 6608 nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 2271 1 482 11 795 14960 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 111 4 0 0 0 0 0 0 116 4 0 0 141 1 0 0] 8 #() 1728 nil 27 1952 1728 nil 27 25 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 15200 nil nil nil 5 nil nil nil 15200 4658 170 176 34 4 410 ##(Smalltalk.CardContainer) 34 16 nil 15200 34 2 8 1409286144 131073 15312 nil 992 nil 5 nil nil nil 15312 2130 138 144 34 5 2194 10322 8 'SUnit' 1186 0 nil 1218 4 1 1184 8 'doIt' 8 '[Icon fromId: ''icons\UnitTestPlugin.ico'']' 8 #[32 105 45 30 178 106] 983558 ##(Smalltalk.VariableBinding) #Icon ##(Smalltalk.Icon) 8 'icons\UnitTestPlugin.ico' #fromId: 15472 7 1 nil nil 410 ##(Smalltalk.ReferenceView) 34 14 nil 15312 34 2 8 1140850688 131073 15600 nil 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 nil nil nil 15600 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteSUnitInClassPresenter) #resource_Default_view nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 9 53 482 3585 697 15600 1666 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 4 7 0 0 118 1 0 0] 784 1728 nil 27 2194 10322 8 'Class Definition' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 15312 34 2 8 1445007428 1025 15920 721990 2 ##(Smalltalk.ValueHolder) nil false 11024 nil 15666 26337781 nil 5 8370 nil true 34 11 8418 1 4802 #editSave 8 '&Save' 9383 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 8418 1 4802 #editUndo 8 '&Undo' 9397 1 nil nil nil 8418 1 4802 #editRedo 8 '&Redo' 9395 1 nil nil nil 16114 4097 8418 1 4802 #editCut 8 'Cu&t' 9393 1 nil nil nil 8418 1 4802 #editCopy 8 '&Copy' 9351 1 nil nil nil 8418 1 4802 #editPaste 8 '&Paste' 9389 1 nil nil nil 8418 1 4802 #editDelete 8 '&Delete' 1629 1 nil nil nil 16114 4097 8418 1 4802 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 12562 nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 15920 nil 8 1468939752 5842 nil nil 13 1428439825 170 192 34 4 #callTip 1182790 1 ##(Smalltalk.ScintillaTextStyle) 77 978 #gray 978 #white 1 nil nil nil nil #callTip nil nil nil #normal 16674 1 nil nil 1 nil nil nil nil #normal nil nil nil nil 1639686 ##(Smalltalk.SmalltalkExpressionStyler) 1 nil nil false 138 144 784 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 15920 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 784 nil 170 176 784 9215 nil nil nil nil 12272 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #literalArray 8 '()' #specialCharacter 8 '()[]<>' 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 16736 nil nil nil nil 16 nil 170 192 34 6 1 1510470 3 ##(Smalltalk.ScintillaIndicatorStyle) 1 15920 15666 65025 3 false 1 nil nil nil nil nil nil 3 17090 3 15920 978 #blue 5 false 3 nil nil nil nil nil nil 5 17090 5 15920 978 #red 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 16674 1027 15666 60239 15666 31326207 1 nil nil nil nil #Warning nil nil nil #Error 16674 1031 15666 335 15666 31317503 1 nil nil nil nil #Error nil nil nil #Notification 16674 1029 nil 15666 31185883 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1474 138 144 34 9 1538 #createAt:extent: 34 2 482 9 53 482 3585 697 15920 1538 #contextMenu: 34 1 16032 15920 1538 #caretPeriod: 8 #(530) 15920 1538 #wordWrap: 8 #(true) 15920 1538 #margins: 34 1 34 3 985158 3 ##(Smalltalk.ScintillaMargin) 1 15920 1 3 nil nil 5 nil 17618 3 15920 33 nil 3 67108863 5 nil 17618 5 15920 1 nil 3 -67108863 5 nil 15920 1538 #tabWidth: 8 #(4) 15920 1538 #targetRange: 34 1 525062 ##(Smalltalk.Interval) 1 -1 3 15920 1538 #maxCompletionListHeight: 8 #(9) 15920 1538 #edgeColumn: 8 #(1) 15920 1666 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 4 7 0 0 118 1 0 0] 8 #() 1728 nil 33 2194 10322 8 'Class Documentation' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 15312 34 2 8 1445007428 1025 17936 15986 nil false 11024 nil 15666 26337781 nil 5 8370 nil true 34 1 8418 1 4802 #editSaveClassComment 8 'Save' 1025 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 12562 nil true 16546 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 17936 nil 8 1468939752 5842 nil nil 15 1428487873 170 192 34 4 #callTip 16674 77 16704 16720 1 nil nil nil nil #callTip nil nil nil #normal 16674 1 nil nil 1 nil nil nil nil #normal nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 16834 1 nil nil nil 17936 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 784 nil 170 176 784 9215 nil nil nil nil 12272 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 18272 nil nil nil nil 16 nil 170 192 34 6 1 17090 1 17936 15666 65025 3 false 1 nil nil nil nil nil nil 3 17090 3 17936 17152 5 false 3 nil nil nil nil nil nil 5 17090 5 17936 17184 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 16674 1027 15666 60239 15666 31326207 1 nil nil nil nil #Warning nil nil nil #Error 16674 1031 15666 335 15666 31317503 1 nil nil nil nil #Error nil nil nil #Notification 16674 1029 nil 15666 31185883 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1474 138 144 34 10 1538 #createAt:extent: 34 2 482 9 53 482 3585 697 17936 1538 #contextMenu: 34 1 18032 17936 1538 #hoverTime: 8 #(1000000) 17936 1538 #caretPeriod: 8 #(530) 17936 1538 #wordWrap: 8 #(true) 17936 1538 #margins: 34 1 34 3 17618 1 17936 1 3 nil nil 5 nil 17618 3 17936 33 nil 3 67108863 5 nil 17618 5 17936 1 nil 3 -67108863 5 nil 17936 1538 #tabWidth: 8 #(4) 17936 1538 #targetRange: 34 1 17746 1 -1 3 17936 1538 #maxCompletionListHeight: 8 #(9) 17936 1538 #edgeColumn: 8 #(1) 17936 1666 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 4 7 0 0 118 1 0 0] 8 #() 1728 nil 33 2194 10322 8 'Method Source' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 15312 34 2 8 1445007428 1025 19312 15986 nil false 11024 nil 15666 26337781 nil 5 nil 12562 nil true 16546 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 19312 nil 8 1468939752 5842 nil nil 13 1428474769 170 192 34 4 #callTip 16674 77 16704 16720 1 nil nil nil nil #callTip nil nil nil #normal 16674 1 nil nil 1 nil nil nil nil #normal nil nil nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 784 170 192 34 2 #default 16834 1 nil nil nil 19312 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 784 nil 170 176 784 9215 nil nil nil nil 12272 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #literalArray 8 '()' #specialCharacter 8 '()[]<>' 8 '' 3 170 192 34 2 #container 170 192 34 4 #callTip 19536 #normal 19552 nil nil nil nil 16 nil 170 192 34 12 1 17090 1 19312 15666 65025 3 false 1 nil nil nil nil nil nil 8 'indicator9' 17090 19 19312 17184 13 nil nil nil nil nil nil nil nil 8 'indicator10' 17090 21 19312 17184 3 nil nil nil nil nil nil nil nil 3 17090 3 19312 17152 5 false 3 nil nil nil nil nil nil 8 'indicator8' 17090 17 19312 12272 1 nil nil nil nil nil nil nil nil 5 17090 5 19312 17184 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 16674 1027 15666 60239 15666 31326207 1 nil nil nil nil #Warning nil nil nil #Error 16674 1031 15666 335 15666 31317503 1 nil nil nil nil #Error nil nil nil #Notification 16674 1029 nil 15666 31185883 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1474 138 144 34 9 1538 #createAt:extent: 34 2 482 9 53 482 3585 697 19312 1538 #hoverTime: 8 #(500) 19312 1538 #caretPeriod: 8 #(530) 19312 1538 #wordWrap: 8 #(true) 19312 1538 #margins: 34 1 34 3 17618 1 19312 61 3 nil nil 5 nil 17618 3 19312 1 nil 3 67108863 nil nil 17618 5 19312 1 nil 3 -67108863 nil nil 19312 1538 #tabWidth: 8 #(4) 19312 1538 #targetRange: 34 1 17746 1 -1 3 19312 1538 #maxCompletionListHeight: 8 #(9) 19312 1538 #edgeColumn: 8 #(1) 19312 1666 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 4 7 0 0 118 1 0 0] 8 #() 1728 nil 33 2194 10322 8 'Comparison' nil nil 410 ##(Smalltalk.ShellView) 34 27 nil 15312 34 2 8 1078919168 131073 20752 nil 992 nil 517 nil nil nil 20752 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 20752 34 2 8 1140850688 131073 20848 nil 15666 26337781 nil 5 8370 nil true 34 5 8418 1 4802 #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 8418 1 4802 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 8418 1 4802 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 8418 1 4802 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 8418 1 4802 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 20848 514 170 176 784 false 170 192 784 nil 1474 138 144 34 2 1538 #createAt:extent: 34 2 482 1 1 482 3553 665 20848 1538 #contextMenu: 34 1 20928 20848 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 240 6 0 0 76 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 20848 34 2 8 1140850688 131073 21456 nil 992 nil 5 nil nil nil 21456 20818 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 21456 34 2 8 1140850945 262145 21536 nil nil nil 21 nil nil nil 21536 nil 8 1728838848 5842 nil nil nil 1474 138 144 34 2 1538 #createAt:extent: 34 2 482 1 625 482 1771 41 21536 1538 #text: 34 1 8 '
' 21536 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 117 3 0 0 76 1 0 0] 8 #() 1728 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 21456 34 2 8 1140920580 1025 21840 15986 nil false 11024 nil 15666 26337781 nil 21 nil nil nil 21840 nil 8 1468939752 5842 nil nil 13 1428466033 170 192 34 12 #whitespace 16674 3 978 #teal nil 1 nil nil nil nil #whitespace nil nil nil #diff 16674 5 nil 15666 16908287 3 nil nil nil nil #diff nil 1401 nil #lineNumber 16674 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #normal 16674 1 nil nil 1 nil nil nil nil #normal nil nil nil #indentGuide 16674 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #callTip 16674 77 16704 16720 1 nil nil nil nil #callTip nil nil nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 16834 1 nil nil nil 21840 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 784 nil 170 176 784 9215 nil nil nil nil 12272 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #literalArray 8 '()' #specialCharacter 8 '()[]<>' 8 '' 3 170 192 34 2 #container 21968 nil nil nil nil 16 nil 170 192 34 2 #diff 17090 1 21840 978 #yellow 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 16674 1027 15666 60239 15666 31326207 1 nil nil nil nil #Warning nil nil nil #Error 16674 1031 15666 335 15666 31317503 1 nil nil nil nil #Error nil nil nil #Notification 16674 1029 nil 15666 31185883 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1474 138 144 34 8 1538 #createAt:extent: 34 2 482 1 1 482 1771 625 21840 1538 #caretPeriod: 8 #(530) 21840 1538 #wordWrap: 8 #(true) 21840 1538 #margins: 34 1 34 3 17618 1 21840 49 3 nil nil nil nil 17618 3 21840 1 nil nil 67108863 nil nil 17618 5 21840 1 nil nil nil nil nil 21840 1538 #canHScroll: 8 #(false) 21840 1538 #targetRange: 34 1 17746 1 -1 3 21840 1538 #maxCompletionListHeight: 8 #(9) 21840 1538 #edgeColumn: 8 #(1) 21840 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 117 3 0 0 56 1 0 0] 8 #() 1728 nil 33 170 192 34 4 21536 8 'beforeTitle' 21840 8 'before' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 1 482 1771 665 21456 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 117 3 0 0 76 1 0 0] 34 2 21840 21536 1728 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 20848 34 2 8 1140850688 1 23296 nil 15666 66047 nil 517 nil nil nil 6578 23296 nil 1 #left nil nil nil 6608 6624 nil 6608 nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1771 1 482 11 665 23296 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 117 3 0 0 0 0 0 0 122 3 0 0 76 1 0 0] 8 #() 1728 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 20848 34 2 8 1140850688 131073 23552 nil 992 nil 5 nil nil nil 23552 20818 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 23552 34 2 8 1140850945 262145 23632 nil nil nil 21 nil nil nil 23632 nil 8 1728838848 5842 nil nil nil 1474 138 144 34 2 1538 #createAt:extent: 34 2 482 1 625 482 1773 41 23632 1538 #text: 34 1 8 '
' 23632 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 118 3 0 0 76 1 0 0] 8 #() 1728 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 23552 34 2 8 1140920580 1025 23936 15986 nil false 11024 nil 15666 26337781 nil 21 nil nil nil 23936 nil 8 1468939752 5842 nil nil 13 1428492241 170 192 34 12 #whitespace 16674 3 22016 nil 1 nil nil nil nil #whitespace nil nil nil #diff 16674 5 nil 15666 16908287 3 nil nil nil nil #diff nil 1401 nil #lineNumber 16674 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #normal 16674 1 nil nil 1 nil nil nil nil #normal nil nil nil #indentGuide 16674 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #callTip 16674 77 16704 16720 1 nil nil nil nil #callTip nil nil nil nil 22130 22160 170 192 34 2 #default 16834 1 nil nil nil 23936 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 784 nil 170 176 784 9215 nil nil nil nil 12272 nil nil 65 nil nil 22256 22336 3 170 192 34 2 #container 24064 nil nil nil nil 16 nil 170 192 34 2 #diff 17090 1 23936 22432 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 16674 1027 15666 60239 15666 31326207 1 nil nil nil nil #Warning nil nil nil #Error 16674 1031 15666 335 15666 31317503 1 nil nil nil nil #Error nil nil nil #Notification 16674 1029 nil 15666 31185883 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1474 138 144 34 8 1538 #createAt:extent: 34 2 482 1 1 482 1773 625 23936 1538 #caretPeriod: 8 #(530) 23936 1538 #wordWrap: 8 #(true) 23936 1538 #margins: 34 1 34 3 17618 1 23936 49 3 nil nil nil nil 17618 3 23936 1 nil nil 67108863 nil nil 17618 5 23936 1 nil nil nil nil nil 23936 1538 #canHScroll: 8 #(false) 23936 1538 #targetRange: 34 1 17746 1 -1 3 23936 1538 #maxCompletionListHeight: 8 #(9) 23936 1538 #edgeColumn: 8 #(1) 23936 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 118 3 0 0 56 1 0 0] 8 #() 1728 nil 33 170 192 34 4 23936 8 'after' 23632 8 'afterTitle' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1781 1 482 1773 665 23552 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 122 3 0 0 0 0 0 0 240 6 0 0 76 1 0 0] 34 2 23936 23632 1728 nil 27 1728 nil 27 170 192 34 2 20848 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 8370 nil true 34 4 8418 1 4802 #selectUpper 8 'Select &upper' 1 1 nil nil nil 8418 1 4802 #selectLower 8 'Select &lower' 1 1 nil nil nil 16114 4097 8418 1 4802 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 18697 nil nil 8370 nil true 34 3 8418 1 4802 #character 8 '&Character' 1 1 nil nil nil 8418 1 4802 #word 8 '&Word' 1 1 nil nil nil 8418 1 4802 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 18699 nil nil 8370 nil true 34 1 8418 1 4802 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 18701 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1474 138 144 34 2 1538 #createAt:extent: 34 2 482 9 53 482 3585 697 20752 1538 #text: 34 1 8 'Comparison' 20752 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 4 7 0 0 118 1 0 0] 34 1 20848 1728 nil 27 20752 nil nil nil 170 192 34 10 20752 8 'comparisonTab' 15920 8 'classDefinition' 15600 8 'sunit' 17936 8 'classDocumentation' 19312 8 'methodSource' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 15312 34 2 8 1140916736 1 26160 898 138 144 34 5 15888 17904 19280 15440 20720 nil 960 nil nil 1 nil nil nil 26160 nil 8 1728696064 1186 0 nil 4082 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 26288 7 257 nil 1186 0 nil 4082 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 26336 7 257 nil 1088 nil nil nil nil nil #smallIcons nil nil nil nil nil 1474 138 144 34 3 1538 #createAt:extent: 34 2 482 1 1 482 3601 757 26160 1538 #setSingleSelection: 8 #(5) 26160 1538 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 26160 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 8 7 0 0 122 1 0 0] 8 #() 1728 nil 27 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 1 482 3601 757 15312 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 8 7 0 0 122 1 0 0] 34 6 15920 17936 19312 15600 20752 26160 1728 nil 27 4994 5040 1 5056 1 5744 1 5072 -39 410 ##(Smalltalk.ContainerView) 34 15 nil 15200 34 2 8 1140850688 131073 26784 nil nil 482 2241 43 517 nil nil nil 26784 4658 170 176 34 4 410 ##(Smalltalk.ToolButton) 34 14 nil 26784 34 2 8 1140850688 131073 26912 nil nil nil 1029 nil nil nil 26912 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 26912 34 2 8 1140853580 131137 26976 nil nil 482 43 43 513 nil nil nil 26976 nil 8 1728949632 nil 170 192 34 2 15651 1115206 1 ##(Smalltalk.ToolbarIconButton) 26976 1 4802 #flipAutoCommit 8 'Auto Commit' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons/camera16_light_icon.ico' nil 15651 34 1 27120 nil nil 3 nil 482 33 33 482 33 33 nil nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 1 482 43 43 26976 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 8 #() 1728 nil 27 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 1 482 43 43 26912 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 34 1 26976 1728 nil 27 4994 5040 1 5026 #fixedViewLeft 43 5744 1 13968 43 410 ##(Smalltalk.TextEdit) 34 16 nil 26784 34 2 8 1140850688 1 27648 nil 992 482 2199 43 517 nil 12562 nil true 16546 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 482 193 193 nil 27648 978 #black 8 1728982448 5842 nil nil 67 1474 138 144 34 2 1538 #createAt:extent: 34 2 482 43 1 482 3559 41 27648 1538 #setMarginWidths: 34 1 8 #(3 3) 27648 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 21 0 0 0 0 0 0 0 8 7 0 0 20 0 0 0] 8 #() 1728 nil 27 4994 5040 43 5056 1 5744 1 5072 1 170 192 34 4 26912 8 'autoCommitButton' 27648 8 'statusBarField' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 757 482 3601 41 26784 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 122 1 0 0 8 7 0 0 142 1 0 0] 34 2 26912 27648 1728 nil 27 4994 5040 1 5056 1 5072 -39 5072 1 170 192 34 2 15312 8 'textAreaTabs' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 805 482 3601 797 15200 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 146 1 0 0 8 7 0 0 32 3 0 0] 34 2 15312 26784 1728 nil 27 25 true 170 192 34 2 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 28544 nil 992 nil 517 nil nil nil 6578 28544 nil 1 #left nil nil nil 6608 6624 nil 6608 nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 1 795 482 3601 11 28544 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 141 1 0 0 8 7 0 0 146 1 0 0] 8 #() 1728 nil 27 8 'splitter' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 482 6859 21 482 3601 1601 416 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 101 13 0 0 10 0 0 0 109 20 0 0 42 3 0 0] 34 3 576 28544 15200 1728 nil 27 )! !
!JadeiteBrowserPresenter class categoriesForMethods!
defaultAdditionalAccelerators!constants!public! !
projectMenu!menus!public! !
projectMenuStrings!menus!public! !
resource_Default_view!public!resources-views! !
!

