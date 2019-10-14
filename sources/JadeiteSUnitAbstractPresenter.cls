"Filed out from Dolphin Smalltalk 7"!

JadePresenter subclass: #JadeiteSUnitAbstractPresenter
	instanceVariableNames: 'methodListPresenter textResultPresenter'
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

debugTestMethodServices: methodServices className: className
	| jadeResult |
	methodServices isEmpty ifTrue: [^self].
	jadeResult := self
				runTestCommand: #debugTest:inClassName:
				methods: methodServices
				className: className.
	^jadeResult!

debugTests: methodServices
	self halt. 
	^self debugTestMethodServices: methodServices className: nil!

editSelectAll
	methodListPresenter selections: methodListPresenter list. !

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
	| jadeResult |
	jadeResult := JadeTestResult new.
	methodServices do: 
			[:methodService |
			| index |
			methodService
				command: command;
				commandArgs: (Array with: methodService selector with: (className ifNil: [methodService className])).
			self issueCommand: (Array with: methodService).
			methodService testResult = 'error' ifTrue: [jadeResult addError: methodService selector].
			methodService testResult = 'failure' ifTrue: [jadeResult addFailure: methodService selector].
			methodService testResult = 'passed' ifTrue: [jadeResult addPassed: methodService selector].
			index := methodServices indexOf: methodService.
			methodListPresenter view ensureVisible: index].
	self updateResult: jadeResult.
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

textResultPresenter
	^textResultPresenter!

textResultPresenter: anObject
	textResultPresenter := anObject!

updateResult: jadeResult
	jadeResult setSummary.
	self setColorFor: jadeResult! !
!JadeiteSUnitAbstractPresenter categoriesFor: #createComponents!public! !
!JadeiteSUnitAbstractPresenter categoriesFor: #debugTestMethodServices:className:!private! !
!JadeiteSUnitAbstractPresenter categoriesFor: #debugTests:!public! !
!JadeiteSUnitAbstractPresenter categoriesFor: #editSelectAll!menu handlers support!public! !
!JadeiteSUnitAbstractPresenter categoriesFor: #refresh!event handlers!public! !
!JadeiteSUnitAbstractPresenter categoriesFor: #refreshFromServerAfterAbort:!event handlers!public! !
!JadeiteSUnitAbstractPresenter categoriesFor: #reset!public! !
!JadeiteSUnitAbstractPresenter categoriesFor: #runTestCommand:methods:className:!private! !
!JadeiteSUnitAbstractPresenter categoriesFor: #runTestMethodServices:className:!private! !
!JadeiteSUnitAbstractPresenter categoriesFor: #runTests:!public! !
!JadeiteSUnitAbstractPresenter categoriesFor: #runTests:in:!public! !
!JadeiteSUnitAbstractPresenter categoriesFor: #setColorFor:!public! !
!JadeiteSUnitAbstractPresenter categoriesFor: #textResultPresenter!accessing!private! !
!JadeiteSUnitAbstractPresenter categoriesFor: #textResultPresenter:!accessing!private! !
!JadeiteSUnitAbstractPresenter categoriesFor: #updateResult:!public! !

