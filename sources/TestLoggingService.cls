"Filed out from Dolphin Smalltalk 7"!

RowanLoggingService subclass: #TestLoggingService
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
TestLoggingService guid: (GUID fromString: '{cbd64604-4dc3-4d5d-ac98-debc8e0212f2}')!
TestLoggingService comment: ''!
!TestLoggingService categoriesForClass!Unclassified! !
!TestLoggingService methodsFor!

isTestLoggingService

	^true!

logComment: aString
	BrowserUpdate current logFileName: self testFilename.
	^super logComment: aString!

testFilename
	^'jadeiteTestFilename.txt'! !
!TestLoggingService categoriesFor: #isTestLoggingService!public!testing! !
!TestLoggingService categoriesFor: #logComment:!public! !
!TestLoggingService categoriesFor: #testFilename!private! !

!TestLoggingService class methodsFor!

newWithGroupId: integer logger: logger
	"Logger can decide what to do."

	^logger newWithGroupId: integer logger: logger! !
!TestLoggingService class categoriesFor: #newWithGroupId:logger:!instance creation!public! !

