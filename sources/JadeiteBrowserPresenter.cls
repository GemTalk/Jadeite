"Filed out from Dolphin Smallalk"!

JadeiteProjectsBrowserPresenter subclass: #JadeiteBrowserPresenter
	instanceVariableNames: 'dictionaryPresenter packageDictionaryCards globalsTab autoCommitButton search previousTabViewArrangement previousTopViewArrangement componentListPresenter componentPackageContainer packageDictionaryContainer loadSpecTab'
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

buildLoadSpecTabIfNecessary
	| loadSpecTabView cardLabel |
	loadSpecTab
		ifNil: 
			[loadSpecTab := ListPresenter new.
			loadSpecTabView := self buildInfoTab: loadSpecTab]
		ifNotNil: [loadSpecTabView := loadSpecTab view].
	loadSpecTabView contextMenu: self loadSpecMenu.
	(loadSpecTabView allColumns at: 1) getContentsBlock: [:each | each first].
	(loadSpecTabView allColumns at: 2) getContentsBlock: [:each | each last].
	cardLabel := CardLabel text: 'Load Spec'.
	cardLabel iconBlock: [Icon fromId: (File composeStem: 'Collection' extension: 'ico')].
	loadSpecTabView
		arrangement: cardLabel;
		getImageBlock: nil;
		name: 'loadSpecTab'.
	^loadSpecTabView!

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
	self isProjectInfoTabSelected ifTrue: [self copyProjectInfo].
	self isLoadSpecTabSelected ifTrue: [self copyLoadSpecInfo]!

copyLoadSpecInfo
	loadSpecTab selectionIfNone: 
			[MessageBox notify: 'No selection to copy'.
			^self].
	loadSpecTab selection last ifNil: [^self].
	loadSpecTab selection last copyToClipboard!

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

loadSpecMenu
	^Menu fromStrings: self loadSpecMenuStrings!

loadSpecMenuStrings
	self rowanFixMe.	"this really is a cumbersome way to build a menu."
	0 == 1
		ifTrue: 
			[self
				copyLoadSpecInfo
				].
	^#('Dictionaries' 
	'Copy//copyLoadSpecInfo'
	'Browse Commit In GitHub//openCommitInGitHub')!

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
	self isNoneProjectSelected
		ifTrue: 
			[self
				removeProjectTab;
				removeLoadSpecTab]
		ifFalse: [self removeGlobalsTab]!

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

removeLoadSpecTab
	| loadSpecTabView |
	loadSpecTabView := self view viewNamed: 'loadSpecTab' ifNone: [nil].
	loadSpecTabView ifNotNil: [self textAreaTabs removeSubView: loadSpecTabView].
	loadSpecTab := nil!

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

updateLoadSpecInfoTabFor: service
	| ws |
	ws := Array writeStream: 1.
	service specService objects
		do: [:assoc | ws nextPut: (Array with: assoc key with: assoc value)].
	loadSpecTab list: ws contents!

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
	self buildLoadSpecTabIfNecessary.
	service := projectListPresenter selectionIfNone: [^projectInfoTab list: ListModel new].
	self updateTabLabel.
	self updateProjectInfoTabFor: service.
	self updateLoadSpecInfoTabFor: service.!

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
buildLoadSpecTabIfNecessary!private!tabs! !
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
copyLoadSpecInfo!menu handlers!public! !
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
loadSpecMenu!menus!public! !
loadSpecMenuStrings!menus!public! !
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
removeLoadSpecTab!private!tabs! !
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
updateLoadSpecInfoTabFor:!private!tabs! !
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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil 328198 ##(Smalltalk.Point) 3001 1601 517 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 576 nil nil nil 5 nil nil nil 576 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 576 34 2 8 1140850688 131073 704 nil nil 482 2241 43 517 nil nil nil 704 642 170 176 34 4 410 ##(Smalltalk.ToolButton) 34 14 nil 704 34 2 8 1140850688 131073 832 nil nil nil 1029 nil nil nil 832 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 832 34 2 8 1140853580 131137 896 nil nil 482 43 43 513 nil nil nil 896 nil 8 1591782784 nil 170 192 34 2 25943 1115206 1 ##(Smalltalk.ToolbarIconButton) 896 1 1180998 4 ##(Smalltalk.CommandDescription) #flipAutoCommit 8 'Auto Commit' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons/camera16_light_icon.ico' nil 25943 34 1 1040 nil nil 3 nil 482 33 33 482 33 33 nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 482 1 1 482 43 43 896 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 8 #() 482 193 193 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 43 43 832 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 34 1 896 1440 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 1650 #fixedViewLeft 43 1650 #fixedParentTop 1 1650 #fixedViewTop 43 410 ##(Smalltalk.TextEdit) 34 16 nil 704 34 2 8 1140850688 1 1728 nil 327686 ##(Smalltalk.Color) #default 482 2199 43 517 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 482 193 193 nil 1728 1794 #black 8 1591815600 852486 ##(Smalltalk.NullConverter) nil nil 67 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 43 1 482 2959 41 1728 1298 #setMarginWidths: 34 1 8 #(3 3) 1728 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 21 0 0 0 0 0 0 0 220 5 0 0 20 0 0 0] 8 #() 1440 nil 27 1618 1664 43 1650 #fixedParentRight 1 1696 1 1650 #fixedParentBottom 1 170 192 34 4 832 8 'autoCommitButton' 1728 8 'statusBarField' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 757 482 3001 41 704 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 122 1 0 0 220 5 0 0 142 1 0 0] 34 2 832 1728 1440 nil 27 1618 1664 1 2224 1 2240 -39 2240 1 410 ##(Smalltalk.CardContainer) 34 16 nil 576 34 2 8 1409286144 131073 2496 nil 1808 nil 5 nil nil nil 2496 656710 1 ##(Smalltalk.CardLayout) 138 144 34 5 721414 ##(Smalltalk.Association) 590662 1 ##(Smalltalk.CardLabel) 8 'SUnit' 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 4 1 2704 8 'doIt' 8 '[Icon fromId: ''icons\UnitTestPlugin.ico'']' 8 #[32 105 45 30 178 106] 983558 ##(Smalltalk.VariableBinding) #Icon 1104 8 'icons\UnitTestPlugin.ico' #fromId: 2720 7 1 nil nil 410 ##(Smalltalk.ReferenceView) 34 14 nil 2496 34 2 8 1140850688 131073 2864 nil 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 nil nil nil 2864 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteSUnitInClassPresenter) #resource_Default_view nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 9 53 482 2985 697 2864 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 216 5 0 0 118 1 0 0] 8 #() 1440 nil 27 2626 2658 8 'Class Definition' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 2496 34 2 8 1445007428 1025 3200 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 2930 26337781 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 11 984134 2 ##(Smalltalk.CommandMenuItem) 1 1058 #editSave 8 '&Save' 9383 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 3394 1 1058 #editUndo 8 '&Undo' 9397 1 nil nil nil 3394 1 1058 #editRedo 8 '&Redo' 9395 1 nil nil nil 3458 4097 3394 1 1058 #editCut 8 'Cu&t' 9393 1 nil nil nil 3394 1 1058 #editCopy 8 '&Copy' 9351 1 nil nil nil 3394 1 1058 #editPaste 8 '&Paste' 9389 1 nil nil nil 3394 1 1058 #editDelete 8 '&Delete' 1629 1 nil nil nil 3458 4097 3394 1 1058 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 1842 nil true 1874 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 3200 nil 8 1465073128 1970 nil nil 13 1420976113 170 192 34 4 #callTip 1182790 1 ##(Smalltalk.ScintillaTextStyle) 77 1794 #gray 1794 #white 1 nil nil nil nil #callTip nil nil nil #normal 4002 1 nil nil 1 nil nil nil nil #normal nil nil nil nil 1639686 ##(Smalltalk.SmalltalkExpressionStyler) 1 nil nil false 138 144 3136 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 3200 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 3136 nil 170 176 3136 9215 nil nil nil nil 1794 #silver nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #literalArray 8 '()' #specialCharacter 8 '()[]<>' 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 4064 nil nil nil nil 16 nil 170 192 34 6 1 1510470 3 ##(Smalltalk.ScintillaIndicatorStyle) 1 3200 2930 65025 3 false 1 nil nil nil nil nil nil 3 4434 3 3200 1794 #blue 5 false 3 nil nil nil nil nil nil 5 4434 5 3200 1794 #red 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 4002 1027 2930 60239 2930 31326207 1 nil nil nil nil #Warning nil nil nil #Error 4002 1031 2930 335 2930 31317503 1 nil nil nil nil #Error nil nil nil #Notification 4002 1029 nil 2930 31185883 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 9 1298 #createAt:extent: 34 2 482 9 53 482 2985 697 3200 1298 #contextMenu: 34 1 3360 3200 1298 #caretPeriod: 8 #(530) 3200 1298 #wordWrap: 8 #(true) 3200 1298 #margins: 34 1 34 3 985158 3 ##(Smalltalk.ScintillaMargin) 1 3200 1 3 nil nil 5 nil 4962 3 3200 33 nil 3 67108863 5 nil 4962 5 3200 1 nil 3 -67108863 5 nil 3200 1298 #tabWidth: 8 #(4) 3200 1298 #targetRange: 34 1 525062 ##(Smalltalk.Interval) 1 -1 3 3200 1298 #maxCompletionListHeight: 8 #(9) 3200 1298 #edgeColumn: 8 #(1) 3200 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 216 5 0 0 118 1 0 0] 8 #() 1440 nil 33 2626 2658 8 'Class Documentation' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 2496 34 2 8 1445007428 1025 5280 3266 nil false 3312 nil 2930 26337781 nil 5 3346 nil true 34 1 3394 1 1058 #editSaveClassComment 8 'Save' 1025 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 1842 nil true 1874 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 5280 nil 8 1465073128 1970 nil nil 15 1420997953 170 192 34 4 #callTip 4002 77 4032 4048 1 nil nil nil nil #callTip nil nil nil #normal 4002 1 nil nil 1 nil nil nil nil #normal nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 4162 1 nil nil nil 5280 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 3136 nil 170 176 3136 9215 nil nil nil nil 4224 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 5616 nil nil nil nil 16 nil 170 192 34 6 1 4434 1 5280 2930 65025 3 false 1 nil nil nil nil nil nil 3 4434 3 5280 4496 5 false 3 nil nil nil nil nil nil 5 4434 5 5280 4528 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 4002 1027 2930 60239 2930 31326207 1 nil nil nil nil #Warning nil nil nil #Error 4002 1031 2930 335 2930 31317503 1 nil nil nil nil #Error nil nil nil #Notification 4002 1029 nil 2930 31185883 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 10 1298 #createAt:extent: 34 2 482 9 53 482 2985 697 5280 1298 #contextMenu: 34 1 5376 5280 1298 #hoverTime: 8 #(1000000) 5280 1298 #caretPeriod: 8 #(530) 5280 1298 #wordWrap: 8 #(true) 5280 1298 #margins: 34 1 34 3 4962 1 5280 1 3 nil nil 5 nil 4962 3 5280 33 nil 3 67108863 5 nil 4962 5 5280 1 nil 3 -67108863 5 nil 5280 1298 #tabWidth: 8 #(4) 5280 1298 #targetRange: 34 1 5090 1 -1 3 5280 1298 #maxCompletionListHeight: 8 #(9) 5280 1298 #edgeColumn: 8 #(1) 5280 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 216 5 0 0 118 1 0 0] 8 #() 1440 nil 33 2626 2658 8 'Method Source' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 2496 34 2 8 1445007428 1025 6656 3266 nil false 3312 nil 2930 26337781 nil 5 nil 1842 nil true 1874 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 6656 nil 8 1465073128 1970 nil nil 13 1420949905 170 192 34 4 #callTip 4002 77 4032 4048 1 nil nil nil nil #callTip nil nil nil #normal 4002 1 nil nil 1 nil nil nil nil #normal nil nil nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 3136 170 192 34 2 #default 4162 1 nil nil nil 6656 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 3136 nil 170 176 3136 9215 nil nil nil nil 4224 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #literalArray 8 '()' #specialCharacter 8 '()[]<>' 8 '' 3 170 192 34 2 #container 170 192 34 4 #callTip 6880 #normal 6896 nil nil nil nil 16 nil 170 192 34 12 1 4434 1 6656 2930 65025 3 false 1 nil nil nil nil nil nil 8 'indicator8' 4434 17 6656 4224 1 nil nil nil nil nil nil nil nil 8 'indicator10' 4434 21 6656 4528 3 nil nil nil nil nil nil nil nil 5 4434 5 6656 4528 1 false 5 nil nil nil nil nil nil 3 4434 3 6656 4496 5 false 3 nil nil nil nil nil nil 8 'indicator9' 4434 19 6656 4528 13 nil nil nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 4002 1027 2930 60239 2930 31326207 1 nil nil nil nil #Warning nil nil nil #Error 4002 1031 2930 335 2930 31317503 1 nil nil nil nil #Error nil nil nil #Notification 4002 1029 nil 2930 31185883 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 9 1298 #createAt:extent: 34 2 482 9 53 482 2985 697 6656 1298 #hoverTime: 8 #(500) 6656 1298 #caretPeriod: 8 #(530) 6656 1298 #wordWrap: 8 #(true) 6656 1298 #margins: 34 1 34 3 4962 1 6656 61 3 nil nil 5 nil 4962 3 6656 1 nil 3 67108863 nil nil 4962 5 6656 1 nil 3 -67108863 nil nil 6656 1298 #tabWidth: 8 #(4) 6656 1298 #targetRange: 34 1 5090 1 -1 3 6656 1298 #maxCompletionListHeight: 8 #(9) 6656 1298 #edgeColumn: 8 #(1) 6656 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 216 5 0 0 118 1 0 0] 8 #() 1440 nil 33 2626 2658 8 'Comparison' nil nil 410 ##(Smalltalk.ShellView) 34 27 nil 2496 34 2 8 1078919168 131073 8096 nil 1808 nil 517 nil nil nil 8096 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 8096 34 2 8 1140850688 131073 8192 nil 2930 26337781 nil 5 3346 nil true 34 5 3394 1 1058 #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 3394 1 1058 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 3394 1 1058 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 3394 1 1058 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 3394 1 1058 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 8192 514 170 176 3136 false 170 192 3136 nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 1 1 482 2953 665 8192 1298 #contextMenu: 34 1 8272 8192 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 196 5 0 0 76 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 8192 34 2 8 1140850688 131073 8800 nil 1808 nil 5 nil nil nil 8800 8162 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 8800 34 2 8 1140850945 262145 8880 nil nil nil 21 nil nil nil 8880 nil 8 1591672000 1970 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 1 625 482 1471 41 8880 1298 #text: 34 1 8 '
' 8880 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 223 2 0 0 76 1 0 0] 8 #() 1440 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 8800 34 2 8 1140920580 1025 9184 3266 nil false 3312 nil 2930 26337781 nil 21 nil nil nil 9184 nil 8 1465073128 1970 nil nil 13 1420980481 170 192 34 12 #whitespace 4002 3 1794 #teal nil 1 nil nil nil nil #whitespace nil nil nil #diff 4002 5 nil 2930 16908287 3 nil nil nil nil #diff nil 1401 nil #lineNumber 4002 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #normal 4002 1 nil nil 1 nil nil nil nil #normal nil nil nil #indentGuide 4002 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #callTip 4002 77 4032 4048 1 nil nil nil nil #callTip nil nil nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 4162 1 nil nil nil 9184 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 3136 nil 170 176 3136 9215 nil nil nil nil 4224 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #literalArray 8 '()' #specialCharacter 8 '()[]<>' 8 '' 3 170 192 34 2 #container 9312 nil nil nil nil 16 nil 170 192 34 2 #diff 4434 1 9184 1794 #yellow 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 4002 1027 2930 60239 2930 31326207 1 nil nil nil nil #Warning nil nil nil #Error 4002 1031 2930 335 2930 31317503 1 nil nil nil nil #Error nil nil nil #Notification 4002 1029 nil 2930 31185883 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 8 1298 #createAt:extent: 34 2 482 1 1 482 1471 625 9184 1298 #caretPeriod: 8 #(530) 9184 1298 #wordWrap: 8 #(true) 9184 1298 #margins: 34 1 34 3 4962 1 9184 49 3 nil nil nil nil 4962 3 9184 1 nil nil 67108863 nil nil 4962 5 9184 1 nil nil nil nil nil 9184 1298 #canHScroll: 8 #(false) 9184 1298 #targetRange: 34 1 5090 1 -1 3 9184 1298 #maxCompletionListHeight: 8 #(9) 9184 1298 #edgeColumn: 8 #(1) 9184 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 223 2 0 0 56 1 0 0] 8 #() 1440 nil 33 170 192 34 4 9184 8 'before' 8880 8 'beforeTitle' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 1471 665 8800 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 223 2 0 0 76 1 0 0] 34 2 9184 8880 1440 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 8192 34 2 8 1140850688 1 10640 nil 2930 66047 nil 517 nil nil nil 1510470 1 ##(Smalltalk.DraggableViewInteractor) 10640 nil 1 #left nil nil nil 482 1 1 482 9 9 nil 10752 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1471 1 482 11 665 10640 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 223 2 0 0 0 0 0 0 228 2 0 0 76 1 0 0] 8 #() 1440 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 8192 34 2 8 1140850688 131073 10944 nil 1808 nil 5 nil nil nil 10944 8162 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 10944 34 2 8 1140850945 262145 11024 nil nil nil 21 nil nil nil 11024 nil 8 1591672000 1970 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 1 625 482 1473 41 11024 1298 #text: 34 1 8 '
' 11024 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 224 2 0 0 76 1 0 0] 8 #() 1440 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 10944 34 2 8 1140920580 1025 11328 3266 nil false 3312 nil 2930 26337781 nil 21 nil nil nil 11328 nil 8 1465073128 1970 nil nil 13 1420984849 170 192 34 12 #whitespace 4002 3 9360 nil 1 nil nil nil nil #whitespace nil nil nil #diff 4002 5 nil 2930 16908287 3 nil nil nil nil #diff nil 1401 nil #lineNumber 4002 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #normal 4002 1 nil nil 1 nil nil nil nil #normal nil nil nil #indentGuide 4002 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #callTip 4002 77 4032 4048 1 nil nil nil nil #callTip nil nil nil nil 9474 9504 170 192 34 2 #default 4162 1 nil nil nil 11328 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 3136 nil 170 176 3136 9215 nil nil nil nil 4224 nil nil 65 nil nil 9600 9680 3 170 192 34 2 #container 11456 nil nil nil nil 16 nil 170 192 34 2 #diff 4434 1 11328 9776 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 4002 1027 2930 60239 2930 31326207 1 nil nil nil nil #Warning nil nil nil #Error 4002 1031 2930 335 2930 31317503 1 nil nil nil nil #Error nil nil nil #Notification 4002 1029 nil 2930 31185883 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 8 1298 #createAt:extent: 34 2 482 1 1 482 1473 625 11328 1298 #caretPeriod: 8 #(530) 11328 1298 #wordWrap: 8 #(true) 11328 1298 #margins: 34 1 34 3 4962 1 11328 49 3 nil nil nil nil 4962 3 11328 1 nil nil 67108863 nil nil 4962 5 11328 1 nil nil nil nil nil 11328 1298 #canHScroll: 8 #(false) 11328 1298 #targetRange: 34 1 5090 1 -1 3 11328 1298 #maxCompletionListHeight: 8 #(9) 11328 1298 #edgeColumn: 8 #(1) 11328 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 224 2 0 0 56 1 0 0] 8 #() 1440 nil 33 170 192 34 4 11024 8 'afterTitle' 11328 8 'after' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1481 1 482 1473 665 10944 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 228 2 0 0 0 0 0 0 196 5 0 0 76 1 0 0] 34 2 11328 11024 1440 nil 27 1440 nil 27 170 192 34 2 8192 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 3346 nil true 34 4 3394 1 1058 #selectUpper 8 'Select &upper' 1 1 nil nil nil 3394 1 1058 #selectLower 8 'Select &lower' 1 1 nil nil nil 3458 4097 3394 1 1058 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 26075 nil nil 3346 nil true 34 3 3394 1 1058 #character 8 '&Character' 1 1 nil nil nil 3394 1 1058 #word 8 '&Word' 1 1 nil nil nil 3394 1 1058 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 26077 nil nil 3346 nil true 34 1 3394 1 1058 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 26079 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 9 53 482 2985 697 8096 1298 #text: 34 1 8 'Comparison' 8096 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 216 5 0 0 118 1 0 0] 34 1 8192 1440 nil 27 8096 nil nil nil 170 192 34 10 8096 8 'comparisonTab' 2864 8 'sunit' 5280 8 'classDocumentation' 3200 8 'classDefinition' 6656 8 'methodSource' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 2496 34 2 8 1140916736 1 13552 590662 2 ##(Smalltalk.ListModel) 138 144 34 5 3168 5248 6624 2672 8064 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) nil nil 1 nil nil nil 13552 nil 8 1591529216 2706 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 13728 7 257 nil 2706 0 nil 13746 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 13792 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #smallIcons nil nil nil nil nil 1234 138 144 34 3 1298 #createAt:extent: 34 2 482 1 1 482 3001 757 13552 1298 #setSingleSelection: 8 #(5) 13552 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 13552 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 220 5 0 0 122 1 0 0] 8 #() 1440 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 3001 757 2496 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 220 5 0 0 122 1 0 0] 34 6 3200 5280 6656 2864 8096 13552 1440 nil 27 1618 1664 1 2224 1 1696 1 2240 -39 170 192 34 2 2496 8 'textAreaTabs' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 805 482 3001 797 576 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 146 1 0 0 220 5 0 0 32 3 0 0] 34 2 2496 704 1440 nil 27 25 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 14480 nil nil nil 5 nil nil nil 14480 514 170 176 34 8 410 ##(Smalltalk.ContainerView) 34 15 nil 14480 34 2 8 1140850688 131073 14592 nil nil nil 5 nil nil nil 14592 514 170 176 3136 false 170 192 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 14592 34 2 8 1140850688 131073 14720 nil nil nil 5 nil nil nil 14720 514 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 14720 34 2 8 1409286144 131073 14832 nil 1808 nil 21 nil nil nil 14832 2562 138 144 3136 nil nil nil nil 170 192 3136 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 14832 34 2 8 1140916736 1 14944 13618 138 144 3136 nil 13696 nil nil 17 nil nil nil 14944 nil 8 1591529216 2706 0 nil 13746 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 15056 7 257 nil 2706 0 nil 13746 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 15104 7 257 nil 13856 nil nil nil nil nil #noIcons nil nil nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 1 1 482 477 795 14944 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 14944 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 238 0 0 0 141 1 0 0] 8 #() 1440 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 477 795 14832 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 238 0 0 0 141 1 0 0] 34 1 14944 1440 nil 27 3 false 170 192 34 2 14832 8 'packageDictionaryCards' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 485 1 482 477 795 14720 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 242 0 0 0 0 0 0 0 224 1 0 0 141 1 0 0] 34 1 14832 1440 nil 27 8 'packageDictionaryContainer' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 433 1 482 961 795 14592 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 216 0 0 0 0 0 0 0 184 2 0 0 141 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 14592 34 2 8 1140850688 131073 15888 nil nil nil 5 nil nil nil 15888 514 170 176 3136 false 170 192 3136 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 475 795 15888 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 237 0 0 0 141 1 0 0] 34 1 410 ##(Smalltalk.CardContainer) 34 16 nil 15888 34 2 8 1409286144 131073 16160 nil 1808 nil 5 nil nil nil 16160 2562 138 144 34 1 2626 8 'Package Groups' 410 ##(Smalltalk.JadeiteTreeView) 34 28 nil 16160 34 2 8 1140916775 1025 16304 1049670 3 ##(Smalltalk.JadeiteTreeModel) nil 13696 984070 ##(Smalltalk.JadeiteTreeNode) nil nil nil nil 170 192 3136 1808 nil 5 nil nil nil 16304 nil 8 1591603216 2706 0 nil 2738 2 1 ##(Smalltalk.Message) 8 'doIt' 8 '[:service | service displayString]' 8 #[30 105 226 0 106] #displayString 16464 7 257 nil ##(Smalltalk.IconicListAbstract) 13856 nil nil nil nil nil 170 176 3136 33 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 3136 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 9 53 482 459 735 16304 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 233 0 0 0 137 1 0 0] 8 #() 1440 nil 27 16304 nil nil nil 170 192 34 2 16304 8 'componentTree' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 16160 34 2 8 1140916736 1 16784 13618 138 144 34 1 16288 nil 13696 nil nil 1 nil nil nil 16784 nil 8 1591529216 2706 0 nil 13746 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 16912 7 257 nil 2706 0 nil 13746 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 16960 7 257 nil 13856 nil nil nil nil nil #noIcons nil nil nil nil nil 1234 138 144 34 3 1298 #createAt:extent: 34 2 482 1 1 482 475 795 16784 1298 #setSingleSelection: 8 #(1) 16784 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 16784 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 237 0 0 0 141 1 0 0] 8 #() 1440 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 475 795 16160 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 237 0 0 0 141 1 0 0] 34 2 16304 16784 1440 nil 27 1440 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 14592 34 2 8 1140850688 1 17392 nil 1808 nil 517 nil nil nil 10722 17392 nil 1 #left nil nil nil 10752 10768 nil 10752 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 475 1 482 11 795 17392 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 237 0 0 0 0 0 0 0 242 0 0 0 141 1 0 0] 8 #() 1440 nil 27 14720 1440 nil 27 524806 ##(Smalltalk.Fraction) 3 7 410 ##(Smalltalk.ContainerView) 34 15 nil 14480 34 2 8 1140850688 131073 17664 nil nil nil 5 nil nil nil 17664 514 170 176 34 4 410 ##(Smalltalk.CardContainer) 34 16 nil 17664 34 2 8 1409286144 131073 17776 nil 1808 nil 5 nil nil nil 17776 2562 138 144 34 2 2626 8 'Category' 410 ##(Smalltalk.ListView) 34 45 nil 17776 34 2 8 1409372233 1025 17920 13618 138 144 3136 nil 13696 1808 nil 21 nil nil nil 17920 nil 8 1591759072 459270 ##(Smalltalk.Message) #displayString 8 #() nil 13856 nil nil nil nil nil nil 138 144 34 1 920646 5 ##(Smalltalk.ListViewColumn) 8 'Column 1' 351 #left 18034 #displayString 8 #() ##(Smalltalk.SortedCollection) 2706 0 nil 2738 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each]' 1779525917 18192 7 257 nil nil 17920 nil 3 nil nil #report 8 #() nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 9 53 482 359 735 17920 1298 #text: 34 1 8 'Column 1' 17920 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 183 0 0 0 137 1 0 0] 8 #() 1440 nil 35 2626 8 'Variables' 410 ##(Smalltalk.ListView) 34 45 nil 17776 34 2 8 1409372233 1025 18512 13618 138 144 3136 nil 13696 1808 nil 21 nil nil nil 18512 nil 8 1591759072 18034 #displayString 8 #() nil 13856 nil nil 2706 0 nil 2738 4 1 2704 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 18656 7 257 nil nil nil nil 138 144 34 1 18114 8 'Column 1' 351 #left 18034 #displayString 18640 ##(Smalltalk.SortedCollection) nil nil 18512 nil 3 nil 2706 0 nil 2738 4 1 2704 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 18816 7 257 nil #report 18256 nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 9 53 482 359 735 18512 1298 #text: 34 1 8 'Column 1' 18512 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 183 0 0 0 137 1 0 0] 8 #() 1440 nil 35 17920 nil nil nil 170 192 34 4 17920 8 'categoryList' 18512 8 'variableList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 17776 34 2 8 1140916736 1 19168 13618 138 144 34 2 17904 18496 nil 13696 nil nil 1 nil nil nil 19168 nil 8 1591529216 2706 0 nil 13746 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 19296 7 257 nil 2706 0 nil 13746 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 19344 7 257 nil 13856 nil nil nil nil nil #noIcons nil nil nil nil nil 1234 138 144 34 3 1298 #createAt:extent: 34 2 482 1 1 482 375 795 19168 1298 #setSingleSelection: 8 #(1) 19168 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 19168 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 187 0 0 0 141 1 0 0] 8 #() 1440 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 375 795 17776 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 187 0 0 0 141 1 0 0] 34 3 17920 18512 19168 1440 nil 27 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 232 63 410 ##(Smalltalk.ContainerView) 34 15 nil 17664 34 2 8 1140850688 131073 19808 nil nil nil 5 nil nil nil 19808 642 170 176 34 6 410 ##(Smalltalk.ListView) 34 45 nil 19808 34 2 8 1409372233 1025 19920 13618 138 144 3136 nil 13696 1808 nil 13 nil nil nil 19920 nil 8 1591759072 18034 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 13856 nil nil nil nil nil nil 138 144 34 2 18114 8 '' 41 #left 1298 #empty 8 #() 16 18034 #<= 8 #() nil nil 19920 2706 0 nil 2738 2 1 2704 8 'doIt' 8 '[:each | each subSuperIcon]' 8 #[30 105 226 0 106] #subSuperIcon 20192 7 257 nil 1 nil nil 18114 8 'Selector' 581 #left 18034 #displayString 20048 ##(Smalltalk.SortedCollection) nil nil 19920 nil 3 nil 2706 0 nil 2738 5 1 2704 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 20320 7 257 nil #report 18256 nil 133221 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 55 482 629 691 19920 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 27 0 0 0 58 1 0 0 116 1 0 0] 8 #() 1440 nil 35 1618 1664 1 2224 1 1696 55 2240 -49 410 ##(Smalltalk.PushButton) 34 20 nil 19808 34 2 8 1140858880 1 20576 nil 1808 nil 5 nil nil nil 20576 nil 8 1591823792 1058 #gotoMethodDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 745 482 629 51 20576 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 116 1 0 0 58 1 0 0 141 1 0 0] 8 #() 1440 nil 29 1618 1664 1 2224 1 2240 -49 2240 1 410 ##(Smalltalk.TextEdit) 34 16 nil 19808 34 2 8 1140916352 1025 20848 nil 1808 nil 5 nil nil nil 20848 nil 8 1591815600 1970 nil nil 3 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 629 51 20848 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 58 1 0 0 25 0 0 0] 8 #() 1440 nil 27 1618 1664 1 2224 1 1696 1 1696 51 170 192 34 6 19920 8 'methodList' 20576 8 'definedPackageMethodText' 20848 8 'categoryMethodText' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 385 1 482 629 795 19808 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 192 0 0 0 0 0 0 0 250 1 0 0 141 1 0 0] 34 3 19920 20576 20848 1440 nil 27 19778 8 0 0 0 0 0 0 244 63 false 170 192 34 2 17776 8 'methodFilterTabs' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1989 1 482 1013 795 17664 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 226 3 0 0 0 0 0 0 220 5 0 0 141 1 0 0] 34 3 17776 410 ##(Smalltalk.Splitter) 34 12 nil 17664 34 2 8 1140850688 1 21584 nil 1808 nil 517 nil nil nil 10722 21584 nil 1 #left nil nil nil 10752 10768 nil 10752 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 375 1 482 11 795 21584 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 187 0 0 0 0 0 0 0 192 0 0 0 141 1 0 0] 8 #() 1440 nil 27 19808 1440 nil 27 17634 15 41 410 ##(Smalltalk.ContainerView) 34 15 nil 14480 34 2 8 1140850688 131073 21840 nil nil nil 5 nil nil nil 21840 642 170 176 34 6 410 ##(Smalltalk.CardContainer) 34 16 nil 21840 34 2 8 1409286144 131073 21952 nil 1808 nil 5 nil nil nil 21952 2562 138 144 34 2 2626 2658 8 'Classes' nil nil 410 ##(Smalltalk.ListView) 34 45 nil 21952 34 2 8 1409372237 1025 22112 13618 138 144 3136 nil 13696 1808 nil 29 nil nil nil 22112 nil 8 1591759072 18034 #displayString 8 #() nil 13856 nil nil nil nil nil nil 138 144 34 1 18114 8 '' 553 #left 18034 #displayString 8 #() 18034 #<= 8 #() nil nil 22112 nil 3 nil 2706 0 nil 2738 5 1 2704 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 22384 7 257 nil #report 18256 nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 9 53 482 561 635 22112 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 28 1 0 0 87 1 0 0] 8 #() 1440 nil 35 2626 2658 8 'Hierarchy' nil nil 410 ##(Smalltalk.JadeiteTreeView) 34 28 nil 21952 34 2 8 1140920871 1025 22672 16370 nil 3312 16402 nil nil nil nil 170 176 3136 1808 nil 29 nil nil nil 22672 nil 8 1591603216 2706 0 nil 2738 2 1 2704 8 'doIt' 8 '[:each | each displayString]' 8 #[30 105 226 0 106] #displayString 22800 7 257 nil ##(Smalltalk.IconicListAbstract) 13856 nil 2706 0 nil 2738 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 22880 7 257 nil 2706 0 nil 2738 5 1 2704 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 22960 7 257 nil nil nil 170 176 3136 33 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 3136 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 9 53 482 561 635 22672 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 28 1 0 0 87 1 0 0] 8 #() 1440 nil 27 22112 nil nil nil 170 192 34 4 22672 8 'classHierarchy' 22112 8 'classList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 21952 34 2 8 1140916736 1 23296 13618 138 144 34 2 22080 22640 nil 13696 nil nil 1 nil nil nil 23296 nil 8 1591529216 2706 0 nil 13746 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 23424 7 257 nil 2706 0 nil 13746 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 23472 7 257 nil 13856 nil nil nil nil nil #smallIcons nil nil nil nil nil 1234 138 144 34 3 1298 #createAt:extent: 34 2 482 1 1 482 577 695 23296 1298 #setSingleSelection: 8 #(1) 23296 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 23296 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 32 1 0 0 91 1 0 0] 8 #() 1440 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 577 695 21952 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 32 1 0 0 91 1 0 0] 34 3 22112 22672 23296 1440 nil 27 1618 1664 1 2224 1 1696 1 2240 -99 410 ##(Smalltalk.CardContainer) 34 16 nil 21840 34 2 8 1409286144 131073 23920 nil 1808 nil 5 nil 1842 nil true 524550 ##(Smalltalk.LOGFONTW) 8 #[240 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 188 2 0 0 0 0 0 0 1 2 1 34 83 0 121 0 115 0 116 0 101 0 109 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 23920 2562 138 144 34 2 2626 2658 8 'Class' nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 23920 34 2 8 1140850688 131073 24160 nil nil nil 5 nil nil nil 24160 nil 170 192 3136 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 9 9 482 561 1 24160 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 28 1 0 0 4 0 0 0] 8 #() 1440 nil 27 2626 2658 8 'Instance' nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 23920 34 2 8 1140850688 131073 24448 nil nil nil 5 nil nil nil 24448 nil 170 192 3136 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 9 9 482 561 1 24448 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 28 1 0 0 4 0 0 0] 8 #() 1440 nil 27 24448 nil nil nil 170 192 34 4 24160 8 'classTab' 24448 8 'instanceTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 23920 34 2 8 1140916738 1 24752 13618 138 144 34 2 24416 24128 nil 13696 nil nil 1 nil nil nil 24752 nil 8 1591529216 2706 0 nil 13746 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 24880 7 257 nil 2706 0 nil 13746 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 24928 7 257 nil 13856 nil nil nil nil nil #smallIcons nil nil nil nil nil 1234 138 144 34 3 1298 #createAt:extent: 34 2 482 1 1 482 577 51 24752 1298 #setSingleSelection: 8 #(1) 24752 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 24752 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 32 1 0 0 25 0 0 0] 8 #() 1440 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 695 482 577 51 23920 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 91 1 0 0 32 1 0 0 116 1 0 0] 34 3 24448 24160 24752 1440 nil 27 1618 1664 1 2224 1 2240 -99 1712 51 410 ##(Smalltalk.PushButton) 34 20 nil 21840 34 2 8 1140858880 1 25376 nil 4224 nil 5 nil nil nil 25376 nil 8 1591823792 1058 #gotoClassDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 745 482 577 51 25376 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 116 1 0 0 32 1 0 0 141 1 0 0] 8 #() 1440 nil 29 1618 1664 1 2224 1 2240 -49 2240 1 170 192 34 6 21952 8 'classHierarchyTabs' 23920 8 'instanceClassTabs' 25376 8 'definedPackageClassText' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1403 1 482 577 795 21840 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 189 2 0 0 0 0 0 0 221 3 0 0 141 1 0 0] 34 3 21952 23920 25376 1440 nil 27 17634 3 11 410 ##(Smalltalk.ContainerView) 34 15 nil 14480 34 2 8 1140850688 131073 25904 nil nil nil 5 nil nil nil 25904 514 170 176 3136 false 170 192 34 2 410 ##(Smalltalk.ListView) 34 45 nil 25904 34 2 8 1409405261 1025 26032 13618 138 144 3136 nil 13696 1808 nil 5 nil nil nil 26032 nil 8 1591759072 18034 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 13856 nil nil nil nil nil nil 138 144 34 1 18114 8 'Column 1' 425 #left 2706 0 nil 2738 2 1 2704 8 'doIt' 8 '[:each | each displayName]' 8 #[30 105 226 0 106] #displayName 26240 7 257 nil ##(Smalltalk.SortedCollection) nil nil 26032 nil 3 2706 0 nil 2738 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 26320 7 257 nil 2706 0 nil 2738 3 1 2704 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 26400 7 257 nil #report 18256 nil 133217 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 1 1 482 433 795 26032 1298 #text: 34 1 8 'Column 1' 26032 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 216 0 0 0 141 1 0 0] 8 #() 1440 nil 35 8 'projectList' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 433 795 25904 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 216 0 0 0 141 1 0 0] 34 1 26032 1440 nil 27 17634 7 41 false 170 192 34 2 14592 8 'componentPackageContainer' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 3001 795 14480 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 220 5 0 0 141 1 0 0] 34 6 25904 14592 410 ##(Smalltalk.Splitter) 34 12 nil 14480 34 2 8 1140850688 1 27088 nil 1808 nil 517 nil nil nil 10722 27088 nil 1 #left nil nil nil 10752 10768 nil 10752 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1393 1 482 11 795 27088 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 184 2 0 0 0 0 0 0 189 2 0 0 141 1 0 0] 8 #() 1440 nil 27 21840 410 ##(Smalltalk.Splitter) 34 12 nil 14480 34 2 8 1140850688 1 27328 nil 1808 nil 517 nil nil nil 10722 27328 nil 1 #left nil nil nil 10752 10768 nil 10752 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1979 1 482 11 795 27328 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 221 3 0 0 0 0 0 0 226 3 0 0 141 1 0 0] 8 #() 1440 nil 27 17664 1440 nil 27 25 true 170 192 34 2 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 27600 nil 1808 nil 517 nil nil nil 10722 27600 nil 1 #left nil nil nil 10752 10768 nil 10752 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 795 482 3001 11 27600 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 141 1 0 0 220 5 0 0 146 1 0 0] 8 #() 1440 nil 27 8 'splitter' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 6513 21 482 3001 1601 416 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 184 12 0 0 10 0 0 0 148 18 0 0 42 3 0 0] 34 3 14480 27600 576 1440 nil 27 )! !
!JadeiteBrowserPresenter class categoriesForMethods!
resource_Default_view!public!resources-views! !
!

