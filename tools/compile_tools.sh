#!/bin/bash

#########################################
######### Install Dependencies ##########
#########################################

tools_dir=$(dirname $0)
cd $tools_dir

install_world=true

# 1. Getting WORLD
if [ "$install_world" = true ]; then
    echo "compiling WORLD..."
    (
        cd WORLD;
        make
        make analysis synth
        make clean
    )
fi

WORLD_BIN_DIR=bin/WORLD

# 2. Copy binaries
echo "deleting downloaded tar files..."
rm -rf $tools_dir/*.tar.gz


mkdir -p bin
mkdir -p $WORLD_BIN_DIR

cp WORLD/build/analysis $WORLD_BIN_DIR/
cp WORLD/build/synth $WORLD_BIN_DIR/
if [[ ! -f ${WORLD_BIN_DIR}/analysis ]]; then
    echo "Error installing WORLD tools"
    exit 1
else
    echo "All tools successfully compiled!!"
fi
