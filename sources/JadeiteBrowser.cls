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

position: aPoint
	self cardsPresenter view cards size > 1
		ifTrue: [^self	"don't move a project browser automatically if it has multiple tabs"].
	super position: aPoint!

systemBrowserPresenter
	^JadeiteBrowserPresenter! !
!JadeiteBrowser categoriesFor: #maximizeCode!public! !
!JadeiteBrowser categoriesFor: #position:!public! !
!JadeiteBrowser categoriesFor: #systemBrowserPresenter!public! !

!JadeiteBrowser class methodsFor!

onSession: session
	^self showOnSession: session!

openOn: session class: classService
	| browser |
	browser := self onSession: session.
	BrowserUpdate current updateService: classService session: session.
	browser currentCard selectProjectNamed: classService projectName.
	classService projectName = RowanProjectService noneProject name
		ifTrue: [browser currentCard selectDictionaryNamed: classService dictionaryName]
		ifFalse: [browser currentCard selectPackageNamed: classService packageName].
	browser currentCard selectClassNamed: classService name.
	browser currentCard classListPresenter setFocus.
	^browser!

openOn: session dictionary: dictionaryService
	| browser |
	browser := self onSession: session.
	browser currentCard selectProjectNamed: RowanProjectService notRowanizedPackageName.
	browser currentCard selectDictionaryNamed: dictionaryService name.
	browser currentCard dictionaryPresenter setFocus.
	^browser!

openOn: session package: packageService
	| browser |
	browser := self onSession: session.
	BrowserUpdate current updateService: packageService session: session.
	browser currentCard selectProjectNamed: packageService projectName.
	browser currentCard selectPackageNamed: packageService name.
	browser currentCard packageListPresenter setFocus.
	^browser!

openOn: session project: projectService
	| browser |
	browser := self onSession: session.
	browser currentCard selectProjectNamed: projectService name.
	browser currentCard projectListPresenter setFocus.
	^browser! !
!JadeiteBrowser class categoriesFor: #onSession:!instance creation!public! !
!JadeiteBrowser class categoriesFor: #openOn:class:!instance creation!public! !
!JadeiteBrowser class categoriesFor: #openOn:dictionary:!instance creation!public! !
!JadeiteBrowser class categoriesFor: #openOn:package:!instance creation!public! !
!JadeiteBrowser class categoriesFor: #openOn:project:!instance creation!public! !

