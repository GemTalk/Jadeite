"Filed out from Dolphin Smallalk"!

JadeShell subclass: #JadeiteServerFileBrowser
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteServerFileBrowser guid: (GUID fromString: '{70f59a0e-a3b1-4740-ab3e-4b15f70b06a0}')!
JadeiteServerFileBrowser comment: ''!
!JadeiteServerFileBrowser categoriesForClass!Unclassified! !
!JadeiteServerFileBrowser methodsFor!

presenterClass
	^JadeiteServerFilePresenter !

updateCaption
	self caption: (gciSession titleBarFor: 'Server File Browser')! !
!JadeiteServerFileBrowser categoriesForMethods!
presenterClass!accessing!public! !
updateCaption!public! !
!

