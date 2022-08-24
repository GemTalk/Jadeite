"Filed out from Dolphin Smallalk"!

JadeiteServerFileSelectorDialog subclass: #JadeiteLoadProjectDialog
	instanceVariableNames: 'projectHomeSelector customAttributesList componentList session attributes components'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteLoadProjectDialog guid: (GUID fromString: '{56d5144b-600b-471e-a37c-749135f80915}')!
JadeiteLoadProjectDialog comment: ''!
!JadeiteLoadProjectDialog categoriesForClass!Unclassified! !
!JadeiteLoadProjectDialog methodsFor!

answer
	"Answer the model if the receiver was confirmed (with #apply, #ok) or nil otherwise"

	^self isConfirmed
		ifTrue: 
			[Array
				with: fileSelectorPresenter pathText value
				with: projectHomeSelector pathText value
				with: components
				with: attributes]
		ifFalse: [nil]!

apply
	self flushChanges.
	confirmed := true!

createComponents
	super createComponents.
	projectHomeSelector := self add: JadeiteServerFileSelectorPresenter new name: 'projectHomeSelector'.
	customAttributesList := self add: ListPresenter new name: 'conditionalAttributesList'.
	componentList := self add: ListPresenter new name: 'componentList'!

createSchematicWiring
	super createSchematicWiring.
	fileSelectorPresenter directoryContentsList
		when: #selectionChanged
		send: #updateProperties
		to: self!

ok
	components := componentList selections.
	attributes := customAttributesList selections.
	^super ok!

select
	| components attributes |
	fileSelectorPresenter selectionMade.
	projectHomeSelector selectionMade.
	self ok.
	!

session
	^session!

session: anObject
	session := anObject!

setPathTexts: path
	"both presenters default to the same path" 
	fileSelectorPresenter pathText value: path.
	projectHomeSelector pathText value: path !

setPresenterModels: aGciSession path: path
	| projectSpecService projectHomeService |
	projectSpecService := RowanFileService new path: path.
	projectSpecService session: aGciSession.
	fileSelectorPresenter model:  projectSpecService asValue.
	projectHomeService := RowanFileService new path: path.
	projectHomeService session: aGciSession.
	projectHomeSelector model: projectHomeService asValue!

shellName

	^'Jadeite Load Project Dialog'.!

showDirectoryContents
	fileSelectorPresenter showDirectoryContents.
	projectHomeSelector showDirectoryContents!

updateProperties
	| loadSpecService |
	fileSelectorPresenter directoryContentsList selectionOrNil ifNil: [^self].
	loadSpecService := RowanLoadSpecService new loadSpecPath: fileSelectorPresenter pathText value , '/'
						, fileSelectorPresenter directoryContentsList selection key.
	[BrowserUpdate current updateService: loadSpecService session: session] on: Error
		do: 
			[:ex |
			customAttributesList list: OrderedCollection new.
			componentList list: OrderedCollection new.
			^self	"not a valid load spec"].
	customAttributesList list: loadSpecService conditionalAttributes.
	customAttributesList view selectAll.
	componentList list: loadSpecService componentNames asOrderedCollection.
	componentList view selectAll! !
!JadeiteLoadProjectDialog categoriesForMethods!
answer!accessing!public! !
apply!actions!public! !
createComponents!initialization!public! !
createSchematicWiring!initialization!public! !
ok!accessing!public! !
select!actions!public! !
session!accessing!private! !
session:!accessing!private! !
setPathTexts:!public! !
setPresenterModels:path:!public! !
shellName!public! !
showDirectoryContents!public! !
updateProperties!event handlers!public! !
!

!JadeiteLoadProjectDialog class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.DialogView) 34 30 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1201 801 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 592 nil nil nil 7 nil nil nil 592 530 170 176 34 4 410 ##(Smalltalk.ListBox) 34 17 nil 592 34 2 8 1412499713 1025 704 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 nil nil nil 704 nil 8 1594244096 459270 ##(Smalltalk.Message) #displayString 8 #() 816 nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 1 61 498 391 303 704 994 #caretIndex: 8 #(1) 704 994 #horizontalExtent: 8 #(0) 704 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 30 0 0 0 195 0 0 0 181 0 0 0] 8 #() 498 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 1250 #fixedParentRight 1 1250 #fixedParentTop 61 1250 #fixedParentBottom 1 410 ##(Smalltalk.StaticText) 34 16 nil 592 34 2 8 1140850944 65 1328 nil nil nil 7 nil nil nil 1328 nil 8 1594293440 852486 ##(Smalltalk.NullConverter) nil nil nil 930 138 144 34 2 994 #createAt:extent: 34 2 498 1 1 498 391 51 1328 994 #text: 34 1 8 'Custom Attributes

' 1328 1138 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 195 0 0 0 25 0 0 0] 8 #() 1200 nil 27 1218 1264 1 1280 1 1250 #relativeParentHeight 1 1250 #fixedViewTop 51 170 192 34 2 704 8 'conditionalAttributesList' nil 930 138 144 34 1 994 #createAt:extent: 34 2 498 779 361 498 391 363 592 1138 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 133 1 0 0 180 0 0 0 72 2 0 0 105 1 0 0] 34 2 1328 704 1200 nil 27 1218 1250 #relativeParentWidth 524806 ##(Smalltalk.Fraction) 5 7 1280 1 1664 1938 3 5 1312 1 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 1984 nil 480 nil 7 nil nil nil 1984 656710 1 ##(Smalltalk.CardLayout) 138 144 34 2 721414 ##(Smalltalk.Association) 8 'Projects Home' 410 ##(Smalltalk.ReferenceView) 34 14 nil 1984 34 2 8 1140850688 131073 2160 nil nil nil 5 nil nil nil 2160 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteServerFileSelectorPresenter) #resource_Default_view nil 930 138 144 34 1 994 #createAt:extent: 34 2 498 9 53 498 763 663 2160 1138 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 129 1 0 0 101 1 0 0] 816 1200 nil 27 2114 8 'Project Spec File' 410 ##(Smalltalk.ReferenceView) 34 14 nil 1984 34 2 8 1140850688 131073 2432 nil nil nil 7 nil nil nil 2432 2226 ##(Smalltalk.JadeiteServerFileSelectorPresenter) #resource_Default_view nil 930 138 144 34 1 994 #createAt:extent: 34 2 498 9 53 498 763 663 2432 1138 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 129 1 0 0 101 1 0 0] 816 1200 nil 27 2432 nil nil nil 170 192 34 4 2160 8 'projectHomeSelector' 2432 8 'fileSelectorPresenter' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 1984 34 2 8 1140916736 1 2720 770 138 144 34 2 2416 2144 nil 848 nil nil 1 nil nil nil 2720 nil 8 1594150656 787814 3 ##(Smalltalk.BlockClosure) 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 2864 7 257 nil 2850 0 nil 2882 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 2928 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #noIcons nil nil nil nil nil 930 138 144 34 3 994 #createAt:extent: 34 2 498 1 1 498 779 723 2720 994 #setSingleSelection: 8 #(1) 2720 994 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 2720 1138 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 133 1 0 0 105 1 0 0] 8 #() 1200 nil 27 930 138 144 34 1 994 #createAt:extent: 34 2 498 1 1 498 779 723 1984 1138 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 133 1 0 0 105 1 0 0] 34 3 2432 2160 2720 1200 nil 27 1218 1264 1 1920 1938 5 7 1296 1 1312 1 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 3424 nil nil nil 7 nil nil nil 3424 530 170 176 34 4 410 ##(Smalltalk.ListBox) 34 17 nil 3424 34 2 8 1412497665 1025 3536 770 138 144 816 nil 848 480 nil 7 nil nil nil 3536 nil 8 1594244096 882 #displayString 912 8 #() false 930 138 144 34 2 994 #createAt:extent: 34 2 498 1 61 498 391 301 3536 994 #horizontalExtent: 8 #(0) 3536 1138 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 30 0 0 0 195 0 0 0 180 0 0 0] 8 #() 1200 nil 27 1218 1264 1 1280 1 1296 61 1312 1 410 ##(Smalltalk.StaticText) 34 16 nil 3424 34 2 8 1140850944 65 3888 nil nil nil 7 nil nil nil 3888 nil 8 1594293440 1410 nil nil nil 930 138 144 34 2 994 #createAt:extent: 34 2 498 1 11 498 391 51 3888 994 #text: 34 1 8 'Components
' 3888 1138 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 5 0 0 0 195 0 0 0 30 0 0 0] 8 #() 1200 nil 27 1218 1264 1 1280 1 1296 11 1296 61 170 192 34 2 3536 8 'componentList' nil 930 138 144 34 1 994 #createAt:extent: 34 2 498 779 1 498 391 361 3424 1138 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 133 1 0 0 0 0 0 0 72 2 0 0 180 0 0 0] 34 2 3536 3888 1200 nil 27 1218 1920 1938 779 1169 1280 1 1296 1 1664 1938 3 5 170 192 816 590342 ##(Smalltalk.Rectangle) 498 1 1 498 1 1 nil nil nil nil 3 nil nil nil nil 1 nil nil 590598 ##(Smalltalk.Semaphore) nil nil 1 false 8 2006068576 930 138 144 34 1 994 #createAt:extent: 34 2 498 6947 21 498 1201 801 416 1138 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 145 13 0 0 10 0 0 0 233 15 0 0 154 1 0 0] 34 3 1984 3424 592 1200 nil 27 )!

showOnSession: aGciSession defaultPath: path
	| inst projectSpecService answer |
	projectSpecService := RowanFileService new path: path.
	projectSpecService session: aGciSession.
	inst := self create.
	inst session: aGciSession. 
	inst setPresenterModels: aGciSession path: path.
	inst setPathTexts: projectSpecService path.
	inst showDirectoryContents.
	inst updateCaptionInSession: aGciSession.
	answer := inst showModal. 
	^answer! !
!JadeiteLoadProjectDialog class categoriesForMethods!
resource_Default_view!public!resources-views! !
showOnSession:defaultPath:!instance creation!public! !
!

