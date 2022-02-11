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
	^self showShell!

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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1141 1351 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 592 nil nil nil 7 nil nil nil 592 530 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 592 34 2 8 1140850688 131073 704 nil nil nil 7 nil nil nil 704 530 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 704 34 2 8 1140850688 131073 816 nil 480 nil 7 nil nil nil 816 530 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 816 34 2 8 1409286144 131073 928 nil 480 nil 7 nil nil nil 928 656710 1 ##(Smalltalk.CardLayout) 138 144 34 3 721414 ##(Smalltalk.Association) 8 'Conditional Attributes' 410 ##(Smalltalk.EditableListView) 34 55 nil 928 34 2 8 1140969549 1025 1104 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 2 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #addConditionalAttribute 8 'Add Conditional Attribute' 1 1 nil nil nil 1346 1 1378 #removeConditionalAttribute 8 'Delete Conditional Attribute' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 1104 nil 8 1591759072 ##(Smalltalk.BasicListAbstract) nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil 498 65 65 nil nil 138 144 34 1 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Column 1' 1085 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 1 83886081 1632 8 'doIt' 8 '[:assoc | assoc value]' 8 #[29 105 17 142 106] 1648 7 257 nil nil 1104 nil 3 nil nil true 1634 0 nil 1666 1 83886081 1632 8 'doIt' 8 '[:assoc :new  | assoc value: new ]' 8 #[29 105 233 1 143 106] 1744 7 513 nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 1840 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 1840 nil nil 852486 ##(Smalltalk.NullConverter) nil 8 '' 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 9 53 498 1093 553 1104 2066 #contextMenu: 34 1 1312 1104 2066 #text: 34 1 8 'Column 1' 1104 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 38 2 0 0 46 1 0 0] 8 #() 498 193 193 nil 33 1058 8 'Platform Properties' 410 ##(Smalltalk.EditableListView) 34 55 nil 928 34 2 8 1140936781 1025 2336 1170 138 144 1216 nil 1248 1266 26337781 nil 5 nil nil nil 2336 nil 8 1591759072 ##(Smalltalk.BasicListAbstract) nil 1520 nil nil nil 498 65 65 nil nil 138 144 34 2 1586 8 '' 543 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 1634 0 nil 1666 2 1 1632 8 'doIt' 8 '[:array | array first ]' 8 #[30 105 226 0 106] #first 2544 7 257 nil nil 2336 nil 3 nil nil false nil 1826 nil nil 8 #(67174528 0) 2624 1874 nil false 1920 nil nil nil 5 nil nil nil 2624 nil nil 1938 nil 8 '' 1 nil nil nil nil nil nil nil nil nil 1586 8 '' 543 #left 459270 ##(Smalltalk.Message) #displayString 8 #() 2738 #<= 2768 1634 0 nil 1666 2 1 1632 8 'doIt' 8 '[:array | array last value ]' 8 #[30 105 226 0 142 106] #last 2800 7 257 nil nil 2336 nil 3 nil nil false 1634 0 nil 1666 2 1 1632 8 'doIt' 8 '[:array :value | array last value: value]' 8 #[30 105 226 0 18 143 106] #last 2880 7 513 nil 1826 nil nil 8 #(67174528 0) 2960 1874 nil false 1920 nil 480 nil 5 nil nil nil 2960 nil nil nil 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 2002 138 144 34 1 2066 #createAt:extent: 34 2 498 9 53 498 1093 553 2336 2226 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 38 2 0 0 46 1 0 0] 8 #() 2288 nil 33 1058 8 'Comment' 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 928 34 2 8 1174474756 1025 3216 1874 nil false 1920 nil 1266 26337781 nil 7 nil nil nil 3216 nil 8 1669086696 1938 nil nil 9 1576354577 170 192 34 8 #normal 1182790 1 ##(Smalltalk.ScintillaTextStyle) 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 1379398 1 ##(Smalltalk.ScintillaCallTipStyle) 77 466 #tooltipText 466 #tooltip 1 nil nil nil nil #callTip nil nil nil #lineNumber 3378 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #indentGuide 3378 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil nil 1245510 1 ##(Smalltalk.NullScintillaStyler) #normal 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) nil nil nil nil 3216 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1216 nil 170 176 1216 nil nil nil nil nil 466 #silver nil nil nil nil nil nil nil 1 170 192 1216 nil nil nil nil 208 nil nil nil nil 170 192 34 6 #Error 3378 3 466 #firebrick 466 #floralWhite 1 nil nil nil nil #Error nil nil nil #Warning 3378 5 466 #darkGoldenrod 466 #ivory 1 nil nil nil nil #Warning nil nil nil #Notification 3378 7 nil 466 #gainsboro 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 2002 138 144 34 7 2066 #createAt:extent: 34 2 498 9 53 498 1093 553 3216 2066 #caretPeriod: 8 #(530) 3216 2066 #wordWrap: 8 #(true) 3216 2066 #margins: 34 1 34 5 985158 3 ##(Smalltalk.ScintillaMargin) 1 3216 1 3 nil nil nil nil 4050 3 3216 33 nil nil 67108863 nil nil 4050 5 3216 1 nil nil nil nil nil 4050 7 3216 1 nil nil nil nil nil 4050 9 3216 1 nil nil nil nil nil 3216 2066 #targetRange: 34 1 525062 ##(Smalltalk.Interval) 1 -1 3 3216 2066 #maxCompletionListHeight: 8 #(9) 3216 2066 #edgeColumn: 8 #(1) 3216 2226 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 38 2 0 0 46 1 0 0] 8 #() 2288 nil 33 3216 nil nil nil 170 192 34 6 2336 8 'platformPropertiesPresenter' 3216 8 'commentPresenter' 1104 8 'conditionalAttributesPresenter' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 928 34 2 8 1140916736 1 4400 1170 138 144 34 3 3200 1088 2320 nil 1248 nil nil 1 nil nil nil 4400 nil 8 1591529216 1634 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 4528 7 257 nil 1634 0 nil 4546 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 4592 7 257 nil 1520 nil nil nil nil nil #noIcons nil nil nil nil nil 2002 138 144 34 3 2066 #createAt:extent: 34 2 498 1 1 498 1109 613 4400 2066 #setSingleSelection: 8 #(1) 4400 2066 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 4400 2226 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 42 2 0 0 50 1 0 0] 8 #() 2288 nil 27 2002 138 144 34 1 2066 #createAt:extent: 34 2 498 1 1 498 1109 613 928 2226 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 42 2 0 0 50 1 0 0] 34 4 3216 1104 2336 4400 2288 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 5058 #fixedParentRight 1 5058 #fixedParentTop 1 5058 #fixedParentBottom 1 170 192 1216 nil 2002 138 144 34 1 2066 #createAt:extent: 34 2 498 1 611 498 1109 613 816 2226 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 49 1 0 0 42 2 0 0 99 2 0 0] 34 1 928 2288 nil 27 5026 5072 1 5088 1 5058 #relativeParentHeight 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 224 63 5120 1 410 ##(Smalltalk.ContainerView) 34 15 nil 704 34 2 8 1409286144 131073 5376 nil 480 nil 7 nil nil nil 5376 530 170 176 34 2 410 ##(Smalltalk.EditableListView) 34 55 nil 5376 34 2 8 1140953165 1025 5488 1170 138 144 1216 nil 1248 480 nil 7 nil nil nil 5488 nil 8 1591759072 ##(Smalltalk.BasicListAbstract) nil 1520 nil nil nil 498 65 65 nil nil 138 144 34 2 1586 8 'Property' 401 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 1634 0 nil 1666 2 1 1632 8 'doIt' 8 '[:array | array first]' 8 #[30 105 226 0 106] #first 5680 7 257 nil nil 5488 nil 1 nil nil false nil 1826 nil nil 8 #(67174528 0) 5760 1874 nil false 1920 nil nil nil 5 nil nil nil 5760 nil nil 1938 nil 8 '' 1 nil nil nil nil nil nil nil nil nil 1586 8 'Value' 701 #left ##(Smalltalk.BasicListAbstract) 2738 #<= 8 #() 1634 0 nil 1666 2 1 1632 8 'doIt' 8 '[:array | array last value ]' 8 #[30 105 226 0 142 106] #last 5904 7 257 nil #value 5488 nil 3 nil nil false 1634 0 nil 1666 1 83886081 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:array :value | array at: 2 put: value]' 8 #[29 105 17 64 18 149 106] 5984 7 513 nil 1826 nil nil 8 #(67174528 0) 6064 1874 nil false 1920 nil 480 nil 5 nil nil nil 6064 nil nil nil 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 2002 138 144 34 2 2066 #createAt:extent: 34 2 498 1 1 498 1109 607 5488 2066 #text: 34 1 8 'Property' 5488 2226 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 42 2 0 0 47 1 0 0] 8 #() 2288 nil 33 5026 5072 1 5088 1 5104 1 5120 1 170 192 34 2 5488 8 'loadSpecPresenter' nil 2002 138 144 34 1 2066 #createAt:extent: 34 2 498 1 5 498 1109 607 5376 2226 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 2 0 0 0 42 2 0 0 49 1 0 0] 34 1 5488 2288 nil 27 5026 5072 1 5088 1 5104 5 5328 5346 8 0 0 0 0 0 0 224 63 170 192 34 2 5376 8 'propertyPresenter' nil 2002 138 144 34 1 2066 #createAt:extent: 34 2 498 1 1 498 1109 1223 704 2226 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 42 2 0 0 99 2 0 0] 34 2 5376 816 2288 nil 27 5026 5072 1 5088 1 5104 1 5120 -49 410 ##(Smalltalk.ContainerView) 34 15 nil 592 34 2 8 1140850688 131073 6816 nil nil nil 7 nil nil nil 6816 530 170 176 34 4 410 ##(Smalltalk.PushButton) 34 20 nil 6816 34 2 8 1149313024 1 6928 nil nil nil 7 nil nil nil 6928 nil 8 1591823792 1378 #loadLoadSpec 8 'Load' 1 1 nil nil false nil nil nil 2002 138 144 34 3 2066 #createAt:extent: 34 2 498 1 1 498 301 47 6928 2066 #isEnabled: 8 #(false) 6928 2066 #text: 34 1 8 'Load' 6928 2226 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 150 0 0 0 23 0 0 0] 8 #() 2288 nil 29 5026 5072 1 5072 301 5104 1 5120 1 410 ##(Smalltalk.PushButton) 34 20 nil 6816 34 2 8 1149313024 1 7296 nil nil nil 7 nil nil nil 7296 nil 8 1591823792 1378 #exportLoadSpec 8 'Export' 1 1 nil nil false nil nil nil 2002 138 144 34 3 2066 #createAt:extent: 34 2 498 367 1 498 301 47 7296 2066 #isEnabled: 8 #(false) 7296 2066 #text: 34 1 8 'Export' 7296 2226 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 183 0 0 0 0 0 0 0 77 1 0 0 23 0 0 0] 8 #() 2288 nil 29 5026 5088 -299 5088 1 5104 1 5120 1 170 192 1216 nil 2002 138 144 34 1 2066 #createAt:extent: 34 2 498 221 1223 498 667 47 6816 2226 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 110 0 0 0 99 2 0 0 187 1 0 0 122 2 0 0] 34 2 7296 6928 2288 nil 27 5026 5058 #relativeParentWidth 524806 ##(Smalltalk.Fraction) 3 11 7856 7874 9 11 5120 -49 5120 -3 170 192 1216 nil 2002 138 144 34 1 2066 #createAt:extent: 34 2 498 1 1 498 1109 1273 592 2226 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 42 2 0 0 124 2 0 0] 34 2 704 6816 2288 nil 27 5026 5072 1 5088 1 5104 1 5120 1 170 192 1216 nil nil nil nil nil 1 nil nil nil nil 1 nil nil 2002 138 144 34 1 2066 #createAt:extent: 34 2 498 6513 21 498 1141 1351 416 2226 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 184 12 0 0 10 0 0 0 242 14 0 0 173 2 0 0] 34 1 592 2288 nil 27 )!

showOnSession: aGciSession
	| editor |
	editor := self new gciSession: aGciSession.
	^editor editLoadSpecFromFile! !
!JadeiteLoadSpecEditor class categoriesForMethods!
editLoadSpecFromFile!instance creation!public! !
resource_Default_view!public!resources-views! !
showOnSession:!public! !
!

