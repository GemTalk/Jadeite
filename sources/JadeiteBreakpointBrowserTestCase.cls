"Filed out from Dolphin Smalltalk 7"!

JadeiteAbstractTestCase subclass: #JadeiteBreakpointBrowserTestCase
	instanceVariableNames: 'breakpointBrowser'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteBreakpointBrowserTestCase guid: (GUID fromString: '{b25133d6-569d-4d76-8b31-b1c37c1d7705}')!
JadeiteBreakpointBrowserTestCase comment: ''!
!JadeiteBreakpointBrowserTestCase categoriesForClass!Unclassified! !
!JadeiteBreakpointBrowserTestCase methodsFor!

openBreakpointBrowser
	^breakpointBrowser := transcript browseBreakpoints!

tearDown
	breakpointBrowser ifNotNil: [breakpointBrowser view close]!

test_openBreakpointBrowser
	self openBreakpointBrowser.
	self assert: breakpointBrowser isKindOf: JadeiteBreakpointBrowser. 
!

test_showsBreakpoints
	| treeModel |
	self openProjectBrowser.
	
	[| indicators |
	self selectRowanSample1Test.
	self selectMethodNamed: #test2.
	self projectsPresenter setBreakPointAt: 2 in: self projectsPresenter.
	self openBreakpointBrowser.
	treeModel := breakpointBrowser breakpointListPresenter model.
	self assert: treeModel roots asArray equals: #('RowanSample1Test').
	self assert: treeModel rootNodes first children first object selector equals: #test2.
	breakpointBrowser breakpointListPresenter selections: #('RowanSample1Test').
	self assert: breakpointBrowser methodSourcePresenter value isEmpty.
	breakpointBrowser breakpointListPresenter
		selections: (Array with: treeModel rootNodes first children first object).
	self assert: breakpointBrowser methodSourcePresenter value
		equals: 'test2

	self assert: RowanSample1 bar = ''bar'''.
	indicators := breakpointBrowser methodSourcePresenter documentPresenter view indicators.
	self assert: indicators size equals: 5. 
	self assert: (indicators at: 1) styleName equals: #stepPoint.
	self assert: (indicators at: 1) range equals: (1 to: 5).
	self assert: (indicators at: 2) styleName equals: #breakPoint.
	self assert: (indicators at: 2) range equals: (35 to: 37).
	self assert: (indicators at: 3) styleName equals: #stepPoint.
	self assert: (indicators at: 3) range equals: (39 to: 40).
	self assert: (indicators at: 4) styleName equals: #stepPoint.
	self assert: (indicators at: 4) range equals: (14 to: 20).
	self assert: (indicators at: 5) styleName equals: #stepPoint.
	self assert: (indicators at: 5) range equals: (45 to: 46).
]
			ensure: [self destroy: projectsBrowser]! !
!JadeiteBreakpointBrowserTestCase categoriesFor: #openBreakpointBrowser!private!support! !
!JadeiteBreakpointBrowserTestCase categoriesFor: #tearDown!public!support! !
!JadeiteBreakpointBrowserTestCase categoriesFor: #test_openBreakpointBrowser!public!tests! !
!JadeiteBreakpointBrowserTestCase categoriesFor: #test_showsBreakpoints!public!tests! !

