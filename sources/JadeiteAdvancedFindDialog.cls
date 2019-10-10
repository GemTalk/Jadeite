"Filed out from Dolphin Smalltalk 7"!

AdvancedFindDialog subclass: #JadeiteAdvancedFindDialog
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteAdvancedFindDialog guid: (GUID fromString: '{4fbbe787-7c4f-44a6-b3ef-b588f051eb2e}')!
JadeiteAdvancedFindDialog comment: ''!
!JadeiteAdvancedFindDialog categoriesForClass!MVP-Presenters! !
!JadeiteAdvancedFindDialog methodsFor!

findNext
	(self model aspectValue: #action) value: #findNext.
	ownerView onFind: self model value!

initialize
	super initialize.
	flags := 0.
	validationBlock := [:details | self isValidSearch: details]!

isRegExpEnabled
	^false!

isRegExpEnabled: aBoolean
	flags := flags mask: RegExpMask set: false.
	self invalidateUserInterface!

isWildCardEnabled
	^true!

isWildCardEnabled: aBoolean 
	flags := flags mask: WildCardMask set: true.
	self invalidateUserInterface!

modePresenter
	"for testing"

	^modePresenter!

patternPresenter

	^patternPresenter!

wrapPresenter
	"for testing"

	^wrapPresenter! !
!JadeiteAdvancedFindDialog categoriesFor: #findNext!commands!public! !
!JadeiteAdvancedFindDialog categoriesFor: #initialize!initializing!public! !
!JadeiteAdvancedFindDialog categoriesFor: #isRegExpEnabled!public!testing! !
!JadeiteAdvancedFindDialog categoriesFor: #isRegExpEnabled:!accessing!public! !
!JadeiteAdvancedFindDialog categoriesFor: #isWildCardEnabled!public!testing! !
!JadeiteAdvancedFindDialog categoriesFor: #isWildCardEnabled:!accessing!public! !
!JadeiteAdvancedFindDialog categoriesFor: #modePresenter!accessing!public! !
!JadeiteAdvancedFindDialog categoriesFor: #patternPresenter!accessing!public! !
!JadeiteAdvancedFindDialog categoriesFor: #wrapPresenter!accessing!public! !

!JadeiteAdvancedFindDialog class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.DialogView) 34 30 nil nil 8 #(13369344 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 328198 ##(Smalltalk.Point) 1171 401 679 nil nil nil 416 788230 ##(Smalltalk.BorderLayout) 11 1 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 576 nil nil nil 7 nil nil nil 576 656198 1 ##(Smalltalk.FlowLayout) 1 11 1 170 192 34 4 410 ##(Smalltalk.PushButton) 34 20 nil 576 34 2 8 1140924416 1 704 nil nil nil 7 nil nil nil 704 nil 8 4294903093 1180998 4 ##(Smalltalk.CommandDescription) #cancel 8 'C&lose' 1 1 nil nil false nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 514 1 77 514 151 47 704 898 #text: 34 1 8 'C&lose' 704 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 38 0 0 0 75 0 0 0 61 0 0 0] 8 #() 514 193 193 nil 29 8 'cancel' 410 ##(Smalltalk.PushButton) 34 20 nil 576 34 2 8 1141055488 1 1120 nil nil nil 7 nil nil nil 1120 nil 8 4294903093 786 #ok 8 '&Find' 1 5 nil nil true nil nil nil 834 138 144 34 3 898 #createAt:extent: 34 2 514 1 21 514 151 47 1120 898 #isEnabled: 8 #(false) 1120 898 #text: 34 1 8 '&Find' 1120 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 10 0 0 0 75 0 0 0 33 0 0 0] 8 #() 1088 nil 29 8 'ok' 590342 ##(Smalltalk.Rectangle) 514 1 21 514 1 1 834 138 144 34 1 898 #createAt:extent: 34 2 514 969 1 514 161 323 576 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 228 1 0 0 0 0 0 0 52 2 0 0 161 0 0 0] 34 2 1120 704 1088 nil 27 nil 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 1712 nil nil nil 7 nil nil nil 1712 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.TextEdit) 34 16 nil 1712 34 2 8 1141047424 1025 1840 nil 466 496 nil 7 nil nil nil 1840 nil 8 4294904635 852486 ##(Smalltalk.NullConverter) nil nil 5 834 138 144 34 1 898 #createAt:extent: 34 2 514 145 29 514 781 51 1840 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 72 0 0 0 14 0 0 0 206 1 0 0 39 0 0 0] 8 #() 1088 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedPreviousRight 19 2162 #fixedParentRight -13 2162 #fixedPreviousTop -1 2162 #fixedViewTop 51 410 ##(Smalltalk.ContainerView) 34 15 nil 1712 34 2 8 1140850688 131073 2240 nil nil nil 7 nil nil nil 2240 642 11 1 1 170 192 8 #() 1490 514 1 11 514 1 1 834 138 144 34 1 898 #createAt:extent: 34 2 514 15 89 514 935 211 2240 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 7 0 0 0 44 0 0 0 218 1 0 0 149 0 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 2240 34 2 8 1140850688 131073 2560 nil nil nil 7 nil nil nil 2560 1778 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 2560 34 2 8 1140850688 131073 2672 nil nil nil 7 nil nil nil 2672 656390 ##(Smalltalk.GridLayout) 5 1 1 1 170 192 34 4 410 ##(Smalltalk.RadioButton) 34 16 nil 2672 34 2 8 1140862217 1 2800 721990 2 ##(Smalltalk.ValueHolder) nil nil 1376774 ##(Smalltalk.PluggableSearchPolicy) 459270 ##(Smalltalk.Message) #= 8 #() 2930 #hash 8 #() false nil nil 7 nil nil nil 2800 nil 8 4294903093 1938 nil nil nil 834 138 144 34 2 898 #createAt:extent: 34 2 514 1 75 514 311 75 2800 898 #text: 34 1 8 '&Wildcard Expression' 2800 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 37 0 0 0 155 0 0 0 74 0 0 0] 8 #() 1088 nil 27 8 'wildcardExpression' 410 ##(Smalltalk.RadioButton) 34 16 nil 2672 34 2 8 1141055497 1 3264 2866 nil nil 2898 2930 #= 8 #() 2930 #hash 8 #() false nil nil 7 nil nil nil 3264 nil 8 4294903093 1938 nil nil nil 834 138 144 34 2 898 #createAt:extent: 34 2 514 1 1 514 311 75 3264 898 #text: 34 1 8 '&Text' 3264 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 155 0 0 0 37 0 0 0] 8 #() 1088 nil 27 8 'text' nil 834 138 144 34 1 898 #createAt:extent: 34 2 514 21 41 514 311 149 2672 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 10 0 0 0 20 0 0 0 165 0 0 0 94 0 0 0] 34 2 3264 2800 1088 nil 27 2130 2162 #fixedParentLeft 21 2192 -9 2162 #fixedParentTop 41 2162 #fixedParentBottom -13 410 ##(Smalltalk.GroupBox) 34 14 nil 2560 34 2 8 1140850695 65 3904 nil nil nil 7 nil nil nil 3904 nil 8 4294903093 834 138 144 34 2 898 #createAt:extent: 34 2 514 3 1 514 339 203 3904 898 #text: 34 1 8 'Search Mode' 3904 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 1 0 0 0 0 0 0 0 170 0 0 0 101 0 0 0] 8 #() 1088 nil 27 2130 3856 3 2192 1 3872 1 3888 1 170 192 34 2 2672 8 'mode' nil 834 138 144 34 1 898 #createAt:extent: 34 2 514 1 11 514 341 203 2560 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 5 0 0 0 170 0 0 0 106 0 0 0] 34 2 3904 2672 1088 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 2240 34 2 8 1140850688 131073 4416 nil nil nil 7 nil nil nil 4416 1778 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 4416 34 2 8 1140850688 131073 4528 nil nil nil 7 nil nil nil 4528 2738 5 1 1 1 170 192 34 4 410 ##(Smalltalk.CheckBox) 34 16 nil 4528 34 2 8 1141058819 1 4640 2866 nil nil 1114118 ##(Smalltalk.NeverSearchPolicy) false nil nil 7 nil nil nil 4640 nil 8 4294903093 1938 nil nil nil 834 138 144 34 2 898 #createAt:extent: 34 2 514 1 1 514 251 77 4640 898 #text: 34 1 8 '&Whole word' 4640 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 125 0 0 0 38 0 0 0] 8 #() 1088 nil 27 8 'matchWhole' 410 ##(Smalltalk.CheckBox) 34 16 nil 4528 34 2 8 1140924419 1 5008 2866 nil nil 4736 false nil nil 7 nil nil nil 5008 nil 8 4294903093 1938 nil nil nil 834 138 144 34 2 898 #createAt:extent: 34 2 514 1 77 514 251 75 5008 898 #text: 34 1 8 '&Case' 5008 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 38 0 0 0 125 0 0 0 75 0 0 0] 8 #() 1088 nil 27 8 'matchCase' nil 834 138 144 34 1 898 #createAt:extent: 34 2 514 23 31 514 251 151 4528 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 11 0 0 0 15 0 0 0 136 0 0 0 90 0 0 0] 34 2 4640 5008 1088 nil 27 2130 3856 23 2192 -7 3872 31 3888 -19 410 ##(Smalltalk.GroupBox) 34 14 nil 4416 34 2 8 1140850695 65 5520 nil nil nil 7 nil nil nil 5520 nil 8 4294903093 834 138 144 34 2 898 #createAt:extent: 34 2 514 3 1 514 279 201 5520 898 #text: 34 1 8 'Match' 5520 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 1 0 0 0 0 0 0 0 140 0 0 0 100 0 0 0] 8 #() 1088 nil 27 2130 3856 3 2192 1 3872 1 3888 1 170 192 2336 nil 834 138 144 34 1 898 #createAt:extent: 34 2 514 351 11 514 281 201 4416 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 175 0 0 0 5 0 0 0 59 1 0 0 105 0 0 0] 34 2 5520 4528 1088 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 2240 34 2 8 1140850688 131073 6000 nil nil nil 7 nil nil nil 6000 1778 170 176 34 4 410 ##(Smalltalk.GroupBox) 34 14 nil 6000 34 2 8 1140850695 65 6112 nil nil nil 7 nil nil nil 6112 nil 8 4294903093 834 138 144 34 2 898 #createAt:extent: 34 2 514 3 1 514 293 201 6112 898 #text: 34 1 8 'Direction' 6112 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 1 0 0 0 0 0 0 0 147 0 0 0 100 0 0 0] 8 #() 1088 nil 27 2130 3856 3 2192 1 3872 1 3888 1 410 ##(Smalltalk.ContainerView) 34 15 nil 6000 34 2 8 1140850688 131073 6416 nil nil 514 281 141 519 nil nil nil 6416 2738 5 1 1 1 170 192 34 6 410 ##(Smalltalk.CheckBox) 34 16 nil 6416 34 2 8 1140858883 1 6544 2866 nil nil 4736 false nil nil 7 nil nil nil 6544 nil 8 4294903093 1938 nil nil nil 834 138 144 34 2 898 #createAt:extent: 34 2 514 1 71 514 141 71 6544 898 #text: 34 1 8 '&Wrap around' 6544 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 35 0 0 0 70 0 0 0 70 0 0 0] 8 #() 1088 nil 27 8 'wrap' 410 ##(Smalltalk.RadioButton) 34 16 nil 6416 34 2 8 1140858889 1 6880 2866 nil nil 2898 2930 #= 8 #() 2930 #hash 8 #() false nil nil 7 nil nil nil 6880 nil 8 4294903093 1938 nil nil nil 834 138 144 34 2 898 #createAt:extent: 34 2 514 141 1 514 141 71 6880 898 #text: 34 1 8 '&Down' 6880 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 70 0 0 0 0 0 0 0 140 0 0 0 35 0 0 0] 8 #() 1088 nil 27 8 'down' 410 ##(Smalltalk.RadioButton) 34 16 nil 6416 34 2 8 1141055497 1 7296 2866 nil nil 2898 2930 #= 8 #() 2930 #hash 8 #() false nil nil 7 nil nil nil 7296 nil 8 4294903093 1938 nil nil nil 834 138 144 34 2 898 #createAt:extent: 34 2 514 1 1 514 141 71 7296 898 #text: 34 1 8 '&Up' 7296 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 70 0 0 0 35 0 0 0] 8 #() 1088 nil 27 8 'up' nil 834 138 144 34 1 898 #createAt:extent: 34 2 514 11 41 514 281 141 6416 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 20 0 0 0 145 0 0 0 90 0 0 0] 34 3 7296 6880 6544 1088 nil 27 2130 3856 11 2192 -3 3872 41 3888 -19 170 192 34 2 6416 8 'direction' nil 834 138 144 34 1 898 #createAt:extent: 34 2 514 641 11 514 295 201 6000 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 64 1 0 0 5 0 0 0 211 1 0 0 105 0 0 0] 34 2 6112 6416 1088 nil 27 1088 nil 27 2130 3856 3 2192 11 2162 #fixedPreviousBottom 11 3888 -3 410 ##(Smalltalk.StaticText) 34 16 nil 1712 34 2 8 1140850944 1 8128 2866 nil nil 4736 8 '' nil nil 7 nil nil nil 8128 nil 8 1663077024 1938 nil nil true 834 138 144 34 2 898 #createAt:extent: 34 2 514 17 31 514 111 31 8128 898 #text: 34 1 8 'Fi&nd what:' 8128 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 8 0 0 0 15 0 0 0 63 0 0 0 30 0 0 0] 8 #() 1088 nil 27 2130 3856 5 2162 #fixedViewLeft 111 3872 1 2224 31 170 192 34 4 1840 8 'pattern' 8128 8 'prompt' 1490 514 13 31 514 11 21 834 138 144 34 1 898 #createAt:extent: 34 2 514 11 1 514 949 323 1712 1026 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 0 0 0 0 223 1 0 0 161 0 0 0] 34 3 8128 1840 2240 1088 nil 27 170 192 2336 1490 514 11 1 514 11 1 nil nil nil nil 9123 nil nil 514 2049 461 514 961 401 1 nil nil 590598 ##(Smalltalk.Semaphore) nil nil 1 nil 8 2003786336 834 138 144 34 3 898 #createAt:extent: 34 2 514 7679 21 514 1171 401 416 898 #text: 34 1 8 'Jadeite Find' 416 898 #updateMenuBar 2336 416 1026 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 72 17 0 0 210 0 0 0] 34 2 1712 576 1088 nil 27 )!

showModeless: aView on: aFindDetails 
	^(self createOn: aFindDetails)
		ownerView: aView;
		show! !
!JadeiteAdvancedFindDialog class categoriesFor: #resource_Default_view!public!resources-views! !
!JadeiteAdvancedFindDialog class categoriesFor: #showModeless:on:!instance creation!public! !

