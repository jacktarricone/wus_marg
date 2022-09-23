# testing making a snow accumulation gif with one tile
# sept 23, 2022

library(terra)
library(ncdf4)
library(gganimate)
library(gapminder)
library(ggplot2);theme_set(theme_classic(12))


# set working directory for full year i just got off nsidc
setwd("/Volumes/jack_t/wus_marg/wy1984")

# list all netcdf files for 1984 wy
nc_list <-list.files(pattern = "SWE_SCA_POST.nc$", full.names = TRUE)

# pull out one near tahoe
tahoe <-nc_list[163]
tahoe

###### swe data info ######
# gives us 4 dimensions here (nrow,ncol,statitics,time)
## data organized in order of the 5 statistics for the 50 model ensemble 
# stat_1 = mean
# stat_2 = standard deviation
# stat_3 = median
# stat_4 = 25th
# stat_5 = 75th

# bring swe variable into array
ncin <- nc_open(tahoe) # open tahoe tile
swe_array <- ncvar_get(ncin,"SWE_Post") # read in
med_swe_array <-swe_array[,,3,] # pull out med SWE

# convert to raster stack and project
stack <-rast(med_swe_array)
ext(stack)<- ext(-121,-120,38,39)
crs(stack) <-"epsg:4326"
stack # inspect
plot(stack[[170]])

# convert to df for ggplot
stack_df <-as.data.frame(stack, xy = TRUE)

# create dates sequence
dates_seq <-seq(as.Date("1984-10-01"),as.Date("1985-09-30"),1)
colnames(stack_df)[3:367] <-as.character(dates_seq) # rename cols to dowy numbers

# pivot for plotting
stack_df_plot <-tidyr::pivot_longer(stack_df,3:367) # pivot
colnames(stack_df_plot)[3:4] <-c("date","swe") # rename
stack_df_plot$date <-as.Date(stack_df_plot$date) # convert to date
test <-dplyr::filter(stack_df_plot, date >= as.Date("1985-03-25") & date <= as.Date("1985-04-10"))

# plot
plot <-ggplot(test,aes(x,y, fill = as.numeric(swe), group = date)) +
  geom_raster() +
  labs(x="Lon (deg)",y="Lat (deg)")+
  coord_equal() +
  labs(fill = "SWE (m)") + #, title = "Grand Mesa Unwrapped Phase 2021 UAVSAR Time Series") +
  scale_fill_gradientn('UNW (rad)', limits = c(0,2),
                       colours = colorRampPalette(c("white", "darkblue"))(20)) +
  theme(strip.background = element_rect(colour="white", fill="white")) +
  transition_time(date) +
  labs(title = "Sierra Snow Water Equivalent: {frame_time}")+
  ease_aes()

#check
plot

# render and save
setwd("/Users/jacktarricone/wus_marg/")
# animate(plot, height=500, width=500, renderer=gifski_renderer())
anim_save("swe_map_test_v2.gif",
          plot,
          height=500, 
          width=500, 
          renderer=gifski_renderer())


