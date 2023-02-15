library(terra)
library(ncdf4)

# path to file
nc_path <-'/Users/jacktarricone/Downloads/4km_SWE_Depth_WY2012_v01.nc'
nc_in <-nc_open(nc_path) # open
nc_in # inspect

# pull out needed info
swe_array <-ncvar_get(nc_in,"SWE") # read in
lat_array <-ncvar_get(nc_in,"lat") # read in
lon_array <-ncvar_get(nc_in,"lon") # read in

# pull out extent limits for geoferencing
xmin <-min(lon_array)
xmax <-max(lon_array)
ymin <-min(lat_array)
ymax <-max(lat_array)

# make test rast from one day
test_mat <-swe_array[,,180] # pull out first stat or "mean SWE"
rotate_mat <-apply(t(test_mat),2,rev) # rotate matrix 90 deg counter clockwise
test_rast <-rast(rotate_mat)
test_rast # check
plot(test_rast)

# georeference
ext(test_rast) <-c(xmin,xmax,ymin,ymax) # set extent
crs(test_rast) <-crs('+proj=longlat +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +no_defs') # from user guide
plot(test_rast) # looks okay to me

