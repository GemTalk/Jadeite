"Filed out from Dolphin Smallalk"!

RowanCommandResult subclass: #RowanMethodUpdate
	instanceVariableNames: 'classOop className methodOop selector category editable source firstSendOffsets stepPoints breakPoints originalMethodSource compilationWarnings isTestClass isOverride gsMethod selected'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanMethodUpdate guid: (GUID fromString: '{c77aaf73-dce8-4890-a7b9-dcbe34ac585c}')!
RowanMethodUpdate comment: ''!
!RowanMethodUpdate categoriesForClass!Unclassified! !
!RowanMethodUpdate methodsFor!

breakPoints
	^breakPoints!

breakPoints: anObject
	breakPoints := anObject!

category
	^category!

category: anObject
	category := anObject!

className
	^className!

className: anObject
	className := anObject!

classOop
	^classOop!

classOop: anObject
	classOop := anObject!

compilationWarnings
	^compilationWarnings!

compilationWarnings: anObject
	compilationWarnings := anObject!

editable
	^editable!

editable: anObject
	editable := anObject!

firstSendOffsets
	^firstSendOffsets!

firstSendOffsets: anObject
	firstSendOffsets := anObject!

initialize
	super initialize. 
	selected := false!

isOverride
	^isOverride!

isOverride: anObject
	isOverride := anObject!

isTestClass
	^isTestClass!

isTestClass: anObject
	isTestClass := anObject!

methodOop
	^methodOop!

methodOop: anObject
	methodOop := anObject!

originalMethodSource
	^originalMethodSource!

originalMethodSource: anObject
	originalMethodSource := anObject!

selected
	^selected!

selected: anObject
	selected := anObject!

selector
	^gsMethod selector!

selector: anObject
	selector := anObject!

source
	^source!

source: anObject
	source := anObject!

stepPoints
	^stepPoints!

stepPoints: anObject
	stepPoints := anObject!

updateSelectedSelectorFor: presenter
	self rowanFixMe.	"step points, break points, override, read only, other tabs? "
	presenter view isModified
		ifTrue: 
			[gsMethod source = presenter value ifTrue: [^self].
			(MessageBox confirm: 'Copy changes to clipboard?' caption: 'Method has unsaved changes!!')
				ifTrue: [presenter value copyToClipboard]].
	presenter value: gsMethod source.
	stepPoints := gsMethod stepPoints.
	breakPoints := gsMethod breakPoints.
	presenter view
		backcolor: JadeiteTextStyles default colorForNoEdits;
		isModified: false;
		isReadOnly: false;
		yourself!

updateSelectorFor: presenter

	selected ifTrue:[self updateSelectedSelectorFor: presenter].! !
!RowanMethodUpdate categoriesForMethods!
breakPoints!accessing!private! !
breakPoints:!accessing!private! !
category!accessing!private! !
category:!accessing!private! !
className!accessing!private! !
className:!accessing!private! !
classOop!accessing!private! !
classOop:!accessing!private! !
compilationWarnings!accessing!private! !
compilationWarnings:!accessing!private! !
editable!accessing!private! !
editable:!accessing!private! !
firstSendOffsets!accessing!private! !
firstSendOffsets:!accessing!private! !
initialize!initialization!public! !
isOverride!accessing!private! !
isOverride:!accessing!private! !
isTestClass!accessing!private! !
isTestClass:!accessing!private! !
methodOop!accessing!private! !
methodOop:!accessing!private! !
originalMethodSource!accessing!private! !
originalMethodSource:!accessing!private! !
selected!accessing!private! !
selected:!accessing!private! !
selector!accessing!private! !
selector:!accessing!private! !
source!accessing!private! !
source:!accessing!private! !
stepPoints!accessing!private! !
stepPoints:!accessing!private! !
updateSelectedSelectorFor:!public!updating! !
updateSelectorFor:!public!updating! !
!

