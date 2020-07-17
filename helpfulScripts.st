JadeiteDebugger allInstances do:[:debugger | debugger debuggerProcess ifNotNil:[:proc | proc terminate]. debugger debuggerProcess: nil]

JadeiteDebugger allInstances first 
JadeiteDebugger allInstances size

SessionManager current inputState windows size "old 583"  
SessionManager current inputState purgeDeadWindows
SessionManager current inputState main
BrowserUpdate clearCurrent
SessionManager current inputState windows collect:[:ea | (ea class canUnderstand: #presenter) ifTrue:[ea presenter topShell] ifFalse:[]]

Process allInstances
JadeiteDebugger debuggers

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

	Smalltalk at: #jadeiteInstVarClasses
		put: (SortedCollection sortBlock: 
					[:x :y |
					x first = y first
						ifTrue: [x second = y second ifTrue: [x third <= y third] ifFalse: [x second <= y second]]
						ifFalse: [x first <= y first]])

"print service instVar classes"
postUpdate
	"Give the service a chance to clean up unnecessary objects after replication"

	self class instVarNames do: 
			[:instVarName |
			| theClass theService existing |
			theClass := (self instVarNamed: instVarName) class.
			theService := self class.
			existing := (Smalltalk at: #jadeiteInstVarClasses) detect: 
							[:triplet |
							(triplet at: 1) = theClass and: [(triplet at: 2) = theService and: [(triplet at: 3) = instVarName]]]
						ifNone: [].
			existing
				ifNil: 
					[(Smalltalk at: #jadeiteInstVarClasses) add: (Array
								with: theClass
								with: theService
								with: instVarName)]]

| count lastClass countStream |
	count := 0.
	countStream := WriteStream on: String new.
	(Smalltalk at: #jadeiteInstVarClasses) do: 
			[:triplet |
			| theClass theService theInstVarName |
			theClass := triplet at: 1.
			theService := triplet at: 2.
			theInstVarName := triplet at: 3.
			lastClass
				ifNotNil: 
					[lastClass ~= theClass
						ifTrue: 
							[countStream
								cr;
								tab;
								tab;
								nextPutAll: lastClass name , ' count: ';
								print: count.
							count := 0]].
			lastClass := theClass.
			count := count + 1.
			Transcript
				cr;
				tab;
				show: theClass name , ' | ';
				show: theService name , ' | ';
				print: theInstVarName.
			Transcript flush].
	countStream
		cr;
		tab;
		tab;
		nextPutAll: lastClass name , ' count: ';
		print: count.
	Transcript
		cr;
		cr;
		show: 'Totals:';
		cr;
		show: countStream contents
	

""