"Filed out from Dolphin Smallalk"!

JadePresenterA subclass: #JadeiteServerFileSelectorPresenter
	instanceVariableNames: 'directoryContentsList pathText'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteServerFileSelectorPresenter guid: (GUID fromString: '{1ca2fcfa-af65-44b7-87b6-3b5c5781ac1a}')!
JadeiteServerFileSelectorPresenter comment: ''!
!JadeiteServerFileSelectorPresenter categoriesForClass!Unclassified! !
!JadeiteServerFileSelectorPresenter methodsFor!

cancel
	parentPresenter cancel. 
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

directoryContentsList
	^directoryContentsList!

dive
	(model value isDirectory: directoryContentsList selection key)
		ifTrue: 
			[pathText value: pathText value , '/' , directoryContentsList selection key.
			model value path: pathText value.
			self showDirectoryContents]
		ifFalse: [self select]!

fileName
	^self model fileName!

goto
	model value path: pathText value.
	self showDirectoryContents!

logoutRequested: aValueHolder
	"Private - Opportunity to save changes."

	aValueHolder value: true.!

newPathText
	| item newPathText finalSlash |
	item := directoryContentsList selectionOrNil ifNil: [String new] ifNotNil: [:sel | sel key].
	finalSlash := pathText value isEmpty
				ifFalse: [pathText value last = $/ ifTrue: [String new] ifFalse: ['/']].
	newPathText := pathText value , finalSlash , item.
	^newPathText!

parentDirectoryPath
	^self model parentDirectoryPath!

pathText
	^pathText!

pathText: anObject
	pathText := anObject!

pop
	model value path: pathText value. 
	directoryContentsList list: model value pop.
	pathText value: model value path!

select
	parentPresenter select!

selectionMade
	| newPathText |
	model value path = pathText value ifFalse: [^self goto].
	newPathText := self newPathText.
	pathText value: newPathText!

setPath: path
	pathText value: path.
	model value path: path. !

showDirectoryContents
	| directoryContents |
	directoryContents := model value directoryContents.
	directoryContentsList list: directoryContents! !
!JadeiteServerFileSelectorPresenter categoriesForMethods!
cancel!actions!public! !
createComponents!initialization!public! !
createSchematicWiring!initialization!public! !
directoryContentsList!accessing!private! !
dive!actions!public! !
fileName!accessing!public! !
goto!actions!public! !
logoutRequested:!event handlers!private! !
newPathText!actions!public! !
parentDirectoryPath!accessing!public! !
pathText!accessing!private! !
pathText:!accessing!private! !
pop!actions!public! !
select!actions!public! !
selectionMade!actions!public! !
setPath:!actions!public! !
showDirectoryContents!actions!public! !
!

!JadeiteServerFileSelectorPresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil nil 5 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 544 nil nil nil 5 nil nil nil 544 482 170 176 34 12 410 ##(Smalltalk.TextEdit) 34 16 nil 544 34 2 8 1149239424 1 656 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 656 nil 8 1607675312 852486 ##(Smalltalk.NullConverter) nil nil 1 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 328198 ##(Smalltalk.Point) 121 11 946 441 61 656 898 #text: 34 1 8 'c:\Program Files\Dolphin Smalltalk' 656 898 #setMarginWidths: 34 1 8 #(3 3) 656 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 60 0 0 0 5 0 0 0 24 1 0 0 35 0 0 0] 8 #() 946 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 121 1202 #fixedParentRight -139 1202 #fixedParentTop 11 1202 #fixedViewTop 61 410 ##(Smalltalk.PushButton) 34 20 nil 544 34 2 8 1140924416 1 1280 nil nil nil 5 nil nil nil 1280 nil 8 1607683504 1180998 4 ##(Smalltalk.CommandDescription) #cancel 8 'Cancel' 1 1 nil nil false nil nil nil 834 138 144 34 2 898 #createAt:extent: 34 2 946 491 431 946 201 61 1280 898 #text: 34 1 8 'Cancel' 1280 1090 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 245 0 0 0 215 0 0 0 89 1 0 0 245 0 0 0] 8 #() 1152 nil 29 1170 1232 -209 1232 -9 1202 #fixedParentBottom -69 1632 -9 410 ##(Smalltalk.ToolButton) 34 14 nil 544 34 2 8 1140850688 131073 1648 nil nil nil 5 nil nil nil 1648 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 1648 34 2 8 1140853580 131137 1712 nil nil nil 1 nil nil nil 1712 nil 8 1607642496 nil 170 192 34 2 23573 1115206 1 ##(Smalltalk.ToolbarIconButton) 1712 1 1362 #pop 8 'Pop' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons\FolderUp.ico' nil 23573 34 1 1840 nil nil 3 nil 946 49 49 946 71 51 nil nil 834 138 144 34 1 898 #createAt:extent: 34 2 946 1 1 946 81 61 1712 1090 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 40 0 0 0 30 0 0 0] 8 #() 1152 nil 27 834 138 144 34 1 898 #createAt:extent: 34 2 946 591 11 946 81 61 1648 1090 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 39 1 0 0 5 0 0 0 79 1 0 0 35 0 0 0] 34 1 1712 1152 nil 27 1170 1232 -109 1232 -29 1248 11 1264 61 410 ##(Smalltalk.StaticText) 34 16 nil 544 34 2 8 1140850944 65 2352 nil nil nil 5 nil nil nil 2352 nil 8 1607531712 802 nil nil nil 834 138 144 34 2 898 #createAt:extent: 34 2 946 11 11 946 101 61 2352 898 #text: 34 1 8 'Path:
' 2352 1090 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 5 0 0 0 55 0 0 0 35 0 0 0] 8 #() 1152 nil 27 1170 1216 11 1216 111 1248 11 1264 61 410 ##(Smalltalk.EditableListView) 34 55 nil 544 34 2 8 1140936781 1025 2672 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 327686 ##(Smalltalk.Color) #default nil 5 nil nil nil 2672 nil 8 1607618784 ##(Smalltalk.BasicListAbstract) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 5 1 2880 8 'doIt' 8 '[:assoc | assoc value ifTrue:[Icon fromId: ''Folder.ico''] ifFalse:[0]]' 8 #[32 105 17 142 121 45 30 178 106 62 106] 983558 ##(Smalltalk.VariableBinding) #Icon 1888 8 'Folder.ico' #fromId: 2896 #ifTrue:ifFalse: 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil 946 65 65 nil nil 138 144 34 1 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Column 1' 673 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 2882 0 nil 2914 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:assoc | assoc key]' 8 #[30 105 226 0 106] #key 3168 7 257 nil nil 2672 nil 3 nil nil false nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 3264 722 nil false 768 nil nil nil 5 nil nil nil 3264 nil nil 802 nil 8 '' 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 834 138 144 34 2 898 #createAt:extent: 34 2 946 11 101 946 681 321 2672 898 #text: 34 1 8 'Column 1' 2672 1090 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 50 0 0 0 89 1 0 0 210 0 0 0] 8 #() 1152 nil 33 1170 1216 11 1232 -9 1248 101 1632 -79 410 ##(Smalltalk.PushButton) 34 20 nil 544 34 2 8 1140924416 1 3584 nil nil nil 5 nil nil nil 3584 nil 8 1607683504 1362 #select 8 'Select' 1 1 nil nil false nil nil nil 834 138 144 34 3 898 #createAt:extent: 34 2 946 281 431 946 211 61 3584 898 #isEnabled: 8 #(false) 3584 898 #text: 34 1 8 'Select' 3584 1090 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 140 0 0 0 215 0 0 0 245 0 0 0 245 0 0 0] 8 #() 1152 nil 29 1170 1232 -419 1232 -209 1632 -69 1632 -9 170 192 34 4 2672 8 'directoryContentsList' 656 8 'pathText' nil 834 138 144 34 1 898 #createAt:extent: 34 2 946 1 1 946 701 501 544 1090 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 94 1 0 0 250 0 0 0] 34 6 656 2352 3584 1648 1280 2672 1152 nil 27 1170 1216 1 1232 1 1248 1 1632 1 170 192 2784 nil 834 138 144 34 1 898 #createAt:extent: 34 2 946 6987 21 946 701 501 416 1090 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 165 13 0 0 10 0 0 0 3 15 0 0 4 1 0 0] 34 1 544 1152 nil 27 )!

resource_Load_view
	"Answer the literal data from which the 'Load view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Load_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil nil 5 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 544 nil nil nil 5 nil nil nil 544 482 170 176 34 10 410 ##(Smalltalk.ToolButton) 34 14 nil 544 34 2 8 1140850688 131073 656 nil nil nil 5 nil nil nil 656 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 656 34 2 8 1140853580 131137 720 nil nil nil 1 nil nil nil 720 nil 8 1597418880 nil 170 192 34 2 56161 1115206 1 ##(Smalltalk.ToolbarIconButton) 720 1 1180998 4 ##(Smalltalk.CommandDescription) #pop 8 'Pop' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons\FolderUp.ico' nil 56161 34 1 848 nil nil 3 nil 328198 ##(Smalltalk.Point) 49 49 1010 71 51 nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 1010 1 1 1010 81 61 720 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 40 0 0 0 30 0 0 0] 8 #() 1010 193 193 nil 27 1058 138 144 34 1 1122 #createAt:extent: 34 2 1010 591 11 1010 81 61 656 1202 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 39 1 0 0 5 0 0 0 79 1 0 0 35 0 0 0] 34 1 720 1264 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentRight -109 1488 -29 1474 #fixedParentTop 11 1474 #fixedViewTop 61 410 ##(Smalltalk.TextEdit) 34 16 nil 544 34 2 8 1149239424 1 1536 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 1536 nil 8 1597451696 852486 ##(Smalltalk.NullConverter) nil nil 1 1058 138 144 34 3 1122 #createAt:extent: 34 2 1010 121 11 1010 441 61 1536 1122 #text: 34 1 8 'c:\Program Files\Dolphin Smalltalk' 1536 1122 #setMarginWidths: 34 1 8 #(3 3) 1536 1202 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 60 0 0 0 5 0 0 0 24 1 0 0 35 0 0 0] 8 #() 1264 nil 27 1442 1474 #fixedParentLeft 121 1488 -139 1504 11 1520 61 410 ##(Smalltalk.StaticText) 34 16 nil 544 34 2 8 1140850944 65 2000 nil nil nil 5 nil nil nil 2000 nil 8 1597308096 1682 nil nil nil 1058 138 144 34 2 1122 #createAt:extent: 34 2 1010 11 11 1010 101 61 2000 1122 #text: 34 1 8 'Path:
' 2000 1202 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 5 0 0 0 55 0 0 0 35 0 0 0] 8 #() 1264 nil 27 1442 1984 11 1984 111 1504 11 1520 61 410 ##(Smalltalk.EditableListView) 34 55 nil 544 34 2 8 1140936781 1025 2320 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 327686 ##(Smalltalk.Color) #default nil 5 nil nil nil 2320 nil 8 1597395168 ##(Smalltalk.BasicListAbstract) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 5 1 2528 8 'doIt' 8 '[:assoc | assoc value ifTrue:[Icon fromId: ''Folder.ico''] ifFalse:[0]]' 8 #[32 105 17 142 121 45 30 178 106 62 106] 983558 ##(Smalltalk.VariableBinding) #Icon 912 8 'Folder.ico' #fromId: 2544 #ifTrue:ifFalse: 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil 1010 65 65 nil nil 138 144 34 1 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Column 1' 673 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 2530 0 nil 2562 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:assoc | assoc key]' 8 #[30 105 226 0 106] #key 2816 7 257 nil nil 2320 nil 3 nil nil false nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 2912 1602 nil false 1648 nil nil nil 5 nil nil nil 2912 nil nil 1682 nil 8 '' 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 1058 138 144 34 2 1122 #createAt:extent: 34 2 1010 11 101 1010 681 321 2320 1122 #text: 34 1 8 'Column 1' 2320 1202 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 50 0 0 0 89 1 0 0 210 0 0 0] 8 #() 1264 nil 33 1442 1984 11 1488 -9 1504 101 1474 #fixedParentBottom -79 410 ##(Smalltalk.PushButton) 34 20 nil 544 34 2 8 1140924416 1 3248 nil nil nil 5 nil nil nil 3248 nil 8 1597459888 866 #select 8 'Select' 1 1 nil nil false nil nil nil 1058 138 144 34 3 1122 #createAt:extent: 34 2 1010 11 431 1010 201 61 3248 1122 #isEnabled: 8 #(false) 3248 1122 #text: 34 1 8 'Select' 3248 1202 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 215 0 0 0 105 0 0 0 245 0 0 0] 8 #() 1264 nil 29 1442 1984 11 1984 211 3232 -69 3232 -9 170 192 34 4 2320 8 'directoryContentsList' 1536 8 'pathText' nil 1058 138 144 34 1 1122 #createAt:extent: 34 2 1010 1 1 1010 701 501 544 1202 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 94 1 0 0 250 0 0 0] 34 5 1536 2000 3248 656 2320 1264 nil 27 1442 1984 1 1488 1 1504 1 3232 1 170 192 2432 nil 1058 138 144 34 1 1122 #createAt:extent: 34 2 1010 7087 21 1010 701 501 416 1202 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 215 13 0 0 10 0 0 0 53 15 0 0 4 1 0 0] 34 1 544 1264 nil 27 )! !
!JadeiteServerFileSelectorPresenter class categoriesForMethods!
resource_Default_view!public!resources-views! !
resource_Load_view!public!resources-views! !
!

