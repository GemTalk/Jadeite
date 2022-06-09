"Filed out from Dolphin Smallalk"!

JadeiteAbstractTestCase subclass: #JadeiteComponentEditorTestCase
	instanceVariableNames: 'componentEditor treeModel componentPresenterList'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteComponentEditorTestCase guid: (GUID fromString: '{727f02cf-18f8-4a71-b3af-979b06a570a3}')!
JadeiteComponentEditorTestCase comment: ''!
!JadeiteComponentEditorTestCase categoriesForClass!Unclassified! !
!JadeiteComponentEditorTestCase methodsFor!

assertMenuItemIsEnabled: command in: menu
	| query |
	query := self commandQueryFor: command in: menu.
	self assert: query isEnabled!

assertSorted: items
	| sortedChildren |
	sortedChildren := items asSortedCollection: [:x :y | x name < y name].
	self assert: items = sortedChildren asOrderedCollection!

commandQueryFor: command in: menu
	| query menuItem |
	menuItem := menu items detect: [:item | item command = command].
	query := CommandQuery commandDescription: menuItem commandDescription
				source: componentEditor primaryPresenter packageListPresenter view.
	componentEditor primaryPresenter queryCommand: query.
	^query!

denyMenuItemIsEnabled: command in: menu
	| query |
	query := self commandQueryFor: command in: menu.
	self deny: query isEnabled!

openComponentEditorOnRowanSample9
	self selectRowanSample9ProjectFromTranscript.
	componentEditor := self transcript editComponents!

resetTreeModel
	treeModel := componentPresenterList model!

selectComponentNamed: componentName
	| componentService |
	componentService := componentPresenterList model asBag
				detect: [:componentDefinitionService | componentDefinitionService name = componentName]
				ifNone: [].
	^componentPresenterList selection: componentService!

selectPackageNamed: packageName
	| thePackageName |
	thePackageName := componentEditor primaryPresenter packageListPresenter model asBag
				detect: [:listPackageService | listPackageService = packageName]
				ifNone: [].
	^componentEditor primaryPresenter packageListPresenter selection: thePackageName!

selectRowanSample9ProjectFromTranscript
	| rowanSample9Project |
	rowanSample9Project := self transcript projectListPresenter projectListPresenter list
				detect: [:projectService | projectService name = 'RowanSample9'].
	self transcript projectListPresenter projectListPresenter selection: rowanSample9Project.
	^rowanSample9Project!

setUp
	super setUp. 
	self openComponentEditorOnRowanSample9.
	componentPresenterList := componentEditor primaryPresenter componentListPresenter.
	self resetTreeModel!

tearDown
	super tearDown. 
	self destroy: componentEditor. 
	self destroy: projectsBrowser
	!

test_addComponent
	| parent |
	parent := self selectComponentNamed: 'common/Tests'.
	self assert: parent name = 'common/Tests'.
	componentEditor primaryPresenter basicAddComponent: 'Daughter of Tests'.
	self assert: componentPresenterList selection name = 'Daughter of Tests'.
	self assert: ((treeModel childrenOf: parent) includes: componentPresenterList selection).
	parent := self selectComponentNamed: 'Core'.
	self assert: parent name = 'Core'.
	componentEditor primaryPresenter basicAddComponent: 'Son of Core'.
	self assert: componentPresenterList selection name = 'Son of Core'.
	self assert: ((treeModel childrenOf: parent) includes: componentPresenterList selection).
	self selectComponentNamed: nil.
	self assertIsNil: componentPresenterList selectionOrNil.
	componentEditor primaryPresenter basicAddComponent: 'New Root'.
	self assert: componentPresenterList selection name = 'New Root'.
	self assertIsNil: (treeModel parentOf: componentPresenterList selection)!

test_componentEditorDisplaysComponents
	| items roots children |
	"sanity test that components show up in component editor"
	self assert: componentEditor isKindOf: JadeiteComponentEditor.
	roots := treeModel roots.
	self assert: roots size = 1.
	self assert: roots first name = 'Core'.
	items := treeModel asBag.
	items do: [:item | self assert: (item isKindOf: RowanComponentDefinitionService)].
	children := treeModel childrenOf: roots first.
	self assert: children size > 0	"don't know much about what to expect yet except that there should be children"!

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

test_packageMenuEnablement
	| toolbarMenu contextMenu |
	contextMenu := componentEditor primaryPresenter packageListPresenter view contextMenu.
	self selectComponentNamed: 'common/Tests'.	"no packages"
	self assertMenuItemIsEnabled: #addPackage in: contextMenu.
	self denyMenuItemIsEnabled: #renamePackage in: contextMenu.
	self denyMenuItemIsEnabled: #removePackages in: contextMenu.
	self selectComponentNamed: nil.	"no components selected"
	self denyMenuItemIsEnabled: #addPackage in: contextMenu.
	self denyMenuItemIsEnabled: #renamePackage in: contextMenu.
	self denyMenuItemIsEnabled: #removePackages in: contextMenu.
	self selectComponentNamed: 'common/tests/Tests'.
	self selectPackageNamed: 'RowanSample9-Tests'.
	self assertMenuItemIsEnabled: #addPackage in: contextMenu.
	self assertMenuItemIsEnabled: #renamePackage in: contextMenu.
	self assertMenuItemIsEnabled: #removePackages in: contextMenu.
	toolbarMenu := componentEditor view menuBar items detect: [:menu | menu text = 'Packages'].
	self selectComponentNamed: 'common/Tests'.	"no packages"
	self assertMenuItemIsEnabled: #addPackage in: toolbarMenu.
	self denyMenuItemIsEnabled: #renamePackage in: toolbarMenu.
	self denyMenuItemIsEnabled: #removePackages in: toolbarMenu.
	self selectComponentNamed: nil.	"no components selected"
	self denyMenuItemIsEnabled: #addPackage in: toolbarMenu.
	self denyMenuItemIsEnabled: #renamePackage in: toolbarMenu.
	self denyMenuItemIsEnabled: #removePackages in: toolbarMenu.
	self selectComponentNamed: 'common/tests/Tests'.
	self selectPackageNamed: 'RowanSample9-Tests'.
	self assertMenuItemIsEnabled: #addPackage in: toolbarMenu.
	self assertMenuItemIsEnabled: #renamePackage in: toolbarMenu.
	self assertMenuItemIsEnabled: #removePackages in: toolbarMenu!

test_removeComponent
	| parent addedComponent |
	parent := self selectComponentNamed: 'common/Tests'.
	self assert: parent name = 'common/Tests'.
	componentEditor primaryPresenter basicAddComponent: 'Daughter of Tests'.
	self assert: componentPresenterList selection name = 'Daughter of Tests'.
	addedComponent := componentPresenterList selection.
	componentEditor primaryPresenter basicRemoveComponent.
	self resetTreeModel.	"model has been rebuilt - update instance variable for test's sake"
	self deny: (treeModel includes: addedComponent)!

test_selectDoesNotAccumulateJunk
	"Services were building up during component selection and blowing out temp obj memory. 
	Just do a bunch of selections."

	10 timesRepeat: 
			[treeModel do: 
					[:service |
					componentPresenterList selection: service.
					self assert: componentPresenterList selection = service]]! !
!JadeiteComponentEditorTestCase categoriesForMethods!
assertMenuItemIsEnabled:in:!private!support! !
assertSorted:!private!support!tests! !
commandQueryFor:in:!private!support! !
denyMenuItemIsEnabled:in:!private!support! !
openComponentEditorOnRowanSample9!private!support! !
resetTreeModel!private!support! !
selectComponentNamed:!private!support! !
selectPackageNamed:!private!support! !
selectRowanSample9ProjectFromTranscript!private!support! !
setUp!public!support! !
tearDown!public!support! !
test_addComponent!public!tests! !
test_componentEditorDisplaysComponents!public!tests! !
test_componentEditorDisplaysPackages!public!tests! !
test_componentTreeHasAlphabeticalOrder!public!tests! !
test_openComponentEditor!public!tests! !
test_packageMenuEnablement!public!tests! !
test_removeComponent!public!tests! !
test_selectDoesNotAccumulateJunk!public!tests! !
!

