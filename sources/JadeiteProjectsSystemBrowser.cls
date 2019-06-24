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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 2521 1511 551 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 10 410 ##(Smalltalk.ToolButton) 34 14 nil 416 34 2 8 1140850688 131073 608 nil 466 8 4278190080 nil 7 nil nil nil 608 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 608 34 2 8 1140853580 131137 704 nil 672 nil 3 nil nil nil 704 672 8 4294902665 nil 170 192 34 2 20509 1115910 ##(Smalltalk.ToolbarIconButton) 20509 nil 704 1 1180998 4 ##(Smalltalk.CommandDescription) #flipAutoCommit 8 'Auto Commit' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons/camera16_light_icon.ico' nil 395334 3 ##(Smalltalk.Bitmap) nil true nil nil nil nil 3 514 33 33 1 34 1 832 170 176 34 2 992 1 nil 3 nil 514 33 33 514 37 33 nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 1 1 514 47 43 704 1170 #updateSizePosted 8 #() 704 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 23 0 0 0 21 0 0 0] 8 #() 514 193 193 nil 27 1106 138 144 34 2 1170 #createAt:extent: 34 2 514 1 1351 514 47 43 608 1170 #isEnabled: 8 #(false) 608 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 163 2 0 0 23 0 0 0 184 2 0 0] 34 1 704 1344 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 1600 47 1586 #fixedParentBottom -41 1616 1 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409288972 131137 1632 nil 466 8 4278190080 nil 519 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 514 193 193 nil 1632 466 1712 8 4294902665 170 192 1264 170 192 34 6 20503 853766 ##(Smalltalk.ToolbarButton) 20503 nil 1632 1 850 #moveCardLeft 8 'Move Card Left' 1 1 nil 657990 3 ##(Smalltalk.DIBSection) nil true 944 8 'IdeaSpaceCardBar.bmp' nil nil 7 514 161 33 17 nil 1 20505 1906 20505 nil 1632 1 850 #moveCardRight 8 'Move Card Right' 1 1 nil 1984 3 20507 1906 20507 nil 1632 1 850 #closeCard 8 'Close Card' 1 1 nil 1984 5 34 4 1050118 ##(Smalltalk.ToolbarSeparator) nil nil 1632 3 nil 1 1920 2032 2080 170 176 34 2 1984 1 nil 1 nil 514 33 33 514 45 45 nil 656198 1 ##(Smalltalk.FlowLayout) 1 1 1 1106 138 144 34 2 1170 #createAt:extent: 34 2 514 2329 1 514 161 51 1632 1170 #updateSizePosted 1264 1632 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 140 4 0 0 0 0 0 0 220 4 0 0 25 0 0 0] 8 #() 1344 nil 27 1554 1586 #fixedParentRight -159 1586 #fixedViewLeft 161 1586 #fixedParentTop 1 1586 #fixedViewTop 51 410 ##(Smalltalk.TextEdit) 34 16 nil 416 34 2 8 1140850688 1 2528 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 466 8 4278190080 nil 7 nil 1730 nil true 1762 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 514 193 193 nil 2528 786694 ##(Smalltalk.IndexedColor) 33554433 8 4294902529 852486 ##(Smalltalk.NullConverter) nil 8 '' 67 1106 138 144 34 2 1170 #createAt:extent: 34 2 514 51 1351 514 2431 41 2528 1170 #setMarginWidths: 34 1 8 #(3 3) 2528 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 25 0 0 0 163 2 0 0 216 4 0 0 183 2 0 0] 8 #() 1344 nil 27 1554 1600 51 2464 -7 1616 -41 1616 -1 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 3072 nil 466 8 4278190080 nil 1031 nil nil nil 3072 655878 ##(Smalltalk.CardLayout) 138 144 1264 nil 170 192 1264 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 3072 34 2 8 1140916736 1 3232 590662 2 ##(Smalltalk.ListModel) 138 144 1264 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) nil nil 1 nil nil nil 3232 nil 8 4294903103 787814 3 ##(Smalltalk.BlockClosure) 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 3408 7 257 nil 3394 0 nil 3426 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 3472 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #noIcons nil nil nil nil nil 1106 138 144 34 2 1170 #createAt:extent: 34 2 514 1 1 514 2481 1291 3232 1170 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 3232 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 216 4 0 0 133 2 0 0] 8 #() 1344 nil 27 1106 138 144 34 1 1170 #createAt:extent: 34 2 514 5 59 514 2481 1291 3072 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 2 0 0 0 29 0 0 0 218 4 0 0 162 2 0 0] 34 1 3232 1344 nil 27 1554 1600 5 2464 -3 2496 59 1616 -43 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409288972 131137 3920 nil 466 8 4278190080 nil 519 nil 1730 nil true 1762 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 514 193 193 nil 3920 466 4000 8 4294902665 170 192 1264 170 192 34 12 20491 1906 20491 nil 3920 1 850 #abortTransaction 8 'Abort Transaction' 1 1 nil 978 nil true 944 8 'Tools.bmp' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil nil 7 514 1857 33 1 20493 1906 20493 nil 3920 1 850 #commitTransaction 8 'Commit Transaction' 1 1 nil 4208 27 20495 1246982 ##(Smalltalk.ToolbarSystemButton) 20495 nil 3920 1 850 #addWorkspace 8 'Add Workspace' 1 1 nil 1 13 20497 1906 20497 nil 3920 1 850 #addSystemBrowser 8 'Add System Browser' 1 1 nil 4208 17 20499 818 20499 nil 3920 1 850 #maximizeCode 8 'Maximize Code' 1 1 898 nil true 944 8 'Shell.ico' 4256 978 nil true nil nil nil nil 3 514 33 33 1 20501 818 20501 nil 3920 1 850 #jadeBrowseTests 8 'Open SUnit Browser' 1 1 898 nil true 944 8 'icons\UnitTestPlugin.ico' nil 978 nil true nil nil nil nil 3 514 33 33 1 34 9 4160 4304 2146 nil nil 3920 3 nil 1 4368 4416 2146 nil nil 3920 3 nil 1 4464 2146 nil nil 3920 3 nil 1 4576 170 176 34 8 1 117 4208 1 4656 149 4544 147 nil 1 nil 514 33 33 514 45 45 nil 2242 1 1 1 1106 138 144 34 2 1170 #createAt:extent: 34 2 514 -1 1 514 2331 51 3920 1170 #updateSizePosted 1264 3920 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 140 4 0 0 25 0 0 0] 8 #() 1344 nil 27 1554 1600 -1 2464 -159 2496 1 2512 51 170 192 34 10 608 8 'autoCommitButton' 1632 8 'rightToolbar' 2528 8 'statusBarField' 3072 8 'cardContainer' 3920 8 'leftToolbar' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 1 265030 4 ##(Smalltalk.Menu) nil true 34 1 984134 2 ##(Smalltalk.CommandMenuItem) 1 850 #close 8 'Exit' 1025 1 nil nil nil 8 'Jade' nil 134217729 nil nil 20489 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1106 138 144 34 3 1170 #createAt:extent: 34 2 514 7679 21 514 2521 1511 416 1170 #text: 34 1 8 'Rowan System Browser' 416 1170 #updateMenuBar 1264 416 1282 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 235 19 0 0 253 2 0 0] 34 5 3920 1632 3072 2528 608 1344 nil 27 )! !
!JadeiteProjectsSystemBrowser class categoriesFor: #resource_Default_view!public!resources-views! !

