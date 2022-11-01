"Filed out from Dolphin Smallalk"!

ChoicePrompter subclass: #JadeiteGitChoicePrompter
	instanceVariableNames: 'gitUrl'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteGitChoicePrompter guid: (GUID fromString: '{897a6627-3131-443e-ab51-541fe488bfb3}')!
JadeiteGitChoicePrompter comment: ''!
!JadeiteGitChoicePrompter categoriesForClass!MVP-Presenters! !
!JadeiteGitChoicePrompter methodsFor!

createComponents
	super createComponents.
	gitUrl := self add: TextPresenter new name: 'gitUrlText'.!

gitUrl
	^gitUrl! !
!JadeiteGitChoicePrompter categoriesForMethods!
createComponents!initialization!public! !
gitUrl!accessing!private! !
!

!JadeiteGitChoicePrompter class methodsFor!

defaultView
	^'Default view'!

on: aValueModel choices: aSequenceableCollection caption: aStringCaptionOrNil gitUrl: gitUrl
	"Answer a dialog capable of allowing the user to choose from aSequenceableCollection.
	The initial list selection is determined by the value of aValueModel and the
	list choice made is sent back as this model's value. The dialog is given a caption
	according to aStringCaptionOrNil. If nil the default caption is used."

	| prompter | 
	(prompter := self create: self defaultView)
		choices: aSequenceableCollection;
		model: aValueModel.
	aStringCaptionOrNil notNil ifTrue: [
		prompter caption: aStringCaptionOrNil ].
	prompter gitUrl value: 'Project Url: ', gitUrl. 
	^prompter!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.DialogView) 34 30 nil nil 8 #(13369344 65536) 416 nil 655878 ##(Smalltalk.ThemeColor) #dialog 328198 ##(Smalltalk.Point) 1201 711 677 nil 263174 ##(Smalltalk.Font) nil true 524550 ##(Smalltalk.LOGFONTW) 8 #[244 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 83 0 101 0 103 0 111 0 101 0 32 0 85 0 73 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 498 193 193 nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.ListBox) 34 17 nil 416 34 2 8 1144062209 1025 688 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 327686 ##(Smalltalk.Color) #default nil 7 nil nil nil 688 nil 8 1607482368 459270 ##(Smalltalk.Message) #displayString 8 #() 8 #() nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 15 95 498 949 445 688 1026 #horizontalExtent: 8 #(0) 688 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 7 0 0 0 47 0 0 0 225 1 0 0 13 1 0 0] 8 #() 498 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 1250 #fixedParentRight 1 1250 #fixedParentTop 81 1250 #fixedParentBottom -79 410 ##(Smalltalk.StaticText) 34 16 nil 416 34 2 8 1140916480 1 1328 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil 864 nil 7 nil nil nil 1328 nil 8 1607531712 852486 ##(Smalltalk.NullConverter) nil nil nil 962 138 144 34 1 1026 #createAt:extent: 34 2 498 15 15 498 949 71 1328 1138 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 7 0 0 0 7 0 0 0 225 1 0 0 42 0 0 0] 8 #() 1200 nil 27 1218 1264 1 1280 1 1296 1 1296 71 410 ##(Smalltalk.ReferenceView) 34 14 nil 416 34 2 8 1140850688 131073 1680 nil nil nil 7 nil nil nil 1680 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.Presenter) #resource_OK_Cancel_button_block nil 962 138 144 34 1 1026 #createAt:extent: 34 2 498 15 549 498 949 71 1680 1138 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 7 0 0 0 18 1 0 0 225 1 0 0 53 1 0 0] 800 1200 nil 27 1218 1264 1 1280 1 1312 -69 1312 1 170 192 34 4 1328 8 'gitUrlText' 688 8 'choices' 590342 ##(Smalltalk.Rectangle) 498 15 15 498 17 15 nil nil nil nil 12777 nil nil nil 498 501 311 1 nil nil 590598 ##(Smalltalk.Semaphore) nil nil 1 nil 8 1998138720 962 138 144 34 2 1026 #createAt:extent: 34 2 498 6911 21 498 1011 711 416 1026 #text: 34 1 8 'Choose one of:' 416 1138 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 127 13 0 0 10 0 0 0 120 15 0 0 109 1 0 0] 34 3 1328 688 1680 1200 nil 27 )! !
!JadeiteGitChoicePrompter class categoriesForMethods!
defaultView!constants!private! !
on:choices:caption:gitUrl:!instance creation!public! !
resource_Default_view!public!resources-views! !
!

