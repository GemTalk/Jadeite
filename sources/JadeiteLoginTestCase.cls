"Filed out from Dolphin Smallalk"!

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

test_370Libraries
	self assert: LibGciRpc64_3_7 superclass equals: LibGciRpc64.
	self assert: LibGciRpc64_3_7 displayName equals: '64-bit 3.7.0'.
	self assert: (File exists: File workingDirectory , 'bin\' , LibGciRpc64_3_7 fileNameSearch)!

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
	"Dolphin runs tests at priority 6. Dolphin debugs tests at priority 5.  I hope there's a good reason for this. 
	If activeProcess priority = 5, the test can't close the window properly
	so the file write on close won't happen.  See JadeiteLoginShell>>onViewClosed.
	So we change the priority to 5"

	Processor activeProcess priority: 5.
	self testsIssue: #issue416 withTitle: 'NetLDI task in login is not displayed correctly'.
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #no.	"don't commit"
	GciSession current ifNotNil: [:sess | sess logout].
	JadeiteLoginShell allInstances do: 
			[:inst |
			inst model gemTask: 'gemnetobject'.
			inst model saveDefault.
			inst view close].	"set known value in file to start test"
	jadeiteLogin := nil.
	jadeiteShell := JadeiteLoginShell show position: 80 @ 20.
	jadeiteLogin := jadeiteShell model.
	self assert: jadeiteLogin gemTask equals: 'gemnetobject'.
	jadeiteLogin gemTask: 'gemnetdebug'.
	jadeiteShell gemTaskPresenter: 'gemnetdebug'.	"update the gui"
	jadeiteShell model saveDefault.
	self loginWithRetry: jadeiteShell.	"have to login so new task is accepted"
	"somehow test that we are using gemnetdebug"
	TestMessageBox plannedResult: #no.
	GciSession current logout.
	jadeiteShell view close.	"should save to the remote 'C:\Users\ewinger\AppData\Roaming\JadeDefaultConnection.gss' file"
	jadeiteShell := JadeiteLoginShell show.
	jadeiteLogin := jadeiteShell model.
	self assert: jadeiteLogin gemTask equals: 'gemnetdebug'.
	jadeiteLogin gemTask: 'gemnetobject'.
	jadeiteShell gemTaskPresenter: 'gemnetobject'.	"update the gui"
	jadeiteShell model saveDefault.
	self loginWithRetry: jadeiteShell.

	"somehow test that we are using gemnetobject"
	TestMessageBox plannedResult: #no.
	[GciSession current logout] ensure: [TestMessageBox disableJadeiteTestMessageBox].
	jadeiteShell view close.	"should save to the remote 'C:\Users\ewinger\AppData\Roaming\JadeDefaultConnection.gss' file"
	jadeiteShell := JadeiteLoginShell show.
	jadeiteLogin := jadeiteShell model.
	self assert: jadeiteLogin gemTask equals: 'gemnetobject'.
	jadeiteLogin saveDefault.
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

test_loginErrorMessages
	| userId stoneName password |
	self testsIssue: #issue858 withTitle: 'better gci error reporting is needed'.
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #no.
	self setupToLogin.
	userId := jadeiteShell userIDPresenter value.
	jadeiteShell userIDPresenter value: 'WrongUser'.
	[jadeiteShell login] ensure: 
			[TestMessageBox disableJadeiteTestMessageBox.
			jadeiteShell userIDPresenter value: userId].
	self assert: TestMessageBox lastMessageBox text
		equals: 'Login failed:  the userId/password combination is invalid or expired. An unknown GciLoginFailed has occurred'.
	password := jadeiteShell passwordPresenter value.
	jadeiteShell passwordPresenter value: 'xxxxxx'.
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #no.
	[jadeiteShell login] ensure: 
			[TestMessageBox disableJadeiteTestMessageBox.
			jadeiteShell passwordPresenter value: password].
	self assert: TestMessageBox lastMessageBox text
		equals: 'Login failed:  the userId/password combination is invalid or expired. An unknown GciLoginFailed has occurred'.
	stoneName := jadeiteShell stoneNamePresenter value.
	jadeiteShell stoneNamePresenter value: 'WrongStone'.
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #no.
	[jadeiteShell login] ensure: 
			[TestMessageBox disableJadeiteTestMessageBox.
			jadeiteShell stoneNamePresenter value: stoneName].
	self
		assert: ('The given Stone Repository monitor cannot be reached, could not find server ''WrongStone'' on host ''*'' because  service not found An unknown GciLoginFailed has occurred'
				match: TestMessageBox lastMessageBox text)!

test_loginShellPlaceholdersForAddedLibraries
	| loginShell previousPlaceHolders binDir fakeLib newPlaceHolders addedPlaceHolders fakeLibPath |
	loginShell := JadeiteLoginShell allInstances first.
	previousPlaceHolders := loginShell placeholdersForNewSharedLibraries.
	binDir := SessionManager current imageBase , 'bin\'.
	
	[fakeLibPath := binDir , '\libgcirpc-3.7.46-32.dll'.	"I hope we never actually release the 46th version of 3.7"
	fakeLib := File open: fakeLibPath mode: #create]
			ensure: [fakeLib close].
	
	[newPlaceHolders := loginShell placeholdersForNewSharedLibraries.
	self assert: newPlaceHolders size = (previousPlaceHolders size + 1).
	addedPlaceHolders := newPlaceHolders difference: previousPlaceHolders.
	self assert: addedPlaceHolders first fileNameSearch = 'libgcirpc-3.7.46-32.dll']
			ensure: [File delete: fakeLibPath]!

test_simpleLogin
	self denyIsNil: session.
	self assert: session isKindOf: GciSession. 
	self deny: session identicalTo: GciSession current.  
	self tearDown.
	self assertIsNil: session.
	session := nil!

testsIssue: aSymbol withTitle: anObject! !
!JadeiteLoginTestCase categoriesForMethods!
fail:!public! !
jadeLoginShell!private!setup teardown! !
login!private!setup teardown! !
loginWithRetry:!private!support! !
setUp!public!setup teardown! !
setupToLogin!private!support! !
tearDown!public!setup teardown! !
test_370Libraries!public!tests! !
test_debugLoginDumpsParameters!public!tests! !
test_gemTask!public!tests! !
test_loginButtonEnablement!public!tests! !
test_loginErrorMessages!public!tests! !
test_loginShellPlaceholdersForAddedLibraries!public!tests! !
test_simpleLogin!public!tests! !
testsIssue:withTitle:!private! !
!

