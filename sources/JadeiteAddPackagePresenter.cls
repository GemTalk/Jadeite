"Filed out from Dolphin Smallalk"!

JadePresenter subclass: #JadeiteAddPackagePresenter
	instanceVariableNames: 'packageName symbolDictionaryName componentName'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteAddPackagePresenter guid: (GUID fromString: '{64f74889-ab69-43e4-a5e5-7e333491a13e}')!
JadeiteAddPackagePresenter comment: ''!
!JadeiteAddPackagePresenter categoriesForClass!Unclassified! !
!JadeiteAddPackagePresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil 327686 ##(Smalltalk.Color) #default nil 5 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 576 nil nil nil 5 nil nil nil 576 514 170 176 34 12 410 ##(Smalltalk.TextEdit) 34 16 nil 576 34 2 8 1140916352 1025 688 nil 496 nil 5 nil nil nil 688 nil 8 1728982448 852486 ##(Smalltalk.NullConverter) nil nil 1 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 328198 ##(Smalltalk.Point) 311 11 914 449 61 688 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 155 0 0 0 5 0 0 0 123 1 0 0 35 0 0 0] 8 #() 914 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 311 1074 #fixedViewLeft 449 1074 #fixedParentTop 11 1074 #fixedViewTop 61 410 ##(Smalltalk.ComboBox) 34 17 nil 576 34 2 8 1412498946 1025 1152 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 496 nil 5 nil nil nil 1152 nil 8 1728782432 459270 ##(Smalltalk.Message) #displayString 8 #() 8 #() 401 802 138 144 34 1 866 #createAt:extent: 34 2 914 311 111 914 449 51 1152 962 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 155 0 0 0 55 0 0 0 123 1 0 0 80 0 0 0] 8 #() 1024 nil 27 1042 1088 311 1104 449 1120 111 1136 51 410 ##(Smalltalk.StaticText) 34 16 nil 576 34 2 8 1140850944 65 1568 nil nil nil 5 nil nil nil 1568 nil 8 1728838848 770 nil nil nil 802 138 144 34 2 866 #createAt:extent: 34 2 914 21 201 914 231 51 1568 866 #text: 34 1 8 'Symbol Dictionary:
' 1568 962 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 10 0 0 0 100 0 0 0 125 0 0 0 125 0 0 0] 8 #() 1024 nil 27 1042 1088 21 1104 231 1120 201 1136 51 410 ##(Smalltalk.StaticText) 34 16 nil 576 34 2 8 1140850944 65 1888 nil nil nil 5 nil nil nil 1888 nil 8 1728838848 770 nil nil nil 802 138 144 34 2 866 #createAt:extent: 34 2 914 21 111 914 221 71 1888 866 #text: 34 1 8 'Component:


' 1888 962 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 10 0 0 0 55 0 0 0 120 0 0 0 90 0 0 0] 8 #() 1024 nil 27 1042 1088 21 1104 221 1120 111 1136 71 410 ##(Smalltalk.ComboBox) 34 17 nil 576 34 2 8 1412498946 1025 2208 1218 138 144 1264 nil 1296 496 nil 5 nil nil nil 2208 nil 8 1728782432 1330 #displayString 1360 1376 401 802 138 144 34 1 866 #createAt:extent: 34 2 914 311 201 914 451 51 2208 962 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 155 0 0 0 100 0 0 0 124 1 0 0 125 0 0 0] 8 #() 1024 nil 27 1042 1088 311 1104 451 1120 201 1136 51 410 ##(Smalltalk.StaticText) 34 16 nil 576 34 2 8 1140850944 65 2512 nil nil nil 5 nil nil nil 2512 nil 8 1728838848 770 nil nil nil 802 138 144 34 2 866 #createAt:extent: 34 2 914 21 11 914 221 61 2512 866 #text: 34 1 8 'New Package:
' 2512 962 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 10 0 0 0 5 0 0 0 120 0 0 0 35 0 0 0] 8 #() 1024 nil 27 1042 1088 21 1104 221 1120 11 1136 61 170 192 34 6 1152 8 'componentPresenter' 2208 8 'symbolDictionaryPresenter' 688 8 'newPackagePresenter' nil 802 138 144 34 1 866 #createAt:extent: 34 2 914 1 1 914 781 361 576 962 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 134 1 0 0 180 0 0 0] 34 6 2512 688 1888 1152 1568 2208 1024 nil 27 1042 1088 1 1074 #fixedParentRight 1 1120 1 1120 361 410 ##(Smalltalk.PushButton) 34 20 nil 416 34 2 8 1149313024 1 3104 nil nil nil 5 nil nil nil 3104 nil 8 1728990640 1180998 4 ##(Smalltalk.CommandDescription) nil 8 'Add Package' 1 1 nil nil false nil nil nil 802 138 144 34 2 866 #createAt:extent: 34 2 914 231 381 914 291 51 3104 866 #text: 34 1 8 'Add Package' 3104 962 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 115 0 0 0 190 0 0 0 4 1 0 0 215 0 0 0] 8 #() 1024 nil 29 1042 1088 231 1104 291 1120 381 1074 #fixedParentBottom -69 170 192 1264 nil 802 138 144 34 1 866 #createAt:extent: 34 2 914 6859 21 914 781 501 416 962 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 101 13 0 0 10 0 0 0 235 14 0 0 4 1 0 0] 34 2 576 3104 1024 nil 27 )! !
!JadeiteAddPackagePresenter class categoriesForMethods!
resource_Default_view!public!resources-views! !
!

