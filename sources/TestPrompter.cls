"Filed out from Dolphin Smallalk"!

Prompter subclass: #TestPrompter
	instanceVariableNames: ''
	classVariableNames: 'LastPrompt PlannedResult'
	poolDictionaries: ''
	classInstanceVariableNames: ''!
TestPrompter guid: (GUID fromString: '{b5c4525d-f1b1-422f-97b5-4896d8d2ecf7}')!
TestPrompter comment: ''!
!TestPrompter categoriesForClass!MVP-Presenters! !
!TestPrompter methodsFor!

answer
	^self class plannedResult!

caption: ignore!

prompt: thePrompt
	"save for testing" 
	LastPrompt := thePrompt !

showModalView

	"avoid raising the dialog window"! !
!TestPrompter categoriesForMethods!
answer!public! !
caption:!public! !
prompt:!public! !
showModalView!public! !
!

!TestPrompter class methodsFor!

lastPrompt
	"for testing"

	^LastPrompt!

plannedResult
	PlannedResult isEmpty ifTrue: [^nil].
	[^PlannedResult first] ensure: [PlannedResult removeFirstIfAbsent: []]!

plannedResult: answer
	"tests can insert the desired result to simulate various
	MessageBox behaviors. Class variable is reset to nil after
	each use. answer can be a collection or an object"

	(answer isKindOf: OrderedCollection)
		ifTrue: [PlannedResult := answer]
		ifFalse: [PlannedResult := OrderedCollection with: answer]! !
!TestPrompter class categoriesForMethods!
lastPrompt!accessing!public! !
plannedResult!public! !
plannedResult:!public! !
!

