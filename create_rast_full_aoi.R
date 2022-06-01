# code that stiches all tiles together for one single day

library(terra)
library(ncdf4)
require(XML)

### starting the loop.....

# set working directory
setwd("/Users/jacktarricone/wus_marg/wy_2017/")

# file path for 2017 swe and sca ncdf4 in idaho
# netcdf_files <-list.files(pattern = ".*SWE_SCA_POST.nc$", full.names = TRUE)
# print(netcdf_files)
# print(netcdf_files[15])

# create list of latitude values by degree or tile
lat_range <-seq(47,48,1)

# create empty list of latitude values loop matrices into
lat_mat_list <-vector(mode = "list", length = length(lat_range))

# create list of 23 dummy matrices so every row has same number of columns
# 23 is maximum number of latitude degrees in a row
dummy_mat <-matrix(, nrow = 225, ncol = 225)
mat_list_23 <-replicate(23, dummy_mat, simplify = FALSE)


# goal: a nested loop that creates a list of list by latitude
# can then be stiched back together to make full scene raster


for (i in seq_along(lat_mat_list)){
  
  # define latitude value
  lat_value <-lat_range[i]
  print(lat_value) # test print
  
  # create string to search files using lat value
  file_name <-paste0(".*", lat_value, ".*SWE_SCA_POST.nc$")
  
  # list all SWE files for defined latitude values
  netcdf_files <-list.files(pattern = file_name, full.names = TRUE)
  
  for (j in seq_along(netcdf_files)){
    
    # open file
    ncin <- nc_open(netcdf_files[[j]])
  
    # bring swe variable into array
    swe_array <- ncvar_get(ncin,"SWE_Post") # read in
    mean_swe_array <-swe_array[,,1,] # pull out first stat or "mean SWE"
    dowy200 <-mean_swe_array[,,200] # day of water year 200
  
    # test plots for knowing the loop is working
    test <-rast(dowy200)
    plot(test)
    
    # store in list
    mat_list_23[[j]] <-dowy200 
    
    nc_close(ncin) # close netcdf, idk why it was online
  }
  
  # create single matrix for said lat by combining them from list
  # reverse to geolocate propertly
  day200_mat <-do.call(cbind, rev(mat_list_23))
  
  # store matrix 
  lat_mat_list[[i]] <-day200_mat
  
  # ext(day200_rast_full)<- ext(-124,-102,47,48)
  # crs(day200_rast_full) <-"epsg:4326"
  # day200_rast_full
  # plot(day200_rast_full)
   
}

lat_mat_list

#day200_mat <-do.call(cbind, rev(day200_list))
full_mat <-do.call(rbind, rev(lat_mat_list))
day200_rast <-rast(full_mat)
ext(day200_rast)<- ext(-125,-102,47,49)
crs(day200_rast) <-"epsg:4326"
day200_rast
plot(day200_rast)
writeRaster(day200_rast, "4849n.tif")

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




