"Filed out from Dolphin Smalltalk 7"!

JadeiteInspectorDataCuratorTestCase subclass: #JadeiteInspectorTestCase
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteInspectorTestCase guid: (GUID fromString: '{e9bef516-9ceb-4fa5-9f71-0673eae11259}')!
JadeiteInspectorTestCase comment: ''!
!JadeiteInspectorTestCase categoriesForClass!Unclassified! !
!JadeiteInspectorTestCase methodsFor!

setUp
	user := 'SystemUser'.
	super setUp!

test_inspectorRootObjectRegistered
	| remoteObject inspectorHandle |
	self testsIssue: #issue385 withTitle: 'Inspector should keep associated root object alive'.
	remoteObject := session executeString: 'Object new'.
	inspector := JadeInspector showOn: remoteObject session: session.
	inspectorHandle := inspector view handle value.
	self assert: (session
				executeString: '(RowanBrowserService new openWindows at: ' , inspectorHandle printString
						, ' ifAbsent:[]) asOop')
		equals: remoteObject value.
	inspector view close.
	self assertIsNil: (session
				executeString: 'RowanBrowserService new openWindows at: ' , inspectorHandle printString
						, ' ifAbsent:[]')!

test_inspectorRootSpecialObjectNotRegistered
	| remoteObject inspectorHandle |
	self testsIssue: #issue385 withTitle: 'Inspector should keep associated root object alive'.
	remoteObject := session executeString: '$a'.
	inspector := JadeInspector showOn: remoteObject session: session.
	inspectorHandle := inspector view handle value.
	self assert: (session
				executeString: 'RowanBrowserService new openWindows at: ' , inspectorHandle printString
						, ' ifAbsent:[]')
		equals: $a!

test_openProjectsBrowser
	| remoteObject shell |
	remoteObject := session
				executeString: 'RowanClassService new'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	shell := inspector browseClass.
	[self assert: (shell isKindOf: JadeiteBrowser)] ensure: [self destroy: shell]!

test_openProjectsBrowserOnClass
	| remoteObject shell |
	remoteObject := session
				executeString: 'RowanClassService'
				fromContext: nil
				environment: 0.
	inspector := JadeInspector showOn: remoteObject session: session.
	shell := inspector browseClass.
	[self assert: (shell isKindOf: JadeiteBrowser)] ensure: [self destroy: shell]! !
!JadeiteInspectorTestCase categoriesFor: #setUp!public!setup teardown! !
!JadeiteInspectorTestCase categoriesFor: #test_inspectorRootObjectRegistered!public! !
!JadeiteInspectorTestCase categoriesFor: #test_inspectorRootSpecialObjectNotRegistered!public! !
!JadeiteInspectorTestCase categoriesFor: #test_openProjectsBrowser!public! !
!JadeiteInspectorTestCase categoriesFor: #test_openProjectsBrowserOnClass!public! !

