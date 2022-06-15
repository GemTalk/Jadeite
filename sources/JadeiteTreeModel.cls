"Filed out from Dolphin Smallalk"!

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
	(self childrenOf: anObject) do: [:child | self remove: child ifAbsent: []]!

removeWithoutNotification: anObject ifAbsent: aNiladicValuable view: theView
	"Jadeite - remove but don't trigger events to avoid trips to the server"

	| node parentNode parent |
	parent := self parentOf: anObject.
	node := self getNodeFor: anObject ifAbsent: [].
	node isNil ifTrue: [^aNiladicValuable value].
	parentNode := node parent.
	parentNode removeChildNode: node.
	self forgetNode: node.
	theView onItem: anObject removedFromParent: parent.
	^anObject!

resetVisited
	self asBag do: [:object | (self lookupNode: object) resetVisited]! !
!JadeiteTreeModel categoriesForMethods!
nodeClass!constants!public! !
removeChildrenOf:!public! !
removeWithoutNotification:ifAbsent:view:!public! !
resetVisited!constants!public! !
!

!JadeiteTreeModel class methodsFor!

defaultSearchPolicy
	"Answer the default <searchPolicy> used by instances of the receiver."

	^SearchPolicy equality! !
!JadeiteTreeModel class categoriesForMethods!
defaultSearchPolicy!constants!public! !
!

