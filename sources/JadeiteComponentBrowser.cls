"Filed out from Dolphin Smalltalk 7"!

JadeShell subclass: #JadeiteComponentBrowser
	instanceVariableNames: 'componentTreePresenter componentPropertyPresenter'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteComponentBrowser guid: (GUID fromString: '{3afeeb63-aa19-42d9-ad83-b415a0fb8993}')!
JadeiteComponentBrowser comment: ''!
!JadeiteComponentBrowser categoriesForClass!Unclassified! !
!JadeiteComponentBrowser methodsFor!

createComponents
	componentTreePresenter := self add: JadeiteTreePresenter new name: 'componentTreePresenter'.
	componentPropertyPresenter := self add: ListPresenter new name: 'componentPropertyPresenter'!

initialize
	super initialize. 
	self resetComponentList
	!

onViewClosed
	super onViewClosed.
	BrowserUpdate current removeEventsTriggeredFor: componentTreePresenter.!

onViewOpened
	super onViewOpened.
	self registerPresentersForUpdates!

registerPresentersForUpdates
	BrowserUpdate current
		register: componentTreePresenter
		selector: #componentsUpdate:browser:
		browser: self!

resetComponentList
	componentTreePresenter model: (TreeModel new
				searchPolicy: SearchPolicy equality;
				reset)! !
!JadeiteComponentBrowser categoriesFor: #createComponents!initialization!public! !
!JadeiteComponentBrowser categoriesFor: #initialize!initialization!public! !
!JadeiteComponentBrowser categoriesFor: #onViewClosed!event handlers!public! !
!JadeiteComponentBrowser categoriesFor: #onViewOpened!event handlers!public! !
!JadeiteComponentBrowser categoriesFor: #registerPresentersForUpdates!public!register presenters! !
!JadeiteComponentBrowser categoriesFor: #resetComponentList!initialization!public! !

!JadeiteComponentBrowser class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default nil 37 nil nil nil 416 nil 170 192 8 #() nil nil nil nil nil 1 nil nil nil nil 1 nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 328198 ##(Smalltalk.Point) 7155 21 642 1221 961 416 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 249 13 0 0 10 0 0 0 91 16 0 0 234 1 0 0] 34 1 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 752 nil nil nil 7 nil nil nil 752 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.ListTreeView) 34 59 nil 752 34 2 8 1140920397 1025 880 590662 2 ##(Smalltalk.ListModel) 138 144 512 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 nil nil nil 880 nil 8 1740499056 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 2 920646 5 ##(Smalltalk.ListViewColumn) 8 'Properties' 293 #left ##(Smalltalk.BasicListAbstract) 459270 ##(Smalltalk.Message) #<= 8 #() nil nil 880 nil 3 nil nil 1106 8 '' 301 #left 1154 #displayString 8 #() 1154 #<= 1248 nil nil 880 nil 1 nil nil #report 8 #() nil 133217 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil true 1050438 3 ##(Smalltalk.VirtualTreeModel) nil 1008 138 144 512 787814 3 ##(Smalltalk.BlockClosure) 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 1296 #defaultGetChildrenBlock 42440101 8 #[30 105 226 0 106] #children 1360 7 257 nil 1346 0 nil 1378 2 3 1296 #defaultGetParentBlock 42415045 8 #[30 105 226 0 106] #parent 1424 7 257 nil 1346 0 nil 1378 2 3 1296 #defaultHasChildrenBlock 42500293 8 #[252 1 0 0 1 4 0 65 176 159 106 105] #childrenOf: #notEmpty 17 257 1312 1346 0 nil 1378 1 83886083 1296 #defaultFilterBlock 42430373 8 #[29 105 17 157 106] 1520 7 257 nil nil 138 ##(Smalltalk.PluggableSet) 512 138 ##(Smalltalk.IdentitySet) 512 37 1 nil nil nil nil nil nil nil 530 138 144 34 2 594 #createAt:extent: 34 2 642 601 1 642 601 879 880 594 #text: 34 1 8 'Properties' 880 690 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 44 1 0 0 0 0 0 0 88 2 0 0 183 1 0 0] 8 #() 642 193 193 nil 2029 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 601 1858 #fixedViewLeft 601 1858 #fixedParentTop 1 1858 #fixedParentBottom 1 410 ##(Smalltalk.ListTreeView) 34 59 nil 752 34 2 8 1140920397 1025 1936 946 138 144 512 nil 1008 480 nil 7 nil nil nil 1936 nil 8 1740499056 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 1056 nil nil nil nil nil nil 138 144 34 1 1106 8 'Component' 601 #left ##(Smalltalk.BasicListAbstract) 1154 #<= 8 #() nil nil 1936 nil 1 nil nil #report 8 #() nil 133217 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil true 1298 nil 1008 138 144 512 1346 0 nil 1378 2 3 1296 #defaultGetChildrenBlock 42440101 8 #[30 105 226 0 106] #children 2192 7 257 nil 1346 0 nil 1378 2 3 1296 #defaultGetParentBlock 42415045 8 #[30 105 226 0 106] #parent 2240 7 257 nil 1346 0 nil 1378 2 3 1296 #defaultHasChildrenBlock 42500293 8 #[252 1 0 0 1 4 0 65 176 159 106 105] #childrenOf: #notEmpty 17 257 2160 1346 0 nil 1378 1 83886083 1296 #defaultFilterBlock 42430373 8 #[29 105 17 157 106] 2336 7 257 nil nil 138 ##(Smalltalk.PluggableSet) 512 138 ##(Smalltalk.IdentitySet) 512 37 1 nil nil nil nil nil nil nil 530 138 144 34 2 594 #createAt:extent: 34 2 642 1 1 642 601 879 1936 594 #text: 34 1 8 'Component' 1936 690 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 44 1 0 0 183 1 0 0] 8 #() 1808 nil 2029 1826 1872 1 1872 601 1904 1 1920 1 170 192 34 4 880 8 'componentPropertyPresenter' 1936 8 'componentTreePresenter' nil 530 138 144 34 1 594 #createAt:extent: 34 2 642 5 1 642 1165 879 752 690 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 2 0 0 0 0 0 0 0 72 2 0 0 183 1 0 0] 34 2 1936 880 1808 nil 27 1808 nil 27 )! !
!JadeiteComponentBrowser class categoriesFor: #resource_Default_view!public!resources-views! !

