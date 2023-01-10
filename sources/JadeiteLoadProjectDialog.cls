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
	urlText := self add: (TextPresenter new value: 'https:/') name: 'urlText'.!

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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.DialogView) 34 30 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1461 891 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.PushButton) 34 20 nil 416 34 2 8 1140924416 1 592 nil nil nil 7 nil nil nil 592 nil 8 1597459888 1180998 4 ##(Smalltalk.CommandDescription) #cancel 8 '&Cancel' 1 1 nil nil true nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 1119 753 498 301 51 592 786 #text: 34 1 8 '&Cancel' 592 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 47 2 0 0 120 1 0 0 197 2 0 0 145 1 0 0] 8 #() 498 193 193 nil 29 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentRight -309 1040 -9 1026 #fixedParentBottom -59 1056 -9 410 ##(Smalltalk.PushButton) 34 20 nil 416 34 2 8 1140924416 1 1072 nil nil nil 7 nil nil nil 1072 nil 8 1597459888 674 #load 8 'Load' 1 1 nil nil false nil nil nil 722 138 144 34 3 786 #createAt:extent: 34 2 498 809 753 498 311 51 1072 786 #isEnabled: 8 #(false) 1072 786 #text: 34 1 8 'Load' 1072 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 148 1 0 0 120 1 0 0 47 2 0 0 145 1 0 0] 8 #() 976 nil 29 994 1040 -619 1040 -309 1056 -59 1056 -9 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 1440 nil 480 nil 7 nil nil nil 1440 656710 1 ##(Smalltalk.CardLayout) 138 144 34 4 721414 ##(Smalltalk.Association) 8 'Advanced' 410 ##(Smalltalk.ContainerView) 34 15 nil 1440 34 2 8 1140850688 131073 1616 nil nil nil 5 nil nil nil 1616 530 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 1616 34 2 8 1140850688 131073 1728 nil nil nil 5 nil nil nil 1728 530 170 176 34 6 410 ##(Smalltalk.ContainerView) 34 15 nil 1728 34 2 8 1140850688 131073 1840 nil nil nil 5 nil nil nil 1840 530 170 176 34 4 410 ##(Smalltalk.ListBox) 34 17 nil 1840 34 2 8 1412499713 1025 1952 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 5 nil nil nil 1952 nil 8 1597258752 459270 ##(Smalltalk.Message) #displayString 8 #() 8 #() nil 722 138 144 34 3 786 #createAt:extent: 34 2 498 1 61 498 709 463 1952 786 #caretIndex: 8 #(1) 1952 786 #horizontalExtent: 8 #(0) 1952 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 30 0 0 0 98 1 0 0 5 1 0 0] 8 #() 976 nil 27 994 1026 #fixedParentLeft 1 1040 1 1026 #fixedParentTop 61 1056 1 410 ##(Smalltalk.StaticText) 34 16 nil 1840 34 2 8 1140850944 65 2464 nil nil nil 5 nil nil nil 2464 nil 8 1597308096 852486 ##(Smalltalk.NullConverter) nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 1 1 498 709 51 2464 786 #text: 34 1 8 'Custom Attributes

' 2464 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 98 1 0 0 25 0 0 0] 8 #() 976 nil 27 994 2432 1 1040 1 1026 #relativeParentHeight 1 1026 #fixedViewTop 51 170 192 34 2 1952 8 'conditionalAttributesList' nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 707 1 498 709 523 1840 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 97 1 0 0 0 0 0 0 195 2 0 0 5 1 0 0] 34 2 2464 1952 976 nil 27 994 1026 #relativeParentWidth 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 224 63 1040 1 2448 1 1056 -99 410 ##(Smalltalk.ContainerView) 34 15 nil 1728 34 2 8 1140850688 131073 3104 nil nil nil 5 nil nil nil 3104 530 170 176 34 4 410 ##(Smalltalk.StaticText) 34 16 nil 3104 34 2 8 1140850944 65 3216 nil nil nil 5 nil nil nil 3216 nil 8 1597308096 2546 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 1 11 498 707 51 3216 786 #text: 34 1 8 'Components
' 3216 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 5 0 0 0 97 1 0 0 30 0 0 0] 8 #() 976 nil 27 994 2432 1 1040 1 2448 11 2448 61 410 ##(Smalltalk.ListBox) 34 17 nil 3104 34 2 8 1412497665 1025 3536 2018 138 144 2064 nil 2096 480 nil 5 nil nil nil 3536 nil 8 1597258752 2130 #displayString 2160 8 #() false 722 138 144 34 2 786 #createAt:extent: 34 2 498 1 61 498 707 463 3536 786 #horizontalExtent: 8 #(0) 3536 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 30 0 0 0 97 1 0 0 5 1 0 0] 8 #() 976 nil 27 994 2432 1 1040 1 2448 61 1056 1 170 192 34 2 3536 8 'componentList' nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 1 1 498 707 523 3104 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 97 1 0 0 5 1 0 0] 34 2 3536 3216 976 nil 27 994 2432 1 3056 3074 8 0 0 0 0 0 0 224 63 2448 1 1056 -99 410 ##(Smalltalk.CheckBox) 34 16 nil 1728 34 2 8 1409363203 1 4128 721990 2 ##(Smalltalk.ValueHolder) nil nil 1114118 ##(Smalltalk.NeverSearchPolicy) false nil nil 5 nil nil nil 4128 nil 8 1597459888 2546 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 11 563 498 387 61 4128 786 #text: 34 1 8 'Resolve Strict?' 4128 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 25 1 0 0 198 0 0 0 55 1 0 0] 8 #() 976 nil 27 994 2432 11 1026 #fixedViewLeft 387 1056 -59 1056 1 170 192 34 2 4128 8 'resolveStrictCheckbox' nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 1 1 498 1415 623 1728 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 195 2 0 0 55 1 0 0] 34 3 3104 1840 4128 976 nil 27 994 2432 1 1040 1 2448 1 1056 -69 410 ##(Smalltalk.StaticText) 34 16 nil 1616 34 2 8 1140850945 65 4752 nil nil nil 5 nil nil nil 4752 nil 8 1597308096 2546 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 21 623 498 1395 71 4752 786 #text: 34 1 8 'Components and attributes are features in Rowan v3 that are not yet fully supported in Jadeite.' 4752 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 10 0 0 0 55 1 0 0 195 2 0 0 90 1 0 0] 8 #() 976 nil 27 994 2432 21 1040 1 1056 -69 1056 1 170 192 2064 nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 9 53 498 1415 693 1616 914 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 199 2 0 0 116 1 0 0] 34 2 1728 4752 976 nil 27 1570 8 'Project Spec' 410 ##(Smalltalk.ContainerView) 34 15 nil 1440 34 2 8 1140850688 131073 5280 nil nil nil 7 nil nil nil 5280 530 170 176 34 4 410 ##(Smalltalk.StaticText) 34 16 nil 5280 34 2 8 1140850945 65 5392 nil nil nil 7 nil nil nil 5392 nil 8 1597308096 2546 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 21 623 498 1395 71 5392 786 #text: 34 1 8 'Select the project specification that you wish to load. You should also ensure that the Project Home is correct.' 5392 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 10 0 0 0 55 1 0 0 195 2 0 0 90 1 0 0] 8 #() 976 nil 27 994 2432 21 1040 1 1056 -69 1056 1 410 ##(Smalltalk.ReferenceView) 34 14 nil 5280 34 2 8 1140850688 131073 5712 nil nil nil 7 nil nil nil 5712 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteServerFileSelectorPresenter) #resource_Load_view nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 1 1 498 1415 623 5712 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 195 2 0 0 55 1 0 0] 2064 976 nil 27 994 2432 1 1040 1 2448 1 1056 -69 170 192 34 2 5712 8 'fileSelectorPresenter' nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 9 53 498 1415 693 5280 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 199 2 0 0 116 1 0 0] 34 2 5712 5392 976 nil 27 1570 8 'Project Home' 410 ##(Smalltalk.ContainerView) 34 15 nil 1440 34 2 8 1140850688 131073 6208 nil nil nil 5 nil nil nil 6208 530 170 176 34 4 410 ##(Smalltalk.ReferenceView) 34 14 nil 6208 34 2 8 1140850688 131073 6320 nil 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 nil nil nil 6320 5778 ##(Smalltalk.JadeiteServerFileSelectorPresenter) #resource_Load_view nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 1 1 498 1415 623 6320 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 195 2 0 0 55 1 0 0] 2064 976 nil 27 994 2432 1 1040 1 2448 1 1056 -69 410 ##(Smalltalk.StaticText) 34 16 nil 6208 34 2 8 1140850945 65 6592 nil 6386 26337781 nil 5 nil nil nil 6592 nil 8 1597308096 2546 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 21 623 498 1395 71 6592 786 #text: 34 1 8 'Select the home directory for this project. This is equivalent to the old $ROWAN_PROJECTS_HOME.' 6592 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 10 0 0 0 55 1 0 0 195 2 0 0 90 1 0 0] 8 #() 976 nil 27 994 2432 21 1040 1 1056 -69 1056 1 170 192 34 2 6320 8 'projectHomeSelector' nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 9 53 498 1415 693 6208 914 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 199 2 0 0 116 1 0 0] 34 2 6320 6592 976 nil 27 1570 8 'URL' 410 ##(Smalltalk.ContainerView) 34 15 nil 1440 34 2 8 1140850688 131073 7168 nil nil nil 5 nil nil nil 7168 530 170 176 34 6 410 ##(Smalltalk.StaticText) 34 16 nil 7168 34 2 8 1140850945 65 7280 nil nil nil 5 nil nil nil 7280 nil 8 1597308096 2546 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 21 623 498 1395 71 7280 786 #text: 34 1 8 'Enter URL of project. Project Spec and Project Home not required to be set. Use full https://... address' 7280 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 10 0 0 0 55 1 0 0 195 2 0 0 90 1 0 0] 8 #() 976 nil 27 994 2432 21 1040 1 1056 -69 1056 1 410 ##(Smalltalk.TextEdit) 34 16 nil 7168 34 2 8 1149239424 1 7600 4194 nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 7600 nil 8 1597451696 2546 nil nil 1 722 138 144 34 3 786 #createAt:extent: 34 2 498 121 21 498 1275 61 7600 786 #text: 34 1 8 'https://' 7600 786 #setMarginWidths: 34 1 8 #(3 3) 7600 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 60 0 0 0 10 0 0 0 185 2 0 0 40 0 0 0] 8 #() 976 nil 27 994 2432 121 1040 -19 2448 21 2448 81 410 ##(Smalltalk.StaticText) 34 16 nil 7168 34 2 8 1140850944 65 8016 nil nil nil 5 nil nil nil 8016 nil 8 1597308096 2546 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 21 21 498 81 61 8016 786 #text: 34 1 8 'URL:
' 8016 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 10 0 0 0 10 0 0 0 50 0 0 0 40 0 0 0] 8 #() 976 nil 27 994 2432 21 2432 101 2448 21 2448 81 170 192 34 2 7600 8 'urlText' nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 9 53 498 1415 693 7168 914 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 199 2 0 0 116 1 0 0] 34 3 7600 8016 7280 976 nil 27 5280 nil nil nil 170 192 34 8 1616 8 'Advanced Container' 6208 8 'Project Home Container' 7168 8 'URL Container' 5280 8 'Project Spec Container' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 1440 34 2 8 1140916736 1 8640 2018 138 144 34 4 5264 6192 7152 1600 nil 2096 nil nil 1 nil nil nil 8640 nil 8 1597165312 787814 3 ##(Smalltalk.BlockClosure) 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 8784 7 257 nil 8770 0 nil 8802 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 8848 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #noIcons nil nil nil nil nil 722 138 144 34 3 786 #createAt:extent: 34 2 498 1 1 498 1431 753 8640 786 #setSingleSelection: 8 #(1) 8640 786 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 8640 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 203 2 0 0 120 1 0 0] 8 #() 976 nil 27 722 138 144 34 1 786 #createAt:extent: 34 2 498 1 1 498 1431 753 1440 914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 203 2 0 0 120 1 0 0] 34 5 5280 6208 7168 1616 8640 976 nil 27 994 2432 1 1040 3 2448 1 1056 -59 170 192 34 2 1440 8 'Tabs' 590342 ##(Smalltalk.Rectangle) 498 1 1 498 1 1 nil nil nil nil 5 nil nil nil nil 1 nil nil 590598 ##(Smalltalk.Semaphore) nil nil 1 false 8 2006134112 722 138 144 34 1 786 #createAt:extent: 34 2 498 7087 21 498 1461 891 416 914 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 215 13 0 0 10 0 0 0 177 16 0 0 199 1 0 0] 34 3 1440 1072 592 976 nil 27 )!

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

