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

breakPointsAreEnabled: session
	command := #breakPointsAreEnabled.
	BrowserUpdate current issueCommand: (Array with: self) session: session.
	^answer!

breakpointSettingChanged: transcript
	updateType
		ifNotNil: 
			[transcript areBreakpointsEnabled value: answer.
			BrowserUpdate current breakpointsEnabled: answer]!

expressionSelector: string session: session
	command := #expressionSelector:.
	commandArgs := Array with: string.
	BrowserUpdate current issueCommand: (Array with: self) session: session.
	^answer!

flipAutoCommitFor: session
	command := #flipAutoCommit.
	BrowserUpdate current issueCommand: (Array with: self) session: session.
	^answer!

flipTranscriptIn: session
	command := #flipTranscript.
	BrowserUpdate current issueCommand: (Array with: self) session: session!

isAnsweringService

	^true!

isTranscriptInstalledIn: session
	command := #transcriptInstalled.
	BrowserUpdate current issueCommand: (Array with: self) session: session.
	^answer!

needsCommit: session
	command := #needsCommit.
	self commandArgs: Array new.
	BrowserUpdate current issueCommand: (Array with: self) session: session.
	^answer!

setAutoCommit: boolean for: session
	command := #setAutoCommit:. 
	self commandArgs: (Array with: boolean). 
	BrowserUpdate current issueCommand: (Array with: self) session: session.
	^answer!

setBreakpointsEnabled: boolean session: session
	command := #setBreakPointsAreEnabled:.
	commandArgs := Array with: boolean.
	BrowserUpdate current issueCommand: (Array with: self) session: session! !
!RowanAnsweringService categoriesFor: #answer!accessing!private! !
!RowanAnsweringService categoriesFor: #answer:!accessing!private! !
!RowanAnsweringService categoriesFor: #breakPointsAreEnabled:!commands!public! !
!RowanAnsweringService categoriesFor: #breakpointSettingChanged:!public!updating! !
!RowanAnsweringService categoriesFor: #expressionSelector:session:!commands!public! !
!RowanAnsweringService categoriesFor: #flipAutoCommitFor:!commands!public! !
!RowanAnsweringService categoriesFor: #flipTranscriptIn:!commands!public! !
!RowanAnsweringService categoriesFor: #isAnsweringService!public!testing! !
!RowanAnsweringService categoriesFor: #isTranscriptInstalledIn:!commands!public! !
!RowanAnsweringService categoriesFor: #needsCommit:!commands!public! !
!RowanAnsweringService categoriesFor: #setAutoCommit:for:!commands!public! !
!RowanAnsweringService categoriesFor: #setBreakpointsEnabled:session:!commands!public! !

