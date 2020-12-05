"Filed out from Dolphin Smalltalk 7"!

JadeiteProjectsBrowserPresenter subclass: #JadeiteBrowserPresenter
	instanceVariableNames: 'dictionaryPresenter packageDictionaryCards globalsTab autoCommitButton search previousTabViewArrangement previousTopViewArrangement specEditor componentListPresenter componentPackageContainer packageDictionaryContainer loadSpecTab'
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

componentListPresenter: anObject
	componentListPresenter := anObject!

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
			[classService command: #fullHierarchy.
			self issueCommand: classService.
			self selectClassNamed: classService name.
			classHierarchyPresenter view expandAll]!

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
	^#('Projects' 'Create ...//createNewProject' 'Load Git Project ...//loadV2Project' 'Reload Project //reloadV2Project' 'Unload//unloadProjects' '-' 'Pull from Git//pullFromGit' 'Commit to Git ...//gitCommit' 'Push to Git//pushToGit' '-' '&Changes//projectChanges' 'Write//writeProject' 'Checkout Git Tag ...//checkoutTag' 'Checkout Git Branch ...//checkout' '-' '&Add Package...//addPackage' '-' 'Audit//auditProject' 'Git Log//projectLog' '&Refresh//refreshFromServer')!

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
	self isNoneProjectSelected
		ifTrue: 
			[self
				removeProjectTab;
				removeLoadSpecTab]
		ifFalse: [self removeGlobalsTab]!

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
					[self selectClassInClassListNamed: classService name.
					self updateHierarchy]]!

updateAfterFindClassInPackage: classService
	packageListPresenter list detect: [:service | service name = classService definedPackageName]
		ifNone: [self projectListPresenter selectionByIndex: 0	"display full list of packages"].
	self selectPackageNamed: classService packageName.
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
!JadeiteBrowserPresenter categoriesFor: #abortTransaction!public!transaction management! !
!JadeiteBrowserPresenter categoriesFor: #addDictionary!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #additionalAccelerators!constants!public! !
!JadeiteBrowserPresenter categoriesFor: #addNoneProject!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #addSystemBrowser!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #allSelectedProjectsDirty!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #auditProject!project menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #basicAddDictionaryNamed:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #basicCopyClass:to:!menu handlers support!private! !
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
!JadeiteBrowserPresenter categoriesFor: #buildInfoTab:!private!tabs! !
!JadeiteBrowserPresenter categoriesFor: #buildLoadSpecTabIfNecessary!private!tabs! !
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
!JadeiteBrowserPresenter categoriesFor: #copyInfo!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #copyLoadSpecInfo!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #copyProjectInfo!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #createComponents!initialize/release!public! !
!JadeiteBrowserPresenter categoriesFor: #createListViewFor:!private! !
!JadeiteBrowserPresenter categoriesFor: #createNewProject!menu handlers!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #createSchematicWiring!initialize/release!public! !
!JadeiteBrowserPresenter categoriesFor: #createSchematicWiringForClassHierarchy!create schemantic wiring!public! !
!JadeiteBrowserPresenter categoriesFor: #createSchematicWiringForClassList!create schemantic wiring!public! !
!JadeiteBrowserPresenter categoriesFor: #createSchematicWiringForMethodList!create schemantic wiring!public! !
!JadeiteBrowserPresenter categoriesFor: #createSchematicWiringForMethodSource!initialize/release!public! !
!JadeiteBrowserPresenter categoriesFor: #createSchematicWiringForProjectList!create schemantic wiring!public! !
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
!JadeiteBrowserPresenter categoriesFor: #findClass!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #findRemovedServices!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #gitCommit!project menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #globalsMenu!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #globalsMenuStrings!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #globalsTab!accessing!private! !
!JadeiteBrowserPresenter categoriesFor: #gotoClassDefinedPackage!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #gotoDictionary!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #gotoDictionaryNamed:!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #hasCategorySelected!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #hasExactlyOneCategorySelected!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #insertCompileErrorText:into:!compile support!public! !
!JadeiteBrowserPresenter categoriesFor: #insertIfFalse!menu handlers!must not strip!public! !
!JadeiteBrowserPresenter categoriesFor: #insertIfTrue!menu handlers!must not strip!public! !
!JadeiteBrowserPresenter categoriesFor: #inspectGlobal!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #inspectMethod!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #inspectorContextObject!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #isClassDefinitionTabSelected!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #isClassSelected!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #isComparisonTabSelected!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #isDictionariesTabSelected!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #isHierarchyTabSelected!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #isLoadSpecTabSelected!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #isMethodSourceTabSelected!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #isNoneProjectSelected!event handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #isOkayToChange!event handlers!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #isProjectInfoTabSelected!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #isProjectItemEnabled:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #isRowanProjectSelected!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #isSourceTabSelected!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #isSunitTabSelected!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #jadeInspect!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #loadProjects!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #loadSpecMenu!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #loadSpecMenuStrings!menus!public! !
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
!JadeiteBrowserPresenter categoriesFor: #moveMethodsToPackageNamed:!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #moveMethodToPackage!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #newProjectNamed:!menu handlers!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #noClassSelectedInEitherPresenter!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #onDragClass:!drag & drop!public! !
!JadeiteBrowserPresenter categoriesFor: #onDragMethod:!drag & drop!public! !
!JadeiteBrowserPresenter categoriesFor: #onDragOverPackageList:!drag & drop!public! !
!JadeiteBrowserPresenter categoriesFor: #onDropClassesOnPackage:session:!drag & drop!public! !
!JadeiteBrowserPresenter categoriesFor: #onDropClassesOnPackageList:!drag & drop!public! !
!JadeiteBrowserPresenter categoriesFor: #onDropMethodsOnPackageList:!drag & drop!public! !
!JadeiteBrowserPresenter categoriesFor: #onDropMethodsOnPackageList:session:!drag & drop!public! !
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
!JadeiteBrowserPresenter categoriesFor: #projectChanges!project menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #projectInfoMenu!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #projectInfoMenuStrings!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #projectInfoTab!accessing!public! !
!JadeiteBrowserPresenter categoriesFor: #projectLog!project menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #projectMenu!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #projectMenuCommands!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #projectMenuStrings!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #projectTabLabel!displaying!private! !
!JadeiteBrowserPresenter categoriesFor: #protectedDictionaries!constants!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #pullFromGit!project menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #pushToGit!project menu handlers!public! !
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
!JadeiteBrowserPresenter categoriesFor: #removeLoadSpecTab!private!tabs! !
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
!JadeiteBrowserPresenter categoriesFor: #symbolExists:!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #textTabChanged!event handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #togglePackageDictionaryColumn!event handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #unloadProjects!project menu handlers!public! !
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
!JadeiteBrowserPresenter categoriesFor: #updateLoadSpecInfoTabFor:!private!tabs! !
!JadeiteBrowserPresenter categoriesFor: #updateMenuBar!menus!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateMethodSourceColor!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateProject!event handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateProjectInfo!private!tabs! !
!JadeiteBrowserPresenter categoriesFor: #updateProjectInfoTabFor:!private!tabs! !
!JadeiteBrowserPresenter categoriesFor: #updateSystemTab!event handlers support!private!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateTabLabel!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #variablesMenuStrings!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #writeProject!project menu handlers!public! !

!JadeiteBrowserPresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil 328198 ##(Smalltalk.Point) 3001 1601 517 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 576 nil nil nil 5 nil nil nil 576 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.CardContainer) 34 16 nil 576 34 2 8 1409286144 131073 704 nil 327686 ##(Smalltalk.Color) #default nil 5 nil nil nil 704 656710 1 ##(Smalltalk.CardLayout) 138 144 34 5 721414 ##(Smalltalk.Association) 590662 1 ##(Smalltalk.CardLabel) 8 'SUnit' 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 4 1 944 8 'doIt' 8 '[Icon fromId: ''icons\UnitTestPlugin.ico'']' 8 #[32 105 45 30 178 106] 983558 ##(Smalltalk.VariableBinding) #Icon ##(Smalltalk.Icon) 8 'icons\UnitTestPlugin.ico' #fromId: 960 7 1 nil nil 410 ##(Smalltalk.ReferenceView) 34 14 nil 704 34 2 8 1140850688 131073 1104 nil 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 nil nil nil 1104 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteSUnitInClassPresenter) #resource_Default_view nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 482 9 53 482 2985 697 1104 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 216 5 0 0 118 1 0 0] 8 #() 482 193 193 nil 27 866 898 8 'Class Definition' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 704 34 2 8 1445007428 1025 1504 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 1170 26337781 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 11 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #editSave 8 '&Save' 9383 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 1698 1 1730 #editUndo 8 '&Undo' 9397 1 nil nil nil 1698 1 1730 #editRedo 8 '&Redo' 9395 1 nil nil nil 1778 4097 1698 1 1730 #editCut 8 'Cu&t' 9393 1 nil nil nil 1698 1 1730 #editCopy 8 '&Copy' 9351 1 nil nil nil 1698 1 1730 #editPaste 8 '&Paste' 9389 1 nil nil nil 1698 1 1730 #editDelete 8 '&Delete' 1629 1 nil nil nil 1778 4097 1698 1 1730 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 1504 nil 8 1429223005 852486 ##(Smalltalk.NullConverter) nil nil 13 nil 170 192 34 4 #normal 1182790 1 ##(Smalltalk.ScintillaTextStyle) 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 2370 77 770 #gray 770 #white 1 nil nil nil nil #callTip nil nil nil nil 1639686 ##(Smalltalk.SmalltalkExpressionStyler) 1 nil nil false 138 144 1424 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 1504 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1424 nil 170 176 1424 9215 nil nil nil nil 770 #silver nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 2384 nil nil nil nil 1 nil 170 192 34 6 1 1510470 3 ##(Smalltalk.ScintillaIndicatorStyle) 1 1504 1170 65025 3 false 1 nil nil nil nil nil nil 3 2802 3 1504 770 #blue 5 false 3 nil nil nil nil nil nil 5 2802 5 1504 770 #red 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 2370 1027 1170 60239 1170 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2370 1031 1170 335 1170 31317503 1 nil nil nil nil #Error nil nil nil #Notification 2370 1029 nil 1170 31185883 1 nil nil nil nil #Notification nil nil nil nil 1234 138 144 34 9 1298 #createAt:extent: 34 2 482 9 53 482 2985 697 1504 1298 #contextMenu: 34 1 1664 1504 1298 #caretPeriod: 8 #(530) 1504 1298 #wordWrap: 8 #(true) 1504 1298 #margins: 34 1 34 3 985158 3 ##(Smalltalk.ScintillaMargin) 1 1504 1 3 nil nil 5 nil 3330 3 1504 33 nil 3 67108863 5 nil 3330 5 1504 1 nil 3 -67108863 5 nil 1504 1298 #tabWidth: 8 #(4) 1504 1298 #targetRange: 34 1 525062 ##(Smalltalk.Interval) 1 -1 3 1504 1298 #maxCompletionListHeight: 8 #(9) 1504 1298 #edgeColumn: 8 #(1) 1504 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 216 5 0 0 118 1 0 0] 8 #() 1440 nil 29 866 898 8 'Class Documentation' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 704 34 2 8 1445007428 1025 3648 1570 nil false 1616 nil 1170 26337781 nil 5 1650 nil true 34 1 1698 1 1730 #editSaveClassComment 8 'Save' 1025 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 2194 nil true 2226 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 3648 nil 8 1429223005 2306 nil nil 15 nil 170 192 34 4 #normal 2370 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 2370 77 2416 2432 1 nil nil nil nil #callTip nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 2530 1 nil nil nil 3648 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1424 nil 170 176 1424 9215 nil nil nil nil 2592 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 3968 nil nil nil nil 1 nil 170 192 34 6 1 2802 1 3648 1170 65025 3 false 1 nil nil nil nil nil nil 3 2802 3 3648 2864 5 false 3 nil nil nil nil nil nil 5 2802 5 3648 2896 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 2370 1027 1170 60239 1170 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2370 1031 1170 335 1170 31317503 1 nil nil nil nil #Error nil nil nil #Notification 2370 1029 nil 1170 31185883 1 nil nil nil nil #Notification nil nil nil nil 1234 138 144 34 10 1298 #createAt:extent: 34 2 482 9 53 482 2985 697 3648 1298 #contextMenu: 34 1 3744 3648 1298 #hoverTime: 8 #(1000000) 3648 1298 #caretPeriod: 8 #(530) 3648 1298 #wordWrap: 8 #(true) 3648 1298 #margins: 34 1 34 3 3330 1 3648 1 3 nil nil 5 nil 3330 3 3648 33 nil 3 67108863 5 nil 3330 5 3648 1 nil 3 -67108863 5 nil 3648 1298 #tabWidth: 8 #(4) 3648 1298 #targetRange: 34 1 3458 1 -1 3 3648 1298 #maxCompletionListHeight: 8 #(9) 3648 1298 #edgeColumn: 8 #(1) 3648 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 216 5 0 0 118 1 0 0] 8 #() 1440 nil 29 866 898 8 'Method Source' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 704 34 2 8 1445007428 1025 5024 1570 nil false 1616 nil 1170 26337781 nil 5 nil 2194 nil true 2226 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 5024 nil 8 1429223005 2306 nil nil 13 nil 170 192 34 4 #normal 2370 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 2370 77 2416 2432 1 nil nil nil nil #callTip nil nil nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 1424 170 192 34 2 #default 2530 1 nil nil nil 5024 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1424 nil 170 176 1424 9215 nil nil nil nil 2592 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 4 #normal 5248 #callTip 5264 nil nil nil nil 1 nil 170 192 34 12 1 2802 1 5024 1170 65025 3 false 1 nil nil nil nil nil nil 8 'indicator8' 2802 17 5024 2592 1 nil nil nil nil nil nil nil nil 8 'indicator10' 2802 21 5024 2896 3 nil nil nil nil nil nil nil nil 3 2802 3 5024 2864 5 false 3 nil nil nil nil nil nil 8 'indicator9' 2802 19 5024 2896 13 nil nil nil nil nil nil nil nil 5 2802 5 5024 2896 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 2370 1027 1170 60239 1170 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2370 1031 1170 335 1170 31317503 1 nil nil nil nil #Error nil nil nil #Notification 2370 1029 nil 1170 31185883 1 nil nil nil nil #Notification nil nil nil nil 1234 138 144 34 9 1298 #createAt:extent: 34 2 482 9 53 482 2985 697 5024 1298 #hoverTime: 8 #(500) 5024 1298 #caretPeriod: 8 #(530) 5024 1298 #wordWrap: 8 #(true) 5024 1298 #margins: 34 1 34 3 3330 1 5024 61 3 nil nil 5 nil 3330 3 5024 1 nil 3 67108863 nil nil 3330 5 5024 1 nil 3 -67108863 nil nil 5024 1298 #tabWidth: 8 #(4) 5024 1298 #targetRange: 34 1 3458 1 -1 3 5024 1298 #maxCompletionListHeight: 8 #(9) 5024 1298 #edgeColumn: 8 #(1) 5024 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 216 5 0 0 118 1 0 0] 8 #() 1440 nil 29 866 898 8 'Comparison' nil nil 410 ##(Smalltalk.ShellView) 34 27 nil 704 34 2 8 1078919168 131073 6464 nil 784 nil 517 nil nil nil 6464 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 6464 34 2 8 1140850688 131073 6560 nil 1170 26337781 nil 5 1650 nil true 34 5 1698 1 1730 #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 1698 1 1730 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 1698 1 1730 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 1698 1 1730 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 1698 1 1730 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 6560 514 170 176 1424 false 170 192 1424 nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 1 1 482 2953 665 6560 1298 #contextMenu: 34 1 6640 6560 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 196 5 0 0 76 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 6560 34 2 8 1140850688 131073 7168 nil 784 nil 5 nil nil nil 7168 6530 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 7168 34 2 8 1140850945 262145 7248 nil nil nil 21 nil nil nil 7248 nil 8 1737263776 2306 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 1 625 482 1471 41 7248 1298 #text: 34 1 8 '
' 7248 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 223 2 0 0 76 1 0 0] 8 #() 1440 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 7168 34 2 8 1140920580 1025 7552 1570 nil false 1616 nil 1170 26337781 nil 21 nil nil nil 7552 nil 8 1429223005 2306 nil nil 13 nil 170 192 34 12 #callTip 2370 77 2416 2432 1 nil nil nil nil #callTip nil nil nil #indentGuide 2370 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 2370 3 770 #teal nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 2370 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #normal 2370 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 2370 5 nil 1170 16908287 3 nil nil nil nil #diff nil 1401 nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 2530 1 nil nil nil 7552 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1424 nil 170 176 1424 9215 nil nil nil nil 2592 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 7680 nil nil nil nil 1 nil 170 192 34 2 #diff 2802 1 7552 770 #yellow 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 2370 1027 1170 60239 1170 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2370 1031 1170 335 1170 31317503 1 nil nil nil nil #Error nil nil nil #Notification 2370 1029 nil 1170 31185883 1 nil nil nil nil #Notification nil nil nil nil 1234 138 144 34 8 1298 #createAt:extent: 34 2 482 1 1 482 1471 625 7552 1298 #caretPeriod: 8 #(530) 7552 1298 #wordWrap: 8 #(true) 7552 1298 #margins: 34 1 34 3 3330 1 7552 49 3 nil nil nil nil 3330 3 7552 1 nil nil 67108863 nil nil 3330 5 7552 1 nil nil nil nil nil 7552 1298 #canHScroll: 8 #(false) 7552 1298 #targetRange: 34 1 3458 1 -1 3 7552 1298 #maxCompletionListHeight: 8 #(9) 7552 1298 #edgeColumn: 8 #(1) 7552 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 223 2 0 0 56 1 0 0] 8 #() 1440 nil 29 170 192 34 4 7552 8 'before' 7248 8 'beforeTitle' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 1471 665 7168 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 223 2 0 0 76 1 0 0] 34 2 7552 7248 1440 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 6560 34 2 8 1140850688 1 9008 nil 1170 66047 nil 517 nil nil nil 1510470 1 ##(Smalltalk.DraggableViewInteractor) 9008 nil 1 #left nil nil nil 482 1 1 482 9 9 nil 9120 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1471 1 482 11 665 9008 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 223 2 0 0 0 0 0 0 228 2 0 0 76 1 0 0] 8 #() 1440 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 6560 34 2 8 1140850688 131073 9312 nil 784 nil 5 nil nil nil 9312 6530 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 9312 34 2 8 1140850945 262145 9392 nil nil nil 21 nil nil nil 9392 nil 8 1737263776 2306 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 1 625 482 1473 41 9392 1298 #text: 34 1 8 '
' 9392 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 224 2 0 0 76 1 0 0] 8 #() 1440 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 9312 34 2 8 1140920580 1025 9696 1570 nil false 1616 nil 1170 26337781 nil 21 nil nil nil 9696 nil 8 1429223005 2306 nil nil 13 nil 170 192 34 12 #callTip 2370 77 2416 2432 1 nil nil nil nil #callTip nil nil nil #indentGuide 2370 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 2370 3 7760 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 2370 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #normal 2370 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 2370 5 nil 1170 16908287 3 nil nil nil nil #diff nil 1401 nil nil 7842 7872 170 192 34 2 #default 2530 1 nil nil nil 9696 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1424 nil 170 176 1424 9215 nil nil nil nil 2592 nil nil 65 nil nil 7968 8048 3 170 192 34 2 #container 9824 nil nil nil nil 1 nil 170 192 34 2 #diff 2802 1 9696 8144 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 2370 1027 1170 60239 1170 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2370 1031 1170 335 1170 31317503 1 nil nil nil nil #Error nil nil nil #Notification 2370 1029 nil 1170 31185883 1 nil nil nil nil #Notification nil nil nil nil 1234 138 144 34 8 1298 #createAt:extent: 34 2 482 1 1 482 1473 625 9696 1298 #caretPeriod: 8 #(530) 9696 1298 #wordWrap: 8 #(true) 9696 1298 #margins: 34 1 34 3 3330 1 9696 49 3 nil nil nil nil 3330 3 9696 1 nil nil 67108863 nil nil 3330 5 9696 1 nil nil nil nil nil 9696 1298 #canHScroll: 8 #(false) 9696 1298 #targetRange: 34 1 3458 1 -1 3 9696 1298 #maxCompletionListHeight: 8 #(9) 9696 1298 #edgeColumn: 8 #(1) 9696 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 224 2 0 0 56 1 0 0] 8 #() 1440 nil 29 170 192 34 4 9392 8 'afterTitle' 9696 8 'after' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1481 1 482 1473 665 9312 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 228 2 0 0 0 0 0 0 196 5 0 0 76 1 0 0] 34 2 9696 9392 1440 nil 27 1440 nil 27 170 192 34 2 6560 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 1650 nil true 34 4 1698 1 1730 #selectUpper 8 'Select &upper' 1 1 nil nil nil 1698 1 1730 #selectLower 8 'Select &lower' 1 1 nil nil nil 1778 4097 1698 1 1730 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 43683 nil nil 1650 nil true 34 3 1698 1 1730 #character 8 '&Character' 1 1 nil nil nil 1698 1 1730 #word 8 '&Word' 1 1 nil nil nil 1698 1 1730 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 43685 nil nil 1650 nil true 34 1 1698 1 1730 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 43687 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 9 53 482 2985 697 6464 1298 #text: 34 1 8 'Comparison' 6464 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 216 5 0 0 118 1 0 0] 34 1 6560 1440 nil 27 6464 nil nil nil 170 192 34 10 1104 8 'sunit' 5024 8 'methodSource' 3648 8 'classDocumentation' 1504 8 'classDefinition' 6464 8 'comparisonTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 704 34 2 8 1140916736 1 11920 590662 2 ##(Smalltalk.ListModel) 138 144 34 5 1472 3616 4992 912 6432 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) nil nil 1 nil nil nil 11920 nil 8 1737494000 946 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 12096 7 257 nil 946 0 nil 12114 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 12160 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #smallIcons nil nil nil nil nil 1234 138 144 34 3 1298 #createAt:extent: 34 2 482 1 1 482 3001 757 11920 1298 #setSingleSelection: 8 #(5) 11920 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 11920 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 220 5 0 0 122 1 0 0] 8 #() 1440 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 3001 757 704 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 220 5 0 0 122 1 0 0] 34 6 1504 3648 5024 1104 6464 11920 1440 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 12658 #fixedParentRight 1 12658 #fixedParentTop 1 12658 #fixedParentBottom -39 410 ##(Smalltalk.ContainerView) 34 15 nil 576 34 2 8 1140850688 131073 12736 nil nil 482 2241 43 517 nil nil nil 12736 642 170 176 34 4 410 ##(Smalltalk.ToolButton) 34 14 nil 12736 34 2 8 1140850688 131073 12864 nil nil nil 1029 nil nil nil 12864 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 12864 34 2 8 1140853580 131137 12928 nil nil 482 43 43 513 nil nil nil 12928 nil 8 1737207072 nil 170 192 34 2 43519 1115206 1 ##(Smalltalk.ToolbarIconButton) 12928 1 1730 #flipAutoCommit 8 'Auto Commit' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons/camera16_light_icon.ico' nil 43519 34 1 13072 nil nil 3 nil 482 33 33 482 33 33 nil nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 43 43 12928 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 8 #() 1440 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 43 43 12864 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 34 1 12928 1440 nil 27 12626 12672 1 12658 #fixedViewLeft 43 12704 1 12658 #fixedViewTop 43 410 ##(Smalltalk.TextEdit) 34 16 nil 12736 34 2 8 1140850688 1 13616 nil 784 482 2199 43 517 nil 2194 nil true 2226 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 482 193 193 nil 13616 770 #black 8 1737104896 2306 nil nil 67 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 43 1 482 2959 41 13616 1298 #setMarginWidths: 34 1 8 #(3 3) 13616 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 21 0 0 0 0 0 0 0 220 5 0 0 20 0 0 0] 8 #() 1440 nil 27 12626 12672 43 12688 1 12704 1 12720 1 170 192 34 4 12864 8 'autoCommitButton' 13616 8 'statusBarField' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 757 482 3001 41 12736 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 122 1 0 0 220 5 0 0 142 1 0 0] 34 2 12864 13616 1440 nil 27 12626 12672 1 12688 1 12720 -39 12720 1 170 192 34 2 704 8 'textAreaTabs' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 805 482 3001 797 576 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 146 1 0 0 220 5 0 0 32 3 0 0] 34 2 704 12736 1440 nil 27 25 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 14480 nil nil nil 5 nil nil nil 14480 514 170 176 34 8 410 ##(Smalltalk.ContainerView) 34 15 nil 14480 34 2 8 1140850688 131073 14592 nil nil nil 5 nil nil nil 14592 642 170 176 34 6 410 ##(Smalltalk.PushButton) 34 20 nil 14592 34 2 8 1140858880 1 14704 nil 2592 nil 5 nil nil nil 14704 nil 8 1737266240 1730 #gotoClassDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 745 482 577 51 14704 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 116 1 0 0 32 1 0 0 141 1 0 0] 8 #() 1440 nil 29 12626 12672 1 12688 1 12720 -49 12720 1 410 ##(Smalltalk.CardContainer) 34 16 nil 14592 34 2 8 1409286144 131073 14976 nil 784 nil 5 nil nil nil 14976 802 138 144 34 2 866 898 8 'Hierarchy' nil nil 410 ##(Smalltalk.TreeView) 34 27 nil 14976 34 2 8 1409356327 1025 15136 590918 3 ##(Smalltalk.TreeModel) nil 12064 525062 ##(Smalltalk.TreeNode) nil nil nil 170 192 1424 784 nil 29 nil nil nil 15136 nil 8 1737728064 946 0 nil 978 2 1 944 8 'doIt' 8 '[:each | each displayString]' 8 #[30 105 226 0 106] #displayString 15296 7 257 nil ##(Smalltalk.IconicListAbstract) 12224 nil 946 0 nil 978 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 15376 7 257 nil 946 0 nil 978 5 1 944 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 15456 7 257 nil nil nil 170 176 1424 33 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 1424 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 9 53 482 561 635 15136 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 28 1 0 0 87 1 0 0] 8 #() 1440 nil 27 866 898 8 'Classes' nil nil 410 ##(Smalltalk.ListView) 34 45 nil 14976 34 2 8 1409372237 1025 15776 11986 138 144 1424 nil 12064 784 nil 29 nil nil nil 15776 nil 8 1737156720 459270 ##(Smalltalk.Message) #displayString 8 #() nil 12224 nil nil nil nil nil nil 138 144 34 1 920646 5 ##(Smalltalk.ListViewColumn) 8 '' 553 #left 15890 #displayString 8 #() 15890 #<= 8 #() nil nil 15776 nil 3 nil 946 0 nil 978 5 1 944 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 16080 7 257 nil #report 8 #() nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 9 53 482 561 635 15776 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 28 1 0 0 87 1 0 0] 8 #() 1440 nil 35 15776 nil nil nil 170 192 34 4 15776 8 'classList' 15136 8 'classHierarchy' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 14976 34 2 8 1140916736 1 16400 11986 138 144 34 2 15744 15104 nil 12064 nil nil 1 nil nil nil 16400 nil 8 1737494000 946 0 nil 12114 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 16528 7 257 nil 946 0 nil 12114 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 16576 7 257 nil 12224 nil nil nil nil nil #smallIcons nil nil nil nil nil 1234 138 144 34 3 1298 #createAt:extent: 34 2 482 1 1 482 577 695 16400 1298 #setSingleSelection: 8 #(1) 16400 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 16400 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 32 1 0 0 91 1 0 0] 8 #() 1440 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 577 695 14976 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 32 1 0 0 91 1 0 0] 34 3 15776 15136 16400 1440 nil 27 12626 12672 1 12688 1 12704 1 12720 -99 410 ##(Smalltalk.CardContainer) 34 16 nil 14592 34 2 8 1409286144 131073 17024 nil 784 nil 5 nil 2194 nil true 524550 ##(Smalltalk.LOGFONTW) 8 #[240 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 188 2 0 0 0 0 0 0 1 2 1 34 83 0 121 0 115 0 116 0 101 0 109 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 17024 802 138 144 34 2 866 898 8 'Class' nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 17024 34 2 8 1140850688 131073 17264 nil nil nil 5 nil nil nil 17264 nil 170 192 1424 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 9 9 482 561 1 17264 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 28 1 0 0 4 0 0 0] 8 #() 1440 nil 27 866 898 8 'Instance' nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 17024 34 2 8 1140850688 131073 17552 nil nil nil 5 nil nil nil 17552 nil 170 192 1424 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 9 9 482 561 1 17552 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 28 1 0 0 4 0 0 0] 8 #() 1440 nil 27 17552 nil nil nil 170 192 34 4 17552 8 'instanceTab' 17264 8 'classTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 17024 34 2 8 1140916738 1 17856 11986 138 144 34 2 17520 17232 nil 12064 nil nil 1 nil nil nil 17856 nil 8 1737494000 946 0 nil 12114 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 17984 7 257 nil 946 0 nil 12114 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 18032 7 257 nil 12224 nil nil nil nil nil #smallIcons nil nil nil nil nil 1234 138 144 34 3 1298 #createAt:extent: 34 2 482 1 1 482 577 51 17856 1298 #setSingleSelection: 8 #(1) 17856 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 17856 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 32 1 0 0 25 0 0 0] 8 #() 1440 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 695 482 577 51 17024 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 91 1 0 0 32 1 0 0 116 1 0 0] 34 3 17552 17264 17856 1440 nil 27 12626 12672 1 12688 1 12720 -99 13600 51 170 192 34 6 14704 8 'definedPackageClassText' 14976 8 'classHierarchyTabs' 17024 8 'instanceClassTabs' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1403 1 482 577 795 14592 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 189 2 0 0 0 0 0 0 221 3 0 0 141 1 0 0] 34 3 14976 17024 14704 1440 nil 27 524806 ##(Smalltalk.Fraction) 3 11 410 ##(Smalltalk.ContainerView) 34 15 nil 14480 34 2 8 1140850688 131073 18752 nil nil nil 5 nil nil nil 18752 514 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 18752 34 2 8 1140850688 131073 18864 nil nil nil 5 nil nil nil 18864 642 170 176 34 6 410 ##(Smalltalk.PushButton) 34 20 nil 18864 34 2 8 1140858880 1 18976 nil 784 nil 5 nil nil nil 18976 nil 8 1737266240 1730 #gotoMethodDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 745 482 629 51 18976 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 116 1 0 0 58 1 0 0 141 1 0 0] 8 #() 1440 nil 29 12626 12672 1 12688 1 12720 -49 12720 1 410 ##(Smalltalk.TextEdit) 34 16 nil 18864 34 2 8 1140916352 1025 19248 nil 784 nil 5 nil nil nil 19248 nil 8 1737104896 2306 nil nil 3 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 629 51 19248 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 58 1 0 0 25 0 0 0] 8 #() 1440 nil 27 12626 12672 1 12688 1 12704 1 12704 51 410 ##(Smalltalk.ListView) 34 45 nil 18864 34 2 8 1409372233 1025 19520 11986 138 144 1424 nil 12064 784 nil 13 nil nil nil 19520 nil 8 1737156720 15890 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 12224 nil nil nil nil nil nil 138 144 34 2 15970 8 '' 41 #left 1298 #empty 8 #() 16 15890 #<= 8 #() nil nil 19520 946 0 nil 978 2 1 944 8 'doIt' 8 '[:each | each subSuperIcon]' 8 #[30 105 226 0 106] #subSuperIcon 19792 7 257 nil 1 nil nil 15970 8 'Selector' 581 #left 15890 #displayString 19648 ##(Smalltalk.SortedCollection) nil nil 19520 nil 3 nil 946 0 nil 978 5 1 944 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 19920 7 257 nil #report 16160 nil 133221 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 55 482 629 691 19520 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 27 0 0 0 58 1 0 0 116 1 0 0] 8 #() 1440 nil 35 12626 12672 1 12688 1 12704 55 12720 -49 170 192 34 6 18976 8 'definedPackageMethodText' 19248 8 'categoryMethodText' 19520 8 'methodList' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 385 1 482 629 795 18864 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 192 0 0 0 0 0 0 0 250 1 0 0 141 1 0 0] 34 3 19520 18976 19248 1440 nil 27 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 244 63 410 ##(Smalltalk.CardContainer) 34 16 nil 18752 34 2 8 1409286144 131073 20448 nil 784 nil 5 nil nil nil 20448 802 138 144 34 2 866 8 'Category' 410 ##(Smalltalk.ListView) 34 45 nil 20448 34 2 8 1409372233 1025 20592 11986 138 144 1424 nil 12064 784 nil 21 nil nil nil 20592 nil 8 1737156720 15890 #displayString 8 #() nil 12224 nil nil nil nil nil nil 138 144 34 1 15970 8 'Column 1' 351 #left 15890 #displayString 8 #() ##(Smalltalk.SortedCollection) 946 0 nil 978 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each]' 1779525917 20832 7 257 nil nil 20592 nil 3 nil nil #report 16160 nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 9 53 482 359 735 20592 1298 #text: 34 1 8 'Column 1' 20592 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 183 0 0 0 137 1 0 0] 8 #() 1440 nil 35 866 8 'Variables' 410 ##(Smalltalk.ListView) 34 45 nil 20448 34 2 8 1409372233 1025 21136 11986 138 144 1424 nil 12064 784 nil 21 nil nil nil 21136 nil 8 1737156720 15890 #displayString 8 #() nil 12224 nil nil 946 0 nil 978 4 1 944 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 21280 7 257 nil nil nil nil 138 144 34 1 15970 8 'Column 1' 351 #left 15890 #displayString 21264 ##(Smalltalk.SortedCollection) nil nil 21136 nil 3 nil 946 0 nil 978 4 1 944 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 21440 7 257 nil #report 16160 nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 9 53 482 359 735 21136 1298 #text: 34 1 8 'Column 1' 21136 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 183 0 0 0 137 1 0 0] 8 #() 1440 nil 35 20592 nil nil nil 170 192 34 4 21136 8 'variableList' 20592 8 'categoryList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 20448 34 2 8 1140916736 1 21792 11986 138 144 34 2 20576 21120 nil 12064 nil nil 1 nil nil nil 21792 nil 8 1737494000 946 0 nil 12114 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 21920 7 257 nil 946 0 nil 12114 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 21968 7 257 nil 12224 nil nil nil nil nil #noIcons nil nil nil nil nil 1234 138 144 34 3 1298 #createAt:extent: 34 2 482 1 1 482 375 795 21792 1298 #setSingleSelection: 8 #(1) 21792 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 21792 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 187 0 0 0 141 1 0 0] 8 #() 1440 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 375 795 20448 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 187 0 0 0 141 1 0 0] 34 3 20592 21136 21792 1440 nil 27 20418 8 0 0 0 0 0 0 232 63 false 170 192 34 2 20448 8 'methodFilterTabs' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1989 1 482 1013 795 18752 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 226 3 0 0 0 0 0 0 220 5 0 0 141 1 0 0] 34 3 20448 410 ##(Smalltalk.Splitter) 34 12 nil 18752 34 2 8 1140850688 1 22624 nil 784 nil 517 nil nil nil 9090 22624 nil 1 #left nil nil nil 9120 9136 nil 9120 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 375 1 482 11 795 22624 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 187 0 0 0 0 0 0 0 192 0 0 0 141 1 0 0] 8 #() 1440 nil 27 18864 1440 nil 27 18722 15 41 410 ##(Smalltalk.ContainerView) 34 15 nil 14480 34 2 8 1140850688 131073 22880 nil nil nil 5 nil nil nil 22880 514 170 176 1424 false 170 192 34 2 410 ##(Smalltalk.ListView) 34 45 nil 22880 34 2 8 1409405261 1025 23008 11986 138 144 1424 nil 12064 784 nil 5 nil nil nil 23008 nil 8 1737156720 15890 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 12224 nil nil nil nil nil nil 138 144 34 1 15970 8 'Column 1' 425 #left 946 0 nil 978 2 1 944 8 'doIt' 8 '[:each | each displayName]' 8 #[30 105 226 0 106] #displayName 23216 7 257 nil ##(Smalltalk.SortedCollection) nil nil 23008 nil 3 946 0 nil 978 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 23296 7 257 nil 946 0 nil 978 3 1 944 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 23376 7 257 nil #report 16160 nil 133217 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 1 1 482 433 795 23008 1298 #text: 34 1 8 'Column 1' 23008 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 216 0 0 0 141 1 0 0] 8 #() 1440 nil 35 8 'projectList' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 433 795 22880 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 216 0 0 0 141 1 0 0] 34 1 23008 1440 nil 27 18722 7 41 410 ##(Smalltalk.ContainerView) 34 15 nil 14480 34 2 8 1140850688 131073 23856 nil nil nil 5 nil nil nil 23856 514 170 176 1424 false 170 192 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 23856 34 2 8 1140850688 131073 23984 nil nil nil 5 nil nil nil 23984 514 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 23984 34 2 8 1409286144 131073 24096 nil 784 nil 21 nil nil nil 24096 802 138 144 1424 nil nil nil nil 170 192 1424 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 24096 34 2 8 1140916736 1 24208 11986 138 144 1424 nil 12064 nil nil 17 nil nil nil 24208 nil 8 1737494000 946 0 nil 12114 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 24320 7 257 nil 946 0 nil 12114 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 24368 7 257 nil 12224 nil nil nil nil nil #noIcons nil nil nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 482 1 1 482 477 795 24208 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 24208 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 238 0 0 0 141 1 0 0] 8 #() 1440 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 477 795 24096 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 238 0 0 0 141 1 0 0] 34 1 24208 1440 nil 27 3 false 170 192 34 2 24096 8 'packageDictionaryCards' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 485 1 482 477 795 23984 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 242 0 0 0 0 0 0 0 224 1 0 0 141 1 0 0] 34 1 24096 1440 nil 27 8 'packageDictionaryContainer' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 433 1 482 961 795 23856 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 216 0 0 0 0 0 0 0 184 2 0 0 141 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 23856 34 2 8 1140850688 131073 25152 nil nil nil 5 nil nil nil 25152 514 170 176 1424 false 170 192 1424 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 475 795 25152 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 237 0 0 0 141 1 0 0] 34 1 410 ##(Smalltalk.CardContainer) 34 16 nil 25152 34 2 8 1409286144 131073 25424 nil 784 nil 5 nil nil nil 25424 802 138 144 34 1 866 8 'Components' 410 ##(Smalltalk.JadeiteTreeView) 34 27 nil 25424 34 2 8 1140916775 1025 25568 1049670 3 ##(Smalltalk.JadeiteTreeModel) nil 12064 984070 ##(Smalltalk.JadeiteTreeNode) nil nil nil nil 170 192 1424 784 nil 5 nil nil nil 25568 nil 8 1737728064 946 0 nil 978 2 1 15888 8 'doIt' 8 '[:service | service displayString]' 8 #[30 105 226 0 106] #displayString 25728 7 257 nil ##(Smalltalk.IconicListAbstract) 12224 nil nil nil nil nil 170 176 1424 33 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 1424 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 9 53 482 459 735 25568 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 233 0 0 0 137 1 0 0] 8 #() 1440 nil 27 25568 nil nil nil 170 192 34 2 25568 8 'componentTree' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 25424 34 2 8 1140916736 1 26048 11986 138 144 34 1 25552 nil 12064 nil nil 1 nil nil nil 26048 nil 8 1737494000 946 0 nil 12114 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 26176 7 257 nil 946 0 nil 12114 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 26224 7 257 nil 12224 nil nil nil nil nil #noIcons nil nil nil nil nil 1234 138 144 34 3 1298 #createAt:extent: 34 2 482 1 1 482 475 795 26048 1298 #setSingleSelection: 8 #(1) 26048 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 26048 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 237 0 0 0 141 1 0 0] 8 #() 1440 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 475 795 25424 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 237 0 0 0 141 1 0 0] 34 2 25568 26048 1440 nil 27 1440 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 23856 34 2 8 1140850688 1 26656 nil 784 nil 517 nil nil nil 9090 26656 nil 1 #left nil nil nil 9120 9136 nil 9120 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 475 1 482 11 795 26656 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 237 0 0 0 0 0 0 0 242 0 0 0 141 1 0 0] 8 #() 1440 nil 27 23984 1440 nil 27 18722 3 7 false 170 192 34 2 23856 8 'componentPackageContainer' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 1 482 3001 795 14480 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 220 5 0 0 141 1 0 0] 34 6 22880 23856 410 ##(Smalltalk.Splitter) 34 12 nil 14480 34 2 8 1140850688 1 27120 nil 784 nil 517 nil nil nil 9090 27120 nil 1 #left nil nil nil 9120 9136 nil 9120 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1393 1 482 11 795 27120 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 184 2 0 0 0 0 0 0 189 2 0 0 141 1 0 0] 8 #() 1440 nil 27 14592 410 ##(Smalltalk.Splitter) 34 12 nil 14480 34 2 8 1140850688 1 27360 nil 784 nil 517 nil nil nil 9090 27360 nil 1 #left nil nil nil 9120 9136 nil 9120 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1979 1 482 11 795 27360 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 221 3 0 0 0 0 0 0 226 3 0 0 141 1 0 0] 8 #() 1440 nil 27 18752 1440 nil 27 25 true 170 192 34 2 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 27632 nil 784 nil 517 nil nil nil 9090 27632 nil 1 #left nil nil nil 9120 9136 nil 9120 nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 1 795 482 3001 11 27632 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 141 1 0 0 220 5 0 0 146 1 0 0] 8 #() 1440 nil 27 8 'splitter' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 482 7545 21 482 3001 1601 416 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 188 14 0 0 10 0 0 0 152 20 0 0 42 3 0 0] 34 3 14480 27632 576 1440 nil 27 )! !
!JadeiteBrowserPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

