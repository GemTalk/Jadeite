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

isOkayToChangeFrame
	^codePane isOkayToChange!

onCloseRequested: boolValueHolder
	self isOkayToChangeFrame ifFalse: [^boolValueHolder value: false].
	super onCloseRequested: boolValueHolder!

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
	self issueCommand: service.
	codePane documentPresenter view isModified: false. !

saveDocumentAs
	| service newPath |
	newPath := JadeiteServerFileSaveDialog showOnSession: gciSession defaultPath: path.
	newPath ifNil: [^self].
	service := RowanFileService new
				command: #write:;
				commandArgs: (Array with: codePane documentPresenter value);
				path: newPath.
	self issueCommand: service.
	codePane documentPresenter view isModified: false. 
	path := newPath.
	self updateCaption!

updateCaption
	self caption: (gciSession titleBarFor: 'File contents of: ' , path)! !
!JadeiteServerFileWorkspace categoriesForMethods!
isOkayToChangeFrame!event handlers!public! !
onCloseRequested:!event handlers!public! !
path!accessing!private! !
path:!accessing!private! !
saveDocument!public! !
saveDocumentAs!public! !
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

