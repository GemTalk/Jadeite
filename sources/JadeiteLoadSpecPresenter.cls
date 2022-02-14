"Filed out from Dolphin Smallalk"!

JadePresenterA subclass: #JadeiteLoadSpecPresenter
	instanceVariableNames: 'loadSpecPresenter commentPresenter conditionalAttributesPresenter platformPropertiesPresenter hasUnwrittenChanges'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteLoadSpecPresenter guid: (GUID fromString: '{df273fa5-ad4a-4601-8f47-d8c78f3f6de1}')!
JadeiteLoadSpecPresenter comment: ''!
!JadeiteLoadSpecPresenter categoriesForClass!Unclassified! !
!JadeiteLoadSpecPresenter methodsFor!

addConditionalAttribute
	| attribute |
	attribute := Prompter prompt: 'Please enter new conditional attribute ...'
				caption: 'Add Conditional Attribute'.
	model conditionalAttributes add: attribute.
	self displayConditionalAttributes.
	conditionalAttributesPresenter selectionByIndex: model conditionalAttributes size.
	self conditionalAttributeItem: attribute updatedAtIndex: model conditionalAttributes size!

changePlatformPropertyItem: aMouseEvent
	(self popupEdit: platformPropertiesPresenter) ifNil: [^self].
	model setPlatformProperty: platformPropertiesPresenter selection first
		to: platformPropertiesPresenter selection last value.
	hasUnwrittenChanges := true!

commentChanged
	commentPresenter value = model comment ifTrue: [^self].
	model setComment: commentPresenter value.
	hasUnwrittenChanges := true!

conditionalAttributeItem: item updatedAtIndex: index
	model conditionalAttributeItem: item updatedAtIndex: index.
	hasUnwrittenChanges := true!

createComponents
	super createComponents.
	loadSpecPresenter := self add: ListPresenter new name: 'loadSpecPresenter'.
	commentPresenter := self add: TextPresenter new name: 'commentPresenter'.
	conditionalAttributesPresenter := self add: ListPresenter new name: 'conditionalAttributesPresenter'.
	platformPropertiesPresenter := self add: ListPresenter new name: 'platformPropertiesPresenter'!

createSchematicWiring
	super createSchematicWiring.
	loadSpecPresenter
		when: #leftButtonDoubleClicked:
			send: #onLoadSpecPropertyClicked:
			to: self.
	conditionalAttributesPresenter model
		when: #item:updatedAtIndex:
		send: #conditionalAttributeItem:updatedAtIndex:
		to: self.
	platformPropertiesPresenter
		when: #leftButtonDoubleClicked:
		send: #changePlatformPropertyItem:
		to: self.
	commentPresenter
		when: #valueChanged
		send: #commentChanged
		to: self!

displayConditionalAttributes
	conditionalAttributesPresenter
		list: (model conditionalAttributes collect: [:attribute | model conditionalAttributes -> attribute])!

displayLoadSpecification
	| assocs |
	assocs := model objects collect: [:assoc | Array with: assoc key with: assoc value asString asValue].
	assocs := assocs asSortedCollection: [:x :y | x first < y first].
	loadSpecPresenter list: assocs asArray!

displayTabs
	| propertiesArray |
	commentPresenter value: model comment.
	self displayConditionalAttributes.
	propertiesArray := OrderedCollection new.
	model platformProperties
		keysAndValuesDo: [:key :value | propertiesArray add: (Array with: key with: value asValue)].
	platformPropertiesPresenter list: propertiesArray!

exportLoadSpec
	model export.
	hasUnwrittenChanges := false!

initialize
	super initialize.
	hasUnwrittenChanges := false!

isOkayToClose
	^hasUnwrittenChanges
		ifTrue: [MessageBox confirm: 'There are unwritten changes. Exit anyway?']
		ifFalse: [true]!

loadLoadSpec
	hasUnwrittenChanges
		ifTrue: 
			[(MessageBox confirm: 'There are unwritten changes which will not be loaded. Load anyway?')
				ifFalse: [^self]].
	model load!

onCloseRequested: aCloseEvent
	aCloseEvent value: self isOkayToClose!

onLoadSpecPropertyChanged
	| selection |
	self halt. 
	selection := loadSpecPresenter selectionOrNil ifNil: [^self].
	(self popupEdit: loadSpecPresenter)
		ifNotNil: [model setLoadSpecProperty: selection first to: selection last value].
	hasUnwrittenChanges := true!

onLoadSpecPropertyClicked: aMouseEvent
	| selection |
	selection := loadSpecPresenter selectionOrNil ifNil: [^self].
	(self popupEdit: loadSpecPresenter)
		ifNotNil: [model setLoadSpecProperty: selection first to: selection last value].
	hasUnwrittenChanges := true!

popupEdit: presenter
	| aspectDialog |
	presenter selectionOrNil ifNil: [^self].
	aspectDialog := AspectEditorDialog createOn: nil asValue.
	aspectDialog recommendedRectangle: (View
				mapRectangle: (presenter view subItemRectRow: presenter view selectionByIndex column: 2)
				from: presenter
				to: View desktop).
	aspectDialog subPresenters first view
		extent: aspectDialog view extent;
		arrangement: #center.
	aspectDialog
		createAspectPresenters: (AspectAccessor subject: presenter selection aspect: (Aspect string: #last))
		for: presenter selection last.
	^aspectDialog showModal!

removeConditionalAttribute
	(MessageBox
		confirm: 'Really remove conditional attribute ''' , conditionalAttributesPresenter selection value
				, '''?')
			ifTrue: 
				[model conditionalAttributes removeAtIndex: conditionalAttributesPresenter selectionByIndex.
				self displayConditionalAttributes.
				self conditionalAttributeItem: nil updatedAtIndex: model conditionalAttributes size]! !
!JadeiteLoadSpecPresenter categoriesForMethods!
addConditionalAttribute!menu handlers!public! !
changePlatformPropertyItem:!event handlers!public! !
commentChanged!event handlers!public! !
conditionalAttributeItem:updatedAtIndex:!event handlers!public! !
createComponents!initialization!public! !
createSchematicWiring!initialization!public! !
displayConditionalAttributes!displaying!public! !
displayLoadSpecification!displaying!public! !
displayTabs!displaying!event handlers!public! !
exportLoadSpec!menu handlers!public! !
initialize!initialization!public! !
isOkayToClose!public!testing! !
loadLoadSpec!menu handlers!public! !
onCloseRequested:!event handlers!public! !
onLoadSpecPropertyChanged!event handlers!public! !
onLoadSpecPropertyClicked:!event handlers!public! !
popupEdit:!private! !
removeConditionalAttribute!menu handlers!public! !
!

!JadeiteLoadSpecPresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil nil 5 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 544 nil nil nil 5 nil nil nil 544 482 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 544 34 2 8 1140850688 131073 656 nil nil nil 5 nil nil nil 656 482 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 656 34 2 8 1409286144 131073 768 nil 327686 ##(Smalltalk.Color) #default nil 5 nil nil nil 768 482 170 176 34 2 410 ##(Smalltalk.EditableListView) 34 55 nil 768 34 2 8 1140953165 1025 912 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 848 nil 5 nil nil nil 912 nil 8 1591759072 ##(Smalltalk.BasicListAbstract) nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil 328198 ##(Smalltalk.Point) 65 65 nil nil 138 144 34 2 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Property' 401 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 1232 8 'doIt' 8 '[:array | array first]' 8 #[30 105 226 0 106] #first 1248 7 257 nil nil 912 nil 1 nil nil false nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 1360 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 1360 nil nil 852486 ##(Smalltalk.NullConverter) nil 8 '' 1 nil nil nil nil nil nil nil nil nil 1186 8 'Value' 733 #left ##(Smalltalk.BasicListAbstract) 459270 ##(Smalltalk.Message) #<= 8 #() 1234 0 nil 1266 2 1 1232 8 'doIt' 8 '[:array | array last value ]' 8 #[30 105 226 0 142 106] #last 1584 7 257 nil #value 912 nil 3 nil nil false 1234 0 nil 1266 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:array :value | array at: 2 put: value]' 8 #[29 105 17 64 18 149 106] 1664 7 513 nil 1346 nil nil 8 #(67174528 0) 1744 1394 nil false 1440 nil 848 nil 5 nil nil nil 1744 nil nil nil 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 1122 1 1 1122 1141 627 912 1874 #text: 34 1 8 'Property' 912 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 58 2 0 0 57 1 0 0] 8 #() 1122 193 193 nil 33 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 2114 #fixedParentRight 1 2114 #fixedParentTop 1 2114 #fixedParentBottom 1 170 192 34 2 912 8 'loadSpecPresenter' nil 1810 138 144 34 1 1874 #createAt:extent: 34 2 1122 1 5 1122 1141 627 768 2002 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 2 0 0 0 58 2 0 0 59 1 0 0] 34 1 912 2064 nil 27 2082 2128 1 2144 1 2160 5 2114 #relativeParentHeight 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 224 63 410 ##(Smalltalk.ContainerView) 34 15 nil 656 34 2 8 1140850688 131073 2464 nil 848 nil 5 nil nil nil 2464 482 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 2464 34 2 8 1409286144 131073 2576 nil 848 nil 5 nil nil nil 2576 656710 1 ##(Smalltalk.CardLayout) 138 144 34 3 721414 ##(Smalltalk.Association) 8 'Conditional Attributes' 410 ##(Smalltalk.EditableListView) 34 55 nil 2576 34 2 8 1140969549 1025 2752 978 138 144 1024 nil 1056 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 2 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #addConditionalAttribute 8 'Add Conditional Attribute' 1 1 nil nil nil 2930 1 2962 #removeConditionalAttribute 8 'Delete Conditional Attribute' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 2752 nil 8 1591759072 ##(Smalltalk.BasicListAbstract) nil 1104 nil nil nil 1122 65 65 nil nil 138 144 34 1 1186 8 'Column 1' 1117 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 1234 0 nil 1266 1 83886081 1232 8 'doIt' 8 '[:assoc | assoc value]' 8 #[29 105 17 142 106] 3168 7 257 nil nil 2752 nil 3 nil nil true 1234 0 nil 1266 1 83886081 1232 8 'doIt' 8 '[:assoc :new  | assoc value: new ]' 8 #[29 105 233 1 143 106] 3248 7 513 nil 1346 nil nil 8 #(67174528 0) 3328 1394 nil false 1440 nil nil nil 5 nil nil nil 3328 nil nil 1458 nil 8 '' 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 1810 138 144 34 3 1874 #createAt:extent: 34 2 1122 9 53 1122 1125 571 2752 1874 #contextMenu: 34 1 2896 2752 1874 #text: 34 1 8 'Column 1' 2752 2002 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 54 2 0 0 55 1 0 0] 8 #() 2064 nil 33 2706 8 'Platform Properties' 410 ##(Smalltalk.EditableListView) 34 55 nil 2576 34 2 8 1140936781 1025 3696 978 138 144 1024 nil 1056 2850 26337781 nil 5 nil nil nil 3696 nil 8 1591759072 ##(Smalltalk.BasicListAbstract) nil 1104 nil nil nil 1122 65 65 nil nil 138 144 34 2 1186 8 '' 559 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 1234 0 nil 1266 2 1 1232 8 'doIt' 8 '[:array | array first ]' 8 #[30 105 226 0 106] #first 3904 7 257 nil nil 3696 nil 3 nil nil false nil 1346 nil nil 8 #(67174528 0) 3984 1394 nil false 1440 nil nil nil 5 nil nil nil 3984 nil nil 1458 nil 8 '' 1 nil nil nil nil nil nil nil nil nil 1186 8 '' 559 #left 1538 #displayString 8 #() 1538 #<= 4112 1234 0 nil 1266 2 1 1232 8 'doIt' 8 '[:array | array last value ]' 8 #[30 105 226 0 142 106] #last 4144 7 257 nil nil 3696 nil 3 nil nil false 1234 0 nil 1266 2 1 1232 8 'doIt' 8 '[:array :value | array last value: value]' 8 #[30 105 226 0 18 143 106] #last 4224 7 513 nil 1346 nil nil 8 #(67174528 0) 4304 1394 nil false 1440 nil 848 nil 5 nil nil nil 4304 nil nil nil 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 1810 138 144 34 1 1874 #createAt:extent: 34 2 1122 9 53 1122 1125 571 3696 2002 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 54 2 0 0 55 1 0 0] 8 #() 2064 nil 33 2706 8 'Comment' 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 2576 34 2 8 1174474756 1025 4560 1394 nil false 1440 nil 2850 26337781 nil 5 nil nil nil 4560 nil 8 1669086696 1458 nil nil 9 1576324001 170 192 34 8 #normal 1182790 1 ##(Smalltalk.ScintillaTextStyle) 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 1379398 1 ##(Smalltalk.ScintillaCallTipStyle) 77 834 #tooltipText 834 #tooltip 1 nil nil nil nil #callTip nil nil nil #lineNumber 4722 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #indentGuide 4722 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) nil nil nil nil 4560 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1024 nil 170 176 1024 nil nil nil nil nil 834 #silver nil nil nil nil nil nil nil 1 170 192 1024 nil nil nil nil 208 nil nil nil nil 170 192 34 6 #Error 4722 3 834 #firebrick 834 #floralWhite 1 nil nil nil nil #Error nil nil nil #Warning 4722 5 834 #darkGoldenrod 834 #ivory 1 nil nil nil nil #Warning nil nil nil #Notification 4722 7 nil 834 #gainsboro 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1810 138 144 34 7 1874 #createAt:extent: 34 2 1122 9 53 1122 1125 571 4560 1874 #caretPeriod: 8 #(530) 4560 1874 #wordWrap: 8 #(true) 4560 1874 #margins: 34 1 34 5 985158 3 ##(Smalltalk.ScintillaMargin) 1 4560 1 3 nil nil nil nil 5394 3 4560 33 nil nil 67108863 nil nil 5394 5 4560 1 nil nil nil nil nil 5394 7 4560 1 nil nil nil nil nil 5394 9 4560 1 nil nil nil nil nil 4560 1874 #targetRange: 34 1 525062 ##(Smalltalk.Interval) 1 -1 3 4560 1874 #maxCompletionListHeight: 8 #(9) 4560 1874 #edgeColumn: 8 #(1) 4560 2002 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 54 2 0 0 55 1 0 0] 8 #() 2064 nil 33 4560 nil nil nil 170 192 34 6 3696 8 'platformPropertiesPresenter' 2752 8 'conditionalAttributesPresenter' 4560 8 'commentPresenter' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 2576 34 2 8 1140916736 1 5744 978 138 144 34 3 4544 2736 3680 nil 1056 nil nil 1 nil nil nil 5744 nil 8 1591529216 1234 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 5872 7 257 nil 1234 0 nil 5890 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 5936 7 257 nil 1104 nil nil nil nil nil #noIcons nil nil nil nil nil 1810 138 144 34 3 1874 #createAt:extent: 34 2 1122 1 1 1122 1141 631 5744 1874 #setSingleSelection: 8 #(1) 5744 1874 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 5744 2002 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 58 2 0 0 59 1 0 0] 8 #() 2064 nil 27 1810 138 144 34 1 1874 #createAt:extent: 34 2 1122 1 1 1122 1141 631 2576 2002 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 58 2 0 0 59 1 0 0] 34 4 4560 2752 3696 5744 2064 nil 27 2082 2128 1 2144 1 2160 1 2176 1 170 192 1024 nil 1810 138 144 34 1 1874 #createAt:extent: 34 2 1122 1 631 1122 1141 631 2464 2002 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 59 1 0 0 58 2 0 0 118 2 0 0] 34 1 2576 2064 nil 27 2082 2128 1 2144 1 2416 2434 8 0 0 0 0 0 0 224 63 2176 1 170 192 34 2 768 8 'propertyPresenter' nil 1810 138 144 34 1 1874 #createAt:extent: 34 2 1122 1 1 1122 1141 1261 656 2002 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 58 2 0 0 118 2 0 0] 34 2 768 2464 2064 nil 27 2082 2128 1 2144 1 2160 1 2176 -49 410 ##(Smalltalk.ContainerView) 34 15 nil 544 34 2 8 1140850688 131073 6816 nil nil nil 5 nil nil nil 6816 482 170 176 34 4 410 ##(Smalltalk.PushButton) 34 20 nil 6816 34 2 8 1149313024 1 6928 nil nil nil 5 nil nil nil 6928 nil 8 1591823792 2962 #exportLoadSpec 8 'Export' 1 1 nil nil false nil nil nil 1810 138 144 34 3 1874 #createAt:extent: 34 2 1122 385 1 1122 301 47 6928 1874 #isEnabled: 8 #(false) 6928 1874 #text: 34 1 8 'Export' 6928 2002 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 192 0 0 0 0 0 0 0 86 1 0 0 23 0 0 0] 8 #() 2064 nil 29 2082 2144 -299 2144 1 2160 1 2176 1 410 ##(Smalltalk.PushButton) 34 20 nil 6816 34 2 8 1149313024 1 7296 nil nil nil 5 nil nil nil 7296 nil 8 1591823792 2962 #loadLoadSpec 8 'Load' 1 1 nil nil false nil nil nil 1810 138 144 34 3 1874 #createAt:extent: 34 2 1122 1 1 1122 301 47 7296 1874 #isEnabled: 8 #(false) 7296 1874 #text: 34 1 8 'Load' 7296 2002 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 150 0 0 0 23 0 0 0] 8 #() 2064 nil 29 2082 2128 1 2128 301 2160 1 2176 1 170 192 1024 nil 1810 138 144 34 1 1874 #createAt:extent: 34 2 1122 229 1261 1122 685 47 6816 2002 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 114 0 0 0 118 2 0 0 200 1 0 0 141 2 0 0] 34 2 6928 7296 2064 nil 27 2082 2114 #relativeParentWidth 524806 ##(Smalltalk.Fraction) 3 11 7856 7874 9 11 2176 -49 2176 -3 170 192 1024 nil 1810 138 144 34 1 1874 #createAt:extent: 34 2 1122 1 1 1122 1141 1311 544 2002 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 58 2 0 0 143 2 0 0] 34 2 656 6816 2064 nil 27 2082 2128 1 2144 1 2160 1 2176 1 170 192 1024 nil 1810 138 144 34 1 1874 #createAt:extent: 34 2 1122 6513 21 1122 1141 1311 416 2002 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 184 12 0 0 10 0 0 0 242 14 0 0 153 2 0 0] 34 1 544 2064 nil 27 )! !
!JadeiteLoadSpecPresenter class categoriesForMethods!
resource_Default_view!public!resources-views! !
!

