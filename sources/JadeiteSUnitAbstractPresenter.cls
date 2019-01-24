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

refresh

	self subclassResponsibility!

refreshFromServerAfterAbort: browserService
	self refresh!

reset
	methodListPresenter model do: [:each | each testResult: nil].
	textResultPresenter value: String new.
	methodListPresenter view invalidate.
	textResultPresenter view backcolor: Color face3d!

runTestMethodServices: methodServices className: className
	| jadeResult |
	methodServices isEmpty ifTrue: [^self].
	jadeResult := JadeTestResult new.
	methodServices do: 
			[:methodService |
			| index |
			methodService
				command: #runTest:inClassName:;
				commandArgs: (Array with: methodService selector with: (className ifNil: [methodService className])).
			self issueCommand: (Array with: methodService).
			methodService testResult = 'error' ifTrue: [jadeResult addError: methodService selector].
			methodService testResult = 'failure' ifTrue: [jadeResult addFailure: methodService selector].
			methodService testResult = 'passed' ifTrue: [jadeResult addPassed: methodService selector].
			index := methodServices indexOf: methodService.
			methodListPresenter view ensureVisible: index].
	self updateResult: jadeResult.
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
!JadeiteSUnitAbstractPresenter categoriesFor: #refresh!event handlers!public! !
!JadeiteSUnitAbstractPresenter categoriesFor: #refreshFromServerAfterAbort:!event handlers!public! !
!JadeiteSUnitAbstractPresenter categoriesFor: #reset!public! !
!JadeiteSUnitAbstractPresenter categoriesFor: #runTestMethodServices:className:!private! !
!JadeiteSUnitAbstractPresenter categoriesFor: #runTests:!public! !
!JadeiteSUnitAbstractPresenter categoriesFor: #runTests:in:!public! !
!JadeiteSUnitAbstractPresenter categoriesFor: #setColorFor:!public! !
!JadeiteSUnitAbstractPresenter categoriesFor: #textResultPresenter!accessing!private! !
!JadeiteSUnitAbstractPresenter categoriesFor: #textResultPresenter:!accessing!private! !
!JadeiteSUnitAbstractPresenter categoriesFor: #updateResult:!public! !

