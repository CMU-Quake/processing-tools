#!/bin/bash
##########################################################################
#
# Script: scale-sources-chino-bbp.sh
#
# Description: Construct Chino BBP scaled slips
#
##########################################################################

# Scale extended source
#echo ""
#echo "Extended source scaling run 1"
#echo ""
./scale-extended-source.py -w 5.4 -z 1.253211e+17 ./chino_bbp_run1/area.in ./chino_bbp_run1/slip.in ./chino_bbp_run1/slip.in.scaled

echo ""
echo "Extended source scaling run 2"
echo ""
./scale-extended-source.py -w 5.4 -z 1.360800e+17 ./chino_bbp_run2/area.in ./chino_bbp_run2/slip.in ./chino_bbp_run2/slip.in.scaled
