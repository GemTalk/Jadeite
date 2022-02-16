"Filed out from Dolphin Smallalk"!

JadeShell subclass: #JadeiteServerFileSelector
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteServerFileSelector guid: (GUID fromString: '{70f59a0e-a3b1-4740-ab3e-4b15f70b06a0}')!
JadeiteServerFileSelector comment: ''!
!JadeiteServerFileSelector categoriesForClass!Unclassified! !
!JadeiteServerFileSelector methodsFor!

postOpen	
	| service |
	service := RowanFileService new path: '$ROWAN_PROJECTS_HOME'.
	service session: gciSession. 
	myPresenter model: service. 
	myPresenter postOpen!

presenterClass
	^JadeiteServerFileSelectorPresenter!

select
	^myPresenter select!

updateCaption
	self caption: (gciSession titleBarFor: 'Server File Selector')! !
!JadeiteServerFileSelector categoriesForMethods!
postOpen!public! !
presenterClass!accessing!public! !
select!actions!public! !
updateCaption!public! !
!

!JadeiteServerFileSelector class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default 328198 ##(Smalltalk.Point) 1201 801 549 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 592 nil nil nil 7 nil nil nil 592 530 170 176 34 10 410 ##(Smalltalk.TextEdit) 34 16 nil 592 34 2 8 1149239424 1 704 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 7 nil nil nil 704 nil 8 1591815600 852486 ##(Smalltalk.NullConverter) nil nil 1 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 498 121 11 498 909 61 704 946 #text: 34 1 8 'c:\Program Files\Dolphin Smalltalk' 704 946 #setMarginWidths: 34 1 8 #(3 3) 704 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 60 0 0 0 5 0 0 0 2 2 0 0 35 0 0 0] 8 #() 498 193 193 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 121 1234 #fixedParentRight -139 1234 #fixedParentTop 11 1234 #fixedViewTop 61 410 ##(Smalltalk.StaticText) 34 16 nil 592 34 2 8 1140850944 65 1312 nil nil nil 7 nil nil nil 1312 nil 8 1591672000 850 nil nil nil 882 138 144 34 2 946 #createAt:extent: 34 2 498 11 11 498 101 61 1312 946 #text: 34 1 8 'Path:
' 1312 1122 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 5 0 0 0 55 0 0 0 35 0 0 0] 8 #() 1184 nil 27 1202 1248 11 1248 111 1280 11 1296 61 410 ##(Smalltalk.ListBox) 34 17 nil 592 34 2 8 1412497665 1025 1632 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 7 nil nil nil 1632 nil 8 1591622656 459270 ##(Smalltalk.Message) #displayString 8 #() 8 #() false 882 138 144 34 2 946 #createAt:extent: 34 2 498 11 101 498 1149 543 1632 946 #horizontalExtent: 8 #(0) 1632 1122 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 50 0 0 0 67 2 0 0 65 1 0 0] 8 #() 1184 nil 27 1202 1248 11 1264 -9 1280 101 1234 #fixedParentBottom -79 410 ##(Smalltalk.ToolButton) 34 14 nil 592 34 2 8 1140850688 131073 2096 nil nil nil 7 nil nil nil 2096 nil 410 ##(Smalltalk.Toolbar) 34 25 nil 2096 34 2 8 1140853580 131137 2160 nil nil nil 3 nil nil nil 2160 nil 8 1591782784 nil 170 192 34 2 17357 1115206 1 ##(Smalltalk.ToolbarIconButton) 2160 1 1180998 4 ##(Smalltalk.CommandDescription) #pop 8 'Pop' 1 1 263494 3 ##(Smalltalk.Icon) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'C:\Users\ewinger\source\repos\Dolphin7121\Dolphin\Core\DolphinVM\Res\FolderUp.ico' nil 17357 34 1 2288 nil nil 3 nil 498 49 49 498 71 51 nil nil 882 138 144 34 1 946 #createAt:extent: 34 2 498 1 1 498 81 61 2160 1122 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 40 0 0 0 30 0 0 0] 8 #() 1184 nil 27 882 138 144 34 2 946 #createAt:extent: 34 2 498 1059 11 498 81 61 2096 946 #isEnabled: 8 #(false) 2096 1122 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 17 2 0 0 5 0 0 0 57 2 0 0 35 0 0 0] 34 1 2160 1184 nil 27 1202 1264 -109 1264 -29 1280 11 1296 61 410 ##(Smalltalk.PushButton) 34 20 nil 592 34 2 8 1140924416 1 2848 nil nil nil 7 nil nil nil 2848 nil 8 1591823792 2306 #select 8 'Select' 1 1 nil nil false nil nil nil 882 138 144 34 3 946 #createAt:extent: 34 2 498 959 653 498 201 61 2848 946 #isEnabled: 8 #(false) 2848 946 #text: 34 1 8 'Select' 2848 1122 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 223 1 0 0 70 1 0 0 67 2 0 0 100 1 0 0] 8 #() 1184 nil 29 1202 1264 -209 1264 -9 2080 -69 2080 -9 170 192 34 4 1632 8 'directoryContentsList' 704 8 'pathText' nil 882 138 144 34 1 946 #createAt:extent: 34 2 498 1 1 498 1169 723 592 1122 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 72 2 0 0 105 1 0 0] 34 5 704 1312 1632 2848 2096 1184 nil 27 1202 1248 1 1264 1 1280 1 2080 1 170 192 1744 nil nil nil nil nil 1 nil nil nil nil 1 nil nil 882 138 144 34 1 946 #createAt:extent: 34 2 498 6513 21 498 1201 801 416 1122 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 184 12 0 0 10 0 0 0 16 15 0 0 154 1 0 0] 34 1 592 1184 nil 27 )!

showOnSession: aGciSession

	| inst | 
	inst := super showOnSession: aGciSession.
	^inst postOpen
	
	! !
!JadeiteServerFileSelector class categoriesForMethods!
resource_Default_view!public!resources-views! !
showOnSession:!instance creation!public! !
!

