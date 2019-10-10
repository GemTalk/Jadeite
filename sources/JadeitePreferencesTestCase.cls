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
			ensure: [browser view close]! !
!JadeitePreferencesTestCase categoriesFor: #test_preferencesOpenBrowsers!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_preferencesSettingTranscript!public!tests! !
!JadeitePreferencesTestCase categoriesFor: #test_preferencesSUnitOpenBrowser!public!tests! !

