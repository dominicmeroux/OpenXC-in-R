####################
# OpenXC R MongoDB #
####################
# This code was run on R 3.2.2 on a computer with RedHat CentOS 6

#########################################
######## Install + load packages
#########################################
# Install packages if they are not already on your system
Packages = c("RMongo", "jsonlite", "sqldf", "ggplot2")
sapply(Packages, function(x){if (any(grepl(x, installed.packages()))==FALSE){
  install.packages(x, repos = "http://cran.rstudio.com")
}})

# Libraries
library(RMongo)
library(jsonlite)
library(sqldf)
library(ggplot2)
#library(ggmap)           # didn't properly install
#library(plotGoogleMaps)  # didn't properly install

#########################################
######## Insert a sample OpenXC trace
#########################################
# Set working directory to a directory with OpenXC drive traces
setwd('/home/cloudera/Desktop/Cloudera_Notes/OpenXC/1FMCU9G94GUC63004')

# Connect to database
mongo = mongoDbConnect("test2", "localhost", 27017)

# Insert an OpenXC drive trace file
system('mongoimport --db test2 --collection trace --file 2016-09-11-22-31-08.json')


#########################################
######## Query from database
#########################################
##### HARSH ACCELERATION
# Acceleration events where pedal was pressed down more than 80%
Harsh_Acceleration = dbGetQuery(mongo, "trace", '{$and:[{"name":"accelerator_pedal_position"},{"value": {$gt:80}}]}')

# Histogram gives us a visualization of the extent to which the accelerator was pressed "harshly" (>80%)
# and how frequently these "harsh acceleration" events occured
hist(Harsh_Acceleration$value, 
     main = "Histogram of Harsh Acceleration Values", xlab = "Accelerator Pedal Position (%)", col = "cadetblue")

##### EXCESSIVE SPEEDING
# Capture instances of speed above 75 mph, or roughly 121 (rounding up) km/hr
Excessive_Speed = dbGetQuery(mongo, "trace", '{$and:[{"name":"vehicle_speed"},{"value": {$gt:121}}]}')

# Histogram gives us a visualization of the extent to which speeds exceeded 75 mph 
# and how frequently these "speeding" events occured
hist(Excessive_Speed$value, main = "Histogram of Excessive Speed Values", xlab = "Speed (km/hr)", col = "cadetblue")

##### LOCATIONS
Latitude = dbGetQuery(mongo, "trace", '{"name":"latitude"}')
Longitude = dbGetQuery(mongo, "trace", '{"name":"longitude"}')

# Pull locations together into a single dataframe, matched by timestamp
LocationDF = sqldf("select a.timestamp, a.value as Latitude, b.value as Longitude 
                   from Latitude as a, Longitude as b
                   where a.timestamp = b.timestamp")

# Initial basic plot of vehicle trip locations 
# TODO: work on an in-depth spatial analysis
plot(LocationDF$Latitude, LocationDF$Longitude, col = "cadetblue", xlab = "Latitude", ylab = "Longitude")

#########################################
######## MapReduce jobs
#########################################
# I haven't found a way to run MapReduce jobs from within R, 
# but you can go to the terminal and run (as an example)
# following similar structure to https://docs.mongodb.com/manual/tutorial/map-reduce-examples/
# TODO: Come up with more useful MapReduce queries

# $ mongo
########### Map
# $ 
# $ var mapFunction1 = function() {
# $   emit(this.name, this.value);
# $ };
# $
########### Reduce
# $ var reduceFunction1 = function(keyName, valuesValue) {
# $   return Array.sum(valuesValue);
# $ };
# $
########### Run MapReduce job
# $ db.trace.mapReduce(
# $   mapFunction1,
# $   reduceFunction1,
# $   { out: "map_reduce_example" }
# $ )

#########################################
######## Close out of MongoDB
#########################################
dbDisconnect(mongo)
