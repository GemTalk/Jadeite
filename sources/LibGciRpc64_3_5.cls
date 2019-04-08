"Filed out from Dolphin Smalltalk 7"!

LibGciRpc64 subclass: #LibGciRpc64_3_5
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
LibGciRpc64_3_5 guid: (GUID fromString: '{50640f87-32a5-4a8e-bd7c-6d4c072b87b7}')!
LibGciRpc64_3_5 comment: ''!
!LibGciRpc64_3_5 categoriesForClass!Unclassified! !
!LibGciRpc64_3_5 methodsFor!

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
!LibGciRpc64_3_5 categoriesFor: #errorStructureClass!private! !
!LibGciRpc64_3_5 categoriesFor: #gciErr:!private! !
!LibGciRpc64_3_5 categoriesFor: #gsHasPragmas!public! !
!LibGciRpc64_3_5 categoriesFor: #session:execute:context:environment:!public!required! !
!LibGciRpc64_3_5 categoriesFor: #specialFromOop:!public! !

!LibGciRpc64_3_5 class methodsFor!

displayName

	^'64-bit 3.5.0'.
!

fileNameSearch

	^'libgcirpc-3.5.0-32.dll'.
!

isRowanReady

	^true! !
!LibGciRpc64_3_5 class categoriesFor: #displayName!public! !
!LibGciRpc64_3_5 class categoriesFor: #fileNameSearch!public! !
!LibGciRpc64_3_5 class categoriesFor: #isRowanReady!public!testing! !

