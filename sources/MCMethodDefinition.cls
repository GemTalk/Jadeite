"Filed out from Dolphin Smallalk"!

MCDefinition subclass: #MCMethodDefinition
	instanceVariableNames: 'classIsMeta source category selector className timeStamp'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
MCMethodDefinition guid: (GUID fromString: '{2fc81943-2846-4631-abf1-f40bd2da0274}')!
MCMethodDefinition comment: ''!
!MCMethodDefinition categoriesForClass!Unclassified! !
!MCMethodDefinition methodsFor!

category
	^category!

category: anObject
	category := anObject!

classIsMeta
	^classIsMeta!

className

	^className , (classIsMeta ifTrue: [' class'] ifFalse: ['']).
!

detailsString

	^category!

displayMemo

	^source.
!

displayText

	^category.
!

initialize: aStream
	| size |
	timeStamp := aStream upTo: Character tab.
	packageName := aStream upTo: Character tab.
	className := aStream upTo: Character tab.
	classIsMeta := (aStream upTo: Character tab) = 'true'.
	category := aStream upTo: Character tab.
	selector := aStream upTo: Character tab.
	size := (aStream upTo: Character tab) asNumber + 1.
	source := (aStream next: size) copyReplacing: Character cr withObject: Character lf.
	source := source copyFrom: 1 to: (source size - 1 max: 1)	"remove trailing lf"!

selector
	^selector!

source
	^source!

source: anObject
	source := anObject!

timeStamp
	^timeStamp! !
!MCMethodDefinition categoriesForMethods!
category!accessing!public! !
category:!public! !
classIsMeta!accessing!public! !
className!accessing!public! !
detailsString!public! !
displayMemo!public! !
displayText!public! !
initialize:!private! !
selector!accessing!public! !
source!accessing!public! !
source:!public! !
timeStamp!accessing!public! !
!

