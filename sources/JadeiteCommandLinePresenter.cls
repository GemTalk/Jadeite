"Filed out from Dolphin Smalltalk 7"!

TextPresenter subclass: #JadeiteCommandLinePresenter
	instanceVariableNames: 'history historyIndex'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteCommandLinePresenter guid: (GUID fromString: '{2da019e6-c154-4325-8424-ae5ae11db5b4}')!
JadeiteCommandLinePresenter comment: ''!
!JadeiteCommandLinePresenter categoriesForClass!MVP-Presenters! !
!JadeiteCommandLinePresenter methodsFor!

initialize
	super initialize. 
	history := OrderedCollection new. 
	historyIndex := 0. !

onKeyPressed: aKeyEvent
	"Enter"

	aKeyEvent wParam = 13
		ifTrue: 
			[historyIndex := 0.
			history addFirst: self value.
			^self parentPresenter submitCommand].
	"Up Arrow"
	aKeyEvent wParam = 38
		ifTrue: 
			[historyIndex := historyIndex + 1 min: history size.
			self value: (history at: historyIndex)].
	"Down Arrow"
	aKeyEvent wParam = 40
		ifTrue: 
			[historyIndex = 1
				ifTrue: 
					[historyIndex := 0.
					^self value: String new].
			historyIndex := historyIndex - 1 max: 1.
			self value: (history at: historyIndex)]! !
!JadeiteCommandLinePresenter categoriesFor: #initialize!initialization!public! !
!JadeiteCommandLinePresenter categoriesFor: #onKeyPressed:!event handlers!public! !

