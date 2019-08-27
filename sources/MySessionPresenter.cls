"Filed out from Dolphin Smalltalk 7"!

JadePresenterA subclass: #MySessionPresenter
	instanceVariableNames: 'configurationReportPresenter gciSessionIdPresenter gciVersionPresenter gemHostPresenter gemTypePresenter logPathPresenter netPortPresenter netTaskPresenter stoneHostPresenter stoneNamePresenter stoneSerialPresenter stoneSessionIDPresenter userIDPresenter versionReportPresenter'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
MySessionPresenter guid: (GUID fromString: '{b36a1c7d-3698-4294-b47d-101c34edf22d}')!
MySessionPresenter comment: ''!
!MySessionPresenter categoriesForClass!Unclassified! !
!MySessionPresenter methodsFor!

abortTransaction

	parentPresenter abortTransaction.
!

commitTransaction
	^parentPresenter commitTransaction!

configDetailsFor: aPresenter

	| line string |
	line := aPresenter selection.	string := gciSession serverPerform: #'descriptionOfConfigOption:' with: line first.
	string := string , 'System gemConfigurationAt: #' , (line at: 1) , ' "' , (line at: 2) , '"'.
	(JadeWorkspace showOnSession: gciSession)
		model: string;
		isModified: false;
		yourself.!

createComponents

	super createComponents.
	configurationReportPresenter	:= self add: ListPresenter	new name: 'configurationReport'.
	gciSessionIdPresenter		:= self add: TextPresenter	new name: 'gciSessionId'.
	gciVersionPresenter			:= self add: TextPresenter	new name: 'gciVersion'.
	gemHostPresenter			:= self add: TextPresenter	new name: 'gemHost'.
	gemTypePresenter			:= self add: TextPresenter	new name: 'gemType'.
	logPathPresenter			:= self add: TextPresenter new name: 'logPath'.
	netPortPresenter			:= self add: TextPresenter	new name: 'netPort'.
	netTaskPresenter			:= self add: TextPresenter	new name: 'netTask'.
	stoneHostPresenter			:= self add: TextPresenter	new name: 'stoneHost'.
	stoneNamePresenter			:= self add: TextPresenter	new name: 'stoneName'.
	stoneSerialPresenter			:= self add: TextPresenter	new name: 'stoneSerial'.
	stoneSessionIDPresenter		:= self add: TextPresenter	new name: 'stoneSessionID'.
	userIDPresenter				:= self add: TextPresenter	new name: 'userID'.
	versionReportPresenter		:= self add: ListPresenter	new name: 'versionReport'.
!

createSchematicWiring

	super createSchematicWiring.
	configurationReportPresenter 	when: #'actionPerformed' send: #'configDetailsFor:' 	to: self with: configurationReportPresenter.
	versionReportPresenter 		when: #'actionPerformed' send: #'versionDetailsFor:' 	to: self with: versionReportPresenter.
!

fillSessionInfo

	| line list stream |
	gciVersionPresenter 	value: gciSession libraryVersion.
	userIDPresenter		value: gciSession userID.
	stoneHostPresenter	value: gciSession stoneHost.
	stoneNamePresenter	value: gciSession stoneName.
	gciSession isLinkedGem ifTrue: [
		gemTypePresenter	value: 'linked'.
	] ifFalse: [
		gemTypePresenter	value: 'RPC'.
		gemHostPresenter	value: gciSession gemHost.
		netPortPresenter	value: gciSession netPort.
		netTaskPresenter	value: gciSession netTask.
	].
	stoneSessionIDPresenter	value: gciSession stoneSessionID.
	stoneSerialPresenter		value: gciSession stoneSerial.
	gciSessionIdPresenter	value: gciSession gciSessionId.

	stream := ReadStream on: (gciSession serverPerform: #'mySessionInfo').
	logPathPresenter value: stream nextLine.
	list := OrderedCollection new.
	[
		(line := stream nextLine) = '%'.
	] whileFalse: [
		list add: (line subStrings: Character tab).
	].
	versionReportPresenter list: list.
	list := OrderedCollection new.
	[
		(line := stream nextLine) = '%'.
	] whileFalse: [
		list add: (line subStrings: Character tab).
	].
	configurationReportPresenter list: list.!

hardBreak

	gciSession hardBreak.
!

softBreak

	gciSession softBreak.
!

versionDetailsFor: aPresenter

	| line string |
	line := aPresenter selection.	string := 'System gemVersionAt: #' , (line at: 1) , ' "' , (line at: 2) , '"'.
	(JadeWorkspace showOnSession: gciSession)
		model: string;
		isModified: false;
		yourself.! !
!MySessionPresenter categoriesFor: #abortTransaction!public! !
!MySessionPresenter categoriesFor: #commitTransaction!public! !
!MySessionPresenter categoriesFor: #configDetailsFor:!public! !
!MySessionPresenter categoriesFor: #createComponents!public! !
!MySessionPresenter categoriesFor: #createSchematicWiring!public! !
!MySessionPresenter categoriesFor: #fillSessionInfo!public!updating! !
!MySessionPresenter categoriesFor: #hardBreak!public! !
!MySessionPresenter categoriesFor: #softBreak!public! !
!MySessionPresenter categoriesFor: #versionDetailsFor:!public! !

!MySessionPresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil 328198 ##(Smalltalk.Point) 1153 621 5 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 60 410 ##(Smalltalk.ListView) 34 30 nil 416 34 2 8 1409355853 1025 576 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 524550 ##(Smalltalk.ColorRef) 8 4278190080 nil 5 nil nil nil 576 nil 8 4294903685 459270 ##(Smalltalk.Message) #displayString 8 #() ##(Smalltalk.IconicListAbstract) 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil nil 138 144 34 2 920646 5 ##(Smalltalk.ListViewColumn) 8 'Configuration' 381 #left 802 #first 8 #() ##(Smalltalk.SortedCollection) nil nil 576 nil 1 nil nil 914 8 'Value' 151 #right 802 #last 976 802 #<= 976 nil nil 576 nil 1 nil nil #report 688 nil 131169 nil 34 4 nil nil 482 1 1 nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 482 577 233 482 577 389 576 1154 #text: 34 1 8 'Configuration' 576 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 32 1 0 0 116 0 0 0 64 2 0 0 54 1 0 0] 8 #() 482 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedPreviousRight 1 1394 #fixedParentRight 1 1394 #fixedPreviousTop 1 1394 #fixedParentBottom 1 410 ##(Smalltalk.PushButton) 34 20 nil 416 34 2 8 1140924416 1 1472 nil nil nil 5 nil nil nil 1472 nil 8 4294902187 1180998 4 ##(Smalltalk.CommandDescription) #commitTransaction 8 'Commit' 1 1 nil nil false nil nil nil 1090 138 144 34 3 1154 #createAt:extent: 34 2 482 133 571 482 121 51 1472 1154 #isEnabled: 8 #(false) 1472 1154 #text: 34 1 8 'Commit' 1472 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 66 0 0 0 29 1 0 0 126 0 0 0 54 1 0 0] 8 #() 1344 nil 29 1362 1408 11 1394 #fixedViewLeft 121 1440 1 1394 #fixedViewTop 51 410 ##(Smalltalk.StaticText) 34 16 nil 416 34 2 8 1140850944 1 1888 nil nil nil 5 nil nil nil 1888 nil 8 1817086624 852486 ##(Smalltalk.NullConverter) nil nil nil 1090 138 144 34 2 1154 #createAt:extent: 34 2 482 403 49 482 161 45 1888 1154 #text: 34 1 8 'Gem Type:' 1888 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 201 0 0 0 24 0 0 0 25 1 0 0 46 0 0 0] 8 #() 1344 nil 27 1362 1408 11 1856 161 1440 1 1872 45 410 ##(Smalltalk.TextEdit) 34 16 nil 416 34 2 8 1140916352 1025 2224 nil 738 8 4278190080 nil 5 nil nil nil 2224 nil 8 4294905821 1970 nil nil 3 1090 138 144 34 1 1154 #createAt:extent: 34 2 482 563 141 482 211 45 2224 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 25 1 0 0 70 0 0 0 130 1 0 0 92 0 0 0] 8 #() 1344 nil 27 1362 1408 1 1856 211 1440 1 1872 45 410 ##(Smalltalk.StaticText) 34 16 nil 416 34 2 8 1140850944 1 2528 nil nil nil 5 nil nil nil 2528 nil 8 1817086624 1970 nil nil nil 1090 138 144 34 2 1154 #createAt:extent: 34 2 482 403 95 482 161 45 2528 1154 #text: 34 1 8 'Net Service:' 2528 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 201 0 0 0 47 0 0 0 25 1 0 0 69 0 0 0] 8 #() 1344 nil 27 1362 1408 11 1856 161 1440 1 1872 45 410 ##(Smalltalk.StaticText) 34 16 nil 416 34 2 8 1140850944 1 2848 nil nil nil 5 nil nil nil 2848 nil 8 1817086624 1970 nil nil nil 1090 138 144 34 2 1154 #createAt:extent: 34 2 482 403 141 482 161 45 2848 1154 #text: 34 1 8 'Net Task:' 2848 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 201 0 0 0 70 0 0 0 25 1 0 0 92 0 0 0] 8 #() 1344 nil 27 1362 1408 11 1856 161 1440 1 1872 45 410 ##(Smalltalk.StaticText) 34 16 nil 416 34 2 8 1140850944 1 3168 nil nil nil 5 nil nil nil 3168 nil 8 1817086624 1970 nil nil nil 1090 138 144 34 2 1154 #createAt:extent: 34 2 482 783 141 482 161 45 3168 1154 #text: 34 1 8 'Stone Serial:
' 3168 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 135 1 0 0 70 0 0 0 215 1 0 0 92 0 0 0] 8 #() 1344 nil 27 1362 1408 11 1856 161 1440 1 1872 45 410 ##(Smalltalk.TextEdit) 34 16 nil 416 34 2 8 1140916352 1025 3488 nil 738 8 4278190080 nil 5 nil nil nil 3488 nil 8 4294905821 1970 nil nil 3 1090 138 144 34 1 1154 #createAt:extent: 34 2 482 183 187 482 971 45 3488 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 91 0 0 0 93 0 0 0 64 2 0 0 115 0 0 0] 8 #() 1344 nil 27 1362 1408 1 1424 1 1440 1 1872 45 410 ##(Smalltalk.StaticText) 34 16 nil 416 34 2 8 1140850944 1 3792 nil nil nil 5 nil nil nil 3792 nil 8 1817086624 1970 nil nil nil 1090 138 144 34 2 1154 #createAt:extent: 34 2 482 783 49 482 161 45 3792 1154 #text: 34 1 8 'GCI Version:' 3792 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 135 1 0 0 24 0 0 0 215 1 0 0 46 0 0 0] 8 #() 1344 nil 27 1362 1408 11 1856 161 1440 1 1872 45 410 ##(Smalltalk.TextEdit) 34 16 nil 416 34 2 8 1140916352 1025 4112 nil 738 2304 nil 5 nil nil nil 4112 nil 8 4294905821 1970 nil nil 3 1090 138 144 34 1 1154 #createAt:extent: 34 2 482 943 49 482 211 45 4112 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 215 1 0 0 24 0 0 0 64 2 0 0 46 0 0 0] 8 #() 1344 nil 27 1362 1408 1 1856 211 1440 1 1872 45 410 ##(Smalltalk.TextEdit) 34 16 nil 416 34 2 8 1140916352 1025 4400 nil 738 2304 nil 5 nil nil nil 4400 nil 8 4294905821 1970 nil nil 3 1090 138 144 34 1 1154 #createAt:extent: 34 2 482 183 3 482 211 45 4400 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 91 0 0 0 1 0 0 0 196 0 0 0 23 0 0 0] 8 #() 1344 nil 27 1362 1408 1 1856 211 1440 1 1872 45 410 ##(Smalltalk.TextEdit) 34 16 nil 416 34 2 8 1140916352 1025 4688 nil 738 2304 nil 5 nil nil nil 4688 nil 8 4294905821 1970 nil nil 3 1090 138 144 34 1 1154 #createAt:extent: 34 2 482 563 49 482 211 45 4688 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 25 1 0 0 24 0 0 0 130 1 0 0 46 0 0 0] 8 #() 1344 nil 27 1362 1408 1 1856 211 1440 1 1872 45 410 ##(Smalltalk.TextEdit) 34 16 nil 416 34 2 8 1140916352 1025 4976 nil 738 2304 nil 5 nil nil nil 4976 nil 8 4294905821 1970 nil nil 3 1090 138 144 34 1 1154 #createAt:extent: 34 2 482 563 3 482 591 45 4976 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 25 1 0 0 1 0 0 0 64 2 0 0 23 0 0 0] 8 #() 1344 nil 27 1362 1408 1 1856 591 1440 1 1872 45 410 ##(Smalltalk.TextEdit) 34 16 nil 416 34 2 8 1140916354 1025 5264 nil 738 2304 nil 5 nil nil nil 5264 nil 8 4294905821 1970 nil nil 3 1090 138 144 34 1 1154 #createAt:extent: 34 2 482 183 141 482 211 45 5264 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 91 0 0 0 70 0 0 0 196 0 0 0 92 0 0 0] 8 #() 1344 nil 27 1362 1408 1 1856 211 1440 1 1872 45 410 ##(Smalltalk.PushButton) 34 20 nil 416 34 2 8 1140924416 1 5552 nil nil nil 5 nil nil nil 5552 nil 8 4294902187 1554 #softBreak 8 'Soft Break' 9395 1 nil nil false nil nil nil 1090 138 144 34 3 1154 #createAt:extent: 34 2 482 263 571 482 151 51 5552 1154 #isEnabled: 8 #(false) 5552 1154 #text: 34 1 8 'Soft Break' 5552 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 131 0 0 0 29 1 0 0 206 0 0 0 54 1 0 0] 8 #() 1344 nil 29 1362 1408 11 1856 151 1440 1 1872 51 410 ##(Smalltalk.StaticText) 34 16 nil 416 34 2 8 1140850944 1 5920 nil nil nil 5 nil nil nil 5920 nil 8 1817086624 1970 nil nil nil 1090 138 144 34 2 1154 #createAt:extent: 34 2 482 3 49 482 181 45 5920 1154 #text: 34 1 8 'Stone Host:' 5920 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 1 0 0 0 24 0 0 0 91 0 0 0 46 0 0 0] 8 #() 1344 nil 27 1362 1394 #fixedParentLeft 3 1856 181 1394 #fixedPreviousBottom 3 1872 45 410 ##(Smalltalk.StaticText) 34 16 nil 416 34 2 8 1140850944 1 6272 nil nil nil 5 nil nil nil 6272 nil 8 1817086624 1970 nil nil nil 1090 138 144 34 2 1154 #createAt:extent: 34 2 482 783 95 482 161 45 6272 1154 #text: 34 1 8 'GCI Session:' 6272 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 135 1 0 0 47 0 0 0 215 1 0 0 69 0 0 0] 8 #() 1344 nil 27 1362 1408 11 1856 161 1440 1 1872 45 410 ##(Smalltalk.StaticText) 34 16 nil 416 34 2 8 1140850944 1 6592 nil nil nil 5 nil nil nil 6592 nil 8 1817086624 1970 nil nil nil 1090 138 144 34 2 1154 #createAt:extent: 34 2 482 3 141 482 181 45 6592 1154 #text: 34 1 8 'Stone Session:' 6592 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 1 0 0 0 70 0 0 0 91 0 0 0 92 0 0 0] 8 #() 1344 nil 27 1362 6240 3 1856 181 6256 3 1872 45 410 ##(Smalltalk.TextEdit) 34 16 nil 416 34 2 8 1140916354 1025 6912 nil 738 2304 nil 5 nil nil nil 6912 nil 8 4294905821 1970 nil nil 3 1090 138 144 34 1 1154 #createAt:extent: 34 2 482 943 141 482 211 45 6912 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 215 1 0 0 70 0 0 0 64 2 0 0 92 0 0 0] 8 #() 1344 nil 27 1362 1408 1 1856 211 1440 1 1872 45 410 ##(Smalltalk.TextEdit) 34 16 nil 416 34 2 8 1140916352 1025 7200 nil 738 2304 nil 5 nil nil nil 7200 nil 8 4294905821 1970 nil nil 3 1090 138 144 34 1 1154 #createAt:extent: 34 2 482 563 95 482 211 45 7200 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 25 1 0 0 47 0 0 0 130 1 0 0 69 0 0 0] 8 #() 1344 nil 27 1362 1408 1 1856 211 1440 1 1872 45 410 ##(Smalltalk.StaticText) 34 16 nil 416 34 2 8 1140850944 1 7488 nil nil nil 5 nil nil nil 7488 nil 8 1817086624 1970 nil nil nil 1090 138 144 34 2 1154 #createAt:extent: 34 2 482 3 3 482 181 45 7488 1154 #text: 34 1 8 'User ID:' 7488 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 1 0 0 0 1 0 0 0 91 0 0 0 23 0 0 0] 8 #() 1344 nil 27 1362 6240 3 1856 181 1394 #fixedParentTop 3 1872 45 410 ##(Smalltalk.PushButton) 34 20 nil 416 34 2 8 1140924416 1 7824 nil nil nil 5 nil nil nil 7824 nil 8 4294902187 1554 #hardBreak 8 'Hard Break' 1 1 nil nil false nil nil nil 1090 138 144 34 3 1154 #createAt:extent: 34 2 482 423 571 482 151 51 7824 1154 #isEnabled: 8 #(false) 7824 1154 #text: 34 1 8 'Hard Break' 7824 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 211 0 0 0 29 1 0 0 30 1 0 0 54 1 0 0] 8 #() 1344 nil 29 1362 1408 11 1856 151 1440 1 1872 51 410 ##(Smalltalk.ListView) 34 30 nil 416 34 2 8 1409355853 1025 8192 642 138 144 688 nil 720 738 768 nil 5 nil nil nil 8192 nil 8 4294903685 802 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 864 nil nil nil nil nil nil 138 144 34 2 914 8 'Version' 271 #left 802 #first 976 ##(Smalltalk.SortedCollection) nil nil 8192 nil 1 nil nil 914 8 'Value' 261 #left 802 #last 976 802 #<= 976 nil nil 8192 nil 1 nil nil #report 688 nil 131169 nil 34 4 nil nil 482 1 1 nil 1090 138 144 34 2 1154 #createAt:extent: 34 2 482 3 233 482 575 339 8192 1154 #text: 34 1 8 'Version' 8192 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 1 0 0 0 116 0 0 0 32 1 0 0 29 1 0 0] 8 #() 1344 nil 27 1362 6240 3 1394 #relativeParentWidth 524806 ##(Smalltalk.Fraction) 3 5 6256 3 1456 -49 410 ##(Smalltalk.TextEdit) 34 16 nil 416 34 2 8 1140916354 1025 8800 nil 738 2304 nil 5 nil nil nil 8800 nil 8 4294905821 1970 nil nil 3 1090 138 144 34 1 1154 #createAt:extent: 34 2 482 943 95 482 211 45 8800 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 215 1 0 0 47 0 0 0 64 2 0 0 69 0 0 0] 8 #() 1344 nil 27 1362 1408 1 1856 211 1440 1 1872 45 410 ##(Smalltalk.StaticText) 34 16 nil 416 34 2 8 1140850944 1 9088 nil nil nil 5 nil nil nil 9088 nil 8 1817086624 1970 nil nil nil 1090 138 144 34 2 1154 #createAt:extent: 34 2 482 3 95 482 181 45 9088 1154 #text: 34 1 8 'Stone Name:' 9088 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 1 0 0 0 47 0 0 0 91 0 0 0 69 0 0 0] 8 #() 1344 nil 27 1362 6240 3 1856 181 6256 3 1872 45 410 ##(Smalltalk.TextEdit) 34 16 nil 416 34 2 8 1140916352 1025 9408 nil 738 2304 nil 5 nil nil nil 9408 nil 8 4294905821 1970 nil nil 3 1090 138 144 34 1 1154 #createAt:extent: 34 2 482 183 49 482 211 45 9408 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 91 0 0 0 24 0 0 0 196 0 0 0 46 0 0 0] 8 #() 1344 nil 27 1362 1408 1 1856 211 1440 1 1872 45 410 ##(Smalltalk.PushButton) 34 20 nil 416 34 2 8 1140924416 1 9696 nil nil nil 5 nil nil nil 9696 nil 8 4294902187 1554 #abortTransaction 8 'Abort' 1 1 nil nil false nil nil nil 1090 138 144 34 3 1154 #createAt:extent: 34 2 482 3 571 482 121 51 9696 1154 #isEnabled: 8 #(false) 9696 1154 #text: 34 1 8 'Abort' 9696 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 1 0 0 0 29 1 0 0 61 0 0 0 54 1 0 0] 8 #() 1344 nil 29 1362 6240 3 1856 121 1456 -49 1872 51 410 ##(Smalltalk.TextEdit) 34 16 nil 416 34 2 8 1140916352 1025 10064 nil 738 2304 nil 5 nil nil nil 10064 nil 8 4294905821 1970 nil nil 3 1090 138 144 34 1 1154 #createAt:extent: 34 2 482 183 95 482 211 45 10064 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 91 0 0 0 47 0 0 0 196 0 0 0 69 0 0 0] 8 #() 1344 nil 27 1362 1408 1 1856 211 1440 1 1872 45 410 ##(Smalltalk.StaticText) 34 16 nil 416 34 2 8 1140850944 1 10352 nil nil nil 5 nil nil nil 10352 nil 8 1817086624 1970 nil nil nil 1090 138 144 34 2 1154 #createAt:extent: 34 2 482 403 3 482 161 45 10352 1154 #text: 34 1 8 'Gem Host:' 10352 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 201 0 0 0 1 0 0 0 25 1 0 0 23 0 0 0] 8 #() 1344 nil 27 1362 1408 11 1856 161 1440 1 1872 45 410 ##(Smalltalk.StaticText) 34 16 nil 416 34 2 8 1140850944 65 10672 nil nil nil 5 nil nil nil 10672 nil 8 1817086624 1970 nil nil nil 1090 138 144 34 2 1154 #createAt:extent: 34 2 482 3 187 482 181 45 10672 1154 #text: 34 1 8 'Log Path:' 10672 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 1 0 0 0 93 0 0 0 91 0 0 0 115 0 0 0] 8 #() 1344 nil 27 1362 6240 3 1856 181 6256 3 1872 45 170 192 34 28 2224 8 'netTask' 4112 8 'gciVersion' 6912 8 'stoneSerial' 8800 8 'gciSessionId' 5264 8 'stoneSessionID' 8192 8 'versionReport' 4688 8 'gemType' 7200 8 'netPort' 4400 8 'userID' 4976 8 'gemHost' 9408 8 'stoneHost' 10064 8 'stoneName' 3488 8 'logPath' 576 8 'configurationReport' nil 1090 138 144 34 1 1154 #createAt:extent: 34 2 482 7679 21 482 1153 621 416 1282 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 63 17 0 0 64 1 0 0] 34 30 7488 4400 10352 4976 5920 9408 1888 4688 3792 4112 9088 10064 2528 7200 6272 8800 6592 5264 2848 2224 3168 6912 10672 3488 8192 576 9696 1472 5552 7824 1344 nil 27 )! !
!MySessionPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

