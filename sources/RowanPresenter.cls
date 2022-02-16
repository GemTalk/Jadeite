"Filed out from Dolphin Smallalk"!

JadePresenterA subclass: #RowanPresenter
	instanceVariableNames: 'projectToolsOop'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanPresenter guid: (GUID fromString: '{470d7090-f9aa-42cf-95da-55ffdf27f367}')!
RowanPresenter comment: ''!
!RowanPresenter categoriesForClass!Unclassified! !
!RowanPresenter methodsFor!

defaultProjectName
	^'RowanProject'!

defaultSymbolDictionaryName

	^ 'Rowan_GUI_Data'
!

projectSpecOop

	^gciSession
		send: #spec
		to: self projectToolsOop.
!

projectToolsOop
	
	^projectToolsOop ifNil:[projectToolsOop := gciSession executeString: 'Rowan projectTools']! !
!RowanPresenter categoriesForMethods!
defaultProjectName!private! !
defaultSymbolDictionaryName!private! !
projectSpecOop!private! !
projectToolsOop!private! !
!

