"Filed out from Dolphin Smalltalk 7"!

JadeiteAbstractTestCase subclass: #JadeiteProjectBrowserAbstractTestCase
	instanceVariableNames: 'secondBrowser methodListBrowser secondPresenter transcriptWritesWereEnabled'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteProjectBrowserAbstractTestCase guid: (GUID fromString: '{2b931b66-023f-4734-a4d1-b87646633136}')!
JadeiteProjectBrowserAbstractTestCase comment: ''!
!JadeiteProjectBrowserAbstractTestCase categoriesForClass!Unclassified! !
!JadeiteProjectBrowserAbstractTestCase methodsFor!

assertLinearAncestry: family in: presenter
	"given a collection of class names in order from root to leaf,
	test that each subsequent element of the collection is a child
	of the previous element"

	self assert: presenter model size equals: family size.
	1 to: family size - 1
		do: 
			[:index |
			| parentNode childNode parentName childName |
			parentName := family at: index.
			childName := family at: index + 1.
			parentNode := presenter model asBag detect: [:classService | classService name = parentName] ifNone: [].
			childNode := presenter model asBag detect: [:classService | classService name = childName] ifNone: [].
			self assert: (presenter model childrenOf: parentNode) size equals: 1. 
			self assert: (presenter model childrenOf: parentNode) first equals: childNode]!

closeExistingInspectors
	"not so elegant way of making sure the test gets the right inspector. Close others first"

	JadeNavigationInspector allInstances do: [:oldInspector | oldInspector view close].
	JadeInspector allInstances do: [:oldInspector | oldInspector view close]!

disableTranscriptWrites
	(transcriptWritesWereEnabled := transcript isTranscriptInstalled)
		ifTrue: [transcript flipTranscript]	"turn off gemstone transcript writes for performance"!

ensureOneTab
	projectsBrowser ifNil: [^self].
	[projectsBrowser cardsPresenter view cards size = 1] whileFalse: [projectsBrowser closeCard]!

isAbstract

	^self == JadeiteProjectBrowserAbstractTestCase!

openSecondBrowser
	secondBrowser := self openWindow: [transcript openJadeiteProjectsBrowser].
	secondBrowser caption: 'second browser'.
	secondPresenter := secondBrowser currentCard.
	secondPresenter selectClassListTab. 
	^secondBrowser!

selectClassListTab
	self projectsPresenter selectClassListTab.!

setUp
	super setUp.
	self disableTranscriptWrites.	"turn off gemstone transcript writes for performance"
	projectsBrowser := JadeiteTestResource current openProjectsBrowser.
	self ensureOneTab. 
	self selectClassListTab.
	self selectInstanceTab.
	self projectsPresenter selectCategoryTab.
	self projectListPresenter resetSelection. 
!

tearDown
	super tearDown.
	session isValidSession
		ifTrue: [transcriptWritesWereEnabled == true ifTrue: [transcript flipTranscript]].
	methodListBrowser
		ifNotNil: 
			[self destroy: methodListBrowser.
			methodListBrowser := nil].
	secondBrowser
		ifNotNil: 
			[self destroy: secondBrowser.
			secondBrowser := nil]! !
!JadeiteProjectBrowserAbstractTestCase categoriesFor: #assertLinearAncestry:in:!private! !
!JadeiteProjectBrowserAbstractTestCase categoriesFor: #closeExistingInspectors!private!support! !
!JadeiteProjectBrowserAbstractTestCase categoriesFor: #disableTranscriptWrites!private! !
!JadeiteProjectBrowserAbstractTestCase categoriesFor: #ensureOneTab!public!support! !
!JadeiteProjectBrowserAbstractTestCase categoriesFor: #isAbstract!public!testing! !
!JadeiteProjectBrowserAbstractTestCase categoriesFor: #openSecondBrowser!private! !
!JadeiteProjectBrowserAbstractTestCase categoriesFor: #selectClassListTab!private!selection! !
!JadeiteProjectBrowserAbstractTestCase categoriesFor: #setUp!private!setup teardown! !
!JadeiteProjectBrowserAbstractTestCase categoriesFor: #tearDown!private!setup teardown! !
