"Filed out from Dolphin Smalltalk 7"!

JadeNavigationInspector subclass: #JadeServiceInspector
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeServiceInspector guid: (GUID fromString: '{e2a72e04-9d21-4c3c-8464-3f402c07b537}')!
JadeServiceInspector comment: ''!
!JadeServiceInspector categoriesForClass!Unclassified! !
!JadeServiceInspector methodsFor!

displayObject
	instVarListPresenter
		list: model objects;
		selection: model objects first;
		yourself.
	className := model myself value!

printInstVar
	| answeringService |
	^
	[answeringService := RowanAnsweringService new.
	answeringService
		command: #printStringOf:toMaxSize:;
		commandArgs: (Array with: instVarListPresenter selection value with: self maxPrintStringSize).
	self issueCommand: (Array with: answeringService).
	answeringService answer]
			on: Error
			do: [:ex | self displayInstVarError: ex instVar: instVarListPresenter selection value]! !
!JadeServiceInspector categoriesFor: #displayObject!displaying!public! !
!JadeServiceInspector categoriesFor: #printInstVar!displaying!public! !

