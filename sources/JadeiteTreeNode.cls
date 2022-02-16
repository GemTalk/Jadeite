"Filed out from Dolphin Smallalk"!

TreeNode subclass: #JadeiteTreeNode
	instanceVariableNames: 'visited'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteTreeNode guid: (GUID fromString: '{94ece110-8aca-4f84-9f75-546040c70901}')!
JadeiteTreeNode comment: 'The inst var `visited` is used when updating a JadeiteTreeModel. 
After a node is added, it is visited.  Nodes that are not visited are subsequently removed. '!
!JadeiteTreeNode categoriesForClass!MVP-Models-Support! !
!JadeiteTreeNode methodsFor!

initialize
	super initialize.
	visited := true!

resetVisited

	visited := false!

visited
	^visited!

visited: anObject
	visited := anObject! !
!JadeiteTreeNode categoriesForMethods!
initialize!initialization!public! !
resetVisited!public! !
visited!accessing!private! !
visited:!accessing!private! !
!

