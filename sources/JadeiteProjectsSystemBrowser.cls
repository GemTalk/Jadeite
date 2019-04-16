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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 2521 1511 551 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 10 410 ##(Smalltalk.TextEdit) 34 16 nil 416 34 2 8 1140850688 1 608 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 466 8 4278190080 nil 7 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 514 193 193 nil 608 786694 ##(Smalltalk.IndexedColor) 33554433 8 4294906663 852486 ##(Smalltalk.NullConverter) nil 8 '' 67 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 45 1349 514 2441 41 608 1026 #setMarginWidths: 34 1 8 #(3 3) 608 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 22 0 0 0 162 2 0 0 218 4 0 0 182 2 0 0] 8 #() 514 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 45 1266 #fixedParentRight -3 1266 #fixedParentBottom -43 1312 -3 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409288972 131137 1328 nil 466 8 4278190080 nil 519 nil 770 nil true 802 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 514 193 193 nil 1328 466 1408 8 4294906443 170 192 8 #() 170 192 34 6 39843 853766 ##(Smalltalk.ToolbarButton) 39843 nil 1328 1 1180998 4 ##(Smalltalk.CommandDescription) #moveCardLeft 8 'Move Card Left' 1 1 nil 657990 3 ##(Smalltalk.DIBSection) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'IdeaSpaceCardBar.bmp' nil nil 7 514 161 33 17 nil 1 39845 1586 39845 nil 1328 1 1618 #moveCardRight 8 'Move Card Right' 1 1 nil 1680 3 39847 1586 39847 nil 1328 1 1618 #closeCard 8 'Close Card' 1 1 nil 1680 5 34 4 1050118 ##(Smalltalk.ToolbarSeparator) nil nil 1328 3 nil 1 1600 1760 1808 170 176 34 2 1680 1 nil 1 nil 514 33 33 514 45 45 nil 656198 1 ##(Smalltalk.FlowLayout) 1 1 1 962 138 144 34 2 1026 #createAt:extent: 34 2 514 2329 1 514 161 51 1328 1026 #updateSizePosted 1536 1328 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 140 4 0 0 0 0 0 0 220 4 0 0 25 0 0 0] 8 #() 1216 nil 27 1234 1296 -159 1266 #fixedViewLeft 161 1266 #fixedParentTop 1 1266 #fixedViewTop 51 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409288972 131137 2240 nil 466 8 4278190080 nil 519 nil 770 nil true 802 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 514 193 193 nil 2240 466 2320 8 4294906443 170 192 1536 170 192 34 12 39831 1586 39831 nil 2240 1 1618 #abortTransaction 8 'Abort Transaction' 1 1 nil 395334 3 ##(Smalltalk.Bitmap) nil true 1712 8 'Tools.bmp' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil nil 7 514 1857 33 1 39833 1586 39833 nil 2240 1 1618 #commitTransaction 8 'Commit Transaction' 1 1 nil 2544 27 39835 1246982 ##(Smalltalk.ToolbarSystemButton) 39835 nil 2240 1 1618 #addWorkspace 8 'Add Workspace' 1 1 nil 1 13 39837 1586 39837 nil 2240 1 1618 #addSystemBrowser 8 'Add System Browser' 1 1 nil 2544 17 39839 1115910 ##(Smalltalk.ToolbarIconButton) 39839 nil 2240 1 1618 #maximizeCode 8 'Maximize Code' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1712 8 'Shell.ico' 2592 2530 nil true nil nil nil nil 3 514 33 33 1 39841 2802 39841 nil 2240 1 1618 #jadeBrowseTests 8 'Open SUnit Browser' 1 1 2866 nil true 1712 8 'icons\UnitTestPlugin.ico' nil 2530 nil true nil nil nil nil 3 514 33 33 1 34 9 2480 2640 1874 nil nil 2240 3 nil 1 2704 2752 1874 nil nil 2240 3 nil 1 2816 1874 nil nil 2240 3 nil 1 2944 170 176 34 8 1 117 2544 1 3024 149 2912 147 nil 1 nil 514 33 33 514 45 45 nil 1970 1 1 1 962 138 144 34 2 1026 #createAt:extent: 34 2 514 -1 1 514 2331 51 2240 1026 #updateSizePosted 1536 2240 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 140 4 0 0 25 0 0 0] 8 #() 1216 nil 27 1234 1280 -1 1296 -159 2208 1 2224 51 410 ##(Smalltalk.ToolButton) 34 14 nil 416 34 2 8 1140850688 131073 3392 nil 466 8 4278190080 nil 7 nil nil nil 3392 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 3392 34 2 8 1140853580 131137 3488 nil 3456 nil 3 nil nil nil 3488 3456 8 4294906443 nil 170 192 34 2 39849 2802 39849 nil 3488 1 1618 #flipAutoCommit 8 'Auto Commit' 1 1 2866 nil true 1712 8 'icons/camera16_light_icon.ico' nil 2530 nil true nil nil nil nil 3 514 33 33 1 34 1 3600 170 176 34 2 3680 1 nil 3 nil 514 33 33 514 37 33 nil nil 962 138 144 34 2 1026 #createAt:extent: 34 2 514 1 1 514 47 43 3488 1026 #updateSizePosted 1536 3488 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 23 0 0 0 21 0 0 0] 8 #() 1216 nil 27 962 138 144 34 2 1026 #createAt:extent: 34 2 514 1 1351 514 47 43 3392 1026 #isEnabled: 8 #(false) 3392 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 163 2 0 0 23 0 0 0 184 2 0 0] 34 1 3488 1216 nil 27 1234 1280 1 1280 47 1312 -41 1312 1 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 4176 nil 466 8 4278190080 nil 1031 nil nil nil 4176 655878 ##(Smalltalk.CardLayout) 138 144 1536 nil 170 192 1536 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 4176 34 2 8 1140916736 1 4336 590662 2 ##(Smalltalk.ListModel) 138 144 1536 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) nil nil 1 nil nil nil 4336 nil 8 4294910593 787814 3 ##(Smalltalk.BlockClosure) 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 4512 7 257 nil 4498 0 nil 4530 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 4576 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #smallIcons nil nil nil nil nil 962 138 144 34 2 1026 #createAt:extent: 34 2 514 1 1 514 2481 1291 4336 1026 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 4336 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 216 4 0 0 133 2 0 0] 8 #() 1216 nil 27 962 138 144 34 1 1026 #createAt:extent: 34 2 514 5 59 514 2481 1291 4176 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 2 0 0 0 29 0 0 0 218 4 0 0 162 2 0 0] 34 1 4336 1216 nil 27 1234 1280 5 1296 -3 2208 59 1312 -43 170 192 34 10 608 8 'statusBarField' 1328 8 'rightToolbar' 2240 8 'leftToolbar' 3392 8 'autoCommitButton' 4176 8 'cardContainer' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 1 265030 4 ##(Smalltalk.Menu) nil true 34 1 984134 2 ##(Smalltalk.CommandMenuItem) 1 1618 #close 8 'Exit' 1025 1 nil nil nil 8 'Jade' nil 134217729 nil nil 39829 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 962 138 144 34 3 1026 #createAt:extent: 34 2 514 7679 21 514 2521 1511 416 1026 #text: 34 1 8 'Rowan System Browser' 416 1026 #updateMenuBar 1536 416 1154 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 235 19 0 0 253 2 0 0] 34 5 2240 1328 4176 608 3392 1216 nil 27 )! !
!JadeiteProjectsSystemBrowser class categoriesFor: #resource_Default_view!public!resources-views! !

