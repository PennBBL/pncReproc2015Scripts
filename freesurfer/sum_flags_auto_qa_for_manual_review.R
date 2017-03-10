#MQ March 10, 2017

#This script takes the Flag Outliers csv and Euler number flags output from 
#/home/mquarmley/pncReproc2015Scripts/freesurfer/cnr_euler_qa_go1_apply.R and
#/home/mquarmley/pncReproc2015Scripts/freesurfer/flag_outliers_go1_apply.R
#for GO Freesurfer version 5.3 reprocessing and does the following:
### 1) merges the files into an aggregate qa file
### 2) calculates an overall "flagged" column which is a binary 1 (flagged) or 0 (not flagged) based on QA metrics
### 3) outputs a csv of images that need to be manually reviewed (note: if this is for a larger sample such as n2416, many of the 
#subjects flagged for manual QA review have most likely already been reviewed, so make sure to compare to existing qa)

#load libraries
library(ggplot2)

##################
###### ARGS ######
##################
output.dir<-commandArgs(TRUE)[1]
#output.dir<-"/data/joy/BBL/projects/pncReproc2015/freesurfer/stats5_3"
subjnum<-commandArgs(TRUE)[2]
#subjnum<-"n1601"
go1_flag<-read.csv(commandArgs(TRUE)[3])
#go1_flag<-read.csv("/data/joy/BBL/projects/pncReproc2015/freesurfer/stats5_3/all.flags.go1.based.n1601.csv")
euler_flag<-read.csv(commandArgs(TRUE)[4])
#euler_flag<-read.csv("/data/joy/BBL/projects/pncReproc2015/freesurfer/stats5_3/cnr_euler_flags_go1_based_n1601.csv")
t1_qa<- read.csv(commandArgs(TRUE)[5])
#t1_qa<-read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/t1struct/n1601_t1QaData_20170306.csv")

##################
### DATA PREP ####
##################

#create flags datasheet which gets all the columns which should be included in the automatic QA flagging sum
#Note: this is excluding the columns of: meanthickness, totalarea, cnr,snr SubCortGayVol, CortexVol, CorticalWhiteMatterVol, noutliers.thickness.rois, noutliers.lat.thickness.rois, 
#and crn_outlier (since we use the CNR values from the euler script)
flags<- go1_flag[,c(1:2,12:16,18:20)]

#merge in the euler number columns (gray/white cnr, gray/csf cnr, euler number)
flags$graycsf_flag<- euler_flag$graycsf_flag[match(flags$scanid,euler_flag$scanid)]
flags$graywhite_flag<- euler_flag$graywhite_flag[match(flags$scanid,euler_flag$scanid)]
flags$euler_flag<- euler_flag$euler_flag[match(flags$scanid,euler_flag$scanid)]


##################
### SUM FLAGS ####
##################


#create summary column that gets a sum of the flags in this csv
flags$total_outliers<- rowSums(flags[,3:13])

#create column that gets a binary 1 (flagged) or 0 (not flagged) if the subject is flagged or not
flags$fsFlag<- "NA"
flags$fsFlag[which(flags$total_outliers==0)]<- "0"
flags$fsFlag[which(flags$total_outliers>0)]<- "1"

#create subset csv that is only images that need to be manually reviewed (i.e. they failed FS QA but passed T1Exclude)
#manual_fs_review<- flags
#manual_fs_review$scanid_short<- substring(manual_fs_review$scanid,10,100)
#manual_fs_review<- manual_fs_review[manual_fs_review$fsFlag=="1",]
#manual_fs_review$t1exclude<- t1_qa$t1Exclude[match(manual_fs_review$scanid_short,t1_qa$scanid)]
#manual_fs_review<- manual_fs_review[manual_fs_review$t1exclude==0,]

#get rid of datexscanid so can share the csv
#manual_fs_review$scanid<- manual_fs_review$scanid_short
#manual_fs_review<- manual_fs_review[,c(1:15,17)]


##################
### OUTPUT DATA ##
##################

write.csv(flags, file.path(output.dir, paste('auto.qa.summary.flags.go1.based.' , subjnum,'.csv', sep='')), quote=FALSE, row.names=FALSE)
cat('wrote file to', file.path(output.dir, paste('auto.qa.summary.flags.go1.based.' , subjnum,'.csv', sep='')), '\n')

#write.csv(manual_fs_review, file.path(output.dir, paste('list.for.manual.review.go1.based.' , subjnum,'.csv', sep='')), quote=FALSE, row.names=FALSE)
#cat('wrote file to', file.path(output.dir, paste('list.for.manual.review.go1.based.' , subjnum,'.csv', sep='')), '\n')

