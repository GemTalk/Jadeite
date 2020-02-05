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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 2521 1511 551 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409288972 131137 608 nil 466 8 4278190080 nil 519 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 514 193 193 nil 608 466 688 8 4294909093 170 192 8 #() 170 192 34 6 11763 853766 ##(Smalltalk.ToolbarButton) 11763 nil 608 1 1180998 4 ##(Smalltalk.CommandDescription) #moveCardLeft 8 'Move Card Left' 1 1 nil 657990 3 ##(Smalltalk.DIBSection) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'IdeaSpaceCardBar.bmp' nil nil 7 514 161 33 17 nil 1 11765 898 11765 nil 608 1 930 #moveCardRight 8 'Move Card Right' 1 1 nil 992 3 11767 898 11767 nil 608 1 930 #closeCard 8 'Close Card' 1 1 nil 992 5 34 4 1050118 ##(Smalltalk.ToolbarSeparator) nil nil 608 3 nil 1 912 1072 1120 170 176 34 2 992 1 nil 1 nil 514 33 33 514 45 45 nil 656198 1 ##(Smalltalk.FlowLayout) 1 1 1 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 2329 1 514 161 51 608 1378 #updateSizePosted 848 608 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 140 4 0 0 0 0 0 0 220 4 0 0 25 0 0 0] 8 #() 514 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentRight -159 1586 #fixedViewLeft 161 1586 #fixedParentTop 1 1586 #fixedViewTop 51 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 1664 nil 466 8 4278190080 nil 1031 nil nil nil 1664 655878 ##(Smalltalk.CardLayout) 138 144 848 nil 170 192 848 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 1664 34 2 8 1140916736 1 1824 590662 2 ##(Smalltalk.ListModel) 138 144 848 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) nil nil 1 nil nil nil 1824 nil 8 4294907483 787814 3 ##(Smalltalk.BlockClosure) 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 2000 7 257 nil 1986 0 nil 2018 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 2064 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #noIcons nil nil nil nil nil 1314 138 144 34 2 1378 #createAt:extent: 34 2 514 1 1 514 2481 1335 1824 1378 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 1824 1474 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 216 4 0 0 155 2 0 0] 8 #() 1536 nil 27 1314 138 144 34 1 1378 #createAt:extent: 34 2 514 5 59 514 2481 1335 1664 1474 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 2 0 0 0 29 0 0 0 218 4 0 0 184 2 0 0] 34 1 1824 1536 nil 27 1554 1586 #fixedParentLeft 5 1600 -3 1632 59 1586 #fixedParentBottom 1 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409288972 131137 2544 nil 466 8 4278190080 nil 519 nil 706 nil true 738 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 514 193 193 nil 2544 466 2624 8 4294909093 170 192 848 170 192 34 12 11751 898 11751 nil 2544 1 930 #abortTransaction 8 'Abort Transaction' 1 1 nil 395334 3 ##(Smalltalk.Bitmap) nil true 1024 8 'Tools.bmp' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil nil 7 514 1857 33 1 11753 898 11753 nil 2544 1 930 #commitTransaction 8 'Commit Transaction' 1 1 nil 2848 27 11755 1246982 ##(Smalltalk.ToolbarSystemButton) 11755 nil 2544 1 930 #addWorkspace 8 'Add Workspace' 1 1 nil 1 13 11757 898 11757 nil 2544 1 930 #addSystemBrowser 8 'Add System Browser' 1 1 nil 2848 17 11759 1115910 ##(Smalltalk.ToolbarIconButton) 11759 nil 2544 1 930 #maximizeCode 8 'Maximize Code' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1024 8 'Shell.ico' 2896 2834 nil true nil nil nil nil 3 514 33 33 1 11761 3106 11761 nil 2544 1 930 #jadeBrowseTests 8 'Open SUnit Browser' 1 1 3170 nil true 1024 8 'icons\UnitTestPlugin.ico' nil 2834 nil true nil nil nil nil 3 514 33 33 1 34 9 2784 2944 1186 nil nil 2544 3 nil 1 3008 3056 1186 nil nil 2544 3 nil 1 3120 1186 nil nil 2544 3 nil 1 3248 170 176 34 8 1 117 2848 1 3328 149 3216 147 nil 1 nil 514 33 33 514 45 45 nil 1282 1 1 1 1314 138 144 34 2 1378 #createAt:extent: 34 2 514 -1 1 514 2331 51 2544 1378 #updateSizePosted 848 2544 1474 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 140 4 0 0 25 0 0 0] 8 #() 1536 nil 27 1554 2512 -1 1600 -159 1632 1 1648 51 170 192 34 6 608 8 'rightToolbar' 1664 8 'cardContainer' 2544 8 'leftToolbar' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 1 265030 4 ##(Smalltalk.Menu) nil true 34 1 984134 2 ##(Smalltalk.CommandMenuItem) 1 930 #close 8 'Exit' 1025 1 nil nil nil 8 'Jade' nil 134217729 nil nil 11749 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1314 138 144 34 3 1378 #createAt:extent: 34 2 514 7679 21 514 2521 1511 416 1378 #text: 34 1 8 'Rowan System Browser' 416 1378 #updateMenuBar 848 416 1474 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 235 19 0 0 253 2 0 0] 34 3 2544 608 1664 1536 nil 27 )! !
!JadeiteProjectsSystemBrowser class categoriesFor: #resource_Default_view!public!resources-views! !

