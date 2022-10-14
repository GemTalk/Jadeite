"Filed out from Dolphin Smallalk"!

Presenter subclass: #JadePresenter
	instanceVariableNames: 'gciSession'
	classVariableNames: 'InTransaction PackageGroupsVisible PackageListVisible SigAbortProcessInterval SigAbortsProcess SigAbortsProcessEnabled TransactionMode'
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadePresenter guid: (GUID fromString: '{b55f33eb-59fb-46d6-8fec-7df1571c7d45}')!
JadePresenter comment: 'Abstract class for Jadeite''s presenters. 

We''re storing TransactionMode here for global access.
However, it might be better to move it to session state on the server and access via a service. '!
!JadePresenter categoriesForClass!MVP-Presenters! !
!JadePresenter methodsFor!

additionalAccelerators
	^#(#(#raiseConsole 'Ctrl+F7'))!

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

inTransaction

	^self class inTransaction!

inTransaction: aBoolean
	self class inTransaction: aBoolean!

isBeginTransactionEnabled
	^self class isBeginTransactionEnabled!

isCommitEnabled
	^self class isCommitEnabled!

onViewOpened
	super onViewOpened.
	self positionToDefaultLocation!

positionToDefaultLocation
	self topShell position: JadePresenter defaultWindowPosition!

postEditSaveMethod!

queryCommand: query
	"this seems dumb but if JadePresenter can perform a symbol it will enable 
	the command regardless of what it's subclasses do."

	super queryCommand: query.
	query commandSymbol = #beginTransaction
		ifTrue: 
			[query isEnabled: self isBeginTransactionEnabled.
			^true].
	query commandSymbol = #commitTransaction
		ifTrue: 
			[query isEnabled: self isCommitEnabled.
			^true]!

refresh

	self subclassResponsibility!

refreshFromServer
	parentPresenter refreshFromServer!

resetCursor

	(Delay forMilliseconds: 20) wait.
	[Cursor current: nil] forkAt: Processor userBackgroundPriority.
!

resetListeningForSigAborts: session
	self stopListeningForSigAborts.
	(self transactionMode == #manualBegin or: [self transactionMode == #transactionless])
		ifTrue: [self listenForSigAborts: session]!

setStatusBarDefault
	| statusBarView |
	statusBarView := self topShell view viewNamed: 'statusBarField'.
	statusBarView backcolor: statusBarView defaultBackcolor!

sigAbortsProcessEnabled
	^self class sigAbortsProcessEnabled!

sigAbortsProcessEnabled: aBoolean
	self class sigAbortsProcessEnabled: aBoolean!

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
	self resetListeningForSigAborts: session!

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
!JadePresenter categoriesForMethods!
additionalAccelerators!constants!public! !
commitTransaction!public!transaction management! !
gciSession!public! !
gciSession:!public! !
insertIfFalse:!displaying!public! !
insertIfTrue:!displaying!public! !
inTransaction!public! !
inTransaction:!public! !
isBeginTransactionEnabled!public! !
isCommitEnabled!public! !
onViewOpened!event handlers!public! !
positionToDefaultLocation!event handlers!event handlers support!public! !
postEditSaveMethod!menu handlers support!public! !
queryCommand:!public! !
refresh!menu handlers!public! !
refreshFromServer!public! !
resetCursor!public! !
resetListeningForSigAborts:!public! !
setStatusBarDefault!displaying!public! !
sigAbortsProcessEnabled!public! !
sigAbortsProcessEnabled:!public! !
statusBarText:!public! !
subMenuName!menus!public! !
subMenuPresenter!menus!public! !
transactionMode!public! !
transactionMode:!public! !
transactionMode:session:!public! !
updateMenuBar:!menus!public! !
updateMenuBar:withName:itemsFrom:!menus!public! !
updateService:!public!services! !
!

!JadePresenter class methodsFor!

areAbortCommitEnabled
	^self transactionMode == #autoBegin
		or: [self transactionMode == #manualBegin and: [self inTransaction]]!

defaultAdditionalAccelerators
	^#(#(#raiseConsole 'Ctrl+F7'))!

defaultSigAbortProcessInterval
	"in seconds"

	^10!

homeEnvVarString
	^'$HOME'!

inTransaction

	^InTransaction!

isBeginTransactionEnabled
	^self transactionMode = #manualBegin and: [self inTransaction not]!

isCommitEnabled
	^self transactionMode == #autoBegin
		or: [self transactionMode == #manualBegin and: [self inTransaction]]!

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

packageGroupsVisible
	^PackageGroupsVisible ifNil: [PackageGroupsVisible := true]!

packageGroupsVisible: aBoolean
	PackageGroupsVisible := aBoolean!

packageListVisible
	^PackageListVisible ifNil: [PackageListVisible := true]!

packageListVisible: aBoolean
	PackageListVisible := aBoolean!

resetSigAbortProcessEnablement
	"Sent during logout process. 
	Enablement control is done in the Jadeite.prefs file"

	self sigAbortsProcessEnabled: true!

resetSigAbortProcessInterval
	"Sent during logout process. 
	Interval control is done in the Jadeite.prefs file"

	self sigAbortProcessInterval: self defaultSigAbortProcessInterval!

rowanProjectsHomeEnvVarString
	^'$ROWAN_PROJECTS_HOME'!

rowanSample1Path
	^'file:$ROWAN_PROJECTS_HOME/Rowan/samples/RowanSample1_resolved_v2.ston'!

rowanSample9Path
	^'file:$ROWAN_PROJECTS_HOME/RowanSample9/rowan/specs/spec_0061.ston'!

sigAbortProcessInterval
	^SigAbortProcessInterval ifNil: [SigAbortProcessInterval := self defaultSigAbortProcessInterval]!

sigAbortProcessInterval: anInteger
	"can be set from preferences file to be applied on startup"

	SigAbortProcessInterval := anInteger!

sigAbortsProcess

	^SigAbortsProcess!

sigAbortsProcess: aProcess

	SigAbortsProcess := aProcess!

sigAbortsProcessEnabled
	^SigAbortsProcessEnabled ifNil: [SigAbortsProcessEnabled := true]!

sigAbortsProcessEnabled: aBoolean
	SigAbortsProcessEnabled := aBoolean!

stopListeningForSigAborts
	self sigAbortsProcess ifNotNil: [:proc | proc terminate].
	self sigAbortsProcess: nil!

transactionMode
	TransactionMode ifNil: [self initializeTransactionMode].
	^TransactionMode value!

transactionModeValueHolder
	^TransactionMode ifNil:[self initializeTransactionMode]!

waitForAnswer: thingThatCanAnswer
	| theAnswer deferredValue |
	deferredValue := [thingThatCanAnswer answer] deferredValue.
	[deferredValue hasValue not and: [thingThatCanAnswer isDeafObject not]] whileTrue: 
			[| sync |
			sync := ModalMsgLoop new.
			
			[(Delay forMilliseconds: 1) wait.
			sync signal] fork.
			sync wait].
	theAnswer := [deferredValue value] on: Error
				do: 
					[:ex |
					ex messageText = 'DeferredValue terminated prematurely'
						ifTrue: [nil]
						ifFalse: 
							[thingThatCanAnswer
								getProcessList;
								update.	"should be a debugger so update"
							self waitForAnswer: thingThatCanAnswer]].
	^theAnswer! !
!JadePresenter class categoriesForMethods!
areAbortCommitEnabled!public! !
defaultAdditionalAccelerators!constants!public! !
defaultSigAbortProcessInterval!public! !
homeEnvVarString!constants!public! !
inTransaction!public! !
isBeginTransactionEnabled!public! !
isCommitEnabled!public! !
loadViewResource2:inContext:!operations!public! !
maxPrintStringSize!constants!public! !
openCommit:inGitHub:!browsing!public! !
packageGroupsVisible!preferences!public! !
packageGroupsVisible:!preferences!public! !
packageListVisible!preferences!public! !
packageListVisible:!preferences!public! !
resetSigAbortProcessEnablement!public! !
resetSigAbortProcessInterval!public! !
rowanProjectsHomeEnvVarString!constants!public! !
rowanSample1Path!constants!public! !
rowanSample9Path!constants!public! !
sigAbortProcessInterval!preferences!public! !
sigAbortProcessInterval:!preferences!public! !
sigAbortsProcess!public! !
sigAbortsProcess:!public! !
sigAbortsProcessEnabled!public! !
sigAbortsProcessEnabled:!public! !
stopListeningForSigAborts!public! !
transactionMode!preferences!public! !
transactionModeValueHolder!public! !
waitForAnswer:!debugger support!public! !
!

