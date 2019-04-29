"Filed out from Dolphin Smalltalk 7"!

Presenter subclass: #JadePresenter
	instanceVariableNames: 'gciSession'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadePresenter guid: (GUID fromString: '{b55f33eb-59fb-46d6-8fec-7df1571c7d45}')!
JadePresenter comment: ''!
!JadePresenter categoriesForClass!MVP-Presenters! !
!JadePresenter methodsFor!

addSystemBrowser
	"only sent from browseSelectedClassIn:newTab:
	Not implemented in all subclasses"

	self subclassResponsibility!

commitTransaction
	"Even if it takes a windy path, try to make sure
	all commits in Jadeite pass through here"

	| commitResult |
	commitResult := gciSession commit.
	commitResult ifTrue: [Sound informationBeep] ifFalse: [MessageBox warning: 'Commit failed!!'].
	^commitResult!

gciSession

	^gciSession
!

gciSession: aGciSession

	gciSession := aGciSession.
!

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
!JadePresenter categoriesFor: #commitTransaction!public!transaction management! !
!JadePresenter categoriesFor: #gciSession!public! !
!JadePresenter categoriesFor: #gciSession:!public! !
!JadePresenter categoriesFor: #refreshFromServer!public! !
!JadePresenter categoriesFor: #resetCursor!public! !
!JadePresenter categoriesFor: #setStatusBarDefault!displaying!public! !
!JadePresenter categoriesFor: #statusBarText:!public! !
!JadePresenter categoriesFor: #subMenuName!menus!public! !
!JadePresenter categoriesFor: #subMenuPresenter!menus!public! !
!JadePresenter categoriesFor: #updateMenuBar:!menus!public! !
!JadePresenter categoriesFor: #updateMenuBar:withName:itemsFrom:!menus!public! !
!JadePresenter categoriesFor: #updateService:!public!services! !

