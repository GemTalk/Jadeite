"Filed out from Dolphin Smallalk"!

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
!

showCompileError: anArray

	| result string count textView selectionRange offset |
	textView := self view.
	offset := anArray at: 2.
	result := anArray at: 3.
	selectionRange := textView selectionRange.
	string := textView value.
	string := string copyFrom: selectionRange start to: selectionRange stop.
	string := string replaceCrLfWithLf copyFrom: 1 to: offset - 1.
	count := (string select: [:each | each = Character lf]) size.
	offset := offset + count.
	textView
		caretPosition: selectionRange start + offset - 1;
		replaceSelection: result;
		selectionStart: textView caretPosition - result size length: result size.! !
!JadeTextPresenter categoriesForMethods!
onViewOpened!public! !
selection!public! !
showCompileError:!private! !
!

