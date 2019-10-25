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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil 328198 ##(Smalltalk.Point) 2241 1401 517 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 6 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 576 nil nil 482 2241 43 517 nil nil nil 576 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil nil 170 192 34 4 410 ##(Smalltalk.TextEdit) 34 16 nil 576 34 2 8 1140850688 1 720 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 482 2199 43 517 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 482 193 193 nil 720 786694 ##(Smalltalk.IndexedColor) 33554433 8 4294905155 852486 ##(Smalltalk.NullConverter) nil nil 67 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 482 43 1 482 2199 43 720 1090 #setMarginWidths: 34 1 8 #(3 3) 720 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 21 0 0 0 0 0 0 0 96 4 0 0 21 0 0 0] 8 #() 482 193 193 nil 27 8 'statusBarField' 410 ##(Smalltalk.ToolButton) 34 14 nil 576 34 2 8 1140850688 131073 1312 nil nil nil 1029 nil nil nil 1312 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 1312 34 2 8 1140853580 131137 1376 nil nil 482 43 43 513 nil nil nil 1376 nil 8 4294904257 nil 170 192 34 2 38533 1115910 ##(Smalltalk.ToolbarIconButton) 38533 nil 1376 1 1180998 4 ##(Smalltalk.CommandDescription) #flipAutoCommit 8 'Auto Commit' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons/camera16_light_icon.ico' nil 395334 3 ##(Smalltalk.Bitmap) nil true nil nil nil nil 3 482 33 33 1 34 1 1520 170 176 34 2 1680 1 nil 3 nil 482 33 33 482 33 33 nil nil 1026 138 144 34 2 1090 #createAt:extent: 34 2 482 1 1 482 43 43 1376 1090 #updateSizePosted 8 #() 1376 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 8 #() 1280 nil 27 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 1 1 482 43 43 1312 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 34 1 1376 1280 nil 27 8 'autoCommitButton' nil 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 1 1359 482 2241 43 576 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 167 2 0 0 96 4 0 0 188 2 0 0] 34 2 1312 720 1280 nil 27 327734 ##(Smalltalk.Float) 8 184 30 133 235 81 184 158 63 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 2352 nil nil nil 5 nil nil nil 2352 514 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 2352 34 2 8 1140850688 131073 2464 nil nil nil 5 nil nil nil 2464 514 170 176 34 6 410 ##(Smalltalk.ContainerView) 34 15 nil 2464 34 2 8 1140850688 131073 2576 nil nil nil 5 nil nil nil 2576 514 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 2576 34 2 8 1409286144 131073 2688 nil 786 8 4278190080 nil 5 nil nil nil 2688 655878 ##(Smalltalk.CardLayout) 138 144 1920 nil 170 192 1920 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 2688 34 2 8 1140916736 1 2848 590662 2 ##(Smalltalk.ListModel) 138 144 1920 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) nil nil 1 nil nil nil 2848 nil 8 4294907401 787814 3 ##(Smalltalk.BlockClosure) 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 3024 7 257 nil 3010 0 nil 3042 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 3088 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #noIcons nil nil nil nil nil 1026 138 144 34 2 1090 #createAt:extent: 34 2 482 1 1 482 511 675 2848 1090 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 2848 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 81 1 0 0] 8 #() 1280 nil 27 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 1 1 482 511 675 2688 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 81 1 0 0] 34 1 2848 1280 nil 27 3 false 170 192 34 2 2688 8 'packageDictionaryCards' nil 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 351 1 482 511 675 2576 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 175 0 0 0 0 0 0 0 174 1 0 0 81 1 0 0] 34 1 2688 1280 nil 27 524806 ##(Smalltalk.Fraction) 7 11 410 ##(Smalltalk.ListView) 34 30 nil 2464 34 2 8 1409405261 1025 3760 2914 138 144 1920 nil 2976 786 8 4278190080 nil 5 nil nil nil 3760 nil 8 4294906459 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.IconicListAbstract) 3152 nil nil nil nil nil nil 138 144 34 1 920646 5 ##(Smalltalk.ListViewColumn) 8 'Column 1' 333 #left 3010 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 3008 8 'doIt' 8 '[:each | each displayName]' 8 #[30 105 226 0 106] #displayName 4032 7 257 nil ##(Smalltalk.SortedCollection) nil nil 3760 nil 3 3010 0 nil 4050 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 4128 7 257 nil 3010 0 nil 4050 3 1 3008 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 4208 7 257 nil #report 1920 nil 133217 nil 34 4 nil nil 482 1 1 nil 1026 138 144 34 2 1090 #createAt:extent: 34 2 482 1 1 482 341 675 3760 1090 #text: 34 1 8 'Column 1' 3760 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 170 0 0 0 81 1 0 0] 8 #() 1280 nil 27 3730 5 11 410 ##(Smalltalk.ContainerView) 34 15 nil 2464 34 2 8 1140850688 131073 4544 nil nil nil 5 nil nil nil 4544 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.CardContainer) 34 16 nil 4544 34 2 8 1409286144 131073 4672 nil 786 8 4278190080 nil 5 nil nil nil 4672 2786 138 144 34 2 721414 ##(Smalltalk.Association) 590662 1 ##(Smalltalk.CardLabel) 8 'Classes' 3010 0 nil 4050 7 1 16 8 'doIt' 8 '(CardLabel text: ''Classes'' iconBlock: [Icon fromId: ''Class.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 4848 4880 1584 8 'Class.ico' #fromId: #text:iconBlock: 4896 11 1 nil nil 410 ##(Smalltalk.ListView) 34 30 nil 4672 34 2 8 1409372237 1025 4992 2914 138 144 1920 nil 2976 786 3872 nil 21 nil nil nil 4992 nil 8 4294906459 3906 #displayString 8 #() nil 3152 nil nil nil nil nil nil 138 144 34 1 3986 8 '' 487 #left 3906 #displayString 8 #() 3906 #<= 8 #() nil nil 4992 nil 3 nil 3010 0 nil 4050 5 1 3008 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 5280 7 257 nil #report 1920 nil 131169 nil 34 4 nil nil 482 1 1 nil 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 9 55 482 495 513 4992 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 251 0 0 0 27 1 0 0] 8 #() 1280 nil 27 4818 4850 8 'Hierarchy' 3010 0 nil 4050 7 1 16 8 'doIt' 8 '(CardLabel text: ''Hierarchy'' iconBlock: [Icon fromId: ''ClassHierarchyDiagram.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 4848 5584 1584 8 'ClassHierarchyDiagram.ico' #fromId: #text:iconBlock: 5600 11 1 nil nil 410 ##(Smalltalk.TreeView) 34 27 nil 4672 34 2 8 1409352231 1025 5696 590918 3 ##(Smalltalk.TreeModel) nil 2976 525062 ##(Smalltalk.TreeNode) nil nil nil 170 192 1920 786 8 4278190080 nil 21 nil nil nil 5696 nil 8 4294905601 3010 0 nil 4050 2 1 3008 8 'doIt' 8 '[:each | each displayString]' 8 #[30 105 226 0 106] #displayString 5888 7 257 nil ##(Smalltalk.IconicListAbstract) 3152 nil 3010 0 nil 4050 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 5968 7 257 nil 3010 0 nil 4050 5 1 3008 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 6048 7 257 nil nil nil 170 176 1920 17 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 1920 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 9 55 482 495 513 5696 1218 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 251 0 0 0 27 1 0 0] 8 #() 1280 nil 27 4992 170 192 34 4 4992 8 'classList' 5696 8 'classHierarchy' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 4672 34 2 8 1140916736 1 6384 2914 138 144 34 2 4864 5568 nil 2976 nil nil 1 nil nil nil 6384 nil 8 4294907401 3010 0 nil 3042 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 6512 7 257 nil 3010 0 nil 3042 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 6560 7 257 nil 3152 nil nil nil nil nil #smallIcons nil nil nil nil nil 1026 138 144 34 3 1090 #createAt:extent: 34 2 482 1 1 482 511 575 6384 1090 #basicSelectionsByIndex: 34 1 8 #(1) 6384 1090 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 6384 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 31 1 0 0] 8 #() 1280 nil 27 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 1 1 482 511 575 4672 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 31 1 0 0] 34 3 4992 5696 6384 1280 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 7042 #fixedParentRight 1 7042 #fixedParentTop 1 7042 #fixedParentBottom -99 410 ##(Smalltalk.CardContainer) 34 16 nil 4544 34 2 8 1409286144 131073 7120 nil 786 8 4278190080 nil 5 nil nil nil 7120 2786 138 144 34 2 4818 4850 8 'Instance' 3010 0 nil 4050 7 1 16 8 'doIt' 8 '(CardLabel text: ''Instance'' iconBlock: [Icon fromId: ''Class.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 4848 7296 1584 8 'Class.ico' #fromId: #text:iconBlock: 7312 11 1 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 7120 34 2 8 1140850688 131073 7408 nil nil nil 5 nil nil nil 7408 nil 170 192 1920 nil 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 9 9 482 495 1 7408 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 251 0 0 0 4 0 0 0] 8 #() 1280 nil 27 4818 4850 8 'Class' 3010 0 nil 4050 7 1 16 8 'doIt' 8 '(CardLabel text: ''Class'' iconBlock: [Icon fromId: ''Metaclass.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 4848 7680 1584 8 'Metaclass.ico' #fromId: #text:iconBlock: 7696 11 1 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 7120 34 2 8 1140850688 131073 7792 nil nil nil 5 nil nil nil 7792 nil 170 192 1920 nil 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 9 9 482 495 1 7792 1218 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 251 0 0 0 4 0 0 0] 8 #() 1280 nil 27 7408 170 192 34 4 7792 8 'classTab' 7408 8 'instanceTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 7120 34 2 8 1140916738 1 8096 2914 138 144 34 2 7280 7664 nil 2976 nil nil 1 nil nil nil 8096 nil 8 4294907401 3010 0 nil 3042 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 8224 7 257 nil 3010 0 nil 3042 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 8272 7 257 nil 3152 nil nil nil nil nil #smallIcons nil nil nil nil nil 1026 138 144 34 3 1090 #createAt:extent: 34 2 482 1 1 482 511 51 8096 1090 #basicSelectionsByIndex: 34 1 8 #(1) 8096 1090 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 8096 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 25 0 0 0] 8 #() 1280 nil 27 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 1 575 482 511 51 7120 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 31 1 0 0 255 0 0 0 56 1 0 0] 34 3 7408 7792 8096 1280 nil 27 7010 7056 1 7072 1 7104 -99 7042 #fixedViewTop 51 410 ##(Smalltalk.PushButton) 34 20 nil 4544 34 2 8 1140858880 1 8752 nil 946 33554447 nil 5 nil nil nil 8752 nil 8 4294905679 1538 #gotoClassDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 1 625 482 511 51 8752 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 255 0 0 0 81 1 0 0] 8 #() 1280 nil 29 7010 7056 1 7072 1 7104 -49 7104 1 170 192 34 6 4672 8 'classHierarchyTabs' 7120 8 'instanceClassTabs' 8752 8 'definedPackageClassText' nil 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 871 1 482 511 675 4544 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 179 1 0 0 0 0 0 0 178 2 0 0 81 1 0 0] 34 3 4672 7120 8752 1280 nil 27 3730 7 11 false 170 192 34 2 3760 8 'projectList' nil 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 1 1 482 2241 675 2464 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 7 3760 410 ##(Smalltalk.Splitter) 34 12 nil 2464 34 2 8 1140850688 1 9504 nil 786 8 4278190080 nil 517 nil nil nil 9504 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 341 1 482 11 675 9504 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 170 0 0 0 0 0 0 0 175 0 0 0 81 1 0 0] 8 #() 1280 nil 27 2576 410 ##(Smalltalk.Splitter) 34 12 nil 2464 34 2 8 1140850688 1 9760 nil 786 9584 nil 517 nil nil nil 9760 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 861 1 482 11 675 9760 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 174 1 0 0 0 0 0 0 179 1 0 0 81 1 0 0] 8 #() 1280 nil 27 4544 410 ##(Smalltalk.Splitter) 34 12 nil 2464 34 2 8 1140850688 1 10000 nil 786 9584 nil 517 nil nil nil 10000 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 1381 1 482 11 675 10000 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 178 2 0 0 0 0 0 0 183 2 0 0 81 1 0 0] 8 #() 1280 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 2464 34 2 8 1140850688 131073 10240 nil nil nil 5 nil nil nil 10240 514 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 10240 34 2 8 1140850688 131073 10352 nil nil nil 5 nil nil nil 10352 4610 170 176 34 6 410 ##(Smalltalk.PushButton) 34 20 nil 10352 34 2 8 1140858880 1 10464 nil 786 8 4278190080 nil 5 nil nil nil 10464 nil 8 4294905679 1538 #gotoMethodDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 1 625 482 469 51 10464 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 234 0 0 0 81 1 0 0] 8 #() 1280 nil 29 7010 7056 1 7072 1 7104 -49 7104 1 410 ##(Smalltalk.TextEdit) 34 16 nil 10352 34 2 8 1140916352 1025 10768 nil 786 8 4278190080 nil 5 nil nil nil 10768 nil 8 4294905155 994 nil nil 3 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 1 1 482 469 51 10768 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 234 0 0 0 25 0 0 0] 8 #() 1280 nil 27 7010 7056 1 7072 1 7088 1 7088 51 410 ##(Smalltalk.ListView) 34 30 nil 10352 34 2 8 1409372233 1025 11072 2914 138 144 1920 nil 2976 786 8 4278190080 nil 13 nil nil nil 11072 nil 8 4294906459 3906 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 3152 nil nil nil nil nil nil 138 144 34 2 3986 8 '' 41 #left 1090 #empty 8 #() 16 3906 #<= 8 #() nil nil 11072 3010 0 nil 4050 2 1 3008 8 'doIt' 8 '[:each | each subSuperIcon]' 8 #[30 105 226 0 106] #subSuperIcon 11376 7 257 nil 1 nil nil 3986 8 'Selector' 421 #left 3906 #displayString 11232 ##(Smalltalk.SortedCollection) nil nil 11072 nil 3 nil 3010 0 nil 4050 5 1 3008 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 11504 7 257 nil #report 1920 nil 133221 nil 34 4 nil nil 482 1 1 nil 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 1 55 482 469 571 11072 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 27 0 0 0 234 0 0 0 56 1 0 0] 8 #() 1280 nil 27 7010 7056 1 7072 1 7088 55 7104 -49 170 192 34 6 10464 8 'definedPackageMethodText' 10768 8 'categoryMethodText' 11072 8 'methodList' nil 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 383 1 482 469 675 10352 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 191 0 0 0 0 0 0 0 169 1 0 0 81 1 0 0] 34 3 11072 10464 10768 1280 nil 27 2322 8 0 0 0 0 0 0 244 63 false 170 192 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 10240 34 2 8 1409286144 131073 12080 nil 786 8 4278190080 nil 5 nil nil nil 12080 2786 138 144 34 2 4818 8 'Category' 410 ##(Smalltalk.ListView) 34 30 nil 12080 34 2 8 1409372233 1025 12256 2914 138 144 1920 nil 2976 786 11184 nil 21 nil nil nil 12256 nil 8 4294906459 3906 #displayString 8 #() nil 3152 nil nil nil nil nil nil 138 144 34 1 3986 8 'Column 1' 349 #left 3906 #displayString 8 #() ##(Smalltalk.SortedCollection) 3010 0 nil 4050 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each]' 1779525917 12512 7 257 nil nil 12256 nil 3 nil nil #report 1920 nil 131169 nil 34 4 nil nil 482 1 1 nil 1026 138 144 34 2 1090 #createAt:extent: 34 2 482 9 55 482 357 613 12256 1090 #text: 34 1 8 'Column 1' 12256 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 182 0 0 0 77 1 0 0] 8 #() 1280 nil 27 4818 8 'Variables' 410 ##(Smalltalk.ListView) 34 30 nil 12080 34 2 8 1409372233 1025 12848 2914 138 144 1920 nil 2976 786 11184 nil 21 nil nil nil 12848 nil 8 4294906459 3906 #displayString 8 #() nil 3152 nil nil nil nil nil nil 138 144 34 1 3986 8 'Column 1' 349 #left 3906 #displayString 12992 ##(Smalltalk.SortedCollection) nil nil 12848 nil 3 nil 3010 0 nil 4050 9 1 3008 8 'doIt' 8 '[:each | each item first = Character space ifTrue: [each font: (each font beBold; beItalic)]]' 8 #[37 105 226 0 159 31 161 132 221 9 17 226 4 100 163 97 164 183 106 60 106] #item #first ##(Smalltalk.Character) #space #font #beBold #beItalic #font: 13088 7 257 nil #report 1920 nil 131169 nil 34 4 nil nil 482 1 1 nil 1026 138 144 34 2 1090 #createAt:extent: 34 2 482 9 55 482 357 613 12848 1090 #text: 34 1 8 'Column 1' 12848 1218 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 182 0 0 0 77 1 0 0] 8 #() 1280 nil 27 12256 170 192 34 4 12848 8 'variableList' 12256 8 'categoryList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 12080 34 2 8 1140916736 1 13472 2914 138 144 34 2 12240 12832 nil 2976 nil nil 1 nil nil nil 13472 nil 8 4294907401 3010 0 nil 3042 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 13600 7 257 nil 3010 0 nil 3042 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 13648 7 257 nil 3152 nil nil nil nil nil #noIcons nil nil nil nil nil 1026 138 144 34 3 1090 #createAt:extent: 34 2 482 1 1 482 373 675 13472 1090 #basicSelectionsByIndex: 34 1 8 #(1) 13472 1090 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 13472 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 186 0 0 0 81 1 0 0] 8 #() 1280 nil 27 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 1 1 482 373 675 12080 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 186 0 0 0 81 1 0 0] 34 3 12256 12848 13472 1280 nil 27 8 'methodFilterTabs' nil 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 1391 1 482 851 675 10240 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 183 2 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 3 12080 410 ##(Smalltalk.Splitter) 34 12 nil 10240 34 2 8 1140850688 1 14272 nil 786 9584 nil 517 nil nil nil 14272 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 373 1 482 11 675 14272 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 186 0 0 0 0 0 0 0 191 0 0 0 81 1 0 0] 8 #() 1280 nil 27 10352 1280 nil 27 1280 nil 27 7 false 170 192 1920 nil 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 1 1 482 2241 675 2352 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 1 2464 1280 nil 27 3730 3 5 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 14704 nil 786 4752 nil 5 nil nil nil 14704 2786 138 144 34 5 4818 4850 8 'SUnit' 3010 0 nil 4050 4 1 3008 8 'doIt' 8 '[Icon fromId: ''icons\UnitTestPlugin.ico'']' 8 #[32 105 45 30 178 106] 983558 ##(Smalltalk.VariableBinding) #Icon 1584 8 'icons\UnitTestPlugin.ico' #fromId: 14880 7 1 nil nil 410 ##(Smalltalk.ReferenceView) 34 14 nil 14704 34 2 8 1140850688 131073 15008 nil 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 nil nil nil 15008 1180166 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteSUnitInClassPresenter) #resource_Default_view nil 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 9 55 482 2225 613 15008 1218 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 1920 1280 nil 27 4818 4850 8 'Class Definition' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 14704 34 2 8 1445007428 1025 15328 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 15074 26337781 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 11 984134 2 ##(Smalltalk.CommandMenuItem) 1 1538 #editSave 8 '&Save' 9383 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 15522 1 1538 #editUndo 8 '&Undo' 9397 1 nil nil nil 15522 1 1538 #editRedo 8 '&Redo' 9395 1 nil nil nil 15586 4097 15522 1 1538 #editCut 8 'Cu&t' 9393 1 nil nil nil 15522 1 1538 #editCopy 8 '&Copy' 9351 1 nil nil nil 15522 1 1538 #editPaste 8 '&Paste' 9389 1 nil nil nil 15522 1 1538 #editDelete 8 '&Delete' 1629 1 nil nil nil 15586 4097 15522 1 1538 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 850 nil true 882 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 15328 nil 8 4294906647 994 nil nil 13 nil 170 192 34 4 #normal 1182790 1 ##(Smalltalk.ScintillaTextStyle) 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 16130 77 946 33554457 946 33554471 1 nil nil nil nil #callTip nil nil nil 34 256 16144 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 16160 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1639686 ##(Smalltalk.SmalltalkExpressionStyler) 1 nil nil false 138 144 1920 170 192 34 2 #default 1641542 1 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 15328 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1920 nil 170 176 1920 9215 nil nil nil nil 8816 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 16144 nil nil nil nil 1 nil 170 192 34 6 1 1510470 2 ##(Smalltalk.ScintillaIndicatorStyle) 1 15328 65025 3 false 1 nil nil nil nil nil nil 3 16562 3 15328 33423361 5 false 3 nil nil nil nil nil nil 5 16562 5 15328 511 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 16130 1029 nil 15074 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 16130 1027 15074 60239 15074 31326207 1 nil nil nil nil #Warning nil nil nil #Error 16130 1031 15074 335 15074 31317503 1 nil nil nil nil #Error nil nil nil nil 1026 138 144 34 8 1090 #createAt:extent: 34 2 482 9 55 482 2225 613 15328 1090 #contextMenu: 34 1 15488 15328 1090 #modificationEventMask: 8 #(4607) 15328 1090 #caretPeriod: 8 #(530) 15328 1090 #wordWrap: 8 #(true) 15328 1090 #margins: 34 1 34 3 985158 2 ##(Smalltalk.ScintillaMargin) 1 15328 1 3 nil nil 5 nil 17074 3 15328 33 nil 3 67108863 5 nil 17074 5 15328 1 nil 3 -67108863 5 nil 15328 1090 #tabWidth: 8 #(4) 15328 1090 #maxCompletionListHeight: 8 #(9) 15328 1218 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1280 nil 29 4818 4850 8 'Class Documentation' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 14704 34 2 8 1445007428 1025 17296 15394 nil false 15440 nil 15074 26337781 nil 5 15474 nil true 34 1 15522 1 1538 #editSaveClassComment 8 'Save' 1025 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 850 nil true 882 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 17296 nil 8 4294906647 994 nil nil 15 nil 170 192 34 4 #normal 16130 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 16130 77 16176 16192 1 nil nil nil nil #callTip nil nil nil 34 256 17616 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 17632 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 16306 1 nil nil nil 17296 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1920 nil 170 176 1920 9215 nil nil nil nil 8816 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 17616 nil nil nil nil 1 nil 170 192 34 6 1 16562 1 17296 65025 3 false 1 nil nil nil nil nil nil 3 16562 3 17296 33423361 5 false 3 nil nil nil nil nil nil 5 16562 5 17296 511 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 16130 1029 nil 15074 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 16130 1027 15074 60239 15074 31326207 1 nil nil nil nil #Warning nil nil nil #Error 16130 1031 15074 335 15074 31317503 1 nil nil nil nil #Error nil nil nil nil 1026 138 144 34 8 1090 #createAt:extent: 34 2 482 9 55 482 2225 613 17296 1090 #contextMenu: 34 1 17392 17296 1090 #modificationEventMask: 8 #(4607) 17296 1090 #caretPeriod: 8 #(530) 17296 1090 #wordWrap: 8 #(true) 17296 1090 #margins: 34 1 34 3 17074 1 17296 1 3 nil nil 5 nil 17074 3 17296 33 nil 3 67108863 5 nil 17074 5 17296 1 nil 3 -67108863 5 nil 17296 1090 #tabWidth: 8 #(4) 17296 1090 #maxCompletionListHeight: 8 #(9) 17296 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1280 nil 29 4818 4850 8 'Method Source' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 14704 34 2 8 1445007428 1025 18592 15394 nil false 15440 nil 15074 26337781 nil 5 nil 850 nil true 882 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 18592 nil 8 4294906647 994 nil nil 13 nil 170 192 34 4 #normal 16130 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 16130 77 16176 16192 1 nil nil nil nil #callTip nil nil nil 34 256 18816 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 18832 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 1920 170 192 34 2 #default 16306 1 nil nil nil 18592 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1920 nil 170 176 1920 9215 nil nil nil nil 8816 nil nil 65 nil nil 16368 8 '' 3 170 192 34 2 #container 170 192 34 4 #normal 18816 #callTip 18832 nil nil nil nil 1 nil 170 192 34 12 1 16562 1 18592 65025 3 false 1 nil nil nil nil nil nil 3 16562 3 18592 33423361 5 false 3 nil nil nil nil nil nil 5 16562 5 18592 511 1 false 5 nil nil nil nil nil nil 8 'indicator10' 16562 21 18592 33554459 3 nil nil nil nil nil nil nil nil 8 'indicator8' 16562 17 18592 33554447 1 nil nil nil nil nil nil nil nil 8 'indicator9' 16562 19 18592 33554459 13 nil nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 16130 1029 nil 15074 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 16130 1027 15074 60239 15074 31326207 1 nil nil nil nil #Warning nil nil nil #Error 16130 1031 15074 335 15074 31317503 1 nil nil nil nil #Error nil nil nil nil 1026 138 144 34 8 1090 #createAt:extent: 34 2 482 9 55 482 2225 613 18592 1090 #modificationEventMask: 8 #(4607) 18592 1090 #hoverTime: 8 #(200) 18592 1090 #caretPeriod: 8 #(530) 18592 1090 #wordWrap: 8 #(true) 18592 1090 #margins: 34 1 34 3 17074 1 18592 61 3 nil nil 5 nil 17074 3 18592 1 nil 3 67108863 nil nil 17074 5 18592 1 nil 3 -67108863 nil nil 18592 1090 #tabWidth: 8 #(4) 18592 1090 #maxCompletionListHeight: 8 #(9) 18592 1218 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1280 nil 29 4818 8 'Comparison' 410 ##(Smalltalk.ShellView) 34 27 nil 14704 34 2 8 1078919168 131073 19888 nil 786 8 4278190080 nil 517 nil nil nil 19888 658 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 19888 34 2 8 1140850688 131073 20000 nil 15074 26337781 nil 5 15474 nil true 34 5 15522 1 1538 #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 15522 1 1538 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 15522 1 1538 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 15522 1 1538 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 15522 1 1538 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 20000 514 170 176 1920 false 170 192 1920 nil 1026 138 144 34 2 1090 #createAt:extent: 34 2 482 1 1 482 2193 581 20000 1090 #contextMenu: 34 1 20080 20000 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 4 0 0 34 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 20000 34 2 8 1140850688 131073 20608 nil 786 19968 nil 5 nil nil nil 20608 658 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 20608 34 2 8 1140850945 262145 20704 nil nil nil 5 nil nil nil 20704 nil 8 1663077024 994 nil nil nil 1026 138 144 34 2 1090 #createAt:extent: 34 2 482 1 541 482 1091 41 20704 1090 #text: 34 1 8 '
' 20704 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 14 1 0 0 33 2 0 0 34 1 0 0] 8 #() 1280 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 20608 34 2 8 1140920580 1025 21008 15394 nil false 15440 nil 15074 26337781 nil 5 nil nil nil 21008 nil 8 4294906647 994 nil nil 11 nil 170 192 34 12 #indentGuide 16130 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 16130 3 946 33554445 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 16130 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 16130 77 16176 16192 1 nil nil nil nil #callTip nil nil nil #normal 16130 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 16130 5 nil 15074 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 21248 21184 21264 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 21216 nil nil nil 21168 nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 16306 1 nil nil nil 21008 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1920 nil 170 176 1920 9215 nil nil nil nil 8816 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 21136 nil nil nil nil 1 nil 170 192 34 6 8 'indicator0' 16562 1 21008 33554459 13 false nil nil nil nil nil nil nil 8 'indicator1' 16562 3 21008 33423361 5 false nil nil nil nil nil nil nil 8 'indicator2' 16562 5 21008 511 1 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 16130 1029 nil 15074 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 16130 1027 15074 60239 15074 31326207 1 nil nil nil nil #Warning nil nil nil #Error 16130 1031 15074 335 15074 31317503 1 nil nil nil nil #Error nil nil nil nil 1026 138 144 34 7 1090 #createAt:extent: 34 2 482 1 1 482 1091 541 21008 1090 #modificationEventMask: 8 #(4607) 21008 1090 #caretPeriod: 8 #(530) 21008 1090 #wordWrap: 8 #(true) 21008 1090 #margins: 34 1 34 3 17074 1 21008 49 3 nil nil nil nil 17074 3 21008 1 nil nil 67108863 nil nil 17074 5 21008 1 nil nil nil nil nil 21008 1090 #canHScroll: 8 #(false) 21008 1090 #maxCompletionListHeight: 8 #(9) 21008 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 14 1 0 0] 8 #() 1280 nil 29 170 192 34 4 21008 8 'before' 20704 8 'beforeTitle' nil 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 1 1 482 1091 581 20608 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 34 1 0 0] 34 2 21008 20704 1280 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 20000 34 2 8 1140850688 1 22416 nil 15074 66047 nil 517 nil nil nil 22416 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 1091 1 482 11 581 22416 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 33 2 0 0 0 0 0 0 38 2 0 0 34 1 0 0] 8 #() 1280 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 20000 34 2 8 1140850688 131073 22656 nil 786 19968 nil 5 nil nil nil 22656 658 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 22656 34 2 8 1140850945 262145 22752 nil nil nil 5 nil nil nil 22752 nil 8 1663077024 994 nil nil nil 1026 138 144 34 2 1090 #createAt:extent: 34 2 482 1 541 482 1093 41 22752 1090 #text: 34 1 8 '
' 22752 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 14 1 0 0 34 2 0 0 34 1 0 0] 8 #() 1280 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 22656 34 2 8 1140920580 1025 23056 15394 nil false 15440 nil 15074 26337781 nil 5 nil nil nil 23056 nil 8 4294906647 994 nil nil 11 nil 170 192 34 12 #indentGuide 16130 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 16130 3 21200 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 16130 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 16130 77 16176 16192 1 nil nil nil nil #callTip nil nil nil #normal 16130 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 16130 5 nil 15074 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 23280 23232 23296 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 23248 nil nil nil 23216 nil nil 21314 21344 170 192 34 2 #default 16306 1 nil nil nil 23056 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1920 nil 170 176 1920 9215 nil nil nil nil 8816 nil nil 65 nil nil nil 21440 3 170 192 34 2 #container 23184 nil nil nil nil 1 nil 170 192 34 6 8 'indicator1' 16562 3 23056 33423361 5 false nil nil nil nil nil nil nil 8 'indicator0' 16562 1 23056 33554459 13 false nil nil nil nil nil nil nil 8 'indicator2' 16562 5 23056 511 1 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 16130 1029 nil 15074 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 16130 1027 15074 60239 15074 31326207 1 nil nil nil nil #Warning nil nil nil #Error 16130 1031 15074 335 15074 31317503 1 nil nil nil nil #Error nil nil nil nil 1026 138 144 34 7 1090 #createAt:extent: 34 2 482 1 1 482 1093 541 23056 1090 #modificationEventMask: 8 #(4607) 23056 1090 #caretPeriod: 8 #(530) 23056 1090 #wordWrap: 8 #(true) 23056 1090 #margins: 34 1 34 3 17074 1 23056 49 3 nil nil nil nil 17074 3 23056 1 nil nil 67108863 nil nil 17074 5 23056 1 nil nil nil nil nil 23056 1090 #canHScroll: 8 #(false) 23056 1090 #maxCompletionListHeight: 8 #(9) 23056 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 34 2 0 0 14 1 0 0] 8 #() 1280 nil 29 170 192 34 4 23056 8 'after' 22752 8 'afterTitle' nil 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 1101 1 482 1093 581 22656 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 38 2 0 0 0 0 0 0 72 4 0 0 34 1 0 0] 34 2 23056 22752 1280 nil 27 1280 nil 27 170 192 34 2 20000 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 15474 nil true 34 4 15522 1 1538 #selectUpper 8 'Select &upper' 1 1 nil nil nil 15522 1 1538 #selectLower 8 'Select &lower' 1 1 nil nil nil 15586 4097 15522 1 1538 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 38571 nil nil 15474 nil true 34 3 15522 1 1538 #character 8 '&Character' 1 1 nil nil nil 15522 1 1538 #word 8 '&Word' 1 1 nil nil nil 15522 1 1538 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 38573 nil nil 15474 nil true 34 1 15522 1 1538 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 38575 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1026 138 144 34 3 1090 #createAt:extent: 34 2 482 9 55 482 2225 613 19888 1090 #text: 34 1 8 'Comparison' 19888 1090 #updateMenuBar 1920 19888 1218 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 34 1 20000 1280 nil 27 17296 170 192 34 10 15328 8 'classDefinition' 15008 8 'sunit' 19888 8 'comparisonTab' 17296 8 'classDocumentation' 18592 8 'methodSource' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 14704 34 2 8 1140916736 1 25344 2914 138 144 34 5 15296 17264 18560 14848 19872 nil 2976 nil nil 1 nil nil nil 25344 nil 8 4294907401 3010 0 nil 3042 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 25472 7 257 nil 3010 0 nil 3042 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 25520 7 257 nil 3152 nil nil nil nil nil #smallIcons nil nil nil nil nil 1026 138 144 34 3 1090 #createAt:extent: 34 2 482 1 1 482 2241 675 25344 1090 #basicSelectionsByIndex: 34 1 8 #(2) 25344 1090 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 25344 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 8 #() 1280 nil 27 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 1 685 482 2241 675 14704 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 86 1 0 0 96 4 0 0 167 2 0 0] 34 6 15328 17296 18592 15008 19888 25344 1280 nil 27 3730 3 5 true 170 192 34 4 14704 8 'textAreaTabs' 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 26032 nil 786 9584 nil 517 nil nil nil 26032 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 1 675 482 2241 11 26032 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 81 1 0 0 96 4 0 0 86 1 0 0] 8 #() 1280 nil 27 8 'splitter' nil 1026 138 144 34 1 1090 #createAt:extent: 34 2 482 7679 21 482 2241 1401 416 1218 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 95 19 0 0 198 2 0 0] 34 4 2352 26032 14704 576 1280 nil 27 )! !
!JadeiteBrowserPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

