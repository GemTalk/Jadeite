"Filed out from Dolphin Smallalk"!

JadeShell subclass: #JadeSystemBrowser
	instanceVariableNames: 'cardsPresenter roundTripCount'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeSystemBrowser guid: (GUID fromString: '{72210941-97b6-4113-8ec8-e23015415de6}')!
JadeSystemBrowser comment: ''!
!JadeSystemBrowser categoriesForClass!Unclassified! !
!JadeSystemBrowser methodsFor!

abortTransaction
	self isOkayToChange ifTrue: [self currentCard abortTransaction]!

addSystemBrowser
	self addSystemBrowserWithLayoutInfo: (self currentCard ifNotNil: [:currentCard | currentCard layoutInfo]).
!

addSystemBrowserForClass: anArray

	(self systemBrowserPresenter 
		createIn: cardsPresenter 
		gciSession: gciSession)
		updateAfterFindClass: anArray
		isMeta: nil 
		selector: ''.
!

addSystemBrowserWithLayoutInfo: each
	(self systemBrowserPresenter createIn: cardsPresenter gciSession: gciSession) layoutInfo: each!

addWorkspace

	JadeWorkspace showOnSession: gciSession.
!

closeCard

	cardsPresenter view removeSubView: self currentCard view.!

closeRequested: anAssociation

	anAssociation value ifTrue: [
		self isOkayToChange ifTrue: [
			[self saveLayoutAndContents] on: Error do: [:ex | ex return].
		] ifFalse: [
			anAssociation value: false.
		].
	].
!

commitTransaction
	| commitResult |
	commitResult := self currentCard commitTransaction.
	commitResult ifTrue: [self update].
	^commitResult!

createComponents

	super createComponents.
	cardsPresenter := self add: Presenter new name: 'cardContainer'.
!

createSchematicWiring

	| toolbar |
	super createSchematicWiring.
	toolbar := self view viewNamed: 'leftToolbar'.
	cardsPresenter view 	when: #'currentCardChanged' 	send: #'update' 			to: self.
	self  				when: #'closeRequested:'		send: #'closeRequested:'	to: self.
	self  view 			when: #'viewActivated'		send: #'update'			to: self.
	toolbar			when: #dropDown: 			send: #onDropDown: 		to: self.!

currentCard

	^cardsPresenter view currentCard ifNotNil: [:cardView | cardView presenter].
!

handleInvalidSession

	| hadDialog |
	hadDialog := false.
	cardsPresenter view cards do: [:each | 
		(each presenter isKindOf: JadeSystemBrowserPresenter) ifTrue: [
			hadDialog := each presenter handleInvalidSession or: [hadDialog].
		].
	].
	hadDialog ifFalse: [
		MessageBox
			warning: 'All windows for this session will close due to unexpected logout.'
			caption: 'Invalid session!!'.
	].
	gciSession forceLogout.
!

initialize

	super initialize.
	roundTripCount := 0.!

isOkayToChange

	cardsPresenter view cards do: [:each | 
		each presenter isOkayToChange ifFalse: [^false].
	].
	^true.
!

layoutFilePath

	^SessionManager current imageBase , 'Jade System Browser Layout.stb'!

logoutRequested: aValueHolder
	"Opportunity to save changes."

	self closeRequested: aValueHolder.
!

moveCardLeft

	| cardView nextSibling |
	cardView := self currentCard view.
	nextSibling := cardView previousSiblingView.
	nextSibling notNil ifTrue: [nextSibling := nextSibling previousSiblingView].
	nextSibling notNil ifTrue: [cardView zOrderAfter: nextSibling] ifFalse: [cardView zOrderTop]!

moveCardRight

	| cardView nextSibling |
	cardView := self currentCard view.
	nextSibling := cardView nextSiblingView.
	nextSibling notNil ifTrue: [cardView zOrderAfter: nextSibling].
!

onDropDown: aToolbarButton 
	"Private - The receiver's toolbar has sent a notification that a button's drop-down arrow
	has been pressed. Generate and pop-up the appropriate menu."
	| popup |

	aToolbarButton command == #historyBack ifTrue: [popup :=  self currentCard historyBackMenu].
	aToolbarButton command == #historyForward ifTrue: [popup := self currentCard historyForwardMenu].
	popup queryAllFromView: self view.
	popup showIn: self position: aToolbarButton screenRectangle bottomLeft.

	^0!

onViewOpened

	super onViewOpened.
	cardsPresenter model: gciSession.
	self restoreLayoutAndContents.
!

queryCommand: aCommandQuery
	(#(#'closeCard' #'moveCardLeft' #'moveCardRight') includes: aCommandQuery command)  ifTrue: [
		aCommandQuery isEnabled: 1 < cardsPresenter view cards size. 
		^true.
	].
	^super queryCommand: aCommandQuery.

!

renameSelection

	MessageBox notify: 'Sorry, we are not yet prepared to handle this feature!!'.
	SessionManager current pause.
!

restoreLayoutAndContents

	self restoreLayoutAndContentsFromFile ifFalse: [
		self addSystemBrowserWithLayoutInfo: nil.
	].
!

restoreLayoutAndContentsFromFile

	| path file bytes data |
	path := self layoutFilePath.
	(File exists: path) ifFalse: [^false].
	file := File 
		open: path
		mode: #read.
	bytes := ByteArray new: file size.
	file read: bytes; close.
	data := Object fromBinaryStoreBytes: bytes.
	(data isKindOf: OrderedCollection) ifFalse: [File delete: path. ^false].
	(data at: 1) == 1 ifFalse: [File delete: path. ^false].
	(data at: 2) top < 0 ifTrue: [File delete: path. ^false].	"Occasionally the position seems to be bad"
	self view rectangle: (data at: 2).
	(data at: 3) do: [:each | 
		self addSystemBrowserWithLayoutInfo: each.
	].
	^true.
!

saveLayoutAndContents

	| data |
	data := OrderedCollection new
		add: 1;	"file version number"
		add: self view rectangle;
		add: (cardsPresenter view cards collect: [:each | each presenter layoutInfo]);
		yourself.
	(File 
		open: self layoutFilePath
		mode: #truncate 
		check: false)
		write: data binaryStoreBytes;
		close.
!

selectClass: classString selector: methodString

	self currentCard
		selectClass: classString 
		selector: methodString.
!

shellName

	^'System Browse'.
!

statusBarServerRequestText: aString

	roundTripCount := roundTripCount + 1.
	self statusBarText: 'Server request #' , roundTripCount printString , '; ' , aString.
!

statusBarText
	"for tests"

	^(self view viewNamed: 'statusBarField') model value!

statusBarText: aString
	(self view viewNamed: 'statusBarField') model: (ValueHolder with: aString).
!

systemBrowserPresenter
	^JadeAutoSystemBrowserPresenter!

update

	self currentCard ifNotNil: [:currentCard | currentCard onSetFocus].
! !
!JadeSystemBrowser categoriesForMethods!
abortTransaction!public! !
addSystemBrowser!public! !
addSystemBrowserForClass:!public! !
addSystemBrowserWithLayoutInfo:!public! !
addWorkspace!public! !
closeCard!public! !
closeRequested:!public! !
commitTransaction!public! !
createComponents!public! !
createSchematicWiring!history!public! !
currentCard!public! !
handleInvalidSession!public! !
initialize!public! !
isOkayToChange!public!testing! !
layoutFilePath!public! !
logoutRequested:!public! !
moveCardLeft!public! !
moveCardRight!public! !
onDropDown:!history!public! !
onViewOpened!public! !
queryCommand:!public! !
renameSelection!public! !
restoreLayoutAndContents!public! !
restoreLayoutAndContentsFromFile!public! !
saveLayoutAndContents!public! !
selectClass:selector:!public! !
shellName!overrides!private! !
statusBarServerRequestText:!public! !
statusBarText!public! !
statusBarText:!public! !
systemBrowserPresenter!public! !
update!public! !
!

!JadeSystemBrowser class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1801 1201 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 8 410 ##(Smalltalk.StatusBar) 34 18 nil 416 34 2 8 1409288460 1 592 nil 480 nil 7 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 498 193 193 nil 592 nil 8 1728651120 170 192 34 2 853766 ##(Smalltalk.StatusBarItem) 1 -1 592 nil 459270 ##(Smalltalk.Message) #displayString 8 #() 834 #iconImageIndex 8 #() 1049926 1 ##(Smalltalk.IconImageManager) 8 'statusBarField' 34 1 816 1115142 ##(Smalltalk.StatusBarNullItem) 513 1 592 nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 1 1039 498 1769 45 592 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 7 2 0 0 116 3 0 0 29 2 0 0] 8 #() 498 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 1266 #fixedParentRight 1 1266 #fixedParentBottom -43 1312 1 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409288972 131137 1328 nil 480 nil 519 nil 658 nil true 690 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 498 193 193 nil 1328 480 8 1728949632 170 192 8 #() 170 192 34 6 25047 1246790 1 ##(Smalltalk.ToolbarBitmapButton) 1328 1 1180998 4 ##(Smalltalk.CommandDescription) #moveCardRight 8 'Move Card Right' 1 1 nil 25047 657990 3 ##(Smalltalk.DIBSection) 1 true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'IdeaSpaceCardBar.bmp' nil nil 7 498 1 1 1 nil 3 25045 1538 1328 1 1570 #moveCardLeft 8 'Move Card Left' 1 1 nil 25045 1632 1 25049 1538 1328 1 1570 #closeCard 8 'Close Card' 1 1 nil 25049 1632 5 34 4 1049158 1 ##(Smalltalk.ToolbarSeparator) 1328 1 1712 1552 1760 nil nil 1 nil 498 33 33 498 45 45 nil 656198 1 ##(Smalltalk.FlowLayout) 1 1 1 1010 138 144 34 1 1074 #createAt:extent: 34 2 498 1609 1 498 161 51 1328 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 36 3 0 0 0 0 0 0 116 3 0 0 25 0 0 0] 8 #() 1216 nil 27 1234 1296 -159 1266 #fixedViewLeft 161 1266 #fixedParentTop 1 1266 #fixedViewTop 51 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409288972 131137 2144 nil 480 nil 519 nil 658 nil true 690 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 498 193 193 nil 2144 480 8 1728949632 170 192 1488 170 192 34 18 25017 1538 2144 1 1570 #browseUsers 8 'Browse Users' 1 1 nil 25017 395334 3 ##(Smalltalk.Bitmap) nil true 1664 8 'Tools.bmp' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil nil 7 498 1857 33 75 25013 1246790 1 ##(Smalltalk.ToolbarSystemButton) 2144 1 1570 #addWorkspace 8 'Add Workspace' 1 1 nil 25013 1 13 25009 1538 2144 1 1570 #abortTransaction 8 'Abort Transaction' 1 1 nil 25009 2400 1 25039 1115206 1 ##(Smalltalk.ToolbarIconButton) 2144 1 1570 #jadeBrowseTests 8 'Open SUnit Browser' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1664 8 'icons\UnitTestPlugin.ico' nil 25039 25043 2610 2144 17 1570 #historyForward 8 'History Forward' 1 1 2674 nil true 1664 8 'HistoryForward.ico' 2448 25043 25023 2610 2144 1 1570 #maximizeCode 8 'Maximize Code' 1 1 2674 nil true 1664 8 'Shell.ico' 2448 25023 25015 1538 2144 1 1570 #addSystemBrowser 8 'Add System Browser Tab' 1 1 nil 25015 2400 17 25011 1538 2144 1 1570 #commitTransaction 8 'Commit Transaction' 1 1 nil 25011 2400 27 25041 2610 2144 17 1570 #historyBack 8 'History Back' 1 1 2674 nil true 1664 8 'HistoryBack.ico' 2448 25041 34 13 2560 2928 1826 2144 1 2512 2880 2336 1826 2144 1 2800 1826 2144 1 2624 1826 2144 1 2976 2720 nil nil 1 nil 498 33 33 498 45 45 nil 1890 1 1 1 1010 138 144 34 1 1074 #createAt:extent: 34 2 498 -1 1 498 1611 51 2144 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 36 3 0 0 25 0 0 0] 8 #() 1216 nil 27 1234 1280 -1 1296 -159 2112 1 2128 51 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 3360 nil 480 nil 1031 nil nil nil 3360 656710 1 ##(Smalltalk.CardLayout) 138 144 1488 nil nil nil nil 170 192 1488 nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 3360 34 2 8 1140916736 1 3488 590662 2 ##(Smalltalk.ListModel) 138 144 1488 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) nil nil 1 nil nil nil 3488 nil 8 1728696064 787814 3 ##(Smalltalk.BlockClosure) 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 3664 7 257 nil 3650 0 nil 3682 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 3728 7 257 nil 928 nil nil nil nil nil #smallIcons nil nil nil nil nil 1010 138 144 34 2 1074 #createAt:extent: 34 2 498 1 1 498 1785 997 3488 1074 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 3488 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 124 3 0 0 242 1 0 0] 8 #() 1216 nil 27 1010 138 144 34 1 1074 #createAt:extent: 34 2 498 -7 51 498 1785 997 3360 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 252 255 255 255 25 0 0 0 120 3 0 0 11 2 0 0] 34 1 3488 1216 nil 27 1234 1280 -7 1296 9 2112 51 1312 -35 170 192 34 8 592 8 'statusBar' 1328 8 'rightToolbar' 2144 8 'leftToolbar' 3360 8 'cardContainer' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 1 265030 4 ##(Smalltalk.Menu) nil true 34 1 984134 2 ##(Smalltalk.CommandMenuItem) 1 1570 #close 8 'Exit' 1025 1 nil nil nil 8 'Jade' nil 134217729 nil nil 25087 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1010 138 144 34 2 1074 #createAt:extent: 34 2 498 6859 21 498 1801 1201 416 1074 #text: 34 1 8 'Jade System Browser' 416 1154 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 101 13 0 0 10 0 0 0 233 16 0 0 98 2 0 0] 34 4 2144 1328 3360 592 1216 nil 27 )! !
!JadeSystemBrowser class categoriesForMethods!
resource_Default_view!public!resources-views! !
!

