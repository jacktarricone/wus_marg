# learning how to manipulate the new WUS margulis data
# needs to be read in with netcdf not raster

library(terra)
library(ncdf4)

setwd("/Users/jacktarricone/wus_marg/test_data/")

# file path
name <-"/Users/jacktarricone/wus_marg/test_data/WUS_UCLA_SR_v01_N37_0W120_0_agg_16_WY2017_18_SWE_SCA_POST.nc"
ncin <- nc_open(name)
dname <- "SWE_Post"  # note: tmp means temperature (not temporary)
print(ncin)

# pull out SWE
swe_array <- ncvar_get(ncin,dname)
dim(swe_array)

# gives us 4 dimensions here, first layer is mean_swe
mean_swe_array <-swe_array[,,1,]

# convert to raster
mean_swe_rast <-rast(mean_swe_array)
mean_swe_rast 
plot(mean_swe_rast[[170]])

### geolocate and project
# set extent
ext(mean_swe_rast)<- ext(-119.998,-119.001,37.0023,37.9978)

# set crs
crs(mean_swe_rast) <-"epsg:4326"

# test plot
plot(mean_swe_rast[[170]])
writeRaster(mean_swe_rast[[220]], "test2.tif")



# bring in swe and sca netcdf for 2017
setwd("/Users/jacktarricone/wus_marg/test_data/")
full <-rast("WUS_UCLA_SR_v01_N37_0W120_0_agg_16_WY2017_18_SWE_SCA_POST.nc")
#depth <-rast("Users/jacktarricone/Downloads/WUS_UCLA_SR_v01_N40_0W109_0_agg_16_WY2017_18_SD_POST.nc")
plot(depth)

# set extent for this test brick
ext(full)<- ext(-119.998,-119.001,37.0023,37.9978)
# full <-project(full, "epsg:4326")

# list names
list_names <-names(full)
tail(list_names)


## data organized in order of the 5 statistics for the 50 model ensemble 
# stat_1 = mean
# stat_2 = standard deviation
# stat_3 = median
# stat_4 = 25th
# stat_5

# first 1825 layers are swe
# last are sca

# sequence for mean_swe layers (1,6,1...)
swe_layers <-seq(1,1825,by=5)

# create subset vector of layers
mean_swe <-subset(full, swe_layers)
mean_swe # inspect
plot(mean_swe[[220]])

# test save
writeRaster(mean_swe[[220]], "test.tif")
