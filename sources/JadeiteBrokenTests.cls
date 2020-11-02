"Filed out from Dolphin Smalltalk 7"!

TestCase2 subclass: #JadeiteBrokenTests
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteBrokenTests guid: (GUID fromString: '{80fcc550-8af1-4dea-b644-8363e6d40b71}')!
JadeiteBrokenTests comment: 'Tests which no longer work, or can''t currently be made to work, 
but shouldn''t be thrown away just yet. '!
!JadeiteBrokenTests categoriesForClass!Unclassified! !
!JadeiteBrokenTests methodsFor!

test_findClassNotInProject
	"we no longer open the old dictionary browser"

	self testsIssue: #issue217 withTitle: 'Eliminate Dictionary Browser'.
	self projectsPresenter updateAfterFindClass: (RowanClassService new name: 'Object').
	self assert: self classListPresenter selection name equals: 'Object'.
	self assert: self dictionaryPresenter selection name equals: 'Globals'.
	self assert: self projectListPresenter selection name equals: RowanProjectService noneProject name.
	self assert: self projectsPresenter isNoneProjectSelected.
	self projectsPresenter updateAfterFindClass: (RowanClassService new name: 'ExecBlock').
	self assert: self classListPresenter selection name equals: 'ExecBlock'.
	self assert: self dictionaryPresenter selection name equals: 'Globals'.
	self assert: self projectListPresenter selection name equals: RowanProjectService noneProject name.
	self assert: self projectsPresenter isNoneProjectSelected.
	self projectsPresenter updateAfterFindClass: (RowanClassService new name: 'CypressClassDefinition').
	self assert: self classListPresenter selection name equals: 'CypressClassDefinition'.
	self assert: self classListPresenter selection definedPackageName equals: 'Cypress-Definitions'.
	self assert: self packageListPresenter selection name equals: 'Cypress-Definitions'.
	self assert: self projectListPresenter selection name equals: 'Cypress'.
	self deny: self projectsPresenter isNoneProjectSelected! !
!JadeiteBrokenTests categoriesFor: #test_findClassNotInProject!public! !

