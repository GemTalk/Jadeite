"Filed out from Dolphin Smalltalk 7"!

JadePresenter subclass: #JadeiteLoggerPresenter
	instanceVariableNames: 'logListPresenter'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteLoggerPresenter guid: (GUID fromString: '{cb441c58-d704-44e4-9d81-6e3cf611cfb4}')!
JadeiteLoggerPresenter comment: ''!
!JadeiteLoggerPresenter categoriesForClass!MVP-Presenters! !
!JadeiteLoggerPresenter methodsFor!

createComponents
	super createComponents.
	logListPresenter := self add: ListPresenter new name: 'logList'!

createSchematicWiring

	super createSchematicWiring.
	logListPresenter when: #'actionPerformed' send: #'inspectService' to: self.!

inputClientFile: objects
	| rs |
	rs := FileStream open: BrowserUpdate current logFileName mode: #read.
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
	| rs serverFileContents |
	serverFileContents := gciSession
				executeString: '(RowanLoggingService new fileName: ''' , BrowserUpdate current logFileName
						, ''') logFileContents'.
	rs := ReadStream on: serverFileContents.
	[[rs atEnd] whileFalse: [objects add: (STON fromStream: rs)]] ensure: [rs close]!

inspectService

	logListPresenter selections inspect!

onViewOpened
	super onViewOpened.
	self inputFiles! !
!JadeiteLoggerPresenter categoriesFor: #createComponents!initialization!public! !
!JadeiteLoggerPresenter categoriesFor: #createSchematicWiring!initialization!public! !
!JadeiteLoggerPresenter categoriesFor: #inputClientFile:!private! !
!JadeiteLoggerPresenter categoriesFor: #inputFiles!private! !
!JadeiteLoggerPresenter categoriesFor: #inputServerFile:!private! !
!JadeiteLoggerPresenter categoriesFor: #inspectService!operations!public! !
!JadeiteLoggerPresenter categoriesFor: #onViewOpened!event handlers!public! !

!JadeiteLoggerPresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil nil 5 nil nil nil 416 nil 170 192 8 #() nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 328198 ##(Smalltalk.Point) 7679 21 626 1791 1121 416 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 126 18 0 0 58 2 0 0] 34 1 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 736 nil nil nil 5 nil nil nil 736 nil 170 192 34 2 410 ##(Smalltalk.ListView) 34 30 nil 736 34 2 8 1409388621 1025 832 590662 2 ##(Smalltalk.ListModel) 138 144 496 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 524550 ##(Smalltalk.ColorRef) 8 4278190080 nil 5 nil nil nil 832 nil 8 4294905313 nil ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 2 920646 5 ##(Smalltalk.ListViewColumn) 8 'Client' 893 #left 459270 ##(Smalltalk.Message) #clientDisplayString 496 ##(Smalltalk.SortedCollection) nil nil 832 nil 3 nil nil 1106 8 'Server' 891 #left 1154 #serverDisplayString 496 1154 #<= 496 nil nil 832 nil 3 nil nil #report 496 nil 131171 nil 34 4 nil nil 626 1 1 nil 514 138 144 34 2 578 #createAt:extent: 34 2 626 1 1 626 1791 1121 832 578 #text: 34 1 8 'Client' 832 674 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 127 3 0 0 48 2 0 0] 8 #() 626 193 193 nil 27 8 'logList' nil 514 138 144 34 1 578 #createAt:extent: 34 2 626 1 1 626 1791 1121 736 674 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 127 3 0 0 48 2 0 0] 34 1 832 1488 nil 27 1488 nil 27 )! !
!JadeiteLoggerPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

