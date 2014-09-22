# copperMaps.py v0.00            damiancclarke             yyyy-mm-dd:2014-09-21
#---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
#

from qgis.core import *
import qgis.utils


#===============================================================================
#=== (1) Set locations of data
#===============================================================================
comloc = '~/database/ChileRegiones/GeoRefs/division_comunal/'
coploc = '~/investigacion/2014/ParentalInvestments/data/Copper/USGS/'

#===============================================================================
#=== (2) Load raster layers
#===============================================================================
comlayer = QgsVectorLayer(comloc + 'division_comunal.shp', 'coms', 'ogr')
midlayer = QgsVectorLayer(comloc + 'comuna_centroids.shp', 'cent', 'ogr')

copper = 'file//' + coploc + 'Deposits.csv?delimiter=%s&xField=%s&yField=%s&crs=epsg:4326" \
% (",", "latitude", "longitude")'
coplayer = QgsVectorLayer(copper, 'copp', 'delimitedtext')

print comlayer
print midlayer
print coplayer

#===============================================================================
#=== (3) Close
#===============================================================================
QgsApplication.exitQgis()
