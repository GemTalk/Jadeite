"Filed out from Dolphin Smalltalk 7"!

JadeFindDialog subclass: #JadeiteFindMethodDialog
	instanceVariableNames: 'listPresenter available'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteFindMethodDialog guid: (GUID fromString: '{c2dc95ba-61f0-42a4-b745-50a7cacaeea3}')!
JadeiteFindMethodDialog comment: ''!
!JadeiteFindMethodDialog categoriesForClass!Unclassified! !
!JadeiteFindMethodDialog methodsFor!

createComponents

	super createComponents.
	listPresenter 		:= self add: ListPresenter		new name: 'list'.
!

createSchematicWiring

	super createSchematicWiring.
	listPresenter 		when: #actionPerformed 	send: #ok			to: self.!

listPresenter
	"Private - for testing"

	^listPresenter!

ok
	self model value removeAllEventsTriggered.
	self model value: listPresenter selectionOrNil.
	super ok.
!

onViewOpened

	super onViewOpened. 
	self updateList!

updateList
	| list |
	list := model value methods select: [:each | nameEntryPresenter value , '*' match: each name].
	listPresenter list: list.
	list size >= 1 ifTrue: [listPresenter selectionByIndex: 1]! !
!JadeiteFindMethodDialog categoriesFor: #createComponents!private! !
!JadeiteFindMethodDialog categoriesFor: #createSchematicWiring!private! !
!JadeiteFindMethodDialog categoriesFor: #listPresenter!accessing!private! !
!JadeiteFindMethodDialog categoriesFor: #ok!event handlers!public! !
!JadeiteFindMethodDialog categoriesFor: #onViewOpened!event handlers!public! !
!JadeiteFindMethodDialog categoriesFor: #updateList!private! !

!JadeiteFindMethodDialog class methodsFor!

resource_DefaultView
	"Answer the literal data from which the 'DefaultView' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_DefaultView)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.DialogView) 34 30 nil nil 8 #(13107200 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 nil 167 nil nil nil 416 788230 ##(Smalltalk.BorderLayout) 1 1 nil 410 ##(Smalltalk.ReferenceView) 34 14 nil 416 34 2 8 1140850688 131073 544 nil nil nil 7 nil nil nil 544 1180166 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.Presenter) #resource_OK_Cancel_button_block nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 328198 ##(Smalltalk.Point) 21 433 754 1129 51 544 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 10 0 0 0 216 0 0 0 62 2 0 0 241 0 0 0] 8 #() 754 193 193 nil 27 nil nil nil 170 192 34 4 410 ##(Smalltalk.ListView) 34 30 nil 416 34 2 8 1140920397 1025 912 590662 2 ##(Smalltalk.ListModel) 138 144 848 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 466 496 nil 7 nil nil nil 912 nil 8 4294910659 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 2 920646 5 ##(Smalltalk.ListViewColumn) 8 'Selector' 575 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 1200 8 'doIt' 8 '[:service | service selector]' 8 #[30 105 226 0 106] #selector 1216 7 257 nil nil 912 nil 1 1202 0 nil 1234 1 83886081 1200 8 'doIt' 8 '[:each | each]' 1779525917 1312 7 257 nil nil 1154 8 'Category' 575 #left 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.SortedCollection) 1202 0 nil 1234 2 1 1200 8 'doIt' 8 '[:service | service category]' 8 #[30 105 226 0 106] #category 1456 7 257 nil nil 912 nil 1 1202 0 nil 1234 1 83886081 1200 8 'doIt' 8 '[:each | each]' 1779525917 1536 7 257 nil nil #report 848 nil 133217 nil 34 4 nil nil 754 1 1 nil 642 138 144 34 2 706 #createAt:extent: 34 2 754 5 39 754 1161 391 912 706 #text: 34 1 8 'Selector' 912 802 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 2 0 0 0 19 0 0 0 70 2 0 0 214 0 0 0] 8 #() 864 nil 27 8 'list' 410 ##(Smalltalk.TextEdit) 34 16 nil 416 34 2 8 1140916352 1025 1856 nil 466 496 nil 7 nil nil nil 1856 nil 8 4294911699 852486 ##(Smalltalk.NullConverter) nil nil 5 642 138 144 34 2 706 #createAt:extent: 34 2 754 215 1 754 951 51 1856 706 #text: 34 1 8 '*' 1856 802 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 107 0 0 0 0 0 0 0 70 2 0 0 25 0 0 0] 8 #() 864 nil 27 8 'nameEntry' 590342 ##(Smalltalk.Rectangle) 754 21 21 754 21 21 nil nil nil nil 54749 nil nil nil nil 1 nil nil 590598 ##(Smalltalk.Semaphore) nil nil 1 nil 8 1998073872 642 138 144 34 3 706 #createAt:extent: 34 2 754 7679 21 754 1201 581 416 706 #text: 34 1 8 'Jadeite Find Method Dialog' 416 706 #updateMenuBar 848 416 802 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 87 17 0 0 44 1 0 0] 34 4 410 ##(Smalltalk.StaticText) 34 16 nil 416 34 2 8 1140850944 1 2544 nil nil nil 7 nil nil nil 2544 nil 8 1695245616 1954 nil nil nil 642 138 144 34 2 706 #createAt:extent: 34 2 754 1 1 754 211 41 2544 706 #text: 34 1 8 'Method Selector:
Name:' 2544 802 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 105 0 0 0 20 0 0 0] 8 #() 864 nil 27 1856 912 544 864 nil 27 )! !
!JadeiteFindMethodDialog class categoriesFor: #resource_DefaultView!public!resources-views! !

