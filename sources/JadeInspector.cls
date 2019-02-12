"Filed out from Dolphin Smalltalk 7"!

JadeTextDocument subclass: #JadeInspector
	instanceVariableNames: 'instVarListPresenter className'
	classVariableNames: 'DefaultInspectorClass'
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeInspector guid: (GUID fromString: '{7cade1f1-0352-4ff0-a34d-888a4de0cd14}')!
JadeInspector comment: ''!
!JadeInspector categoriesForClass!Unclassified! !
!JadeInspector methodsFor!

contextObject

	^model.
!

createComponents

	super createComponents.
	instVarListPresenter := self add: ListPresenter new name: 'instVarList'.
!

createSchematicWiring

	super createSchematicWiring.
	instVarListPresenter 	when: #'selectionChanged' 	send: #'selectedInstVar' 	to: self.
	instVarListPresenter 	when: #'actionPerformed' 	send: #'inspectInstVar' 	to: self.
!

createView: string
	| newView |
	newView := super createView: string.
	(model isKindOf: ExternalInteger) ifTrue: [self registerWindow: newView handle rootObject: model].
	^newView!

inspectInstVar	
	JadeInspector 
		showOn: instVarListPresenter selection value 
		session: gciSession.
!

instVarListPresenter
	^instVarListPresenter!

instVarListPresenter: anObject
	instVarListPresenter := anObject!

isModified

	^false.
!

maxPrintStringSize
	^100000!

model: anObject
	"often a GsObject, but could be an Integer, String, etc."

	| object |
	object := (anObject isKindOf: String) ifTrue: [anObject replaceLfWithCrLf] ifFalse: [anObject].
	(anObject isKindOf: Symbol) ifTrue: [object := object asSymbol].
	model := object.
	codePane model: object! !
!JadeInspector categoriesFor: #contextObject!private! !
!JadeInspector categoriesFor: #createComponents!accessing!private! !
!JadeInspector categoriesFor: #createSchematicWiring!accessing!private! !
!JadeInspector categoriesFor: #createView:!public! !
!JadeInspector categoriesFor: #inspectInstVar!accessing!private! !
!JadeInspector categoriesFor: #instVarListPresenter!accessing!private! !
!JadeInspector categoriesFor: #instVarListPresenter:!accessing!private! !
!JadeInspector categoriesFor: #isModified!private! !
!JadeInspector categoriesFor: #maxPrintStringSize!private! !
!JadeInspector categoriesFor: #model:!private! !

!JadeInspector class methodsFor!

defaultInspectorClass

	DefaultInspectorClass isNil ifTrue: [DefaultInspectorClass := JadeInspector].

	^DefaultInspectorClass!

setDefaultInspectorClass: aJadeInspectorClass

	DefaultInspectorClass := aJadeInspectorClass
!

setNormalInspector

	self setDefaultInspectorClass: JadeInspector!

showOn: anObject session: aGciSession
	| class view |
	class := self defaultInspectorClass.
	view := self defaultView.
	^class new
		gciSession: aGciSession;
		model: anObject;
		createView: view;
		showShell;
		yourself! !
!JadeInspector class categoriesFor: #defaultInspectorClass!public! !
!JadeInspector class categoriesFor: #setDefaultInspectorClass:!public! !
!JadeInspector class categoriesFor: #setNormalInspector!public! !
!JadeInspector class categoriesFor: #showOn:session:!public! !

