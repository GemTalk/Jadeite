"Filed out from Dolphin Smallalk"!

JadePresenterA subclass: #JadeiteComponentPresenter
	instanceVariableNames: 'componentListPresenter packageListPresenter componentPropertyPresenter prePostLoadListPresenter loadSpecPresenter commentPresenter conditionalAttributesPresenter platformPropertiesPresenter prePostLoadSource packageGroupPresenter'
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

componentListPresenter
	^componentListPresenter!

conditionalAttributeItem: new updatedAtIndex: index
	model
		command: #setConditionalAttributes:;
		commandArgs: (Array with: model conditionalAttributes).
	self issueProjectDefinitionCommand!

createComponents
	componentListPresenter := self add: JadeiteTreePresenter new name: 'componentListPresenter'.
	packageListPresenter := self add: ListPresenter new name: 'packageListPresenter'.
	componentPropertyPresenter := self add: JadeitePropertyPresenter new
				name: 'componentPropertyPresenter'.
	prePostLoadListPresenter := self add: ListPresenter new name: 'prePostLoadListPresenter'.
	loadSpecPresenter := self add: ListPresenter new name: 'loadSpecPresenter'.
	commentPresenter := self add: TextPresenter new name: 'commentPresenter'.
	conditionalAttributesPresenter := self add: ListPresenter new name: 'conditionalAttributesPresenter'.
	platformPropertiesPresenter := self add: ListPresenter new name: 'platformPropertiesPresenter'.
	prePostLoadSource := self add: TextPresenter new name: 'prePostLoadSource'.
	packageGroupPresenter := self add: ListPresenter new name: 'packageGroupPresenter'!

createSchematicWiring
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
	loadSpecPresenter model
		when: #item:updatedAtIndex:
		send: #loadSpecItem:updatedAtIndex:
		to: self.
	conditionalAttributesPresenter model
		when: #item:updatedAtIndex:
		send: #conditionalAttributeItem:updatedAtIndex:
		to: self.
	platformPropertiesPresenter model
		when: #item:updatedAtIndex:
		send: #platformPropertyItem:updatedAtIndex:
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
			send: #resetPrePostLoadSource
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
	packageGroupPresenter
		when: #selectionChanged
		send: #displayPackageGroupPackages
		to: self.
	packageGroupPresenter
		when: #drop:
			send: #onDropPackageToPackageGroup:
			to: self;
		when: #dragOver:
			send: #onDragOverPackageGroup:
			to: self;
		when: #dragEnter
			send: #onDragOverPackageGroup:
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
	| assocs |
	assocs := model specService objects
				collect: [:assoc | Array with: assoc key with: assoc value asString].
	assocs := assocs asSortedCollection: [:x :y | x first < y first].
	loadSpecPresenter list: assocs asArray!

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

!

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

exportLoadSpec
	model
		command: #exportLoadSpecification;
		commandArgs: Array new.
	self issueProjectDefinitionCommand!

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
			componentListPresenter selection: componentSelection]!

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

nonNilComponentDefinitionRoots
	^model componentDefinitions keys select: [:def | (def == #nil) not]!

onDragOverComponentTree: dragDropSession
	"this duplication of code with the drag event itself seems necessary as Dolphin not-so-wittingly clears a lot of state from the session at the drag entry event"

	| newDragObjects |
	newDragObjects := packageListPresenter selections
				collect: [:packageName | dragDropSession newDragObject: packageName].
	dragDropSession supportedOperations: #(#move).
	dragDropSession operation: #move.
	dragDropSession dragObjects: newDragObjects.
	dragDropSession dropTarget: componentListPresenter view!

onDragOverPackageGroup: dragDropSession
	!

onDragPackageToComponent: dragDropSession
	| newDragObjects |
	newDragObjects := packageListPresenter selections
				collect: [:packageName | dragDropSession newDragObject: packageName].
	dragDropSession supportedOperations: #(#move).
	dragDropSession operation: #move.
	dragDropSession dragObjects: newDragObjects.
	dragDropSession dropTarget: componentListPresenter view!

onDropPackageToComponent: dragDropSession
	dragDropSession dragObjects
		do: [:dragObject | model movePackageNamed: dragObject object toComponentNamed: dragDropSession suggestedTarget name].
	self displayComponentPackages!

onDropPackageToPackageGroup: dragDropSession
		!

onViewClosed
	super onViewClosed.
	BrowserUpdate current removeEventsTriggeredFor: componentListPresenter.!

onViewOpened
	super onViewOpened.
	self registerPresentersForUpdates.
	self updateService: model.!

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

registerPresentersForUpdates
	BrowserUpdate current
		register: componentListPresenter
		selector: #componentsUpdate:browser:
		browser: self!

removeComponent
	componentListPresenter selections isEmpty
		ifTrue: [^MessageBox notify: 'Select component before removing it'].
	MessageBox confirm: 'Really remove component ' , componentListPresenter selection name.
	model removeComponentNamed: componentListPresenter selection name.
	self resetComponentList.
	self displayComponents!

removeConditionalAttribute
	(MessageBox
		confirm: 'Really remove conditional attribute ''' , conditionalAttributesPresenter selection value
				, '''?')
			ifTrue: 
				[model conditionalAttributes removeAtIndex: conditionalAttributesPresenter selectionByIndex.
				self displayConditionalAttributes.
				self conditionalAttributeItem: nil updatedAtIndex: model conditionalAttributes size]!

renameComponent
	componentListPresenter view editSelectionLabel.!

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
addPostLoadSelector!menu handlers!public! !
addPreLoadSelector!menu handlers!public! !
componentListPresenter!accessing!public! !
conditionalAttributeItem:updatedAtIndex:!event handlers!public! !
createComponents!initialization!public! !
createSchematicWiring!initialization!public! !
displayComponentPackages!displaying!event handlers!public! !
displayComponents!displaying!event handlers!public! !
displayConditionalAttributes!displaying!event handlers!public! !
displayLoadSpecification!displaying!event handlers!public! !
displayPackageGroupPackages!displaying!event handlers!public! !
displayPackageGroups!displaying!event handlers!public! !
displayPrePostLoadSources!displaying!event handlers!public! !
displayTabs!displaying!event handlers!public! !
exportLoadSpec!menu handlers!public! !
exportProjectDefinition!menu handlers!public! !
initialize!initialization!public! !
isClassSelected!public!testing! !
isOkayToChange!event handlers!public! !
issueProjectDefinitionCommand!private! !
labelOf:editedTo:accept:!event handlers!public! !
loadSpecItem:updatedAtIndex:!event handlers!public! !
nonNilComponentDefinitionRoots!private! !
onDragOverComponentTree:!drag & drop!public! !
onDragOverPackageGroup:!drag & drop!public! !
onDragPackageToComponent:!drag & drop!event handlers!public! !
onDropPackageToComponent:!drag & drop!event handlers!public! !
onDropPackageToPackageGroup:!drag & drop!public! !
onViewClosed!event handlers!public! !
onViewOpened!event handlers!public! !
platformPropertyItem:updatedAtIndex:!event handlers!public! !
prePostLoadChanged!event handlers!public! !
projectDefinitionService!accessing!public! !
projectListPresenter!accessing!public! !
registerPresentersForUpdates!public!register presenters! !
removeComponent!menu handlers!public! !
removeConditionalAttribute!menu handlers!public! !
renameComponent!menu handlers!public! !
resetComponentList!initialization!public! !
resetPrePostLoadSource!event handlers!public! !
updatePrePostSource!event handlers!public! !
!

!JadeiteComponentPresenter class methodsFor!

resource_Component_Properties_View
	"Answer the literal data from which the 'Component Properties View' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Component_Properties_View)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil 327686 ##(Smalltalk.Color) #default nil 5 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 576 nil nil nil 5 nil nil nil 576 514 170 176 34 2 410 ##(Smalltalk.EditableListView) 34 55 nil 576 34 2 8 1140920397 1025 688 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 496 nil 5 nil nil nil 688 nil 8 1714874480 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil 328198 ##(Smalltalk.Point) 65 65 nil nil 138 144 34 2 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Property' 647 #left 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 106 8 'Dolphin List Presenter' 8 'BasicListAbstract' 8 'doIt' 8 '[:componentService | componentService key ]' 8 #[30 105 226 0 106] #key 1024 7 257 nil ##(Smalltalk.SortedCollection) nil nil 688 nil 3 nil nil true nil nil nil nil nil nil nil nil nil nil 962 8 'Value' 647 #left 1010 0 nil 1042 1 83886081 1008 8 'doIt' 8 '[:componentService | componentService value]' 8 #[29 105 17 142 106] 1200 7 257 nil 459270 ##(Smalltalk.Message) #<= 8 #() nil nil 688 nil 3 nil nil true nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 1344 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 496 nil 5 nil nil nil 1344 nil nil nil 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 898 1 1 898 1301 349 688 1522 #text: 34 1 8 'Property' 688 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 138 2 0 0 174 0 0 0] 8 #() 898 193 193 nil 33 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 1762 #fixedParentRight 1 1762 #fixedParentTop 1 1762 #fixedParentBottom 1 170 192 34 2 688 8 'propertyPresenter' nil 1458 138 144 34 1 1522 #createAt:extent: 34 2 898 1 1 898 1301 349 576 1650 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 138 2 0 0 174 0 0 0] 34 1 688 1712 nil 27 1730 1776 1 1792 1 1808 1 1762 #relativeParentHeight 327734 ##(Smalltalk.Float) 8 154 153 153 153 153 153 217 63 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 2112 nil nil nil 5 nil nil nil 2112 514 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 2112 34 2 8 1409286144 131073 2224 nil 496 nil 5 nil nil nil 2224 656710 1 ##(Smalltalk.CardLayout) 138 144 34 1 721414 ##(Smalltalk.Association) 8 'Comment' 410 ##(Smalltalk.TextEdit) 34 16 nil 2224 34 2 8 1140916352 1025 2400 nil 496 nil 5 nil nil nil 2400 nil 8 1714822656 852486 ##(Smalltalk.NullConverter) nil nil 1 1458 138 144 34 1 1522 #createAt:extent: 34 2 898 9 53 898 1285 463 2400 1650 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 134 2 0 0 1 1 0 0] 8 #() 1712 nil 27 2400 nil nil nil 170 192 34 2 2400 8 'commentText' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 2224 34 2 8 1140916736 1 2720 754 138 144 34 1 2384 nil 832 nil nil 1 nil nil nil 2720 nil 8 1715211760 1010 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 2848 7 257 nil 1010 0 nil 2866 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 2912 7 257 nil 880 nil nil nil nil nil #noIcons nil nil nil nil nil 1458 138 144 34 3 1522 #createAt:extent: 34 2 898 1 1 898 1301 523 2720 1522 #setSingleSelection: 8 #(1) 2720 1522 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 2720 1650 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 138 2 0 0 5 1 0 0] 8 #() 1712 nil 27 1458 138 144 34 2 1522 #createAt:extent: 34 2 898 1 1 898 1301 523 2224 1522 #text: 34 1 8 'commentTab' 2224 1650 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 138 2 0 0 5 1 0 0] 34 2 2400 2720 1712 nil 27 1730 1776 1 1792 1 1808 1 1824 1 170 192 800 nil 1458 138 144 34 1 1522 #createAt:extent: 34 2 898 1 349 898 1301 523 2112 1650 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 174 0 0 0 138 2 0 0 179 1 0 0] 34 1 2224 1712 nil 27 1730 1776 1 1792 1 2064 2082 8 154 153 153 153 153 153 217 63 1824 1 170 192 800 nil 1458 138 144 34 1 1522 #createAt:extent: 34 2 898 6837 21 898 1301 871 416 1650 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 90 13 0 0 10 0 0 0 228 15 0 0 189 1 0 0] 34 2 576 2112 1712 nil 27 )! !
!JadeiteComponentPresenter class categoriesForMethods!
resource_Component_Properties_View!public!resources-views! !
!

