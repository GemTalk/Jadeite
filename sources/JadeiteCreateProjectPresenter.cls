"Filed out from Dolphin Smallalk"!

JadePresenterA subclass: #JadeiteCreateProjectPresenter
	instanceVariableNames: 'propertyList initialPropertyList browser'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteCreateProjectPresenter guid: (GUID fromString: '{63d27b7b-cfe9-4397-b51b-0387134f89a0}')!
JadeiteCreateProjectPresenter comment: ''!
!JadeiteCreateProjectPresenter categoriesForClass!Unclassified! !
!JadeiteCreateProjectPresenter methodsFor!

atProperty: property
	^(initialPropertyList detect: [:propertyArray | propertyArray first = property]) last!

browser
	^browser!

createComponents
	super createComponents.
	propertyList := self add: ListPresenter new name: 'propertyList'!

createProject
	| service browserService projectNames projectName shell newService |
	browserService := RowanBrowserService new command: #updateProjects.
	self issueCommand: browserService.
	projectNames := browserService projects collect: [:projectService | projectService name].
	projectName := self atProperty: 'projectName'.
	projectName isEmpty
		ifTrue: 
			[MessageBox notify: 'Project name cannot be blank'.
			^false].
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
	browser := JadeiteBrowser showOnSession: gciSession.
	newService := browser currentCard projectListPresenter list
				detect: [:projectService | projectService name = projectName]
				ifNone: 
					[MessageBox notify: 'Project possibly not created'.
					^true	"something went wrong but close the create project editor anyway as it may just be a display problem"].
	browser currentCard projectListPresenter selection: newService.
	^true!

initializeValues
	initialPropertyList := self class defaults copy.
	propertyList list: initialPropertyList!

propertiesAreChanged
	^(self class defaults = initialPropertyList) not!

propertyList
	^propertyList!

propertyList: anObject
	propertyList := anObject! !
!JadeiteCreateProjectPresenter categoriesForMethods!
atProperty:!private! !
browser!accessing!private! !
createComponents!initialization!public! !
createProject!menu handlers!public! !
initializeValues!initialization!menu handlers!public! !
propertiesAreChanged!public!testing! !
propertyList!accessing!private! !
propertyList:!accessing!private! !
!

!JadeiteCreateProjectPresenter class methodsFor!

defaults
	| properties |
	properties := OrderedCollection new.
	properties
		add: (Array with: 'projectName' with: String new); 
		add: (Array with: 'componentName' with: 'Core');
		add: (Array with: 'defaultSymbolDictName' with: 'UserGlobals');
		add: (Array with: 'packageConvention' with: 'RowanHybrid');
		add: (Array with: 'packageFormat' with: 'tonel');
		add: (Array with: 'projectsHome' with: '$ROWAN_PROJECTS_HOME');
		add: (Array with: 'repositoryType' with: 'git').
	^properties! !
!JadeiteCreateProjectPresenter class categoriesForMethods!
defaults!public! !
!

