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

setAutoCommit: boolean for: session
	command := #setAutoCommit:. 
	commandArgs := Array with: boolean. 
	BrowserUpdate current issueCommand: (Array with: self) session: session.
	^answer! !
!RowanAnsweringService categoriesFor: #answer!accessing!private! !
!RowanAnsweringService categoriesFor: #answer:!accessing!private! !
!RowanAnsweringService categoriesFor: #flipAutoCommitFor:!commands!public! !
!RowanAnsweringService categoriesFor: #flipTranscriptIn:!commands!public! !
!RowanAnsweringService categoriesFor: #isAnsweringService!public!testing! !
!RowanAnsweringService categoriesFor: #isTranscriptInstalledIn:!commands!public! !
!RowanAnsweringService categoriesFor: #setAutoCommit:for:!commands!public! !

