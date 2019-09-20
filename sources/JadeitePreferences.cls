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

	| message |
	message := preferencesString subStrings first asSymbol.
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
	^self new session: session! !
!JadeitePreferences class categoriesFor: #onSession:!instance creation!public! !

