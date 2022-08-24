"Filed out from Dolphin Smallalk"!

Dialog subclass: #JadeiteServerFileSelectorDialog
	instanceVariableNames: 'fileSelectorPresenter'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteServerFileSelectorDialog guid: (GUID fromString: '{70f59a0e-a3b1-4740-ab3e-4b15f70b06a0}')!
JadeiteServerFileSelectorDialog comment: ''!
!JadeiteServerFileSelectorDialog categoriesForClass!Unclassified! !
!JadeiteServerFileSelectorDialog methodsFor!

createComponents
	super createComponents.
	fileSelectorPresenter := self add: JadeiteServerFileSelectorPresenter new name: 'fileSelectorPresenter'.
!

pathText
	^fileSelectorPresenter pathText!

select
	fileSelectorPresenter select.
	self ok.
	^fileSelectorPresenter pathText value!

setPathText: thePathText
	fileSelectorPresenter pathText: thePathText!

setPresenterModel
	fileSelectorPresenter model: model!

shellName

	^'Jadeite Select File Dialog'.!

showDirectoryContents
	fileSelectorPresenter showDirectoryContents!

updateCaptionInSession: session
	self caption: (session titleBarFor: self shellName)! !
!JadeiteServerFileSelectorDialog categoriesForMethods!
createComponents!initialization!public! !
pathText!initialization!public! !
select!public! !
setPathText:!initialization!public! !
setPresenterModel!actions!public! !
shellName!constants!private! !
showDirectoryContents!actions!public! !
updateCaptionInSession:!overrides!private! !
!

!JadeiteServerFileSelectorDialog class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.DialogView) 34 30 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1201 801 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ReferenceView) 34 14 nil 416 34 2 8 1140850688 131073 592 nil nil nil 7 nil nil nil 592 1180230 1 ##(Smalltalk.ResourceIdentifier) ##(Smalltalk.JadeiteServerFileSelectorPresenter) #resource_Default_view nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 1 1 498 1169 723 592 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 105 1 0 0] 8 #() 498 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 946 #fixedParentRight 1 946 #fixedParentTop 1 946 #fixedParentBottom 1 170 192 34 2 592 8 'fileSelectorPresenter' 590342 ##(Smalltalk.Rectangle) 498 1 1 498 1 1 nil nil nil nil 3 nil nil nil nil 1 nil nil 590598 ##(Smalltalk.Semaphore) nil nil 1 false 8 2006068576 690 138 144 34 1 754 #createAt:extent: 34 2 498 6947 21 498 1201 801 416 834 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 145 13 0 0 10 0 0 0 233 15 0 0 154 1 0 0] 34 1 592 896 nil 27 )!

showOnSession: aGciSession
	^self showOnSession: aGciSession defaultPath: JadePresenter rowanProjectsHomeEnvVarString!

showOnSession: aGciSession defaultPath: path
	| inst service answer |
	service := RowanFileService new path: path. 
	service session: aGciSession.
	inst := self createOn: service.
	inst setPresenterModel.
	inst setPathText: path.
	inst showDirectoryContents.
	inst updateCaptionInSession: aGciSession.
	answer := inst showModal.
	^answer ifNil: [nil] ifNotNil: [inst pathText value]! !
!JadeiteServerFileSelectorDialog class categoriesForMethods!
resource_Default_view!public!resources-views! !
showOnSession:!instance creation!public! !
showOnSession:defaultPath:!instance creation!public! !
!

