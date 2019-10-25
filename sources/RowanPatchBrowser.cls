"Filed out from Dolphin Smalltalk 7"!

MCPatchBrowser subclass: #RowanPatchBrowser
	instanceVariableNames: 'name'
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
	includeIdenticalPresenter value: true!

name
	^name!

name: anObject
	name := anObject!

operationSelected

	| operation |
	leftTextPresenter 		value: ''.
	leftMemoPresenter	value: ''.
	rightTextPresenter	value: ''.
	rightMemoPresenter	value: ''.
	operationListPresenter hasSelection ifFalse: [^self].
	operation := operationListPresenter selection.
	leftTextPresenter 		value: 'Disk'.
	leftMemoPresenter	value: operation obsoletionMemo.
	rightTextPresenter	value: 'Image'.
	rightMemoPresenter	value: operation modificationMemo. 
	operation obsoletionMemoMarkers do: [:each | 
		leftMemoPresenter view addMarkerType: each key at: each value.
	].
	operation modificationMemoMarkers do: [:each |
		rightMemoPresenter view addMarkerType: each key at: each value.
	].
!

raiseConsole
	| transcript |
	transcript := JadeiteTranscript allInstances
				detect: [:trans | trans gciSession = GciSession current]
				ifNone: [^self].
	transcript view setFocus!

shellName

	^name, ' Changes'
! !
!RowanPatchBrowser categoriesFor: #additionalAccelerators!accessing!public! !
!RowanPatchBrowser categoriesFor: #createComponents!public! !
!RowanPatchBrowser categoriesFor: #name!accessing!public! !
!RowanPatchBrowser categoriesFor: #name:!accessing!public! !
!RowanPatchBrowser categoriesFor: #operationSelected!public! !
!RowanPatchBrowser categoriesFor: #raiseConsole!menu handlers!public! !
!RowanPatchBrowser categoriesFor: #shellName!overrides!private! !

!RowanPatchBrowser class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 1601 1201 551 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 8 #() true 170 192 592 nil nil nil nil nil 1 nil nil nil nil 1 nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 7679 21 514 1601 1201 416 690 #updateMenuBar 592 416 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 31 18 0 0 98 2 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 848 nil nil nil 7 nil nil nil 848 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.ListView) 34 30 nil 848 34 2 8 1409355853 1025 976 590662 2 ##(Smalltalk.ListModel) 138 144 592 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 466 8 4278190080 nil 7 265030 4 ##(Smalltalk.Menu) nil true 34 3 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #browseChangedThing 8 'Browse in Project Browser' 1 1 nil nil nil 1202 1 1234 #browseImplementors 8 'Browse Implementors' 1 1 nil nil nil 1202 1 1234 #browseSenders 8 'Browse Senders' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 976 nil 8 4294904591 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 4 920646 5 ##(Smalltalk.ListViewColumn) 8 'Type' 301 #left 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 1568 8 'doIt' 8 '[:each | each typeString]' 8 #[30 105 226 0 106] #typeString 1584 7 257 nil 1570 0 nil 1602 2 1 1408 8 'doIt' 8 '[:x :y | x typeString <= y typeString]' 8 #[30 105 226 0 226 32 130 106] #typeString 1680 7 513 nil nil nil 976 nil 1 1570 0 nil 1602 5 1 1568 8 'doIt' 8 '[:each | each className, ''>>'', each selector]' 8 #[33 105 226 0 30 178 226 3 178 106] #className 8 '>>' #, #selector 1760 7 257 nil nil 1522 8 'Class' 401 #left 1570 0 nil 1602 2 1 1408 8 'doIt' 8 '[:each | each className]' 8 #[30 105 226 0 106] #className 1888 7 257 nil 1570 0 nil 1602 2 1 106 8 'Dolphin' 8 'SortedCollection' 8 'doIt' 8 '[:x :y | x className <= y className]' 8 #[30 105 226 0 226 32 130 106] #className 1968 7 513 nil nil nil 976 nil 1 nil nil 1522 8 'Selector' 401 #left 1570 0 nil 1602 2 1 112 8 'doIt' 8 '[:each | each selector]' 8 #[30 105 226 0 106] #selector 2128 7 257 nil 1570 0 nil 1602 2 1 1568 8 'doIt' 8 '[:x :y | x selector <= y selector]' 8 #[30 105 226 0 226 32 130 106] #selector 2208 7 513 nil nil nil 976 nil 1 nil nil 1522 8 'Detail' 961 #left 1570 0 nil 1602 2 1 1408 8 'doIt' 8 '[:each | each detailsString]' 8 #[30 105 226 0 106] #detailsString 2320 7 257 nil 1570 0 nil 1602 2 1 1568 8 'doIt' 8 '[:x :y | x detailsString <= y detailsString]' 8 #[30 105 226 0 226 32 130 106] #detailsString 2400 7 513 nil nil nil 976 nil 3 nil nil #report 592 nil 133217 nil 34 4 nil nil 514 1 1 nil 626 138 144 34 3 690 #createAt:extent: 34 2 514 1 41 514 1569 517 976 690 #contextMenu: 34 1 1168 976 690 #text: 34 1 8 'Type' 976 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 20 0 0 0 16 3 0 0 22 1 0 0] 8 #() 514 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 2802 #fixedParentRight 1 2802 #fixedParentTop 41 2802 #fixedParentBottom 1 410 ##(Smalltalk.CheckBox) 34 16 nil 848 34 2 8 1409363203 1 2880 721990 2 ##(Smalltalk.ValueHolder) nil false 1114118 ##(Smalltalk.NeverSearchPolicy) true nil nil 7 nil nil nil 2880 nil 8 4294905029 852486 ##(Smalltalk.NullConverter) nil nil nil 626 138 144 34 2 690 #createAt:extent: 34 2 514 5 1 514 511 41 2880 690 #text: 34 1 8 'Include methods with identical source' 2880 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 2 0 0 0 0 0 0 0 1 1 0 0 20 0 0 0] 8 #() 2752 nil 27 2770 2816 5 2802 #fixedViewLeft 511 2848 1 2802 #fixedViewTop 41 170 192 34 4 976 8 'operationList' 2880 8 'includeIdenticalSource' nil 626 138 144 34 1 690 #createAt:extent: 34 2 514 1 1 514 1569 557 848 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 3 0 0 22 1 0 0] 34 2 2880 976 2752 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 3536 nil 466 8 4278190080 nil 519 nil nil nil 3536 626 138 144 34 1 690 #createAt:extent: 34 2 514 1 557 514 1569 11 3536 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 22 1 0 0 16 3 0 0 27 1 0 0] 8 #() 2752 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 3792 nil nil nil 7 nil nil nil 3792 546 170 176 592 false 170 192 592 nil 626 138 144 34 1 690 #createAt:extent: 34 2 514 1 567 514 1569 557 3792 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 27 1 0 0 16 3 0 0 49 2 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 3792 34 2 8 1140850688 131073 4064 nil nil nil 7 nil nil nil 4064 914 170 176 34 4 410 ##(Smalltalk.TextEdit) 34 16 nil 4064 34 2 8 1140916352 1025 4176 nil 466 8 4278190080 nil 7 nil nil nil 4176 nil 8 4294901891 3026 nil nil 3 626 138 144 34 1 690 #createAt:extent: 34 2 514 1 1 514 779 39 4176 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 133 1 0 0 19 0 0 0] 8 #() 2752 nil 27 2770 2816 1 2832 1 2848 1 3296 39 410 ##(Smalltalk.ScintillaView) 34 50 nil 4064 34 2 8 1445007428 1025 4480 2946 nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 466 8 4278190080 nil 7 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 514 193 193 nil 4480 nil 8 4294904615 3026 nil nil 11 nil 170 192 34 4 #normal 1182790 1 ##(Smalltalk.ScintillaTextStyle) 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 4786 77 786694 ##(Smalltalk.IndexedColor) 33554457 4834 33554471 1 nil nil nil nil #callTip nil nil nil 34 256 4800 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 4816 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 592 170 192 34 8 #removed 1641542 1 ##(Smalltalk.ScintillaMarkerDefinition) 5 20091 nil nil 4480 #removed nil nil nil nil nil nil #changed 4978 7 5 nil nil 4480 #changed nil nil nil nil nil nil #circle 4978 1 nil nil nil 4480 #circle nil nil nil nil nil nil #added 4978 3 20087 nil nil 4480 #added nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 592 nil 170 176 592 9215 nil nil nil nil 4834 33554447 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 4800 nil nil nil nil 1 nil 170 192 34 6 1 1510470 2 ##(Smalltalk.ScintillaIndicatorStyle) 1 4480 65025 3 false 1 nil nil nil nil nil nil 3 5298 3 4480 33423361 5 false 3 nil nil nil nil nil nil 5 5298 5 4480 511 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 4786 1027 nil 196934 1 ##(Smalltalk.RGB) 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 4786 1031 5410 60239 5410 31326207 1 nil nil nil nil #Warning nil nil nil #Error 4786 1029 5410 335 5410 31317503 1 nil nil nil nil #Error nil nil nil nil 626 138 144 34 6 690 #createAt:extent: 34 2 514 1 41 514 779 517 4480 690 #modificationEventMask: 8 #(4607) 4480 690 #caretPeriod: 8 #(530) 4480 690 #margins: 34 1 34 3 985158 2 ##(Smalltalk.ScintillaMargin) 1 4480 1 3 nil nil nil nil 5762 3 4480 33 nil nil 67108863 nil nil 5762 5 4480 1 nil 3 -67108863 nil nil 4480 690 #tabWidth: 8 #(4) 4480 690 #maxCompletionListHeight: 8 #(9) 4480 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 20 0 0 0 133 1 0 0 22 1 0 0] 8 #() 2752 nil 29 2770 2816 1 2832 1 2848 41 2864 1 170 192 34 4 4176 8 'leftText' 4480 8 'leftMemo' nil 626 138 144 34 1 690 #createAt:extent: 34 2 514 1 1 514 779 557 4064 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 133 1 0 0 22 1 0 0] 34 2 4176 4480 2752 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 3792 34 2 8 1140850688 1 6176 nil 466 3616 nil 519 nil nil nil 6176 626 138 144 34 1 690 #createAt:extent: 34 2 514 779 1 514 11 557 6176 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 133 1 0 0 0 0 0 0 138 1 0 0 22 1 0 0] 8 #() 2752 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 3792 34 2 8 1140850688 131073 6416 nil nil nil 7 nil nil nil 6416 914 170 176 34 4 410 ##(Smalltalk.ScintillaView) 34 50 nil 6416 34 2 8 1445007428 1025 6528 2946 nil false 4576 nil 466 4608 nil 7 nil 4626 nil true 4658 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 514 193 193 nil 6528 nil 8 4294904615 3026 nil nil 11 nil 170 192 34 4 #normal 4786 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 4786 77 4848 4864 1 nil nil nil nil #callTip nil nil nil 34 256 6752 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 6768 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 4898 1 nil nil false 138 144 592 170 192 34 8 #removed 4978 5 20091 nil nil 6528 #removed nil nil nil nil nil nil #changed 4978 7 5 nil nil 6528 #changed nil nil nil nil nil nil #circle 4978 1 nil nil nil 6528 #circle nil nil nil nil nil nil #added 4978 3 20087 nil nil 6528 #added nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 592 nil 170 176 592 9215 nil nil nil nil 5088 nil nil 65 nil nil 5104 8 '' 3 170 192 34 2 #container 170 192 34 2 #normal 6752 nil nil nil nil 1 nil 170 192 34 6 1 5298 1 6528 65025 3 false 1 nil nil nil nil nil nil 3 5298 3 6528 33423361 5 false 3 nil nil nil nil nil nil 5 5298 5 6528 511 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 4786 1027 nil 5410 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 4786 1031 5410 60239 5410 31326207 1 nil nil nil nil #Warning nil nil nil #Error 4786 1029 5410 335 5410 31317503 1 nil nil nil nil #Error nil nil nil nil 626 138 144 34 6 690 #createAt:extent: 34 2 514 1 41 514 781 517 6528 690 #modificationEventMask: 8 #(4607) 6528 690 #caretPeriod: 8 #(530) 6528 690 #margins: 34 1 34 3 5762 1 6528 1 3 nil nil nil nil 5762 3 6528 33 nil nil 67108863 nil nil 5762 5 6528 1 nil 3 -67108863 nil nil 6528 690 #tabWidth: 8 #(4) 6528 690 #maxCompletionListHeight: 8 #(9) 6528 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 20 0 0 0 134 1 0 0 22 1 0 0] 8 #() 2752 nil 29 2770 2816 1 2832 1 2848 41 2864 1 410 ##(Smalltalk.TextEdit) 34 16 nil 6416 34 2 8 1140916352 1025 7680 nil 466 4256 nil 7 nil nil nil 7680 nil 8 4294901891 3026 nil nil 3 626 138 144 34 1 690 #createAt:extent: 34 2 514 1 1 514 781 39 7680 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 134 1 0 0 19 0 0 0] 8 #() 2752 nil 27 2770 2816 1 2832 1 2848 1 3296 39 170 192 34 4 6528 8 'rightMemo' 7680 8 'rightText' nil 626 138 144 34 1 690 #createAt:extent: 34 2 514 789 1 514 781 557 6416 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 138 1 0 0 0 0 0 0 16 3 0 0 22 1 0 0] 34 2 7680 6528 2752 nil 27 2752 nil 27 2752 nil 27 )!

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

