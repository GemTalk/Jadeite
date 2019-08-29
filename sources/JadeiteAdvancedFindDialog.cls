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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.DialogView) 34 30 nil nil 8 #(13369344 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 nil 167 nil nil nil 416 788230 ##(Smalltalk.BorderLayout) 11 1 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 544 nil nil nil 7 nil nil nil 544 656198 1 ##(Smalltalk.FlowLayout) 1 11 1 170 192 34 4 410 ##(Smalltalk.PushButton) 34 20 nil 544 34 2 8 1140924416 1 672 nil nil nil 7 nil nil nil 672 nil 8 4294904477 1180998 4 ##(Smalltalk.CommandDescription) #cancel 8 'C&lose' 1 1 nil nil false nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 328198 ##(Smalltalk.Point) 1 77 914 151 47 672 866 #text: 34 1 8 'C&lose' 672 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 38 0 0 0 75 0 0 0 61 0 0 0] 8 #() 914 193 193 nil 29 8 'cancel' 410 ##(Smalltalk.PushButton) 34 20 nil 544 34 2 8 1141055488 1 1104 nil nil nil 7 nil nil nil 1104 nil 8 4294904477 754 #ok 8 '&Find' 1 5 nil nil true nil nil nil 802 138 144 34 3 866 #createAt:extent: 34 2 914 1 21 914 151 47 1104 866 #isEnabled: 8 #(false) 1104 866 #text: 34 1 8 '&Find' 1104 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 10 0 0 0 75 0 0 0 33 0 0 0] 8 #() 1072 nil 29 8 'ok' 590342 ##(Smalltalk.Rectangle) 914 1 21 914 1 1 802 138 144 34 1 866 #createAt:extent: 34 2 914 969 1 914 161 323 544 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 228 1 0 0 0 0 0 0 52 2 0 0 161 0 0 0] 34 2 1104 672 1072 nil 27 nil 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 1696 nil nil nil 7 nil nil nil 1696 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.TextEdit) 34 16 nil 1696 34 2 8 1141047424 1025 1824 nil 466 496 nil 7 nil nil nil 1824 nil 8 4294905141 852486 ##(Smalltalk.NullConverter) nil nil 5 802 138 144 34 1 866 #createAt:extent: 34 2 914 145 29 914 781 51 1824 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 72 0 0 0 14 0 0 0 206 1 0 0 39 0 0 0] 8 #() 1072 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedPreviousRight 19 2146 #fixedParentRight -13 2146 #fixedPreviousTop -1 2146 #fixedViewTop 51 410 ##(Smalltalk.ContainerView) 34 15 nil 1696 34 2 8 1140850688 131073 2224 nil nil nil 7 nil nil nil 2224 610 11 1 1 170 192 8 #() 1474 914 1 11 914 1 1 802 138 144 34 1 866 #createAt:extent: 34 2 914 15 89 914 935 211 2224 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 7 0 0 0 44 0 0 0 218 1 0 0 149 0 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 2224 34 2 8 1140850688 131073 2544 nil nil nil 7 nil nil nil 2544 1762 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 2544 34 2 8 1140850688 131073 2656 nil nil nil 7 nil nil nil 2656 656390 ##(Smalltalk.GridLayout) 5 1 1 1 170 192 34 4 410 ##(Smalltalk.RadioButton) 34 16 nil 2656 34 2 8 1141055497 1 2784 721990 2 ##(Smalltalk.ValueHolder) nil nil 1376774 ##(Smalltalk.PluggableSearchPolicy) 459270 ##(Smalltalk.Message) #= 8 #() 2914 #hash 8 #() false nil nil 7 nil nil nil 2784 nil 8 4294904477 1922 nil nil nil 802 138 144 34 2 866 #createAt:extent: 34 2 914 1 1 914 311 77 2784 866 #text: 34 1 8 '&Text' 2784 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 155 0 0 0 38 0 0 0] 8 #() 1072 nil 27 8 'text' 410 ##(Smalltalk.RadioButton) 34 16 nil 2656 34 2 8 1140862217 1 3248 2850 nil nil 2882 2914 #= 8 #() 2914 #hash 8 #() false nil nil 7 nil nil nil 3248 nil 8 4294904477 1922 nil nil nil 802 138 144 34 2 866 #createAt:extent: 34 2 914 1 77 914 311 75 3248 866 #text: 34 1 8 '&Wildcard Expression' 3248 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 38 0 0 0 155 0 0 0 75 0 0 0] 8 #() 1072 nil 27 8 'wildcardExpression' nil 802 138 144 34 1 866 #createAt:extent: 34 2 914 21 41 914 311 151 2656 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 10 0 0 0 20 0 0 0 165 0 0 0 95 0 0 0] 34 2 2784 3248 1072 nil 27 2114 2146 #fixedParentLeft 21 2176 -9 2146 #fixedParentTop 41 2146 #fixedParentBottom -13 410 ##(Smalltalk.GroupBox) 34 14 nil 2544 34 2 8 1140850695 65 3888 nil nil nil 7 nil nil nil 3888 nil 8 4294904477 802 138 144 34 2 866 #createAt:extent: 34 2 914 3 1 914 339 205 3888 866 #text: 34 1 8 'Search Mode' 3888 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 1 0 0 0 0 0 0 0 170 0 0 0 102 0 0 0] 8 #() 1072 nil 27 2114 3840 3 2176 1 3856 1 3872 1 170 192 34 2 2656 8 'mode' nil 802 138 144 34 1 866 #createAt:extent: 34 2 914 1 11 914 341 205 2544 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 5 0 0 0 170 0 0 0 107 0 0 0] 34 2 3888 2656 1072 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 2224 34 2 8 1140850688 131073 4400 nil nil nil 7 nil nil nil 4400 1762 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 4400 34 2 8 1140850688 131073 4512 nil nil nil 7 nil nil nil 4512 2722 5 1 1 1 170 192 34 4 410 ##(Smalltalk.CheckBox) 34 16 nil 4512 34 2 8 1141058819 1 4624 2850 nil nil 1114118 ##(Smalltalk.NeverSearchPolicy) false nil nil 7 nil nil nil 4624 nil 8 4294904477 1922 nil nil nil 802 138 144 34 2 866 #createAt:extent: 34 2 914 1 1 914 251 77 4624 866 #text: 34 1 8 '&Whole word' 4624 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 125 0 0 0 38 0 0 0] 8 #() 1072 nil 27 8 'matchWhole' 410 ##(Smalltalk.CheckBox) 34 16 nil 4512 34 2 8 1140924419 1 4992 2850 nil nil 4720 false nil nil 7 nil nil nil 4992 nil 8 4294904477 1922 nil nil nil 802 138 144 34 2 866 #createAt:extent: 34 2 914 1 77 914 251 75 4992 866 #text: 34 1 8 '&Case' 4992 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 38 0 0 0 125 0 0 0 75 0 0 0] 8 #() 1072 nil 27 8 'matchCase' nil 802 138 144 34 1 866 #createAt:extent: 34 2 914 23 31 914 251 151 4512 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 11 0 0 0 15 0 0 0 136 0 0 0 90 0 0 0] 34 2 4624 4992 1072 nil 27 2114 3840 23 2176 -7 3856 31 3872 -19 410 ##(Smalltalk.GroupBox) 34 14 nil 4400 34 2 8 1140850695 65 5504 nil nil nil 7 nil nil nil 5504 nil 8 4294904477 802 138 144 34 2 866 #createAt:extent: 34 2 914 3 1 914 279 201 5504 866 #text: 34 1 8 'Match' 5504 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 1 0 0 0 0 0 0 0 140 0 0 0 100 0 0 0] 8 #() 1072 nil 27 2114 3840 3 2176 1 3856 1 3872 1 170 192 2320 nil 802 138 144 34 1 866 #createAt:extent: 34 2 914 351 11 914 281 201 4400 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 175 0 0 0 5 0 0 0 59 1 0 0 105 0 0 0] 34 2 5504 4512 1072 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 2224 34 2 8 1140850688 131073 5984 nil nil nil 7 nil nil nil 5984 1762 170 176 34 4 410 ##(Smalltalk.GroupBox) 34 14 nil 5984 34 2 8 1140850695 65 6096 nil nil nil 7 nil nil nil 6096 nil 8 4294904477 802 138 144 34 2 866 #createAt:extent: 34 2 914 3 1 914 293 201 6096 866 #text: 34 1 8 'Direction' 6096 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 1 0 0 0 0 0 0 0 147 0 0 0 100 0 0 0] 8 #() 1072 nil 27 2114 3840 3 2176 1 3856 1 3872 1 410 ##(Smalltalk.ContainerView) 34 15 nil 5984 34 2 8 1140850688 131073 6400 nil nil 914 281 141 519 nil nil nil 6400 610 1 45 1 170 192 34 6 410 ##(Smalltalk.RadioButton) 34 16 nil 6400 34 2 8 1140858889 1 6528 2850 nil nil 2882 2914 #= 8 #() 2914 #hash 8 #() false nil nil 7 nil nil nil 6528 nil 8 4294904477 1922 nil nil nil 802 138 144 34 2 866 #createAt:extent: 34 2 914 89 1 914 97 43 6528 866 #text: 34 1 8 '&Down' 6528 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 44 0 0 0 0 0 0 0 92 0 0 0 21 0 0 0] 8 #() 1072 nil 27 8 'down' 410 ##(Smalltalk.RadioButton) 34 16 nil 6400 34 2 8 1141055497 1 6944 2850 nil nil 2882 2914 #= 8 #() 2914 #hash 8 #() false nil nil 7 nil nil nil 6944 nil 8 4294904477 1922 nil nil nil 802 138 144 34 2 866 #createAt:extent: 34 2 914 1 1 914 89 43 6944 866 #text: 34 1 8 '&Up' 6944 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 44 0 0 0 21 0 0 0] 8 #() 1072 nil 27 8 'up' 410 ##(Smalltalk.CheckBox) 34 16 nil 6400 34 2 8 1140858883 1 7360 2850 nil nil 4720 false nil nil 7 nil nil nil 7360 nil 8 4294904477 1922 nil nil nil 802 138 144 34 2 866 #createAt:extent: 34 2 914 1 87 914 181 43 7360 866 #text: 34 1 8 '&Wrap around' 7360 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 43 0 0 0 90 0 0 0 64 0 0 0] 8 #() 1072 nil 27 8 'wrap' nil 802 138 144 34 1 866 #createAt:extent: 34 2 914 11 41 914 281 141 6400 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 20 0 0 0 145 0 0 0 90 0 0 0] 34 3 6944 6528 7360 1072 nil 27 2114 3840 11 2176 -3 3856 41 3872 -19 170 192 34 2 6400 8 'direction' nil 802 138 144 34 1 866 #createAt:extent: 34 2 914 641 11 914 295 201 5984 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 64 1 0 0 5 0 0 0 211 1 0 0 105 0 0 0] 34 2 6096 6400 1072 nil 27 1072 nil 27 2114 3840 3 2176 11 2146 #fixedPreviousBottom 11 3872 -3 410 ##(Smalltalk.StaticText) 34 16 nil 1696 34 2 8 1140850944 1 8112 2850 nil nil 4720 8 '' nil nil 7 nil nil nil 8112 nil 8 1657572000 1922 nil nil true 802 138 144 34 2 866 #createAt:extent: 34 2 914 17 31 914 111 31 8112 866 #text: 34 1 8 'Fi&nd what:' 8112 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 8 0 0 0 15 0 0 0 63 0 0 0 30 0 0 0] 8 #() 1072 nil 27 2114 3840 5 2146 #fixedViewLeft 111 3856 1 2208 31 170 192 34 4 1824 8 'pattern' 8112 8 'prompt' 1474 914 13 31 914 11 21 802 138 144 34 1 866 #createAt:extent: 34 2 914 11 1 914 949 323 1696 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 0 0 0 0 223 1 0 0 161 0 0 0] 34 3 8112 1824 2224 1072 nil 27 170 192 2320 1474 914 11 1 914 11 1 nil nil nil nil 17639 nil nil 914 2049 461 914 961 401 1 nil nil 590598 ##(Smalltalk.Semaphore) nil nil 1 nil 8 2006407776 802 138 144 34 3 866 #createAt:extent: 34 2 914 7679 21 914 1171 401 416 866 #text: 34 1 8 'Jadeite Find' 416 866 #updateMenuBar 2320 416 1010 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 72 17 0 0 210 0 0 0] 34 2 1696 544 1072 nil 27 )!

showModeless: aView on: aFindDetails 
	^(self createOn: aFindDetails)
		ownerView: aView;
		show! !
!JadeiteAdvancedFindDialog class categoriesFor: #resource_Default_view!public!resources-views! !
!JadeiteAdvancedFindDialog class categoriesFor: #showModeless:on:!instance creation!public! !

