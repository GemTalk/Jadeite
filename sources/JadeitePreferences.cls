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

allowsSpacesInArgument: commandSymbol
	"so far openWorkspace: is only command to allow spaces in it's arguments"
	^commandSymbol = #openWorkspace:!

applyPreference: preferencesString
	"only perform messages which are defined by this class"

	| message subStrings |
	preferencesString trimBlanks subStrings isEmpty ifTrue: [^self].
	subStrings := preferencesString subStrings.
	message := subStrings first asSymbol.
	(self allowsSpacesInArgument: message)
		ifTrue: [^self performCommand: message allowSpacesInArgs: preferencesString].
	subStrings size = 2 ifFalse: [^self].	"single keyword argument format for now"
	message := subStrings first asSymbol.
	message first = $# ifTrue: [^self].
	(JadeitePreferences methodDictionary at: message ifAbsent: [])
		ifNotNil: [self perform: message with: preferencesString subStrings second]!

autocommitEnabled: booleanString
	| autoCommitService boolean |
	boolean := booleanString = 'true'.
	autoCommitService := RowanAutoCommitService new
				command: #autoCommit:;
				commandArgs: (Array with: boolean).
	BrowserUpdate current issueCommands: (Array with: autoCommitService) session: session!

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
	BrowserUpdate current issueCommands: (Array with: answeringService) session: session!

fontSize: integerStringOrNil
	"file syntax - fontSize: 12"

	| pointSize |
	pointSize := integerStringOrNil = 'nil'
				ifTrue: [nil]
				ifFalse: 
					[[integerStringOrNil asNumber] on: Error
						do: [:ex | ^MessageBox notify: 'Error setting fontSize preference. Error description:' , ex description]].
	JadeiteTextStyles default textStyles do: [:textStyle | textStyle pointSize: pointSize]!

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
	projectBrowser := JadeiteBrowser openOn: session
				project: (RowanProjectService new name: projectName).
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

openWorkspace: pathOrNil
	| workspace |
	workspace := JadeWorkspace showOnSession: session.
	pathOrNil = 'nil'
		ifFalse: 
			[(File exists: pathOrNil)
				ifTrue: [workspace openOn: pathOrNil]
				ifFalse: 
					[| localPath |
					"try the image directory"
					localPath := SessionManager current imageBase , pathOrNil.
					(File exists: localPath)
						ifTrue: [workspace openOn: localPath]
						ifFalse: 
							[workspace view close.
							^MessageBox notify: 'preferences workspace ' , pathOrNil , ' unable to be opened']]].
	^workspace!

performCommand: message allowSpacesInArgs: preferencesString
	| argument readStream |
	readStream := ReadStream on: preferencesString trimBlanks.
	readStream upTo: Character space.
	argument := readStream upToEnd.
	^self perform: message with: argument!

session: anObject
	session := anObject!

transcriptEnabled: booleanString
	"file syntax - transcriptEnabled false"

	| answeringService boolean |
	boolean := booleanString = 'true'.
	answeringService := RowanAnsweringService new.
	(answeringService isTranscriptInstalledIn: session) == boolean
		ifFalse: [answeringService flipTranscriptIn: session]! !
!JadeitePreferences categoriesFor: #allowsSpacesInArgument:!private!testing! !
!JadeitePreferences categoriesFor: #applyPreference:!accessing!must not strip!public! !
!JadeitePreferences categoriesFor: #autocommitEnabled:!must not strip!preferences!public! !
!JadeitePreferences categoriesFor: #autocompleteEnabled:!must not strip!preferences!public! !
!JadeitePreferences categoriesFor: #breakpointsEnabled:!must not strip!preferences!public! !
!JadeitePreferences categoriesFor: #fontSize:!must not strip!preferences!public! !
!JadeitePreferences categoriesFor: #loggingEnabled:!must not strip!preferences!public! !
!JadeitePreferences categoriesFor: #openBrowserOnClass:!must not strip!preferences!public! !
!JadeitePreferences categoriesFor: #openBrowserOnPackage:!must not strip!preferences!public! !
!JadeitePreferences categoriesFor: #openBrowserOnProject:!must not strip!preferences!public! !
!JadeitePreferences categoriesFor: #openProjectBrowser!preferences!private! !
!JadeitePreferences categoriesFor: #openSUnitBrowser!preferences!private! !
!JadeitePreferences categoriesFor: #openSUnitBrowserOnPackage:!must not strip!preferences!public! !
!JadeitePreferences categoriesFor: #openWorkspace:!must not strip!preferences!public! !
!JadeitePreferences categoriesFor: #performCommand:allowSpacesInArgs:!accessing!must not strip!public! !
!JadeitePreferences categoriesFor: #session:!accessing!private! !
!JadeitePreferences categoriesFor: #transcriptEnabled:!must not strip!preferences!public! !

!JadeitePreferences class methodsFor!

onSession: session
	^self new session: session!

preferencesFile

	^'Jadeite.prefs'!

preferencesFileDefaultContents
	^'#Remove # to uncomment option. 

#legal values are a boolean
#autocommitEnabled: false
#autocompleteEnabled: false
#breakpointsEnabled: true
#loggingEnabled: false
#transcriptEnabled: true

#legal values are an integer or nil for default font size
#fontSize: <anInteger or nil>

#legal values are a name (without quotes) or nil
#openBrowserOnClass: <class name>
#openBrowserOnPackage: <package name>
#openBrowserOnProject: <project name> 
#openSUnitBrowserOnPackage: <package name>
#openWorkspace: <file path without quotes or nil> '! !
!JadeitePreferences class categoriesFor: #onSession:!instance creation!public! !
!JadeitePreferences class categoriesFor: #preferencesFile!constants!public! !
!JadeitePreferences class categoriesFor: #preferencesFileDefaultContents!constants!public! !

