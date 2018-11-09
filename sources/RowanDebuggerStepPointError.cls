"Filed out from Dolphin Smalltalk 7"!

Error subclass: #RowanDebuggerStepPointError
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanDebuggerStepPointError guid: (GUID fromString: '{6f572ac8-2ed4-4f1a-aab6-47e28ac6fb01}')!
RowanDebuggerStepPointError comment: ''!
!RowanDebuggerStepPointError categoriesForClass!Kernel-Exception Handling! !
!RowanDebuggerStepPointError methodsFor!

isNested
	"Override the super class implementation to recognize that
	this error will always have an outer handler that should 
	be ignored (GsError). But we should not ignore other errors"

	| env |
	env := Processor activeProcess exceptionEnvironment.
	[env isNil] whileFalse: 
			[(env actionFor: self) ifNotNil: [:action | action method methodClass = GsError ifFalse: [^true]].
			env := env outer].
	^false!

isResumable
	

	^true! !
!RowanDebuggerStepPointError categoriesFor: #isNested!public!testing! !
!RowanDebuggerStepPointError categoriesFor: #isResumable!public!testing! !

