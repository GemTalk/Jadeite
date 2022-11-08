"Filed out from Dolphin Smallalk"!

JadeErrorShell subclass: #TestJadeErrorShell
	instanceVariableNames: ''
	classVariableNames: 'LastErrorShell'
	poolDictionaries: ''
	classInstanceVariableNames: ''!
TestJadeErrorShell guid: (GUID fromString: '{6ec124cd-e1bb-4c14-a03f-e85653700406}')!
TestJadeErrorShell comment: ''!
!TestJadeErrorShell categoriesForClass!Unclassified! !
!TestJadeErrorShell methodsFor!

showModal
	"While testing, don't open modal"

	self class lastErrorShell: self.
	self show.
	self view close.
	^#debug! !
!TestJadeErrorShell categoriesForMethods!
showModal!public! !
!

!TestJadeErrorShell class methodsFor!

disableJadeiteErrorShell
	Smalltalk removeKey: #JadeiteTestsActive ifAbsent: [].
	LastErrorShell := nil!

enableJadeiteErrorShell
	Smalltalk at: #JadeiteTestsActive put: true.!

lastErrorShell
	^LastErrorShell!

lastErrorShell: shell
	LastErrorShell := shell! !
!TestJadeErrorShell class categoriesForMethods!
disableJadeiteErrorShell!public! !
enableJadeiteErrorShell!public! !
lastErrorShell!public! !
lastErrorShell:!public! !
!

