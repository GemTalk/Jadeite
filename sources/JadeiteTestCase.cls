"Filed out from Dolphin Smalltalk 7"!

TestCase subclass: #JadeiteTestCase
	instanceVariableNames: 'session browser transcript'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteTestCase guid: (GUID fromString: '{1d6db475-c257-442b-9f91-d1574b03aee2}')!
JadeiteTestCase comment: 'General Jadeite tests. Assumes a logged in session and transcript present. '!
!JadeiteTestCase categoriesForClass!Unclassified! !
!JadeiteTestCase methodsFor!

openProjectsBrowser
	browser := self openWindow: [transcript openJadeiteProjectsBrowser]!

openWindow: aBlock
	"evaluate a block which is expected to return an object that responds to #view.
	Wait until the view affirms it is open before continuing"

	| presenter count |
	presenter := aBlock value.
	count := 0.
	[presenter view isOpen] whileFalse: 
			[(Delay forMilliseconds: 50) wait.
			count := count + 1.
			count > 10 ifTrue: [^presenter]].
	^presenter!

packageListPresenter
	^browser currentCard packageListPresenter!

projectList
	^self projectListPresenter list!

projectListPresenter
	^browser currentCard projectListPresenter!

rowanProjectNames
	"this may change"

	^#('Cypress' 'Rowan' 'STON' 'Tonel')!

selectElementsNamed: anArray in: presenter
	anArray do: 
			[:name |
			| service |
			service := presenter list detect: [:svc | svc name = name]
						ifNone: [self error: 'List element ' , name , ' not found'].
			presenter selections: (presenter selections asOrderedCollection
						add: service;
						yourself)]!

serviceNamed: name in: presenter
	| service |
	service := presenter list detect: [:service | service name = name] ifNone: [].
	self denyIsNil: service.
	^service!

setUp
	super setUp.
	session := JadeiteTestResource current session.
	transcript := JadeiteTestResource current transcript!

tearDown
	super tearDown.
	browser ifNotNil: [browser destroy]!

test_openProjectsBrowser
	self openProjectsBrowser.
	self assert: browser class equals: JadeiteProjectsSystemBrowser.
	self
		denyIsNil: (self projectList detect: [:projectService | projectService name = 'Rowan'] ifNone: [])!

test_selectMultiplePackages
	self openProjectsBrowser.
	self assert: self packageListPresenter list isEmpty.
	self selectElementsNamed: #('Rowan') in: self projectListPresenter.
	self deny: self packageListPresenter list isEmpty.
	self serviceNamed: 'Rowan-Services-Core' in: self packageListPresenter.
	self serviceNamed: 'Rowan-JadeServer' in: self packageListPresenter.
	self selectElementsNamed: #('Rowan-Services-Core' 'Rowan-JadeServer') in: self packageListPresenter!

test_selectMultipleProjects
	self openProjectsBrowser.
	self assert: self projectListPresenter selections isEmpty.
	self selectElementsNamed: self rowanProjectNames in: self projectListPresenter.
	self assert: self projectListPresenter selections size = 4! !
!JadeiteTestCase categoriesFor: #openProjectsBrowser!private!private project support! !
!JadeiteTestCase categoriesFor: #openWindow:!private! !
!JadeiteTestCase categoriesFor: #packageListPresenter!private!private presenters!private project support! !
!JadeiteTestCase categoriesFor: #projectList!private!private project support! !
!JadeiteTestCase categoriesFor: #projectListPresenter!private!private presenters!private project support! !
!JadeiteTestCase categoriesFor: #rowanProjectNames!private!private project support! !
!JadeiteTestCase categoriesFor: #selectElementsNamed:in:!private! !
!JadeiteTestCase categoriesFor: #serviceNamed:in:!private! !
!JadeiteTestCase categoriesFor: #setUp!private! !
!JadeiteTestCase categoriesFor: #tearDown!private! !
!JadeiteTestCase categoriesFor: #test_openProjectsBrowser!public!test! !
!JadeiteTestCase categoriesFor: #test_selectMultiplePackages!public!test! !
!JadeiteTestCase categoriesFor: #test_selectMultipleProjects!public!test! !

!JadeiteTestCase class methodsFor!

resources
	^IdentitySet with: JadeiteTestResource! !
!JadeiteTestCase class categoriesFor: #resources!public! !
