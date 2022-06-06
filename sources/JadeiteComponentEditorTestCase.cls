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

assertSorted: items
	| sortedChildren |
	sortedChildren := items asSortedCollection: [:x :y | x name < y name].
	self assert: items = sortedChildren asOrderedCollection!

openComponentEditorOnRowanSample9
	self selectRowanSample9ProjectFromTranscript.
	componentEditor := self transcript editComponents!

selectComponentNamed: componentName
	| presenter componentService |
	presenter := componentEditor primaryPresenter componentListPresenter.
	componentService := presenter model asBag
				detect: [:componentDefinitionService | componentDefinitionService name = componentName].
	presenter selection: componentService!

selectRowanSample9ProjectFromTranscript
	| rowanSample9Project |
	rowanSample9Project := self transcript projectListPresenter projectListPresenter list
				detect: [:projectService | projectService name = 'RowanSample9'].
	self transcript projectListPresenter projectListPresenter selection: rowanSample9Project.
	^rowanSample9Project!

setUp
	super setUp. 
	self openComponentEditorOnRowanSample9.!

tearDown
	super tearDown. 
	self destroy: componentEditor. 
	self destroy: projectsBrowser
	!

test_componentEditorDisplaysComponents
	| items roots treeModel children |
	"sanity test that components show up in component editor"
	self assert: componentEditor isKindOf: JadeiteComponentEditor.
	treeModel := componentEditor primaryPresenter componentListPresenter model.
	roots := treeModel roots.
	self assert: roots size = 1.
	self assert: roots first name = 'Core'.
	items := treeModel asBag.
	items do: [:item | self assert: (item isKindOf: RowanComponentDefinitionService)].
	children := treeModel childrenOf: roots first. 
	self assert: children size > 0 "don't know much about what to expect yet except that there should be children" !

test_componentEditorDisplaysPackages
	| packageListPresenter |
	packageListPresenter := componentEditor primaryPresenter packageListPresenter.
	self assert: packageListPresenter size = 0.	"currently, opening a component editor selects no components"
	self selectComponentNamed: 'common/Core'.
	self assert: packageListPresenter list size > 0.
	packageListPresenter list
		do: [:packageDefinitionService | packageDefinitionService isKindOf: RowanPackageDefinitionService]!

test_componentTreeHasAlphabeticalOrder
	"The component tree should display components in alphabetical order"

	| treeModel |
	treeModel := componentEditor primaryPresenter componentListPresenter model.
	treeModel do: [:service | self assertSorted: (treeModel childrenOf: service)]!

test_openComponentEditor
	"should be able to edit components from project list and project browser"
	self destroy: componentEditor. 
	self selectRowanSample9ProjectFromTranscript.
	componentEditor := self transcript editComponents.
	[self assert: (componentEditor isKindOf: JadeiteComponentEditor)]
		ensure: [self destroy: componentEditor].
	self openProjectBrowser.
	self projectsPresenter selectProjectNamed: 'RowanSample9'.
	componentEditor := self projectsPresenter editComponents.
	self assert: (componentEditor isKindOf: JadeiteComponentEditor)!

test_selectDoesNotAccumulateJunk
	"Services were building up during component selection and blowing out temp obj memory. 
	Just do a bunch of selections."

	| treeModel |
	treeModel := componentEditor primaryPresenter componentListPresenter model.
	10 timesRepeat: 
			[treeModel do: 
					[:service |
					componentEditor primaryPresenter componentListPresenter selection: service.
					self assert: componentEditor primaryPresenter componentListPresenter selection = service]]! !
!JadeiteComponentEditorTestCase categoriesForMethods!
assertSorted:!private!support!tests! !
openComponentEditorOnRowanSample9!private!support! !
selectComponentNamed:!private!support! !
selectRowanSample9ProjectFromTranscript!private!support! !
setUp!public!support! !
tearDown!public!support! !
test_componentEditorDisplaysComponents!public!tests! !
test_componentEditorDisplaysPackages!public!tests! !
test_componentTreeHasAlphabeticalOrder!public!tests! !
test_openComponentEditor!public!tests! !
test_selectDoesNotAccumulateJunk!public!tests! !
!

