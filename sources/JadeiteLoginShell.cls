"Filed out from Dolphin Smallalk"!

JadeLoginShell subclass: #JadeiteLoginShell
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteLoginShell guid: (GUID fromString: '{f36f41a4-9f3b-4f44-b07e-a68ce7de3ed7}')!
JadeiteLoginShell comment: ''!
!JadeiteLoginShell categoriesForClass!Unclassified! !
!JadeiteLoginShell methodsFor!

additionalAccelerators
	^#(#(#raiseConsole 'Ctrl+F7'))!

basicCaption
	^'Jadeite Login Version: ' , self class jadeiteVersionString!

fillVersionList
	| list |
	list := self librariesSupportingRowanV30.
	list addAll: self placeholdersForNewSharedLibraries.
	list := list
				asSortedCollection: [:a :b | self isVersion: a displayName lessThanOrEqualTo: b displayName].
	versionListPresenter list: list asArray!

invalidateLoginButton
	"fake up a query to ensure the button gets enabled without user action"

	| query buttonView |
	buttonView := loginButtonPresenter view.
	query := CommandQuery commandDescription: buttonView commandDescription source: buttonView.
	self queryCommand: query.
	self view setFocus.
	buttonView invalidate!

librariesSupportingRowanV30
	^GciLibrary allSubclasses select: [:library | library supportsRowanV30]!

login
	| session |
	self updateModel.
	[session := self model login] on: Error
		do: 
			[:ex |
			| ws | 
			ws := WriteStream on: String new.
			ex tag message isEmpty
				ifFalse: 
					[ws
						nextPutAll: ex tag message;
						space].
			ws nextPutAll: ex description.
			MessageBox errorMsg: ws contents caption: 'Jadeite Login Error'.
			SessionManager current pause.
			GciSession current: nil.
			^nil].
	self postShellLogin: session!

onViewClosed
	self updateModel.
	model saveDefault.
	super onViewClosed.
!

openGitHubJadeiteProject
	^JadePresenter openGitHubJadeiteProject!

openGitHubRowanProject
	^JadePresenter openGitHubRowanProject!

placeholderFor: fileName version: version libraryName: libraryName
	| parentLibraryName parentLibrary |
	parentLibraryName := 'LibGciRpc64_' , ((fileName subStrings: $-) second first: 3)
				copyReplaceAll: '.'
				with: '_'.
	parentLibrary := Smalltalk at: parentLibraryName
				ifAbsent: [^self error: 'Invalid Client Library string detected'].
	^LibGciRpc64_Holder
		displayName: '64-bit ' , version
		fileNameSearch: fileName
		parentLibrary: parentLibrary!

placeholdersForNewSharedLibraries
	"Private - Search the <working directory>/bin directory for windows client gci libraries
	that don't already have an associated Smalltalk class. Create a class if necessary"

	| binDir placeholders |
	binDir := SessionManager current imageBase , 'bin\'.
	(File exists: binDir) ifFalse: [^self].
	placeholders := OrderedCollection new.
	File
		for: 'libgcirpc*dll'
		in: SessionManager current imageBase , 'bin\'
		do: 
			[:data |
			| version libraryName |
			version := (data fileName subStrings: $-) second.
			libraryName := 'LibGciRpc64_' , (version copyReplaceAll: '.' with: '_').
			Smalltalk at: libraryName
				ifAbsent: 
					[placeholders add: (self
								placeholderFor: data fileName
								version: version
								libraryName: libraryName)]].
	^placeholders!

postLogoutActions
	self invalidateLoginButton.
	BrowserUpdate clearCurrent	"gets rid of all old service events associated with current session"!

postShellLogin: aGciSession
	| transcript |
	aGciSession isRowanLoaded ifFalse: [^aGciSession logout].
	versionListPresenter view disable.
	aGciSession
		when: #postLogout
		send: #postLogoutActions
		to: self.
	transcript := JadeiteTranscript showOnSession: aGciSession.
	transcript view position: self view position + JadePresenter defaultWindowOffset!

raiseConsole
	| transcript |
	transcript := self class defaultTranscript.
	transcript ifNotNil: [transcript view setFocus]!

updateCaption
	self caption: 'Jadeite Login Version: ', self class jadeiteVersionString! !
!JadeiteLoginShell categoriesForMethods!
additionalAccelerators!accessing!public! !
basicCaption!accessing!public! !
fillVersionList!public!version list! !
invalidateLoginButton!public! !
librariesSupportingRowanV30!gci!private!version list! !
login!public! !
onViewClosed!event handlers!public! !
openGitHubJadeiteProject!public! !
openGitHubRowanProject!public! !
placeholderFor:version:libraryName:!gci!private!version list! !
placeholdersForNewSharedLibraries!gci!private!version list! !
postLogoutActions!public! !
postShellLogin:!public! !
raiseConsole!menu handlers!public! !
updateCaption!public! !
!

!JadeiteLoginShell class methodsFor!

addToDevelopmentTools
"
	RowanLoginShell addToDevelopmentTools.
	Smalltalk developmentSystem removeSystemFolderIconNamed: RowanLoginShell toolsFolderIcon description.
"
	Smalltalk developmentSystem addAdditionalToolsFolderIcon: self toolsFolderIcon.
!

defaultTranscript
	^JadeiteTranscript allInstances
		detect: [:trans | trans gciSession = GciSession current and: [trans view class ~= DeafObject]]
		ifNone: []!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1041 911 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 10 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409289036 131137 592 nil 480 nil 7 nil nil nil 592 480 8 1586015616 170 192 8 #() 170 192 34 10 39735 1246790 1 ##(Smalltalk.ToolbarBitmapButton) 592 1 1180998 4 ##(Smalltalk.CommandDescription) #editDelete 8 'Delete' 1 1 nil 39735 395334 3 ##(Smalltalk.Bitmap) 1 true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'EditBar.bmp' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil nil 7 498 1 1 11 39731 738 592 1 770 #editCopy 8 'Copy' 1 1 nil 39731 832 3 39737 738 592 1 770 #editUndo 8 'Undo' 1 1 nil 39737 832 7 39733 738 592 1 770 #editPaste 8 'Paste' 1 1 nil 39733 832 5 39729 738 592 1 770 #editCut 8 'Cut' 1 1 nil 39729 832 1 34 6 1104 960 1056 752 1008 1049158 1 ##(Smalltalk.ToolbarSeparator) 592 1 nil nil 1 nil 498 33 33 498 45 45 nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 151 1 498 241 51 592 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 75 0 0 0 0 0 0 0 195 0 0 0 25 0 0 0] 8 #() 498 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedPreviousRight 1 1490 #fixedViewLeft 241 1490 #fixedParentTop 1 1490 #fixedViewTop 51 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1140853580 131137 1568 nil 480 nil 519 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 498 193 193 nil 1568 480 8 1586015616 170 192 688 170 192 34 4 39739 1246790 1 ##(Smalltalk.ToolbarSystemButton) 1568 1 770 #getHelpOn 8 'Get help on widget' 1 1 nil 39739 1 23 39741 738 1568 1 770 #openHelp 8 'Jade Help' 1 1 nil 39741 818 nil true 864 8 'Tools.bmp' 912 nil 7 498 1857 33 71 34 2 1808 1856 nil nil 1 nil 498 33 33 498 45 45 nil 656198 1 ##(Smalltalk.FlowLayout) 1 1 1 1234 138 144 34 1 1298 #createAt:extent: 34 2 498 391 1 498 619 51 1568 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 0 0 0 0 248 1 0 0 25 0 0 0] 8 #() 1440 nil 27 1458 1504 1 1490 #fixedParentRight 1 1536 1 1552 51 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409289036 131137 2224 nil 480 nil 7 nil nil nil 2224 480 8 1586015616 170 192 688 170 192 34 6 39727 1115206 1 ##(Smalltalk.ToolbarIconButton) 2224 1 770 #fileSave 8 'Save' 1 1 263494 3 ##(Smalltalk.Icon) nil true 864 8 'FileSave.ico' 912 39727 39725 2354 2224 1 770 #fileOpen 8 'Open' 1 1 2418 nil true 864 8 'FileOpen.ico' 912 39725 39723 2354 2224 1 770 #fileNew 8 'New' 1 1 2418 nil true 864 8 'DocumentShell.ico' nil 39723 34 4 2544 2464 2368 1170 2224 1 nil nil 1 nil 498 33 33 498 45 45 nil nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 498 1 1 498 151 51 2224 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 75 0 0 0 25 0 0 0] 8 #() 1440 nil 27 1458 1490 #fixedParentLeft 1 1520 151 1536 1 1552 51 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 2880 nil 480 nil 7 nil nil nil 2880 656710 1 ##(Smalltalk.CardLayout) 138 144 34 2 721414 ##(Smalltalk.Association) 8 'Basic' 410 ##(Smalltalk.ContainerView) 34 15 nil 2880 34 2 8 1140850688 131073 3056 nil nil nil 7 nil nil nil 3056 530 170 176 34 24 410 ##(Smalltalk.StaticText) 34 16 nil 3056 34 2 8 1140850944 1 3168 nil nil nil 7 nil nil nil 3168 nil 8 1585904832 852486 ##(Smalltalk.NullConverter) nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 11 21 498 441 61 3168 1298 #text: 34 1 8 'GemStone/Smalltalk Version:' 3168 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 10 0 0 0 225 0 0 0 40 0 0 0] 8 #() 1440 nil 27 1458 2864 11 1520 441 1536 21 1536 81 410 ##(Smalltalk.StaticText) 34 16 nil 3056 34 2 8 1140850944 1 3504 nil nil nil 7 nil nil nil 3504 nil 8 1585904832 3250 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 11 421 498 441 61 3504 1298 #text: 34 1 8 'GemStone Password:' 3504 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 210 0 0 0 225 0 0 0 240 0 0 0] 8 #() 1440 nil 27 1458 2864 11 1520 441 1490 #fixedPreviousBottom 21 3824 81 410 ##(Smalltalk.TextEdit) 34 16 nil 3056 34 2 8 1140916352 1025 3840 nil 480 nil 7 nil nil nil 3840 nil 8 1586048432 3250 nil nil 1 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 461 101 498 523 61 3840 1298 #setMarginWidths: 34 1 8 #(3 3) 3840 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 230 0 0 0 50 0 0 0 235 1 0 0 80 0 0 0] 8 #() 1440 nil 27 1458 1504 11 2208 -9 1490 #fixedPreviousTop 1 3824 1 410 ##(Smalltalk.StaticText) 34 16 nil 3056 34 2 8 1140850944 1 4176 nil nil nil 7 nil nil nil 4176 nil 8 1585904832 3250 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 11 261 498 441 61 4176 1298 #text: 34 1 8 'Stone Name:' 4176 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 130 0 0 0 225 0 0 0 160 0 0 0] 8 #() 1440 nil 27 1458 2864 11 1520 441 3824 21 3824 81 410 ##(Smalltalk.TextEdit) 34 16 nil 3056 34 2 8 1140916352 1025 4496 nil 480 nil 7 nil nil nil 4496 nil 8 1586048432 3250 nil nil 1 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 461 341 498 523 61 4496 1298 #setMarginWidths: 34 1 8 #(3 3) 4496 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 230 0 0 0 170 0 0 0 235 1 0 0 200 0 0 0] 8 #() 1440 nil 27 1458 1504 11 2208 -9 4160 1 3824 1 410 ##(Smalltalk.ComboBox) 34 17 nil 3056 34 2 8 1144063491 1025 4816 590662 2 ##(Smalltalk.ListModel) 138 144 688 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 nil nil nil 4816 nil 8 1585848416 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 ##(Smalltalk.Message) 8 'doIt' 8 '[:libClass | libClass displayName]' 8 #[30 105 226 0 106] #displayName 4992 7 257 nil 8 #() 401 1234 138 144 34 1 1298 #createAt:extent: 34 2 498 461 21 498 523 51 4816 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 230 0 0 0 10 0 0 0 235 1 0 0 35 0 0 0] 8 #() 1440 nil 27 1458 1504 11 2208 -9 4160 1 3824 1 410 ##(Smalltalk.StaticText) 34 16 nil 3056 34 2 8 1140850944 1 5280 nil nil nil 7 nil nil nil 5280 nil 8 1585904832 3250 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 11 181 498 441 61 5280 1298 #text: 34 1 8 'NetLDI Service Name or Port:' 5280 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 90 0 0 0 225 0 0 0 120 0 0 0] 8 #() 1440 nil 27 1458 2864 11 1520 441 3824 21 3824 81 410 ##(Smalltalk.StaticText) 34 16 nil 3056 34 2 8 1140850944 1 5600 nil nil nil 7 nil nil nil 5600 nil 8 1585904832 3250 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 11 341 498 441 61 5600 1298 #text: 34 1 8 'GemStone User ID:' 5600 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 170 0 0 0 225 0 0 0 200 0 0 0] 8 #() 1440 nil 27 1458 2864 11 1520 441 3824 21 3824 81 410 ##(Smalltalk.TextEdit) 34 16 nil 3056 34 2 8 1140916352 1025 5920 nil 480 nil 7 nil nil nil 5920 nil 8 1586048432 3250 nil nil 1 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 461 261 498 523 61 5920 1298 #setMarginWidths: 34 1 8 #(3 3) 5920 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 230 0 0 0 130 0 0 0 235 1 0 0 160 0 0 0] 8 #() 1440 nil 27 1458 1504 11 2208 -9 4160 1 3824 1 410 ##(Smalltalk.TextEdit) 34 16 nil 3056 34 2 8 1140916384 1025 6240 nil 480 nil 7 nil nil nil 6240 nil 8 1586048432 3250 nil nil 1 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 461 421 498 523 61 6240 1298 #setMarginWidths: 34 1 8 #(3 3) 6240 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 230 0 0 0 210 0 0 0 235 1 0 0 240 0 0 0] 8 #() 1440 nil 27 1458 1504 11 2208 -9 4160 1 3824 1 410 ##(Smalltalk.StaticText) 34 16 nil 3056 34 2 8 1140850944 1 6560 nil nil nil 7 nil nil nil 6560 nil 8 1585904832 3250 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 11 101 498 441 61 6560 1298 #text: 34 1 8 'RPC Gem Host Name or IP:' 6560 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 50 0 0 0 225 0 0 0 80 0 0 0] 8 #() 1440 nil 27 1458 2864 11 1520 441 3824 21 3824 81 410 ##(Smalltalk.TextEdit) 34 16 nil 3056 34 2 8 1140916352 1025 6880 nil 480 nil 7 nil nil nil 6880 nil 8 1586048432 3250 nil nil 1 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 461 181 498 523 61 6880 1298 #setMarginWidths: 34 1 8 #(3 3) 6880 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 230 0 0 0 90 0 0 0 235 1 0 0 120 0 0 0] 8 #() 1440 nil 27 1458 1504 11 2208 -9 4160 1 3824 1 170 192 34 12 3840 8 'gemHost' 4496 8 'userID' 6240 8 'password' 4816 8 'versionList' 6880 8 'gemService' 5920 8 'stoneName' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 498 9 53 498 993 597 3056 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 244 1 0 0 68 1 0 0] 34 12 3168 4816 6560 3840 5280 6880 4176 5920 5600 4496 3504 6240 1440 nil 27 3010 8 'Advanced' 410 ##(Smalltalk.ContainerView) 34 15 nil 2880 34 2 8 1140850688 131073 7520 nil nil nil 5 nil nil nil 7520 530 170 176 34 22 410 ##(Smalltalk.StaticText) 34 16 nil 7520 34 2 8 1140850944 1 7632 nil nil nil 5 nil nil nil 7632 nil 8 1585904832 3250 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 321 281 498 161 51 7632 1298 #text: 34 1 8 'OS User ID:' 7632 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 160 0 0 0 140 0 0 0 240 0 0 0 165 0 0 0] 8 #() 1440 nil 27 1458 1504 11 1520 161 4160 1 4160 51 410 ##(Smalltalk.TextEdit) 34 16 nil 7520 34 2 8 1140916352 1025 7952 nil 480 nil 5 nil nil nil 7952 nil 8 1586048432 3250 nil nil 1 1234 138 144 34 3 1298 #createAt:extent: 34 2 498 321 181 498 503 61 7952 1298 #text: 34 1 8 'gemnetobject' 7952 1298 #setMarginWidths: 34 1 8 #(3 3) 7952 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 160 0 0 0 90 0 0 0 155 1 0 0 120 0 0 0] 8 #() 1440 nil 27 1458 1504 11 2208 -9 4160 1 3824 1 410 ##(Smalltalk.TextEdit) 34 16 nil 7520 34 2 8 1140916352 1025 8320 nil 480 nil 5 nil nil nil 8320 nil 8 1586048432 3250 nil nil 1 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 491 281 498 333 51 8320 1298 #setMarginWidths: 34 1 8 #(3 3) 8320 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 245 0 0 0 140 0 0 0 155 1 0 0 165 0 0 0] 8 #() 1440 nil 27 1458 1504 11 2208 -9 4160 1 3824 1 410 ##(Smalltalk.PushButton) 34 20 nil 7520 34 2 8 1140924416 1 8640 nil nil nil 5 nil nil nil 8640 nil 8 1586056624 770 #debugGCI 8 'Debug GCI' 1 1 nil nil false nil nil nil 1234 138 144 34 3 1298 #createAt:extent: 34 2 498 11 21 498 201 51 8640 1298 #isEnabled: 8 #(false) 8640 1298 #text: 34 1 8 'Debug GCI' 8640 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 10 0 0 0 105 0 0 0 35 0 0 0] 8 #() 1440 nil 29 1458 2864 11 1520 201 1536 21 1536 71 410 ##(Smalltalk.ContainerView) 34 15 nil 7520 34 2 8 1409286144 393217 9008 nil 480 nil 5 nil nil nil 9008 656390 ##(Smalltalk.GridLayout) 5 3 11 11 170 192 34 4 410 ##(Smalltalk.RadioButton) 34 16 nil 9008 34 2 8 1141055497 1 9136 721990 2 ##(Smalltalk.ValueHolder) nil nil 1376774 ##(Smalltalk.PluggableSearchPolicy) 459270 ##(Smalltalk.Message) #= 8 #() 9266 #hash 8 #() false 480 nil 5 nil nil nil 9136 nil 8 1586056624 3250 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 1 1 498 297 55 9136 1298 #text: 34 1 8 'NetLDI Guest' 9136 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 148 0 0 0 27 0 0 0] 8 #() 1440 nil 27 8 'guest' 410 ##(Smalltalk.RadioButton) 34 16 nil 9008 34 2 8 1140924425 1 9600 9202 nil nil 9234 9266 #= 8 #() 9266 #hash 8 #() false 480 nil 5 nil nil nil 9600 nil 8 1586056624 3250 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 1 65 498 297 53 9600 1298 #text: 34 1 8 'Native OS User' 9600 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 32 0 0 0 148 0 0 0 58 0 0 0] 8 #() 1440 nil 27 8 'member' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 498 11 281 498 301 121 9008 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 140 0 0 0 155 0 0 0 200 0 0 0] 34 2 9136 9600 1440 nil 27 1458 2864 11 1520 301 3824 41 3824 161 410 ##(Smalltalk.StaticText) 34 16 nil 7520 34 2 8 1140850944 1 10192 nil nil nil 5 nil nil nil 10192 nil 8 1585904832 3250 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 11 91 498 301 61 10192 1298 #text: 34 1 8 'Stone Host (from Gem):' 10192 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 45 0 0 0 155 0 0 0 75 0 0 0] 8 #() 1440 nil 27 1458 2864 11 1520 301 3824 21 3824 81 410 ##(Smalltalk.TextEdit) 34 16 nil 7520 34 2 8 1140916352 1025 10512 nil 480 nil 5 nil nil nil 10512 nil 8 1586048432 3250 nil nil 1 1234 138 144 34 4 1298 #createAt:extent: 34 2 498 321 91 498 503 61 10512 1298 #text: 34 1 8 'localhost' 10512 1298 #selectionRange: 34 1 525062 ##(Smalltalk.Interval) 3 19 3 10512 1298 #setMarginWidths: 34 1 8 #(3 3) 10512 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 160 0 0 0 45 0 0 0 155 1 0 0 75 0 0 0] 8 #() 1440 nil 27 1458 1504 11 2208 -9 4160 1 3824 1 410 ##(Smalltalk.TextEdit) 34 16 nil 7520 34 2 8 1140916384 1025 10944 nil 480 nil 5 nil nil nil 10944 nil 8 1586048432 3250 nil nil 1 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 491 351 498 333 51 10944 1298 #setMarginWidths: 34 1 8 #(3 3) 10944 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 245 0 0 0 175 0 0 0 155 1 0 0 200 0 0 0] 8 #() 1440 nil 27 1458 1504 11 2208 -9 4160 1 3824 1 410 ##(Smalltalk.StaticText) 34 16 nil 7520 34 2 8 1140850944 1 11264 nil nil nil 5 nil nil nil 11264 nil 8 1585904832 3250 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 321 351 498 161 51 11264 1298 #text: 34 1 8 'Password:' 11264 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 160 0 0 0 175 0 0 0 240 0 0 0 200 0 0 0] 8 #() 1440 nil 27 1458 1490 #fixedPreviousLeft -169 1520 161 4160 71 4160 121 410 ##(Smalltalk.StaticPath) 34 17 nil 7520 34 2 8 1140850944 1 11600 nil nil nil 5 nil nil nil 11600 nil 8 1585904832 3250 nil nil nil 8 'XXX' 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 221 21 498 603 51 11600 1298 #text: 34 1 11696 11600 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 110 0 0 0 10 0 0 0 155 1 0 0 35 0 0 0] 8 #() 1440 nil 27 1458 1504 11 2208 -9 4160 1 3824 1 410 ##(Smalltalk.StaticText) 34 16 nil 7520 34 2 8 1140850944 1 11920 nil nil nil 5 nil nil nil 11920 nil 8 1585904832 3250 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 11 181 498 301 61 11920 1298 #text: 34 1 8 'NetLDI Task Name:' 11920 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 90 0 0 0 155 0 0 0 120 0 0 0] 8 #() 1440 nil 27 1458 2864 11 11584 -9 3824 31 3824 91 170 192 34 12 7952 8 'gemTask' 8320 8 'hostUserID' 9008 8 'loginType' 10512 8 'stoneHost' 10944 8 'hostPassword' 11600 8 'debugPath' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 498 9 53 498 993 597 7520 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 244 1 0 0 68 1 0 0] 34 11 8640 11600 10192 10512 11920 7952 9008 7632 8320 11264 10944 1440 nil 27 3056 nil nil nil 170 192 34 4 7520 8 'Advanced' 3056 8 'Basic' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 2880 34 2 8 1140916736 1 12592 4882 138 144 34 2 3040 7504 nil 4944 nil nil 1 nil nil nil 12592 nil 8 1585762048 4978 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 12720 7 257 nil 4978 0 nil 12738 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 12784 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #noIcons nil nil nil nil nil 1234 138 144 34 3 1298 #createAt:extent: 34 2 498 1 1 498 1009 657 12592 1298 #setSingleSelection: 8 #(1) 12592 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 12592 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 248 1 0 0 72 1 0 0] 8 #() 1440 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 498 1 51 498 1009 657 2880 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 248 1 0 0 97 1 0 0] 34 3 3056 7520 12592 1440 nil 27 1458 2864 1 2208 1 1536 51 1490 #fixedParentBottom -79 410 ##(Smalltalk.PushButton) 34 20 nil 416 34 2 8 1140924416 1 13280 nil nil nil 7 nil nil nil 13280 nil 8 1586056624 770 #login 8 'Login' 1 1 nil nil true nil nil nil 1234 138 144 34 3 1298 #createAt:extent: 34 2 498 1 707 498 1009 81 13280 1298 #isEnabled: 8 #(false) 13280 1298 #text: 34 1 8 'Login' 13280 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 97 1 0 0 248 1 0 0 137 1 0 0] 8 #() 1440 nil 29 1458 2864 1 2208 1 13264 -79 13264 1 170 192 34 10 592 8 'Edit Tools' 1568 8 'Other Tools' 2224 8 'File Tools' 2880 8 'Tabs' 13280 8 'loginButton' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 265030 4 ##(Smalltalk.Menu) nil true 34 7 984134 2 ##(Smalltalk.CommandMenuItem) 1 770 #fileNew 8 '&New' 9373 1 nil nil nil 13858 1 770 #fileOpen 8 '&Open...' 9375 1 nil nil nil 13858 1 770 #fileSave 8 '&Save' 9383 1 nil nil nil 13858 1 770 #fileSaveAs 8 'Save &As...' 1 1 nil nil nil 13858 1 770 #fileRevert 8 '&Revert' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 13858 1 770 #exit 8 'E&xit' 17639 1 nil nil nil 8 '&File' nil 134217729 nil nil 39755 nil nil 13810 nil true 34 9 13858 1 770 #editUndo 8 '&Undo' 9397 1 nil nil nil 13858 1 770 #editRedo 8 '&Redo' 9395 1 nil nil nil 14114 4097 13858 1 770 #editCut 8 'Cu&t' 9393 1 nil nil nil 13858 1 770 #editCopy 8 '&Copy' 9351 1 nil nil nil 13858 1 770 #editPaste 8 '&Paste' 9389 1 nil nil nil 13858 1 770 #editDelete 8 'De&lete' 1629 1 nil nil nil 14114 4097 13858 1 770 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 8 '&Edit' nil 134217729 nil nil 39771 nil nil 13810 nil true 34 5 13858 1 770 #openHomePage 8 '&GemStone Home Page' 1025 1 nil nil nil 13858 1 770 #openGitHubJadeiteProject 8 '&Jadiete GitHub Project' 1025 1 nil nil nil 13858 1 770 #openGitHubRowanProject 8 '&Rowan GitHub Project' 1025 1 nil nil nil 14114 4097 13858 1 770 #aboutJadeite 8 '&About Jadeite' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 39781 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 22449 2418 nil true 864 8 'icons\GS32.ico' nil 2418 nil true 864 8 'icons\GS16.ico' nil nil nil 1 nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 6455 21 498 1041 911 416 1298 #text: 34 1 8 'Jadeite Login' 416 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 155 12 0 0 10 0 0 0 163 14 0 0 209 1 0 0] 34 5 2224 592 1568 13280 2880 1440 nil 27 )!

toolsFolderIcon

	^SmalltalkSystemIcon 
		icon: self toolsIcon
		description: 'Jadeite Login for GemStone/64'
		openBlock: [:folder :item | self show].
! !
!JadeiteLoginShell class categoriesForMethods!
addToDevelopmentTools!Development Image!public! !
defaultTranscript!public! !
resource_Default_view!public!resources-views! !
toolsFolderIcon!public! !
!

