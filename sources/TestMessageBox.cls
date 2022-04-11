"Filed out from Dolphin Smallalk"!

MessageBox subclass: #TestMessageBox
	instanceVariableNames: ''
	classVariableNames: 'LastMessageBox PlannedResult'
	poolDictionaries: ''
	classInstanceVariableNames: ''!
TestMessageBox guid: (GUID fromString: '{f514e15b-9c9a-46e2-98c3-1de5dc78c906}')!
TestMessageBox comment: ''!
!TestMessageBox categoriesForClass!MVP-Views-Support! !
!TestMessageBox methodsFor!

initialize
	self class lastMessageBox: self.
	^super initialize!

open
	"don't open the dialog. Just send the result"

	^self result!

result
	^self class plannedResult! !
!TestMessageBox categoriesForMethods!
initialize!initialization!public! !
open!accessing!public! !
result!accessing!public! !
!

!TestMessageBox class methodsFor!

disableJadeiteTestMessageBox
	self plannedResult: OrderedCollection new.
	Smalltalk removeKey: #JadeiteTestsActive ifAbsent: []!

enableJadeiteTestMessageBox
	Smalltalk at: #JadeiteTestsActive put: true.
	self plannedResult: OrderedCollection new!

lastMessageBox
	"store a copy of the last message box for testing"

	^LastMessageBox!

lastMessageBox: messageBox
	"store a copy of the last message box for testing"

	LastMessageBox := messageBox!

plannedResult
	PlannedResult isEmpty ifTrue: [^nil].
	[^PlannedResult first] ensure: [PlannedResult removeFirstIfAbsent: []]!

plannedResult: answer
	"tests can insert the desired result to simulate various
	MessageBox behaviors. Class variable is reset to nil after
	each use.
	answer can be a collection or an object"

	(answer isKindOf: OrderedCollection)
		ifTrue: [PlannedResult := answer]
		ifFalse: [PlannedResult := OrderedCollection with: answer]! !
!TestMessageBox class categoriesForMethods!
disableJadeiteTestMessageBox!actions!public! !
enableJadeiteTestMessageBox!actions!public! !
lastMessageBox!accessing!public! !
lastMessageBox:!accessing!public! !
plannedResult!accessing!public! !
plannedResult:!accessing!public! !
!

