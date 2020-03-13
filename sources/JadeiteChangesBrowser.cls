"Filed out from Dolphin Smalltalk 7"!

MCPatchBrowser subclass: #JadeiteChangesBrowser
	instanceVariableNames: 'name diffsPresenter session'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteChangesBrowser guid: (GUID fromString: '{5754d2bc-5a68-40d5-a2b0-36ac0383ab9f}')!
JadeiteChangesBrowser comment: ''!
!JadeiteChangesBrowser categoriesForClass!Unclassified! !
!JadeiteChangesBrowser methodsFor!

additionalAccelerators
	^#(#(#raiseConsole 'Ctrl+F7'))!

afterTitle: operation
	^operation obsoletionMemo = operation modificationMemo
		ifTrue: ['Image (no change)']
		ifFalse: ['Image']!

createComponents
	super createComponents.
	diffsPresenter := self add: JadeiteDiffBrowser new diffsPresenter name: 'diffs'!

createSchematicWiring
	super createSchematicWiring.
	includeIdenticalPresenter
		when: #valueChanged
		send: #refreshIdenticalSource
		to: self.
	operationListPresenter
		when: #selectionChanged
		send: #operationSelected
		to: self!

flipIdenticalSource
	includeIdenticalPresenter value: includeIdenticalPresenter value not!

initialize
	super initialize.
	includeIdenticalPresenter := ValueHolder with: true!

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

operationsList

	| list |
	list := operationListPresenter list. 
	includeIdenticalPresenter value ifFalse: [
		list := list reject: [:each | each hasEquivalentText].
	].
	^list asSortedCollection asArray.
!

queryCommand: aCommandQuery
	| command |
	command := aCommandQuery command.
	command = #flipIdenticalSource
		ifTrue: 
			[aCommandQuery isEnabled: true.
			aCommandQuery isChecked: includeIdenticalPresenter value.
			^true].
	(#(#refresh) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: true.
			^true].
	operationListPresenter selections isEmpty
		ifTrue: 
			[aCommandQuery isEnabled: false.
			^true].
	#revert = command
		ifTrue: 
			[| selection |
			selection := operationListPresenter selection.
			aCommandQuery isEnabled: selection canBeReverted.
			^true].
	^super queryCommand: aCommandQuery!

raiseConsole
	| transcript |
	transcript := JadeiteTranscript allInstances
				detect: [:trans | trans gciSession = GciSession current]
				ifNone: [^self].
	transcript view setFocus!

refresh
	| projectService operations |
	projectService := RowanProjectService new name: name.
	operations := projectService basicChangesUsing: gciSession. 
	operationListPresenter list: operations asSortedCollection!

refreshIdenticalSource
	operationListPresenter
		resetSelection;
		list: self operationsList;
		yourself!

revert
	| operation afterTitle |
	
	[operation := operationListPresenter selection.
	operation revert: gciSession.
	operation clearObsoletionMemo.
	afterTitle := self afterTitle: operation.
	diffsPresenter
		afterTitle: afterTitle;
		compare: operation obsoletionMemo with: operation modificationMemo.
	operationListPresenter view invalidate]
			on: Error
			do: [:ex | MessageBox notify: 'Not able to revert this item yet']!

shellName

	^name, ' Changes'
!

showNoComparison
	diffsPresenter
		beforeTitle: 'Disk';
		afterTitle: 'Image';
		compare: String new with: String new! !
!JadeiteChangesBrowser categoriesFor: #additionalAccelerators!accessing!public! !
!JadeiteChangesBrowser categoriesFor: #afterTitle:!public! !
!JadeiteChangesBrowser categoriesFor: #createComponents!public! !
!JadeiteChangesBrowser categoriesFor: #createSchematicWiring!initialization!public! !
!JadeiteChangesBrowser categoriesFor: #flipIdenticalSource!initialization!public! !
!JadeiteChangesBrowser categoriesFor: #initialize!initialization!public! !
!JadeiteChangesBrowser categoriesFor: #name!accessing!public! !
!JadeiteChangesBrowser categoriesFor: #name:!accessing!public! !
!JadeiteChangesBrowser categoriesFor: #operationSelected!public! !
!JadeiteChangesBrowser categoriesFor: #operationsList!public! !
!JadeiteChangesBrowser categoriesFor: #queryCommand:!menu handlers!public! !
!JadeiteChangesBrowser categoriesFor: #raiseConsole!menu handlers!public! !
!JadeiteChangesBrowser categoriesFor: #refresh!menu handlers!public! !
!JadeiteChangesBrowser categoriesFor: #refreshIdenticalSource!menu handlers!public! !
!JadeiteChangesBrowser categoriesFor: #revert!menu handlers!public! !
!JadeiteChangesBrowser categoriesFor: #shellName!overrides!private! !
!JadeiteChangesBrowser categoriesFor: #showNoComparison!public! !

!JadeiteChangesBrowser class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 2111 1841 549 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 592 nil nil nil 7 nil nil nil 592 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ListView) 34 30 nil 592 34 2 8 1409355853 1025 720 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 265030 4 ##(Smalltalk.Menu) nil true 34 5 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #browseChangedThing 8 'Browse in Project Browser' 1 1 nil nil nil 930 1 962 #browseImplementors 8 'Browse Implementors' 1 1 nil nil nil 930 1 962 #browseSenders 8 'Browse Senders' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 930 1 962 #revert 8 'Revert' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 720 nil 8 1660151920 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 4 920646 5 ##(Smalltalk.ListViewColumn) 8 'Type' 301 #left 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 1376 8 'doIt' 8 '[:each | each typeString]' 8 #[30 105 226 0 106] #typeString 1392 7 257 nil 1378 0 nil 1410 2 1 1216 8 'doIt' 8 '[:x :y | x typeString <= y typeString]' 8 #[30 105 226 0 226 32 130 106] #typeString 1488 7 513 nil nil nil 720 nil 1 1378 0 nil 1410 5 1 1376 8 'doIt' 8 '[:each | each className, ''>>'', each selector]' 8 #[33 105 226 0 30 178 226 3 178 106] #className 8 '>>' #, #selector 1568 7 257 nil nil 1330 8 'Class' 401 #left 1378 0 nil 1410 2 1 1216 8 'doIt' 8 '[:each | each className]' 8 #[30 105 226 0 106] #className 1696 7 257 nil 1378 0 nil 1410 2 1 106 8 'Dolphin' 8 'SortedCollection' 8 'doIt' 8 '[:x :y | x className <= y className]' 8 #[30 105 226 0 226 32 130 106] #className 1776 7 513 nil nil nil 720 nil 1 nil nil 1330 8 'Selector' 401 #left 1378 0 nil 1410 2 1 112 8 'doIt' 8 '[:each | each selector]' 8 #[30 105 226 0 106] #selector 1936 7 257 nil 1378 0 nil 1410 2 1 1376 8 'doIt' 8 '[:x :y | x selector <= y selector]' 8 #[30 105 226 0 226 32 130 106] #selector 2016 7 513 nil nil nil 720 nil 1 nil nil 1330 8 'Detail' 971 #left 1378 0 nil 1410 2 1 1216 8 'doIt' 8 '[:each | each detailsString]' 8 #[30 105 226 0 106] #detailsString 2128 7 257 nil 1378 0 nil 1410 2 1 1376 8 'doIt' 8 '[:x :y | x detailsString <= y detailsString]' 8 #[30 105 226 0 226 32 130 106] #detailsString 2208 7 513 nil nil nil 720 nil 3 nil nil #report 832 nil 133217 nil 34 4 nil nil 498 1 1 nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 1 1 498 2079 591 720 2386 #contextMenu: 34 1 896 720 2386 #text: 34 1 8 'Type' 720 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 15 4 0 0 39 1 0 0] 8 #() 498 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 2658 #fixedParentRight 1 2658 #fixedParentTop 1 2658 #fixedParentBottom 1 170 192 34 2 720 8 'operationList' nil 2322 138 144 34 1 2386 #createAt:extent: 34 2 498 1 1 498 2079 591 592 2546 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 15 4 0 0 39 1 0 0] 34 1 720 2608 nil 27 524806 ##(Smalltalk.Fraction) 1081 1563 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 2976 nil nil nil 7 nil nil nil 2976 530 170 176 832 false 170 192 832 nil 2322 138 144 34 1 2386 #createAt:extent: 34 2 498 1 601 498 2079 1123 2976 2546 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 44 1 0 0 15 4 0 0 93 3 0 0] 34 2 410 ##(Smalltalk.Splitter) 34 12 nil 2976 34 2 8 1140850688 1 3248 nil 480 nil 519 nil nil nil 1510470 1 ##(Smalltalk.DraggableViewInteractor) 3248 nil 1 #left nil nil nil 498 1 1 498 9 9 nil 3344 nil 2322 138 144 34 1 2386 #createAt:extent: 34 2 498 585 1 498 11 557 3248 2546 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 36 1 0 0 0 0 0 0 41 1 0 0 22 1 0 0] 8 #() 2608 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 2976 34 2 8 1140850688 131073 3536 nil nil nil 7 nil nil nil 3536 658 170 176 34 2 410 ##(Smalltalk.ShellView) 34 27 nil 3536 34 2 8 1083113472 131073 3648 nil 480 nil 551 nil nil nil 3648 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 3648 34 2 8 1140850688 131073 3744 nil 480 nil 7 882 nil true 34 5 930 1 962 #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 930 1 962 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 930 1 962 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 930 1 962 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 930 1 962 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 3744 530 170 176 832 false 170 192 832 nil 2322 138 144 34 2 2386 #createAt:extent: 34 2 498 1 1 498 2047 1091 3744 2386 #contextMenu: 34 1 3808 3744 2546 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 3 0 0 33 2 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 3744 34 2 8 1140850688 131073 4336 nil 480 nil 7 nil nil nil 4336 3714 1 1 410 ##(Smalltalk.StaticText) 34 16 nil 4336 34 2 8 1140850945 262145 4416 nil nil nil 7 nil nil nil 4416 nil 8 1660258976 852486 ##(Smalltalk.NullConverter) nil nil nil 2322 138 144 34 2 2386 #createAt:extent: 34 2 498 1 1 498 1019 41 4416 2386 #text: 34 1 8 '
' 4416 2546 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 253 1 0 0 20 0 0 0] 8 #() 2608 nil 27 nil nil nil 410 ##(Smalltalk.ScintillaView) 34 50 nil 4336 34 2 8 1140920580 1025 4736 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 480 nil 7 nil nil nil 4736 nil 8 1682100671 4498 nil nil 11 nil 170 192 34 12 #lineNumber 1182790 1 ##(Smalltalk.ScintillaTextStyle) 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 4930 77 466 #gray 466 #white 1 nil nil nil nil #callTip nil nil nil #indentGuide 4930 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #normal 4930 1 nil nil 1 nil nil nil nil #normal nil nil nil #whitespace 4930 3 466 #teal nil 1 nil nil nil nil #whitespace nil nil nil #diff 4930 5 nil 196934 1 ##(Smalltalk.RGB) 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 5024 5040 5072 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 4944 nil nil nil 5008 nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 4736 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 832 nil 170 176 832 9215 nil nil nil nil 466 #silver nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 4896 nil nil nil nil 1 nil 170 192 34 2 #diff 1510470 3 ##(Smalltalk.ScintillaIndicatorStyle) 1 4736 466 #yellow 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 4930 1027 5090 60239 5090 31326207 1 nil nil nil nil #Warning nil nil nil #Error 4930 1031 5090 335 5090 31317503 1 nil nil nil nil #Error nil nil nil #Notification 4930 1029 nil 5090 31185883 1 nil nil nil nil #Notification nil nil nil nil 2322 138 144 34 8 2386 #createAt:extent: 34 2 498 1 41 498 1019 1051 4736 2386 #textLimit: 8 #(1073741823) 4736 2386 #caretPeriod: 8 #(530) 4736 2386 #wordWrap: 8 #(true) 4736 2386 #margins: 34 1 34 3 985158 3 ##(Smalltalk.ScintillaMargin) 1 4736 49 3 nil nil nil nil 5842 3 4736 1 nil nil 67108863 nil nil 5842 5 4736 1 nil nil nil nil nil 4736 2386 #canHScroll: 8 #(false) 4736 2386 #maxCompletionListHeight: 8 #(9) 4736 2386 #edgeColumn: 8 #(1) 4736 2546 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 20 0 0 0 253 1 0 0 33 2 0 0] 8 #() 2608 nil 29 170 192 34 4 4416 8 'beforeTitle' 4736 8 'before' nil 2322 138 144 34 1 2386 #createAt:extent: 34 2 498 1 1 498 1019 1091 4336 2546 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 253 1 0 0 33 2 0 0] 34 2 4736 4416 2608 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 3744 34 2 8 1140850688 1 6272 nil 5090 66047 nil 519 nil nil nil 3314 6272 nil 1 #left nil nil nil 3344 3360 nil 3344 nil 2322 138 144 34 1 2386 #createAt:extent: 34 2 498 1019 1 498 11 1091 6272 2546 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 253 1 0 0 0 0 0 0 2 2 0 0 33 2 0 0] 8 #() 2608 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 3744 34 2 8 1140850688 131073 6528 nil 480 nil 7 nil nil nil 6528 3714 1 1 410 ##(Smalltalk.StaticText) 34 16 nil 6528 34 2 8 1140850945 262145 6608 nil nil nil 7 nil nil nil 6608 nil 8 1660258976 4498 nil nil nil 2322 138 144 34 2 2386 #createAt:extent: 34 2 498 1 1 498 1019 41 6608 2386 #text: 34 1 8 '
' 6608 2546 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 253 1 0 0 20 0 0 0] 8 #() 2608 nil 27 nil nil nil 410 ##(Smalltalk.ScintillaView) 34 50 nil 6528 34 2 8 1140920580 1025 6912 4802 nil false 4848 nil 480 nil 7 nil nil nil 6912 nil 8 1682100671 4498 nil nil 11 nil 170 192 34 12 #lineNumber 4930 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 4930 77 466 #gray 466 #white 1 nil nil nil nil #callTip nil nil nil #indentGuide 4930 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #normal 4930 1 nil nil 1 nil nil nil nil #normal nil nil nil #whitespace 4930 3 466 #teal nil 1 nil nil nil nil #whitespace nil nil nil #diff 4930 5 466 #black 466 #yellow 3 nil nil nil nil #diff nil 1401 nil 34 256 7136 7152 7184 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 7056 nil nil nil 7120 7072 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 5138 5168 170 192 34 2 #default 5218 1 nil nil nil 6912 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 832 nil 170 176 832 9215 nil nil nil nil 466 #silver nil nil 65 nil nil nil 5296 3 170 192 34 2 #container 7024 nil nil nil nil 1 nil 170 192 34 2 #diff 5378 1 6912 5408 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 4930 1027 5090 60239 5090 31326207 1 nil nil nil nil #Warning nil nil nil #Error 4930 1031 5090 335 5090 31317503 1 nil nil nil nil #Error nil nil nil #Notification 4930 1029 nil 5090 31185883 1 nil nil nil nil #Notification nil nil nil nil 2322 138 144 34 8 2386 #createAt:extent: 34 2 498 1 41 498 1019 1051 6912 2386 #textLimit: 8 #(1073741823) 6912 2386 #caretPeriod: 8 #(530) 6912 2386 #wordWrap: 8 #(true) 6912 2386 #margins: 34 1 34 3 5842 1 6912 49 3 nil nil nil nil 5842 3 6912 1 nil nil 67108863 nil nil 5842 5 6912 1 nil nil nil nil nil 6912 2386 #canHScroll: 8 #(false) 6912 2386 #maxCompletionListHeight: 8 #(9) 6912 2386 #edgeColumn: 8 #(1) 6912 2546 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 20 0 0 0 253 1 0 0 33 2 0 0] 8 #() 2608 nil 29 170 192 34 4 6608 8 'afterTitle' 6912 8 'after' nil 2322 138 144 34 1 2386 #createAt:extent: 34 2 498 1029 1 498 1019 1091 6528 2546 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 2 2 0 0 0 0 0 0 255 3 0 0 33 2 0 0] 34 2 6912 6608 2608 nil 27 2608 nil 27 170 192 34 2 3744 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 882 nil true 34 4 930 1 962 #selectUpper 8 'Select &upper' 1 1 nil nil nil 930 1 962 #selectLower 8 'Select &lower' 1 1 nil nil nil 1106 4097 930 1 962 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 32033 nil nil 882 nil true 34 3 930 1 962 #character 8 '&Character' 1 1 nil nil nil 930 1 962 #word 8 '&Word' 1 1 nil nil nil 930 1 962 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 32041 nil nil 882 nil true 34 1 930 1 962 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 32045 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 2322 138 144 34 3 2386 #createAt:extent: 34 2 498 1 1 498 2079 1123 3648 2386 #text: 34 1 8 'Differences' 3648 2386 #updateMenuBar 832 3648 2546 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 15 4 0 0 49 2 0 0] 34 1 3744 2608 nil 27 2626 2672 1 2688 1 2704 1 2720 1 170 192 832 nil 2322 138 144 34 1 2386 #createAt:extent: 34 2 498 1 1 498 2079 1123 3536 2546 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 15 4 0 0 49 2 0 0] 34 1 3648 2608 nil 27 2608 nil 27 2946 2045 1563 true 170 192 832 nil 8322 nil true 34 1 882 nil true 34 2 930 1 962 #refresh 8 'Refresh' 1 1 nil nil nil 930 1025 962 #flipIdenticalSource 8 'Include Methods With Identical Source' 1 1 nil nil nil 8 'Jadeite' nil 134217729 nil nil 32025 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 2322 138 144 34 2 2386 #createAt:extent: 34 2 498 7679 21 498 2111 1841 416 2386 #updateMenuBar 832 416 2546 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 30 19 0 0 162 3 0 0] 34 3 592 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 9696 nil 480 nil 519 nil nil nil 3314 9696 nil 1 #left nil nil nil 3344 3360 nil 3344 nil 2322 138 144 34 1 2386 #createAt:extent: 34 2 498 1 591 498 2079 11 9696 2546 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 39 1 0 0 15 4 0 0 44 1 0 0] 8 #() 2608 nil 27 2976 2608 nil 27 )!

showOn: aModel name: aString
	| browser |
	browser := self on: aModel.
	browser name: aString.
	^browser
		createView: self defaultView;
		showShell;
		yourself! !
!JadeiteChangesBrowser class categoriesFor: #resource_Default_view!public!resources-views! !
!JadeiteChangesBrowser class categoriesFor: #showOn:name:!public! !

