"Filed out from Dolphin Smallalk"!

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
	
	[| className |
	className := selection className.
	(className last: 6) = ' class'
		ifTrue: [className := selection className copyFrom: 1 to: selection className size - 6].
	classService := RowanClassService named: className.
	shell := JadeiteBrowser showOnSession: gciSession.
	shell currentCard updateAfterFindClass: classService.
	selection isMethodModification
		ifTrue: 
			[selection modification classIsMeta ifTrue: [shell currentCard selectClassTab].
			shell currentCard findMethod: selection modification selector]]
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
!JadeiteChangesBrowser categoriesForMethods!
additionalAccelerators!accessing!constants!public! !
afterTitle:!public! !
browseChangedThing!menu handlers!public! !
browseImplementors!menu handlers!public! !
browseSenders!menu handlers!public! !
createComponents!public! !
createSchematicWiring!initialization!public! !
flipIdenticalSource!initialization!public! !
initialize!initialization!public! !
modifiedSelectorForBrowsing:!menu handlers support!public! !
name!accessing!public! !
name:!accessing!public! !
operationSelected!public! !
operationsList!public! !
queryCommand:!menu handlers!public! !
refresh!menu handlers!public! !
refreshIdenticalSource!menu handlers!public! !
revert!menu handlers!public! !
shellName!overrides!private! !
showNoComparison!public! !
!

!JadeiteChangesBrowser class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 2111 1501 549 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 592 nil nil nil 7 nil nil nil 592 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ListView) 34 45 nil 592 34 2 8 1409355853 1025 720 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 265030 4 ##(Smalltalk.Menu) nil true 34 5 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #browseChangedThing 8 'Browse' 1 1 nil nil nil 930 1 962 #browseImplementors 8 'Browse Implementors' 1 1 nil nil nil 930 1 962 #browseSenders 8 'Browse Senders' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 930 1 962 #revert 8 'Revert' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 720 nil 8 1607618784 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 5 1 1296 8 'doIt' 8 '[:drawingThing | Transcript cr; print: drawingThing; flush. drawingThing]' 8 #[33 105 45 100 159 76 17 178 97 161 73 106] 983558 ##(Smalltalk.VariableBinding) #Transcript 1114638 ##(Smalltalk.STBSingletonProxy) ##(Smalltalk.TranscriptShell) #current #cr #print: #flush 1312 7 257 nil nil nil nil 138 144 34 4 920646 5 ##(Smalltalk.ListViewColumn) 8 'Type' 301 #left 1298 0 nil 1330 2 1 1296 8 'doIt' 8 '[:each | each typeString]' 8 #[30 105 226 0 106] #typeString 1552 7 257 nil 1298 0 nil 1330 2 1 1216 8 'doIt' 8 '[:x :y | x typeString <= y typeString]' 8 #[30 105 226 0 226 32 130 106] #typeString 1632 7 513 nil nil nil 720 nil 1 1298 0 nil 1330 5 1 1296 8 'doIt' 8 '[:each | each className, ''>>'', each selector]' 8 #[33 105 226 0 30 178 226 3 178 106] #className 8 '>>' #, #selector 1712 7 257 nil 1298 0 nil 1330 7 1 1296 8 'doIt' 8 '[:drawingThing | 
drawingThing item reverted ifTrue:[drawingThing forecolor: Color red]]' 8 #[34 105 226 0 159 122 17 47 161 180 106 60 106] #item #reverted 1410 #Color 464 #red #forecolor: 1808 #ifTrue: 7 257 nil 1506 8 'Class' 401 #left 1298 0 nil 1330 2 1 1216 8 'doIt' 8 '[:each | each className]' 8 #[30 105 226 0 106] #className 1936 7 257 nil 1298 0 nil 1330 2 1 106 8 'Dolphin' 8 'SortedCollection' 8 'doIt' 8 '[:x :y | x className <= y className]' 8 #[30 105 226 0 226 32 130 106] #className 2016 7 513 nil nil nil 720 nil 1 nil nil 1506 8 'Selector' 401 #left 1298 0 nil 1330 2 1 112 8 'doIt' 8 '[:each | each selector]' 8 #[30 105 226 0 106] #selector 2176 7 257 nil 1298 0 nil 1330 2 1 1296 8 'doIt' 8 '[:x :y | x selector <= y selector]' 8 #[30 105 226 0 226 32 130 106] #selector 2256 7 513 nil nil nil 720 nil 1 nil nil 1506 8 'Detail' 971 #left 1298 0 nil 1330 2 1 1216 8 'doIt' 8 '[:each | each detailsString]' 8 #[30 105 226 0 106] #detailsString 2368 7 257 nil 1298 0 nil 1330 2 1 1296 8 'doIt' 8 '[:x :y | x detailsString <= y detailsString]' 8 #[30 105 226 0 226 32 130 106] #detailsString 2448 7 513 nil nil nil 720 nil 3 nil nil #report 8 #() nil 133217 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 1 1 498 2079 475 720 2610 #contextMenu: 34 1 896 720 2610 #text: 34 1 8 'Type' 720 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 15 4 0 0 237 0 0 0] 8 #() 498 193 193 nil 35 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 2882 #fixedParentRight 1 2882 #fixedParentTop 1 2882 #fixedParentBottom 1 170 192 34 2 720 8 'operationList' nil 2546 138 144 34 1 2610 #createAt:extent: 34 2 498 1 1 498 2079 475 592 2770 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 15 4 0 0 237 0 0 0] 34 1 720 2832 nil 27 524806 ##(Smalltalk.Fraction) 1081 1563 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 3200 nil nil nil 7 nil nil nil 3200 530 170 176 832 false 170 192 832 nil 2546 138 144 34 1 2610 #createAt:extent: 34 2 498 1 485 498 2079 899 3200 2770 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 242 0 0 0 15 4 0 0 179 2 0 0] 34 2 410 ##(Smalltalk.Splitter) 34 12 nil 3200 34 2 8 1140850688 1 3472 nil 480 nil 519 nil nil nil 1510470 1 ##(Smalltalk.DraggableViewInteractor) 3472 nil 1 #left nil nil nil 498 1 1 498 9 9 nil 3568 nil 2546 138 144 34 1 2610 #createAt:extent: 34 2 498 585 1 498 11 557 3472 2770 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 36 1 0 0 0 0 0 0 41 1 0 0 22 1 0 0] 8 #() 2832 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 3200 34 2 8 1140850688 131073 3760 nil nil nil 7 nil nil nil 3760 658 170 176 34 2 410 ##(Smalltalk.ShellView) 34 27 nil 3760 34 2 8 1083113472 131073 3872 nil 480 nil 551 nil nil nil 3872 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 3872 34 2 8 1140850688 131073 3968 nil 480 nil 7 882 nil true 34 5 930 1 962 #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 930 1 962 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 930 1 962 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 930 1 962 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 930 1 962 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 3968 530 170 176 832 false 170 192 832 nil 2546 138 144 34 2 2610 #createAt:extent: 34 2 498 1 1 498 2047 867 3968 2610 #contextMenu: 34 1 4032 3968 2770 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 255 3 0 0 177 1 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 3968 34 2 8 1140850688 131073 4560 nil 480 nil 7 nil nil nil 4560 3938 1 1 410 ##(Smalltalk.StaticText) 34 16 nil 4560 34 2 8 1140850945 262145 4640 nil nil nil 7 nil nil nil 4640 nil 8 1607531712 852486 ##(Smalltalk.NullConverter) nil nil nil 2546 138 144 34 2 2610 #createAt:extent: 34 2 498 1 1 498 1019 41 4640 2610 #text: 34 1 8 '
' 4640 2770 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 253 1 0 0 20 0 0 0] 8 #() 2832 nil 27 nil nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 4560 34 2 8 1140920580 1025 4960 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 480 nil 7 nil nil nil 4960 nil 8 1358183912 4722 nil nil 11 1535975377 170 192 34 12 #whitespace 1182790 1 ##(Smalltalk.ScintillaTextStyle) 3 466 #teal nil 1 nil nil nil nil #whitespace nil nil nil #diff 5154 5 nil 196934 1 ##(Smalltalk.RGB) 16908287 3 nil nil nil nil #diff nil 1401 nil #lineNumber 5154 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #normal 5154 1 nil nil 1 nil nil nil nil #normal nil nil nil #indentGuide 5154 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #callTip 5154 77 466 #gray 466 #white 1 nil nil nil nil #callTip nil nil nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 4960 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 832 nil 170 176 832 9215 nil nil nil nil 466 #silver nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 5120 nil nil nil nil 16 nil 170 192 34 2 #diff 1510470 3 ##(Smalltalk.ScintillaIndicatorStyle) 1 4960 466 #yellow 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 5154 1027 5218 60239 5218 31326207 1 nil nil nil nil #Warning nil nil nil #Error 5154 1031 5218 335 5218 31317503 1 nil nil nil nil #Error nil nil nil #Notification 5154 1029 nil 5218 31185883 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 2546 138 144 34 8 2610 #createAt:extent: 34 2 498 1 41 498 1019 827 4960 2610 #caretPeriod: 8 #(530) 4960 2610 #wordWrap: 8 #(true) 4960 2610 #margins: 34 1 34 3 985158 3 ##(Smalltalk.ScintillaMargin) 1 4960 49 3 nil nil nil nil 6018 3 4960 1 nil nil 67108863 nil nil 6018 5 4960 1 nil nil nil nil nil 4960 2610 #canHScroll: 8 #(false) 4960 2610 #targetRange: 34 1 525062 ##(Smalltalk.Interval) 1 -1 3 4960 2610 #maxCompletionListHeight: 8 #(9) 4960 2610 #edgeColumn: 8 #(1) 4960 2770 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 20 0 0 0 253 1 0 0 177 1 0 0] 8 #() 2832 nil 33 170 192 34 4 4640 8 'beforeTitle' 4960 8 'before' nil 2546 138 144 34 1 2610 #createAt:extent: 34 2 498 1 1 498 1019 867 4560 2770 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 253 1 0 0 177 1 0 0] 34 2 4960 4640 2832 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 3968 34 2 8 1140850688 1 6512 nil 5218 66047 nil 519 nil nil nil 3538 6512 nil 1 #left nil nil nil 3568 3584 nil 3568 nil 2546 138 144 34 1 2610 #createAt:extent: 34 2 498 1019 1 498 11 867 6512 2770 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 253 1 0 0 0 0 0 0 2 2 0 0 177 1 0 0] 8 #() 2832 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 3968 34 2 8 1140850688 131073 6768 nil 480 nil 7 nil nil nil 6768 3938 1 1 410 ##(Smalltalk.StaticText) 34 16 nil 6768 34 2 8 1140850945 262145 6848 nil nil nil 7 nil nil nil 6848 nil 8 1607531712 4722 nil nil nil 2546 138 144 34 2 2610 #createAt:extent: 34 2 498 1 1 498 1019 41 6848 2610 #text: 34 1 8 '
' 6848 2770 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 253 1 0 0 20 0 0 0] 8 #() 2832 nil 27 nil nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 6768 34 2 8 1140920580 1025 7152 5026 nil false 5072 nil 480 nil 7 nil nil nil 7152 nil 8 1358183912 4722 nil nil 11 1536027793 170 192 34 12 #whitespace 5154 3 5184 nil 1 nil nil nil nil #whitespace nil nil nil #diff 5154 5 466 #black 5616 3 nil nil nil nil #diff nil 1401 nil #lineNumber 5154 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #normal 5154 1 nil nil 1 nil nil nil nil #normal nil nil nil #indentGuide 5154 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #callTip 5154 77 5312 5328 1 nil nil nil nil #callTip nil nil nil nil 5346 5376 170 192 34 2 #default 5426 1 nil nil nil 7152 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 832 nil 170 176 832 9215 nil nil nil nil 5488 nil nil 65 nil nil nil 5504 3 170 192 34 2 #container 7264 nil nil nil nil 16 nil 170 192 34 2 #diff 5586 1 7152 5616 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 5154 1027 5218 60239 5218 31326207 1 nil nil nil nil #Warning nil nil nil #Error 5154 1031 5218 335 5218 31317503 1 nil nil nil nil #Error nil nil nil #Notification 5154 1029 nil 5218 31185883 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 2546 138 144 34 8 2610 #createAt:extent: 34 2 498 1 41 498 1019 827 7152 2610 #caretPeriod: 8 #(530) 7152 2610 #wordWrap: 8 #(true) 7152 2610 #margins: 34 1 34 3 6018 1 7152 49 3 nil nil nil nil 6018 3 7152 1 nil nil 67108863 nil nil 6018 5 7152 1 nil nil nil nil nil 7152 2610 #canHScroll: 8 #(false) 7152 2610 #targetRange: 34 1 6146 1 -1 3 7152 2610 #maxCompletionListHeight: 8 #(9) 7152 2610 #edgeColumn: 8 #(1) 7152 2770 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 20 0 0 0 253 1 0 0 177 1 0 0] 8 #() 2832 nil 33 170 192 34 4 6848 8 'afterTitle' 7152 8 'after' nil 2546 138 144 34 1 2610 #createAt:extent: 34 2 498 1029 1 498 1019 867 6768 2770 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 2 2 0 0 0 0 0 0 255 3 0 0 177 1 0 0] 34 2 7152 6848 2832 nil 27 2832 nil 27 170 192 34 2 3968 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 882 nil true 34 4 930 1 962 #selectUpper 8 'Select &upper' 1 1 nil nil nil 930 1 962 #selectLower 8 'Select &lower' 1 1 nil nil nil 1106 4097 930 1 962 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 48895 nil nil 882 nil true 34 3 930 1 962 #character 8 '&Character' 1 1 nil nil nil 930 1 962 #word 8 '&Word' 1 1 nil nil nil 930 1 962 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 48903 nil nil 882 nil true 34 1 930 1 962 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 48907 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 2546 138 144 34 2 2610 #createAt:extent: 34 2 498 1 1 498 2079 899 3872 2610 #text: 34 1 8 'Differences' 3872 2770 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 15 4 0 0 193 1 0 0] 34 1 3968 2832 nil 27 2850 2896 1 2912 1 2928 1 2944 1 170 192 832 nil 2546 138 144 34 1 2610 #createAt:extent: 34 2 498 1 1 498 2079 899 3760 2770 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 15 4 0 0 193 1 0 0] 34 1 3872 2832 nil 27 2832 nil 27 3170 2045 1563 true 170 192 832 nil 8482 nil true 34 1 882 nil true 34 2 930 1 962 #refresh 8 'Refresh' 1 1 nil nil nil 930 1025 962 #flipIdenticalSource 8 'Include Methods With Identical Source' 1 1 nil nil nil 8 'Jadeite' nil 134217729 nil nil 48913 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 2546 138 144 34 1 2610 #createAt:extent: 34 2 498 6911 21 498 2111 1501 416 2770 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 127 13 0 0 10 0 0 0 158 17 0 0 248 2 0 0] 34 3 592 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 9824 nil 480 nil 519 nil nil nil 3538 9824 nil 1 #left nil nil nil 3568 3584 nil 3568 nil 2546 138 144 34 1 2610 #createAt:extent: 34 2 498 1 475 498 2079 11 9824 2770 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 237 0 0 0 15 4 0 0 242 0 0 0] 8 #() 2832 nil 27 3200 2832 nil 27 )!

showOn: aModel name: aString
	| browser |
	browser := self on: aModel.
	browser name: aString.
	^browser
		createView: self defaultView;
		showShell;
		yourself! !
!JadeiteChangesBrowser class categoriesForMethods!
resource_Default_view!public!resources-views! !
showOn:name:!public! !
!

