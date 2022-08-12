"Filed out from Dolphin Smallalk"!

Dialog subclass: #JadeiteServerFileSelectorDialog
	instanceVariableNames: 'directoryContentsList pathText'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteServerFileSelectorDialog guid: (GUID fromString: '{70f59a0e-a3b1-4740-ab3e-4b15f70b06a0}')!
JadeiteServerFileSelectorDialog comment: ''!
!JadeiteServerFileSelectorDialog categoriesForClass!Unclassified! !
!JadeiteServerFileSelectorDialog methodsFor!

cancel
	super cancel. 
	^nil!

createComponents
	super createComponents.
	directoryContentsList := self add: ListPresenter new name: 'directoryContentsList'.
	pathText := self add: TextPresenter new name: 'pathText'!

createSchematicWiring
	super createSchematicWiring.
	directoryContentsList
		when: #actionPerformed
		send: #dive
		to: self.
	pathText
		when: #focusLost
		send: #goto
		to: self.
	!

dive
	(model value isDirectory: directoryContentsList selection key)
		ifTrue: 
			[pathText value: pathText value , '/' , directoryContentsList selection key.
			model value path: pathText value.
			self showDirectoryContents]
		ifFalse: [self select]!

goto
	model value path: pathText value.
	self showDirectoryContents!

logoutRequested: aValueHolder
	"Private - Opportunity to save changes."

	aValueHolder value: true.!

pathText
	^pathText!

pathText: anObject
	pathText := anObject!

pop
	model value path: pathText value. 
	directoryContentsList list: model value pop.
	pathText value: model value path!

select
	| folder |
	model value path = pathText value ifFalse:[^self goto]. 
	folder := directoryContentsList selectionOrNil ifNil: [String new] ifNotNil: [:sel | sel key].
	pathText value: pathText value , '/' , folder.
	self ok.
	^pathText value!

showDirectoryContents
	| directoryContents |
	directoryContents := model value directoryContents.
	directoryContentsList list: directoryContents!

updateCaption
	self caption: (model value session titleBarFor: 'Server File Selector')! !
!JadeiteServerFileSelectorDialog categoriesForMethods!
cancel!actions!public! !
createComponents!initialization!public! !
createSchematicWiring!initialization!public! !
dive!actions!public! !
goto!actions!public! !
logoutRequested:!event handlers!private! !
pathText!accessing!private! !
pathText:!accessing!private! !
pop!actions!public! !
select!actions!public! !
showDirectoryContents!actions!public! !
updateCaption!public! !
!

!JadeiteServerFileSelectorDialog class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.DialogView) 34 30 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1201 801 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 592 nil nil nil 7 nil nil nil 592 530 170 176 34 12 410 ##(Smalltalk.EditableListView) 34 55 nil 592 34 2 8 1140936781 1025 704 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 nil nil nil 704 nil 8 1582584032 ##(Smalltalk.BasicListAbstract) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 5 1 880 8 'doIt' 8 '[:assoc | assoc value ifTrue:[Icon fromId: ''Folder.ico''] ifFalse:[0]]' 8 #[32 105 17 142 121 45 30 178 106 62 106] 983558 ##(Smalltalk.VariableBinding) #Icon ##(Smalltalk.Icon) 8 'Folder.ico' #fromId: 896 #ifTrue:ifFalse: 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil 498 65 65 nil nil 138 144 34 1 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Column 1' 1141 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 882 0 nil 914 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:assoc | assoc key]' 8 #[30 105 226 0 106] #key 1168 7 257 nil nil 704 nil 3 nil nil false nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 1264 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 1264 nil nil 852486 ##(Smalltalk.NullConverter) nil 8 '' 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 11 101 498 1149 543 704 1490 #text: 34 1 8 'Column 1' 704 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 50 0 0 0 67 2 0 0 65 1 0 0] 8 #() 498 193 193 nil 33 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 11 1730 #fixedParentRight -9 1730 #fixedParentTop 101 1730 #fixedParentBottom -79 410 ##(Smalltalk.PushButton) 34 20 nil 592 34 2 8 1140924416 1 1808 nil nil nil 7 nil nil nil 1808 nil 8 1582648752 1180998 4 ##(Smalltalk.CommandDescription) #select 8 'Select' 1 1 nil nil true nil nil nil 1426 138 144 34 3 1490 #createAt:extent: 34 2 498 749 653 498 211 61 1808 1490 #isEnabled: 8 #(false) 1808 1490 #text: 34 1 8 'Select' 1808 1618 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 118 1 0 0 70 1 0 0 223 1 0 0 100 1 0 0] 8 #() 1680 nil 29 1698 1760 -419 1760 -209 1792 -69 1792 -9 410 ##(Smalltalk.TextEdit) 34 16 nil 592 34 2 8 1149239424 1 2192 1298 nil false 1344 nil nil nil 7 nil nil nil 2192 nil 8 1582640560 1362 nil nil 1 1426 138 144 34 3 1490 #createAt:extent: 34 2 498 121 11 498 909 61 2192 1490 #text: 34 1 8 'c:\Program Files\Dolphin Smalltalk' 2192 1490 #setMarginWidths: 34 1 8 #(3 3) 2192 1618 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 60 0 0 0 5 0 0 0 2 2 0 0 35 0 0 0] 8 #() 1680 nil 27 1698 1744 121 1760 -139 1776 11 1730 #fixedViewTop 61 410 ##(Smalltalk.StaticText) 34 16 nil 592 34 2 8 1140850944 65 2592 nil nil nil 7 nil nil nil 2592 nil 8 1582496960 1362 nil nil nil 1426 138 144 34 2 1490 #createAt:extent: 34 2 498 11 11 498 101 61 2592 1490 #text: 34 1 8 'Path:
' 2592 1618 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 5 0 0 0 55 0 0 0 35 0 0 0] 8 #() 1680 nil 27 1698 1744 11 1744 111 1776 11 2576 61 410 ##(Smalltalk.ToolButton) 34 14 nil 592 34 2 8 1140850688 131073 2912 nil nil nil 7 nil nil nil 2912 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 2912 34 2 8 1140853580 131137 2976 nil nil nil 3 nil nil nil 2976 nil 8 1582607744 nil 170 192 34 2 9451 1115206 1 ##(Smalltalk.ToolbarIconButton) 2976 1 1890 #pop 8 'Pop' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons\FolderUp.ico' nil 9451 34 1 3104 nil nil 3 nil 498 49 49 498 71 51 nil nil 1426 138 144 34 1 1490 #createAt:extent: 34 2 498 1 1 498 81 61 2976 1618 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 40 0 0 0 30 0 0 0] 8 #() 1680 nil 27 1426 138 144 34 2 1490 #createAt:extent: 34 2 498 1059 11 498 81 61 2912 1490 #isEnabled: 8 #(false) 2912 1618 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 17 2 0 0 5 0 0 0 57 2 0 0 35 0 0 0] 34 1 2976 1680 nil 27 1698 1760 -109 1760 -29 1776 11 2576 61 410 ##(Smalltalk.PushButton) 34 20 nil 592 34 2 8 1140924416 1 3648 nil nil nil 7 nil nil nil 3648 nil 8 1582648752 1890 #cancel 8 'Cancel' 1 1 nil nil false nil nil nil 1426 138 144 34 2 1490 #createAt:extent: 34 2 498 959 653 498 201 61 3648 1490 #text: 34 1 8 'Cancel' 3648 1618 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 223 1 0 0 70 1 0 0 67 2 0 0 100 1 0 0] 8 #() 1680 nil 29 1698 1760 -209 1760 -9 1792 -69 1792 -9 170 192 34 4 2192 8 'pathText' 704 8 'directoryContentsList' nil 1426 138 144 34 1 1490 #createAt:extent: 34 2 498 1 1 498 1169 723 592 1618 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 105 1 0 0] 34 6 2192 2592 1808 2912 3648 704 1680 nil 27 1698 1744 1 1760 1 1776 1 1792 1 170 192 816 590342 ##(Smalltalk.Rectangle) 498 1 1 498 1 1 nil nil nil nil 8837 nil nil nil nil 1 nil nil 590598 ##(Smalltalk.Semaphore) nil nil 1 false 8 2003643744 1426 138 144 34 1 1490 #createAt:extent: 34 2 498 6683 21 498 1201 801 416 1618 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 13 13 0 0 10 0 0 0 101 15 0 0 154 1 0 0] 34 1 592 1680 nil 27 )!

showOnSession: aGciSession
	^self showOnSession: aGciSession defaultPath: JadePresenter rowanProjectsHomeEnvVarString!

showOnSession: aGciSession defaultPath: path
	| inst service answer |
	service := RowanFileService new path: path. 
	service session: aGciSession.
	inst := self createOn: service.
	inst pathText value: service path.
	inst showDirectoryContents.
	answer := inst showModal.
	^answer ifNil: [nil] ifNotNil: [inst pathText value]! !
!JadeiteServerFileSelectorDialog class categoriesForMethods!
resource_Default_view!public!resources-views! !
showOnSession:!instance creation!public! !
showOnSession:defaultPath:!instance creation!public! !
!

