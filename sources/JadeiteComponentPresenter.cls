"Filed out from Dolphin Smalltalk 7"!

JadePresenterA subclass: #JadeiteComponentPresenter
	instanceVariableNames: 'projectListPresenter componentListPresenter componentPropertyPresenter packageListPresenter'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteComponentPresenter guid: (GUID fromString: '{f837143a-a8e6-4980-aed2-4c0f6a719061}')!
JadeiteComponentPresenter comment: ''!
!JadeiteComponentPresenter categoriesForClass!Unclassified! !
!JadeiteComponentPresenter methodsFor!

addNoneProject

	"we don't add the (NONE) project in the component editor"!

componentListPresenter
	^componentListPresenter!

createComponents
	componentListPresenter := self add: JadeiteTreePresenter new name: 'componentListPresenter'.
	componentPropertyPresenter := self add: ListPresenter new name: 'componentPropertyPresenter'.
	projectListPresenter := self add: ListPresenter new name: 'projectListPresenter'.
	packageListPresenter := self add: ListPresenter new name: 'packageListPresenter'!

createSchematicWiring
	projectListPresenter
		when: #selectionChanged
		send: #updateProject
		to: self.
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

hasMethods
	^false!

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
	BrowserUpdate current removeEventsTriggeredFor: componentListPresenter.
	BrowserUpdate current removeEventsTriggeredFor: projectListPresenter!

onViewOpened
	super onViewOpened.
	self registerPresentersForUpdates.
	self updateProjects!

possiblyClearProjectInfoTab

	"No project info tab" !

projectListPresenter
	^projectListPresenter!

projectListPresenter: anObject
	projectListPresenter := anObject!

registerPresentersForUpdates
	BrowserUpdate current
		register: componentListPresenter
			selector: #componentsUpdate:browser:
			browser: self;
		register: projectListPresenter selector: #projectsUpdate:;
		register: projectListPresenter
			selector: #projectsUpdate:browser:
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
	self updateServices: packageListPresenter selections!

updateProject
	self updateService: (projectListPresenter selectionIfNone: [^self])!

updateProjectPackages

	"no packages to update yet"!

updateProjects
	| browserService |
	browserService := RowanBrowserService new.
	browserService command: #updateProjects.
	self issueCommand: browserService! !
!JadeiteComponentPresenter categoriesFor: #addNoneProject!public!updating! !
!JadeiteComponentPresenter categoriesFor: #componentListPresenter!accessing!public! !
!JadeiteComponentPresenter categoriesFor: #createComponents!initialization!public! !
!JadeiteComponentPresenter categoriesFor: #createSchematicWiring!initialization!public! !
!JadeiteComponentPresenter categoriesFor: #hasMethods!public!testing! !
!JadeiteComponentPresenter categoriesFor: #initialize!initialization!public! !
!JadeiteComponentPresenter categoriesFor: #isClassSelected!public!testing! !
!JadeiteComponentPresenter categoriesFor: #labelOf:changedTo:!event handlers!public! !
!JadeiteComponentPresenter categoriesFor: #labelOfClass:editedTo:accept:!event handlers!public! !
!JadeiteComponentPresenter categoriesFor: #onViewClosed!event handlers!public! !
!JadeiteComponentPresenter categoriesFor: #onViewOpened!event handlers!public! !
!JadeiteComponentPresenter categoriesFor: #possiblyClearProjectInfoTab!public!updating! !
!JadeiteComponentPresenter categoriesFor: #projectListPresenter!accessing!private! !
!JadeiteComponentPresenter categoriesFor: #projectListPresenter:!accessing!private! !
!JadeiteComponentPresenter categoriesFor: #registerPresentersForUpdates!public!register presenters! !
!JadeiteComponentPresenter categoriesFor: #renameComponent!menu handlers!public! !
!JadeiteComponentPresenter categoriesFor: #resetComponentList!initialization!public! !
!JadeiteComponentPresenter categoriesFor: #updateComponentPackages!public!updating! !
!JadeiteComponentPresenter categoriesFor: #updateProject!public!updating! !
!JadeiteComponentPresenter categoriesFor: #updateProjectPackages!public!updating! !
!JadeiteComponentPresenter categoriesFor: #updateProjects!actions!public! !

