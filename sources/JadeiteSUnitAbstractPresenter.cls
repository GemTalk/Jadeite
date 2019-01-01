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

reset
	methodListPresenter model do: [:each | each testResult: nil].
	textResultPresenter value: String new.
	methodListPresenter view invalidate.
	textResultPresenter view backcolor: Color face3d!

runTests: methodServices
	| jadeResult |
	methodServices isEmpty ifTrue: [^self].
	jadeResult := JadeTestResult new.
	methodServices do: 
			[:methodService |
			| result resultArray |
			result := gciSession
						serverPerform: #runTestNamed:in:
						with: methodService selector
						with: methodService className.
			resultArray := result subStrings: ','.
			resultArray first ~= '0'
				ifTrue: 
					[methodService testResult: 'error'.
					jadeResult addError: methodService selector].
			resultArray second ~= '0'
				ifTrue: 
					[methodService testResult: 'failure'.
					jadeResult addFailure: methodService selector].
			resultArray third ~= '0'
				ifTrue: 
					[methodService testResult: 'passed'.
					jadeResult addPassed: methodService selector]].
	self updateResult: jadeResult.
	^jadeResult!

runTests: anOrderedCollection in: className
	| jadeResult |
	anOrderedCollection isEmpty ifTrue: [^self].
	jadeResult := JadeTestResult new.
	anOrderedCollection do: 
			[:methodService |
			| result resultArray |
			result := gciSession
						serverPerform: #runTestNamed:in:
						with: methodService selector
						with: className.
			resultArray := result subStrings: ','.
			resultArray first ~= '0'
				ifTrue: 
					[methodService testResult: 'error'.
					jadeResult addError: methodService selector].
			resultArray second ~= '0'
				ifTrue: 
					[methodService testResult: 'failure'.
					jadeResult addFailure: methodService selector].
			resultArray third ~= '0'
				ifTrue: 
					[methodService testResult: 'passed'.
					jadeResult addPassed: methodService selector]].
	self updateResult: jadeResult.
	^jadeResult!

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
!JadeiteSUnitAbstractPresenter categoriesFor: #reset!public! !
!JadeiteSUnitAbstractPresenter categoriesFor: #runTests:!public! !
!JadeiteSUnitAbstractPresenter categoriesFor: #runTests:in:!public! !
!JadeiteSUnitAbstractPresenter categoriesFor: #setColorFor:!public! !
!JadeiteSUnitAbstractPresenter categoriesFor: #textResultPresenter!accessing!private! !
!JadeiteSUnitAbstractPresenter categoriesFor: #textResultPresenter:!accessing!private! !
!JadeiteSUnitAbstractPresenter categoriesFor: #updateResult:!public! !

