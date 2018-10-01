#!/usr/bin/env Rscript

###################################################################
#  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  #
###################################################################

###################################################################
# Merge the extant data frames
###################################################################

data <- read.csv('/data/joy/BBL/studies/pnc/subjectData/n1601_go1_datarel_020716.csv')
xcp <- read.csv('/data/joy/BBL/projects/pncReproc2015/nback/quality/NBACK_XCP.csv')
b0 <- read.csv('/data/joy/BBL/projects/pncReproc2015/nback/quality/B0MAPCORRECTION.csv')
maxRelRMS <- read.csv('/data/joy/BBL/projects/pncReproc2015/nback/quality/RELRMS.csv')
activation <- read.csv('/data/joy/BBL/projects/pncReproc2015/nback/quality/ACTIVATION.csv')
coverage <- read.csv('/data/joy/BBL/projects/pncReproc2015/nback/quality/NBACK_COVERAGE_PROCESSED2416.csv')
data8 <- merge(data,coverage,by='scanid',all.x=T)
data9 <- merge(data8,b0,by='scanid',all.x=T)
data0 <- merge(data9,xcp,by='scanid',all.x=T)
data1 <- merge(data0,maxRelRMS,by='scanid',all.x=T)
data2 <- merge(data1,activation,by='scanid',all.x=T)

###################################################################
# Determine exclusion criteria
###################################################################
data2$nbackMeanRelRMSMotionExclude <- as.numeric(data2$rel_mean_rms_motion > 0.5)
data2$nbackMaxRelRMSMotionExclude <- as.numeric(data2$nbackMaxRelRMS > 6)

data2$nbackExclude <- as.numeric(!data2$nbackProtocolValidationStatus  | data2$nbackMeanRelRMSMotionExclude | data2$nbackMaxRelRMSMotionExclude | data2$nbackMeanActivationExclude)
data2$nbackExcludeVoxelwise <- as.numeric(!data2$nbackProtocolValidationStatus | data2$nbackMeanRelRMSMotionExclude | data2$nbackMaxRelRMSMotionExclude | data2$nbackMeanActivationExclude && !data2$nbackVoxelwiseCoverageInclude)

###################################################################
# Generate the final quality file.
###################################################################

nbackQA <- data.frame(
   bblid=data2$bblid.x,
   scanid=data2$scanid,
   nbackExclude=data2$nbackExclude,
   nbackExcludeVoxelwise=data2$nbackExcludeVoxelwise,
   nbackNoDataExclude=as.numeric(!data2$nbackProtocolValidationStatus) ,
   nbackRelMeanRMSMotion=data2$rel_mean_rms_motion,
   nbackRelMeanRMSMotionExclude=data2$nbackMeanRelRMSMotionExclude,
   nbackRelMaxRMSMotion=data2$nbackMaxRelRMS,
   nbackRelMaxRMSMotionExclude=data2$nbackMaxRelRMSMotionExclude,
   nbackNormCrossCorr=data2$normCrossCorr,
   nbackNormCoverage=data2$normCoverage,
   nbackCoregCrossCorr=data2$coregCrossCorr,
   nbackCoregCoverage=data2$coregCoverage,
   nbackVoxelwiseCoverageExclude=as.numeric(!data2$nbackVoxelwiseCoverageInclude),
   nbackMeanActivationExclude=data2$nbackMeanActivationExclude,
   nbackRpsMapCorrectionNotApplied=data2$B0MapUsable
)

write.csv(nbackQA,'/data/joy/BBL/projects/pncReproc2015/nback/quality/NBACK_QA_1601.csv',row.names=F)

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
write.csv(baz,'/data/joy/BBL/projects/pncReproc2015/nback/quality/vennDiagram1601.csv')
