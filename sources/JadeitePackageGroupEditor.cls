"Filed out from Dolphin Smallalk"!

JadeShell subclass: #JadeitePackageGroupEditor
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeitePackageGroupEditor guid: (GUID fromString: '{d68de4dd-c885-4824-b9e7-31b90c147e75}')!
JadeitePackageGroupEditor comment: ''!
!JadeitePackageGroupEditor categoriesForClass!Unclassified! !
!JadeitePackageGroupEditor methodsFor!

editPackageGroups: projectName
	self createView: self class defaultView.
	model := (RowanProjectDefinitionService new
				name: projectName;
				showLoadedPackageGroupsOnly: false) editInSession: gciSession window: self view handle value.
	self updateCaption.	"pick up the project definition name in the caption -- needed?"
	model session: self gciSession.
	myPresenter model: model.
	myPresenter displayPackageGroups.
	^self show!

export
	(MessageBox confirm: 'Really export changes to package groups to disk?')
		ifTrue: [^myPresenter export]!

load
	^myPresenter load!

onViewClosed
	super onViewClosed.
	myPresenter onViewClosed.
	self gciSession
		ifNotNil: [:sess | RowanBrowserService new releaseWindow: self view handle value session: self gciSession]!

presenterClass
	^JadeitePackageGroupPresenter!

updateCaption
	self caption: (gciSession titleBarFor: 'Package Group Editor for ', model name)! !
!JadeitePackageGroupEditor categoriesForMethods!
editPackageGroups:!initialization!public! !
export!actions!public! !
load!actions!public! !
onViewClosed!event handlers!public! !
presenterClass!public! !
updateCaption!public! !
!

!JadeitePackageGroupEditor class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 4 788558 10 ##(Smalltalk.STBViewProxy) ##(Smalltalk.ShellView) 34 27 nil nil 8 #(13565952 65536) 416 nil 327686 ##(Smalltalk.Color) #default nil 37 nil nil nil 416 852230 ##(Smalltalk.FramingLayout) 170 176 34 6 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 560 nil nil nil 7 nil nil nil 560 498 170 176 34 4 410 ##(Smalltalk.EditableListView) 34 55 nil 560 34 2 8 1140920393 1025 672 590662 2 ##(Smalltalk.ListModel) 138 144 8 #() nil 1310726 ##(Smalltalk.IdentitySearchPolicy) 480 nil 23 265030 4 ##(Smalltalk.Menu) nil true 34 4 984134 2 ##(Smalltalk.CommandMenuItem) 1 1180998 4 ##(Smalltalk.CommandDescription) #addPackageGroup 8 'Add Package Group ...' 1 1 nil nil nil 882 1 914 #removePackageGroups 8 'Remove Package Groups ...' 9393 1 nil nil nil 983366 1 ##(Smalltalk.DividerMenuItem) 4097 882 1 914 #addNewPackageToPackageGroup 8 'Add New Package to Package Group ...' 1 1 nil nil nil 8 '' nil 134217729 nil nil nil nil nil nil nil 672 nil 8 1591759072 787814 3 ##(Smalltalk.BlockClosure) 0 nil 1180966 ##(Smalltalk.CompiledExpression) 1 83886081 106 8 'Dolphin List Presenter' 8 'BasicListAbstract' 8 'doIt' 8 '[:each | each ]' 1779525917 1136 7 257 nil nil 1049926 1 ##(Smalltalk.IconImageManager) nil nil nil 328198 ##(Smalltalk.Point) 65 65 nil nil 138 144 34 2 1447750 15 ##(Smalltalk.EditableListViewColumn) 8 'Name' 289 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) 1122 0 nil 1154 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:service | service name]' 8 #[30 105 226 0 106] #name 1408 7 257 nil nil 672 nil 3 nil nil true 1122 0 nil 1154 2 1 1120 8 'doIt' 8 '[:packageGroupService :newName | packageGroupService renamePackageGroupTo: newName ]' 8 #[30 105 233 1 176 106] #renamePackageGroupTo: 1488 7 513 nil 1052998 20 ##(Smalltalk.EmbeddedTextEdit) nil nil 8 #(67174528 0) 1584 721990 2 ##(Smalltalk.ValueHolder) nil false 1310726 ##(Smalltalk.EqualitySearchPolicy) nil nil nil 5 nil nil nil 1584 nil nil 852486 ##(Smalltalk.NullConverter) nil 8 '' 1 nil nil nil nil nil nil nil nil nil 1362 8 'Condition' 289 #left 459270 ##(Smalltalk.Message) #displayString 8 #() 1762 #<= 1792 1122 0 nil 1154 2 1 ##(Smalltalk.UndefinedObject) 8 'doIt' 8 '[:service | service condition]' 8 #[30 105 226 0 106] #condition 1824 7 257 nil nil 672 nil 3 nil nil true 1122 0 nil 1154 2 1 1120 8 'doIt' 8 '[:packageGroupService :condition | packageGroupService setCondition: condition ]' 8 #[30 105 233 1 176 106] #setCondition: 1904 7 513 nil 1570 nil nil 8 #(67174528 0) 1984 1618 nil false 1664 nil 480 nil 5 nil nil nil 1984 nil nil nil 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131169 nil 1 nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil nil 3 nil nil nil nil 983302 ##(Smalltalk.MessageSequence) 138 144 34 3 721670 ##(Smalltalk.MessageSend) #createAt:extent: 34 2 1298 1 51 1298 585 623 672 2114 #contextMenu: 34 1 848 672 2114 #text: 34 1 8 'Name' 672 983302 ##(Smalltalk.WINDOWPLACEMENT) 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 36 1 0 0 80 1 0 0] 8 #() 1298 193 193 nil 33 1181766 2 ##(Smalltalk.FramingConstraints) 1180678 ##(Smalltalk.FramingCalculation) #fixedParentLeft 1 2386 #fixedParentRight 1 2386 #fixedParentTop 51 2386 #fixedParentBottom 1 410 ##(Smalltalk.StaticText) 34 16 nil 560 34 2 8 1140850945 65 2464 nil 480 nil 7 nil nil nil 2464 nil 8 1591672000 1682 nil nil nil 2050 138 144 34 2 2114 #createAt:extent: 34 2 1298 1 1 1298 585 51 2464 2114 #text: 34 1 8 'Package Groups' 2464 2274 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 36 1 0 0 25 0 0 0] 8 #() 2336 nil 27 2354 2400 1 2416 1 2432 1 2432 51 170 192 34 2 672 8 'packageGroupPresenter' nil 2050 138 144 34 1 2114 #createAt:extent: 34 2 1298 1 1 1298 585 673 560 2274 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 36 1 0 0 80 1 0 0] 34 2 2464 672 2336 nil 27 2354 2400 1 2386 #relativeParentWidth 327734 ##(Smalltalk.Float) 8 0 0 0 0 0 0 224 63 2432 1 2448 -49 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 3056 nil nil nil 7 nil nil nil 3056 498 170 176 34 4 410 ##(Smalltalk.ListView) 34 45 nil 3056 34 2 8 1140937033 1025 3168 738 138 144 784 nil 816 480 nil 15 834 nil true 34 5 882 1 914 #addPackage 8 'Add Package ...' 1 1 nil nil nil 882 1 914 #renamePackage 8 'Rename Package ...' 1 1 nil nil nil 1010 4097 882 1 914 #removePackageFromPackageGroup 8 'Remove Package From Package Group' 1 1 nil nil nil 882 1 914 #removePackages 8 'Remove Package from Project Definition' 1 1 nil nil nil 1088 nil 134217729 nil nil nil nil nil nil nil 3168 nil 8 1591759072 1122 0 nil 1154 1 83886081 1184 1232 1248 1779525917 3520 7 257 nil nil 1280 nil nil nil nil nil nil 138 144 34 1 1362 8 '' 577 #left ##(Smalltalk.BasicListAbstract) ##(Smalltalk.SortedCollection) nil nil 3168 nil 3 nil nil true 1122 0 nil 1154 3 1 1120 8 'doIt' 8 '[:packageService :newName | packageService halt; renameTo: newName]' 8 #[31 105 17 100 158 74 177 106] #halt #renameTo: 3616 7 513 nil 1570 nil nil 1600 3696 1618 nil false 1664 nil nil nil 5 nil nil nil 3696 nil nil 1682 nil 1712 1 nil nil nil nil nil nil nil nil nil #report 8 #() nil 131169 nil 1 nil nil 201 nil nil nil nil nil nil nil nil nil nil nil nil 2050 138 144 34 2 2114 #createAt:extent: 34 2 1298 1 51 1298 585 623 3168 2114 #contextMenu: 34 1 3264 3168 2274 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 25 0 0 0 36 1 0 0 80 1 0 0] 8 #() 2336 nil 35 2354 2400 1 2416 1 2432 51 2448 1 410 ##(Smalltalk.StaticText) 34 16 nil 3056 34 2 8 1140850945 65 3968 nil 480 nil 7 nil nil nil 3968 nil 8 1591672000 1682 nil nil nil 2050 138 144 34 2 2114 #createAt:extent: 34 2 1298 1 1 1298 585 51 3968 2114 #text: 34 1 8 'Packages
' 3968 2274 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 36 1 0 0 25 0 0 0] 8 #() 2336 nil 27 2354 2400 1 2416 1 2432 1 2386 #fixedViewTop 51 170 192 34 2 3168 8 'packageListPresenter' nil 2050 138 144 34 1 2114 #createAt:extent: 34 2 1298 585 1 1298 585 673 3056 2274 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 36 1 0 0 0 0 0 0 72 2 0 0 80 1 0 0] 34 2 3968 3168 2336 nil 27 2354 3008 3026 8 0 0 0 0 0 0 224 63 2416 1 2432 1 2448 -49 410 ##(Smalltalk.ContainerView) 34 15 nil 416 34 2 8 1140850688 131073 4544 nil nil nil 7 nil nil nil 4544 498 170 176 34 4 410 ##(Smalltalk.PushButton) 34 20 nil 4544 34 2 8 1149313024 1 4656 nil nil nil 7 nil nil nil 4656 nil 8 1591823792 914 #export 8 'Export' 1 1 nil nil false nil nil nil 2050 138 144 34 3 2114 #createAt:extent: 34 2 1298 655 1 1298 233 51 4656 2114 #isEnabled: 8 #(false) 4656 2114 #text: 34 1 8 'Export' 4656 2274 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 71 1 0 0 0 0 0 0 187 1 0 0 25 0 0 0] 8 #() 2336 nil 29 2354 3008 3026 8 236 81 184 30 133 235 225 63 3008 3026 8 82 184 30 133 235 81 232 63 2448 -49 2448 1 410 ##(Smalltalk.PushButton) 34 20 nil 4544 34 2 8 1149313024 1 5056 nil nil nil 7 nil nil nil 5056 nil 8 1591823792 914 #load 8 'Load' 1 1 nil nil false nil nil nil 2050 138 144 34 3 2114 #createAt:extent: 34 2 1298 233 1 1298 235 51 5056 2114 #isEnabled: 8 #(false) 5056 2114 #text: 34 1 8 'Load' 5056 2274 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 116 0 0 0 0 0 0 0 233 0 0 0 25 0 0 0] 8 #() 2336 nil 29 2354 3008 3026 8 154 153 153 153 153 153 201 63 3008 3026 8 154 153 153 153 153 153 217 63 2448 -49 2448 1 170 192 784 nil 2050 138 144 34 1 2114 #createAt:extent: 34 2 1298 1 673 1298 1169 51 4544 2274 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 80 1 0 0 72 2 0 0 105 1 0 0] 34 2 5056 4656 2336 nil 27 2354 2400 1 2416 1 2448 -49 2448 1 170 192 34 6 560 8 'Package Group Container View' 3056 8 'Packages Container View' 4544 8 'Buttons Container View' nil nil nil nil nil 1 nil nil nil nil 1 nil nil 2050 138 144 34 1 2114 #createAt:extent: 34 2 1298 6517 21 1298 1201 801 416 2274 8 #[44 0 0 0 0 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 186 12 0 0 10 0 0 0 18 15 0 0 154 1 0 0] 34 3 560 3056 4544 2336 nil 27)!

showOn: projectName session: aGciSession
	| editor |
	editor := self new gciSession: aGciSession.
	^editor editPackageGroups: projectName! !
!JadeitePackageGroupEditor class categoriesForMethods!
resource_Default_view!public!resources-views! !
showOn:session:!public! !
!

