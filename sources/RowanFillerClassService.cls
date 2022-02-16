"Filed out from Dolphin Smallalk"!

RowanClassService subclass: #RowanFillerClassService
	instanceVariableNames: ''
	classVariableNames: 'RandomNumber'
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanFillerClassService guid: (GUID fromString: '{8ea8354b-4468-449a-9a3e-fde4420ab374}')!
RowanFillerClassService comment: 'Use this as a place holder class in the class hierarchy display. 

We don''t want to bring over every class in a hierarchy under some circumstances because that would be expensive. 
Instead, if we find out a class has children, but there are none returned from the server, stick one of these in the hierarchy
so that the > will display in the tree - indicating that the class is expandable.

When the expansion is done, we make a round trip to fill in the subclass details.'!
!RowanFillerClassService categoriesForClass!Unclassified! !
!RowanFillerClassService methodsFor!

hasSubclasses 
	^false!

initialize
	super initialize.
	name := 'Filler Class' , self class random next printString!

isInSymbolList
	^true! !
!RowanFillerClassService categoriesForMethods!
hasSubclasses!public! !
initialize!initialize!public! !
isInSymbolList!public! !
!

!RowanFillerClassService class methodsFor!

random
	RandomNumber ifNil: [RandomNumber := Random new].
	^RandomNumber! !
!RowanFillerClassService class categoriesForMethods!
random!public! !
!

