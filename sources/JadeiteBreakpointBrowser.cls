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

addMethodServicesToTree: methodServices
	| sortedMethodServices |
	sortedMethodServices := methodServices asSortedCollection: 
					[:x :y |
					x className = y className ifTrue: [x selector < y selector] ifFalse: [x className < y className]].
	sortedMethodServices do: 
			[:methodService |
			methodService breakPoints isEmpty
				ifFalse: 
					[breakpointListPresenter model getNodeFor: methodService className
						ifAbsent: [breakpointListPresenter model addRoot: methodService className].
					breakpointListPresenter model add: methodService asChildOf: methodService className.
					breakpointListPresenter view expand: methodService className]]!

allMethodServices
	^breakpointListPresenter model asBag select: [:object | object isMethodService]!

clearMethodBreakpoints
	| methodServices |
	methodServices := self selectedMethodServices asOrderedCollection.
	methodServices addAll: (self allMethodServices
				select: [:methodService | self selectedClassServices includes: methodService className]).
	^JadePresenter clearMethodBreakpoints: methodServices in: self gciSession!

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
	| service methodServices |
	service := RowanQueryService command: #breakPointMethods withArgs: Array new.
	BrowserUpdate current issueCommands: (Array with: service) session: self gciSession.
	methodServices := service queryResults.
	self addMethodServicesToTree: methodServices.
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
	methodSourcePresenter gciSession: gciSession.
	self registerPresentersForUpdates!

queryCommand: aCommandQuery
	#clearMethodBreakpoints == aCommandQuery command
		ifTrue: 
			[aCommandQuery isEnabled: breakpointListPresenter selections notEmpty.
			^true].
	^super queryCommand: aCommandQuery!

registerPresentersForUpdates
	BrowserUpdate current
		register: breakpointListPresenter
			selector: #updateBreakPoints:browser:
			browser: self;
		register: breakpointListPresenter
			selector: #updatedClass:browser:
			browser: self;
		register: breakpointListPresenter
			selector: #methodListUpdate:browser:
			browser: self!

removeClass: classService
	breakpointListPresenter model asBag do: 
			[:object |
			object isMethodService not
				ifTrue: 
					[(object = classService name
						and: [(breakpointListPresenter model getNodeFor: object) children isEmpty])
							ifTrue: [breakpointListPresenter model remove: object ifAbsent: []]]]!

removeMethodServices: methodServices
	| methodServicesWithoutBreakpoints shouldRemoveParent missingParents |
	missingParents := Set new.
	methodServicesWithoutBreakpoints := methodServices
				select: [:methodService | methodService breakPoints isEmpty].
	breakpointListPresenter model asBag do: 
			[:object |
			(methodServicesWithoutBreakpoints includes: object)
				ifTrue: 
					[shouldRemoveParent := (breakpointListPresenter model getNodeFor: object) parent children size = 1.
					breakpointListPresenter model remove: object ifAbsent: [].
					shouldRemoveParent ifTrue: [missingParents add: object className]]].
	missingParents do: [:parentName | breakpointListPresenter model remove: parentName ifAbsent: []]!

removeMethodsNoLongerIn: classService
	breakpointListPresenter model asBag do: 
			[:object |
			(object isMethodService and: [classService name = object className])
				ifTrue: 
					[classService methods detect: [:methodService | methodService = object]
						ifNone: [breakpointListPresenter model remove: object ifAbsent: []]]]!

removeMethodsWithoutBreakpointsIn: classService
	classService methods do: 
			[:methodService |
			| methodServiceNode |
			methodServiceNode := breakpointListPresenter model getNodeFor: methodService ifAbsent: [].
			methodServiceNode
				ifNotNil: 
					[:node |
					methodService breakPoints isEmpty ifTrue: [breakpointListPresenter model remove: methodService]]]!

resetSourcePane
	methodSourcePresenter value: String new.
	methodSourcePresenter documentPresenter view backcolor: JadeiteTextStyles default colorForNoEdits!

selectedClassServices
	^breakpointListPresenter selections select: [:object | object isMethodService not]!

selectedMethodServices
	^breakpointListPresenter selections select: [:object | object isMethodService]!

statusBarText: aString

	"do nothing for now" !

updateClass: classService
	self removeMethodsWithoutBreakpointsIn: classService.
	self removeMethodsNoLongerIn: classService.
	self removeClass: classService.
	self addMethodServicesToTree: classService methods.
	breakpointListPresenter view invalidate!

updateMethodList: methodService
	| methodServices |
	methodServices := Array with: methodService.
	self updateMethodServicesFrom: methodServices. 
	self addMethodServicesToTree: methodServices.
	self removeMethodServices: methodServices!

updateMethodServicesFrom: methodServices
	breakpointListPresenter model asBag do: 
			[:object |
			object isMethodService
				ifTrue: 
					[methodServices
						do: [:methodService | object replicateFrom: methodService	"replicateFrom: will take care of equality test"]]]! !
!JadeiteBreakpointBrowser categoriesFor: #aboutToChange:!event handlers!public! !
!JadeiteBreakpointBrowser categoriesFor: #addMethodServicesToTree:!event handlers support!private!updating support! !
!JadeiteBreakpointBrowser categoriesFor: #allMethodServices!accessing!private! !
!JadeiteBreakpointBrowser categoriesFor: #clearMethodBreakpoints!menu handlers!public! !
!JadeiteBreakpointBrowser categoriesFor: #createComponents!initialization!public! !
!JadeiteBreakpointBrowser categoriesFor: #createSchematicWiring!initialization!public! !
!JadeiteBreakpointBrowser categoriesFor: #initialize!initialization!public! !
!JadeiteBreakpointBrowser categoriesFor: #initializeMethods!event handlers support!initialization!private! !
!JadeiteBreakpointBrowser categoriesFor: #methodListSelection!public!selection! !
!JadeiteBreakpointBrowser categoriesFor: #methodSelected!event handlers!public! !
!JadeiteBreakpointBrowser categoriesFor: #onCloseRequested:!event handlers!public! !
!JadeiteBreakpointBrowser categoriesFor: #onViewOpened!event handlers!public! !
!JadeiteBreakpointBrowser categoriesFor: #queryCommand:!menu handlers support!public! !
!JadeiteBreakpointBrowser categoriesFor: #registerPresentersForUpdates!public!register presenters! !
!JadeiteBreakpointBrowser categoriesFor: #removeClass:!public!updating support! !
!JadeiteBreakpointBrowser categoriesFor: #removeMethodServices:!public!updating support! !
!JadeiteBreakpointBrowser categoriesFor: #removeMethodsNoLongerIn:!public!updating support! !
!JadeiteBreakpointBrowser categoriesFor: #removeMethodsWithoutBreakpointsIn:!public!updating support! !
!JadeiteBreakpointBrowser categoriesFor: #resetSourcePane!event handlers support!private! !
!JadeiteBreakpointBrowser categoriesFor: #selectedClassServices!accessing!private! !
!JadeiteBreakpointBrowser categoriesFor: #selectedMethodServices!accessing!private! !
!JadeiteBreakpointBrowser categoriesFor: #statusBarText:!accessing!public! !
!JadeiteBreakpointBrowser categoriesFor: #updateClass:!public!updating! !
!JadeiteBreakpointBrowser categoriesFor: #updateMethodList:!public!updating! !
!JadeiteBreakpointBrowser categoriesFor: #updateMethodServicesFrom:!public!updating support! !

!JadeiteBreakpointBrowser class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1861 1371 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 592 nil nil nil 7 nil nil nil 592 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 2 410 ##(Smalltalk.ListTreeView) 34 44 nil 592 34 2 8 1149358155 1 720 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 265030 4 ##(Smalltalk.Menu) nil true 34 1 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #clearMethodBreakpoints 8 'Clear Method Breakpoints' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 720 nil 8 1660151920 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 5 1 1040 8 'doIt' 8 '[:object | object  isMethodService ifTrue:[object 
displayStringWithBreakpointCount] ifFalse:[ object displayString]]' 8 #[33 105 226 0 120 226 1 106 226 3 106] #isMethodService #displayStringWithBreakpointCount #ifTrue:ifFalse: #displayString 1056 7 257 nil nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 1 920646 5 ##(Smalltalk.ListViewColumn) 8 'Column 1' 903 #left 1042 0 nil 1074 5 1 ##(Smalltalk.Message) 8 'doIt' 8 '[:object | object isMethodService ifTrue:[object displayStringWithBreakpointCount] ifFalse: [object printString]]' 8 #[33 105 226 0 120 226 1 106 226 3 106] #isMethodService #displayStringWithBreakpointCount #ifTrue:ifFalse: #printString 1264 7 257 nil 459270 ##(Smalltalk.Message) #<= 832 nil nil 720 nil 3 nil nil #list 832 1 353 nil 34 4 nil nil 498 1 1 nil false 1050438 3 ##(Smalltalk.VirtualTreeModel) nil 864 138 144 832 1042 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 1408 #defaultGetChildrenBlock 304967395 8 #[30 105 226 0 106] #children 1456 7 257 nil 1042 0 nil 1474 2 3 1408 #defaultGetParentBlock 304973091 8 #[30 105 226 0 106] #parent 1520 7 257 nil 1042 0 nil 1474 2 3 1408 #defaultHasChildrenBlock 304978627 8 #[252 1 0 0 1 4 0 65 176 159 106 105] #childrenOf: #notEmpty 17 257 1424 1042 0 nil 1474 1 83886083 1408 #defaultFilterBlock 304961123 8 #[29 105 17 157 106] 1616 7 257 nil nil 138 ##(Smalltalk.IdentitySet) 832 138 ##(Smalltalk.IdentitySet) 832 45 1 nil nil nil nil nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 1 1 498 911 1199 720 1762 #contextMenu: 34 1 896 720 1762 #text: 34 1 8 'Column 1' 720 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 199 1 0 0 87 2 0 0] 8 #() 498 193 193 nil 2021 3 false 170 192 34 4 720 8 'breakpointListPresenter' 410 ##(Smalltalk.ContainerView) 34 15 nil 592 34 2 8 1417674752 131073 2048 nil nil nil 7 nil nil nil 2048 530 170 176 34 4 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 2048 34 2 8 1445007428 1025 2160 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 480 nil 7 882 nil true 34 22 930 1 962 #undo 8 '&Undo' 9397 1 nil nil nil 930 1 962 #redo 8 'R&edo' 9395 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 930 1 962 #editCut 8 'Cu&t' 9393 1 nil nil nil 930 1 962 #editCopy 8 '&Copy' 9351 1 nil nil nil 930 1 962 #editPaste 8 '&Paste' 9389 1 nil nil nil 930 1 962 #editDelete 8 'De&lete' 1629 1 nil nil nil 930 1 962 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 2418 4097 930 1 962 #editFind 8 '&Find...' 9357 1 nil nil nil 930 1 962 #editFindNext 8 'Find &Next' 9359 1 nil nil nil 930 1 962 #editReplace 8 '&Replace...' 9361 1 nil nil nil 2418 4097 930 1 962 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 930 1 962 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 930 1 962 #jadeExecute 8 'Execute' 9355 1 nil nil nil 930 1 962 #jadeDebug 8 'De&bug' 9349 1 nil nil nil 2418 4097 930 1 962 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 930 1 962 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 2418 4097 930 1 962 #fileIn 8 'File In' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 498 193 193 nil 2160 nil 8 1631769023 852486 ##(Smalltalk.NullConverter) nil nil 13 nil 170 192 34 4 #normal 1182790 1 ##(Smalltalk.ScintillaTextStyle) 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 3426 77 466 #gray 466 #white 1 nil nil nil nil #callTip nil nil nil 34 256 3440 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3456 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 832 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 2160 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 832 nil 170 176 832 9215 nil nil nil nil 466 #silver nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 4 #normal 3440 #callTip 3456 nil nil nil nil 1 nil 170 192 34 12 1 1510470 3 ##(Smalltalk.ScintillaIndicatorStyle) 1 2160 196934 1 ##(Smalltalk.RGB) 65025 3 false 1 nil nil nil nil nil nil 3 3874 3 2160 466 #blue 5 false 3 nil nil nil nil nil nil 8 'indicator8' 3874 17 2160 3664 1 nil nil nil nil nil nil nil nil 8 'indicator9' 3874 19 2160 466 #red 13 nil nil nil nil nil nil nil nil 8 'indicator10' 3874 21 2160 4032 3 nil nil nil nil nil nil nil nil 5 3874 5 2160 4032 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 3426 1027 3906 60239 3906 31326207 1 nil nil nil nil #Warning nil nil nil #Error 3426 1031 3906 335 3906 31317503 1 nil nil nil nil #Error nil nil nil #Notification 3426 1029 nil 3906 31185883 1 nil nil nil nil #Notification nil nil nil nil 1698 138 144 34 11 1762 #createAt:extent: 34 2 498 1 51 498 907 1145 2160 1762 #contextMenu: 34 1 2288 2160 1762 #textLimit: 8 #(1073741823) 2160 1762 #hoverTime: 8 #(200) 2160 1762 #caretPeriod: 8 #(530) 2160 1762 #wordWrap: 8 #(true) 2160 1762 #margins: 34 1 34 3 985158 3 ##(Smalltalk.ScintillaMargin) 1 2160 61 3 nil nil nil nil 4578 3 2160 1 nil 3 67108863 nil nil 4578 5 2160 1 nil 3 -67108863 nil nil 2160 1762 #canHScroll: 8 #(false) 2160 1762 #tabWidth: 8 #(4) 2160 1762 #maxCompletionListHeight: 8 #(9) 2160 1762 #edgeColumn: 8 #(1) 2160 1922 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 197 1 0 0 85 2 0 0] 8 #() 1984 nil 29 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 4850 #fixedParentRight 1 4850 #fixedPreviousBottom 1 4850 #fixedParentBottom 1 410 ##(Smalltalk.Toolbar) 34 25 nil 2048 34 2 8 1140851500 131137 4928 nil 480 nil 519 nil 3250 nil true 3282 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 498 193 193 nil 4928 480 8 1660202272 170 192 832 170 192 34 24 60653 1246790 1 ##(Smalltalk.ToolbarSystemButton) 4928 1 962 #editDelete 8 'Delete' 1 1 nil 60653 1 11 60647 5122 4928 1 962 #editCut 8 'Cut' 1 1 nil 60647 1 1 60657 5122 4928 1 962 #redo 8 'Redo' 1 1 nil 60657 1 9 60641 1246790 1 ##(Smalltalk.ToolbarBitmapButton) 4928 1 962 #jadeExecute 8 'Execute' 9355 1 nil 60641 395334 3 ##(Smalltalk.Bitmap) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'Tools.bmp' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil nil 7 498 1857 33 57 60651 5122 4928 1 962 #editPaste 8 'Paste' 1 1 nil 60651 1 5 60661 5122 4928 1 962 #editReplace 8 'Replace' 1 1 nil 60661 1 27 60645 5122 4928 1 962 #editSaveMethod 8 'Save' 9383 1 nil 60645 1 17 60655 5122 4928 1 962 #undo 8 'Undo' 1 1 nil 60655 1 7 60639 5282 4928 1 962 #jadeDisplay 8 'Display' 9353 1 nil 60639 5360 55 60649 5122 4928 1 962 #copySelection 8 'Copy' 1 1 nil 60649 1 3 60659 5122 4928 1 962 #editFind 8 'Find' 1 1 nil 60659 1 25 60643 5282 4928 1 962 #jadeInspect 8 'Inspect' 9379 1 nil 60643 5360 59 34 15 5680 5296 5824 1049158 1 ##(Smalltalk.ToolbarSeparator) 4928 1 5584 5890 4928 1 5184 5728 5488 5136 5632 5232 5890 4928 1 5776 5536 nil nil 1 nil 498 33 33 498 45 45 nil nil 1698 138 144 34 2 1762 #createAt:extent: 34 2 498 1 1 498 907 51 4928 1762 #updateSizePosted 832 4928 1922 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 197 1 0 0 25 0 0 0] 8 #() 1984 nil 27 4818 4864 1 4880 1 4850 #fixedParentTop 1 4850 #fixedViewTop 51 170 192 34 2 2160 8 'document' nil 1698 138 144 34 1 1762 #createAt:extent: 34 2 498 911 1 498 911 1199 2048 1922 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 199 1 0 0 0 0 0 0 142 3 0 0 87 2 0 0] 34 2 4928 2160 1984 nil 27 8 'methodSourcePresenter' nil 1698 138 144 34 1 1762 #createAt:extent: 34 2 498 5 1 498 1821 1199 592 1922 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 2 0 0 0 0 0 0 0 144 3 0 0 87 2 0 0] 34 2 720 2048 1984 nil 27 4818 4864 5 4880 -3 6176 1 4912 -53 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 6608 nil nil nil 7 nil nil nil 6608 658 170 176 832 false 170 192 34 2 410 ##(Smalltalk.TextEdit) 34 16 nil 6608 34 2 8 1140850688 1 6736 nil 480 nil 7 nil 3250 nil true 3282 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 498 193 193 nil 6736 466 #black 8 1660100096 3362 nil nil 67 1698 138 144 34 2 1762 #createAt:extent: 34 2 498 1 1 498 1829 51 6736 1762 #setMarginWidths: 34 1 8 #(3 3) 6736 1922 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 146 3 0 0 25 0 0 0] 8 #() 1984 nil 27 8 'statusBarField' nil 1698 138 144 34 1 1762 #createAt:extent: 34 2 498 1 1203 498 1829 51 6608 1922 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 89 2 0 0 146 3 0 0 114 2 0 0] 34 1 6736 1984 nil 27 4818 4864 1 4880 1 4912 -49 4912 1 170 192 832 nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 2 882 nil true 8 #() 8 'Jadeite' nil 134217729 nil nil 60635 nil nil 882 nil true 8 #() 8 'Breakpoint' nil 134217729 nil nil 60637 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1698 138 144 34 3 1762 #createAt:extent: 34 2 498 7679 21 498 1861 1371 416 1762 #text: 34 1 8 'Jadeite Breakpoint Browser' 416 1762 #updateMenuBar 832 416 1922 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 161 18 0 0 183 2 0 0] 34 2 592 6608 1984 nil 27 )! !
!JadeiteBreakpointBrowser class categoriesFor: #resource_Default_view!public!resources-views! !

