"Filed out from Dolphin Smallalk"!

ChoicePrompter subclass: #TestChoicePrompter
	instanceVariableNames: ''
	classVariableNames: 'PlannedResult'
	poolDictionaries: ''
	classInstanceVariableNames: ''!
TestChoicePrompter guid: (GUID fromString: '{e6726740-a007-4764-8f16-cddc67ff1a91}')!
TestChoicePrompter comment: ''!
!TestChoicePrompter categoriesForClass!MVP-Presenters! !
!TestChoicePrompter methodsFor!

answer
	^self class plannedResult!

caption: ignore!

choices: anObject

	"ignore"!

model: anObject
	"ignore"

	!

newChoice
	self value: self class plannedResult!

newPrompt!

prompt: ignore!

showModalView

	"avoid raising the dialog window"! !
!TestChoicePrompter categoriesForMethods!
answer!public! !
caption:!public! !
choices:!public! !
model:!public! !
newChoice!public! !
newPrompt!public! !
prompt:!public! !
showModalView!public! !
!

!TestChoicePrompter class methodsFor!

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
!TestChoicePrompter class categoriesForMethods!
plannedResult!public! !
plannedResult:!public! !
!

