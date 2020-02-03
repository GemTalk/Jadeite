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
	^'Jadeite Log Browser'! !
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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 1431 711 39 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 608 nil nil nil 7 nil nil nil 608 546 170 176 34 2 410 ##(Smalltalk.StaticPath) 34 17 nil 608 34 2 8 1140850956 262145 720 nil nil nil 7 nil nil nil 720 nil 8 1678140720 852486 ##(Smalltalk.NullConverter) nil nil nil 8 'c:\Program Files\Dolphin Smalltalk' 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 1139 1 514 1061 55 720 914 #text: 34 1 832 720 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 57 2 0 0 0 0 0 0 75 4 0 0 27 0 0 0] 8 #() 514 193 193 nil 27 327734 ##(Smalltalk.Float) 8 195 245 40 92 143 194 237 63 false 170 192 34 4 410 ##(Smalltalk.StaticPath) 34 17 nil 608 34 2 8 1140850956 262145 1168 nil nil nil 519 nil nil nil 1168 nil 8 1678140720 802 nil nil nil 8 'c:\Program Files\Dolphin Smalltalk' 850 138 144 34 2 914 #createAt:extent: 34 2 514 1 1 514 1139 55 1168 914 #text: 34 1 1264 1168 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 57 2 0 0 27 0 0 0] 8 #() 1088 nil 27 8 'clientFilenameText' 720 8 'serverFilenameText' nil 850 138 144 34 1 914 #createAt:extent: 34 2 514 1 1339 514 2199 55 608 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 157 2 0 0 75 4 0 0 184 2 0 0] 34 2 1168 720 1088 nil 27 524806 ##(Smalltalk.Fraction) 3 51 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1409286144 131073 1696 nil nil nil 519 nil nil nil 1696 546 170 176 8 #() false 170 192 34 2 410 ##(Smalltalk.ListView) 34 30 nil 1696 34 2 8 1409388617 1025 1840 590662 2 ##(Smalltalk.ListModel) 138 144 1792 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 466 8 4278190080 nil 519 nil nil nil 1840 nil 8 4294902139 459270 ##(Smalltalk.Message) #displayString 8 #() nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 4 920646 5 ##(Smalltalk.ListViewColumn) 8 '' 81 #left 2034 #clientGroupIdDisplayString 8 #() 2034 #<= 2208 nil nil 1840 nil 1 nil nil 2146 2176 51 #left 2034 #clientIdDisplayString 2208 2034 #<= 2208 nil nil 1840 nil 1 nil nil 2146 8 'Client' 1031 #left 2034 #clientDisplayString 8 #() ##(Smalltalk.SortedCollection) nil nil 1840 nil 3 nil nil 2146 8 'Server' 1031 #left 2034 #serverDisplayString 2336 2034 #<= 8 #() nil nil 1840 nil 3 nil nil #report 1792 nil 131171 nil 34 4 nil nil 514 1 1 nil 850 138 144 34 1 914 #createAt:extent: 34 2 514 1 1 514 2199 1339 1840 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 75 4 0 0 157 2 0 0] 8 #() 1088 nil 27 8 'logList' nil 850 138 144 34 1 914 #createAt:extent: 34 2 514 1 1 514 2199 1339 1696 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 75 4 0 0 157 2 0 0] 34 1 1840 1088 nil 27 3 true 170 192 1792 nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 1 265030 4 ##(Smalltalk.Menu) nil true 34 3 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #inputFiles 8 'Refresh' 9381 1 nil nil nil 2914 1 2946 #selectClientFile nil 1 1 nil nil nil 2914 1 2946 #selectServerFile nil 1 1 nil nil nil 8 'Jadeite' nil 134217729 nil nil 36025 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 850 138 144 34 2 914 #createAt:extent: 34 2 514 7679 21 514 2231 1511 416 914 #updateMenuBar 1792 416 1026 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 90 19 0 0 253 2 0 0] 34 2 1696 608 1088 nil 27 )!

showOnSession: session
	^(RowanAnsweringService new canAccessServiceClasses: session)
		ifTrue: [super showOnSession: session]
		ifFalse: 
			[MessageBox
				notify: 'Unable to view logs. Need access to Rowan service classes. Try logging in as SystemUser']! !
!JadeiteLoggerShell class categoriesFor: #resource_Default_view!public!resources-views! !
!JadeiteLoggerShell class categoriesFor: #showOnSession:!instance creation!public! !

