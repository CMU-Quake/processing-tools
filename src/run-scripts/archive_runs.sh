#!/bin/bash

# Simulation name and number of runs
SIMNAME=$1
NUMRUN=$2

cd ..

INPUTFILE="${SIMNAME}_inputs.tar.gz"
echo "Archiving simulation input files into $INPUTFILE"
tar zcvf $INPUTFILE ./$SIMNAME/inputfiles ./$SIMNAME/*.pbs ./$SIMNAME/*.sh


for i in `seq 1 ${NUMRUN}`;
do
    OUTPUTFILE="${SIMNAME}_run${i}_outputs_stations.tar.gz"
    echo "Archiving simulation station files and logs into $OUTPUTFILE"
    tar zcvf $OUTPUTFILE ./$SIMNAME/outputfiles_run$i/stations  ./$SIMNAME/outputfiles_run$i/*.txt ./$SIMNAME/outputfiles_run$i/*.o*

    OUTPUTFILE="${SIMNAME}_run${i}_outputs_planes.tar"
    echo "Archiving simulation planes into $OUTPUTFILE"
    tar cvf $OUTPUTFILE ./$SIMNAME/outputfiles_run$i/planes
done

cd $SIMNAME
