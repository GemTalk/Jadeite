"Filed out from Dolphin Smallalk"!

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

	^34!

indexOfSourceInstVar
	^7!

indexOfStepPointsInstVar
	^21!

indexOfTestResultInstVar
	^28!

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
	self indexOfSourceInstVar = index ifTrue: [^newService source isNil not].	"fastRefresh nils out stepPoints and sources for performance"
	self indexOfStepPointsInstVar = index ifTrue: [^newService stepPoints isNil not].
	^isTestResultInstVar not or: 
			[(isTestResultInstVar or: [self indexOfSourceInstVar = index])
				and: [(newService instVarAt: index) notNil]]!

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
!RowanMethodService categoriesForMethods!
<=!comparing!public! !
=!comparing!public! !
>=!comparing!public! !
accessedInstVars!accessing!private! !
accessedInstVars:!accessing!private! !
addBreakPointMenuAt:to:presenter:!method menu support!private! !
appendToSourceMenu:presenter:!method menu support!public! !
basicPrepareForReplication!public!replication! !
breakpointDisplayString!displaying!public! !
breakPoints!public! !
breakPoints:!accessing!public! !
category!accessing!private! !
category:!accessing!private! !
classMethodDisplayString!displaying!public! !
className!accessing!private! !
className:!accessing!private! !
classService!public! !
comparisonSource!accessing!private! !
comparisonSource:!accessing!private! !
compilationWarnings!accessing!private! !
copyBasicsFrom:!public!updating! !
debuggerMethodSourceUpdate:browser:!public!updating! !
definedClassName!accessing!private! !
definedClassName:!accessing!private! !
definedPackage!accessing!private! !
displayClassName!displaying!public! !
displayName!displaying!public! !
displayOn:!displaying!public! !
displayString!displaying!public! !
displayStringFor:!displaying!public! !
displayStringFor:browser:!displaying!public! !
equalBeforeRename:!comparing!public! !
failedCompile!accessing!public! !
firstReference!accessing!private! !
firstReference:!accessing!private! !
hash!comparing!public! !
hasMethodHistory!accessing!private! !
hasSubs!accessing!private! !
hasSubs:!accessing!private! !
hasSupers!accessing!private! !
hasSupers:!accessing!private! !
homeMethodOop!accessing!private! !
icon!public!sunit! !
implementorsOf:!method accessing!public! !
indexOfFirstReferenceInstVar!constants!public!replication! !
indexOfSourceInstVar!constants!public!replication! !
indexOfStepPointsInstVar!constants!public!replication! !
indexOfTestResultInstVar!constants!public!replication! !
initialize!initialization!public! !
inSelectedPackage!public!testing! !
inSelectedPackage:!accessing!public! !
isExtension!accessing!public! !
isExtension:!accessing!public! !
isMethodService!public!testing! !
isReadOnly!public!testing! !
isTestMethod!public!testing! !
meta!accessing!private! !
meta:!accessing!private! !
methodDefinitions!accessing!private! !
methodDefinitions:!accessing!private! !
methodHistoryUpdated:!public!updating! !
methodListUpdate:browser:!public!updating! !
methodName!accessing!private! !
methodSourceUpdate:browser:!public!updating! !
methodUpdate:browser:!public!updating! !
name!accessing!public! !
name:!accessing!public! !
oop!public! !
oopType!public! !
packageName!accessing!private! !
packageName:!accessing!private! !
positiveBreakpoints!accessing!public! !
postUpdate!public!updating! !
prepareForReplication!public!replication! !
printOn:!printing!public! !
projectName!accessing!private! !
projectName:!accessing!private! !
references!accessing!private! !
references:!accessing!private! !
remoteServiceName!must not strip!public! !
removeJadeiteSeparatorFrom:!method menu support!private! !
renamedName!accessing!private! !
renamedName:!accessing!private! !
replicateFrom:!public!replication! !
searchString!accessing!private! !
searchString:!accessing!private! !
selectedPackageServices!accessing!private! !
selectedPackageServices:browser:!accessing!private! !
selector!accessing!private! !
selector:!accessing!private! !
selectorsDisplayString!displaying!public! !
setError!public!sunit! !
setFailure!public!sunit! !
setPassed!public!sunit! !
shouldReplicateInstVarAtIndex:newService:!public!replication!testing! !
sortAspect!accessing!public! !
source!accessing!private! !
source:!accessing!private! !
stepPointFromCursorIn:!presenter support!private! !
stepPointFromCursorIn:charIndex:!presenter support!private! !
stepPoints!public! !
subSuperIcon!displaying!public! !
superDisplayString!accessing!private! !
superDisplayString:!accessing!private! !
testResult!accessing!public! !
testResult:!accessing!public! !
testResultUpdate:browser:!public!updating! !
toolTip!accessing!displaying!private! !
unimplementedSelectors!public! !
updateBreakPoints:browser:!public!updating! !
updateSelectorFromCompiledMethod:!private! !
user!accessing!private! !
user:!accessing!private! !
!

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
!RowanMethodService class categoriesForMethods!
defaultIconName!private! !
fakeMethodFor:selector:source:!instance creation!public! !
icon!private! !
!

