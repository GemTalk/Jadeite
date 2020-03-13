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

disableTranscriptWrites
	(transcriptWritesWereEnabled := transcript isTranscriptInstalled)
		ifTrue: [transcript flipTranscript]	"turn off gemstone transcript writes for performance"!

isAbstract

	^self == JadeiteProjectBrowserAbstractTestCase!

issue170methodCreation
	| source |
	self methodSourcePresenter value: (source := 'another  ^5').
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self methodSourcePresenter value: (source := 'interesting  ^5').
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self methodSourcePresenter value: (source := 'test  ^5').
	self projectsPresenter editSaveMethod: self classListPresenter selection.
	self methodSourcePresenter value: (source := 'try  ^5').
	self projectsPresenter editSaveMethod: self classListPresenter selection!

openSecondBrowser
	secondBrowser := (self openWindow: [transcript openJadeiteProjectsBrowser]) topShell.
	secondBrowser caption: 'second browser'.
	secondPresenter := secondBrowser currentCard.
	secondPresenter selectClassListTab.
	^secondBrowser!

saveMethodWithUniqueString

	| source |
	source := 'gloop
	"I be unique"
	^self gloop'. 
	self methodSourcePresenter value: source. 
	self projectsPresenter editSaveMethod: self classListPresenter selection. 

	!

selectLowerTabsThenDo: aBlock
	#('sunit' 'classDefinition' 'classDocumentation' 'methodSource' 'comparisonTab') do: 
			[:tabName |
			| tab |
			tab := self projectsPresenter selectSourceTabNamed: tabName.
			aBlock value: tab]!

selectSUnitTab
	self projectsPresenter sunitPresenter ensureVisible!

setUp
	super setUp.
	self disableTranscriptWrites.	"turn off gemstone transcript writes for performance"
	self setupProjectBrowser!

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
!JadeiteProjectBrowserAbstractTestCase categoriesFor: #disableTranscriptWrites!private! !
!JadeiteProjectBrowserAbstractTestCase categoriesFor: #isAbstract!private!testing! !
!JadeiteProjectBrowserAbstractTestCase categoriesFor: #issue170methodCreation!issue test support!private! !
!JadeiteProjectBrowserAbstractTestCase categoriesFor: #openSecondBrowser!private! !
!JadeiteProjectBrowserAbstractTestCase categoriesFor: #saveMethodWithUniqueString!private! !
!JadeiteProjectBrowserAbstractTestCase categoriesFor: #selectLowerTabsThenDo:!private!support! !
!JadeiteProjectBrowserAbstractTestCase categoriesFor: #selectSUnitTab!private!selection! !
!JadeiteProjectBrowserAbstractTestCase categoriesFor: #setUp!private!setup teardown! !
!JadeiteProjectBrowserAbstractTestCase categoriesFor: #tearDown!private!setup teardown! !

