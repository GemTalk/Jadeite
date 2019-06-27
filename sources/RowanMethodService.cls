"Filed out from Dolphin Smalltalk 7"!

RowanService subclass: #RowanMethodService
	instanceVariableNames: 'source selector methodDefinitions category packageName projectName className meta user hasSupers hasSubs isExtension inSelectedPackage references stepPoints selectedPackageServices superDisplayString accessedInstVars breakPoints oop compilationWarnings testResult definedPackage isTestMethod testRunClassName failedCompile comparisonSource'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanMethodService guid: (GUID fromString: '{f5550fdc-dbb4-4382-af82-88c561c0a9d1}')!
RowanMethodService comment: ''!
!RowanMethodService categoriesForClass!Kernel-Objects! !
!RowanMethodService methodsFor!

= methodService
	methodService isMethodService ifFalse:[^false].
	^selector = methodService selector
		and: [className = methodService className and: [meta = methodService meta]]!

accessedInstVars
	^accessedInstVars!

accessedInstVars: anObject
	accessedInstVars := anObject!

addBreakPointMenuAt: stepPoint to: aMenu presenter: presenter
	| desc args menuCommand |
	args := Array with: stepPoint with: presenter parentPresenter.
	(self breakPoints includes: stepPoint)
		ifTrue: 
			[command := #clearBreakPointAt:in:.
			desc := 'Clear break at step point ' , stepPoint printString]
		ifFalse: 
			[command := #setBreakPointAt:in:.
			desc := 'Break at step point ' , stepPoint printString].
	menuCommand := MessageSend
				receiver: presenter parentPresenter
				selector: command
				arguments: args.
	aMenu addCommand: menuCommand description: desc.
	^menuCommand!

appendToSourceMenu: aMenu presenter: methodSourcePresenter
	| stepPoint menuCommand messageSelector |
	self rowanFixMe. "when we can replace the dictionary browser, only send menu appends to the right menus" 
	stepPoint := self stepPointFromCursorIn: methodSourcePresenter.
	stepPoint isNil ifTrue: [^self].
	('*Methods*' match: aMenu text) ifTrue: [^self].	"Don't add breakpoints to the Methods menu. Let's keep it in the context menu for consistency."
	('*Debug*' match: aMenu text) ifTrue: [^self].	"Don't add breakpoints to the Debug menu. Let's keep it in the context menu for consistency."
	('*Jade*' match: aMenu text) ifTrue: [^self].	"Don't add breakpoints to the Jadeite menu. Let's keep it in the context menu for consistency."
	aMenu addSeparator.
	menuCommand := self
				addBreakPointMenuAt: stepPoint
				to: aMenu
				presenter: methodSourcePresenter.
	messageSelector := (stepPoints at: stepPoint) value.
	messageSelector isEmpty ifTrue: [^self].
	menuCommand := MessageSend
				receiver: methodSourcePresenter parentPresenter
				selector: #browseImplementorsOf:
				argument: messageSelector.
	aMenu addCommand: menuCommand description: 'Browse Implementors of ' , messageSelector printString.
	menuCommand := MessageSend
				receiver: methodSourcePresenter parentPresenter
				selector: #browseSendersOf:
				argument: messageSelector.
	aMenu addCommand: menuCommand description: 'Browse Senders of ' , messageSelector printString!

basicPrepareForReplication
	stepPoints := Array new.
	breakPoints := Array new.
	testRunClassName := nil!

basicSubSuperIcon
	hasSupers ifTrue: [^JadeSystemBrowserPresenter overriddenIcon].
	hasSubs ifTrue: [^JadeiteBrowserPresenter downArrowIcon].
	^Icon blank!

breakPoints

	^breakPoints!

category
	^category ifNil: ['']!

category: anObject
	category := anObject!

classMethodDisplayString
	| stream |
	stream := WriteStream on: String new.
	self displayOn: stream.
	^stream contents!

className
	^className!

className: anObject
	className := anObject asString!

classService

	^RowanClassService named: className!

comparisonSource
	^comparisonSource!

comparisonSource: anObject
	comparisonSource := anObject!

compilationWarnings
	^compilationWarnings!

copyBasicsFrom: oldService

	oop 		:= oldService oop.
	selector 	:= oldService selector.
	className := oldService className asString.
	meta 	:= oldService meta.!

definedPackage
	^definedPackage!

displayClassName
	^className , (meta ifTrue: [' class'] ifFalse: [String new])!

displayName
	^className , '>>' , selector!

displayOn: aStream
	aStream
		nextPutAll: (className ifNil: ['?']);
		nextPutAll: '>>';
		nextPutAll: (selector ifNil: ['?'])!

displayStringFor: displayThing
	isExtension
		ifTrue: 
			[displayThing forecolor: Color darkMagenta.
			inSelectedPackage ifFalse: [displayThing font beUnderlined ]]!

failedCompile
	^failedCompile!

hash
	^(selector hash bitXor: className hash) bitXor: meta hash!

hasSubs
	^hasSubs!

hasSubs: anObject
	hasSubs := anObject!

hasSupers
	^hasSupers!

hasSupers: anObject
	hasSupers := anObject!

icon
	testResult ifNil: [^self class icon].
	testResult = 'passed' ifTrue: [^true icon].
	testResult = 'failure' ifTrue: [^Warning icon].
	testResult = 'error' ifTrue: [^false icon].
	^self class icon!

implementorsOf: aString

	^methodDefinitions!

initialize
	super initialize. 
	inSelectedPackage := true.  
	failedCompile := false. !

inSelectedPackage

	^inSelectedPackage!

inSelectedPackage: anObject
	inSelectedPackage := anObject!

isExtension
	^isExtension!

isExtension: anObject
	isExtension := anObject!

isMethodService

	^true!

isReadOnly

	self rowanFixMe.
	^false!

isTestMethod
	^isTestMethod!

meta
	^meta!

meta: anObject
	meta := anObject!

methodDefinitions
	^methodDefinitions!

methodDefinitions: anObject
	methodDefinitions := anObject.
	self trigger: #changed!

methodName
	"for the old sunit in class browser tab"
	^selector!

methodSourceUpdate: presenter browser: browser
	| selection |
	selection := browser methodListSelection.
	selection ifNil: [^self].
	selection = self
		ifTrue: 
			[presenter view isModified
				ifFalse: 
					[presenter value: source.
					browser displayNoMods: presenter]]!

methodUpdate: presenter
	presenter list
		do: [:methodService | methodService = self ifTrue: [methodService replicateFrom: self]]!

name
	selector isNil ifTrue:[^String new].
	^selector asString!

oop

	^oop!

oopType

	^OopType64 fromInteger: oop!

packageName
	^packageName!

packageName: anObject
	packageName := anObject!

prepareForReplication
	super prepareForReplication.
	self basicPrepareForReplication!

printOn: target
	"Append, to the <puttableStream>, target, a string whose characters are a 
	the same as those which would result from sending a #printString
	message to the receiver.
	N.B. This is really intended for development use. #displayOn: and #displayString
	are complementary methods for generating strings for presentation to an
	end-user."

	| serviceClassName |
	serviceClassName := self class name.
	target 
		nextPutAll: (serviceClassName first isVowel ifTrue: ['an '] ifFalse: ['a ']);
		nextPutAll: serviceClassName;
		nextPut: $(;
		nextPutAll: className; 
		nextPutAll: '>>';
		nextPutAll: selector asString;
		nextPut: $). !

projectName
	^projectName!

projectName: anObject
	projectName := anObject!

references
	^references!

references: anObject
	references := anObject!

remoteServiceName
	^'Rowan methodServiceClass'!

replicateFrom: newService
	^(self isMethodService and: [newService isMethodService])
		ifTrue: 
			[self = newService ifTrue: [super replicateFrom: newService]]!

selectedPackageServices
	^selectedPackageServices!

selectedPackageServices: anObject browser: anObject1
	selectedPackageServices := anObject!

selector
	^selector!

selector: anObject
	selector := anObject!

selectorsDisplayString

	^className, '>>', selector!

setError
	testResult := 'error'!

setFailure
	testResult := 'failure'!

setPassed
	testResult := 'passed'!

shouldReplicateInstVarAtIndex: index newService: newService
	| isTestResultInstVar |
	isTestResultInstVar := (self class indexOfInstVar: 'testResult') = index.
	^isTestResultInstVar not or: [ isTestResultInstVar and: [(newService instVarAt: index) notNil]]!

sortAspect

	^selector!

source
	^source!

source: anObject
	source := anObject!

stepPointFromCursorIn: methodSourcePresenter
	| charIndex |
	charIndex := methodSourcePresenter view
				charNearestPosition: methodSourcePresenter view cursorPosition.
	self stepPoints size to: 1
		by: -1
		do: 
			[:index |
			| range |
			range := (self stepPoints at: index) key.
			(charIndex between: range start and: range stop) ifTrue: [^index]].
	^nil!

stepPoints

	(stepPoints notEmpty and: [stepPoints first key isInteger]) ifTrue: [
		stepPoints := stepPoints collect: [:each | 
			| range start char length |
			start := each key.
			char := source at: start.
			length := (char isAlphaNumeric or: [char = $_])
				ifTrue: [(source copyFrom: start + 1 to: source size) findFirst: [:eachChar | (eachChar isAlphaNumeric or: [eachChar = $_ or: [eachChar = $:]]) not]]
				ifFalse: [2].
			length = 0 ifTrue: [length := source size - start + 1].
			[
				2 < length and: [(source at: start) = $_].
			] whileTrue: [
				start := start + 1.
				length := length - 1.
			].
			range := Interval from: start to: start + length - 1.
			range -> each value.
		].
	].
	^stepPoints!

subSuperIcon
	^(self basicSubSuperIcon) imageIndex!

superDisplayString
	^superDisplayString!

superDisplayString: anObject
	superDisplayString := anObject!

testResult
	^testResult!

testResult: anObject
	testResult := anObject!

testResultUpdate: presenter browser: browser
	| existingService |
	existingService := presenter list detect: [:methodService | methodService = self] ifNone: [^self].
	testRunClassName ifNotNil: [browser selectedClass name = testRunClassName ifFalse: [^self]].
	existingService replicateFrom: self.
	presenter view invalidate!

toolTip
	| ws |
	ws := WriteStream on: String new.
	ws
		nextPutAll: 'Defined package: ';
		nextPutAll: definedPackage;
		cr;
		nextPutAll: 'Category: '; 
		nextPutAll: category.
	^ws contents!

unimplementedSelectors

	self rowanFixMe.
	^#()!

updateSelectorFromCompiledMethod: aString

	| stream | 
	stream := ReadStream on: aString. 
	stream skipWhile:[:char | char isDigit].
	selector := stream upToEnd. 


!

user
	^user!

user: anObject
	user := anObject! !
!RowanMethodService categoriesFor: #=!comparing!public! !
!RowanMethodService categoriesFor: #accessedInstVars!accessing!private! !
!RowanMethodService categoriesFor: #accessedInstVars:!accessing!private! !
!RowanMethodService categoriesFor: #addBreakPointMenuAt:to:presenter:!presenter support!private! !
!RowanMethodService categoriesFor: #appendToSourceMenu:presenter:!presenter support!public! !
!RowanMethodService categoriesFor: #basicPrepareForReplication!public!replication! !
!RowanMethodService categoriesFor: #basicSubSuperIcon!displaying!public! !
!RowanMethodService categoriesFor: #breakPoints!public! !
!RowanMethodService categoriesFor: #category!accessing!private! !
!RowanMethodService categoriesFor: #category:!accessing!private! !
!RowanMethodService categoriesFor: #classMethodDisplayString!displaying!public! !
!RowanMethodService categoriesFor: #className!accessing!private! !
!RowanMethodService categoriesFor: #className:!accessing!private! !
!RowanMethodService categoriesFor: #classService!public! !
!RowanMethodService categoriesFor: #comparisonSource!accessing!private! !
!RowanMethodService categoriesFor: #comparisonSource:!accessing!private! !
!RowanMethodService categoriesFor: #compilationWarnings!accessing!private! !
!RowanMethodService categoriesFor: #copyBasicsFrom:!public!updating! !
!RowanMethodService categoriesFor: #definedPackage!accessing!private! !
!RowanMethodService categoriesFor: #displayClassName!displaying!public! !
!RowanMethodService categoriesFor: #displayName!displaying!public! !
!RowanMethodService categoriesFor: #displayOn:!displaying!public! !
!RowanMethodService categoriesFor: #displayStringFor:!displaying!public! !
!RowanMethodService categoriesFor: #failedCompile!accessing!public! !
!RowanMethodService categoriesFor: #hash!comparing!public! !
!RowanMethodService categoriesFor: #hasSubs!accessing!private! !
!RowanMethodService categoriesFor: #hasSubs:!accessing!private! !
!RowanMethodService categoriesFor: #hasSupers!accessing!private! !
!RowanMethodService categoriesFor: #hasSupers:!accessing!private! !
!RowanMethodService categoriesFor: #icon!public!sunit! !
!RowanMethodService categoriesFor: #implementorsOf:!method accessing!public! !
!RowanMethodService categoriesFor: #initialize!initialization!public! !
!RowanMethodService categoriesFor: #inSelectedPackage!public!testing! !
!RowanMethodService categoriesFor: #inSelectedPackage:!accessing!public! !
!RowanMethodService categoriesFor: #isExtension!accessing!public! !
!RowanMethodService categoriesFor: #isExtension:!accessing!public! !
!RowanMethodService categoriesFor: #isMethodService!public!testing! !
!RowanMethodService categoriesFor: #isReadOnly!public!testing! !
!RowanMethodService categoriesFor: #isTestMethod!public!testing! !
!RowanMethodService categoriesFor: #meta!accessing!private! !
!RowanMethodService categoriesFor: #meta:!accessing!private! !
!RowanMethodService categoriesFor: #methodDefinitions!accessing!private! !
!RowanMethodService categoriesFor: #methodDefinitions:!accessing!private! !
!RowanMethodService categoriesFor: #methodName!accessing!private! !
!RowanMethodService categoriesFor: #methodSourceUpdate:browser:!public!updating! !
!RowanMethodService categoriesFor: #methodUpdate:!public!updating! !
!RowanMethodService categoriesFor: #name!accessing!public! !
!RowanMethodService categoriesFor: #oop!public! !
!RowanMethodService categoriesFor: #oopType!public! !
!RowanMethodService categoriesFor: #packageName!accessing!private! !
!RowanMethodService categoriesFor: #packageName:!accessing!private! !
!RowanMethodService categoriesFor: #prepareForReplication!public!replication! !
!RowanMethodService categoriesFor: #printOn:!printing!public! !
!RowanMethodService categoriesFor: #projectName!accessing!private! !
!RowanMethodService categoriesFor: #projectName:!accessing!private! !
!RowanMethodService categoriesFor: #references!accessing!private! !
!RowanMethodService categoriesFor: #references:!accessing!private! !
!RowanMethodService categoriesFor: #remoteServiceName!must not strip!public! !
!RowanMethodService categoriesFor: #replicateFrom:!public!updating! !
!RowanMethodService categoriesFor: #selectedPackageServices!accessing!private! !
!RowanMethodService categoriesFor: #selectedPackageServices:browser:!accessing!private! !
!RowanMethodService categoriesFor: #selector!accessing!private! !
!RowanMethodService categoriesFor: #selector:!accessing!private! !
!RowanMethodService categoriesFor: #selectorsDisplayString!displaying!public! !
!RowanMethodService categoriesFor: #setError!public!sunit! !
!RowanMethodService categoriesFor: #setFailure!public!sunit! !
!RowanMethodService categoriesFor: #setPassed!public!sunit! !
!RowanMethodService categoriesFor: #shouldReplicateInstVarAtIndex:newService:!public!replication!testing! !
!RowanMethodService categoriesFor: #sortAspect!accessing!public! !
!RowanMethodService categoriesFor: #source!accessing!private! !
!RowanMethodService categoriesFor: #source:!accessing!private! !
!RowanMethodService categoriesFor: #stepPointFromCursorIn:!presenter support!private! !
!RowanMethodService categoriesFor: #stepPoints!public! !
!RowanMethodService categoriesFor: #subSuperIcon!displaying!public! !
!RowanMethodService categoriesFor: #superDisplayString!accessing!private! !
!RowanMethodService categoriesFor: #superDisplayString:!accessing!private! !
!RowanMethodService categoriesFor: #testResult!accessing!public! !
!RowanMethodService categoriesFor: #testResult:!accessing!public! !
!RowanMethodService categoriesFor: #testResultUpdate:browser:!public!updating! !
!RowanMethodService categoriesFor: #toolTip!accessing!displaying!private! !
!RowanMethodService categoriesFor: #unimplementedSelectors!public! !
!RowanMethodService categoriesFor: #updateSelectorFromCompiledMethod:!private! !
!RowanMethodService categoriesFor: #user!accessing!private! !
!RowanMethodService categoriesFor: #user:!accessing!private! !

!RowanMethodService class methodsFor!

defaultIconName
	"Answer a filename to use for an icon of this class."

	^File composeStem: 'Message' extension: 'ico'.!

icon
	"Answers an Icon that can be used to represent this class"

	^##(self) defaultIcon ! !
!RowanMethodService class categoriesFor: #defaultIconName!private! !
!RowanMethodService class categoriesFor: #icon!private! !

