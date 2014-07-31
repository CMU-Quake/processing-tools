#!/bin/bash

for i in `seq 1 6`;
do
    OUTPUTDIR=./outputfiles_run$i

    # Delete existing output directory
    rm -rf $OUTPUTDIR

    # Create new output directory structure
    mkdir $OUTPUTDIR
    mkdir $OUTPUTDIR/planes
    mkdir $OUTPUTDIR/stations
    mkdir $OUTPUTDIR/srctmp
done
