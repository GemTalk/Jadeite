"Filed out from Dolphin Smalltalk 7"!

RowanSystemBrowserPresenter subclass: #JadeiteProjectsBrowserPresenter
	instanceVariableNames: 'projectListPresenter stonCritical projectInfoTab projectLabel projectDictionaryTabs comparisonPresenter comparisonTab definedClassPackageText definedMethodPackageText methodCategoryText autoCommit statusBarText'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteProjectsBrowserPresenter guid: (GUID fromString: '{258266f3-948d-47d3-afa6-c6d0c941ddc5}')!
JadeiteProjectsBrowserPresenter comment: 'Use subclass JadeiteBrowserPresenter now which integrates the dictionary browser. 
In packages pane, show projects & packages. Remove class categories.
'!
!JadeiteProjectsBrowserPresenter categoriesForClass!Unclassified! !
!JadeiteProjectsBrowserPresenter methodsFor!

aboutToChange: aSelectionChangingEvent
	aSelectionChangingEvent value ifTrue: [
		aSelectionChangingEvent value: self isOkayToChange.
		self resetCategoryText.
	].
	
!

addNoneProject 

	"ignore in this browser"!

addPackage
	| projectService newPackageName |
	true
		ifTrue: 
			[self rowanFixMe.
			^MessageBox notify: 'Packages cannot be added in RowanV2.0 yet. Sorry.'
				caption: 'Unavailable operation'].
	(newPackageName := Prompter prompt: 'Enter new package name:') isNil ifTrue: [^self].
	projectService := projectListPresenter selection.
	projectService addPackageNamed: newPackageName using: self!

addPackageDictionaryInfoTo: aStream

	"Private - projects don't write themselves to string"!

addSubclass
	| classService answerService |
	classService := self selectedClass ifNil: [^self].
	classService
		command: #subclassCreationTemplate;
		commandArgs: Array new. 
	answerService := (self issueCommand: (Array with: classService)) first.
	classDefinitionPresenter
		ensureVisible;
		value: answerService answer!

addVariableAccessors
	| cachedSelections |
	self confirmOverwriteAccessor ifFalse: [^self].
	(cachedSelections := self methodFilterListPresenter selections) do: 
			[:variable |
			| sourceStream classService |
			classService := self selectedClass.
			sourceStream := self getterMethodSourceFor: variable.
			classService
				saveMethod: sourceStream contents
				category: 'accessing'
				session: self gciSession.
			sourceStream := self setterMethodSourceFor: variable.
			classService
				saveMethod: sourceStream contents
				category: 'accessing'
				session: self gciSession].
	self methodFilterListPresenter selections: cachedSelections!

allClasses
	| browserService |
	browserService := RowanBrowserService new.
	browserService
		command: #allClasses.
	self issueCommand: (Array with: browserService).
	^browserService allClasses ifNil:[Array new]!

autoCommit
	"Private - for testing"

	^autoCommit value!

autoCommit: boolean
	autoCommit value: boolean.
	gciSession autoCommit: boolean!

basicAddMethodCategory: string
	| service |
	(self categoryListPresenter list includes: string)
		ifFalse: 
			[service := self selectedClass
						command: #addCategory:;
						commandArgs: (Array with: string).
			service meta: self isClassSideSelected. 
			self issueCommand: (Array with: service)].
	self selectCategoriesNamed: (Array with: string)!

basicCopyClass: oldClassService to: newClassName
	oldClassService
		command: #copyClassTo:;
		commandArgs: (Array with: newClassName).
	self issueCommand: (Array with: oldClassService).
	self updateAfterFindClass: (RowanClassService new name: newClassName)!

basicOnDropClassList: dragDropSession
	| classService failedCompilations newSelections |
	failedCompilations := OrderedCollection new.
	classService := dragDropSession suggestedTarget.
	classService meta: self isClassSideSelected.
	dragDropSession dragObjects do: 
			[:dragDropObject |
			
			[dragDropObject object source ifNil: [self updateService: dragDropObject object].
			classService
				saveMethod: dragDropObject object source
				category: dragDropObject object category
				session: gciSession]
					on: GsCompileError
					do: [:ex | failedCompilations add: dragDropObject object]].
	failedCompilations isEmpty
		ifTrue: 
			[self selectedClass == classService
				ifFalse: 
					[self isHierarchyTabSelected
						ifTrue: [self selectClassInClassHierarchyNamed: classService name]
						ifFalse: [self selectClassNamed: classService name]].
			newSelections := methodListPresenter list select: 
							[:methodService |
							(dragDropSession dragObjects collect: [:ea | ea object selector]) includes: methodService selector].
			methodListPresenter selections: newSelections].
	^failedCompilations!

basicProjectTabLabel
	| label |
	projectListPresenter selections isEmpty ifTrue: [^'Projects'].
	label := projectListPresenter selection name.
	packageListPresenter list isEmpty ifTrue: [^label].
	packageListPresenter selections isEmpty ifTrue: [^label].
	packageListPresenter selections size > 1 ifTrue: [^label].
	label := packageListPresenter selection name.
	^self selectedClass ifNil: [label] ifNotNil: [self selectedClass name]!

basicRemoveClass: selection
	| packageService parentNode |
	self isHierarchyTabSelected
		ifTrue: [parentNode := classHierarchyPresenter model parentNodeOf: selection].
	packageService := packageListPresenter selection.
	packageService
		command: #removeClass:;
		commandArgs: (Array with: selection).
	self issueCommand: (Array with: packageService).
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

basicRemoveMethodCategories
	| service |
	service := self selectedClass
				command: #removeCategories:;
				commandArgs: (Array with: categoryListPresenter selections).
	self issueCommand: (Array with: service)!

basicRemoveMethods
	| service presenter |
	presenter := self isClassListTabSelected
				ifTrue: [classListPresenter]
				ifFalse: [classHierarchyPresenter].
	service := presenter selectionIfNone: [^self].
	service meta: self isClassSideSelected.
	self removeMethods: (Array with: service)!

basicRenameCategoryFrom: old to: new
	| service |
	new isEmpty ifTrue: [^MessageBox notify: 'New category name cannot be blank'].
	service := self selectedClass
				command: #renameCategoryFrom:to:;
				commandArgs: (Array with: old with: new).
	self issueCommand: (Array with: service).
	categoryListPresenter selection: new!

basicRenameClass: classService to: newName
	| serviceArray oldName browser answeringService |
	oldName := classService name.
	classService
		command: #renameClass:to:;
		commandArgs: (Array with: classService name with: newName).
	[serviceArray := self issueCommand: (Array with: classService)] on: GsCompileError
		do: 
			[:ex |
			^MessageBox
				notify: 'Compilation error during rename class. Class may be referenced in its hierarchy"

'
						, ex descriptiveText].
	self updateServices: packageListPresenter selections.
	self refreshClassListOrHierarchy.
	classListPresenter resetSelection. 
	self selectClassNamed: newName.
	(serviceArray detect: [:service | service isAnsweringService]) answer isEmpty ifTrue: [^self].
	browser := JadeiteRenameClassMethodListBrowser showOnSession: gciSession.
	browser primaryPresenter
		findString: newName;
		newClassName: newName.
	answeringService := serviceArray detect: [:service | service isAnsweringService].
	browser primaryPresenter methods: answeringService answer selecting: classService name.
	browser updateCaption: 'Methods updated after renaming ' , oldName , ' to ' , newName.
	^browser!

basicUnloadProjects: projectNames
	| browserService |
	browserService := RowanBrowserService new.
	browserService
		command: #unloadProjectsNamed:;
		commandArgs: (Array with: projectNames).
	self issueCommand: (Array with: browserService).
	packageListPresenter model: ListModel new.
	classListPresenter model: ListModel new.
	categoryListPresenter model: (ListModel new searchPolicy: SearchPolicy equality).
	variableListPresenter model: (ListModel new searchPolicy: SearchPolicy equality).
	methodListPresenter model: ListModel new. 
	self refreshGlobalSelections!

behaviorIdentifier
	^self selectedClass behaviorIdentifier!

browseHierarchyImplementors
	^self browseHierarchyImplementorsOf: self selectedMethodName
		className: methodListPresenter selections first className!

browseHierarchySenders
	^self browseHierarchySendersOf: self selectedMethodName
		className: methodListPresenter selection className!

browseSelectedClass
	^self browseSelectedClassIn: methodSourcePresenter newTab: Keyboard default isCtrlDown!

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
		'&File out categories//fileOutCategories'
	)
!

categoryListPresenter
	^categoryListPresenter!

classCommentPresenter
	"for test access" 
	^classCommentPresenter!

classDefinitionPresenter

	^classDefinitionPresenter!

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

classHierarchyTabs
	^classHierarchyTabs!

cleanupComparisonBrowser
	comparisonPresenter
		beforeTitle: String new;
		afterTitle: String new;
		compare: String new with: String new!

clearFilterLists
	categoryListPresenter model: (ListModel new searchPolicy: SearchPolicy equality).
	variableListPresenter model: (ListModel new searchPolicy: SearchPolicy equality).!

clearMethodBreakpoints
	^JadePresenter clearMethodBreakpoints: methodListPresenter selections in: self gciSession!

comparisonTab
	^comparisonTab
		ifNil: 
			[comparisonTab := self textTabs
						detect: [:each | (each class canUnderstand: #text) ifTrue: [each text = 'Comparison'] ifFalse: [each = 'Comparison']]]!

confirmCategoryRemoval: selections
	| ws verbiage |
	ws := WriteStream on: String new.
	verbiage := categoryListPresenter selections size = 1 ifTrue: ['category'] ifFalse: ['categories'].
	ws
		nextPutAll: 'Really delete method ';
		nextPutAll: verbiage;
		space.
	selections do: 
			[:category |
			ws
				nextPutAll: category;
				space].
	ws
		nextPutAll: 'and ';
		nextPutAll: methodListPresenter list size printString;
		nextPutAll: ' methods?'.
	^(MessageBox confirm: ws contents) == true!

confirmOverwriteAccessor
	| existing selectors |
	existing := OrderedCollection new.
	selectors := self selectedClass methods collect: [:methodService | methodService selector].
	self methodFilterListPresenter selections do: 
			[:variable |
			| setter |
			(selectors includes: variable asSymbol) ifTrue: [existing add: variable].
			setter := (variable , ':') asSymbol.
			(selectors includes: setter) ifTrue: [existing add: setter]].
	existing isEmpty
		ifFalse: 
			[^MessageBox
				confirm: 'These methods will be overridden - ' , existing asArray printString , ' Continue?'].
	^true!

containedDictionaryLabel
	| containedDictionary |
	containedDictionary := 'Go To Containing Dictionary'.
	self selectedClass
		ifNotNil: [:classService | containedDictionary := containedDictionary , ' (' , classService dictionaryName , ')'].
	^containedDictionary!

copyClass
	| oldClassService newClassName validClassNameSelected |
	oldClassService := self selectedClass ifNil: [^MessageBox notify: 'Class must be selected'].
	validClassNameSelected := false.
	[validClassNameSelected] whileFalse: 
			[(newClassName := Prompter
						on: oldClassService name
						prompt: 'Copy ' , oldClassService name , ' to:'
						caption: 'Copy class') isNil
				ifTrue: [^self].
			validClassNameSelected := self symbolExists: newClassName.
			validClassNameSelected ifFalse: [MessageBox notify: 'Symbol exists. Please retry.']].
	self basicCopyClass: oldClassService to: newClassName!

copyProjectInfo
	projectInfoTab selection last ifNil:[^self]. 
	(projectInfoTab selection first perform: projectInfoTab selection last asSymbol) displayString copyToClipboard!

createComponents
	super createComponents.
	projectListPresenter := self add: ListPresenter new name: 'projectList'.
	packageListPresenter := self add: ListPresenter new name: 'packagesList'.
	comparisonPresenter := self add: JadeiteDifferencesPresenter new name: 'comparisonTab'.
	definedClassPackageText := self add: Presenter new name: 'definedPackageClassText'.
	definedMethodPackageText := self add: Presenter new name: 'definedPackageMethodText'.
	methodCategoryText := self add: TextPresenter new name: 'categoryMethodText'.
	statusBarText := self add: TextPresenter new name: 'statusBarField'!

createSchematicWiring
	super createSchematicWiring.
	self
		createSchematicWiringForProjectList;
		createSchematicWiringForMethodFilterTabs.
	autoCommit
		when: #valueChanged
		send: #updateAutoCommit
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

createSchematicWiringForClassHierarchyTabs
	classHierarchyTabs
		when: #currentCardChanging:
			send: #aboutToChange:
			to: self;
		when: #currentCardChanged
			send: #refreshClassListOrHierarchy
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

createSchematicWiringForInstanceClassTabs
	instanceClassTabs
		when: #currentCardChanging:
			send: #aboutToChange:
			to: self;
		when: #currentCardChanged
			send: #refreshClass
			to: self!

createSchematicWiringForMethodCategoryList
	categoryListPresenter
		when: #dragOver:
			send: #onDragOverMethodCategory:
			to: self;
		when: #drop:
			send: #onDropOnMethodCategory:
			to: self;
		when: #keyTyped:
			send: #delayUpdate
			to: self;
		when: #selectionChanging:
			send: #aboutToChange:
			to: self;
		when: #selectionChanged
			send: #updateTabLabel
			to: self;
		when: #selectionChanged
			send: #selectMethodSourceTab
			to: self;
		when: #selectionChanged
			send: #refreshMethodsOn:
			to: self
			with: methodListPresenter!

createSchematicWiringForMethodFilterTabs
	methodFilterTabs
		when: #currentCardChanged
			send: #filterTabChanged
			to: self;
		when: #currentCardChanged
			send: #refreshMethodsOn:
			to: self
			with: methodListPresenter!

createSchematicWiringForMethodList
	methodListPresenter
		when: #drag: 				send: #onDragMethod: 			to: self; 
		when: #dragCut: 			send: #onDragCutMethod: 			to: self; 
		when: #keyTyped: 			send: #delayUpdate 				to: self; 
		when: #aboutToDisplayMenu: 	send: #updateMethodMenu:		to: self;
		when: #selectionChanging:		send: #aboutToChange:			to: self; 
		when: #keyTyped: 			send: #selectServiceStartingWith: 	to: methodListPresenter; 
		when: #selectionChanged 		send: #methodSelectionChanged 	to: self!

createSchematicWiringForPackageDictionaryTabs

	"Yes, I know. Subclasses should not remove behavior."!

createSchematicWiringForPackageList

	packageListPresenter
		when: #'drag:'				send: #'onDragPackageList:'		to: self;
		when: #'dragCut:'			send: #'onDragCutPackageList:'		to: self;
		when: #'dragOver:'			send: #'onDragOverPackageList:'	to: self;
		when: #'drop:'				send: #'onDropOnPackageList:'		to: self;
		when: #'keyTyped:'			send: #'delayUpdate'				to: self;
		when: #'selectionChanging:'	send: #'aboutToChange:'			to: self;
		when: #'selectionChanging:'	send: #'releasedReferencedServices:'	to: self;
		when: #'selectionChanged'		send: #'updatePackage' 			to: self;
		when: #keyTyped: 			send: #selectServiceStartingWith: 	to: packageListPresenter
!

createSchematicWiringForProjectDictionaryList
	projectDictionaryTabs
		when: #currentCardChanging:
			send: #aboutToChange:
			to: self;
		when: #currentCardChanged
			send: #projectDictionaryChanged
			to: self;
		yourself!

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

createSchematicWiringForVariableList
	variableListPresenter
		when: #selectionChanging: send: #aboutToChange: to: self;
		when: #selectionChanged send: #selectMethodSourceTab to: self;
		when: #selectionChanged send: #refreshMethodsOn: to: self with: methodListPresenter!

createStateEntry

	^projectDictionaryTabs currentCard == projectListPresenter view!

definedClassMenuItemLabel
	| definedLabel |
	definedLabel := 'Go To Defining Package'.
	self selectedClass
		ifNotNil: 
			[:classService |
			classService definedPackageName ifNil: [self updateService: self selectedClass].
			classService definedPackageName = RowanService notRowanizedPackageName
				ifFalse: [definedLabel := definedLabel , ' (' , classService definedPackageName , ')']].
	^definedLabel!

definedMethodMenuItemLabel
	| definedLabel |
	definedLabel := 'Go To Defining Package'.
	methodListPresenter selection
		ifNotNil: 
			[:methodService |
			methodService definedPackage = RowanService notRowanizedPackageName
				ifFalse: [definedLabel := definedLabel , ' (' , methodService definedPackage , ')']].
	^definedLabel!

displayMultipleCategories
	"display a generic indication of multiple categories unless all selected methods
	are in the same category"

	| categories |
	categories := (methodListPresenter selections collect: [:methodService | methodService category])
				asSet.
	categories size = 1
		ifTrue: [methodCategoryText value: 'Category: ' , categories anyOne]
		ifFalse: [methodCategoryText value: 'Categories: (Multiple)']!

editFind
	| tab |
	tab := textAreaTabs currentCard.
	tab setFocus.
	(tab class canUnderstand: #editFind) ifTrue: [^tab editFind]!

editReplace
	View focus == methodSourcePresenter view ifTrue: [View focus findReplace]!

editSaveClassComment
	| classService |
	classService := self selectedClass ifNil: [^self].
	classService
		command: #classComment:;
		commandArgs: (Array with: classCommentPresenter value trimBlanks).
	self issueCommand: (Array with: classService).
	classCommentPresenter ensureVisible.
	self refreshFromServer.
	classCommentPresenter view
		isModified: false;
		backcolor: JadeiteTextStyles default colorForNoEdits!

expandHierarchyOneLevelAt: classService
	Cursor wait showWhile: 
			[classService command: #oneLevelClassHierarchy.
			self issueCommand: (Array with: classService).
			self selectClassNamed: classService name.
			self classHierarchyPresenter view expandAll]!

fileOutCategories
	| path suggestedFileName classSide |
	MessageBox notify: 'Filein/fileout are not Rowan-ready in this version'
		caption: 'Filein/fileout notification'.
	true ifTrue: [^self].
	"note that the code below should work. Rowan issue is problem"
	classSide := self selectedClass meta ifTrue: ['class_'] ifFalse: [String new].
	suggestedFileName := categoryListPresenter selections size = 1
				ifTrue: [self selectedClass name , '_' , classSide , categoryListPresenter selection]
				ifFalse: [self selectedClass name , classSide , 'categories'].
	suggestedFileName := suggestedFileName copyWithout: $*.
	path := FileSaveDialog new
				caption: 'File Out Categories';
				fileTypes: self fileTypes;
				defaultExtension: self defaultFileExtension;
				value: suggestedFileName;
				overwritePrompt;
				showModal.
	path ifNotNil: [self fileOutCategoriesOnPath: path]!

fileOutCategoriesOnPath: path
	| file service answeringService |
	service := self selectedClass.
	service
		command: #fileoutCategories:;
		commandArgs: (Array with: categoryListPresenter selections).
	answeringService := (self issueCommand: (Array with: service)) first.
	file := FileStream write: path.
	[file nextPutAll: answeringService answer] ensure: [file close]!

fileOutClass
	| path suggestedFileName classSide |
	MessageBox notify: 'Filein/fileout are not Rowan-ready in this version'
		caption: 'Filein/fileout notification'.
	true ifTrue: [^self].
	"note that the code below should work. Rowan issue is problem"
	suggestedFileName := self selectedClass name.
	path := FileSaveDialog new
				caption: 'File Out Class';
				fileTypes: self fileTypes;
				defaultExtension: self defaultFileExtension;
				value: suggestedFileName;
				overwritePrompt;
				showModal.
	path ifNotNil: [self fileOutClassOnPath: path]!

fileOutClassOnPath: path
	| file answeringService service |
	service := self selectedClass.
	service command: #fileoutClass.
	answeringService := (self issueCommand: (Array with: service)) first.
	file := FileStream write: path.
	[file nextPutAll: answeringService answer] ensure: [file close]!

fileOutMethods
	| path suggestedFileName classSide |
	MessageBox notify: 'Filein/fileout are not Rowan-ready in this version'
		caption: 'Filein/fileout notification'.
	true ifTrue:[^self].
	"note that the code below should work. Rowan issue is problem"
	classSide := self selectedClass meta ifTrue: ['class_'] ifFalse: [String new].
	suggestedFileName := methodListPresenter selections size = 1
				ifTrue: 
					[methodListPresenter selection className , '_' , classSide
						, methodListPresenter selection selector asString]
				ifFalse: [methodListPresenter selections first className , '_' , classSide , 'methods'].
	path := FileSaveDialog new
				caption: 'File Out Method';
				fileTypes: self fileTypes;
				defaultExtension: self defaultFileExtension;
				value: suggestedFileName;
				overwritePrompt;
				showModal.
	path ifNotNil: [self fileOutMethodsOnPath: path]!

fileOutMethodsOnPath: path
	| file answeringService service |
	service := self selectedClass.
	service
		command: #fileoutMethods:;
		commandArgs: (Array with: methodListPresenter selections).
	answeringService := (self issueCommand: (Array with: service)) first.
	file := FileStream write: path.
	[file nextPutAll: answeringService answer] ensure: [file close]!

filterTabChanged
	self isClassSelected
		ifTrue: [self updateService: self selectedClass]
		ifFalse: 
			[self clearFilterLists.
			^self].
	self populateFilterList.
	self isCategoryTabSelected
		ifTrue: 
			[^methodListPresenter selectionOrNil
				ifNil: [self selectMethodSourceTab]
				ifNotNil: 
					[:methodService |
					self selectCategoryFrom: methodService.
					self selectMethodSourceTab]].
	methodListPresenter selectionOrNil ifNotNil: [self selectMethodSourceTab]!

findClass
	| find |
	self isOkayToChange ifFalse:[^self]. 
	find := JadeiteFindClassDialog showModal: 'DefaultView' on: self allClasses.
	find ifNotNil: [self updateAfterFindClass: find]!

findMethod
	self selectedClass isNil ifTrue: [^self].
	^self class
		findMethodIn: gciSession
		class: self selectedClass
		presenter: self!

findMethod: selector
	"assume we have a populated method list"

	| methodService |
	methodService := methodListPresenter list detect: [:service | service selector = selector]
				ifNone: [^self].
	self isCategoryTabSelected
		ifTrue: [categoryListPresenter selection: methodService category]
		ifFalse: [variableListPresenter selection: nil].
	methodListPresenter selections: (Array with: methodService)!

findRemovedServices
	| browserService |
	browserService := RowanBrowserService new
				command: #findRemovedServices:;
				commandArgs: (Array with: BrowserUpdate current activeServices asArray).
	BrowserUpdate current issueCommands: (Array with: browserService) session: self gciSession!

gciSession: aGciSession
	super gciSession: aGciSession.
	autoCommit := ValueHolder with: aGciSession autoCommit!

getterMethodSourceFor: variable
	| sourceStream |
	sourceStream := WriteStream on: String new.
	sourceStream
		nextPutAll: variable;
		cr;
		tab;
		nextPut: $^;
		nextPutAll: variable.
	^sourceStream!

getViews
	classHierarchyTabs := self view viewNamed: 'classHierarchyTabs'.
	instanceClassTabs := self view viewNamed: 'instanceClassTabs'.
	methodFilterTabs := self view viewNamed: 'methodFilterTabs'.
	textAreaTabs := self view viewNamed: 'textAreaTabs'.!

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
	self issueCommand: (Array with: service).
	MessageBox notify: 'Project ' , projectName , ' committed to local repository!!'.
	self refreshFromServer. !

gotoClass
	JadePresenter browseClassIn: self gciSession!

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

gotoClassDefinedPackageViaButton
	^self gotoClassDefinedPackage!

gotoMethodDefinedPackage
	"find will go to the defined package of the selected class"

	| selectedCategory selectedMethod className |
	selectedCategory := categoryListPresenter selectionIfNone: [].
	selectedMethod := methodListPresenter selectionIfNone: [^self].
	className := self selectedClass name.
	self selectClassListTab.
	self gotoProjectNamed: selectedMethod projectName.
	self gotoPackageNamed: selectedMethod definedPackage.
	self selectClassNamed: className.
	selectedCategory ifNotNil: [:category | categoryListPresenter selection: category].
	methodListPresenter selection: (methodListPresenter list
				detect: [:methodService | methodService selector = selectedMethod selector])	"It better be there".
	self updateMenuBar. "to refresh method menu"!

gotoMethodDefinedPackageViaButton
	^self gotoMethodDefinedPackage!

gotoPackageNamed: packageName
	| packageService |
	packageService := packageListPresenter list detect: [:service | service name = packageName]
				ifNone: [^self].
	packageListPresenter selections: (Array with: packageService)!

gotoProjectNamed: projectName
	| projectService  |
	projectService := projectListPresenter list
				detect: [:service | service name = projectName]
				ifNone: 
					[^self].
	projectListPresenter selections: (Array with: projectService).
	!

hasCategorySelected

	^categoryListPresenter selections notEmpty!

hasExactlyOneCategorySelected

	^categoryListPresenter selections size = 1!

hierarchyClassDoubleClicked
	self expandHierarchyOneLevelAt: classHierarchyPresenter selection!

initialize
	super initialize.
	stonCritical := Semaphore forMutualExclusion.!

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

isMethodSourceTabSelected
	^textAreaTabs currentCard name = 'methodSource'!

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

isSourceTabSelected

	^textAreaTabs currentCard name = 'methodSource'.
!

isSunitTabSelected
	^self textAreaTabs currentCard name = 'sunit'!

jadeDebug
	View focus name = 'methodSource' ifFalse: [^self runMethodTests].
	^super jadeDebug!

jadeDisplay
	View focus == methodSourcePresenter view ifFalse: [^self].
	^super jadeDisplay!

jadeExecute
	View focus == methodSourcePresenter view ifFalse: [^self].
	^super jadeExecute!

jadeMenuStrings
	false ifTrue: [
		self abortTransaction; commitTransaction; newBrowser; addSystemBrowser; maximizeCode; findClass; gotoClass; refreshFromServer; exit.
	]. 
	^#(
		'&Jadeite'
		'&Abort Transaction//abortTransaction'
		'&Commit Transaction//commitTransaction' 
		'-'
		'&New Projects Browser/Ctrl+N/newBrowser'
		'&New Projects Tab/Ctrl+T/addSystemBrowser'
		'&Maximize Code/Ctrl+M/maximizeCode'
		'-'
		'&Find Class.../Ctrl+Shift+F/findClass' 
		'&Go To Class In New Browser.../Ctrl+Shift+G/gotoClass' 
		'&Refresh/Ctrl+R/refreshFromServer'
		'-'
		'E&xit/Shift+F4/exit'
	).
!

loadProjects
	self loadProjectsFrom: self.
	self findRemovedServices!

methodCategoryText
	^methodCategoryText!

methodListPresenter
	^methodListPresenter!

methodListSelection

	^methodListPresenter selectionOrNil!

methodMenuBreak: aMenu
	| selection |
	methodSourcePresenter view isModified ifTrue: [^self].
	selection := methodListPresenter selectionOrNil.
	selection ifNil: [^self].
	selection appendToSourceMenu: aMenu presenter: methodSourcePresenter!

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
				clearMethodBreakpoints;
				removeMethods;
				runMethodTests;
				fileOutMethods;
				findMethod;
				runMethodTests;
				gotoMethodDefinedPackage;
				runAll;
				runSelected].
	^#('&Methods' 'Browse &Implementors//browseImplementors' 'Browse Implementors of ...//browseImplementorsOf' 'Browse &Senders//browseSenders' 'Browse Senders of ...//browseSendersOf' '-' 'Browse Hierarchy Implementors//browseHierarchyImplementors' 'Browse Hierarchy Senders//browseHierarchySenders' '-' 'Browse Methods &Containing ...//browseMethodsContaining' 'Browse Literal References ...//browseLiteralReferences' 'Browse Selected Methods//browseSelectedMethods' 'Browse Method History//browseMethodHistory' '-' 'Browse Breakpoints//browseBreakpoints' 'Clear Method Breakpoints//clearMethodBreakpoints' '-' 'Find Method .../Ctrl+Shift+M/findMethod' '-' '&Remove Method(s) ...//removeMethods' '-' 'Run All Tests/Ctrl+Shift+A/runAll' 'Run Selected Test(s)/Ctrl+Shift+S/runMethodTests' 'Debug Selected &Test(s)/Ctrl+B/runMethodTests' '-' 'Go To Defining Package//gotoMethodDefinedPackage')!

methodSourcePresenter: anObject
	methodSourcePresenter := anObject!

moveMethods: methodServices toCategory: targetCategory
	| classService |
	classService := self selectedClass.
	self selectCategoriesNamed: (categoryListPresenter selections copyWith: targetCategory).
	classService
		command: #moveMethods:to:;
		commandArgs: (Array with: methodServices with: targetCategory).
	self issueCommand: (Array with: classService).
	self selectMethodsFrom: classService!

newBrowser
	| classService selector |
	classService := self selectedClass.
	selector := methodListPresenter selectionOrNil ifNotNil: [:methodService | methodService selector].
	^self openProjectBrowserOn: classService selector: selector!

onDragClass: aSession
	| className |
	className := self selectedClass name.
	^super onDragClass: aSession className: className
!

onDragClassHierarchy: aSession
	| className |
	className := classHierarchyPresenter selection name.
	^super onDragClass: aSession className: className!

onDropMethodsOnClassHierarchy: aSession
	^self onDropOnClassList: aSession!

onDropOnClassList: dragDropSession
	| failedCompilations |
	failedCompilations := self basicOnDropClassList: dragDropSession.
	failedCompilations isEmpty
		ifFalse: 
			[MessageBox notify: 'Methods failing compilation: '
						, (failedCompilations collect: [:methodService | methodService selector]) asArray printString]!

onDropOnMethodCategory: aSession
	| methodServices targetCategory |
	methodServices := aSession dragObjects collect: [:each | each format: #method].
	targetCategory := aSession suggestedTarget trimBlanks.
	self moveMethods: methodServices toCategory: targetCategory!

onSetFocus: aView stack: aString

	"no need for constant trips to the server"!

onViewClosed
	"the sunitPresenter doesn't seem to get it's events cleaned up on 
	a normal window exit. Help it out."

	super onViewClosed.
	BrowserUpdate current logComment: 'Closing Projects Browser {' , self identityHash printString, '}'.
	BrowserUpdate current removeEventsTriggeredFor: sunitPresenter methodListPresenter.
	BrowserUpdate current removeEventsTriggeredFor: self!

onViewOpened
	"copied to RowanDebugger"

	super onViewOpened.
	BrowserUpdate current logComment: 'Opening Projects Browser {' , self identityHash printString , '}'.
	self registerPresentersForUpdates.
	projectListPresenter view contextMenu: self projectMenu.
	self setupPackageMenu.
	self updateMenuBar.
	self updateProjects.
	self updateAutoCommit.
	definedClassPackageText view isMultiline: false.
	definedClassPackageText view alignment: #left.
	definedMethodPackageText view isMultiline: false.
	definedMethodPackageText view alignment: #left!

pkgsMenuStrings
	0 == 1
		ifTrue: 
			[self
				savePackage;
				unloadPackage].
	^#('&Packages' 
	'&Write Package...//savePackage'
	'&Unload Package...//unloadPackage')!

populateFilterList
	| listModel |
	self selectedClass ifNil: [^self].	"can legitimately be nil during test run setUp"
	listModel := ListModel new searchPolicy: SearchPolicy equality.
	self isCategoryTabSelected
		ifTrue: 
			[listModel addAll: self selectedClass categories.
			categoryListPresenter model: ((ListModel on: listModel asSortedCollection asOrderedCollection)
						searchPolicy: SearchPolicy equality)]
		ifFalse: 
			[listModel addAll: self selectedClass variables.
			variableListPresenter model: ((ListModel on: listModel asSortedCollection asOrderedCollection)
						searchPolicy: SearchPolicy equality)]!

postOkToChangeEvent
	| service |
	service := self isClassListTabSelected
				ifTrue: [classListPresenter selectionIfNone: [^self]]
				ifFalse: [classHierarchyPresenter selectionIfNone: [^self]].
	service ifNil:[^self]. 
	classDefinitionPresenter value: service template.
	self resetClassDefinitionPane.
	self sundryCleanup!

projectChanges
	projectListPresenter selections isEmpty ifTrue: [^MessageBox notify: 'No project selected'].
	^projectListPresenter selection changesUsing: self gciSession!

projectDictionaryChanged
	| listModel |
	listModel := self textTabs.
	globalsLabel ifNil: [globalsLabel := listModel detect: [:each | each text = 'Globals']].
	self setDefaultProjectTablLabel.
	packageLabel ifNil: [packageLabel := listModel detect: [:each | each text = 'Package']].
	(listModel includes: projectLabel) ifFalse: [listModel addFirst: projectLabel].
	self updateProjectInfo.
	projectInfoTab ensureVisible.
	listModel remove: globalsLabel ifAbsent: [].
	listModel remove: packageLabel ifAbsent: []!

projectInfoTab
	^projectInfoTab!

projectListPresenter
	^projectListPresenter!

projectLog
	projectListPresenter selection projectLogUsing: self session: gciSession
!

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
	self issueCommand: projectServices!

pushToGit
	| projectServices ws |
	projectServices := projectListPresenter selections.
	ws := WriteStream on: String new.
	projectServices do: 
			[:service |
			ws
				nextPutAll: service name;
				space].
	(MessageBox
		confirm: 'Push projects - ' , ws contents , '- from the local repository to the remote server?')
			ifFalse: [^self].
	projectServices do: [:service | service command: #pushToGit].
	self issueCommand: projectServices!

queryCommand: aCommandQuery
	| command focusView isTextEdit |
	command := aCommandQuery command.
	focusView := View focus.
	isTextEdit := focusView isKindOf: TextEdit.
	(#(#browseMethodPragmas) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: gciSession gsHasPragmas.
			^true].
	(#(#editSave) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: (isTextEdit and: [focusView isModified]).
			^true].
	(#(#editUndo #editRevert) includes: aCommandQuery command)
		ifTrue: 
			[aCommandQuery isEnabled: (isTextEdit and: [focusView canUndo]).
			^true].
	(#(#editRedo) includes: aCommandQuery command)
		ifTrue: 
			[aCommandQuery isEnabled: (isTextEdit and: [focusView canRedo]).
			^true].
	(#(#editCut #editCopy) includes: aCommandQuery command)
		ifTrue: 
			[aCommandQuery isEnabled: (isTextEdit and: [focusView hasSelection]).
			^true].	"#'editDelete'"
	(#(#editPaste) includes: aCommandQuery command)
		ifTrue: 
			[aCommandQuery isEnabled: (isTextEdit and: [Clipboard current isTextAvailable]).
			^true].
	(#(#addRepository) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: packageListPresenter selections notEmpty.
			^true].
	(#(#showPackageChanges) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: true.
			^true].
	(#(#savePackage) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: packageListPresenter selections size = 1.
			^true].
	(#(#removeRepository) includes: command)
		ifTrue: 
			[aCommandQuery
				isEnabled: (repositoryListPresenter hasSelection and: [packageListPresenter selections size = 1]).
			^true].
	(#(#compareAncestor) includes: command)
		ifTrue: 
			[aCommandQuery
				isEnabled: (packageListPresenter selections size = 1 and: [ancestorListPresenter hasSelection]).
			^true].
	(#(#browseMethodHistory #browseImplementors #browseSenders) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: methodListPresenter selections size = 1.
			^true].
	(#(#inspectGlobal #browseGlobalReferences) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: globalsPresenter selections size = 1.
			^true].
	(#(#removeGlobals) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: globalsPresenter selections notEmpty.
			^true].
	(#(#fileOutMethods #clearMethodBreakpoints) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: self methodListPresenter selections notEmpty.
			^true].
	(#(#removeMethods) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: self methodListPresenter selections notEmpty.
			^true].
	(#(#loadLatestVersion) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: (packageListPresenter selections notEmpty
						and: [packageListPresenter selections allSatisfy: [:each | each key beginsWith: 'ConfigurationOf']]).
			^true].
	#gotoClassDefinedPackage = command
		ifTrue: 
			[self updateClassMenu: nil.
			self selectedClass
				ifNil: 
					[aCommandQuery isEnabled: false.
					^true].
			(self selectedClass selectedPackageNames includes: self selectedClass definedPackageName)
				ifTrue: 
					[aCommandQuery isEnabled: false.
					^true].
			self selectedClass definedPackageName = RowanService notRowanizedPackageName
				ifTrue: 
					[aCommandQuery isEnabled: false.
					^true]].
	#gotoMethodDefinedPackage = command
		ifTrue: 
			[methodListPresenter selectionIfNone: 
					[aCommandQuery isEnabled: false.
					^true].
			methodListPresenter selections size = 1
				ifFalse: 
					[aCommandQuery isEnabled: false.
					^true].
			(self selectedClass selectedPackageNames includes: methodListPresenter selection definedPackage)
				ifTrue: 
					[aCommandQuery isEnabled: false.
					^true].
			methodListPresenter selection definedPackage = RowanService notRowanizedPackageName
				ifTrue: 
					[aCommandQuery isEnabled: false.
					^true]].
	(#(#browseClassReferences #fileOutClass #addSubclass #addMissingAccessors #renameClass #removeClass #removePriorVersions #copyClass)
		includes: command)
			ifTrue: 
				[aCommandQuery isEnabled: self selectedClasses size == 1.
				^true].
	(#(#findMethod) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: self selectedClass notNil.
			^true].
	(#(#runClassTests #runAll) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: (self selectedClass
						ifNil: [false]
						ifNotNil: [:classService | classService isTestCase ifNil: [false]]).
			^true].
	(#(#runSelected #runMethodTests #runAndMesureTime #debug) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: (methodListPresenter selections notEmpty
						and: [methodListPresenter selections first isTestMethod]).
			^true].
	(#(#browseSelectedClass) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: self isClassSelectedInEditor.
			^true].
	command == #historyBack
		ifTrue: 
			[aCommandQuery isEnabled: self hasCommandHistoryBack.
			^true].
	command == #historyForward
		ifTrue: 
			[aCommandQuery isEnabled: self hasCommandHistoryForward.
			^true].
	command == #renameMethodCategory
		ifTrue: 
			[aCommandQuery isEnabled: self hasExactlyOneCategorySelected.
			^true].
	command == #removeMethodCategories
		ifTrue: 
			[aCommandQuery isEnabled: self hasCategorySelected.
			^true].
	command == #fileOutCategories
		ifTrue: 
			[aCommandQuery isEnabled: self hasCategorySelected.
			^true].
	command == #loadV2Project
		ifTrue: 
			[aCommandQuery isEnabled: true.
			^true].
	command == #refreshFromServer
		ifTrue: 
			[aCommandQuery isEnabled: true.
			^true].
	command == #findClass
		ifTrue: 
			[aCommandQuery isEnabled: true.
			^true].
	(command == #setEnvironment0 and: [environment == 0])
		ifTrue: 
			[aCommandQuery isChecked: true.
			^true].
	(command == #setEnvironment1 and: [environment == 1])
		ifTrue: 
			[aCommandQuery isChecked: true.
			^true].
	(command == #setEnvironment2 and: [environment == 2])
		ifTrue: 
			[aCommandQuery isChecked: true.
			^true].
	(#(#browseHierarchyImplementors #browseHierarchySenders) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: methodListPresenter selections size = 1.
			^true].
	(#(#browseSelectedMethods) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: methodListPresenter selections notEmpty.
			^true].
	(#(#showSUnitBrowserOnClass) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: (self selectedClass notNil and: [self selectedClass isTestCase]).
			^true].
	(self queryCommandHandlers: aCommandQuery) ifTrue: [^true].
	(aCommandQuery canPerformAgainst: self) ifTrue: [aCommandQuery beEnabled].
	^false	"There was no specific enablement of the command at this level"!

redrawAllViews
	"for now, just update a few views. Not sure if there's a better way to do this."
	projectListPresenter view invalidate.
	packageListPresenter view invalidate.
	classListPresenter view invalidate.!

refreshClassListOrHierarchy
	| newSelection listSelection hierarchySelection |
	(textAreaTabs currentCard name = 'classDefinition' and: [self selectedClass isNil])
		ifTrue: [self resetClassTemplate].
	self isClassListTabSelected
		ifTrue: 
			[listSelection := classListPresenter selectionOrNil.
			hierarchySelection := classHierarchyPresenter selectionOrNil.
			listSelection = hierarchySelection
				ifTrue: 
					[self resetDefinedClassPackage.
					^self].
			hierarchySelection isNil ifTrue: [^self updateClasses].
			self updateClasses.
			newSelection := classListPresenter list detect: [:service | hierarchySelection name = service name]
						ifNone: 
							[self resetDefinedClassPackage.
							^classListPresenter resetSelection].
			classListPresenter selection: newSelection]
		ifFalse: 
			[| selectedFilters selectedMethods |
			selectedFilters := self selectedFilters.
			selectedMethods := methodListPresenter selections.
			self updateHierarchy.
			self isCategoryTabSelected
				ifTrue: [categoryListPresenter selections: selectedFilters]
				ifFalse: [variableListPresenter selections: selectedFilters].
			classHierarchyPresenter selections isEmpty
				ifFalse: 
					["No selection if in the refreshing after rename. Done later"
					self selectMethods: selectedMethods]]!

refreshMethodsOn: presenter
	| classService |
	classService := self selectedClass ifNil:[^self].
	classService meta: self isClassSideSelected. 
	self isCategoryTabSelected
		ifTrue: [classService filters: categoryListPresenter selections]
		ifFalse: [classService filters: variableListPresenter selections].
	classService displayMethodsOn: presenter browser: self!

registerClassData
	"temporarily disabled"!

registerPresentersForUpdates

	BrowserUpdate current register: projectListPresenter 		selector: #projectsUpdate:browser: browser: self.
	BrowserUpdate current register: projectListPresenter 		selector: #removedProject:.
	BrowserUpdate current register: projectListPresenter 		selector: #newProject:.
	BrowserUpdate current register: projectListPresenter 		selector: #projectsUpdate:.
	BrowserUpdate current register: projectListPresenter 		selector: #removed:.
	BrowserUpdate current register: classListPresenter 		selector: #classesUpdate:browser: browser: self.
	BrowserUpdate current register: classListPresenter 		selector: #removedClass:.
	BrowserUpdate current register: classListPresenter 		selector: #updatedClass:browser: browser: self.
	BrowserUpdate current register: classDefinitionPresenter 	selector: #updatedClassDefinition:browser: browser: self.
	BrowserUpdate current register: classListPresenter 		selector: #removed:.
	BrowserUpdate current register: packageListPresenter 		selector: #projectPackagesUpdate:browser: browser: self.
	BrowserUpdate current register: packageListPresenter 		selector: #removed:.
	BrowserUpdate current register: packageListPresenter 		selector: #packageUpdate:.
	BrowserUpdate current register: categoryListPresenter 	selector: #filterUpdate:browser: browser: self.
	BrowserUpdate current register: classHierarchyPresenter 	selector: #classHierarchyUpdate:browser: browser: self.
	BrowserUpdate current register: classListPresenter 		selector: #updatedClass:browser: browser: self.
	BrowserUpdate current register: classHierarchyPresenter 	selector: #removedClass:.
	BrowserUpdate current register: classHierarchyPresenter 	selector: #updatedClass:browser: browser: self.
	BrowserUpdate current register: classHierarchyPresenter 	selector: #updatedClassInHierarchy:browser: browser: self.
	BrowserUpdate current register: classHierarchyPresenter 	selector: #removed:.
	BrowserUpdate current register: variableListPresenter 	selector: #filterUpdate:browser: browser: self.
	BrowserUpdate current register: methodListPresenter 	selector: #classMethodsUpdate:browser: browser: self.
	BrowserUpdate current register: methodListPresenter 	selector: #removed:.
	BrowserUpdate current register: methodSourcePresenter 	selector: #methodSourceUpdate:browser: browser: self. 
	BrowserUpdate current register: self 					selector: #autoCommitUpdate:.!

releasedReferencedServices: selectionChangingEvent
	selectionChangingEvent window presenter selectionOrNil ifNotNil: [:service | service postUpdate]!

removeClass
	| classService answeringService classReferenceBrowser queryService |
	classService := self selectedClass ifNil: [^self].
	answeringService := RowanAnsweringService new.
	answeringService
		command: #classHasSubclasses:;
		commandArgs: (Array with: classService oop).
	self issueCommand: (Array with: answeringService).
	answeringService answer ifTrue: [^MessageBox notify: 'Cannot remove class with subclasses'].
	(MessageBox confirm: 'Really delete class ' , classService name , '?') ifFalse: [^self].
	queryService := JadePresenter basicBrowseClassReferences: classService name session: self gciSession.
	queryService hasResults
		ifTrue: [classReferenceBrowser := self browseClassReferences: classService name].
	self basicRemoveClass: classService.
	queryService hasResults
		ifTrue: 
			[MessageBox notify: classService name
						, ' was removed. You will need to remove references to the class or your code may not load in the future.'].
	^classReferenceBrowser!

removeMethodCategories
	| selections |
	selections := categoryListPresenter selections.
	selections isEmpty ifTrue: [^MessageBox notify: 'No categories selected'].
	(self confirmCategoryRemoval: selections) ifFalse: [^self].
	self basicRemoveMethodCategories!

removeMethods: classServices
	"This is hokey but used everywhere. Replace 
	it with #removeMethodSelector(s): sometime soon"

	classServices do: 
			[:classService |
			classService
				command: #removeMethods:;
				commandArgs: (Array with: methodListPresenter selections)].
	self issueCommand: classServices!

removeMethodSelector: selector
	self removeMethodSelectors: (Array with: selector)!

removeMethodSelectors: selectors
	self selectedClass
		command: #removeMethods:;
		commandArgs: (Array with: methodListPresenter selections).
	self issueCommand: (Array with: self selectedClass)!

renameClass
	| oldClassService newClassName |
	oldClassService := self selectedClass ifNil: [^MessageBox notify: 'Class must be selected'].
	(MessageBox
		confirm: 'Rename class does NOT create a new version of the renamed class and instances are not migrated. Continue?')
			ifFalse: [^self].
	(newClassName := Prompter
				on: oldClassService name
				prompt: 'Rename ' , oldClassService name , ' to:'
				caption: 'Rename class') isNil
		ifTrue: [^self].
	self basicRenameClass: oldClassService to: newClassName!

renameMethodCategory
	| new old |
	old := categoryListPresenter selection.
	(new := Prompter
				on: old
				prompt: 'New method category?'
				caption: 'Rename Category') isNil
		ifTrue: [^self].
	(categoryListPresenter list includes: new)
		ifTrue: [^MessageBox notify: 'category ' , new , ' already exists'].
	self basicRenameCategoryFrom: old to: new!

resetCategoryText
	methodCategoryText value: String new. !

resetClassDefinitionPane
	classDefinitionPresenter view
		isModified: false;
		backcolor: JadeiteTextStyles default colorForNoEdits;
		isReadOnly: false!

resetClassTemplate
	self packageListPresenter list isEmpty
		ifTrue: 
			[classDefinitionPresenter value: String new.
			classDefinitionPresenter view isModified: false.
			^self].
	classDefinitionPresenter value: (self packageListPresenter selections isEmpty
				ifTrue: [String new]
				ifFalse: [self packageListPresenter selections first defaultTemplate]).
	self resetClassDefinitionPane!

resetDefinedClassPackage
	definedClassPackageText view text: String new.!

resetSunitTestList
	self selectedClass ifNil: [sunitPresenter resetTestList]!

runAndMesureTime
	| selections |
	self selectSUnitTab.
	sunitPresenter reset.
	selections := OrderedCollection new.
	methodListPresenter selections do: 
			[:methodService |
			| service |
			service := sunitPresenter methodListPresenter list
						detect: [:sunitService | sunitService selector = methodService selector]
						ifNone: [].
			service ifNotNil: [selections add: service]].
	sunitPresenter methodListPresenter selections: selections. 
	^sunitPresenter runAndMesureTime!

runClassTests
	| classService answeringService |
	classService := self selectedClass.
	classService
		command: #runClassTests:;
		commandArgs: (Array with: self selectedClass).
	answeringService := [self issueCommand: (Array with: classService)] on: Error
				do: 
					[:ex |
					ex pass. 
					^self].
	answeringService first answer
		ifTrue: 
			[| testResult |
			sunitPresenter reset.
			testResult := JadeTestResult new.
			testResult passed: (methodListPresenter list
						select: [:methodService | 'test*' match: methodService selector asString]
						thenCollect: [:methodService | methodService selector]).
			sunitPresenter updateResult: testResult.
			sunitPresenter ensureVisible]!

runMethodTests
	| sunitPresenterSelections testMethodServices | 
	testMethodServices := methodListPresenter selections select:[:methodService | methodService isTestMethod]. 
	(JadePresenter runMethodTests: testMethodServices in: self gciSession)
		ifTrue: 
			[| testResult |
			sunitPresenter reset.
			testResult := JadeTestResult new.
			testResult passed: (testMethodServices
								collect: [:methodService | methodService selector]).
			sunitPresenterSelections := self sunitPresenter methodListPresenter list select:[:methodService | testMethodServices includes: methodService]. 
			self sunitPresenter methodListPresenter selections: sunitPresenterSelections.
			sunitPresenter updateResult: testResult.
			sunitPresenter ensureVisible]!

savePackage
	MessageBox notify: 'This feature is not yet available'!

selectCategoriesNamed: array
	| selections |
	selections := categoryListPresenter list select: [:category | array includes: category].
	categoryListPresenter selections: selections!

selectCategoryFrom: methodService
	^categoryListPresenter selectionOrNil = methodService category
		ifFalse: [categoryListPresenter selection: methodService category]!

selectCategoryNamed: category
	^self selectCategoriesNamed: (Array with: category)!

selectCategoryTab
	(self view viewNamed: 'categoryList') ensureVisible!

selectClassDefinitionTab
	self selectSourceTabNamed: 'classDefinition'!

selectClassInClassHierarchyNamed: className
	| selection |
	selection := classHierarchyPresenter model asBag
				detect: [:classService | classService name = className]
				ifNone: [].
	selection ifNotNil: [classHierarchyPresenter selection: selection].
	^selection!

selectClassInClassListNamed: className
	| selection |
	selection := classListPresenter list detect: [:classService | classService name = className]
				ifNone: [].
	selection ifNotNil: [classListPresenter selection: selection].
	^selection!

selectClassListTab
	classHierarchyTabs firstCard!

selectClassNamed: className
	self isClassListTabSelected
		ifTrue: [self selectClassInClassListNamed: className]
		ifFalse: [self selectClassInClassHierarchyNamed: className]!

selectClassTab
	instanceClassTabs lastCard.!

selectCommentTab
	self selectSourceTabNamed: 'classDocumentation'!

selectComparisonTab
	self selectSourceTabNamed: 'comparisonTab'!

selectedClass
	^self isClassListTabSelected
		ifTrue: [classListPresenter selectionIfNone: []]
		ifFalse: [classHierarchyPresenter selectionIfNone: []]!

selectedClasses
	^self isClassListTabSelected
		ifTrue: [classListPresenter selections]
		ifFalse: [classHierarchyPresenter selections]!

selectedClassName
	^self selectedClass name!

selectedFilters
	^self isCategoryTabSelected
		ifTrue: [categoryListPresenter selections]
		ifFalse: [variableListPresenter selections]!

selectedMethodCategory
	^methodListPresenter selectionOrNil ifNotNil: [:methodService | methodService category]!

selectedMethodName

	^methodListPresenter selections first selector
!

selectedPackageNames
	^packageListPresenter selections collect: [:packageService | packageService name]!

selectGlobalsTab
	| tab |
	tab := self view viewNamed: 'globalsTab' ifNone:[^nil].
	^tab ensureVisible!

selectionMethod: methodSelection
	| newMethodSelection |
	newMethodSelection := methodListPresenter list
				detect: [:svc | svc selector = methodSelection selector]
				ifNone: [].
	^newMethodSelection ifNotNil: [methodListPresenter selection: newMethodSelection]!

selectMethods: methodSelections
	| newMethodSelections newSelection |
	newMethodSelections := OrderedCollection new.
	methodSelections do: 
			[:methodSelection |
			newSelection := methodListPresenter list detect: [:svc | svc selector = methodSelection selector]
						ifNone: [].
			newSelection ifNotNil: [newMethodSelections add: newSelection]].
	^methodListPresenter selections: newMethodSelections!

selectMethodsFrom: classService
	| selections |
	selections := OrderedCollection new.
	self selectClassNamed: classService selectedMethods first className asString.
	(classService selectedMethods size = 1 and: [self isCategoryTabSelected])
		ifTrue: [categoryListPresenter selection: classService selectedMethods first category].
	classService selectedMethods do: 
			[:methodService |
			| selection |
			selection := methodListPresenter list detect: [:svc | svc selector == methodService selector]
						ifNone: [].
			selection ifNotNil: [:sel | selections add: sel]].
	methodListPresenter selections: selections!

selectMethodSourceTab
	| methodSourceTab selection |
	methodSourceTab := self view viewNamed: 'methodSource'.
	methodListPresenter selectionOrNil ifNotNil: [^methodSourceTab ensureVisible].
	selection := self isCategoryTabSelected
				ifTrue: [categoryListPresenter selectionOrNil]
				ifFalse: [variableListPresenter selectionOrNil].
	selection
		ifNotNil: 
			[methodSourceTab ensureVisible.
			methodListPresenter selectionOrNil ifNil: [methodSourcePresenter setDefaultMethod]]!

selectPackage: newPackageSelection
	| methodSelection classSelection |
	methodSelection := methodListPresenter selectionOrNil.
	classSelection := classListPresenter selectionOrNil.
	packageListPresenter selection: newPackageSelection.
	classSelection ifNotNil: [self selectClassNamed: classSelection name].
	methodSelection ifNotNil: [self selectionMethod: methodSelection]!

selectProjectTab
	self selectSourceTabNamed: 'projectInfo'!

selectSourceTabNamed: tabName
	| tab |
	tab := self view viewNamed: tabName.
	tab ensureVisible!

selectSUnitTab
	self selectSourceTabNamed: 'sunit'!

selectVariableTab
	(self view viewNamed: 'variableList') ensureVisible!

setDefaultProjectTablLabel
	projectLabel ifNil: [projectLabel := self textTabs detect: [:each | each text = 'Project']]!

setDefaultProjectTablLabel: listModel
	projectLabel ifNil: [projectLabel := listModel detect: [:each | each text = 'Project']]!

setMethodFilterFor: presenter
	| filters |
	self isCategoryTabSelected
		ifTrue: [filters := categoryListPresenter selections]
		ifFalse: [filters := variableListPresenter selections].
	presenter model asBag do: [:service | service filters: filters]!

setterMethodSourceFor: variable
	| sourceStream |
	sourceStream := WriteStream on: String new.
	sourceStream
		nextPutAll: variable , ': object';
		cr;
		tab;
		nextPutAll: variable , ' := object'.
	^sourceStream!

setTestClass: service
	sunitPresenter testClassService: (service isTestCase ifTrue: [service] ifFalse: [nil])!

setupPackageMenu
	packageListPresenter view contextMenu: (Menu fromStrings: self pkgsMenuStrings)!

showMethodRecompilationError: ex
	| sourcePresenter browser source className errorText failedMethodService |
	source := ex additionalArgs first.
	className := ex additionalArgs second.
	failedMethodService := RowanMethodService
				fakeMethodFor: className
				selector: (SmalltalkParser parseMethod: source) buildSelector asSymbol
				source: source.
	self updateService: failedMethodService. 
	failedMethodService category: 'other'.
	browser := JadeiteMethodListBrowser showOnSession: gciSession.
	browser updateMethodsWithoutTriggeringEvents: failedMethodService.
	browser primaryPresenter updateSource. 
	browser updateCaption: 'Methods Failing Recompilation'.
	sourcePresenter := browser primaryPresenter methodSourcePresenter documentPresenter.
	browser primaryPresenter setCompileErrorColor.
	errorText := ex list first third.
	browser primaryPresenter statusBarText: errorText.
	self reportCompileError: ex list in: sourcePresenter.
	sourcePresenter view isModified: false.
	^browser!

showSUnitBrowserOnClass
	| sunitBrowser |
	sunitBrowser := JadeiteSUnitBrowser showOnSession: gciSession.
	sunitBrowser primaryPresenter selectPackageNamed: self selectedClass definedPackageName
		classNamed: self selectedClass name.
	^sunitBrowser!

showSuperClassComparison
	| methodService |
	methodService := methodListPresenter selection.
	methodService hasSupers
		ifTrue: 
			[comparisonPresenter
				beforeTitle: methodService classMethodDisplayString;
				afterTitle: methodService superDisplayString;
				compare: methodService source with: methodService comparisonSource]
		ifFalse: 
			[comparisonPresenter
				beforeTitle: methodService classMethodDisplayString;
				afterTitle: 'No super implementation';
				compare: methodService source with: String new]!

sundryCleanup
	self statusBarText: String new.
	methodListPresenter selections notEmpty ifFalse: [self cleanupComparisonBrowser].
	self resetSunitTestList!

sunitPresenter
	"for testing"

	^sunitPresenter!

symbolExists: newClassName
	^(RowanAnsweringService new symbolExists: newClassName asSymbol session: self gciSession) not!

targetCategory
	self isVariablesTabSelected ifTrue: [^self selectedMethodCategory].
	categoryListPresenter hasSelection ifFalse: [^self selectedMethodCategory].
	categoryListPresenter selections size > 1 ifTrue: [^self selectedMethodCategory].
	^categoryListPresenter selection trimBlanks!

textAreaTabs
	"for testing"
	^textAreaTabs!

textTabChanged
	methodSourcePresenter view cancelCallTip.
	textAreaTabs currentCard name = 'projectInfo' ifTrue: [projectInfoTab ensureVisible].
	textAreaTabs currentCard name = 'sunit'
		ifTrue: [sunitPresenter methodListPresenter setFocus	"to ensure sunit bar is enabled"].
	self updateMenuBar!

textTabs
	^(textAreaTabs subViews detect: [:each | each class == TabViewXP]) model!

unloadPackage
	MessageBox notify: 'This feature is not yet available'!

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

update: services afterStonReplication: stonResults
	| result |
	result := super update: services afterStonReplication: stonResults.
	self redrawAllViews.
	^result!

updateAndSelectA: aView
	"is this override still needed?"
	self updateMenuBar.
	aView notNil ifTrue: [aView ensureVisible].
!

updateClasses
	self updateServices: packageListPresenter selections.!

updateClassInfo
	| service |
	self resetCategoryText.
	service := self selectedClass
				ifNil: 
					[self resetDefinedClassPackage.
					^self].
	classCommentPresenter value: service comment.
	classDefinitionPresenter view isModified
		ifTrue: 
			[service template = classDefinition ifTrue: [^self].
			(MessageBox confirm: 'Copy changes to clipboard?' caption: 'Class has unsaved changes!!')
				ifTrue: [classDefinitionPresenter value copyToClipboard]].
	classDefinitionPresenter value: service template.
	self resetClassDefinitionPane.
	self setTestClass: service.
	self isSunitTabSelected ifFalse: [classDefinitionPresenter ensureVisible].
	self sundryCleanup.
	definedClassPackageText view text: 'Defined Package: ' , self selectedClass definedPackageName.
	self updateClassMenu: nil.
	self updateSUnitTab.
!

updateClassMenu: menu
	| gotoPackageItem gotoDictionaryItem |
	(menu class canUnderstand: #items) ifFalse: [^self].
	"Removal and adding of the item seems to be necessary to update the menu about to be displayed"
	gotoPackageItem := menu items
				detect: [:commandItem | commandItem commandDescription command = #gotoClassDefinedPackage]
				ifNone: [^self].
	menu removeItem: gotoPackageItem.
	gotoPackageItem description: self definedClassMenuItemLabel.
	menu addItem: gotoPackageItem.
	gotoDictionaryItem := menu items
				detect: [:commandItem | commandItem commandDescription command = #gotoDictionary]
				ifNone: [^self].
	menu removeItem: gotoDictionaryItem.
	gotoDictionaryItem description: self containedDictionaryLabel.
	menu addItem: gotoDictionaryItem!

updateCommand: aString onSuccessDo: aBlock

	"Only use STON to update in our new browser"
	stonCritical critical: 
			[
			[| stonResults update |
			update := BrowserUpdate current initializeUpdates.
			stonResults := self gciSession serverPerform: #systemBrowserSTON:
						with: environment printString , ' ' , aString.
			update updates: (STON fromString: stonResults).
			self updateSelectionsFor: update.
			self updateTabLabel.
			update updates: #()]
					ensure: [selectedClassChanged := false]].
	^nil!

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
				addItem: (Menu fromStrings: self preferencesMenuStrings);
				yourself.
	shellView menuBar: menuBar.
	self updateMethodMenu: methodMenu!

updateMethodMenu: menu
	| item |
	methodListPresenter selectionIfNone: [^self].
	(menu class canUnderstand: #items) ifFalse: [^self].
	item := menu items
				detect: [:commandItem | commandItem commandDescription command = #gotoMethodDefinedPackage]
				ifNone: [^self].
	"Removal and adding of the item seems to be necessary to update the menu about to be displayed"
	menu removeItem: item.
	item description: self definedMethodMenuItemLabel.
	menu addItem: item!

updateMethodReferences: services
	services do: [:service | service command: #allReferences].
	self issueCommand: services.
	^services!

updateMethodSource
	methodSourcePresenter view isModified ifTrue: [^self].
	self sundryCleanup.
	methodListPresenter selections isEmpty
		ifTrue: 
			[methodCategoryText value: 'Category: '.
			definedMethodPackageText view text: String new.
			^methodSourcePresenter setDefaultMethod].
	self updateServices: methodListPresenter selections.
	methodListPresenter selections isEmpty ifTrue: [^self].
	methodListPresenter selections size > 1
		ifTrue: 
			[self updateMultiMethodComparison.
			self displayMultipleCategories]
		ifFalse: 
			[self showSuperClassComparison.
			self updateSingleMethodSource.
			definedMethodPackageText view
				text: 'Defined Package: ' , methodListPresenter selection definedPackage.
			methodCategoryText value: 'Category: ' , methodListPresenter selection category].
	self updateSUnitTab.
	self displayUncompilableSourceIn: methodSourcePresenter!

updateMultiMethodComparison
	comparisonPresenter
		beforeTitle: (methodListPresenter selections at: 1) classMethodDisplayString;
		afterTitle: (methodListPresenter selections at: 2) classMethodDisplayString;
		compare: (methodListPresenter selections at: 1) source
			with: (methodListPresenter selections at: 2) source.
	comparisonPresenter view invalidate!

updatePackage
	classListPresenter model: ListModel new.
	classHierarchyPresenter model: TreeModel new.
	self updateClasses.
	self isClassListTabSelected ifFalse: [self updateHierarchy].
	self updatePackageInfo.
	self resetSunitTestList!

updatePackageInfo
	| service |
	self updateTabLabel.
	service := packageListPresenter selectionIfNone: [^self].
	classDefinitionPresenter value: service defaultTemplate.
	self resetClassDefinitionPane.
	classCommentPresenter view
		backcolor: JadeiteTextStyles default colorForNoEdits;
		isModified: false.
	classDefinitionPresenter ensureVisible!

updatePackages
	packageListPresenter clear.
	projectListPresenter selections isEmpty ifTrue: [^self].
	self updateServices: projectListPresenter selections.
	self sundryCleanup!

updatePresenter: presenter selections: selections
	| newSelections |
	newSelections := OrderedCollection new.
	selections do: 
			[:selection |
			(presenter list detect: [:service | service name = selection name] ifNone: [])
				ifNotNil: [:newSelection | newSelections add: newSelection]].
	presenter selections: newSelections!

updateProject
	self updatePackages.
	self updateProjectInfo.
	projectInfoTab ensureVisible.
	self sundryCleanup!

updateProjectInfo
	| services array |
	services := projectListPresenter selections.
	self updateTabLabel.
	services isEmpty ifTrue: [^projectInfoTab list: ListModel new].
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

updateProjects
	| browserService |
	browserService := RowanBrowserService new.
	browserService
		command: #updateProjects.
	self issueCommand: (Array with: browserService).!

updateSelectionsForUpdate: update
	update updatePackageSelectionsFor: packageListPresenter.
	update updateClassCategorySelectionsFor: classCategoryPresenter.
	update updateClassSelectionFor: classListPresenter.
	update updateClassHierarchySelectionFor: classHierarchyPresenter.
	update updateSuperclassSelectionFor: superclassListPresenter.
	update updateMethodFilterSelectionFor: self methodFilterListPresenter.
	update updateMethodSelectionFor: self methodListPresenter.
	update projectSelectionUpdate: projectListPresenter!

updateSingleMethodSource
	methodSourcePresenter value: methodListPresenter selection source.
	self refreshBreakPointsIn: methodSourcePresenter.
	self displayNoMods: methodSourcePresenter. !

updateSUnitTab
	self selectedClass
		ifNil: [sunitPresenter testClassService: nil]
		ifNotNil: [:service | self setTestClass: service]!

updateSUnitTab: service
	service ifNil: [sunitPresenter testClassService: nil] ifNotNil: [self setTestClass: service]!

writeProject
	| projectServices |
	projectServices := projectListPresenter selections.
	projectServices isEmpty ifTrue: [^MessageBox notify: 'No project selected'].
	^self basicWriteProject: projectServices! !
!JadeiteProjectsBrowserPresenter categoriesFor: #aboutToChange:!event handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #addNoneProject!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #addPackage!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #addPackageDictionaryInfoTo:!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #addSubclass!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #addVariableAccessors!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #allClasses!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #autoCommit!accessing!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #autoCommit:!initialize/release!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #basicAddMethodCategory:!menu handlers support!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #basicCopyClass:to:!menu handlers support!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #basicOnDropClassList:!drag & drop!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #basicProjectTabLabel!displaying!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #basicRemoveClass:!menu handlers support!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #basicRemoveMethodCategories!menu handlers support!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #basicRemoveMethods!menu handlers support!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #basicRenameCategoryFrom:to:!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #basicRenameClass:to:!menu handlers support!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #basicUnloadProjects:!menu handlers support!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #behaviorIdentifier!private!selection! !
!JadeiteProjectsBrowserPresenter categoriesFor: #browseHierarchyImplementors!menu handlers!public!queries! !
!JadeiteProjectsBrowserPresenter categoriesFor: #browseHierarchySenders!public!queries! !
!JadeiteProjectsBrowserPresenter categoriesFor: #browseSelectedClass!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #categoriesMenuStrings!menus!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #categoryListPresenter!accessing!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #classCommentPresenter!accessing!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #classDefinitionPresenter!accessing!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #classesMenuStrings!menus!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #classHierarchyTabs!accessing!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #cleanupComparisonBrowser!initialize/release!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #clearFilterLists!event handlers support!private!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #clearMethodBreakpoints!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #comparisonTab!private!text tabs! !
!JadeiteProjectsBrowserPresenter categoriesFor: #confirmCategoryRemoval:!menu handlers support!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #confirmOverwriteAccessor!menu handlers support!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #containedDictionaryLabel!menus!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #copyClass!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #copyProjectInfo!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #createComponents!initialize/release!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #createSchematicWiring!create schemantic wiring!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #createSchematicWiringForClassHierarchy!create schemantic wiring!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #createSchematicWiringForClassHierarchyTabs!create schemantic wiring!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #createSchematicWiringForClassList!create schemantic wiring!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #createSchematicWiringForInstanceClassTabs!create schemantic wiring!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #createSchematicWiringForMethodCategoryList!create schemantic wiring!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #createSchematicWiringForMethodFilterTabs!create schemantic wiring!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #createSchematicWiringForMethodList!create schemantic wiring!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #createSchematicWiringForPackageDictionaryTabs!create schemantic wiring!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #createSchematicWiringForPackageList!create schemantic wiring!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #createSchematicWiringForProjectDictionaryList!create schemantic wiring!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #createSchematicWiringForProjectList!create schemantic wiring!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #createSchematicWiringForVariableList!create schemantic wiring!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #createStateEntry!accessing!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #definedClassMenuItemLabel!menus!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #definedMethodMenuItemLabel!menus!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #displayMultipleCategories!displaying!private!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #editFind!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #editReplace!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #editSaveClassComment!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #expandHierarchyOneLevelAt:!event handlers!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #fileOutCategories!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #fileOutCategoriesOnPath:!menu handlers support!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #fileOutClass!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #fileOutClassOnPath:!menu handlers support!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #fileOutMethods!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #fileOutMethodsOnPath:!menu handlers support!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #filterTabChanged!event handlers!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #findClass!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #findMethod!event handlers!menu handlers!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #findMethod:!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #findRemovedServices!project menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #gciSession:!accessing!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #getterMethodSourceFor:!menu handlers support!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #getViews!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #gitCommit!project menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #gotoClass!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #gotoClassDefinedPackage!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #gotoClassDefinedPackageViaButton!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #gotoMethodDefinedPackage!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #gotoMethodDefinedPackageViaButton!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #gotoPackageNamed:!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #gotoProjectNamed:!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #hasCategorySelected!public!testing! !
!JadeiteProjectsBrowserPresenter categoriesFor: #hasExactlyOneCategorySelected!public!testing! !
!JadeiteProjectsBrowserPresenter categoriesFor: #hierarchyClassDoubleClicked!event handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #initialize!initialize/release!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #isClassDefinitionTabSelected!public!testing! !
!JadeiteProjectsBrowserPresenter categoriesFor: #isClassSelected!public!testing! !
!JadeiteProjectsBrowserPresenter categoriesFor: #isComparisonTabSelected!public!testing! !
!JadeiteProjectsBrowserPresenter categoriesFor: #isDictionariesTabSelected!public!testing! !
!JadeiteProjectsBrowserPresenter categoriesFor: #isHierarchyTabSelected!public!testing! !
!JadeiteProjectsBrowserPresenter categoriesFor: #isMethodSourceTabSelected!public!testing! !
!JadeiteProjectsBrowserPresenter categoriesFor: #isOkayToChange!event handlers!public!testing! !
!JadeiteProjectsBrowserPresenter categoriesFor: #isSourceTabSelected!public!testing! !
!JadeiteProjectsBrowserPresenter categoriesFor: #isSunitTabSelected!public!testing! !
!JadeiteProjectsBrowserPresenter categoriesFor: #jadeDebug!menu handlers!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #jadeDisplay!menu handlers!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #jadeExecute!menu handlers!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #jadeMenuStrings!menus!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #loadProjects!project menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #methodCategoryText!accessing!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #methodListPresenter!accessing!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #methodListSelection!accessing!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #methodMenuBreak:!menus!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #methodsMenuStrings!menus!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #methodSourcePresenter:!accessing!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #moveMethods:toCategory:!drag & drop!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #newBrowser!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #onDragClass:!drag & drop!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #onDragClassHierarchy:!drag & drop!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #onDropMethodsOnClassHierarchy:!drag & drop!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #onDropOnClassList:!drag & drop!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #onDropOnMethodCategory:!drag & drop!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #onSetFocus:stack:!event handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #onViewClosed!event handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #onViewOpened!event handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #pkgsMenuStrings!menus!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #populateFilterList!event handlers support!private!services!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #postOkToChangeEvent!event handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #projectChanges!project menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #projectDictionaryChanged!event handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #projectInfoTab!accessing!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #projectListPresenter!accessing!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #projectLog!project menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #projectTabLabel!displaying!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #pullFromGit!project menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #pushToGit!project menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #queryCommand:!menu handlers support!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #redrawAllViews!displaying!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #refreshClassListOrHierarchy!event handlers!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #refreshMethodsOn:!event handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #registerClassData!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #registerPresentersForUpdates!event handlers!initialize/release!private!register presenters! !
!JadeiteProjectsBrowserPresenter categoriesFor: #releasedReferencedServices:!event handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #removeClass!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #removeMethodCategories!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #removeMethods:!private!services! !
!JadeiteProjectsBrowserPresenter categoriesFor: #removeMethodSelector:!private!services! !
!JadeiteProjectsBrowserPresenter categoriesFor: #removeMethodSelectors:!private!services! !
!JadeiteProjectsBrowserPresenter categoriesFor: #renameClass!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #renameMethodCategory!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #resetCategoryText!event handlers support!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #resetClassDefinitionPane!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #resetClassTemplate!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #resetDefinedClassPackage!event handlers support!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #resetSunitTestList!initialize/release!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #runAndMesureTime!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #runClassTests!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #runMethodTests!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #savePackage!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #selectCategoriesNamed:!public!selection! !
!JadeiteProjectsBrowserPresenter categoriesFor: #selectCategoryFrom:!public!selection! !
!JadeiteProjectsBrowserPresenter categoriesFor: #selectCategoryNamed:!public!selection! !
!JadeiteProjectsBrowserPresenter categoriesFor: #selectCategoryTab!public!selection! !
!JadeiteProjectsBrowserPresenter categoriesFor: #selectClassDefinitionTab!public!selection! !
!JadeiteProjectsBrowserPresenter categoriesFor: #selectClassInClassHierarchyNamed:!private!selection! !
!JadeiteProjectsBrowserPresenter categoriesFor: #selectClassInClassListNamed:!private!selection! !
!JadeiteProjectsBrowserPresenter categoriesFor: #selectClassListTab!public!selection! !
!JadeiteProjectsBrowserPresenter categoriesFor: #selectClassNamed:!private!selection! !
!JadeiteProjectsBrowserPresenter categoriesFor: #selectClassTab!public!selection! !
!JadeiteProjectsBrowserPresenter categoriesFor: #selectCommentTab!public!selection! !
!JadeiteProjectsBrowserPresenter categoriesFor: #selectComparisonTab!public!selection! !
!JadeiteProjectsBrowserPresenter categoriesFor: #selectedClass!private!selection! !
!JadeiteProjectsBrowserPresenter categoriesFor: #selectedClasses!private!selection! !
!JadeiteProjectsBrowserPresenter categoriesFor: #selectedClassName!private!selection! !
!JadeiteProjectsBrowserPresenter categoriesFor: #selectedFilters!accessing!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #selectedMethodCategory!menu handlers support!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #selectedMethodName!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #selectedPackageNames!public!selection! !
!JadeiteProjectsBrowserPresenter categoriesFor: #selectGlobalsTab!public!selection! !
!JadeiteProjectsBrowserPresenter categoriesFor: #selectionMethod:!private!selection! !
!JadeiteProjectsBrowserPresenter categoriesFor: #selectMethods:!private!selection! !
!JadeiteProjectsBrowserPresenter categoriesFor: #selectMethodsFrom:!private!selection! !
!JadeiteProjectsBrowserPresenter categoriesFor: #selectMethodSourceTab!public!selection! !
!JadeiteProjectsBrowserPresenter categoriesFor: #selectPackage:!private!selection! !
!JadeiteProjectsBrowserPresenter categoriesFor: #selectProjectTab!public!selection! !
!JadeiteProjectsBrowserPresenter categoriesFor: #selectSourceTabNamed:!private!selection! !
!JadeiteProjectsBrowserPresenter categoriesFor: #selectSUnitTab!public!selection! !
!JadeiteProjectsBrowserPresenter categoriesFor: #selectVariableTab!public!selection! !
!JadeiteProjectsBrowserPresenter categoriesFor: #setDefaultProjectTablLabel!event handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #setDefaultProjectTablLabel:!event handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #setMethodFilterFor:!event handlers support!private!services!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #setterMethodSourceFor:!menu handlers support!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #setTestClass:!event handlers support!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #setupPackageMenu!event handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #showMethodRecompilationError:!menu handlers support!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #showSUnitBrowserOnClass!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #showSuperClassComparison!private!text tabs! !
!JadeiteProjectsBrowserPresenter categoriesFor: #sundryCleanup!initialize/release!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #sunitPresenter!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #symbolExists:!public!testing! !
!JadeiteProjectsBrowserPresenter categoriesFor: #targetCategory!menu handlers support!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #textAreaTabs!private!text tabs! !
!JadeiteProjectsBrowserPresenter categoriesFor: #textTabChanged!event handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #textTabs!private!text tabs! !
!JadeiteProjectsBrowserPresenter categoriesFor: #unloadPackage!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #unloadProjects!project menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #update:afterStonReplication:!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updateAndSelectA:!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updateClasses!event handlers!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updateClassInfo!event handlers!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updateClassMenu:!event handlers!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updateCommand:onSuccessDo:!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updateMenuBar!menus!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updateMethodMenu:!event handlers!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updateMethodReferences:!private!services! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updateMethodSource!event handlers!public!text tabs!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updateMultiMethodComparison!event handlers support!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updatePackage!event handlers!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updatePackageInfo!event handlers!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updatePackages!event handlers!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updatePresenter:selections:!event handlers support!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updateProject!event handlers!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updateProjectInfo!event handlers!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updateProjects!event handlers!menu handlers!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updateSelectionsForUpdate:!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updateSingleMethodSource!event handlers support!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updateSUnitTab!event handlers!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updateSUnitTab:!event handlers!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #writeProject!project menu handlers!public! !

!JadeiteProjectsBrowserPresenter class methodsFor!

downArrowIcon
	^Icon fromFile: 'icons\DownArrow.ico'
! !
!JadeiteProjectsBrowserPresenter class categoriesFor: #downArrowIcon!public! !

