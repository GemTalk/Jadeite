"Filed out from Dolphin Smalltalk 7"!

MethodSourcePresenter subclass: #JadeiteDebuggerMethodSourcePresenter
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteDebuggerMethodSourcePresenter guid: (GUID fromString: '{6d5123d9-0a7c-4211-a992-58969cbdc10d}')!
JadeiteDebuggerMethodSourcePresenter comment: ''!
!JadeiteDebuggerMethodSourcePresenter categoriesForClass!Unclassified! !
!JadeiteDebuggerMethodSourcePresenter methodsFor!

clearBreakPointAt: stepPoint in: browser
	super clearBreakPointAt: stepPoint in: browser.
	self parentPresenter clearBreakPointsAt: stepPoint!

editMenuStrings
	false ifTrue: [
		self editSaveMethod; undo; redo; cutSelection; copySelection; pasteClipboard; clearSelection; selectAll; editFind; editFindNext; editReplace; 
			jadeDisplay; jadeExecute; jadeInspect; browseSelectedClass.
	].
	^#(
		'&Edit'
		'&Save/Ctrl+S/editSaveMethod'
		'-'
		'&Undo/Ctrl+Z/undo'
		'&Redo/Ctrl+Y/redo'
		'Revert//editRevert'
		'-'
		'&Reformat Source/Ctrl+Shift+O/reformatSource'
		'-'
		'&Cu&t/Ctrl+X/cutSelection'
		'&Copy/Ctrl+C/copySelection'
		'&Paste/Ctrl+V/pasteClipboard'
		'&Delete/Delete/clearSelection'
		'-'
		'Select &All/Ctrl+A/selectAll'
		'-'
		'&Find/Ctrl+F/editFind'
		'Find &Next/F3/editFindNext'
		'&Replace/Ctrl+H/editReplace'
		'-'
		'Display/Ctrl+D/jadeDisplay'
		'Execute/Ctrl+E/jadeExecute'
		'Inspect/Ctrl+Q/jadeInspect'
		'Debug/Ctrl+B/jadeDebug'
	).
!

editRevert
	self isOkayToChange
		ifTrue: 
			[documentPresenter value: originalSource.
			self displayNoMods: self documentPresenter]!

executeSelectionOrLine: contextObject
	^self parentPresenter executeSelectionOrLine: contextObject!

inspectorContextObject
	^self parentPresenter contextObject!

jadeInspect
	| inspector |
	inspector := JadeiteInspector new gciSession: gciSession.
	^inspector
		evaluateSelectedTextIn: self
		thenInspectInContext: self inspectorContextObject
		debugger: self parentPresenter! !
!JadeiteDebuggerMethodSourcePresenter categoriesFor: #clearBreakPointAt:in:!menu handlers!public! !
!JadeiteDebuggerMethodSourcePresenter categoriesFor: #editMenuStrings!Jade!private! !
!JadeiteDebuggerMethodSourcePresenter categoriesFor: #editRevert!edit!private! !
!JadeiteDebuggerMethodSourcePresenter categoriesFor: #executeSelectionOrLine:!menu handlers!public! !
!JadeiteDebuggerMethodSourcePresenter categoriesFor: #inspectorContextObject!private! !
!JadeiteDebuggerMethodSourcePresenter categoriesFor: #jadeInspect!Jade!private! !

