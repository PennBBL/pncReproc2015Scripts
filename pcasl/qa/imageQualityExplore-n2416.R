# AFGR April 6 2016

##Usage##
# This script is going to be used to judge the pcasl data's quality
# Based on the output metrics of the xcpEngine asl module
# This script will only work for the n1601!

## Declare libraries
source("/home/arosen/adroseHelperScripts/R/afgrHelpFunc.R")
install_load('ANTsR', 'eVenn')

## Now create and load the data
# First combine all of the qa information
system('${XCPEDIR}/utils//qualityWrapper -d /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/pcasl/xcpFiles/pcasl_201607291423.dsn -S 3 -m "temporalSignalNoiseRatio relMeanRMSmotion" -M "30 0.5" -E "0 1"')
system("mv /data/joy/BBL/studies/pnc/processedData/pcasl/pcasl_201607291423/*csv /data/joy/BBL/projects/pncReproc2015/pcasl/QA/n2416/")
# Now create all of the mean GM pcasl values
system('for i in `find /data/joy/BBL/studies/pnc/processedData/pcasl/pcasl_201607291423/ -name "*asl_quant_ssT1Std.nii.gz" -type f` ; do vals=`fslstats ${i} -k /data/joy/BBL/studies/pnc/template/priors/prior_grey_thr20_2mm.nii.gz -M` ; echo "${i},${vals}" >> /home/arosen/meanCBFValues.csv ; done')
system("mv /home/arosen/meanCBFValues.csv /data/joy/BBL/projects/pncReproc2015/pcasl/QA/n2416/")
# Now get all of the pcasl ss values
system('/data/joy/BBL/applications/xcpEngine/utils/combineOutput -p /data/joy/BBL/studies/pnc/processedData/pcasl/pcasl_201607291423/ -f JLFintersect_val_asl_quant_ssT1.1D -o pcasl_JLFintersect_ssT1.1D')
system("mv /data/joy/BBL/studies/pnc/processedData/pcasl/pcasl_201607291423/pcasl_JLFintersect_ssT1.1D /data/joy/BBL/projects/pncReproc2015/pcasl/cbfValues/pcasl_20161202/")
# Now load all data
qa.scores <- read.csv('/data/joy/BBL/projects/pncReproc2015/pcasl/QA/n2416/pcasl_201607291423_groupLevelQuality.csv')
flag.scores <- read.csv('/data/joy/BBL/projects/pncReproc2015/pcasl/QA/n2416/pcasl_201607291423_groupLevelFlagStatus.csv')
flag.scores[,2] <- qa.scores[,2]
trInfo <- read.csv('/data/joy/BBL/studies/pnc/subjectData/n2416_pnc_protocol_validation_params_status_20170105.csv')
n1601.data <- read.csv('/data/joy/BBL/projects/pncReproc2015/antsCT/n1601_bblid_scanid_dateid.csv')
meanPcaslVals <- read.csv('/data/joy/BBL/projects/pncReproc2015/pcasl/QA/n2416/meanCBFValues.csv', header=F)
subjectScanInfo <- read.csv('/data/joy/BBL/studies/pnc/subjectData/n2416_pnc_protocol_validation_params_status_20170105.csv')
rpsMapInfo <- read.csv('/data/joy/BBL/projects/pncReproc2015/pcasl/QA/n2416/subjsWithRpsMaps.csv')
n1601.pcasl.quality <- read.csv('/data/joy/BBL/projects/pncReproc2015/pcasl/QA/n2416/n1601PcaslQaData.csv')
n2416.subj.ids <- read.csv('/data/joy/BBL/projects/pncReproc2015/pcasl/QA/n2416/n2416_bblid_scanid_dateid.csv', header=F)
pcaslSSVals <- read.table('/data/joy/BBL/projects/pncReproc2015/pcasl/cbfValues/pcasl_20161202/pcasl_JLFintersect_ssT1.1D',header=T)
# Now fix the meanPcaslVals column names
meanPcaslVals$bblid <- strSplitMatrixReturn(meanPcaslVals$V1, '/')[,10]
meanPcaslVals$datexscanid <- strSplitMatrixReturn(meanPcaslVals$V1, '/')[,11]
meanPcaslVals$scanid <- strSplitMatrixReturn(strSplitMatrixReturn(meanPcaslVals$V1, '/')[,11], 'x')[,2]
meanPcaslVals <- meanPcaslVals[,-1]
names(meanPcaslVals)[1] <- 'pcaslMeanGMValue'

# Now combine all of our data
flag.scores$scanid <-strSplitMatrixReturn(flag.scores$subject.1.,'x')[,2]
colnames(flag.scores)[1:2] <- c('bblid', 'datexscanid')
qa.scores$scanid <-strSplitMatrixReturn(qa.scores$subject.1.,'x')[,2]
colnames(qa.scores)[1:2] <- c('bblid', 'datexscanid')
allData <- merge(qa.scores, flag.scores, by=c('bblid', 'scanid', 'datexscanid'))

# Now rm the n1601 from the allData
rowsToRm <- which(allData$scanid %in% n1601.data$scanid == 'TRUE')
n1601Data <- allData[rowsToRm,]
allData <- allData[-rowsToRm,]

# Now attach the scan info to allData
allData <- merge(allData, subjectScanInfo, by=c('bblid', 'scanid'))
allData <- merge(allData, meanPcaslVals, by=c('bblid', 'scanid', 'datexscanid')) 

#######
#######
## Coverage Mask ##
#######
#######
## Here I am going to be make a coverage mask across all 
## of the n1601 subjects w/ pcasl data
all.subj.id <- cbind(allData$bblid, as.character(allData$datexscanid))
write.csv(all.subj.id, '/data/joy/BBL/projects/pncReproc2015/pcasl/QA/n2416/allSubjId.csv', quote=F, row.names=F)
system("/bin/bash /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/pcasl/qa/combineImages-n2416.sh /data/joy/BBL/projects/pncReproc2015/pcasl/QA/n2416/allSubjId.csv /data/joy/BBL/projects/pncReproc2015/pcasl/QA/n2416/allSubjIdImageOrder")

## I now am going to find the optimal coverage to use based on the n1601 data and will 
## then check for voxel values for which to flag images that don't contain that value
# Load the 4-d time series 
four.d.time <- as.array(antsImageRead('/data/joy/BBL/projects/pncReproc2015/pcasl/QA/n2416/allSubjIdImageOrder.nii.gz', dimension=4))

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

# Now find which bblid's were flagged
imageLog <- read.table('/data/joy/BBL/projects/pncReproc2015/pcasl/QA/n2416/flaggedImages/subjectOrder.txt', header=F)
imageLog$V1 <- as.character(imageLog$V1)
bblid.index <- strSplitMatrixReturn(imageLog$V1, '_')[,2]
datexscanid <- strSplitMatrixReturn(strSplitMatrixReturn(imageLog$V1, '_')[,3], '.nii.gz')
flagged.bblids <- bblid.index[outputFlagged]
flagged.dateid <- datexscanid[outputFlagged]


## Now repeat this process for the 1601 so we can have all subjects flagged from both timepoints together
all.subj.id <- cbind(n1601Data$bblid, as.character(n1601Data$datexscanid))
write.csv(all.subj.id, '/data/joy/BBL/projects/pncReproc2015/pcasl/QA/n2416/allSubjId.csv', quote=F, row.names=F)
system("/bin/bash /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/pcasl/qa/combineImages-n2416.sh /data/joy/BBL/projects/pncReproc2015/pcasl/QA/n2416/allSubjId.csv /data/joy/BBL/projects/pncReproc2015/pcasl/QA/n2416/allSubjIdImageOrder")

## I now am going to find the optimal coverage to use based on the n1601 data and will 
## then check for voxel values for which to flag images that don't contain that value
# Load the 4-d time series 
four.d.time <- as.array(antsImageRead('/data/joy/BBL/projects/pncReproc2015/pcasl/QA/n2416/allSubjIdImageOrder.nii.gz', dimension=4))

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
imageLog <- read.table('/data/joy/BBL/projects/pncReproc2015/pcasl/QA/n2416/flaggedImages/subjectOrder.txt', header=F)
imageLog$V1 <- as.character(imageLog$V1)
bblid.index <- strSplitMatrixReturn(imageLog$V1, '_')[,2]
datexscanid <- strSplitMatrixReturn(strSplitMatrixReturn(imageLog$V1, '_')[,3], '.nii.gz')
flagged.bblids <- append(flagged.bblids, bblid.index[outputFlagged])
flagged.dateid <- append(flagged.dateid, datexscanid[outputFlagged])

# Now find all of the flagged images
all.date.id  <- append(as.character(n1601Data$datexscanid), as.character(allData$datexscanid))
all.bblid <- append(as.character(n1601Data$bblid), as.character(allData$bblid))
outputFlagged <- match(flagged.dateid, all.date.id)

# Now combine all of our non flagged images
non.flagged.bblid <- all.bblid[-outputFlagged]
non.flagged.dateid <- all.date.id[-outputFlagged]
non.flagged.subj <- cbind(non.flagged.bblid, as.character(non.flagged.dateid))
write.csv(non.flagged.subj, '/data/joy/BBL/projects/pncReproc2015/pcasl/QA/n2416/allNonFlagged-it1-SubjId.csv', quote=F, row.names=F)
#system("/bin/bash /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/pcasl/qa/combineImages-n2416.sh /data/joy/BBL/projects/pncReproc2015/pcasl/QA/n2416/allNonFlagged-it1-SubjId.csv /data/joy/BBL/projects/pncReproc2015/pcasl/QA/n2416/allNonFlaggedImage")

# Now create the coverage flag column
allData$pcaslCoverageExclude <- 0
allData$pcaslCoverageExclude[match(flagged.dateid, allData$datexscanid)] <- 1
allData$pcaslRpsMapCorrectionNotApplied <- 1
allData$pcaslRpsMapCorrectionNotApplied[match(rpsMapInfo$scanid, allData$scanid)] <- 0
allData$pcaslNVolumesAcquired <- allData$cbfNvolsXnat
allData$pcaslNVolumesAcquiredExclude <- 0
allData$pcaslNVolumesAcquiredExclude[which(allData$pcaslNVolumesAcquired != 80)] <- 1
allData$pcaslMeanGMValueExclude <- 0
allData$pcaslMeanGMValueExclude[which(allData$pcaslMeanGMValue<15)] <- 1
# The exclude column is a or statement across motion, tSNR, & nTR's
allData$pcaslExclude <- 0
allData$pcaslExclude[which(allData$relMeanRMSmotion.y==1 | allData$temporalSignalNoiseRatio.y == 1 | allData$pcaslNVolumesAcquired != 80 | allData$pcaslMeanGMValueExclude==1)] <- 1
# The voxelwise exlcusion extends the pcasl exlusion to incldue the coverage flag
allData$pcaslVoxelwiseExclude <- 0
allData$pcaslVoxelwiseExclude[which(allData$relMeanRMSmotion.y==1 | allData$temporalSignalNoiseRatio.y == 1 | allData$pcaslNVolumesAcquired != 80 | allData$pcaslCoverageExclude==1 | allData$pcaslMeanGMValueExclude==1)] <- 1

allData$pcaslNoDataExclude <- 0

# Now prepare the output csv
colsToKeep <- c(1, 2, 97, 98, 99, 6, 16, 5, 15, 12, 13, 8, 9, 94, 95, 92, 93, 91, 96)
output.df <- allData[, colsToKeep]

# Now combine the n1601 dtaa and the new data 
names(output.df) <- names(n1601.pcasl.quality)
output.df <- rbind(n1601.pcasl.quality, output.df)

## Now I need to prepare the rows that do not have any data 
bblidToAdd <- n2416.subj.ids$V1[which(n2416.subj.ids$V2 %in% output.df$scanid == 'FALSE')]
scanidToAdd <- n2416.subj.ids[,2][which(n2416.subj.ids[,2] %in% output.df$scanid == 'FALSE')]
tmpToAdd <- as.data.frame(matrix(rep(NA, length(bblidToAdd) * (ncol(output.df)-2)), nrow=length(bblidToAdd), ncol=(ncol(output.df)-2)))
tmpToAdd <- cbind(bblidToAdd, scanidToAdd, tmpToAdd)
colnames(tmpToAdd) <- colnames(output.df)
output.df <- rbind(output.df, tmpToAdd)

# Now fix the no data exclude and other pcal exclusions for the missing data
output.df$pcaslExclude[which(is.na(output.df$pcaslExclude)=='TRUE')] <- 1
output.df$pcaslVoxelwiseExclude[which(is.na(output.df$pcaslVoxelwiseExclude)=='TRUE')] <- 1
output.df$pcaslNoDataExclude[which(is.na(output.df$pcaslNoDataExclude)=='TRUE')] <- 1

# Now write the output
write.csv(output.df, paste('/data/joy/BBL/studies/pnc/n2416_dataFreeze/neuroimaging/asl/n2416_PcaslQaData_',format(Sys.Date(), format="%Y%m%d"), '.csv', sep=''), quote=F, row.names=F)

# Now lets produce our venn diagram for those subjects that were flagged for removal
qaData <- output.df
excludeCols <- grep('Exclude', names(qaData))
excludeCols <- excludeCols[-c(1,2,3)]
matrixValues <- qaData[which(output.df$pcaslVoxelwiseExclude==1),excludeCols]
matrixValues <- as.matrix(matrixValues)
evenn(matLists=matrixValues, pathRes='/data/joy/BBL/projects/pncReproc2015/pcasl/QA/n2416/')

# Now prepare the n2416 pcasl SS values
pcaslSSVals <- read.table('/data/joy/BBL/projects/pncReproc2015/pcasl/cbfValues/pcasl_20161202/pcasl_JLFintersect_ssT1.1D',header=T)
tmpColumns <- read.csv('/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/jlf/labelList/inclusionCheck.csv')
tmpNames <- gsub(x=gsub(x=tmpColumns$JLF.Column.Names, pattern='%MODALITY%', replacement='pcasl'), pattern='%MEASURE%', replacement='cbf')[which(tmpColumns$PCASL==0)]
tmpNames <- c('bblid', 'scanid', as.character(tmpNames))
tmpCols <- tmpColumns$Label.Number[which(tmpColumns$PCASL==0)]+2
pcaslSSVals[,2] <-strSplitMatrixReturn(pcaslSSVals$subject.1.,'x')[,2]

# Now remove extra columns and fix names
pcaslSSVals <- pcaslSSVals[,c(1,2,tmpCols)]
colnames(pcaslSSVals) <- tmpNames

# Now remove all negative values
pcaslSSVals[pcaslSSVals<0] <- 'NA'

# and now append the extra subjects
colnames(n2416.subj.ids) <- c('bblid', 'scanid', 'datexscanid') 
bblidToAdd <- n2416.subj.ids$bblid[which(n2416.subj.ids$scanid %in% pcaslSSVals$scanid == 'FALSE')]
scanidToAdd <- n2416.subj.ids$scanid[which(n2416.subj.ids$scanid %in% pcaslSSVals$scanid == 'FALSE')]
tmpToAdd <- as.data.frame(matrix(rep(NA, length(bblidToAdd) * (ncol(pcaslSSVals)-2)), nrow=length(bblidToAdd), ncol=(ncol(pcaslSSVals)-2)))
tmpToAdd <- cbind(bblidToAdd, scanidToAdd, tmpToAdd)
colnames(tmpToAdd) <- colnames(pcaslSSVals)
pcaslSSVals <- rbind(pcaslSSVals, tmpToAdd)

# Now write the csv
write.csv(pcaslSSVals, paste('/data/joy/BBL/studies/pnc/n2416_dataFreeze/neuroimaging/asl/n2416_jlfAntsCTIntersectionPcaslValues_',format(Sys.Date(), format="%Y%m%d"), '.csv', sep=''), row.names=F, quote=F)
