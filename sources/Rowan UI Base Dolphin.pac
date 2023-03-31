| package |
package := Package name: 'Rowan UI Base Dolphin'.
package paxVersion: 1;
	basicComment: ''.


package methodNames
	add: #GciSession -> #library:;
	add: #GciSession -> #titleBarFor:;
	add: #JadeTextDocument -> #createComponents;
	add: #JadeTextDocument -> #executeSelectionOrLine:shouldDebug:;
	add: #JadeTextDocument -> #onViewOpened;
	add: #JadeTextDocument -> #queryCommand:;
	add: #JadeTextDocument -> #validateUserInterface;
	add: 'JadePresenter class' -> #waitForAnswer:;
	add: 'JadeTextDocument class' -> #showOnSession:;
	yourself.

package binaryGlobalNames: (Set new
	yourself).

package globalAliases: (Set new
	yourself).

package setPrerequisites: #(
	'..\Core\Object Arts\Dolphin\Base\Dolphin'
	'..\Core\Object Arts\Dolphin\MVP\Base\Dolphin MVP Base'
	'..\Core\Object Arts\Dolphin\MVP\Views\Scintilla\Dolphin Scintilla View'
	'..\Core\Object Arts\Dolphin\MVP\Presenters\Text\Dolphin Text Presenter'
	'GemStone C Interface'
	'GemStone Session'
	'Jade UI Base'
	'Rowan Client Services 2').

package!

"Class Definitions"!


"Global Aliases"!


"Loose Methods"!

!GciSession methodsFor!

library: anObject
	library := anObject!

titleBarFor: windowName
	| stream |
	self computeStoneHost.
	stream := WriteStream on: String new.
	stream
		nextPutAll: windowName;
		nextPutAll: ' for ';
		nextPutAll: userID asString;
		nextPutAll: ' on ';
		nextPutAll: stoneName asString;
		nextPutAll: ' [';
		print: gciSessionId;
		nextPutAll: ']'.
	self isRemoteGem
		ifTrue: 
			[self computeGemHost.
			stream
				nextPutAll: ' with remote gem on ';
				nextPutAll: gemHost asString]
		ifFalse: [stream nextPutAll: ' with linked gem'].
	^stream contents! !
!GciSession categoriesForMethods!
library:!accessing!private! !
titleBarFor:!public!title bar! !
!

!JadePresenter class methodsFor!

waitForAnswer: thingThatCanAnswer
	| theAnswer deferredValue thisProcess |
	deferredValue := [thingThatCanAnswer answer] deferredValue.
	thisProcess := Processor activeProcess.
	
	[
	[[deferredValue hasValue not and: [thingThatCanAnswer isDeafObject not]]
		whileTrue: [(Delay forMilliseconds: 1) wait]]
			ensure: 
				[SessionManager current inputState main: Processor activeProcess.
				thingThatCanAnswer isDeafObject
					ifTrue: [thisProcess terminate]
					ifFalse: [[thisProcess resume: nil] on: Error do: [:ex | ]]]]
			fork.
	Processor suspendActive.
	theAnswer := [deferredValue value] on: Error
				do: 
					[:ex |
					ex messageText = 'DeferredValue terminated prematurely'
						ifTrue: [nil]
						ifFalse: 
							[thingThatCanAnswer
								getProcessList;
								update.	"should be a debugger so update"
							self waitForAnswer: thingThatCanAnswer]].
	^theAnswer! !
!JadePresenter class categoriesForMethods!
waitForAnswer:!debugger support!public! !
!

!JadeTextDocument methodsFor!

createComponents

	super createComponents.
	view viewNamed: 'codePane' ifNone: [^self].
	codePane := self add: self codeSourcePresenterClass new name: 'codePane'.
	documentPresenter := codePane documentPresenter.
	self updateCodeFont.
!

executeSelectionOrLine: contextObject shouldDebug: aBoolean
	| answeringService answer oop |
	oop := (contextObject isKindOf: ExternalInteger)
				ifTrue: [contextObject value]
				ifFalse: [contextObject].	"services wants a local special as a context"
	oop ifNil: [oop := 20].
	answeringService := RowanAnsweringService new.
	answeringService
		command: #exec:context:;
		commandArgs: (Array with: self currentSelectionOrLine with: oop).
	self issueCommand: answeringService.
	answer := self waitForAnswer: answeringService.
	answer key ifTrue: [answer value: (OopType64 fromInteger: answer value)].
	^answer!

onViewOpened
	codePane ifNotNil: [codePane gciSession: gciSession].
	super onViewOpened.
	self updateStatusBar.
	(documentPresenter view isKindOf: ScintillaView) ifFalse: [^self].
	documentPresenter view
		restyleAll;
		backcolor: (RGB
					red: 250
					green: 242
					blue: 208);
		yourself.
	self updateCodeFont.
	self positionToDefaultLocation!

queryCommand: query
	| textEdit focusView isTextEdit |
	textEdit := self activeTextEdit.
	focusView := View focus.
	isTextEdit := focusView isKindOf: TextEdit.
	(#(#addQuotesToSelection #removeQuotesFromSelection #editCut #editCopy #editDelete #editReplace #editFind #editFindNext #editSelectAll #jadeDebug #jadeDisplay #jadeExecute #jadeInspect)
		includes: query commandSymbol)
			ifTrue: 
				[query isEnabled: (textEdit notNil and: [textEdit isKindOf: TextEdit]).
				^true].
	query commandSymbol = #editPaste
		ifTrue: 
			[query isEnabled: (textEdit notNil and: [(textEdit isKindOf: TextEdit) and: [textEdit canPaste]]).
			^true].
	(#(#editUndo #editRevert) includes: query commandSymbol)
		ifTrue: 
			[query isEnabled: (isTextEdit and: [focusView canUndo]). 
			^true].
	(#( #editRedo ) includes: query commandSymbol)
		ifTrue: 
			[query isEnabled: (isTextEdit and: [focusView canRedo]).
			^true].
	^super queryCommand: query!

validateUserInterface

	[
		super validateUserInterface.
	] on: Error do: [:ex | 
		view == DeafObject current ifTrue: [ex return: nil].
		ex pass.
	].! !
!JadeTextDocument categoriesForMethods!
createComponents!private! !
executeSelectionOrLine:shouldDebug:!Jade!private! !
onViewOpened!event handlers!private! !
queryCommand:!menu handlers!private! !
validateUserInterface!overrides!private! !
!

!JadeTextDocument class methodsFor!

showOnSession: aGciSession
	^self new 
		gciSession: aGciSession;
		createView: self defaultView;
		showShell;
		yourself.

! !
!JadeTextDocument class categoriesForMethods!
showOnSession:!public! !
!

"End of package definition"!

"Source Globals"!

"Classes"!

"Binary Globals"!

