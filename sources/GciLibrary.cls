"Filed out from Dolphin Smallalk"!

ExternalLibrary subclass: #GciLibrary
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
GciLibrary guid: (GUID fromString: '{ad9a79e0-d6ef-4d77-83fc-015b118b2331}')!
GciLibrary comment: ''!
!GciLibrary categoriesForClass!Unclassified! !
!GciLibrary methodsFor!

abortSession: anInteger

	self subclassResponsibility.
!

beginSession: anInteger

	self subclassResponsibility.
!

commitSession: anInteger

	self subclassResponsibility.
!

errorStructureClass

	self subclassResponsibility.
!

gsHasPragmas

	^false!

hardBreakSession: anInteger

	self subclassResponsibility.
!

loginHostUser: hostUser hostPassword: hostPassword gsUser: gsUser gsPassword: gsPassword gemNRS: gemString stoneNRS: stoneString

	self subclassResponsibility.
!

logoutSession: anInteger

	self subclassResponsibility.
!

nbResult

	self subclassResponsibility.
!

oopAsciiNul

	self subclassResponsibility.
!

oopAt: anExternalAddress

	self subclassResponsibility.
!

oopClassArray

	self subclassResponsibility.
!

oopClassByteArray

	self subclassResponsibility.
!

oopClassDoubleByteString

	self subclassResponsibility.
!

oopClassQuadByteString

	self subclassResponsibility.
!

oopClassString

	self subclassResponsibility.
!

oopClassSymbol

	self subclassResponsibility.
!

oopClassSystem

	self subclassResponsibility.
!

oopClassUnicode16

	self subclassResponsibility.
!

oopClassUnicode32

	self subclassResponsibility.
!

oopClassUnicode7

	self subclassResponsibility.
!

oopFalse

	self subclassResponsibility.
!

oopForInteger: anInteger

	self subclassResponsibility.
!

oopGemStoneError

	self subclassResponsibility.
!

oopIllegal

	self subclassResponsibility.
!

oopMaxSmallInteger

	self subclassResponsibility.
!

oopMinSmallInteger

	self subclassResponsibility.
!

oopMinusOne

	self subclassResponsibility.
!

oopNil

	self subclassResponsibility.
!

oopOne

	self subclassResponsibility.
!

oopRemoteNil

	self subclassResponsibility.
!

oopTrue

	self subclassResponsibility.
!

oopTwo

	self subclassResponsibility.
!

oopTypeArrayClass

	self subclassResponsibility.
!

oopTypeClass

	self subclassResponsibility.
!

oopTypeWithOop: anInteger

	self subclassResponsibility.
!

oopZero

	self subclassResponsibility.
!

pollForSignalSession: anInteger

	self subclassResponsibility.
!

sendInterpreted: aString to: anOopType with: anArray session: anInteger

	self subclassResponsibility.
!

session: session clearStack: processOop

	self subclassResponsibility.
!

session: session continue: gsProcessOop

	^self 
		session: session 
		continue: gsProcessOop 
		withObject: self oopIllegal
!

session: session continue: gsProcessOop withObject: anOop

	self subclassResponsibility.
!

session: session execute: stringOrOop context: contextOop

	self subclassResponsibility.
!

session: session execute: stringOrOop context: contextOop environment: anInteger

	self subclassResponsibility.
!

session: session fetchBytes: anOop

	self subclassResponsibility.
!

session: session oopForInteger: anInteger

	self subclassResponsibility.
!

session: session oopForString: aString

	self subclassResponsibility.
!

session: session releaseOops: oopList

	self subclassResponsibility.
!

session: anInteger send: aString to: anOopType with: anArray 

	self subclassResponsibility.
!

softBreakSession: anInteger

	self subclassResponsibility.
!

version

	self subclassResponsibility.
! !
!GciLibrary categoriesForMethods!
abortSession:!public!subclassResponsibility! !
beginSession:!public!subclassResponsibility! !
commitSession:!public!subclassResponsibility! !
errorStructureClass!private!subclassResponsibility! !
gsHasPragmas!public! !
hardBreakSession:!public!subclassResponsibility! !
loginHostUser:hostPassword:gsUser:gsPassword:gemNRS:stoneNRS:!public!subclassResponsibility! !
logoutSession:!public!subclassResponsibility! !
nbResult!public!subclassResponsibility! !
oopAsciiNul!public!Reserved OOPs!subclassResponsibility! !
oopAt:!public!subclassResponsibility! !
oopClassArray!public!Reserved OOPs!subclassResponsibility! !
oopClassByteArray!public!Reserved OOPs!subclassResponsibility! !
oopClassDoubleByteString!public!Reserved OOPs!subclassResponsibility! !
oopClassQuadByteString!public!Reserved OOPs!subclassResponsibility! !
oopClassString!public!Reserved OOPs!subclassResponsibility! !
oopClassSymbol!public!Reserved OOPs!subclassResponsibility! !
oopClassSystem!public!Reserved OOPs!subclassResponsibility! !
oopClassUnicode16!public!Reserved OOPs!subclassResponsibility! !
oopClassUnicode32!public!Reserved OOPs!subclassResponsibility! !
oopClassUnicode7!public!Reserved OOPs!subclassResponsibility! !
oopFalse!public!Reserved OOPs!subclassResponsibility! !
oopForInteger:!public!subclassResponsibility! !
oopGemStoneError!public!Reserved OOPs!subclassResponsibility! !
oopIllegal!public!Reserved OOPs!subclassResponsibility! !
oopMaxSmallInteger!public!Reserved OOPs!subclassResponsibility! !
oopMinSmallInteger!public!Reserved OOPs!subclassResponsibility! !
oopMinusOne!public!Reserved OOPs!subclassResponsibility! !
oopNil!public!Reserved OOPs!subclassResponsibility! !
oopOne!public!Reserved OOPs!subclassResponsibility! !
oopRemoteNil!public!Reserved OOPs!subclassResponsibility! !
oopTrue!public!Reserved OOPs!subclassResponsibility! !
oopTwo!public!Reserved OOPs!subclassResponsibility! !
oopTypeArrayClass!public!Reserved OOPs!subclassResponsibility! !
oopTypeClass!public!Reserved OOPs!subclassResponsibility! !
oopTypeWithOop:!public!subclassResponsibility! !
oopZero!public!Reserved OOPs!subclassResponsibility! !
pollForSignalSession:!public!subclassResponsibility! !
sendInterpreted:to:with:session:!public!subclassResponsibility! !
session:clearStack:!public!subclassResponsibility! !
session:continue:!public! !
session:continue:withObject:!public!subclassResponsibility! !
session:execute:context:!public!subclassResponsibility! !
session:execute:context:environment:!public!subclassResponsibility! !
session:fetchBytes:!public!Reserved OOPs!subclassResponsibility! !
session:oopForInteger:!public!subclassResponsibility! !
session:oopForString:!public!subclassResponsibility! !
session:releaseOops:!public!subclassResponsibility! !
session:send:to:with:!public!Reserved OOPs!subclassResponsibility! !
softBreakSession:!public!subclassResponsibility! !
version!public!subclassResponsibility! !
!

!GciLibrary class methodsFor!

addMissingMethods
	"The external function address is cached in the method and if it is inherited we will use the first one called.
	Having our own method allows us to have multiple libraries loaded and to call the proper function."

	SessionManager current class name == #'DevelopmentSessionManager' ifTrue: [^self].
	self allSelectors do: [:eachSelector |
		| class method |
		class := self whichClassIncludesSelector: eachSelector.
		class ~~ self ifTrue: [
			method := class methodDictionary at: eachSelector.
			method isExternalCall ifTrue: [
				self addSelector: eachSelector withMethod: method copy clear; yourself.
			].
		].
	].!

displayName

	^nil.
!

fileName

	| list |
	list := OrderedCollection new.
	File
		for: self fileNameSearch
		in: SessionManager current imageBase , 'bin'
		do: [:each | list add: each fileName].
	list := list reject: [:each | each = '.'].	"This is needed after upgrading to Fusion 2 beta 1"
	list isEmpty ifTrue: [self error: 'library not found!!'].
	^list first.
!

fileNameSearch

	self subclassResponsibility.
!

isRowanReady

	^false!

onStartup2

	default := nil.
!

open: pathString

	| currentWorkingDirectory result |
	(default notNil and: [default handle notNil]) ifTrue: [^default].
	self addMissingMethods.
	currentWorkingDirectory := File workingDirectory.
	[
		File workingDirectory: SessionManager current imageBase , 'bin'.
		result := super open: pathString.
		self default: result.
	] ensure: [
		File workingDirectory: currentWorkingDirectory.
	].
	^result.
!

sessionStarted
"
	GciLibrary sessionStarted.
"
	GciErrSType32 new.
	GciErrSType64 new.
	GciErrSType64_30 new.
	GciErrSType64_31 new.
	GciTsObjInfo new.
	OopType32Array new.
	OopType64Array new.
	OopType32 new.
	OopType64 new.
!

supportsRowanV30

	^false!

withDisplayName: aString

	^self allSubclasses detect: [:each | each displayName = aString].
! !
!GciLibrary class categoriesForMethods!
addMissingMethods!public! !
displayName!public! !
fileName!public! !
fileNameSearch!public! !
isRowanReady!public!testing! !
onStartup2!public! !
open:!public! !
sessionStarted!public! !
supportsRowanV30!public!testing! !
withDisplayName:!public! !
!

