"Filed out from Dolphin Smallalk"!

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

addNoneProject 

	"ignore in this browser"!

addPackageDictionaryInfoTo: aStream

	"Private - projects don't write themselves to string"!

addSubclass
	| classService answerService |
	classService := self selectedClass ifNil: [^self].
	classService
		command: #subclassCreationTemplate;
		commandArgs: Array new. 
	answerService := (self issueCommand: classService) first.
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
	self issueCommand: browserService.
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
			self issueCommand: service].
	self selectCategoriesNamed: (Array with: string)!

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

basicRemoveMethodCategories
	| service |
	service := self selectedClass
				command: #removeCategories:;
				commandArgs: (Array with: categoryListPresenter selections).
	self issueCommand: service!

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
	self issueCommand: service.
	categoryListPresenter selection: new!

basicRenameClass: classService to: newName
	| serviceArray oldName browser answeringService |
	oldName := classService name.
	classService
		command: #renameClass:to:;
		commandArgs: (Array with: classService name with: newName).
	[serviceArray := self issueCommand: classService] on: GsCompileError
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
	self issueCommand: browserService.
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

categoryListPresenter
	^categoryListPresenter!

classCommentPresenter
	"for test access" 
	^classCommentPresenter!

classDefinitionPresenter

	^classDefinitionPresenter!

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

containedPackageDictionaryLabel
	| containedDictionary |
	containedDictionary := 'Go to Associated Dictionary'.
	packageListPresenter selection
		ifNotNil: 
			[:packageService |
			containedDictionary := containedDictionary , ' ('
						, (packageService dictionaryName ifNil: [String new]) , ')'].
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
		to: self.
	JadePresenter transactionModeValueHolder
		when: #valueChanged
		send: #updateAutoCommit
		to: self!

createSchematicWiringForClassHierarchyTabs
	classHierarchyTabs
		when: #currentCardChanging:
			send: #aboutToChange:
			to: self;
		when: #currentCardChanged
			send: #refreshClassListOrHierarchy
			to: self!

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

createSchematicWiringForPackageDictionaryTabs

	"Yes, I know. Subclasses should not remove behavior."!

createSchematicWiringForPackageList

	packageListPresenter
		when: #'drag:'				send: #'onDragPackageList:'			to: self;
		when: #'dragCut:'			send: #'onDragCutPackageList:'		to: self;
		when: #'dragOver:'			send: #'onDragOverPackageList:'		to: self;
		when: #'drop:'				send: #'onDropOnPackageList:'		to: self; 
		when: #'keyTyped:'			send: #'delayUpdate'				to: self;
		when: #'selectionChanging:'	send: #'aboutToChange:'			to: self;
		when: #'selectionChanging:'	send: #'releasedReferencedServices:'	to: self;
		when: #'selectionChanged'		send: #'updatePackage' 			to: self;
		when: #keyTyped: 			send: #selectServiceStartingWith: 		to: packageListPresenter;
		when: #aboutToDisplayMenu: send: #updatePackageMenu: 		to: self
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
	self issueCommand: classService.
	classCommentPresenter ensureVisible.
	self refreshFromServer.
	classCommentPresenter view
		isModified: false;
		backcolor: JadeiteTextStyles default colorForNoEdits!

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

gotoClass
	JadePresenter browseClassIn: self gciSession!

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

initialize
	super initialize.
	stonCritical := Semaphore forMutualExclusion.!

jadeDisplay
	View focus == methodSourcePresenter view ifFalse: [^self].
	^super jadeDisplay!

jadeExecute
	View focus == methodSourcePresenter view ifFalse: [^self].
	^super jadeExecute!

jadeMenuStrings
	false ifTrue: [
		self abortTransaction; commitTransaction; beginTransaction; newBrowser; addSystemBrowser; maximizeCode; findClass; gotoClass; refreshFromServer; exit.
	]. 
	^#(
		'&Jadeite'
		'&Abort Transaction//abortTransaction'
		'&Commit Transaction//commitTransaction' 
		'&Begin Transaction//beginTransaction'
		'-'
		'&New Projects Browser/Ctrl+N/newBrowser'
		'&New Projects Tab/Ctrl+T/addSystemBrowser'
		'&Maximize Code/Ctrl+M/maximizeCode'
		'-'
		'&Find Class.../Ctrl+Shift+F/findClass' 
		'&Go To Class In New Browser.../Ctrl+Shift+G/gotoClass' 
		'&Save Class Tabs to Preferences File//saveCurrentClassTabsToPreferencesFile'
		'-'
		'&Refresh/Ctrl+R/refreshFromServer'
		'-'
		'E&xit/Shift+F4/exit'
	).
!

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

newBrowser
	| classService selector |
	classService := self selectedClass.
	selector := methodListPresenter selectionOrNil ifNotNil: [:methodService | methodService selector].
	^self openProjectBrowserOn: classService selector: selector!

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
	BrowserUpdate current removeEventsTriggeredFor: self.
	JadePresenter transactionModeValueHolder removeEventsTriggeredFor: self. !

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

projectListPresenter
	^projectListPresenter!

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
	command == #addMethodCategory
		ifTrue: 
			[aCommandQuery isEnabled: self selectedClass notNil.
			^true].
	command == #loadProject
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

registerClassData
	"temporarily disabled"!

registerPresentersForUpdates
	BrowserUpdate current
		register: projectListPresenter
		selector: #projectsUpdate:browser:
		browser: self.
	BrowserUpdate current register: projectListPresenter selector: #removedProject:.
	BrowserUpdate current register: projectListPresenter selector: #newProject:.
	BrowserUpdate current register: projectListPresenter selector: #projectsUpdate:.
	BrowserUpdate current register: projectListPresenter selector: #removed:.
	BrowserUpdate current
		register: classListPresenter
		selector: #classesUpdate:browser:
		browser: self.
	BrowserUpdate current register: classListPresenter selector: #removedClass:.
	BrowserUpdate current
		register: classListPresenter
		selector: #updatedClass:browser:
		browser: self.
	BrowserUpdate current
		register: classDefinitionPresenter
		selector: #updatedClassDefinition:browser:
		browser: self.
	BrowserUpdate current register: classListPresenter selector: #removed:.
	BrowserUpdate current
		register: packageListPresenter
		selector: #projectPackagesUpdate:browser:
		browser: self.
	BrowserUpdate current register: packageListPresenter selector: #removed:.
	BrowserUpdate current register: packageListPresenter selector: #packageUpdate:.
	BrowserUpdate current
		register: categoryListPresenter
		selector: #filterUpdate:browser:
		browser: self.
	BrowserUpdate current
		register: variableListPresenter
		selector: #filterUpdate:browser:
		browser: self.
	BrowserUpdate current
		register: classHierarchyPresenter
		selector: #classHierarchyUpdate:browser:
		browser: self.
	BrowserUpdate current
		register: classListPresenter
		selector: #updatedClass:browser:
		browser: self.
	BrowserUpdate current register: classHierarchyPresenter selector: #removedClass:.
	BrowserUpdate current
		register: classHierarchyPresenter
		selector: #updatedClass:browser:
		browser: self.
	BrowserUpdate current
		register: classHierarchyPresenter
		selector: #updatedClassInHierarchy:browser:
		browser: self.
	BrowserUpdate current
		register: classHierarchyPresenter
		selector: #updatedOneLevelInClassHierarchy:browser:
		browser: self.
	BrowserUpdate current register: classHierarchyPresenter selector: #removed:.
	BrowserUpdate current
		register: methodListPresenter
		selector: #classMethodsUpdate:browser:
		browser: self.
	BrowserUpdate current register: methodListPresenter selector: #removed:.
	BrowserUpdate current
		register: methodSourcePresenter
		selector: #methodSourceUpdate:browser:
		browser: self.
	BrowserUpdate current register: self selector: #autoCommitUpdate:!

releasedReferencedServices: selectionChangingEvent
	selectionChangingEvent window presenter selectionOrNil ifNotNil: [:service | service postUpdate]!

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
	self issueCommands: classServices!

removeMethodSelector: selector
	self removeMethodSelectors: (Array with: selector)!

removeMethodSelectors: selectors
	self selectedClass
		command: #removeMethods:;
		commandArgs: (Array with: methodListPresenter selections).
	self issueCommand: self selectedClass!

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
	answeringService := [self issueCommand: classService] on: Error
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
	classHierarchyPresenter view expand: selection. 
	^selection!

selectClassInClassListNamed: className
	| selection |
	selection := classListPresenter list detect: [:classService | classService name = className]
				ifNone: [].
	selection ifNotNil: [classListPresenter selection: selection].
	^selection!

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
		ifTrue: [| category | category := classService selectedMethods first category. 
			(categoryListPresenter model includes: category) ifFalse: [categoryListPresenter model add: category]. 
			categoryListPresenter selection: category].
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

targetCategory
	self isVariablesTabSelected ifTrue: [^self selectedMethodCategory].
	categoryListPresenter hasSelection ifFalse: [^self selectedMethodCategory].
	categoryListPresenter selections size > 1 ifTrue: [^self selectedMethodCategory].
	^categoryListPresenter selection trimBlanks!

textAreaTabs
	"for testing"
	^textAreaTabs!

textTabs
	^(textAreaTabs subViews detect: [:each | each class == TabViewXP]) model!

unloadPackage
	MessageBox notify: 'This feature is not yet available'!

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

updateCommand: aString onSuccessDo: aBlock
	"Only use STON to update in our new browser"

	stonCritical critical: 
			[
			[| stonResults update |
			update := BrowserUpdate current initializeUpdates.
			stonResults := self gciSession serverPerform: #systemBrowserSTON:
						with: environment printString , ' ' , aString.
			update applyUpdatesFromReturnedServices: (STON fromString: stonResults).
			self updateSelectionsFor: update.
			self updateTabLabel.
			update applyUpdatesFromReturnedServices: #()]
					ensure: [selectedClassChanged := false]].
	^nil!

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

updatePresenter: presenter selections: selections
	| newSelections |
	newSelections := OrderedCollection new.
	selections do: 
			[:selection |
			(presenter list detect: [:service | service name = selection name] ifNone: [])
				ifNotNil: [:newSelection | newSelections add: newSelection]].
	presenter selections: newSelections!

updateProjectPackages
	packageListPresenter clear.
	projectListPresenter selections isEmpty ifTrue: [^self].
	self updateServices: projectListPresenter selections.
	self sundryCleanup!

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
	service ifNil: [sunitPresenter testClassService: nil] ifNotNil: [self setTestClass: service]! !
!JadeiteProjectsBrowserPresenter categoriesForMethods!
addNoneProject!private! !
addPackageDictionaryInfoTo:!private! !
addSubclass!menu handlers!public! !
addVariableAccessors!menu handlers!public! !
allClasses!menu handlers!public! !
autoCommit!accessing!private! !
autoCommit:!initialize/release!public! !
basicAddMethodCategory:!menu handlers support!private! !
basicOnDropClassList:!drag & drop!public! !
basicProjectTabLabel!displaying!private! !
basicRemoveMethodCategories!menu handlers support!private! !
basicRemoveMethods!menu handlers support!private! !
basicRenameCategoryFrom:to:!menu handlers!public! !
basicRenameClass:to:!menu handlers support!private! !
basicUnloadProjects:!menu handlers support!private! !
behaviorIdentifier!private!selection! !
browseHierarchyImplementors!menu handlers!public!queries! !
browseHierarchySenders!public!queries! !
browseSelectedClass!menu handlers!public! !
categoryListPresenter!accessing!public! !
classCommentPresenter!accessing!menu handlers!public! !
classDefinitionPresenter!accessing!public! !
classHierarchyTabs!accessing!private! !
cleanupComparisonBrowser!initialize/release!private! !
clearFilterLists!event handlers support!private!updating! !
clearMethodBreakpoints!menu handlers!public! !
comparisonTab!private!text tabs! !
confirmCategoryRemoval:!menu handlers support!private! !
confirmOverwriteAccessor!menu handlers support!public! !
containedDictionaryLabel!menus!private! !
containedPackageDictionaryLabel!menus!private! !
copyClass!menu handlers!public! !
createComponents!initialize/release!public! !
createSchematicWiring!create schemantic wiring!public! !
createSchematicWiringForClassHierarchyTabs!create schemantic wiring!public! !
createSchematicWiringForInstanceClassTabs!create schemantic wiring!public! !
createSchematicWiringForMethodCategoryList!create schemantic wiring!public! !
createSchematicWiringForMethodFilterTabs!create schemantic wiring!public! !
createSchematicWiringForPackageDictionaryTabs!create schemantic wiring!public! !
createSchematicWiringForPackageList!create schemantic wiring!public! !
createSchematicWiringForVariableList!create schemantic wiring!public! !
createStateEntry!accessing!public!updating! !
definedClassMenuItemLabel!menus!private! !
definedMethodMenuItemLabel!menus!private! !
displayMultipleCategories!displaying!private!updating! !
editFind!menu handlers!public! !
editReplace!menu handlers!public! !
editSaveClassComment!menu handlers!public! !
filterTabChanged!event handlers!public!updating! !
findMethod!event handlers!menu handlers!public!updating! !
findMethod:!menu handlers!public! !
gciSession:!accessing!public! !
getterMethodSourceFor:!menu handlers support!public! !
getViews!public! !
gotoClass!menu handlers!public! !
gotoClassDefinedPackageViaButton!menu handlers!public! !
gotoMethodDefinedPackage!menu handlers!public! !
gotoMethodDefinedPackageViaButton!menu handlers!public! !
gotoPackageNamed:!menu handlers!public! !
gotoProjectNamed:!menu handlers!public! !
initialize!initialize/release!public! !
jadeDisplay!menu handlers!private! !
jadeExecute!menu handlers!private! !
jadeMenuStrings!menus!public! !
methodCategoryText!accessing!private! !
methodListPresenter!accessing!public! !
methodListSelection!accessing!public! !
methodMenuBreak:!menus!public! !
methodsMenuStrings!menus!public! !
methodSourcePresenter:!accessing!private! !
newBrowser!menu handlers!public! !
onDropMethodsOnClassHierarchy:!drag & drop!public! !
onDropOnClassList:!drag & drop!public! !
onDropOnMethodCategory:!drag & drop!public! !
onSetFocus:stack:!event handlers!public! !
onViewClosed!event handlers!public! !
populateFilterList!event handlers support!private!services!updating! !
postOkToChangeEvent!event handlers!public! !
projectListPresenter!accessing!public! !
queryCommand:!menu handlers support!private! !
redrawAllViews!displaying!public! !
refreshClassListOrHierarchy!event handlers!public!updating! !
registerClassData!public!updating! !
registerPresentersForUpdates!event handlers!initialize/release!private!register presenters! !
releasedReferencedServices:!event handlers!public! !
removeMethodCategories!menu handlers!public! !
removeMethods:!private!services! !
removeMethodSelector:!private!services! !
removeMethodSelectors:!private!services! !
renameClass!menu handlers!public! !
renameMethodCategory!menu handlers!public! !
resetCategoryText!event handlers support!public! !
resetClassDefinitionPane!menu handlers!public! !
resetClassTemplate!private! !
resetDefinedClassPackage!event handlers support!private! !
resetSunitTestList!initialize/release!private! !
runAndMesureTime!menu handlers!public! !
runClassTests!menu handlers!public! !
runMethodTests!menu handlers!public! !
savePackage!menu handlers!public! !
selectCategoriesNamed:!public!selection! !
selectCategoryFrom:!public!selection! !
selectCategoryNamed:!public!selection! !
selectCategoryTab!public!selection! !
selectClassDefinitionTab!public!selection! !
selectClassInClassHierarchyNamed:!private!selection! !
selectClassInClassListNamed:!private!selection! !
selectClassNamed:!private!selection! !
selectClassTab!public!selection! !
selectCommentTab!public!selection! !
selectComparisonTab!public!selection! !
selectedClass!private!selection! !
selectedClasses!private!selection! !
selectedClassName!private!selection! !
selectedMethodCategory!menu handlers support!private! !
selectedMethodName!menu handlers!public! !
selectedPackageNames!public!selection! !
selectGlobalsTab!public!selection! !
selectionMethod:!private!selection! !
selectMethods:!private!selection! !
selectMethodsFrom:!private!selection! !
selectMethodSourceTab!public!selection! !
selectPackage:!private!selection! !
selectSourceTabNamed:!private!selection! !
selectSUnitTab!public!selection! !
selectVariableTab!public!selection! !
setDefaultProjectTablLabel!event handlers!public! !
setDefaultProjectTablLabel:!event handlers!public! !
setMethodFilterFor:!event handlers support!private!services!updating! !
setterMethodSourceFor:!menu handlers support!public! !
setTestClass:!event handlers support!private! !
setupPackageMenu!event handlers!public! !
showMethodRecompilationError:!menu handlers support!public! !
showSUnitBrowserOnClass!menu handlers!public! !
showSuperClassComparison!private!text tabs! !
sundryCleanup!initialize/release!private! !
sunitPresenter!menu handlers!public! !
targetCategory!menu handlers support!private! !
textAreaTabs!private!text tabs! !
textTabs!private!text tabs! !
unloadPackage!menu handlers!public! !
update:afterStonReplication:!public!updating! !
updateAndSelectA:!public!updating! !
updateClasses!event handlers!public!updating! !
updateClassInfo!event handlers!public!updating! !
updateCommand:onSuccessDo:!public!updating! !
updateMethodMenu:!event handlers!public!updating! !
updateMethodReferences:!private!services! !
updateMethodSource!event handlers!public!text tabs!updating! !
updateMultiMethodComparison!event handlers support!private! !
updatePackageInfo!event handlers!public!updating! !
updatePresenter:selections:!event handlers support!public! !
updateProjectPackages!event handlers!public!updating! !
updateSelectionsForUpdate:!public!updating! !
updateSingleMethodSource!event handlers support!private! !
updateSUnitTab!event handlers!public!updating! !
updateSUnitTab:!event handlers!public!updating! !
!

