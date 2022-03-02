"Filed out from Dolphin Smallalk"!

Dialog subclass: #JadeiteServerFileSelector
	instanceVariableNames: 'directoryContentsList pathText'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteServerFileSelector guid: (GUID fromString: '{70f59a0e-a3b1-4740-ab3e-4b15f70b06a0}')!
JadeiteServerFileSelector comment: ''!
!JadeiteServerFileSelector categoriesForClass!Unclassified! !
!JadeiteServerFileSelector methodsFor!

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
		to: self.!

dive
	(model value isDirectory: directoryContentsList selection)
		ifTrue: 
			[pathText value: pathText value , '/' , directoryContentsList selection.
			model value path: pathText value.
			self showDirectoryContents]!

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
	folder := directoryContentsList selectionOrNil ifNil: [String new] ifNotNil: [:sel | sel].
	pathText value: pathText value , '/' , folder.
	self ok.
	^pathText value!

showDirectoryContents
	| directoryContents |
	directoryContents := model value directoryContents.
	directoryContentsList list: directoryContents!

updateCaption
	self caption: (model value session titleBarFor: 'Server File Selector')! !
!JadeiteServerFileSelector categoriesForMethods!
cancel!actions!public! !
createComponents!initialization!public! !
createSchematicWiring!initialization!public! !
dive!actions!public! !
logoutRequested:!event handlers!private! !
pathText!accessing!private! !
pathText:!accessing!private! !
pop!actions!public! !
select!actions!public! !
showDirectoryContents!actions!public! !
updateCaption!public! !
!

!JadeiteServerFileSelector class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.DialogView) 34 30 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1201 801 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 592 nil nil nil 7 nil nil nil 592 530 170 176 34 12 410 ##(Smalltalk.TextEdit) 34 16 nil 592 34 2 8 1149239424 1 704 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 7 nil nil nil 704 nil 8 1591815600 852486 ##(Smalltalk.NullConverter) nil nil 1 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 121 11 498 909 61 704 946 #text: 34 1 8 'c:\Program Files\Dolphin Smalltalk' 704 946 #setMarginWidths: 34 1 8 #(3 3) 704 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 60 0 0 0 5 0 0 0 2 2 0 0 35 0 0 0] 8 #() 498 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 121 1234 #fixedParentRight -139 1234 #fixedParentTop 11 1234 #fixedViewTop 61 410 ##(Smalltalk.StaticText) 34 16 nil 592 34 2 8 1140850944 65 1312 nil nil nil 7 nil nil nil 1312 nil 8 1591672000 850 nil nil nil 882 138 144 34 2 946 #createAt:extent: 34 2 498 11 11 498 101 61 1312 946 #text: 34 1 8 'Path:
' 1312 1122 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 5 0 0 0 55 0 0 0 35 0 0 0] 8 #() 1184 nil 27 1202 1248 11 1248 111 1280 11 1296 61 410 ##(Smalltalk.PushButton) 34 20 nil 592 34 2 8 1140924416 1 1632 nil nil nil 7 nil nil nil 1632 nil 8 1591823792 1180998 4 ##(Smalltalk.CommandDescription) #select 8 'Select' 1 1 nil nil false nil nil nil 882 138 144 34 3 946 #createAt:extent: 34 2 498 749 653 498 211 61 1632 946 #isEnabled: 8 #(false) 1632 946 #text: 34 1 8 'Select' 1632 1122 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 118 1 0 0 70 1 0 0 223 1 0 0 100 1 0 0] 8 #() 1184 nil 29 1202 1264 -419 1264 -209 1234 #fixedParentBottom -69 2016 -9 410 ##(Smalltalk.ListView) 34 45 nil 592 34 2 8 1140937039 1025 2032 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 nil nil nil 2032 nil 8 1591759072 459270 ##(Smalltalk.Message) #displayString 8 #() 787814 3 ##(Smalltalk.BlockClosure) 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 541855619 8 #[30 105 226 0 106] #iconImageIndex 2272 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 1 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Column 1' 1001 #left 2210 #displayString 8 #() 2210 #<= 2144 2258 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 2256 8 'doIt' 8 '[:assoc | assoc key]' 8 #[30 105 226 0 106] #key 2496 7 257 nil nil 2032 nil 3 nil 2258 0 nil 2514 4 1 2256 8 'doIt' 8 '[:displayThing | displayThing item key halt]' 8 #[32 105 226 0 159 160 106] #item #key #halt 2592 7 257 nil false nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 2688 770 nil false 816 nil 480 nil 5 nil nil nil 2688 nil nil 850 nil 8 '' 1 nil nil nil nil nil nil nil nil nil #list 2144 nil 2145 nil 1 nil nil 201 nil nil nil nil nil nil nil nil nil nil nil nil 882 138 144 34 2 946 #createAt:extent: 34 2 498 11 101 498 1149 543 2032 946 #text: 34 1 8 'Column 1' 2032 1122 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 50 0 0 0 67 2 0 0 65 1 0 0] 8 #() 1184 nil 35 1202 1248 11 1264 -9 1280 101 2016 -79 410 ##(Smalltalk.ToolButton) 34 14 nil 592 34 2 8 1140850688 131073 2992 nil nil nil 7 nil nil nil 2992 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 2992 34 2 8 1140853580 131137 3056 nil nil nil 3 nil nil nil 3056 nil 8 1591782784 nil 170 192 34 2 16717 1115206 1 ##(Smalltalk.ToolbarIconButton) 3056 1 1714 #pop 8 'Pop' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'C:\Users\ewinger\source\repos\Dolphin7121\Dolphin\Core\DolphinVM\Res\FolderUp.ico' nil 16717 34 1 3184 nil nil 3 nil 498 49 49 498 71 51 nil nil 882 138 144 34 1 946 #createAt:extent: 34 2 498 1 1 498 81 61 3056 1122 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 40 0 0 0 30 0 0 0] 8 #() 1184 nil 27 882 138 144 34 2 946 #createAt:extent: 34 2 498 1059 11 498 81 61 2992 946 #isEnabled: 8 #(false) 2992 1122 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 17 2 0 0 5 0 0 0 57 2 0 0 35 0 0 0] 34 1 3056 1184 nil 27 1202 1264 -109 1264 -29 1280 11 1296 61 410 ##(Smalltalk.PushButton) 34 20 nil 592 34 2 8 1140924416 1 3728 nil nil nil 7 nil nil nil 3728 nil 8 1591823792 1714 #cancel 8 'Cancel' 1 1 nil nil false nil nil nil 882 138 144 34 2 946 #createAt:extent: 34 2 498 959 653 498 201 61 3728 946 #text: 34 1 8 'Cancel' 3728 1122 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 223 1 0 0 70 1 0 0 67 2 0 0 100 1 0 0] 8 #() 1184 nil 29 1202 1264 -209 1264 -9 2016 -69 2016 -9 170 192 34 4 2032 8 'directoryContentsList' 704 8 'pathText' nil 882 138 144 34 1 946 #createAt:extent: 34 2 498 1 1 498 1169 723 592 1122 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 105 1 0 0] 34 6 704 1312 2032 1632 2992 3728 1184 nil 27 1202 1248 1 1264 1 1280 1 2016 1 170 192 2144 590342 ##(Smalltalk.Rectangle) 498 1 1 498 1 1 nil nil nil nil 3 nil nil nil nil 1 nil nil 590598 ##(Smalltalk.Semaphore) nil nil 1 false 8 2007379296 882 138 144 34 1 946 #createAt:extent: 34 2 498 6513 21 498 1201 801 416 1122 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 184 12 0 0 10 0 0 0 16 15 0 0 154 1 0 0] 34 1 592 1184 nil 27 )!

showOnSession: aGciSession
	| inst service answer |
	service := RowanFileService new path: '$ROWAN_PROJECTS_HOME'.
	service session: aGciSession.
	inst := self createOn: service.
	inst pathText value: service path.
	inst showDirectoryContents.
	answer := inst showModal.
	^answer ifNil: [nil] ifNotNil: [inst pathText value]! !
!JadeiteServerFileSelector class categoriesForMethods!
resource_Default_view!public!resources-views! !
showOnSession:!instance creation!public! !
!

