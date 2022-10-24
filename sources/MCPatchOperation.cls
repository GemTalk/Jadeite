"Filed out from Dolphin Smallalk"!

GsObject subclass: #MCPatchOperation
	instanceVariableNames: 'reverted'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
MCPatchOperation guid: (GUID fromString: '{656d8071-9137-4a7a-9aba-d0273ee9d33c}')!
MCPatchOperation comment: ''!
!MCPatchOperation categoriesForClass!Unclassified! !
!MCPatchOperation methodsFor!

<= aPatchOperation

	^self sortString <= aPatchOperation sortString.
!

className

	self subclassResponsibility.
!

hasEquivalentText

	^false.
!

initialize
	super initialize. 
	reverted := false. !

initialize: aStream session: aGciSession

	| string |
	gciSession := aGciSession.
	string := aStream upTo: Character tab.
	oopType := gciSession oopTypeWithOop: string asNumber.
	self initialize: aStream.
!

isRemoval

	^false!

modificationMemo

	^''.
!

modificationMemoMarkers

	^#().
!

modificationText

	^''.
!

obsoletionMemo

	^''.
!

obsoletionMemoMarkers

	^#().
!

obsoletionText

	^''.
!

reverted
	^reverted!

reverted: anObject
	reverted := anObject!

selector

	self subclassResponsibility.
!

sortString

	^self className , '>>' , self selector.
!

typeString
	"This browser is going away someday. Do ugly string parsing for now to make modifications that are reverted more visible"

	| typeString |
	typeString := self class name copyFrom: 3 to: self class name size.
	reverted ifTrue: [typeString := typeString , ' ' , '(reverted)'].
	^typeString! !
!MCPatchOperation categoriesForMethods!
<=!public! !
className!public! !
hasEquivalentText!public! !
initialize!initialization!public! !
initialize:session:!public! !
isRemoval!public! !
modificationMemo!public! !
modificationMemoMarkers!public! !
modificationText!public! !
obsoletionMemo!public! !
obsoletionMemoMarkers!public! !
obsoletionText!public! !
reverted!accessing!private! !
reverted:!accessing!private! !
selector!public! !
sortString!public! !
typeString!public! !
!

!MCPatchOperation class methodsFor!

fromStream: aStream session: aGciSession

	| char class |
	char := aStream next.
	aStream next.
	class := 
		char = $A ifTrue: [MCAddition] ifFalse: [
		char = $M ifTrue: [MCModification] ifFalse: [
		char = $R ifTrue: [MCRemoval] ifFalse: [
		self error: 'Invalid MCPatchOperation']]].
	^class new
		initialize: aStream
		session:  aGciSession.
! !
!MCPatchOperation class categoriesForMethods!
fromStream:session:!public! !
!

