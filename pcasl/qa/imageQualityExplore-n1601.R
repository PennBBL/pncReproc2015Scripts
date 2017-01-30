# AFGR April 6 2016

##Usage##
# This script is going to be used to judge the pcasl data's quality
# Based on the output metrics of the xcpEngine asl module
# This script will only work for the n1601!

## Declare libraries
source("/home/arosen/adroseHelperScripts/R/afgrHelpFunc.R")
install_load('ANTsR', 'eVenn')

## Declare any functions to use here

# Now create and load the data
system('${XCPEDIR}/utils//qualityWrapper -d /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/pcasl/xcpFiles/pcasl_201607291423.dsn -S 3 -m "temporalSignalNoiseRatio relMeanRMSmotion" -M "30 0.5" -E "0 1"')
system("mv /data/joy/BBL/studies/pnc/processedData/pcasl/pcasl_201607291423/*csv /data/joy/BBL/projects/pncReproc2015/pcasl/QA/")
qa.scores <- read.csv('/data/joy/BBL/projects/pncReproc2015/pcasl/QA/pcasl_201606231423_groupLevelQuality.csv')
flag.scores <- read.csv('/data/joy/BBL/projects/pncReproc2015/pcasl/QA/pcasl_201606231423_groupLevelFlagStatus.csv')
flag.scores[,2] <- qa.scores[,2]
n.tr.data <- read.csv('/data/joy/BBL/projects/pncReproc2015/pcasl/QA/aslAllCohortTRInfo.csv', header=F)
n1601.subjs <- read.csv('/data/joy/BBL/projects/pncReproc2015/antsCT/n1601_bblid_scanid_dateid.csv')
## Now prepare our SS values 
system('/data/joy/BBL/applications/xcpEngine/utils/combineOutput -p /data/joy/BBL/studies/pnc/processedData/pcasl/pcasl_201607291423/ -f "JLFintersect_val_asl_quant_ssT1.1D" -o pcasl_JLFintersect_ssT1.1D')
system('mv /data/joy/BBL/studies/pnc/processedData/pcasl/pcasl_201607291423/pcasl_JLFintersect_ssT1.1D /data/joy/BBL/projects/pncReproc2015/pcasl/cbfValues/pcasl_20161202/')
# Now fix the column headers
tmp <- read.table('/data/joy/BBL/projects/pncReproc2015/pcasl/cbfValues/pcasl_20161202/pcasl_JLFintersect_ssT1.1D', header=T)
tmpCols <- read.csv('/data/joy/BBL/projects/pncReproc2015/pcasl/cbfValues/nameAssistFiles/columsOfInterest.csv')
tmp <- tmp[,tmpCols$x]
tmpNames <- read.csv('/data/joy/BBL/projects/pncReproc2015/pcasl/cbfValues/nameAssistFiles/pcaslJlfNames.csv')
tmpNames <- c('bblid', 'scanid', as.character(tmpNames$X))
colnames(tmp) <- tmpNames
tmp[,2] <- strSplitMatrixReturn(charactersToSplit=tmp[,2], splitCharacter='x')[,2]
write.csv(tmp, '/data/joy/BBL/projects/pncReproc2015/pcasl/cbfValues/pcasl_20161202/pcasl_JLF_ssT1-correctHeaders.csv', quote=F, row.names=F)
rm(tmp, tmpCols, tmpNames)
pcaslSSVals <- read.csv('/data/joy/BBL/projects/pncReproc2015/pcasl/cbfValues/pcasl_20161202/pcasl_JLF_ssT1-correctHeaders.csv')
n1601.data <- read.csv('/data/joy/BBL/studies/pnc/subjectData/n1601_go1_datarel_020716.csv')
n1601.pcasl.include <- read.csv('/data/joy/BBL/projects/pncReproc2015/pcasl/QA/n1601-QA/n1601_asl_acquired_incomplete_usable.csv')
n1601.t1.qa.data <- read.csv('/data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/t1struct/n1601_t1QaData.csv')
no.rps.map.1601 <- read.csv('/data/joy/BBL/projects/pncReproc2015/pcasl/QA/n1601-QA/noRps-n1601.csv', header=F)
all.mean.pcasl.values <- read.csv('/data/joy/BBL/projects/pncReproc2015/pcasl/cbfValues/pcasl_201607291423/meanCbfValues.csv')
file.paths <- read.table('/data/joy/BBL/projects/pncReproc2015/pcasl/cbfValues/pcasl_201607291423/jlfPcaslImages.txt', header=F)

# Now add the file.paths bblid and scanid
names(file.paths) <- 'pcaslImagePath'
file.paths$bblid <- strSplitMatrixReturn(file.paths[,1], '/')[,10]
file.paths$scanid <- strSplitMatrixReturn(strSplitMatrixReturn(file.paths[,1], '/')[,11], 'x')[,2]

# Now limit our data to just the 1601
n1601.ss.vals <- merge(n1601.subjs, pcaslSSVals, by=c('bblid', 'scanid'))
# Now combine all of our data
flag.scores$scanid <-strSplitMatrixReturn(flag.scores$subject.1.,'x')[,2]
colnames(flag.scores)[1:2] <- c('bblid', 'datexscanid')
qa.scores$scanid <-strSplitMatrixReturn(qa.scores$subject.1.,'x')[,2]
colnames(qa.scores)[1:2] <- c('bblid', 'datexscanid')
n1601.ss.vals <- merge(n1601.ss.vals, qa.scores, by=c('bblid', 'scanid'))
n1601.ss.vals <- merge(n1601.ss.vals, flag.scores, by=c('bblid', 'scanid'))
n1601.ss.vals$pcaslMeanGMValue <- all.mean.pcasl.values$meanPcaslValue[match(n1601.ss.vals$datexscanid.x, all.mean.pcasl.values$datexscanid.x)]
n1601.ss.vals$nTR <- n.tr.data$V4[match(n1601.ss.vals$datexscanid.y, n.tr.data$V2)]

#######
#######
## Coverage Mask ##
#######
#######
## Here I am going to be make a coverage mask across all 
## of the n1601 subjects w/ pcasl data
all.subj.id <- cbind(n1601.ss.vals$bblid, as.character(n1601.ss.vals$datexscanid.x))
write.csv(all.subj.id, '/data/joy/BBL/projects/pncReproc2015/pcasl/QA/n1601-QA/allSubjId.csv', quote=F, row.names=F)
#system("/bin/bash /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/pcasl/qa/combineImages.sh /data/joy/BBL/projects/pncReproc2015/pcasl/QA/n1601-QA/allSubjId.csv /data/joy/BBL/projects/pncReproc2015/pcasl/QA/n1601-QA/allSubjIdImageOrder")

## I now am going to find the optimal coverage to use based on the n1601 data and will 
## then check for voxel values for which to flag images that don't contain that value
# Load the 4-d time series 
four.d.time <- as.array(antsImageRead('/data/joy/BBL/projects/pncReproc2015/pcasl/QA/n1601-QA/allSubjIdImageOrder.nii.gz', dimension=4))

# Now I need to find for each subject if the voxel coordinate of interest is a 1 or 0
xCoord.a <- c(48, 57, 40, 48, 45, 30)
yCoord.a <- c(29, 74, 74, 27, 105, 68) 
zCoord.a <- c(29, 27, 27, 32, 33, 28)

# Now loop thourgh the 1657 images and find if our voxel of interest is a 1 or 0 
# Return the time points which have a 0 there
seqLength <- dim(four.d.time)[4]
outputFlagged <- NULL
for(val in seq(1,length(xCoord.a))){
  xCoord <- xCoord.a[val]
  yCoord <- yCoord.a[val]
  zCoord <- zCoord.a[val]
  for(i in seq(1,seqLength,1)){
    valueOfInterest <- four.d.time[xCoord, yCoord, zCoord, i]
    if(valueOfInterest == 0){
      outputFlagged <- append(outputFlagged, i)
    }  
  }
}
outputFlagged <- unique(outputFlagged)

# Now find which bblid's were flagged
imageLog <- read.table('/data/joy/BBL/projects/pncReproc2015/pcasl/QA/n1601-QA/normMasks/subjectOrderAll.txt', header=F)
imageLog$V1 <- as.character(imageLog$V1)
bblid.index <- strSplitMatrixReturn(imageLog$V1, '_')[,2]
datexscanid <- strSplitMatrixReturn(strSplitMatrixReturn(imageLog$V1, '_')[,3], '.nii.gz')
flagged.bblids <- bblid.index[outputFlagged]
flagged.dateid <- datexscanid[outputFlagged]

# Now combine all of our non flagged images
non.flagged.bblid <- bblid.index[-outputFlagged]
non.flagged.dateid <- datexscanid[-outputFlagged]
non.flagged.subj <- cbind(non.flagged.bblid, as.character(non.flagged.dateid))
write.csv(non.flagged.subj, '/data/joy/BBL/projects/pncReproc2015/pcasl/QA/n1601-QA/allNonFlagged-it1-SubjId.csv', quote=F, row.names=F)
#system("/bin/bash /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/pcasl/qa/combineImages.sh /data/joy/BBL/projects/pncReproc2015/pcasl/QA/n1601-QA/allNonFlagged-it1-SubjId.csv /data/joy/BBL/projects/pncReproc2015/pcasl/QA/n1601-QA/allNonFlaggeImage")

# I need to really quickly grab the bblid's from the subjects for whom I do not have RPS maps for


# Now attach the T1 qa data to the pcasl values - we want to rm any of the subjects that the T1 failed QA from the data
n1601.ss.vals <- merge(n1601.ss.vals, n1601.t1.qa.data, by=c('bblid', 'scanid'))


# Now create the coverage flag column
n1601.ss.vals$pcaslRpsMapCorrectionNotApplied <- rep(0, nrow(n1601.ss.vals))
n1601.ss.vals$pcaslRpsMapCorrectionNotApplied[match(no.rps.map.1601$V2, n1601.ss.vals$scanid)] <- 1
n1601.ss.vals$pcaslCoverageExclude <- rep(0, nrow(n1601.ss.vals))
n1601.ss.vals$pcaslCoverageExclude[match(flagged.dateid, n1601.ss.vals$datexscanid.x)] <- 1
n1601.ss.vals$pcaslExclude <- rep(0, nrow(n1601.ss.vals))
n1601.ss.vals$pcaslExclude[which(n1601.ss.vals$relMeanRMSmotion.y==1 |  n1601.ss.vals$temporalSignalNoiseRatio.y == 1 | n1601.ss.vals$nTR != 80)] <- 1
n1601.ss.vals$pcaslNVolumesAcquiredExclude <- rep(0, nrow(n1601.ss.vals))
n1601.ss.vals$pcaslNVolumesAcquiredExclude[which(n1601.ss.vals$nTR != 80)] <- 1
n1601.ss.vals$pcaslNoDataExclude <- rep(0, nrow(n1601.ss.vals))
n1601.ss.vals$pcaslMeanGMValueExclude <- rep(0, nrow(n1601.ss.vals))
n1601.ss.vals$pcaslVoxelwiseExclude <- rep(0, nrow(n1601.ss.vals))
n1601.ss.vals$pcaslVoxelwiseExclude[which(n1601.ss.vals$relMeanRMSmotion.y==1 |  n1601.ss.vals$temporalSignalNoiseRatio.y == 1 | n1601.ss.vals$nTR != 80 | n1601.ss.vals$pcaslCoverageExclude==1)] <- 1


# Now I can prep the output csv
pcaslValCols <- grep('pcasl_jlf_cbf', names(n1601.ss.vals))
attach(n1601.ss.vals)
#output <- cbind(bblid, scanid, pcaslExclude, t1Exclude, pcaslVoxelwiseCoverageExclude, 
#          relMeanRMSmotion.x, relMeanRMSmotion.y, 
#          temporalSignalNoiseRatio.x, temporalSignalNoiseRatio.y,
#          normCrossCorr.x,nTR, pcaslNVolumesAcquiredExclude, pcaslNoDataExclude,
#          pcaslMeanGMValue, pcaslRpsMapCorrectionNotApplied, pcaslMeanValueExclude ,n1601.ss.vals[,pcaslValCols])
#output <- cbind(bblid, scanid, pcaslExclude, pcaslVoxelwiseExclude, pcaslNoDataExclude, t1Exclude, 
#                relMeanRMSmotion.x, relMeanRMSmotion.y, temporalSignalNoiseRatio.x, temporalSignalNoiseRatio.y,
#                normCrossCorr.x, nTR, pcaslNVolumesAcquiredExclude, pcaslCoverageExclude, pcaslRpsMapCorrectionNotApplied, 
#                pcaslMeanGMValue, pcaslMeanGMValueExclude, n1601.ss.vals[,pcaslValCols])
imageingData <- cbind(bblid, scanid, n1601.ss.vals[,pcaslValCols]) 
qualityMetrics <- cbind(bblid, scanid, pcaslExclude, pcaslVoxelwiseExclude, pcaslNoDataExclude, 
                relMeanRMSmotion.x, relMeanRMSmotion.y, temporalSignalNoiseRatio.x, temporalSignalNoiseRatio.y,
                normCrossCorr.x, normCoverage.x, coregCrossCorr.x, coregCoverage.x, nTR, pcaslNVolumesAcquiredExclude, pcaslCoverageExclude, pcaslRpsMapCorrectionNotApplied, 
                pcaslMeanGMValue, pcaslMeanGMValueExclude)
detach(n1601.ss.vals)

## Now work with the quality data to prep the final output csv
output.df <- as.data.frame(qualityMetrics)
colnames(output.df) <- gsub(pattern='.x', replacement = '', x = colnames(output.df), fixed = TRUE)          
colnames(output.df) <- gsub(pattern='.y', replacement = 'Exclude', x = colnames(output.df), fixed = TRUE)  
names(output.df)[6:14] <- c('pcaslRelMeanRMSMotion', 'pcaslRelMeanRMSMotionExclude','pcaslTSNR', 'pcaslTSNRExclude',
                           'pcaslNormCrossCorr', 'pcaslNormCoverage', 'pcaslCoregCrossCorr', 'pcaslCoregCoverage', 'pcaslNVolumesAcquired')
output.df <- merge(output.df, file.paths, by=c('bblid', 'scanid'))
## Now I need to create rows for the subjects I do not have data for 
bblidToAdd <- n1601.subjs$bblid[which(n1601.subjs$bblid %in% output.df$bblid == 'FALSE')]
scanidToAdd <- n1601.subjs$scanid[which(n1601.subjs$scanid %in% output.df$scanid == 'FALSE')]
tmpToAdd <- as.data.frame(matrix(rep(NA, length(bblidToAdd) * (ncol(output.df)-2)), nrow=length(bblidToAdd), ncol=(ncol(output.df)-2)))
tmpToAdd <- cbind(bblidToAdd, scanidToAdd, tmpToAdd)
colnames(tmpToAdd) <- colnames(output.df)
output.df <- rbind(output.df, tmpToAdd)
# Now apply the mean GM value exclusion
output.df$pcaslExclude[which(output.df$pcaslMeanGMValue<15 & output.df$pcaslExclude==0)] <- 1
n1601.ss.vals$pcaslVoxelwiseExclude[which(output.df$pcaslMeanGMValue<15)] <- 1
output.df$pcaslMeanGMValueExclude[which(output.df$pcaslMeanGMValue<15)] <- 1
# Now I need to change all of the NA's to either 0's or 1's in the QA files
output.df$pcaslExclude[which(is.na(output.df$pcaslExclude)=='TRUE')] <- 1
output.df$pcaslVoxelwiseExclude[which(is.na(output.df$pcaslVoxelwiseExclude)=='TRUE')] <- 1
output.df$pcaslNoDataExclude[which(is.na(output.df$pcaslNoDataExclude)=='TRUE')] <- 1
output.df <- output.df[,-20]

write.csv(output.df, '/data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/asl/n1601_PcaslQaData.csv', quote=F, row.names=F)
qaData <- output.df

## Now work with the imaging data here
output.df <- imageingData
# Now I need to rm the cerebellum, whitematter, the optic chiasm, and the 
# ventral DC areas from the cbf values
namesToRm <- c('Ventricle', 'Cerebellum', 'White', 'CSF', 'Vent', 'Vessel', 
               'Ventral_DC', 'OpticChiasm', 'CerVerLob', 'BasForebr', 'Brain_Stem',
               'WM', 'fornix', 'antlimb_InC', 'postlimbcerebr', 'corpus_callosum')
colsToRm <- NULL
# Now go through a loop and grep the columns that we need to rm
# and append those values to the colsToRm variable
for(value in namesToRm){
  valuesToRm <- grep(value, names(output.df))
  colsToRm <- append(colsToRm, valuesToRm)
}

output.df <- output.df[,-colsToRm]
output.df[output.df<0] <- 'NA'

# and now append the extra subjects 
bblidToAdd <- n1601.subjs$bblid[which(n1601.subjs$bblid %in% output.df$bblid == 'FALSE')]
scanidToAdd <- n1601.subjs$scanid[which(n1601.subjs$scanid %in% output.df$scanid == 'FALSE')]
tmpToAdd <- as.data.frame(matrix(rep(NA, length(bblidToAdd) * (ncol(output.df)-2)), nrow=length(bblidToAdd), ncol=(ncol(output.df)-2)))
tmpToAdd <- cbind(bblidToAdd, scanidToAdd, tmpToAdd)
colnames(tmpToAdd) <- colnames(output.df)
output.df <- rbind(output.df, tmpToAdd)


write.csv(output.df, '/data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/asl/n1601_jlfAntsCTIntersectionPcaslValues.csv', quote=F, row.names=F)

# Now lets produce our venn diagram for those subjects that were flagged for removal
excludeCols <- grep('Exclude', names(qaData))
excludeCols <- excludeCols[-c(1,2,3)]
matrixValues <- qaData[which(output.df$pcaslVoxelwiseExclude==1),excludeCols]
matrixValues <- as.matrix(matrixValues)
evenn(matLists=matrixValues, pathRes='/data/joy/BBL/projects/pncReproc2015/pcasl/QA/n1601-QA/')
