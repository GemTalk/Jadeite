"RSR" 

[RsrConnection acceptOn: RsrSocketPair listenPort] fork.
(Delay forSeconds: 1) wait. 
1

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


