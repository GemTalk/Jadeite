"Filed out from Dolphin Smalltalk 7"!

JadeiteMethodListPresenter subclass: #JadeiteRenameClassMethodListPresenter
	instanceVariableNames: 'findString newClassName'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteRenameClassMethodListPresenter guid: (GUID fromString: '{5972612c-43ba-4906-a602-6e5ae6500eed}')!
JadeiteRenameClassMethodListPresenter comment: ''!
!JadeiteRenameClassMethodListPresenter categoriesForClass!Unclassified! !
!JadeiteRenameClassMethodListPresenter methodsFor!

createComponents
	methodListPresenter := self add: JadeiteBasicRenameClassMethodListPresenter new name: 'methodList'.
	methodSourcePresenter := (self add: JadeiteMethodSourcePresenter new name: 'methodSource')
				menuTitle: '&Method Source'.
	comparisonPresenter := self add: DifferencesPresenter new name: 'comparisonTab'!

createSchematicWiring
	super createSchematicWiring.
	methodListPresenter methodListPresenter
		when: #selectionChanged
		send: #selectionChanged
		to: self!

findString: anObject
	findString := anObject!

newClassName
	^newClassName!

newClassName: anObject
	newClassName := anObject!

nextSelection
	| sourceView offset |
	sourceView := self methodSourcePresenter documentPresenter view.
	sourceView selectionRanges size > 1 ifTrue: [^self resetAndFindFirstIn: sourceView].
	self methodSourcePresenter documentPresenter view setFocus.
	offset := sourceView findString: findString startingAt: sourceView selectionRange start + 1.
	offset = 0
		ifTrue: 
			[methodListPresenter selection = methodListPresenter methodListPresenter list last
				ifTrue: 
					[sourceView isModified ifTrue: [methodSourcePresenter isOkayToChange ifFalse: [^self]].
					methodListPresenter methodListPresenter selectionByIndex: 1.
					^self resetAndFindFirstIn: sourceView].
			sourceView isModified ifTrue: [methodSourcePresenter isOkayToChange ifFalse: [^self]].
			methodListPresenter methodListPresenter
				selectionByIndex: methodListPresenter methodListPresenter selectionByIndex + 1.
			^self resetAndFindFirstIn: sourceView].
	sourceView selectionRange: (offset to: offset + findString size - 1)!

onViewOpened

	super onViewOpened. 
	self registerPresentersForUpdates.
	self updateAutoCommit.!

previousSelection
	| sourceView offset |
	sourceView := self methodSourcePresenter documentPresenter view.
	self methodSourcePresenter documentPresenter view setFocus.
	offset := sourceView findString: findString startingAt: 1.
	(offset = 0 or:[offset >= sourceView selectionRange start])
		ifTrue: 
			[methodListPresenter selection = methodListPresenter methodListPresenter list first
				ifTrue: 
					[sourceView isModified ifTrue: [methodSourcePresenter isOkayToChange ifFalse: [^self]].
					methodListPresenter methodListPresenter
						selectionByIndex: methodListPresenter methodListPresenter list size.
					^self resetAndFindLastIn: sourceView].
			sourceView isModified ifTrue: [methodSourcePresenter isOkayToChange ifFalse: [^self]].
			methodListPresenter methodListPresenter
				selectionByIndex: methodListPresenter methodListPresenter selectionByIndex - 1.
			^self resetAndFindLastIn: sourceView].
	sourceView selectionRange: (offset to: offset + findString size - 1)!

resetAndFindFirstIn: sourceView
	| offset |
	sourceView selectionRange: (0 to: 0).
	offset := sourceView findString: findString startingAt: 1.
	sourceView selectionRange: (offset to: offset + findString size - 1).
	self methodSourcePresenter documentPresenter view setFocus.
	!

resetAndFindLastIn: sourceView
	| offset  lastOffset |
	sourceView selectionRange: (0 to: 0).
	offset := 0.
	[offset := sourceView findString: findString startingAt: offset + 1.
	offset = 0] whileFalse: [lastOffset := offset].
	lastOffset ifNil:[^self].
	sourceView selectionRange: (lastOffset to: lastOffset + findString size - 1).
	self methodSourcePresenter documentPresenter view setFocus!

selectionChanged
	| sourceView selectionRanges offset selection |
	findString ifNil: [^self].
	selection := methodListPresenter methodListPresenter selection.
	findString := selection failedCompile ifTrue: [selection comparisonSource] ifFalse: [newClassName].
	sourceView := self methodSourcePresenter documentPresenter view.
	selectionRanges := OrderedCollection new.
	offset := 1.
	[(offset := sourceView findString: findString startingAt: offset + 1) = 0]
		whileFalse: [selectionRanges add: (offset to: offset + findString size - 1)].
	sourceView selectionRanges: selectionRanges.
	self showComparison!

showComparison
	| selection |
	selection := methodListPresenter methodListPresenter selectionIfNone: [^self].
	selection failedCompile
		ifTrue: 
			[comparisonPresenter
				beforeTitle: 'Current Source';
				afterTitle: 'Proposed Source';
				compare: selection source
					with: (selection source copyReplaceAll: selection comparisonSource with: newClassName)]
		ifFalse: 
			[comparisonPresenter
				beforeTitle: 'Old Source';
				afterTitle: 'Current Source';
				compare: selection comparisonSource with: selection source]! !
!JadeiteRenameClassMethodListPresenter categoriesFor: #createComponents!initialization!public! !
!JadeiteRenameClassMethodListPresenter categoriesFor: #createSchematicWiring!initialization!public! !
!JadeiteRenameClassMethodListPresenter categoriesFor: #findString:!accessing!private! !
!JadeiteRenameClassMethodListPresenter categoriesFor: #newClassName!accessing!private! !
!JadeiteRenameClassMethodListPresenter categoriesFor: #newClassName:!accessing!private! !
!JadeiteRenameClassMethodListPresenter categoriesFor: #nextSelection!event handlers!public! !
!JadeiteRenameClassMethodListPresenter categoriesFor: #onViewOpened!event handlers!public! !
!JadeiteRenameClassMethodListPresenter categoriesFor: #previousSelection!event handlers!public! !
!JadeiteRenameClassMethodListPresenter categoriesFor: #resetAndFindFirstIn:!event handlers!public! !
!JadeiteRenameClassMethodListPresenter categoriesFor: #resetAndFindLastIn:!event handlers!public! !
!JadeiteRenameClassMethodListPresenter categoriesFor: #selectionChanged!event handlers!public! !
!JadeiteRenameClassMethodListPresenter categoriesFor: #showComparison!event handlers!public! !

!JadeiteRenameClassMethodListPresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil nil 5 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 2 410 ##(Smalltalk.ReferenceView) 34 14 nil 416 34 2 8 1140916224 131073 544 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 nil 5 nil nil nil 544 1180166 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteBasicRenameClassMethodListPresenter) #resource_Default_view nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 328198 ##(Smalltalk.Point) 1 1 802 1461 271 544 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 218 2 0 0 135 0 0 0] 8 #() 802 193 193 nil 27 524806 ##(Smalltalk.Fraction) 3 5 true 170 192 34 6 544 8 'methodList' 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 1008 nil 610 8 4278190080 nil 517 nil nil nil 1008 690 138 144 34 1 754 #createAt:extent: 34 2 802 1 271 802 1461 11 1008 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 135 0 0 0 218 2 0 0 140 0 0 0] 8 #() 912 nil 27 8 'Splitter' 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 1280 nil 610 8 4278190080 nil 5 nil nil nil 1280 655878 ##(Smalltalk.CardLayout) 138 144 34 2 721414 ##(Smalltalk.Association) 8 'Comparison' 410 ##(Smalltalk.ShellView) 34 27 nil 1280 34 2 8 1078919168 131073 1488 nil 610 8 4278190080 nil 517 nil nil nil 1488 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 1488 34 2 8 1140850688 131073 1616 nil 610 1568 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 5 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 1746 1 1778 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 1746 1 1778 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 1746 1 1778 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 1746 1 1778 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 1616 482 170 176 896 false 170 192 896 nil 690 138 144 34 2 754 #createAt:extent: 34 2 802 1 1 802 1413 447 1616 754 #contextMenu: 34 1 1712 1616 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 194 2 0 0 223 0 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 1616 34 2 8 1140850688 131073 2272 nil 610 1568 nil 5 nil nil nil 2272 1586 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 2272 34 2 8 1140850945 262145 2368 nil nil nil 5 nil nil nil 2368 nil 8 1674732848 852486 ##(Smalltalk.NullConverter) nil nil nil 690 138 144 34 2 754 #createAt:extent: 34 2 802 1 407 802 701 41 2368 754 #text: 34 1 8 '
' 2368 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 203 0 0 0 94 1 0 0 223 0 0 0] 8 #() 912 nil 27 nil nil 410 ##(Smalltalk.ScintillaView) 34 50 nil 2272 34 2 8 1140920580 1025 2688 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 610 1568 nil 5 nil nil nil 2688 nil 8 4294904155 2450 nil nil 11 nil 170 192 34 12 #indentGuide 1182790 1 ##(Smalltalk.ScintillaTextStyle) 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 2898 3 786694 ##(Smalltalk.IndexedColor) 33554445 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 2898 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 2898 77 2946 33554457 2946 33554471 1 nil nil nil nil #callTip nil nil nil #normal 2898 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 2898 5 nil 196934 1 ##(Smalltalk.RGB) 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 3040 2928 3056 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 2976 nil nil nil 2912 nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 1641542 1 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 2688 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 896 nil 170 176 896 9215 nil nil nil nil 2946 33554447 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 2864 nil nil nil nil 1 nil 170 192 34 6 8 'indicator2' 1510470 2 ##(Smalltalk.ScintillaIndicatorStyle) 5 2688 511 1 false nil nil nil nil nil nil nil 8 'indicator0' 3378 1 2688 33554459 13 false nil nil nil nil nil nil nil 8 'indicator1' 3378 3 2688 33423361 5 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 2898 1029 nil 3074 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 2898 1027 3074 60239 3074 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2898 1031 3074 335 3074 31317503 1 nil nil nil nil #Error nil nil nil nil 690 138 144 34 7 754 #createAt:extent: 34 2 802 1 1 802 701 407 2688 754 #modificationEventMask: 8 #(4607) 2688 754 #caretPeriod: 8 #(530) 2688 754 #wordWrap: 8 #(true) 2688 754 #margins: 34 1 34 3 985158 2 ##(Smalltalk.ScintillaMargin) 1 2688 49 3 nil nil nil nil 3890 3 2688 1 nil nil 67108863 nil nil 3890 5 2688 1 nil nil nil nil nil 2688 754 #canHScroll: 8 #(false) 2688 754 #maxCompletionListHeight: 8 #(9) 2688 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 94 1 0 0 203 0 0 0] 8 #() 912 nil 29 170 192 34 4 2688 8 'before' 2368 8 'beforeTitle' nil 690 138 144 34 1 754 #createAt:extent: 34 2 802 1 1 802 701 447 2272 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 94 1 0 0 223 0 0 0] 34 2 2688 2368 912 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 1616 34 2 8 1140850688 1 4288 nil 3074 66047 nil 517 nil nil nil 4288 690 138 144 34 1 754 #createAt:extent: 34 2 802 701 1 802 11 447 4288 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 94 1 0 0 0 0 0 0 99 1 0 0 223 0 0 0] 8 #() 912 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 1616 34 2 8 1140850688 131073 4528 nil 610 1568 nil 5 nil nil nil 4528 1586 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 4528 34 2 8 1140850945 262145 4624 nil nil nil 5 nil nil nil 4624 nil 8 1674732848 2450 nil nil nil 690 138 144 34 2 754 #createAt:extent: 34 2 802 1 407 802 703 41 4624 754 #text: 34 1 8 '
' 4624 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 203 0 0 0 95 1 0 0 223 0 0 0] 8 #() 912 nil 27 nil nil 410 ##(Smalltalk.ScintillaView) 34 50 nil 4528 34 2 8 1140920580 1025 4928 2754 nil false 2800 nil 610 1568 nil 5 nil nil nil 4928 nil 8 4294904155 2450 nil nil 11 nil 170 192 34 12 #indentGuide 2898 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 2898 3 2960 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 2898 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 2898 77 3008 3024 1 nil nil nil nil #callTip nil nil nil #normal 2898 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 2898 5 nil 3074 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 5152 5104 5168 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 5120 nil nil nil 5088 nil nil 3122 3152 170 192 34 2 #default 3202 1 nil nil nil 4928 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 896 nil 170 176 896 9215 nil nil nil nil 3264 nil nil 65 nil nil nil 3280 3 170 192 34 2 #container 5056 nil nil nil nil 1 nil 170 192 34 6 8 'indicator2' 3378 5 4928 511 1 false nil nil nil nil nil nil nil 8 'indicator0' 3378 1 4928 33554459 13 false nil nil nil nil nil nil nil 8 'indicator1' 3378 3 4928 33423361 5 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 2898 1029 nil 3074 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 2898 1027 3074 60239 3074 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2898 1031 3074 335 3074 31317503 1 nil nil nil nil #Error nil nil nil nil 690 138 144 34 7 754 #createAt:extent: 34 2 802 1 1 802 703 407 4928 754 #modificationEventMask: 8 #(4607) 4928 754 #caretPeriod: 8 #(530) 4928 754 #wordWrap: 8 #(true) 4928 754 #margins: 34 1 34 3 3890 1 4928 49 3 nil nil nil nil 3890 3 4928 1 nil nil 67108863 nil nil 3890 5 4928 1 nil nil nil nil nil 4928 754 #canHScroll: 8 #(false) 4928 754 #maxCompletionListHeight: 8 #(9) 4928 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 95 1 0 0 203 0 0 0] 8 #() 912 nil 29 170 192 34 4 4928 8 'after' 4624 8 'afterTitle' nil 690 138 144 34 1 754 #createAt:extent: 34 2 802 711 1 802 703 447 4528 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 99 1 0 0 0 0 0 0 194 2 0 0 223 0 0 0] 34 2 4928 4624 912 nil 27 912 nil 27 170 192 34 2 1616 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 1698 nil true 34 4 1746 1 1778 #selectUpper 8 'Select &upper' 1 1 nil nil nil 1746 1 1778 #selectLower 8 'Select &lower' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 1746 1 1778 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 20519 nil nil 1698 nil true 34 3 1746 1 1778 #character 8 '&Character' 1 1 nil nil nil 1746 1 1778 #word 8 '&Word' 1 1 nil nil nil 1746 1 1778 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 20521 nil nil 1698 nil true 34 1 1746 1 1778 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 20523 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 690 138 144 34 3 754 #createAt:extent: 34 2 802 9 55 802 1445 479 1488 754 #text: 34 1 8 'Differences' 1488 754 #updateMenuBar 896 1488 850 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 214 2 0 0 10 1 0 0] 34 1 1616 912 nil 27 1442 8 'Method Source' 410 ##(Smalltalk.ReferenceView) 34 14 nil 1280 34 2 8 1140850688 131073 7152 nil 610 8 4278190080 nil 5 nil nil nil 7152 658 ##(Smalltalk.JadeiteMethodSourcePresenter) #resource_Default_view nil 690 138 144 34 1 754 #createAt:extent: 34 2 802 9 55 802 1445 479 7152 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 214 2 0 0 10 1 0 0] 896 912 nil 27 7152 170 192 34 4 7152 8 'methodSource' 1488 8 'comparisonTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 1280 34 2 8 1140916736 1 7472 590662 2 ##(Smalltalk.ListModel) 138 144 34 2 7136 1472 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) nil nil 1 nil nil nil 7472 nil 8 4294910431 787814 3 ##(Smalltalk.BlockClosure) 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 7664 7 257 nil 7650 0 nil 7682 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 7728 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #noIcons nil nil nil nil nil 690 138 144 34 3 754 #createAt:extent: 34 2 802 1 1 802 1461 541 7472 754 #basicSelectionsByIndex: 34 1 8 #(1) 7472 754 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 7472 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 218 2 0 0 14 1 0 0] 8 #() 912 nil 27 690 138 144 34 2 754 #createAt:extent: 34 2 802 1 281 802 1461 541 1280 754 #text: 34 1 8 'textAreaTabs' 1280 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 140 0 0 0 218 2 0 0 154 1 0 0] 34 3 7152 1488 7472 912 nil 27 8 'textAreaTabs' nil 690 138 144 34 1 754 #createAt:extent: 34 2 802 7679 21 802 1461 821 416 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 217 17 0 0 164 1 0 0] 34 3 544 1008 1280 912 nil 27 )! !
!JadeiteRenameClassMethodListPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

