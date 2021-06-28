"Filed out from Dolphin Smalltalk 7"!

LibGciRpc64 subclass: #LibGciRpc64_3_6
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
LibGciRpc64_3_6 guid: (GUID fromString: '{f369c77a-c6b5-44d4-a169-0572fc0659b1}')!
LibGciRpc64_3_6 comment: ''!
!LibGciRpc64_3_6 categoriesForClass!Unclassified! !
!LibGciRpc64_3_6 methodsFor!

errorStructureClass

	^GciErrSType64_31.
!

gciErr: errorReport

	<cdecl: bool GciErr GciErrSType64_31*>
	^self invalidCall
!

gsHasPragmas

	^true!

session: session execute: stringOrOop context: contextOop environment: anInteger

	self critical: [
		self gciSetSessionId: session.
		self
			gciNbExecuteStrFromContext_: stringOrOop
			_: contextOop
			_: self oopNil
			_: anInteger.
		^self nbResult.
	].
!

specialFromOop: anOop

	anOop isSmallFraction ifTrue: [
		^anOop asFraction.
	].
	^super specialFromOop: anOop
! !
!LibGciRpc64_3_6 categoriesFor: #errorStructureClass!private! !
!LibGciRpc64_3_6 categoriesFor: #gciErr:!private! !
!LibGciRpc64_3_6 categoriesFor: #gsHasPragmas!public! !
!LibGciRpc64_3_6 categoriesFor: #session:execute:context:environment:!public!required! !
!LibGciRpc64_3_6 categoriesFor: #specialFromOop:!public! !

!LibGciRpc64_3_6 class methodsFor!

displayName

	^'64-bit 3.6.0'.
!

fileNameSearch

	^'libgcirpc-3.6.0-32.dll'.
!

isRowanReady

	^true! !
!LibGciRpc64_3_6 class categoriesFor: #displayName!public! !
!LibGciRpc64_3_6 class categoriesFor: #fileNameSearch!public! !
!LibGciRpc64_3_6 class categoriesFor: #isRowanReady!public!testing! !

