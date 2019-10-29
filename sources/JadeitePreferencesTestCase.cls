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

tearDown
	workspace
		ifNotNil: 
			[workspace isModified: false.
			workspace view close]!

test_autoCommitEnabled
	| prefs autoCommitWasEnabled |
	self testsIssue: #issue553 withTitle: 'Jadeite settings in preferences file (3.0.78)'.
	autoCommitWasEnabled := transcript autoCommit.
	
	[prefs := JadeitePreferences new session: session.
	prefs setPreference: 'autocommitEnabled: true'.
	self assert: transcript autoCommit.
	prefs setPreference: 'autocommitEnabled: false'.
	self deny: transcript autoCommit]
			ensure: [transcript autoCommit: autoCommitWasEnabled]!

test_autoCompleteEnabled
	| prefs autoCompleteWasEnabled |
	self testsIssue: #issue553 withTitle: 'Jadeite settings in preferences file (3.0.78)'.
	autoCompleteWasEnabled := JadeiteSearch autoCompleteEnabled.
	
	[prefs := JadeitePreferences new session: session.
	prefs setPreference: 'autocompleteEnabled: true'.
	self assert: JadeiteSearch autoCompleteEnabled.
	prefs setPreference: 'autocompleteEnabled: false'.
	self deny: JadeiteSearch autoCompleteEnabled]
			ensure: [JadeiteSearch autoCompleteEnabled: autoCompleteWasEnabled]!

test_breakpointEnabled
	| prefs breakpointWasEnabled |
	self testsIssue: #issue553 withTitle: 'Jadeite settings in preferences file (3.0.78)'.
	breakpointWasEnabled := transcript areBreakpointsEnabled value.
	
	[prefs := JadeitePreferences new session: session.
	prefs setPreference: 'breakpointsEnabled: true'.
	self assert: transcript areBreakpointsEnabled value.
	prefs setPreference: 'breakpointsEnabled: false'.
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
	result := prefs setPreference: 'transcriptEnabled:'.	"no argument"
	self assert: result equals: prefs.
	result := prefs setPreference: 'transcriptEnabled: true false'.	"too many arguments"
	self assert: result equals: prefs.
	result := prefs setPreference: 'glooble: true'.	"invalid preference, but well-formed"
	self assert: result equals: prefs.
	result := prefs setPreference: '		transcriptEnabled: true'.	"indentation ok "
	self assert: result equals: prefs!

test_loggingEnabled
	| prefs loggingWasEnabled |
	self testsIssue: #issue553 withTitle: 'Jadeite settings in preferences file (3.0.78)'.
	loggingWasEnabled := BrowserUpdate current isLogging.
	
	[prefs := JadeitePreferences new session: session.
	prefs setPreference: 'loggingEnabled: true'.
	self assert: BrowserUpdate current isLogging.
	prefs setPreference: 'loggingEnabled: false'.
	self deny: BrowserUpdate current isLogging]
			ensure: [BrowserUpdate current isLogging: loggingWasEnabled]!

test_preferencesHandlesBlanks
	| prefs result |
	prefs := JadeitePreferences new session: session.
	result := prefs setPreference: String new.
	self assert: result equals: prefs.	"#setPreference: returns itself. Just test that it returned and didn't walkback"
	result := prefs
				setPreference: ((WriteStream on: String new)
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

test_preferencesOpenWorkspace
	| prefs |
	prefs := JadeitePreferences new session: session.
	workspace := prefs openWorkspace: 'nil'.
	[self assert: (workspace isKindOf: JadeWorkspace)] ensure: [workspace view close]!

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
!JadeitePreferencesTestCase categoriesFor: #tearDown!private!setup teardown! !
!JadeitePreferencesTestCase categoriesFor: #test_autoCommitEnabled!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_autoCompleteEnabled!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_breakpointEnabled!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_everyPreferenceIsInMustNotStripCategory!public! !
!JadeitePreferencesTestCase categoriesFor: #test_handleMalformedPreference!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_loggingEnabled!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_preferencesHandlesBlanks!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_preferencesOpenBrowsers!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_preferencesOpenWorkspace!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_preferencesSettingTranscript!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_preferencesSUnitOpenBrowser!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_resetPreferences!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_validPreferences!public!tests! !

