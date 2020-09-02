"Filed out from Dolphin Smalltalk 7"!

JadeBrowserPresenter subclass: #JadeSystemBrowserPresenter
	instanceVariableNames: 'ancestorListPresenter breakPoints categoryListPresenter classCategoryPresenter classCommentPresenter classDefinition classDefinitionPresenter classHierarchyPresenter classHierarchyTabs classListPresenter dictionaryListPresenter environment eventCount globalsPresenter globalsLabel historyList historyIndex ignoreNextSetFocusEvent instanceClassTabs inUpdate keystrokeTime methodCategory methodFilterTabs methodListPresenter methodSource methodSourcePresenter originalSourceLabel originalSourcePresenter overrideListPresenter packageDictionaryTabs packageInfoTab packageLabel packageListPresenter pragmaListPresenter readStream repositoryListPresenter selectedClassChanged selectedClassesAreTestCases selectedClassName selectedClassOop stepPoints sunitPresenter superclassListPresenter textAreaTabs unimplementedSelectors updateCount updateProcess variableListPresenter'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeSystemBrowserPresenter guid: (GUID fromString: '{aa74f365-5e98-46b2-af4c-19a7bf1e6e97}')!
JadeSystemBrowserPresenter comment: ''!
!JadeSystemBrowserPresenter categoriesForClass!Unclassified! !
!JadeSystemBrowserPresenter methodsFor!

aboutToChange: aSelectionChangingEvent
	aSelectionChangingEvent value ifTrue: [
		aSelectionChangingEvent value: self isOkayToChange.
	].
!

aboutToEditClassLabel: oldName accept: aValueHolder

	aValueHolder value: true.
!

addClassCategoryInfoTo: aStream

	| category |
	category := (classCategoryPresenter selectionIfNone: [#() -> nil]) key.
	category isEmpty ifTrue: [category := #('')].
	category do: [:each | 
		aStream nextPutAll: each; nextPut: $-.
	].
	aStream lf.
!

addClassHierarchyInfoTo: aStream

	| selections |
	aStream nextPutAll: classHierarchyTabs currentCard name; lf.
	self isClassListTabSelected ifTrue: [
		(selections := classListPresenter selections) isEmpty ifTrue: [
			selections := Array with: self selectedClassNameWithoutVersion.
		].
	] ifFalse: [
		selections := Array with: (classHierarchyPresenter selectionIfNone: [Array with: self selectedClassNameWithoutVersion]) last.
	].
	selections do: [:each | aStream nextPutAll: each; tab].
	aStream lf.
!

addMethodCategory
	| string |
	(string := Prompter prompt: 'New method category?') isNil ifTrue: [^self].
	string trimBlanks isEmpty ifTrue: [^MessageBox notify: 'Category name must not be blank'].
	self basicAddMethodCategory: string!

addMethodInfoTo: aStream

	| string |
	selectedClassChanged ifTrue: [
		aStream 
			nextPutAll: instanceClassTabs currentCard name; lf;
			lf;	"superclassList selection"
			nextPutAll: 'categoryList'; tab;
			lf;	"method filter selections"
			lf; "overrideList selection"
			yourself.
		^self.
	].
	string := superclassListPresenter selectionIfNone: [''].
	aStream 
		nextPutAll: instanceClassTabs currentCard name; lf;		"instanceTab or classTab"
		nextPutAll: string; lf;								"selected superclass"
		nextPutAll: methodFilterTabs currentCard name; tab;		"categoryList or variableList or pragmaList"
		lf.
	self methodFilterListPresenter selections do: [:each | aStream nextPutAll: each trimBlanks; tab].
	aStream lf.
	methodListPresenter selections do: [:each | aStream nextPutAll: each first; tab].
	string := overrideListPresenter selectionIfNone: [''].
	(string includes: Character space) ifTrue: [string := string subStrings first].
	aStream 
		lf;
		nextPutAll: string; lf;
		yourself.
!

addMissingAccessors

	| string |
	string := 'addMissingAccessors' , Character tab asString , self behaviorIdentifier , Character lf asString , self requestString.
	self updateCommand: string.
!

addPackage

	| string stream |
	(string := Prompter prompt: 'New package name?') isNil ifTrue: [^self].
	stream := WriteStream on: String new.
	stream
		nextPutAll: 'addPackage'; tab;
		nextPutAll: string; tab;
		lf.
	self updateCommand: stream contents , self requestString.
!

addPackageDictionaryInfoTo: aStream

	| tabName |
	tabName := packageDictionaryTabs currentCard name.
	aStream nextPutAll: tabName; lf.
	tabName = 'packageList' ifTrue: [
		packageListPresenter selections do: [:each | aStream nextPutAll: each key; tab].
	] ifFalse: [
		dictionaryListPresenter selections do: [:each | aStream nextPutAll: each key; tab].
	].
	aStream lf.
!

addRepository

	| string list selection stream |
	string := self gciSession serverPerform: #'mcRepositoryList'.
	list := (string subStrings: Character lf) reject: [:each | each isEmpty].
	list := list collect: [:each | (each subStrings: Character tab) at: 2].
	list := list asSortedCollection.
	selection := ChoicePrompter 
		choices: list 
		caption: 'Select Repository'.
	selection isNil ifTrue: [^self].
	stream := (WriteStream on: String new)
		nextPutAll: 'addRepository'; tab;
		nextPutAll: selection;
		yourself.
	packageListPresenter selections do: [:each | stream tab; nextPutAll: each key].
	stream lf.
	self updateCommand: stream contents , self requestString.
!

addSubclass

	| i j superclass string | 
	self isOkayToChange ifFalse: [^self].
	i := classDefinition indexOfSubCollection: '''' startingAt: 1.
	j := classDefinition indexOfSubCollection: '''' startingAt: i + 1.
	superclass := classDefinition copyFrom: i + 1 to: j - 1.
	string := '(
' , superclass , ' subclass: ''MyNewSubclass''' , (classDefinition copyFrom: j + 1 to: classDefinition size).
	j := 1.
	[
		i := string indexOfSubCollection: '#(' startingAt: j.
		0 < i.
	] whileTrue: [
		j := string indexOfSubCollection: ')' startingAt: i + 1.
		string := (string copyFrom: 1 to: i + 1) , (string copyFrom: j to: string size).
	].
	j := 1.
	[
		i := string indexOfSubCollection: '#[' startingAt: j.
		0 < i.
	] whileTrue: [
		j := string indexOfSubCollection: ']' startingAt: i + 1.
		string := (string copyFrom: 1 to: i + 1) , (string copyFrom: j to: string size).
	].
	classDefinitionPresenter
		ensureVisible;
		value: string;
		yourself.
!

behaviorIdentifier

	^(WriteStream on: String new)
		nextPutAll: self selectedClassNameWithoutVersion; tab;
		nextPutAll: selectedClassOop printString; tab;
		nextPutAll: instanceClassTabs currentCard name;
		contents.
!

breakAt: anInteger operation: aString

	| stream |
	stream := WriteStream on: String new.
	stream
		nextPutAll: 'break'; tab;
		nextPutAll: self selectedClassNameWithoutVersion; tab;
		nextPutAll: selectedClassOop printString; tab;
		nextPutAll: instanceClassTabs currentCard name; tab;
		nextPutAll: methodListPresenter selection first; tab;
		nextPutAll: anInteger printString; tab;
		nextPutAll: aString; tab;
		lf.
	self updateCommand: stream contents , self requestString.
!

browseGlobalReferences

	| string |
	string := 'browseGlobalReferences' , Character tab asString , (globalsPresenter selection at: 5) , Character lf asString.
	(string := self updateCommand: string) = 'browseGlobalReferences' ifFalse: [self error: 'unrecognized response'].
	self browseMethodsAndSelect: (globalsPresenter selection at: 1).
!

browseImplementors
	^self browseImplementorsOf: self selectedMethodName.
!

browseMethodHistory

	| string |
	string := 'browseMethodHistory' , Character tab asString , self methodsIdentifier , Character lf asString.
	(self updateCommand: string) = 'browseMethodHistory' ifFalse: [self error: 'unexpected response'].
	readStream atEnd ifTrue: [
		MessageBox notify: 'No history available!!'.
		^self.
	].
	(JadeMethodHistoryBrowser showOnSession: gciSession)
		setContents: readStream;
		yourself.
!

browseMethodPragmas

	| commandString keyword keywords responseString |
	responseString:= self updateCommand: 'listMethodPragmas'.
	keywords := responseString subStrings: Character tab.
	(keyword := ChoicePrompter choices: keywords) ifNil: [^self].
	commandString := 'browseMethodsWithPragma' , Character tab asString , keyword , Character lf asString.
	responseString := self updateCommand: commandString.
	responseString = 'browseMethodsWithPragma' ifFalse: [self error: 'unexpected response'].
	self browseMethodsAndSelect: keyword.
!

browseSelectedClass

	| range string list assoc |
	range := methodSourcePresenter view selectionRange.
	string := methodSourcePresenter value copyFrom: range start to: range stop.
	list := self findClassList.
	assoc := list 
		detect: [:each | each key = string]
		ifNone: [^MessageBox warning: 'Class ' , string printString , ' not found!!' caption: 'Jade'].
	parentPresenter parentPresenter addSystemBrowserForClass: assoc value.
!

browseSenders
	^self browseSendersOf: self selectedMethodName!

buildHistoryMenuNamed: aString from: startIndex to: endIndex by: increment

	| currentClassName popup subMenu |
	popup := Menu new.
	currentClassName := nil.	"avoid warning and make explicit that we expect comparison to fail the first time so we get a new submenu"
	startIndex to: endIndex by: increment do: [:i | 
		| className historyEntry methodName |
		historyEntry := historyList at: i.
		className := historyEntry at: 1.
		methodName := historyEntry at: 2.
		className ~= currentClassName ifTrue: [
			currentClassName := className.
			subMenu := popup addSubmenu: currentClassName.
		].
		subMenu
			addCommand: (Message selector: #'jumpToHistoryIndex:' argument: i)
			description: methodName.
		subMenu setDefault: 1.
	].
	popup setDefault: 1.
	^popup!

categoriesMenuStrings

	false ifTrue: [
		self addMethodCategory; removeMethodCategories.
	].
	^#(
		'&Categories'
		'&Add Method Category//addMethodCategory'
		'&Remove Method Categories//removeMethodCategories'
	).
!

categoryListPresenter

	^categoryListPresenter!

classCategoryPresenter

	^classCategoryPresenter!

classDefChanged
	inUpdate ifTrue: [^self].
	classDefinitionPresenter value = classDefinition
		ifTrue: 
			[classDefinitionPresenter view
				backcolor: JadeiteTextStyles default colorForNoEdits;
				isModified: false;
				yourself]
		ifFalse: 
			[classDefinitionPresenter view
				backcolor: JadeiteTextStyles default colorForUnsavedEdits;
				isModified: true;
				yourself]!

classesMenuStrings

	false ifTrue: [
		self browseClassReferences; fileOutClass; addSubclass; addMissingAccessors; removeClass; removePriorVersions; runClassTests.
	].
	^#(
		'&Classes'
		'&Browse References//browseClassReferences'
		'&File Out Class//fileOutClass'
		'Add &Subclass//addSubclass'
		'Add &Missing Accessors//addMissingAccessors'
		'&Remove//removeClass'
		'Remove Prior &Versions//removePriorVersions'
		'-'
		'Set Compiler &Environment ...//setEnvironment'
		'Run &Tests//runClassTests'
	).
!

classHierarchyPresenter

	^classHierarchyPresenter!

classHierarchyTabs
	"for tests" 
	^classHierarchyTabs!

classListPresenter

	^classListPresenter!

clearPackageInfo

	ancestorListPresenter list: #().
	repositoryListPresenter list: #().

!

closeRequested: anAssociation

	anAssociation value ifTrue: [
		anAssociation value: self isOkayToChange.
	].

!

compareAncestor

	| repository stream patch |
	repository := repositoryListPresenter hasSelection 
		ifTrue: [repositoryListPresenter selection]
		ifFalse: [repositoryListPresenter list first].
	stream := (WriteStream on: String new)
		nextPutAll: 'comparePackages'; tab;
		nextPutAll: packageListPresenter selections first key; tab;
		nextPutAll: (ancestorListPresenter selections first at: 2); tab;
		nextPutAll: (repository at: 2); tab;
		lf.
	(self updateCommand: stream contents) = 'comparePackages' ifFalse: [self error: 'Unexpected response!!'].
	patch := MCPatch
		fromString: readStream upToEnd
		session: self gciSession.
	patch operations isEmpty ifTrue: [
		MessageBox notify: 'No changes!!'.
		^self.
	].
	MCPatchBrowser showOn: patch.
!

contextObject
	^gciSession oopNil value!

createSchematicWiringForClassCategoryList

	classCategoryPresenter		
		when: #'dragOver:'			send: #'onDragOverClassCategory:'	to: self;
		when: #'drop:'				send: #'onDropOnClassCategory:'	to: self;
		when: #'keyTyped:'			send: #'delayUpdate'				to: self;
		when: #'selectionChanging:'	send: #'aboutToChange:'			to: self;		
		when: #'selectionChanged'		send: #'updateAndSelect:'			to: self	with: classDefinitionPresenter;
		yourself.
!

createSchematicWiringForClassDefinition

	classDefinitionPresenter
		when: #'valueChanged'	send: #'classDefChanged'	to: self;
		yourself.
!

createSchematicWiringForClassHierarchy

	classHierarchyPresenter	
		when: #'drag:'				send: #'onDragClassHierarchy:'		to: self;
		when: #'dragCut:'			send: #'onDragCutClassHierarchy:'	to: self;
		when: #'dragOver:'			send: #'onDragOverClassHierarchy:'	to: self;
		when: #'drop:'				send: #'onDropOnClassHierarchy:'	to: self;
		when: #'keyTyped:'			send: #'delayUpdate'				to: self;
		when: #'selectionChanging:'	send: #'aboutToChange:'			to: self;
		when: #'selectionChanged'		send: #'selectedClassChanged:'		to: self	with: true;
		when: #'selectionChanged'		send: #'updateAndSelect:'			to: self	with: classDefinitionPresenter;
		yourself.
!

createSchematicWiringForClassList

	classListPresenter				
		when: #'drag:'					send: #'onDragClassList:'				to: self;
		when: #'dragCut:'				send: #'onDragCutClassList:'			to: self;
		when: #'dragOver:'				send: #'onDragOverClassList:'			to: self;
		when: #'drop:'					send: #'onDropOnClassList:'			to: self;
		when: #'keyTyped:'				send: #'delayUpdate'					to: self;
		when: #'selectionChanging:'		send: #'aboutToChange:'				to: self;
		when: #'selectionChanged'			send: #'selectedClassChanged:'			to: self	with: true;
		when: #'selectionChanged'			send: #'updateAndSelect:'				to: self	with: classDefinitionPresenter;

		when: #labelOf:changedTo: 		send: #labelOfClass:changedTo:			to: self;
		when: #aboutToEditLabel:accept: 	send: #aboutToEditClassLabel:accept:	to: self;
		when: #labelOf:editedTo:accept: 	send: #labelOfClass:editedTo:accept:		to: self;

		yourself.
!

createSchematicWiringForDictionaryList

	dictionaryListPresenter
		when: #'dragOver:'			send: #'onDragOverDictionary:'		to: self;
		when: #'drop:'				send: #'onDropOnDictionary:'		to: self;
		when: #'keyTyped:'			send: #'delayUpdate'				to: self;
		when: #'selectionChanging:'	send: #'aboutToChange:'			to: self;
		when: #'selectionChanged'		send: #'updateAndSelect:'			to: self	with: globalsPresenter;
		yourself.
!

createSchematicWiringForInstanceClassTabs

	instanceClassTabs
		when: #'currentCardChanging:'	send: #'aboutToChange:'		to: self;
		when: #'currentCardChanged'	send: #'selectedClassChanged:'	to: self	with: true;
		when: #'currentCardChanged'	send: #'updateAndSelect:'		to: self	with: classDefinitionPresenter;
		yourself.
!

createSchematicWiringForMethodCategoryList

	categoryListPresenter
		when: #'dragOver:'			send: #'onDragOverMethodCategory:'	to: self;
		when: #'drop:'				send: #'onDropOnMethodCategory:'	to: self;
		when: #'keyTyped:'			send: #'delayUpdate'				to: self;
		when: #'selectionChanging:'	send: #'aboutToChange:'			to: self;
		when: #'selectionChanged'		send: #'updateAndSelect:'			to: self	with: methodSourcePresenter;
		when: #'selectionChanged'		send: #'updateTabLabel'			to: self;
		yourself.
!

createSchematicWiringForMethodList

	methodListPresenter			
		when: #'drag:'				send: #'onDragMethod:'			to: self;
		when: #'dragCut:'			send: #'onDragCutMethod:'			to: self;
		when: #'keyTyped:'			send: #'delayUpdate'				to: self;
		when: #'selectionChanging:'	send: #'aboutToChange:'			to: self;
		when: #'selectionChanged'		send: #'selectedMethodChanged'		to: self;
		yourself.
!

createSchematicWiringForMethodSource

	methodSourcePresenter 	
		when: #'hoverStart:'				send: #'methodHoverStart:'	to: self;
		when: #'hoverEnd:'				send: #'methodHoverEnd:'		to: self;
		when: #'aboutToDisplayMenu:'		send: #'methodMenu:'		to: self;
		when: #'leftButtonDoubleClicked:'	send: #'methodDoubleClicked:'	to: self;
		when: #'focusLost'				send: #'cancelCallTip'			to: methodSourcePresenter view;
		yourself.
	!

createSchematicWiringForOverrideList

	overrideListPresenter		
		when: #'keyTyped:'			send: #'delayUpdate'		to: self;
		when: #'selectionChanging:'	send: #'aboutToChange:'	to: self;		
		when: #'selectionChanged'		send: #'updateAndSelect:'	to: self	with: methodSourcePresenter;
		yourself.
!

createSchematicWiringForPackageDictionaryTabs

	packageDictionaryTabs
		when: #'currentCardChanging:'	send: #'aboutToChange:'	to: self;
		when: #'currentCardChanged'	send: #'pkgDictChanged'	to: self;
		yourself.!

createSchematicWiringForPackageList

	packageListPresenter
		when: #'drag:'				send: #'onDragPackageList:'		to: self;
		when: #'dragCut:'			send: #'onDragCutPackageList:'		to: self;
		when: #'dragOver:'			send: #'onDragOverPackageList:'	to: self;
		when: #'drop:'				send: #'onDropOnPackageList:'		to: self;
		when: #'keyTyped:'			send: #'delayUpdate'				to: self;
		when: #'selectionChanging:'	send: #'aboutToChange:'			to: self;
		when: #'selectionChanged' 		send: #'ensureVisible'				to: packageInfoTab;
		when: #'selectionChanged' 		send: #'list:' 					to: globalsPresenter 	with: #();
		when: #'selectionChanged'		send: #'updateAndSelect:'			to: self			with: packageInfoTab;
		yourself.
!

createSchematicWiringForPragmaList

	pragmaListPresenter
		when: #'keyTyped:'			send: #'delayUpdate'		to: self;
		when: #'selectionChanging:'	send: #'aboutToChange:'	to: self;
		when: #'selectionChanged'		send: #'updateAndSelect:'	to: self	with: methodSourcePresenter;
		when: #'selectionChanged'		send: #'updateTabLabel'	to: self;
		yourself.
!

createSchematicWiringForSuperClassList

	superclassListPresenter		
		when: #'keyTyped:'			send: #'delayUpdate'		to: self;
		when: #'selectionChanging:'	send: #'aboutToChange:'	to: self;		
		when: #'selectionChanged'		send: #'updateAndSelect:'	to: self	with: methodSourcePresenter;
		yourself.
!

createSchematicWiringForVariableList

	variableListPresenter
		when: #'keyTyped:'			send: #'delayUpdate'		to: self;
		when: #'selectionChanging:'	send: #'aboutToChange:'	to: self;
		when: #'selectionChanged'		send: #'updateAndSelect:'	to: self	with: methodSourcePresenter;
		when: #'selectionChanged'		send: #'updateTabLabel'	to: self;
		yourself.
!

currentSelectionOrLine

	View focus hasSelection ifFalse: [View focus selectCurrentLine].
	^View focus selection replaceCrLfWithLf.
!

defaultFileExtension

	^'gs'.
!

delayUpdate
	"Sent by various key-press events. If someone is typing in a list, the list will update
	to the letters typed. If someone is typing several keys in in a row, we don't want to
	go to the server for every keystroke."

	keystrokeTime := Time millisecondClockValue + 500.
!

deletePackage
	"renamed from unloadPackage for semantical differences with Monticello"
	| packageName |
	packageName := packageListPresenter selections first key.
	(MessageBox confirm: 'Do you want to unload ''' , packageName , '''?' caption: 'Confirm Unload')
		ifFalse: [^self].
	self updateCommand: 'unloadPackage' , Character tab asString , packageName , Character lf asString
				, self requestString!

dictionaryListPresenter

	^dictionaryListPresenter!

dictsMenuStrings

	false ifTrue: [
		self browseDictionaryReferences; fileOutDictionary; findClass; insertDictionary; removeDictionary; setHomeDictionary; fileInCode.
	].
	^#(
		'&Dictionaries'
		'&Browse References//browseDictionaryReferences'
		'&File Out Dictionary//fileOutDictionary'
		'File In Code//fileInCode'
		'&Find Class/Ctrl+Shift+F/findClass'
		'&Insert Dictionary//insertDictionary'
		'&Remove Dictionary//removeDictionary'
		'&Set Home Dictionary//setHomeDictionary'
	).
!

editCopy

	View focus copySelection.
!

editCut

	View focus cutSelection.
!

editFind
	textAreaTabs currentCard setFocus; editFind.!

editFindNext
	textAreaTabs currentCard setFocus; editFind.!

editMenuStrings

	false ifTrue: [
		self editSave; editUndo; editRevert; editRedo; editCut; editCopy; editPaste; editDelete; editSelectAll; editFind; editFindNext; editReplace; 
			jadeDisplay; jadeExecute; jadeInspect; browseSelectedClass.
	].
	^#(
		'&Edit'
		'&Save/Ctrl+S/editSave'
		'-'
		'&Undo/Ctrl+Z/editUndo'
		'&Redo/Ctrl+Y/editRedo'
		'&Revert//editRevert'
		'-'
		'&Reformat Source/Ctrl+Shift+O/reformatSource'
		'-'
		'&Cu&t/Ctrl+X/editCut'
		'&Copy/Ctrl+C/editCopy'
		'&Paste/Ctrl+V/editPaste'
		'&Delete/Delete/editDelete'
		'-'
		'Select &All/Ctrl+A/editSelectAll'
		'-'
		'&Find/Ctrl+F/editFind'
		'Find &Next/F3/editFindNext'
		'&Replace/Ctrl+H/editReplace'
		'-'
		'Debug/Ctrl+B/jadeDebug'
		'Display/Ctrl+D/jadeDisplay'
		'Execute/Ctrl+E/jadeExecute'
		'Inspect/Ctrl+Q/jadeInspect'
		'Browse Class//browseSelectedClass'
	).
!

editPaste

	View focus 
		pasteClipboard;
		updateModel;
		yourself.
!

editRedo

	View focus redo.
!

editReplace

	View focus findReplace.
!

editSave

	| currentCard |
	currentCard := textAreaTabs view currentCard.
	currentCard = classDefinitionPresenter view ifTrue: [^self editSaveClass].
	currentCard = methodSourcePresenter view ifTrue: [^self editSaveMethod].
	currentCard = classCommentPresenter view ifTrue: [^self editSaveClassComment].
	MessageBox notify: 'Save menu not effective for this text area tab'.
!

editSaveClassA

	"Removed the class migration dialog and just pass default answers.
	Rowan will then ignore them." 
	| stream answer |
	(selectedClassName includes: Character space) ifFalse: [^self].		"This is a check to see if an earlier version exists"
	"(dict := JadeMigrateClassDialog showModal) isNil ifTrue: [^self revertNewClass].  Commented out for Jadeite
	(dict allSatisfy: [:each | each not]) ifTrue: [^self]."
	(stream := WriteStream on: String new)
		nextPutAll: 'postSaveClass'; tab;
		nextPutAll: self behaviorIdentifier; tab;
		yourself.
	true printOn: stream. 			stream tab.	"copyMethods"
	true printOn: stream. 			stream tab.	"recompileSubclasses"
	true printOn: stream. 			stream tab.	"migrateInstances"
	true printOn: stream. 	stream lf.				"removeFromClassHistory"
	(answer := self updateCommand: stream contents , self requestString) isNil ifTrue: [^self].
	[
		answer = 'compileError'.
	] whileTrue: [
		(JadeWorkspace showOnSession: self gciSession)
			caption: 'Jade Workspace - Compile errors found when compiling class';
			showText: readStream nextParagraph.
		answer := readStream nextLine.
	].
	answer = 'update' ifFalse: [self error: 'Unexpected token'].
	self updatePresenters.
!

editSaveClassComment

	| stream |
	stream := (WriteStream on: String new)
		nextPutAll: 'classComment'; tab;
		nextPutAll: self selectedClassNameWithoutVersion; tab;
		nextPutAll: selectedClassOop printString; tab;
		nextPutAll: instanceClassTabs currentCard name; lf;
		nextPutAll: classCommentPresenter value trimBlanks; lf;
		nextPut: $%; lf;
		yourself.
	self 
		updateCommand: stream contents , self requestString
		onSuccessDo: [classCommentPresenter view isModified: false].
!

editSaveMethod
	| stream caretPosition firstVisibleLine |
	caretPosition := methodSourcePresenter view caretPosition.
	firstVisibleLine := methodSourcePresenter view lineScroll.
	(self isCategoryTabSelected and: [categoryListPresenter hasSelection])
		ifTrue: [methodCategory := categoryListPresenter selection trimBlanks].
	stream := (WriteStream on: String new)
				nextPutAll: 'method';
				tab;
				nextPutAll: self selectedClassNameWithoutVersion;
				tab;
				nextPutAll: selectedClassOop printString;
				tab;
				nextPutAll: instanceClassTabs currentCard name;
				tab;
				nextPutAll: methodCategory;
				tab;
				lf;
				nextPutAll: self currentMethodSource;
				lf;
				nextPut: $%;
				lf;
				yourself.
	
	[self updateCommand: stream contents , self requestString
		onSuccessDo: 
			[methodSourcePresenter view
				isModified: false;
				ensureVisible]]
			on: GsCompileError
			do: [:ex | self reportCompileError: ex list].
	methodSourcePresenter view firstVisibleLine: firstVisibleLine.
	methodSourcePresenter view goto: caretPosition!

editSelectAll

	View focus selectAll.
!

editUndo

	View focus undo.
!

executeSelectionOrLine
	^self executeSelectionOrLine: self contextObject!

fileInCode

	| path |
	MessageBox notify: 'Filein/fileout are not Rowan-ready in this version'
		caption: 'Filein/fileout notification'.
	true ifTrue:[^self].
	path := FileOpenDialog new
		caption: 'File In Code';
		fileTypes: self fileTypes;
		defaultExtension: self defaultFileExtension;
		showModal.
	path isNil ifTrue: [^self].
	JadeFileIn new
		fileInPath: path 
		session: gciSession.
!

fileOutClass

	| path string |
	MessageBox notify: 'Filein/fileout are not Rowan-ready in this version'
		caption: 'Filein/fileout notification'.
	true ifTrue:[^self].
	((string := self selectedClassNameWithoutVersion) endsWith: 'TestCase') ifTrue: [
		string := string copyFrom: 1 to: string size - 8.
	].
	path := FileSaveDialog new
		caption: 'File Out ' , self selectedClassNameWithoutVersion;
		fileTypes: self fileTypes;
		defaultExtension: self defaultFileExtension;
		value: string;
		overwritePrompt;
		showModal.
	path ifNotNil: [:value | self fileOutClassOnPath: value].
!

fileOutClassOnPath: aString

	| header file newSource index |
	newSource := self gciSession 
		serverPerform: #'systemBrowser:' 
		with: environment printString , ' fileOutClass' , Character tab asString , self behaviorIdentifier.
	index := newSource indexOf: Character lf.
	newSource := newSource copyFrom: index + 1 to: newSource size.
	header := self stuffToKeepFromPath: aString andAddTo: newSource.
	file := FileStream write: aString.
	[
		file nextPutAll: header; nextPutAll: newSource.
	] ensure: [
		file close.
	].
!

fileOutDictionary

	| dictionaryName path string file index |
	MessageBox notify: 'Filein/fileout are not Rowan-ready in this version'
		caption: 'Filein/fileout notification'.
	true ifTrue:[^self].
	dictionaryName :=  dictionaryListPresenter selection key.
	path := FileSaveDialog new
		caption: 'File Out ' , dictionaryName;
		fileTypes: self fileTypes;
		defaultExtension: self defaultFileExtension;
		value: dictionaryName , '.gs';
		overwritePrompt;
		showModal.
	path isNil ifTrue: [^self].
	string := environment printString , ' fileOutDictionary' , Character tab asString , dictionaryName.
	string := self gciSession 
		serverPerform: #'systemBrowser:' 
		with: string.
	index := string indexOf: Character lf.
	file := FileStream write: path.
	[
		file nextPutAll: (string copyFrom: index + 1 to: string size).
	] ensure: [
		file close.
	].
!

fileOutMethod

	| name path myReadStream writeStream |
	MessageBox notify: 'Filein/fileout are not Rowan-ready in this version'
		caption: 'Filein/fileout notification'.
	true ifTrue:[^self].
	name := self selectedClassNameWithoutVersion.
	self isClassSideSelected ifTrue: [name := name , '-class'].
	name := name , '-' , self selectedMethodName.
	name := name copyReplaceAll: ':' with: '_'.
	myReadStream := ReadStream on: name.
	writeStream := WriteStream on: String new.
	[myReadStream atEnd not] whileTrue: [
		| each |
		each := myReadStream next.
		(each isAlphaNumeric or: [each == $_ or: [each == $-]]) ifTrue: [
			writeStream nextPut: each.
		] ifFalse: [
			writeStream
				nextPut: $-;
				print: each codePoint;
				nextPut: $-;
				yourself.
		].
	].
	name := writeStream contents.
	path := FileSaveDialog new
		caption: 'File Out Method';
		fileTypes: self fileTypes;
		defaultExtension: self defaultFileExtension;
		value: name;
		overwritePrompt;
		showModal.
	path ifNotNil: [:value | self fileOutMethodOnPath: value].
!

fileOutMethodOnPath: aString

	| header file newSource index |
	newSource := self gciSession 
		serverPerform: #'systemBrowser:' 
		with: environment printString , ' fileOutMethod' , Character tab asString , self behaviorIdentifier , Character tab asString , self selectedMethodName.
	index := newSource indexOf: Character lf.
	newSource := newSource copyFrom: index + 1 to: newSource size.
	header := self stuffToKeepFromPath: aString andAddTo: newSource.
	file := FileStream write: aString.
	[
		file nextPutAll: header; nextPutAll: newSource.
	] ensure: [
		file close.
	].
!

fileTypes

	^Array
		with: #('GemStone Files (*.gs)' '*.gs')
		with: #('Smalltalk Files (*.st)' '*.st')
		with: FileDialog allFilesType.
!

findClassList
"
	Array with: className with: dictionaryName with: catetory with: packageName.
"
	| string list | 
	string := self gciSession 
		serverPerform: #'systemBrowser:' 
		with: environment printString , ' findClass'.
	list := (string subStrings: Character lf) collect: [:each | each subStrings: Character tab].
	list := list copyFrom: 2 to: list size.
	list := list collect: [:each | each size < 3 ifTrue: [each , #('' '' '')] ifFalse: [each]].
	list := list collect: [:each | (each at: 1) -> each].
	^list
!

gciSession: aGciSession

	super gciSession: aGciSession.
	sunitPresenter gciSession: aGciSession.
!

getSelectedMethod
	| dataArray |

	dataArray := self methodListPresenter selectionOrNil.
	dataArray ifNil: [^nil].

	^dataArray first!

getViews

	packageDictionaryTabs 	:= self view viewNamed: 'packageDictionaryTabs'.
	classHierarchyTabs 		:= self view viewNamed: 'classHierarchyTabs'.
	instanceClassTabs		:= self view viewNamed: 'instanceClassTabs'.
	methodFilterTabs 		:= self view viewNamed: 'methodFilterTabs'.
	textAreaTabs			:= self view viewNamed: 'textAreaTabs'.
	packageInfoTab			:= self view viewNamed: 'packageInfo'.
!

globalsMenuStrings

	false ifTrue: [
		self inspectGlobal; browseGlobalReferences; removeGlobals.
	].
	^#(
		'&Globals'
		'&Inspect//inspectGlobal'
		'&Browse References//browseGlobalReferences'
		'&Remove//removeGlobals'
	).
!

handleInvalidSession

	| hadDialog |
	hadDialog := false.
	inUpdate := true.
	methodSourcePresenter view isModified ifTrue: [
		self ensureVisible.
		methodSourcePresenter ensureVisible.
		methodSourcePresenter view isModified: false.
		(MessageBox confirm: 'Copy unsaved method to clipboard?' caption: 'Invalid Session!!') ifTrue: [
			methodSourcePresenter view selectAll; copySelection.
		].
		hadDialog := true.
	].
	classDefinitionPresenter view isModified ifTrue: [
		self ensureVisible.
		classDefinitionPresenter ensureVisible.
		classDefinitionPresenter view isModified: false.
		(MessageBox confirm: 'Copy unsaved class definition to clipboard?' caption: 'Invalid Session!!') ifTrue: [
			classDefinitionPresenter view selectAll; copySelection.
		].
		hadDialog := true.
	].
	^hadDialog.
!

hasCommandHistoryBack

	^1 < historyIndex!

hasCommandHistoryForward

	^historyIndex < historyList size!

historyBack

	self jumpToHistoryIndex: historyIndex - 1.
	!

historyBackMenu

	^self 
		buildHistoryMenuNamed: 'Backward'
		from: historyIndex - 1
		to: 1 
		by: -1!

historyForward

	self jumpToHistoryIndex: historyIndex + 1.
	!

historyForwardMenu

	^self 
		buildHistoryMenuNamed: 'Forward'
		from: historyIndex + 1
		to: historyList size 
		by: 1
!

horizontalSplitter

	^view 
		viewNamed: 'splitter' 
		ifNone: [self error: 'splitter is missing!!?'].
!

initialize

	super initialize.
	environment := 0.
	historyIndex := 0.
	historyList := OrderedCollection new.
	ignoreNextSetFocusEvent := false.
	inUpdate := false.
	selectedClassName := ''.
	eventCount := 0.
	selectedClassChanged := false.
	selectedClassesAreTestCases := false.
	keystrokeTime := 0.
	updateCount := 0.
!

insertDictionary

	| newName currentName stream |
	(newName := Prompter prompt: 'New dictionary name?') isNil ifTrue: [^self].
	currentName := dictionaryListPresenter selections notEmpty
		ifTrue: [dictionaryListPresenter selections first key]
		ifFalse: [''].
	stream := (WriteStream on: String new)
		nextPutAll: 'addDictionary'; tab;
		nextPutAll: newName; tab;
		nextPutAll: currentName; tab;
		lf;
		nextPutAll: self requestString;
		yourself.
	self updateCommand: stream contents.
!

inspectGlobal

	| oopType |
	oopType := self gciSession oopTypeWithOop: (globalsPresenter selection at: 4) asNumber.
	(Smalltalk at: #'JadeInspector' ifAbsent: [^self]) showOn: oopType session: self gciSession.
!

isCategoryTabSelected
	^methodFilterTabs currentCard name = 'categoryList'!

isClassListTabSelected
	^classHierarchyTabs currentCard name = 'classList'!

isClassSelectedInEditor

	| range string |
	(range := methodSourcePresenter view selectionRange) isEmpty ifTrue: [^false].
	string := methodSourcePresenter value copyFrom: range start to: range stop.
	^(string allSatisfy: [:each | each isAlphaNumeric]) and: [string first isLetter and: [string first isUppercase]]
!

isClassSideSelected

	^instanceClassTabs currentCard name = 'classTab'.
!

isDictionariesTabSelected

	^packageDictionaryTabs currentCard name = 'dictionaryList'.
!

isGlobalsTabSelected

	^textAreaTabs currentCard name = 'globals'.
!

isPackageListTabSelected

	^packageDictionaryTabs currentCard name = 'packageList'.
!

isPragmasTabSelected

	^methodFilterTabs currentCard name = 'pragmaList'.
!

isTreeModel: treeModelA equivalentTo: treeModelB

	| listA listB |
	listA := (treeModelA asBag collect: [:each | each key printString]) asSortedCollection asArray.
	listB := (treeModelB asBag collect: [:each | each key printString]) asSortedCollection asArray.
	^listA = listB.
!

isVariablesTabSelected

	^methodFilterTabs currentCard name = 'variableList'.
!

jadeDebug
	[
		gciSession debugString: self currentSelectionOrLine fromContext: nil environment: environment.
	] on: GsCompileError do: [:ex | 
		self jadeExecute.
	].
!

jadeDisplay

	self jadeExecuteAndDisplay: true.
!

jadeExecute

	self jadeExecuteAndDisplay: false.
!

jadeExecuteAndDisplay: aBoolean


	| textView result value selectionRange offset |
	textView := View focus.
	result := self executeSelectionOrLine.
	result key ifTrue: [	"success"
		value := result value.
		result := ''.
		aBoolean ifTrue: [
			(self gciSession isOopType: value) ifFalse: [
				result := ' ' , value printString.
			] ifTrue: [
				result := ' ' , (self gciSession printString: value).
			].
		].
		selectionRange := textView selectionRange.
		textView
			caretPosition: selectionRange stop + 1;
			replaceSelection: result;
			selectionStart: textView caretPosition - result size length: result size.
		^value.
	] ifFalse: [		"compile error"
		| string count |
		(result := result value first) isNil ifTrue: [^self].
		offset := result at: 2.
		result := result at: 3.
		selectionRange := textView selectionRange.
		(string := textView text) size < selectionRange stop ifTrue: [
			self error: 'Select beyond the end of the text!!?'.
			"string := documentPresenter value."
		].
		string := string copyFrom: selectionRange start to: selectionRange stop.
		string := string replaceCrLfWithLf copyFrom: 1 to: offset - 1.
		count := (string select: [:each | each = Character lf]) size.
		offset := offset + count.
		textView
			caretPosition: selectionRange start + offset - 1;
			replaceSelection: result;
			selectionStart: textView caretPosition - result size length: result size.
		^self
	].
!

jadeMenuStrings

	false ifTrue: [
		self abortTransaction; commitTransaction; newWorkspace; newProjectBrowser; rename; exit.
	].
	^#(
		'&Jade'
		'&Abort Transaction//abortTransaction'
		'&CommitTransaction//commitTransaction'
		'-'
		'&New Workspace/Ctrl+N/newWorkspace'
		'&Open Projects Browser/Ctrl+B/newProjectBrowser'
		'-'
		'&Rename Selection/F2/rename'
		'-'
		'E&xit/Shift+F4/exit'
	).
!

jumpToHistoryIndex: anInteger

	| commandString historyEntry |
	historyIndex := anInteger.
	historyEntry := historyList at: anInteger.
	commandString := historyEntry at: 3.
	self 
		updateCommand: commandString;
		updateMenuBar;
		yourself.
	methodSourcePresenter ensureVisible.!

labelOfClass: oldName changedTo: newName

	| stream |
	oldName = self selectedClassNameWithoutVersion.
	stream := (WriteStream on: String new)
		nextPutAll: 'changeClassName'; tab;
		nextPutAll: self selectedClassNameWithoutVersion; tab;
		nextPutAll: selectedClassOop printString; tab;
		nextPutAll: newName; tab;
		lf; nextPutAll: self requestString;
		yourself.
	self selectedClassName: newName.
	self updateCommand: stream contents.
!

labelOfClass: oldName editedTo: newName accept: aValueHolder

	| stream string |
	oldName = self selectedClassNameWithoutVersion.
	stream := (WriteStream on: String new)
		nextPutAll: 'checkUniqueClassName'; tab;
		nextPutAll: oldName; tab;
		nextPutAll: selectedClassOop printString; tab;
		nextPutAll: newName; tab; lf;
		yourself.
	(string := self updateCommand: stream contents) notEmpty ifTrue: [
		MessageBox warning: string.
	] ifFalse: [
		aValueHolder value: true.
	].
!

layoutInfo

	^OrderedCollection new
		add: self requestStringForUpdate;
		add: self horizontalSplitter position;
		add: environment;
		asArray.
!

layoutInfo: anArray
	environment := (anArray size < 3) ifTrue: [0] ifFalse: [anArray at: 3].
	view ensureVisible.
	anArray isNil ifTrue: [
		self updateAndSelect: nil.
		^self.
	].
	self 
		updateCommand: (anArray at: 1);
		updateMenuBar;
		yourself.
	methodListPresenter hasSelection ifTrue: [
		methodSourcePresenter ensureVisible.
	].
	[
		view layoutManager reposition: self horizontalSplitter to: (anArray at: 2).
		view layout.
	] postToInputQueue.
!

loadLatestVersion

	| stream |
	stream := WriteStream on: String new.
	stream nextPutAll: 'loadLatestVersion'.
	packageListPresenter selections do: [:each | stream tab; nextPutAll: each key].
	stream lf; nextPutAll: self requestString.
	self updateCommand: stream contents.
!

methodDoubleClicked: anObject

	| range string |
	range := methodSourcePresenter view selectionRange.
	string := methodSourcePresenter value.
	string size = range stop ifTrue: [^self].
	(string at: range stop + 1) = $: ifFalse: [^self].
	range stop: range stop + 1.
	methodSourcePresenter view selectionRange: range.
!

methodFilterListPresenter

	| name |
	name := methodFilterTabs currentCard name.
	name = 'categoryList' ifTrue: [^categoryListPresenter].
	name = 'variableList' ifTrue: [^variableListPresenter].
	name = 'pragmaList' ifTrue: [^pragmaListPresenter].
	self error: 'Unrecognized method filter name'.
!

methodHoverEnd: anObject

	methodSourcePresenter view cancelCallTip.!

methodHoverStart: aPoint

	| charIndex indicator |
	charIndex := methodSourcePresenter view charNearestPosition: aPoint.
	indicator := methodSourcePresenter view indicators
		detect: [:each | each range includes: charIndex]
		ifNone: [^self].
	methodSourcePresenter view 
		showCallTip: indicator tag
		at: charIndex.
!

methodListPresenter

	^methodListPresenter!

methodsIdentifier

	| stream |
	stream := (WriteStream on: String new)
		nextPutAll: self behaviorIdentifier;
		yourself.
	methodListPresenter selections do: [:each | stream tab; nextPutAll: each first].
	^stream contents.
!

methodSourcePresenter

	^methodSourcePresenter.
!

onDragClassesOverDictionary: aSession 

	(dictionaryListPresenter selections includes: aSession suggestedTarget) ifTrue: [^self].
	aSession
		supportedOperations: #(#'copy' #'move');
		operation: #'move';
		yourself.
!

onDragClassesOverPackageList: aSession

	aSession
		supportedOperations: #(#'move');
		operation: #'move';
		yourself.
!

onDragClassHierarchy: aSession
	| className |
	className := classHierarchyPresenter selection last.
	^super onDragClass: aSession className: className!

onDragClassList: aSession 

	| list |
	list := classListPresenter selections collect: [:each | 
		(aSession newDragObject: each)
			format: #class data: each;
			yourself.
	].
	aSession 
		dragObjects: list;
		supportedOperations: #(#move #copy);
		defaultOperation: #move;
		yourself.
!

onDragCutClassHierarchy: aSession 
!

onDragCutClassList: aSession 
!

onDragCutMethod: aSession 

	"self halt."!

onDragMethodsOverClassHierarchy: aSession

	aSession
		supportedOperations: #(#'copy' #'move');
		operation: #'copy';
		yourself.
!

onDragMethodsOverClassList: aSession

	aSession
		supportedOperations: #(#'copy' #'move');
		operation: #'copy';
		yourself.
!

onDragOverClassCategory: aSession 

	aSession operation: nil.
	aSession dragObjects isEmpty ifTrue: [^self].
	aSession suggestedTarget isNil ifTrue: [^self].
	(aSession isFormatAvailable: #'class') ifFalse: [^self].
	aSession
		supportedOperations: #(#'move');
		operation: #'move';
		yourself.
!

onDragOverClassHierarchy: aSession 

	aSession operation: nil.
	aSession dragObjects isEmpty 			ifTrue: [^self].
	aSession suggestedTarget isNil 			ifTrue: [^self].
	(aSession isFormatAvailable: #'class') 	ifTrue: [^self].
	(aSession isFormatAvailable: #'method')	ifTrue: [^self onDragMethodsOverClassHierarchy: aSession].
	MessageBox notify: 'Sorry, we are not yet prepared to handle ' , aSession printString , '!!'.
	SessionManager current pause.!

onDragOverClassList: aSession 

	aSession operation: nil.
	aSession dragObjects isEmpty ifTrue: [^self].
	aSession suggestedTarget isNil ifTrue: [^self].
	(aSession isFormatAvailable: #'class')			ifTrue: [^self].
	(aSession isFormatAvailable: #'method') 	ifTrue: [^self onDragMethodsOverClassList: aSession].
	MessageBox notify: 'Sorry, we are not yet prepared to handle ' , aSession printString , '!!'.
	SessionManager current pause.
!

onDragOverDictionary: aSession 

	aSession operation: nil.
	aSession dragObjects isEmpty ifTrue: [^self].
	aSession suggestedTarget isNil ifTrue: [^self].
	(aSession isFormatAvailable: #'class') 				ifTrue: [^self onDragClassesOverDictionary: aSession].
	MessageBox notify: 'Sorry, we are not yet prepared to handle ' , aSession printString , '!!'.
	SessionManager current pause.
!

onDragOverMethodCategory: aSession 
	aSession operation: nil.
	aSession dragObjects isEmpty ifTrue: [^self].
	aSession suggestedTarget isNil ifTrue: [^self].

	(aSession isFormatAvailable: #'method') ifFalse: [^self].
	aSession
		supportedOperations: #(#'move');
		operation: #'move';
		yourself.
!

onDragOverPackageList: aSession 

	aSession operation: nil.
	aSession dragObjects isEmpty ifTrue: [^self].
	aSession suggestedTarget isNil ifTrue: [^self].
	(aSession isFormatAvailable: #'package') ifTrue: [^self].
	(aSession isFormatAvailable: #'class') 	ifTrue: [^self onDragClassesOverPackageList: aSession].
	MessageBox notify: 'Sorry, we are not yet prepared to handle ' , aSession printString , '!!'.
	SessionManager current pause.
!

onDropClassesOnDictionary: aSession 

	| classNames stream |
	classNames := aSession dragObjects collect: [:each | each format: #'class'].
	stream := (WriteStream on: String new)
		nextPutAll: 'classesToDictionary'; tab;
		nextPutAll: aSession operation; tab;
		nextPutAll: aSession suggestedTarget key;
		lf.
	dictionaryListPresenter selections do: [:each | stream nextPutAll: each key; tab].
	stream lf.
	classNames do: [:each | stream nextPutAll: each; tab].
	stream lf; nextPutAll: self requestString.
	self updateCommand: stream contents.
!

onDropClassesOnPackage: aString session: aSession 

	| classes stream |
	classes := aSession dragObjects collect: [:each | each format: #'class'].
	MessageBox notify: 'Sorry, we are not yet prepared to handle ' , aSession printString , '!!'.
	SessionManager current pause.
"
	stream := (WriteStream on: String new)
		nextPutAll: 'methodClass'; tab;
		nextPutAll: self behaviorIdentifier; tab;
		nextPutAll: aSession operation; tab;
		nextPutAll: aString;
		yourself.
	classes do: [:each | stream tab; nextPutAll: each].
	stream lf; nextPutAll: self requestString.
	self updateCommand: stream contents.
"!

onDropClassesOnPackageList: aSession 

	self
		onDropClassesOnPackage: aSession suggestedTarget 
		session: aSession.!

onDropMethodsOnClass: aString session: aSession 

	| selectors stream |
	selectors := aSession dragObjects collect: [:each | each format: #'method'].
	stream := (WriteStream on: String new)
		nextPutAll: 'methodClass'; tab;
		nextPutAll: self behaviorIdentifier; tab;
		nextPutAll: aSession operation; tab;
		nextPutAll: aString;
		yourself.
	selectors do: [:each | stream tab; nextPutAll: each].
	stream lf; nextPutAll: self requestString.
	self updateCommand: stream contents.
!

onDropMethodsOnClassHierarchy: aSession
	self onDropMethodsOnClass: aSession suggestedTarget last session: aSession!

onDropMethodsOnClassList: aSession
	self onDropMethodsOnClass: aSession suggestedTarget session: aSession!

onDropOnClassCategory: aSession 

	| classNames stream |
	classNames := aSession dragObjects collect: [:each | each format: #'class'].
	stream := (WriteStream on: String new)
		nextPutAll: 'classCategory'; tab;
		yourself.
	aSession suggestedTarget key do: [:each | stream nextPutAll: each; nextPut: $-].
	stream tab.
	classNames do: [:each | stream nextPutAll: each; space].
	stream lf; nextPutAll: self requestString.
	self updateCommand: stream contents.
!

onDropOnClassHierarchy: aSession 

	(aSession isFormatAvailable: #'method') ifTrue: [^self onDropMethodsOnClassHierarchy: aSession].
	MessageBox notify: 'Sorry, we are not yet prepared to handle ' , aSession printString , '!!'.
	SessionManager current pause.
!

onDropOnClassList: aSession 

	(aSession isFormatAvailable: #'method') ifTrue: [^self onDropMethodsOnClassList: aSession].
	MessageBox notify: 'Sorry, we are not yet prepared to handle ' , aSession printString , '!!'.
	SessionManager current pause.
!

onDropOnDictionary: aSession 

	(aSession isFormatAvailable: #'class') ifTrue: [^self onDropClassesOnDictionary: aSession].
	MessageBox notify: 'Sorry, we are not yet prepared to handle ' , aSession printString , '!!'.
	SessionManager current pause.
!

onDropOnMethodCategory: aSession 

	| selectors stream |
	selectors := aSession dragObjects collect: [:each | each format: #'method'].
	stream := (WriteStream on: String new)
		nextPutAll: 'methodCategory'; tab;
		nextPutAll: self behaviorIdentifier; tab;
		nextPutAll: aSession suggestedTarget trimBlanks;
		yourself.
	selectors do: [:each | stream tab; nextPutAll: each].
	stream lf; nextPutAll: self requestString.
	self updateCommand: stream contents.
!

onDropOnPackageList: aSession 

	(aSession isFormatAvailable: #'class') 	ifTrue: [^self onDropClassesOnPackageList: aSession].
	MessageBox notify: 'Sorry, we are not yet prepared to handle ' , aSession printString , '!!'.
	SessionManager current pause.!

onSetFocus: aView stack: aString

	[
		| startTime activeView |
		startTime := TimeStamp current.
		(Delay forMilliseconds: 50) wait.
		aView ~~ (activeView := View active) ifTrue: [^self].		"If view changed then there is no point in updating it!!"
		view = DeafObject current ifTrue: [^self].
		eventCount = gciSession eventCount ifTrue: [^self].
		super onSetFocus.
		[
			self updateAndSelect: nil.
		] on: Error do: [:ex | 
			SessionManager current logError: ex.
			ignoreNextSetFocusEvent := true.
			MessageBox 
				errorMsg: ex description
				caption: 'Jade Error'.
			Keyboard default isShiftDown ifTrue: [
				| stream |
				stream := WriteStream on: String new.
				ex printTraceOn: stream.
				(JadeWorkspace showOnSession: gciSession) showText: stream contents.
			].
		].
	] ensure: [
		updateProcess := nil.
	].
!

openSourceStyler
	| textStyles |
	textStyles := methodSourcePresenter view editStyles textStyles.
	JadeiteTextStyles default textStyles: textStyles.
	classDefinitionPresenter view textStyles: textStyles.
	originalSourcePresenter view textStyles: textStyles!

packageListPresenter

	^packageListPresenter!

parseContext

	^nil!

pkgDictChanged

	| listModel | 
	listModel := (textAreaTabs subViews detect: [:each | each class == TabViewXP]) model.
	globalsLabel ifNil: [globalsLabel := listModel detect: [:each | each text = 'Globals']].
	packageLabel ifNil: [packageLabel := listModel detect: [:each | each text = 'Package']].
	self isPackageListTabSelected ifTrue: [
		(listModel includes: packageLabel) ifFalse: [listModel addFirst: packageLabel].
		packageInfoTab ensureVisible.
		listModel remove: globalsLabel ifAbsent: [].
		self updateAndSelect: packageInfoTab.
	] ifFalse: [
		(listModel includes: globalsLabel ) ifFalse: [listModel addFirst: globalsLabel].
		globalsPresenter ensureVisible.
		listModel remove: packageLabel ifAbsent: [].
		self updateAndSelect: globalsPresenter.
	].
!

pkgsMenuStrings
	0 == 1
		ifTrue: 
			[self
				findClass;
				addPackage;
				loadLatestVersion;
				addRepository;
				removeRepository;
				savePackage;
				showPackageChanges;
				deletePackage].
	^#('&Packages' '&Find Class.../Ctrl+Shift+F/findClass' '&Add Package...//addPackage' '-' '&Load Latest Version//loadLatestVersion' 'Add &Repository...//addRepository' 'Remo&ve Repository...//removeRepository' '&Write Package..//savePackage' 'Show &Changes//showPackageChanges' '&Unload Package...//unloadPackage')!

preferencesMenuStrings

	false ifTrue: [		"adding explicit senders ensures that packaging will not drop methods and allows us to find references by browsing senders"
		self openSourceStyler; setColorForCompileErrors; setColorForNoEdits; setColorForUnsavedEdits.
	].
	^#(
		'&Preferences'
		'&Source Styler...//openSourceStyler'
		'-'
		'&Reset Colors//resetColors'
		'Color for &Compile Errors...//setColorForCompileErrors'
		'Color for &No Edits...//setColorForNoEdits'
		'Color for &Unsaved Edits...//setColorForUnsavedEdits'
	).
!

promptForSelector

	| string list stream |
	ignoreNextSetFocusEvent := true.
	(string := Prompter prompt: 'Enter selector:') isNil ifTrue: [^nil].
	((string includes: $:) and: [string includes: Character space]) ifTrue: [
		list := string subStrings: Character space.
		list := list select: [:each | each last = $:].
		stream := WriteStream on: String new.
		list do: [:each | stream nextPutAll: each].
		string := stream contents.
	].
	string := string reject: [:each | each = Character space].
	^string.!

removeClass

	| list stream result |
	list := self selectedClasses.
	stream := WriteStream on: String new.
	list do: [:each | stream nextPutAll: each; cr].
	result := MessageBox 
		confirm: stream contents 
		caption: 'Remove the following class(s)?'.
	result ifFalse: [^self].
	stream := WriteStream on: String new.
	stream nextPutAll: 'removeClasses'; lf.
	self addPackageDictionaryInfoTo: stream.
	list do: [:each | stream nextPutAll: each; tab].
	stream lf; nextPutAll: self requestString.
	self updateCommand: stream contents.

!

removeDictionary

	| list stream result |
	list := dictionaryListPresenter selections collect: [:each | each key].
	stream := WriteStream on: String new.
	list do: [:each | stream nextPutAll: each; cr].
	result := MessageBox 
		confirm: stream contents 
		caption: 'Remove the following dictionary(s)?'.
	result ifFalse: [^self].
	stream := (WriteStream on: String new)
		nextPutAll: 'removeDictionaries'; tab;
		yourself.
	list do: [:each | 
		stream nextPutAll: each; tab.
	].
	stream lf; nextPutAll: self requestString.
	self updateCommand: stream contents.
!

removeGlobals

	| stream |
	stream := (WriteStream on: String new)
		nextPutAll: 'removeGlobals'; lf;
		yourself.
	dictionaryListPresenter selections do: [:each | 
		stream nextPutAll: each key; tab.
	].
	stream lf.
	globalsPresenter selections do: [:each | 
		stream nextPutAll: each first; tab.
	].
	stream lf; nextPutAll: self requestString.
	self updateCommand: stream contents.
!

removeMethodCategories

	| stream |
	stream := WriteStream on: String new.
	stream
		nextPutAll: 'removeMethodCategories'; tab;
		nextPutAll: self selectedClassNameWithoutVersion; tab;
		nextPutAll: selectedClassOop printString; tab;
		nextPutAll: instanceClassTabs currentCard name;
		yourself.
	categoryListPresenter selections do: [:each | stream tab; nextPutAll: each trimBlanks].
	stream lf.
	self updateCommand: stream contents , self requestString.
!

removePriorVersions

	| stream |
	stream := WriteStream on: String new.
	stream nextPutAll: 'removePriorVersions'; lf.
	self addPackageDictionaryInfoTo: stream.
	self selectedClasses do: [:each | stream nextPutAll: each; tab].
	stream lf; nextPutAll: self requestString.
	self updateCommand: stream contents.
!

removeRepository

	|stream |
	stream := (WriteStream on: String new)
		nextPutAll: 'removeRepository'; tab;
		nextPutAll: (repositoryListPresenter selection at: 2);
		yourself.
	packageListPresenter selections do: [:each | stream tab; nextPutAll: each key].
	stream lf.
	self updateCommand: stream contents , self requestString.
!

reportCompileError: anArrayOfArray
	| source position stream string indicators |
	indicators := OrderedCollection new.
	methodSourcePresenter view clearContainerIndicators.
	source := self currentMethodSource , Character lf asString.
	position := methodSourcePresenter view caretPosition.
	methodSourcePresenter value: source.
	methodSourcePresenter view caretPosition: position.
	stream := WriteStream on: String new.
	anArrayOfArray do: 
			[:eachArray |
			| start |
			start := eachArray at: 2.
			string := eachArray at: 3.
			stream nextPutAll: string , '; '.
			indicators add: (ScintillaIndicator
						styleName: #compileError
						range: (start to: (start + 10 min: source size))
						tag: string)].
	methodSourcePresenter view backcolor: JadeiteTextStyles default colorForCompileError.
	methodSourcePresenter view indicators: indicators.
	string := stream contents.
	self statusBarText: (string copyFrom: 1 to: string size - 2)!

requestString

	| stream |
	stream := WriteStream on: String new.
	self
		addPackageDictionaryInfoTo: stream;
		addClassCategoryInfoTo: stream;
		addClassHierarchyInfoTo: stream;
		addMethodInfoTo: stream;
		yourself.
	^stream contents.!

requestStringForUpdate

	^'update' , Character lf asString , self requestString.
!

resetColors
	JadeiteTextStyles default resetColors!

revertNewClass

	| stream |
	stream := WriteStream on: String new.
	stream nextPutAll: 'revertClass'; lf.
	self addPackageDictionaryInfoTo: stream.
	stream nextPutAll: selectedClassName subStrings first.
	stream lf; nextPutAll: self requestString.
	self updateCommand: stream contents.
!

runMethodTests

	| result |
	result := self gciSession 
		serverPerform: #'sbRunMethodTests:' 
		with: self methodsIdentifier.
	result == true ifFalse: [self error: 'unexpected result!!'].
	MessageBox notify: 'Ran ' , methodListPresenter selections size printString , ' test(s)'.
!

selectClass: aString selector: methodString
"
	Array with: className with: dictionaryName with: category with: packageName.
"
	| string list className isMeta array |
	updateProcess ifNotNil: [		"https://github.com/jgfoster/Jade/issues/109"
		updateProcess terminate.
		updateProcess := nil.
	].
	string := self gciSession 
		serverPerform: #'systemBrowser:' 
		with: environment printString , ' findClass'.
	list := (string subStrings: Character lf) collect: [:each | each subStrings: Character tab].
	list := list copyFrom: 2 to: list size.
	list := list collect: [:each | each size < 3 ifTrue: [each , #('' '' '')] ifFalse: [each]].
	className := aString.
	(isMeta := className endsWith: ' class') ifTrue: [
		className := className copyFrom: 1 to: className size - 6.
	].
	array := list detect: [:each | each first subStrings first = className].
	self 
		updateAfterFindClass: array
		isMeta: isMeta 
		selector: methodString.
!

selectedClassChanged: aBoolean
		"We don't want the previous class' method filter to apply to new class"

	selectedClassChanged := aBoolean.
!

selectedClasses

	| list |
	(list := classListPresenter selections) isEmpty ifTrue: [
		(list := classHierarchyPresenter selections) notEmpty ifTrue: [
			list := Array with: list last last.
		].
	].
	^list.
!

selectedClassName
	^self selectedClasses isEmpty ifTrue: [nil] ifFalse: [self selectedClasses first]!

selectedClassName: aString

	selectedClassName := aString.
	self updateTabLabel.
!

selectedClassNameWithoutVersion

	^(selectedClassName includes: Character space)
		ifTrue: [selectedClassName subStrings first]
		ifFalse: [selectedClassName].
!

selectedMethodChanged

	| historyEntry |
	self updateAndSelect: methodSourcePresenter.
	methodListPresenter selections size == 1 ifFalse: [^self].
	historyList := historyList copyFrom: 1 to: historyIndex.	"trim any forward options on an explicit manual selection"
	historyEntry := Array
		with: selectedClassName , (self isClassSideSelected ifTrue: [' class'] ifFalse: [''])
		with: (methodListPresenter selection at: 1)
		with: self requestStringForUpdate.
	historyList add: historyEntry.
	historyIndex := historyList size.
!

selectedMethodName

	^methodListPresenter selections first first.
!

setColorForCompileErrors
	| newColor |
	newColor := ColorDialog showModalOn: JadeiteTextStyles default colorForNoEdits.
	newColor ifNotNil: [JadeiteTextStyles default colorForCompileError: newColor]!

setColorForNoEdits
	| newColor |
	newColor := ColorDialog showModalOn: JadeiteTextStyles default colorForNoEdits.
	newColor ifNotNil: [JadeiteTextStyles default colorForNoEdits: newColor]!

setColorForUnsavedEdits
	| newColor |
	newColor := ColorDialog showModalOn: JadeiteTextStyles default colorForUnsavedEdits.
	newColor ifNotNil: [JadeiteTextStyles default colorForUnsavedEdits: newColor]!

setEnvironment: anInteger

	environment := anInteger.
	self updateCommand: self requestStringForUpdate.
!

setEnvironment0

	self setEnvironment: 0
!

setEnvironment1

	self setEnvironment: 1
!

setEnvironment2

	self setEnvironment: 2
!

setHomeDictionary

	| string |
	string := 'setHomeDictionary' , Character tab asString , dictionaryListPresenter selection key , Character lf asString , self requestString.
	self updateCommand: string.
!

setSearchPolicy

	ancestorListPresenter 	view model searchPolicy: SearchPolicy equality.
	categoryListPresenter 	view model searchPolicy: SearchPolicy equality.
	classCategoryPresenter	view model searchPolicy: SearchPolicy equality.
	classHierarchyPresenter	view model searchPolicy: SearchPolicy equality.
	classListPresenter		view model searchPolicy: SearchPolicy equality.
	dictionaryListPresenter 	view model searchPolicy: SearchPolicy equality.
	globalsPresenter		view model searchPolicy: SearchPolicy equality.
	methodListPresenter		view model searchPolicy: SearchPolicy equality.
	overrideListPresenter	view model searchPolicy: SearchPolicy equality.
	packageListPresenter 	view model searchPolicy: SearchPolicy equality.
	pragmaListPresenter		view model searchPolicy: SearchPolicy equality.
	repositoryListPresenter	view model searchPolicy: SearchPolicy equality.
	superclassListPresenter	view model searchPolicy: SearchPolicy equality.
	variableListPresenter	 	view model searchPolicy: SearchPolicy equality.
!

showPackageChanges

	| repository stream patch |
	repository := repositoryListPresenter hasSelection 
		ifTrue: [repositoryListPresenter selection]
		ifFalse: [repositoryListPresenter list first].
	stream := (WriteStream on: String new)
		nextPutAll: 'changesInPackage'; tab;
		nextPutAll: packageListPresenter selections first key; tab;	"package name"
		nextPutAll: (repository at: 2); tab;		"repository name"
		lf.
	(self updateCommand: stream contents) = 'changesInPackage' ifFalse: [self error: 'Unexpected response!!'].
	patch := MCPatch
		fromString: readStream upToEnd
		session: self gciSession.
	patch operations isEmpty ifTrue: [
		MessageBox notify: 'No changes!!'.
		^self.
	].
	MCPatchBrowser showOn: patch.
!

splitterPosition: aPoint

	[
		| splitter |
		splitter := view viewNamed: 'splitter' ifNone: [self error: 'splitter is missing!!?'].
		view layoutManager reposition: splitter to: aPoint.
		view layout.
	] postToInputQueue.

!

statusBarServerRequestText: aString

	self parentPresenter parentPresenter statusBarServerRequestText: aString.
!

statusBarText: aString
	self parentPresenter parentPresenter statusBarText: aString.
!

stepPointAt: aPoint

	| charIndex |
	charIndex := methodSourcePresenter view charNearestPosition: aPoint.
	stepPoints size to: 1 by: -1 do: [:stepPoint | 
		| range |
		range := (stepPoints at: stepPoint) key.
		(range start <= charIndex and: [charIndex <= range stop]) ifTrue: [
			^stepPoint.
		].
	].
	^nil.
!

stuffToKeepFromPath: pathString andAddTo: newSource

	| file existingSource i j string existingHeader newHeader x |
	[
		file := FileStream
			read: pathString
			text: true.
	] on: Exception do: [:ex | ^''].
	existingSource := file contents.
	file close.
	string := 'doit' , Character lf asString.
	(i := existingSource indexOfSubCollection: string) <3 ifTrue: [^''].
	(j := newSource indexOfSubCollection: string) <3 ifTrue: [^''].
	(i == j and: [(existingSource copyFrom: 1 to: i) = (newSource copyFrom: 1 to: j)]) ifTrue: [^''].
	existingHeader := existingSource copyFrom: 1 to: i - 2.
	newHeader := newSource copyFrom: 1 to: j - 2.
	[
		0 < (i := existingHeader size - newHeader size) and: [
			x := existingHeader copyFrom: i + 1 to: existingHeader size.
			x = newHeader.
		].
	] whileTrue: [
		existingHeader = newHeader ifTrue: [^''].
		existingHeader := existingHeader copyFrom: 1 to: i - 1.
	].
	^(MessageBox confirm: 'Add the following header to the fileout?
' , existingHeader caption: 'Existing fileout has extra line(s) at the top') 
		ifTrue: [existingHeader , Character lf asString]
		ifFalse: [''].

!

sunitPresenter
	"Private - for testing"

	^sunitPresenter!

textTabChanged

	methodSourcePresenter view cancelCallTip.
	(textAreaTabs currentCard name = 'globals' 	and: [self isPackageListTabSelected	]) ifTrue: [packageInfoTab 	ensureVisible].
	(textAreaTabs currentCard name = 'packageInfo' and: [self isDictionariesTabSelected	]) ifTrue: [globalsPresenter 	ensureVisible].
	self updateMenuBar.
!

updateAfterFindClass: anArray isMeta: aBoolean selector: aString
"
	Array with: className with: dictionaryName with: catetory with: packageName.

	packageDictionaryTabs currentCard name
	package or dictionary selections (tab-delimited)
	category-subcategory-subsubcategory-
	classHierarchyTabs currentCard name
	selected classes (tab-delimited)
	instanceClassTabs currentCard name
	superclassList selection
	categoryVariableTabs currentCard name
	methodFilterList selections (tab-delimited)
	methodList selections (tab-delimited)
	overrideList selection
"
	| stream tabName |
	anArray isNil ifTrue: [^self].
	stream := WriteStream on: String new.
	tabName := (anArray at: 4) isEmpty 
		ifTrue: ['dictionaryList']
		ifFalse: [packageDictionaryTabs currentCard name].
	stream 
		nextPutAll: 'update'; lf;
		nextPutAll: tabName; lf;	"[ packageList | dictionaryList ]"
		nextPutAll: (tabName = 'packageList' ifTrue: [anArray at: 4] ifFalse: [anArray at: 2]); lf; 	"Package or Dictionary name"
		nextPutAll: (anArray at: 3); nextPut: $-; lf;	"class category"
		nextPutAll: 'classList'; lf;	"not hierarchy"
		nextPutAll: (anArray at: 1); lf;	"className"
		nextPutAll: (aBoolean ifNil: ['default'] ifNotNil: [aBoolean ifTrue: ['classTab'] ifFalse: ['instanceTab']]); lf;
		lf; 	"superclass"
		nextPutAll: 'categoryList'; lf;	"not variables"
		lf;		"methodFilter (category or variable)"
		nextPutAll: aString; lf; 	"method names"
		lf;		"override"
		yourself.
	self updateCommand: stream contents.
!

updateAndSelect: aView

	updateCount := updateCount + 1.
	keystrokeTime < Time millisecondClockValue ifTrue: [
		self updateAndSelectA: aView.
	] ifFalse: [
		[self updateAndSelectB: aView] fork.
	].
!

updateAndSelectA: aView

	inUpdate ifTrue: [^self].
	self updateCommand: self requestStringForUpdate.
	self updateMenuBar.
	aView notNil ifTrue: [aView ensureVisible].
!

updateAndSelectB: aView

	| oldUpdateCount |
	oldUpdateCount := updateCount.
	(Delay forMilliseconds: keystrokeTime - Time millisecondClockValue) wait.
	oldUpdateCount = updateCount ifTrue: [
		self updateAndSelectA: aView.
	].
!

updateClassCategoryTree

	| root treeModel cache listA listB existingSelection newSelection |

	root := #() -> '--Categories--'.
	treeModel := TreeModel new
		searchPolicy: SearchPolicy equality;
		reset;
		add: root asChildOf: nil;
		yourself.
	cache := Dictionary new
		at: root key put: root;
		yourself.
	readStream nextLineAsList asSortedCollection do: [:each | 
		| array |
		array := each subStrings: $-.
		1 to: array size do: [:i | 
			| childName parentName child parent |
			childName := array copyFrom: 1 to: i.
			parentName := array copyFrom: 1 to: i - 1.
			parent := cache at: parentName.
			(cache includesKey: childName) ifFalse: [
				cache 
					at: childName
					put: (child := childName -> each).
				treeModel 
					add: child
					asChildOf: parent.
			].
		].
	].
	listA := (treeModel asBag collect: [:each | each key printString]) asSortedCollection asArray.
	listB := (classCategoryPresenter model asBag collect: [:each | each key printString]) asSortedCollection asArray.
	listA = listB ifFalse: [
		classCategoryPresenter
			model: treeModel;
			yourself.
	].
	newSelection := readStream nextLine subStrings: $-.
	newSelection isEmpty ifTrue: [newSelection := root key].
	existingSelection := (classCategoryPresenter selectionIfNone: [nil -> nil]) key.
	newSelection = existingSelection ifFalse: [
		| items item |
		items := classCategoryPresenter model asBag asArray.
		0 to: newSelection size do: [:i | 
			| key |
			key := newSelection copyFrom: 1 to: i.
			item := items detect: [:each | each key = key] ifNone: [nil].
			classCategoryPresenter expand: item.
		].
		classCategoryPresenter selection: item.
	].
	classCategoryPresenter view ensureSelectionVisible.
!

updateClassInfo
	| index newClassDefinition |
	selectedClassOop := readStream nextLine asNumber.
	newClassDefinition := readStream nextParagraph.
	classCommentPresenter value: readStream nextParagraph.
	classDefinitionPresenter view isModified
		ifTrue: 
			[newClassDefinition = classDefinition ifTrue: [^self].
			(MessageBox confirm: 'Copy changes to clipboard?' caption: 'Class has unsaved changes!!')
				ifTrue: [classDefinitionPresenter value copyToClipboard]].
	classDefinition := newClassDefinition.
	0 < (classDefinition indexOfSubCollection: 'MyNewClass')
		ifTrue: 
			["Template is based on Stream class, but we don't want to use 'Globals' in template"
			index := classDefinition indexOfSubCollection: ': Globals'.
			(0 < index and: [(classDefinition copyFrom: index - 2 to: index + 1) ~= 'User'])
				ifTrue: 
					[classDefinition := (classDefinition copyFrom: 1 to: index + 1)
								, (dictionaryListPresenter selectionIfNone: ['UserGlobals' -> false]) key
									, (classDefinition copyFrom: index + 9 to: classDefinition size).
					index := classDefinition indexOfSubCollection: 'User Classes'.
					0 < index
						ifTrue: 
							[classDefinition := (classDefinition copyFrom: 1 to: index - 1)
										, (packageListPresenter selectionIfNone: ['User Classes' -> nil]) key
											, (classDefinition copyFrom: index + 12 to: classDefinition size)]]].
	classDefinitionPresenter value: classDefinition.
	classDefinitionPresenter view
		backcolor: JadeiteTextStyles default colorForNoEdits;
		isModified: false;
		yourself!

updateClassListOrHierarchy

	| tab |
	tab := readStream nextLine.
	tab = 'classHierarchy' ifTrue: [^self updateClassHierarchy].
	tab = 'classList' ifTrue: [^self updateClassList].
	self error: 'Unexpected token!!'.
!

updateCommand: aString

	^self 
		updateCommand: aString 
		onSuccessDo: [].
!

updateCommand: aString onSuccessDo: aBlock
	
	[
		| time1 time2 time3 string |
		time1 := Time millisecondsToRun: [
			string := self gciSession 
				serverPerform: #'systemBrowser:' 
				with: environment printString , ' ' , aString.
			eventCount := self gciSession eventCount.
		].
		time2 := Time millisecondsToRun: [
			| responseType |
			readStream := JadeServerReadStream on: string.
			time3 := readStream nextLine asNumber.
			aBlock value.
			(responseType := readStream nextLine) = 'update' ifFalse: [^responseType].
			self updatePresenters.
		].
		self statusBarServerRequestText:
			'server took ' , time3 printString , 'ms; ' , 
			'network took ' , (time1 - time3) printString , 'ms; ' , 
			'client took ' , time2 printString , 'ms; ' , 
			'total of ' , (time1 + time2) printString , 'ms'.
	] ensure: [
		selectedClassChanged := false.
	].
	^nil.
!

updateDictionaryList

	| fullList selections lines |
	dictionaryListPresenter ensureVisible.
	fullList := readStream nextLineAsList collect: [:each | (each copyFrom: 2 to: each size) -> (each first = $H)].
	dictionaryListPresenter list = fullList ifFalse: [
		dictionaryListPresenter list: (ListModel withAll: fullList).
	].
	selections := readStream nextLineAsList collect: [:x | dictionaryListPresenter list detect: [:y | x = y key]].
	dictionaryListPresenter selections = selections ifFalse: [
		dictionaryListPresenter selections: selections.
	].
	dictionaryListPresenter view ensureSelectionVisible.
	lines := readStream nextList.
	globalsPresenter list: (ListModel withAll: lines).
!

updateMenuBar
	| shellView menuBar dictionaryMenu methodFilterMenu textAreaMenu |
	dictionaryMenu := Menu fromStrings: self dictsMenuStrings.
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
				addItem: dictionaryMenu;
				addItem: (Menu fromStrings: self classesMenuStrings);
				addItem: methodFilterMenu;
				addItem: (Menu fromStrings: self methodsMenuStrings);
				addItem: textAreaMenu;
				addItem: (Menu fromStrings: self preferencesMenuStrings);
				yourself.
	shellView menuBar: menuBar!

updateMethodFilter

	| listPresenter pieces type tabs tab filters selections |
	listPresenter := self methodFilterListPresenter.
	pieces := readStream nextLine subStrings: Character tab.
	type := pieces at: 1.
	1 < pieces size ifTrue: [environment := (pieces at: 2) asNumber].
	(tabs := methodFilterTabs cards) isEmpty ifTrue: [^self].
	tab := tabs detect: [:each | each name = type].
	tab ensureVisible.
	filters := readStream nextLineAsList reverse.
	filters = listPresenter list ifFalse: [
		listPresenter list: filters.
	].
	selections := readStream nextLineAsList.
	selections := listPresenter list select: [:each | selections includes: each].
	selections = listPresenter selections ifFalse: [
		listPresenter selections: selections.
	].
	selections notEmpty ifTrue: [
		listPresenter view ensureSelectionVisible.
	] ifFalse: [
		filters notEmpty ifTrue: [
			listPresenter view ensureVisible: 1.
		].
	].
!

updateMethodList

	| fullList selections |
	fullList := (readStream nextParagraph subStrings: Character lf) collect: [:each | (each subStrings: Character tab) , #('' '' '' '' '')].
	fullList := fullList do: [:each | 	"JadeServer>>#'sbUpdateMethods' "
		each 
			at: 2 put: (each at: 2) = 'T';		"has a superclass implementation"
			at: 3 put: (each at: 3) = 'T';		"is in a TestCase class"
			at: 4 put: (each at: 4) = 'T';		"method replaced by GsPackagePolicy"
			yourself.
	].
	fullList = methodListPresenter list ifFalse: [
		methodListPresenter list: (ListModel withAll: fullList).
	].
	selections := readStream nextLineAsList.	"JadeServer>>#'sbUpdateMethodSelectionsIn:' "
	selections := methodListPresenter list select: [:eachArray | selections includes: eachArray first].
	selections = methodListPresenter selections ifFalse: [
		methodListPresenter selections: selections.
	].
	selections notEmpty ifTrue: [
		methodListPresenter view ensureSelectionVisible.
	] ifFalse: [
		fullList notEmpty ifTrue: [
			methodListPresenter view ensureVisible: 1.
		].
	].

!

updateMethodStepPoints
	| indicators |
	methodSourcePresenter view clearContainerIndicators.
	indicators := OrderedCollection new.
	1 to: stepPoints size
		do: 
			[:stepPoint |
			| range string styleName |
			range := (stepPoints at: stepPoint) key.
			(unimplementedSelectors at: range start ifAbsent: [nil])
				ifNotNil: 
					[:value |
					styleName := 10.
					string := 'No implementors of #' , value printString , ' (found at step point #'
								, stepPoint printString , ')']
				ifNil: 
					[styleName := (breakPoints includes: stepPoint) ifTrue: [#disabledBreakPoint] ifFalse: [#stepPoint].
					string := ((breakPoints includes: stepPoint) ifTrue: ['Break at '] ifFalse: ['']) , 'step point #'
								, stepPoint printString].
			indicators add: (ScintillaIndicator
						styleName: styleName
						range: range
						tag: string)].
	methodSourcePresenter view indicators: indicators!

updateOverrideList

	| list selection |
	list := readStream nextLineAsList.		"JadeServer>>#'sbUpdateMethod:' "
	list = overrideListPresenter list ifFalse: [
		overrideListPresenter list: list.
	].
	selection := readStream nextLine.
	selection isEmpty ifTrue: [selection := nil].
	selection notNil ifTrue: [
		selection := overrideListPresenter list
			detect: [:each | each = selection]
			ifNone: [nil].
	].
	selection = overrideListPresenter selectionOrNil ifFalse: [
		overrideListPresenter selectionOrNil: selection.
	].
!

updatePackageDictionaryList

	| next |
	self rowanFixMe. "project list is updated by STON only" 
	next := readStream nextLine.
	next = 'dictionaryList' ifTrue: [^self updateDictionaryList].
	next = 'packageList' ifTrue: [^self updatePackageList].
	next = 'projectList' ifTrue: [^self updatePackageList]. 
	self error: 'Unexpected token'.
!

updatePackageInfo

	| list |
	list := readStream nextList collect: [:each | each , #('' '' '' '')].
	list = ancestorListPresenter list ifFalse: [
		ancestorListPresenter list: list.
	].
	list := readStream nextList collect: [:each | each , #('' '')].
	list = repositoryListPresenter list ifFalse: [
		repositoryListPresenter list: list.
	].
!

updatePackageList

	| dictionary fullList selections old new |

	packageListPresenter ensureVisible.
	dictionary := Dictionary new.
	readStream nextLineAsList do: [:each | dictionary at: each put: false].
	readStream nextLineAsList do: [:each | dictionary at: each put: true].
	fullList := dictionary associations asSortedCollection asArray.
	old := packageListPresenter list collect: [:each | each key].
	new := fullList collect: [:each | each key].
	old = new ifTrue: [
		packageListPresenter list do: [:each | 
			each value: (dictionary at: each key).
		].
		packageListPresenter view updateAll.
	] ifFalse: [
		packageListPresenter list: fullList.
	].
	selections :=  readStream nextLineAsList.
	selections := selections collect: [:x | packageListPresenter list detect: [:y | x = y key]].
	packageListPresenter selections = selections ifFalse: [
		packageListPresenter selections: selections.
	].
	selections size = 1 
		ifTrue: [self updatePackageInfo]
		ifFalse: [self clearPackageInfo].
	packageListPresenter view ensureSelectionVisible.
!

updatePresenters
	
	[inUpdate := true.
	self
		updatePackageDictionaryList;
		updateClassCategoryTree;
		updateClassListOrHierarchy;
		updateClassInfo;
		updateSuperclassList;
		updateMethodFilter;
		updateMethodList;
		updateOverrideList;
		updateSelector;
		updateTabLabel;
		yourself]
			ensure: [inUpdate := false]!

updateSuperclassList

	| tabs tabName tab list selected |
	tabName := readStream nextLine.
	(tabs := instanceClassTabs cards) isEmpty ifTrue: [^self].
	tab := tabs 
		detect: [:each | each name = tabName]
		ifNone: [self error: 'None of ' , tabs printString , ' match ' , tabName printString].
	tab ensureVisible.
	list := readStream nextLineAsList reverse.
	list = superclassListPresenter list ifFalse: [
		superclassListPresenter list: (ListModel withAll: list).
	].
	(selected := readStream nextLine) notEmpty ifTrue: [
		selected := (selected subStrings: Character tab) first.
	].
	selected := superclassListPresenter list
		detect: [:each | each = selected]
		ifNone: [list notEmpty ifTrue: [list last] ifFalse: [nil]].
	(selected = superclassListPresenter selectionOrNil) ifFalse: [
		superclassListPresenter selection: selected.
	].
!

updateTabLabel

	| cardNumber newLabel | 
	cardNumber := self parentPresenter view cards indexOf: self view.
	(newLabel := self selectedClassNameWithoutVersion) notEmpty ifTrue: [
		instanceClassTabs currentCard name = 'classTab' ifTrue: [
			newLabel := newLabel , ' class'.
		].
		0 < environment ifTrue: [newLabel := newLabel , ' [' , environment printString , ']'].
	] ifFalse: [
		| tabName selections |
		tabName := packageDictionaryTabs currentCard name.
		tabName = 'packageList' ifTrue: [
			newLabel := 'Packages'.
			selections := packageListPresenter selections.
		] ifFalse: [
			newLabel := 'Dictionaries'.
			selections := dictionaryListPresenter selections.
		].
		selections size = 1 ifTrue: [newLabel := selections first key].
	].
	self view arrangement: cardNumber printString , ' ' , newLabel.
	self parentPresenter view updateTabs.
!

variableListPresenter

	^variableListPresenter!

viewActivated

	Transcript cr; show: 'viewActivated'.

	"self update."
! !
!JadeSystemBrowserPresenter categoriesFor: #aboutToChange:!event handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #aboutToEditClassLabel:accept:!event handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #addClassCategoryInfoTo:!public!request string! !
!JadeSystemBrowserPresenter categoriesFor: #addClassHierarchyInfoTo:!public!request string! !
!JadeSystemBrowserPresenter categoriesFor: #addMethodCategory!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #addMethodInfoTo:!public!request string! !
!JadeSystemBrowserPresenter categoriesFor: #addMissingAccessors!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #addPackage!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #addPackageDictionaryInfoTo:!public!request string! !
!JadeSystemBrowserPresenter categoriesFor: #addRepository!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #addSubclass!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #behaviorIdentifier!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #breakAt:operation:!event handlers!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #browseGlobalReferences!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #browseImplementors!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #browseMethodHistory!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #browseMethodPragmas!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #browseSelectedClass!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #browseSenders!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #buildHistoryMenuNamed:from:to:by:!history!public! !
!JadeSystemBrowserPresenter categoriesFor: #categoriesMenuStrings!menus!public! !
!JadeSystemBrowserPresenter categoriesFor: #categoryListPresenter!accessing!public! !
!JadeSystemBrowserPresenter categoriesFor: #classCategoryPresenter!accessing!public! !
!JadeSystemBrowserPresenter categoriesFor: #classDefChanged!event handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #classesMenuStrings!menus!public! !
!JadeSystemBrowserPresenter categoriesFor: #classHierarchyPresenter!accessing!public! !
!JadeSystemBrowserPresenter categoriesFor: #classHierarchyTabs!public! !
!JadeSystemBrowserPresenter categoriesFor: #classListPresenter!accessing!public! !
!JadeSystemBrowserPresenter categoriesFor: #clearPackageInfo!public! !
!JadeSystemBrowserPresenter categoriesFor: #closeRequested:!event handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #compareAncestor!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #contextObject!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #createSchematicWiringForClassCategoryList!create schemantic wiring!overrides!public! !
!JadeSystemBrowserPresenter categoriesFor: #createSchematicWiringForClassDefinition!create schemantic wiring!public! !
!JadeSystemBrowserPresenter categoriesFor: #createSchematicWiringForClassHierarchy!create schemantic wiring!public! !
!JadeSystemBrowserPresenter categoriesFor: #createSchematicWiringForClassList!create schemantic wiring!public! !
!JadeSystemBrowserPresenter categoriesFor: #createSchematicWiringForDictionaryList!create schemantic wiring!public! !
!JadeSystemBrowserPresenter categoriesFor: #createSchematicWiringForInstanceClassTabs!create schemantic wiring!overrides!public! !
!JadeSystemBrowserPresenter categoriesFor: #createSchematicWiringForMethodCategoryList!create schemantic wiring!public! !
!JadeSystemBrowserPresenter categoriesFor: #createSchematicWiringForMethodList!create schemantic wiring!public! !
!JadeSystemBrowserPresenter categoriesFor: #createSchematicWiringForMethodSource!create schemantic wiring!public! !
!JadeSystemBrowserPresenter categoriesFor: #createSchematicWiringForOverrideList!create schemantic wiring!overrides!public! !
!JadeSystemBrowserPresenter categoriesFor: #createSchematicWiringForPackageDictionaryTabs!create schemantic wiring!public! !
!JadeSystemBrowserPresenter categoriesFor: #createSchematicWiringForPackageList!create schemantic wiring!public! !
!JadeSystemBrowserPresenter categoriesFor: #createSchematicWiringForPragmaList!create schemantic wiring!public! !
!JadeSystemBrowserPresenter categoriesFor: #createSchematicWiringForSuperClassList!create schemantic wiring!overrides!public! !
!JadeSystemBrowserPresenter categoriesFor: #createSchematicWiringForVariableList!create schemantic wiring!public! !
!JadeSystemBrowserPresenter categoriesFor: #currentSelectionOrLine!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #defaultFileExtension!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #delayUpdate!public!updating! !
!JadeSystemBrowserPresenter categoriesFor: #deletePackage!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #dictionaryListPresenter!accessing!public! !
!JadeSystemBrowserPresenter categoriesFor: #dictsMenuStrings!menus!public! !
!JadeSystemBrowserPresenter categoriesFor: #editCopy!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #editCut!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #editFind!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #editFindNext!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #editMenuStrings!menus!public! !
!JadeSystemBrowserPresenter categoriesFor: #editPaste!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #editRedo!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #editReplace!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #editSave!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #editSaveClassA!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #editSaveClassComment!public! !
!JadeSystemBrowserPresenter categoriesFor: #editSaveMethod!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #editSelectAll!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #editUndo!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #executeSelectionOrLine!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #fileInCode!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #fileOutClass!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #fileOutClassOnPath:!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #fileOutDictionary!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #fileOutMethod!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #fileOutMethodOnPath:!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #fileTypes!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #findClassList!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #gciSession:!overrides!public! !
!JadeSystemBrowserPresenter categoriesFor: #getSelectedMethod!public! !
!JadeSystemBrowserPresenter categoriesFor: #getViews!public! !
!JadeSystemBrowserPresenter categoriesFor: #globalsMenuStrings!menus!public! !
!JadeSystemBrowserPresenter categoriesFor: #handleInvalidSession!public! !
!JadeSystemBrowserPresenter categoriesFor: #hasCommandHistoryBack!history!public! !
!JadeSystemBrowserPresenter categoriesFor: #hasCommandHistoryForward!history!public! !
!JadeSystemBrowserPresenter categoriesFor: #historyBack!history!public! !
!JadeSystemBrowserPresenter categoriesFor: #historyBackMenu!history!public! !
!JadeSystemBrowserPresenter categoriesFor: #historyForward!history!public! !
!JadeSystemBrowserPresenter categoriesFor: #historyForwardMenu!history!public! !
!JadeSystemBrowserPresenter categoriesFor: #horizontalSplitter!public! !
!JadeSystemBrowserPresenter categoriesFor: #initialize!history!public! !
!JadeSystemBrowserPresenter categoriesFor: #insertDictionary!public! !
!JadeSystemBrowserPresenter categoriesFor: #inspectGlobal!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #isCategoryTabSelected!public!testing! !
!JadeSystemBrowserPresenter categoriesFor: #isClassListTabSelected!public!request string! !
!JadeSystemBrowserPresenter categoriesFor: #isClassSelectedInEditor!public! !
!JadeSystemBrowserPresenter categoriesFor: #isClassSideSelected!accessing!public!request string! !
!JadeSystemBrowserPresenter categoriesFor: #isDictionariesTabSelected!public!testing! !
!JadeSystemBrowserPresenter categoriesFor: #isGlobalsTabSelected!public!testing! !
!JadeSystemBrowserPresenter categoriesFor: #isPackageListTabSelected!public!testing! !
!JadeSystemBrowserPresenter categoriesFor: #isPragmasTabSelected!public!testing! !
!JadeSystemBrowserPresenter categoriesFor: #isTreeModel:equivalentTo:!public! !
!JadeSystemBrowserPresenter categoriesFor: #isVariablesTabSelected!public!testing! !
!JadeSystemBrowserPresenter categoriesFor: #jadeDebug!menu handlers!private! !
!JadeSystemBrowserPresenter categoriesFor: #jadeDisplay!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #jadeExecute!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #jadeExecuteAndDisplay:!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #jadeMenuStrings!menus!public! !
!JadeSystemBrowserPresenter categoriesFor: #jumpToHistoryIndex:!history!public! !
!JadeSystemBrowserPresenter categoriesFor: #labelOfClass:changedTo:!event handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #labelOfClass:editedTo:accept:!event handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #layoutInfo!public! !
!JadeSystemBrowserPresenter categoriesFor: #layoutInfo:!public! !
!JadeSystemBrowserPresenter categoriesFor: #loadLatestVersion!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #methodDoubleClicked:!event handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #methodFilterListPresenter!public!request string! !
!JadeSystemBrowserPresenter categoriesFor: #methodHoverEnd:!event handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #methodHoverStart:!event handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #methodListPresenter!accessing!public! !
!JadeSystemBrowserPresenter categoriesFor: #methodsIdentifier!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #methodSourcePresenter!public!updating! !
!JadeSystemBrowserPresenter categoriesFor: #onDragClassesOverDictionary:!drag & drop!public! !
!JadeSystemBrowserPresenter categoriesFor: #onDragClassesOverPackageList:!drag & drop!public! !
!JadeSystemBrowserPresenter categoriesFor: #onDragClassHierarchy:!drag & drop!public! !
!JadeSystemBrowserPresenter categoriesFor: #onDragClassList:!drag & drop!public! !
!JadeSystemBrowserPresenter categoriesFor: #onDragCutClassHierarchy:!drag & drop!public! !
!JadeSystemBrowserPresenter categoriesFor: #onDragCutClassList:!drag & drop!public! !
!JadeSystemBrowserPresenter categoriesFor: #onDragCutMethod:!drag & drop!public! !
!JadeSystemBrowserPresenter categoriesFor: #onDragMethodsOverClassHierarchy:!drag & drop!public! !
!JadeSystemBrowserPresenter categoriesFor: #onDragMethodsOverClassList:!drag & drop!public! !
!JadeSystemBrowserPresenter categoriesFor: #onDragOverClassCategory:!drag & drop!public! !
!JadeSystemBrowserPresenter categoriesFor: #onDragOverClassHierarchy:!drag & drop!public! !
!JadeSystemBrowserPresenter categoriesFor: #onDragOverClassList:!drag & drop!public! !
!JadeSystemBrowserPresenter categoriesFor: #onDragOverDictionary:!drag & drop!public! !
!JadeSystemBrowserPresenter categoriesFor: #onDragOverMethodCategory:!drag & drop!public! !
!JadeSystemBrowserPresenter categoriesFor: #onDragOverPackageList:!drag & drop!public! !
!JadeSystemBrowserPresenter categoriesFor: #onDropClassesOnDictionary:!drag & drop!public! !
!JadeSystemBrowserPresenter categoriesFor: #onDropClassesOnPackage:session:!drag & drop!public! !
!JadeSystemBrowserPresenter categoriesFor: #onDropClassesOnPackageList:!drag & drop!public! !
!JadeSystemBrowserPresenter categoriesFor: #onDropMethodsOnClass:session:!drag & drop!public! !
!JadeSystemBrowserPresenter categoriesFor: #onDropMethodsOnClassHierarchy:!drag & drop!public! !
!JadeSystemBrowserPresenter categoriesFor: #onDropMethodsOnClassList:!drag & drop!public! !
!JadeSystemBrowserPresenter categoriesFor: #onDropOnClassCategory:!drag & drop!public! !
!JadeSystemBrowserPresenter categoriesFor: #onDropOnClassHierarchy:!drag & drop!public! !
!JadeSystemBrowserPresenter categoriesFor: #onDropOnClassList:!drag & drop!public! !
!JadeSystemBrowserPresenter categoriesFor: #onDropOnDictionary:!drag & drop!public! !
!JadeSystemBrowserPresenter categoriesFor: #onDropOnMethodCategory:!drag & drop!public! !
!JadeSystemBrowserPresenter categoriesFor: #onDropOnPackageList:!drag & drop!public! !
!JadeSystemBrowserPresenter categoriesFor: #onSetFocus:stack:!public! !
!JadeSystemBrowserPresenter categoriesFor: #openSourceStyler!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #packageListPresenter!accessing!public! !
!JadeSystemBrowserPresenter categoriesFor: #parseContext!public! !
!JadeSystemBrowserPresenter categoriesFor: #pkgDictChanged!event handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #pkgsMenuStrings!menus!public! !
!JadeSystemBrowserPresenter categoriesFor: #preferencesMenuStrings!menus!public! !
!JadeSystemBrowserPresenter categoriesFor: #promptForSelector!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #removeClass!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #removeDictionary!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #removeGlobals!public! !
!JadeSystemBrowserPresenter categoriesFor: #removeMethodCategories!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #removePriorVersions!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #removeRepository!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #reportCompileError:!menu handlers support!public! !
!JadeSystemBrowserPresenter categoriesFor: #requestString!public!request string! !
!JadeSystemBrowserPresenter categoriesFor: #requestStringForUpdate!public!request string! !
!JadeSystemBrowserPresenter categoriesFor: #resetColors!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #revertNewClass!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #runMethodTests!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #selectClass:selector:!public! !
!JadeSystemBrowserPresenter categoriesFor: #selectedClassChanged:!public! !
!JadeSystemBrowserPresenter categoriesFor: #selectedClasses!public! !
!JadeSystemBrowserPresenter categoriesFor: #selectedClassName!private! !
!JadeSystemBrowserPresenter categoriesFor: #selectedClassName:!public!updating! !
!JadeSystemBrowserPresenter categoriesFor: #selectedClassNameWithoutVersion!public! !
!JadeSystemBrowserPresenter categoriesFor: #selectedMethodChanged!event handlers!history!public! !
!JadeSystemBrowserPresenter categoriesFor: #selectedMethodName!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #setColorForCompileErrors!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #setColorForNoEdits!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #setColorForUnsavedEdits!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #setEnvironment:!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #setEnvironment0!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #setEnvironment1!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #setEnvironment2!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #setHomeDictionary!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #setSearchPolicy!overrides!public! !
!JadeSystemBrowserPresenter categoriesFor: #showPackageChanges!menu handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #splitterPosition:!public! !
!JadeSystemBrowserPresenter categoriesFor: #statusBarServerRequestText:!public!updating! !
!JadeSystemBrowserPresenter categoriesFor: #statusBarText:!public!updating! !
!JadeSystemBrowserPresenter categoriesFor: #stepPointAt:!event handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #stuffToKeepFromPath:andAddTo:!public! !
!JadeSystemBrowserPresenter categoriesFor: #sunitPresenter!overrides!private! !
!JadeSystemBrowserPresenter categoriesFor: #textTabChanged!event handlers!public! !
!JadeSystemBrowserPresenter categoriesFor: #updateAfterFindClass:isMeta:selector:!public!updating! !
!JadeSystemBrowserPresenter categoriesFor: #updateAndSelect:!public!updating! !
!JadeSystemBrowserPresenter categoriesFor: #updateAndSelectA:!public!updating! !
!JadeSystemBrowserPresenter categoriesFor: #updateAndSelectB:!public!updating! !
!JadeSystemBrowserPresenter categoriesFor: #updateClassCategoryTree!public!updating! !
!JadeSystemBrowserPresenter categoriesFor: #updateClassInfo!public!updating! !
!JadeSystemBrowserPresenter categoriesFor: #updateClassListOrHierarchy!public!updating! !
!JadeSystemBrowserPresenter categoriesFor: #updateCommand:!public!updating! !
!JadeSystemBrowserPresenter categoriesFor: #updateCommand:onSuccessDo:!public!updating! !
!JadeSystemBrowserPresenter categoriesFor: #updateDictionaryList!public!updating! !
!JadeSystemBrowserPresenter categoriesFor: #updateMenuBar!menus!public! !
!JadeSystemBrowserPresenter categoriesFor: #updateMethodFilter!public!updating! !
!JadeSystemBrowserPresenter categoriesFor: #updateMethodList!public!updating! !
!JadeSystemBrowserPresenter categoriesFor: #updateMethodStepPoints!public!updating! !
!JadeSystemBrowserPresenter categoriesFor: #updateOverrideList!public!updating! !
!JadeSystemBrowserPresenter categoriesFor: #updatePackageDictionaryList!public!updating! !
!JadeSystemBrowserPresenter categoriesFor: #updatePackageInfo!public!updating! !
!JadeSystemBrowserPresenter categoriesFor: #updatePackageList!public!updating! !
!JadeSystemBrowserPresenter categoriesFor: #updatePresenters!public!updating! !
!JadeSystemBrowserPresenter categoriesFor: #updateSuperclassList!public!updating! !
!JadeSystemBrowserPresenter categoriesFor: #updateTabLabel!public!updating! !
!JadeSystemBrowserPresenter categoriesFor: #variableListPresenter!accessing!public! !
!JadeSystemBrowserPresenter categoriesFor: #viewActivated!event handlers!public! !

!JadeSystemBrowserPresenter class methodsFor!

overriddenIcon

	^Icon fromId: 'icons\OVERRIDDEN.ICO'.
! !
!JadeSystemBrowserPresenter class categoriesFor: #overriddenIcon!public! !

