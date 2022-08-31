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
	parentPresenter select!

selectionMade
	| item finalSlash |
	model value path = pathText value ifFalse: [^self goto].
	item := directoryContentsList selectionOrNil ifNil: [String new] ifNotNil: [:sel | sel key].
	finalSlash := pathText value isEmpty
				ifFalse: [pathText value last = $/ ifTrue: [String new] ifFalse: ['/']].
	pathText value: pathText value , finalSlash , item!

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
goto!actions!public! !
logoutRequested:!event handlers!private! !
pathText!accessing!private! !
pathText:!accessing!private! !
pop!actions!public! !
select!actions!public! !
selectionMade!actions!public! !
showDirectoryContents!actions!public! !
!

!JadeiteServerFileSelectorPresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil nil 5 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 544 nil nil nil 5 nil nil nil 544 482 170 176 34 12 410 ##(Smalltalk.EditableListView) 34 55 nil 544 34 2 8 1140936781 1025 656 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 327686 ##(Smalltalk.Color) #default nil 5 nil nil nil 656 nil 8 1594380512 ##(Smalltalk.BasicListAbstract) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 5 1 864 8 'doIt' 8 '[:assoc | assoc value ifTrue:[Icon fromId: ''Folder.ico''] ifFalse:[0]]' 8 #[32 105 17 142 121 45 30 178 106 62 106] 983558 ##(Smalltalk.VariableBinding) #Icon ##(Smalltalk.Icon) 8 'Folder.ico' #fromId: 880 #ifTrue:ifFalse: 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil 328198 ##(Smalltalk.Point) 65 65 nil nil 138 144 34 1 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Column 1' 673 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 866 0 nil 898 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:assoc | assoc key]' 8 #[30 105 226 0 106] #key 1168 7 257 nil nil 656 nil 3 nil nil false nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 1264 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 1264 nil nil 852486 ##(Smalltalk.NullConverter) nil 8 '' 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 1058 11 101 1058 681 321 656 1490 #text: 34 1 8 'Column 1' 656 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 50 0 0 0 89 1 0 0 210 0 0 0] 8 #() 1058 193 193 nil 33 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 11 1730 #fixedParentRight -9 1730 #fixedParentTop 101 1730 #fixedParentBottom -79 410 ##(Smalltalk.StaticText) 34 16 nil 544 34 2 8 1140850944 65 1808 nil nil nil 5 nil nil nil 1808 nil 8 1594293440 1362 nil nil nil 1426 138 144 34 2 1490 #createAt:extent: 34 2 1058 11 11 1058 101 61 1808 1490 #text: 34 1 8 'Path:
' 1808 1618 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 5 0 0 0 55 0 0 0 35 0 0 0] 8 #() 1680 nil 27 1698 1744 11 1744 111 1776 11 1730 #fixedViewTop 61 410 ##(Smalltalk.PushButton) 34 20 nil 544 34 2 8 1140924416 1 2144 nil nil nil 5 nil nil nil 2144 nil 8 1594445232 1180998 4 ##(Smalltalk.CommandDescription) #cancel 8 'Cancel' 1 1 nil nil false nil nil nil 1426 138 144 34 2 1490 #createAt:extent: 34 2 1058 491 431 1058 201 61 2144 1490 #text: 34 1 8 'Cancel' 2144 1618 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 245 0 0 0 215 0 0 0 89 1 0 0 245 0 0 0] 8 #() 1680 nil 29 1698 1760 -209 1760 -9 1792 -69 1792 -9 410 ##(Smalltalk.PushButton) 34 20 nil 544 34 2 8 1140924416 1 2496 nil nil nil 5 nil nil nil 2496 nil 8 1594445232 2226 #select 8 'Select' 1 1 nil nil false nil nil nil 1426 138 144 34 3 1490 #createAt:extent: 34 2 1058 281 431 1058 211 61 2496 1490 #isEnabled: 8 #(false) 2496 1490 #text: 34 1 8 'Select' 2496 1618 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 140 0 0 0 215 0 0 0 245 0 0 0 245 0 0 0] 8 #() 1680 nil 29 1698 1760 -419 1760 -209 1792 -69 1792 -9 410 ##(Smalltalk.ToolButton) 34 14 nil 544 34 2 8 1140850688 131073 2864 nil nil nil 5 nil nil nil 2864 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 2864 34 2 8 1140853580 131137 2928 nil nil nil 1 nil nil nil 2928 nil 8 1594404224 nil 170 192 34 2 27617 1115206 1 ##(Smalltalk.ToolbarIconButton) 2928 1 2226 #pop 8 'Pop' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons\FolderUp.ico' nil 27617 34 1 3056 nil nil 3 nil 1058 49 49 1058 71 51 nil nil 1426 138 144 34 1 1490 #createAt:extent: 34 2 1058 1 1 1058 81 61 2928 1618 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 40 0 0 0 30 0 0 0] 8 #() 1680 nil 27 1426 138 144 34 1 1490 #createAt:extent: 34 2 1058 591 11 1058 81 61 2864 1618 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 39 1 0 0 5 0 0 0 79 1 0 0 35 0 0 0] 34 1 2928 1680 nil 27 1698 1760 -109 1760 -29 1776 11 2128 61 410 ##(Smalltalk.TextEdit) 34 16 nil 544 34 2 8 1149239424 1 3568 1298 nil false 1344 nil nil nil 5 nil nil nil 3568 nil 8 1594437040 1362 nil nil 1 1426 138 144 34 3 1490 #createAt:extent: 34 2 1058 121 11 1058 441 61 3568 1490 #text: 34 1 8 'c:\Program Files\Dolphin Smalltalk' 3568 1490 #setMarginWidths: 34 1 8 #(3 3) 3568 1618 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 60 0 0 0 5 0 0 0 24 1 0 0 35 0 0 0] 8 #() 1680 nil 27 1698 1744 121 1760 -139 1776 11 2128 61 170 192 34 4 656 8 'directoryContentsList' 3568 8 'pathText' nil 1426 138 144 34 1 1490 #createAt:extent: 34 2 1058 1 1 1058 701 501 544 1618 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 94 1 0 0 250 0 0 0] 34 6 3568 1808 2496 2864 2144 656 1680 nil 27 1698 1744 1 1760 1 1776 1 1792 1 170 192 768 nil 1426 138 144 34 1 1490 #createAt:extent: 34 2 1058 6947 21 1058 701 501 416 1618 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 145 13 0 0 10 0 0 0 239 14 0 0 4 1 0 0] 34 1 544 1680 nil 27 )! !
!JadeiteServerFileSelectorPresenter class categoriesForMethods!
resource_Default_view!public!resources-views! !
!

