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
		when: #valueChanged
		send: #methodValueChanged
		to: self.!

editMenuStrings
	false ifTrue: [
		self editSaveMethod; undo; redo; reformatSource; cutSelection; copySelection; pasteClipboard; clearSelection; selectAll; editFind; editFindNext; editReplace; 
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
!JadeiteMethodSourcePresenter categoriesFor: #statusBarText:!public! !
!JadeiteMethodSourcePresenter categoriesFor: #update!public!updating! !
!JadeiteMethodSourcePresenter categoriesFor: #updateMethodSource!public!updating! !
!JadeiteMethodSourcePresenter categoriesFor: #value!public! !
!JadeiteMethodSourcePresenter categoriesFor: #value:!public! !

!JadeiteMethodSourcePresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil nil 5 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1140851500 131137 544 nil 327686 ##(Smalltalk.Color) #default nil 517 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 328198 ##(Smalltalk.Point) 193 193 nil 544 624 8 1650109728 170 192 8 #() 170 192 34 24 43587 1246790 1 ##(Smalltalk.ToolbarSystemButton) 544 1 1180998 4 ##(Smalltalk.CommandDescription) #editCut 8 'Cut' 1 1 nil 43587 1 1 43597 834 544 1 866 #redo 8 'Redo' 1 1 nil 43597 1 9 43581 1246790 1 ##(Smalltalk.ToolbarBitmapButton) 544 1 866 #jadeExecute 8 'Execute' 9355 1 nil 43581 395334 3 ##(Smalltalk.Bitmap) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'Tools.bmp' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil nil 7 722 1857 33 57 43591 834 544 1 866 #editPaste 8 'Paste' 1 1 nil 43591 1 5 43601 834 544 1 866 #editReplace 8 'Replace' 1 1 nil 43601 1 27 43585 834 544 1 866 #editSaveMethod 8 'Save' 9383 1 nil 43585 1 17 43595 834 544 1 866 #undo 8 'Undo' 1 1 nil 43595 1 7 43579 962 544 1 866 #jadeDisplay 8 'Display' 9353 1 nil 43579 1040 55 43589 834 544 1 866 #copySelection 8 'Copy' 1 1 nil 43589 1 3 43599 834 544 1 866 #editFind 8 'Find' 1 1 nil 43599 1 25 43583 962 544 1 866 #jadeInspect 8 'Inspect' 9379 1 nil 43583 1040 59 43593 834 544 1 866 #editDelete 8 'Delete' 1 1 nil 43593 1 11 34 15 1360 976 1504 1049158 1 ##(Smalltalk.ToolbarSeparator) 544 1 1264 1618 544 1 848 1408 1168 1552 1312 912 1618 544 1 1456 1216 nil nil 1 nil 722 33 33 722 45 45 nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 722 1 1 722 1001 51 544 1778 #updateSizePosted 784 544 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 244 1 0 0 25 0 0 0] 8 #() 722 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 1986 #fixedParentRight 1 1986 #fixedParentTop 1 1986 #fixedViewTop 51 410 ##(Smalltalk.JadeiteScintillaView) 34 50 nil 416 34 2 8 1445007428 1025 2064 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 624 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 23 984134 2 ##(Smalltalk.CommandMenuItem) 1 866 #undo 8 '&Undo' 9397 1 nil nil nil 2242 1 866 #redo 8 'R&edo' 9395 1 nil nil nil 2242 1 866 #editRevert 8 'Revert' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 2242 1 866 #editCut 8 'Cu&t' 9393 1 nil nil nil 2242 1 866 #editCopy 8 '&Copy' 9351 1 nil nil nil 2242 1 866 #editPaste 8 '&Paste' 9389 1 nil nil nil 2242 1 866 #editDelete 8 'De&lete' 1629 1 nil nil nil 2242 1 866 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 2402 4097 2242 1 866 #editFind 8 '&Find...' 9357 1 nil nil nil 2242 1 866 #editFindNext 8 'Find &Next' 9359 1 nil nil nil 2242 1 866 #editReplace 8 '&Replace...' 9361 1 nil nil nil 2402 4097 2242 1 866 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 2242 1 866 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 2242 1 866 #jadeExecute 8 'Execute' 9355 1 nil nil nil 2242 1 866 #jadeDebug 8 'De&bug' 9349 1 nil nil nil 2402 4097 2242 1 866 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 2242 1 866 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 2402 4097 2242 1 866 #fileIn 8 'File In' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil 642 nil true 674 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 722 193 193 nil 2064 nil 8 1527370175 852486 ##(Smalltalk.NullConverter) nil nil 9 nil 170 192 34 4 #normal 1182790 1 ##(Smalltalk.ScintillaTextStyle) 1 nil nil 1 nil nil nil nil #normal nil nil nil #callTip 3378 77 610 #gray 610 #white 1 nil nil nil nil #callTip nil nil nil 34 256 3392 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3408 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 784 170 192 34 2 #default 1641542 2 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 2064 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 784 nil 170 176 784 9215 nil nil nil nil 610 #silver nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 4 #normal 3392 #callTip 3408 nil nil nil nil 1 nil 170 192 34 12 1 1510470 3 ##(Smalltalk.ScintillaIndicatorStyle) 1 2064 196934 1 ##(Smalltalk.RGB) 65025 3 false 1 nil nil nil nil nil nil 8 'indicator10' 3826 21 2064 610 #red 3 nil nil nil nil nil nil nil nil 8 'indicator9' 3826 19 2064 3920 13 nil nil nil nil nil nil nil nil 3 3826 3 2064 610 #blue 5 false 3 nil nil nil nil nil nil 8 'indicator8' 3826 17 2064 3616 1 nil nil nil nil nil nil nil nil 5 3826 5 2064 3920 1 false 5 nil nil nil nil nil nil nil nil 170 192 34 6 #Warning 3378 1027 3858 60239 3858 31326207 1 nil nil nil nil #Warning nil nil nil #Error 3378 1031 3858 335 3858 31317503 1 nil nil nil nil #Error nil nil nil #Notification 3378 1029 nil 3858 31185883 1 nil nil nil nil #Notification nil nil nil nil 1714 138 144 34 11 1778 #createAt:extent: 34 2 722 1 51 722 1001 551 2064 1778 #contextMenu: 34 1 2208 2064 1778 #textLimit: 8 #(1073741823) 2064 1778 #hoverTime: 8 #(200) 2064 1778 #caretPeriod: 8 #(530) 2064 1778 #wordWrap: 8 #(true) 2064 1778 #margins: 34 1 34 3 985158 3 ##(Smalltalk.ScintillaMargin) 1 2064 61 3 nil nil nil nil 4530 3 2064 1 nil 3 67108863 nil nil 4530 5 2064 1 nil 3 -67108863 nil nil 2064 1778 #canHScroll: 8 #(false) 2064 1778 #tabWidth: 8 #(4) 2064 1778 #maxCompletionListHeight: 8 #(9) 2064 1778 #edgeColumn: 8 #(1) 2064 1874 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 244 1 0 0 44 1 0 0] 8 #() 1936 nil 29 1954 2000 1 2016 1 1986 #fixedPreviousBottom 1 1986 #fixedParentBottom 1 170 192 34 2 2064 8 'document' nil 1714 138 144 34 1 1778 #createAt:extent: 34 2 722 7679 21 722 1001 601 416 1874 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 243 16 0 0 54 1 0 0] 34 2 544 2064 1936 nil 27 )! !
!JadeiteMethodSourcePresenter class categoriesFor: #resource_Default_view!public!resources-views! !

