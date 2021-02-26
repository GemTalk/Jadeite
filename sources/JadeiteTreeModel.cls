"Filed out from Dolphin Smalltalk 7"!

TreeModel subclass: #JadeiteTreeModel
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteTreeModel guid: (GUID fromString: '{9da5c17c-b7f6-4238-a00b-164c06f3067b}')!
JadeiteTreeModel comment: ''!
!JadeiteTreeModel categoriesForClass!MVP-Models! !
!JadeiteTreeModel methodsFor!

nodeClass
	"Answer the class of object to be used to represent the receiver's nodes."

	^JadeiteTreeNode!

resetVisited
	self asBag do: [:object | (self lookupNode: object) resetVisited]! !
!JadeiteTreeModel categoriesFor: #nodeClass!constants!public! !
!JadeiteTreeModel categoriesFor: #resetVisited!constants!public! !

!JadeiteTreeModel class methodsFor!

defaultSearchPolicy
	"Answer the default <searchPolicy> used by instances of the receiver."

	^SearchPolicy equality! !
!JadeiteTreeModel class categoriesFor: #defaultSearchPolicy!constants!public! !

