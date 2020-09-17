"Filed out from Dolphin Smalltalk 7"!

RowanVariableService subclass: #RowanDisplayLabelVariableService
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanDisplayLabelVariableService guid: (GUID fromString: '{0415affc-2fc9-4b4c-bd38-3d28ffd10c10}')!
RowanDisplayLabelVariableService comment: 'Not a true service. Used for displaying column headers in the debugger''s variable pane'!
!RowanDisplayLabelVariableService categoriesForClass!Kernel-Objects! !
!RowanDisplayLabelVariableService methodsFor!

_key
	^String new!

displayOop

	^String new!

displayStringOn: displayThing
	displayThing font beItalic.
	displayThing forecolor: Color blue!

initialize

	super initialize. 
	oop := nil. 
	value := nil. !

isDisplayLabel

	^true!

value: aString
	value := aString! !
!RowanDisplayLabelVariableService categoriesFor: #_key!accessing!public! !
!RowanDisplayLabelVariableService categoriesFor: #displayOop!printing!public! !
!RowanDisplayLabelVariableService categoriesFor: #displayStringOn:!printing!public! !
!RowanDisplayLabelVariableService categoriesFor: #initialize!initialization!public! !
!RowanDisplayLabelVariableService categoriesFor: #isDisplayLabel!public!testing! !
!RowanDisplayLabelVariableService categoriesFor: #value:!accessing!public! !

