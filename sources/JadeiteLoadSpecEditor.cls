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

createSchematicWiring
	super createSchematicWiring.
	self
		when: #closeRequested:
		send: #onCloseRequested:
		to: myPresenter!

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
createSchematicWiring!initialization!public! !
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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1141 1351 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 592 nil nil nil 7 nil nil nil 592 530 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 592 34 2 8 1140850688 131073 704 nil nil nil 7 nil nil nil 704 530 170 176 34 4 410 ##(Smalltalk.PushButton) 34 20 nil 704 34 2 8 1149313024 1 816 nil nil nil 7 nil nil nil 816 nil 8 1591823792 1180998 4 ##(Smalltalk.CommandDescription) #exportLoadSpec 8 'Export' 1 1 nil nil false nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 367 1 498 301 47 816 1010 #isEnabled: 8 #(false) 816 1010 #text: 34 1 8 'Export' 816 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 183 0 0 0 0 0 0 0 77 1 0 0 23 0 0 0] 8 #() 498 193 193 nil 29 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentRight -299 1296 1 1282 #fixedParentTop 1 1282 #fixedParentBottom 1 410 ##(Smalltalk.PushButton) 34 20 nil 704 34 2 8 1149313024 1 1344 nil nil nil 7 nil nil nil 1344 nil 8 1591823792 898 #loadLoadSpec 8 'Load' 1 1 nil nil false nil nil nil 946 138 144 34 3 1010 #createAt:extent: 34 2 498 1 1 498 301 47 1344 1010 #isEnabled: 8 #(false) 1344 1010 #text: 34 1 8 'Load' 1344 1170 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 150 0 0 0 23 0 0 0] 8 #() 1232 nil 29 1250 1282 #fixedParentLeft 1 1712 301 1312 1 1328 1 170 192 8 #() nil 946 138 144 34 1 1010 #createAt:extent: 34 2 498 221 1223 498 667 47 704 1170 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 110 0 0 0 99 2 0 0 187 1 0 0 122 2 0 0] 34 2 816 1344 1232 nil 27 1250 1282 #relativeParentWidth 524806 ##(Smalltalk.Fraction) 3 11 1936 1954 9 11 1328 -49 1328 -3 410 ##(Smalltalk.ContainerView) 34 15 nil 592 34 2 8 1140850688 131073 2000 nil nil nil 7 nil nil nil 2000 530 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 2000 34 2 8 1140850688 131073 2112 nil 480 nil 7 nil nil nil 2112 530 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 2112 34 2 8 1409286144 131073 2224 nil 480 nil 7 nil nil nil 2224 656710 1 ##(Smalltalk.CardLayout) 138 144 34 3 721414 ##(Smalltalk.Association) 8 'Conditional Attributes' 410 ##(Smalltalk.EditableListView) 34 55 nil 2224 34 2 8 1140969549 1025 2400 590662 2 ##(Smalltalk.ListModel) 138 144 1744 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 2 984134 2 ##(Smalltalk.CommandMenuItem) 1 898 #addConditionalAttribute 8 'Add Conditional Attribute' 1 1 nil nil nil 2626 1 898 #removeConditionalAttribute 8 'Delete Conditional Attribute' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 2400 nil 8 1591759072 ##(Smalltalk.BasicListAbstract) nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil 498 65 65 nil nil 138 144 34 1 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Column 1' 1085 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 1 83886081 2896 8 'doIt' 8 '[:assoc | assoc value]' 8 #[29 105 17 142 106] 2912 7 257 nil nil 2400 nil 3 nil nil true 2898 0 nil 2930 1 83886081 2896 8 'doIt' 8 '[:assoc :new  | assoc value: new ]' 8 #[29 105 233 1 143 106] 3008 7 513 nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 3104 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 3104 nil nil 852486 ##(Smalltalk.NullConverter) nil 8 '' 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 946 138 144 34 3 1010 #createAt:extent: 34 2 498 9 53 498 1093 553 2400 1010 #contextMenu: 34 1 2592 2400 1010 #text: 34 1 8 'Column 1' 2400 1170 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 38 2 0 0 46 1 0 0] 8 #() 1232 nil 33 2354 8 'Platform Properties' 410 ##(Smalltalk.EditableListView) 34 55 nil 2224 34 2 8 1140936781 1025 3536 2466 138 144 1744 nil 2528 2546 26337781 nil 5 nil nil nil 3536 nil 8 1591759072 ##(Smalltalk.BasicListAbstract) nil 2784 nil nil nil 498 65 65 nil nil 138 144 34 2 2850 8 '' 543 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 2898 0 nil 2930 2 1 2896 8 'doIt' 8 '[:assoc | assoc key ]' 8 #[30 105 226 0 106] #key 3744 7 257 nil nil 3536 nil 3 nil nil false nil 3090 nil nil 8 #(67174528 0) 3824 3138 nil false 3184 nil nil nil 5 nil nil nil 3824 nil nil 3202 nil 8 '' 1 nil nil nil nil nil nil nil nil nil 2850 8 '' 543 #left 459270 ##(Smalltalk.Message) #displayString 8 #() 3938 #<= 3968 2898 0 nil 2930 1 83886081 2896 8 'doIt' 8 '[:assoc | assoc value ]' 8 #[29 105 17 142 106] 4000 7 257 nil nil 3536 nil 3 nil nil true 2898 0 nil 2930 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:assoc :value | assoc value: value]' 8 #[29 105 233 1 143 106] 4080 7 513 nil 3090 nil nil 8 #(67174528 0) 4160 3138 nil false 3184 nil 480 nil 5 nil nil nil 4160 nil nil nil 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 946 138 144 34 1 1010 #createAt:extent: 34 2 498 9 53 498 1093 553 3536 1170 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 38 2 0 0 46 1 0 0] 8 #() 1232 nil 33 2354 8 'Comment' 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 2224 34 2 8 1174474756 1025 4416 3138 nil false 3184 nil 2546 26337781 nil 7 nil nil nil 4416 nil 8 1669086696 3202 nil nil 9 1574932833 170 192 34 8 #normal 1182790 1 ##(Smalltalk.ScintillaTextStyle) 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 1379398 1 ##(Smalltalk.ScintillaCallTipStyle) 77 466 #tooltipText 466 #tooltip 1 nil nil nil nil #callTip nil nil nil #lineNumber 4578 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #indentGuide 4578 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) nil nil nil nil 4416 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1744 nil 170 176 1744 nil nil nil nil nil 466 #silver nil nil nil nil nil nil nil 1 170 192 1744 nil nil nil nil 208 nil nil nil nil 170 192 34 6 #Error 4578 3 466 #firebrick 466 #floralWhite 1 nil nil nil nil #Error nil nil nil #Warning 4578 5 466 #darkGoldenrod 466 #ivory 1 nil nil nil nil #Warning nil nil nil #Notification 4578 7 nil 466 #gainsboro 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 946 138 144 34 7 1010 #createAt:extent: 34 2 498 9 53 498 1093 553 4416 1010 #caretPeriod: 8 #(530) 4416 1010 #wordWrap: 8 #(true) 4416 1010 #margins: 34 1 34 5 985158 3 ##(Smalltalk.ScintillaMargin) 1 4416 1 3 nil nil nil nil 5250 3 4416 33 nil nil 67108863 nil nil 5250 5 4416 1 nil nil nil nil nil 5250 7 4416 1 nil nil nil nil nil 5250 9 4416 1 nil nil nil nil nil 4416 1010 #targetRange: 34 1 525062 ##(Smalltalk.Interval) 1 -1 3 4416 1010 #maxCompletionListHeight: 8 #(9) 4416 1010 #edgeColumn: 8 #(1) 4416 1170 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 38 2 0 0 46 1 0 0] 8 #() 1232 nil 33 4416 nil nil nil 170 192 34 6 3536 8 'platformPropertiesPresenter' 4416 8 'commentPresenter' 2400 8 'conditionalAttributesPresenter' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 2224 34 2 8 1140916736 1 5600 2466 138 144 34 3 4400 2384 3520 nil 2528 nil nil 1 nil nil nil 5600 nil 8 1591529216 2898 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 5728 7 257 nil 2898 0 nil 5746 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 5792 7 257 nil 2784 nil nil nil nil nil #noIcons nil nil nil nil nil 946 138 144 34 3 1010 #createAt:extent: 34 2 498 1 1 498 1109 613 5600 1010 #setSingleSelection: 8 #(1) 5600 1010 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 5600 1170 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 42 2 0 0 50 1 0 0] 8 #() 1232 nil 27 946 138 144 34 1 1010 #createAt:extent: 34 2 498 1 1 498 1109 613 2224 1170 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 42 2 0 0 50 1 0 0] 34 4 4416 2400 3536 5600 1232 nil 27 1250 1712 1 1296 1 1312 1 1328 1 170 192 1744 nil 946 138 144 34 1 1010 #createAt:extent: 34 2 498 1 611 498 1109 613 2112 1170 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 49 1 0 0 42 2 0 0 99 2 0 0] 34 1 2224 1232 nil 27 1250 1712 1 1296 1 1282 #relativeParentHeight 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 224 63 1328 1 410 ##(Smalltalk.ContainerView) 34 15 nil 2000 34 2 8 1409286144 131073 6480 nil 480 nil 7 nil nil nil 6480 530 170 176 34 2 410 ##(Smalltalk.EditableListView) 34 55 nil 6480 34 2 8 1140953165 1025 6592 2466 138 144 1744 nil 2528 480 nil 7 nil nil nil 6592 nil 8 1591759072 ##(Smalltalk.BasicListAbstract) nil 2784 nil nil nil 498 65 65 nil nil 138 144 34 2 2850 8 'Property' 401 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 2898 0 nil 2930 2 1 2896 8 'doIt' 8 '[:array | array first]' 8 #[30 105 226 0 106] #first 6784 7 257 nil nil 6592 nil 1 nil nil false nil 3090 nil nil 8 #(67174528 0) 6864 3138 nil false 3184 nil nil nil 5 nil nil nil 6864 nil nil 3202 nil 8 '' 1 nil nil nil nil nil nil nil nil nil 2850 8 'Value' 701 #left ##(Smalltalk.BasicListAbstract) 3938 #<= 8 #() 2898 0 nil 2930 2 1 2896 8 'doIt' 8 '[:array | array last value ]' 8 #[30 105 226 0 142 106] #last 7008 7 257 nil #value 6592 nil 3 nil nil false 2898 0 nil 2930 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:array :value | array at: 2 put: value]' 8 #[29 105 17 64 18 149 106] 7088 7 513 nil 3090 nil nil 8 #(67174528 0) 7168 3138 nil false 3184 nil 480 nil 5 nil nil nil 7168 nil nil nil 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 946 138 144 34 2 1010 #createAt:extent: 34 2 498 1 1 498 1109 607 6592 1010 #text: 34 1 8 'Property' 6592 1170 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 42 2 0 0 47 1 0 0] 8 #() 1232 nil 33 1250 1712 1 1296 1 1312 1 1328 1 170 192 34 2 6592 8 'loadSpecPresenter' nil 946 138 144 34 1 1010 #createAt:extent: 34 2 498 1 5 498 1109 607 6480 1170 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 2 0 0 0 42 2 0 0 49 1 0 0] 34 1 6592 1232 nil 27 1250 1712 1 1296 1 1312 5 6432 6450 8 0 0 0 0 0 0 224 63 170 192 34 2 6480 8 'propertyPresenter' nil 946 138 144 34 1 1010 #createAt:extent: 34 2 498 1 1 498 1109 1223 2000 1170 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 42 2 0 0 99 2 0 0] 34 2 6480 2112 1232 nil 27 1250 1712 1 1296 1 1312 1 1328 -49 170 192 1744 nil 946 138 144 34 1 1010 #createAt:extent: 34 2 498 1 1 498 1109 1273 592 1170 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 42 2 0 0 124 2 0 0] 34 2 2000 704 1232 nil 27 1250 1712 1 1296 1 1312 1 1328 1 170 192 1744 nil nil nil nil nil 1 nil nil nil nil 1 nil nil 946 138 144 34 1 1010 #createAt:extent: 34 2 498 6513 21 498 1141 1351 416 1170 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 184 12 0 0 10 0 0 0 242 14 0 0 173 2 0 0] 34 1 592 1232 nil 27 )!

showOnSession: aGciSession
	| editor |
	editor := self new gciSession: aGciSession.
	^editor editLoadSpecFromFile! !
!JadeiteLoadSpecEditor class categoriesForMethods!
editLoadSpecFromFile!instance creation!public! !
resource_Default_view!public!resources-views! !
showOnSession:!public! !
!

