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
	aSelectionChangingEvent value
		ifTrue: 
			[aSelectionChangingEvent value: self isOkayToChange.
			aSelectionChangingEvent value ifTrue: [self resetCategoryText]]!

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

basicOnDropClassList: dragDropSession
	| classService failedCompilations newSelections |
	failedCompilations := OrderedCollection new.
	classService := dragDropSession suggestedTarget.
	classService meta: self isClassSideSelected.
	dragDropSession dragObjects do: 
			[:dragDropObject |
			
			[dragDropObject object source ifNil: [self updateService: dragDropObject object].
			classService
				saveMethod: dragDropObject object source
				category: dragDropObject object category
				session: gciSession]
					on: GsCompileError
					do: [:ex | failedCompilations add: dragDropObject object]].
	failedCompilations isEmpty
		ifTrue: 
			[self selectedClass == classService
				ifFalse: 
					[self isHierarchyTabSelected
						ifTrue: [self selectClassInClassHierarchyNamed: classService name]
						ifFalse: [self selectClassNamed: classService name]].
			newSelections := methodListPresenter list select: 
							[:methodService |
							(dragDropSession dragObjects collect: [:ea | ea object selector]) includes: methodService selector].
			methodListPresenter selections: newSelections].
	^failedCompilations!

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
		name: 'projectReadMeTab'.
	projectReadMeTab view contextMenu: classDefinitionPresenter view contextMenu!

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
			on: GsApplicationError, GsCompileError
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
			(JadePresenter unsavedChangesDialogIn: self)
				ifTrue: 
					[gciSession isValidSession
						ifTrue: 
							[classDefinitionPresenter view isModified: false.
							^true]
						ifFalse: 
							[classDefinitionPresenter
								selectAll;
								copySelection]]
				ifFalse: [^false].
			classDefinitionPresenter view isModified: false].
	classCommentPresenter view isModified
		ifTrue: 
			[classCommentPresenter ensureVisible.
			gciSession isValidSession
				ifTrue: 
					[(JadePresenter unsavedChangesDialogIn: self
						text: 'Stay on window with unsaved changes? Class comment has unsaved changes.') ifTrue: [^false]]
				ifFalse: 
					[(JadePresenter unsavedChangesDialogIn: self
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

onDropMethodsOnClassHierarchy: aSession
	^self onDropOnClassList: aSession!

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

onDropOnClassList: dragDropSession
	| failedCompilations |
	failedCompilations := self basicOnDropClassList: dragDropSession.
	failedCompilations isEmpty
		ifFalse: 
			[MessageBox notify: 'Methods failing compilation: '
						, (failedCompilations collect: [:methodService | methodService selector]) asArray printString]!

onDropOnMethodCategory: aSession
	| methodServices targetCategory |
	methodServices := aSession dragObjects collect: [:each | each format: #method].
	targetCategory := aSession suggestedTarget trimBlanks.
	self moveMethods: methodServices toCategory: targetCategory!

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
	textStyles := methodSourcePresenter view editStyles textStyles.
	JadeiteTextStyles default textStyles: textStyles.
	classDefinitionPresenter view textStyles: textStyles.
	originalSourcePresenter view textStyles: textStyles.
	classCommentPresenter view textStyles: textStyles.
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

refreshProjectInfoTab
	| service |
	service := self projectListPresenter selectionIfNone: [^self cleanupProjectInfoTab].
	service wasUpdated: true. 
	self updateProjectInfoTabFor: service!

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
			classHierarchyPresenter model asBag detect: [:svc | svc name = classService name]
				ifNone: [self updateHierarchy].
			self selectClassNamed: classService name]!

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
basicOnDropClassList:!drag & drop!public! !
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
onDropMethodsOnClassHierarchy:!drag & drop!public! !
onDropMethodsOnPackageList:!drag & drop!public! !
onDropMethodsOnPackageList:session:!drag & drop!public! !
onDropOnClassList:!drag & drop!public! !
onDropOnMethodCategory:!drag & drop!public! !
onDropOnPackageList:!drag & drop!public! !
onViewClosed!event handlers!public! !
onViewOpened!event handlers!public! !
openJadeiteProjectsBrowser!menu handlers!must not strip!public! !
openSourceStyler!menu handlers!must not strip!public! !
packageDictionaryCards!accessing!private! !
packageGroupPresenter!accessing!private! !
pkgsMenuStrings!menus!public! !
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
refreshProjectInfoTab!event handlers!public!updating! !
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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil 328198 ##(Smalltalk.Point) 3601 1601 517 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 576 nil nil nil 5 nil nil nil 576 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.CardContainer) 34 16 nil 576 34 2 8 1409286144 131073 704 nil 327686 ##(Smalltalk.Color) #default nil 5 nil nil nil 704 656710 1 ##(Smalltalk.CardLayout) 138 144 34 5 721414 ##(Smalltalk.Association) 590662 1 ##(Smalltalk.CardLabel) 8 'SUnit' 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 4 1 944 8 'doIt' 8 '[Icon fromId: ''icons\UnitTestPlugin.ico'']' 8 #[32 105 45 30 178 106] 983558 ##(Smalltalk.VariableBinding) #Icon ##(Smalltalk.Icon) 8 'icons\UnitTestPlugin.ico' #fromId: 960 7 1 nil nil 410 ##(Smalltalk.ReferenceView) 34 14 nil 704 34 2 8 1140850688 131073 1104 nil 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 nil nil nil 1104 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteSUnitInClassPresenter) #resource_Default_view nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 482 9 53 482 3585 697 1104 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 4 7 0 0 118 1 0 0] 8 #() 482 193 193 nil 27 866 898 8 'Class Definition' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 704 34 2 8 1445007428 1025 1504 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 1170 26337781 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 10 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #editSave 8 '&Save' 9383 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 1698 1 1730 #editUndo 8 '&Undo' 9397 1 nil nil nil 1698 1 1730 #editRedo 8 '&Redo' 9395 1 nil nil nil 1778 4097 1698 1 1730 #editCut 8 'Cu&t' 9393 1 nil nil nil 1698 1 1730 #editCopy 8 '&Copy' 9351 1 nil nil nil 1698 1 1730 #editPaste 8 '&Paste' 9389 1 nil nil nil 1778 4097 1698 1 1730 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 263174 ##(Smalltalk.Font) nil true 524550 ##(Smalltalk.LOGFONTW) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 0 0 0 0 86 0 101 0 114 0 100 0 97 0 110 0 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 1504 nil 8 1384725992 852486 ##(Smalltalk.NullConverter) nil nil 13 1995598065 170 192 34 4 #callTip 1182790 1 ##(Smalltalk.ScintillaTextStyle) 77 770 #gray 770 #white 1 nil nil nil nil #callTip nil nil nil #normal 2322 1 nil nil 1 nil nil nil nil #normal nil nil nil nil 1639686 ##(Smalltalk.SmalltalkExpressionStyler) 1 nil nil false 138 144 1424 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 1504 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1424 nil 170 176 1424 9215 nil nil nil nil 770 #silver nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #literalArray 8 '()' #specialCharacter 8 '()[]<>' 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 2384 nil nil nil nil 16 nil 170 192 34 6 1 1510470 3 ##(Smalltalk.ScintillaIndicatorStyle) 1 1504 1170 65025 3 false 1 nil nil nil nil nil nil 3 2754 3 1504 770 #blue 5 false 3 nil nil nil nil nil nil 5 2754 5 1504 770 #red 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 2322 1027 1170 60239 1170 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2322 1031 1170 335 1170 31317503 1 nil nil nil nil #Error nil nil nil #Notification 2322 1029 nil 1170 31185883 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 9 1298 #createAt:extent: 34 2 482 9 53 482 3585 697 1504 1298 #contextMenu: 34 1 1664 1504 1298 #caretPeriod: 8 #(530) 1504 1298 #wordWrap: 8 #(true) 1504 1298 #margins: 34 1 34 3 985158 3 ##(Smalltalk.ScintillaMargin) 1 1504 1 3 nil nil 5 nil 3282 3 1504 33 nil 3 67108863 5 nil 3282 5 1504 1 nil 3 -67108863 5 nil 1504 1298 #tabWidth: 8 #(4) 1504 1298 #targetRange: 34 1 525062 ##(Smalltalk.Interval) 1 -1 3 1504 1298 #maxCompletionListHeight: 8 #(9) 1504 1298 #edgeColumn: 8 #(1) 1504 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 4 7 0 0 118 1 0 0] 8 #() 1440 nil 33 866 898 8 'Class Documentation' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 704 34 2 8 1445007428 1025 3600 1570 nil false 1616 nil 1170 26337781 nil 5 1650 nil true 34 1 1698 1 1730 #editSaveClassComment 8 'Save' 1025 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 2160 nil 3600 nil 8 1384725992 2258 nil nil 15 1995611169 170 192 34 4 #callTip 2322 77 2352 2368 1 nil nil nil nil #callTip nil nil nil #normal 2322 1 nil nil 1 nil nil nil nil #normal nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 2482 1 nil nil nil 3600 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1424 nil 170 176 1424 9215 nil nil nil nil 2544 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 3872 nil nil nil nil 16 nil 170 192 34 6 1 2754 1 3600 1170 65025 3 false 1 nil nil nil nil nil nil 3 2754 3 3600 2816 5 false 3 nil nil nil nil nil nil 5 2754 5 3600 2848 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 2322 1027 1170 60239 1170 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2322 1031 1170 335 1170 31317503 1 nil nil nil nil #Error nil nil nil #Notification 2322 1029 nil 1170 31185883 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 10 1298 #createAt:extent: 34 2 482 9 53 482 3585 697 3600 1298 #contextMenu: 34 1 3696 3600 1298 #hoverTime: 8 #(1000000) 3600 1298 #caretPeriod: 8 #(530) 3600 1298 #wordWrap: 8 #(true) 3600 1298 #margins: 34 1 34 3 3282 1 3600 1 3 nil nil 5 nil 3282 3 3600 33 nil 3 67108863 5 nil 3282 5 3600 1 nil 3 -67108863 5 nil 3600 1298 #tabWidth: 8 #(4) 3600 1298 #targetRange: 34 1 3410 1 -1 3 3600 1298 #maxCompletionListHeight: 8 #(9) 3600 1298 #edgeColumn: 8 #(1) 3600 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 4 7 0 0 118 1 0 0] 8 #() 1440 nil 33 866 898 8 'Method Source' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 704 34 2 8 1445007428 1025 4912 1570 nil false 1616 nil 1170 26337781 nil 5 nil 2160 nil 4912 nil 8 1384725992 2258 nil nil 13 1995554385 170 192 34 4 #callTip 2322 77 2352 2368 1 nil nil nil nil #callTip nil nil nil #normal 2322 1 nil nil 1 nil nil nil nil #normal nil nil nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 1424 170 192 34 2 #default 2482 1 nil nil nil 4912 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1424 nil 170 176 1424 9215 nil nil nil nil 2544 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #literalArray 8 '()' #specialCharacter 8 '()[]<>' 8 '' 3 170 192 34 2 #container 170 192 34 4 #callTip 5072 #normal 5088 nil nil nil nil 16 nil 170 192 34 12 1 2754 1 4912 1170 65025 3 false 1 nil nil nil nil nil nil 8 'indicator8' 2754 17 4912 2544 1 nil nil nil nil nil nil nil nil 8 'indicator9' 2754 19 4912 2848 13 nil nil nil nil nil nil nil nil 8 'indicator10' 2754 21 4912 2848 3 nil nil nil nil nil nil nil nil 3 2754 3 4912 2816 5 false 3 nil nil nil nil nil nil 5 2754 5 4912 2848 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 2322 1027 1170 60239 1170 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2322 1031 1170 335 1170 31317503 1 nil nil nil nil #Error nil nil nil #Notification 2322 1029 nil 1170 31185883 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 9 1298 #createAt:extent: 34 2 482 9 53 482 3585 697 4912 1298 #hoverTime: 8 #(500) 4912 1298 #caretPeriod: 8 #(530) 4912 1298 #wordWrap: 8 #(true) 4912 1298 #margins: 34 1 34 3 3282 1 4912 61 3 nil nil 5 nil 3282 3 4912 1 nil 3 67108863 nil nil 3282 5 4912 1 nil 3 -67108863 nil nil 4912 1298 #tabWidth: 8 #(4) 4912 1298 #targetRange: 34 1 3410 1 -1 3 4912 1298 #maxCompletionListHeight: 8 #(9) 4912 1298 #edgeColumn: 8 #(1) 4912 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 4 7 0 0 118 1 0 0] 8 #() 1440 nil 33 866 898 8 'Comparison' nil nil 410 ##(Smalltalk.ShellView) 34 27 nil 704 34 2 8 1078919168 131073 6288 nil 784 nil 517 nil nil nil 6288 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 6288 34 2 8 1140850688 131073 6384 nil 1170 26337781 nil 5 1650 nil true 34 5 1698 1 1730 #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 1698 1 1730 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 1698 1 1730 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 1698 1 1730 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 1698 1 1730 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 6384 514 170 176 1424 false 170 192 1424 nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 1 1 482 3553 665 6384 1298 #contextMenu: 34 1 6464 6384 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 240 6 0 0 76 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 6384 34 2 8 1140850688 131073 6992 nil 784 nil 5 nil nil nil 6992 6354 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 6992 34 2 8 1140850945 262145 7072 nil nil nil 21 nil nil nil 7072 nil 8 1612971200 2258 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 1 625 482 1771 41 7072 1298 #text: 34 1 8 '
' 7072 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 117 3 0 0 76 1 0 0] 8 #() 1440 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 6992 34 2 8 1140920580 1025 7376 1570 nil false 1616 nil 1170 26337781 nil 21 nil 2160 nil 7376 nil 8 1384725992 2258 nil nil 13 1995650481 170 192 34 12 #whitespace 2322 3 770 #teal nil 1 nil nil nil nil #whitespace nil nil nil #diff 2322 5 nil 1170 16908287 3 nil nil nil nil #diff nil 1401 nil #lineNumber 2322 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #normal 2322 1 nil nil 1 nil nil nil nil #normal nil nil nil #indentGuide 2322 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #callTip 2322 77 2352 2368 1 nil nil nil nil #callTip nil nil nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 2482 1 nil nil nil 7376 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1424 nil 170 176 1424 9215 nil nil nil nil 2544 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #literalArray 8 '()' #specialCharacter 8 '()[]<>' 8 '' 3 170 192 34 2 #container 7504 nil nil nil nil 16 nil 170 192 34 2 #diff 2754 1 7376 770 #yellow 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 2322 1027 1170 60239 1170 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2322 1031 1170 335 1170 31317503 1 nil nil nil nil #Error nil nil nil #Notification 2322 1029 nil 1170 31185883 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 8 1298 #createAt:extent: 34 2 482 1 1 482 1771 625 7376 1298 #caretPeriod: 8 #(530) 7376 1298 #wordWrap: 8 #(true) 7376 1298 #margins: 34 1 34 3 3282 1 7376 49 3 nil nil nil nil 3282 3 7376 1 nil nil 67108863 nil nil 3282 5 7376 1 nil nil nil nil nil 7376 1298 #canHScroll: 8 #(false) 7376 1298 #targetRange: 34 1 3410 1 -1 3 7376 1298 #maxCompletionListHeight: 8 #(9) 7376 1298 #edgeColumn: 8 #(1) 7376 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 117 3 0 0 56 1 0 0] 8 #() 1440 nil 33 170 192 34 4 7072 8 'beforeTitle' 7376 8 'before' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 1771 665 6992 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 117 3 0 0 76 1 0 0] 34 2 7376 7072 1440 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 6384 34 2 8 1140850688 1 8832 nil 1170 66047 nil 517 nil nil nil 1510470 1 ##(Smalltalk.DraggableViewInteractor) 8832 nil 1 #left nil nil nil 482 1 1 482 9 9 nil 8944 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1771 1 482 11 665 8832 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 117 3 0 0 0 0 0 0 122 3 0 0 76 1 0 0] 8 #() 1440 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 6384 34 2 8 1140850688 131073 9136 nil 784 nil 5 nil nil nil 9136 6354 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 9136 34 2 8 1140850945 262145 9216 nil nil nil 21 nil nil nil 9216 nil 8 1612971200 2258 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 1 625 482 1773 41 9216 1298 #text: 34 1 8 '
' 9216 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 118 3 0 0 76 1 0 0] 8 #() 1440 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 9136 34 2 8 1140920580 1025 9520 1570 nil false 1616 nil 1170 26337781 nil 21 nil 2160 nil 9520 nil 8 1384725992 2258 nil nil 13 1995654849 170 192 34 12 #whitespace 2322 3 7552 nil 1 nil nil nil nil #whitespace nil nil nil #diff 2322 5 nil 1170 16908287 3 nil nil nil nil #diff nil 1401 nil #lineNumber 2322 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #normal 2322 1 nil nil 1 nil nil nil nil #normal nil nil nil #indentGuide 2322 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #callTip 2322 77 2352 2368 1 nil nil nil nil #callTip nil nil nil nil 7666 7696 170 192 34 2 #default 2482 1 nil nil nil 9520 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1424 nil 170 176 1424 9215 nil nil nil nil 2544 nil nil 65 nil nil 7792 7872 3 170 192 34 2 #container 9648 nil nil nil nil 16 nil 170 192 34 2 #diff 2754 1 9520 7968 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 2322 1027 1170 60239 1170 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2322 1031 1170 335 1170 31317503 1 nil nil nil nil #Error nil nil nil #Notification 2322 1029 nil 1170 31185883 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 8 1298 #createAt:extent: 34 2 482 1 1 482 1773 625 9520 1298 #caretPeriod: 8 #(530) 9520 1298 #wordWrap: 8 #(true) 9520 1298 #margins: 34 1 34 3 3282 1 9520 49 3 nil nil nil nil 3282 3 9520 1 nil nil 67108863 nil nil 3282 5 9520 1 nil nil nil nil nil 9520 1298 #canHScroll: 8 #(false) 9520 1298 #targetRange: 34 1 3410 1 -1 3 9520 1298 #maxCompletionListHeight: 8 #(9) 9520 1298 #edgeColumn: 8 #(1) 9520 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 118 3 0 0 56 1 0 0] 8 #() 1440 nil 33 170 192 34 4 9520 8 'after' 9216 8 'afterTitle' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1781 1 482 1773 665 9136 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 122 3 0 0 0 0 0 0 240 6 0 0 76 1 0 0] 34 2 9520 9216 1440 nil 27 1440 nil 27 170 192 34 2 6384 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 1650 nil true 34 4 1698 1 1730 #selectUpper 8 'Select &upper' 1 1 nil nil nil 1698 1 1730 #selectLower 8 'Select &lower' 1 1 nil nil nil 1778 4097 1698 1 1730 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 15525 nil nil 1650 nil true 34 3 1698 1 1730 #character 8 '&Character' 1 1 nil nil nil 1698 1 1730 #word 8 '&Word' 1 1 nil nil nil 1698 1 1730 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 15527 nil nil 1650 nil true 34 1 1698 1 1730 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 15529 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 9 53 482 3585 697 6288 1298 #text: 34 1 8 'Comparison' 6288 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 4 7 0 0 118 1 0 0] 34 1 6384 1440 nil 27 3600 nil nil nil 170 192 34 10 1504 8 'classDefinition' 4912 8 'methodSource' 1104 8 'sunit' 6288 8 'comparisonTab' 3600 8 'classDocumentation' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 704 34 2 8 1140916736 1 11744 590662 2 ##(Smalltalk.ListModel) 138 144 34 5 1472 3568 4880 912 6256 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) nil nil 1 nil nil nil 11744 nil 8 1612828416 946 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 11920 7 257 nil 946 0 nil 11938 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 11984 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #smallIcons nil nil nil nil nil 1234 138 144 34 3 1298 #createAt:extent: 34 2 482 1 1 482 3601 757 11744 1298 #setSingleSelection: 8 #(2) 11744 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 11744 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 8 7 0 0 122 1 0 0] 8 #() 1440 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 3601 757 704 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 8 7 0 0 122 1 0 0] 34 6 1504 3600 4912 1104 6288 11744 1440 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 12482 #fixedParentRight 1 12482 #fixedParentTop 1 12482 #fixedParentBottom -39 410 ##(Smalltalk.ContainerView) 34 15 nil 576 34 2 8 1140850688 131073 12560 nil nil 482 2241 43 517 nil nil nil 12560 642 170 176 34 4 410 ##(Smalltalk.ToolButton) 34 14 nil 12560 34 2 8 1140850688 131073 12688 nil nil nil 1029 nil nil nil 12688 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 12688 34 2 8 1140853580 131137 12752 nil nil 482 43 43 513 nil nil nil 12752 nil 8 1613081984 nil 170 192 34 2 15347 1115206 1 ##(Smalltalk.ToolbarIconButton) 12752 1 1730 #flipAutoCommit 8 'Auto Commit' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons/camera16_light_icon.ico' nil 15347 34 1 12896 nil nil 3 nil 482 33 33 482 33 33 nil nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 43 43 12752 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 8 #() 1440 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 43 43 12688 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 34 1 12752 1440 nil 27 12450 12496 1 12482 #fixedViewLeft 43 12528 1 12482 #fixedViewTop 43 410 ##(Smalltalk.TextEdit) 34 16 nil 12560 34 2 8 1140850688 1 13440 nil 784 482 2199 43 517 nil 2146 nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 482 193 193 nil 13440 770 #black 8 1613114800 2258 nil nil 67 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 43 1 482 3559 41 13440 1298 #setMarginWidths: 34 1 8 #(3 3) 13440 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 21 0 0 0 0 0 0 0 8 7 0 0 20 0 0 0] 8 #() 1440 nil 27 12450 12496 43 12512 1 12528 1 12544 1 170 192 34 4 12688 8 'autoCommitButton' 13440 8 'statusBarField' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 757 482 3601 41 12560 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 122 1 0 0 8 7 0 0 142 1 0 0] 34 2 12688 13440 1440 nil 27 12450 12496 1 12512 1 12544 -39 12544 1 170 192 34 2 704 8 'textAreaTabs' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 805 482 3601 797 576 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 146 1 0 0 8 7 0 0 32 3 0 0] 34 2 704 12560 1440 nil 27 25 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 14320 nil nil nil 5 nil nil nil 14320 514 170 176 34 8 410 ##(Smalltalk.ContainerView) 34 15 nil 14320 34 2 8 1140850688 131073 14432 nil nil nil 5 nil nil nil 14432 514 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 14432 34 2 8 1140850688 131073 14544 nil nil nil 5 nil nil nil 14544 514 170 176 1424 false 170 192 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 14544 34 2 8 1409286144 131073 14672 nil 784 nil 5 nil nil nil 14672 802 138 144 34 1 866 8 'Package Groups' 410 ##(Smalltalk.JadeiteTreeView) 34 28 nil 14672 34 2 8 1140916775 1025 14816 1049670 3 ##(Smalltalk.JadeiteTreeModel) nil 11888 984070 ##(Smalltalk.JadeiteTreeNode) nil nil nil nil 170 192 1424 784 nil 5 1650 nil true 34 1 1698 1 1730 #editPackageGroups 8 'Edit Package Groups ...' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 14816 nil 8 1612902416 946 0 nil 978 2 1 ##(Smalltalk.Message) 8 'doIt' 8 '[:service | service displayString]' 8 #[30 105 226 0 106] #displayString 15072 7 257 nil ##(Smalltalk.IconicListAbstract) 12048 nil nil nil nil nil 170 176 1424 33 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 1424 nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 9 53 482 529 735 14816 1298 #contextMenu: 34 1 14960 14816 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 12 1 0 0 137 1 0 0] 8 #() 1440 nil 27 14816 nil nil nil 170 192 34 2 14816 8 'packageGroupTree' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 14672 34 2 8 1140916736 1 15424 11810 138 144 34 1 14800 nil 11888 nil nil 1 nil nil nil 15424 nil 8 1612828416 946 0 nil 11938 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 15552 7 257 nil 946 0 nil 11938 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 15600 7 257 nil 12048 nil nil nil nil nil #noIcons nil nil nil nil nil 1234 138 144 34 3 1298 #createAt:extent: 34 2 482 1 1 482 545 795 15424 1298 #setSingleSelection: 8 #(1) 15424 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 15424 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 1 0 0 141 1 0 0] 8 #() 1440 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 545 795 14672 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 1 0 0 141 1 0 0] 34 2 14816 15424 1440 nil 27 8 'packageGroupsCards' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 545 795 14544 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 1 0 0 141 1 0 0] 34 1 14672 1440 nil 27 524806 ##(Smalltalk.Fraction) 3 5 410 ##(Smalltalk.ContainerView) 34 15 nil 14432 34 2 8 1140850688 131073 16240 nil nil nil 5 nil nil nil 16240 514 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 16240 34 2 8 1409286144 131073 16352 nil 784 nil 21 nil nil nil 16352 802 138 144 1424 nil nil nil nil 170 192 1424 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 16352 34 2 8 1140916736 1 16464 11810 138 144 1424 nil 11888 nil nil 17 nil nil nil 16464 nil 8 1612828416 946 0 nil 11938 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 16576 7 257 nil nil 12048 nil nil nil nil nil #noIcons nil nil nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 1 1 482 545 795 16464 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 16464 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 1 0 0 141 1 0 0] 8 #() 1440 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 545 795 16352 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 1 0 0 141 1 0 0] 34 1 16464 1440 nil 27 3 false 170 192 34 2 16352 8 'packageDictionaryCards' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 555 1 482 545 795 16240 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 21 1 0 0 0 0 0 0 37 2 0 0 141 1 0 0] 34 1 16352 1440 nil 27 16210 3 5 false 170 192 34 4 14544 8 'packageGroupsContainer' 16240 8 'packageDictionaryContainer' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 505 1 482 1099 795 14432 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 252 0 0 0 0 0 0 0 33 3 0 0 141 1 0 0] 34 3 14544 410 ##(Smalltalk.Splitter) 34 12 nil 14432 34 2 8 1140850688 1 17424 nil 784 nil 517 nil nil nil 8914 17424 nil 1 #left nil nil nil 8944 8960 nil 8944 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 545 1 482 11 795 17424 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 16 1 0 0 0 0 0 0 21 1 0 0 141 1 0 0] 8 #() 1440 nil 27 16240 1440 nil 27 16210 3 7 410 ##(Smalltalk.ContainerView) 34 15 nil 14320 34 2 8 1140850688 131073 17680 nil nil nil 5 nil nil nil 17680 514 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 17680 34 2 8 1140850688 131073 17792 nil nil nil 5 nil nil nil 17792 642 170 176 34 6 410 ##(Smalltalk.PushButton) 34 20 nil 17792 34 2 8 1140858880 1 17904 nil 784 nil 5 nil nil nil 17904 nil 8 1613122992 1730 #gotoMethodDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 745 482 821 51 17904 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 116 1 0 0 154 1 0 0 141 1 0 0] 8 #() 1440 nil 29 12450 12496 1 12512 1 12544 -49 12544 1 410 ##(Smalltalk.TextEdit) 34 16 nil 17792 34 2 8 1140916352 1025 18176 nil 784 nil 5 nil nil nil 18176 nil 8 1613114800 2258 nil nil 3 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 821 51 18176 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 154 1 0 0 25 0 0 0] 8 #() 1440 nil 27 12450 12496 1 12512 1 12528 1 12528 51 410 ##(Smalltalk.ListView) 34 45 nil 17792 34 2 8 1409372233 1025 18448 11810 138 144 1424 nil 11888 784 nil 13 nil nil nil 18448 nil 8 1613058272 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.IconicListAbstract) 12048 nil nil nil nil nil nil 138 144 34 2 920646 5 ##(Smalltalk.ListViewColumn) 8 '' 41 #left 1298 #empty 8 #() 16 18562 #<= 8 #() nil nil 18448 946 0 nil 978 2 1 944 8 'doIt' 8 '[:each | each subSuperIcon]' 8 #[30 105 226 0 106] #subSuperIcon 18752 7 257 nil 1 nil nil 18642 8 'Selector' 773 #left 18562 #displayString 18592 ##(Smalltalk.SortedCollection) nil nil 18448 nil 3 nil 946 0 nil 978 5 1 944 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 18880 7 257 nil #report 8 #() nil 133221 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 55 482 821 691 18448 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 27 0 0 0 154 1 0 0 116 1 0 0] 8 #() 1440 nil 35 12450 12496 1 12512 1 12528 55 12544 -49 170 192 34 6 17904 8 'definedPackageMethodText' 18176 8 'categoryMethodText' 18448 8 'methodList' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 501 1 482 821 795 17792 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 250 0 0 0 0 0 0 0 148 2 0 0 141 1 0 0] 34 3 18448 17904 18176 1440 nil 27 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 244 63 410 ##(Smalltalk.CardContainer) 34 16 nil 17680 34 2 8 1409286144 131073 19424 nil 784 nil 5 nil nil nil 19424 802 138 144 34 3 866 8 'Category' 410 ##(Smalltalk.ListView) 34 45 nil 19424 34 2 8 1409372233 1025 19568 11810 138 144 1424 nil 11888 784 nil 21 nil nil nil 19568 nil 8 1613058272 18562 #displayString 8 #() nil 12048 nil nil nil nil nil nil 138 144 34 1 18642 8 'Column 1' 467 #left 18562 #displayString 8 #() ##(Smalltalk.SortedCollection) 946 0 nil 978 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each]' 1779525917 19808 7 257 nil nil 19568 nil 3 nil nil #report 18960 nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 9 53 482 475 735 19568 1298 #text: 34 1 8 'Column 1' 19568 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 241 0 0 0 137 1 0 0] 8 #() 1440 nil 35 866 8 'Package' 410 ##(Smalltalk.ListView) 34 45 nil 19424 34 2 8 1409372233 1025 20112 11810 138 144 1424 nil 11888 784 nil 21 nil nil nil 20112 nil 8 1613058272 18562 #displayString 19696 nil 12048 nil nil nil nil nil nil 138 144 34 1 18642 8 'Packages' 467 #left 18562 #displayString 19792 ##(Smalltalk.SortedCollection) 946 0 nil 978 1 83886081 ##(Smalltalk.UndefinedObject) 19840 19856 1779525917 20320 7 257 nil nil 20112 nil 3 nil nil #report 18960 nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 9 53 482 475 735 20112 1298 #text: 34 1 8 'Packages' 20112 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 241 0 0 0 137 1 0 0] 8 #() 1440 nil 35 866 8 'Variable' 410 ##(Smalltalk.ListView) 34 45 nil 19424 34 2 8 1409372233 1025 20592 11810 138 144 1424 nil 11888 784 nil 21 nil nil nil 20592 nil 8 1613058272 18562 #displayString 8 #() nil 12048 nil nil 946 0 nil 978 4 1 944 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 20736 7 257 nil nil nil nil 138 144 34 1 18642 8 'Column 1' 467 #left 18562 #displayString 20720 ##(Smalltalk.SortedCollection) nil nil 20592 nil 3 nil 946 0 nil 978 4 1 944 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 20896 7 257 nil #report 18960 nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 9 53 482 475 735 20592 1298 #text: 34 1 8 'Column 1' 20592 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 241 0 0 0 137 1 0 0] 8 #() 1440 nil 35 19568 nil nil nil 170 192 34 6 20112 8 'packageMethodList' 19568 8 'categoryList' 20592 8 'variableList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 19424 34 2 8 1140916736 1 21264 11810 138 144 34 3 19552 20576 20096 nil 11888 nil nil 1 nil nil nil 21264 nil 8 1612828416 946 0 nil 11938 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 21392 7 257 nil 946 0 nil 11938 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 21440 7 257 nil 12048 nil nil nil nil nil #noIcons nil nil nil nil nil 1234 138 144 34 3 1298 #createAt:extent: 34 2 482 1 1 482 491 795 21264 1298 #setSingleSelection: 8 #(1) 21264 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 21264 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 245 0 0 0 141 1 0 0] 8 #() 1440 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 491 795 19424 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 245 0 0 0 141 1 0 0] 34 4 19568 20592 20112 21264 1440 nil 27 19394 8 0 0 0 0 0 0 232 63 false 170 192 34 2 19424 8 'methodFilterTabs' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 2281 1 482 1321 795 17680 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 116 4 0 0 0 0 0 0 8 7 0 0 141 1 0 0] 34 3 19424 410 ##(Smalltalk.Splitter) 34 12 nil 17680 34 2 8 1140850688 1 22096 nil 784 nil 517 nil nil nil 8914 22096 nil 1 #left nil nil nil 8944 8960 nil 8944 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 491 1 482 11 795 22096 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 245 0 0 0 0 0 0 0 250 0 0 0 141 1 0 0] 8 #() 1440 nil 27 17792 1440 nil 27 16210 5 11 410 ##(Smalltalk.ContainerView) 34 15 nil 14320 34 2 8 1140850688 131073 22352 nil nil nil 5 nil nil nil 22352 514 170 176 1424 false 170 192 34 2 410 ##(Smalltalk.ListView) 34 45 nil 22352 34 2 8 1409405261 1025 22480 11810 138 144 1424 nil 11888 784 nil 5 nil nil nil 22480 nil 8 1613058272 18562 #displayString 8 #() nil 12048 nil nil nil nil nil nil 138 144 34 1 18642 8 'Column 1' 487 #left 946 0 nil 978 2 1 944 8 'doIt' 8 '[:each | each displayName]' 8 #[30 105 226 0 106] #displayName 22688 7 257 nil ##(Smalltalk.SortedCollection) nil nil 22480 nil 3 946 0 nil 978 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 22768 7 257 nil 946 0 nil 978 3 1 944 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 22848 7 257 nil #report 18960 nil 133217 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 1 1 482 495 795 22480 1298 #text: 34 1 8 'Column 1' 22480 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 247 0 0 0 141 1 0 0] 8 #() 1440 nil 35 8 'projectList' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 495 795 22352 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 247 0 0 0 141 1 0 0] 34 1 22480 1440 nil 27 16210 7 41 410 ##(Smalltalk.ContainerView) 34 15 nil 14320 34 2 8 1140850688 131073 23328 nil nil nil 5 nil nil nil 23328 642 170 176 34 6 410 ##(Smalltalk.CardContainer) 34 16 nil 23328 34 2 8 1409286144 131073 23440 nil 784 nil 5 nil nil nil 23440 802 138 144 34 2 866 898 8 'Classes' nil nil 410 ##(Smalltalk.ListView) 34 45 nil 23440 34 2 8 1409372237 1025 23600 11810 138 144 1424 nil 11888 784 nil 29 nil nil nil 23600 nil 8 1613058272 18562 #displayString 8 #() nil 12048 nil nil nil nil nil nil 138 144 34 1 18642 8 '' 635 #left 18562 #displayString 8 #() 18562 #<= 8 #() nil nil 23600 nil 3 nil 946 0 nil 978 5 1 944 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 23872 7 257 nil #report 18960 nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 9 53 482 643 635 23600 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 69 1 0 0 87 1 0 0] 8 #() 1440 nil 35 866 898 8 'Hierarchy' nil nil 410 ##(Smalltalk.JadeiteTreeView) 34 28 nil 23440 34 2 8 1140920871 1025 24160 14882 nil 1616 14914 nil nil nil nil 170 176 1424 784 nil 29 nil nil nil 24160 nil 8 1612902416 946 0 nil 978 2 1 944 8 'doIt' 8 '[:each | each displayString]' 8 #[30 105 226 0 106] #displayString 24288 7 257 nil ##(Smalltalk.IconicListAbstract) 12048 nil 946 0 nil 978 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 24368 7 257 nil 946 0 nil 978 5 1 944 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 24448 7 257 nil nil nil 170 176 1424 33 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 1424 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 9 53 482 643 635 24160 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 69 1 0 0 87 1 0 0] 8 #() 1440 nil 27 23600 nil nil nil 170 192 34 4 23600 8 'classList' 24160 8 'classHierarchy' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 23440 34 2 8 1140916736 1 24784 11810 138 144 34 2 23568 24128 nil 11888 nil nil 1 nil nil nil 24784 nil 8 1612828416 946 0 nil 11938 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 24912 7 257 nil 946 0 nil 11938 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 24960 7 257 nil 12048 nil nil nil nil nil #smallIcons nil nil nil nil nil 1234 138 144 34 3 1298 #createAt:extent: 34 2 482 1 1 482 659 695 24784 1298 #setSingleSelection: 8 #(1) 24784 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 24784 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 73 1 0 0 91 1 0 0] 8 #() 1440 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 659 695 23440 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 73 1 0 0 91 1 0 0] 34 3 23600 24160 24784 1440 nil 27 12450 12496 1 12512 1 12528 1 12544 -99 410 ##(Smalltalk.PushButton) 34 20 nil 23328 34 2 8 1140858880 1 25408 nil 2544 nil 5 nil nil nil 25408 nil 8 1613122992 1730 #gotoClassDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 745 482 659 51 25408 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 116 1 0 0 73 1 0 0 141 1 0 0] 8 #() 1440 nil 29 12450 12496 1 12512 1 12544 -49 12544 1 410 ##(Smalltalk.CardContainer) 34 16 nil 23328 34 2 8 1409286144 131073 25680 nil 784 nil 5 nil 2146 nil true 2178 8 #[240 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 188 2 0 0 0 0 0 0 1 2 1 34 83 0 121 0 115 0 116 0 101 0 109 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 25680 802 138 144 34 2 866 898 8 'Class' nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 25680 34 2 8 1140850688 131073 25904 nil nil nil 5 nil nil nil 25904 nil 170 192 1424 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 9 9 482 643 1 25904 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 69 1 0 0 4 0 0 0] 8 #() 1440 nil 27 866 898 8 'Instance' nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 25680 34 2 8 1140850688 131073 26192 nil nil nil 5 nil nil nil 26192 nil 170 192 1424 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 9 9 482 643 1 26192 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 69 1 0 0 4 0 0 0] 8 #() 1440 nil 27 26192 nil nil nil 170 192 34 4 26192 8 'instanceTab' 25904 8 'classTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 25680 34 2 8 1140916738 1 26496 11810 138 144 34 2 26160 25872 nil 11888 nil nil 1 nil nil nil 26496 nil 8 1612828416 946 0 nil 11938 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 26624 7 257 nil 946 0 nil 11938 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 26672 7 257 nil 12048 nil nil nil nil nil #smallIcons nil nil nil nil nil 1234 138 144 34 3 1298 #createAt:extent: 34 2 482 1 1 482 659 51 26496 1298 #setSingleSelection: 8 #(1) 26496 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 26496 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 73 1 0 0 25 0 0 0] 8 #() 1440 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 695 482 659 51 25680 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 91 1 0 0 73 1 0 0 116 1 0 0] 34 3 26192 25904 26496 1440 nil 27 12450 12496 1 12512 1 12544 -99 13424 51 170 192 34 6 23440 8 'classHierarchyTabs' 25408 8 'definedPackageClassText' 25680 8 'instanceClassTabs' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1613 1 482 659 795 23328 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 38 3 0 0 0 0 0 0 111 4 0 0 141 1 0 0] 34 3 23440 25680 25408 1440 nil 27 16210 3 11 false 170 192 34 6 14432 8 'componentPackageContainer' 23328 8 'classContainer' 22352 8 'projectListContainer' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 3601 795 14320 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 8 7 0 0 141 1 0 0] 34 7 22352 410 ##(Smalltalk.Splitter) 34 12 nil 14320 34 2 8 1140850688 1 27616 nil 784 nil 517 nil nil nil 8914 27616 nil 1 #left nil nil nil 8944 8960 nil 8944 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 495 1 482 11 795 27616 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 247 0 0 0 0 0 0 0 252 0 0 0 141 1 0 0] 8 #() 1440 nil 27 14432 410 ##(Smalltalk.Splitter) 34 12 nil 14320 34 2 8 1140850688 1 27856 nil 784 nil 517 nil nil nil 8914 27856 nil 1 #left nil nil nil 8944 8960 nil 8944 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1603 1 482 11 795 27856 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 33 3 0 0 0 0 0 0 38 3 0 0 141 1 0 0] 8 #() 1440 nil 27 23328 410 ##(Smalltalk.Splitter) 34 12 nil 14320 34 2 8 1140850688 1 28096 nil 784 nil 517 nil nil nil 8914 28096 nil 1 #left nil nil nil 8944 8960 nil 8944 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 2271 1 482 11 795 28096 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 111 4 0 0 0 0 0 0 116 4 0 0 141 1 0 0] 8 #() 1440 nil 27 17680 1440 nil 27 25 true 170 192 34 2 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 28368 nil 784 nil 517 nil nil nil 8914 28368 nil 1 #left nil nil nil 8944 8960 nil 8944 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 795 482 3601 11 28368 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 141 1 0 0 8 7 0 0 146 1 0 0] 8 #() 1440 nil 27 8 'splitter' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 7679 21 482 3601 1601 416 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 7 22 0 0 42 3 0 0] 34 3 14320 28368 576 1440 nil 27 )! !
!JadeiteBrowserPresenter class categoriesForMethods!
defaultAdditionalAccelerators!constants!public! !
downArrowIcon!public! !
overriddenIcon!public! !
projectMenu!menus!public! !
projectMenuStrings!menus!public! !
resource_Default_view!public!resources-views! !
!

