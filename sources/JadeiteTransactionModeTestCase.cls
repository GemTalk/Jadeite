"Filed out from Dolphin Smallalk"!

JadeiteAbstractTestCase subclass: #JadeiteTransactionModeTestCase
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteTransactionModeTestCase guid: (GUID fromString: '{b096accd-0515-40b1-8ef1-b3cdba201103}')!
JadeiteTransactionModeTestCase comment: ''!
!JadeiteTransactionModeTestCase categoriesForClass!Unclassified! !
!JadeiteTransactionModeTestCase methodsFor!

assertButton: aSymbol enabled: aBoolean
	| query |
	query := CommandQuery commandDescription: (CommandDescription command: aSymbol)
				source: transcript toolbarPresenter view.
	transcript toolbarPresenter queryCommand: query.
	aBoolean ifTrue: [self assert: query isEnabled] ifFalse: [self deny: query isEnabled]!

assertProjectBrowserAbortButtonEnabled
	| query |
	query := CommandQuery commandDescription: (CommandDescription command: #abortTransaction)
				source: projectsBrowser.
	projectsBrowser toolbarPresenter queryCommand: query.
	self assert: query isEnabled!

assertTranscriptAbortButtonEnabled
	self assertButton: #abort enabled: true!

assertTranscriptBeginButtonDisabled
	self assertButton: #begin enabled: false!

assertTranscriptBeginButtonEnabled
	self assertButton: #begin enabled: true!

assertTranscriptCommitButtonDisabled
	self assertButton: #commit enabled: false!

assertTranscriptCommitButtonEnabled
	self assertButton: #commit enabled: true!

setUp
	self switchTransactionModeTo: #autoBegin.	"start tests in a known transaction mode"
	user := 'SystemUser'.
	super setUp!

test_abortButtonAlwaysEnabled
	self testsIssue: #issue889 withTitle: 'Support transaction modes & SIGABORT handling'.
	self assert: transcript transactionMode equals: #autoBegin.	"should be the default mode for the test"
	self openProjectBrowser.
	
	[self switchTransactionModeTo: #manualBegin.
	self assert: transcript transactionMode equals: #manualBegin.
	self assertTranscriptAbortButtonEnabled.
	self assertProjectBrowserAbortButtonEnabled.
	self switchTransactionModeTo: #transactionless.
	self assert: transcript transactionMode equals: #transactionless.
	self assertTranscriptAbortButtonEnabled.
	self assertProjectBrowserAbortButtonEnabled.
	self switchTransactionModeTo: #autoBegin.
	self assert: transcript transactionMode equals: #autoBegin.
	self assertTranscriptAbortButtonEnabled.
	self assertProjectBrowserAbortButtonEnabled]
			ensure: 
				[transcript transactionMode == #autoBegin ifFalse: [self switchTransactionModeTo: #autoBegin].
				projectsBrowser view close.
				self cloneRowanSample1.
				self ensureRowanSampleProjectsLoaded	"this is needed because changing transaction mode does an abort"]!

test_beginTransactionEnablement
	self testsIssue: #issue889 withTitle: 'Support transaction modes & SIGABORT handling'.
	self assert: transcript transactionMode equals: #autoBegin.	"should be the default mode for the test"
	
	[self switchTransactionModeTo: #manualBegin.
	self assertTranscriptBeginButtonEnabled.
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #yes.
	[transcript beginTransaction] ensure: [TestMessageBox disableJadeiteTestMessageBox].
	self assertTranscriptBeginButtonDisabled.
	self assertTranscriptCommitButtonEnabled.
	self abortTransaction.
	self assertTranscriptBeginButtonEnabled.
	self assertTranscriptCommitButtonDisabled.
	self switchTransactionModeTo: #transactionless.
	self assertTranscriptBeginButtonDisabled.
	self abortTransaction.
	self assertTranscriptBeginButtonDisabled.
	self switchTransactionModeTo: #autoBegin.
	self assertTranscriptBeginButtonDisabled.
	self abortTransaction.
	self assertTranscriptBeginButtonDisabled]
			ensure: 
				[transcript transactionMode == #autoBegin ifFalse: [self switchTransactionModeTo: #autoBegin].
				self cloneRowanSample1.
				self ensureRowanSampleProjectsLoaded	"this is needed because changing transaction mode does an abort"]!

test_changeTransactionModeWithFailedCommit
	self testsIssue: #issue889 withTitle: 'Support transaction modes & SIGABORT handling'.
	self assert: transcript transactionMode equals: #autoBegin.	"should be the default mode for the test"
	session executeString: 'UserGlobals at: #autoCommitTest put: (#key -> #value)'.
	self commitTransaction.
	self loginOtherSession.
	self openProjectBrowser.
	self projectsPresenter remoteAutoCommit ifFalse: [self projectsPresenter flipAutoCommit].
	self assert: self projectsPresenter remoteAutoCommit.
	
	[self
		executeStringInOtherSession: 'abort;
			executeString: ''(UserGlobals at: #autoCommitTest) value: #newValue'';
			commit'.
	self selectRowanSample1Test.
	self selectMethodNamed: #test1.
	self
		saveMethod: 'test1 ^123'
		in: 'RowanSample1Test'
		category: 'tests'.
	session executeString: '(UserGlobals at: #autoCommitTest) value: #stillAnotherNewValue'.	"This will setup the auto commit failure"
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #no.
	self switchTransactionModeTo: #manualBegin	"With auto commit on, get a failure and lose the changes but no bad things will happen"]
			ensure: 
				[TestMessageBox disableJadeiteTestMessageBox.
				self logoutOtherSession.
				self abortTransaction.
				session executeString: 'UserGlobals removeKey: #autoCommitTest'.
				transcript transactionMode == #autoBegin ifFalse: [self switchTransactionModeTo: #autoBegin].
				RowanAnsweringService new setAutoCommit: false for: session.
				self commitTransaction.
				projectsBrowser view close.
				self cloneRowanSample1.
				self ensureRowanSampleProjectsLoaded	"this is needed because changing transaction mode does an abort"]!

test_setTransactionlessMode
	| previousTransactionMode |
	self testsIssue: #issue889 withTitle: 'Support transaction modes & SIGABORT handling'.
	previousTransactionMode := transcript transactionMode.
	self assert: (session executeString: 'System transactionMode') equals: previousTransactionMode.
	
	[transcript basicTransactionMode: #transactionless.	"this will cause an abort requiring a clone/reload of RowanSample1 later"
	self assert: (session executeString: 'System transactionMode') equals: #transactionless]
			ensure: 
				[transcript basicTransactionMode: previousTransactionMode.
				self assert: (session executeString: 'System transactionMode') equals: previousTransactionMode.
				self cloneRowanSample1.
				self ensureRowanSampleProjectsLoaded]!

test_setTransactionModeChangesServer
	| previousTransactionMode |
	self testsIssue: #issue889 withTitle: 'Support transaction modes & SIGABORT handling'.
	previousTransactionMode := transcript transactionMode.
	self assert: (session executeString: 'System transactionMode') equals: previousTransactionMode.
	
	[transcript basicTransactionMode: #manualBegin.	"this will cause an abort requiring a clone/reload of RowanSample1 later"
	self assert: (session executeString: 'System transactionMode') equals: #manualBegin]
			ensure: 
				[transcript basicTransactionMode: previousTransactionMode.
				self assert: (session executeString: 'System transactionMode') equals: previousTransactionMode.
				self cloneRowanSample1.
				self ensureRowanSampleProjectsLoaded]!

test_transactionModeDefault
	| prefsExist |
	self testsIssue: #issue889 withTitle: 'Support transaction modes & SIGABORT handling'.
	prefsExist := self removePreferencesFile.
	[self logoutThenLoginAs: 'SystemUser'.	"ensure we have reset the transaction mode on the login to auto"
	self assert: transcript transactionMode equals: #autoBegin]
			ensure: [self restoreBackupPrefsFile: prefsExist]!

test_transactionModeLogoffRestoresDefaultSettings
	"logging off should reset the transaction mode settings"

	| prefsExist |
	self testsIssue: #issue889 withTitle: 'Support transaction modes & SIGABORT handling'.
	prefsExist := self removePreferencesFile.	"don't let preferences muck up the test"
	JadePresenter
		sigAbortProcessInterval: JadePresenter defaultSigAbortProcessInterval + 50;
		sigAbortsProcessEnabled: false;
		transactionMode: #transactionless session: session.
	self assert: JadePresenter sigAbortProcessInterval equals: JadePresenter defaultSigAbortProcessInterval + 50.
	self assert: JadePresenter sigAbortsProcessEnabled equals: false.
	self assert: JadePresenter transactionMode equals: #transactionless.
	
	[self logoutThenLoginAs: 'SystemUser'.	"ensure we have reset the transaction mode on the login to auto"
	self assert: JadePresenter sigAbortProcessInterval
		equals: JadePresenter defaultSigAbortProcessInterval.
	self assert: JadePresenter sigAbortsProcessEnabled equals: true.
	self assert: JadePresenter transactionMode equals: #autoBegin]
			ensure: [self restoreBackupPrefsFile: prefsExist]!

test_transactionModeManualTurnsOnSigAbortListener
	| previousTransactionMode sigAbortListener count |
	self testsIssue: #issue889 withTitle: 'Support transaction modes & SIGABORT handling'.
	previousTransactionMode := transcript transactionMode.
	
	[transcript basicTransactionMode: #manualBegin.	"changing transaction modes will cause an abort requiring a clone/reload of RowanSample1 later"
	sigAbortListener := JadePresenter sigAbortsProcess.
	self denyIsNil: sigAbortListener.
	transcript basicTransactionMode: #autoBegin.
	count := 0.
	[sigAbortListener isDead or: [count > 100]] whileFalse: 
			[count := count + 1.
			(Delay forMilliseconds: 10) wait	"might take a sec to terminate"].
	self assert: sigAbortListener isDead.
	self assertIsNil: JadePresenter sigAbortsProcess.
	transcript basicTransactionMode: #transactionless.
	self denyIsNil: JadePresenter sigAbortsProcess]
			ensure: 
				[transcript basicTransactionMode: previousTransactionMode.
				self assert: (session executeString: 'System transactionMode') equals: previousTransactionMode.
				self cloneRowanSample1.
				self ensureRowanSampleProjectsLoaded]!

test_transactionModeSigAbortsListener
	| previousTransactionMode previousSigAbortProcessInterval count secondSession |
	self testsIssue: #issue889 withTitle: 'Support transaction modes & SIGABORT handling'.
	[self nonSystemSessionCount = 1] whileFalse: 
			[self stopOtherSessions.
			(Delay forMilliseconds: 10) wait].
	self assert: self nonSystemSessionCount equals: 1.
	previousTransactionMode := transcript transactionMode.
	previousSigAbortProcessInterval := JadePresenter sigAbortProcessInterval.
	JadePresenter sigAbortProcessInterval: 1.
	
	[secondSession := JadeLogin allInstances first login.	"should always be only one ... I hope"
	self assert: secondSession ~~ session.
	transcript basicTransactionMode: #manualBegin.	"this will abort the current session and turn on the listener process"
	self deny: JadePresenter inTransaction.
	self deny: (session executeString: 'System inTransaction').
	session executeString: 'UserGlobals at: #willBeRemovedOnAbort put: 1'.
	count := 0.
	[count < 750] whileTrue: 
			[secondSession
				executeString: 'UserGlobals at: #ulp put: ((1 to: 50) collect:[:ea | Object new]). System commit'.
			(Delay forMilliseconds: 20) wait.
			count := count + 1].
	count := 0.
	[count > 2000] whileFalse: 
			[count := count + 1.
			(Delay forMilliseconds: 10) wait].
	self assertIsNil: (session executeString: 'UserGlobals at: #willBeRemovedOnAbort ifAbsent:[]').
	self deny: transcript lastKnownTransaction equals: transcript lastKnownTransaction value]
			ensure: 
				[secondSession _library ifNotNil: [:lib | lib logoutSession: secondSession gciSessionId].
				secondSession
					gciSessionId: nil;
					library: nil.	"logout without triggering events"
				GciSession current: session.	"Jadeite isn't really setup for two sessions. Make sure our global session is the right one"
				transcript basicTransactionMode: previousTransactionMode.
				JadePresenter sigAbortProcessInterval: previousSigAbortProcessInterval.
				self assert: (session executeString: 'System transactionMode') equals: previousTransactionMode.
				self cloneRowanSample1.
				self ensureRowanSampleProjectsLoaded]! !
!JadeiteTransactionModeTestCase categoriesForMethods!
assertButton:enabled:!private!support!tests! !
assertProjectBrowserAbortButtonEnabled!private!support!tests! !
assertTranscriptAbortButtonEnabled!private!support!tests! !
assertTranscriptBeginButtonDisabled!private!support!tests! !
assertTranscriptBeginButtonEnabled!private!support!tests! !
assertTranscriptCommitButtonDisabled!private!support!tests! !
assertTranscriptCommitButtonEnabled!private!support!tests! !
setUp!public!support! !
test_abortButtonAlwaysEnabled!public!tests! !
test_beginTransactionEnablement!public!tests! !
test_changeTransactionModeWithFailedCommit!public!tests! !
test_setTransactionlessMode!public!tests! !
test_setTransactionModeChangesServer!public!tests! !
test_transactionModeDefault!public!tests! !
test_transactionModeLogoffRestoresDefaultSettings!public!tests! !
test_transactionModeManualTurnsOnSigAbortListener!public!tests! !
test_transactionModeSigAbortsListener!public! !
!

