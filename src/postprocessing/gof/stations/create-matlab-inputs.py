#!/usr/bin/env python
############################################################################
#
# Script: create-matlab-inputs.py
#
# Description: Create Matlab input files from master station list
#
############################################################################

import os
import sys
import array
import getopt
import math
import random

class CreateMatlabInputs:
    def __init__(self, argv):
        self.argc = len(argv)
        self.argv = argv

    def usage(self):
        print "Usage: " + sys.argv[0] + " [-e #######] <station file>"
        print "Example: " + sys.argv[0] + " LH_stations.txt\n"
        print "\t[-h]                   : This help message"
        print "\t<stations file>        : Hercules station file"
        sys.exit(1)

    def main(self):
        # Parse options
        try:
            opts, args = getopt.getopt(self.argv[1:], "h", ["help"])
        except getopt.GetoptError, err:
            print str(err)
            self.usage()
            return(1)

        # Defaults
        evid = 15481673

        for o, a in opts:
            if o in ("-h", "--help"):
                self.usage()
                return(0)
            else:
                print "Invalid option %s" % (o)
                return(1)

        # Check command-line arguments
        if (len(args) != 1):
            self.usage()
            return(1)

        stafile = args[0]
        configfile = 'stations_observed.txt'

        # Read in Hercules station list
        print 'Reading Hercules station list'
        fp = open(stafile, 'r')
        sdata = fp.readlines()
        fp.close()

        # Write matlab scripts
        print 'Writing matlab configuration script %s' % (configfile)
        fp = open(configfile, 'w')
        for i in range(0, len(sdata)):
            stokens = sdata[i].split()
            netid = stokens[0]
            staid = stokens[1]
            if (netid == '#'):
                # Skip comment header
                continue
            fp.write('%s.%s.%s\n' % (netid, staid, 'BHN'))

        fp.close()

        configfile = 'stations_compare.txt'
        print 'Writing matlab configuration script %s' % (configfile)
        fp = open(configfile, 'w')
        offset = 0
        for i in range(0, len(sdata)):
            stokens = sdata[i].split()
            netid = stokens[0]
            staid = stokens[1]
            if (netid == '#'):
                # Skip comment header
                offset = offset + 1
                continue
            fp.write('%s%s %d\n' % (netid, staid, i - offset))

        fp.close()

        configfile = 'stations_score.txt'
        print 'Writing matlab configuration script %s' % (configfile)
        fp = open(configfile, 'w')
        offset = 0
        for i in range(0, len(sdata)):
            stokens = sdata[i].split()
            netid = stokens[0]
            staid = stokens[1]

            if (netid == '#'):
                # Skip comment header
                offset = offset + 1
                continue

            x = float(stokens[5])
            y = float(stokens[6])

            fp.write('%s%s %d %f %f\n' % (netid, staid, i - offset, x, y))

        fp.close()

        print "Done"
        return 0

if __name__ == '__main__':

    prog = CreateMatlabInputs(sys.argv)
    sys.exit(prog.main())
