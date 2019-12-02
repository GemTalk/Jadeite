"Filed out from Dolphin Smalltalk 7"!

JadeWorkspace subclass: #JadeitePreferencesWorkspace
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeitePreferencesWorkspace guid: (GUID fromString: '{436a344c-31d9-4feb-a49b-57929ac293d0}')!
JadeitePreferencesWorkspace comment: ''!
!JadeitePreferencesWorkspace categoriesForClass!Unclassified! !
!JadeitePreferencesWorkspace methodsFor!

basicResetPreferences
	model value: JadeitePreferences preferencesFileDefaultContents!

openPreferencesOptionsWorkspace
	| workspace |
	workspace := JadeWorkspace showOnSession: self gciSession.
	workspace model value: JadeitePreferences preferencesFileDefaultContents.
	workspace
		isModified: false;
		caption: 'Default Preferences'.
	workspace codePane documentPresenter view setReadOnly: true.
	^workspace!

resetPreferences
	(MessageBox confirm: 'Really reset jadeite.prefs file to default settings?') ifFalse: [^self].
	self basicResetPreferences! !
!JadeitePreferencesWorkspace categoriesFor: #basicResetPreferences!menu handlers!private! !
!JadeitePreferencesWorkspace categoriesFor: #openPreferencesOptionsWorkspace!menu handlers!public! !
!JadeitePreferencesWorkspace categoriesFor: #resetPreferences!menu handlers!public! !

!JadeitePreferencesWorkspace class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 1201 801 551 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 8 #() false 170 192 34 2 410 ##(Smalltalk.ReferenceView) 34 14 nil 416 34 2 8 1140850688 131073 640 nil 466 8 4278190080 nil 7 nil nil nil 640 1180166 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.CodeSourcePresenter) #resource_Default_view nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 1 1 514 1169 683 640 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 85 1 0 0] 592 514 193 193 nil 27 8 'codePane' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 265030 4 ##(Smalltalk.Menu) nil true 34 7 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #fileNew 8 '&New Workspace' 9373 1 nil nil nil 1090 1 1122 #fileOpen 8 '&Open Workspace...' 9375 1 nil nil nil 1090 1 1122 #fileSave 8 '&Save' 9383 1 nil nil nil 1090 1 1122 #fileSaveAs 8 'Save &As...' 1 1 nil nil nil 1090 1 1122 #fileRevert 8 '&Revert' 1025 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 1090 1 1122 #exit 8 'E&xit' 17639 1 nil nil nil 8 '&File' nil 1 nil nil 15909 nil nil 1042 nil true 34 15 1090 1 1122 #undo 8 '&Undo' 9397 1 nil nil nil 1090 1 1122 #redo 8 'R&edo' 9395 1 nil nil nil 1362 4097 1090 1 1122 #editCut 8 'Cu&t' 9393 1 nil nil nil 1090 1 1122 #editCopy 8 '&Copy' 9351 1 nil nil nil 1090 1 1122 #editPaste 8 '&Paste' 9389 1 nil nil nil 1090 1 1122 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 1090 1 1122 #editDelete 8 '&Delete' 1629 1 nil nil nil 1362 4097 1090 1 1122 #editFind 8 '&Find...' 9357 1 nil nil nil 1090 1 1122 #editFindNext 8 'Find &Next' 9359 1 nil nil nil 1090 1 1122 #editReplace 8 '&Replace...' 9361 1 nil nil nil 1362 4097 1090 1 1122 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 1090 1 1122 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 8 '&Edit' nil 1 nil nil 15935 nil nil 1042 nil true 34 13 1090 1 1122 #abortTransaction 8 '&Abort Transaction' 1 1 nil nil nil 1090 1 1122 #commitTransaction 8 '&Commit Transaction' 1 1 nil nil nil 1362 4097 1090 1 1122 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 1090 1 1122 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 1090 1 1122 #jadeExecute 8 '&Execute' 9355 1 nil nil nil 1090 1 1122 #jadeDebug 8 'De&bug' 9349 1 nil nil nil 1090 1 1122 #fileIn 8 'Fi&le In' 1 1 nil nil nil 1362 4097 1090 1 1122 #openProjectsBrowser 8 '&Browse Projects' 9377 1 nil nil nil 1362 4097 1090 1 1122 #openPreferencesOptionsWorkspace 8 'Browse Default Settings' 1025 1 nil nil nil 1090 1 1122 #resetPreferences 8 'Reset to Default Settings' 1025 1 nil nil nil 8 '&Jadeite' nil 1 nil nil 15957 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons\GS32.ico' nil 2722 nil true 2768 8 'icons\GS16.ico' nil nil nil 1 nil nil 770 138 144 34 3 834 #createAt:extent: 34 2 514 7679 21 514 1201 801 416 834 #text: 34 1 8 'Jade Preferences Workspace' 416 834 #updateMenuBar 592 416 914 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 87 17 0 0 154 1 0 0] 34 1 640 960 nil 27 )! !
!JadeitePreferencesWorkspace class categoriesFor: #resource_Default_view!public!resources-views! !

