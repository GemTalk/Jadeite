"Filed out from Dolphin Smalltalk 7"!

JadeiteProjectsSystemBrowser subclass: #JadeiteBrowser
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteBrowser guid: (GUID fromString: '{4ed2f816-dbc6-4ce7-b7ef-c483e56b9397}')!
JadeiteBrowser comment: ''!
!JadeiteBrowser categoriesForClass!Unclassified! !
!JadeiteBrowser methodsFor!

queryCommand: aCommandQuery
	| command |
	command := aCommandQuery command.
	(command = #abortTransaction or: [command = #commitTransaction])
		ifTrue: 
			[aCommandQuery isEnabled: JadePresenter areAbortCommitEnabled.
			^true].
	^super queryCommand: aCommandQuery!

systemBrowserPresenter
	^JadeiteBrowserPresenter! !
!JadeiteBrowser categoriesFor: #queryCommand:!menu handlers support!public! !
!JadeiteBrowser categoriesFor: #systemBrowserPresenter!public! !

