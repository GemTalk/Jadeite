"Filed out from Dolphin Smalltalk 7"!

TestCase subclass: #JadeiteLoginTestCase
	instanceVariableNames: 'session jadeiteLogin parmFileName jadeiteShell'
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

loginWithRetry: loginShell
	| loginError |
	loginError := true.
	[loginError] whileTrue: 
			[
			[loginShell loginWithoutErrorHandling.
			loginError := false] on: Error
					do: [:ex | (Delay forMilliseconds: 100) wait]]!

setUp
	"get a new session for this test"

	| currentSession |
	jadeiteLogin := self jadeLoginShell.
	currentSession := GciSession current.
	session := self login.
	GciSession current: currentSession!

setupToLogin
	GciSession current ifNotNil: [:sess | sess logout].
	JadeiteLoginShell allInstances do: [:inst | inst view close].
	jadeiteShell := JadeiteLoginShell show position: 80 @ 20.
	parmFileName := 'jadeiteLoginParameters.log'.
	(File exists: parmFileName) ifTrue: [File delete: parmFileName].
	jadeiteLogin := jadeiteShell model.
	self assert: jadeiteShell debugPathPresenter value isEmpty!

tearDown
	super tearDown. 
	session
		ifNotNil: 
			[session privateLogout.
			session gciSessionId: nil.
			session library: nil.
			session := nil]!

test_debugLoginDumpsParameters
	self testsIssue: #issue681 withTitle: 'Write out login values if "Debug GCI" is enabled'.
	"logging out. If we need to commit, too bad"
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #no.
	[self setupToLogin] ensure: [TestMessageBox disableJadeiteTestMessageBox].
	self loginWithRetry: jadeiteShell.
	self deny: (File exists: parmFileName).
	self setupToLogin.
	jadeiteShell debugPathPresenter: SessionManager current imagePath.
	self loginWithRetry: jadeiteShell.
	self assert: (File exists: parmFileName).
	[self assert: GciSession current isKindOf: GciSession] ensure: 
			[JadeiteTestResource current
				tearDown;
				setUp	"reset the tes resource's session, etc"]!

test_gemTask
	| formerGemTask jadeiteShell |
	self testsIssue: #issue416 withTitle: 'NetLDI task in login is not displayed correctly'.
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #no.	"don't commit"
	GciSession current ifNotNil: [:sess | sess logout].
	JadeiteLoginShell allInstances do: [:inst | inst view close].
	jadeiteShell := JadeiteLoginShell show position: 80 @ 20.
	jadeiteLogin := jadeiteShell model.
	formerGemTask := jadeiteLogin gemTask.
	self assert: formerGemTask equals: 'gemnetobject'.	"might need to change this assumption"
	jadeiteLogin gemTask: 'gemnetdebug'.
	jadeiteShell gemTaskPresenter: 'gemnetdebug'.	"update the gui"
	self loginWithRetry: jadeiteShell.	"have to login so new task is accepted"
	"somehow test that we are using gemnetdebug"
	TestMessageBox plannedResult: #no.
	GciSession current logout.
	JadeiteLoginShell allInstances do: [:inst | inst view close].	"should save to the remote JadeDefaultConnection.gss file"
	jadeiteShell := JadeiteLoginShell show.
	jadeiteLogin := jadeiteShell model.
	self assert: jadeiteLogin gemTask equals: 'gemnetdebug'.
	jadeiteLogin gemTask: 'gemnetobject'.
	jadeiteShell gemTaskPresenter: 'gemnetobject'.	"update the gui"
	self loginWithRetry: jadeiteShell.
	"somehow test that we are using gemnetobject"
	TestMessageBox plannedResult: #no.
	[GciSession current logout] ensure: [TestMessageBox disableJadeiteTestMessageBox].
	JadeiteLoginShell allInstances do: [:inst | inst view close].	"should save to the remote JadeDefaultConnection.gss file"
	jadeiteShell := JadeiteLoginShell show.
	jadeiteLogin := jadeiteShell model.
	self assert: jadeiteLogin gemTask equals: 'gemnetobject'.
	self loginWithRetry: jadeiteShell.
	[self assert: GciSession current isKindOf: GciSession] ensure: 
			[JadeiteTestResource current
				tearDown;
				setUp	"reset the tes resource's session, etc"]!

test_loginButtonEnablement
	| query buttonView transcript |
	self testsIssue: #issue527 withTitle: 'Multiple sessions can''t keep console project list straight'.
	self testsIssue: #issue635
		withTitle: '(3.0.87) Extra click after logout to reenable the login button'.
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #no.	"don't commit"
	[GciSession current ifNotNil: [:sess | sess logout]]
		ensure: [TestMessageBox disableJadeiteTestMessageBox].
	JadeiteLoginShell allInstances do: 
			[:inst |
			query := CommandQuery commandDescription: (CommandDescription command: #login)
						source: inst loginButtonPresenter view.
			inst queryCommand: query.
			self assert: query isEnabled.	"any login shell should have a disabled login button"
			inst view close].
	jadeiteShell := JadeiteLoginShell show position: 80 @ 20.
	jadeiteShell login.
	query := CommandQuery commandDescription: (CommandDescription command: #login)
				source: jadeiteShell view.
	jadeiteShell view queryCommand: query.
	self deny: query isEnabled.
	transcript := JadeiteTranscript allInstances
				detect: [:theTranscript | theTranscript gciSession == GciSession current].
	transcript view setFocus.
	transcript view close.
	
	[buttonView := jadeiteShell loginButtonPresenter view.
	query := CommandQuery commandDescription: buttonView commandDescription source: buttonView.
	jadeiteShell queryCommand: query.
	self assert: query isEnabled]
			ensure: [jadeiteShell login]!

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
!JadeiteLoginTestCase categoriesFor: #loginWithRetry:!private!support! !
!JadeiteLoginTestCase categoriesFor: #setUp!public!setup teardown! !
!JadeiteLoginTestCase categoriesFor: #setupToLogin!private!support! !
!JadeiteLoginTestCase categoriesFor: #tearDown!public!setup teardown! !
!JadeiteLoginTestCase categoriesFor: #test_debugLoginDumpsParameters!public!tests! !
!JadeiteLoginTestCase categoriesFor: #test_gemTask!public!tests! !
!JadeiteLoginTestCase categoriesFor: #test_loginButtonEnablement!public!tests! !
!JadeiteLoginTestCase categoriesFor: #test_simpleLogin!public!tests! !
!JadeiteLoginTestCase categoriesFor: #testsIssue:withTitle:!private! !

