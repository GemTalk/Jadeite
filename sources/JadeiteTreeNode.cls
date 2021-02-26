"Filed out from Dolphin Smalltalk 7"!

TreeNode subclass: #JadeiteTreeNode
	instanceVariableNames: 'visited'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteTreeNode guid: (GUID fromString: '{94ece110-8aca-4f84-9f75-546040c70901}')!
JadeiteTreeNode comment: 'The inst var `marked` is used when updating a JadeiteTreeModel. 
After a node is added, it is marked.  Nodes that are not marked are subsequently removed. '!
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
!JadeiteTreeNode categoriesFor: #initialize!initialization!public! !
!JadeiteTreeNode categoriesFor: #resetVisited!public! !
!JadeiteTreeNode categoriesFor: #visited!accessing!private! !
!JadeiteTreeNode categoriesFor: #visited:!accessing!private! !

