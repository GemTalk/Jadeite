"Filed out from Dolphin Smalltalk 7"!

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
!TestMessageBox categoriesFor: #initialize!initialization!public! !
!TestMessageBox categoriesFor: #open!accessing!public! !
!TestMessageBox categoriesFor: #result!accessing!public! !

!TestMessageBox class methodsFor!

disableJadeiteTestMessageBox
	Smalltalk removeKey: #JadeiteTestsActive ifAbsent:[]!

enableJadeiteTestMessageBox
	Smalltalk at: #JadeiteTestsActive put: true!

lastMessageBox
	"store a copy of the last message box for testing"

	^LastMessageBox!

lastMessageBox: messageBox
	"store a copy of the last message box for testing"

	LastMessageBox := messageBox!

plannedResult
	"test needs to setup expected result each time.
	This helps ensure we don't leave a result hanging around
	causing unknown chaos."
	[^PlannedResult] ensure: [self plannedResult: nil]!

plannedResult: answer
	"tests can insert the desired result to simulate various
	MessageBox behaviors. Class variable is reset to nil after
	each use."

	PlannedResult := answer! !
!TestMessageBox class categoriesFor: #disableJadeiteTestMessageBox!actions!public! !
!TestMessageBox class categoriesFor: #enableJadeiteTestMessageBox!actions!public! !
!TestMessageBox class categoriesFor: #lastMessageBox!accessing!public! !
!TestMessageBox class categoriesFor: #lastMessageBox:!accessing!public! !
!TestMessageBox class categoriesFor: #plannedResult!accessing!public! !
!TestMessageBox class categoriesFor: #plannedResult:!accessing!public! !

