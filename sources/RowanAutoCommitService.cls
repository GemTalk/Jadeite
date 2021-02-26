"Filed out from Dolphin Smalltalk 7"!

RowanService subclass: #RowanAutoCommitService
	instanceVariableNames: 'autoCommit postUpdateBlock'
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

	^self printString!

postUpdateBlock

	^postUpdateBlock!

sortAspect
	"don't think this is used"
	^self printString ! !
!RowanAutoCommitService categoriesFor: #autoCommitUpdate:!public!updating! !
!RowanAutoCommitService categoriesFor: #displayName!displaying!public! !
!RowanAutoCommitService categoriesFor: #postUpdateBlock!accessing!public! !
!RowanAutoCommitService categoriesFor: #sortAspect!accessing!public! !

