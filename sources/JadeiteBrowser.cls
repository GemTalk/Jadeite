"Filed out from Dolphin Smalltalk 7"!

JadeiteProjectsSystemBrowser subclass: #JadeiteBrowser
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteBrowser guid: (GUID fromString: '{4ed2f816-dbc6-4ce7-b7ef-c483e56b9397}')!
JadeiteBrowser comment: ''!
!JadeiteBrowser categoriesForClass!Unclassified! !
!JadeiteBrowser methodsFor!

maximizeCode
	| tabView topView |
	self currentCard class == self systemBrowserPresenter ifFalse: [^self].
	tabView := (self currentCard view viewNamed: 'textAreaTabs') parentView.
	topView := (self currentCard view viewNamed: 'projectList') parentView parentView.
	self currentCard previousTabViewArrangement
		ifNil: 
			[self currentCard previousTabViewArrangement: tabView arrangement.
			self currentCard previousTopViewArrangement: topView arrangement.
			tabView arrangement: 24.
			topView arrangement: 0.1	"small but non zero. See class comment in ProportionalLayout."]
		ifNotNil: 
			[:value |
			tabView arrangement: self currentCard previousTabViewArrangement.
			topView arrangement: self currentCard previousTopViewArrangement.
			self currentCard previousTabViewArrangement: nil.
			self currentCard previousTopViewArrangement: nil].
	self currentCard view invalidate!

systemBrowserPresenter
	^JadeiteBrowserPresenter! !
!JadeiteBrowser categoriesFor: #maximizeCode!public! !
!JadeiteBrowser categoriesFor: #systemBrowserPresenter!public! !

!JadeiteBrowser class methodsFor!

onSession: session
	^self showOnSession: session!

openOn: session projectName: projectName
	| projectBrowser |
	projectBrowser := self onSession: session.
	projectBrowser currentCard selectProjectNamed: projectName.
	^projectBrowser! !
!JadeiteBrowser class categoriesFor: #onSession:!instance creation!public! !
!JadeiteBrowser class categoriesFor: #openOn:projectName:!instance creation!public! !

