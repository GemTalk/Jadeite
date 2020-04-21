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
			send: #updateMethodSourceColor
			to: self;
		when: #valueChanged
			send: #methodValueChanged
			to: self!

editMenuStrings
	false ifTrue: [
		self editSaveMethod; undo; redo; editRevert; reformatSource; cutSelection; copySelection; pasteClipboard; clearSelection; selectAll; editFind; editFindNext; editReplace; 
			jadeDisplay; jadeExecute; jadeInspect; browseSelectedClass.
	].
	^#(
		'&Edit'
		'&Save/Ctrl+S/editSaveMethod' 
		'-'
		'&Undo/Ctrl+Z/undo'
		'&Redo/Ctrl+Y/redo'
		'Revert//editRevert'
		'-'
		'&Reformat Source/Ctrl+Shift+O/reformatSource'
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

editRevert
	self isOkayToChange
		ifTrue: 
			[documentPresenter value: self parentPresenter methodListPresenter selection source.
			self displayNoMods: self documentPresenter]!

editSaveMethod
	| classService |
	methodService ifNil:[^self]. 
	classService := RowanClassService named: methodService className.
	classService meta: methodService meta.
	self
		editSaveMethod: classService
		in: documentPresenter
		category: methodService category.
	self parentPresenter postEditSaveMethod!

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
	methodService ifNil: [^true].
	self methodSourceEqual
		ifTrue: 
			[documentPresenter view
				backcolor: JadeiteTextStyles default colorForNoEdits;
				isModified: false.
			self statusBarText: String new]
		ifFalse: 
			[documentPresenter view
				backcolor: JadeiteTextStyles default colorForUnsavedEdits;
				clearContainerIndicators]!

onViewClosed
	(Delay forMilliseconds: 2) wait.  "let paint events finish" 
	super onViewClosed.
	subPresenters do: [:presenter | BrowserUpdate current removeEventsTriggeredFor: presenter]!

onViewOpened
	super onViewOpened.
	self registerPresentersForUpdates!

reformatSource
	methodService
		source: documentPresenter value;
		command: #reformatSource;
		commandArgs: Array new.
	[self issueCommand: (Array with: methodService)] on: Error
		do: 
			[:ex |
			self setCompileErrorColor.
			self statusBarText: 'Reformat failed. Illegal source'.
			^false].
	documentPresenter view performUndoableAction: 
			[documentPresenter view modifyText: [documentPresenter view sciSetText: methodService source]].
	documentPresenter value: methodService source.
	documentPresenter view isModified: true.
	documentPresenter view
		backcolor: JadeiteTextStyles default colorForUnsavedEdits;
		clearContainerIndicators.
	self setStatusBarDefault.
	self statusBarText: String new.
	^documentPresenter value!

registerPresentersForUpdates
	BrowserUpdate current
		register: documentPresenter
		selector: #methodSourceUpdate:browser:
		browser: self!

resetSourcePane
	self value: String new.
	documentPresenter view backcolor: JadeiteTextStyles default colorForNoEdits.
	documentPresenter view isReadOnly: true!

statusBarText: aString
	self topShell statusBarText: aString.
	(self topShell view viewNamed: 'statusBarField') invalidate
!

update
	^self updateMethodSource!

updateMethodSource
	methodService isNil ifTrue: [^self setDefaultMethod].
	documentPresenter
		value: methodService source;
		isModified: false.
	documentPresenter view
		backcolor: JadeiteTextStyles default colorForNoEdits;
		isEnabled: true;
		yourself.
	self refreshBreakPointsIn: documentPresenter!

updateMethodSourceColor
	documentPresenter view isModified
		ifTrue: [documentPresenter view backcolor: JadeiteTextStyles default colorForUnsavedEdits]
		ifFalse: [documentPresenter view backcolor: JadeiteTextStyles default colorForNoEdits].
	documentPresenter view invalidate. !

value
	^documentPresenter value!

value: string
	documentPresenter value: string! !
!JadeiteMethodSourcePresenter categoriesFor: #createSchematicWiring!create schemantic wiring!private! !
!JadeiteMethodSourcePresenter categoriesFor: #editMenuStrings!menu handlers!private! !
!JadeiteMethodSourcePresenter categoriesFor: #editRevert!edit!private! !
!JadeiteMethodSourcePresenter categoriesFor: #editSaveMethod!menu handlers!public! !
!JadeiteMethodSourcePresenter categoriesFor: #fileSave!menu handlers!public! !
!JadeiteMethodSourcePresenter categoriesFor: #methodListSelection!accessing!public! !
!JadeiteMethodSourcePresenter categoriesFor: #methodService!accessing!private! !
!JadeiteMethodSourcePresenter categoriesFor: #methodService:!accessing!private! !
!JadeiteMethodSourcePresenter categoriesFor: #methodSourceEqual!public!testing! !
!JadeiteMethodSourcePresenter categoriesFor: #methodValueChanged!event handlers!public! !
!JadeiteMethodSourcePresenter categoriesFor: #onViewClosed!event handlers!public! !
!JadeiteMethodSourcePresenter categoriesFor: #onViewOpened!event handlers!public! !
!JadeiteMethodSourcePresenter categoriesFor: #reformatSource!menu handlers!private! !
!JadeiteMethodSourcePresenter categoriesFor: #registerPresentersForUpdates!public!register presenters! !
!JadeiteMethodSourcePresenter categoriesFor: #resetSourcePane!public! !
!JadeiteMethodSourcePresenter categoriesFor: #statusBarText:!public! !
!JadeiteMethodSourcePresenter categoriesFor: #update!public!updating! !
!JadeiteMethodSourcePresenter categoriesFor: #updateMethodSource!public!updating! !
!JadeiteMethodSourcePresenter categoriesFor: #updateMethodSourceColor!public!updating! !
!JadeiteMethodSourcePresenter categoriesFor: #value!public! !
!JadeiteMethodSourcePresenter categoriesFor: #value:!public! !

!JadeiteMethodSourcePresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil nil 5 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 416 34 2 8 1445007428 1025 544 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 327686 ##(Smalltalk.Color) #default nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 23 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #undo 8 '&Undo' 9397 1 nil nil nil 754 1 786 #redo 8 'R&edo' 9395 1 nil nil nil 754 1 786 #editRevert 8 'Revert' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 754 1 786 #editCut 8 'Cu&t' 9393 1 nil nil nil 754 1 786 #editCopy 8 '&Copy' 9351 1 nil nil nil 754 1 786 #editPaste 8 '&Paste' 9389 1 nil nil nil 754 1 786 #editDelete 8 'De&lete' 1629 1 nil nil nil 754 1 786 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 930 4097 754 1 786 #editFind 8 '&Find...' 9357 1 nil nil nil 754 1 786 #editFindNext 8 'Find &Next' 9359 1 nil nil nil 754 1 786 #editReplace 8 '&Replace...' 9361 1 nil nil nil 930 4097 754 1 786 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 754 1 786 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 754 1 786 #jadeExecute 8 'Execute' 9355 1 nil nil nil 754 1 786 #jadeDebug 8 'De&bug' 9349 1 nil nil nil 930 4097 754 1 786 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 754 1 786 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 930 4097 754 1 786 #fileIn 8 'File In' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 328198 ##(Smalltalk.Point) 193 193 nil 544 nil 8 1608896959 852486 ##(Smalltalk.NullConverter) nil nil 13 nil 170 192 34 4 #normal 1182790 1 ##(Smalltalk.ScintillaTextStyle) 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 1954 77 674 #gray 674 #white 1 nil nil nil nil #callTip nil nil nil 34 256 1968 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1984 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 8 #() 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 544 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 2096 nil 170 176 2096 9215 nil nil nil nil 674 #silver nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 4 #normal 1968 #callTip 1984 nil nil nil nil 1 nil 170 192 34 12 1 1510470 3 ##(Smalltalk.ScintillaIndicatorStyle) 1 544 196934 1 ##(Smalltalk.RGB) 65025 3 false 1 nil nil nil nil nil nil 8 'indicator8' 2418 17 544 2208 1 nil nil nil nil nil nil nil nil 3 2418 3 544 674 #blue 5 false 3 nil nil nil nil nil nil 8 'indicator10' 2418 21 544 674 #red 3 nil nil nil nil nil nil nil nil 8 'indicator9' 2418 19 544 2576 13 nil nil nil nil nil nil nil nil 5 2418 5 544 2576 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 1954 1027 2450 60239 2450 31326207 1 nil nil nil nil #Warning nil nil nil #Error 1954 1031 2450 335 2450 31317503 1 nil nil nil nil #Error nil nil nil #Notification 1954 1029 nil 2450 31185883 1 nil nil nil nil #Notification nil nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 11 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 1842 1 51 1842 1001 551 544 2866 #contextMenu: 34 1 720 544 2866 #textLimit: 8 #(1073741823) 544 2866 #hoverTime: 8 #(200) 544 2866 #caretPeriod: 8 #(530) 544 2866 #wordWrap: 8 #(true) 544 2866 #margins: 34 1 34 3 985158 3 ##(Smalltalk.ScintillaMargin) 1 544 61 3 nil nil nil nil 3154 3 544 1 nil 3 67108863 nil nil 3154 5 544 1 nil 3 -67108863 nil nil 544 2866 #canHScroll: 8 #(false) 544 2866 #tabWidth: 8 #(4) 544 2866 #maxCompletionListHeight: 8 #(9) 544 2866 #edgeColumn: 8 #(1) 544 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 244 1 0 0 44 1 0 0] 8 #() 1842 193 193 nil 29 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 3458 #fixedParentRight 1 3458 #fixedPreviousBottom 1 3458 #fixedParentBottom 1 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1140851500 131137 3536 nil 688 nil 517 nil 1762 nil true 1794 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 1842 193 193 nil 3536 688 8 1650109728 170 192 2096 170 192 34 24 13437 1246790 1 ##(Smalltalk.ToolbarSystemButton) 3536 1 786 #editFind 8 'Find' 1 1 nil 13437 1 25 13421 1246790 1 ##(Smalltalk.ToolbarBitmapButton) 3536 1 786 #jadeInspect 8 'Inspect' 9379 1 nil 13421 395334 3 ##(Smalltalk.Bitmap) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'Tools.bmp' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil nil 7 1842 1857 33 59 13431 3730 3536 1 786 #editDelete 8 'Delete' 1 1 nil 13431 1 11 13425 3730 3536 1 786 #editCut 8 'Cut' 1 1 nil 13425 1 1 13435 3730 3536 1 786 #redo 8 'Redo' 1 1 nil 13435 1 9 13419 3794 3536 1 786 #jadeExecute 8 'Execute' 9355 1 nil 13419 3872 57 13429 3730 3536 1 786 #editPaste 8 'Paste' 1 1 nil 13429 1 5 13439 3730 3536 1 786 #editReplace 8 'Replace' 1 1 nil 13439 1 27 13423 3730 3536 1 786 #editSaveMethod 8 'Save' 9383 1 nil 13423 1 17 13433 3730 3536 1 786 #undo 8 'Undo' 1 1 nil 13433 1 7 13417 3794 3536 1 786 #jadeDisplay 8 'Display' 9353 1 nil 13417 3872 55 13427 3730 3536 1 786 #copySelection 8 'Copy' 1 1 nil 13427 1 3 34 15 4384 4144 3808 1049158 1 ##(Smalltalk.ToolbarSeparator) 3536 1 4288 4498 3536 1 4048 4432 4192 4000 4336 4096 4498 3536 1 3744 4240 nil nil 1 nil 1842 33 33 1842 45 45 nil nil 2802 138 144 34 2 2866 #createAt:extent: 34 2 1842 1 1 1842 1001 51 3536 2866 #updateSizePosted 2096 3536 3346 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 244 1 0 0 25 0 0 0] 8 #() 3408 nil 27 3426 3472 1 3488 1 3458 #fixedParentTop 1 3458 #fixedViewTop 51 170 192 34 2 544 8 'document' nil 2802 138 144 34 1 2866 #createAt:extent: 34 2 1842 2879 21 1842 1001 601 416 3346 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 159 5 0 0 10 0 0 0 147 7 0 0 54 1 0 0] 34 2 3536 544 3408 nil 27 )! !
!JadeiteMethodSourcePresenter class categoriesFor: #resource_Default_view!public!resources-views! !

