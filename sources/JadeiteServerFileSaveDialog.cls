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

answer
	^self isConfirmed
		ifTrue: [ fileSelectorPresenter pathText value ]
		ifFalse: [ nil ]!

createComponents
	super createComponents.
	fileNamePresenter := self add: TextPresenter new name: 'fileName'.!

fileNamePresenter
	^fileNamePresenter!

goto
	model value path: fileSelectorPresenter pathText value.
	self showDirectoryContents!

pop

	^fileSelectorPresenter pop!

save
	model value path = fileSelectorPresenter pathText value ifFalse: [^self goto].
	fileSelectorPresenter pathText
		value: fileSelectorPresenter pathText value , '/' , fileNamePresenter value.
	self ok! !
!JadeiteServerFileSaveDialog categoriesForMethods!
answer!public! !
createComponents!initialization!public! !
fileNamePresenter!accessing!private! !
goto!actions!public! !
pop!actions!public! !
save!actions!public! !
!

!JadeiteServerFileSaveDialog class methodsFor!

instantiateOnSession: aGciSession initialFileName: fileName
	| service inst |
	service := RowanFileService new path: JadePresenter rowanProjectsHomeEnvVarString.
	service session: aGciSession.
	inst := self createOn: service.
	inst setPresenterModel.
	inst fileNamePresenter value: fileName.
	inst pathText value: service path.
	inst showDirectoryContents.
	^inst!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.DialogView) 34 30 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1201 801 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 592 nil nil nil 7 nil nil nil 592 530 170 176 34 14 410 ##(Smalltalk.PushButton) 34 20 nil 592 34 2 8 1140924416 1 704 nil nil nil 7 nil nil nil 704 nil 8 1607683504 1180998 4 ##(Smalltalk.CommandDescription) #save 8 'Save' 1 1 nil nil false nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 749 653 498 211 61 704 898 #isEnabled: 8 #(false) 704 898 #text: 34 1 8 'Save' 704 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 118 1 0 0 70 1 0 0 223 1 0 0 100 1 0 0] 8 #() 498 193 193 nil 29 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentRight -419 1184 -209 1170 #fixedParentBottom -69 1200 -9 410 ##(Smalltalk.EditableListView) 34 55 nil 592 34 2 8 1140936781 1025 1216 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 nil nil nil 1216 nil 8 1607618784 ##(Smalltalk.BasicListAbstract) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 5 1 1392 8 'doIt' 8 '[:assoc | assoc value ifTrue:[Icon fromId: ''Folder.ico''] ifFalse:[0]]' 8 #[32 105 17 142 121 45 30 178 106 62 106] 983558 ##(Smalltalk.VariableBinding) #Icon ##(Smalltalk.Icon) 8 'Folder.ico' #fromId: 1408 #ifTrue:ifFalse: 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil 498 65 65 nil nil 138 144 34 1 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Column 1' 1141 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 1394 0 nil 1426 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:assoc | assoc key]' 8 #[30 105 226 0 106] #key 1680 7 257 nil nil 1216 nil 3 nil nil false nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 1776 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 1776 nil nil 852486 ##(Smalltalk.NullConverter) nil 8 '' 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 834 138 144 34 2 898 #createAt:extent: 34 2 498 11 101 498 1149 543 1216 898 #text: 34 1 8 'Column 1' 1216 1058 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 50 0 0 0 67 2 0 0 65 1 0 0] 8 #() 1120 nil 33 1138 1170 #fixedParentLeft 11 1184 -9 1170 #fixedParentTop 101 1200 -79 410 ##(Smalltalk.PushButton) 34 20 nil 592 34 2 8 1140924416 1 2192 nil nil nil 7 nil nil nil 2192 nil 8 1607683504 786 #cancel 8 'Cancel' 1 1 nil nil false nil nil nil 834 138 144 34 2 898 #createAt:extent: 34 2 498 959 653 498 201 61 2192 898 #text: 34 1 8 'Cancel' 2192 1058 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 223 1 0 0 70 1 0 0 67 2 0 0 100 1 0 0] 8 #() 1120 nil 29 1138 1184 -209 1184 -9 1200 -69 1200 -9 410 ##(Smalltalk.TextEdit) 34 16 nil 592 34 2 8 1149239424 1 2528 1810 nil false 1856 nil nil nil 7 nil nil nil 2528 nil 8 1607675312 1874 nil nil 1 834 138 144 34 2 898 #createAt:extent: 34 2 498 15 649 498 721 61 2528 898 #setMarginWidths: 34 1 8 #(3 3) 2528 1058 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 7 0 0 0 68 1 0 0 111 1 0 0 98 1 0 0] 8 #() 1120 nil 27 1138 2160 15 1170 #fixedViewLeft 721 2176 649 1170 #fixedViewTop 61 410 ##(Smalltalk.StaticText) 34 16 nil 592 34 2 8 1140850944 65 2896 nil nil nil 7 nil nil nil 2896 nil 8 1607531712 1874 nil nil nil 834 138 144 34 2 898 #createAt:extent: 34 2 498 11 11 498 101 61 2896 898 #text: 34 1 8 'Path:
' 2896 1058 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 5 0 0 0 55 0 0 0 35 0 0 0] 8 #() 1120 nil 27 1138 2160 11 2160 111 2176 11 2880 61 410 ##(Smalltalk.TextEdit) 34 16 nil 592 34 2 8 1149239424 1 3216 1810 nil false 1856 nil nil nil 7 nil nil nil 3216 nil 8 1607675312 1874 nil nil 1 834 138 144 34 3 898 #createAt:extent: 34 2 498 111 21 498 931 61 3216 898 #text: 34 1 8 'c:\Program Files\Dolphin Smalltalk' 3216 898 #setMarginWidths: 34 1 8 #(3 3) 3216 1058 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 55 0 0 0 10 0 0 0 8 2 0 0 40 0 0 0] 8 #() 1120 nil 27 1138 2160 111 1184 -127 2176 21 2880 61 410 ##(Smalltalk.ToolButton) 34 14 nil 592 34 2 8 1140850688 131073 3600 nil nil nil 7 nil nil nil 3600 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 3600 34 2 8 1140853580 131137 3664 nil nil nil 3 nil nil nil 3664 nil 8 1607642496 nil 170 192 34 2 48591 1115206 1 ##(Smalltalk.ToolbarIconButton) 3664 1 786 #pop 8 'Pop' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons\FolderUp.ico' nil 48591 34 1 3792 nil nil 3 nil 498 49 49 498 71 51 nil nil 834 138 144 34 1 898 #createAt:extent: 34 2 498 1 1 498 81 61 3664 1058 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 40 0 0 0 30 0 0 0] 8 #() 1120 nil 27 834 138 144 34 1 898 #createAt:extent: 34 2 498 1059 11 498 81 61 3600 1058 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 17 2 0 0 5 0 0 0 57 2 0 0 35 0 0 0] 34 1 3664 1120 nil 27 1138 1184 -109 1184 -29 2176 11 2880 61 170 192 34 8 3600 8 'upButton' 2528 8 'fileName' 1216 8 'directoryContentsList' 3216 8 'pathText' nil 834 138 144 34 1 898 #createAt:extent: 34 2 498 1 1 498 1169 723 592 1058 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 105 1 0 0] 34 7 3216 2896 704 3600 2192 1216 2528 1120 nil 27 1138 2160 1 1184 1 2176 1 1200 1 170 192 1328 590342 ##(Smalltalk.Rectangle) 498 1 1 498 1 1 nil nil nil nil 3 nil nil nil nil 1 nil nil 590598 ##(Smalltalk.Semaphore) nil nil 1 false 8 1998138720 834 138 144 34 1 898 #createAt:extent: 34 2 498 6911 21 498 1201 801 416 1058 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 127 13 0 0 10 0 0 0 215 15 0 0 154 1 0 0] 34 1 592 1120 nil 27 )!

showNonModalOnSession: aGciSession initialFileName: fileName
	| inst |
	"for testing only"
	inst := self instantiateOnSession: aGciSession initialFileName: fileName.
	inst show.
	^inst!

showOnSession: aGciSession initialFileName: fileName
	| inst answer |
	inst := self instantiateOnSession: aGciSession initialFileName: fileName.
	answer := inst showModal.
	^answer ifNil: [nil] ifNotNil: [inst pathText value]! !
!JadeiteServerFileSaveDialog class categoriesForMethods!
instantiateOnSession:initialFileName:!instance creation!private! !
resource_Default_view!public!resources-views! !
showNonModalOnSession:initialFileName:!instance creation!public! !
showOnSession:initialFileName:!instance creation!public! !
!

