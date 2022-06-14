"Filed out from Dolphin Smallalk"!

Object subclass: #LibGciRpc64_Holder
	instanceVariableNames: 'parentLibrary fileNameSearch displayName'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
LibGciRpc64_Holder guid: (GUID fromString: '{f0ed36c5-2e5f-453b-8e5e-90532556ecbc}')!
LibGciRpc64_Holder comment: 'Placeholder for a subclass of GciLibrary. Used for logging into server versions for which no GciLibrary subclass is present. '!
!LibGciRpc64_Holder categoriesForClass!Kernel-Objects! !
!LibGciRpc64_Holder methodsFor!

= aHolder
	aHolder class = LibGciRpc64_Holder ifFalse:[^false]. 
	^fileNameSearch = aHolder fileNameSearch!

displayName
	^displayName!

displayName: anObject
	displayName := anObject!

fileNameSearch
	^fileNameSearch!

fileNameSearch: anObject
	fileNameSearch := anObject!

hash
	^fileNameSearch hash!

parentLibrary
	^parentLibrary!

parentLibrary: anObject
	parentLibrary := anObject!

withDisplayName: aDisplayName
	^parentLibrary! !
!LibGciRpc64_Holder categoriesForMethods!
=!comparison!public! !
displayName!accessing!private! !
displayName:!accessing!private! !
fileNameSearch!accessing!private! !
fileNameSearch:!accessing!private! !
hash!comparison!public! !
parentLibrary!accessing!private! !
parentLibrary:!accessing!private! !
withDisplayName:!accessing!public! !
!

!LibGciRpc64_Holder class methodsFor!

displayName: displayName fileNameSearch: fileNameSearch parentLibrary: parentLibraryClass
	| inst |
	inst := self new.
	inst
		displayName: displayName;
		fileNameSearch: fileNameSearch;
		parentLibrary: parentLibraryClass.
	^inst! !
!LibGciRpc64_Holder class categoriesForMethods!
displayName:fileNameSearch:parentLibrary:!public! !
!

