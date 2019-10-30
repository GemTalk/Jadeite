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
	browserService
		ifNil: [self refreshGlobalSelections]
		ifNotNil: 
			[browserService projectsUpdate: projectListPresenter browser: self.
			browserService dictionaryListUpdate: dictionaryPresenter].
	self autoCommit: (autoCommit value == #failed ifTrue: [true] ifFalse: [autoCommit value])!

registerPresentersForUpdates
	super registerPresentersForUpdates.
	BrowserUpdate current register: dictionaryPresenter selector: #dictionaryListUpdate:.
	BrowserUpdate current
		register: dictionaryPresenter
		selector: #aborted:browser:
		browser: self.
	BrowserUpdate current
		register: classListPresenter
		selector: #renamedClass:browser:
		browser: self.
	BrowserUpdate current
		register: classHierarchyPresenter
		selector: #renamedClassInHierarchy:browser:
		browser: self!

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
!JadeiteBrowserPresenter categoriesFor: #comparisonPresenter!accessing!public! !
!JadeiteBrowserPresenter categoriesFor: #contextObject!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #createComponents!initialize/release!public! !
!JadeiteBrowserPresenter categoriesFor: #createListViewFor:!private! !
!JadeiteBrowserPresenter categoriesFor: #createSchematicWiring!create schemantic wiring!public! !
!JadeiteBrowserPresenter categoriesFor: #createSchematicWiringForMethodSource!create schemantic wiring!public! !
!JadeiteBrowserPresenter categoriesFor: #dictionaryMenu!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #dictionaryMenuStrings!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #dictionaryPresenter!accessing!private! !
!JadeiteBrowserPresenter categoriesFor: #displayStringFor:in:!double dispatch!public! !
!JadeiteBrowserPresenter categoriesFor: #displayVariable:!displaying!private! !
!JadeiteBrowserPresenter categoriesFor: #editSaveClass!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #editSaveMethod:!menu handlers support!private! !
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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil 328198 ##(Smalltalk.Point) 2241 1401 517 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 6 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 576 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 nil 5 nil nil nil 576 655878 ##(Smalltalk.CardLayout) 138 144 34 5 721414 ##(Smalltalk.Association) 590662 1 ##(Smalltalk.CardLabel) 8 'SUnit' 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 4 1 832 8 'doIt' 8 '[Icon fromId: ''icons\UnitTestPlugin.ico'']' 8 #[32 105 45 30 178 106] 983558 ##(Smalltalk.VariableBinding) #Icon ##(Smalltalk.Icon) 8 'icons\UnitTestPlugin.ico' #fromId: 848 7 1 nil nil 410 ##(Smalltalk.ReferenceView) 34 14 nil 576 34 2 8 1140850688 131073 992 nil 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 nil nil nil 992 1180166 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteSUnitInClassPresenter) #resource_Default_view nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 482 9 55 482 2225 613 992 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 8 #() 482 193 193 nil 27 754 786 8 'Class Definition' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 576 34 2 8 1445007428 1025 1392 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 1058 26337781 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 11 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #editSave 8 '&Save' 9383 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 1586 1 1618 #editUndo 8 '&Undo' 9397 1 nil nil nil 1586 1 1618 #editRedo 8 '&Redo' 9395 1 nil nil nil 1666 4097 1586 1 1618 #editCut 8 'Cu&t' 9393 1 nil nil nil 1586 1 1618 #editCopy 8 '&Copy' 9351 1 nil nil nil 1586 1 1618 #editPaste 8 '&Paste' 9389 1 nil nil nil 1586 1 1618 #editDelete 8 '&Delete' 1629 1 nil nil nil 1666 4097 1586 1 1618 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 1392 nil 8 4294907885 852486 ##(Smalltalk.NullConverter) nil nil 13 nil 170 192 34 4 #normal 1182790 1 ##(Smalltalk.ScintillaTextStyle) 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 2258 77 786694 ##(Smalltalk.IndexedColor) 33554457 2306 33554471 1 nil nil nil nil #callTip nil nil nil 34 256 2272 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 2288 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1639686 ##(Smalltalk.SmalltalkExpressionStyler) 1 nil nil false 138 144 1312 170 192 34 2 #default 1641542 1 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 1392 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1312 nil 170 176 1312 9215 nil nil nil nil 2306 33554447 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 2272 nil nil nil nil 1 nil 170 192 34 6 1 1510470 2 ##(Smalltalk.ScintillaIndicatorStyle) 1 1392 65025 3 false 1 nil nil nil nil nil nil 3 2722 3 1392 33423361 5 false 3 nil nil nil nil nil nil 5 2722 5 1392 511 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 2258 1029 nil 1058 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 2258 1027 1058 60239 1058 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2258 1031 1058 335 1058 31317503 1 nil nil nil nil #Error nil nil nil nil 1122 138 144 34 8 1186 #createAt:extent: 34 2 482 9 55 482 2225 613 1392 1186 #contextMenu: 34 1 1552 1392 1186 #modificationEventMask: 8 #(4607) 1392 1186 #caretPeriod: 8 #(530) 1392 1186 #wordWrap: 8 #(true) 1392 1186 #margins: 34 1 34 3 985158 2 ##(Smalltalk.ScintillaMargin) 1 1392 1 3 nil nil 5 nil 3234 3 1392 33 nil 3 67108863 5 nil 3234 5 1392 1 nil 3 -67108863 5 nil 1392 1186 #tabWidth: 8 #(4) 1392 1186 #maxCompletionListHeight: 8 #(9) 1392 1266 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1328 nil 29 754 786 8 'Class Documentation' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 576 34 2 8 1445007428 1025 3456 1458 nil false 1504 nil 1058 26337781 nil 5 1538 nil true 34 1 1586 1 1618 #editSaveClassComment 8 'Save' 1025 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 2082 nil true 2114 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 3456 nil 8 4294907885 2194 nil nil 15 nil 170 192 34 4 #normal 2258 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 2258 77 2320 2336 1 nil nil nil nil #callTip nil nil nil 34 256 3776 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3792 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 2450 1 nil nil nil 3456 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1312 nil 170 176 1312 9215 nil nil nil nil 2512 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 3776 nil nil nil nil 1 nil 170 192 34 6 1 2722 1 3456 65025 3 false 1 nil nil nil nil nil nil 3 2722 3 3456 33423361 5 false 3 nil nil nil nil nil nil 5 2722 5 3456 511 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 2258 1029 nil 1058 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 2258 1027 1058 60239 1058 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2258 1031 1058 335 1058 31317503 1 nil nil nil nil #Error nil nil nil nil 1122 138 144 34 8 1186 #createAt:extent: 34 2 482 9 55 482 2225 613 3456 1186 #contextMenu: 34 1 3552 3456 1186 #modificationEventMask: 8 #(4607) 3456 1186 #caretPeriod: 8 #(530) 3456 1186 #wordWrap: 8 #(true) 3456 1186 #margins: 34 1 34 3 3234 1 3456 1 3 nil nil 5 nil 3234 3 3456 33 nil 3 67108863 5 nil 3234 5 3456 1 nil 3 -67108863 5 nil 3456 1186 #tabWidth: 8 #(4) 3456 1186 #maxCompletionListHeight: 8 #(9) 3456 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1328 nil 29 754 786 8 'Method Source' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 576 34 2 8 1445007428 1025 4752 1458 nil false 1504 nil 1058 26337781 nil 5 nil 2082 nil true 2114 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 4752 nil 8 4294907885 2194 nil nil 13 nil 170 192 34 4 #normal 2258 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 2258 77 2320 2336 1 nil nil nil nil #callTip nil nil nil 34 256 4976 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 4992 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 1312 170 192 34 2 #default 2450 1 nil nil nil 4752 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1312 nil 170 176 1312 9215 nil nil nil nil 2512 nil nil 65 nil nil 2528 8 '' 3 170 192 34 2 #container 170 192 34 4 #normal 4976 #callTip 4992 nil nil nil nil 1 nil 170 192 34 12 1 2722 1 4752 65025 3 false 1 nil nil nil nil nil nil 3 2722 3 4752 33423361 5 false 3 nil nil nil nil nil nil 5 2722 5 4752 511 1 false 5 nil nil nil nil nil nil 8 'indicator8' 2722 17 4752 33554447 1 nil nil nil nil nil nil nil nil 8 'indicator9' 2722 19 4752 33554459 13 nil nil nil nil nil nil nil nil 8 'indicator10' 2722 21 4752 33554459 3 nil nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 2258 1029 nil 1058 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 2258 1027 1058 60239 1058 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2258 1031 1058 335 1058 31317503 1 nil nil nil nil #Error nil nil nil nil 1122 138 144 34 8 1186 #createAt:extent: 34 2 482 9 55 482 2225 613 4752 1186 #modificationEventMask: 8 #(4607) 4752 1186 #hoverTime: 8 #(200) 4752 1186 #caretPeriod: 8 #(530) 4752 1186 #wordWrap: 8 #(true) 4752 1186 #margins: 34 1 34 3 3234 1 4752 61 3 nil nil 5 nil 3234 3 4752 1 nil 3 67108863 nil nil 3234 5 4752 1 nil 3 -67108863 nil nil 4752 1186 #tabWidth: 8 #(4) 4752 1186 #maxCompletionListHeight: 8 #(9) 4752 1266 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1328 nil 29 754 8 'Comparison' 410 ##(Smalltalk.ShellView) 34 27 nil 576 34 2 8 1078919168 131073 6048 nil 642 8 4278190080 nil 517 nil nil nil 6048 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 6048 34 2 8 1140850688 131073 6176 nil 1058 26337781 nil 5 1538 nil true 34 5 1586 1 1618 #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 1586 1 1618 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 1586 1 1618 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 1586 1 1618 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 1586 1 1618 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 6176 514 170 176 1312 false 170 192 1312 nil 1122 138 144 34 2 1186 #createAt:extent: 34 2 482 1 1 482 2193 581 6176 1186 #contextMenu: 34 1 6256 6176 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 4 0 0 34 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 6176 34 2 8 1140850688 131073 6784 nil 642 6128 nil 5 nil nil nil 6784 6146 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 6784 34 2 8 1140850945 262145 6880 nil nil nil 5 nil nil nil 6880 nil 8 1663077024 2194 nil nil nil 1122 138 144 34 2 1186 #createAt:extent: 34 2 482 1 541 482 1091 41 6880 1186 #text: 34 1 8 '
' 6880 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 14 1 0 0 33 2 0 0 34 1 0 0] 8 #() 1328 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 6784 34 2 8 1140920580 1025 7184 1458 nil false 1504 nil 1058 26337781 nil 5 nil nil nil 7184 nil 8 4294907885 2194 nil nil 11 nil 170 192 34 12 #indentGuide 2258 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 2258 3 2306 33554445 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 2258 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 2258 77 2320 2336 1 nil nil nil nil #callTip nil nil nil #normal 2258 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 2258 5 nil 1058 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 7424 7360 7440 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 7392 nil nil nil 7344 nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 2450 1 nil nil nil 7184 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1312 nil 170 176 1312 9215 nil nil nil nil 2512 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 7312 nil nil nil nil 1 nil 170 192 34 6 8 'indicator1' 2722 3 7184 33423361 5 false nil nil nil nil nil nil nil 8 'indicator2' 2722 5 7184 511 1 false nil nil nil nil nil nil nil 8 'indicator0' 2722 1 7184 33554459 13 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 2258 1029 nil 1058 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 2258 1027 1058 60239 1058 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2258 1031 1058 335 1058 31317503 1 nil nil nil nil #Error nil nil nil nil 1122 138 144 34 7 1186 #createAt:extent: 34 2 482 1 1 482 1091 541 7184 1186 #modificationEventMask: 8 #(4607) 7184 1186 #caretPeriod: 8 #(530) 7184 1186 #wordWrap: 8 #(true) 7184 1186 #margins: 34 1 34 3 3234 1 7184 49 3 nil nil nil nil 3234 3 7184 1 nil nil 67108863 nil nil 3234 5 7184 1 nil nil nil nil nil 7184 1186 #canHScroll: 8 #(false) 7184 1186 #maxCompletionListHeight: 8 #(9) 7184 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 14 1 0 0] 8 #() 1328 nil 29 170 192 34 4 6880 8 'beforeTitle' 7184 8 'before' nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 1 482 1091 581 6784 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 34 1 0 0] 34 2 7184 6880 1328 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 6176 34 2 8 1140850688 1 8592 nil 1058 66047 nil 517 nil nil nil 8592 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1091 1 482 11 581 8592 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 33 2 0 0 0 0 0 0 38 2 0 0 34 1 0 0] 8 #() 1328 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 6176 34 2 8 1140850688 131073 8832 nil 642 6128 nil 5 nil nil nil 8832 6146 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 8832 34 2 8 1140850945 262145 8928 nil nil nil 5 nil nil nil 8928 nil 8 1663077024 2194 nil nil nil 1122 138 144 34 2 1186 #createAt:extent: 34 2 482 1 541 482 1093 41 8928 1186 #text: 34 1 8 '
' 8928 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 14 1 0 0 34 2 0 0 34 1 0 0] 8 #() 1328 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 8832 34 2 8 1140920580 1025 9232 1458 nil false 1504 nil 1058 26337781 nil 5 nil nil nil 9232 nil 8 4294907885 2194 nil nil 11 nil 170 192 34 12 #indentGuide 2258 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 2258 3 7376 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 2258 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 2258 77 2320 2336 1 nil nil nil nil #callTip nil nil nil #normal 2258 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 2258 5 nil 1058 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 9456 9408 9472 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 9424 nil nil nil 9392 nil nil 7490 7520 170 192 34 2 #default 2450 1 nil nil nil 9232 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1312 nil 170 176 1312 9215 nil nil nil nil 2512 nil nil 65 nil nil nil 7616 3 170 192 34 2 #container 9360 nil nil nil nil 1 nil 170 192 34 6 8 'indicator2' 2722 5 9232 511 1 false nil nil nil nil nil nil nil 8 'indicator0' 2722 1 9232 33554459 13 false nil nil nil nil nil nil nil 8 'indicator1' 2722 3 9232 33423361 5 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 2258 1029 nil 1058 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 2258 1027 1058 60239 1058 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2258 1031 1058 335 1058 31317503 1 nil nil nil nil #Error nil nil nil nil 1122 138 144 34 7 1186 #createAt:extent: 34 2 482 1 1 482 1093 541 9232 1186 #modificationEventMask: 8 #(4607) 9232 1186 #caretPeriod: 8 #(530) 9232 1186 #wordWrap: 8 #(true) 9232 1186 #margins: 34 1 34 3 3234 1 9232 49 3 nil nil nil nil 3234 3 9232 1 nil nil 67108863 nil nil 3234 5 9232 1 nil nil nil nil nil 9232 1186 #canHScroll: 8 #(false) 9232 1186 #maxCompletionListHeight: 8 #(9) 9232 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 34 2 0 0 14 1 0 0] 8 #() 1328 nil 29 170 192 34 4 9232 8 'after' 8928 8 'afterTitle' nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1101 1 482 1093 581 8832 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 38 2 0 0 0 0 0 0 72 4 0 0 34 1 0 0] 34 2 9232 8928 1328 nil 27 1328 nil 27 170 192 34 2 6176 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 1538 nil true 34 4 1586 1 1618 #selectUpper 8 'Select &upper' 1 1 nil nil nil 1586 1 1618 #selectLower 8 'Select &lower' 1 1 nil nil nil 1666 4097 1586 1 1618 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 11973 nil nil 1538 nil true 34 3 1586 1 1618 #character 8 '&Character' 1 1 nil nil nil 1586 1 1618 #word 8 '&Word' 1 1 nil nil nil 1586 1 1618 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 11975 nil nil 1538 nil true 34 1 1586 1 1618 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 11977 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1122 138 144 34 3 1186 #createAt:extent: 34 2 482 9 55 482 2225 613 6048 1186 #text: 34 1 8 'Comparison' 6048 1186 #updateMenuBar 1312 6048 1266 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 34 1 6176 1328 nil 27 3456 170 192 34 10 3456 8 'classDocumentation' 4752 8 'methodSource' 1392 8 'classDefinition' 992 8 'sunit' 6048 8 'comparisonTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 576 34 2 8 1140916736 1 11520 590662 2 ##(Smalltalk.ListModel) 138 144 34 5 1360 3424 4720 800 6032 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) nil nil 1 nil nil nil 11520 nil 8 4294907827 834 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 11696 7 257 nil 834 0 nil 11714 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 11760 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #smallIcons nil nil nil nil nil 1122 138 144 34 3 1186 #createAt:extent: 34 2 482 1 1 482 2241 675 11520 1186 #basicSelectionsByIndex: 34 1 8 #(2) 11520 1186 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 11520 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 8 #() 1328 nil 27 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 685 482 2241 675 576 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 86 1 0 0 96 4 0 0 167 2 0 0] 34 6 1392 3456 4752 992 6048 11520 1328 nil 27 524806 ##(Smalltalk.Fraction) 3 5 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 12272 nil nil nil 5 nil nil nil 12272 514 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 12272 34 2 8 1140850688 131073 12384 nil nil nil 5 nil nil nil 12384 514 170 176 34 6 410 ##(Smalltalk.ContainerView) 34 15 nil 12384 34 2 8 1140850688 131073 12496 nil nil nil 5 nil nil nil 12496 514 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 12496 34 2 8 1409286144 131073 12608 nil 642 8 4278190080 nil 5 nil nil nil 12608 690 138 144 1312 nil 170 192 1312 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 12608 34 2 8 1140916736 1 12752 11586 138 144 1312 nil 11664 nil nil 1 nil nil nil 12752 nil 8 4294907827 834 0 nil 11714 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 12864 7 257 nil 834 0 nil 11714 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 12912 7 257 nil 11824 nil nil nil nil nil #noIcons nil nil nil nil nil 1122 138 144 34 2 1186 #createAt:extent: 34 2 482 1 1 482 511 675 12752 1186 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 12752 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 81 1 0 0] 8 #() 1328 nil 27 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 1 482 511 675 12608 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 81 1 0 0] 34 1 12752 1328 nil 27 3 false 170 192 34 2 12608 8 'packageDictionaryCards' nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 351 1 482 511 675 12496 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 175 0 0 0 0 0 0 0 174 1 0 0 81 1 0 0] 34 1 12608 1328 nil 27 12242 7 11 410 ##(Smalltalk.ContainerView) 34 15 nil 12384 34 2 8 1140850688 131073 13536 nil nil nil 5 nil nil nil 13536 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.PushButton) 34 20 nil 13536 34 2 8 1140858880 1 13664 nil 2512 nil 5 nil nil nil 13664 nil 8 4294901953 1618 #gotoClassDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 625 482 511 51 13664 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 255 0 0 0 81 1 0 0] 8 #() 1328 nil 29 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 13954 #fixedParentRight 1 13954 #fixedParentBottom -49 14000 1 410 ##(Smalltalk.CardContainer) 34 16 nil 13536 34 2 8 1409286144 131073 14016 nil 642 672 nil 5 nil nil nil 14016 690 138 144 34 2 754 786 8 'Classes' 834 0 nil 866 7 1 16 8 'doIt' 8 '(CardLabel text: ''Classes'' iconBlock: [Icon fromId: ''Class.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 784 14176 ##(Smalltalk.Icon) 8 'Class.ico' #fromId: #text:iconBlock: 14192 11 1 nil nil 410 ##(Smalltalk.ListView) 34 30 nil 14016 34 2 8 1409372237 1025 14288 11586 138 144 1312 nil 11664 642 8 4278190080 nil 21 nil nil nil 14288 nil 8 4294905919 459270 ##(Smalltalk.Message) #displayString 8 #() nil 11824 nil nil nil nil nil nil 138 144 34 1 920646 5 ##(Smalltalk.ListViewColumn) 8 '' 487 #left 14434 #displayString 8 #() 14434 #<= 8 #() nil nil 14288 nil 3 nil 834 0 nil 866 5 1 832 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 14624 7 257 nil #report 1312 nil 131169 nil 34 4 nil nil 482 1 1 nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 9 55 482 495 513 14288 1266 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 251 0 0 0 27 1 0 0] 8 #() 1328 nil 27 754 786 8 'Hierarchy' 834 0 nil 866 7 1 16 8 'doIt' 8 '(CardLabel text: ''Hierarchy'' iconBlock: [Icon fromId: ''ClassHierarchyDiagram.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 784 14928 ##(Smalltalk.Icon) 8 'ClassHierarchyDiagram.ico' #fromId: #text:iconBlock: 14944 11 1 nil nil 410 ##(Smalltalk.TreeView) 34 27 nil 14016 34 2 8 1409352231 1025 15040 590918 3 ##(Smalltalk.TreeModel) nil 11664 525062 ##(Smalltalk.TreeNode) nil nil nil 170 192 1312 642 8 4278190080 nil 21 nil nil nil 15040 nil 8 4294906907 834 0 nil 866 2 1 832 8 'doIt' 8 '[:each | each displayString]' 8 #[30 105 226 0 106] #displayString 15232 7 257 nil ##(Smalltalk.IconicListAbstract) 11824 nil 834 0 nil 866 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 15312 7 257 nil 834 0 nil 866 5 1 832 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 15392 7 257 nil nil nil 170 176 1312 17 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 1312 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 9 55 482 495 513 15040 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 251 0 0 0 27 1 0 0] 8 #() 1328 nil 27 15040 170 192 34 4 15040 8 'classHierarchy' 14288 8 'classList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 14016 34 2 8 1140916736 1 15728 11586 138 144 34 2 14160 14912 nil 11664 nil nil 1 nil nil nil 15728 nil 8 4294907827 834 0 nil 11714 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 15856 7 257 nil 834 0 nil 11714 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 15904 7 257 nil 11824 nil nil nil nil nil #smallIcons nil nil nil nil nil 1122 138 144 34 3 1186 #createAt:extent: 34 2 482 1 1 482 511 575 15728 1186 #basicSelectionsByIndex: 34 1 8 #(2) 15728 1186 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 15728 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 31 1 0 0] 8 #() 1328 nil 27 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 1 482 511 575 14016 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 31 1 0 0] 34 3 14288 15040 15728 1328 nil 27 13922 13968 1 13984 1 13954 #fixedParentTop 1 14000 -99 410 ##(Smalltalk.CardContainer) 34 16 nil 13536 34 2 8 1409286144 131073 16384 nil 642 8 4278190080 nil 5 nil nil nil 16384 690 138 144 34 2 754 786 8 'Instance' 834 0 nil 866 7 1 16 8 'doIt' 8 '(CardLabel text: ''Instance'' iconBlock: [Icon fromId: ''Class.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 784 16560 ##(Smalltalk.Icon) 8 'Class.ico' #fromId: #text:iconBlock: 16576 11 1 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 16384 34 2 8 1140850688 131073 16672 nil nil nil 5 nil nil nil 16672 nil 170 192 1312 nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 9 9 482 495 1 16672 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 251 0 0 0 4 0 0 0] 8 #() 1328 nil 27 754 786 8 'Class' 834 0 nil 866 7 1 16 8 'doIt' 8 '(CardLabel text: ''Class'' iconBlock: [Icon fromId: ''Metaclass.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 784 16944 ##(Smalltalk.Icon) 8 'Metaclass.ico' #fromId: #text:iconBlock: 16960 11 1 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 16384 34 2 8 1140850688 131073 17056 nil nil nil 5 nil nil nil 17056 nil 170 192 1312 nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 9 9 482 495 1 17056 1266 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 251 0 0 0 4 0 0 0] 8 #() 1328 nil 27 16672 170 192 34 4 16672 8 'instanceTab' 17056 8 'classTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 16384 34 2 8 1140916738 1 17360 11586 138 144 34 2 16544 16928 nil 11664 nil nil 1 nil nil nil 17360 nil 8 4294907827 834 0 nil 11714 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 17488 7 257 nil 834 0 nil 11714 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 17536 7 257 nil 11824 nil nil nil nil nil #smallIcons nil nil nil nil nil 1122 138 144 34 3 1186 #createAt:extent: 34 2 482 1 1 482 511 51 17360 1186 #basicSelectionsByIndex: 34 1 8 #(1) 17360 1186 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 17360 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 25 0 0 0] 8 #() 1328 nil 27 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 575 482 511 51 16384 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 31 1 0 0 255 0 0 0 56 1 0 0] 34 3 16672 17056 17360 1328 nil 27 13922 13968 1 13984 1 14000 -99 13954 #fixedViewTop 51 170 192 34 6 13664 8 'definedPackageClassText' 14016 8 'classHierarchyTabs' 16384 8 'instanceClassTabs' nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 871 1 482 511 675 13536 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 179 1 0 0 0 0 0 0 178 2 0 0 81 1 0 0] 34 3 14016 16384 13664 1328 nil 27 12242 7 11 410 ##(Smalltalk.ListView) 34 30 nil 12384 34 2 8 1409405261 1025 18272 11586 138 144 1312 nil 11664 642 14400 nil 5 nil nil nil 18272 nil 8 4294905919 14434 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 11824 nil nil nil nil nil nil 138 144 34 1 14514 8 'Column 1' 333 #left 834 0 nil 866 2 1 832 8 'doIt' 8 '[:each | each displayName]' 8 #[30 105 226 0 106] #displayName 18496 7 257 nil ##(Smalltalk.SortedCollection) nil nil 18272 nil 3 834 0 nil 866 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 18576 7 257 nil 834 0 nil 866 3 1 832 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 18656 7 257 nil #report 1312 nil 133217 nil 34 4 nil nil 482 1 1 nil 1122 138 144 34 2 1186 #createAt:extent: 34 2 482 1 1 482 341 675 18272 1186 #text: 34 1 8 'Column 1' 18272 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 170 0 0 0 81 1 0 0] 8 #() 1328 nil 27 12242 5 11 false 170 192 34 2 18272 8 'projectList' nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 1 482 2241 675 12384 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 7 18272 410 ##(Smalltalk.Splitter) 34 12 nil 12384 34 2 8 1140850688 1 19200 nil 642 8 4278190080 nil 517 nil nil nil 19200 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 341 1 482 11 675 19200 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 170 0 0 0 0 0 0 0 175 0 0 0 81 1 0 0] 8 #() 1328 nil 27 12496 410 ##(Smalltalk.Splitter) 34 12 nil 12384 34 2 8 1140850688 1 19456 nil 642 19280 nil 517 nil nil nil 19456 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 861 1 482 11 675 19456 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 174 1 0 0 0 0 0 0 179 1 0 0 81 1 0 0] 8 #() 1328 nil 27 13536 410 ##(Smalltalk.Splitter) 34 12 nil 12384 34 2 8 1140850688 1 19696 nil 642 19280 nil 517 nil nil nil 19696 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1381 1 482 11 675 19696 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 178 2 0 0 0 0 0 0 183 2 0 0 81 1 0 0] 8 #() 1328 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 12384 34 2 8 1140850688 131073 19936 nil nil nil 5 nil nil nil 19936 514 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 19936 34 2 8 1140850688 131073 20048 nil nil nil 5 nil nil nil 20048 13602 170 176 34 6 410 ##(Smalltalk.ListView) 34 30 nil 20048 34 2 8 1409372233 1025 20160 11586 138 144 1312 nil 11664 642 8 4278190080 nil 13 nil nil nil 20160 nil 8 4294905919 14434 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 11824 nil nil nil nil nil nil 138 144 34 2 14514 8 '' 41 #left 1186 #empty 8 #() 16 14434 #<= 8 #() nil nil 20160 834 0 nil 866 2 1 832 8 'doIt' 8 '[:each | each subSuperIcon]' 8 #[30 105 226 0 106] #subSuperIcon 20464 7 257 nil 1 nil nil 14514 8 'Selector' 421 #left 14434 #displayString 20320 ##(Smalltalk.SortedCollection) nil nil 20160 nil 3 nil 834 0 nil 866 5 1 832 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 20592 7 257 nil #report 1312 nil 133221 nil 34 4 nil nil 482 1 1 nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 55 482 469 571 20160 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 27 0 0 0 234 0 0 0 56 1 0 0] 8 #() 1328 nil 27 13922 13968 1 13984 1 16368 55 14000 -49 410 ##(Smalltalk.TextEdit) 34 16 nil 20048 34 2 8 1140916352 1025 20880 nil 642 8 4278190080 nil 5 nil nil nil 20880 nil 8 4294905431 2194 nil nil 3 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 1 482 469 51 20880 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 234 0 0 0 25 0 0 0] 8 #() 1328 nil 27 13922 13968 1 13984 1 16368 1 16368 51 410 ##(Smalltalk.PushButton) 34 20 nil 20048 34 2 8 1140858880 1 21184 nil 642 8 4278190080 nil 5 nil nil nil 21184 nil 8 4294901953 1618 #gotoMethodDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 625 482 469 51 21184 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 234 0 0 0 81 1 0 0] 8 #() 1328 nil 29 13922 13968 1 13984 1 14000 -49 14000 1 170 192 34 6 20160 8 'methodList' 20880 8 'categoryMethodText' 21184 8 'definedPackageMethodText' nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 383 1 482 469 675 20048 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 191 0 0 0 0 0 0 0 169 1 0 0 81 1 0 0] 34 3 20160 21184 20880 1328 nil 27 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 244 63 false 170 192 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 19936 34 2 8 1409286144 131073 21792 nil 642 8 4278190080 nil 5 nil nil nil 21792 690 138 144 34 2 754 8 'Category' 410 ##(Smalltalk.ListView) 34 30 nil 21792 34 2 8 1409372233 1025 21968 11586 138 144 1312 nil 11664 642 20272 nil 21 nil nil nil 21968 nil 8 4294905919 14434 #displayString 8 #() nil 11824 nil nil nil nil nil nil 138 144 34 1 14514 8 'Column 1' 349 #left 14434 #displayString 8 #() ##(Smalltalk.SortedCollection) 834 0 nil 866 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each]' 1779525917 22224 7 257 nil nil 21968 nil 3 nil nil #report 1312 nil 131169 nil 34 4 nil nil 482 1 1 nil 1122 138 144 34 2 1186 #createAt:extent: 34 2 482 9 55 482 357 613 21968 1186 #text: 34 1 8 'Column 1' 21968 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 182 0 0 0 77 1 0 0] 8 #() 1328 nil 27 754 8 'Variables' 410 ##(Smalltalk.ListView) 34 30 nil 21792 34 2 8 1409372233 1025 22560 11586 138 144 1312 nil 11664 642 20272 nil 21 nil nil nil 22560 nil 8 4294905919 14434 #displayString 8 #() nil 11824 nil nil 834 0 nil 866 4 1 832 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 22720 7 257 nil nil nil nil 138 144 34 1 14514 8 'Column 1' 349 #left 14434 #displayString 22704 ##(Smalltalk.SortedCollection) nil nil 22560 nil 3 nil 834 0 nil 866 4 1 832 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 22880 7 257 nil #report 1312 nil 131169 nil 34 4 nil nil 482 1 1 nil 1122 138 144 34 2 1186 #createAt:extent: 34 2 482 9 55 482 357 613 22560 1186 #text: 34 1 8 'Column 1' 22560 1266 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 182 0 0 0 77 1 0 0] 8 #() 1328 nil 27 21968 170 192 34 4 21968 8 'categoryList' 22560 8 'variableList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 21792 34 2 8 1140916736 1 23264 11586 138 144 34 2 21952 22544 nil 11664 nil nil 1 nil nil nil 23264 nil 8 4294907827 834 0 nil 11714 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 23392 7 257 nil 834 0 nil 11714 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 23440 7 257 nil 11824 nil nil nil nil nil #noIcons nil nil nil nil nil 1122 138 144 34 3 1186 #createAt:extent: 34 2 482 1 1 482 373 675 23264 1186 #basicSelectionsByIndex: 34 1 8 #(1) 23264 1186 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 23264 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 186 0 0 0 81 1 0 0] 8 #() 1328 nil 27 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 1 482 373 675 21792 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 186 0 0 0 81 1 0 0] 34 3 21968 22560 23264 1328 nil 27 8 'methodFilterTabs' nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1391 1 482 851 675 19936 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 183 2 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 3 21792 410 ##(Smalltalk.Splitter) 34 12 nil 19936 34 2 8 1140850688 1 24064 nil 642 19280 nil 517 nil nil nil 24064 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 373 1 482 11 675 24064 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 186 0 0 0 0 0 0 0 191 0 0 0 81 1 0 0] 8 #() 1328 nil 27 20048 1328 nil 27 1328 nil 27 7 false 170 192 1312 nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 1 482 2241 675 12272 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 1 12384 1328 nil 27 12242 3 5 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 24496 nil nil 482 2241 43 517 nil nil nil 24496 13602 170 176 34 4 410 ##(Smalltalk.ToolButton) 34 14 nil 24496 34 2 8 1140850688 131073 24624 nil nil nil 1029 nil nil nil 24624 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 24624 34 2 8 1140853580 131137 24688 nil nil 482 43 43 513 nil nil nil 24688 nil 8 4294905879 nil 170 192 34 2 11847 1115910 ##(Smalltalk.ToolbarIconButton) 11847 nil 24688 1 1618 #flipAutoCommit 8 'Auto Commit' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons/camera16_light_icon.ico' nil 395334 3 ##(Smalltalk.Bitmap) nil true nil nil nil nil 3 482 33 33 1 34 1 24832 170 176 34 2 24976 1 nil 3 nil 482 33 33 482 33 33 nil nil 1122 138 144 34 2 1186 #createAt:extent: 34 2 482 1 1 482 43 43 24688 1186 #updateSizePosted 1312 24688 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 8 #() 1328 nil 27 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 1 482 43 43 24624 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 34 1 24688 1328 nil 27 13922 13968 1 13954 #fixedViewLeft 43 16368 1 18000 43 410 ##(Smalltalk.TextEdit) 34 16 nil 24496 34 2 8 1140850688 1 25456 nil 642 8 4278190080 482 2199 43 517 nil 2082 nil true 2114 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 482 193 193 nil 25456 2306 33554433 8 4294905431 2194 nil nil 67 1122 138 144 34 2 1186 #createAt:extent: 34 2 482 43 1 482 2199 43 25456 1186 #setMarginWidths: 34 1 8 #(3 3) 25456 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 21 0 0 0 0 0 0 0 96 4 0 0 21 0 0 0] 8 #() 1328 nil 27 13922 13968 43 13984 1 16368 1 14000 1 170 192 34 4 24624 8 'autoCommitButton' 25456 8 'statusBarField' nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 1359 482 2241 43 24496 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 167 2 0 0 96 4 0 0 188 2 0 0] 34 2 24624 25456 1328 nil 27 21730 8 184 30 133 235 81 184 158 63 true 170 192 34 4 576 8 'textAreaTabs' 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 26192 nil 642 19280 nil 517 nil nil nil 26192 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 1 675 482 2241 11 26192 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 81 1 0 0 96 4 0 0 86 1 0 0] 8 #() 1328 nil 27 8 'splitter' nil 1122 138 144 34 1 1186 #createAt:extent: 34 2 482 7679 21 482 2241 1401 416 1266 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 95 19 0 0 198 2 0 0] 34 4 12272 26192 576 24496 1328 nil 27 )! !
!JadeiteBrowserPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

