"Filed out from Dolphin Smallalk"!

JadeiteAbstractTestCase subclass: #JadeiteComponentEditorTestCase
	instanceVariableNames: 'componentEditor'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteComponentEditorTestCase guid: (GUID fromString: '{727f02cf-18f8-4a71-b3af-979b06a570a3}')!
JadeiteComponentEditorTestCase comment: ''!
!JadeiteComponentEditorTestCase categoriesForClass!Unclassified! !
!JadeiteComponentEditorTestCase methodsFor!

tearDown
	super tearDown. 
	self destroy: componentEditor. 
	self destroy: projectsBrowser
	!

test_openComponentEditor
	"should be able to edit components from project list and project browser"

	| rowanSample9Project |
	self openProjectBrowser.
	rowanSample9Project := self projectListPresenter list
				detect: [:projectService | projectService name = 'RowanSample9'].
	self projectListPresenter selection: rowanSample9Project.
	componentEditor := self transcript editComponents.
	[self assert: (componentEditor isKindOf: JadeiteComponentEditor)]
		ensure: [self destroy: componentEditor].
	self projectsPresenter selectProjectNamed: 'RowanSample9'.
	componentEditor := self projectsPresenter editComponents.
	self assert: (componentEditor isKindOf: JadeiteComponentEditor)! !
!JadeiteComponentEditorTestCase categoriesForMethods!
tearDown!public!support! !
test_openComponentEditor!public!tests! !
!

