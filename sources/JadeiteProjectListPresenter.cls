"Filed out from Dolphin Smallalk"!

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
	self updateProjects.
	self refreshGlobalSelections!

addNoneProject
	"project list does not add a none project"

	!

allSelectedProjectsDirty
	^self basicAllSelectedProjectsDirty: projectListPresenter!

auditProject
	self auditProjectFor: projectListPresenter selection name!

basicUnloadProjects: projectNames
	| browserService |
	browserService := RowanBrowserService new.
	browserService
		command: #unloadProjectsNamed:;
		commandArgs: (Array with: projectNames).
	self issueCommand: browserService.
	self refreshGlobalSelections!

browseProject
	| shell presenter service serviceNames |
	shell := JadeiteBrowser showOnSession: gciSession.
	presenter := shell currentCard projectListPresenter.
	serviceNames := projectListPresenter selections collect: [:service | service name].
	service := presenter list detect: [:projectService | serviceNames includes: projectService name]
				ifNone: [^self].
	presenter selection: service.
	^shell currentCard!

checkout
	projectListPresenter selection checkoutUsing: self!

checkoutTag
	self checkoutTag: projectListPresenter selection!

cleanupProjectInfoTab
	"no project tab to update"

	!

createComponents
	super createComponents.
	projectListPresenter := self add: ListPresenter new name: 'projectList'!

createSchematicWiring
	super createSchematicWiring.
	projectListPresenter
		when: #actionPerformed
		send: #browseProject
		to: self!

gitCommit
	| projectName message service promptResult |
	projectListPresenter hasSelection ifFalse: [MessageBox notify: 'No project selected'].
	projectListPresenter selections size > 1
		ifTrue: [MessageBox notify: 'Only one project may be committed'].
	projectName := projectListPresenter selection name.
	message := String new asValue.
	promptResult := JadeiteMultilinePrompter
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
	self issueCommand: service.
	self updateServices: self projectListPresenter list.
	MessageBox notify: 'Project ' , projectName , ' committed to local repository!!'!

hasSelection
	^projectListPresenter selections isEmpty not!

list: list
	projectListPresenter list: (SortedCollection sortBlock: [:x :y | x sortAspect < y sortAspect]).
	projectListPresenter model addAll: list!

loadProjects
	self loadProjectsFrom: self.
	self refreshGlobalSelections.!

onViewClosed
	super onViewClosed.
	BrowserUpdate current
		logComment: 'Closing Project List Browser {' , self identityHash printString , '}'.
	BrowserUpdate current removeEventsTriggeredFor: self. !

onViewOpened
	super onViewOpened.
	BrowserUpdate current
		logComment: 'Opening Project List Browser {' , self identityHash printString , '}'.
	self registerPresentersForUpdates.
	projectListPresenter view contextMenu: JadeiteBrowserPresenter projectMenu!

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
	projectListPresenter selections first projectLogUsing: self session: gciSession!

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
	self issueCommands: projectServices!

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
	self issueCommands: projectServices.
	MessageBox notify: 'Projects ' , (projectServices collect: [:service | service name]) printString
				, ' pushed to remote repository!!'!

queryCommand: aCommandQuery
	#gitCommit == aCommandQuery command
		ifTrue: 
			[aCommandQuery isEnabled: self allSelectedProjectsDirty.
			^true].
	(#(#reloadProject #unloadProjects #loadProjects #pullFromGit #pushToGit #writeProject #projectChanges #browseProject #projectLog)
		includes: aCommandQuery command)
			ifTrue: 
				[aCommandQuery isEnabled: projectListPresenter selections notEmpty.
				^true].
	(#(#loadProject #refresh) includes: aCommandQuery command)
		ifTrue: 
			[aCommandQuery isEnabled: true.
			^true].
	(#(#checkout #checkoutTag) includes: aCommandQuery command)
		ifTrue: 
			[aCommandQuery isEnabled: projectListPresenter selections size = 1.
			^true].
	^true!

refresh
	self updateProjects.
	projectListPresenter view invalidate!

refreshFromServer
	self updateProjects.
	self redrawAllViews!

refreshFromServerAfterAbort: browserService
	browserService projectsUpdate: projectListPresenter browser: self. !

registerPresentersForUpdates
	BrowserUpdate current
		register: projectListPresenter
		selector: #projectsUpdate:browser:
		browser: self.
	BrowserUpdate current register: projectListPresenter selector: #removedProject:!

reloadProject
	^self reloadProjectsFrom: self!

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

updateProject
	"no project tab to update" 

	!

updateProjectPackages
	"no op for project list"

	!

writeProject
	| projectServices |
	projectServices := projectListPresenter selections.
	projectServices isEmpty ifTrue: [^MessageBox notify: 'No project selected'].
	^self basicWriteProject: projectServices! !
!JadeiteProjectListPresenter categoriesForMethods!
abortTransaction!menu handlers!public! !
addNoneProject!public!updating! !
allSelectedProjectsDirty!public!testing! !
auditProject!menu handlers!public! !
basicUnloadProjects:!menu handlers!private! !
browseProject!public! !
checkout!menu handlers!public! !
checkoutTag!menu handlers!public! !
cleanupProjectInfoTab!public!updating! !
createComponents!public! !
createSchematicWiring!initialization!public! !
gitCommit!menu handlers!public! !
hasSelection!public!testing! !
list:!public! !
loadProjects!menu handlers!public! !
onViewClosed!event handlers!public! !
onViewOpened!event handlers!public! !
openChangesShell:!menu handlers!private! !
primaryPresenter!public! !
projectChanges!menu handlers!public! !
projectListPresenter!public! !
projectLog!menu handlers!public! !
pullFromGit!menu handlers!public! !
pushToGit!menu handlers!public! !
queryCommand:!menu handlers!public! !
refresh!menu handlers!public! !
refreshFromServer!menu handlers!public! !
refreshFromServerAfterAbort:!menu handlers!public! !
registerPresentersForUpdates!private!register presenters! !
reloadProject!menu handlers!public! !
unloadProjects!menu handlers!public! !
updateProject!public!updating! !
updateProjectPackages!public!updating! !
writeProject!menu handlers!public! !
!

