"Filed out from Dolphin Smalltalk 7"!

TextPresenter subclass: #JadeTextPresenter
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeTextPresenter guid: (GUID fromString: '{483a5019-ce38-4f6a-b12d-d39804fc00f4}')!
JadeTextPresenter comment: ''!
!JadeTextPresenter categoriesForClass!Unclassified! !
!JadeTextPresenter methodsFor!

onViewOpened
	super onViewOpened.
	(view isKindOf: ScintillaView) ifFalse: [^self].
	view textStyles: JadeiteTextStyles default textStyles.
	view indicatorStyles: JadeiteTextStyles default defaultIndicatorStyles!

selection

	^view selection.
! !
!JadeTextPresenter categoriesFor: #onViewOpened!public! !
!JadeTextPresenter categoriesFor: #selection!public! !

