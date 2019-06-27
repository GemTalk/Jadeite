"Filed out from Dolphin Smalltalk 7"!

RowanPresenter subclass: #JadeiteProjectListPresenter
	instanceVariableNames: 'projectListPresenter'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteProjectListPresenter guid: (GUID fromString: '{b13b9082-2fe0-487d-b717-84410faf12ea}')!
JadeiteProjectListPresenter comment: ''!
!JadeiteProjectListPresenter categoriesForClass!MVP-Presenters! !
!JadeiteProjectListPresenter methodsFor!

abortTransaction
	parentPresenter abortTransaction.
	self refreshProjects.
	self refreshGlobalSelections!

addNoneProject
	"project list does not add a none project"

	!

basicUnloadProjects: projectNames
	| browserService |
	browserService := RowanBrowserService new.
	browserService
		command: #unloadProjectsNamed:;
		commandArgs: (Array with: projectNames).
	self issueCommand: (Array with: browserService).
	self refreshGlobalSelections!

browseProject
	| shell presenter service serviceNames |
	shell := JadeiteBrowser showOnSession: gciSession.
	presenter := shell currentCard projectListPresenter.
	serviceNames := projectListPresenter selections collect: [:service | service name].
	service := presenter list detect: [:projectService | serviceNames includes: projectService name]
				ifNone: [^self].
	presenter selection: service!

checkout
	projectListPresenter selection checkoutUsing: self.!

commit
	| projectName message service promptResult |
	projectListPresenter hasSelection ifFalse: [MessageBox notify: 'No project selected'].
	projectListPresenter selections size > 1
		ifTrue: [MessageBox notify: 'Only one project may be committed'].
	projectName := projectListPresenter selection name.
	message := String new asValue.
	promptResult := StsMultilinePrompter
				on: message
				prompt: 'Enter Git commit message. (Note - This will NOT do a GemStone commit)'
				caption: 'Committing Project ' , projectName.
	promptResult isNil ifTrue: [^self].
	message value isEmpty
		ifTrue: [^MessageBox notify: 'Commit message must not be empty. Commit to local repository NOT done.'].
	service := projectListPresenter selection.
	service
		command: #commitWithMessage:;
		commandArgs: (Array with: message value asString).
	self issueCommand: (Array with: service).
	MessageBox notify: 'Project ' , projectName , ' committed to local repository!!'!

createComponents
	super createComponents.
	projectListPresenter := self add: ListPresenter new name: 'projectList'!

list: list
	projectListPresenter list: (SortedCollection sortBlock: [:x :y | x sortAspect < y sortAspect]).
	projectListPresenter model addAll: list!

loadProjects
	self loadProjectsFrom: self.
	self refreshGlobalSelections.!

makeDefault
	"the server is the gold copy"
	| projectService |
	projectService := projectListPresenter selection.
	projectService command: #setDefaultProject.
	self issueCommand: (Array with: projectService).
	RowanProjectService defaultProjectName: projectService name!

onViewClosed
	super onViewClosed.
	BrowserUpdate current
		logComment: 'Closing Project List Browser {' , self identityHash printString , '}'.
	subPresenters do: [:presenter | BrowserUpdate current removeEventsTriggeredFor: presenter]!

onViewOpened
	super onViewOpened.
	BrowserUpdate current logComment: 'Opening Project List Browser {' , self identityHash printString , '}'.
	self registerPresentersForUpdates!

openChangesShell: changesString
	| shell editor rs |
	editor := RichTextEdit new.
	editor value: changesString.
	shell := ShellView new
				create;
				yourself.
	shell extent: 600 @ 600.
	shell layoutManager: GridLayout new.
	editor parentView: shell.
	editor create show.
	shell caption: projectListPresenter selection name, ' project changes'.
	shell show.
	rs := ReadStream on: changesString.
	[rs atEnd] whileFalse: 
			[| line startPosition checkChar |
			startPosition := rs position.
			line := rs nextLine.
			checkChar := line isEmpty ifTrue: [nil] ifFalse: [line first].
			checkChar = $+
				ifTrue: 
					[editor selectionRange: (startPosition to: rs position - 1).
					editor selectionColor: Color darkGreen].
			checkChar = $-
				ifTrue: 
					[editor selectionRange: (startPosition to: rs position - 1).
					editor selectionColor: Color red]].
	editor selectionRange: editor defaultSelectionRange.
	editor invalidate!

primaryPresenter
	^projectListPresenter!

projectChanges
	projectListPresenter selections isEmpty ifTrue: [^MessageBox notify: 'No project selected'].
	^projectListPresenter selections first changesUsing: self gciSession!

projectListPresenter
	^projectListPresenter!

projectLog
	projectListPresenter selection projectLogUsing: self session: gciSession!

pullFromGit
	| projectServices ws |
	projectServices := projectListPresenter selections.
	ws := WriteStream on: String new.
	projectServices do: 
			[:service |
			ws
				nextPutAll: service name;
				space].
	(MessageBox
		confirm: 'It is recommended that you commit changes before doing a pulling projects - ' , ws contents
				, ' -  from git. Really proceed?')
			ifFalse: [^self].
	projectServices do: [:service | service command: #pullFromGit].
	self issueCommand: projectServices!

pushToGit
	| projectServices ws |
	projectServices := projectListPresenter selections.
	projectServices isEmpty ifTrue: [^MessageBox notify: 'No project selected'].
	ws := WriteStream on: String new.
	projectServices do: 
			[:service |
			ws
				nextPutAll: service name;
				space].
	(MessageBox
		confirm: 'Push projects - ' , ws contents , '- from the local repository to the remote server?')
			ifFalse: [^self].
	projectServices do: [:service | service command: #pushToGit].
	self issueCommand: projectServices!

queryCommand: aCommandQuery
	(#(#unloadProjects #loadProjects #pullFromGit #pushToGit #commit #writeProject #projectChanges #browseProject #makeDefault #projectLog #checkout)
		includes: aCommandQuery command)
			ifTrue: 
				[aCommandQuery isEnabled: projectListPresenter selections notEmpty.
				^true].
	(#(#cloneProject #refresh #includes: #aCommandQuery #command) includes: aCommandQuery command)
		ifTrue: 
			[aCommandQuery isEnabled: true.
			^true].
	^true!

refresh
	self refreshProjects!

refreshFromServerAfterAbort: browserService
	browserService projectsUpdate: projectListPresenter browser: self. !

refreshProjects
	| browserService |
	browserService := RowanBrowserService new.
	browserService command: #updateProjects.
	self issueCommand: (Array with: browserService).!

registerPresentersForUpdates
	BrowserUpdate current register: projectListPresenter selector: #projectsUpdate:browser: browser: self.
	BrowserUpdate current register: projectListPresenter selector: #removedProject:.
	BrowserUpdate current register: projectListPresenter 	selector: #projectsUpdate:.
	BrowserUpdate current register: projectListPresenter selector: #aborted:browser: browser: self!

unloadProjects
	| projectNames ws |
	projectNames := projectListPresenter selections collect: [:projectService | projectService name].
	projectNames isEmpty ifTrue: [^self].
	ws := WriteStream on: String new.
	projectNames do: 
			[:projectName |
			ws
				space;
				nextPutAll: projectName].
	(MessageBox
		confirm: 'Really unload project(s) - ' , ws contents , '?  You will lose any unsaved changes!! '
		caption: 'UNLOAD PROJECTS WARNING!!') ifFalse: [^self].
	self basicUnloadProjects: projectNames!

updatePackages
	"no op for project list"

	!

writeProject
	| projectServices ws |
	projectServices := projectListPresenter selections.
	projectServices isEmpty ifTrue: [^MessageBox notify: 'No project selected'].
	ws := WriteStream on: String new.
	projectServices do: 
			[:service |
			ws
				nextPutAll: service name;
				space].
	(MessageBox confirm: 'Write projects - ' , ws contents , '- to disk without committing?')
		ifFalse: [^false].
	projectServices do: [:service | service command: #write].
	self issueCommand: projectServices.
	MessageBox notify: 'Projects ' ,  ws contents  , ' written to disk'! !
!JadeiteProjectListPresenter categoriesFor: #abortTransaction!menu handlers!public! !
!JadeiteProjectListPresenter categoriesFor: #addNoneProject!public!updating! !
!JadeiteProjectListPresenter categoriesFor: #basicUnloadProjects:!menu handlers!private! !
!JadeiteProjectListPresenter categoriesFor: #browseProject!menu handlers!public! !
!JadeiteProjectListPresenter categoriesFor: #checkout!menu handlers!public! !
!JadeiteProjectListPresenter categoriesFor: #commit!menu handlers!public! !
!JadeiteProjectListPresenter categoriesFor: #createComponents!public! !
!JadeiteProjectListPresenter categoriesFor: #list:!public! !
!JadeiteProjectListPresenter categoriesFor: #loadProjects!menu handlers!public! !
!JadeiteProjectListPresenter categoriesFor: #makeDefault!menu handlers!public! !
!JadeiteProjectListPresenter categoriesFor: #onViewClosed!event handlers!public! !
!JadeiteProjectListPresenter categoriesFor: #onViewOpened!event handlers!public! !
!JadeiteProjectListPresenter categoriesFor: #openChangesShell:!menu handlers!private! !
!JadeiteProjectListPresenter categoriesFor: #primaryPresenter!public! !
!JadeiteProjectListPresenter categoriesFor: #projectChanges!menu handlers!public! !
!JadeiteProjectListPresenter categoriesFor: #projectListPresenter!public! !
!JadeiteProjectListPresenter categoriesFor: #projectLog!menu handlers!public! !
!JadeiteProjectListPresenter categoriesFor: #pullFromGit!menu handlers!public! !
!JadeiteProjectListPresenter categoriesFor: #pushToGit!menu handlers!public! !
!JadeiteProjectListPresenter categoriesFor: #queryCommand:!menu handlers!public! !
!JadeiteProjectListPresenter categoriesFor: #refresh!menu handlers!public! !
!JadeiteProjectListPresenter categoriesFor: #refreshFromServerAfterAbort:!menu handlers!public! !
!JadeiteProjectListPresenter categoriesFor: #refreshProjects!public! !
!JadeiteProjectListPresenter categoriesFor: #registerPresentersForUpdates!private!register presenters! !
!JadeiteProjectListPresenter categoriesFor: #unloadProjects!menu handlers!public! !
!JadeiteProjectListPresenter categoriesFor: #updatePackages!public!updating! !
!JadeiteProjectListPresenter categoriesFor: #writeProject!menu handlers!public! !

