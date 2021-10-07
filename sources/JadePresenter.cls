"Filed out from Dolphin Smalltalk 7"!

Presenter subclass: #JadePresenter
	instanceVariableNames: 'gciSession'
	classVariableNames: 'InTransaction SigAbortsProcess TransactionMode'
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadePresenter guid: (GUID fromString: '{b55f33eb-59fb-46d6-8fec-7df1571c7d45}')!
JadePresenter comment: 'Abstract class for Jadeite''s presenters. 

We''re storing TransactionMode here for global access.
However, it might be better to move it to session state on the server and access via a service. '!
!JadePresenter categoriesForClass!MVP-Presenters! !
!JadePresenter methodsFor!

addSystemBrowser
	"only sent from browseSelectedClassIn:newTab:
	Not implemented in all subclasses"

	self subclassResponsibility!

gciSession

	^gciSession
!

gciSession: aGciSession

	gciSession := aGciSession.
!

insertIfFalse: methodSourcePresenter
	"Accelerator key - Ctrl-Shift-D"

	| selectionRange |
	selectionRange := methodSourcePresenter selectionRange.
	methodSourcePresenter view replaceSelection: 'ifFalse:[]'.
	methodSourcePresenter selectionRange: selectionRange + 9!

insertIfTrue: methodSourcePresenter
	"Accelerator key - Ctrl-Shift-T"

	| selectionRange |
	selectionRange := methodSourcePresenter selectionRange.
	methodSourcePresenter view replaceSelection: 'ifTrue:[]'.
	methodSourcePresenter selectionRange: selectionRange + 8!

inTransaction

	^self class inTransaction!

inTransaction: aBoolean
	self class inTransaction: aBoolean!

isBeginTransactionEnabled
	^self class isBeginTransactionEnabled!

postEditSaveMethod!

refreshFromServer
	parentPresenter refreshFromServer!

resetCursor

	(Delay forMilliseconds: 20) wait.
	[Cursor current: nil] forkAt: Processor userBackgroundPriority.
!

setStatusBarDefault
	| statusBarView |
	statusBarView := self topShell view viewNamed: 'statusBarField'.
	statusBarView backcolor: statusBarView defaultBackcolor!

statusBarText: aString
	self topShell statusBarText: aString.
	(self view topShell view viewNamed: 'statusBarField') invalidate
!

subMenuName

	^nil.
!

subMenuPresenter

	^nil.
!

transactionMode

	^self class transactionMode!

transactionMode: aSymbol
	self class transactionMode: aSymbol!

transactionMode: aSymbol session: session
	self class transactionMode: aSymbol session: session.
	self stopListeningForSigAborts.
	self transactionMode == #manualBegin ifTrue: [self listenForSigAborts: session]!

updateMenuBar: aMenuBar

	self
		updateMenuBar: aMenuBar 
		withName: self subMenuName 
		itemsFrom: self subMenuPresenter.
!

updateMenuBar: aMenuBar withName: aString itemsFrom: aPresenter

	| contextMenu commandsToRemove items newMenu |
	aString isNil ifTrue: [^self].
	(contextMenu := aPresenter view contextMenu) isNil ifTrue: [^self].
	commandsToRemove := #(#'rename').
	items := contextMenu items reject: [:each | commandsToRemove includes: each command].
	items isEmpty ifTrue: [^self].
	newMenu := aMenuBar addSubmenu: aString.
	1 to: items size do: [:i | 
		| item description |
		item := (items at: i) copy.
		(item isKindOf: CommandMenuItem) ifTrue: [
			description := item commandDescription.
			description := ClosedCommandDescription new
				command: 		description command;
				description: 		description description;
				acceleratorKey: 	description acceleratorKey;
				isModalCommand: 	description isModalCommand;
				image: 			description image;
				receiver:			self;
				queryBlock: 		[:aCommandQuery | self queryCommand: aCommandQuery];
				yourself.
			item commandDescription: description.
		].
		newMenu 
			insertItem: item
			at: i.
	].
!

updateService: service

	^self updateServices: (Array with: service) ! !
!JadePresenter categoriesFor: #addSystemBrowser!private! !
!JadePresenter categoriesFor: #gciSession!public! !
!JadePresenter categoriesFor: #gciSession:!public! !
!JadePresenter categoriesFor: #insertIfFalse:!displaying!public! !
!JadePresenter categoriesFor: #insertIfTrue:!displaying!public! !
!JadePresenter categoriesFor: #inTransaction!accessing!public!transaction management! !
!JadePresenter categoriesFor: #inTransaction:!accessing!public!transaction management! !
!JadePresenter categoriesFor: #isBeginTransactionEnabled!accessing!public!transaction management! !
!JadePresenter categoriesFor: #postEditSaveMethod!menu handlers support!public! !
!JadePresenter categoriesFor: #refreshFromServer!public! !
!JadePresenter categoriesFor: #resetCursor!public! !
!JadePresenter categoriesFor: #setStatusBarDefault!displaying!public! !
!JadePresenter categoriesFor: #statusBarText:!public! !
!JadePresenter categoriesFor: #subMenuName!menus!public! !
!JadePresenter categoriesFor: #subMenuPresenter!menus!public! !
!JadePresenter categoriesFor: #transactionMode!accessing!public!transaction management! !
!JadePresenter categoriesFor: #transactionMode:!accessing!public!transaction management! !
!JadePresenter categoriesFor: #transactionMode:session:!accessing!public!transaction management! !
!JadePresenter categoriesFor: #updateMenuBar:!menus!public! !
!JadePresenter categoriesFor: #updateMenuBar:withName:itemsFrom:!menus!public! !
!JadePresenter categoriesFor: #updateService:!public!services! !

!JadePresenter class methodsFor!

inTransaction

	^InTransaction!

isBeginTransactionEnabled
	^self transactionMode = #manualBegin and: [self inTransaction not]!

openCommit: sha inGitHub: projectService
	^ShellLibrary default shellOpen: projectService projectUrl , '/commit/' , sha directory: ''!

sigAbortsProcess

	^SigAbortsProcess!

sigAbortsProcess: aProcess

	SigAbortsProcess := aProcess!

stopListeningForSigAborts
	self sigAbortsProcess ifNotNil: [:proc | proc terminate].
	self sigAbortsProcess: nil!

transactionMode

	^TransactionMode! !
!JadePresenter class categoriesFor: #inTransaction!public!transaction mode! !
!JadePresenter class categoriesFor: #isBeginTransactionEnabled!public!testing!transaction mode! !
!JadePresenter class categoriesFor: #openCommit:inGitHub:!browsing!public! !
!JadePresenter class categoriesFor: #sigAbortsProcess!public!transaction mode! !
!JadePresenter class categoriesFor: #sigAbortsProcess:!public!transaction mode! !
!JadePresenter class categoriesFor: #stopListeningForSigAborts!public!transaction mode! !
!JadePresenter class categoriesFor: #transactionMode!public!transaction mode! !

