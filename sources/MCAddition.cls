"Filed out from Dolphin Smallalk"!

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

packageName
	^definition packageName!

selector

	^definition selector.
! !
!MCAddition categoriesForMethods!
className!public! !
detailsString!public! !
isMethod!public!testing! !
isMethodAddition!public!testing! !
modificationMemo!public! !
modificationText!public! !
packageName!public! !
selector!public! !
!

!MCAddition class methodsFor!

icon
	"Answers an Icon that can be used to represent this class"

	^(self environment at: #Icon) fromId: (File composeStem: 'CompiledMethod' extension: 'ico')! !
!MCAddition class categoriesForMethods!
icon!public! !
!

