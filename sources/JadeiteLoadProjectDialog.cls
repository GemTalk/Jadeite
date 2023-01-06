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
	self previousFilePath: JadePresenter expandedRowanProjectsHome. 
	self previousProjectHomePath: JadePresenter expandedRowanProjectsHome!

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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.DialogView) 34 30 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1461 891 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 592 nil 480 nil 7 nil nil nil 592 656710 1 ##(Smalltalk.CardLayout) 138 144 34 3 721414 ##(Smalltalk.Association) 8 'Advanced' 410 ##(Smalltalk.ContainerView) 34 15 nil 592 34 2 8 1140850688 131073 768 nil nil nil 5 nil nil nil 768 530 170 176 34 6 410 ##(Smalltalk.ContainerView) 34 15 nil 768 34 2 8 1140850688 131073 880 nil nil nil 5 nil nil nil 880 530 170 176 34 4 410 ##(Smalltalk.StaticText) 34 16 nil 880 34 2 8 1140850944 65 992 nil nil nil 5 nil nil nil 992 nil 8 1597308096 852486 ##(Smalltalk.NullConverter) nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 1 11 498 707 51 992 1170 #text: 34 1 8 'Components
' 992 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 5 0 0 0 97 1 0 0 30 0 0 0] 8 #() 498 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 1410 #fixedParentRight 1 1410 #fixedParentTop 11 1456 61 410 ##(Smalltalk.ListBox) 34 17 nil 880 34 2 8 1412497665 1025 1472 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 5 nil nil nil 1472 nil 8 1597258752 459270 ##(Smalltalk.Message) #displayString 8 #() 8 #() false 1106 138 144 34 2 1170 #createAt:extent: 34 2 498 1 61 498 707 533 1472 1170 #horizontalExtent: 8 #(0) 1472 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 30 0 0 0 97 1 0 0 40 1 0 0] 8 #() 1360 nil 27 1378 1424 1 1440 1 1456 61 1410 #fixedParentBottom 1 170 192 34 2 1472 8 'componentList' nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 498 1 1 498 707 593 880 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 97 1 0 0 40 1 0 0] 34 2 1472 992 1360 nil 27 1378 1424 1 1410 #relativeParentWidth 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 224 63 1456 1 1920 -99 410 ##(Smalltalk.ContainerView) 34 15 nil 768 34 2 8 1140850688 131073 2208 nil nil nil 5 nil nil nil 2208 530 170 176 34 4 410 ##(Smalltalk.StaticText) 34 16 nil 2208 34 2 8 1140850944 65 2320 nil nil nil 5 nil nil nil 2320 nil 8 1597308096 1074 nil nil nil 1106 138 144 34 2 1170 #createAt:extent: 34 2 498 1 1 498 709 51 2320 1170 #text: 34 1 8 'Custom Attributes

' 2320 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 98 1 0 0 25 0 0 0] 8 #() 1360 nil 27 1378 1424 1 1440 1 1410 #relativeParentHeight 1 1410 #fixedViewTop 51 410 ##(Smalltalk.ListBox) 34 17 nil 2208 34 2 8 1412499713 1025 2672 1538 138 144 1584 nil 1616 480 nil 5 nil nil nil 2672 nil 8 1597258752 1650 #displayString 1680 8 #() nil 1106 138 144 34 3 1170 #createAt:extent: 34 2 498 1 61 498 709 533 2672 1170 #caretIndex: 8 #(1) 2672 1170 #horizontalExtent: 8 #(0) 2672 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 30 0 0 0 98 1 0 0 40 1 0 0] 8 #() 1360 nil 27 1378 1424 1 1440 1 1456 61 1920 1 170 192 34 2 2672 8 'conditionalAttributesList' nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 498 707 1 498 709 593 2208 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 97 1 0 0 0 0 0 0 195 2 0 0 40 1 0 0] 34 2 2320 2672 1360 nil 27 1378 2160 2178 8 0 0 0 0 0 0 224 63 1440 1 1456 1 1920 -99 410 ##(Smalltalk.CheckBox) 34 16 nil 768 34 2 8 1409363203 1 3296 721990 2 ##(Smalltalk.ValueHolder) nil nil 1114118 ##(Smalltalk.NeverSearchPolicy) false nil nil 5 nil nil nil 3296 nil 8 1597459888 1074 nil nil nil 1106 138 144 34 2 1170 #createAt:extent: 34 2 498 11 633 498 387 61 3296 1170 #text: 34 1 8 'Resolve Strict?' 3296 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 60 1 0 0 198 0 0 0 90 1 0 0] 8 #() 1360 nil 27 1378 1424 11 1410 #fixedViewLeft 387 1920 -59 1920 1 170 192 34 2 3296 8 'resolveStrictCheckbox' nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 498 9 53 498 1415 693 768 1298 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 199 2 0 0 116 1 0 0] 34 3 880 2208 3296 1360 nil 27 722 8 'Project Spec' 410 ##(Smalltalk.ContainerView) 34 15 nil 592 34 2 8 1140850688 131073 3936 nil nil nil 7 nil nil nil 3936 530 170 176 34 4 410 ##(Smalltalk.StaticText) 34 16 nil 3936 34 2 8 1140850945 65 4048 nil nil nil 7 nil nil nil 4048 nil 8 1597308096 1074 nil nil nil 1106 138 144 34 2 1170 #createAt:extent: 34 2 498 21 623 498 1395 71 4048 1170 #text: 34 1 8 'Select the project specification that you wish to load. You should also ensure that the Project Home is correct.' 4048 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 10 0 0 0 55 1 0 0 195 2 0 0 90 1 0 0] 8 #() 1360 nil 27 1378 1424 21 1440 1 1920 -69 1920 1 410 ##(Smalltalk.ReferenceView) 34 14 nil 3936 34 2 8 1140850688 131073 4368 nil nil nil 7 nil nil nil 4368 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteServerFileSelectorPresenter) #resource_Load_view nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 498 1 1 498 1415 623 4368 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 195 2 0 0 55 1 0 0] 1584 1360 nil 27 1378 1424 1 1440 1 1456 1 1920 -69 170 192 34 2 4368 8 'fileSelectorPresenter' nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 498 9 53 498 1415 693 3936 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 199 2 0 0 116 1 0 0] 34 2 4368 4048 1360 nil 27 722 8 'Project Home' 410 ##(Smalltalk.ContainerView) 34 15 nil 592 34 2 8 1140850688 131073 4864 nil nil nil 5 nil nil nil 4864 530 170 176 34 4 410 ##(Smalltalk.ReferenceView) 34 14 nil 4864 34 2 8 1140850688 131073 4976 nil 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 nil nil nil 4976 4434 ##(Smalltalk.JadeiteServerFileSelectorPresenter) #resource_Load_view nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 498 1 1 498 1415 623 4976 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 195 2 0 0 55 1 0 0] 1584 1360 nil 27 1378 1424 1 1440 1 1456 1 1920 -69 410 ##(Smalltalk.StaticText) 34 16 nil 4864 34 2 8 1140850945 65 5248 nil 5042 26337781 nil 5 nil nil nil 5248 nil 8 1597308096 1074 nil nil nil 1106 138 144 34 2 1170 #createAt:extent: 34 2 498 21 623 498 1395 71 5248 1170 #text: 34 1 8 'Select the home directory for this project. This is equivalent to the old $ROWAN_PROJECTS_HOME.' 5248 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 10 0 0 0 55 1 0 0 195 2 0 0 90 1 0 0] 8 #() 1360 nil 27 1378 1424 21 1440 1 1920 -69 1920 1 170 192 34 2 4976 8 'projectHomeSelector' nil 1106 138 144 34 1 1170 #createAt:extent: 34 2 498 9 53 498 1415 693 4864 1298 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 199 2 0 0 116 1 0 0] 34 2 4976 5248 1360 nil 27 3936 nil nil nil 170 192 34 6 4864 8 'Project Home Container' 768 8 'Advanced Container' 3936 8 '''Project Spec Container''' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 592 34 2 8 1140916736 1 5872 1538 138 144 34 3 3920 4848 752 nil 1616 nil nil 1 nil nil nil 5872 nil 8 1597165312 787814 3 ##(Smalltalk.BlockClosure) 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 6016 7 257 nil 6002 0 nil 6034 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 6080 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #noIcons nil nil nil nil nil 1106 138 144 34 3 1170 #createAt:extent: 34 2 498 1 1 498 1431 753 5872 1170 #setSingleSelection: 8 #(1) 5872 1170 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 5872 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 203 2 0 0 120 1 0 0] 8 #() 1360 nil 27 1106 138 144 34 1 1170 #createAt:extent: 34 2 498 1 1 498 1431 753 592 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 203 2 0 0 120 1 0 0] 34 4 3936 4864 768 5872 1360 nil 27 1378 1424 1 1440 3 1456 1 1920 -59 410 ##(Smalltalk.PushButton) 34 20 nil 416 34 2 8 1140924416 1 6560 nil nil nil 7 nil nil nil 6560 nil 8 1597459888 1180998 4 ##(Smalltalk.CommandDescription) nil 8 'Load' 1 1 nil nil false nil nil nil 1106 138 144 34 2 1170 #createAt:extent: 34 2 498 809 753 498 311 51 6560 1170 #text: 34 1 8 'Load' 6560 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 148 1 0 0 120 1 0 0 47 2 0 0 145 1 0 0] 8 #() 1360 nil 29 1378 1440 -619 1440 -309 1920 -59 1920 -9 410 ##(Smalltalk.PushButton) 34 20 nil 416 34 2 8 1140924416 1 6912 nil nil nil 7 nil nil nil 6912 nil 8 1597459888 6642 #cancel 8 '&Cancel' 1 1 nil nil false nil nil nil 1106 138 144 34 2 1170 #createAt:extent: 34 2 498 1119 753 498 301 51 6912 1170 #text: 34 1 8 '&Cancel' 6912 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 47 2 0 0 120 1 0 0 197 2 0 0 145 1 0 0] 8 #() 1360 nil 29 1378 1440 -309 1440 -9 1920 -59 1920 -9 170 192 1584 590342 ##(Smalltalk.Rectangle) 498 1 1 498 1 1 nil nil nil nil 5 nil nil nil nil 1 nil nil 590598 ##(Smalltalk.Semaphore) nil nil 1 false 8 2006134112 1106 138 144 34 1 1170 #createAt:extent: 34 2 498 7087 21 498 1461 891 416 1298 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 215 13 0 0 10 0 0 0 177 16 0 0 199 1 0 0] 34 3 592 6560 6912 1360 nil 27 )!

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

