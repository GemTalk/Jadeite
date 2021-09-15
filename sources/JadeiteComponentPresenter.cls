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

clearComponentList
	componentTreePresenter model: (JadeiteTreeModel new
				searchPolicy: SearchPolicy equality;
				reset)!

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

updateProjectPackages

	"no packages to update yet"!

updateProjects
	| browserService |
	browserService := RowanBrowserService new.
	browserService command: #updateProjects.
	self issueCommand: browserService! !
!JadeiteComponentPresenter categoriesFor: #addNoneProject!public!updating! !
!JadeiteComponentPresenter categoriesFor: #clearComponentList!actions!public! !
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
!JadeiteComponentPresenter categoriesFor: #updateProjectPackages!public!updating! !
!JadeiteComponentPresenter categoriesFor: #updateProjects!actions!public! !

!JadeiteComponentPresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1140850688 131073 416 nil nil nil 7 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.ListTreeView) 34 59 nil 416 34 2 8 1140920397 1025 544 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 327686 ##(Smalltalk.Color) #default nil 7 nil nil nil 544 nil 8 1740499056 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 1 920646 5 ##(Smalltalk.ListViewColumn) 8 'Component' 503 #left ##(Smalltalk.BasicListAbstract) 459270 ##(Smalltalk.Message) #<= 8 #() nil nil 544 nil 3 nil nil #report 8 #() nil 133217 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil true 1050438 3 ##(Smalltalk.VirtualTreeModel) nil 688 138 144 656 787814 3 ##(Smalltalk.BlockClosure) 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 928 #defaultGetChildrenBlock 42440101 8 #[30 105 226 0 106] #children 992 7 257 nil 978 0 nil 1010 2 3 928 #defaultGetParentBlock 42415045 8 #[30 105 226 0 106] #parent 1056 7 257 nil 978 0 nil 1010 2 3 928 #defaultHasChildrenBlock 42500293 8 #[252 1 0 0 1 4 0 65 176 159 106 105] #childrenOf: #notEmpty 17 257 944 978 0 nil 1010 1 83886083 928 #defaultFilterBlock 42430373 8 #[29 105 17 157 106] 1152 7 257 nil nil 138 ##(Smalltalk.PluggableSet) 656 138 ##(Smalltalk.IdentitySet) 656 37 1 nil nil nil nil nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 328198 ##(Smalltalk.Point) 493 1 1346 511 875 544 1298 #text: 34 1 8 'Component' 544 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 246 0 0 0 0 0 0 0 245 1 0 0 181 1 0 0] 8 #() 1346 193 193 nil 2029 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #relativeParentWidth 327734 ##(Smalltalk.Float) 8 31 133 235 81 184 30 213 63 1568 1586 8 113 61 10 215 163 112 229 63 1554 #fixedParentTop 1 1554 #fixedParentBottom 1 410 ##(Smalltalk.EditableListView) 34 55 nil 416 34 2 8 1140920397 1025 1664 610 138 144 656 nil 688 720 nil 7 nil nil nil 1664 nil 8 1740499056 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 768 nil nil nil 1346 65 65 nil nil 138 144 34 2 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Property' 245 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) nil nil 1664 nil 3 nil nil true nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 1888 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 1888 nil nil 852486 ##(Smalltalk.NullConverter) nil 8 '' 1 nil nil nil nil nil nil nil nil nil 1826 8 'Value' 243 #left 866 #displayString 8 #() 866 #<= 2080 nil nil 1664 nil 3 nil nil true nil 1874 nil nil 8 #(67174528 0) 2112 1922 nil false 1968 nil 720 nil 5 nil nil nil 2112 nil nil nil 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 1346 1003 1 1346 495 875 1664 1298 #text: 34 1 8 'Property' 1664 1442 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 245 1 0 0 0 0 0 0 236 2 0 0 181 1 0 0] 8 #() 1504 nil 33 1522 1568 1586 8 113 61 10 215 163 112 229 63 1554 #fixedParentRight 1 1632 1 1648 1 410 ##(Smalltalk.EditableListView) 34 55 nil 416 34 2 8 1140920397 1025 2432 610 138 144 656 nil 688 720 nil 7 nil nil nil 2432 nil 8 1740499056 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 768 nil nil nil 1346 65 65 nil nil 138 144 34 1 1826 8 'Projects' 485 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 978 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 976 8 'doIt' 8 '[:each | each displayName]' 8 #[30 105 226 0 106] #displayName 2624 7 257 nil nil 2432 nil 3 nil 978 0 nil 2642 3 1 976 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 2720 7 257 nil false nil 1874 nil nil 8 #(67174528 0) 2800 1922 nil false 1968 nil nil nil 5 nil nil nil 2800 nil nil 1986 nil 8 '' 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 1346 1 1 1346 493 875 2432 1298 #text: 34 1 8 'Projects' 2432 1442 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 246 0 0 0 181 1 0 0] 8 #() 1504 nil 33 1522 1554 #fixedParentLeft 1 1568 1586 8 31 133 235 81 184 30 213 63 1632 1 1648 1 170 192 34 6 544 8 'componentTreePresenter' 1664 8 'componentPropertyPresenter' 2432 8 'projectListPresenter' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 1346 7155 21 1346 1497 875 416 1442 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 249 13 0 0 10 0 0 0 229 16 0 0 191 1 0 0] 34 3 2432 544 1664 1504 nil 27 )! !
!JadeiteComponentPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

