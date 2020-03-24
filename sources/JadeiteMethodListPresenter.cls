"Filed out from Dolphin Smalltalk 7"!

RowanMethodListPresenter subclass: #JadeiteMethodListPresenter
	instanceVariableNames: 'textAreaTabs comparisonTab comparisonPresenter autoCommit search'
	classVariableNames: ''
	poolDictionaries: 'ScintillaConstants'
	classInstanceVariableNames: ''!
JadeiteMethodListPresenter guid: (GUID fromString: '{c27cfd96-c166-40cb-83b6-6073a885a25f}')!
JadeiteMethodListPresenter comment: ''!
!JadeiteMethodListPresenter categoriesForClass!Unclassified! !
!JadeiteMethodListPresenter methodsFor!

additionalAccelerators
	^#(#(#insertIfFalse 'Ctrl+Shift+D') #(#insertIfTrue 'Ctrl+Shift+T') #(#raiseConsole 'Ctrl+F7'))!

autoCommit
	"for testing"

	^autoCommit value!

autoCommit: boolean
	autoCommit value: boolean!

browseMethodHistory
	| methodService |
	methodService := methodListPresenter selections first.
	^JadeiteMethodHistoryBrowser showOnClass: methodService classService selector: methodService!

cleanupComparisonBrowser
	comparisonPresenter
		beforeTitle: String new;
		afterTitle: String new;
		compare: String new with: String new!

clearAllBreakpoints
	^JadePresenter clearAllBreaksIn: self gciSession!

clearMethodBreakpoints
	^JadePresenter clearMethodBreakpoints: methodListPresenter selections in: self gciSession!

comparisonPresenter

	^comparisonPresenter!

comparisonTab
	^comparisonTab
		ifNil: 
			[comparisonTab := self textTabs
						detect: [:each | (each class canUnderstand: #text) ifTrue: [each text = 'Comparison'] ifFalse: [each = 'Comparison']]]!

contextObject
	| methodService classService |
	methodService := methodListPresenter methodListPresenter selectionIfNone: [^nil].
	classService := RowanClassService named: methodService className.
	self updateService: classService.
	^classService oop!

createComponents
	methodListPresenter := self add: JadeiteBasicMethodListPresenter new name: 'methodList'.
	methodSourcePresenter := (self add: JadeiteMethodSourcePresenter new name: 'methodSource')
				menuTitle: '&Method Source'.
	comparisonPresenter := self add: DifferencesPresenter new name: 'comparisonTab'.!

createSchematicWiring
	super createSchematicWiring.
	self getViews.
	methodListPresenter
		when: #methodSelectionChanged
		send: #updateMethodSource
		to: self.
	autoCommit
		when: #valueChanged
		send: #updateAutoCommit
		to: self.
	methodSourcePresenter documentPresenter
		when: #autoComplete:startingAt:accept:
			send: #onAutoComplete:startingAt:accept:
			to: self search;
		when: #timerTick:
			send: #onTimerTick:
			to: self search;
		when: #charAdded:
			send: #onCharAdded:
			to: self search.
	comparisonPresenter beforePresenter
		when: #dragOver:
			send: #onDragOverSource:
			to: self;
		when: #drop:
			send: #onDropOnBefore:
			to: self.
	comparisonPresenter afterPresenter
		when: #dragOver:
			send: #onDragOverSource:
			to: self;
		when: #drop:
			send: #onDropOnAfter:
			to: self!

fileSave

	self halt. !

gciSession: aGciSession
	super gciSession: aGciSession.
	autoCommit := ValueHolder with: self remoteAutoCommit.!

getViews 
	textAreaTabs := parentPresenter view viewNamed: 'textAreaTabs'.!

methodListSelection
	^methodListPresenter selectionOrNil!

methods: services selecting: stringOrIndex
	"services can legitimately be nil if call was blocked because it
	was already inUpdate"

	(services isNil or: [services isEmpty]) ifTrue: [^self].
	methodListPresenter
		list: (ListModel withAll: services);
		selectFirstMethod.
	stringOrIndex ifNil: [^self].
	self selecting: stringOrIndex!

methods: services selectingAnyMatch: string
	services isEmpty ifTrue: [^self].
	methodListPresenter
		list: (ListModel withAll: services);
		selectFirstMethod.
!

onCloseRequested: aCloseEvent
	aCloseEvent value: (methodSourcePresenter documentPresenter view isModified
				ifTrue: [methodSourcePresenter isOkayToChange]
				ifFalse: [true])!

onDragMethod: aSession
	| list |
	list := methodListPresenter selections collect: 
					[:each |
					(aSession newDragObject: each)
						format: #method data: each;
						yourself].
	aSession
		dragObjects: list;
		supportedOperations: #(#move #copy);
		defaultOperation: #copy;
		yourself!

onDragOverSource: aDragDropSession
	aDragDropSession operation: nil.
	aDragDropSession dragObjects isEmpty ifTrue: [^self].
	aDragDropSession suggestedTarget isNil ifTrue: [^self].
	self setDragOperationsFor: aDragDropSession!

onDropOnAfter: aDragDropSession
	comparisonPresenter afterPresenter value: aDragDropSession suggestedSource source.
	comparisonPresenter refresh.
	aDragDropSession suggestedTarget: nil.	"nil out the suggestedTarget so the TextPresenter does not try to act on the drop"!

onDropOnBefore: aDragDropSession
	comparisonPresenter beforePresenter value: aDragDropSession suggestedSource source.
	comparisonPresenter refresh.
	aDragDropSession suggestedTarget: nil.	"nil out the suggestedTarget so the TextPresenter does not try to act on the drop"!

onViewOpened

	super onViewOpened. 
	self registerPresentersForUpdates.
	self updateAutoCommit.!

postEditSaveMethod
	| methodService |
	methodService := self methodListPresenter methodListPresenter selectionIfNone: [^self].

	"If we recompile a method in the method list browser
	reset the firstReference to nil. Although we have the
	string that was searched on, we don't know the type
	of search so it's better to show no reference than the
	wrong reference"
	methodService firstReference: nil!

queryCommand: aCommandQuery
	| command |
	command := aCommandQuery command.
	(#(#clearMethodBreakpoints) includes: command)
		ifTrue: 
			[aCommandQuery isEnabled: methodListPresenter selections notEmpty.
			^true].
	#browseMethodHistory = command
		ifTrue: 
			[| selections | 
			selections := self methodListPresenter selections.
			aCommandQuery isEnabled: (selections size = 1 and: [selections first hasMethodHistory]).
			^true].
	^super queryCommand: aCommandQuery!

registerPresentersForUpdates
	BrowserUpdate current
		register: self selector: #autoCommitUpdate:;
		register: methodListPresenter methodListPresenter
			selector: #methodUpdate:browser:
			browser: self!

removeComparisonTab
	self textTabs remove: self comparisonTab ifAbsent: []!

search
	^search
		ifNil: 
			[search := JadeiteSearch on: methodSourcePresenter documentPresenter view session: self gciSession]!

selectComparisonTab
	comparisonPresenter ensureVisible!

selectedClassName
	^methodListPresenter methodListPresenter list first className!

selecting: stringOrIndex string: searchString
	stringOrIndex isNumber
		ifTrue: 
			[| range stream selectionStop |
			stream := ReadStream on: methodSourcePresenter documentPresenter value.
			stream position: stringOrIndex.
			stream nextWord.
			selectionStop := searchString
						ifNil: [stream position]
						ifNotNil: [searchString size + stringOrIndex].
			range := Interval from: stringOrIndex to: selectionStop - 1.
			methodSourcePresenter documentPresenter selectionRange: range]
		ifFalse: 
			[searchBlock := [self searchFor: stringOrIndex].
			self doSearch].
	methodSourcePresenter documentPresenter view ensureCaretVisible!

selectionChanging: aSelectionChangingEvent
	aSelectionChangingEvent value: (methodSourcePresenter documentPresenter view isModified
				ifTrue: [methodSourcePresenter isOkayToChange]
				ifFalse: [true])!

showComparisonTab
	self textTabs add: self comparisonTab.
	comparisonPresenter ensureVisible!

showSuperClassComparison
	| methodService |
	methodService := methodListPresenter selection.
	methodService hasSupers
		ifTrue: 
			[comparisonPresenter
				beforeTitle: methodService classMethodDisplayString;
				afterTitle: methodService superDisplayString;
				compare: methodService source with: methodService comparisonSource]
		ifFalse: 
			[comparisonPresenter
				beforeTitle: methodService classMethodDisplayString;
				afterTitle: 'No super implementation';
				compare: methodService source with: String new]!

textAreaTabs
	^textAreaTabs!

textAreaTabs: anObject
	textAreaTabs := anObject!

textTabs
	^(textAreaTabs subViews detect: [:each | each class == TabViewXP]) model!

updateAutoCommit
	| autoCommitButtonView |
	autoCommitButtonView := self topShell view viewNamed: 'autoCommitButton'.
	autoCommit value == #failed ifTrue: [^autoCommitButtonView backcolor: Color red].
	autoCommit value
		ifTrue: [autoCommitButtonView backcolor: Color green]
		ifFalse: [autoCommitButtonView backcolor: Color default]!

updateMethodSource
	methodListPresenter selections isEmpty
		ifTrue: 
			[self cleanupComparisonBrowser.
			^methodSourcePresenter value: String new].
	methodListPresenter selections size = 1
		ifTrue: 
			[self showSuperClassComparison.
			^self updateSingleMethodSource].
	self updateMultiMethodComparison.
	self refreshBreakPointsIn: methodSourcePresenter documentPresenter.
	self setStatusBarDefault!

updateMultiMethodComparison
	self selectComparisonTab.
	comparisonPresenter
		beforeTitle: (methodListPresenter selections at: 1) classMethodDisplayString;
		afterTitle: (methodListPresenter selections at: 2) classMethodDisplayString;
		compare: (methodListPresenter selections at: 1) source
			with: (methodListPresenter selections at: 2) source.!

updateSingleMethodSource
	| selection |
	selection := methodListPresenter selection.
	methodSourcePresenter value: selection source.
	selection firstReference
		ifNotNil: 
			[:index |
			methodSourcePresenter value ifNotNil: [self selecting: index string: selection searchString]].
	methodSourcePresenter ensureVisible!

updateSource
	| selection |
	selection := methodListPresenter selectionOrNil.
	selection ifNil: [^self]. 
	methodSourcePresenter methodService: selection.
	methodSourcePresenter update.
	self doSearch. 
	('*METHOD SOURCE CANNOT BE DISPLAYED*' match: methodSourcePresenter documentPresenter value)
		ifTrue: [methodSourcePresenter documentPresenter view backcolor: Color red faded faded].! !
!JadeiteMethodListPresenter categoriesFor: #additionalAccelerators!accessing!public! !
!JadeiteMethodListPresenter categoriesFor: #autoCommit!accessing!public! !
!JadeiteMethodListPresenter categoriesFor: #autoCommit:!accessing!public! !
!JadeiteMethodListPresenter categoriesFor: #browseMethodHistory!menu handlers!public! !
!JadeiteMethodListPresenter categoriesFor: #cleanupComparisonBrowser!private!text tabs! !
!JadeiteMethodListPresenter categoriesFor: #clearAllBreakpoints!menu handlers!public! !
!JadeiteMethodListPresenter categoriesFor: #clearMethodBreakpoints!menu handlers!public! !
!JadeiteMethodListPresenter categoriesFor: #comparisonPresenter!public! !
!JadeiteMethodListPresenter categoriesFor: #comparisonTab!private!selection!text tabs! !
!JadeiteMethodListPresenter categoriesFor: #contextObject!public! !
!JadeiteMethodListPresenter categoriesFor: #createComponents!initialization!public! !
!JadeiteMethodListPresenter categoriesFor: #createSchematicWiring!initialization!public! !
!JadeiteMethodListPresenter categoriesFor: #fileSave!public! !
!JadeiteMethodListPresenter categoriesFor: #gciSession:!accessing!public! !
!JadeiteMethodListPresenter categoriesFor: #getViews!public! !
!JadeiteMethodListPresenter categoriesFor: #methodListSelection!public! !
!JadeiteMethodListPresenter categoriesFor: #methods:selecting:!public! !
!JadeiteMethodListPresenter categoriesFor: #methods:selectingAnyMatch:!public! !
!JadeiteMethodListPresenter categoriesFor: #onCloseRequested:!event handlers!public! !
!JadeiteMethodListPresenter categoriesFor: #onDragMethod:!drag & drop!public! !
!JadeiteMethodListPresenter categoriesFor: #onDragOverSource:!drag & drop!public! !
!JadeiteMethodListPresenter categoriesFor: #onDropOnAfter:!drag & drop!public! !
!JadeiteMethodListPresenter categoriesFor: #onDropOnBefore:!drag & drop!public! !
!JadeiteMethodListPresenter categoriesFor: #onViewOpened!event handlers!public! !
!JadeiteMethodListPresenter categoriesFor: #postEditSaveMethod!menu handlers!public! !
!JadeiteMethodListPresenter categoriesFor: #queryCommand:!menu handlers support!public! !
!JadeiteMethodListPresenter categoriesFor: #registerPresentersForUpdates!public!register presenters! !
!JadeiteMethodListPresenter categoriesFor: #removeComparisonTab!private!selection!text tabs! !
!JadeiteMethodListPresenter categoriesFor: #search!accessing!public! !
!JadeiteMethodListPresenter categoriesFor: #selectComparisonTab!private!selection!text tabs! !
!JadeiteMethodListPresenter categoriesFor: #selectedClassName!public!selection! !
!JadeiteMethodListPresenter categoriesFor: #selecting:string:!public! !
!JadeiteMethodListPresenter categoriesFor: #selectionChanging:!event handlers!public! !
!JadeiteMethodListPresenter categoriesFor: #showComparisonTab!private!selection!text tabs! !
!JadeiteMethodListPresenter categoriesFor: #showSuperClassComparison!private!text tabs! !
!JadeiteMethodListPresenter categoriesFor: #textAreaTabs!accessing!private! !
!JadeiteMethodListPresenter categoriesFor: #textAreaTabs:!accessing!private! !
!JadeiteMethodListPresenter categoriesFor: #textTabs!private!text tabs! !
!JadeiteMethodListPresenter categoriesFor: #updateAutoCommit!public!updating! !
!JadeiteMethodListPresenter categoriesFor: #updateMethodSource!public!updating! !
!JadeiteMethodListPresenter categoriesFor: #updateMultiMethodComparison!private!text tabs! !
!JadeiteMethodListPresenter categoriesFor: #updateSingleMethodSource!private!text tabs! !
!JadeiteMethodListPresenter categoriesFor: #updateSource!public! !

!JadeiteMethodListPresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil nil 5 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 2 410 ##(Smalltalk.ReferenceView) 34 14 nil 416 34 2 8 1140916224 131073 544 nil 327686 ##(Smalltalk.Color) #default nil 5 nil nil nil 544 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteBasicMethodListPresenter) #resource_Default_view nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 328198 ##(Smalltalk.Point) 1 1 786 1461 271 544 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 218 2 0 0 135 0 0 0] 8 #() 786 193 193 nil 27 524806 ##(Smalltalk.Fraction) 3 5 true 170 192 34 6 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 976 nil 624 nil 5 nil nil nil 976 655878 ##(Smalltalk.CardLayout) 138 144 34 2 721414 ##(Smalltalk.Association) 8 'Comparison' 410 ##(Smalltalk.ShellView) 34 27 nil 976 34 2 8 1078919168 131073 1152 nil 624 nil 517 nil nil nil 1152 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 1152 34 2 8 1140850688 131073 1248 nil 624 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 5 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 1362 1 1394 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 1362 1 1394 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 1362 1 1394 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 1362 1 1394 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 1248 482 170 176 880 false 170 192 880 nil 674 138 144 34 2 738 #createAt:extent: 34 2 786 1 1 786 1413 447 1248 738 #contextMenu: 34 1 1328 1248 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 194 2 0 0 223 0 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 1248 34 2 8 1140850688 131073 1888 nil 624 nil 5 nil nil nil 1888 1218 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 1888 34 2 8 1140850945 262145 1968 nil nil nil 5 nil nil nil 1968 nil 8 1650166432 852486 ##(Smalltalk.NullConverter) nil nil nil 674 138 144 34 2 738 #createAt:extent: 34 2 786 1 407 786 701 41 1968 738 #text: 34 1 8 '
' 1968 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 203 0 0 0 94 1 0 0 223 0 0 0] 8 #() 896 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 1888 34 2 8 1140920580 1025 2288 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 196934 1 ##(Smalltalk.RGB) 26337781 nil 21 nil nil nil 2288 nil 8 1428148671 2050 nil nil 11 nil 170 192 34 12 #lineNumber 1182790 1 ##(Smalltalk.ScintillaTextStyle) 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 2514 77 610 #gray 610 #white 1 nil nil nil nil #callTip nil nil nil #indentGuide 2514 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #normal 2514 1 nil nil 1 nil nil nil nil #normal nil nil nil #whitespace 2514 3 610 #teal nil 1 nil nil nil nil #whitespace nil nil nil #diff 2514 5 nil 2418 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 2608 2624 2656 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 2528 nil nil nil 2592 nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 2288 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 880 nil 170 176 880 9215 nil nil nil nil 610 #silver nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 2480 nil nil nil nil 1 nil 170 192 34 2 #diff 1510470 3 ##(Smalltalk.ScintillaIndicatorStyle) 1 2288 610 #yellow 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 2514 1027 2418 60239 2418 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2514 1031 2418 335 2418 31317503 1 nil nil nil nil #Error nil nil nil #Notification 2514 1029 nil 2418 31185883 1 nil nil nil nil #Notification nil nil nil nil 674 138 144 34 8 738 #createAt:extent: 34 2 786 1 1 786 701 407 2288 738 #textLimit: 8 #(1073741823) 2288 738 #caretPeriod: 8 #(530) 2288 738 #wordWrap: 8 #(true) 2288 738 #margins: 34 1 34 3 985158 3 ##(Smalltalk.ScintillaMargin) 1 2288 49 3 nil nil nil nil 3410 3 2288 1 nil nil 67108863 nil nil 3410 5 2288 1 nil nil nil nil nil 2288 738 #canHScroll: 8 #(false) 2288 738 #maxCompletionListHeight: 8 #(9) 2288 738 #edgeColumn: 8 #(1) 2288 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 94 1 0 0 203 0 0 0] 8 #() 896 nil 29 170 192 34 4 1968 8 'beforeTitle' 2288 8 'before' nil 674 138 144 34 1 738 #createAt:extent: 34 2 786 1 1 786 701 447 1888 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 94 1 0 0 223 0 0 0] 34 2 2288 1968 896 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 1248 34 2 8 1140850688 1 3840 nil 2418 66047 nil 517 nil nil nil 1510470 1 ##(Smalltalk.DraggableViewInteractor) 3840 nil 1 #left nil nil nil 786 1 1 786 9 9 nil 3952 nil 674 138 144 34 1 738 #createAt:extent: 34 2 786 701 1 786 11 447 3840 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 94 1 0 0 0 0 0 0 99 1 0 0 223 0 0 0] 8 #() 896 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 1248 34 2 8 1140850688 131073 4144 nil 624 nil 5 nil nil nil 4144 1218 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 4144 34 2 8 1140850945 262145 4224 nil nil nil 5 nil nil nil 4224 nil 8 1650166432 2050 nil nil nil 674 138 144 34 2 738 #createAt:extent: 34 2 786 1 407 786 703 41 4224 738 #text: 34 1 8 '
' 4224 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 203 0 0 0 95 1 0 0 223 0 0 0] 8 #() 896 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 4144 34 2 8 1140920580 1025 4528 2354 nil false 2400 nil 2418 26337781 nil 21 nil nil nil 4528 nil 8 1428148671 2050 nil nil 11 nil 170 192 34 12 #lineNumber 2514 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 2514 77 2560 2576 1 nil nil nil nil #callTip nil nil nil #indentGuide 2514 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #normal 2514 1 nil nil 1 nil nil nil nil #normal nil nil nil #whitespace 2514 3 2640 nil 1 nil nil nil nil #whitespace nil nil nil #diff 2514 5 nil 2418 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 4736 4752 4768 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 4688 nil nil nil 4720 nil nil 2706 2736 170 192 34 2 #default 2786 1 nil nil nil 4528 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 880 nil 170 176 880 9215 nil nil nil nil 2848 nil nil 65 nil nil nil 2864 3 170 192 34 2 #container 4656 nil nil nil nil 1 nil 170 192 34 2 #diff 2946 1 4528 2976 33 false #diff 201 nil nil nil 171 nil nil nil 170 192 34 6 #Warning 2514 1027 2418 60239 2418 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2514 1031 2418 335 2418 31317503 1 nil nil nil nil #Error nil nil nil #Notification 2514 1029 nil 2418 31185883 1 nil nil nil nil #Notification nil nil nil nil 674 138 144 34 8 738 #createAt:extent: 34 2 786 1 1 786 703 407 4528 738 #textLimit: 8 #(1073741823) 4528 738 #caretPeriod: 8 #(530) 4528 738 #wordWrap: 8 #(true) 4528 738 #margins: 34 1 34 3 3410 1 4528 49 3 nil nil nil nil 3410 3 4528 1 nil nil 67108863 nil nil 3410 5 4528 1 nil nil nil nil nil 4528 738 #canHScroll: 8 #(false) 4528 738 #maxCompletionListHeight: 8 #(9) 4528 738 #edgeColumn: 8 #(1) 4528 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 95 1 0 0 203 0 0 0] 8 #() 896 nil 29 170 192 34 4 4224 8 'afterTitle' 4528 8 'after' nil 674 138 144 34 1 738 #createAt:extent: 34 2 786 711 1 786 703 447 4144 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 99 1 0 0 0 0 0 0 194 2 0 0 223 0 0 0] 34 2 4528 4224 896 nil 27 896 nil 27 170 192 34 2 1248 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 1314 nil true 34 4 1362 1 1394 #selectUpper 8 'Select &upper' 1 1 nil nil nil 1362 1 1394 #selectLower 8 'Select &lower' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 1362 1 1394 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 26405 nil nil 1314 nil true 34 3 1362 1 1394 #character 8 '&Character' 1 1 nil nil nil 1362 1 1394 #word 8 '&Word' 1 1 nil nil nil 1362 1 1394 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 26407 nil nil 1314 nil true 34 1 1362 1 1394 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 26409 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 674 138 144 34 3 738 #createAt:extent: 34 2 786 9 53 786 1445 481 1152 738 #text: 34 1 8 'Differences' 1152 738 #updateMenuBar 880 1152 834 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 214 2 0 0 10 1 0 0] 34 1 1248 896 nil 27 1106 8 'Method Source' 410 ##(Smalltalk.ReferenceView) 34 14 nil 976 34 2 8 1140850688 131073 6704 nil 624 nil 5 nil nil nil 6704 642 ##(Smalltalk.JadeiteMethodSourcePresenter) #resource_Default_view nil 674 138 144 34 1 738 #createAt:extent: 34 2 786 9 53 786 1445 481 6704 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 214 2 0 0 10 1 0 0] 880 896 nil 27 6704 170 192 34 4 1152 8 'comparisonTab' 6704 8 'methodSource' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 976 34 2 8 1140916736 1 6992 590662 2 ##(Smalltalk.ListModel) 138 144 34 2 6688 1136 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) nil nil 1 nil nil nil 6992 nil 8 1650396656 787814 3 ##(Smalltalk.BlockClosure) 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 7184 7 257 nil 7170 0 nil 7202 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 7248 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #noIcons nil nil nil nil nil 674 138 144 34 3 738 #createAt:extent: 34 2 786 1 1 786 1461 541 6992 738 #basicSelectionsByIndex: 34 1 8 #(1) 6992 738 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 6992 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 218 2 0 0 14 1 0 0] 8 #() 896 nil 27 674 138 144 34 2 738 #createAt:extent: 34 2 786 1 281 786 1461 541 976 738 #text: 34 1 8 'textAreaTabs' 976 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 140 0 0 0 218 2 0 0 154 1 0 0] 34 3 6704 1152 6992 896 nil 27 8 'textAreaTabs' 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 7792 nil 624 nil 517 nil nil nil 3922 7792 nil 1 #left nil nil nil 3952 3968 nil 3952 nil 674 138 144 34 1 738 #createAt:extent: 34 2 786 1 271 786 1461 11 7792 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 135 0 0 0 218 2 0 0 140 0 0 0] 8 #() 896 nil 27 8 'Splitter' 544 8 'methodList' nil 674 138 144 34 1 738 #createAt:extent: 34 2 786 2879 21 786 1461 821 416 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 159 5 0 0 10 0 0 0 121 8 0 0 164 1 0 0] 34 3 544 7792 976 896 nil 27 )! !
!JadeiteMethodListPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

