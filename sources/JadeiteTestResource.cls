"Filed out from Dolphin Smallalk"!

TestResource subclass: #JadeiteTestResource
	instanceVariableNames: 'projectsBrowser jadeiteShell'
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
			JadePresenter issueCommands: (Array with: service) session: GciSession current]!

closeTranscript: aTranscript
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #no.	"closing the transcript will logout the session. don't commit"
	[aTranscript view close] ensure: [TestMessageBox disableJadeiteTestMessageBox]!

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
	self refreshProjectNamed: self rowanSample1Project name.  "make sure we have the correct server state in the browser" 
	self rowanSample1Project ifNotNil: [:projectService | projectService isDirty ifFalse: [^self]].
	self disableInteractionsWhile: 
			[self unloadSampleProject.
			self session commit.
			self
				loadProjectFromFile: self rowanSample1Path
				projectsHome: '$ROWAN_PROJECTS_HOME'
				customConditionalAttributes: #('tests')
				componentNames: #('Core' 'Tests')].!

hasValidSession
	| session |
	session := GciSession current.
	session ifNil: [^false].
	^session isValidSession!

isAvailable
	^self session notNil and: [self transcript notNil]!

issueCommand: service
	^JadePresenter issueCommands: (Array with: service) session: self session!

loadProjectFromFile: fileString projectsHome: projectsHomePath customConditionalAttributes: attributes componentNames: componentNames
	| projectService |
	projectService := RowanProjectService new.
	projectService
		command: #loadProjectFromFile:projectsHome:customConditionalAttributes:componentNames:;
		commandArgs: (Array
					with: fileString
					with: projectsHomePath
					with: attributes
					with: componentNames).
	JadePresenter issueCommands: (Array with: projectService) session: self session!

loadProjectNamed: projectName
	| projectService |
	projectService := RowanProjectService new name: projectName.
	projectService
		command: #reloadProject;
		commandArgs: nil.
	JadePresenter issueCommands: (Array with: projectService) session: self session!

loginWithRetry: loginShell
	| loginError |
	loginError := true.
	[loginError] whileTrue: 
			[
			[loginShell loginWithoutErrorHandling.
			loginError := false] on: Error
					do: [:ex | (Delay forMilliseconds: 100) wait]]!

logoutThenLoginAs: userName
	"closing the transcript will logout the session. don't commit"

	userName ifNil: [^self].
	GciSession current ifNotNil: [:current | userName = current userID ifTrue: [^self]].
	self transcript ifNotNil: [self closeTranscript: self transcript].
	JadeiteTranscript allInstances
		do: [:transcript | self closeTranscript: transcript	"hopeful none, but just in case"].
	JadeiteLoginShell allInstances
		do: [:shell | shell view close	"should save to the remote JadeDefaultConnection.gss file"].
	jadeiteShell := JadeiteLoginShell show.
	jadeiteShell userIDPresenter value: userName.
	self loginWithRetry: jadeiteShell!

openProjectsBrowser
	(projectsBrowser isNil or: [projectsBrowser isOpen not])
		ifTrue: [projectsBrowser := self openWindow: [self transcript openJadeiteProjectsBrowser]].
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

refreshProjectNamed: projectName
	| projectService |
	projectService := RowanProjectService new name: projectName.
	projectService
		command: #update;
		commandArgs: nil.
	JadePresenter issueCommands: (Array with: projectService) session: self session!

rowanProjectsHome
	^JadePresenter rowanProjectsHomeEnvVarString!

rowanSample1Path
	^JadePresenter rowanSample1Path!

rowanSample1Project
	^self transcript projectListPresenter projectListPresenter list
		detect: [:projectService | projectService name = 'RowanSample1']
		ifNone: []!

sampleProjectName
	^self class sampleProjectName!

session

	^GciSession current!

setUp
	super setUp.
	self logoutThenLoginAs: 'SystemUser'.
	GciSession current
		ifNil: 
			[MessageBox notify: 'GciSession current is nil. Login again.'.
			Processor activeProcess terminate	"There's not a good way to safely return without many subsequent errors. Just kill the test process."].
	self unloadSampleProject.
	self ensureRowanSample1Loaded!

tearDown
	super tearDown.
	self logoutThenLoginAs: 'SystemUser'.
	projectsBrowser
		ifNotNil: 
			[(projectsBrowser currentCard projectListPresenter list
				detect: [:service | service name = self sampleProjectName]
				ifNone: [])
					ifNotNil: [projectsBrowser currentCard basicUnloadProjects: (Array with: self sampleProjectName)].
			projectsBrowser destroy.
			projectsBrowser := nil]!

transcript
	^self transcriptForCurrentSession!

transcriptForCurrentSession
	| transcript |
	transcript := JadeiteTranscript allInstances
				detect: [:aTranscript | aTranscript gciSession == GciSession current]
				ifNone: [].
	transcript
		ifNil: 
			["somehow we have a transcript disconnected from the current session or no session at all. 
				This might have happened when a test failed in a bad way. Reestablish
				a valid session and transcript"
			JadeiteTranscript allInstances do: 
					[:aTranscript |
					aTranscript gciSession ifNotNil: [:sess | sess logout].
					self closeTranscript: aTranscript].
			GciSession current ifNotNil: [:sess | sess logout]].
	^transcript!

unloadSampleProject
	self transcript projectListPresenter primaryPresenter list
		detect: [:projectService | projectService name = self sampleProjectName]
		ifNone: [^self].
	self transcript projectListPresenter basicUnloadProjects: (Array with: self sampleProjectName).
	self session commit! !
!JadeiteTestResource categoriesForMethods!
cloneRowanSample1!private!setup teardown! !
closeTranscript:!private!setup teardown!support! !
disableInteractionsWhile:!private!setup teardown! !
ensureRowanSample1Loaded!private!setup teardown! !
hasValidSession!public!testing! !
isAvailable!public!testing! !
issueCommand:!public!setup teardown! !
loadProjectFromFile:projectsHome:customConditionalAttributes:componentNames:!private!setup teardown! !
loadProjectNamed:!private!setup teardown! !
loginWithRetry:!private!support! !
logoutThenLoginAs:!private!setup teardown!support! !
openProjectsBrowser!private!setup teardown! !
openWindow:!private! !
projectsBrowser:!private!setup teardown! !
refreshProjectNamed:!private!setup teardown! !
rowanProjectsHome!constants!private! !
rowanSample1Path!constants!private! !
rowanSample1Project!constants!private! !
sampleProjectName!constants!private! !
session!accessing!public! !
setUp!private!setup teardown! !
tearDown!private!setup teardown! !
transcript!accessing!public! !
transcriptForCurrentSession!private!setup teardown!support! !
unloadSampleProject!private!setup teardown! !
!

!JadeiteTestResource class methodsFor!

current
	current
		ifNil: 
			[current := self new.
			current session ifNil: [^nil	"notified earlier"]].
	current hasValidSession ifFalse: [current := self new].
	^current!

isAvailable
	^self current isAvailable!

sampleProjectName
	^'RowanSample1'!

signalInitializationError
	"TestSuite>>run: in the SUnit pacakge sends this method
	to the class, but implements it on the instance. That appears
	to be a bug."

	self reset.
	^TestResult signalErrorWith: 'Resource ' , self name , ' could not be initialized'! !
!JadeiteTestResource class categoriesForMethods!
current!Accessing!public! !
isAvailable!public! !
sampleProjectName!constants!public! !
signalInitializationError!error handling!public! !
!

