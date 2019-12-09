"Filed out from Dolphin Smalltalk 7"!

MCPatchBrowser subclass: #RowanPatchBrowser
	instanceVariableNames: 'name diffsPresenter'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanPatchBrowser guid: (GUID fromString: '{5754d2bc-5a68-40d5-a2b0-36ac0383ab9f}')!
RowanPatchBrowser comment: ''!
!RowanPatchBrowser categoriesForClass!Unclassified! !
!RowanPatchBrowser methodsFor!

additionalAccelerators
	^#(#(#raiseConsole 'Ctrl+F7'))!

afterTitle: operation
	^operation obsoletionMemo = operation modificationMemo
		ifTrue: ['Image (no change)']
		ifFalse: ['Image']!

createComponents
	super createComponents.
	includeIdenticalPresenter value: true.
	diffsPresenter := self add: DiffBrowser new diffsPresenter name: 'diffs'!

name
	^name!

name: anObject
	name := anObject!

operationSelected
	| operation afterTitle |
	self showNoComparison.
	operationListPresenter hasSelection ifFalse: [^self].
	operation := operationListPresenter selection.
	afterTitle := self afterTitle: operation.
	diffsPresenter
		beforeTitle: 'Disk';
		afterTitle: afterTitle;
		compare: operation obsoletionMemo with: operation modificationMemo!

queryCommand: aCommandQuery
	| command |
	command := aCommandQuery command.
	operationListPresenter selections isEmpty
		ifTrue: 
			[aCommandQuery isEnabled: false.
			^true].
	#revert = command
		ifTrue: 
			[aCommandQuery isEnabled: operationListPresenter selection isMethodModification.
			^true].
	^super queryCommand: aCommandQuery!

raiseConsole
	| transcript |
	transcript := JadeiteTranscript allInstances
				detect: [:trans | trans gciSession = GciSession current]
				ifNone: [^self].
	transcript view setFocus!

revert
	| operation afterTitle |
	operation := operationListPresenter selection.
	operation isMethodModification
		ifTrue: 
			[operation revert: gciSession.
			operation clearObsoletionMemo.
			afterTitle := self afterTitle: operation.
			diffsPresenter
				afterTitle: afterTitle;
				compare: operation obsoletionMemo with: operation modificationMemo]
		ifFalse: [MessageBox notify: 'Sorry. Not able to revert that yet']!

shellName

	^name, ' Changes'
!

showNoComparison
	diffsPresenter
		beforeTitle: 'Disk';
		afterTitle: 'Image';
		compare: String new with: String new! !
!RowanPatchBrowser categoriesFor: #additionalAccelerators!accessing!public! !
!RowanPatchBrowser categoriesFor: #afterTitle:!public! !
!RowanPatchBrowser categoriesFor: #createComponents!public! !
!RowanPatchBrowser categoriesFor: #name!accessing!public! !
!RowanPatchBrowser categoriesFor: #name:!accessing!public! !
!RowanPatchBrowser categoriesFor: #operationSelected!public! !
!RowanPatchBrowser categoriesFor: #queryCommand:!menu handlers!public! !
!RowanPatchBrowser categoriesFor: #raiseConsole!menu handlers!public! !
!RowanPatchBrowser categoriesFor: #revert!menu handlers!public! !
!RowanPatchBrowser categoriesFor: #shellName!overrides!private! !
!RowanPatchBrowser categoriesFor: #showNoComparison!public! !

!RowanPatchBrowser class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 1601 1201 551 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 8 #() true 170 192 592 nil nil nil nil nil 1 nil nil nil nil 1 nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 7679 21 514 1601 1201 416 690 #updateMenuBar 592 416 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 31 18 0 0 98 2 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 848 nil nil nil 7 nil nil nil 848 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.CheckBox) 34 16 nil 848 34 2 8 1409363203 1 976 721990 2 ##(Smalltalk.ValueHolder) nil false 1114118 ##(Smalltalk.NeverSearchPolicy) true nil nil 7 nil nil nil 976 nil 8 4294905779 852486 ##(Smalltalk.NullConverter) nil nil nil 626 138 144 34 2 690 #createAt:extent: 34 2 514 5 1 514 511 41 976 690 #text: 34 1 8 'Include methods with identical source' 976 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 2 0 0 0 0 0 0 0 1 1 0 0 20 0 0 0] 8 #() 514 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 5 1410 #fixedViewLeft 511 1410 #fixedParentTop 1 1410 #fixedViewTop 41 410 ##(Smalltalk.ListView) 34 30 nil 848 34 2 8 1409355853 1025 1488 590662 2 ##(Smalltalk.ListModel) 138 144 592 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 466 8 4278190080 nil 7 265030 4 ##(Smalltalk.Menu) nil true 34 5 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #browseChangedThing 8 'Browse in Project Browser' 1 1 nil nil nil 1714 1 1746 #browseImplementors 8 'Browse Implementors' 1 1 nil nil nil 1714 1 1746 #browseSenders 8 'Browse Senders' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 1714 1 1746 #revert 8 'Revert' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 1488 nil 8 4294906201 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 4 920646 5 ##(Smalltalk.ListViewColumn) 8 'Type' 301 #left 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 2160 8 'doIt' 8 '[:each | each typeString]' 8 #[30 105 226 0 106] #typeString 2176 7 257 nil 2162 0 nil 2194 2 1 2000 8 'doIt' 8 '[:x :y | x typeString <= y typeString]' 8 #[30 105 226 0 226 32 130 106] #typeString 2272 7 513 nil nil nil 1488 nil 1 2162 0 nil 2194 5 1 2160 8 'doIt' 8 '[:each | each className, ''>>'', each selector]' 8 #[33 105 226 0 30 178 226 3 178 106] #className 8 '>>' #, #selector 2352 7 257 nil nil 2114 8 'Class' 401 #left 2162 0 nil 2194 2 1 2000 8 'doIt' 8 '[:each | each className]' 8 #[30 105 226 0 106] #className 2480 7 257 nil 2162 0 nil 2194 2 1 106 8 'Dolphin' 8 'SortedCollection' 8 'doIt' 8 '[:x :y | x className <= y className]' 8 #[30 105 226 0 226 32 130 106] #className 2560 7 513 nil nil nil 1488 nil 1 nil nil 2114 8 'Selector' 401 #left 2162 0 nil 2194 2 1 112 8 'doIt' 8 '[:each | each selector]' 8 #[30 105 226 0 106] #selector 2720 7 257 nil 2162 0 nil 2194 2 1 2160 8 'doIt' 8 '[:x :y | x selector <= y selector]' 8 #[30 105 226 0 226 32 130 106] #selector 2800 7 513 nil nil nil 1488 nil 1 nil nil 2114 8 'Detail' 961 #left 2162 0 nil 2194 2 1 2000 8 'doIt' 8 '[:each | each detailsString]' 8 #[30 105 226 0 106] #detailsString 2912 7 257 nil 2162 0 nil 2194 2 1 2160 8 'doIt' 8 '[:x :y | x detailsString <= y detailsString]' 8 #[30 105 226 0 226 32 130 106] #detailsString 2992 7 513 nil nil nil 1488 nil 3 nil nil #report 592 nil 133217 nil 34 4 nil nil 514 1 1 nil 626 138 144 34 3 690 #createAt:extent: 34 2 514 1 41 514 1569 517 1488 690 #contextMenu: 34 1 1680 1488 690 #text: 34 1 8 'Type' 1488 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 20 0 0 0 16 3 0 0 22 1 0 0] 8 #() 1360 nil 27 1378 1424 1 1410 #fixedParentRight 1 1456 41 1410 #fixedParentBottom 1 170 192 34 4 976 8 'includeIdenticalSource' 1488 8 'operationList' nil 626 138 144 34 1 690 #createAt:extent: 34 2 514 1 1 514 1569 557 848 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 3 0 0 22 1 0 0] 34 2 976 1488 1360 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 3616 nil 466 8 4278190080 nil 519 nil nil nil 3616 626 138 144 34 1 690 #createAt:extent: 34 2 514 1 557 514 1569 11 3616 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 22 1 0 0 16 3 0 0 27 1 0 0] 8 #() 1360 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 3872 nil nil nil 7 nil nil nil 3872 546 170 176 592 false 170 192 592 nil 626 138 144 34 1 690 #createAt:extent: 34 2 514 1 567 514 1569 557 3872 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 27 1 0 0 16 3 0 0 49 2 0 0] 34 2 410 ##(Smalltalk.Splitter) 34 12 nil 3872 34 2 8 1140850688 1 4144 nil 466 3696 nil 519 nil nil nil 4144 626 138 144 34 1 690 #createAt:extent: 34 2 514 585 1 514 11 557 4144 786 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 36 1 0 0 0 0 0 0 41 1 0 0 22 1 0 0] 8 #() 1360 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 3872 34 2 8 1140850688 131073 4384 nil nil nil 7 nil nil nil 4384 914 170 176 34 2 410 ##(Smalltalk.ShellView) 34 27 nil 4384 34 2 8 1083113472 131073 4496 nil 466 8 4278190080 nil 551 nil nil nil 4496 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 4496 34 2 8 1140850688 131073 4624 nil 466 4576 nil 7 1666 nil true 34 5 1714 1 1746 #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 1714 1 1746 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 1714 1 1746 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 1714 1 1746 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 1714 1 1746 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 4624 546 170 176 592 false 170 192 592 nil 626 138 144 34 2 690 #createAt:extent: 34 2 514 1 1 514 1537 525 4624 690 #contextMenu: 34 1 4704 4624 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 0 3 0 0 6 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 4624 34 2 8 1140850688 131073 5232 nil 466 4576 nil 7 nil nil nil 5232 4594 1 1 410 ##(Smalltalk.StaticText) 34 16 nil 5232 34 2 8 1140850945 262145 5328 nil nil nil 7 nil nil nil 5328 nil 8 1663077024 1122 nil nil nil 626 138 144 34 2 690 #createAt:extent: 34 2 514 1 1 514 763 41 5328 690 #text: 34 1 8 '
' 5328 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 125 1 0 0 20 0 0 0] 8 #() 1360 nil 27 nil nil nil 410 ##(Smalltalk.ScintillaView) 34 50 nil 5232 34 2 8 1140920580 1025 5632 1042 nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 466 4576 nil 7 nil nil nil 5632 nil 8 4294906401 1122 nil nil 11 nil 170 192 34 12 #indentGuide 1182790 1 ##(Smalltalk.ScintillaTextStyle) 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 5826 3 786694 ##(Smalltalk.IndexedColor) 33554445 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 5826 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 5826 77 5874 33554457 5874 33554471 1 nil nil nil nil #callTip nil nil nil #normal 5826 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 5826 5 nil 196934 1 ##(Smalltalk.RGB) 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 5968 5856 5984 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 5904 nil nil nil 5840 nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 1641542 1 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 5632 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 592 nil 170 176 592 9215 nil nil nil nil 5874 33554447 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 5792 nil nil nil nil 1 nil 170 192 34 6 8 'indicator0' 1510470 2 ##(Smalltalk.ScintillaIndicatorStyle) 1 5632 33554459 13 false nil nil nil nil nil nil nil 8 'indicator1' 6306 3 5632 33423361 5 false nil nil nil nil nil nil nil 8 'indicator2' 6306 5 5632 511 1 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 5826 1029 nil 6002 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 5826 1027 6002 60239 6002 31326207 1 nil nil nil nil #Warning nil nil nil #Error 5826 1031 6002 335 6002 31317503 1 nil nil nil nil #Error nil nil nil nil 626 138 144 34 7 690 #createAt:extent: 34 2 514 1 41 514 763 485 5632 690 #modificationEventMask: 8 #(4607) 5632 690 #caretPeriod: 8 #(530) 5632 690 #wordWrap: 8 #(true) 5632 690 #margins: 34 1 34 3 985158 2 ##(Smalltalk.ScintillaMargin) 1 5632 49 3 nil nil nil nil 6818 3 5632 1 nil nil 67108863 nil nil 6818 5 5632 1 nil nil nil nil nil 5632 690 #canHScroll: 8 #(false) 5632 690 #maxCompletionListHeight: 8 #(9) 5632 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 20 0 0 0 125 1 0 0 6 1 0 0] 8 #() 1360 nil 29 170 192 34 4 5328 8 'beforeTitle' 5632 8 'before' nil 626 138 144 34 1 690 #createAt:extent: 34 2 514 1 1 514 763 525 5232 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 125 1 0 0 6 1 0 0] 34 2 5632 5328 1360 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 4624 34 2 8 1140850688 1 7216 nil 6002 66047 nil 519 nil nil nil 7216 626 138 144 34 1 690 #createAt:extent: 34 2 514 763 1 514 11 525 7216 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 125 1 0 0 0 0 0 0 130 1 0 0 6 1 0 0] 8 #() 1360 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 4624 34 2 8 1140850688 131073 7456 nil 466 4576 nil 7 nil nil nil 7456 4594 1 1 410 ##(Smalltalk.StaticText) 34 16 nil 7456 34 2 8 1140850945 262145 7552 nil nil nil 7 nil nil nil 7552 nil 8 1663077024 1122 nil nil nil 626 138 144 34 2 690 #createAt:extent: 34 2 514 1 1 514 765 41 7552 690 #text: 34 1 8 '
' 7552 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 126 1 0 0 20 0 0 0] 8 #() 1360 nil 27 nil nil nil 410 ##(Smalltalk.ScintillaView) 34 50 nil 7456 34 2 8 1140920580 1025 7856 1042 nil false 5728 nil 466 4576 nil 7 nil nil nil 7856 nil 8 4294906401 1122 nil nil 11 nil 170 192 34 12 #indentGuide 5826 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 5826 3 5888 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 5826 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 5826 77 5936 5952 1 nil nil nil nil #callTip nil nil nil #normal 5826 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 5826 5 nil 6002 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 8080 8032 8096 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 8048 nil nil nil 8016 nil nil 6050 6080 170 192 34 2 #default 6130 1 nil nil nil 7856 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 592 nil 170 176 592 9215 nil nil nil nil 6192 nil nil 65 nil nil nil 6208 3 170 192 34 2 #container 7984 nil nil nil nil 1 nil 170 192 34 6 8 'indicator1' 6306 3 7856 33423361 5 false nil nil nil nil nil nil nil 8 'indicator2' 6306 5 7856 511 1 false nil nil nil nil nil nil nil 8 'indicator0' 6306 1 7856 33554459 13 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 5826 1029 nil 6002 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 5826 1027 6002 60239 6002 31326207 1 nil nil nil nil #Warning nil nil nil #Error 5826 1031 6002 335 6002 31317503 1 nil nil nil nil #Error nil nil nil nil 626 138 144 34 7 690 #createAt:extent: 34 2 514 1 41 514 765 485 7856 690 #modificationEventMask: 8 #(4607) 7856 690 #caretPeriod: 8 #(530) 7856 690 #wordWrap: 8 #(true) 7856 690 #margins: 34 1 34 3 6818 1 7856 49 3 nil nil nil nil 6818 3 7856 1 nil nil 67108863 nil nil 6818 5 7856 1 nil nil nil nil nil 7856 690 #canHScroll: 8 #(false) 7856 690 #maxCompletionListHeight: 8 #(9) 7856 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 20 0 0 0 126 1 0 0 6 1 0 0] 8 #() 1360 nil 29 170 192 34 4 7856 8 'after' 7552 8 'afterTitle' nil 626 138 144 34 1 690 #createAt:extent: 34 2 514 773 1 514 765 525 7456 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 130 1 0 0 0 0 0 0 0 3 0 0 6 1 0 0] 34 2 7856 7552 1360 nil 27 1360 nil 27 170 192 34 2 4624 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 1666 nil true 34 4 1714 1 1746 #selectUpper 8 'Select &upper' 1 1 nil nil nil 1714 1 1746 #selectLower 8 'Select &lower' 1 1 nil nil nil 1890 4097 1714 1 1746 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 63781 nil nil 1666 nil true 34 3 1714 1 1746 #character 8 '&Character' 1 1 nil nil nil 1714 1 1746 #word 8 '&Word' 1 1 nil nil nil 1714 1 1746 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 63789 nil nil 1666 nil true 34 1 1714 1 1746 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 63793 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 626 138 144 34 3 690 #createAt:extent: 34 2 514 1 1 514 1569 557 4496 690 #text: 34 1 8 'Differences' 4496 690 #updateMenuBar 592 4496 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 3 0 0 22 1 0 0] 34 1 4624 1360 nil 27 1378 1424 1 3360 1 1456 1 3376 1 170 192 592 nil 626 138 144 34 1 690 #createAt:extent: 34 2 514 1 1 514 1569 557 4384 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 3 0 0 22 1 0 0] 34 1 4496 1360 nil 27 1360 nil 27 1360 nil 27 )!

showOn: aModel name: aString
	| browser | 
	browser := self on: aModel.
	browser name: aString. 
	^browser
		createView: self defaultView;
		showShell;
		yourself! !
!RowanPatchBrowser class categoriesFor: #resource_Default_view!public!resources-views! !
!RowanPatchBrowser class categoriesFor: #showOn:name:!public! !

