# AFGR April 6 2016

##Usage##
# This script is going to be used to judge the pcasl data's quality
# Based on the output metrics of the xcpEngine asl module
# This script will only work for the n1601!

## Declare libraries
source("/home/arosen/adroseHelperScripts/R/afgrHelpFunc.R")
install_load('ANTsR')

## Declare any functions to use here
# Declare a function which will tell us if binary matrix A is entierly 
# contained within binary matrix B
checkIntersect <- function(binaryMatrixToInclude, binaryMatrixToTest, coverageThreshold){
  # First prime the output
  output <- "TRUE"
  # First get an index for all of the 1 values for the mask to include
  includeIndex <- which(binaryMatrixToInclude == 1)
  # Now do the same for the mask to test 
  testIndex <- which(binaryMatrixToTest == 1)
  # Now Subtract test - include and check for negative values 
  matchingIndex <- (includeIndex %in% testIndex)
  # Now check for any False values
  if(identical(names(table(matchingIndex)[1]), "FALSE")){
    # Now lets check to see if we meet the threshold
    # First lets find the length that would exceed our threshold
    excludeLength <- floor(length(includeIndex) * coverageThreshold)
    # Now test to see if we exceed that
    if(unname(table(matchingIndex)[1]) > excludeLength){
      output <- "FALSE"
    }
  }
  return(output)
}


# Now create and load the data
system('${XCPEDIR}/utils//qualityWrapper -d /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/pcasl/xcpFiles/pcasl_20160729/pcasl_201606231423.dsn -S 3 -m "temporalSignalNoiseRatio relMeanRMSmotion" -M "30 0.5" -E "0 1"')
system("mv /data/joy/BBL/studies/pnc/processedData/pcasl/pcasl_201607291423/*csv /data/joy/BBL/projects/pncReproc2015/pcasl/QA/")
qa.scores <- read.csv('/data/joy/BBL/projects/pncReproc2015/pcasl/QA/pcasl_201606231423_groupLevelQuality.csv')
flag.scores <- read.csv('/data/joy/BBL/projects/pncReproc2015/pcasl/QA/pcasl_201606231423_groupLevelFlagStatus.csv')
flag.scores[,2] <- qa.scores[,2]
n.tr.data <- read.csv('/data/joy/BBL/projects/pncReproc2015/pcasl/QA/aslAllCohortTRInfo.csv', header=F)
n1601.subjs <- read.csv('/data/joy/BBL/projects/pncReproc2015/antsCT/n1601_bblid_scanid_dateid.csv')
pcaslSSVals <- read.csv('/data/joy/BBL/projects/pncReproc2015/pcasl/cbfValues/pcasl_201607291423/pcasl_JLF_ssT1-correctHeaders.csv')
pcaslSTDVals <- read.csv('/data/joy/BBL/projects/pncReproc2015/pcasl/cbfValues/pcasl_201607291423/pcasl_JLF_stdT1-correctHeaders.csv')
n1601.data <- read.csv('/data/joy/BBL/studies/pnc/subjectData/n1601_go1_datarel_020716.csv')
n1601.pcasl.include <- read.csv('/data/joy/BBL/projects/pncReproc2015/pcasl/QA/n1601-QA/n1601_asl_acquired_incomplete_usable.csv')
n1601.t1.qa.data <- read.csv('/data/joy/BBL/studies/pnc/summaryData_n1601_20160823/n1601_t1QaData.csv')
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
n1601.ss.vals$pcaslExclude[which(n1601.ss.vals$relMeanRMSmotion.y==1 |  n1601.ss.vals$temporalSignalNoiseRatio.y == 1 | n1601.ss.vals$nTR != 80 | n1601.ss.vals$t1Exclude==1)] <- 1
n1601.ss.vals$pcaslNVolumesAcquiredExclude <- rep(0, nrow(n1601.ss.vals))
n1601.ss.vals$pcaslNVolumesAcquiredExclude[which(n1601.ss.vals$nTR != 80)] <- 1
n1601.ss.vals$pcaslNoDataExclude <- rep(0, nrow(n1601.ss.vals))
n1601.ss.vals$pcaslMeanGMValueExclude <- rep(0, nrow(n1601.ss.vals))
n1601.ss.vals$pcaslVoxelwiseExclude <- rep(0, nrow(n1601.ss.vals))
n1601.ss.vals$pcaslVoxelwiseExclude[which(n1601.ss.vals$relMeanRMSmotion.y==1 |  n1601.ss.vals$temporalSignalNoiseRatio.y == 1 | n1601.ss.vals$nTR != 80 | n1601.ss.vals$t1Exclude==1 | n1601.ss.vals$pcaslCoverageExclude==1)] <- 1


# Now I can prep the output csv
pcaslValCols <- grep('pcasl_jlf_cbf', names(n1601.ss.vals))
attach(n1601.ss.vals)
#output <- cbind(bblid, scanid, pcaslExclude, t1Exclude, pcaslVoxelwiseCoverageExclude, 
#          relMeanRMSmotion.x, relMeanRMSmotion.y, 
#          temporalSignalNoiseRatio.x, temporalSignalNoiseRatio.y,
#          normCrossCorr.x,nTR, pcaslNVolumesAcquiredExclude, pcaslNoDataExclude,
#          pcaslMeanGMValue, pcaslRpsMapCorrectionNotApplied, pcaslMeanValueExclude ,n1601.ss.vals[,pcaslValCols])
output <- cbind(bblid, scanid, pcaslExclude, pcaslVoxelwiseExclude, pcaslNoDataExclude, t1Exclude, 
                relMeanRMSmotion.x, relMeanRMSmotion.y, temporalSignalNoiseRatio.x, temporalSignalNoiseRatio.y,
                normCrossCorr.x, nTR, pcaslNVolumesAcquiredExclude, pcaslCoverageExclude, pcaslRpsMapCorrectionNotApplied, 
                pcaslMeanGMValue, pcaslMeanGMValueExclude, n1601.ss.vals[,pcaslValCols])
detach(n1601.ss.vals)

# Now change all of the column names ending in .x to blank
output.df <- as.data.frame(output)
colnames(output.df) <- gsub(pattern='.x', replacement = '', x = colnames(output.df), fixed = TRUE)          

# Now change anything with a .y to a Flag
colnames(output.df) <- gsub(pattern='.y', replacement = 'Exclude', x = colnames(output.df), fixed = TRUE)  

# Now prepend pcasl to the QA values that do not contain it
colnames(output.df)[7:12] <- c('pcaslRelMeanRMSMotion', 'pcaslRelMeanRMSMotionExclude', 'pcaslTSNR', 'pcaslTSNRExclude',
                              'pcaslNormCrossCorr', 'pcaslNVolumesAcquired')
# Now attach our image paths
output.df <- merge(output.df, file.paths, by=c('bblid', 'scanid'))

# Now I need to create rows for the subjects I do not have data for 
bblidToAdd <- n1601.subjs$bblid[which(n1601.subjs$bblid %in% output.df$bblid == 'FALSE')]
scanidToAdd <- n1601.subjs$scanid[which(n1601.subjs$scanid %in% output.df$scanid == 'FALSE')]
tmpToAdd <- as.data.frame(matrix(rep(NA, 23 * 151), nrow=23, ncol=151))
tmpToAdd <- cbind(bblidToAdd, scanidToAdd, tmpToAdd)
colnames(tmpToAdd) <- colnames(output.df)

output.df <- rbind(output.df, tmpToAdd)

# Now I need to rm the cerebellum, whitematter, the optic chiasm, and the 
# ventral DC areas from the cbf values
namesToRm <- c('Ventricle', 'Cerebellum', 'White', 'CSF', 'Vent', 'Vessel', 
               'Ventral_DC', 'OpticChiasm', 'CerVerLob', 'BasForebr', 'Brain_Stem')
colsToRm <- NULL
# Now go through a loop and grep the columns that we need to rm
# and append those values to the colsToRm variable
for(value in namesToRm){
  valuesToRm <- grep(value, names(output.df))
  colsToRm <- append(colsToRm, valuesToRm)
}

output.df <- output.df[,-colsToRm]

# Now we need to identify subjects with abnormal average pcasl values (i.e. negative)
# First start by turning everyone's pcaslExclude value with a mean value below
# 15 to a 1
output.df$pcaslExclude[which(output.df$pcaslMeanGMValue<15 & output.df$pcaslExclude==0)] <- 1
n1601.ss.vals$pcaslVoxelwiseExclude[which(output.df$pcaslMeanGMValue<15)] <- 1
output.df$pcaslMeanGMValueExclude[which(output.df$pcaslMeanGMValue<15)] <- 1


# Now I need to change all of the NA's to either 0's or 1's in the QA files
output.df$pcaslExclude[which(is.na(output.df$pcaslExclude)=='TRUE')] <- 1
output.df$pcaslVoxelwiseExclude[which(is.na(output.df$pcaslVoxelwiseExclude)=='TRUE')] <- 1
output.df$pcaslNoDataExclude[which(is.na(output.df$pcaslNoDataExclude)=='TRUE')] <- 1


write.csv(output.df, '/data/joy/BBL/projects/pncReproc2015/pcasl/cbfValues/pcasl_201607291423/n1601_jlfPcasl.csv', quote=F, row.names=F)