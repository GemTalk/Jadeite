"Filed out from Dolphin Smallalk"!

Notification subclass: #ShortcutMenuStatus
	instanceVariableNames: ''
	classVariableNames: 'Status'
	poolDictionaries: ''
	classInstanceVariableNames: ''!
ShortcutMenuStatus guid: (GUID fromString: '{141b492e-356c-4349-ac57-28d52e5c564b}')!
ShortcutMenuStatus comment: ''!
!ShortcutMenuStatus categoriesForClass!Kernel-Exception Handling! !
!ShortcutMenuStatus methodsFor!

defaultAction

	Status := tag.
! !
!ShortcutMenuStatus categoriesForMethods!
defaultAction!public! !
!

!ShortcutMenuStatus class methodsFor!

isClosed

	^Status = #'stop'!

isOpen

	^Status = #'start'!

reset

	self signalWith: nil.
!

start

	self signalWith: #'start'.
!

status

	^Status
!

stop

	self signalWith: #'stop'.
! !
!ShortcutMenuStatus class categoriesForMethods!
isClosed!public! !
isOpen!public! !
reset!public! !
start!public! !
status!public! !
stop!public! !
!

