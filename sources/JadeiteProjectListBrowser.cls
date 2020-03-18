"Filed out from Dolphin Smalltalk 7"!

RowanShell subclass: #JadeiteProjectListBrowser
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteProjectListBrowser guid: (GUID fromString: '{c41e9df2-548a-41c0-97e8-a12a2746e7b3}')!
JadeiteProjectListBrowser comment: ''!
!JadeiteProjectListBrowser categoriesForClass!Unclassified! !
!JadeiteProjectListBrowser methodsFor!

performCommand: aCommand
	| commandResult |
	commandResult := super performCommand: aCommand.
	commandResult == false ifFalse: [self refresh]	"any result except false results in an update"!

presenterClass
	^JadeiteProjectListPresenter!

refresh
	self primaryPresenter refresh!

shellName
	^'Project List'!

unloadProjects
	self primaryPresenter unloadProjects.
	self refresh! !
!JadeiteProjectListBrowser categoriesFor: #performCommand:!public! !
!JadeiteProjectListBrowser categoriesFor: #presenterClass!public! !
!JadeiteProjectListBrowser categoriesFor: #refresh!menu handlers!public! !
!JadeiteProjectListBrowser categoriesFor: #shellName!private! !
!JadeiteProjectListBrowser categoriesFor: #unloadProjects!menu handlers!public! !

!JadeiteProjectListBrowser class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1201 801 549 265030 4 ##(Smalltalk.Menu) nil true 34 14 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #cloneProject 8 'Clone Git Project ...' 1 1 nil nil nil 578 1 610 #loadProjects 8 'Load ...' 1 1 nil nil nil 578 1 610 #unloadProjects 8 'Unload ...' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 578 1 610 #pullFromGit 8 'Pull from Git ...' 1 1 nil nil nil 578 1 610 #commit 8 'Commit to Git ...' 1 1 nil nil nil 578 1 610 #pushToGit 8 'Push to Git ...' 1 1 nil nil nil 754 4097 578 1 610 #projectChanges 8 'Changes' 1 1 nil nil nil 578 1 610 #writeProject 8 'Write ...' 1 1 nil nil nil 578 1 610 #checkout 8 'Checkout Git Branch ...' 1 1 nil nil nil 754 4097 578 1 610 #projectLog 8 'Git Log' 1 1 nil nil nil 578 1 610 #refresh 8 'Refresh' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 8 #() false 170 192 34 2 410 ##(Smalltalk.ListView) 34 30 nil 416 34 2 8 1140920653 1025 1312 590662 2 ##(Smalltalk.ListModel) 138 144 1264 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 nil nil nil 1312 nil 8 1650059376 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 3 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Project Name' 387 #left 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.SortedCollection) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 1632 8 'doIt' 8 '[:project | project displayName]' 8 #[30 105 226 0 106] #displayName 1648 7 257 nil nil 1312 nil 3 nil 1634 0 nil 1666 3 1 1632 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 1744 7 257 nil false nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 1840 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 1840 nil nil 852486 ##(Smalltalk.NullConverter) nil 8 '' 3 nil nil nil nil nil nil nil nil nil 1538 8 'Loaded Sha' 389 #left 1586 #displayString 8 #() 1586 #<= 2032 1634 0 nil 1666 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:project | project sha]' 8 #[30 105 226 0 106] #sha 2064 7 257 nil nil 1312 nil 3 nil nil false nil 1826 nil nil 8 #(67174528 0) 2144 1874 nil false 1920 nil 480 nil 5 nil nil nil 2144 nil nil 1938 nil 8 '' 3 nil nil nil nil nil nil nil nil nil 1538 8 'Branch' 387 #left 1586 #displayString 2032 1586 #<= 2032 1634 0 nil 1666 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:project | project branch]' 8 #[30 105 226 0 106] #branch 2288 7 257 nil nil 1312 nil 3 nil nil false nil 1826 nil nil 8 #(67174528 0) 2368 1874 nil false 1920 nil 480 nil 5 nil nil nil 2368 nil nil 1938 nil 8 '' 3 nil nil nil nil nil nil nil nil nil #report 1264 nil 131171 498 129 129 34 4 nil nil 498 1 1 nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 1 1 498 1169 723 1312 2562 #text: 34 1 8 'Project Name' 1312 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 105 1 0 0] 8 #() 498 193 193 nil 27 8 'projectList' nil nil nil nil nil 1 nil nil nil nil 1 nil nil 2498 138 144 34 4 2562 #createAt:extent: 34 2 498 7679 21 498 1201 801 416 2562 #contextMenu: 34 1 544 416 2562 #text: 34 1 8 'Rowan Project List' 416 2562 #updateMenuBar 1264 416 2690 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 87 17 0 0 154 1 0 0] 34 1 1312 2752 nil 27 )! !
!JadeiteProjectListBrowser class categoriesFor: #resource_Default_view!public!resources-views! !

