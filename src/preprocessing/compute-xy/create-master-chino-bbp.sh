#!/bin/bash
##########################################################################
#
# Script: create-master-chino-bbp.sh
#
# Description: Construct Chino BBP master station list
#
##########################################################################

mkdir -p chino_bbp

# Remove first few headerlines from BB-formatted station list
sed '1,2d' ./chino_bbp_input_stations/BB_chino.list > ./chino_bbp/BB_chino.tmp

# Get required fields
awk '{print "BB", $3, $1, $2}' ./chino_bbp/BB_chino.tmp > ./chino_bbp/BB_chino.tmp2

# Compute xy locations
./compute-xy.py ./chino_bbp/BB_chino.tmp2 > ./chino_bbp/BB_chino_xy.list

# Remove temporary files
rm ./chino_bbp/BB_chino.tmp
rm ./chino_bbp/BB_chino.tmp2

# Bounds check the coordinates
./create-master.py ./chino_bbp/BB_chino_xy.list > ./chino_bbp/CH_stations.txt

# Convert to Hercules parameters.in format
cut -f3,4,5 ./chino_bbp/CH_stations.txt | awk '{print $2, $1, $3}' > ./chino_bbp/CH_stations_parameters.in
sed -i '1,1d' ./chino_bbp/CH_stations_parameters.in
