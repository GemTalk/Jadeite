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

abortedTransaction
	toolbarPresenter view validateUserInterface!

closeRequested: anAssociation
	anAssociation value ifTrue: [self isOkayToChange ifFalse: [anAssociation value: false]]!

createComponents
	super createComponents.
	toolbarPresenter := self add: JadeToolsToolBarPresenter new name: 'leftToolbar'!

createSchematicWiring
	super createSchematicWiring.
	JadePresenter
		when: #abortedTransaction
		send: #abortedTransaction
		to: self!

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

saveCurrentClassTabsToPreferencesFile
	| classNames path createDefaultPrefsFile fileStream file writeStream | 
	classNames := OrderedCollection new.
	self cardsPresenter view cardLayout cards do: 
			[:container |
			| browserPresenter |
			browserPresenter := container presenter.
			browserPresenter selectedClass ifNotNil: [:classService | classNames add: classService name]].
	classNames isEmpty ifTrue: [MessageBox notify: 'No tabs with classes in browser'. ^self].
	path := SessionManager current imageBase , gciSession preferencesFile.
	createDefaultPrefsFile := false.
	(File exists: path)
		ifFalse: 
			[(MessageBox
				confirm: 'Jadeite.prefs does not exist in ' , SessionManager current imageBase , '. Create it?')
					ifTrue: [createDefaultPrefsFile := true]
					ifFalse: [^self]].
	file := File
				open: path
				mode: #open
				check: false.	"create it if it's not there"
	
	[createDefaultPrefsFile
		ifTrue: 
			[fileStream := FileStream on: file.
			fileStream
				nextPutAll: JadeitePreferences preferencesFileDefaultContents;
				flush]]
			ensure: [file close].
	file := File
				open: path
				mode: #append
				check: false.
	
	[writeStream := WriteStream on: String new.
	writeStream
		cr;
		nextPutAll: 'openBrowserOnClasses: '.
	classNames do: 
			[:name |
			writeStream
				nextPutAll: name;
				space]. 
	file write: writeStream contents]
			ensure: [file close].
	MessageBox notify: 'Current class browsers saved to preferences file!!'!

systemBrowserPresenter
	^JadeiteBrowserPresenter!

toolbarPresenter
	"for tests" 
	^toolbarPresenter! !
!JadeiteBrowser categoriesForMethods!
abortedTransaction!event handlers!public! !
closeRequested:!public! !
createComponents!initialization!public! !
createSchematicWiring!initialization!public! !
maximizeCode!public! !
position:!public! !
saveCurrentClassTabsToPreferencesFile!menu handlers!public! !
systemBrowserPresenter!public! !
toolbarPresenter!private! !
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
!JadeiteBrowser class categoriesForMethods!
defaultAdditionalAccelerators!constants!public! !
onSession:!instance creation!public! !
openOn:class:!instance creation!public! !
openOn:dictionary:!instance creation!public! !
openOn:package:!instance creation!public! !
openOn:project:!instance creation!public! !
!

