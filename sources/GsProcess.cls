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

