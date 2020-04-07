"Filed out from Dolphin Smalltalk 7"!

JadeAutoTextPresenter3 subclass: #JadeiteGitCommandShellTextPresenter
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteGitCommandShellTextPresenter guid: (GUID fromString: '{2ae24995-888a-4138-a91f-4ec23e28e9a0}')!
JadeiteGitCommandShellTextPresenter comment: ''!
!JadeiteGitCommandShellTextPresenter categoriesForClass!Unclassified! !
!JadeiteGitCommandShellTextPresenter methodsFor!

onKeyPressed: aKeyEvent
	| result |
	aKeyEvent wParam = 13 ifTrue: [result := self submitGitCommand].
	result
		ifNotNil: 
			[self view appendText: Character cr asString , result.
			self view moveToEndOfDocument]!

submitGitCommand

	^'Answer like a big-boy shell'! !
!JadeiteGitCommandShellTextPresenter categoriesFor: #onKeyPressed:!event handlers!public! !
!JadeiteGitCommandShellTextPresenter categoriesFor: #submitGitCommand!private! !

