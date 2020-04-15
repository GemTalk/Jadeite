"Filed out from Dolphin Smalltalk 7"!

RowanService subclass: #RowanAnsweringService
	instanceVariableNames: 'answer'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanAnsweringService guid: (GUID fromString: '{d2ef2348-8273-4df1-b823-ba4509d53308}')!
RowanAnsweringService comment: 'An answer service doesn''t understand any update commands. 
He just responds with an answer object. '!
!RowanAnsweringService categoriesForClass!Kernel-Objects! !
!RowanAnsweringService methodsFor!

answer
	^answer!

answer: anObject
	answer := anObject!

autoCommitIn: session
	command := #autoCommit.
	BrowserUpdate current issueCommands: (Array with: self) session: session.
	^answer!

breakPointsAreEnabled: session
	command := #breakPointsAreEnabled.
	BrowserUpdate current issueCommands: (Array with: self) session: session.
	^answer!

breakpointSettingChanged: transcript
	updateType
		ifNotNil: 
			[transcript areBreakpointsEnabled value: answer.
			BrowserUpdate current breakpointsEnabled: answer]!

canAccessServiceClasses: session
	command := #canAccessServiceClasses.
	self commandArgs: Array new.
	BrowserUpdate current issueCommands: (Array with: self) session: session.
	^answer!

exec: string in: session
	command := #exec:.
	commandArgs := Array with: string.
	BrowserUpdate current issueCommands: (Array with: self) session: session!

expressionSelector: string session: session
	command := #expressionSelector:.
	commandArgs := Array with: string.
	BrowserUpdate current issueCommands: (Array with: self) session: session.
	^answer!

flipAutoCommitFor: session
	command := #flipAutoCommit.
	BrowserUpdate current issueCommands: (Array with: self) session: session.
	^answer!

flipTranscriptIn: session
	command := #flipTranscript.
	BrowserUpdate current issueCommands: (Array with: self) session: session!

isAnsweringService

	^true!

isTranscriptInstalledIn: session
	command := #transcriptInstalled.
	BrowserUpdate current issueCommands: (Array with: self) session: session.
	^answer!

lowercaseSelectorsMatching: string session: session
	"sender should pass in lowercase string which will be 
	compared to lowercase on the server. Avoids case misses"

	command := #lowercaseSelectorsMatching:.
	commandArgs := Array with: string.
	BrowserUpdate current issueCommands: (Array with: self) session: session.
	^answer!

needsCommit: session
	command := #needsCommit.
	self commandArgs: Array new.
	BrowserUpdate current issueCommands: (Array with: self) session: session.
	^answer!

printOn: stream
	stream
		nextPutAll: self class name;
		space;
		nextPut: $(;
		nextPutAll: command printString;
		nextPutAll: '->';
		nextPutAll: commandArgs printString;
		nextPut: $)!

setAutoCommit: boolean for: session
	command := #setAutoCommit:.
	self commandArgs: (Array with: boolean).
	BrowserUpdate current issueCommands: (Array with: self) session: session.
	^answer!

setBreakpointsEnabled: boolean session: session
	command := #setBreakPointsAreEnabled:.
	commandArgs := Array with: boolean.
	BrowserUpdate current issueCommands: (Array with: self) session: session!

symbolExists: aSymbol session: session
	command := #symbolExists:.
	commandArgs := Array with: aSymbol.
	BrowserUpdate current issueCommands: (Array with: self) session: session.
	^answer!

symbolsMatching: string session: session
	command := #symbolsMatching:.
	commandArgs := Array with: string.
	BrowserUpdate current issueCommands: (Array with: self) session: session.
	^answer!

updateSymbols: unused
	updateType = #updateSymbols: ifFalse: [^self].
	JadeiteSearch allClassNames addAll: answer first.
	JadeiteSearch allSelectors addAll: answer last! !
!RowanAnsweringService categoriesFor: #answer!accessing!private! !
!RowanAnsweringService categoriesFor: #answer:!accessing!private! !
!RowanAnsweringService categoriesFor: #autoCommitIn:!commands!public! !
!RowanAnsweringService categoriesFor: #breakPointsAreEnabled:!commands!public! !
!RowanAnsweringService categoriesFor: #breakpointSettingChanged:!public!updating! !
!RowanAnsweringService categoriesFor: #canAccessServiceClasses:!commands!public! !
!RowanAnsweringService categoriesFor: #exec:in:!commands!public! !
!RowanAnsweringService categoriesFor: #expressionSelector:session:!commands!public! !
!RowanAnsweringService categoriesFor: #flipAutoCommitFor:!commands!public! !
!RowanAnsweringService categoriesFor: #flipTranscriptIn:!commands!public! !
!RowanAnsweringService categoriesFor: #isAnsweringService!public!testing! !
!RowanAnsweringService categoriesFor: #isTranscriptInstalledIn:!commands!public! !
!RowanAnsweringService categoriesFor: #lowercaseSelectorsMatching:session:!commands!public!testing! !
!RowanAnsweringService categoriesFor: #needsCommit:!commands!public! !
!RowanAnsweringService categoriesFor: #printOn:!printing!public! !
!RowanAnsweringService categoriesFor: #setAutoCommit:for:!commands!public! !
!RowanAnsweringService categoriesFor: #setBreakpointsEnabled:session:!commands!public! !
!RowanAnsweringService categoriesFor: #symbolExists:session:!commands!public!testing! !
!RowanAnsweringService categoriesFor: #symbolsMatching:session:!commands!public!testing! !
!RowanAnsweringService categoriesFor: #updateSymbols:!public!updating! !

