"Filed out from Dolphin Smallalk"!

JadeShell subclass: #JadeitePackageGroupEditor
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeitePackageGroupEditor guid: (GUID fromString: '{d68de4dd-c885-4824-b9e7-31b90c147e75}')!
JadeitePackageGroupEditor comment: ''!
!JadeitePackageGroupEditor categoriesForClass!Unclassified! !
!JadeitePackageGroupEditor methodsFor!

editPackageGroups: projectName
	self createView: self class defaultView.
	model := (RowanProjectDefinitionService new
				name: projectName;
				showLoadedPackageGroupsOnly: false) editInSession: gciSession window: self view handle value.
	self updateCaption.	"pick up the project definition name in the caption -- needed?"
	model session: self gciSession.
	myPresenter model: model.
	myPresenter displayPackageGroups.
	^self show!

onViewClosed
	super onViewClosed.
	myPresenter onViewClosed.
	self gciSession
		ifNotNil: 
			[:sess |
			sess isValidSession
				ifTrue: [RowanBrowserService new releaseWindow: self view handle value session: self gciSession]]!

presenterClass
	^JadeitePackageGroupPresenter!

updateCaption
	self caption: (gciSession titleBarFor: 'Package Group Editor for ', model name)! !
!JadeitePackageGroupEditor categoriesForMethods!
editPackageGroups:!initialization!public! !
onViewClosed!event handlers!public! !
presenterClass!public! !
updateCaption!public! !
!

!JadeitePackageGroupEditor class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default nil 37 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 560 nil nil nil 7 nil nil nil 560 498 170 176 34 4 410 ##(Smalltalk.StaticText) 34 16 nil 560 34 2 8 1140850945 65 672 nil 480 nil 7 nil nil nil 672 nil 8 1591672000 852486 ##(Smalltalk.NullConverter) nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 328198 ##(Smalltalk.Point) 1 1 898 585 51 672 850 #text: 34 1 8 'Packages
' 672 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 36 1 0 0 25 0 0 0] 8 #() 898 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 1106 #fixedParentRight 1 1106 #fixedParentTop 1 1106 #fixedViewTop 51 410 ##(Smalltalk.ListView) 34 45 nil 560 34 2 8 1140937033 1025 1184 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 15 265030 4 ##(Smalltalk.Menu) nil true 34 5 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #addPackage 8 'Add Package ...' 1 1 nil nil nil 1394 1 1426 #renamePackage 8 'Rename Package ...' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 1394 1 1426 #removePackageFromPackageGroup 8 'Remove Package From Package Group' 1 1 nil nil nil 1394 1 1426 #removePackagesFromProjectDefinition 8 'Remove Package from Project Definition' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 1184 nil 8 1591759072 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 1 83886081 106 8 'Dolphin List Presenter' 8 'BasicListAbstract' 8 'doIt' 8 '[:each | each ]' 1779525917 1696 7 257 nil nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 1 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 '' 577 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) nil nil 1184 nil 3 nil nil true 1682 0 nil 1714 3 1 1680 8 'doIt' 8 '[:packageService :newName | packageService halt; renameTo: newName]' 8 #[31 105 17 100 158 74 177 106] #halt #renameTo: 1936 7 513 nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 2032 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 2032 nil nil 754 nil 8 '' 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131169 nil 1 nil nil 201 nil nil nil nil nil nil nil nil nil nil nil nil 786 138 144 34 2 850 #createAt:extent: 34 2 898 1 51 898 585 673 1184 850 #contextMenu: 34 1 1360 1184 994 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 36 1 0 0 105 1 0 0] 8 #() 1056 nil 35 1074 1120 1 1136 1 1152 51 1106 #fixedParentBottom 1 170 192 34 2 1184 8 'packageListPresenter' nil 786 138 144 34 1 850 #createAt:extent: 34 2 898 585 1 898 585 723 560 994 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 36 1 0 0 0 0 0 0 72 2 0 0 105 1 0 0] 34 2 672 1184 1056 nil 27 1074 1106 #relativeParentWidth 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 224 63 1136 1 1152 1 2384 1 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 2672 nil nil nil 7 nil nil nil 2672 498 170 176 34 4 410 ##(Smalltalk.EditableListView) 34 55 nil 2672 34 2 8 1140920393 1025 2784 1250 138 144 1296 nil 1328 480 nil 23 1346 nil true 34 4 1394 1 1426 #addPackageGroup 8 'Add Package Group ...' 1 1 nil nil nil 1394 1 1426 #removePackageGroups 8 'Remove Package Groups ...' 9393 1 nil nil nil 1522 4097 1394 1 1426 #addNewPackageToPackageGroup 8 'Add New Package to Package Group ...' 1 1 nil nil nil 1648 nil 134217729 nil nil nil nil nil nil nil 2784 nil 8 1591759072 1682 0 nil 1714 1 83886081 1744 1792 1808 1779525917 3088 7 257 nil nil 1840 nil nil nil 898 65 65 nil nil 138 144 34 2 1890 8 'Name' 289 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 1682 0 nil 1714 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:service | service name]' 8 #[30 105 226 0 106] #name 3200 7 257 nil nil 2784 nil 3 nil nil true 1682 0 nil 1714 2 1 1680 8 'doIt' 8 '[:packageGroupService :newName | packageGroupService renamePackageGroupTo: newName ]' 8 #[30 105 233 1 176 106] #renamePackageGroupTo: 3280 7 513 nil 2018 nil nil 2048 3360 2066 nil false 2112 nil nil nil 5 nil nil nil 3360 nil nil 754 nil 2144 1 nil nil nil nil nil nil nil nil nil 1890 8 'Condition' 289 #left 459270 ##(Smalltalk.Message) #displayString 8 #() 3442 #<= 3472 1682 0 nil 1714 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:service | service condition]' 8 #[30 105 226 0 106] #condition 3504 7 257 nil nil 2784 nil 3 nil nil true 1682 0 nil 1714 2 1 1680 8 'doIt' 8 '[:packageGroupService :condition | packageGroupService setCondition: condition ]' 8 #[30 105 233 1 176 106] #setCondition: 3584 7 513 nil 2018 nil nil 8 #(67174528 0) 3664 2066 nil false 2112 nil 480 nil 5 nil nil nil 3664 nil nil nil 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 786 138 144 34 3 850 #createAt:extent: 34 2 898 1 51 898 585 673 2784 850 #contextMenu: 34 1 2880 2784 850 #text: 34 1 8 'Name' 2784 994 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 36 1 0 0 105 1 0 0] 8 #() 1056 nil 33 1074 1120 1 1136 1 1152 51 2384 1 410 ##(Smalltalk.StaticText) 34 16 nil 2672 34 2 8 1140850945 65 3984 nil 480 nil 7 nil nil nil 3984 nil 8 1591672000 754 nil nil nil 786 138 144 34 2 850 #createAt:extent: 34 2 898 1 1 898 585 51 3984 850 #text: 34 1 8 'Package Groups' 3984 994 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 36 1 0 0 25 0 0 0] 8 #() 1056 nil 27 1074 1120 1 1136 1 1152 1 1152 51 170 192 34 2 2784 8 'packageGroupPresenter' nil 786 138 144 34 1 850 #createAt:extent: 34 2 898 1 1 898 585 723 2672 994 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 36 1 0 0 105 1 0 0] 34 2 3984 2784 1056 nil 27 1074 1120 1 2624 2642 8 0 0 0 0 0 0 224 63 1152 1 2384 1 170 192 34 4 560 8 'Packages Container View' 2672 8 'Package Group Container View' nil nil nil nil nil 1 nil nil nil nil 1 nil nil 786 138 144 34 1 850 #createAt:extent: 34 2 898 6517 21 898 1201 801 416 994 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 186 12 0 0 10 0 0 0 18 15 0 0 154 1 0 0] 34 2 2672 560 1056 nil 27 )!

showOn: projectName session: aGciSession
	| editor |
	editor := self new gciSession: aGciSession.
	^editor editPackageGroups: projectName! !
!JadeitePackageGroupEditor class categoriesForMethods!
resource_Default_view!public!resources-views! !
showOn:session:!public! !
!

