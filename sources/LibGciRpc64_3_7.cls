"Filed out from Dolphin Smalltalk 7"!

LibGciRpc64 subclass: #LibGciRpc64_3_7
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
LibGciRpc64_3_7 guid: (GUID fromString: '{9239dae2-1e22-4497-b848-2ca0c34552a5}')!
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

gciNbExecuteStrContextDbg: string _: sourceSize _: sourceClass _: context _: symbolList _: flags
	"In 3.7, GciNbExecuteStrContextDbg_ supports client user actions, but GciNbExecuteStrFromContext does not" 
	<cdecl: void GciNbExecuteStrFromContextDbg lpstr sqword OopType64 OopType64 OopType64 word>
	^self invalidCall!

gciNbExecuteStrContextDbg_: string _: sourceSize _: sourceClass _: context _: symbolList _: flags _: environmentId
	"In 3.7, GciNbExecuteStrContextDbg_ supports client user actions, but GciNbExecuteStrFromContext does not" 
	<cdecl: void GciNbExecuteStrFromContextDbg_ lpstr dword OopType64  OopType64  OopType64  sdword  word>
	^self invalidCall!

gsHasPragmas

	^true!

jadeServerClass

	^JadeServer64bit34
!

session: session execute: string context: contextOop environment: anInteger
	"environment in Jadeite is always 0" 
	^self
		session: session
		execute: string
		context: contextOop
		symbolList: self oopNil!

session: session execute: string context: contextOop symbolList: symbolList
	^self
		session: session
		execute: string
		context: contextOop
		symbolList: symbolList
		flags: 1	"GCI_PERFORM_FLAG_ENABLE_DEBUG = 1"!

session: session execute: string context: contextOop symbolList: symbolList flags: flags
	self critical: 
			[self gciSetSessionId: session. 
			self
				gciNbExecuteStrContextDbg: string
				_: string size
				_: self stringClassOop
				_: contextOop
				_: symbolList
				_: flags.
			^self nbResult]!

session: anInteger send: aString to: anOopType with: anArray
	"GciNbPerformNoDebug supports client user actions in 3.7. GciNbPerform does not"
	self critical: [
		self gciSetSessionId: anInteger.
		self
			gciNbPerformNoDebug: anOopType 
			_: aString 
			_: anArray 
			_: anArray size
			_: 16r21.		"GCI_PERFORM_FLAG_ENABLE_DEBUG + GCI_PERFORM_FLAG_INTERPRETED"
		^self nbResult.
	].
!

specialFromOop: anOop

	anOop isSmallFraction ifTrue: [
		^anOop asFraction.
	].
	^super specialFromOop: anOop
!

stringClassOop
	^OopType64 fromInteger: 74753 "16r12401"! !
!LibGciRpc64_3_7 categoriesFor: #errorStructureClass!public! !
!LibGciRpc64_3_7 categoriesFor: #gciErr:!public! !
!LibGciRpc64_3_7 categoriesFor: #gciNbExecuteStrContextDbg:_:_:_:_:_:!public! !
!LibGciRpc64_3_7 categoriesFor: #gciNbExecuteStrContextDbg_:_:_:_:_:_:_:!public! !
!LibGciRpc64_3_7 categoriesFor: #gsHasPragmas!public! !
!LibGciRpc64_3_7 categoriesFor: #jadeServerClass!public! !
!LibGciRpc64_3_7 categoriesFor: #session:execute:context:environment:!public! !
!LibGciRpc64_3_7 categoriesFor: #session:execute:context:symbolList:!public! !
!LibGciRpc64_3_7 categoriesFor: #session:execute:context:symbolList:flags:!public! !
!LibGciRpc64_3_7 categoriesFor: #session:send:to:with:!public! !
!LibGciRpc64_3_7 categoriesFor: #specialFromOop:!public! !
!LibGciRpc64_3_7 categoriesFor: #stringClassOop!public! !

!LibGciRpc64_3_7 class methodsFor!

displayName

	^'64-bit 3.7.0'.
!

fileNameSearch

	^'libgcirpc-3.7.0-32.dll'.
!

isRowanReady

	^true! !
!LibGciRpc64_3_7 class categoriesFor: #displayName!public! !
!LibGciRpc64_3_7 class categoriesFor: #fileNameSearch!public! !
!LibGciRpc64_3_7 class categoriesFor: #isRowanReady!public! !

