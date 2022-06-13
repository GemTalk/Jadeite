"Filed out from Dolphin Smallalk"!

JadePresenter subclass: #JadeiteAddPackagePresenter
	instanceVariableNames: 'symbolDictionaryPresenter componentPresenter newPackagePresenter projectService'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteAddPackagePresenter guid: (GUID fromString: '{64f74889-ab69-43e4-a5e5-7e333491a13e}')!
JadeiteAddPackagePresenter comment: ''!
!JadeiteAddPackagePresenter categoriesForClass!Unclassified! !
!JadeiteAddPackagePresenter methodsFor!

addPackage
	newPackagePresenter value isNil ifTrue: [^MessageBox notify: 'Must enter a valid package name'].
	newPackagePresenter value = String new
		ifTrue: [^MessageBox notify: 'Must enter a valid package name'].
	projectService
		command: #addNewPackageNamed:inSymbolDictionaryNamed:toComponentNamed:;
		commandArgs: (Array
					with: newPackagePresenter value
					with: symbolDictionaryPresenter selection
					with: componentPresenter selection).
	self issueCommand: projectService!

addSystemBrowser
	"pass along to the browser"

	self topShell addSystemBrowser!

createComponents
	super createComponents.
	newPackagePresenter := self add: TextPresenter new name: 'newPackagePresenter'.
	symbolDictionaryPresenter := self add: ListPresenter new name: 'symbolDictionaryPresenter'.
	componentPresenter := self add: ListPresenter new name: 'componentPresenter'.!

initializeComponents
	| componentNames |
	projectService componentServices ifNil:[^self]. "none project selected" 
	componentNames := projectService componentServices keys
				select: [:componentService | (componentService == #nil) not]
				thenCollect: [:componentService | componentService name].
	componentPresenter list: componentNames asSortedCollection asOrderedCollection!

initializeLists
	self initializeComponents. 
	self initializeSymbolDictionaries. 
	newPackagePresenter value: String new. !

initializeSymbolDictionaries
	| dictionaryNames |
	dictionaryNames := RowanAnsweringService new symbolDictionaryNames: gciSession.
	symbolDictionaryPresenter list: dictionaryNames!

projectService
	^projectService!

projectService: anObject
	projectService := anObject.
	self initializeLists! !
!JadeiteAddPackagePresenter categoriesForMethods!
addPackage!actions!public! !
addSystemBrowser!actions!public! !
createComponents!initialization!public! !
initializeComponents!initialization!public! !
initializeLists!initialization!public! !
initializeSymbolDictionaries!initialization!public! !
projectService!accessing!private! !
projectService:!accessing!private! !
!

!JadeiteAddPackagePresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1417674752 131073 416 nil 327686 ##(Smalltalk.Color) #default nil 5 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 576 nil nil nil 5 nil nil nil 576 514 170 176 34 2 410 ##(Smalltalk.PushButton) 34 20 nil 576 34 2 8 1149313024 1 688 nil nil nil 5 nil nil nil 688 nil 8 1728990640 1180998 4 ##(Smalltalk.CommandDescription) #addPackage 8 'Add Package' 1 1 nil nil false nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 328198 ##(Smalltalk.Point) 251 21 930 277 61 688 882 #text: 34 1 8 'Add Package' 688 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 125 0 0 0 10 0 0 0 7 1 0 0 40 0 0 0] 8 #() 930 193 193 nil 29 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 251 1138 #fixedParentRight -249 1138 #fixedParentTop 21 1138 #fixedParentBottom -39 170 192 8 #() nil 818 138 144 34 1 882 #createAt:extent: 34 2 930 1 377 930 777 121 576 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 188 0 0 0 132 1 0 0 248 0 0 0] 34 1 688 1088 nil 27 1106 1152 1 1168 1 1200 -119 1200 1 410 ##(Smalltalk.StaticText) 34 16 nil 416 34 2 8 1140850945 65 1424 nil nil nil 5 nil 263174 ##(Smalltalk.Font) nil true 524550 ##(Smalltalk.LOGFONTW) 8 #[237 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 188 2 0 0 0 0 0 0 1 2 1 34 83 0 121 0 115 0 116 0 101 0 109 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 930 193 193 nil 1424 nil 8 1728838848 852486 ##(Smalltalk.NullConverter) nil nil nil 818 138 144 34 2 882 #createAt:extent: 34 2 930 21 21 930 737 61 1424 882 #text: 34 1 8 'Add Package
' 1424 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 10 0 0 0 10 0 0 0 122 1 0 0 40 0 0 0] 8 #() 1088 nil 27 1106 1152 21 1168 -19 1184 21 1138 #fixedViewTop 61 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 1872 nil nil nil 5 nil nil nil 1872 514 170 176 34 12 410 ##(Smalltalk.StaticText) 34 16 nil 1872 34 2 8 1140850944 65 1984 nil nil nil 5 nil nil nil 1984 nil 8 1728838848 1602 nil nil nil 818 138 144 34 2 882 #createAt:extent: 34 2 930 21 11 930 221 61 1984 882 #text: 34 1 8 'New Package:
' 1984 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 10 0 0 0 5 0 0 0 120 0 0 0 35 0 0 0] 8 #() 1088 nil 27 1106 1152 21 1138 #fixedViewLeft 221 1184 11 1856 61 410 ##(Smalltalk.StaticText) 34 16 nil 1872 34 2 8 1140850944 65 2320 nil nil nil 5 nil nil nil 2320 nil 8 1728838848 1602 nil nil nil 818 138 144 34 2 882 #createAt:extent: 34 2 930 21 201 930 231 51 2320 882 #text: 34 1 8 'Symbol Dictionary:
' 2320 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 10 0 0 0 100 0 0 0 125 0 0 0 125 0 0 0] 8 #() 1088 nil 27 1106 1152 21 2304 231 1184 201 1856 51 410 ##(Smalltalk.ComboBox) 34 17 nil 1872 34 2 8 1412498947 1025 2640 590662 2 ##(Smalltalk.ListModel) 138 144 1232 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 496 nil 5 nil nil nil 2640 nil 8 1728782432 459270 ##(Smalltalk.Message) #displayString 8 #() 8 #() 401 818 138 144 34 1 882 #createAt:extent: 34 2 930 311 111 930 447 51 2640 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 155 0 0 0 55 0 0 0 122 1 0 0 80 0 0 0] 8 #() 1088 nil 27 1106 1152 311 1168 -19 1184 111 1856 51 410 ##(Smalltalk.TextEdit) 34 16 nil 1872 34 2 8 1140916352 1025 3040 nil 496 nil 5 nil nil nil 3040 nil 8 1728982448 1602 nil nil 1 818 138 144 34 1 882 #createAt:extent: 34 2 930 311 11 930 447 51 3040 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 155 0 0 0 5 0 0 0 122 1 0 0 30 0 0 0] 8 #() 1088 nil 27 1106 1152 311 1168 -19 1184 11 1856 51 410 ##(Smalltalk.StaticText) 34 16 nil 1872 34 2 8 1140850944 65 3312 nil nil nil 5 nil nil nil 3312 nil 8 1728838848 1602 nil nil nil 818 138 144 34 2 882 #createAt:extent: 34 2 930 21 111 930 221 71 3312 882 #text: 34 1 8 'Component:


' 3312 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 10 0 0 0 55 0 0 0 120 0 0 0 90 0 0 0] 8 #() 1088 nil 27 1106 1152 21 2304 221 1184 111 1856 71 410 ##(Smalltalk.ComboBox) 34 17 nil 1872 34 2 8 1412498947 1025 3632 2706 138 144 1232 nil 2768 496 nil 5 nil nil nil 3632 nil 8 1728782432 2802 #displayString 8 #() 8 #() 401 818 138 144 34 1 882 #createAt:extent: 34 2 930 311 201 930 447 51 3632 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 155 0 0 0 100 0 0 0 122 1 0 0 125 0 0 0] 8 #() 1088 nil 27 1106 1152 311 1168 -19 1184 201 1856 51 170 192 34 6 3632 8 'symbolDictionaryPresenter' 2640 8 'componentPresenter' 3040 8 'newPackagePresenter' nil 818 138 144 34 1 882 #createAt:extent: 34 2 930 1 101 930 777 261 1872 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 50 0 0 0 132 1 0 0 180 0 0 0] 34 6 1984 3040 3312 2640 2320 3632 1088 nil 27 1106 1152 1 1168 1 1184 101 1184 361 170 192 1232 nil 818 138 144 34 1 882 #createAt:extent: 34 2 930 6859 21 930 781 501 416 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 101 13 0 0 10 0 0 0 235 14 0 0 4 1 0 0] 34 3 1424 1872 576 1088 nil 27 )! !
!JadeiteAddPackagePresenter class categoriesForMethods!
resource_Default_view!public!resources-views! !
!

