---
title: "Selecting Subjects for PNC Template"
author: "BBL, et al"
date: "April 13, 2016"
output: pdf_document
---

*Identifying Outliers for GMD and CT Data*
=========================


The goal here is to identify data points which may not be trusworthy for the CT and GMD data.

Data was produced via the antsCT pipeline and afgr's GMD and CT post processing script
all scripts can be found @ /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/antsCT

Data for this project exists in:

/data/joy/BBL/projects/pncReproc2015/antsCT

_Strategy is as follows:_

1.) Identify outliers from the quality file
2.) Identify outliers from the GMD and CT data points
3.) Each previous step will be given a binary output the third step will sum those prior outputs

## Load the data
gmd.data <- read.table('/data/joy/BBL/projects/pncReproc2015/antsCT/antsGMD.1D', header=T)
ct.data <- read.table('/data/joy/BBL/projects/pncReproc2015/antsCT/antsCT.1D', header=T)
quality.data <- read.csv('/data/joy/BBL/projects/pncReproc2015/antsCT/normQuality.csv')
go.one.data <- read.csv('/data/joy/BBL/projects/pncReproc2015/antsCT/go1BblidAndScanid.csv')

## I am actually going to put all of this on hold because I am not sure how we are going to QA this data - 
## I am just now going to create a n1601 csv for the gmd and ct and qaulity values

## Start by merging the data
merge.data <- merge(gmd.data, ct.data, by='subject.1.')
merge.data <- merge(merge.data, quality.data, by='subject.1.')

## Now seperate the date and scan id's
str.split.output <- strsplit(as.character(merge.data$subject.1.), split='x')
scanid <- matrix(unlist(str.split.output),nrow=nrow(merge.data), byrow=T)[,2]
dateid <- matrix(unlist(str.split.output),nrow=nrow(merge.data), byrow=T)[,1]
bblid <- merge.data$subject.0.
output <- cbind(scanid, dateid, bblid, merge.data)
cols.to.rm <- grep('subject', names(output))
output <- output[,-cols.to.rm]

go.one.data <- merge(go.one.data, output, by='scanid')
colnames(go.one.data)[2] <- 'bblid'
output <- go.one.data[,-4]

write.csv(output, '/data/joy/BBL/projects/pncReproc2015/antsCT/n1601_gmd_ct_normCoverage_data.csv', quote=F, row.names=F)
