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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil 328198 ##(Smalltalk.Point) 2241 1401 517 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 6 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 576 nil nil nil 5 nil nil nil 576 514 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 576 34 2 8 1140850688 131073 688 nil nil nil 5 nil nil nil 688 514 170 176 34 6 410 ##(Smalltalk.ContainerView) 34 15 nil 688 34 2 8 1140850688 131073 800 nil nil nil 5 nil nil nil 800 514 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 800 34 2 8 1409286144 131073 912 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 nil 5 nil nil nil 912 655878 ##(Smalltalk.CardLayout) 138 144 8 #() nil 170 192 1072 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 912 34 2 8 1140916736 1 1104 590662 2 ##(Smalltalk.ListModel) 138 144 1072 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) nil nil 1 nil nil nil 1104 nil 8 4294907827 787814 3 ##(Smalltalk.BlockClosure) 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 1280 7 257 nil 1266 0 nil 1298 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 1344 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #noIcons nil nil nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 482 1 1 482 511 675 1104 1490 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 1104 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 81 1 0 0] 8 #() 482 193 193 nil 27 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 1 1 482 511 675 912 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 81 1 0 0] 34 1 1104 1664 nil 27 3 false 170 192 34 2 912 8 'packageDictionaryCards' nil 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 351 1 482 511 675 800 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 175 0 0 0 0 0 0 0 174 1 0 0 81 1 0 0] 34 1 912 1664 nil 27 524806 ##(Smalltalk.Fraction) 7 11 410 ##(Smalltalk.ListView) 34 30 nil 688 34 2 8 1409405261 1025 2080 1170 138 144 1072 nil 1232 978 8 4278190080 nil 5 nil nil nil 2080 nil 8 4294905919 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.IconicListAbstract) 1408 nil nil nil nil nil nil 138 144 34 1 920646 5 ##(Smalltalk.ListViewColumn) 8 'Column 1' 333 #left 1266 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 1264 8 'doIt' 8 '[:each | each displayName]' 8 #[30 105 226 0 106] #displayName 2352 7 257 nil ##(Smalltalk.SortedCollection) nil nil 2080 nil 3 1266 0 nil 2370 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 2448 7 257 nil 1266 0 nil 2370 3 1 1264 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 2528 7 257 nil #report 1072 nil 133217 nil 34 4 nil nil 482 1 1 nil 1426 138 144 34 2 1490 #createAt:extent: 34 2 482 1 1 482 341 675 2080 1490 #text: 34 1 8 'Column 1' 2080 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 170 0 0 0 81 1 0 0] 8 #() 1664 nil 27 2050 5 11 410 ##(Smalltalk.ContainerView) 34 15 nil 688 34 2 8 1140850688 131073 2864 nil nil nil 5 nil nil nil 2864 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.PushButton) 34 20 nil 2864 34 2 8 1140858880 1 2992 nil 786694 ##(Smalltalk.IndexedColor) 33554447 nil 5 nil nil nil 2992 nil 8 4294901953 1180998 4 ##(Smalltalk.CommandDescription) #gotoClassDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 1 625 482 511 51 2992 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 255 0 0 0 81 1 0 0] 8 #() 1664 nil 29 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 3330 #fixedParentRight 1 3330 #fixedParentBottom -49 3376 1 410 ##(Smalltalk.CardContainer) 34 16 nil 2864 34 2 8 1409286144 131073 3392 nil 978 8 4278190080 nil 5 nil nil nil 3392 1026 138 144 34 2 721414 ##(Smalltalk.Association) 590662 1 ##(Smalltalk.CardLabel) 8 'Classes' 1266 0 nil 2370 7 1 16 8 'doIt' 8 '(CardLabel text: ''Classes'' iconBlock: [Icon fromId: ''Class.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 3568 3600 ##(Smalltalk.Icon) 8 'Class.ico' #fromId: #text:iconBlock: 3616 11 1 nil nil 410 ##(Smalltalk.ListView) 34 30 nil 3392 34 2 8 1409372237 1025 3712 1170 138 144 1072 nil 1232 978 2192 nil 21 nil nil nil 3712 nil 8 4294905919 2226 #displayString 8 #() nil 1408 nil nil nil nil nil nil 138 144 34 1 2306 8 '' 487 #left 2226 #displayString 8 #() 2226 #<= 8 #() nil nil 3712 nil 3 nil 1266 0 nil 2370 5 1 1264 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 4000 7 257 nil #report 1072 nil 131169 nil 34 4 nil nil 482 1 1 nil 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 9 55 482 495 513 3712 1602 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 251 0 0 0 27 1 0 0] 8 #() 1664 nil 27 3538 3570 8 'Hierarchy' 1266 0 nil 2370 7 1 16 8 'doIt' 8 '(CardLabel text: ''Hierarchy'' iconBlock: [Icon fromId: ''ClassHierarchyDiagram.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 3568 4304 ##(Smalltalk.Icon) 8 'ClassHierarchyDiagram.ico' #fromId: #text:iconBlock: 4320 11 1 nil nil 410 ##(Smalltalk.TreeView) 34 27 nil 3392 34 2 8 1409352231 1025 4416 590918 3 ##(Smalltalk.TreeModel) nil 1232 525062 ##(Smalltalk.TreeNode) nil nil nil 170 192 1072 978 8 4278190080 nil 21 nil nil nil 4416 nil 8 4294906907 1266 0 nil 2370 2 1 1264 8 'doIt' 8 '[:each | each displayString]' 8 #[30 105 226 0 106] #displayString 4608 7 257 nil ##(Smalltalk.IconicListAbstract) 1408 nil 1266 0 nil 2370 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 4688 7 257 nil 1266 0 nil 2370 5 1 1264 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 4768 7 257 nil nil nil 170 176 1072 17 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 1072 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 9 55 482 495 513 4416 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 251 0 0 0 27 1 0 0] 8 #() 1664 nil 27 4416 170 192 34 4 3712 8 'classList' 4416 8 'classHierarchy' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 3392 34 2 8 1140916736 1 5104 1170 138 144 34 2 3584 4288 nil 1232 nil nil 1 nil nil nil 5104 nil 8 4294907827 1266 0 nil 1298 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 5232 7 257 nil 1266 0 nil 1298 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 5280 7 257 nil 1408 nil nil nil nil nil #smallIcons nil nil nil nil nil 1426 138 144 34 3 1490 #createAt:extent: 34 2 482 1 1 482 511 575 5104 1490 #basicSelectionsByIndex: 34 1 8 #(2) 5104 1490 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 5104 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 31 1 0 0] 8 #() 1664 nil 27 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 1 1 482 511 575 3392 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 31 1 0 0] 34 3 3712 4416 5104 1664 nil 27 3298 3344 1 3360 1 3330 #fixedParentTop 1 3376 -99 410 ##(Smalltalk.CardContainer) 34 16 nil 2864 34 2 8 1409286144 131073 5760 nil 978 8 4278190080 nil 5 nil nil nil 5760 1026 138 144 34 2 3538 3570 8 'Instance' 1266 0 nil 2370 7 1 16 8 'doIt' 8 '(CardLabel text: ''Instance'' iconBlock: [Icon fromId: ''Class.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 3568 5936 ##(Smalltalk.Icon) 8 'Class.ico' #fromId: #text:iconBlock: 5952 11 1 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 5760 34 2 8 1140850688 131073 6048 nil nil nil 5 nil nil nil 6048 nil 170 192 1072 nil 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 9 9 482 495 1 6048 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 251 0 0 0 4 0 0 0] 8 #() 1664 nil 27 3538 3570 8 'Class' 1266 0 nil 2370 7 1 16 8 'doIt' 8 '(CardLabel text: ''Class'' iconBlock: [Icon fromId: ''Metaclass.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 3568 6320 ##(Smalltalk.Icon) 8 'Metaclass.ico' #fromId: #text:iconBlock: 6336 11 1 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 5760 34 2 8 1140850688 131073 6432 nil nil nil 5 nil nil nil 6432 nil 170 192 1072 nil 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 9 9 482 495 1 6432 1602 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 251 0 0 0 4 0 0 0] 8 #() 1664 nil 27 6048 170 192 34 4 6048 8 'instanceTab' 6432 8 'classTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 5760 34 2 8 1140916738 1 6736 1170 138 144 34 2 5920 6304 nil 1232 nil nil 1 nil nil nil 6736 nil 8 4294907827 1266 0 nil 1298 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 6864 7 257 nil 1266 0 nil 1298 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 6912 7 257 nil 1408 nil nil nil nil nil #smallIcons nil nil nil nil nil 1426 138 144 34 3 1490 #createAt:extent: 34 2 482 1 1 482 511 51 6736 1490 #basicSelectionsByIndex: 34 1 8 #(1) 6736 1490 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 6736 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 25 0 0 0] 8 #() 1664 nil 27 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 1 575 482 511 51 5760 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 31 1 0 0 255 0 0 0 56 1 0 0] 34 3 6048 6432 6736 1664 nil 27 3298 3344 1 3360 1 3376 -99 3330 #fixedViewTop 51 170 192 34 6 2992 8 'definedPackageClassText' 3392 8 'classHierarchyTabs' 5760 8 'instanceClassTabs' nil 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 871 1 482 511 675 2864 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 179 1 0 0 0 0 0 0 178 2 0 0 81 1 0 0] 34 3 3392 5760 2992 1664 nil 27 2050 7 11 false 170 192 34 2 2080 8 'projectList' nil 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 1 1 482 2241 675 688 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 7 2080 410 ##(Smalltalk.Splitter) 34 12 nil 688 34 2 8 1140850688 1 7856 nil 978 8 4278190080 nil 517 nil nil nil 7856 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 341 1 482 11 675 7856 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 170 0 0 0 0 0 0 0 175 0 0 0 81 1 0 0] 8 #() 1664 nil 27 800 410 ##(Smalltalk.Splitter) 34 12 nil 688 34 2 8 1140850688 1 8112 nil 978 7936 nil 517 nil nil nil 8112 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 861 1 482 11 675 8112 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 174 1 0 0 0 0 0 0 179 1 0 0 81 1 0 0] 8 #() 1664 nil 27 2864 410 ##(Smalltalk.Splitter) 34 12 nil 688 34 2 8 1140850688 1 8352 nil 978 7936 nil 517 nil nil nil 8352 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 1381 1 482 11 675 8352 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 178 2 0 0 0 0 0 0 183 2 0 0 81 1 0 0] 8 #() 1664 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 688 34 2 8 1140850688 131073 8592 nil nil nil 5 nil nil nil 8592 514 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 8592 34 2 8 1140850688 131073 8704 nil nil nil 5 nil nil nil 8704 2930 170 176 34 6 410 ##(Smalltalk.PushButton) 34 20 nil 8704 34 2 8 1140858880 1 8816 nil 978 8 4278190080 nil 5 nil nil nil 8816 nil 8 4294901953 3106 #gotoMethodDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 1 625 482 469 51 8816 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 234 0 0 0 81 1 0 0] 8 #() 1664 nil 29 3298 3344 1 3360 1 3376 -49 3376 1 410 ##(Smalltalk.TextEdit) 34 16 nil 8704 34 2 8 1140916352 1025 9120 nil 978 8 4278190080 nil 5 nil nil nil 9120 nil 8 4294905431 852486 ##(Smalltalk.NullConverter) nil nil 3 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 1 1 482 469 51 9120 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 234 0 0 0 25 0 0 0] 8 #() 1664 nil 27 3298 3344 1 3360 1 5744 1 5744 51 410 ##(Smalltalk.ListView) 34 30 nil 8704 34 2 8 1409372233 1025 9440 1170 138 144 1072 nil 1232 978 8 4278190080 nil 13 nil nil nil 9440 nil 8 4294905919 2226 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 1408 nil nil nil nil nil nil 138 144 34 2 2306 8 '' 41 #left 1490 #empty 8 #() 16 2226 #<= 8 #() nil nil 9440 1266 0 nil 2370 2 1 1264 8 'doIt' 8 '[:each | each subSuperIcon]' 8 #[30 105 226 0 106] #subSuperIcon 9744 7 257 nil 1 nil nil 2306 8 'Selector' 421 #left 2226 #displayString 9600 ##(Smalltalk.SortedCollection) nil nil 9440 nil 3 nil 1266 0 nil 2370 5 1 1264 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 9872 7 257 nil #report 1072 nil 133221 nil 34 4 nil nil 482 1 1 nil 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 1 55 482 469 571 9440 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 27 0 0 0 234 0 0 0 56 1 0 0] 8 #() 1664 nil 27 3298 3344 1 3360 1 5744 55 3376 -49 170 192 34 6 8816 8 'definedPackageMethodText' 9120 8 'categoryMethodText' 9440 8 'methodList' nil 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 383 1 482 469 675 8704 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 191 0 0 0 0 0 0 0 169 1 0 0 81 1 0 0] 34 3 9440 8816 9120 1664 nil 27 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 244 63 false 170 192 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 8592 34 2 8 1409286144 131073 10464 nil 978 8 4278190080 nil 5 nil nil nil 10464 1026 138 144 34 2 3538 8 'Category' 410 ##(Smalltalk.ListView) 34 30 nil 10464 34 2 8 1409372233 1025 10640 1170 138 144 1072 nil 1232 978 9552 nil 21 nil nil nil 10640 nil 8 4294905919 2226 #displayString 8 #() nil 1408 nil nil nil nil nil nil 138 144 34 1 2306 8 'Column 1' 349 #left 2226 #displayString 8 #() ##(Smalltalk.SortedCollection) 1266 0 nil 2370 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each]' 1779525917 10896 7 257 nil nil 10640 nil 3 nil nil #report 1072 nil 131169 nil 34 4 nil nil 482 1 1 nil 1426 138 144 34 2 1490 #createAt:extent: 34 2 482 9 55 482 357 613 10640 1490 #text: 34 1 8 'Column 1' 10640 1602 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 182 0 0 0 77 1 0 0] 8 #() 1664 nil 27 3538 8 'Variables' 410 ##(Smalltalk.ListView) 34 30 nil 10464 34 2 8 1409372233 1025 11232 1170 138 144 1072 nil 1232 978 9552 nil 21 nil nil nil 11232 nil 8 4294905919 2226 #displayString 8 #() nil 1408 nil nil 1266 0 nil 2370 4 1 1264 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 11392 7 257 nil nil nil nil 138 144 34 1 2306 8 'Column 1' 349 #left 2226 #displayString 11376 ##(Smalltalk.SortedCollection) nil nil 11232 nil 3 nil 1266 0 nil 2370 4 1 1264 8 'doIt' 8 '[:each | 
each view parentPresenter possiblyBoldVariable: each]' 8 #[32 105 226 0 159 17 178 106] #view #parentPresenter #displayVariable: 11552 7 257 nil #report 1072 nil 131169 nil 34 4 nil nil 482 1 1 nil 1426 138 144 34 2 1490 #createAt:extent: 34 2 482 9 55 482 357 613 11232 1490 #text: 34 1 8 'Column 1' 11232 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 182 0 0 0 77 1 0 0] 8 #() 1664 nil 27 11232 170 192 34 4 10640 8 'categoryList' 11232 8 'variableList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 10464 34 2 8 1140916736 1 11936 1170 138 144 34 2 10624 11216 nil 1232 nil nil 1 nil nil nil 11936 nil 8 4294907827 1266 0 nil 1298 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 12064 7 257 nil 1266 0 nil 1298 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 12112 7 257 nil 1408 nil nil nil nil nil #noIcons nil nil nil nil nil 1426 138 144 34 3 1490 #createAt:extent: 34 2 482 1 1 482 373 675 11936 1490 #basicSelectionsByIndex: 34 1 8 #(2) 11936 1490 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 11936 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 186 0 0 0 81 1 0 0] 8 #() 1664 nil 27 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 1 1 482 373 675 10464 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 186 0 0 0 81 1 0 0] 34 3 10640 11232 11936 1664 nil 27 8 'methodFilterTabs' nil 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 1391 1 482 851 675 8592 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 183 2 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 3 10464 410 ##(Smalltalk.Splitter) 34 12 nil 8592 34 2 8 1140850688 1 12736 nil 978 7936 nil 517 nil nil nil 12736 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 373 1 482 11 675 12736 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 186 0 0 0 0 0 0 0 191 0 0 0 81 1 0 0] 8 #() 1664 nil 27 8704 1664 nil 27 1664 nil 27 7 false 170 192 1072 nil 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 1 1 482 2241 675 576 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 1 688 1664 nil 27 2050 3 5 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 13168 nil nil 482 2241 43 517 nil nil nil 13168 2930 170 176 34 4 410 ##(Smalltalk.ToolButton) 34 14 nil 13168 34 2 8 1140850688 131073 13296 nil nil nil 1029 nil nil nil 13296 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 13296 34 2 8 1140853580 131137 13360 nil nil 482 43 43 513 nil nil nil 13360 nil 8 4294905879 nil 170 192 34 2 26923 1115910 ##(Smalltalk.ToolbarIconButton) 26923 nil 13360 1 3106 #flipAutoCommit 8 'Auto Commit' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons/camera16_light_icon.ico' nil 395334 3 ##(Smalltalk.Bitmap) nil true nil nil nil nil 3 482 33 33 1 34 1 13504 170 176 34 2 13648 1 nil 3 nil 482 33 33 482 33 33 nil nil 1426 138 144 34 2 1490 #createAt:extent: 34 2 482 1 1 482 43 43 13360 1490 #updateSizePosted 1072 13360 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 8 #() 1664 nil 27 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 1 1 482 43 43 13296 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 34 1 13360 1664 nil 27 3298 3344 1 3330 #fixedViewLeft 43 5744 1 7376 43 410 ##(Smalltalk.TextEdit) 34 16 nil 13168 34 2 8 1140850688 1 14128 nil 978 8 4278190080 482 2199 43 517 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 482 193 193 nil 14128 3058 33554433 8 4294905431 9234 nil nil 67 1426 138 144 34 2 1490 #createAt:extent: 34 2 482 43 1 482 2199 43 14128 1490 #setMarginWidths: 34 1 8 #(3 3) 14128 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 21 0 0 0 0 0 0 0 96 4 0 0 21 0 0 0] 8 #() 1664 nil 27 3298 3344 43 3360 1 5744 1 3376 1 170 192 34 4 13296 8 'autoCommitButton' 14128 8 'statusBarField' nil 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 1 1359 482 2241 43 13168 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 167 2 0 0 96 4 0 0 188 2 0 0] 34 2 13296 14128 1664 nil 27 10402 8 184 30 133 235 81 184 158 63 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 14848 nil 978 3472 nil 5 nil nil nil 14848 1026 138 144 34 5 3538 3570 8 'SUnit' 1266 0 nil 2370 4 1 1264 8 'doIt' 8 '[Icon fromId: ''icons\UnitTestPlugin.ico'']' 8 #[32 105 45 30 178 106] 983558 ##(Smalltalk.VariableBinding) #Icon 13552 8 'icons\UnitTestPlugin.ico' #fromId: 15024 7 1 nil nil 410 ##(Smalltalk.ReferenceView) 34 14 nil 14848 34 2 8 1140850688 131073 15152 nil 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 nil nil nil 15152 1180166 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteSUnitInClassPresenter) #resource_Default_view nil 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 9 55 482 2225 613 15152 1602 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 1072 1664 nil 27 3538 3570 8 'Class Definition' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 14848 34 2 8 1445007428 1025 15472 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 15218 26337781 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 11 984134 2 ##(Smalltalk.CommandMenuItem) 1 3106 #editSave 8 '&Save' 9383 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 15666 1 3106 #editUndo 8 '&Undo' 9397 1 nil nil nil 15666 1 3106 #editRedo 8 '&Redo' 9395 1 nil nil nil 15730 4097 15666 1 3106 #editCut 8 'Cu&t' 9393 1 nil nil nil 15666 1 3106 #editCopy 8 '&Copy' 9351 1 nil nil nil 15666 1 3106 #editPaste 8 '&Paste' 9389 1 nil nil nil 15666 1 3106 #editDelete 8 '&Delete' 1629 1 nil nil nil 15730 4097 15666 1 3106 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 14242 nil true 14274 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 15472 nil 8 4294907885 9234 nil nil 13 nil 170 192 34 4 #normal 1182790 1 ##(Smalltalk.ScintillaTextStyle) 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 16274 77 3058 33554457 3058 33554471 1 nil nil nil nil #callTip nil nil nil 34 256 16288 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 16304 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1639686 ##(Smalltalk.SmalltalkExpressionStyler) 1 nil nil false 138 144 1072 170 192 34 2 #default 1641542 1 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 15472 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1072 nil 170 176 1072 9215 nil nil nil nil 3072 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 16288 nil nil nil nil 1 nil 170 192 34 6 1 1510470 2 ##(Smalltalk.ScintillaIndicatorStyle) 1 15472 65025 3 false 1 nil nil nil nil nil nil 3 16706 3 15472 33423361 5 false 3 nil nil nil nil nil nil 5 16706 5 15472 511 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 16274 1029 nil 15218 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 16274 1027 15218 60239 15218 31326207 1 nil nil nil nil #Warning nil nil nil #Error 16274 1031 15218 335 15218 31317503 1 nil nil nil nil #Error nil nil nil nil 1426 138 144 34 8 1490 #createAt:extent: 34 2 482 9 55 482 2225 613 15472 1490 #contextMenu: 34 1 15632 15472 1490 #modificationEventMask: 8 #(4607) 15472 1490 #caretPeriod: 8 #(530) 15472 1490 #wordWrap: 8 #(true) 15472 1490 #margins: 34 1 34 3 985158 2 ##(Smalltalk.ScintillaMargin) 1 15472 1 3 nil nil 5 nil 17218 3 15472 33 nil 3 67108863 5 nil 17218 5 15472 1 nil 3 -67108863 5 nil 15472 1490 #tabWidth: 8 #(4) 15472 1490 #maxCompletionListHeight: 8 #(9) 15472 1602 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1664 nil 29 3538 3570 8 'Class Documentation' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 14848 34 2 8 1445007428 1025 17440 15538 nil false 15584 nil 15218 26337781 nil 5 15618 nil true 34 1 15666 1 3106 #editSaveClassComment 8 'Save' 1025 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 14242 nil true 14274 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 17440 nil 8 4294907885 9234 nil nil 15 nil 170 192 34 4 #normal 16274 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 16274 77 16320 16336 1 nil nil nil nil #callTip nil nil nil 34 256 17760 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 17776 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 16450 1 nil nil nil 17440 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1072 nil 170 176 1072 9215 nil nil nil nil 3072 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 17760 nil nil nil nil 1 nil 170 192 34 6 1 16706 1 17440 65025 3 false 1 nil nil nil nil nil nil 3 16706 3 17440 33423361 5 false 3 nil nil nil nil nil nil 5 16706 5 17440 511 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 16274 1029 nil 15218 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 16274 1027 15218 60239 15218 31326207 1 nil nil nil nil #Warning nil nil nil #Error 16274 1031 15218 335 15218 31317503 1 nil nil nil nil #Error nil nil nil nil 1426 138 144 34 8 1490 #createAt:extent: 34 2 482 9 55 482 2225 613 17440 1490 #contextMenu: 34 1 17536 17440 1490 #modificationEventMask: 8 #(4607) 17440 1490 #caretPeriod: 8 #(530) 17440 1490 #wordWrap: 8 #(true) 17440 1490 #margins: 34 1 34 3 17218 1 17440 1 3 nil nil 5 nil 17218 3 17440 33 nil 3 67108863 5 nil 17218 5 17440 1 nil 3 -67108863 5 nil 17440 1490 #tabWidth: 8 #(4) 17440 1490 #maxCompletionListHeight: 8 #(9) 17440 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1664 nil 29 3538 3570 8 'Method Source' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 14848 34 2 8 1445007428 1025 18736 15538 nil false 15584 nil 15218 26337781 nil 5 nil 14242 nil true 14274 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 18736 nil 8 4294907885 9234 nil nil 13 nil 170 192 34 4 #normal 16274 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 16274 77 16320 16336 1 nil nil nil nil #callTip nil nil nil 34 256 18960 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 18976 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 1072 170 192 34 2 #default 16450 1 nil nil nil 18736 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1072 nil 170 176 1072 9215 nil nil nil nil 3072 nil nil 65 nil nil 16512 8 '' 3 170 192 34 2 #container 170 192 34 4 #normal 18960 #callTip 18976 nil nil nil nil 1 nil 170 192 34 12 1 16706 1 18736 65025 3 false 1 nil nil nil nil nil nil 3 16706 3 18736 33423361 5 false 3 nil nil nil nil nil nil 5 16706 5 18736 511 1 false 5 nil nil nil nil nil nil 8 'indicator9' 16706 19 18736 33554459 13 nil nil nil nil nil nil nil nil 8 'indicator10' 16706 21 18736 33554459 3 nil nil nil nil nil nil nil nil 8 'indicator8' 16706 17 18736 33554447 1 nil nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 16274 1029 nil 15218 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 16274 1027 15218 60239 15218 31326207 1 nil nil nil nil #Warning nil nil nil #Error 16274 1031 15218 335 15218 31317503 1 nil nil nil nil #Error nil nil nil nil 1426 138 144 34 8 1490 #createAt:extent: 34 2 482 9 55 482 2225 613 18736 1490 #modificationEventMask: 8 #(4607) 18736 1490 #hoverTime: 8 #(200) 18736 1490 #caretPeriod: 8 #(530) 18736 1490 #wordWrap: 8 #(true) 18736 1490 #margins: 34 1 34 3 17218 1 18736 61 3 nil nil 5 nil 17218 3 18736 1 nil 3 67108863 nil nil 17218 5 18736 1 nil 3 -67108863 nil nil 18736 1490 #tabWidth: 8 #(4) 18736 1490 #maxCompletionListHeight: 8 #(9) 18736 1602 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1664 nil 29 3538 8 'Comparison' 410 ##(Smalltalk.ShellView) 34 27 nil 14848 34 2 8 1078919168 131073 20032 nil 978 8 4278190080 nil 517 nil nil nil 20032 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 20032 34 2 8 1140850688 131073 20160 nil 15218 26337781 nil 5 15618 nil true 34 5 15666 1 3106 #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 15666 1 3106 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 15666 1 3106 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 15666 1 3106 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 15666 1 3106 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 20160 514 170 176 1072 false 170 192 1072 nil 1426 138 144 34 2 1490 #createAt:extent: 34 2 482 1 1 482 2193 581 20160 1490 #contextMenu: 34 1 20240 20160 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 4 0 0 34 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 20160 34 2 8 1140850688 131073 20768 nil 978 20112 nil 5 nil nil nil 20768 20130 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 20768 34 2 8 1140850945 262145 20864 nil nil nil 5 nil nil nil 20864 nil 8 1663077024 9234 nil nil nil 1426 138 144 34 2 1490 #createAt:extent: 34 2 482 1 541 482 1091 41 20864 1490 #text: 34 1 8 '
' 20864 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 14 1 0 0 33 2 0 0 34 1 0 0] 8 #() 1664 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 20768 34 2 8 1140920580 1025 21168 15538 nil false 15584 nil 15218 26337781 nil 5 nil nil nil 21168 nil 8 4294907885 9234 nil nil 11 nil 170 192 34 12 #indentGuide 16274 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 16274 3 3058 33554445 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 16274 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 16274 77 16320 16336 1 nil nil nil nil #callTip nil nil nil #normal 16274 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 16274 5 nil 15218 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 21408 21344 21424 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 21376 nil nil nil 21328 nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 16450 1 nil nil nil 21168 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1072 nil 170 176 1072 9215 nil nil nil nil 3072 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 21296 nil nil nil nil 1 nil 170 192 34 6 8 'indicator1' 16706 3 21168 33423361 5 false nil nil nil nil nil nil nil 8 'indicator0' 16706 1 21168 33554459 13 false nil nil nil nil nil nil nil 8 'indicator2' 16706 5 21168 511 1 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 16274 1029 nil 15218 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 16274 1027 15218 60239 15218 31326207 1 nil nil nil nil #Warning nil nil nil #Error 16274 1031 15218 335 15218 31317503 1 nil nil nil nil #Error nil nil nil nil 1426 138 144 34 7 1490 #createAt:extent: 34 2 482 1 1 482 1091 541 21168 1490 #modificationEventMask: 8 #(4607) 21168 1490 #caretPeriod: 8 #(530) 21168 1490 #wordWrap: 8 #(true) 21168 1490 #margins: 34 1 34 3 17218 1 21168 49 3 nil nil nil nil 17218 3 21168 1 nil nil 67108863 nil nil 17218 5 21168 1 nil nil nil nil nil 21168 1490 #canHScroll: 8 #(false) 21168 1490 #maxCompletionListHeight: 8 #(9) 21168 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 14 1 0 0] 8 #() 1664 nil 29 170 192 34 4 20864 8 'beforeTitle' 21168 8 'before' nil 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 1 1 482 1091 581 20768 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 34 1 0 0] 34 2 21168 20864 1664 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 20160 34 2 8 1140850688 1 22576 nil 15218 66047 nil 517 nil nil nil 22576 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 1091 1 482 11 581 22576 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 33 2 0 0 0 0 0 0 38 2 0 0 34 1 0 0] 8 #() 1664 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 20160 34 2 8 1140850688 131073 22816 nil 978 20112 nil 5 nil nil nil 22816 20130 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 22816 34 2 8 1140850945 262145 22912 nil nil nil 5 nil nil nil 22912 nil 8 1663077024 9234 nil nil nil 1426 138 144 34 2 1490 #createAt:extent: 34 2 482 1 541 482 1093 41 22912 1490 #text: 34 1 8 '
' 22912 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 14 1 0 0 34 2 0 0 34 1 0 0] 8 #() 1664 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 22816 34 2 8 1140920580 1025 23216 15538 nil false 15584 nil 15218 26337781 nil 5 nil nil nil 23216 nil 8 4294907885 9234 nil nil 11 nil 170 192 34 12 #indentGuide 16274 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 16274 3 21360 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 16274 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 16274 77 16320 16336 1 nil nil nil nil #callTip nil nil nil #normal 16274 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 16274 5 nil 15218 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 23440 23392 23456 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 23408 nil nil nil 23376 nil nil 21474 21504 170 192 34 2 #default 16450 1 nil nil nil 23216 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1072 nil 170 176 1072 9215 nil nil nil nil 3072 nil nil 65 nil nil nil 21600 3 170 192 34 2 #container 23344 nil nil nil nil 1 nil 170 192 34 6 8 'indicator0' 16706 1 23216 33554459 13 false nil nil nil nil nil nil nil 8 'indicator1' 16706 3 23216 33423361 5 false nil nil nil nil nil nil nil 8 'indicator2' 16706 5 23216 511 1 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 16274 1029 nil 15218 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 16274 1027 15218 60239 15218 31326207 1 nil nil nil nil #Warning nil nil nil #Error 16274 1031 15218 335 15218 31317503 1 nil nil nil nil #Error nil nil nil nil 1426 138 144 34 7 1490 #createAt:extent: 34 2 482 1 1 482 1093 541 23216 1490 #modificationEventMask: 8 #(4607) 23216 1490 #caretPeriod: 8 #(530) 23216 1490 #wordWrap: 8 #(true) 23216 1490 #margins: 34 1 34 3 17218 1 23216 49 3 nil nil nil nil 17218 3 23216 1 nil nil 67108863 nil nil 17218 5 23216 1 nil nil nil nil nil 23216 1490 #canHScroll: 8 #(false) 23216 1490 #maxCompletionListHeight: 8 #(9) 23216 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 34 2 0 0 14 1 0 0] 8 #() 1664 nil 29 170 192 34 4 23216 8 'after' 22912 8 'afterTitle' nil 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 1101 1 482 1093 581 22816 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 38 2 0 0 0 0 0 0 72 4 0 0 34 1 0 0] 34 2 23216 22912 1664 nil 27 1664 nil 27 170 192 34 2 20160 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 15618 nil true 34 4 15666 1 3106 #selectUpper 8 'Select &upper' 1 1 nil nil nil 15666 1 3106 #selectLower 8 'Select &lower' 1 1 nil nil nil 15730 4097 15666 1 3106 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 40409 nil nil 15618 nil true 34 3 15666 1 3106 #character 8 '&Character' 1 1 nil nil nil 15666 1 3106 #word 8 '&Word' 1 1 nil nil nil 15666 1 3106 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 40411 nil nil 15618 nil true 34 1 15666 1 3106 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 40413 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1426 138 144 34 3 1490 #createAt:extent: 34 2 482 9 55 482 2225 613 20032 1490 #text: 34 1 8 'Comparison' 20032 1490 #updateMenuBar 1072 20032 1602 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 34 1 20160 1664 nil 27 17440 170 192 34 10 18736 8 'methodSource' 15152 8 'sunit' 15472 8 'classDefinition' 20032 8 'comparisonTab' 17440 8 'classDocumentation' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 14848 34 2 8 1140916736 1 25504 1170 138 144 34 5 15440 17408 18704 14992 20016 nil 1232 nil nil 1 nil nil nil 25504 nil 8 4294907827 1266 0 nil 1298 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 25632 7 257 nil 1266 0 nil 1298 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 25680 7 257 nil 1408 nil nil nil nil nil #smallIcons nil nil nil nil nil 1426 138 144 34 3 1490 #createAt:extent: 34 2 482 1 1 482 2241 675 25504 1490 #basicSelectionsByIndex: 34 1 8 #(2) 25504 1490 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 25504 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 8 #() 1664 nil 27 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 1 685 482 2241 675 14848 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 86 1 0 0 96 4 0 0 167 2 0 0] 34 6 15472 17440 18736 15152 20032 25504 1664 nil 27 2050 3 5 true 170 192 34 4 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 26176 nil 978 7936 nil 517 nil nil nil 26176 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 1 675 482 2241 11 26176 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 81 1 0 0 96 4 0 0 86 1 0 0] 8 #() 1664 nil 27 8 'splitter' 14848 8 'textAreaTabs' nil 1426 138 144 34 1 1490 #createAt:extent: 34 2 482 7679 21 482 2241 1401 416 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 95 19 0 0 198 2 0 0] 34 4 576 26176 14848 13168 1664 nil 27)! !
!JadeiteBrowserPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

