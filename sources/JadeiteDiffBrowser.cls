"Filed out from Dolphin Smalltalk 7"!

DiffBrowser subclass: #JadeiteDiffBrowser
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteDiffBrowser guid: (GUID fromString: '{e7e1c614-97b8-4d76-bc0c-335946e3a5b6}')!
JadeiteDiffBrowser comment: ''!
!JadeiteDiffBrowser categoriesForClass!IDB Goodies! !
!JadeiteDiffBrowser methodsFor!

createComponents
	searchPresenter := self
				add: JadeiteSmalltalkSearchPresenter new
				name: 'search'
				helpId: 10510.

	"Font size adjust by slider (if supported by view)"
	fontSizePresenter := self add: NumberPresenter new name: 'fontSize'.
	diffsPresenter := self add: DifferencesPresenter new name: 'diffs'!

onViewOpened
	self basicOnViewOpened.
	caption := self view caption.
	self
		updateIcon;
		invalidateUserInterface;
		updateCaption.
	self class trigger: #viewOpened: with: self.
	fontSizePresenter model: (ValueAspectAdaptor subject: self aspect: #fontSize)!

systemModel
	^nil! !
!JadeiteDiffBrowser categoriesFor: #createComponents!initializing!public! !
!JadeiteDiffBrowser categoriesFor: #onViewOpened!event handlers!public! !
!JadeiteDiffBrowser categoriesFor: #systemModel!accessing!private! !

