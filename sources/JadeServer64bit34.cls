"Filed out from Dolphin Smalltalk 7"!

JadeServer64bit32 subclass: #JadeServer64bit34
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeServer64bit34 guid: (GUID fromString: '{1fe2384e-a7cc-4e95-8b1e-52399b34f562}')!
JadeServer64bit34 comment: ''!
!JadeServer64bit34 categoriesForClass!Unclassified! !
!JadeServer64bit34 methodsFor!

classOrganizer

	^ClassOrganizer newForEnvironment: environment
!

debugString: aString fromContext: anObject environment: anInteger
	"See String>>evaluateInContext:symbolList:"

	[
		^ (aString
			_compileInContext: anObject 
			symbolList: GsSession currentSession symbolList 
			oldLitVars: nil 
			environmentId: anInteger 
			flags: 0) 
			setBreakAtStepPoint: 1;
			_executeInContext: anObject
	] on: CompileWarning do: [:ex | 
		ex resume.
	].
!

executeString: aString fromContext: anObject environment: anInteger
	"See String>>evaluateInContext:symbolList:"

	[
		^ (aString
			_compileInContext: anObject 
			symbolList: GsSession currentSession symbolList 
			oldLitVars: nil 
			environmentId: anInteger 
			flags: 0)
			_executeInContext: anObject
	] on: CompileWarning do: [:ex | 
		ex resume.
	].
! !
!JadeServer64bit34 categoriesFor: #classOrganizer!public! !
!JadeServer64bit34 categoriesFor: #debugString:fromContext:environment:!public! !
!JadeServer64bit34 categoriesFor: #executeString:fromContext:environment:!public! !

