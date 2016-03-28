# R-MySQL_OpenXC_data

This R code is meant to work with vehicle data from Ford's open-source OpenXC project (I have no affiliation with this group). 
Before using the code, you must either obtain a JSON drive trace file from the OpenXC web site (http://openxcplatform.com/resources/traces.html), or generate your own JSON trace files using a Reference VI. 

The OpenXC project offers Python code that more efficiently reads in data and offers visualizations - this R code was meant to allow use of R tools for further analysis, as well as connection with a MySQL database for storing and working with larger numbers of trace files. 
