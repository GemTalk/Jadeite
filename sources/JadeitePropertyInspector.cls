"Filed out from Dolphin Smalltalk 7"!

PropertyInspector subclass: #JadeitePropertyInspector
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeitePropertyInspector guid: (GUID fromString: '{582e43fa-62ce-4926-9ca8-1a7fe1e6916d}')!
JadeitePropertyInspector comment: ''!
!JadeitePropertyInspector categoriesForClass!MVP-Resources-IDE Tools! !
!JadeitePropertyInspector methodsFor!

editAspect
	^self inplaceEditAspect!

inplaceEditAspect
	"using renameVariable: aStVariableNode operation: operationBlock validationBlock: validationBlock "

	| name editor style font |
	name := aspectPresenter value.
	editor := JadeiteInplaceTextEditor createOn: name asValue.
	editor validationBlock: 
			[:value |
			
			[editor model value: (Compiler evaluate: value).
			true] on: Error do: [:ex | false]	"for now"].
	editor textRectangle: self selectedAspectValueRect.
	style := JadeiteScintillaView new styleAt: 1.
	font := style fontName ifNil: [self view actualFont copy] ifNotNil: [:face | Font name: face].
	style restyleFont: font.
	editor font: font.
	editor showModal.
	(editor model value isKindOf: Boolean)
		ifTrue: [self aspectAccessor aspectDescriptor beImmediateActionIsEdit]
		ifFalse: [self aspectAccessor aspectDescriptor immediateActionBlock: nil ].
	aspectPresenter value: editor model value!

onAspectActioned
	"Event handler for an action being performed on the current aspect, i.e. Enter or double-click"

	self aspectAccessor canImmediateAction
		ifTrue: [^self aspectAccessor immediateActionUsing: aspectPresenter].
	^self inplaceEditAspect!

selectedAspectValueRect
	"Private - Answer a screen rectangle bounding the value area of the selected aspect 
	Don't map for the benefit of the InplaceTextEditor"

	| aspectListView |
	aspectListView := aspectTreePresenter view.
	^aspectListView subItemRectRow: aspectListView selectionByIndex column: 2! !
!JadeitePropertyInspector categoriesFor: #editAspect!event handling!private! !
!JadeitePropertyInspector categoriesFor: #inplaceEditAspect!operations!public! !
!JadeitePropertyInspector categoriesFor: #onAspectActioned!event handling!private! !
!JadeitePropertyInspector categoriesFor: #selectedAspectValueRect!private! !

!JadeitePropertyInspector class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil nil 5 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 138 ##(Smalltalk.Dictionary) 34 1 721414 ##(Smalltalk.Association) 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 576 nil nil nil 517 nil nil nil 1510470 1 ##(Smalltalk.DraggableViewInteractor) 576 nil 1 #left nil nil nil 328198 ##(Smalltalk.Point) 1 1 674 9 9 nil 688 nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 674 1 85 674 731 11 576 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 42 0 0 0 109 1 0 0 47 0 0 0] 8 #() 674 193 193 nil 27 1 true 170 192 34 2 410 ##(Smalltalk.ListTreeView) 34 44 nil 416 34 2 8 1140953421 1 976 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 196934 1 ##(Smalltalk.RGB) 26337781 nil 13 265030 4 ##(Smalltalk.Menu) nil true 34 12 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #inspectIt 8 '&Inspect' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'BasicInspector.ico' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil nil nil 1218 1 1250 #inspectReferences 8 'Inspect &References' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 1218 1 1250 #browseIt 8 '&Browse It' 1 1 1298 nil true 1344 8 'ClassBrowserShell.ico' 1392 nil nil 1474 4097 1218 1 1250 #copyAspect 8 '&Copy' 1 1 nil nil nil 1218 1 1250 #pasteAspect 8 '&Paste <1d>' 1 1 nil nil nil 1474 4097 1218 1 1250 #editAspect 8 '&Edit' 1 1 nil nil nil 1218 1 1250 #nilAspect 8 'Set to &Nil' 1 1 nil nil nil 1474 4097 1218 1 1250 #refresh 8 'Re&fresh' 1 1 nil nil nil 8 '&Workspace' nil 134217729 nil nil nil nil nil nil nil 976 nil 8 1650059376 459270 ##(Smalltalk.Message) #valueText 8 #() nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 3 920646 5 ##(Smalltalk.ListViewColumn) 8 'Property' 347 #left 1906 #valueNameOnly 8 #() 1906 #<= 8 #() nil nil 976 nil 3 1906 #valueNameInfo 8 #() nil 2018 8 'Value' 345 #left 1906 #valueTextOnly 8 #() 1906 #<= 2112 nil nil 976 1906 #valueImage 8 #() 3 nil nil 2018 8 '' 33 #center nil 1906 #<= 8 #() nil nil 976 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 3 1 2336 8 'doIt' 8 '[:x | PropertyInspector editButtonImageIndexFor: x ]' 8 #[31 105 29 17 177 106] ##(Smalltalk.PropertyInspector) #editButtonImageIndexFor: 2352 7 257 nil 1 nil nil #report 1088 nil 131431 674 129 129 34 4 nil nil 674 1 1 nil false 1050438 3 ##(Smalltalk.VirtualTreeModel) nil 1120 138 144 1088 nil nil 2338 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 2496 #defaultHasChildrenBlock 508791331 8 #[252 1 0 0 1 4 0 65 176 159 106 105] #childrenOf: #notEmpty 17 257 2512 2338 0 nil 2562 1 83886083 2496 #defaultFilterBlock 508773827 8 #[29 105 17 157 106] 2608 7 257 nil nil 138 ##(Smalltalk.PluggableSet) 1088 138 ##(Smalltalk.IdentitySet) 1088 13 1 nil nil nil nil nil nil nil 722 138 144 34 3 786 #createAt:extent: 34 2 674 1 1 674 731 341 976 786 #contextMenu: 34 1 1184 976 786 #text: 34 1 8 'Property' 976 866 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 109 1 0 0 170 0 0 0] 8 #() 928 nil 2021 8 'aspects' nil 722 138 144 34 1 786 #createAt:extent: 34 2 674 2879 21 674 731 341 416 866 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 159 5 0 0 10 0 0 0 12 7 0 0 180 0 0 0] 34 2 576 976 928 nil 27 )! !
!JadeitePropertyInspector class categoriesFor: #resource_Default_view!public!resources-views! !

