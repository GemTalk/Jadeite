"Filed out from Dolphin Smalltalk 7"!

JadeShell subclass: #JadeiteBreakpointBrowser
	instanceVariableNames: 'breakpointListPresenter methodSourcePresenter'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteBreakpointBrowser guid: (GUID fromString: '{b21049e4-05e7-4a1f-91e7-569f6579f13f}')!
JadeiteBreakpointBrowser comment: ''!
!JadeiteBreakpointBrowser categoriesForClass!Unclassified! !
!JadeiteBreakpointBrowser methodsFor!

aboutToChange: aSelectionChangingEvent
	aSelectionChangingEvent value
		ifTrue: [aSelectionChangingEvent value: methodSourcePresenter isOkayToChange]!

createComponents
	breakpointListPresenter := self add: TreePresenter new name: 'breakpointListPresenter'.
	methodSourcePresenter := self add: JadeiteMethodSourcePresenter new name: 'methodSourcePresenter'.!

createSchematicWiring
	super createSchematicWiring.
	breakpointListPresenter
		when: #selectionChanged
			send: #methodSelected
			to: self;
		when: #selectionChanging:
			send: #aboutToChange:
			to: self.
	self
		when: #closeRequested:
		send: #onCloseRequested:
		to: self!

initialize
	super initialize.
	breakpointListPresenter model: (TreeModel new
				searchPolicy: SearchPolicy equality;
				reset)!

initializeMethods
	| service treeModel sortedMethodServices |
	service := RowanQueryService command: #breakPointMethods withArgs: Array new.
	BrowserUpdate current issueCommands: (Array with: service) session: self gciSession.
	treeModel := breakpointListPresenter model.
	breakpointListPresenter model: treeModel.
	sortedMethodServices := service queryResults asSortedCollection: 
					[:x :y |
					x className = y className ifTrue: [x selector < y selector] ifFalse: [x className < y className]].
	sortedMethodServices do: 
			[:methodService |
			treeModel getNodeFor: methodService className
				ifAbsent: [treeModel add: methodService className asChildOf: nil].
			treeModel add: methodService asChildOf: methodService className].
	breakpointListPresenter view expandAll!

methodListSelection
	"assume the first selection is a valid methodService"

	^breakpointListPresenter selections first!

methodSelected
	breakpointListPresenter selections notEmpty
		ifTrue: 
			[| selections |
			selections := breakpointListPresenter selections select: [:each | each isMethodService].
			selections isEmpty ifTrue: [^self resetSourcePane].
			methodSourcePresenter methodService: selections first.
			methodSourcePresenter value: selections first source.
			methodSourcePresenter basicRefreshBreakpointsIn: methodSourcePresenter documentPresenter
				selection: selections first.
			methodSourcePresenter methodValueChanged]
		ifFalse: [^self resetSourcePane]!

onCloseRequested: aCloseEvent
	aCloseEvent value: (methodSourcePresenter documentPresenter view isModified
				ifTrue: [methodSourcePresenter isOkayToChange]
				ifFalse: [true])!

onViewOpened
	super onViewOpened.
	self updateCaption: 'Breakpoint Browser'.
	self initializeMethods.
	methodSourcePresenter gciSession: gciSession!

resetSourcePane
	methodSourcePresenter value: String new.
	methodSourcePresenter documentPresenter view backcolor: JadeiteTextStyles default colorForNoEdits!

statusBarText: aString

	"do nothing for now" ! !
!JadeiteBreakpointBrowser categoriesFor: #aboutToChange:!event handlers!public! !
!JadeiteBreakpointBrowser categoriesFor: #createComponents!initialization!public! !
!JadeiteBreakpointBrowser categoriesFor: #createSchematicWiring!initialization!public! !
!JadeiteBreakpointBrowser categoriesFor: #initialize!initialization!public! !
!JadeiteBreakpointBrowser categoriesFor: #initializeMethods!event handlers support!public! !
!JadeiteBreakpointBrowser categoriesFor: #methodListSelection!public!selection! !
!JadeiteBreakpointBrowser categoriesFor: #methodSelected!event handlers!public! !
!JadeiteBreakpointBrowser categoriesFor: #onCloseRequested:!event handlers!public! !
!JadeiteBreakpointBrowser categoriesFor: #onViewOpened!event handlers!public! !
!JadeiteBreakpointBrowser categoriesFor: #resetSourcePane!event handlers support!private! !
!JadeiteBreakpointBrowser categoriesFor: #statusBarText:!accessing!public! !

!JadeiteBreakpointBrowser class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1861 1371 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 592 nil nil nil 7 nil nil nil 592 656390 ##(Smalltalk.GridLayout) 3 5 1 1 170 192 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 592 34 2 8 1417674752 131073 720 nil nil nil 7 nil nil nil 720 530 170 176 34 4 410 ##(Smalltalk.Toolbar) 34 25 nil 720 34 2 8 1140851500 131137 832 nil 480 nil 519 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 498 193 193 nil 832 480 8 1660202272 170 192 8 #() 170 192 34 24 52909 1246790 1 ##(Smalltalk.ToolbarSystemButton) 832 1 1180998 4 ##(Smalltalk.CommandDescription) #editReplace 8 'Replace' 1 1 nil 52909 1 27 52893 1074 832 1 1106 #editSaveMethod 8 'Save' 9383 1 nil 52893 1 17 52903 1074 832 1 1106 #undo 8 'Undo' 1 1 nil 52903 1 7 52887 1246790 1 ##(Smalltalk.ToolbarBitmapButton) 832 1 1106 #jadeDisplay 8 'Display' 9353 1 nil 52887 395334 3 ##(Smalltalk.Bitmap) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'Tools.bmp' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil nil 7 498 1857 33 55 52897 1074 832 1 1106 #copySelection 8 'Copy' 1 1 nil 52897 1 3 52907 1074 832 1 1106 #editFind 8 'Find' 1 1 nil 52907 1 25 52891 1250 832 1 1106 #jadeInspect 8 'Inspect' 9379 1 nil 52891 1328 59 52901 1074 832 1 1106 #editDelete 8 'Delete' 1 1 nil 52901 1 11 52895 1074 832 1 1106 #editCut 8 'Cut' 1 1 nil 52895 1 1 52905 1074 832 1 1106 #redo 8 'Redo' 1 1 nil 52905 1 9 52889 1250 832 1 1106 #jadeExecute 8 'Execute' 9355 1 nil 52889 1328 57 52899 1074 832 1 1106 #editPaste 8 'Paste' 1 1 nil 52899 1 5 34 15 1264 1744 1552 1049158 1 ##(Smalltalk.ToolbarSeparator) 832 1 1152 1858 832 1 1648 1456 1792 1600 1200 1696 1858 832 1 1504 1088 nil nil 1 nil 498 33 33 498 45 45 nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 1 1 498 911 51 832 2018 #updateSizePosted 1024 832 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 199 1 0 0 25 0 0 0] 8 #() 498 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 2226 #fixedParentRight 1 2226 #fixedParentTop 1 2226 #fixedViewTop 51 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 720 34 2 8 1445007428 1025 2304 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 480 nil 7 265030 4 ##(Smalltalk.Menu) nil true 34 22 984134 2 ##(Smalltalk.CommandMenuItem) 1 1106 #undo 8 '&Undo' 9397 1 nil nil nil 2482 1 1106 #redo 8 'R&edo' 9395 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 2482 1 1106 #editCut 8 'Cu&t' 9393 1 nil nil nil 2482 1 1106 #editCopy 8 '&Copy' 9351 1 nil nil nil 2482 1 1106 #editPaste 8 '&Paste' 9389 1 nil nil nil 2482 1 1106 #editDelete 8 'De&lete' 1629 1 nil nil nil 2482 1 1106 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 2594 4097 2482 1 1106 #editFind 8 '&Find...' 9357 1 nil nil nil 2482 1 1106 #editFindNext 8 'Find &Next' 9359 1 nil nil nil 2482 1 1106 #editReplace 8 '&Replace...' 9361 1 nil nil nil 2594 4097 2482 1 1106 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 2482 1 1106 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 2482 1 1106 #jadeExecute 8 'Execute' 9355 1 nil nil nil 2482 1 1106 #jadeDebug 8 'De&bug' 9349 1 nil nil nil 2594 4097 2482 1 1106 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 2482 1 1106 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 2594 4097 2482 1 1106 #fileIn 8 'File In' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil 898 nil true 930 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 498 193 193 nil 2304 nil 8 1631769023 852486 ##(Smalltalk.NullConverter) nil nil 13 nil 170 192 34 4 #normal 1182790 1 ##(Smalltalk.ScintillaTextStyle) 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 3570 77 466 #gray 466 #white 1 nil nil nil nil #callTip nil nil nil 34 256 3584 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3600 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 1024 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 2304 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 1024 nil 170 176 1024 9215 nil nil nil nil 466 #silver nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 4 #normal 3584 #callTip 3600 nil nil nil nil 1 nil 170 192 34 12 1 1510470 3 ##(Smalltalk.ScintillaIndicatorStyle) 1 2304 196934 1 ##(Smalltalk.RGB) 65025 3 false 1 nil nil nil nil nil nil 3 4018 3 2304 466 #blue 5 false 3 nil nil nil nil nil nil 8 'indicator8' 4018 17 2304 3808 1 nil nil nil nil nil nil nil nil 8 'indicator9' 4018 19 2304 466 #red 13 nil nil nil nil nil nil nil nil 8 'indicator10' 4018 21 2304 4176 3 nil nil nil nil nil nil nil nil 5 4018 5 2304 4176 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 3570 1027 4050 60239 4050 31326207 1 nil nil nil nil #Warning nil nil nil #Error 3570 1031 4050 335 4050 31317503 1 nil nil nil nil #Error nil nil nil #Notification 3570 1029 nil 4050 31185883 1 nil nil nil nil #Notification nil nil nil nil 1954 138 144 34 11 2018 #createAt:extent: 34 2 498 1 51 498 911 1143 2304 2018 #contextMenu: 34 1 2448 2304 2018 #textLimit: 8 #(1073741823) 2304 2018 #hoverTime: 8 #(200) 2304 2018 #caretPeriod: 8 #(530) 2304 2018 #wordWrap: 8 #(true) 2304 2018 #margins: 34 1 34 3 985158 3 ##(Smalltalk.ScintillaMargin) 1 2304 61 3 nil nil nil nil 4722 3 2304 1 nil 3 67108863 nil nil 4722 5 2304 1 nil 3 -67108863 nil nil 2304 2018 #canHScroll: 8 #(false) 2304 2018 #tabWidth: 8 #(4) 2304 2018 #maxCompletionListHeight: 8 #(9) 2304 2018 #edgeColumn: 8 #(1) 2304 2114 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 199 1 0 0 84 2 0 0] 8 #() 2176 nil 29 2194 2240 1 2256 1 2226 #fixedPreviousBottom 1 2226 #fixedParentBottom 1 170 192 34 2 2304 8 'document' nil 1954 138 144 34 1 2018 #createAt:extent: 34 2 498 915 1 498 915 1197 720 2114 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 201 1 0 0 0 0 0 0 146 3 0 0 86 2 0 0] 34 2 832 2304 2176 nil 27 8 'methodSourcePresenter' 410 ##(Smalltalk.TreeView) 34 27 nil 592 34 2 8 1149309479 1 5232 590918 3 ##(Smalltalk.TreeModel) nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 525062 ##(Smalltalk.TreeNode) nil nil nil 170 192 1024 480 nil 7 nil nil nil 5232 nil 8 1660723264 459270 ##(Smalltalk.Message) #displayString 8 #() nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil 170 176 1024 33 #noIcons 1 170 ##(Smalltalk.PluggableLookupTable) 1024 1954 138 144 34 1 2018 #createAt:extent: 34 2 498 1 1 498 915 1197 5232 2114 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 201 1 0 0 86 2 0 0] 8 #() 2176 nil 27 8 'breakpointListPresenter' nil 1954 138 144 34 1 2018 #createAt:extent: 34 2 498 1 1 498 1829 1197 592 2114 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 146 3 0 0 86 2 0 0] 34 2 5232 720 2176 nil 27 2194 2240 1 2226 #fixedViewLeft 1829 2272 1 2288 1197 410 ##(Smalltalk.TextEdit) 34 16 nil 416 34 2 8 1140850688 1 5904 nil 480 nil 7 nil 898 nil true 930 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 498 193 193 nil 5904 466 #black 8 1660100096 3506 nil nil 67 1954 138 144 34 2 2018 #createAt:extent: 34 2 498 5 1199 498 1825 51 5904 2018 #setMarginWidths: 34 1 8 #(3 3) 5904 2114 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 2 0 0 0 87 2 0 0 146 3 0 0 112 2 0 0] 8 #() 2176 nil 27 2194 2240 5 5888 1825 2272 1199 2288 51 170 192 34 2 5904 8 'statusBarField' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 2 2434 nil true 8 #() 8 'Jadeite' nil 134217729 nil nil 52883 nil nil 2434 nil true 8 #() 8 'Breakpoint' nil 134217729 nil nil 52885 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1954 138 144 34 3 2018 #createAt:extent: 34 2 498 7679 21 498 1861 1371 416 2018 #text: 34 1 8 'Jadeite Breakpoint Browser' 416 2018 #updateMenuBar 1024 416 2114 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 161 18 0 0 183 2 0 0] 34 2 592 5904 2176 nil 27 )! !
!JadeiteBreakpointBrowser class categoriesFor: #resource_Default_view!public!resources-views! !

