"Filed out from Dolphin Smalltalk 7"!

TestCase subclass: #JadeiteLoginTestCase
	instanceVariableNames: 'session jadeiteLogin'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteLoginTestCase guid: (GUID fromString: '{c685ca72-752c-47e7-8e17-374b9478089c}')!
JadeiteLoginTestCase comment: 'Most Jadeite tests assume a login is already present. 
This tests aspects of login without that assumption.'!
!JadeiteLoginTestCase categoriesForClass!Unclassified! !
!JadeiteLoginTestCase methodsFor!

fail: aString
	TestMessageBox disableJadeiteTestMessageBox.
	^super fail: aString!

jadeLoginShell
	^JadeLogin allInstances first	"dangerous but convenient. Assume there is a login shell available"!

login
	"Private - return a new session that this test will manage itself"

	^jadeiteLogin login!

setUp
	| currentSession |
	jadeiteLogin := self jadeLoginShell.
	currentSession := GciSession current.
	session := self login.
	GciSession current: currentSession!

tearDown
	super tearDown. 
	session
		ifNotNil: 
			[session privateLogout.
			session gciSessionId: nil.
			session library: nil.
			session := nil]!

test_dataCuratorLogin
	| jadeiteShell transcript |
	TestMessageBox enableJadeiteTestMessageBox.
	
	[TestMessageBox plannedResult: #no.	"don't commit"
	GciSession current logout.
	JadeiteLoginShell allInstances first view close.	"should save to the remote JadeDefaultConnection.gss file"
	jadeiteShell := JadeiteLoginShell show.
	jadeiteLogin := jadeiteShell model.
	jadeiteShell userIDPresenter value: 'DataCurator'.	
	jadeiteShell login.
	transcript := JadeiteTranscript allInstances detect: [:tran | tran gciSession == GciSession current]
				ifNone: [].
	self assert: ('*DataCurator*' match: transcript view text).	"test that window header says DataCurator"
	TestMessageBox plannedResult: #no.
	GciSession current logout.
	jadeiteShell userIDPresenter value: 'SystemUser'.	
	jadeiteShell login.
	transcript := JadeiteTranscript allInstances detect: [:tran | tran gciSession == GciSession current]
				ifNone: [].
	self assert: ('*SystemUser*' match: transcript view text)	"test that window header says SystemUser again"]
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

test_gemTask
	| formerGemTask jadeiteShell |
	self testsIssue: #issue416 withTitle: 'NetLDI task in login is not displayed correctly'.
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #no.	"don't commit"
	GciSession current ifNotNil: [:sess | sess logout].
	jadeiteShell := JadeiteLoginShell allInstances first.
	jadeiteLogin := jadeiteShell model.
	formerGemTask := jadeiteLogin gemTask.
	self assert: formerGemTask equals: 'gemnetobject'.	"might need to change this assumption"
	jadeiteLogin gemTask: 'gemnetdebug'.
	jadeiteShell gemTaskPresenter: 'gemnetdebug'.  "update the gui"
	jadeiteShell login.	"have to login so new task is accepted"
	"somehow test that we are using gemnetdebug"
	TestMessageBox plannedResult: #no.
	GciSession current logout.
	JadeiteLoginShell allInstances first view close.	"should save to the remote JadeDefaultConnection.gss file"
	jadeiteShell := JadeiteLoginShell show.
	jadeiteLogin := jadeiteShell model.
	self assert: jadeiteLogin gemTask equals: 'gemnetdebug'.
	jadeiteLogin gemTask: 'gemnetobject'.
	jadeiteShell gemTaskPresenter: 'gemnetobject'.  "update the gui"
	jadeiteShell login.
	"somehow test that we are using gemnetobject"
	TestMessageBox plannedResult: #no.
	[GciSession current logout] ensure: [TestMessageBox disableJadeiteTestMessageBox].
	JadeiteLoginShell allInstances first view close.	"should save to the remote JadeDefaultConnection.gss file"
	jadeiteShell := JadeiteLoginShell show.
	jadeiteLogin := jadeiteShell model.
	self assert: jadeiteLogin gemTask equals: 'gemnetobject'.
	jadeiteShell login.
	self assert: GciSession current isKindOf: GciSession!

test_simpleLogin
	self denyIsNil: session.
	self assert: session isKindOf: GciSession. 
	self deny: session sameAs: GciSession current.  
	self tearDown.
	self assertIsNil: session.
	session := nil!

testsIssue: aSymbol withTitle: anObject! !
!JadeiteLoginTestCase categoriesFor: #fail:!public! !
!JadeiteLoginTestCase categoriesFor: #jadeLoginShell!private!setup teardown! !
!JadeiteLoginTestCase categoriesFor: #login!private!setup teardown! !
!JadeiteLoginTestCase categoriesFor: #setUp!public!setup teardown! !
!JadeiteLoginTestCase categoriesFor: #tearDown!public!setup teardown! !
!JadeiteLoginTestCase categoriesFor: #test_dataCuratorLogin!public!tests! !
!JadeiteLoginTestCase categoriesFor: #test_gemTask!public!tests! !
!JadeiteLoginTestCase categoriesFor: #test_simpleLogin!public!tests! !
!JadeiteLoginTestCase categoriesFor: #testsIssue:withTitle:!private! !

