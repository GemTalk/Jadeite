

Prepare for Rowan development: 
"attach to local Rowan git clone"
(Rowan projectNamed: 'Rowan') gitRepositoryRoot: '$ROWAN_PROJECTS_HOME/Rowan'.
"attach to local 3.6.0 git clone"
"(Rowan projectNamed: 'gemstoneBaseImage') gitRepositoryRoot: '$ARCHBASE/image'."
"trigger lazy inititialization ... need to incorporate into gitRepositoryRoot: implementation"
Rowan projects do: [:project | project existsOnDisk ].	
"reload Rowan and load Rowan tests"
[(Rowan projectNamed: 'Rowan') defined
	read: Rowan platformConditionalAttributes, #('tests' 'v2' 'v2Only' 'testsV2');
	load ] on: Warning do: [:ex | ex resume: true ]


RowanSample1Test new arbitraryCode   

arbitraryCode
	| fnoodle |
	fnoodle := UserGlobals
		at: #'iShouldNotBeHere'
		ifAbsent: [ 
			| def |
			def := Array with: 1 with: 2 with: 4.
			def
				do: [ :idx | 
					UserGlobals
						at: #'iShouldNotBeHere'
						ifAbsent: [ Transcript cr; show: idx printString ] ] ]



(RwSpecification fromUrl: 'file:$ROWAN_PROJECTS_HOME/Rowan/samples/RowanSample1_v2.ston') resolveStrict load.

(Rowan projectNamed: 'Rowan') gitRepositoryRoot: '$ROWAN_PROJECTS_HOME/Rowan'.
Rowan projects do: [:project | project existsOnDisk ].

"reload changing which packages are loaded"
[(Rowan projectNamed: 'Rowan') defined
	read: Rowan platformConditionalAttributes, #('tests' 'v2' 'v2Only' 'testsV2');
	load ] on: Warning do: [:ex | ex resume: true ]

"RSR" 

[RsrConnection acceptOn: 4321] fork.
(Delay forSeconds: 1) wait. 


======>>>>>>>
[| connection |
connection := RsrConnection acceptOn: 4321.
UserGlobals at: #connection put: connection. 
connection log addSink: RsrTranscriptSink new] fork


"RSR - close dead socket" 
GsSignalingSocket allInstancesInMemory do:[:ea | [ea port = RsrSocketPair listenPort ifTrue:[ea close]] on: Error do:[:ex | ]]

25 timesRepeat: [[(Delay forSeconds: 30) wait] fork].
(Delay forSeconds: 5) wait. "get em started"

"Read in an RwSpecification" 
RwSpecification fromUrl: 'file:/export//korea2/users/ewinger/shared/repos/Rowan/rowan/v2/proposed_specs/Rowan_proposed_2.ston'
(RwSpecification fromFile: '/export//korea2/users/ewinger/shared/repos/Rowan/rowan/configs/Kernel.ston')

(RwSpecification fromFile: '/export//korea2/users/ewinger/shared/repos/RowanSample9/specs/spec_0052.ston') resolve load
"Write out RwSimpleProjectSpecification"
self exportToUrl: 'file:/home/ewinger/temp/' as: 'test.ston'

"Attach my clone to Rowan"
 Rowan gemstoneTools image 
        newRepositoryRoot: '$ROWAN_PROJECTS_HOME/Rowan' 
        platformConditionalAttributes: Rowan platformConditionalAttributes, #('tests' 'v2' 'v2Only' 'testsV2')
        forProjectNamed: 'Rowan'

(Rowan projectNamed: 'Rowan') gitRepositoryRoot: '$ROWAN_PROJECTS_HOME/Rowan'


