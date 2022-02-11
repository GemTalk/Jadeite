"Filed out from Dolphin Smallalk"!

JadePresenterA subclass: #JadeiteLoadSpecPresenter
	instanceVariableNames: 'loadSpecPresenter commentPresenter conditionalAttributesPresenter platformPropertiesPresenter shouldAskToClose'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteLoadSpecPresenter guid: (GUID fromString: '{df273fa5-ad4a-4601-8f47-d8c78f3f6de1}')!
JadeiteLoadSpecPresenter comment: ''!
!JadeiteLoadSpecPresenter categoriesForClass!Unclassified! !
!JadeiteLoadSpecPresenter methodsFor!

addConditionalAttribute
	| attribute |
	attribute := Prompter prompt: 'Please enter new conditional attribute ...'
				caption: 'Add Conditional Attribute'.
	model conditionalAttributes add: attribute.
	self displayConditionalAttributes.
	conditionalAttributesPresenter selectionByIndex: model conditionalAttributes size.
	self conditionalAttributeItem: attribute updatedAtIndex: model conditionalAttributes size!

commentChanged
	commentPresenter value = model comment ifTrue: [^self].
	model setComment: commentPresenter value.
	shouldAskToClose := true!

conditionalAttributeItem: item updatedAtIndex: index
	model conditionalAttributeItem: item updatedAtIndex: index.
	shouldAskToClose := true!

createComponents
	super createComponents.
	loadSpecPresenter := self add: ListPresenter new name: 'loadSpecPresenter'.
	commentPresenter := self add: TextPresenter new name: 'commentPresenter'.
	conditionalAttributesPresenter := self add: ListPresenter new name: 'conditionalAttributesPresenter'.
	platformPropertiesPresenter := self add: ListPresenter new name: 'platformPropertiesPresenter'!

createSchematicWiring
	super createSchematicWiring.
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
	model export.
	shouldAskToClose := false!

initialize
	super initialize.
	shouldAskToClose := false!

isOkayToClose
	^shouldAskToClose
		ifTrue: [MessageBox confirm: 'There are unwritten changes. Exit anyway?']
		ifFalse: [true]!

loadLoadSpec
	model load!

onCloseRequested: aCloseEvent
	aCloseEvent value: self isOkayToClose!

onLoadSpecPropertyChanged
	| selection |
	selection := loadSpecPresenter selectionOrNil ifNil: [^self].
	self popupEdit ifNotNil: [model setLoadSpecProperty: selection first to: selection last value].
	shouldAskToClose := true. !

platformPropertyItem: item updatedAtIndex: index
	model platformPropertyItem: item updatedAtIndex: index.
	shouldAskToClose := true!

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
	^aspectDialog showModal!

removeConditionalAttribute
	(MessageBox
		confirm: 'Really remove conditional attribute ''' , conditionalAttributesPresenter selection value
				, '''?')
			ifTrue: 
				[model conditionalAttributes removeAtIndex: conditionalAttributesPresenter selectionByIndex.
				self displayConditionalAttributes.
				self conditionalAttributeItem: nil updatedAtIndex: model conditionalAttributes size]! !
!JadeiteLoadSpecPresenter categoriesForMethods!
addConditionalAttribute!menu handlers!public! !
commentChanged!event handlers!public! !
conditionalAttributeItem:updatedAtIndex:!event handlers!public! !
createComponents!initialization!public! !
createSchematicWiring!initialization!public! !
displayConditionalAttributes!displaying!public! !
displayLoadSpecification!displaying!public! !
displayTabs!displaying!event handlers!public! !
exportLoadSpec!menu handlers!public! !
initialize!initialization!public! !
isOkayToClose!public!testing! !
loadLoadSpec!menu handlers!public! !
onCloseRequested:!event handlers!public! !
onLoadSpecPropertyChanged!event handlers!public! !
platformPropertyItem:updatedAtIndex:!event handlers!public! !
popupEdit!private! !
removeConditionalAttribute!menu handlers!public! !
!

