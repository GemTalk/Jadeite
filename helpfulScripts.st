"In lieu of conditional breakpoints in Dolphin, use this to stop only once. 
Good for debugging menus, etc" 

"client side" 

(Smalltalk at: #stopOnce ifAbsent:[false[)
		ifTrue: 
			["Smalltalk at: #stopOnce put: true"
			Smalltalk at: #stopOnce put: false.
			self halt].

BrowserUpdate clearCurrent

GciSession current: nil

JadeiteCommandShell showOnSession: GciSession current



"RSR"
| connection   |
[GciSession current executeString: '(Delay forSeconds: 1) wait'. ] fork.
connection := RsrConnection connectTo: 4321 on: 'owl'.
Smalltalk at: #connection put: connection. 
[[connection isOpen]
  whileTrue:
    [GciSession current executeString: '(Delay forSeconds: 1) wait'.
    (Delay forSeconds: 1) wait]] fork

[GciSession current executeString: '(Delay forSeconds: 1) wait'. ] fork

[GciSession current executeString: '| connection |
connection := RsrConnection acceptOn: 4321.
connection log addSink: RsrTranscriptSink new.
connection waitUntilClose'] fork.

[GciSession current executeString: '| connection |
connection := RsrConnection acceptOn: 4321.
UserGlobals at: #connection put: connection. 
connection log addSink: RsrTranscriptSink new.'] fork. 

[[connection isOpen]
  whileTrue:
    [GciSession current executeString: '(Delay forSeconds: 1) wait'.
    (Delay forSeconds: 1) wait] fork.

---------

"1"
[GciSession current executeString: '| connection |
connection := RsrConnection acceptOn: 4321.
connection log addSink: RsrTranscriptSink new'] fork.

"1a"
| connection | 
connection := RsrConnection connectToHost: 'owl' port: 4322.
connection log addSink: RsrTranscriptSink new.
Smalltalk at: #rsrConnection put: connection. 

"2"
[GciSession current executeString: '(Delay forSeconds: 1) wait'] fork.

"3"

service := (Smalltalk at: #rsrConnection) serviceFor: #RowanClassService.
service name: 'Array'. 
service rsrCommand: #update.
service inspect.

--------

| connection service |
connection := RsrConnection connectTo: RsrSocketPair listenPort on: 'owl'.
service := connection serviceFor: #RsrClientNoInstVars.

------

Smalltalk at: #jadeiteInstVarClasses put: Dictionary new. 
"print service classes"
RowanService>>postUpdate
	"Give the service a chance to clean up unnecessary objects after replication"

	self class instVarNames do: 
			[:instVarName |
			| theClass |
			theClass := (self instVarNamed: instVarName) class.
			((Smalltalk at: #jadeiteInstVarClasses) keys includes: theClass)
				ifFalse: 
					[(Smalltalk at: #jadeiteInstVarClasses) at: theClass
						put: (Array with: self class name with: instVarName).
					Transcript
						cr;
						tab;
						show: self class name , ' | ';
						show: instVarName , ': ';
						print: (self instVarNamed: instVarName) class.
					Transcript flush]]

"sample output: RowanAnsweringService | answer: Utf8String
	RowanAutoCommitService | autoCommit: True
	RowanAutoCommitService | postUpdateBlock: UndefinedObject
	RowanProjectService | isSkew: False
	RowanProjectService | packages: Array
	RowanProjectService | projectOop: SmallInteger
	RowanBrowserService | projects: OrderedCollection
	RowanMethodService | selector: Symbol
	RowanClassService | hierarchyServices: Dictionary
	RowanInspectorService | myself: Association
	RowanProjectService | sha: AnsiString

	RowanProjectService | sha: Utf8String
	RowanProjectService | isSkew: False
	RowanProjectService | packages: Array
	RowanProjectService | changes: UndefinedObject
	RowanProjectService | existsOnDisk: True
	RowanProjectService | projectOop: SmallInteger
	RowanBrowserService | projects: OrderedCollection
	RowanMethodService | selector: Symbol
	RowanPackageService | selectedClass: RowanClassService
	RowanAnsweringService | answer: Association
	RowanClassService | hierarchyServices: Dictionary
"