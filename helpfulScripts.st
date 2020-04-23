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

"server side" 
25 timesRepeat: [[(Delay forSeconds: 30) wait] fork].
(Delay forSeconds: 5) wait. "get em started"