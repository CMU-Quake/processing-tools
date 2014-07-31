#!/usr/bin/env python
############################################################################
#
# Script: compute-buftime.py
#
# Description: Examines slipfunction.in to compute BUFTIME value
#
############################################################################

import os
import sys
import array
import getopt
import math
import random

class ComputeBufTime:
    def __init__(self, argv):
        self.argc = len(argv)
        self.argv = argv

    def usage(self):
        print "Usage: " + sys.argv[0] + " <slip function>"
        print "Example: " + sys.argv[0] + " slipfunction.in\n"
        print "\t[-h]                   : This help message"
        print "\t<slip function>        : Slip function file"
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

        slipfile = args[0]

        # Read in Hercules station list
        print 'Reading slip function file %s' % (slipfile)
        fp = open(slipfile, 'r')
        sdata = fp.readlines()
        fp.close()

        t1 = 10000.0
        t2 = 0.0
        
        t1line = 0
        t2line = 0

        # Calculate buftime
        for i in range(0, len(sdata)):
            stokens = sdata[i].split()
            if (len(stokens) == 0):
                continue
            numsamp = int(stokens[0])
            delay = float(stokens[1])
            dt = float(stokens[2])

            endtime = delay + numsamp*dt

            if (delay < t1):
                t1 = delay
                t1line = i
            if (endtime > t2):
                t2 = endtime
                t2line = i

        print "t1 = %f, line %d" % (t1, t1line+1)
        print "t2 = %f, line %d" % (t2, t2line+1)
        print "BUFTIME = %f" % (t1 + (t2-t1)/2.0)

        print "Done"
        return 0

if __name__ == '__main__':

    prog = ComputeBufTime(sys.argv)
    sys.exit(prog.main())
