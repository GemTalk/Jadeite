"Filed out from Dolphin Smalltalk 7"!

RowanService subclass: #RowanComponentService
	instanceVariableNames: 'name componentServices packageServices projectService basename'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanComponentService guid: (GUID fromString: '{842be73b-a371-499f-a6d4-dcd4a81c01e5}')!
RowanComponentService comment: ''!
!RowanComponentService categoriesForClass!Unclassified! !
!RowanComponentService methodsFor!

= componentService
	^componentService isService
		and: [componentService isComponentService and: [name = componentService name]]!

basename
	^basename!

basename: anObject
	basename := anObject!

componentPackagesUpdate: presenter browser: browser
	wasUpdated ifFalse:[^self].
	packageServices isEmpty ifTrue:[^self]. 
	self
		packagesUpdate: presenter
		browser: browser
		parentPresenter: browser componentListPresenter!

displayString
	^basename!

hash
	^self name hash!

isComponentService
	^true!

name
	^name!

packageServices
	^packageServices!

printOn: stream
	stream
		nextPutAll: self class name;
		nextPutAll: '->';
		nextPutAll: basename! !
!RowanComponentService categoriesFor: #=!comparing!public! !
!RowanComponentService categoriesFor: #basename!accessing!private! !
!RowanComponentService categoriesFor: #basename:!accessing!private! !
!RowanComponentService categoriesFor: #componentPackagesUpdate:browser:!public!updating! !
!RowanComponentService categoriesFor: #displayString!displaying!public! !
!RowanComponentService categoriesFor: #hash!comparing!public! !
!RowanComponentService categoriesFor: #isComponentService!public!testing! !
!RowanComponentService categoriesFor: #name!accessing!public! !
!RowanComponentService categoriesFor: #packageServices!accessing!private! !
!RowanComponentService categoriesFor: #printOn:!displaying!public! !

