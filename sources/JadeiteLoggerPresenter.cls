"Filed out from Dolphin Smalltalk 7"!

JadePresenter subclass: #JadeiteLoggerPresenter
	instanceVariableNames: 'logListPresenter clientFilename serverFilename'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteLoggerPresenter guid: (GUID fromString: '{cb441c58-d704-44e4-9d81-6e3cf611cfb4}')!
JadeiteLoggerPresenter comment: ''!
!JadeiteLoggerPresenter categoriesForClass!MVP-Presenters! !
!JadeiteLoggerPresenter methodsFor!

additionalAccelerators
	^#(#(#raiseConsole 'Ctrl+F7'))!

clientFilename
	^clientFilename!

clientFilename: anObject
	clientFilename := anObject!

createComponents
	super createComponents.
	logListPresenter := self add: ListPresenter new name: 'logList'!

createSchematicWiring

	super createSchematicWiring.
	logListPresenter when: #'actionPerformed' send: #'inspectService' to: self.!

inputClientFile: objects
	| rs filename |
	filename := clientFilename ifNil: [BrowserUpdate current logFileName].
	filename isNil ifTrue:[^self].
	rs := FileStream open: filename mode: #read.
	[[rs atEnd] whileFalse: [objects add: (STON fromStream: rs)]] ensure: [rs close]!

inputFiles
	| sorted |
	sorted := SortedCollection
				sortBlock: [:x :y | x groupId < y groupId or: [x groupId = y groupId and: [x id < y id]]].
	self inputClientFile: sorted.
	self inputServerFile: sorted.
	logListPresenter model: (ListModel withAll: sorted).
	logListPresenter view vertScrollPos: 100000 "seems there should be a better way to show the bottom of the list"!

inputServerFile: objects
	"don't use a service call otherwise the returned string will slowly be turned into objects by ston"

	| rs serverFileContents |
	rs := serverFilename
				ifNil: 
					[BrowserUpdate current logFileName ifNil: [^self].
					serverFileContents := gciSession
								executeString: '(RowanLoggingService new fileName: ''' , BrowserUpdate current logFileName
										, ''') logFileContents'.
					ReadStream on: serverFileContents]
				ifNotNil: [FileStream open: serverFilename mode: #read].
	[[rs atEnd] whileFalse: [objects add: (STON fromStream: rs)]] ensure: [rs close]!

inspectService
	SessionManager current isRuntime ifFalse: [logListPresenter selections inspect]!

onViewOpened
	super onViewOpened.
	self inputFiles!

raiseConsole
	| transcript |
	transcript := JadeiteTranscript allInstances
				detect: [:trans | trans gciSession = GciSession current]
				ifNone: [^self].
	transcript view setFocus!

serverFilename
	^serverFilename!

serverFilename: anObject
	serverFilename := anObject! !
!JadeiteLoggerPresenter categoriesFor: #additionalAccelerators!accessing!public! !
!JadeiteLoggerPresenter categoriesFor: #clientFilename!accessing!private! !
!JadeiteLoggerPresenter categoriesFor: #clientFilename:!accessing!private! !
!JadeiteLoggerPresenter categoriesFor: #createComponents!initialization!public! !
!JadeiteLoggerPresenter categoriesFor: #createSchematicWiring!initialization!public! !
!JadeiteLoggerPresenter categoriesFor: #inputClientFile:!private! !
!JadeiteLoggerPresenter categoriesFor: #inputFiles!private! !
!JadeiteLoggerPresenter categoriesFor: #inputServerFile:!private! !
!JadeiteLoggerPresenter categoriesFor: #inspectService!operations!public! !
!JadeiteLoggerPresenter categoriesFor: #onViewOpened!event handlers!public! !
!JadeiteLoggerPresenter categoriesFor: #raiseConsole!menu handlers!public! !
!JadeiteLoggerPresenter categoriesFor: #serverFilename!accessing!private! !
!JadeiteLoggerPresenter categoriesFor: #serverFilename:!accessing!private! !

!JadeiteLoggerPresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil nil 5 nil nil nil 416 nil 170 192 34 4 410 ##(Smalltalk.StaticPath) 34 17 nil 416 34 2 8 1140850944 1 512 nil nil nil 5 nil nil nil 512 nil 8 1678140720 852486 ##(Smalltalk.NullConverter) nil nil nil 8 'c:\Program Files\Dolphin Smalltalk' 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 328198 ##(Smalltalk.Point) 891 1121 754 901 41 512 706 #text: 34 1 624 512 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 189 1 0 0 48 2 0 0 127 3 0 0 68 2 0 0] 8 #() 754 193 193 nil 27 8 'serverFilenameText' 410 ##(Smalltalk.StaticPath) 34 17 nil 416 34 2 8 1140850944 1 928 nil nil nil 5 nil nil nil 928 nil 8 1678140720 594 nil nil nil 624 642 138 144 34 2 706 #createAt:extent: 34 2 754 1 1121 754 891 41 928 706 #text: 34 1 624 928 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 48 2 0 0 189 1 0 0 68 2 0 0] 8 #() 896 nil 27 8 'clientFilenameText' nil 642 138 144 34 1 706 #createAt:extent: 34 2 754 7679 21 754 1791 1161 416 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 126 18 0 0 78 2 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 1392 nil nil nil 5 nil nil nil 1392 nil 170 192 34 2 410 ##(Smalltalk.ListView) 34 30 nil 1392 34 2 8 1409388621 1025 1488 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 524550 ##(Smalltalk.ColorRef) 8 4278190080 nil 5 nil nil nil 1488 nil 8 4294904653 nil ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 2 920646 5 ##(Smalltalk.ListViewColumn) 8 'Client' 893 #left 459270 ##(Smalltalk.Message) #clientDisplayString 8 #() ##(Smalltalk.SortedCollection) nil nil 1488 nil 3 nil nil 1778 8 'Server' 891 #left 1826 #serverDisplayString 1856 1826 #<= 1856 nil nil 1488 nil 3 nil nil #report 1600 nil 131171 nil 34 4 nil nil 754 1 1 nil 642 138 144 34 2 706 #createAt:extent: 34 2 754 1 1 754 1791 1121 1488 706 #text: 34 1 8 'Client' 1488 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 127 3 0 0 48 2 0 0] 8 #() 896 nil 27 8 'logList' nil 642 138 144 34 1 706 #createAt:extent: 34 2 754 1 1 754 1791 1121 1392 834 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 127 3 0 0 48 2 0 0] 34 1 1488 896 nil 27 928 512 896 nil 27 )! !
!JadeiteLoggerPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

