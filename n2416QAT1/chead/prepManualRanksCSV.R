# AFGR Jan 30th 2017

# This csv will be used to prepare a csv with all of the (n=2416) manual ratings from the three raters
# It will combine the ratings made on monsturm and chead.

# source and load library(s)
source('/home/arosen/adroseHelperScripts/R/afgrHelpFunc.R')

# Load all of the data 
n1601.data <- read.csv('/data/joy/BBL/studies/pnc/subjectData/n1601_t1RawManualQA.csv')
n368.data <- read.csv('/data/joy/BBL/studies/pnc/subjectData/n368_t1RawManualQA_GO2.csv')
jb.data <- read.csv('/data/joy/BBL/projects/pncReproc2015/n2416QAT1/t1QA/data/jablake_qa_logs/jablakeoutfile17_01_04_14_56_37_AFGREDITS-notesrm.csv')
ks.data <- read.csv('/data/joy/BBL/projects/pncReproc2015/n2416QAT1/t1QA/data/kseelaus_qa_logs/merged-notesrm.csv')
pv.data <- read.csv('/data/joy/BBL/projects/pncReproc2015/n2416QAT1/t1QA/data/pvilla_qa_logs/merged_pvillaedits_afgredits-notesrm.csv')
n2416.subjs <- read.csv('/data/joy/BBL/projects/pncReproc2015/antsCT/n2416_bblid_scanid.csv')
imagesToRM <- read.csv('/data/joy/BBL/projects/pncReproc2015/n2416QAT1/finalReview/afgrReviewAGGComments.csv')
#skullIssues <- read.csv('/data/joy/BBL/projects/pncReproc2015/n2416QAT1/finalReview/manualBEIssues.csv')
oldRef <- read.csv('/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/t1struct/n1601_t1QaData_20170306.csv')
skullFixSubjects <- read.csv('/data/joy/BBL/projects/pncReproc2015/beSave/subjectId/subjectToRun', header=F)
reprocAntsSubjs <- read.csv('/data/joy/BBL/projects/pncReproc2015/antsCT/subjectsReprocessed.csv')

# Now clean the data so we can combine them 
jb.data <- jb.data[!duplicated(jb.data$scanid),]
ks.data <- ks.data[!duplicated(ks.data$scanid),]
pv.data <- pv.data[!duplicated(pv.data$scanid),]
ks.data <- ks.data[which(ks.data$scanid %in% jb.data$scanid =='TRUE'),]

colnames(jb.data)[4] <- 'ratingJB'
colnames(ks.data)[4] <- 'ratingKS'
colnames(pv.data)[4] <- 'ratingLV'

colsToRm <- c(1,5)
jb.data <- jb.data[,-colsToRm]
ks.data <- ks.data[,-colsToRm]
pv.data <- pv.data[,-colsToRm] 

tmpData <- merge(jb.data, ks.data, by=c('bblid', 'scanid'))
tmpData <- merge(tmpData, pv.data, by=c('bblid', 'scanid'))

# Now rm all date id variables from the n1601 data 
n1601.data <- n1601.data[,-c(3,4)]

# Now fix our colnames for the n2416 data
colnames(n2416.subjs) <- c('bblid', 'scanid')

# Now create our average rating row 
tmpData$averageRating <- (tmpData$ratingJB + tmpData$ratingKS + tmpData$ratingLV)/3
tmpData$averageRating[tmpData$averageRating < .99] <- 0


# Now merge all of our data 
allData <- rbind(n1601.data, tmpData, n368.data)
allData <- merge(n2416.subjs, allData, by=c('bblid', 'scanid'))


# Now prepare a final formal T1 QA csv 
output <- cbind(allData$bblid, allData$scanid)

t1Exclude <- rep(0, 2416)
t1Reprocess <- rep(0, 2416)
t1RawDataExclude <- rep(0, 2416)
t1PostProcessExclude <- rep(0, 2416)
t1BETBrainExtraction <- rep(0, 2416)

output <- cbind(output, t1Exclude)
output <- cbind(output, t1RawDataExclude)
output <- cbind(output, t1BETBrainExtraction)
output <- cbind(output, t1PostProcessExclude)

# Now find the subjects with unusable data 
scanidIndex <- imagesToRM$scanid[which(imagesToRM$Useable==1)]
scanidIndex <- append(scanidIndex, oldRef$scanid[which(oldRef$t1PostProcessExclude==1)])
scanidIndex <- scanidIndex[-which(scanidIndex %in% reprocAntsSubjs[,3])]
scanid0Index <- allData$scanid[which(allData$averageRating==0)]

# Now turn everting not useable into ones for the output
output <- as.data.frame(output)
names(output)[1:2] <- c('bblid', 'scanid')
output$t1BETBrainExtraction[output$scanid %in% skullFixSubjects[,3]] <- 1
output$t1PostProcessExclude[output$scanid %in% scanidIndex] <- 1
output$t1PostProcessExclude[which(output$t1PostProcessExclude==1 & output$t1BETBrainExtraction==1)] <- 0
output$t1RawDataExclude[output$scanid %in% scanid0Index] <- 1
output$averageManualRating <- allData$averageRating[match(output$scanid, allData$scanid)]
output$ratingKS <- allData$ratingKS[match(output$scanid, allData$scanid)]
output$ratingJB <- allData$ratingJB[match(output$scanid, allData$scanid)]
output$ratingLV <- allData$ratingLV[match(output$scanid, allData$scanid)]

output$t1Exclude[which(output$t1PostProcessExclude==1 | output$t1RawDataExclude==1)] <- 1

# Now write the csv 
write.csv(output, paste('/data/joy/BBL/studies/pnc/n2416_dataFreeze/neuroimaging/t1struct/n2416_t1QaData_',format(Sys.Date(), format="%Y%m%d"),'.csv', sep=''), quote=F, row.names=F)
