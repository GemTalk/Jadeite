"Filed out from Dolphin Smallalk"!

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

preferenceFileLines
	^JadeitePreferences preferencesFileDefaultContents lines!

preferenceSymbols
	"Private - parse the default contents of the preferences file for symbols"

	| preferenceSymbols |
	preferenceSymbols := self rawPreferenceSymbols.
	preferenceSymbols := preferenceSymbols collect: [:string | (string copyWithout: $#) asSymbol].
	^preferenceSymbols!

prefsFileLastLine
	| stream file lastLine |
	file := File open: JadeitePreferences preferencesPath mode: #read.
	
	[stream := file readWriteStream.
	[stream atEnd] whileFalse: [lastLine := stream nextLine]]
			ensure: [file close].
	^lastLine!

primaryTestWindow
	"Every test should have a primary window it is testing. 
	If not, just return nil"

	^workspace!

rawPreferenceSymbols
	| preferenceSymbols lines |
	lines := self preferenceFileLines.
	preferenceSymbols := OrderedCollection new.
	lines do: 
			[:line |
			| substrings |
			substrings := line subStrings.
			(substrings notEmpty and: [substrings first last = $:])
				ifTrue: [preferenceSymbols add: substrings first]].
	^preferenceSymbols!

tearDown
	workspace ifNotNil: [self closeWorkspace]!

test_additionalAccelerators
	"No way yet to adequately test accelerators function
	but we can assert that we tell Dolphin to set them up"

	| prefs |
	self testsIssue: #issue329 withTitle: 'Need accelerator key tests'.
	prefs := JadeitePreferences new session: session.
	workspace := prefs openWorkspace: 'nil'.
	self assert: workspace additionalAccelerators size equals: 1	"should fail if we add a new one"!

test_allowSpacesInArguments
	| prefs |
	prefs := JadeitePreferences new session: session.
	self assert: (prefs allowsSpacesInArgument: #openWorkspace:).
	self assert: (prefs allowsSpacesInArgument: #openBrowserOnClasses:).
	self assert: (prefs allowsSpacesInArgument: #font:).
	self assert: (prefs allowsSpacesInArgument: #textFont:)!

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

test_fontNameHasSpaces
	| prefs |
	self testsIssue: #issue959 withTitle: '[3.2.12] Cannot set font by name in preferences file'.
	prefs := JadeitePreferences new session: session.
	prefs applyPreference: 'font: Comic Sans MS 10'.
	
	[self assert: View desktop font pointSize equals: 10.
	self assert: View desktop font name equals: 'Comic Sans MS']
			ensure: 
				[JadeitePreferences current resetFont.
				View desktop font: JadeitePreferences defaultFont]!

test_fontSize
	| prefs |
	self testsIssue: #issue805 withTitle: 'Preference to adjust font size (3.1.0)'.
	prefs := JadeitePreferences new session: session.
	prefs applyPreference: 'font: Tahoma 20'.
	[self assert: View desktop font pointSize equals: 20] ensure: 
			[JadeitePreferences current resetFont.
			View desktop font: JadeitePreferences defaultFont]!

test_globalAdditionalAccelerators
	| prefs |
	prefs := JadeitePreferences new session: session.
	workspace := prefs openWorkspace: 'nil'.
	self assert: (self primaryTestWindow additionalAccelerators includes: #(#raiseConsole 'Ctrl+F7'))!

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

test_packageGroupsHidden
	"preference default is for packageGroups to be hidden.
	The preference symbols which are not #'d out will be executed on startup. 
	Confirm packageGroups preference is not #'d out. "

	| packageGroupPreference lines |
	packageGroupPreference := self rawPreferenceSymbols
				detect: [:symbol | '*packageGroupsVisible:*' match: symbol].
	self assert: packageGroupPreference equals: 'packageGroupsVisible:'.
	lines := self preferenceFileLines.
	packageGroupPreference := lines detect: [:symbol | '*packageGroupsVisible:*' match: symbol].
	self assert: packageGroupPreference equals: 'packageGroupsVisible: false'!

test_packageGroupVisible
	| prefs packageGroupWasVisible |
	self testsIssue: #issue887
		withTitle: '(Oscar V3.2) consider having the Preferences>>Package list visible menu apply to all tabs in a browser'.
	packageGroupWasVisible := JadePresenter packageGroupsVisible.
	
	[prefs := JadeitePreferences new session: session.
	prefs applyPreference: 'packageGroupsVisible: true'.
	self assert: JadePresenter packageGroupsVisible.
	prefs applyPreference: 'packageGroupsVisible: false'.
	self deny: JadePresenter packageGroupsVisible]
			ensure: [JadePresenter packageGroupsVisible: packageGroupWasVisible]!

test_packageListVisible
	| prefs packageListWasVisible |
	self testsIssue: #issue887
		withTitle: '(Oscar V3.2) consider having the Preferences>>Package list visible menu apply to all tabs in a browser'.
	packageListWasVisible := JadePresenter packageGroupsVisible.
	
	[prefs := JadeitePreferences new session: session.
	prefs applyPreference: 'packageListVisible: true'.
	self assert: JadePresenter packageListVisible.
	prefs applyPreference: 'packageListVisible: false'.
	self deny: JadePresenter packageListVisible]
			ensure: [JadePresenter packageListVisible: packageListWasVisible]!

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

test_preferencesOpenMultipleClassesInOneBrowser
	| prefs browser |
	prefs := JadeitePreferences new session: session.
	browser := prefs openBrowserOnClasses: 'RowanService String JadeServer'.
	
	[self assert: (browser isKindOf: JadeiteBrowser).
	self assert: browser cardsPresenter view firstCard presenter classListPresenter selection name
		equals: 'RowanService'.
	self assert: browser cardsPresenter view nextCard presenter classListPresenter selection name
		equals: 'String'.
	self assert: browser cardsPresenter view lastCard presenter classListPresenter selection name
		equals: 'JadeServer']
			ensure: [self destroy: browser]!

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

test_preferencesSigAbortsProcessEnabled
	| prefs previousSigAbortsProcessEnabled |
	self testsIssue: #issue889 withTitle: 'Support transaction modes & SIGABORT handling'.
	previousSigAbortsProcessEnabled := JadePresenter sigAbortsProcessEnabled.
	
	[prefs := JadeitePreferences new session: session.
	prefs sigAbortsProcessEnabled: false.
	self assert: JadePresenter sigAbortsProcessEnabled equals: false]
			ensure: [JadePresenter sigAbortsProcessEnabled: previousSigAbortsProcessEnabled]!

test_preferencesSigAbortsProcessInterval
	| prefs previousSigAbortsProcessInterval |
	self testsIssue: #issue889 withTitle: 'Support transaction modes & SIGABORT handling'.
	previousSigAbortsProcessInterval := JadePresenter sigAbortProcessInterval.
	
	[prefs := JadeitePreferences new session: session.
	prefs sigAbortProcessInterval: '500'.
	self assert: JadePresenter sigAbortProcessInterval equals: 500]
			ensure: [JadePresenter sigAbortProcessInterval: previousSigAbortsProcessInterval]!

test_preferencesSUnitOpenBrowser
	| prefs browser |
	prefs := JadeitePreferences new session: session.
	browser := prefs openSUnitBrowserOnPackage: 'Rowan-Services-Tests'.
	
	[self assert: (browser isKindOf: JadeiteSUnitBrowser).
	self assert: browser primaryPresenter packageListPresenter selection name
		equals: 'Rowan-Services-Tests']
			ensure: [browser view close]!

test_preferencesTransactionModeSet
	| prefs previousTransactionMode |
	self testsIssue: #issue889 withTitle: 'Support transaction modes & SIGABORT handling'.
	previousTransactionMode := JadePresenter transactionMode.
	
	[prefs := JadeitePreferences new session: session.
	prefs transactionMode: #transactionless.
	self assert: JadePresenter transactionMode = #transactionless]
			ensure: [JadePresenter transactionMode: previousTransactionMode session: session]!

test_resetPreferences
	self testsIssue: #issue553 withTitle: 'Jadeite settings in preferences file (3.0.78)'.
	workspace := JadeitePreferencesWorkspace showOnSession: session.
	workspace model value: String new.
	workspace basicResetPreferences.
	self assert: workspace model value equals: JadeitePreferences preferencesFileDefaultContents!

test_saveMultipleClassesInPrefsFile
	| prefs prefsFileContents file |
	prefs := JadeitePreferences new session: session.
	self deny: self prefsFileLastLine trimBlanks
				= 'openBrowserOnClasses: RowanService OrderedCollection Array'.
	file := File open: JadeitePreferences preferencesPath mode: #read.
	[prefsFileContents := file readWriteStream contents] ensure: [file close].
	
	[projectsBrowser := prefs openBrowserOnClasses: 'RowanService OrderedCollection Array'.
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #ok.
	[projectsBrowser saveCurrentClassTabsToPreferencesFile]
		ensure: [TestMessageBox disableJadeiteTestMessageBox].
	self assert: self prefsFileLastLine trimBlanks
				= 'openBrowserOnClasses: RowanService OrderedCollection Array']
			ensure: 
				[self destroy: projectsBrowser.
				file := File
							open: JadeitePreferences preferencesPath
							mode: #truncate
							check: false.
				[file write: prefsFileContents] ensure: [file close]]!

test_setResetFont
	self testsIssue: #issue805 withTitle: 'Preference to adjust font size (3.1.0)'.
	transcript basicSetFont: (Font name: 'Tahoma' pointSize: 16).
	self assert: View desktop font name equals: 'Tahoma'.
	self assert: View desktop font pointSize equals: 16.
	transcript resetFonts.
	self assert: View desktop font name equals: JadeitePreferences defaultFont name.
	self assert: View desktop font pointSize equals: JadeitePreferences defaultFont pointSize!

test_setResetTextFont
	self testsIssue: #issue805 withTitle: 'Preference to adjust font size (3.1.0)'.
	transcript basicSetTextFont: (Font name: 'Tahoma' pointSize: 16).
	JadeiteScintillaView allInstances do: 
			[:scintillaView |
			self assert: scintillaView font pointSize equals: 16.
			self assert: scintillaView font name equals: 'Tahoma'].
	transcript resetFonts.
	JadeiteScintillaView allInstances do: 
			[:scintillaView |
			self assert: scintillaView font pointSize equals: JadeitePreferences defaultTextFont pointSize.
			self assert: scintillaView font name equals: JadeitePreferences defaultTextFont name]!

test_textFont
	| prefs |
	self testsIssue: #issue805 withTitle: 'Preference to adjust font size (3.1.0)'.
	prefs := JadeitePreferences new session: session.
	
	[prefs applyPreference: 'textFont: Verdana 20'.
	JadeiteScintillaView allInstances do: 
			[:view |
			self assert: view font pointSize equals: 20.
			self assert: view font name equals: 'Verdana']]
			ensure: [JadeitePreferences current resetTextFont]!

test_textFontNameHasSpaces
	| prefs |
	self testsIssue: #issue959 withTitle: '[3.2.12] Cannot set font by name in preferences file'.
	prefs := JadeitePreferences new session: session.
	
	[prefs applyPreference: 'textFont: Comic Sans MS 10'.
	JadeiteScintillaView allInstances do: 
			[:view |
			self assert: view font pointSize equals: 10.
			self assert: view font name equals: 'Comic Sans MS']]
			ensure: [JadeitePreferences current resetTextFont]!

test_validPreferences
	| prefs validPreferences |
	self testsIssue: #issue553 withTitle: 'Jadeite settings in preferences file (3.0.78)'.
	validPreferences := self preferenceSymbols. 
	prefs := JadeitePreferences new session: session.
	validPreferences do: [:symbol | self assert: (prefs class canUnderstand: symbol)]! !
!JadeitePreferencesTestCase categoriesForMethods!
closeWorkspace!private!support! !
preferenceFileLines!private!support! !
preferenceSymbols!private!support! !
prefsFileLastLine!private!support! !
primaryTestWindow!accessing!public! !
rawPreferenceSymbols!private!support! !
tearDown!private!setup teardown! !
test_additionalAccelerators!public!tests! !
test_allowSpacesInArguments!public!tests! !
test_autoCommitEnabled!public!tests! !
test_autoCompleteEnabled!public!tests! !
test_blanksInOpenWorkspaceArguments!public!tests! !
test_breakpointEnabled!public!tests! !
test_everyPreferenceIsInMustNotStripCategory!public! !
test_fontNameHasSpaces!public!tests! !
test_fontSize!public!tests! !
test_globalAdditionalAccelerators!public!tests! !
test_handleMalformedPreference!public!tests! !
test_loggingEnabled!public!tests! !
test_packageGroupsHidden!public!tests! !
test_packageGroupVisible!public!tests! !
test_packageListVisible!public!tests! !
test_preferencesHandlesBlanks!public!tests! !
test_preferencesOpenBrowsers!public!tests! !
test_preferencesOpenCorrectWorkspaceFiles!public!tests! !
test_preferencesOpenMultipleClassesInOneBrowser!public!tests! !
test_preferencesOpenWorkspace!public!tests! !
test_preferencesOpenWorkspaceFiles!public!tests! !
test_preferencesSettingTranscript!public!tests! !
test_preferencesSigAbortsProcessEnabled!public! !
test_preferencesSigAbortsProcessInterval!public! !
test_preferencesSUnitOpenBrowser!public!tests! !
test_preferencesTransactionModeSet!public! !
test_resetPreferences!public!tests! !
test_saveMultipleClassesInPrefsFile!public!tests! !
test_setResetFont!public!tests! !
test_setResetTextFont!public!tests! !
test_textFont!public!tests! !
test_textFontNameHasSpaces!public!tests! !
test_validPreferences!public!tests! !
!

