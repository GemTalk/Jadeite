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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 2521 1511 551 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 608 nil 466 8 4278190080 nil 1031 nil nil nil 608 655878 ##(Smalltalk.CardLayout) 138 144 8 #() nil 170 192 752 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 608 34 2 8 1140916736 1 784 590662 2 ##(Smalltalk.ListModel) 138 144 752 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) nil nil 1 nil nil nil 784 nil 8 4294901947 787814 3 ##(Smalltalk.BlockClosure) 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 960 7 257 nil 946 0 nil 978 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 1024 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #noIcons nil nil nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 1 1 514 2481 1335 784 1170 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 784 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 216 4 0 0 155 2 0 0] 8 #() 514 193 193 nil 27 1106 138 144 34 1 1170 #createAt:extent: 34 2 514 5 59 514 2481 1335 608 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 2 0 0 0 29 0 0 0 218 4 0 0 184 2 0 0] 34 1 784 1344 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 5 1554 #fixedParentRight -3 1554 #fixedParentTop 59 1554 #fixedParentBottom 1 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409288972 131137 1632 nil 466 8 4278190080 nil 519 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 514 193 193 nil 1632 466 1712 8 4294902389 170 192 752 170 192 34 6 10041 853766 ##(Smalltalk.ToolbarButton) 10041 nil 1632 1 1180998 4 ##(Smalltalk.CommandDescription) #moveCardRight 8 'Move Card Right' 1 1 nil 657990 3 ##(Smalltalk.DIBSection) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'IdeaSpaceCardBar.bmp' nil nil 7 514 161 33 17 nil 3 10043 1906 10043 nil 1632 1 1938 #closeCard 8 'Close Card' 1 1 nil 2000 5 10039 1906 10039 nil 1632 1 1938 #moveCardLeft 8 'Move Card Left' 1 1 nil 2000 1 34 4 1050118 ##(Smalltalk.ToolbarSeparator) nil nil 1632 3 nil 1 2128 1920 2080 170 176 34 2 2000 1 nil 1 nil 514 33 33 514 45 45 nil 656198 1 ##(Smalltalk.FlowLayout) 1 1 1 1106 138 144 34 2 1170 #createAt:extent: 34 2 514 2329 1 514 161 51 1632 1170 #updateSizePosted 752 1632 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 140 4 0 0 0 0 0 0 220 4 0 0 25 0 0 0] 8 #() 1344 nil 27 1522 1584 -159 1554 #fixedViewLeft 161 1600 1 1554 #fixedViewTop 51 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409288972 131137 2544 nil 466 8 4278190080 nil 519 nil 1730 nil true 1762 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 514 193 193 nil 2544 466 2624 8 4294902389 170 192 752 170 192 34 12 10033 1906 10033 nil 2544 1 1938 #addSystemBrowser 8 'Add System Browser' 1 1 nil 395334 3 ##(Smalltalk.Bitmap) nil true 2032 8 'Tools.bmp' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil nil 7 514 1857 33 17 10035 1115910 ##(Smalltalk.ToolbarIconButton) 10035 nil 2544 1 1938 #maximizeCode 8 'Maximize Code' 1 1 263494 3 ##(Smalltalk.Icon) nil true 2032 8 'Shell.ico' 2896 2834 nil true nil nil nil nil 3 514 33 33 1 10037 2946 10037 nil 2544 1 1938 #jadeBrowseTests 8 'Open SUnit Browser' 1 1 3010 nil true 2032 8 'icons\UnitTestPlugin.ico' nil 2834 nil true nil nil nil nil 3 514 33 33 1 10027 1906 10027 nil 2544 1 1938 #abortTransaction 8 'Abort Transaction' 1 1 nil 2848 1 10029 1906 10029 nil 2544 1 1938 #commitTransaction 8 'Commit Transaction' 1 1 nil 2848 27 10031 1246982 ##(Smalltalk.ToolbarSystemButton) 10031 nil 2544 1 1938 #addWorkspace 8 'Add Workspace' 1 1 nil 1 13 34 9 3200 3248 2194 nil nil 2544 3 nil 1 3312 2784 2194 nil nil 2544 3 nil 1 2960 2194 nil nil 2544 3 nil 1 3088 170 176 34 8 1 117 2848 1 3168 149 3056 147 nil 1 nil 514 33 33 514 45 45 nil 2290 1 1 1 1106 138 144 34 2 1170 #createAt:extent: 34 2 514 -1 1 514 2331 51 2544 1170 #updateSizePosted 752 2544 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 140 4 0 0 25 0 0 0] 8 #() 1344 nil 27 1522 1568 -1 1584 -159 1600 1 2528 51 170 192 34 6 608 8 'cardContainer' 1632 8 'rightToolbar' 2544 8 'leftToolbar' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 1 265030 4 ##(Smalltalk.Menu) nil true 34 1 984134 2 ##(Smalltalk.CommandMenuItem) 1 1938 #close 8 'Exit' 1025 1 nil nil nil 8 'Jade' nil 134217729 nil nil 10025 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1106 138 144 34 3 1170 #createAt:extent: 34 2 514 7679 21 514 2521 1511 416 1170 #text: 34 1 8 'Rowan System Browser' 416 1170 #updateMenuBar 752 416 1282 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 235 19 0 0 253 2 0 0] 34 3 2544 1632 608 1344 nil 27 )! !
!JadeiteProjectsSystemBrowser class categoriesFor: #resource_Default_view!public!resources-views! !

