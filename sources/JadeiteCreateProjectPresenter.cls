"Filed out from Dolphin Smallalk"!

JadePresenterA subclass: #JadeiteCreateProjectPresenter
	instanceVariableNames: 'defaultPropertyList propertyList'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteCreateProjectPresenter guid: (GUID fromString: '{63d27b7b-cfe9-4397-b51b-0387134f89a0}')!
JadeiteCreateProjectPresenter comment: ''!
!JadeiteCreateProjectPresenter categoriesForClass!Unclassified! !
!JadeiteCreateProjectPresenter methodsFor!

atProperty: property
	^(propertyList detect: [:propertyArray | propertyArray first = property]) last!

createComponents
	super createComponents.
	defaultPropertyList := self add: ListPresenter new name: 'propertyList'!

createProject
	| service browserService projectNames projectName shell newService |
	browserService := RowanBrowserService new command: #updateProjects.
	self issueCommand: browserService.
	projectNames := browserService projects collect: [:projectService | projectService name].
	projectName := self atProperty: 'projectName'.
	(projectNames includes: projectName)
		ifTrue: 
			[MessageBox notify: 'Project name already exists'.
			^false].
	service := RowanProjectService new name: projectName.
	service command: #createProjectComponent:symDict:convention:format:projectsHome:type:.
	service
		commandArgs: (OrderedCollection new
				add: (self atProperty: 'componentName');
				add: (self atProperty: 'defaultSymbolDictName');
				add: (self atProperty: 'packageConvention');
				add: (self atProperty: 'packageFormat');
				add: (self atProperty: 'projectsHome');
				add: (self atProperty: 'repositoryType');
				yourself) asArray.
	self issueCommand: service.
	shell := JadeiteBrowser showOnSession: gciSession.
	newService := shell currentCard projectListPresenter list
				detect: [:projectService | projectService name = projectName]
				ifNone: [^true].
	shell currentCard projectListPresenter selection: newService.
	^true!

initializeValues
	propertyList := self class defaults copy.
	defaultPropertyList list: propertyList!

propertiesAreChanged
	^(self class defaults = propertyList) not! !
!JadeiteCreateProjectPresenter categoriesForMethods!
atProperty:!private! !
createComponents!initialization!public! !
createProject!menu handlers!public! !
initializeValues!initialization!menu handlers!public! !
propertiesAreChanged!public!testing! !
!

!JadeiteCreateProjectPresenter class methodsFor!

defaults
	| properties |
	properties := OrderedCollection new.
	properties
		add: (Array with: 'projectName' with: String new); 
		add: (Array with: 'componentName' with: 'Core');
		add: (Array with: 'defaultSymbolDictName' with: 'Globals');
		add: (Array with: 'packageConvention' with: 'RowanHybrid');
		add: (Array with: 'packageFormat' with: 'tonel');
		add: (Array with: 'projectsHome' with: '$ROWAN_PROJECTS_HOME');
		add: (Array with: 'repositoryType' with: 'git').
	^properties! !
!JadeiteCreateProjectPresenter class categoriesForMethods!
defaults!public! !
!

