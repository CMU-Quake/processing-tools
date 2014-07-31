#!/bin/bash
##########################################################################
#
# Script: create-master-lahabra.sh
#
# Description: Construct La Habra master station list
#
##########################################################################

mkdir -p lahabra

# Copy Ricardo's station list, remove first few lines from spreadsheet, 
# and get required fields
cut -f2,3,6,7 ./lahabra_input_stations/clean-stations.txt > ./lahabra/CH_stations.list
sed -i '1,5d' ./lahabra/CH_stations.list

# Copy En-Jui's station list
cp ./lahabra_input_stations/BB_stations.list ./lahabra

# Copy EQ origin location
cp ./lahabra_input_stations/EQ_lahabra.list ./lahabra

# Compute xy locations
./compute-xy.py ./lahabra/BB_stations.list > ./lahabra/BB_stations_xy.list
./compute-xy.py ./lahabra/CH_stations.list > ./lahabra/CH_stations_xy.list
./compute-xy.py ./lahabra/EQ_lahabra.list > ./lahabra/EQ_lahabra_xy.list

# Merge (-m) the two station lists
./create-master.py -m ./lahabra/BB_stations_xy.list ./lahabra/CH_stations_xy.list > ./lahabra/LH_stations.txt

# Convert to Hercules parameters.in format
cut -f3,4,5 ./lahabra/LH_stations.txt | awk '{print $2, $1, $3}' > ./lahabra/LH_stations_parameters.in
sed -i '1,1d' ./lahabra/LH_stations_parameters.in
