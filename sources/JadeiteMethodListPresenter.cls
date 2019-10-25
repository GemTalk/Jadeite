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
	^gciSession oopTypeWithOop: classService oop!

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
			to: self search!

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
	self selecting: stringOrIndex!

methods: services selectingAnyMatch: string
	services isEmpty ifTrue: [^self].
	methodListPresenter
		list: (ListModel withAll: services);
		selectFirstMethod.
	self selectingAnyMatch: string!

onCloseRequested: aCloseEvent
	aCloseEvent value: (methodSourcePresenter documentPresenter view isModified
				ifTrue: [methodSourcePresenter isOkayToChange]
				ifFalse: [true])!

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
	^super queryCommand: aCommandQuery!

registerPresentersForUpdates
	BrowserUpdate current register: self selector: #autoCommitUpdate:!

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
	comparisonPresenter
		beforeTitle: (methodListPresenter selections at: 1) classMethodDisplayString;
		afterTitle: (methodListPresenter selections at: 2) classMethodDisplayString;
		compare: (methodListPresenter selections at: 1) source
			with: (methodListPresenter selections at: 2) source.!

updateSingleMethodSource
	| selection |
	selection := methodListPresenter selection.
	methodSourcePresenter value: selection source.
	selection firstReference ifNotNil: [:index | self selecting: index].
	methodSourcePresenter ensureVisible!

updateSource
	| selection |
	selection := methodListPresenter selectionOrNil.
	methodSourcePresenter methodService: selection.
	methodSourcePresenter update.
	self doSearch. 
	('*METHOD SOURCE CANNOT BE DISPLAYED*' match: methodSourcePresenter documentPresenter value)
		ifTrue: [methodSourcePresenter documentPresenter view backcolor: Color red faded faded].! !
!JadeiteMethodListPresenter categoriesFor: #additionalAccelerators!accessing!public! !
!JadeiteMethodListPresenter categoriesFor: #autoCommit!accessing!public! !
!JadeiteMethodListPresenter categoriesFor: #autoCommit:!accessing!public! !
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
!JadeiteMethodListPresenter categoriesFor: #onViewOpened!event handlers!public! !
!JadeiteMethodListPresenter categoriesFor: #postEditSaveMethod!menu handlers!public! !
!JadeiteMethodListPresenter categoriesFor: #queryCommand:!menu handlers!public! !
!JadeiteMethodListPresenter categoriesFor: #registerPresentersForUpdates!public!register presenters! !
!JadeiteMethodListPresenter categoriesFor: #removeComparisonTab!private!selection!text tabs! !
!JadeiteMethodListPresenter categoriesFor: #search!accessing!public! !
!JadeiteMethodListPresenter categoriesFor: #selectComparisonTab!private!selection!text tabs! !
!JadeiteMethodListPresenter categoriesFor: #selectedClassName!public!selection! !
!JadeiteMethodListPresenter categoriesFor: #selectionChanging:!event handlers!public! !
!JadeiteMethodListPresenter categoriesFor: #showComparisonTab!private!selection!text tabs! !
!JadeiteMethodListPresenter categoriesFor: #showSuperClassComparison!private!text tabs! !
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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil nil 5 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 2 410 ##(Smalltalk.ReferenceView) 34 14 nil 416 34 2 8 1140916224 131073 544 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 nil 5 nil nil nil 544 1180166 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteBasicMethodListPresenter) #resource_Default_view nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 328198 ##(Smalltalk.Point) 1 1 802 1461 271 544 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 218 2 0 0 135 0 0 0] 8 #() 802 193 193 nil 27 524806 ##(Smalltalk.Fraction) 3 5 true 170 192 34 6 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 992 nil 610 8 4278190080 nil 5 nil nil nil 992 655878 ##(Smalltalk.CardLayout) 138 144 34 2 721414 ##(Smalltalk.Association) 8 'Comparison' 410 ##(Smalltalk.ShellView) 34 27 nil 992 34 2 8 1078919168 131073 1200 nil 610 8 4278190080 nil 517 nil nil nil 1200 788230 ##(Smalltalk.BorderLayout) 1 1 nil nil nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 1200 34 2 8 1140850688 131073 1328 nil 610 1280 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 5 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #toggleIndentGuides 8 'Indentation &Guides' 1 1 nil nil nil 1458 1 1490 #toggleVisibleLineEndings 8 'Line &Endings' 1 1 nil nil nil 1458 1 1490 #toggleLineNumberMargins 8 'Line N&umbers' 1 1 nil nil nil 1458 1 1490 #toggleVisibleWhitespace 8 'W&hitespace' 1 1 nil nil nil 1458 1 1490 #toggleWrapping 8 '&Word Wrap' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil nil nil 1328 482 170 176 896 false 170 192 896 nil 690 138 144 34 2 754 #createAt:extent: 34 2 802 1 1 802 1413 447 1328 754 #contextMenu: 34 1 1424 1328 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 194 2 0 0 223 0 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 1328 34 2 8 1140850688 131073 1984 nil 610 1280 nil 5 nil nil nil 1984 1298 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 1984 34 2 8 1140850945 262145 2080 nil nil nil 5 nil nil nil 2080 nil 8 1686791472 852486 ##(Smalltalk.NullConverter) nil nil nil 690 138 144 34 2 754 #createAt:extent: 34 2 802 1 407 802 701 41 2080 754 #text: 34 1 8 '
' 2080 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 203 0 0 0 94 1 0 0 223 0 0 0] 8 #() 912 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 1984 34 2 8 1140920580 1025 2400 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 nil nil nil 2400 nil 8 4294905373 2162 nil nil 11 nil 170 192 34 12 #indentGuide 1182790 1 ##(Smalltalk.ScintillaTextStyle) 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 2626 3 786694 ##(Smalltalk.IndexedColor) 33554445 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 2626 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 2626 77 2674 33554457 2674 33554471 1 nil nil nil nil #callTip nil nil nil #normal 2626 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 2626 5 nil 2530 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 2768 2656 2784 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 2704 nil nil nil 2640 nil nil 1310982 ##(Smalltalk.DiffsScintillaStyler) 8 #() 170 192 34 2 #default 1641542 1 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 2400 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 896 nil 170 176 896 9215 nil nil nil nil 2674 33554447 nil nil 65 nil nil nil 8 '' 3 170 192 34 2 #container 2592 nil nil nil nil 1 nil 170 192 34 6 8 'indicator0' 1510470 2 ##(Smalltalk.ScintillaIndicatorStyle) 1 2400 33554459 13 false nil nil nil nil nil nil nil 8 'indicator2' 3090 5 2400 511 1 false nil nil nil nil nil nil nil 8 'indicator1' 3090 3 2400 33423361 5 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 2626 1029 nil 2530 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 2626 1027 2530 60239 2530 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2626 1031 2530 335 2530 31317503 1 nil nil nil nil #Error nil nil nil nil 690 138 144 34 7 754 #createAt:extent: 34 2 802 1 1 802 701 407 2400 754 #modificationEventMask: 8 #(4607) 2400 754 #caretPeriod: 8 #(530) 2400 754 #wordWrap: 8 #(true) 2400 754 #margins: 34 1 34 3 985158 2 ##(Smalltalk.ScintillaMargin) 1 2400 49 3 nil nil nil nil 3602 3 2400 1 nil nil 67108863 nil nil 3602 5 2400 1 nil nil nil nil nil 2400 754 #canHScroll: 8 #(false) 2400 754 #maxCompletionListHeight: 8 #(9) 2400 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 94 1 0 0 203 0 0 0] 8 #() 912 nil 29 170 192 34 4 2400 8 'before' 2080 8 'beforeTitle' nil 690 138 144 34 1 754 #createAt:extent: 34 2 802 1 1 802 701 447 1984 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 94 1 0 0 223 0 0 0] 34 2 2400 2080 912 nil 27 410 ##(Smalltalk.Splitter) 34 12 nil 1328 34 2 8 1140850688 1 4000 nil 2530 66047 nil 517 nil nil nil 4000 690 138 144 34 1 754 #createAt:extent: 34 2 802 701 1 802 11 447 4000 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 94 1 0 0 0 0 0 0 99 1 0 0 223 0 0 0] 8 #() 912 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 1328 34 2 8 1140850688 131073 4240 nil 610 1280 nil 5 nil nil nil 4240 1298 1 1 nil 410 ##(Smalltalk.StaticText) 34 16 nil 4240 34 2 8 1140850945 262145 4336 nil nil nil 5 nil nil nil 4336 nil 8 1686791472 2162 nil nil nil 690 138 144 34 2 754 #createAt:extent: 34 2 802 1 407 802 703 41 4336 754 #text: 34 1 8 '
' 4336 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 203 0 0 0 95 1 0 0 223 0 0 0] 8 #() 912 nil 27 nil nil 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 4240 34 2 8 1140920580 1025 4640 2466 nil false 2512 nil 2530 26337781 nil 5 nil nil nil 4640 nil 8 4294905373 2162 nil nil 11 nil 170 192 34 12 #indentGuide 2626 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #whitespace 2626 3 2688 nil 1 nil nil nil nil #whitespace nil nil nil #lineNumber 2626 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #callTip 2626 77 2736 2752 1 nil nil nil nil #callTip nil nil nil #normal 2626 1 nil nil 1 nil nil nil nil #normal nil nil nil #diff 2626 5 nil 2530 16908287 3 nil nil nil nil #diff nil 1401 nil 34 40 4864 4816 4880 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 4832 nil nil nil 4800 nil nil 2834 2864 170 192 34 2 #default 2914 1 nil nil nil 4640 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 896 nil 170 176 896 9215 nil nil nil nil 2976 nil nil 65 nil nil nil 2992 3 170 192 34 2 #container 4768 nil nil nil nil 1 nil 170 192 34 6 8 'indicator1' 3090 3 4640 33423361 5 false nil nil nil nil nil nil nil 8 'indicator0' 3090 1 4640 33554459 13 false nil nil nil nil nil nil nil 8 'indicator2' 3090 5 4640 511 1 false nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 2626 1029 nil 2530 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 2626 1027 2530 60239 2530 31326207 1 nil nil nil nil #Warning nil nil nil #Error 2626 1031 2530 335 2530 31317503 1 nil nil nil nil #Error nil nil nil nil 690 138 144 34 7 754 #createAt:extent: 34 2 802 1 1 802 703 407 4640 754 #modificationEventMask: 8 #(4607) 4640 754 #caretPeriod: 8 #(530) 4640 754 #wordWrap: 8 #(true) 4640 754 #margins: 34 1 34 3 3602 1 4640 49 3 nil nil nil nil 3602 3 4640 1 nil nil 67108863 nil nil 3602 5 4640 1 nil nil nil nil nil 4640 754 #canHScroll: 8 #(false) 4640 754 #maxCompletionListHeight: 8 #(9) 4640 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 95 1 0 0 203 0 0 0] 8 #() 912 nil 29 170 192 34 4 4336 8 'afterTitle' 4640 8 'after' nil 690 138 144 34 1 754 #createAt:extent: 34 2 802 711 1 802 703 447 4240 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 99 1 0 0 0 0 0 0 194 2 0 0 223 0 0 0] 34 2 4640 4336 912 nil 27 912 nil 27 170 192 34 2 1328 8 'diffs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 1410 nil true 34 4 1458 1 1490 #selectUpper 8 'Select &upper' 1 1 nil nil nil 1458 1 1490 #selectLower 8 'Select &lower' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 1458 1 1490 #exit 8 '&Close' 1 1 nil nil nil 8 '&File' nil 1 nil nil 15143 nil nil 1410 nil true 34 3 1458 1 1490 #character 8 '&Character' 1 1 nil nil nil 1458 1 1490 #word 8 '&Word' 1 1 nil nil nil 1458 1 1490 #line 8 '&Line' 1 1 nil nil nil 8 '&Mode' nil 1 nil nil 15145 nil nil 1410 nil true 34 1 1458 1 1490 #about 8 '&About' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 15147 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 690 138 144 34 3 754 #createAt:extent: 34 2 802 9 55 802 1445 479 1200 754 #text: 34 1 8 'Differences' 1200 754 #updateMenuBar 896 1200 850 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 214 2 0 0 10 1 0 0] 34 1 1328 912 nil 27 1154 8 'Method Source' 410 ##(Smalltalk.ReferenceView) 34 14 nil 992 34 2 8 1140850688 131073 6864 nil 610 8 4278190080 nil 5 nil nil nil 6864 658 ##(Smalltalk.JadeiteMethodSourcePresenter) #resource_Default_view nil 690 138 144 34 1 754 #createAt:extent: 34 2 802 9 55 802 1445 479 6864 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 214 2 0 0 10 1 0 0] 896 912 nil 27 6864 170 192 34 4 6864 8 'methodSource' 1200 8 'comparisonTab' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 992 34 2 8 1140916736 1 7184 590662 2 ##(Smalltalk.ListModel) 138 144 34 2 6848 1184 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) nil nil 1 nil nil nil 7184 nil 8 4294905175 787814 3 ##(Smalltalk.BlockClosure) 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 7376 7 257 nil 7362 0 nil 7394 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 7440 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #noIcons nil nil nil nil nil 690 138 144 34 3 754 #createAt:extent: 34 2 802 1 1 802 1461 541 7184 754 #basicSelectionsByIndex: 34 1 8 #(1) 7184 754 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 7184 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 218 2 0 0 14 1 0 0] 8 #() 912 nil 27 690 138 144 34 2 754 #createAt:extent: 34 2 802 1 281 802 1461 541 992 754 #text: 34 1 8 'textAreaTabs' 992 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 140 0 0 0 218 2 0 0 154 1 0 0] 34 3 6864 1200 7184 912 nil 27 8 'textAreaTabs' 544 8 'methodList' 410 ##(Smalltalk.Splitter) 34 12 nil 416 34 2 8 1140850688 1 8000 nil 610 8 4278190080 nil 517 nil nil nil 8000 690 138 144 34 1 754 #createAt:extent: 34 2 802 1 271 802 1461 11 8000 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 135 0 0 0 218 2 0 0 140 0 0 0] 8 #() 912 nil 27 8 'Splitter' nil 690 138 144 34 1 754 #createAt:extent: 34 2 802 7679 21 802 1461 821 416 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 217 17 0 0 164 1 0 0] 34 3 544 8000 992 912 nil 27 )! !
!JadeiteMethodListPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

