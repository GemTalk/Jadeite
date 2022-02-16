"Filed out from Dolphin Smallalk"!

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

confirmClassRemoval: classService
	| messageStream |
	messageStream := WriteStream on: String new.
	messageStream
		nextPutAll: 'Really delete class ';
		nextPutAll: classService name;
		nextPut: $?.
	classService packageName = RowanService notRowanizedPackageName
		ifTrue: 
			[messageStream
				cr;
				nextPutAll: 'Note that removal of unpackaged classes will not be tracked by Rowan'].
	^MessageBox confirm: messageStream contents!

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

selectIn: presenter
	| selection |
	presenter selectProjectNamed: self class notRowanizedPackageName.
	selection := presenter dictionaryPresenter list detect:[:dictionaryService | dictionaryService name = self name]. 
	presenter dictionaryPresenter selection: selection!

selectPackageOrDictionaryService: service in: presenter 
	presenter  selectProjectNamed: service projectName. 
	presenter dictionaryPresenter selection: service

	!

sortAspect

	^name! !
!RowanDictionaryService categoriesForMethods!
=!comparing!public! !
basicPrepareForReplication!public!replication! !
classes!accessing!public! !
classes:!accessing!public! !
classesUpdate:browser:!public!updating! !
classHierarchyUpdate:browser:!public!updating! !
confirmClassRemoval:!accessing!public! !
defaultTemplate!accessing!private! !
defaultTemplate:!accessing!private! !
displayName!displaying!public! !
displayString!displaying!public! !
displayStringFor:!displaying!public! !
doesUpdateApply:!private!testing! !
globals!accessing!public! !
globals:!accessing!public! !
hash!comparing!public! !
isDictionaryService!public!testing! !
name!accessing!public! !
name:!accessing!public! !
postUpdate!Init / Release!public! !
prepareForReplication!public!replication! !
removeDeletedClassesIn:browser:!private! !
selectIn:!public!selection! !
selectPackageOrDictionaryService:in:!public!selection! !
sortAspect!accessing!public! !
!

!RowanDictionaryService class methodsFor!

defaultIconName
	"Answer a filename to use for an icon of this class."

	^File composeStem: 'Dictionary' extension: 'ico'.!

icon
	"Answers an Icon that can be used to represent this class"

	^##(self) defaultIcon! !
!RowanDictionaryService class categoriesForMethods!
defaultIconName!private! !
icon!private! !
!

