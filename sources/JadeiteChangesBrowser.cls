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
	diffsPresenter := self add: DiffBrowser new diffsPresenter name: 'diffs'!

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
	operation := operationListPresenter selection.
	operation revert: gciSession.
	operation clearObsoletionMemo.
	afterTitle := self afterTitle: operation.
	diffsPresenter
		afterTitle: afterTitle;
		compare: operation obsoletionMemo with: operation modificationMemo.
	operationListPresenter view invalidate!

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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 1601 1201 551 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 8 #() true 170 192 592 nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 1 265030 4 ##(Smalltalk.Menu) nil true 34 2 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #refresh 8 'Refresh' 1 1 nil nil nil 722 1025 754 #flipIdenticalSource 8 'Include Methods With Identical Source' 1 1 nil nil nil 8 'Jadeite' nil 134217729 nil nil 21945 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 7679 21 514 1601 1201 416 946 #updateMenuBar 592 416 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 31 18 0 0 98 2 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 1104 nil nil nil 7 nil nil nil 1104 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ListView) 34 30 nil 1104 34 2 8 1409355853 1025 1232 590662 2 ##(Smalltalk.ListModel) 138 144 592 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 466 8 4278190080 nil 7 674 nil true 34 5 722 1 754 #browseChangedThing 8 'Browse in Project Browser' 1 1 nil nil nil 722 1 754 #browseImplementors 8 'Browse Implementors' 1 1 nil nil nil 722 1 754 #browseSenders 8 'Browse Senders' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 722 1 754 #revert 8 'Revert' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 1232 nil 8 4294906403 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 4 920646 5 ##(Smalltalk.ListViewColumn) 8 'Type' 301 #left 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 1856 8 'doIt' 8 '[:each | each typeString]' 8 #[30 105 226 0 106] #typeString 1872 7 257 nil 1858 0 nil 1890 2 1 1696 8 'doIt' 8 '[:x :y | x typeString <= y typeString]' 8 #[30 105 226 0 226 32 130 106] #typeString 1968 7 513 nil nil nil 1232 nil 1 1858 0 nil 1890 5 1 1856 8 'doIt' 8 '[:each | each className, ''>>'', each selector]' 8 #[33 105 226 0 30 178 226 3 178 106] #className 8 '>>' #, #selector 2048 7 257 nil nil 1810 8 'Class' 401 #left 1858 0 nil 1890 2 1 1696 8 'doIt' 8 '[:each | each className]' 8 #[30 105 226 0 106] #className 2176 7 257 nil 1858 0 nil 1890 2 1 106 8 'Dolphin' 8 'SortedCollection' 8 'doIt' 8 '[:x :y | x className <= y className]' 8 #[30 105 226 0 226 32 130 106] #className 2256 7 513 nil nil nil 1232 nil 1 nil nil 1810 8 'Selector' 401 #left 1858 0 nil 1890 2 1 112 8 'doIt' 8 '[:each | each selector]' 8 #[30 105 226 0 106] #selector 2416 7 257 nil 1858 0 nil 1890 2 1 1856 8 'doIt' 8 '[:x :y | x selector <= y selector]' 8 #[30 105 226 0 226 32 130 106] #selector 2496 7 513 nil nil nil 1232 nil 1 nil nil 1810 8 'Detail' 461 #left 1858 0 nil 1890 2 1 1696 8 'doIt' 8 '[:each | each detailsString]' 8 #[30 105 226 0 106] #detailsString 2608 7 257 nil 1858 0 nil 1890 2 1 1856 8 'doIt' 8 '[:x :y | x detailsString <= y detailsString]' 8 #[30 105 226 0 226 32 130 106] #detailsString 2688 7 513 nil nil nil 1232 nil 3 nil nil #report 592 nil 133217 nil 34 4 nil nil 514 1 1 nil 882 138 144 34 3 946 #createAt:extent: 34 2 514 1 1 514 1569 537 1232 946 #contextMenu: 34 1 1408 1232 946 #text: 34 1 8 'Type' 1232 1042 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 3 0 0 12 1 0 0] 8 #() 514 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 3090 #fixedParentRight 1 3090 #fixedParentTop 1 3090 #fixedParentBottom 1 170 192 34 2 1232 8 'operationList' nil 882 138 144 34 1 946 #createAt:extent: 34 2 514 1 1 514 1569 537 1104 1042 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 3 0 0 12 1 0 0] 34 1 1232 3040 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 3376 nil 466 8 4278190080 nil 519 nil nil nil 3376 882 138 144 34 1 946 #createAt:extent: 34 2 514 1 537 514 1569 11 3376 1042 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 12 1 0 0 16 3 0 0 17 1 0 0] 8 #() 3040 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 3632 nil nil nil 7 nil nil nil 3632 546 170 176 592 false 170 192 592 nil 882 138 144 34 1 946 #createAt:extent: 34 2 514 1 547 514 1569 537 3632 1042 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 17 1 0 0 16 3 0 0 29 2 0 0] 34 2 410 ##(Smalltalk.Splitter) 34 12 nil 3632 34 2 8 1140850688 1 3904 nil 466 3456 nil 519 nil nil nil 3904 882 138 144 34 1 946 #createAt:extent: 34 2 514 585 1 514 11 557 3904 1042 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 36 1 0 0 0 0 0 0 41 1 0 0 22 1 0 0] 8 #() 3040 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 3632 34 2 8 1140850688 131073 4144 nil nil nil 7 nil nil nil 4144 1170 170 176 34 2 410 ##(Smalltalk.ShellView) 34 27 nil 4144 34 2 8 1083113472 131073 4256 nil 466 8 4278190080 nil 551 nil nil nil 4256 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 4256 34 2 8 1140850688 131073 4384 nil 466 4336 nil 7 674 nil true 34 5 722 1 754 #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 722 1 754 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 722 1 754 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 722 1 754 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 722 1 754 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 4384 546 170 176 592 false 170 192 592 nil 882 138 144 34 2 946 #createAt:extent: 34 2 514 1 1 514 1537 505 4384 946 #contextMenu: 34 1 4464 4384 1042 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 0 3 0 0 252 0 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 4384 34 2 8 1140850688 131073 4992 nil 466 4336 nil 7 nil nil nil 4992 4354 1 1 410 ##(Smalltalk.StaticText) 34 16 nil 4992 34 2 8 1140850945 262145 5088 nil nil nil 7 nil nil nil 5088 nil 8 1663077024 852486 ##(Smalltalk.NullConverter) nil nil nil 882 138 144 34 2 946 #createAt:extent: 34 2 514 1 1 514 763 41 5088 946 #text: 34 1 8 '
' 5088 1042 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 125 1 0 0 20 0 0 0] 8 #() 3040 nil 27 nil nil nil 410 ##(Smalltalk.ScintillaView) 34 50 nil 4992 34 2 8 1140920580 1025 5408 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 466 4336 nil 7 nil nil nil 5408 nil 8 4294906421 5170 nil nil 11 nil 170 192 34 12 #indentGuide 1182790 1 ##(Smalltalk.ScintillaTextStyle) 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 5618 3 786694 ##(Smalltalk.IndexedColor) 33554445 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 5618 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 5618 77 5666 33554457 5666 33554471 1 nil nil nil nil #callTip nil nil nil #normal 5618 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 5618 5 nil 196934 1 ##(Smalltalk.RGB) 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 5760 5648 5776 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 5696 nil nil nil 5632 nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 1641542 1 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 5408 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 592 nil 170 176 592 9215 nil nil nil nil 5666 33554447 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 5584 nil nil nil nil 1 nil 170 192 34 6 8 'indicator0' 1510470 2 ##(Smalltalk.ScintillaIndicatorStyle) 1 5408 33554459 13 false nil nil nil nil nil nil nil 8 'indicator1' 6098 3 5408 33423361 5 false nil nil nil nil nil nil nil 8 'indicator2' 6098 5 5408 511 1 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 5618 1029 nil 5794 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 5618 1027 5794 60239 5794 31326207 1 nil nil nil nil #Warning nil nil nil #Error 5618 1031 5794 335 5794 31317503 1 nil nil nil nil #Error nil nil nil nil 882 138 144 34 7 946 #createAt:extent: 34 2 514 1 41 514 763 465 5408 946 #modificationEventMask: 8 #(4607) 5408 946 #caretPeriod: 8 #(530) 5408 946 #wordWrap: 8 #(true) 5408 946 #margins: 34 1 34 3 985158 2 ##(Smalltalk.ScintillaMargin) 1 5408 49 3 nil nil nil nil 6610 3 5408 1 nil nil 67108863 nil nil 6610 5 5408 1 nil nil nil nil nil 5408 946 #canHScroll: 8 #(false) 5408 946 #maxCompletionListHeight: 8 #(9) 5408 1042 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 20 0 0 0 125 1 0 0 252 0 0 0] 8 #() 3040 nil 29 170 192 34 4 5408 8 'before' 5088 8 'beforeTitle' nil 882 138 144 34 1 946 #createAt:extent: 34 2 514 1 1 514 763 505 4992 1042 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 125 1 0 0 252 0 0 0] 34 2 5408 5088 3040 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 4384 34 2 8 1140850688 1 7008 nil 5794 66047 nil 519 nil nil nil 7008 882 138 144 34 1 946 #createAt:extent: 34 2 514 763 1 514 11 505 7008 1042 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 125 1 0 0 0 0 0 0 130 1 0 0 252 0 0 0] 8 #() 3040 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 4384 34 2 8 1140850688 131073 7248 nil 466 4336 nil 7 nil nil nil 7248 4354 1 1 410 ##(Smalltalk.StaticText) 34 16 nil 7248 34 2 8 1140850945 262145 7344 nil nil nil 7 nil nil nil 7344 nil 8 1663077024 5170 nil nil nil 882 138 144 34 2 946 #createAt:extent: 34 2 514 1 1 514 765 41 7344 946 #text: 34 1 8 '
' 7344 1042 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 126 1 0 0 20 0 0 0] 8 #() 3040 nil 27 nil nil nil 410 ##(Smalltalk.ScintillaView) 34 50 nil 7248 34 2 8 1140920580 1025 7648 5474 nil false 5520 nil 466 4336 nil 7 nil nil nil 7648 nil 8 4294906421 5170 nil nil 11 nil 170 192 34 12 #indentGuide 5618 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 5618 3 5680 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 5618 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 5618 77 5728 5744 1 nil nil nil nil #callTip nil nil nil #normal 5618 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 5618 5 nil 5794 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 7872 7824 7888 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 7840 nil nil nil 7808 nil nil 5842 5872 170 192 34 2 #default 5922 1 nil nil nil 7648 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 592 nil 170 176 592 9215 nil nil nil nil 5984 nil nil 65 nil nil nil 6000 3 170 192 34 2 #container 7776 nil nil nil nil 1 nil 170 192 34 6 8 'indicator1' 6098 3 7648 33423361 5 false nil nil nil nil nil nil nil 8 'indicator2' 6098 5 7648 511 1 false nil nil nil nil nil nil nil 8 'indicator0' 6098 1 7648 33554459 13 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 5618 1029 nil 5794 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 5618 1027 5794 60239 5794 31326207 1 nil nil nil nil #Warning nil nil nil #Error 5618 1031 5794 335 5794 31317503 1 nil nil nil nil #Error nil nil nil nil 882 138 144 34 7 946 #createAt:extent: 34 2 514 1 41 514 765 465 7648 946 #modificationEventMask: 8 #(4607) 7648 946 #caretPeriod: 8 #(530) 7648 946 #wordWrap: 8 #(true) 7648 946 #margins: 34 1 34 3 6610 1 7648 49 3 nil nil nil nil 6610 3 7648 1 nil nil 67108863 nil nil 6610 5 7648 1 nil nil nil nil nil 7648 946 #canHScroll: 8 #(false) 7648 946 #maxCompletionListHeight: 8 #(9) 7648 1042 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 20 0 0 0 126 1 0 0 252 0 0 0] 8 #() 3040 nil 29 170 192 34 4 7648 8 'after' 7344 8 'afterTitle' nil 882 138 144 34 1 946 #createAt:extent: 34 2 514 773 1 514 765 505 7248 1042 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 130 1 0 0 0 0 0 0 0 3 0 0 252 0 0 0] 34 2 7648 7344 3040 nil 27 3040 nil 27 170 192 34 2 4384 8 'diffs' nil 626 nil true 34 3 674 nil true 34 4 722 1 754 #selectUpper 8 'Select &upper' 1 1 nil nil nil 722 1 754 #selectLower 8 'Select &lower' 1 1 nil nil nil 1586 4097 722 1 754 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 20149 nil nil 674 nil true 34 3 722 1 754 #character 8 '&Character' 1 1 nil nil nil 722 1 754 #word 8 '&Word' 1 1 nil nil nil 722 1 754 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 20157 nil nil 674 nil true 34 1 722 1 754 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 20161 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 882 138 144 34 3 946 #createAt:extent: 34 2 514 1 1 514 1569 537 4256 946 #text: 34 1 8 'Differences' 4256 946 #updateMenuBar 592 4256 1042 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 3 0 0 12 1 0 0] 34 1 4384 3040 nil 27 3058 3104 1 3120 1 3136 1 3152 1 170 192 592 nil 882 138 144 34 1 946 #createAt:extent: 34 2 514 1 1 514 1569 537 4144 1042 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 16 3 0 0 12 1 0 0] 34 1 4256 3040 nil 27 3040 nil 27 3040 nil 27 )!

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

