"Filed out from Dolphin Smalltalk 7"!

JadeShell subclass: #JadeiteLoggerShell
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteLoggerShell guid: (GUID fromString: '{593ed341-9daf-4727-a135-2b2b451929e8}')!
JadeiteLoggerShell comment: ''!
!JadeiteLoggerShell categoriesForClass!Unclassified! !
!JadeiteLoggerShell methodsFor!

inputClientFile

	^self primaryPresenter inputClientFile!

presenterClass
	^JadeiteLoggerPresenter!

shellName
	^'Jadeite Logger Browser'! !
!JadeiteLoggerShell categoriesFor: #inputClientFile!menu handlers!public! !
!JadeiteLoggerShell categoriesFor: #presenterClass!overrides!private! !
!JadeiteLoggerShell categoriesFor: #shellName!overrides!private! !

!JadeiteLoggerShell class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 1431 711 39 nil nil nil 416 nil 170 192 8 #() nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 1 265030 4 ##(Smalltalk.Menu) nil true 34 1 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #inputClientFile 8 'Refresh' 9381 1 nil nil nil 8 'Jadeite' nil 134217729 nil nil 49383 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 7699 21 514 2111 1311 416 850 #updateMenuBar 560 416 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 9 15 0 0 10 0 0 0 40 19 0 0 153 2 0 0] 34 1 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1409286144 131073 1008 nil nil nil 519 nil nil nil 1008 nil 170 192 34 2 410 ##(Smalltalk.ListView) 34 30 nil 1008 34 2 8 1409388621 1025 1104 590662 2 ##(Smalltalk.ListModel) 138 144 560 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 466 8 4278190080 nil 519 nil nil nil 1104 nil 8 4294905313 459270 ##(Smalltalk.Message) #displayString 8 #() nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 2 920646 5 ##(Smalltalk.ListViewColumn) 8 'Client' 1027 #left 1298 #clientDisplayString 8 #() ##(Smalltalk.SortedCollection) nil nil 1104 nil 3 nil nil 1410 8 'Server' 1027 #left 1298 #serverDisplayString 1472 1298 #<= 8 #() nil nil 1104 nil 3 nil nil #report 560 nil 131171 nil 34 4 nil nil 514 1 1 nil 786 138 144 34 2 850 #createAt:extent: 34 2 514 -1 1 514 2061 1233 1104 850 #text: 34 1 8 'Client' 1104 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 5 4 0 0 104 2 0 0] 8 #() 514 193 193 nil 27 8 'logList' nil 786 138 144 34 1 850 #createAt:extent: 34 2 514 5 1 514 2061 1233 1008 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 2 0 0 0 0 0 0 0 8 4 0 0 104 2 0 0] 34 1 1104 1808 nil 27 1808 nil 27 )! !
!JadeiteLoggerShell class categoriesFor: #resource_Default_view!public!resources-views! !

