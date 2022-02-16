"Filed out from Dolphin Smallalk"!

RowanCommandResult subclass: #RowanClassInfoUpdate
	instanceVariableNames: 'oop template category comment'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanClassInfoUpdate guid: (GUID fromString: '{e7acaa37-9865-4b18-a3d9-680bccb6db7c}')!
RowanClassInfoUpdate comment: ''!
!RowanClassInfoUpdate categoriesForClass!Unclassified! !
!RowanClassInfoUpdate methodsFor!

category
	^category!

category: anObject
	category := anObject!

classCommentUpdate: presenter
	presenter value: comment!

classDefinitionUpdate: presenter
	presenter isOpen ifFalse: [^self].
	presenter view isModified
		ifTrue: 
			[template = presenter value ifTrue: [^self].
			(MessageBox confirm: 'Copy changes to clipboard?' caption: 'Class has unsaved changes!!')
				ifTrue: [presenter value copyToClipboard]].
	presenter value: template.
	presenter view
		backcolor: Color white;
		isModified: false;
		yourself!

comment
	^comment!

comment: anObject
	comment := anObject!

oop
	^oop!

oop: anObject
	oop := anObject!

template
	^template!

template: anObject
	template := anObject!

update: aPresenter
	aPresenter updateFromCommand: self! !
!RowanClassInfoUpdate categoriesForMethods!
category!accessing!public! !
category:!accessing!public! !
classCommentUpdate:!public!updating! !
classDefinitionUpdate:!public!updating! !
comment!accessing!public! !
comment:!accessing!public! !
oop!accessing!public! !
oop:!accessing!public! !
template!accessing!public! !
template:!accessing!public! !
update:!public! !
!

