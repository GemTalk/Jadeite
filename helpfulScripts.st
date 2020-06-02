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

"2"
[GciSession current executeString: '(Delay forSeconds: 1) wait'] fork.

"3"
| connection | 
connection := RsrConnection connectTo: 4322 on: 'owl'.
service := connection serviceFor: #RowanClassService.
service name: 'Array'. 
service rsrCommand: #update.
service inspect.

--------

| connection service |
connection := RsrConnection connectTo: RsrSocketPair listenPort on: 'owl'.
service := connection serviceFor: #RsrClientNoInstVars.


