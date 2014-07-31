#!/bin/bash
##########################################################################
#
# Script: scale-sources-lahabra.sh
#
# Description: Construct La Habra scaled slips
#
##########################################################################

# Scale point source 134/55/155
echo ""
echo "Point source 1 scaling"
echo ""
./scale-point-source.py -w 5.12 -z 2.166486E+10

# Scale point source 239/70/38
echo ""
echo "Point source 2 scaling"
echo ""
./scale-point-source.py -w 5.12 -z 2.174612e+10

# Scale extended source
echo ""
echo "Extended source scaling"
echo ""
./scale-extended-source.py -w 5.12 -z 4.820099e+16 ./lahabra/area.in ./lahabra/slip.in ./lahabra/slip.in.scaled
