"Filed out from Dolphin Smalltalk 7"!

JadeShell subclass: #JadeiteGitLogPresenter
	instanceVariableNames: 'logTextPresenter'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteGitLogPresenter guid: (GUID fromString: '{87acfb70-3fb9-4280-8468-ecb5474cb281}')!
JadeiteGitLogPresenter comment: ''!
!JadeiteGitLogPresenter categoriesForClass!Unclassified! !
!JadeiteGitLogPresenter methodsFor!

createComponents
	super createComponents.
	logTextPresenter := self add: CodeSourcePresenter new name: 'logTextPresenter'!

logTextPresenter
	^logTextPresenter!

logTextPresenter: anObject
	logTextPresenter := anObject! !
!JadeiteGitLogPresenter categoriesFor: #createComponents!public! !
!JadeiteGitLogPresenter categoriesFor: #logTextPresenter!accessing!private! !
!JadeiteGitLogPresenter categoriesFor: #logTextPresenter:!accessing!private! !

!JadeiteGitLogPresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 nil 551 nil nil nil 416 1180166 ##(Smalltalk.ProportionalLayout) 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1409351680 131073 576 nil 466 8 4278190080 nil 7 nil nil nil 576 852230 ##(Smalltalk.FramingLayout) 170 176 34 4 410 ##(Smalltalk.Toolbar) 34 25 nil 576 34 2 8 1140851500 131137 736 nil 466 8 4278190080 nil 519 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 328198 ##(Smalltalk.Point) 193 193 nil 736 466 816 8 4294905565 170 192 8 #() 170 192 34 24 25255 1246982 ##(Smalltalk.ToolbarSystemButton) 25255 nil 736 1 1180998 4 ##(Smalltalk.CommandDescription) #editReplace 8 'Replace' 1 1 nil 1 27 25233 853766 ##(Smalltalk.ToolbarButton) 25233 nil 736 1 1074 #jadeDisplay 8 'Display' 1 1 nil 395334 3 ##(Smalltalk.Bitmap) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'Tools.bmp' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil nil 7 914 1857 33 55 25235 1122 25235 nil 736 1 1074 #jadeExecute 8 'Execute' 1 1 nil 1200 57 25237 1122 25237 nil 736 1 1074 #jadeInspect 8 'Inspect' 1 1 nil 1200 59 25239 1042 25239 nil 736 1 1074 #fileSave 8 'Save' 1 1 nil 1 17 25241 1042 25241 nil 736 1 1074 #editCut 8 'Cut' 1 1 nil 1 1 25243 1042 25243 nil 736 1 1074 #copySelection 8 'Copy' 1 1 nil 1 3 25245 1042 25245 nil 736 1 1074 #editPaste 8 'Paste' 1 1 nil 1 5 25247 1042 25247 nil 736 1 1074 #editDelete 8 'Delete' 1 1 nil 1 11 25249 1042 25249 nil 736 1 1074 #undo 8 'Undo' 1 1 nil 1 7 25251 1042 25251 nil 736 1 1074 #redo 8 'Redo' 1 1 nil 1 9 25253 1042 25253 nil 736 1 1074 #editFind 8 'Find' 9357 1 nil 1 25 34 15 1136 1328 1376 1050118 ##(Smalltalk.ToolbarSeparator) nil nil 736 3 nil 1 1424 1826 nil nil 736 3 nil 1 1472 1520 1568 1616 1664 1712 1826 nil nil 736 3 nil 1 1760 1056 170 176 34 4 1 117 1200 1 nil 1 nil 914 33 33 914 45 45 nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 914 1 1 914 1399 51 736 2018 #updateSizePosted 992 736 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 187 2 0 0 25 0 0 0] 8 #() 914 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 2226 #fixedParentRight 1 2226 #fixedParentTop 1 2226 #fixedViewTop 51 410 ##(Smalltalk.RichTextEdit) 34 18 nil 576 34 2 8 1144066500 1025 2304 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 466 656 nil 7 265030 4 ##(Smalltalk.Menu) nil true 34 28 984134 2 ##(Smalltalk.CommandMenuItem) 1 1074 #fileSave 8 '&Save' 9383 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 2498 1 1074 #undo 8 '&Undo' 9397 1 nil nil nil 2498 1 1074 #redo 8 'R&edo' 9395 1 nil nil nil 2562 4097 2498 1 1074 #editCut 8 'Cu&t' 9393 1 nil nil nil 2498 1 1074 #editCopy 8 '&Copy' 9351 1 nil nil nil 2498 1 1074 #editPaste 8 '&Paste' 9389 1 nil nil nil 2498 1 1074 #editDelete 8 'De&lete' 1629 1 nil nil nil 2498 1 1074 #editSelectAll 8 'Select &All' 9347 1 nil nil nil 2562 4097 2498 1 1074 #editFind 8 '&Find...' 9357 1 nil nil nil 2498 1 1074 #editFindNext 8 'Find &Next' 9359 1 nil nil nil 2498 1 1074 #editReplace 8 '&Replace...' 9361 1 nil nil nil 2562 4097 2498 1 1074 #jadeInspect 8 '&Inspect' 9379 1 nil nil nil 2498 1 1074 #jadeDisplay 8 '&Display' 9353 1 nil nil nil 2498 1 1074 #jadeExecute 8 'Execute' 9355 1 nil nil nil 2498 1 1074 #jadeDebug 8 'De&bug' 9349 1 nil nil nil 2562 4097 2498 1 1074 #addQuotesToSelection 8 'Add &Quotes' 1 1 nil nil nil 2498 1 1074 #removeQuotesFromSelection 8 'Re&move Quotes' 1 1 nil nil nil 2562 4097 2498 1 1074 #browseSelectedClass 8 'Browse Class' 1 1 nil nil nil 2498 1 1074 #browseImplementors 8 'Browse Implementors' 1 1 nil nil nil 2498 1 1074 #browseSenders 8 'Browse Senders' 1 1 nil nil nil 2562 4097 2498 1 1074 #fileIn 8 'File In' 1 1 nil nil nil 8 '' nil 1 nil nil nil nil nil 834 nil true 866 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 86 101 114 100 97 110 97 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 914 193 193 nil 2304 nil 8 1788103200 852486 ##(Smalltalk.NullConverter) nil nil 9 nil 655622 ##(Smalltalk.EDITSTREAM) 8 #[0 0 0 0 0 0 0 0 48 0 67 3] 1954 138 144 34 4 2018 #createAt:extent: 34 2 914 1 51 914 1399 1193 2304 2018 #contextMenu: 34 1 2464 2304 2018 #text: 34 1 524550 ##(Smalltalk.RichText) 8 '{\rtf1\ansi\deff0{\fonttbl{\f0\fswiss\fprq2\fcharset0 Verdana;}}
{\colortbl ;\red0\green0\blue0;}
\viewkind4\uc1\pard\cf1\lang1033\f0\fs20 
\par }
' 2304 2018 #resetCharFormat 992 2304 2114 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 187 2 0 0 109 2 0 0] 8 #() 2176 nil 27 2194 2240 1 2256 1 2226 #fixedPreviousBottom 1 2226 #fixedParentBottom 1 170 192 34 2 2304 8 'document' nil 1954 138 144 34 1 2018 #createAt:extent: 34 2 914 1 1 914 1399 1243 576 2114 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 187 2 0 0 109 2 0 0] 34 2 736 2304 2176 nil 27 3 false 170 192 34 2 576 8 'logTextPresenter' nil nil nil nil nil 1 nil nil nil nil 1 nil nil 1954 138 144 34 2 2018 #createAt:extent: 34 2 914 7679 21 914 1431 1321 416 2018 #updateMenuBar 992 416 2114 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 202 17 0 0 158 2 0 0] 34 1 576 2176 nil 27 )! !
!JadeiteGitLogPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

