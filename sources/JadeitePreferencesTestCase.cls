"Filed out from Dolphin Smalltalk 7"!

JadeiteAbstractTestCase subclass: #JadeitePreferencesTestCase
	instanceVariableNames: 'workspace'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeitePreferencesTestCase guid: (GUID fromString: '{af9192c0-b3c9-464b-8407-cc39db5b4a9f}')!
JadeitePreferencesTestCase comment: ''!
!JadeitePreferencesTestCase categoriesForClass!Unclassified! !
!JadeitePreferencesTestCase methodsFor!

closeWorkspace
	workspace
		ifNotNil: 
			[workspace codePane documentPresenter view isModified: false.
			workspace view close]!

tearDown
	workspace ifNotNil: [self closeWorkspace]!

test_autoCommitEnabled
	| prefs autoCommitWasEnabled |
	self testsIssue: #issue553 withTitle: 'Jadeite settings in preferences file (3.0.78)'.
	autoCommitWasEnabled := transcript autoCommit.
	
	[prefs := JadeitePreferences new session: session.
	prefs applyPreference: 'autocommitEnabled: true'.
	self assert: transcript autoCommit.
	prefs applyPreference: 'autocommitEnabled: false'.
	self deny: transcript autoCommit]
			ensure: [transcript autoCommit: autoCommitWasEnabled]!

test_autoCompleteEnabled
	| prefs autoCompleteWasEnabled |
	self testsIssue: #issue553 withTitle: 'Jadeite settings in preferences file (3.0.78)'.
	autoCompleteWasEnabled := JadeiteSearch autoCompleteEnabled.
	
	[prefs := JadeitePreferences new session: session.
	prefs applyPreference: 'autocompleteEnabled: true'.
	self assert: JadeiteSearch autoCompleteEnabled.
	prefs applyPreference: 'autocompleteEnabled: false'.
	self deny: JadeiteSearch autoCompleteEnabled]
			ensure: [JadeiteSearch autoCompleteEnabled: autoCompleteWasEnabled]!

test_blanksInOpenWorkspaceArguments
	| prefs file fileName |
	fileName := 'file with blanks in name.gs'.
	file := File open: fileName mode: #create.
	file close.
	
	[prefs := JadeitePreferences new session: session.
	workspace := prefs openWorkspace: fileName.
	self assert: ('file with blanks in name.gs*' match: workspace caption).
	self assert: (workspace isKindOf: JadeWorkspace)]
			ensure: [file delete]!

test_breakpointEnabled
	| prefs breakpointWasEnabled |
	self testsIssue: #issue553 withTitle: 'Jadeite settings in preferences file (3.0.78)'.
	breakpointWasEnabled := transcript areBreakpointsEnabled value.
	
	[prefs := JadeitePreferences new session: session.
	prefs applyPreference: 'breakpointsEnabled: true'.
	self assert: transcript areBreakpointsEnabled value.
	prefs applyPreference: 'breakpointsEnabled: false'.
	self deny: transcript areBreakpointsEnabled value]
			ensure: [transcript areBreakpointsEnabled value: breakpointWasEnabled]!

test_everyPreferenceIsInMustNotStripCategory
	"or else the preference will silently fail in runtime.
	All preferences are assumed to be in default file and
	preferences are in the format of ... # <method selector:> value"

	| stream count |
	stream := ReadStream on: JadeitePreferences preferencesFileDefaultContents.
	count := 0.
	
	[[stream atEnd] whileFalse: 
			[| line substrings selector method categories |
			line := stream nextLine.
			substrings := line subStrings.
			(substrings notEmpty and: [substrings first first = $# and: [substrings first last = $:]])
				ifTrue: 
					[selector := (substrings first copyWithout: $#) asSymbol.
					method := JadeitePreferences methodDictionary at: selector.
					categories := (JadeitePreferences categoriesOfMethod: method) collect: [:category | category name].
					self assert: (categories asArray includes: 'must not strip').
					count := count + 1]]]
			ensure: 
				[self assert: count >= 10.	"sanity test that we checked every pref at the time test was written"
				stream close]!

test_handleMalformedPreference
	| prefs result |
	self testsIssue: #issue553 withTitle: 'Jadeite settings in preferences file (3.0.78)'.
	prefs := JadeitePreferences new session: session.
	result := prefs applyPreference: 'transcriptEnabled:'.	"no argument"
	self assert: result equals: prefs.
	result := prefs applyPreference: 'transcriptEnabled: true false'.	"too many arguments"
	self assert: result equals: prefs.
	result := prefs applyPreference: 'glooble: true'.	"invalid preference, but well-formed"
	self assert: result equals: prefs.
	result := prefs applyPreference: '		transcriptEnabled: true'.	"indentation ok "
	self assert: result equals: prefs!

test_loggingEnabled
	| prefs loggingWasEnabled |
	self testsIssue: #issue553 withTitle: 'Jadeite settings in preferences file (3.0.78)'.
	loggingWasEnabled := BrowserUpdate current isLogging.
	
	[prefs := JadeitePreferences new session: session.
	prefs applyPreference: 'loggingEnabled: true'.
	self assert: BrowserUpdate current isLogging.
	prefs applyPreference: 'loggingEnabled: false'.
	self deny: BrowserUpdate current isLogging]
			ensure: [BrowserUpdate current isLogging: loggingWasEnabled]!

test_preferencesHandlesBlanks
	| prefs result |
	prefs := JadeitePreferences new session: session.
	result := prefs applyPreference: String new.
	self assert: result equals: prefs.	"#setPreference: returns itself. Just test that it returned and didn't walkback"
	result := prefs
				applyPreference: ((WriteStream on: String new)
						cr;
						lf;
						tab;
						space;
						yourself) contents.	"prefs should trim blanks"
	self assert: result equals: prefs!

test_preferencesOpenBrowsers
	| prefs browser |
	prefs := JadeitePreferences new session: session.
	browser := prefs openBrowserOnProject: 'Rowan'.
	
	[self assert: (browser isKindOf: JadeiteBrowser).
	self assert: browser currentCard projectListPresenter selection name equals: 'Rowan']
			ensure: [browser view close].
	browser := prefs openBrowserOnPackage: 'Rowan-Services-Core'.
	
	[self assert: (browser isKindOf: JadeiteBrowser).
	self assert: browser currentCard packageListPresenter selection name equals: 'Rowan-Services-Core']
			ensure: [browser view close].
	browser := prefs openBrowserOnClass: 'RowanAnsweringService'.
	
	[self assert: (browser isKindOf: JadeiteBrowser).
	self assert: browser currentCard classListPresenter selection name equals: 'RowanAnsweringService']
			ensure: [browser view close]!

test_preferencesOpenCorrectWorkspaceFiles
	"make sure to open the correct file if two are present 
	in subdirectories"

	| prefs file1 file2 |
	self testsIssue: #issue632
		withTitle: '(3.0.87) Opening workspace from Jadeite.prefs doesn''t work on first login'.
	prefs := JadeitePreferences new session: session.
	File createDirectory: 'operations'.
	file1 := File
				open: 'testws1.gs'
				mode: #create
				check: false.
	[file1 write: 'testws1.gs'] ensure: [file1 close].
	file2 := File
				open: 'operations\testws1.gs'
				mode: #create
				check: false.
	[file2 write: 'operations\testws1.gs'] ensure: [file2 close].
	workspace := prefs openWorkspace: 'testws1.gs'.
	[self assert: workspace codePane documentPresenter value equals: 'testws1.gs']
		ensure: [self closeWorkspace].
	workspace := prefs openWorkspace: 'operations\testws1.gs'.
	[self assert: workspace codePane documentPresenter value equals: 'operations\testws1.gs'] ensure: 
			[self closeWorkspace.
			file1 delete.
			file2 delete.
			File deleteDirectory: 'operations']!

test_preferencesOpenWorkspace
	| prefs |
	prefs := JadeitePreferences new session: session.
	workspace := prefs openWorkspace: 'nil'.
	self assert: (workspace isKindOf: JadeWorkspace)!

test_preferencesOpenWorkspaceFiles
	| prefs file |
	self testsIssue: #issue632
		withTitle: '(3.0.87) Opening workspace from Jadeite.prefs doesn''t work on first login'.
	prefs := JadeitePreferences new session: session.
	file := File
				open: 'testPrefWorkspace.gs'
				mode: #create
				check: false.
	[file write: 'test1'] ensure: [file close].
	
	[workspace := prefs openWorkspace: 'testPrefWorkspace.gs'.
	self assert: workspace codePane documentPresenter value equals: 'test1']
			ensure: 
				[self closeWorkspace.
				file delete].
	file := File
				open: 'test pref workspace.gs'
				mode: #create
				check: false.
	[file write: 'test2'] ensure: [file close].
	
	[workspace := prefs openWorkspace: 'test pref workspace.gs'.	"spaces in name"
	self assert: workspace codePane documentPresenter value equals: 'test2']
			ensure: 
				[self closeWorkspace.
				file delete].
	file := File
				open: SessionManager current imageBase , 'testPrefWorkspace.gs'
				mode: #create
				check: false.
	[file write: 'test3'] ensure: [file close].
	
	[workspace := prefs openWorkspace: SessionManager current imageBase , 'testPrefWorkspace.gs'.
	self assert: workspace codePane documentPresenter value equals: 'test3']
			ensure: 
				[self closeWorkspace.
				file delete]!

test_preferencesSettingTranscript
	| prefs transcriptInstalled |
	prefs := JadeitePreferences new session: session.
	transcriptInstalled := RowanAnsweringService new isTranscriptInstalledIn: session.
	prefs transcriptEnabled: 'true'.
	
	[self assert: (RowanAnsweringService new isTranscriptInstalledIn: session).
	prefs transcriptEnabled: 'false'.
	self deny: (RowanAnsweringService new isTranscriptInstalledIn: session)]
			ensure: [transcriptInstalled ifTrue: [RowanAnsweringService new flipTranscriptIn: session]]!

test_preferencesSUnitOpenBrowser
	| prefs browser |
	prefs := JadeitePreferences new session: session.
	browser := prefs openSUnitBrowserOnPackage: 'Rowan-Services-Tests'.
	
	[self assert: (browser isKindOf: JadeiteSUnitBrowser).
	self assert: browser primaryPresenter packageListPresenter selection name
		equals: 'Rowan-Services-Tests']
			ensure: [browser view close]!

test_resetPreferences
	self testsIssue: #issue553 withTitle: 'Jadeite settings in preferences file (3.0.78)'.
	workspace := JadeitePreferencesWorkspace showOnSession: session.
	workspace model value: String new.
	workspace basicResetPreferences.
	self assert: (workspace model value equals: JadeitePreferences preferencesFileDefaultContents)!

test_validPreferences
	| prefs validPreferences |
	self testsIssue: #issue553 withTitle: 'Jadeite settings in preferences file (3.0.78)'.
	validPreferences := #(#transcriptEnabled: #openBrowserOnClass: #openBrowserOnPackage: #openSUnitBrowserOnPackage: #autocommitEnabled: #autocompleteEnabled: #breakpointsEnabled: #loggingEnabled:).
	prefs := JadeitePreferences new session: session.
	validPreferences do: [:symbol | self assert: (prefs class canUnderstand: symbol)]! !
!JadeitePreferencesTestCase categoriesFor: #closeWorkspace!public!support! !
!JadeitePreferencesTestCase categoriesFor: #tearDown!private!setup teardown! !
!JadeitePreferencesTestCase categoriesFor: #test_autoCommitEnabled!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_autoCompleteEnabled!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_blanksInOpenWorkspaceArguments!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_breakpointEnabled!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_everyPreferenceIsInMustNotStripCategory!public! !
!JadeitePreferencesTestCase categoriesFor: #test_handleMalformedPreference!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_loggingEnabled!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_preferencesHandlesBlanks!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_preferencesOpenBrowsers!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_preferencesOpenCorrectWorkspaceFiles!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_preferencesOpenWorkspace!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_preferencesOpenWorkspaceFiles!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_preferencesSettingTranscript!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_preferencesSUnitOpenBrowser!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_resetPreferences!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_validPreferences!public!tests! !

