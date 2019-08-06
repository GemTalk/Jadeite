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

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.DialogView) 34 30 nil nil 8 #(13369344 65536) 416 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 nil 167 nil nil nil 416 788230 ##(Smalltalk.BorderLayout) 11 1 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 544 nil nil nil 7 nil nil nil 544 656198 1 ##(Smalltalk.FlowLayout) 1 11 1 170 192 34 4 410 ##(Smalltalk.PushButton) 34 20 nil 544 34 2 8 1140924416 1 672 nil nil nil 7 nil nil nil 672 nil 8 4294906179 1180998 4 ##(Smalltalk.CommandDescription) #cancel 8 'C&lose' 1 1 nil nil false nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 2 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 328198 ##(Smalltalk.Point) 1 77 914 151 47 672 866 #text: 34 1 8 'C&lose' 672 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 38 0 0 0 75 0 0 0 61 0 0 0] 8 #() 914 193 193 nil 29 8 'cancel' 410 ##(Smalltalk.PushButton) 34 20 nil 544 34 2 8 1141055488 1 1104 nil nil nil 7 nil nil nil 1104 nil 8 4294906179 754 #ok 8 '&Find' 1 5 nil nil true nil nil nil 802 138 144 34 3 866 #createAt:extent: 34 2 914 1 21 914 151 47 1104 866 #isEnabled: 8 #(false) 1104 866 #text: 34 1 8 '&Find' 1104 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 10 0 0 0 75 0 0 0 33 0 0 0] 8 #() 1072 nil 29 8 'ok' 590342 ##(Smalltalk.Rectangle) 914 1 21 914 1 1 802 138 144 34 1 866 #createAt:extent: 34 2 914 969 1 914 161 323 544 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 228 1 0 0 0 0 0 0 52 2 0 0 161 0 0 0] 34 2 1104 672 1072 nil 27 nil 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 1696 nil nil nil 7 nil nil nil 1696 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.ContainerView) 34 15 nil 1696 34 2 8 1140850688 131073 1824 nil nil nil 7 nil nil nil 1824 610 11 1 1 170 192 8 #() 1474 914 1 11 914 1 1 802 138 144 34 1 866 #createAt:extent: 34 2 914 13 89 914 927 215 1824 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 6 0 0 0 44 0 0 0 213 1 0 0 151 0 0 0] 34 3 410 ##(Smalltalk.ContainerView) 34 15 nil 1824 34 2 8 1140850688 131073 2144 nil nil nil 7 nil nil nil 2144 1762 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 2144 34 2 8 1140850688 131073 2256 nil nil nil 7 nil nil nil 2256 656390 ##(Smalltalk.GridLayout) 5 1 1 1 170 192 34 4 410 ##(Smalltalk.RadioButton) 34 16 nil 2256 34 2 8 1140862217 1 2384 721990 2 ##(Smalltalk.ValueHolder) nil nil 1376774 ##(Smalltalk.PluggableSearchPolicy) 459270 ##(Smalltalk.Message) #= 8 #() 2514 #hash 8 #() false nil nil 7 nil nil nil 2384 nil 8 4294906179 852486 ##(Smalltalk.NullConverter) nil nil nil 802 138 144 34 2 866 #createAt:extent: 34 2 914 1 77 914 311 75 2384 866 #text: 34 1 8 '&Wildcard Expression' 2384 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 38 0 0 0 155 0 0 0 75 0 0 0] 8 #() 1072 nil 27 8 'wildcardExpression' 410 ##(Smalltalk.RadioButton) 34 16 nil 2256 34 2 8 1141055497 1 2864 2450 nil nil 2482 2514 #= 8 #() 2514 #hash 8 #() false nil nil 7 nil nil nil 2864 nil 8 4294906179 2610 nil nil nil 802 138 144 34 2 866 #createAt:extent: 34 2 914 1 1 914 311 77 2864 866 #text: 34 1 8 '&Text' 2864 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 155 0 0 0 38 0 0 0] 8 #() 1072 nil 27 8 'text' nil 802 138 144 34 1 866 #createAt:extent: 34 2 914 21 41 914 311 151 2256 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 10 0 0 0 20 0 0 0 165 0 0 0 95 0 0 0] 34 2 2864 2384 1072 nil 27 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 21 3474 #fixedParentRight -9 3474 #fixedParentTop 41 3474 #fixedParentBottom -13 410 ##(Smalltalk.GroupBox) 34 14 nil 2144 34 2 8 1140850695 65 3552 nil nil nil 7 nil nil nil 3552 nil 8 4294906179 802 138 144 34 2 866 #createAt:extent: 34 2 914 3 1 914 339 205 3552 866 #text: 34 1 8 'Search Mode' 3552 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 1 0 0 0 0 0 0 0 170 0 0 0 102 0 0 0] 8 #() 1072 nil 27 3442 3488 3 3504 1 3520 1 3536 1 170 192 34 2 2256 8 'mode' nil 802 138 144 34 1 866 #createAt:extent: 34 2 914 1 11 914 341 205 2144 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 5 0 0 0 170 0 0 0 107 0 0 0] 34 2 3552 2256 1072 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 1824 34 2 8 1140850688 131073 4064 nil nil nil 7 nil nil nil 4064 1762 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 4064 34 2 8 1140850688 131073 4176 nil nil nil 7 nil nil nil 4176 2322 5 1 1 1 170 192 34 4 410 ##(Smalltalk.CheckBox) 34 16 nil 4176 34 2 8 1141058819 1 4288 2450 nil nil 1114118 ##(Smalltalk.NeverSearchPolicy) false nil nil 7 nil nil nil 4288 nil 8 4294906179 2610 nil nil nil 802 138 144 34 2 866 #createAt:extent: 34 2 914 1 1 914 251 77 4288 866 #text: 34 1 8 '&Whole word' 4288 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 125 0 0 0 38 0 0 0] 8 #() 1072 nil 27 8 'matchWhole' 410 ##(Smalltalk.CheckBox) 34 16 nil 4176 34 2 8 1140924419 1 4656 2450 nil nil 4384 false nil nil 7 nil nil nil 4656 nil 8 4294906179 2610 nil nil nil 802 138 144 34 2 866 #createAt:extent: 34 2 914 1 77 914 251 75 4656 866 #text: 34 1 8 '&Case' 4656 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 38 0 0 0 125 0 0 0 75 0 0 0] 8 #() 1072 nil 27 8 'matchCase' nil 802 138 144 34 1 866 #createAt:extent: 34 2 914 23 31 914 251 151 4176 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 11 0 0 0 15 0 0 0 136 0 0 0 90 0 0 0] 34 2 4288 4656 1072 nil 27 3442 3488 23 3504 -7 3520 31 3536 -19 410 ##(Smalltalk.GroupBox) 34 14 nil 4064 34 2 8 1140850695 65 5168 nil nil nil 7 nil nil nil 5168 nil 8 4294906179 802 138 144 34 2 866 #createAt:extent: 34 2 914 3 1 914 279 201 5168 866 #text: 34 1 8 'Match' 5168 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 1 0 0 0 0 0 0 0 140 0 0 0 100 0 0 0] 8 #() 1072 nil 27 3442 3488 3 3504 1 3520 1 3536 1 170 192 1920 nil 802 138 144 34 1 866 #createAt:extent: 34 2 914 351 11 914 281 201 4064 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 175 0 0 0 5 0 0 0 59 1 0 0 105 0 0 0] 34 2 5168 4176 1072 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 1824 34 2 8 1140850688 131073 5648 nil nil nil 7 nil nil nil 5648 1762 170 176 34 4 410 ##(Smalltalk.ContainerView) 34 15 nil 5648 34 2 8 1140850688 131073 5760 nil nil nil 7 nil nil nil 5760 610 1 45 1 170 192 34 6 410 ##(Smalltalk.RadioButton) 34 16 nil 5760 34 2 8 1141055497 1 5872 2450 nil nil 2482 2514 #= 8 #() 2514 #hash 8 #() false nil nil 7 nil nil nil 5872 nil 8 4294906179 2610 nil nil nil 802 138 144 34 2 866 #createAt:extent: 34 2 914 1 1 914 89 43 5872 866 #text: 34 1 8 '&Up' 5872 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 44 0 0 0 21 0 0 0] 8 #() 1072 nil 27 8 'up' 410 ##(Smalltalk.CheckBox) 34 16 nil 5760 34 2 8 1140858883 1 6288 2450 nil nil 4384 false nil nil 7 nil nil nil 6288 nil 8 4294906179 2610 nil nil nil 802 138 144 34 2 866 #createAt:extent: 34 2 914 1 87 914 181 43 6288 866 #text: 34 1 8 '&Wrap around' 6288 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 43 0 0 0 90 0 0 0 64 0 0 0] 8 #() 1072 nil 27 8 'wrap' 410 ##(Smalltalk.RadioButton) 34 16 nil 5760 34 2 8 1140858889 1 6624 2450 nil nil 2482 2514 #= 8 #() 2514 #hash 8 #() false nil nil 7 nil nil nil 6624 nil 8 4294906179 2610 nil nil nil 802 138 144 34 2 866 #createAt:extent: 34 2 914 89 1 914 97 43 6624 866 #text: 34 1 8 '&Down' 6624 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 44 0 0 0 0 0 0 0 92 0 0 0 21 0 0 0] 8 #() 1072 nil 27 8 'down' nil 802 138 144 34 1 866 #createAt:extent: 34 2 914 11 41 914 241 121 5760 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 20 0 0 0 125 0 0 0 80 0 0 0] 34 3 5872 6624 6288 1072 nil 27 3442 3488 11 3504 -19 3520 41 3536 -39 410 ##(Smalltalk.GroupBox) 34 14 nil 5648 34 2 8 1140850695 65 7216 nil nil nil 7 nil nil nil 7216 nil 8 4294906179 802 138 144 34 2 866 #createAt:extent: 34 2 914 1 1 914 269 201 7216 866 #text: 34 1 8 'Direction' 7216 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 134 0 0 0 100 0 0 0] 8 #() 1072 nil 27 3442 3488 1 3504 -1 3520 1 3536 1 170 192 34 2 5760 8 'direction' nil 802 138 144 34 1 866 #createAt:extent: 34 2 914 641 11 914 271 201 5648 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 64 1 0 0 5 0 0 0 199 1 0 0 105 0 0 0] 34 2 7216 5760 1072 nil 27 1072 nil 27 3442 3488 1 3504 1 3474 #fixedPreviousBottom 11 3536 1 410 ##(Smalltalk.TextEdit) 34 16 nil 1696 34 2 8 1141047424 1025 7760 nil 466 496 nil 7 nil nil nil 7760 nil 8 4294902643 2610 nil nil 5 802 138 144 34 1 866 #createAt:extent: 34 2 914 145 29 914 781 51 7760 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 72 0 0 0 14 0 0 0 206 1 0 0 39 0 0 0] 8 #() 1072 nil 27 3442 3474 #fixedPreviousRight 19 3504 -13 3474 #fixedPreviousTop -1 3474 #fixedViewTop 51 410 ##(Smalltalk.StaticText) 34 16 nil 1696 34 2 8 1140850944 1 8096 2450 nil nil 4384 8 '' nil nil 7 nil nil nil 8096 nil 8 1684497712 2610 nil nil true 802 138 144 34 2 866 #createAt:extent: 34 2 914 17 31 914 111 31 8096 866 #text: 34 1 8 'Fi&nd what:' 8096 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 8 0 0 0 15 0 0 0 63 0 0 0 30 0 0 0] 8 #() 1072 nil 27 3442 3488 5 3474 #fixedViewLeft 111 3520 1 8080 31 170 192 34 4 7760 8 'pattern' 8096 8 'prompt' 1474 914 13 31 914 11 21 802 138 144 34 1 866 #createAt:extent: 34 2 914 11 1 914 949 323 1696 1010 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 5 0 0 0 0 0 0 0 223 1 0 0 161 0 0 0] 34 3 8096 7760 1824 1072 nil 27 170 192 1920 1474 914 11 1 914 11 1 nil nil nil nil 15843 nil nil 914 2049 461 914 961 401 1 nil nil 590598 ##(Smalltalk.Semaphore) nil nil 1 nil 8 2000760848 802 138 144 34 3 866 #createAt:extent: 34 2 914 7679 21 914 1171 401 416 866 #text: 34 1 8 'Jadeite Find' 416 866 #updateMenuBar 1920 416 1010 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 72 17 0 0 210 0 0 0] 34 2 1696 544 1072 nil 27 )!

showModeless: aView on: aFindDetails 
	^(self createOn: aFindDetails)
		ownerView: aView;
		show! !
!JadeiteAdvancedFindDialog class categoriesFor: #resource_Default_view!public!resources-views! !
!JadeiteAdvancedFindDialog class categoriesFor: #showModeless:on:!instance creation!public! !

