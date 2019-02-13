"Filed out from Dolphin Smalltalk 7"!

Model subclass: #BrowserUpdate
	instanceVariableNames: 'updates debug inUpdate'
	classVariableNames: 'Current'
	poolDictionaries: ''
	classInstanceVariableNames: ''!
BrowserUpdate guid: (GUID fromString: '{9ec78c86-d74d-477a-bb5a-254ba1c54272}')!
BrowserUpdate comment: 'Coordinate client presenters with updates from the server'!
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

basicIssueCommand: services session: session
	| stonString stonResultString updateResult |
	services do: [:service | service prepareForReplication].
	stonString := STON toString: services.
	[stonResultString := session serverPerform: #updateFromSton: with: stonString]
		ensure: [services do: [:service | service clearCommand]].
	updateResult := self update: services afterStonReplication: stonResultString.
	session releaseAllOops.
	^updateResult!

basicUpdateServices: services session: session
	| stonString stonResults result |
	services do: 
			[:service |
			service
				prepareForReplication;
				command: nil	"updates don't have commands"].
	stonString := STON toString: services.
	stonResults := session serverPerform: #updateFromSton: with: stonString.
	result := self update: services afterStonReplication: stonResults.
	session releaseAllOops.
	^result!

debug
	^debug!

debug: aBoolean
	aBoolean
		ifTrue: 
			[Smalltalk at: #roundTrips put: 0].
	debug := aBoolean!

initialize
	self initializeUpdates.
	debug := false.
	inUpdate := false!

initializeUpdates
	updates := OrderedCollection new.
	!

inUpdate
	^inUpdate!

inUpdate: anObject
	^inUpdate := anObject!

issueCommand: services session: session
	inUpdate ifTrue: [^self].
	inUpdate := true.
	[[Cursor wait showWhile: [^self basicIssueCommand: services session: session]]
		ensure: [inUpdate := false]]
			ifCurtailed: [inUpdate := false]!

performUpdate: updateBlock with: selector
	updates do: 
			[:update |
			update updateType
				ifNil: [updateBlock value: update]
				ifNotNil: [:type | type == selector ifTrue: [updateBlock value: update]].
			]!

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

selectedServices
	| services potentialSelections |
	services := OrderedCollection new.
	self registeredPresenters do: 
			[:presenter |
			(presenter class canUnderstand: #selections)
				ifTrue: 
					[potentialSelections := presenter selections.
					services addAll: (potentialSelections select: [:selection | selection isRowanService])]].
	^services!

update: services afterStonReplication: stonResults
	"assume we get back the 'same' services as we sent"

	| updatedServices |
	self initializeUpdates.
	updatedServices := STON fromString: stonResults.
	updatedServices do: [:newService | services do: [:service | service replicateFrom: newService]].
	self updates: updatedServices.
	updatedServices do: [:service | service releaseReferencedServices].
	^updatedServices!

updateReady
	updates isEmpty ifFalse: [self trigger: #updateReady]!

updates
	^updates!

updates: aCollection
	"don't just reinitialize the updates instance variable because
	presenters are registered to that object"
	updates removeAll: updates.
	updates addAll: aCollection.
	self updateReady!

updateService: service session: session
	self updateServices: (Array with: service) session: session!

updateServices: services session: session
	inUpdate ifTrue: [^self].
	services isEmpty ifTrue:[^self]. 
	inUpdate := true.
	
	[[Cursor wait showWhile: [^self basicUpdateServices: services session: session]]
		ensure: [inUpdate := false]]
			ifCurtailed: [inUpdate := false]!

updatesPerform: selector presenter: presenter
	"the update may know which client updates 
	it wants us to care about. Respect that."

	updates do: 
			[:update |
			(update updateType isNil or: [update updateType == selector])
				ifTrue: [update perform: selector with: presenter]]!

updatesPerform: selector presenter: presenter browser: browser
	"the update may know which client updates 
	it wants us to care about if updateType is set. 
	Respect the server's wishes."

	updates do: 
			[:update |
			(update updateType isNil or: [update updateType == selector])
				ifTrue: 
					[update
						perform: selector
						with: presenter
						with: browser]]! !
!BrowserUpdate categoriesFor: #activeClassServices!accessing!public! !
!BrowserUpdate categoriesFor: #activeMethodServices!accessing!public! !
!BrowserUpdate categoriesFor: #activePackageServices!accessing!public! !
!BrowserUpdate categoriesFor: #activeServices!accessing!public! !
!BrowserUpdate categoriesFor: #basicIssueCommand:session:!commands!private! !
!BrowserUpdate categoriesFor: #basicUpdateServices:session:!private!updating! !
!BrowserUpdate categoriesFor: #debug!accessing!private! !
!BrowserUpdate categoriesFor: #debug:!accessing!private! !
!BrowserUpdate categoriesFor: #initialize!initialization!public! !
!BrowserUpdate categoriesFor: #initializeUpdates!initialization!public! !
!BrowserUpdate categoriesFor: #inUpdate!accessing!public! !
!BrowserUpdate categoriesFor: #inUpdate:!accessing!private! !
!BrowserUpdate categoriesFor: #issueCommand:session:!commands!public! !
!BrowserUpdate categoriesFor: #performUpdate:with:!private!updating! !
!BrowserUpdate categoriesFor: #register:selector:!public!registeringPresenters! !
!BrowserUpdate categoriesFor: #register:selector:browser:!public!registeringPresenters! !
!BrowserUpdate categoriesFor: #registeredListPresenters!private!registeringPresenters! !
!BrowserUpdate categoriesFor: #registeredListServices!private!registeringPresenters! !
!BrowserUpdate categoriesFor: #registeredPresenters!public!registeringPresenters! !
!BrowserUpdate categoriesFor: #registeredTreePresenters!private!registeringPresenters! !
!BrowserUpdate categoriesFor: #selectedServices!accessing!public! !
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
	^Current ifNil: [Current := self new]! !
!BrowserUpdate class categoriesFor: #clearCurrent!accessing!public! !
!BrowserUpdate class categoriesFor: #current!accessing!public! !

