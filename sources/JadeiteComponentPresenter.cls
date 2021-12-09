"Filed out from Dolphin Smalltalk 7"!

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
		send: #updateComponentPackages
		to: self!

initialize
	super initialize. 
	self resetComponentList
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
	self registerPresentersForUpdates.!

projectListPresenter

	^nil!

registerPresentersForUpdates
	BrowserUpdate current
		register: componentListPresenter
			selector: #componentsUpdate:browser:
			browser: self;
		register: packageListPresenter
			selector: #componentPackagesUpdate:browser:
			browser: self!

renameComponent
	componentListPresenter view editSelectionLabel!

resetComponentList
	componentListPresenter model: (JadeiteTreeModel new
				searchPolicy: SearchPolicy equality;
				reset)!

updateComponentPackages
	packageListPresenter clear.
	componentListPresenter selections isEmpty ifTrue: [^self].
	self updateServices: componentListPresenter selections.
	packageListPresenter selections: packageListPresenter list.
	self updateServices: packageListPresenter selections! !
!JadeiteComponentPresenter categoriesFor: #componentListPresenter!accessing!public! !
!JadeiteComponentPresenter categoriesFor: #createComponents!initialization!public! !
!JadeiteComponentPresenter categoriesFor: #createSchematicWiring!initialization!public! !
!JadeiteComponentPresenter categoriesFor: #initialize!initialization!public! !
!JadeiteComponentPresenter categoriesFor: #isClassSelected!public!testing! !
!JadeiteComponentPresenter categoriesFor: #labelOf:changedTo:!event handlers!public! !
!JadeiteComponentPresenter categoriesFor: #labelOfClass:editedTo:accept:!event handlers!public! !
!JadeiteComponentPresenter categoriesFor: #onViewClosed!event handlers!public! !
!JadeiteComponentPresenter categoriesFor: #onViewOpened!event handlers!public! !
!JadeiteComponentPresenter categoriesFor: #projectListPresenter!accessing!public! !
!JadeiteComponentPresenter categoriesFor: #registerPresentersForUpdates!public!register presenters! !
!JadeiteComponentPresenter categoriesFor: #renameComponent!menu handlers!public! !
!JadeiteComponentPresenter categoriesFor: #resetComponentList!initialization!public! !
!JadeiteComponentPresenter categoriesFor: #updateComponentPackages!public!updating! !

