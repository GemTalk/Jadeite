"Filed out from Dolphin Smallalk"!

JadeShell subclass: #JadeiteLoadSpecEditor
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteLoadSpecEditor guid: (GUID fromString: '{d49fae44-24d8-4cfb-9c43-9be0ca22455c}')!
JadeiteLoadSpecEditor comment: ''!
!JadeiteLoadSpecEditor categoriesForClass!Unclassified! !
!JadeiteLoadSpecEditor methodsFor!

createSchematicWiring
	super createSchematicWiring.
	self
		when: #closeRequested:
		send: #onCloseRequested:
		to: myPresenter!

editLoadSpecFromFile
	| path |
	"path := FileOpenDialog new showModal ifNil: [^self]."

	"would like a server file browser someday"
	path := '/uffda2/users/ewinger/shared/repos/RowanSample9/rowan/specs/spec_0061.ston'.
	^self editLoadSpecFromFile: path!

editLoadSpecFromFile: path
	| loadSpecService |
	loadSpecService := RowanLoadSpecService new loadSpecPath: path.
	^self editLoadSpecService: loadSpecService!

editLoadSpecFromOop: oop
	| loadSpecService |
	loadSpecService := RowanLoadSpecService new loadSpecOop: oop.
	^self editLoadSpecService: loadSpecService!

editLoadSpecService: loadSpecService
	self createView: self class defaultView.
	model := loadSpecService editInSession: gciSession window: self view handle value.
	self updateCaption.
	model session: self gciSession.
	myPresenter
		model: model;
		displayLoadSpecification;
		displayTabs.
	^self showShell!

exportLoadSpec
	^myPresenter exportLoadSpec!

loadLoadSpec
	^myPresenter loadLoadSpec!

presenterClass
	^JadeiteLoadSpecPresenter!

updateCaption
	self caption: (gciSession titleBarFor: 'Load Specification Editor')! !
!JadeiteLoadSpecEditor categoriesForMethods!
createSchematicWiring!initialization!public! !
editLoadSpecFromFile!instance creation!public! !
editLoadSpecFromFile:!instance creation!public! !
editLoadSpecFromOop:!instance creation!public! !
editLoadSpecService:!instance creation!public! !
exportLoadSpec!event handlers!public! !
loadLoadSpec!event handlers!public! !
presenterClass!accessing!public! !
updateCaption!public! !
!

!JadeiteLoadSpecEditor class methodsFor!

editLoadSpecFromFileInSession: session
	| inst |
	inst := self new gciSession: session. 
	^inst editLoadSpecFromFile!

editLoadSpecFromOop:  loadSpecOop session: session
	| inst |
	inst := self new gciSession: session. 
	^inst editLoadSpecFromOop: loadSpecOop!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1141 1351 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ReferenceView) 34 14 nil 416 34 2 8 1140850688 131073 592 nil 480 nil 7 nil nil nil 592 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteLoadSpecPresenter) #resource_Default_view nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 1 1 498 1109 1273 592 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 42 2 0 0 124 2 0 0] 8 #() 498 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 946 #fixedParentRight 1 946 #fixedParentTop 1 946 #fixedParentBottom 1 170 192 880 nil nil nil nil nil 1 nil nil nil nil 1 nil nil 690 138 144 34 1 754 #createAt:extent: 34 2 498 6513 21 498 1141 1351 416 834 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 184 12 0 0 10 0 0 0 242 14 0 0 173 2 0 0] 34 1 592 896 nil 27 )! !
!JadeiteLoadSpecEditor class categoriesForMethods!
editLoadSpecFromFileInSession:!instance creation!public! !
editLoadSpecFromOop:session:!instance creation!public! !
resource_Default_view!public!resources-views! !
!

