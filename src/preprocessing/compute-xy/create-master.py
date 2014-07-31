#!/usr/bin/env python
############################################################################
#
# Script: create-master.py
#
# Description: Compute BB and CH station lists into one master list
#
############################################################################

import os
import sys
import array
import getopt
import math
import random

# Domain side length
DOMAINLENGTHETA = 180e3
DOMAINLENGTHCSI = 135e3

# Location tolerance
TOL = 1e-3

class CreateMaster:
    def __init__(self, argv):
        self.argc = len(argv)
        self.argv = argv

    def usage(self):
        print "Usage: " + sys.argv[0] + " <station file1> [station file2]"
        print "Example: " + sys.argv[0] + " -m BB_station_xy.list CH_station_xy.list\n"
        print "Example: " + sys.argv[0] + " BB_station_xy\n"
        print "\t[-h]                   : This help message"
        print "\t[-m]                   : Perform merge"
        print "\t<stations file1>        : Station list 1"
        print "\t<stations file2>        : Station list 2 (Optional, used in merge)"
        sys.exit(1)

    def main(self):
        # Parse options
        try:
            opts, args = getopt.getopt(self.argv[1:], "hm", ["help", "merge"])
        except getopt.GetoptError, err:
            print str(err)
            self.usage()
            return(1)

        # Defaults
        domerge = False
        for o, a in opts:
            if o in ("-h", "--help"):
                self.usage()
                return(0)
            elif o in ("-m", "--merge"):
                domerge = True
            else:
                print "Invalid option %s" % (o)
                return(1)

        # Check command-line arguments
        if ((domerge == True and len(args) != 2) or 
            (domerge == False and len(args) != 1)):
            self.usage()
            return(1)

        sfile1 = args[0]
        if (domerge):
            sfile2 = args[1]

        #print "Reading in station list %s" % (sfile1)
        fp = open(sfile1, 'r')
        sdata1 = fp.readlines()
        fp.close()

        if (domerge):
            #print "Reading in station list %s" % (sfile2)
            fp = open(sfile2, 'r')
            sdata2 = fp.readlines()
            fp.close()

        master = []
        
        # Preferred stations that must be included if they fit in sim box
        #print "Merging station lists:"
        for i in range(0, len(sdata1)):
            stokens = sdata1[i].split()
            snet1 = stokens[0]
            ssta1 = stokens[1]
            slon1 = float(stokens[2])
            slat1 = float(stokens[3])
            sx1 = float(stokens[4])
            sy1 = float(stokens[5])
            if ((sx1 >= 0.0) and (sx1 < DOMAINLENGTHETA) and (sy1 >= 0.0) and (sy1 < DOMAINLENGTHCSI)):
                master.append([snet1, ssta1, slon1, slat1, sx1, sy1]);
            #else:
            #    print('Station %s %s is outside of sim box (%f, %f)\n' % (snet1, ssta1, sx1, sy1));

        if (domerge):
            # Additional stations with possible duplicates that must be filtered
            master2 = []
            for i in range(0, len(sdata2)):
                stokens = sdata2[i].split()
                snet2 = stokens[0]
                ssta2 = stokens[1]
                slon2 = float(stokens[2])
                slat2 = float(stokens[3])
                sx2 = float(stokens[4])
                sy2 = float(stokens[5])
                # Find in master list
                found = False
                for m in range(0, len(master)):
                    mtokens = master[m]
                    mnet = mtokens[0]
                    msta = mtokens[1]
                    mlon = float(mtokens[2])
                    mlat = float(mtokens[3])
                    mx = float(mtokens[4])
                    my = float(mtokens[5])
                    if ((math.fabs(slon2 - mlon) < TOL) and 
                        ((math.fabs(slat2 - mlat) < TOL))):
                        #sys.stdout.write("%s %s duplicate of %s %s\n" % (snet2, ssta2, mnet, msta))
                        found = True
                        break;

                # Append to new list to allow dupes in CH list
                if (not found):
                    master2.append([snet2, ssta2, slon2, slat2, sx2, sy2]);

            # Merge the two lists
            master = master + master2

        # Output merged list
        sys.stdout.write("# net sta lon lat x y sta_id\n")
        staid = 0
        for m in range(0, len(master)):
            mtokens = master[m]
            mnet = mtokens[0]
            msta = mtokens[1]
            mlon = float(mtokens[2])
            mlat = float(mtokens[3])
            mx = float(mtokens[4])
            my = float(mtokens[5])
            stafile = "station.%d" % (staid)
            sys.stdout.write("%5s\t%10s\t%14.6f\t%14.6f\t%14.6f\t%14.6f\t%14.6f\t%12s\n" % (mnet, msta, mlon, mlat, 0.0, mx, my, stafile))
            staid = staid + 1

        #print "Done"
        return 0

if __name__ == '__main__':

    prog = CreateMaster(sys.argv)
    sys.exit(prog.main())
