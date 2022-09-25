# testing making a snow accumulation gif with one tile
# sept 23, 2022

library(terra)
library(lubridate)
library(ncdf4)
library(ggmap)
library(gganimate)
library(gapminder)
library(ggplot2);theme_set(theme_classic(12))
library(RColorBrewer)

# set working directory for full year i just got off nsidc
setwd("/Users/jacktarricone/wus_marg/sierra_tile")

# list all netcdf files for 1984 wy
nc_list <-list.files(pattern = "SWE_SCA_POST.nc$", full.names = TRUE)
nc_list

# pull out wy2018
wy2018 <-nc_list[35]
wy2018

###### swe data info ######
# gives us 4 dimensions here (nrow,ncol,statitics,time)
## data organized in order of the 5 statistics for the 50 model ensemble 
# stat_1 = mean
# stat_2 = standard deviation
# stat_3 = median
# stat_4 = 25th
# stat_5 = 75th

# bring swe variable into array
ncin <- nc_open(wy2018) # open tahoe tile
swe_array <- ncvar_get(ncin,"SWE_Post") # read in
med_swe_array <-swe_array[,,3,] # pull out med SWE

# convert to raster stack and project
stack <-rast(med_swe_array)
ext(stack)<- ext(-121,-120,39,40)
crs(stack) <-"epsg:4326"
stack # inspect
plot(stack[[230]])

# convert to df for ggplot
stack_df <-as.data.frame(stack, xy = TRUE)

# create dates sequence
dates_seq <-seq(ymd(origin = "2017-10-01"), ymd("2018-09-30"),1)
colnames(stack_df)[3:367] <-as.character(dates_seq) # rename cols to dowy numbers
head(stack_df)
stack_df[stack_df == 0] <-NA

# pivot for plotting
stack_df_plot <-tidyr::pivot_longer(stack_df,3:367) # pivot
colnames(stack_df_plot)[3:4] <-c("date","swe") # rename
stack_df_plot$date <-ymd(stack_df_plot$date) # convert to date
class(stack_df_plot)

# date filtering
# <-as.data.frame(dplyr::filter(stack_df_plot, date >= ymd("1985-03-25") & date <= ymd("1985-04-10")))

# set map bounding box
loc <-c(-121,39,-120,40)

# download google sat
myMap <- get_map(location=loc,
                 source="google", 
                 maptype="satellite", 
                 crop=TRUE)

# see map, looks good
ggmap(myMap)

# set scale
blues_scale <-brewer.pal(9, 'Blues')

# single plot test before making gif
ggmap(myMap) +
  geom_raster(stack_df, mapping = aes(x,y, fill = `2018-04-01`)) +
  coord_equal()+
  scale_fill_gradientn(colours = blues_scale, limits = c(0,2.5), na.value="transparent") +
  theme(strip.background = element_rect(colour="white", fill="white")) +
  labs(title = "North Lake Tahoe SWE: 2018-04-01", fill = "SWE (m)",
       x="Lon (deg)", y="Lat (deg)")

# ggsave("nl_swe_2018_04_01.png",
#        width = 7,
#        height = 7,
#        dpi = 400)

# date filtering
# test <-as.data.frame(dplyr::filter(stack_df_plot, date >= ymd("2018-03-25") & date <= ymd("2018-03-27")))

# plot for animation
plot <-ggmap(myMap) +
  geom_raster(stack_df_plot, mapping = aes(x,y, group = date, fill = swe)) +
  coord_equal() + # set aspect ratio
  scale_fill_gradientn(colours = blues_scale, limits = c(0,2.5), na.value="transparent") +
  labs(title = "North Lake Tahoe SWE: {frame_time}", 
       fill = "SWE (m)",
       x="Lon (deg)", y="Lat (deg)")+
  transition_time(date) + # format gif by date
  ease_aes("linear") # ow gifs change

# render and save
setwd("/Users/jacktarricone/wus_marg/")
animate(plot, fps=.11)
anim_save("north_lake_swe_map_2018_v2", animation = last_animation())


