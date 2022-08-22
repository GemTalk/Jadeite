"Filed out from Dolphin Smallalk"!

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

jadeDebug
	| result nilHalt |
	nilHalt := 'nil halt. '.
	result := self parentPresenter execute: nilHalt , self currentSelectionOrLine
				context: self parentPresenter contextObject. 
	result key
		ifFalse: 
			[| adjustedArray |
			adjustedArray := result value first.
			adjustedArray at: 2 put: (adjustedArray at: 2) - nilHalt size.
			self showCompileError: adjustedArray].
	^result!

jadeDisplay
	| result |
	result := self parentPresenter execute: self currentSelectionOrLine
				context: self parentPresenter contextObject.
	result key ifTrue: [self showResult: result value] ifFalse: [self showCompileError: result value first].
	^result!

jadeExecute
	| result |
	result := self parentPresenter execute: self currentSelectionOrLine
				context: self parentPresenter contextObject.
	result key ifFalse: [self showCompileError: result value first].
	^result!

jadeInspect
	| inspector |
	inspector := JadeiteInspector new gciSession: gciSession.
	^inspector
		evaluateSelectedTextIn: self
		thenInspectInContext: self inspectorContextObject
		debugger: self parentPresenter!

onViewClosed
	super onViewClosed.
	BrowserUpdate current removeEventsTriggeredFor: self.! !
!JadeiteDebuggerMethodSourcePresenter categoriesForMethods!
clearBreakPointAt:in:!menu handlers!public! !
editMenuStrings!Jade!private! !
editRevert!edit!private! !
executeSelectionOrLine:!menu handlers!public! !
inspectorContextObject!private! !
jadeDebug!Jade!private! !
jadeDisplay!Jade!private! !
jadeExecute!Jade!private! !
jadeInspect!Jade!private! !
onViewClosed!events!public! !
!

!JadeiteDebuggerMethodSourcePresenter class methodsFor!

defaultAdditionalAccelerators
	^super defaultAdditionalAccelerators , #(#(#jadeDebug 'Ctrl+B'))! !
!JadeiteDebuggerMethodSourcePresenter class categoriesForMethods!
defaultAdditionalAccelerators!constants!public! !
!

