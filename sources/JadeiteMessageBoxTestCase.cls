"Filed out from Dolphin Smallalk"!

JadeiteAbstractTestCase subclass: #JadeiteMessageBoxTestCase
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteMessageBoxTestCase guid: (GUID fromString: '{e2a64efd-c6d7-4ed5-beff-b3f8215f808c}')!
JadeiteMessageBoxTestCase comment: 'Jadeite tests go around MessageBox''s to make testing predictable. 

Test that this test infrastructure change works. '!
!JadeiteMessageBoxTestCase categoriesForClass!Unclassified! !
!JadeiteMessageBoxTestCase methodsFor!

setUp
	super setUp.
	TestMessageBox enableJadeiteTestMessageBox!

tearDown
	super tearDown.
	TestMessageBox disableJadeiteTestMessageBox!

testClearResultAfterEachUse
	TestMessageBox plannedResult: #oneTime.
	self assert: TestMessageBox plannedResult == #oneTime.
	self assertIsNil: TestMessageBox plannedResult!

testEnableTestMessageBox
	TestMessageBox disableJadeiteTestMessageBox.
	self assert: MessageBox new isKindOf: MessageBox.
	TestMessageBox enableJadeiteTestMessageBox. 
	self assert: MessageBox new isKindOf: TestMessageBox.
	!

testMessageBox
	"remember that the debugging this test may be problematic
	if you don't turn off the test message box first. 
	TestMessageBox disableJadeiteTestMessageBox"

	| boolean answer |
	TestMessageBox enableJadeiteTestMessageBox.
	TestMessageBox plannedResult: #yes.
	boolean := MessageBox confirm: 'Do you want some ice cream?'.
	self assert: boolean.
	boolean := TestMessageBox plannedResult: #no.
	boolean := MessageBox confirm: 'Did you shave the yak today?'.
	self deny: boolean.
	TestMessageBox plannedResult: #noAnswer.
	answer := MessageBox notify: 'There will be no answer'.
	self assert: answer == MessageBox.
	TestMessageBox plannedResult: #noAnswer.
	answer := MessageBox notify: 'Warnings do not return answer'.
	self assert: answer == MessageBox!

testRemoveGlobalHook
	TestMessageBox disableJadeiteTestMessageBox.
	self assertIsNil: (Smalltalk at: #JadeiteTestsActive ifAbsent:[]).
	TestMessageBox enableJadeiteTestMessageBox. 
	self assert: (Smalltalk at: #JadeiteTestsActive).
	! !
!JadeiteMessageBoxTestCase categoriesForMethods!
setUp!public!support! !
tearDown!public!support! !
testClearResultAfterEachUse!public!test! !
testEnableTestMessageBox!public!test! !
testMessageBox!public!test! !
testRemoveGlobalHook!public!test! !
!

