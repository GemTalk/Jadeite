"Filed out from Dolphin Smalltalk 7"!

JadeShell subclass: #JadeiteBreakpointBrowser
	instanceVariableNames: 'breakpointListPresenter methodSourcePresenter search areBreakpointsEnabled'
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

additionalAccelerators
	^#(#(#editSaveMethod 'Ctrl+S'))!

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

areBreakpointsEnabled
	^areBreakpointsEnabled!

basicBrowseMethod: selectedMethodService
	| shell |
	shell := JadeiteBrowser showOnSession: gciSession.
	shell currentCard
		updateAfterFindClass: (RowanClassService new name: selectedMethodService className).
	selectedMethodService meta ifTrue: [shell currentCard selectClassTab].
	shell currentCard findMethod: selectedMethodService selector.
	^shell!

browseBreakpointMethods
	^JadePresenter browseBreakpointsIn: self gciSession!

browseClass
	| shell selectedClassName |
	selectedClassName := self selectedClassServices first.
	shell := JadeiteBrowser showOnSession: gciSession.
	shell currentCard updateAfterFindClass: (RowanClassService new name: selectedClassName).
	^shell!

browseClassOrMethod
	self selectedClassServices notEmpty ifTrue: [^self browseClass].
	self selectedMethodServices notEmpty ifTrue: [^self browseMethod]!

browseMethod
	| selectedMethodService |
	selectedMethodService := self selectedMethodServices first.
	^self basicBrowseMethod: selectedMethodService!

clearAllBreakpoints
	^JadePresenter clearAllBreakpointsIn: self gciSession!

clearBreakpoints
	| methodServices |
	methodServices := self selectedMethodServices asOrderedCollection.
	methodServices addAll: (self methodServicesWithBreakpoints
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
			to: self;
		when: #closeRequested:
			send: #onCloseRequested:
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

disableAllBreakpoints
	^JadePresenter disableAllBreakpointsIn: self gciSession!

disableBreakpoints
	| methodServices |
	methodServices := self selectedMethodServices asOrderedCollection.
	methodServices addAll: (self methodServicesWithBreakpoints
				select: [:methodService | self selectedClassServices includes: methodService className]).
	^JadePresenter disableMethodBreakpoints: methodServices in: self gciSession!

editSaveMethod
	| selection |
	selection := breakpointListPresenter selections first.
	methodSourcePresenter editSaveMethod.
	self basicBrowseMethod: selection!

enableAllBreakpoints
	^JadePresenter enableAllBreakpointsIn: self gciSession!

enableBreakpoints
	| methodServices |
	methodServices := self selectedMethodServices asOrderedCollection.
	methodServices addAll: (self methodServicesWithBreakpoints
				select: [:methodService | self selectedClassServices includes: methodService className]).
	^JadePresenter enableMethodBreakpoints: methodServices in: self gciSession!

flipBreakpointsEnabled
	| answeringService | 
	answeringService := RowanAnsweringService new.
	answeringService setBreakpointsEnabled: areBreakpointsEnabled value not session: self gciSession!

initialize
	super initialize.
	self resetBreakpointList.
	areBreakpointsEnabled := ValueHolder with: true!

initializeMethods
	| service methodServices |
	service := RowanQueryService command: #breakPointMethods withArgs: Array new.
	BrowserUpdate current issueCommands: (Array with: service) session: self gciSession.
	methodServices := service queryResults.
	self addMethodServicesToTree: methodServices.
	breakpointListPresenter view expandAll!

methodListSelection
	
	^breakpointListPresenter selections isEmpty ifTrue:[nil] ifFalse:[breakpointListPresenter selections first]!

methodSelected
	breakpointListPresenter selections notEmpty
		ifTrue: 
			[| selections |
			breakpointListPresenter selections size > 1 ifTrue: [^self resetSourcePane].
			selections := breakpointListPresenter selections select: [:each | each isMethodService].
			selections isEmpty ifTrue: [^self resetSourcePane].
			selections first source isNil ifTrue: [self updateSelection: selections first].
			methodSourcePresenter methodService: selections first.
			methodSourcePresenter value: selections first source.
			methodSourcePresenter basicRefreshBreakpointsIn: methodSourcePresenter documentPresenter
				selection: selections first.
			methodSourcePresenter methodValueChanged]
		ifFalse: [^self resetSourcePane]!

methodServicesWithBreakpoints
	^breakpointListPresenter model asBag
		select: [:object | object isMethodService and: [object breakPoints notEmpty]]!

methodServicesWithoutBreakpoints
	^breakpointListPresenter model asBag
		select: [:object | object isMethodService and: [object breakPoints isEmpty]]!

onCloseRequested: valueHolder
	valueHolder value: (methodSourcePresenter documentPresenter view isModified
				ifTrue: [methodSourcePresenter isOkayToChange]
				ifFalse: [true])!

onViewClosed
	super onViewClosed.
	BrowserUpdate current removeEventsTriggeredFor: breakpointListPresenter.
	BrowserUpdate current removeEventsTriggeredFor: methodSourcePresenter documentPresenter!

onViewOpened
	| answeringService breakPointsEnabled |
	super onViewOpened.
	self updateCaption: 'Breakpoint Browser'.
	self initializeMethods.
	methodSourcePresenter gciSession: gciSession.
	self registerPresentersForUpdates.
	answeringService := RowanAnsweringService new. 
	areBreakpointsEnabled
		value: (breakPointsEnabled := answeringService breakPointsAreEnabled: self gciSession).
	BrowserUpdate current breakpointsEnabled: breakPointsEnabled.
!

postEditSaveMethod
	!

queryCommand: aCommandQuery
	(#(#browseClassOrMethod #clearBreakpoints #disableBreakpoints #enableBreakpoints)
		includes: aCommandQuery command)
			ifTrue: 
				[aCommandQuery isEnabled: breakpointListPresenter selections notEmpty.
				^true].
	aCommandQuery command = #flipBreakpointsEnabled
		ifTrue: 
			[aCommandQuery isEnabled: true.
			aCommandQuery isChecked: areBreakpointsEnabled value.
			^true].
	^super queryCommand: aCommandQuery!

refresh
	self resetBreakpointList.
	self initializeMethods.
	self resetSourcePane!

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
			browser: self.
	BrowserUpdate current
		register: self selector: #breakpointSettingChanged:!

removeClass: classService
	| methodServices |
	methodServices := self methodServicesWithBreakpoints
				reject: [:methodService | methodService className = classService name].
	breakpointListPresenter model clear.
	self addMethodServicesToTree: methodServices!

removeMethodServicesWithoutBreakpoints
	| methodServicesWithBreakpoints selections updatedSelections |
	methodSourcePresenter documentPresenter view isModified ifTrue: [^self].
	selections := breakpointListPresenter selections.
	methodServicesWithBreakpoints := self methodServicesWithBreakpoints.
	breakpointListPresenter model clear.
	self addMethodServicesToTree: methodServicesWithBreakpoints.
	updatedSelections := breakpointListPresenter model asBag intersection: selections.
	breakpointListPresenter selections: updatedSelections!

resetBreakpointList
	breakpointListPresenter model: (TreeModel new
				searchPolicy: SearchPolicy equality;
				reset)!

resetSourcePane
	methodSourcePresenter value: String new.
	methodSourcePresenter documentPresenter view backcolor: JadeiteTextStyles default colorForNoEdits!

search
	^search
		ifNil: 
			[search := JadeiteSearch on: methodSourcePresenter documentPresenter view session: self gciSession]!

selectedClassServices
	^breakpointListPresenter selections select: [:object | object isMethodService not]!

selectedMethodServices
	^breakpointListPresenter selections select: [:object | object isMethodService]!

statusBarText: aString

	"do nothing for now" !

updateClass: classService
	| methodServices |
	methodServices := self methodServicesWithBreakpoints
				reject: [:methodService | methodService className = classService name and: [methodService meta = classService meta]].
	methodServices
		addAll: (classService methods select: [:methodService | methodService breakPoints notEmpty]).
	breakpointListPresenter model clear.
	self addMethodServicesToTree: methodServices.
	breakpointListPresenter view invalidate!

updateMethodList: methodService
	| methodServices |
	methodServices := Array with: methodService.
	self updateMethodServicesFrom: methodServices. 
	self addMethodServicesToTree: methodServices.
	self removeMethodServicesWithoutBreakpoints!

updateMethodServicesFrom: methodServices
	breakpointListPresenter model asBag do: 
			[:object |
			object isMethodService
				ifTrue: 
					[methodServices
						do: [:methodService | object replicateFrom: methodService	"replicateFrom: will take care of equality test"]]]!

updateSelection: selection
	selection command: #update.
	BrowserUpdate current issueCommands: (Array with: selection) session: self gciSession! !
!JadeiteBreakpointBrowser categoriesFor: #aboutToChange:!event handlers!public! !
!JadeiteBreakpointBrowser categoriesFor: #additionalAccelerators!constants!public! !
!JadeiteBreakpointBrowser categoriesFor: #addMethodServicesToTree:!event handlers support!initialization!private!updating support! !
!JadeiteBreakpointBrowser categoriesFor: #areBreakpointsEnabled!accessing!public! !
!JadeiteBreakpointBrowser categoriesFor: #basicBrowseMethod:!menu handlers support!private! !
!JadeiteBreakpointBrowser categoriesFor: #browseBreakpointMethods!menu handlers!public! !
!JadeiteBreakpointBrowser categoriesFor: #browseClass!menu handlers support!private! !
!JadeiteBreakpointBrowser categoriesFor: #browseClassOrMethod!menu handlers!public! !
!JadeiteBreakpointBrowser categoriesFor: #browseMethod!menu handlers support!private! !
!JadeiteBreakpointBrowser categoriesFor: #clearAllBreakpoints!menu handlers!public! !
!JadeiteBreakpointBrowser categoriesFor: #clearBreakpoints!menu handlers!public! !
!JadeiteBreakpointBrowser categoriesFor: #createComponents!initialization!public! !
!JadeiteBreakpointBrowser categoriesFor: #createSchematicWiring!initialization!public! !
!JadeiteBreakpointBrowser categoriesFor: #disableAllBreakpoints!menu handlers!public! !
!JadeiteBreakpointBrowser categoriesFor: #disableBreakpoints!menu handlers!public! !
!JadeiteBreakpointBrowser categoriesFor: #editSaveMethod!menu handlers!public! !
!JadeiteBreakpointBrowser categoriesFor: #enableAllBreakpoints!menu handlers!public! !
!JadeiteBreakpointBrowser categoriesFor: #enableBreakpoints!menu handlers!public! !
!JadeiteBreakpointBrowser categoriesFor: #flipBreakpointsEnabled!menu handlers!public! !
!JadeiteBreakpointBrowser categoriesFor: #initialize!initialization!public! !
!JadeiteBreakpointBrowser categoriesFor: #initializeMethods!event handlers support!initialization!private! !
!JadeiteBreakpointBrowser categoriesFor: #methodListSelection!public!selection! !
!JadeiteBreakpointBrowser categoriesFor: #methodSelected!event handlers!public! !
!JadeiteBreakpointBrowser categoriesFor: #methodServicesWithBreakpoints!accessing!private! !
!JadeiteBreakpointBrowser categoriesFor: #methodServicesWithoutBreakpoints!accessing!private! !
!JadeiteBreakpointBrowser categoriesFor: #onCloseRequested:!event handlers!public! !
!JadeiteBreakpointBrowser categoriesFor: #onViewClosed!event handlers!public! !
!JadeiteBreakpointBrowser categoriesFor: #onViewOpened!event handlers!public! !
!JadeiteBreakpointBrowser categoriesFor: #postEditSaveMethod!menu handlers support!private! !
!JadeiteBreakpointBrowser categoriesFor: #queryCommand:!menu handlers support!private! !
!JadeiteBreakpointBrowser categoriesFor: #refresh!menu handlers!public! !
!JadeiteBreakpointBrowser categoriesFor: #registerPresentersForUpdates!public!register presenters! !
!JadeiteBreakpointBrowser categoriesFor: #removeClass:!public!updating support! !
!JadeiteBreakpointBrowser categoriesFor: #removeMethodServicesWithoutBreakpoints!public!updating support! !
!JadeiteBreakpointBrowser categoriesFor: #resetBreakpointList!initialization!private! !
!JadeiteBreakpointBrowser categoriesFor: #resetSourcePane!event handlers support!private! !
!JadeiteBreakpointBrowser categoriesFor: #search!accessing!public! !
!JadeiteBreakpointBrowser categoriesFor: #selectedClassServices!private!selection! !
!JadeiteBreakpointBrowser categoriesFor: #selectedMethodServices!private!selection! !
!JadeiteBreakpointBrowser categoriesFor: #statusBarText:!accessing!public! !
!JadeiteBreakpointBrowser categoriesFor: #updateClass:!public!updating! !
!JadeiteBreakpointBrowser categoriesFor: #updateMethodList:!public!updating! !
!JadeiteBreakpointBrowser categoriesFor: #updateMethodServicesFrom:!public!updating support! !
!JadeiteBreakpointBrowser categoriesFor: #updateSelection:!event handlers!event handlers support!private! !

!JadeiteBreakpointBrowser class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1861 1371 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 592 nil nil nil 7 nil nil nil 592 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 2 410 ##(Smalltalk.ListTreeView) 34 44 nil 592 34 2 8 1149358153 1 720 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 265030 4 ##(Smalltalk.Menu) nil true 34 5 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #enableBreakpoints 8 'Enable Breakpoints' 1 1 nil nil nil 930 1 962 #disableBreakpoints 8 'Disable breakpoints' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 930 1 962 #clearBreakpoints 8 'Clear Breakpoints' 1 1 nil nil nil 930 1 962 #browseClassOrMethod 8 'Browse' 1025 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 720 nil 8 1660151920 nil nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 1 920646 5 ##(Smalltalk.ListViewColumn) 8 'Column 1' 899 #left 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 4 1 1328 8 'doIt' 8 '[:object | object isMethodService ifTrue:[object breakpointDisplayString ] ifFalse: [object]]' 8 #[32 105 226 0 120 226 1 106 17 106] #isMethodService #breakpointDisplayString #ifTrue:ifFalse: 1344 7 257 nil 459270 ##(Smalltalk.Message) #<= 8 #() nil nil 720 nil 3 nil nil #report 832 1 353 nil 34 4 nil nil 498 1 1 nil false 1050438 3 ##(Smalltalk.VirtualTreeModel) nil 864 138 144 832 1330 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 1520 #defaultGetChildrenBlock 304967395 8 #[30 105 226 0 106] #children 1568 7 257 nil 1330 0 nil 1586 2 3 1520 #defaultGetParentBlock 304973091 8 #[30 105 226 0 106] #parent 1632 7 257 nil 1330 0 nil 1586 2 3 1520 #defaultHasChildrenBlock 304978627 8 #[252 1 0 0 1 4 0 65 176 159 106 105] #childrenOf: #notEmpty 17 257 1536 1330 0 nil 1586 1 83886083 1520 #defaultFilterBlock 304961123 8 #[29 105 17 157 106] 1728 7 257 nil nil 138 ##(Smalltalk.IdentitySet) 832 138 ##(Smalltalk.IdentitySet) 832 45 1 nil nil nil nil nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 1 1 498 911 1199 720 1874 #contextMenu: 34 1 896 720 1874 #text: 34 1 8 'Column 1' 720 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 199 1 0 0 87 2 0 0] 8 #() 498 193 193 nil 2021 3 false 170 192 34 4 720 8 'breakpointListPresenter' 410 ##(Smalltalk.ContainerView) 34 15 nil 592 34 2 8 1417674752 131073 2160 nil nil nil 7 nil nil nil 2160 530 170 176 34 4 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 2160 34 2 8 1445007428 1025 2272 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 480 nil 7 882 nil true 34 22 930 1 962 #undo 8 '&Undo' 9397 1 nil nil nil 930 1 962 #redo 8 'R&edo' 9395 1 nil nil nil 1058 4097 930 1 962 #editCut 8 'Cu&t' 9393 1 nil nil nil 930 1 962 #editCopy 8 '&Copy' 9351 1 nil nil nil 930 1 962 #editPaste 8 '&Paste' 9389 1 nil nil nil 930 1 962 #editDelete 8 'De&lete' 1629 1 nil nil nil 930 1 962 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 1058 4097 930 1 962 #editFind 8 '&Find...' 9357 1 nil nil nil 930 1 962 #editFindNext 8 'Find &Next' 9359 1 nil nil nil 930 1 962 #editReplace 8 '&Replace...' 9361 1 nil nil nil 1058 4097 930 1 962 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 930 1 962 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 930 1 962 #jadeExecute 8 'Execute' 9355 1 nil nil nil 930 1 962 #jadeDebug 8 'De&bug' 9349 1 nil nil nil 1058 4097 930 1 962 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 930 1 962 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 1058 4097 930 1 962 #fileIn 8 'File In' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 498 193 193 nil 2272 nil 8 1631769023 852486 ##(Smalltalk.NullConverter) nil nil 13 nil 170 192 34 4 #normal 1182790 1 ##(Smalltalk.ScintillaTextStyle) 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 3522 77 466 #gray 466 #white 1 nil nil nil nil #callTip nil nil nil 34 256 3536 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3552 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 832 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 2272 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 832 nil 170 176 832 9215 nil nil nil nil 466 #silver nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 4 #normal 3536 #callTip 3552 nil nil nil nil 1 nil 170 192 832 nil nil 170 192 34 6 #Warning 3522 1027 196934 1 ##(Smalltalk.RGB) 60239 4002 31326207 1 nil nil nil nil #Warning nil nil nil #Error 3522 1031 4002 335 4002 31317503 1 nil nil nil nil #Error nil nil nil #Notification 3522 1029 nil 4002 31185883 1 nil nil nil nil #Notification nil nil nil nil 1810 138 144 34 11 1874 #createAt:extent: 34 2 498 1 51 498 907 1145 2272 1874 #contextMenu: 34 1 2400 2272 1874 #textLimit: 8 #(1073741823) 2272 1874 #hoverTime: 8 #(200) 2272 1874 #caretPeriod: 8 #(530) 2272 1874 #wordWrap: 8 #(true) 2272 1874 #margins: 34 1 34 3 985158 3 ##(Smalltalk.ScintillaMargin) 1 2272 61 3 nil nil nil nil 4450 3 2272 1 nil 3 67108863 nil nil 4450 5 2272 1 nil 3 -67108863 nil nil 2272 1874 #canHScroll: 8 #(false) 2272 1874 #tabWidth: 8 #(4) 2272 1874 #maxCompletionListHeight: 8 #(9) 2272 1874 #edgeColumn: 8 #(1) 2272 2034 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 197 1 0 0 85 2 0 0] 8 #() 2096 nil 29 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 4722 #fixedParentRight 1 4722 #fixedPreviousBottom 1 4722 #fixedParentBottom 1 410 ##(Smalltalk.Toolbar) 34 25 nil 2160 34 2 8 1140851500 131137 4800 nil 480 nil 519 nil 3346 nil true 3378 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 498 193 193 nil 4800 480 8 1660202272 170 192 832 170 192 34 24 48041 1246790 1 ##(Smalltalk.ToolbarSystemButton) 4800 1 962 #undo 8 'Undo' 1 1 nil 48041 1 7 48025 1246790 1 ##(Smalltalk.ToolbarBitmapButton) 4800 1 962 #jadeDisplay 8 'Display' 9353 1 nil 48025 395334 3 ##(Smalltalk.Bitmap) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'Tools.bmp' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil nil 7 498 1857 33 55 48035 4994 4800 1 962 #copySelection 8 'Copy' 1 1 nil 48035 1 3 48045 4994 4800 1 962 #editFind 8 'Find' 1 1 nil 48045 1 25 48029 5058 4800 1 962 #jadeInspect 8 'Inspect' 9379 1 nil 48029 5136 59 48039 4994 4800 1 962 #editDelete 8 'Delete' 1 1 nil 48039 1 11 48033 4994 4800 1 962 #editCut 8 'Cut' 1 1 nil 48033 1 1 48043 4994 4800 1 962 #redo 8 'Redo' 1 1 nil 48043 1 9 48027 5058 4800 1 962 #jadeExecute 8 'Execute' 9355 1 nil 48027 5136 57 48037 4994 4800 1 962 #editPaste 8 'Paste' 1 1 nil 48037 1 5 48047 4994 4800 1 962 #editReplace 8 'Replace' 1 1 nil 48047 1 27 48031 4994 4800 1 962 #editSaveMethod 8 'Save' 9383 1 nil 48031 1 17 34 15 5072 5552 5360 1049158 1 ##(Smalltalk.ToolbarSeparator) 4800 1 5696 5762 4800 1 5456 5264 5600 5408 5008 5504 5762 4800 1 5312 5648 nil nil 1 nil 498 33 33 498 45 45 nil nil 1810 138 144 34 2 1874 #createAt:extent: 34 2 498 1 1 498 907 51 4800 1874 #updateSizePosted 832 4800 2034 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 197 1 0 0 25 0 0 0] 8 #() 2096 nil 27 4690 4736 1 4752 1 4722 #fixedParentTop 1 4722 #fixedViewTop 51 170 192 34 2 2272 8 'document' nil 1810 138 144 34 1 1874 #createAt:extent: 34 2 498 911 1 498 911 1199 2160 2034 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 199 1 0 0 0 0 0 0 142 3 0 0 87 2 0 0] 34 2 4800 2272 2096 nil 27 8 'methodSourcePresenter' nil 1810 138 144 34 1 1874 #createAt:extent: 34 2 498 5 1 498 1821 1199 592 2034 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 2 0 0 0 0 0 0 0 144 3 0 0 87 2 0 0] 34 2 720 2160 2096 nil 27 4690 4736 5 4752 -3 6048 1 4784 -53 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 6480 nil nil nil 7 nil nil nil 6480 658 170 176 832 false 170 192 34 2 410 ##(Smalltalk.TextEdit) 34 16 nil 6480 34 2 8 1140850688 1 6608 nil 480 nil 7 nil 3346 nil true 3378 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 498 193 193 nil 6608 466 #black 8 1660100096 3458 nil nil 67 1810 138 144 34 2 1874 #createAt:extent: 34 2 498 1 1 498 1829 51 6608 1874 #setMarginWidths: 34 1 8 #(3 3) 6608 2034 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 146 3 0 0 25 0 0 0] 8 #() 2096 nil 27 8 'statusBarField' nil 1810 138 144 34 1 1874 #createAt:extent: 34 2 498 1 1203 498 1829 51 6480 2034 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 89 2 0 0 146 3 0 0 114 2 0 0] 34 1 6608 2096 nil 27 4690 4736 1 4752 1 4784 -49 4784 1 170 192 832 nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 2 882 nil true 34 2 930 1 962 #refresh nil 1 1 nil nil nil 930 1025 962 #flipBreakpointsEnabled 8 'Breakpoints enabled' 1025 1 nil nil nil 8 'Jadeite' nil 134217729 nil nil 34991 nil nil 882 nil true 34 11 930 1 962 #enableBreakpoints 8 'Enable Breakpoints' 1 1 nil nil nil 930 1 962 #enableAllBreakpoints 8 'Enable All Breakpoints' 1 1 nil nil nil 1058 4097 930 1 962 #disableBreakpoints 8 'Disable breakpoints' 1 1 nil nil nil 930 1 962 #disableAllBreakpoints 8 'Disable All Breakpoints' 1 1 nil nil nil 1058 4097 930 1 962 #clearBreakpoints 8 'Clear Breakpoints' 1 1 nil nil nil 930 1 962 #clearAllBreakpoints 8 'Clear All Breakpoints' 1 1 nil nil nil 1058 4097 930 1 962 #browseClassOrMethod 8 'Browse' 1025 1 nil nil nil 930 1 962 #browseBreakpointMethods nil 1 1 nil nil nil 8 'Breakpoints' nil 134217729 nil nil 35009 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1810 138 144 34 3 1874 #createAt:extent: 34 2 498 7679 21 498 1861 1371 416 1874 #text: 34 1 8 'Jadeite Breakpoint Browser' 416 1874 #updateMenuBar 832 416 2034 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 161 18 0 0 183 2 0 0] 34 2 592 6480 2096 nil 27 )! !
!JadeiteBreakpointBrowser class categoriesFor: #resource_Default_view!public!resources-views! !

