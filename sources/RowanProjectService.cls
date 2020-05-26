"Filed out from Dolphin Smalltalk 7"!

RowanService subclass: #RowanProjectService
	instanceVariableNames: 'sha branch isSkew packages changes existsOnDisk isLoaded projectUrl rowanProjectsHome isDiskDirty projectOop name isDirty'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanProjectService guid: (GUID fromString: '{d65732a3-f4fb-489b-ae7e-d104cddbf3d8}')!
RowanProjectService comment: ''!
!RowanProjectService categoriesForClass!Unclassified! !
!RowanProjectService methodsFor!

= projectService
	^projectService isProjectService ifTrue: [name = projectService name] ifFalse: [^false]!

addPackageNamed: newPackageName using: presenter
	| packageService answeringService services |
	self
		command: #addPackageNamed:;
		commandArgs: (Array with: newPackageName).
	services := presenter issueCommand: (Array with: self).
	answeringService := services detect: [:service | service isAnsweringService].
	answeringService answer = #duplicatePackage
		ifTrue: [^MessageBox notify: 'Duplicate Package. Package named ' , newPackageName , ' not added'].
	packageService := presenter packageListPresenter list
				detect: [:service | service name = newPackageName]
				ifNone: [^MessageBox notify: 'Package named ' , newPackageName , ' not found'].
	presenter packageListPresenter selection: packageService.
	presenter refreshFromServer!

allClasses
	"for testing"

	^packages inject: OrderedCollection new
		into: 
			[:coll :packageService |
			packageService classes ifNotNil: [:classes | coll addAll: classes].
			coll]!

basicChangesUsing: session
	| operations |
	command := #changes.
	BrowserUpdate current issueCommands: (Array with: self) session: session.
	operations := OrderedCollection new.
	changes
		do: [:changeString | operations addAll: (RowanPatch fromString: changeString session: session) operations].
	^operations!

basicCheckout: branchName using: presenter
	self
		command: #checkout:;
		commandArgs: (Array with: (branchName copyWithout: $*)).
	presenter issueCommand: (Array with: self).
	presenter refresh!

basicCheckoutTag: tag using: session
	self
		command: #checkoutTag:;
		commandArgs: (Array with: tag).
	BrowserUpdate current issueCommand: self session: session!

basicCheckoutUsing: presenter
	| branches query branchString |
	query := RowanQueryService new
				command: #projectBranches:;
				commandArgs: (Array with: self name).
	branchString := (presenter issueCommand: (Array with: query)) first answer.
	branches := (branchString subStrings: Character lf) asOrderedCollection.
	branches := branches reject: [:string | '*HEAD*' match: string].
	branches := branches collect: [:string | string copyWithout: Character space].
	^branches!

basicName: aString
	"don't round trip to the server to get information" 
	name := aString!

branch
	^branch!

branch: anObject
	branch := anObject!

changesUsing: session
	| operations |
	operations := self basicChangesUsing: session.
	changes isEmpty ifTrue: [^MessageBox notify: 'No changes!!'].
	[^JadeiteChangesBrowser showOn: (RowanPatch new
				operations: operations;
				session: session)
		name: name]
			ensure: [changes := nil	"clean this up. no longer needed and can be large"]!

checkoutUsing: presenter
	| branchName branches |
	branches := self basicCheckoutUsing: presenter.
	branchName := ChoicePrompter
				on: branch
				choices: branches
				caption: 'Select branch to checkout:'.
	branchName isNil ifTrue: [^self].
	self basicCheckout: branchName using: presenter!

displayName
	| displayName |
	name ifNil: [^String new].
	displayName := name.
	existsOnDisk == false ifTrue: [displayName := '(' , displayName , ')'].
	isDiskDirty ifTrue: [displayName := displayName , '*'].
	^displayName!

displayStringFor: displayThing
	name ifNil: [^self].
	self isDirty
		ifTrue: 
			[displayThing font
				beItalic;
				beBold.
			displayThing forecolor: Color black].
	self isLoaded
		ifTrue: 
			[self isSkew
				ifTrue: [displayThing forecolor: Color red]
				ifFalse: [displayThing forecolor: Color black]]
		ifFalse: [displayThing forecolor: Color black]!

gitTags: session
	| query tags |
	query := RowanQueryService new
				command: #gitTagListUsing:;
				commandArgs: (Array with: self).
	tags := (BrowserUpdate current issueCommand: query session: session) first answer.
	^tags!

hash
	^self name hash!

initialize
	super initialize.
	isDirty := false.
	isLoaded := false.
	isSkew := false.
	sha := 'not a project'.
	isDiskDirty := false. !

isDirty
	^isDirty!

isDirty: anObject
	isDirty := anObject!

isDiskDirty
	^isDiskDirty!

isLoaded

	^sha isEmpty not!

isProjectService

	^true!

isSkew
	^isSkew!

isSkew: anObject
	isSkew := anObject!

name
	^name!

name: aString
	name := aString asString!

newTextView: session using: parentPresenter
	| edit shell |
	shell := JadeShell showOnSession: session.
	shell view
		layoutManager: BorderLayout new;
		hasMaximize: false;
		hasMinimize: false;
		extent: 800 @ 900;
		caption: 'About';
		addSubView: (edit := RichTextEdit new);
		contextMenu: parentPresenter view contextMenu;
		show.
	edit
		arrangement: #center;
		isReadOnly: true;
		canVScroll: true;
		font: (Font name: 'Arial' pointSize: 10);
		alignment: #center;
		contextMenu: parentPresenter view contextMenu.
	^edit!

packages

	^packages!

performGitCommand: gitCommand with: argsString in: session
	self
		command: #performGitCommand:with:;
		commandArgs: (Array with: gitCommand with: argsString).
	BrowserUpdate current issueCommand: self session: session!

postUpdate
	super postUpdate.
	packages ifNotNil: [packages do: [:service | service postUpdate]].
	packages := Array new!

prepareForReplication

	"I don't *think* we need packages when sending to the server"
	super prepareForReplication.
	packages := nil.!

projectLogUsing: parentPresenter session: session
	| gitLog projectName queryService |
	projectName := self name.
	gitLog := JadeiteGitLog showOnSession: session.
	gitLog projectService: self. 
	gitLog caption: (parentPresenter gciSession titleBarFor: projectName , ' Project Git Log').
	queryService := RowanQueryService command: #projectLog: withArgs: (Array with: projectName).
	parentPresenter issueCommand: (Array with: queryService).
	gitLog codePane documentPresenter value: queryService queryResults!

projectPackagesUpdate: presenter browser: browser
	presenter list isEmpty ifTrue: [self initializePresenterList: presenter].
	browser projectListPresenter selections detect: [:projectService | projectService name = name]
		ifNone: [^self].
	self
		updateList: presenter
		whilePreservingSelections: packages
		browser: browser.
	browser isClassSelected ifFalse: [self emptyFilterListsIn: browser]!

projectSelectionUpdate: presenter
	| newSelections |
	newSelections := presenter list select: [:service | self name = service name].
	presenter selections: newSelections!

projectsUpdate: presenter
	| listProject |
	listProject := presenter list detect: [:listProj | listProj name = name] ifNone: [^self].
	listProject replicateFrom: self.
	presenter view invalidate!

projectUrl
	^projectUrl!

remoteServiceName
	^'Rowan projectServiceClass'!

removed: presenter
	self = RowanProjectService noneProject ifTrue: [^self].
	self isDefinedProject ifTrue:[^self]. 
	^super removed: presenter!

removedProject: presenter
	| removedProject |
	updateType == #removedProject: ifFalse:[^self].
	removedProject := presenter list detect: [:projectService | projectService name = name] ifNone: [].
	removedProject ifNotNil: [presenter model remove: removedProject]!

replicateFrom: newService
	^self isProjectService ifTrue: [name isNil ifFalse: [super replicateFrom: newService]]!

rowanProjectsHome
	^rowanProjectsHome!

sha
	^sha!

sha: anObject
	sha := anObject!

sortAspect

	^name! !
!RowanProjectService categoriesFor: #=!comparing!public! !
!RowanProjectService categoriesFor: #addPackageNamed:using:!presenter support!public! !
!RowanProjectService categoriesFor: #allClasses!accessing!public! !
!RowanProjectService categoriesFor: #basicChangesUsing:!presenter support!public! !
!RowanProjectService categoriesFor: #basicCheckout:using:!presenter support!public! !
!RowanProjectService categoriesFor: #basicCheckoutTag:using:!presenter support!public! !
!RowanProjectService categoriesFor: #basicCheckoutUsing:!presenter support!private! !
!RowanProjectService categoriesFor: #basicName:!accessing!public! !
!RowanProjectService categoriesFor: #branch!accessing!public! !
!RowanProjectService categoriesFor: #branch:!accessing!public! !
!RowanProjectService categoriesFor: #changesUsing:!presenter support!public! !
!RowanProjectService categoriesFor: #checkoutUsing:!presenter support!public! !
!RowanProjectService categoriesFor: #displayName!accessing!displaying!public! !
!RowanProjectService categoriesFor: #displayStringFor:!displaying!public! !
!RowanProjectService categoriesFor: #gitTags:!presenter support!public! !
!RowanProjectService categoriesFor: #hash!comparing!public! !
!RowanProjectService categoriesFor: #initialize!Init / Release!public! !
!RowanProjectService categoriesFor: #isDirty!accessing!public! !
!RowanProjectService categoriesFor: #isDirty:!accessing!public! !
!RowanProjectService categoriesFor: #isDiskDirty!accessing!public! !
!RowanProjectService categoriesFor: #isLoaded!public!testing! !
!RowanProjectService categoriesFor: #isProjectService!public!testing! !
!RowanProjectService categoriesFor: #isSkew!accessing!private! !
!RowanProjectService categoriesFor: #isSkew:!accessing!private! !
!RowanProjectService categoriesFor: #name!accessing!public! !
!RowanProjectService categoriesFor: #name:!accessing!public! !
!RowanProjectService categoriesFor: #newTextView:using:!displaying!private! !
!RowanProjectService categoriesFor: #packages!accessing!public! !
!RowanProjectService categoriesFor: #performGitCommand:with:in:!presenter support!public! !
!RowanProjectService categoriesFor: #postUpdate!Init / Release!public! !
!RowanProjectService categoriesFor: #prepareForReplication!public!replication! !
!RowanProjectService categoriesFor: #projectLogUsing:session:!presenter support!public! !
!RowanProjectService categoriesFor: #projectPackagesUpdate:browser:!public!updating! !
!RowanProjectService categoriesFor: #projectSelectionUpdate:!public!updating! !
!RowanProjectService categoriesFor: #projectsUpdate:!public!updating! !
!RowanProjectService categoriesFor: #projectUrl!accessing!public! !
!RowanProjectService categoriesFor: #remoteServiceName!must not strip!public! !
!RowanProjectService categoriesFor: #removed:!public!updating! !
!RowanProjectService categoriesFor: #removedProject:!public!updating! !
!RowanProjectService categoriesFor: #replicateFrom:!public!replication! !
!RowanProjectService categoriesFor: #rowanProjectsHome!accessing!public! !
!RowanProjectService categoriesFor: #sha!accessing!public! !
!RowanProjectService categoriesFor: #sha:!accessing!public! !
!RowanProjectService categoriesFor: #sortAspect!accessing!public! !

!RowanProjectService class methodsFor!

defaultIconName
	"Answer a filename to use for an icon of this class."

	^File composeStem: 'Collection' extension: 'ico'.!

icon
	"Answers an Icon that can be used to represent this class"

	^##(self) defaultIcon!

noneProject
	| inst |
	inst := self new.
	inst
		name: self notRowanizedPackageName;
		isDirty: false;
		isSkew: false;
		sha: 'not a project'.
	^inst! !
!RowanProjectService class categoriesFor: #defaultIconName!private! !
!RowanProjectService class categoriesFor: #icon!private! !
!RowanProjectService class categoriesFor: #noneProject!instance creation!public! !

