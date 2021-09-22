"Filed out from Dolphin Smalltalk 7"!

JadePresenterA subclass: #JadeiteComponentPresenter
	instanceVariableNames: 'projectListPresenter componentTreePresenter componentPropertyPresenter'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteComponentPresenter guid: (GUID fromString: '{f837143a-a8e6-4980-aed2-4c0f6a719061}')!
JadeiteComponentPresenter comment: ''!
!JadeiteComponentPresenter categoriesForClass!Unclassified! !
!JadeiteComponentPresenter methodsFor!

addNoneProject

	"we don't add the (NONE) project in the component editor"!

createComponents
	componentTreePresenter := self add: JadeiteTreePresenter new name: 'componentTreePresenter'.
	componentPropertyPresenter := self add: ListPresenter new name: 'componentPropertyPresenter'.
	projectListPresenter := self add: ListPresenter new name: 'projectListPresenter'!

createSchematicWiring
	projectListPresenter
		when: #selectionChanged
		send: #updateProject
		to: self.
	componentTreePresenter when: #labelOf:editedTo:accept: 	send: #labelOfClass:editedTo:accept:		to: self. 
	componentTreePresenter
		when: #labelOf:changedTo:
		send: #labelOf:changedTo:
		to: self!

initialize
	super initialize. 
	self resetComponentList
	!

labelOf: object changedTo: value
	componentTreePresenter view update.
	self rowanFixMe.  "write the change to the server"!

labelOfClass: componentService editedTo: value accept: accept
	value isEmpty
		ifFalse: 
			[componentService name: value.
			accept value: true]!

onViewClosed
	super onViewClosed.
	BrowserUpdate current removeEventsTriggeredFor: componentTreePresenter.
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
		register: componentTreePresenter
			selector: #componentsUpdate:browser:
			browser: self;
		register: projectListPresenter selector: #projectsUpdate:;
		register: projectListPresenter
			selector: #projectsUpdate:browser:
			browser: self!

renameComponent
	componentTreePresenter view editSelectionLabel!

resetComponentList
	componentTreePresenter model: (JadeiteTreeModel new
				searchPolicy: SearchPolicy equality;
				reset)!

updateProject

	self updateService: projectListPresenter selection!

updateProjectPackages

	"no packages to update yet"!

updateProjects
	| browserService |
	browserService := RowanBrowserService new.
	browserService command: #updateProjects.
	self issueCommand: browserService! !
!JadeiteComponentPresenter categoriesFor: #addNoneProject!public!updating! !
!JadeiteComponentPresenter categoriesFor: #createComponents!initialization!public! !
!JadeiteComponentPresenter categoriesFor: #createSchematicWiring!initialization!public! !
!JadeiteComponentPresenter categoriesFor: #initialize!initialization!public! !
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
!JadeiteComponentPresenter categoriesFor: #updateProject!public!updating! !
!JadeiteComponentPresenter categoriesFor: #updateProjectPackages!public!updating! !
!JadeiteComponentPresenter categoriesFor: #updateProjects!actions!public! !

!JadeiteComponentPresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1140850688 131073 416 nil nil nil 7 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.EditableListView) 34 55 nil 416 34 2 8 1140920397 1025 544 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 327686 ##(Smalltalk.Color) #default nil 7 nil nil nil 544 nil 8 1740499056 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil 328198 ##(Smalltalk.Point) 65 65 nil nil 138 144 34 2 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Property' 245 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) nil nil 544 nil 3 nil nil true nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 912 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 912 nil nil 852486 ##(Smalltalk.NullConverter) nil 8 '' 1 nil nil nil nil nil nil nil nil nil 850 8 'Value' 243 #left 459270 ##(Smalltalk.Message) #displayString 8 #() 1090 #<= 1120 nil nil 544 nil 3 nil nil true nil 898 nil nil 8 #(67174528 0) 1152 946 nil false 992 nil 720 nil 5 nil nil nil 1152 nil nil nil 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 786 1003 1 786 495 875 544 1282 #text: 34 1 8 'Property' 544 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 245 1 0 0 0 0 0 0 236 2 0 0 181 1 0 0] 8 #() 786 193 193 nil 33 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #relativeParentWidth 327734 ##(Smalltalk.Float) 8 113 61 10 215 163 112 229 63 1522 #fixedParentRight 1 1522 #fixedParentTop 1 1522 #fixedParentBottom 1 410 ##(Smalltalk.EditableListView) 34 55 nil 416 34 2 8 1140920397 1025 1632 610 138 144 656 nil 688 720 nil 7 nil nil nil 1632 nil 8 1740499056 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 768 nil nil nil 786 65 65 nil nil 138 144 34 1 850 8 'Projects' 485 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 1824 8 'doIt' 8 '[:each | each displayName]' 8 #[30 105 226 0 106] #displayName 1840 7 257 nil nil 1632 nil 3 nil 1826 0 nil 1858 3 1 1824 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 1936 7 257 nil false nil 898 nil nil 8 #(67174528 0) 2016 946 nil false 992 nil nil nil 5 nil nil nil 2016 nil nil 1010 nil 8 '' 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 1218 138 144 34 2 1282 #createAt:extent: 34 2 786 1 1 786 493 875 1632 1282 #text: 34 1 8 'Projects' 1632 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 246 0 0 0 181 1 0 0] 8 #() 1472 nil 33 1490 1522 #fixedParentLeft 1 1536 1554 8 31 133 235 81 184 30 213 63 1600 1 1616 1 410 ##(Smalltalk.JadeiteTreeView) 34 27 nil 416 34 2 8 1140916775 1025 2368 1049670 3 ##(Smalltalk.JadeiteTreeModel) nil 992 984070 ##(Smalltalk.JadeiteTreeNode) nil nil nil nil 170 176 656 720 nil 7 265030 4 ##(Smalltalk.Menu) nil true 34 1 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #renameComponent 8 'Rename' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 2368 nil 8 1741070400 1826 0 nil 1858 2 1 1088 8 'doIt' 8 '[:service | service displayString]' 8 #[30 105 226 0 106] #displayString 2672 7 257 nil ##(Smalltalk.IconicListAbstract) 768 nil nil nil nil nil 170 176 656 nil #smallIcons 1 170 ##(Smalltalk.PluggableLookupTable) 656 1218 138 144 34 2 1282 #createAt:extent: 34 2 786 493 1 786 511 875 2368 1282 #contextMenu: 34 1 2528 2368 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 246 0 0 0 0 0 0 0 245 1 0 0 181 1 0 0] 8 #() 1472 nil 27 1490 1536 1554 8 31 133 235 81 184 30 213 63 1536 1554 8 113 61 10 215 163 112 229 63 1600 1 1616 1 170 192 34 6 544 8 'componentPropertyPresenter' 1632 8 'projectListPresenter' 2368 8 'componentTreePresenter' nil 1218 138 144 34 1 1282 #createAt:extent: 34 2 786 7155 21 786 1497 875 416 1410 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 249 13 0 0 10 0 0 0 229 16 0 0 191 1 0 0] 34 3 1632 2368 544 1472 nil 27 )! !
!JadeiteComponentPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

