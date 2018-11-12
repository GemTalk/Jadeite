"Filed out from Dolphin Smalltalk 7"!

TestResource subclass: #JadeiteTestResource
	instanceVariableNames: 'session transcript projectsBrowser'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteTestResource guid: (GUID fromString: '{81a2cf60-8ff0-4d5a-95b7-c3e863ced71c}')!
JadeiteTestResource comment: ''!
!JadeiteTestResource categoriesForClass!Unclassified! !
!JadeiteTestResource methodsFor!

cloneRowanSample1
	| sample1Path root |
	sample1Path := self rowanSample1Path.
	root := self rowanProjectsHome.
	projectsBrowser currentCard basicCloneProject: sample1Path root: root!

isAvailable
	^session notNil and: [transcript notNil]!

openWindow: aBlock
	"evaluate a block which is expected to return an object that responds to #view.
	Wait until the view affirms it is open before continuing"

	| presenter count |
	presenter := aBlock value.
	count := 0.
	[presenter view isOpen] whileFalse: 
			[(Delay forMilliseconds: 50) wait.
			count := count + 1.
			count > 10 ifTrue: [^presenter]].
	^presenter!

projectsBrowser

	^projectsBrowser!

resourceHasValidSession
	^(GciSession allInstances includes: session) and: [session isValidSession]!

rowanProjectsHome
	^'$ROWAN_PROJECTS_HOME'!

rowanSample1Path
	^'file:$ROWAN_PROJECTS_HOME/Rowan/samples/RowanSample1.ston'!

sampleProjectName
	^'RowanSample1'!

session

	^session!

setUp
	super setUp.
	session := GciSession allInstances detect: [:each | each isValidSession] ifNone: [].
	transcript := JadeiteTranscript allInstances detect: [:tran | tran gciSession == session] ifNone: [].
	projectsBrowser := self openWindow: [transcript openJadeiteProjectsBrowser].
	self cloneRowanSample1!

tearDown
	super tearDown.
	projectsBrowser
		ifNotNil: 
			[projectsBrowser currentCard basicUnloadProjects: (Array with: self sampleProjectName).
			projectsBrowser destroy]!

transcript

	^transcript! !
!JadeiteTestResource categoriesFor: #cloneRowanSample1!private!setup teardown! !
!JadeiteTestResource categoriesFor: #isAvailable!public!testing! !
!JadeiteTestResource categoriesFor: #openWindow:!private! !
!JadeiteTestResource categoriesFor: #projectsBrowser!accessing!public! !
!JadeiteTestResource categoriesFor: #resourceHasValidSession!public!testing! !
!JadeiteTestResource categoriesFor: #rowanProjectsHome!private!setup teardown! !
!JadeiteTestResource categoriesFor: #rowanSample1Path!private!setup teardown! !
!JadeiteTestResource categoriesFor: #sampleProjectName!private!setup teardown! !
!JadeiteTestResource categoriesFor: #session!accessing!public! !
!JadeiteTestResource categoriesFor: #setUp!private!setup teardown! !
!JadeiteTestResource categoriesFor: #tearDown!private!setup teardown! !
!JadeiteTestResource categoriesFor: #transcript!accessing!public! !

!JadeiteTestResource class methodsFor!

current
	current ifNil: [current := self new].
	current resourceHasValidSession ifFalse: [current := self new].
	^current!

isAvailable
	^self current isAvailable!

signalInitializationError
	"TestSuite>>run: in the SUnit pacakge sends this method
	to the class, but implements it on the instance. That appears
	to be a bug."

	self reset.
	^TestResult signalErrorWith: 'Resource ' , self name , ' could not be initialized'! !
!JadeiteTestResource class categoriesFor: #current!Accessing!public! !
!JadeiteTestResource class categoriesFor: #isAvailable!public! !
!JadeiteTestResource class categoriesFor: #signalInitializationError!error handling!public! !

