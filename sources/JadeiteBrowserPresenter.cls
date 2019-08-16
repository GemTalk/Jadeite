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
			classDefinitionPresenter view
				backcolor: JadeTextStyles default colorForNoEdits;
				isModified: false;
				isReadOnly: false]!

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
	self issueCommand: (Array with: methodListPresenter selection).
	methodSourcePresenter value: methodListPresenter selection source.
	methodSourcePresenter view isModified: true. 
	self methodValueChanged. 
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
	BrowserUpdate current register: dictionaryPresenter		selector: #dictionaryListUpdate:.
	BrowserUpdate current register: dictionaryPresenter		selector: #aborted:browser: browser: self.!

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
	presenter := self isNoneProjectSelected ifTrue:[dictionaryPresenter] ifFalse:[packageListPresenter].
	presenter list isEmpty
		ifTrue: 
			[classDefinitionPresenter value: String new.
			classDefinitionPresenter view isModified: false.
			^self].
	classDefinitionPresenter value: (presenter selections isEmpty
				ifTrue: [String new]
				ifFalse: [presenter selections first defaultTemplate]).
	classDefinitionPresenter view
		backcolor: JadeTextStyles default colorForNoEdits;
		isModified: false;
		isReadOnly: false!

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
	classDefinitionPresenter view
		backcolor: JadeTextStyles default colorForNoEdits;
		isModified: false!

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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil nil 5 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 6 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 544 nil nil nil 5 nil nil nil 544 482 170 176 34 4 410 ##(Smalltalk.TextEdit) 34 16 nil 544 34 2 8 1140850688 1 656 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 nil 5 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 328198 ##(Smalltalk.Point) 193 193 nil 656 786694 ##(Smalltalk.IndexedColor) 33554433 8 4294905101 852486 ##(Smalltalk.NullConverter) nil nil 67 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 850 43 1 850 2199 43 656 1026 #setMarginWidths: 34 1 8 #(3 3) 656 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 21 0 0 0 0 0 0 0 96 4 0 0 21 0 0 0] 8 #() 850 193 193 nil 27 3 410 ##(Smalltalk.ToolButton) 34 14 nil 544 34 2 8 1140850688 131073 1232 nil nil nil 1029 nil nil nil 1232 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 1232 34 2 8 1140853580 131137 1296 nil nil nil 1 nil nil nil 1296 nil 8 4294905565 nil 170 192 34 2 10061 1115910 ##(Smalltalk.ToolbarIconButton) 10061 nil 1296 1 1180998 4 ##(Smalltalk.CommandDescription) #flipAutoCommit 8 'Auto Commit' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons/camera16_light_icon.ico' nil 395334 3 ##(Smalltalk.Bitmap) nil true nil nil nil nil 3 850 33 33 1 34 1 1424 170 176 34 2 1584 1 nil 3 nil 850 33 33 850 33 33 nil nil 962 138 144 34 2 1026 #createAt:extent: 34 2 850 1 1 850 43 43 1296 1026 #updateSizePosted 8 #() 1296 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 8 #() 1216 nil 27 962 138 144 34 1 1026 #createAt:extent: 34 2 850 1 1 850 43 43 1232 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 21 0 0 0 21 0 0 0] 34 1 1296 1216 nil 27 327734 ##(Smalltalk.Float) 8 123 20 174 71 225 122 148 63 false 170 192 34 4 656 8 'statusBarField' 1232 8 'autoCommitButton' nil 962 138 144 34 1 1026 #createAt:extent: 34 2 850 1 1359 850 2241 43 544 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 167 2 0 0 96 4 0 0 188 2 0 0] 34 2 1232 656 1216 nil 27 2050 8 184 30 133 235 81 184 158 63 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 2320 nil 722 8 4278190080 nil 5 nil nil nil 2320 655878 ##(Smalltalk.CardLayout) 138 144 34 5 721414 ##(Smalltalk.Association) 590662 1 ##(Smalltalk.CardLabel) 8 'SUnit' 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 4 1 2560 8 'doIt' 8 '[Icon fromId: ''icons\UnitTestPlugin.ico'']' 8 #[32 105 45 30 178 106] 983558 ##(Smalltalk.VariableBinding) #Icon 1488 8 'icons\UnitTestPlugin.ico' #fromId: 2576 7 1 nil nil 410 ##(Smalltalk.ReferenceView) 34 14 nil 2320 34 2 8 1140850688 131073 2720 nil 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 nil nil nil 2720 1180166 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteSUnitInClassPresenter) #resource_Default_view nil 962 138 144 34 1 1026 #createAt:extent: 34 2 850 9 55 850 2225 613 2720 1154 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 1824 1216 nil 27 2482 2514 8 'Class Definition' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 2320 34 2 8 1445007428 1025 3040 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 2786 26337781 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 11 984134 2 ##(Smalltalk.CommandMenuItem) 1 1442 #editSave 8 '&Save' 9383 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 3234 1 1442 #editUndo 8 '&Undo' 9397 1 nil nil nil 3234 1 1442 #editRedo 8 '&Redo' 9395 1 nil nil nil 3298 4097 3234 1 1442 #editCut 8 'Cu&t' 9393 1 nil nil nil 3234 1 1442 #editCopy 8 '&Copy' 9351 1 nil nil nil 3234 1 1442 #editPaste 8 '&Paste' 9389 1 nil nil nil 3234 1 1442 #editDelete 8 '&Delete' 1629 1 nil nil nil 3298 4097 3234 1 1442 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 770 nil true 802 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 850 193 193 nil 3040 nil 8 4294905511 930 nil nil 13 nil 170 192 34 4 #normal 1182790 1 ##(Smalltalk.ScintillaTextStyle) 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 3842 77 882 33554457 882 33554471 1 nil nil nil nil #callTip nil nil nil 34 256 3856 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3872 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1639686 ##(Smalltalk.SmalltalkExpressionStyler) 1 nil nil false 138 144 1824 170 192 34 2 #default 1641542 1 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 3040 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1824 nil 170 176 1824 9215 nil nil nil nil 882 33554447 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 3856 nil nil nil nil 1 nil 170 192 34 6 1 1510470 2 ##(Smalltalk.ScintillaIndicatorStyle) 1 3040 65025 3 false 1 nil nil nil nil nil nil 3 4290 3 3040 33423361 5 false 3 nil nil nil nil nil nil 5 4290 5 3040 511 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 3842 1029 nil 2786 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 3842 1027 2786 60239 2786 31326207 1 nil nil nil nil #Warning nil nil nil #Error 3842 1031 2786 335 2786 31317503 1 nil nil nil nil #Error nil nil nil nil 962 138 144 34 8 1026 #createAt:extent: 34 2 850 9 55 850 2225 613 3040 1026 #contextMenu: 34 1 3200 3040 1026 #modificationEventMask: 8 #(4607) 3040 1026 #caretPeriod: 8 #(530) 3040 1026 #wordWrap: 8 #(true) 3040 1026 #margins: 34 1 34 3 985158 2 ##(Smalltalk.ScintillaMargin) 1 3040 1 3 nil nil 5 nil 4802 3 3040 33 nil 3 67108863 5 nil 4802 5 3040 1 nil 3 -67108863 5 nil 3040 1026 #tabWidth: 8 #(4) 3040 1026 #maxCompletionListHeight: 8 #(9) 3040 1154 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1216 nil 29 2482 2514 8 'Class Documentation' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 2320 34 2 8 1445007428 1025 5024 3106 nil false 3152 nil 2786 26337781 nil 5 3186 nil true 34 1 3234 1 1442 #editSaveClassComment 8 'Save' 1025 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 770 nil true 802 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 850 193 193 nil 5024 nil 8 4294905511 930 nil nil 15 nil 170 192 34 4 #normal 3842 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 3842 77 3888 3904 1 nil nil nil nil #callTip nil nil nil 34 256 5344 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 5360 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 4018 1 nil nil nil 5024 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1824 nil 170 176 1824 9215 nil nil nil nil 4080 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 5344 nil nil nil nil 1 nil 170 192 34 6 1 4290 1 5024 65025 3 false 1 nil nil nil nil nil nil 3 4290 3 5024 33423361 5 false 3 nil nil nil nil nil nil 5 4290 5 5024 511 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 3842 1029 nil 2786 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 3842 1027 2786 60239 2786 31326207 1 nil nil nil nil #Warning nil nil nil #Error 3842 1031 2786 335 2786 31317503 1 nil nil nil nil #Error nil nil nil nil 962 138 144 34 8 1026 #createAt:extent: 34 2 850 9 55 850 2225 613 5024 1026 #contextMenu: 34 1 5120 5024 1026 #modificationEventMask: 8 #(4607) 5024 1026 #caretPeriod: 8 #(530) 5024 1026 #wordWrap: 8 #(true) 5024 1026 #margins: 34 1 34 3 4802 1 5024 1 3 nil nil 5 nil 4802 3 5024 33 nil 3 67108863 5 nil 4802 5 5024 1 nil 3 -67108863 5 nil 5024 1026 #tabWidth: 8 #(4) 5024 1026 #maxCompletionListHeight: 8 #(9) 5024 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1216 nil 29 2482 2514 8 'Method Source' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 2320 34 2 8 1445007428 1025 6320 3106 nil false 3152 nil 2786 26337781 nil 5 nil 770 nil true 802 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 850 193 193 nil 6320 nil 8 4294905511 930 nil nil 13 nil 170 192 34 4 #normal 3842 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 3842 77 3888 3904 1 nil nil nil nil #callTip nil nil nil 34 256 6544 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 6560 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 1824 170 192 34 2 #default 4018 1 nil nil nil 6320 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1824 nil 170 176 1824 9215 nil nil nil nil 4080 nil nil 65 nil nil 4096 8 '' 3 170 192 34 2 #container 170 192 34 4 #normal 6544 #callTip 6560 nil nil nil nil 1 nil 170 192 34 12 1 4290 1 6320 65025 3 false 1 nil nil nil nil nil nil 3 4290 3 6320 33423361 5 false 3 nil nil nil nil nil nil 5 4290 5 6320 511 1 false 5 nil nil nil nil nil nil 8 'indicator10' 4290 21 6320 33554459 3 nil nil nil nil nil nil nil nil 8 'indicator8' 4290 17 6320 33554447 1 nil nil nil nil nil nil nil nil 8 'indicator9' 4290 19 6320 33554459 13 nil nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 3842 1029 nil 2786 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 3842 1027 2786 60239 2786 31326207 1 nil nil nil nil #Warning nil nil nil #Error 3842 1031 2786 335 2786 31317503 1 nil nil nil nil #Error nil nil nil nil 962 138 144 34 8 1026 #createAt:extent: 34 2 850 9 55 850 2225 613 6320 1026 #modificationEventMask: 8 #(4607) 6320 1026 #hoverTime: 8 #(200) 6320 1026 #caretPeriod: 8 #(530) 6320 1026 #wordWrap: 8 #(true) 6320 1026 #margins: 34 1 34 3 4802 1 6320 61 3 nil nil 5 nil 4802 3 6320 1 nil 3 67108863 nil nil 4802 5 6320 1 nil 3 -67108863 nil nil 6320 1026 #tabWidth: 8 #(4) 6320 1026 #maxCompletionListHeight: 8 #(9) 6320 1154 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 8 #() 1216 nil 29 2482 8 'Comparison' 410 ##(Smalltalk.ShellView) 34 27 nil 2320 34 2 8 1078919168 131073 7616 nil 722 8 4278190080 nil 517 nil nil nil 7616 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 7616 34 2 8 1140850688 131073 7744 nil 2786 26337781 nil 5 3186 nil true 34 5 3234 1 1442 #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 3234 1 1442 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 3234 1 1442 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 3234 1 1442 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 3234 1 1442 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 7744 482 170 176 1824 false 170 192 1824 nil 962 138 144 34 2 1026 #createAt:extent: 34 2 850 1 1 850 2193 581 7744 1026 #contextMenu: 34 1 7824 7744 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 4 0 0 34 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 7744 34 2 8 1140850688 131073 8352 nil 722 7696 nil 5 nil nil nil 8352 7714 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 8352 34 2 8 1140850945 262145 8448 nil nil nil 5 nil nil nil 8448 nil 8 1686791472 930 nil nil nil 962 138 144 34 2 1026 #createAt:extent: 34 2 850 1 541 850 1091 41 8448 1026 #text: 34 1 8 '
' 8448 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 14 1 0 0 33 2 0 0 34 1 0 0] 8 #() 1216 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 8352 34 2 8 1140920580 1025 8752 3106 nil false 3152 nil 2786 26337781 nil 5 nil nil nil 8752 nil 8 4294905511 930 nil nil 11 nil 170 192 34 12 #indentGuide 3842 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 3842 3 882 33554445 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 3842 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 3842 77 3888 3904 1 nil nil nil nil #callTip nil nil nil #normal 3842 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 3842 5 nil 2786 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 8992 8928 9008 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 8960 nil nil nil 8912 nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 4018 1 nil nil nil 8752 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1824 nil 170 176 1824 9215 nil nil nil nil 4080 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 8880 nil nil nil nil 1 nil 170 192 34 6 8 'indicator1' 4290 3 8752 33423361 5 false nil nil nil nil nil nil nil 8 'indicator2' 4290 5 8752 511 1 false nil nil nil nil nil nil nil 8 'indicator0' 4290 1 8752 33554459 13 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 3842 1029 nil 2786 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 3842 1027 2786 60239 2786 31326207 1 nil nil nil nil #Warning nil nil nil #Error 3842 1031 2786 335 2786 31317503 1 nil nil nil nil #Error nil nil nil nil 962 138 144 34 7 1026 #createAt:extent: 34 2 850 1 1 850 1091 541 8752 1026 #modificationEventMask: 8 #(4607) 8752 1026 #caretPeriod: 8 #(530) 8752 1026 #wordWrap: 8 #(true) 8752 1026 #margins: 34 1 34 3 4802 1 8752 49 3 nil nil nil nil 4802 3 8752 1 nil nil 67108863 nil nil 4802 5 8752 1 nil nil nil nil nil 8752 1026 #canHScroll: 8 #(false) 8752 1026 #maxCompletionListHeight: 8 #(9) 8752 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 14 1 0 0] 8 #() 1216 nil 29 170 192 34 4 8448 8 'beforeTitle' 8752 8 'before' nil 962 138 144 34 1 1026 #createAt:extent: 34 2 850 1 1 850 1091 581 8352 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 34 1 0 0] 34 2 8752 8448 1216 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 7744 34 2 8 1140850688 1 10160 nil 2786 66047 nil 517 nil nil nil 10160 962 138 144 34 1 1026 #createAt:extent: 34 2 850 1091 1 850 11 581 10160 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 33 2 0 0 0 0 0 0 38 2 0 0 34 1 0 0] 8 #() 1216 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 7744 34 2 8 1140850688 131073 10400 nil 722 7696 nil 5 nil nil nil 10400 7714 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 10400 34 2 8 1140850945 262145 10496 nil nil nil 5 nil nil nil 10496 nil 8 1686791472 930 nil nil nil 962 138 144 34 2 1026 #createAt:extent: 34 2 850 1 541 850 1093 41 10496 1026 #text: 34 1 8 '
' 10496 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 14 1 0 0 34 2 0 0 34 1 0 0] 8 #() 1216 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 10400 34 2 8 1140920580 1025 10800 3106 nil false 3152 nil 2786 26337781 nil 5 nil nil nil 10800 nil 8 4294905511 930 nil nil 11 nil 170 192 34 12 #indentGuide 3842 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 3842 3 8944 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 3842 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 3842 77 3888 3904 1 nil nil nil nil #callTip nil nil nil #normal 3842 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 3842 5 nil 2786 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 11024 10976 11040 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 10992 nil nil nil 10960 nil nil 9058 9088 170 192 34 2 #default 4018 1 nil nil nil 10800 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1824 nil 170 176 1824 9215 nil nil nil nil 4080 nil nil 65 nil nil nil 9184 3 170 192 34 2 #container 10928 nil nil nil nil 1 nil 170 192 34 6 8 'indicator1' 4290 3 10800 33423361 5 false nil nil nil nil nil nil nil 8 'indicator2' 4290 5 10800 511 1 false nil nil nil nil nil nil nil 8 'indicator0' 4290 1 10800 33554459 13 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 3842 1029 nil 2786 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 3842 1027 2786 60239 2786 31326207 1 nil nil nil nil #Warning nil nil nil #Error 3842 1031 2786 335 2786 31317503 1 nil nil nil nil #Error nil nil nil nil 962 138 144 34 7 1026 #createAt:extent: 34 2 850 1 1 850 1093 541 10800 1026 #modificationEventMask: 8 #(4607) 10800 1026 #caretPeriod: 8 #(530) 10800 1026 #wordWrap: 8 #(true) 10800 1026 #margins: 34 1 34 3 4802 1 10800 49 3 nil nil nil nil 4802 3 10800 1 nil nil 67108863 nil nil 4802 5 10800 1 nil nil nil nil nil 10800 1026 #canHScroll: 8 #(false) 10800 1026 #maxCompletionListHeight: 8 #(9) 10800 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 34 2 0 0 14 1 0 0] 8 #() 1216 nil 29 170 192 34 4 10496 8 'afterTitle' 10800 8 'after' nil 962 138 144 34 1 1026 #createAt:extent: 34 2 850 1101 1 850 1093 581 10400 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 38 2 0 0 0 0 0 0 72 4 0 0 34 1 0 0] 34 2 10800 10496 1216 nil 27 1216 nil 27 170 192 34 2 7744 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 3186 nil true 34 4 3234 1 1442 #selectUpper 8 'Select &upper' 1 1 nil nil nil 3234 1 1442 #selectLower 8 'Select &lower' 1 1 nil nil nil 3298 4097 3234 1 1442 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 10187 nil nil 3186 nil true 34 3 3234 1 1442 #character 8 '&Character' 1 1 nil nil nil 3234 1 1442 #word 8 '&Word' 1 1 nil nil nil 3234 1 1442 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 10189 nil nil 3186 nil true 34 1 3234 1 1442 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 10191 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 962 138 144 34 3 1026 #createAt:extent: 34 2 850 9 55 850 2225 613 7616 1026 #text: 34 1 8 'Comparison' 7616 1026 #updateMenuBar 1824 7616 1154 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 77 1 0 0] 34 1 7744 1216 nil 27 5024 170 192 34 10 3040 8 'classDefinition' 7616 8 'comparisonTab' 5024 8 'classDocumentation' 6320 8 'methodSource' 2720 8 'sunit' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 2320 34 2 8 1140916736 1 13088 590662 2 ##(Smalltalk.ListModel) 138 144 34 5 3008 4992 6288 2528 7600 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) nil nil 1 nil nil nil 13088 nil 8 4294905357 2562 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 13264 7 257 nil 2562 0 nil 13282 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 13328 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #smallIcons nil nil nil nil nil 962 138 144 34 3 1026 #createAt:extent: 34 2 850 1 1 850 2241 675 13088 1026 #basicSelectionsByIndex: 34 1 8 #(2) 13088 1026 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 13088 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 8 #() 1216 nil 27 962 138 144 34 1 1026 #createAt:extent: 34 2 850 1 685 850 2241 675 2320 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 86 1 0 0 96 4 0 0 167 2 0 0] 34 6 3040 5024 6320 2720 7616 13088 1216 nil 27 524806 ##(Smalltalk.Fraction) 3 5 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 13840 nil nil nil 5 nil nil nil 13840 482 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 13840 34 2 8 1140850688 131073 13952 nil nil nil 5 nil nil nil 13952 482 170 176 34 6 410 ##(Smalltalk.ListView) 34 30 nil 13952 34 2 8 1409405261 1025 14064 13154 138 144 1824 nil 13232 722 8 4278190080 nil 5 nil nil nil 14064 nil 8 4294905463 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.IconicListAbstract) 13392 nil nil nil nil nil nil 138 144 34 1 920646 5 ##(Smalltalk.ListViewColumn) 8 'Column 1' 333 #left 2562 0 nil 2594 2 1 2560 8 'doIt' 8 '[:each | each displayName]' 8 #[30 105 226 0 106] #displayName 14336 7 257 nil ##(Smalltalk.SortedCollection) nil nil 14064 nil 3 2562 0 nil 2594 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 14416 7 257 nil 2562 0 nil 2594 3 1 2560 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 14496 7 257 nil #report 1824 nil 133217 nil 34 4 nil nil 850 1 1 nil 962 138 144 34 2 1026 #createAt:extent: 34 2 850 1 1 850 341 675 14064 1026 #text: 34 1 8 'Column 1' 14064 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 170 0 0 0 81 1 0 0] 8 #() 1216 nil 27 13810 5 11 410 ##(Smalltalk.ContainerView) 34 15 nil 13952 34 2 8 1140850688 131073 14832 nil nil nil 5 nil nil nil 14832 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.CardContainer) 34 16 nil 14832 34 2 8 1409286144 131073 14960 nil 722 8 4278190080 nil 5 nil nil nil 14960 2418 138 144 34 2 2482 2514 8 'Instance' 2562 0 nil 2594 7 1 16 8 'doIt' 8 '(CardLabel text: ''Instance'' iconBlock: [Icon fromId: ''Class.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 2512 15136 1488 8 'Class.ico' #fromId: #text:iconBlock: 15152 11 1 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 14960 34 2 8 1140850688 131073 15248 nil nil nil 5 nil nil nil 15248 nil 170 192 1824 nil 962 138 144 34 1 1026 #createAt:extent: 34 2 850 9 9 850 495 1 15248 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 251 0 0 0 4 0 0 0] 8 #() 1216 nil 27 2482 2514 8 'Class' 2562 0 nil 2594 7 1 16 8 'doIt' 8 '(CardLabel text: ''Class'' iconBlock: [Icon fromId: ''Metaclass.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 2512 15520 1488 8 'Metaclass.ico' #fromId: #text:iconBlock: 15536 11 1 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 14960 34 2 8 1140850688 131073 15632 nil nil nil 5 nil nil nil 15632 nil 170 192 1824 nil 962 138 144 34 1 1026 #createAt:extent: 34 2 850 9 9 850 495 1 15632 1154 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 251 0 0 0 4 0 0 0] 8 #() 1216 nil 27 15248 170 192 34 4 15632 8 'classTab' 15248 8 'instanceTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 14960 34 2 8 1140916738 1 15936 13154 138 144 34 2 15120 15504 nil 13232 nil nil 1 nil nil nil 15936 nil 8 4294905357 2562 0 nil 13282 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 16064 7 257 nil 2562 0 nil 13282 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 16112 7 257 nil 13392 nil nil nil nil nil #smallIcons nil nil nil nil nil 962 138 144 34 3 1026 #createAt:extent: 34 2 850 1 1 850 511 51 15936 1026 #basicSelectionsByIndex: 34 1 8 #(1) 15936 1026 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 15936 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 25 0 0 0] 8 #() 1216 nil 27 962 138 144 34 1 1026 #createAt:extent: 34 2 850 1 575 850 511 51 14960 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 31 1 0 0 255 0 0 0 56 1 0 0] 34 3 15248 15632 15936 1216 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 16594 #fixedParentRight 1 16594 #fixedParentBottom -99 16594 #fixedViewTop 51 410 ##(Smalltalk.CardContainer) 34 16 nil 14832 34 2 8 1409286144 131073 16672 nil 722 2400 nil 5 nil nil nil 16672 2418 138 144 34 2 2482 2514 8 'Classes' 2562 0 nil 2594 7 1 16 8 'doIt' 8 '(CardLabel text: ''Classes'' iconBlock: [Icon fromId: ''Class.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 2512 16832 1488 8 'Class.ico' #fromId: #text:iconBlock: 16848 11 1 nil nil 410 ##(Smalltalk.ListView) 34 30 nil 16672 34 2 8 1409372237 1025 16944 13154 138 144 1824 nil 13232 722 14176 nil 21 nil nil nil 16944 nil 8 4294905463 14210 #displayString 8 #() nil 13392 nil nil nil nil nil nil 138 144 34 1 14290 8 '' 487 #left 14210 #displayString 8 #() 14210 #<= 8 #() nil nil 16944 nil 3 nil 2562 0 nil 2594 5 1 2560 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 17232 7 257 nil #report 1824 nil 131169 nil 34 4 nil nil 850 1 1 nil 962 138 144 34 1 1026 #createAt:extent: 34 2 850 9 55 850 495 513 16944 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 251 0 0 0 27 1 0 0] 8 #() 1216 nil 27 2482 2514 8 'Hierarchy' 2562 0 nil 2594 7 1 16 8 'doIt' 8 '(CardLabel text: ''Hierarchy'' iconBlock: [Icon fromId: ''ClassHierarchyDiagram.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 2512 17536 1488 8 'ClassHierarchyDiagram.ico' #fromId: #text:iconBlock: 17552 11 1 nil nil 410 ##(Smalltalk.TreeView) 34 27 nil 16672 34 2 8 1409352231 1025 17648 590918 3 ##(Smalltalk.TreeModel) nil 13232 525062 ##(Smalltalk.TreeNode) nil nil nil 170 192 1824 722 8 4278190080 nil 21 nil nil nil 17648 nil 8 4294905469 2562 0 nil 2594 2 1 2560 8 'doIt' 8 '[:each | each displayString]' 8 #[30 105 226 0 106] #displayString 17840 7 257 nil ##(Smalltalk.IconicListAbstract) 13392 nil 2562 0 nil 2594 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 17920 7 257 nil 2562 0 nil 2594 5 1 2560 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 18000 7 257 nil nil nil 170 176 1824 17 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 1824 962 138 144 34 1 1026 #createAt:extent: 34 2 850 9 55 850 495 513 17648 1154 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 251 0 0 0 27 1 0 0] 8 #() 1216 nil 27 16944 170 192 34 4 17648 8 'classHierarchy' 16944 8 'classList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 16672 34 2 8 1140916736 1 18336 13154 138 144 34 2 16816 17520 nil 13232 nil nil 1 nil nil nil 18336 nil 8 4294905357 2562 0 nil 13282 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 18464 7 257 nil 2562 0 nil 13282 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 18512 7 257 nil 13392 nil nil nil nil nil #smallIcons nil nil nil nil nil 962 138 144 34 3 1026 #createAt:extent: 34 2 850 1 1 850 511 575 18336 1026 #basicSelectionsByIndex: 34 1 8 #(1) 18336 1026 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 18336 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 31 1 0 0] 8 #() 1216 nil 27 962 138 144 34 1 1026 #createAt:extent: 34 2 850 1 1 850 511 575 16672 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 31 1 0 0] 34 3 16944 17648 18336 1216 nil 27 16562 16608 1 16624 1 16594 #fixedParentTop 1 16640 -99 410 ##(Smalltalk.TextEdit) 34 16 nil 14832 34 2 8 1140916352 1025 18992 nil 722 8 4278190080 nil 5 nil nil nil 18992 nil 8 4294905101 930 nil nil 3 962 138 144 34 1 1026 #createAt:extent: 34 2 850 1 625 850 511 51 18992 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 255 0 0 0 81 1 0 0] 8 #() 1216 nil 27 16562 16608 1 16624 1 16640 -49 16640 1 170 192 34 6 14960 8 'instanceClassTabs' 16672 8 'classHierarchyTabs' 18992 8 'definedPackageClassText' nil 962 138 144 34 1 1026 #createAt:extent: 34 2 850 871 1 850 511 675 14832 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 179 1 0 0 0 0 0 0 178 2 0 0 81 1 0 0] 34 3 16672 14960 18992 1216 nil 27 13810 7 11 410 ##(Smalltalk.ContainerView) 34 15 nil 13952 34 2 8 1140850688 131073 19552 nil nil nil 5 nil nil nil 19552 482 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 19552 34 2 8 1409286144 131073 19664 nil 722 8 4278190080 nil 5 nil nil nil 19664 2418 138 144 1824 nil 170 192 1824 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 19664 34 2 8 1140916736 1 19808 13154 138 144 1824 nil 13232 nil nil 1 nil nil nil 19808 nil 8 4294905357 2562 0 nil 13282 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 19920 7 257 nil 2562 0 nil 13282 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 19968 7 257 nil 13392 nil nil nil nil nil #noIcons nil nil nil nil nil 962 138 144 34 2 1026 #createAt:extent: 34 2 850 1 1 850 511 675 19808 1026 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 19808 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 81 1 0 0] 8 #() 1216 nil 27 962 138 144 34 1 1026 #createAt:extent: 34 2 850 1 1 850 511 675 19664 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 81 1 0 0] 34 1 19808 1216 nil 27 3 false 170 192 34 2 19664 8 'packageDictionaryCards' nil 962 138 144 34 1 1026 #createAt:extent: 34 2 850 351 1 850 511 675 19552 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 175 0 0 0 0 0 0 0 174 1 0 0 81 1 0 0] 34 1 19664 1216 nil 27 13810 7 11 false 170 192 34 2 14064 8 'projectList' nil 962 138 144 34 1 1026 #createAt:extent: 34 2 850 1 1 850 2241 675 13952 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 7 14064 410 ##(Smalltalk.Splitter) 34 12 nil 13952 34 2 8 1140850688 1 20800 nil 722 8 4278190080 nil 517 nil nil nil 20800 962 138 144 34 1 1026 #createAt:extent: 34 2 850 341 1 850 11 675 20800 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 170 0 0 0 0 0 0 0 175 0 0 0 81 1 0 0] 8 #() 1216 nil 27 19552 410 ##(Smalltalk.Splitter) 34 12 nil 13952 34 2 8 1140850688 1 21056 nil 722 20880 nil 517 nil nil nil 21056 962 138 144 34 1 1026 #createAt:extent: 34 2 850 861 1 850 11 675 21056 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 174 1 0 0 0 0 0 0 179 1 0 0 81 1 0 0] 8 #() 1216 nil 27 14832 410 ##(Smalltalk.Splitter) 34 12 nil 13952 34 2 8 1140850688 1 21296 nil 722 20880 nil 517 nil nil nil 21296 962 138 144 34 1 1026 #createAt:extent: 34 2 850 1381 1 850 11 675 21296 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 178 2 0 0 0 0 0 0 183 2 0 0 81 1 0 0] 8 #() 1216 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 13952 34 2 8 1140850688 131073 21536 nil nil nil 5 nil nil nil 21536 482 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 21536 34 2 8 1140850688 131073 21648 nil nil nil 5 nil nil nil 21648 14898 170 176 34 6 410 ##(Smalltalk.TextEdit) 34 16 nil 21648 34 2 8 1140916352 1025 21760 nil 722 19072 nil 5 nil nil nil 21760 nil 8 4294905101 930 nil nil 3 962 138 144 34 1 1026 #createAt:extent: 34 2 850 1 625 850 469 51 21760 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 56 1 0 0 234 0 0 0 81 1 0 0] 8 #() 1216 nil 27 16562 16608 1 16624 1 16640 -49 16640 1 410 ##(Smalltalk.TextEdit) 34 16 nil 21648 34 2 8 1140916352 1025 22048 nil 722 8 4278190080 nil 5 nil nil nil 22048 nil 8 4294905101 930 nil nil 3 962 138 144 34 1 1026 #createAt:extent: 34 2 850 1 1 850 469 51 22048 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 234 0 0 0 25 0 0 0] 8 #() 1216 nil 27 16562 16608 1 16624 1 18976 1 18976 51 410 ##(Smalltalk.ListView) 34 30 nil 21648 34 2 8 1409372233 1025 22352 13154 138 144 1824 nil 13232 722 8 4278190080 nil 13 nil nil nil 22352 nil 8 4294905463 14210 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 13392 nil nil nil nil nil nil 138 144 34 2 14290 8 '' 41 #left 1026 #empty 8 #() 16 14210 #<= 8 #() nil nil 22352 2562 0 nil 2594 2 1 2560 8 'doIt' 8 '[:each | each subSuperIcon]' 8 #[30 105 226 0 106] #subSuperIcon 22656 7 257 nil 1 nil nil 14290 8 'Selector' 421 #left 14210 #displayString 22512 ##(Smalltalk.SortedCollection) nil nil 22352 nil 3 nil 2562 0 nil 2594 3 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 22784 7 257 nil #report 1824 nil 133221 nil 34 4 nil nil 850 1 1 nil 962 138 144 34 1 1026 #createAt:extent: 34 2 850 1 55 850 469 571 22352 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 27 0 0 0 234 0 0 0 56 1 0 0] 8 #() 1216 nil 27 16562 16608 1 16624 1 18976 55 16640 -49 170 192 34 6 21760 8 'definedPackageMethodText' 22048 8 'categoryMethodText' 22352 8 'methodList' nil 962 138 144 34 1 1026 #createAt:extent: 34 2 850 383 1 850 469 675 21648 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 191 0 0 0 0 0 0 0 169 1 0 0 81 1 0 0] 34 3 22352 21760 22048 1216 nil 27 2050 8 0 0 0 0 0 0 244 63 false 170 192 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 21536 34 2 8 1409286144 131073 23360 nil 722 8 4278190080 nil 5 nil nil nil 23360 2418 138 144 34 2 2482 8 'Category' 410 ##(Smalltalk.ListView) 34 30 nil 23360 34 2 8 1409372233 1025 23536 13154 138 144 1824 nil 13232 722 22464 nil 21 nil nil nil 23536 nil 8 4294905463 14210 #displayString 8 #() nil 13392 nil nil nil nil nil nil 138 144 34 1 14290 8 'Column 1' 349 #left 14210 #displayString 8 #() ##(Smalltalk.SortedCollection) 2562 0 nil 2594 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each]' 1779525917 23792 7 257 nil nil 23536 nil 3 nil nil #report 1824 nil 131169 nil 34 4 nil nil 850 1 1 nil 962 138 144 34 2 1026 #createAt:extent: 34 2 850 9 55 850 357 613 23536 1026 #text: 34 1 8 'Column 1' 23536 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 182 0 0 0 77 1 0 0] 8 #() 1216 nil 27 2482 8 'Variables' 410 ##(Smalltalk.ListView) 34 30 nil 23360 34 2 8 1409372233 1025 24128 13154 138 144 1824 nil 13232 722 22464 nil 21 nil nil nil 24128 nil 8 4294905463 14210 #displayString 8 #() nil 13392 nil nil nil nil nil nil 138 144 34 1 14290 8 'Column 1' 349 #left 14210 #displayString 24272 ##(Smalltalk.SortedCollection) nil nil 24128 nil 3 nil 2562 0 nil 2594 9 1 2560 8 'doIt' 8 '[:each | each item first = Character space ifTrue: [each font: (each font beBold; beItalic)]]' 8 #[37 105 226 0 159 31 161 132 221 9 17 226 4 100 163 97 164 183 106 60 106] #item #first ##(Smalltalk.Character) #space #font #beBold #beItalic #font: 24368 7 257 nil #report 1824 nil 131169 nil 34 4 nil nil 850 1 1 nil 962 138 144 34 2 1026 #createAt:extent: 34 2 850 9 55 850 357 613 24128 1026 #text: 34 1 8 'Column 1' 24128 1154 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 182 0 0 0 77 1 0 0] 8 #() 1216 nil 27 23536 170 192 34 4 24128 8 'variableList' 23536 8 'categoryList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 23360 34 2 8 1140916736 1 24752 13154 138 144 34 2 23520 24112 nil 13232 nil nil 1 nil nil nil 24752 nil 8 4294905357 2562 0 nil 13282 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 24880 7 257 nil 2562 0 nil 13282 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 24928 7 257 nil 13392 nil nil nil nil nil #noIcons nil nil nil nil nil 962 138 144 34 3 1026 #createAt:extent: 34 2 850 1 1 850 373 675 24752 1026 #basicSelectionsByIndex: 34 1 8 #(1) 24752 1026 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 24752 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 186 0 0 0 81 1 0 0] 8 #() 1216 nil 27 962 138 144 34 1 1026 #createAt:extent: 34 2 850 1 1 850 373 675 23360 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 186 0 0 0 81 1 0 0] 34 3 23536 24128 24752 1216 nil 27 8 'methodFilterTabs' nil 962 138 144 34 1 1026 #createAt:extent: 34 2 850 1391 1 850 851 675 21536 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 183 2 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 3 23360 410 ##(Smalltalk.Splitter) 34 12 nil 21536 34 2 8 1140850688 1 25552 nil 722 20880 nil 517 nil nil nil 25552 962 138 144 34 1 1026 #createAt:extent: 34 2 850 373 1 850 11 675 25552 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 186 0 0 0 0 0 0 0 191 0 0 0 81 1 0 0] 8 #() 1216 nil 27 21648 1216 nil 27 1216 nil 27 7 false 170 192 1824 nil 962 138 144 34 1 1026 #createAt:extent: 34 2 850 1 1 850 2241 675 13840 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 81 1 0 0] 34 1 13952 1216 nil 27 13810 3 5 true 170 192 34 4 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 26016 nil 722 20880 nil 517 nil nil nil 26016 962 138 144 34 1 1026 #createAt:extent: 34 2 850 1 675 850 2241 11 26016 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 81 1 0 0 96 4 0 0 86 1 0 0] 8 #() 1216 nil 27 8 'splitter' 2320 8 'textAreaTabs' nil 962 138 144 34 1 1026 #createAt:extent: 34 2 850 7679 21 850 2241 1401 416 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 95 19 0 0 198 2 0 0] 34 4 13840 26016 2320 544 1216 nil 27 )! !
!JadeiteBrowserPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

