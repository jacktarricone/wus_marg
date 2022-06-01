# code that stiches all tiles together for one single day

library(terra)
library(ncdf4)
require(XML)

### starting the loop.....

# set working directory
setwd("/Users/jacktarricone/wus_marg/wy_2017/")

# file path for 2017 swe and sca ncdf4 in idaho
netcdf_files <-list.files(pattern = ".*SWE_SCA_POST.nc$", full.names = TRUE)
print(netcdf_files)

list <- vector(mode = "list", length = length(netcdf_files))

for (i in seq_along(netcdf_files)){
  
  # pull out SWE variable
  ncin <- nc_open(netcdf_files[[i]])
  list[[i]] <- ncvar_get(ncin,"SWE_Post")
  nc_close(ncin)
  
}

# data extent

# Northernmost latitude: 49 N 
# Southernmost latitude 31 N 

# Westernmost longitude: -125 W
# Easternmost longitude: -102 W




head(netcdf_list)
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
plot(mean_swe_rast[[200]]) # test plot not projected

### geolocate and project
# !!!!this is not the right way to do this given the variable pixel size

# parse xml file
swe_xml_file <-list.files(pattern = "SWE_SCA_POST.nc.xml", full.names = TRUE)
data <- xmlParse(swe_xml_file)
xml_data <- xmlToList(data)
print(xml_data)

# bounding box for geolocation in terra
xmin <-as.numeric(xml_data[["GranuleURMetaData"]][["SpatialDomainContainer"]][["HorizontalSpatialDomainContainer"]][["BoundingRectangle"]][["WestBoundingCoordinate"]])
xmax <-as.numeric(xml_data[["GranuleURMetaData"]][["SpatialDomainContainer"]][["HorizontalSpatialDomainContainer"]][["BoundingRectangle"]][["EastBoundingCoordinate"]])
ymin <-as.numeric(xml_data[["GranuleURMetaData"]][["SpatialDomainContainer"]][["HorizontalSpatialDomainContainer"]][["BoundingRectangle"]][["SouthBoundingCoordinate"]])
ymax <-as.numeric(xml_data[["GranuleURMetaData"]][["SpatialDomainContainer"]][["HorizontalSpatialDomainContainer"]][["BoundingRectangle"]][["NorthBoundingCoordinate"]])

# set extent
ext(mean_swe_rast)<- ext(xmin,xmax,ymin,ymax)

# set crs
crs(mean_swe_rast) <-"epsg:4326"
mean_swe_rast

# test plot
plot(mean_swe_rast[[230]])
writeRaster(mean_swe_rast[[230]], "idaho230.tif")




