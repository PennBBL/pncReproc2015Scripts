# AFGR April 6 2016

##Usage##
# This script is going to be used to judge the pcasl data's quality
# Based on the output metrics of the xcpEngine asl module

## Declare libraries
source("/home/arosen/R/x86_64-unknown-linux-gnu-library/helperFunctions/afgrHelpFunc.R")

## Declare any functions to use here

## Load the data here
new.qa.metrics <- read.csv('/data/joy/BBL/projects/pncReproc2015/pcasl/qa/data/allQualityWScanId.csv')
all.data <- read.csv('/data/joy/BBL/projects/pncReproc2015/pcasl/qa/data/n1601_go1_datarel_020716.csv')
merged.df <- merge(all.data, new.qa.metrics, by='scanid')

## Now first lets plot all of the new image metrics as histograms
pdf('/data/joy/BBL/projects/pncReproc2015/pcasl/qa/reports/xcpEngineQAMetrics.pdf')

