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

saveDocument
	^(MessageBox confirm: self saveDocumentWarningMessage) ifTrue: [super saveDocument]!

saveDocumentAs
	^(MessageBox confirm: self saveDocumentWarningMessage) ifTrue: [super saveDocumentAs]!

saveDocumentWarningMessage
	^'Saving login parameters to disk will save passwords in plain text. Continue?'!

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
saveDocument!menu handlers!public! !
saveDocumentAs!menu handlers!public! !
saveDocumentWarningMessage!menu handlers!private! !
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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1041 911 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 10 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409289036 131137 592 nil 480 nil 7 nil nil nil 592 480 8 1614130560 170 192 8 #() 170 192 34 10 11549 1246790 1 ##(Smalltalk.ToolbarBitmapButton) 592 1 1180998 4 ##(Smalltalk.CommandDescription) #editUndo 8 'Undo' 1 1 nil 11549 395334 3 ##(Smalltalk.Bitmap) 1 true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'EditBar.bmp' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil nil 7 498 1 1 7 11545 738 592 1 770 #editPaste 8 'Paste' 1 1 nil 11545 832 5 11541 738 592 1 770 #editCut 8 'Cut' 1 1 nil 11541 832 1 11547 738 592 1 770 #editDelete 8 'Delete' 1 1 nil 11547 832 11 11543 738 592 1 770 #editCopy 8 'Copy' 1 1 nil 11543 832 3 34 6 1008 1104 960 1056 752 1049158 1 ##(Smalltalk.ToolbarSeparator) 592 1 nil nil 1 nil 498 33 33 498 45 45 nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 151 1 498 241 51 592 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 75 0 0 0 0 0 0 0 195 0 0 0 25 0 0 0] 8 #() 498 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedPreviousRight 1 1490 #fixedViewLeft 241 1490 #fixedParentTop 1 1490 #fixedViewTop 51 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1409289036 131137 1568 nil 480 nil 7 nil nil nil 1568 480 8 1614130560 170 192 688 170 192 34 6 11537 1115206 1 ##(Smalltalk.ToolbarIconButton) 1568 1 770 #fileOpen 8 'Open' 1 1 263494 3 ##(Smalltalk.Icon) nil true 864 8 'FileOpen.ico' 912 11537 11535 1698 1568 1 770 #fileNew 8 'New' 1 1 1762 nil true 864 8 'DocumentShell.ico' nil 11535 11539 1698 1568 1 770 #fileSave 8 'Save' 1 1 1762 nil true 864 8 'FileSave.ico' 912 11539 34 4 1808 1712 1888 1170 1568 1 nil nil 1 nil 498 33 33 498 45 45 nil nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 498 1 1 498 151 51 1568 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 75 0 0 0 25 0 0 0] 8 #() 1440 nil 27 1458 1490 #fixedParentLeft 1 1520 151 1536 1 1552 51 410 ##(Smalltalk.PushButton) 34 20 nil 416 34 2 8 1140924416 1 2224 nil nil nil 7 nil nil nil 2224 nil 8 1614171568 770 #login 8 'Login' 1 1 nil nil true nil nil nil 1234 138 144 34 3 1298 #createAt:extent: 34 2 498 1 707 498 1009 81 2224 1298 #isEnabled: 8 #(false) 2224 1298 #text: 34 1 8 'Login' 2224 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 97 1 0 0 248 1 0 0 137 1 0 0] 8 #() 1440 nil 29 1458 2208 1 1490 #fixedParentRight 1 1490 #fixedParentBottom -79 2608 1 410 ##(Smalltalk.CardContainer) 34 16 nil 416 34 2 8 1409286144 131073 2624 nil 480 nil 7 nil nil nil 2624 656710 1 ##(Smalltalk.CardLayout) 138 144 34 2 721414 ##(Smalltalk.Association) 8 'Basic' 410 ##(Smalltalk.ContainerView) 34 15 nil 2624 34 2 8 1140850688 131073 2800 nil nil nil 7 nil nil nil 2800 530 170 176 34 24 410 ##(Smalltalk.TextEdit) 34 16 nil 2800 34 2 8 1140916352 1025 2912 nil 480 nil 7 nil nil nil 2912 nil 8 1614163376 852486 ##(Smalltalk.NullConverter) nil nil 1 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 461 261 498 523 61 2912 1298 #setMarginWidths: 34 1 8 #(3 3) 2912 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 230 0 0 0 130 0 0 0 235 1 0 0 160 0 0 0] 8 #() 1440 nil 27 1458 1504 11 2592 -9 1490 #fixedPreviousTop 1 1490 #fixedPreviousBottom 1 410 ##(Smalltalk.StaticText) 34 16 nil 2800 34 2 8 1140850944 1 3280 nil nil nil 7 nil nil nil 3280 nil 8 1614019776 2994 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 11 261 498 441 61 3280 1298 #text: 34 1 8 'Stone Name:' 3280 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 130 0 0 0 225 0 0 0 160 0 0 0] 8 #() 1440 nil 27 1458 2208 11 1520 441 3264 21 3264 81 410 ##(Smalltalk.TextEdit) 34 16 nil 2800 34 2 8 1140916352 1025 3600 nil 480 nil 7 nil nil nil 3600 nil 8 1614163376 2994 nil nil 1 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 461 341 498 523 61 3600 1298 #setMarginWidths: 34 1 8 #(3 3) 3600 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 230 0 0 0 170 0 0 0 235 1 0 0 200 0 0 0] 8 #() 1440 nil 27 1458 1504 11 2592 -9 3248 1 3264 1 410 ##(Smalltalk.StaticText) 34 16 nil 2800 34 2 8 1140850944 1 3920 nil nil nil 7 nil nil nil 3920 nil 8 1614019776 2994 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 11 21 498 441 61 3920 1298 #text: 34 1 8 'GemStone/Smalltalk Version:' 3920 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 10 0 0 0 225 0 0 0 40 0 0 0] 8 #() 1440 nil 27 1458 2208 11 1520 441 1536 21 1536 81 410 ##(Smalltalk.StaticText) 34 16 nil 2800 34 2 8 1140850944 1 4240 nil nil nil 7 nil nil nil 4240 nil 8 1614019776 2994 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 11 341 498 441 61 4240 1298 #text: 34 1 8 'GemStone User ID:' 4240 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 170 0 0 0 225 0 0 0 200 0 0 0] 8 #() 1440 nil 27 1458 2208 11 1520 441 3264 21 3264 81 410 ##(Smalltalk.ComboBox) 34 17 nil 2800 34 2 8 1144063491 1025 4560 590662 2 ##(Smalltalk.ListModel) 138 144 688 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 nil nil nil 4560 nil 8 1613963360 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 ##(Smalltalk.Message) 8 'doIt' 8 '[:libClass | libClass displayName]' 8 #[30 105 226 0 106] #displayName 4736 7 257 nil 8 #() 401 1234 138 144 34 1 1298 #createAt:extent: 34 2 498 461 21 498 523 51 4560 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 230 0 0 0 10 0 0 0 235 1 0 0 35 0 0 0] 8 #() 1440 nil 27 1458 1504 11 2592 -9 3248 1 3264 1 410 ##(Smalltalk.TextEdit) 34 16 nil 2800 34 2 8 1140916384 1025 5024 nil 480 nil 7 nil nil nil 5024 nil 8 1614163376 2994 nil nil 1 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 461 421 498 523 61 5024 1298 #setMarginWidths: 34 1 8 #(3 3) 5024 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 230 0 0 0 210 0 0 0 235 1 0 0 240 0 0 0] 8 #() 1440 nil 27 1458 1504 11 2592 -9 3248 1 3264 1 410 ##(Smalltalk.StaticText) 34 16 nil 2800 34 2 8 1140850944 1 5344 nil nil nil 7 nil nil nil 5344 nil 8 1614019776 2994 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 11 181 498 441 61 5344 1298 #text: 34 1 8 'NetLDI Service Name or Port:' 5344 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 90 0 0 0 225 0 0 0 120 0 0 0] 8 #() 1440 nil 27 1458 2208 11 1520 441 3264 21 3264 81 410 ##(Smalltalk.StaticText) 34 16 nil 2800 34 2 8 1140850944 1 5664 nil nil nil 7 nil nil nil 5664 nil 8 1614019776 2994 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 11 101 498 441 61 5664 1298 #text: 34 1 8 'RPC Gem Host Name or IP:' 5664 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 50 0 0 0 225 0 0 0 80 0 0 0] 8 #() 1440 nil 27 1458 2208 11 1520 441 3264 21 3264 81 410 ##(Smalltalk.TextEdit) 34 16 nil 2800 34 2 8 1140916352 1025 5984 nil 480 nil 7 nil nil nil 5984 nil 8 1614163376 2994 nil nil 1 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 461 101 498 523 61 5984 1298 #setMarginWidths: 34 1 8 #(3 3) 5984 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 230 0 0 0 50 0 0 0 235 1 0 0 80 0 0 0] 8 #() 1440 nil 27 1458 1504 11 2592 -9 3248 1 3264 1 410 ##(Smalltalk.StaticText) 34 16 nil 2800 34 2 8 1140850944 1 6304 nil nil nil 7 nil nil nil 6304 nil 8 1614019776 2994 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 11 421 498 441 61 6304 1298 #text: 34 1 8 'GemStone Password:' 6304 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 210 0 0 0 225 0 0 0 240 0 0 0] 8 #() 1440 nil 27 1458 2208 11 1520 441 3264 21 3264 81 410 ##(Smalltalk.TextEdit) 34 16 nil 2800 34 2 8 1140916352 1025 6624 nil 480 nil 7 nil nil nil 6624 nil 8 1614163376 2994 nil nil 1 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 461 181 498 523 61 6624 1298 #setMarginWidths: 34 1 8 #(3 3) 6624 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 230 0 0 0 90 0 0 0 235 1 0 0 120 0 0 0] 8 #() 1440 nil 27 1458 1504 11 2592 -9 3248 1 3264 1 170 192 34 12 2912 8 'stoneName' 3600 8 'userID' 6624 8 'gemService' 5024 8 'password' 5984 8 'gemHost' 4560 8 'versionList' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 498 9 53 498 993 597 2800 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 244 1 0 0 68 1 0 0] 34 12 3920 4560 5664 5984 5344 6624 3280 2912 4240 3600 6304 5024 1440 nil 27 2754 8 'Advanced' 410 ##(Smalltalk.ContainerView) 34 15 nil 2624 34 2 8 1140850688 131073 7264 nil nil nil 5 nil nil nil 7264 530 170 176 34 22 410 ##(Smalltalk.TextEdit) 34 16 nil 7264 34 2 8 1140916352 1025 7376 nil 480 nil 5 nil nil nil 7376 nil 8 1614163376 2994 nil nil 1 1234 138 144 34 3 1298 #createAt:extent: 34 2 498 321 181 498 663 61 7376 1298 #text: 34 1 8 'gemnetobject' 7376 1298 #setMarginWidths: 34 1 8 #(3 3) 7376 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 160 0 0 0 90 0 0 0 235 1 0 0 120 0 0 0] 8 #() 1440 nil 27 1458 1504 11 2592 -9 3248 1 3264 1 410 ##(Smalltalk.StaticText) 34 16 nil 7264 34 2 8 1140850944 1 7744 nil nil nil 5 nil nil nil 7744 nil 8 1614019776 2994 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 11 431 498 301 61 7744 1298 #text: 34 1 8 'Password:' 7744 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 215 0 0 0 155 0 0 0 245 0 0 0] 8 #() 1440 nil 27 1458 2208 11 1490 #fixedPreviousLeft -9 3264 31 3264 91 410 ##(Smalltalk.StaticText) 34 16 nil 7264 34 2 8 1140850944 1 8080 nil nil nil 5 nil nil nil 8080 nil 8 1614019776 2994 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 11 341 498 301 61 8080 1298 #text: 34 1 8 'OS User ID:' 8080 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 170 0 0 0 155 0 0 0 200 0 0 0] 8 #() 1440 nil 27 1458 2208 11 8064 301 3264 11 3264 71 410 ##(Smalltalk.StaticText) 34 16 nil 7264 34 2 8 1140850944 1 8400 nil nil nil 5 nil nil nil 8400 nil 8 1614019776 2994 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 11 181 498 301 61 8400 1298 #text: 34 1 8 'NetLDI Task Name:' 8400 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 90 0 0 0 155 0 0 0 120 0 0 0] 8 #() 1440 nil 27 1458 2208 11 8064 -9 3264 31 3264 91 410 ##(Smalltalk.TextEdit) 34 16 nil 7264 34 2 8 1140916352 1025 8720 nil 480 nil 5 nil nil nil 8720 nil 8 1614163376 2994 nil nil 1 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 321 341 498 663 61 8720 1298 #setMarginWidths: 34 1 8 #(3 3) 8720 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 160 0 0 0 170 0 0 0 235 1 0 0 200 0 0 0] 8 #() 1440 nil 27 1458 1504 11 2592 -9 3248 1 3264 1 410 ##(Smalltalk.TextEdit) 34 16 nil 7264 34 2 8 1140916352 1025 9040 nil 480 nil 5 nil nil nil 9040 nil 8 1614163376 2994 nil nil 1 1234 138 144 34 4 1298 #createAt:extent: 34 2 498 321 91 498 663 61 9040 1298 #text: 34 1 8 'localhost' 9040 1298 #selectionRange: 34 1 525062 ##(Smalltalk.Interval) 3 19 3 9040 1298 #setMarginWidths: 34 1 8 #(3 3) 9040 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 160 0 0 0 45 0 0 0 235 1 0 0 75 0 0 0] 8 #() 1440 nil 27 1458 1504 11 2592 -9 3248 1 3264 1 410 ##(Smalltalk.TextEdit) 34 16 nil 7264 34 2 8 1140916384 1025 9472 nil 480 nil 5 nil nil nil 9472 nil 8 1614163376 2994 nil nil 1 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 321 431 498 663 61 9472 1298 #setMarginWidths: 34 1 8 #(3 3) 9472 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 160 0 0 0 215 0 0 0 235 1 0 0 245 0 0 0] 8 #() 1440 nil 27 1458 1504 11 2592 -9 3248 1 3264 1 410 ##(Smalltalk.StaticText) 34 16 nil 7264 34 2 8 1140850944 1 9792 nil nil nil 5 nil nil nil 9792 nil 8 1614019776 2994 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 11 91 498 301 61 9792 1298 #text: 34 1 8 'Stone Host (from Gem):' 9792 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 45 0 0 0 155 0 0 0 75 0 0 0] 8 #() 1440 nil 27 1458 2208 11 1520 301 3264 21 3264 81 410 ##(Smalltalk.StaticText) 34 16 nil 7264 34 2 8 1140850944 65 10112 nil nil nil 5 nil nil nil 10112 nil 8 1614019776 2994 nil nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 11 271 498 973 61 10112 1298 #text: 34 1 8 'Following fields are only required if NetLDI is not in guest mode:
' 10112 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 135 0 0 0 235 1 0 0 165 0 0 0] 8 #() 1440 nil 27 1458 2208 11 2592 -9 3264 31 3264 91 410 ##(Smalltalk.PushButton) 34 20 nil 7264 34 2 8 1140924416 1 10432 nil nil nil 5 nil nil nil 10432 nil 8 1614171568 770 #debugGCI 8 'Debug GCI' 1 1 nil nil false nil nil nil 1234 138 144 34 3 1298 #createAt:extent: 34 2 498 11 21 498 201 51 10432 1298 #isEnabled: 8 #(false) 10432 1298 #text: 34 1 8 'Debug GCI' 10432 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 10 0 0 0 105 0 0 0 35 0 0 0] 8 #() 1440 nil 29 1458 2208 11 1520 201 1536 21 1536 71 410 ##(Smalltalk.StaticPath) 34 17 nil 7264 34 2 8 1140850944 1 10800 nil nil nil 5 nil nil nil 10800 nil 8 1614019776 2994 nil nil nil 8 'XXX' 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 221 21 498 763 51 10800 1298 #text: 34 1 10896 10800 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 110 0 0 0 10 0 0 0 235 1 0 0 35 0 0 0] 8 #() 1440 nil 27 1458 1504 11 2592 -9 3248 1 3264 1 170 192 34 10 8720 8 'hostUserID' 9040 8 'stoneHost' 9472 8 'hostPassword' 10800 8 'debugPath' 7376 8 'gemTask' nil 1234 138 144 34 1 1298 #createAt:extent: 34 2 498 9 53 498 993 597 7264 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 4 0 0 0 26 0 0 0 244 1 0 0 68 1 0 0] 34 11 10432 10800 9792 9040 8400 7376 10112 8080 8720 7744 9472 1440 nil 27 2800 nil nil nil 170 192 34 4 2800 8 'Basic' 7264 8 'Advanced' nil 410 ##(Smalltalk.TabViewXP) 34 28 nil 2624 34 2 8 1140916736 1 11456 4626 138 144 34 2 2784 7248 nil 4688 nil nil 1 nil nil nil 11456 nil 8 1613876992 4722 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 ##(Smalltalk.ListControlView) #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] #displayString 11584 7 257 nil 4722 0 nil 11602 2 3 ##(Smalltalk.IconicListAbstract) #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] #iconImageIndex 11648 7 257 nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil nil nil #noIcons nil nil nil nil nil 1234 138 144 34 3 1298 #createAt:extent: 34 2 498 1 1 498 1009 657 11456 1298 #setSingleSelection: 8 #(1) 11456 1298 #tcmSetExtendedStyle:dwExStyle: 8 #(-1 0) 11456 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 248 1 0 0 72 1 0 0] 8 #() 1440 nil 27 1234 138 144 34 1 1298 #createAt:extent: 34 2 498 1 51 498 1009 657 2624 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 248 1 0 0 97 1 0 0] 34 3 2800 7264 11456 1440 nil 27 1458 2208 1 2592 1 1536 51 2608 -79 410 ##(Smalltalk.Toolbar) 34 25 nil 416 34 2 8 1140853580 131137 12128 nil 480 nil 519 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 498 193 193 nil 12128 480 8 1614130560 170 192 688 170 192 34 4 11551 1246790 1 ##(Smalltalk.ToolbarSystemButton) 12128 1 770 #getHelpOn 8 'Get help on widget' 1 1 nil 11551 1 23 11553 738 12128 1 770 #openHelp 8 'Jade Help' 1 1 nil 11553 818 nil true 864 8 'Tools.bmp' 912 nil 7 498 1857 33 71 34 2 12368 12416 nil nil 1 nil 498 33 33 498 45 45 nil 656198 1 ##(Smalltalk.FlowLayout) 1 1 1 1234 138 144 34 1 1298 #createAt:extent: 34 2 498 391 1 498 619 51 12128 1378 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 195 0 0 0 0 0 0 0 248 1 0 0 25 0 0 0] 8 #() 1440 nil 27 1458 1504 1 2592 1 1536 1 1552 51 170 192 34 10 592 8 'Edit Tools' 1568 8 'File Tools' 2224 8 'loginButton' 2624 8 'Tabs' 12128 8 'Other Tools' nil 461638 4 ##(Smalltalk.MenuBar) nil true 34 3 265030 4 ##(Smalltalk.Menu) nil true 34 7 984134 2 ##(Smalltalk.CommandMenuItem) 1 770 #fileNew 8 '&New' 9373 1 nil nil nil 12978 1 770 #fileOpen 8 '&Open...' 9375 1 nil nil nil 12978 1 770 #fileSave 8 '&Save' 9383 1 nil nil nil 12978 1 770 #fileSaveAs 8 'Save &As...' 1 1 nil nil nil 12978 1 770 #fileRevert 8 '&Revert' 1 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 12978 1 770 #exit 8 'E&xit' 17639 1 nil nil nil 8 '&File' nil 134217729 nil nil 11567 nil nil 12930 nil true 34 9 12978 1 770 #editUndo 8 '&Undo' 9397 1 nil nil nil 12978 1 770 #editRedo 8 '&Redo' 9395 1 nil nil nil 13234 4097 12978 1 770 #editCut 8 'Cu&t' 9393 1 nil nil nil 12978 1 770 #editCopy 8 '&Copy' 9351 1 nil nil nil 12978 1 770 #editPaste 8 '&Paste' 9389 1 nil nil nil 12978 1 770 #editDelete 8 'De&lete' 1629 1 nil nil nil 13234 4097 12978 1 770 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 8 '&Edit' nil 134217729 nil nil 11583 nil nil 12930 nil true 34 5 12978 1 770 #openHomePage 8 '&GemStone Home Page' 1025 1 nil nil nil 12978 1 770 #openGitHubJadeiteProject 8 '&Jadiete GitHub Project' 1025 1 nil nil nil 12978 1 770 #openGitHubRowanProject 8 '&Rowan GitHub Project' 1025 1 nil nil nil 13234 4097 12978 1 770 #aboutJadeite 8 '&About Jadeite' 1 1 nil nil nil 8 '&Help' nil 134217729 nil nil 11593 nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil nil 10133 1762 nil true 864 8 'icons\GS32.ico' nil 1762 nil true 864 8 'icons\GS16.ico' nil nil nil 1 nil nil 1234 138 144 34 2 1298 #createAt:extent: 34 2 498 3839 21 498 1041 911 416 1298 #text: 34 1 8 'Jadeite Login' 416 1378 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 127 7 0 0 10 0 0 0 135 9 0 0 209 1 0 0] 34 5 1568 592 12128 2224 2624 1440 nil 27 )!

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

