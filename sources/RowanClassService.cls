"Filed out from Dolphin Smalltalk 7"!

RowanService subclass: #RowanClassService
	instanceVariableNames: 'comment instVarNames classVarNames classInstVarNames superclassName subclassType poolDictionaryNames classType packageService meta isExtension version versions template oop allFilters filters filterType methods'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanClassService guid: (GUID fromString: '{ab96bbd9-d725-4add-b635-94cec9f12a19}')!
RowanClassService comment: ''!
!RowanClassService categoriesForClass!Kernel-Objects! !
!RowanClassService methodsFor!

allFilters
	^allFilters!

allFilters: anObject
	allFilters := anObject!

classCreationTemplate

	^transport send: #classCreationTemplate to: self remoteService!

classMethodsUpdate: presenter
	| visibleMethods |
	visibleMethods := OrderedCollection new.
	filters isEmpty
		ifTrue: [visibleMethods := methods]
		ifFalse: 
			[visibleMethods := methods select: [:methodService | filters includes: methodService category]].
	presenter list: visibleMethods!

classUpdate: presenter
	"don't just replace the list as we want to preserve selections"

	presenter list isEmpty ifTrue: [^presenter list: allFilters].
	presenter list addAll: (allFilters difference: presenter list).
	presenter list removeAll: (presenter list difference: allFilters)!

comment
	^comment!

comment: anObject
	comment := anObject!

createSampleClass
	transport send: #createSampleClass to: remoteService.  !

displayString
	| displayString |
	displayString := self name.
	versions ~= 1
		ifTrue: [displayString := displayString , ' (' , version printString , '/' , versions printString , ')'].
	^displayString!

displayStringFor: displayThing
	isExtension ifTrue: [displayThing forecolor: Color darkMagenta ].
	^self displayString!

filter
	^filter!

filter: anObject
	filter := anObject!

filters
	^filters!

filters: anObject
	filters := anObject!

initialize
	
	super initialize. 
	filters := Array new. !

isClassService

	^true!

meta
	^meta!

meta: anObject
	meta := anObject!

remoteServiceName
	^'Rowan classServiceClass'!

removeSelector: selector

	transport send: #removeSelector: to: remoteService withAll: (Array with: selector)!

replicateFrom: newService
	self isClassService ifFalse: [^self].
	newService name = name ifFalse: [^self].
	1 to: self class instSize
		do: 
			[:index | 
			(self class allInstVarNames at: index) = 'filters'
				ifFalse: [self instVarAt: index put: (newService instVarAt: index)]]!

sampleClassName
	^transport send: #sampleClassName to: remoteService.  !

subclassCreationTemplate
	^transport send: #subclassCreationTemplate to: self remoteService!

template
	^template!

template: anObject
	template := anObject!

toolTip
	^self displayString
! !
!RowanClassService categoriesFor: #allFilters!accessing!private! !
!RowanClassService categoriesFor: #allFilters:!accessing!private! !
!RowanClassService categoriesFor: #classCreationTemplate!public! !
!RowanClassService categoriesFor: #classMethodsUpdate:!public!updating! !
!RowanClassService categoriesFor: #classUpdate:!public!updating! !
!RowanClassService categoriesFor: #comment!accessing!public! !
!RowanClassService categoriesFor: #comment:!accessing!public! !
!RowanClassService categoriesFor: #createSampleClass!public! !
!RowanClassService categoriesFor: #displayString!printing!public! !
!RowanClassService categoriesFor: #displayStringFor:!printing!public! !
!RowanClassService categoriesFor: #filter!accessing!private! !
!RowanClassService categoriesFor: #filter:!accessing!private! !
!RowanClassService categoriesFor: #filters!accessing!public! !
!RowanClassService categoriesFor: #filters:!accessing!public! !
!RowanClassService categoriesFor: #initialize!initialization!public! !
!RowanClassService categoriesFor: #isClassService!public!testing! !
!RowanClassService categoriesFor: #meta!accessing!private! !
!RowanClassService categoriesFor: #meta:!accessing!private! !
!RowanClassService categoriesFor: #remoteServiceName!must not strip!public! !
!RowanClassService categoriesFor: #removeSelector:!public!rowan! !
!RowanClassService categoriesFor: #replicateFrom:!public!updating! !
!RowanClassService categoriesFor: #sampleClassName!public! !
!RowanClassService categoriesFor: #subclassCreationTemplate!public! !
!RowanClassService categoriesFor: #template!accessing!private! !
!RowanClassService categoriesFor: #template:!accessing!private! !
!RowanClassService categoriesFor: #toolTip!printing!public! !
