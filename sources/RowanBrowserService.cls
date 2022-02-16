"Filed out from Dolphin Smallalk"!

RowanService subclass: #RowanBrowserService
	instanceVariableNames: 'projects removedMethods allClasses hierarchyServices testPackages testCount dictionaries selectedClass newCachedSelectors newCachedClasses name'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanBrowserService guid: (GUID fromString: '{9c5e8a88-ca64-403c-8f81-6c70c46926f0}')!
RowanBrowserService comment: ''!
!RowanBrowserService categoriesForClass!Unclassified! !
!RowanBrowserService methodsFor!

= browserService
	^browserService isBrowserService and: [name = browserService name]!

allClasses
	^allClasses!

allClasses: theClasses
	allClasses := theClasses!

basicPrepareForReplication
	"don't call anything potentially recursive here.
	method services don't iterate over subcollections"

	removedMethods
		ifNotNil: [removedMethods do: [:methodService | methodService basicPrepareForReplication]].
	dictionaries := nil .
	!

classHierarchyUpdate: presenter browser: browser
	browser isHierarchyTabSelected ifFalse: [^false].
	self
		classHierarchyUpdate: presenter
		browser: browser
		hierarchyServices: hierarchyServices!

dictionaryListUpdate: presenter
	"no sort. dictionaries maintain their server order"
	| removals replicate |	
	presenter list isEmpty ifTrue: [presenter list: ListModel new].
	removals := presenter list reject: [:dictionaryService | dictionaries includes: dictionaryService].
	presenter model removeAll: removals.
	presenter list copy do: 
			[:service |
			replicate := dictionaries detect: [:update | update = service] ifNone: [nil].
			replicate notNil ifTrue: [service replicateFrom: replicate]].
	1 to: dictionaries size
		do: 
			[:index |
			(dictionaries at: index) = (presenter model at: index ifAbsent: [RowanDictionaryService new])
				ifFalse: [presenter model add: (dictionaries at: index) afterIndex: index - 1]]!

displayName
	"for logging. for now"

	^name!

excludedInstVars
	^super excludedInstVars , #('hierarchyServices')!

hash
	^name hash!

initialize
	super initialize.
	allClasses := OrderedCollection new!

isBrowserService

	^true!

name
	"browser services aren't named, but (for convenience) can respond"

	^nil!

name: aString
	name := aString asString!

newProjectNamed: projectName session: session windowHandle: handle
	self
		command: #newProjectNamed:windowHandle:;
		commandArgs: (Array with: projectName with: handle).
	BrowserUpdate current issueCommands: (Array with: self) session: session!

prepareForReplication
	super prepareForReplication.
	self basicPrepareForReplication!

printOn: aStream
	super printOn: aStream.
	aStream nextPut: $(.
	command
		ifNotNil: 
			[aStream
				nextPutAll: 'command: ';
				print: command;
				space;
				nextPutAll: 'commandArgs: ';
				print: commandArgs].
	aStream nextPut: $)!

projects
	^projects!

projectsUpdate: presenter
	| removals |
	presenter list isEmpty ifTrue: [self initializePresenterList: presenter].
	removals := presenter list select: [:projectService | (projects includes: projectService) not].
	presenter model removeAll: removals.
	self
		updateList: presenter
		whilePreservingSelections: projects
		browser: nil!

projectsUpdate: presenter browser: browser
	| removals |
	presenter list isEmpty ifTrue: [self initializePresenterList: presenter].
	removals := presenter list select: 
					[:projectService |
					(projects includes: projectService) not and: [projectService ~= RowanProjectService noneProject]].
	presenter model removeAll: removals.
	presenter selections isEmpty ifTrue: [browser updateProjectPackages].
	self
		updateList: presenter
		whilePreservingSelections: projects
		browser: browser.
	browser addNoneProject.
	browser possiblyClearProjectInfoTab!

registerWindow: handle rootObject: oop session: session
	self
		command: #saveRootObject:windowHandle:;
		commandArgs: (Array with: oop with: handle).
	JadePresenter issueCommands: (Array with: self) session: session!

releaseWindow: handle session: session
	self
		command: #releaseWindowHandle:;
		commandArgs: (Array with: handle).
	JadePresenter issueCommands: (Array with: self) session: session!

reloadProjects: selectedProjectServices presenter: presenter
	| selectedServices |
	selectedServices := BrowserUpdate current selectedServices asSet asOrderedCollection.
	selectedServices removeAll: selectedProjectServices.
	Cursor wait showWhile: 
			[self
				command: #reloadProjects:andUpdateServices:;
				commandArgs: (Array with: selectedProjectServices asSet asArray with: selectedServices).
			BrowserUpdate current issueCommands: (Array with: self) session: presenter gciSession]!

removedMethods
	^removedMethods!

removedMethods: anObject
	removedMethods := anObject!

replicateFrom: newService
	self isBrowserService ifTrue: [super replicateFrom: newService]!

selectedClass

	^selectedClass!

selectedClass: anObject
	selectedClass := anObject!

sortAspect

	^name!

testCount
	^testCount!

testCount: anObject
	testCount := anObject!

testPackages: presenter
	| additions |
	additions := OrderedCollection new.
	testPackages do: 
			[:newPackageService |
			| updatedPackage |
			updatedPackage := presenter model detect: [:packageService | packageService = newPackageService]
						ifNone: 
							[additions add: newPackageService.
							nil].
			updatedPackage ifNotNil: [updatedPackage replicateFrom: newPackageService]].
	presenter model addAll: additions.
	presenter model copy do:[:oldPackageService |
		(testPackages includes: oldPackageService) ifFalse:[presenter model remove: oldPackageService]]. ! !
!RowanBrowserService categoriesForMethods!
=!comparing!public! !
allClasses!accessing!private! !
allClasses:!accessing!private! !
basicPrepareForReplication!public!replication! !
classHierarchyUpdate:browser:!public!updating! !
dictionaryListUpdate:!public!updating! !
displayName!displaying!public! !
excludedInstVars!public!ston! !
hash!comparing!public! !
initialize!initialization!public! !
isBrowserService!public!testing! !
name!accessing!public! !
name:!accessing!public! !
newProjectNamed:session:windowHandle:!commands!public!registering windows! !
prepareForReplication!public!replication! !
printOn:!printing!public! !
projects!accessing!public! !
projectsUpdate:!public!updating! !
projectsUpdate:browser:!public!updating! !
registerWindow:rootObject:session:!commands!public!registering windows! !
releaseWindow:session:!commands!public!registering windows! !
reloadProjects:presenter:!commands!public! !
removedMethods!accessing!private! !
removedMethods:!accessing!private! !
replicateFrom:!public!replication! !
selectedClass!accessing!public! !
selectedClass:!accessing!public! !
sortAspect!accessing!public! !
testCount!accessing!private! !
testCount:!accessing!private! !
testPackages:!public!updating! !
!

