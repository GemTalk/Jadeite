"Filed out from Dolphin Smalltalk 7"!

RowanProjectService subclass: #RowanDefinedProjectService
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanDefinedProjectService guid: (GUID fromString: '{10fbdfa7-183d-43e5-b1f1-18b76d206b16}')!
RowanDefinedProjectService comment: ''!
!RowanDefinedProjectService categoriesForClass!Unclassified! !
!RowanDefinedProjectService methodsFor!

isDefinedProject

	^true!

newProject: presenter
	presenter list detect: [:projectService | projectService = self]
		ifNone: 
			[presenter list add: self.
			presenter view invalidate]! !
!RowanDefinedProjectService categoriesFor: #isDefinedProject!public!testing! !
!RowanDefinedProjectService categoriesFor: #newProject:!public!updating! !

