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
	| newPath |
	newPath := JadeiteServerFileSaveDialog showOnSession: gciSession defaultFilePath: path.
	newPath ifNil: [^self].
	self writeDocumentTo: newPath!

updateCaption
	self caption: (gciSession titleBarFor: 'File contents of: ' , path)!

writeDocumentTo: newPath
	| service |
	service := RowanFileService new
				command: #write:;
				commandArgs: (Array with: codePane documentPresenter value);
				path: newPath.
	self issueCommand: service.
	codePane documentPresenter view isModified: false.
	path := newPath.
	self updateCaption! !
!JadeiteServerFileWorkspace categoriesForMethods!
isOkayToChangeFrame!event handlers!public! !
onCloseRequested:!event handlers!public! !
path!accessing!private! !
path:!accessing!private! !
saveDocument!public! !
saveDocumentAs!public! !
updateCaption!actions!public! !
writeDocumentTo:!private! !
!

!JadeiteServerFileWorkspace class methodsFor!

showOnSession: aGciSession path: path
	| inst service |
	inst := self new
				path: path;
				gciSession: aGciSession.
	service := RowanFileService new
				command: #fileContents;
				path: path.
	inst issueCommand: service.
	inst codePane documentPresenter value: service answer.
	inst
		gciSession: aGciSession;
		createView: self defaultView;
		showShell;
		yourself.
	^inst! !
!JadeiteServerFileWorkspace class categoriesForMethods!
showOnSession:path:!instance creation!public! !
!

