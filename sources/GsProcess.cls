"Filed out from Dolphin Smallalk"!

GsObject subclass: #GsProcess
	instanceVariableNames: 'stack type'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
GsProcess guid: (GUID fromString: '{0cb5149e-f4a3-413c-8ac6-2caf13e5fb15}')!
GsProcess comment: ''!
!GsProcess categoriesForClass!Unclassified! !
!GsProcess methodsFor!

description

	^gciSession printString: self oop.
!

frameForLevel: anInteger
 
	| string |
	anInteger = 0 ifTrue: [self error: 'No such frame level!!'].
	[
		string := gciSession 
			serverPerform: #'sourceForProcess:frame:'
			with: self 
			with: anInteger.
		(string beginsWith: '?????') ifTrue: [self error: (string copyFrom: 6 to: string size)].
	] on: Error do: [:ex | 
		MessageBox warning: 
'Error when attempting to read stack frame.
Maybe an object got an error on a #printString method.
' , ex description.
		SessionManager current pause.
		^nil.
	].
	^GsStackFrame
		fromStringXML: string
		session: gciSession.
!

gciSession: aGciSession 
	gciSession := aGciSession!

printOn: aStream

	aStream
		nextPutAll: 'aGsProcess(';
		print: oopType asInteger;
		nextPutAll: ((type isNil or: [type isEmpty]) ifTrue: [''] ifFalse: [', ' , type]);
		nextPut: $);
		yourself.
!

type
	^type!

type: anObject
	type := anObject! !
!GsProcess categoriesForMethods!
description!public! !
frameForLevel:!public! !
gciSession:!public! !
printOn:!public! !
type!accessing!public! !
type:!accessing!public! !
!

!GsProcess class methodsFor!

session: aGciSession oopType: anOopType

	^self new
		gciSession: aGciSession;
		oopType: anOopType; 
		yourself.
!

xmlBaseName

	^'process'.
! !
!GsProcess class categoriesForMethods!
session:oopType:!public! !
xmlBaseName!public! !
!

