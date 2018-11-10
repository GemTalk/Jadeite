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
	"Answer whether the current exception currently being handled is within the scope of another
	handler for the same exception (i.e. if passed will be caught)."

	| env |
	env := Processor activeProcess exceptionEnvironment.
	[env isNil] whileFalse: 
			[(env actionFor: self)
				ifNotNil: 
					[:action |
					"This is a hacky bit of tomfoolery. Try to work around server step point bugs and still 
						allow tests to run
						not pass the error up to the error reporting entry point
						pass errors up to intended handlers. 

					Yuck"
					(action method methodClass ~= GsError and: [action method methodClass ~= TestResult]) ifTrue: [^true]].
			env := env outer].
	^false!

isResumable
	

	^true! !
!RowanDebuggerStepPointError categoriesFor: #isNested!public!testing! !
!RowanDebuggerStepPointError categoriesFor: #isResumable!public!testing! !

