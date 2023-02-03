"Filed out from Dolphin Smallalk"!

MCPatchOperation subclass: #MCRemoval
	instanceVariableNames: 'definition'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
MCRemoval guid: (GUID fromString: '{ba962c07-8639-4e40-89aa-6ce4eb10ab50}')!
MCRemoval comment: ''!
!MCRemoval categoriesForClass!Unclassified! !
!MCRemoval methodsFor!

className

	^definition className.
!

detailsString

	^definition detailsString.
!

isRemoval

	^true!

obsoletionMemo

	^definition displayMemo.
!

obsoletionText

	^definition displayText.
!

packageName

	^definition packageName.
!

selector

	^definition selector.
! !
!MCRemoval categoriesForMethods!
className!public! !
detailsString!public! !
isRemoval!public! !
obsoletionMemo!public! !
obsoletionText!public! !
packageName!public! !
selector!public! !
!

!MCRemoval class methodsFor!

icon
	"Answers an Icon that can be used to represent this class"
	^False icon! !
!MCRemoval class categoriesForMethods!
icon!public! !
!

