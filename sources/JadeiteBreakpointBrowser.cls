"Filed out from Dolphin Smallalk"!

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

addMethodServicesToTree: methodServices
	| sortedMethodServices |
	sortedMethodServices := methodServices asSortedCollection: 
					[:x :y |
					x className = y className ifTrue: [x selector < y selector] ifFalse: [x className < y className]].
	sortedMethodServices do: 
			[:methodService |
			methodService breakPoints isEmpty
				ifFalse: 
					[methodService className
						ifNotNil: 
							[breakpointListPresenter model getNodeFor: methodService className
								ifAbsent: [breakpointListPresenter model addRoot: methodService className].
							breakpointListPresenter model add: methodService asChildOf: methodService className.
							breakpointListPresenter view expand: methodService className]]]!

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

basicBrowseSelectedMethod: selectedMethodService
	| browser |
	BrowserUpdate current updateService: selectedMethodService session: gciSession.
	(browser := JadeiteMethodListBrowser showOnSession: gciSession) primaryPresenter
		methods: (Array with: selectedMethodService)
		selecting: nil.
	browser updateCaption: 'Selected Breakpoint Methods'.
	^browser!

breakpointListPresenter
	^breakpointListPresenter!

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

browseSelectedMethod
	| selectedMethodService |
	selectedMethodService := self selectedMethodServices first.
	^self basicBrowseSelectedMethod: selectedMethodService

!

clearAllBreakpoints
	^JadePresenter clearAllBreakpointsIn: self gciSession!

clearBreakpoints
	| methodServices |
	methodServices := self selectedMethodServices asOrderedCollection.
	methodServices addAll: (self methodServicesWithBreakpoints
				select: [:methodService | self selectedClassServices includes: methodService className]).
	^JadePresenter clearMethodBreakpoints: methodServices in: self gciSession!

contextObject
	^nil!

createComponents
	breakpointListPresenter := self add: JadeiteTreePresenter new name: 'breakpointListPresenter'.
	methodSourcePresenter := self add: JadeiteBreakpointBrowserSourcePresenter new
				name: 'methodSourcePresenter'!

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
	breakpointListPresenter selections isEmpty ifTrue:[^self]. 
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

ensureFirstBreakpointIsVisible
	| breakpointIndicator methodSourceView |
	methodSourceView := methodSourcePresenter documentPresenter view.
	breakpointIndicator := methodSourceView  indicators
				detect: [:indicator | indicator styleName == #breakPoint or: [indicator styleName == #disabledBreakPoint]].
	methodSourceView selectionRange: breakpointIndicator range.
	methodSourceView lineScrollBy: 1.  "make sure breakpoint doesn't fall off the bottom of the page" !

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

methodListPresenter
	"hook to make some method source presenter functions work.
	breakpointListPresenter responds to some list api's"

	^breakpointListPresenter!

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
			methodSourcePresenter methodValueChanged.
			self ensureFirstBreakpointIsVisible. 
			methodSourcePresenter documentPresenter view isReadOnly: false]
		ifFalse: [^self resetSourcePane]!

methodServicesWithBreakpoints
	^breakpointListPresenter model asBag
		select: [:object | object isMethodService and: [object breakPoints notEmpty]]!

methodServicesWithoutBreakpoints
	^breakpointListPresenter model asBag
		select: [:object | object isMethodService and: [object breakPoints isEmpty]]!

methodSourcePresenter

	^methodSourcePresenter!

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
	self resetSourcePane. 
	self updateCaption: 'Breakpoint Browser'.
	self initializeMethods.
	methodSourcePresenter gciSession: gciSession.
	self registerPresentersForUpdates.
	answeringService := RowanAnsweringService new.
	areBreakpointsEnabled
		value: (breakPointsEnabled := answeringService breakPointsAreEnabled: self gciSession).
	BrowserUpdate current breakpointsEnabled: breakPointsEnabled.
	self selectFirstMethodService. !

postEditSaveMethod
	!

queryCommand: aCommandQuery
	(#(#browseClassOrMethod #clearBreakpoints #disableBreakpoints #enableBreakpoints #editSaveMethod)
		includes: aCommandQuery command)
			ifTrue: 
				[aCommandQuery isEnabled: breakpointListPresenter selections notEmpty.
				^true].
	aCommandQuery command = #flipBreakpointsEnabled
		ifTrue: 
			[aCommandQuery isEnabled: true.
			aCommandQuery isChecked: areBreakpointsEnabled value.
			^true].
	aCommandQuery command = #browseSelectedMethod
		ifTrue: 
			[aCommandQuery isEnabled: breakpointListPresenter selection isMethodService.
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
	breakpointListPresenter model: (JadeiteTreeModel new
				searchPolicy: SearchPolicy equality;
				reset)!

resetSourcePane
	methodSourcePresenter methodService: nil. 
	methodSourcePresenter resetSourcePane!

search
	^search
		ifNil: 
			[search := JadeiteSearch on: methodSourcePresenter documentPresenter view session: self gciSession]!

selectedClassServices
	^breakpointListPresenter selections select: [:object | object isMethodService not]!

selectedMethodServices
	^breakpointListPresenter selections select: [:object | object isMethodService]!

selectFirstMethodService
	| methodServices |
	methodServices := breakpointListPresenter model asArray select: [:object | object isMethodService]. 
	methodServices isEmpty ifTrue:[^self]. 
	breakpointListPresenter selection: methodServices first. !

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
	breakpointListPresenter view invalidate.
	self selectedMethodServices isEmpty ifTrue: [self resetSourcePane]!

updateMethodList: methodService
	| methodServices |
	methodServices := Array with: methodService.
	self updateMethodServicesFrom: methodServices.
	self addMethodServicesToTree: methodServices.
	self removeMethodServicesWithoutBreakpoints.
	self selectedMethodServices isEmpty ifTrue: [self resetSourcePane]!

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
!JadeiteBreakpointBrowser categoriesForMethods!
aboutToChange:!event handlers!public! !
addMethodServicesToTree:!event handlers support!initialization!private!updating support! !
areBreakpointsEnabled!accessing!public! !
basicBrowseMethod:!menu handlers support!private! !
basicBrowseSelectedMethod:!menu handlers support!private! !
breakpointListPresenter!accessing!private! !
browseBreakpointMethods!menu handlers!public! !
browseClass!menu handlers support!private! !
browseClassOrMethod!menu handlers!public! !
browseMethod!menu handlers support!private! !
browseSelectedMethod!menu handlers support!private! !
clearAllBreakpoints!menu handlers!public! !
clearBreakpoints!menu handlers!public! !
contextObject!public! !
createComponents!initialization!public! !
createSchematicWiring!initialization!public! !
disableAllBreakpoints!menu handlers!public! !
disableBreakpoints!menu handlers!public! !
editSaveMethod!menu handlers!public! !
enableAllBreakpoints!menu handlers!public! !
enableBreakpoints!menu handlers!public! !
ensureFirstBreakpointIsVisible!event handlers support!public! !
flipBreakpointsEnabled!menu handlers!public! !
initialize!initialization!public! !
initializeMethods!event handlers support!initialization!private! !
methodListPresenter!accessing!public! !
methodListSelection!public!selection! !
methodSelected!event handlers!public! !
methodServicesWithBreakpoints!accessing!private! !
methodServicesWithoutBreakpoints!accessing!private! !
methodSourcePresenter!public! !
onCloseRequested:!event handlers!public! !
onViewClosed!event handlers!public! !
onViewOpened!event handlers!public! !
postEditSaveMethod!menu handlers support!private! !
queryCommand:!menu handlers support!private! !
refresh!menu handlers!public! !
registerPresentersForUpdates!public!register presenters! !
removeClass:!public!updating support! !
removeMethodServicesWithoutBreakpoints!public!updating support! !
resetBreakpointList!initialization!private! !
resetSourcePane!event handlers support!private! !
search!accessing!public! !
selectedClassServices!private!selection! !
selectedMethodServices!private!selection! !
selectFirstMethodService!public!selection! !
statusBarText:!accessing!public! !
updateClass:!public!updating! !
updateMethodList:!public!updating! !
updateMethodServicesFrom:!public!updating support! !
updateSelection:!event handlers!event handlers support!private! !
!

!JadeiteBreakpointBrowser class methodsFor!

defaultAdditionalAccelerators
	^super defaultAdditionalAccelerators
		, #(#(#reformatSource 'Ctrl+Shift+O') #(#jadeDebug 'Ctrl+B') #(#jadeInspect 'Ctrl+Q') #(#jadeDisplay 'Ctrl+D') #(#jadeExecute 'Ctrl+E'))!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1481 1081 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 592 nil nil nil 7 nil nil nil 592 1180166 ##(Smalltalk.ProportionalLayout) 170 176 8 #() false 170 192 34 2 410 ##(Smalltalk.TextEdit) 34 16 nil 592 34 2 8 1140850688 1 752 nil 480 nil 7 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 498 193 193 nil 752 466 #black 8 1591356848 852486 ##(Smalltalk.NullConverter) nil nil 67 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 1 1 498 1449 51 752 1042 #setMarginWidths: 34 1 8 #(3 3) 752 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 212 2 0 0 25 0 0 0] 8 #() 498 193 193 nil 27 8 'statusBarField' nil 978 138 144 34 1 1042 #createAt:extent: 34 2 498 1 907 498 1449 51 592 1170 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 197 1 0 0 212 2 0 0 222 1 0 0] 34 1 752 1232 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 1458 #fixedParentRight 1 1458 #fixedParentBottom -49 1504 1 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 1520 nil nil nil 7 nil nil nil 1520 658 170 176 34 2 410 ##(Smalltalk.ListTreeView) 34 59 nil 1520 34 2 8 1149358153 1 1632 590662 2 ##(Smalltalk.ListModel) 138 144 704 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 265030 4 ##(Smalltalk.Menu) nil true 34 6 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #enableBreakpoints 8 'Enable Breakpoints' 1 1 nil nil nil 1826 1 1858 #disableBreakpoints 8 'Disable breakpoints' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 1826 1 1858 #clearBreakpoints 8 'Clear Breakpoints' 1 1 nil nil nil 1826 1 1858 #browseClassOrMethod 8 'Browse' 1025 1 nil nil nil 1826 1 1858 #browseSelectedMethod nil 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 1632 nil 8 1591300320 nil nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 1 920646 5 ##(Smalltalk.ListViewColumn) 8 'Column 1' 717 #left 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 4 1 2256 8 'doIt' 8 '[:object | object isMethodService ifTrue:[object breakpointDisplayString ] ifFalse: [object]]' 8 #[32 105 226 0 120 226 1 106 17 106] #isMethodService #breakpointDisplayString #ifTrue:ifFalse: 2272 7 257 nil 459270 ##(Smalltalk.Message) #<= 8 #() nil nil 1632 nil 3 nil nil #report 8 #() 1 353 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil false 1050438 3 ##(Smalltalk.VirtualTreeModel) nil 1760 138 144 704 2258 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 2432 #defaultGetChildrenBlock 304967395 8 #[30 105 226 0 106] #children 2480 7 257 nil 2258 0 nil 2498 2 3 2432 #defaultGetParentBlock 304973091 8 #[30 105 226 0 106] #parent 2544 7 257 nil 2258 0 nil 2498 2 3 2432 #defaultHasChildrenBlock 304978627 8 #[252 1 0 0 1 4 0 65 176 159 106 105] #childrenOf: #notEmpty 17 257 2448 2258 0 nil 2498 1 83886083 2432 #defaultFilterBlock 304961123 8 #[29 105 17 157 106] 2640 7 257 nil nil 138 ##(Smalltalk.IdentitySet) 704 138 ##(Smalltalk.IdentitySet) 704 45 1 nil nil nil nil nil nil nil 978 138 144 34 3 1042 #createAt:extent: 34 2 498 1 1 498 721 903 1632 1042 #contextMenu: 34 1 1792 1632 1042 #text: 34 1 8 'Column 1' 1632 1170 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 104 1 0 0 195 1 0 0] 8 #() 1232 nil 2029 3 false 170 192 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 1520 34 2 8 1417674752 131073 2992 nil nil nil 7 nil nil nil 2992 530 170 176 34 4 410 ##(Smalltalk.Toolbar) 34 25 nil 2992 34 2 8 1140851500 131137 3104 nil 480 nil 519 nil 818 nil true 850 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 498 193 193 nil 3104 480 8 1591324032 170 192 704 170 192 34 24 48173 1246790 1 ##(Smalltalk.ToolbarSystemButton) 3104 1 1858 #editPaste 8 'Paste' 1 1 nil 48173 1 5 48183 3298 3104 1 1858 #editReplace 8 'Replace' 1 1 nil 48183 1 27 48167 3298 3104 1 1858 #editSaveMethod 8 'Save' 9383 1 nil 48167 1 17 48177 3298 3104 1 1858 #undo 8 'Undo' 1 1 nil 48177 1 7 48161 1246790 1 ##(Smalltalk.ToolbarBitmapButton) 3104 1 1858 #jadeDisplay 8 'Display' 9353 1 nil 48161 395334 3 ##(Smalltalk.Bitmap) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'Tools.bmp' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil nil 7 498 1857 33 55 48171 3298 3104 1 1858 #copySelection 8 'Copy' 1 1 nil 48171 1 3 48181 3298 3104 1 1858 #editFind 8 'Find' 1 1 nil 48181 1 25 48165 3506 3104 1 1858 #jadeInspect 8 'Inspect' 9379 1 nil 48165 3584 59 48175 3298 3104 1 1858 #editDelete 8 'Delete' 1 1 nil 48175 1 11 48169 3298 3104 1 1858 #editCut 8 'Cut' 1 1 nil 48169 1 1 48179 3298 3104 1 1858 #redo 8 'Redo' 1 1 nil 48179 1 9 48163 3506 3104 1 1858 #jadeExecute 8 'Execute' 9355 1 nil 48163 3584 57 34 15 3520 4000 3808 1049158 1 ##(Smalltalk.ToolbarSeparator) 3104 1 3408 4066 3104 1 3904 3712 3312 3856 3456 3952 4066 3104 1 3760 3360 nil nil 1 nil 498 33 33 498 45 45 nil nil 978 138 144 34 1 1042 #createAt:extent: 34 2 498 1 1 498 717 51 3104 1170 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 102 1 0 0 25 0 0 0] 8 #() 1232 nil 27 1426 1472 1 1488 1 1458 #fixedParentTop 1 1458 #fixedViewTop 51 410 ##(Smalltalk.JadeiteScintillaView) 34 65 nil 2992 34 2 8 1445007428 1025 4368 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 480 nil 7 1778 nil true 34 22 1826 1 1858 #undo 8 '&Undo' 9397 1 nil nil nil 1826 1 1858 #redo 8 'R&edo' 9395 1 nil nil nil 1954 4097 1826 1 1858 #editCut 8 'Cu&t' 9393 1 nil nil nil 1826 1 1858 #editCopy 8 '&Copy' 9351 1 nil nil nil 1826 1 1858 #editPaste 8 '&Paste' 9389 1 nil nil nil 1826 1 1858 #editDelete 8 'De&lete' 1629 1 nil nil nil 1826 1 1858 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 1954 4097 1826 1 1858 #editFind 8 '&Find...' 9357 1 nil nil nil 1826 1 1858 #editFindNext 8 'Find &Next' 9359 1 nil nil nil 1826 1 1858 #editReplace 8 '&Replace...' 9361 1 nil nil nil 1954 4097 1826 1 1858 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 1826 1 1858 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 1826 1 1858 #jadeExecute 8 'Execute' 9355 1 nil nil nil 1826 1 1858 #jadeDebug 8 'De&bug' 9349 1 nil nil nil 1954 4097 1826 1 1858 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 1826 1 1858 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 1954 4097 1826 1 1858 #fileIn 8 'File In' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil 818 nil true 524550 ##(Smalltalk.LOGFONTW) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 0 0 0 0 86 0 101 0 114 0 100 0 97 0 110 0 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 498 193 193 nil 4368 nil 8 1677082088 946 nil nil 13 1666214929 170 192 34 4 #callTip 1182790 1 ##(Smalltalk.ScintillaTextStyle) 77 466 #gray 466 #white 1 nil nil nil nil #callTip nil nil nil #normal 5586 1 nil nil 1 nil nil nil nil #normal nil nil nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 704 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 4368 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 704 nil 170 176 704 9215 nil nil nil nil 466 #silver nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #literalArray 8 '()' #specialCharacter 8 '()[]<>' 8 '' 3 170 192 34 2 #container 170 192 34 4 #callTip 5600 #normal 5648 nil nil nil nil 16 nil 170 192 704 nil nil 170 192 34 6 #Warning 5586 1027 196934 1 ##(Smalltalk.RGB) 60239 6050 31326207 1 nil nil nil nil #Warning nil nil nil #Error 5586 1031 6050 335 6050 31317503 1 nil nil nil nil #Error nil nil nil #Notification 5586 1029 nil 6050 31185883 1 nil nil nil nil #Notification nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 978 138 144 34 11 1042 #createAt:extent: 34 2 498 1 51 498 717 849 4368 1042 #contextMenu: 34 1 4496 4368 1042 #hoverTime: 8 #(200) 4368 1042 #caretPeriod: 8 #(530) 4368 1042 #wordWrap: 8 #(true) 4368 1042 #margins: 34 1 34 3 985158 3 ##(Smalltalk.ScintillaMargin) 1 4368 61 3 nil nil nil nil 6466 3 4368 1 nil 3 67108863 nil nil 6466 5 4368 1 nil 3 -67108863 nil nil 4368 1042 #canHScroll: 8 #(false) 4368 1042 #tabWidth: 8 #(4) 4368 1042 #targetRange: 34 1 525062 ##(Smalltalk.Interval) 1 -1 3 4368 1042 #maxCompletionListHeight: 8 #(9) 4368 1042 #edgeColumn: 8 #(1) 4368 1170 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 102 1 0 0 193 1 0 0] 8 #() 1232 nil 33 1426 1472 1 1488 1 1458 #fixedPreviousBottom 1 1504 1 170 192 34 2 4368 8 'document' nil 978 138 144 34 1 1042 #createAt:extent: 34 2 498 721 1 498 721 903 2992 1170 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 104 1 0 0 0 0 0 0 208 2 0 0 195 1 0 0] 34 2 3104 4368 1232 nil 27 8 'methodSourcePresenter' 1632 8 'breakpointListPresenter' nil 978 138 144 34 1 1042 #createAt:extent: 34 2 498 5 1 498 1441 903 1520 1170 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 2 0 0 0 0 0 0 0 210 2 0 0 195 1 0 0] 34 2 1632 2992 1232 nil 27 1426 1472 5 1488 -3 4336 1 1504 -53 170 192 704 nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 2 1778 nil true 34 2 1826 1 1858 #refresh nil 1 1 nil nil nil 1826 1025 1858 #flipBreakpointsEnabled 8 'Breakpoints enabled' 1025 1 nil nil nil 8 'Jadeite' nil 134217729 nil nil 48189 nil nil 1778 nil true 34 11 1826 1 1858 #enableBreakpoints 8 'Enable Breakpoints' 1 1 nil nil nil 1826 1 1858 #enableAllBreakpoints 8 'Enable All Breakpoints' 1 1 nil nil nil 1954 4097 1826 1 1858 #disableBreakpoints 8 'Disable breakpoints' 1 1 nil nil nil 1826 1 1858 #disableAllBreakpoints 8 'Disable All Breakpoints' 1 1 nil nil nil 1954 4097 1826 1 1858 #clearBreakpoints 8 'Clear Breakpoints' 1 1 nil nil nil 1826 1 1858 #clearAllBreakpoints 8 'Clear All Breakpoints' 1 1 nil nil nil 1954 4097 1826 1 1858 #browseClassOrMethod 8 'Browse' 1025 1 nil nil nil 1826 1 1858 #browseBreakpointMethods nil 1 1 nil nil nil 8 'Breakpoints' nil 134217729 nil nil 48207 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 978 138 144 34 2 1042 #createAt:extent: 34 2 498 5119 21 498 1481 1081 416 1042 #text: 34 1 8 'Jadeite Breakpoint Browser' 416 1170 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 9 0 0 10 0 0 0 227 12 0 0 38 2 0 0] 34 2 1520 592 1232 nil 27 )! !
!JadeiteBreakpointBrowser class categoriesForMethods!
defaultAdditionalAccelerators!public! !
resource_Default_view!public!resources-views! !
!

