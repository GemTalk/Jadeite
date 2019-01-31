"Filed out from Dolphin Smalltalk 7"!

JadeValueDialog subclass: #JadeFindDialog
	instanceVariableNames: 'nameEntryPresenter'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeFindDialog guid: (GUID fromString: '{c0493b4f-823f-4a6d-8fc7-dc5b9cdf7aca}')!
JadeFindDialog comment: ''!
!JadeFindDialog categoriesForClass!Unclassified! !
!JadeFindDialog methodsFor!

createComponents

	super createComponents.
	nameEntryPresenter		:= self add: TextPresenter		new name: 'nameEntry'.
!

createSchematicWiring

	super createSchematicWiring.
	nameEntryPresenter	when: #valueChanged 	send: #updateList 	to: self.
!

onViewOpened
	super onViewOpened. 
	nameEntryPresenter value: '*'! !
!JadeFindDialog categoriesFor: #createComponents!private! !
!JadeFindDialog categoriesFor: #createSchematicWiring!private! !
!JadeFindDialog categoriesFor: #onViewOpened!event handlers!public! !

