"Filed out from Dolphin Smalltalk 7"!

SmalltalkWorkspace subclass: #JadeiteSmalltalkWorkspace
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteSmalltalkWorkspace guid: (GUID fromString: '{1e23274b-88e2-4989-a5e2-7a8edd04cce6}')!
JadeiteSmalltalkWorkspace comment: ''!
!JadeiteSmalltalkWorkspace categoriesForClass!Development! !
!JadeiteSmalltalkWorkspace methodsFor!

applyOptions
	"Private - Apply the class options to the receiver"

	view backcolor ifNotNil: [:color | color isDefault ifTrue: [self setBackcolor]].
	self
		setFont;
		setCaretColor;
		setWordWrap;
		setTabWidth.
	"textStyles are initialized to class setting by default, but parent presenter might have
	replaced them. N.B. If you blow up here, its because you are trying to use a non-Scintilla
	view with SmalltalkWorkspace. This is no longer supported."
	view textStyles: self textStyles.
	view indicatorStyles: self indicatorStyles.
	self hasSmalltalkStyler ifFalse: [self isAutoCompletionEnabled: false].
	view isAutoCompletionCaseInsensitive: self class isAutoCompletionCaseInsensitive.
	"This has no effect, since we takeover insertion of the completed word, but it's a useful
	way to store the flag on a per-instance basis"
	view isAutoCompletionTruncating: self class isAutoCompletionTruncating.
	view maxCompletionListHeight: 10.
	view maxCompletionListWidth: 40.
	view autoCompletionSeparator: $\x7F.
	self areVariableTipsEnabled ifTrue: [view isBackgroundDwellEnabled: true].
	"#2137"
	view annotationMode: self class annotationMode.
	view wrapIndentMode: self class wrapIndentMode.! !
!JadeiteSmalltalkWorkspace categoriesFor: #applyOptions!operations!options!private! !

