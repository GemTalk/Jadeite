"Filed out from Dolphin Smalltalk 7"!

RowanMethodListBrowser subclass: #JadeiteMethodListBrowser
	instanceVariableNames: 'firstReferenceString'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteMethodListBrowser guid: (GUID fromString: '{2e2f252d-6e40-49c6-bc5c-31d1626dcc9a}')!
JadeiteMethodListBrowser comment: ''!
!JadeiteMethodListBrowser categoriesForClass!Unclassified! !
!JadeiteMethodListBrowser methodsFor!

createSchematicWiring

	super createSchematicWiring. 
	self  	 when: #'closeRequested:'		send: #'onCloseRequested:'	to: self primaryPresenter.!

editSaveMethod
	self primaryPresenter methodSourcePresenter editSaveMethod!

firstReferenceString
	^firstReferenceString!

firstReferenceString: anObject
	firstReferenceString := anObject!

onViewClosed
	super onViewClosed.
	BrowserUpdate current
		logComment: 'Closing Method List Browser {' , self identityHash printString , '}'.
	BrowserUpdate current removeEventsTriggeredFor: self primaryPresenter!

onViewOpened
	super onViewOpened.
	BrowserUpdate current
		logComment: 'Opening Method List Browser {' , self identityHash printString , '}'!

presenterClass

	^JadeiteMethodListPresenter!

reformatSource

	^myPresenter reformatSource!

shellName

	^'Jadeite Method List Browser'.
!

updateMethodsWithoutTriggeringEvents: methodServices
	self primaryPresenter methodListPresenter methodListPresenter
		noEventsDo: [self primaryPresenter methods: (Array with: methodServices) selecting: nil]! !
!JadeiteMethodListBrowser categoriesFor: #createSchematicWiring!create schemantic wiring!public! !
!JadeiteMethodListBrowser categoriesFor: #editSaveMethod!menu handlers!public! !
!JadeiteMethodListBrowser categoriesFor: #firstReferenceString!accessing!private! !
!JadeiteMethodListBrowser categoriesFor: #firstReferenceString:!accessing!private! !
!JadeiteMethodListBrowser categoriesFor: #onViewClosed!event handlers!public! !
!JadeiteMethodListBrowser categoriesFor: #onViewOpened!event handlers!public! !
!JadeiteMethodListBrowser categoriesFor: #presenterClass!private! !
!JadeiteMethodListBrowser categoriesFor: #reformatSource!menu handlers!public! !
!JadeiteMethodListBrowser categoriesFor: #shellName!private! !
!JadeiteMethodListBrowser categoriesFor: #updateMethodsWithoutTriggeringEvents:!event handlers!public! !

!JadeiteMethodListBrowser class methodsFor!

openOn: service selecting: string session: gciSession
	| shell stringOrIndex |
	stringOrIndex := service queryResults isEmpty
				ifTrue: [String new]
				ifFalse: [service queryResults first firstReference ifNil: [string]].
	(shell := self showOnSession: gciSession) primaryPresenter methods: service queryResults
		selecting: stringOrIndex.
	shell firstReferenceString: string.
	^shell!

openOn: service selectingAnyMatch: string session: gciSession
	| shell |
	(shell := self showOnSession: gciSession) primaryPresenter methods: service queryResults
		selectingAnyMatch: string.
	^shell!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 1601 1201 551 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.ReferenceView) 34 14 nil 416 34 2 8 1140850688 131073 608 nil nil nil 7 nil nil nil 608 1180166 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteMethodListPresenter) #resource_Default_view nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 5 1 514 1565 1039 608 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 2 0 0 0 0 0 0 0 16 3 0 0 7 2 0 0] 8 #() 514 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 5 962 #fixedParentRight 1 962 #fixedParentTop 1 962 #fixedParentBottom -43 410 ##(Smalltalk.ToolButton) 34 14 nil 416 34 2 8 1140850688 131073 1040 nil 466 8 4278190080 nil 7 nil nil nil 1040 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 1040 34 2 8 1140853580 131137 1136 nil 1104 nil 3 nil nil nil 1136 1104 8 4294906677 nil 170 192 34 2 52153 1115910 ##(Smalltalk.ToolbarIconButton) 52153 nil 1136 1 1180998 4 ##(Smalltalk.CommandDescription) #flipAutoCommit 8 'Auto Commit' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'icons/camera16_light_icon.ico' nil 395334 3 ##(Smalltalk.Bitmap) nil true nil nil nil nil 3 514 33 33 1 34 1 1264 170 176 34 2 1424 1 nil 3 nil 514 33 33 514 39 35 nil nil 706 138 144 34 2 770 #createAt:extent: 34 2 514 1 1 514 49 45 1136 770 #updateSizePosted 896 1136 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 24 0 0 0 22 0 0 0] 8 #() 912 nil 27 706 138 144 34 2 770 #createAt:extent: 34 2 514 1 1039 514 49 45 1040 770 #isEnabled: 8 #(false) 1040 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 7 2 0 0 24 0 0 0 29 2 0 0] 34 1 1136 912 nil 27 930 976 1 976 49 1024 -43 1024 1 410 ##(Smalltalk.TextEdit) 34 16 nil 416 34 2 8 1140850688 1 1920 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 466 8 4278190080 nil 7 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 514 193 193 nil 1920 786694 ##(Smalltalk.IndexedColor) 33554433 8 4294902639 852486 ##(Smalltalk.NullConverter) nil 8 '' 3 706 138 144 34 2 770 #createAt:extent: 34 2 514 49 1039 514 1521 41 1920 770 #setMarginWidths: 34 1 8 #(3 3) 1920 850 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 24 0 0 0 7 2 0 0 16 3 0 0 27 2 0 0] 8 #() 912 nil 27 930 976 49 992 1 962 #fixedPreviousBottom 1 1024 -3 170 192 34 4 1040 8 'autoCommitButton' 1920 8 'statusBarField' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 1 265030 4 ##(Smalltalk.Menu) nil true 34 8 984134 2 ##(Smalltalk.CommandMenuItem) 1 1282 #editSaveMethod 8 'Save' 9383 1 nil nil nil 2674 1 1282 #editFind 8 'Find' 9357 1 nil nil nil 2674 1 1282 #editReplace 8 'Replace' 9361 1 nil nil nil 2674 1 1282 #reformatSource nil 13471 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 2674 1 1282 #jadeExecute 8 'Execute' 9355 1 nil nil nil 2674 1 1282 #jadeInspect 8 'Inspect' 9379 1 nil nil nil 2674 1 1282 #jadeDisplay 8 'Display' 9353 1 nil nil nil 8 'Edit' nil 134217729 nil nil 52173 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 706 138 144 34 3 770 #createAt:extent: 34 2 514 7679 21 514 1601 1201 416 770 #text: 34 1 8 'Jadeite Method List Browser' 416 770 #updateMenuBar 896 416 850 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 31 18 0 0 98 2 0 0] 34 3 608 1920 1040 912 nil 27 )! !
!JadeiteMethodListBrowser class categoriesFor: #openOn:selecting:session:!instance creation!public! !
!JadeiteMethodListBrowser class categoriesFor: #openOn:selectingAnyMatch:session:!instance creation!public! !
!JadeiteMethodListBrowser class categoriesFor: #resource_Default_view!public!resources-views! !

