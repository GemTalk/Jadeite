"Filed out from Dolphin Smallalk"!

FileSaveDialog subclass: #TestFileSaveDialog
	instanceVariableNames: ''
	classVariableNames: 'LastMessageBox PlannedResult'
	poolDictionaries: ''
	classInstanceVariableNames: ''!
TestFileSaveDialog guid: (GUID fromString: '{b3db52db-6845-4520-a7ef-3df7a917fbb6}')!
TestFileSaveDialog comment: ''!
!TestFileSaveDialog categoriesForClass!MVP-Presenters! !
!TestFileSaveDialog methodsFor!

initialize
	self class lastMessageBox: self.
	^super initialize!

result
	^self class plannedResult!

showModal
	"don't open the dialog. Just send the result"

	^self result! !
!TestFileSaveDialog categoriesForMethods!
initialize!initialization!public! !
result!accessing!public! !
showModal!accessing!public! !
!

!TestFileSaveDialog class methodsFor!

disableJadeiteTestFileSaveDialog
	self plannedResult: OrderedCollection new.
	Smalltalk removeKey: #JadeiteTestsActive ifAbsent: []!

enableJadeiteTestFileSaveDialog
	Smalltalk at: #JadeiteTestsActive put: true.
	self plannedResult: OrderedCollection new!

lastMessageBox
	"store a copy of the last message box for testing"

	^LastMessageBox!

lastMessageBox: messageBox
	"store a copy of the last message box for testing"

	LastMessageBox := messageBox!

on: aModel
	"Answer an instance of the receiver not yet connected to any view
	but connected to aModel."

	^self basicNew
		on: aModel;
		yourself!

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
!TestFileSaveDialog class categoriesForMethods!
disableJadeiteTestFileSaveDialog!actions!public! !
enableJadeiteTestFileSaveDialog!actions!public! !
lastMessageBox!accessing!public! !
lastMessageBox:!accessing!public! !
on:!public! !
plannedResult!accessing!public! !
plannedResult:!accessing!public! !
!

