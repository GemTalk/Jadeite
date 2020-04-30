"Filed out from Dolphin Smalltalk 7"!

JadePresenterA subclass: #JadeiteCommandPresenter
	instanceVariableNames: 'commandLine codePane'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteCommandPresenter guid: (GUID fromString: '{2f2d61ed-c9e9-4155-87b6-23e1eb2f72c7}')!
JadeiteCommandPresenter comment: ''!
!JadeiteCommandPresenter categoriesForClass!Unclassified! !
!JadeiteCommandPresenter methodsFor!

are: switches legalIn: command
	switches do: [:switch | ((self switches at: command) includes: switch) ifFalse: [^false]].
	^true!

basicSubmitCommand: string
	| answeringService |
	(self isJadeiteCommand: string) ifTrue:[^self submitJadeiteCommand: string]. 
	[answeringService := RowanAnsweringService new
				command: #exec:;
				commandArgs: (Array with: string).
	BrowserUpdate current issueCommands: (Array with: answeringService) session: self gciSession]
			on: Error
			do: [:ex | ^ex messageText].
	^answeringService answer!

browse: substrings
	| answeringService newService |
	answeringService := RowanAnsweringService new
				command: #resolveAsService:;
				commandArgs: (Array with: substrings first).
	self issueCommand: (Array with: answeringService).
	newService := answeringService answer.
	newService ifNil: [^JadePresenter browseImplementorsOf: substrings first session: self gciSession].
	newService isProjectService ifTrue: [^JadeiteBrowser openOn: self gciSession project: newService].
	newService isPackageService ifTrue: [^JadeiteBrowser openOn: self gciSession package: newService].
	newService isDictionaryService
		ifTrue: [^JadeiteBrowser openOn: self gciSession dictionary: newService].
	newService isClassService ifTrue: [^JadeiteBrowser openOn: self gciSession class: newService]!

commandHelpStrings
	| writeStream |
	writeStream := WriteStream on: String new.
	writeStream
		nextPutAll: '"If a known command is not entered, input will be evaluated as an expression in the server."';
		cr;
		nextPutAll: 'Known Commands';
		cr.
	1 to: self commands size
		do: 
			[:index |
			writeStream
				nextPutAll: (self commandStrings at: index);
				nextPutAll: ' - ';
				nextPutAll: (self commandHelpText at: index).
			index = self commands size ifFalse: [writeStream cr]].
	^writeStream contents!

commandHelpText
	^self commands collect: [:array | array last]!

commands
	"Private - command with help text"

	| sorted |
	sorted := SortedCollection sortBlock: [:x :y | x first < y first].
	sorted
		addAll: #(#('browse' #browse: 'browse [gemstone_object_name] "browse project/package/class name"') #('imp' #implementors: 'imp [implementor_name] "browse implementors of selector"') #('send' #senders: 'send [sender_name] "browse senders of selector"') #('help' #help: 'help "command help"')).
	^sorted!

commandSelectors
	^self commands collect: [:array | array second]!

commandStrings
	^self commands collect: [:array | array first]!

createComponents
	super createComponents.
	commandLine := self add: JadeiteCommandLinePresenter new name: 'commandLine'.
	codePane := self add: CodeSourcePresenter new name: 'codePane'!

documentPresenter
	^codePane documentPresenter!

help: substrings
	^self commandHelpStrings!

implementors: substrings
	^JadePresenter browseImplementorsOf: substrings first session: self gciSession!

is: switch legalIn: command
	^(self switches at: command) includes: switch!

isJadeiteCommand: string
	string isEmpty ifTrue: [^false].
	^self commandStrings includes: string subStrings first!

onViewOpened
	super onViewOpened.
	self documentPresenter isReadOnly: true.
	commandLine setFocus!

selectorFromCommand: string
	^self commandSelectors at: (self commandStrings indexOf: string)!

senders: substrings
	^JadePresenter browseSendersOf: substrings first session: self gciSession!

submitCommand
	| result input |
	input := commandLine value.
	self documentPresenter view appendText: Character cr asString , '>' , commandLine value.
	self documentPresenter view moveToEndOfDocument.
	commandLine value: String new.
	commandLine setFocus.
	result := self basicSubmitCommand: input.
	self documentPresenter view appendText: Character cr asString , result.
	self documentPresenter view moveToEndOfDocument!

submitJadeiteCommand: string
	| selector substrings result |
	substrings := string subStrings.
	selector := self selectorFromCommand: string subStrings first.
	result := self perform: selector with: (substrings copyFrom: 2 to: substrings size).
	^(result isKindOf: String) ifTrue: [result] ifFalse: [result printString]!

switchArgumentPairsFrom: substrings
	"assume substrings format is switch/arg"

	^substrings fold: [:switch :arg | Array with: switch with: arg]!

switches
	| switches |
	switches := Dictionary new.
	switches at: #browse:
		put: (Array
				with: '-project'
				with: '-package'
				with: '-class'
				with: '-method').
	^switches!

switchesFrom: substrings
	^substrings select: [:substring | substring first = $-]! !
!JadeiteCommandPresenter categoriesFor: #are:legalIn:!public!testing! !
!JadeiteCommandPresenter categoriesFor: #basicSubmitCommand:!commands!public! !
!JadeiteCommandPresenter categoriesFor: #browse:!operations!public! !
!JadeiteCommandPresenter categoriesFor: #commandHelpStrings!accessing!command registry!private! !
!JadeiteCommandPresenter categoriesFor: #commandHelpText!accessing!command registry!private! !
!JadeiteCommandPresenter categoriesFor: #commands!command registry!private! !
!JadeiteCommandPresenter categoriesFor: #commandSelectors!accessing!command registry!private! !
!JadeiteCommandPresenter categoriesFor: #commandStrings!accessing!command registry!private! !
!JadeiteCommandPresenter categoriesFor: #createComponents!initialization!public! !
!JadeiteCommandPresenter categoriesFor: #documentPresenter!accessing!private! !
!JadeiteCommandPresenter categoriesFor: #help:!operations!public! !
!JadeiteCommandPresenter categoriesFor: #implementors:!operations!public! !
!JadeiteCommandPresenter categoriesFor: #is:legalIn:!public!testing! !
!JadeiteCommandPresenter categoriesFor: #isJadeiteCommand:!public!testing! !
!JadeiteCommandPresenter categoriesFor: #onViewOpened!event handlers!public! !
!JadeiteCommandPresenter categoriesFor: #selectorFromCommand:!command registry!private! !
!JadeiteCommandPresenter categoriesFor: #senders:!operations!public! !
!JadeiteCommandPresenter categoriesFor: #submitCommand!commands!public! !
!JadeiteCommandPresenter categoriesFor: #submitJadeiteCommand:!commands!public! !
!JadeiteCommandPresenter categoriesFor: #switchArgumentPairsFrom:!private!switches! !
!JadeiteCommandPresenter categoriesFor: #switches!private!switches! !
!JadeiteCommandPresenter categoriesFor: #switchesFrom:!private!switches! !

!JadeiteCommandPresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil nil 5 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.ReferenceView) 34 14 nil 416 34 2 8 1140850688 131073 544 nil 327686 ##(Smalltalk.Color) #default nil 5 nil nil nil 544 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.CodeSourcePresenter) #resource_Default_view nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 328198 ##(Smalltalk.Point) 1 1 786 701 451 544 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 94 1 0 0 225 0 0 0] 8 #() 786 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 946 #fixedParentRight 1 946 #fixedParentTop 1 946 #fixedParentBottom -49 410 ##(Smalltalk.TextEdit) 34 16 nil 416 34 2 8 1140916480 1025 1024 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 624 nil 5 nil nil nil 1024 nil 8 1650007552 852486 ##(Smalltalk.NullConverter) nil nil 5 674 138 144 34 2 738 #createAt:extent: 34 2 786 1 451 786 701 51 1024 738 #setMarginWidths: 34 1 8 #(3 3) 1024 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 225 0 0 0 94 1 0 0 250 0 0 0] 8 #() 896 nil 27 914 960 1 976 1 1008 -49 1008 1 170 192 34 4 544 8 'codePane' 1024 8 'commandLine' nil 674 138 144 34 1 738 #createAt:extent: 34 2 786 2879 21 786 701 501 416 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 159 5 0 0 10 0 0 0 253 6 0 0 4 1 0 0] 34 2 1024 544 896 nil 27 )! !
!JadeiteCommandPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

