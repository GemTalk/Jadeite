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

removeChildrenOf: anObject
	"Jadeite - remove all children but don't trigger events to avoid trips to the server"

	(self childrenOf: anObject) do: [:child | self remove: child ifAbsent: []]!

removeWithoutNotification: anObject ifAbsent: aNiladicValuable
	"Jadeite - remove but don't trigger events to avoid trips to the server"

	| node parentNode |
	node := self getNodeFor: anObject ifAbsent: [].
	node isNil ifTrue: [^aNiladicValuable value].
	parentNode := node parent.
	parentNode removeChildNode: node.
	self forgetNode: node.
	^anObject!

resetVisited
	self asBag do: [:object | (self lookupNode: object) resetVisited]! !
!JadeiteTreeModel categoriesFor: #nodeClass!constants!public! !
!JadeiteTreeModel categoriesFor: #removeChildrenOf:!public! !
!JadeiteTreeModel categoriesFor: #removeWithoutNotification:ifAbsent:!public! !
!JadeiteTreeModel categoriesFor: #resetVisited!constants!public! !

!JadeiteTreeModel class methodsFor!

defaultSearchPolicy
	"Answer the default <searchPolicy> used by instances of the receiver."

	^SearchPolicy equality! !
!JadeiteTreeModel class categoriesFor: #defaultSearchPolicy!constants!public! !

