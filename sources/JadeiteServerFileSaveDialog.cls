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
	model value = pathText value ifFalse: [self goto].
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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.DialogView) 34 30 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1201 801 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 592 nil nil nil 7 nil nil nil 592 530 170 176 34 14 410 ##(Smalltalk.TextEdit) 34 16 nil 592 34 2 8 1149239424 1 704 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 7 nil nil nil 704 nil 8 1595878832 852486 ##(Smalltalk.NullConverter) nil nil 1 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 111 21 498 931 61 704 946 #text: 34 1 8 'c:\Program Files\Dolphin Smalltalk' 704 946 #setMarginWidths: 34 1 8 #(3 3) 704 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 55 0 0 0 10 0 0 0 8 2 0 0 40 0 0 0] 8 #() 498 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 111 1234 #fixedParentRight -127 1234 #fixedParentTop 21 1234 #fixedViewTop 61 410 ##(Smalltalk.StaticText) 34 16 nil 592 34 2 8 1140850944 65 1312 nil nil nil 7 nil nil nil 1312 nil 8 1595735232 850 nil nil nil 882 138 144 34 2 946 #createAt:extent: 34 2 498 11 11 498 101 61 1312 946 #text: 34 1 8 'Path:
' 1312 1122 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 5 0 0 0 55 0 0 0 35 0 0 0] 8 #() 1184 nil 27 1202 1248 11 1248 111 1280 11 1296 61 410 ##(Smalltalk.ToolButton) 34 14 nil 592 34 2 8 1140850688 131073 1632 nil nil nil 7 nil nil nil 1632 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 1632 34 2 8 1140853580 131137 1696 nil nil nil 3 nil nil nil 1696 nil 8 1595846016 nil 170 192 34 2 11395 1115206 1 ##(Smalltalk.ToolbarIconButton) 1696 1 1180998 4 ##(Smalltalk.CommandDescription) #pop 8 'Pop' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'FolderUp.ico' nil 11395 34 1 1824 nil nil 3 nil 498 49 49 498 71 51 nil nil 882 138 144 34 1 946 #createAt:extent: 34 2 498 1 1 498 81 61 1696 1122 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 40 0 0 0 30 0 0 0] 8 #() 1184 nil 27 882 138 144 34 2 946 #createAt:extent: 34 2 498 1059 11 498 81 61 1632 946 #isEnabled: 8 #(false) 1632 1122 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 17 2 0 0 5 0 0 0 57 2 0 0 35 0 0 0] 34 1 1696 1184 nil 27 1202 1264 -109 1264 -29 1280 11 1296 61 410 ##(Smalltalk.PushButton) 34 20 nil 592 34 2 8 1140924416 1 2384 nil nil nil 7 nil nil nil 2384 nil 8 1595887024 1842 #cancel 8 'Cancel' 1 1 nil nil false nil nil nil 882 138 144 34 2 946 #createAt:extent: 34 2 498 959 653 498 201 61 2384 946 #text: 34 1 8 'Cancel' 2384 1122 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 223 1 0 0 70 1 0 0 67 2 0 0 100 1 0 0] 8 #() 1184 nil 29 1202 1264 -209 1264 -9 1234 #fixedParentBottom -69 2720 -9 410 ##(Smalltalk.PushButton) 34 20 nil 592 34 2 8 1140924416 1 2736 nil nil nil 7 nil nil nil 2736 nil 8 1595887024 1842 #save 8 'Save' 1 1 nil nil false nil nil nil 882 138 144 34 3 946 #createAt:extent: 34 2 498 749 653 498 211 61 2736 946 #isEnabled: 8 #(false) 2736 946 #text: 34 1 8 'Save' 2736 1122 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 118 1 0 0 70 1 0 0 223 1 0 0 100 1 0 0] 8 #() 1184 nil 29 1202 1264 -419 1264 -209 2720 -69 2720 -9 410 ##(Smalltalk.TextEdit) 34 16 nil 592 34 2 8 1149239424 1 3104 770 nil false 816 nil nil nil 7 nil nil nil 3104 nil 8 1595878832 850 nil nil 1 882 138 144 34 2 946 #createAt:extent: 34 2 498 15 649 498 721 61 3104 946 #setMarginWidths: 34 1 8 #(3 3) 3104 1122 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 7 0 0 0 68 1 0 0 111 1 0 0 98 1 0 0] 8 #() 1184 nil 27 1202 1248 15 1234 #fixedViewLeft 721 1280 649 1296 61 410 ##(Smalltalk.EditableListView) 34 55 nil 592 34 2 8 1140936781 1025 3456 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 nil nil nil 3456 nil 8 1595822304 ##(Smalltalk.BasicListAbstract) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 5 1 3632 8 'doIt' 8 '[:assoc | assoc value ifTrue:[Icon fromId: ''Folder.ico''] ifFalse:[0]]' 8 #[32 105 17 142 121 45 30 178 106 62 106] 983558 ##(Smalltalk.VariableBinding) #Icon 1888 8 'Folder.ico' #fromId: 3648 #ifTrue:ifFalse: 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil 498 65 65 nil nil 138 144 34 1 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Column 1' 1141 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 3634 0 nil 3666 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:assoc | assoc key]' 8 #[30 105 226 0 106] #key 3920 7 257 nil nil 3456 nil 3 nil nil false nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 4016 770 nil false 816 nil nil nil 5 nil nil nil 4016 nil nil 850 nil 8 '' 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 882 138 144 34 2 946 #createAt:extent: 34 2 498 11 101 498 1149 543 3456 946 #text: 34 1 8 'Column 1' 3456 1122 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 50 0 0 0 67 2 0 0 65 1 0 0] 8 #() 1184 nil 33 1202 1248 11 1264 -9 1280 101 2720 -79 170 192 34 6 3104 8 'fileName' 704 8 'pathText' 3456 8 'directoryContentsList' nil 882 138 144 34 1 946 #createAt:extent: 34 2 498 1 1 498 1169 723 592 1122 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 105 1 0 0] 34 7 704 1312 2736 1632 2384 3456 3104 1184 nil 27 1202 1248 1 1264 1 1280 1 2720 1 170 192 3568 590342 ##(Smalltalk.Rectangle) 498 1 1 498 1 1 nil nil nil nil 9595 nil nil nil nil 1 nil nil 590598 ##(Smalltalk.Semaphore) nil nil 1 false 8 2008427872 882 138 144 34 1 946 #createAt:extent: 34 2 498 7515 21 498 1201 801 416 1122 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 173 14 0 0 10 0 0 0 5 17 0 0 154 1 0 0] 34 1 592 1184 nil 27 )!

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

