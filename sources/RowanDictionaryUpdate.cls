"Filed out from Dolphin Smallalk"!

RowanCommandResult subclass: #RowanDictionaryUpdate
	instanceVariableNames: 'dictionaries selections'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanDictionaryUpdate guid: (GUID fromString: '{83fbbd49-2c42-4bef-8463-1e3264cbcc43}')!
RowanDictionaryUpdate comment: ''!
!RowanDictionaryUpdate categoriesForClass!Unclassified! !
!RowanDictionaryUpdate methodsFor!

dictionaryUpdate: aPresenter
	aPresenter list: (dictionaries collect: [:dictName | (dictName last: dictName size - 1) -> false])!

updateDictionarySelectionsFor: presenter
	| sels |
	sels := presenter list select:[:sel | selections includes: sel key].
	presenter selections: sels! !
!RowanDictionaryUpdate categoriesForMethods!
dictionaryUpdate:!public!updating! !
updateDictionarySelectionsFor:!public!updating! !
!

