"Filed out from Dolphin Smalltalk 7"!

JadeNavigationInspector subclass: #JadeiteServiceInspector
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteServiceInspector guid: (GUID fromString: '{e2a72e04-9d21-4c3c-8464-3f402c07b537}')!
JadeiteServiceInspector comment: ''!
!JadeiteServiceInspector categoriesForClass!Unclassified! !
!JadeiteServiceInspector methodsFor!

displayObject
	| contents |
	contents := OrderedCollection with: model myself with: '-.asOop' -> model oop.
	contents addAll: model objects.
	instVarListPresenter list: contents.
	model objects isEmpty ifFalse: [instVarListPresenter selection: model myself].
	className := model className!

expectedModelClass
	^RowanInspectorService!

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
			do: [:ex | self displayInstVarError: ex instVar: instVarListPresenter selection value]!

registerWindow: handle rootObject: oop
	^RowanBrowserService new
		registerWindow: handle value
		rootObject: oop
		session: self gciSession!

selectedInstVar
	| string |
	instVarListPresenter selection key = 'self'
		ifTrue: 
			[string := instVarListPresenter selection value.
			documentPresenter value: string.
			^self].
	instVarListPresenter selection key = '-.asOop'
		ifTrue: 
			[documentPresenter value: instVarListPresenter selection value.
			^self].
	string := [self printInstVar] on: GsRuntimeError
				do: 
					[:ex |
					ex errorReport number == 2106
						ifTrue: 
							["Forward reference error"
							ex return: 'an invalid or hidden object (perhaps a LargeObjectNode)'].
					ex pass].
	documentPresenter value: string! !
!JadeiteServiceInspector categoriesFor: #displayObject!displaying!public! !
!JadeiteServiceInspector categoriesFor: #expectedModelClass!private! !
!JadeiteServiceInspector categoriesFor: #printInstVar!displaying!public! !
!JadeiteServiceInspector categoriesFor: #registerWindow:rootObject:!private! !
!JadeiteServiceInspector categoriesFor: #selectedInstVar!accessing!private! !

!JadeiteServiceInspector class methodsFor!

showOn: service session: aGciSession
	^self new
		gciSession: aGciSession;
		model: service;
		createView: self defaultView;
		showShell;
		yourself! !
!JadeiteServiceInspector class categoriesFor: #showOn:session:!public! !

