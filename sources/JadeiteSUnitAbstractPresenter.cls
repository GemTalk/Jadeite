"Filed out from Dolphin Smallalk"!

JadePresenter subclass: #JadeiteSUnitAbstractPresenter
	instanceVariableNames: 'methodListPresenter textResultPresenter shouldStopTestRun testProcess'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteSUnitAbstractPresenter guid: (GUID fromString: '{472418d5-e1b6-4d52-aa6f-01de7f19d38f}')!
JadeiteSUnitAbstractPresenter comment: ''!
!JadeiteSUnitAbstractPresenter categoriesForClass!Unclassified! !
!JadeiteSUnitAbstractPresenter methodsFor!

createComponents
	super createComponents.
	methodListPresenter := self add: ListPresenter new name: 'testCases'.
	textResultPresenter := self add: TextPresenter new name: 'textResult'!

debugTestAsFailureMethodServices: methodServices className: className
	| jadeResult |
	methodServices isEmpty ifTrue: [^self].
	jadeResult := self
				runTestCommand: #debugTestAsFailure:inClassName:
				methods: methodServices
				className: className.
	^jadeResult!

debugTestMethodServices: methodServices className: className
	| jadeResult |
	methodServices isEmpty ifTrue: [^self].
	jadeResult := self
				runTestCommand: #debugTest:inClassName:
				methods: methodServices
				className: className.
	^jadeResult!

debugTests: methodServices
	^self subclassResponsibility!

editSelectAll
	methodListPresenter selections: methodListPresenter list. !

initialize
	super initialize.
	shouldStopTestRun := false!

methodListPresenter
	^methodListPresenter!

methodListPresenter: anObject
	methodListPresenter := anObject!

refresh

	self subclassResponsibility!

refreshFromServerAfterAbort: browserService
	self refresh!

reset
	
	methodListPresenter model do: [:each | each testResult: nil].
	textResultPresenter value: String new.
	methodListPresenter view invalidate.
	textResultPresenter view backcolor: Color face3d!

runTestCommand: command methods: methodServices className: className
	| jadeResult index |
	jadeResult := JadeTestResult new.
	methodServices do: 
			[:methodService |
			methodService
				command: command;
				commandArgs: (Array with: methodService selector with: (className ifNil: [methodService className])).
			self issueCommand: methodService.
			methodService testResult = 'error' ifTrue: [jadeResult addError: methodService].
			methodService testResult = 'failure' ifTrue: [jadeResult addFailure: methodService].
			methodService testResult = 'passed' ifTrue: [jadeResult addPassed: methodService].
			index := methodListPresenter list indexOf: methodService.
			methodListPresenter view updateItem: methodService atIndex: index.
			methodListPresenter view ensureVisible: index.
			methodListPresenter view update.
			shouldStopTestRun ifTrue: [^shouldStopTestRun := false]].
	self updateResult: jadeResult.
	methodListPresenter view ensureVisible: index.	"ensure last test run is visible"
	shouldStopTestRun := false.
	^jadeResult!

runTestMethodServices: methodServices className: className
	| jadeResult |
	methodServices isEmpty ifTrue: [^self]. 
	jadeResult := self
				runTestCommand: #runTest:inClassName:
				methods: methodServices
				className: className.
	^jadeResult!

runTests: methodServices
	^self runTestMethodServices: methodServices className: nil!

runTests: methodServices in: className
	^self runTestMethodServices: methodServices className: className!

selectedClass
	^self subclassResponsibility!

setColorFor: aJadeTestResult
	textResultPresenter value: aJadeTestResult summary.
	aJadeTestResult failures do: 
			[:eachSymbol |
			methodListPresenter model 
				do: [:eachTest | eachTest selector = eachSymbol ifTrue: [eachTest setFailure]]].
	aJadeTestResult errors do: 
			[:eachSymbol |
			methodListPresenter model
				do: [:eachTest | eachTest selector = eachSymbol ifTrue: [eachTest setError]]].
	aJadeTestResult passed do: 
			[:eachSymbol |
			methodListPresenter model
				do: [:eachTest | eachTest selector = eachSymbol ifTrue: [eachTest setPassed]]].
	methodListPresenter view invalidate.
	textResultPresenter view backcolor: aJadeTestResult backgroundColor!

stopTestProcess
	testProcess
		ifNotNil: 
			[shouldStopTestRun := true.
			[shouldStopTestRun] whileTrue: [(Delay forMilliseconds: 1) wait].
			testProcess ifNotNil: [:proc | proc terminate].
			testProcess := nil]!

textResultPresenter
	^textResultPresenter!

textResultPresenter: anObject
	textResultPresenter := anObject!

updateResult: jadeResult
	jadeResult setSummary.
	self setColorFor: jadeResult! !
!JadeiteSUnitAbstractPresenter categoriesForMethods!
createComponents!public! !
debugTestAsFailureMethodServices:className:!private! !
debugTestMethodServices:className:!private! !
debugTests:!public! !
editSelectAll!menu handlers support!public! !
initialize!initialization!public! !
methodListPresenter!accessing!private! !
methodListPresenter:!accessing!private! !
refresh!event handlers!public! !
refreshFromServerAfterAbort:!event handlers!public! !
reset!public! !
runTestCommand:methods:className:!private! !
runTestMethodServices:className:!private! !
runTests:!public! !
runTests:in:!public! !
selectedClass!accessing!public! !
setColorFor:!public! !
stopTestProcess!menu handlers!public! !
textResultPresenter!accessing!private! !
textResultPresenter:!accessing!private! !
updateResult:!public! !
!

