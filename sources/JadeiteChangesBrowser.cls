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

browseChangedThing
	| selection shell classService modifiedSelector |
	selection := operationListPresenter selectionOrNil.
	selection isNil ifTrue: [^MessageBox notify: 'Nothing to browse'].
	selection isRemoval ifTrue: [^MessageBox notify: 'Cannot browse a removed item'].
	
	[classService := RowanClassService named: selection className.
	shell := JadeiteBrowser showOnSession: gciSession.
	shell currentCard updateServices: (Array with: classService)]
			on: Error
			do: 
				[:ex |
				shell destroy.
				MessageBox notify: 'The change you have selected cannot be browsed'].
	modifiedSelector := self modifiedSelectorForBrowsing: selection.
	shell currentCard
		updateAfterFindClass: classService;
		findMethod: modifiedSelector asSymbol.
	^shell!

browseImplementors
	| selection shell methodListPresenter changedMethod modifiedSelector |
	selection := operationListPresenter selectionOrNil.
	selection isNil ifTrue: [^MessageBox notify: 'Nothing to browse'].
	selection isMethod ifFalse: [^MessageBox notify: 'Cannot browse implementors of a non-method'].
	modifiedSelector := self modifiedSelectorForBrowsing: selection.
	
	[shell := JadePresenter browseImplementorsOf: modifiedSelector session: self gciSession.
	methodListPresenter := shell primaryPresenter methodListPresenter methodListPresenter.
	changedMethod := methodListPresenter list
				detect: [:methodService | methodService className = selection className]
				ifNone: [^shell].
	methodListPresenter selection: changedMethod]
			on: Error
			do: 
				[:ex |
				shell destroy.
				MessageBox notify: 'The change you have selected cannot be browsed'].
	^shell!

browseSenders
	| selection shell modifiedSelector |
	selection := operationListPresenter selectionOrNil.
	selection isNil ifTrue: [^MessageBox notify: 'Nothing to browse'].
	selection isMethod ifFalse: [^MessageBox notify: 'Cannot browse senders of a non-method'].
	modifiedSelector := self modifiedSelectorForBrowsing: selection.
	[shell := JadePresenter browseSendersOf: modifiedSelector session: self gciSession] on: Error
		do: 
			[:ex |
			shell destroy.
			MessageBox notify: 'The change you have selected cannot be browsed'].
	^shell!

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

modifiedSelectorForBrowsing: selection
	| substrings |
	substrings := selection selector subStrings.
	^substrings isEmpty ifTrue: [String new] ifFalse: [substrings first asSymbol]!

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
		beforeTitle: 'Disk Equivalent';
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
	diffsPresenter beforePresenter value: String new.	"resetting value first seems to be necessary to clear highlighting even though indicators get cleared"
	diffsPresenter afterPresenter value: String new.
	diffsPresenter
		clearDiffs;
		afterTitle: afterTitle;
		compare: operation obsoletionMemo with: operation modificationMemo.
	diffsPresenter view invalidate.
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
!JadeiteChangesBrowser categoriesFor: #additionalAccelerators!accessing!constants!public! !
!JadeiteChangesBrowser categoriesFor: #afterTitle:!public! !
!JadeiteChangesBrowser categoriesFor: #browseChangedThing!menu handlers!public! !
!JadeiteChangesBrowser categoriesFor: #browseImplementors!menu handlers!public! !
!JadeiteChangesBrowser categoriesFor: #browseSenders!menu handlers!public! !
!JadeiteChangesBrowser categoriesFor: #createComponents!public! !
!JadeiteChangesBrowser categoriesFor: #createSchematicWiring!initialization!public! !
!JadeiteChangesBrowser categoriesFor: #flipIdenticalSource!initialization!public! !
!JadeiteChangesBrowser categoriesFor: #initialize!initialization!public! !
!JadeiteChangesBrowser categoriesFor: #modifiedSelectorForBrowsing:!menu handlers support!public! !
!JadeiteChangesBrowser categoriesFor: #name!accessing!public! !
!JadeiteChangesBrowser categoriesFor: #name:!accessing!public! !
!JadeiteChangesBrowser categoriesFor: #operationSelected!public! !
!JadeiteChangesBrowser categoriesFor: #operationsList!public! !
!JadeiteChangesBrowser categoriesFor: #queryCommand:!menu handlers!public! !
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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 2111 1501 549 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 592 nil nil nil 7 nil nil nil 592 530 170 176 8 #() false 170 192 688 nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 1 485 498 2079 899 592 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 242 0 0 0 15 4 0 0 179 2 0 0] 34 2 410 ##(Smalltalk.Splitter) 34 12 nil 592 34 2 8 1140850688 1 928 nil 480 nil 519 nil nil nil 1510470 1 ##(Smalltalk.DraggableViewInteractor) 928 nil 1 #left nil nil nil 498 1 1 498 9 9 nil 1024 nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 585 1 498 11 557 928 866 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 36 1 0 0 0 0 0 0 41 1 0 0 22 1 0 0] 8 #() 498 193 193 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 592 34 2 8 1140850688 131073 1232 nil nil nil 7 nil nil nil 1232 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ShellView) 34 27 nil 1232 34 2 8 1083113472 131073 1360 nil 480 nil 551 nil nil nil 1360 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 1360 34 2 8 1140850688 131073 1456 nil 480 nil 7 265030 4 ##(Smalltalk.Menu) nil true 34 5 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 1570 1 1602 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 1570 1 1602 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 1570 1 1602 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 1570 1 1602 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 1456 530 170 176 688 false 170 192 688 nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 1 1 498 2047 867 1456 786 #contextMenu: 34 1 1536 1456 866 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 3 0 0 177 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 1456 34 2 8 1140850688 131073 2096 nil 480 nil 7 nil nil nil 2096 1426 1 1 410 ##(Smalltalk.StaticText) 34 16 nil 2096 34 2 8 1140850945 262145 2176 nil nil nil 7 nil nil nil 2176 nil 8 1725008544 852486 ##(Smalltalk.NullConverter) nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 1 1 498 1019 41 2176 786 #text: 34 1 8 '
' 2176 866 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 253 1 0 0 20 0 0 0] 8 #() 1216 nil 27 nil nil nil 410 ##(Smalltalk.ScintillaView) 34 50 nil 2096 34 2 8 1140920580 1025 2496 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 480 nil 7 nil nil nil 2496 nil 8 1683109469 2258 nil nil 11 nil 170 192 34 12 #callTip 1182790 1 ##(Smalltalk.ScintillaTextStyle) 77 466 #gray 466 #white 1 nil nil nil nil #callTip nil nil nil #indentGuide 2690 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 2690 3 466 #teal nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 2690 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #normal 2690 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 2690 5 nil 196934 1 ##(Smalltalk.RGB) 16908287 3 nil nil nil nil #diff nil 1401 nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 2496 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 688 nil 170 176 688 9215 nil nil nil nil 466 #silver nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 2656 nil nil nil nil 1 nil 170 192 34 2 #diff 1510470 3 ##(Smalltalk.ScintillaIndicatorStyle) 1 2496 466 #yellow 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 2690 1027 2850 60239 2850 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2690 1031 2850 335 2850 31317503 1 nil nil nil nil #Error nil nil nil #Notification 2690 1029 nil 2850 31185883 1 nil nil nil nil #Notification nil nil nil nil 722 138 144 34 8 786 #createAt:extent: 34 2 498 1 41 498 1019 827 2496 786 #caretPeriod: 8 #(530) 2496 786 #wordWrap: 8 #(true) 2496 786 #margins: 34 1 34 3 985158 3 ##(Smalltalk.ScintillaMargin) 1 2496 49 3 nil nil nil nil 3554 3 2496 1 nil nil 67108863 nil nil 3554 5 2496 1 nil nil nil nil nil 2496 786 #canHScroll: 8 #(false) 2496 786 #targetRange: 34 1 525062 ##(Smalltalk.Interval) 1 -1 3 2496 786 #maxCompletionListHeight: 8 #(9) 2496 786 #edgeColumn: 8 #(1) 2496 866 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 20 0 0 0 253 1 0 0 177 1 0 0] 8 #() 1216 nil 29 170 192 34 4 2496 8 'before' 2176 8 'beforeTitle' nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 1 1 498 1019 867 2096 866 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 253 1 0 0 177 1 0 0] 34 2 2496 2176 1216 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 1456 34 2 8 1140850688 1 4048 nil 2850 66047 nil 519 nil nil nil 994 4048 nil 1 #left nil nil nil 1024 1040 nil 1024 nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 1019 1 498 11 867 4048 866 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 253 1 0 0 0 0 0 0 2 2 0 0 177 1 0 0] 8 #() 1216 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 1456 34 2 8 1140850688 131073 4304 nil 480 nil 7 nil nil nil 4304 1426 1 1 410 ##(Smalltalk.StaticText) 34 16 nil 4304 34 2 8 1140850945 262145 4384 nil nil nil 7 nil nil nil 4384 nil 8 1725008544 2258 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 1 1 498 1019 41 4384 786 #text: 34 1 8 '
' 4384 866 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 253 1 0 0 20 0 0 0] 8 #() 1216 nil 27 nil nil nil 410 ##(Smalltalk.ScintillaView) 34 50 nil 4304 34 2 8 1140920580 1025 4688 2562 nil false 2608 nil 480 nil 7 nil nil nil 4688 nil 8 1683109469 2258 nil nil 11 nil 170 192 34 12 #callTip 2690 77 2720 2736 1 nil nil nil nil #callTip nil nil nil #indentGuide 2690 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 2690 3 2784 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 2690 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #normal 2690 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 2690 5 466 #black 3152 3 nil nil nil nil #diff nil 1401 nil nil 2882 2912 170 192 34 2 #default 2962 1 nil nil nil 4688 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 688 nil 170 176 688 9215 nil nil nil nil 3024 nil nil 65 nil nil nil 3040 3 170 192 34 2 #container 4800 nil nil nil nil 1 nil 170 192 34 2 #diff 3122 1 4688 3152 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 2690 1027 2850 60239 2850 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2690 1031 2850 335 2850 31317503 1 nil nil nil nil #Error nil nil nil #Notification 2690 1029 nil 2850 31185883 1 nil nil nil nil #Notification nil nil nil nil 722 138 144 34 8 786 #createAt:extent: 34 2 498 1 41 498 1019 827 4688 786 #caretPeriod: 8 #(530) 4688 786 #wordWrap: 8 #(true) 4688 786 #margins: 34 1 34 3 3554 1 4688 49 3 nil nil nil nil 3554 3 4688 1 nil nil 67108863 nil nil 3554 5 4688 1 nil nil nil nil nil 4688 786 #canHScroll: 8 #(false) 4688 786 #targetRange: 34 1 3682 1 -1 3 4688 786 #maxCompletionListHeight: 8 #(9) 4688 786 #edgeColumn: 8 #(1) 4688 866 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 20 0 0 0 253 1 0 0 177 1 0 0] 8 #() 1216 nil 29 170 192 34 4 4384 8 'afterTitle' 4688 8 'after' nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 1029 1 498 1019 867 4304 866 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 2 2 0 0 0 0 0 0 255 3 0 0 177 1 0 0] 34 2 4688 4384 1216 nil 27 1216 nil 27 170 192 34 2 1456 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 1522 nil true 34 4 1570 1 1602 #selectUpper 8 'Select &upper' 1 1 nil nil nil 1570 1 1602 #selectLower 8 'Select &lower' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 1570 1 1602 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 31457 nil nil 1522 nil true 34 3 1570 1 1602 #character 8 '&Character' 1 1 nil nil nil 1570 1 1602 #word 8 '&Word' 1 1 nil nil nil 1570 1 1602 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 31465 nil nil 1522 nil true 34 1 1570 1 1602 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 31469 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 1 1 498 2079 899 1360 786 #text: 34 1 8 'Differences' 1360 866 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 15 4 0 0 193 1 0 0] 34 1 1456 1216 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 6834 #fixedParentRight 1 6834 #fixedParentTop 1 6834 #fixedParentBottom 1 170 192 688 nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 1 1 498 2079 899 1232 866 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 15 4 0 0 193 1 0 0] 34 1 1360 1216 nil 27 1216 nil 27 524806 ##(Smalltalk.Fraction) 2045 1563 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 7120 nil nil nil 7 nil nil nil 7120 1298 170 176 34 2 410 ##(Smalltalk.ListView) 34 45 nil 7120 34 2 8 1409355853 1025 7232 590662 2 ##(Smalltalk.ListModel) 138 144 688 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 1522 nil true 34 5 1570 1 1602 #browseChangedThing 8 'Browse' 1 1 nil nil nil 1570 1 1602 #browseImplementors 8 'Browse Implementors' 1 1 nil nil nil 1570 1 1602 #browseSenders 8 'Browse Senders' 1 1 nil nil nil 6194 4097 1570 1 1602 #revert 8 'Revert' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 7232 nil 8 1724901488 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 4 920646 5 ##(Smalltalk.ListViewColumn) 8 'Type' 301 #left 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 7808 8 'doIt' 8 '[:each | each typeString]' 8 #[30 105 226 0 106] #typeString 7824 7 257 nil 7810 0 nil 7842 2 1 7648 8 'doIt' 8 '[:x :y | x typeString <= y typeString]' 8 #[30 105 226 0 226 32 130 106] #typeString 7920 7 513 nil nil nil 7232 nil 1 7810 0 nil 7842 5 1 7808 8 'doIt' 8 '[:each | each className, ''>>'', each selector]' 8 #[33 105 226 0 30 178 226 3 178 106] #className 8 '>>' #, #selector 8000 7 257 nil nil 7762 8 'Class' 401 #left 7810 0 nil 7842 2 1 7648 8 'doIt' 8 '[:each | each className]' 8 #[30 105 226 0 106] #className 8128 7 257 nil 7810 0 nil 7842 2 1 106 8 'Dolphin' 8 'SortedCollection' 8 'doIt' 8 '[:x :y | x className <= y className]' 8 #[30 105 226 0 226 32 130 106] #className 8208 7 513 nil nil nil 7232 nil 1 nil nil 7762 8 'Selector' 401 #left 7810 0 nil 7842 2 1 112 8 'doIt' 8 '[:each | each selector]' 8 #[30 105 226 0 106] #selector 8368 7 257 nil 7810 0 nil 7842 2 1 7808 8 'doIt' 8 '[:x :y | x selector <= y selector]' 8 #[30 105 226 0 226 32 130 106] #selector 8448 7 513 nil nil nil 7232 nil 1 nil nil 7762 8 'Detail' 971 #left 7810 0 nil 7842 2 1 7648 8 'doIt' 8 '[:each | each detailsString]' 8 #[30 105 226 0 106] #detailsString 8560 7 257 nil 7810 0 nil 7842 2 1 7808 8 'doIt' 8 '[:x :y | x detailsString <= y detailsString]' 8 #[30 105 226 0 226 32 130 106] #detailsString 8640 7 513 nil nil nil 7232 nil 3 nil nil #report 8 #() nil 133217 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 722 138 144 34 3 786 #createAt:extent: 34 2 498 1 1 498 2079 475 7232 786 #contextMenu: 34 1 7376 7232 786 #text: 34 1 8 'Type' 7232 866 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 15 4 0 0 237 0 0 0] 8 #() 1216 nil 35 6802 6848 1 6864 1 6880 1 6896 1 170 192 34 2 7232 8 'operationList' nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 1 1 498 2079 475 7120 866 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 15 4 0 0 237 0 0 0] 34 1 7232 1216 nil 27 7090 1081 1563 true 170 192 688 nil 6018 nil true 34 1 1522 nil true 34 2 1570 1 1602 #refresh 8 'Refresh' 1 1 nil nil nil 1570 1025 1602 #flipIdenticalSource 8 'Include Methods With Identical Source' 1 1 nil nil nil 8 'Jadeite' nil 134217729 nil nil 31475 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 7545 21 498 2111 1501 416 866 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 188 14 0 0 10 0 0 0 219 18 0 0 248 2 0 0] 34 3 7120 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 9584 nil 480 nil 519 nil nil nil 994 9584 nil 1 #left nil nil nil 1024 1040 nil 1024 nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 1 475 498 2079 11 9584 866 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 237 0 0 0 15 4 0 0 242 0 0 0] 8 #() 1216 nil 27 592 1216 nil 27 )!

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

