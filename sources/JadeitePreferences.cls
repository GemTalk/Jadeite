"Filed out from Dolphin Smalltalk 7"!

Object subclass: #JadeitePreferences
	instanceVariableNames: 'session'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeitePreferences guid: (GUID fromString: '{80b64814-9abd-4128-b728-ba94645715b1}')!
JadeitePreferences comment: ''!
!JadeitePreferences categoriesForClass!Unclassified! !
!JadeitePreferences methodsFor!

openBrowserOnClass: className
	| projectBrowser classService |
	projectBrowser := JadeiteBrowser showOnSession: session.
	classService := RowanClassService new name: className.
	projectBrowser currentCard updateAfterFindClass: classService.
	^projectBrowser!

openBrowserOnPackage: packageName
	| projectBrowser |
	projectBrowser := JadeiteBrowser showOnSession: session.
	projectBrowser currentCard selectPackageNamed: packageName.
	^projectBrowser!

openBrowserOnProject: projectName
	| projectBrowser |
	projectBrowser := JadeiteBrowser showOnSession: session.
	projectBrowser currentCard selectProjectNamed: projectName.
	^projectBrowser!

setPreference: preferencesString session: gciSession
	"only perform messages which are defined by this class"

	| message |
	session := gciSession.
	message := preferencesString subStrings first asSymbol.
	message first = $# ifTrue:[^self]. 
	(JadeitePreferences methodDictionary at: message ifAbsent: [])
		ifNotNil: [self perform: message with: preferencesString subStrings second]!

transcriptEnabled: booleanString
	"file syntax - transcriptEnabled false"

	| answeringService boolean |
	boolean := booleanString = 'true'.
	answeringService := RowanAnsweringService new.
	(answeringService isTranscriptInstalledIn: session) == boolean
		ifFalse: [answeringService flipTranscriptIn: session]! !
!JadeitePreferences categoriesFor: #openBrowserOnClass:!preferences!public! !
!JadeitePreferences categoriesFor: #openBrowserOnPackage:!preferences!public! !
!JadeitePreferences categoriesFor: #openBrowserOnProject:!preferences!public! !
!JadeitePreferences categoriesFor: #setPreference:session:!accessing!public! !
!JadeitePreferences categoriesFor: #transcriptEnabled:!preferences!public! !

