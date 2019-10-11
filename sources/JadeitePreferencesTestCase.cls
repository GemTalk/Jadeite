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

test_autoCompleteEnabled
	| prefs autoCompleteWasEnabled |
	autoCompleteWasEnabled := JadeiteSearch autoCompleteEnabled.
	
	[prefs := JadeitePreferences new session: session.
	prefs setPreference: 'autocompleteEnabled: true'.
	self assert: JadeiteSearch autoCompleteEnabled.
	prefs setPreference: 'autocompleteEnabled: false'.
	self deny: JadeiteSearch autoCompleteEnabled]
			ensure: [JadeiteSearch autoCompleteEnabled: autoCompleteWasEnabled]!

test_handleMalformedPreference
	| prefs result |
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

test_validPreferences
	| prefs validPreferences |
	validPreferences := #(#transcriptEnabled: #openBrowserOnClass: #openBrowserOnPackage: #openSUnitBrowserOnPackage: #autocommitEnabled: #autocompleteEnabled: #breakpointsEnabled: #loggingEnabled:).
	prefs := JadeitePreferences new session: session.
	validPreferences do: [:symbol | self assert: (prefs class canUnderstand: symbol)]! !
!JadeitePreferencesTestCase categoriesFor: #test_autoCompleteEnabled!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_handleMalformedPreference!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_loggingEnabled!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_preferencesHandlesBlanks!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_preferencesOpenBrowsers!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_preferencesSettingTranscript!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_preferencesSUnitOpenBrowser!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_validPreferences!public!tests! !

