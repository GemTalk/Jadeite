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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 801 651 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 10 410 ##(Smalltalk.PushButton) 34 20 nil 416 34 2 8 1140924416 1 592 nil nil nil 7 nil nil nil 592 nil 8 1562135984 1180998 4 ##(Smalltalk.CommandDescription) #login 8 'Login' 1 1 nil nil true nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 1 473 498 769 61 592 786 #isEnabled: 8 #(false) 592 786 #text: 34 1 8 'Login' 592 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 236 0 0 0 128 1 0 0 10 1 0 0] 8 #() 498 193 193 nil 29 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 1058 #fixedParentRight 1 1058 #fixedParentBottom -59 1058 #fixedViewTop 61 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1140853580 131137 1136 nil 480 nil 519 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 498 193 193 nil 1136 480 8 1562094976 170 192 8 #() 170 192 34 4 30121 1246790 1 ##(Smalltalk.ToolbarSystemButton) 1136 1 674 #getHelpOn 8 'Get help on widget' 1 1 nil 30121 1 23 30123 1246790 1 ##(Smalltalk.ToolbarBitmapButton) 1136 1 674 #openHelp 8 'Jade Help' 1 1 nil 30123 395334 3 ##(Smalltalk.Bitmap) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'Tools.bmp' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil nil 7 498 1857 33 71 34 2 1392 1456 nil nil 1 nil 498 33 33 498 45 45 nil 656198 1 ##(Smalltalk.FlowLayout) 1 1 1 722 138 144 34 1 786 #createAt:extent: 34 2 498 391 1 498 379 51 1136 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 0 0 0 0 128 1 0 0 25 0 0 0] 8 #() 1008 nil 27 1026 1058 #fixedPreviousRight 1 1088 1 1058 #fixedParentTop 1 1120 51 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 1936 nil 480 nil 7 nil nil nil 1936 656710 1 ##(Smalltalk.CardLayout) 138 144 34 2 721414 ##(Smalltalk.Association) 8 'Basic' 410 ##(Smalltalk.ContainerView) 34 15 nil 1936 34 2 8 1140850688 131073 2112 nil nil nil 7 nil nil nil 2112 530 170 176 34 24 410 ##(Smalltalk.StaticText) 34 16 nil 2112 34 2 8 1140850944 1 2224 nil nil nil 7 nil nil nil 2224 nil 8 1561984192 852486 ##(Smalltalk.NullConverter) nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 11 21 498 371 41 2224 786 #text: 34 1 8 'GemStone/Smalltalk Version:' 2224 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 10 0 0 0 190 0 0 0 30 0 0 0] 8 #() 1008 nil 27 1026 1072 11 1058 #fixedViewLeft 371 1920 21 1120 41 410 ##(Smalltalk.ComboBox) 34 17 nil 2112 34 2 8 1144063491 1025 2576 590662 2 ##(Smalltalk.ListModel) 138 144 1328 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 nil nil nil 2576 nil 8 1561927776 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 ##(Smalltalk.Message) 8 'doIt' 8 '[:libClass | libClass displayName]' 8 #[30 105 226 0 106] #displayName 2752 7 257 nil 8 #() 401 722 138 144 34 1 786 #createAt:extent: 34 2 498 391 11 498 353 51 2576 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 5 0 0 0 115 1 0 0 30 0 0 0] 8 #() 1008 nil 27 1026 1904 11 1088 -9 1920 11 1120 47 410 ##(Smalltalk.TextEdit) 34 16 nil 2112 34 2 8 1140916384 1025 3040 nil 480 nil 7 nil nil nil 3040 nil 8 1562127792 2306 nil nil 1 722 138 144 34 2 786 #createAt:extent: 34 2 498 391 259 498 353 45 3040 786 #setMarginWidths: 34 1 8 #(3 3) 3040 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 129 0 0 0 115 1 0 0 151 0 0 0] 8 #() 1008 nil 27 1026 1904 11 1088 -9 1058 #fixedPreviousTop 1 1120 45 410 ##(Smalltalk.TextEdit) 34 16 nil 2112 34 2 8 1140916352 1025 3376 nil 480 nil 7 nil nil nil 3376 nil 8 1562127792 2306 nil nil 1 722 138 144 34 2 786 #createAt:extent: 34 2 498 391 113 498 353 45 3376 786 #setMarginWidths: 34 1 8 #(3 3) 3376 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 56 0 0 0 115 1 0 0 78 0 0 0] 8 #() 1008 nil 27 1026 1904 11 1088 -9 3360 1 1120 45 410 ##(Smalltalk.TextEdit) 34 16 nil 2112 34 2 8 1140916352 1025 3696 nil 480 nil 7 nil nil nil 3696 nil 8 1562127792 2306 nil nil 1 722 138 144 34 2 786 #createAt:extent: 34 2 498 391 213 498 353 45 3696 786 #setMarginWidths: 34 1 8 #(3 3) 3696 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 106 0 0 0 115 1 0 0 128 0 0 0] 8 #() 1008 nil 27 1026 1904 11 1088 -9 3360 1 1120 45 410 ##(Smalltalk.StaticText) 34 16 nil 2112 34 2 8 1140850944 1 4016 nil nil nil 7 nil nil nil 4016 nil 8 1561984192 2306 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 11 259 498 371 41 4016 786 #text: 34 1 8 'GemStone Password:' 4016 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 129 0 0 0 190 0 0 0 149 0 0 0] 8 #() 1008 nil 27 1026 1072 11 2560 371 1058 #fixedPreviousBottom 3 1120 41 410 ##(Smalltalk.TextEdit) 34 16 nil 2112 34 2 8 1140916352 1025 4352 nil 480 nil 7 nil nil nil 4352 nil 8 1562127792 2306 nil nil 1 722 138 144 34 2 786 #createAt:extent: 34 2 498 391 67 498 353 45 4352 786 #setMarginWidths: 34 1 8 #(3 3) 4352 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 33 0 0 0 115 1 0 0 55 0 0 0] 8 #() 1008 nil 27 1026 1904 11 1088 -9 3360 1 1120 45 410 ##(Smalltalk.StaticText) 34 16 nil 2112 34 2 8 1140850944 1 4672 nil nil nil 7 nil nil nil 4672 nil 8 1561984192 2306 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 11 167 498 371 39 4672 786 #text: 34 1 8 'Stone Name:' 4672 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 83 0 0 0 190 0 0 0 102 0 0 0] 8 #() 1008 nil 27 1026 1072 11 2560 371 4336 11 1120 39 410 ##(Smalltalk.TextEdit) 34 16 nil 2112 34 2 8 1140916352 1025 4992 nil 480 nil 7 nil nil nil 4992 nil 8 1562127792 2306 nil nil 1 722 138 144 34 2 786 #createAt:extent: 34 2 498 391 167 498 353 45 4992 786 #setMarginWidths: 34 1 8 #(3 3) 4992 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 83 0 0 0 115 1 0 0 105 0 0 0] 8 #() 1008 nil 27 1026 1904 11 1088 -9 3360 1 1120 45 410 ##(Smalltalk.StaticText) 34 16 nil 2112 34 2 8 1140850944 1 5312 nil nil nil 7 nil nil nil 5312 nil 8 1561984192 2306 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 11 67 498 371 31 5312 786 #text: 34 1 8 'RPC Gem Host Name or IP:' 5312 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 33 0 0 0 190 0 0 0 48 0 0 0] 8 #() 1008 nil 27 1026 1072 11 2560 371 4336 11 1120 31 410 ##(Smalltalk.StaticText) 34 16 nil 2112 34 2 8 1140850944 1 5632 nil nil nil 7 nil nil nil 5632 nil 8 1561984192 2306 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 11 113 498 371 31 5632 786 #text: 34 1 8 'NetLDI Service Name or Port:' 5632 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 56 0 0 0 190 0 0 0 71 0 0 0] 8 #() 1008 nil 27 1026 1072 11 2560 371 4336 3 1120 31 410 ##(Smalltalk.StaticText) 34 16 nil 2112 34 2 8 1140850944 1 5952 nil nil nil 7 nil nil nil 5952 nil 8 1561984192 2306 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 11 213 498 371 41 5952 786 #text: 34 1 8 'GemStone User ID:' 5952 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 106 0 0 0 190 0 0 0 126 0 0 0] 8 #() 1008 nil 27 1026 1072 11 2560 371 4336 3 1120 41 170 192 34 12 3696 8 'userID' 2576 8 'versionList' 3376 8 'gemService' 3040 8 'password' 4352 8 'gemHost' 4992 8 'stoneName' nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 9 53 498 753 363 2112 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 124 1 0 0 207 0 0 0] 34 12 2224 2576 5312 4352 5632 3376 4672 4992 5952 3696 4016 3040 1008 nil 27 2066 8 'Advanced' 410 ##(Smalltalk.ContainerView) 34 15 nil 1936 34 2 8 1140850688 131073 6592 nil nil nil 5 nil nil nil 6592 530 170 176 34 22 410 ##(Smalltalk.StaticText) 34 16 nil 6592 34 2 8 1140850944 1 6704 nil nil nil 5 nil nil nil 6704 nil 8 1561984192 2306 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 321 257 498 161 41 6704 786 #text: 34 1 8 'Password:' 6704 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 160 0 0 0 128 0 0 0 240 0 0 0 148 0 0 0] 8 #() 1008 nil 27 1026 1058 #fixedPreviousLeft -169 2560 161 4336 3 1120 41 410 ##(Smalltalk.PushButton) 34 20 nil 6592 34 2 8 1140924416 1 7040 nil nil nil 5 nil nil nil 7040 nil 8 1562135984 674 #debugGCI 8 'Debug GCI' 1 1 nil nil false nil nil nil 722 138 144 34 3 786 #createAt:extent: 34 2 498 11 5 498 141 51 7040 786 #isEnabled: 8 #(false) 7040 786 #text: 34 1 8 'Debug GCI' 7040 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 2 0 0 0 75 0 0 0 27 0 0 0] 8 #() 1008 nil 29 1026 1072 11 2560 141 4336 5 1120 51 410 ##(Smalltalk.TextEdit) 34 16 nil 6592 34 2 8 1140916384 1025 7408 nil 480 nil 5 nil nil nil 7408 nil 8 1562127792 2306 nil nil 1 722 138 144 34 2 786 #createAt:extent: 34 2 498 491 257 498 253 45 7408 786 #setMarginWidths: 34 1 8 #(3 3) 7408 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 245 0 0 0 128 0 0 0 115 1 0 0 150 0 0 0] 8 #() 1008 nil 27 1026 1904 11 1088 -9 3360 1 1120 45 410 ##(Smalltalk.StaticText) 34 16 nil 6592 34 2 8 1140850944 1 7728 nil nil nil 5 nil nil nil 7728 nil 8 1561984192 2306 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 321 211 498 161 41 7728 786 #text: 34 1 8 'OS User ID:' 7728 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 160 0 0 0 105 0 0 0 240 0 0 0 125 0 0 0] 8 #() 1008 nil 27 1026 1904 11 2560 161 3360 1 1120 41 410 ##(Smalltalk.StaticText) 34 16 nil 6592 34 2 8 1140850944 1 8048 nil nil nil 5 nil nil nil 8048 nil 8 1561984192 2306 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 11 125 498 301 31 8048 786 #text: 34 1 8 'NetLDI Task Name:' 8048 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 62 0 0 0 155 0 0 0 77 0 0 0] 8 #() 1008 nil 27 1026 1072 11 2560 301 4336 13 1120 31 410 ##(Smalltalk.StaticPath) 34 17 nil 6592 34 2 8 1140850944 1 8368 nil nil nil 5 nil nil nil 8368 nil 8 1561984192 2306 nil nil nil 8 'XXX' 722 138 144 34 2 786 #createAt:extent: 34 2 498 161 15 498 583 45 8368 786 #text: 34 1 8464 8368 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 80 0 0 0 7 0 0 0 115 1 0 0 29 0 0 0] 8 #() 1008 nil 27 1026 1072 161 1088 -9 3360 11 1120 45 410 ##(Smalltalk.ContainerView) 34 15 nil 6592 34 2 8 1409286144 393217 8688 nil 480 nil 5 nil nil nil 8688 656390 ##(Smalltalk.GridLayout) 1 3 1 1 170 192 34 4 410 ##(Smalltalk.RadioButton) 34 16 nil 8688 34 2 8 1140924425 1 8816 721990 2 ##(Smalltalk.ValueHolder) nil nil 1376774 ##(Smalltalk.PluggableSearchPolicy) 459270 ##(Smalltalk.Message) #= 8 #() 8946 #hash 8 #() false 480 nil 5 nil nil nil 8816 nil 8 1562135984 2306 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 1 39 498 297 39 8816 786 #text: 34 1 8 'Native OS User' 8816 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 19 0 0 0 148 0 0 0 38 0 0 0] 8 #() 1008 nil 27 8 'member' 410 ##(Smalltalk.RadioButton) 34 16 nil 8688 34 2 8 1141055497 1 9280 8882 nil nil 8914 8946 #= 8 #() 8946 #hash 8 #() false 480 nil 5 nil nil nil 9280 nil 8 1562135984 2306 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 1 1 498 297 39 9280 786 #text: 34 1 8 'NetLDI Guest' 9280 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 148 0 0 0 19 0 0 0] 8 #() 1008 nil 27 8 'guest' nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 11 211 498 301 81 8688 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 105 0 0 0 155 0 0 0 145 0 0 0] 34 2 9280 8816 1008 nil 27 1026 1072 11 2560 301 4336 33 1120 81 410 ##(Smalltalk.StaticText) 34 16 nil 6592 34 2 8 1140850944 1 9872 nil nil nil 5 nil nil nil 9872 nil 8 1561984192 2306 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 11 69 498 301 41 9872 786 #text: 34 1 8 'Stone Host (from Gem):' 9872 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 34 0 0 0 155 0 0 0 54 0 0 0] 8 #() 1008 nil 27 1026 1072 11 2560 301 4336 11 1120 41 410 ##(Smalltalk.TextEdit) 34 16 nil 6592 34 2 8 1140916352 1025 10192 nil 480 nil 5 nil nil nil 10192 nil 8 1562127792 2306 nil nil 1 722 138 144 34 3 786 #createAt:extent: 34 2 498 321 135 498 423 45 10192 786 #text: 34 1 8 'gemnetobject' 10192 786 #setMarginWidths: 34 1 8 #(3 3) 10192 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 160 0 0 0 67 0 0 0 115 1 0 0 89 0 0 0] 8 #() 1008 nil 27 1026 1904 11 1088 -9 3360 11 1120 45 410 ##(Smalltalk.TextEdit) 34 16 nil 6592 34 2 8 1140916352 1025 10560 nil 480 nil 5 nil nil nil 10560 nil 8 1562127792 2306 nil nil 1 722 138 144 34 2 786 #createAt:extent: 34 2 498 491 211 498 253 45 10560 786 #setMarginWidths: 34 1 8 #(3 3) 10560 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 245 0 0 0 105 0 0 0 115 1 0 0 127 0 0 0] 8 #() 1008 nil 27 1026 1904 11 1088 -9 3360 1 1120 45 410 ##(Smalltalk.TextEdit) 34 16 nil 6592 34 2 8 1140916352 1025 10880 nil 480 nil 5 nil nil nil 10880 nil 8 1562127792 2306 nil nil 1 722 138 144 34 4 786 #createAt:extent: 34 2 498 321 69 498 423 45 10880 786 #text: 34 1 8 'localhost' 10880 786 #selectionRange: 34 1 525062 ##(Smalltalk.Interval) 3 19 3 10880 786 #setMarginWidths: 34 1 8 #(3 3) 10880 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 160 0 0 0 34 0 0 0 115 1 0 0 56 0 0 0] 8 #() 1008 nil 27 1026 1904 11 1088 -9 3360 1 1120 45 170 192 34 12 7408 8 'hostPassword' 8688 8 'loginType' 8368 8 'debugPath' 10192 8 'gemTask' 10560 8 'hostUserID' 10880 8 'stoneHost' nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 9 53 498 753 363 6592 946 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 124 1 0 0 207 0 0 0] 34 11 7040 8368 9872 10880 8048 10192 8688 7728 10560 6704 7408 1008 nil 27 2112 nil nil nil 170 192 34 4 2112 8 'Basic' 6592 8 'Advanced' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 1936 34 2 8 1140916736 1 11664 2642 138 144 34 2 2096 6576 nil 2704 nil nil 1 nil nil nil 11664 nil 8 1561841408 2738 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 11792 7 257 nil 2738 0 nil 11810 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 11856 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #noIcons nil nil nil nil nil 722 138 144 34 3 786 #createAt:extent: 34 2 498 1 1 498 769 423 11664 786 #setSingleSelection: 8 #(1) 11664 786 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 11664 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 128 1 0 0 211 0 0 0] 8 #() 1008 nil 27 722 138 144 34 1 786 #createAt:extent: 34 2 498 1 51 498 769 423 1936 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 128 1 0 0 236 0 0 0] 34 3 2112 6592 11664 1008 nil 27 1026 1072 1 1088 1 1920 51 1104 -59 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409289036 131137 12336 nil 480 nil 7 nil nil nil 12336 480 8 1562094976 170 192 1328 170 192 34 6 30109 1115206 1 ##(Smalltalk.ToolbarIconButton) 12336 1 674 #fileSave 8 'Save' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1552 8 'FileSave.ico' 1600 30109 30107 12466 12336 1 674 #fileOpen 8 'Open' 1 1 12530 nil true 1552 8 'FileOpen.ico' 1600 30107 30105 12466 12336 1 674 #fileNew 8 'New' 1 1 12530 nil true 1552 8 'DocumentShell.ico' nil 30105 34 4 12656 12576 12480 1049158 1 ##(Smalltalk.ToolbarSeparator) 12336 1 nil nil 1 nil 498 33 33 498 45 45 nil nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 1 1 498 151 51 12336 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 75 0 0 0 25 0 0 0] 8 #() 1008 nil 27 1026 1072 1 2560 151 1920 1 1120 51 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409289036 131137 12992 nil 480 nil 7 nil nil nil 12992 480 8 1562094976 170 192 1328 170 192 34 10 30117 1442 12992 1 674 #editDelete 8 'Delete' 1 1 nil 30117 1506 1 true 1552 8 'EditBar.bmp' 1600 nil 7 498 1 1 11 30113 1442 12992 1 674 #editCopy 8 'Copy' 1 1 nil 30113 13168 3 30119 1442 12992 1 674 #editUndo 8 'Undo' 1 1 nil 30119 13168 7 30115 1442 12992 1 674 #editPaste 8 'Paste' 1 1 nil 30115 13168 5 30111 1442 12992 1 674 #editCut 8 'Cut' 1 1 nil 30111 13168 1 34 6 13360 13216 13312 13120 13264 12754 12992 1 nil nil 1 nil 498 33 33 498 45 45 nil nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 151 1 498 241 51 12992 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 75 0 0 0 0 0 0 0 195 0 0 0 25 0 0 0] 8 #() 1008 nil 27 1026 1904 1 2560 241 1920 1 1120 51 170 192 34 10 592 8 'loginButton' 1136 8 'Other Tools' 1936 8 'Tabs' 12336 8 'File Tools' 12992 8 'Edit Tools' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 265030 4 ##(Smalltalk.Menu) nil true 34 7 984134 2 ##(Smalltalk.CommandMenuItem) 1 674 #fileNew 8 '&New' 9373 1 nil nil nil 13858 1 674 #fileOpen 8 '&Open...' 9375 1 nil nil nil 13858 1 674 #fileSave 8 '&Save' 9383 1 nil nil nil 13858 1 674 #fileSaveAs 8 'Save &As...' 1 1 nil nil nil 13858 1 674 #fileRevert 8 '&Revert' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 13858 1 674 #exit 8 'E&xit' 17639 1 nil nil nil 8 '&File' nil 134217729 nil nil 30137 nil nil 13810 nil true 34 9 13858 1 674 #editUndo 8 '&Undo' 9397 1 nil nil nil 13858 1 674 #editRedo 8 '&Redo' 9395 1 nil nil nil 14114 4097 13858 1 674 #editCut 8 'Cu&t' 9393 1 nil nil nil 13858 1 674 #editCopy 8 '&Copy' 9351 1 nil nil nil 13858 1 674 #editPaste 8 '&Paste' 9389 1 nil nil nil 13858 1 674 #editDelete 8 'De&lete' 1629 1 nil nil nil 14114 4097 13858 1 674 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 8 '&Edit' nil 134217729 nil nil 30153 nil nil 13810 nil true 34 5 13858 1 674 #openHomePage 8 '&GemStone Home Page' 1025 1 nil nil nil 13858 1 674 #openGitHubJadeiteProject 8 '&Jadiete GitHub Project' 1025 1 nil nil nil 13858 1 674 #openGitHubRowanProject 8 '&Rowan GitHub Project' 1025 1 nil nil nil 14114 4097 13858 1 674 #aboutJadeite 8 '&About Jadeite' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 30163 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 15019 12530 nil true 1552 8 'icons\GS32.ico' nil 12530 nil true 1552 8 'icons\GS16.ico' nil nil nil 1 nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 3023 21 498 801 651 416 786 #text: 34 1 8 'Jadeite Login' 416 946 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 231 5 0 0 10 0 0 0 119 7 0 0 79 1 0 0] 34 5 12336 12992 1136 592 1936 1008 nil 27 )!

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

