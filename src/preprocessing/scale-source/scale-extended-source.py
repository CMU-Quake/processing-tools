#!/usr/bin/env python
############################################################################
#
# Script: scale-extended-source.py
#
# Description: Scales an extended source to match desired Mw
#
############################################################################

import os
import sys
import array
import getopt
import math
import random



class ScaleExtendedSource:
    def __init__(self, argv):
        self.argc = len(argv)
        self.argv = argv

    def usage(self):
        print "Usage: " + sys.argv[0] + " <area.in> <slip.in> <outfile>"
        print "Example: " + sys.argv[0] + " area.in slip.in slip.in.scaled\n"
        print "\t[-h]                   : This help message"
        print "\t[-w]                   : Target Mw"
        print "\t[-z]                   : Dummy M0 with area=slip=1.0"
        print "\t<area.in>              : Hercules area.in"
        print "\t<slip.in>              : Hercules slip.in"
        print "\t<outfile>              : Scaled slip file"
        sys.exit(1)

    def main(self):
        # Parse options
        try:
            opts, args = getopt.getopt(self.argv[1:], "hw:z:", ["help", "Mw", "M0"])
        except getopt.GetoptError, err:
            print str(err)
            self.usage()
            return(1)

        # Defaults
        M0 = 1.0
        Mw = 1.0
        for o, a in opts:
            if o in ("-h", "--help"):
                self.usage()
                return(0)
            elif o in ("-w", "--Mw"):
                Mw = float(a)
            elif o in ("-z", "--M0"):
                M0 = float(a)
            else:
                print "Invalid option %s" % (o)
                return(1)

        # Check command-line arguments
        if (len(args) != 3):
            self.usage()
            return(1)

        afile = args[0]
        sfile = args[1]
        outfile = args[2]

        print "Configuration:"
        print "\tDummy M0 = %e" % (M0)
        print "\tTarget Mw = %e" % (Mw)
        print "\tArea file = %s" % (afile)
        print "\tSlip file = %s" % (sfile)

        print "\nReading in area file %s" % (afile)
        fp = open(afile, 'r')
        adata = fp.readlines()
        fp.close()

        print "Reading in slip file %s" % (sfile)
        fp = open(sfile, 'r')
        sdata = fp.readlines()
        fp.close()

        if (len(adata) != len(sdata)):
            print "Area and slip file lengths are unequal!"
            return(1);

        print "Computing slip scaling factor"            
        targetM0 = math.pow(10, 1.5*(Mw + 10.73)) / (1.0e7)
        scalefactor = targetM0/M0

        print "Calculated scale factor: %f" % (scalefactor)

        print "Scaling slips and saving in %s" % (outfile)
        fp = open(outfile, 'w')
        for slip in sdata:
            try:
                fp.write("%e\n" % (scalefactor*float(slip)))
            except ValueError:
                continue;
        fp.close()

        print "Done"
        return 0

if __name__ == '__main__':

    prog = ScaleExtendedSource(sys.argv)
    sys.exit(prog.main())
