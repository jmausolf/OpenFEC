#!/usr/bin/env bash

#log files
mkdir -p logs
mv *.log logs 2>/dev/null


#download data
mkdir -p downloads
mv *.csv downloads 2>/dev/null


#data for analysis
mkdir -p data
#copy final files over to data