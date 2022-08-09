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
	versionListPresenter list: list!

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
			MessageBox errorMsg: ex description caption: 'Jadeite Login Error'.
			SessionManager current pause.
			GciSession current: nil.
			^nil].
	self postShellLogin: session!

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


	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 801 651 551 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 10 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409289036 131137 608 nil 466 8 4278190080 nil 7 nil nil nil 608 466 688 8 4294905159 170 192 8 #() 170 192 34 6 19071 1115910 ##(Smalltalk.ToolbarIconButton) 19071 nil 608 1 1180998 4 ##(Smalltalk.CommandDescription) #fileOpen 8 'Open' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'FileOpen.ico' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil 395334 3 ##(Smalltalk.Bitmap) nil true nil nil nil nil 3 514 33 33 1 19073 802 19073 nil 608 1 834 #fileSave 8 'Save' 1 1 882 nil true 928 8 'FileSave.ico' 976 1010 nil true nil nil nil nil 3 514 33 33 1 19069 802 19069 nil 608 1 834 #fileNew 8 'New' 1 1 882 nil true 928 8 'DocumentShell.ico' nil 1010 nil true nil nil nil nil 3 514 33 33 1 34 4 1168 816 1056 1050118 ##(Smalltalk.ToolbarSeparator) nil nil 608 3 nil 1 170 176 34 6 1024 3 1136 5 1248 1 nil 1 nil 514 33 33 514 45 45 nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 1 1 514 151 51 608 1458 #updateSizePosted 752 608 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 75 0 0 0 25 0 0 0] 8 #() 514 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 1666 #fixedViewLeft 151 1666 #fixedParentTop 1 1666 #fixedViewTop 51 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409289036 131137 1744 nil 466 8 4278190080 nil 7 nil nil nil 1744 466 1824 8 4294905159 170 192 752 170 192 34 10 19075 853766 ##(Smalltalk.ToolbarButton) 19075 nil 1744 1 834 #editCut 8 'Cut' 1 1 nil 1010 nil true 928 8 'EditBar.bmp' 976 nil 7 514 193 33 1 19077 1922 19077 nil 1744 1 834 #editCopy 8 'Copy' 1 1 nil 1984 3 19079 1922 19079 nil 1744 1 834 #editPaste 8 'Paste' 1 1 nil 1984 5 19081 1922 19081 nil 1744 1 834 #editDelete 8 'Delete' 1 1 nil 1984 11 19083 1922 19083 nil 1744 1 834 #editUndo 8 'Undo' 1 1 nil 1984 7 34 6 1936 2032 2080 2128 2176 1298 nil nil 1744 3 nil 1 170 176 34 2 1984 1 nil 1 nil 514 33 33 514 45 45 nil nil 1394 138 144 34 2 1458 #createAt:extent: 34 2 514 151 1 514 241 51 1744 1458 #updateSizePosted 752 1744 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 75 0 0 0 0 0 0 0 195 0 0 0 25 0 0 0] 8 #() 1616 nil 27 1634 1666 #fixedPreviousRight 1 1696 241 1712 1 1728 51 410 ##(Smalltalk.PushButton) 34 20 nil 416 34 2 8 1140924416 1 2528 nil nil nil 7 nil nil nil 2528 nil 8 4294904111 834 #login 8 'Login' 1 1 nil nil true nil nil nil 1394 138 144 34 3 1458 #createAt:extent: 34 2 514 1 473 514 769 61 2528 1458 #isEnabled: 8 #(false) 2528 1458 #text: 34 1 8 'Login' 2528 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 236 0 0 0 128 1 0 0 10 1 0 0] 8 #() 1616 nil 29 1634 1680 1 1666 #fixedParentRight 1 1666 #fixedParentBottom -59 1728 61 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1140853580 131137 2928 nil 466 8 4278190080 nil 519 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 514 193 193 nil 2928 466 3008 8 4294905159 170 192 752 170 192 34 4 19085 1246982 ##(Smalltalk.ToolbarSystemButton) 19085 nil 2928 1 834 #getHelpOn 8 'Get help on widget' 1 1 nil 1 23 19087 1922 19087 nil 2928 1 834 #openHelp 8 'Jade Help' 1 1 nil 1010 nil true 928 8 'Tools.bmp' 976 nil 7 514 1857 33 71 34 2 3216 3264 170 176 34 4 1 1 3312 31 nil 1 nil 514 33 33 514 45 45 nil 656198 1 ##(Smalltalk.FlowLayout) 1 1 1 1394 138 144 34 2 1458 #createAt:extent: 34 2 514 391 1 514 379 51 2928 1458 #updateSizePosted 752 2928 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 0 0 0 0 128 1 0 0 25 0 0 0] 8 #() 1616 nil 27 1634 2512 1 2896 1 1712 1 1728 51 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 3664 nil 466 8 4278190080 nil 7 nil nil nil 3664 655878 ##(Smalltalk.CardLayout) 138 144 34 2 721414 ##(Smalltalk.Association) 8 'Basic' 410 ##(Smalltalk.ContainerView) 34 15 nil 3664 34 2 8 1140850688 131073 3872 nil nil nil 7 nil nil nil 3872 546 170 176 34 24 410 ##(Smalltalk.StaticText) 34 16 nil 3872 34 2 8 1140850944 1 3984 nil nil nil 7 nil nil nil 3984 nil 8 1604582592 852486 ##(Smalltalk.NullConverter) nil nil nil 1394 138 144 34 2 1458 #createAt:extent: 34 2 514 11 113 514 371 31 3984 1458 #text: 34 1 8 'NetLDI Service Name or Port:' 3984 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 56 0 0 0 190 0 0 0 71 0 0 0] 8 #() 1616 nil 27 1634 1680 11 1696 371 1666 #fixedPreviousBottom 3 1728 31 410 ##(Smalltalk.TextEdit) 34 16 nil 3872 34 2 8 1140916352 1025 4336 nil 466 8 4278190080 nil 7 nil nil nil 4336 nil 8 4294905209 4066 nil nil 1 1394 138 144 34 2 1458 #createAt:extent: 34 2 514 391 113 514 353 45 4336 1458 #setMarginWidths: 34 1 8 #(3 3) 4336 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 56 0 0 0 115 1 0 0 78 0 0 0] 8 #() 1616 nil 27 1634 2512 11 2896 -9 1666 #fixedPreviousTop 1 1728 45 410 ##(Smalltalk.TextEdit) 34 16 nil 3872 34 2 8 1140916352 1025 4704 nil 466 4416 nil 7 nil nil nil 4704 nil 8 4294905209 4066 nil nil 1 1394 138 144 34 2 1458 #createAt:extent: 34 2 514 391 67 514 353 45 4704 1458 #setMarginWidths: 34 1 8 #(3 3) 4704 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 33 0 0 0 115 1 0 0 55 0 0 0] 8 #() 1616 nil 27 1634 2512 11 2896 -9 4688 1 1728 45 410 ##(Smalltalk.TextEdit) 34 16 nil 3872 34 2 8 1140916352 1025 5040 nil 466 4416 nil 7 nil nil nil 5040 nil 8 4294905209 4066 nil nil 1 1394 138 144 34 2 1458 #createAt:extent: 34 2 514 391 213 514 353 45 5040 1458 #setMarginWidths: 34 1 8 #(3 3) 5040 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 106 0 0 0 115 1 0 0 128 0 0 0] 8 #() 1616 nil 27 1634 2512 11 2896 -9 4688 1 1728 45 410 ##(Smalltalk.StaticText) 34 16 nil 3872 34 2 8 1140850944 1 5376 nil nil nil 7 nil nil nil 5376 nil 8 1604582592 4066 nil nil nil 1394 138 144 34 2 1458 #createAt:extent: 34 2 514 11 259 514 371 41 5376 1458 #text: 34 1 8 'GemStone Password:' 5376 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 129 0 0 0 190 0 0 0 149 0 0 0] 8 #() 1616 nil 27 1634 1680 11 1696 371 4320 3 1728 41 410 ##(Smalltalk.TextEdit) 34 16 nil 3872 34 2 8 1140916352 1025 5696 nil 466 4416 nil 7 nil nil nil 5696 nil 8 4294905209 4066 nil nil 1 1394 138 144 34 2 1458 #createAt:extent: 34 2 514 391 167 514 353 45 5696 1458 #setMarginWidths: 34 1 8 #(3 3) 5696 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 83 0 0 0 115 1 0 0 105 0 0 0] 8 #() 1616 nil 27 1634 2512 11 2896 -9 4688 1 1728 45 410 ##(Smalltalk.ComboBox) 34 17 nil 3872 34 2 8 1144063491 1025 6032 590662 2 ##(Smalltalk.ListModel) 138 144 752 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 466 8 4278190080 nil 7 nil nil nil 6032 nil 8 4294905433 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 ##(Smalltalk.Message) 8 'doIt' 8 '[:libClass | libClass displayName]' 8 #[30 105 226 0 106] #displayName 6240 7 257 nil 752 401 1394 138 144 34 1 1458 #createAt:extent: 34 2 514 391 11 514 353 53 6032 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 5 0 0 0 115 1 0 0 31 0 0 0] 8 #() 1616 nil 27 1634 2512 11 2896 -9 1712 11 1728 47 410 ##(Smalltalk.StaticText) 34 16 nil 3872 34 2 8 1140850944 1 6512 nil nil nil 7 nil nil nil 6512 nil 8 1604582592 4066 nil nil nil 1394 138 144 34 2 1458 #createAt:extent: 34 2 514 11 67 514 371 31 6512 1458 #text: 34 1 8 'RPC Gem Host Name or IP:' 6512 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 33 0 0 0 190 0 0 0 48 0 0 0] 8 #() 1616 nil 27 1634 1680 11 1696 371 4320 11 1728 31 410 ##(Smalltalk.StaticText) 34 16 nil 3872 34 2 8 1140850944 1 6832 nil nil nil 7 nil nil nil 6832 nil 8 1604582592 4066 nil nil nil 1394 138 144 34 2 1458 #createAt:extent: 34 2 514 11 213 514 371 41 6832 1458 #text: 34 1 8 'GemStone User ID:' 6832 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 106 0 0 0 190 0 0 0 126 0 0 0] 8 #() 1616 nil 27 1634 1680 11 1696 371 4320 3 1728 41 410 ##(Smalltalk.StaticText) 34 16 nil 3872 34 2 8 1140850944 1 7152 nil nil nil 7 nil nil nil 7152 nil 8 1604582592 4066 nil nil nil 1394 138 144 34 2 1458 #createAt:extent: 34 2 514 11 21 514 371 41 7152 1458 #text: 34 1 8 'GemStone/Smalltalk Version:' 7152 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 10 0 0 0 190 0 0 0 30 0 0 0] 8 #() 1616 nil 27 1634 1680 11 1696 371 1712 21 1728 41 410 ##(Smalltalk.StaticText) 34 16 nil 3872 34 2 8 1140850944 1 7472 nil nil nil 7 nil nil nil 7472 nil 8 1604582592 4066 nil nil nil 1394 138 144 34 2 1458 #createAt:extent: 34 2 514 11 167 514 371 39 7472 1458 #text: 34 1 8 'Stone Name:' 7472 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 83 0 0 0 190 0 0 0 102 0 0 0] 8 #() 1616 nil 27 1634 1680 11 1696 371 4320 11 1728 39 410 ##(Smalltalk.TextEdit) 34 16 nil 3872 34 2 8 1140916384 1025 7792 nil 466 8 4278190080 nil 7 nil nil nil 7792 nil 8 4294905209 4066 nil nil 1 1394 138 144 34 2 1458 #createAt:extent: 34 2 514 391 259 514 353 45 7792 1458 #setMarginWidths: 34 1 8 #(3 3) 7792 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 129 0 0 0 115 1 0 0 151 0 0 0] 8 #() 1616 nil 27 1634 2512 11 2896 -9 4688 1 1728 45 170 192 34 12 5696 8 'stoneName' 4704 8 'gemHost' 4336 8 'gemService' 7792 8 'password' 6032 8 'versionList' 5040 8 'userID' nil 1394 138 144 34 1 1458 #createAt:extent: 34 2 514 9 55 514 753 361 3872 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 124 1 0 0 207 0 0 0] 34 12 7152 6032 6512 4704 3984 4336 7472 5696 6832 5040 5376 7792 1616 nil 27 3826 8 'Advanced' 410 ##(Smalltalk.ContainerView) 34 15 nil 3664 34 2 8 1140850688 131073 8464 nil nil nil 5 nil nil nil 8464 546 170 176 34 24 410 ##(Smalltalk.ContainerView) 34 15 nil 8464 34 2 8 1140850688 393217 8576 nil 466 8 4278190080 nil 5 nil nil nil 8576 656390 ##(Smalltalk.GridLayout) 3 5 1 1 170 192 34 4 410 ##(Smalltalk.RadioButton) 34 16 nil 8576 34 2 8 1140924425 1 8736 721990 2 ##(Smalltalk.ValueHolder) nil nil 1376774 ##(Smalltalk.PluggableSearchPolicy) 459270 ##(Smalltalk.Message) #= 8 #() 8866 #hash 8 #() false 466 8656 nil 5 nil nil nil 8736 nil 8 4294904111 4066 nil nil nil 1394 138 144 34 2 1458 #createAt:extent: 34 2 514 1 1 514 365 45 8736 1458 #text: 34 1 8 'RPC Gem' 8736 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 182 0 0 0 22 0 0 0] 8 #() 1616 nil 27 8 'remote' 410 ##(Smalltalk.RadioButton) 34 16 nil 8576 34 2 8 1141055497 1 9216 8802 nil nil 8834 8866 #= 8 #() 8866 #hash 8 #() false 466 8656 nil 5 nil nil nil 9216 nil 8 4294904111 4066 nil nil nil 1394 138 144 34 2 1458 #createAt:extent: 34 2 514 365 1 514 365 45 9216 1458 #text: 34 1 8 'Linked Gem (32-bit only)' 9216 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 182 0 0 0 0 0 0 0 108 1 0 0 22 0 0 0] 8 #() 1616 nil 27 8 'linked' nil 1394 138 144 34 1 1458 #createAt:extent: 34 2 514 11 257 514 733 49 8576 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 128 0 0 0 115 1 0 0 152 0 0 0] 34 2 8736 9216 1616 nil 27 1634 1680 11 2896 -9 4320 5 1728 49 410 ##(Smalltalk.StaticText) 34 16 nil 8464 34 2 8 1140850944 1 9824 nil nil nil 5 nil nil nil 9824 nil 8 1604582592 4066 nil nil nil 1394 138 144 34 2 1458 #createAt:extent: 34 2 514 11 69 514 301 41 9824 1458 #text: 34 1 8 'Stone Host (from Gem):' 9824 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 34 0 0 0 155 0 0 0 54 0 0 0] 8 #() 1616 nil 27 1634 1680 11 1696 301 4320 11 1728 41 410 ##(Smalltalk.PushButton) 34 20 nil 8464 34 2 8 1140924416 1 10144 nil nil nil 5 nil nil nil 10144 nil 8 4294904111 834 #debugGCI 8 'Debug GCI' 1 1 nil nil false nil nil nil 1394 138 144 34 3 1458 #createAt:extent: 34 2 514 11 5 514 141 51 10144 1458 #isEnabled: 8 #(false) 10144 1458 #text: 34 1 8 'Debug GCI' 10144 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 2 0 0 0 75 0 0 0 27 0 0 0] 8 #() 1616 nil 29 1634 1680 11 1696 141 4320 5 1728 51 410 ##(Smalltalk.StaticPath) 34 17 nil 8464 34 2 8 1140850944 1 10512 nil nil nil 5 nil nil nil 10512 nil 8 1604582592 4066 nil nil nil 8 'XXX' 1394 138 144 34 2 1458 #createAt:extent: 34 2 514 161 15 514 583 45 10512 1458 #text: 34 1 10608 10512 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 80 0 0 0 7 0 0 0 115 1 0 0 29 0 0 0] 8 #() 1616 nil 27 1634 1680 161 2896 -9 4688 11 1728 45 410 ##(Smalltalk.StaticText) 34 16 nil 8464 34 2 8 1140850944 1 10832 nil nil nil 5 nil nil nil 10832 nil 8 1604582592 4066 nil nil nil 1394 138 144 34 2 1458 #createAt:extent: 34 2 514 11 115 514 301 31 10832 1458 #text: 34 1 8 'NetLDI Task Name:' 10832 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 57 0 0 0 155 0 0 0 72 0 0 0] 8 #() 1616 nil 27 1634 1680 11 1696 301 4320 3 1728 31 410 ##(Smalltalk.ContainerView) 34 15 nil 8464 34 2 8 1409286144 393217 11152 nil 466 8 4278190080 nil 5 nil nil nil 11152 8674 1 3 1 1 170 192 34 4 410 ##(Smalltalk.RadioButton) 34 16 nil 11152 34 2 8 1140924425 1 11296 8802 nil nil 8834 8866 #= 8 #() 8866 #hash 8 #() false 466 11232 nil 5 nil nil nil 11296 nil 8 4294904111 4066 nil nil nil 1394 138 144 34 2 1458 #createAt:extent: 34 2 514 1 39 514 297 39 11296 1458 #text: 34 1 8 'Native OS User' 11296 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 19 0 0 0 148 0 0 0 38 0 0 0] 8 #() 1616 nil 27 8 'member' 410 ##(Smalltalk.RadioButton) 34 16 nil 11152 34 2 8 1141055497 1 11728 8802 nil nil 8834 8866 #= 8 #() 8866 #hash 8 #() false 466 11232 nil 5 nil nil nil 11728 nil 8 4294904111 4066 nil nil nil 1394 138 144 34 2 1458 #createAt:extent: 34 2 514 1 1 514 297 39 11728 1458 #text: 34 1 8 'NetLDI Guest' 11728 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 148 0 0 0 19 0 0 0] 8 #() 1616 nil 27 8 'guest' nil 1394 138 144 34 1 1458 #createAt:extent: 34 2 514 11 163 514 301 81 11152 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 81 0 0 0 155 0 0 0 121 0 0 0] 34 2 11728 11296 1616 nil 27 1634 1680 11 1696 301 4320 5 1728 81 410 ##(Smalltalk.TextEdit) 34 16 nil 8464 34 2 8 1140916352 1025 12336 nil 466 8 4278190080 nil 5 nil nil nil 12336 nil 8 4294905209 4066 nil nil 1 1394 138 144 34 2 1458 #createAt:extent: 34 2 514 491 163 514 253 45 12336 1458 #setMarginWidths: 34 1 8 #(3 3) 12336 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 245 0 0 0 81 0 0 0 115 1 0 0 103 0 0 0] 8 #() 1616 nil 27 1634 2512 11 2896 -9 4688 1 1728 45 410 ##(Smalltalk.TextEdit) 34 16 nil 8464 34 2 8 1140916384 1025 12688 nil 466 8 4278190080 nil 5 nil nil nil 12688 nil 8 4294905209 4066 nil nil 1 1394 138 144 34 2 1458 #createAt:extent: 34 2 514 491 209 514 253 45 12688 1458 #setMarginWidths: 34 1 8 #(3 3) 12688 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 245 0 0 0 104 0 0 0 115 1 0 0 126 0 0 0] 8 #() 1616 nil 27 1634 2512 11 2896 -9 4688 1 1728 45 410 ##(Smalltalk.StaticText) 34 16 nil 8464 34 2 8 1140850944 1 13040 nil nil nil 5 nil nil nil 13040 nil 8 1604582592 4066 nil nil nil 1394 138 144 34 2 1458 #createAt:extent: 34 2 514 321 209 514 161 41 13040 1458 #text: 34 1 8 'Password:' 13040 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 160 0 0 0 104 0 0 0 240 0 0 0 124 0 0 0] 8 #() 1616 nil 27 1634 1666 #fixedPreviousLeft -169 1696 161 4320 3 1728 41 410 ##(Smalltalk.StaticText) 34 16 nil 8464 34 2 8 1140850944 1 13376 nil nil nil 5 nil nil nil 13376 nil 8 1604582592 4066 nil nil nil 1394 138 144 34 2 1458 #createAt:extent: 34 2 514 321 163 514 161 41 13376 1458 #text: 34 1 8 'OS User ID:' 13376 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 160 0 0 0 81 0 0 0 240 0 0 0 101 0 0 0] 8 #() 1616 nil 27 1634 2512 11 1696 161 4688 1 1728 41 410 ##(Smalltalk.TextEdit) 34 16 nil 8464 34 2 8 1140916352 1025 13696 nil 466 4416 nil 5 nil nil nil 13696 nil 8 4294905209 4066 nil nil 1 1394 138 144 34 3 1458 #createAt:extent: 34 2 514 321 115 514 423 45 13696 1458 #text: 34 1 8 'gemnetobject' 13696 1458 #setMarginWidths: 34 1 8 #(3 3) 13696 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 160 0 0 0 57 0 0 0 115 1 0 0 79 0 0 0] 8 #() 1616 nil 27 1634 2512 11 2896 -9 4688 1 1728 45 410 ##(Smalltalk.TextEdit) 34 16 nil 8464 34 2 8 1140916352 1025 14080 nil 466 4416 nil 5 nil nil nil 14080 nil 8 4294905209 4066 nil nil 1 1394 138 144 34 4 1458 #createAt:extent: 34 2 514 321 69 514 423 45 14080 1458 #text: 34 1 8 'localhost' 14080 1458 #selectionRange: 34 1 525062 ##(Smalltalk.Interval) 3 19 3 14080 1458 #setMarginWidths: 34 1 8 #(3 3) 14080 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 160 0 0 0 34 0 0 0 115 1 0 0 56 0 0 0] 8 #() 1616 nil 27 1634 2512 11 2896 -9 4688 1 1728 45 170 192 34 14 13696 8 'gemTask' 12336 8 'hostUserID' 12688 8 'hostPassword' 11152 8 'loginType' 8576 8 'gemType' 14080 8 'stoneHost' 10512 8 'debugPath' nil 1394 138 144 34 1 1458 #createAt:extent: 34 2 514 9 55 514 753 361 8464 1554 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 27 0 0 0 124 1 0 0 207 0 0 0] 34 12 10144 10512 9824 14080 10832 13696 11152 13376 12336 13040 12688 8576 1616 nil 27 3872 170 192 34 4 8464 8 'Advanced' 3872 8 'Basic' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 3664 34 2 8 1140916736 1 14896 6098 138 144 34 2 3856 8448 nil 6160 nil nil 1 nil nil nil 14896 nil 8 4294905415 6226 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 15024 7 257 nil 6226 0 nil 15042 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 15088 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #noIcons nil nil nil nil nil 1394 138 144 34 3 1458 #createAt:extent: 34 2 514 1 1 514 769 423 14896 1458 #basicSelectionsByIndex: 34 1 8 #(1) 14896 1458 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 14896 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 128 1 0 0 211 0 0 0] 8 #() 1616 nil 27 1394 138 144 34 1 1458 #createAt:extent: 34 2 514 1 51 514 769 423 3664 1554 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 128 1 0 0 236 0 0 0] 34 3 3872 8464 14896 1616 nil 27 1634 1680 1 2896 1 1712 51 2912 -59 170 192 34 10 608 8 'File Tools' 1744 8 'Edit Tools' 2528 8 'loginButton' 2928 8 'Other Tools' 3664 8 'Tabs' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 265030 4 ##(Smalltalk.Menu) nil true 34 7 984134 2 ##(Smalltalk.CommandMenuItem) 1 834 #fileNew 8 '&New' 9373 1 nil nil nil 15794 1 834 #fileOpen 8 '&Open...' 9375 1 nil nil nil 15794 1 834 #fileSave 8 '&Save' 9383 1 nil nil nil 15794 1 834 #fileSaveAs 8 'Save &As...' 1 1 nil nil nil 15794 1 834 #fileRevert 8 '&Revert' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 15794 1 834 #exit 8 'E&xit' 17639 1 nil nil nil 8 '&File' nil 134217729 nil nil 19041 nil nil 15746 nil true 34 9 15794 1 834 #editUndo 8 '&Undo' 9397 1 nil nil nil 15794 1 834 #editRedo 8 '&Redo' 9395 1 nil nil nil 16050 4097 15794 1 834 #editCut 8 'Cu&t' 9393 1 nil nil nil 15794 1 834 #editCopy 8 '&Copy' 9351 1 nil nil nil 15794 1 834 #editPaste 8 '&Paste' 9389 1 nil nil nil 15794 1 834 #editDelete 8 'De&lete' 1629 1 nil nil nil 16050 4097 15794 1 834 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 8 '&Edit' nil 134217729 nil nil 19057 nil nil 15746 nil true 34 5 15794 1 834 #openHomePage 8 '&GemStone Home Page' 1025 1 nil nil nil 15794 1 834 #openGitHubJadeiteProject 8 '&Jadiete GitHub Project' 1025 1 nil nil nil 15794 1 834 #openGitHubRowanProject 8 '&Rowan GitHub Project' 1025 1 nil nil nil 16050 4097 15794 1 834 #aboutJadeite 8 '&About Jadeite' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 19067 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 11699 882 nil true 928 8 'icons\GS32.ico' nil 882 nil true 928 8 'icons\GS16.ico' nil nil nil 1 nil nil 1394 138 144 34 3 1458 #createAt:extent: 34 2 514 6305 21 514 801 651 416 1458 #text: 34 1 8 'Jadeite Login' 416 1458 #updateMenuBar 752 416 1554 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 80 12 0 0 10 0 0 0 224 13 0 0 79 1 0 0] 34 5 608 1744 2928 2528 3664 1616 nil 27 )!

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

