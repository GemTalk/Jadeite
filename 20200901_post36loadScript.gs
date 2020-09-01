(Rowan projectNamed: 'Rowan') gitRepositoryRoot: '$ROWAN_PROJECTS_HOME/Rowan'.
"(Rowan projectNamed: 'gemstoneBaseImage') gitRepositoryRoot: '$ARCHBASE/image'."
"reload changing which packages are loaded"
[(Rowan projectNamed: 'Rowan') defined
	readProjectSet: Rowan platformConditionalAttributes, #('tests' 'v2' 'v2Only' 'testsV2' 'stubs' 'tonel');
	load ] on: Warning do: [:ex | ex resume: true ]