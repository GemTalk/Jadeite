"Filed out from Dolphin Smallalk"!

JadePresenterA subclass: #JadeiteComponentPresenter
	instanceVariableNames: 'componentListPresenter packageListPresenter propertyPresenter'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteComponentPresenter guid: (GUID fromString: '{f837143a-a8e6-4980-aed2-4c0f6a719061}')!
JadeiteComponentPresenter comment: ''!
!JadeiteComponentPresenter categoriesForClass!Unclassified! !
!JadeiteComponentPresenter methodsFor!

componentListPresenter
	^componentListPresenter!

componentPropertiesDictionary
	| dictionary |
	dictionary := Dictionary new.
	#(#preloadDoitName #postloadDoitName #projectNames)
		do: [:instVarName | dictionary at: instVarName put: (model perform: instVarName)]!

createComponents
	componentListPresenter := self add: JadeiteTreePresenter new name: 'componentListPresenter'.
	packageListPresenter := self add: ListPresenter new name: 'packageListPresenter'.
	propertyPresenter := self add: Presenter new name: 'propertyPresenter'!

createSchematicWiring
	componentListPresenter
		when: #labelOf:editedTo:accept:
		send: #labelOfClass:editedTo:accept:
		to: self.
	componentListPresenter
		when: #labelOf:changedTo:
		send: #labelOf:changedTo:
		to: self.
	componentListPresenter
		when: #selectionChanged
		send: #displayPackages
		to: self.
	componentListPresenter
		when: #selectionChanged
		send: #displayComponentProperties
		to: self!

displayComponentProperties

	componentListPresenter selectionOrNil ifNil:[^self]. 
	componentListPresenter list:  self componentPropertiesDictionary

	
	!

displayComponents
	"The fake dictionary will be replaced by an argument to the method with the actual hierarchy from the server"

	| treeModel fakeHierarchy flattenedHierarchy |
	fakeHierarchy := Dictionary new.
	fakeHierarchy at: #nil put: #('common/Core').
	fakeHierarchy at: 'common/Core' put: #('SubComponent1' 'SubComponent2').
	flattenedHierarchy := fakeHierarchy.	"flattenedHierarchy will become the argument"
	treeModel := componentListPresenter model.
	flattenedHierarchy keysAndValuesDo: 
			[:parent :children |
			| parentDefinitionService |
			parentDefinitionService := treeModel asBag
						detect: [:definitionService | definitionService name = parent]
						ifNone: [nil].
			children do: 
					[:child |
					| componentDefinitionService |
					componentDefinitionService := RowanComponentDefinitionService new
								name: child;
								projectDefinitionService: model.
					treeModel add: componentDefinitionService asChildOf: parentDefinitionService]].
	componentListPresenter view expandAll!

displayPackages
	| packageNames |
	componentListPresenter selections isEmpty ifTrue: [^self].
	packageListPresenter clear.
	packageNames := SortedCollection new.
	componentListPresenter selections do: 
			[:componentDefinitionService |
			componentDefinitionService command: #packageNames.
			self issueCommand: componentDefinitionService.
			packageNames addAll: componentDefinitionService packageNames].
	packageListPresenter list: packageNames!

initialize
	super initialize. 
	self resetComponentList.
	!

isClassSelected
	"no classes in component browser" 
	^false!

labelOf: object changedTo: value
	componentListPresenter view update.
	self rowanFixMe	"write the change to the server"!

labelOfClass: componentService editedTo: value accept: accept
	value isEmpty
		ifFalse: 
			[componentService name: value.
			accept value: true]!

onViewClosed
	super onViewClosed.
	BrowserUpdate current removeEventsTriggeredFor: componentListPresenter.!

onViewOpened
	super onViewOpened.
	self displayComponents.!

projectListPresenter

	^nil!

renameComponent
	componentListPresenter view editSelectionLabel!

resetComponentList
	componentListPresenter model: (JadeiteTreeModel new
				searchPolicy: SearchPolicy equality;
				reset)! !
!JadeiteComponentPresenter categoriesForMethods!
componentListPresenter!accessing!public! !
componentPropertiesDictionary!accessing!public! !
createComponents!initialization!public! !
createSchematicWiring!initialization!public! !
displayComponentProperties!displaying!public! !
displayComponents!displaying!public! !
displayPackages!displaying!public! !
initialize!initialization!public! !
isClassSelected!public!testing! !
labelOf:changedTo:!event handlers!public! !
labelOfClass:editedTo:accept:!event handlers!public! !
onViewClosed!event handlers!public! !
onViewOpened!event handlers!public! !
projectListPresenter!accessing!public! !
renameComponent!menu handlers!public! !
resetComponentList!initialization!public! !
!

!JadeiteComponentPresenter class methodsFor!

resource_Component_Properties_View
	"Answer the literal data from which the 'Component Properties View' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Component_Properties_View)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil 327686 ##(Smalltalk.Color) #default nil 5 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 576 nil nil nil 5 nil nil nil 576 514 170 176 34 2 410 ##(Smalltalk.EditableListView) 34 55 nil 576 34 2 8 1140920397 1025 688 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 496 nil 5 nil nil nil 688 nil 8 1714874480 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil 328198 ##(Smalltalk.Point) 65 65 nil nil 138 144 34 2 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Property' 647 #left 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 106 8 'Dolphin List Presenter' 8 'BasicListAbstract' 8 'doIt' 8 '[:componentService | componentService key ]' 8 #[30 105 226 0 106] #key 1024 7 257 nil ##(Smalltalk.SortedCollection) nil nil 688 nil 3 nil nil true nil nil nil nil nil nil nil nil nil nil 962 8 'Value' 647 #left 1010 0 nil 1042 1 83886081 1008 8 'doIt' 8 '[:componentService | componentService value]' 8 #[29 105 17 142 106] 1200 7 257 nil 459270 ##(Smalltalk.Message) #<= 8 #() nil nil 688 nil 3 nil nil true nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 1344 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 496 nil 5 nil nil nil 1344 nil nil nil 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 898 1 1 898 1301 349 688 1522 #text: 34 1 8 'Property' 688 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 138 2 0 0 174 0 0 0] 8 #() 898 193 193 nil 33 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 1762 #fixedParentRight 1 1762 #fixedParentTop 1 1762 #fixedParentBottom 1 170 192 34 2 688 8 'propertyPresenter' nil 1458 138 144 34 1 1522 #createAt:extent: 34 2 898 1 1 898 1301 349 576 1650 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 138 2 0 0 174 0 0 0] 34 1 688 1712 nil 27 1730 1776 1 1792 1 1808 1 1762 #relativeParentHeight 327734 ##(Smalltalk.Float) 8 154 153 153 153 153 153 217 63 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 2112 nil nil nil 5 nil nil nil 2112 514 170 176 34 2 410 ##(Smalltalk.CardContainer) 34 16 nil 2112 34 2 8 1409286144 131073 2224 nil 496 nil 5 nil nil nil 2224 656710 1 ##(Smalltalk.CardLayout) 138 144 34 1 721414 ##(Smalltalk.Association) 8 'Comment' 410 ##(Smalltalk.TextEdit) 34 16 nil 2224 34 2 8 1140916352 1025 2400 nil 496 nil 5 nil nil nil 2400 nil 8 1714822656 852486 ##(Smalltalk.NullConverter) nil nil 1 1458 138 144 34 1 1522 #createAt:extent: 34 2 898 9 53 898 1285 463 2400 1650 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 134 2 0 0 1 1 0 0] 8 #() 1712 nil 27 2400 nil nil nil 170 192 34 2 2400 8 'commentText' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 2224 34 2 8 1140916736 1 2720 754 138 144 34 1 2384 nil 832 nil nil 1 nil nil nil 2720 nil 8 1715211760 1010 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 2848 7 257 nil 1010 0 nil 2866 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 2912 7 257 nil 880 nil nil nil nil nil #noIcons nil nil nil nil nil 1458 138 144 34 3 1522 #createAt:extent: 34 2 898 1 1 898 1301 523 2720 1522 #setSingleSelection: 8 #(1) 2720 1522 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 2720 1650 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 138 2 0 0 5 1 0 0] 8 #() 1712 nil 27 1458 138 144 34 2 1522 #createAt:extent: 34 2 898 1 1 898 1301 523 2224 1522 #text: 34 1 8 'commentTab' 2224 1650 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 138 2 0 0 5 1 0 0] 34 2 2400 2720 1712 nil 27 1730 1776 1 1792 1 1808 1 1824 1 170 192 800 nil 1458 138 144 34 1 1522 #createAt:extent: 34 2 898 1 349 898 1301 523 2112 1650 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 174 0 0 0 138 2 0 0 179 1 0 0] 34 1 2224 1712 nil 27 1730 1776 1 1792 1 2064 2082 8 154 153 153 153 153 153 217 63 1824 1 170 192 800 nil 1458 138 144 34 1 1522 #createAt:extent: 34 2 898 6837 21 898 1301 871 416 1650 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 90 13 0 0 10 0 0 0 228 15 0 0 189 1 0 0] 34 2 576 2112 1712 nil 27 )! !
!JadeiteComponentPresenter class categoriesForMethods!
resource_Component_Properties_View!public!resources-views! !
!

