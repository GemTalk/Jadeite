"Filed out from Dolphin Smalltalk 7"!

RowanService subclass: #RowanDictionaryService
	instanceVariableNames: 'classes hierarchyServices'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanDictionaryService guid: (GUID fromString: '{4b891434-003f-48d1-a7d3-b09dfd2d390f}')!
RowanDictionaryService comment: ''!
!RowanDictionaryService categoriesForClass!Kernel-Objects! !
!RowanDictionaryService methodsFor!

classes

	^classes!

classes: anArray
	classes := anArray!

classesUpdate: presenter browser: browser
	presenter list isEmpty ifTrue: [self initializePresenterList: presenter].
	browser packageListPresenter selections detect: [:packageService | packageService name = name]
		ifNone: [^self].
	self removeDeletedClassesIn: presenter browser: browser.
	self updateList: presenter whilePreservingSelections: classes.
	presenter list
		do: [:classService | classService selectedPackageServices: browser packageListPresenter selections browser: browser].
	presenter view invalidate.
	browser isClassSelected ifFalse: [self emptyFilterListsIn: browser]!

classHierarchyUpdate: presenter browser: browser
	self
		classHierarchyUpdate: presenter
		browser: browser
		hierarchyServices: hierarchyServices!

prepareForReplication
	super prepareForReplication.
	hierarchyServices := nil.!

removeDeletedClassesIn: presenter browser: browser
	| updatedClasses removedClasses |
	updatedClasses := classes select: [:classService | classService packageName = name]
				thenCollect: [:classService | classService name asString].
	removedClasses := presenter list
				select: [:classService | classService packageName = name and: [(updatedClasses includes: classService name) not]].
	removedClasses isEmpty ifTrue: [^self].
	presenter model
		setList: (ListModel withAll: (presenter list asArray copyWithoutAll: removedClasses))
		searchPolicy: SearchPolicy equality! !
!RowanDictionaryService categoriesFor: #classes!accessing!public! !
!RowanDictionaryService categoriesFor: #classes:!accessing!public! !
!RowanDictionaryService categoriesFor: #classesUpdate:browser:!public!updating! !
!RowanDictionaryService categoriesFor: #classHierarchyUpdate:browser:!public!updating! !
!RowanDictionaryService categoriesFor: #prepareForReplication!public!replication! !
!RowanDictionaryService categoriesFor: #removeDeletedClassesIn:browser:!private! !

