"Filed out from Dolphin Smalltalk 7"!

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
!RowanQueryService categoriesFor: #answer!accessing!private! !
!RowanQueryService categoriesFor: #displayName!displaying!public! !
!RowanQueryService categoriesFor: #hasResults!public!testing! !
!RowanQueryService categoriesFor: #name!accessing!public! !
!RowanQueryService categoriesFor: #name:!accessing!public! !
!RowanQueryService categoriesFor: #queryResults!accessing!private! !
!RowanQueryService categoriesFor: #queryResults:!accessing!private! !
!RowanQueryService categoriesFor: #sortAspect!accessing!public! !

