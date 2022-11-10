"Filed out from Dolphin Smallalk"!

JadeiteServerFileSaveDialog subclass: #JadeiteServerFileSaveTestDialog
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteServerFileSaveTestDialog guid: (GUID fromString: '{29abcc58-cd29-4a02-aa45-74a065ac921a}')!
JadeiteServerFileSaveTestDialog comment: ''!
!JadeiteServerFileSaveTestDialog categoriesForClass!Unclassified! !
!JadeiteServerFileSaveTestDialog methodsFor!

showModal
	^self show! !
!JadeiteServerFileSaveTestDialog categoriesForMethods!
showModal!displaying!public! !
!

!JadeiteServerFileSaveTestDialog class methodsFor!

showOnSession: aGciSession initialFileName: fileName
	"just return the dialog, not the answer for testing" 
	| inst |
	inst := self instantiateOnSession: aGciSession initialFileName: fileName.
	^inst showModal! !
!JadeiteServerFileSaveTestDialog class categoriesForMethods!
showOnSession:initialFileName:!instance creation!public! !
!

