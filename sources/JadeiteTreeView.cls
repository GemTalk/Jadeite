"Filed out from Dolphin Smalltalk 7"!

TreeView subclass: #JadeiteTreeView
	instanceVariableNames: 'toldToExpand'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteTreeView guid: (GUID fromString: '{3dd705c5-e522-4b7a-ae54-bbcfc4a3ab71}')!
JadeiteTreeView comment: ''!
!JadeiteTreeView categoriesForClass!MVP-Views! !
!JadeiteTreeView methodsFor!

expand: anObject
	toldToExpand := true.
	[super expand: anObject] ensure: [toldToExpand := false]!

hasPlaceholderChild: object
	| children |
	children := self model childrenOf: object.
	children isEmpty ifTrue: [^false].
	^children first isKindOf: RowanFillerClassService!

tvnItemExpanding: pNMHDR
	| object nmtv |
	Transcript
		cr;
		show: 'about to set nmtv'.
	nmtv := self notificationClass fromAddress: pNMHDR.
	Transcript
		cr;
		show: 'check if I am already expanded'.
	nmtv action = TVE_EXPAND ifFalse: [^nil].	"See if we have been expanded before"
	Transcript
		cr;
		show: 'get the object'.
	object := self objectFromHandle: nmtv itemNew hItem ifAbsent: [].
	Transcript
		cr;
		show: (self model getChildrenOf: object) printString.
	toldToExpand
		ifFalse: 
			[Transcript
				cr;
				show: 'I was not told to expand with #expand:'.
			(self hasPlaceholderChild: object) ifTrue: [Transcript cr; show: 'has placeholder child'. object silentlyExpandHierarchyOneLevel: self]].
	Transcript
		cr;
		show: 'children after expanding one level: ';
		show: (self model getChildrenOf: object) printString.
	Transcript
		cr;
		show: 'send the super message';
		cr;
		show: '--------';
		flush.
	super tvnItemExpanding: pNMHDR! !
!JadeiteTreeView categoriesFor: #expand:!event handling-win32!private! !
!JadeiteTreeView categoriesFor: #hasPlaceholderChild:!private!testing! !
!JadeiteTreeView categoriesFor: #tvnItemExpanding:!event handling-win32!private! !

!JadeiteTreeView class methodsFor!

defaultModel
	"Answer a default model to be assigned to the receiver when it is initialized."

	^JadeiteTreeModel new! !
!JadeiteTreeView class categoriesFor: #defaultModel!models!public! !

