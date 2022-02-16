"Filed out from Dolphin Smallalk"!

JadePresenterA subclass: #JadeiteServerFileSelectorPresenter
	instanceVariableNames: 'directoryContentsList pathText'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteServerFileSelectorPresenter guid: (GUID fromString: '{0fbb212f-5644-4753-aabf-3513566853a4}')!
JadeiteServerFileSelectorPresenter comment: ''!
!JadeiteServerFileSelectorPresenter categoriesForClass!Unclassified! !
!JadeiteServerFileSelectorPresenter methodsFor!

createComponents
	super createComponents.
	directoryContentsList := self add: ListPresenter new name: 'directoryContentsList'.
	pathText := self add: TextPresenter new name: 'pathText'!

createSchematicWiring
	super createSchematicWiring.
	directoryContentsList
		when: #selectionChanged
		send: #entitySelected
		to: self.
	directoryContentsList
		when: #actionPerformed
		send: #dive
		to: self.!

dive
	model path: pathText value. 
	self showDirectoryContents. !

entitySelected
	directoryContentsList selectionOrNil ifNil:[^self]. 
	pathText value: model path , '/' , directoryContentsList selection!

pop
	model path: pathText value. 
	directoryContentsList list: model pop.
	pathText value: model path!

popBkp
	| rs string adjustedPathText |
	adjustedPathText := pathText value last = $/
				ifTrue: [pathText value copyFrom: 1 to: pathText value size - 1]
				ifFalse: [pathText value].
	rs := ReadStream on: adjustedPathText.
	string := String new.
	[rs atEnd] whileFalse: 
			[| next |
			next := rs upTo: $/.
			rs atEnd ifFalse: [string := string , next , '/']].
	pathText value: string. 
	model path: string.
	self showDirectoryContents!

postOpen
	pathText value: model path. 
	self showDirectoryContents. 
	!

select
	| selection |
	selection := pathText value. 
	self parentPresenter view close.
	^selection
	!

showDirectoryContents
	| directoryContents |
	directoryContents := model directoryContents.
	directoryContentsList list: directoryContents! !
!JadeiteServerFileSelectorPresenter categoriesForMethods!
createComponents!initialization!public! !
createSchematicWiring!initialization!public! !
dive!actions!public! !
entitySelected!event handlers!public! !
pop!actions!public! !
popBkp!actions!public! !
postOpen!initialization!public! !
select!actions!public! !
showDirectoryContents!actions!public! !
!

