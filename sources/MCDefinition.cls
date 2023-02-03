"Filed out from Dolphin Smallalk"!

Object subclass: #MCDefinition
	instanceVariableNames: 'packageName'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
MCDefinition guid: (GUID fromString: '{055475ac-74a4-4268-bbf9-805e3c53183b}')!
MCDefinition comment: ''!
!MCDefinition categoriesForClass!Unclassified! !
!MCDefinition methodsFor!

packageName
	^packageName!

packageName: anObject
	packageName := anObject!

selector

	^''.
! !
!MCDefinition categoriesForMethods!
packageName!accessing!private! !
packageName:!accessing!private! !
selector!public! !
!

!MCDefinition class methodsFor!

fromStream: aStream

	| char class |
	char := aStream next.
	aStream next.
	class := 
		char = $M ifTrue: [MCMethodDefinition] ifFalse: [
		char = $O ifTrue: [MCOrganizationDefinition] ifFalse: [
		char = $C ifTrue: [MCClassDefinition] ifFalse: [
		self error: 'Invalid MCDefinition']]].
	^class new
		initialize: aStream;
		yourself.
! !
!MCDefinition class categoriesForMethods!
fromStream:!public! !
!

