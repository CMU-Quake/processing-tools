#!/usr/bin/env python
############################################################################
#
# Script: create-stp-script.py
#
# Description: Create STP script for pulling observed data
#
############################################################################

import os
import sys
import array
import getopt
import math
import random

class CreateSTPScript:
    def __init__(self, argv):
        self.argc = len(argv)
        self.argv = argv

    def usage(self):
        print "Usage: " + sys.argv[0] + " [-e #######] <station file>"
        print "Example: " + sys.argv[0] + " -e 15481673 LH_stations.txt\n"
        print "\t[-h]                   : This help message"
        print "\t[-e]                   : Event ID associated with event"
        print "\t<stations file>        : Hercules station file"
        sys.exit(1)

    def main(self):
        # Parse options
        try:
            opts, args = getopt.getopt(self.argv[1:], "he:", ["help", "event"])
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
            elif o in ("-e", "--event"):
                evid = int(a)
            else:
                print "Invalid option %s" % (o)
                return(1)

        # Check command-line arguments
        if (len(args) != 1):
            self.usage()
            return(1)

        stafile = args[0]
        stpfile = 'stp_script.txt'

        # Read in Hercules station list
        print 'Reading Hercules station list'
        fp = open(stafile, 'r')
        sdata = fp.readlines()
        fp.close()

        # Write STP script
        print 'Writing STP script %s' % (stpfile)
        fp = open(stpfile, 'w')
        fp.write('event -e %d\n' % (evid))
        fp.write('ascii\n')
        fp.write('gain on\n')
        for i in range(0, len(sdata)):
            stokens = sdata[i].split()
            netid = stokens[0]
            staid = stokens[1]
            if (netid == '#'):
                # Skip comment header
                continue
            fp.write('trig -net %s -sta %s -chan B%% %d\n' % (netid, staid, evid))

        fp.close()

        print "Done"
        return 0

if __name__ == '__main__':

    prog = CreateSTPScript(sys.argv)
    sys.exit(prog.main())
