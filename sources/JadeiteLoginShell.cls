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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 801 651 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 10 410 ##(Smalltalk.PushButton) 34 20 nil 416 34 2 8 1140924416 1 592 nil nil nil 7 nil nil nil 592 nil 8 1597459888 1180998 4 ##(Smalltalk.CommandDescription) #login 8 'Login' 1 1 nil nil true nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 1 467 498 769 61 592 786 #isEnabled: 8 #(false) 592 786 #text: 34 1 8 'Login' 592 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 233 0 0 0 128 1 0 0 7 1 0 0] 8 #() 498 193 193 nil 29 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 1058 #fixedParentRight 1 1058 #fixedParentBottom -59 1058 #fixedViewTop 61 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1140853580 131137 1136 nil 480 nil 519 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 498 193 193 nil 1136 480 8 1597418880 170 192 8 #() 170 192 34 4 40159 1246790 1 ##(Smalltalk.ToolbarBitmapButton) 1136 1 674 #openHelp 8 'Jade Help' 1 1 nil 40159 395334 3 ##(Smalltalk.Bitmap) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'Tools.bmp' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil nil 7 498 1857 33 71 40157 1246790 1 ##(Smalltalk.ToolbarSystemButton) 1136 1 674 #getHelpOn 8 'Get help on widget' 1 1 nil 40157 1 23 34 2 1600 1392 nil nil 1 nil 498 33 33 498 45 45 nil 656198 1 ##(Smalltalk.FlowLayout) 1 1 1 722 138 144 34 1 786 #createAt:extent: 34 2 498 391 1 498 379 51 1136 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 0 0 0 0 128 1 0 0 25 0 0 0] 8 #() 1008 nil 27 1026 1058 #fixedPreviousRight 1 1088 1 1058 #fixedParentTop 1 1120 51 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 1936 nil 480 nil 7 nil nil nil 1936 656710 1 ##(Smalltalk.CardLayout) 138 144 34 2 721414 ##(Smalltalk.Association) 8 'Basic' 410 ##(Smalltalk.ContainerView) 34 15 nil 1936 34 2 8 1140850688 131073 2112 nil nil nil 7 nil nil nil 2112 530 170 176 34 24 410 ##(Smalltalk.TextEdit) 34 16 nil 2112 34 2 8 1140916352 1025 2224 nil 480 nil 7 nil nil nil 2224 nil 8 1597451696 852486 ##(Smalltalk.NullConverter) nil nil 1 722 138 144 34 2 786 #createAt:extent: 34 2 498 391 67 498 353 45 2224 786 #setMarginWidths: 34 1 8 #(3 3) 2224 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 33 0 0 0 115 1 0 0 55 0 0 0] 8 #() 1008 nil 27 1026 1904 11 1088 -9 1058 #fixedPreviousTop 1 1120 45 410 ##(Smalltalk.ComboBox) 34 17 nil 2112 34 2 8 1144063491 1025 2576 590662 2 ##(Smalltalk.ListModel) 138 144 1328 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 nil nil nil 2576 nil 8 1597251680 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 ##(Smalltalk.Message) 8 'doIt' 8 '[:libClass | libClass displayName]' 8 #[30 105 226 0 106] #displayName 2752 7 257 nil 8 #() 401 722 138 144 34 1 786 #createAt:extent: 34 2 498 391 11 498 353 51 2576 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 5 0 0 0 115 1 0 0 30 0 0 0] 8 #() 1008 nil 27 1026 1904 11 1088 -9 1920 11 1120 47 410 ##(Smalltalk.StaticText) 34 16 nil 2112 34 2 8 1140850944 1 3040 nil nil nil 7 nil nil nil 3040 nil 8 1597308096 2306 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 11 167 498 371 39 3040 786 #text: 34 1 8 'Stone Name:' 3040 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 83 0 0 0 190 0 0 0 102 0 0 0] 8 #() 1008 nil 27 1026 1072 11 1058 #fixedViewLeft 371 1058 #fixedPreviousBottom 11 1120 39 410 ##(Smalltalk.StaticText) 34 16 nil 2112 34 2 8 1140850944 1 3392 nil nil nil 7 nil nil nil 3392 nil 8 1597308096 2306 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 11 259 498 371 41 3392 786 #text: 34 1 8 'GemStone Password:' 3392 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 129 0 0 0 190 0 0 0 149 0 0 0] 8 #() 1008 nil 27 1026 1072 11 3360 371 3376 3 1120 41 410 ##(Smalltalk.TextEdit) 34 16 nil 2112 34 2 8 1140916352 1025 3712 nil 480 nil 7 nil nil nil 3712 nil 8 1597451696 2306 nil nil 1 722 138 144 34 2 786 #createAt:extent: 34 2 498 391 167 498 353 45 3712 786 #setMarginWidths: 34 1 8 #(3 3) 3712 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 83 0 0 0 115 1 0 0 105 0 0 0] 8 #() 1008 nil 27 1026 1904 11 1088 -9 2560 1 1120 45 410 ##(Smalltalk.TextEdit) 34 16 nil 2112 34 2 8 1140916352 1025 4032 nil 480 nil 7 nil nil nil 4032 nil 8 1597451696 2306 nil nil 1 722 138 144 34 2 786 #createAt:extent: 34 2 498 391 113 498 353 45 4032 786 #setMarginWidths: 34 1 8 #(3 3) 4032 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 56 0 0 0 115 1 0 0 78 0 0 0] 8 #() 1008 nil 27 1026 1904 11 1088 -9 2560 1 1120 45 410 ##(Smalltalk.TextEdit) 34 16 nil 2112 34 2 8 1140916384 1025 4352 nil 480 nil 7 nil nil nil 4352 nil 8 1597451696 2306 nil nil 1 722 138 144 34 2 786 #createAt:extent: 34 2 498 391 259 498 353 45 4352 786 #setMarginWidths: 34 1 8 #(3 3) 4352 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 129 0 0 0 115 1 0 0 151 0 0 0] 8 #() 1008 nil 27 1026 1904 11 1088 -9 2560 1 1120 45 410 ##(Smalltalk.TextEdit) 34 16 nil 2112 34 2 8 1140916352 1025 4672 nil 480 nil 7 nil nil nil 4672 nil 8 1597451696 2306 nil nil 1 722 138 144 34 2 786 #createAt:extent: 34 2 498 391 213 498 353 45 4672 786 #setMarginWidths: 34 1 8 #(3 3) 4672 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 106 0 0 0 115 1 0 0 128 0 0 0] 8 #() 1008 nil 27 1026 1904 11 1088 -9 2560 1 1120 45 410 ##(Smalltalk.StaticText) 34 16 nil 2112 34 2 8 1140850944 1 4992 nil nil nil 7 nil nil nil 4992 nil 8 1597308096 2306 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 11 67 498 371 31 4992 786 #text: 34 1 8 'RPC Gem Host Name or IP:' 4992 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 33 0 0 0 190 0 0 0 48 0 0 0] 8 #() 1008 nil 27 1026 1072 11 3360 371 3376 11 1120 31 410 ##(Smalltalk.StaticText) 34 16 nil 2112 34 2 8 1140850944 1 5312 nil nil nil 7 nil nil nil 5312 nil 8 1597308096 2306 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 11 213 498 371 41 5312 786 #text: 34 1 8 'GemStone User ID:' 5312 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 106 0 0 0 190 0 0 0 126 0 0 0] 8 #() 1008 nil 27 1026 1072 11 3360 371 3376 3 1120 41 410 ##(Smalltalk.StaticText) 34 16 nil 2112 34 2 8 1140850944 1 5632 nil nil nil 7 nil nil nil 5632 nil 8 1597308096 2306 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 11 21 498 371 41 5632 786 #text: 34 1 8 'GemStone/Smalltalk Version:' 5632 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 10 0 0 0 190 0 0 0 30 0 0 0] 8 #() 1008 nil 27 1026 1072 11 3360 371 1920 21 1120 41 410 ##(Smalltalk.StaticText) 34 16 nil 2112 34 2 8 1140850944 1 5952 nil nil nil 7 nil nil nil 5952 nil 8 1597308096 2306 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 11 113 498 371 31 5952 786 #text: 34 1 8 'NetLDI Service Name or Port:' 5952 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 56 0 0 0 190 0 0 0 71 0 0 0] 8 #() 1008 nil 27 1026 1072 11 3360 371 3376 3 1120 31 170 192 34 12 3712 8 'stoneName' 4352 8 'password' 2224 8 'gemHost' 4032 8 'gemService' 2576 8 'versionList' 4672 8 'userID' nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 9 53 498 753 357 2112 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 124 1 0 0 204 0 0 0] 34 12 5632 2576 4992 2224 5952 4032 3040 3712 5312 4672 3392 4352 1008 nil 27 2066 8 'Advanced' 410 ##(Smalltalk.ContainerView) 34 15 nil 1936 34 2 8 1140850688 131073 6592 nil nil nil 5 nil nil nil 6592 530 170 176 34 22 410 ##(Smalltalk.PushButton) 34 20 nil 6592 34 2 8 1140924416 1 6704 nil nil nil 5 nil nil nil 6704 nil 8 1597459888 674 #debugGCI 8 'Debug GCI' 1 1 nil nil false nil nil nil 722 138 144 34 3 786 #createAt:extent: 34 2 498 11 5 498 201 51 6704 786 #isEnabled: 8 #(false) 6704 786 #text: 34 1 8 'Debug GCI' 6704 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 2 0 0 0 105 0 0 0 27 0 0 0] 8 #() 1008 nil 29 1026 1072 11 3360 201 3376 5 1120 51 410 ##(Smalltalk.TextEdit) 34 16 nil 6592 34 2 8 1140916384 1025 7072 nil 480 nil 5 nil nil nil 7072 nil 8 1597451696 2306 nil nil 1 722 138 144 34 2 786 #createAt:extent: 34 2 498 491 257 498 253 45 7072 786 #setMarginWidths: 34 1 8 #(3 3) 7072 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 245 0 0 0 128 0 0 0 115 1 0 0 150 0 0 0] 8 #() 1008 nil 27 1026 1904 11 1088 -9 2560 1 1120 45 410 ##(Smalltalk.StaticText) 34 16 nil 6592 34 2 8 1140850944 1 7392 nil nil nil 5 nil nil nil 7392 nil 8 1597308096 2306 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 11 69 498 301 41 7392 786 #text: 34 1 8 'Stone Host (from Gem):' 7392 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 34 0 0 0 155 0 0 0 54 0 0 0] 8 #() 1008 nil 27 1026 1072 11 3360 301 3376 11 1120 41 410 ##(Smalltalk.StaticPath) 34 17 nil 6592 34 2 8 1140850944 1 7712 nil nil nil 5 nil nil nil 7712 nil 8 1597308096 2306 nil nil nil 8 'XXX' 722 138 144 34 2 786 #createAt:extent: 34 2 498 221 15 498 523 45 7712 786 #text: 34 1 7808 7712 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 110 0 0 0 7 0 0 0 115 1 0 0 29 0 0 0] 8 #() 1008 nil 27 1026 1072 221 1088 -9 2560 11 1120 45 410 ##(Smalltalk.TextEdit) 34 16 nil 6592 34 2 8 1140916352 1025 8032 nil 480 nil 5 nil nil nil 8032 nil 8 1597451696 2306 nil nil 1 722 138 144 34 2 786 #createAt:extent: 34 2 498 491 211 498 253 45 8032 786 #setMarginWidths: 34 1 8 #(3 3) 8032 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 245 0 0 0 105 0 0 0 115 1 0 0 127 0 0 0] 8 #() 1008 nil 27 1026 1904 11 1088 -9 2560 1 1120 45 410 ##(Smalltalk.TextEdit) 34 16 nil 6592 34 2 8 1140916352 1025 8352 nil 480 nil 5 nil nil nil 8352 nil 8 1597451696 2306 nil nil 1 722 138 144 34 3 786 #createAt:extent: 34 2 498 321 135 498 423 45 8352 786 #text: 34 1 8 'gemnetobject' 8352 786 #setMarginWidths: 34 1 8 #(3 3) 8352 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 160 0 0 0 67 0 0 0 115 1 0 0 89 0 0 0] 8 #() 1008 nil 27 1026 1904 11 1088 -9 2560 11 1120 45 410 ##(Smalltalk.StaticText) 34 16 nil 6592 34 2 8 1140850944 1 8720 nil nil nil 5 nil nil nil 8720 nil 8 1597308096 2306 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 321 211 498 161 41 8720 786 #text: 34 1 8 'OS User ID:' 8720 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 160 0 0 0 105 0 0 0 240 0 0 0 125 0 0 0] 8 #() 1008 nil 27 1026 1904 11 3360 161 2560 1 1120 41 410 ##(Smalltalk.StaticText) 34 16 nil 6592 34 2 8 1140850944 1 9040 nil nil nil 5 nil nil nil 9040 nil 8 1597308096 2306 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 11 125 498 301 31 9040 786 #text: 34 1 8 'NetLDI Task Name:' 9040 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 62 0 0 0 155 0 0 0 77 0 0 0] 8 #() 1008 nil 27 1026 1072 11 3360 301 3376 13 1120 31 410 ##(Smalltalk.StaticText) 34 16 nil 6592 34 2 8 1140850944 1 9360 nil nil nil 5 nil nil nil 9360 nil 8 1597308096 2306 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 321 257 498 161 41 9360 786 #text: 34 1 8 'Password:' 9360 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 160 0 0 0 128 0 0 0 240 0 0 0 148 0 0 0] 8 #() 1008 nil 27 1026 1058 #fixedPreviousLeft -169 3360 161 3376 3 1120 41 410 ##(Smalltalk.ContainerView) 34 15 nil 6592 34 2 8 1409286144 393217 9696 nil 480 nil 5 nil nil nil 9696 656390 ##(Smalltalk.GridLayout) 1 3 1 1 170 192 34 4 410 ##(Smalltalk.RadioButton) 34 16 nil 9696 34 2 8 1140924425 1 9824 721990 2 ##(Smalltalk.ValueHolder) nil nil 1376774 ##(Smalltalk.PluggableSearchPolicy) 459270 ##(Smalltalk.Message) #= 8 #() 9954 #hash 8 #() false 480 nil 5 nil nil nil 9824 nil 8 1597459888 2306 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 1 39 498 297 39 9824 786 #text: 34 1 8 'Native OS User' 9824 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 19 0 0 0 148 0 0 0 38 0 0 0] 8 #() 1008 nil 27 8 'member' 410 ##(Smalltalk.RadioButton) 34 16 nil 9696 34 2 8 1141055497 1 10288 9890 nil nil 9922 9954 #= 8 #() 9954 #hash 8 #() false 480 nil 5 nil nil nil 10288 nil 8 1597459888 2306 nil nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 1 1 498 297 39 10288 786 #text: 34 1 8 'NetLDI Guest' 10288 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 148 0 0 0 19 0 0 0] 8 #() 1008 nil 27 8 'guest' nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 11 211 498 301 81 9696 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 105 0 0 0 155 0 0 0 145 0 0 0] 34 2 10288 9824 1008 nil 27 1026 1072 11 3360 301 3376 33 1120 81 410 ##(Smalltalk.TextEdit) 34 16 nil 6592 34 2 8 1140916352 1025 10880 nil 480 nil 5 nil nil nil 10880 nil 8 1597451696 2306 nil nil 1 722 138 144 34 4 786 #createAt:extent: 34 2 498 321 69 498 423 45 10880 786 #text: 34 1 8 'localhost' 10880 786 #selectionRange: 34 1 525062 ##(Smalltalk.Interval) 3 19 3 10880 786 #setMarginWidths: 34 1 8 #(3 3) 10880 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 160 0 0 0 34 0 0 0 115 1 0 0 56 0 0 0] 8 #() 1008 nil 27 1026 1904 11 1088 -9 2560 1 1120 45 170 192 34 12 7072 8 'hostPassword' 7712 8 'debugPath' 8032 8 'hostUserID' 8352 8 'gemTask' 9696 8 'loginType' 10880 8 'stoneHost' nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 9 53 498 753 357 6592 946 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 124 1 0 0 204 0 0 0] 34 11 6704 7712 7392 10880 9040 8352 9696 8720 8032 9360 7072 1008 nil 27 2112 nil nil nil 170 192 34 4 6592 8 'Advanced' 2112 8 'Basic' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 1936 34 2 8 1140916736 1 11664 2642 138 144 34 2 2096 6576 nil 2704 nil nil 1 nil nil nil 11664 nil 8 1597165312 2738 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 11792 7 257 nil 2738 0 nil 11810 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 11856 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #noIcons nil nil nil nil nil 722 138 144 34 3 786 #createAt:extent: 34 2 498 1 1 498 769 417 11664 786 #setSingleSelection: 8 #(1) 11664 786 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 11664 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 128 1 0 0 208 0 0 0] 8 #() 1008 nil 27 722 138 144 34 1 786 #createAt:extent: 34 2 498 1 51 498 769 417 1936 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 128 1 0 0 233 0 0 0] 34 3 2112 6592 11664 1008 nil 27 1026 1072 1 1088 1 1920 51 1104 -59 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409289036 131137 12336 nil 480 nil 7 nil nil nil 12336 480 8 1597418880 170 192 1328 170 192 34 10 40155 1378 12336 1 674 #editUndo 8 'Undo' 1 1 nil 40155 1442 1 true 1488 8 'EditBar.bmp' 1536 nil 7 498 1 1 7 40151 1378 12336 1 674 #editPaste 8 'Paste' 1 1 nil 40151 12512 5 40147 1378 12336 1 674 #editCut 8 'Cut' 1 1 nil 40147 12512 1 40153 1378 12336 1 674 #editDelete 8 'Delete' 1 1 nil 40153 12512 11 40149 1378 12336 1 674 #editCopy 8 'Copy' 1 1 nil 40149 12512 3 34 6 12608 12704 12560 12656 12464 1049158 1 ##(Smalltalk.ToolbarSeparator) 12336 1 nil nil 1 nil 498 33 33 498 45 45 nil nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 151 1 498 241 51 12336 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 75 0 0 0 0 0 0 0 195 0 0 0 25 0 0 0] 8 #() 1008 nil 27 1026 1904 1 3360 241 1920 1 1120 51 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409289036 131137 13008 nil 480 nil 7 nil nil nil 13008 480 8 1597418880 170 192 1328 170 192 34 6 40145 1115206 1 ##(Smalltalk.ToolbarIconButton) 13008 1 674 #fileSave 8 'Save' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1488 8 'FileSave.ico' 1536 40145 40143 13138 13008 1 674 #fileOpen 8 'Open' 1 1 13202 nil true 1488 8 'FileOpen.ico' 1536 40143 40141 13138 13008 1 674 #fileNew 8 'New' 1 1 13202 nil true 1488 8 'DocumentShell.ico' nil 40141 34 4 13328 13248 13152 12770 13008 1 nil nil 1 nil 498 33 33 498 45 45 nil nil 722 138 144 34 1 786 #createAt:extent: 34 2 498 1 1 498 151 51 13008 946 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 75 0 0 0 25 0 0 0] 8 #() 1008 nil 27 1026 1072 1 3360 151 1920 1 1120 51 170 192 34 10 592 8 'loginButton' 1136 8 'Other Tools' 1936 8 'Tabs' 12336 8 'Edit Tools' 13008 8 'File Tools' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 265030 4 ##(Smalltalk.Menu) nil true 34 7 984134 2 ##(Smalltalk.CommandMenuItem) 1 674 #fileNew 8 '&New' 9373 1 nil nil nil 13858 1 674 #fileOpen 8 '&Open...' 9375 1 nil nil nil 13858 1 674 #fileSave 8 '&Save' 9383 1 nil nil nil 13858 1 674 #fileSaveAs 8 'Save &As...' 1 1 nil nil nil 13858 1 674 #fileRevert 8 '&Revert' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 13858 1 674 #exit 8 'E&xit' 17639 1 nil nil nil 8 '&File' nil 134217729 nil nil 40173 nil nil 13810 nil true 34 9 13858 1 674 #editUndo 8 '&Undo' 9397 1 nil nil nil 13858 1 674 #editRedo 8 '&Redo' 9395 1 nil nil nil 14114 4097 13858 1 674 #editCut 8 'Cu&t' 9393 1 nil nil nil 13858 1 674 #editCopy 8 '&Copy' 9351 1 nil nil nil 13858 1 674 #editPaste 8 '&Paste' 9389 1 nil nil nil 13858 1 674 #editDelete 8 'De&lete' 1629 1 nil nil nil 14114 4097 13858 1 674 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 8 '&Edit' nil 134217729 nil nil 40189 nil nil 13810 nil true 34 5 13858 1 674 #openHomePage 8 '&GemStone Home Page' 1025 1 nil nil nil 13858 1 674 #openGitHubJadeiteProject 8 '&Jadiete GitHub Project' 1025 1 nil nil nil 13858 1 674 #openGitHubRowanProject 8 '&Rowan GitHub Project' 1025 1 nil nil nil 14114 4097 13858 1 674 #aboutJadeite 8 '&About Jadeite' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 40199 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 30089 13202 nil true 1488 8 'icons\GS32.ico' nil 13202 nil true 1488 8 'icons\GS16.ico' nil nil nil 1 nil nil 722 138 144 34 2 786 #createAt:extent: 34 2 498 7319 21 498 801 651 416 786 #text: 34 1 8 'Jadeite Login' 416 946 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 75 14 0 0 10 0 0 0 219 15 0 0 79 1 0 0] 34 5 13008 12336 1136 592 1936 1008 nil 27 )!

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

