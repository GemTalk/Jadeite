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

createComponents
	super createComponents.
	includeIdenticalPresenter value: true.
	diffsPresenter := self add: DiffBrowser new diffsPresenter name: 'diffs'!

name
	^name!

name: anObject
	name := anObject!

operationSelected
	| operation |
	self showNoComparison. 
	operationListPresenter hasSelection ifFalse: [^self].
	operation := operationListPresenter selection.
	diffsPresenter
		beforeTitle: 'Disk';
		afterTitle: 'Image';
		compare: operation obsoletionMemo with: operation modificationMemo!

raiseConsole
	| transcript |
	transcript := JadeiteTranscript allInstances
				detect: [:trans | trans gciSession = GciSession current]
				ifNone: [^self].
	transcript view setFocus!

shellName

	^name, ' Changes'
!

showNoComparison
	diffsPresenter
		beforeTitle: 'Disk';
		afterTitle: 'Image';
		compare: String new with: String new! !
!RowanPatchBrowser categoriesFor: #additionalAccelerators!accessing!public! !
!RowanPatchBrowser categoriesFor: #createComponents!public! !
!RowanPatchBrowser categoriesFor: #name!accessing!public! !
!RowanPatchBrowser categoriesFor: #name:!accessing!public! !
!RowanPatchBrowser categoriesFor: #operationSelected!public! !
!RowanPatchBrowser categoriesFor: #raiseConsole!menu handlers!public! !
!RowanPatchBrowser categoriesFor: #shellName!overrides!private! !
!RowanPatchBrowser categoriesFor: #showNoComparison!public! !

!RowanPatchBrowser class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 1601 1201 551 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 8 #() true 170 192 592 nil nil nil nil nil 1 nil nil nil nil 1 nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 7679 21 514 1601 1201 416 690 #updateMenuBar 592 416 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 31 18 0 0 98 2 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 848 nil nil nil 7 nil nil nil 848 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.CheckBox) 34 16 nil 848 34 2 8 1409363203 1 976 721990 2 ##(Smalltalk.ValueHolder) nil false 1114118 ##(Smalltalk.NeverSearchPolicy) true nil nil 7 nil nil nil 976 nil 8 4294905779 852486 ##(Smalltalk.NullConverter) nil nil nil 626 138 144 34 2 690 #createAt:extent: 34 2 514 5 1 514 511 41 976 690 #text: 34 1 8 'Include methods with identical source' 976 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 2 0 0 0 0 0 0 0 1 1 0 0 20 0 0 0] 8 #() 514 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 5 1410 #fixedViewLeft 511 1410 #fixedParentTop 1 1410 #fixedViewTop 41 410 ##(Smalltalk.ListView) 34 30 nil 848 34 2 8 1409355853 1025 1488 590662 2 ##(Smalltalk.ListModel) 138 144 592 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 466 8 4278190080 nil 7 265030 4 ##(Smalltalk.Menu) nil true 34 3 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #browseChangedThing 8 'Browse in Project Browser' 1 1 nil nil nil 1714 1 1746 #browseImplementors 8 'Browse Implementors' 1 1 nil nil nil 1714 1 1746 #browseSenders 8 'Browse Senders' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 1488 nil 8 4294906201 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 4 920646 5 ##(Smalltalk.ListViewColumn) 8 'Type' 301 #left 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 2080 8 'doIt' 8 '[:each | each typeString]' 8 #[30 105 226 0 106] #typeString 2096 7 257 nil 2082 0 nil 2114 2 1 1920 8 'doIt' 8 '[:x :y | x typeString <= y typeString]' 8 #[30 105 226 0 226 32 130 106] #typeString 2192 7 513 nil nil nil 1488 nil 1 2082 0 nil 2114 5 1 2080 8 'doIt' 8 '[:each | each className, ''>>'', each selector]' 8 #[33 105 226 0 30 178 226 3 178 106] #className 8 '>>' #, #selector 2272 7 257 nil nil 2034 8 'Class' 401 #left 2082 0 nil 2114 2 1 1920 8 'doIt' 8 '[:each | each className]' 8 #[30 105 226 0 106] #className 2400 7 257 nil 2082 0 nil 2114 2 1 106 8 'Dolphin' 8 'SortedCollection' 8 'doIt' 8 '[:x :y | x className <= y className]' 8 #[30 105 226 0 226 32 130 106] #className 2480 7 513 nil nil nil 1488 nil 1 nil nil 2034 8 'Selector' 401 #left 2082 0 nil 2114 2 1 112 8 'doIt' 8 '[:each | each selector]' 8 #[30 105 226 0 106] #selector 2640 7 257 nil 2082 0 nil 2114 2 1 2080 8 'doIt' 8 '[:x :y | x selector <= y selector]' 8 #[30 105 226 0 226 32 130 106] #selector 2720 7 513 nil nil nil 1488 nil 1 nil nil 2034 8 'Detail' 961 #left 2082 0 nil 2114 2 1 1920 8 'doIt' 8 '[:each | each detailsString]' 8 #[30 105 226 0 106] #detailsString 2832 7 257 nil 2082 0 nil 2114 2 1 2080 8 'doIt' 8 '[:x :y | x detailsString <= y detailsString]' 8 #[30 105 226 0 226 32 130 106] #detailsString 2912 7 513 nil nil nil 1488 nil 3 nil nil #report 592 nil 133217 nil 34 4 nil nil 514 1 1 nil 626 138 144 34 3 690 #createAt:extent: 34 2 514 1 41 514 1569 517 1488 690 #contextMenu: 34 1 1680 1488 690 #text: 34 1 8 'Type' 1488 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 20 0 0 0 16 3 0 0 22 1 0 0] 8 #() 1360 nil 27 1378 1424 1 1410 #fixedParentRight 1 1456 41 1410 #fixedParentBottom 1 170 192 34 4 976 8 'includeIdenticalSource' 1488 8 'operationList' nil 626 138 144 34 1 690 #createAt:extent: 34 2 514 1 1 514 1569 557 848 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 3 0 0 22 1 0 0] 34 2 976 1488 1360 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 3536 nil 466 8 4278190080 nil 519 nil nil nil 3536 626 138 144 34 1 690 #createAt:extent: 34 2 514 1 557 514 1569 11 3536 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 22 1 0 0 16 3 0 0 27 1 0 0] 8 #() 1360 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 3792 nil nil nil 7 nil nil nil 3792 546 170 176 592 false 170 192 592 nil 626 138 144 34 1 690 #createAt:extent: 34 2 514 1 567 514 1569 557 3792 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 27 1 0 0 16 3 0 0 49 2 0 0] 34 2 410 ##(Smalltalk.Splitter) 34 12 nil 3792 34 2 8 1140850688 1 4064 nil 466 3616 nil 519 nil nil nil 4064 626 138 144 34 1 690 #createAt:extent: 34 2 514 585 1 514 11 557 4064 786 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 36 1 0 0 0 0 0 0 41 1 0 0 22 1 0 0] 8 #() 1360 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 3792 34 2 8 1140850688 131073 4304 nil nil nil 7 nil nil nil 4304 914 170 176 34 2 410 ##(Smalltalk.ShellView) 34 27 nil 4304 34 2 8 1083113472 131073 4416 nil 466 8 4278190080 nil 551 nil nil nil 4416 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 4416 34 2 8 1140850688 131073 4544 nil 466 4496 nil 7 1666 nil true 34 5 1714 1 1746 #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 1714 1 1746 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 1714 1 1746 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 1714 1 1746 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 1714 1 1746 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 4544 546 170 176 592 false 170 192 592 nil 626 138 144 34 2 690 #createAt:extent: 34 2 514 1 1 514 1537 525 4544 690 #contextMenu: 34 1 4624 4544 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 0 3 0 0 6 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 4544 34 2 8 1140850688 131073 5152 nil 466 4496 nil 7 nil nil nil 5152 4514 1 1 410 ##(Smalltalk.StaticText) 34 16 nil 5152 34 2 8 1140850945 262145 5248 nil nil nil 7 nil nil nil 5248 nil 8 1663077024 1122 nil nil nil 626 138 144 34 2 690 #createAt:extent: 34 2 514 1 1 514 763 41 5248 690 #text: 34 1 8 '
' 5248 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 125 1 0 0 20 0 0 0] 8 #() 1360 nil 27 nil nil nil 410 ##(Smalltalk.ScintillaView) 34 50 nil 5152 34 2 8 1140920580 1025 5552 1042 nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 466 4496 nil 7 nil nil nil 5552 nil 8 4294906401 1122 nil nil 11 nil 170 192 34 12 #indentGuide 1182790 1 ##(Smalltalk.ScintillaTextStyle) 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 5746 3 786694 ##(Smalltalk.IndexedColor) 33554445 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 5746 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 5746 77 5794 33554457 5794 33554471 1 nil nil nil nil #callTip nil nil nil #normal 5746 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 5746 5 nil 196934 1 ##(Smalltalk.RGB) 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 5888 5776 5904 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 5824 nil nil nil 5760 nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 1641542 1 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 5552 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 592 nil 170 176 592 9215 nil nil nil nil 5794 33554447 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 5712 nil nil nil nil 1 nil 170 192 34 6 8 'indicator0' 1510470 2 ##(Smalltalk.ScintillaIndicatorStyle) 1 5552 33554459 13 false nil nil nil nil nil nil nil 8 'indicator1' 6226 3 5552 33423361 5 false nil nil nil nil nil nil nil 8 'indicator2' 6226 5 5552 511 1 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 5746 1029 nil 5922 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 5746 1027 5922 60239 5922 31326207 1 nil nil nil nil #Warning nil nil nil #Error 5746 1031 5922 335 5922 31317503 1 nil nil nil nil #Error nil nil nil nil 626 138 144 34 7 690 #createAt:extent: 34 2 514 1 41 514 763 485 5552 690 #modificationEventMask: 8 #(4607) 5552 690 #caretPeriod: 8 #(530) 5552 690 #wordWrap: 8 #(true) 5552 690 #margins: 34 1 34 3 985158 2 ##(Smalltalk.ScintillaMargin) 1 5552 49 3 nil nil nil nil 6738 3 5552 1 nil nil 67108863 nil nil 6738 5 5552 1 nil nil nil nil nil 5552 690 #canHScroll: 8 #(false) 5552 690 #maxCompletionListHeight: 8 #(9) 5552 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 20 0 0 0 125 1 0 0 6 1 0 0] 8 #() 1360 nil 29 170 192 34 4 5552 8 'before' 5248 8 'beforeTitle' nil 626 138 144 34 1 690 #createAt:extent: 34 2 514 1 1 514 763 525 5152 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 125 1 0 0 6 1 0 0] 34 2 5552 5248 1360 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 4544 34 2 8 1140850688 1 7136 nil 5922 66047 nil 519 nil nil nil 7136 626 138 144 34 1 690 #createAt:extent: 34 2 514 763 1 514 11 525 7136 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 125 1 0 0 0 0 0 0 130 1 0 0 6 1 0 0] 8 #() 1360 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 4544 34 2 8 1140850688 131073 7376 nil 466 4496 nil 7 nil nil nil 7376 4514 1 1 410 ##(Smalltalk.StaticText) 34 16 nil 7376 34 2 8 1140850945 262145 7472 nil nil nil 7 nil nil nil 7472 nil 8 1663077024 1122 nil nil nil 626 138 144 34 2 690 #createAt:extent: 34 2 514 1 1 514 765 41 7472 690 #text: 34 1 8 '
' 7472 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 126 1 0 0 20 0 0 0] 8 #() 1360 nil 27 nil nil nil 410 ##(Smalltalk.ScintillaView) 34 50 nil 7376 34 2 8 1140920580 1025 7776 1042 nil false 5648 nil 466 4496 nil 7 nil nil nil 7776 nil 8 4294906401 1122 nil nil 11 nil 170 192 34 12 #indentGuide 5746 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 5746 3 5808 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 5746 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 5746 77 5856 5872 1 nil nil nil nil #callTip nil nil nil #normal 5746 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 5746 5 nil 5922 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 8000 7952 8016 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 7968 nil nil nil 7936 nil nil 5970 6000 170 192 34 2 #default 6050 1 nil nil nil 7776 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 592 nil 170 176 592 9215 nil nil nil nil 6112 nil nil 65 nil nil nil 6128 3 170 192 34 2 #container 7904 nil nil nil nil 1 nil 170 192 34 6 8 'indicator1' 6226 3 7776 33423361 5 false nil nil nil nil nil nil nil 8 'indicator0' 6226 1 7776 33554459 13 false nil nil nil nil nil nil nil 8 'indicator2' 6226 5 7776 511 1 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 5746 1029 nil 5922 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 5746 1027 5922 60239 5922 31326207 1 nil nil nil nil #Warning nil nil nil #Error 5746 1031 5922 335 5922 31317503 1 nil nil nil nil #Error nil nil nil nil 626 138 144 34 7 690 #createAt:extent: 34 2 514 1 41 514 765 485 7776 690 #modificationEventMask: 8 #(4607) 7776 690 #caretPeriod: 8 #(530) 7776 690 #wordWrap: 8 #(true) 7776 690 #margins: 34 1 34 3 6738 1 7776 49 3 nil nil nil nil 6738 3 7776 1 nil nil 67108863 nil nil 6738 5 7776 1 nil nil nil nil nil 7776 690 #canHScroll: 8 #(false) 7776 690 #maxCompletionListHeight: 8 #(9) 7776 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 20 0 0 0 126 1 0 0 6 1 0 0] 8 #() 1360 nil 29 170 192 34 4 7776 8 'after' 7472 8 'afterTitle' nil 626 138 144 34 1 690 #createAt:extent: 34 2 514 773 1 514 765 525 7376 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 130 1 0 0 0 0 0 0 0 3 0 0 6 1 0 0] 34 2 7776 7472 1360 nil 27 1360 nil 27 170 192 34 2 4544 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 1666 nil true 34 4 1714 1 1746 #selectUpper 8 'Select &upper' 1 1 nil nil nil 1714 1 1746 #selectLower 8 'Select &lower' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 1714 1 1746 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 56619 nil nil 1666 nil true 34 3 1714 1 1746 #character 8 '&Character' 1 1 nil nil nil 1714 1 1746 #word 8 '&Word' 1 1 nil nil nil 1714 1 1746 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 56627 nil nil 1666 nil true 34 1 1714 1 1746 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 56631 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 626 138 144 34 3 690 #createAt:extent: 34 2 514 1 1 514 1569 557 4416 690 #text: 34 1 8 'Differences' 4416 690 #updateMenuBar 592 4416 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 3 0 0 22 1 0 0] 34 1 4544 1360 nil 27 1378 1424 1 3280 1 1456 1 3296 1 170 192 592 nil 626 138 144 34 1 690 #createAt:extent: 34 2 514 1 1 514 1569 557 4304 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 3 0 0 22 1 0 0] 34 1 4416 1360 nil 27 1360 nil 27 1360 nil 27 )!

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

