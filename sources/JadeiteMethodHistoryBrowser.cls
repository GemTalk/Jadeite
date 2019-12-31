"Filed out from Dolphin Smalltalk 7"!

MethodHistoryBrowser subclass: #JadeiteMethodHistoryBrowser
	instanceVariableNames: 'session'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteMethodHistoryBrowser guid: (GUID fromString: '{a2b0e8a4-20d0-48d3-8b19-98dc5dd55a21}')!
JadeiteMethodHistoryBrowser comment: ''!
!JadeiteMethodHistoryBrowser categoriesForClass!IDB Goodies! !
!JadeiteMethodHistoryBrowser methodsFor!

about
	"Display the about view"
	self 
		about: '
Jadeite Method History Browser subclassed from original 
MethodHistoryBrowser built in Dolphin Smalltalk 6.x
Version 6b
© 2005 by Ian Bartholomew'!

applyOptions
	view maxCompletionListHeight: 10.
	view maxCompletionListWidth: 40.
	view autoCompletionSeparator: $\x7F.!

classService
	"we're repurposing class inst var"

	^class!

createComponents
	"avoid sending super. Dependencies fail in a runtime environment"

	slider := self add: NumberPresenter new name: 'slider'.
	source := self add: JadeiteSmalltalkWorkspace new name: 'source'.
	searchPresenter := self
				add: JadeiteSmalltalkSearchPresenter new
				name: 'search'
				helpId: 10510.

	"Font size adjust by slider (if supported by view)"
	fontSizePresenter := self add: NumberPresenter new name: 'fontSize'!

createSchematicWiring
	slider 
		when: #valueChanged
		send: #onSliderValueChanged
		to: self.!

diff
	| diffBrowser |
	diffBrowser := DiffBrowser create: 'Vertical view'.
	diffBrowser showShell.
	diffBrowser
		caption: class name , '>>' , self methodService selector;
		compare: ((history at: selection) at: 3)
			id: 'Version #' , selection printString
			and: ((history at: history size) at: 3)
			id: 'Current'!

methodService
	"we're repurposing selector inst var"

	^selector!

restoreMethod
	Cursor wait showWhile: 
			[self classService
				saveMethod: ((history at: selection) at: 3)
				category: self methodService category
				session: session.
			self updateHistory]!

session
	^session!

session: aGciSession
	session := aGciSession.
	session
		when: #forceJadeiteWindowClose
			send: #exit
			to: self;
		yourself!

setCaption
	self caption: (String writeStream
				nextPutAll: 'MethodHistory - ';
				nextPutAll: class name;
				nextPutAll: '>>';
				nextPutAll: self methodService selector asString;
				nextPutAll: '  (';
				print: selection;
				nextPutAll: ' of ';
				print: history size;
				nextPut: $);
				contents)!

systemModel
	^nil!

updateHistory
	"Get the historic information for the method. Purge consecutive duplicates from the list"

	| methodServiceHistory answeringService |
	Cursor wait showWhile: 
			[answeringService := RowanAnsweringService new
						command: #methodHistoryFor:;
						commandArgs: (Array with: self methodService);
						yourself.
			JadePresenter issueCommands: (Array with: answeringService) session: session].
	history := OrderedCollection new.
	methodServiceHistory := answeringService answer.
	methodServiceHistory do: 
			[:changedMethodService |
			history add: (Array
						with: #sources
						with: changedMethodService selector
						with: changedMethodService source)].
	self setCaption.
	self moveToLast! !
!JadeiteMethodHistoryBrowser categoriesFor: #about!commands!public! !
!JadeiteMethodHistoryBrowser categoriesFor: #applyOptions!initialization!public! !
!JadeiteMethodHistoryBrowser categoriesFor: #classService!accessing!public! !
!JadeiteMethodHistoryBrowser categoriesFor: #createComponents!initialization!public! !
!JadeiteMethodHistoryBrowser categoriesFor: #createSchematicWiring!initialization!public! !
!JadeiteMethodHistoryBrowser categoriesFor: #diff!commands!public! !
!JadeiteMethodHistoryBrowser categoriesFor: #methodService!accessing!public! !
!JadeiteMethodHistoryBrowser categoriesFor: #restoreMethod!commands!public! !
!JadeiteMethodHistoryBrowser categoriesFor: #session!accessing!private! !
!JadeiteMethodHistoryBrowser categoriesFor: #session:!accessing!private! !
!JadeiteMethodHistoryBrowser categoriesFor: #setCaption!operations!public! !
!JadeiteMethodHistoryBrowser categoriesFor: #systemModel!accessing!private! !
!JadeiteMethodHistoryBrowser categoriesFor: #updateHistory!operations!public! !

!JadeiteMethodHistoryBrowser class methodsFor!

canUseIdeaSpace

	^false!

defaultModel
	"in runtime environment, the superclass
	implementation of #defaultModel tries to 
	initialize a system which is not present"

	^nil!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 721158 ##(Smalltalk.SystemColor) 31 328198 ##(Smalltalk.Point) 1261 601 551 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 592 nil nil nil 7 nil nil nil 592 530 170 176 34 6 410 ##(Smalltalk.PushButton) 34 20 nil 592 34 2 8 1140924416 1 704 nil nil nil 7 nil nil nil 704 nil 8 4294905779 1180998 4 ##(Smalltalk.CommandDescription) #restoreMethod 8 'Restore' 1 1 nil nil false nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 17 9 498 121 57 704 898 #isEnabled: 8 #(false) 704 898 #text: 34 1 8 'Restore' 704 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 8 0 0 0 4 0 0 0 68 0 0 0 32 0 0 0] 8 #() 498 193 193 nil 29 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 17 1170 #fixedViewLeft 121 1170 #fixedParentTop 9 1170 #fixedParentBottom -7 410 ##(Smalltalk.PushButton) 34 20 nil 592 34 2 8 1140924416 1 1248 nil nil nil 7 nil nil nil 1248 nil 8 4294905779 786 #diff 8 'Diff' 1 1 nil nil false nil nil nil 834 138 144 34 3 898 #createAt:extent: 34 2 498 153 9 498 121 57 1248 898 #isEnabled: 8 #(false) 1248 898 #text: 34 1 8 'Diff' 1248 1058 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 76 0 0 0 4 0 0 0 136 0 0 0 32 0 0 0] 8 #() 1120 nil 29 1138 1170 #fixedPreviousRight 17 1200 121 1216 9 1232 -7 410 ##(Smalltalk.ContainerView) 34 15 nil 592 34 2 8 1140850688 131073 1632 nil nil nil 7 nil nil nil 1632 530 170 176 34 10 410 ##(Smalltalk.PushButton) 34 20 nil 1632 34 2 8 1140924416 1 1744 nil nil nil 7 nil nil nil 1744 nil 8 4294905779 786 #moveToPrevious 8 '<' 1 1 nil nil false nil nil nil 834 138 144 34 3 898 #createAt:extent: 34 2 498 65 9 498 49 57 1744 898 #isEnabled: 8 #(false) 1744 898 #text: 34 1 8 '<' 1744 1058 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 32 0 0 0 4 0 0 0 56 0 0 0 32 0 0 0] 8 #() 1120 nil 29 1138 1616 9 1200 49 1216 9 1232 -7 410 ##(Smalltalk.PushButton) 34 20 nil 1632 34 2 8 1140924416 1 2112 nil nil nil 7 nil nil nil 2112 nil 8 4294905779 786 #moveToFirst 8 '|<' 1 1 nil nil false nil nil nil 834 138 144 34 3 898 #createAt:extent: 34 2 498 9 9 498 49 57 2112 898 #isEnabled: 8 #(false) 2112 898 #text: 34 1 8 '|<' 2112 1058 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 4 0 0 0 28 0 0 0 32 0 0 0] 8 #() 1120 nil 29 1138 1184 9 1200 49 1216 9 1232 -7 410 ##(Smalltalk.Slider) 34 18 nil 1632 34 2 8 1140916485 1 2480 721990 2 ##(Smalltalk.ValueHolder) nil false 1376774 ##(Smalltalk.PluggableSearchPolicy) 459270 ##(Smalltalk.Message) #= 8 #() 2610 #hash 8 #() 3 nil nil 7 nil nil nil 2480 nil 8 4294902455 852486 ##(Smalltalk.NullConverter) nil nil 3 nil nil 834 138 144 34 3 898 #createAt:extent: 34 2 498 121 1 498 361 71 2480 898 #pageSize: 8 #(1) 2480 898 #range: 34 1 525062 ##(Smalltalk.Interval) 1 3 3 2480 1058 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 60 0 0 0 0 0 0 0 240 0 0 0 35 0 0 0] 8 #() 1120 nil 27 1138 1184 121 1170 #fixedParentRight -119 1216 1 1170 #fixedViewTop 71 410 ##(Smalltalk.PushButton) 34 20 nil 1632 34 2 8 1140924416 1 3040 nil nil nil 7 nil nil nil 3040 nil 8 4294905779 786 #moveToLast 8 '>|' 1 1 nil nil false nil nil nil 834 138 144 34 3 898 #createAt:extent: 34 2 498 545 9 498 49 57 3040 898 #isEnabled: 8 #(false) 3040 898 #text: 34 1 8 '>|' 3040 1058 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 16 1 0 0 4 0 0 0 40 1 0 0 32 0 0 0] 8 #() 1120 nil 29 1138 1170 #fixedViewRight -47 3008 -7 1216 9 1232 -7 410 ##(Smalltalk.PushButton) 34 20 nil 1632 34 2 8 1140924416 1 3424 nil nil nil 7 nil nil nil 3424 nil 8 4294905779 786 #moveToNext 8 '>' 1 1 nil nil false nil nil nil 834 138 144 34 3 898 #createAt:extent: 34 2 498 489 9 498 49 57 3424 898 #isEnabled: 8 #(false) 3424 898 #text: 34 1 8 '>' 3424 1058 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 244 0 0 0 4 0 0 0 12 1 0 0 32 0 0 0] 8 #() 1120 nil 29 1138 3408 -47 1170 #fixedPreviousLeft -7 1216 9 1232 -7 170 192 34 2 2480 8 'slider' nil 834 138 144 34 1 898 #createAt:extent: 34 2 498 323 1 498 601 73 1632 1058 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 161 0 0 0 0 0 0 0 205 1 0 0 36 0 0 0] 34 5 2112 1744 3040 3424 2480 1120 nil 27 1138 1616 51 1200 601 1216 1 1232 1 170 192 8 #() nil 834 138 144 34 1 898 #createAt:extent: 34 2 498 1 1 498 1229 73 592 1058 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 102 2 0 0 36 0 0 0] 34 3 704 1248 1632 1120 nil 27 1138 1184 1 3008 1 1216 1 3024 73 410 ##(Smalltalk.ScintillaView) 34 50 nil 416 34 2 8 1174475012 1025 4240 2546 nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 196934 1 ##(Smalltalk.RGB) 30277631 nil 7 nil nil nil 4240 nil 8 4294906401 2706 nil nil 11 nil 170 192 34 8 #callTip 1182790 1 ##(Smalltalk.ScintillaTextStyle) 77 786694 ##(Smalltalk.IndexedColor) 33554457 4482 33554471 1 nil nil nil nil #callTip nil nil nil #indentGuide 4450 75 nil nil 1 nil nil nil nil #indentGuide nil nil nil #lineNumber 4450 67 nil nil 1 nil nil nil nil #lineNumber nil nil nil #normal 4450 1 nil nil 1 nil nil nil nil #normal nil nil nil 34 40 4560 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 4544 nil nil nil 4528 nil nil 1377542 ##(Smalltalk.SmalltalkMethodStyler) 1 nil nil false 138 144 4048 170 192 34 2 #default 1641542 1 ##(Smalltalk.ScintillaMarkerDefinition) nil nil nil nil 4240 #circle nil nil nil nil nil nil 138 ##(Smalltalk.IdentitySet) 4048 nil 170 176 4048 9215 nil nil nil nil 4482 33554447 nil nil 65 nil nil 170 192 34 6 #literalBytes 8 '[]' #specialCharacter 8 '()[]<>' #literalArray 8 '()' 8 '' 1 170 192 4048 nil nil nil nil 3 nil 170 192 34 4 8 'indicator0' 1510470 2 ##(Smalltalk.ScintillaIndicatorStyle) 1 4240 65025 3 nil nil nil nil nil nil nil nil 8 'indicator1' 4914 3 4240 33423361 5 nil nil nil nil nil nil nil nil nil nil 170 192 34 6 #Notification 4450 1027 nil 4354 31185883 1 nil nil nil nil #Notification nil nil nil #Warning 4450 1029 4354 60239 4354 31326207 1 nil nil nil nil #Warning nil nil nil #Error 4450 1031 4354 335 4354 31317503 1 nil nil nil nil #Error nil nil nil nil 834 138 144 34 5 898 #createAt:extent: 34 2 498 1 73 498 1229 411 4240 898 #modificationEventMask: 8 #(4607) 4240 898 #caretPeriod: 8 #(530) 4240 898 #margins: 34 1 34 3 985158 2 ##(Smalltalk.ScintillaMargin) 1 4240 1 3 nil nil nil nil 5362 3 4240 1 nil nil 67108863 nil nil 5362 5 4240 1 nil nil nil nil nil 4240 898 #maxCompletionListHeight: 8 #(9) 4240 1058 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 36 0 0 0 102 2 0 0 241 0 0 0] 8 #() 1120 nil 29 1138 1184 1 3008 1 1170 #fixedPreviousBottom 1 1232 1 170 192 34 2 4240 8 'source' 590342 ##(Smalltalk.Rectangle) 498 1 1 498 1 1 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 265030 4 ##(Smalltalk.Menu) nil true 34 5 984134 2 ##(Smalltalk.CommandMenuItem) 1 786 #pageSetup 8 'Page &setup...' 1 1 nil nil nil 5746 1 786 #printPreview 8 'Print p&review...' 1 1 nil nil nil 5746 1 786 #print 8 '&Print...' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 5746 1 786 #exit 8 '&Close' 16615 1 nil nil nil 8 '&File' nil 1 nil nil 50029 nil nil 5698 nil true 34 3 5746 1 786 #copySelection 8 '&Copy' 1 1 nil nil nil 5746 1 786 #restoreMethod 8 '&Restore' 9381 1 nil nil nil 5746 1 786 #diff 8 '&Diff' 9353 1 nil nil nil 8 '&Edit' nil 1 nil nil 50037 nil nil 5698 nil true 34 4 5746 1 786 #moveToFirst 8 '&First' 1605 1 nil nil nil 5746 1 786 #moveToPrevious 8 '&Previous' 1611 1 nil nil nil 5746 1 786 #moveToNext 8 '&Next' 1615 1 nil nil nil 5746 1 786 #moveToLast 8 '&Last' 1603 1 nil nil nil 8 '&Position' nil 134217729 nil nil 50047 nil nil 8 '' nil 1 nil nil nil nil nil nil nil nil 1 nil nil nil nil 1 nil nil 834 138 144 34 3 898 #createAt:extent: 34 2 498 7679 21 498 1261 601 416 898 #text: 34 1 8 'Method History' 416 898 #updateMenuBar 4048 416 1058 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 117 17 0 0 54 1 0 0] 34 2 592 4240 1120 nil 27 )!

reuseIfOpen

	^false!

showOnClass: classService selector: methodService
	^self
		showOnClass: classService
		selector: methodService
		debugger: nil!

showOnClass: aClass selector: aSymbol debugger: aDebuggerOrNil
	| inst |
	inst := (self create session: GciSession current) showShell
				setClass: aClass
				selector: aSymbol
				debugger: aDebuggerOrNil.
	inst session: GciSession current.
	^inst! !
!JadeiteMethodHistoryBrowser class categoriesFor: #canUseIdeaSpace!public!testing! !
!JadeiteMethodHistoryBrowser class categoriesFor: #defaultModel!public! !
!JadeiteMethodHistoryBrowser class categoriesFor: #resource_Default_view!public!resources-views! !
!JadeiteMethodHistoryBrowser class categoriesFor: #reuseIfOpen!public!testing! !
!JadeiteMethodHistoryBrowser class categoriesFor: #showOnClass:selector:!instance creation!public! !
!JadeiteMethodHistoryBrowser class categoriesFor: #showOnClass:selector:debugger:!instance creation!private! !

