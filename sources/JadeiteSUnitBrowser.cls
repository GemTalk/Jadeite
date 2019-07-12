"Filed out from Dolphin Smalltalk 7"!

JadeShell subclass: #JadeiteSUnitBrowser
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteSUnitBrowser guid: (GUID fromString: '{9f573c71-de71-43fe-b9c0-f2e9e68007eb}')!
JadeiteSUnitBrowser comment: ''!
!JadeiteSUnitBrowser categoriesForClass!Unclassified! !
!JadeiteSUnitBrowser methodsFor!

presenterClass
	^JadeiteSUnitPresenter!

shellName
 
	^'Jadeite SUnit Browser'.
! !
!JadeiteSUnitBrowser categoriesFor: #presenterClass!private! !
!JadeiteSUnitBrowser categoriesFor: #shellName!overrides!private! !

!JadeiteSUnitBrowser class methodsFor!

icon
	^Icon fromFile: 'UnitTestPlugin.ico'!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 1601 1201 551 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 8 #() false 170 192 34 2 410 ##(Smalltalk.ReferenceView) 34 14 nil 416 34 2 8 1140850688 131073 640 nil 466 8 4278190080 nil 7 nil nil nil 640 1180166 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteSUnitPresenter) #resource_Default_view nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 1 1 514 1569 1083 640 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 3 0 0 29 2 0 0] 592 514 193 193 nil 27 8 'myPresenter' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 1 265030 4 ##(Smalltalk.Menu) nil true 34 10 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #runAll 8 'Run All' 13443 1 nil nil nil 1090 1 1122 #runSelected 8 'Run Selected' 13479 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 1090 1 1122 #debug 8 'Debug' 9349 1 nil nil nil 1218 4097 1090 1 1122 #browseMethods 8 'Browse Methods' 9371 1 nil nil nil 1090 1 1122 #browseClass 8 'Browse Class' 9367 1 nil nil nil 1090 1 1122 #editSelectAll 8 'Select All Tests' 9347 1 nil nil nil 1218 4097 1090 1 1122 #reset 8 'Reset' 9381 1 nil nil nil 8 'Test' nil 134217729 nil nil 55263 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 nil 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'UnitTestPlugin.ico' nil nil nil 1 nil nil 770 138 144 34 3 834 #createAt:extent: 34 2 514 7679 21 514 1601 1201 416 834 #text: 34 1 8 'Jade SUnit Browser' 416 834 #updateMenuBar 592 416 914 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 31 18 0 0 98 2 0 0] 34 1 640 960 nil 27 )! !
!JadeiteSUnitBrowser class categoriesFor: #icon!public! !
!JadeiteSUnitBrowser class categoriesFor: #resource_Default_view!public!resources-views! !

