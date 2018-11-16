"Filed out from Dolphin Smalltalk 7"!

RowanMethodSourcePresenter subclass: #JadeiteMethodSourcePresenter
	instanceVariableNames: 'methodService'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteMethodSourcePresenter guid: (GUID fromString: '{c31ba898-ca43-466f-9627-726fb3531dca}')!
JadeiteMethodSourcePresenter comment: ''!
!JadeiteMethodSourcePresenter categoriesForClass!Unclassified! !
!JadeiteMethodSourcePresenter methodsFor!

createSchematicWiring
	super createSchematicWiring.
	documentPresenter
		when: #textChanged
		send: #methodValueChanged
		to: self!

editMenuStrings

	false ifTrue: [
		self editSaveMethod; undo; redo; cutSelection; copySelection; pasteClipboard; clearSelection; selectAll; editFind; editFindNext; editReplace; 
			jadeDisplay; jadeExecute; jadeInspect; browseSelectedClass.
	].
	^#(
		'&Edit'
		'&Save/Ctrl+S/editSaveMethod' 
		'-'
		'&Undo/Ctrl+Z/undo'
		'&Redo/Ctrl+Y/redo'
		'-'
		'&Reformat Source/Ctrl+R/reformatSource'
		'-'
		'&Cu&t/Ctrl+X/cutSelection'
		'&Copy/Ctrl+C/copySelection'
		'&Paste/Ctrl+V/pasteClipboard'
		'&Delete/Delete/clearSelection'
		'-'
		'Select &All/Ctrl+A/selectAll'
		'-'
		'&Find/Ctrl+F/editFind'
		'Find &Next/F3/editFindNext'
		'&Replace/Ctrl+H/editReplace'
		'-'
		'Display/Ctrl+D/jadeDisplay'
		'Execute/Ctrl+E/jadeExecute'
		'Inspect/Ctrl+Q/jadeInspect'
		'Debug/Ctrl+B/jadeDebug'
		'Browse Class/Ctrl+P/browseSelectedClass'
	).
!

editSaveMethod
	| classService |
	classService := RowanClassService named: methodService className.
	classService meta: methodService meta.
	self
		editSaveMethod: classService
		in: documentPresenter
		category: methodService category.!

fileSave
	self editSaveMethod!

methodListSelection

	^methodService!

methodService
	^methodService!

methodService: anObject
	methodService := anObject!

methodSourceEqual
	^documentPresenter value = methodService source 
	!

methodValueChanged
	methodService ifNil:[^true].
	self methodSourceEqual
		ifTrue: 
			[documentPresenter view
				backcolor: JadeTextStyles default colorForNoEdits;
				isModified: false.
			self statusBarText: String new]
		ifFalse: 
			[documentPresenter view
				backcolor: JadeTextStyles default colorForUnsavedEdits;
				clearContainerIndicators]!

onViewOpened
	super onViewOpened.
	self registerPresentersForUpdates. !

registerPresentersForUpdates
	BrowserUpdate current
		register: documentPresenter
		selector: #methodSourceUpdate:browser:
		browser: self!

update
	^self updateMethodSource!

updateMethodSource
	methodService isNil ifTrue: [^self setDefaultMethod].
	documentPresenter
		value: methodService source;
		isModified: false.
	documentPresenter view
		backcolor: JadeTextStyles default colorForNoEdits;
		isEnabled: true;
		yourself.
	self refreshBreakPointsIn: documentPresenter!

value: string

	documentPresenter value: string! !
!JadeiteMethodSourcePresenter categoriesFor: #createSchematicWiring!create schemantic wiring!private! !
!JadeiteMethodSourcePresenter categoriesFor: #editMenuStrings!menu handlers!private! !
!JadeiteMethodSourcePresenter categoriesFor: #editSaveMethod!menu handlers!public! !
!JadeiteMethodSourcePresenter categoriesFor: #fileSave!menu handlers!public! !
!JadeiteMethodSourcePresenter categoriesFor: #methodListSelection!accessing!public! !
!JadeiteMethodSourcePresenter categoriesFor: #methodService!accessing!private! !
!JadeiteMethodSourcePresenter categoriesFor: #methodService:!accessing!private! !
!JadeiteMethodSourcePresenter categoriesFor: #methodSourceEqual!public!testing! !
!JadeiteMethodSourcePresenter categoriesFor: #methodValueChanged!event handlers!public! !
!JadeiteMethodSourcePresenter categoriesFor: #onViewOpened!event handlers!public! !
!JadeiteMethodSourcePresenter categoriesFor: #registerPresentersForUpdates!public!register presenters! !
!JadeiteMethodSourcePresenter categoriesFor: #update!public!updating! !
!JadeiteMethodSourcePresenter categoriesFor: #updateMethodSource!public!updating! !
!JadeiteMethodSourcePresenter categoriesFor: #value:!public! !

!JadeiteMethodSourcePresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil nil 5 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1140851500 131137 544 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 nil 517 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 328198 ##(Smalltalk.Point) 193 193 nil 544 610 640 8 4294907395 170 192 8 #() 170 192 34 24 12893 853766 ##(Smalltalk.ToolbarButton) 12893 nil 544 1 1180998 4 ##(Smalltalk.CommandDescription) #jadeDisplay 8 'Display' 1 1 nil 395334 3 ##(Smalltalk.Bitmap) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'Tools.bmp' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil nil 7 738 1857 33 55 12895 866 12895 nil 544 1 898 #jadeExecute 8 'Execute' 1 1 nil 960 57 12897 866 12897 nil 544 1 898 #jadeInspect 8 'Inspect' 1 1 nil 960 59 12899 1246982 ##(Smalltalk.ToolbarSystemButton) 12899 nil 544 1 898 #editSaveMethod 8 'Save' 9383 1 nil 1 17 12901 1186 12901 nil 544 1 898 #editCut 8 'Cut' 1 1 nil 1 1 12903 1186 12903 nil 544 1 898 #copySelection 8 'Copy' 1 1 nil 1 3 12905 1186 12905 nil 544 1 898 #editPaste 8 'Paste' 1 1 nil 1 5 12907 1186 12907 nil 544 1 898 #editDelete 8 'Delete' 1 1 nil 1 11 12909 1186 12909 nil 544 1 898 #undo 8 'Undo' 1 1 nil 1 7 12911 1186 12911 nil 544 1 898 #redo 8 'Redo' 1 1 nil 1 9 12913 1186 12913 nil 544 1 898 #editFind 8 'Find' 1 1 nil 1 25 12915 1186 12915 nil 544 1 898 #editReplace 8 'Replace' 1 1 nil 1 27 34 15 880 1088 1136 1050118 ##(Smalltalk.ToolbarSeparator) nil nil 544 3 nil 1 1200 1650 nil nil 544 3 nil 1 1248 1296 1344 1392 1440 1488 1650 nil nil 544 3 nil 1 1536 1584 170 176 34 4 1 117 960 1 nil 1 nil 738 33 33 738 45 45 nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 738 1 1 738 1001 51 544 1842 #updateSizePosted 816 544 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 244 1 0 0 25 0 0 0] 8 #() 738 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 2050 #fixedParentRight 1 2050 #fixedParentTop 1 2050 #fixedViewTop 51 410 ##(Smalltalk.ScintillaView) 34 50 nil 416 34 2 8 1445007428 1025 2128 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 610 8 4278190080 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 22 984134 2 ##(Smalltalk.CommandMenuItem) 1 898 #undo 8 '&Undo' 9397 1 nil nil nil 2338 1 898 #redo 8 'R&edo' 9395 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 2338 1 898 #editCut 8 'Cu&t' 9393 1 nil nil nil 2338 1 898 #editCopy 8 '&Copy' 9351 1 nil nil nil 2338 1 898 #editPaste 8 '&Paste' 9389 1 nil nil nil 2338 1 898 #editDelete 8 'De&lete' 1629 1 nil nil nil 2338 1 898 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 2450 4097 2338 1 898 #editFind 8 '&Find...' 9357 1 nil nil nil 2338 1 898 #editFindNext 8 'Find &Next' 9359 1 nil nil nil 2338 1 898 #editReplace 8 '&Replace...' 9361 1 nil nil nil 2450 4097 2338 1 898 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 2338 1 898 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 2338 1 898 #jadeExecute 8 'Execute' 9355 1 nil nil nil 2338 1 898 #jadeDebug 8 'De&bug' 9349 1 nil nil nil 2450 4097 2338 1 898 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 2338 1 898 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 2450 4097 2338 1 898 #fileIn 8 'File In' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil 658 nil true 690 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 738 193 193 nil 2128 nil 8 4294907213 852486 ##(Smalltalk.NullConverter) nil nil 9 nil 170 192 34 4 #callTip 1182790 1 ##(Smalltalk.ScintillaTextStyle) 77 786694 ##(Smalltalk.IndexedColor) 33554457 3458 33554471 1 nil nil nil nil #callTip nil nil nil #normal 3426 1 nil nil 1 nil nil nil nil #normal nil nil nil 34 256 3504 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3440 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1639686 ##(Smalltalk.SmalltalkExpressionStyler) 1 nil nil false 138 144 816 170 192 34 2 #default 1641542 1 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 2128 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 816 nil 170 176 816 9215 nil nil nil nil 3458 33554447 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 4 #callTip 3440 #normal 3504 nil nil nil nil 1 nil 170 192 34 12 1 1510470 2 ##(Smalltalk.ScintillaIndicatorStyle) 1 2128 65025 3 false 1 nil nil nil nil nil nil 3 3890 3 2128 33423361 5 false 3 nil nil nil nil nil nil 5 3890 5 2128 511 1 false 5 nil nil nil nil nil nil 8 'indicator8' 3890 17 2128 33554447 1 nil nil nil nil nil nil nil nil 8 'indicator10' 3890 21 2128 33554459 3 nil nil nil nil nil nil nil nil 8 'indicator9' 3890 19 2128 33554459 13 nil nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 3426 1029 nil 196934 1 ##(Smalltalk.RGB) 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 3426 1027 4098 60239 4098 31326207 1 nil nil nil nil #Warning nil nil nil #Error 3426 1031 4098 335 4098 31317503 1 nil nil nil nil #Error nil nil nil nil 1778 138 144 34 10 1842 #createAt:extent: 34 2 738 1 51 738 1001 551 2128 1842 #contextMenu: 34 1 2304 2128 1842 #modificationEventMask: 8 #(4607) 2128 1842 #hoverTime: 8 #(200) 2128 1842 #caretPeriod: 8 #(530) 2128 1842 #wordWrap: 8 #(true) 2128 1842 #margins: 34 1 34 3 985158 2 ##(Smalltalk.ScintillaMargin) 1 2128 61 3 nil nil nil nil 4546 3 2128 1 nil 3 67108863 nil nil 4546 5 2128 1 nil 3 -67108863 nil nil 2128 1842 #canHScroll: 8 #(false) 2128 1842 #tabWidth: 8 #(4) 2128 1842 #maxCompletionListHeight: 8 #(9) 2128 1938 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 244 1 0 0 44 1 0 0] 8 #() 2000 nil 29 2018 2064 1 2080 1 2050 #fixedPreviousBottom 1 2050 #fixedParentBottom 1 170 192 34 2 2128 8 'document' nil 1778 138 144 34 1 1842 #createAt:extent: 34 2 738 7679 21 738 1001 601 416 1938 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 243 16 0 0 54 1 0 0] 34 2 544 2128 2000 nil 27 )! !
!JadeiteMethodSourcePresenter class categoriesFor: #resource_Default_view!public!resources-views! !

