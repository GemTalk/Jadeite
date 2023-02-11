"Filed out from Dolphin Smallalk"!

RowanService subclass: #RowanProjectService
	instanceVariableNames: 'sha branch isSkew packages changes existsOnDisk isLoaded projectUrl rowanProjectsHome isDiskDirty projectOop name isDirty specService componentServices packageGroups defaultSymbolDictionaryName packageConvention diskSha'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanProjectService guid: (GUID fromString: '{d65732a3-f4fb-489b-ae7e-d104cddbf3d8}')!
RowanProjectService comment: ''!
!RowanProjectService categoriesForClass!Unclassified! !
!RowanProjectService methodsFor!

= projectService
	^projectService isProjectService ifTrue: [name = projectService name] ifFalse: [^false]!

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

defaultSymbolDictionaryName
	^defaultSymbolDictionaryName!

definition

	"send back a copy of the definition"!

diskSha
	^diskSha!

displayName
	| displayName |
	name ifNil: [^String new].
	displayName := name.
	existsOnDisk == false ifTrue: [displayName := '(' , displayName , ')'].
	^displayName!

displayStringFor: displayThing
	name ifNil: [^self].
	self isDirty == true
		ifTrue: 
			[displayThing font beBold.
			displayThing forecolor: Color black].
	self isLoaded
		ifTrue: 
			[self isSkew
				ifTrue: [displayThing forecolor: Color red]
				ifFalse: [displayThing forecolor: Color black]]
		ifFalse: [displayThing forecolor: Color black].
	isDiskDirty ifTrue: [displayThing font beItalic]!

existsOnDisk
	name = self class notRowanizedPackageName ifTrue:[^false]. 
	^existsOnDisk!

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

logReceivedOn: aStream
	super logReceivedOn: aStream.
	aStream
		space;
		nextPutAll: name!

logSentOn: aStream
	super logSentOn: aStream.
	aStream
		space;
		nextPutAll: name!

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

packageConvention
	^packageConvention!

packageGroupUpdate: presenter browser: browser
	| treeModel allService |
	wasUpdated ifFalse: [^self].
	browser selectedProjectName = name ifFalse: [^self].
	treeModel := self chooseModel: presenter using: browser.
	allService := RowanPackageGroupService new
				name: self class allPackagesGroupName;
				projectName: name.
	treeModel isEmpty
		ifTrue: 
			[treeModel add: allService asChildOf: nil.
			packageGroups do: [:packageGroupService | treeModel add: packageGroupService asChildOf: allService]]
		ifFalse: 
			[(treeModel childrenOf: allService)
				do: [:displayedGroup | (packageGroups includes: displayedGroup) ifFalse: [treeModel remove: displayedGroup ifAbsent: []]].
			packageGroups do: 
					[:packageGroupService |
					((treeModel childrenOf: allService) includes: packageGroupService)
						ifFalse: [treeModel add: packageGroupService asChildOf: allService]]].
	presenter view ensureSelectionVisible.
	presenter view expandAll!

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

	super prepareForReplication.
	packages := nil.!

prettyPrintInstVar: instVarName
	"for display on the project info tab"

	^instVarName ifNil: [String new] ifNotNil: [:iv | self printPrintInstVars at: iv]!

printPrintInstVars
	| pretty |
	pretty := Dictionary new.
	pretty
		at: 'rowanProjectsHome' put: 'Rowan Projects Home';
		at: 'name' put: 'Name';
		at: 'sha' put: 'Sha';
		at: 'diskSha' put: 'Disk Sha';
		at: 'branch' put: 'Branch';
		at: 'isSkew' put: 'Skew';
		at: 'isDirty' put: 'Dirty State';
		at: 'projectUrl' put: 'URL';
		at: 'packageConvention' put: 'Package Convention';
		yourself.
	^pretty!

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
	specService := anObject!

toolTip
	| writeStream crNeeded |
	BrowserUpdate current updateService: self session: GciSession current.
	writeStream := WriteStream on: String new.
	crNeeded := false.
	(isDiskDirty not and: 
			[isDirty not and: 
					[isSkew not
						and: [(existsOnDisk == false) not and: [self displayName ~= RowanService notRowanizedPackageName]]]])
		ifTrue: 
			[writeStream nextPutAll: 'Disk/image consistent'.
			crNeeded := true].
	isDiskDirty
		ifTrue: 
			[writeStream nextPutAll: 'Dirty on disk '.
			crNeeded := true].
	isDirty
		ifTrue: 
			[crNeeded ifTrue: [writeStream cr].
			writeStream nextPutAll: 'Dirty in image '.
			crNeeded := true].
	isSkew
		ifTrue: 
			[crNeeded ifTrue: [writeStream cr].
			writeStream nextPutAll: 'Skew in sha '.
			crNeeded := true].
	(existsOnDisk == false or: [self displayName = RowanService notRowanizedPackageName])
		ifTrue: 
			[crNeeded ifTrue: [writeStream cr].
			writeStream nextPutAll: 'Does not exist on disk'.
			crNeeded := true].
	^writeStream contents! !
!RowanProjectService categoriesForMethods!
=!comparing!public! !
allClasses!accessing!public! !
basicChangesUsing:!presenter support!public! !
basicCheckout:using:!presenter support!public! !
basicCheckoutTag:using:!presenter support!public! !
basicCheckoutUsing:!presenter support!private! !
basicName:!accessing!public! !
branch!accessing!public! !
branch:!accessing!public! !
componentServices!public! !
componentsUpdate:browser:!public!updating! !
defaultSymbolDictionaryName!accessing!private! !
definition!accessing!public! !
diskSha!accessing!private! !
displayName!accessing!displaying!public! !
displayStringFor:!displaying!public! !
existsOnDisk!accessing!private! !
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
logReceivedOn:!printing!public! !
logSentOn:!printing!public! !
name!accessing!public! !
name:!accessing!public! !
newTextView:using:!displaying!private! !
packageConvention!accessing!private! !
packageGroupUpdate:browser:!public!updating! !
packages!accessing!public! !
packageServices!accessing!public! !
performGitCommand:with:in:!presenter support!public! !
postUpdate!Init / Release!public! !
prepareForReplication!public!replication! !
prettyPrintInstVar:!accessing!public! !
printPrintInstVars!accessing!private! !
projectPackagesUpdate:browser:!public!updating! !
projectSelectionUpdate:!public!updating! !
projectsUpdate:!public!updating! !
projectUrl!accessing!must not strip!public! !
remoteServiceName!must not strip!public! !
removed:!public!updating! !
removedProject:!public!updating! !
replicateFrom:!public!replication! !
rowanProjectsHome!accessing!must not strip!public! !
sha!accessing!public! !
sha:!accessing!public! !
sortAspect!accessing!public! !
specService!accessing!private! !
specService:!accessing!private! !
toolTip!accessing!displaying!public! !
!

!RowanProjectService class methodsFor!

allPackagesGroupName
	^'All Packages'!

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
allPackagesGroupName!constants!public! !
defaultIconName!private! !
icon!private! !
noneProject!instance creation!public! !
!

