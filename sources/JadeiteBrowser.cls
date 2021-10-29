"Filed out from Dolphin Smallalk"!

JadeiteProjectsSystemBrowser subclass: #JadeiteBrowser
	instanceVariableNames: 'toolbarPresenter'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteBrowser guid: (GUID fromString: '{4ed2f816-dbc6-4ce7-b7ef-c483e56b9397}')!
JadeiteBrowser comment: ''!
!JadeiteBrowser categoriesForClass!Unclassified! !
!JadeiteBrowser methodsFor!

closeRequested: anAssociation
	anAssociation value ifTrue: [self isOkayToChange ifFalse: [anAssociation value: false]]!

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
!JadeiteBrowser categoriesForMethods!
closeRequested:!public! !
maximizeCode!public! !
position:!public! !
systemBrowserPresenter!public! !
!

!JadeiteBrowser class methodsFor!

defaultAdditionalAccelerators
	^super defaultAdditionalAccelerators, #(#(#insertIfFalse 'Ctrl+Shift+D') #(#insertIfTrue 'Ctrl+Shift+T'))!

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
	browser currentCard selectPackageNamed: packageService name for: nil.
	browser currentCard packageListPresenter setFocus.
	^browser!

openOn: session project: projectService
	| browser |
	browser := self onSession: session.
	browser currentCard selectProjectNamed: projectService name.
	browser currentCard projectListPresenter setFocus.
	^browser! !

abortedTransaction
	toolbarPresenter view validateUserInterface!

createComponents
	super createComponents.
	toolbarPresenter := self add: JadeToolsToolBarPresenter new name: 'leftToolbar'!

createSchematicWiring
	super createSchematicWiring.
	JadePresenter
		when: #abortedTransaction
		send: #abortedTransaction
		to: self!

onViewClosed
	super onViewClosed.
	JadePresenter removeEventsTriggeredFor: self!

queryCommand: aCommandQuery
	| command |
	command := aCommandQuery command.
	command = #commitTransaction
		ifTrue: 
			[aCommandQuery isEnabled: JadePresenter isCommitEnabled.
			^true].
	command = #beginTransaction
		ifTrue: 
			[aCommandQuery isEnabled: JadePresenter isBeginTransactionEnabled.
			^true].
	^super queryCommand: aCommandQuery!

systemBrowserPresenter
	^JadeiteBrowserPresenter! !

toolbarPresenter
	"for tests" 
	^toolbarPresenter! !

!JadeiteBrowser class categoriesForMethods!
defaultAdditionalAccelerators!constants!public! !
onSession:!instance creation!public! !
openOn:class:!instance creation!public! !
openOn:dictionary:!instance creation!public! !
openOn:package:!instance creation!public! !
openOn:project:!instance creation!public! !
!
