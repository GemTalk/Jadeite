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
	"path := FileOpenDialog new showModal ifNil: [^self]."  "would like a server file browser someday" 
	path := '/uffda2/users/ewinger/shared/repos/RowanSample9/rowan/specs/spec_0061.ston'.
	self createView: self class defaultView.
	model := (RowanSpecificationService new loadSpecPath: path) editInSession: gciSession
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
	model := RowanSpecificationService new editInSession: gciSession window: self view handle value.
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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default nil 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 560 nil nil nil 7 nil nil nil 560 498 170 176 34 4 410 ##(Smalltalk.PushButton) 34 20 nil 560 34 2 8 1149313024 1 672 nil nil nil 7 nil nil nil 672 nil 8 1678265776 1180998 4 ##(Smalltalk.CommandDescription) #exportLoadSpec 8 'Export Load Spec' 1 1 nil nil false nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 328198 ##(Smalltalk.Point) 1199 1403 914 301 47 672 866 #isEnabled: 8 #(false) 672 866 #text: 34 1 8 'Export Load Spec' 672 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 87 2 0 0 189 2 0 0 237 2 0 0 212 2 0 0] 8 #() 914 193 193 nil 29 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentRight -299 1168 1 1154 #fixedParentBottom -49 1184 -3 410 ##(Smalltalk.ContainerView) 34 15 nil 560 34 2 8 1140850688 131073 1200 nil nil nil 7 nil nil nil 1200 498 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 1200 34 2 8 1140850688 131073 1312 nil 480 nil 7 nil nil nil 1312 498 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 1312 34 2 8 1409286144 131073 1424 nil 480 nil 7 nil nil nil 1424 656710 1 ##(Smalltalk.CardLayout) 138 144 34 3 721414 ##(Smalltalk.Association) 8 'Conditional Attributes' 410 ##(Smalltalk.EditableListView) 34 55 nil 1424 34 2 8 1140969549 1025 1600 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 2 984134 2 ##(Smalltalk.CommandMenuItem) 1 754 #addConditionalAttribute 8 'Add Conditional Attribute' 1 1 nil nil nil 1842 1 754 #removeConditionalAttribute 8 'Delete Conditional Attribute' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 1600 nil 8 1678201056 ##(Smalltalk.BasicListAbstract) nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil 914 65 65 nil nil 138 144 34 1 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Column 1' 1475 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 1 83886081 2112 8 'doIt' 8 '[:assoc | assoc value]' 8 #[29 105 17 142 106] 2128 7 257 nil nil 1600 nil 3 nil nil true 2114 0 nil 2146 1 83886081 2112 8 'doIt' 8 '[:assoc :new  | assoc value: new ]' 8 #[29 105 233 1 143 106] 2224 7 513 nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 2320 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 2320 nil nil 852486 ##(Smalltalk.NullConverter) nil 8 '' 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 802 138 144 34 3 866 #createAt:extent: 34 2 914 9 53 914 1483 643 1600 866 #contextMenu: 34 1 1808 1600 866 #text: 34 1 8 'Column 1' 1600 1042 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 233 2 0 0 91 1 0 0] 8 #() 1104 nil 33 1554 8 'Platform Properties' 410 ##(Smalltalk.EditableListView) 34 55 nil 1424 34 2 8 1140936781 1025 2752 1666 138 144 1712 nil 1744 1762 26337781 nil 5 nil nil nil 2752 nil 8 1678201056 ##(Smalltalk.BasicListAbstract) nil 2000 nil nil nil 914 65 65 nil nil 138 144 34 2 2066 8 '' 739 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 2114 0 nil 2146 2 1 2112 8 'doIt' 8 '[:assoc | assoc key ]' 8 #[30 105 226 0 106] #key 2960 7 257 nil nil 2752 nil 3 nil nil false nil 2306 nil nil 8 #(67174528 0) 3040 2354 nil false 2400 nil nil nil 5 nil nil nil 3040 nil nil 2418 nil 8 '' 1 nil nil nil nil nil nil nil nil nil 2066 8 '' 737 #left 459270 ##(Smalltalk.Message) #displayString 8 #() 3154 #<= 3184 2114 0 nil 2146 1 83886081 2112 8 'doIt' 8 '[:assoc | assoc value ]' 8 #[29 105 17 142 106] 3216 7 257 nil nil 2752 nil 3 nil nil true 2114 0 nil 2146 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:assoc :value | assoc value: value]' 8 #[29 105 233 1 143 106] 3296 7 513 nil 2306 nil nil 8 #(67174528 0) 3376 2354 nil false 2400 nil 480 nil 5 nil nil nil 3376 nil nil nil 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 802 138 144 34 1 866 #createAt:extent: 34 2 914 9 53 914 1483 643 2752 1042 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 233 2 0 0 91 1 0 0] 8 #() 1104 nil 33 1554 8 'Comment' 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 1424 34 2 8 1174474756 1025 3632 2354 nil false 2400 nil 1762 26337781 nil 7 nil nil nil 3632 nil 8 1644969448 2418 nil nil 9 180944577 170 192 34 8 #normal 1182790 1 ##(Smalltalk.ScintillaTextStyle) 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 1379398 1 ##(Smalltalk.ScintillaCallTipStyle) 77 466 #tooltipText 466 #tooltip 1 nil nil nil nil #callTip nil nil nil #lineNumber 3794 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #indentGuide 3794 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) nil nil nil nil 3632 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1712 nil 170 176 1712 nil nil nil nil nil 466 #silver nil nil nil nil nil nil nil 1 170 192 1712 nil nil nil nil 208 nil nil nil nil 170 192 34 6 #Error 3794 3 466 #firebrick 466 #floralWhite 1 nil nil nil nil #Error nil nil nil #Warning 3794 5 466 #darkGoldenrod 466 #ivory 1 nil nil nil nil #Warning nil nil nil #Notification 3794 7 nil 466 #gainsboro 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 802 138 144 34 7 866 #createAt:extent: 34 2 914 9 53 914 1483 643 3632 866 #caretPeriod: 8 #(530) 3632 866 #wordWrap: 8 #(true) 3632 866 #margins: 34 1 34 5 985158 3 ##(Smalltalk.ScintillaMargin) 1 3632 1 3 nil nil nil nil 4466 3 3632 33 nil nil 67108863 nil nil 4466 5 3632 1 nil nil nil nil nil 4466 7 3632 1 nil nil nil nil nil 4466 9 3632 1 nil nil nil nil nil 3632 866 #targetRange: 34 1 525062 ##(Smalltalk.Interval) 1 -1 3 3632 866 #maxCompletionListHeight: 8 #(9) 3632 866 #edgeColumn: 8 #(1) 3632 1042 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 233 2 0 0 91 1 0 0] 8 #() 1104 nil 33 3632 nil nil nil 170 192 34 6 1600 8 'conditionalAttributesPresenter' 3632 8 'commentPresenter' 2752 8 'platformPropertiesPresenter' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 1424 34 2 8 1140916736 1 4816 1666 138 144 34 3 3616 1584 2736 nil 1744 nil nil 1 nil nil nil 4816 nil 8 1677971200 2114 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 4944 7 257 nil 2114 0 nil 4962 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 5008 7 257 nil 2000 nil nil nil nil nil #noIcons nil nil nil nil nil 802 138 144 34 3 866 #createAt:extent: 34 2 914 1 1 914 1499 703 4816 866 #setSingleSelection: 8 #(1) 4816 866 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 4816 1042 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 237 2 0 0 95 1 0 0] 8 #() 1104 nil 27 802 138 144 34 1 866 #createAt:extent: 34 2 914 1 1 914 1499 703 1424 1042 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 237 2 0 0 95 1 0 0] 34 4 3632 1600 2752 4816 1104 nil 27 1122 1154 #fixedParentLeft 1 1168 1 1154 #fixedParentTop 1 1184 1 170 192 1712 nil 802 138 144 34 1 866 #createAt:extent: 34 2 914 1 701 914 1499 703 1312 1042 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 94 1 0 0 237 2 0 0 189 2 0 0] 34 1 1424 1104 nil 27 1122 5456 1 1168 1 1154 #relativeParentHeight 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 224 63 1184 1 410 ##(Smalltalk.ContainerView) 34 15 nil 1200 34 2 8 1409286144 131073 5728 nil 480 nil 7 nil nil nil 5728 498 170 176 34 2 410 ##(Smalltalk.EditableListView) 34 55 nil 5728 34 2 8 1140953165 1025 5840 1666 138 144 1712 nil 1744 480 nil 7 nil nil nil 5840 nil 8 1678201056 ##(Smalltalk.BasicListAbstract) nil 2000 nil nil nil 914 65 65 nil nil 138 144 34 2 2066 8 'Property' 401 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 2114 0 nil 2146 2 1 2112 8 'doIt' 8 '[:array | array first]' 8 #[30 105 226 0 106] #first 6032 7 257 nil nil 5840 nil 1 nil nil false nil 2306 nil nil 8 #(67174528 0) 6112 2354 nil false 2400 nil nil nil 5 nil nil nil 6112 nil nil 2418 nil 8 '' 1 nil nil nil nil nil nil nil nil nil 2066 8 'Value' 1091 #left ##(Smalltalk.BasicListAbstract) 3154 #<= 8 #() 2114 0 nil 2146 2 1 2112 8 'doIt' 8 '[:array | array last ]' 8 #[30 105 226 0 106] #last 6256 7 257 nil nil 5840 nil 3 nil nil true 2114 0 nil 2146 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:array :value | array at: 2 put: value]' 8 #[29 105 17 64 18 149 106] 6336 7 513 nil 2306 nil nil 8 #(67174528 0) 6416 2354 nil false 2400 nil 480 nil 5 nil nil nil 6416 nil nil nil 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 802 138 144 34 2 866 #createAt:extent: 34 2 914 1 1 914 1499 697 5840 866 #text: 34 1 8 'Property' 5840 1042 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 237 2 0 0 92 1 0 0] 8 #() 1104 nil 33 1122 5456 1 1168 1 5472 1 1184 1 170 192 34 2 5840 8 'loadSpecPresenter' nil 802 138 144 34 1 866 #createAt:extent: 34 2 914 1 5 914 1499 697 5728 1042 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 2 0 0 0 237 2 0 0 94 1 0 0] 34 1 5840 1104 nil 27 1122 5456 1 1168 1 5472 5 5680 5698 8 0 0 0 0 0 0 224 63 170 192 34 2 5728 8 'propertyPresenter' nil 802 138 144 34 1 866 #createAt:extent: 34 2 914 1 1 914 1499 1403 1200 1042 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 237 2 0 0 189 2 0 0] 34 2 5728 1312 1104 nil 27 1122 5456 1 1168 1 5472 1 1184 -49 170 192 1712 nil 802 138 144 34 1 866 #createAt:extent: 34 2 914 1 1 914 1499 1453 560 1042 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 237 2 0 0 214 2 0 0] 34 2 1200 672 1104 nil 27 1122 5456 1 1168 1 5472 1 1184 1 170 192 1712 nil nil nil nil nil 1 nil nil nil nil 1 nil nil 802 138 144 34 1 866 #createAt:extent: 34 2 914 6705 21 914 1531 1531 416 1042 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 24 13 0 0 10 0 0 0 21 16 0 0 7 3 0 0] 34 1 560 1104 nil 27 )!

showOnSession: aGciSession
	| editor |
	editor := self new gciSession: aGciSession.
	^editor editLoadSpecFromFile! !
!JadeiteLoadSpecEditor class categoriesForMethods!
editLoadSpecFromFile!instance creation!public! !
resource_Default_view!public!resources-views! !
showOnSession:!public! !
!

