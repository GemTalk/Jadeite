"Filed out from Dolphin Smallalk"!

RowanService subclass: #RowanQueryService
	instanceVariableNames: 'queryResults name'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanQueryService guid: (GUID fromString: '{b3af0738-b123-4ff6-8610-4344673a459d}')!
RowanQueryService comment: ''!
!RowanQueryService categoriesForClass!Unclassified! !
!RowanQueryService methodsFor!

answer
	^queryResults	!

displayName
	"for logging. for now"

	^name!

hasResults

	^queryResults notEmpty!

name
	^name!

name: aString
	name := aString asString!

queryResults
	^queryResults!

queryResults: anObject
	queryResults := anObject!

sortAspect

	^name! !
!RowanQueryService categoriesForMethods!
answer!accessing!private! !
displayName!displaying!public! !
hasResults!public!testing! !
name!accessing!public! !
name:!accessing!public! !
queryResults!accessing!private! !
queryResults:!accessing!private! !
sortAspect!accessing!public! !
!

