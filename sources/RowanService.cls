"Filed out from Dolphin Smalltalk 7"!

Model subclass: #RowanService
	instanceVariableNames: 'remoteService name isDirty command commandArgs updateType'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanService guid: (GUID fromString: '{c91bf577-a5a9-4782-b6be-c05df3222bc9}')!
RowanService comment: ''!
!RowanService categoriesForClass!Kernel-Objects! !
!RowanService methodsFor!

aborted: presenter browser: browser
	
	!

autoCommitUpdate: browser!

basicPrepareForReplication
	"don't call anything potentially recursive here"!

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

classMethodsUpdate: presenter browser: anObject
	!

classUpdate: presenter
	!

clearCommand

	command := nil. 
	commandArgs := nil. !

clientDefinitionClass

	^self subclassResponsibility!

command
	^command!

command: symbol
	command := symbol.!

commandArgs
	^commandArgs!

commandArgs: anObject
	commandArgs := anObject!

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

dictionaryUpdate: presenter
	!

displayName
	"for logging. for now"

	^name!

displayString

	^self name!

emptyFilterListsIn: browser
	browser categoryListPresenter sortBlock: [:x :y | x < y].
	browser variableListPresenter sortBlock: [:x :y | x < y].!

excludedInstVars

	^#( 'events' )
!

filterUpdate: presenter browser: anObject
	!

frameListUpdate: aPresenter!

globalsUpdate: presenter!

initialize

	commandArgs := Array new. !

initializePresenterList: presenter
	presenter sortBlock: [:x :y | x sortAspect < y sortAspect].
	presenter list: ListModel new!

isAnsweringService

	^false!

isBrowserService

	^false!

isClassService

	^false!

isDirty
	^isDirty!

isDirty: anObject
	isDirty := anObject!

isLoggingService

	^false!

isMethodService

	^false!

isPackageService

	^false!

isProjectService

	^false!

isTestCase

	^false!

isUpdatableService
	^true!

methodFilterUpdate: presenter
	!

methodSourceUpdate: presenter browser: anObject
	!

methodsUpdate: presenter
	!

methodUpdate: presenter
	!

name
	^name!

name: aString
	name := aString asString!

notRowanizedPackageName
	^self class notRowanizedPackageName!

packagesUpdate: presenter!

prepareForReplication
	"only replicate what is absolutely necessary. Each service knows how to do that. 
	This method prepares each command arg as well"

	commandArgs ifNotNil: [:args | args basicPrepareForReplication]!

printOn: aStream

	super printOn: aStream. 
	aStream nextPut: $:. 
	aStream nextPutAll: (name ifNil: [nil printString])!

processListUpdate: aPresenter!

projectPackagesUpdate: aPresenter browser: anObject
	!

projectSelectionUpdate: aPresenter
!

projectsUpdate: aPresenter!

releaseReferencedServices
	"Give the service a chance to clean up unnecessary objects after replication"

	!

remoteService
	^remoteService!

remoteServiceName
	self subclassResponsibility!

removed: presenter
	| service |
	updateType == #removed: ifFalse: [^self	"server must tell us to remove service"].
	service := presenter model asBag detect: [:svc | svc = self] ifNone: [^self].
	presenter model remove: service!

removedClass: aPresenter!

removedProject: presenter!

replicateFrom: newService
	(newService class = self class and: [newService name = self name])
		ifTrue: 
			[1 to: self class instSize
				do: 
					[:index |
					(self shouldReplicateInstVarAtIndex: index newService: newService)
						ifTrue: [self instVarAt: index put: (newService instVarAt: index)]]]!

shouldReplicateInstVarAtIndex: index newService: anObject
	^true!

sortAspect

	^name!

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

testClasses: presenter!

testPackages: presenter!

testResultUpdate: presenter browser: anObject
	!

toolTip
	^self displayString
!

updateClassCategorySelectionsFor: presenter!

updateClassHierarchySelectionFor: presenter!

updateClassSelectionFor: presenter!

updatedClass: aPresenter browser: anObject
	!

updatedClassDefinition: classDefinitionPresenter browser: browser

	
	!

updatedClassInHierarchy: aPresenter browser: projectBrowser!

updateDictionarySelectionsFor: presenter
	!

updateList: presenter whilePreservingSelections: updates
	| replicate |
	presenter list copy do: 
			[:service |
			replicate := updates detect: [:update | update = service] ifNone: [nil].
			replicate notNil ifTrue: [service replicateFrom: replicate]].
	updates do: [:update | (presenter list includes: update) not ifTrue: [presenter model add: update]]!

updateMethodFilterSelectionFor: presenter!

updateMethodSelectionFor: presenter!

updatePackageSelectionsFor: presenter
	!

updateSelectorFor: presenter!

updateSuperclassSelectionFor: presenter!

updateType
	^updateType!

updateType: anObject
	updateType := anObject!

variableDataUpdate: aPresenter!

variableListUpdate: aPresenter! !
!RowanService categoriesFor: #aborted:browser:!public!updating! !
!RowanService categoriesFor: #autoCommitUpdate:!public!updating! !
!RowanService categoriesFor: #basicPrepareForReplication!public!replication! !
!RowanService categoriesFor: #classCategoryUpdate:!public!updating! !
!RowanService categoriesFor: #classCommentUpdate:!public!updating! !
!RowanService categoriesFor: #classDefinitionUpdate:!public!updating! !
!RowanService categoriesFor: #classesHierarchyUpdate:!public!updating! !
!RowanService categoriesFor: #classesUpdate:browser:!public!updating! !
!RowanService categoriesFor: #classHierarchyUpdate:!public!updating! !
!RowanService categoriesFor: #classHierarchyUpdate:browser:!public!updating! !
!RowanService categoriesFor: #classMethodsUpdate:browser:!public!updating! !
!RowanService categoriesFor: #classUpdate:!public!updating! !
!RowanService categoriesFor: #clearCommand!Init / Release!public! !
!RowanService categoriesFor: #clientDefinitionClass!public! !
!RowanService categoriesFor: #command!accessing!public! !
!RowanService categoriesFor: #command:!accessing!public! !
!RowanService categoriesFor: #commandArgs!accessing!public! !
!RowanService categoriesFor: #commandArgs:!accessing!public! !
!RowanService categoriesFor: #debugPrintOn:!printing!public! !
!RowanService categoriesFor: #debugPrintString!printing!public! !
!RowanService categoriesFor: #dictionaryUpdate:!public!updating! !
!RowanService categoriesFor: #displayName!displaying!public! !
!RowanService categoriesFor: #displayString!displaying!public! !
!RowanService categoriesFor: #emptyFilterListsIn:!Init / Release!private! !
!RowanService categoriesFor: #excludedInstVars!public!ston! !
!RowanService categoriesFor: #filterUpdate:browser:!public!updating! !
!RowanService categoriesFor: #frameListUpdate:!Debugger!public!updating! !
!RowanService categoriesFor: #globalsUpdate:!public!updating! !
!RowanService categoriesFor: #initialize!Init / Release!public! !
!RowanService categoriesFor: #initializePresenterList:!Init / Release!private! !
!RowanService categoriesFor: #isAnsweringService!public!testing! !
!RowanService categoriesFor: #isBrowserService!public!testing! !
!RowanService categoriesFor: #isClassService!public!testing! !
!RowanService categoriesFor: #isDirty!accessing!public! !
!RowanService categoriesFor: #isDirty:!accessing!public! !
!RowanService categoriesFor: #isLoggingService!public!testing! !
!RowanService categoriesFor: #isMethodService!public!testing! !
!RowanService categoriesFor: #isPackageService!public!testing! !
!RowanService categoriesFor: #isProjectService!public!testing! !
!RowanService categoriesFor: #isTestCase!public!testing! !
!RowanService categoriesFor: #isUpdatableService!public!testing! !
!RowanService categoriesFor: #methodFilterUpdate:!public!updating! !
!RowanService categoriesFor: #methodSourceUpdate:browser:!public!updating! !
!RowanService categoriesFor: #methodsUpdate:!public!updating! !
!RowanService categoriesFor: #methodUpdate:!public!updating! !
!RowanService categoriesFor: #name!accessing!public! !
!RowanService categoriesFor: #name:!accessing!public! !
!RowanService categoriesFor: #notRowanizedPackageName!displaying!public! !
!RowanService categoriesFor: #packagesUpdate:!public!updating! !
!RowanService categoriesFor: #prepareForReplication!public!replication! !
!RowanService categoriesFor: #printOn:!printing!public! !
!RowanService categoriesFor: #processListUpdate:!Debugger!public!updating! !
!RowanService categoriesFor: #projectPackagesUpdate:browser:!public!updating! !
!RowanService categoriesFor: #projectSelectionUpdate:!public!updating! !
!RowanService categoriesFor: #projectsUpdate:!public!updating! !
!RowanService categoriesFor: #releaseReferencedServices!Init / Release!public! !
!RowanService categoriesFor: #remoteService!public! !
!RowanService categoriesFor: #remoteServiceName!must not strip!public! !
!RowanService categoriesFor: #removed:!public!updating! !
!RowanService categoriesFor: #removedClass:!public!updating! !
!RowanService categoriesFor: #removedProject:!public!updating! !
!RowanService categoriesFor: #replicateFrom:!public!replication!updating! !
!RowanService categoriesFor: #shouldReplicateInstVarAtIndex:newService:!public!testing! !
!RowanService categoriesFor: #sortAspect!accessing!public! !
!RowanService categoriesFor: #stonOn:!must not strip!public!ston! !
!RowanService categoriesFor: #sunitMethodsUpdate:browser:!public!updating! !
!RowanService categoriesFor: #superclassListUpdate:!public!updating! !
!RowanService categoriesFor: #testClasses:!public!updating! !
!RowanService categoriesFor: #testPackages:!public!updating! !
!RowanService categoriesFor: #testResultUpdate:browser:!public!updating! !
!RowanService categoriesFor: #toolTip!printing!public! !
!RowanService categoriesFor: #updateClassCategorySelectionsFor:!public!updating! !
!RowanService categoriesFor: #updateClassHierarchySelectionFor:!public!updating! !
!RowanService categoriesFor: #updateClassSelectionFor:!public!updating! !
!RowanService categoriesFor: #updatedClass:browser:!public!updating! !
!RowanService categoriesFor: #updatedClassDefinition:browser:!public!updating! !
!RowanService categoriesFor: #updatedClassInHierarchy:browser:!public!updating! !
!RowanService categoriesFor: #updateDictionarySelectionsFor:!public!updating! !
!RowanService categoriesFor: #updateList:whilePreservingSelections:!private! !
!RowanService categoriesFor: #updateMethodFilterSelectionFor:!public!updating! !
!RowanService categoriesFor: #updateMethodSelectionFor:!public!updating! !
!RowanService categoriesFor: #updatePackageSelectionsFor:!public!updating! !
!RowanService categoriesFor: #updateSelectorFor:!public!updating! !
!RowanService categoriesFor: #updateSuperclassSelectionFor:!public!updating! !
!RowanService categoriesFor: #updateType!accessing!public! !
!RowanService categoriesFor: #updateType:!accessing!public! !
!RowanService categoriesFor: #variableDataUpdate:!Debugger!public!updating! !
!RowanService categoriesFor: #variableListUpdate:!Debugger!public!updating! !

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

	^File composeStem: 'Magic' extension: 'ico'.!

icon
	"Answers an Icon that can be used to represent this class"

	^##(self) defaultIcon!

new
	^super new initialize!

notRowanizedPackageName
	^'(NONE)'! !
!RowanService class categoriesFor: #command:withArgs:!instance creation!public! !
!RowanService class categoriesFor: #defaultIcon!private! !
!RowanService class categoriesFor: #defaultIconName!private! !
!RowanService class categoriesFor: #icon!private! !
!RowanService class categoriesFor: #new!initialization!public! !
!RowanService class categoriesFor: #notRowanizedPackageName!constants!public! !

