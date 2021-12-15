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
	myPresenter onViewClosed.
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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 66048) 416 nil 327686 ##(Smalltalk.Color) #default nil 37 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 560 nil nil nil 7 nil nil nil 560 498 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 560 34 2 8 1140850688 131073 672 nil nil nil 7 nil nil nil 672 498 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 672 34 2 8 1409286144 131073 784 nil 480 nil 7 nil nil nil 784 656710 1 ##(Smalltalk.CardLayout) 138 144 8 #() nil nil nil nil 170 192 896 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 784 34 2 8 1140916736 1 928 590662 2 ##(Smalltalk.ListModel) 138 144 896 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) nil nil 1 nil nil nil 928 nil 8 1715211760 787814 3 ##(Smalltalk.BlockClosure) 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 1104 7 257 nil 1090 0 nil 1122 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 1168 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #noIcons nil nil nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 328198 ##(Smalltalk.Point) 1 1 1362 561 875 928 1314 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 928 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 24 1 0 0 181 1 0 0] 8 #() 1362 193 193 nil 27 1250 138 144 34 1 1314 #createAt:extent: 34 2 1362 1 1 1362 561 875 784 1442 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 24 1 0 0 181 1 0 0] 34 1 928 1504 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 1714 #fixedParentRight 1 1714 #fixedParentTop 1 1714 #fixedParentBottom 1 170 192 34 2 784 8 'propertyPresenter' nil 1250 138 144 34 1 1314 #createAt:extent: 34 2 1362 1121 1 1362 561 875 672 1442 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 48 2 0 0 0 0 0 0 72 3 0 0 181 1 0 0] 34 1 784 1504 nil 27 1682 1714 #relativeParentWidth 524806 ##(Smalltalk.Fraction) 5 7 1744 1 1760 1 1776 1 410 ##(Smalltalk.ContainerView) 34 15 nil 560 34 2 8 1140850688 131073 2064 nil nil nil 7 nil nil nil 2064 498 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 2064 34 2 8 1140850688 131073 2176 nil nil nil 7 nil nil nil 2176 498 170 176 34 4 410 ##(Smalltalk.EditableListView) 34 55 nil 2176 34 2 8 1140936777 1025 2288 994 138 144 896 nil 1056 480 nil 7 nil nil nil 2288 nil 8 1714874480 1090 0 nil 1180966 ##(Smalltalk.CompiledExpression) 1 83886081 106 8 'Dolphin List Presenter' 8 'BasicListAbstract' 8 'doIt' 8 '[:each | each ]' 1779525917 2400 7 257 nil nil 1232 nil nil nil 1362 65 65 nil nil 138 144 34 1 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 '' 553 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) nil nil 2288 nil 3 nil nil false nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 2640 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 2640 nil nil 852486 ##(Smalltalk.NullConverter) nil 8 '' 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 1250 138 144 34 1 1314 #createAt:extent: 34 2 1362 1 51 1362 561 825 2288 1442 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 24 1 0 0 181 1 0 0] 8 #() 1504 nil 33 1682 1728 1 1744 1 1760 51 1776 1 410 ##(Smalltalk.StaticText) 34 16 nil 2176 34 2 8 1140850945 65 2976 nil 480 nil 7 nil nil nil 2976 nil 8 1714981536 2738 nil nil nil 1250 138 144 34 2 1314 #createAt:extent: 34 2 1362 1 1 1362 561 51 2976 1314 #text: 34 1 8 'Packages
' 2976 1442 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 24 1 0 0 25 0 0 0] 8 #() 1504 nil 27 1682 1728 1 1744 1 1760 1 1714 #fixedViewTop 51 170 192 34 2 2288 8 'packageListPresenter' nil 1250 138 144 34 1 1314 #createAt:extent: 34 2 1362 561 1 1362 561 875 2176 1442 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 24 1 0 0 0 0 0 0 48 2 0 0 181 1 0 0] 34 2 2976 2288 1504 nil 27 1682 2016 2034 3 5 2016 3 1760 1 1776 1 410 ##(Smalltalk.ContainerView) 34 15 nil 2064 34 2 8 1140850688 131073 3552 nil nil nil 7 nil nil nil 3552 498 170 176 34 4 410 ##(Smalltalk.JadeiteTreeView) 34 28 nil 3552 34 2 8 1140916783 1025 3664 1049670 3 ##(Smalltalk.JadeiteTreeModel) nil 1056 984070 ##(Smalltalk.JadeiteTreeNode) nil nil nil nil 170 192 896 480 nil 7 265030 4 ##(Smalltalk.Menu) nil true 34 1 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #renameComponent 8 'Rename' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 3664 nil 8 1715445824 1090 0 nil 2418 2 1 1088 8 'doIt' 8 '[:service | service name]' 8 #[30 105 226 0 106] #name 3968 7 257 nil ##(Smalltalk.IconicListAbstract) 1232 nil nil nil nil nil 170 176 896 33 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 896 nil 1250 138 144 34 2 1314 #createAt:extent: 34 2 1362 11 51 1362 551 825 3664 1314 #contextMenu: 34 1 3824 3664 1442 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 25 0 0 0 24 1 0 0 181 1 0 0] 8 #() 1504 nil 27 1682 1728 11 1744 1 1760 51 1776 1 410 ##(Smalltalk.StaticText) 34 16 nil 3552 34 2 8 1140850945 65 4288 nil 480 nil 7 nil nil nil 4288 nil 8 1714981536 2738 nil nil nil 1250 138 144 34 2 1314 #createAt:extent: 34 2 1362 1 1 1362 561 51 4288 1314 #text: 34 1 8 'Components' 4288 1442 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 24 1 0 0 25 0 0 0] 8 #() 1504 nil 27 1682 1728 1 1744 1 1760 1 1760 51 170 192 34 2 3664 8 'componentListPresenter' nil 1250 138 144 34 1 1314 #createAt:extent: 34 2 1362 1 1 1362 561 875 3552 1442 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 24 1 0 0 181 1 0 0] 34 2 4288 3664 1504 nil 27 1682 2016 1 2016 2034 3 5 1760 1 1776 1 170 192 896 nil 1250 138 144 34 1 1314 #createAt:extent: 34 2 1362 1 1 1362 1121 875 2064 1442 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 48 2 0 0 181 1 0 0] 34 2 3552 2176 1504 nil 27 1682 1728 1 2016 2034 5 7 1760 1 1776 1 170 192 896 nil 1250 138 144 34 1 1314 #createAt:extent: 34 2 1362 1 1 1362 1681 875 560 1442 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 3 0 0 181 1 0 0] 34 2 2064 672 1504 nil 27 1682 1728 1 1744 1 1760 1 1776 1 170 192 896 nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1250 138 144 34 2 1314 #createAt:extent: 34 2 1362 6837 21 1362 1721 961 416 1314 #text: 34 1 8 'Jadeite Component Editor' 416 1442 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 90 13 0 0 10 0 0 0 182 16 0 0 234 1 0 0] 34 1 560 1504 nil 27 )!

showOn: projectName session: aGciSession
	| editor |
	editor := self new gciSession: aGciSession.
	^editor editProject: projectName! !
!JadeiteComponentEditor class categoriesForMethods!
resource_Default_view!public!resources-views! !
showOn:session:!public! !
!

