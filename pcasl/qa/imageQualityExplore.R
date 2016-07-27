# AFGR April 6 2016

##Usage##
# This script is going to be used to judge the pcasl data's quality
# Based on the output metrics of the xcpEngine asl module

## Declare libraries
source("/home/arosen/R/x86_64-unknown-linux-gnu-library/helperFunctions/afgrHelpFunc.R")
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



## Load the data here
# These first two files were produced via the qualityWrapper script in the xcpedir utils folder:
# This is the call used:
# ./qualityWrapper -d /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/pcasl/xcpFiles/pcasl_201606231423.dsn 
# -S 3 -m "temporalSignalNoiseRatio relMeanRMSmotion"  -M "30 0.5"  -E "0 1"
qa.scores <- read.csv('/data/joy/BBL/projects/pncReproc2015/pcasl/QA/pcasl_201606231423_groupLevelQuality.csv')
flag.scores <- read.csv('/data/joy/BBL/projects/pncReproc2015/pcasl/QA/pcasl_201606231423_groupLevelFlagStatus.csv')
flag.scores[,2] <- qa.scores[,2]

# This is the go 1 data rel
all.data <- read.csv('/data/joy/BBL/studies/pnc/subjectData/n1601_go1_datarel_020716.csv')

## First thing we need to do is decide on a cut off value for the coreg coverage scores
# The summary of the coreg coverage looks like this:
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 0.8288  0.9299  0.9492  0.9453  0.9647  0.9989 
# The SD is 0.02707349
# There are 16 subjects 3 SD's lower then the mean 

# here is the index for which bblid's were flagged for bad coreg coverage
bad.coreg.coverage.bblid <- qa.scores$subject.0.[which(flag.scores$coregCoverage==1)]
bad.coreg.coverage.scanid <- qa.scores$subject.1.[which(flag.scores$coregCoverage==1)]
# I now need to visually inspect the coregistraions for these flagged images and decide if the coregistration is actually bad
# or if coreg was flagged becuase of bad brain extractions 
# Below are my nots from the manual QA
# 109335: Appears to have a bad functional brain extraction which lowered the coverage score. good scan and series though.
# 116672: Again another beautiful registration, can spot anything for why this coreg was flagged
# 80396: """
# 81043: """
# 81047: """
# 81544: Poor brain extrac as evident from the seq2struct image, also missing a lot of cerebellum-the registration looks great though
# 83080: """
# 83103: """
# Now write out a csv with the bblid's and scanid's in order to create a mask of the normalizations  
output <- cbind(bad.coreg.coverage.bblid, as.character(bad.coreg.coverage.scanid))
write.csv(output, '/data/joy/BBL/projects/pncReproc2015/pcasl/QA/flaggedCoregCoverageImages.csv', quote=F, row.names=F)
system("/bin/bash /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/pcasl/qa/combineImages.sh /data/joy/BBL/projects/pncReproc2015/pcasl/QA/flaggedCoregCoverageImages.csv /data/joy/BBL/projects/pncReproc2015/pcasl/QA/flaggedMasks/flaggedCoregCoverageImages.nii.gz")


# I gave up on usieng coverage to probe for bad registrations, and am now going to try cross cor
# Here is the summary for the cross corr values
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 0.7059  0.7990  0.8137  0.8110  0.8271  0.8599 
# The SD is 0.02227354
bad.coreg.cross.bblid <- qa.scores$subject.0.[which(flag.scores$coregCrossCorr==1)]
bad.coreg.cross.scanid <- qa.scores$subject.1.[which(flag.scores$coregCrossCorr==1)]

# I am now going to visually inspect a handful of the flagged images to see if Cross Corr is reliable 
# 104059: Again another good registration although some brain extraction artifacts remain 
# 104207: """
# 106331: """
# 88869: This is the lowest Cross Corr value. Even with the lowest Xcorr value this is contributed just from a terrible brain extraction
output <- cbind(bad.coreg.cross.bblid, as.character(bad.coreg.cross.scanid))
write.csv(output, '/data/joy/BBL/projects/pncReproc2015/pcasl/QA/flaggedCoregCrossImages.csv',quote=F, row.names=F)
system("/bin/bash /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/pcasl/qa/combineImages.sh /data/joy/BBL/projects/pncReproc2015/pcasl/QA/flaggedCoregCrossImages.csv /data/joy/BBL/projects/pncReproc2015/pcasl/QA/flaggedMasks/flaggedCoregCrossImages.nii.gz")





######
######
## Done with Manual Flagging
## N of rm'ed:0
######
######
## I am now going to try to find the intersection of all masks and ensure that it is of acceptable quality 
# when compared to the PNC template mask
# In order to do this I am going to combine all example func standard masks
# Find the intersection of all of these masks 
# And then create a time series with all of the subjects masks included and find and acceptable cut off 
# for where enough coverage is included, and find the subjects which masks do not posses these coordinates 

## FIrst thing I need to do is create the 4d time sereis mask
all.bblid <- qa.scores$subject.0.
all.scanid <- qa.scores$subject.1.

# Now write the output and run the combineImages bash script 
output <- cbind(all.bblid, as.character(all.scanid))
write.csv(output, '/data/joy/BBL/projects/pncReproc2015/pcasl/QA/allImages.csv',quote=F, row.names=F)
system("/bin/bash /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/pcasl/qa/combineImages.sh /data/joy/BBL/projects/pncReproc2015/pcasl/QA/allImages.csv /data/joy/BBL/projects/pncReproc2015/pcasl/QA/flaggedMasks/allImages.nii.gz")

# Now create the intersection mask 
system("fslmaths /data/joy/BBL/projects/pncReproc2015/pcasl/QA/flaggedMasks/allImages.nii.gz -Tmin /data/joy/BBL/projects/pncReproc2015/pcasl/QA/flaggedMasks/allNormStdMasks-Tmin.nii.gz")

# Now create the concatanated mask 
system("fslmaths /data/joy/BBL/projects/pncReproc2015/pcasl/QA/flaggedMasks/allImages.nii.gz -Tmean -mul 1657 /data/joy/BBL/projects/pncReproc2015/pcasl/QA/flaggedMasks/allNormStdMasks_TmeanMul1657.nii.gz")

# Now I need to figure out which subjects are not part of the intersection of all of the masks.
# I am choosing an arbitray value of 1524because this looks like an acceptable level of coverage 
# SO I am going to find which images in the 4d mask are do not include the voxel coordinate of X: 41 Y:57 Z:21 <- VIA freeview

# Load the 4-d time series 
four.d.time <- as.array(antsImageRead('/data/joy/BBL/projects/pncReproc2015/pcasl/QA/flaggedMasks/allImages.nii.gz', dimension=4))

# Now I need to find for each subject if the voxel coordinate of interest is a 1 or 0
xCoord <- 42
yCoord <- 57 
zCoord <- 22

# Now loop thourgh the 1657 images and find if our voxel of interest is a 1 or 0 
# Return the time points which have a 0 there
seqLength <- dim(four.d.time)[4]
outputFlagged <- NULL
for(i in seq(1,seqLength,1)){
  valueOfInterest <- four.d.time[xCoord, yCoord, zCoord, i]
  if(valueOfInterest == 0){
    outputFlagged <- append(outputFlagged, i)
  }
}

# Now we need to turn our output flagged indices into BBLID's 
# Load the image log file
system('mv /data/joy/BBL/projects/pncReproc2015/pcasl/QA/flaggedMasks/subjectOrder.txt /data/joy/BBL/projects/pncReproc2015/pcasl/QA/flaggedMasks/allsubjectOrder.txt')
imageLog <- read.table('/data/joy/BBL/projects/pncReproc2015/pcasl/QA/flaggedMasks/allsubjectOrder.txt')
imageLog$V1 <- as.character(imageLog$V1)
# Now convert each of the file names into a bblid and scanid index 
all.fields <- matrix(unlist(strsplit(imageLog$V1, split='/')),nrow=1657, byrow=T)
isolated.field <- matrix(unlist(strsplit(all.fields[,10], split='_')), nrow=1657, byrow=T)
bblid.field <- isolated.field[,2]
scanid.field <- gsub(pattern='.nii.gz', replacement = '', x = isolated.field[,3], fixed = TRUE)

# Now find the flagged images
bblid.flagged <- bblid.field[outputFlagged]
scanid.flagged <- scanid.field[outputFlagged]

# Now create the mask of all of the images that were just flagged 
output <- cbind(bblid.flagged, scanid.flagged)
write.csv(output, '/data/joy/BBL/projects/pncReproc2015/pcasl/QA/manualFlaggedImages.csv',quote=F, row.names=F)
system("/bin/bash /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/pcasl/qa/combineImages.sh /data/joy/BBL/projects/pncReproc2015/pcasl/QA/manualFlaggedImages.csv /data/joy/BBL/projects/pncReproc2015/pcasl/QA/flaggedMasks/manualFlaggedImages.nii.gz")

# Now create a mask of all of the images that were not flagged
bblid.not.flagged <- bblid.field[-outputFlagged]
scanid.not.flagged <- scanid.field[-outputFlagged]
output <- cbind(bblid.not.flagged, scanid.not.flagged)
write.csv(output, '/data/joy/BBL/projects/pncReproc2015/pcasl/QA/manualNotFlaggedImages.csv',quote=F, row.names=F)
system("/bin/bash /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/pcasl/qa/combineImages.sh /data/joy/BBL/projects/pncReproc2015/pcasl/QA/manualNotFlaggedImages.csv /data/joy/BBL/projects/pncReproc2015/pcasl/QA/flaggedMasks/manualNotFlaggedImages.nii.gz")

# Now create the combined mask
system("fslmaths /data/joy/BBL/projects/pncReproc2015/pcasl/QA/flaggedMasks/manualNotFlaggedImages.nii.gz -Tmean -mul 1520 /data/joy/BBL/projects/pncReproc2015/pcasl/QA/flaggedMasks/manualNotFlaggedImages_Mul1520")

# After meeting with Ted on 20160727 we decided on a better system to decide on inclusion criteria
# We looked at the all mask and found a comfortable threshold which stil 
# included the temporal and occipital lobes. The overall N for this selectionc riteria was 
# **N = 1639**
# Working with this value I am going to threshold the all mask at 1639 and see which subjects
# Individual masks include the entierty of this mask 

# First thing we have to do is threshold ALL Subjects mask @ 1639
system("fslmaths /data/joy/BBL/projects/pncReproc2015/pcasl/QA/flaggedMasks/allNormStdMasks_TmeanMul1657.nii.gz -thr 1638 -bin /data/joy/BBL/projects/pncReproc2015/pcasl/QA/flaggedMasks/n1639_CoverageMaskToUse.nii.gz")  

# Now load the coverage mask 
coverage.mask.to.use <- as.array(antsImageRead('/data/joy/BBL/projects/pncReproc2015/pcasl/QA/flaggedMasks/n1639_CoverageMaskToUse.nii.gz', dimension=3))

# Now I need to loop through each subject in the four d mask of all subjects
# and check to see that their mask covers the entierty of the coverage.mask.to.use
# I am going to loop through each mask and check to see if 988% of the voxels of the 
# coverage mask to use are included within the mask I am testing
seqLength <- dim(four.d.time)[4]
outputFlagged <- NULL
for(i in seq(1,seqLength,1)){
  coverageCheck <- checkIntersect(coverage.mask.to.use, four.d.time[,,,i], .012)
  outputFlagged <- append(outputFlagged, coverageCheck)
}

# Now check out the flagged images
# Now find the flagged images
bblid.flagged <- bblid.field[which(outputFlagged=="FALSE")]
scanid.flagged <- scanid.field[which(outputFlagged=="FALSE")]

# Now create the mask of all of the images that were just flagged 
output <- cbind(bblid.flagged, scanid.flagged)
write.csv(output, '/data/joy/BBL/projects/pncReproc2015/pcasl/QA/n1639-ExcludedSubjects.csv',quote=F, row.names=F)
system("/bin/bash /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/pcasl/qa/combineImages.sh /data/joy/BBL/projects/pncReproc2015/pcasl/QA/n1639-ExcludedSubjects.csv /data/joy/BBL/projects/pncReproc2015/pcasl/QA/flaggedMasks/n1639_ExcludedImages.nii.gz")

# Now check out the not flagged images

bblid.flagged <- bblid.field[which(outputFlagged=="TRUE")]
scanid.flagged <- scanid.field[which(outputFlagged=="TRUE")]

# Now create the mask of all of the images that were just not flagged 
output <- cbind(bblid.flagged, scanid.flagged)
write.csv(output, '/data/joy/BBL/projects/pncReproc2015/pcasl/QA/n1630-IncludedSubjects.csv',quote=F, row.names=F)
system("/bin/bash /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/pcasl/qa/combineImages.sh /data/joy/BBL/projects/pncReproc2015/pcasl/QA/n1639-IncludedSubjects.csv /data/joy/BBL/projects/pncReproc2015/pcasl/QA/flaggedMasks/n1639_IncludedImages.nii.gz")

# Now create the combined mask 
system("fslmaths /data/joy/BBL/projects/pncReproc2015/pcasl/QA/flaggedMasks/n1639_IncludedImages.nii.gz -Tmean -mul 1639 /data/joy/BBL/projects/pncReproc2015/pcasl/QA/flaggedMasks/n1639_IncludedImages_TmeanMul.nii.gz")


# Now create a manual coverage binary inclusion variable and attach it to the flag scores 
bblid.flagged <- bblid.field[which(outputFlagged=="FALSE")]
scanid.flagged <- scanid.field[which(outputFlagged=="FALSE")]
flag.scores$manualCoverageFlag <- rep(0, nrow(flag.scores))
flag.scores$manualCoverageFlag[match(scanid.flagged, flag.scores$subject.1.)] <- 1
flag.scores.output <- as.data.frame(cbind(qa.scores[,1], as.character(qa.scores[,2]),
                      qa.scores$temporalSignalNoiseRatio, 
                      flag.scores$temporalSignalNoiseRatio,
                      qa.scores$relMeanRMSmotion, flag.scores$relMeanRMSmotion,
                      flag.scores$manualCoverageFlag))
colnames(flag.scores.output) <- c('subject.0.', 'subject.1.', 'temporalSignalNoiseRatio',
                                'temporalSignalNoiseRatioFlag', 'relMeanRMSmotion',
                                'relMeanRMSmotionFlag', 'manualCoverageFlag')
write.csv(flag.scores.output, 
          '/data/joy/BBL/projects/pncReproc2015/pcasl/QA/n1639_FlagStatus.csv',
          row.names=F, quote=F)


# Now lets find where the flags occur
onlyTSNR <- length(which(flag.scores.output$temporalSignalNoiseRatioFlag==1 & flag.scores.output$relMeanRMSmotionFlag==0 & flag.scores.output$manualCoverageFlag==0))

onlyRELRMS <- length(which(flag.scores.output$temporalSignalNoiseRatioFlag==0 & flag.scores.output$relMeanRMSmotionFlag==1 & flag.scores.output$manualCoverageFlag==0))

onlyCOVERAGE <- length(which(flag.scores.output$temporalSignalNoiseRatioFlag==0 & flag.scores.output$relMeanRMSmotionFlag==0 & flag.scores.output$manualCoverageFlag==1))

tsnrAndMotion <- length(which(flag.scores.output$temporalSignalNoiseRatioFlag==1 & flag.scores.output$relMeanRMSmotionFlag==1 & flag.scores.output$manualCoverageFlag==0))

tsnrAndCoverage <- length(which(flag.scores.output$temporalSignalNoiseRatioFlag==1 & flag.scores.output$relMeanRMSmotionFlag==0 & flag.scores.output$manualCoverageFlag==1))

motionAndCoverage <- length(which(flag.scores.output$temporalSignalNoiseRatioFlag==0 & flag.scores.output$relMeanRMSmotionFlag==1 & flag.scores.output$manualCoverageFlag==1))

nTable <- cbind(onlyTSNR,onlyRELRMS, onlyCOVERAGE, tsnrAndMotion, tsnrAndCoverage,motionAndCoverage)

write.csv(nTable,'/data/joy/BBL/projects/pncReproc2015/pcasl/QA/n1639_FlagBreakDown.csv', 
          quote=F, row.names=F) 
