"Filed out from Dolphin Smallalk"!

JadeWorkspace subclass: #JadeiteServerFileWorkspace
	instanceVariableNames: 'path'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteServerFileWorkspace guid: (GUID fromString: '{2729959b-d846-40e2-9c1b-8614ca3b2eef}')!
JadeiteServerFileWorkspace comment: ''!
!JadeiteServerFileWorkspace categoriesForClass!Unclassified! !
!JadeiteServerFileWorkspace methodsFor!

path
	^path!

path: anObject
	path := anObject.
	!

saveDocument
	| service |
	service := RowanFileService new
				command: #write:;
				commandArgs: (Array with: codePane documentPresenter value);
				path: path.
	self issueCommand: service!

updateCaption
	self caption: (gciSession titleBarFor: 'File contents of: ' , path)! !
!JadeiteServerFileWorkspace categoriesForMethods!
path!accessing!private! !
path:!accessing!private! !
saveDocument!public! !
updateCaption!actions!public! !
!

!JadeiteServerFileWorkspace class methodsFor!

showOnSession: aGciSession path: path contents: contents
	| inst |
	inst := (self new path: path). 
	inst codePane documentPresenter value: contents. 
	inst
		gciSession: aGciSession;
		createView: self defaultView;
		showShell;
		yourself.
	^inst! !
!JadeiteServerFileWorkspace class categoriesForMethods!
showOnSession:path:contents:!instance creation!public! !
!

