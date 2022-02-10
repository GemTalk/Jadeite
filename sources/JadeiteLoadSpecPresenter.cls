"Filed out from Dolphin Smallalk"!

JadePresenterA subclass: #JadeiteLoadSpecPresenter
	instanceVariableNames: 'loadSpecPresenter commentPresenter conditionalAttributesPresenter platformPropertiesPresenter'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteLoadSpecPresenter guid: (GUID fromString: '{df273fa5-ad4a-4601-8f47-d8c78f3f6de1}')!
JadeiteLoadSpecPresenter comment: ''!
!JadeiteLoadSpecPresenter categoriesForClass!Unclassified! !
!JadeiteLoadSpecPresenter methodsFor!

commentChanged!

conditionalAttributeItem: item updatedAtIndex: index!

createComponents
	super createComponents.
	loadSpecPresenter := self add: ListPresenter new name: 'loadSpecPresenter'.
	commentPresenter := self add: TextPresenter new name: 'commentPresenter'.
	conditionalAttributesPresenter := self add: ListPresenter new name: 'conditionalAttributesPresenter'.
	platformPropertiesPresenter := self add: ListPresenter new name: 'platformPropertiesPresenter'!

createSchematicWiring
	super createSchematicWiring.
	"loadSpecPresenter model
		when: #item:updatedAtIndex:
		send: #loadSpecItem:updatedAtIndex:
		to: self."
	loadSpecPresenter
		when: #selectionChanged
		send: #onLoadSpecPropertyChanged
		to: self.
	conditionalAttributesPresenter model
		when: #item:updatedAtIndex:
		send: #conditionalAttributeItem:updatedAtIndex:
		to: self.
	platformPropertiesPresenter model
		when: #item:updatedAtIndex:
		send: #platformPropertyItem:updatedAtIndex:
		to: self.
	commentPresenter
		when: #valueChanged
		send: #commentChanged
		to: self!

displayConditionalAttributes
	conditionalAttributesPresenter
		list: (model conditionalAttributes collect: [:attribute | model conditionalAttributes -> attribute])!

displayLoadSpecification
	| assocs |
	assocs := model objects collect: [:assoc | Array with: assoc key with: assoc value asString asValue].
	assocs := assocs asSortedCollection: [:x :y | x first < y first].
	loadSpecPresenter list: assocs asArray!

displayTabs
	| propertiesArray |
	commentPresenter value: model comment.
	self displayConditionalAttributes.
	propertiesArray := OrderedCollection new.
	model platformProperties keysAndValuesDo: [:key :value | propertiesArray add: key -> value].
	platformPropertiesPresenter list: propertiesArray!

exportLoadSpec
	model
		command: #exportLoadSpecification;
		commandArgs: Array new.
	self issueCommand: model!

loadSpecItem: item updatedAtIndex: index
	!

onLoadSpecPropertyChanged
	self popupEdit. !

platformPropertyItem: item updatedAtIndex: index!

popupEdit
	| aspectDialog |
	loadSpecPresenter selectionOrNil ifNil:[^self]. 
	aspectDialog := AspectEditorDialog createOn: nil asValue.
	aspectDialog recommendedRectangle: (View
				mapRectangle: (loadSpecPresenter view subItemRectRow: loadSpecPresenter view selectionByIndex column: 2)
				from: loadSpecPresenter
				to: View desktop).
	aspectDialog createAspectPresenters: (AspectAccessor subject: loadSpecPresenter selection
				aspect: (Aspect string: #last))
		for: loadSpecPresenter selection last.
	aspectDialog showModal! !
!JadeiteLoadSpecPresenter categoriesForMethods!
commentChanged!event handlers!public! !
conditionalAttributeItem:updatedAtIndex:!event handlers!public! !
createComponents!initialization!public! !
createSchematicWiring!initialization!public! !
displayConditionalAttributes!displaying!public! !
displayLoadSpecification!displaying!public! !
displayTabs!displaying!event handlers!public! !
exportLoadSpec!menu handlers!public! !
loadSpecItem:updatedAtIndex:!event handlers!public! !
onLoadSpecPropertyChanged!event handlers!public! !
platformPropertyItem:updatedAtIndex:!event handlers!public! !
popupEdit!private! !
!

