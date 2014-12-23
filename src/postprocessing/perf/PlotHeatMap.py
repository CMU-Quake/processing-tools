#!/usr/bin/env python
############################################################################
#
# Script: PlotHeatMap.py
#
# Description: Plot heat map for Hercules performance statistics
#
############################################################################

# Basic modules
import os
import sys
import array
import getopt
import numpy as np

# Patrick's modules
#from Params import *
from PlotUtils import *
#from ParseMeta import *

# Matplotlib modules
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors 
import matplotlib.cm as cm

# Statistics field format
statformat = {'proc':0,'cpu_flops':1,'cpu_elapsed':2,
              'gpu_flops':3,'gpu_elapsed':4,
              'mpi_sent':5,'mpi_recv':6,'mpi_elapsed':7};

# Statistics units
statunits = {'proc':'PEs','cpu_flops':'FLOPs','cpu_elapsed':'s',
              'gpu_flops':'FLOPs','gpu_elapsed':'s',
              'mpi_sent':'bytes','mpi_recv':'bytes','mpi_elapsed':'s'};

# Statistics labels
statlabels = {'proc':'Processors','cpu_flops':'CPU FLOPs',
              'cpu_elapsed':'CPU Elapsed Time',
              'gpu_flops':'GPU FLOPs','gpu_elapsed':'GPU Elapsed Time',
              'mpi_sent':'MPI Bytes Sent','mpi_recv':'MPI Bytes Received',
              'mpi_elapsed':'MPI Elapsed Time'};

# Plot figure axis position
PLOT_MAP_LOC = [0.15, 0.2, 0.7, 0.7]

class PlotHeatMap:
    def __init__(self, outfile, infile, field, cart, \
                     color=None, discretize=None, scale=None):
        self.valid = False
        self.outfile = outfile
        self.point1 = [0.0, 0.0]
        self.point2 = [0.0, 0.0]
        self.infile = infile
        self.field= field
        stokens = cart.split(',')
        self.cart = [int(stokens[0]), int(stokens[1])]
        self.color = color
        if (discretize != None):
            self.discretize = discretize
        else:
            self.discretize = [False, 6]
        self.scale = scale;
        self.valid = True

    def isValid(self):
        return self.valid

    def cleanup(self):
        return

    def _getData(self):
        # Read in the data file
        if (not os.path.exists(self.infile)):
            print "File %s does not exist" % (self.infile)
            return(None)
        fp = open(self.infile, 'r')
        lines = fp.readlines()
        fp.close()

        # Remove header/comment lines
        i = 0
        while (lines[i][0] == '#'):
            i = i + 1
        lines = lines[i:]

        # Define data array and extract desired field
        numprocs = len(lines);
        data = np.arange(numprocs, dtype=float)
        for i in xrange(0, numprocs):
            tokens = lines[i].split()
            data[i] = tokens[statformat[self.field]]

        data = data.reshape(self.cart[0], self.cart[1])
        #print data
        return(data)

    def main(self):
        # Get data points for selected statistic
        points = self._getData();
        if (points == None):
            print "Failed to get plot points"
            return(1)

        # Setup color scale. Select color map style, discretize it if
        # necessary
        if (self.color == None):
            cmap = cm.Spectral
        else:
            cmap = eval("cm.%s" % (self.color))
        if (self.discretize[0]):
            cmap = PlotUtils().plotCmapDiscretize(cmap, self.discretize[1])

        # Setup normalization
        if (self.scale != None):
            value_min = self.scale[0]
            value_max = self.scale[1]
        else:
            value_min = np.amin(points)
            value_max = np.amax(points)
        norm = mcolors.Normalize(vmin=value_min,vmax=value_max)

        # Plot the heat map
        plot_x_size = 8
        plot_y_size = 6
        fig = plt.figure(figsize=(plot_x_size,plot_y_size))
        PlotUtils().plotGridArray(fig, PLOT_MAP_LOC, points, \
                                      ['X', 'Y'], ['PEs', 'PEs'], \
                                      cmap, norm, statlabels[self.field])

        # Plot the colorbar
        PlotUtils().plotColorbar(self.field, statunits[self.field], \
                                     cmap, norm, value_min, value_max, \
                                     self.discretize[1])
        # Save the plot
        plt.savefig(self.outfile)
        plt.show()
        return 0

class PlotHeatMapScript:
    def __init__(self, argv):
        self.argc = len(argv)
        self.argv = argv

    def usage(self):
        print "Usage: " + sys.argv[0] + " [-c color] [-d bool,#] [-s min,max] <outfile> <infile> <field> <cart>"
        print "Example: " + sys.argv[0] + " test.png data.in Test\n"
        print "\t[-h]: This help message"
        print "\t[-c]: Set custom color bar (default: Spectral)"
        print "\t[-d]: Set color bar discretization (default: false,10)"
        print "\t[-s]: Set custom scale"
        print "\t<outfile>: Filename for plot"
        print "\t<infile>: Data source"
        print "\t<field>: Field for plot\n"
        print "\t<cart>: Cartesian grid\n"
        sys.exit(1)


    def main(self):

        # Parse options
        try:
            opts, args = getopt.getopt(self.argv[1:], "hc:d:s:", \
                                           ["help", "colorbar", \
                                                "discretize", "scale"])
        except getopt.GetoptError, err:
            print str(err)
            self.usage()
            return(1)

        color = None
        discretize = None
        scale = None

        for o, a in opts:
            if o in ('-s', '--scale'):
                stokens = a.split(',')
                scale = [float(stokens[0]), float(stokens[1])]
            elif o in ('-d', '--discretize'):
                stokens = a.split(',')
                discretize = [stokens[0], int(stokens[1])]
                if ((discretize[0] == 'true') or (discretize[0] == 'True')):
                    discretize[0] = True
                else:
                    discretize[0] = False
            elif o in ('-c', '--colorbar'):
                color = a
            elif o in ("-h", "--help"):
                self.usage()
                return(0)
            else:
                print "Invalid option %s" % (o)
                return(1)

        # Check command line arguments
        if (len(args) < 4):
            self.usage()

        outfile = args[0]
        infile = args[1]
        field = args[2]
        cart = args[3]

        prog = PlotHeatMap(outfile, infile, field, cart, \
                           color, discretize, scale)
        if (prog.isValid() == False):
            return(1)
            
        retval = prog.main()
        prog.cleanup()
        return(retval)
        

if __name__ == '__main__':

    prog = PlotHeatMapScript(sys.argv)
    sys.exit(prog.main())
