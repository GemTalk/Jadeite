"Filed out from Dolphin Smalltalk 7"!

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
!GsCompileError categoriesFor: #additionalArgs!accessing!private! !
!GsCompileError categoriesFor: #descriptiveText!accessing!public! !
!GsCompileError categoriesFor: #gatherData!public! !
!GsCompileError categoriesFor: #list!public! !

!GsCompileError class methodsFor!

errorListFor: anOop inSession: aGciSession
 
	| result list |
	result := aGciSession
		serverPerform: #'errorListFor:'
		with: anOop.
	list := result subStrings: Character lf.
	list := list collect: [:each | each , '	' subStrings: Character tab].
	list := list collect: [:each | 
		Array
			with: (each at: 1) asNumber
			with: (each at: 2) asNumber
			with: (each at: 3).
	].
	^list.
!

wantsToHandle: aGciErrorSType session: aGciSession

	^aGciErrorSType isCompileErrorInSession: aGciSession.
! !
!GsCompileError class categoriesFor: #errorListFor:inSession:!public! !
!GsCompileError class categoriesFor: #wantsToHandle:session:!public! !

