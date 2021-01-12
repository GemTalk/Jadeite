"Filed out from Dolphin Smalltalk 7"!

LibGciRpc64 subclass: #LibGciRpc64_3_7
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
LibGciRpc64_3_7 guid: (GUID fromString: '{f952a3d0-6164-4e54-afef-11482661ace1}')!
LibGciRpc64_3_7 comment: ''!
!LibGciRpc64_3_7 categoriesForClass!Unclassified! !
!LibGciRpc64_3_7 methodsFor!

errorStructureClass

	^GciErrSType64_31.
!

gciErr: errorReport

	<cdecl: bool GciErr GciErrSType64_31*>
	^self invalidCall
!

gsHasPragmas

	^true!

jadeServerClass

	^JadeServer64bit34
!

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
!LibGciRpc64_3_7 categoriesFor: #errorStructureClass!private! !
!LibGciRpc64_3_7 categoriesFor: #gciErr:!private! !
!LibGciRpc64_3_7 categoriesFor: #gsHasPragmas!public! !
!LibGciRpc64_3_7 categoriesFor: #jadeServerClass!public! !
!LibGciRpc64_3_7 categoriesFor: #session:execute:context:environment:!public!required! !
!LibGciRpc64_3_7 categoriesFor: #specialFromOop:!public! !

!LibGciRpc64_3_7 class methodsFor!

displayName

	^'64-bit 3.7.0 unreleased'.
!

fileNameSearch

	^'libgcirpc-3.7.0-32.dll'.
!

isRowanReady

	^true! !
!LibGciRpc64_3_7 class categoriesFor: #displayName!public! !
!LibGciRpc64_3_7 class categoriesFor: #fileNameSearch!public! !
!LibGciRpc64_3_7 class categoriesFor: #isRowanReady!public!testing! !

