"Filed out from Dolphin Smallalk"!

PackageMethodListPresenter subclass: #JadeiteBasicMethodListPresenter
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteBasicMethodListPresenter guid: (GUID fromString: '{a7382908-5775-44be-81de-c643c1215fb3}')!
JadeiteBasicMethodListPresenter comment: ''!
!JadeiteBasicMethodListPresenter categoriesForClass!Unclassified! !
!JadeiteBasicMethodListPresenter methodsFor!

basicRemoveMethods
	| services |
	services := methodListPresenter selections.
	services isEmpty ifTrue:[^self].
	self removeMethods: (Array with: services)!

browseClass
	| classService selector |
	classService := RowanClassService new name: methodListPresenter selection className.
	classService meta: methodListPresenter selection meta.
	BrowserUpdate current updateService: classService session: gciSession.
	selector := methodListPresenter selection selector.
	^Cursor wait showWhile: [self openProjectBrowserOn: classService selector: selector]!

browseClassReferences
	^JadePresenter browseClassReferences: self selectedClassName session: self gciSession!

browseHierarchyImplementors
	^self browseHierarchyImplementorsOf: methodListPresenter selection selector className: methodListPresenter selection className!

browseHierarchySenders
	^self browseHierarchySendersOf: methodListPresenter selection selector
		className: methodListPresenter selection className!

browseInExistingBrowser
	| classService selector shell |
	classService := RowanClassService new name: methodListPresenter selection className.
	classService meta: methodListPresenter selection meta.
	BrowserUpdate current updateService: classService session: gciSession.
	selector := methodListPresenter selection selector.
	shell := JadeiteBrowser allInstances detect: [:presenter | presenter isOpen] ifNone: [].
	shell := shell ifNil: [JadeiteBrowser showOnSession: gciSession] ifNotNil: [shell addSystemBrowser].
	shell view setFocus.
	shell currentCard updateAfterFindClass: classService.
	classService meta ifTrue: [shell currentCard selectClassTab].
	shell currentCard findMethod: selector.
	^self!

debugSelectedTests
	^(JadePresenter runMethodTests: methodListPresenter selections in: self gciSession)
		ifTrue: [MessageBox notify: 'Tests passed!!'] !

methodListPresenter

	^methodListPresenter!

methodSelectionChanged

	self trigger: #'methodSelectionChanged'.
	self updateServices: methodListPresenter selections. 
	self setStatusBarDefault
!

onViewClosed
	super onViewClosed.
	BrowserUpdate current removeEventsTriggeredFor: self. 
	BrowserUpdate current removeEventsTriggeredFor: methodListPresenter. !

onViewOpened
	super onViewOpened.
	self registerPresentersForUpdates!

queryCommand: query
	query command = #removeMethods
		ifTrue: 
			[query isEnabled: methodListPresenter selections notEmpty.
			^true].
	^super queryCommand: query!

registerPresentersForUpdates
	BrowserUpdate current
		register: methodListPresenter selector: #removed:;
		register: methodListPresenter
			selector: #methodUpdate:browser:
			browser: self!

removeFromList
	methodListPresenter list: (methodListPresenter list copyWithoutAll: methodListPresenter selections)!

removeMethods
	| result confirmationString |
	confirmationString := self removeSelectorsString: self methodListPresenter selections.
	result := MessageBox confirm: confirmationString caption: 'Remove the following method(s)?'.
	result ifFalse: [^self].
	self basicRemoveMethods!

removeMethods: services
	| browserService |
	browserService := RowanBrowserService new.
	browserService
		command: #removeMethods:;
		commandArgs: (Array with: methodListPresenter selections).
	self issueCommand: browserService
	!

selectedClassName
	^methodListPresenter selection className!

selection
	^methodListPresenter selection!

selections

	^methodListPresenter selections!

updateMethodSource

	self parentPresenter updateMethodSource! !
!JadeiteBasicMethodListPresenter categoriesForMethods!
basicRemoveMethods!private! !
browseClass!menu handlers!public! !
browseClassReferences!menu handlers!public! !
browseHierarchyImplementors!public! !
browseHierarchySenders!public! !
browseInExistingBrowser!menu handlers!public! !
debugSelectedTests!menu handlers!public! !
methodListPresenter!accessing!public! !
methodSelectionChanged!drag & drop!public! !
onViewClosed!event handlers!public! !
onViewOpened!event handlers!public! !
queryCommand:!menu handlers!public! !
registerPresentersForUpdates!public!register presenters! !
removeFromList!menu handlers!public! !
removeMethods!menu handlers!public! !
removeMethods:!menu handlers!private! !
selectedClassName!public!selection! !
selection!public! !
selections!public! !
updateMethodSource!public!updating! !
!

!JadeiteBasicMethodListPresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil nil 5 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 2 410 ##(Smalltalk.ListView) 34 45 nil 416 34 2 8 1140920649 1025 544 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 327686 ##(Smalltalk.Color) #default nil 13 265030 4 ##(Smalltalk.Menu) nil true 34 22 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #removeFromList 8 'Remove from &List' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 786 1 818 #browseClass 8 'Browse' 1 1 nil nil nil 786 1 818 #browseInExistingBrowser 8 'Browse In Existing Browser' 1 1 nil nil nil 786 1 818 #browseClassReferences 8 'Browse Class References' 1 1 nil nil nil 786 1 818 #browseImplementors 8 'Browse &Implementors' 1 1 nil nil nil 786 1 818 #browseImplementorsOf 8 'Browse Implementors of ...' 1 1 nil nil nil 786 1 818 #browseSenders 8 'Browse &Senders' 1 1 nil nil nil 786 1 818 #browseSendersOf 8 'Browse Senders of ...' 1 1 nil nil nil 866 4097 786 1 818 #browseHierarchyImplementors 8 'Browse Hierarchy Implementors' 1 1 nil nil nil 786 1 818 #browseHierarchySenders 8 'Browse Hierarchy Senders' 1 1 nil nil nil 866 4097 786 1 818 #clearMethodBreakpoints 8 'Clear Method Breakpoints' 1 1 nil nil nil 866 4097 786 1 818 #browseMethodsContaining 8 'Browse Methods Containing ...' 1 1 nil nil nil 786 1 818 #browseLiteralReferences 8 'Browse Literal References ...' 1 1 nil nil nil 786 1 818 #browseSelectedMethods 8 'Browse Selected Methods' 1 1 nil nil nil 786 1 818 #browseMethodHistory nil 1 1 nil nil nil 866 4097 786 1 818 #removeMethods 8 'Remove Method(s) ...' 1 1 nil nil nil 786 1 818 #debugSelectedTests 8 'Debug Selected Test(s)' 13445 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 544 nil 8 1607618784 459270 ##(Smalltalk.Message) #displayString 8 #() nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 5 920646 5 ##(Smalltalk.ListViewColumn) 8 'Project' 201 #left 1746 #displayString 8 #() 1746 #<= 1920 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each projectName ]' 8 #[30 105 226 0 106] #projectName 1968 7 257 nil nil 544 nil 1 nil 1954 0 nil 1986 7 1 1952 8 'doIt' 8 '[:drawThing | drawThing item failedCompile ifTrue:[drawThing forecolor: Color red] ]' 8 #[35 105 226 0 159 122 17 47 161 180 106 60 106] #item #failedCompile 983558 ##(Smalltalk.VariableBinding) #Color 704 #red #forecolor: #ifTrue: 2064 7 257 nil 1858 8 'Package' 251 #left 1746 #displayString 8 #() 1746 #<= 2224 1954 0 nil 1986 2 1 1952 8 'doIt' 8 '[:each | each packageName ]' 8 #[30 105 226 0 106] #packageName 2256 7 257 nil nil 544 nil 1 nil nil 1858 8 'Class' 315 #left 1746 #displayString 8 #() 1746 #<= 2384 1954 0 nil 1986 2 1 1952 8 'doIt' 8 '[:each | each displayClassName ]' 8 #[30 105 226 0 106] #displayClassName 2416 7 257 nil nil 544 nil 3 nil nil 1858 8 'Category' 315 #left 1746 #displayString 8 #() 1746 #<= 2544 1954 0 nil 1986 2 1 1952 8 'doIt' 8 '[:each | each category]' 8 #[30 105 226 0 106] #category 2576 7 257 nil nil 544 nil 3 nil nil 1858 8 'Method' 315 #left 1746 #displayString 1776 ##(Smalltalk.SortedCollection) 1954 0 nil 1986 2 1 1952 8 'doIt' 8 '[:each | each selector]' 8 #[30 105 226 0 106] #selector 2704 7 257 nil nil 544 nil 3 nil nil #report 8 #() nil 131169 328198 ##(Smalltalk.Point) 129 129 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 2802 1 1 2802 1401 401 544 2898 #contextMenu: 34 1 752 544 2898 #text: 34 1 8 'Project' 544 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 188 2 0 0 200 0 0 0] 8 #() 2802 193 193 nil 35 3 false 170 192 34 2 544 8 'methodList' nil 2834 138 144 34 1 2898 #createAt:extent: 34 2 2802 6911 21 2802 1401 401 416 3058 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 127 13 0 0 10 0 0 0 59 16 0 0 210 0 0 0] 34 1 544 3120 nil 27 )! !
!JadeiteBasicMethodListPresenter class categoriesForMethods!
resource_Default_view!public!resources-views! !
!

