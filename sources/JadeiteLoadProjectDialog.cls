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

isProjectHomeTabSelected
	^self selectedTab = 'Project Home Container'!

isProjectSpecTabSelected
	^self selectedTab = 'Project Spec Container'!

load
	| fileService |
	fileSelectorPresenter isFileSelected
		ifFalse: [^MessageBox notify: 'Project Spec file must be selected'].
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

ok
	| fileService |
	fileService := RowanFileService new
				path: projectHomeSelector pathText value;
				session: session.
	fileService directoryPath.
	self class previousProjectHomePath: fileService directoryPath.
	fileService path: fileSelectorPresenter pathText value.
	self class previousFilePath: fileService directoryPath.
	components := componentList selections.
	attributes := customAttributesList selections.
	^super ok!

resolveStrictCheckbox
	"for testing"
	^resolveStrictCheckbox!

select
	self isProjectSpecTabSelected
		ifTrue: 
			[fileSelectorPresenter isDirectorySelected
				ifTrue: [^MessageBox notify: 'Project Spec must be a file']].
	self isProjectHomeTabSelected
		ifTrue: 
			[projectHomeSelector isDirectorySelected
				ifFalse: [^MessageBox notify: 'Project Home must be a directory']].!

selectedTab
	^(self view viewNamed: 'Tabs') currentCard name!

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
isProjectHomeTabSelected!public!testing! !
isProjectSpecTabSelected!public!testing! !
load!accessing!public! !
ok!accessing!public! !
resolveStrictCheckbox!accessing!private! !
select!actions!public! !
selectedTab!accessing!public! !
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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.DialogView) 34 30 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1461 891 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.PushButton) 34 20 nil 416 34 2 8 1140924416 1 592 nil nil nil 7 nil nil nil 592 nil 8 1597459888 1180998 4 ##(Smalltalk.CommandDescription) #load 8 'Load' 1 1 nil nil false nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 809 753 498 311 51 592 786 #text: 34 1 8 'Load' 592 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 148 1 0 0 120 1 0 0 47 2 0 0 145 1 0 0] 8 #() 498 193 193 nil 29 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentRight -619 1040 -309 1026 #fixedParentBottom -59 1056 -9 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 1072 nil 480 nil 7 nil nil nil 1072 656710 1 ##(Smalltalk.CardLayout) 138 144 34 3 721414 ##(Smalltalk.Association) 8 'Advanced' 410 ##(Smalltalk.ContainerView) 34 15 nil 1072 34 2 8 1140850688 131073 1248 nil nil nil 5 nil nil nil 1248 530 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 1248 34 2 8 1140850688 131073 1360 nil nil nil 5 nil nil nil 1360 530 170 176 34 6 410 ##(Smalltalk.ContainerView) 34 15 nil 1360 34 2 8 1140850688 131073 1472 nil nil nil 5 nil nil nil 1472 530 170 176 34 4 410 ##(Smalltalk.ListBox) 34 17 nil 1472 34 2 8 1412499713 1025 1584 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 5 nil nil nil 1584 nil 8 1597258752 459270 ##(Smalltalk.Message) #displayString 8 #() 8 #() nil 722 138 144 34 3 786 #createAt:extent: 34 2 498 1 61 498 709 463 1584 786 #caretIndex: 8 #(1) 1584 786 #horizontalExtent: 8 #(0) 1584 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 30 0 0 0 98 1 0 0 5 1 0 0] 8 #() 976 nil 27 994 1026 #fixedParentLeft 1 1040 1 1026 #fixedParentTop 61 1056 1 410 ##(Smalltalk.StaticText) 34 16 nil 1472 34 2 8 1140850944 65 2096 nil nil nil 5 nil nil nil 2096 nil 8 1597308096 852486 ##(Smalltalk.NullConverter) nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 1 1 498 709 51 2096 786 #text: 34 1 8 'Custom Attributes

' 2096 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 98 1 0 0 25 0 0 0] 8 #() 976 nil 27 994 2064 1 1040 1 1026 #relativeParentHeight 1 1026 #fixedViewTop 51 170 192 34 2 1584 8 'conditionalAttributesList' nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 707 1 498 709 523 1472 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 97 1 0 0 0 0 0 0 195 2 0 0 5 1 0 0] 34 2 2096 1584 976 nil 27 994 1026 #relativeParentWidth 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 224 63 1040 1 2080 1 1056 -99 410 ##(Smalltalk.ContainerView) 34 15 nil 1360 34 2 8 1140850688 131073 2736 nil nil nil 5 nil nil nil 2736 530 170 176 34 4 410 ##(Smalltalk.ListBox) 34 17 nil 2736 34 2 8 1412497665 1025 2848 1650 138 144 1696 nil 1728 480 nil 5 nil nil nil 2848 nil 8 1597258752 1762 #displayString 1792 8 #() false 722 138 144 34 2 786 #createAt:extent: 34 2 498 1 61 498 707 463 2848 786 #horizontalExtent: 8 #(0) 2848 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 30 0 0 0 97 1 0 0 5 1 0 0] 8 #() 976 nil 27 994 2064 1 1040 1 2080 61 1056 1 410 ##(Smalltalk.StaticText) 34 16 nil 2736 34 2 8 1140850944 65 3200 nil nil nil 5 nil nil nil 3200 nil 8 1597308096 2178 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 1 11 498 707 51 3200 786 #text: 34 1 8 'Components
' 3200 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 5 0 0 0 97 1 0 0 30 0 0 0] 8 #() 976 nil 27 994 2064 1 1040 1 2080 11 2080 61 170 192 34 2 2848 8 'componentList' nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 1 1 498 707 523 2736 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 97 1 0 0 5 1 0 0] 34 2 2848 3200 976 nil 27 994 2064 1 2688 2706 8 0 0 0 0 0 0 224 63 2080 1 1056 -99 410 ##(Smalltalk.CheckBox) 34 16 nil 1360 34 2 8 1409363203 1 3760 721990 2 ##(Smalltalk.ValueHolder) nil nil 1114118 ##(Smalltalk.NeverSearchPolicy) false nil nil 5 nil nil nil 3760 nil 8 1597459888 2178 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 11 563 498 387 61 3760 786 #text: 34 1 8 'Resolve Strict?' 3760 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 25 1 0 0 198 0 0 0 55 1 0 0] 8 #() 976 nil 27 994 2064 11 1026 #fixedViewLeft 387 1056 -59 1056 1 170 192 34 2 3760 8 'resolveStrictCheckbox' nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 1 1 498 1415 623 1360 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 195 2 0 0 55 1 0 0] 34 3 2736 1472 3760 976 nil 27 994 2064 1 1040 1 2080 1 1056 -69 410 ##(Smalltalk.StaticText) 34 16 nil 1248 34 2 8 1140850945 65 4384 nil nil nil 5 nil nil nil 4384 nil 8 1597308096 2178 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 21 623 498 1395 71 4384 786 #text: 34 1 8 'Components and attributes are features in Rowan v3 that are not yet fully supported in Jadeite.' 4384 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 10 0 0 0 55 1 0 0 195 2 0 0 90 1 0 0] 8 #() 976 nil 27 994 2064 21 1040 1 1056 -69 1056 1 170 192 1696 nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 9 53 498 1415 693 1248 914 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 199 2 0 0 116 1 0 0] 34 2 1360 4384 976 nil 27 1202 8 'Project Spec' 410 ##(Smalltalk.ContainerView) 34 15 nil 1072 34 2 8 1140850688 131073 4912 nil nil nil 7 nil nil nil 4912 530 170 176 34 4 410 ##(Smalltalk.StaticText) 34 16 nil 4912 34 2 8 1140850945 65 5024 nil nil nil 7 nil nil nil 5024 nil 8 1597308096 2178 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 21 623 498 1395 71 5024 786 #text: 34 1 8 'Select the project specification that you wish to load. You should also ensure that the Project Home is correct.' 5024 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 10 0 0 0 55 1 0 0 195 2 0 0 90 1 0 0] 8 #() 976 nil 27 994 2064 21 1040 1 1056 -69 1056 1 410 ##(Smalltalk.ReferenceView) 34 14 nil 4912 34 2 8 1140850688 131073 5344 nil nil nil 7 nil nil nil 5344 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteServerFileSelectorPresenter) #resource_Load_view nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 1 1 498 1415 623 5344 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 195 2 0 0 55 1 0 0] 1696 976 nil 27 994 2064 1 1040 1 2080 1 1056 -69 170 192 34 2 5344 8 'fileSelectorPresenter' nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 9 53 498 1415 693 4912 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 199 2 0 0 116 1 0 0] 34 2 5344 5024 976 nil 27 1202 8 'Project Home' 410 ##(Smalltalk.ContainerView) 34 15 nil 1072 34 2 8 1140850688 131073 5840 nil nil nil 5 nil nil nil 5840 530 170 176 34 4 410 ##(Smalltalk.ReferenceView) 34 14 nil 5840 34 2 8 1140850688 131073 5952 nil 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 nil nil nil 5952 5410 ##(Smalltalk.JadeiteServerFileSelectorPresenter) #resource_Load_view nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 1 1 498 1415 623 5952 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 195 2 0 0 55 1 0 0] 1696 976 nil 27 994 2064 1 1040 1 2080 1 1056 -69 410 ##(Smalltalk.StaticText) 34 16 nil 5840 34 2 8 1140850945 65 6224 nil 6018 26337781 nil 5 nil nil nil 6224 nil 8 1597308096 2178 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 21 623 498 1395 71 6224 786 #text: 34 1 8 'Select the home directory for this project. This is equivalent to the old $ROWAN_PROJECTS_HOME.' 6224 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 10 0 0 0 55 1 0 0 195 2 0 0 90 1 0 0] 8 #() 976 nil 27 994 2064 21 1040 1 1056 -69 1056 1 170 192 34 2 5952 8 'projectHomeSelector' nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 9 53 498 1415 693 5840 914 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 199 2 0 0 116 1 0 0] 34 2 5952 6224 976 nil 27 4912 nil nil nil 170 192 34 6 4912 8 'Project Spec Container' 5840 8 'Project Home Container' 1248 8 'Advanced Container' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 1072 34 2 8 1140916736 1 6848 1650 138 144 34 3 4896 5824 1232 nil 1728 nil nil 1 nil nil nil 6848 nil 8 1597165312 787814 3 ##(Smalltalk.BlockClosure) 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 6992 7 257 nil 6978 0 nil 7010 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 7056 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #noIcons nil nil nil nil nil 722 138 144 34 3 786 #createAt:extent: 34 2 498 1 1 498 1431 753 6848 786 #setSingleSelection: 8 #(1) 6848 786 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 6848 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 203 2 0 0 120 1 0 0] 8 #() 976 nil 27 722 138 144 34 1 786 #createAt:extent: 34 2 498 1 1 498 1431 753 1072 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 203 2 0 0 120 1 0 0] 34 4 4912 5840 1248 6848 976 nil 27 994 2064 1 1040 3 2080 1 1056 -59 410 ##(Smalltalk.PushButton) 34 20 nil 416 34 2 8 1140924416 1 7536 nil nil nil 7 nil nil nil 7536 nil 8 1597459888 674 #cancel 8 '&Cancel' 1 1 nil nil false nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 1119 753 498 301 51 7536 786 #text: 34 1 8 '&Cancel' 7536 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 47 2 0 0 120 1 0 0 197 2 0 0 145 1 0 0] 8 #() 976 nil 29 994 1040 -309 1040 -9 1056 -59 1056 -9 170 192 34 2 1072 8 'Tabs' 590342 ##(Smalltalk.Rectangle) 498 1 1 498 1 1 nil nil nil nil 3 nil nil nil nil 1 nil nil 590598 ##(Smalltalk.Semaphore) nil nil 1 false 8 2006134112 722 138 144 34 1 786 #createAt:extent: 34 2 498 7087 21 498 1461 891 416 914 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 215 13 0 0 10 0 0 0 177 16 0 0 199 1 0 0] 34 3 1072 592 7536 976 nil 27 )!

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

