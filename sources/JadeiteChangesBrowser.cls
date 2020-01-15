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
	operationListPresenter list: operations!

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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 2111 1841 551 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 608 nil nil nil 7 nil nil nil 608 546 170 176 8 #() false 170 192 704 nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 1 601 514 2079 1123 608 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 44 1 0 0 15 4 0 0 93 3 0 0] 34 2 410 ##(Smalltalk.Splitter) 34 12 nil 608 34 2 8 1140850688 1 944 nil 466 8 4278190080 nil 519 nil nil nil 944 738 138 144 34 1 802 #createAt:extent: 34 2 514 585 1 514 11 557 944 882 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 36 1 0 0 0 0 0 0 41 1 0 0 22 1 0 0] 8 #() 514 193 193 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 608 34 2 8 1140850688 131073 1216 nil nil nil 7 nil nil nil 1216 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ShellView) 34 27 nil 1216 34 2 8 1083113472 131073 1344 nil 466 8 4278190080 nil 551 nil nil nil 1344 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 1344 34 2 8 1140850688 131073 1472 nil 466 1424 nil 7 265030 4 ##(Smalltalk.Menu) nil true 34 5 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 1602 1 1634 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 1602 1 1634 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 1602 1 1634 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 1602 1 1634 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 1472 546 170 176 704 false 170 192 704 nil 738 138 144 34 2 802 #createAt:extent: 34 2 514 1 1 514 2047 1091 1472 802 #contextMenu: 34 1 1568 1472 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 3 0 0 33 2 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 1472 34 2 8 1140850688 131073 2128 nil 466 1424 nil 7 nil nil nil 2128 1442 1 1 410 ##(Smalltalk.StaticText) 34 16 nil 2128 34 2 8 1140850945 262145 2224 nil nil nil 7 nil nil nil 2224 nil 8 1663077024 852486 ##(Smalltalk.NullConverter) nil nil nil 738 138 144 34 2 802 #createAt:extent: 34 2 514 1 1 514 1019 41 2224 802 #text: 34 1 8 '
' 2224 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 253 1 0 0 20 0 0 0] 8 #() 1200 nil 27 nil nil nil 410 ##(Smalltalk.ScintillaView) 34 50 nil 2128 34 2 8 1140920580 1025 2544 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 466 1424 nil 7 nil nil nil 2544 nil 8 4294906429 2306 nil nil 11 nil 170 192 34 12 #indentGuide 1182790 1 ##(Smalltalk.ScintillaTextStyle) 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 2754 3 786694 ##(Smalltalk.IndexedColor) 33554445 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 2754 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 2754 77 2802 33554457 2802 33554471 1 nil nil nil nil #callTip nil nil nil #normal 2754 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 2754 5 nil 196934 1 ##(Smalltalk.RGB) 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 2896 2784 2912 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 2832 nil nil nil 2768 nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 1641542 1 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 2544 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 704 nil 170 176 704 9215 nil nil nil nil 2802 33554447 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 2720 nil nil nil nil 1 nil 170 192 34 6 8 'indicator2' 1510470 2 ##(Smalltalk.ScintillaIndicatorStyle) 5 2544 511 1 false nil nil nil nil nil nil nil 8 'indicator0' 3234 1 2544 33554459 13 false nil nil nil nil nil nil nil 8 'indicator1' 3234 3 2544 33423361 5 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 2754 1029 nil 2930 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 2754 1027 2930 60239 2930 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2754 1031 2930 335 2930 31317503 1 nil nil nil nil #Error nil nil nil nil 738 138 144 34 7 802 #createAt:extent: 34 2 514 1 41 514 1019 1051 2544 802 #modificationEventMask: 8 #(4607) 2544 802 #caretPeriod: 8 #(530) 2544 802 #wordWrap: 8 #(true) 2544 802 #margins: 34 1 34 3 985158 2 ##(Smalltalk.ScintillaMargin) 1 2544 49 3 nil nil nil nil 3746 3 2544 1 nil nil 67108863 nil nil 3746 5 2544 1 nil nil nil nil nil 2544 802 #canHScroll: 8 #(false) 2544 802 #maxCompletionListHeight: 8 #(9) 2544 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 20 0 0 0 253 1 0 0 33 2 0 0] 8 #() 1200 nil 29 170 192 34 4 2544 8 'before' 2224 8 'beforeTitle' nil 738 138 144 34 1 802 #createAt:extent: 34 2 514 1 1 514 1019 1091 2128 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 253 1 0 0 33 2 0 0] 34 2 2544 2224 1200 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 1472 34 2 8 1140850688 1 4144 nil 2930 66047 nil 519 nil nil nil 4144 738 138 144 34 1 802 #createAt:extent: 34 2 514 1019 1 514 11 1091 4144 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 253 1 0 0 0 0 0 0 2 2 0 0 33 2 0 0] 8 #() 1200 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 1472 34 2 8 1140850688 131073 4384 nil 466 1424 nil 7 nil nil nil 4384 1442 1 1 410 ##(Smalltalk.StaticText) 34 16 nil 4384 34 2 8 1140850945 262145 4480 nil nil nil 7 nil nil nil 4480 nil 8 1663077024 2306 nil nil nil 738 138 144 34 2 802 #createAt:extent: 34 2 514 1 1 514 1019 41 4480 802 #text: 34 1 8 '
' 4480 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 253 1 0 0 20 0 0 0] 8 #() 1200 nil 27 nil nil nil 410 ##(Smalltalk.ScintillaView) 34 50 nil 4384 34 2 8 1140920580 1025 4784 2610 nil false 2656 nil 466 1424 nil 7 nil nil nil 4784 nil 8 4294906429 2306 nil nil 11 nil 170 192 34 12 #indentGuide 2754 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 2754 3 2816 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 2754 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 2754 77 2864 2880 1 nil nil nil nil #callTip nil nil nil #normal 2754 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 2754 5 nil 2930 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 5008 4960 5024 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 4976 nil nil nil 4944 nil nil 2978 3008 170 192 34 2 #default 3058 1 nil nil nil 4784 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 704 nil 170 176 704 9215 nil nil nil nil 3120 nil nil 65 nil nil nil 3136 3 170 192 34 2 #container 4912 nil nil nil nil 1 nil 170 192 34 6 8 'indicator1' 3234 3 4784 33423361 5 false nil nil nil nil nil nil nil 8 'indicator2' 3234 5 4784 511 1 false nil nil nil nil nil nil nil 8 'indicator0' 3234 1 4784 33554459 13 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 2754 1029 nil 2930 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 2754 1027 2930 60239 2930 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2754 1031 2930 335 2930 31317503 1 nil nil nil nil #Error nil nil nil nil 738 138 144 34 7 802 #createAt:extent: 34 2 514 1 41 514 1019 1051 4784 802 #modificationEventMask: 8 #(4607) 4784 802 #caretPeriod: 8 #(530) 4784 802 #wordWrap: 8 #(true) 4784 802 #margins: 34 1 34 3 3746 1 4784 49 3 nil nil nil nil 3746 3 4784 1 nil nil 67108863 nil nil 3746 5 4784 1 nil nil nil nil nil 4784 802 #canHScroll: 8 #(false) 4784 802 #maxCompletionListHeight: 8 #(9) 4784 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 20 0 0 0 253 1 0 0 33 2 0 0] 8 #() 1200 nil 29 170 192 34 4 4784 8 'after' 4480 8 'afterTitle' nil 738 138 144 34 1 802 #createAt:extent: 34 2 514 1029 1 514 1019 1091 4384 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 2 2 0 0 0 0 0 0 255 3 0 0 33 2 0 0] 34 2 4784 4480 1200 nil 27 1200 nil 27 170 192 34 2 1472 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 1554 nil true 34 4 1602 1 1634 #selectUpper 8 'Select &upper' 1 1 nil nil nil 1602 1 1634 #selectLower 8 'Select &lower' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 1602 1 1634 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 30135 nil nil 1554 nil true 34 3 1602 1 1634 #character 8 '&Character' 1 1 nil nil nil 1602 1 1634 #word 8 '&Word' 1 1 nil nil nil 1602 1 1634 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 30143 nil nil 1554 nil true 34 1 1602 1 1634 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 30147 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 738 138 144 34 3 802 #createAt:extent: 34 2 514 1 1 514 2079 1123 1344 802 #text: 34 1 8 'Differences' 1344 802 #updateMenuBar 704 1344 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 15 4 0 0 49 2 0 0] 34 1 1472 1200 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 7010 #fixedParentRight 1 7010 #fixedParentTop 1 7010 #fixedParentBottom 1 170 192 704 nil 738 138 144 34 1 802 #createAt:extent: 34 2 514 1 1 514 2079 1123 1216 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 15 4 0 0 49 2 0 0] 34 1 1344 1200 nil 27 1200 nil 27 524806 ##(Smalltalk.Fraction) 2045 1563 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 7296 nil nil nil 7 nil nil nil 7296 1282 170 176 34 2 410 ##(Smalltalk.ListView) 34 30 nil 7296 34 2 8 1409355853 1025 7408 590662 2 ##(Smalltalk.ListModel) 138 144 704 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 466 8 4278190080 nil 7 1554 nil true 34 5 1602 1 1634 #browseChangedThing 8 'Browse in Project Browser' 1 1 nil nil nil 1602 1 1634 #browseImplementors 8 'Browse Implementors' 1 1 nil nil nil 1602 1 1634 #browseSenders 8 'Browse Senders' 1 1 nil nil nil 6354 4097 1602 1 1634 #revert 8 'Revert' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 7408 nil 8 4294906401 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 4 920646 5 ##(Smalltalk.ListViewColumn) 8 'Type' 301 #left 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 8016 8 'doIt' 8 '[:each | each typeString]' 8 #[30 105 226 0 106] #typeString 8032 7 257 nil 8018 0 nil 8050 2 1 7856 8 'doIt' 8 '[:x :y | x typeString <= y typeString]' 8 #[30 105 226 0 226 32 130 106] #typeString 8128 7 513 nil nil nil 7408 nil 1 8018 0 nil 8050 5 1 8016 8 'doIt' 8 '[:each | each className, ''>>'', each selector]' 8 #[33 105 226 0 30 178 226 3 178 106] #className 8 '>>' #, #selector 8208 7 257 nil nil 7970 8 'Class' 401 #left 8018 0 nil 8050 2 1 7856 8 'doIt' 8 '[:each | each className]' 8 #[30 105 226 0 106] #className 8336 7 257 nil 8018 0 nil 8050 2 1 106 8 'Dolphin' 8 'SortedCollection' 8 'doIt' 8 '[:x :y | x className <= y className]' 8 #[30 105 226 0 226 32 130 106] #className 8416 7 513 nil nil nil 7408 nil 1 nil nil 7970 8 'Selector' 401 #left 8018 0 nil 8050 2 1 112 8 'doIt' 8 '[:each | each selector]' 8 #[30 105 226 0 106] #selector 8576 7 257 nil 8018 0 nil 8050 2 1 8016 8 'doIt' 8 '[:x :y | x selector <= y selector]' 8 #[30 105 226 0 226 32 130 106] #selector 8656 7 513 nil nil nil 7408 nil 1 nil nil 7970 8 'Detail' 971 #left 8018 0 nil 8050 2 1 7856 8 'doIt' 8 '[:each | each detailsString]' 8 #[30 105 226 0 106] #detailsString 8768 7 257 nil 8018 0 nil 8050 2 1 8016 8 'doIt' 8 '[:x :y | x detailsString <= y detailsString]' 8 #[30 105 226 0 226 32 130 106] #detailsString 8848 7 513 nil nil nil 7408 nil 3 nil nil #report 704 nil 133217 nil 34 4 nil nil 514 1 1 nil 738 138 144 34 3 802 #createAt:extent: 34 2 514 1 1 514 2079 591 7408 802 #contextMenu: 34 1 7584 7408 802 #text: 34 1 8 'Type' 7408 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 15 4 0 0 39 1 0 0] 8 #() 1200 nil 27 6978 7024 1 7040 1 7056 1 7072 1 170 192 34 2 7408 8 'operationList' nil 738 138 144 34 1 802 #createAt:extent: 34 2 514 1 1 514 2079 591 7296 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 15 4 0 0 39 1 0 0] 34 1 7408 1200 nil 27 7266 1081 1563 true 170 192 704 nil 6178 nil true 34 1 1554 nil true 34 2 1602 1 1634 #refresh 8 'Refresh' 1 1 nil nil nil 1602 1025 1634 #flipIdenticalSource 8 'Include Methods With Identical Source' 1 1 nil nil nil 8 'Jadeite' nil 134217729 nil nil 30127 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 738 138 144 34 2 802 #createAt:extent: 34 2 514 7679 21 514 2111 1841 416 802 #updateMenuBar 704 416 882 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 30 19 0 0 162 3 0 0] 34 3 7296 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 9824 nil 466 1024 nil 519 nil nil nil 9824 738 138 144 34 1 802 #createAt:extent: 34 2 514 1 591 514 2079 11 9824 882 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 39 1 0 0 15 4 0 0 44 1 0 0] 8 #() 1200 nil 27 608 1200 nil 27 )!

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

