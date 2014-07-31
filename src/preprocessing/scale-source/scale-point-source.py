#!/usr/bin/env python
############################################################################
#
# Script: scale-point-source.py
#
# Description: Scales a point source to match desired Mw
#
############################################################################

import os
import sys
import array
import getopt
import math
import random



class ScalePointSource:
    def __init__(self, argv):
        self.argc = len(argv)
        self.argv = argv

    def usage(self):
        print "Usage: " + sys.argv[0] + " [-w Mw] [-z M0]"
        print "Example: " + sys.argv[0] + " -w 5.12 -z 2.166486E+10\n"
        print "\t[-h]                   : This help message"
        print "\t[-w]                   : Target Mw"
        print "\t[-z]                   : Dummy M0 with area=slip=1.0"
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
        if (len(args) != 0):
            self.usage()
            return(1)

        print "Configuration:"
        print "\tDummy M0 = %e" % (M0)
        print "\tTarget Mw = %e" % (Mw)

        mu = M0
        prod = math.pow(10, 1.5*(Mw + 10.73)) / (mu * 1.0e7)

        print "\nAdjusted area*slip product: = %f" % (prod)
        print "Done"
        return 0

if __name__ == '__main__':

    prog = ScalePointSource(sys.argv)
    sys.exit(prog.main())
