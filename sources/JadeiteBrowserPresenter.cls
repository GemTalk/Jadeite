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
			projectInfoView backcolor: JadeiteTextStyles default colorForNoEdits.
			projectInfoView
				contextMenu: self projectInfoMenu;
				hasColumnHeaders: false;
				hasGridLines: false;
				isMultiSelect: true.
			(projectInfoView allColumns at: 1)
				isEditable: false;
				width: 175;
				getImageBlock: IconicListAbstract;
				getContentsBlock: [:each | each at: 2].
			projectInfoView addColumn.
			(projectInfoView allColumns at: 2)
				isEditable: false;
				getImageBlock: IconicListAbstract;
				isAutoResize: true;
				getContentsBlock: [:each | (each at: 2) ifNil: [String new] ifNotNil: [:iv | (each at: 1) instVarNamed: iv]]]
		ifNotNil: [projectInfoView := projectInfoTab view].
	projectInfoView
		arrangement: 'Project';
		name: 'projectInfoTab'.
	^projectInfoView!

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
	menuStrings := #('&Classes' '&Browse Class References//browseClassReferences' 'Browse SUnit//showSUnitBrowserOnClass' '&File Out Class//fileOutClass' 'Add &Subclass//addSubclass'  'Copy ...//copyClass' '&Remove//removeClass' '-')
				asOrderedCollection.
	menuStrings add: '&Expand Full Hierarchy//expandFullHierarchy'.
	menuStrings add: '-'.
	menuStrings addLast: definedLabel , '//gotoClassDefinedPackage'.
	menuStrings addLast: containedDictionaryLabel , '//gotoDictionary'.
	^menuStrings!

comparisonPresenter

	^comparisonPresenter!

contextObject
	^self selectedClass
		ifNil: [^nil]
		ifNotNil: [:classService | gciSession oopTypeWithOop: classService oop]!

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

isNoneProjectSelected
	^projectListPresenter selections includes: RowanProjectService noneProject!

isProjectItemEnabled: command
	(command = #refreshFromServer or: [command = #cloneProject]) ifTrue: [^true].
	^projectListPresenter selections notEmpty
		and: [(projectListPresenter selections includes: RowanProjectService noneProject) not]!

isRowanProjectSelected
	^(self isNoneProjectSelected or: [projectListPresenter selections isEmpty]) not!

maxAutoCompleteListSize
	^50!

methodToReformat
	^methodListPresenter selectionIfNone: [RowanMethodService new]!

noClassSelectedInEitherPresenter
	classListPresenter selectionIfNone: [classHierarchyPresenter selectionIfNone: [^true]].
	^false!

onViewOpened

	super onViewOpened. 
	self showPackageList!

openCommitInGitHub
	| projectService |
	projectService := projectListPresenter selection.
	^JadePresenter openCommit: projectService sha inGitHub: projectService!

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
			^self].
	classHierarchyPresenter model: TreeModel new.
	self projectListPresenter selection name = RowanService notRowanizedPackageName
		ifTrue: 
			[self showDictionaryList.
			self updateTabLabel.
			self updateProjectInfo]
		ifFalse: 
			[self showPackageList.
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
!JadeiteBrowserPresenter categoriesFor: #buildGlobalsTab!private!tabs! !
!JadeiteBrowserPresenter categoriesFor: #buildProjectTab!private!tabs! !
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
!JadeiteBrowserPresenter categoriesFor: #insertCompileErrorText:into:!compile support!public! !
!JadeiteBrowserPresenter categoriesFor: #insertIfFalse!menu handlers!must not strip!public! !
!JadeiteBrowserPresenter categoriesFor: #insertIfTrue!menu handlers!must not strip!public! !
!JadeiteBrowserPresenter categoriesFor: #inspectGlobal!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #isNoneProjectSelected!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #isProjectItemEnabled:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #isRowanProjectSelected!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #maxAutoCompleteListSize!constants!public! !
!JadeiteBrowserPresenter categoriesFor: #methodToReformat!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #noClassSelectedInEitherPresenter!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #onViewOpened!event handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #openCommitInGitHub!menu handlers!public! !
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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil 328198 ##(Smalltalk.Point) 2241 1401 517 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 6 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 576 nil nil nil 5 nil nil nil 576 514 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 576 34 2 8 1140850688 131073 688 nil nil nil 5 nil nil nil 688 514 170 176 34 6 410 ##(Smalltalk.ListView) 34 30 nil 688 34 2 8 1409405261 1025 800 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 524550 ##(Smalltalk.ColorRef) 8 4278190080 nil 5 nil nil nil 800 nil 8 4294905919 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 1 920646 5 ##(Smalltalk.ListViewColumn) 8 'Column 1' 333 #left 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 1184 8 'doIt' 8 '[:each | each displayName]' 8 #[30 105 226 0 106] #displayName 1200 7 257 nil ##(Smalltalk.SortedCollection) nil nil 800 nil 3 1186 0 nil 1218 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 1296 7 257 nil 1186 0 nil 1218 3 1 1184 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 1376 7 257 nil #report 912 nil 133217 nil 34 4 nil nil 482 1 1 nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 482 1 1 482 341 675 800 1554 #text: 34 1 8 'Column 1' 800 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 170 0 0 0 81 1 0 0] 8 #() 482 193 193 nil 27 524806 ##(Smalltalk.Fraction) 5 11 410 ##(Smalltalk.ContainerView) 34 15 nil 688 34 2 8 1140850688 131073 1792 nil nil nil 5 nil nil nil 1792 514 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 1792 34 2 8 1409286144 131073 1904 nil 962 8 4278190080 nil 5 nil nil nil 1904 655878 ##(Smalltalk.CardLayout) 138 144 912 nil 170 192 912 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 1904 34 2 8 1140916736 1 2064 866 138 144 912 nil 944 nil nil 1 nil nil nil 2064 nil 8 4294907827 1186 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 2176 7 257 nil 1186 0 nil 2194 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 2240 7 257 nil 1088 nil nil nil nil nil #noIcons nil nil nil nil nil 1490 138 144 34 2 1554 #createAt:extent: 34 2 482 1 1 482 511 675 2064 1554 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 2064 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 81 1 0 0] 8 #() 1744 nil 27 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 1 1 482 511 675 1904 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 81 1 0 0] 34 1 2064 1744 nil 27 3 false 170 192 34 2 1904 8 'packageDictionaryCards' nil 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 351 1 482 511 675 1792 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 175 0 0 0 0 0 0 0 174 1 0 0 81 1 0 0] 34 1 1904 1744 nil 27 1762 7 11 410 ##(Smalltalk.ContainerView) 34 15 nil 688 34 2 8 1140850688 131073 2864 nil nil nil 5 nil nil nil 2864 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.CardContainer) 34 16 nil 2864 34 2 8 1409286144 131073 2992 nil 962 8 4278190080 nil 5 nil nil nil 2992 2002 138 144 34 2 721414 ##(Smalltalk.Association) 590662 1 ##(Smalltalk.CardLabel) 8 'Classes' 1186 0 nil 1218 7 1 16 8 'doIt' 8 '(CardLabel text: ''Classes'' iconBlock: [Icon fromId: ''Class.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 3168 3200 ##(Smalltalk.Icon) 8 'Class.ico' #fromId: #text:iconBlock: 3216 11 1 nil nil 410 ##(Smalltalk.ListView) 34 30 nil 2992 34 2 8 1409372237 1025 3312 866 138 144 912 nil 944 962 992 nil 21 nil nil nil 3312 nil 8 4294905919 1026 #displayString 8 #() nil 1088 nil nil nil nil nil nil 138 144 34 1 1138 8 '' 487 #left 1026 #displayString 8 #() 1026 #<= 8 #() nil nil 3312 nil 3 nil 1186 0 nil 1218 5 1 1184 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 3600 7 257 nil #report 912 nil 131169 nil 34 4 nil nil 482 1 1 nil 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 9 55 482 495 513 3312 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 251 0 0 0 27 1 0 0] 8 #() 1744 nil 27 3138 3170 8 'Hierarchy' 1186 0 nil 1218 7 1 16 8 'doIt' 8 '(CardLabel text: ''Hierarchy'' iconBlock: [Icon fromId: ''ClassHierarchyDiagram.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 3168 3904 ##(Smalltalk.Icon) 8 'ClassHierarchyDiagram.ico' #fromId: #text:iconBlock: 3920 11 1 nil nil 410 ##(Smalltalk.TreeView) 34 27 nil 2992 34 2 8 1409352231 1025 4016 590918 3 ##(Smalltalk.TreeModel) nil 944 525062 ##(Smalltalk.TreeNode) nil nil nil 170 192 912 962 8 4278190080 nil 21 nil nil nil 4016 nil 8 4294906907 1186 0 nil 1218 2 1 1184 8 'doIt' 8 '[:each | each displayString]' 8 #[30 105 226 0 106] #displayString 4208 7 257 nil ##(Smalltalk.IconicListAbstract) 1088 nil 1186 0 nil 1218 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 4288 7 257 nil 1186 0 nil 1218 5 1 1184 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 4368 7 257 nil nil nil 170 176 912 17 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 912 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 9 55 482 495 513 4016 1682 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 251 0 0 0 27 1 0 0] 8 #() 1744 nil 27 3312 170 192 34 4 4016 8 'classHierarchy' 3312 8 'classList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 2992 34 2 8 1140916736 1 4704 866 138 144 34 2 3184 3888 nil 944 nil nil 1 nil nil nil 4704 nil 8 4294907827 1186 0 nil 2194 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 4832 7 257 nil 1186 0 nil 2194 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 4880 7 257 nil 1088 nil nil nil nil nil #smallIcons nil nil nil nil nil 1490 138 144 34 3 1554 #createAt:extent: 34 2 482 1 1 482 511 575 4704 1554 #basicSelectionsByIndex: 34 1 8 #(1) 4704 1554 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 4704 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 31 1 0 0] 8 #() 1744 nil 27 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 1 1 482 511 575 2992 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 31 1 0 0] 34 3 3312 4016 4704 1744 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 5362 #fixedParentRight 1 5362 #fixedParentTop 1 5362 #fixedParentBottom -99 410 ##(Smalltalk.CardContainer) 34 16 nil 2864 34 2 8 1409286144 131073 5440 nil 962 8 4278190080 nil 5 nil nil nil 5440 2002 138 144 34 2 3138 3170 8 'Instance' 1186 0 nil 1218 7 1 16 8 'doIt' 8 '(CardLabel text: ''Instance'' iconBlock: [Icon fromId: ''Class.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 3168 5616 ##(Smalltalk.Icon) 8 'Class.ico' #fromId: #text:iconBlock: 5632 11 1 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 5440 34 2 8 1140850688 131073 5728 nil nil nil 5 nil nil nil 5728 nil 170 192 912 nil 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 9 9 482 495 1 5728 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 251 0 0 0 4 0 0 0] 8 #() 1744 nil 27 3138 3170 8 'Class' 1186 0 nil 1218 7 1 16 8 'doIt' 8 '(CardLabel text: ''Class'' iconBlock: [Icon fromId: ''Metaclass.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 3168 6000 ##(Smalltalk.Icon) 8 'Metaclass.ico' #fromId: #text:iconBlock: 6016 11 1 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 5440 34 2 8 1140850688 131073 6112 nil nil nil 5 nil nil nil 6112 nil 170 192 912 nil 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 9 9 482 495 1 6112 1682 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 251 0 0 0 4 0 0 0] 8 #() 1744 nil 27 5728 170 192 34 4 6112 8 'classTab' 5728 8 'instanceTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 5440 34 2 8 1140916738 1 6416 866 138 144 34 2 5600 5984 nil 944 nil nil 1 nil nil nil 6416 nil 8 4294907827 1186 0 nil 2194 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 6544 7 257 nil 1186 0 nil 2194 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 6592 7 257 nil 1088 nil nil nil nil nil #smallIcons nil nil nil nil nil 1490 138 144 34 3 1554 #createAt:extent: 34 2 482 1 1 482 511 51 6416 1554 #basicSelectionsByIndex: 34 1 8 #(1) 6416 1554 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 6416 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 25 0 0 0] 8 #() 1744 nil 27 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 1 575 482 511 51 5440 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 31 1 0 0 255 0 0 0 56 1 0 0] 34 3 5728 6112 6416 1744 nil 27 5330 5376 1 5392 1 5424 -99 5362 #fixedViewTop 51 410 ##(Smalltalk.PushButton) 34 20 nil 2864 34 2 8 1140858880 1 7072 nil 786694 ##(Smalltalk.IndexedColor) 33554447 nil 5 nil nil nil 7072 nil 8 4294901953 1180998 4 ##(Smalltalk.CommandDescription) #gotoClassDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 1 625 482 511 51 7072 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 255 0 0 0 81 1 0 0] 8 #() 1744 nil 29 5330 5376 1 5392 1 5424 -49 5424 1 170 192 34 6 2992 8 'classHierarchyTabs' 5440 8 'instanceClassTabs' 7072 8 'definedPackageClassText' nil 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 871 1 482 511 675 2864 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 179 1 0 0 0 0 0 0 178 2 0 0 81 1 0 0] 34 3 2992 5440 7072 1744 nil 27 1762 7 11 false 170 192 34 2 800 8 'projectList' nil 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 1 1 482 2241 675 688 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 7 800 410 ##(Smalltalk.Splitter) 34 12 nil 688 34 2 8 1140850688 1 7856 nil 962 8 4278190080 nil 517 nil nil nil 7856 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 341 1 482 11 675 7856 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 170 0 0 0 0 0 0 0 175 0 0 0 81 1 0 0] 8 #() 1744 nil 27 1792 410 ##(Smalltalk.Splitter) 34 12 nil 688 34 2 8 1140850688 1 8112 nil 962 7936 nil 517 nil nil nil 8112 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 861 1 482 11 675 8112 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 174 1 0 0 0 0 0 0 179 1 0 0 81 1 0 0] 8 #() 1744 nil 27 2864 410 ##(Smalltalk.Splitter) 34 12 nil 688 34 2 8 1140850688 1 8352 nil 962 7936 nil 517 nil nil nil 8352 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 1381 1 482 11 675 8352 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 178 2 0 0 0 0 0 0 183 2 0 0 81 1 0 0] 8 #() 1744 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 688 34 2 8 1140850688 131073 8592 nil nil nil 5 nil nil nil 8592 514 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 8592 34 2 8 1140850688 131073 8704 nil nil nil 5 nil nil nil 8704 2930 170 176 34 6 410 ##(Smalltalk.PushButton) 34 20 nil 8704 34 2 8 1140858880 1 8816 nil 962 8 4278190080 nil 5 nil nil nil 8816 nil 8 4294901953 7186 #gotoMethodDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 1 625 482 469 51 8816 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 234 0 0 0 81 1 0 0] 8 #() 1744 nil 29 5330 5376 1 5392 1 5424 -49 5424 1 410 ##(Smalltalk.ListView) 34 30 nil 8704 34 2 8 1409372233 1025 9120 866 138 144 912 nil 944 962 8 4278190080 nil 13 nil nil nil 9120 nil 8 4294905919 1026 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 1088 nil nil nil nil nil nil 138 144 34 2 1138 8 '' 41 #left 1554 #empty 8 #() 16 1026 #<= 8 #() nil nil 9120 1186 0 nil 1218 2 1 1184 8 'doIt' 8 '[:each | each subSuperIcon]' 8 #[30 105 226 0 106] #subSuperIcon 9424 7 257 nil 1 nil nil 1138 8 'Selector' 421 #left 1026 #displayString 9280 ##(Smalltalk.SortedCollection) nil nil 9120 nil 3 nil 1186 0 nil 1218 5 1 1184 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 9552 7 257 nil #report 912 nil 133221 nil 34 4 nil nil 482 1 1 nil 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 1 55 482 469 571 9120 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 27 0 0 0 234 0 0 0 56 1 0 0] 8 #() 1744 nil 27 5330 5376 1 5392 1 5408 55 5424 -49 410 ##(Smalltalk.TextEdit) 34 16 nil 8704 34 2 8 1140916352 1025 9840 nil 962 8 4278190080 nil 5 nil nil nil 9840 nil 8 4294905431 852486 ##(Smalltalk.NullConverter) nil nil 3 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 1 1 482 469 51 9840 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 234 0 0 0 25 0 0 0] 8 #() 1744 nil 27 5330 5376 1 5392 1 5408 1 5408 51 170 192 34 6 8816 8 'definedPackageMethodText' 9120 8 'methodList' 9840 8 'categoryMethodText' nil 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 383 1 482 469 675 8704 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 191 0 0 0 0 0 0 0 169 1 0 0 81 1 0 0] 34 3 9120 8816 9840 1744 nil 27 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 244 63 false 170 192 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 8592 34 2 8 1409286144 131073 10464 nil 962 8 4278190080 nil 5 nil nil nil 10464 2002 138 144 34 2 3138 8 'Category' 410 ##(Smalltalk.ListView) 34 30 nil 10464 34 2 8 1409372233 1025 10640 866 138 144 912 nil 944 962 9232 nil 21 nil nil nil 10640 nil 8 4294905919 1026 #displayString 8 #() nil 1088 nil nil nil nil nil nil 138 144 34 1 1138 8 'Column 1' 349 #left 1026 #displayString 8 #() ##(Smalltalk.SortedCollection) 1186 0 nil 1218 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each]' 1779525917 10896 7 257 nil nil 10640 nil 3 nil nil #report 912 nil 131169 nil 34 4 nil nil 482 1 1 nil 1490 138 144 34 2 1554 #createAt:extent: 34 2 482 9 55 482 357 613 10640 1554 #text: 34 1 8 'Column 1' 10640 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 182 0 0 0 77 1 0 0] 8 #() 1744 nil 27 3138 8 'Variables' 410 ##(Smalltalk.ListView) 34 30 nil 10464 34 2 8 1409372233 1025 11232 866 138 144 912 nil 944 962 9232 nil 21 nil nil nil 11232 nil 8 4294905919 1026 #displayString 8 #() nil 1088 nil nil 1186 0 nil 1218 4 1 1184 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 11392 7 257 nil nil nil nil 138 144 34 1 1138 8 'Column 1' 349 #left 1026 #displayString 11376 ##(Smalltalk.SortedCollection) nil nil 11232 nil 3 nil 1186 0 nil 1218 4 1 1184 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 11552 7 257 nil #report 912 nil 131169 nil 34 4 nil nil 482 1 1 nil 1490 138 144 34 2 1554 #createAt:extent: 34 2 482 9 55 482 357 613 11232 1554 #text: 34 1 8 'Column 1' 11232 1682 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 182 0 0 0 77 1 0 0] 8 #() 1744 nil 27 10640 170 192 34 4 10640 8 'categoryList' 11232 8 'variableList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 10464 34 2 8 1140916736 1 11936 866 138 144 34 2 10624 11216 nil 944 nil nil 1 nil nil nil 11936 nil 8 4294907827 1186 0 nil 2194 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 12064 7 257 nil 1186 0 nil 2194 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 12112 7 257 nil 1088 nil nil nil nil nil #noIcons nil nil nil nil nil 1490 138 144 34 3 1554 #createAt:extent: 34 2 482 1 1 482 373 675 11936 1554 #basicSelectionsByIndex: 34 1 8 #(1) 11936 1554 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 11936 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 186 0 0 0 81 1 0 0] 8 #() 1744 nil 27 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 1 1 482 373 675 10464 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 186 0 0 0 81 1 0 0] 34 3 10640 11232 11936 1744 nil 27 8 'methodFilterTabs' nil 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 1391 1 482 851 675 8592 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 183 2 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 3 10464 410 ##(Smalltalk.Splitter) 34 12 nil 8592 34 2 8 1140850688 1 12736 nil 962 7936 nil 517 nil nil nil 12736 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 373 1 482 11 675 12736 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 186 0 0 0 0 0 0 0 191 0 0 0 81 1 0 0] 8 #() 1744 nil 27 8704 1744 nil 27 1744 nil 27 7 false 170 192 912 nil 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 1 1 482 2241 675 576 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 1 688 1744 nil 27 1762 3 5 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 13168 nil 962 3072 nil 5 nil nil nil 13168 2002 138 144 34 5 3138 3170 8 'SUnit' 1186 0 nil 1218 4 1 1184 8 'doIt' 8 '[Icon fromId: ''icons\UnitTestPlugin.ico'']' 8 #[32 105 45 30 178 106] 983558 ##(Smalltalk.VariableBinding) #Icon ##(Smalltalk.Icon) 8 'icons\UnitTestPlugin.ico' #fromId: 13344 7 1 nil nil 410 ##(Smalltalk.ReferenceView) 34 14 nil 13168 34 2 8 1140850688 131073 13472 nil 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 nil nil nil 13472 1180166 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteSUnitInClassPresenter) #resource_Default_view nil 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 9 55 482 2225 613 13472 1682 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 912 1744 nil 27 3138 3170 8 'Class Definition' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 13168 34 2 8 1445007428 1025 13792 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 13538 26337781 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 11 984134 2 ##(Smalltalk.CommandMenuItem) 1 7186 #editSave 8 '&Save' 9383 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 13986 1 7186 #editUndo 8 '&Undo' 9397 1 nil nil nil 13986 1 7186 #editRedo 8 '&Redo' 9395 1 nil nil nil 14050 4097 13986 1 7186 #editCut 8 'Cu&t' 9393 1 nil nil nil 13986 1 7186 #editCopy 8 '&Copy' 9351 1 nil nil nil 13986 1 7186 #editPaste 8 '&Paste' 9389 1 nil nil nil 13986 1 7186 #editDelete 8 '&Delete' 1629 1 nil nil nil 14050 4097 13986 1 7186 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 13792 nil 8 4294907885 9954 nil nil 13 nil 170 192 34 4 #normal 1182790 1 ##(Smalltalk.ScintillaTextStyle) 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 14626 77 7138 33554457 7138 33554471 1 nil nil nil nil #callTip nil nil nil 34 256 14640 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 14656 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1639686 ##(Smalltalk.SmalltalkExpressionStyler) 1 nil nil false 138 144 912 170 192 34 2 #default 1641542 1 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 13792 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 912 nil 170 176 912 9215 nil nil nil nil 7152 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 14640 nil nil nil nil 1 nil 170 192 34 6 1 1510470 2 ##(Smalltalk.ScintillaIndicatorStyle) 1 13792 65025 3 false 1 nil nil nil nil nil nil 3 15058 3 13792 33423361 5 false 3 nil nil nil nil nil nil 5 15058 5 13792 511 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 14626 1029 nil 13538 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 14626 1027 13538 60239 13538 31326207 1 nil nil nil nil #Warning nil nil nil #Error 14626 1031 13538 335 13538 31317503 1 nil nil nil nil #Error nil nil nil nil 1490 138 144 34 8 1554 #createAt:extent: 34 2 482 9 55 482 2225 613 13792 1554 #contextMenu: 34 1 13952 13792 1554 #modificationEventMask: 8 #(4607) 13792 1554 #caretPeriod: 8 #(530) 13792 1554 #wordWrap: 8 #(true) 13792 1554 #margins: 34 1 34 3 985158 2 ##(Smalltalk.ScintillaMargin) 1 13792 1 3 nil nil 5 nil 15570 3 13792 33 nil 3 67108863 5 nil 15570 5 13792 1 nil 3 -67108863 5 nil 13792 1554 #tabWidth: 8 #(4) 13792 1554 #maxCompletionListHeight: 8 #(9) 13792 1682 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1744 nil 29 3138 3170 8 'Class Documentation' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 13168 34 2 8 1445007428 1025 15792 13858 nil false 13904 nil 13538 26337781 nil 5 13938 nil true 34 1 13986 1 7186 #editSaveClassComment 8 'Save' 1025 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 14466 nil true 14498 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 15792 nil 8 4294907885 9954 nil nil 15 nil 170 192 34 4 #normal 14626 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 14626 77 14672 14688 1 nil nil nil nil #callTip nil nil nil 34 256 16112 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 16128 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 14802 1 nil nil nil 15792 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 912 nil 170 176 912 9215 nil nil nil nil 7152 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 16112 nil nil nil nil 1 nil 170 192 34 6 1 15058 1 15792 65025 3 false 1 nil nil nil nil nil nil 3 15058 3 15792 33423361 5 false 3 nil nil nil nil nil nil 5 15058 5 15792 511 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 14626 1029 nil 13538 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 14626 1027 13538 60239 13538 31326207 1 nil nil nil nil #Warning nil nil nil #Error 14626 1031 13538 335 13538 31317503 1 nil nil nil nil #Error nil nil nil nil 1490 138 144 34 8 1554 #createAt:extent: 34 2 482 9 55 482 2225 613 15792 1554 #contextMenu: 34 1 15888 15792 1554 #modificationEventMask: 8 #(4607) 15792 1554 #caretPeriod: 8 #(530) 15792 1554 #wordWrap: 8 #(true) 15792 1554 #margins: 34 1 34 3 15570 1 15792 1 3 nil nil 5 nil 15570 3 15792 33 nil 3 67108863 5 nil 15570 5 15792 1 nil 3 -67108863 5 nil 15792 1554 #tabWidth: 8 #(4) 15792 1554 #maxCompletionListHeight: 8 #(9) 15792 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1744 nil 29 3138 3170 8 'Method Source' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 13168 34 2 8 1445007428 1025 17088 13858 nil false 13904 nil 13538 26337781 nil 5 nil 14466 nil true 14498 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 17088 nil 8 4294907885 9954 nil nil 13 nil 170 192 34 4 #normal 14626 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 14626 77 14672 14688 1 nil nil nil nil #callTip nil nil nil 34 256 17312 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 17328 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 912 170 192 34 2 #default 14802 1 nil nil nil 17088 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 912 nil 170 176 912 9215 nil nil nil nil 7152 nil nil 65 nil nil 14864 8 '' 3 170 192 34 2 #container 170 192 34 4 #normal 17312 #callTip 17328 nil nil nil nil 1 nil 170 192 34 12 1 15058 1 17088 65025 3 false 1 nil nil nil nil nil nil 3 15058 3 17088 33423361 5 false 3 nil nil nil nil nil nil 5 15058 5 17088 511 1 false 5 nil nil nil nil nil nil 8 'indicator8' 15058 17 17088 33554447 1 nil nil nil nil nil nil nil nil 8 'indicator9' 15058 19 17088 33554459 13 nil nil nil nil nil nil nil nil 8 'indicator10' 15058 21 17088 33554459 3 nil nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 14626 1029 nil 13538 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 14626 1027 13538 60239 13538 31326207 1 nil nil nil nil #Warning nil nil nil #Error 14626 1031 13538 335 13538 31317503 1 nil nil nil nil #Error nil nil nil nil 1490 138 144 34 8 1554 #createAt:extent: 34 2 482 9 55 482 2225 613 17088 1554 #modificationEventMask: 8 #(4607) 17088 1554 #hoverTime: 8 #(200) 17088 1554 #caretPeriod: 8 #(530) 17088 1554 #wordWrap: 8 #(true) 17088 1554 #margins: 34 1 34 3 15570 1 17088 61 3 nil nil 5 nil 15570 3 17088 1 nil 3 67108863 nil nil 15570 5 17088 1 nil 3 -67108863 nil nil 17088 1554 #tabWidth: 8 #(4) 17088 1554 #maxCompletionListHeight: 8 #(9) 17088 1682 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1744 nil 29 3138 8 'Comparison' 410 ##(Smalltalk.ShellView) 34 27 nil 13168 34 2 8 1078919168 131073 18384 nil 962 8 4278190080 nil 517 nil nil nil 18384 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 18384 34 2 8 1140850688 131073 18512 nil 13538 26337781 nil 5 13938 nil true 34 5 13986 1 7186 #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 13986 1 7186 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 13986 1 7186 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 13986 1 7186 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 13986 1 7186 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 18512 514 170 176 912 false 170 192 912 nil 1490 138 144 34 2 1554 #createAt:extent: 34 2 482 1 1 482 2193 581 18512 1554 #contextMenu: 34 1 18592 18512 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 4 0 0 34 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 18512 34 2 8 1140850688 131073 19120 nil 962 18464 nil 5 nil nil nil 19120 18482 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 19120 34 2 8 1140850945 262145 19216 nil nil nil 5 nil nil nil 19216 nil 8 1663077024 9954 nil nil nil 1490 138 144 34 2 1554 #createAt:extent: 34 2 482 1 541 482 1091 41 19216 1554 #text: 34 1 8 '
' 19216 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 14 1 0 0 33 2 0 0 34 1 0 0] 8 #() 1744 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 19120 34 2 8 1140920580 1025 19520 13858 nil false 13904 nil 13538 26337781 nil 5 nil nil nil 19520 nil 8 4294907885 9954 nil nil 11 nil 170 192 34 12 #indentGuide 14626 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 14626 3 7138 33554445 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 14626 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 14626 77 14672 14688 1 nil nil nil nil #callTip nil nil nil #normal 14626 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 14626 5 nil 13538 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 19760 19696 19776 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 19728 nil nil nil 19680 nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 14802 1 nil nil nil 19520 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 912 nil 170 176 912 9215 nil nil nil nil 7152 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 19648 nil nil nil nil 1 nil 170 192 34 6 8 'indicator1' 15058 3 19520 33423361 5 false nil nil nil nil nil nil nil 8 'indicator0' 15058 1 19520 33554459 13 false nil nil nil nil nil nil nil 8 'indicator2' 15058 5 19520 511 1 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 14626 1029 nil 13538 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 14626 1027 13538 60239 13538 31326207 1 nil nil nil nil #Warning nil nil nil #Error 14626 1031 13538 335 13538 31317503 1 nil nil nil nil #Error nil nil nil nil 1490 138 144 34 7 1554 #createAt:extent: 34 2 482 1 1 482 1091 541 19520 1554 #modificationEventMask: 8 #(4607) 19520 1554 #caretPeriod: 8 #(530) 19520 1554 #wordWrap: 8 #(true) 19520 1554 #margins: 34 1 34 3 15570 1 19520 49 3 nil nil nil nil 15570 3 19520 1 nil nil 67108863 nil nil 15570 5 19520 1 nil nil nil nil nil 19520 1554 #canHScroll: 8 #(false) 19520 1554 #maxCompletionListHeight: 8 #(9) 19520 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 14 1 0 0] 8 #() 1744 nil 29 170 192 34 4 19520 8 'before' 19216 8 'beforeTitle' nil 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 1 1 482 1091 581 19120 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 34 1 0 0] 34 2 19520 19216 1744 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 18512 34 2 8 1140850688 1 20928 nil 13538 66047 nil 517 nil nil nil 20928 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 1091 1 482 11 581 20928 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 33 2 0 0 0 0 0 0 38 2 0 0 34 1 0 0] 8 #() 1744 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 18512 34 2 8 1140850688 131073 21168 nil 962 18464 nil 5 nil nil nil 21168 18482 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 21168 34 2 8 1140850945 262145 21264 nil nil nil 5 nil nil nil 21264 nil 8 1663077024 9954 nil nil nil 1490 138 144 34 2 1554 #createAt:extent: 34 2 482 1 541 482 1093 41 21264 1554 #text: 34 1 8 '
' 21264 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 14 1 0 0 34 2 0 0 34 1 0 0] 8 #() 1744 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 21168 34 2 8 1140920580 1025 21568 13858 nil false 13904 nil 13538 26337781 nil 5 nil nil nil 21568 nil 8 4294907885 9954 nil nil 11 nil 170 192 34 12 #indentGuide 14626 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 14626 3 19712 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 14626 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 14626 77 14672 14688 1 nil nil nil nil #callTip nil nil nil #normal 14626 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 14626 5 nil 13538 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 21792 21744 21808 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 21760 nil nil nil 21728 nil nil 19826 19856 170 192 34 2 #default 14802 1 nil nil nil 21568 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 912 nil 170 176 912 9215 nil nil nil nil 7152 nil nil 65 nil nil nil 19952 3 170 192 34 2 #container 21696 nil nil nil nil 1 nil 170 192 34 6 8 'indicator2' 15058 5 21568 511 1 false nil nil nil nil nil nil nil 8 'indicator0' 15058 1 21568 33554459 13 false nil nil nil nil nil nil nil 8 'indicator1' 15058 3 21568 33423361 5 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 14626 1029 nil 13538 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 14626 1027 13538 60239 13538 31326207 1 nil nil nil nil #Warning nil nil nil #Error 14626 1031 13538 335 13538 31317503 1 nil nil nil nil #Error nil nil nil nil 1490 138 144 34 7 1554 #createAt:extent: 34 2 482 1 1 482 1093 541 21568 1554 #modificationEventMask: 8 #(4607) 21568 1554 #caretPeriod: 8 #(530) 21568 1554 #wordWrap: 8 #(true) 21568 1554 #margins: 34 1 34 3 15570 1 21568 49 3 nil nil nil nil 15570 3 21568 1 nil nil 67108863 nil nil 15570 5 21568 1 nil nil nil nil nil 21568 1554 #canHScroll: 8 #(false) 21568 1554 #maxCompletionListHeight: 8 #(9) 21568 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 34 2 0 0 14 1 0 0] 8 #() 1744 nil 29 170 192 34 4 21264 8 'afterTitle' 21568 8 'after' nil 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 1101 1 482 1093 581 21168 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 38 2 0 0 0 0 0 0 72 4 0 0 34 1 0 0] 34 2 21568 21264 1744 nil 27 1744 nil 27 170 192 34 2 18512 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 13938 nil true 34 4 13986 1 7186 #selectUpper 8 'Select &upper' 1 1 nil nil nil 13986 1 7186 #selectLower 8 'Select &lower' 1 1 nil nil nil 14050 4097 13986 1 7186 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 15179 nil nil 13938 nil true 34 3 13986 1 7186 #character 8 '&Character' 1 1 nil nil nil 13986 1 7186 #word 8 '&Word' 1 1 nil nil nil 13986 1 7186 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 15181 nil nil 13938 nil true 34 1 13986 1 7186 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 15183 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1490 138 144 34 3 1554 #createAt:extent: 34 2 482 9 55 482 2225 613 18384 1554 #text: 34 1 8 'Comparison' 18384 1554 #updateMenuBar 912 18384 1682 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 34 1 18512 1744 nil 27 15792 170 192 34 10 15792 8 'classDocumentation' 13792 8 'classDefinition' 13472 8 'sunit' 17088 8 'methodSource' 18384 8 'comparisonTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 13168 34 2 8 1140916736 1 23856 866 138 144 34 5 13760 15760 17056 13312 18368 nil 944 nil nil 1 nil nil nil 23856 nil 8 4294907827 1186 0 nil 2194 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 23984 7 257 nil 1186 0 nil 2194 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 24032 7 257 nil 1088 nil nil nil nil nil #smallIcons nil nil nil nil nil 1490 138 144 34 3 1554 #createAt:extent: 34 2 482 1 1 482 2241 675 23856 1554 #basicSelectionsByIndex: 34 1 8 #(2) 23856 1554 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 23856 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 8 #() 1744 nil 27 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 1 685 482 2241 675 13168 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 86 1 0 0 96 4 0 0 167 2 0 0] 34 6 13792 15792 17088 13472 18384 23856 1744 nil 27 1762 3 5 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 24496 nil nil 482 2241 43 517 nil nil nil 24496 2930 170 176 34 4 410 ##(Smalltalk.ToolButton) 34 14 nil 24496 34 2 8 1140850688 131073 24624 nil nil nil 1029 nil nil nil 24624 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 24624 34 2 8 1140853580 131137 24688 nil nil 482 43 43 513 nil nil nil 24688 nil 8 4294905879 nil 170 192 34 2 15053 1115910 ##(Smalltalk.ToolbarIconButton) 15053 nil 24688 1 7186 #flipAutoCommit 8 'Auto Commit' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons/camera16_light_icon.ico' nil 395334 3 ##(Smalltalk.Bitmap) nil true nil nil nil nil 3 482 33 33 1 34 1 24832 170 176 34 2 24976 1 nil 3 nil 482 33 33 482 33 33 nil nil 1490 138 144 34 2 1554 #createAt:extent: 34 2 482 1 1 482 43 43 24688 1554 #updateSizePosted 912 24688 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 8 #() 1744 nil 27 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 1 1 482 43 43 24624 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 34 1 24688 1744 nil 27 5330 5376 1 5362 #fixedViewLeft 43 5408 1 7056 43 410 ##(Smalltalk.TextEdit) 34 16 nil 24496 34 2 8 1140850688 1 25456 nil 962 8 4278190080 482 2199 43 517 nil 14466 nil true 14498 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 482 193 193 nil 25456 7138 33554433 8 4294905431 9954 nil nil 67 1490 138 144 34 2 1554 #createAt:extent: 34 2 482 43 1 482 2199 43 25456 1554 #setMarginWidths: 34 1 8 #(3 3) 25456 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 21 0 0 0 0 0 0 0 96 4 0 0 21 0 0 0] 8 #() 1744 nil 27 5330 5376 43 5392 1 5408 1 5424 1 170 192 34 4 24624 8 'autoCommitButton' 25456 8 'statusBarField' nil 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 1 1359 482 2241 43 24496 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 167 2 0 0 96 4 0 0 188 2 0 0] 34 2 24624 25456 1744 nil 27 10402 8 184 30 133 235 81 184 158 63 true 170 192 34 4 13168 8 'textAreaTabs' 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 26192 nil 962 7936 nil 517 nil nil nil 26192 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 1 675 482 2241 11 26192 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 81 1 0 0 96 4 0 0 86 1 0 0] 8 #() 1744 nil 27 8 'splitter' nil 1490 138 144 34 1 1554 #createAt:extent: 34 2 482 7679 21 482 2241 1401 416 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 95 19 0 0 198 2 0 0] 34 4 576 26192 13168 24496 1744 nil 27 )! !
!JadeiteBrowserPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

