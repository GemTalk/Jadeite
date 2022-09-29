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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 801 651 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 10 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409289036 131137 592 nil 480 nil 7 nil nil nil 592 480 8 1562094976 170 192 8 #() 170 192 34 6 28393 1115206 1 ##(Smalltalk.ToolbarIconButton) 592 1 1180998 4 ##(Smalltalk.CommandDescription) #fileOpen 8 'Open' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'FileOpen.ico' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil 28393 28391 738 592 1 770 #fileNew 8 'New' 1 1 818 nil true 864 8 'DocumentShell.ico' nil 28391 28395 738 592 1 770 #fileSave 8 'Save' 1 1 818 nil true 864 8 'FileSave.ico' 912 28395 34 4 944 752 1024 1049158 1 ##(Smalltalk.ToolbarSeparator) 592 1 nil nil 1 nil 498 33 33 498 45 45 nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 1 1 498 151 51 592 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 75 0 0 0 25 0 0 0] 8 #() 498 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 1442 #fixedViewLeft 151 1442 #fixedParentTop 1 1442 #fixedViewTop 51 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 1520 nil 480 nil 7 nil nil nil 1520 656710 1 ##(Smalltalk.CardLayout) 138 144 34 2 721414 ##(Smalltalk.Association) 8 'Basic' 410 ##(Smalltalk.ContainerView) 34 15 nil 1520 34 2 8 1140850688 131073 1696 nil nil nil 7 nil nil nil 1696 530 170 176 34 24 410 ##(Smalltalk.StaticText) 34 16 nil 1696 34 2 8 1140850944 1 1808 nil nil nil 7 nil nil nil 1808 nil 8 1561984192 852486 ##(Smalltalk.NullConverter) nil nil nil 1186 138 144 34 2 1250 #createAt:extent: 34 2 498 11 167 498 371 39 1808 1250 #text: 34 1 8 'Stone Name:' 1808 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 83 0 0 0 190 0 0 0 102 0 0 0] 8 #() 1392 nil 27 1410 1456 11 1472 371 1442 #fixedPreviousBottom 11 1504 39 410 ##(Smalltalk.StaticText) 34 16 nil 1696 34 2 8 1140850944 1 2160 nil nil nil 7 nil nil nil 2160 nil 8 1561984192 1890 nil nil nil 1186 138 144 34 2 1250 #createAt:extent: 34 2 498 11 21 498 371 41 2160 1250 #text: 34 1 8 'GemStone/Smalltalk Version:' 2160 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 10 0 0 0 190 0 0 0 30 0 0 0] 8 #() 1392 nil 27 1410 1456 11 1472 371 1488 21 1504 41 410 ##(Smalltalk.TextEdit) 34 16 nil 1696 34 2 8 1140916352 1025 2480 nil 480 nil 7 nil nil nil 2480 nil 8 1562127792 1890 nil nil 1 1186 138 144 34 2 1250 #createAt:extent: 34 2 498 391 167 498 353 45 2480 1250 #setMarginWidths: 34 1 8 #(3 3) 2480 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 83 0 0 0 115 1 0 0 105 0 0 0] 8 #() 1392 nil 27 1410 1442 #fixedPreviousRight 11 1442 #fixedParentRight -9 1442 #fixedPreviousTop 1 1504 45 410 ##(Smalltalk.ComboBox) 34 17 nil 1696 34 2 8 1144063491 1025 2848 590662 2 ##(Smalltalk.ListModel) 138 144 688 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 nil nil nil 2848 nil 8 1561927776 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 ##(Smalltalk.Message) 8 'doIt' 8 '[:libClass | libClass displayName]' 8 #[30 105 226 0 106] #displayName 3024 7 257 nil 8 #() 401 1186 138 144 34 1 1250 #createAt:extent: 34 2 498 391 11 498 353 51 2848 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 5 0 0 0 115 1 0 0 30 0 0 0] 8 #() 1392 nil 27 1410 2800 11 2816 -9 1488 11 1504 47 410 ##(Smalltalk.StaticText) 34 16 nil 1696 34 2 8 1140850944 1 3312 nil nil nil 7 nil nil nil 3312 nil 8 1561984192 1890 nil nil nil 1186 138 144 34 2 1250 #createAt:extent: 34 2 498 11 259 498 371 41 3312 1250 #text: 34 1 8 'GemStone Password:' 3312 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 129 0 0 0 190 0 0 0 149 0 0 0] 8 #() 1392 nil 27 1410 1456 11 1472 371 2144 3 1504 41 410 ##(Smalltalk.StaticText) 34 16 nil 1696 34 2 8 1140850944 1 3632 nil nil nil 7 nil nil nil 3632 nil 8 1561984192 1890 nil nil nil 1186 138 144 34 2 1250 #createAt:extent: 34 2 498 11 67 498 371 31 3632 1250 #text: 34 1 8 'RPC Gem Host Name or IP:' 3632 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 33 0 0 0 190 0 0 0 48 0 0 0] 8 #() 1392 nil 27 1410 1456 11 1472 371 2144 11 1504 31 410 ##(Smalltalk.StaticText) 34 16 nil 1696 34 2 8 1140850944 1 3952 nil nil nil 7 nil nil nil 3952 nil 8 1561984192 1890 nil nil nil 1186 138 144 34 2 1250 #createAt:extent: 34 2 498 11 113 498 371 31 3952 1250 #text: 34 1 8 'NetLDI Service Name or Port:' 3952 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 56 0 0 0 190 0 0 0 71 0 0 0] 8 #() 1392 nil 27 1410 1456 11 1472 371 2144 3 1504 31 410 ##(Smalltalk.TextEdit) 34 16 nil 1696 34 2 8 1140916352 1025 4272 nil 480 nil 7 nil nil nil 4272 nil 8 1562127792 1890 nil nil 1 1186 138 144 34 2 1250 #createAt:extent: 34 2 498 391 67 498 353 45 4272 1250 #setMarginWidths: 34 1 8 #(3 3) 4272 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 33 0 0 0 115 1 0 0 55 0 0 0] 8 #() 1392 nil 27 1410 2800 11 2816 -9 2832 1 1504 45 410 ##(Smalltalk.StaticText) 34 16 nil 1696 34 2 8 1140850944 1 4592 nil nil nil 7 nil nil nil 4592 nil 8 1561984192 1890 nil nil nil 1186 138 144 34 2 1250 #createAt:extent: 34 2 498 11 213 498 371 41 4592 1250 #text: 34 1 8 'GemStone User ID:' 4592 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 106 0 0 0 190 0 0 0 126 0 0 0] 8 #() 1392 nil 27 1410 1456 11 1472 371 2144 3 1504 41 410 ##(Smalltalk.TextEdit) 34 16 nil 1696 34 2 8 1140916352 1025 4912 nil 480 nil 7 nil nil nil 4912 nil 8 1562127792 1890 nil nil 1 1186 138 144 34 2 1250 #createAt:extent: 34 2 498 391 113 498 353 45 4912 1250 #setMarginWidths: 34 1 8 #(3 3) 4912 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 56 0 0 0 115 1 0 0 78 0 0 0] 8 #() 1392 nil 27 1410 2800 11 2816 -9 2832 1 1504 45 410 ##(Smalltalk.TextEdit) 34 16 nil 1696 34 2 8 1140916352 1025 5232 nil 480 nil 7 nil nil nil 5232 nil 8 1562127792 1890 nil nil 1 1186 138 144 34 2 1250 #createAt:extent: 34 2 498 391 213 498 353 45 5232 1250 #setMarginWidths: 34 1 8 #(3 3) 5232 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 106 0 0 0 115 1 0 0 128 0 0 0] 8 #() 1392 nil 27 1410 2800 11 2816 -9 2832 1 1504 45 410 ##(Smalltalk.TextEdit) 34 16 nil 1696 34 2 8 1140916384 1025 5552 nil 480 nil 7 nil nil nil 5552 nil 8 1562127792 1890 nil nil 1 1186 138 144 34 2 1250 #createAt:extent: 34 2 498 391 259 498 353 45 5552 1250 #setMarginWidths: 34 1 8 #(3 3) 5552 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 129 0 0 0 115 1 0 0 151 0 0 0] 8 #() 1392 nil 27 1410 2800 11 2816 -9 2832 1 1504 45 170 192 34 12 2480 8 'stoneName' 5552 8 'password' 4272 8 'gemHost' 4912 8 'gemService' 5232 8 'userID' 2848 8 'versionList' nil 1186 138 144 34 1 1250 #createAt:extent: 34 2 498 9 53 498 753 363 1696 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 124 1 0 0 207 0 0 0] 34 12 2160 2848 3632 4272 3952 4912 1808 2480 4592 5232 3312 5552 1392 nil 27 1650 8 'Advanced' 410 ##(Smalltalk.ContainerView) 34 15 nil 1520 34 2 8 1140850688 131073 6192 nil nil nil 5 nil nil nil 6192 530 170 176 34 22 410 ##(Smalltalk.StaticPath) 34 17 nil 6192 34 2 8 1140850944 1 6304 nil nil nil 5 nil nil nil 6304 nil 8 1561984192 1890 nil nil nil 8 'XXX' 1186 138 144 34 2 1250 #createAt:extent: 34 2 498 161 15 498 583 45 6304 1250 #text: 34 1 6400 6304 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 80 0 0 0 7 0 0 0 115 1 0 0 29 0 0 0] 8 #() 1392 nil 27 1410 1456 161 2816 -9 2832 11 1504 45 410 ##(Smalltalk.StaticText) 34 16 nil 6192 34 2 8 1140850944 1 6624 nil nil nil 5 nil nil nil 6624 nil 8 1561984192 1890 nil nil nil 1186 138 144 34 2 1250 #createAt:extent: 34 2 498 11 115 498 301 31 6624 1250 #text: 34 1 8 'NetLDI Task Name:' 6624 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 57 0 0 0 155 0 0 0 72 0 0 0] 8 #() 1392 nil 27 1410 1456 11 1472 301 2144 3 1504 31 410 ##(Smalltalk.TextEdit) 34 16 nil 6192 34 2 8 1140916384 1025 6944 nil 480 nil 5 nil nil nil 6944 nil 8 1562127792 1890 nil nil 1 1186 138 144 34 2 1250 #createAt:extent: 34 2 498 491 209 498 253 45 6944 1250 #setMarginWidths: 34 1 8 #(3 3) 6944 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 245 0 0 0 104 0 0 0 115 1 0 0 126 0 0 0] 8 #() 1392 nil 27 1410 2800 11 2816 -9 2832 1 1504 45 410 ##(Smalltalk.StaticText) 34 16 nil 6192 34 2 8 1140850944 1 7264 nil nil nil 5 nil nil nil 7264 nil 8 1561984192 1890 nil nil nil 1186 138 144 34 2 1250 #createAt:extent: 34 2 498 321 163 498 161 41 7264 1250 #text: 34 1 8 'OS User ID:' 7264 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 160 0 0 0 81 0 0 0 240 0 0 0 101 0 0 0] 8 #() 1392 nil 27 1410 2800 11 1472 161 2832 1 1504 41 410 ##(Smalltalk.TextEdit) 34 16 nil 6192 34 2 8 1140916352 1025 7584 nil 480 nil 5 nil nil nil 7584 nil 8 1562127792 1890 nil nil 1 1186 138 144 34 3 1250 #createAt:extent: 34 2 498 321 115 498 423 45 7584 1250 #text: 34 1 8 'gemnetobject' 7584 1250 #setMarginWidths: 34 1 8 #(3 3) 7584 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 160 0 0 0 57 0 0 0 115 1 0 0 79 0 0 0] 8 #() 1392 nil 27 1410 2800 11 2816 -9 2832 1 1504 45 410 ##(Smalltalk.StaticText) 34 16 nil 6192 34 2 8 1140850944 1 7952 nil nil nil 5 nil nil nil 7952 nil 8 1561984192 1890 nil nil nil 1186 138 144 34 2 1250 #createAt:extent: 34 2 498 321 209 498 161 41 7952 1250 #text: 34 1 8 'Password:' 7952 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 160 0 0 0 104 0 0 0 240 0 0 0 124 0 0 0] 8 #() 1392 nil 27 1410 1442 #fixedPreviousLeft -169 1472 161 2144 3 1504 41 410 ##(Smalltalk.ContainerView) 34 15 nil 6192 34 2 8 1409286144 393217 8288 nil 480 nil 5 nil nil nil 8288 656390 ##(Smalltalk.GridLayout) 1 3 1 1 170 192 34 4 410 ##(Smalltalk.RadioButton) 34 16 nil 8288 34 2 8 1141055497 1 8416 721990 2 ##(Smalltalk.ValueHolder) nil nil 1376774 ##(Smalltalk.PluggableSearchPolicy) 459270 ##(Smalltalk.Message) #= 8 #() 8546 #hash 8 #() false 480 nil 5 nil nil nil 8416 nil 8 1562135984 1890 nil nil nil 1186 138 144 34 2 1250 #createAt:extent: 34 2 498 1 1 498 297 39 8416 1250 #text: 34 1 8 'NetLDI Guest' 8416 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 148 0 0 0 19 0 0 0] 8 #() 1392 nil 27 8 'guest' 410 ##(Smalltalk.RadioButton) 34 16 nil 8288 34 2 8 1140924425 1 8880 8482 nil nil 8514 8546 #= 8 #() 8546 #hash 8 #() false 480 nil 5 nil nil nil 8880 nil 8 1562135984 1890 nil nil nil 1186 138 144 34 2 1250 #createAt:extent: 34 2 498 1 39 498 297 39 8880 1250 #text: 34 1 8 'Native OS User' 8880 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 19 0 0 0 148 0 0 0 38 0 0 0] 8 #() 1392 nil 27 8 'member' nil 1186 138 144 34 1 1250 #createAt:extent: 34 2 498 11 163 498 301 81 8288 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 81 0 0 0 155 0 0 0 121 0 0 0] 34 2 8416 8880 1392 nil 27 1410 1456 11 1472 301 2144 5 1504 81 410 ##(Smalltalk.TextEdit) 34 16 nil 6192 34 2 8 1140916352 1025 9472 nil 480 nil 5 nil nil nil 9472 nil 8 1562127792 1890 nil nil 1 1186 138 144 34 2 1250 #createAt:extent: 34 2 498 491 163 498 253 45 9472 1250 #setMarginWidths: 34 1 8 #(3 3) 9472 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 245 0 0 0 81 0 0 0 115 1 0 0 103 0 0 0] 8 #() 1392 nil 27 1410 2800 11 2816 -9 2832 1 1504 45 410 ##(Smalltalk.StaticText) 34 16 nil 6192 34 2 8 1140850944 1 9792 nil nil nil 5 nil nil nil 9792 nil 8 1561984192 1890 nil nil nil 1186 138 144 34 2 1250 #createAt:extent: 34 2 498 11 69 498 301 41 9792 1250 #text: 34 1 8 'Stone Host (from Gem):' 9792 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 34 0 0 0 155 0 0 0 54 0 0 0] 8 #() 1392 nil 27 1410 1456 11 1472 301 2144 11 1504 41 410 ##(Smalltalk.TextEdit) 34 16 nil 6192 34 2 8 1140916352 1025 10112 nil 480 nil 5 nil nil nil 10112 nil 8 1562127792 1890 nil nil 1 1186 138 144 34 4 1250 #createAt:extent: 34 2 498 321 69 498 423 45 10112 1250 #text: 34 1 8 'localhost' 10112 1250 #selectionRange: 34 1 525062 ##(Smalltalk.Interval) 3 19 3 10112 1250 #setMarginWidths: 34 1 8 #(3 3) 10112 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 160 0 0 0 34 0 0 0 115 1 0 0 56 0 0 0] 8 #() 1392 nil 27 1410 2800 11 2816 -9 2832 1 1504 45 410 ##(Smalltalk.PushButton) 34 20 nil 6192 34 2 8 1140924416 1 10544 nil nil nil 5 nil nil nil 10544 nil 8 1562135984 770 #debugGCI 8 'Debug GCI' 1 1 nil nil false nil nil nil 1186 138 144 34 3 1250 #createAt:extent: 34 2 498 11 5 498 141 51 10544 1250 #isEnabled: 8 #(false) 10544 1250 #text: 34 1 8 'Debug GCI' 10544 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 2 0 0 0 75 0 0 0 27 0 0 0] 8 #() 1392 nil 29 1410 1456 11 1472 141 2144 5 1504 51 170 192 34 12 7584 8 'gemTask' 6304 8 'debugPath' 9472 8 'hostUserID' 8288 8 'loginType' 10112 8 'stoneHost' 6944 8 'hostPassword' nil 1186 138 144 34 1 1250 #createAt:extent: 34 2 498 9 53 498 753 363 6192 1330 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 124 1 0 0 207 0 0 0] 34 11 10544 6304 9792 10112 6624 7584 8288 7264 9472 7952 6944 1392 nil 27 1696 nil nil nil 170 192 34 4 1696 8 'Basic' 6192 8 'Advanced' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 1520 34 2 8 1140916736 1 11264 2914 138 144 34 2 1680 6176 nil 2976 nil nil 1 nil nil nil 11264 nil 8 1561841408 3010 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 11392 7 257 nil 3010 0 nil 11410 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 11456 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #noIcons nil nil nil nil nil 1186 138 144 34 3 1250 #createAt:extent: 34 2 498 1 1 498 769 423 11264 1250 #setSingleSelection: 8 #(1) 11264 1250 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 11264 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 128 1 0 0 211 0 0 0] 8 #() 1392 nil 27 1186 138 144 34 1 1250 #createAt:extent: 34 2 498 1 51 498 769 423 1520 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 128 1 0 0 236 0 0 0] 34 3 1696 6192 11264 1392 nil 27 1410 1456 1 2816 1 1488 51 1442 #fixedParentBottom -59 410 ##(Smalltalk.PushButton) 34 20 nil 416 34 2 8 1140924416 1 11952 nil nil nil 7 nil nil nil 11952 nil 8 1562135984 770 #login 8 'Login' 1 1 nil nil true nil nil nil 1186 138 144 34 3 1250 #createAt:extent: 34 2 498 1 473 498 769 61 11952 1250 #isEnabled: 8 #(false) 11952 1250 #text: 34 1 8 'Login' 11952 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 236 0 0 0 128 1 0 0 10 1 0 0] 8 #() 1392 nil 29 1410 1456 1 2816 1 11936 -59 1504 61 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409289036 131137 12320 nil 480 nil 7 nil nil nil 12320 480 8 1562094976 170 192 688 170 192 34 10 28405 1246790 1 ##(Smalltalk.ToolbarBitmapButton) 12320 1 770 #editUndo 8 'Undo' 1 1 nil 28405 395334 3 ##(Smalltalk.Bitmap) 1 true 864 8 'EditBar.bmp' 912 nil 7 498 1 1 7 28401 12450 12320 1 770 #editPaste 8 'Paste' 1 1 nil 28401 12528 5 28397 12450 12320 1 770 #editCut 8 'Cut' 1 1 nil 28397 12528 1 28403 12450 12320 1 770 #editDelete 8 'Delete' 1 1 nil 28403 12528 11 28399 12450 12320 1 770 #editCopy 8 'Copy' 1 1 nil 28399 12528 3 34 6 12624 12720 12576 12672 12464 1122 12320 1 nil nil 1 nil 498 33 33 498 45 45 nil nil 1186 138 144 34 1 1250 #createAt:extent: 34 2 498 151 1 498 241 51 12320 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 75 0 0 0 0 0 0 0 195 0 0 0 25 0 0 0] 8 #() 1392 nil 27 1410 2800 1 1472 241 1488 1 1504 51 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1140853580 131137 13008 nil 480 nil 519 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 498 193 193 nil 13008 480 8 1562094976 170 192 688 170 192 34 4 28407 1246790 1 ##(Smalltalk.ToolbarSystemButton) 13008 1 770 #getHelpOn 8 'Get help on widget' 1 1 nil 28407 1 23 28409 12450 13008 1 770 #openHelp 8 'Jade Help' 1 1 nil 28409 12514 nil true 864 8 'Tools.bmp' 912 nil 7 498 1857 33 71 34 2 13248 13296 nil nil 1 nil 498 33 33 498 45 45 nil 656198 1 ##(Smalltalk.FlowLayout) 1 1 1 1186 138 144 34 1 1250 #createAt:extent: 34 2 498 391 1 498 379 51 13008 1330 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 0 0 0 0 128 1 0 0 25 0 0 0] 8 #() 1392 nil 27 1410 2800 1 2816 1 1488 1 1504 51 170 192 34 10 592 8 'File Tools' 1520 8 'Tabs' 11952 8 'loginButton' 12320 8 'Edit Tools' 13008 8 'Other Tools' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 265030 4 ##(Smalltalk.Menu) nil true 34 7 984134 2 ##(Smalltalk.CommandMenuItem) 1 770 #fileNew 8 '&New' 9373 1 nil nil nil 13858 1 770 #fileOpen 8 '&Open...' 9375 1 nil nil nil 13858 1 770 #fileSave 8 '&Save' 9383 1 nil nil nil 13858 1 770 #fileSaveAs 8 'Save &As...' 1 1 nil nil nil 13858 1 770 #fileRevert 8 '&Revert' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 13858 1 770 #exit 8 'E&xit' 17639 1 nil nil nil 8 '&File' nil 134217729 nil nil 28423 nil nil 13810 nil true 34 9 13858 1 770 #editUndo 8 '&Undo' 9397 1 nil nil nil 13858 1 770 #editRedo 8 '&Redo' 9395 1 nil nil nil 14114 4097 13858 1 770 #editCut 8 'Cu&t' 9393 1 nil nil nil 13858 1 770 #editCopy 8 '&Copy' 9351 1 nil nil nil 13858 1 770 #editPaste 8 '&Paste' 9389 1 nil nil nil 13858 1 770 #editDelete 8 'De&lete' 1629 1 nil nil nil 14114 4097 13858 1 770 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 8 '&Edit' nil 134217729 nil nil 28439 nil nil 13810 nil true 34 5 13858 1 770 #openHomePage 8 '&GemStone Home Page' 1025 1 nil nil nil 13858 1 770 #openGitHubJadeiteProject 8 '&Jadiete GitHub Project' 1025 1 nil nil nil 13858 1 770 #openGitHubRowanProject 8 '&Rowan GitHub Project' 1025 1 nil nil nil 14114 4097 13858 1 770 #aboutJadeite 8 '&About Jadeite' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 28449 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 14281 818 nil true 864 8 'icons\GS32.ico' nil 818 nil true 864 8 'icons\GS16.ico' nil nil nil 1 nil nil 1186 138 144 34 2 1250 #createAt:extent: 34 2 498 3023 21 498 801 651 416 1250 #text: 34 1 8 'Jadeite Login' 416 1330 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 231 5 0 0 10 0 0 0 119 7 0 0 79 1 0 0] 34 5 592 12320 13008 11952 1520 1392 nil 27 )!

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

