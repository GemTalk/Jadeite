"Filed out from Dolphin Smallalk"!

JadeiteProjectBrowserAbstractTestCase subclass: #JadeitePackageGroupTestCase
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeitePackageGroupTestCase guid: (GUID fromString: '{bd0097d9-f96d-4bfd-99ee-7e4c75a89f8e}')!
JadeitePackageGroupTestCase comment: ''!
!JadeitePackageGroupTestCase categoriesForClass!Unclassified! !
!JadeitePackageGroupTestCase methodsFor!

test_basicDisplayPackageGroups
	"package groups are another selectable pane in the browser. 
	Sanity test that they are displaying"

	| packageGroupModel children expectedChildNames childNames |
	self selectServiceNamed: 'RowanSample9' in: self projectListPresenter.
	packageGroupModel := self projectsPresenter packageGroupPresenter model.
	self assert: packageGroupModel notEmpty.
	self assert: packageGroupModel roots size = 1.
	self assert: packageGroupModel roots first name = 'All Packages'.
	children := packageGroupModel childrenOf: packageGroupModel roots first.
	childNames := children collect: [:child | child name].
	expectedChildNames := #('groups/WorkGroup_dkh' 'groups/Tests' 'groups/Examples' 'groups/Projects' 'groups/Loader' 'groups/Rowan').
	childNames do: [:childName | self assert: (expectedChildNames includes: childName)].
	expectedChildNames do: [:expectedChildName | self assert: (childNames includes: expectedChildName)]!

test_packageGroupsFromLoadedPackage
	"in the browser, the package groups shown should be derived from the loaded project, 
	not the project definition."

	| packageGroupModel children loadedProjectPackageGroupNames childNames |
	self testsIssue: #issue898
		withTitle: 'Let''s consider using the loaded project for displaying packageGroups in the project browser'.
	self selectServiceNamed: 'RowanSample9' in: self projectListPresenter.
	packageGroupModel := self projectsPresenter packageGroupPresenter model.
	self assert: packageGroupModel notEmpty.
	self assert: packageGroupModel roots size = 1.
	self assert: packageGroupModel roots first name = 'All Packages'.
	children := packageGroupModel childrenOf: packageGroupModel roots first.
	childNames := children collect: [:child | child name].
	"get loaded project names directly for test"
	loadedProjectPackageGroupNames := (RowanAnsweringService new
				execReturningObject: '(Rowan projectNamed: ''RowanSample9'') packageGroupNames'
				in: session) answer.
	childNames do: [:childName | self assert: (loadedProjectPackageGroupNames includes: childName)].
	loadedProjectPackageGroupNames
		do: [:expectedChildName | self assert: (childNames includes: expectedChildName)]!

test_packageGroupsSelection
	"test that only loaded packages show up in the right package group"

	| packageGroupName packageNames |
	self testsIssue: #issue898
		withTitle: 'Let''s consider using the loaded project for displaying packageGroups in the project browser'.
	self selectServiceNamed: 'RowanSample9' in: self projectListPresenter.
	self projectsPresenter packageGroupPresenter model asBag do: 
			[:packageGroupService |
			packageGroupName := packageGroupService name.
			packageGroupName = 'All Packages'
				ifFalse: 
					[self selectTreeServicesNamed: (Array with: packageGroupName)
						in: self projectsPresenter packageGroupPresenter.
					packageNames := (RowanAnsweringService new
								execReturningObject: '| packageGroup loadedProjectPackageNames |
					packageGroup := (Rowan projectNamed: ''RowanSample9'') packageGroupNamed: '''
										, packageGroupName
											, '''. 
					loadedProjectPackageNames := (Rowan image loadedProjectNamed: ''RowanSample9'') packageNames.
					packageGroup packageNames select:[:packageName | loadedProjectPackageNames includes: packageName]'
								in: session) answer.
					self
						assert: (self packageListPresenter list collect: [:packageService | packageService name]) asArray
								= packageNames]]!

test_rowanAllPackagesDoesNotTakeTooLong
	"Although it's hard to test performance in a unit test, 
	do a sanity test that selecting All Packages in the Rowan
	project doesn't take a long time. There was a bug causing
	horrendous performance."

	| expectedTime time |
	self selectServiceNamed: 'Rowan' in: self projectListPresenter.
	expectedTime := 2000.	"ms"
	time := Time millisecondsToRun: 
					[self selectTreeServicesNamed: (Array with: 'All Packages')
						in: self projectsPresenter packageGroupPresenter].
	self assert: time < expectedTime! !
!JadeitePackageGroupTestCase categoriesForMethods!
test_basicDisplayPackageGroups!public!tests! !
test_packageGroupsFromLoadedPackage!public!tests! !
test_packageGroupsSelection!public!tests! !
test_rowanAllPackagesDoesNotTakeTooLong!public!tests! !
!

