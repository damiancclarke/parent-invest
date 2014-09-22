# copperMaps.py v0.00            damiancclarke             yyyy-mm-dd:2014-09-21
#---|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8
#

from qgis.core import *
import qgis.utils


#===============================================================================
#=== (1) Set locations of data
#===============================================================================
comloc = '~/database/ChileRegiones/GeoRefs/division_comunal'
coploc = '~/investigacion/2014/ParentalInvestments/data/Geo'

#===============================================================================
#=== (1) Load raster layers
#===============================================================================
comlayer = QgsVectorLayer(coploc + 'division_comunal', 'coms', 'ogr')
print comlayer
