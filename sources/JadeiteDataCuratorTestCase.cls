"Filed out from Dolphin Smalltalk 7"!

JadeiteAbstractTestCase subclass: #JadeiteDataCuratorTestCase
	instanceVariableNames: 'jadeiteShell'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteDataCuratorTestCase guid: (GUID fromString: '{c45862e4-9471-42c7-b10f-e7bd27791426}')!
JadeiteDataCuratorTestCase comment: 'Run a few sanity tests as DataCurator during every test run'!
!JadeiteDataCuratorTestCase categoriesForClass!Unclassified! !
!JadeiteDataCuratorTestCase methodsFor!

logoutThenLoginAs: user
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #no.	"closing the transcript will logout the session. don't commit"
	transcript := JadeiteTranscript allInstances detect: [:tran | tran gciSession == GciSession current]
				ifNone: [].
	[transcript view close] ensure: [TestMessageBox disableJadeiteTestMessageBox].
	JadeiteLoginShell allInstances first view close.	"should save to the remote JadeDefaultConnection.gss file"
	jadeiteShell := JadeiteLoginShell show.
	jadeiteShell userIDPresenter value: user.
	jadeiteShell login!

setUp
	self logoutThenLoginAs: 'DataCurator'.
	super setUp.
	self setupProjectBrowser!

tearDown
	self logoutThenLoginAs: 'SystemUser'.
	self assert: jadeiteShell userIDPresenter value equals: 'SystemUser'.
	self assert: GciSession current userID equals: 'SystemUser'.
	self assert: (GciSession current executeString: '3+4') equals: 7!

test_compileClass
	self testsIssue: #issue390 withTitle: 'Rename instance variable with accessor method is... wonky'.
	self selectRowanSample1Class.
	self
		saveClass: 'TestClass'
		superclass: 'Object'
		instVars: #('abc')
		package: 'RowanSample1-Core'.
	[self assert: self projectsPresenter selectedClass name = 'TestClass']
		ensure: [self projectsPresenter basicRemoveClass: self projectsPresenter selectedClass]!

test_loginOk
	self assert: JadeiteLoginShell allInstances first userIDPresenter value equals: 'DataCurator'.
	self assert: GciSession current userID equals: 'DataCurator'.
	self assert: (GciSession current executeString: '3+4') equals: 7
! !
!JadeiteDataCuratorTestCase categoriesFor: #logoutThenLoginAs:!private!setup teardown!support! !
!JadeiteDataCuratorTestCase categoriesFor: #setUp!public!setup teardown! !
!JadeiteDataCuratorTestCase categoriesFor: #tearDown!public!setup teardown! !
!JadeiteDataCuratorTestCase categoriesFor: #test_compileClass!public!test compiing!tests! !
!JadeiteDataCuratorTestCase categoriesFor: #test_loginOk!public!tests! !

