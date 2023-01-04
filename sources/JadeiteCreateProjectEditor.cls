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
	| canClose |
	canClose := true.
	self primaryPresenter propertiesAreChanged
		ifTrue: [canClose := MessageBox confirm: 'There are unsaved changes. Close anyway?'].
	canClose ifTrue: [self view close]!

createProject
	self primaryPresenter propertyList view refreshContents.	"force the view's model to be updated. It may not be if the default button 'Create' is activated by the <enter> key before leaving a property value field"
	self primaryPresenter createProject ifTrue: [self view close]!

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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default nil 37 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.EditableListView) 34 55 nil 416 34 2 8 1140920397 1025 560 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 nil nil nil 560 nil 8 1597395168 ##(Smalltalk.BasicListAbstract) nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil 328198 ##(Smalltalk.Point) 65 65 nil nil 138 144 34 2 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Property' 487 #left 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.SortedCollection) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 928 8 'doIt' 8 '[:array | array first]' 8 #[30 105 226 0 106] #first 944 7 257 nil nil 560 nil 3 nil nil false nil nil nil nil nil nil nil nil nil nil 834 8 'Value' 485 #left 882 #displayString 8 #() 882 #<= 8 #() 930 0 nil 962 2 1 928 8 'doIt' 8 '[:array | array last]' 8 #[30 105 226 0 106] #last 1136 7 257 nil nil 560 nil 3 nil nil true 930 0 nil 962 1 83886081 928 8 'doIt' 8 '[:property :value | property at: 2 put: value]' 8 #[29 105 17 64 18 149 106] 1216 7 513 nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 1312 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 480 nil 5 nil nil nil 1312 nil nil nil 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131171 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 770 1 1 770 979 623 560 1490 #text: 34 1 8 'Property' 560 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 233 1 0 0 55 1 0 0] 8 #() 770 193 193 nil 33 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 1730 #fixedParentRight 1 1730 #fixedParentTop 1 1730 #fixedParentBottom -99 410 ##(Smalltalk.PushButton) 34 20 nil 416 34 2 8 1140924416 1 1808 nil nil nil 7 nil nil nil 1808 nil 8 1597459888 1180998 4 ##(Smalltalk.CommandDescription) #createProject 8 'Create' 1 1 nil nil true nil nil nil 1426 138 144 34 3 1490 #createAt:extent: 34 2 770 293 663 770 149 51 1808 1490 #isEnabled: 8 #(false) 1808 1490 #text: 34 1 8 'Create' 1808 1618 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 146 0 0 0 75 1 0 0 220 0 0 0 100 1 0 0] 8 #() 1680 nil 29 1698 1730 #relativeParentWidth 327734 ##(Smalltalk.Float) 8 51 51 51 51 51 51 211 63 2192 2210 8 205 204 204 204 204 204 220 63 1792 -59 1792 -9 410 ##(Smalltalk.PushButton) 34 20 nil 416 34 2 8 1140924416 1 2256 nil nil nil 7 nil nil nil 2256 nil 8 1597459888 1890 #cancel 8 '&Cancel' 1 1 nil nil false nil nil nil 1426 138 144 34 3 1490 #createAt:extent: 34 2 770 537 663 770 149 51 2256 1490 #isEnabled: 8 #(false) 2256 1490 #text: 34 1 8 '&Cancel' 2256 1618 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 12 1 0 0 75 1 0 0 86 1 0 0 100 1 0 0] 8 #() 1680 nil 29 1698 2192 2210 8 154 153 153 153 153 153 225 63 2192 2210 8 102 102 102 102 102 102 230 63 1792 -59 1792 -9 170 192 34 2 560 8 'propertyList' nil nil nil nil nil 35543 nil nil nil nil 1 nil nil 1426 138 144 34 1 1490 #createAt:extent: 34 2 770 7087 21 770 1011 801 416 1618 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 215 13 0 0 10 0 0 0 208 15 0 0 154 1 0 0] 34 3 560 1808 2256 1680 nil 27 )!

showOnSession: aGciSession
	| inst |
	inst := super showOnSession: aGciSession.
	inst primaryPresenter initializeValues.
	^inst! !
!JadeiteCreateProjectEditor class categoriesForMethods!
resource_Default_view!public!resources-views! !
showOnSession:!instance creation!public! !
!

