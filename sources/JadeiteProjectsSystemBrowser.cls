"Filed out from Dolphin Smalltalk 7"!

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
!JadeiteProjectsSystemBrowser categoriesFor: #addSystemBrowser!layout!public! !
!JadeiteProjectsSystemBrowser categoriesFor: #addSystemBrowserWithLayoutInfo:!layout!public! !
!JadeiteProjectsSystemBrowser categoriesFor: #cardsPresenter!layout!public! !
!JadeiteProjectsSystemBrowser categoriesFor: #commitTransaction!public! !
!JadeiteProjectsSystemBrowser categoriesFor: #layoutFilePath!layout!public! !
!JadeiteProjectsSystemBrowser categoriesFor: #shellName!overrides!private! !
!JadeiteProjectsSystemBrowser categoriesFor: #systemBrowserPresenter!public! !

!JadeiteProjectsSystemBrowser class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 2521 1511 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 592 nil 480 nil 1031 nil nil nil 592 655878 ##(Smalltalk.CardLayout) 138 144 8 #() nil 170 192 704 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 592 34 2 8 1140916736 1 736 590662 2 ##(Smalltalk.ListModel) 138 144 704 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) nil nil 1 nil nil nil 736 nil 8 1660489200 787814 3 ##(Smalltalk.BlockClosure) 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 912 7 257 nil 898 0 nil 930 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 976 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #noIcons nil nil nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 1 1 498 2481 1335 736 1122 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 736 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 216 4 0 0 155 2 0 0] 8 #() 498 193 193 nil 27 1058 138 144 34 1 1122 #createAt:extent: 34 2 498 5 59 498 2481 1335 592 1234 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 2 0 0 0 29 0 0 0 218 4 0 0 184 2 0 0] 34 1 736 1296 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 5 1506 #fixedParentRight -3 1506 #fixedParentTop 59 1506 #fixedParentBottom 1 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409288972 131137 1584 nil 480 nil 519 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 498 193 193 nil 1584 480 8 1660202272 170 192 704 170 192 34 6 45555 1246790 1 ##(Smalltalk.ToolbarBitmapButton) 1584 1 1180998 4 ##(Smalltalk.CommandDescription) #moveCardLeft 8 'Move Card Left' 1 1 nil 45555 657990 3 ##(Smalltalk.DIBSection) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons\IdeaSpaceCardBar.bmp' nil nil 7 498 161 33 65 nil 1 45559 1810 1584 1 1842 #closeCard 8 'Close Card' 1 1 nil 45559 1904 5 45557 1810 1584 1 1842 #moveCardRight 8 'Move Card Right' 1 1 nil 45557 1904 3 34 4 1049158 1 ##(Smalltalk.ToolbarSeparator) 1584 1 1824 2032 1984 nil nil 1 nil 498 33 33 498 45 45 nil 656198 1 ##(Smalltalk.FlowLayout) 1 1 1 1058 138 144 34 2 1122 #createAt:extent: 34 2 498 2329 1 498 161 51 1584 1122 #updateSizePosted 704 1584 1234 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 140 4 0 0 0 0 0 0 220 4 0 0 25 0 0 0] 8 #() 1296 nil 27 1474 1536 -159 1506 #fixedViewLeft 161 1552 1 1506 #fixedViewTop 51 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409288972 131137 2416 nil 480 nil 519 nil 1650 nil true 1682 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 498 193 193 nil 2416 480 8 1660202272 170 192 704 170 192 34 12 45543 1810 2416 1 1842 #abortTransaction 8 'Abort Transaction' 1 1 nil 45543 395334 3 ##(Smalltalk.Bitmap) nil true 1936 8 'Tools.bmp' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil nil 7 498 1857 33 1 45553 1115206 1 ##(Smalltalk.ToolbarIconButton) 2416 1 1842 #jadeBrowseTests 8 'Open SUnit Browser' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1936 8 'icons\UnitTestPlugin.ico' nil 45553 45549 1810 2416 1 1842 #addSystemBrowser 8 'Add System Browser' 1 1 nil 45549 2672 17 45545 1810 2416 1 1842 #commitTransaction 8 'Commit Transaction' 1 1 nil 45545 2672 27 45551 2770 2416 1 1842 #maximizeCode 8 'Maximize Code' 1 1 2834 nil true 1936 8 'Shell.ico' 2720 45551 45547 1246790 1 ##(Smalltalk.ToolbarSystemButton) 2416 1 1842 #addWorkspace 8 'Add Workspace' 1 1 nil 45547 1 13 34 9 2608 2928 2098 2416 1 3072 2880 2098 2416 1 2976 2098 2416 1 2784 nil nil 1 nil 498 33 33 498 45 45 nil 2162 1 1 1 1058 138 144 34 2 1122 #createAt:extent: 34 2 498 -1 1 498 2331 51 2416 1122 #updateSizePosted 704 2416 1234 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 140 4 0 0 25 0 0 0] 8 #() 1296 nil 27 1474 1520 -1 1536 -159 1552 1 2400 51 170 192 34 6 592 8 'cardContainer' 1584 8 'rightToolbar' 2416 8 'leftToolbar' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 1 265030 4 ##(Smalltalk.Menu) nil true 34 1 984134 2 ##(Smalltalk.CommandMenuItem) 1 1842 #close 8 'Exit' 1025 1 nil nil nil 8 'Jade' nil 134217729 nil nil 45541 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1058 138 144 34 3 1122 #createAt:extent: 34 2 498 7679 21 498 2521 1511 416 1122 #text: 34 1 8 'Rowan System Browser' 416 1122 #updateMenuBar 704 416 1234 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 235 19 0 0 253 2 0 0] 34 3 2416 592 1584 1296 nil 27 )! !
!JadeiteProjectsSystemBrowser class categoriesFor: #resource_Default_view!public!resources-views! !

