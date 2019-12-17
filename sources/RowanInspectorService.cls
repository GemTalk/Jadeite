"Filed out from Dolphin Smalltalk 7"!

RowanService subclass: #RowanInspectorService
	instanceVariableNames: 'oop objects myself className'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanInspectorService guid: (GUID fromString: '{b80c7b87-3ce0-4b36-a288-1e52506958dd}')!
RowanInspectorService comment: ''!
!RowanInspectorService categoriesForClass!Unclassified! !
!RowanInspectorService methodsFor!

= inspectorService
	^inspectorService isInspectorService ifTrue: [oop = inspectorService oop] ifFalse: [false]!

className
	^className!

className: anObject
	className := anObject!

hash
	^oop hash!

initialize
	super initialize. 
	objects := Array new. !

inspect: anOop session: session
	oop := anOop value.
	self
		command: #inspect:;
		commandArgs: (Array with: oop).
	BrowserUpdate current issueCommands: (Array with: self) session: session!

isInspectorService

	^true!

myself
	^myself!

myself: anObject
	myself := anObject!

objects
	^objects!

objects: anObject
	objects := anObject!

oop
	^oop! !
!RowanInspectorService categoriesFor: #=!comparison!public! !
!RowanInspectorService categoriesFor: #className!accessing!private! !
!RowanInspectorService categoriesFor: #className:!accessing!private! !
!RowanInspectorService categoriesFor: #hash!comparison!private! !
!RowanInspectorService categoriesFor: #initialize!initialization!public! !
!RowanInspectorService categoriesFor: #inspect:session:!public! !
!RowanInspectorService categoriesFor: #isInspectorService!public!testing! !
!RowanInspectorService categoriesFor: #myself!accessing!private! !
!RowanInspectorService categoriesFor: #myself:!accessing!private! !
!RowanInspectorService categoriesFor: #objects!accessing!private! !
!RowanInspectorService categoriesFor: #objects:!accessing!private! !
!RowanInspectorService categoriesFor: #oop!accessing!private! !

