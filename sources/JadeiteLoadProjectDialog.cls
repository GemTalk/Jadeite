"Filed out from Dolphin Smallalk"!

JadeiteServerFileSelectorDialog subclass: #JadeiteLoadProjectDialog
	instanceVariableNames: 'projectHomePresenter customAttributesList componentList session attributes components resolveStrictCheckbox urlText lastSelectedTabName'
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
			[lastSelectedTabName = 'URL Container'
				ifTrue: [Array with: lastSelectedTabName with: urlText value]
				ifFalse: 
					[{lastSelectedTabName.
						fileSelectorPresenter pathText value.
						projectHomePresenter pathText value.
						components.
						attributes.
						resolveStrictCheckbox value}]]
		ifFalse: [nil]!

apply
	self flushChanges.
	confirmed := true!

createComponents
	super createComponents.
	projectHomePresenter := self add: JadeiteServerFileSelectorPresenter new name: 'projectHomeSelector'.
	customAttributesList := self add: ListPresenter new name: 'conditionalAttributesList'.
	componentList := self add: ListPresenter new name: 'componentList'.
	resolveStrictCheckbox := self add: BooleanPresenter new name: 'resolveStrictCheckbox'.
	urlText := self add: (TextPresenter new value: 'https://') name: 'urlText'.!

createSchematicWiring
	super createSchematicWiring.
	fileSelectorPresenter directoryContentsList
		when: #selectionChanged
		send: #updateProperties
		to: self!

initialize
	super initialize.
	self class previousFilePath
		ifNil: [self class previousFilePath: JadePresenter expandedRowanProjectsHome].
	self class previousProjectHomePath
		ifNil: [self class previousProjectHomePath: JadePresenter expandedRowanProjectsHome]!

isAdvancedTabSelected
	^self selectedTab = 'Advanced Container'!

isProjectHomeTabSelected
	^self selectedTab = 'Project Home Container'!

isProjectSpecTabSelected
	^self selectedTab = 'Project Spec Container'!

isURLTabSelected
	^self selectedTab = 'URL Container'!

lastSelectedTabName
	^lastSelectedTabName!

lastSelectedTabName: anObject
	lastSelectedTabName := anObject!

load
	| fileService |
	self isURLTabSelected ifTrue: [^self loadFromUrl].
	fileSelectorPresenter isFileSelected
		ifFalse: [^MessageBox notify: 'Project Spec file must be selected'].
	fileSelectorPresenter selectionMade.
	projectHomePresenter selectionMade.
	fileService := RowanFileService new
				path: projectHomePresenter pathText value;
				session: session.
	self class previousProjectHomePath: fileService directoryPath.
	fileService path: fileSelectorPresenter pathText value.
	self class previousFilePath: fileService directoryPath.
	self ok!

loadFromUrl
	lastSelectedTabName := self selectedTab.
	confirmed := true.
	self view close.!

ok
	| fileService |
	fileService := RowanFileService new
				path: projectHomePresenter pathText value;
				session: session.
	self class previousProjectHomePath: fileService directoryPath.
	fileService path: fileSelectorPresenter pathText value.
	self class previousFilePath: fileService directoryPath.
	components := componentList selections.
	attributes := customAttributesList selections.
	lastSelectedTabName := self selectedTab.
	^super ok!

projectHomePresenter
	^projectHomePresenter!

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
			[projectHomePresenter isDirectorySelected
				ifFalse: [^MessageBox notify: 'Project Home must be a directory']]!

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
	projectHomePresenter model: projectHomeService asValue.
	fileSelectorPresenter pathText value: self class previousFilePath.
	projectHomePresenter pathText value: self class previousProjectHomePath!

shellName

	^'Jadeite Load Project Dialog'.!

showDirectoryContents
	fileSelectorPresenter showDirectoryContents.
	projectHomePresenter showDirectoryContents!

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
	componentList view selectAll!

urlText
	^urlText!

urlText: anObject
	urlText := anObject! !
!JadeiteLoadProjectDialog categoriesForMethods!
answer!accessing!public! !
apply!actions!public! !
createComponents!initialization!public! !
createSchematicWiring!initialization!public! !
initialize!initialization!public! !
isAdvancedTabSelected!public!testing! !
isProjectHomeTabSelected!public!testing! !
isProjectSpecTabSelected!public!testing! !
isURLTabSelected!public!testing! !
lastSelectedTabName!accessing!private! !
lastSelectedTabName:!accessing!private! !
load!actions!public! !
loadFromUrl!actions!private! !
ok!accessing!actions!public! !
projectHomePresenter!accessing!private! !
resolveStrictCheckbox!accessing!private! !
select!actions!public! !
selectedTab!accessing!public! !
session!accessing!private! !
session:!accessing!private! !
setPresenterModels:!public! !
shellName!public! !
showDirectoryContents!public! !
updateProperties!event handlers!public! !
urlText!accessing!private! !
urlText:!accessing!private! !
!

!JadeiteLoadProjectDialog class methodsFor!

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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.DialogView) 34 30 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1461 891 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.PushButton) 34 20 nil 416 34 2 8 1140924416 1 592 nil nil nil 7 nil nil nil 592 nil 8 1613122992 1180998 4 ##(Smalltalk.CommandDescription) #load 8 'Load' 1 1 nil nil false nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 809 753 498 311 51 592 786 #isEnabled: 8 #(false) 592 786 #text: 34 1 8 'Load' 592 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 148 1 0 0 120 1 0 0 47 2 0 0 145 1 0 0] 8 #() 498 193 193 nil 29 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentRight -619 1072 -309 1058 #fixedParentBottom -59 1088 -9 410 ##(Smalltalk.PushButton) 34 20 nil 416 34 2 8 1140924416 1 1104 nil nil nil 7 nil nil nil 1104 nil 8 1613122992 674 #cancel 8 '&Cancel' 1 1 nil nil false nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 1119 753 498 301 51 1104 786 #text: 34 1 8 '&Cancel' 1104 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 47 2 0 0 120 1 0 0 197 2 0 0 145 1 0 0] 8 #() 1008 nil 29 1026 1072 -309 1072 -9 1088 -59 1088 -9 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 1440 nil 480 nil 7 nil nil nil 1440 656710 1 ##(Smalltalk.CardLayout) 138 144 34 4 721414 ##(Smalltalk.Association) 8 'Advanced' 410 ##(Smalltalk.ContainerView) 34 15 nil 1440 34 2 8 1140850688 131073 1616 nil nil nil 5 nil nil nil 1616 530 170 176 34 4 410 ##(Smalltalk.StaticText) 34 16 nil 1616 34 2 8 1140850945 65 1728 nil nil nil 5 nil nil nil 1728 nil 8 1612971200 852486 ##(Smalltalk.NullConverter) nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 21 21 498 1375 51 1728 786 #text: 34 1 8 'Components and attributes are features in Rowan v3 that are not yet fully supported in Jadeite.' 1728 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 10 0 0 0 10 0 0 0 185 2 0 0 35 0 0 0] 8 #() 1008 nil 27 1026 1058 #fixedParentLeft 21 1072 -19 1058 #fixedParentTop 21 2080 71 410 ##(Smalltalk.ContainerView) 34 15 nil 1616 34 2 8 1140850688 131073 2096 nil nil nil 5 nil nil nil 2096 530 170 176 34 6 410 ##(Smalltalk.CheckBox) 34 16 nil 2096 34 2 8 1409363203 1 2208 721990 2 ##(Smalltalk.ValueHolder) nil nil 1114118 ##(Smalltalk.NeverSearchPolicy) false nil nil 5 nil nil nil 2208 nil 8 1613122992 1810 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 11 563 498 387 61 2208 786 #text: 34 1 8 'Resolve Strict?' 2208 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 25 1 0 0 198 0 0 0 55 1 0 0] 8 #() 1008 nil 27 1026 2064 11 1058 #fixedViewLeft 387 1088 -59 1088 1 410 ##(Smalltalk.ContainerView) 34 15 nil 2096 34 2 8 1140850688 131073 2608 nil nil nil 5 nil nil nil 2608 530 170 176 34 4 410 ##(Smalltalk.StaticText) 34 16 nil 2608 34 2 8 1140850944 65 2720 nil nil nil 5 nil nil nil 2720 nil 8 1612971200 1810 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 1 11 498 707 51 2720 786 #text: 34 1 8 'Components
' 2720 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 5 0 0 0 97 1 0 0 30 0 0 0] 8 #() 1008 nil 27 1026 2064 1 1072 1 2080 11 2080 61 410 ##(Smalltalk.ListBox) 34 17 nil 2608 34 2 8 1412497665 1025 3040 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 5 nil nil nil 3040 nil 8 1612921856 459270 ##(Smalltalk.Message) #displayString 8 #() 8 #() false 722 138 144 34 2 786 #createAt:extent: 34 2 498 1 61 498 707 463 3040 786 #horizontalExtent: 8 #(0) 3040 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 30 0 0 0 97 1 0 0 5 1 0 0] 8 #() 1008 nil 27 1026 2064 1 1072 1 2080 61 1088 1 170 192 34 2 3040 8 'componentList' nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 1 1 498 707 523 2608 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 97 1 0 0 5 1 0 0] 34 2 3040 2720 1008 nil 27 1026 2064 1 1058 #relativeParentWidth 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 224 63 2080 1 1088 -99 410 ##(Smalltalk.ContainerView) 34 15 nil 2096 34 2 8 1140850688 131073 3760 nil nil nil 5 nil nil nil 3760 530 170 176 34 4 410 ##(Smalltalk.ListBox) 34 17 nil 3760 34 2 8 1412499713 1025 3872 3106 138 144 3152 nil 3184 480 nil 5 nil nil nil 3872 nil 8 1612921856 3218 #displayString 3248 8 #() nil 722 138 144 34 3 786 #createAt:extent: 34 2 498 1 61 498 709 463 3872 786 #caretIndex: 8 #(1) 3872 786 #horizontalExtent: 8 #(0) 3872 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 30 0 0 0 98 1 0 0 5 1 0 0] 8 #() 1008 nil 27 1026 2064 1 1072 1 2080 61 1088 1 410 ##(Smalltalk.StaticText) 34 16 nil 3760 34 2 8 1140850944 65 4256 nil nil nil 5 nil nil nil 4256 nil 8 1612971200 1810 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 1 1 498 709 51 4256 786 #text: 34 1 8 'Custom Attributes

' 4256 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 98 1 0 0 25 0 0 0] 8 #() 1008 nil 27 1026 2064 1 1072 1 1058 #relativeParentHeight 1 1058 #fixedViewTop 51 170 192 34 2 3872 8 'conditionalAttributesList' nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 707 1 498 709 523 3760 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 97 1 0 0 0 0 0 0 195 2 0 0 5 1 0 0] 34 2 4256 3872 1008 nil 27 1026 3712 3730 8 0 0 0 0 0 0 224 63 1072 1 2080 1 1088 -99 170 192 34 2 2208 8 'resolveStrictCheckbox' nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 1 71 498 1415 623 2096 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 35 0 0 0 195 2 0 0 90 1 0 0] 34 3 2608 3760 2208 1008 nil 27 1026 2064 1 1072 1 2080 71 1088 1 170 192 3152 nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 9 53 498 1415 693 1616 946 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 199 2 0 0 116 1 0 0] 34 2 2096 1728 1008 nil 27 1570 8 'Project Spec' 410 ##(Smalltalk.ContainerView) 34 15 nil 1440 34 2 8 1140850688 131073 5280 nil nil nil 7 nil nil nil 5280 530 170 176 34 4 410 ##(Smalltalk.StaticText) 34 16 nil 5280 34 2 8 1140850945 65 5392 nil nil nil 7 nil nil nil 5392 nil 8 1612971200 1810 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 21 21 498 1375 51 5392 786 #text: 34 1 8 'Select the project specification that you wish to load. You should also verify that the Project Home is correct.' 5392 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 10 0 0 0 10 0 0 0 185 2 0 0 35 0 0 0] 8 #() 1008 nil 27 1026 2064 21 1072 -19 2080 21 2080 71 410 ##(Smalltalk.ReferenceView) 34 14 nil 5280 34 2 8 1140850688 131073 5712 nil nil nil 7 nil nil nil 5712 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteServerFileSelectorPresenter) #resource_Load_view nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 1 71 498 1415 623 5712 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 35 0 0 0 195 2 0 0 90 1 0 0] 3152 1008 nil 27 1026 2064 1 1072 1 2080 71 1088 1 170 192 34 2 5712 8 'fileSelectorPresenter' nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 9 53 498 1415 693 5280 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 199 2 0 0 116 1 0 0] 34 2 5712 5392 1008 nil 27 1570 8 'Project Home' 410 ##(Smalltalk.ContainerView) 34 15 nil 1440 34 2 8 1140850688 131073 6208 nil nil nil 5 nil nil nil 6208 530 170 176 34 4 410 ##(Smalltalk.ReferenceView) 34 14 nil 6208 34 2 8 1140850688 131073 6320 nil nil nil 5 nil nil nil 6320 5778 ##(Smalltalk.JadeiteServerFileSelectorPresenter) #resource_Load_view nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 1 71 498 1415 623 6320 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 35 0 0 0 195 2 0 0 90 1 0 0] 3152 1008 nil 27 1026 2064 1 1072 1 2080 71 1088 1 410 ##(Smalltalk.StaticText) 34 16 nil 6208 34 2 8 1140850945 65 6560 nil nil nil 5 nil nil nil 6560 nil 8 1612971200 1810 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 21 21 498 1375 51 6560 786 #text: 34 1 8 'Select the home directory for this project. This is equivalent to the old $ROWAN_PROJECTS_HOME.' 6560 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 10 0 0 0 10 0 0 0 185 2 0 0 35 0 0 0] 8 #() 1008 nil 27 1026 2064 21 1072 -19 2080 21 2080 71 170 192 34 2 6320 8 'projectHomeSelector' nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 9 53 498 1415 693 6208 946 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 199 2 0 0 116 1 0 0] 34 2 6320 6560 1008 nil 27 1570 8 'URL' 410 ##(Smalltalk.ContainerView) 34 15 nil 1440 34 2 8 1140850688 131073 7120 nil nil nil 5 nil nil nil 7120 530 170 176 34 6 410 ##(Smalltalk.TextEdit) 34 16 nil 7120 34 2 8 1149239424 1 7232 2274 nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 7232 nil 8 1613114800 1810 nil nil 1 722 138 144 34 3 786 #createAt:extent: 34 2 498 121 81 498 1275 61 7232 786 #text: 34 1 8 'https://' 7232 786 #setMarginWidths: 34 1 8 #(3 3) 7232 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 60 0 0 0 40 0 0 0 185 2 0 0 70 0 0 0] 8 #() 1008 nil 27 1026 2064 121 1072 -19 2080 81 2080 141 410 ##(Smalltalk.StaticText) 34 16 nil 7120 34 2 8 1140850945 65 7648 nil nil nil 5 nil nil nil 7648 nil 8 1612971200 1810 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 21 21 498 1375 51 7648 786 #text: 34 1 8 'Enter URL of project. Project Spec and Project Home not required to be set. Use full https://... address' 7648 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 10 0 0 0 10 0 0 0 185 2 0 0 35 0 0 0] 8 #() 1008 nil 27 1026 2064 21 1072 -19 2080 21 2080 71 410 ##(Smalltalk.StaticText) 34 16 nil 7120 34 2 8 1140850944 65 7968 nil nil nil 5 nil nil nil 7968 nil 8 1612971200 1810 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 21 81 498 81 61 7968 786 #text: 34 1 8 'URL:
' 7968 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 10 0 0 0 40 0 0 0 50 0 0 0 70 0 0 0] 8 #() 1008 nil 27 1026 2064 21 2064 101 2080 81 2080 141 170 192 34 2 7232 8 'urlText' nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 9 53 498 1415 693 7120 946 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 199 2 0 0 116 1 0 0] 34 3 7232 7968 7648 1008 nil 27 5280 nil nil nil 170 192 34 8 5280 8 'Project Spec Container' 1616 8 'Advanced Container' 7120 8 'URL Container' 6208 8 'Project Home Container' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 1440 34 2 8 1140916736 1 8592 3106 138 144 34 4 5264 6192 7104 1600 nil 3184 nil nil 1 nil nil nil 8592 nil 8 1612828416 787814 3 ##(Smalltalk.BlockClosure) 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 8736 7 257 nil 8722 0 nil 8754 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 8800 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #noIcons nil nil nil nil nil 722 138 144 34 3 786 #createAt:extent: 34 2 498 1 1 498 1431 753 8592 786 #setSingleSelection: 8 #(1) 8592 786 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 8592 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 203 2 0 0 120 1 0 0] 8 #() 1008 nil 27 722 138 144 34 1 786 #createAt:extent: 34 2 498 1 1 498 1431 753 1440 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 203 2 0 0 120 1 0 0] 34 5 5280 6208 7120 1616 8592 1008 nil 27 1026 2064 1 1072 3 2080 1 1088 -59 170 192 34 2 1440 8 'Tabs' 590342 ##(Smalltalk.Rectangle) 498 1 1 498 1 1 nil nil nil nil 3 nil nil nil nil 1 nil nil 590598 ##(Smalltalk.Semaphore) nil nil 1 false 8 2006592864 722 138 144 34 1 786 #createAt:extent: 34 2 498 7679 21 498 1461 891 416 946 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 217 17 0 0 199 1 0 0] 34 3 1440 592 1104 1008 nil 27 )!

showNonModalOnSession: aGciSession
	" for testing" 
	| inst  |
	inst := self instantiateDialogOn: aGciSession.
	^inst show.!

showOnSession: aGciSession
	| inst answer |
	inst := self instantiateDialogOn: aGciSession.
	answer := inst showModal.
	^answer! !
!JadeiteLoadProjectDialog class categoriesForMethods!
instantiateDialogOn:!instance creation!private! !
previousFilePath!accessing!public! !
previousFilePath:!accessing!public! !
previousProjectHomePath!accessing!public! !
previousProjectHomePath:!accessing!public! !
resource_Default_view!public!resources-views! !
showNonModalOnSession:!instance creation!public! !
showOnSession:!instance creation!public! !
!

