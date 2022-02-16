"Filed out from Dolphin Smallalk"!

RowanCommandResult subclass: #RowanProjectsUpdate
	instanceVariableNames: 'projects modifiedProjects selection'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanProjectsUpdate guid: (GUID fromString: '{c47a8cd5-d11c-486b-83a2-a1e1839bb959}')!
RowanProjectsUpdate comment: ''!
!RowanProjectsUpdate categoriesForClass!Unclassified! !
!RowanProjectsUpdate methodsFor!

projectSelectionUpdate: presenter
	| newSelections |
	newSelections := presenter list
				select: [:service | (selection detect: [:sel | sel name = service name] ifNone: []) notNil].
	presenter selections: newSelections!

projectsUpdate: presenter
	"don't just replace the list as we want to preserve selections"
	presenter list isEmpty ifTrue: [^presenter list: projects].
	presenter list addAll: (projects difference: presenter list).
	presenter list removeAll: (presenter list difference: projects)! !
!RowanProjectsUpdate categoriesForMethods!
projectSelectionUpdate:!public!updating! !
projectsUpdate:!public!updating! !
!

!RowanProjectsUpdate class methodsFor!

new
	^super new! !
!RowanProjectsUpdate class categoriesForMethods!
new!instance creation!public! !
!

