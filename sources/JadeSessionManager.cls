"Filed out from Dolphin Smalltalk 7"!

RuntimeSessionManager subclass: #JadeSessionManager
	instanceVariableNames: ''
	classVariableNames: 'Version'
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeSessionManager guid: (GUID fromString: '{8d7a4642-b8e1-43ea-94d5-e13390ca1f79}')!
JadeSessionManager comment: ''!
!JadeSessionManager categoriesForClass!Unclassified! !
!JadeSessionManager methodsFor!

defaultResLibPath
	"Answer the path of the development resource library."

	^'bin\Jade'!

logError: exception
	| fileStream timestampString |
	timestampString := self class stackDumpTimeStampString.	"print the same string at the beginning and end for easier searching"
	fileStream := FileStream write: self errorLogName mode: #append.
	[self class prependStackStartMessage: timestampString on: fileStream] ensure: [fileStream close].
	super logError: exception.
	fileStream := FileStream write: self errorLogName mode: #append.
	[self class appendStackEndMessage: timestampString on: fileStream] ensure: [fileStream close]!

main
"
	JadeSessionManager basicNew main.
"
	Keyboard default isShiftDown 
		ifTrue: [self mainShellClass show: 'Compact view']
		ifFalse: [self mainShellClass show].
!

pause

	Keyboard default isShiftDown ifTrue: [self error: 'Generate walkback!!'].
!

version

	^Version notNil 
		ifTrue: [Version]
		ifFalse: ['(Development)'].
! !
!JadeSessionManager categoriesFor: #defaultResLibPath!public! !
!JadeSessionManager categoriesFor: #logError:!public! !
!JadeSessionManager categoriesFor: #main!public! !
!JadeSessionManager categoriesFor: #pause!public! !
!JadeSessionManager categoriesFor: #version!public! !

!JadeSessionManager class methodsFor!

appendStackEndMessage: timeStampString on: fileStream
	fileStream
		nextPutAll: '***** Ending Dolphin stack dump started at ';
		nextPutAll: timeStampString;
		nextPutAll: ' *****';
		cr!

getVersion

	| string |
	string := [SessionManager current class git: 'describe'] on: ExternalProcessExecuteError do: [:ex | ^'???'].
	^(ReadStream on: string) nextLine
!

prependStackStartMessage: timeStampString on: fileStream
	fileStream
		nextPutAll: '***** Starting Dolphin stack dump at ';
		nextPutAll: timeStampString;
		nextPutAll: ' *****';
		cr!

sessionStarted

	ScintillaLibrary open: 'bin\SciLexer.dll'.
	GciLibrary sessionStarted.!

shortVersion
	^(ReadStream on: self version) upTo: $-!

stackDumpTimeStampString
	^Time now printString , ' ' , Date today shortString!

version

	^Version notNil 
		ifTrue: [Version]
		ifFalse: ['(Development)'].
! !
!JadeSessionManager class categoriesFor: #appendStackEndMessage:on:!public!stack dumping support! !
!JadeSessionManager class categoriesFor: #getVersion!public! !
!JadeSessionManager class categoriesFor: #prependStackStartMessage:on:!public!stack dumping support! !
!JadeSessionManager class categoriesFor: #sessionStarted!public! !
!JadeSessionManager class categoriesFor: #shortVersion!public! !
!JadeSessionManager class categoriesFor: #stackDumpTimeStampString!public!stack dumping support! !
!JadeSessionManager class categoriesFor: #version!public! !

