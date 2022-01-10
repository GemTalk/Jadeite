"Filed out from Dolphin Smallalk"!

RowanService subclass: #RowanProjectService
	instanceVariableNames: 'sha branch isSkew packages changes existsOnDisk isLoaded projectUrl rowanProjectsHome isDiskDirty projectOop name isDirty specService componentServices'
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
	services := presenter issueCommand: self. 
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
	presenter issueCommand: self.
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
	branchString := (presenter issueCommand: query) first answer.
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

checkoutUsing: presenter
	| branchName branches |
	branches := self basicCheckoutUsing: presenter.
	branchName := ChoicePrompter
				on: branch
				choices: branches
				caption: 'Select branch to checkout:'.
	branchName isNil ifTrue: [^self].
	self basicCheckout: branchName using: presenter!

componentServices

	^componentServices!

componentsUpdate: presenter browser: browser
	"componentServices will be a dictionary. 
	The key is the parent component.
	The value is an array of the children components.

	Example:
	nil -> #(A) - A is a top level component
	A -> #(B C) - B & C are children of A
	B -> #(D) - D is a child of B
	C -> nil
	D -> nil - neither C nor D have children"

	| treeModel parent topLevelComponents removals |
	
	wasUpdated ifFalse: [^self].
	presenter model class = TreeModel
		ifTrue: [^self	"not sure why the model starts out as a TreeModel, not a JadeiteTreeModel"].
	browser projectListPresenter
		ifNil: [^self]
		ifNotNil: 
			[:list |
			list selectionOrNil ifNil: [^self] ifNotNil: [:service | service name = name ifFalse: [^self]]].
	treeModel := self chooseModel: presenter using: browser.
	topLevelComponents := componentServices at: #nil ifAbsent: [^self].
	treeModel resetVisited.
	parent := nil.
	topLevelComponents do: 
			[:componentService |
			self
				possiblyAddComponent: componentService
				to: treeModel
				withParent: parent
				hierarchyServices: componentServices].
	removals := treeModel asBag reject: [:service | (treeModel getNodeFor: service) visited].
	removals do: [:service | treeModel remove: service ifAbsent: []].
	topLevelComponents do: [:component | presenter view expand: component].
	presenter view ensureSelectionVisible!

definition

	"send back a copy of the definition"!

displayName
	| displayName |
	name ifNil: [^String new].
	displayName := name.
	existsOnDisk == false ifTrue: [displayName := '(' , displayName , ')'].
	isDiskDirty ifTrue: [displayName := displayName , '*'].
	^displayName!

displayStringFor: displayThing
	name ifNil: [^self].
	self isDirty == true 
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
	"Unpackaged project may have a nil sha"

	^sha isNil not and: [sha isEmpty not]!

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

packageServices
	"really, packages are a RowanPackageService"
	^packages!

performGitCommand: gitCommand with: argsString in: session
	self
		command: #performGitCommand:with:;
		commandArgs: (Array with: gitCommand with: argsString).
	BrowserUpdate current issueCommand: self session: session!

postUpdate
	super postUpdate.
	packages ifNotNil: [packages do: [:service | service postUpdate]].
	componentServices := Dictionary new. !

prepareForReplication

	"I don't *think* we need packages when sending to the server"
	super prepareForReplication.
	packages := nil.!

projectPackagesUpdate: presenter browser: browser
	wasUpdated ifFalse: [^self].
	self
		packagesUpdate: presenter
		browser: browser
		parentPresenter: browser projectListPresenter!

projectSelectionUpdate: presenter
	| newSelections |
	newSelections := presenter list select: [:service | self name = service name].
	presenter selections: newSelections!

projectsUpdate: presenter
	| listProject |
	wasUpdated ifFalse: [^self].
	listProject := presenter list detect: [:listProj | listProj name = name] ifNone: [^self].
	listProject replicateFrom: self.
	presenter view invalidate!

projectUrl
	^projectUrl!

remoteServiceName
	^'Rowan projectServiceClass'!

removed: presenter
	self = self class noneProject ifTrue: [^self].
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

	^name!

specService
	^specService!

specService: anObject
	specService := anObject! !
!RowanProjectService categoriesForMethods!
=!comparing!public! !
addPackageNamed:using:!presenter support!public! !
allClasses!accessing!public! !
basicChangesUsing:!presenter support!public! !
basicCheckout:using:!presenter support!public! !
basicCheckoutTag:using:!presenter support!public! !
basicCheckoutUsing:!presenter support!private! !
basicName:!accessing!public! !
branch!accessing!public! !
branch:!accessing!public! !
checkoutUsing:!presenter support!public! !
componentServices!public! !
componentsUpdate:browser:!public!updating! !
definition!accessing!public! !
displayName!accessing!displaying!public! !
displayStringFor:!displaying!public! !
gitTags:!presenter support!public! !
hash!comparing!public! !
initialize!Init / Release!public! !
isDirty!accessing!public! !
isDirty:!accessing!public! !
isDiskDirty!accessing!public! !
isLoaded!public!testing! !
isProjectService!public!testing! !
isSkew!accessing!private! !
isSkew:!accessing!private! !
name!accessing!public! !
name:!accessing!public! !
newTextView:using:!displaying!private! !
packages!accessing!public! !
packageServices!accessing!public! !
performGitCommand:with:in:!presenter support!public! !
postUpdate!Init / Release!public! !
prepareForReplication!public!replication! !
projectPackagesUpdate:browser:!public!updating! !
projectSelectionUpdate:!public!updating! !
projectsUpdate:!public!updating! !
projectUrl!accessing!public! !
remoteServiceName!must not strip!public! !
removed:!public!updating! !
removedProject:!public!updating! !
replicateFrom:!public!replication! !
rowanProjectsHome!accessing!public! !
sha!accessing!public! !
sha:!accessing!public! !
sortAspect!accessing!public! !
specService!accessing!private! !
specService:!accessing!private! !
!

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
!RowanProjectService class categoriesForMethods!
defaultIconName!private! !
icon!private! !
noneProject!instance creation!public! !
!

