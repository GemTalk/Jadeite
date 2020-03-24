"Filed out from Dolphin Smalltalk 7"!

JadePresenterA subclass: #JadeBrowserPresenter
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeBrowserPresenter guid: (GUID fromString: '{d80d9891-a83e-456b-8849-d67e57e2a490}')!
JadeBrowserPresenter comment: ''!
!JadeBrowserPresenter categoriesForClass!Unclassified! !
!JadeBrowserPresenter methodsFor!

onDragClass: aSession className: class
	| list |
	list := Array with: ((aSession newDragObject: class)
						format: #class data: class;
						yourself).
	aSession
		dragObjects: list;
		supportedOperations: #(#move #copy);
		defaultOperation: #move;
		yourself!

selectedClassName

	self subclassResponsibility! !
!JadeBrowserPresenter categoriesFor: #onDragClass:className:!drag & drop!public! !
!JadeBrowserPresenter categoriesFor: #selectedClassName!public!selection! !

