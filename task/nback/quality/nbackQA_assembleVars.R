#!/usr/bin/env Rscript

###################################################################
#  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  #
###################################################################

###################################################################
# Merge the extant data frames
###################################################################

data1 <- read.csv('/data/joy/BBL/studies/pnc/subjectData/n1601_go1_datarel_020716.csv')
xcp <- read.csv('/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts_mv_20161007/task/nback/quality/NBACK_XCP.csv')
b0 <- read.csv('/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/dico/n1601_b0map_nos.csv')
maxRelRMS <- read.csv('/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts_mv_20161007/task/nback/quality/RELRMS.csv')
activation <- read.csv('/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts_mv_20161007/task/nback/quality/ACTIVATION.csv')
coverage <- read.csv('/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts_mv_20161007/task/nback/quality/NBACK_COVERAGE_PROCESSED.csv')
data2 <- merge(data1,coverage,by='scanid')
data2 <- merge(data2,b0,by='scanid')
data2 <- merge(data2,xcp,by='scanid')
data2 <- merge(data2,maxRelRMS,by='scanid')
data2 <- merge(data2,activation,by='scanid')

###################################################################
# Determine exclusion criteria
###################################################################
data2$nbackMeanRelRMSMotionExclude <- as.numeric(data2$rel_mean_rms_motion > 0.5)
data2$nbackMaxRelRMSMotionExclude <- as.numeric(data2$nbackMaxRelRMS > 6)

data2$nbackExclude <- as.numeric(data2$nbackMissingDataExclude | data2$nbackMeanRelRMSMotionExclude | data2$nbackMaxRelRMSMotionExclude | data2$nbackMeanActivationExclude)
data2$nbackExcludeVoxelwise <- as.numeric(data2$nbackMissingDataExclude | data2$nbackMeanRelRMSMotionExclude | data2$nbackMaxRelRMSMotionExclude | data2$nbackMeanActivationExclude | !data2$nbackVoxelwiseCoverageExclude)

###################################################################
# Generate the final quality file.
###################################################################

nbackQA <- data.frame(
   bblid=data2$bblid.x,
   scanid=data2$scanid,
   nbackExclude=data2$nbackExclude,
   nbackExcludeVoxelwise=data2$nbackExcludeVoxelwise,
   nbackNoDataExclude=data2$nbackMissingDataExclude,
   nbackRelMeanRMSMotion=data2$rel_mean_rms_motion,
   nbackRelMeanRMSMotionExclude=data2$nbackMeanRelRMSMotionExclude,
   nbackRelMaxRMSMotion=data2$nbackMaxRelRMS,
   nbackRelMaxRMSMotionExclude=data2$nbackMaxRelRMSMotionExclude,
   nbackNormCrossCorr=data2$normCrossCorr,
   nbackNormCoverage=data2$normCoverage,
   nbackCoregCrossCorr=data2$coregCrossCorr,
   nbackCoregCoverage=data2$coregCoverage,
   nbackVoxelwiseCoverageExclude=!data2$nbackVoxelwiseCoverageExclude,
   nbackMeanActivationExclude=data2$nbackMeanActivationExclude,
   nbackRpsMapCorrectionNotApplied=data2$B0MapUsable
)

write.csv(nbackQA,'NBACK_QA.csv',row.names=F)

###################################################################
# Generate a Venn partition.
###################################################################
require(limma)
qux <- data.frame(
   nbackQA$nbackNoDataExclude,
   nbackQA$nbackVoxelwiseCoverageExclude,
   nbackQA$nbackMeanActivationExclude,
   nbackQA$nbackRelMaxRMSMotionExclude,
   nbackQA$nbackRelMeanRMSMotionExclude
)
baz <- vennCounts(qux)
baz <- baz[baz[,6]!=0,]
write.csv(baz,'vennDiagram.csv')
