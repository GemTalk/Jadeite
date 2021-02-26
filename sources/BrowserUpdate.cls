"Filed out from Dolphin Smalltalk 7"!

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

applyUpdateWhile: block
	applyingUpdates := true.
	block ensure: 
			[applyingUpdates := false.
			self postUpdate]!

basicIssueCommand: services session: session
	| stonString stonResultString updateResult loggedServices newLoggingService |
	services do: [:service | service prepareForReplication].
	newLoggingService := logger newServiceLoggingService addServices: services.
	self logSentServices: services.
	loggedServices := services asOrderedCollection
				addFirst: newLoggingService;
				yourself. 
	stonString := STON toString: loggedServices. 
	[stonResultString := session serverPerform: #updateFromSton: with: stonString]
		ensure: [services do: [:service | service clearCommand]].
	stonResultString = 'nil' ifFalse: [
		updateResult := self update: services afterStonReplication: stonResultString].
	session releaseAllOops.
	^updateResult!

basicUpdateServices: services session: session
	services do: [:service | service command: #update].
	^self basicIssueCommand: services session: session!

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
	"Private -  for testing"

	^inUpdate!

inUpdateWhile: block
	| result |
	BrowserUpdate current logComment: 'About to execute inUpdate block - ' , block printString.
	result := inUpdate critical: [Cursor wait showWhile: block].
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
	self inUpdateWhile: 
			[| commandResult |
			commandResult := self basicIssueCommand: services session: session.
			BrowserUpdate current logComment: 'Released inUpdate semaphore'.
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
		when: #updateReady
		send: #update:withSelector:
		to: presenter
		withArguments: (Array with: self with: selector)!

register: presenter selector: selector browser: browser
	"send the update to the presenter so that when the presenter gets
	removed, it's events go with it."
	self
		when: #updateReady
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
	(self getEvents ifNil: [^Array new] ifNotNil: [:eventCollection | eventCollection at: #updateReady])
		messagesDo: [:message | presenters add: message receiver].
	^presenters!

registeredTreePresenters
	^self registeredPresenters select: [:presenter | presenter isKindOf: TreePresenter]!

removeEventsTriggeredFor: anObject
	super removeEventsTriggeredFor: anObject.
	self
		logComment: 'Remove events triggered for ' , anObject printString , ' {'
				, anObject identityHash printString , '}'!

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
	^services!

shouldApply: selector forSelector: update
	^update updateType isNil or: 
			[update updateType == selector
				or: [update updateType isEmpty or: [update updateType includes: selector]]]!

shouldGetNewLoggerGroup: boolean

	logger shouldGetNewLoggerGroup: boolean!

startLogging
	logger startLogging!

stopLogging
	logger stopLogging!

update: services afterStonReplication: stonResults
	"assume we get back the 'same' services as we sent"
	self initializeUpdates.
	returnedServices := STON fromString: stonResults.
	logger loggingService replicateFrom: returnedServices last.
	returnedServices := returnedServices copyWithout: returnedServices last.
	self logReceivedServices: returnedServices.
	returnedServices do: [:newService | services do: [:service | service replicateFrom: newService]].
	self updates: returnedServices.
	returnedServices do: [:service | service postUpdate].
	^returnedServices!

updateReady
	updates isEmpty ifFalse: [self trigger: #updateReady]!

updates
	^updates!

updates: aCollection
	"don't just reinitialize the updates instance variable because
	presenters are registered to that object"

	self applyUpdateWhile: 
			[updates removeAll: updates.
			updates addAll: aCollection.
			self updateReady]!

updateService: service session: session
	^self updateServices: (Array with: service) session: session!

updateServices: services session: session
	| commandResult |
	services isEmpty ifTrue: [^self].
	self inUpdateWhile: 
			[commandResult := self basicUpdateServices: services session: session.
			BrowserUpdate current logComment: 'Released inUpdate semaphore'.
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
			do: [:ex | self halt]! !
!BrowserUpdate categoriesFor: #activeClassServices!accessing!public! !
!BrowserUpdate categoriesFor: #activeMethodServices!accessing!public! !
!BrowserUpdate categoriesFor: #activePackageServices!accessing!public! !
!BrowserUpdate categoriesFor: #activeServices!accessing!public! !
!BrowserUpdate categoriesFor: #applyUpdateWhile:!public!updating! !
!BrowserUpdate categoriesFor: #basicIssueCommand:session:!commands!private! !
!BrowserUpdate categoriesFor: #basicUpdateServices:session:!private!updating! !
!BrowserUpdate categoriesFor: #breakpointsEnabled!accessing!private! !
!BrowserUpdate categoriesFor: #breakpointsEnabled:!accessing!private! !
!BrowserUpdate categoriesFor: #debug!accessing!private! !
!BrowserUpdate categoriesFor: #debug:!accessing!private! !
!BrowserUpdate categoriesFor: #initializeUpdates!initialization!public! !
!BrowserUpdate categoriesFor: #inUpdate!private! !
!BrowserUpdate categoriesFor: #inUpdateWhile:!commands!public! !
!BrowserUpdate categoriesFor: #isApplyingUpdates!public!testing! !
!BrowserUpdate categoriesFor: #isLogging!logging!public!testing! !
!BrowserUpdate categoriesFor: #isLogging:!logging!public!testing! !
!BrowserUpdate categoriesFor: #issueCommand:session:!commands!public! !
!BrowserUpdate categoriesFor: #issueCommands:session:!commands!public! !
!BrowserUpdate categoriesFor: #logComment:!logging!public! !
!BrowserUpdate categoriesFor: #logFileName!accessing!public! !
!BrowserUpdate categoriesFor: #logFileName:!accessing!public! !
!BrowserUpdate categoriesFor: #logger!accessing!private! !
!BrowserUpdate categoriesFor: #logger:!accessing!private! !
!BrowserUpdate categoriesFor: #loggingService!accessing!public! !
!BrowserUpdate categoriesFor: #logReceivedServices:!logging!public! !
!BrowserUpdate categoriesFor: #logSentServices:!logging!public! !
!BrowserUpdate categoriesFor: #performUpdate:with:!private!updating! !
!BrowserUpdate categoriesFor: #postUpdate!public!updating! !
!BrowserUpdate categoriesFor: #register:selector:!public!registeringPresenters! !
!BrowserUpdate categoriesFor: #register:selector:browser:!public!registeringPresenters! !
!BrowserUpdate categoriesFor: #registeredListPresenters!private!registeringPresenters! !
!BrowserUpdate categoriesFor: #registeredListServices!private!registeringPresenters! !
!BrowserUpdate categoriesFor: #registeredPresenters!public!registeringPresenters! !
!BrowserUpdate categoriesFor: #registeredTreePresenters!private!registeringPresenters! !
!BrowserUpdate categoriesFor: #removeEventsTriggeredFor:!public!registeringPresenters! !
!BrowserUpdate categoriesFor: #resetLoggingService!initialization!public! !
!BrowserUpdate categoriesFor: #selectedServices!accessing!public! !
!BrowserUpdate categoriesFor: #shouldApply:forSelector:!private!testing! !
!BrowserUpdate categoriesFor: #shouldGetNewLoggerGroup:!accessing!public! !
!BrowserUpdate categoriesFor: #startLogging!logging!public! !
!BrowserUpdate categoriesFor: #stopLogging!logging!public! !
!BrowserUpdate categoriesFor: #update:afterStonReplication:!public!updating! !
!BrowserUpdate categoriesFor: #updateReady!public!updating! !
!BrowserUpdate categoriesFor: #updates!accessing!public! !
!BrowserUpdate categoriesFor: #updates:!accessing!public! !
!BrowserUpdate categoriesFor: #updateService:session:!public!updating! !
!BrowserUpdate categoriesFor: #updateServices:session:!public!updating! !
!BrowserUpdate categoriesFor: #updatesPerform:presenter:!public!updating! !
!BrowserUpdate categoriesFor: #updatesPerform:presenter:browser:!public!updating! !

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
!BrowserUpdate class categoriesFor: #clearCurrent!accessing!public! !
!BrowserUpdate class categoriesFor: #current!accessing!public! !
!BrowserUpdate class categoriesFor: #startLogging!logging!public! !
!BrowserUpdate class categoriesFor: #stopLogging!logging!public! !

