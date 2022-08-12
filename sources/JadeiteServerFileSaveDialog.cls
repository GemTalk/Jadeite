"Filed out from Dolphin Smallalk"!

JadeiteServerFileSelectorDialog subclass: #JadeiteServerFileSaveDialog
	instanceVariableNames: 'fileNamePresenter'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteServerFileSaveDialog guid: (GUID fromString: '{5a3ac76f-a5d7-4092-b360-64424c5be56b}')!
JadeiteServerFileSaveDialog comment: ''!
!JadeiteServerFileSaveDialog categoriesForClass!Unclassified! !
!JadeiteServerFileSaveDialog methodsFor!

createComponents
	super createComponents.
	fileNamePresenter := self add: TextPresenter new name: 'fileName'!

fileNamePresenter
	^fileNamePresenter!

save
	model value = pathText value ifFalse: [^self goto].
	pathText value: (pathText value , '/' , fileNamePresenter value).
	self ok.
	! !
!JadeiteServerFileSaveDialog categoriesForMethods!
createComponents!initialization!public! !
fileNamePresenter!accessing!private! !
save!actions!public! !
!

!JadeiteServerFileSaveDialog class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.DialogView) 34 30 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1201 801 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 592 nil nil nil 7 nil nil nil 592 530 170 176 34 14 410 ##(Smalltalk.PushButton) 34 20 nil 592 34 2 8 1140924416 1 704 nil nil nil 7 nil nil nil 704 nil 8 1582648752 1180998 4 ##(Smalltalk.CommandDescription) #cancel 8 'Cancel' 1 1 nil nil false nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 959 653 498 201 61 704 898 #text: 34 1 8 'Cancel' 704 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 223 1 0 0 70 1 0 0 67 2 0 0 100 1 0 0] 8 #() 498 193 193 nil 29 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentRight -209 1152 -9 1138 #fixedParentBottom -69 1168 -9 410 ##(Smalltalk.EditableListView) 34 55 nil 592 34 2 8 1140936781 1025 1184 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 nil nil nil 1184 nil 8 1582584032 ##(Smalltalk.BasicListAbstract) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 5 1 1360 8 'doIt' 8 '[:assoc | assoc value ifTrue:[Icon fromId: ''Folder.ico''] ifFalse:[0]]' 8 #[32 105 17 142 121 45 30 178 106 62 106] 983558 ##(Smalltalk.VariableBinding) #Icon ##(Smalltalk.Icon) 8 'Folder.ico' #fromId: 1376 #ifTrue:ifFalse: 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil 498 65 65 nil nil 138 144 34 1 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Column 1' 1141 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 1362 0 nil 1394 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:assoc | assoc key]' 8 #[30 105 226 0 106] #key 1648 7 257 nil nil 1184 nil 3 nil nil false nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 1744 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 1744 nil nil 852486 ##(Smalltalk.NullConverter) nil 8 '' 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 834 138 144 34 2 898 #createAt:extent: 34 2 498 11 101 498 1149 543 1184 898 #text: 34 1 8 'Column 1' 1184 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 50 0 0 0 67 2 0 0 65 1 0 0] 8 #() 1088 nil 33 1106 1138 #fixedParentLeft 11 1152 -9 1138 #fixedParentTop 101 1168 -79 410 ##(Smalltalk.StaticText) 34 16 nil 592 34 2 8 1140850944 65 2160 nil nil nil 7 nil nil nil 2160 nil 8 1582496960 1842 nil nil nil 834 138 144 34 2 898 #createAt:extent: 34 2 498 11 11 498 101 61 2160 898 #text: 34 1 8 'Path:
' 2160 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 5 0 0 0 55 0 0 0 35 0 0 0] 8 #() 1088 nil 27 1106 2128 11 2128 111 2144 11 1138 #fixedViewTop 61 410 ##(Smalltalk.TextEdit) 34 16 nil 592 34 2 8 1149239424 1 2496 1778 nil false 1824 nil nil nil 7 nil nil nil 2496 nil 8 1582640560 1842 nil nil 1 834 138 144 34 3 898 #createAt:extent: 34 2 498 111 21 498 931 61 2496 898 #text: 34 1 8 'c:\Program Files\Dolphin Smalltalk' 2496 898 #setMarginWidths: 34 1 8 #(3 3) 2496 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 55 0 0 0 10 0 0 0 8 2 0 0 40 0 0 0] 8 #() 1088 nil 27 1106 2128 111 1152 -127 2144 21 2480 61 410 ##(Smalltalk.ToolButton) 34 14 nil 592 34 2 8 1140850688 131073 2880 nil nil nil 7 nil nil nil 2880 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 2880 34 2 8 1140853580 131137 2944 nil nil nil 3 nil nil nil 2944 nil 8 1582607744 nil 170 192 34 2 11929 1115206 1 ##(Smalltalk.ToolbarIconButton) 2944 1 786 #pop 8 'Pop' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons\FolderUp.ico' nil 11929 34 1 3072 nil nil 3 nil 498 49 49 498 71 51 nil nil 834 138 144 34 1 898 #createAt:extent: 34 2 498 1 1 498 81 61 2944 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 40 0 0 0 30 0 0 0] 8 #() 1088 nil 27 834 138 144 34 2 898 #createAt:extent: 34 2 498 1059 11 498 81 61 2880 898 #isEnabled: 8 #(false) 2880 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 17 2 0 0 5 0 0 0 57 2 0 0 35 0 0 0] 34 1 2944 1088 nil 27 1106 1152 -109 1152 -29 2144 11 2480 61 410 ##(Smalltalk.TextEdit) 34 16 nil 592 34 2 8 1149239424 1 3616 1778 nil false 1824 nil nil nil 7 nil nil nil 3616 nil 8 1582640560 1842 nil nil 1 834 138 144 34 2 898 #createAt:extent: 34 2 498 15 649 498 721 61 3616 898 #setMarginWidths: 34 1 8 #(3 3) 3616 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 7 0 0 0 68 1 0 0 111 1 0 0 98 1 0 0] 8 #() 1088 nil 27 1106 2128 15 1138 #fixedViewLeft 721 2144 649 2480 61 410 ##(Smalltalk.PushButton) 34 20 nil 592 34 2 8 1140924416 1 3968 nil nil nil 7 nil nil nil 3968 nil 8 1582648752 786 #save 8 'Save' 1 1 nil nil true nil nil nil 834 138 144 34 3 898 #createAt:extent: 34 2 498 749 653 498 211 61 3968 898 #isEnabled: 8 #(false) 3968 898 #text: 34 1 8 'Save' 3968 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 118 1 0 0 70 1 0 0 223 1 0 0 100 1 0 0] 8 #() 1088 nil 29 1106 1152 -419 1152 -209 1168 -69 1168 -9 170 192 34 6 1184 8 'directoryContentsList' 3616 8 'fileName' 2496 8 'pathText' nil 834 138 144 34 1 898 #createAt:extent: 34 2 498 1 1 498 1169 723 592 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 105 1 0 0] 34 7 2496 2160 3968 2880 704 1184 3616 1088 nil 27 1106 2128 1 1152 1 2144 1 1168 1 170 192 1296 590342 ##(Smalltalk.Rectangle) 498 1 1 498 1 1 nil nil nil nil 10573 nil nil nil nil 1 nil nil 590598 ##(Smalltalk.Semaphore) nil nil 1 false 8 2003643744 834 138 144 34 1 898 #createAt:extent: 34 2 498 6683 21 498 1201 801 416 1026 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 13 13 0 0 10 0 0 0 101 15 0 0 154 1 0 0] 34 1 592 1088 nil 27 )!

showOnSession: aGciSession initialFileName: fileName
	| inst service answer |
	service := RowanFileService new path: JadePresenter rowanProjectsHomeEnvVarString.
	service session: aGciSession.
	inst := self createOn: service.
	inst fileNamePresenter value: fileName. 
	inst pathText value: service path.
	inst showDirectoryContents.
	answer := inst showModal.
	^answer ifNil: [nil] ifNotNil: [inst pathText value]! !
!JadeiteServerFileSaveDialog class categoriesForMethods!
resource_Default_view!public!resources-views! !
showOnSession:initialFileName:!instance creation!public! !
!

