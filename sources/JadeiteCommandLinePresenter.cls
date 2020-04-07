"Filed out from Dolphin Smalltalk 7"!

JadeAutoTextPresenter3 subclass: #JadeiteCommandLinePresenter
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteCommandLinePresenter guid: (GUID fromString: '{2da019e6-c154-4325-8424-ae5ae11db5b4}')!
JadeiteCommandLinePresenter comment: ''!
!JadeiteCommandLinePresenter categoriesForClass!MVP-Presenters! !
!JadeiteCommandLinePresenter methodsFor!

onKeyPressed: aKeyEvent
	aKeyEvent wParam = 13 ifTrue: [^self parentPresenter submitCommand].
	super onKeyPressed: aKeyEvent!

submitCommand

	^'Answer like a big-boy shell'! !
!JadeiteCommandLinePresenter categoriesFor: #onKeyPressed:!event handlers!public! !
!JadeiteCommandLinePresenter categoriesFor: #submitCommand!private! !

