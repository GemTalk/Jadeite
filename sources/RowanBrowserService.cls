"Filed out from Dolphin Smalltalk 7"!

RowanService subclass: #RowanBrowserService
	instanceVariableNames: 'projects removedMethods allClasses hierarchyServices testPackages testCount autoCommit'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanBrowserService guid: (GUID fromString: '{9c5e8a88-ca64-403c-8f81-6c70c46926f0}')!
RowanBrowserService comment: ''!
!RowanBrowserService categoriesForClass!Unclassified! !
!RowanBrowserService methodsFor!

= browserService
	^browserService isBrowserService and: [name = browserService name]!

aborted: presenter browser: browser
	browser refreshFromServerAfterAbort: self!

allClasses
	^allClasses!

autoCommitUpdate: browser
	browser autoCommit: autoCommit!

basicPrepareForReplication
	"don't call anything potentially recursive here.
	method services don't iterate over subcollections"

	removedMethods
		ifNotNil: [removedMethods do: [:methodService | methodService basicPrepareForReplication]]!

excludedInstVars
	^super excludedInstVars , #('hierarchyServices')!

hash
	^name hash!

isBrowserService

	^true!

name
	"browser services aren't named, but (for convenience) can respond"

	^nil!

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
	removals := presenter list select:[:projectService | (projects includes: projectService) not]. 
	presenter model removeAll: removals. 
	self updateList: presenter whilePreservingSelections: projects!

registerWindow: handle rootObject: oop session: session
	self
		command: #saveRootObject:windowHandle:;
		commandArgs: (Array with: oop with: handle).
	JadePresenter issueCommand: (Array with: self) session: session!

releaseReferencedServices
	projects ifNotNil: [projects do: [:service | service releaseReferencedServices]].
	projects := Array new!

releaseWindow: handle session: session
	self
		command: #releaseWindowHandle:;
		commandArgs: (Array with: handle).
	JadePresenter issueCommand: (Array with: self) session: session!

reloadProjects: selections presenter: presenter
	self
		command: #reloadProjects:andUpdateServices:;
		commandArgs: (Array with: selections with: BrowserUpdate current selectedServices).
	presenter issueCommand: (Array with: self)!

removedMethods
	^removedMethods!

removedMethods: anObject
	removedMethods := anObject!

replicateFrom: newService
	self isBrowserService ifTrue: [super replicateFrom: newService]!

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
!RowanBrowserService categoriesFor: #=!comparing!public! !
!RowanBrowserService categoriesFor: #aborted:browser:!public!updating! !
!RowanBrowserService categoriesFor: #allClasses!accessing!private! !
!RowanBrowserService categoriesFor: #autoCommitUpdate:!public!updating! !
!RowanBrowserService categoriesFor: #basicPrepareForReplication!public!replication! !
!RowanBrowserService categoriesFor: #excludedInstVars!public!ston! !
!RowanBrowserService categoriesFor: #hash!comparing!public! !
!RowanBrowserService categoriesFor: #isBrowserService!public!testing! !
!RowanBrowserService categoriesFor: #name!accessing!public! !
!RowanBrowserService categoriesFor: #prepareForReplication!public!replication! !
!RowanBrowserService categoriesFor: #printOn:!printing!public! !
!RowanBrowserService categoriesFor: #projects!accessing!public! !
!RowanBrowserService categoriesFor: #projectsUpdate:!public!updating! !
!RowanBrowserService categoriesFor: #registerWindow:rootObject:session:!commands!public!registering windows! !
!RowanBrowserService categoriesFor: #releaseReferencedServices!public! !
!RowanBrowserService categoriesFor: #releaseWindow:session:!commands!public!registering windows! !
!RowanBrowserService categoriesFor: #reloadProjects:presenter:!commands!public! !
!RowanBrowserService categoriesFor: #removedMethods!accessing!private! !
!RowanBrowserService categoriesFor: #removedMethods:!accessing!private! !
!RowanBrowserService categoriesFor: #replicateFrom:!public!replication!updating! !
!RowanBrowserService categoriesFor: #testCount!accessing!private! !
!RowanBrowserService categoriesFor: #testCount:!accessing!private! !
!RowanBrowserService categoriesFor: #testPackages:!public!updating! !

