"Filed out from Dolphin Smalltalk 7"!

RowanService subclass: #RowanClassService
	instanceVariableNames: 'comment instVarNames classVarNames classInstVarNames superclassName subclassType poolDictionaryNames classType meta isExtension version versions template oop filters filterType methods packageName definedPackageName selectedPackageServices selectedMethods projectName hierarchyServices variables categories isTestCase expand visibleTests isNewClass updateAfterCommand isInSymbolList dictionaryName wasRemoved'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanClassService guid: (GUID fromString: '{ab96bbd9-d725-4add-b635-94cec9f12a19}')!
RowanClassService comment: ''!
!RowanClassService categoriesForClass!Kernel-Objects! !
!RowanClassService methodsFor!

= classService
	^classService isClassService ifTrue: [name asString = classService name asString] ifFalse: [^false]!

addHierarchyService: service to: treeModel withParent: parentService
	treeModel getNodeFor: service ifAbsent: [treeModel add: service asChildOf: parentService].
	(hierarchyServices at: service ifAbsent: [^self]) do: 
			[:classService |
			self
				addHierarchyService: classService
				to: treeModel
				withParent: service]!

basicPrepareForReplication
	"don't call anything potentially recursive here.
	method & package services don't iterate over subcollections"
	methods := Array new. 
	hierarchyServices := Array new.
	selectedMethods := Array new. 
	visibleTests := Array new. 
	methods ifNotNil: [methods do: [:methodService | methodService basicPrepareForReplication]].
	selectedMethods
		ifNotNil: [selectedMethods do: [:methodService | methodService basicPrepareForReplication]].
	selectedPackageServices do: [:packageService | packageService basicPrepareForReplication]!

behaviorIdentifier
	"for old school stuff"

	^(WriteStream on: String new)
		nextPutAll: name;
		tab;
		nextPutAll: oop printString;
		tab;
		nextPutAll: name printString;
		contents!

categories
	^categories!

classHierarchyUpdate: presenter browser: browser
	| treeModel subclasses parent |
	hierarchyServices ifNil: [^self].
	browser isClassListTabSelected ifTrue: [^self].
	browser classListPresenter selectionOrNil = self ifFalse:[^self]. 
	presenter selections notEmpty ifTrue: [(presenter selections includes: self) ifFalse: [^self]].
	treeModel := TreeModel new
				searchPolicy: SearchPolicy equality;
				reset.
	parent := nil.
	subclasses := hierarchyServices at: #nil ifAbsent: [].
	subclasses
		ifNil: 
			[| subs |
			parent := self.
			treeModel := presenter model.
			subs := hierarchyServices at: #expand.
			1 to: subs size
				do: 
					[:index |
					| classService node |
					classService := subs at: index.
					node := treeModel getNodeFor: classService ifAbsent: [].
					node
						ifNotNil: 
							[treeModel remove: classService ifAbsent: [].
							subs at: index put: node object]].
			subclasses := subs].
	subclasses do: 
			[:classService |
			self
				addHierarchyService: classService
				to: treeModel
				withParent: parent].
	presenter model asArray = treeModel asArray ifTrue: [^self].	"no need for update"
	treeModel asBag
		do: [:classService | classService selectedPackageServices: browser packageListPresenter selections browser: browser].
	presenter model: treeModel.
	presenter view updateMode: #lazy.	"faster for big tree building"
	presenter view disableRedraw.
	[presenter view expandAll] ensure: [presenter view enableRedraw].
	presenter selectionIfNone: [^presenter view ensureItemVisible: treeModel roots first].
	presenter view ensureSelectionVisible.
	presenter view updateMode: #dynamic!

classMethodsUpdate: presenter browser: browser
	browser selectedClass = self ifFalse: [^self].
	meta = browser isClassSideSelected ifFalse:[^self].
	presenter list isEmpty ifTrue: [self initializePresenterList: presenter].
	self displayMethodsOn: presenter browser: browser!

classOrHierarchyPresenter: browser
	^browser isClassListTabSelected
		ifTrue: [browser classListPresenter]
		ifFalse: [browser classHierarchyPresenter]!

comment
	^comment!

comment: anObject
	comment := anObject!

computeVisibleMethods: presenter browser: browser
	| visibleMethods |
	filters := browser selectedFilters.
	visibleMethods := filters isEmpty ifTrue: [methods] ifFalse: [self filterMethods: browser].
	visibleMethods
		do: [:svc | svc inSelectedPackage: (self selectedPackageServiceNames includes: svc packageName)].
	^visibleMethods!

definedPackageName
	^definedPackageName!

definedPackageName: anObject
	definedPackageName := anObject!

dictionaryName
	^dictionaryName!

displayMethodsOn: presenter browser: browser
	| visibleMethods |
	visibleMethods := self computeVisibleMethods: presenter browser: browser.
	self updateListIn: presenter from: visibleMethods!

displayString
	| displayString |
	displayString := self name.
	versions ~= 1
		ifTrue: 
			[displayString := displayString , ' (' , version printString , '/' , versions printString , ')'].
	isInSymbolList == false ifTrue: [displayString := displayString , ' {' , oop printString , '}'].
	^displayString!

displayStringFor: displayThing
	self shouldColorAsExtension ifTrue: [displayThing forecolor: Color darkMagenta].
	isInSymbolList ifFalse: [displayThing forecolor: Color darkRed].
	^self displayString!

excludedInstVars

	^super excludedInstVars, #( 'hierarchyServices' )
!

expand
	^expand!

expand: anObject
	expand := anObject!

filterMethods: browser
	| visibleMethods |
	browser isCategoryTabSelected
		ifTrue: [visibleMethods := methods select: [:methodService | filters includes: methodService category]]
		ifFalse: 
			[visibleMethods := methods
						select: [:methodService | (filters intersection: methodService accessedInstVars) notEmpty]].
	^visibleMethods!

filters
	^filters!

filters: anObject
	filters := anObject!

filterUpdate: presenter browser: browser
	browser selectedClass ifNil: [^self].
	browser selectedClass name asString = name asString ifFalse: [^self].
	presenter model isEmpty ifTrue: [presenter list: SortedCollection new].
	browser isCategoryTabSelected
		ifTrue: 
			[presenter list = categories ifTrue: [^self].
			self updateCategories: presenter browser: browser]
		ifFalse: 
			[presenter list = variables ifTrue: [^self].
			self updateVariables: presenter]!

hash
	^self name hash!

hierarchyClassServiceNames
	^self hierarchyClassServices collect: [:service | service name]!

hierarchyClassServices
	"flatten the unique format that hierarchyServices is returned
	into a collection of classes found in the service"

	| classes |
	classes := Set new.
	hierarchyServices keysAndValuesDo: 
			[:anchor :chain |
			classes add: anchor.
			chain do: [:service | classes add: service]].
	^classes reject:[:service | service == #nil]. !

initialize
	
	super initialize. 
	filters := Array new. 
	selectedPackageServices := Array new. "method list browser will not have packages to select"
	isTestCase := false. 
	isNewClass := false. 
	wasRemoved := false. !

instVarNames
	^instVarNames!

isClassService

	^true!

isDefined

	^isExtension not!

isExtension

	^isExtension!

isInSymbolList
	^isInSymbolList!

isNewClass
	^isNewClass!

isNewClass: anObject
	isNewClass := anObject!

isTestCase
	^isTestCase!

meta
	^meta!

meta: anObject
	meta := anObject!

methods
	^methods!

methods: anObject
	methods := anObject!

moveNodeToBeChildOf: superclassService in: classHierarchyPresenter
	| superclassNode myNode |
	superclassNode := classHierarchyPresenter model getNodeFor: superclassService.
	myNode := classHierarchyPresenter model getNodeFor: self.
	((classHierarchyPresenter model childrenOfNode: superclassNode) includes: myNode)
		ifFalse: 
			[classHierarchyPresenter model move: self asChildOf: superclassService].
	classHierarchyPresenter view expand: myNode!

oop
	^oop!

oop: anObject
	oop := anObject!

packageName
	^packageName!

packageName: anObject
	packageName := anObject!

prepareForReplication
	super prepareForReplication.
	self basicPrepareForReplication!

projectName
	^projectName!

releaseReferencedServices
	hierarchyServices := nil.
	methods := Array new!

remoteServiceName
	^'Rowan classServiceClass'!

removedClass: presenter
	| removal |
	updateType == #removedClass: ifFalse: [^self].
	removal := presenter model asBag detect: [:classService | classService name = name] ifNone: [].
	removal ifNotNil: [presenter model removeWithoutNotification: removal ifAbsent: []]!

replicateFrom: newService
	newService isClassService ifTrue: [^super replicateFrom: newService]!

saveMethod: source category: category session: session
	self
		command: #saveMethodSource:category:;
		commandArgs: (Array with: source with: category).
	BrowserUpdate current issueCommand: (Array with: self) session: session!

selectedMethods

	^selectedMethods
		!

selectedPackageNames
	^selectedPackageServices
		ifNil: [Array new]
		ifNotNil: [selectedPackageServices collect: [:packageService | packageService name]]!

selectedPackageServiceNames
	^selectedPackageServices collect: [:pkgService | pkgService name]!

selectedPackageServices
	^selectedPackageServices!

selectedPackageServices: anObject browser: browser
	"selected packages don't apply when dictionaries are showing"

	selectedPackageServices := browser isRowanProjectSelected ifTrue: [anObject] ifFalse: [Array new]!

shouldColorAsExtension
	^definedPackageName = self notRowanizedPackageName
		ifTrue: [false]
		ifFalse: 
			[selectedPackageServices isEmpty
				ifTrue: [false]
				ifFalse: 
					[((selectedPackageServices collect: [:service | service name]) includes: definedPackageName) not]]!

shouldReplicateInstVarAtIndex: index newService: newService
	(self class indexOfInstVar: 'meta') = index ifTrue: [^false].
	(self class indexOfInstVar: 'methods') = index ifTrue: [newService meta = meta ifFalse: [^false]].
	^true!

sunitMethodsUpdate: presenter browser: browser
	| selections oldClassService |
	browser classListPresenter selections isEmpty ifTrue: [^self].
	browser classListPresenter selections size > 1
		ifFalse: [browser classListPresenter selection name asString = name asString ifFalse: [^self]].
	presenter list isEmpty ifTrue: [self initializePresenterList: presenter].
	selections := browser classListPresenter selections asOrderedCollection.
	oldClassService := selections detect: [:classService | classService = self] ifNone: [^self].
	oldClassService replicateFrom: self. 
	browser updateMethodsFrom: selections!

template
	^template!

template: anObject
	template := anObject!

toolTip
	^'Defined package: ' , self definedPackageName!

updateAfterCommand: boolean

	updateAfterCommand := boolean!

updateCategories: presenter browser: browser
	"Update without losing selections. If no selections, 
	just update a copy then replace the original."

	| theModel |
	meta = browser isClassSideSelected ifFalse: [^self].
	theModel := presenter hasSelection ifTrue: [presenter model] ifFalse: [presenter model copy].
	presenter list copy
		do: [:category | (categories includes: category) ifFalse: [theModel remove: category]].
	categories do: [:category | (presenter list includes: category) ifFalse: [theModel add: category]].
	presenter hasSelection ifFalse: [presenter model: theModel]!

updatedClass: presenter browser: browser
	"only project browser should use this"

	| update |
	self selectedPackageServices: browser packageListPresenter selections browser: browser.
	update := presenter model asBag detect: [:classService | classService name = name] ifNone: [^self].
	update replicateFrom: self.
	presenter view invalidate!

updatedClassDefinition: classDefinitionPresenter browser: browser
	browser selectedClass = self
		ifTrue: 
			[classDefinitionPresenter view isModified
				ifFalse: 
					[classDefinitionPresenter value: template.
					browser displayNoMods: classDefinitionPresenter]]!

updatedClassInHierarchy: classHierarchyPresenter browser: projectBrowser
	"a newly added class should show up in the list but selection (say) of an existing class
	should in another browser that isn't in the displayed hierarchy but exists in the full 
	hierarchy should not"

	| classNode superclassService selectedPackageNames |
	classHierarchyPresenter view invalidate.
	classNode := classHierarchyPresenter model getNodeFor: self ifAbsent: [isNewClass ifFalse: [^self]].
	superclassService := classHierarchyPresenter model asBag
				detect: [:classService | classService name = superclassName]
				ifNone: [^self].
	(classNode notNil and: [classNode object isNewClass not])
		ifTrue: [^self moveNodeToBeChildOf: superclassService in: classHierarchyPresenter].
	projectBrowser packageListPresenter selections isEmpty ifTrue: [^self].
	selectedPackageNames := projectBrowser packageListPresenter selections
				collect: [:packageService | packageService name].
	(selectedPackageNames includes: packageName) ifFalse: [^self].
	classNode
		ifNil: [classHierarchyPresenter model add: self asChildOf: superclassService]
		ifNotNil: 
			[:node |
			node object replicateFrom: self.
			classHierarchyPresenter model move: node object asChildOf: superclassService]!

updateListIn: presenter from: visibleMethods
	| updated theModel |
	theModel := presenter hasSelection ifTrue: [presenter model] ifFalse: [presenter model copy].
	presenter list copy do: 
			[:old |
			updated := visibleMethods detect: [:new | new = old] ifNone: [].
			updated ifNil: [theModel remove: old] ifNotNil: [old replicateFrom: updated]].
	visibleMethods do: 
			[:new |
			updated := theModel detect: [:old | new = old] ifNone: [].
			updated ifNil: [theModel add: new]].
	(presenter parentPresenter class canUnderstand: #updateSUnitTab)
		ifTrue: [presenter parentPresenter updateSUnitTab].
	presenter hasSelection ifFalse: [presenter model: theModel]!

updateVariables: presenter
	variables ifNil: [^self].
	presenter list: variables. !

variables
	^variables!

version
	"Private - for testing"
	^version!

versions
	"Private - for testing"
	^versions!

visibleTests
	^visibleTests ifNil: [Array new]!

wasRemoved
	^wasRemoved == true!

wasRemoved: anObject
	wasRemoved := anObject! !
!RowanClassService categoriesFor: #=!comparing!public! !
!RowanClassService categoriesFor: #addHierarchyService:to:withParent:!private!updating! !
!RowanClassService categoriesFor: #basicPrepareForReplication!public!replication! !
!RowanClassService categoriesFor: #behaviorIdentifier!accessing!public! !
!RowanClassService categoriesFor: #categories!accessing!private! !
!RowanClassService categoriesFor: #classHierarchyUpdate:browser:!public!updating! !
!RowanClassService categoriesFor: #classMethodsUpdate:browser:!public!updating! !
!RowanClassService categoriesFor: #classOrHierarchyPresenter:!private!updating! !
!RowanClassService categoriesFor: #comment!accessing!public! !
!RowanClassService categoriesFor: #comment:!accessing!public! !
!RowanClassService categoriesFor: #computeVisibleMethods:browser:!private!updating! !
!RowanClassService categoriesFor: #definedPackageName!accessing!private! !
!RowanClassService categoriesFor: #definedPackageName:!accessing!private! !
!RowanClassService categoriesFor: #dictionaryName!accessing!private! !
!RowanClassService categoriesFor: #displayMethodsOn:browser:!public!updating! !
!RowanClassService categoriesFor: #displayString!displaying!public! !
!RowanClassService categoriesFor: #displayStringFor:!displaying!public! !
!RowanClassService categoriesFor: #excludedInstVars!public!ston! !
!RowanClassService categoriesFor: #expand!accessing!private! !
!RowanClassService categoriesFor: #expand:!accessing!private! !
!RowanClassService categoriesFor: #filterMethods:!private!updating! !
!RowanClassService categoriesFor: #filters!accessing!public! !
!RowanClassService categoriesFor: #filters:!accessing!public! !
!RowanClassService categoriesFor: #filterUpdate:browser:!public!updating! !
!RowanClassService categoriesFor: #hash!comparing!public! !
!RowanClassService categoriesFor: #hierarchyClassServiceNames!public! !
!RowanClassService categoriesFor: #hierarchyClassServices!public! !
!RowanClassService categoriesFor: #initialize!Init / Release!public! !
!RowanClassService categoriesFor: #instVarNames!accessing!public! !
!RowanClassService categoriesFor: #isClassService!public!testing! !
!RowanClassService categoriesFor: #isDefined!public!testing! !
!RowanClassService categoriesFor: #isExtension!public!testing! !
!RowanClassService categoriesFor: #isInSymbolList!accessing!private! !
!RowanClassService categoriesFor: #isNewClass!accessing!private! !
!RowanClassService categoriesFor: #isNewClass:!accessing!private! !
!RowanClassService categoriesFor: #isTestCase!public!testing! !
!RowanClassService categoriesFor: #meta!accessing!private! !
!RowanClassService categoriesFor: #meta:!accessing!private! !
!RowanClassService categoriesFor: #methods!accessing!private! !
!RowanClassService categoriesFor: #methods:!accessing!private! !
!RowanClassService categoriesFor: #moveNodeToBeChildOf:in:!private!updating! !
!RowanClassService categoriesFor: #oop!accessing!private! !
!RowanClassService categoriesFor: #oop:!accessing!private! !
!RowanClassService categoriesFor: #packageName!accessing!private! !
!RowanClassService categoriesFor: #packageName:!accessing!private! !
!RowanClassService categoriesFor: #prepareForReplication!public!replication! !
!RowanClassService categoriesFor: #projectName!accessing!private! !
!RowanClassService categoriesFor: #releaseReferencedServices!Init / Release!public! !
!RowanClassService categoriesFor: #remoteServiceName!must not strip!public! !
!RowanClassService categoriesFor: #removedClass:!public!updating! !
!RowanClassService categoriesFor: #replicateFrom:!public!replication! !
!RowanClassService categoriesFor: #saveMethod:category:session:!actions!public! !
!RowanClassService categoriesFor: #selectedMethods!accessing!private! !
!RowanClassService categoriesFor: #selectedPackageNames!private! !
!RowanClassService categoriesFor: #selectedPackageServiceNames!private!updating! !
!RowanClassService categoriesFor: #selectedPackageServices!accessing!private! !
!RowanClassService categoriesFor: #selectedPackageServices:browser:!accessing!private! !
!RowanClassService categoriesFor: #shouldColorAsExtension!public!testing! !
!RowanClassService categoriesFor: #shouldReplicateInstVarAtIndex:newService:!public!testing! !
!RowanClassService categoriesFor: #sunitMethodsUpdate:browser:!public!updating! !
!RowanClassService categoriesFor: #template!accessing!private! !
!RowanClassService categoriesFor: #template:!accessing!private! !
!RowanClassService categoriesFor: #toolTip!public! !
!RowanClassService categoriesFor: #updateAfterCommand:!accessing!public! !
!RowanClassService categoriesFor: #updateCategories:browser:!private!updating! !
!RowanClassService categoriesFor: #updatedClass:browser:!public!updating! !
!RowanClassService categoriesFor: #updatedClassDefinition:browser:!public!updating! !
!RowanClassService categoriesFor: #updatedClassInHierarchy:browser:!public!updating! !
!RowanClassService categoriesFor: #updateListIn:from:!private!updating! !
!RowanClassService categoriesFor: #updateVariables:!private!updating! !
!RowanClassService categoriesFor: #variables!accessing!private! !
!RowanClassService categoriesFor: #version!accessing!private! !
!RowanClassService categoriesFor: #versions!accessing!private! !
!RowanClassService categoriesFor: #visibleTests!accessing!private! !
!RowanClassService categoriesFor: #wasRemoved!accessing!private! !
!RowanClassService categoriesFor: #wasRemoved:!accessing!private! !

!RowanClassService class methodsFor!

defaultIconName
	"Answer a filename to use for an icon of this class."

	^File composeStem: 'Class' extension: 'ico'.!

icon
	"Answers an Icon that can be used to represent this class"

	^##(self) defaultIcon!

named: theName
	| inst |
	inst := self new name: theName.
	^inst! !
!RowanClassService class categoriesFor: #defaultIconName!private! !
!RowanClassService class categoriesFor: #icon!private! !
!RowanClassService class categoriesFor: #named:!instance creation!public! !

