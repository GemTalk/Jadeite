"Filed out from Dolphin Smalltalk 7"!

MCPatchOperation subclass: #MCAddition
	instanceVariableNames: 'definition'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
MCAddition guid: (GUID fromString: '{b78cb54f-d86c-4398-a734-2c5cfa934104}')!
MCAddition comment: ''!
!MCAddition categoriesForClass!Unclassified! !
!MCAddition methodsFor!

className

	^definition className.
!

detailsString

	^definition detailsString.
!

isMethod
	^definition isMethodDefinition!

isMethodAddition
	^definition isMethodAddition!

modificationMemo

	^definition displayMemo.
!

modificationText

	^definition displayText.
!

selector

	^definition selector.
! !
!MCAddition categoriesFor: #className!public! !
!MCAddition categoriesFor: #detailsString!public! !
!MCAddition categoriesFor: #isMethod!public!testing! !
!MCAddition categoriesFor: #isMethodAddition!public!testing! !
!MCAddition categoriesFor: #modificationMemo!public! !
!MCAddition categoriesFor: #modificationText!public! !
!MCAddition categoriesFor: #selector!public! !

!MCAddition class methodsFor!

icon
	"Answers an Icon that can be used to represent this class"

	^(self environment at: #Icon) fromId: (File composeStem: 'CompiledMethod' extension: 'ico')! !
!MCAddition class categoriesFor: #icon!public! !

