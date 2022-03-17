"Filed out from Dolphin Smallalk"!

Object subclass: #RowanService
	instanceVariableNames: 'command commandArgs updateType organizer updates wasUpdated'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanService guid: (GUID fromString: '{c91bf577-a5a9-4782-b6be-c05df3222bc9}')!
RowanService comment: ''!
!RowanService categoriesForClass!Kernel-Objects! !
!RowanService methodsFor!

addCachedSymbols: unused
	!

autoCommitUpdate: browser!

basicPrepareForReplication
	"don't call anything potentially recursive here"!

basicReplicateFrom: newService
	1 to: self class instSize
		do: 
			[:index |
			(self shouldReplicateInstVarAtIndex: index newService: newService)
				ifTrue: [self instVarAt: index put: (newService instVarAt: index)]]!

breakpointSettingChanged: transcript!

chooseModel: presenter using: browser
	| treeModel |
	treeModel := browser projectListPresenter selectionOrNil isNil
				ifTrue: 
					[JadeiteTreeModel new
						searchPolicy: SearchPolicy equality;
						reset]
				ifFalse: [presenter model].
	^treeModel!

classCategoryUpdate: presenter
	!

classCommentUpdate: presenter
	
	!

classDefinitionUpdate: presenter
	!

classesHierarchyUpdate: presenter
!

classesUpdate: presenter browser: anObject
	!

classHierarchyUpdate: presenter
	!

classHierarchyUpdate: presenter browser: browser
!

classHierarchyUpdate: presenter browser: browser hierarchyServices: hierarchyServices
	| treeModel subclasses parent |
	hierarchyServices ifNil: [^self].
	hierarchyServices isEmpty ifTrue: [^self].
	browser isClassListTabSelected ifTrue: [^self].
	presenter selections notEmpty ifTrue: [(presenter selections includes: self) ifFalse: [^self]].
	treeModel := JadeiteTreeModel new
				searchPolicy: SearchPolicy equality;
				reset.
	parent := nil.
	subclasses := hierarchyServices at: #nil ifAbsent: [].
	subclasses
		ifNil: 
			[| subs |
			parent := self.
			treeModel := presenter model.
			subs := hierarchyServices at: #expand.
			1 to: subs size
				do: 
					[:index |
					| classService node |
					classService := subs at: index.
					node := treeModel getNodeFor: classService ifAbsent: [].
					node
						ifNotNil: 
							[treeModel remove: classService ifAbsent: [].
							subs at: index put: node object]].
			subclasses := subs].
	subclasses do: 
			[:classService |
			self
				possiblyAddHierarchyService: classService
				to: treeModel
				withParent: parent
				hierarchyServices: hierarchyServices].
	presenter model: treeModel.
	presenter view updateMode: #lazy.	"faster for big tree building"
	presenter view disableRedraw.
	
	[treeModel preOrderDo: 
			[:classService |
			classService selectedPackageServices: browser packageListPresenter selections browser: browser.
			classService expand == true
				ifTrue: [presenter view expand: classService]
				ifFalse: 
					[classService hasSubclasses
						ifTrue: 
							[| node |
							node := treeModel getNodeFor: classService ifAbsent: [].
							node
								ifNotNil: 
									[node children isEmpty ifTrue: [treeModel add: RowanFillerClassService new asChildOf: classService]]]]]]
			ensure: [presenter view enableRedraw].
	presenter selectionIfNone: [^presenter view ensureItemVisible: treeModel roots first].
	presenter view ensureSelectionVisible.
	presenter view updateMode: #dynamic!

classMethodsUpdate: presenter browser: browser
	!

classUpdate: presenter
	!

clearCommand

	command := nil. 
	self commandArgs: nil. !

clientDefinitionClass

	^self subclassResponsibility!

command
	^command!

command: symbol
	command := symbol.
	!

commandArgs
	^commandArgs!

commandArgs: anObject
	commandArgs := anObject!

componentPackagesUpdate: presenter browser: browser!

componentsUpdate: presenter browser: browser!

debuggerMethodSourceUpdate: presenter browser: browser!

debugPrintOn: aStream
	self printOn: aStream.
	self class instVarNames do: 
			[:instVarName |
			aStream
				tab;
				nextPutAll: instVarName;
				nextPut: $:;
				space;
				nextPutAll: (self instVarNamed: instVarName) printString;
				cr]!

debugPrintString
	| ws |
	ws := WriteStream on: String new.
	self debugPrintOn: ws.
	^ws contents!

dictionaryListUpdate: presenter

	!

dictionaryUpdate: presenter
	!

editInSession: aSession window: handle
	"api for opening an editor window on a service and putting the oop in the export set for the life of the window"

	command := #editInWindow:.
	commandArgs := Array with: handle.
	self issueCommand: self session: aSession!

emptyFilterListsIn: browser
	browser hasMethods
		ifTrue: 
			[browser categoryListPresenter sortBlock: [:x :y | x < y].
			browser variableListPresenter sortBlock: [:x :y | x < y]]!

excludedInstVars

	^#( 'events' )
!

filterUpdate: presenter browser: anObject
	!

frameListUpdate: aPresenter!

globalsUpdate: presenter!

initialize
	commandArgs := Array new!

initializePresenterList: presenter
	presenter sortBlock: [:x :y | x sortAspect < y sortAspect].
	presenter list: ListModel new!

isAnsweringService

	^false!

isBrowserService

	^false!

isClassService

	^false!

isComponentService
	^false!

isDefinedProject

	^true!

isDefinitionService

	^false!

isDictionaryService

	^false!

isInspectorService

	^false!

isLoggingService

	^false!

isMethodService

	^false!

isPackageService

	^false!

isProjectService

	^false!

isService
	^true!

issueCommand: service session: session
	^self issueCommands: (Array with: service) session: session!

issueCommands: services session: session
	^BrowserUpdate current issueCommands: services session: session!

isTestCase

	^false!

isUpdatableService
	^true!

methodFilterUpdate: presenter
	!

methodHistoryUpdated: historyBrowser
	!

methodListUpdate: presenter browser: browser!

methodSourceUpdate: presenter browser: anObject
	!

methodsUpdate: presenter
	!

methodUpdate: presenter browser: anObject
	!

name
	^nil!

newProject: presenter!

notRowanizedPackageName
	^self class notRowanizedPackageName!

packageGroupUpdate: presenter browser: browser!

packageServices
	"most services do not have packages"

	^Array new!

packagesUpdate: presenter!

packagesUpdate: presenter browser: browser parentPresenter: parentPresenter
	| packageServices selectedComponentPackages |
	(presenter class canUnderstand: #list) ifFalse: [^self].
	presenter list isEmpty ifTrue: [self initializePresenterList: presenter].
	parentPresenter selections detect: [:service | service name = self name] ifNone: [^self].
	selectedComponentPackages := (browser packageGroupPresenter selectionIfNone: [])
				ifNil: [self packageServices]
				ifNotNil: [:componentService | componentService packageServices].
	packageServices := self packageServices intersection: selectedComponentPackages.
	self
		updateList: presenter
		whilePreservingSelections: packageServices
		browser: browser.
	browser isClassSelected ifFalse: [self emptyFilterListsIn: browser]!

packageUpdate: presenter!

possiblyAddComponent: service to: treeModel withParent: parentService hierarchyServices: hierarchyServices
	| node |
	node := treeModel getNodeFor: service
				ifAbsent: 
					[treeModel add: service asChildOf: parentService.
					treeModel getNodeFor: service].
	node visited: true.
	(hierarchyServices at: service ifAbsent: [^self]) do: 
			[:aService |
			self
				possiblyAddHierarchyService: aService
				to: treeModel
				withParent: service
				hierarchyServices: hierarchyServices]!

possiblyAddHierarchyService: service to: treeModel withParent: parentService hierarchyServices: hierarchyServices
	| node |
	node := treeModel getNodeFor: service
				ifAbsent: 
					[treeModel add: service asChildOf: parentService.
					treeModel getNodeFor: service].
	node visited: true.
	(hierarchyServices at: service ifAbsent: [^self]) do: 
			[:aService |
			self
				possiblyAddHierarchyService: aService
				to: treeModel
				withParent: service
				hierarchyServices: hierarchyServices]!

postReload
	"most services will do nothing"

	!

postUpdate
	"Give the service a chance to clean up unnecessary objects after replication"

	!

postUpdateBlock
	"RowanAutoCommitService is the only use now. 
	Pushed the inst var to that class to conform with RSR
	replication protocols."

	^nil!

prepareForReplication
	"only replicate what is absolutely necessary. Each service knows how to do that. 
	This method prepares each command arg as well"
	commandArgs ifNotNil: [:args | args basicPrepareForReplication]!

printOn: aStream

	super printOn: aStream. 
	aStream nextPut: $:. 
	aStream nextPutAll: (self name ifNil: [nil printString])!

processListUpdate: aPresenter!

projectPackagesUpdate: aPresenter browser: anObject
	!

projectSelectionUpdate: aPresenter
!

projectsUpdate: aPresenter!

projectsUpdate: presenter browser: browser!

remoteServiceName
	self subclassResponsibility!

removed: presenter
	| service |
	(updateType = #removed:) ifFalse: [^self	"server must tell us to remove service"].
	service := presenter model asBag detect: [:svc | svc = self] ifNone: [^self].
	presenter model remove: service.
	presenter resetSelection!

removedClass: aPresenter!

removeDeletedClassesIn: presenter browser: browser classes: theClasses
	| updatedClasses removedClasses renamedClassNames |
	updatedClasses := theClasses select: [:classService | classService packageName = self name]
				thenCollect: [:classService | classService name asString].
	removedClasses := presenter list
				select: [:classService | classService packageName = self name and: [(updatedClasses includes: classService name) not]].
	renamedClassNames := theClasses collect: [:classService | classService renamedName].
	removedClasses := removedClasses
				reject: [:classService | renamedClassNames includes: classService name].
	removedClasses do: 
			[:removedClassService |
			(presenter selections includes: removedClassService)
				ifTrue: [presenter view noEventsDo: [presenter view resetSelection]]].
	removedClasses isEmpty ifTrue: [^self].
	presenter model
		setList: (ListModel withAll: (presenter list asArray copyWithoutAll: removedClasses))
		searchPolicy: SearchPolicy equality!

removedProject: presenter!

renamedClass: aClassService browser: anObject
	!

renamedClassInHierarchy: presenter browser: anObject
	!

replicateFrom: newService
	(newService class = self class and: [newService name = self name])
		ifTrue: [self basicReplicateFrom: newService]!

shouldReplicateInstVarAtIndex: index newService: anObject
	^true!

silentlyExpandHierarchyOneLevel: treeView
	!

stonOn: stonWriter
	| instanceVariableNames |
	(instanceVariableNames := self class allInstVarNames
				reject: [:iv | self excludedInstVars includes: iv]) isEmpty
		ifTrue: [stonWriter writeObject: self do: [stonWriter encodeMap: #()]]
		ifFalse: 
			[stonWriter writeObject: self
				streamMap: 
					[:dictionary |
					instanceVariableNames do: 
							[:each |
							(self instVarNamed: each)
								ifNotNil: [:value | dictionary at: each asSymbol put: value]
								ifNil: [self stonShouldWriteNilInstVars ifTrue: [dictionary at: each asSymbol put: nil]]]]]!

sunitMethodsUpdate: presenter browser: browser!

superclassListUpdate: presenter
	!

testClasses: presenter browser: anObject
	!

testPackages: presenter!

testResultUpdate: presenter browser: anObject
	!

toolTip
	^self displayString
!

updateBreakPoints: presenter browser: browser!

updateClassCategorySelectionsFor: presenter!

updateClassHierarchySelectionFor: presenter!

updateClassSelectionFor: presenter!

updatedClass: aPresenter browser: browser
	!

updatedClassDefinition: classDefinitionPresenter browser: browser

	
	!

updatedClassInHierarchy: aPresenter browser: projectBrowser!

updateDictionarySelectionsFor: presenter
	!

updatedOneLevelInClassHierarchy: classHierarchyPresenter browser: projectBrowser!

updateForSession: session

	"will not work for some services but does for many"
	
	self
		command: #update;
		commandArgs: Array new. 
	BrowserUpdate current issueCommands: (Array with: self) session: session!

updateList: presenter whilePreservingSelections: updates browser: anObject
	| replicate bag |
	bag := presenter list asBag.
	bag do: 
			[:service |
			replicate := updates detect: [:update | update = service] ifNone: [nil].
			replicate notNil ifTrue: [service replicateFrom: replicate]].
	updates
		do: [:update | ((bag includes: update) and: [update wasRenamed not]) ifFalse: [presenter model add: update]]!

updateMethodFilterSelectionFor: presenter!

updateMethodSelectionFor: presenter!

updatePackageSelectionsFor: presenter
	!

updateSelectorFor: presenter!

updateSuperclassSelectionFor: presenter!

updateSymbols: unused!

updateType
	^updateType!

updateType: anObject
	updateType := anObject!

updateVariable: listPresenter debugger: anObject
	!

variableDataUpdate: aPresenter!

variableListUpdate: aPresenter!

wasRenamed
	"not all services can be renamed"

	^false!

wasUpdated
	^wasUpdated!

wasUpdated: anObject
	wasUpdated := anObject! !
!RowanService categoriesForMethods!
addCachedSymbols:!public!updating! !
autoCommitUpdate:!public!updating! !
basicPrepareForReplication!public!replication! !
basicReplicateFrom:!public!replication! !
breakpointSettingChanged:!public!updating! !
chooseModel:using:!private!updating! !
classCategoryUpdate:!public!updating! !
classCommentUpdate:!public!updating! !
classDefinitionUpdate:!public!updating! !
classesHierarchyUpdate:!public!updating! !
classesUpdate:browser:!public!updating! !
classHierarchyUpdate:!public!updating! !
classHierarchyUpdate:browser:!public!updating! !
classHierarchyUpdate:browser:hierarchyServices:!public!updating! !
classMethodsUpdate:browser:!public!updating! !
classUpdate:!public!updating! !
clearCommand!Init / Release!public! !
clientDefinitionClass!public! !
command!accessing!public! !
command:!accessing!public! !
commandArgs!accessing!public! !
commandArgs:!accessing!public! !
componentPackagesUpdate:browser:!public!updating! !
componentsUpdate:browser:!public!updating! !
debuggerMethodSourceUpdate:browser:!public!updating! !
debugPrintOn:!printing!public! !
debugPrintString!printing!public! !
dictionaryListUpdate:!public!updating! !
dictionaryUpdate:!public!updating! !
editInSession:window:!commands!public! !
emptyFilterListsIn:!Init / Release!private! !
excludedInstVars!public!ston! !
filterUpdate:browser:!public!updating! !
frameListUpdate:!Debugger!public!updating! !
globalsUpdate:!public!updating! !
initialize!Init / Release!public! !
initializePresenterList:!Init / Release!private! !
isAnsweringService!public!testing! !
isBrowserService!public!testing! !
isClassService!public!testing! !
isComponentService!public!testing! !
isDefinedProject!public!testing! !
isDefinitionService!public!testing! !
isDictionaryService!public!testing! !
isInspectorService!public!testing! !
isLoggingService!public!testing! !
isMethodService!public!testing! !
isPackageService!public!testing! !
isProjectService!public!testing! !
isService!public!testing! !
issueCommand:session:!commands!public! !
issueCommands:session:!commands!public! !
isTestCase!public!testing! !
isUpdatableService!public!testing! !
methodFilterUpdate:!public!updating! !
methodHistoryUpdated:!must not strip!public!updating! !
methodListUpdate:browser:!public!updating! !
methodSourceUpdate:browser:!public!updating! !
methodsUpdate:!public!updating! !
methodUpdate:browser:!public!updating! !
name!accessing!public! !
newProject:!public!updating! !
notRowanizedPackageName!displaying!public! !
packageGroupUpdate:browser:!public!updating! !
packageServices!accessing!public! !
packagesUpdate:!public!updating! !
packagesUpdate:browser:parentPresenter:!public!updating! !
packageUpdate:!public!updating! !
possiblyAddComponent:to:withParent:hierarchyServices:!private!updating! !
possiblyAddHierarchyService:to:withParent:hierarchyServices:!private! !
postReload!public!replication! !
postUpdate!Init / Release!public! !
postUpdateBlock!accessing!private! !
prepareForReplication!public!replication! !
printOn:!printing!public! !
processListUpdate:!Debugger!public!updating! !
projectPackagesUpdate:browser:!public!updating! !
projectSelectionUpdate:!public!updating! !
projectsUpdate:!public!updating! !
projectsUpdate:browser:!public!updating! !
remoteServiceName!must not strip!public! !
removed:!public!updating! !
removedClass:!public!updating! !
removeDeletedClassesIn:browser:classes:!private!updating! !
removedProject:!public!updating! !
renamedClass:browser:!public!updating! !
renamedClassInHierarchy:browser:!public!updating! !
replicateFrom:!public!replication! !
shouldReplicateInstVarAtIndex:newService:!public!testing! !
silentlyExpandHierarchyOneLevel:!double dispatch!public! !
stonOn:!must not strip!public!ston! !
sunitMethodsUpdate:browser:!public!updating! !
superclassListUpdate:!public!updating! !
testClasses:browser:!public!updating! !
testPackages:!public!updating! !
testResultUpdate:browser:!public!updating! !
toolTip!printing!public! !
updateBreakPoints:browser:!public!updating! !
updateClassCategorySelectionsFor:!public!updating! !
updateClassHierarchySelectionFor:!public!updating! !
updateClassSelectionFor:!public!updating! !
updatedClass:browser:!public!updating! !
updatedClassDefinition:browser:!public!updating! !
updatedClassInHierarchy:browser:!public!updating! !
updateDictionarySelectionsFor:!public!updating! !
updatedOneLevelInClassHierarchy:browser:!public!updating! !
updateForSession:!actions!public! !
updateList:whilePreservingSelections:browser:!private! !
updateMethodFilterSelectionFor:!public!updating! !
updateMethodSelectionFor:!public!updating! !
updatePackageSelectionsFor:!public!updating! !
updateSelectorFor:!public!updating! !
updateSuperclassSelectionFor:!public!updating! !
updateSymbols:!public!updating! !
updateType!accessing!public! !
updateType:!accessing!public! !
updateVariable:debugger:!public!updating! !
variableDataUpdate:!Debugger!public!updating! !
variableListUpdate:!Debugger!public!updating! !
wasRenamed!public!testing! !
wasUpdated!accessing!private! !
wasUpdated:!accessing!private! !
!

!RowanService class methodsFor!

command: symbol withArgs: array
	| inst |
	inst := self new.
	inst
		command: symbol;
		commandArgs: array.
	^inst!

defaultIcon
	"Answer a suitable default icon to use for this class. Not all classes use their 
	default icon; one must define an appropriate #icon method in each class where the 
	icon required differs from that of the superclass."

	^(self environment at: #Icon) fromId: self defaultIconName.
!

defaultIconName
	"Answer a filename to use for an icon of this class."

	^File composeStem: 'Model' extension: 'ico'.!

icon
	"Answers an Icon that can be used to represent this class"

	^##(self) defaultIcon!

new
	^super new initialize!

notRowanizedPackageName
	^'(NONE)'!

templateClassName	^self name!

version
	"change this method carefully and only at Jadeite release boundaries.
	Failure to do so may prevent logins"

	^3200! !
!RowanService class categoriesForMethods!
command:withArgs:!instance creation!public! !
defaultIcon!private! !
defaultIconName!private! !
icon!private! !
new!initialization!public! !
notRowanizedPackageName!constants!public! !
templateClassName!public! !
version!public!version actions! !
!

