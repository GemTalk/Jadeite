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

makeDefault

	self primaryPresenter makeDefault.
!

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
!JadeiteProjectListBrowser categoriesFor: #makeDefault!menu handlers!public! !
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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 1201 801 551 265030 4 ##(Smalltalk.Menu) nil true 34 16 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #makeDefault 8 'Make Default' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 594 1 626 #cloneProject 8 'Clone Git Project ...' 1 1 nil nil nil 594 1 626 #loadProjects 8 'Load ...' 1 1 nil nil nil 594 1 626 #unloadProjects 8 'Unload ...' 1 1 nil nil nil 674 4097 594 1 626 #pullFromGit 8 'Pull from Git ...' 1 1 nil nil nil 594 1 626 #commit 8 'Commit ...' 1 1 nil nil nil 594 1 626 #pushToGit 8 'Push to Git ...' 1 1 nil nil nil 674 4097 594 1 626 #projectChanges 8 'Changes' 1 1 nil nil nil 594 1 626 #writeProject 8 'Write ...' 1 1 nil nil nil 594 1 626 #checkout 8 'Checkout ...' 1 1 nil nil nil 674 4097 594 1 626 #projectLog 8 'Log' 1 1 nil nil nil 594 1 626 #refresh 8 'Refresh' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 8 #() false 170 192 34 2 410 ##(Smalltalk.ListView) 34 30 nil 416 34 2 8 1140920653 1025 1392 590662 2 ##(Smalltalk.ListModel) 138 144 1344 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 466 8 4278190080 nil 7 nil nil nil 1392 nil 8 4294906105 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 3 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Project Name' 387 #left 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.SortedCollection) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 1744 8 'doIt' 8 '[:project | project displayName]' 8 #[30 105 226 0 106] #displayName 1760 7 257 nil nil 1392 nil 3 nil 1746 0 nil 1778 3 1 1744 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 1856 7 257 nil false nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 1952 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 1952 nil nil 852486 ##(Smalltalk.NullConverter) nil 8 '' 3 nil nil nil nil nil nil nil nil nil 1650 8 'Loaded Sha' 389 #left 1698 #displayString 8 #() 1698 #<= 2144 1746 0 nil 1778 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:project | project sha]' 8 #[30 105 226 0 106] #sha 2176 7 257 nil nil 1392 nil 3 nil nil false nil 1938 nil nil 8 #(67174528 0) 2256 1986 nil false 2032 nil 466 8 4278190080 nil 5 nil nil nil 2256 nil nil 2050 nil 8 '' 3 nil nil nil nil nil nil nil nil nil 1650 8 'Branch' 387 #left 1698 #displayString 2144 1698 #<= 2144 1746 0 nil 1778 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:project | project branch]' 8 #[30 105 226 0 106] #branch 2432 7 257 nil nil 1392 nil 3 nil nil false nil 1938 nil nil 8 #(67174528 0) 2512 1986 nil false 2032 nil 466 2320 nil 5 nil nil nil 2512 nil nil 2050 nil 8 '' 3 nil nil nil nil nil nil nil nil nil #report 1344 nil 131171 514 129 129 34 4 nil nil 514 1 1 nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 1 1 514 1169 723 1392 2722 #text: 34 1 8 'Project Name' 1392 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 105 1 0 0] 8 #() 514 193 193 nil 27 8 'projectList' nil nil nil nil nil 1 nil nil nil nil 1 nil nil 2658 138 144 34 4 2722 #createAt:extent: 34 2 514 7679 21 514 1201 801 416 2722 #contextMenu: 34 1 560 416 2722 #text: 34 1 8 'Rowan Project List' 416 2722 #updateMenuBar 1344 416 2850 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 87 17 0 0 154 1 0 0] 34 1 1392 2912 nil 27 )! !
!JadeiteProjectListBrowser class categoriesFor: #resource_Default_view!public!resources-views! !
