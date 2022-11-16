"Filed out from Dolphin Smallalk"!

Object subclass: #JadeitePreferences
	instanceVariableNames: 'session lastWindowPosition font textFont'
	classVariableNames: 'Current DefaultFont DefaultTextFont'
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeitePreferences guid: (GUID fromString: '{80b64814-9abd-4128-b728-ba94645715b1}')!
JadeitePreferences comment: 'Client preferences are applied on startup. 
See GciSession>>postLoadClientPreferences.

Server preferences are stored in #JadeitePreferences in UserGlobals 
on the server. If the value is a block, it gets run on login after 
client preferences. See GciSession>>postLoadServerPreferences

DefaultFont & DefaultTextFont are captured lazily at startup as changing fonts
dynamically can change the system default fonts. '!
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
	font ifNil: [font := self class defaultFont].
	^font!

currentFont: anObject
	font := anObject!

currentTextFont
	textFont ifNil: [textFont := self class defaultTextFont].
	^textFont!

currentTextFont: anObject
	textFont := anObject!

font: stringWithFontNameSize
	| fontInfoArray |
	fontInfoArray := stringWithFontNameSize subStrings.
	font := Font name: fontInfoArray first pointSize: fontInfoArray last asNumber. 
	self class displayFontFrom: font.!

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
	"Private - file syntax - packageGroupsVisible: true"

	| boolean | 
	boolean := booleanString = 'true'.
	JadePresenter packageGroupsVisible: boolean!

packageListVisible: booleanString
	"Private - file syntax - packageListVisible: true"

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
	View desktop font: JadeitePreferences defaultFont.
	font := self class defaultFont!

resetTextFont
	JadeiteScintillaView allInstances
		do: [:scintillaView | scintillaView font: JadeitePreferences defaultTextFont].
	textFont := self class defaultTextFont!

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
	JadeiteScintillaView allInstances do: [:view | view font: textFont]!

transactionMode: transactionMode
	JadePresenter transactionMode: transactionMode asSymbol session: session!

transcriptEnabled: booleanString
	"Private - file syntax - transcriptEnabled false"

	| answeringService boolean |
	boolean := booleanString = 'true'.
	answeringService := RowanAnsweringService new.
	(answeringService isTranscriptInstalledIn: session) == boolean
		ifFalse: [answeringService flipTranscriptIn: session]! !
!JadeitePreferences categoriesForMethods!
allowsSpacesInArgument:!private!testing! !
applyPreference:!accessing!must not strip!public! !
autocommitEnabled:!must not strip!preferences!private! !
autocompleteEnabled:!must not strip!preferences!private! !
breakpointsEnabled:!must not strip!preferences!private! !
currentFont!accessing!public! !
currentFont:!accessing!public! !
currentTextFont!accessing!private! !
currentTextFont:!accessing!private! !
font:!must not strip!preferences!private! !
loggingEnabled:!must not strip!preferences!private! !
openBrowserOnClass:!must not strip!preferences!private! !
openBrowserOnClasses:!must not strip!preferences!private! !
openBrowserOnPackage:!must not strip!preferences!private! !
openBrowserOnProject:!must not strip!preferences!private! !
openProjectBrowser!must not strip!preferences!private! !
openSUnitBrowser!must not strip!preferences!private! !
openSUnitBrowserOnPackage:!must not strip!preferences!private! !
openWorkspace:!must not strip!preferences!private! !
packageGroupsVisible:!must not strip!preferences!private! !
packageListVisible:!must not strip!preferences!private! !
performCommand:allowSpacesInArgs:!accessing!must not strip!public! !
resetFont!actions!public! !
resetTextFont!actions!public! !
session:!accessing!private! !
sigAbortProcessInterval:!must not strip!public! !
sigAbortsProcessEnabled:!must not strip!public! !
textFont:!must not strip!preferences!private! !
transactionMode:!must not strip!public! !
transcriptEnabled:!must not strip!preferences!private! !
!

!JadeitePreferences class methodsFor!

current
	^Current!

current: aJadeitePreferences
	Current ifNil: [DefaultTextFont := self initializeDefaultFonts].
	Current := aJadeitePreferences!

defaultFont
	^DefaultFont!

defaultTextFont
	^DefaultTextFont!

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

initializeDefaultFonts
	DefaultFont := SmalltalkSystem current defaultFont.
	^Font name: 'Verdana' pointSize: 10!

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
packageGroupsVisible: false
#packageListVisible: true

#legal values are font name plus font point size
#font: <fontName pointSize>
#textFont: <fontName pointSize>

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
defaultFont!accessing!public! !
defaultTextFont!accessing!public! !
displayFontFrom:!public!utilities! !
initializeDefaultFonts!accessing!initializing!public! !
onSession:!instance creation!public! !
preferencesFile!public! !
preferencesFileDefaultContents!public! !
preferencesPath!public! !
public!public! !
!

