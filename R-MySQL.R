##################
# OpenXC R MySQL #
################################################################################################
# Purpose is to read OpenXC JSON trace files into R. Make sure JSON is properly formatted      #
# (if OpenXC VI was unplugged prior to end of data recording, remove partial final message).   #
#                                                                                              #
# After reading into R, OpenXC messages are transferred to a MySQL database for storage        #
# which can be important if many trips are recorded. Data can then be queried from R or        #
# another tool, or imported into visualization software (e.g. Tableau).                        #
################################################################################################

# If running the file from the command line, run with the following arguments
# Rscript R-MySQL.R "FIRST (OR NOT) TIME RUN" "WORKING_DIRECTORY" "DB_Name" "DB_User" "DB_Pass"
#
# e.g. Rscript R-MySQL.R "TRUE" "/Users/ME/Documents/VI_Traces" "MyDatabase" "ME" "abc123"
#
# Arguments
###########
#
# R-MYSQL.R: run this R script, you must be in the directory containing it or specify the absolute path
#
# "FIRST (OR NOT) TIME RUN": set as "TRUE" if this is the first time running the file, else set as "FALSE"
#
# "WORKING_DIRECTORY": the working directory with your trace files, e.g. "/Users/dmeroux/Desktop"
#                      on Mac or Linux; "C:\Users\dmeroux\Desktop" on Windows
#
# "DB_Name": MySQL Database name
#
# "DB_User": MySQL Username
#
# "DB_Pass": MySQL Password
###########
# This file is set up to run via command line - to change this, comment out "CL_args[x]" statements
# and replace them with the appropriate values
CL_args = commandArgs(trailingOnly = TRUE)

# Is this the first time you're running this file? 
FIRST_RUN = CL_args[1]

# Set working directory to access appropriate files
WD = CL_args[2]
setwd(WD)

#########################################
######## STEP 1 - Extracting JSON Data
#########################################

# Install required packages if they are not already installed
Packages = c("jsonlite", "sqldf", "plyr", "RMySQL")
sapply(Packages, function(x){if (any(grepl(x, installed.packages()))==FALSE){
  install.packages(x, repos="http://cran.rstudio.com/")
}})

# Import libraries
library("jsonlite")
library("sqldf")
library("plyr")
library("RMySQL")

# IF TRACES HAVE BEEN ALREADY UPLOADED INTO MySQL DATABASE, ENSURE SUBSEQUENT RUNS OF THIS R SCRIPT DON'T RE-Do THE WORK
# ELSE IF DOING THIS FOR THE FIRST TIME, IGNORE EXISTINGTRACES-RELATED COMMANDS
# http://www.stat.berkeley.edu/~nolan/stat133/Fall05/lectures/SQL-R.pdf
# Goal here is to obtain names of existing traces in MySQL db so these aren't re-uploaded. 
DB_Name = CL_args[3] # Insert Database Name Here
DB_User = CL_args[4] # Insert Database Username Here
DB_Pass = CL_args[5] # Insert Database Password Here
drv = dbDriver("MySQL")
con = dbConnect(drv, user=DB_User, dbname=DB_Name,
                host="localhost", # Change "localhost" if host is different
                password=DB_Pass)

ExistingTraces = dbGetQuery(con, "SELECT DISTINCT trace FROM coordinates;")

## Extract json OpenXC drive trace filenames
files = list.files(path=".", pattern=".json")

## Transform ExistingTraces data frame into a character vector
ExistingTraces2 = character()
for(i in 1:nrow(ExistingTraces)){
  ExistingTraces2[i] = ExistingTraces[i,1]
}
## Remove filenames for existing traces. Expect the following error statement:
# Error in if (gsub(".json", "", files[i]) == ExistingTraces2[j]) { : 
#   missing value where TRUE/FALSE needed
for(i in 1:length(files)){
  for(j in 1:length(ExistingTraces2)){
    if(gsub(".json", "", files[i])==ExistingTraces2[j]){
      files = files[-i]
    }
  }
}

## Remaining trace names
fnames = sapply(files, function(x){gsub(".json", "", x)})

# Read in streamed data: http://stackoverflow.com/questions/26519455/error-parsing-json-file-with-the-jsonlite-package
# Expect warning messages: incomplete final line found on 'filename'
data = list()
names = character()
dfs = list()
for(i in 1:length(files)){
  data[[i]] = data.frame(stream_in(file(files[i])))
  data[[i]] = data[[i]][-3]
}
# Add filenames into a column 
# Expect warning messages: number of items to replace is not a multiple of replacement length
for(i in 1:length(files)){
  names[i] = rep(fnames[i], times = nrow(data[[i]]))
  dfs[[i]] = data.frame(names[i], data[[i]])
}
# Merge dataframe list into one large dataframe
OpenXC_data = ldply(dfs, data.frame)
# Rename dataset identifier column
colnames(OpenXC_data)[1] = "trace"

# List variable names to get a summary
#Variables = sqldf("select count(*), trace, name from OpenXC_data group by trace, name;")

OpenXC_data$timestamp = as.integer(OpenXC_data$timestamp)

accelerator_pedal_position = OpenXC_data[which(OpenXC_data$name == "accelerator_pedal_position"),]
brake_pedal_status = OpenXC_data[which(OpenXC_data$name == "brake_pedal_status"),]
engine_speed = OpenXC_data[which(OpenXC_data$name == "engine_speed"),]
fuel_consumed_since_restart = OpenXC_data[which(OpenXC_data$name == "fuel_consumed_since_restart"),]
fuel_level = OpenXC_data[which(OpenXC_data$name == "fuel_level"),]
headlamp_status = OpenXC_data[which(OpenXC_data$name == "headlamp_status"),]
high_beam_status = OpenXC_data[which(OpenXC_data$name == "high_beam_status"),]
ignition_status = OpenXC_data[which(OpenXC_data$name == "ignition_status"),]
coordinates = OpenXC_data[which(OpenXC_data$name == "latitude" | OpenXC_data$name == "longitude"),]
odometer = OpenXC_data[which(OpenXC_data$name == "odometer"),]
parking_brake_status = OpenXC_data[which(OpenXC_data$name == "parking_brake_status"),]
steering_wheel_angle = OpenXC_data[which(OpenXC_data$name == "steering_wheel_angle"),]
torque_at_transmission = OpenXC_data[which(OpenXC_data$name == "torque_at_transmission"),]
transmission_gear_position = OpenXC_data[which(OpenXC_data$name == "transmission_gear_position"),]
vehicle_speed = OpenXC_data[which(OpenXC_data$name == "vehicle_speed"),]
windshield_wiper_status = OpenXC_data[which(OpenXC_data$name == "windshield_wiper_status"),]

################################################################################################
################################################################################################
################################################################################################
# CONNECTING RESULTS TO MySQL database

# Write Tables (if doing this the first time, overwrite is T and append is F)
if (FIRST_RUN==TRUE){
  OVERWRITE_VAL = T
  APPEND_VAL    = F
} else{
  OVERWRITE_VAL = F
  APPEND_VAL    = T
}

dbWriteTable(con, name="accelerator_pedal_position", 
             value=accelerator_pedal_position,
             field.types=list(trace="varchar(21)", value="double", name="varchar(40)", timestamp="int(10)"),
             row.names=F, overwrite=OVERWRITE_VAL, append=APPEND_VAL)

dbWriteTable(con, name="brake_pedal_status", 
             value=brake_pedal_status, 
             field.types=list(trace="varchar(21)", value="varchar(4)",  name="varchar(40)", timestamp="int(10)"),
             row.names=F, overwrite=OVERWRITE_VAL, append=APPEND_VAL)

dbWriteTable(con, name="brake_pedal_status", 
             value=brake_pedal_status, 
             field.types=list(trace="varchar(21)", value="varchar(4)",  name="varchar(40)", timestamp="int(10)"),
             row.names=F, overwrite=OVERWRITE_VAL, append=APPEND_VAL)

dbWriteTable(con, name="engine_speed", 
             value=engine_speed, 
             field.types=list(trace="varchar(21)", value="double",  name="varchar(40)", timestamp="int(10)"),
             row.names=F, overwrite=OVERWRITE_VAL, append=APPEND_VAL)

dbWriteTable(con, name="fuel_consumed_since_restart", 
             value=fuel_consumed_since_restart, 
             field.types=list(trace="varchar(21)", value="double",  name="varchar(40)", timestamp="int(10)"),
             row.names=F, overwrite=OVERWRITE_VAL, append=APPEND_VAL)

dbWriteTable(con, name="fuel_level", 
             value=fuel_level, 
             field.types=list(trace="varchar(21)", value="double",  name="varchar(40)", timestamp="int(10)"),
             row.names=F, overwrite=OVERWRITE_VAL, append=APPEND_VAL)

dbWriteTable(con, name="headlamp_status", 
             value=headlamp_status, 
             field.types=list(trace="varchar(21)", value="varchar(4)",  name="varchar(40)", timestamp="int(10)"),
             row.names=F, overwrite=OVERWRITE_VAL, append=APPEND_VAL)

dbWriteTable(con, name="high_beam_status", 
             value=high_beam_status, 
             field.types=list(trace="varchar(21)", value="varchar(4)",  name="varchar(40)", timestamp="int(10)"),
             row.names=F, overwrite=OVERWRITE_VAL, append=APPEND_VAL)

dbWriteTable(con, name="ignition_status", 
             value=ignition_status, 
             field.types=list(trace="varchar(21)", value="varchar(4)",  name="varchar(40)", timestamp="int(10)"),
             row.names=F, overwrite=OVERWRITE_VAL, append=APPEND_VAL)

dbWriteTable(con, name="coordinates", 
             value=coordinates, 
             field.types=list(trace="varchar(21)", value="double",  name="varchar(40)", timestamp="int(10)"),
             row.names=F, overwrite=OVERWRITE_VAL, append=APPEND_VAL)

dbWriteTable(con, name="odometer", 
             value=odometer, 
             field.types=list(trace="varchar(21)", value="double",  name="varchar(40)", timestamp="int(10)"),
             row.names=F, overwrite=OVERWRITE_VAL, append=APPEND_VAL)

dbWriteTable(con, name="parking_brake_status", 
             value=parking_brake_status, 
             field.types=list(trace="varchar(21)", value="varchar(4)",  name="varchar(40)", timestamp="int(10)"),
             row.names=F, overwrite=OVERWRITE_VAL, append=APPEND_VAL)

dbWriteTable(con, name="steering_wheel_angle", 
             value=steering_wheel_angle, 
             field.types=list(trace="varchar(21)", value="double",  name="varchar(40)", timestamp="int(10)"),
             row.names=F, overwrite=OVERWRITE_VAL, append=APPEND_VAL)

dbWriteTable(con, name="torque_at_transmission", 
             value=torque_at_transmission, 
             field.types=list(trace="varchar(21)", value="double",  name="varchar(40)", timestamp="int(10)"),
             row.names=F, overwrite=OVERWRITE_VAL, append=APPEND_VAL)

dbWriteTable(con, name="transmission_gear_position", 
             value=transmission_gear_position, 
             field.types=list(trace="varchar(21)", value="varchar(7)",  name="varchar(40)", timestamp="int(10)"),
             row.names=F, overwrite=OVERWRITE_VAL, append=APPEND_VAL)

dbWriteTable(con, name="vehicle_speed", 
             value=vehicle_speed, 
             field.types=list(trace="varchar(21)", value="double",  name="varchar(40)", timestamp="int(10)"),
             row.names=F, overwrite=OVERWRITE_VAL, append=APPEND_VAL)

dbWriteTable(con, name="windshield_wiper_status", 
             value=windshield_wiper_status, 
             field.types=list(trace="varchar(21)", value="varchar(4)",  name="varchar(40)", timestamp="int(10)"),
             row.names=F, overwrite=OVERWRITE_VAL, append=APPEND_VAL)

# A couple of commands to confirm that the created tables exist: 
#dbGetQuery(con, "select count(*) from brake_pedal_status;")
#dbListTables(con)

################
# Next step: Analyze data with R and SQL

################

# Disconnect from Database
dbDisconnect(con)
dbUnloadDriver(drv)
