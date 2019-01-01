"Filed out from Dolphin Smalltalk 7"!

JadePresenterA subclass: #CodeSourcePresenter
	instanceVariableNames: 'documentPresenter menuTitle environment'
	classVariableNames: 'CodeFont'
	poolDictionaries: ''
	classInstanceVariableNames: ''!
CodeSourcePresenter guid: (GUID fromString: '{549a5009-cdd1-42b3-8907-c3c5c1c9e532}')!
CodeSourcePresenter comment: 'model - the context in which code can be executed'!
!CodeSourcePresenter categoriesForClass!Unclassified! !
!CodeSourcePresenter methodsFor!

addMenu

	| menuBar |
	menuBar := self view topShell view menuBar.
	self updateMenuBar: menuBar.
	self view topShell view menuBar: menuBar.
!

addMenuTo: aMenuBar

	self updateMenuBar: aMenuBar.
!

addQuotesToSelection

	documentPresenter view replaceSelection: documentPresenter selection printString.
!

browseImplementors

	^self browseImplementorsOf: self currentSelector.!

browseSenders

	^self browseSendersOf: self currentSelector.!

clearBreakAtStepPoint: anInteger

	| method |
	(method := self trigger: #'needMethod') isNil ifTrue: [^self].
	method clearBreakAtStepPoint: anInteger session: gciSession.
!

clearSelection
	^self editDelete!

codeFont: aFont

	documentPresenter view font: aFont.
!

codePresenterIsMethod

	^false!

copySelection

	documentPresenter view
		copySelection;
		updateModel;
		yourself.
!

currentSelectionOrLine

	| range |
	documentPresenter hasSelection ifFalse: [documentPresenter view selectCurrentLine].
	range := documentPresenter view selectionRange.
	^(documentPresenter value copyFrom: range start to: range stop) replaceCrLfWithLf.
!

currentSelector

	| selection |
	selection := documentPresenter view selection.
	^[
		(SmalltalkParser parseMethod: selection) selector.
	] on: Error do: [:ex | 
		selection.
	]
!

cutSelection
	^self editCut!

documentPresenter

	^documentPresenter!

editCut

	documentPresenter view
		cutSelection;
		updateModel;
		yourself.
!

editDelete

	self selectLfIfEndingOnCr.
	documentPresenter view
		clearSelection;
		updateModel;
		yourself.
!

editFind

	documentPresenter view editFind.
	self showSelection.
!

editFindNext

	documentPresenter view findNext.
	self showSelection.

!

editPaste

	documentPresenter view
		pasteClipboard;
		updateModel;
		yourself.
!

editReplace

	documentPresenter view
		findReplace;
		updateModel;
		yourself.
!

editSelectAll

	documentPresenter view selectAll.
!

environment: anInteger

	environment := anInteger.
!

fileSave
		"Private - Answer whether the save succeeded (false means to stay on the window and cancel any attempt to leave)"

	^parentPresenter fileSave!

findClassList
"
	Array with: className with: dictionaryName with: catetory with: packageName.
"
	| string list |
	string := self gciSession 
		serverPerform: #'systemBrowser:' 
		with: '0 findClass'.
	list := (string subStrings: Character lf) collect: [:each | each subStrings: Character tab].
	list := list copyFrom: 2 to: list size.
	list := list collect: [:each | each size < 3 ifTrue: [each , #('' '' '')] ifFalse: [each]].
	list := list collect: [:each | (each at: 1) -> each].
	^list
!

handleInvalidSession

	documentPresenter view isModified ifFalse: [^false].
	self ensureVisible.
	documentPresenter ensureVisible.
	documentPresenter view isModified: false.
	(MessageBox confirm: 'Copy unsaved method to clipboard?' caption: 'Invalid Session!!') ifTrue: [
		documentPresenter view selectAll; copySelection.
	].
	^true
!

initialize

	super initialize.
	environment := 0.
!

isClassSelectedInEditor

	| range string |
	(range := documentPresenter view selectionRange) isEmpty ifTrue: [^false].
	string := documentPresenter value copyFrom: range start to: range stop.
	^(string allSatisfy: [:each | each isAlphaNumeric]) and: [string first isLetter and: [string first isUppercase]]
!

isModified

	^documentPresenter isModified!

jadeDebug

	[
		gciSession debugString: self currentSelectionOrLine fromContext: model environment: environment.
	] on: GsCompileError do: [:ex | 
		self jadeExecute.
	].
!

jadeDisplay

	self jadeExecuteAndDisplay: true.
!

jadeExecute

	self jadeExecuteAndDisplay: false.
!

jadeExecuteAndDisplay: showResult 

	| result |
	result := self executeSelectionOrLine.
	result key ifTrue: [
		showResult ifTrue: [
			self showResult: result value.
		] ifFalse: [
			self setCaretToEndOfSelection.
		].
		^result value.
	] ifFalse: [
		self showCompileError: result value first.
		^self		"flag for compile error"
	].
!

menuTitle: aString

	menuTitle := aString.
!

mySave
!

pasteClipboard
	^self editPaste!

queryCommand: query
	(#(#'fileSave' #editSaveMethod) includes: query commandSymbol) ifTrue: [
		query isEnabled: documentPresenter view isModified.
		^true.
	].
	(#(#cutSelection #copySelection) includes: query commandSymbol) ifTrue: [
		query isEnabled: documentPresenter hasSelection.
		^true.
	].
	(query commandSymbol = #pasteClipboard) ifTrue: [
		query isEnabled: documentPresenter view canPaste.
		^true.
	].
	(query commandSymbol == #'browseSelectedClass') ifTrue: [
		query isEnabled: self isClassSelectedInEditor.
		^true
	].
	^super queryCommand: query.
!

removeMenu

	| menuBar item |
	(menuBar := self view topShell view menuBar) isNil ifTrue: [^self].
	item := menuBar items 
		detect: [:each | each text = self subMenuName]
		ifNone: [^self].
	menuBar removeItem: item.
	self view topShell view menuBar: menuBar.
!

removeQuotesFromSelection

	| string |
	string := documentPresenter view selection trimBlanks.
	(string size >= 2 and: [string first = $' and: [string last = $']]) ifFalse: [
		^MessageBox notify: 'Selection must begin and end with quote'.
	].
	string := string copyFrom: 2 to: string size - 1.
	string := string 
		copyReplaceAll: ''''''
		with: ''''.
	documentPresenter view replaceSelection: string.
!

selectAll
	^self editSelectAll!

selectionChanging: aSelectionChangingEvent 

	(documentPresenter view isKindOf: DeafObject) ifTrue: [^self].
	documentPresenter view isModified ifFalse: [^self].
	documentPresenter view ensureVisible.
	self halt. 
	MessageBox 
		confirm: 'Save changes?' 
		onYes: 			[aSelectionChangingEvent value: self fileSave] 
		onNo: 			[documentPresenter view isModified: false] 
		onCancel: 	[aSelectionChangingEvent value: false].
!

selectLfIfEndingOnCr
	"deleting a CR without the subsequent LF can leave things somewhat confused"

	| text selectionRange |
	selectionRange := documentPresenter view selectionRange.
	text := documentPresenter view "hide; show;" value.			"somehow the value gets out of synch"
	selectionRange stop < selectionRange start 			ifFalse: [^self ].
	selectionRange start < documentPresenter view value size 	ifFalse: [^self ].
	(text at: selectionRange start) = Character cr 			ifFalse: [^self ].
	(text at: selectionRange start + 1) = Character lf 		ifFalse: [^self ].
	documentPresenter view selectionRange: (selectionRange start to: selectionRange start + 1).
!

setBreakAtStepPoint: anInteger

	| method |
	(method := self trigger: #'needMethod') isNil ifTrue: [^self].
	method setBreakAtStepPoint: anInteger.
	self trigger: #'breaksChanged'.
!

setBreakAtStepPoint: anInteger session: aGciSession

	| method |
	(method := self trigger: #'needMethod') isNil ifTrue: [^self].
	method setBreakAtStepPoint: anInteger session: gciSession.
	self trigger: #'breaksChanged'.
!

setCaretToEndOfSelection

	| textView |
	textView := documentPresenter view.
	textView caretPosition: textView selectionRange stop + 1.
!

setDocumentPresenterWith: aJadeGsClassShape

	documentPresenter lastGsShape: aJadeGsClassShape!

setFont

	| font |
	font := CodeFont notNil
		ifTrue: [FontDialog showModalOn: CodeFont]
		ifFalse: [FontDialog showModal].
	font notNil ifTrue: [
		self class codeFont: font.
	]
!

showCompileError: anArray

	| result string count textView selectionRange offset |
	textView := documentPresenter view.
	offset := anArray at: 2.
	result := anArray at: 3.
	selectionRange := textView selectionRange.
	string := textView value.
	string := string copyFrom: selectionRange start to: selectionRange stop.
	string := string replaceCrLfWithLf copyFrom: 1 to: offset - 1.
	count := (string select: [:each | each = Character lf]) size.
	offset := offset + count.
	textView
		caretPosition: selectionRange start + offset - 1;
		replaceSelection: result;
		selectionStart: textView caretPosition - result size length: result size.
!

showResult: anObject

	| result textView |
	(gciSession isOopType: anObject) ifFalse: [
		result := ' ' , anObject printString.
	] ifTrue: [
		result := ' ' , (gciSession printString: anObject).
	].
	"result := result replaceLfWithCrLf."
	self setCaretToEndOfSelection.
	(textView := documentPresenter view)
		replaceSelection: result;
		selectionStart: textView caretPosition - result size length: result size.
!

showSelection

	| range lineNumber |
	(range := documentPresenter view selectionRange) isEmpty ifTrue: [^self].
	lineNumber := documentPresenter view lineFromPosition: range first.
	lineNumber := lineNumber - 4 max: 1.
	documentPresenter view lineScroll: lineNumber.
!

subMenuName

	^menuTitle.
!

subMenuPresenter

	^documentPresenter.
!

textStyles

	^documentPresenter view editStyles textStyles!

undo

	documentPresenter view undo!

update

	self subclassResponsibility.
!

updateCodeFont

	CodeFont notNil ifTrue: [
		documentPresenter view font: CodeFont.
	].
! !
!CodeSourcePresenter categoriesFor: #addMenu!menus!public! !
!CodeSourcePresenter categoriesFor: #addMenuTo:!menus!public! !
!CodeSourcePresenter categoriesFor: #addQuotesToSelection!edit!private! !
!CodeSourcePresenter categoriesFor: #browseImplementors!public! !
!CodeSourcePresenter categoriesFor: #browseSenders!public! !
!CodeSourcePresenter categoriesFor: #clearBreakAtStepPoint:!Breakpoints!public! !
!CodeSourcePresenter categoriesFor: #clearSelection!public! !
!CodeSourcePresenter categoriesFor: #codeFont:!public! !
!CodeSourcePresenter categoriesFor: #codePresenterIsMethod!public! !
!CodeSourcePresenter categoriesFor: #copySelection!edit!private! !
!CodeSourcePresenter categoriesFor: #currentSelectionOrLine!Jade!private! !
!CodeSourcePresenter categoriesFor: #currentSelector!public! !
!CodeSourcePresenter categoriesFor: #cutSelection!public! !
!CodeSourcePresenter categoriesFor: #documentPresenter!public! !
!CodeSourcePresenter categoriesFor: #editCut!edit!private! !
!CodeSourcePresenter categoriesFor: #editDelete!edit!private! !
!CodeSourcePresenter categoriesFor: #editFind!edit!private! !
!CodeSourcePresenter categoriesFor: #editFindNext!edit!private! !
!CodeSourcePresenter categoriesFor: #editPaste!edit!private! !
!CodeSourcePresenter categoriesFor: #editReplace!edit!private! !
!CodeSourcePresenter categoriesFor: #editSelectAll!edit!private! !
!CodeSourcePresenter categoriesFor: #environment:!public! !
!CodeSourcePresenter categoriesFor: #fileSave!private! !
!CodeSourcePresenter categoriesFor: #findClassList!public! !
!CodeSourcePresenter categoriesFor: #handleInvalidSession!public! !
!CodeSourcePresenter categoriesFor: #initialize!public! !
!CodeSourcePresenter categoriesFor: #isClassSelectedInEditor!public! !
!CodeSourcePresenter categoriesFor: #isModified!public! !
!CodeSourcePresenter categoriesFor: #jadeDebug!Jade!private! !
!CodeSourcePresenter categoriesFor: #jadeDisplay!Jade!private! !
!CodeSourcePresenter categoriesFor: #jadeExecute!Jade!private! !
!CodeSourcePresenter categoriesFor: #jadeExecuteAndDisplay:!Jade!private! !
!CodeSourcePresenter categoriesFor: #menuTitle:!menus!public! !
!CodeSourcePresenter categoriesFor: #mySave!private! !
!CodeSourcePresenter categoriesFor: #pasteClipboard!public! !
!CodeSourcePresenter categoriesFor: #queryCommand:!public! !
!CodeSourcePresenter categoriesFor: #removeMenu!menus!public! !
!CodeSourcePresenter categoriesFor: #removeQuotesFromSelection!edit!private! !
!CodeSourcePresenter categoriesFor: #selectAll!public! !
!CodeSourcePresenter categoriesFor: #selectionChanging:!public! !
!CodeSourcePresenter categoriesFor: #selectLfIfEndingOnCr!edit!private! !
!CodeSourcePresenter categoriesFor: #setBreakAtStepPoint:!Breakpoints!public! !
!CodeSourcePresenter categoriesFor: #setBreakAtStepPoint:session:!public! !
!CodeSourcePresenter categoriesFor: #setCaretToEndOfSelection!Jade!private! !
!CodeSourcePresenter categoriesFor: #setDocumentPresenterWith:!public! !
!CodeSourcePresenter categoriesFor: #setFont!private! !
!CodeSourcePresenter categoriesFor: #showCompileError:!Jade!private! !
!CodeSourcePresenter categoriesFor: #showResult:!Jade!private! !
!CodeSourcePresenter categoriesFor: #showSelection!edit!private! !
!CodeSourcePresenter categoriesFor: #subMenuName!menus!public! !
!CodeSourcePresenter categoriesFor: #subMenuPresenter!menus!public! !
!CodeSourcePresenter categoriesFor: #textStyles!public! !
!CodeSourcePresenter categoriesFor: #undo!Jade!private! !
!CodeSourcePresenter categoriesFor: #update!public! !
!CodeSourcePresenter categoriesFor: #updateCodeFont!public! !

!CodeSourcePresenter class methodsFor!

codeFont

	^CodeFont.
!

codeFont: aFont

	CodeFont := aFont.
	self withAllSubclassesDo: [:eachClass | 
		eachClass allInstances do: [:each | 
			each codeFont: aFont.
		].
	].
	JadeTextDocument withAllSubclassesDo: [:eachClass | 
		eachClass allInstances do: [:each | 
			each updateCodeFont.
		].
	].
!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil nil 5 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1140851500 131137 544 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 nil 517 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 328198 ##(Smalltalk.Point) 193 193 nil 544 610 640 8 4294909993 170 192 8 #() 170 192 34 24 40435 1246982 ##(Smalltalk.ToolbarSystemButton) 40435 nil 544 1 1180998 4 ##(Smalltalk.CommandDescription) #editReplace 8 'Replace' 1 1 nil 1 27 40413 853766 ##(Smalltalk.ToolbarButton) 40413 nil 544 1 898 #jadeDisplay 8 'Display' 1 1 nil 395334 3 ##(Smalltalk.Bitmap) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'Tools.bmp' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil nil 7 738 1857 33 55 40415 946 40415 nil 544 1 898 #jadeExecute 8 'Execute' 1 1 nil 1024 57 40417 946 40417 nil 544 1 898 #jadeInspect 8 'Inspect' 1 1 nil 1024 59 40419 866 40419 nil 544 1 898 #fileSave 8 'Save' 1 1 nil 1 17 40421 866 40421 nil 544 1 898 #editCut 8 'Cut' 1 1 nil 1 1 40423 866 40423 nil 544 1 898 #copySelection 8 'Copy' 1 1 nil 1 3 40425 866 40425 nil 544 1 898 #editPaste 8 'Paste' 1 1 nil 1 5 40427 866 40427 nil 544 1 898 #editDelete 8 'Delete' 1 1 nil 1 11 40429 866 40429 nil 544 1 898 #undo 8 'Undo' 1 1 nil 1 7 40431 866 40431 nil 544 1 898 #redo 8 'Redo' 1 1 nil 1 9 40433 866 40433 nil 544 1 898 #editFind 8 'Find' 1 1 nil 1 25 34 15 960 1152 1200 1050118 ##(Smalltalk.ToolbarSeparator) nil nil 544 3 nil 1 1248 1650 nil nil 544 3 nil 1 1296 1344 1392 1440 1488 1536 1650 nil nil 544 3 nil 1 1584 880 170 176 34 4 1 117 1024 1 nil 1 nil 738 33 33 738 45 45 nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 738 1 1 738 1001 51 544 1842 #updateSizePosted 816 544 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 244 1 0 0 25 0 0 0] 8 #() 738 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 2050 #fixedParentRight 1 2050 #fixedParentTop 1 2050 #fixedViewTop 51 410 ##(Smalltalk.ScintillaView) 34 50 nil 416 34 2 8 1445007428 1025 2128 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 610 8 4278190080 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 27 984134 2 ##(Smalltalk.CommandMenuItem) 1 898 #fileSave 8 '&Save' 9383 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 2338 1 898 #undo 8 '&Undo' 9397 1 nil nil nil 2338 1 898 #redo 8 'R&edo' 9395 1 nil nil nil 2402 4097 2338 1 898 #editCut 8 'Cu&t' 9393 1 nil nil nil 2338 1 898 #editCopy 8 '&Copy' 9351 1 nil nil nil 2338 1 898 #editPaste 8 '&Paste' 9389 1 nil nil nil 2338 1 898 #editDelete 8 'De&lete' 1629 1 nil nil nil 2338 1 898 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 2402 4097 2338 1 898 #editFind 8 '&Find...' 9357 1 nil nil nil 2338 1 898 #editFindNext 8 'Find &Next' 9359 1 nil nil nil 2338 1 898 #editReplace 8 '&Replace...' 9361 1 nil nil nil 2402 4097 2338 1 898 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 2338 1 898 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 2338 1 898 #jadeExecute 8 'Execute' 9355 1 nil nil nil 2338 1 898 #jadeDebug 8 'De&bug' 9349 1 nil nil nil 2402 4097 2338 1 898 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 2338 1 898 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 2402 4097 2338 1 898 #browseImplementors 8 'Browse Implementors' 1 1 nil nil nil 2338 1 898 #browseSenders 8 'Browse Senders' 1 1 nil nil nil 2402 4097 2338 1 898 #fileIn 8 'File In' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil 658 nil true 690 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 738 193 193 nil 2128 nil 8 4294909157 852486 ##(Smalltalk.NullConverter) nil nil 9 nil 170 192 34 4 #callTip 1182790 1 ##(Smalltalk.ScintillaTextStyle) 77 786694 ##(Smalltalk.IndexedColor) 33554457 3634 33554471 1 nil nil nil nil #callTip nil nil nil #normal 3602 1 nil nil 1 nil nil nil nil #normal nil nil nil 34 256 3680 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3616 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 1639686 ##(Smalltalk.SmalltalkExpressionStyler) 1 nil nil false 138 144 816 170 192 34 2 #default 1641542 1 ##(Smalltalk.ScintillaMarkerDefinition) 1 nil nil nil 2128 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 816 nil 170 176 816 9215 nil nil nil nil 3634 33554447 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 3 170 192 34 2 #container 170 192 34 4 #callTip 3616 #normal 3680 nil nil nil nil 1 nil 170 192 34 12 1 1510470 2 ##(Smalltalk.ScintillaIndicatorStyle) 1 2128 65025 3 false 1 nil nil nil nil nil nil 3 4066 3 2128 33423361 5 false 3 nil nil nil nil nil nil 5 4066 5 2128 511 1 false 5 nil nil nil nil nil nil 8 'indicator8' 4066 17 2128 33554447 1 nil nil nil nil nil nil nil nil 8 'indicator10' 4066 21 2128 33554459 3 nil nil nil nil nil nil nil nil 8 'indicator9' 4066 19 2128 33554459 13 nil nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 3602 1029 nil 196934 1 ##(Smalltalk.RGB) 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 3602 1027 4274 60239 4274 31326207 1 nil nil nil nil #Warning nil nil nil #Error 3602 1031 4274 335 4274 31317503 1 nil nil nil nil #Error nil nil nil nil 1778 138 144 34 9 1842 #createAt:extent: 34 2 738 1 51 738 1001 551 2128 1842 #contextMenu: 34 1 2304 2128 1842 #modificationEventMask: 8 #(4607) 2128 1842 #hoverTime: 8 #(200) 2128 1842 #caretPeriod: 8 #(530) 2128 1842 #wordWrap: 8 #(true) 2128 1842 #margins: 34 1 34 3 985158 2 ##(Smalltalk.ScintillaMargin) 1 2128 61 3 nil nil nil nil 4722 3 2128 1 nil 3 67108863 nil nil 4722 5 2128 1 nil 3 -67108863 nil nil 2128 1842 #tabWidth: 8 #(4) 2128 1842 #maxCompletionListHeight: 8 #(9) 2128 1938 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 244 1 0 0 44 1 0 0] 8 #() 2000 nil 29 2018 2064 1 2080 1 2050 #fixedPreviousBottom 1 2050 #fixedParentBottom 1 170 192 34 2 2128 8 'document' nil 1778 138 144 34 1 1842 #createAt:extent: 34 2 738 7679 21 738 1001 601 416 1938 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 243 16 0 0 54 1 0 0] 34 2 544 2128 2000 nil 27 )! !
!CodeSourcePresenter class categoriesFor: #codeFont!public! !
!CodeSourcePresenter class categoriesFor: #codeFont:!public! !
!CodeSourcePresenter class categoriesFor: #resource_Default_view!public!resources-views! !

