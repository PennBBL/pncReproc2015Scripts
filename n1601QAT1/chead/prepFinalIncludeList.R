# source and load library(s)
source('/home/arosen/adroseHelperScripts/R/afgrHelpFunc.R')
 
# Load the data
t1QAData <- read.csv('/data/joy/BBL/projects/pncReproc2015/n1601QAT1/flaggingBasedonSD/n1601_go_QAFlags_Structural_final.csv')
imagesToRM <- read.csv('/data/joy/BBL/projects/pncReproc2015/n1601QAT1/finalReview/afgrReviewAGGcomments-withTSconsensus.csv')
manQAData <- read.csv('/data/joy/BBL/projects/pncReproc2015/n1601QAT1/flaggingBasedonSD/n1601_t1RawManualQA.csv')
subjId <- read.csv('/data/joy/BBL/projects/pncReproc2015/jlf/volumeValues/n1601_jlfVol_antsCTVol_T1QA_mm3.csv')
skullIssues <- read.csv('/data/joy/BBL/projects/pncReproc2015/n1601QAT1/finalReview/manualBEIssues.csv')
skullFixSubjects <- read.csv('/data/joy/BBL/projects/pncReproc2015/beSave/subjectId/subjectToRun', header=F)

# Now prep the output 
attach(subjId)
output <- cbind(bblid, scanid)
detach(subjId)

t1Exclude <- rep(0, 1601)
t1Reprocess <- rep(0, 1601)
t1RawDataExclude <- rep(0, 1601)
t1PostProcessExclude <- rep(0, 1601)
t1GMDExclude <- rep(0, 1601)
t1CTExclude <- rep(0, 1601)
t1ANTsSegmentationExclude <- rep(0, 1601)
t1JLFExclude <- rep(0, 1601)
t1BETBrainExtraction <- rep(0,1601)

output <- cbind(output, t1Exclude)
#output <- cbind(output, t1Reprocess)
output <- cbind(output, t1RawDataExclude)
output <- cbind(output, t1PostProcessExclude)
output <- cbind(output, t1BETBrainExtraction)
#output <- cbind(output, t1GMDExclude)
#output <- cbind(output, t1CTExclude)
#output <- cbind(output, t1ANTsSegmentationExclude)
#output <- cbind(output, t1JLFExclude)

# Now find the subjects with non useable T1 data
bblidIndex <- imagesToRM$bblid[which(imagesToRM$Useable==1)]
bblid0Index <- manQAData$bblid[which(manQAData$averageRating==0)]
bblidRedoIndex <- skullIssues$bblid
bblidGMDIndex <- imagesToRM$bblid[which(imagesToRM$GMD==1)]
bblidCTIndex <- imagesToRM$bblid[which(imagesToRM$CT==1)]
bblidANTSIndex <- imagesToRM$bblid[which(imagesToRM$ANTS==1)]
bblidJLFIndex <- imagesToRM$bblid[which(imagesToRM$JLF==1)]

# Now turn everything not useable to 1's in the output
output <- as.data.frame(output)
output$t1PostProcessExclude[output$bblid %in% bblidIndex[which(which(output$t1PostProcessExclude==1) %in% which(output$t1BETBrainExtraction==1)=='FALSE')]] <- 1
#output$t1PostProcessExclude[output$bblid %in% bblidRedoIndex] <- 1
output$t1RawDataExclude[output$bblid %in% bblid0Index] <- 1
#output$t1Reprocess[output$bblid %in% bblidRedoIndex] <- 1
output$t1BETBrainExtraction[output$scanid %in% skullFixSubjects[,3]] <- 1
#output$t1GMDExclude[output$bblid %in% bblidGMDIndex] <- 1
#output$t1CTExclude[output$bblid %in% bblidCTIndex] <- 1
#output$t1ANTsSegmentationExclude[output$bblid %in% bblidANTSIndex] <- 1
#output$t1JLFExclude[output$bblid %in% bblidJLFIndex] <- 1
output$datexscanid <- subjId$datexscanid
output$averageManualRating <- manQAData$averageRating[match(output$scanid, manQAData$scanid)]
output$ratingKS <- manQAData$ratingKS[match(output$scanid, manQAData$scanid)]
output$ratingJB <- manQAData$ratingJB[match(output$scanid, manQAData$scanid)]
output$ratingLV <- manQAData$ratingLV[match(output$scanid, manQAData$scanid)]

output$t1Exclude[which(output$t1PostProcessExclude==1 | output$t1RawDataExclude==1)] <- 1

# Now write the output
write.csv(output, '/data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/t1struct/n1601_t1QaData-tmp.csv', quote=F, row.names=F)
