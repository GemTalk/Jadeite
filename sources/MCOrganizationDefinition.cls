"Filed out from Dolphin Smallalk"!

MCDefinition subclass: #MCOrganizationDefinition
	instanceVariableNames: 'categories'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
MCOrganizationDefinition guid: (GUID fromString: '{80167200-683e-4723-81d0-1471bca0142b}')!
MCOrganizationDefinition comment: ''!
!MCOrganizationDefinition categoriesForClass!Unclassified! !
!MCOrganizationDefinition methodsFor!

className

	^''.
!

detailsString

	^'Class Categories'.
!

displayMemo

	| stream |
	stream := WriteStream on: String new.
	categories do: [:each | 
		stream nextPutAll: each; cr.
	].
	^stream contents.
!

displayText

	^'Class Categories'.
!

initialize: aStream

	categories := aStream nextLine subStrings: Character tab.
! !
!MCOrganizationDefinition categoriesForMethods!
className!public! !
detailsString!public! !
displayMemo!public! !
displayText!public! !
initialize:!public! !
!

