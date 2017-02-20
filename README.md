# R with MySQL

This R code is meant to work with vehicle data from Ford's open-source OpenXC project (I have no affiliation with this group). 
Before using the code, you must either obtain a JSON drive trace file from the OpenXC web site (http://openxcplatform.com/resources/traces.html), or generate your own JSON trace files using a Reference VI. 

This R code was meant to allow use of R tools for further analysis.

## Benefit to Using MySQL

The aim for use with MySQL is to connect to your database, determine which drive trace files already have been read into the database, and read in only new files. Naturally, there are computational limits to this approach, so for larger amounts of data, an approach that uses parallel processing is ideal. To stay within R, one means of accomplishing this is with SparkR. 

# R with MongoDB
MongoDB is a NoSQL database that can be useful for working with unstructured big data (in MongoDB you can run commands for MapReduce jobs, etc.). NoSQL could prove useful if, for example, you want to store OpenXC trace files as documents run a query to determine which ones contain some variable, e.g. "ethanol_fuel_percentage" to isolate all of the flex-fuel vehicles in your analysis and also query the metadata (see the below example) associated with the trace files as in the [OpenXC Message Format Specification](https://github.com/openxc/openxc-message-format#trace-file-format).

```
{"metadata": {
    "version": "v7.2.0",
    "vehicle_interface_id": "7ABF",
    "vehicle": {
        "make": "Ford",
        "model": "Focus",
        "trim": "SFE",
        "year": 2016
    },
    "description": "filling up with E85 Ethanol",
    "driver_name": "Myself",
    "vehicle_id": "1FADP3K27GL286098"
}
```

The R-MongoDB program offers an approach to interfacing between MongoDB and R. Note, other programs (e.g. Python, etc.) may allow more options in interfacing with MongoDB, but as with the R-MySQL file, the R-MongoDB file offers a way to take advantage of R for analyzing data. 

# SparkR Approach
This code was used on Databricks after uploading drive trace files. The code is currently a rough draft and is meant to offer an R alternative to a PySpark approach (e.g. similar to the SMS Taxi dashboard and another program in development) - updates coming soon! 
