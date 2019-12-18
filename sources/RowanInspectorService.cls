"Filed out from Dolphin Smalltalk 7"!

RowanService subclass: #RowanInspectorService
	instanceVariableNames: 'oop objects myself className indexedSize visibleIndices nextIndices maxIndexedVars'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanInspectorService guid: (GUID fromString: '{b80c7b87-3ce0-4b36-a288-1e52506958dd}')!
RowanInspectorService comment: ''!
!RowanInspectorService categoriesForClass!Unclassified! !
!RowanInspectorService methodsFor!

= inspectorService
	^inspectorService isInspectorService ifTrue: [oop = inspectorService oop] ifFalse: [false]!

className
	^className!

className: anObject
	className := anObject!

defaultIndexedSize
	^1000!

executeThenInspect: string context: anOop session: session windowHandle: handle
	self
		command: #executeThenInspect:context:inWindow:;
		commandArgs: (Array
					with: string
					with: anOop
					with: handle).
	BrowserUpdate current issueCommands: (Array with: self) session: session!

hash
	^oop hash!

indexedSize
	^indexedSize!

indexedSize: anObject
	indexedSize := anObject!

initialize
	super initialize. 
	objects := Array new. 
	maxIndexedVars := self defaultIndexedSize!

inspect: anOop session: session
	oop := anOop value.
	self
		command: #inspect:;
		commandArgs: (Array with: oop).
	BrowserUpdate current issueCommands: (Array with: self) session: session!

isInspectorService

	^true!

maxIndexedVars
	^maxIndexedVars!

maxIndexedVars: anObject
	maxIndexedVars := anObject!

myself
	^myself!

myself: anObject
	myself := anObject!

nextIndexedVarsFrom: indexStart to: indexStop session: session
	self
		command: #nextIndexedVarsFrom:to:;
		commandArgs: (Array with: indexStart with: indexStop).
	BrowserUpdate current issueCommands: (Array with: self) session: session.
	^nextIndices!

nextIndices
	^nextIndices!

nextIndices: anObject
	nextIndices := anObject!

objects
	^objects!

objects: anObject
	objects := anObject!

oop
	^oop!

oop: anObject
	oop := anObject!

visibleIndices
	^visibleIndices!

visibleIndices: anObject
	visibleIndices := anObject! !
!RowanInspectorService categoriesFor: #=!comparison!public! !
!RowanInspectorService categoriesFor: #className!accessing!private! !
!RowanInspectorService categoriesFor: #className:!accessing!private! !
!RowanInspectorService categoriesFor: #defaultIndexedSize!constants!public! !
!RowanInspectorService categoriesFor: #executeThenInspect:context:session:windowHandle:!inspecting!public! !
!RowanInspectorService categoriesFor: #hash!comparison!private! !
!RowanInspectorService categoriesFor: #indexedSize!accessing!private! !
!RowanInspectorService categoriesFor: #indexedSize:!accessing!private! !
!RowanInspectorService categoriesFor: #initialize!initialization!public! !
!RowanInspectorService categoriesFor: #inspect:session:!inspecting!public! !
!RowanInspectorService categoriesFor: #isInspectorService!public!testing! !
!RowanInspectorService categoriesFor: #maxIndexedVars!accessing!private! !
!RowanInspectorService categoriesFor: #maxIndexedVars:!accessing!private! !
!RowanInspectorService categoriesFor: #myself!accessing!private! !
!RowanInspectorService categoriesFor: #myself:!accessing!private! !
!RowanInspectorService categoriesFor: #nextIndexedVarsFrom:to:session:!inspecting!public! !
!RowanInspectorService categoriesFor: #nextIndices!accessing!private! !
!RowanInspectorService categoriesFor: #nextIndices:!accessing!private! !
!RowanInspectorService categoriesFor: #objects!accessing!private! !
!RowanInspectorService categoriesFor: #objects:!accessing!private! !
!RowanInspectorService categoriesFor: #oop!accessing!private! !
!RowanInspectorService categoriesFor: #oop:!accessing!private! !
!RowanInspectorService categoriesFor: #visibleIndices!accessing!private! !
!RowanInspectorService categoriesFor: #visibleIndices:!accessing!private! !

