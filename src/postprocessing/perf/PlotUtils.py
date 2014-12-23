#!/bin/env python
############################################################################
#
# Script: PlotUtils.py
#
# Description: Plotting utilities for UCVM and Hercules
#
############################################################################

# Basic modules
import os
import sys
import array
import math
import numpy as np

# Matplotlib modules
import matplotlib as mtl
mtl.use('Agg') # Disables use of Tk/X11
import matplotlib.mpl as mpl
mpl.rcParams['font.size'] = 10.
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap
import matplotlib.colors as mcolors 
import matplotlib.cm as cm


class PlotUtils:

    # Plots a line on a basemap image
    def plotLineMap(self, fig, grid1, grid2, point1=None, point2=None,
                    marker='o-', color='r'):
        grid_x = [grid1[0], grid2[0]]
        grid_y = [grid1[1], grid2[1]]
        
        fig.plot(grid_x, grid_y, marker,\
                 color=color)

        if (point1 != None):
            fig.text(grid1[0], grid1[1], \
                         '[1] %.1f, %.1f' % (point1[0], point1[1]),\
                         color='k')
        if (point2 != None):
            fig.text(grid2[0], grid2[1], \
                         '[2] %.1f, %.1f' % (point2[0], point2[1]),\
                         color='k')
        return


    # Plots a line on a grid
    def plotLineGrid(self, fig, grid1, grid2):
        grid_x = [grid1[0], grid2[0]]
        grid_y = [grid1[1], grid2[1]]
        
        fig.plot(grid_x, grid_y,'o-',\
                 color='r')
        fig.text(grid1[0]+4, grid1[1]+4, \
                 '[1] %ld, %ld' % (grid1[0], grid1[1]), color='k')
        fig.text(grid2[0]+4, grid2[1]+4, \
                 '[2] %ld, %ld' % (grid2[0], grid2[1]), color='k')
        return


    # Plot distance scale on a map
    def plotDistance(self, m, lonlatbox):
        lon0=lonlatbox[0][0] + (lonlatbox[1][0]-lonlatbox[0][0])/2
        lat0=lonlatbox[0][1] + (lonlatbox[1][1]-lonlatbox[0][1])/2
        try:
            m.drawmapscale(lonlatbox[0][0] + 0.75,\
                               lonlatbox[0][1] + 0.25,\
                               lon0=lon0,\
                               lat0=lat0,\
                               length=50.0)
        except:
            print "Warning: Unable to draw map scale for this projection"

        return 0


    # Plot colorbar
    def plotColorbar(self, value_type, value_units, cmap, norm, \
                     value_min, value_max, num_ticks=10):

        # Compute ticks
        ticks = []
        diff = (value_max - value_min) / float(num_ticks)
        for i in xrange(0, num_ticks + 1):
            ticks.append(value_min + (i * diff))

        if (value_max < 1.0):
            format = '%0.2f'
        else:
            format = '%2.2f'
        cax = plt.axes([0.1, 0.05, 0.8, 0.02])
        if ((value_units != None) and (len(value_units) > 0)):
            cax.set_title("%s (%s)" % (value_type, value_units))
        else:
            cax.set_title("%s" % (value_type))

        # Set tick label size
        if (len(ticks) > 16):
            for t in cax.get_xticklabels():
                t.set_fontsize(8)
            for t in cax.get_yticklabels():
                t.set_fontsize(8)

        mpl.colorbar.ColorbarBase(cax, cmap=cmap, \
                                  norm=norm, \
                                  ticks=ticks, \
                                  format=format, \
                                  orientation='horizontal')

        return 0


    # Discretize colorbar
    """Return a discrete colormap from the continuous colormap cmap.
    
    cmap: colormap instance, eg. cm.jet. 
    N: Number of colors.
    
    Example
    x = resize(arange(100), (5,100))
    djet = cmap_discretize(cm.jet, 5)
    imshow(x, cmap=djet)
    """
    def plotCmapDiscretize(self, cmap, N): 
        cdict = cmap._segmentdata.copy()
        # N colors
        colors_i = np.linspace(0,1.,N)
        # N+1 indices
        indices = np.linspace(0,1.,N+1)
        for key in ('red','green','blue'):
            # Find the N colors
            D = np.array(cdict[key])
            colors = np.interp(colors_i, D[:,0], D[:,1])
            #I = sp.interpolate.interp1d(D[:,0], D[:,1])
            #colors = I(colors_i)
            # Place these colors at the correct indices.
            A = np.zeros((N+1,3), float)
            A[:,0] = indices
            A[1:,1] = colors
            A[:-1,2] = colors
            # Create a tuple for the dictionary.
            L = []
            for l in A:
                L.append(tuple(l))
            cdict[key] = tuple(L)
        # Return colormap object.
        return mcolors.LinearSegmentedColormap('colormap',cdict,1024)


    # Get a tmerc projection
    def getProjection(self, lonlatbox, ax):

        m = Basemap(projection='cyl',\
                        llcrnrlat=lonlatbox[0][1],\
                        urcrnrlat=lonlatbox[1][1],\
                        llcrnrlon=lonlatbox[0][0],\
                        urcrnrlon=lonlatbox[1][0], \
                        resolution='f', \
                        anchor='C', ax=ax)

        #lon_0=lonlatbox[0][0] + (lonlatbox[1][0]-lonlatbox[0][0])/2
        #lat_0=lonlatbox[0][1] + (lonlatbox[1][1]-lonlatbox[0][1])/2
        #lon_r=abs(lonlatbox[0][0] + (lonlatbox[1][0]-lonlatbox[0][0])/2)
        #lat_r=abs(lonlatbox[0][1] + (lonlatbox[1][1]-lonlatbox[0][1])/2)
        #m = Basemap(projection='aeqd',\
        #            width=lon_r*15000.0,\
        #            height=lat_r*60000.0,\
        #            lon_0=lon_0, lat_0=lat_0,\
        #            resolution='f',\
        #            anchor='C', ax=ax)

        #lon_0=lonlatbox[0][0] + (lonlatbox[1][0]-lonlatbox[0][0])/2
        #lat_0=lonlatbox[0][1] + (lonlatbox[1][1]-lonlatbox[0][1])/2
        #m = Basemap(projection='tmerc',\
        #            llcrnrlat=lonlatbox[0][1],\
        #            urcrnrlat=lonlatbox[1][1],\
        #            llcrnrlon=lonlatbox[0][0],\
        #            urcrnrlon=lonlatbox[1][0],\
        #            lon_0=lon_0, lat_0=lat_0,\
        #            resolution='f', \
        #            anchor='C', ax=ax)

        return m


    # Plot regional map, corners of which are specified in lonlatbox
    def plotRegionMap(self, fig, loc, lonlatbox, points, title):
        # Setup region axis
        ax_bird = fig.add_axes(loc, frameon=False)
        ax_bird.set_title('%s' % (title))

        # Setup projection
        m = self.getProjection(lonlatbox, ax_bird)

        lat_diff = abs(lonlatbox[1][1] - lonlatbox[0][1])
        lon_diff = abs(lonlatbox[1][0] - lonlatbox[0][0])
        #lat_diff = round(lat_diff * 4.0) / 8.0
        #lon_diff = round(lon_diff * 4.0) / 8.0
        lat_diff = lat_diff / 2.0
        lon_diff = lon_diff / 2.0

        lat_ticks = np.arange(lonlatbox[0][1],\
                              lonlatbox[1][1] + 0.1,
                              lat_diff)
        lon_ticks = np.arange(lonlatbox[0][0],\
                              lonlatbox[1][0] + 0.1,
                              lon_diff)

        print "Lat Ticks: %s" % (str(lat_ticks))
        print "Lon Ticks: %s" % (str(lon_ticks))

        m.drawparallels(lat_ticks, linewidth=1.0, \
                            labels=[1,0,0,0])
        m.drawmeridians(lon_ticks, linewidth=1.0, \
                            labels=[0,0,0,1])

        grid1 = m(points[0][0], points[0][1])
        grid2 = m(points[1][0], points[1][1])

        # Slice endpoints
        PlotUtils().plotLineMap(plt, grid1, grid2, points[0], points[1])

        # Distance legend
        PlotUtils().plotDistance(m, lonlatbox)

        # Draw coastlines, boundaries and fill in continents
        m.drawcoastlines()
        m.drawmapboundary(fill_color='aqua')
        #m.drawlsmask(land_color='brown', ocean_color='aqua', lakes=True)
        m.fillcontinents(color='brown',lake_color='aqua')

        return 0


    # Plot context mesh and slice endpoints, size of which 
    # is specified in dims
    def plotRegionMesh(self, fig, loc, dims, points, title):
        
        # Setup Grid Axis
        ax = fig.add_axes(loc, frameon=True)
        ax.set_title('%s' % (title))
        ax.set_xlabel('X (units)')
        ax.set_ylabel('Y (units)')

        # Slice endpoints
        PlotUtils().plotLineGrid(plt, points[0], points[1])

        ax.set_xlim(0, dims[0])
        ax.set_ylim(0, dims[1])

        return 0


    # Plot list of points connected by lines
    def plotPointList(self, fig, loc, points, xrange, \
                        labels, units, title):

        ax = fig.add_axes(loc, frameon=False)
        ax.set_title('%s' % (title))
        ax.set_xlabel('%s (%s)' % (labels[0], units[0]))
        ax.set_ylabel('%s (%s)' % (labels[1], units[1]))

        ax.plot(points[1], points[0], '-')

        # Setup custom axis
        ax.set_xlim(xrange[0], xrange[1])
        #ax.set_ylim(0, dims[0])
        ax.invert_yaxis()
        return(0)

    
    # Plot a numpy array of MxNxRGBA on a grid
    def plotGridArray(self, fig, loc, points, \
                              labels, units, cmap, norm, title,
                              tick_scale=None, invert_y=False):

        ax = fig.add_axes(loc, frameon=False)
        ax.set_title('%s' % (title))
        ax.set_xlabel('%s (%s)' % (labels[0], units[0]))
        ax.set_ylabel('%s (%s)' % (labels[1], units[1]))

        ax.imshow(points, cmap=cmap, norm=norm, interpolation='nearest') 

        dims = points.shape
        
        # Setup custom axis
        ax.set_xlim(0, dims[1]-1)
        ax.set_ylim(0, dims[0]-1)
        if (invert_y):
            ax.invert_yaxis()

        # Scale tick labels
        if (tick_scale != None):
            xlo,xla = plt.xticks()
            ylo,yla = plt.yticks()
            xlocs = []
            xlabels = []
            ylocs = []
            ylabels = []
            for i in xrange(0, len(xlo)):
                if (dims[1] >= xlo[i]):
                    xlabels.append("%4.1f" % (xlo[i]*tick_scale[0]))
                    xlocs.append(xlo[i])
            for i in xrange(0, len(ylo)):
                if (dims[0] >= ylo[i]):
                    ylabels.append("%4.1f" % (ylo[i]*tick_scale[1]))
                    ylocs.append(ylo[i])

            plt.xticks(xlocs, xlabels)
            plt.yticks(ylocs, ylabels)

        return 0


    # Plot an array of lon/lat points on a map projection
    def plotMapArray(self, fig, loc, lonlatbox, points, lons, lats, \
                         title, cmap, norm, poly=None):

        # Setup axis
        ax = fig.add_axes(loc, frameon=False)
        ax.set_title('%s' % (title))

        # Setup projection
        m = self.getProjection(lonlatbox, ax)

        lat_diff = abs(lonlatbox[1][1] - lonlatbox[0][1])
        lon_diff = abs(lonlatbox[1][0] - lonlatbox[0][0])
        #lat_diff = round(lat_diff * 4.0) / 8.0
        #lon_diff = round(lon_diff * 4.0) / 8.0
        lat_diff = lat_diff / 2.0
        lon_diff = lon_diff / 2.0

        lat_ticks = np.arange(lonlatbox[0][1],\
                              lonlatbox[1][1] + 0.1,
                              lat_diff)
        lon_ticks = np.arange(lonlatbox[0][0],\
                              lonlatbox[1][0] + 0.1,
                              lon_diff)

        print "Lat Ticks: %s" % (str(lat_ticks))
        print "Lon Ticks: %s" % (str(lon_ticks))

        # Draw parallels, meridians
        m.drawparallels(lat_ticks, linewidth=1.0, \
                        labels=[1,0,0,0])
        m.drawmeridians(lon_ticks, linewidth=1.0, \
                        labels=[0,0,0,1])
        m.drawstates()
        m.drawcountries()

        # Transform from lonlat to map coords
        t = m.transform_scalar(points, lons, lats, len(lons), len(lats))

        # Plot points
        m.imshow(t, cmap=cmap, norm=norm) 
        
        # Plot poly
        if (poly != None):
            i = 0
            polylen = len(poly)
            while (i < polylen-1):
                grid1 = m(poly[i][0], poly[i][1])
                grid2 = m(poly[i+1][0], poly[i+1][1])
                PlotUtils().plotLineMap(plt, grid1, grid2, \
                                            None, None, '-', 'r')
                i = i + 1

        # Draw coastlines,
        m.drawcoastlines()

        return 0
