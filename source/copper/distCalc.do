/* distCalc.do v0.00             damiancclarke             yyyy-mm-dd:2014-09-26
----|----1----|----2----|----3----|----4----|----5----|----6----|----7----|----8

  Imports distance matrix from qgis (distance from each comuna to each mine, and
  calculates summary stats including: minimum distance, number of mines within i
  in {400, 500, 600} km, and weighted distance to mines within 400, 500 and 600
  km.

  In order to create the distance matrix, the following steps are followed:
   > Import base layer as vector file (division_comunal)
   > Create comuna centroids (or import comuna_centroids.shp)
   > Import mine locations from USGS (this is in EPSG:4326)
   > Convert mine locations to EPSG:32719
   > Calculate matrix using Vector->Analysis Tools->Distance Matrix


contact: mailto:damian.clarke@economics.ox.ac.uk
*/
