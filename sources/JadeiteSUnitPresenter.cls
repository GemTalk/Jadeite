"Filed out from Dolphin Smalltalk 7"!

JadeiteSUnitAbstractPresenter subclass: #JadeiteSUnitPresenter
	instanceVariableNames: 'packageListPresenter classListPresenter status testCounter'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteSUnitPresenter guid: (GUID fromString: '{f0d7615e-1a5a-4d8a-b979-c2ad927a9f74}')!
JadeiteSUnitPresenter comment: ''!
!JadeiteSUnitPresenter categoriesForClass!Unclassified! !
!JadeiteSUnitPresenter methodsFor!

abortTransaction
	super abortTransaction.
	self refresh!

commitTransaction
	super commitTransaction!

createComponents
	super createComponents.
	packageListPresenter := self add: ListPresenter new name: 'packages'.
	classListPresenter := self add: ListPresenter new name: 'testClasses'!

createSchematicWiring
	super createSchematicWiring.
	packageListPresenter
		when: #selectionChanged
		send: #onPackageChanged
		to: self.
	classListPresenter
		when: #selectionChanged
		send: #onClassesChanged
		to: self!

debug
	"in order to provide some visual feedback when a debugged
	test passes, we assume that if the test wasn't curtailed that
	it passed."

	methodListPresenter selections do: 
			[:methodService |
			| testClassName |
			testClassName := classListPresenter selections size > 1
						ifTrue: [methodService className]
						ifFalse: [classListPresenter selections first name].
			
			[gciSession
				serverPerform: #debugTestNamed:of:
				with: methodService selector
				with: testClassName]
					ifCurtailed: [^self].
			self updateResult: (JadeTestResult new addPassed: methodService selector)]!

getTestCounter

	^'Total Tests: ', testCounter first printString!

onClassesChanged
	self updateMethods.
	status value: nil.
	status value: self.
!

onPackageChanged
	Cursor wait showWhile: 
			[self updateClasses.
			status value: nil.
			status value: self]!

packagesSize
	^'Packages: ' , packageListPresenter model size printString!

runAll
	^classListPresenter selections size > 1
		ifTrue: [self runTests: methodListPresenter model]
		ifFalse: [self runTests: methodListPresenter model in: classListPresenter selections first name]!

runSelected
	"if multiple classes are selected, we really don't know which test class
	the user intended for the test to be run so pick the class the test is defined in"

	^classListPresenter selections size > 1
		ifTrue: [self runTests: methodListPresenter selections]
		ifFalse: [self runTests: methodListPresenter selections in: classListPresenter selections first name]!

selectClassNamed: name
	"for testing at the moment"

	| classService |
	classService := classListPresenter list detect: [:service | service name = name] ifNone: [^self].
	classListPresenter selection: classService!

selectedFilters
	"no categories in sunit browser"
	^Array new !

selectMethodNamed: selector
	"for testing at the moment" 
	| methodService |
	methodService := methodListPresenter list detect: [:service | service selector = selector] ifNone: [^self].
	methodListPresenter selections: (Array with: methodService)!

selectPackageNamed: name
	"for testing at the moment" 
	| packageService |
	packageService := packageListPresenter list detect: [:service | service name = name] ifNone: [^self].
	packageListPresenter selection: packageService!

selectPackageNamed: packageName classNamed: className
	| packageService classService |
	packageService := packageListPresenter list detect: [:service | service name = packageName]
				ifNone: [^self].
	packageListPresenter selection: packageService.
	classService := classListPresenter list detect: [:service | service name asString = className]
				ifNone: [^self].
	classListPresenter selection: classService!

status
	^status!

status: anObject
	status := anObject!

testCasesSize
	^'Test Cases:' , methodListPresenter model size printString!

testClassesSize
	^'Test Classes:' , classListPresenter model size printString! !
!JadeiteSUnitPresenter categoriesFor: #abortTransaction!public!transaction management! !
!JadeiteSUnitPresenter categoriesFor: #commitTransaction!public!transaction management! !
!JadeiteSUnitPresenter categoriesFor: #createComponents!public! !
!JadeiteSUnitPresenter categoriesFor: #createSchematicWiring!public! !
!JadeiteSUnitPresenter categoriesFor: #debug!public! !
!JadeiteSUnitPresenter categoriesFor: #getTestCounter!public! !
!JadeiteSUnitPresenter categoriesFor: #onClassesChanged!event handlers!public! !
!JadeiteSUnitPresenter categoriesFor: #onPackageChanged!event handlers!public! !
!JadeiteSUnitPresenter categoriesFor: #packagesSize!public! !
!JadeiteSUnitPresenter categoriesFor: #runAll!public! !
!JadeiteSUnitPresenter categoriesFor: #runSelected!public! !
!JadeiteSUnitPresenter categoriesFor: #selectClassNamed:!public!selection! !
!JadeiteSUnitPresenter categoriesFor: #selectedFilters!accessing!public! !
!JadeiteSUnitPresenter categoriesFor: #selectMethodNamed:!public!selection! !
!JadeiteSUnitPresenter categoriesFor: #selectPackageNamed:!public!selection! !
!JadeiteSUnitPresenter categoriesFor: #selectPackageNamed:classNamed:!public! !
!JadeiteSUnitPresenter categoriesFor: #status!accessing!private! !
!JadeiteSUnitPresenter categoriesFor: #status:!accessing!private! !
!JadeiteSUnitPresenter categoriesFor: #testCasesSize!public! !
!JadeiteSUnitPresenter categoriesFor: #testClassesSize!public! !

!JadeiteSUnitPresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil nil 5 nil nil nil 416 788230 ##(Smalltalk.BorderLayout) 1 1 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 512 nil nil nil 5 nil nil nil 512 1180166 ##(Smalltalk.ProportionalLayout) 170 176 8 #() true 170 192 34 2 410 ##(Smalltalk.StaticText) 34 16 nil 512 34 2 8 1140850944 1 672 nil 721158 ##(Smalltalk.SystemColor) 31 nil 5 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[240 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 188 2 0 0 0 0 0 0 1 2 1 34 83 121 115 116 101 109 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 328198 ##(Smalltalk.Point) 193 193 nil 672 nil 8 1695245616 852486 ##(Smalltalk.NullConverter) nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 850 1 55 850 1241 57 672 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 27 0 0 0 108 2 0 0 55 0 0 0] 8 #() 850 193 193 nil 27 8 'textResult' nil 930 138 144 34 1 994 #createAt:extent: 34 2 850 1 1 850 1241 111 512 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 108 2 0 0 55 0 0 0] 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 512 34 2 8 1140850688 131073 1328 nil 738 31 nil 5 nil nil nil 1328 482 1 1 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 1328 34 2 8 1140850688 131073 1424 nil nil nil 5 nil nil nil 1424 578 170 176 624 false 170 192 624 nil 930 138 144 34 1 994 #createAt:extent: 34 2 850 1021 1 850 221 55 1424 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 254 1 0 0 0 0 0 0 108 2 0 0 27 0 0 0] 34 1 410 ##(Smalltalk.SUnitToolbar) 34 25 nil 1424 34 2 8 1140853516 131137 1696 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 nil 517 nil nil nil 1696 1762 1792 8 4294909487 nil 170 192 34 8 16281 853766 ##(Smalltalk.ToolbarButton) 16281 nil 1696 1 1180998 4 ##(Smalltalk.CommandDescription) #debug 8 'Debug' 1 1 nil 395334 3 ##(Smalltalk.Bitmap) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'Tools.bmp' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil nil 7 850 1857 33 15 16283 1246982 ##(Smalltalk.ToolbarSystemButton) 16283 nil 1696 1 1906 #refresh 8 'Refresh' 1 1 nil 1 9 16277 1874 16277 nil 1696 1 1906 #runAll 8 'Run All' 1 1 nil 1968 51 16279 1874 16279 nil 1696 1 1906 #runSelected 8 'Run Selected' 1 1 nil 1968 83 34 6 2160 2208 1050118 ##(Smalltalk.ToolbarSeparator) nil nil 1696 3 nil 1 1888 2274 nil nil 1696 3 nil 1 2112 170 176 34 4 1 117 1968 1 nil 1 nil 850 33 33 850 45 45 nil nil 930 138 144 34 2 994 #createAt:extent: 34 2 850 1 1 850 221 55 1696 994 #updateSizePosted 624 1696 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 110 0 0 0 27 0 0 0] 8 #() 1136 nil 27 1136 nil 27 nil 410 ##(Smalltalk.ContainerView) 34 15 nil 1328 34 2 8 1140850688 131073 2560 nil 738 31 nil 5 nil nil nil 2560 578 170 176 624 false 170 192 34 2 410 ##(Smalltalk.Toolbar) 34 25 nil 2560 34 2 8 1409288972 131137 2704 nil 1762 8 4278190080 nil 517 nil 770 nil true 802 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 850 193 193 nil 2704 1762 2784 8 4294909487 170 192 624 170 192 34 4 16273 1874 16273 nil 2704 1 1906 #abortTransaction 8 'Abort Transaction' 1 1 nil 1968 1 16275 1874 16275 nil 2704 1 1906 #commitTransaction 8 'Commit Transaction' 1 1 nil 1968 27 34 2 2944 2992 170 176 34 2 1968 1 nil 1 nil 850 33 33 850 45 45 nil 656198 1 ##(Smalltalk.FlowLayout) 1 1 1 930 138 144 34 2 994 #createAt:extent: 34 2 850 1 1 850 1021 55 2704 994 #updateSizePosted 624 2704 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 254 1 0 0 27 0 0 0] 8 #() 1136 nil 27 8 'toolbar' nil 930 138 144 34 1 994 #createAt:extent: 34 2 850 1 1 850 1021 55 2560 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 254 1 0 0 27 0 0 0] 34 1 2704 1136 nil 27 170 192 624 nil 930 138 144 34 1 994 #createAt:extent: 34 2 850 1 1 850 1241 55 1328 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 108 2 0 0 27 0 0 0] 34 2 2560 1424 1136 nil 27 672 1136 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 3680 nil 738 31 nil 5 nil nil nil 3680 578 170 176 624 false 170 192 624 nil 930 138 144 34 1 994 #createAt:extent: 34 2 850 1 811 850 1241 61 3680 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 149 1 0 0 108 2 0 0 179 1 0 0] 34 1 410 ##(Smalltalk.StatusBar) 34 18 nil 3680 34 2 8 1409288460 1 3968 nil 1762 8 4278190080 nil 5 nil 770 nil true 802 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 850 193 193 nil 3968 nil 8 4294911859 170 192 34 8 853766 ##(Smalltalk.StatusBarItem) 1 401 3968 nil 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 ##(Smalltalk.Message) 8 'doIt' 8 '[:each | each getTestCounter]' 8 #[30 105 226 0 106] #getTestCounter 4224 7 257 nil 4210 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 4176 #defaultGetImageBlock 405994851 8 #[30 105 226 0 106] #iconImageIndex 4320 7 257 nil nil 8 'statusTestCounter' 4178 1 401 3968 nil 4210 0 nil 4242 2 1 ##(Smalltalk.Message) 8 'doIt' 8 '[:each | each testClassesSize]' 8 #[30 105 226 0 106] #testClassesSize 4416 7 257 nil 4210 0 nil 4338 2 3 4176 #defaultGetImageBlock 405994851 8 #[30 105 226 0 106] #iconImageIndex 4496 7 257 nil nil 8 'statusTestsClasses' 4178 1 401 3968 nil 4210 0 nil 4242 2 1 ##(Smalltalk.Message) 8 'doIt' 8 '[:each | each packagesSize]' 8 #[30 105 226 0 106] #packagesSize 4576 7 257 nil 459270 ##(Smalltalk.Message) #iconImageIndex 8 #() 1049926 1 ##(Smalltalk.IconImageManager) 8 'statusPackages' 4178 1 401 3968 nil 4210 0 nil 4242 2 1 4656 8 'doIt' 8 '[:each | each testCasesSize]' 8 #[30 105 226 0 106] #testCasesSize 4768 7 257 nil 4496 nil 8 'statusTestCases' 34 4 4560 4400 4752 4192 1115142 ##(Smalltalk.StatusBarNullItem) 513 1 3968 nil 578 170 176 624 false 930 138 144 34 1 994 #createAt:extent: 34 2 850 1 1 850 1241 61 3968 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 108 2 0 0 30 0 0 0] 8 #() 1136 nil 27 1136 nil 27 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 5104 nil nil nil 5 nil nil nil 5104 578 170 176 624 false 170 192 34 6 410 ##(Smalltalk.ListView) 34 30 nil 5104 34 2 8 1409388621 1025 5232 590662 2 ##(Smalltalk.ListModel) 138 144 624 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 1762 8 4278190080 nil 5 nil nil nil 5232 nil 8 4294909441 4658 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 4720 nil nil nil nil nil nil 138 144 34 1 920646 5 ##(Smalltalk.ListViewColumn) 8 'Packages' 399 #left 4210 0 nil 4242 2 1 4656 8 'doIt' 8 '[:packageService | packageService name]' 8 #[30 105 226 0 106] #name 5536 7 257 nil ##(Smalltalk.SortedCollection) nil nil 5232 nil 3 nil nil #report 624 nil 131169 nil 34 4 nil nil 850 1 1 nil 930 138 144 34 2 994 #createAt:extent: 34 2 850 1 1 850 407 701 5232 994 #text: 34 1 8 'Packages' 5232 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 203 0 0 0 94 1 0 0] 8 #() 1136 nil 27 8 'packages' 410 ##(Smalltalk.ListView) 34 30 nil 5104 34 2 8 1409388617 1025 5872 5298 138 144 624 nil 5360 1762 5392 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 1 984134 2 ##(Smalltalk.CommandMenuItem) 1 1906 #browseClass 8 'Browse Class' 9367 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 5872 nil 8 4294909441 4658 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 4720 nil nil nil nil nil nil 138 144 34 1 5490 8 'Classes' 399 #left 4210 0 nil 4242 2 1 4656 8 'doIt' 8 '[:classService | classService name]' 8 #[30 105 226 0 106] #name 6224 7 257 nil ##(Smalltalk.SortedCollection) nil nil 5872 nil 3 nil nil #report 624 nil 131169 nil 34 4 nil nil 850 1 1 nil 930 138 144 34 3 994 #createAt:extent: 34 2 850 417 1 850 407 701 5872 994 #contextMenu: 34 1 6000 5872 994 #text: 34 1 8 'Classes' 5872 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 208 0 0 0 0 0 0 0 155 1 0 0 94 1 0 0] 8 #() 1136 nil 27 8 'testClasses' 410 ##(Smalltalk.MultipleSelectionListView) 34 30 nil 5104 34 2 8 1140953161 1025 6592 5298 138 144 624 nil 5360 1762 8 4278190080 nil 5 5986 nil true 34 8 6034 1 1906 #runAll 8 'Run All' 9347 1 nil nil nil 6034 1 1906 #runSelected 8 'Run Selected' 9383 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 6034 1 1906 #debug 8 'Debug' 9349 1 nil nil nil 6850 4097 6034 1 1906 #browseMethods 8 'Browse Methods' 9371 1 nil nil nil 6850 4097 6034 1 1906 #reset 8 'Reset' 9381 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 6592 nil 8 4294909441 4658 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 4720 nil nil nil nil nil nil 138 144 34 1 5490 8 'Methods' 401 #left 4210 0 nil 4242 2 1 4656 8 'doIt' 8 '[:methodService | methodService name]' 8 #[30 105 226 0 106] #name 7184 7 257 nil 4210 0 nil 4242 2 1 106 8 'Dolphin' 8 'SortedCollection' 8 'doIt' 8 '[:a :b | a methodName <= b methodName]' 8 #[30 105 226 0 226 32 130 106] #methodName 7264 7 513 nil nil nil 6592 nil 3 nil nil #report 624 850 65 65 131169 nil 34 4 nil nil 850 1 1 nil 930 138 144 34 3 994 #createAt:extent: 34 2 850 833 1 850 409 701 6592 994 #contextMenu: 34 1 6720 6592 994 #text: 34 1 8 'Methods' 6592 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 160 1 0 0 0 0 0 0 108 2 0 0 94 1 0 0] 8 #() 1136 nil 27 8 'testCases' nil 930 138 144 34 1 994 #createAt:extent: 34 2 850 1 111 850 1241 701 5104 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 55 0 0 0 108 2 0 0 149 1 0 0] 34 5 5232 410 ##(Smalltalk.Splitter) 34 12 nil 5104 34 2 8 1140850688 1 7856 nil 1762 8 4278190080 nil 517 nil nil nil 7856 930 138 144 34 1 994 #createAt:extent: 34 2 850 407 1 850 11 701 7856 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 203 0 0 0 0 0 0 0 208 0 0 0 94 1 0 0] 8 #() 1136 nil 27 5872 410 ##(Smalltalk.Splitter) 34 12 nil 5104 34 2 8 1140850688 1 8112 nil 1762 7936 nil 517 nil nil nil 8112 930 138 144 34 1 994 #createAt:extent: 34 2 850 823 1 850 11 701 8112 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 155 1 0 0 0 0 0 0 160 1 0 0 94 1 0 0] 8 #() 1136 nil 27 6592 1136 nil 27 170 192 624 nil 930 138 144 34 1 994 #createAt:extent: 34 2 850 7679 21 850 1241 871 416 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 14 0 0 10 0 0 0 107 17 0 0 189 1 0 0] 34 3 512 5104 3680 1136 nil 27 )! !
!JadeiteSUnitPresenter class categoriesFor: #resource_Default_view!public!resources-views! !
