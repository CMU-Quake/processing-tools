#!/bin/bash
##########################################################################
#
# Script: reformat_ch
#
# Description: Pull out required fields from Ricardo's master station list
#
##########################################################################

cut -f2,3,6,7 clean-stations.txt > CH_stations.list
