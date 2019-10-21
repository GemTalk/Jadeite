"Filed out from Dolphin Smalltalk 7"!

JadeiteAbstractTestCase subclass: #JadeiteTranscriptTestCase
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteTranscriptTestCase guid: (GUID fromString: '{5527e061-53db-41d8-b3ef-bea5af13e6aa}')!
JadeiteTranscriptTestCase comment: ''!
!JadeiteTranscriptTestCase categoriesForClass!Unclassified! !
!JadeiteTranscriptTestCase methodsFor!

allTranscriptPresenters
	" presenters that may care about menu enablement" 
	| presenters |
	presenters := OrderedCollection new.
	presenters add: transcript.
	presenters add: transcript allSessionsPresenter.
	presenters add: transcript mySessionPresenter.
	presenters add: transcript stoneInfoPresenter.
	presenters add: transcript transcriptPresenter.
	presenters add: transcript projectListPresenter.
	^presenters!

browseMenu
	^transcript view menuBar items detect: [:menu | '*Browse*' match: menu text] ifNone: []!

menuItemIsEnabledInAllPresenters: aSymbol
	| commandQuery |
	self allTranscriptPresenters do: 
			[:presenter |
			commandQuery := self
						queryCommand: aSymbol
						inPresenter: presenter
						view: presenter view.
			self assert: commandQuery isEnabled]!

restoreBackupPrefsFile: prefsExisted
	| backupStream fileStream backupPath |
	prefsExisted
		ifFalse: 
			[(File open: File workingDirectory , 'Jadeite.prefs')
				close;
				delete].
	backupPath := File workingDirectory , 'Jadeite.prefs.testbkp'.
	(File exists: backupPath) ifFalse: [^self].
	backupStream := FileStream read: File workingDirectory , 'Jadeite.prefs.testbkp'.
	fileStream := FileStream write: File workingDirectory , 'Jadeite.prefs'.
	[fileStream nextPutAll: backupStream contents] ensure: 
			[backupStream close.
			(File open: backupPath) delete.
			fileStream close]!

savePrefsBackup
	| backupStream fileStream |
	backupStream := FileStream write: File workingDirectory , 'Jadeite.prefs.testbkp'.
	fileStream := FileStream read: File workingDirectory , 'Jadeite.prefs'.
	[backupStream nextPutAll: fileStream contents] ensure: 
			[backupStream close.
			fileStream close]!

test_abortRemovesProjectsInAllBrowsers
	| sunitBrowser |
	projectsBrowser := self openWindow: [JadeiteBrowser showOnSession: session].
	sunitBrowser := self openWindow: [transcript jadeBrowseTests].
	
	[self denyIsNil: (self projectListPresenter list
				detect: [:projectService | projectService name = 'RowanSample1']
				ifNone: []).
	self denyIsNil: (transcript projectListPresenter projectListPresenter list
				detect: [:projectService1 | projectService1 name = 'RowanSample1']
				ifNone: []).
	self denyIsNil: (sunitBrowser primaryPresenter packageListPresenter list
				detect: [:projectService1 | projectService1 name = 'RowanSample1-Tests']
				ifNone: []).
	transcript toolbarPresenter abort.
	self assertIsNil: (self projectListPresenter list
				detect: [:projectService | projectService name = 'RowanSample1']
				ifNone: []).
	self assertIsNil: (transcript projectListPresenter projectListPresenter list
				detect: [:projectService2 | projectService2 name = 'RowanSample1']
				ifNone: []).
	self assertIsNil: (sunitBrowser primaryPresenter packageListPresenter list
				detect: [:projectService1 | projectService1 name = 'RowanSample1-Tests']
				ifNone: []).
	self cloneRowanSample1.
	self ensureRowanSample1Loaded]
			ensure: 
				[SessionManager inputState pumpMessages.
				self destroy: projectsBrowser.
				self destroy: sunitBrowser]!

test_abortTransaction
	self testsIssue: #issue383 withTitle: '(3.0.53) the commit button on the SUnit browser is silent'.
	transcript projectListPresenter refresh.
	self assertProjectInList: 'RowanSample1'.
	transcript toolbarPresenter abort.
	self denyProjectInList: 'RowanSample1'.
	self cloneRowanSample1.
	self ensureRowanSample1Loaded!

test_autoCommitOff
	| answeringService |
	self testsIssue: #issue396 withTitle: 'Ability to turn on autocommit would be nice'.
	self setAutoCommit: false.
	session executeString: 'UserGlobals at: #TestCommit put: true'.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self abortTransaction.
	self assertIsNil: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	"any service call will commit the transaction"
	session executeString: 'UserGlobals at: #TestCommit put: true'.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	answeringService := RowanAnsweringService new.
	answeringService
		command: #exec:;
		commandArgs: (Array with: '3+4').
	self issueCommand: answeringService.
	self assert: answeringService answer equals: '7'.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self abortTransaction.
	
	[self assertIsNil: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]')	"autoCommit off. TestCommit was not committed"]
			ensure: 
				[self cloneRowanSample1.
				self ensureRowanSample1Loaded]!

test_autoCommitOn
	| answeringService |
	self testsIssue: #issue396 withTitle: 'Ability to turn on autocommit would be nice'.
	
	[self setAutoCommit: true.
	session executeString: 'UserGlobals at: #TestCommit put: true'.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self abortTransaction.
	self assertIsNil: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	"any service call will commit the transaction"
	session executeString: 'UserGlobals at: #TestCommit put: true'.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	answeringService := RowanAnsweringService new.
	answeringService
		command: #exec:;
		commandArgs: (Array with: '3+4').
	self issueCommand: answeringService.
	self assert: answeringService answer equals: '7'.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]').
	self abortTransaction.
	self assert: (session executeString: 'UserGlobals at: #TestCommit ifAbsent:[]')	"TestCommit was committed"]
			ensure: 
				[session executeString: 'UserGlobals removeKey: #TestCommit'.
				self commitTransaction.
				self setAutoCommit: false]!

test_autoCommitSet
	self testsIssue: #issue396 withTitle: 'Ability to turn on autocommit would be nice'.
	self setAutoCommit: false.
	self assert: (session executeString: 'SessionTemps current at: #''Jadeite_AutoCommit''')
		equals: false.
	self setAutoCommit: true.
	
	[self assert: (session executeString: 'SessionTemps current at: #''Jadeite_AutoCommit''')
		equals: true]
			ensure: [transcript autoCommit: false]!

test_autoCompletionMenuItem
	| autoCompletion jadeiteMenu autoCompleteMenuItem commandQuery |
	self testsIssue: #issue524 withTitle: 'autocompletion'.
	autoCompletion := JadeiteSearch autoCompleteEnabled.
	
	[jadeiteMenu := transcript view menuBar items detect: [:menu | '*Jadeite*' match: menu text]
				ifNone: [].
	self denyIsNil: jadeiteMenu.
	autoCompleteMenuItem := jadeiteMenu items
				detect: [:command | '*Autocomplete enabled*' match: command text]
				ifNone: [].
	commandQuery := CommandQuery commandDescription: autoCompleteMenuItem commandDescription
				source: transcript projectListPresenter view.
	transcript autoCompleteEnabled: true.
	transcript queryCommand: commandQuery.
	self assert: commandQuery isChecked.
	transcript autoCompleteEnabled: false.
	transcript queryCommand: commandQuery.
	self deny: commandQuery isChecked]
			ensure: [transcript autoCompleteEnabled: autoCompletion]!

test_browseClassMenuItem
	| browseMenu browseClassItem |
	self testsIssue: #issue235 withTitle: 'Need Find Class/Method from console'.
	browseMenu := transcript view menuBar items detect: [:menu | '*Browse*' match: menu text] ifNone: [].
	self denyIsNil: browseMenu.
	browseClassItem := browseMenu items detect: [:command | '*Find*Class*' match: command text]
				ifNone: [].
	self denyIsNil: browseClassItem.
	self assert: browseClassItem command equals: #browseClass.
	self assert: (transcript class canUnderstand: #browseClass)!

test_browseClassReferencesMenuItem
	| browseMenu browseClassReferencesItem |
	self testsIssue: #issue300
		withTitle: '`would be nice to have `browse references to class` here as well'.
	browseMenu := transcript view menuBar items detect: [:menu | '*Browse*' match: menu text] ifNone: [].
	self denyIsNil: browseMenu.
	browseClassReferencesItem := browseMenu items
				detect: [:command | '*Browse*Class*References*' match: command text]
				ifNone: [].
	self denyIsNil: browseClassReferencesItem.
	self assert: browseClassReferencesItem command equals: #browseClassReferences.
	self assert: (transcript class canUnderstand: #browseClassReferences)!

test_browseClassReferencesMenuItemIsEnabled
	"these presenters either inherit from JadePresenter or
	(somehow) test the menu enablement through JadeTranscript"

	| commandQuery presenters |
	self testsIssue: #issue300
		withTitle: '`would be nice to have `browse references to class` here as well'.
	presenters := OrderedCollection new.
	presenters add: transcript.
	presenters add: transcript allSessionsPresenter.
	presenters add: transcript mySessionPresenter.
	presenters add: transcript stoneInfoPresenter.
	presenters add: transcript transcriptPresenter.
	presenters do: 
			[:presenter |
			commandQuery := self
						queryCommand: #browseClassReferences
						inPresenter: presenter
						view: presenter view.
			self assert: commandQuery isEnabled]!

test_browseFindClassMenuItem
	| browseMenu findClassMenuItem |
	self testsIssue: #issue235 withTitle: 'Need Find Class/Method from console'.
	browseMenu := transcript view menuBar items detect: [:menu | '*Browse*' match: menu text] ifNone: [].
	self denyIsNil: browseMenu.
	findClassMenuItem := browseMenu items detect: [:command | '*Find*Class*' match: command text]
				ifNone: [].
	self denyIsNil: findClassMenuItem.
	self assert: findClassMenuItem command equals: #browseClass.
	self assert: (transcript class canUnderstand: #browseClass)!

test_browseImplementors
	| methodListBrowser methodList |
	self testsIssue: #issue235 withTitle: 'Need Find Class/Method from console'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[TestPrompter plannedResult: 'size'.
	methodListBrowser := transcript browseImplementorsOf.
	methodList := methodListBrowser primaryPresenter methodListPresenter methodListPresenter list.
	self assert: methodList notEmpty.
	self assert: ('Implementors of ''size'' for*' match: methodListBrowser caption)]
			ensure: 
				[TestMessageBox disableJadeiteTestMessageBox.
				self destroy: methodListBrowser]!

test_browseImplementorsMenuItem
	| browseMenu browseImplementorsItem |
	self testsIssue: #issue251 withTitle: '`Browse Methods Containing` available from Console menu'.
	browseMenu := transcript view menuBar items detect: [:menu | '*Browse*' match: menu text] ifNone: [].
	self denyIsNil: browseMenu.
	browseImplementorsItem := browseMenu items
				detect: [:command | '*Browse*Implementors*' match: command text]
				ifNone: [].
	self denyIsNil: browseImplementorsItem.
	self assert: browseImplementorsItem command equals: #browseImplementorsOf.
	self assert: (transcript class canUnderstand: #browseMethodsContaining)!

test_browseLiteralsReferencesMenuItem
	| browseMenu browseLiteralReferencesItem |
	self testsIssue: #issue251 withTitle: '`Browse Methods Containing` available from Console menu'.
	browseMenu := transcript view menuBar items detect: [:menu | '*Browse*' match: menu text] ifNone: [].
	self denyIsNil: browseMenu.
	browseLiteralReferencesItem := browseMenu items
				detect: [:command | '*Browse*Literal*References*' match: command text]
				ifNone: [].
	self denyIsNil: browseLiteralReferencesItem.
	self assert: browseLiteralReferencesItem command equals: #browseLiteralReferences.
	self assert: (transcript class canUnderstand: #browseLiteralReferences)!

test_browseMethodsContainingMenuItem
	| browseMenu browseMethodsContainingItem |
	self testsIssue: #issue251 withTitle: '`Browse Methods Containing` available from Console menu'.
	browseMenu := transcript view menuBar items detect: [:menu | '*Browse*' match: menu text] ifNone: [].
	self denyIsNil: browseMenu.
	browseMethodsContainingItem := browseMenu items
				detect: [:command | '*Browse*Methods*Containing*' match: command text]
				ifNone: [].
	self denyIsNil: browseMethodsContainingItem.
	self assert: browseMethodsContainingItem command equals: #browseMethodsContaining.
	self assert: (transcript class canUnderstand: #browseMethodsContaining)!

test_browseProjectsMenuItem
	| browseMenu browseProjectsMenuItem |
	self testsIssue: #issue235 withTitle: 'Need Find Class/Method from console'.
	browseMenu := transcript view menuBar items detect: [:menu | '*Browse*' match: menu text] ifNone: [].
	self denyIsNil: browseMenu.
	browseProjectsMenuItem := browseMenu items
				detect: [:command | '*Browse*Projects*' match: command text]
				ifNone: [].
	self denyIsNil: browseProjectsMenuItem.
	self assert: browseProjectsMenuItem command equals: #openJadeiteProjectsBrowser.
	self assert: (transcript class canUnderstand: #openJadeiteProjectsBrowser)!

test_browseSenders
	| methodListBrowser methodList |
	self testsIssue: #issue235 withTitle: 'Need Find Class/Method from console'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[TestPrompter plannedResult: 'abort'.
	methodListBrowser := transcript browseSendersOf.
	methodList := methodListBrowser primaryPresenter methodListPresenter methodListPresenter list.
	self assert: methodList notEmpty.
	self assert: ('Senders of ''abort'' for*' match: methodListBrowser caption)]
			ensure: 
				[TestMessageBox disableJadeiteTestMessageBox.
				self destroy: methodListBrowser]!

test_browseSendersMenuItem
	| browseMenu browseSendersItem |
	self testsIssue: #issue235 withTitle: 'Need Find Class/Method from console'.
	browseMenu := transcript view menuBar items detect: [:menu | '*Browse*' match: menu text] ifNone: [].
	self denyIsNil: browseMenu.
	browseSendersItem := browseMenu items detect: [:command | '*Browse*Senders*' match: command text]
				ifNone: [].
	self denyIsNil: browseSendersItem.
	self assert: browseSendersItem command equals: #browseSendersOf.
	self assert: (transcript class canUnderstand: #browseSendersOf)!

test_closeConsoleNeedingCommit
	"expect dialog asking for commit"

	self testsIssue: #issue267 withTitle: 'logout closes project browsers but not method list browsers'.
	self cleanupExistingWindows.
	session executeString: 'UserGlobals at: #test_closeConsoleNeedingCommit put: 123'.	"we now need a commit"
	
	[TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #yes.	"commit"
	[[transcript view close] ensure: [TestMessageBox disableJadeiteTestMessageBox]] ensure: 
			[self loginWithRetry: JadeiteLoginShell allInstances first.
			self resources do: 
					[:resource |
					resource current
						tearDown;
						setUp.
					self setUp]].
	self
		denyIsNil: (session executeString: 'UserGlobals at: #test_closeConsoleNeedingCommit ifAbsent:[]').
	self assert: (session executeString: 'UserGlobals at: #test_closeConsoleNeedingCommit') equals: 123]
			ensure: 
				[session executeString: 'UserGlobals removeKey: #test_closeConsoleNeedingCommit'.
				self commitTransaction]!

test_closeConsoleNoCommitNeeded
	"expect dialog asking for commit"

	self testsIssue: #issue267 withTitle: 'logout closes project browsers but not method list browsers'.
	self cleanupExistingWindows.
	self abortTransaction.
	self deny: (session executeString: 'System needsCommit').
	[transcript view close	"no dialog appears. test would hang otherwise"] ensure: 
			[self loginWithRetry: JadeiteLoginShell allInstances first.
			self resources do: 
					[:resource |
					resource current
						tearDown;
						setUp]]!

test_commitTransaction
	self testsIssue: #issue383 withTitle: '(3.0.53) the commit button on the SUnit browser is silent'.
	self cloneRowanSample1.
	self ensureRowanSample1Loaded.
	transcript projectListPresenter refresh.
	self assertProjectInList: 'RowanSample1'.
	transcript toolbarPresenter commit.
	self assertProjectInList: 'RowanSample1'.
	transcript toolbarPresenter abort.
	self assertProjectInList: 'RowanSample1'.
	self unloadSampleProject.
	transcript toolbarPresenter commit. 
	self denyProjectInList: 'RowanSample1'.
	self cloneRowanSample1.
	self ensureRowanSample1Loaded.!

test_doubleClickOpenProjectBrowser
	| randomIndex projectPresenter projectName |
	randomIndex := (Random new next * 4) ceiling.
	transcript projectListPresenter projectListPresenter selectionByIndex: randomIndex.
	projectName := transcript projectListPresenter projectListPresenter selection name.
	projectPresenter := transcript projectListPresenter projectListPresenter trigger: #actionPerformed.	"simulates double click"
	[self assert: projectPresenter projectListPresenter selection name equals: projectName]
		ensure: [projectPresenter topShell view close]!

test_flipBreakPointsDisabled
	| breakPointsEnabled |
	self testsIssue: #issue515 withTitle: '(3.0.77) clear all breakpoints menu item would be useful'.
	
	[breakPointsEnabled := transcript areBreakpointsEnabled value.
	transcript flipBreakpointsEnabled.
	self assert: transcript areBreakpointsEnabled value equals: breakPointsEnabled not.
	self assert: (session executeString: 'SessionTemps current at: #Jadeite_BreakPointsAreEnabled')
		equals: breakPointsEnabled not.
	transcript flipBreakpointsEnabled.
	self assert: transcript areBreakpointsEnabled value equals: breakPointsEnabled.
	self assert: (session executeString: 'SessionTemps current at: #Jadeite_BreakPointsAreEnabled')
		equals: breakPointsEnabled]
			ensure: [transcript areBreakpointsEnabled value: breakPointsEnabled]!

test_implementorsSenders_SearchList
	"searches starting with _" 
	| selection |
	self testsIssue: #issue581
		withTitle: '(3.0.81) Implementors Of.../Senders Of... doesn''t show selection list'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[TestPrompter plannedResult: '_*'.
	TestChoicePrompter plannedResult: #subclasses.
	selection := JadePresenter
				promptForMatchingSymbolsIn: session
				actionBlock: [:sel | sel]
				promptCaption: 'Test search selectors:'
				searchType: 'prompt:'.
	self assert: selection equals: #subclasses.
	"the code above doesn't really test that our list is populated. Hence the assertions below.
	JadeiteSearch is referenced from #promptFor*"
	(JadeiteSearch symbolsFrom: ('_*' copyWithout: $*) session: session)
		do: [:string | self assert: (string beginsWith: '_')].
	self
		denyIsNil: ((JadeiteTranscriptTestCase methodDictionary at: #test_implementorsSendersSearchList)
				literalsDetect: [:literal | (literal isKindOf: Association) and: [literal value = JadeiteSearch]]
				ifNone: [])]
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

test_implementorsSendersSearchList
	| selection |
	self testsIssue: #issue581
		withTitle: '(3.0.81) Implementors Of.../Senders Of... doesn''t show selection list'.
	TestMessageBox enableJadeiteTestMessageBox.
	
	[TestPrompter plannedResult: 'sub*'.
	TestChoicePrompter plannedResult: #subclasses.
	selection := JadePresenter
				promptForMatchingSymbolsIn: session
				actionBlock: [:sel | sel]
				promptCaption: 'Test search selectors:'
				searchType: 'prompt:'.
	self assert: selection equals: #subclasses.
	"the code above doesn't really test that our list is populated. Hence the assertions below.
	JadeiteSearch is referenced from #promptFor*"
	(JadeiteSearch symbolsFrom: ('sub*' copyWithout: $*) session: session)
		do: [:string | self assert: (string beginsWith: 'sub')].
	self
		denyIsNil: ((JadeiteTranscriptTestCase methodDictionary at: #test_implementorsSendersSearchList)
				literalsDetect: [:literal | (literal isKindOf: Association) and: [literal value = JadeiteSearch]]
				ifNone: [])]
			ensure: [TestMessageBox disableJadeiteTestMessageBox]!

test_jadeiteMenuAdHocExecutionItems
	| editMenu debugMenuItem executeMenuItem inspectMenuItem displayMenuItem |
	self testsIssue: #issue474 withTitle: '(3.0.69) inconsistent debug menu on workspaces'.
	editMenu := transcript view menuBar items detect: [:menu | '*Edit*' match: menu text] ifNone: [].
	self denyIsNil: editMenu.
	debugMenuItem := editMenu items detect: [:command | '*Debug*' match: command text] ifNone: [].
	self denyIsNil: debugMenuItem.
	self assert: debugMenuItem command equals: #jadeDebug.
	self assert: (transcript class canUnderstand: #jadeDebug).
	self assert: debugMenuItem commandDescription acceleratorKey = 4674.	"Ctrl-B"
	executeMenuItem := editMenu items detect: [:command | '*Execute*' match: command text] ifNone: [].
	self denyIsNil: executeMenuItem.
	self assert: executeMenuItem command equals: #jadeExecute.
	self assert: (transcript class canUnderstand: #jadeExecute).
	self assert: executeMenuItem commandDescription acceleratorKey = 4677.	"Ctrl-E"
	inspectMenuItem := editMenu items detect: [:command | '*Inspect*' match: command text] ifNone: [].
	self denyIsNil: inspectMenuItem.
	self assert: inspectMenuItem command equals: #jadeInspect.
	self assert: (transcript class canUnderstand: #jadeInspect).
	self assert: inspectMenuItem commandDescription acceleratorKey = 4689.	"Ctrl-Q"
	displayMenuItem := editMenu items detect: [:command | '*Display*' match: command text] ifNone: [].
	self denyIsNil: displayMenuItem.
	self assert: displayMenuItem command equals: #jadeDisplay.
	self assert: (transcript class canUnderstand: #jadeDisplay).
	self assert: displayMenuItem commandDescription acceleratorKey = 4676	"Ctrl-D"!

test_menuBarBrowseProjectsHonorsSelection
	| randomIndex projectPresenter projectName browseMenu browseProjectsMenuItem projectsPresenter |
	randomIndex := (Random new next * 4) ceiling.
	transcript projectListPresenter projectListPresenter selectionByIndex: randomIndex.
	projectName := transcript projectListPresenter projectListPresenter selection name.
	browseMenu := transcript view menuBar items detect: [:menu | '*Browse*' match: menu text] ifNone: [].
	browseProjectsMenuItem := browseMenu items
				detect: [:command | '*Browse*Projects*' match: command text]
				ifNone: [].
	self assert: browseProjectsMenuItem command equals: #openJadeiteProjectsBrowser.
	projectsPresenter := transcript openJadeiteProjectsBrowser.
	[self assert: projectsPresenter projectListPresenter selection name equals: projectName]
		ensure: [projectsPresenter topShell view close].
	transcript projectListPresenter projectListPresenter selectionByIndex: 0.
	projectsPresenter := transcript openJadeiteProjectsBrowser currentCard.
	[self assertIsNil: (projectsPresenter projectListPresenter selectionIfNone: [])]
		ensure: [projectsPresenter topShell view close]!

test_menuNames
	| commitMenuItem checkoutMenuItem contextMenu |
	self testsIssue: #issue342 withTitle: 'Console menu items not matching projects browser'.
	contextMenu := transcript projectListPresenter projectListPresenter view queryContextMenu.
	commitMenuItem := contextMenu items detect: [:menu | 'Commit to Git ...' = menu text] ifNone: [].
	self denyIsNil: commitMenuItem.
	self assert: commitMenuItem command equals: #gitCommit.
	self assert: (transcript projectListPresenter class canUnderstand: #gitCommit).
	checkoutMenuItem := contextMenu items detect: [:menu | 'Checkout Git Branch ...' = menu text]
				ifNone: [].
	self denyIsNil: checkoutMenuItem.
	self assert: checkoutMenuItem command equals: #checkout.
	self assert: (transcript projectListPresenter class canUnderstand: #checkout)!

test_multiSelectProject
	| projectServices projectCount |
	self testsIssue: #issue163
		withTitle: 'Project list in transcript/console should be multi-select for multi-load'.
	projectServices := transcript projectListPresenter projectListPresenter list.
	projectCount := projectServices size.
	transcript projectListPresenter projectListPresenter selections: projectServices.
	self assert: transcript projectListPresenter projectListPresenter selections size equals: projectCount!

test_openChangesBrowser
	| changesBrowser changesItem projectService |
	self testsIssue: #issue384
		withTitle: '(3.0.53) sort by `type` in changes view does not do complete job'.
	projectService := transcript projectListPresenter projectListPresenter list first.
	transcript projectListPresenter projectListPresenter selection: projectService.
	changesItem := transcript projectListPresenter projectListPresenter view queryContextMenu items
				detect: [:menuItem | menuItem command == #projectChanges].
	changesBrowser := changesItem commandDescription performAgainst: transcript projectListPresenter.
	[self assert: (changesBrowser isKindOf: RowanPatchBrowser)] ensure: [self destroy: changesBrowser]!

test_openPreferencesFile
	| prefsWorkspace prefsItem |
	self testsIssue: #issue522 withTitle: 'hook to open desired set of windows at startup'.
	prefsItem := self browseMenu items detect: [:menuItem | menuItem command == #browseJadeitePrefs].
	prefsWorkspace := prefsItem commandDescription performAgainst: transcript.
	[self assert: (prefsWorkspace isKindOf: JadeWorkspace)] ensure: [prefsWorkspace view close]
!

test_openPreferencesFileCreatePrefsFile
	| prefsWorkspace prefsItem path prefsExists |
	self testsIssue: #issue522 withTitle: 'hook to open desired set of windows at startup'.
	path := File workingDirectory , 'Jadeite.prefs'.
	prefsExists := File exists: path.
	prefsExists
		ifTrue: 
			[self savePrefsBackup.
			(File open: path) delete].
	self deny: (File exists: path).
	
	[prefsItem := self browseMenu items detect: [:menuItem | menuItem command == #browseJadeitePrefs].
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #yes.
	prefsWorkspace := prefsItem commandDescription performAgainst: transcript.
	self assert: (File exists: path)]
			ensure: 
				[TestMessageBox disableJadeiteTestMessageBox.
				prefsWorkspace view close.
				self restoreBackupPrefsFile: prefsExists.
				self assert: (File exists: path) equals: prefsExists]!

test_popupMenuHasBrowseClass
	| browseClassItem |
	self testsIssue: #issue429 withTitle: '(3.0.60) ''Browse Class'' on Transcript gets walkback'.
	browseClassItem := transcript transcriptPresenter documentPresenter view contextMenu items
				detect: [:menu | 'Browse Class' match: menu text]
				ifNone: [].
	self denyIsNil: browseClassItem.
	self assert: browseClassItem command equals: #browseSelectedClass.
	self assert: (transcript transcriptPresenter class canUnderstand: #browseSelectedClass)!

test_popupMenuHasBrowseImplementors
	| browseClassItem |
	self testsIssue: #issue429 withTitle: '(3.0.60) ''Browse Class'' on Transcript gets walkback'.
	browseClassItem := transcript transcriptPresenter documentPresenter view contextMenu items
				detect: [:menu | 'Browse Implementors' match: menu text]
				ifNone: [].
	self denyIsNil: browseClassItem.
	self assert: browseClassItem command equals: #browseImplementors.
	self assert: (transcript transcriptPresenter class canUnderstand: #browseImplementors)!

test_popupMenuHasBrowseSenders
	| browseClassItem |
	self testsIssue: #issue429 withTitle: '(3.0.60) ''Browse Class'' on Transcript gets walkback'.
	browseClassItem := transcript transcriptPresenter documentPresenter view contextMenu items
				detect: [:menu | 'Browse Senders' match: menu text]
				ifNone: [].
	self denyIsNil: browseClassItem.
	self assert: browseClassItem command equals: #browseSenders.
	self assert: (transcript transcriptPresenter class canUnderstand: #browseSenders)!

test_projectMenuGitCommitMenuItem
	| gitCommitMenuItem query |
	self testsIssue: #issue317 withTitle: 'Commit when no changes results in walkback'.
	gitCommitMenuItem := transcript projectListPresenter projectListPresenter view queryContextMenu
				items detect: [:menu | '*Commit to Git*' match: menu text] ifNone: [].
	self denyIsNil: gitCommitMenuItem.
	self assert: gitCommitMenuItem command equals: #gitCommit.
	self assert: (transcript projectListPresenter class canUnderstand: #gitCommit).
	query := CommandQuery commandDescription: gitCommitMenuItem
				source: transcript projectListPresenter view.
	transcript projectListPresenter projectListPresenter list do: 
			[:projectService |
			transcript projectListPresenter projectListPresenter selection: projectService.
			transcript projectListPresenter queryCommand: query.
			projectService isDirty ifTrue: [self assert: query isEnabled] ifFalse: [self deny: query isEnabled]]!

test_transcriptNamedConsole
	| clearTranscriptMenuItem wasInstalled |
	(wasInstalled := transcript isTranscriptInstalled) ifFalse: [transcript flipTranscript].
	
	[clearTranscriptMenuItem := transcript transcriptPresenter documentPresenter view queryContextMenu
				items detect: [:menuItem | menuItem command == #clearTranscript].
	clearTranscriptMenuItem commandDescription performAgainst: transcript transcriptPresenter.
	self assert: transcript transcriptPresenter documentPresenter value isEmpty.
	self assert: transcript transcriptPresenter documentPresenter view displayValue isEmpty.
	session executeString: 'Transcript show: ''wroteOnTranscript'''.
	self assert: transcript transcriptPresenter documentPresenter value equals: '''wroteOnTranscript'''.
	clearTranscriptMenuItem commandDescription performAgainst: transcript transcriptPresenter.
	self assert: transcript transcriptPresenter documentPresenter value isEmpty.
	self assert: transcript transcriptPresenter documentPresenter view displayValue isEmpty]
			ensure: [wasInstalled ifFalse: [transcript flipTranscript	"turn back off"]]!

writeToPrefsFile: string
	| fileStream |
	fileStream := FileStream read: File workingDirectory , 'Jadeite.prefs'.
	[fileStream nextPutAll: string] ensure: [fileStream close]! !
!JadeiteTranscriptTestCase categoriesFor: #allTranscriptPresenters!private!support! !
!JadeiteTranscriptTestCase categoriesFor: #browseMenu!private!support!tests! !
!JadeiteTranscriptTestCase categoriesFor: #menuItemIsEnabledInAllPresenters:!private!support! !
!JadeiteTranscriptTestCase categoriesFor: #restoreBackupPrefsFile:!private!support!tests! !
!JadeiteTranscriptTestCase categoriesFor: #savePrefsBackup!private!support!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_abortRemovesProjectsInAllBrowsers!public!test menus! !
!JadeiteTranscriptTestCase categoriesFor: #test_abortTransaction!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_autoCommitOff!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_autoCommitOn!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_autoCommitSet!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_autoCompletionMenuItem!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_browseClassMenuItem!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_browseClassReferencesMenuItem!public!test menus! !
!JadeiteTranscriptTestCase categoriesFor: #test_browseClassReferencesMenuItemIsEnabled!public!test menus! !
!JadeiteTranscriptTestCase categoriesFor: #test_browseFindClassMenuItem!public!test menus! !
!JadeiteTranscriptTestCase categoriesFor: #test_browseImplementors!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_browseImplementorsMenuItem!public!test menus! !
!JadeiteTranscriptTestCase categoriesFor: #test_browseLiteralsReferencesMenuItem!public!test menus! !
!JadeiteTranscriptTestCase categoriesFor: #test_browseMethodsContainingMenuItem!public!test menus! !
!JadeiteTranscriptTestCase categoriesFor: #test_browseProjectsMenuItem!public!test menus! !
!JadeiteTranscriptTestCase categoriesFor: #test_browseSenders!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_browseSendersMenuItem!public!test menus! !
!JadeiteTranscriptTestCase categoriesFor: #test_closeConsoleNeedingCommit!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_closeConsoleNoCommitNeeded!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_commitTransaction!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_doubleClickOpenProjectBrowser!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_flipBreakPointsDisabled!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_implementorsSenders_SearchList!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_implementorsSendersSearchList!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_jadeiteMenuAdHocExecutionItems!public!test menus! !
!JadeiteTranscriptTestCase categoriesFor: #test_menuBarBrowseProjectsHonorsSelection!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_menuNames!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_multiSelectProject!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_openChangesBrowser!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_openPreferencesFile!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_openPreferencesFileCreatePrefsFile!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_popupMenuHasBrowseClass!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_popupMenuHasBrowseImplementors!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_popupMenuHasBrowseSenders!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #test_projectMenuGitCommitMenuItem!public!test menus! !
!JadeiteTranscriptTestCase categoriesFor: #test_transcriptNamedConsole!public!tests! !
!JadeiteTranscriptTestCase categoriesFor: #writeToPrefsFile:!private!support!tests! !

