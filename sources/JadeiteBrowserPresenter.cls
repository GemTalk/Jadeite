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

aboutToChange: aSelectionChangingEvent
	aSelectionChangingEvent value ifTrue: [
		aSelectionChangingEvent value: self isOkayToChange.
		self resetCategoryText.
	].
	
!

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

addMethodCategory
	| string |
	(string := Prompter prompt: 'New method category?') isNil ifTrue: [^self].
	string trimBlanks isEmpty ifTrue: [^MessageBox notify: 'Category name must not be blank'].
	self basicAddMethodCategory: string!

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

addVariableAccessors
	self confirmOverwriteAccessor ifFalse: [^self].
	self basicAddVariableAccessors!

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

basicAddMethodCategory: string
	| service |
	(self categoryListPresenter list includes: string)
		ifFalse: 
			[service := self selectedClass
						command: #addCategory:;
						commandArgs: (Array with: string).
			service meta: self isClassSideSelected.
			self issueCommand: service].
	self selectCategoriesNamed: (Array with: string)!

basicAddVariableAccessors
	| cachedSelections |
	(cachedSelections := self methodFilterListPresenter selections) do: 
			[:variable |
			| sourceStream classService |
			classService := self selectedClass.
			sourceStream := self getterMethodSourceFor: variable.
			classService
				saveMethod: sourceStream contents
				category: 'accessing'
				session: self gciSession.
			sourceStream := self setterMethodSourceFor: variable.
			classService
				saveMethod: sourceStream contents
				category: 'accessing'
				session: self gciSession].
	self methodFilterListPresenter selections: cachedSelections!

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
				projectService: (projectListPresenter selectionIfNone: [RowanProjectService noneProject]).
	addPackagePresenter parentPresenter: projectInfoTab.
	addPackageView := addPackagePresenter createView: 'Default view'.
	addPackageView
		arrangement: 1;
		backcolor: JadeiteTextStyles default colorForNoEdits.
	projectInfoTab view addSubView: addPackageView.
	addPackagePresenter
		when: #packageAdded:
		send: #selectNewPackage:
		to: self.
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

buildPackageList
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
	packageListPresenter view isDropTarget: true!

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

buildProjectInfoTab: infoTab
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
		getContentsBlock: [:each | (each at: 1) prettyPrintInstVar: (each at: 2)].
	infoTabView addColumn.
	(infoTabView allColumns at: 2)
		isEditable: false;
		isAutoResize: true;
		getContentsBlock: 
				[:each |
				(each at: 2)
					ifNil: [String new]
					ifNotNil: 
						[:iv |
						| service |
						service := each at: 1.
						iv = 'isDirty' ifTrue: [service toolTip] ifFalse: [service instVarNamed: iv]]].
	infoTabView getImageBlock: nil.
	^infoTabView!

buildProjectListView
	| listView |
	projectInfoList := ListPresenter new.
	projectInfoList parentPresenter: projectInfoTab.
	listView := self buildProjectInfoTab: projectInfoList.
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
	self selectedProjectName ifNotNil: [self updateProjectReadMe].
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
		'&File out categories ...//fileOutCategories'
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

classContainer
	^classContainer!

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
	menuStrings := #('&Classes' '&Browse Class References//browseClassReferences' 'Browse SUnit//showSUnitBrowserOnClass' 'Add &Subclass//addSubclass' '&Rename ... //renameClass' 'Copy ...//copyClass' '&Remove//removeClass' '-')
				asOrderedCollection.
	menuStrings add: '&Expand Full Hierarchy//expandFullHierarchy'.
	menuStrings add: '-'.
	menuStrings addLast: 'Move To Package ...//moveClassToPackage'.
	menuStrings add: '-'.
	menuStrings addLast: definedLabel , '//gotoClassDefinedPackage'.
	menuStrings addLast: containedDictionaryLabel , '//gotoDictionary'.
	menuStrings addLast: '&File Out Class ...//fileOutClass'.

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

componentPackageContainer
	^componentPackageContainer!

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
		getImageBlock: nil;
		hasGridLines: false.
	(listView allColumns at: 1)
		isEditable: false;
		getImageBlock: nil;
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
		to: self.
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
	0 == 1 ifTrue: [(self
				addDictionary;
				removeDictionaries) fileOutDictionaries].
	^#('Dictionaries' 'Insert Dictionary//addDictionary' 'Remove Dictionaries//removeDictionaries' '-' 'File Out Selected Dictionaries ...//fileOutDictionaries')!

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

editLoadSpecFromFile
	^JadeiteLoadSpecEditor editLoadSpecFromFileInSession: gciSession!

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
			on: GsApplicationError
			do:  
				[:ex |
				('*poolDictionaries not supported yet*' match: ex description)
					ifTrue: [^MessageBox notify: 'Pool Dictionaries not supported yet'].
				^self showMethodRecompilationError: ex].
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
				command: #write:;
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
	self selectClassHierarchyTab.
	self selectClassInClassHierarchyNamed: self selectedClass. 
	self expandFullAt: self selectedClass. 
	classHierarchyPresenter view ensureSelectionVisible!

fileOutCategories
	| path className |
	className := self selectedClassName ifNil: [^self].
	path := JadeiteServerFileSaveDialog showOnSession: gciSession initialFileName: className , '-categories.gs'.
	path ifNotNil: [self fileOutCategoriesOnPath: path]!

fileOutCategoriesOnPath: path
	| service |
	service := self selectedClass.
	service
		command: #fileoutCategories:on:;
		commandArgs: (Array with: categoryListPresenter selections with: path).
	self issueCommand: service!

fileOutClass
	| path className |
	className := self selectedClassName ifNil: [^self].
	path := JadeiteServerFileSaveDialog showOnSession: gciSession initialFileName: className , '.gs'.
	path ifNotNil: [self fileOutClassOnPath: path]!

fileOutClassOnPath: path
	| service |
	service := self selectedClass.
	service command: #fileoutClassOn:; commandArgs: (Array with: path).
	self issueCommand: service!

fileOutDictionaries
	| path |
	self selectedDictionaryNames isEmpty ifTrue: [^self]. 
	path := JadeiteServerFileSaveDialog showOnSession: gciSession initialFileName: 'dictionaries.gs'.
	path ifNotNil: [self fileOutDictionariesOnPath: path]!

fileOutDictionariesOnPath: path
	| service |
	service := RowanFileService new
				path: path;
				session: gciSession.
	service fileOutDictionaries: self selectedDictionaryNames!

fileOutMethodsOnPath: path
	| service |
	service := RowanFileService new
				path: path;
				session: gciSession.
	service fileOutMethods: methodListPresenter selections!

fileOutSelectedMethods
	| path |
	self methodListPresenter selections isEmpty ifTrue: [^self].
	self selectedClassName ifNil: [^self].
	path := JadeiteServerFileSaveDialog showOnSession: gciSession
				initialFileName: self selectedClassName , '-methods.gs'.
	path ifNotNil: [self fileOutMethodsOnPath: path]!

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
	self refreshFromServer.
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

gotoPackageDictionary
	| selectedPackage dictionaryService |
	selectedPackage := packageListPresenter selectionIfNone: [^MessageBox notify: 'No Package Selected'].
	self selectNoneProject.
	dictionaryService := dictionaryPresenter list
				detect: [:service | service name = selectedPackage dictionaryName]
				ifNone: [^self].
	dictionaryPresenter selections: (Array with: dictionaryService)!

hasCategorySelected

	^categoryListPresenter selections notEmpty!

hasExactlyOneCategorySelected

	^categoryListPresenter selections size = 1!

hasMethods
	^true!

hidePackageGroups
	componentPackageContainer view arrangement: 1/5.
	packageDictionaryContainer view arrangement: 100. 
	projectListContainer view arrangement: 1/5. 
	classContainer view arrangement: 1/5. 
	packageGroupPresenter view creationParentView hide!

hidePackageList
	componentPackageContainer view arrangement: 1 / 6.
	packageDictionaryContainer view hide!

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

isClassHierarchyTabSelected
	^classHierarchyTabs currentCard name = 'classHierarchy'!

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
	self selectedProjectName = RowanProjectService noneProject name ifTrue: [^false].
	(#(#unloadProjects #reloadProject) includes: command)
		ifTrue: 
			[^self selectedProjectName isNil
				ifTrue: [false]
				ifFalse: [('UnPackaged' = self selectedProjectName) not]].
	^projectListPresenter selections isEmpty not!

isRowanProjectSelected
	^(self isNoneProjectSelected or: [projectListPresenter selections isEmpty]) not!

isSourceTabSelected

	^textAreaTabs currentCard name = 'methodSource'.
!

isSunitTabSelected
	^self textAreaTabs currentCard name = 'sunit'!

jadeDebug
	BrowserUpdate current inUpdateWhile: [self jadeExecuteAndDisplay: false shouldDebug: true]!

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
				fileOutSelectedMethods;
				findMethod;
				moveMethodToPackage;
				removeMethods;
				runMethodTests;
				gotoMethodDefinedPackage;
				runAll;
				runSelected].
	^#('&Methods' 'Browse &Implementors//browseImplementors' 'Browse Implementors of ...//browseImplementorsOf' 'Browse &Senders//browseSenders' 'Browse Senders of ...//browseSendersOf' '-' 'Browse Hierarchy Implementors//browseHierarchyImplementors' 'Browse Hierarchy Senders//browseHierarchySenders' '-' 'Browse Methods &Containing ...//browseMethodsContaining' 'Browse Literal References ...//browseLiteralReferences' 'Browse Selected Methods//browseSelectedMethods' 'Browse Method History//browseMethodHistory' 'Inspect//inspectMethod' '-' 'Browse Breakpoints//browseBreakpoints' 'Clear Method Breakpoints//clearMethodBreakpoints' '-' 'Find Method .../Ctrl+Shift+M/findMethod' '-' '&Remove Method(s) .../Ctrl+Shift+X/removeMethods' 
	'-'
	'Move To Package ...//moveMethodToPackage'
	'File Out Selected Methods ...//fileOutSelectedMethods'
	'-'
	'Run All Tests/Ctrl+Shift+A/runAll' 'Run Selected Test(s)/Ctrl+Shift+S/runMethodTests' 'Debug Selected &Test(s)/Ctrl+Shift+B/runMethodTests' '-' 'Go To Defining Package//gotoMethodDefinedPackage')!

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
	self selectedClass ifNil: [^self].
	self selectedClass
		command: #moveToPackageNamed:;
		commandArgs: (Array with: packageName).
	self issueCommand: self selectedClass.
	self updateAfterFindClass: self selectedClass!

moveMethods: methodServices toCategory: targetCategory
	| classService |
	classService := self selectedClass.
	self selectCategoriesNamed: (categoryListPresenter selections copyWith: targetCategory).
	classService
		command: #moveMethods:to:;
		commandArgs: (Array with: methodServices with: targetCategory).
	self issueCommand: classService.
	self selectMethodsFrom: classService!

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
	^self onDragClass: aSession className: self selectedClass!

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
	self buildPackageList.
	self
		buildProjectTab;
		buildProjectReadMeTab.
	self selectProjectTab.
	JadePresenter packageListVisible ifTrue: [self showPackageList] ifFalse: [self hidePackageList].
	JadePresenter packageGroupsVisible
		ifTrue: [self showPackageGroups]
		ifFalse: [self hidePackageGroups].!

openJadeiteProjectsBrowser
	^self addSystemBrowser!

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

pkgsMenuStrings
	0 == 1
		ifTrue: 
			[self
				savePackage;
				removePackages].
	^#('&Packages' 
	'&Write Package...//savePackage'
	'&Remove Package(s)...//removePackages'
	'&Edit Package Groups...//editPackageGroups'
	'Go to Associated Dictionary//gotoPackageDictionary')!

preferencesMenuStrings

	false ifTrue: [		"adding explicit senders ensures that packaging will not drop methods and allows us to find references by browsing senders"
		self openSourceStyler; setColorForCompileErrors; setColorForNoEdits; setColorForUnsavedEdits.
	].
	^#(
		'&Preferences'
		'&Source Styler...//openSourceStyler'
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
	#openJadeiteProjectsBrowser = command
		ifTrue: 
			[aCommandQuery isEnabled: true.
			^true].
	#loadProject = command
		ifTrue: 
			[aCommandQuery isEnabled: true.
			^true].
	command = #beginTransaction
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
			[aCommandQuery isEnabled: true.
			^true].
	(#browseSelectedCategoryMethods = command or: [#fileOutCategories = command])
		ifTrue: 
			[aCommandQuery isEnabled: categoryListPresenter selections notEmpty.
			^true].
	#inspectMethod = command
		ifTrue: 
			[aCommandQuery isEnabled: methodListPresenter selections size = 1.
			^true].
	#fileOutSelectedMethods = command
		ifTrue: 
			[aCommandQuery isEnabled: methodListPresenter selections notEmpty.
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
			aCommandQuery isChecked: JadePresenter packageListVisible.
			^true].
	#togglePackageGroupsColumn == aCommandQuery command
		ifTrue: 
			[aCommandQuery isEnabled: true.
			aCommandQuery isChecked: JadePresenter packageGroupsVisible.
			^true].
	#gotoPackageDictionary = aCommandQuery command
		ifTrue: 
			[aCommandQuery isEnabled: (packageListPresenter selectionIfNone: []) ~~ nil.
			^true].
	(#(#unloadProjects #reloadProject) includes: aCommandQuery command)
		ifTrue: 
			[self halt.
			aCommandQuery isEnabled: ((Array with: RowanService notRowanizedPackageName with: 'UnPackaged')
						includes: self selectedProjectName).
			^true].
	^super queryCommand: aCommandQuery!

reformatSource
	| formattedSource |
	formattedSource := self reformatSourceInPresenter: self methodSourcePresenter
				methodService: self methodToReformat.
	self methodValueChanged.
	^formattedSource!

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
	^self reloadProjectsFrom: self!

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

removePackages
	| projectService |
	(MessageBox confirm: 'Really remove package(s)?') ifFalse: [^self].
	projectService := projectListPresenter selection.
	projectService
		command: #removePackagesNamed:;
		commandArgs: (Array with: packageListPresenter selections).
	self issueCommand: projectService!

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

runAll
	self selectSUnitTab.
	self sunitPresenter runAll!

runSelected
	^self runMethodTests. !

search
	^search ifNil: [search := JadeiteSearch on: methodSourcePresenter view session: self gciSession]!

selectClassHierarchyTab
	classHierarchyTabs lastCard!

selectClassListTab
	classHierarchyTabs firstCard!

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

selectNewPackage: newPackage
	| thePackageService | 
	thePackageService := packageListPresenter list
				detect: [:packageService | packageService name = newPackage].
	packageListPresenter selection: thePackageService!

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

setFont
	| newFont currentFont |
	currentFont := JadeitePreferences current currentFont ifNil: [Font default].
	newFont := FontDialog showModalOn: currentFont.
	newFont ifNil: [^self].
	JadeitePreferences displayFontFrom: newFont.
	JadeitePreferences current currentFont: newFont!

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

showPackageGroups
	componentPackageContainer view arrangement: 1/4.
	packageDictionaryContainer view arrangement: 0.5. 
	projectListContainer view arrangement: 3/20. 
	classContainer view arrangement: 1/5. 
	packageGroupPresenter view creationParentView show!

showPackageList
	componentPackageContainer view arrangement: 1 / 3.
	packageDictionaryContainer view show.
	self view
		hide;
		show	"ugh - this seems necessary for some reason to get the gui to update"!

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
			[JadePresenter packageListVisible: false.
			JadePresenter hidePackageList]
		ifFalse: 
			[JadePresenter packageListVisible: true.
			JadePresenter showPackageList]!

togglePackageGroupsColumn
	packageGroupPresenter view creationParentView isWindowVisible
		ifTrue: 
			[JadePresenter packageGroupsVisible: false.
			JadePresenter hidePackageGroups]
		ifFalse: 
			[JadePresenter packageGroupsVisible: true.
			JadePresenter showPackageGroups]!

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

updateClassMenu: menu
	| gotoPackageItem gotoDictionaryItem |
	(menu class canUnderstand: #items) ifFalse: [^self].
	"Removal and adding of the item seems to be necessary to update the menu about to be displayed"
	gotoPackageItem := menu items
				detect: [:commandItem | commandItem commandDescription command = #gotoClassDefinedPackage]
				ifNone: [^self].
	menu removeItem: gotoPackageItem.
	gotoPackageItem description: self definedClassMenuItemLabel.
	menu addItem: gotoPackageItem.
	gotoDictionaryItem := menu items
				detect: [:commandItem | commandItem commandDescription command = #gotoDictionary]
				ifNone: [^self].
	menu removeItem: gotoDictionaryItem.
	gotoDictionaryItem description: self containedDictionaryLabel.
	menu addItem: gotoDictionaryItem!

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
			[dictionaryPresenter selections do: 
					[:dictionaryService |
					dictionaryService globals
						ifNotNil: [:globals | globals do: [:globalArray | array nextPut: globalArray]]]].
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

updatePackage
	classListPresenter model: ListModel new.
	classHierarchyPresenter model: JadeiteTreeModel new.
	self updateClasses.
	self isClassListTabSelected ifFalse: [self updateHierarchy].
	self updatePackageInfo.
	self resetSunitTestList.
	packageListPresenter selectionIfNone: [self selectProjectTab]!

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

updatePackageMenu: menu
	| gotoPackageDictionaryItem |
	(menu class canUnderstand: #items) ifFalse: [^self].
	"Removal and adding of the item seems to be necessary to update the menu about to be displayed"
	gotoPackageDictionaryItem := menu items
				detect: [:commandItem | commandItem commandDescription command = #gotoPackageDictionary]
				ifNone: [^self].
	menu removeItem: gotoPackageDictionaryItem.
	packageListPresenter selectionIfNone: [^self].
	gotoPackageDictionaryItem description: self containedPackageDictionaryLabel.
	menu addItem: gotoPackageDictionaryItem!

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
			[self buildPackageList.
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
			array nextPut: (Array with: service with: 'diskSha').
			array nextPut: (Array with: service with: 'branch').
			array nextPut: (Array with: service with: 'isSkew').
			array nextPut: (Array with: service with: 'isDirty').
			array nextPut: (Array with: service with: 'projectUrl').
			array nextPut: (Array with: service with: 'packageConvention').
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
	self view arrangement: projectTabLabel.
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
aboutToChange:!event handlers!public! !
addDictionary!menu handlers!must not strip!public! !
additionalAccelerators!constants!public! !
addMethodCategory!menu handlers!must not strip!public! !
addNoneProject!public!updating! !
addPackagePresenter!accessing!private! !
addSystemBrowser!menu handlers!must not strip!public! !
addVariableAccessors!menu handlers!public! !
allSelectedProjectsDirty!public!testing! !
auditProject!project menu handlers!public! !
basicAddDictionaryNamed:!menu handlers support!private! !
basicAddMethodCategory:!menu handlers support!private! !
basicAddVariableAccessors!menu handlers!public! !
basicCopyClass:to:!menu handlers support!private! !
basicDictionaryTabLabel!displaying!private! !
basicProjectTabLabel!displaying!private!tabs! !
basicRemoveClass:!menu handlers support!private! !
basicRemoveDictionaries:!menu handlers support!private! !
basicRemoveGlobal:!menu handlers support!private! !
basicUnloadProjects:!menu handlers support!private! !
basicUpdateProject!private!updating! !
browseBreakpoints!public! !
browseClassReferences!menu handlers!must not strip!public! !
browseGlobalClass!menu handlers!must not strip!public! !
browseGlobalReferences!menu handlers!must not strip!public! !
browseInstVarReaders!menu handlers!must not strip!public! !
browseInstVarWriters!menu handlers!must not strip!public! !
browseMethodHistory!menu handlers!must not strip!public! !
browseSelectedCategoryMethods!menu handlers!must not strip!public!queries! !
browseSelectedMethods!menu handlers!must not strip!public!queries! !
buildAddPackageView!private!tabs! !
buildGlobalsTab!private!tabs! !
buildPackageList!event handlers!public!updating! !
buildPreferencesMenu!menus!private!updating! !
buildProjectInfoTab:!private!tabs! !
buildProjectListView!private!tabs! !
buildProjectReadMeTab!private!tabs! !
buildProjectTab!private!tabs! !
categoriesMenuStrings!menus!public! !
checkout!menu handlers!must not strip!public! !
checkoutTag!menu handlers!must not strip!public! !
classCommentChanged!event handlers!public! !
classContainer!accessing!public! !
classesMenuStrings!menus!public! !
cleanupProjectInfoTab!event handlers!public!updating! !
clearComponentList!initialize/release!public! !
clearMethodListPresenters!event handlers!private!updating! !
clearProjectTabs!private!tabs! !
comparisonPresenter!accessing!public! !
componentPackageContainer!accessing!public! !
contextObject!menu handlers support!private! !
copyInfo!menu handlers!must not strip!public! !
copyProjectInfo!menu handlers!must not strip!public! !
createComponents!initialize/release!public! !
createListViewFor:!private! !
createSchematicWiring!create schemantic wiring!initialize/release!public! !
createSchematicWiringForClassHierarchy!create schemantic wiring!public! !
createSchematicWiringForClassList!create schemantic wiring!public! !
createSchematicWiringForMethodList!create schemantic wiring!public! !
createSchematicWiringForMethodSource!create schemantic wiring!initialize/release!public! !
createSchematicWiringForProjectList!create schemantic wiring!public! !
debug!menu handlers!must not strip!public! !
dictionaryMenu!menus!public! !
dictionaryMenuStrings!menus!public! !
dictionaryPresenter!accessing!private! !
displayStringFor:in:!double dispatch!public! !
displayVariable:!displaying!private! !
editComponents!menu handlers!must not strip!public! !
editDelete!menu handlers!must not strip!public! !
editLoadSpecFromFile!menu handlers!must not strip!public! !
editPackageGroups!menu handlers!must not strip!public! !
editRevert!menu handlers!must not strip!public! !
editSave!menu handlers!must not strip!public! !
editSaveClass!menu handlers!must not strip!public! !
editSaveMethod!menu handlers!must not strip!public! !
editSaveMethod:!menu handlers support!private! !
editSaveReadMe!menu handlers!must not strip!private!tabs! !
expandFullAt:!menu handlers support!private!updating! !
expandFullHierarchy!menu handlers!must not strip!public!updating! !
fileOutCategories!menu handlers!must not strip!public! !
fileOutCategoriesOnPath:!menu handlers support!private! !
fileOutClass!menu handlers!must not strip!public! !
fileOutClassOnPath:!menu handlers support!private! !
fileOutDictionaries!menu handlers!must not strip!public! !
fileOutDictionariesOnPath:!menu handlers support!private! !
fileOutMethodsOnPath:!menu handlers support!private! !
fileOutSelectedMethods!menu handlers!must not strip!public! !
findClass!menu handlers!must not strip!public! !
findRemovedServices!menu handlers support!private! !
gitCommit!project menu handlers!public! !
globalsMenu!menus!public! !
globalsMenuStrings!menus!public! !
globalsTab!accessing!private! !
gotoClassDefinedPackage!menu handlers!must not strip!public! !
gotoDictionary!menu handlers!must not strip!public! !
gotoDictionaryNamed:!menu handlers!must not strip!public! !
gotoPackageDictionary!menu handlers!must not strip!public! !
hasCategorySelected!public!testing! !
hasExactlyOneCategorySelected!public!testing! !
hasMethods!public!testing! !
hidePackageGroups!displaying!public! !
hidePackageList!displaying!public! !
hierarchyClassDoubleClicked!menu handlers!must not strip!public! !
insertCompileErrorText:into:!compile support!public! !
insertIfFalse!menu handlers!must not strip!public! !
insertIfTrue!menu handlers!must not strip!public! !
inspectGlobal!menu handlers!must not strip!public! !
inspectMethod!menu handlers!must not strip!public! !
inspectorContextObject!menu handlers support!private! !
isClassDefinitionTabSelected!public!testing! !
isClassHierarchyTabSelected!public!testing! !
isClassSelected!public!testing! !
isComparisonTabSelected!public!testing! !
isDictionariesTabSelected!public!testing! !
isHierarchyTabSelected!public!testing! !
isLoadSpecTabSelected!public!testing! !
isMethodSourceTabSelected!public!testing! !
isNoneProjectSelected!event handlers!public!updating! !
isOkayToChange!event handlers!public!testing! !
isProjectInfoTabSelected!public!testing! !
isProjectItemEnabled:!menu handlers support!private!testing! !
isRowanProjectSelected!public!testing! !
isSourceTabSelected!public!testing! !
isSunitTabSelected!public!testing! !
jadeDebug!menu handlers!must not strip!private! !
jadeInspect!menu handlers!must not strip!public! !
makeSameSelectionsIn:as:!menu handlers!menu handlers support!must not strip!private! !
maxAutoCompleteListSize!constants!public! !
methodMenu:!menu handlers support!private! !
methodSelectionChanged!event handlers!public! !
methodsMenuStrings!menus!public! !
methodsUpdate:!public!updating! !
methodToReformat!menu handlers support!private! !
methodValueChanged!event handlers!public! !
moveClassToPackage!menu handlers!must not strip!public! !
moveClassToPackageNamed:!menu handlers!must not strip!public! !
moveMethods:toCategory:!drag & drop!private! !
moveMethodsToPackageNamed:!menu handlers!must not strip!public! !
moveMethodToPackage!menu handlers!must not strip!public! !
newProjectNamed:!menu handlers!menu handlers support!must not strip!private! !
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
openJadeiteProjectsBrowser!menu handlers!must not strip!public! !
openSourceStyler!menu handlers!must not strip!public! !
packageDictionaryCards!accessing!private! !
packageGroupPresenter!accessing!private! !
pkgsMenuStrings!menus!public! !
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
projectReadmePath!menu handlers!must not strip!private!tabs! !
projectReadMeTab!accessing!private! !
projectTabLabel!displaying!private! !
protectedDictionaries!constants!menu handlers!must not strip!public! !
pullFromGit!project menu handlers!public! !
pushToGit!project menu handlers!public! !
queryCommand:!menu handlers support!private! !
reformatSource!menu handlers!menu handlers support!must not strip!private! !
refresh!event handlers!menu handlers!must not strip!public!updating! !
refreshClass!event handlers!public!updating! !
refreshFromServer!event handlers!menu handlers!must not strip!public!updating! !
refreshFromServerAfterAbort:!public! !
refreshMethodsOn:!event handlers!public! !
registerPresentersForUpdates!public!register presenters! !
reloadProject!menu handlers!must not strip!public! !
removeAppropriateTab!private!tabs! !
removeClass!menu handlers!must not strip!public! !
removeDictionaries!menu handlers!must not strip!public! !
removeGlobal!menu handlers!must not strip!public! !
removeGlobalsTab!private!tabs! !
removePackages!menu handlers!must not strip!public! !
removeProjectTabs!private!tabs! !
resetClassTemplate!private! !
runAll!menu handlers!must not strip!public! !
runSelected!menu handlers!must not strip!public! !
search!accessing!public! !
selectClassHierarchyTab!public!selection! !
selectClassListTab!public!selection! !
selectDictionaryNamed:!public!selection! !
selectedDictionaryNames!public!selection! !
selectedDictionaryOrPackage!private!selection! !
selectedFilters!accessing!public! !
selectedGlobalName:!menu handlers support!private! !
selectedPackageNames!public!selection! !
selectedPackageServices!public!selection! !
selectedProjectName!public!selection! !
selectNewPackage:!event handlers!public! !
selectNoneProject!public!selection! !
selectPackageNamed:!public!selection! !
selectPackageOrDictionaryFor:!public!selection! !
selectProjectNamed:!public!selection! !
selectProjectTab!public! !
setCompileErrorColor!compile support!public! !
setCompileWarningColor!compile support!public! !
setFont!menu handlers!must not strip!public! !
setStatusBarDefault!compile support!public! !
shouldShowNoneTabLabel!displaying!private!testing! !
showDictionaryList!event handlers!public!updating! !
showPackageGroups!displaying!public! !
showPackageList!displaying!public! !
statusBarText!accessing!public! !
statusBarText:!accessing!public! !
symbolExists:!public!testing! !
textTabChanged!event handlers!public! !
togglePackageDictionaryColumn!displaying!menu handlers!must not strip!public! !
togglePackageGroupsColumn!displaying!menu handlers!must not strip!public! !
unloadProjects!project menu handlers!public! !
updateAddPackageLists!public!updating! !
updateAfterFindClass:!menu handlers!must not strip!public!updating! !
updateAfterFindClassInDictionary:!menu handlers!must not strip!public!updating! !
updateAfterFindClassInPackage:!menu handlers!must not strip!public!updating! !
updateAutoCommit!public!register presenters!updating! !
updateClass:!public!updating! !
updateClasses!event handlers!public!updating! !
updateClassMenu:!event handlers!public!updating! !
updateDictionaries!public!updating! !
updateDictionary!public!updating! !
updateGlobalsTab!private!tabs! !
updateHierarchy!public!updating! !
updateHierarchyForPacktionaries!private!updating! !
updateMenuBar!menus!public!updating! !
updateMethodSourceColor!public!updating! !
updatePackage!event handlers!public!updating! !
updatePackageGroupPackages!event handlers!public!updating! !
updatePackageMenu:!event handlers!public!updating! !
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

downArrowIcon
	^Icon fromFile: 'icons\DownArrow.ico'
!

overriddenIcon
	^Icon fromId: 'icons\OVERRIDDEN.ICO'!

projectMenu
	^Menu fromStrings: self projectMenuStrings!

projectMenuStrings
	"put on the class side so it can be shared with the projectlist in the console"

	self rowanFixMe.	"this really is a cumbersome way to build a menu."
	0 == 1
		ifTrue: 
			[self new
				createNewProject;
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
	^#('Projects' 'Browse//openJadeiteProjectsBrowser' 'Create ...//createNewProject' 'Load ...//loadProject' 'Refresh From Disk //reloadProject' 'Unload//unloadProjects' '-' 'Pull from Git//pullFromGit' 'Commit to Git ...//gitCommit' 'Push to Git//pushToGit' '-' '&Changes//projectChanges' 'Write ...//writeProject' 'Checkout Git Tag ...//checkoutTag' 'Checkout Git Branch ...//checkout' '-' 'Edit Components//editComponents' 'Edit Load Spec From File ...//editLoadSpecFromFile' '-' 'Audit//auditProject' 'Git Log//projectLog' '&Refresh//refreshFromServer')!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil 328198 ##(Smalltalk.Point) 3601 1601 517 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 576 nil nil nil 5 nil nil nil 576 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.CardContainer) 34 16 nil 576 34 2 8 1409286144 131073 704 nil 327686 ##(Smalltalk.Color) #default nil 5 nil nil nil 704 656710 1 ##(Smalltalk.CardLayout) 138 144 34 5 721414 ##(Smalltalk.Association) 590662 1 ##(Smalltalk.CardLabel) 8 'SUnit' 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 4 1 944 8 'doIt' 8 '[Icon fromId: ''icons\UnitTestPlugin.ico'']' 8 #[32 105 45 30 178 106] 983558 ##(Smalltalk.VariableBinding) #Icon ##(Smalltalk.Icon) 8 'icons\UnitTestPlugin.ico' #fromId: 960 7 1 nil nil 410 ##(Smalltalk.ReferenceView) 34 14 nil 704 34 2 8 1140850688 131073 1104 nil 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 nil nil nil 1104 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteSUnitInClassPresenter) #resource_Default_view nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 482 9 53 482 3585 697 1104 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 4 7 0 0 118 1 0 0] 8 #() 482 193 193 nil 27 866 898 8 'Class Definition' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 704 34 2 8 1445007428 1025 1504 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 1170 26337781 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 11 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #editSave 8 '&Save' 9383 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 1698 1 1730 #editUndo 8 '&Undo' 9397 1 nil nil nil 1698 1 1730 #editRedo 8 '&Redo' 9395 1 nil nil nil 1778 4097 1698 1 1730 #editCut 8 'Cu&t' 9393 1 nil nil nil 1698 1 1730 #editCopy 8 '&Copy' 9351 1 nil nil nil 1698 1 1730 #editPaste 8 '&Paste' 9389 1 nil nil nil 1698 1 1730 #editDelete 8 '&Delete' 1629 1 nil nil nil 1778 4097 1698 1 1730 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 263174 ##(Smalltalk.Font) nil true 524550 ##(Smalltalk.LOGFONTW) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 0 0 0 0 86 0 101 0 114 0 100 0 97 0 110 0 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 1504 nil 8 1463369192 852486 ##(Smalltalk.NullConverter) nil nil 13 1687120481 170 192 34 4 #callTip 1182790 1 ##(Smalltalk.ScintillaTextStyle) 77 770 #gray 770 #white 1 nil nil nil nil #callTip nil nil nil #normal 2370 1 nil nil 1 nil nil nil nil #normal nil nil nil nil 1639686 ##(Smalltalk.SmalltalkExpressionStyler) 1 nil nil false 138 144 1424 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 1504 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1424 nil 170 176 1424 9215 nil nil nil nil 770 #silver nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #literalArray 8 '()' #specialCharacter 8 '()[]<>' 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 2432 nil nil nil nil 16 nil 170 192 34 6 1 1510470 3 ##(Smalltalk.ScintillaIndicatorStyle) 1 1504 1170 65025 3 false 1 nil nil nil nil nil nil 3 2802 3 1504 770 #blue 5 false 3 nil nil nil nil nil nil 5 2802 5 1504 770 #red 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 2370 1027 1170 60239 1170 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2370 1031 1170 335 1170 31317503 1 nil nil nil nil #Error nil nil nil #Notification 2370 1029 nil 1170 31185883 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 9 1298 #createAt:extent: 34 2 482 9 53 482 3585 697 1504 1298 #contextMenu: 34 1 1664 1504 1298 #caretPeriod: 8 #(530) 1504 1298 #wordWrap: 8 #(true) 1504 1298 #margins: 34 1 34 3 985158 3 ##(Smalltalk.ScintillaMargin) 1 1504 1 3 nil nil 5 nil 3330 3 1504 33 nil 3 67108863 5 nil 3330 5 1504 1 nil 3 -67108863 5 nil 1504 1298 #tabWidth: 8 #(4) 1504 1298 #targetRange: 34 1 525062 ##(Smalltalk.Interval) 1 -1 3 1504 1298 #maxCompletionListHeight: 8 #(9) 1504 1298 #edgeColumn: 8 #(1) 1504 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 4 7 0 0 118 1 0 0] 8 #() 1440 nil 33 866 898 8 'Class Documentation' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 704 34 2 8 1445007428 1025 3648 1570 nil false 1616 nil 1170 26337781 nil 5 1650 nil true 34 1 1698 1 1730 #editSaveClassComment 8 'Save' 1025 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 2208 nil 3648 nil 8 1463369192 2306 nil nil 15 1687168529 170 192 34 4 #callTip 2370 77 2400 2416 1 nil nil nil nil #callTip nil nil nil #normal 2370 1 nil nil 1 nil nil nil nil #normal nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 2530 1 nil nil nil 3648 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1424 nil 170 176 1424 9215 nil nil nil nil 2592 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 3920 nil nil nil nil 16 nil 170 192 34 6 1 2802 1 3648 1170 65025 3 false 1 nil nil nil nil nil nil 3 2802 3 3648 2864 5 false 3 nil nil nil nil nil nil 5 2802 5 3648 2896 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 2370 1027 1170 60239 1170 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2370 1031 1170 335 1170 31317503 1 nil nil nil nil #Error nil nil nil #Notification 2370 1029 nil 1170 31185883 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 10 1298 #createAt:extent: 34 2 482 9 53 482 3585 697 3648 1298 #contextMenu: 34 1 3744 3648 1298 #hoverTime: 8 #(1000000) 3648 1298 #caretPeriod: 8 #(530) 3648 1298 #wordWrap: 8 #(true) 3648 1298 #margins: 34 1 34 3 3330 1 3648 1 3 nil nil 5 nil 3330 3 3648 33 nil 3 67108863 5 nil 3330 5 3648 1 nil 3 -67108863 5 nil 3648 1298 #tabWidth: 8 #(4) 3648 1298 #targetRange: 34 1 3458 1 -1 3 3648 1298 #maxCompletionListHeight: 8 #(9) 3648 1298 #edgeColumn: 8 #(1) 3648 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 4 7 0 0 118 1 0 0] 8 #() 1440 nil 33 866 898 8 'Method Source' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 704 34 2 8 1445007428 1025 4960 1570 nil false 1616 nil 1170 26337781 nil 5 nil 2208 nil 4960 nil 8 1463369192 2306 nil nil 13 1687111745 170 192 34 4 #callTip 2370 77 2400 2416 1 nil nil nil nil #callTip nil nil nil #normal 2370 1 nil nil 1 nil nil nil nil #normal nil nil nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 1424 170 192 34 2 #default 2530 1 nil nil nil 4960 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1424 nil 170 176 1424 9215 nil nil nil nil 2592 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #literalArray 8 '()' #specialCharacter 8 '()[]<>' 8 '' 3 170 192 34 2 #container 170 192 34 4 #callTip 5120 #normal 5136 nil nil nil nil 16 nil 170 192 34 12 1 2802 1 4960 1170 65025 3 false 1 nil nil nil nil nil nil 8 'indicator10' 2802 21 4960 2896 3 nil nil nil nil nil nil nil nil 8 'indicator8' 2802 17 4960 2592 1 nil nil nil nil nil nil nil nil 8 'indicator9' 2802 19 4960 2896 13 nil nil nil nil nil nil nil nil 3 2802 3 4960 2864 5 false 3 nil nil nil nil nil nil 5 2802 5 4960 2896 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 2370 1027 1170 60239 1170 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2370 1031 1170 335 1170 31317503 1 nil nil nil nil #Error nil nil nil #Notification 2370 1029 nil 1170 31185883 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 9 1298 #createAt:extent: 34 2 482 9 53 482 3585 697 4960 1298 #hoverTime: 8 #(500) 4960 1298 #caretPeriod: 8 #(530) 4960 1298 #wordWrap: 8 #(true) 4960 1298 #margins: 34 1 34 3 3330 1 4960 61 3 nil nil 5 nil 3330 3 4960 1 nil 3 67108863 nil nil 3330 5 4960 1 nil 3 -67108863 nil nil 4960 1298 #tabWidth: 8 #(4) 4960 1298 #targetRange: 34 1 3458 1 -1 3 4960 1298 #maxCompletionListHeight: 8 #(9) 4960 1298 #edgeColumn: 8 #(1) 4960 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 4 7 0 0 118 1 0 0] 8 #() 1440 nil 33 866 898 8 'Comparison' nil nil 410 ##(Smalltalk.ShellView) 34 27 nil 704 34 2 8 1078919168 131073 6336 nil 784 nil 517 nil nil nil 6336 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 6336 34 2 8 1140850688 131073 6432 nil 1170 26337781 nil 5 1650 nil true 34 5 1698 1 1730 #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 1698 1 1730 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 1698 1 1730 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 1698 1 1730 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 1698 1 1730 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 6432 514 170 176 1424 false 170 192 1424 nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 1 1 482 3553 665 6432 1298 #contextMenu: 34 1 6512 6432 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 240 6 0 0 76 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 6432 34 2 8 1140850688 131073 7040 nil 784 nil 5 nil nil nil 7040 6402 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 7040 34 2 8 1140850945 262145 7120 nil nil nil 21 nil nil nil 7120 nil 8 1607531712 2306 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 1 625 482 1771 41 7120 1298 #text: 34 1 8 '
' 7120 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 117 3 0 0 76 1 0 0] 8 #() 1440 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 7040 34 2 8 1140920580 1025 7424 1570 nil false 1616 nil 1170 26337781 nil 21 nil 2208 nil 7424 nil 8 1463369192 2306 nil nil 13 1687124849 170 192 34 12 #whitespace 2370 3 770 #teal nil 1 nil nil nil nil #whitespace nil nil nil #diff 2370 5 nil 1170 16908287 3 nil nil nil nil #diff nil 1401 nil #lineNumber 2370 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #normal 2370 1 nil nil 1 nil nil nil nil #normal nil nil nil #indentGuide 2370 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #callTip 2370 77 2400 2416 1 nil nil nil nil #callTip nil nil nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 2530 1 nil nil nil 7424 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1424 nil 170 176 1424 9215 nil nil nil nil 2592 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #literalArray 8 '()' #specialCharacter 8 '()[]<>' 8 '' 3 170 192 34 2 #container 7552 nil nil nil nil 16 nil 170 192 34 2 #diff 2802 1 7424 770 #yellow 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 2370 1027 1170 60239 1170 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2370 1031 1170 335 1170 31317503 1 nil nil nil nil #Error nil nil nil #Notification 2370 1029 nil 1170 31185883 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 8 1298 #createAt:extent: 34 2 482 1 1 482 1771 625 7424 1298 #caretPeriod: 8 #(530) 7424 1298 #wordWrap: 8 #(true) 7424 1298 #margins: 34 1 34 3 3330 1 7424 49 3 nil nil nil nil 3330 3 7424 1 nil nil 67108863 nil nil 3330 5 7424 1 nil nil nil nil nil 7424 1298 #canHScroll: 8 #(false) 7424 1298 #targetRange: 34 1 3458 1 -1 3 7424 1298 #maxCompletionListHeight: 8 #(9) 7424 1298 #edgeColumn: 8 #(1) 7424 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 117 3 0 0 56 1 0 0] 8 #() 1440 nil 33 170 192 34 4 7120 8 'beforeTitle' 7424 8 'before' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 1771 665 7040 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 117 3 0 0 76 1 0 0] 34 2 7424 7120 1440 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 6432 34 2 8 1140850688 1 8880 nil 1170 66047 nil 517 nil nil nil 1510470 1 ##(Smalltalk.DraggableViewInteractor) 8880 nil 1 #left nil nil nil 482 1 1 482 9 9 nil 8992 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1771 1 482 11 665 8880 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 117 3 0 0 0 0 0 0 122 3 0 0 76 1 0 0] 8 #() 1440 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 6432 34 2 8 1140850688 131073 9184 nil 784 nil 5 nil nil nil 9184 6402 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 9184 34 2 8 1140850945 262145 9264 nil nil nil 21 nil nil nil 9264 nil 8 1607531712 2306 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 1 625 482 1773 41 9264 1298 #text: 34 1 8 '
' 9264 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 118 3 0 0 76 1 0 0] 8 #() 1440 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 9184 34 2 8 1140920580 1025 9568 1570 nil false 1616 nil 1170 26337781 nil 21 nil 2208 nil 9568 nil 8 1463369192 2306 nil nil 13 1687190369 170 192 34 12 #whitespace 2370 3 7600 nil 1 nil nil nil nil #whitespace nil nil nil #diff 2370 5 nil 1170 16908287 3 nil nil nil nil #diff nil 1401 nil #lineNumber 2370 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #normal 2370 1 nil nil 1 nil nil nil nil #normal nil nil nil #indentGuide 2370 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #callTip 2370 77 2400 2416 1 nil nil nil nil #callTip nil nil nil nil 7714 7744 170 192 34 2 #default 2530 1 nil nil nil 9568 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1424 nil 170 176 1424 9215 nil nil nil nil 2592 nil nil 65 nil nil 7840 7920 3 170 192 34 2 #container 9696 nil nil nil nil 16 nil 170 192 34 2 #diff 2802 1 9568 8016 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 2370 1027 1170 60239 1170 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2370 1031 1170 335 1170 31317503 1 nil nil nil nil #Error nil nil nil #Notification 2370 1029 nil 1170 31185883 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 8 1298 #createAt:extent: 34 2 482 1 1 482 1773 625 9568 1298 #caretPeriod: 8 #(530) 9568 1298 #wordWrap: 8 #(true) 9568 1298 #margins: 34 1 34 3 3330 1 9568 49 3 nil nil nil nil 3330 3 9568 1 nil nil 67108863 nil nil 3330 5 9568 1 nil nil nil nil nil 9568 1298 #canHScroll: 8 #(false) 9568 1298 #targetRange: 34 1 3458 1 -1 3 9568 1298 #maxCompletionListHeight: 8 #(9) 9568 1298 #edgeColumn: 8 #(1) 9568 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 118 3 0 0 56 1 0 0] 8 #() 1440 nil 33 170 192 34 4 9568 8 'after' 9264 8 'afterTitle' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1781 1 482 1773 665 9184 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 122 3 0 0 0 0 0 0 240 6 0 0 76 1 0 0] 34 2 9568 9264 1440 nil 27 1440 nil 27 170 192 34 2 6432 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 1650 nil true 34 4 1698 1 1730 #selectUpper 8 'Select &upper' 1 1 nil nil nil 1698 1 1730 #selectLower 8 'Select &lower' 1 1 nil nil nil 1778 4097 1698 1 1730 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 65415 nil nil 1650 nil true 34 3 1698 1 1730 #character 8 '&Character' 1 1 nil nil nil 1698 1 1730 #word 8 '&Word' 1 1 nil nil nil 1698 1 1730 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 65417 nil nil 1650 nil true 34 1 1698 1 1730 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 65419 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 9 53 482 3585 697 6336 1298 #text: 34 1 8 'Comparison' 6336 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 4 7 0 0 118 1 0 0] 34 1 6432 1440 nil 27 6336 nil nil nil 170 192 34 10 3648 8 'classDocumentation' 1504 8 'classDefinition' 1104 8 'sunit' 4960 8 'methodSource' 6336 8 'comparisonTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 704 34 2 8 1140916736 1 11792 590662 2 ##(Smalltalk.ListModel) 138 144 34 5 1472 3616 4928 912 6304 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) nil nil 1 nil nil nil 11792 nil 8 1607388928 946 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 11968 7 257 nil 946 0 nil 11986 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 12032 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #smallIcons nil nil nil nil nil 1234 138 144 34 3 1298 #createAt:extent: 34 2 482 1 1 482 3601 757 11792 1298 #setSingleSelection: 8 #(5) 11792 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 11792 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 8 7 0 0 122 1 0 0] 8 #() 1440 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 3601 757 704 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 8 7 0 0 122 1 0 0] 34 6 1504 3648 4960 1104 6336 11792 1440 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 12530 #fixedParentRight 1 12530 #fixedParentTop 1 12530 #fixedParentBottom -39 410 ##(Smalltalk.ContainerView) 34 15 nil 576 34 2 8 1140850688 131073 12608 nil nil 482 2241 43 517 nil nil nil 12608 642 170 176 34 4 410 ##(Smalltalk.TextEdit) 34 16 nil 12608 34 2 8 1140850688 1 12736 nil 784 482 2199 43 517 nil 2194 nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 482 193 193 nil 12736 770 #black 8 1607675312 2306 nil nil 67 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 43 1 482 3559 41 12736 1298 #setMarginWidths: 34 1 8 #(3 3) 12736 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 21 0 0 0 0 0 0 0 8 7 0 0 20 0 0 0] 8 #() 1440 nil 27 12498 12544 43 12560 1 12576 1 12592 1 410 ##(Smalltalk.ToolButton) 34 14 nil 12608 34 2 8 1140850688 131073 13168 nil nil nil 1029 nil nil nil 13168 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 13168 34 2 8 1140853580 131137 13232 nil nil 482 43 43 513 nil nil nil 13232 nil 8 1607642496 nil 170 192 34 2 60313 1115206 1 ##(Smalltalk.ToolbarIconButton) 13232 1 1730 #flipAutoCommit 8 'Auto Commit' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons/camera16_light_icon.ico' nil 60313 34 1 13376 nil nil 3 nil 482 33 33 482 33 33 nil nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 43 43 13232 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 8 #() 1440 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 43 43 13168 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 34 1 13232 1440 nil 27 12498 12544 1 12530 #fixedViewLeft 43 12576 1 12530 #fixedViewTop 43 170 192 34 4 12736 8 'statusBarField' 13168 8 'autoCommitButton' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 757 482 3601 41 12608 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 122 1 0 0 8 7 0 0 142 1 0 0] 34 2 13168 12736 1440 nil 27 12498 12544 1 12560 1 12592 -39 12592 1 170 192 34 2 704 8 'textAreaTabs' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 805 482 3601 797 576 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 146 1 0 0 8 7 0 0 32 3 0 0] 34 2 704 12608 1440 nil 27 25 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 14368 nil nil nil 5 nil nil nil 14368 514 170 176 34 8 410 ##(Smalltalk.ContainerView) 34 15 nil 14368 34 2 8 1140850688 131073 14480 nil nil nil 5 nil nil nil 14480 514 170 176 34 4 410 ##(Smalltalk.CardContainer) 34 16 nil 14480 34 2 8 1409286144 131073 14592 nil 784 nil 5 nil nil nil 14592 802 138 144 34 3 866 8 'Category' 410 ##(Smalltalk.ListView) 34 45 nil 14592 34 2 8 1409372233 1025 14736 11858 138 144 1424 nil 11936 784 nil 21 nil nil nil 14736 nil 8 1607618784 459270 ##(Smalltalk.Message) #displayString 8 #() nil 12096 nil nil nil nil nil nil 138 144 34 1 920646 5 ##(Smalltalk.ListViewColumn) 8 'Column 1' 467 #left 14850 #displayString 8 #() ##(Smalltalk.SortedCollection) 946 0 nil 978 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each]' 1779525917 15008 7 257 nil nil 14736 nil 3 nil nil #report 8 #() nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 9 53 482 475 735 14736 1298 #text: 34 1 8 'Column 1' 14736 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 241 0 0 0 137 1 0 0] 8 #() 1440 nil 35 866 8 'Package' 410 ##(Smalltalk.ListView) 34 45 nil 14592 34 2 8 1409372233 1025 15328 11858 138 144 1424 nil 11936 784 nil 21 nil nil nil 15328 nil 8 1607618784 14850 #displayString 14880 nil 12096 nil nil nil nil nil nil 138 144 34 1 14930 8 'Packages' 467 #left 14850 #displayString 14992 ##(Smalltalk.SortedCollection) 946 0 nil 978 1 83886081 ##(Smalltalk.UndefinedObject) 15040 15056 1779525917 15536 7 257 nil nil 15328 nil 3 nil nil #report 15072 nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 9 53 482 475 735 15328 1298 #text: 34 1 8 'Packages' 15328 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 241 0 0 0 137 1 0 0] 8 #() 1440 nil 35 866 8 'Variable' 410 ##(Smalltalk.ListView) 34 45 nil 14592 34 2 8 1409372233 1025 15808 11858 138 144 1424 nil 11936 784 nil 21 nil nil nil 15808 nil 8 1607618784 14850 #displayString 8 #() nil 12096 nil nil 946 0 nil 978 4 1 944 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 15952 7 257 nil nil nil nil 138 144 34 1 14930 8 'Column 1' 467 #left 14850 #displayString 15936 ##(Smalltalk.SortedCollection) nil nil 15808 nil 3 nil 946 0 nil 978 4 1 944 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 16112 7 257 nil #report 15072 nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 9 53 482 475 735 15808 1298 #text: 34 1 8 'Column 1' 15808 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 241 0 0 0 137 1 0 0] 8 #() 1440 nil 35 14736 nil nil nil 170 192 34 6 15328 8 'packageMethodList' 15808 8 'variableList' 14736 8 'categoryList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 14592 34 2 8 1140916736 1 16480 11858 138 144 34 3 14720 15792 15312 nil 11936 nil nil 1 nil nil nil 16480 nil 8 1607388928 946 0 nil 11986 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 16608 7 257 nil 946 0 nil 11986 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 16656 7 257 nil 12096 nil nil nil nil nil #noIcons nil nil nil nil nil 1234 138 144 34 3 1298 #createAt:extent: 34 2 482 1 1 482 491 795 16480 1298 #setSingleSelection: 8 #(1) 16480 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 16480 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 245 0 0 0 141 1 0 0] 8 #() 1440 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 491 795 14592 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 245 0 0 0 141 1 0 0] 34 4 14736 15808 15328 16480 1440 nil 27 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 232 63 410 ##(Smalltalk.ContainerView) 34 15 nil 14480 34 2 8 1140850688 131073 17120 nil nil nil 5 nil nil nil 17120 642 170 176 34 6 410 ##(Smalltalk.ListView) 34 45 nil 17120 34 2 8 1409372233 1025 17232 11858 138 144 1424 nil 11936 784 nil 13 nil nil nil 17232 nil 8 1607618784 14850 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 12096 nil nil nil nil nil nil 138 144 34 2 14930 8 '' 41 #left 1298 #empty 8 #() 16 14850 #<= 8 #() nil nil 17232 946 0 nil 978 2 1 944 8 'doIt' 8 '[:each | each subSuperIcon]' 8 #[30 105 226 0 106] #subSuperIcon 17504 7 257 nil 1 nil nil 14930 8 'Selector' 773 #left 14850 #displayString 17360 ##(Smalltalk.SortedCollection) nil nil 17232 nil 3 nil 946 0 nil 978 5 1 944 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 17632 7 257 nil #report 15072 nil 133221 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 55 482 821 691 17232 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 27 0 0 0 154 1 0 0 116 1 0 0] 8 #() 1440 nil 35 12498 12544 1 12560 1 12576 55 12592 -49 410 ##(Smalltalk.PushButton) 34 20 nil 17120 34 2 8 1140858880 1 17888 nil 784 nil 5 nil nil nil 17888 nil 8 1607683504 1730 #gotoMethodDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 745 482 821 51 17888 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 116 1 0 0 154 1 0 0 141 1 0 0] 8 #() 1440 nil 29 12498 12544 1 12560 1 12592 -49 12592 1 410 ##(Smalltalk.TextEdit) 34 16 nil 17120 34 2 8 1140916352 1025 18160 nil 784 nil 5 nil nil nil 18160 nil 8 1607675312 2306 nil nil 3 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 821 51 18160 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 154 1 0 0 25 0 0 0] 8 #() 1440 nil 27 12498 12544 1 12560 1 12576 1 12576 51 170 192 34 6 17232 8 'methodList' 17888 8 'definedPackageMethodText' 18160 8 'categoryMethodText' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 501 1 482 821 795 17120 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 250 0 0 0 0 0 0 0 148 2 0 0 141 1 0 0] 34 3 17232 17888 18160 1440 nil 27 17090 8 0 0 0 0 0 0 244 63 false 170 192 34 2 14592 8 'methodFilterTabs' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 2281 1 482 1321 795 14480 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 116 4 0 0 0 0 0 0 8 7 0 0 141 1 0 0] 34 3 14592 410 ##(Smalltalk.Splitter) 34 12 nil 14480 34 2 8 1140850688 1 18896 nil 784 nil 517 nil nil nil 8962 18896 nil 1 #left nil nil nil 8992 9008 nil 8992 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 491 1 482 11 795 18896 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 245 0 0 0 0 0 0 0 250 0 0 0 141 1 0 0] 8 #() 1440 nil 27 17120 1440 nil 27 524806 ##(Smalltalk.Fraction) 5 11 410 ##(Smalltalk.ContainerView) 34 15 nil 14368 34 2 8 1140850688 131073 19168 nil nil nil 5 nil nil nil 19168 514 170 176 1424 false 170 192 34 2 410 ##(Smalltalk.ListView) 34 45 nil 19168 34 2 8 1409405261 1025 19296 11858 138 144 1424 nil 11936 784 nil 5 nil nil nil 19296 nil 8 1607618784 14850 #displayString 8 #() nil 12096 nil nil nil nil nil nil 138 144 34 1 14930 8 'Column 1' 487 #left 946 0 nil 978 2 1 944 8 'doIt' 8 '[:each | each displayName]' 8 #[30 105 226 0 106] #displayName 19504 7 257 nil ##(Smalltalk.SortedCollection) nil nil 19296 nil 3 946 0 nil 978 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 19584 7 257 nil 946 0 nil 978 3 1 944 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 19664 7 257 nil #report 15072 nil 133217 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 1 1 482 495 795 19296 1298 #text: 34 1 8 'Column 1' 19296 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 247 0 0 0 141 1 0 0] 8 #() 1440 nil 35 8 'projectList' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 495 795 19168 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 247 0 0 0 141 1 0 0] 34 1 19296 1440 nil 27 19138 7 41 410 ##(Smalltalk.ContainerView) 34 15 nil 14368 34 2 8 1140850688 131073 20144 nil nil nil 5 nil nil nil 20144 642 170 176 34 6 410 ##(Smalltalk.CardContainer) 34 16 nil 20144 34 2 8 1409286144 131073 20256 nil 784 nil 5 nil nil nil 20256 802 138 144 34 2 866 898 8 'Classes' nil nil 410 ##(Smalltalk.ListView) 34 45 nil 20256 34 2 8 1409372237 1025 20416 11858 138 144 1424 nil 11936 784 nil 29 nil nil nil 20416 nil 8 1607618784 14850 #displayString 8 #() nil 12096 nil nil nil nil nil nil 138 144 34 1 14930 8 '' 635 #left 14850 #displayString 8 #() 14850 #<= 8 #() nil nil 20416 nil 3 nil 946 0 nil 978 5 1 944 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 20688 7 257 nil #report 15072 nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 9 53 482 643 635 20416 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 69 1 0 0 87 1 0 0] 8 #() 1440 nil 35 866 898 8 'Hierarchy' nil nil 410 ##(Smalltalk.JadeiteTreeView) 34 28 nil 20256 34 2 8 1140920871 1025 20976 1049670 3 ##(Smalltalk.JadeiteTreeModel) nil 1616 984070 ##(Smalltalk.JadeiteTreeNode) nil nil nil nil 170 176 1424 784 nil 29 nil nil nil 20976 nil 8 1607462928 946 0 nil 978 2 1 944 8 'doIt' 8 '[:each | each displayString]' 8 #[30 105 226 0 106] #displayString 21136 7 257 nil ##(Smalltalk.IconicListAbstract) 12096 nil 946 0 nil 978 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 21216 7 257 nil 946 0 nil 978 5 1 944 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 21296 7 257 nil nil nil 170 176 1424 33 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 1424 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 9 53 482 643 635 20976 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 69 1 0 0 87 1 0 0] 8 #() 1440 nil 27 20416 nil nil nil 170 192 34 4 20976 8 'classHierarchy' 20416 8 'classList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 20256 34 2 8 1140916736 1 21632 11858 138 144 34 2 20384 20944 nil 11936 nil nil 1 nil nil nil 21632 nil 8 1607388928 946 0 nil 11986 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 21760 7 257 nil 946 0 nil 11986 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 21808 7 257 nil 12096 nil nil nil nil nil #smallIcons nil nil nil nil nil 1234 138 144 34 3 1298 #createAt:extent: 34 2 482 1 1 482 659 695 21632 1298 #setSingleSelection: 8 #(1) 21632 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 21632 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 73 1 0 0 91 1 0 0] 8 #() 1440 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 659 695 20256 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 73 1 0 0 91 1 0 0] 34 3 20416 20976 21632 1440 nil 27 12498 12544 1 12560 1 12576 1 12592 -99 410 ##(Smalltalk.CardContainer) 34 16 nil 20144 34 2 8 1409286144 131073 22256 nil 784 nil 5 nil 2194 nil true 2226 8 #[240 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 188 2 0 0 0 0 0 0 1 2 1 34 83 0 121 0 115 0 116 0 101 0 109 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 22256 802 138 144 34 2 866 898 8 'Class' nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 22256 34 2 8 1140850688 131073 22480 nil nil nil 5 nil nil nil 22480 nil 170 192 1424 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 9 9 482 643 1 22480 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 69 1 0 0 4 0 0 0] 8 #() 1440 nil 27 866 898 8 'Instance' nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 22256 34 2 8 1140850688 131073 22768 nil nil nil 5 nil nil nil 22768 nil 170 192 1424 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 9 9 482 643 1 22768 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 69 1 0 0 4 0 0 0] 8 #() 1440 nil 27 22768 nil nil nil 170 192 34 4 22768 8 'instanceTab' 22480 8 'classTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 22256 34 2 8 1140916738 1 23072 11858 138 144 34 2 22736 22448 nil 11936 nil nil 1 nil nil nil 23072 nil 8 1607388928 946 0 nil 11986 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 23200 7 257 nil 946 0 nil 11986 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 23248 7 257 nil 12096 nil nil nil nil nil #smallIcons nil nil nil nil nil 1234 138 144 34 3 1298 #createAt:extent: 34 2 482 1 1 482 659 51 23072 1298 #setSingleSelection: 8 #(1) 23072 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 23072 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 73 1 0 0 25 0 0 0] 8 #() 1440 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 695 482 659 51 22256 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 91 1 0 0 73 1 0 0 116 1 0 0] 34 3 22768 22480 23072 1440 nil 27 12498 12544 1 12560 1 12592 -99 13904 51 410 ##(Smalltalk.PushButton) 34 20 nil 20144 34 2 8 1140858880 1 23696 nil 2592 nil 5 nil nil nil 23696 nil 8 1607683504 1730 #gotoClassDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 745 482 659 51 23696 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 116 1 0 0 73 1 0 0 141 1 0 0] 8 #() 1440 nil 29 12498 12544 1 12560 1 12592 -49 12592 1 170 192 34 6 20256 8 'classHierarchyTabs' 22256 8 'instanceClassTabs' 23696 8 'definedPackageClassText' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1613 1 482 659 795 20144 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 38 3 0 0 0 0 0 0 111 4 0 0 141 1 0 0] 34 3 20256 22256 23696 1440 nil 27 19138 3 11 410 ##(Smalltalk.ContainerView) 34 15 nil 14368 34 2 8 1140850688 131073 24224 nil nil nil 5 nil nil nil 24224 514 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 24224 34 2 8 1140850688 131073 24336 nil nil nil 5 nil nil nil 24336 514 170 176 1424 false 170 192 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 24336 34 2 8 1409286144 131073 24464 nil 784 nil 5 nil nil nil 24464 802 138 144 34 1 866 8 'Package Groups' 410 ##(Smalltalk.JadeiteTreeView) 34 28 nil 24464 34 2 8 1140916775 1025 24608 21042 nil 11936 21074 nil nil nil nil 170 192 1424 784 nil 5 1650 nil true 34 1 1698 1 1730 #editPackageGroups 8 'Edit Package Groups ...' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 24608 nil 8 1607462928 946 0 nil 978 2 1 14848 8 'doIt' 8 '[:service | service displayString]' 8 #[30 105 226 0 106] #displayString 24832 7 257 nil ##(Smalltalk.IconicListAbstract) 12096 nil nil nil nil nil 170 176 1424 33 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 1424 nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 9 53 482 529 735 24608 1298 #contextMenu: 34 1 24720 24608 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 12 1 0 0 137 1 0 0] 8 #() 1440 nil 27 24608 nil nil nil 170 192 34 2 24608 8 'packageGroupTree' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 24464 34 2 8 1140916736 1 25184 11858 138 144 34 1 24592 nil 11936 nil nil 1 nil nil nil 25184 nil 8 1607388928 946 0 nil 11986 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 25312 7 257 nil 946 0 nil 11986 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 25360 7 257 nil 12096 nil nil nil nil nil #noIcons nil nil nil nil nil 1234 138 144 34 3 1298 #createAt:extent: 34 2 482 1 1 482 545 795 25184 1298 #setSingleSelection: 8 #(1) 25184 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 25184 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 1 0 0 141 1 0 0] 8 #() 1440 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 545 795 24464 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 1 0 0 141 1 0 0] 34 2 24608 25184 1440 nil 27 8 'packageGroupsCards' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 545 795 24336 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 1 0 0 141 1 0 0] 34 1 24464 1440 nil 27 19138 3 5 410 ##(Smalltalk.ContainerView) 34 15 nil 24224 34 2 8 1140850688 131073 25984 nil nil nil 5 nil nil nil 25984 514 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 25984 34 2 8 1409286144 131073 26096 nil 784 nil 21 nil nil nil 26096 802 138 144 1424 nil nil nil nil 170 192 1424 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 26096 34 2 8 1140916736 1 26208 11858 138 144 1424 nil 11936 nil nil 17 nil nil nil 26208 nil 8 1607388928 946 0 nil 11986 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 26320 7 257 nil nil 12096 nil nil nil nil nil #noIcons nil nil nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 1 1 482 545 795 26208 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 26208 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 1 0 0 141 1 0 0] 8 #() 1440 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 545 795 26096 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 1 0 0 141 1 0 0] 34 1 26208 1440 nil 27 3 false 170 192 34 2 26096 8 'packageDictionaryCards' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 555 1 482 545 795 25984 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 21 1 0 0 0 0 0 0 37 2 0 0 141 1 0 0] 34 1 26096 1440 nil 27 19138 3 5 false 170 192 34 4 24336 8 'packageGroupsContainer' 25984 8 'packageDictionaryContainer' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 505 1 482 1099 795 24224 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 252 0 0 0 0 0 0 0 33 3 0 0 141 1 0 0] 34 3 24336 410 ##(Smalltalk.Splitter) 34 12 nil 24224 34 2 8 1140850688 1 27168 nil 784 nil 517 nil nil nil 8962 27168 nil 1 #left nil nil nil 8992 9008 nil 8992 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 545 1 482 11 795 27168 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 16 1 0 0 0 0 0 0 21 1 0 0 141 1 0 0] 8 #() 1440 nil 27 25984 1440 nil 27 19138 3 7 false 170 192 34 6 20144 8 'classContainer' 19168 8 'projectListContainer' 24224 8 'componentPackageContainer' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 3601 795 14368 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 8 7 0 0 141 1 0 0] 34 7 19168 410 ##(Smalltalk.Splitter) 34 12 nil 14368 34 2 8 1140850688 1 27664 nil 784 nil 517 nil nil nil 8962 27664 nil 1 #left nil nil nil 8992 9008 nil 8992 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 495 1 482 11 795 27664 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 247 0 0 0 0 0 0 0 252 0 0 0 141 1 0 0] 8 #() 1440 nil 27 24224 410 ##(Smalltalk.Splitter) 34 12 nil 14368 34 2 8 1140850688 1 27904 nil 784 nil 517 nil nil nil 8962 27904 nil 1 #left nil nil nil 8992 9008 nil 8992 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1603 1 482 11 795 27904 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 33 3 0 0 0 0 0 0 38 3 0 0 141 1 0 0] 8 #() 1440 nil 27 20144 410 ##(Smalltalk.Splitter) 34 12 nil 14368 34 2 8 1140850688 1 28144 nil 784 nil 517 nil nil nil 8962 28144 nil 1 #left nil nil nil 8992 9008 nil 8992 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 2271 1 482 11 795 28144 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 111 4 0 0 0 0 0 0 116 4 0 0 141 1 0 0] 8 #() 1440 nil 27 14480 1440 nil 27 25 true 170 192 34 2 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 28416 nil 784 nil 517 nil nil nil 8962 28416 nil 1 #left nil nil nil 8992 9008 nil 8992 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 795 482 3601 11 28416 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 141 1 0 0 8 7 0 0 146 1 0 0] 8 #() 1440 nil 27 8 'splitter' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 7311 21 482 3601 1601 416 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 71 14 0 0 10 0 0 0 79 21 0 0 42 3 0 0] 34 3 14368 28416 576 1440 nil 27 )! !
!JadeiteBrowserPresenter class categoriesForMethods!
defaultAdditionalAccelerators!constants!public! !
downArrowIcon!public! !
overriddenIcon!public! !
projectMenu!menus!public! !
projectMenuStrings!menus!public! !
resource_Default_view!public!resources-views! !
!

