"Filed out from Dolphin Smalltalk 7"!

JadeiteMethodListPresenter subclass: #JadeiteFindStringMethodListPresenter
	instanceVariableNames: 'findString'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteFindStringMethodListPresenter guid: (GUID fromString: '{5972612c-43ba-4906-a602-6e5ae6500eed}')!
JadeiteFindStringMethodListPresenter comment: ''!
!JadeiteFindStringMethodListPresenter categoriesForClass!Unclassified! !
!JadeiteFindStringMethodListPresenter methodsFor!

createSchematicWiring
	super createSchematicWiring.
	methodListPresenter methodListPresenter
		when: #selectionChanged
		send: #selectionChanged
		to: self!

findString
	^findString!

findString: anObject
	findString := anObject!

onViewOpened

	super onViewOpened.!

selectionChanged
	| sourceView selectionRanges offset |
	findString ifNil: [^self]. 
	sourceView := self methodSourcePresenter documentPresenter view.
	selectionRanges := OrderedCollection new.
	offset := 1.
	[(offset := sourceView findString: findString startingAt: offset + 1) = 0]
		whileFalse: [selectionRanges add: (offset to: offset + findString size - 1)].
	sourceView selectionRanges: selectionRanges! !
!JadeiteFindStringMethodListPresenter categoriesFor: #createSchematicWiring!initialization!public! !
!JadeiteFindStringMethodListPresenter categoriesFor: #findString!accessing!private! !
!JadeiteFindStringMethodListPresenter categoriesFor: #findString:!accessing!private! !
!JadeiteFindStringMethodListPresenter categoriesFor: #onViewOpened!event handlers!public! !
!JadeiteFindStringMethodListPresenter categoriesFor: #selectionChanged!event handlers!public! !

