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

additionalAccelerators
	^#(#(#raiseConsole 'Ctrl+F7'))!

addSystemBrowser
	"only sent from browseSelectedClassIn:newTab:
	Not implemented in all subclasses"

	self subclassResponsibility!

basicWriteProject: projectServices
	| ws |
	ws := WriteStream on: String new.
	projectServices do: 
			[:service |
			ws
				nextPutAll: service name;
				space].
	(MessageBox confirm: 'Write projects - ' , ws contents , '- to disk without committing?')
		ifFalse: [^false].
	projectServices do: [:service | service command: #write].
	self issueCommands: projectServices.
	MessageBox notify: 'Projects ' , ws contents , ' written to disk'!

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

onViewOpened
	super onViewOpened.
	self positionToDefaultLocation!

positionToDefaultLocation
	self topShell position: JadePresenter defaultWindowPosition!

postEditSaveMethod!

refresh

	self subclassResponsibility!

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
!JadePresenter categoriesFor: #additionalAccelerators!constants!public! !
!JadePresenter categoriesFor: #addSystemBrowser!private! !
!JadePresenter categoriesFor: #basicWriteProject:!menu handlers!public! !
!JadePresenter categoriesFor: #commitTransaction!public!transaction management! !
!JadePresenter categoriesFor: #gciSession!public! !
!JadePresenter categoriesFor: #gciSession:!public! !
!JadePresenter categoriesFor: #insertIfFalse:!displaying!public! !
!JadePresenter categoriesFor: #insertIfTrue:!displaying!public! !
!JadePresenter categoriesFor: #onViewOpened!event handlers!public! !
!JadePresenter categoriesFor: #positionToDefaultLocation!event handlers!event handlers support!public! !
!JadePresenter categoriesFor: #postEditSaveMethod!menu handlers support!public! !
!JadePresenter categoriesFor: #refresh!menu handlers!public! !
!JadePresenter categoriesFor: #refreshFromServer!public! !
!JadePresenter categoriesFor: #resetCursor!public! !
!JadePresenter categoriesFor: #setStatusBarDefault!displaying!public! !
!JadePresenter categoriesFor: #statusBarText:!public! !
!JadePresenter categoriesFor: #subMenuName!menus!public! !
!JadePresenter categoriesFor: #subMenuPresenter!menus!public! !
!JadePresenter categoriesFor: #updateMenuBar:!menus!public! !
!JadePresenter categoriesFor: #updateMenuBar:withName:itemsFrom:!menus!public! !
!JadePresenter categoriesFor: #updateService:!public!services! !

!JadePresenter class methodsFor!

loadViewResource2: aString inContext: contextView
	| resourceIdentifier |
	ShellView
		defaultExtentBlock: [:shellView | shellView extent];
		createHookBlock: 
				[:shellView :createBlock | (Smalltalk at: #stopOnce)
		ifTrue: 
			["Smalltalk at: #stopOnce put: true"
			Smalltalk at: #stopOnce put: false.
			self halt]. 
				shellView beCentered.
				createBlock value.
				].
	
	[resourceIdentifier := ResourceIdentifier class: self name: aString.
	^resourceIdentifier loadWithContext: contextView]
			ensure: 
				[ShellView
					defaultExtentBlock: nil;
					createHookBlock: nil]!

maxPrintStringSize
	^100000!

openCommit: sha inGitHub: projectService
	^ShellLibrary default shellOpen: projectService projectUrl , '/commit/' , sha directory: ''!

rowanProjectsHomeEnvVarString
	^'$ROWAN_PROJECTS_HOME'!

rowanSample1Path
	^'file:$ROWAN_PROJECTS_HOME/Rowan/samples/RowanSample1_resolved_v2.ston'! !
!JadePresenter class categoriesFor: #loadViewResource2:inContext:!operations!public! !
!JadePresenter class categoriesFor: #maxPrintStringSize!constants!public! !
!JadePresenter class categoriesFor: #openCommit:inGitHub:!browsing!public! !
!JadePresenter class categoriesFor: #rowanProjectsHomeEnvVarString!constants!public! !
!JadePresenter class categoriesFor: #rowanSample1Path!constants!public! !

