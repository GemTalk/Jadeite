"Filed out from Dolphin Smalltalk 7"!

SUnitBrowserModel subclass: #JadeiteDevelopmentSUnitBrowserModel
	instanceVariableNames: 'testProcess'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteDevelopmentSUnitBrowserModel guid: (GUID fromString: '{387b1df5-68b7-4e54-b2d3-024b967dcaf3}')!
JadeiteDevelopmentSUnitBrowserModel comment: ''!
!JadeiteDevelopmentSUnitBrowserModel categoriesForClass!Unclassified! !
!JadeiteDevelopmentSUnitBrowserModel methodsFor!

runIndividualTests: tests
	testProcess := 
			[[self individualTests: tests do: [:each | self runTest: each]] ensure: [self stopTestProcess]]
					forkAt: Processor activePriority + 1!

stopTestProcess
	testProcess
		ifNotNil: 
			[testProcess terminate.
			testProcess := nil]!

testProcess
	^testProcess! !
!JadeiteDevelopmentSUnitBrowserModel categoriesFor: #runIndividualTests:!actions!private! !
!JadeiteDevelopmentSUnitBrowserModel categoriesFor: #stopTestProcess!actions!private! !
!JadeiteDevelopmentSUnitBrowserModel categoriesFor: #testProcess!accessing!public! !

