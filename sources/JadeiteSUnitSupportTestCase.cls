"Filed out from Dolphin Smalltalk 7"!

JadeiteAbstractTestCase subclass: #JadeiteSUnitSupportTestCase
	instanceVariableNames: 'sunitBrowser'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteSUnitSupportTestCase guid: (GUID fromString: '{afd06491-29d7-4988-bf71-09264248baaa}')!
JadeiteSUnitSupportTestCase comment: ''!
!JadeiteSUnitSupportTestCase categoriesForClass!Unclassified! !
!JadeiteSUnitSupportTestCase methodsFor!

methodListPresenter

	^self sunitPresenter methodListPresenter!

setUp
	super setUp. 
	sunitBrowser := self openWindow: [transcript jadeBrowseTests]!

sunitPresenter
	^sunitBrowser primaryPresenter!

tearDown
	sunitBrowser destroy!

test_browseMethods
	| browseMethodMenuItem browser selectors |
	self testsIssue: #issue207 withTitle: 'should be able to browe source for test from SUit browser'.
	self selectServiceNamed: 'Rowan-Services-Tests' in: self sunitPresenter packageListPresenter.
	self selectServiceNamed: 'JadeServerTest' in: self sunitPresenter classListPresenter.
	selectors := self sunitPresenter methodListPresenter list collect: [:service | service selector].
	self selectMethodsNamed: selectors.
	browseMethodMenuItem := self sunitPresenter methodListPresenter view contextMenu items
				detect: [:item | item isDivider not and: ['*Browse*Methods*' match: item description]]
				ifNone: [].
	browser := browseMethodMenuItem commandDescription performAgainst: self sunitPresenter.
	
	[self assert: (browser isKindOf: JadeiteMethodListBrowser).
	self assert: browser primaryPresenter methodListPresenter methodListPresenter list size
		equals: selectors size]
			ensure: [browser view close]!

test_browseSunitClass
	| browseClassMenuItem browser |
	self testsIssue: #issue207 withTitle: 'should be able to browe source for test from SUit browser'.
	self selectServiceNamed: 'Rowan-Services-Tests' in: self sunitPresenter packageListPresenter.
	self selectServiceNamed: 'JadeServerTest' in: self sunitPresenter classListPresenter.
	browseClassMenuItem := self sunitPresenter classListPresenter view contextMenu items
				detect: [:item | '*Browse*Class*' match: item description]
				ifNone: [].
	browser := browseClassMenuItem commandDescription performAgainst: self sunitPresenter.
	
	[self assert: (browser isKindOf: JadeiteProjectsSystemBrowser).
	self assert: browser currentCard classListPresenter selection name = 'JadeServerTest']
			ensure: [browser view close]!

test_multiSelectClasses
	| jadeServerTestCount  rowanClassServiceTestCount|
	self selectServiceNamed: 'Rowan-Services-Tests' in: self sunitPresenter packageListPresenter.
	self selectServiceNamed: 'JadeServerTest' in: self sunitPresenter classListPresenter.
	self assert: self sunitPresenter classListPresenter selections size equals: 1.
	jadeServerTestCount := self sunitPresenter methodListPresenter list size. 
		self selectServiceNamed: 'RowanClassServiceTest' in: self sunitPresenter classListPresenter.
	self assert: self sunitPresenter classListPresenter selections size equals: 1.
	rowanClassServiceTestCount := self sunitPresenter methodListPresenter list size. 
	self selectServicesNamed: #('JadeServerTest' 'RowanClassServiceTest')
		in: self sunitPresenter classListPresenter.
	self assert: self sunitPresenter classListPresenter selections size equals: 2. 
	self assert: self sunitPresenter methodListPresenter list size equals: jadeServerTestCount + rowanClassServiceTestCount
	
!

test_openSunitBrowser
	"browser opened in setup"

	self assert: (sunitBrowser isKindOf: JadeiteSUnitBrowser)!

test_refresh
	| source newMethod |
	self testsIssue: #issue279 withTitle: 'Sunit browser refresh, auto or manual'.
	projectsBrowser
		ifNil: [projectsBrowser := self openWindow: [transcript openJadeiteProjectsBrowser]].
	
	[self selectServiceNamed: 'RowanSample1-Tests' in: self sunitPresenter packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: self sunitPresenter classListPresenter.
	self assert: self sunitPresenter methodListPresenter list size equals: 4.
	newMethod := self sunitPresenter methodListPresenter list
				detect: [:methodService | methodService selector == #testMethod]
				ifNone: [].
	self assertIsNil: newMethod.
	self selectServiceNamed: 'RowanSample1' in: self projectListPresenter.
	self selectServiceNamed: 'RowanSample1-Tests' in: self packageListPresenter.
	self selectServiceNamed: 'RowanSample1Test' in: self classListPresenter.
	source := 'testMethod  
		self assert: true'.
	self projectsPresenter methodSourcePresenter value: source.
	self projectsPresenter editSaveMethod: self projectsPresenter classListPresenter selection.
	newMethod := self sunitPresenter methodListPresenter list
				detect: [:methodService | methodService selector == #testMethod]
				ifNone: [].
	self denyIsNil: newMethod.
	self assert: self sunitPresenter methodListPresenter list size equals: 5]
			ensure: [projectsBrowser destroy]!

test_sunitBrowserHasRowanPackages
	self assert: (self sunitPresenter isKindOf: JadeiteSUnitPresenter).	"a different presenter is used in the projects browser"
	self assert: self sunitPresenter packageListPresenter list size > 0.
	self denyIsNil: (self serviceNamed: 'Rowan-Tests' in: self sunitPresenter packageListPresenter).
	self
		denyIsNil: (self serviceNamed: 'Rowan-Services-Tests' in: self sunitPresenter packageListPresenter)!

test_sunitBrowserHasRowanTestClasses
	self assert: self sunitPresenter classListPresenter list size = 0.
	self selectServiceNamed: 'Rowan-Tests' in: self sunitPresenter packageListPresenter.
	self denyIsNil: (self serviceNamed: 'RwMoveTest' in: self sunitPresenter classListPresenter).
	self assert: self sunitPresenter classListPresenter list size > 0.
	self denyIsNil: (self serviceNamed: 'RwBrowserToolApiTest' in: self sunitPresenter classListPresenter).!

test_sunitBrowserHasRowanTestMethods
	self selectServiceNamed: 'Rowan-Tests' in: self sunitPresenter packageListPresenter.
	self assert: self sunitPresenter methodListPresenter list size = 0.
	self selectServiceNamed: 'RwMoveTest' in: self sunitPresenter classListPresenter.
	self assert: self sunitPresenter methodListPresenter list size > 0.! !
!JadeiteSUnitSupportTestCase categoriesFor: #methodListPresenter!public!support! !
!JadeiteSUnitSupportTestCase categoriesFor: #setUp!public!support! !
!JadeiteSUnitSupportTestCase categoriesFor: #sunitPresenter!public!support! !
!JadeiteSUnitSupportTestCase categoriesFor: #tearDown!public!support! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_browseMethods!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_browseSunitClass!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_multiSelectClasses!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_openSunitBrowser!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_refresh!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_sunitBrowserHasRowanPackages!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_sunitBrowserHasRowanTestClasses!public!tests! !
!JadeiteSUnitSupportTestCase categoriesFor: #test_sunitBrowserHasRowanTestMethods!public!tests! !

