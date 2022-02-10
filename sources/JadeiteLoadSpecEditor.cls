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

loadLoadSpec
	^myPresenter loadLoadSpec!

presenterClass
	^JadeiteLoadSpecPresenter!

updateCaption
	self caption: (gciSession titleBarFor: 'Load Specification Editor')! !
!JadeiteLoadSpecEditor categoriesForMethods!
editLoadSpecFromFile!instance creation!public! !
editLoadSpecOnProjectNamed:!instance creation!public! !
exportLoadSpec!event handlers!public! !
loadLoadSpec!event handlers!public! !
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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1141 1351 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 592 nil nil nil 7 nil nil nil 592 530 170 176 34 6 410 ##(Smalltalk.ContainerView) 34 15 nil 592 34 2 8 1140850688 131073 704 nil nil nil 7 nil nil nil 704 530 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 704 34 2 8 1409286144 131073 816 nil 480 nil 7 nil nil nil 816 530 170 176 34 2 410 ##(Smalltalk.EditableListView) 34 55 nil 816 34 2 8 1140953165 1025 928 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 nil nil nil 928 nil 8 1591759072 ##(Smalltalk.BasicListAbstract) nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil 498 65 65 nil nil 138 144 34 2 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Property' 401 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 1232 8 'doIt' 8 '[:array | array first]' 8 #[30 105 226 0 106] #first 1248 7 257 nil nil 928 nil 1 nil nil false nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 1360 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 1360 nil nil 852486 ##(Smalltalk.NullConverter) nil 8 '' 1 nil nil nil nil nil nil nil nil nil 1186 8 'Value' 701 #left ##(Smalltalk.BasicListAbstract) 459270 ##(Smalltalk.Message) #<= 8 #() 1234 0 nil 1266 2 1 1232 8 'doIt' 8 '[:array | array last value ]' 8 #[30 105 226 0 142 106] #last 1584 7 257 nil #value 928 nil 3 nil nil false 1234 0 nil 1266 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:array :value | array at: 2 put: value]' 8 #[29 105 17 64 18 149 106] 1664 7 513 nil 1346 nil nil 8 #(67174528 0) 1744 1394 nil false 1440 nil 480 nil 5 nil nil nil 1744 nil nil nil 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 1 1 498 1109 607 928 1874 #text: 34 1 8 'Property' 928 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 42 2 0 0 47 1 0 0] 8 #() 498 193 193 nil 33 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 2114 #fixedParentRight 1 2114 #fixedParentTop 1 2114 #fixedParentBottom 1 170 192 34 2 928 8 'loadSpecPresenter' nil 1810 138 144 34 1 1874 #createAt:extent: 34 2 498 1 5 498 1109 607 816 2002 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 2 0 0 0 42 2 0 0 49 1 0 0] 34 1 928 2064 nil 27 2082 2128 1 2144 1 2160 5 2114 #relativeParentHeight 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 224 63 410 ##(Smalltalk.ContainerView) 34 15 nil 704 34 2 8 1140850688 131073 2464 nil 480 nil 7 nil nil nil 2464 530 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 2464 34 2 8 1409286144 131073 2576 nil 480 nil 7 nil nil nil 2576 656710 1 ##(Smalltalk.CardLayout) 138 144 34 3 721414 ##(Smalltalk.Association) 8 'Conditional Attributes' 410 ##(Smalltalk.EditableListView) 34 55 nil 2576 34 2 8 1140969549 1025 2752 994 138 144 1040 nil 1072 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 2 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #addConditionalAttribute 8 'Add Conditional Attribute' 1 1 nil nil nil 2930 1 2962 #removeConditionalAttribute 8 'Delete Conditional Attribute' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 2752 nil 8 1591759072 ##(Smalltalk.BasicListAbstract) nil 1120 nil nil nil 498 65 65 nil nil 138 144 34 1 1186 8 'Column 1' 1085 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 1234 0 nil 1266 1 83886081 1232 8 'doIt' 8 '[:assoc | assoc value]' 8 #[29 105 17 142 106] 3168 7 257 nil nil 2752 nil 3 nil nil true 1234 0 nil 1266 1 83886081 1232 8 'doIt' 8 '[:assoc :new  | assoc value: new ]' 8 #[29 105 233 1 143 106] 3248 7 513 nil 1346 nil nil 8 #(67174528 0) 3328 1394 nil false 1440 nil nil nil 5 nil nil nil 3328 nil nil 1458 nil 8 '' 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 1810 138 144 34 3 1874 #createAt:extent: 34 2 498 9 53 498 1093 553 2752 1874 #contextMenu: 34 1 2896 2752 1874 #text: 34 1 8 'Column 1' 2752 2002 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 38 2 0 0 46 1 0 0] 8 #() 2064 nil 33 2706 8 'Platform Properties' 410 ##(Smalltalk.EditableListView) 34 55 nil 2576 34 2 8 1140936781 1025 3696 994 138 144 1040 nil 1072 2850 26337781 nil 5 nil nil nil 3696 nil 8 1591759072 ##(Smalltalk.BasicListAbstract) nil 1120 nil nil nil 498 65 65 nil nil 138 144 34 2 1186 8 '' 543 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 1234 0 nil 1266 2 1 1232 8 'doIt' 8 '[:assoc | assoc key ]' 8 #[30 105 226 0 106] #key 3904 7 257 nil nil 3696 nil 3 nil nil false nil 1346 nil nil 8 #(67174528 0) 3984 1394 nil false 1440 nil nil nil 5 nil nil nil 3984 nil nil 1458 nil 8 '' 1 nil nil nil nil nil nil nil nil nil 1186 8 '' 543 #left 1538 #displayString 8 #() 1538 #<= 4112 1234 0 nil 1266 1 83886081 1232 8 'doIt' 8 '[:assoc | assoc value ]' 8 #[29 105 17 142 106] 4144 7 257 nil nil 3696 nil 3 nil nil true 1234 0 nil 1266 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:assoc :value | assoc value: value]' 8 #[29 105 233 1 143 106] 4224 7 513 nil 1346 nil nil 8 #(67174528 0) 4304 1394 nil false 1440 nil 480 nil 5 nil nil nil 4304 nil nil nil 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 1810 138 144 34 1 1874 #createAt:extent: 34 2 498 9 53 498 1093 553 3696 2002 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 38 2 0 0 46 1 0 0] 8 #() 2064 nil 33 2706 8 'Comment' 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 2576 34 2 8 1174474756 1025 4560 1394 nil false 1440 nil 2850 26337781 nil 7 nil nil nil 4560 nil 8 1669086696 1458 nil nil 9 55104561 170 192 34 8 #normal 1182790 1 ##(Smalltalk.ScintillaTextStyle) 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 1379398 1 ##(Smalltalk.ScintillaCallTipStyle) 77 466 #tooltipText 466 #tooltip 1 nil nil nil nil #callTip nil nil nil #lineNumber 4722 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #indentGuide 4722 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) nil nil nil nil 4560 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1040 nil 170 176 1040 nil nil nil nil nil 466 #silver nil nil nil nil nil nil nil 1 170 192 1040 nil nil nil nil 208 nil nil nil nil 170 192 34 6 #Error 4722 3 466 #firebrick 466 #floralWhite 1 nil nil nil nil #Error nil nil nil #Warning 4722 5 466 #darkGoldenrod 466 #ivory 1 nil nil nil nil #Warning nil nil nil #Notification 4722 7 nil 466 #gainsboro 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1810 138 144 34 7 1874 #createAt:extent: 34 2 498 9 53 498 1093 553 4560 1874 #caretPeriod: 8 #(530) 4560 1874 #wordWrap: 8 #(true) 4560 1874 #margins: 34 1 34 5 985158 3 ##(Smalltalk.ScintillaMargin) 1 4560 1 3 nil nil nil nil 5394 3 4560 33 nil nil 67108863 nil nil 5394 5 4560 1 nil nil nil nil nil 5394 7 4560 1 nil nil nil nil nil 5394 9 4560 1 nil nil nil nil nil 4560 1874 #targetRange: 34 1 525062 ##(Smalltalk.Interval) 1 -1 3 4560 1874 #maxCompletionListHeight: 8 #(9) 4560 1874 #edgeColumn: 8 #(1) 4560 2002 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 38 2 0 0 46 1 0 0] 8 #() 2064 nil 33 4560 nil nil nil 170 192 34 6 4560 8 'commentPresenter' 2752 8 'conditionalAttributesPresenter' 3696 8 'platformPropertiesPresenter' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 2576 34 2 8 1140916736 1 5744 994 138 144 34 3 4544 2736 3680 nil 1072 nil nil 1 nil nil nil 5744 nil 8 1591529216 1234 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 5872 7 257 nil 1234 0 nil 5890 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 5936 7 257 nil 1120 nil nil nil nil nil #noIcons nil nil nil nil nil 1810 138 144 34 3 1874 #createAt:extent: 34 2 498 1 1 498 1109 613 5744 1874 #setSingleSelection: 8 #(1) 5744 1874 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 5744 2002 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 42 2 0 0 50 1 0 0] 8 #() 2064 nil 27 1810 138 144 34 1 1874 #createAt:extent: 34 2 498 1 1 498 1109 613 2576 2002 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 42 2 0 0 50 1 0 0] 34 4 4560 2752 3696 5744 2064 nil 27 2082 2128 1 2144 1 2160 1 2176 1 170 192 1040 nil 1810 138 144 34 1 1874 #createAt:extent: 34 2 498 1 611 498 1109 613 2464 2002 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 49 1 0 0 42 2 0 0 99 2 0 0] 34 1 2576 2064 nil 27 2082 2128 1 2144 1 2416 2434 8 0 0 0 0 0 0 224 63 2176 1 170 192 34 2 816 8 'propertyPresenter' nil 1810 138 144 34 1 1874 #createAt:extent: 34 2 498 1 1 498 1109 1223 704 2002 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 42 2 0 0 99 2 0 0] 34 2 816 2464 2064 nil 27 2082 2128 1 2144 1 2160 1 2176 -49 410 ##(Smalltalk.PushButton) 34 20 nil 592 34 2 8 1149313024 1 6816 nil nil nil 7 nil nil nil 6816 nil 8 1591823792 2962 #exportLoadSpec 8 'Export Load Spec' 1 1 nil nil false nil nil nil 1810 138 144 34 3 1874 #createAt:extent: 34 2 498 809 1223 498 301 47 6816 1874 #isEnabled: 8 #(false) 6816 1874 #text: 34 1 8 'Export Load Spec' 6816 2002 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 148 1 0 0 99 2 0 0 42 2 0 0 122 2 0 0] 8 #() 2064 nil 29 2082 2144 -299 2144 1 2176 -49 2176 -3 410 ##(Smalltalk.PushButton) 34 20 nil 592 34 2 8 1149313024 1 7184 nil nil nil 7 nil nil nil 7184 nil 8 1591823792 2962 #loadLoadSpec 8 'Load Spec' 1 1 nil nil false nil nil nil 1810 138 144 34 3 1874 #createAt:extent: 34 2 498 1 1223 498 301 47 7184 1874 #isEnabled: 8 #(false) 7184 1874 #text: 34 1 8 'Load Spec' 7184 2002 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 99 2 0 0 150 0 0 0 122 2 0 0] 8 #() 2064 nil 29 2082 2128 1 2128 301 2176 -49 2176 -3 170 192 1040 nil 1810 138 144 34 1 1874 #createAt:extent: 34 2 498 1 1 498 1109 1273 592 2002 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 42 2 0 0 124 2 0 0] 34 3 704 6816 7184 2064 nil 27 2082 2128 1 2144 1 2160 1 2176 1 170 192 1040 nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1810 138 144 34 1 1874 #createAt:extent: 34 2 498 6513 21 498 1141 1351 416 2002 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 184 12 0 0 10 0 0 0 242 14 0 0 173 2 0 0] 34 1 592 2064 nil 27 )!

showOnSession: aGciSession
	| editor |
	editor := self new gciSession: aGciSession.
	^editor editLoadSpecFromFile! !
!JadeiteLoadSpecEditor class categoriesForMethods!
editLoadSpecFromFile!instance creation!public! !
resource_Default_view!public!resources-views! !
showOnSession:!public! !
!

