"Filed out from Dolphin Smalltalk 7"!

JadeShell subclass: #JadeiteComponentEditor
	instanceVariableNames: 'projectListPresenter componentTreePresenter componentPropertyPresenter'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteComponentEditor guid: (GUID fromString: '{3afeeb63-aa19-42d9-ad83-b415a0fb8993}')!
JadeiteComponentEditor comment: ''!
!JadeiteComponentEditor categoriesForClass!Unclassified! !
!JadeiteComponentEditor methodsFor!

displayComponents!

editProject: projectName
	self createView: self class defaultView.
	model := (RowanProjectDefinitionService new name: projectName) editInSession: gciSession
				window: self view handle value.
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

show
	super show.
	self displayComponents. !

updateCaption
	self caption: (gciSession titleBarFor: 'Project Component Editor')! !
!JadeiteComponentEditor categoriesFor: #displayComponents!displaying!public! !
!JadeiteComponentEditor categoriesFor: #editProject:!displaying!public! !
!JadeiteComponentEditor categoriesFor: #onViewClosed!event handlers!public! !
!JadeiteComponentEditor categoriesFor: #presenterClass!public! !
!JadeiteComponentEditor categoriesFor: #show!displaying!public! !
!JadeiteComponentEditor categoriesFor: #updateCaption!public! !

!JadeiteComponentEditor class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 66048) 416 nil 327686 ##(Smalltalk.Color) #default nil 37 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 560 nil nil nil 7 nil nil nil 560 498 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 560 34 2 8 1140850688 131073 672 nil nil nil 7 nil nil nil 672 498 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 672 34 2 8 1140850688 131073 784 nil nil nil 7 nil nil nil 784 498 170 176 34 4 410 ##(Smalltalk.EditableListView) 34 55 nil 784 34 2 8 1140936781 1025 896 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 nil nil nil 896 nil 8 1714874480 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil 328198 ##(Smalltalk.Point) 65 65 nil nil 138 144 34 1 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 '' 553 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 1216 8 'doIt' 8 '[:each | each displayName]' 8 #[30 105 226 0 106] #displayName 1232 7 257 nil nil 896 nil 3 nil 1218 0 nil 1250 3 1 1216 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 1328 7 257 nil false nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 1424 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 1424 nil nil 852486 ##(Smalltalk.NullConverter) nil 8 '' 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 1106 1 51 1106 561 825 896 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 24 1 0 0 181 1 0 0] 8 #() 1106 193 193 nil 33 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 1842 #fixedParentRight 1 1842 #fixedParentTop 51 1842 #fixedParentBottom 1 410 ##(Smalltalk.StaticText) 34 16 nil 784 34 2 8 1140850945 65 1920 nil 480 nil 7 nil nil nil 1920 nil 8 1714981536 1522 nil nil nil 1586 138 144 34 2 1650 #createAt:extent: 34 2 1106 1 1 1106 561 51 1920 1650 #text: 34 1 8 'Packages
' 1920 1730 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 24 1 0 0 25 0 0 0] 8 #() 1792 nil 27 1810 1856 1 1872 1 1888 1 1842 #fixedViewTop 51 170 192 34 2 896 8 'packageListPresenter' nil 1586 138 144 34 1 1650 #createAt:extent: 34 2 1106 561 1 1106 561 875 784 1730 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 24 1 0 0 0 0 0 0 48 2 0 0 181 1 0 0] 34 2 1920 896 1792 nil 27 1810 1842 #relativeParentWidth 524806 ##(Smalltalk.Fraction) 3 5 2480 3 1888 1 1904 1 410 ##(Smalltalk.ContainerView) 34 15 nil 672 34 2 8 1140850688 131073 2528 nil nil nil 7 nil nil nil 2528 498 170 176 34 4 410 ##(Smalltalk.JadeiteTreeView) 34 28 nil 2528 34 2 8 1140916783 1025 2640 1049670 3 ##(Smalltalk.JadeiteTreeModel) nil 1040 984070 ##(Smalltalk.JadeiteTreeNode) nil nil nil nil 170 192 1008 480 nil 7 265030 4 ##(Smalltalk.Menu) nil true 34 1 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #renameComponent 8 'Rename' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 2640 nil 8 1715445824 1218 0 nil 1250 2 1 ##(Smalltalk.Message) 8 'doIt' 8 '[:service | service displayString]' 8 #[30 105 226 0 106] #displayString 2944 7 257 nil ##(Smalltalk.IconicListAbstract) 1088 nil nil nil nil nil 170 176 1008 33 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 1008 nil 1586 138 144 34 2 1650 #createAt:extent: 34 2 1106 11 51 1106 551 825 2640 1650 #contextMenu: 34 1 2800 2640 1730 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 25 0 0 0 24 1 0 0 181 1 0 0] 8 #() 1792 nil 27 1810 1856 11 1872 1 1888 51 1904 1 410 ##(Smalltalk.StaticText) 34 16 nil 2528 34 2 8 1140850945 65 3264 nil 480 nil 7 nil nil nil 3264 nil 8 1714981536 1522 nil nil nil 1586 138 144 34 2 1650 #createAt:extent: 34 2 1106 1 1 1106 561 51 3264 1650 #text: 34 1 8 'Components' 3264 1730 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 24 1 0 0 25 0 0 0] 8 #() 1792 nil 27 1810 1856 1 1872 1 1888 1 1888 51 170 192 34 2 2640 8 'componentListPresenter' nil 1586 138 144 34 1 1650 #createAt:extent: 34 2 1106 1 1 1106 561 875 2528 1730 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 24 1 0 0 181 1 0 0] 34 2 3264 2640 1792 nil 27 1810 2480 1 2480 2498 3 5 1888 1 1904 1 170 192 1008 nil 1586 138 144 34 1 1650 #createAt:extent: 34 2 1106 1 1 1106 1121 875 672 1730 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 48 2 0 0 181 1 0 0] 34 2 2528 784 1792 nil 27 1810 1856 1 2480 2498 5 7 1888 1 1904 1 410 ##(Smalltalk.EditableListView) 34 55 nil 560 34 2 8 1140920397 1025 4032 962 138 144 1008 nil 1040 480 nil 7 nil nil nil 4032 nil 8 1714874480 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 1088 nil nil nil 1106 65 65 nil nil 138 144 34 2 1170 8 'Property' 277 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) nil nil 4032 nil 3 nil nil true nil 1410 nil nil 8 #(67174528 0) 4224 1458 nil false 1504 nil nil nil 5 nil nil nil 4224 nil nil 1522 nil 8 '' 1 nil nil nil nil nil nil nil nil nil 1170 8 'Value' 277 #left 459270 ##(Smalltalk.Message) #displayString 8 #() 4338 #<= 4368 nil nil 4032 nil 3 nil nil true nil 1410 nil nil 8 #(67174528 0) 4400 1458 nil false 1504 nil 480 nil 5 nil nil nil 4400 nil nil nil 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 1586 138 144 34 2 1650 #createAt:extent: 34 2 1106 1121 1 1106 561 875 4032 1650 #text: 34 1 8 'Property' 4032 1730 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 48 2 0 0 0 0 0 0 72 3 0 0 181 1 0 0] 8 #() 1792 nil 33 1810 2480 2498 5 7 1872 1 1888 1 1904 1 170 192 34 2 4032 8 'componentPropertyPresenter' nil 1586 138 144 34 1 1650 #createAt:extent: 34 2 1106 1 1 1106 1681 875 560 1730 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 3 0 0 181 1 0 0] 34 2 672 4032 1792 nil 27 1810 1856 1 1872 1 1888 1 1904 1 170 192 1008 nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1586 138 144 34 2 1650 #createAt:extent: 34 2 1106 6837 21 1106 1721 961 416 1650 #text: 34 1 8 'Jadeite Component Editor' 416 1730 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 90 13 0 0 10 0 0 0 182 16 0 0 234 1 0 0] 34 1 560 1792 nil 27 )!

showOn: projectName session: aGciSession
	| editor |
	editor := self new gciSession: aGciSession.
	^editor editProject: projectName! !
!JadeiteComponentEditor class categoriesFor: #resource_Default_view!public!resources-views! !
!JadeiteComponentEditor class categoriesFor: #showOn:session:!public! !

