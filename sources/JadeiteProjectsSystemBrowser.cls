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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 2521 1511 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409288972 131137 592 nil 480 nil 519 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 498 193 193 nil 592 480 8 1650109728 170 192 8 #() 170 192 34 12 14091 1115206 1 ##(Smalltalk.ToolbarIconButton) 592 1 1180998 4 ##(Smalltalk.CommandDescription) #maximizeCode 8 'Maximize Code' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'Shell.ico' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil 14091 14087 1246790 1 ##(Smalltalk.ToolbarSystemButton) 592 1 866 #addWorkspace 8 'Add Workspace' 1 1 nil 14087 1 13 14083 1246790 1 ##(Smalltalk.ToolbarBitmapButton) 592 1 866 #abortTransaction 8 'Abort Transaction' 1 1 nil 14083 395334 3 ##(Smalltalk.Bitmap) nil true 960 8 'Tools.bmp' 1008 nil 7 498 1857 33 1 14093 834 592 1 866 #jadeBrowseTests 8 'Open SUnit Browser' 1 1 914 nil true 960 8 'icons\UnitTestPlugin.ico' nil 14093 14089 1106 592 1 866 #addSystemBrowser 8 'Add System Browser' 1 1 nil 14089 1184 17 14085 1106 592 1 866 #commitTransaction 8 'Commit Transaction' 1 1 nil 14085 1184 27 34 9 1120 1360 1049158 1 ##(Smalltalk.ToolbarSeparator) 592 1 1056 1312 1426 592 1 848 1426 592 1 1232 nil nil 1 nil 498 33 33 498 45 45 nil 656198 1 ##(Smalltalk.FlowLayout) 1 1 1 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 -1 1 498 2331 51 592 1618 #updateSizePosted 784 592 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 140 4 0 0 25 0 0 0] 8 #() 498 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft -1 1826 #fixedParentRight -159 1826 #fixedParentTop 1 1826 #fixedViewTop 51 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 1904 nil 480 nil 1031 nil nil nil 1904 655878 ##(Smalltalk.CardLayout) 138 144 784 nil 170 192 784 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 1904 34 2 8 1140916736 1 2032 590662 2 ##(Smalltalk.ListModel) 138 144 784 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) nil nil 1 nil nil nil 2032 nil 8 1650396656 787814 3 ##(Smalltalk.BlockClosure) 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 2208 7 257 nil 2194 0 nil 2226 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 2272 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #smallIcons nil nil nil nil nil 1554 138 144 34 2 1618 #createAt:extent: 34 2 498 1 1 498 2481 1335 2032 1618 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 2032 1714 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 216 4 0 0 155 2 0 0] 8 #() 1776 nil 27 1554 138 144 34 1 1618 #createAt:extent: 34 2 498 5 59 498 2481 1335 1904 1714 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 2 0 0 0 29 0 0 0 218 4 0 0 184 2 0 0] 34 1 2032 1776 nil 27 1794 1840 5 1856 -3 1872 59 1826 #fixedParentBottom 1 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409288972 131137 2736 nil 480 nil 519 nil 658 nil true 690 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 498 193 193 nil 2736 480 8 1650109728 170 192 784 170 192 34 6 14099 1106 2736 1 866 #closeCard 8 'Close Card' 1 1 nil 14099 657990 3 ##(Smalltalk.DIBSection) nil true 960 8 'icons\IdeaSpaceCardBar.bmp' nil nil 7 498 161 33 17 nil 5 14097 1106 2736 1 866 #moveCardRight 8 'Move Card Right' 1 1 nil 14097 2992 3 14095 1106 2736 1 866 #moveCardLeft 8 'Move Card Left' 1 1 nil 14095 2992 1 34 4 1426 2736 1 3088 3040 2928 nil nil 1 nil 498 33 33 498 45 45 nil 1522 1 1 1 1554 138 144 34 2 1618 #createAt:extent: 34 2 498 2329 1 498 161 51 2736 1618 #updateSizePosted 784 2736 1714 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 140 4 0 0 0 0 0 0 220 4 0 0 25 0 0 0] 8 #() 1776 nil 27 1794 1856 -159 1826 #fixedViewLeft 161 1872 1 1888 51 170 192 34 6 592 8 'leftToolbar' 1904 8 'cardContainer' 2736 8 'rightToolbar' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 1 265030 4 ##(Smalltalk.Menu) nil true 34 1 984134 2 ##(Smalltalk.CommandMenuItem) 1 866 #close 8 'Exit' 1025 1 nil nil nil 8 'Jade' nil 134217729 nil nil 14081 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1554 138 144 34 3 1618 #createAt:extent: 34 2 498 7679 21 498 2521 1511 416 1618 #text: 34 1 8 'Rowan System Browser' 416 1618 #updateMenuBar 784 416 1714 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 235 19 0 0 253 2 0 0] 34 3 592 1904 2736 1776 nil 27 )! !
!JadeiteProjectsSystemBrowser class categoriesFor: #resource_Default_view!public!resources-views! !

