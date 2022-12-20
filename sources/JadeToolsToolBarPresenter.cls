"Filed out from Dolphin Smallalk"!

JadePresenter subclass: #JadeToolsToolBarPresenter
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeToolsToolBarPresenter guid: (GUID fromString: '{7109cdbe-8fa3-4a9d-a3d2-0c1295a3256e}')!
JadeToolsToolBarPresenter comment: ''!
!JadeToolsToolBarPresenter categoriesForClass!Unclassified! !
!JadeToolsToolBarPresenter methodsFor!

abort
	(parentPresenter class canUnderstand: #abortTransaction)
		ifTrue: [^parentPresenter abortTransaction	"include tool post-abort behavior"].
	super abortTransaction!

begin
	(parentPresenter class canUnderstand: #beginTransaction)
		ifTrue: [^parentPresenter beginTransaction]!

commit
	^super commitTransaction!

fileNew
	JadeWorkspace showOnSession: gciSession.
!

fileOpen

	JadeWorkspace openOnSession: gciSession.
!

queryCommand: query
	super queryCommand: query.
	query commandSymbol = #begin
		ifTrue: 
			[query isEnabled: self isBeginTransactionEnabled.
			^true].
	query commandSymbol = #commit
		ifTrue: 
			[query isEnabled: self isCommitEnabled.
			^true].! !
!JadeToolsToolBarPresenter categoriesForMethods!
abort!Jade!public! !
begin!Jade!public! !
commit!public! !
fileNew!public! !
fileOpen!public! !
queryCommand:!public! !
!

!JadeToolsToolBarPresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil nil 5 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ToolbarA) 34 25 nil 416 34 2 8 1140851500 131137 544 nil 327686 ##(Smalltalk.Color) #default nil 517 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 328198 ##(Smalltalk.Point) 193 193 nil 544 624 8 1607642496 nil 170 192 34 16 27711 1115206 1 ##(Smalltalk.ToolbarIconButton) 544 1 1180998 4 ##(Smalltalk.CommandDescription) #browseTests 8 'Open Test Browser' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons\UnitTestPlugin.ico' nil 27711 27703 1246790 1 ##(Smalltalk.ToolbarSystemButton) 544 1 834 #fileNew 8 'New Workspace' 1 1 nil 27703 1 13 27699 1246790 1 ##(Smalltalk.ToolbarBitmapButton) 544 1 834 #commit 8 'Commit Transaction' 1 1 nil 27699 395334 3 ##(Smalltalk.Bitmap) nil true 928 8 'Tools.bmp' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil nil 7 722 1857 33 27 27713 962 544 1 834 #jadePreferences 8 'Jadeite Preferences' 1 1 nil 27713 1 21 27709 1026 544 1 834 #openJadeiteProjectsBrowser 8 'Open Projects Browser' 1 1 nil 27709 1104 17 27705 962 544 1 834 #fileOpen 8 'Open Workspace' 1 1 nil 27705 1 15 27701 1026 544 1 834 #begin 8 'Begin Transaction' 1 1 nil 27701 1104 43 27697 1026 544 1 834 #abort 8 'Abort Transaction' 1 1 nil 27697 1104 1 34 10 1392 1040 1344 1049158 1 ##(Smalltalk.ToolbarSeparator) 544 1 976 1296 1458 544 1 1248 816 1200 nil nil 1 nil 722 33 33 722 45 45 nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 722 1 1 722 461 51 544 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 230 0 0 0 25 0 0 0] 8 #() 722 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 1794 #fixedParentRight 1 1794 #fixedParentTop 1 1794 #fixedParentBottom 1 170 192 8 #() nil 1538 138 144 34 1 1602 #createAt:extent: 34 2 722 6447 21 722 461 51 416 1682 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 151 12 0 0 10 0 0 0 125 13 0 0 35 0 0 0] 34 1 544 1744 nil 27 )! !
!JadeToolsToolBarPresenter class categoriesForMethods!
resource_Default_view!public!resources-views! !
!

