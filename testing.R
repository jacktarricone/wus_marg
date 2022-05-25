# learning how to manipulate the new WUS margulis data
# needs to be read in with netcdf not raster


library(terra)
library(ncdf4)

# set working directory
setwd("/Users/jacktarricone/wus_marg/test_data/")

# file path for 2017 swe and sca ncdf4
name <-"/Users/jacktarricone/wus_marg/test_data/WUS_UCLA_SR_v01_N37_0W120_0_agg_16_WY2017_18_SWE_SCA_POST.nc"
ncin <- nc_open(name)
dname <- "SWE_Post"  # define variable name
print(ncin) # print netcdf contents

# pull out SWE variable
swe_array <- ncvar_get(ncin,dname)
dim(swe_array) # check dims

# gives us 4 dimensions here (nrow,ncol,statitics,time)
## data organized in order of the 5 statistics for the 50 model ensemble 
# stat_1 = mean
# stat_2 = standard deviation
# stat_3 = median
# stat_4 = 25th
# stat_5 = 75th

# create array for just mean_swe
mean_swe_array <-swe_array[,,1,]

# convert to raster
mean_swe_rast <-rast(mean_swe_array)
mean_swe_rast 
plot(mean_swe_rast[[170]]) # test plot

### geolocate and project
# !!!!this is not the right way to do this given the variable pixel size

# set extent (from xml file)
# in the future, think about how to loop over the whole thing and do this
# would need code to extract
ext(mean_swe_rast)<- ext(-119.998,-119.001,37.0023,37.9978)

# set crs
crs(mean_swe_rast) <-"epsg:4326"

# test plot
plot(mean_swe_rast[[170]])
writeRaster(mean_swe_rast[[220]], "test2.tif")




