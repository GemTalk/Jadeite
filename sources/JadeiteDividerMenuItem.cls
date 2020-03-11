"Filed out from Dolphin Smalltalk 7"!

DividerMenuItem subclass: #JadeiteDividerMenuItem
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteDividerMenuItem guid: (GUID fromString: '{422b7df0-1bc2-4078-9aee-4877906c9779}')!
JadeiteDividerMenuItem comment: 'Used as a marker for dynamic menus. Should only be one per menu.'!
!JadeiteDividerMenuItem categoriesForClass!MVP-Views-Support! !
!JadeiteDividerMenuItem methodsFor!

id
	"special identifier for building custom menus" 
	^#jadeiteDivider! !
!JadeiteDividerMenuItem categoriesFor: #id!accessing!public! !

!JadeiteDividerMenuItem class methodsFor!

separator
	^self basicNew
		flags: MFT_SEPARATOR;
		yourself! !
!JadeiteDividerMenuItem class categoriesFor: #separator!instance creation!public! !

