"Filed out from Dolphin Smalltalk 7"!

RowanService subclass: #RowanTestService
	instanceVariableNames: 'name'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanTestService guid: (GUID fromString: '{cbed4495-aa12-43d9-a2c3-31722275a0a8}')!
RowanTestService comment: 'Client test support service'!
!RowanTestService categoriesForClass!Unclassified! !
!RowanTestService methodsFor!

displayName
	"for logging. for now"

	^name!

execute: block overArrayOop: arrayOop session: session
	"assume the oop is an array with simple elements. 
	Evaluate the block for each element"

	| size theOop |
	theOop := OopType64 fromInteger: arrayOop.
	size := session
				executeString: 'self size'
				fromContext: theOop
				environment: 0.
	1 to: size
		do: 
			[:index |
			| remoteElement |
			remoteElement := session
						executeString: 'self at: ' , index printString
						fromContext: theOop
						environment: 0.
			block value: remoteElement]!

name
	^name!

name: aString
	name := aString asString!

remoteServiceClassNamesOop: session
	| answeringService |
	answeringService := RowanAnsweringService new.
	answeringService
		command: #exec:context:;
		commandArgs: (Array with: 'Rowan platform serviceClasses collect:[:cls | cls name]' with: session oopNil value).
	BrowserUpdate current issueCommand: answeringService session: session.
	^answeringService answer value "key is whether result compiled" !

sortAspect

	^name! !
!RowanTestService categoriesFor: #displayName!displaying!public! !
!RowanTestService categoriesFor: #execute:overArrayOop:session:!public! !
!RowanTestService categoriesFor: #name!accessing!public! !
!RowanTestService categoriesFor: #name:!accessing!public! !
!RowanTestService categoriesFor: #remoteServiceClassNamesOop:!public! !
!RowanTestService categoriesFor: #sortAspect!accessing!public! !

