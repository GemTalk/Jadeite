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
		to: self!

initialize
	super initialize. 
	self resetComponentList
	!

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
!JadeiteComponentPresenter categoriesFor: #onViewClosed!event handlers!public! !
!JadeiteComponentPresenter categoriesFor: #onViewOpened!event handlers!public! !
!JadeiteComponentPresenter categoriesFor: #possiblyClearProjectInfoTab!public!updating! !
!JadeiteComponentPresenter categoriesFor: #projectListPresenter!accessing!private! !
!JadeiteComponentPresenter categoriesFor: #projectListPresenter:!accessing!private! !
!JadeiteComponentPresenter categoriesFor: #registerPresentersForUpdates!public!register presenters! !
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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1140850688 131073 416 nil nil nil 7 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.JadeiteTreeView) 34 27 nil 416 34 2 8 1140916775 1025 544 1049670 3 ##(Smalltalk.JadeiteTreeModel) nil 1310726 ##(Smalltalk.EqualitySearchPolicy) 984070 ##(Smalltalk.JadeiteTreeNode) nil nil nil nil 170 176 8 #() 327686 ##(Smalltalk.Color) #default nil 7 nil nil nil 544 nil 8 1741070400 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 ##(Smalltalk.Message) 8 'doIt' 8 '[:service | service displayString]' 8 #[30 105 226 0 106] #displayString 800 7 257 nil ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil 170 176 720 nil #smallIcons 1 170 ##(Smalltalk.PluggableLookupTable) 720 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 328198 ##(Smalltalk.Point) 493 1 1074 511 875 544 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 246 0 0 0 0 0 0 0 245 1 0 0 181 1 0 0] 8 #() 1074 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #relativeParentWidth 327734 ##(Smalltalk.Float) 8 31 133 235 81 184 30 213 63 1248 1266 8 113 61 10 215 163 112 229 63 1234 #fixedParentTop 1 1234 #fixedParentBottom 1 410 ##(Smalltalk.EditableListView) 34 55 nil 416 34 2 8 1140920397 1025 1344 590662 2 ##(Smalltalk.ListModel) 138 144 720 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 752 nil 7 nil nil nil 1344 nil 8 1740499056 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 912 nil nil nil 1074 65 65 nil nil 138 144 34 2 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Property' 245 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) nil nil 1344 nil 3 nil nil true nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 1616 721990 2 ##(Smalltalk.ValueHolder) nil false 656 nil nil nil 5 nil nil nil 1616 nil nil 852486 ##(Smalltalk.NullConverter) nil 8 '' 1 nil nil nil nil nil nil nil nil nil 1554 8 'Value' 243 #left 459270 ##(Smalltalk.Message) #displayString 8 #() 1762 #<= 1792 nil nil 1344 nil 3 nil nil true nil 1602 nil nil 8 #(67174528 0) 1824 1650 nil false 656 nil 752 nil 5 nil nil nil 1824 nil nil nil 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 962 138 144 34 2 1026 #createAt:extent: 34 2 1074 1003 1 1074 495 875 1344 1026 #text: 34 1 8 'Property' 1344 1122 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 245 1 0 0 0 0 0 0 236 2 0 0 181 1 0 0] 8 #() 1184 nil 33 1202 1248 1266 8 113 61 10 215 163 112 229 63 1234 #fixedParentRight 1 1312 1 1328 1 410 ##(Smalltalk.EditableListView) 34 55 nil 416 34 2 8 1140920397 1025 2144 1410 138 144 720 nil 1472 752 nil 7 nil nil nil 2144 nil 8 1740499056 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 912 nil nil nil 1074 65 65 nil nil 138 144 34 1 1554 8 'Projects' 485 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 786 0 nil 818 2 1 784 8 'doIt' 8 '[:each | each displayName]' 8 #[30 105 226 0 106] #displayName 2336 7 257 nil nil 2144 nil 3 nil 786 0 nil 818 3 1 784 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 2416 7 257 nil false nil 1602 nil nil 8 #(67174528 0) 2496 1650 nil false 656 nil nil nil 5 nil nil nil 2496 nil nil 1682 nil 8 '' 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 962 138 144 34 2 1026 #createAt:extent: 34 2 1074 1 1 1074 493 875 2144 1026 #text: 34 1 8 'Projects' 2144 1122 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 246 0 0 0 181 1 0 0] 8 #() 1184 nil 33 1202 1234 #fixedParentLeft 1 1248 1266 8 31 133 235 81 184 30 213 63 1312 1 1328 1 170 192 34 6 544 8 'componentTreePresenter' 1344 8 'componentPropertyPresenter' 2144 8 'projectListPresenter' nil 962 138 144 34 1 1026 #createAt:extent: 34 2 1074 7155 21 1074 1497 875 416 1122 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 249 13 0 0 10 0 0 0 229 16 0 0 191 1 0 0] 34 3 2144 544 1344 1184 nil 27 )! !
!JadeiteComponentPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

