# R with MySQL

This R code is meant to work with vehicle data from Ford's open-source OpenXC project (I have no affiliation with this group). 
Before using the code, you must either obtain a JSON drive trace file from the OpenXC web site (http://openxcplatform.com/resources/traces.html), or generate your own JSON trace files using a Reference VI. 

This R code was meant to allow use of R tools for further analysis.

## Benefit to Using MySQL

The aim for use with MySQL is to connect to your database, determine which drive trace files already have been read into the database, and read in only new files. Naturally, there are computational limits to this approach, so for larger amounts of data, an approach that uses parallel processing is ideal. To stay within R, one means of accomplishing this is with SparkR. 

# COMING SOON: SparkR Approach
