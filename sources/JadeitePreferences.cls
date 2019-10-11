"Filed out from Dolphin Smalltalk 7"!

Object subclass: #JadeitePreferences
	instanceVariableNames: 'session lastWindowPosition'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeitePreferences guid: (GUID fromString: '{80b64814-9abd-4128-b728-ba94645715b1}')!
JadeitePreferences comment: ''!
!JadeitePreferences categoriesForClass!Unclassified! !
!JadeitePreferences methodsFor!

autocommitEnabled: booleanString
	| autoCommitService boolean |
	boolean := booleanString = 'true'.
	autoCommitService := RowanAutoCommitService new
				command: #autoCommit:;
				commandArgs: (Array with: boolean).
	BrowserUpdate current issueCommand: (Array with: autoCommitService) session: session!

autocompleteEnabled: booleanString
	| boolean |
	"auto complete state held on the client"
	boolean := booleanString = 'true'.
	JadeiteSearch autoCompleteEnabled: boolean!

breakpointsEnabled: booleanString
	| answeringService boolean |
	boolean := booleanString = 'true'.
	answeringService := RowanAnsweringService new
				command: #setBreakPointsAreEnabled:;
				commandArgs: (Array with: boolean).
	BrowserUpdate current issueCommand: (Array with: answeringService) session: session.!

loggingEnabled: booleanString
	| boolean |
	boolean := booleanString = 'true'.
	BrowserUpdate current isLogging: boolean!

openBrowserOnClass: className
	| projectBrowser classService |
	projectBrowser := self openProjectBrowser.
	classService := RowanClassService new name: className.
	projectBrowser currentCard updateAfterFindClass: classService.
	lastWindowPosition := projectBrowser view position.
	^projectBrowser!

openBrowserOnPackage: packageName
	| projectBrowser |
	projectBrowser := self openProjectBrowser.
	projectBrowser currentCard selectPackageNamed: packageName.
	lastWindowPosition := projectBrowser view position.
	^projectBrowser!

openBrowserOnProject: projectName
	| projectBrowser |
	projectBrowser := self openProjectBrowser.
	projectBrowser currentCard selectProjectNamed: projectName.
	lastWindowPosition := projectBrowser view position.
	^projectBrowser!

openProjectBrowser
	| projectBrowser |
	projectBrowser := JadeiteBrowser showOnSession: session.
	lastWindowPosition ifNotNil: [projectBrowser position: lastWindowPosition + 20].
	^projectBrowser!

openSUnitBrowser
	| projectBrowser |
	projectBrowser := JadeiteSUnitBrowser showOnSession: session.
	lastWindowPosition ifNotNil: [projectBrowser position: lastWindowPosition + 20].
	^projectBrowser!

openSUnitBrowserOnPackage: packageName
	| sunitBrowser packageSelection |
	sunitBrowser := self openSUnitBrowser.
	packageSelection := sunitBrowser primaryPresenter packageListPresenter list
				detect: [:packageService | packageService name = packageName]
				ifNone: [^self].
	sunitBrowser primaryPresenter packageListPresenter selection: packageSelection.
	lastWindowPosition := sunitBrowser view position.
	^sunitBrowser!

session: anObject
	session := anObject!

setPreference: preferencesString
	"only perform messages which are defined by this class"

	| message subStrings |
	preferencesString trimBlanks subStrings isEmpty ifTrue: [^self].
	subStrings := preferencesString subStrings.
	subStrings size = 2 ifFalse: [^self].	"single keyword argument format for now"
	message := subStrings first asSymbol.
	message first = $# ifTrue: [^self].
	(JadeitePreferences methodDictionary at: message ifAbsent: [])
		ifNotNil: [self perform: message with: preferencesString subStrings second]!

transcriptEnabled: booleanString
	"file syntax - transcriptEnabled false"

	| answeringService boolean |
	boolean := booleanString = 'true'.
	answeringService := RowanAnsweringService new.
	(answeringService isTranscriptInstalledIn: session) == boolean
		ifFalse: [answeringService flipTranscriptIn: session]! !
!JadeitePreferences categoriesFor: #autocommitEnabled:!must not strip!preferences!public! !
!JadeitePreferences categoriesFor: #autocompleteEnabled:!must not strip!preferences!public! !
!JadeitePreferences categoriesFor: #breakpointsEnabled:!must not strip!preferences!public! !
!JadeitePreferences categoriesFor: #loggingEnabled:!must not strip!preferences!public! !
!JadeitePreferences categoriesFor: #openBrowserOnClass:!must not strip!preferences!public! !
!JadeitePreferences categoriesFor: #openBrowserOnPackage:!must not strip!preferences!public! !
!JadeitePreferences categoriesFor: #openBrowserOnProject:!must not strip!preferences!public! !
!JadeitePreferences categoriesFor: #openProjectBrowser!preferences!private! !
!JadeitePreferences categoriesFor: #openSUnitBrowser!preferences!private! !
!JadeitePreferences categoriesFor: #openSUnitBrowserOnPackage:!must not strip!preferences!public! !
!JadeitePreferences categoriesFor: #session:!accessing!private! !
!JadeitePreferences categoriesFor: #setPreference:!accessing!must not strip!public! !
!JadeitePreferences categoriesFor: #transcriptEnabled:!must not strip!preferences!public! !

!JadeitePreferences class methodsFor!

onSession: session
	^self new session: session!

preferencesFile

	^'Jadeite.prefs'!

preferencesFileDefaultContents
	^'#Remove # to uncomment option. 
#legal values are either a boolean or a name

#autocommitEnabled: true
#autocompleteEnabled: false
#breakpointsEnabled: true
#loggingEnabled: false
#openBrowserOnClass: <class name>
#openBrowserOnPackage: <package name>
#openBrowserOnProject: <project name> 
#openSUnitBrowserOnPackage: <package name>
#transcriptEnabled: true'! !
!JadeitePreferences class categoriesFor: #onSession:!instance creation!public! !
!JadeitePreferences class categoriesFor: #preferencesFile!constants!public! !
!JadeitePreferences class categoriesFor: #preferencesFileDefaultContents!constants!public! !

