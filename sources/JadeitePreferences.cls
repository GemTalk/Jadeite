"Filed out from Dolphin Smallalk"!

Object subclass: #JadeitePreferences
	instanceVariableNames: 'session lastWindowPosition fontPointSize textFontPointSize font fontName textFontName textFont'
	classVariableNames: 'Current'
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeitePreferences guid: (GUID fromString: '{80b64814-9abd-4128-b728-ba94645715b1}')!
JadeitePreferences comment: 'Client preferences are applied on startup. 
See GciSession>>postLoadClientPreferences.

Server preferences are stored in #JadeitePreferences in UserGlobals 
on the server. If the value is a block, it gets run on login after 
client preferences. See GciSession>>postLoadServerPreferences'!
!JadeitePreferences categoriesForClass!Unclassified! !
!JadeitePreferences methodsFor!

allowsSpacesInArgument: commandSymbol
	^commandSymbol = #openWorkspace: or: 
			[commandSymbol = #openBrowserOnClasses: or: [commandSymbol = #font: or: [commandSymbol = #textFont:]]]!

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
	BrowserUpdate current issueCommand: autoCommitService session: session!

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

currentFont
	^font!

currentFont: anObject
	font := anObject!

currentTextFont
	^textFont!

currentTextFont: anObject
	textFont := anObject!

defaultFontPointSize
	^10!

font: stringWithFontNameSize
	| fontInfoArray |
	fontInfoArray := stringWithFontNameSize subStrings.
	font := Font name: fontInfoArray first pointSize: fontInfoArray last asNumber. 
	self class displayFontFrom: font.
	fontName := font name. 
	fontPointSize := font pointSize!

fontName
	^fontName!

fontName: anObject
	fontName := anObject!

fontPointSize
	^fontPointSize ifNil: [fontPointSize := self defaultFontPointSize]!

fontPointSize: anObject
	fontPointSize := anObject!

fontSize: integerStringOrNil
	| pointSize newFont |
	pointSize := integerStringOrNil = 'nil'
				ifTrue: [nil]
				ifFalse: 
					[[integerStringOrNil asNumber] on: Error
						do: [:ex | ^MessageBox notify: 'Error setting fontSize preference. Error description:' , ex description]].
	newFont := (View desktop font ifNil: [Font default]) pointSize: pointSize.
	self class displayFontFrom: newFont!

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

openBrowserOnClasses: stringOfClassNames
	| projectBrowser classService classNameArray |
	classNameArray := stringOfClassNames subStrings.
	projectBrowser := self openProjectBrowser.
	classNameArray do: 
			[:className |
			classService := RowanClassService new name: className.
			projectBrowser currentCard updateAfterFindClass: classService.
			className ~= classNameArray last ifTrue: [projectBrowser addSystemBrowser]].
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

packageGroupsVisible: booleanString
	"file syntax - packageGroupsVisible: true"

	| boolean | 
	boolean := booleanString = 'true'.
	JadePresenter packageGroupsVisible: boolean!

packageListVisible: booleanString
	"file syntax - packageListVisible: true"

	| boolean |
	boolean := booleanString = 'true'.
	JadePresenter packageListVisible: boolean!

performCommand: message allowSpacesInArgs: preferencesString
	| argument readStream |
	readStream := ReadStream on: preferencesString trimBlanks.
	readStream upTo: Character space.
	argument := readStream upToEnd.
	^self perform: message with: argument!

resetFont
	fontPointSize := Font default!

resetTextFont
	textFont := Font default!

session: anObject
	session := anObject!

sigAbortProcessInterval: anIntegerString
	JadePresenter sigAbortProcessInterval: anIntegerString asNumber!

sigAbortsProcessEnabled: booleanString
	JadePresenter sigAbortsProcessEnabled: booleanString = 'true'!

textFont: stringWithFontNameSize
	| fontInfoArray |
	fontInfoArray := stringWithFontNameSize subStrings.
	textFont := Font name: fontInfoArray first pointSize: fontInfoArray last asNumber.
	JadeiteScintillaView allInstances do: [:view | view font: textFont].
	textFontName := font name.
	textFontPointSize := font pointSize!

textFontName
	^textFontName!

textFontName: anObject
	textFontName := anObject!

textFontPointSize
	^textFontPointSize ifNil: [textFontPointSize := self defaultFontPointSize]!

textFontPointSize: anObject
	textFontPointSize := anObject!

textFontSize: integerStringOrNil
	| pointSize |
	pointSize := integerStringOrNil = 'nil'
				ifTrue: [nil]
				ifFalse: 
					[[integerStringOrNil asNumber] on: Error
						do: [:ex | ^MessageBox notify: 'Error setting textFontSize preference. Error description:' , ex description]].
	JadeiteTextStyles default textStyles do: [:textStyle | textStyle pointSize: pointSize]!

transactionMode: transactionMode
	JadePresenter transactionMode: transactionMode asSymbol session: session!

transcriptEnabled: booleanString
	"file syntax - transcriptEnabled false"

	| answeringService boolean |
	boolean := booleanString = 'true'.
	answeringService := RowanAnsweringService new.
	(answeringService isTranscriptInstalledIn: session) == boolean
		ifFalse: [answeringService flipTranscriptIn: session]! !
!JadeitePreferences categoriesForMethods!
allowsSpacesInArgument:!private!testing! !
applyPreference:!accessing!must not strip!public! !
autocommitEnabled:!must not strip!preferences!public! !
autocompleteEnabled:!must not strip!preferences!public! !
breakpointsEnabled:!must not strip!preferences!public! !
currentFont!accessing!public! !
currentFont:!accessing!public! !
currentTextFont!accessing!private! !
currentTextFont:!accessing!private! !
defaultFontPointSize!constants!public! !
font:!must not strip!preferences!private! !
fontName!accessing!private! !
fontName:!accessing!private! !
fontPointSize!accessing!private! !
fontPointSize:!accessing!private! !
fontSize:!must not strip!preferences!public! !
loggingEnabled:!must not strip!preferences!public! !
openBrowserOnClass:!must not strip!preferences!public! !
openBrowserOnClasses:!must not strip!preferences!public! !
openBrowserOnPackage:!must not strip!preferences!public! !
openBrowserOnProject:!must not strip!preferences!public! !
openProjectBrowser!must not strip!preferences!private! !
openSUnitBrowser!must not strip!preferences!private! !
openSUnitBrowserOnPackage:!must not strip!preferences!public! !
openWorkspace:!must not strip!preferences!public! !
packageGroupsVisible:!must not strip!preferences!public! !
packageListVisible:!must not strip!preferences!public! !
performCommand:allowSpacesInArgs:!accessing!must not strip!public! !
resetFont!actions!public! !
resetTextFont!actions!public! !
session:!accessing!private! !
sigAbortProcessInterval:!must not strip!public! !
sigAbortsProcessEnabled:!must not strip!public! !
textFont:!accessing!private! !
textFontName!accessing!private! !
textFontName:!accessing!private! !
textFontPointSize!accessing!private! !
textFontPointSize:!accessing!private! !
textFontSize:!must not strip!preferences!public! !
transactionMode:!must not strip!public! !
transcriptEnabled:!must not strip!preferences!public! !
!

!JadeitePreferences class methodsFor!

current
	^Current!

current: aJadeitePreferences
	Current := aJadeitePreferences!

displayFontFrom: newFont
	| lfw lf |
	lf := newFont logFont.
	lfw := LOGFONTW new. "believe this is necessary if the user picks a legacy font - LOGFONTA"
	lfw
		replaceFrom: 1
		to: lf byteSize
		with: lf bytes
		startingAt: 1.
	lfw faceName: lf faceName.
	View desktop font: (Font fromLogFont: lfw)!

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
#packageGroupsVisible: true
#packageListVisible: true

#legal values are an integer or nil for default font size
#fontSize: <anInteger or nil>
#textFontSize: <anInteger or nil>

#legal values are a name (without quotes or angle brackets) or nil
#openBrowserOnClasses: <className1 className2 ...>
#openBrowserOnPackage: <package name>
#openBrowserOnProject: <project name> 
#openSUnitBrowserOnPackage: <package name>
#openWorkspace: <file path without quotes or nil> 
#transcriptEnabled: true
#sigAbortProcessInterval: <# of seconds with default 10>
#sigAbortsProcessEnabled: true
#transactionMode: <autoBegin manualBegin transactionless>'!

preferencesPath
	^SessionManager current imageBase , self preferencesFile!

public! !
!JadeitePreferences class categoriesForMethods!
current!accessing!public! !
current:!accessing!public! !
displayFontFrom:!public!utilities! !
onSession:!instance creation!public! !
preferencesFile!public! !
preferencesFileDefaultContents!public! !
preferencesPath!public! !
public!public! !
!

