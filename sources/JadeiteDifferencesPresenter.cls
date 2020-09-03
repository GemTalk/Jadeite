"Filed out from Dolphin Smalltalk 7"!

DifferencesPresenter subclass: #JadeiteDifferencesPresenter
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteDifferencesPresenter guid: (GUID fromString: '{01824f1b-4abe-4f39-b9af-8f9a9b4202dc}')!
JadeiteDifferencesPresenter comment: ''!
!JadeiteDifferencesPresenter categoriesForClass!MVP-Presenters! !
!JadeiteDifferencesPresenter methodsFor!

comparisonValueChanged
	self refresh!

createComponents

	beforePresenter := self add: JadeTextPresenter new name: 'before'.
	afterPresenter := self add: JadeTextPresenter new name: 'after'.
	beforeTitlePresenter := self add: JadeTextPresenter new name: 'beforeTitle'.
	afterTitlePresenter := self add: JadeTextPresenter new name: 'afterTitle'!

createSchematicWiring
	super createSchematicWiring.
	beforePresenter
		when: #dragOver:
			send: #onDragOverSource:
			to: self;
		when: #drop:
			send: #onDropOnBefore:
			to: self;
		when: #valueChanged
			send: #comparisonValueChanged
			to: self.
	afterPresenter
		when: #dragOver:
			send: #onDragOverSource:
			to: self;
		when: #drop:
			send: #onDropOnAfter:
			to: self;
		when: #valueChanged
			send: #comparisonValueChanged
			to: self!

onDragOverSource: aDragDropSession
	aDragDropSession operation: nil.
	aDragDropSession dragObjects isEmpty ifTrue: [^self].
	aDragDropSession suggestedTarget isNil ifTrue: [^self].
	self setDragOperationsFor: aDragDropSession!

onDropOnAfter: aDragDropSession
	self
		set: afterPresenter
		to: aDragDropSession suggestedSource source
		andReset: beforePresenter.
	aDragDropSession suggestedTarget: nil	"nil out the suggestedTarget so the TextPresenter does not try to act on the drop"!

onDropOnBefore: aDragDropSession
	self
		set: beforePresenter
		to: aDragDropSession suggestedSource source
		andReset: afterPresenter.
	aDragDropSession suggestedTarget: nil	"nil out the suggestedTarget so the TextPresenter does not try to act on the drop"!

set: presenter to: string andReset: otherPresenter
	"Set the value of the otherPresenter to a new value.
	To get a proper #refresh though it was necessary to
	also reset the value of the other presenter. Seems 
	to be a bug in the DifferencesPresenter. "

	| value |
	presenter value: string.
	value := otherPresenter value.
	otherPresenter value: String new.
	otherPresenter value: value.
	self refresh!

setDragOperationsFor: aDragDropSession
	aDragDropSession dragSource topShell == self topShell
		ifTrue: [aDragDropSession operation: nil]
		ifFalse: 
			[aDragDropSession
				supportedOperations: #(#copy #move);
				operation: #copy;
				yourself]! !
!JadeiteDifferencesPresenter categoriesFor: #comparisonValueChanged!event handlers!public! !
!JadeiteDifferencesPresenter categoriesFor: #createComponents!initializing!private! !
!JadeiteDifferencesPresenter categoriesFor: #createSchematicWiring!initialize/release!public! !
!JadeiteDifferencesPresenter categoriesFor: #onDragOverSource:!event handlers!public! !
!JadeiteDifferencesPresenter categoriesFor: #onDropOnAfter:!event handlers!public! !
!JadeiteDifferencesPresenter categoriesFor: #onDropOnBefore:!event handlers!public! !
!JadeiteDifferencesPresenter categoriesFor: #set:to:andReset:!public! !
!JadeiteDifferencesPresenter categoriesFor: #setDragOperationsFor:!event handlers support!private! !

