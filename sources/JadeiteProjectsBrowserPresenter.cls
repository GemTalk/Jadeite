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

abortTransaction
	super abortTransaction.
	self refreshFromServerAfterAbort: nil!

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

addSystemBrowser
	^self topShell addSystemBrowser!

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
	label := projectListPresenter selections size > 1
				ifTrue: ['Projects']
				ifFalse: [projectListPresenter selection name].
	packageListPresenter selections isEmpty ifTrue: [^label].
	packageListPresenter selections size > 1 ifTrue: [^label].
	^packageListPresenter selection name!

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
	browser primaryPresenter methods: answeringService answer selecting: answeringService answer first.
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

browseMethodHistory

	MessageBox warning: 'Method history is not available yet'. !

browseSelectedClass
	^self browseSelectedClassIn: methodSourcePresenter newTab: Keyboard default isCtrlDown!

browseSelectedMethods
	"convenience menu item to display randomly grouped methods in a browser"

	| browser |
	self updateServices: methodListPresenter selections. 
	(browser := JadeiteMethodListBrowser showOnSession: gciSession) primaryPresenter
		methods: methodListPresenter selections
		selecting: nil.
	browser updateCaption: 'Selected Methods'.
	^browser!

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

checkout
	projectListPresenter selection checkoutUsing: self.
	self refreshFromServer!

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
	menuStrings := #('&Classes' '&Browse Class References//browseClassReferences' 'Browse SUnit//showSUnitBrowserOnClass' '&File Out Class//fileOutClass' 'Add &Subclass//addSubclass' '&Rename ... //renameClass' 'Copy ...//copyClass' '&Remove//removeClass' '-' 'Set Compiler &Environment ...//setEnvironment'  '-')
				asOrderedCollection.
	menuStrings addLast: definedLabel , '//gotoClassDefinedPackage'.
	menuStrings addLast: containedDictionaryLabel, '//gotoDictionary'. 
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
	| oldClassService newClassName |
	oldClassService := self selectedClass ifNil: [^MessageBox notify: 'Class must be selected'].
	(newClassName := Prompter
				on: oldClassService name
				prompt: 'Copy ' , oldClassService name , ' to:'
				caption: 'Copy class') isNil
		ifTrue: [^self].
	self basicCopyClass: oldClassService to: newClassName.
!

copyProjectInfo
	projectInfoTab selection last ifNil:[^self]. 
	(projectInfoTab selection first perform: projectInfoTab selection last asSymbol) displayString copyToClipboard!

createComponents
	super createComponents.
	projectListPresenter := self add: ListPresenter new name: 'projectList'.
	packageListPresenter := self add: ListPresenter new name: 'packagesList'.
	comparisonPresenter := self add: DifferencesPresenter new name: 'comparisonTab'.
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
		backcolor: JadeTextStyles default colorForNoEdits!

editSaveMethod
	| selection |
	selection := self selectedClass.
	selection meta: self isClassSideSelected.
	self editSaveMethod: selection.
	self updateSUnitTab.
	self redrawAllViews!

expandHierarchyAt: classService
	Cursor wait showWhile: 
			[classService command: #oneLevelClassHierarchy.
			self issueCommand: (Array with: classService).
			self selectClassNamed: classService name]!

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

gotoDictionary
	" find will go to the class in the dictionary it lives"

	| selectedClass |
	selectedClass := self selectedClass.
	self selectNoneProject.
	^self updateAfterFindClassInDictionary: selectedClass!

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

	self expandHierarchyAt: classHierarchyPresenter selection!

initialize
	super initialize.
	stonCritical := Semaphore forMutualExclusion.!

isClassDefinitionTabSelected
	^textAreaTabs currentCard name = 'classDefinition'!

isClassSelected
	^self selectedClass notNil!

isDictionariesTabSelected

	^projectDictionaryTabs currentCard name = 'dictionaryList'.
!

isHierarchyTabSelected
	^classHierarchyTabs currentCard name = 'classHierarchy'!

isOkayToChange
	methodSourcePresenter view isModified
		ifTrue: [(self isOkayToChangeSource: methodSourcePresenter) ifFalse: [^false]].
	classDefinitionPresenter view isModified
		ifTrue: 
			[classDefinitionPresenter ensureVisible.
			gciSession isValidSession
				ifTrue: 
					[(MessageBox confirm: 'Stay on unsaved class definition?' caption: 'Class has unsaved changes!!')
						ifTrue: [^false]]
				ifFalse: 
					[(MessageBox confirm: 'Copy changes to Clipboard?' caption: 'Class has unsaved changes!!')
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
					[(MessageBox confirm: 'Stay on unsaved class comment?' caption: 'Class commen has unsaved changes!!')
						ifTrue: [^false]]
				ifFalse: 
					[(MessageBox confirm: 'Copy changes to Clipboard?' caption: 'Class has unsaved changes!!')
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

jadeInspect
	View focus == methodSourcePresenter view ifFalse: [^self].
	^super jadeInspect!

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
	self refreshGlobalSelections!

makeDefault
	"the server is the gold copy"
	| projectService |
	projectService := projectListPresenter selection.
	projectService command: #setDefaultProject.
	self issueCommand: (Array with: projectService).
	RowanProjectService defaultProjectName: projectService name.
	projectListPresenter view invalidate. !

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

methodSelectionChanged
	self setStatusBarDefault.
	self updateMethodSource. 
	self topShell cardsPresenter view currentCard presenter == self
		ifTrue: [methodSourcePresenter ensureVisible]!

methodsMenuStrings
	false
		ifTrue: 
			["This helps us find senders"
			self
				browseBreakpoints;
				browseImplementors;
				browseImplementorsOf;
				browseSenders;
				browseSendersOf;
				browseHierarchyImplementors;
				browseHierarchySenders;
				browseMethodsContaining;
				browseLiteralReferences;
				browseSelectedMethods; 
				clearAllBreaks;
				removeMethods;
				runMethodTests;
				fileOutMethods;
				findMethod; 
				runMethodTests;
				gotoMethodDefinedPackage; runAll; runSelected].
	^#('&Methods'
'Browse &Implementors//browseImplementors'
'Browse Implementors of ...//browseImplementorsOf'
'Browse &Senders//browseSenders'
'Browse Senders of ...//browseSendersOf'  
'-'  
'Browse Hierarchy Implementors//browseHierarchyImplementors'
'Browse Hierarchy Senders//browseHierarchySenders'
'-'
'Browse Methods &Containing ...//browseMethodsContaining'
'Browse Literal References ...//browseLiteralReferences'
'Browse Selected Methods//browseSelectedMethods'
'-'
'Browse Breakpoints//browseBreakpoints'  
'Clear All Breakpoints//clearAllBreaks'  
'-'
'Find Method .../Ctrl+Shift+M/findMethod'
'-'
'&Remove Method(s) ...//removeMethods'
'Debug &Tests/Ctrl+B/runMethodTests' 
'Run All Tests/Ctrl+Shift+A/runAll'
'Run Selected/Ctrl+Shift+S/runMethodTests'
'-'
'Go To Defining Package//gotoMethodDefinedPackage' )!

methodSourcePresenter: anObject
	methodSourcePresenter := anObject!

methodSourcePresenter1
	^methodSourcePresenter!

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

onDragMethod: aSession 

	| list |
	list := methodListPresenter selections collect: [:each | 
		(aSession newDragObject: each)
			format: #method data: each;
			yourself.
	].
	aSession 
		dragObjects: list;
		supportedOperations: #(#move #copy);
		defaultOperation: #copy;
		yourself.
!

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

onSetFocus
	"updateProcess was hanging around on test runs. Don't think 
	it was needed in Jadeite anyway"!

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
	listModel := ListModel new searchPolicy: SearchPolicy equality.
	self isCategoryTabSelected
		ifTrue: 
			[listModel addAll: self selectedClass categories.
			categoryListPresenter model: listModel]
		ifFalse: 
			[listModel addAll: self selectedClass variables.
			variableListPresenter model: listModel]!

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

projectMenu
	^Menu fromStrings: self projectMenuStrings!

projectMenuCommands
	^self projectMenu items collect: [:item | item command]!

projectMenuStrings
	self rowanFixMe.	"this really is a cumbersome way to build a menu."
	0 == 1
		ifTrue: 
			[self
				addPackage;
				makeDefault;
				cloneProject;
				loadProjects;
				unloadProjects;
				pullFromGit;
				gitCommit;
				pushToGit;
				projectChanges;
				writeProject;
				checkout;
				projectLog;
				openCommitInGitHub;
				refresh].
	^#('Projects' '&Make Default//makeDefault' 
		'-' 
		'Clone Git Project ...//cloneProject' 
		'Load//loadProjects' 'Unload//unloadProjects' 
		'-'
		'Pull from Git//pullFromGit'
		'Commit to Git ...//gitCommit'
		'Push to Git//pushToGit'
		'-'
		'&Changes//projectChanges'
		'Write//writeProject'
		'Checkout Git Branch ...//checkout'
		'-'
		'&Add Package...//addPackage'
		'-'
		'Git Log//projectLog'
		'Browse Commit In GitHub//openCommitInGitHub'
		'&Refresh//refreshFromServer')!

projectTabLabel
	"Selections get mixed up switching between system presenters unless the tabs
	have a unique label. Rather silly, but we'll give the tab a unique number"

	| cardNumber label |
	label := self basicProjectTabLabel.
	cardNumber := self parentPresenter view cards indexOf: self view.
	^cardNumber printString , ' ' , label!

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
	(#(#editUndo) includes: aCommandQuery command)
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
	(#(#fileOutMethods) includes: command)
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
	(#(#browseClassReferences #fileOutClass #addSubclass #addMissingAccessors #renameClass #removeClass #removePriorVersions)
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
			[aCommandQuery
				isEnabled: (self selectedClass ifNil: [false] ifNotNil: [:classService | classService isTestCase]).
			^true].
	(#( #runSelected #runMethodTests #runAndMesureTime #debug) includes: command)
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
	command == #cloneProject
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
	selection wasRemoved ifTrue: [^self].
	selection meta: self isClassSideSelected.
	selection selectedPackageServices: packageListPresenter selections browser: self.
	selection
		updateAfterCommand: false;
		command: #fastRefresh.
	self issueCommand: (Array with: selection).
	selection updateAfterCommand: true.
	self updateClassInfo!

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

refreshFromServer
	| services |
	services := OrderedCollection with: RowanBrowserService new.
	projectListPresenter selections isEmpty ifFalse: [services addAll: projectListPresenter selections].
	packageListPresenter selections isEmpty ifFalse: [services addAll: packageListPresenter selections].
	classListPresenter selectionOrNil ifNotNil: [:classService | services add: classService].
	classHierarchyPresenter selectionOrNil ifNotNil: [:classService | services add: classService].
	self updateServices: services.
	self updateSUnitTab.
	self redrawAllViews!

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
	BrowserUpdate current register: projectListPresenter 		selector: #projectsUpdate:.
	BrowserUpdate current register: projectListPresenter 		selector: #aborted:browser: browser: self.
	BrowserUpdate current register: classListPresenter 		selector: #classesUpdate:browser: browser: self.
	BrowserUpdate current register: classListPresenter 		selector: #removedClass:.
	BrowserUpdate current register: classListPresenter 		selector: #updatedClass:browser: browser: self.
	BrowserUpdate current register: classDefinitionPresenter 	selector: #updatedClassDefinition:browser: browser: self.
	BrowserUpdate current register: classListPresenter 		selector: #removed:.
	BrowserUpdate current register: packageListPresenter 	selector: #projectPackagesUpdate:browser: browser: self.
	BrowserUpdate current register: packageListPresenter 	selector: #removed:.
	BrowserUpdate current register: packageListPresenter 	selector: #packageUpdate:.
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
	| selection |
	selection := self selectedClass ifNil: [^self].
	(MessageBox confirm: 'Really delete class ' , selection name , '?') ifFalse: [^self].
	self basicRemoveClass: selection!

removeMethodCategories
	| selections |
	selections := categoryListPresenter selections.
	selections isEmpty ifTrue: [^MessageBox notify: 'No categories selected'].
	(self confirmCategoryRemoval: selections) ifFalse: [^self].
	self basicRemoveMethodCategories!

removeMethods: services
	services do: 
			[:classService |
			classService
				command: #removeMethods:;
				commandArgs: (Array with: methodListPresenter selections)].
	self issueCommand: services!

renameClass
	| oldClassService newClassName |
	oldClassService := self selectedClass ifNil: [^MessageBox notify: 'Class must be selected'].
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
		backcolor: JadeTextStyles default colorForNoEdits;
		isReadOnly: false. !

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

	instanceClassTabs lastCard!

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
	source := source copyFrom: 2 to: source size - 1.	"copy without extra single quotes"
	className := ex additionalArgs second.
	failedMethodService := RowanMethodService
				fakeMethodFor: className
				selector: #methodFailingRecompile
				source: source.
	failedMethodService category: 'other'.
	(browser := JadeiteMethodListBrowser showOnSession: gciSession) primaryPresenter
		methods: (Array with: failedMethodService)
		selecting: nil.
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
	methodListPresenter selections notEmpty ifFalse: [self cleanupComparisonBrowser]!

sunitPresenter
	"for testing"

	^sunitPresenter!

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

updateAfterFindClass: classService
	| projectService packageService |
	self updateService: classService.
	projectService := projectListPresenter list
				detect: [:service | service name = classService projectName]
				ifNone: [^self].
	projectListPresenter selections: (Array with: projectService).
	packageService := packageListPresenter list
				detect: [:service | service name = classService definedPackageName]
				ifNone: [^self].
	packageListPresenter selections: (Array with: packageService).
	self isClassListTabSelected
		ifTrue: [self selectClassNamed: classService name asString]
		ifFalse: 
			[self selectClassInClassListNamed: classService name.
			self updateHierarchy]!

updateAndSelectA: aView
	"is this override still needed?"
	self updateMenuBar.
	aView notNil ifTrue: [aView ensureVisible].
!

updateAutoCommit
	| autoCommitButtonView |
	autoCommitButtonView := self topShell view viewNamed: 'autoCommitButton'.
	autoCommit value == #failed ifTrue: [^autoCommitButtonView backcolor: Color red].
	autoCommit value
		ifTrue: [autoCommitButtonView backcolor: Color green]
		ifFalse: [autoCommitButtonView backcolor: Color default]!

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
	classDefinitionPresenter ensureVisible.
	self sundryCleanup.
	definedClassPackageText view text: 'Defined Package: ' , self selectedClass definedPackageName.
	self updateClassMenu: nil.
	self updateSUnitTab.!

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

updateHierarchy
	| service |
	classHierarchyPresenter model: TreeModel new.
	packageListPresenter selectionOrNil ifNil: [^self].
	Cursor wait showWhile: 
			[service := classListPresenter selectionOrNil ifNil: [packageListPresenter selection].
			service command: #classHierarchy.
			self issueCommand: (Array with: service).
			service isPackageService
				ifTrue: [service hierarchyServices: Array new]
				ifFalse: [service name = 'Object' ifFalse: [self selectClassNamed: service name]]]!

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
			with: (methodListPresenter selections at: 2) source.!

updatePackage
	classListPresenter model: ListModel new.
	classHierarchyPresenter model: TreeModel new.
	self updateClasses.
	self isClassListTabSelected ifFalse:[self updateHierarchy].
	self updatePackageInfo!

updatePackageInfo
	| service |
	self updateSystemTab.
	service := packageListPresenter selectionIfNone: [^self].
	classDefinitionPresenter value: service defaultTemplate.
	self resetClassDefinitionPane.
	classCommentPresenter view
		backcolor: JadeTextStyles default colorForNoEdits;
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
	self updateSystemTab.
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

updateSystemTab
	| projectTabLabel |
	projectTabLabel := self projectTabLabel.
	self topShell cardsPresenter view currentCard arrangement: projectTabLabel.
	self parentPresenter view updateTabs!

updateTabLabel
	self updateSystemTab!

writeProject
	| projectServices ws |
	projectServices := projectListPresenter selections.
	ws := WriteStream on: String new.
	projectServices do: 
			[:service |
			ws
				nextPutAll: service name;
				space].
	(MessageBox confirm: 'Write projects - ' , ws contents , '- to disk without committing?')
		ifFalse: [^false].
	projectServices do: [:service | service command: #write].
	self issueCommand: projectServices.
	MessageBox notify: 'Projects ' ,  ws contents  , ' written to disk'.
	self refreshFromServer. ! !
!JadeiteProjectsBrowserPresenter categoriesFor: #abortTransaction!event handlers!menu handlers!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #aboutToChange:!event handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #addNoneProject!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #addPackage!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #addPackageDictionaryInfoTo:!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #addSubclass!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #addSystemBrowser!menu handlers!public! !
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
!JadeiteProjectsBrowserPresenter categoriesFor: #browseMethodHistory!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #browseSelectedClass!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #browseSelectedMethods!menu handlers!public!queries! !
!JadeiteProjectsBrowserPresenter categoriesFor: #categoriesMenuStrings!menus!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #categoryListPresenter!accessing!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #checkout!project menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #classCommentPresenter!accessing!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #classDefinitionPresenter!accessing!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #classesMenuStrings!menus!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #classHierarchyTabs!accessing!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #cleanupComparisonBrowser!initialize/release!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #clearFilterLists!event handlers support!private!updating! !
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
!JadeiteProjectsBrowserPresenter categoriesFor: #editSaveClass!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #editSaveClassComment!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #editSaveMethod!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #expandHierarchyAt:!event handlers!public!updating! !
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
!JadeiteProjectsBrowserPresenter categoriesFor: #gciSession:!accessing!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #getterMethodSourceFor:!menu handlers support!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #getViews!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #gitCommit!project menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #gotoClass!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #gotoClassDefinedPackage!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #gotoClassDefinedPackageViaButton!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #gotoDictionary!menu handlers!public! !
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
!JadeiteProjectsBrowserPresenter categoriesFor: #isDictionariesTabSelected!public!testing! !
!JadeiteProjectsBrowserPresenter categoriesFor: #isHierarchyTabSelected!public!testing! !
!JadeiteProjectsBrowserPresenter categoriesFor: #isOkayToChange!event handlers!public!testing! !
!JadeiteProjectsBrowserPresenter categoriesFor: #isSourceTabSelected!public!testing! !
!JadeiteProjectsBrowserPresenter categoriesFor: #isSunitTabSelected!public!testing! !
!JadeiteProjectsBrowserPresenter categoriesFor: #jadeDebug!menu handlers!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #jadeDisplay!menu handlers!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #jadeExecute!menu handlers!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #jadeInspect!menu handlers!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #jadeMenuStrings!menus!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #loadProjects!project menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #makeDefault!project menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #methodCategoryText!accessing!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #methodListPresenter!accessing!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #methodListSelection!accessing!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #methodMenuBreak:!menus!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #methodSelectionChanged!event handlers!public!text tabs!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #methodsMenuStrings!menus!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #methodSourcePresenter:!accessing!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #methodSourcePresenter1!accessing!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #moveMethods:toCategory:!drag & drop!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #newBrowser!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #onDragClass:!drag & drop!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #onDragClassHierarchy:!drag & drop!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #onDragMethod:!drag & drop!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #onDropMethodsOnClassHierarchy:!drag & drop!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #onDropOnClassList:!drag & drop!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #onDropOnMethodCategory:!drag & drop!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #onSetFocus!event handlers!public! !
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
!JadeiteProjectsBrowserPresenter categoriesFor: #projectMenu!menus!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #projectMenuCommands!menus!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #projectMenuStrings!menus!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #projectTabLabel!displaying!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #pullFromGit!project menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #pushToGit!project menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #queryCommand:!menu handlers support!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #redrawAllViews!displaying!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #refreshClass!event handlers!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #refreshClassListOrHierarchy!event handlers!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #refreshFromServer!event handlers!menu handlers!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #refreshMethodsOn:!event handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #registerClassData!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #registerPresentersForUpdates!event handlers!initialize/release!private!register presenters! !
!JadeiteProjectsBrowserPresenter categoriesFor: #releasedReferencedServices:!event handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #removeClass!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #removeMethodCategories!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #removeMethods:!private!services! !
!JadeiteProjectsBrowserPresenter categoriesFor: #renameClass!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #renameMethodCategory!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #resetCategoryText!event handlers support!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #resetClassDefinitionPane!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #resetClassTemplate!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #resetDefinedClassPackage!event handlers support!private! !
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
!JadeiteProjectsBrowserPresenter categoriesFor: #targetCategory!menu handlers support!private! !
!JadeiteProjectsBrowserPresenter categoriesFor: #textAreaTabs!private!text tabs! !
!JadeiteProjectsBrowserPresenter categoriesFor: #textTabChanged!event handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #textTabs!private!text tabs! !
!JadeiteProjectsBrowserPresenter categoriesFor: #unloadPackage!menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #unloadProjects!project menu handlers!public! !
!JadeiteProjectsBrowserPresenter categoriesFor: #update:afterStonReplication:!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updateAfterFindClass:!menu handlers!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updateAndSelectA:!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updateAutoCommit!public!register presenters!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updateClasses!event handlers!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updateClassInfo!event handlers!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updateClassMenu:!event handlers!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updateCommand:onSuccessDo:!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updateHierarchy!event handlers!public!updating! !
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
!JadeiteProjectsBrowserPresenter categoriesFor: #updateSystemTab!event handlers support!private!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #updateTabLabel!public!updating! !
!JadeiteProjectsBrowserPresenter categoriesFor: #writeProject!project menu handlers!public! !

!JadeiteProjectsBrowserPresenter class methodsFor!

downArrowIcon

	^Icon fromId: 'DownArrow.ico'.
!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil nil 5 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 6 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 544 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 nil 5 nil nil nil 544 655878 ##(Smalltalk.CardLayout) 138 144 34 6 721414 ##(Smalltalk.Association) 590662 1 ##(Smalltalk.CardLabel) 8 'SUnit' 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 4 1 800 8 'doIt' 8 '[Icon fromId: ''icons\UnitTestPlugin.ico'']' 8 #[32 105 45 30 178 106] 983558 ##(Smalltalk.VariableBinding) #Icon ##(Smalltalk.Icon) 8 'icons\UnitTestPlugin.ico' #fromId: 816 7 1 nil nil 410 ##(Smalltalk.ReferenceView) 34 14 nil 544 34 2 8 1140850688 131073 960 nil 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 nil nil nil 960 1180166 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteSUnitInClassPresenter) #resource_Default_view nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 328198 ##(Smalltalk.Point) 9 55 1202 2225 607 960 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 74 1 0 0] 8 #() 1202 193 193 nil 27 722 754 8 'Class Definition' nil nil 410 ##(Smalltalk.ScintillaView) 34 50 nil 544 34 2 8 1445007428 1025 1376 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 1026 26337781 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 11 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #editSave 8 '&Save' 9383 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 1570 1 1602 #editUndo 8 '&Undo' 9397 1 nil nil nil 1570 1 1602 #editRedo 8 '&Redo' 9395 1 nil nil nil 1650 4097 1570 1 1602 #editCut 8 'Cu&t' 9393 1 nil nil nil 1570 1 1602 #editCopy 8 '&Copy' 9351 1 nil nil nil 1570 1 1602 #editPaste 8 '&Paste' 9389 1 nil nil nil 1570 1 1602 #editDelete 8 '&Delete' 1629 1 nil nil nil 1650 4097 1570 1 1602 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 1202 193 193 nil 1376 nil 8 4294902221 852486 ##(Smalltalk.NullConverter) nil nil 13 nil 170 192 34 4 #normal 1182790 1 ##(Smalltalk.ScintillaTextStyle) 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 2242 77 786694 ##(Smalltalk.IndexedColor) 33554457 2290 33554471 1 nil nil nil nil #callTip nil nil nil 34 256 2256 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 2272 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1639686 ##(Smalltalk.SmalltalkExpressionStyler) 1 nil nil false 138 144 1296 170 192 34 2 #default 1641542 1 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 1376 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1296 nil 170 176 1296 9215 nil nil nil nil 2290 33554447 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 2256 nil nil nil nil 1 nil 170 192 34 6 1 1510470 2 ##(Smalltalk.ScintillaIndicatorStyle) 1 1376 65025 3 false 1 nil nil nil nil nil nil 3 2706 3 1376 33423361 5 false 3 nil nil nil nil nil nil 5 2706 5 1376 511 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 2242 1029 nil 1026 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 2242 1027 1026 60239 1026 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2242 1031 1026 335 1026 31317503 1 nil nil nil nil #Error nil nil nil nil 1090 138 144 34 8 1154 #createAt:extent: 34 2 1202 9 55 1202 2225 607 1376 1154 #contextMenu: 34 1 1536 1376 1154 #modificationEventMask: 8 #(4607) 1376 1154 #caretPeriod: 8 #(530) 1376 1154 #wordWrap: 8 #(true) 1376 1154 #margins: 34 1 34 3 985158 2 ##(Smalltalk.ScintillaMargin) 1 1376 1 3 nil nil 5 nil 3218 3 1376 33 nil 3 67108863 5 nil 3218 5 1376 1 nil 3 -67108863 5 nil 1376 1154 #tabWidth: 8 #(4) 1376 1154 #maxCompletionListHeight: 8 #(9) 1376 1250 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 74 1 0 0] 8 #() 1312 nil 29 722 754 8 'Class Documentation' nil nil 410 ##(Smalltalk.ScintillaView) 34 50 nil 544 34 2 8 1445007428 1025 3440 1442 nil false 1488 nil 1026 26337781 nil 5 1522 nil true 34 1 1570 1 1602 #editSaveClassComment 8 'Save' 1025 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil 2066 nil true 2098 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 1202 193 193 nil 3440 nil 8 4294902221 2178 nil nil 11 nil 170 192 34 4 #normal 2242 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 2242 77 2304 2320 1 nil nil nil nil #callTip nil nil nil 34 256 3760 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3776 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 2434 1 nil nil nil 3440 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1296 nil 170 176 1296 9215 nil nil nil nil 2496 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 3760 nil nil nil nil 1 nil 170 192 34 6 1 2706 1 3440 65025 3 false 1 nil nil nil nil nil nil 3 2706 3 3440 33423361 5 false 3 nil nil nil nil nil nil 5 2706 5 3440 511 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 2242 1029 nil 1026 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 2242 1027 1026 60239 1026 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2242 1031 1026 335 1026 31317503 1 nil nil nil nil #Error nil nil nil nil 1090 138 144 34 8 1154 #createAt:extent: 34 2 1202 9 55 1202 2225 607 3440 1154 #contextMenu: 34 1 3536 3440 1154 #modificationEventMask: 8 #(4607) 3440 1154 #caretPeriod: 8 #(530) 3440 1154 #wordWrap: 8 #(true) 3440 1154 #margins: 34 1 34 3 3218 1 3440 1 3 nil nil 5 nil 3218 3 3440 33 nil 3 67108863 5 nil 3218 5 3440 1 nil 3 -67108863 5 nil 3440 1154 #tabWidth: 8 #(4) 3440 1154 #maxCompletionListHeight: 8 #(9) 3440 1250 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 74 1 0 0] 8 #() 1312 nil 29 722 754 8 'Method Source' nil nil 410 ##(Smalltalk.ScintillaView) 34 50 nil 544 34 2 8 1445007428 1025 4736 1442 nil false 1488 nil 1026 26337781 nil 5 nil 2066 nil true 2098 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 1202 193 193 nil 4736 nil 8 4294902221 2178 nil nil 13 nil 170 192 34 4 #normal 2242 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 2242 77 2304 2320 1 nil nil nil nil #callTip nil nil nil 34 256 4960 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 4976 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 1296 170 192 34 2 #default 2434 1 nil nil nil 4736 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1296 nil 170 176 1296 9215 nil nil nil nil 2496 nil nil 65 nil nil 2512 8 '' 3 170 192 34 2 #container 170 192 34 4 #normal 4960 #callTip 4976 nil nil nil nil 1 nil 170 192 34 12 1 2706 1 4736 65025 3 false 1 nil nil nil nil nil nil 3 2706 3 4736 33423361 5 false 3 nil nil nil nil nil nil 5 2706 5 4736 511 1 false 5 nil nil nil nil nil nil 8 'indicator9' 2706 19 4736 33554459 13 nil nil nil nil nil nil nil nil 8 'indicator8' 2706 17 4736 33554447 1 nil nil nil nil nil nil nil nil 8 'indicator10' 2706 21 4736 33554459 3 nil nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 2242 1029 nil 1026 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 2242 1027 1026 60239 1026 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2242 1031 1026 335 1026 31317503 1 nil nil nil nil #Error nil nil nil nil 1090 138 144 34 8 1154 #createAt:extent: 34 2 1202 9 55 1202 2225 607 4736 1154 #modificationEventMask: 8 #(4607) 4736 1154 #hoverTime: 8 #(200) 4736 1154 #caretPeriod: 8 #(530) 4736 1154 #wordWrap: 8 #(true) 4736 1154 #margins: 34 1 34 3 3218 1 4736 61 3 nil nil 5 nil 3218 3 4736 1 nil 3 67108863 nil nil 3218 5 4736 1 nil 3 -67108863 nil nil 4736 1154 #tabWidth: 8 #(4) 4736 1154 #maxCompletionListHeight: 8 #(9) 4736 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 74 1 0 0] 8 #() 1312 nil 29 722 754 8 'Project' 802 0 nil 834 4 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[Icon fromId: ''Collection.ico'']' 8 #[32 105 45 30 178 106] 914 #Icon ##(Smalltalk.Icon) 8 'Collection.ico' #fromId: 6048 7 1 nil nil 410 ##(Smalltalk.ListView) 34 30 nil 544 34 2 8 1409372237 1025 6160 590662 2 ##(Smalltalk.ListModel) 138 144 1296 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 1026 26337781 nil 5 1522 nil true 34 1 1570 1 1602 #copyProjectInfo 8 'Copy' 1025 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 6160 nil 8 4294902179 459270 ##(Smalltalk.Message) #displayString 8 #() nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 2 920646 5 ##(Smalltalk.ListViewColumn) 8 'Name' 351 #left 6434 #displayString 6464 ##(Smalltalk.SortedCollection) 802 0 nil 834 1 83886081 800 8 'doIt' 8 '[:each | (each at: 2)]' 8 #[29 105 17 64 148 106] 6608 7 257 nil nil 6160 nil 1 nil 802 0 nil 834 3 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | (each item at: 1) displayStringFor: each]' 8 #[31 105 226 0 63 148 17 177 106] #item #displayStringFor: 6688 7 257 nil 6546 8 'Value' 1867 #left 6434 #displayString 8 #() 6434 #<= 6816 802 0 nil 834 4 1 800 8 'doIt' 8 '[:each | (each at: 2) ifNil:[String new] ifNotNil: [:iv |
(each at: 1) instVarNamed: iv]]' 8 #[32 105 17 64 148 100 223 4 97 45 146 106 90 17 63 148 18 178 106] 914 #String 16 #ifNil:ifNotNil: #instVarNamed: 6848 7 65793 nil nil 6160 nil 3 nil nil #report 1296 nil 131169 nil 34 4 nil nil 1202 1 1 nil 1090 138 144 34 3 1154 #createAt:extent: 34 2 1202 9 55 1202 2225 607 6160 1154 #contextMenu: 34 1 6320 6160 1154 #text: 34 1 8 'Name' 6160 1250 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 74 1 0 0] 8 #() 1312 nil 27 722 8 'Comparison' 410 ##(Smalltalk.ShellView) 34 27 nil 544 34 2 8 1078919168 131073 7248 nil 610 8 4278190080 nil 517 nil nil nil 7248 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 7248 34 2 8 1140850688 131073 7376 nil 1026 26337781 nil 5 1522 nil true 34 5 1570 1 1602 #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 1570 1 1602 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 1570 1 1602 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 1570 1 1602 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 1570 1 1602 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 7376 482 170 176 1296 false 170 192 1296 nil 1090 138 144 34 2 1154 #createAt:extent: 34 2 1202 1 1 1202 2193 575 7376 1154 #contextMenu: 34 1 7456 7376 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 4 0 0 31 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 7376 34 2 8 1140850688 131073 7984 nil 610 7328 nil 5 nil nil nil 7984 7346 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 7984 34 2 8 1140850945 262145 8080 nil nil nil 5 nil nil nil 8080 nil 8 1686791472 2178 nil nil nil 1090 138 144 34 2 1154 #createAt:extent: 34 2 1202 1 535 1202 1091 41 8080 1154 #text: 34 1 8 '
' 8080 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 11 1 0 0 33 2 0 0 31 1 0 0] 8 #() 1312 nil 27 nil nil 410 ##(Smalltalk.ScintillaView) 34 50 nil 7984 34 2 8 1140920580 1025 8384 1442 nil false 1488 nil 1026 26337781 nil 5 nil nil nil 8384 nil 8 4294902221 2178 nil nil 11 nil 170 192 34 12 #indentGuide 2242 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 2242 3 2290 33554445 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 2242 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 2242 77 2304 2320 1 nil nil nil nil #callTip nil nil nil #normal 2242 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 2242 5 nil 1026 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 8624 8560 8640 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 8592 nil nil nil 8544 nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 2434 1 nil nil nil 8384 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1296 nil 170 176 1296 9215 nil nil nil nil 2496 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 8512 nil nil nil nil 1 nil 170 192 34 6 8 'indicator1' 2706 3 8384 33423361 5 false nil nil nil nil nil nil nil 8 'indicator2' 2706 5 8384 511 1 false nil nil nil nil nil nil nil 8 'indicator0' 2706 1 8384 33554459 13 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 2242 1029 nil 1026 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 2242 1027 1026 60239 1026 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2242 1031 1026 335 1026 31317503 1 nil nil nil nil #Error nil nil nil nil 1090 138 144 34 7 1154 #createAt:extent: 34 2 1202 1 1 1202 1091 535 8384 1154 #modificationEventMask: 8 #(4607) 8384 1154 #caretPeriod: 8 #(530) 8384 1154 #wordWrap: 8 #(true) 8384 1154 #margins: 34 1 34 3 3218 1 8384 49 3 nil nil nil nil 3218 3 8384 1 nil nil 67108863 nil nil 3218 5 8384 1 nil nil nil nil nil 8384 1154 #canHScroll: 8 #(false) 8384 1154 #maxCompletionListHeight: 8 #(9) 8384 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 11 1 0 0] 8 #() 1312 nil 29 170 192 34 4 8080 8 'beforeTitle' 8384 8 'before' nil 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1 1 1202 1091 575 7984 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 33 2 0 0 31 1 0 0] 34 2 8384 8080 1312 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 7376 34 2 8 1140850688 1 9792 nil 1026 66047 nil 517 nil nil nil 9792 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1091 1 1202 11 575 9792 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 33 2 0 0 0 0 0 0 38 2 0 0 31 1 0 0] 8 #() 1312 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 7376 34 2 8 1140850688 131073 10032 nil 610 7328 nil 5 nil nil nil 10032 7346 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 10032 34 2 8 1140850945 262145 10128 nil nil nil 5 nil nil nil 10128 nil 8 1686791472 2178 nil nil nil 1090 138 144 34 2 1154 #createAt:extent: 34 2 1202 1 535 1202 1093 41 10128 1154 #text: 34 1 8 '
' 10128 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 11 1 0 0 34 2 0 0 31 1 0 0] 8 #() 1312 nil 27 nil nil 410 ##(Smalltalk.ScintillaView) 34 50 nil 10032 34 2 8 1140920580 1025 10432 1442 nil false 1488 nil 1026 26337781 nil 5 nil nil nil 10432 nil 8 4294902221 2178 nil nil 11 nil 170 192 34 12 #indentGuide 2242 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 2242 3 8576 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 2242 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 2242 77 2304 2320 1 nil nil nil nil #callTip nil nil nil #normal 2242 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 2242 5 nil 1026 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 10656 10608 10672 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 10624 nil nil nil 10592 nil nil 8690 8720 170 192 34 2 #default 2434 1 nil nil nil 10432 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1296 nil 170 176 1296 9215 nil nil nil nil 2496 nil nil 65 nil nil nil 8816 3 170 192 34 2 #container 10560 nil nil nil nil 1 nil 170 192 34 6 8 'indicator2' 2706 5 10432 511 1 false nil nil nil nil nil nil nil 8 'indicator1' 2706 3 10432 33423361 5 false nil nil nil nil nil nil nil 8 'indicator0' 2706 1 10432 33554459 13 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 2242 1029 nil 1026 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 2242 1027 1026 60239 1026 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2242 1031 1026 335 1026 31317503 1 nil nil nil nil #Error nil nil nil nil 1090 138 144 34 7 1154 #createAt:extent: 34 2 1202 1 1 1202 1093 535 10432 1154 #modificationEventMask: 8 #(4607) 10432 1154 #caretPeriod: 8 #(530) 10432 1154 #wordWrap: 8 #(true) 10432 1154 #margins: 34 1 34 3 3218 1 10432 49 3 nil nil nil nil 3218 3 10432 1 nil nil 67108863 nil nil 3218 5 10432 1 nil nil nil nil nil 10432 1154 #canHScroll: 8 #(false) 10432 1154 #maxCompletionListHeight: 8 #(9) 10432 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 34 2 0 0 11 1 0 0] 8 #() 1312 nil 29 170 192 34 4 10432 8 'after' 10128 8 'afterTitle' nil 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1101 1 1202 1093 575 10032 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 38 2 0 0 0 0 0 0 72 4 0 0 31 1 0 0] 34 2 10432 10128 1312 nil 27 1312 nil 27 170 192 34 2 7376 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 1522 nil true 34 4 1570 1 1602 #selectUpper 8 'Select &upper' 1 1 nil nil nil 1570 1 1602 #selectLower 8 'Select &lower' 1 1 nil nil nil 1650 4097 1570 1 1602 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 17931 nil nil 1522 nil true 34 3 1570 1 1602 #character 8 '&Character' 1 1 nil nil nil 1570 1 1602 #word 8 '&Word' 1 1 nil nil nil 1570 1 1602 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 17933 nil nil 1522 nil true 34 1 1570 1 1602 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 17935 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1090 138 144 34 3 1154 #createAt:extent: 34 2 1202 9 55 1202 2225 607 7248 1154 #text: 34 1 8 'Comparison' 7248 1154 #updateMenuBar 1296 7248 1250 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 92 4 0 0 74 1 0 0] 34 1 7376 1312 nil 27 4736 170 192 34 12 7248 8 'comparisonTab' 1376 8 'classDefinition' 4736 8 'methodSource' 960 8 'sunit' 3440 8 'classDocumentation' 6160 8 'projectInfo' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 544 34 2 8 1140916736 1 12736 6226 138 144 34 6 6016 1344 3408 4704 768 7232 nil 6288 nil nil 1 nil nil nil 12736 nil 8 4294901947 802 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 12864 7 257 nil 802 0 nil 12882 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 12928 7 257 nil 6496 nil nil nil nil nil #smallIcons nil nil nil nil nil 1090 138 144 34 3 1154 #createAt:extent: 34 2 1202 1 1 1202 2241 669 12736 1154 #basicSelectionsByIndex: 34 1 8 #(4) 12736 1154 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 12736 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 78 1 0 0] 8 #() 1312 nil 27 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1 679 1202 2241 669 544 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 83 1 0 0 96 4 0 0 161 2 0 0] 34 7 6160 1376 3440 4736 960 7248 12736 1312 nil 27 524806 ##(Smalltalk.Fraction) 3 5 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 13408 nil nil nil 5 nil nil nil 13408 482 170 176 34 4 410 ##(Smalltalk.TextEdit) 34 16 nil 13408 34 2 8 1140850688 1 13520 nil 610 8 4278190080 nil 5 nil 2066 nil true 2098 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 1202 193 193 nil 13520 2290 33554433 8 4294902835 2178 nil nil 67 1090 138 144 34 2 1154 #createAt:extent: 34 2 1202 65 1 1202 2177 55 13520 1154 #setMarginWidths: 34 1 8 #(3 3) 13520 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 32 0 0 0 0 0 0 0 96 4 0 0 27 0 0 0] 8 #() 1312 nil 27 3 410 ##(Smalltalk.ToolButton) 34 14 nil 13408 34 2 8 1140850688 131073 13936 nil nil nil 5 nil nil nil 13936 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 13936 34 2 8 1140853580 131137 14000 nil nil nil 1 nil nil nil 14000 nil 8 4294902389 nil 170 192 34 2 16781 1115910 ##(Smalltalk.ToolbarIconButton) 16781 nil 14000 1 1602 #flipAutoCommit 8 'Auto Commit' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons/camera16_light_icon.ico' nil 395334 3 ##(Smalltalk.Bitmap) nil true nil nil nil nil 3 1202 49 49 1 34 1 14128 170 176 34 2 14272 1 nil 3 nil 1202 49 49 1202 55 45 nil nil 1090 138 144 34 2 1154 #createAt:extent: 34 2 1202 1 1 1202 65 55 14000 1154 #updateSizePosted 1296 14000 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 32 0 0 0 27 0 0 0] 8 #() 1312 nil 27 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1 1 1202 65 55 13936 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 32 0 0 0 27 0 0 0] 34 1 14000 1312 nil 27 327734 ##(Smalltalk.Float) 8 184 30 133 235 81 184 158 63 false 170 192 34 4 13520 8 'statusBarField' 13936 8 'autoCommitButton' nil 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1 1347 1202 2241 55 13408 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 161 2 0 0 96 4 0 0 188 2 0 0] 34 2 13936 13520 1312 nil 27 14722 8 123 20 174 71 225 122 164 63 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 14992 nil nil nil 5 nil nil nil 14992 482 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 14992 34 2 8 1140850688 131073 15104 nil nil nil 5 nil nil nil 15104 482 170 176 34 6 410 ##(Smalltalk.ContainerView) 34 15 nil 15104 34 2 8 1140850688 131073 15216 nil nil nil 5 nil nil nil 15216 482 170 176 1296 false 170 192 34 2 410 ##(Smalltalk.ListView) 34 30 nil 15216 34 2 8 1140936777 1025 15344 6226 138 144 1296 nil 6288 610 8 4278190080 nil 21 nil nil nil 15344 nil 8 4294902179 6434 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 6496 nil nil nil nil nil nil 138 144 34 1 6546 8 'Column 1' 503 #left 802 0 nil 834 2 1 800 8 'doIt' 8 '[:each | each name]' 8 #[30 105 226 0 106] #name 15584 7 257 nil 6434 #<= 8 #() nil nil 15344 nil 3 802 0 nil 834 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 15696 7 257 nil 802 0 nil 834 3 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 15776 7 257 nil #report 1296 nil 133217 nil 34 4 nil nil 1202 1 1 nil 1090 138 144 34 2 1154 #createAt:extent: 34 2 1202 1 1 1202 511 669 15344 1154 #text: 34 1 8 'Column 1' 15344 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 78 1 0 0] 8 #() 1312 nil 27 8 'packagesList' nil 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 351 1 1202 511 669 15216 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 175 0 0 0 0 0 0 0 174 1 0 0 78 1 0 0] 34 1 15344 1312 nil 27 13378 7 11 410 ##(Smalltalk.ListView) 34 30 nil 15104 34 2 8 1409405257 1025 16288 6226 138 144 1296 nil 6288 610 8 4278190080 nil 5 nil nil nil 16288 nil 8 4294902179 6434 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 6496 nil nil nil nil nil nil 138 144 34 1 6546 8 'Column 1' 333 #left 802 0 nil 834 2 1 800 8 'doIt' 8 '[:each | each displayName]' 8 #[30 105 226 0 106] #displayName 16528 7 257 nil ##(Smalltalk.SortedCollection) nil nil 16288 nil 3 802 0 nil 834 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 16608 7 257 nil 802 0 nil 834 3 1 800 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 16688 7 257 nil #report 1296 nil 133217 nil 34 4 nil nil 1202 1 1 nil 1090 138 144 34 2 1154 #createAt:extent: 34 2 1202 1 1 1202 341 669 16288 1154 #text: 34 1 8 'Column 1' 16288 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 170 0 0 0 78 1 0 0] 8 #() 1312 nil 27 13378 5 11 410 ##(Smalltalk.ContainerView) 34 15 nil 15104 34 2 8 1140850688 131073 17024 nil nil nil 5 nil nil nil 17024 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.TextEdit) 34 16 nil 17024 34 2 8 1140916352 1025 17152 nil 610 8 4278190080 nil 5 nil nil nil 17152 nil 8 4294902835 2178 nil nil 3 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1 619 1202 511 51 17152 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 53 1 0 0 255 0 0 0 78 1 0 0] 8 #() 1312 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 17474 #fixedParentRight 1 17474 #fixedParentBottom -49 17520 1 410 ##(Smalltalk.CardContainer) 34 16 nil 17024 34 2 8 1409286144 131073 17536 nil 610 8 4278190080 nil 5 nil nil nil 17536 658 138 144 34 2 722 754 8 'Instance' 802 0 nil 834 7 1 16 8 'doIt' 8 '(CardLabel text: ''Instance'' iconBlock: [Icon fromId: ''Class.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 752 17712 14176 8 'Class.ico' #fromId: #text:iconBlock: 17728 11 1 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 17536 34 2 8 1140850688 131073 17824 nil nil nil 5 nil nil nil 17824 nil 170 192 1296 nil 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 9 9 1202 495 1 17824 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 251 0 0 0 4 0 0 0] 8 #() 1312 nil 27 722 754 8 'Class' 802 0 nil 834 7 1 16 8 'doIt' 8 '(CardLabel text: ''Class'' iconBlock: [Icon fromId: ''Metaclass.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 752 18096 14176 8 'Metaclass.ico' #fromId: #text:iconBlock: 18112 11 1 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 17536 34 2 8 1140850688 131073 18208 nil nil nil 5 nil nil nil 18208 nil 170 192 1296 nil 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 9 9 1202 495 1 18208 1250 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 251 0 0 0 4 0 0 0] 8 #() 1312 nil 27 17824 170 192 34 4 18208 8 'classTab' 17824 8 'instanceTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 17536 34 2 8 1140916738 1 18512 6226 138 144 34 2 17696 18080 nil 6288 nil nil 1 nil nil nil 18512 nil 8 4294901947 802 0 nil 12882 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 18640 7 257 nil 802 0 nil 12882 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 18688 7 257 nil 6496 nil nil nil nil nil #smallIcons nil nil nil nil nil 1090 138 144 34 3 1154 #createAt:extent: 34 2 1202 1 1 1202 511 51 18512 1154 #basicSelectionsByIndex: 34 1 8 #(1) 18512 1154 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 18512 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 25 0 0 0] 8 #() 1312 nil 27 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1 569 1202 511 51 17536 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 28 1 0 0 255 0 0 0 53 1 0 0] 34 3 17824 18208 18512 1312 nil 27 17442 17488 1 17504 1 17520 -99 17474 #fixedViewTop 51 410 ##(Smalltalk.CardContainer) 34 16 nil 17024 34 2 8 1409286144 131073 19168 nil 610 640 nil 5 nil nil nil 19168 658 138 144 34 2 722 754 8 'Classes' 802 0 nil 834 7 1 16 8 'doIt' 8 '(CardLabel text: ''Classes'' iconBlock: [Icon fromId: ''Class.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 752 19328 14176 8 'Class.ico' #fromId: #text:iconBlock: 19344 11 1 nil nil 410 ##(Smalltalk.ListView) 34 30 nil 19168 34 2 8 1409372237 1025 19440 6226 138 144 1296 nil 6288 610 16400 nil 21 nil nil nil 19440 nil 8 4294902179 6434 #displayString 8 #() nil 6496 nil nil nil nil nil nil 138 144 34 1 6546 8 '' 487 #left 6434 #displayString 8 #() 6434 #<= 8 #() nil nil 19440 nil 3 nil 802 0 nil 834 3 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 19728 7 257 nil #report 1296 nil 131169 nil 34 4 nil nil 1202 1 1 nil 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 9 55 1202 495 507 19440 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 251 0 0 0 24 1 0 0] 8 #() 1312 nil 27 722 754 8 'Hierarchy' 802 0 nil 834 7 1 16 8 'doIt' 8 '(CardLabel text: ''Hierarchy'' iconBlock: [Icon fromId: ''ClassHierarchyDiagram.ico''])' 8 #[29 30 35 113 31 32 180 106 195 105] 752 20032 14176 8 'ClassHierarchyDiagram.ico' #fromId: #text:iconBlock: 20048 11 1 nil nil 410 ##(Smalltalk.TreeView) 34 27 nil 19168 34 2 8 1409352231 1025 20144 590918 3 ##(Smalltalk.TreeModel) nil 6288 525062 ##(Smalltalk.TreeNode) nil nil nil 170 192 1296 610 8 4278190080 nil 21 nil nil nil 20144 nil 8 4294902623 802 0 nil 834 2 1 800 8 'doIt' 8 '[:each | each displayString]' 8 #[30 105 226 0 106] #displayString 20336 7 257 nil ##(Smalltalk.IconicListAbstract) 6496 nil 802 0 nil 834 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each toolTip]' 8 #[30 105 226 0 106] #toolTip 20416 7 257 nil 802 0 nil 834 3 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 20496 7 257 nil nil nil 170 176 1296 17 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 1296 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 9 55 1202 495 507 20144 1250 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 251 0 0 0 24 1 0 0] 8 #() 1312 nil 27 19440 170 192 34 4 19440 8 'classList' 20144 8 'classHierarchy' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 19168 34 2 8 1140916736 1 20832 6226 138 144 34 2 19312 20016 nil 6288 nil nil 1 nil nil nil 20832 nil 8 4294901947 802 0 nil 12882 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 20960 7 257 nil 802 0 nil 12882 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 21008 7 257 nil 6496 nil nil nil nil nil #smallIcons nil nil nil nil nil 1090 138 144 34 3 1154 #createAt:extent: 34 2 1202 1 1 1202 511 569 20832 1154 #basicSelectionsByIndex: 34 1 8 #(1) 20832 1154 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 20832 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 28 1 0 0] 8 #() 1312 nil 27 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1 1 1202 511 569 19168 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 0 0 0 28 1 0 0] 34 3 19440 20144 20832 1312 nil 27 17442 17488 1 17504 1 17474 #fixedParentTop 1 17520 -99 170 192 34 6 17152 8 'definedPackageClassText' 17536 8 'instanceClassTabs' 19168 8 'classHierarchyTabs' nil 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 871 1 1202 511 669 17024 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 179 1 0 0 0 0 0 0 178 2 0 0 78 1 0 0] 34 3 19168 17536 17152 1312 nil 27 13378 7 11 false 170 192 34 2 16288 8 'projectList' nil 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1 1 1202 2241 669 15104 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 78 1 0 0] 34 7 16288 410 ##(Smalltalk.Splitter) 34 12 nil 15104 34 2 8 1140850688 1 21952 nil 610 8 4278190080 nil 517 nil nil nil 21952 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 341 1 1202 11 669 21952 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 170 0 0 0 0 0 0 0 175 0 0 0 78 1 0 0] 8 #() 1312 nil 27 15216 410 ##(Smalltalk.Splitter) 34 12 nil 15104 34 2 8 1140850688 1 22208 nil 610 22032 nil 517 nil nil nil 22208 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 861 1 1202 11 669 22208 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 174 1 0 0 0 0 0 0 179 1 0 0 78 1 0 0] 8 #() 1312 nil 27 17024 410 ##(Smalltalk.Splitter) 34 12 nil 15104 34 2 8 1140850688 1 22448 nil 610 22032 nil 517 nil nil nil 22448 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1381 1 1202 11 669 22448 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 178 2 0 0 0 0 0 0 183 2 0 0 78 1 0 0] 8 #() 1312 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 15104 34 2 8 1140850688 131073 22688 nil nil nil 5 nil nil nil 22688 482 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 22688 34 2 8 1140850688 131073 22800 nil nil nil 5 nil nil nil 22800 17090 170 176 34 6 410 ##(Smalltalk.ListView) 34 30 nil 22800 34 2 8 1409372233 1025 22912 6226 138 144 1296 nil 6288 610 8 4278190080 nil 13 nil nil nil 22912 nil 8 4294902179 6434 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 6496 nil nil nil nil nil nil 138 144 34 2 6546 8 '' 41 #left 1154 #empty 8 #() 16 6434 #<= 8 #() nil nil 22912 802 0 nil 834 2 1 800 8 'doIt' 8 '[:each | each subSuperIcon]' 8 #[30 105 226 0 106] #subSuperIcon 23216 7 257 nil 1 nil nil 6546 8 'Selector' 421 #left 6434 #displayString 23072 ##(Smalltalk.SortedCollection) nil nil 22912 nil 3 nil 802 0 nil 834 3 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 23344 7 257 nil #report 1296 nil 133221 nil 34 4 nil nil 1202 1 1 nil 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1 55 1202 469 565 22912 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 27 0 0 0 234 0 0 0 53 1 0 0] 8 #() 1312 nil 27 17442 17488 1 17504 1 21472 55 17520 -49 410 ##(Smalltalk.TextEdit) 34 16 nil 22800 34 2 8 1140916352 1025 23632 nil 610 8 4278190080 nil 5 nil nil nil 23632 nil 8 4294902835 2178 nil nil 3 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1 1 1202 469 51 23632 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 234 0 0 0 25 0 0 0] 8 #() 1312 nil 27 17442 17488 1 17504 1 21472 1 21472 51 410 ##(Smalltalk.TextEdit) 34 16 nil 22800 34 2 8 1140916352 1025 23936 nil 610 17232 nil 5 nil nil nil 23936 nil 8 4294902835 2178 nil nil 3 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1 619 1202 469 51 23936 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 53 1 0 0 234 0 0 0 78 1 0 0] 8 #() 1312 nil 27 17442 17488 1 17504 1 17520 -49 17520 1 170 192 34 6 22912 8 'methodList' 23632 8 'categoryMethodText' 23936 8 'definedPackageMethodText' nil 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 383 1 1202 469 669 22800 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 191 0 0 0 0 0 0 0 169 1 0 0 78 1 0 0] 34 3 22912 23936 23632 1312 nil 27 14722 8 0 0 0 0 0 0 244 63 false 170 192 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 22688 34 2 8 1409286144 131073 24512 nil 610 8 4278190080 nil 5 nil nil nil 24512 658 138 144 34 2 722 8 'Category' 410 ##(Smalltalk.ListView) 34 30 nil 24512 34 2 8 1409372233 1025 24688 6226 138 144 1296 nil 6288 610 23024 nil 21 nil nil nil 24688 nil 8 4294902179 6434 #displayString 8 #() nil 6496 nil nil nil nil nil nil 138 144 34 1 6546 8 'Column 1' 349 #left 6434 #displayString 8 #() ##(Smalltalk.SortedCollection) 802 0 nil 834 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each]' 1779525917 24944 7 257 nil nil 24688 nil 3 nil nil #report 1296 nil 131169 nil 34 4 nil nil 1202 1 1 nil 1090 138 144 34 2 1154 #createAt:extent: 34 2 1202 9 55 1202 357 607 24688 1154 #text: 34 1 8 'Column 1' 24688 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 182 0 0 0 74 1 0 0] 8 #() 1312 nil 27 722 8 'Variables' 410 ##(Smalltalk.ListView) 34 30 nil 24512 34 2 8 1409372233 1025 25280 6226 138 144 1296 nil 6288 610 23024 nil 21 nil nil nil 25280 nil 8 4294902179 6434 #displayString 8 #() nil 6496 nil nil nil nil nil nil 138 144 34 1 6546 8 'Column 1' 349 #left 6434 #displayString 25424 ##(Smalltalk.SortedCollection) nil nil 25280 nil 3 nil 802 0 nil 834 9 1 800 8 'doIt' 8 '[:each | each item first = Character space ifTrue: [each font: (each font beBold; beItalic)]]' 8 #[37 105 226 0 159 31 161 132 221 9 17 226 4 100 163 97 164 183 106 60 106] #item #first ##(Smalltalk.Character) #space #font #beBold #beItalic #font: 25520 7 257 nil #report 1296 nil 131169 nil 34 4 nil nil 1202 1 1 nil 1090 138 144 34 2 1154 #createAt:extent: 34 2 1202 9 55 1202 357 607 25280 1154 #text: 34 1 8 'Column 1' 25280 1250 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 182 0 0 0 74 1 0 0] 8 #() 1312 nil 27 24688 170 192 34 4 25280 8 'variableList' 24688 8 'categoryList' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 24512 34 2 8 1140916736 1 25904 6226 138 144 34 2 24672 25264 nil 6288 nil nil 1 nil nil nil 25904 nil 8 4294901947 802 0 nil 12882 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 26032 7 257 nil 802 0 nil 12882 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 26080 7 257 nil 6496 nil nil nil nil nil #noIcons nil nil nil nil nil 1090 138 144 34 3 1154 #createAt:extent: 34 2 1202 1 1 1202 373 669 25904 1154 #basicSelectionsByIndex: 34 1 8 #(1) 25904 1154 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 25904 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 186 0 0 0 78 1 0 0] 8 #() 1312 nil 27 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1 1 1202 373 669 24512 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 186 0 0 0 78 1 0 0] 34 3 24688 25280 25904 1312 nil 27 8 'methodFilterTabs' nil 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1391 1 1202 851 669 22688 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 183 2 0 0 0 0 0 0 96 4 0 0 78 1 0 0] 34 3 24512 410 ##(Smalltalk.Splitter) 34 12 nil 22688 34 2 8 1140850688 1 26704 nil 610 22032 nil 517 nil nil nil 26704 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 373 1 1202 11 669 26704 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 186 0 0 0 0 0 0 0 191 0 0 0 78 1 0 0] 8 #() 1312 nil 27 22800 1312 nil 27 1312 nil 27 7 false 170 192 1296 nil 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1 1 1202 2241 669 14992 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 96 4 0 0 78 1 0 0] 34 1 15104 1312 nil 27 13378 3 5 true 170 192 34 4 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 27168 nil 610 22032 nil 517 nil nil nil 27168 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 1 669 1202 2241 11 27168 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 78 1 0 0 96 4 0 0 83 1 0 0] 8 #() 1312 nil 27 8 'splitter' 544 8 'textAreaTabs' nil 1090 138 144 34 1 1154 #createAt:extent: 34 2 1202 7679 21 1202 2241 1401 416 1250 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 95 19 0 0 198 2 0 0] 34 4 14992 27168 544 13408 1312 nil 27 )! !
!JadeiteProjectsBrowserPresenter class categoriesFor: #downArrowIcon!public! !
!JadeiteProjectsBrowserPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

