"Filed out from Dolphin Smalltalk 7"!

JadeiteProjectsBrowserPresenter subclass: #JadeiteBrowserPresenter
	instanceVariableNames: 'dictionaryPresenter packageDictionaryCards globalsTab autoCommitButton'
	classVariableNames: ''
	poolDictionaries: ''
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

basicProjectTabLabel
	| label |
	projectListPresenter selections isEmpty ifTrue: [^'Projects'].
	self isNoneProjectSelected ifFalse: [^super basicProjectTabLabel].
	label := projectListPresenter selection name.
	dictionaryPresenter list isEmpty ifTrue: [^label].
	dictionaryPresenter selections isEmpty ifTrue: [^label].
	dictionaryPresenter selections size > 1 ifTrue: [^label].
	^dictionaryPresenter selection name!

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

browseGlobalClass
	| selection |
	selection := globalsTab selectionIfNone: [^self].
	^self openBrowserInNewTab: false on: (RowanClassService new name: (selection at: 2))!

browseGlobalReferences
	| selection string |
	selection := globalsTab selectionIfNone: [^self].
	string := self selectedGlobalName: selection.
	^JadePresenter browseSymbolReferencesTo: '#' , string session: gciSession!

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
			globalsTabView backcolor: JadeTextStyles default colorForNoEdits.
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
			projectInfoView backcolor: JadeTextStyles default colorForNoEdits.
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
	classCommentPresenter value = self selectedClass comment
		ifTrue: 
			[classCommentPresenter view
				backcolor: JadeTextStyles default colorForNoEdits;
				isModified: false;
				yourself]
		ifFalse: 
			[classCommentPresenter view
				backcolor: JadeTextStyles default colorForUnsavedEdits;
				isModified: true;
				yourself]!

comparisonPresenter

	^comparisonPresenter!

createComponents
	super createComponents.
	dictionaryPresenter := self add: ListPresenter new name: 'dictionariesList'.
	packageDictionaryCards := self add: Presenter new name: 'packageDictionaryCards'.
	autoCommitButton := self add: Presenter new name: 'autoCommitButton'. !

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
		to: self!

createSchematicWiringForMethodSource

	super createSchematicWiringForMethodSource.
	methodSourcePresenter  		
		when: #'textChanged'				send: #'methodValueChanged'	to: self
!

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

insertCompileErrorText: string into: presenter
	"parameters ignored in this presenter"

	statusBarText value: string!

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
			[aCommandQuery isEnabled: self methodListPresenter selections size = 1.
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
	^super queryCommand: aCommandQuery!

reformatSource
	methodListPresenter selection
		source: methodSourcePresenter value;
		command: #reformatSource;
		commandArgs: Array new.
	[self issueCommand: (Array with: methodListPresenter selection)] on: Error
		do: 
			[:ex |
			self setCompileErrorColor.
			self statusBarText: 'Reformat failed. Illegal source'. 
			^false].
	methodSourcePresenter value: methodListPresenter selection source.
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
	self sunitPresenter methodListPresenter view selectAll. 
	self sunitPresenter runAll!

runSelected
	^self runMethodTests. !

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

setCompileErrorColor
	statusBarText view backcolor: Color red faded!

setCompileWarningColor
	statusBarText view backcolor: Color yellow faded!

setStatusBarDefault
	statusBarText view backcolor: statusBarText view defaultBackcolor!

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
	self updateSystemTab.
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
	projectInfoTab list: array contents! !
!JadeiteBrowserPresenter categoriesFor: #addDictionary!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #addNoneProject!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #allSelectedProjectsDirty!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #basicAddDictionaryNamed:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #basicProjectTabLabel!private!tabs! !
!JadeiteBrowserPresenter categoriesFor: #basicRemoveClass:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #basicRemoveDictionaries:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #basicRemoveGlobal:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #basicUnloadProjects:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #browseGlobalClass!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #browseGlobalReferences!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #buildGlobalsTab!private!tabs! !
!JadeiteBrowserPresenter categoriesFor: #buildProjectTab!private!tabs! !
!JadeiteBrowserPresenter categoriesFor: #classCommentChanged!event handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #comparisonPresenter!accessing!public! !
!JadeiteBrowserPresenter categoriesFor: #createComponents!initialize/release!public! !
!JadeiteBrowserPresenter categoriesFor: #createListViewFor:!private! !
!JadeiteBrowserPresenter categoriesFor: #createSchematicWiring!create schemantic wiring!public! !
!JadeiteBrowserPresenter categoriesFor: #createSchematicWiringForMethodSource!create schemantic wiring!public! !
!JadeiteBrowserPresenter categoriesFor: #dictionaryMenu!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #dictionaryMenuStrings!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #dictionaryPresenter!accessing!private! !
!JadeiteBrowserPresenter categoriesFor: #displayStringFor:in:!double dispatch!public! !
!JadeiteBrowserPresenter categoriesFor: #editSaveMethod:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #globalsMenu!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #globalsMenuStrings!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #globalsTab!accessing!private! !
!JadeiteBrowserPresenter categoriesFor: #insertCompileErrorText:into:!compile support!public! !
!JadeiteBrowserPresenter categoriesFor: #inspectGlobal!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #isNoneProjectSelected!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #isProjectItemEnabled:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #isRowanProjectSelected!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #noClassSelectedInEitherPresenter!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #onViewOpened!event handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #openCommitInGitHub!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #packageDictionaryCards!accessing!private! !
!JadeiteBrowserPresenter categoriesFor: #projectInfoMenu!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #projectInfoMenuStrings!menus!public! !
!JadeiteBrowserPresenter categoriesFor: #protectedDictionaries!constants!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #queryCommand:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #reformatSource!menu handlers!public! !
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
!JadeiteBrowserPresenter categoriesFor: #selectedDictionaryNames!public!selection! !
!JadeiteBrowserPresenter categoriesFor: #selectedGlobalName:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #selectedPackageNames!public!selection! !
!JadeiteBrowserPresenter categoriesFor: #selectedPackageServices!public!selection! !
!JadeiteBrowserPresenter categoriesFor: #selectNoneProject!public!selection! !
!JadeiteBrowserPresenter categoriesFor: #setCompileErrorColor!compile support!public! !
!JadeiteBrowserPresenter categoriesFor: #setCompileWarningColor!compile support!public! !
!JadeiteBrowserPresenter categoriesFor: #setStatusBarDefault!compile support!public! !
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

!JadeiteBrowserPresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil nil 5 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 6 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 544 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 nil 5 nil nil nil 544 655878 ##(Smalltalk.CardLayout) 138 144 34 5 721414 ##(Smalltalk.Association) 590662 1 ##(Smalltalk.CardLabel) 8 'SUnit' 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 4 1 800 8 'doIt' 8 '[Icon fromId: ''icons\UnitTestPlugin.ico'']' 8 #[32 105 45 30 178 106] 983558 ##(Smalltalk.VariableBinding) #Icon ##(Smalltalk.Icon) 8 'icons\UnitTestPlugin.ico' #fromId: 816 7 1 nil nil 410 ##(Smalltalk.ReferenceView) 34 14 nil 544 34 2 8 1140850688 131073 960 nil 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 nil nil nil 960 1180166 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteSUnitInClassPresenter) #resource_Default_view nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 328198 ##(Smalltalk.Point) 9 55 1202 2225 613 960 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1202 193 193 nil 27 722 754 8 'Class Definition' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 544 34 2 8 1445007428 1025 1376 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 1026 26337781 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 11 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #editSave 8 '&Save' 9383 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 1570 1 1602 #editUndo 8 '&Undo' 9397 1 nil nil nil 1570 1 1602 #editRedo 8 '&Redo' 9395 1 nil nil nil 1650 4097 1570 1 1602 #editCut 8 'Cu&t' 9393 1 nil nil nil 1570 1 1602 #editCopy 8 '&Copy' 9351 1 nil nil nil 1570 1 1602 #editPaste 8 '&Paste' 9389 1 nil nil nil 1570 1 1602 #editDelete 8 '&Delete' 1629 1 nil nil nil 1650 4097 1570 1 1602 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 1202 193 193 nil 1376 nil 8 4294902163 852486 ##(Smalltalk.NullConverter) nil nil 13 nil 170 192 34 4 #normal 1182790 1 ##(Smalltalk.ScintillaTextStyle) 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 2242 77 786694 ##(Smalltalk.IndexedColor) 33554457 2290 33554471 1 nil nil nil nil #callTip nil nil nil 34 256 2256 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 2272 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1639686 ##(Smalltalk.SmalltalkExpressionStyler) 1 nil nil false 138 144 1296 170 192 34 2 #default 1641542 1 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 1376 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1296 nil 170 176 1296 9215 nil nil nil nil 2290 33554447 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 2256 nil nil nil nil 1 nil 170 192 34 6 1 1510470 2 ##(Smalltalk.ScintillaIndicatorStyle) 1 1376 65025 3 false 1 nil nil nil nil nil nil 3 2706 3 1376 33423361 5 false 3 nil nil nil nil nil nil 5 2706 5 1376 511 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 2242 1029 nil 1026 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 2242 1027 1026 60239 1026 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2242 1031 1026 335 1026 31317503 1 nil nil nil nil #Error nil nil nil nil 1090 138 144 34 8 1154 #createAt:extent: 34 2 1202 9 55 1202 2225 613 1376 1154 #contextMenu: 34 1 1536 1376 1154 #modificationEventMask: 8 #(4607) 1376 1154 #caretPeriod: 8 #(530) 1376 1154 #wordWrap: 8 #(true) 1376 1154 #margins: 34 1 34 3 985158 2 ##(Smalltalk.ScintillaMargin) 1 1376 1 3 nil nil 5 nil 3218 3 1376 33 nil 3 67108863 5 nil 3218 5 1376 1 nil 3 -67108863 5 nil 1376 1154 #tabWidth: 8 #(4) 1376 1154 #maxCompletionListHeight: 8 #(9) 1376 1250 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1312 nil 29 722 754 8 'Class Documentation' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 544 34 2 8 1445007428 1025 3440 1442 nil false 1488 nil 1026 26337781 nil 5 1522 nil true 34 1 1570 1 1602 #editSaveClassComment 8 'Save' 1025 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 2066 nil true 2098 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 1202 193 193 nil 3440 nil 8 4294902163 2178 nil nil 15 nil 170 192 34 4 #normal 2242 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 2242 77 2304 2320 1 nil nil nil nil #callTip nil nil nil 34 256 3760 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3776 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 2434 1 nil nil nil 3440 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1296 nil 170 176 1296 9215 nil nil nil nil 2496 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 3760 nil nil nil nil 1 nil 170 192 34 6 1 2706 1 3440 65025 3 false 1 nil nil nil nil nil nil 3 2706 3 3440 33423361 5 false 3 nil nil nil nil nil nil 5 2706 5 3440 511 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 2242 1029 nil 1026 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 2242 1027 1026 60239 1026 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2242 1031 1026 335 1026 31317503 1 nil nil nil nil #Error nil nil nil nil 1090 138 144 34 8 1154 #createAt:extent: 34 2 1202 9 55 1202 2225 613 3440 1154 #contextMenu: 34 1 3536 3440 1154 #modificationEventMask: 8 #(4607) 3440 1154 #caretPeriod: 8 #(530) 3440 1154 #wordWrap: 8 #(true) 3440 1154 #margins: 34 1 34 3 3218 1 3440 1 3 nil nil 5 nil 3218 3 3440 33 nil 3 67108863 5 nil 3218 5 3440 1 nil 3 -67108863 5 nil 3440 1154 #tabWidth: 8 #(4) 3440 1154 #maxCompletionListHeight: 8 #(9) 3440 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1312 nil 29 722 754 8 'Method Source' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 544 34 2 8 1445007428 1025 4736 1442 nil false 1488 nil 1026 26337781 nil 5 nil 2066 nil true 2098 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 1202 193 193 nil 4736 nil 8 4294902163 2178 nil nil 13 nil 170 192 34 4 #normal 2242 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 2242 77 2304 2320 1 nil nil nil nil #callTip nil nil nil 34 256 4960 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 4976 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 1296 170 192 34 2 #default 2434 1 nil nil nil 4736 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1296 nil 170 176 1296 9215 nil nil nil nil 2496 nil nil 65 nil nil 2512 8 '' 3 170 192 34 2 #container 170 192 34 4 #normal 4960 #callTip 4976 nil nil nil nil 1 nil 170 192 34 12 1 2706 1 4736 65025 3 false 1 nil nil nil nil nil nil 3 2706 3 4736 33423361 5 false 3 nil nil nil nil nil nil 5 2706 5 4736 511 1 false 5 nil nil nil nil nil nil 8 'indicator9' 2706 19 4736 33554459 13 nil nil nil nil nil nil nil nil 8 'indicator10' 2706 21 4736 33554459 3 nil nil nil nil nil nil nil nil 8 'indicator8' 2706 17 4736 33554447 1 nil nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 2242 1029 nil 1026 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 2242 1027 1026 60239 1026 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2242 1031 1026 335 1026 31317503 1 nil nil nil nil #Error nil nil nil nil 1090 138 144 34 8 1154 #createAt:extent: 34 2 1202 9 55 1202 2225 613 4736 1154 #modificationEventMask: 8 #(4607) 4736 1154 #hoverTime: 8 #(200) 4736 1154 #caretPeriod: 8 #(530) 4736 1154 #wordWrap: 8 #(true) 4736 1154 #margins: 34 1 34 3 3218 1 4736 61 3 nil nil 5 nil 3218 3 4736 1 nil 3 67108863 nil nil 3218 5 4736 1 nil 3 -67108863 nil nil 4736 1154 #tabWidth: 8 #(4) 4736 1154 #maxCompletionListHeight: 8 #(9) 4736 1250 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1312 nil 29 722 8 'Comparison' 410 ##(Smalltalk.ShellView) 34 27 nil 544 34 2 8 1078919168 131073 6032 nil 610 8 4278190080 nil 517 nil nil nil 6032 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 6032 34 2 8 1140850688 131073 6160 nil 1026 26337781 nil 5 1522 nil true 34 5 1570 1 1602 #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 1570 1 1602 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 1570 1 1602 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 1570 1 1602 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 1570 1 1602 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 6160 482 170 176 1296 false 170 192 1296 nil 1090 138 144 34 2 1154 #createAt:extent: 34 2 1202 1 1 1202 2193 581 6160 1154 #contextMenu: 34 1 6240 6160 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 4 0 0 34 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 6160 34 2 8 1140850688 131073 6768 nil 610 6112 nil 5 nil nil nil 6768 6130 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 6768 34 2 8 1140850945 262145 6864 nil nil nil 5 nil nil nil 6864 nil 8 1817086624 2178 nil nil nil 1090 138 144 34 2 1154 #createAt:extent: 34 2 1202 1 541 1202 1091 41 6864 1154 #text: 34 1 8 '
' 6864 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 14 1 0 0 33 2 0 0 34 1 0 0] 8 #() 1312 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 6768 34 2 8 1140920580 1025 7168 1442 nil false 1488 nil 1026 26337781 nil 5 nil nil nil 7168 nil 8 4294902163 2178 nil nil 11 nil 170 192 34 12 #indentGuide 2242 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 2242 3 2290 33554445 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 2242 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 2242 77 2304 2320 1 nil nil nil nil #callTip nil nil nil #normal 2242 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 2242 5 nil 1026 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 7408 7344 7424 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 7376 nil nil nil 7328 nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 2434 1 nil nil nil 7168 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1296 nil 170 176 1296 9215 nil nil nil nil 2496 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 7296 nil nil nil nil 1 nil 170 192 34 6 8 'indicator2' 2706 5 7168 511 1 false nil nil nil nil nil nil nil 8 'indicator1' 2706 3 7168 33423361 5 false nil nil nil nil nil nil nil 8 'indicator0' 2706 1 7168 33554459 13 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 2242 1029 nil 1026 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 2242 1027 1026 60239 1026 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2242 1031 1026 335 1026 31317503 1 nil nil nil nil #Error nil nil nil nil 1090 138 144 34 7 1154 #createAt:extent: 34 2 1202 1 1 1202 1091 541 7168 1154 #modificationEventMask: 8 #(4607) 7168 1154 #caretPeriod: 8 #(530) 7168 1154 #wordWrap: 8 #(true) 7168 1154 #margins: 34 1 34 3 3218 1 7168 49 3 nil nil nil nil 3218 3 7168 1 nil nil 67108863 nil nil 3218 5 7168 1 nil nil nil nil nil 7168 1154 #canHScroll: 8 #(false) 7168 1154 #maxCompletionListHeight: 8 #(9) 7168 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 14 1 0 0] 8 #() 1312 nil 29 170 192 34 4 6864 8 'beforeTitle' 7168 8 'before' nil 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1 1 1202 1091 581 6768 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 34 1 0 0] 34 2 7168 6864 1312 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 6160 34 2 8 1140850688 1 8576 nil 1026 66047 nil 517 nil nil nil 8576 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1091 1 1202 11 581 8576 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 33 2 0 0 0 0 0 0 38 2 0 0 34 1 0 0] 8 #() 1312 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 6160 34 2 8 1140850688 131073 8816 nil 610 6112 nil 5 nil nil nil 8816 6130 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 8816 34 2 8 1140850945 262145 8912 nil nil nil 5 nil nil nil 8912 nil 8 1817086624 2178 nil nil nil 1090 138 144 34 2 1154 #createAt:extent: 34 2 1202 1 541 1202 1093 41 8912 1154 #text: 34 1 8 '
' 8912 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 14 1 0 0 34 2 0 0 34 1 0 0] 8 #() 1312 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 8816 34 2 8 1140920580 1025 9216 1442 nil false 1488 nil 1026 26337781 nil 5 nil nil nil 9216 nil 8 4294902163 2178 nil nil 11 nil 170 192 34 12 #indentGuide 2242 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 2242 3 7360 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 2242 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 2242 77 2304 2320 1 nil nil nil nil #callTip nil nil nil #normal 2242 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 2242 5 nil 1026 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 9440 9392 9456 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 9408 nil nil nil 9376 nil nil 7474 7504 170 192 34 2 #default 2434 1 nil nil nil 9216 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1296 nil 170 176 1296 9215 nil nil nil nil 2496 nil nil 65 nil nil nil 7600 3 170 192 34 2 #container 9344 nil nil nil nil 1 nil 170 192 34 6 8 'indicator2' 2706 5 9216 511 1 false nil nil nil nil nil nil nil 8 'indicator1' 2706 3 9216 33423361 5 false nil nil nil nil nil nil nil 8 'indicator0' 2706 1 9216 33554459 13 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 2242 1029 nil 1026 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 2242 1027 1026 60239 1026 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2242 1031 1026 335 1026 31317503 1 nil nil nil nil #Error nil nil nil nil 1090 138 144 34 7 1154 #createAt:extent: 34 2 1202 1 1 1202 1093 541 9216 1154 #modificationEventMask: 8 #(4607) 9216 1154 #caretPeriod: 8 #(530) 9216 1154 #wordWrap: 8 #(true) 9216 1154 #margins: 34 1 34 3 3218 1 9216 49 3 nil nil nil nil 3218 3 9216 1 nil nil 67108863 nil nil 3218 5 9216 1 nil nil nil nil nil 9216 1154 #canHScroll: 8 #(false) 9216 1154 #maxCompletionListHeight: 8 #(9) 9216 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 34 2 0 0 14 1 0 0] 8 #() 1312 nil 29 170 192 34 4 8912 8 'afterTitle' 9216 8 'after' nil 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1101 1 1202 1093 581 8816 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 38 2 0 0 0 0 0 0 72 4 0 0 34 1 0 0] 34 2 9216 8912 1312 nil 27 1312 nil 27 170 192 34 2 6160 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 1522 nil true 34 4 1570 1 1602 #selectUpper 8 'Select &upper' 1 1 nil nil nil 1570 1 1602 #selectLower 8 'Select &lower' 1 1 nil nil nil 1650 4097 1570 1 1602 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 17687 nil nil 1522 nil true 34 3 1570 1 1602 #character 8 '&Character' 1 1 nil nil nil 1570 1 1602 #word 8 '&Word' 1 1 nil nil nil 1570 1 1602 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 17689 nil nil 1522 nil true 34 1 1570 1 1602 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 17691 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1090 138 144 34 3 1154 #createAt:extent: 34 2 1202 9 55 1202 2225 613 6032 1154 #text: 34 1 8 'Comparison' 6032 1154 #updateMenuBar 1296 6032 1250 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 34 1 6160 1312 nil 27 3440 170 192 34 10 3440 8 'classDocumentation' 960 8 'sunit' 4736 8 'methodSource' 1376 8 'classDefinition' 6032 8 'comparisonTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 544 34 2 8 1140916736 1 11504 590662 2 ##(Smalltalk.ListModel) 138 144 34 5 1344 3408 4704 768 6016 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) nil nil 1 nil nil nil 11504 nil 8 4294905135 802 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 11680 7 257 nil 802 0 nil 11698 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 11744 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #smallIcons nil nil nil nil nil 1090 138 144 34 3 1154 #createAt:extent: 34 2 1202 1 1 1202 2241 675 11504 1154 #basicSelectionsByIndex: 34 1 8 #(2) 11504 1154 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 11504 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 8 #() 1312 nil 27 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1 685 1202 2241 675 544 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 86 1 0 0 96 4 0 0 167 2 0 0] 34 6 1376 3440 4736 960 6032 11504 1312 nil 27 524806 ##(Smalltalk.Fraction) 3 5 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 12256 nil nil nil 5 nil nil nil 12256 482 170 176 34 4 410 ##(Smalltalk.ToolButton) 34 14 nil 12256 34 2 8 1140850688 131073 12368 nil nil nil 1029 nil nil nil 12368 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 12368 34 2 8 1140853580 131137 12432 nil nil nil 1 nil nil nil 12432 nil 8 4294905615 nil 170 192 34 2 16269 1115910 ##(Smalltalk.ToolbarIconButton) 16269 nil 12432 1 1602 #flipAutoCommit 8 'Auto Commit' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons/camera16_light_icon.ico' nil 395334 3 ##(Smalltalk.Bitmap) nil true nil nil nil nil 3 1202 33 33 1 34 1 12560 170 176 34 2 12704 1 nil 3 nil 1202 33 33 1202 33 33 nil nil 1090 138 144 34 2 1154 #createAt:extent: 34 2 1202 1 1 1202 43 43 12432 1154 #updateSizePosted 1296 12432 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 8 #() 1312 nil 27 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1 1 1202 43 43 12368 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 34 1 12432 1312 nil 27 327734 ##(Smalltalk.Float) 8 123 20 174 71 225 122 148 63 410 ##(Smalltalk.TextEdit) 34 16 nil 12256 34 2 8 1140850688 1 13184 nil 610 8 4278190080 nil 5 nil 2066 nil true 2098 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 1202 193 193 nil 13184 2290 33554433 8 4294905821 2178 nil nil 67 1090 138 144 34 2 1154 #createAt:extent: 34 2 1202 43 1 1202 2199 43 13184 1154 #setMarginWidths: 34 1 8 #(3 3) 13184 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 21 0 0 0 0 0 0 0 96 4 0 0 21 0 0 0] 8 #() 1312 nil 27 3 false 170 192 34 4 12368 8 'autoCommitButton' 13184 8 'statusBarField' nil 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1 1359 1202 2241 43 12256 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 167 2 0 0 96 4 0 0 188 2 0 0] 34 2 12368 13184 1312 nil 27 13154 8 184 30 133 235 81 184 158 63 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 13840 nil nil nil 5 nil nil nil 13840 482 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 13840 34 2 8 1140850688 131073 13952 nil nil nil 5 nil nil nil 13952 482 170 176 34 6 410 ##(Smalltalk.ListView) 34 30 nil 13952 34 2 8 1409405261 1025 14064 11570 138 144 1296 nil 11648 610 8 4278190080 nil 5 nil nil nil 14064 nil 8 4294903685 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.IconicListAbstract) 11808 nil nil nil nil nil nil 138 144 34 1 920646 5 ##(Smalltalk.ListViewColumn) 8 'Column 1' 333 #left 802 0 nil 834 2 1 800 8 'doIt' 8 '[:each | each displayName]' 8 #[30 105 226 0 106] #displayName 14336 7 257 nil ##(Smalltalk.SortedCollection) nil nil 14064 nil 3 802 0 nil 834 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 14416 7 257 nil 802 0 nil 834 3 1 800 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 14496 7 257 nil #report 1296 nil 133217 nil 34 4 nil nil 1202 1 1 nil 1090 138 144 34 2 1154 #createAt:extent: 34 2 1202 1 1 1202 341 675 14064 1154 #text: 34 1 8 'Column 1' 14064 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 170 0 0 0 81 1 0 0] 8 #() 1312 nil 27 12226 5 11 410 ##(Smalltalk.ContainerView) 34 15 nil 13952 34 2 8 1140850688 131073 14832 nil nil nil 5 nil nil nil 14832 482 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 14832 34 2 8 1409286144 131073 14944 nil 610 8 4278190080 nil 5 nil nil nil 14944 658 138 144 1296 nil 170 192 1296 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 14944 34 2 8 1140916736 1 15088 11570 138 144 1296 nil 11648 nil nil 1 nil nil nil 15088 nil 8 4294905135 802 0 nil 11698 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 15200 7 257 nil 802 0 nil 11698 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 15248 7 257 nil 11808 nil nil nil nil nil #noIcons nil nil nil nil nil 1090 138 144 34 2 1154 #createAt:extent: 34 2 1202 1 1 1202 511 675 15088 1154 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 15088 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 81 1 0 0] 8 #() 1312 nil 27 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1 1 1202 511 675 14944 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 81 1 0 0] 34 1 15088 1312 nil 27 3 false 170 192 34 2 14944 8 'packageDictionaryCards' nil 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 351 1 1202 511 675 14832 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 175 0 0 0 0 0 0 0 174 1 0 0 81 1 0 0] 34 1 14944 1312 nil 27 12226 7 11 410 ##(Smalltalk.ContainerView) 34 15 nil 13952 34 2 8 1140850688 131073 15872 nil nil nil 5 nil nil nil 15872 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.CardContainer) 34 16 nil 15872 34 2 8 1409286144 131073 16000 nil 610 8 4278190080 nil 5 nil nil nil 16000 658 138 144 34 2 722 754 8 'Instance' 802 0 nil 834 7 1 16 8 'doIt' 8 '(CardLabel text: ''Instance'' iconBlock: [Icon fromId: ''Class.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 752 16176 12608 8 'Class.ico' #fromId: #text:iconBlock: 16192 11 1 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 16000 34 2 8 1140850688 131073 16288 nil nil nil 5 nil nil nil 16288 nil 170 192 1296 nil 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 9 9 1202 495 1 16288 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 251 0 0 0 4 0 0 0] 8 #() 1312 nil 27 722 754 8 'Class' 802 0 nil 834 7 1 16 8 'doIt' 8 '(CardLabel text: ''Class'' iconBlock: [Icon fromId: ''Metaclass.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 752 16560 12608 8 'Metaclass.ico' #fromId: #text:iconBlock: 16576 11 1 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 16000 34 2 8 1140850688 131073 16672 nil nil nil 5 nil nil nil 16672 nil 170 192 1296 nil 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 9 9 1202 495 1 16672 1250 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 251 0 0 0 4 0 0 0] 8 #() 1312 nil 27 16288 170 192 34 4 16288 8 'instanceTab' 16672 8 'classTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 16000 34 2 8 1140916738 1 16976 11570 138 144 34 2 16160 16544 nil 11648 nil nil 1 nil nil nil 16976 nil 8 4294905135 802 0 nil 11698 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 17104 7 257 nil 802 0 nil 11698 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 17152 7 257 nil 11808 nil nil nil nil nil #smallIcons nil nil nil nil nil 1090 138 144 34 3 1154 #createAt:extent: 34 2 1202 1 1 1202 511 51 16976 1154 #basicSelectionsByIndex: 34 1 8 #(1) 16976 1154 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 16976 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 25 0 0 0] 8 #() 1312 nil 27 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1 575 1202 511 51 16000 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 31 1 0 0 255 0 0 0 56 1 0 0] 34 3 16288 16672 16976 1312 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 17634 #fixedParentRight 1 17634 #fixedParentBottom -99 17634 #fixedViewTop 51 410 ##(Smalltalk.TextEdit) 34 16 nil 15872 34 2 8 1140916352 1025 17712 nil 610 8 4278190080 nil 5 nil nil nil 17712 nil 8 4294905821 2178 nil nil 3 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1 625 1202 511 51 17712 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 255 0 0 0 81 1 0 0] 8 #() 1312 nil 27 17602 17648 1 17664 1 17680 -49 17680 1 410 ##(Smalltalk.CardContainer) 34 16 nil 15872 34 2 8 1409286144 131073 18016 nil 610 640 nil 5 nil nil nil 18016 658 138 144 34 2 722 754 8 'Classes' 802 0 nil 834 7 1 16 8 'doIt' 8 '(CardLabel text: ''Classes'' iconBlock: [Icon fromId: ''Class.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 752 18176 12608 8 'Class.ico' #fromId: #text:iconBlock: 18192 11 1 nil nil 410 ##(Smalltalk.ListView) 34 30 nil 18016 34 2 8 1409372237 1025 18288 11570 138 144 1296 nil 11648 610 14176 nil 21 nil nil nil 18288 nil 8 4294903685 14210 #displayString 8 #() nil 11808 nil nil nil nil nil nil 138 144 34 1 14290 8 '' 487 #left 14210 #displayString 8 #() 14210 #<= 8 #() nil nil 18288 nil 3 nil 802 0 nil 834 5 1 800 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 18576 7 257 nil #report 1296 nil 131169 nil 34 4 nil nil 1202 1 1 nil 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 9 55 1202 495 513 18288 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 251 0 0 0 27 1 0 0] 8 #() 1312 nil 27 722 754 8 'Hierarchy' 802 0 nil 834 7 1 16 8 'doIt' 8 '(CardLabel text: ''Hierarchy'' iconBlock: [Icon fromId: ''ClassHierarchyDiagram.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 752 18880 12608 8 'ClassHierarchyDiagram.ico' #fromId: #text:iconBlock: 18896 11 1 nil nil 410 ##(Smalltalk.TreeView) 34 27 nil 18016 34 2 8 1409352231 1025 18992 590918 3 ##(Smalltalk.TreeModel) nil 11648 525062 ##(Smalltalk.TreeNode) nil nil nil 170 192 1296 610 8 4278190080 nil 21 nil nil nil 18992 nil 8 4294904995 802 0 nil 834 2 1 800 8 'doIt' 8 '[:each | each displayString]' 8 #[30 105 226 0 106] #displayString 19184 7 257 nil ##(Smalltalk.IconicListAbstract) 11808 nil 802 0 nil 834 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 19264 7 257 nil 802 0 nil 834 5 1 800 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 19344 7 257 nil nil nil 170 176 1296 17 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 1296 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 9 55 1202 495 513 18992 1250 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 251 0 0 0 27 1 0 0] 8 #() 1312 nil 27 18288 170 192 34 4 18288 8 'classList' 18992 8 'classHierarchy' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 18016 34 2 8 1140916736 1 19680 11570 138 144 34 2 18160 18864 nil 11648 nil nil 1 nil nil nil 19680 nil 8 4294905135 802 0 nil 11698 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 19808 7 257 nil 802 0 nil 11698 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 19856 7 257 nil 11808 nil nil nil nil nil #smallIcons nil nil nil nil nil 1090 138 144 34 3 1154 #createAt:extent: 34 2 1202 1 1 1202 511 575 19680 1154 #basicSelectionsByIndex: 34 1 8 #(1) 19680 1154 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 19680 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 31 1 0 0] 8 #() 1312 nil 27 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1 1 1202 511 575 18016 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 31 1 0 0] 34 3 18288 18992 19680 1312 nil 27 17602 17648 1 17664 1 17634 #fixedParentTop 1 17680 -99 170 192 34 6 16000 8 'instanceClassTabs' 17712 8 'definedPackageClassText' 18016 8 'classHierarchyTabs' nil 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 871 1 1202 511 675 15872 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 179 1 0 0 0 0 0 0 178 2 0 0 81 1 0 0] 34 3 18016 16000 17712 1312 nil 27 12226 7 11 false 170 192 34 2 14064 8 'projectList' nil 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1 1 1202 2241 675 13952 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 7 14064 410 ##(Smalltalk.Splitter) 34 12 nil 13952 34 2 8 1140850688 1 20800 nil 610 8 4278190080 nil 517 nil nil nil 20800 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 341 1 1202 11 675 20800 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 170 0 0 0 0 0 0 0 175 0 0 0 81 1 0 0] 8 #() 1312 nil 27 14832 410 ##(Smalltalk.Splitter) 34 12 nil 13952 34 2 8 1140850688 1 21056 nil 610 20880 nil 517 nil nil nil 21056 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 861 1 1202 11 675 21056 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 174 1 0 0 0 0 0 0 179 1 0 0 81 1 0 0] 8 #() 1312 nil 27 15872 410 ##(Smalltalk.Splitter) 34 12 nil 13952 34 2 8 1140850688 1 21296 nil 610 20880 nil 517 nil nil nil 21296 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1381 1 1202 11 675 21296 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 178 2 0 0 0 0 0 0 183 2 0 0 81 1 0 0] 8 #() 1312 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 13952 34 2 8 1140850688 131073 21536 nil nil nil 5 nil nil nil 21536 482 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 21536 34 2 8 1140850688 131073 21648 nil nil nil 5 nil nil nil 21648 15938 170 176 34 6 410 ##(Smalltalk.ListView) 34 30 nil 21648 34 2 8 1409372233 1025 21760 11570 138 144 1296 nil 11648 610 8 4278190080 nil 13 nil nil nil 21760 nil 8 4294903685 14210 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 11808 nil nil nil nil nil nil 138 144 34 2 14290 8 '' 41 #left 1154 #empty 8 #() 16 14210 #<= 8 #() nil nil 21760 802 0 nil 834 2 1 800 8 'doIt' 8 '[:each | each subSuperIcon]' 8 #[30 105 226 0 106] #subSuperIcon 22064 7 257 nil 1 nil nil 14290 8 'Selector' 421 #left 14210 #displayString 21920 ##(Smalltalk.SortedCollection) nil nil 21760 nil 3 nil 802 0 nil 834 5 1 800 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 22192 7 257 nil #report 1296 nil 133221 nil 34 4 nil nil 1202 1 1 nil 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1 55 1202 469 571 21760 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 27 0 0 0 234 0 0 0 56 1 0 0] 8 #() 1312 nil 27 17602 17648 1 17664 1 20320 55 17680 -49 410 ##(Smalltalk.TextEdit) 34 16 nil 21648 34 2 8 1140916352 1025 22480 nil 610 17792 nil 5 nil nil nil 22480 nil 8 4294905821 2178 nil nil 3 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1 625 1202 469 51 22480 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 234 0 0 0 81 1 0 0] 8 #() 1312 nil 27 17602 17648 1 17664 1 17680 -49 17680 1 410 ##(Smalltalk.TextEdit) 34 16 nil 21648 34 2 8 1140916352 1025 22768 nil 610 8 4278190080 nil 5 nil nil nil 22768 nil 8 4294905821 2178 nil nil 3 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1 1 1202 469 51 22768 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 234 0 0 0 25 0 0 0] 8 #() 1312 nil 27 17602 17648 1 17664 1 20320 1 20320 51 170 192 34 6 21760 8 'methodList' 22480 8 'definedPackageMethodText' 22768 8 'categoryMethodText' nil 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 383 1 1202 469 675 21648 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 191 0 0 0 0 0 0 0 169 1 0 0 81 1 0 0] 34 3 21760 22480 22768 1312 nil 27 13154 8 0 0 0 0 0 0 244 63 false 170 192 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 21536 34 2 8 1409286144 131073 23360 nil 610 8 4278190080 nil 5 nil nil nil 23360 658 138 144 34 2 722 8 'Category' 410 ##(Smalltalk.ListView) 34 30 nil 23360 34 2 8 1409372233 1025 23536 11570 138 144 1296 nil 11648 610 21872 nil 21 nil nil nil 23536 nil 8 4294903685 14210 #displayString 8 #() nil 11808 nil nil nil nil nil nil 138 144 34 1 14290 8 'Column 1' 349 #left 14210 #displayString 8 #() ##(Smalltalk.SortedCollection) 802 0 nil 834 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each]' 1779525917 23792 7 257 nil nil 23536 nil 3 nil nil #report 1296 nil 131169 nil 34 4 nil nil 1202 1 1 nil 1090 138 144 34 2 1154 #createAt:extent: 34 2 1202 9 55 1202 357 613 23536 1154 #text: 34 1 8 'Column 1' 23536 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 182 0 0 0 77 1 0 0] 8 #() 1312 nil 27 722 8 'Variables' 410 ##(Smalltalk.ListView) 34 30 nil 23360 34 2 8 1409372233 1025 24128 11570 138 144 1296 nil 11648 610 21872 nil 21 nil nil nil 24128 nil 8 4294903685 14210 #displayString 8 #() nil 11808 nil nil nil nil nil nil 138 144 34 1 14290 8 'Column 1' 349 #left 14210 #displayString 24272 ##(Smalltalk.SortedCollection) nil nil 24128 nil 3 nil 802 0 nil 834 9 1 800 8 'doIt' 8 '[:each | each item first = Character space ifTrue: [each font: (each font beBold; beItalic)]]' 8 #[37 105 226 0 159 31 161 132 221 9 17 226 4 100 163 97 164 183 106 60 106] #item #first ##(Smalltalk.Character) #space #font #beBold #beItalic #font: 24368 7 257 nil #report 1296 nil 131169 nil 34 4 nil nil 1202 1 1 nil 1090 138 144 34 2 1154 #createAt:extent: 34 2 1202 9 55 1202 357 613 24128 1154 #text: 34 1 8 'Column 1' 24128 1250 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 182 0 0 0 77 1 0 0] 8 #() 1312 nil 27 23536 170 192 34 4 24128 8 'variableList' 23536 8 'categoryList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 23360 34 2 8 1140916736 1 24752 11570 138 144 34 2 23520 24112 nil 11648 nil nil 1 nil nil nil 24752 nil 8 4294905135 802 0 nil 11698 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 24880 7 257 nil 802 0 nil 11698 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 24928 7 257 nil 11808 nil nil nil nil nil #noIcons nil nil nil nil nil 1090 138 144 34 3 1154 #createAt:extent: 34 2 1202 1 1 1202 373 675 24752 1154 #basicSelectionsByIndex: 34 1 8 #(1) 24752 1154 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 24752 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 186 0 0 0 81 1 0 0] 8 #() 1312 nil 27 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1 1 1202 373 675 23360 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 186 0 0 0 81 1 0 0] 34 3 23536 24128 24752 1312 nil 27 8 'methodFilterTabs' nil 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1391 1 1202 851 675 21536 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 183 2 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 3 23360 410 ##(Smalltalk.Splitter) 34 12 nil 21536 34 2 8 1140850688 1 25552 nil 610 20880 nil 517 nil nil nil 25552 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 373 1 1202 11 675 25552 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 186 0 0 0 0 0 0 0 191 0 0 0 81 1 0 0] 8 #() 1312 nil 27 21648 1312 nil 27 1312 nil 27 7 false 170 192 1296 nil 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1 1 1202 2241 675 13840 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 1 13952 1312 nil 27 12226 3 5 true 170 192 34 4 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 26016 nil 610 20880 nil 517 nil nil nil 26016 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1 675 1202 2241 11 26016 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 81 1 0 0 96 4 0 0 86 1 0 0] 8 #() 1312 nil 27 8 'splitter' 544 8 'textAreaTabs' nil 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 7679 21 1202 2241 1401 416 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 95 19 0 0 198 2 0 0] 34 4 13840 26016 544 12256 1312 nil 27 )! !
!JadeiteBrowserPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

