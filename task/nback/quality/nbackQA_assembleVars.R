#!/usr/bin/env Rscript

###################################################################
#  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  #
###################################################################

###################################################################
# Merge the extant data frames
###################################################################

data <- read.csv('/data/joy/BBL/studies/pnc/subjectData/n1601_go1_datarel_020716.csv')
xcp <- read.csv('/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/task/nback/quality/NBACK_XCP.csv')
maxRelRMS <- read.csv('RELRMS.csv')
activation <- read.csv('ACTIVATION.csv')
coverage <- read.csv('NBACK_COVERAGE_PROCESSED.csv')
data9 <- merge(data,coverage,by='scanid')
data0 <- merge(data9,xcp,by='scanid')
data1 <- merge(data0,maxRelRMS,by='scanid')
data2 <- merge(data1,activation,by='scanid')
nbackQA <- data.frame(bblid=data2$bblid.x,scanid=data2$scanid,nbackNoDataExclude=data2$nbackMissingDataExclude,nbackZerobackNrExclude=data2$nbackZerobackNrExclude,nbackIncompleteBehavioralExclude=data2$nbackIncompleteBehavioralExclude,nbackMaxRelRMS=data2$nbackMaxRelRMS,nbackMeanRelRMS=data2$rel_mean_rms_motion,nbackVoxelwiseCoverageExclude=!data2$nbackVoxelwiseCoverageInclude,nbackMeanActivationExclude=data2$nbackMeanActivationExclude)
nbackQA <- nbackQA[nbackQA$nbackNoDataExclude==0,]

###################################################################
# Determine exclusion criteria
###################################################################
nbackQA$nbackMeanRelRMSMotionExclude <- as.numeric(nbackQA$nbackMeanRelRMS > 0.5)
nbackQA$nbackMaxRelRMSMotionExclude <- as.numeric(nbackQA$nbackMaxRelRMS > 6)

nbackQA$nbackExclude <- as.numeric(nbackQA$nbackNoDataExclude | nbackQA$nbackZerobackNrExclude | nbackQA$nbackIncompleteBehavioralExclude | nbackQA$nbackMeanRelRMSMotionExclude | nbackQA$nbackMaxRelRMSMotionExclude | nbackQA$nbackMeanActivationExclude)
nbackQA$nbackExcludeVoxelwise <- as.numeric(nbackQA$nbackNoDataExclude | nbackQA$nbackZerobackNrExclude | nbackQA$nbackIncompleteBehavioralExclude | nbackQA$nbackMeanRelRMSMotionExclude | nbackQA$nbackMaxRelRMSMotionExclude | nbackQA$nbackMeanActivationExclude | nbackQA$nbackVoxelwiseCoverageExclude)

write.csv(nbackQA,'NBACK_QA.csv',row.names=F)

###################################################################
# Generate a Venn partition.
###################################################################
require(limma)
qux <- data.frame(nbackQA$nbackNoDataExclude,nbackQA$nbackZerobackNrExclude,nbackQA$nbackIncompleteBehavioralExclude,nbackQA$nbackVoxelwiseCoverageExclude,nbackQA$nbackMeanActivationExclude,nbackQA$nbackMaxRelRMSMotionExclude,nbackQA$nbackMeanRelRMSMotionExclude)
baz <- vennCounts(qux)
baz <- baz[baz[,8]!=0,]
write.csv(baz,'vennDiagram.csv')
write.csv(baz,'vennDiagram.csv')
