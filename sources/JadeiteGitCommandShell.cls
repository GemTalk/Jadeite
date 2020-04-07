"Filed out from Dolphin Smalltalk 7"!

JadeWorkspace subclass: #JadeiteGitCommandShell
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteGitCommandShell guid: (GUID fromString: '{d7998a4a-792c-4729-9cfe-8988ca050a78}')!
JadeiteGitCommandShell comment: 'An experimental command shell to run git commands from Jadeite'!
!JadeiteGitCommandShell categoriesForClass!Unclassified! !
!JadeiteGitCommandShell methodsFor!

codeSourcePresenterClass

	^JadeiteGitCommandPresenter!

createComponents
	super createComponents. 
	!

updateCaption
	self caption: (gciSession titleBarFor: 'Git Command Shell')! !
!JadeiteGitCommandShell categoriesFor: #codeSourcePresenterClass!accessing!public! !
!JadeiteGitCommandShell categoriesFor: #createComponents!initialization!public! !
!JadeiteGitCommandShell categoriesFor: #updateCaption!public!updating! !

!JadeiteGitCommandShell class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1201 801 549 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 8 #() false 170 192 34 2 410 ##(Smalltalk.ReferenceView) 34 14 nil 416 34 2 8 1140850688 131073 624 nil 480 nil 7 nil nil nil 624 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteGitCommandPresenter) #resource_Default_view nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 1 1 498 1169 683 624 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 85 1 0 0] 576 498 193 193 nil 27 8 'codePane' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 265030 4 ##(Smalltalk.Menu) nil true 34 7 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #fileNew 8 '&New Workspace' 9373 1 nil nil nil 1042 1 1074 #fileOpen 8 '&Open Workspace...' 9375 1 nil nil nil 1042 1 1074 #fileSave 8 '&Save' 9383 1 nil nil nil 1042 1 1074 #fileSaveAs 8 'Save &As...' 1 1 nil nil nil 1042 1 1074 #fileRevert 8 '&Revert' 1025 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 1042 1 1074 #exit 8 'E&xit' 17639 1 nil nil nil 8 '&File' nil 1 nil nil 59241 nil nil 994 nil true 34 15 1042 1 1074 #undo 8 '&Undo' 9397 1 nil nil nil 1042 1 1074 #redo 8 'R&edo' 9395 1 nil nil nil 1314 4097 1042 1 1074 #editCut 8 'Cu&t' 9393 1 nil nil nil 1042 1 1074 #editCopy 8 '&Copy' 9351 1 nil nil nil 1042 1 1074 #editPaste 8 '&Paste' 9389 1 nil nil nil 1042 1 1074 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 1042 1 1074 #editDelete 8 '&Delete' 1629 1 nil nil nil 1314 4097 1042 1 1074 #editFind 8 '&Find...' 9357 1 nil nil nil 1042 1 1074 #editFindNext 8 'Find &Next' 9359 1 nil nil nil 1042 1 1074 #editReplace 8 '&Replace...' 9361 1 nil nil nil 1314 4097 1042 1 1074 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 1042 1 1074 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 8 '&Edit' nil 1 nil nil 59267 nil nil 994 nil true 34 10 1042 1 1074 #abortTransaction 8 '&Abort Transaction' 1 1 nil nil nil 1042 1 1074 #commitTransaction 8 '&Commit Transaction' 1 1 nil nil nil 1314 4097 1042 1 1074 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 1042 1 1074 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 1042 1 1074 #jadeExecute 8 '&Execute' 9355 1 nil nil nil 1042 1 1074 #jadeDebug 8 'De&bug' 9349 1 nil nil nil 1042 1 1074 #fileIn 8 'Fi&le In' 1 1 nil nil nil 1314 4097 1042 1 1074 #openProjectsBrowser 8 '&Browse Projects' 9377 1 nil nil nil 8 '&Jadeite' nil 1 nil nil 59285 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons\GS32.ico' nil 2562 nil true 2608 8 'icons\GS16.ico' nil nil nil 1 nil nil 722 138 144 34 3 786 #createAt:extent: 34 2 498 2879 21 498 1201 801 416 786 #text: 34 1 8 'Jade Workspace' 416 786 #updateMenuBar 576 416 866 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 159 5 0 0 10 0 0 0 247 7 0 0 154 1 0 0] 34 1 624 912 nil 27 )! !
!JadeiteGitCommandShell class categoriesFor: #resource_Default_view!public!resources-views! !

