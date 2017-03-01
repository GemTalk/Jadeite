"Filed out from Dolphin Smalltalk 7"!

Object subclass: #JadeAbstractHistoryEntry
	instanceVariableNames: 'methodName className classCategory'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeAbstractHistoryEntry guid: (GUID fromString: '{66B233A5-1D07-47F6-B050-BA3EBDBA62A0}')!
JadeAbstractHistoryEntry comment: ''!
!JadeAbstractHistoryEntry categoriesForClass!Unclassified! !
!JadeAbstractHistoryEntry methodsFor!

classCategory
	^classCategory!

classCategory: anObject
	classCategory := anObject!

className
	^className!

className: anObject
	className := anObject!

getClassName
	"<className> is anArray with all hierarchy names"

	(className isKindOf: String) ifTrue: [^className].

	(className isNil or: [className isEmpty]) ifTrue: [^''].

	^className last!

getMethodName
	"<methodName> is anArray with different GemStone values"

	(methodName isKindOf: String) ifTrue: [^methodName].

	(methodName isNil or: [methodName isEmpty]) ifTrue: [^''].

	^methodName first!

methodName
	^methodName!

methodName: anObject
	methodName := anObject! !
!JadeAbstractHistoryEntry categoriesFor: #classCategory!accessing!private! !
!JadeAbstractHistoryEntry categoriesFor: #classCategory:!accessing!private! !
!JadeAbstractHistoryEntry categoriesFor: #className!accessing!private! !
!JadeAbstractHistoryEntry categoriesFor: #className:!accessing!private! !
!JadeAbstractHistoryEntry categoriesFor: #getClassName!public! !
!JadeAbstractHistoryEntry categoriesFor: #getMethodName!public! !
!JadeAbstractHistoryEntry categoriesFor: #methodName!accessing!private! !
!JadeAbstractHistoryEntry categoriesFor: #methodName:!accessing!private! !
