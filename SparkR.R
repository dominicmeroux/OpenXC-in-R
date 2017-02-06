# Databricks notebook source
# Useful documentation: https://docs.databricks.com/spark/latest/sparkr/functions/unionAll.html

# TABLE OF CONTENTS
########################################################################################################################
# Harsh Acceleration


# Using Spark 2.0, Scala 2.1.0
FilePath_3FADP4BJ5DM119777_1 <- '/FileStore/tables/ctihs8f51474399879780' # Data from 2015 - 2016, collected via Reference VI with Android phone by BlueTooth
FilePath_3FADP4BJ5DM119777_2 <- '/FileStore/tables/kmmptxmn1485673267130' # Data from January 2017, collected via C5 BT with SD card

df_3FADP4BJ5DM119777_1 <- read.df(FilePath_3FADP4BJ5DM119777_1, "json")
df_3FADP4BJ5DM119777_2 <- read.df(FilePath_3FADP4BJ5DM119777_2, "json")

# COMMAND ----------

# Add VIN to each dataframe (for future support of analysis with multiple vehicles)

# SEE this StackOverflow post: http://stackoverflow.com/questions/31589222/how-to-do-bind-two-dataframe-columns-in-sparkr
# withColumn() works when you're creating a new column involving a calculation of another existing column in the dataframe
#df_3FADP4BJ5DM119777_2 <- withColumn(df_3FADP4BJ5DM119777_2, "VIN", "3FADP4BJ5DM119777") # event???

# (POOR PERFORMANCE) approach:
# Create vector of VIN values, each the size of its corresponding Spark dataframe
VIN_1 = rep("3FADP4BJ5DM119777", times=count(df_3FADP4BJ5DM119777_1))
VIN_2 = rep("3FADP4BJ5DM119777", times=count(df_3FADP4BJ5DM119777_2))

# Create Spark dataframe from concatenated (ordered) vectors
VIN = as.DataFrame(data.frame(c(VIN_1, VIN_2)))
#DF2 <- merge(DF, VIN, all.x=FALSE, all.y=TRUE)
# Cartesian joins could be prohibitively expensive and are disabled by default. To explicitly enable them, please set spark.sql.crossJoin.enabled = true;

# COMMAND ----------

# Select specified columns from each dataframe
df_3FADP4BJ5DM119777_1 <- select(df_3FADP4BJ5DM119777_1, df_3FADP4BJ5DM119777_1$timestamp, df_3FADP4BJ5DM119777_1$name, df_3FADP4BJ5DM119777_1$event, df_3FADP4BJ5DM119777_1$value)

df_3FADP4BJ5DM119777_2 <- select(df_3FADP4BJ5DM119777_2, df_3FADP4BJ5DM119777_2$timestamp, df_3FADP4BJ5DM119777_2$name, df_3FADP4BJ5DM119777_2$event, df_3FADP4BJ5DM119777_2$value)

# concatenate all dataframes into one large dataframe
DF <- unionAll(df_3FADP4BJ5DM119777_1, df_3FADP4BJ5DM119777_2)
#count(df_3FADP4BJ5DM119777_1) # 7245978
#count(df_3FADP4BJ5DM119777_2) # 456 ########## TODO: fix issue with SD card files that causes only the first line of each to be read in
#count(DF) # 7246434

# COMMAND ----------

# Count of observations of each measurement
DF_counts <- count(groupBy(DF, DF$name))
display(arrange(DF_counts, desc(DF_counts$count)))

# COMMAND ----------

# Extract each measurement as a seperate dataframe
torque_at_transmission      <- filter(DF, DF$name == 'torque_at_transmission')
accelerator_pedal_position  <- filter(DF, DF$name == 'accelerator_pedal_position')
engine_speed                <- filter(DF, DF$name == 'engine_speed')
vehicle_speed               <- filter(DF, DF$name == 'vehicle_speed')
fuel_consumed_since_restart <- filter(DF, DF$name == 'fuel_consumed_since_restart')
steering_wheel_angle        <- filter(DF, DF$name == 'steering_wheel_angle')
odometer                    <- filter(DF, DF$name == 'odometer')
headlamp_status             <- filter(DF, DF$name == 'headlamp_status')
parking_brake_status        <- filter(DF, DF$name == 'parking_brake_status')
high_beam_status            <- filter(DF, DF$name == 'high_beam_status')
fuel_level                  <- filter(DF, DF$name == 'fuel_level')
transmission_gear_position  <- filter(DF, DF$name == 'transmission_gear_position')
brake_pedal_status          <- filter(DF, DF$name == 'brake_pedal_status')
ignition_status             <- filter(DF, DF$name == 'ignition_status')
windshield_wiper_status     <- filter(DF, DF$name == 'windshield_wiper_status')
longitude                   <- filter(DF, DF$name == 'longitude')
latitude                    <- filter(DF, DF$name == 'latitude')
door_status                 <- filter(DF, DF$name == 'door_status')

# COMMAND ----------

head(door_status, 30)

# COMMAND ----------

# Proportion of acceleration events where acceleration events were "harsh" - accelerator pedal position more than 50%
count(filter(accelerator_pedal_position, accelerator_pedal_position$value > 50)) / count(filter(accelerator_pedal_position, accelerator_pedal_position$value > 0))

# COMMAND ----------

display(filter(accelerator_pedal_position, accelerator_pedal_position$value > 50))

# COMMAND ----------

# trying to show date of timestamp https://spark.apache.org/docs/1.5.1/api/R/unix_timestamp.html
#A = withColumn(accelerator_pedal_position, "Date", to_date(as.integer(accelerator_pedal_position$timestamp))) ### ERRORS OUT
#head(A)

# COMMAND ----------


