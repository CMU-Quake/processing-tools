#!/bin/bash

for i in `seq 1 6`;
do
    OUTPUTDIR=./outputfiles_run$i

    # Change permissions
    chmod 664 $OUTPUTDIR/herc*
    chmod 664 $OUTPUTDIR/stat-*
    chmod 664 $OUTPUTDIR/monit*
    chmod 664 $OUTPUTDIR/planes/*
    chmod 664 $OUTPUTDIR/srctmp/*
    chmod 664 $OUTPUTDIR/stations/*
done
