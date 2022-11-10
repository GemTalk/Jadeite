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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.DialogView) 34 30 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1201 801 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 592 nil nil nil 7 nil nil nil 592 530 170 176 34 14 410 ##(Smalltalk.StaticText) 34 16 nil 592 34 2 8 1140850944 65 704 nil nil nil 7 nil nil nil 704 nil 8 1607531712 852486 ##(Smalltalk.NullConverter) nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 11 11 498 101 61 704 882 #text: 34 1 8 'Path:
' 704 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 5 0 0 0 55 0 0 0 35 0 0 0] 8 #() 498 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 11 1136 111 1122 #fixedParentTop 11 1122 #fixedViewTop 61 410 ##(Smalltalk.EditableListView) 34 55 nil 592 34 2 8 1140936781 1025 1184 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 nil nil nil 1184 nil 8 1607618784 ##(Smalltalk.BasicListAbstract) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 5 1 1360 8 'doIt' 8 '[:assoc | assoc value ifTrue:[Icon fromId: ''Folder.ico''] ifFalse:[0]]' 8 #[32 105 17 142 121 45 30 178 106 62 106] 983558 ##(Smalltalk.VariableBinding) #Icon ##(Smalltalk.Icon) 8 'Folder.ico' #fromId: 1376 #ifTrue:ifFalse: 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil 498 65 65 nil nil 138 144 34 1 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Column 1' 1141 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 1362 0 nil 1394 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:assoc | assoc key]' 8 #[30 105 226 0 106] #key 1648 7 257 nil nil 1184 nil 3 nil nil false nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 1744 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 1744 nil nil 786 nil 8 '' 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 818 138 144 34 2 882 #createAt:extent: 34 2 498 11 101 498 1149 543 1184 882 #text: 34 1 8 'Column 1' 1184 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 50 0 0 0 67 2 0 0 65 1 0 0] 8 #() 1072 nil 33 1090 1136 11 1122 #fixedParentRight -9 1152 101 1122 #fixedParentBottom -79 410 ##(Smalltalk.PushButton) 34 20 nil 592 34 2 8 1140924416 1 2144 nil nil nil 7 nil nil nil 2144 nil 8 1607683504 1180998 4 ##(Smalltalk.CommandDescription) #cancel 8 'Cancel' 1 1 nil nil false nil nil nil 818 138 144 34 2 882 #createAt:extent: 34 2 498 959 653 498 201 61 2144 882 #text: 34 1 8 'Cancel' 2144 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 223 1 0 0 70 1 0 0 67 2 0 0 100 1 0 0] 8 #() 1072 nil 29 1090 2112 -209 2112 -9 2128 -69 2128 -9 410 ##(Smalltalk.TextEdit) 34 16 nil 592 34 2 8 1149239424 1 2496 1778 nil false 1824 nil nil nil 7 nil nil nil 2496 nil 8 1607675312 786 nil nil 1 818 138 144 34 2 882 #createAt:extent: 34 2 498 11 653 498 729 61 2496 882 #setMarginWidths: 34 1 8 #(3 3) 2496 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 70 1 0 0 113 1 0 0 100 1 0 0] 8 #() 1072 nil 27 1090 1136 11 2112 -429 2128 -69 2128 -9 410 ##(Smalltalk.TextEdit) 34 16 nil 592 34 2 8 1149239424 1 2832 1778 nil false 1824 nil nil nil 7 nil nil nil 2832 nil 8 1607675312 786 nil nil 1 818 138 144 34 3 882 #createAt:extent: 34 2 498 111 21 498 931 61 2832 882 #text: 34 1 8 'c:\Program Files\Dolphin Smalltalk' 2832 882 #setMarginWidths: 34 1 8 #(3 3) 2832 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 55 0 0 0 10 0 0 0 8 2 0 0 40 0 0 0] 8 #() 1072 nil 27 1090 1136 111 2112 -127 1152 21 1168 61 410 ##(Smalltalk.PushButton) 34 20 nil 592 34 2 8 1140924416 1 3216 nil nil nil 7 nil nil nil 3216 nil 8 1607683504 2226 #save 8 'Save' 1 1 nil nil false nil nil nil 818 138 144 34 3 882 #createAt:extent: 34 2 498 749 653 498 211 61 3216 882 #isEnabled: 8 #(false) 3216 882 #text: 34 1 8 'Save' 3216 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 118 1 0 0 70 1 0 0 223 1 0 0 100 1 0 0] 8 #() 1072 nil 29 1090 2112 -419 2112 -209 2128 -69 2128 -9 410 ##(Smalltalk.ToolButton) 34 14 nil 592 34 2 8 1140850688 131073 3584 nil nil nil 7 nil nil nil 3584 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 3584 34 2 8 1140853580 131137 3648 nil nil nil 3 nil nil nil 3648 nil 8 1607642496 nil 170 192 34 2 13373 1115206 1 ##(Smalltalk.ToolbarIconButton) 3648 1 2226 #pop 8 'Pop' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons\FolderUp.ico' nil 13373 34 1 3776 nil nil 3 nil 498 49 49 498 71 51 nil nil 818 138 144 34 1 882 #createAt:extent: 34 2 498 1 1 498 81 61 3648 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 40 0 0 0 30 0 0 0] 8 #() 1072 nil 27 818 138 144 34 2 882 #createAt:extent: 34 2 498 1059 11 498 81 61 3584 882 #isEnabled: 8 #(false) 3584 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 17 2 0 0 5 0 0 0 57 2 0 0 35 0 0 0] 34 1 3648 1072 nil 27 1090 2112 -109 2112 -29 1152 11 1168 61 170 192 34 8 2496 8 'fileName' 1184 8 'directoryContentsList' 3584 8 'upButton' 2832 8 'pathText' nil 818 138 144 34 1 882 #createAt:extent: 34 2 498 1 1 498 1169 723 592 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 105 1 0 0] 34 7 2832 704 3216 3584 2144 1184 2496 1072 nil 27 1090 1136 1 2112 1 1152 1 2128 1 170 192 1296 590342 ##(Smalltalk.Rectangle) 498 1 1 498 1 1 nil nil nil nil 3 nil nil nil nil 1 nil nil 590598 ##(Smalltalk.Semaphore) nil nil 1 false 8 1998138720 818 138 144 34 1 882 #createAt:extent: 34 2 498 7311 21 498 1201 801 416 1010 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 71 14 0 0 10 0 0 0 159 16 0 0 154 1 0 0] 34 1 592 1072 nil 27 )!

showNonModalOnSession: aGciSession initialFileName: fileName
	| inst |
	"for testing only"
	inst := self instantiateOnSession: aGciSession initialFileName: fileName.
	inst show.
	^inst!

showOnSession: aGciSession defaultFilePath: path
	"assumes path is a full path + file name" 
	| inst answer  |
	inst := self createDialogOn: aGciSession path: path.
	inst fileNamePresenter value: inst fileSelectorPresenter fileName.
	inst fileSelectorPresenter setPath:  inst fileSelectorPresenter parentDirectoryPath.  
	inst showDirectoryContents. 
	answer := inst showModal.
	^answer ifNil: [nil] ifNotNil: [inst pathText value]!

showOnSession: aGciSession initialFileName: fileName
	"assumes default $ROWAN_PROJECTS_HOME directory"
	| inst answer |
	inst := self instantiateOnSession: aGciSession initialFileName: fileName.
	answer := inst showModal.
	^answer ifNil: [nil] ifNotNil: [inst pathText value]! !
!JadeiteServerFileSaveDialog class categoriesForMethods!
instantiateOnSession:initialFileName:!instance creation!private! !
resource_Default_view!public!resources-views! !
showNonModalOnSession:initialFileName:!instance creation!public! !
showOnSession:defaultFilePath:!instance creation!public! !
showOnSession:initialFileName:!instance creation!public! !
!

