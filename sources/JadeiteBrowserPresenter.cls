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
	projectListPresenter selections isEmpty ifTrue:[^false]. 
	projectListPresenter selections detect: [:projectService | projectService isDirty not]
		ifNone: [^true].
	^false!

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
	| globalsTabView |
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
	globalsTabView
		arrangement: 'Globals';
		name: 'globalsTab'.
	classListPresenter list: ListModel new.
	self updateGlobalsTab!

buildProjectTab
	| projectInfoView |
	projectInfoTab
		ifNil: 
			[projectInfoTab := ListPresenter new.
			projectInfoTab parentPresenter: self textAreaTabs.
			projectInfoView := projectInfoTab createView: 'Editable list view'.
			projectInfoView getImageBlock: nil. 
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
	projectInfoView
		arrangement: 'Project';
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
				yourself]!

noClassSelectedInEitherPresenter
	classListPresenter selectionIfNone: [classHierarchyPresenter selectionIfNone: [^true]].
	^false!

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
!JadeiteBrowserPresenter categoriesFor: #inspectorContextObject!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #isNoneProjectSelected!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #isProjectItemEnabled:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #isRowanProjectSelected!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #jadeInspect!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #makeSameSelectionsIn:as:!menu handlers!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #maxAutoCompleteListSize!constants!public! !
!JadeiteBrowserPresenter categoriesFor: #methodMenu:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #methodToReformat!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #methodValueChanged!event handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #noClassSelectedInEitherPresenter!public!testing! !
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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil 328198 ##(Smalltalk.Point) 2241 1401 517 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 6 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 576 nil 327686 ##(Smalltalk.Color) #default nil 5 nil nil nil 576 655878 ##(Smalltalk.CardLayout) 138 144 34 5 721414 ##(Smalltalk.Association) 590662 1 ##(Smalltalk.CardLabel) 8 'SUnit' 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 4 1 816 8 'doIt' 8 '[Icon fromId: ''icons\UnitTestPlugin.ico'']' 8 #[32 105 45 30 178 106] 983558 ##(Smalltalk.VariableBinding) #Icon ##(Smalltalk.Icon) 8 'icons\UnitTestPlugin.ico' #fromId: 832 7 1 nil nil 410 ##(Smalltalk.ReferenceView) 34 14 nil 576 34 2 8 1140850688 131073 976 nil 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 nil nil nil 976 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteSUnitInClassPresenter) #resource_Default_view nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 482 9 53 482 2225 615 976 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 92 4 0 0 77 1 0 0] 8 #() 482 193 193 nil 27 738 770 8 'Class Definition' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 576 34 2 8 1445007428 1025 1376 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 1042 26337781 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 11 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #editSave 8 '&Save' 9383 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 1570 1 1602 #editUndo 8 '&Undo' 9397 1 nil nil nil 1570 1 1602 #editRedo 8 '&Redo' 9395 1 nil nil nil 1650 4097 1570 1 1602 #editCut 8 'Cu&t' 9393 1 nil nil nil 1570 1 1602 #editCopy 8 '&Copy' 9351 1 nil nil nil 1570 1 1602 #editPaste 8 '&Paste' 9389 1 nil nil nil 1570 1 1602 #editDelete 8 '&Delete' 1629 1 nil nil nil 1650 4097 1570 1 1602 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 1376 nil 8 1682100671 852486 ##(Smalltalk.NullConverter) nil nil 13 nil 170 192 34 4 #normal 1182790 1 ##(Smalltalk.ScintillaTextStyle) 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 2242 77 642 #gray 642 #white 1 nil nil nil nil #callTip nil nil nil 34 256 2256 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 2272 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1639686 ##(Smalltalk.SmalltalkExpressionStyler) 1 nil nil false 138 144 1296 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 1376 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1296 nil 170 176 1296 9215 nil nil nil nil 642 #silver nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 2256 nil nil nil nil 1 nil 170 192 34 6 1 1510470 3 ##(Smalltalk.ScintillaIndicatorStyle) 1 1376 1042 65025 3 false 1 nil nil nil nil nil nil 3 2690 3 1376 642 #blue 5 false 3 nil nil nil nil nil nil 5 2690 5 1376 642 #red 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 2242 1027 1042 60239 1042 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2242 1031 1042 335 1042 31317503 1 nil nil nil nil #Error nil nil nil #Notification 2242 1029 nil 1042 31185883 1 nil nil nil nil #Notification nil nil nil nil 1106 138 144 34 9 1170 #createAt:extent: 34 2 482 9 53 482 2225 615 1376 1170 #contextMenu: 34 1 1536 1376 1170 #textLimit: 8 #(1073741823) 1376 1170 #caretPeriod: 8 #(530) 1376 1170 #wordWrap: 8 #(true) 1376 1170 #margins: 34 1 34 3 985158 3 ##(Smalltalk.ScintillaMargin) 1 1376 1 3 nil nil 5 nil 3250 3 1376 33 nil 3 67108863 5 nil 3250 5 1376 1 nil 3 -67108863 5 nil 1376 1170 #tabWidth: 8 #(4) 1376 1170 #maxCompletionListHeight: 8 #(9) 1376 1170 #edgeColumn: 8 #(1) 1376 1250 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1312 nil 29 738 770 8 'Class Documentation' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 576 34 2 8 1445007428 1025 3504 1442 nil false 1488 nil 1042 26337781 nil 5 1522 nil true 34 1 1570 1 1602 #editSaveClassComment 8 'Save' 1025 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 2066 nil true 2098 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 3504 nil 8 1682100671 2178 nil nil 15 nil 170 192 34 4 #normal 2242 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 2242 77 2288 2304 1 nil nil nil nil #callTip nil nil nil 34 256 3824 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3840 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 2418 1 nil nil nil 3504 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1296 nil 170 176 1296 9215 nil nil nil nil 2480 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 3824 nil nil nil nil 1 nil 170 192 34 6 1 2690 1 3504 1042 65025 3 false 1 nil nil nil nil nil nil 3 2690 3 3504 2752 5 false 3 nil nil nil nil nil nil 5 2690 5 3504 2784 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 2242 1027 1042 60239 1042 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2242 1031 1042 335 1042 31317503 1 nil nil nil nil #Error nil nil nil #Notification 2242 1029 nil 1042 31185883 1 nil nil nil nil #Notification nil nil nil nil 1106 138 144 34 10 1170 #createAt:extent: 34 2 482 9 53 482 2225 615 3504 1170 #contextMenu: 34 1 3600 3504 1170 #textLimit: 8 #(1073741823) 3504 1170 #hoverTime: 8 #(1000000) 3504 1170 #caretPeriod: 8 #(530) 3504 1170 #wordWrap: 8 #(true) 3504 1170 #margins: 34 1 34 3 3250 1 3504 1 3 nil nil 5 nil 3250 3 3504 33 nil 3 67108863 5 nil 3250 5 3504 1 nil 3 -67108863 5 nil 3504 1170 #tabWidth: 8 #(4) 3504 1170 #maxCompletionListHeight: 8 #(9) 3504 1170 #edgeColumn: 8 #(1) 3504 1250 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1312 nil 29 738 770 8 'Method Source' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 576 34 2 8 1445007428 1025 4880 1442 nil false 1488 nil 1042 26337781 nil 5 nil 2066 nil true 2098 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 4880 nil 8 1682100671 2178 nil nil 13 nil 170 192 34 4 #normal 2242 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 2242 77 2288 2304 1 nil nil nil nil #callTip nil nil nil 34 256 5104 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 5120 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 1296 170 192 34 2 #default 2418 1 nil nil nil 4880 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1296 nil 170 176 1296 9215 nil nil nil nil 2480 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 4 #normal 5104 #callTip 5120 nil nil nil nil 1 nil 170 192 34 12 1 2690 1 4880 1042 65025 3 false 1 nil nil nil nil nil nil 5 2690 5 4880 2784 1 false 5 nil nil nil nil nil nil 3 2690 3 4880 2752 5 false 3 nil nil nil nil nil nil 8 'indicator8' 2690 17 4880 2480 1 nil nil nil nil nil nil nil nil 8 'indicator9' 2690 19 4880 2784 13 nil nil nil nil nil nil nil nil 8 'indicator10' 2690 21 4880 2784 3 nil nil nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 2242 1027 1042 60239 1042 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2242 1031 1042 335 1042 31317503 1 nil nil nil nil #Error nil nil nil #Notification 2242 1029 nil 1042 31185883 1 nil nil nil nil #Notification nil nil nil nil 1106 138 144 34 9 1170 #createAt:extent: 34 2 482 9 53 482 2225 615 4880 1170 #textLimit: 8 #(1073741823) 4880 1170 #hoverTime: 8 #(500) 4880 1170 #caretPeriod: 8 #(530) 4880 1170 #wordWrap: 8 #(true) 4880 1170 #margins: 34 1 34 3 3250 1 4880 61 3 nil nil 5 nil 3250 3 4880 1 nil 3 67108863 nil nil 3250 5 4880 1 nil 3 -67108863 nil nil 4880 1170 #tabWidth: 8 #(4) 4880 1170 #maxCompletionListHeight: 8 #(9) 4880 1170 #edgeColumn: 8 #(1) 4880 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1312 nil 29 738 8 'Comparison' 410 ##(Smalltalk.ShellView) 34 27 nil 576 34 2 8 1078919168 131073 6304 nil 656 nil 517 nil nil nil 6304 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 6304 34 2 8 1140850688 131073 6400 nil 1042 26337781 nil 5 1522 nil true 34 5 1570 1 1602 #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 1570 1 1602 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 1570 1 1602 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 1570 1 1602 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 1570 1 1602 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 6400 514 170 176 1296 false 170 192 1296 nil 1106 138 144 34 2 1170 #createAt:extent: 34 2 482 1 1 482 2193 581 6400 1170 #contextMenu: 34 1 6480 6400 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 4 0 0 34 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 6400 34 2 8 1140850688 131073 7008 nil 656 nil 5 nil nil nil 7008 6370 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 7008 34 2 8 1140850945 262145 7088 nil nil nil 5 nil nil nil 7088 nil 8 1660258976 2178 nil nil nil 1106 138 144 34 2 1170 #createAt:extent: 34 2 482 1 541 482 1091 41 7088 1170 #text: 34 1 8 '
' 7088 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 14 1 0 0 33 2 0 0 34 1 0 0] 8 #() 1312 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 7008 34 2 8 1140920580 1025 7392 1442 nil false 1488 nil 1042 26337781 nil 5 nil nil nil 7392 nil 8 1682100671 2178 nil nil 11 nil 170 192 34 12 #lineNumber 2242 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 2242 77 2288 2304 1 nil nil nil nil #callTip nil nil nil #indentGuide 2242 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #normal 2242 1 nil nil 1 nil nil nil nil #normal nil nil nil #whitespace 2242 3 642 #teal nil 1 nil nil nil nil #whitespace nil nil nil #diff 2242 5 nil 1042 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 7600 7616 7648 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 7552 nil nil nil 7584 nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 2418 1 nil nil nil 7392 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1296 nil 170 176 1296 9215 nil nil nil nil 2480 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 7520 nil nil nil nil 1 nil 170 192 34 6 8 'indicator2' 2690 5 7392 2784 1 false nil nil nil nil nil nil nil 8 'indicator1' 2690 3 7392 2752 5 false nil nil nil nil nil nil nil 8 'indicator0' 2690 1 7392 2784 13 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 2242 1027 1042 60239 1042 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2242 1031 1042 335 1042 31317503 1 nil nil nil nil #Error nil nil nil #Notification 2242 1029 nil 1042 31185883 1 nil nil nil nil #Notification nil nil nil nil 1106 138 144 34 8 1170 #createAt:extent: 34 2 482 1 1 482 1091 541 7392 1170 #textLimit: 8 #(1073741823) 7392 1170 #caretPeriod: 8 #(530) 7392 1170 #wordWrap: 8 #(true) 7392 1170 #margins: 34 1 34 3 3250 1 7392 49 3 nil nil nil nil 3250 3 7392 1 nil nil 67108863 nil nil 3250 5 7392 1 nil nil nil nil nil 7392 1170 #canHScroll: 8 #(false) 7392 1170 #maxCompletionListHeight: 8 #(9) 7392 1170 #edgeColumn: 8 #(1) 7392 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 14 1 0 0] 8 #() 1312 nil 29 170 192 34 4 7088 8 'beforeTitle' 7392 8 'before' nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 1 482 1091 581 7008 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 34 1 0 0] 34 2 7392 7088 1312 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 6400 34 2 8 1140850688 1 8832 nil 1042 66047 nil 517 nil nil nil 1510470 1 ##(Smalltalk.DraggableViewInteractor) 8832 nil 1 #left nil nil nil 482 1 1 482 9 9 nil 8944 nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1091 1 482 11 581 8832 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 33 2 0 0 0 0 0 0 38 2 0 0 34 1 0 0] 8 #() 1312 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 6400 34 2 8 1140850688 131073 9136 nil 656 nil 5 nil nil nil 9136 6370 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 9136 34 2 8 1140850945 262145 9216 nil nil nil 5 nil nil nil 9216 nil 8 1660258976 2178 nil nil nil 1106 138 144 34 2 1170 #createAt:extent: 34 2 482 1 541 482 1093 41 9216 1170 #text: 34 1 8 '
' 9216 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 14 1 0 0 34 2 0 0 34 1 0 0] 8 #() 1312 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 9136 34 2 8 1140920580 1025 9520 1442 nil false 1488 nil 1042 26337781 nil 5 nil nil nil 9520 nil 8 1682100671 2178 nil nil 11 nil 170 192 34 12 #lineNumber 2242 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 2242 77 2288 2304 1 nil nil nil nil #callTip nil nil nil #indentGuide 2242 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #normal 2242 1 nil nil 1 nil nil nil nil #normal nil nil nil #whitespace 2242 3 7632 nil 1 nil nil nil nil #whitespace nil nil nil #diff 2242 5 nil 1042 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 9728 9744 9760 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 9680 nil nil nil 9712 nil nil 7698 7728 170 192 34 2 #default 2418 1 nil nil nil 9520 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1296 nil 170 176 1296 9215 nil nil nil nil 2480 nil nil 65 nil nil nil 7824 3 170 192 34 2 #container 9648 nil nil nil nil 1 nil 170 192 34 6 8 'indicator0' 2690 1 9520 2784 13 false nil nil nil nil nil nil nil 8 'indicator1' 2690 3 9520 2752 5 false nil nil nil nil nil nil nil 8 'indicator2' 2690 5 9520 2784 1 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 2242 1027 1042 60239 1042 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2242 1031 1042 335 1042 31317503 1 nil nil nil nil #Error nil nil nil #Notification 2242 1029 nil 1042 31185883 1 nil nil nil nil #Notification nil nil nil nil 1106 138 144 34 8 1170 #createAt:extent: 34 2 482 1 1 482 1093 541 9520 1170 #textLimit: 8 #(1073741823) 9520 1170 #caretPeriod: 8 #(530) 9520 1170 #wordWrap: 8 #(true) 9520 1170 #margins: 34 1 34 3 3250 1 9520 49 3 nil nil nil nil 3250 3 9520 1 nil nil 67108863 nil nil 3250 5 9520 1 nil nil nil nil nil 9520 1170 #canHScroll: 8 #(false) 9520 1170 #maxCompletionListHeight: 8 #(9) 9520 1170 #edgeColumn: 8 #(1) 9520 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 34 2 0 0 14 1 0 0] 8 #() 1312 nil 29 170 192 34 4 9520 8 'after' 9216 8 'afterTitle' nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1101 1 482 1093 581 9136 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 38 2 0 0 0 0 0 0 72 4 0 0 34 1 0 0] 34 2 9520 9216 1312 nil 27 1312 nil 27 170 192 34 2 6400 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 1522 nil true 34 4 1570 1 1602 #selectUpper 8 'Select &upper' 1 1 nil nil nil 1570 1 1602 #selectLower 8 'Select &lower' 1 1 nil nil nil 1650 4097 1570 1 1602 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 24955 nil nil 1522 nil true 34 3 1570 1 1602 #character 8 '&Character' 1 1 nil nil nil 1570 1 1602 #word 8 '&Word' 1 1 nil nil nil 1570 1 1602 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 24957 nil nil 1522 nil true 34 1 1570 1 1602 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 24959 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1106 138 144 34 3 1170 #createAt:extent: 34 2 482 9 53 482 2225 615 6304 1170 #text: 34 1 8 'Comparison' 6304 1170 #updateMenuBar 1296 6304 1250 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 92 4 0 0 77 1 0 0] 34 1 6400 1312 nil 27 4880 170 192 34 10 1376 8 'classDefinition' 6304 8 'comparisonTab' 3504 8 'classDocumentation' 4880 8 'methodSource' 976 8 'sunit' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 576 34 2 8 1140916736 1 11840 590662 2 ##(Smalltalk.ListModel) 138 144 34 5 1344 3472 4848 784 6288 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) nil nil 1 nil nil nil 11840 nil 8 1660489200 818 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 12016 7 257 nil 818 0 nil 12034 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 12080 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #smallIcons nil nil nil nil nil 1106 138 144 34 3 1170 #createAt:extent: 34 2 482 1 1 482 2241 675 11840 1170 #basicSelectionsByIndex: 34 1 8 #(3) 11840 1170 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 11840 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 8 #() 1312 nil 27 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 685 482 2241 675 576 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 86 1 0 0 96 4 0 0 167 2 0 0] 34 6 1376 3504 4880 976 6304 11840 1312 nil 27 524806 ##(Smalltalk.Fraction) 3 5 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 12592 nil nil 482 2241 43 517 nil nil nil 12592 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.TextEdit) 34 16 nil 12592 34 2 8 1140850688 1 12736 nil 656 482 2199 43 517 nil 2066 nil true 2098 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 482 193 193 nil 12736 642 #black 8 1660100096 2178 nil nil 67 1106 138 144 34 2 1170 #createAt:extent: 34 2 482 43 1 482 2199 43 12736 1170 #setMarginWidths: 34 1 8 #(3 3) 12736 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 21 0 0 0 0 0 0 0 96 4 0 0 21 0 0 0] 8 #() 1312 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 43 13170 #fixedParentRight 1 13170 #fixedParentTop 1 13170 #fixedParentBottom 1 410 ##(Smalltalk.ToolButton) 34 14 nil 12592 34 2 8 1140850688 131073 13248 nil nil nil 1029 nil nil nil 13248 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 13248 34 2 8 1140853580 131137 13312 nil nil 482 43 43 513 nil nil nil 13312 nil 8 1660202272 nil 170 192 34 2 22963 1115206 1 ##(Smalltalk.ToolbarIconButton) 13312 1 1602 #flipAutoCommit 8 'Auto Commit' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons/camera16_light_icon.ico' nil 22963 34 1 13456 nil nil 3 nil 482 33 33 482 33 33 nil nil 1106 138 144 34 2 1170 #createAt:extent: 34 2 482 1 1 482 43 43 13312 1170 #updateSizePosted 1296 13312 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 8 #() 1312 nil 27 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 1 482 43 43 13248 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 34 1 13312 1312 nil 27 13138 13184 1 13170 #fixedViewLeft 43 13216 1 13170 #fixedViewTop 43 170 192 34 4 12736 8 'statusBarField' 13248 8 'autoCommitButton' nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 1359 482 2241 43 12592 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 167 2 0 0 96 4 0 0 188 2 0 0] 34 2 13248 12736 1312 nil 27 327734 ##(Smalltalk.Float) 8 184 30 133 235 81 184 158 63 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 14272 nil nil nil 5 nil nil nil 14272 514 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 14272 34 2 8 1140850688 131073 14384 nil nil nil 5 nil nil nil 14384 514 170 176 34 6 410 ##(Smalltalk.ContainerView) 34 15 nil 14384 34 2 8 1140850688 131073 14496 nil nil nil 5 nil nil nil 14496 12674 170 176 34 6 410 ##(Smalltalk.PushButton) 34 20 nil 14496 34 2 8 1140858880 1 14608 nil 2480 nil 5 nil nil nil 14608 nil 8 1660261440 1602 #gotoClassDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 625 482 511 51 14608 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 255 0 0 0 81 1 0 0] 8 #() 1312 nil 29 13138 13184 1 13200 1 13232 -49 13232 1 410 ##(Smalltalk.CardContainer) 34 16 nil 14496 34 2 8 1409286144 131073 14880 nil 656 nil 5 nil nil nil 14880 674 138 144 34 2 738 770 8 'Instance' 818 0 nil 850 7 1 16 8 'doIt' 8 '(CardLabel text: ''Instance'' iconBlock: [Icon fromId: ''Class.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 768 15024 13504 8 'Class.ico' #fromId: #text:iconBlock: 15040 11 1 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 14880 34 2 8 1140850688 131073 15136 nil nil nil 5 nil nil nil 15136 nil 170 192 1296 nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 9 9 482 495 1 15136 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 251 0 0 0 4 0 0 0] 8 #() 1312 nil 27 738 770 8 'Class' 818 0 nil 850 7 1 16 8 'doIt' 8 '(CardLabel text: ''Class'' iconBlock: [Icon fromId: ''Metaclass.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 768 15408 13504 8 'Metaclass.ico' #fromId: #text:iconBlock: 15424 11 1 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 14880 34 2 8 1140850688 131073 15520 nil nil nil 5 nil nil nil 15520 nil 170 192 1296 nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 9 9 482 495 1 15520 1250 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 251 0 0 0 4 0 0 0] 8 #() 1312 nil 27 15136 170 192 34 4 15520 8 'classTab' 15136 8 'instanceTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 14880 34 2 8 1140916738 1 15824 11906 138 144 34 2 15008 15392 nil 11984 nil nil 1 nil nil nil 15824 nil 8 1660489200 818 0 nil 12034 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 15952 7 257 nil 818 0 nil 12034 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 16000 7 257 nil 12144 nil nil nil nil nil #smallIcons nil nil nil nil nil 1106 138 144 34 3 1170 #createAt:extent: 34 2 482 1 1 482 511 51 15824 1170 #basicSelectionsByIndex: 34 1 8 #(1) 15824 1170 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 15824 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 25 0 0 0] 8 #() 1312 nil 27 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 575 482 511 51 14880 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 31 1 0 0 255 0 0 0 56 1 0 0] 34 3 15136 15520 15824 1312 nil 27 13138 13184 1 13200 1 13232 -99 14000 51 410 ##(Smalltalk.CardContainer) 34 16 nil 14496 34 2 8 1409286144 131073 16464 nil 656 nil 5 nil nil nil 16464 674 138 144 34 2 738 770 8 'Classes' 818 0 nil 850 7 1 16 8 'doIt' 8 '(CardLabel text: ''Classes'' iconBlock: [Icon fromId: ''Class.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 768 16608 13504 8 'Class.ico' #fromId: #text:iconBlock: 16624 11 1 nil nil 410 ##(Smalltalk.ListView) 34 30 nil 16464 34 2 8 1409372237 1025 16720 11906 138 144 1296 nil 11984 656 nil 21 nil nil nil 16720 nil 8 1660151920 459270 ##(Smalltalk.Message) #displayString 8 #() nil 12144 nil nil nil nil nil nil 138 144 34 1 920646 5 ##(Smalltalk.ListViewColumn) 8 '' 487 #left 16834 #displayString 8 #() 16834 #<= 8 #() nil nil 16720 nil 3 nil 818 0 nil 850 5 1 816 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 17024 7 257 nil #report 1296 nil 131169 nil 34 4 nil nil 482 1 1 nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 9 53 482 495 515 16720 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 251 0 0 0 27 1 0 0] 8 #() 1312 nil 27 738 770 8 'Hierarchy' 818 0 nil 850 7 1 16 8 'doIt' 8 '(CardLabel text: ''Hierarchy'' iconBlock: [Icon fromId: ''ClassHierarchyDiagram.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 768 17328 13504 8 'ClassHierarchyDiagram.ico' #fromId: #text:iconBlock: 17344 11 1 nil nil 410 ##(Smalltalk.TreeView) 34 27 nil 16464 34 2 8 1409352231 1025 17440 590918 3 ##(Smalltalk.TreeModel) nil 11984 525062 ##(Smalltalk.TreeNode) nil nil nil 170 192 1296 656 nil 21 nil nil nil 17440 nil 8 1660723264 818 0 nil 850 2 1 816 8 'doIt' 8 '[:each | each displayString]' 8 #[30 105 226 0 106] #displayString 17600 7 257 nil ##(Smalltalk.IconicListAbstract) 12144 nil 818 0 nil 850 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 17680 7 257 nil 818 0 nil 850 5 1 816 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 17760 7 257 nil nil nil 170 176 1296 33 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 1296 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 9 53 482 495 515 17440 1250 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 251 0 0 0 27 1 0 0] 8 #() 1312 nil 27 16720 170 192 34 4 17440 8 'classHierarchy' 16720 8 'classList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 16464 34 2 8 1140916736 1 18096 11906 138 144 34 2 16592 17312 nil 11984 nil nil 1 nil nil nil 18096 nil 8 1660489200 818 0 nil 12034 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 18224 7 257 nil 818 0 nil 12034 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 18272 7 257 nil 12144 nil nil nil nil nil #smallIcons nil nil nil nil nil 1106 138 144 34 3 1170 #createAt:extent: 34 2 482 1 1 482 511 575 18096 1170 #basicSelectionsByIndex: 34 1 8 #(1) 18096 1170 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 18096 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 31 1 0 0] 8 #() 1312 nil 27 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 1 482 511 575 16464 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 31 1 0 0] 34 3 16720 17440 18096 1312 nil 27 13138 13184 1 13200 1 13216 1 13232 -99 170 192 34 6 14608 8 'definedPackageClassText' 14880 8 'instanceClassTabs' 16464 8 'classHierarchyTabs' nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 871 1 482 511 675 14496 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 179 1 0 0 0 0 0 0 178 2 0 0 81 1 0 0] 34 3 16464 14880 14608 1312 nil 27 12562 7 11 410 ##(Smalltalk.ContainerView) 34 15 nil 14384 34 2 8 1140850688 131073 18992 nil nil nil 5 nil nil nil 18992 514 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 18992 34 2 8 1409286144 131073 19104 nil 656 nil 5 nil nil nil 19104 674 138 144 1296 nil 170 192 1296 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 19104 34 2 8 1140916736 1 19216 11906 138 144 1296 nil 11984 nil nil 1 nil nil nil 19216 nil 8 1660489200 818 0 nil 12034 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 19328 7 257 nil 818 0 nil 12034 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 19376 7 257 nil 12144 nil nil nil nil nil #noIcons nil nil nil nil nil 1106 138 144 34 2 1170 #createAt:extent: 34 2 482 1 1 482 511 675 19216 1170 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 19216 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 81 1 0 0] 8 #() 1312 nil 27 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 1 482 511 675 19104 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 81 1 0 0] 34 1 19216 1312 nil 27 3 false 170 192 34 2 19104 8 'packageDictionaryCards' nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 351 1 482 511 675 18992 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 175 0 0 0 0 0 0 0 174 1 0 0 81 1 0 0] 34 1 19104 1312 nil 27 12562 7 11 410 ##(Smalltalk.ListView) 34 30 nil 14384 34 2 8 1409405261 1025 20000 11906 138 144 1296 nil 11984 656 nil 5 nil nil nil 20000 nil 8 1660151920 16834 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 12144 nil nil nil nil nil nil 138 144 34 1 16914 8 'Column 1' 333 #left 818 0 nil 850 2 1 816 8 'doIt' 8 '[:each | each displayName]' 8 #[30 105 226 0 106] #displayName 20208 7 257 nil ##(Smalltalk.SortedCollection) nil nil 20000 nil 3 818 0 nil 850 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 20288 7 257 nil 818 0 nil 850 3 1 816 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 20368 7 257 nil #report 1296 nil 133217 nil 34 4 nil nil 482 1 1 nil 1106 138 144 34 2 1170 #createAt:extent: 34 2 482 1 1 482 341 675 20000 1170 #text: 34 1 8 'Column 1' 20000 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 170 0 0 0 81 1 0 0] 8 #() 1312 nil 27 12562 5 11 false 170 192 34 2 20000 8 'projectList' nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 1 482 2241 675 14384 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 7 20000 410 ##(Smalltalk.Splitter) 34 12 nil 14384 34 2 8 1140850688 1 20912 nil 656 nil 517 nil nil nil 8914 20912 nil 1 #left nil nil nil 8944 8960 nil 8944 nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 341 1 482 11 675 20912 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 170 0 0 0 0 0 0 0 175 0 0 0 81 1 0 0] 8 #() 1312 nil 27 18992 410 ##(Smalltalk.Splitter) 34 12 nil 14384 34 2 8 1140850688 1 21152 nil 656 nil 517 nil nil nil 8914 21152 nil 1 #left nil nil nil 8944 8960 nil 8944 nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 861 1 482 11 675 21152 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 174 1 0 0 0 0 0 0 179 1 0 0 81 1 0 0] 8 #() 1312 nil 27 14496 410 ##(Smalltalk.Splitter) 34 12 nil 14384 34 2 8 1140850688 1 21392 nil 656 nil 517 nil nil nil 8914 21392 nil 1 #left nil nil nil 8944 8960 nil 8944 nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1381 1 482 11 675 21392 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 178 2 0 0 0 0 0 0 183 2 0 0 81 1 0 0] 8 #() 1312 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 14384 34 2 8 1140850688 131073 21632 nil nil nil 5 nil nil nil 21632 514 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 21632 34 2 8 1140850688 131073 21744 nil nil nil 5 nil nil nil 21744 12674 170 176 34 6 410 ##(Smalltalk.ListView) 34 30 nil 21744 34 2 8 1409372233 1025 21856 11906 138 144 1296 nil 11984 656 nil 13 nil nil nil 21856 nil 8 1660151920 16834 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 12144 nil nil nil nil nil nil 138 144 34 2 16914 8 '' 41 #left 1170 #empty 8 #() 16 16834 #<= 8 #() nil nil 21856 818 0 nil 850 2 1 816 8 'doIt' 8 '[:each | each subSuperIcon]' 8 #[30 105 226 0 106] #subSuperIcon 22128 7 257 nil 1 nil nil 16914 8 'Selector' 421 #left 16834 #displayString 21984 ##(Smalltalk.SortedCollection) nil nil 21856 nil 3 nil 818 0 nil 850 5 1 816 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 22256 7 257 nil #report 1296 nil 133221 nil 34 4 nil nil 482 1 1 nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 55 482 469 571 21856 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 27 0 0 0 234 0 0 0 56 1 0 0] 8 #() 1312 nil 27 13138 13184 1 13200 1 13216 55 13232 -49 410 ##(Smalltalk.PushButton) 34 20 nil 21744 34 2 8 1140858880 1 22544 nil 656 nil 5 nil nil nil 22544 nil 8 1660261440 1602 #gotoMethodDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 625 482 469 51 22544 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 234 0 0 0 81 1 0 0] 8 #() 1312 nil 29 13138 13184 1 13200 1 13232 -49 13232 1 410 ##(Smalltalk.TextEdit) 34 16 nil 21744 34 2 8 1140916352 1025 22816 nil 656 nil 5 nil nil nil 22816 nil 8 1660100096 2178 nil nil 3 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 1 482 469 51 22816 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 234 0 0 0 25 0 0 0] 8 #() 1312 nil 27 13138 13184 1 13200 1 13216 1 13216 51 170 192 34 6 21856 8 'methodList' 22544 8 'definedPackageMethodText' 22816 8 'categoryMethodText' nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 383 1 482 469 675 21744 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 191 0 0 0 0 0 0 0 169 1 0 0 81 1 0 0] 34 3 21856 22544 22816 1312 nil 27 14242 8 0 0 0 0 0 0 244 63 false 170 192 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 21632 34 2 8 1409286144 131073 23376 nil 656 nil 5 nil nil nil 23376 674 138 144 34 2 738 8 'Category' 410 ##(Smalltalk.ListView) 34 30 nil 23376 34 2 8 1409372233 1025 23520 11906 138 144 1296 nil 11984 656 nil 21 nil nil nil 23520 nil 8 1660151920 16834 #displayString 8 #() nil 12144 nil nil nil nil nil nil 138 144 34 1 16914 8 'Column 1' 349 #left 16834 #displayString 8 #() ##(Smalltalk.SortedCollection) 818 0 nil 850 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each]' 1779525917 23760 7 257 nil nil 23520 nil 3 nil nil #report 1296 nil 131169 nil 34 4 nil nil 482 1 1 nil 1106 138 144 34 2 1170 #createAt:extent: 34 2 482 9 53 482 357 615 23520 1170 #text: 34 1 8 'Column 1' 23520 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 182 0 0 0 77 1 0 0] 8 #() 1312 nil 27 738 8 'Variables' 410 ##(Smalltalk.ListView) 34 30 nil 23376 34 2 8 1409372233 1025 24096 11906 138 144 1296 nil 11984 656 nil 21 nil nil nil 24096 nil 8 1660151920 16834 #displayString 8 #() nil 12144 nil nil 818 0 nil 850 4 1 816 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 24240 7 257 nil nil nil nil 138 144 34 1 16914 8 'Column 1' 349 #left 16834 #displayString 24224 ##(Smalltalk.SortedCollection) nil nil 24096 nil 3 nil 818 0 nil 850 4 1 816 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 24400 7 257 nil #report 1296 nil 131169 nil 34 4 nil nil 482 1 1 nil 1106 138 144 34 2 1170 #createAt:extent: 34 2 482 9 53 482 357 615 24096 1170 #text: 34 1 8 'Column 1' 24096 1250 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 182 0 0 0 77 1 0 0] 8 #() 1312 nil 27 23520 170 192 34 4 24096 8 'variableList' 23520 8 'categoryList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 23376 34 2 8 1140916736 1 24784 11906 138 144 34 2 23504 24080 nil 11984 nil nil 1 nil nil nil 24784 nil 8 1660489200 818 0 nil 12034 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 24912 7 257 nil 818 0 nil 12034 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 24960 7 257 nil 12144 nil nil nil nil nil #noIcons nil nil nil nil nil 1106 138 144 34 3 1170 #createAt:extent: 34 2 482 1 1 482 373 675 24784 1170 #basicSelectionsByIndex: 34 1 8 #(1) 24784 1170 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 24784 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 186 0 0 0 81 1 0 0] 8 #() 1312 nil 27 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 1 482 373 675 23376 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 186 0 0 0 81 1 0 0] 34 3 23520 24096 24784 1312 nil 27 8 'methodFilterTabs' nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1391 1 482 851 675 21632 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 183 2 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 3 23376 410 ##(Smalltalk.Splitter) 34 12 nil 21632 34 2 8 1140850688 1 25584 nil 656 nil 517 nil nil nil 8914 25584 nil 1 #left nil nil nil 8944 8960 nil 8944 nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 373 1 482 11 675 25584 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 186 0 0 0 0 0 0 0 191 0 0 0 81 1 0 0] 8 #() 1312 nil 27 21744 1312 nil 27 1312 nil 27 7 false 170 192 1296 nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 1 482 2241 675 14272 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 1 14384 1312 nil 27 12562 3 5 true 170 192 34 4 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 26048 nil 656 nil 517 nil nil nil 8914 26048 nil 1 #left nil nil nil 8944 8960 nil 8944 nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 1 675 482 2241 11 26048 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 81 1 0 0 96 4 0 0 86 1 0 0] 8 #() 1312 nil 27 8 'splitter' 576 8 'textAreaTabs' nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 482 7679 21 482 2241 1401 416 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 95 19 0 0 198 2 0 0] 34 4 14272 26048 576 12592 1312 nil 27 )! !
!JadeiteBrowserPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

