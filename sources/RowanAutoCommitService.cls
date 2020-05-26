"Filed out from Dolphin Smalltalk 7"!

RowanService subclass: #RowanAutoCommitService
	instanceVariableNames: 'autoCommit postUpdateBlock name'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanAutoCommitService guid: (GUID fromString: '{32b30a33-c470-43de-befd-cab5cd6cd8a7}')!
RowanAutoCommitService comment: ''!
!RowanAutoCommitService categoriesForClass!Unclassified! !
!RowanAutoCommitService methodsFor!

autoCommitUpdate: browser
	| shouldAbort |
	autoCommit == #failed
		ifTrue: 
			[postUpdateBlock := 
					[shouldAbort := MessageBox
								confirm: 'Autocommit has failed to commit. Your changes will not be commited in the repository until you abort. Abort now?

(If you choose ''No'' you will be prompted with a list of transaction conflicts)'.
					shouldAbort
						ifTrue: [JadePresenter abortTransaction: browser gciSession]
						ifFalse: [self displayTransactionConflicts: browser]]].
	browser autoCommit: autoCommit.
	^postUpdateBlock!

displayName
	"for logging. for now"

	^name!

displayTransactionConflicts: browser
	| inspector session service |
	session := browser gciSession.
	inspector := JadeiteInspector new gciSession: session.
	service := inspector evaluateText: 'System transactionConflicts'
				thenInspectInContext: session oopNil value.
	inspector showOn: service.
	inspector updateCaption: 'Transaction Conflicts'. !

name
	^name!

name: aString
	name := aString asString!

sortAspect

	^name! !
!RowanAutoCommitService categoriesFor: #autoCommitUpdate:!public!updating! !
!RowanAutoCommitService categoriesFor: #displayName!displaying!public! !
!RowanAutoCommitService categoriesFor: #displayTransactionConflicts:!private!transaction management! !
!RowanAutoCommitService categoriesFor: #name!accessing!public! !
!RowanAutoCommitService categoriesFor: #name:!accessing!public! !
!RowanAutoCommitService categoriesFor: #sortAspect!accessing!public! !

