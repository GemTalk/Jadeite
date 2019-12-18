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
	^self parentPresenter executeSelectionOrLine: contextObject!

inspectorContextObject
	^self parentPresenter contextObject value!

jadeInspect
	"build the window first, then pass the window handle to the inspector.
	This allows the inspector service to hold on to the resulting object 
	after the service is released. See 
	RowanInspectorService>>executeThenInspect: context: inWindow:"

	| service inspector |
	inspector := JadeiteInspector new gciSession: gciSession.
	inspector createView: JadeiteInspector defaultView.
	service := RowanInspectorService new
				executeThenInspect: self currentSelectionOrLine
				context: self inspectorContextObject
				session: gciSession
				windowHandle: inspector view handle value
				debugger: self parentPresenter.
	service compileErrorArray
		ifNotNil: 
			[[^self showCompileError: service compileErrorArray first] ensure: [service compileErrorArray: nil]].
	^inspector showOn: service! !
!JadeiteDebuggerMethodSourcePresenter categoriesFor: #clearBreakPointAt:in:!menu handlers!public! !
!JadeiteDebuggerMethodSourcePresenter categoriesFor: #executeSelectionOrLine:!menu handlers!public! !
!JadeiteDebuggerMethodSourcePresenter categoriesFor: #inspectorContextObject!private! !
!JadeiteDebuggerMethodSourcePresenter categoriesFor: #jadeInspect!Jade!private! !

