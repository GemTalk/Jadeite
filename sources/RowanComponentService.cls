"Filed out from Dolphin Smallalk"!

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

name: aString
	name := aString!

packageServices
	^packageServices!

printOn: stream
	stream
		nextPutAll: self class name;
		nextPutAll: '->';
		nextPutAll: basename! !
!RowanComponentService categoriesForMethods!
=!comparing!public! !
basename!accessing!private! !
basename:!accessing!private! !
componentPackagesUpdate:browser:!public!updating! !
displayString!displaying!public! !
hash!comparing!public! !
isComponentService!public!testing! !
name!accessing!public! !
name:!accessing!public! !
packageServices!accessing!private! !
printOn:!displaying!public! !
!

