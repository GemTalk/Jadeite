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
	| sample1Path root service |
	self disableInteractionsWhile: 
			[sample1Path := self rowanSample1Path.
			root := self rowanProjectsHome.
			service := RowanProjectService new.
			service
				command: #newGitProject:root:useSsh:;
				commandArgs: (Array
							with: sample1Path
							with: root
							with: true).
			JadePresenter issueCommands: (Array with: service) session: session]!

disableInteractionsWhile: block
	"interactions like confirm: and notify: are enabled by 
	default on all service commands. Disable for the duration
	of this block"

	| answeringService wasEnabled |
	answeringService := RowanAnsweringService new.
	answeringService
		command: #interactionHandlerActive;
		commandArgs: Array new.
	self issueCommand: answeringService.
	wasEnabled := answeringService answer.
	answeringService
		command: #setEnableInteractionHandler:;
		commandArgs: (Array with: false).
	self issueCommand: answeringService.
	[block value] ensure: 
			[answeringService
				command: #setEnableInteractionHandler:;
				commandArgs: (Array with: wasEnabled).
			self issueCommand: answeringService]!

ensureRowanSample1Loaded
	self disableInteractionsWhile: 
			[self unloadSampleProject.
			session commit.
			self cloneRowanSample1.
			self loadProjectNamed: self sampleProjectName]!

isAvailable
	^session notNil and: [transcript notNil]!

issueCommand: service
	^JadePresenter issueCommands: (Array with: service) session: session!

loadProjectNamed: projectName
	| projectService |
	projectService := RowanProjectService new name: projectName.
	projectService
		command: #reloadProject;
		commandArgs: nil.
	JadePresenter issueCommands: (Array with: projectService) session: session!

openProjectsBrowser
	(projectsBrowser isNil or: [projectsBrowser isOpen not])
		ifTrue: [projectsBrowser := self openWindow: [transcript openJadeiteProjectsBrowser]].
	projectsBrowser := projectsBrowser topShell.
	^projectsBrowser!

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

projectsBrowser: anObject
	projectsBrowser := anObject!

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

session: anObject
	session := anObject!

setUp
	super setUp.
	session := GciSession current.
	session
		ifNil: 
			[MessageBox notify: 'GciSession current is nil. Login again.'.
			Processor activeProcess terminate	"There's not a good way to safely return without many subsequent errors. Just kill the test process."].
	transcript := JadeiteTranscript allInstances detect: [:tran | tran gciSession == session] ifNone: [].
	self unloadSampleProject.
	self cloneRowanSample1.
	self ensureRowanSample1Loaded!

tearDown
	super tearDown.
	projectsBrowser
		ifNotNil: 
			[(projectsBrowser currentCard projectListPresenter list
				detect: [:service | service name = self sampleProjectName]
				ifNone: [])
					ifNotNil: [projectsBrowser currentCard basicUnloadProjects: (Array with: self sampleProjectName)].
			projectsBrowser destroy.
			projectsBrowser := nil]!

transcript

	^transcript!

transcript: anObject
	transcript := anObject!

unloadSampleProject
	transcript projectListPresenter primaryPresenter list
		detect: [:projectService | projectService name = self sampleProjectName]
		ifNone: [^self].
	transcript projectListPresenter basicUnloadProjects: (Array with: self sampleProjectName).
	session commit! !
!JadeiteTestResource categoriesFor: #cloneRowanSample1!private!setup teardown! !
!JadeiteTestResource categoriesFor: #disableInteractionsWhile:!private!setup teardown! !
!JadeiteTestResource categoriesFor: #ensureRowanSample1Loaded!private!setup teardown! !
!JadeiteTestResource categoriesFor: #isAvailable!public!testing! !
!JadeiteTestResource categoriesFor: #issueCommand:!public!setup teardown! !
!JadeiteTestResource categoriesFor: #loadProjectNamed:!private!setup teardown! !
!JadeiteTestResource categoriesFor: #openProjectsBrowser!private!setup teardown! !
!JadeiteTestResource categoriesFor: #openWindow:!private! !
!JadeiteTestResource categoriesFor: #projectsBrowser:!private!setup teardown! !
!JadeiteTestResource categoriesFor: #resourceHasValidSession!public!testing! !
!JadeiteTestResource categoriesFor: #rowanProjectsHome!constants!private! !
!JadeiteTestResource categoriesFor: #rowanSample1Path!constants!private! !
!JadeiteTestResource categoriesFor: #sampleProjectName!constants!private! !
!JadeiteTestResource categoriesFor: #session!accessing!public! !
!JadeiteTestResource categoriesFor: #session:!accessing!public! !
!JadeiteTestResource categoriesFor: #setUp!private!setup teardown! !
!JadeiteTestResource categoriesFor: #tearDown!private!setup teardown! !
!JadeiteTestResource categoriesFor: #transcript!accessing!public! !
!JadeiteTestResource categoriesFor: #transcript:!accessing!public! !
!JadeiteTestResource categoriesFor: #unloadSampleProject!private!setup teardown! !

!JadeiteTestResource class methodsFor!

current
	current
		ifNil: 
			[current := self new.
			current session ifNil: [^nil	"notified earlier"]].
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

