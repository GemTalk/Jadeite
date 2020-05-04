| projectRoot filePath gitTool  projects specName |
specName := 'spec_0052'.	"name of RowanSample9 example to load"
gitTool := Rowan projectTools git.
"Asume that RowanSample9 proejct has been pre-cloned into $ROWAN_PROJECTS_HOME dir"
projectRoot := '$ROWAN_PROJECTS_HOME/RowanSample9' asFileReference.
"Assume that we don't know what branch RowanSample9 is on, so
	checkout the master branch"
gitTool gitcheckoutIn: projectRoot with: 'master'.
"We know that on the master branch, the specs directory has s spec for each of the 
	project branches and we want to load spec_0052"
filePath :=  projectRoot / 'specs' / specName, 'ston'.
projects := (RwSpecification fromFile: filePath) 
	resolveStrict	"use resolveStrict, because we want to checkout the branch 
							specified in the spec" 
	loadProjectSet.	"use loadProjectSet so that required projects get loaded 
							--- this should be used by default to load projects"
"if you inspect the result you will see an RwProject instance for each loaded
	project:
		anArray( aRwProject for RowanSample9, aRwProject for RowanSample9_embedded_1)
From the project list you can determine which projects need to be refreshed in the 
	project list"