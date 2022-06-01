# code that stiches all tiles together for one single day
# hard coding 200 for now, but could change that
# using data from the 2017 WY

library(terra)
library(ncdf4)
require(XML)

### starting the loop.....

# set working directory
setwd("/Users/jacktarricone/wus_marg/wy_2017/")

# data info 

# gives us 4 dimensions here (nrow,ncol,statitics,time)
## data organized in order of the 5 statistics for the 50 model ensemble 
# stat_1 = mean
# stat_2 = standard deviation
# stat_3 = median
# stat_4 = 25th
# stat_5 = 75th

# create list of latitude values by degree or tile
lat_range <-seq(31,48,1)

# create empty list of latitude values loop matrices into
lat_mat_list <-vector(mode = "list", length = length(lat_range))

# create list of 23 dummy matrices so every row has same number of columns
# 23 is maximum number of latitude degrees in a row
dummy_mat <-matrix(, nrow = 225, ncol = 225)
mat_list_23 <-replicate(23, dummy_mat, simplify = FALSE)


# nested loop that creates a list of matrices by degree

system.time(
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
  
}
)

lat_mat_list # inspect list

# bind matrices together by row for full scence
full_mat <-do.call(rbind, rev(lat_mat_list))

# convert to raster and georeference
day200_rast <-rast(full_mat)

# data extent

# Northernmost latitude: 49 N 
# Southernmost latitude 31 N 

# Westernmost longitude: -125 W
# Easternmost longitude: -102 W

ext(day200_rast)<- ext(-125,-102,31,49)
crs(day200_rast) <-"epsg:4326"
day200_rast # inspect

# test plot
plot(day200_rast)
writeRaster(day200_rast, "wy2017_dowy200.tif") # save














