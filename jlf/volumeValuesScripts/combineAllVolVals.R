# AFGR August 5 2016

##Usage##
# This script is oging to be used to combine all of the:
#	1.) JLF Volumes
#	2.) ANTsCT Volumes
#	3.) Manual QA Values

# Load library(s)
source('/home/arosen/adroseHelperScripts/R/afgrHelpFunc.R')
install_load('tools')

# Load data
jlfVals <- commandArgs()[5]
jlfVals <- read.csv(jlfVals)
ctVals <- commandArgs()[6]
ctVals <- read.csv(ctVals)
manQA1 <- commandArgs()[7]
manQA1 <- read.csv(manQA1)
manQA2 <- commandArgs()[8]
manQA2 <- read.csv(manQA2)
voxelDim <- commandArgs()[9]
voxelDim <- read.csv(voxelDim)

# Now make sure everyone has a scanid column
jlfVals$scanid <- strSplitMatrixReturn(jlfVals$subject.1., 'x')[,2]
ctVals$scanid <- strSplitMatrixReturn(ctVals$subject.1., 'x')[,2]

# Now combine the qa data
manQA1 <- manQA1[,-c(3,4)]
qaData <- rbind(manQA1, manQA2)

output <- merge(jlfVals, ctVals, by='scanid')
output <- merge(output, qaData, by='scanid')

# Just going to do this manually although I know there is a more dynamic fix...
# Fixing column names...
rowsToRM <- NULL
rowsToRM <- grep('bblid', names(output))
rowsToRM <- append(rowsToRM, grep('subject.1..y', names(output))) 
rowsToRM <- append(rowsToRM, grep('subject.0..y', names(output))) 
output <- output[,-rowsToRM]
colnames(output)[2] <- 'bblid'
colnames(output)[3] <- 'datexscanid'

# Now reorder the columns
attach(output)
outputNew <- cbind(bblid, scanid, as.character(datexscanid), ratingJB, ratingKS, ratingLV, averageRating)
output <- output[,-c(seq(1,3), seq(ncol(output), (ncol(output)-3)))]
output <- as.data.frame(cbind(outputNew, output))
colnames(output)[3] <- 'datexscanid'

write.csv(output, '/data/joy/BBL/projects/pncReproc2015/jlf/volumeValues/jlfVolumeValuesVoxelCount.csv', quote=F, row.names=F)
detach(output)

# Now multiply the voxel volume by the voxel count to get mm3
voxelDim$scanid <- strSplitMatrixReturn(voxelDim$subject.1., 'x')[,2]
tmp <- merge(output, voxelDim, by='scanid')
ccOutput <- apply(tmp[,8:150], 2, function(x) (x * tmp$output))
attach(tmp)
ccOutput <- as.data.frame(cbind(as.character(bblid), as.character(scanid), as.character(datexscanid), as.character(ratingJB), as.character(ratingKS), as.character(ratingLV), as.character(averageRating), ccOutput))
colnames(ccOutput)[1:7] <- c('bblid', 'scanid', 'datexscanid', 'ratingJB', 'ratingKS', 'ratingLV', 'averageRating')
write.csv(ccOutput, '/data/joy/BBL/projects/pncReproc2015/jlf/volumeValues/jlfVolumeValuesmm3Vals.csv', quote=F, row.names=F)
