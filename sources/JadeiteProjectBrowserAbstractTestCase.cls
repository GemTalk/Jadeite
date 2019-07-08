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
!JadeiteProjectBrowserAbstractTestCase categoriesFor: #closeExistingInspectors!private!support! !
!JadeiteProjectBrowserAbstractTestCase categoriesFor: #disableTranscriptWrites!private! !
!JadeiteProjectBrowserAbstractTestCase categoriesFor: #ensureOneTab!public!support! !
!JadeiteProjectBrowserAbstractTestCase categoriesFor: #isAbstract!public!testing! !
!JadeiteProjectBrowserAbstractTestCase categoriesFor: #openSecondBrowser!private! !
!JadeiteProjectBrowserAbstractTestCase categoriesFor: #selectClassListTab!private!selection! !
!JadeiteProjectBrowserAbstractTestCase categoriesFor: #setUp!private!setup teardown! !
!JadeiteProjectBrowserAbstractTestCase categoriesFor: #tearDown!private!setup teardown! !

