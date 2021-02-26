"Filed out from Dolphin Smalltalk 7"!

Semaphore subclass: #RowanSemaphore
	instanceVariableNames: 'lockingProcess'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RowanSemaphore guid: (GUID fromString: '{bee6b8be-8e92-4b1e-b1c1-9a35fa6d9cf8}')!
RowanSemaphore comment: ''!
!RowanSemaphore categoriesForClass!Kernel-Processes! !
!RowanSemaphore methodsFor!

critical: aBlock
	lockingProcess := Processor activeProcess.
	[aBlock value] ensure: [lockingProcess := nil]!

lockingProcess
	"Private - for testing"

	^lockingProcess! !
!RowanSemaphore categoriesFor: #critical:!process synchronisation!public! !
!RowanSemaphore categoriesFor: #lockingProcess!accessing!private! !

