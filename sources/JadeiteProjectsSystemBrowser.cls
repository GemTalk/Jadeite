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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 2521 1511 551 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 10 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409288972 131137 608 nil 466 8 4278190080 nil 519 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 514 193 193 nil 608 466 688 8 4294909339 170 192 8 #() 170 192 34 6 27971 853766 ##(Smalltalk.ToolbarButton) 27971 nil 608 1 1180998 4 ##(Smalltalk.CommandDescription) #moveCardRight 8 'Move Card Right' 1 1 nil 657990 3 ##(Smalltalk.DIBSection) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'IdeaSpaceCardBar.bmp' nil nil 7 514 161 33 17 nil 3 27973 898 27973 nil 608 1 930 #closeCard 8 'Close Card' 1 1 nil 992 5 27969 898 27969 nil 608 1 930 #moveCardLeft 8 'Move Card Left' 1 1 nil 992 1 34 4 1050118 ##(Smalltalk.ToolbarSeparator) nil nil 608 3 nil 1 1120 912 1072 170 176 34 2 992 1 nil 1 nil 514 33 33 514 45 45 nil 656198 1 ##(Smalltalk.FlowLayout) 1 1 1 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 2329 1 514 161 51 608 1378 #updateSizePosted 848 608 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 140 4 0 0 0 0 0 0 220 4 0 0 25 0 0 0] 8 #() 514 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentRight -159 1586 #fixedViewLeft 161 1586 #fixedParentTop 1 1586 #fixedViewTop 51 410 ##(Smalltalk.TextEdit) 34 16 nil 416 34 2 8 1140850688 1 1664 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 466 8 4278190080 nil 7 nil 706 nil true 738 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 514 193 193 nil 1664 786694 ##(Smalltalk.IndexedColor) 33554433 8 4294908737 852486 ##(Smalltalk.NullConverter) nil 8 '' 67 1314 138 144 34 2 1378 #createAt:extent: 34 2 514 51 1351 514 2431 41 1664 1378 #setMarginWidths: 34 1 8 #(3 3) 1664 1474 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 25 0 0 0 163 2 0 0 216 4 0 0 183 2 0 0] 8 #() 1536 nil 27 1554 1586 #fixedParentLeft 51 1600 -7 1586 #fixedParentBottom -41 2224 -1 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 2240 nil 466 8 4278190080 nil 1031 nil nil nil 2240 655878 ##(Smalltalk.CardLayout) 138 144 848 nil 170 192 848 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 2240 34 2 8 1140916736 1 2400 590662 2 ##(Smalltalk.ListModel) 138 144 848 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) nil nil 1 nil nil nil 2400 nil 8 4294906973 787814 3 ##(Smalltalk.BlockClosure) 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 2576 7 257 nil 2562 0 nil 2594 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 2640 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #smallIcons nil nil nil nil nil 1314 138 144 34 2 1378 #createAt:extent: 34 2 514 1 1 514 2481 1291 2400 1378 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 2400 1474 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 216 4 0 0 133 2 0 0] 8 #() 1536 nil 27 1314 138 144 34 1 1378 #createAt:extent: 34 2 514 5 59 514 2481 1291 2240 1474 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 2 0 0 0 29 0 0 0 218 4 0 0 162 2 0 0] 34 1 2400 1536 nil 27 1554 2208 5 1600 -3 1632 59 2224 -43 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409288972 131137 3088 nil 466 8 4278190080 nil 519 nil 706 nil true 738 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 514 193 193 nil 3088 466 3168 8 4294909339 170 192 848 170 192 34 12 27963 898 27963 nil 3088 1 930 #addSystemBrowser 8 'Add System Browser' 1 1 nil 395334 3 ##(Smalltalk.Bitmap) nil true 1024 8 'Tools.bmp' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil nil 7 514 1857 33 17 27965 1115910 ##(Smalltalk.ToolbarIconButton) 27965 nil 3088 1 930 #maximizeCode 8 'Maximize Code' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1024 8 'Shell.ico' 3440 3378 nil true nil nil nil nil 3 514 33 33 1 27967 3490 27967 nil 3088 1 930 #jadeBrowseTests 8 'Open SUnit Browser' 1 1 3554 nil true 1024 8 'icons\UnitTestPlugin.ico' nil 3378 nil true nil nil nil nil 3 514 33 33 1 27957 898 27957 nil 3088 1 930 #abortTransaction 8 'Abort Transaction' 1 1 nil 3392 1 27959 898 27959 nil 3088 1 930 #commitTransaction 8 'Commit Transaction' 1 1 nil 3392 27 27961 1246982 ##(Smalltalk.ToolbarSystemButton) 27961 nil 3088 1 930 #addWorkspace 8 'Add Workspace' 1 1 nil 1 13 34 9 3744 3792 1186 nil nil 3088 3 nil 1 3856 3328 1186 nil nil 3088 3 nil 1 3504 1186 nil nil 3088 3 nil 1 3632 170 176 34 8 1 117 3392 1 3712 149 3600 147 nil 1 nil 514 33 33 514 45 45 nil 1282 1 1 1 1314 138 144 34 2 1378 #createAt:extent: 34 2 514 -1 1 514 2331 51 3088 1378 #updateSizePosted 848 3088 1474 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 140 4 0 0 25 0 0 0] 8 #() 1536 nil 27 1554 2208 -1 1600 -159 1632 1 1648 51 410 ##(Smalltalk.ToolButton) 34 14 nil 416 34 2 8 1140850688 131073 4240 nil 466 8 4278190080 nil 7 nil nil nil 4240 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 4240 34 2 8 1140853580 131137 4336 nil 4304 nil 3 nil nil nil 4336 4304 8 4294909339 nil 170 192 34 2 27975 3490 27975 nil 4336 1 930 #flipAutoCommit 8 'Auto Commit' 1 1 3554 nil true 1024 8 'icons/camera16_light_icon.ico' nil 3378 nil true nil nil nil nil 3 514 33 33 1 34 1 4448 170 176 34 12 3378 nil true nil nil nil nil 3 514 33 33 3 3378 nil true nil nil nil nil 3 514 33 33 5 3378 nil true nil nil nil nil 3 514 33 33 7 3378 nil true nil nil nil nil 3 514 33 33 1 3378 nil true nil nil nil nil 3 514 33 33 9 4528 11 nil 3 nil 514 33 33 514 37 33 nil nil 1314 138 144 34 2 1378 #createAt:extent: 34 2 514 1 1 514 47 43 4336 1378 #updateSizePosted 848 4336 1474 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 23 0 0 0 21 0 0 0] 8 #() 1536 nil 27 1314 138 144 34 1 1378 #createAt:extent: 34 2 514 1 1351 514 47 43 4240 1474 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 163 2 0 0 23 0 0 0 184 2 0 0] 34 1 4336 1536 nil 27 1554 2208 1 2208 47 2224 -41 2224 1 170 192 34 10 608 8 'rightToolbar' 1664 8 'statusBarField' 2240 8 'cardContainer' 3088 8 'leftToolbar' 4240 8 'autoCommitButton' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 1 265030 4 ##(Smalltalk.Menu) nil true 34 1 984134 2 ##(Smalltalk.CommandMenuItem) 1 930 #close 8 'Exit' 1025 1 nil nil nil 8 'Jade' nil 134217729 nil nil 27955 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1314 138 144 34 3 1378 #createAt:extent: 34 2 514 7679 21 514 2521 1511 416 1378 #text: 34 1 8 'Rowan System Browser' 416 1378 #updateMenuBar 848 416 1474 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 235 19 0 0 253 2 0 0] 34 5 3088 608 2240 1664 4240 1536 nil 27 )! !
!JadeiteProjectsSystemBrowser class categoriesFor: #resource_Default_view!public!resources-views! !

