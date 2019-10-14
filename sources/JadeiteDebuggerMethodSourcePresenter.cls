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

executeSelectionOrLine: contextObject
	^self parentPresenter executeSelectionOrLine: contextObject! !
!JadeiteDebuggerMethodSourcePresenter categoriesFor: #clearBreakPointAt:in:!menu handlers!public! !
!JadeiteDebuggerMethodSourcePresenter categoriesFor: #executeSelectionOrLine:!menu handlers!public! !

