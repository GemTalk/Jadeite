"Filed out from Dolphin Smalltalk 7"!

JadeShell subclass: #JadeiteLoggerShell
	instanceVariableNames: 'clientFilenameText serverFilenameText'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteLoggerShell guid: (GUID fromString: '{593ed341-9daf-4727-a135-2b2b451929e8}')!
JadeiteLoggerShell comment: ''!
!JadeiteLoggerShell categoriesForClass!Unclassified! !
!JadeiteLoggerShell methodsFor!

clientFilenameText
	^clientFilenameText!

clientFilenameText: anObject
	clientFilenameText := anObject!

createComponents
	super createComponents.
	clientFilenameText := self add: TextPresenter new name: 'clientFilenameText'.
	serverFilenameText := self add: TextPresenter new name: 'serverFilenameText'!

inputFiles

	^self primaryPresenter inputFiles!

onViewClosed
	BrowserUpdate current logComment: 'Closing Logger Browser {' , self identityHash printString , '}'.
	super onViewClosed!

onViewOpened
	BrowserUpdate current logComment: 'Opening Logger Browser {' , self identityHash printString , '}'.
	super onViewOpened!

presenterClass
	^JadeiteLoggerPresenter!

selectClientFile
	self primaryPresenter
		clientFilename: (FileOpenDialog showModalOn: self primaryPresenter clientFilename asValue).
	clientFilenameText value: self primaryPresenter clientFilename.
	self inputFiles. !

selectServerFile
	self primaryPresenter
		serverFilename: (FileOpenDialog showModalOn: self primaryPresenter serverFilename asValue).
	serverFilenameText value: self primaryPresenter serverFilename.
	self inputFiles. !

serverFilenameText
	^serverFilenameText!

serverFilenameText: anObject
	serverFilenameText := anObject!

shellName
	^'Jadeite Logger Browser'! !
!JadeiteLoggerShell categoriesFor: #clientFilenameText!accessing!private! !
!JadeiteLoggerShell categoriesFor: #clientFilenameText:!accessing!private! !
!JadeiteLoggerShell categoriesFor: #createComponents!initialization!public! !
!JadeiteLoggerShell categoriesFor: #inputFiles!menu handlers!public! !
!JadeiteLoggerShell categoriesFor: #onViewClosed!event handlers!public! !
!JadeiteLoggerShell categoriesFor: #onViewOpened!event handlers!public! !
!JadeiteLoggerShell categoriesFor: #presenterClass!overrides!private! !
!JadeiteLoggerShell categoriesFor: #selectClientFile!menu handlers!public! !
!JadeiteLoggerShell categoriesFor: #selectServerFile!menu handlers!public! !
!JadeiteLoggerShell categoriesFor: #serverFilenameText!accessing!private! !
!JadeiteLoggerShell categoriesFor: #serverFilenameText:!accessing!private! !
!JadeiteLoggerShell categoriesFor: #shellName!overrides!private! !

!JadeiteLoggerShell class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 1431 711 39 nil nil nil 416 nil 170 192 34 4 410 ##(Smalltalk.StaticPath) 34 17 nil 416 34 2 8 1140850956 1 576 nil nil nil 7 nil nil nil 576 nil 8 1678140720 852486 ##(Smalltalk.NullConverter) nil nil nil 8 'c:\Program Files\Dolphin Smalltalk' 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 1171 1279 514 911 45 576 770 #text: 34 1 688 576 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 73 2 0 0 127 2 0 0 16 4 0 0 149 2 0 0] 8 #() 514 193 193 nil 27 8 'serverFilenameText' 410 ##(Smalltalk.StaticPath) 34 17 nil 416 34 2 8 1140850956 1 976 nil nil nil 7 nil nil nil 976 nil 8 1678140720 658 nil nil nil 8 'c:\Program Files\Dolphin Smalltalk' 706 138 144 34 2 770 #createAt:extent: 34 2 514 141 1283 514 1011 41 976 770 #text: 34 1 1072 976 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 70 0 0 0 129 2 0 0 63 2 0 0 149 2 0 0] 8 #() 944 nil 27 8 'clientFilenameText' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 1 265030 4 ##(Smalltalk.Menu) nil true 34 3 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #inputFiles 8 'Refresh' 9381 1 nil nil nil 1394 1 1426 #selectClientFile nil 1 1 nil nil nil 1394 1 1426 #selectServerFile nil 1 1 nil nil nil 8 'Jadeite' nil 134217729 nil nil 58085 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 706 138 144 34 2 770 #createAt:extent: 34 2 514 7679 21 514 2161 1441 416 770 #updateMenuBar 8 #() 416 882 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 55 19 0 0 218 2 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1409286144 131073 1760 nil nil nil 519 nil nil nil 1760 nil 170 192 34 2 410 ##(Smalltalk.ListView) 34 30 nil 1760 34 2 8 1409388621 1025 1856 590662 2 ##(Smalltalk.ListModel) 138 144 1696 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 466 8 4278190080 nil 519 nil nil nil 1856 nil 8 4294904653 459270 ##(Smalltalk.Message) #displayString 8 #() nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 4 920646 5 ##(Smalltalk.ListViewColumn) 8 '' 81 #left 2050 #clientGroupIdDisplayString 8 #() 2050 #<= 2224 nil nil 1856 nil 1 nil nil 2162 2192 51 #left 2050 #clientIdDisplayString 2224 2050 #<= 2224 nil nil 1856 nil 1 nil nil 2162 8 'Client' 993 #left 2050 #clientDisplayString 8 #() ##(Smalltalk.SortedCollection) nil nil 1856 nil 3 nil nil 2162 8 'Server' 991 #left 2050 #serverDisplayString 2352 2050 #<= 8 #() nil nil 1856 nil 3 nil nil #report 1696 nil 131171 nil 34 4 nil nil 514 1 1 nil 706 138 144 34 1 770 #createAt:extent: 34 2 514 1 1 514 2121 1269 1856 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 36 4 0 0 122 2 0 0] 8 #() 944 nil 27 8 'logList' nil 706 138 144 34 1 770 #createAt:extent: 34 2 514 5 1 514 2121 1269 1760 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 2 0 0 0 0 0 0 0 38 4 0 0 122 2 0 0] 34 1 1856 944 nil 27 976 576 944 nil 27 )! !
!JadeiteLoggerShell class categoriesFor: #resource_Default_view!public!resources-views! !

