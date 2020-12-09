"Filed out from Dolphin Smalltalk 7"!

JadeiteSUnitAbstractPresenter subclass: #JadeiteSUnitPresenter
	instanceVariableNames: 'packageListPresenter classListPresenter status testCounter methodColumns'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteSUnitPresenter guid: (GUID fromString: '{f0d7615e-1a5a-4d8a-b979-c2ad927a9f74}')!
JadeiteSUnitPresenter comment: ''!
!JadeiteSUnitPresenter categoriesForClass!Unclassified! !
!JadeiteSUnitPresenter methodsFor!

addUpdatedTestClasses: classServices
	"don't add class that the package doesn't think should be shown"

	| inSelectedPackage |
	inSelectedPackage := OrderedCollection new.
	packageListPresenter selections do: 
			[:packageService |
			packageService classes
				ifNotNil: 
					[classServices
						do: [:classService | (packageService classes includes: classService) ifTrue: [inSelectedPackage add: classService]]]].
	classListPresenter model addAll: inSelectedPackage!

basicDelete
	classListPresenter selection
		command: #removeMethods:;
		commandArgs: (Array with: methodListPresenter selections).
	self issueCommand: classListPresenter selection!

browseMethods
	^self browseSelectedMethods!

classListPresenter
	^classListPresenter!

commitTransaction
	super commitTransaction!

createComponents
	super createComponents.
	packageListPresenter := self add: ListPresenter new name: 'packages'.
	classListPresenter := self add: ListPresenter new name: 'testClasses'.
	packageListPresenter
		model: (ListModel new list: (SortedCollection sortBlock: [:x :y | x name < y name])).
	self initializeClassList!

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
	self debugTests: methodListPresenter selection!

debugTests: methodServices
	| className |
	className := classListPresenter selections size = 1
				ifTrue: [classListPresenter selections first name]
				ifFalse: [].
	^self debugTestMethodServices: methodServices className: className!

delete
	| selectors writeStream |
	selectors := methodListPresenter selections collect: [:methodService | methodService selector].
	selectors isEmpty ifTrue: [^self].
	writeStream := WriteStream on: String new.
	writeStream nextPutAll: 'Really delete these test methods?'.
	selectors do: 
			[:symbol |
			writeStream
				cr;
				nextPutAll: symbol].
	MessageBox confirm: writeStream contents!

displayStringFor: methodService in: displayThing
	| packageNames |
	packageNames := packageListPresenter selections collect: [:packageService | packageService name].
	(packageNames includes: methodService definedPackage)
		ifFalse: 
			[displayThing forecolor: Color darkMagenta.
			methodService inSelectedPackage ifFalse: [displayThing font beUnderlined]]!

editSelectAll
	^classListPresenter view hasFocus
		ifTrue: [classListPresenter selections: classListPresenter list]
		ifFalse: [super editSelectAll]!

getTestCounter

	^'Total Tests: ', testCounter first printString!

initializeClassList
	classListPresenter
		model: (ListModel new list: (SortedCollection sortBlock: [:x :y | x name < y name]))!

isNoneProjectSelected
	"no concept of dictionaries in sunit browser"

	^false!

methodListPresenter
	^methodListPresenter!

onClassesChanged
	Cursor wait showWhile: 
			[classListPresenter selections size > 1
				ifTrue: [methodListPresenter view columnsList: methodColumns]
				ifFalse: [methodListPresenter view columnsList: (Array with: methodColumns second)].
			self updateMethods.
			methodListPresenter view resortOnLastColumnClicked.
			status value: nil.
			status value: self.
			self reset]!

onPackageChanged
	Cursor wait showWhile: 
			[self updateClasses.
			status value: nil.
			status value: self.
			self reset]!

packageListPresenter
	^packageListPresenter!

packagesSize
	^'Packages: ' , packageListPresenter model size printString!

queryCommand: commandQuery
	commandQuery isEnabled: true.
	(#(#browseMethods #debug #runSelected) includes: commandQuery command)
		ifTrue: 
			[methodListPresenter selections isEmpty ifTrue: [commandQuery isEnabled: false].
			^true].
	(#(#browseClass) includes: commandQuery command)
		ifTrue: 
			[classListPresenter selections isEmpty ifTrue: [commandQuery isEnabled: false].
			^true].
	^true!

refresh
	| packageSelections classSelections methodSelections |
	packageSelections := packageListPresenter selections.
	classSelections := classListPresenter selections.
	methodSelections := methodListPresenter selections.
	self updateProjectPackages.
	packageListPresenter selections: (packageListPresenter list
				select: [:packageService | packageSelections includes: packageService]).
	classListPresenter selections: (classListPresenter list
				select: [:packageService | classSelections includes: packageService]).
	methodListPresenter selections: (methodListPresenter list
				select: [:packageService | methodSelections includes: packageService]).
	self reset!

refreshFromServerAfterAbort: browserService
	browserService testPackages: packageListPresenter!

runAll
	^(classListPresenter selections size > 1 or: [classListPresenter selections isEmpty])
		ifTrue: [self runTests: methodListPresenter model]
		ifFalse: [self runTests: methodListPresenter model in: classListPresenter selections first name]!

runSelected
	"if multiple classes are selected, we really don't know which test class
	the user intended for the test to be run so pick the class the test is defined in"

	^classListPresenter selections size > 1
		ifTrue: [self runTests: methodListPresenter selections]
		ifFalse: [self runTests: methodListPresenter selections in: classListPresenter selections first name]!

runTestMethodServices: methodServices className: className
	| jadeResult |
	jadeResult := super runTestMethodServices: methodServices className: className.
	self methodListPresenter view ensureSelectionVisible.
	^jadeResult!

selectClassNamed: name
	"for testing at the moment"

	| classService |
	classService := classListPresenter list detect: [:service | service name = name] ifNone: [^self].
	classListPresenter selection: classService!

selectedClass

	^classListPresenter selectionOrNil!

selectedFilters
	"no categories in sunit browser"
	^Array new !

selectedPackageServiceNames
	^packageListPresenter selections collect: [:packageService | packageService name]!

selectedPackageServices
	^packageListPresenter selections!

selectMethodNamed: selector
	"for testing at the moment" 
	| methodService |
	methodService := methodListPresenter list detect: [:service | service selector = selector] ifNone: [^self].
	methodListPresenter selections: (Array with: methodService)!

selectMethodsNamed: selectors
	| methodServices |
	methodServices := methodListPresenter list select: [:service | selectors includes: service selector].
	methodListPresenter selections: (Array with: methodServices)!

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
	^'Test Classes:' , classListPresenter model size printString!

update: newMethods orRemove: removals
	| listModel |
	methodListPresenter model do: 
			[:existing |
			| new |
			new := newMethods detect: [:newService | newService = existing]
						ifNone: 
							[removals add: existing.
							nil].
			new
				ifNotNil: 
					[existing replicateFrom: new.
					new replicateFrom: existing.
					newMethods remove: new	"order matters so we get the right test result"]].
	listModel := ListModel withAll: ((methodListPresenter model union: newMethods)
						asSortedCollection: [:x :y | x selector < y selector]).
	listModel removeAll: removals. 
	methodListPresenter model: listModel.
	methodListPresenter view invalidate. !

updateClasses
	| packageServices |
	self initializeClassList.
	packageServices := packageListPresenter selections.
	packageServices do: [:packageService | packageService command: #testClasses].
	self issueCommands: packageServices!

updateMethods
	| classServices |
	classServices := classListPresenter selections.
	classServices do: 
			[:service |
			service
				updateAfterCommand: false;
				command: #fastRefresh].
	self issueCommands: classServices.
	classServices do: [:service | service updateAfterCommand: true].
	^self updateMethodsFrom: classServices!

updateMethodsFrom: classServices
	| newMethods selectedSelectors removals |
	classServices isEmpty ifTrue: [^methodListPresenter list: ListModel new].
	selectedSelectors := methodListPresenter selections
				collect: [:methodService | methodService selector].
	removals := OrderedCollection new.
	newMethods := OrderedCollection new.
	classServices do: 
			[:classService |
			| tests |
			"show the class that the test will be run under"
			tests := classService visibleTests. 
			tests do: [:methodService | methodService className: classService name].
			newMethods addAll: tests].
	self update: newMethods orRemove: removals.
	methodListPresenter selections: (methodListPresenter model
				select: [:methodService | selectedSelectors includes: methodService selector]).
	methodListPresenter view invalidate.
	methodListPresenter view resortOnLastColumnClicked.! !
!JadeiteSUnitPresenter categoriesFor: #addUpdatedTestClasses:!public!updating! !
!JadeiteSUnitPresenter categoriesFor: #basicDelete!menu handlers!public! !
!JadeiteSUnitPresenter categoriesFor: #browseMethods!event handlers!public! !
!JadeiteSUnitPresenter categoriesFor: #classListPresenter!accessing!private! !
!JadeiteSUnitPresenter categoriesFor: #commitTransaction!public!transaction management! !
!JadeiteSUnitPresenter categoriesFor: #createComponents!initialization!public! !
!JadeiteSUnitPresenter categoriesFor: #createSchematicWiring!initialization!public! !
!JadeiteSUnitPresenter categoriesFor: #debug!public! !
!JadeiteSUnitPresenter categoriesFor: #debugTests:!public! !
!JadeiteSUnitPresenter categoriesFor: #delete!menu handlers support!public! !
!JadeiteSUnitPresenter categoriesFor: #displayStringFor:in:!double dispatch!public! !
!JadeiteSUnitPresenter categoriesFor: #editSelectAll!menu handlers support!public! !
!JadeiteSUnitPresenter categoriesFor: #getTestCounter!public! !
!JadeiteSUnitPresenter categoriesFor: #initializeClassList!public! !
!JadeiteSUnitPresenter categoriesFor: #isNoneProjectSelected!public!testing! !
!JadeiteSUnitPresenter categoriesFor: #methodListPresenter!accessing!private! !
!JadeiteSUnitPresenter categoriesFor: #onClassesChanged!event handlers!public! !
!JadeiteSUnitPresenter categoriesFor: #onPackageChanged!event handlers!public! !
!JadeiteSUnitPresenter categoriesFor: #packageListPresenter!accessing!private! !
!JadeiteSUnitPresenter categoriesFor: #packagesSize!public! !
!JadeiteSUnitPresenter categoriesFor: #queryCommand:!event handlers!public! !
!JadeiteSUnitPresenter categoriesFor: #refresh!event handlers!public! !
!JadeiteSUnitPresenter categoriesFor: #refreshFromServerAfterAbort:!event handlers!public! !
!JadeiteSUnitPresenter categoriesFor: #runAll!public! !
!JadeiteSUnitPresenter categoriesFor: #runSelected!public! !
!JadeiteSUnitPresenter categoriesFor: #runTestMethodServices:className:!private! !
!JadeiteSUnitPresenter categoriesFor: #selectClassNamed:!public!selection! !
!JadeiteSUnitPresenter categoriesFor: #selectedClass!accessing!public! !
!JadeiteSUnitPresenter categoriesFor: #selectedFilters!accessing!public! !
!JadeiteSUnitPresenter categoriesFor: #selectedPackageServiceNames!public!selection! !
!JadeiteSUnitPresenter categoriesFor: #selectedPackageServices!public!selection! !
!JadeiteSUnitPresenter categoriesFor: #selectMethodNamed:!public!selection! !
!JadeiteSUnitPresenter categoriesFor: #selectMethodsNamed:!public!selection! !
!JadeiteSUnitPresenter categoriesFor: #selectPackageNamed:!public!selection! !
!JadeiteSUnitPresenter categoriesFor: #selectPackageNamed:classNamed:!public! !
!JadeiteSUnitPresenter categoriesFor: #status!accessing!private! !
!JadeiteSUnitPresenter categoriesFor: #status:!accessing!private! !
!JadeiteSUnitPresenter categoriesFor: #testCasesSize!public! !
!JadeiteSUnitPresenter categoriesFor: #testClassesSize!public! !
!JadeiteSUnitPresenter categoriesFor: #update:orRemove:!event handlers!private! !
!JadeiteSUnitPresenter categoriesFor: #updateClasses!event handlers!public! !
!JadeiteSUnitPresenter categoriesFor: #updateMethods!event handlers!public! !
!JadeiteSUnitPresenter categoriesFor: #updateMethodsFrom:!event handlers!public! !

!JadeiteSUnitPresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil nil 5 nil nil nil 416 788230 ##(Smalltalk.BorderLayout) 1 1 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 512 nil nil nil 5 nil nil nil 512 1180166 ##(Smalltalk.ProportionalLayout) 170 176 8 #() true 170 192 34 2 410 ##(Smalltalk.StaticText) 34 16 nil 512 34 2 8 1140850944 1 672 nil 327686 ##(Smalltalk.Color) #face3d nil 5 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[240 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 188 2 0 0 0 0 0 0 1 2 1 34 83 121 115 116 101 109 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 328198 ##(Smalltalk.Point) 193 193 nil 672 nil 8 1650166432 852486 ##(Smalltalk.NullConverter) nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 850 1 55 850 2031 57 672 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 27 0 0 0 247 3 0 0 55 0 0 0] 8 #() 850 193 193 nil 27 8 'textResult' nil 930 138 144 34 1 994 #createAt:extent: 34 2 850 1 1 850 2031 111 512 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 247 3 0 0 55 0 0 0] 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 512 34 2 8 1140850688 131073 1328 nil 752 nil 5 nil nil nil 1328 482 1 1 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 1328 34 2 8 1140850688 131073 1408 nil nil nil 5 nil nil nil 1408 578 170 176 624 false 170 192 624 nil 930 138 144 34 1 994 #createAt:extent: 34 2 850 1811 1 850 221 55 1408 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 137 3 0 0 0 0 0 0 247 3 0 0 27 0 0 0] 34 1 410 ##(Smalltalk.SUnitToolbar) 34 25 nil 1408 34 2 8 1140853516 131137 1680 nil 738 #default nil 517 nil nil nil 1680 1744 8 1650109728 nil 170 192 34 8 54781 1246790 1 ##(Smalltalk.ToolbarBitmapButton) 1680 1 1180998 4 ##(Smalltalk.CommandDescription) #runSelected 8 'Run Selected' 13479 1 nil 54781 395334 3 ##(Smalltalk.Bitmap) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'Tools.bmp' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil nil 7 850 1857 33 83 54779 1810 1680 1 1842 #runAll 8 'Run All' 13443 1 nil 54779 1904 51 54785 1246790 1 ##(Smalltalk.ToolbarSystemButton) 1680 1 1842 #refresh 8 'Refresh' 1 1 nil 54785 1 9 54783 1810 1680 1 1842 #debug 8 'Debug' 1 1 nil 54783 1904 15 34 6 2032 1824 1049158 1 ##(Smalltalk.ToolbarSeparator) 1680 1 2144 2210 1680 1 2096 nil nil 1 nil 850 33 33 850 45 45 nil nil 930 138 144 34 2 994 #createAt:extent: 34 2 850 1 1 850 221 55 1680 994 #updateSizePosted 624 1680 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 110 0 0 0 27 0 0 0] 8 #() 1136 nil 27 1136 nil 27 nil 410 ##(Smalltalk.ContainerView) 34 15 nil 1328 34 2 8 1140850688 131073 2464 nil 752 nil 5 nil nil nil 2464 578 170 176 624 false 170 192 34 2 410 ##(Smalltalk.Toolbar) 34 25 nil 2464 34 2 8 1409288972 131137 2592 nil 1744 nil 517 nil 770 nil true 802 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 850 193 193 nil 2592 1744 8 1650109728 170 192 624 170 192 34 4 54777 1810 2592 1 1842 #commitTransaction 8 'Commit Transaction' 1 1 nil 54777 1904 27 54775 1810 2592 1 1842 #abortTransaction 8 'Abort Transaction' 1 1 nil 54775 1904 1 34 2 2832 2784 nil nil 1 nil 850 33 33 850 45 45 nil 656198 1 ##(Smalltalk.FlowLayout) 1 1 1 930 138 144 34 2 994 #createAt:extent: 34 2 850 1 1 850 1811 55 2592 994 #updateSizePosted 624 2592 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 137 3 0 0 27 0 0 0] 8 #() 1136 nil 27 8 'toolbar' nil 930 138 144 34 1 994 #createAt:extent: 34 2 850 1 1 850 1811 55 2464 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 137 3 0 0 27 0 0 0] 34 1 2592 1136 nil 27 170 192 624 nil 930 138 144 34 1 994 #createAt:extent: 34 2 850 1 1 850 2031 55 1328 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 247 3 0 0 27 0 0 0] 34 2 2464 1408 1136 nil 27 672 1136 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 3488 nil 752 nil 5 nil nil nil 3488 578 170 176 624 false 170 192 624 nil 930 138 144 34 1 994 #createAt:extent: 34 2 850 1 1141 850 2031 61 3488 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 58 2 0 0 247 3 0 0 88 2 0 0] 34 1 410 ##(Smalltalk.StatusBar) 34 18 nil 3488 34 2 8 1409288460 1 3760 nil 1744 nil 5 nil 770 nil true 802 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 850 193 193 nil 3760 nil 8 1649992288 170 192 34 8 853766 ##(Smalltalk.StatusBarItem) 513 501 3760 nil 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 ##(Smalltalk.Message) 8 'doIt' 8 '[:each | each testCasesSize]' 8 #[30 105 226 0 106] #testCasesSize 3984 7 257 nil 3970 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 3936 #defaultGetImageBlock 405994851 8 #[30 105 226 0 106] #iconImageIndex 4080 7 257 nil nil 8 'statusTestCases' 3938 513 501 3760 nil 3970 0 nil 4002 2 1 ##(Smalltalk.Message) 8 'doIt' 8 '[:each | each getTestCounter]' 8 #[30 105 226 0 106] #getTestCounter 4176 7 257 nil 3970 0 nil 4098 2 3 3936 #defaultGetImageBlock 405994851 8 #[30 105 226 0 106] #iconImageIndex 4256 7 257 nil nil 8 'statusTestCounter' 3938 513 501 3760 nil 3970 0 nil 4002 2 1 ##(Smalltalk.Message) 8 'doIt' 8 '[:each | each packagesSize]' 8 #[30 105 226 0 106] #packagesSize 4336 7 257 nil 459270 ##(Smalltalk.Message) #iconImageIndex 8 #() 1049926 1 ##(Smalltalk.IconImageManager) 8 'statusPackages' 3938 513 501 3760 nil 3970 0 nil 4002 2 1 4416 8 'doIt' 8 '[:each | each testClassesSize]' 8 #[30 105 226 0 106] #testClassesSize 4528 7 257 nil 4080 nil 8 'statusTestsClasses' 34 4 4320 4512 3952 4160 1115142 ##(Smalltalk.StatusBarNullItem) 513 1 3760 nil 578 170 176 624 false 930 138 144 34 1 994 #createAt:extent: 34 2 850 1 1 850 2031 61 3760 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 247 3 0 0 30 0 0 0] 8 #() 1136 nil 27 1136 nil 27 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 4864 nil nil nil 5 nil nil nil 4864 578 170 176 34 6 410 ##(Smalltalk.MultipleSelectionListView) 34 30 nil 4864 34 2 8 1140920393 1025 4976 590662 2 ##(Smalltalk.ListModel) 138 144 624 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 1744 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 8 984134 2 ##(Smalltalk.CommandMenuItem) 1 1842 #runAll 8 'Run All' 13443 1 nil nil nil 5170 1 1842 #runSelected 8 'Run Selected' 13479 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 5170 1 1842 #debug 8 'Debug' 9349 1 nil nil nil 5282 4097 5170 1 1842 #browseMethods 8 'Browse Selected Tests' 1025 1 nil nil nil 5282 4097 5170 1 1842 #reset 8 'Reset' 9381 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 4976 nil 8 1650059376 4418 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 4480 nil nil nil nil nil nil 138 144 34 2 920646 5 ##(Smalltalk.ListViewColumn) 8 'Test Execution Class' 441 #left 3970 0 nil 4002 2 1 3968 8 'doIt' 8 '[:methodService | methodService className ]' 8 #[30 105 226 0 106] #className 5632 7 257 nil 3970 0 nil 4002 2 1 3968 8 'doIt' 8 '[:a :b | a className <= b className]' 8 #[30 105 226 0 226 32 130 106] #className 5712 7 513 nil nil nil 4976 nil 3 nil 3970 0 nil 4002 5 1 3968 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 5792 7 257 nil 5586 8 'Test Selector' 439 #left 4418 #selector 8 #() 3970 0 nil 4002 2 1 3968 8 'doIt' 8 '[:a :b | a selector <= b selector]' 8 #[30 105 226 0 226 32 130 106] #selector 5936 7 513 nil nil nil 4976 nil 3 nil nil #report 624 850 65 65 131169 nil 34 4 nil nil 850 1 1 nil 930 138 144 34 3 994 #createAt:extent: 34 2 850 1137 1 850 895 1031 4976 994 #contextMenu: 34 1 5136 4976 994 #text: 34 1 8 'Test Execution Class' 4976 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 56 2 0 0 0 0 0 0 247 3 0 0 3 2 0 0] 8 #() 1136 nil 27 5 410 ##(Smalltalk.ListView) 34 30 nil 4864 34 2 8 1409388617 1025 6304 5042 138 144 624 nil 5104 1744 nil 5 5122 nil true 34 1 5170 1 1842 #browseClass 8 'Browse Class' 9367 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 6304 nil 8 1650059376 4418 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 4480 nil nil nil nil nil nil 138 144 34 1 5586 8 'Classes' 551 #left 3970 0 nil 4002 2 1 4416 8 'doIt' 8 '[:classService | classService name]' 8 #[30 105 226 0 106] #name 6608 7 257 nil ##(Smalltalk.SortedCollection) nil nil 6304 nil 3 nil 3970 0 nil 4002 5 1 3968 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 6688 7 257 nil #report 624 nil 131169 nil 34 4 nil nil 850 1 1 nil 930 138 144 34 3 994 #createAt:extent: 34 2 850 569 1 850 559 1031 6304 994 #contextMenu: 34 1 6400 6304 994 #text: 34 1 8 'Classes' 6304 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 28 1 0 0 0 0 0 0 51 2 0 0 3 2 0 0] 8 #() 1136 nil 27 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 244 63 410 ##(Smalltalk.ListView) 34 30 nil 4864 34 2 8 1409388621 1025 7072 5042 138 144 624 nil 5104 1744 nil 5 nil nil nil 7072 nil 8 1650059376 4418 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 4480 nil nil nil nil nil nil 138 144 34 1 5586 8 'Packages' 551 #left 3970 0 nil 4002 2 1 4416 8 'doIt' 8 '[:packageService | packageService name]' 8 #[30 105 226 0 106] #name 7280 7 257 nil ##(Smalltalk.SortedCollection) nil nil 7072 nil 3 nil nil #report 624 nil 131169 nil 34 4 nil nil 850 1 1 nil 930 138 144 34 2 994 #createAt:extent: 34 2 850 1 1 850 559 1031 7072 994 #text: 34 1 8 'Packages' 7072 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 23 1 0 0 3 2 0 0] 8 #() 1136 nil 27 7042 8 0 0 0 0 0 0 244 63 false 170 192 34 6 4976 8 'testCases' 6304 8 'testClasses' 7072 8 'packages' nil 930 138 144 34 1 994 #createAt:extent: 34 2 850 1 111 850 2031 1031 4864 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 55 0 0 0 247 3 0 0 58 2 0 0] 34 5 7072 410 ##(Smalltalk.Splitter) 34 12 nil 4864 34 2 8 1140850688 1 7856 nil 1744 nil 517 nil nil nil 1510470 1 ##(Smalltalk.DraggableViewInteractor) 7856 nil 1 #left nil nil nil 850 1 1 850 9 9 nil 7952 nil 930 138 144 34 1 994 #createAt:extent: 34 2 850 559 1 850 11 1031 7856 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 23 1 0 0 0 0 0 0 28 1 0 0 3 2 0 0] 8 #() 1136 nil 27 6304 410 ##(Smalltalk.Splitter) 34 12 nil 4864 34 2 8 1140850688 1 8144 nil 1744 nil 517 nil nil nil 7922 8144 nil 1 #left nil nil nil 7952 7968 nil 7952 nil 930 138 144 34 1 994 #createAt:extent: 34 2 850 1127 1 850 11 1031 8144 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 51 2 0 0 0 0 0 0 56 2 0 0 3 2 0 0] 8 #() 1136 nil 27 4976 1136 nil 27 170 192 624 nil 930 138 144 34 1 994 #createAt:extent: 34 2 850 2879 21 850 2031 1201 416 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 159 5 0 0 10 0 0 0 150 9 0 0 98 2 0 0] 34 3 512 4864 3488 1136 nil 27 )! !
!JadeiteSUnitPresenter class categoriesFor: #resource_Default_view!public!resources-views! !

