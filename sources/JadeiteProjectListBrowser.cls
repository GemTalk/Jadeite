"Filed out from Dolphin Smallalk"!

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
!JadeiteProjectListBrowser categoriesForMethods!
performCommand:!public! !
presenterClass!public! !
refresh!menu handlers!public! !
shellName!private! !
unloadProjects!menu handlers!public! !
!

!JadeiteProjectListBrowser class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1201 801 549 265030 4 ##(Smalltalk.Menu) nil true 34 14 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #loadV2Project 8 'Load Git Project ...' 1 1 nil nil nil 578 1 610 #loadProjects 8 'Reload Projects' 1 1 nil nil nil 578 1 610 #unloadProjects 8 'Unload ...' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 578 1 610 #pullFromGit 8 'Pull from Git ...' 1 1 nil nil nil 578 1 610 #commit 8 'Commit to Git ...' 1 1 nil nil nil 578 1 610 #pushToGit 8 'Push to Git ...' 1 1 nil nil nil 754 4097 578 1 610 #projectChanges 8 'Changes' 1 1 nil nil nil 578 1 610 #writeProject 8 'Write ...' 1 1 nil nil nil 578 1 610 #checkout 8 'Checkout Git Branch ...' 1 1 nil nil nil 754 4097 578 1 610 #projectLog 8 'Git Log' 1 1 nil nil nil 578 1 610 #refresh 8 'Refresh' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 8 #() false 170 192 34 2 410 ##(Smalltalk.ListView) 34 45 nil 416 34 2 8 1140920653 1025 1312 590662 2 ##(Smalltalk.ListModel) 138 144 1264 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 530 nil true 34 18 578 1 610 #openJadeiteProjectsBrowser 8 'Browse' 9377 1 nil nil nil 578 1 610 #editComponents 8 'Edit Components' 1025 1 nil nil nil 754 4097 578 1 610 #loadV2Project 8 'Load Git Project ...' 1 1 nil nil nil 578 1 610 #loadProjects 8 'Reload' 1 1 nil nil nil 578 1 610 #unloadProjects 8 'Unload' 1 1 nil nil nil 754 4097 578 1 610 #pullFromGit 8 'Pull from Git' 1 1 nil nil nil 578 1 610 #gitCommit 8 'Commit to Git ...' 1 1 nil nil nil 578 1 610 #pushToGit 8 'Push to Git' 1 1 nil nil nil 754 4097 578 1 610 #projectChanges 8 'Changes' 1 1 nil nil nil 578 1 610 #writeProject 8 'Write' 1 1 nil nil nil 578 1 610 #checkoutTag 8 'Checkout Git Tag ...' 1 1 nil nil nil 578 1 610 #checkout 8 'Checkout Git Branch ...' 1 1 nil nil nil 754 4097 578 1 610 #projectLog 8 'Git Log' 1 1 nil nil nil 578 1 610 #refresh 8 'Refresh' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 1312 nil 8 1719462000 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 3 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Project Name' 387 #left 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.SortedCollection) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 2416 8 'doIt' 8 '[:project | project displayName]' 8 #[30 105 226 0 106] #displayName 2432 7 257 nil nil 1312 nil 3 nil 2418 0 nil 2450 3 1 2416 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 2528 7 257 nil false nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 2624 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 2624 nil nil 852486 ##(Smalltalk.NullConverter) nil 8 '' 3 nil nil nil nil nil nil nil nil nil 2322 8 'Loaded Sha' 389 #left 2370 #displayString 8 #() 2370 #<= 2816 2418 0 nil 2450 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:project | project sha]' 8 #[30 105 226 0 106] #sha 2848 7 257 nil nil 1312 nil 3 nil nil false nil 2610 nil nil 8 #(67174528 0) 2928 2658 nil false 2704 nil 480 nil 5 nil nil nil 2928 nil nil 2722 nil 8 '' 3 nil nil nil nil nil nil nil nil nil 2322 8 'Branch' 387 #left 2370 #displayString 2816 2370 #<= 2816 2418 0 nil 2450 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:project | project branch]' 8 #[30 105 226 0 106] #branch 3072 7 257 nil nil 1312 nil 3 nil nil false nil 2610 nil nil 8 #(67174528 0) 3152 2658 nil false 2704 nil 480 nil 5 nil nil nil 3152 nil nil 2722 nil 8 '' 3 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 498 129 129 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 1 1 498 1169 723 1312 3330 #contextMenu: 34 1 1456 1312 3330 #text: 34 1 8 'Project Name' 1312 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 105 1 0 0] 8 #() 498 193 193 nil 35 8 'projectList' nil nil nil nil nil 1 nil nil nil nil 1 nil nil 3266 138 144 34 3 3330 #createAt:extent: 34 2 498 6691 21 498 1201 801 416 3330 #contextMenu: 34 1 544 416 3330 #text: 34 1 8 'Rowan Project List' 416 3490 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 17 13 0 0 10 0 0 0 105 15 0 0 154 1 0 0] 34 1 1312 3552 nil 27 )! !
!JadeiteProjectListBrowser class categoriesForMethods!
resource_Default_view!public!resources-views! !
!

