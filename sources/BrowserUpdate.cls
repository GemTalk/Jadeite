"Filed out from Dolphin Smallalk"!

Model subclass: #BrowserUpdate
	instanceVariableNames: 'updates debug inUpdate logger applyingUpdates breakpointsEnabled returnedServices'
	classVariableNames: 'Current'
	poolDictionaries: ''
	classInstanceVariableNames: ''!
BrowserUpdate guid: (GUID fromString: '{9ec78c86-d74d-477a-bb5a-254ba1c54272}')!
BrowserUpdate comment: 'Coordinate client presenters with updates from the server.

returnedServices are the last services returned from the server. Handy for testing. '!
!BrowserUpdate categoriesForClass!MVP-Models! !
!BrowserUpdate methodsFor!

activeClassServices
	^self registeredListServices select: [:service | service isClassService]!

activeMethodServices
	^self registeredListServices select: [:service | service isMethodService]!

activePackageServices
	^self registeredListServices select: [:service | service isPackageService]!

activeServices
	"services which are open in windows in list browsers"

	| services |
	services := OrderedCollection new.
	services addAll: self activeMethodServices.
	services addAll: self activeClassServices.
	services addAll: self activePackageServices.
	^services!

applyUpdatesFromReturnedServices: aCollection
	"don't just reinitialize the updates instance variable because
	presenters are registered to that object"
	self applyUpdateWhile: 
			[updates removeAll: updates.
			updates addAll: aCollection.
			self updatesReadyToApply]!

applyUpdateWhile: block
	applyingUpdates := true.
	block ensure: 
			[applyingUpdates := false.
			self postUpdate]!

basicInUpdateWhile: block
	"here is where we actually grab the mutex" 
	| result |
	result := self inUpdate critical: 
					[BrowserUpdate current logComment: 'got inUpdate mutex.  [' , block printString , ']'.
					block ensure: 
							[GciSession current
								ifNotNil: 
									[:session |
									session autoCommit == true
										ifTrue: [JadePresenter trigger: #committedTransaction	"autoCommit could be a symbol #failed"]].
							BrowserUpdate current
								logComment: 'about to release inUpdate mutex.  [' , block printString , ']']].
	^result!

basicIssueCommand: services session: session ignoreReturnedServices: ignoreUpdates
	| stonString stonResultString updateResult loggedServices newLoggingService |
	services do: [:service | service prepareForReplication].
	newLoggingService := logger newServiceLoggingService addServices: services.
	self logSentServices: services.
	loggedServices := services asOrderedCollection
				addFirst: newLoggingService;
				yourself.
	stonString := JadeiteSTON toString: loggedServices.
	[stonResultString := session serverPerform: #updateFromSton: with: stonString]
		ensure: [services do: [:service | service clearCommand]].
	self basicInUpdateWhile: 
			[ignoreUpdates
				ifFalse: 
					[stonResultString = 'nil'
						ifFalse: [updateResult := self update: services afterStonReplication: stonResultString]].
			session releaseAllOops].
	^updateResult!

basicUpdateServices: services session: session
	services do: [:service | service command: #update].
	^self
		basicIssueCommand: services
		session: session
		ignoreReturnedServices: false!

breakpointsEnabled
	^breakpointsEnabled!

breakpointsEnabled: anObject
	breakpointsEnabled := anObject!

debug
	^debug!

debug: aBoolean
	aBoolean
		ifTrue: 
			[Smalltalk at: #roundTrips put: 0].
	debug := aBoolean!

initializeUpdates
	updates := OrderedCollection new.
	!

inUpdate
	^inUpdate!

inUpdateWhile: block
	"don't really get inUpdate semaphore here but we are conceptually in an update. 
	See #basicInUpdateWhile: for the actual grabbing of the mutex"

	| result |
	result := block ensure: 
					[GciSession current
						ifNotNil: 
							[:session |
							session autoCommit == true
								ifTrue: [JadePresenter trigger: #committedTransaction	"autoCommit could be a symbol #failed"]]].
	^result!

isApplyingUpdates
	"we've come back from the server and
	are in the middle of updating browsers. 
	Send this to avoid untimely updates to
	services until updates are fully applied"

	^applyingUpdates == true!

isLogging

	^logger isLogging!

isLogging: boolean
	boolean ifTrue: [self startLogging] ifFalse: [self stopLogging]!

issueCommand: service session: session
	^self issueCommands: (Array with: service) session: session!

issueCommands: services session: session
	^self
		issueCommands: services
		session: session
		ignoringUpdates: false!

issueCommands: services session: session ignoringUpdates: ignore
	| commandResult |
	session
		ifNotNil: 
			[commandResult := self
						basicIssueCommand: services
						session: session
						ignoreReturnedServices: ignore.
			^commandResult]!

logComment: string
	logger logComment: string!

logFileName

	^logger logFileName!

logFileName: string

	^logger logFileName: string!

logger
	"Private - for testing"

	^logger!

logger: anObject
	logger := anObject!

loggingService
	"for testing"

	^logger loggingService!

logReceivedServices: services
	logger logReceivedServices: services.
	logger shouldGetNewLoggerGroup: true!

logSentServices: services
	logger logSentServices: services!

performUpdate: updateBlock with: selector
	updates do: 
			[:update | 
			update updateType
				ifNil: [updateBlock value: update]
				ifNotNil: 
					[:type |
					(type == selector or: [type isEmpty or: [type includes: selector]])
						ifTrue: [updateBlock value: update]]]!

postUpdate
	updates do: [:service | service postUpdateBlock ifNotNil: [:block | block value]]!

register: presenter selector: selector
	"send the update to the presenter so that when the presenter gets
	removed, it's events go with it."

	self
		when: #updatesReadyToApply
		send: #update:withSelector:
		to: presenter
		withArguments: (Array with: self with: selector)!

register: presenter selector: selector browser: browser
	"send the update to the presenter so that when the presenter gets
	removed, it's events go with it."

	self
		when: #updatesReadyToApply
		send: #update:withSelector:browser:
		to: presenter
		withArguments: (Array
				with: self
				with: selector
				with: browser)!

registeredListPresenters
	^self registeredPresenters select: [:presenter | presenter class canUnderstand: #list]!

registeredListServices
	| listServices |
	listServices := OrderedCollection new.
	self registeredListPresenters do: [:listPresenter | listServices addAll: listPresenter list].
	self registeredTreePresenters do:[:treePresenter | listServices addAll: treePresenter model]. 
	^listServices!

registeredPresenters
	| presenters |
	presenters := Set new.
	(self getEvents
		ifNil: [^Array new]
		ifNotNil: [:eventCollection | eventCollection at: #updatesReadyToApply])
			messagesDo: [:message | presenters add: message receiver].
	^presenters!

registeredTreePresenters
	^self registeredPresenters select: [:presenter | presenter isKindOf: TreePresenter]!

removeEventsTriggeredFor: anObject
	super removeEventsTriggeredFor: anObject.
	"self
		logComment: 'Remove events triggered for ' , anObject printString , ' {'
				, anObject identityHash printString , '}'"!

resetLoggingService
	logger loggingService: nil. 
	logger newLoggingService!

selectedServices
	| services potentialSelections |
	services := OrderedCollection new.
	self registeredPresenters do: 
			[:presenter |
			(presenter class canUnderstand: #selections)
				ifTrue: 
					[potentialSelections := presenter selections.
					services addAll: (potentialSelections select: [:selection | selection isUpdatableService])]].
	services do:[:service | service command: #update]. 
	^services asSet asArray!

shouldApply: selector forSelector: service
	^service updateType isNil or: 
			[service updateType == selector
				or: [service updateType isEmpty or: [service updateType includes: selector]]]!

shouldGetNewLoggerGroup: boolean

	logger shouldGetNewLoggerGroup: boolean!

startLogging
	logger startLogging!

stopLogging
	logger stopLogging!

update: services afterStonReplication: stonResults
	"assume we get back the 'same' services as we sent"

	self initializeUpdates.
	returnedServices := JadeiteSTON fromString: stonResults.
	logger loggingService replicateFrom: returnedServices last.
	returnedServices := returnedServices copyWithout: returnedServices last.
	self logReceivedServices: returnedServices.
	returnedServices do: [:newService | services do: [:service | service replicateFrom: newService]].
	self applyUpdatesFromReturnedServices: returnedServices.
	self logComment: 'Received services'' updates applied'. 
	returnedServices do: [:service | service postUpdate].
	^returnedServices!

updates
	^updates!

updateService: service session: session
	^self updateServices: (Array with: service) session: session!

updateServices: services session: session
	| commandResult |
	services isEmpty ifTrue: [^self].
	self inUpdateWhile: 
			[commandResult := self basicUpdateServices: services session: session.
			^commandResult]!

updatesPerform: selector presenter: presenter
	"the update may know which client updates 
	it wants us to care about. Respect that."

	
	[updates do: 
			[:update |
			(self shouldApply: selector forSelector: update) ifTrue: [update perform: selector with: presenter]]]
			on: Error
			do: [:ex | self halt]!

updatesPerform: selector presenter: presenter browser: browser
	"the update may know which client updates 
	it wants us to care about if updateType is set. 
	Respect the server's wishes."

	
	[updates do: 
			[:update |
			(self shouldApply: selector forSelector: update)
				ifTrue: 
					[update
						perform: selector
						with: presenter
						with: browser]]]
			on: Error
			do: [:ex | self halt]!

updatesReadyToApply
	updates isEmpty ifFalse: [self trigger: #updatesReadyToApply]! !
!BrowserUpdate categoriesForMethods!
activeClassServices!accessing!public! !
activeMethodServices!accessing!public! !
activePackageServices!accessing!public! !
activeServices!accessing!public! !
applyUpdatesFromReturnedServices:!accessing!public! !
applyUpdateWhile:!public!updating! !
basicInUpdateWhile:!commands!public!semaphore access! !
basicIssueCommand:session:ignoreReturnedServices:!commands!private! !
basicUpdateServices:session:!private!updating! !
breakpointsEnabled!accessing!private! !
breakpointsEnabled:!accessing!private! !
debug!accessing!private! !
debug:!accessing!private! !
initializeUpdates!initialization!public! !
inUpdate!private!semaphore access! !
inUpdateWhile:!commands!public!semaphore access! !
isApplyingUpdates!public!testing! !
isLogging!logging!public!testing! !
isLogging:!logging!public!testing! !
issueCommand:session:!commands!public! !
issueCommands:session:!commands!public! !
issueCommands:session:ignoringUpdates:!commands!public! !
logComment:!logging!public! !
logFileName!accessing!public! !
logFileName:!accessing!public! !
logger!accessing!private! !
logger:!accessing!private! !
loggingService!accessing!public! !
logReceivedServices:!logging!public! !
logSentServices:!logging!public! !
performUpdate:with:!private!updating! !
postUpdate!public!updating! !
register:selector:!public!registeringPresenters! !
register:selector:browser:!public!registeringPresenters! !
registeredListPresenters!private!registeringPresenters! !
registeredListServices!private!registeringPresenters! !
registeredPresenters!public!registeringPresenters! !
registeredTreePresenters!private!registeringPresenters! !
removeEventsTriggeredFor:!public!registeringPresenters! !
resetLoggingService!initialization!public! !
selectedServices!accessing!public! !
shouldApply:forSelector:!private!testing! !
shouldGetNewLoggerGroup:!accessing!public! !
startLogging!logging!public! !
stopLogging!logging!public! !
update:afterStonReplication:!public!updating! !
updates!accessing!public! !
updateService:session:!public!updating! !
updateServices:session:!public!updating! !
updatesPerform:presenter:!public!updating! !
updatesPerform:presenter:browser:!public!updating! !
updatesReadyToApply!public!updating! !
!

!BrowserUpdate class methodsFor!

clearCurrent
"
	BrowserUpdate clearCurrent.
"
	Current := nil!

current
	^Current ifNil: [Current := self new]!

startLogging
	Current startLogging!

stopLogging
	Current stopLogging! !
!BrowserUpdate class categoriesForMethods!
clearCurrent!accessing!public! !
current!accessing!public! !
startLogging!logging!public! !
stopLogging!logging!public! !
!

