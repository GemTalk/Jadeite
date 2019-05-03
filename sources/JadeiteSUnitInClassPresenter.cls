"Filed out from Dolphin Smalltalk 7"!

JadeiteSUnitAbstractPresenter subclass: #JadeiteSUnitInClassPresenter
	instanceVariableNames: 'testClassService'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteSUnitInClassPresenter guid: (GUID fromString: '{a1eac98a-259a-424e-bfe5-973e32a9b4c6}')!
JadeiteSUnitInClassPresenter comment: ''!
!JadeiteSUnitInClassPresenter categoriesForClass!Unclassified! !
!JadeiteSUnitInClassPresenter methodsFor!

addSystemBrowser

	^parentPresenter addSystemBrowser!

browseIt
	^self debug!

debug
	testClassService ifNil: [^self].
	methodListPresenter selections do: 
			[:methodService |
			
			[gciSession
				serverPerform: #debugTestNamed:of:
				with: methodService selector
				with: testClassService name]
					ifCurtailed: [^self].
			methodService setPassed]!

editFind

	"do nothing"!

editReplace

	"do nothing"!

editSave

	"do nothing" !

editSelectAll

	methodListPresenter selections: methodListPresenter list. !

findClass

	^parentPresenter findClass!

findMethod

	^parentPresenter findMethod!

jadeBrowseTests

	^parentPresenter topShell jadeBrowseTests!

jadeDebug
	"hot key hook" 
	^self debug.!

jadeDisplay

	"do nothing"!

jadeExecute

	"do nothing"!

jadeInspect

	"do nothing"!

newBrowser

	^parentPresenter newBrowser!

onViewOpened

	super onViewOpened. 
	self registerPresentersForUpdates.
	!

queryCommand: aCommandQuery
	aCommandQuery isEnabled: true. 
	^false!

refresh
	parentPresenter updateService: parentPresenter selectedClass.
	self parentPresenter updateSUnitTab.
	self ensureVisible.
	self reset!

runAll
	self runTests: methodListPresenter model in: testClassService name!

runAndMesureTime
	| millisecondsToRun timeMessage time |
	"(testCasesPresenter selection size = 1) ifFalse: [^MessageBox notify: 'Select only one Test' ]."
	timeMessage := WriteStream on: String new.
	timeMessage nextPutAll: 'Total Time'.
	millisecondsToRun := Time millisecondsToRun: [self runSelected].
	time := Time fromMilliseconds: millisecondsToRun.
	time asSeconds = 0
		ifTrue: [timeMessage nextPutAll: 'milliseconds - ' , millisecondsToRun printString]
		ifFalse: 
			[timeMessage nextPutAll: String lineDelimiter , time minutes printString , ' minutes or'.
			timeMessage nextPutAll: String lineDelimiter , time asSeconds printString , ' seconds or'.
			timeMessage nextPutAll: String lineDelimiter , millisecondsToRun printString , ' milliseconds'].
	MessageBox notify: timeMessage contents!

runSelected
	self runTests: methodListPresenter selection in: testClassService name!

selectedClass
	^self parentPresenter selectedClass! !
!JadeiteSUnitInClassPresenter categoriesFor: #addSystemBrowser!menu handlers support!public! !
!JadeiteSUnitInClassPresenter categoriesFor: #browseIt!public! !
!JadeiteSUnitInClassPresenter categoriesFor: #debug!public! !
!JadeiteSUnitInClassPresenter categoriesFor: #editFind!menu handlers support!public! !
!JadeiteSUnitInClassPresenter categoriesFor: #editReplace!menu handlers support!public! !
!JadeiteSUnitInClassPresenter categoriesFor: #editSave!menu handlers support!public! !
!JadeiteSUnitInClassPresenter categoriesFor: #editSelectAll!menu handlers support!public! !
!JadeiteSUnitInClassPresenter categoriesFor: #findClass!menu handlers support!public! !
!JadeiteSUnitInClassPresenter categoriesFor: #findMethod!menu handlers support!public! !
!JadeiteSUnitInClassPresenter categoriesFor: #jadeBrowseTests!menu handlers support!public! !
!JadeiteSUnitInClassPresenter categoriesFor: #jadeDebug!public! !
!JadeiteSUnitInClassPresenter categoriesFor: #jadeDisplay!menu handlers support!public! !
!JadeiteSUnitInClassPresenter categoriesFor: #jadeExecute!menu handlers support!public! !
!JadeiteSUnitInClassPresenter categoriesFor: #jadeInspect!menu handlers support!public! !
!JadeiteSUnitInClassPresenter categoriesFor: #newBrowser!public! !
!JadeiteSUnitInClassPresenter categoriesFor: #onViewOpened!event handlers!public! !
!JadeiteSUnitInClassPresenter categoriesFor: #queryCommand:!menu handlers support!public! !
!JadeiteSUnitInClassPresenter categoriesFor: #refresh!public! !
!JadeiteSUnitInClassPresenter categoriesFor: #runAll!public! !
!JadeiteSUnitInClassPresenter categoriesFor: #runAndMesureTime!public! !
!JadeiteSUnitInClassPresenter categoriesFor: #runSelected!public! !
!JadeiteSUnitInClassPresenter categoriesFor: #selectedClass!accessing!public! !

!JadeiteSUnitInClassPresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil 196934 1 ##(Smalltalk.RGB) 26337781 nil 5 nil nil nil 416 788230 ##(Smalltalk.BorderLayout) 1 1 nil 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 544 nil nil nil 5 nil nil nil 544 1180166 ##(Smalltalk.ProportionalLayout) 170 176 8 #() false 170 192 34 2 410 ##(Smalltalk.StaticText) 34 16 nil 544 34 2 8 1140850944 1 704 nil 721158 ##(Smalltalk.SystemColor) 31 nil 5 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[240 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 188 2 0 0 0 0 0 0 1 2 1 34 83 121 115 116 101 109 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 328198 ##(Smalltalk.Point) 193 193 nil 704 nil 8 1674732848 852486 ##(Smalltalk.NullConverter) nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 882 1 1 882 1241 71 704 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 108 2 0 0 35 0 0 0] 8 #() 882 193 193 nil 27 8 'textResult' nil 962 138 144 34 1 1026 #createAt:extent: 34 2 882 1 801 882 1241 71 544 1106 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 144 1 0 0 108 2 0 0 179 1 0 0] 34 1 704 1168 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 1360 nil nil nil 5 nil nil nil 1360 610 170 176 656 true 170 192 656 nil 962 138 144 34 1 1026 #createAt:extent: 34 2 882 1181 1 882 61 801 1360 1106 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 78 2 0 0 0 0 0 0 108 2 0 0 144 1 0 0] 34 1 410 ##(Smalltalk.ContainerView) 34 15 nil 1360 34 2 8 1140850688 131073 1632 nil 770 31 nil 5 nil nil nil 1632 610 170 176 656 false 170 192 656 nil 962 138 144 34 1 1026 #createAt:extent: 34 2 882 1 1 882 61 801 1632 1106 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 30 0 0 0 144 1 0 0] 34 1 410 ##(Smalltalk.ContainerView) 34 15 nil 1632 34 2 8 1140850688 131073 1920 nil nil nil 5 nil nil nil 1920 610 170 176 656 false 170 192 656 nil 962 138 144 34 1 1026 #createAt:extent: 34 2 882 1 1 882 61 801 1920 1106 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 30 0 0 0 144 1 0 0] 34 1 410 ##(Smalltalk.SUnitToolbar) 34 25 nil 1920 34 2 8 1149240268 131137 2192 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 nil 517 nil nil nil 2192 2258 2288 8 4294909297 nil 170 192 34 10 25965 853766 ##(Smalltalk.ToolbarButton) 25965 nil 2192 1 1180998 4 ##(Smalltalk.CommandDescription) #runAll 8 'Run All' nil 1 nil 395334 3 ##(Smalltalk.Bitmap) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'Tools.bmp' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil nil 7 882 1857 33 51 25967 2370 25967 nil 2192 1 2402 #runSelected 8 'Run Selected' 1 1 nil 2464 83 25969 1115910 ##(Smalltalk.ToolbarIconButton) 25969 nil 2192 1 2402 #runAndMesureTime 8 'Run and Measure Time' 1 1 263494 3 ##(Smalltalk.Icon) nil true 2496 8 'Time.ico' 2544 2450 nil true nil nil nil nil 3 882 33 33 1 25971 2370 25971 nil 2192 1 2402 #debug 8 'Debug' 1 1 nil 2464 15 25973 1246982 ##(Smalltalk.ToolbarSystemButton) 25973 nil 2192 1 2402 #reset 8 'Reset' 1 1 nil 1 9 34 8 2384 2592 1050118 ##(Smalltalk.ToolbarSeparator) nil nil 2192 3 nil 1 2656 2914 nil nil 2192 3 nil 1 2784 2914 nil nil 2192 3 nil 1 2848 170 176 34 6 1 119 2464 1 2752 117 nil 1 nil 882 33 33 882 45 45 nil nil 962 138 144 34 2 1026 #createAt:extent: 34 2 882 1 1 882 61 801 2192 1026 #updateSizePosted 656 2192 1106 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 30 0 0 0 144 1 0 0] 8 #() 1168 nil 27 1168 nil 27 1168 nil 27 1168 nil 27 nil 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 3216 nil 482 26337781 nil 5 nil nil nil 3216 610 170 176 656 false 170 192 34 2 410 ##(Smalltalk.MultipleSelectionListView) 34 30 nil 3216 34 2 8 1140920393 1025 3360 590662 2 ##(Smalltalk.ListModel) 138 144 656 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 482 26337781 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 8 984134 2 ##(Smalltalk.CommandMenuItem) 1 2402 #runAll 8 'Run All' 1025 1 nil nil nil 3570 1 2402 #runSelected 8 'Run Selected' 1025 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 3570 1 2402 #runAndMesureTime 8 'Run and Measure Time' 1 1 nil nil nil 3682 4097 3570 1 2402 #debug 8 'Debug' 9349 1 nil nil nil 3682 4097 3570 1 2402 #refresh 8 'Refresh' 1025 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 3360 nil 8 4294909209 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 1 920646 5 ##(Smalltalk.ListViewColumn) 8 'Test Cases' 1181 #left 3922 #name 8 #() 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 106 8 'Dolphin' 8 'SortedCollection' 8 'doIt' 8 '[:a :b | a methodName <= b methodName]' 8 #[30 105 226 0 226 32 130 106] #methodName 4128 7 513 nil nil nil 3360 nil 3 nil nil #report 656 nil 131169 nil 34 4 nil nil 882 1 1 nil 962 138 144 34 3 1026 #createAt:extent: 34 2 882 1 1 882 1181 801 3360 1026 #contextMenu: 34 1 3536 3360 1026 #text: 34 1 8 'Test Cases' 3360 1106 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 78 2 0 0 144 1 0 0] 8 #() 1168 nil 27 8 'testCases' nil 962 138 144 34 1 1026 #createAt:extent: 34 2 882 1 1 882 1181 801 3216 1106 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 78 2 0 0 144 1 0 0] 34 1 3360 1168 nil 27 170 192 656 nil 962 138 144 34 1 1026 #createAt:extent: 34 2 882 7679 21 882 1241 871 416 1106 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 107 17 0 0 189 1 0 0] 34 3 3216 1360 544 1168 nil 27 )! !
!JadeiteSUnitInClassPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

