"Filed out from Dolphin Smalltalk 7"!

Object subclass: #JadeiteSearch
	instanceVariableNames: 'view session stop start'
	classVariableNames: ''
	poolDictionaries: 'ScintillaConstants'
	classInstanceVariableNames: ''!
JadeiteSearch guid: (GUID fromString: '{76051fbb-0c1e-40b5-b560-8eef47e5711c}')!
JadeiteSearch comment: 'Derived from SmalltalkSearchPresenter'!
!JadeiteSearch categoriesForClass!MVP-Presenters! !
!JadeiteSearch methodsFor!

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
	self insertCompletion: aString at: anInteger.
	aValueHolder value: false!

onCharAdded: aCharacter
	aCharacter = Character cr ifFalse: [self startAutocompleteTimer]!

onTimerTick: anInteger
	anInteger == SCI_AUTOCSHOW ifFalse: [^self].
	self killAutocompleteTimer.
	self showCompletionList!

session: aSession
	session := aSession!

showCompletionList
	| searchList prefix |
	view selectionRange isEmpty ifFalse: [^self].
	stop := view caretPosition - 1.
	start := self tokenStartAt: stop.
	start = 0 ifTrue: [^self].
	prefix := view plainTextFrom: start to: stop. 
	searchList := prefix first isLowercase
				ifTrue: [JadePresenter symbolsFrom: prefix , '*' session: session]
				ifFalse: [JadePresenter allClassesStartingWith: prefix].	
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

tokenStartAt: anInteger
	^(view styleAt: anInteger) name == #specialCharacter
		ifTrue: [anInteger]
		ifFalse: [view tokenStartAt: anInteger]!

view: aView

	view := aView! !
!JadeiteSearch categoriesFor: #insertCompletion:at:!autocompletion!event handlers!private! !
!JadeiteSearch categoriesFor: #killAutocompleteTimer!autocompletion!private! !
!JadeiteSearch categoriesFor: #onAutoComplete:startingAt:accept:!autocompletion!event handlers!private! !
!JadeiteSearch categoriesFor: #onCharAdded:!autocompletion!event handlers!private! !
!JadeiteSearch categoriesFor: #onTimerTick:!autocompletion!event handlers!private! !
!JadeiteSearch categoriesFor: #session:!accessing!public! !
!JadeiteSearch categoriesFor: #showCompletionList!autocompletion!private! !
!JadeiteSearch categoriesFor: #showCompletionList:prefixLength:!autocompletion!private! !
!JadeiteSearch categoriesFor: #startAutocompleteTimer!autocompletion!event handlers!private! !
!JadeiteSearch categoriesFor: #tokenStartAt:!autocompletion!event handlers!private! !
!JadeiteSearch categoriesFor: #view:!accessing!public! !

!JadeiteSearch class methodsFor!

on: view session: session
	^self new
		view: view;
		session: session! !
!JadeiteSearch class categoriesFor: #on:session:!instance creation!public! !

