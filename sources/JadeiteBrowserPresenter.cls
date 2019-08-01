"Filed out from Dolphin Smalltalk 7"!

JadeiteProjectsBrowserPresenter subclass: #JadeiteBrowserPresenter
	instanceVariableNames: 'dictionaryPresenter packageDictionaryCards globalsTab'
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

comparisonPresenter

	^comparisonPresenter!

createComponents
	super createComponents.
	dictionaryPresenter := self add: ListPresenter new name: 'dictionariesList'.
	packageDictionaryCards := self add: Presenter new name: 'packageDictionaryCards'.!

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
	dictionaryPresenter when: #'selectionChanged' send: #'updateDictionary' to: self!

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

onViewOpened

	super onViewOpened. 
	self showPackageList!

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
	^#('Dictionaries' 'Copy//copyProjectInfo')!

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
					[self resetClassTemplate.
					self resetDefinedClassPackage.
					categoryListPresenter clear.
					variableListPresenter clear.
					^methodListPresenter clear].
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
	BrowserUpdate current register: dictionaryPresenter	selector: #dictionaryListUpdate:.
	BrowserUpdate current register: dictionaryPresenter	selector: #aborted:browser: browser: self!

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

selectedGlobalName: selection
	| string rs |
	rs := ReadStream on: (selection at: 1).
	rs upTo: $..
	string := rs upToEnd.
	^string!

selectNoneProject
	projectListPresenter selection: (projectListPresenter list
				detect: [:projectService | projectService name = RowanProjectService noneProject name])!

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
			classListPresenter list: ListModel new].
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
			classListPresenter list: ListModel new]!

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
	Cursor wait showWhile: 
			[service := classListPresenter selectionOrNil ifNil: [^self updateHierarchyForPacktionaries].
			service command: #classHierarchy.
			self issueCommand: (Array with: service).
			service name = 'Object' ifFalse: [self selectClassNamed: service name]]!

updateHierarchyForPacktionaries
	| service |
	service := RowanBrowserService new command: #classHierarchy.
	service allClasses addAll: self visibleClasses.
	self issueCommand: (Array with: service)!

updateProject
	self projectListPresenter selectionIfNone: 
			[packageListPresenter clear.
			dictionaryPresenter clear. 
			^self].
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
	projectInfoTab list: array contents!

visibleClasses
	| theClasses |
	theClasses := OrderedCollection new.
	self isNoneProjectSelected
		ifTrue: 
			[self updateServices: dictionaryPresenter selections.
			dictionaryPresenter selections
				do: [:dictionaryService | dictionaryService classes ifNotNil: [theClasses addAll: dictionaryService classes]]]
		ifFalse: 
			[self updateServices: packageListPresenter selections.
			packageListPresenter selections
				do: [:packageService | packageService classes ifNotNil: [theClasses addAll: packageService classes]]].
	^theClasses! !
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
!JadeiteBrowserPresenter categoriesFor: #inspectGlobal!menu handlers!public! !
!JadeiteBrowserPresenter categoriesFor: #isNoneProjectSelected!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #isProjectItemEnabled:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #isRowanProjectSelected!public!testing! !
!JadeiteBrowserPresenter categoriesFor: #onViewOpened!event handlers!public! !
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
!JadeiteBrowserPresenter categoriesFor: #selectedGlobalName:!menu handlers support!private! !
!JadeiteBrowserPresenter categoriesFor: #selectNoneProject!public!selection! !
!JadeiteBrowserPresenter categoriesFor: #showDictionaryList!event handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #showPackageList!event handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateAfterFindClass:!menu handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateAfterFindClassInDictionary:!menu handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateAfterFindClassInPackage:!menu handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateClasses!event handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateDictionaries!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateDictionary!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateGlobalsTab!private!tabs! !
!JadeiteBrowserPresenter categoriesFor: #updateHierarchy!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateHierarchyForPacktionaries!private!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateProject!event handlers!public!updating! !
!JadeiteBrowserPresenter categoriesFor: #updateProjectInfo!private!tabs! !
!JadeiteBrowserPresenter categoriesFor: #updateProjectTabFor:!private!tabs! !
!JadeiteBrowserPresenter categoriesFor: #visibleClasses!private!updating! !

!JadeiteBrowserPresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil nil 5 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 544 nil nil nil 5 nil nil nil 544 482 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 544 34 2 8 1140850688 131073 656 nil nil nil 5 nil nil nil 656 482 170 176 34 6 410 ##(Smalltalk.ListView) 34 30 nil 656 34 2 8 1409405261 1025 768 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 524550 ##(Smalltalk.ColorRef) 8 4278190080 nil 5 nil nil nil 768 nil 8 4294905965 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 1 920646 5 ##(Smalltalk.ListViewColumn) 8 'Column 1' 333 #left 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 1152 8 'doIt' 8 '[:each | each displayName]' 8 #[30 105 226 0 106] #displayName 1168 7 257 nil ##(Smalltalk.SortedCollection) nil nil 768 nil 3 1154 0 nil 1186 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 1264 7 257 nil 1154 0 nil 1186 3 1 1152 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 1344 7 257 nil #report 880 nil 133217 nil 34 4 nil nil 328198 ##(Smalltalk.Point) 1 1 nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 1442 1 1 1442 341 695 768 1538 #text: 34 1 8 'Column 1' 768 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 170 0 0 0 91 1 0 0] 8 #() 1442 193 193 nil 27 524806 ##(Smalltalk.Fraction) 5 11 410 ##(Smalltalk.ContainerView) 34 15 nil 656 34 2 8 1140850688 131073 1776 nil nil nil 5 nil nil nil 1776 482 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 1776 34 2 8 1409286144 131073 1888 nil 930 8 4278190080 nil 5 nil nil nil 1888 655878 ##(Smalltalk.CardLayout) 138 144 880 nil 170 192 880 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 1888 34 2 8 1140916736 1 2048 834 138 144 880 nil 912 nil nil 1 nil nil nil 2048 nil 8 4294902825 1154 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 2160 7 257 nil 1154 0 nil 2178 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 2224 7 257 nil 1056 nil nil nil nil nil #noIcons nil nil nil nil nil 1474 138 144 34 2 1538 #createAt:extent: 34 2 1442 1 1 1442 511 695 2048 1538 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 2048 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 91 1 0 0] 8 #() 1728 nil 27 1474 138 144 34 1 1538 #createAt:extent: 34 2 1442 1 1 1442 511 695 1888 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 91 1 0 0] 34 1 2048 1728 nil 27 3 false 170 192 34 2 1888 8 'packageDictionaryCards' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 1442 351 1 1442 511 695 1776 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 175 0 0 0 0 0 0 0 174 1 0 0 91 1 0 0] 34 1 1888 1728 nil 27 1746 7 11 410 ##(Smalltalk.ContainerView) 34 15 nil 656 34 2 8 1140850688 131073 2848 nil nil nil 5 nil nil nil 2848 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.CardContainer) 34 16 nil 2848 34 2 8 1409286144 131073 2976 nil 930 8 4278190080 nil 5 nil nil nil 2976 1986 138 144 34 2 721414 ##(Smalltalk.Association) 590662 1 ##(Smalltalk.CardLabel) 8 'Classes' 1154 0 nil 1186 7 1 16 8 'doIt' 8 '(CardLabel text: ''Classes'' iconBlock: [Icon fromId: ''Class.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 3152 3184 ##(Smalltalk.Icon) 8 'Class.ico' #fromId: #text:iconBlock: 3200 11 1 nil nil 410 ##(Smalltalk.ListView) 34 30 nil 2976 34 2 8 1409372237 1025 3296 834 138 144 880 nil 912 930 960 nil 21 nil nil nil 3296 nil 8 4294905965 994 #displayString 8 #() nil 1056 nil nil nil nil nil nil 138 144 34 1 1106 8 '' 487 #left 994 #displayString 8 #() 994 #<= 8 #() nil nil 3296 nil 3 nil 1154 0 nil 1186 3 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 3584 7 257 nil #report 880 nil 131169 nil 34 4 nil nil 1442 1 1 nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 1442 9 55 1442 495 533 3296 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 251 0 0 0 37 1 0 0] 8 #() 1728 nil 27 3122 3154 8 'Hierarchy' 1154 0 nil 1186 7 1 16 8 'doIt' 8 '(CardLabel text: ''Hierarchy'' iconBlock: [Icon fromId: ''ClassHierarchyDiagram.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 3152 3888 ##(Smalltalk.Icon) 8 'ClassHierarchyDiagram.ico' #fromId: #text:iconBlock: 3904 11 1 nil nil 410 ##(Smalltalk.TreeView) 34 27 nil 2976 34 2 8 1409352231 1025 4000 590918 3 ##(Smalltalk.TreeModel) nil 912 525062 ##(Smalltalk.TreeNode) nil nil nil 170 192 880 930 8 4278190080 nil 21 nil nil nil 4000 nil 8 4294904325 1154 0 nil 1186 2 1 1152 8 'doIt' 8 '[:each | each displayString]' 8 #[30 105 226 0 106] #displayString 4192 7 257 nil ##(Smalltalk.IconicListAbstract) 1056 nil 1154 0 nil 1186 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 4272 7 257 nil 1154 0 nil 1186 3 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 4352 7 257 nil nil nil 170 176 880 17 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 880 1474 138 144 34 1 1538 #createAt:extent: 34 2 1442 9 55 1442 495 533 4000 1666 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 251 0 0 0 37 1 0 0] 8 #() 1728 nil 27 3296 170 192 34 4 4000 8 'classHierarchy' 3296 8 'classList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 2976 34 2 8 1140916736 1 4688 834 138 144 34 2 3168 3872 nil 912 nil nil 1 nil nil nil 4688 nil 8 4294902825 1154 0 nil 2178 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 4816 7 257 nil 1154 0 nil 2178 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 4864 7 257 nil 1056 nil nil nil nil nil #smallIcons nil nil nil nil nil 1474 138 144 34 3 1538 #createAt:extent: 34 2 1442 1 1 1442 511 595 4688 1538 #basicSelectionsByIndex: 34 1 8 #(1) 4688 1538 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 4688 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 41 1 0 0] 8 #() 1728 nil 27 1474 138 144 34 1 1538 #createAt:extent: 34 2 1442 1 1 1442 511 595 2976 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 41 1 0 0] 34 3 3296 4000 4688 1728 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 5346 #fixedParentRight 1 5346 #fixedParentTop 1 5346 #fixedParentBottom -99 410 ##(Smalltalk.CardContainer) 34 16 nil 2848 34 2 8 1409286144 131073 5424 nil 930 8 4278190080 nil 5 nil nil nil 5424 1986 138 144 34 2 3122 3154 8 'Instance' 1154 0 nil 1186 7 1 16 8 'doIt' 8 '(CardLabel text: ''Instance'' iconBlock: [Icon fromId: ''Class.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 3152 5600 ##(Smalltalk.Icon) 8 'Class.ico' #fromId: #text:iconBlock: 5616 11 1 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 5424 34 2 8 1140850688 131073 5712 nil nil nil 5 nil nil nil 5712 nil 170 192 880 nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 1442 9 9 1442 495 1 5712 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 251 0 0 0 4 0 0 0] 8 #() 1728 nil 27 3122 3154 8 'Class' 1154 0 nil 1186 7 1 16 8 'doIt' 8 '(CardLabel text: ''Class'' iconBlock: [Icon fromId: ''Metaclass.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 3152 5984 ##(Smalltalk.Icon) 8 'Metaclass.ico' #fromId: #text:iconBlock: 6000 11 1 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 5424 34 2 8 1140850688 131073 6096 nil nil nil 5 nil nil nil 6096 nil 170 192 880 nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 1442 9 9 1442 495 1 6096 1666 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 251 0 0 0 4 0 0 0] 8 #() 1728 nil 27 5712 170 192 34 4 5712 8 'instanceTab' 6096 8 'classTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 5424 34 2 8 1140916738 1 6400 834 138 144 34 2 5584 5968 nil 912 nil nil 1 nil nil nil 6400 nil 8 4294902825 1154 0 nil 2178 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 6528 7 257 nil 1154 0 nil 2178 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 6576 7 257 nil 1056 nil nil nil nil nil #smallIcons nil nil nil nil nil 1474 138 144 34 3 1538 #createAt:extent: 34 2 1442 1 1 1442 511 51 6400 1538 #basicSelectionsByIndex: 34 1 8 #(1) 6400 1538 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 6400 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 25 0 0 0] 8 #() 1728 nil 27 1474 138 144 34 1 1538 #createAt:extent: 34 2 1442 1 595 1442 511 51 5424 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 41 1 0 0 255 0 0 0 66 1 0 0] 34 3 5712 6096 6400 1728 nil 27 5314 5360 1 5376 1 5408 -99 5346 #fixedViewTop 51 410 ##(Smalltalk.TextEdit) 34 16 nil 2848 34 2 8 1140916352 1025 7056 nil 930 8 4278190080 nil 5 nil nil nil 7056 nil 8 4294902643 852486 ##(Smalltalk.NullConverter) nil nil 3 1474 138 144 34 1 1538 #createAt:extent: 34 2 1442 1 645 1442 511 51 7056 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 66 1 0 0 255 0 0 0 91 1 0 0] 8 #() 1728 nil 27 5314 5360 1 5376 1 5408 -49 5408 1 170 192 34 6 2976 8 'classHierarchyTabs' 5424 8 'instanceClassTabs' 7056 8 'definedPackageClassText' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 1442 871 1 1442 511 695 2848 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 179 1 0 0 0 0 0 0 178 2 0 0 91 1 0 0] 34 3 2976 5424 7056 1728 nil 27 1746 7 11 false 170 192 34 2 768 8 'projectList' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 1442 1 1 1442 2241 695 656 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 91 1 0 0] 34 7 768 410 ##(Smalltalk.Splitter) 34 12 nil 656 34 2 8 1140850688 1 7840 nil 930 8 4278190080 nil 517 nil nil nil 7840 1474 138 144 34 1 1538 #createAt:extent: 34 2 1442 341 1 1442 11 695 7840 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 170 0 0 0 0 0 0 0 175 0 0 0 91 1 0 0] 8 #() 1728 nil 27 1776 410 ##(Smalltalk.Splitter) 34 12 nil 656 34 2 8 1140850688 1 8096 nil 930 7920 nil 517 nil nil nil 8096 1474 138 144 34 1 1538 #createAt:extent: 34 2 1442 861 1 1442 11 695 8096 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 174 1 0 0 0 0 0 0 179 1 0 0 91 1 0 0] 8 #() 1728 nil 27 2848 410 ##(Smalltalk.Splitter) 34 12 nil 656 34 2 8 1140850688 1 8336 nil 930 7920 nil 517 nil nil nil 8336 1474 138 144 34 1 1538 #createAt:extent: 34 2 1442 1381 1 1442 11 695 8336 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 178 2 0 0 0 0 0 0 183 2 0 0 91 1 0 0] 8 #() 1728 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 656 34 2 8 1140850688 131073 8576 nil nil nil 5 nil nil nil 8576 482 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 8576 34 2 8 1140850688 131073 8688 nil nil nil 5 nil nil nil 8688 2914 170 176 34 6 410 ##(Smalltalk.ListView) 34 30 nil 8688 34 2 8 1409372233 1025 8800 834 138 144 880 nil 912 930 8 4278190080 nil 13 nil nil nil 8800 nil 8 4294905965 994 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 1056 nil nil nil nil nil nil 138 144 34 2 1106 8 '' 41 #left 1538 #empty 8 #() 16 994 #<= 8 #() nil nil 8800 1154 0 nil 1186 2 1 1152 8 'doIt' 8 '[:each | each subSuperIcon]' 8 #[30 105 226 0 106] #subSuperIcon 9104 7 257 nil 1 nil nil 1106 8 'Selector' 421 #left 994 #displayString 8960 ##(Smalltalk.SortedCollection) nil nil 8800 nil 3 nil 1154 0 nil 1186 3 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 9232 7 257 nil #report 880 nil 133221 nil 34 4 nil nil 1442 1 1 nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 1442 1 55 1442 469 591 8800 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 27 0 0 0 234 0 0 0 66 1 0 0] 8 #() 1728 nil 27 5314 5360 1 5376 1 5392 55 5408 -49 410 ##(Smalltalk.TextEdit) 34 16 nil 8688 34 2 8 1140916352 1025 9520 nil 930 7136 nil 5 nil nil nil 9520 nil 8 4294902643 7170 nil nil 3 1474 138 144 34 1 1538 #createAt:extent: 34 2 1442 1 645 1442 469 51 9520 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 66 1 0 0 234 0 0 0 91 1 0 0] 8 #() 1728 nil 27 5314 5360 1 5376 1 5408 -49 5408 1 410 ##(Smalltalk.TextEdit) 34 16 nil 8688 34 2 8 1140916352 1025 9808 nil 930 8 4278190080 nil 5 nil nil nil 9808 nil 8 4294902643 7170 nil nil 3 1474 138 144 34 1 1538 #createAt:extent: 34 2 1442 1 1 1442 469 51 9808 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 234 0 0 0 25 0 0 0] 8 #() 1728 nil 27 5314 5360 1 5376 1 5392 1 5392 51 170 192 34 6 8800 8 'methodList' 9520 8 'definedPackageMethodText' 9808 8 'categoryMethodText' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 1442 383 1 1442 469 695 8688 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 191 0 0 0 0 0 0 0 169 1 0 0 91 1 0 0] 34 3 8800 9520 9808 1728 nil 27 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 244 63 false 170 192 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 8576 34 2 8 1409286144 131073 10416 nil 930 8 4278190080 nil 5 nil nil nil 10416 1986 138 144 34 2 3122 8 'Category' 410 ##(Smalltalk.ListView) 34 30 nil 10416 34 2 8 1409372233 1025 10592 834 138 144 880 nil 912 930 8912 nil 21 nil nil nil 10592 nil 8 4294905965 994 #displayString 8 #() nil 1056 nil nil nil nil nil nil 138 144 34 1 1106 8 'Column 1' 349 #left 994 #displayString 8 #() ##(Smalltalk.SortedCollection) 1154 0 nil 1186 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each]' 1779525917 10848 7 257 nil nil 10592 nil 3 nil nil #report 880 nil 131169 nil 34 4 nil nil 1442 1 1 nil 1474 138 144 34 2 1538 #createAt:extent: 34 2 1442 9 55 1442 357 633 10592 1538 #text: 34 1 8 'Column 1' 10592 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 182 0 0 0 87 1 0 0] 8 #() 1728 nil 27 3122 8 'Variables' 410 ##(Smalltalk.ListView) 34 30 nil 10416 34 2 8 1409372233 1025 11184 834 138 144 880 nil 912 930 8912 nil 21 nil nil nil 11184 nil 8 4294905965 994 #displayString 8 #() nil 1056 nil nil nil nil nil nil 138 144 34 1 1106 8 'Column 1' 349 #left 994 #displayString 11328 ##(Smalltalk.SortedCollection) nil nil 11184 nil 3 nil 1154 0 nil 1186 9 1 1152 8 'doIt' 8 '[:each | each item first = Character space ifTrue: [each font: (each font beBold; beItalic)]]' 8 #[37 105 226 0 159 31 161 132 221 9 17 226 4 100 163 97 164 183 106 60 106] #item #first ##(Smalltalk.Character) #space #font #beBold #beItalic #font: 11424 7 257 nil #report 880 nil 131169 nil 34 4 nil nil 1442 1 1 nil 1474 138 144 34 2 1538 #createAt:extent: 34 2 1442 9 55 1442 357 633 11184 1538 #text: 34 1 8 'Column 1' 11184 1666 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 182 0 0 0 87 1 0 0] 8 #() 1728 nil 27 10592 170 192 34 4 11184 8 'variableList' 10592 8 'categoryList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 10416 34 2 8 1140916736 1 11808 834 138 144 34 2 10576 11168 nil 912 nil nil 1 nil nil nil 11808 nil 8 4294902825 1154 0 nil 2178 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 11936 7 257 nil 1154 0 nil 2178 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 11984 7 257 nil 1056 nil nil nil nil nil #noIcons nil nil nil nil nil 1474 138 144 34 3 1538 #createAt:extent: 34 2 1442 1 1 1442 373 695 11808 1538 #basicSelectionsByIndex: 34 1 8 #(1) 11808 1538 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 11808 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 186 0 0 0 91 1 0 0] 8 #() 1728 nil 27 1474 138 144 34 1 1538 #createAt:extent: 34 2 1442 1 1 1442 373 695 10416 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 186 0 0 0 91 1 0 0] 34 3 10592 11184 11808 1728 nil 27 8 'methodFilterTabs' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 1442 1391 1 1442 851 695 8576 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 183 2 0 0 0 0 0 0 96 4 0 0 91 1 0 0] 34 3 10416 410 ##(Smalltalk.Splitter) 34 12 nil 8576 34 2 8 1140850688 1 12608 nil 930 7920 nil 517 nil nil nil 12608 1474 138 144 34 1 1538 #createAt:extent: 34 2 1442 373 1 1442 11 695 12608 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 186 0 0 0 0 0 0 0 191 0 0 0 91 1 0 0] 8 #() 1728 nil 27 8688 1728 nil 27 1728 nil 27 7 false 170 192 880 nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 1442 1 1 1442 2241 695 544 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 91 1 0 0] 34 1 656 1728 nil 27 1746 3 5 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 13040 nil 930 3056 nil 5 nil nil nil 13040 1986 138 144 34 5 3122 3154 8 'SUnit' 1154 0 nil 1186 4 1 1152 8 'doIt' 8 '[Icon fromId: ''icons\UnitTestPlugin.ico'']' 8 #[32 105 45 30 178 106] 983558 ##(Smalltalk.VariableBinding) #Icon ##(Smalltalk.Icon) 8 'icons\UnitTestPlugin.ico' #fromId: 13216 7 1 nil nil 410 ##(Smalltalk.ReferenceView) 34 14 nil 13040 34 2 8 1140850688 131073 13344 nil 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 nil nil nil 13344 1180166 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteSUnitInClassPresenter) #resource_Default_view nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 1442 9 55 1442 2225 635 13344 1666 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 88 1 0 0] 880 1728 nil 27 3122 3154 8 'Class Definition' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 13040 34 2 8 1445007428 1025 13664 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 13410 26337781 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 11 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #editSave 8 '&Save' 9383 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 13858 1 13890 #editUndo 8 '&Undo' 9397 1 nil nil nil 13858 1 13890 #editRedo 8 '&Redo' 9395 1 nil nil nil 13938 4097 13858 1 13890 #editCut 8 'Cu&t' 9393 1 nil nil nil 13858 1 13890 #editCopy 8 '&Copy' 9351 1 nil nil nil 13858 1 13890 #editPaste 8 '&Paste' 9389 1 nil nil nil 13858 1 13890 #editDelete 8 '&Delete' 1629 1 nil nil nil 13938 4097 13858 1 13890 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 1442 193 193 nil 13664 nil 8 4294906183 7170 nil nil 13 nil 170 192 34 4 #normal 1182790 1 ##(Smalltalk.ScintillaTextStyle) 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 14514 77 786694 ##(Smalltalk.IndexedColor) 33554457 14562 33554471 1 nil nil nil nil #callTip nil nil nil 34 256 14528 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 14544 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1639686 ##(Smalltalk.SmalltalkExpressionStyler) 1 nil nil false 138 144 880 170 192 34 2 #default 1641542 1 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 13664 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 880 nil 170 176 880 9215 nil nil nil nil 14562 33554447 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 14528 nil nil nil nil 1 nil 170 192 34 6 1 1510470 2 ##(Smalltalk.ScintillaIndicatorStyle) 1 13664 65025 3 false 1 nil nil nil nil nil nil 3 14978 3 13664 33423361 5 false 3 nil nil nil nil nil nil 5 14978 5 13664 511 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 14514 1029 nil 13410 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 14514 1027 13410 60239 13410 31326207 1 nil nil nil nil #Warning nil nil nil #Error 14514 1031 13410 335 13410 31317503 1 nil nil nil nil #Error nil nil nil nil 1474 138 144 34 8 1538 #createAt:extent: 34 2 1442 9 55 1442 2225 635 13664 1538 #contextMenu: 34 1 13824 13664 1538 #modificationEventMask: 8 #(4607) 13664 1538 #caretPeriod: 8 #(530) 13664 1538 #wordWrap: 8 #(true) 13664 1538 #margins: 34 1 34 3 985158 2 ##(Smalltalk.ScintillaMargin) 1 13664 1 3 nil nil 5 nil 15490 3 13664 33 nil 3 67108863 5 nil 15490 5 13664 1 nil 3 -67108863 5 nil 13664 1538 #tabWidth: 8 #(4) 13664 1538 #maxCompletionListHeight: 8 #(9) 13664 1666 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 88 1 0 0] 8 #() 1728 nil 29 3122 3154 8 'Class Documentation' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 13040 34 2 8 1445007428 1025 15712 13730 nil false 13776 nil 13410 26337781 nil 5 13810 nil true 34 1 13858 1 13890 #editSaveClassComment 8 'Save' 1025 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 14354 nil true 14386 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 1442 193 193 nil 15712 nil 8 4294906183 7170 nil nil 11 nil 170 192 34 4 #normal 14514 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 14514 77 14576 14592 1 nil nil nil nil #callTip nil nil nil 34 256 16032 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 16048 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 14706 1 nil nil nil 15712 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 880 nil 170 176 880 9215 nil nil nil nil 14768 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 16032 nil nil nil nil 1 nil 170 192 34 6 1 14978 1 15712 65025 3 false 1 nil nil nil nil nil nil 3 14978 3 15712 33423361 5 false 3 nil nil nil nil nil nil 5 14978 5 15712 511 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 14514 1029 nil 13410 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 14514 1027 13410 60239 13410 31326207 1 nil nil nil nil #Warning nil nil nil #Error 14514 1031 13410 335 13410 31317503 1 nil nil nil nil #Error nil nil nil nil 1474 138 144 34 8 1538 #createAt:extent: 34 2 1442 9 55 1442 2225 635 15712 1538 #contextMenu: 34 1 15808 15712 1538 #modificationEventMask: 8 #(4607) 15712 1538 #caretPeriod: 8 #(530) 15712 1538 #wordWrap: 8 #(true) 15712 1538 #margins: 34 1 34 3 15490 1 15712 1 3 nil nil 5 nil 15490 3 15712 33 nil 3 67108863 5 nil 15490 5 15712 1 nil 3 -67108863 5 nil 15712 1538 #tabWidth: 8 #(4) 15712 1538 #maxCompletionListHeight: 8 #(9) 15712 1666 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 88 1 0 0] 8 #() 1728 nil 29 3122 3154 8 'Method Source' nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 13040 34 2 8 1445007428 1025 17008 13730 nil false 13776 nil 13410 26337781 nil 5 nil 14354 nil true 14386 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 1442 193 193 nil 17008 nil 8 4294906183 7170 nil nil 13 nil 170 192 34 4 #normal 14514 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 14514 77 14576 14592 1 nil nil nil nil #callTip nil nil nil 34 256 17232 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 17248 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 880 170 192 34 2 #default 14706 1 nil nil nil 17008 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 880 nil 170 176 880 9215 nil nil nil nil 14768 nil nil 65 nil nil 14784 8 '' 3 170 192 34 2 #container 170 192 34 4 #normal 17232 #callTip 17248 nil nil nil nil 1 nil 170 192 34 12 1 14978 1 17008 65025 3 false 1 nil nil nil nil nil nil 3 14978 3 17008 33423361 5 false 3 nil nil nil nil nil nil 5 14978 5 17008 511 1 false 5 nil nil nil nil nil nil 8 'indicator9' 14978 19 17008 33554459 13 nil nil nil nil nil nil nil nil 8 'indicator10' 14978 21 17008 33554459 3 nil nil nil nil nil nil nil nil 8 'indicator8' 14978 17 17008 33554447 1 nil nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 14514 1029 nil 13410 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 14514 1027 13410 60239 13410 31326207 1 nil nil nil nil #Warning nil nil nil #Error 14514 1031 13410 335 13410 31317503 1 nil nil nil nil #Error nil nil nil nil 1474 138 144 34 8 1538 #createAt:extent: 34 2 1442 9 55 1442 2225 635 17008 1538 #modificationEventMask: 8 #(4607) 17008 1538 #hoverTime: 8 #(200) 17008 1538 #caretPeriod: 8 #(530) 17008 1538 #wordWrap: 8 #(true) 17008 1538 #margins: 34 1 34 3 15490 1 17008 61 3 nil nil 5 nil 15490 3 17008 1 nil 3 67108863 nil nil 15490 5 17008 1 nil 3 -67108863 nil nil 17008 1538 #tabWidth: 8 #(4) 17008 1538 #maxCompletionListHeight: 8 #(9) 17008 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 88 1 0 0] 8 #() 1728 nil 29 3122 8 'Comparison' 410 ##(Smalltalk.ShellView) 34 27 nil 13040 34 2 8 1078919168 131073 18304 nil 930 8 4278190080 nil 517 nil nil nil 18304 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 18304 34 2 8 1140850688 131073 18432 nil 13410 26337781 nil 5 13810 nil true 34 5 13858 1 13890 #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 13858 1 13890 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 13858 1 13890 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 13858 1 13890 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 13858 1 13890 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 18432 482 170 176 880 false 170 192 880 nil 1474 138 144 34 2 1538 #createAt:extent: 34 2 1442 1 1 1442 2193 603 18432 1538 #contextMenu: 34 1 18512 18432 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 4 0 0 45 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 18432 34 2 8 1140850688 131073 19040 nil 930 18384 nil 5 nil nil nil 19040 18402 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 19040 34 2 8 1140850945 262145 19136 nil nil nil 5 nil nil nil 19136 nil 8 1684497712 7170 nil nil nil 1474 138 144 34 2 1538 #createAt:extent: 34 2 1442 1 563 1442 1091 41 19136 1538 #text: 34 1 8 '
' 19136 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 1 0 0 33 2 0 0 45 1 0 0] 8 #() 1728 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 19040 34 2 8 1140920580 1025 19440 13730 nil false 13776 nil 13410 26337781 nil 5 nil nil nil 19440 nil 8 4294906183 7170 nil nil 11 nil 170 192 34 12 #indentGuide 14514 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 14514 3 14562 33554445 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 14514 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 14514 77 14576 14592 1 nil nil nil nil #callTip nil nil nil #normal 14514 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 14514 5 nil 13410 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 19680 19616 19696 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 19648 nil nil nil 19600 nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 14706 1 nil nil nil 19440 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 880 nil 170 176 880 9215 nil nil nil nil 14768 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 19568 nil nil nil nil 1 nil 170 192 34 6 8 'indicator2' 14978 5 19440 511 1 false nil nil nil nil nil nil nil 8 'indicator1' 14978 3 19440 33423361 5 false nil nil nil nil nil nil nil 8 'indicator0' 14978 1 19440 33554459 13 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 14514 1029 nil 13410 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 14514 1027 13410 60239 13410 31326207 1 nil nil nil nil #Warning nil nil nil #Error 14514 1031 13410 335 13410 31317503 1 nil nil nil nil #Error nil nil nil nil 1474 138 144 34 7 1538 #createAt:extent: 34 2 1442 1 1 1442 1091 563 19440 1538 #modificationEventMask: 8 #(4607) 19440 1538 #caretPeriod: 8 #(530) 19440 1538 #wordWrap: 8 #(true) 19440 1538 #margins: 34 1 34 3 15490 1 19440 49 3 nil nil nil nil 15490 3 19440 1 nil nil 67108863 nil nil 15490 5 19440 1 nil nil nil nil nil 19440 1538 #canHScroll: 8 #(false) 19440 1538 #maxCompletionListHeight: 8 #(9) 19440 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 25 1 0 0] 8 #() 1728 nil 29 170 192 34 4 19136 8 'beforeTitle' 19440 8 'before' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 1442 1 1 1442 1091 603 19040 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 45 1 0 0] 34 2 19440 19136 1728 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 18432 34 2 8 1140850688 1 20848 nil 13410 66047 nil 517 nil nil nil 20848 1474 138 144 34 1 1538 #createAt:extent: 34 2 1442 1091 1 1442 11 603 20848 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 33 2 0 0 0 0 0 0 38 2 0 0 45 1 0 0] 8 #() 1728 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 18432 34 2 8 1140850688 131073 21088 nil 930 18384 nil 5 nil nil nil 21088 18402 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 21088 34 2 8 1140850945 262145 21184 nil nil nil 5 nil nil nil 21184 nil 8 1684497712 7170 nil nil nil 1474 138 144 34 2 1538 #createAt:extent: 34 2 1442 1 563 1442 1093 41 21184 1538 #text: 34 1 8 '
' 21184 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 1 0 0 34 2 0 0 45 1 0 0] 8 #() 1728 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 21088 34 2 8 1140920580 1025 21488 13730 nil false 13776 nil 13410 26337781 nil 5 nil nil nil 21488 nil 8 4294906183 7170 nil nil 11 nil 170 192 34 12 #indentGuide 14514 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 14514 3 19632 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 14514 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 14514 77 14576 14592 1 nil nil nil nil #callTip nil nil nil #normal 14514 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 14514 5 nil 13410 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 21712 21664 21728 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 21680 nil nil nil 21648 nil nil 19746 19776 170 192 34 2 #default 14706 1 nil nil nil 21488 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 880 nil 170 176 880 9215 nil nil nil nil 14768 nil nil 65 nil nil nil 19872 3 170 192 34 2 #container 21616 nil nil nil nil 1 nil 170 192 34 6 8 'indicator2' 14978 5 21488 511 1 false nil nil nil nil nil nil nil 8 'indicator0' 14978 1 21488 33554459 13 false nil nil nil nil nil nil nil 8 'indicator1' 14978 3 21488 33423361 5 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 14514 1029 nil 13410 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 14514 1027 13410 60239 13410 31326207 1 nil nil nil nil #Warning nil nil nil #Error 14514 1031 13410 335 13410 31317503 1 nil nil nil nil #Error nil nil nil nil 1474 138 144 34 7 1538 #createAt:extent: 34 2 1442 1 1 1442 1093 563 21488 1538 #modificationEventMask: 8 #(4607) 21488 1538 #caretPeriod: 8 #(530) 21488 1538 #wordWrap: 8 #(true) 21488 1538 #margins: 34 1 34 3 15490 1 21488 49 3 nil nil nil nil 15490 3 21488 1 nil nil 67108863 nil nil 15490 5 21488 1 nil nil nil nil nil 21488 1538 #canHScroll: 8 #(false) 21488 1538 #maxCompletionListHeight: 8 #(9) 21488 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 34 2 0 0 25 1 0 0] 8 #() 1728 nil 29 170 192 34 4 21184 8 'afterTitle' 21488 8 'after' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 1442 1101 1 1442 1093 603 21088 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 38 2 0 0 0 0 0 0 72 4 0 0 45 1 0 0] 34 2 21488 21184 1728 nil 27 1728 nil 27 170 192 34 2 18432 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 13810 nil true 34 4 13858 1 13890 #selectUpper 8 'Select &upper' 1 1 nil nil nil 13858 1 13890 #selectLower 8 'Select &lower' 1 1 nil nil nil 13938 4097 13858 1 13890 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 31289 nil nil 13810 nil true 34 3 13858 1 13890 #character 8 '&Character' 1 1 nil nil nil 13858 1 13890 #word 8 '&Word' 1 1 nil nil nil 13858 1 13890 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 31291 nil nil 13810 nil true 34 1 13858 1 13890 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 31293 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1474 138 144 34 3 1538 #createAt:extent: 34 2 1442 9 55 1442 2225 635 18304 1538 #text: 34 1 8 'Comparison' 18304 1538 #updateMenuBar 880 18304 1666 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 88 1 0 0] 34 1 18432 1728 nil 27 17008 170 192 34 10 13664 8 'classDefinition' 17008 8 'methodSource' 15712 8 'classDocumentation' 13344 8 'sunit' 18304 8 'comparisonTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 13040 34 2 8 1140916736 1 23776 834 138 144 34 5 13632 15680 16976 13184 18288 nil 912 nil nil 1 nil nil nil 23776 nil 8 4294902825 1154 0 nil 2178 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 23904 7 257 nil 1154 0 nil 2178 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 23952 7 257 nil 1056 nil nil nil nil nil #smallIcons nil nil nil nil nil 1474 138 144 34 3 1538 #createAt:extent: 34 2 1442 1 1 1442 2241 697 23776 1538 #basicSelectionsByIndex: 34 1 8 #(3) 23776 1538 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 23776 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 92 1 0 0] 8 #() 1728 nil 27 1474 138 144 34 1 1538 #createAt:extent: 34 2 1442 1 705 1442 2241 697 13040 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 96 1 0 0 96 4 0 0 188 2 0 0] 34 6 13664 15712 17008 13344 18304 23776 1728 nil 27 1746 3 5 true 170 192 34 4 13040 8 'textAreaTabs' 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 24464 nil 930 7920 nil 517 nil nil nil 24464 1474 138 144 34 1 1538 #createAt:extent: 34 2 1442 1 695 1442 2241 11 24464 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 91 1 0 0 96 4 0 0 96 1 0 0] 8 #() 1728 nil 27 8 'splitter' nil 1474 138 144 34 1 1538 #createAt:extent: 34 2 1442 7679 21 1442 2241 1401 416 1666 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 95 19 0 0 198 2 0 0] 34 3 544 24464 13040 1728 nil 27 )! !
!JadeiteBrowserPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

