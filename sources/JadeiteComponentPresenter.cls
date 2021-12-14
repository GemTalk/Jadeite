"Filed out from Dolphin Smallalk"!

JadePresenterA subclass: #JadeiteComponentPresenter
	instanceVariableNames: 'componentListPresenter componentPropertyPresenter packageListPresenter'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteComponentPresenter guid: (GUID fromString: '{f837143a-a8e6-4980-aed2-4c0f6a719061}')!
JadeiteComponentPresenter comment: ''!
!JadeiteComponentPresenter categoriesForClass!Unclassified! !
!JadeiteComponentPresenter methodsFor!

componentListPresenter
	^componentListPresenter!

createComponents
	componentListPresenter := self add: JadeiteTreePresenter new name: 'componentListPresenter'.
	componentPropertyPresenter := self add: ListPresenter new name: 'componentPropertyPresenter'.
	packageListPresenter := self add: ListPresenter new name: 'packageListPresenter'!

createSchematicWiring
	componentListPresenter
		when: #labelOf:editedTo:accept:
		send: #labelOfClass:editedTo:accept:
		to: self.
	componentListPresenter
		when: #labelOf:changedTo:
		send: #labelOf:changedTo:
		to: self.
	componentListPresenter
		when: #selectionChanged
		send: #displayPackages
		to: self!

displayComponents
	"The fake dictionary will be replaced by an argument to the method with the actual hierarchy from the server"

	| treeModel fakeHierarchy flattenedHierarchy |
	fakeHierarchy := Dictionary new.
	fakeHierarchy at: #nil put: #('Component').
	fakeHierarchy at: 'Component' put: #('SubComponent1' 'SubComponent2').
	flattenedHierarchy := fakeHierarchy.	"flattenedHierarchy will become the argument"
	treeModel := componentListPresenter model.
	flattenedHierarchy keysAndValuesDo: 
			[:parent :children |
			| theParent |
			theParent := parent == #nil ifTrue: [nil] ifFalse: [parent].
			children do: [:child | treeModel add: child asChildOf: theParent]].
	componentListPresenter view  expandAll.!

displayPackages
	| packageNames |
	componentListPresenter selections isEmpty ifTrue: [^self].
	packageListPresenter clear.
	packageNames := SortedCollection new.
	componentListPresenter selections do: 
			[:componentName |
			| componentService |
			componentService := RowanComponentDefinitionService new
						name: componentName; 
						projectDefinitionService: model.
			componentService command: #packageNames.
			self issueCommand: componentService.
			packageNames addAll: componentService packageNames].
	packageListPresenter list addAll: packageNames!

initialize
	super initialize. 
	self resetComponentList.
	!

isClassSelected
	"no classes in component browser" 
	^false!

labelOf: object changedTo: value
	componentListPresenter view update.
	self rowanFixMe	"write the change to the server"!

labelOfClass: componentService editedTo: value accept: accept
	value isEmpty
		ifFalse: 
			[componentService name: value.
			accept value: true]!

onViewClosed
	super onViewClosed.
	BrowserUpdate current removeEventsTriggeredFor: componentListPresenter.!

onViewOpened
	super onViewOpened.
	self displayComponents.!

projectListPresenter

	^nil!

renameComponent
	componentListPresenter view editSelectionLabel!

resetComponentList
	componentListPresenter model: (JadeiteTreeModel new
				searchPolicy: SearchPolicy equality;
				reset)! !
!JadeiteComponentPresenter categoriesForMethods!
componentListPresenter!accessing!public! !
createComponents!initialization!public! !
createSchematicWiring!initialization!public! !
displayComponents!displaying!public! !
displayPackages!displaying!public! !
initialize!initialization!public! !
isClassSelected!public!testing! !
labelOf:changedTo:!event handlers!public! !
labelOfClass:editedTo:accept:!event handlers!public! !
onViewClosed!event handlers!public! !
onViewOpened!event handlers!public! !
projectListPresenter!accessing!public! !
renameComponent!menu handlers!public! !
resetComponentList!initialization!public! !
!

