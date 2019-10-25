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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil 328198 ##(Smalltalk.Point) 2241 1401 517 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 6 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 576 nil nil 482 2241 43 517 nil nil nil 576 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.ToolButton) 34 14 nil 576 34 2 8 1140850688 131073 720 nil nil nil 1029 nil nil nil 720 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 720 34 2 8 1140853580 131137 784 nil nil 482 43 43 513 nil nil nil 784 nil 8 4294904083 nil 170 192 34 2 23551 1115910 ##(Smalltalk.ToolbarIconButton) 23551 nil 784 1 1180998 4 ##(Smalltalk.CommandDescription) #flipAutoCommit 8 'Auto Commit' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons/camera16_light_icon.ico' nil 395334 3 ##(Smalltalk.Bitmap) nil true nil nil nil nil 3 482 33 33 1 34 1 928 170 176 34 2 1088 1 nil 3 nil 482 33 33 482 33 33 nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 482 1 1 482 43 43 784 1266 #updateSizePosted 8 #() 784 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 8 #() 482 193 193 nil 27 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 1 1 482 43 43 720 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 34 1 784 1440 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 1650 #fixedViewLeft 43 1650 #fixedParentTop 1 1650 #fixedViewTop 43 410 ##(Smalltalk.TextEdit) 34 16 nil 576 34 2 8 1140850688 1 1728 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 482 2199 43 517 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 482 193 193 nil 1728 786694 ##(Smalltalk.IndexedColor) 33554433 8 4294907151 852486 ##(Smalltalk.NullConverter) nil nil 67 1202 138 144 34 2 1266 #createAt:extent: 34 2 482 43 1 482 2199 43 1728 1266 #setMarginWidths: 34 1 8 #(3 3) 1728 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 21 0 0 0 0 0 0 0 96 4 0 0 21 0 0 0] 8 #() 1440 nil 27 1618 1664 43 1650 #fixedParentRight 1 1696 1 1650 #fixedParentBottom 1 170 192 34 4 720 8 'autoCommitButton' 1728 8 'statusBarField' nil 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 1 1359 482 2241 43 576 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 167 2 0 0 96 4 0 0 188 2 0 0] 34 2 720 1728 1440 nil 27 327734 ##(Smalltalk.Float) 8 184 30 133 235 81 184 158 63 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 2544 nil 1794 8 4278190080 nil 5 nil nil nil 2544 655878 ##(Smalltalk.CardLayout) 138 144 34 5 721414 ##(Smalltalk.Association) 590662 1 ##(Smalltalk.CardLabel) 8 'SUnit' 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 4 1 2784 8 'doIt' 8 '[Icon fromId: ''icons\UnitTestPlugin.ico'']' 8 #[32 105 45 30 178 106] 983558 ##(Smalltalk.VariableBinding) #Icon 992 8 'icons\UnitTestPlugin.ico' #fromId: 2800 7 1 nil nil 410 ##(Smalltalk.ReferenceView) 34 14 nil 2544 34 2 8 1140850688 131073 2944 nil 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 nil nil nil 2944 1180166 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteSUnitInClassPresenter) #resource_Default_view nil 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 9 55 482 2225 613 2944 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 1360 1440 nil 27 2706 2738 8 'Class Definition' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 2544 34 2 8 1445007428 1025 3264 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 3010 26337781 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 11 984134 2 ##(Smalltalk.CommandMenuItem) 1 946 #editSave 8 '&Save' 9383 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 3458 1 946 #editUndo 8 '&Undo' 9397 1 nil nil nil 3458 1 946 #editRedo 8 '&Redo' 9395 1 nil nil nil 3522 4097 3458 1 946 #editCut 8 'Cu&t' 9393 1 nil nil nil 3458 1 946 #editCopy 8 '&Copy' 9351 1 nil nil nil 3458 1 946 #editPaste 8 '&Paste' 9389 1 nil nil nil 3458 1 946 #editDelete 8 '&Delete' 1629 1 nil nil nil 3522 4097 3458 1 946 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 1858 nil true 1890 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 3264 nil 8 4294907873 2002 nil nil 13 nil 170 192 34 4 #normal 1182790 1 ##(Smalltalk.ScintillaTextStyle) 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 4066 77 1954 33554457 1954 33554471 1 nil nil nil nil #callTip nil nil nil 34 256 4080 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 4096 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1639686 ##(Smalltalk.SmalltalkExpressionStyler) 1 nil nil false 138 144 1360 170 192 34 2 #default 1641542 1 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 3264 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1360 nil 170 176 1360 9215 nil nil nil nil 1954 33554447 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 4080 nil nil nil nil 1 nil 170 192 34 6 1 1510470 2 ##(Smalltalk.ScintillaIndicatorStyle) 1 3264 65025 3 false 1 nil nil nil nil nil nil 3 4514 3 3264 33423361 5 false 3 nil nil nil nil nil nil 5 4514 5 3264 511 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 4066 1029 nil 3010 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 4066 1027 3010 60239 3010 31326207 1 nil nil nil nil #Warning nil nil nil #Error 4066 1031 3010 335 3010 31317503 1 nil nil nil nil #Error nil nil nil nil 1202 138 144 34 8 1266 #createAt:extent: 34 2 482 9 55 482 2225 613 3264 1266 #contextMenu: 34 1 3424 3264 1266 #modificationEventMask: 8 #(4607) 3264 1266 #caretPeriod: 8 #(530) 3264 1266 #wordWrap: 8 #(true) 3264 1266 #margins: 34 1 34 3 985158 2 ##(Smalltalk.ScintillaMargin) 1 3264 1 3 nil nil 5 nil 5026 3 3264 33 nil 3 67108863 5 nil 5026 5 3264 1 nil 3 -67108863 5 nil 3264 1266 #tabWidth: 8 #(4) 3264 1266 #maxCompletionListHeight: 8 #(9) 3264 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1440 nil 29 2706 2738 8 'Class Documentation' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 2544 34 2 8 1445007428 1025 5248 3330 nil false 3376 nil 3010 26337781 nil 5 3410 nil true 34 1 3458 1 946 #editSaveClassComment 8 'Save' 1025 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 1858 nil true 1890 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 5248 nil 8 4294907873 2002 nil nil 15 nil 170 192 34 4 #normal 4066 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 4066 77 4112 4128 1 nil nil nil nil #callTip nil nil nil 34 256 5568 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 5584 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 4242 1 nil nil nil 5248 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1360 nil 170 176 1360 9215 nil nil nil nil 4304 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 5568 nil nil nil nil 1 nil 170 192 34 6 1 4514 1 5248 65025 3 false 1 nil nil nil nil nil nil 3 4514 3 5248 33423361 5 false 3 nil nil nil nil nil nil 5 4514 5 5248 511 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 4066 1029 nil 3010 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 4066 1027 3010 60239 3010 31326207 1 nil nil nil nil #Warning nil nil nil #Error 4066 1031 3010 335 3010 31317503 1 nil nil nil nil #Error nil nil nil nil 1202 138 144 34 8 1266 #createAt:extent: 34 2 482 9 55 482 2225 613 5248 1266 #contextMenu: 34 1 5344 5248 1266 #modificationEventMask: 8 #(4607) 5248 1266 #caretPeriod: 8 #(530) 5248 1266 #wordWrap: 8 #(true) 5248 1266 #margins: 34 1 34 3 5026 1 5248 1 3 nil nil 5 nil 5026 3 5248 33 nil 3 67108863 5 nil 5026 5 5248 1 nil 3 -67108863 5 nil 5248 1266 #tabWidth: 8 #(4) 5248 1266 #maxCompletionListHeight: 8 #(9) 5248 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1440 nil 29 2706 2738 8 'Method Source' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 2544 34 2 8 1445007428 1025 6544 3330 nil false 3376 nil 3010 26337781 nil 5 nil 1858 nil true 1890 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 482 193 193 nil 6544 nil 8 4294907873 2002 nil nil 13 nil 170 192 34 4 #normal 4066 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 4066 77 4112 4128 1 nil nil nil nil #callTip nil nil nil 34 256 6768 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 6784 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 1360 170 192 34 2 #default 4242 1 nil nil nil 6544 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1360 nil 170 176 1360 9215 nil nil nil nil 4304 nil nil 65 nil nil 4320 8 '' 3 170 192 34 2 #container 170 192 34 4 #normal 6768 #callTip 6784 nil nil nil nil 1 nil 170 192 34 12 1 4514 1 6544 65025 3 false 1 nil nil nil nil nil nil 3 4514 3 6544 33423361 5 false 3 nil nil nil nil nil nil 5 4514 5 6544 511 1 false 5 nil nil nil nil nil nil 8 'indicator10' 4514 21 6544 33554459 3 nil nil nil nil nil nil nil nil 8 'indicator8' 4514 17 6544 33554447 1 nil nil nil nil nil nil nil nil 8 'indicator9' 4514 19 6544 33554459 13 nil nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 4066 1029 nil 3010 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 4066 1027 3010 60239 3010 31326207 1 nil nil nil nil #Warning nil nil nil #Error 4066 1031 3010 335 3010 31317503 1 nil nil nil nil #Error nil nil nil nil 1202 138 144 34 8 1266 #createAt:extent: 34 2 482 9 55 482 2225 613 6544 1266 #modificationEventMask: 8 #(4607) 6544 1266 #hoverTime: 8 #(200) 6544 1266 #caretPeriod: 8 #(530) 6544 1266 #wordWrap: 8 #(true) 6544 1266 #margins: 34 1 34 3 5026 1 6544 61 3 nil nil 5 nil 5026 3 6544 1 nil 3 67108863 nil nil 5026 5 6544 1 nil 3 -67108863 nil nil 6544 1266 #tabWidth: 8 #(4) 6544 1266 #maxCompletionListHeight: 8 #(9) 6544 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1440 nil 29 2706 8 'Comparison' 410 ##(Smalltalk.ShellView) 34 27 nil 2544 34 2 8 1078919168 131073 7840 nil 1794 8 4278190080 nil 517 nil nil nil 7840 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 7840 34 2 8 1140850688 131073 7968 nil 3010 26337781 nil 5 3410 nil true 34 5 3458 1 946 #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 3458 1 946 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 3458 1 946 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 3458 1 946 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 3458 1 946 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 7968 514 170 176 1360 false 170 192 1360 nil 1202 138 144 34 2 1266 #createAt:extent: 34 2 482 1 1 482 2193 581 7968 1266 #contextMenu: 34 1 8048 7968 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 4 0 0 34 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 7968 34 2 8 1140850688 131073 8576 nil 1794 7920 nil 5 nil nil nil 8576 7938 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 8576 34 2 8 1140850945 262145 8672 nil nil nil 5 nil nil nil 8672 nil 8 1663077024 2002 nil nil nil 1202 138 144 34 2 1266 #createAt:extent: 34 2 482 1 541 482 1091 41 8672 1266 #text: 34 1 8 '
' 8672 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 14 1 0 0 33 2 0 0 34 1 0 0] 8 #() 1440 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 8576 34 2 8 1140920580 1025 8976 3330 nil false 3376 nil 3010 26337781 nil 5 nil nil nil 8976 nil 8 4294907873 2002 nil nil 11 nil 170 192 34 12 #indentGuide 4066 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 4066 3 1954 33554445 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 4066 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 4066 77 4112 4128 1 nil nil nil nil #callTip nil nil nil #normal 4066 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 4066 5 nil 3010 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 9216 9152 9232 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 9184 nil nil nil 9136 nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 4242 1 nil nil nil 8976 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1360 nil 170 176 1360 9215 nil nil nil nil 4304 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 9104 nil nil nil nil 1 nil 170 192 34 6 8 'indicator2' 4514 5 8976 511 1 false nil nil nil nil nil nil nil 8 'indicator1' 4514 3 8976 33423361 5 false nil nil nil nil nil nil nil 8 'indicator0' 4514 1 8976 33554459 13 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 4066 1029 nil 3010 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 4066 1027 3010 60239 3010 31326207 1 nil nil nil nil #Warning nil nil nil #Error 4066 1031 3010 335 3010 31317503 1 nil nil nil nil #Error nil nil nil nil 1202 138 144 34 7 1266 #createAt:extent: 34 2 482 1 1 482 1091 541 8976 1266 #modificationEventMask: 8 #(4607) 8976 1266 #caretPeriod: 8 #(530) 8976 1266 #wordWrap: 8 #(true) 8976 1266 #margins: 34 1 34 3 5026 1 8976 49 3 nil nil nil nil 5026 3 8976 1 nil nil 67108863 nil nil 5026 5 8976 1 nil nil nil nil nil 8976 1266 #canHScroll: 8 #(false) 8976 1266 #maxCompletionListHeight: 8 #(9) 8976 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 14 1 0 0] 8 #() 1440 nil 29 170 192 34 4 8976 8 'before' 8672 8 'beforeTitle' nil 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 1 1 482 1091 581 8576 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 34 1 0 0] 34 2 8976 8672 1440 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 7968 34 2 8 1140850688 1 10384 nil 3010 66047 nil 517 nil nil nil 10384 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 1091 1 482 11 581 10384 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 33 2 0 0 0 0 0 0 38 2 0 0 34 1 0 0] 8 #() 1440 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 7968 34 2 8 1140850688 131073 10624 nil 1794 7920 nil 5 nil nil nil 10624 7938 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 10624 34 2 8 1140850945 262145 10720 nil nil nil 5 nil nil nil 10720 nil 8 1663077024 2002 nil nil nil 1202 138 144 34 2 1266 #createAt:extent: 34 2 482 1 541 482 1093 41 10720 1266 #text: 34 1 8 '
' 10720 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 14 1 0 0 34 2 0 0 34 1 0 0] 8 #() 1440 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 10624 34 2 8 1140920580 1025 11024 3330 nil false 3376 nil 3010 26337781 nil 5 nil nil nil 11024 nil 8 4294907873 2002 nil nil 11 nil 170 192 34 12 #indentGuide 4066 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 4066 3 9168 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 4066 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 4066 77 4112 4128 1 nil nil nil nil #callTip nil nil nil #normal 4066 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 4066 5 nil 3010 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 11248 11200 11264 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 11216 nil nil nil 11184 nil nil 9282 9312 170 192 34 2 #default 4242 1 nil nil nil 11024 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1360 nil 170 176 1360 9215 nil nil nil nil 4304 nil nil 65 nil nil nil 9408 3 170 192 34 2 #container 11152 nil nil nil nil 1 nil 170 192 34 6 8 'indicator2' 4514 5 11024 511 1 false nil nil nil nil nil nil nil 8 'indicator1' 4514 3 11024 33423361 5 false nil nil nil nil nil nil nil 8 'indicator0' 4514 1 11024 33554459 13 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 4066 1029 nil 3010 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 4066 1027 3010 60239 3010 31326207 1 nil nil nil nil #Warning nil nil nil #Error 4066 1031 3010 335 3010 31317503 1 nil nil nil nil #Error nil nil nil nil 1202 138 144 34 7 1266 #createAt:extent: 34 2 482 1 1 482 1093 541 11024 1266 #modificationEventMask: 8 #(4607) 11024 1266 #caretPeriod: 8 #(530) 11024 1266 #wordWrap: 8 #(true) 11024 1266 #margins: 34 1 34 3 5026 1 11024 49 3 nil nil nil nil 5026 3 11024 1 nil nil 67108863 nil nil 5026 5 11024 1 nil nil nil nil nil 11024 1266 #canHScroll: 8 #(false) 11024 1266 #maxCompletionListHeight: 8 #(9) 11024 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 34 2 0 0 14 1 0 0] 8 #() 1440 nil 29 170 192 34 4 11024 8 'after' 10720 8 'afterTitle' nil 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 1101 1 482 1093 581 10624 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 38 2 0 0 0 0 0 0 72 4 0 0 34 1 0 0] 34 2 11024 10720 1440 nil 27 1440 nil 27 170 192 34 2 7968 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 3410 nil true 34 4 3458 1 946 #selectUpper 8 'Select &upper' 1 1 nil nil nil 3458 1 946 #selectLower 8 'Select &lower' 1 1 nil nil nil 3522 4097 3458 1 946 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 23767 nil nil 3410 nil true 34 3 3458 1 946 #character 8 '&Character' 1 1 nil nil nil 3458 1 946 #word 8 '&Word' 1 1 nil nil nil 3458 1 946 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 23769 nil nil 3410 nil true 34 1 3458 1 946 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 23771 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1202 138 144 34 3 1266 #createAt:extent: 34 2 482 9 55 482 2225 613 7840 1266 #text: 34 1 8 'Comparison' 7840 1266 #updateMenuBar 1360 7840 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 34 1 7968 1440 nil 27 5248 170 192 34 10 6544 8 'methodSource' 3264 8 'classDefinition' 2944 8 'sunit' 5248 8 'classDocumentation' 7840 8 'comparisonTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 2544 34 2 8 1140916736 1 13312 590662 2 ##(Smalltalk.ListModel) 138 144 34 5 3232 5216 6512 2752 7824 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) nil nil 1 nil nil nil 13312 nil 8 4294903921 2786 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 13488 7 257 nil 2786 0 nil 13506 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 13552 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #smallIcons nil nil nil nil nil 1202 138 144 34 3 1266 #createAt:extent: 34 2 482 1 1 482 2241 675 13312 1266 #basicSelectionsByIndex: 34 1 8 #(2) 13312 1266 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 13312 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 8 #() 1440 nil 27 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 1 685 482 2241 675 2544 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 86 1 0 0 96 4 0 0 167 2 0 0] 34 6 3264 5248 6544 2944 7840 13312 1440 nil 27 524806 ##(Smalltalk.Fraction) 3 5 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 14064 nil nil nil 5 nil nil nil 14064 514 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 14064 34 2 8 1140850688 131073 14176 nil nil nil 5 nil nil nil 14176 514 170 176 34 6 410 ##(Smalltalk.ListView) 34 30 nil 14176 34 2 8 1409405261 1025 14288 13378 138 144 1360 nil 13456 1794 8 4278190080 nil 5 nil nil nil 14288 nil 8 4294907471 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.IconicListAbstract) 13616 nil nil nil nil nil nil 138 144 34 1 920646 5 ##(Smalltalk.ListViewColumn) 8 'Column 1' 333 #left 2786 0 nil 2818 2 1 2784 8 'doIt' 8 '[:each | each displayName]' 8 #[30 105 226 0 106] #displayName 14560 7 257 nil ##(Smalltalk.SortedCollection) nil nil 14288 nil 3 2786 0 nil 2818 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 14640 7 257 nil 2786 0 nil 2818 3 1 2784 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 14720 7 257 nil #report 1360 nil 133217 nil 34 4 nil nil 482 1 1 nil 1202 138 144 34 2 1266 #createAt:extent: 34 2 482 1 1 482 341 675 14288 1266 #text: 34 1 8 'Column 1' 14288 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 170 0 0 0 81 1 0 0] 8 #() 1440 nil 27 14034 5 11 410 ##(Smalltalk.ContainerView) 34 15 nil 14176 34 2 8 1140850688 131073 15056 nil nil nil 5 nil nil nil 15056 658 170 176 34 6 410 ##(Smalltalk.PushButton) 34 20 nil 15056 34 2 8 1140858880 1 15168 nil 4304 nil 5 nil nil nil 15168 nil 8 4294907755 946 #gotoClassDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 1 625 482 511 51 15168 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 255 0 0 0 81 1 0 0] 8 #() 1440 nil 29 1618 1664 1 2256 1 2272 -49 2272 1 410 ##(Smalltalk.CardContainer) 34 16 nil 15056 34 2 8 1409286144 131073 15440 nil 1794 2624 nil 5 nil nil nil 15440 2642 138 144 34 2 2706 2738 8 'Classes' 2786 0 nil 2818 7 1 16 8 'doIt' 8 '(CardLabel text: ''Classes'' iconBlock: [Icon fromId: ''Class.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 2736 15600 992 8 'Class.ico' #fromId: #text:iconBlock: 15616 11 1 nil nil 410 ##(Smalltalk.ListView) 34 30 nil 15440 34 2 8 1409372237 1025 15712 13378 138 144 1360 nil 13456 1794 14400 nil 21 nil nil nil 15712 nil 8 4294907471 14434 #displayString 8 #() nil 13616 nil nil nil nil nil nil 138 144 34 1 14514 8 '' 487 #left 14434 #displayString 8 #() 14434 #<= 8 #() nil nil 15712 nil 3 nil 2786 0 nil 2818 5 1 2784 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 16000 7 257 nil #report 1360 nil 131169 nil 34 4 nil nil 482 1 1 nil 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 9 55 482 495 513 15712 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 251 0 0 0 27 1 0 0] 8 #() 1440 nil 27 2706 2738 8 'Hierarchy' 2786 0 nil 2818 7 1 16 8 'doIt' 8 '(CardLabel text: ''Hierarchy'' iconBlock: [Icon fromId: ''ClassHierarchyDiagram.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 2736 16304 992 8 'ClassHierarchyDiagram.ico' #fromId: #text:iconBlock: 16320 11 1 nil nil 410 ##(Smalltalk.TreeView) 34 27 nil 15440 34 2 8 1409352231 1025 16416 590918 3 ##(Smalltalk.TreeModel) nil 13456 525062 ##(Smalltalk.TreeNode) nil nil nil 170 192 1360 1794 8 4278190080 nil 21 nil nil nil 16416 nil 8 4294904201 2786 0 nil 2818 2 1 2784 8 'doIt' 8 '[:each | each displayString]' 8 #[30 105 226 0 106] #displayString 16608 7 257 nil ##(Smalltalk.IconicListAbstract) 13616 nil 2786 0 nil 2818 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 16688 7 257 nil 2786 0 nil 2818 5 1 2784 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 16768 7 257 nil nil nil 170 176 1360 17 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 1360 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 9 55 482 495 513 16416 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 251 0 0 0 27 1 0 0] 8 #() 1440 nil 27 15712 170 192 34 4 16416 8 'classHierarchy' 15712 8 'classList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 15440 34 2 8 1140916736 1 17104 13378 138 144 34 2 15584 16288 nil 13456 nil nil 1 nil nil nil 17104 nil 8 4294903921 2786 0 nil 13506 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 17232 7 257 nil 2786 0 nil 13506 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 17280 7 257 nil 13616 nil nil nil nil nil #smallIcons nil nil nil nil nil 1202 138 144 34 3 1266 #createAt:extent: 34 2 482 1 1 482 511 575 17104 1266 #basicSelectionsByIndex: 34 1 8 #(1) 17104 1266 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 17104 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 31 1 0 0] 8 #() 1440 nil 27 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 1 1 482 511 575 15440 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 31 1 0 0] 34 3 15712 16416 17104 1440 nil 27 1618 1664 1 2256 1 1696 1 2272 -99 410 ##(Smalltalk.CardContainer) 34 16 nil 15056 34 2 8 1409286144 131073 17744 nil 1794 8 4278190080 nil 5 nil nil nil 17744 2642 138 144 34 2 2706 2738 8 'Instance' 2786 0 nil 2818 7 1 16 8 'doIt' 8 '(CardLabel text: ''Instance'' iconBlock: [Icon fromId: ''Class.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 2736 17920 992 8 'Class.ico' #fromId: #text:iconBlock: 17936 11 1 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 17744 34 2 8 1140850688 131073 18032 nil nil nil 5 nil nil nil 18032 nil 170 192 1360 nil 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 9 9 482 495 1 18032 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 251 0 0 0 4 0 0 0] 8 #() 1440 nil 27 2706 2738 8 'Class' 2786 0 nil 2818 7 1 16 8 'doIt' 8 '(CardLabel text: ''Class'' iconBlock: [Icon fromId: ''Metaclass.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 2736 18304 992 8 'Metaclass.ico' #fromId: #text:iconBlock: 18320 11 1 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 17744 34 2 8 1140850688 131073 18416 nil nil nil 5 nil nil nil 18416 nil 170 192 1360 nil 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 9 9 482 495 1 18416 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 251 0 0 0 4 0 0 0] 8 #() 1440 nil 27 18032 170 192 34 4 18416 8 'classTab' 18032 8 'instanceTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 17744 34 2 8 1140916738 1 18720 13378 138 144 34 2 17904 18288 nil 13456 nil nil 1 nil nil nil 18720 nil 8 4294903921 2786 0 nil 13506 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 18848 7 257 nil 2786 0 nil 13506 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 18896 7 257 nil 13616 nil nil nil nil nil #smallIcons nil nil nil nil nil 1202 138 144 34 3 1266 #createAt:extent: 34 2 482 1 1 482 511 51 18720 1266 #basicSelectionsByIndex: 34 1 8 #(1) 18720 1266 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 18720 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 25 0 0 0] 8 #() 1440 nil 27 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 1 575 482 511 51 17744 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 31 1 0 0 255 0 0 0 56 1 0 0] 34 3 18032 18416 18720 1440 nil 27 1618 1664 1 2256 1 2272 -99 1712 51 170 192 34 6 15168 8 'definedPackageClassText' 15440 8 'classHierarchyTabs' 17744 8 'instanceClassTabs' nil 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 871 1 482 511 675 15056 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 179 1 0 0 0 0 0 0 178 2 0 0 81 1 0 0] 34 3 15440 17744 15168 1440 nil 27 14034 7 11 410 ##(Smalltalk.ContainerView) 34 15 nil 14176 34 2 8 1140850688 131073 19616 nil nil nil 5 nil nil nil 19616 514 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 19616 34 2 8 1409286144 131073 19728 nil 1794 8 4278190080 nil 5 nil nil nil 19728 2642 138 144 1360 nil 170 192 1360 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 19728 34 2 8 1140916736 1 19872 13378 138 144 1360 nil 13456 nil nil 1 nil nil nil 19872 nil 8 4294903921 2786 0 nil 13506 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 19984 7 257 nil 2786 0 nil 13506 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 20032 7 257 nil 13616 nil nil nil nil nil #noIcons nil nil nil nil nil 1202 138 144 34 2 1266 #createAt:extent: 34 2 482 1 1 482 511 675 19872 1266 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 19872 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 81 1 0 0] 8 #() 1440 nil 27 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 1 1 482 511 675 19728 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 81 1 0 0] 34 1 19872 1440 nil 27 3 false 170 192 34 2 19728 8 'packageDictionaryCards' nil 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 351 1 482 511 675 19616 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 175 0 0 0 0 0 0 0 174 1 0 0 81 1 0 0] 34 1 19728 1440 nil 27 14034 7 11 false 170 192 34 2 14288 8 'projectList' nil 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 1 1 482 2241 675 14176 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 7 14288 410 ##(Smalltalk.Splitter) 34 12 nil 14176 34 2 8 1140850688 1 20864 nil 1794 8 4278190080 nil 517 nil nil nil 20864 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 341 1 482 11 675 20864 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 170 0 0 0 0 0 0 0 175 0 0 0 81 1 0 0] 8 #() 1440 nil 27 19616 410 ##(Smalltalk.Splitter) 34 12 nil 14176 34 2 8 1140850688 1 21120 nil 1794 20944 nil 517 nil nil nil 21120 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 861 1 482 11 675 21120 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 174 1 0 0 0 0 0 0 179 1 0 0 81 1 0 0] 8 #() 1440 nil 27 15056 410 ##(Smalltalk.Splitter) 34 12 nil 14176 34 2 8 1140850688 1 21360 nil 1794 20944 nil 517 nil nil nil 21360 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 1381 1 482 11 675 21360 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 178 2 0 0 0 0 0 0 183 2 0 0 81 1 0 0] 8 #() 1440 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 14176 34 2 8 1140850688 131073 21600 nil nil nil 5 nil nil nil 21600 514 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 21600 34 2 8 1140850688 131073 21712 nil nil nil 5 nil nil nil 21712 658 170 176 34 6 410 ##(Smalltalk.TextEdit) 34 16 nil 21712 34 2 8 1140916352 1025 21824 nil 1794 8 4278190080 nil 5 nil nil nil 21824 nil 8 4294907151 2002 nil nil 3 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 1 1 482 469 51 21824 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 234 0 0 0 25 0 0 0] 8 #() 1440 nil 27 1618 1664 1 2256 1 1696 1 1696 51 410 ##(Smalltalk.ListView) 34 30 nil 21712 34 2 8 1409372233 1025 22128 13378 138 144 1360 nil 13456 1794 8 4278190080 nil 13 nil nil nil 22128 nil 8 4294907471 14434 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 13616 nil nil nil nil nil nil 138 144 34 2 14514 8 '' 41 #left 1266 #empty 8 #() 16 14434 #<= 8 #() nil nil 22128 2786 0 nil 2818 2 1 2784 8 'doIt' 8 '[:each | each subSuperIcon]' 8 #[30 105 226 0 106] #subSuperIcon 22432 7 257 nil 1 nil nil 14514 8 'Selector' 421 #left 14434 #displayString 22288 ##(Smalltalk.SortedCollection) nil nil 22128 nil 3 nil 2786 0 nil 2818 5 1 2784 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 22560 7 257 nil #report 1360 nil 133221 nil 34 4 nil nil 482 1 1 nil 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 1 55 482 469 571 22128 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 27 0 0 0 234 0 0 0 56 1 0 0] 8 #() 1440 nil 27 1618 1664 1 2256 1 1696 55 2272 -49 410 ##(Smalltalk.PushButton) 34 20 nil 21712 34 2 8 1140858880 1 22848 nil 1794 8 4278190080 nil 5 nil nil nil 22848 nil 8 4294907755 946 #gotoMethodDefinedPackageViaButton nil 1 1 nil nil false nil nil nil 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 1 625 482 469 51 22848 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 234 0 0 0 81 1 0 0] 8 #() 1440 nil 29 1618 1664 1 2256 1 2272 -49 2272 1 170 192 34 6 21824 8 'categoryMethodText' 22128 8 'methodList' 22848 8 'definedPackageMethodText' nil 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 383 1 482 469 675 21712 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 191 0 0 0 0 0 0 0 169 1 0 0 81 1 0 0] 34 3 22128 22848 21824 1440 nil 27 2514 8 0 0 0 0 0 0 244 63 false 170 192 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 21600 34 2 8 1409286144 131073 23440 nil 1794 8 4278190080 nil 5 nil nil nil 23440 2642 138 144 34 2 2706 8 'Category' 410 ##(Smalltalk.ListView) 34 30 nil 23440 34 2 8 1409372233 1025 23616 13378 138 144 1360 nil 13456 1794 22240 nil 21 nil nil nil 23616 nil 8 4294907471 14434 #displayString 8 #() nil 13616 nil nil nil nil nil nil 138 144 34 1 14514 8 'Column 1' 349 #left 14434 #displayString 8 #() ##(Smalltalk.SortedCollection) 2786 0 nil 2818 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each]' 1779525917 23872 7 257 nil nil 23616 nil 3 nil nil #report 1360 nil 131169 nil 34 4 nil nil 482 1 1 nil 1202 138 144 34 2 1266 #createAt:extent: 34 2 482 9 55 482 357 613 23616 1266 #text: 34 1 8 'Column 1' 23616 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 182 0 0 0 77 1 0 0] 8 #() 1440 nil 27 2706 8 'Variables' 410 ##(Smalltalk.ListView) 34 30 nil 23440 34 2 8 1409372233 1025 24208 13378 138 144 1360 nil 13456 1794 22240 nil 21 nil nil nil 24208 nil 8 4294907471 14434 #displayString 8 #() nil 13616 nil nil nil nil nil nil 138 144 34 1 14514 8 'Column 1' 349 #left 14434 #displayString 24352 ##(Smalltalk.SortedCollection) nil nil 24208 nil 3 nil 2786 0 nil 2818 9 1 2784 8 'doIt' 8 '[:each | each item first = Character space ifTrue: [each font: (each font beBold; beItalic)]]' 8 #[37 105 226 0 159 31 161 132 221 9 17 226 4 100 163 97 164 183 106 60 106] #item #first ##(Smalltalk.Character) #space #font #beBold #beItalic #font: 24448 7 257 nil #report 1360 nil 131169 nil 34 4 nil nil 482 1 1 nil 1202 138 144 34 2 1266 #createAt:extent: 34 2 482 9 55 482 357 613 24208 1266 #text: 34 1 8 'Column 1' 24208 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 182 0 0 0 77 1 0 0] 8 #() 1440 nil 27 23616 170 192 34 4 23616 8 'categoryList' 24208 8 'variableList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 23440 34 2 8 1140916736 1 24832 13378 138 144 34 2 23600 24192 nil 13456 nil nil 1 nil nil nil 24832 nil 8 4294903921 2786 0 nil 13506 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 24960 7 257 nil 2786 0 nil 13506 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 25008 7 257 nil 13616 nil nil nil nil nil #noIcons nil nil nil nil nil 1202 138 144 34 3 1266 #createAt:extent: 34 2 482 1 1 482 373 675 24832 1266 #basicSelectionsByIndex: 34 1 8 #(1) 24832 1266 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 24832 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 186 0 0 0 81 1 0 0] 8 #() 1440 nil 27 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 1 1 482 373 675 23440 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 186 0 0 0 81 1 0 0] 34 3 23616 24208 24832 1440 nil 27 8 'methodFilterTabs' nil 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 1391 1 482 851 675 21600 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 183 2 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 3 23440 410 ##(Smalltalk.Splitter) 34 12 nil 21600 34 2 8 1140850688 1 25632 nil 1794 20944 nil 517 nil nil nil 25632 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 373 1 482 11 675 25632 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 186 0 0 0 0 0 0 0 191 0 0 0 81 1 0 0] 8 #() 1440 nil 27 21712 1440 nil 27 1440 nil 27 7 false 170 192 1360 nil 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 1 1 482 2241 675 14064 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 1 14176 1440 nil 27 14034 3 5 true 170 192 34 4 2544 8 'textAreaTabs' 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 26112 nil 1794 20944 nil 517 nil nil nil 26112 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 1 675 482 2241 11 26112 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 81 1 0 0 96 4 0 0 86 1 0 0] 8 #() 1440 nil 27 8 'splitter' nil 1202 138 144 34 1 1266 #createAt:extent: 34 2 482 7679 21 482 2241 1401 416 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 95 19 0 0 198 2 0 0] 34 4 14064 26112 2544 576 1440 nil 27 )! !
!JadeiteBrowserPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

