#! /bin/bash

# Regenerates the Rowan bootstrap .gs files from the tonel files.

if [ "$GEMSTONE" = "" ]; then
  echo "GEMSTONE must be defined"
  exit 1
fi
if [ "$ROWAN_PROJECTS_HOME" = "" ]; then
  echo "ROWAN_PROJECTS_HOME must be defined"
  exit 1
else
  echo "using ROWAN_PROJECTS_HOME=$ROWAN_PROJECTS_HOME"
fi

$GEMSTONE/bin/topaz -l -C"GEM_SOLO_EXTENT=$GEMSTONE/../hidden/bin/extent0.rowan.dbf" -S $ROWAN_PROJECTS_HOME/Rowan/platforms/gemstone/topaz/read_and_write_rowan_source.tpz
if [ $? != 0 ]; then 
  echo "ERRORs from topaz"
  exit 1
fi

