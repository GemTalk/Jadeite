"Filed out from Dolphin Smalltalk 7"!

RowanShell subclass: #RowanProjectListShell
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanProjectListShell guid: (GUID fromString: '{c41e9df2-548a-41c0-97e8-a12a2746e7b3}')!
RowanProjectListShell comment: ''!
!RowanProjectListShell categoriesForClass!Unclassified! !
!RowanProjectListShell methodsFor!

cloneProject
	self primaryPresenter cloneProject.
	self refresh!

makeDefault

	self primaryPresenter makeDefault.
!

performCommand: aCommand
	| commandResult |
	commandResult := super performCommand: aCommand.
	commandResult == false ifFalse: [self refresh]	"any result except false results in an update"!

presenterClass
	
	^RowanProjectListPresenter!

refresh
	self primaryPresenter browseProjects.
	self primaryPresenter view invalidate!

shellName
	^'Rowan Projects Browser'!

unloadProject
	
	self primaryPresenter unloadProject.
	self refresh
	
! !
!RowanProjectListShell categoriesFor: #cloneProject!menu handlers!public! !
!RowanProjectListShell categoriesFor: #makeDefault!menu handlers!public! !
!RowanProjectListShell categoriesFor: #performCommand:!public! !
!RowanProjectListShell categoriesFor: #presenterClass!public! !
!RowanProjectListShell categoriesFor: #refresh!menu handlers!public! !
!RowanProjectListShell categoriesFor: #shellName!private! !
!RowanProjectListShell categoriesFor: #unloadProject!menu handlers!public! !

!RowanProjectListShell class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 1201 801 551 265030 4 ##(Smalltalk.Menu) nil true 34 18 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #makeDefault 8 'Make Default' 1 1 nil nil nil 594 1 626 #showPackages 8 'Show Packages ...' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 594 1 626 #cloneProject 8 'Clone Git Project ...' 1 1 nil nil nil 594 1 626 #loadProject 8 'Load ...' 1 1 nil nil nil 594 1 626 #unloadProject 8 'Unload ...' 1 1 nil nil nil 722 4097 594 1 626 #pullFromGit 8 'Pull from Git ...' 1 1 nil nil nil 594 1 626 #commit 8 'Commit ...' 1 1 nil nil nil 594 1 626 #pushToGit 8 'Push to Git ...' 1 1 nil nil nil 722 4097 594 1 626 #projectChanges 8 'Changes' 1 1 nil nil nil 594 1 626 #writeProject 8 'Write ...' 1 1 nil nil nil 594 1 626 #checkout 8 'Checkout ...' 1 1 nil nil nil 722 4097 594 1 626 #projectLog 8 'Log' 1 1 nil nil nil 594 1 626 #inspectProject 8 'Inspect' 1 1 nil nil nil 594 1 626 #refresh 8 'Refresh' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 8 #() false 170 192 34 2 410 ##(Smalltalk.ListView) 34 30 nil 416 34 2 8 1140920653 1025 1488 590662 2 ##(Smalltalk.ListModel) 138 144 1440 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 466 8 4278190080 nil 7 nil nil nil 1488 nil 8 4294904973 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 3 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Project Name' 387 #left 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.SortedCollection) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 1840 8 'doIt' 8 '[:project | project displayName]' 8 #[30 105 226 0 106] #displayName 1856 7 257 nil nil 1488 nil 3 nil 1842 0 nil 1874 3 1 1840 8 'doIt' 8 '[:each | each item displayStringFor: each]' 8 #[31 105 226 0 17 177 106] #item #displayStringFor: 1952 7 257 nil false nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 2048 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 2048 nil nil 852486 ##(Smalltalk.NullConverter) nil 8 '' 3 nil nil nil nil nil nil nil nil nil 1746 8 'Loaded Sha' 389 #left 1794 #displayString 8 #() 1794 #<= 2240 1842 0 nil 1874 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:project | project sha]' 8 #[30 105 226 0 106] #sha 2272 7 257 nil nil 1488 nil 3 nil nil false nil 2034 nil nil 8 #(67174528 0) 2352 2082 nil false 2128 nil 466 8 4278190080 nil 5 nil nil nil 2352 nil nil 2146 nil 8 '' 3 nil nil nil nil nil nil nil nil nil 1746 8 'Branch' 387 #left 1794 #displayString 2240 1794 #<= 2240 1842 0 nil 1874 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:project | project branch]' 8 #[30 105 226 0 106] #branch 2528 7 257 nil nil 1488 nil 3 nil nil false nil 2034 nil nil 8 #(67174528 0) 2608 2082 nil false 2128 nil 466 2416 nil 5 nil nil nil 2608 nil nil 2146 nil 8 '' 3 nil nil nil nil nil nil nil nil nil #report 1440 nil 131171 514 129 129 34 4 nil nil 514 1 1 nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 1 1 514 1169 723 1488 2818 #text: 34 1 8 'Project Name' 1488 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 105 1 0 0] 8 #() 514 193 193 nil 27 8 'projectList' nil nil nil nil nil 1 nil nil nil nil 1 nil nil 2754 138 144 34 4 2818 #createAt:extent: 34 2 514 3839 21 514 1201 801 416 2818 #contextMenu: 34 1 560 416 2818 #text: 34 1 8 'Rowan Project List' 416 2818 #updateMenuBar 1440 416 2946 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 127 7 0 0 10 0 0 0 215 9 0 0 154 1 0 0] 34 1 1488 3008 nil 27 )! !
!RowanProjectListShell class categoriesFor: #resource_Default_view!public!resources-views! !

