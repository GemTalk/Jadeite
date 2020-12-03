"Filed out from Dolphin Smalltalk 7"!

JadeFindDialog subclass: #JadeitePackageDialog
	instanceVariableNames: 'packageListPresenter availablePackages'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeitePackageDialog guid: (GUID fromString: '{3a7f6cdb-e959-4b89-99e5-09fc13461d9d}')!
JadeitePackageDialog comment: ''!
!JadeitePackageDialog categoriesForClass!Unclassified! !
!JadeitePackageDialog methodsFor!

additionalAccelerators
	^#(#(#selectNextPackage 'DOWN') #(#selectPreviousPackage 'UP'))!

createComponents
	super createComponents.
	packageListPresenter := self add: ListPresenter new name: 'packageList'!

createSchematicWiring
	super createSchematicWiring.
	packageListPresenter
		when: #actionPerformed
		send: #ok
		to: self!

initializeAvailable
	"sorted on server"
	^self model value!

ok

	self model value: packageListPresenter selectionOrNil.
	super ok.
!

onViewOpened
	availablePackages := self initializeAvailable.
	self model value: nil.
	super onViewOpened.!

selectNextPackage
	packageListPresenter
		selectionByIndex: (packageListPresenter selectionByIndex + 1 min: packageListPresenter list size)!

selectPreviousPackage
	packageListPresenter selectionByIndex: (packageListPresenter selectionByIndex - 1 max: 1)!

updateList
	| list |
	list := availablePackages select: [:each | nameEntryPresenter value , '*' match: each name].
	packageListPresenter list: list.
	list size >= 1 ifTrue: [packageListPresenter selectionByIndex: 1]! !
!JadeitePackageDialog categoriesFor: #additionalAccelerators!accessing!public! !
!JadeitePackageDialog categoriesFor: #createComponents!initialization!public! !
!JadeitePackageDialog categoriesFor: #createSchematicWiring!private! !
!JadeitePackageDialog categoriesFor: #initializeAvailable!private! !
!JadeitePackageDialog categoriesFor: #ok!private! !
!JadeitePackageDialog categoriesFor: #onViewOpened!private! !
!JadeitePackageDialog categoriesFor: #selectNextPackage!private! !
!JadeitePackageDialog categoriesFor: #selectPreviousPackage!private! !
!JadeitePackageDialog categoriesFor: #updateList!private! !

!JadeitePackageDialog class methodsFor!

resource_DefaultView
	"Answer the literal data from which the 'DefaultView' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_DefaultView)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.DialogView) 34 30 nil nil 8 #(13107200 65536) 416 nil 327686 ##(Smalltalk.Color) #default nil 37 nil nil nil 416 788230 ##(Smalltalk.BorderLayout) 1 1 nil 410 ##(Smalltalk.ReferenceView) 34 14 nil 416 34 2 8 1140850688 131073 528 nil nil nil 7 nil nil nil 528 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.Presenter) #resource_OK_Cancel_button_block nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 328198 ##(Smalltalk.Point) 21 413 738 1129 71 528 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 10 0 0 0 206 0 0 0 62 2 0 0 241 0 0 0] 8 #() 738 193 193 nil 27 nil nil nil 170 192 34 4 410 ##(Smalltalk.TextEdit) 34 16 nil 416 34 2 8 1140916352 1025 896 nil 480 nil 7 nil nil nil 896 nil 8 1737104896 852486 ##(Smalltalk.NullConverter) nil nil 5 626 138 144 34 2 690 #createAt:extent: 34 2 738 215 1 738 951 39 896 690 #text: 34 1 8 '*' 896 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 107 0 0 0 0 0 0 0 70 2 0 0 19 0 0 0] 8 #() 848 nil 27 8 'nameEntry' 410 ##(Smalltalk.ListView) 34 45 nil 416 34 2 8 1140920397 1025 1232 590662 2 ##(Smalltalk.ListModel) 138 144 832 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 nil nil nil 1232 nil 8 1737156720 ##(Smalltalk.BasicListAbstract) ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 2 920646 5 ##(Smalltalk.ListViewColumn) 8 'Package' 601 #left 459270 ##(Smalltalk.Message) #displayString 8 #() 1506 #<= 1536 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 1568 8 'doIt' 8 '[:service | service name]' 8 #[30 105 226 0 106] #name 1584 7 257 nil nil 1232 nil 1 1570 0 nil 1602 1 83886081 1568 8 'doIt' 8 '[:each | each]' 1779525917 1680 7 257 nil nil 1458 8 'Project' 601 #left 1506 #displayString 8 #() ##(Smalltalk.SortedCollection) 1570 0 nil 1602 2 1 1568 8 'doIt' 8 '[:service | service projectName]' 8 #[30 105 226 0 106] #projectName 1808 7 257 nil nil 1232 nil 1 1570 0 nil 1602 1 83886081 1568 8 'doIt' 8 '[:each | each]' 1779525917 1888 7 257 nil nil #report 8 #() nil 133217 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 626 138 144 34 2 690 #createAt:extent: 34 2 738 5 39 738 1161 391 1232 690 #text: 34 1 8 'Package' 1232 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 2 0 0 0 19 0 0 0 70 2 0 0 214 0 0 0] 8 #() 848 nil 35 8 'packageList' 590342 ##(Smalltalk.Rectangle) 738 21 21 738 21 21 nil nil nil nil 10361 nil nil nil nil 1 nil nil 590598 ##(Smalltalk.Semaphore) nil nil 1 nil 8 2010340112 626 138 144 34 2 690 #createAt:extent: 34 2 738 7545 21 738 1201 581 416 690 #text: 34 1 8 'Jadeite Find Class Dialog' 416 786 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 188 14 0 0 10 0 0 0 20 17 0 0 44 1 0 0] 34 4 410 ##(Smalltalk.StaticText) 34 16 nil 416 34 2 8 1140850944 1 2512 nil nil nil 7 nil nil nil 2512 nil 8 1737263776 978 nil nil nil 626 138 144 34 2 690 #createAt:extent: 34 2 738 1 1 738 211 41 2512 690 #text: 34 1 8 'Class Name:' 2512 786 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 105 0 0 0 20 0 0 0] 8 #() 848 nil 27 896 1232 528 848 nil 27 )! !
!JadeitePackageDialog class categoriesFor: #resource_DefaultView!public!resources-views! !

