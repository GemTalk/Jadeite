"Filed out from Dolphin Smalltalk 7"!

RowanService subclass: #RowanPackageService
	instanceVariableNames: 'classes defaultTemplate projectName classCompilationFailures testClasses hierarchyServices selectedClass'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanPackageService guid: (GUID fromString: '{16c34093-697c-4a97-8953-e92983a2f084}')!
RowanPackageService comment: ''!
!RowanPackageService categoriesForClass!Kernel-Objects! !
!RowanPackageService methodsFor!

= packageService
	^packageService isPackageService ifTrue: [name = packageService name] ifFalse: [^false]!

addHierarchyService: service to: treeModel withParent: parentService
	treeModel getNodeFor: service ifAbsent: [treeModel add: service asChildOf: parentService].
	(hierarchyServices at: service ifAbsent: [^self]) do: 
			[:classService |
			self
				addHierarchyService: classService
				to: treeModel
				withParent: service]!

basicPrepareForReplication
	"don't iterate over sub colletions"
	classes := nil.
	testClasses := nil. 
	selectedClass := nil. !

classes

	^classes!

classes: anArray
	classes := anArray!

classesUpdate: presenter browser: browser
	"If the selected packages have the same class defined and extended, show the defined class"

	| condensedList selections selectedPackageServices |
	presenter list isEmpty ifTrue: [self initializePresenterList: presenter].
	(self doesUpdateApply: browser) ifFalse: [^self].
	self removeDeletedClassesIn: presenter browser: browser.
	condensedList := self condenseExtensions: presenter.
	presenter selectionOrNil
		ifNil: [presenter list: (ListModel withAll: condensedList asSet)]
		ifNotNil: [self updateList: presenter whilePreservingSelections: condensedList].
	"#selections is very expensive in Dolphin. Don't send it in a loop"
	selections := browser packageListPresenter selections.
	selectedPackageServices := browser isRowanProjectSelected ifTrue: [selections] ifFalse: [Array new].
	presenter list do: [:classService | classService selectedPackageServices: selectedPackageServices].
	presenter view invalidate.
	browser isClassSelected ifFalse: [self emptyFilterListsIn: browser]!

classHierarchyUpdate: presenter browser: browser
	browser isHierarchyTabSelected ifFalse: [^false].
	browser packageListPresenter selectionOrNil
		ifNil: [^self]
		ifNotNil: [:packageService | packageService name = name ifFalse: [^self]].
	self
		classHierarchyUpdate: presenter
		browser: browser
		hierarchyServices: hierarchyServices!

condenseExtensions: presenter
	| defined newList |
	newList := OrderedCollection new.
	newList
		addAll: presenter list;
		addAll: classes.
	defined := newList select: [:svc | svc isDefined] thenCollect: [:svc | svc name].
	newList := newList reject: [:svc | svc isExtension and: [defined includes: svc name]].
	newList := newList reject:[:svc | svc wasRenamed]. 
	^newList!

defaultTemplate
	^defaultTemplate!

defaultTemplate: anObject
	defaultTemplate := anObject!

displayStringFor: displayThing
	name ifNil: [^self].
	self isDirty == true
		ifTrue: 
			[displayThing font
				beItalic;
				beBold.
			displayThing forecolor: Color black]!

doesUpdateApply: browser
	| selections |
	selections := browser packageListPresenter selections.
	^browser isNoneProjectSelected ifTrue: [false] ifFalse: [selections includes: self]!

hash
	^self name hash!

hierarchyServices: collection

	hierarchyServices := collection!

isPackageService

	^true!

packageUpdate: presenter
	| packageInList |
	packageInList := presenter list detect: [:packageService | packageService name = name] ifNone: [].
	packageInList ifNotNil: [:packageService | packageService isDirty: isDirty].
	presenter view invalidate!

postUpdate
	classes ifNotNil: [classes do: [:service | service postUpdate]].
	classes := Array new!

prepareForReplication
	super prepareForReplication.
	self basicPrepareForReplication!

projectName
	^projectName!

projectName: anObject
	projectName := anObject!

remoteServiceName
	^'Rowan packageServiceClass'!

removeDeletedClassesIn: presenter browser: browser
	^super
		removeDeletedClassesIn: presenter
		browser: browser
		classes: classes!

replicateFrom: newService
	^(self isPackageService and: [newService isPackageService])
		ifTrue: [super replicateFrom: newService]!

selectedClass
	^selectedClass!

selectedClass: anObject
	selectedClass := anObject!

testClasses: presenter
	| additions |
	additions := OrderedCollection new.
	testClasses ifNil: [^self]. 
	testClasses do: 
			[:newClassService |
			| updatedClass |
			updatedClass := presenter model detect: [:classService | classService = newClassService]
						ifNone: 
							[additions add: newClassService.
							nil].
			updatedClass ifNotNil: [updatedClass replicateFrom: newClassService]].
	presenter model addAll: additions!

updateList: presenter whilePreservingSelections: updates
	| replicate bag |
	bag := presenter list asBag.
	bag do: 
			[:service |
			replicate := updates detect: [:update | update = service] ifNone: [nil].
			replicate notNil ifTrue: [service replicateFrom: replicate]].
	updates
		do: [:update | ((bag includes: update) and: [update wasRenamed not]) ifFalse: [presenter model add: update]]! !
!RowanPackageService categoriesFor: #=!comparing!public! !
!RowanPackageService categoriesFor: #addHierarchyService:to:withParent:!private!updating! !
!RowanPackageService categoriesFor: #basicPrepareForReplication!public!replication! !
!RowanPackageService categoriesFor: #classes!accessing!public! !
!RowanPackageService categoriesFor: #classes:!accessing!public! !
!RowanPackageService categoriesFor: #classesUpdate:browser:!public!updating! !
!RowanPackageService categoriesFor: #classHierarchyUpdate:browser:!public!updating! !
!RowanPackageService categoriesFor: #condenseExtensions:!private!updating! !
!RowanPackageService categoriesFor: #defaultTemplate!accessing!private! !
!RowanPackageService categoriesFor: #defaultTemplate:!accessing!private! !
!RowanPackageService categoriesFor: #displayStringFor:!displaying!public! !
!RowanPackageService categoriesFor: #doesUpdateApply:!private!testing! !
!RowanPackageService categoriesFor: #hash!comparing!public! !
!RowanPackageService categoriesFor: #hierarchyServices:!public!updating! !
!RowanPackageService categoriesFor: #isPackageService!public!testing! !
!RowanPackageService categoriesFor: #packageUpdate:!public!updating! !
!RowanPackageService categoriesFor: #postUpdate!Init / Release!public! !
!RowanPackageService categoriesFor: #prepareForReplication!public!replication! !
!RowanPackageService categoriesFor: #projectName!accessing!private! !
!RowanPackageService categoriesFor: #projectName:!accessing!private! !
!RowanPackageService categoriesFor: #remoteServiceName!must not strip!public! !
!RowanPackageService categoriesFor: #removeDeletedClassesIn:browser:!private!updating! !
!RowanPackageService categoriesFor: #replicateFrom:!public!replication! !
!RowanPackageService categoriesFor: #selectedClass!accessing!public! !
!RowanPackageService categoriesFor: #selectedClass:!accessing!public! !
!RowanPackageService categoriesFor: #testClasses:!public!updating! !
!RowanPackageService categoriesFor: #updateList:whilePreservingSelections:!private!updating! !

!RowanPackageService class methodsFor!

defaultIconName
	"Answer a filename to use for an icon of this class."

	^File composeStem: 'Package' extension: 'ico'.!

icon
	"Answers an Icon that can be used to represent this class"

	^##(self) defaultIcon! !
!RowanPackageService class categoriesFor: #defaultIconName!private! !
!RowanPackageService class categoriesFor: #icon!private! !

