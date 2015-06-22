#!/usr/bin/env python
############################################################################
#
# Script: PlotHeatMapGPU.py
#
# Description: Plot heat map for Hercules GPU performance statistics
#
############################################################################

# Basic modules
import os
import sys
import array
import getopt
import numpy as np

# Patrick's modules
from PlotUtils import *

# Matplotlib modules
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors 
import matplotlib.cm as cm

# Plot labels
plotlabels = {'flops':'CPU/GPU FLOPs','flops_elapsed':'CPU/GPU Time',
              'flop_rate':'CPU/GPU FLOP Rate',
              'mpi_sent':'Bytes Sent','mpi_recv':'Bytes Received',
              'mpi_elapsed':'Communication Time'};

# Plot units
plotunits = {'flops':'GFLOPs','flops_elapsed':'s','flop_rate':'GFLOPs/s',
             'mpi_sent':'GB','mpi_recv':'GB','mpi_elapsed':'s'};

# Statistics field format
statformat = {'proc':0,'cpu_flops':1,'cpu_elapsed':2,
              'gpu_flops':3,'gpu_elapsed':4,
              'mpi_sent':5,'mpi_recv':6,'mpi_elapsed':7};

# Plot figure axis position
PLOT_MAP_LOC = [0.15, 0.2, 0.7, 0.7]

class PlotHeatMapGPU:
    def __init__(self, outfile, infile, ptype, cart, title, \
                     color=None, discretize=None, scale=None):
        self.valid = False
        self.outfile = outfile
        self.point1 = [0.0, 0.0]
        self.point2 = [0.0, 0.0]
        self.infile = infile
        stokens = cart.split(',')
        self.cart = [int(stokens[0]), int(stokens[1])]
        self.color = color
        if (discretize != None):
            self.discretize = discretize
        else:
            self.discretize = [False, 6]
        self.scale = scale;

        # Parse field list
        self.ptype = ptype
        self.punits = plotunits[ptype]
        self.plabel = plotlabels[ptype]
        
        # Construct plot title
        self.pltitle = "%s %s" % (title, self.plabel)

        # Construct color bar title
        self.cbtitle = "%s" % (self.plabel)

        # Construct color bar units
        self.cbunits = "%s" % (self.punits)

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

        numprocs = len(lines);
        if (numprocs != self.cart[0]*self.cart[1]):
            print "Unexpected number of PE data points in %s" % (self.infile)
            sys.exit(1)

        cpu_flops = np.zeros(numprocs, dtype=np.float64)
        cpu_elapsed = np.zeros(numprocs, dtype=np.float64)
        gpu_flops = np.zeros(numprocs, dtype=np.float64)
        gpu_elapsed = np.zeros(numprocs, dtype=np.float64)
        flop_rate = np.zeros(numprocs, dtype=np.float64)
        mpi_sent = np.zeros(numprocs, dtype=np.float64)
        mpi_recv = np.zeros(numprocs, dtype=np.float64)
        mpi_elapsed = np.zeros(numprocs, dtype=np.float64)

        # Define data array and extract desired field(s)
        data = np.arange(numprocs, dtype=float)
        for i in xrange(0, numprocs):
            tokens = lines[i].split()

            # Parse data for plot
            if (self.ptype == 'flops'):
                data[i] = (float(tokens[statformat['cpu_flops']]) \
                               + float(tokens[statformat['gpu_flops']])) \
                               / float(1024*1024*1024)
            elif (self.ptype == 'flops_elapsed'):
                data[i] = float(tokens[statformat['cpu_elapsed']]) \
                    + float(tokens[statformat['gpu_elapsed']])
            elif (self.ptype == 'flop_rate'):
                elapsed = (float(tokens[statformat['cpu_elapsed']]) \
                               + float(tokens[statformat['gpu_elapsed']]))
                if (elapsed > 0.0):
                    data[i] = (float(tokens[statformat['cpu_flops']]) \
                                   + float(tokens[statformat['gpu_flops']])) \
                                   / (elapsed) / float(1024*1024*1024)
                else:
                    data[i] = 0.0
            elif (self.ptype == 'mpi_sent'):
                data[i] = float(tokens[statformat[self.ptype]]) \
                    / float(1024*1024*1024)
            elif (self.ptype == 'mpi_recv'):
                data[i] = float(tokens[statformat[self.ptype]]) \
                    / float(1024*1024*1024)
            elif (self.ptype == 'mpi_elapsed'):
                data[i] = float(tokens[statformat[self.ptype]])

            # Parse data for statistics
            cpu_flops[i] =  float(tokens[statformat['cpu_flops']]) / float(1024*1024*1024)
            cpu_elapsed[i] =  float(tokens[statformat['cpu_elapsed']])
            gpu_flops[i] =  float(tokens[statformat['gpu_flops']]) / float(1024*1024*1024)
            gpu_elapsed[i] =  float(tokens[statformat['gpu_elapsed']])
            if (cpu_elapsed[i] > 0.0):
                flop_rate[i] = (cpu_flops[i]/cpu_elapsed[i])
            else:
                flop_rate[i] = 0
            if (gpu_elapsed[i] > 0.0):
                flop_rate[i] = flop_rate[i] + (gpu_flops[i]/gpu_elapsed[i])
            mpi_sent[i] =  float(tokens[statformat['mpi_sent']]) / float(1024*1024*1024)
            mpi_recv[i] =  float(tokens[statformat['mpi_recv']]) / float(1024*1024*1024)
            mpi_elapsed[i] =  float(tokens[statformat['mpi_elapsed']])

        data = data.reshape(self.cart[0], self.cart[1])

        # Dump statistics
        print "Statistics (min, max, mean, var, std):"
        print "CPU Flops (GF)\t%12.2f%12.2f%12.2f%12.2f%12.2f" % (np.amin(cpu_flops), np.amax(cpu_flops), np.mean(cpu_flops), np.var(cpu_flops), np.std(cpu_flops)) 
        print "CPU Elapsed (s)\t%12.2f%12.2f%12.2f%12.2f%12.2f" % (np.amin(cpu_elapsed), np.amax(cpu_elapsed), np.mean(cpu_elapsed), np.var(cpu_elapsed), np.std(cpu_elapsed))
        print "GPU Flops (GF)\t%12.2f%12.2f%12.2f%12.2f%12.2f" % (np.amin(gpu_flops), np.amax(gpu_flops), np.mean(gpu_flops), np.var(gpu_flops), np.std(gpu_flops)) 
        print "GPU Elapsed (s)\t%12.2f%12.2f%12.2f%12.2f%12.2f" % (np.amin(gpu_elapsed), np.amax(gpu_elapsed), np.mean(gpu_elapsed), np.var(gpu_elapsed), np.std(gpu_elapsed)) 
        print "FLOP Rate(GF/s)\t%12.2f%12.2f%12.2f%12.2f%12.2f" % (np.amin(flop_rate), np.amax(flop_rate), np.mean(flop_rate), np.var(flop_rate), np.std(flop_rate)) 
        print "MPI Sent (GB)\t%12.2f%12.2f%12.2f%12.2f%12.2f" % (np.amin(mpi_sent), np.amax(mpi_sent), np.mean(mpi_sent), np.var(mpi_sent), np.std(mpi_sent)) 
        print "MPI Recv (GB)\t%12.2f%12.2f%12.2f%12.2f%12.2f" % (np.amin(mpi_recv), np.amax(mpi_recv), np.mean(mpi_recv), np.var(mpi_recv), np.std(mpi_recv)) 
        print "MPI Elapsed (s)\t%12.2f%12.2f%12.2f%12.2f%12.2f" % (np.amin(mpi_elapsed), np.amax(mpi_elapsed), np.mean(mpi_elapsed), np.var(mpi_elapsed), np.std(mpi_elapsed)) 

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
            cmap = cm.Spectral_r
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
                                      cmap, norm, self.pltitle)

        # Plot the colorbar
        PlotUtils().plotColorbar(self.cbtitle, self.cbunits, \
                                     cmap, norm, value_min, value_max, \
                                     self.discretize[1])
        # Save the plot
        plt.savefig(self.outfile)
        plt.show()
        return 0

class PlotHeatMapGPUScript:
    def __init__(self, argv):
        self.argc = len(argv)
        self.argv = argv

    def usage(self):
        print "Usage: " + sys.argv[0] + " [-c color] [-d bool,#] [-s min,max] <infile> <plot type> <cart> <title> <outfile>"
        print "Example 1: " + sys.argv[0] + " stat-perf.txt flops 2,2 \"Solver \" plot.png\n"
        print "Example 2: " + sys.argv[0] + " stat-perf.txt flop_rate 4,8 \"Solver\" plot.png\n"
        print "\t[-h]: This help message"
        print "\t[-c]: Set custom color bar (default: Spectral_r)"
        print "\t[-d]: Set color bar discretization (default: false,10)"
        print "\t[-s]: Set custom scale"
        print "\t<infile>     : Data source"
        print "\t<plot type>  : Type of plot (" + str(plotlabels.keys()) + ")"
        print "\t<cart>       : Cartesian grid for PE layout (eg: 2,2)"
        print "\t<title>      : Plot title"
        print "\t<outfile>    : Filename for plot\n"
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
        if (len(args) < 5):
            self.usage()

        infile = args[0]
        ptype = args[1]
        cart = args[2]
        title = args[3]
        outfile = args[4]

        if (ptype not in plotlabels.keys()):
            print "Invalid plot type: %s" % (ptype)
            return(1)

        prog = PlotHeatMapGPU(outfile, infile, ptype, cart, title, \
                           color, discretize, scale)
        if (prog.isValid() == False):
            return(1)
            
        retval = prog.main()
        prog.cleanup()
        return(retval)
        

if __name__ == '__main__':

    prog = PlotHeatMapGPUScript(sys.argv)
    sys.exit(prog.main())
