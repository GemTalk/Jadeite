"Filed out from Dolphin Smalltalk 7"!

JadeiteProjectsSystemBrowser subclass: #JadeiteBrowser
	instanceVariableNames: 'toolbarPresenter'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteBrowser guid: (GUID fromString: '{4ed2f816-dbc6-4ce7-b7ef-c483e56b9397}')!
JadeiteBrowser comment: ''!
!JadeiteBrowser categoriesForClass!Unclassified! !
!JadeiteBrowser methodsFor!

abortedTransaction
	toolbarPresenter view validateUserInterface!

createComponents
	super createComponents.
	toolbarPresenter := self add: JadeToolsToolBarPresenter new name: 'leftToolbar'!

createSchematicWiring
	super createSchematicWiring.
	JadePresenter
		when: #abortedTransaction
		send: #abortedTransaction
		to: self!

onViewClosed
	super onViewClosed.
	JadePresenter removeEventsTriggeredFor: self!

queryCommand: aCommandQuery
	| command |
	command := aCommandQuery command.
	command = #commitTransaction
		ifTrue: 
			[aCommandQuery isEnabled: JadePresenter isCommitEnabled.
			^true].
	command = #beginTransaction
		ifTrue: 
			[aCommandQuery isEnabled: JadePresenter isBeginTransactionEnabled.
			^true].
	^super queryCommand: aCommandQuery!

systemBrowserPresenter
	^JadeiteBrowserPresenter!

toolbarPresenter
	"for tests" 
	^toolbarPresenter! !
!JadeiteBrowser categoriesFor: #abortedTransaction!event handlers!public! !
!JadeiteBrowser categoriesFor: #createComponents!initialize!public! !
!JadeiteBrowser categoriesFor: #createSchematicWiring!initialize!public! !
!JadeiteBrowser categoriesFor: #onViewClosed!event handlers!public! !
!JadeiteBrowser categoriesFor: #queryCommand:!menu handlers support!public! !
!JadeiteBrowser categoriesFor: #systemBrowserPresenter!public! !
!JadeiteBrowser categoriesFor: #toolbarPresenter!accessing!private! !

