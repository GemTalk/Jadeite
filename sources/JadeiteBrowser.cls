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

openOn: session className: className
	| browser classService |
	browser := self onSession: session.
	classService := RowanClassService new name: className.
	BrowserUpdate current updateService: classService session: session.
	browser currentCard selectProjectNamed: classService projectName.
	browser currentCard selectPackageNamed: classService packageName.
	browser currentCard selectClassNamed: classService name.
	^browser!

openOn: session packageName: packageName
	| browser packageService |
	browser := self onSession: session.
	packageService := RowanPackageService new name: packageName.
	BrowserUpdate current updateService: packageService session: session.
	browser currentCard selectProjectNamed: packageService projectName.
	browser currentCard selectPackageNamed: packageService name.
	^browser!

openOn: session projectName: projectName
	| projectBrowser |
	projectBrowser := self onSession: session.
	projectBrowser currentCard selectProjectNamed: projectName.
	^projectBrowser! !
!JadeiteBrowser class categoriesFor: #onSession:!instance creation!public! !
!JadeiteBrowser class categoriesFor: #openOn:className:!instance creation!public! !
!JadeiteBrowser class categoriesFor: #openOn:packageName:!instance creation!public! !
!JadeiteBrowser class categoriesFor: #openOn:projectName:!instance creation!public! !

