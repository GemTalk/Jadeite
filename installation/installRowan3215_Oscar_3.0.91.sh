#!/bin/sh

#set -x
set -e

. gshere
stopnetldi $2
startnetldi $2 -ga ewinger

(
$GEMSTONE/bin/topaz -il <<EOF
status
#login linked to put gcilogServer: output in MFC.out
set gemstone $1  

input $ROWAN_PROJECTS_HOME/Rowan/platforms/gemstone/topaz/3.2.15/installRowan 
errorCount
exit
EOF
) >> MFC.out

