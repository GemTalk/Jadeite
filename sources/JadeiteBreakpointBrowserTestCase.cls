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

primaryTestWindow
	"Every test should have a primary window it is testing. 
	If not, just return nil"

	^breakpointBrowser!

setUp
	super setUp.
	JadePresenter clearAllBreakpointsIn: session!

tearDown
	breakpointBrowser ifNotNil: [breakpointBrowser view close].
	projectsBrowser ifNotNil: [self destroy: projectsBrowser]!

test_addedBreakpointAddsMethod
	| treeModel |
	self openProjectBrowser.
	
	self selectRowanSample1Test.
	self selectMethodNamed: #test2.
	self projectsPresenter setBreakPointAt: 1 in: self projectsPresenter.
	self openBreakpointBrowser.
	treeModel := breakpointBrowser breakpointListPresenter model.
	self assert: treeModel roots asArray equals: #('RowanSample1Test').
	self assert: treeModel rootNodes first children first object selector equals: #test2.
	breakpointBrowser breakpointListPresenter selections: #('RowanSample1Test').
	self assert: breakpointBrowser methodSourcePresenter value isEmpty.
	self assert: treeModel rootNodes first children size equals: 1.
	self assert: treeModel rootNodes first children first object breakpointDisplayString
		equals: 'test2 (1)'.
	self selectMethodNamed: #test1.
	self projectsPresenter setBreakPointAt: 1 in: self projectsPresenter.
	self assert: treeModel rootNodes first children size equals: 2.
	self assert: treeModel rootNodes first children first object breakpointDisplayString
		equals: 'test1 (1)'.
	self assert: treeModel rootNodes first children last object breakpointDisplayString
		equals: 'test2 (1)'!

test_additionalAccelerators
	"No way yet to adequately test accelerators function
	but we can assert that we tell Dolphin to set them up"

	self testsIssue: #issue329 withTitle: 'Need accelerator key tests'.
	self openBreakpointBrowser.
	self assert: (breakpointBrowser additionalAccelerators includes: #(#editSaveMethod 'Ctrl+S')).
	self assert: breakpointBrowser additionalAccelerators size equals: 2	"should fail if we add a new one"!

test_breakpointAdditionsUpdateAutomatically
	| treeModel indicators |
	self openProjectBrowser.
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
	self assert: treeModel rootNodes first children first object breakpointDisplayString
		equals: 'test2 (1)'.
	self assert: ('test2*self assert: RowanSample1 bar = ''bar'''
				match: breakpointBrowser methodSourcePresenter value).
	indicators := breakpointBrowser methodSourcePresenter documentPresenter view indicators.
	self assert: indicators size equals: 5.
	self assert: (indicators at: 1) styleName equals: #stepPoint.
	self assert: (indicators at: 1) range equals: (1 to: 5).
	self assert: (indicators at: 2) styleName equals: #breakPoint.
	self assert: (indicators at: 2) range equals: (35 to: 37).
	self projectsPresenter setBreakPointAt: 1 in: self projectsPresenter.	"set another breakpoint"
	indicators := breakpointBrowser methodSourcePresenter documentPresenter view indicators.
	self assert: indicators size equals: 5.
	self assert: (indicators at: 1) styleName equals: #breakPoint.
	self assert: (indicators at: 1) range equals: (1 to: 5).
	self assert: (indicators at: 2) styleName equals: #breakPoint.
	self assert: (indicators at: 2) range equals: (35 to: 37).
	self assert: treeModel rootNodes first children first object breakpointDisplayString
		equals: 'test2 (2)'!

test_breakpointIsSelectedAndVisible
	| firstBreakpoint |
	self testsIssue: #issue514
		withTitle: '(3.0.77) should breakpoint browser come up with the first breakpoint in method highlighted?'.
	self openProjectBrowser.
	self selectRowanSample1Test.
	self selectMethodNamed: #test2.
	self projectsPresenter setBreakPointAt: 1 in: self projectsPresenter.
	self openBreakpointBrowser.
	self assert: breakpointBrowser selectedMethodServices size equals: 1.
	self assert: breakpointBrowser selectedMethodServices first selector equals: #test2.
	firstBreakpoint := breakpointBrowser methodSourcePresenter documentPresenter view indicators
				detect: [:indicator | indicator styleName == #breakPoint or: [indicator styleName == #disabledBreakPoint]].
	self assert: firstBreakpoint range
		equals: breakpointBrowser methodSourcePresenter documentPresenter view selectionRange!

test_breakpointRemovalsUpdateAutomatically
	| treeModel indicators |
	self openProjectBrowser.
	self selectRowanSample1Test.
	self selectMethodNamed: #test2.
	self projectsPresenter setBreakPointAt: 1 in: self projectsPresenter.
	self projectsPresenter setBreakPointAt: 2 in: self projectsPresenter.
	self openBreakpointBrowser.
	treeModel := breakpointBrowser breakpointListPresenter model.
	self assert: treeModel roots asArray equals: #('RowanSample1Test').
	self assert: treeModel rootNodes first children first object selector equals: #test2.
	breakpointBrowser breakpointListPresenter selections: #('RowanSample1Test').
	self assert: breakpointBrowser methodSourcePresenter value isEmpty.
	breakpointBrowser breakpointListPresenter
		selections: (Array with: treeModel rootNodes first children first object).
	self assert: treeModel rootNodes first children first object breakpointDisplayString
		equals: 'test2 (2)'.
	self assert: ('test2*self assert: RowanSample1 bar = ''bar''' match: breakpointBrowser methodSourcePresenter value). 
	indicators := breakpointBrowser methodSourcePresenter documentPresenter view indicators.
	self assert: indicators size equals: 5.
	self assert: (indicators at: 1) styleName equals: #breakPoint.
	self assert: (indicators at: 1) range equals: (1 to: 5).
	self assert: (indicators at: 2) styleName equals: #breakPoint.
	self assert: (indicators at: 2) range equals: (35 to: 37).
	self assert: treeModel rootNodes first children first object breakpointDisplayString
		equals: 'test2 (2)'.
	self projectsPresenter clearBreakPointAt: 1 in: self projectsPresenter.
	indicators := breakpointBrowser methodSourcePresenter documentPresenter view indicators.
	self assert: indicators size equals: 5.
	self assert: (indicators at: 1) styleName equals: #stepPoint.
	self assert: (indicators at: 1) range equals: (1 to: 5).
	self assert: (indicators at: 2) styleName equals: #breakPoint.
	self assert: (indicators at: 2) range equals: (35 to: 37).
	self assert: treeModel rootNodes first children first object breakpointDisplayString
		equals: 'test2 (1)'!

test_clearMethodPaneWhenBreakpointRemoved
	| originalSource |
	self testsIssue: #issue763
		withTitle: 'Breakpoint browser text pane not refreshed on method disappear (3.1pr3)'.
	self openProjectBrowser.
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	originalSource := projectsBrowser currentCard methodSourcePresenter value.
	self projectsPresenter setBreakPointAt: 1 in: self projectsPresenter.
	breakpointBrowser := self projectsPresenter browseBreakpoints.
	self assert: breakpointBrowser selectedMethodServices size equals: 1.
	self assert: breakpointBrowser selectedMethodServices first selector equals: #test1.
	self assert: breakpointBrowser methodSourcePresenter value equals: originalSource.
	self projectsPresenter clearBreakPointAt: 1 in: self projectsPresenter.
	self assert: breakpointBrowser methodSourcePresenter value equals: String new!

test_clearMethodPaneWhenBreakpointRemoved2
	"clear from the breakpoint browser which has slightly different behavior"

	| originalSource |
	self testsIssue: #issue763
		withTitle: 'Breakpoint browser text pane not refreshed on method disappear (3.1pr3)'.
	self openProjectBrowser.
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	originalSource := projectsBrowser currentCard methodSourcePresenter value.
	self projectsPresenter setBreakPointAt: 1 in: self projectsPresenter.
	breakpointBrowser := self projectsPresenter browseBreakpoints.
	self assert: breakpointBrowser selectedMethodServices size equals: 1.
	self assert: breakpointBrowser selectedMethodServices first selector equals: #test1.
	self assert: breakpointBrowser methodSourcePresenter value equals: originalSource.
	breakpointBrowser methodSourcePresenter clearBreakPointAt: 1 in: self projectsPresenter.
	self assert: breakpointBrowser methodSourcePresenter value equals: String new!

test_globalAdditionalAccelerators
	self openBreakpointBrowser.
	self primaryTestWindow ifNil: [^self].	"not all test classes have a primaryTestWindow"
	self assert: (self primaryTestWindow additionalAccelerators includes: #(#raiseConsole 'Ctrl+F7'))!

test_openBreakpointBrowser
	self openBreakpointBrowser.
	self assert: breakpointBrowser isKindOf: JadeiteBreakpointBrowser. 
!

test_openBreakpointBrowserDisabledSourcePane
	self openBreakpointBrowser.
	self assert: breakpointBrowser methodSourcePresenter value equals: String new.
	self assert: breakpointBrowser methodSourcePresenter documentPresenter view isReadOnly!

test_revert
	"revert should revert back to the method source
	not related to issue per say but this comment within it
	https://github.com/GemTalk/Jadeite/issues/584#issuecomment-610531382"

	| originalSource |
	self testsIssue: #issue584 withTitle: 'Would like changed method indicator on tab'.
	self openProjectBrowser.
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	originalSource := projectsBrowser currentCard methodSourcePresenter value.
	self projectsPresenter setBreakPointAt: 1 in: self projectsPresenter.
	breakpointBrowser := self projectsPresenter browseBreakpoints.
	self assert: breakpointBrowser selectedMethodServices size equals: 1.
	self assert: breakpointBrowser selectedMethodServices first selector equals: #test1.
	self assert: breakpointBrowser methodSourcePresenter value equals: originalSource.
	breakpointBrowser methodSourcePresenter value: originalSource , 'blahblahblah'.
	self assert: breakpointBrowser methodSourcePresenter value equals: originalSource , 'blahblahblah'.
	breakpointBrowser methodSourcePresenter editRevert.
	self assert: breakpointBrowser methodSourcePresenter value equals: originalSource!

test_selectedMethodIsFirstSelected
	"when bp browser is opened from the project browser, try to 
	select the selected method in the bp browser using the selectin
	in the project browser"

	| firstBreakpoint |
	self testsIssue: #issue514
		withTitle: '(3.0.77) should breakpoint browser come up with the first breakpoint in method highlighted?'.
	self openProjectBrowser.
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	self projectsPresenter setBreakPointAt: 1 in: self projectsPresenter.
	self selectMethodNamed: #test2.
	self projectsPresenter setBreakPointAt: 1 in: self projectsPresenter.
	self assert: self projectsPresenter methodListPresenter selection selector equals: #test2.	"not the first in the bp list"
	breakpointBrowser := self projectsPresenter browseBreakpoints.
	self assert: breakpointBrowser selectedMethodServices size equals: 1.
	self assert: breakpointBrowser selectedMethodServices first selector equals: #test2.
	firstBreakpoint := breakpointBrowser methodSourcePresenter documentPresenter view indicators
				detect: [:indicator | indicator styleName == #breakPoint or: [indicator styleName == #disabledBreakPoint]].
	self assert: firstBreakpoint range
		equals: breakpointBrowser methodSourcePresenter documentPresenter view selectionRange!

test_showsBreakpoints
	| treeModel indicators |
	self openProjectBrowser.
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
	self assert: treeModel rootNodes first children first object breakpointDisplayString
		equals: 'test2 (1)'.
	self assert: ('test2*self assert: RowanSample1 bar = ''bar''' match: breakpointBrowser methodSourcePresenter value).
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
	self assert: (indicators at: 5) range equals: (45 to: 46)! !
!JadeiteBreakpointBrowserTestCase categoriesFor: #openBreakpointBrowser!private!support! !
!JadeiteBreakpointBrowserTestCase categoriesFor: #primaryTestWindow!accessing!public! !
!JadeiteBreakpointBrowserTestCase categoriesFor: #setUp!public!support! !
!JadeiteBreakpointBrowserTestCase categoriesFor: #tearDown!public!support! !
!JadeiteBreakpointBrowserTestCase categoriesFor: #test_addedBreakpointAddsMethod!public!tests! !
!JadeiteBreakpointBrowserTestCase categoriesFor: #test_additionalAccelerators!public!tests! !
!JadeiteBreakpointBrowserTestCase categoriesFor: #test_breakpointAdditionsUpdateAutomatically!public!tests! !
!JadeiteBreakpointBrowserTestCase categoriesFor: #test_breakpointIsSelectedAndVisible!public!tests! !
!JadeiteBreakpointBrowserTestCase categoriesFor: #test_breakpointRemovalsUpdateAutomatically!public!tests! !
!JadeiteBreakpointBrowserTestCase categoriesFor: #test_clearMethodPaneWhenBreakpointRemoved!public!tests! !
!JadeiteBreakpointBrowserTestCase categoriesFor: #test_clearMethodPaneWhenBreakpointRemoved2!public!tests! !
!JadeiteBreakpointBrowserTestCase categoriesFor: #test_globalAdditionalAccelerators!public!tests! !
!JadeiteBreakpointBrowserTestCase categoriesFor: #test_openBreakpointBrowser!public!tests! !
!JadeiteBreakpointBrowserTestCase categoriesFor: #test_openBreakpointBrowserDisabledSourcePane!public!tests! !
!JadeiteBreakpointBrowserTestCase categoriesFor: #test_revert!public!tests! !
!JadeiteBreakpointBrowserTestCase categoriesFor: #test_selectedMethodIsFirstSelected!public!tests! !
!JadeiteBreakpointBrowserTestCase categoriesFor: #test_showsBreakpoints!public!tests! !

