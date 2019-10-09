"Filed out from Dolphin Smalltalk 7"!

Semaphore subclass: #JadeiteSemaphore
	instanceVariableNames: 'lockingProcess'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
JadeiteSemaphore guid: (GUID fromString: '{bee6b8be-8e92-4b1e-b1c1-9a35fa6d9cf8}')!
JadeiteSemaphore comment: ''!
!JadeiteSemaphore categoriesForClass!Kernel-Processes! !
!JadeiteSemaphore methodsFor!

critical: aBlock
	lockingProcess := Processor activeProcess.
	[aBlock value] ensure: [lockingProcess := nil]!

lockingProcess
	"Private - for testing"

	^lockingProcess! !
!JadeiteSemaphore categoriesFor: #critical:!process synchronisation!public! !
!JadeiteSemaphore categoriesFor: #lockingProcess!accessing!private! !

