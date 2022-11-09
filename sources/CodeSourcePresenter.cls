"Filed out from Dolphin Smallalk"!

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
	^self browseImplementorsOf: self currentSelection!

browseSenders
	^self browseSendersOf: self currentSelection!

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

createSchematicWiring
	super createSchematicWiring.
	documentPresenter
		when: #aboutToDisplayMenu:
			send: #methodMenu:
			to: self;
		when: #leftButtonDoubleClicked:
			send: #methodDoubleClicked:
			to: self!

currentSelectionOrLine

	| range |
	documentPresenter hasSelection ifFalse: [documentPresenter view selectCurrentLine].
	range := documentPresenter view selectionRange.
	^(documentPresenter value copyFrom: range start to: range stop) replaceCrLfWithLf.
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

editRevert
	self isOkayToChange ifTrue: [self parentPresenter editRevert]!

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

isOkayToChange
	documentPresenter view isModified
		ifTrue: [(JadePresenter unsavedChangesValidSessionDialogIn: documentPresenter) ifTrue: [^false]].
	documentPresenter view isModified: false.
	^true!

jadeDisplay
	self jadeExecuteAndDisplay: true shouldDebug: false!

jadeExecute
	self jadeExecuteAndDisplay: false shouldDebug: false!

jadeExecuteAndDisplay: showResult shouldDebug: shouldDebug
	| result |
	result := self executeSelectionOrLine: self parentPresenter contextObject shouldDebug: shouldDebug.
	result ifNil: [^self].
	result key
		ifTrue: 
			[showResult ifTrue: [self showResult: result value] ifFalse: [self setCaretToEndOfSelection].
			^result value]
		ifFalse: 
			[self showCompileError: result value first.
			^self	"flag for compile error"]!

menuTitle: aString

	menuTitle := aString.
!

methodDoubleClicked: anObject

	| range string |
	range := documentPresenter view selectionRange.
	string := documentPresenter value.
	string size = range stop ifTrue: [^self].
	(string at: range stop + 1) = $: ifFalse: [^self].
	range stop: range stop + 1.
	documentPresenter view selectionRange: range.
!

methodMenu: aMenu
	self methodMenuBreak: aMenu!

mySave
!

pasteClipboard
	^self editPaste!

queryCommand: query
	(#(#fileSave #editSaveMethod) includes: query commandSymbol)
		ifTrue: 
			[query isEnabled: documentPresenter view isModified.
			^true].
	(#(#cutSelection #copySelection) includes: query commandSymbol)
		ifTrue: 
			[query isEnabled: documentPresenter hasSelection.
			^true].
	query commandSymbol = #pasteClipboard
		ifTrue: 
			[query isEnabled: documentPresenter view canPaste.
			^true].
	query commandSymbol == #browseSelectedClass
		ifTrue: 
			[query isEnabled: self isClassSelectedInEditor.
			^true].
	(#(#undo #editRevert) includes: query commandSymbol)
		ifTrue: 
			[query isEnabled: ((View focus isKindOf: TextEdit) and: [View focus canUndo]). 
			^true].
	(#(#redo) includes: query commandSymbol)
		ifTrue: 
			[ query isEnabled: ((View focus isKindOf: TextEdit) and: [ View focus canRedo]).
			^true].
	^super queryCommand: query!

redo
	documentPresenter view redo!

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

selectedClassName
	"assume the selection is the class name" 
	^documentPresenter selection
	!

selection
	^documentPresenter selection
	!

selectionChanging: aSelectionChangingEvent 

	(documentPresenter view isKindOf: DeafObject) ifTrue: [^self].
	documentPresenter view isModified ifFalse: [^self].
	documentPresenter view ensureVisible.
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
!CodeSourcePresenter categoriesForMethods!
addMenu!menus!public! !
addMenuTo:!menus!public! !
addQuotesToSelection!edit!private! !
browseImplementors!public! !
browseSenders!public! !
clearBreakAtStepPoint:!Breakpoints!public! !
clearSelection!public! !
codeFont:!public! !
codePresenterIsMethod!public! !
copySelection!edit!private! !
createSchematicWiring!Jade!private! !
currentSelectionOrLine!Jade!private! !
cutSelection!public! !
documentPresenter!public! !
editCut!edit!private! !
editDelete!edit!private! !
editFind!edit!private! !
editFindNext!edit!private! !
editPaste!edit!private! !
editReplace!edit!private! !
editRevert!edit!private! !
editSelectAll!edit!private! !
environment:!public! !
fileSave!private! !
findClassList!public! !
handleInvalidSession!public! !
initialize!public! !
isClassSelectedInEditor!public! !
isModified!public! !
isOkayToChange!public!testing! !
jadeDisplay!Jade!private! !
jadeExecute!Jade!private! !
jadeExecuteAndDisplay:shouldDebug:!Jade!private! !
menuTitle:!menus!public! !
methodDoubleClicked:!Jade!private! !
methodMenu:!menus!private! !
mySave!private! !
pasteClipboard!public! !
queryCommand:!public! !
redo!edit!private! !
removeMenu!menus!public! !
removeQuotesFromSelection!edit!private! !
selectAll!public! !
selectedClassName!public! !
selection!public! !
selectionChanging:!public! !
selectLfIfEndingOnCr!edit!private! !
setBreakAtStepPoint:!Breakpoints!public! !
setBreakAtStepPoint:session:!public! !
setCaretToEndOfSelection!Jade!private! !
setDocumentPresenterWith:!public! !
setFont!private! !
showCompileError:!Jade!private! !
showSelection!edit!private! !
subMenuName!menus!public! !
subMenuPresenter!menus!public! !
textStyles!public! !
undo!edit!private! !
update!public! !
updateCodeFont!public! !
!

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
! !
!CodeSourcePresenter class categoriesForMethods!
codeFont!public! !
codeFont:!public! !
!

