"Filed out from Dolphin Smallalk"!

RowanClassesUpdate subclass: #RowanMethodsUpdate
	instanceVariableNames: 'methods methodFilters selectors selectedClass selectedSelectors inheritedClasses inheritedClass type'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanMethodsUpdate guid: (GUID fromString: '{253447c0-f306-48b9-87c4-7bfa4516f3b3}')!
RowanMethodsUpdate comment: ''!
!RowanMethodsUpdate categoriesForClass!Unclassified! !
!RowanMethodsUpdate methodsFor!

classesUpdate: presenter browser: anObject
	!

inheritedClass
	^inheritedClass!

inheritedClass: anObject
	inheritedClass := anObject!

inheritedClasses
	^inheritedClasses!

inheritedClasses: anObject
	inheritedClasses := anObject!

methodFilters
	^methodFilters!

methodFilters: anObject
	methodFilters := anObject!

methodFilterUpdate: presenter
	
	presenter list: methodFilters asArray reverse!

methods
	^methods!

methods: anObject
	methods := anObject!

methodsUpdate: presenter
	"The method list update knows which method is selected. 
	Mark the selected method update accordingling for later update"

	| methodList selectedMethodUpdates |
	selectedMethodUpdates := methods select: [:method | selectedSelectors includes: method selector].
	selectedMethodUpdates do: [:update | update selected: true].
	methodList := ListModel new.
	methods do: 
			[:update |
			| displayArray |
			displayArray := Array new: 5.
			displayArray
				at: 1 put: update selector asString;
				at: 2 put: update isOverride;
				at: 3 put: update isTestClass;
				at: 4 put: false;
				at: 5 put: update selector asString.	"unused"
			methodList add: displayArray].
	presenter list: methodList!

selectedClass
	^selectedClass!

selectedClass: anObject
	selectedClass := anObject!

selectedSelectors
	^selectedSelectors!

selectedSelectors: anObject
	selectedSelectors := anObject!

selectors
	^selectors!

selectors: anObject
	selectors := anObject!

type
	^type!

type: anObject
	type := anObject!

update: aPresenter

	aPresenter updateMethodFilterFrom: self. 
	aPresenter updateMethodsFrom: self. !

updateClassSelectionFor: presenter!

updateMethodFilterSelectionFor: presenter
	presenter selections: selectionNames.
!

updateMethodSelectionFor: presenter
	| selections |
	selections := presenter list select: [:item | selectedSelectors includes: item first asSymbol].
	presenter selections: selections! !
!RowanMethodsUpdate categoriesForMethods!
classesUpdate:browser:!public!updating! !
inheritedClass!accessing!public! !
inheritedClass:!accessing!public! !
inheritedClasses!accessing!public! !
inheritedClasses:!accessing!public! !
methodFilters!accessing!public! !
methodFilters:!accessing!public! !
methodFilterUpdate:!public!updating! !
methods!accessing!public! !
methods:!accessing!public! !
methodsUpdate:!public!updating! !
selectedClass!accessing!public! !
selectedClass:!accessing!public! !
selectedSelectors!accessing!public! !
selectedSelectors:!accessing!public! !
selectors!accessing!public! !
selectors:!accessing!public! !
type!accessing!private! !
type:!accessing!private! !
update:!public!updating! !
updateClassSelectionFor:!public!updating! !
updateMethodFilterSelectionFor:!public!updating! !
updateMethodSelectionFor:!public!updating! !
!

