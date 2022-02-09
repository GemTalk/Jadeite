"Filed out from Dolphin Smallalk"!

JadeShell subclass: #JadeiteLoadSpecEditor
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteLoadSpecEditor guid: (GUID fromString: '{d49fae44-24d8-4cfb-9c43-9be0ca22455c}')!
JadeiteLoadSpecEditor comment: ''!
!JadeiteLoadSpecEditor categoriesForClass!Unclassified! !
!JadeiteLoadSpecEditor methodsFor!

editLoadSpecFromFile
	| path |
	"path := FileOpenDialog new showModal ifNil: [^self]."

	"would like a server file browser someday"
	path := '/uffda2/users/ewinger/shared/repos/RowanSample9/rowan/specs/spec_0061.ston'.
	self createView: self class defaultView.
	model := (RowanLoadSpecService new loadSpecPath: path) editInSession: gciSession
				window: self view handle value.
	self updateCaption.
	model session: self gciSession.
	myPresenter
		model: model;
		displayLoadSpecification;
		displayTabs.
	^self show!

editLoadSpecOnProjectNamed: projectName
	self createView: self class defaultView.
	model := RowanLoadSpecService new editInSession: gciSession window: self view handle value.
	self updateCaption.
	model session: self gciSession.
	myPresenter model: model.
	^self show!

exportLoadSpec
	^myPresenter exportLoadSpec!

presenterClass
	^JadeiteLoadSpecPresenter!

updateCaption
	self caption: (gciSession titleBarFor: 'Load Specification Editor')! !
!JadeiteLoadSpecEditor categoriesForMethods!
editLoadSpecFromFile!instance creation!public! !
editLoadSpecOnProjectNamed:!instance creation!public! !
exportLoadSpec!event handlers!public! !
presenterClass!accessing!public! !
updateCaption!public! !
!

!JadeiteLoadSpecEditor class methodsFor!

editLoadSpecFromFile
	| inst |
	inst := self new. 
	^inst editLoadSpecFromFile!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1141 1351 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 592 nil nil nil 7 nil nil nil 592 530 170 176 34 4 410 ##(Smalltalk.PushButton) 34 20 nil 592 34 2 8 1149313024 1 704 nil nil nil 7 nil nil nil 704 nil 8 1591823792 1180998 4 ##(Smalltalk.CommandDescription) #exportLoadSpec 8 'Export Load Spec' 1 1 nil nil false nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 809 1223 498 301 47 704 898 #isEnabled: 8 #(false) 704 898 #text: 34 1 8 'Export Load Spec' 704 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 148 1 0 0 99 2 0 0 42 2 0 0 122 2 0 0] 8 #() 498 193 193 nil 29 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentRight -299 1184 1 1170 #fixedParentBottom -49 1200 -3 410 ##(Smalltalk.ContainerView) 34 15 nil 592 34 2 8 1140850688 131073 1216 nil nil nil 7 nil nil nil 1216 530 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 1216 34 2 8 1140850688 131073 1328 nil 480 nil 7 nil nil nil 1328 530 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 1328 34 2 8 1409286144 131073 1440 nil 480 nil 7 nil nil nil 1440 656710 1 ##(Smalltalk.CardLayout) 138 144 34 3 721414 ##(Smalltalk.Association) 8 'Conditional Attributes' 410 ##(Smalltalk.EditableListView) 34 55 nil 1440 34 2 8 1140969549 1025 1616 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 2 984134 2 ##(Smalltalk.CommandMenuItem) 1 786 #addConditionalAttribute 8 'Add Conditional Attribute' 1 1 nil nil nil 1858 1 786 #removeConditionalAttribute 8 'Delete Conditional Attribute' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 1616 nil 8 1591759072 ##(Smalltalk.BasicListAbstract) nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil 498 65 65 nil nil 138 144 34 1 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Column 1' 1085 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 1 83886081 2128 8 'doIt' 8 '[:assoc | assoc value]' 8 #[29 105 17 142 106] 2144 7 257 nil nil 1616 nil 3 nil nil true 2130 0 nil 2162 1 83886081 2128 8 'doIt' 8 '[:assoc :new  | assoc value: new ]' 8 #[29 105 233 1 143 106] 2240 7 513 nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 2336 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 2336 nil nil 852486 ##(Smalltalk.NullConverter) nil 8 '' 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 834 138 144 34 3 898 #createAt:extent: 34 2 498 9 53 498 1093 553 1616 898 #contextMenu: 34 1 1824 1616 898 #text: 34 1 8 'Column 1' 1616 1058 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 38 2 0 0 46 1 0 0] 8 #() 1120 nil 33 1570 8 'Platform Properties' 410 ##(Smalltalk.EditableListView) 34 55 nil 1440 34 2 8 1140936781 1025 2768 1682 138 144 1728 nil 1760 1778 26337781 nil 5 nil nil nil 2768 nil 8 1591759072 ##(Smalltalk.BasicListAbstract) nil 2016 nil nil nil 498 65 65 nil nil 138 144 34 2 2082 8 '' 543 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 2130 0 nil 2162 2 1 2128 8 'doIt' 8 '[:assoc | assoc key ]' 8 #[30 105 226 0 106] #key 2976 7 257 nil nil 2768 nil 3 nil nil false nil 2322 nil nil 8 #(67174528 0) 3056 2370 nil false 2416 nil nil nil 5 nil nil nil 3056 nil nil 2434 nil 8 '' 1 nil nil nil nil nil nil nil nil nil 2082 8 '' 543 #left 459270 ##(Smalltalk.Message) #displayString 8 #() 3170 #<= 3200 2130 0 nil 2162 1 83886081 2128 8 'doIt' 8 '[:assoc | assoc value ]' 8 #[29 105 17 142 106] 3232 7 257 nil nil 2768 nil 3 nil nil true 2130 0 nil 2162 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:assoc :value | assoc value: value]' 8 #[29 105 233 1 143 106] 3312 7 513 nil 2322 nil nil 8 #(67174528 0) 3392 2370 nil false 2416 nil 480 nil 5 nil nil nil 3392 nil nil nil 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 834 138 144 34 1 898 #createAt:extent: 34 2 498 9 53 498 1093 553 2768 1058 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 38 2 0 0 46 1 0 0] 8 #() 1120 nil 33 1570 8 'Comment' 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 1440 34 2 8 1174474756 1025 3648 2370 nil false 2416 nil 1778 26337781 nil 7 nil nil nil 3648 nil 8 2076917224 2434 nil nil 9 1843819265 170 192 34 8 #normal 1182790 1 ##(Smalltalk.ScintillaTextStyle) 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 1379398 1 ##(Smalltalk.ScintillaCallTipStyle) 77 466 #tooltipText 466 #tooltip 1 nil nil nil nil #callTip nil nil nil #lineNumber 3810 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #indentGuide 3810 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) nil nil nil nil 3648 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1728 nil 170 176 1728 nil nil nil nil nil 466 #silver nil nil nil nil nil nil nil 1 170 192 1728 nil nil nil nil 208 nil nil nil nil 170 192 34 6 #Error 3810 3 466 #firebrick 466 #floralWhite 1 nil nil nil nil #Error nil nil nil #Warning 3810 5 466 #darkGoldenrod 466 #ivory 1 nil nil nil nil #Warning nil nil nil #Notification 3810 7 nil 466 #gainsboro 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 834 138 144 34 7 898 #createAt:extent: 34 2 498 9 53 498 1093 553 3648 898 #caretPeriod: 8 #(530) 3648 898 #wordWrap: 8 #(true) 3648 898 #margins: 34 1 34 5 985158 3 ##(Smalltalk.ScintillaMargin) 1 3648 1 3 nil nil nil nil 4482 3 3648 33 nil nil 67108863 nil nil 4482 5 3648 1 nil nil nil nil nil 4482 7 3648 1 nil nil nil nil nil 4482 9 3648 1 nil nil nil nil nil 3648 898 #targetRange: 34 1 525062 ##(Smalltalk.Interval) 1 -1 3 3648 898 #maxCompletionListHeight: 8 #(9) 3648 898 #edgeColumn: 8 #(1) 3648 1058 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 38 2 0 0 46 1 0 0] 8 #() 1120 nil 33 3648 nil nil nil 170 192 34 6 1616 8 'conditionalAttributesPresenter' 2768 8 'platformPropertiesPresenter' 3648 8 'commentPresenter' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 1440 34 2 8 1140916736 1 4832 1682 138 144 34 3 3632 1600 2752 nil 1760 nil nil 1 nil nil nil 4832 nil 8 1591529216 2130 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 4960 7 257 nil 2130 0 nil 4978 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 5024 7 257 nil 2016 nil nil nil nil nil #noIcons nil nil nil nil nil 834 138 144 34 3 898 #createAt:extent: 34 2 498 1 1 498 1109 613 4832 898 #setSingleSelection: 8 #(1) 4832 898 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 4832 1058 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 42 2 0 0 50 1 0 0] 8 #() 1120 nil 27 834 138 144 34 1 898 #createAt:extent: 34 2 498 1 1 498 1109 613 1440 1058 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 42 2 0 0 50 1 0 0] 34 4 3648 1616 2768 4832 1120 nil 27 1138 1170 #fixedParentLeft 1 1184 1 1170 #fixedParentTop 1 1200 1 170 192 1728 nil 834 138 144 34 1 898 #createAt:extent: 34 2 498 1 611 498 1109 613 1328 1058 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 49 1 0 0 42 2 0 0 99 2 0 0] 34 1 1440 1120 nil 27 1138 5472 1 1184 1 1170 #relativeParentHeight 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 224 63 1200 1 410 ##(Smalltalk.ContainerView) 34 15 nil 1216 34 2 8 1409286144 131073 5744 nil 480 nil 7 nil nil nil 5744 530 170 176 34 2 410 ##(Smalltalk.EditableListView) 34 55 nil 5744 34 2 8 1140953165 1025 5856 1682 138 144 1728 nil 1760 480 nil 7 nil nil nil 5856 nil 8 1591759072 ##(Smalltalk.BasicListAbstract) nil 2016 nil nil nil 498 65 65 nil nil 138 144 34 2 2082 8 'Property' 401 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 2130 0 nil 2162 2 1 2128 8 'doIt' 8 '[:array | array first]' 8 #[30 105 226 0 106] #first 6048 7 257 nil nil 5856 nil 1 nil nil false nil 2322 nil nil 8 #(67174528 0) 6128 2370 nil false 2416 nil nil nil 5 nil nil nil 6128 nil nil 2434 nil 8 '' 1 nil nil nil nil nil nil nil nil nil 2082 8 'Value' 701 #left ##(Smalltalk.BasicListAbstract) 3170 #<= 8 #() 2130 0 nil 2162 2 1 2128 8 'doIt' 8 '[:array | array last ]' 8 #[30 105 226 0 106] #last 6272 7 257 nil nil 5856 nil 3 nil nil true 2130 0 nil 2162 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:array :value | array at: 2 put: value]' 8 #[29 105 17 64 18 149 106] 6352 7 513 nil 2322 nil nil 8 #(67174528 0) 6432 2370 nil false 2416 nil 480 nil 5 nil nil nil 6432 nil nil nil 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 834 138 144 34 2 898 #createAt:extent: 34 2 498 1 1 498 1109 607 5856 898 #text: 34 1 8 'Property' 5856 1058 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 42 2 0 0 47 1 0 0] 8 #() 1120 nil 33 1138 5472 1 1184 1 5488 1 1200 1 170 192 34 2 5856 8 'loadSpecPresenter' nil 834 138 144 34 1 898 #createAt:extent: 34 2 498 1 5 498 1109 607 5744 1058 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 2 0 0 0 42 2 0 0 49 1 0 0] 34 1 5856 1120 nil 27 1138 5472 1 1184 1 5488 5 5696 5714 8 0 0 0 0 0 0 224 63 170 192 34 2 5744 8 'propertyPresenter' nil 834 138 144 34 1 898 #createAt:extent: 34 2 498 1 1 498 1109 1223 1216 1058 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 42 2 0 0 99 2 0 0] 34 2 5744 1328 1120 nil 27 1138 5472 1 1184 1 5488 1 1200 -49 170 192 1728 nil 834 138 144 34 1 898 #createAt:extent: 34 2 498 1 1 498 1109 1273 592 1058 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 42 2 0 0 124 2 0 0] 34 2 1216 704 1120 nil 27 1138 5472 1 1184 1 5488 1 1200 1 170 192 1728 nil nil nil nil nil 1 nil nil nil nil 1 nil nil 834 138 144 34 1 898 #createAt:extent: 34 2 498 6513 21 498 1141 1351 416 1058 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 184 12 0 0 10 0 0 0 242 14 0 0 173 2 0 0] 34 1 592 1120 nil 27 )!

showOnSession: aGciSession
	| editor |
	editor := self new gciSession: aGciSession.
	^editor editLoadSpecFromFile! !
!JadeiteLoadSpecEditor class categoriesForMethods!
editLoadSpecFromFile!instance creation!public! !
resource_Default_view!public!resources-views! !
showOnSession:!public! !
!

