"Filed out from Dolphin Smallalk"!

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
	self debugTests: methodListPresenter selections!

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

selectPackageNamed: packageName
	| packageService |
	packageService := packageListPresenter list detect: [:service | service name = packageName]
				ifNone: [^self].
	packageListPresenter selection: packageService!

selectPackageNamed: packageName classNamed: className
	| classService |
	self selectPackageNamed: packageName.
	classService := classListPresenter list detect: [:service | service name asString = className]
				ifNone: [^self].
	classListPresenter selection: classService!

selectPackageOrDictionaryNamed: name for: anObject
	"for testing at the moment"

	| packageService |
	packageService := packageListPresenter list detect: [:service | service name = name] ifNone: [^self].
	packageListPresenter selection: packageService!

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
	methodListPresenter model
		do: [:methodService | methodService inSelectedPackage: methodService packageName = packageListPresenter selection name].
	methodListPresenter selections: (methodListPresenter model
				select: [:methodService | selectedSelectors includes: methodService selector]).
	methodListPresenter view invalidate.
	methodListPresenter view resortOnLastColumnClicked! !
!JadeiteSUnitPresenter categoriesForMethods!
addUpdatedTestClasses:!public!updating! !
basicDelete!menu handlers!public! !
browseMethods!event handlers!public! !
classListPresenter!accessing!private! !
commitTransaction!public!transaction management! !
createComponents!initialization!public! !
createSchematicWiring!initialization!public! !
debug!public! !
debugTests:!public! !
delete!menu handlers support!public! !
displayStringFor:in:!double dispatch!public! !
editSelectAll!menu handlers support!public! !
getTestCounter!public! !
initializeClassList!public! !
isNoneProjectSelected!public!testing! !
methodListPresenter!accessing!private! !
onClassesChanged!event handlers!public! !
onPackageChanged!event handlers!public! !
packageListPresenter!accessing!private! !
packagesSize!public! !
queryCommand:!event handlers!public! !
refresh!event handlers!public! !
refreshFromServerAfterAbort:!event handlers!public! !
runAll!public! !
runSelected!public! !
runTestMethodServices:className:!private! !
selectClassNamed:!public!selection! !
selectedClass!accessing!public! !
selectedFilters!accessing!public! !
selectedPackageServiceNames!public!selection! !
selectedPackageServices!public!selection! !
selectMethodNamed:!public!selection! !
selectMethodsNamed:!public!selection! !
selectPackageNamed:!public! !
selectPackageNamed:classNamed:!public! !
selectPackageOrDictionaryNamed:for:!public!selection! !
status!accessing!private! !
status:!accessing!private! !
testCasesSize!public! !
testClassesSize!public! !
update:orRemove:!event handlers!private! !
updateClasses!event handlers!public! !
updateMethods!event handlers!public! !
updateMethodsFrom:!event handlers!public! !
!

!JadeiteSUnitPresenter class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ContainerView) 34 15 nil nil 34 2 8 1409286144 131073 416 nil nil nil 5 nil nil nil 416 788230 ##(Smalltalk.BorderLayout) 1 1 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 512 nil nil nil 5 nil nil nil 512 1180166 ##(Smalltalk.ProportionalLayout) 170 176 8 #() true 170 192 34 2 410 ##(Smalltalk.StaticText) 34 16 nil 512 34 2 8 1140850944 1 672 nil 721158 ##(Smalltalk.SystemColor) 31 nil 5 nil 263174 ##(Smalltalk.Font) nil true 459014 ##(Smalltalk.LOGFONT) 8 #[240 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 188 2 0 0 0 0 0 0 1 2 1 34 83 121 115 116 101 109 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 328198 ##(Smalltalk.Point) 193 193 nil 672 nil 8 1714981536 852486 ##(Smalltalk.NullConverter) nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 1 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 850 1 55 850 1241 57 672 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 27 0 0 0 108 2 0 0 55 0 0 0] 8 #() 850 193 193 nil 27 8 'textResult' nil 930 138 144 34 1 994 #createAt:extent: 34 2 850 1 1 850 1241 111 512 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 108 2 0 0 55 0 0 0] 34 2 410 ##(Smalltalk.ContainerView) 34 15 nil 512 34 2 8 1140850688 131073 1328 nil 738 31 nil 5 nil nil nil 1328 482 1 1 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 1328 34 2 8 1140850688 131073 1424 nil nil nil 5 nil nil nil 1424 578 170 176 624 false 170 192 624 nil 930 138 144 34 1 994 #createAt:extent: 34 2 850 1021 1 850 221 55 1424 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 254 1 0 0 0 0 0 0 108 2 0 0 27 0 0 0] 34 1 410 ##(Smalltalk.SUnitToolbar) 34 25 nil 1424 34 2 8 1140853516 131137 1696 nil 524550 ##(Smalltalk.ColorRef) 8 4278190080 nil 517 nil nil nil 1696 1762 1792 8 4294913055 nil 170 192 34 8 58543 853766 ##(Smalltalk.ToolbarButton) 58543 nil 1696 1 1180998 4 ##(Smalltalk.CommandDescription) #runAll 8 'Run All' 13443 1 nil 395334 3 ##(Smalltalk.Bitmap) nil true 1572870 ##(Smalltalk.ImageRelativeFileLocator) 8 'Tools.bmp' 2032142 ##(Smalltalk.STBExternalResourceLibraryProxy) 8 'dolphindr7.dll' nil nil 7 850 1857 33 51 58545 1874 58545 nil 1696 1 1906 #runSelected 8 'Run Selected' 13479 1 nil 1968 83 58547 1874 58547 nil 1696 1 1906 #debug 8 'Debug' 1 1 nil 1968 15 58549 1246982 ##(Smalltalk.ToolbarSystemButton) 58549 nil 1696 1 1906 #refresh 8 'Refresh' 1 1 nil 1 9 34 6 1888 2096 1050118 ##(Smalltalk.ToolbarSeparator) nil nil 1696 3 nil 1 2144 2274 nil nil 1696 3 nil 1 2208 170 176 34 4 1 117 1968 1 nil 1 nil 850 33 33 850 45 45 nil nil 930 138 144 34 2 994 #createAt:extent: 34 2 850 1 1 850 221 55 1696 994 #updateSizePosted 624 1696 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 110 0 0 0 27 0 0 0] 8 #() 1136 nil 27 1136 nil 27 nil 410 ##(Smalltalk.ContainerView) 34 15 nil 1328 34 2 8 1140850688 131073 2560 nil 738 31 nil 5 nil nil nil 2560 578 170 176 624 false 170 192 34 2 410 ##(Smalltalk.Toolbar) 34 25 nil 2560 34 2 8 1409288972 131137 2704 nil 1762 8 4278190080 nil 517 nil 770 nil true 802 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0] 850 193 193 nil 2704 1762 2784 8 4294913055 170 192 624 170 192 34 6 58541 1874 58541 nil 2704 1 1906 #commitTransaction 8 'Commit Transaction' 1 1 nil 1968 27 58585 1874 58585 nil 2704 1 1906 #beginTransaction 8 'Begin Transaction' 1 1 nil 1968 43 58539 1874 58539 nil 2704 1 1906 #abortTransaction 8 'Abort Transaction' 1 1 nil 1968 1 34 3 3040 2944 2992 170 176 34 2 1968 1 nil 1 nil 850 33 33 850 45 45 nil 656198 1 ##(Smalltalk.FlowLayout) 1 1 1 930 138 144 34 2 994 #createAt:extent: 34 2 850 1 1 850 1021 55 2704 994 #updateSizePosted 624 2704 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 254 1 0 0 27 0 0 0] 8 #() 1136 nil 27 8 'toolbar' nil 930 138 144 34 1 994 #createAt:extent: 34 2 850 1 1 850 1021 55 2560 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 254 1 0 0 27 0 0 0] 34 1 2704 1136 nil 27 170 192 624 nil 930 138 144 34 1 994 #createAt:extent: 34 2 850 1 1 850 1241 55 1328 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 108 2 0 0 27 0 0 0] 34 2 2560 1424 1136 nil 27 672 1136 nil 27 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 3728 nil 738 31 nil 5 nil nil nil 3728 578 170 176 624 false 170 192 624 nil 930 138 144 34 1 994 #createAt:extent: 34 2 850 1 811 850 1241 61 3728 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 149 1 0 0 108 2 0 0 179 1 0 0] 34 1 410 ##(Smalltalk.StatusBar) 34 18 nil 3728 34 2 8 1409288460 1 4016 nil 1762 8 4278190080 nil 5 nil 770 nil true 802 8 #[243 255 255 255 0 0 0 0 0 0 0 0 0 0 0 0 144 1 0 0 0 0 0 0 3 2 1 34 65 114 105 97 108 0 159 4 0 134 63 1 0 0 204 53 63 1 2 0 20 59 0 0 0 0 247 0 5 86 111 1] 850 193 193 nil 4016 nil 8 4294907749 170 192 34 8 853766 ##(Smalltalk.StatusBarItem) 1 401 4016 nil 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 2 1 ##(Smalltalk.Message) 8 'doIt' 8 '[:each | each packagesSize]' 8 #[30 105 226 0 106] #packagesSize 4272 7 257 nil 459270 ##(Smalltalk.Message) #iconImageIndex 8 #() 1049926 1 ##(Smalltalk.IconImageManager) 8 'statusPackages' 4226 1 401 4016 nil 4258 0 nil 4290 2 1 4368 8 'doIt' 8 '[:each | each testCasesSize]' 8 #[30 105 226 0 106] #testCasesSize 4480 7 257 nil 4258 0 nil 918822 ##(Smalltalk.CompiledMethod) 2 3 4224 #defaultGetImageBlock 405994851 8 #[30 105 226 0 106] #iconImageIndex 4560 7 257 nil nil 8 'statusTestCases' 4226 1 401 4016 nil 4258 0 nil 4290 2 1 4368 8 'doIt' 8 '[:each | each testClassesSize]' 8 #[30 105 226 0 106] #testClassesSize 4656 7 257 nil 4560 nil 8 'statusTestsClasses' 4226 1 401 4016 nil 4258 0 nil 4290 2 1 4368 8 'doIt' 8 '[:each | each getTestCounter]' 8 #[30 105 226 0 106] #getTestCounter 4768 7 257 nil 4258 0 nil 4578 2 3 4224 #defaultGetImageBlock 405994851 8 #[30 105 226 0 106] #iconImageIndex 4848 7 257 nil nil 8 'statusTestCounter' 34 4 4240 4640 4464 4752 1115142 ##(Smalltalk.StatusBarNullItem) 513 1 4016 nil 578 170 176 624 false 930 138 144 34 1 994 #createAt:extent: 34 2 850 1 1 850 1241 61 4016 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 108 2 0 0 30 0 0 0] 8 #() 1136 nil 27 1136 nil 27 nil nil 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 5152 nil nil nil 5 nil nil nil 5152 578 170 176 624 false 170 192 34 6 410 ##(Smalltalk.MultipleSelectionListView) 34 30 nil 5152 34 2 8 1140953161 1025 5280 590662 2 ##(Smalltalk.ListModel) 138 144 624 nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 1762 8 4278190080 nil 5 265030 4 ##(Smalltalk.Menu) nil true 34 8 984134 2 ##(Smalltalk.CommandMenuItem) 1 1906 #runAll 8 'Run All' 13443 1 nil nil nil 5506 1 1906 #runSelected 8 'Run Selected' 13479 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 5506 1 1906 #debug 8 'Debug' 9349 1 nil nil nil 5618 4097 5506 1 1906 #browseMethods 8 'Browse Methods' 9371 1 nil nil nil 5618 4097 5506 1 1906 #reset 8 'Reset' 9381 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 5280 nil 8 4294912595 4370 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 4432 nil nil nil nil nil nil 138 144 34 1 920646 5 ##(Smalltalk.ListViewColumn) 8 'Methods' 401 #left 4258 0 nil 4290 2 1 4368 8 'doIt' 8 '[:methodService | methodService name]' 8 #[30 105 226 0 106] #name 5968 7 257 nil 4258 0 nil 4290 2 1 106 8 'Dolphin' 8 'SortedCollection' 8 'doIt' 8 '[:a :b | a methodName <= b methodName]' 8 #[30 105 226 0 226 32 130 106] #methodName 6048 7 513 nil nil nil 5280 nil 3 nil 4258 0 nil 4290 5 1 4256 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 6176 7 257 nil #report 624 850 65 65 131169 nil 34 4 nil nil 850 1 1 nil 930 138 144 34 3 994 #createAt:extent: 34 2 850 833 1 850 409 701 5280 994 #contextMenu: 34 1 5472 5280 994 #text: 34 1 8 'Methods' 5280 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 160 1 0 0 0 0 0 0 108 2 0 0 94 1 0 0] 8 #() 1136 nil 27 8 'testCases' 410 ##(Smalltalk.ListView) 34 30 nil 5152 34 2 8 1409388621 1025 6560 5346 138 144 624 nil 5408 1762 8 4278190080 nil 5 nil nil nil 6560 nil 8 4294912595 4370 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 4432 nil nil nil nil nil nil 138 144 34 1 5922 8 'Packages' 399 #left 4258 0 nil 4290 2 1 4368 8 'doIt' 8 '[:packageService | packageService name]' 8 #[30 105 226 0 106] #name 6800 7 257 nil ##(Smalltalk.SortedCollection) nil nil 6560 nil 3 nil nil #report 624 nil 131169 nil 34 4 nil nil 850 1 1 nil 930 138 144 34 2 994 #createAt:extent: 34 2 850 1 1 850 407 701 6560 994 #text: 34 1 8 'Packages' 6560 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 203 0 0 0 94 1 0 0] 8 #() 1136 nil 27 8 'packages' 410 ##(Smalltalk.ListView) 34 30 nil 5152 34 2 8 1409388617 1025 7136 5346 138 144 624 nil 5408 1762 6672 nil 5 5458 nil true 34 1 5506 1 1906 #browseClass 8 'Browse Class' 9367 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 7136 nil 8 4294912595 4370 #displayString 8 #() ##(Smalltalk.IconicListAbstract) 4432 nil nil nil nil nil nil 138 144 34 1 5922 8 'Classes' 399 #left 4258 0 nil 4290 2 1 4368 8 'doIt' 8 '[:classService | classService name]' 8 #[30 105 226 0 106] #name 7456 7 257 nil ##(Smalltalk.SortedCollection) nil nil 7136 nil 3 nil 4258 0 nil 4290 5 1 4256 8 'doIt' 8 '[:each | each item displayStringFor: each browser: each view parentPresenter]' 8 #[33 105 226 0 17 226 1 160 193 106] #item #view #parentPresenter #displayStringFor:browser: 7536 7 257 nil #report 624 nil 131169 nil 34 4 nil nil 850 1 1 nil 930 138 144 34 3 994 #createAt:extent: 34 2 850 417 1 850 407 701 7136 994 #contextMenu: 34 1 7248 7136 994 #text: 34 1 8 'Classes' 7136 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 208 0 0 0 0 0 0 0 155 1 0 0 94 1 0 0] 8 #() 1136 nil 27 8 'testClasses' nil 930 138 144 34 1 994 #createAt:extent: 34 2 850 1 111 850 1241 701 5152 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 55 0 0 0 108 2 0 0 149 1 0 0] 34 5 6560 410 ##(Smalltalk.Splitter) 34 12 nil 5152 34 2 8 1140850688 1 8064 nil 1762 8 4278190080 nil 517 nil nil nil 8064 930 138 144 34 1 994 #createAt:extent: 34 2 850 407 1 850 11 701 8064 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 203 0 0 0 0 0 0 0 208 0 0 0 94 1 0 0] 8 #() 1136 nil 27 7136 410 ##(Smalltalk.Splitter) 34 12 nil 5152 34 2 8 1140850688 1 8320 nil 1762 8144 nil 517 nil nil nil 8320 930 138 144 34 1 994 #createAt:extent: 34 2 850 823 1 850 11 701 8320 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 155 1 0 0 0 0 0 0 160 1 0 0 94 1 0 0] 8 #() 1136 nil 27 5280 1136 nil 27 170 192 624 nil 930 138 144 34 1 994 #createAt:extent: 34 2 850 6829 21 850 1241 871 416 1074 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 86 13 0 0 10 0 0 0 194 15 0 0 189 1 0 0] 34 3 512 5152 3728 1136 nil 27 )! !

