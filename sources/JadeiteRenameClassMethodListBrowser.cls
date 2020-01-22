"Filed out from Dolphin Smalltalk 7"!

JadeiteMethodListBrowser subclass: #JadeiteRenameClassMethodListBrowser
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteRenameClassMethodListBrowser guid: (GUID fromString: '{d454656d-41bf-4d2c-9ef4-92244eff7660}')!
JadeiteRenameClassMethodListBrowser comment: ''!
!JadeiteRenameClassMethodListBrowser categoriesForClass!Unclassified! !
!JadeiteRenameClassMethodListBrowser methodsFor!

presenterClass
	^JadeiteRenameClassMethodListPresenter! !
!JadeiteRenameClassMethodListBrowser categoriesFor: #presenterClass!private! !

!JadeiteRenameClassMethodListBrowser class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 1601 1201 551 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.TextEdit) 34 16 nil 416 34 2 8 1140850688 1 608 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 466 8 4278190080 nil 7 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 514 193 193 nil 608 nil 8 4294907459 852486 ##(Smalltalk.NullConverter) nil 8 '' 1 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 49 1039 514 1521 41 608 994 #isEnabled: 8 #(false) 608 994 #setMarginWidths: 34 1 8 #(3 3) 608 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 24 0 0 0 7 2 0 0 16 3 0 0 27 2 0 0] 8 #() 514 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 49 1266 #fixedParentRight 1 1266 #fixedPreviousBottom 1 1266 #fixedParentBottom -3 410 ##(Smalltalk.ReferenceView) 34 14 nil 416 34 2 8 1140850688 131073 1344 nil nil nil 7 nil nil nil 1344 1180166 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteRenameClassMethodListPresenter) #resource_Default_view nil 930 138 144 34 1 994 #createAt:extent: 34 2 514 5 1 514 1565 1039 1344 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 2 0 0 0 0 0 0 0 16 3 0 0 7 2 0 0] 8 #() 1216 nil 27 1234 1280 5 1296 1 1266 #fixedParentTop 1 1328 -43 410 ##(Smalltalk.ToolButton) 34 14 nil 416 34 2 8 1140850688 131073 1632 nil 466 8 4278190080 nil 7 nil nil nil 1632 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 1632 34 2 8 1140853580 131137 1728 nil 1696 nil 3 nil nil nil 1728 1696 8 4294903825 nil 170 192 34 2 26691 1115910 ##(Smalltalk.ToolbarIconButton) 26691 nil 1728 1 1180998 4 ##(Smalltalk.CommandDescription) #flipAutoCommit 8 'Auto Commit' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons/camera16_light_icon.ico' nil 395334 3 ##(Smalltalk.Bitmap) nil true nil nil nil nil 3 514 33 33 1 34 1 1856 170 176 34 2 2016 1 nil 3 nil 514 33 33 514 39 35 nil nil 930 138 144 34 2 994 #createAt:extent: 34 2 514 1 1 514 49 45 1728 994 #updateSizePosted 1584 1728 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 24 0 0 0 22 0 0 0] 8 #() 1216 nil 27 930 138 144 34 2 994 #createAt:extent: 34 2 514 1 1039 514 49 45 1632 994 #isEnabled: 8 #(false) 1632 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 7 2 0 0 24 0 0 0 29 2 0 0] 34 1 1728 1216 nil 27 1234 1280 1 1280 49 1328 -43 1328 1 170 192 34 4 608 8 'statusBarField' 1632 8 'autoCommitButton' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 1 265030 4 ##(Smalltalk.Menu) nil true 34 7 984134 2 ##(Smalltalk.CommandMenuItem) 1 1874 #editSaveMethod 8 'Save' 9383 1 nil nil nil 2674 1 1874 #editFind 8 'Find' 9357 1 nil nil nil 2674 1 1874 #editReplace 8 'Replace' 9361 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 2674 1 1874 #jadeExecute 8 'Execute' 9355 1 nil nil nil 2674 1 1874 #jadeInspect 8 'Inspect' 9379 1 nil nil nil 2674 1 1874 #jadeDisplay 8 'Display' 9353 1 nil nil nil 8 'Edit' nil 134217729 nil nil 26645 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 930 138 144 34 3 994 #createAt:extent: 34 2 514 7679 21 514 1601 1201 416 994 #text: 34 1 8 'Jadeite Method List Browser' 416 994 #updateMenuBar 1584 416 1154 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 31 18 0 0 98 2 0 0] 34 3 1344 608 1632 1216 nil 27 )! !
!JadeiteRenameClassMethodListBrowser class categoriesFor: #resource_Default_view!public!resources-views! !

