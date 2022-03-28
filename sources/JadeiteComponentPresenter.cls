"Filed out from Dolphin Smallalk"!

JadePresenterA subclass: #JadeiteComponentPresenter
	instanceVariableNames: 'componentListPresenter packageListPresenter componentPropertyPresenter prePostLoadListPresenter commentPresenter conditionalAttributesPresenter platformPropertiesPresenter prePostLoadSource'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteComponentPresenter guid: (GUID fromString: '{f837143a-a8e6-4980-aed2-4c0f6a719061}')!
JadeiteComponentPresenter comment: ''!
!JadeiteComponentPresenter categoriesForClass!Unclassified! !
!JadeiteComponentPresenter methodsFor!

addComponent
	| componentName |
	componentName := Prompter prompt: 'Please enter a component name ...' caption: 'Add Component'.
	componentName ifNil: [^self].
	componentListPresenter selectionOrNil
		ifNil: [model addComponentNamed: componentName]
		ifNotNil: [:sel | model addSubcomponentNamed: componentName toComponentNamed: sel name].
	self displayComponents.
	componentListPresenter selection: (componentListPresenter model asBag
				detect: [:componentDefinitionService | componentDefinitionService name = componentName])!

addConditionalAttribute
	| attribute |
	attribute := Prompter prompt: 'Please enter new conditional attribute ...'
				caption: 'Add Conditional Attribute'.
	model conditionalAttributes add: attribute.
	self displayConditionalAttributes.
	conditionalAttributesPresenter selectionByIndex: model conditionalAttributes size.
	self conditionalAttributeItem: attribute updatedAtIndex: model conditionalAttributes size!

addPackage
	| packageName |
	componentListPresenter selectionOrNil ifNil: [^MessageBox notify: 'Please select a component'].
	packageName := Prompter prompt: 'Please enter a package name ...'
				caption: 'Add Package to ' , componentListPresenter selection name.
	packageName ifNil: [^self].
	model addPackageNamed: packageName toComponentNamed: componentListPresenter selection name.
	self displayComponentPackages.
	packageListPresenter selection: (packageListPresenter list detect: [:name | name = packageName])!

addPackageGroup
	| packageGroupName |
	packageGroupName := Prompter prompt: 'Please enter a package group name ...'
				caption: 'Add Package Group to ' , componentListPresenter selection name.
	packageGroupName ifNil: [^self]!

addPostLoadSelector
	| selector |
	selector := (Prompter prompt: 'Enter postLoad selector' caption: 'Enter PostLoad Selector')
				ifNil: [^self].
	model
		command: #addPostloadDoitName:withSource:toComponentNamed:;
		commandArgs: (Array
					with: selector
					with: '[tempSource]'
					with: componentListPresenter selection name).
	self issueProjectDefinitionCommand.
	self displayPrePostLoadSources!

addPreLoadSelector
	| selector |
	selector := (Prompter prompt: 'Enter preLoad selector' caption: 'Enter PreLoad Selector')
				ifNil: [^self].
	model
		command: #addPreloadDoitName:withSource:toComponentNamed:;
		commandArgs: (Array
					with: selector
					with: '[tempSource]'
					with: componentListPresenter selection name).
	self issueProjectDefinitionCommand.
	self displayPrePostLoadSources!

commentChanged
	model comment: commentPresenter value!

componentListPresenter
	^componentListPresenter!

componentSelectionChanged
	self resetPrePostLoadSource!

conditionalAttributeItem: new updatedAtIndex: index
	model
		command: #setConditionalAttributes:;
		commandArgs: (Array with: model conditionalAttributes).
	self issueProjectDefinitionCommand!

createComponents
	super createComponents.
	componentListPresenter := self add: JadeiteTreePresenter new name: 'componentListPresenter'.
	packageListPresenter := self add: ListPresenter new name: 'packageListPresenter'.
	componentPropertyPresenter := self add: JadeitePropertyPresenter new
				name: 'componentPropertyPresenter'.
	prePostLoadListPresenter := self add: ListPresenter new name: 'prePostLoadListPresenter'.
	commentPresenter := self add: TextPresenter new name: 'commentPresenter'.
	conditionalAttributesPresenter := self add: ListPresenter new name: 'conditionalAttributesPresenter'.
	platformPropertiesPresenter := self add: ListPresenter new name: 'platformPropertiesPresenter'.
	prePostLoadSource := self add: TextPresenter new name: 'prePostLoadSource'!

createSchematicWiring
	commentPresenter
		when: #valueChanged
		send: #commentChanged
		to: self.
	componentListPresenter
		when: #labelOf:editedTo:accept:
		send: #labelOf:editedTo:accept:
		to: self.
	componentListPresenter
		when: #selectionChanged
		send: #displayComponentPackages
		to: self.
	componentListPresenter
		when: #selectionChanged
		send: #displayPrePostLoadSources
		to: self.
	componentListPresenter
		when: #drop:
			send: #onDropPackageToComponent:
			to: self;
		when: #dragOver:
			send: #onDragOverComponentTree:
			to: self;
		when: #dragEnter
			send: #onDragOverComponentTree:
			to: self;
		when: #selectionChanging:
			send: #isOkayToChange
			to: self;
		when: #selectionChanged
			send: #componentSelectionChanged
			to: self.
	packageListPresenter
		when: #drag:
		send: #onDragPackageToComponent:
		to: self.
	prePostLoadListPresenter
		when: #selectionChanged
		send: #updatePrePostSource
		to: self.
	prePostLoadListPresenter model
		when: #item:updatedAtIndex:
		send: #prePostLoadChanged
		to: self.
	prePostLoadSource
		when: #focusLost
		send: #prePostLoadChanged
		to: self.
	packageListPresenter
		when: #labelOf:editedTo:accept:
		send: #packageLabelOf:editedTo:accept:
		to: self!

displayComponentPackages
	| packageNames |
	componentListPresenter selections isEmpty ifTrue: [^self].
	packageListPresenter clear.
	packageNames := SortedCollection new.
	componentListPresenter selections do: 
			[:componentDefinitionService |
			componentDefinitionService
				command: #packageNames;
				projectDefinitionService: model.
			self issueCommand: componentDefinitionService.
			packageNames addAll: componentDefinitionService packageNames].
	packageListPresenter list: packageNames!

displayComponents

	| treeModel |
	treeModel := componentListPresenter model.
	model componentDefinitions keysAndValuesDo: 
			[:parent :children |
			| parentDefinitionService |
			parent == #nil
				ifTrue: [parentDefinitionService := nil]
				ifFalse: 
					[parentDefinitionService := treeModel asBag
								detect: [:definitionService | definitionService name = parent name]
								ifNone: [nil]].
			children do: 
					[:child |
					| componentDefinitionService |
					componentDefinitionService := RowanComponentDefinitionService new
								name: child name;
								projectDefinitionService: model.
					treeModel add: componentDefinitionService asChildOf: parentDefinitionService]].
	componentListPresenter view expandAll!

displayConditionalAttributes
	conditionalAttributesPresenter
		list: (model conditionalAttributes collect: [:attribute | model conditionalAttributes -> attribute])!

displayLoadSpecification
	"| assocs |
	assocs := model specService objects
				collect: [:assoc | Array with: assoc key with: assoc value asString].
	assocs := assocs asSortedCollection: [:x :y | x first < y first].
	loadSpecPresenter list: assocs asArray"!

displayPrePostLoadSources
	| list |
	componentListPresenter selectionOrNil
		ifNotNil: 
			[list := OrderedCollection new.
			list add: (OrderedCollection with: #preloadDoitName
						with: (componentListPresenter selection preloadDoitName ifNotNil: [:nm | nm key])).
			list add: (OrderedCollection with: #postloadDoitName
						with: (componentListPresenter selection postloadDoitName ifNotNil: [:nm | nm key])).
			prePostLoadListPresenter list: list]!

displayTabs
	| propertiesArray |
	commentPresenter value: model comment.
	self displayConditionalAttributes.
	propertiesArray := OrderedCollection new.
	model platformProperties keysAndValuesDo: [:key :value | propertiesArray add: key -> value].
	platformPropertiesPresenter list: propertiesArray!

editLoadSpec
	^JadeiteLoadSpecEditor editLoadSpecFromOop: model specService loadSpecOop session: gciSession!

exportProjectDefinition
	model
		command: #export;
		commandArgs: Array new.
	self issueProjectDefinitionCommand!

initialize
	super initialize. 
	self resetComponentList.!

isClassSelected
	"no classes in component browser" 
	^false!

isOkayToChange
	prePostLoadSource view isModified
		ifTrue: [(JadePresenter unsavedChangesValidSessionDialogIn: self topShell) ifTrue: [^false]].
	^true!

issueProjectDefinitionCommand
	| componentSelection |
	self issueCommand: model.
	componentListPresenter selectionOrNil
		ifNotNil: 
			[componentSelection := componentListPresenter selection.
			self nonNilComponentDefinitionRoots do: 
					[:new |
					| old |
					old := componentListPresenter model asBag detect: [:oldDef | oldDef name = new name] ifNone: [].
					old ifNotNil: [old replicateFrom: new]].
			componentListPresenter selection: componentSelection ifAbsent:[]]!

labelOf: componentService editedTo: value accept: accept
	value isEmpty ifTrue: [^self].
	componentService name = value ifTrue: [^self].
	self projectDefinitionService
		command: #renameComponent:to:;
		commandArgs: (Array with: componentService name with: value).
	self issueProjectDefinitionCommand.
	componentService name: value.
	accept value: true!

loadSpecItem: specPropertyArray updatedAtIndex: index
	model
		command: #setLoadSpecProperty:to:;
		commandArgs: (Array with: specPropertyArray first with: specPropertyArray last).
	self issueProjectDefinitionCommand!

model: projectDefinitionService
	super model: projectDefinitionService.
	projectDefinitionService packageGroups do: 
			[:packageGroup | 
			packageGroup
				projectDefinitionService: projectDefinitionService;
				session: projectDefinitionService session]!

nonNilComponentDefinitionRoots
	^model componentDefinitions keys select: [:def | (def == #nil) not]!

onDragOverComponentTree: dragDropSession
	"this duplication of code with the drag event itself seems necessary as Dolphin not-so-wittingly clears a lot of state from the session at the drag entry event"

	| newDragObjects |
	newDragObjects := packageListPresenter selections
				collect: [:packageName | dragDropSession newDragObject: packageName].
	dragDropSession supportedOperations: #(#move).
	dragDropSession operation: #move.
	dragDropSession dragObjects: newDragObjects.!

onDragPackageToComponent: dragDropSession
	| newDragObjects |
	newDragObjects := packageListPresenter selections
				collect: [:packageName | dragDropSession newDragObject: packageName].
	dragDropSession supportedOperations: #(#move).
	dragDropSession operation: #move.
	dragDropSession dragObjects: newDragObjects.!

onDropPackageToComponent: dragDropSession
	| componentName componentToSelect packageNames |
	componentName := dragDropSession suggestedTarget name.
	dragDropSession dragObjects
		do: [:dragObject | model movePackageNamed: dragObject object toComponentNamed: componentName].
	componentToSelect := componentListPresenter model asBag
				detect: [:componentService | componentService name = componentName].
	componentListPresenter selection: componentToSelect.
	packageNames := dragDropSession dragObjects collect: [:obj | packageListPresenter list detect:[:pkgName | pkgName = obj object]].
	packageListPresenter selections: packageNames asArray!

onViewClosed
	super onViewClosed.
	BrowserUpdate current removeEventsTriggeredFor: componentListPresenter.!

onViewOpened
	super onViewOpened.
	self registerPresentersForUpdates.
	self updateService: model.!

packageLabelOf: packageName editedTo: value accept: accept
	packageName = value ifTrue: [^self].
	model renamePackage: packageName to: value.
	componentListPresenter selections isEmpty
		ifTrue: [self displayPackageGroupPackages]
		ifFalse: [self displayComponentPackages].
	accept value: true. 
!

platformPropertyItem: association updatedAtIndex: value
	model
		command: #setPlatformProperty:to:;
		commandArgs: (Array with: association key with: value).
	self issueProjectDefinitionCommand!

prePostLoadChanged
	| command |
	prePostLoadListPresenter selectionOrNil ifNil: [^self].
	prePostLoadListPresenter selection last ifNil: [^self].
	prePostLoadListPresenter selection first = #preloadDoitName
		ifTrue: 
			[command := #addPreloadDoitName:withSource:toComponentNamed:.
			componentListPresenter selection
				preloadDoitName: prePostLoadListPresenter selection last -> prePostLoadSource value]
		ifFalse: 
			[command := #addPostloadDoitName:withSource:toComponentNamed:.
			componentListPresenter selection
				postloadDoitName: prePostLoadListPresenter selection last -> prePostLoadSource value].
	model
		command: command;
		commandArgs: (Array
					with: prePostLoadListPresenter selection last
					with: prePostLoadSource value
					with: componentListPresenter selection name).
	self issueProjectDefinitionCommand.
	self displayPrePostLoadSources!

projectDefinitionService
	^model!

projectListPresenter

	^nil!

queryCommand: query
	query command = #removePackagesFromProjectDefinition
		ifTrue: 
			[query isEnabled: componentListPresenter selections notEmpty.
			^true].
	^super queryCommand: query!

registerPresentersForUpdates
	BrowserUpdate current
		register: componentListPresenter
		selector: #componentsUpdate:browser:
		browser: self!

removeComponent
	componentListPresenter selections isEmpty
		ifTrue: [^MessageBox notify: 'Select component before removing it'].
	(MessageBox confirm: 'Really remove component ' , componentListPresenter selection name)
		ifTrue: 
			[model removeComponentNamed: componentListPresenter selection name.
			self resetComponentList.
			self displayComponents]!

removeConditionalAttribute
	(MessageBox
		confirm: 'Really remove conditional attribute ''' , conditionalAttributesPresenter selection value
				, '''?')
			ifTrue: 
				[model conditionalAttributes removeAtIndex: conditionalAttributesPresenter selectionByIndex.
				self displayConditionalAttributes.
				self conditionalAttributeItem: nil updatedAtIndex: model conditionalAttributes size]!

removePackagesFromProjectDefinition
	packageListPresenter selections isEmpty ifTrue: [^self].
	(MessageBox
		confirm: 'Really remove ' , packageListPresenter selections printString , ' from project definition?')
			ifFalse: [^self].
	model removePackagesFromProjectDefinition: packageListPresenter selections.
	self displayComponentPackages!

renameComponent
	componentListPresenter view editSelectionLabel.!

renamePackage
	| result |
	result := packageListPresenter view editSelectionLabel.
	Transcript cr; show: result printString. !

resetComponentList
	componentListPresenter model: (JadeiteTreeModel new
				searchPolicy: SearchPolicy equality;
				reset)!

resetPrePostLoadSource
	prePostLoadSource value: String new.
	prePostLoadSource view
		isModified: false;
		isReadOnly: true!

updatePrePostSource
	componentListPresenter selectionOrNil ifNil:[^self]. 
	prePostLoadListPresenter selectionOrNil
		ifNotNil: 
			[:selection |
			| loadAssoc |
			prePostLoadSource view isReadOnly: false. 
			loadAssoc := componentListPresenter selection perform: selection first.
			prePostLoadSource value: (loadAssoc ifNotNil: [loadAssoc value])]! !
!JadeiteComponentPresenter categoriesForMethods!
addComponent!menu handlers!public! !
addConditionalAttribute!menu handlers!public! !
addPackage!menu handlers!public! !
addPackageGroup!menu handlers!public! !
addPostLoadSelector!menu handlers!public! !
addPreLoadSelector!menu handlers!public! !
commentChanged!event handlers!public! !
componentListPresenter!accessing!public! !
componentSelectionChanged!event handlers!public! !
conditionalAttributeItem:updatedAtIndex:!event handlers!public! !
createComponents!initialization!public! !
createSchematicWiring!initialization!public! !
displayComponentPackages!displaying!public! !
displayComponents!displaying!public! !
displayConditionalAttributes!displaying!public! !
displayLoadSpecification!displaying!public! !
displayPrePostLoadSources!displaying!public! !
displayTabs!displaying!event handlers!public! !
editLoadSpec!menu handlers!public! !
exportProjectDefinition!menu handlers!public! !
initialize!initialization!public! !
isClassSelected!public!testing! !
isOkayToChange!event handlers!public! !
issueProjectDefinitionCommand!private! !
labelOf:editedTo:accept:!event handlers!public! !
loadSpecItem:updatedAtIndex:!event handlers!public! !
model:!accessing!public! !
nonNilComponentDefinitionRoots!private! !
onDragOverComponentTree:!drag & drop!public! !
onDragPackageToComponent:!drag & drop!event handlers!public! !
onDropPackageToComponent:!drag & drop!event handlers!public! !
onViewClosed!event handlers!public! !
onViewOpened!event handlers!public! !
packageLabelOf:editedTo:accept:!event handlers!public! !
platformPropertyItem:updatedAtIndex:!event handlers!public! !
prePostLoadChanged!event handlers!public! !
projectDefinitionService!accessing!public! !
projectListPresenter!accessing!public! !
queryCommand:!menu handlers!public! !
registerPresentersForUpdates!public!register presenters! !
removeComponent!menu handlers!public! !
removeConditionalAttribute!menu handlers!public! !
removePackagesFromProjectDefinition!menu handlers!public! !
renameComponent!menu handlers!public! !
renamePackage!menu handlers!public! !
resetComponentList!initialization!public! !
resetPrePostLoadSource!event handlers!public! !
updatePrePostSource!event handlers!public! !
!

