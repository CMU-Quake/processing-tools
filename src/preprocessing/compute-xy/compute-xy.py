#!/usr/bin/env python
############################################################################
#
# Script: compute-xy.py
#
# Description: Compute x,y coordinate for list of stations given lat/lon
#
############################################################################

import os
import sys
import array
import getopt
import math
import random


# Domain bounds
LONCORNERS = [-119.288842 , -118.354016, -116.846030, -117.780976]
LATCORNERS = [ 34.120549 ,  35.061096,   34.025873,   33.096503]

# Domain side length
DOMAINLENGTHETA = 180e3
DOMAINLENGTHCSI = 135e3

# Location tolerance
TOL = 1e-3


class ComputeXY:
    def __init__(self, argv):
        self.argc = len(argv)
        self.argv = argv

    def usage(self):
        print "Usage: " + sys.argv[0] + " <station file>"
        print "Example: " + sys.argv[0] + " BB_station.list\n"
        print "\t[-h]                   : This help message"
        print "\t<stations file>        : External station list"
        sys.exit(1)

    def compute(self, lon, lat):
        Xi = [0.0, 0.0, 0.0, 0.0]
        Yi = [0.0, 0.0, 0.0, 0.0]

        X=lat
        Y=lon
  
        for i in xrange(0, 4):
            Xi[i]=LATCORNERS[i]
            Yi[i]=LONCORNERS[i]
  
        Ax=4*X-(Xi[0]+Xi[1]+Xi[2]+Xi[3])
        Ay=4*Y-(Yi[0]+Yi[1]+Yi[2]+Yi[3])

        Bx=-Xi[0]+Xi[1]+Xi[2]-Xi[3]
        By=-Yi[0]+Yi[1]+Yi[2]-Yi[3]
        Cx=-Xi[0]-Xi[1]+Xi[2]+Xi[3]
        Cy=-Yi[0]-Yi[1]+Yi[2]+Yi[3]  
        Dx= Xi[0]-Xi[1]+Xi[2]-Xi[3]
        Dy= Yi[0]-Yi[1]+Yi[2]-Yi[3]
   
        # /*Initial values for csi and etha*/  
        XN = [0.0, 0.0]

        res=1e10

        M = [[0.0, 0.0], [0.0, 0.0]]
        F = [0.0, 0.0]
        DXN = [0.0, 0.0]
        XN = [0.0, 0.0]

        while ( res > TOL ):        
            M[0][0]=Bx+Dx*XN[1]
            M[0][1]=Cx+Dx*XN[0]
            M[1][0]=By+Dy*XN[1]
            M[1][1]=Cy+Dy*XN[0]
    
            F[0]=-Ax+Bx*XN[0]+Cx*XN[1]+Dx*XN[0]*XN[1]    
            F[1]=-Ay+By*XN[0]+Cy*XN[1]+Dy*XN[0]*XN[1]
    
            DXN[0]=-(F[0]*M[1][1]-F[1]*M[0][1])/(M[0][0]*M[1][1]-M[1][0]*M[0][1])
            DXN[1]=-(F[1]*M[0][0]-F[0]*M[1][0])/(M[0][0]*M[1][1]-M[1][0]*M[0][1])    

            res=math.pow(F[0]*F[0]+F[1]*F[1],0.5);
    
            XN[0]=XN[0]+DXN[0];
            XN[1]=XN[1]+DXN[1];
   
        # fprintf(stdout,"\n res=%e",res);
        domainCoords = [0.0, 0.0]
        domainCoords[0]=.5*(XN[0]+1)*DOMAINLENGTHCSI
        domainCoords[1]=.5*(XN[1]+1)*DOMAINLENGTHETA
  
        return domainCoords


    def main(self):
        # Parse options
        try:
            opts, args = getopt.getopt(self.argv[1:], "h", ["help"])
        except getopt.GetoptError, err:
            print str(err)
            self.usage()
            return(1)

        # Defaults
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

        sfile = args[0]

        #print "Reading in station list %s" % (sfile)
        fp = open(sfile, 'r')
        sdata = fp.readlines()
        fp.close()

        #print "Converting to x-y coordinates:"
        for i in range(0, len(sdata)):
            stokens = sdata[i].split()
            snet = stokens[0]
            ssta = stokens[1]
            slon = float(stokens[2])
            slat = float(stokens[3])
            xy = self.compute(slon, slat);
            sys.stdout.write("%5s %10s %14.6f %14.6f %14.6f %14.6f\n" % (snet, ssta, slon, slat, xy[1], xy[0]))
            
        #print "Done"
        return 0

if __name__ == '__main__':

    prog = ComputeXY(sys.argv)
    sys.exit(prog.main())
