"Filed out from Dolphin Smallalk"!

JadeiteServerFileSelectorDialog subclass: #JadeiteLoadProjectDialog
	instanceVariableNames: 'projectHomeSelector customAttributesList componentList session attributes components resolveStrictCheckbox'
	classVariableNames: 'PreviousFilePath PreviousProjectHomePath'
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
				with: attributes
				with: resolveStrictCheckbox value]
		ifFalse: [nil]!

apply
	self flushChanges.
	confirmed := true!

createComponents
	super createComponents.
	projectHomeSelector := self add: JadeiteServerFileSelectorPresenter new name: 'projectHomeSelector'.
	customAttributesList := self add: ListPresenter new name: 'conditionalAttributesList'.
	componentList := self add: ListPresenter new name: 'componentList'.
	resolveStrictCheckbox := self add: BooleanPresenter new name: 'resolveStrictCheckbox'.!

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

resolveStrictCheckbox
	"for testing"
	^resolveStrictCheckbox!

select
	| fileService |
	fileSelectorPresenter selectionMade.
	projectHomeSelector selectionMade.
	fileService := RowanFileService new
				path: projectHomeSelector pathText value;
				session: session.
	fileService directoryPath.
	self class previousProjectHomePath: fileService directoryPath.
	fileService path: fileSelectorPresenter pathText value.
	self class previousFilePath: fileService directoryPath.
	self ok!

session
	^session!

session: anObject
	session := anObject!

setPresenterModels: aGciSession
	| projectSpecService projectHomeService |
	projectSpecService := RowanFileService new path: self class previousFilePath.
	projectSpecService session: aGciSession.
	fileSelectorPresenter model: projectSpecService asValue.
	projectHomeService := RowanFileService new path: self class previousProjectHomePath.
	projectHomeService session: aGciSession.
	projectHomeSelector model: projectHomeService asValue.
	fileSelectorPresenter pathText value: self class previousFilePath.
	projectHomeSelector pathText value: self class previousProjectHomePath!

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
resolveStrictCheckbox!accessing!private! !
select!actions!public! !
session!accessing!private! !
session:!accessing!private! !
setPresenterModels:!public! !
shellName!public! !
showDirectoryContents!public! !
updateProperties!event handlers!public! !
!

!JadeiteLoadProjectDialog class methodsFor!

initialize

	super initialize. 
	self previousFilePath: JadePresenter rowanProjectsHomeEnvVarString. 
	self previousProjectHomePath: JadePresenter rowanProjectsHomeEnvVarString!

instantiateDialogOn: aGciSession
	| inst |
	inst := self create.
	inst session: aGciSession.
	inst setPresenterModels: aGciSession.
	inst showDirectoryContents.
	inst updateCaptionInSession: aGciSession.
	^inst!

previousFilePath

	^PreviousFilePath!

previousFilePath: aString

	PreviousFilePath := aString!

previousProjectHomePath

	^PreviousProjectHomePath!

previousProjectHomePath: aString

	PreviousProjectHomePath := aString!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.DialogView) 34 30 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1201 801 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 8 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 592 nil nil nil 7 nil nil nil 592 530 170 176 34 4 410 ##(Smalltalk.ListBox) 34 17 nil 592 34 2 8 1412499713 1025 704 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 nil nil nil 704 nil 8 1636776960 459270 ##(Smalltalk.Message) #displayString 8 #() 8 #() nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 1 61 498 433 395 704 1010 #caretIndex: 8 #(1) 704 1010 #horizontalExtent: 8 #(0) 704 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 30 0 0 0 216 0 0 0 227 0 0 0] 8 #() 498 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 1266 #fixedParentRight 1 1266 #fixedParentTop 61 1266 #fixedParentBottom 1 410 ##(Smalltalk.StaticText) 34 16 nil 592 34 2 8 1140850944 65 1344 nil nil nil 7 nil nil nil 1344 nil 8 1636826304 852486 ##(Smalltalk.NullConverter) nil nil nil 946 138 144 34 2 1010 #createAt:extent: 34 2 498 1 1 498 433 51 1344 1010 #text: 34 1 8 'Custom Attributes

' 1344 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 216 0 0 0 25 0 0 0] 8 #() 1216 nil 27 1234 1280 1 1296 1 1266 #relativeParentHeight 1 1266 #fixedViewTop 51 170 192 34 2 704 8 'conditionalAttributesList' nil 946 138 144 34 1 1010 #createAt:extent: 34 2 498 873 345 498 433 455 592 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 180 1 0 0 172 0 0 0 140 2 0 0 143 1 0 0] 34 2 1344 704 1216 nil 27 1234 1266 #relativeParentWidth 524806 ##(Smalltalk.Fraction) 5 7 1296 -3 1680 1954 5 11 1328 -63 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 2000 nil 480 nil 7 nil nil nil 2000 656710 1 ##(Smalltalk.CardLayout) 138 144 34 2 721414 ##(Smalltalk.Association) 8 'Projects Home' 410 ##(Smalltalk.ReferenceView) 34 14 nil 2000 34 2 8 1140850688 131073 2176 nil nil nil 5 nil nil nil 2176 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteServerFileSelectorPresenter) #resource_Default_view nil 946 138 144 34 1 1010 #createAt:extent: 34 2 498 9 53 498 857 803 2176 1154 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 176 1 0 0 171 1 0 0] 816 1216 nil 27 2130 8 'Project Spec File' 410 ##(Smalltalk.ReferenceView) 34 14 nil 2000 34 2 8 1140850688 131073 2448 nil nil nil 7 nil nil nil 2448 2242 ##(Smalltalk.JadeiteServerFileSelectorPresenter) #resource_Default_view nil 946 138 144 34 1 1010 #createAt:extent: 34 2 498 9 53 498 857 803 2448 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 176 1 0 0 171 1 0 0] 816 1216 nil 27 2448 nil nil nil 170 192 34 4 2176 8 'projectHomeSelector' 2448 8 'fileSelectorPresenter' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 2000 34 2 8 1140916736 1 2736 770 138 144 34 2 2432 2160 nil 848 nil nil 1 nil nil nil 2736 nil 8 1636683520 787814 3 ##(Smalltalk.BlockClosure) 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 2880 7 257 nil 2866 0 nil 2898 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 2944 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #noIcons nil nil nil nil nil 946 138 144 34 3 1010 #createAt:extent: 34 2 498 1 1 498 873 863 2736 1010 #setSingleSelection: 8 #(1) 2736 1010 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 2736 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 180 1 0 0 175 1 0 0] 8 #() 1216 nil 27 946 138 144 34 1 1010 #createAt:extent: 34 2 498 1 1 498 873 863 2000 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 180 1 0 0 175 1 0 0] 34 3 2448 2176 2736 1216 nil 27 1234 1280 1 1936 1954 5 7 1312 1 1328 1 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 3440 nil nil nil 7 nil nil nil 3440 530 170 176 34 4 410 ##(Smalltalk.ListBox) 34 17 nil 3440 34 2 8 1412497665 1025 3552 770 138 144 816 nil 848 480 nil 7 nil nil nil 3552 nil 8 1636776960 882 #displayString 912 8 #() false 946 138 144 34 2 1010 #createAt:extent: 34 2 498 1 61 498 435 285 3552 1010 #horizontalExtent: 8 #(0) 3552 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 30 0 0 0 217 0 0 0 172 0 0 0] 8 #() 1216 nil 27 1234 1280 1 1296 1 1312 61 1328 1 410 ##(Smalltalk.StaticText) 34 16 nil 3440 34 2 8 1140850944 65 3904 nil nil nil 7 nil nil nil 3904 nil 8 1636826304 1426 nil nil nil 946 138 144 34 2 1010 #createAt:extent: 34 2 498 1 11 498 435 51 3904 1010 #text: 34 1 8 'Components
' 3904 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 5 0 0 0 217 0 0 0 30 0 0 0] 8 #() 1216 nil 27 1234 1280 1 1296 1 1312 11 1312 61 170 192 34 2 3552 8 'componentList' nil 946 138 144 34 1 1010 #createAt:extent: 34 2 498 871 1 498 435 345 3440 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 179 1 0 0 0 0 0 0 140 2 0 0 172 0 0 0] 34 2 3552 3904 1216 nil 27 1234 1936 1954 779 1169 1296 -3 1312 1 1680 1954 5 11 410 ##(Smalltalk.CheckBox) 34 16 nil 416 34 2 8 1409363203 1 4480 721990 2 ##(Smalltalk.ValueHolder) nil nil 1114118 ##(Smalltalk.NeverSearchPolicy) false nil nil 7 nil nil nil 4480 nil 8 1636978096 1426 nil nil nil 946 138 144 34 2 1010 #createAt:extent: 34 2 498 873 799 498 433 61 4480 1010 #text: 34 1 8 'Resolve Strict?' 4480 1154 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 180 1 0 0 143 1 0 0 140 2 0 0 173 1 0 0] 8 #() 1216 nil 27 1234 1936 1954 5 7 1296 -3 1328 -63 1328 -3 170 192 34 2 4480 8 'resolveStrictCheckbox' 590342 ##(Smalltalk.Rectangle) 498 1 1 498 1 1 nil nil nil nil 3 nil nil nil nil 1 nil nil 590598 ##(Smalltalk.Semaphore) nil nil 1 false 8 2003447136 946 138 144 34 1 1010 #createAt:extent: 34 2 498 7367 21 498 1341 941 416 1154 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 99 14 0 0 10 0 0 0 1 17 0 0 224 1 0 0] 34 4 2000 3440 592 4480 1216 nil 27 )!

showOnSession: aGciSession
	| inst answer |
	inst := self instantiateDialogOn: aGciSession.
	answer := inst showModal.
	^answer! !
!JadeiteLoadProjectDialog class categoriesForMethods!
initialize!initialization!public! !
instantiateDialogOn:!instance creation!private! !
previousFilePath!accessing!public! !
previousFilePath:!accessing!public! !
previousProjectHomePath!accessing!public! !
previousProjectHomePath:!accessing!public! !
resource_Default_view!public!resources-views! !
showOnSession:!instance creation!public! !
!

