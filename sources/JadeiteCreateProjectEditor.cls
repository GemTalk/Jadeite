"Filed out from Dolphin Smallalk"!

JadeShell subclass: #JadeiteCreateProjectEditor
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteCreateProjectEditor guid: (GUID fromString: '{64fcb4ce-125b-491a-8157-0daff3885fc0}')!
JadeiteCreateProjectEditor comment: ''!
!JadeiteCreateProjectEditor categoriesForClass!Unclassified! !
!JadeiteCreateProjectEditor methodsFor!

cancel
	self view close!

createProject
	self primaryPresenter createProject
!

presenterClass
	^JadeiteCreateProjectPresenter!

updateCaption
	self caption: (gciSession titleBarFor: 'Create Project Editor')! !
!JadeiteCreateProjectEditor categoriesForMethods!
cancel!public! !
createProject!public! !
presenterClass!public! !
updateCaption!public! !
!

!JadeiteCreateProjectEditor class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default nil 37 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.EditableListView) 34 55 nil 416 34 2 8 1140920397 1025 560 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 nil nil nil 560 nil 8 1595822304 ##(Smalltalk.BasicListAbstract) nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil 328198 ##(Smalltalk.Point) 65 65 nil nil 138 144 34 2 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Property' 487 #left 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.SortedCollection) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 928 8 'doIt' 8 '[:array | array first]' 8 #[30 105 226 0 106] #first 944 7 257 nil nil 560 nil 3 nil nil false nil nil nil nil nil nil nil nil nil nil 834 8 'Value' 485 #left 882 #displayString 672 882 #<= 8 #() 930 0 nil 962 2 1 928 8 'doIt' 8 '[:array | array last]' 8 #[30 105 226 0 106] #last 1120 7 257 nil nil 560 nil 3 nil nil true 930 0 nil 962 1 83886081 928 8 'doIt' 8 '[:property :value | property at: 2 put: value]' 8 #[29 105 17 64 18 149 106] 1200 7 513 nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 1296 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 480 nil 5 nil nil nil 1296 nil nil nil 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 770 1 1 770 979 643 560 1474 #text: 34 1 8 'Property' 560 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 233 1 0 0 65 1 0 0] 8 #() 770 193 193 nil 33 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 1714 #fixedParentRight 1 1714 #fixedParentTop 1 1714 #fixedParentBottom -79 410 ##(Smalltalk.PushButton) 34 20 nil 416 34 2 8 1140924416 1 1792 nil nil nil 7 nil nil nil 1792 nil 8 1595887024 1180998 4 ##(Smalltalk.CommandDescription) #createProject 8 'Create' 1 1 nil nil true nil nil nil 1410 138 144 34 2 1474 #createAt:extent: 34 2 770 311 651 770 141 51 1792 1474 #text: 34 1 8 'Create' 1792 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 155 0 0 0 69 1 0 0 225 0 0 0 94 1 0 0] 8 #() 1664 nil 29 1682 1728 311 1714 #fixedViewLeft 141 1760 651 1714 #fixedViewTop 51 410 ##(Smalltalk.PushButton) 34 20 nil 416 34 2 8 1140924416 1 2176 nil nil nil 7 nil nil nil 2176 nil 8 1595887024 1874 #cancel 8 '&Cancel' 1 1 nil nil false nil nil nil 1410 138 144 34 2 1474 #createAt:extent: 34 2 770 501 651 770 141 51 2176 1474 #text: 34 1 8 '&Cancel' 2176 1602 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 250 0 0 0 69 1 0 0 64 1 0 0 94 1 0 0] 8 #() 1664 nil 29 1682 1728 501 2144 141 1760 651 2160 51 170 192 34 2 560 8 'propertyList' nil nil nil nil nil 81363 nil nil nil nil 1 nil nil 1410 138 144 34 1 1474 #createAt:extent: 34 2 770 7515 21 770 1011 801 416 1602 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 173 14 0 0 10 0 0 0 166 16 0 0 154 1 0 0] 34 3 560 1792 2176 1664 nil 27 )!

showOnSession: aGciSession
	| inst |
	inst := super showOnSession: aGciSession.
	inst primaryPresenter initializeValues.
	^inst! !
!JadeiteCreateProjectEditor class categoriesForMethods!
resource_Default_view!public!resources-views! !
showOnSession:!instance creation!public! !
!

