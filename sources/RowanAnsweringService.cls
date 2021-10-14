"Filed out from Dolphin Smallalk"!

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

execReturningObject: string in: session
	"instead of just returning a printString of the remote execution results, return
	a fully-formed object. If only simple objects are used, it might work. Else, STON
	might become unhappy and crash. Use at your own risk"

	command := #execReturningObject:.
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

projectRepositoryRoots: projectServices

	!

projectRepositoryRoots: projectServices session: session
	self
		command: #projectsRepositoryRoots:;
		commandArgs: (Array with: (projectServices collect: [:projectService | projectService name])).
	BrowserUpdate current issueCommands: (Array with: self) session: session.
	^answer!

setAutoCommit: boolean for: session
	command := #setAutoCommit:.
	self commandArgs: (Array with: boolean).
	BrowserUpdate current issueCommands: (Array with: self) session: session.
	^answer!

setBreakpointsEnabled: boolean session: session
	command := #setBreakPointsAreEnabled:.
	commandArgs := Array with: boolean.
	BrowserUpdate current issueCommands: (Array with: self) session: session!

symbolDictionaryNames: session
	self
		command: #symbolDictionaryNames;
		commandArgs: Array new.
	BrowserUpdate current issueCommand: self session: session.
	^answer!

symbolExists: aSymbol session: session
	command := #symbolExists:.
	commandArgs := Array with: aSymbol.
	BrowserUpdate current issueCommands: (Array with: self) session: session.
	^answer!

symbolsMatching: string session: session
	command := #symbolsMatching:.
	commandArgs := Array with: string.
	BrowserUpdate current issueCommands: (Array with: self) session: session.
	^answer! !
!RowanAnsweringService categoriesForMethods!
answer!accessing!private! !
answer:!accessing!private! !
autoCommitIn:!commands!public! !
breakPointsAreEnabled:!commands!public! !
breakpointSettingChanged:!public!updating! !
canAccessServiceClasses:!commands!public! !
exec:in:!commands!public! !
execReturningObject:in:!commands!public! !
expressionSelector:session:!commands!public! !
flipAutoCommitFor:!commands!public! !
flipTranscriptIn:!commands!public! !
isAnsweringService!public!testing! !
isTranscriptInstalledIn:!commands!public! !
lowercaseSelectorsMatching:session:!commands!public!testing! !
needsCommit:!commands!public! !
printOn:!printing!public! !
projectRepositoryRoots:!commands!public! !
projectRepositoryRoots:session:!commands!public! !
setAutoCommit:for:!commands!public! !
setBreakpointsEnabled:session:!commands!public! !
symbolDictionaryNames:!commands!public! !
symbolExists:session:!commands!public!testing! !
symbolsMatching:session:!commands!public!testing! !
!
updateSymbols: unused
	updateType = #updateSymbols: ifFalse: [^self].
	JadeiteSearch allClassNames addAll: answer first.
	JadeiteSearch allSelectors addAll: answer last! !