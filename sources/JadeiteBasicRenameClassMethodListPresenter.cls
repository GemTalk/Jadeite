"Filed out from Dolphin Smalltalk 7"!

JadeiteBasicMethodListPresenter subclass: #JadeiteBasicRenameClassMethodListPresenter
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteBasicRenameClassMethodListPresenter guid: (GUID fromString: '{22ec86d0-eb03-4b36-b86a-b4b36d53b21c}')!
JadeiteBasicRenameClassMethodListPresenter comment: ''!
!JadeiteBasicRenameClassMethodListPresenter categoriesForClass!Unclassified! !
!JadeiteBasicRenameClassMethodListPresenter methodsFor!

next

	self parentPresenter nextSelection !

previous

	self parentPresenter previousSelection ! !
!JadeiteBasicRenameClassMethodListPresenter categoriesFor: #next!public! !
!JadeiteBasicRenameClassMethodListPresenter categoriesFor: #previous!public! !

!JadeiteBasicRenameClassMethodListPresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil nil 5 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 2 410 ##(Smalltalk.ListView) 34 30 nil 416 34 2 8 1140920649 1025 544 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 524550 ##(Smalltalk.ColorRef) 8 4278190080 nil 13 265030 4 ##(Smalltalk.Menu) nil true 34 18 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #removeFromList 8 'Remove from &List' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 802 1 834 #browseClass 8 'Browse Class' 1 1 nil nil nil 802 1 834 #browseImplementors 8 'Browse &Implementors' 1 1 nil nil nil 802 1 834 #browseImplementorsOf 8 'Browse Implementors of ...' 1 1 nil nil nil 802 1 834 #browseSenders 8 'Browse &Senders' 1 1 nil nil nil 802 1 834 #browseSendersOf 8 'Browse Senders of ...' 1 1 nil nil nil 802 1 834 #browseMethodsContaining 8 'Browse Methods Containing ...' 1 1 nil nil nil 882 4097 802 1 834 #browseHierarchyImplementors 8 'Browse Hierarchy Implementors' 1 1 nil nil nil 802 1 834 #browseHierarchySenders 8 'Browse Hierarchy Senders' 1 1 nil nil nil 882 4097 802 1 834 #removeMethods 8 'Remove Method(s) ...' 1 1 nil nil nil 882 4097 802 1 834 #runTests 8 'Run Tests' 9349 1 nil nil nil 882 4097 802 1 834 #next 8 'Next Change' 9365 1 nil nil nil 802 1 834 #previous 8 'Previous Change' 9367 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 544 nil 8 4294903845 459270 ##(Smalltalk.Message) #displayString 8 #() nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 5 920646 5 ##(Smalltalk.ListViewColumn) 8 'Project' 201 #left 1586 #displayString 8 #() 1586 #<= 1760 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:each | each projectName ]' 8 #[30 105 226 0 106] #projectName 1808 7 257 nil nil 544 nil 1 nil 1794 0 nil 1826 7 1 1792 8 'doIt' 8 '[:drawThing | drawThing item failedCompile ifTrue:[drawThing forecolor: Color red] ]' 8 #[35 105 226 0 159 122 17 47 161 180 106 60 106] #item #failedCompile 983558 ##(Smalltalk.VariableBinding) #Color ##(Smalltalk.Color) #red #forecolor: #ifTrue: 1904 7 257 nil 1698 8 'Package' 251 #left 1586 #displayString 8 #() 1586 #<= 2064 1794 0 nil 1826 2 1 1792 8 'doIt' 8 '[:each | each packageName ]' 8 #[30 105 226 0 106] #packageName 2096 7 257 nil nil 544 nil 1 nil nil 1698 8 'Class' 315 #left 1586 #displayString 8 #() 1586 #<= 2224 1794 0 nil 1826 2 1 1792 8 'doIt' 8 '[:each | each displayClassName ]' 8 #[30 105 226 0 106] #displayClassName 2256 7 257 nil nil 544 nil 3 nil nil 1698 8 'Category' 315 #left 1586 #displayString 8 #() 1586 #<= 2384 1794 0 nil 1826 2 1 1792 8 'doIt' 8 '[:each | each category]' 8 #[30 105 226 0 106] #category 2416 7 257 nil nil 544 nil 3 nil nil 1698 8 'Method' 315 #left 1586 #displayString 1616 ##(Smalltalk.SortedCollection) 1794 0 nil 1826 2 1 1792 8 'doIt' 8 '[:each | each selector]' 8 #[30 105 226 0 106] #selector 2544 7 257 nil nil 544 nil 3 nil nil #report 656 nil 131169 328198 ##(Smalltalk.Point) 129 129 34 4 nil nil 2626 1 1 nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 2626 1 1 2626 1401 401 544 2754 #contextMenu: 34 1 768 544 2754 #text: 34 1 8 'Project' 544 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 188 2 0 0 200 0 0 0] 8 #() 2626 193 193 nil 27 3 false 170 192 34 2 544 8 'methodList' nil 2690 138 144 34 1 2754 #createAt:extent: 34 2 2626 7679 21 2626 1401 401 416 2914 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 187 17 0 0 210 0 0 0] 34 1 544 2976 nil 27 )! !
!JadeiteBasicRenameClassMethodListPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

