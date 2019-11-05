"Filed out from Dolphin Smalltalk 7"!

Object subclass: #JadeiteSearch
	instanceVariableNames: 'view session stop start'
	classVariableNames: 'AllClassNames AllSelectors AutoCompleteEnabled'
	poolDictionaries: 'ScintillaConstants'
	classInstanceVariableNames: ''!
JadeiteSearch guid: (GUID fromString: '{76051fbb-0c1e-40b5-b560-8eef47e5711c}')!
JadeiteSearch comment: 'Derived from SmalltalkSearchPresenter'!
!JadeiteSearch categoriesForClass!MVP-Presenters! !
!JadeiteSearch methodsFor!

allClassesStartingWith: string
	| displayNames |
	AllClassNames ifNil: [self class initializeClassNamesIn: session].
	displayNames := AllClassNames select: [:className | className beginsWith: string].
	^displayNames!

insertCompletion: string at: anInteger
	| index |
	view performUndoableAction: 
			[stop := view caretPosition - 1.
			start := self tokenStartAt: stop.
			view selectionRange: (start to: stop).
			view replaceSelection: string.
			index := string indexOf: $:.
			index = 0 ifFalse: [view caretPosition: index + start]]!

killAutocompleteTimer
	view killTimer: SCI_AUTOCSHOW!

onAutoComplete: aString startingAt: anInteger accept: aValueHolder
	self class autoCompleteEnabled
		ifTrue: 
			[self insertCompletion: aString at: anInteger.
			aValueHolder value: false]!

onCharAdded: aCharacter
	self class autoCompleteEnabled
		ifTrue: [aCharacter = Character cr ifFalse: [self startAutocompleteTimer]]!

onTimerTick: anInteger
	self class autoCompleteEnabled
		ifTrue: 
			[anInteger == SCI_AUTOCSHOW ifFalse: [^self].
			self killAutocompleteTimer.
			self showCompletionList]!

session: aSession
	session := aSession!

showCompletionList
	| searchList prefix |
	view selectionRange isEmpty ifFalse: [^self].
	stop := view caretPosition - 1.
	start := self tokenStartAt: stop.
	start = 0 ifTrue: [^self].
	prefix := view plainTextFrom: start to: stop.
	searchList := (prefix first isLowercase or: [prefix first = $_])
				ifTrue: [self symbolsFrom: prefix]
				ifFalse: [self allClassesStartingWith: prefix].
	self showCompletionList: searchList prefixLength: prefix size!

showCompletionList: aCollection prefixLength: anInteger
	(aCollection size = 1 and: [aCollection anyOne size = anInteger])
		ifTrue: 
			["Don't display a list of one item that is the same as the prefix"
			^self].
	view
		showAutoCompletionList: aCollection
		prefixLength: anInteger
		withIcons: false!

startAutocompleteTimer
	view setTimer: SCI_AUTOCSHOW interval: 30!

symbolsFrom: selector
	AllSelectors ifNil: [self class initializeSelectorsIn: session].
	^AllSelectors select: [:symbol | symbol beginsWith: selector]!

tokenStartAt: anInteger
	^(view styleAt: anInteger) name == #specialCharacter
		ifTrue: [anInteger]
		ifFalse: 
			[| start1 tokenId styleId |
			tokenId := view styleIdAt: anInteger.
			start1 := anInteger.
			
			[styleId := view styleIdAt: start1 - 1.
			start1 > 1 and: [styleId == tokenId or: [styleId == 21	"#keywordMessage"]]]
					whileTrue: [start1 := start1 - 1].
			start1]!

view: aView

	view := aView! !
!JadeiteSearch categoriesFor: #allClassesStartingWith:!accessing!public! !
!JadeiteSearch categoriesFor: #insertCompletion:at:!autocompletion!private! !
!JadeiteSearch categoriesFor: #killAutocompleteTimer!autocompletion!private! !
!JadeiteSearch categoriesFor: #onAutoComplete:startingAt:accept:!autocompletion!event handlers!private! !
!JadeiteSearch categoriesFor: #onCharAdded:!autocompletion!event handlers!private! !
!JadeiteSearch categoriesFor: #onTimerTick:!autocompletion!event handlers!private! !
!JadeiteSearch categoriesFor: #session:!accessing!public! !
!JadeiteSearch categoriesFor: #showCompletionList!autocompletion!private! !
!JadeiteSearch categoriesFor: #showCompletionList:prefixLength:!autocompletion!private! !
!JadeiteSearch categoriesFor: #startAutocompleteTimer!autocompletion!private! !
!JadeiteSearch categoriesFor: #symbolsFrom:!accessing!public! !
!JadeiteSearch categoriesFor: #tokenStartAt:!autocompletion!private! !
!JadeiteSearch categoriesFor: #view:!accessing!public! !

!JadeiteSearch class methodsFor!

allClassNames
	^AllClassNames ifNil: [AllClassNames := OrderedCollection new]!

allSelectorSymbols
	^AllSelectors ifNil: [AllSelectors := OrderedCollection new]!

autoCompleteEnabled
	AutoCompleteEnabled ifNil: [AutoCompleteEnabled := false].
	^AutoCompleteEnabled!

autoCompleteEnabled: boolean
	AutoCompleteEnabled := boolean!

confirmAutoCompleteEnabled: boolean in: session
	"If the use chooses not to continue. Reset the value
	return the former value to the sending method."

	boolean
		ifTrue: 
			[(MessageBox
				confirm: 'Enabling auto complete requires symbols to be cached in the client. This can be a lengthy operation. Continue?')
					ifTrue: [Cursor wait showWhile: [self initializeAutocompleteSymbolsIn: session]]
					ifFalse: [^boolean not]].
	self autoCompleteEnabled: boolean.
	^boolean!

initializeAutocompleteSymbolsIn: session
	| service |
	service := RowanAnsweringService new
				command: #autocompleteSymbols;
				commandArgs: Array new.
	BrowserUpdate current issueCommand: (Array with: service) session: session.
	AllClassNames := service answer first.
	AllSelectors := service answer last!

initializeClassNamesIn: session
	| service |
	service := RowanAnsweringService new command: #allClassNames.
	service commandArgs: Array new.
	JadePresenter issueCommand: (Array with: service) session: session.
	AllClassNames := service answer asOrderedCollection!

initializeSelectorsIn: session
	| service |
	service := RowanAnsweringService new
				command: #sortedSymbols;
				commandArgs: Array new.
	BrowserUpdate current issueCommand: (Array with: service) session: session.
	AllSelectors := service answer asOrderedCollection!

on: view session: session
	^self new
		view: view;
		session: session!

selectorsFrom: partialSelector session: session
	AllSelectors ifNil: [self initializeSelectorsIn: session].
	^AllSelectors select: [:selector | partialSelector match: selector]!

updateAutocompleteSymbolsIn: session
	| service |
	service := RowanAnsweringService new
				command: #updateAutocompleteSymbols;
				commandArgs: Array new.
	BrowserUpdate current issueCommand: (Array with: service) session: session.
	AllClassNames addAll: service answer first.
	AllSelectors addAll: service answer last! !
!JadeiteSearch class categoriesFor: #allClassNames!accessing!public! !
!JadeiteSearch class categoriesFor: #allSelectorSymbols!accessing!public! !
!JadeiteSearch class categoriesFor: #autoCompleteEnabled!accessing!public! !
!JadeiteSearch class categoriesFor: #autoCompleteEnabled:!accessing!public! !
!JadeiteSearch class categoriesFor: #confirmAutoCompleteEnabled:in:!accessing!public! !
!JadeiteSearch class categoriesFor: #initializeAutocompleteSymbolsIn:!public!utilities! !
!JadeiteSearch class categoriesFor: #initializeClassNamesIn:!public!utilities! !
!JadeiteSearch class categoriesFor: #initializeSelectorsIn:!public!utilities! !
!JadeiteSearch class categoriesFor: #on:session:!instance creation!public! !
!JadeiteSearch class categoriesFor: #selectorsFrom:session:!accessing!public! !
!JadeiteSearch class categoriesFor: #updateAutocompleteSymbolsIn:!public!utilities! !

