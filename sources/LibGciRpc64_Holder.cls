"Filed out from Dolphin Smalltalk 7"!

Object subclass: #LibGciRpc64_Holder
	instanceVariableNames: 'parentLibrary fileNameSearch displayName'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
LibGciRpc64_Holder guid: (GUID fromString: '{f0ed36c5-2e5f-453b-8e5e-90532556ecbc}')!
LibGciRpc64_Holder comment: 'Placeholder for a subclass of GciLibrary. Used for logging into server versions for which no GciLibrary subclass is present. '!
!LibGciRpc64_Holder categoriesForClass!Kernel-Objects! !
!LibGciRpc64_Holder methodsFor!

displayName
	^displayName!

displayName: anObject
	displayName := anObject!

fileName
	^fileNameSearch!

fileNameSearch
	^fileNameSearch!

fileNameSearch: anObject
	fileNameSearch := anObject!

library
	^parentLibrary!

open: filePath
	^parentLibrary open: filePath!

parentLibrary
	^parentLibrary!

parentLibrary: anObject
	parentLibrary := anObject! !
!LibGciRpc64_Holder categoriesFor: #displayName!accessing!private! !
!LibGciRpc64_Holder categoriesFor: #displayName:!accessing!private! !
!LibGciRpc64_Holder categoriesFor: #fileName!accessing!private! !
!LibGciRpc64_Holder categoriesFor: #fileNameSearch!accessing!private! !
!LibGciRpc64_Holder categoriesFor: #fileNameSearch:!accessing!private! !
!LibGciRpc64_Holder categoriesFor: #library!accessing!public! !
!LibGciRpc64_Holder categoriesFor: #open:!accessing!public! !
!LibGciRpc64_Holder categoriesFor: #parentLibrary!accessing!private! !
!LibGciRpc64_Holder categoriesFor: #parentLibrary:!accessing!private! !

!LibGciRpc64_Holder class methodsFor!

displayName: displayName fileNameSearch: fileNameSearch parentLibrary: parentLibraryClass
	| inst |
	inst := self new.
	inst
		displayName: displayName;
		fileNameSearch: fileNameSearch;
		parentLibrary: parentLibraryClass.
	^inst! !
!LibGciRpc64_Holder class categoriesFor: #displayName:fileNameSearch:parentLibrary:!public! !

