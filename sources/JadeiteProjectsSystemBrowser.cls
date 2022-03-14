"Filed out from Dolphin Smallalk"!

RowanSystemBrowser subclass: #JadeiteProjectsSystemBrowser
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteProjectsSystemBrowser guid: (GUID fromString: '{8b442830-2c48-4a43-aff6-375f4d49530d}')!
JadeiteProjectsSystemBrowser comment: ''!
!JadeiteProjectsSystemBrowser categoriesForClass!Unclassified! !
!JadeiteProjectsSystemBrowser methodsFor!

addSystemBrowser
	self addSystemBrowserWithLayoutInfo: nil!

addSystemBrowserWithLayoutInfo: each
	| presenter |
	self rowanFixMe. "ignore layout info. Roll our own later"
	presenter := (self systemBrowserPresenter createIn: cardsPresenter gciSession: gciSession).
	presenter updateTabLabel.
	presenter ensureVisible.
	
!

cardsPresenter

	^cardsPresenter
!

commitTransaction
	| commitResult |
	commitResult := super commitTransaction.
	commitResult ifTrue: [self currentCard refreshFromServer].
	^commitResult!

layoutFilePath

	^SessionManager current imageBase , 'Rowan System Browser Layout.stb'!

shellName

	^'Projects Browser'.
!

systemBrowserPresenter
	^JadeiteProjectsBrowserPresenter! !
!JadeiteProjectsSystemBrowser categoriesForMethods!
addSystemBrowser!layout!public! !
addSystemBrowserWithLayoutInfo:!layout!public! !
cardsPresenter!layout!public! !
commitTransaction!public! !
layoutFilePath!layout!public! !
shellName!overrides!private! !
systemBrowserPresenter!public! !
!

!JadeiteProjectsSystemBrowser class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 3001 1601 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409288972 131137 592 nil 480 nil 519 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 498 193 193 nil 592 480 8 1591782784 170 192 8 #() 170 192 34 12 16967 1115206 1 ##(Smalltalk.ToolbarIconButton) 592 1 1180998 4 ##(Smalltalk.CommandDescription) #jadeBrowseTests 8 'Open SUnit Browser' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons\UnitTestPlugin.ico' nil 16967 16963 1246790 1 ##(Smalltalk.ToolbarBitmapButton) 592 1 866 #addSystemBrowser 8 'Add System Browser' 1 1 nil 16963 395334 3 ##(Smalltalk.Bitmap) nil true 960 8 'Tools.bmp' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil nil 7 498 1857 33 17 16959 994 592 1 866 #commitTransaction 8 'Commit Transaction' 1 1 nil 16959 1072 27 16965 834 592 1 866 #maximizeCode 8 'Maximize Code' 1 1 914 nil true 960 8 'Shell.ico' 1120 16965 16961 1246790 1 ##(Smalltalk.ToolbarSystemButton) 592 1 866 #addWorkspace 8 'Add Workspace' 1 1 nil 16961 1 13 16957 994 592 1 866 #abortTransaction 8 'Abort Transaction' 1 1 nil 16957 1072 1 34 9 1360 1168 1049158 1 ##(Smalltalk.ToolbarSeparator) 592 1 1312 1008 1426 592 1 1216 1426 592 1 848 nil nil 1 nil 498 33 33 498 45 45 nil 656198 1 ##(Smalltalk.FlowLayout) 1 1 1 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 -1 1 498 2811 51 592 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 124 5 0 0 25 0 0 0] 8 #() 498 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft -1 1810 #fixedParentRight -159 1810 #fixedParentTop 1 1810 #fixedViewTop 51 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 1888 nil 480 nil 1031 nil nil nil 1888 656710 1 ##(Smalltalk.CardLayout) 138 144 784 nil nil nil nil 170 192 784 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 1888 34 2 8 1140916736 1 2016 590662 2 ##(Smalltalk.ListModel) 138 144 784 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) nil nil 1 nil nil nil 2016 nil 8 1591529216 787814 3 ##(Smalltalk.BlockClosure) 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 2192 7 257 nil 2178 0 nil 2210 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 2256 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #smallIcons nil nil nil nil nil 1554 138 144 34 2 1618 #createAt:extent: 34 2 498 1 1 498 2961 1425 2016 1618 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 2016 1698 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 200 5 0 0 200 2 0 0] 8 #() 1760 nil 27 1554 138 144 34 1 1618 #createAt:extent: 34 2 498 5 59 498 2961 1425 1888 1698 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 2 0 0 0 29 0 0 0 202 5 0 0 229 2 0 0] 34 1 2016 1760 nil 27 1778 1824 5 1840 -3 1856 59 1810 #fixedParentBottom 1 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409288972 131137 2720 nil 480 nil 519 nil 658 nil true 690 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 498 193 193 nil 2720 480 8 1591782784 170 192 784 170 192 34 6 16969 994 2720 1 866 #moveCardLeft 8 'Move Card Left' 1 1 nil 16969 657990 3 ##(Smalltalk.DIBSection) nil true 960 8 'icons\IdeaSpaceCardBar.bmp' nil nil 7 498 161 33 17 nil 1 16973 994 2720 1 866 #closeCard 8 'Close Card' 1 1 nil 16973 2976 5 16971 994 2720 1 866 #moveCardRight 8 'Move Card Right' 1 1 nil 16971 2976 3 34 4 1426 2720 1 2912 3072 3024 nil nil 1 nil 498 33 33 498 45 45 nil 1522 1 1 1 1554 138 144 34 1 1618 #createAt:extent: 34 2 498 2809 1 498 161 51 2720 1698 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 124 5 0 0 0 0 0 0 204 5 0 0 25 0 0 0] 8 #() 1760 nil 27 1778 1840 -159 1810 #fixedViewLeft 161 1856 1 1872 51 170 192 34 6 592 8 'leftToolbar' 1888 8 'cardContainer' 2720 8 'rightToolbar' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 1 265030 4 ##(Smalltalk.Menu) nil true 34 1 984134 2 ##(Smalltalk.CommandMenuItem) 1 866 #close 8 'Exit' 1025 1 nil nil nil 8 'Jade' nil 134217729 nil nil 16977 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1554 138 144 34 2 1618 #createAt:extent: 34 2 498 6517 21 498 3001 1601 416 1618 #text: 34 1 8 'Rowan System Browser' 416 1698 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 186 12 0 0 10 0 0 0 150 18 0 0 42 3 0 0] 34 3 592 1888 2720 1760 nil 27 )! !
!JadeiteProjectsSystemBrowser class categoriesForMethods!
resource_Default_view!public!resources-views! !
!

