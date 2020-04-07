"Filed out from Dolphin Smalltalk 7"!

JadeWorkspace subclass: #JadeiteCommandShell
	instanceVariableNames: 'commandLine'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteCommandShell guid: (GUID fromString: '{d7998a4a-792c-4729-9cfe-8988ca050a78}')!
JadeiteCommandShell comment: 'An experimental command shell to run git commands from Jadeite'!
!JadeiteCommandShell categoriesForClass!Unclassified! !
!JadeiteCommandShell methodsFor!

basicSubmitCommand: string
	| answeringService |
	
	[answeringService := RowanAnsweringService new
				command: #exec:;
				commandArgs: (Array with: string).
	BrowserUpdate current issueCommands: (Array with: answeringService) session: self gciSession]
			on: Error
			do: [:ex | ^ex messageText].
	^answeringService answer!

createComponents
	super createComponents. 
	commandLine := self add: JadeiteCommandLinePresenter new name: 'commandLine'
	!

onViewOpened

	super onViewOpened. 
	documentPresenter isReadOnly: true. 
	commandLine setFocus . !

submitCommand
	| result |
	result := self basicSubmitCommand: commandLine value.
	documentPresenter view appendText: Character cr asString , '>' , commandLine value.
	documentPresenter view appendText: Character cr asString , result.
	documentPresenter view moveToEndOfDocument.
	commandLine value: String new.
	commandLine setFocus!

updateCaption
	self caption: (gciSession titleBarFor: 'Command Shell')! !
!JadeiteCommandShell categoriesFor: #basicSubmitCommand:!operations!public! !
!JadeiteCommandShell categoriesFor: #createComponents!initialization!public! !
!JadeiteCommandShell categoriesFor: #onViewOpened!event handlers!public! !
!JadeiteCommandShell categoriesFor: #submitCommand!operations!public! !
!JadeiteCommandShell categoriesFor: #updateCaption!public!updating! !

!JadeiteCommandShell class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1201 801 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.ReferenceView) 34 14 nil 416 34 2 8 1140850688 131073 592 nil 480 nil 7 nil nil nil 592 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.CodeSourcePresenter) #resource_Default_view nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 1 1 498 1169 603 592 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 45 1 0 0] 8 #() 498 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 946 #fixedParentRight 1 946 #fixedParentTop 1 946 #fixedParentBottom -79 410 ##(Smalltalk.TextEdit) 34 16 nil 416 34 2 8 1140916352 1025 1024 nil 480 nil 7 nil nil nil 1024 nil 8 1650007552 852486 ##(Smalltalk.NullConverter) nil nil 1 690 138 144 34 1 754 #createAt:extent: 34 2 498 1 603 498 1169 81 1024 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 45 1 0 0 72 2 0 0 85 1 0 0] 8 #() 896 nil 27 914 960 1 976 1 1008 -79 1008 1 170 192 34 4 592 8 'codePane' 1024 8 'commandLine' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 265030 4 ##(Smalltalk.Menu) nil true 34 7 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #fileNew 8 '&New Workspace' 9373 1 nil nil nil 1474 1 1506 #fileOpen 8 '&Open Workspace...' 9375 1 nil nil nil 1474 1 1506 #fileSave 8 '&Save' 9383 1 nil nil nil 1474 1 1506 #fileSaveAs 8 'Save &As...' 1 1 nil nil nil 1474 1 1506 #fileRevert 8 '&Revert' 1025 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 1474 1 1506 #exit 8 'E&xit' 17639 1 nil nil nil 8 '&File' nil 1 nil nil 17849 nil nil 1426 nil true 34 15 1474 1 1506 #undo 8 '&Undo' 9397 1 nil nil nil 1474 1 1506 #redo 8 'R&edo' 9395 1 nil nil nil 1746 4097 1474 1 1506 #editCut 8 'Cu&t' 9393 1 nil nil nil 1474 1 1506 #editCopy 8 '&Copy' 9351 1 nil nil nil 1474 1 1506 #editPaste 8 '&Paste' 9389 1 nil nil nil 1474 1 1506 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 1474 1 1506 #editDelete 8 '&Delete' 1629 1 nil nil nil 1746 4097 1474 1 1506 #editFind 8 '&Find...' 9357 1 nil nil nil 1474 1 1506 #editFindNext 8 'Find &Next' 9359 1 nil nil nil 1474 1 1506 #editReplace 8 '&Replace...' 9361 1 nil nil nil 1746 4097 1474 1 1506 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 1474 1 1506 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 8 '&Edit' nil 1 nil nil 17875 nil nil 1426 nil true 34 10 1474 1 1506 #abortTransaction 8 '&Abort Transaction' 1 1 nil nil nil 1474 1 1506 #commitTransaction 8 '&Commit Transaction' 1 1 nil nil nil 1746 4097 1474 1 1506 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 1474 1 1506 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 1474 1 1506 #jadeExecute 8 '&Execute' 9355 1 nil nil nil 1474 1 1506 #jadeDebug 8 'De&bug' 9349 1 nil nil nil 1474 1 1506 #fileIn 8 'Fi&le In' 1 1 nil nil nil 1746 4097 1474 1 1506 #openProjectsBrowser 8 '&Browse Projects' 9377 1 nil nil nil 8 '&Jadeite' nil 1 nil nil 17893 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons\GS32.ico' nil 2994 nil true 3040 8 'icons\GS16.ico' nil nil nil 1 nil nil 690 138 144 34 3 754 #createAt:extent: 34 2 498 2879 21 498 1201 801 416 754 #text: 34 1 8 'Jade Workspace' 416 754 #updateMenuBar 880 416 834 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 159 5 0 0 10 0 0 0 247 7 0 0 154 1 0 0] 34 2 1024 592 896 nil 27 )! !
!JadeiteCommandShell class categoriesFor: #resource_Default_view!public!resources-views! !

