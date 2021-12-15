"Filed out from Dolphin Smallalk"!

JadeShell subclass: #JadeiteComponentEditor
	instanceVariableNames: 'projectListPresenter componentTreePresenter componentPropertyPresenter'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteComponentEditor guid: (GUID fromString: '{3afeeb63-aa19-42d9-ad83-b415a0fb8993}')!
JadeiteComponentEditor comment: ''!
!JadeiteComponentEditor categoriesForClass!Unclassified! !
!JadeiteComponentEditor methodsFor!

editProject: projectName
	self createView: self class defaultView.
	model := (RowanProjectDefinitionService new name: projectName) editInSession: gciSession
				window: self view handle value.
	myPresenter model: model. 
	^self show!

onViewClosed
	super onViewClosed.
	self gciSession
		ifNotNil: 
			[:sess |
			sess isValidSession
				ifTrue: [RowanBrowserService new releaseWindow: self view handle value session: self gciSession]]!

presenterClass
	^JadeiteComponentPresenter!

updateCaption
	self caption: (gciSession titleBarFor: 'Project Component Editor')! !
!JadeiteComponentEditor categoriesForMethods!
editProject:!displaying!public! !
onViewClosed!event handlers!public! !
presenterClass!public! !
updateCaption!public! !
!

!JadeiteComponentEditor class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 66048) 416 nil 327686 ##(Smalltalk.Color) #default nil 37 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 560 nil nil nil 7 nil nil nil 560 498 170 176 34 6 410 ##(Smalltalk.EditableListView) 34 55 nil 560 34 2 8 1140920397 1025 672 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 nil nil nil 672 nil 8 1714874480 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil 328198 ##(Smalltalk.Point) 65 65 nil nil 138 144 34 2 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Property' 277 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) nil nil 672 nil 3 nil nil true nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 1008 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 1008 nil nil 852486 ##(Smalltalk.NullConverter) nil 8 '' 1 nil nil nil nil nil nil nil nil nil 946 8 'Value' 277 #left 459270 ##(Smalltalk.Message) #displayString 8 #() 1186 #<= 1216 nil nil 672 nil 3 nil nil true nil 994 nil nil 8 #(67174528 0) 1248 1042 nil false 1088 nil 480 nil 5 nil nil nil 1248 nil nil nil 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 882 1121 1 882 561 875 672 1378 #text: 34 1 8 'Property' 672 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 48 2 0 0 0 0 0 0 72 3 0 0 181 1 0 0] 8 #() 882 193 193 nil 33 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #relativeParentWidth 524806 ##(Smalltalk.Fraction) 5 7 1618 #fixedParentRight 1 1618 #fixedParentTop 1 1618 #fixedParentBottom 1 410 ##(Smalltalk.ContainerView) 34 15 nil 560 34 2 8 1140850688 131073 1728 nil nil nil 7 nil nil nil 1728 nil 170 192 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 1728 34 2 8 1409286144 131073 1824 nil 480 nil 7 nil nil nil 1824 656710 1 ##(Smalltalk.CardLayout) 138 144 784 nil nil nil nil 170 192 784 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 1824 34 2 8 1140916736 1 1952 738 138 144 784 nil 816 nil nil 1 nil nil nil 1952 nil 8 1715211760 787814 3 ##(Smalltalk.BlockClosure) 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 2080 7 257 nil 2066 0 nil 2098 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 2144 7 257 nil 864 nil nil nil nil nil #noIcons nil nil nil nil nil 1314 138 144 34 2 1378 #createAt:extent: 34 2 882 1 1 882 1681 875 1952 1378 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 1952 1506 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 3 0 0 181 1 0 0] 8 #() 1568 nil 27 1314 138 144 34 1 1378 #createAt:extent: 34 2 882 3 1 882 1681 875 1824 1506 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 1 0 0 0 0 0 0 0 73 3 0 0 181 1 0 0] 34 1 1952 1568 nil 27 8 'propertyPresenter' nil 1314 138 144 34 1 1378 #createAt:extent: 34 2 882 1121 1 882 561 875 1728 1506 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 48 2 0 0 0 0 0 0 72 3 0 0 181 1 0 0] 34 1 1824 1568 nil 27 1586 1632 1650 5 7 1680 1 1696 1 1712 1 410 ##(Smalltalk.ContainerView) 34 15 nil 560 34 2 8 1140850688 131073 2752 nil nil nil 7 nil nil nil 2752 498 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 2752 34 2 8 1140850688 131073 2864 nil nil nil 7 nil nil nil 2864 498 170 176 34 4 410 ##(Smalltalk.EditableListView) 34 55 nil 2864 34 2 8 1140936777 1025 2976 738 138 144 784 nil 816 480 nil 7 nil nil nil 2976 nil 8 1714874480 2066 0 nil 1180966 ##(Smalltalk.CompiledExpression) 1 83886081 106 8 'Dolphin List Presenter' 8 'BasicListAbstract' 8 'doIt' 8 '[:each | each ]' 1779525917 3088 7 257 nil nil 864 nil nil nil 882 65 65 nil nil 138 144 34 1 946 8 '' 553 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) nil nil 2976 nil 3 nil nil false nil 994 nil nil 8 #(67174528 0) 3296 1042 nil false 1088 nil nil nil 5 nil nil nil 3296 nil nil 1106 nil 8 '' 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 1314 138 144 34 1 1378 #createAt:extent: 34 2 882 1 51 882 561 825 2976 1506 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 24 1 0 0 181 1 0 0] 8 #() 1568 nil 33 1586 1618 #fixedParentLeft 1 1680 1 1696 51 1712 1 410 ##(Smalltalk.StaticText) 34 16 nil 2864 34 2 8 1140850945 65 3584 nil 480 nil 7 nil nil nil 3584 nil 8 1714981536 1106 nil nil nil 1314 138 144 34 2 1378 #createAt:extent: 34 2 882 1 1 882 561 51 3584 1378 #text: 34 1 8 'Packages
' 3584 1506 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 24 1 0 0 25 0 0 0] 8 #() 1568 nil 27 1586 3568 1 1680 1 1696 1 1618 #fixedViewTop 51 170 192 34 2 2976 8 'packageListPresenter' nil 1314 138 144 34 1 1378 #createAt:extent: 34 2 882 561 1 882 561 875 2864 1506 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 24 1 0 0 0 0 0 0 48 2 0 0 181 1 0 0] 34 2 3584 2976 1568 nil 27 1586 1632 1650 3 5 1632 3 1696 1 1712 1 410 ##(Smalltalk.ContainerView) 34 15 nil 2752 34 2 8 1140850688 131073 4160 nil nil nil 7 nil nil nil 4160 498 170 176 34 4 410 ##(Smalltalk.JadeiteTreeView) 34 28 nil 4160 34 2 8 1140916783 1025 4272 1049670 3 ##(Smalltalk.JadeiteTreeModel) nil 816 984070 ##(Smalltalk.JadeiteTreeNode) nil nil nil nil 170 192 784 480 nil 7 265030 4 ##(Smalltalk.Menu) nil true 34 1 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #renameComponent 8 'Rename' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 4272 nil 8 1715445824 2066 0 nil 3106 2 1 2064 8 'doIt' 8 '[:service | service name]' 8 #[30 105 226 0 106] #name 4576 7 257 nil ##(Smalltalk.IconicListAbstract) 864 nil nil nil nil nil 170 176 784 33 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 784 nil 1314 138 144 34 2 1378 #createAt:extent: 34 2 882 11 51 882 551 825 4272 1378 #contextMenu: 34 1 4432 4272 1506 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 25 0 0 0 24 1 0 0 181 1 0 0] 8 #() 1568 nil 27 1586 3568 11 1680 1 1696 51 1712 1 410 ##(Smalltalk.StaticText) 34 16 nil 4160 34 2 8 1140850945 65 4896 nil 480 nil 7 nil nil nil 4896 nil 8 1714981536 1106 nil nil nil 1314 138 144 34 2 1378 #createAt:extent: 34 2 882 1 1 882 561 51 4896 1378 #text: 34 1 8 'Components' 4896 1506 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 24 1 0 0 25 0 0 0] 8 #() 1568 nil 27 1586 3568 1 1680 1 1696 1 1696 51 170 192 34 2 4272 8 'componentListPresenter' nil 1314 138 144 34 1 1378 #createAt:extent: 34 2 882 1 1 882 561 875 4160 1506 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 24 1 0 0 181 1 0 0] 34 2 4896 4272 1568 nil 27 1586 1632 1 1632 1650 3 5 1696 1 1712 1 170 192 784 nil 1314 138 144 34 1 1378 #createAt:extent: 34 2 882 1 1 882 1121 875 2752 1506 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 48 2 0 0 181 1 0 0] 34 2 4160 2864 1568 nil 27 1586 3568 1 1632 1650 5 7 1696 1 1712 1 170 192 34 2 672 8 'componentPropertyPresenter' nil 1314 138 144 34 1 1378 #createAt:extent: 34 2 882 1 1 882 1681 875 560 1506 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 3 0 0 181 1 0 0] 34 3 2752 672 1728 1568 nil 27 1586 3568 1 1680 1 1696 1 1712 1 170 192 784 nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1314 138 144 34 2 1378 #createAt:extent: 34 2 882 6837 21 882 1721 961 416 1378 #text: 34 1 8 'Jadeite Component Editor' 416 1506 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 90 13 0 0 10 0 0 0 182 16 0 0 234 1 0 0] 34 1 560 1568 nil 27 )!

showOn: projectName session: aGciSession
	| editor |
	editor := self new gciSession: aGciSession.
	^editor editProject: projectName! !
!JadeiteComponentEditor class categoriesForMethods!
resource_Default_view!public!resources-views! !
showOn:session:!public! !
!

