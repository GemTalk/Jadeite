"Filed out from Dolphin Smalltalk 7"!

RowanService subclass: #RowanDictionaryService
	instanceVariableNames: 'classes hierarchyServices globals defaultTemplate name'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanDictionaryService guid: (GUID fromString: '{4b891434-003f-48d1-a7d3-b09dfd2d390f}')!
RowanDictionaryService comment: ''!
!RowanDictionaryService categoriesForClass!Kernel-Objects! !
!RowanDictionaryService methodsFor!

= dictionaryService
	^dictionaryService isDictionaryService ifTrue: [name = dictionaryService name] ifFalse: [^false]!

basicPrepareForReplication
	super basicPrepareForReplication.
	classes := nil. 
	hierarchyServices := nil.!

classes

	^classes!

classes: anArray
	classes := anArray!

classesUpdate: presenter browser: browser
	| updatedClasses |
	presenter list isEmpty ifTrue: [self initializePresenterList: presenter].
	(self doesUpdateApply: browser) ifFalse: [^self].
	self removeDeletedClassesIn: presenter browser: browser.
	presenter selectionOrNil
		ifNil: 
			[updatedClasses := classes asSet reject: [:classService | classService wasRenamed].
			updatedClasses addAll: presenter list.
			presenter list: (ListModel withAll: updatedClasses)]
		ifNotNil: 
			[self
				updateList: presenter
				whilePreservingSelections: classes
				browser: browser].
	presenter list
		do: [:classService | classService selectedPackageServices: browser packageListPresenter selections browser: browser].
	presenter view invalidate.
	browser isClassSelected ifFalse: [self emptyFilterListsIn: browser]!

classHierarchyUpdate: presenter browser: browser
	browser isHierarchyTabSelected ifFalse: [^false].
	browser dictionaryPresenter selectionOrNil
		ifNil: [^self]
		ifNotNil: [:dictionaryService | dictionaryService name = name ifFalse: [^self]].
	self
		classHierarchyUpdate: presenter
		browser: browser
		hierarchyServices: hierarchyServices!

defaultTemplate
	^defaultTemplate!

defaultTemplate: anObject
	defaultTemplate := anObject!

displayName
	"for logging. for now"

	^name!

displayString
	^self name!

displayStringFor: displayThing
	displayThing forecolor: Color black!

doesUpdateApply: browser
	^browser isNoneProjectSelected
		ifTrue: [browser dictionaryPresenter selections includes: self]
		ifFalse: [false]!

globals
	^globals!

globals: anObject
	globals := anObject!

hash
	^self name hash!

isDictionaryService

	^true!

name
	^name!

name: aString
	name := aString asString!

postUpdate
	super postUpdate.
	hierarchyServices
		ifNotNil: 
			[hierarchyServices keysAndValuesDo: 
					[:key :value |
					key isBehavior ifTrue: [key postUpdate].
					value do: [:service | service postUpdate]]].
	hierarchyServices := nil.
	classes ifNotNil: [classes do: [:service | service postUpdate]].
	classes := Array new!

prepareForReplication
	super prepareForReplication.
	classes := nil. 
	hierarchyServices := nil.!

removeDeletedClassesIn: presenter browser: browser
	^super
		removeDeletedClassesIn: presenter
		browser: browser
		classes: classes!

sortAspect

	^name! !
!RowanDictionaryService categoriesFor: #=!comparing!public! !
!RowanDictionaryService categoriesFor: #basicPrepareForReplication!public!replication! !
!RowanDictionaryService categoriesFor: #classes!accessing!public! !
!RowanDictionaryService categoriesFor: #classes:!accessing!public! !
!RowanDictionaryService categoriesFor: #classesUpdate:browser:!public!updating! !
!RowanDictionaryService categoriesFor: #classHierarchyUpdate:browser:!public!updating! !
!RowanDictionaryService categoriesFor: #defaultTemplate!accessing!private! !
!RowanDictionaryService categoriesFor: #defaultTemplate:!accessing!private! !
!RowanDictionaryService categoriesFor: #displayName!displaying!public! !
!RowanDictionaryService categoriesFor: #displayString!displaying!public! !
!RowanDictionaryService categoriesFor: #displayStringFor:!displaying!public! !
!RowanDictionaryService categoriesFor: #doesUpdateApply:!private!testing! !
!RowanDictionaryService categoriesFor: #globals!accessing!public! !
!RowanDictionaryService categoriesFor: #globals:!accessing!public! !
!RowanDictionaryService categoriesFor: #hash!comparing!public! !
!RowanDictionaryService categoriesFor: #isDictionaryService!public!testing! !
!RowanDictionaryService categoriesFor: #name!accessing!public! !
!RowanDictionaryService categoriesFor: #name:!accessing!public! !
!RowanDictionaryService categoriesFor: #postUpdate!Init / Release!public! !
!RowanDictionaryService categoriesFor: #prepareForReplication!public!replication! !
!RowanDictionaryService categoriesFor: #removeDeletedClassesIn:browser:!private! !
!RowanDictionaryService categoriesFor: #sortAspect!accessing!public! !

!RowanDictionaryService class methodsFor!

defaultIconName
	"Answer a filename to use for an icon of this class."

	^File composeStem: 'Dictionary' extension: 'ico'.!

icon
	"Answers an Icon that can be used to represent this class"

	^##(self) defaultIcon! !
!RowanDictionaryService class categoriesFor: #defaultIconName!private! !
!RowanDictionaryService class categoriesFor: #icon!private! !

