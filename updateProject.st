updateProject
	| selection |
	selection := self projectListPresenter selectionIfNone: [^self].
	self projectListPresenter selection name = '(NONE)'
		ifTrue: 
			[self showDictionaryList.
			self updateTabLabel.
			self updateProjectInfo]
		ifFalse: 
			[self showPackageList.
			super updateProject]