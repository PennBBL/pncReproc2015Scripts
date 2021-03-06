#!/usr/bin/env Rscript

###################################################################
#  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  ☭  #
###################################################################

###################################################################
# Merge the extant data frames
###################################################################

data <- read.csv('/data/joy/BBL/studies/pnc/subjectData/n1601_go1_datarel_020716.csv')
xcp <- read.csv('/data/joy/BBL/projects/pncReproc2015/restbold/quality/REST_XCP.csv')
b0 <- read.csv('/data/joy/BBL/projects/pncReproc2015/restbold/quality/B0MAPCORRECTION.csv')
coverage <- read.csv('/data/joy/BBL/projects/pncReproc2015/restbold/quality/REST_COVERAGE_PROCESSED.csv')
data0 <- merge(data,coverage,by='scanid',all.x=T)
data1 <- merge(data0,b0,by='scanid',all.x=T)
data2 <- merge(data1,xcp,by='scanid',all.x=T)

###################################################################
# Determine exclusion criteria
###################################################################
data2$restMeanRelRMSMotionExclude <- as.numeric(data2$relMeanRMSmotion > 0.2)
data2$restNSpikesMotionExclude <- as.numeric(data2$nframesHighMotionrms0.25 > 20)

data2$restExclude <- as.numeric(!data2$restAcquired | data2$restMeanRelRMSMotionExclude | data2$restNSpikesMotionExclude)
data2$restExcludeVoxelwise <- as.numeric(!data2$restAcquired | data2$restMeanRelRMSMotionExclude | data2$restNSpikesMotionExclude | !data2$restVoxelwiseCoverageInclude)

###################################################################
# Generate the final quality file.
###################################################################

restQA <- data.frame(
   bblid=data2$bblid.x,
   scanid=data2$scanid,
   restExclude=data2$restExclude,
   restExcludeVoxelwise=data2$restExcludeVoxelwise,
   restNoDataExclude=as.numeric(!data2$restAcquired),
   restRelMeanRMSMotion=data2$relMeanRMSmotion,
   restRelMeanRMSMotionExclude=data2$restMeanRelRMSMotionExclude,
   restNSpikesMotion=data2$nframesHighMotionrms0.25,
   restNSpikesMotionExclude=data2$restNSpikesMotionExclude,
   restNormCrossCorr=data2$normCrossCorr,
   restNormCoverage=data2$normCoverage,
   restCoregCrossCorr=data2$coregCrossCorr,
   restCoregCoverage=data2$coregCoverage,
   restVoxelwiseCoverageExclude=!data2$restVoxelwiseCoverageInclude,
   restRpsMapCorrectionNotApplied=data2$B0MapUsable
)

newSeq=c(7287,7288,7289,7296,7297,7298,7308,7315)
for (i in newSeq) {
   restQA$restNoDataExclude[which(data2$scanid==i)] = 0
}

write.csv(restQA,'/data/joy/BBL/projects/pncReproc2015/restbold/quality/REST_QA.csv',row.names=F)

###################################################################
# Generate a Venn partition.
###################################################################
require(limma)
qux <- data.frame(
   restQA$restNoDataExclude,
   restQA$restVoxelwiseCoverageExclude,
   restQA$restNSpikesMotionExclude,
   restQA$restRelMeanRMSMotionExclude
)
baz <- vennCounts(qux)
baz <- baz[baz[,5]!=0,]
write.csv(baz,'/data/joy/BBL/projects/pncReproc2015/restbold/quality/vennDiagram.csv')
