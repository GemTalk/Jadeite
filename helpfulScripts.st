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

[GciSession current executeString: '(Delay forSeconds: 20) wait'. ] fork

"RSR"
| connection service  |
connection := RsrConnection connectTo: RsrSocketPair listenPort on: 'owl'.
service := connection serviceFor: #RowanAnsweringService.
service rsrCommand: #isTranscriptInstalled.
service

| connection service  |
connection := RsrConnection connectTo: RsrSocketPair listenPort on: 'owl'.
service := connection serviceFor: #RowanClassService.
service name: 'Array'. 
service comment: 'this is a comment'. 
service rsrCommand: #update.
service


| connection service |
connection := RsrConnection connectTo: RsrSocketPair listenPort on: 'owl'.
service := connection serviceFor: #RsrClientNoInstVars.


