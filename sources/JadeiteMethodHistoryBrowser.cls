"Filed out from Dolphin Smalltalk 7"!

MethodHistoryBrowser subclass: #JadeiteMethodHistoryBrowser
	instanceVariableNames: 'session'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteMethodHistoryBrowser guid: (GUID fromString: '{a2b0e8a4-20d0-48d3-8b19-98dc5dd55a21}')!
JadeiteMethodHistoryBrowser comment: ''!
!JadeiteMethodHistoryBrowser categoriesForClass!IDB Goodies! !
!JadeiteMethodHistoryBrowser methodsFor!

classService
	"we're repurposing class inst var"

	^class!

diff
	DiffBrowser show
		caption: class name , '>>' , self methodService selector;
		compare: ((history at: selection) at: 3)
			id: 'Version #' , selection printString
			and: ((history at: history size) at: 3)
			id: 'Current'!

methodService
	"we're repurposing selector inst var"

	^selector!

restoreMethod
	Cursor wait showWhile: 
			[self classService
				saveMethod: ((history at: selection) at: 3)
				category: self methodService category
				session: session.
			self updateHistory]!

session
	^session!

session: anObject
	session := anObject!

setCaption
	self caption: (String writeStream
				nextPutAll: 'MethodHistory - ';
				nextPutAll: class name;
				nextPutAll: '>>';
				nextPutAll: self methodService selector asString;
				nextPutAll: '  (';
				print: selection;
				nextPutAll: ' of ';
				print: history size;
				nextPut: $);
				contents)!

updateHistory
	"Get the historic information for the method. Purge consecutive duplicates from the list"

	| methodServiceHistory answeringService |
	Cursor wait showWhile: 
			[answeringService := RowanAnsweringService new
						command: #methodHistoryFor:;
						commandArgs: (Array with: self methodService);
						yourself.
			JadePresenter issueCommand: (Array with: answeringService) session: session].
	history := OrderedCollection new.
	methodServiceHistory := answeringService answer.
	methodServiceHistory do: 
			[:changedMethodService |
			history add: (Array
						with: #sources
						with: changedMethodService selector
						with: changedMethodService source)].
	self setCaption.
	self moveToLast! !
!JadeiteMethodHistoryBrowser categoriesFor: #classService!accessing!public! !
!JadeiteMethodHistoryBrowser categoriesFor: #diff!commands!public! !
!JadeiteMethodHistoryBrowser categoriesFor: #methodService!accessing!public! !
!JadeiteMethodHistoryBrowser categoriesFor: #restoreMethod!commands!public! !
!JadeiteMethodHistoryBrowser categoriesFor: #session!accessing!private! !
!JadeiteMethodHistoryBrowser categoriesFor: #session:!accessing!private! !
!JadeiteMethodHistoryBrowser categoriesFor: #setCaption!operations!public! !
!JadeiteMethodHistoryBrowser categoriesFor: #updateHistory!operations!public! !

!JadeiteMethodHistoryBrowser class methodsFor!

canUseIdeaSpace

	^false!

reuseIfOpen

	^false!

showOnClass: classService selector: methodService
	^self
		showOnClass: classService
		selector: methodService
		debugger: nil!

showOnClass: aClass selector: aSymbol debugger: aDebuggerOrNil
	| inst |
	inst := (self create session: GciSession current) showShell
				setClass: aClass
				selector: aSymbol
				debugger: aDebuggerOrNil.
	inst session: GciSession current.
	^inst! !
!JadeiteMethodHistoryBrowser class categoriesFor: #canUseIdeaSpace!public!testing! !
!JadeiteMethodHistoryBrowser class categoriesFor: #reuseIfOpen!public!testing! !
!JadeiteMethodHistoryBrowser class categoriesFor: #showOnClass:selector:!instance creation!public! !
!JadeiteMethodHistoryBrowser class categoriesFor: #showOnClass:selector:debugger:!instance creation!private! !

