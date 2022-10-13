"Filed out from Dolphin Smallalk"!

JadePresenterA subclass: #JadeitePackageGroupPresenter
	instanceVariableNames: 'packageListPresenter packageGroupPresenter'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeitePackageGroupPresenter guid: (GUID fromString: '{a8ef4299-16a9-4791-bda9-39604e2b4a96}')!
JadeitePackageGroupPresenter comment: ''!
!JadeitePackageGroupPresenter categoriesForClass!Unclassified! !
!JadeitePackageGroupPresenter methodsFor!

addNewPackageToPackageGroup
	| packageName |
	packageGroupPresenter selectionOrNil ifNil: [^MessageBox notify: 'Must select a package group'].
	packageName := Prompter prompt: 'Please enter a package name ...'
				caption: 'Add Package to ' , packageGroupPresenter selection name.
	packageName ifNil: [^self].
	model addPackagesNamed: (Array with: packageName)
		toPackageGroup: packageGroupPresenter selections first name.
	self displayPackageGroupPackages!

createComponents
	super createComponents. 
	packageListPresenter := self add: ListPresenter new name: 'packageListPresenter'.
	packageGroupPresenter := self add: ListPresenter new name: 'packageGroupPresenter'!

createSchematicWiring
	super createSchematicWiring.
	packageGroupPresenter
		when: #selectionChanged
			send: #packageGroupSelectionChanged
			to: self;
		when: #drop:
			send: #onDropPackageToPackageGroup:
			to: self;
		when: #dragOver:
			send: #onDragOverPackageGroup:
			to: self;
		when: #dragEnter
			send: #onDragOverPackageGroup:
			to: self.
	packageListPresenter
		when: #labelOf:editedTo:accept:
		send: #packageLabelOf:editedTo:accept:
		to: self!

displayPackageGroupPackages
	| packageNames |
	packageGroupPresenter selections isEmpty ifTrue: [^self].
	packageListPresenter clear.
	packageNames := SortedCollection new.
	packageGroupPresenter selections do: 
			[:packageGroupService |
			packageGroupService
				command: #packageNames;
				projectDefinitionService: model.
			self issueCommand: packageGroupService.
			packageNames addAll: packageGroupService packageNames].
	packageListPresenter list: packageNames!

displayPackageGroups
	packageGroupPresenter list: model packageGroups!

export
	model export!

load!

onDragOverPackageGroup: dragDropSession
		| newDragObjects |
	newDragObjects := packageListPresenter selections
				collect: [:packageName | dragDropSession newDragObject: packageName].
	dragDropSession supportedOperations: #(#copy).
	dragDropSession operation: #copy.
	dragDropSession dragObjects: newDragObjects.!

onDragPackageToComponent: dragDropSession
	| newDragObjects |
	newDragObjects := packageListPresenter selections
				collect: [:packageName | dragDropSession newDragObject: packageName].
	dragDropSession supportedOperations: #(#move).
	dragDropSession operation: #move.
	dragDropSession dragObjects: newDragObjects.!

onDropPackageToComponent: dragDropSession
	dragDropSession dragObjects
		do: [:dragObject | model movePackageNamed: dragObject object toComponentNamed: dragDropSession suggestedTarget name].
	self displayPackageGroupPackages!

onDropPackageToPackageGroup: dragDropSession
	model addPackagesNamed: (dragDropSession dragObjects collect: [:ea | ea object])
		toPackageGroup: dragDropSession suggestedTarget name.
	packageGroupPresenter selection: dragDropSession suggestedTarget.
	self displayPackageGroupPackages!

onViewClosed
	super onViewClosed.
	BrowserUpdate current removeEventsTriggeredFor: packageGroupPresenter.!

packageGroupPresenter
	^packageGroupPresenter!

packageGroupSelectionChanged
	self displayPackageGroupPackages!

queryCommand: query
	query command = #removePackageFromPackageGroup
		ifTrue: 
			[query isEnabled: packageGroupPresenter selections size = 1.
			^true].
	^super queryCommand: query!

removePackageFromPackageGroup
	packageGroupPresenter selections size = 1
		ifFalse: [^MessageBox notify: 'Must have only one package group selected'].
	(MessageBox
		confirm: 'Really remove ' , packageListPresenter selections printString , ' from package group '
				, packageListPresenter selection , '?')
			ifFalse: [^self].
	model removePackagesNamed: packageListPresenter selections
		fromPackageGroupNamed: packageGroupPresenter selection name.
	self displayPackageGroupPackages!

removePackageGroups
	(MessageBox confirm: 'Really remove package group(s)?' , '''?')
		ifTrue: 
			[model removePackageGroupsNamed: packageGroupPresenter selections.
			self displayPackageGroups]! !
!JadeitePackageGroupPresenter categoriesForMethods!
addNewPackageToPackageGroup!menu handlers!public! !
createComponents!initialization!public! !
createSchematicWiring!initialization!public! !
displayPackageGroupPackages!displaying!public! !
displayPackageGroups!displaying!public! !
export!public! !
load!public! !
onDragOverPackageGroup:!drag & drop!public! !
onDragPackageToComponent:!drag & drop!event handlers!public! !
onDropPackageToComponent:!drag & drop!event handlers!public! !
onDropPackageToPackageGroup:!drag & drop!public! !
onViewClosed!event handlers!public! !
packageGroupPresenter!accessing!private! !
packageGroupSelectionChanged!event handlers!public! !
queryCommand:!menu handlers!public! !
removePackageFromPackageGroup!menu handlers!public! !
removePackageGroups!menu handlers!public! !
!

