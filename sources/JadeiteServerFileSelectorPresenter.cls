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
			[| directoryName |
			directoryName := directoryContentsList selection key.
			directoryName = '..' ifTrue: [^self pop].
			directoryName = '.'
				ifFalse: [pathText value: pathText value , '/' , directoryContentsList selection key].
			model value path: pathText value.
			self showDirectoryContents]
		ifFalse: [self select]!

fileName
	^self model fileName!

goto
	model value path: pathText value.
	self showDirectoryContents!

isDirectorySelected
	^(directoryContentsList selectionIfNone: [^true]) value!

isFileSelected
	^(directoryContentsList selectionIfNone: [^false]) value not!

load

	^parentPresenter load!

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

selectedFilePath
	^self pathText value , '/' , directoryContentsList selection key!

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
isDirectorySelected!public!testing! !
isFileSelected!public!testing! !
load!menu handlers!public! !
logoutRequested:!event handlers!private! !
newPathText!actions!public! !
parentDirectoryPath!accessing!public! !
pathText!accessing!private! !
pathText:!accessing!private! !
pop!actions!menu handlers!public! !
select!actions!menu handlers!public! !
selectedFilePath!accessing!public! !
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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil nil 5 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 544 nil nil nil 5 nil nil nil 544 482 170 176 34 12 410 ##(Smalltalk.PushButton) 34 20 nil 544 34 2 8 1140924416 1 656 nil nil nil 5 nil nil nil 656 nil 8 1597459888 1180998 4 ##(Smalltalk.CommandDescription) #cancel 8 'Cancel' 1 1 nil nil false nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 328198 ##(Smalltalk.Point) 491 431 898 201 61 656 850 #text: 34 1 8 'Cancel' 656 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 245 0 0 0 215 0 0 0 89 1 0 0 245 0 0 0] 8 #() 898 193 193 nil 29 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentRight -209 1120 -9 1106 #fixedParentBottom -69 1136 -9 410 ##(Smalltalk.TextEdit) 34 16 nil 544 34 2 8 1149239424 1 1152 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 1152 nil 8 1597451696 852486 ##(Smalltalk.NullConverter) nil nil 1 786 138 144 34 3 850 #createAt:extent: 34 2 898 121 11 898 441 61 1152 850 #text: 34 1 8 'c:\Program Files\Dolphin Smalltalk' 1152 850 #setMarginWidths: 34 1 8 #(3 3) 1152 994 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 60 0 0 0 5 0 0 0 24 1 0 0 35 0 0 0] 8 #() 1056 nil 27 1074 1106 #fixedParentLeft 121 1120 -139 1106 #fixedParentTop 11 1106 #fixedViewTop 61 410 ##(Smalltalk.EditableListView) 34 55 nil 544 34 2 8 1140936781 1025 1648 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 327686 ##(Smalltalk.Color) #default nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 1 984134 2 ##(Smalltalk.CommandMenuItem) 1 738 #dive 8 'Dive' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 1648 nil 8 1597395168 ##(Smalltalk.BasicListAbstract) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 5 1 1984 8 'doIt' 8 '[:assoc | assoc value ifTrue:[Icon fromId: ''Folder.ico''] ifFalse:[0]]' 8 #[32 105 17 142 121 45 30 178 106 62 106] 983558 ##(Smalltalk.VariableBinding) #Icon ##(Smalltalk.Icon) 8 'Folder.ico' #fromId: 2000 #ifTrue:ifFalse: 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil 898 65 65 nil nil 138 144 34 1 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Column 1' 673 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 1986 0 nil 2018 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:assoc | assoc key]' 8 #[30 105 226 0 106] #key 2272 7 257 nil nil 1648 nil 3 nil nil false nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 2368 1218 nil false 1264 nil nil nil 5 nil nil nil 2368 nil nil 1298 nil 8 '' 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 786 138 144 34 3 850 #createAt:extent: 34 2 898 11 101 898 681 321 1648 850 #contextMenu: 34 1 1856 1648 850 #text: 34 1 8 'Column 1' 1648 994 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 50 0 0 0 89 1 0 0 210 0 0 0] 8 #() 1056 nil 33 1074 1600 11 1120 -9 1616 101 1136 -79 410 ##(Smalltalk.ToolButton) 34 14 nil 544 34 2 8 1140850688 131073 2720 nil nil nil 5 nil nil nil 2720 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 2720 34 2 8 1140853580 131137 2784 nil nil nil 1 nil nil nil 2784 nil 8 1597418880 nil 170 192 34 2 14203 1115206 1 ##(Smalltalk.ToolbarIconButton) 2784 1 738 #pop 8 'Pop' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons\FolderUp.ico' nil 14203 34 1 2912 nil nil 3 nil 898 49 49 898 71 51 nil nil 786 138 144 34 1 850 #createAt:extent: 34 2 898 1 1 898 81 61 2784 994 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 40 0 0 0 30 0 0 0] 8 #() 1056 nil 27 786 138 144 34 1 850 #createAt:extent: 34 2 898 591 11 898 81 61 2720 994 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 39 1 0 0 5 0 0 0 79 1 0 0 35 0 0 0] 34 1 2784 1056 nil 27 1074 1120 -109 1120 -29 1616 11 1632 61 410 ##(Smalltalk.PushButton) 34 20 nil 544 34 2 8 1140924416 1 3424 nil nil nil 5 nil nil nil 3424 nil 8 1597459888 738 #select 8 'Select' 1 1 nil nil false nil nil nil 786 138 144 34 3 850 #createAt:extent: 34 2 898 281 431 898 211 61 3424 850 #isEnabled: 8 #(false) 3424 850 #text: 34 1 8 'Select' 3424 994 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 140 0 0 0 215 0 0 0 245 0 0 0 245 0 0 0] 8 #() 1056 nil 29 1074 1120 -419 1120 -209 1136 -69 1136 -9 410 ##(Smalltalk.StaticText) 34 16 nil 544 34 2 8 1140850944 65 3792 nil nil nil 5 nil nil nil 3792 nil 8 1597308096 1298 nil nil nil 786 138 144 34 2 850 #createAt:extent: 34 2 898 11 11 898 101 61 3792 850 #text: 34 1 8 'Path:
' 3792 994 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 5 0 0 0 55 0 0 0 35 0 0 0] 8 #() 1056 nil 27 1074 1600 11 1600 111 1616 11 1632 61 170 192 34 4 1152 8 'pathText' 1648 8 'directoryContentsList' nil 786 138 144 34 1 850 #createAt:extent: 34 2 898 1 1 898 701 501 544 994 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 94 1 0 0 250 0 0 0] 34 6 1152 3792 3424 2720 656 1648 1056 nil 27 1074 1600 1 1120 1 1616 1 1136 1 170 192 1760 nil 786 138 144 34 1 850 #createAt:extent: 34 2 898 7087 21 898 701 501 416 994 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 215 13 0 0 10 0 0 0 53 15 0 0 4 1 0 0] 34 1 544 1056 nil 27 )!

resource_Load_view
	"Answer the literal data from which the 'Load view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Load_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil nil 5 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 544 nil nil nil 5 nil nil nil 544 482 170 176 34 10 410 ##(Smalltalk.PushButton) 34 20 nil 544 34 2 8 1140924416 1 656 nil nil nil 5 nil nil nil 656 nil 8 1597459888 1180998 4 ##(Smalltalk.CommandDescription) #select 8 'Select' 1 1 nil nil false nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 328198 ##(Smalltalk.Point) 11 431 898 201 61 656 850 #isEnabled: 8 #(false) 656 850 #text: 34 1 8 'Select' 656 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 215 0 0 0 105 0 0 0 245 0 0 0] 8 #() 898 193 193 nil 29 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 11 1152 211 1138 #fixedParentBottom -69 1168 -9 410 ##(Smalltalk.EditableListView) 34 55 nil 544 34 2 8 1140936781 1025 1184 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 327686 ##(Smalltalk.Color) #default nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 1 984134 2 ##(Smalltalk.CommandMenuItem) 1 738 #dive 8 'Dive' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 1184 nil 8 1597395168 ##(Smalltalk.BasicListAbstract) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 5 1 1520 8 'doIt' 8 '[:assoc | assoc value ifTrue:[Icon fromId: ''Folder.ico''] ifFalse:[0]]' 8 #[32 105 17 142 121 45 30 178 106 62 106] 983558 ##(Smalltalk.VariableBinding) #Icon ##(Smalltalk.Icon) 8 'Folder.ico' #fromId: 1536 #ifTrue:ifFalse: 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil 898 65 65 nil nil 138 144 34 1 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Column 1' 673 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 1522 0 nil 1554 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:assoc | assoc key]' 8 #[30 105 226 0 106] #key 1808 7 257 nil nil 1184 nil 3 nil nil false nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 1904 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 1904 nil nil 852486 ##(Smalltalk.NullConverter) nil 8 '' 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 786 138 144 34 3 850 #createAt:extent: 34 2 898 11 101 898 681 321 1184 850 #contextMenu: 34 1 1392 1184 850 #text: 34 1 8 'Column 1' 1184 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 50 0 0 0 89 1 0 0 210 0 0 0] 8 #() 1088 nil 33 1106 1152 11 1138 #fixedParentRight -9 1138 #fixedParentTop 101 1168 -79 410 ##(Smalltalk.TextEdit) 34 16 nil 544 34 2 8 1149239424 1 2352 1938 nil false 1984 nil nil nil 5 nil nil nil 2352 nil 8 1597451696 2002 nil nil 1 786 138 144 34 3 850 #createAt:extent: 34 2 898 121 11 898 441 61 2352 850 #text: 34 1 8 'c:\Program Files\Dolphin Smalltalk' 2352 850 #setMarginWidths: 34 1 8 #(3 3) 2352 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 60 0 0 0 5 0 0 0 24 1 0 0 35 0 0 0] 8 #() 1088 nil 27 1106 1152 121 2320 -139 2336 11 1138 #fixedViewTop 61 410 ##(Smalltalk.StaticText) 34 16 nil 544 34 2 8 1140850944 65 2752 nil nil nil 5 nil nil nil 2752 nil 8 1597308096 2002 nil nil nil 786 138 144 34 2 850 #createAt:extent: 34 2 898 11 11 898 101 61 2752 850 #text: 34 1 8 'Path:
' 2752 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 5 0 0 0 55 0 0 0 35 0 0 0] 8 #() 1088 nil 27 1106 1152 11 1152 111 2336 11 2736 61 410 ##(Smalltalk.ToolButton) 34 14 nil 544 34 2 8 1140850688 131073 3072 nil nil nil 5 nil nil nil 3072 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 3072 34 2 8 1140853580 131137 3136 nil nil nil 1 nil nil nil 3136 nil 8 1597418880 nil 170 192 34 2 14625 1115206 1 ##(Smalltalk.ToolbarIconButton) 3136 1 738 #pop 8 'Pop' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons\FolderUp.ico' nil 14625 34 1 3264 nil nil 3 nil 898 49 49 898 71 51 nil nil 786 138 144 34 1 850 #createAt:extent: 34 2 898 1 1 898 81 61 3136 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 40 0 0 0 30 0 0 0] 8 #() 1088 nil 27 786 138 144 34 1 850 #createAt:extent: 34 2 898 591 11 898 81 61 3072 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 39 1 0 0 5 0 0 0 79 1 0 0 35 0 0 0] 34 1 3136 1088 nil 27 1106 2320 -109 2320 -29 2336 11 2736 61 170 192 34 4 1184 8 'directoryContentsList' 2352 8 'pathText' nil 786 138 144 34 1 850 #createAt:extent: 34 2 898 1 1 898 701 501 544 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 94 1 0 0 250 0 0 0] 34 5 2352 2752 656 3072 1184 1088 nil 27 1106 1152 1 2320 1 2336 1 1168 1 170 192 1296 nil 786 138 144 34 1 850 #createAt:extent: 34 2 898 7087 21 898 701 501 416 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 215 13 0 0 10 0 0 0 53 15 0 0 4 1 0 0] 34 1 544 1088 nil 27 )! !
!JadeiteServerFileSelectorPresenter class categoriesForMethods!
resource_Default_view!public!resources-views! !
resource_Load_view!public!resources-views! !
!

