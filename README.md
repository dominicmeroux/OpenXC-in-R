# R with MySQL

This R code is meant to work with vehicle data from Ford's open-source OpenXC project (I have no affiliation with this group). 
Before using the code, you must either obtain a JSON drive trace file from the OpenXC web site (http://openxcplatform.com/resources/traces.html), or generate your own JSON trace files using a Reference VI. 

This R code was meant to allow use of R tools for further analysis.

## Benefit to Using MySQL

The aim for use with MySQL is to connect to your database, determine which drive trace files already have been read into the database, and read in only new files. Naturally, there are computational limits to this approach, so for larger amounts of data, an approach that uses parallel processing is ideal. To stay within R, one means of accomplishing this is with SparkR. 

# R with MongoDB
MongoDB is a NoSQL database that can be useful for working with big data (using MapReduce jobs, etc.), so this file offers an approach to interfacing between MongoDB and R. Note, other programs (e.g. Python, etc.) may allow more options in interfacing with MongoDB, but as with the R-MySQL file, the R-MongoDB file offers a way to take advantage of R for analyzing data. 

# SparkR Approach
This code was used on Databricks after uploading drive trace files. The code is currently a very rough draft - updates coming soon!
