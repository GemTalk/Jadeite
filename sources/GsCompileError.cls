"Filed out from Dolphin Smallalk"!

GsError subclass: #GsCompileError
	instanceVariableNames: 'list additionalArgs'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
GsCompileError guid: (GUID fromString: '{e49be376-e1af-4368-a429-b691f6e547ca}')!
GsCompileError comment: ''!
!GsCompileError categoriesForClass!Unclassified! !
!GsCompileError methodsFor!

additionalArgs
	^additionalArgs!

descriptiveText
	| writeStream |
	writeStream := WriteStream on: String new.
	writeStream
		nextPutAll: additionalArgs second;
		nextPutAll: '>>';
		nextPutAll: (additionalArgs first copyFrom: 2 to: list first second);
		space;
		nextPutAll: list first third;
		nextPutAll: '>>>>>';
		nextPutAll: (additionalArgs first copyFrom: list first second + 1 to: additionalArgs first size - 1).
	^writeStream contents!

gatherData
	super gatherData.
	list := self class errorListFor: gciErrSType args first inSession: self gciSession.
	gciErrSType args size > 1
		ifTrue: 
			[additionalArgs := OrderedCollection new.
			2 to: gciErrSType args size
				do: 
					[:index |
					additionalArgs add: (self gciSession
								executeString: 'self isString ifTrue:[self] ifFalse:[self printString]'
								fromContext: (gciErrSType args at: index)
								environment: 0)]]!

list

	^list.
! !
!GsCompileError categoriesForMethods!
additionalArgs!accessing!private! !
descriptiveText!accessing!public! !
gatherData!public! !
list!public! !
!

!GsCompileError class methodsFor!

wantsToHandle: aGciErrorSType session: aGciSession

	^aGciErrorSType isCompileErrorInSession: aGciSession.
! !
!GsCompileError class categoriesForMethods!
wantsToHandle:session:!public! !
!

