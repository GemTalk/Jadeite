"Filed out from Dolphin Smalltalk 7"!

RowanService subclass: #RowanMethodService
	instanceVariableNames: 'source selector methodDefinitions category packageName projectName className meta user hasSupers hasSubs isExtension inSelectedPackage references stepPoints selectedPackageServices superDisplayString accessedInstVars breakPoints oop compilationWarnings testResult definedPackage isTestMethod testRunClassName failedCompile comparisonSource firstReference renamedName isMethodForBlock homeMethodOop hasMethodHistory searchString definedClassName name'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanMethodService guid: (GUID fromString: '{f5550fdc-dbb4-4382-af82-88c561c0a9d1}')!
RowanMethodService comment: 'Don''t change the order of the inst vars without checking
the index of the firstReference & testResults inst vars. These have
constant methods for performance. 

#indexOfTestResultInstVar
#indexOfFirstReferenceInstVar'!
!RowanMethodService categoriesForClass!Kernel-Objects! !
!RowanMethodService methodsFor!

<= methodService
	(methodService isKindOf: RowanMethodService) ifFalse: [^false].
	^className = methodService className
		ifTrue: [selector <= methodService selector]
		ifFalse: [className <= methodService className]!

= methodService
	methodService isMethodService ifFalse: [^false].
	^selector = methodService selector
		and: [className = methodService className and: [meta = methodService meta]]!

>= methodService
	(methodService isKindOf: RowanMethodService) ifFalse: [^false].
	^className = methodService className
		ifTrue: [selector >= methodService selector]
		ifFalse: [className >= methodService className]!

accessedInstVars
	^accessedInstVars!

accessedInstVars: anObject
	accessedInstVars := anObject!

addBreakPointMenuAt: stepPoint to: aMenu presenter: presenter
	| desc args menuCommand |
	args := Array with: stepPoint with: presenter parentPresenter.
	(self positiveBreakpoints includes: stepPoint)
		ifTrue: 
			[command := #clearBreakPointAt:in:.
			desc := 'Clear break at step point ' , stepPoint printString.
			menuCommand := MessageSend
						receiver: presenter parentPresenter
						selector: command
						arguments: args.
			aMenu addCommand: menuCommand description: desc.
			(breakPoints includes: stepPoint)
				ifTrue: 
					[command := #disableBreakPointAt:in:.
					desc := 'Disable break at step point ' , stepPoint printString]
				ifFalse: 
					[command := #enableBreakPointAt:in:.
					desc := 'Enable break at step point ' , stepPoint printString].
			menuCommand := MessageSend
						receiver: presenter parentPresenter
						selector: command
						arguments: args.
			aMenu addCommand: menuCommand description: desc]
		ifFalse: 
			[command := #setBreakPointAt:in:.
			desc := 'Break at step point ' , stepPoint printString.
			menuCommand := MessageSend
						receiver: presenter parentPresenter
						selector: command
						arguments: args.
			aMenu addCommand: menuCommand description: desc].
	^menuCommand!

appendToSourceMenu: aMenu presenter: methodSourcePresenter
	| stepPoint menuCommand messageSelector |
	self removeTrailingMenuItemsFrom: aMenu.
	stepPoint := self stepPointFromCursorIn: methodSourcePresenter.
	stepPoint isNil ifTrue: [^self removeJadeiteSeparatorFrom: aMenu].
	('*Edit*' match: aMenu text) ifFalse: [^self removeJadeiteSeparatorFrom: aMenu].	"popup or edit menu only"	
	menuCommand := self
				addBreakPointMenuAt: stepPoint
				to: aMenu
				presenter: methodSourcePresenter.
	messageSelector := (stepPoints at: stepPoint) value.
	messageSelector isEmpty ifTrue: [^self removeJadeiteSeparatorFrom: aMenu].
	aMenu addSeparator.
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
	testRunClassName := nil!

breakpointDisplayString
	| count writeStream disabledCount |
	breakPoints ifNil: [^self displayString].
	count := breakPoints size.
	disabledCount := (breakPoints select: [:bp | bp < 0]) size.
	writeStream := WriteStream on: String new.
	meta ifTrue: [writeStream nextPutAll: 'class>>'].
	writeStream
		nextPutAll: self displayString;
		space.
	writeStream
		nextPut: $(;
		nextPutAll: count printString.
	disabledCount > 0
		ifTrue: 
			[writeStream
				nextPut: $,; space;
				nextPutAll: 'disabled=';
				nextPutAll: disabledCount printString].
	writeStream nextPut: $).
	^writeStream contents!

breakPoints
	^breakPoints!

breakPoints: anObject
	breakPoints := anObject!

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

debuggerMethodSourceUpdate: presenter browser: browser
	"don't replicate the method - debugger is debugging the old method"

	^browser refreshBreakPointsIn: presenter!

definedClassName
	^definedClassName!

definedClassName: anObject
	definedClassName := anObject!

definedPackage
	^definedPackage!

displayClassName
	^className , (meta ifTrue: [' class'] ifFalse: [String new])!

displayName
	"protect against invalid entries"

	^[className , '>>' , selector] on: Error
		do: [:ex | className printString , '>>' , selector printString]!

displayOn: aStream
	aStream
		nextPutAll: (className ifNil: ['?']);
		nextPutAll: '>>';
		nextPutAll: (selector ifNil: ['?'])!

displayString
	^selector!

displayStringFor: displayThing
	isExtension
		ifTrue: 
			[displayThing forecolor: Color darkMagenta.
			inSelectedPackage ifFalse: [displayThing font beUnderlined ]]!

displayStringFor: displayThing browser: browser 
	browser displayStringFor: self in:  displayThing
	!

equalBeforeRename: aMethodService
	^renamedName = aMethodService className
		and: [selector = aMethodService selector and: [meta = aMethodService meta]]!

failedCompile
	^failedCompile!

firstReference
	^firstReference!

firstReference: integer
	firstReference := integer!

hash
	^(selector hash bitXor: className hash) bitXor: meta hash!

hasMethodHistory

	^hasMethodHistory!

hasSubs
	^hasSubs!

hasSubs: anObject
	hasSubs := anObject!

hasSupers
	^hasSupers!

hasSupers: anObject
	hasSupers := anObject!

homeMethodOop
	^homeMethodOop!

icon
	testResult ifNil: [^self class icon].
	testResult = 'passed' ifTrue: [^true icon].
	testResult = 'failure' ifTrue: [^Warning icon].
	testResult = 'error' ifTrue: [^false icon].
	^self class icon!

implementorsOf: aString

	^methodDefinitions!

indexOfFirstReferenceInstVar

	^37!

indexOfTestResultInstVar
	^31!

initialize
	super initialize.
	inSelectedPackage := true.
	failedCompile := false.
	meta := false.
	stepPoints := Array new.
	breakPoints := OrderedCollection new.
	hasSupers := false.
	hasSubs := false.
	hasMethodHistory := true. !

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

methodHistoryUpdated: historyBrowser
	
	^historyBrowser methodHistoryUpdated: self!

methodListUpdate: presenter browser: browser
	browser updateMethodList: self!

methodName
	"for the old sunit in class browser tab"
	^selector!

methodSourceUpdate: presenter browser: methodSourcePresenter
	| selection |
	selection := methodSourcePresenter methodListSelection.
	selection ifNil: [^self].
	selection = self
		ifTrue: 
			[selection replicateFrom: self.
			presenter view isModified
				ifFalse: 
					[presenter value: source.
					methodSourcePresenter refreshBreakPointsIn: presenter.
					methodSourcePresenter displayNoMods: presenter]]!

methodUpdate: presenter browser: browser
	presenter list do: 
			[:methodService |
			methodService replicateFrom: self	"#replicateFrom: will ensure we only replicate the proper methods"].
	browser updateMethodSource!

name
	selector isNil ifTrue:[^String new].
	^selector asString!

name: aString
	name := aString asString!

oop

	^oop!

oopType

	^OopType64 fromInteger: oop!

packageName
	^packageName!

packageName: anObject
	packageName := anObject!

positiveBreakpoints
	^breakPoints collect: [:bp | bp abs]!

postUpdate
	super postUpdate.
	renamedName := nil!

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

removeJadeiteSeparatorFrom: aMenu
	| last |
	last := aMenu items last.
	last id = #jadeiteDivider ifTrue: [aMenu removeItem: last]!

renamedName
	^renamedName!

renamedName: anObject
	renamedName := anObject!

replicateFrom: newService
	^(self isMethodService and: [newService isMethodService])
		ifTrue: 
			[(self = newService or: [newService equalBeforeRename: self])
				ifTrue: 
					[super replicateFrom: newService.
					renamedName := nil]]!

searchString
	^searchString!

searchString: anObject
	searchString := anObject!

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
	"first reference is only valid on the first return of a method service for a particular browser. 
	It may be better to (someday) move firstReference to the browser state"

	| isTestResultInstVar |
	index = self indexOfFirstReferenceInstVar ifTrue: [firstReference ifNotNil: [^false]].
	isTestResultInstVar := self indexOfTestResultInstVar = index.
	^isTestResultInstVar not or: [isTestResultInstVar and: [(newService instVarAt: index) notNil]]!

sortAspect

	^selector!

source
	^source!

source: anObject
	source := anObject!

stepPointFromCursorIn: methodSourcePresenter
	| charIndex |
	charIndex := methodSourcePresenter view caretPosition.
	^self stepPointFromCursorIn: methodSourcePresenter charIndex: charIndex!

stepPointFromCursorIn: methodSourcePresenter charIndex: charIndex
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

updateBreakPoints: presenter browser: browser
	presenter view invalidate!

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
!RowanMethodService categoriesFor: #<=!comparing!public! !
!RowanMethodService categoriesFor: #=!comparing!public! !
!RowanMethodService categoriesFor: #>=!comparing!public! !
!RowanMethodService categoriesFor: #accessedInstVars!accessing!private! !
!RowanMethodService categoriesFor: #accessedInstVars:!accessing!private! !
!RowanMethodService categoriesFor: #addBreakPointMenuAt:to:presenter:!method menu support!private! !
!RowanMethodService categoriesFor: #appendToSourceMenu:presenter:!method menu support!public! !
!RowanMethodService categoriesFor: #basicPrepareForReplication!public!replication! !
!RowanMethodService categoriesFor: #breakpointDisplayString!displaying!public! !
!RowanMethodService categoriesFor: #breakPoints!public! !
!RowanMethodService categoriesFor: #breakPoints:!accessing!public! !
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
!RowanMethodService categoriesFor: #debuggerMethodSourceUpdate:browser:!public!updating! !
!RowanMethodService categoriesFor: #definedClassName!accessing!private! !
!RowanMethodService categoriesFor: #definedClassName:!accessing!private! !
!RowanMethodService categoriesFor: #definedPackage!accessing!private! !
!RowanMethodService categoriesFor: #displayClassName!displaying!public! !
!RowanMethodService categoriesFor: #displayName!displaying!public! !
!RowanMethodService categoriesFor: #displayOn:!displaying!public! !
!RowanMethodService categoriesFor: #displayString!displaying!public! !
!RowanMethodService categoriesFor: #displayStringFor:!displaying!public! !
!RowanMethodService categoriesFor: #displayStringFor:browser:!displaying!public! !
!RowanMethodService categoriesFor: #equalBeforeRename:!comparing!public! !
!RowanMethodService categoriesFor: #failedCompile!accessing!public! !
!RowanMethodService categoriesFor: #firstReference!accessing!private! !
!RowanMethodService categoriesFor: #firstReference:!accessing!private! !
!RowanMethodService categoriesFor: #hash!comparing!public! !
!RowanMethodService categoriesFor: #hasMethodHistory!accessing!private! !
!RowanMethodService categoriesFor: #hasSubs!accessing!private! !
!RowanMethodService categoriesFor: #hasSubs:!accessing!private! !
!RowanMethodService categoriesFor: #hasSupers!accessing!private! !
!RowanMethodService categoriesFor: #hasSupers:!accessing!private! !
!RowanMethodService categoriesFor: #homeMethodOop!accessing!private! !
!RowanMethodService categoriesFor: #icon!public!sunit! !
!RowanMethodService categoriesFor: #implementorsOf:!method accessing!public! !
!RowanMethodService categoriesFor: #indexOfFirstReferenceInstVar!constants!public! !
!RowanMethodService categoriesFor: #indexOfTestResultInstVar!constants!public! !
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
!RowanMethodService categoriesFor: #methodHistoryUpdated:!public!updating! !
!RowanMethodService categoriesFor: #methodListUpdate:browser:!public!updating! !
!RowanMethodService categoriesFor: #methodName!accessing!private! !
!RowanMethodService categoriesFor: #methodSourceUpdate:browser:!public!updating! !
!RowanMethodService categoriesFor: #methodUpdate:browser:!public!updating! !
!RowanMethodService categoriesFor: #name!accessing!public! !
!RowanMethodService categoriesFor: #name:!accessing!public! !
!RowanMethodService categoriesFor: #oop!public! !
!RowanMethodService categoriesFor: #oopType!public! !
!RowanMethodService categoriesFor: #packageName!accessing!private! !
!RowanMethodService categoriesFor: #packageName:!accessing!private! !
!RowanMethodService categoriesFor: #positiveBreakpoints!accessing!public! !
!RowanMethodService categoriesFor: #postUpdate!public!updating! !
!RowanMethodService categoriesFor: #prepareForReplication!public!replication! !
!RowanMethodService categoriesFor: #printOn:!printing!public! !
!RowanMethodService categoriesFor: #projectName!accessing!private! !
!RowanMethodService categoriesFor: #projectName:!accessing!private! !
!RowanMethodService categoriesFor: #references!accessing!private! !
!RowanMethodService categoriesFor: #references:!accessing!private! !
!RowanMethodService categoriesFor: #remoteServiceName!must not strip!public! !
!RowanMethodService categoriesFor: #removeJadeiteSeparatorFrom:!method menu support!private! !
!RowanMethodService categoriesFor: #renamedName!accessing!private! !
!RowanMethodService categoriesFor: #renamedName:!accessing!private! !
!RowanMethodService categoriesFor: #replicateFrom:!public!replication! !
!RowanMethodService categoriesFor: #searchString!accessing!private! !
!RowanMethodService categoriesFor: #searchString:!accessing!private! !
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
!RowanMethodService categoriesFor: #stepPointFromCursorIn:charIndex:!presenter support!private! !
!RowanMethodService categoriesFor: #stepPoints!public! !
!RowanMethodService categoriesFor: #subSuperIcon!displaying!public! !
!RowanMethodService categoriesFor: #superDisplayString!accessing!private! !
!RowanMethodService categoriesFor: #superDisplayString:!accessing!private! !
!RowanMethodService categoriesFor: #testResult!accessing!public! !
!RowanMethodService categoriesFor: #testResult:!accessing!public! !
!RowanMethodService categoriesFor: #testResultUpdate:browser:!public!updating! !
!RowanMethodService categoriesFor: #toolTip!accessing!displaying!private! !
!RowanMethodService categoriesFor: #unimplementedSelectors!public! !
!RowanMethodService categoriesFor: #updateBreakPoints:browser:!public!updating! !
!RowanMethodService categoriesFor: #updateSelectorFromCompiledMethod:!private! !
!RowanMethodService categoriesFor: #user!accessing!private! !
!RowanMethodService categoriesFor: #user:!accessing!private! !

!RowanMethodService class methodsFor!

defaultIconName
	"Answer a filename to use for an icon of this class."

	^File composeStem: 'Message' extension: 'ico'.!

fakeMethodFor: className selector: selector source: source
	| inst |
	inst := self new.
	inst
		className: className;
		selector: selector;
		source: source.
	^inst!

icon
	"Answers an Icon that can be used to represent this class"

	^##(self) defaultIcon ! !
!RowanMethodService class categoriesFor: #defaultIconName!private! !
!RowanMethodService class categoriesFor: #fakeMethodFor:selector:source:!instance creation!public! !
!RowanMethodService class categoriesFor: #icon!private! !

