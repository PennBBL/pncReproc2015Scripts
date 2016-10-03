# AFGR August 5 2016

##Usage##
# This script is going to be used to prepare the antsCT JLF data
# Its going to rm extra columns and then prepare the data's header
# Might make this into one big function but we will see how that goes =/


# Load library(s)
source("/home/arosen/adroseHelperScripts/R/afgrHelpFunc.R")

# Load data
columnNames <- read.csv("/data/joy/BBL/projects/pncReproc2015/antsCT/ctJlfNames.csv")
columnNumbers <- read.csv("/data/joy/BBL/projects/pncReproc2015/antsCT/justJLFColNamesafgrEdits.csv")
# ctValues was created by using the command found below:
system("$XCPEDIR/utils/combineOutput -p /data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/ -f JLF_antsCT_val.1D -o antsCT_JLF_vals.1D")
system("mv /data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/antsCT_JLF_vals.1D /data/joy/BBL/projects/pncReproc2015/antsCT/jlfAntsCTVals.1D") 
ctValues <- read.table("/data/joy/BBL/projects/pncReproc2015/antsCT/jlfAntsCTVals.1D", header=T)
manQAVal1 <- read.csv("/data/joy/BBL/studies/pnc/subjectData/n1601_t1RawManualQA.csv")
manQAVal2 <- read.csv("/data/joy/BBL/studies/pnc/subjectData/n368_t1RawManualQA_GO2.csv")
ctImagePaths <- read.table("/data/joy/BBL/projects/pncReproc2015/antsCT/antsCTImages.txt", header=F)
#tbvData <- read.csv('/data/joy/BBL/studies/pnc//data/joy/BBL/studies/pnc/summaryData_n1601_20160823/n1601_antsCtVol_jlfVol.csv')
#tbvData <- tbvData[,c(1,2,5)]

# Now modify our image paths so it is easier to work with
names(ctImagePaths) <- 'ctImagePath'
ctImagePaths$bblid <- strSplitMatrixReturn(ctImagePaths[,1], '/')[,10]
ctImagePaths$scanid <- strSplitMatrixReturn(strSplitMatrixReturn(ctImagePaths[,1], '/')[,11], 'x')[,2]

# Now take only the column of interest
colsOfInterest <- columnNumbers$ROI_INDEX[115:length(columnNumbers$ROI_INDEX)] + 2
colsOfInterest <- append(c(1,2), colsOfInterest)

# Now limit the PCASL values to just the columns of interest
ctValues <- ctValues[,colsOfInterest]

# Now change their names
colnames(ctValues)[3:length(ctValues)] <- as.character(columnNames$X)

# Now rm the white matter regions that don't exist 
ctValues <- ctValues[,-seq(41,55)]

# Now order and rename the files
ctValues$scanid <- strSplitMatrixReturn(ctValues$subject.1., 'x')[,2]
colnames(ctValues)[1:2] <- c('bblid', 'datexscanid')
attach(ctValues)
output <- as.data.frame(cbind(bblid, scanid, datexscanid, ctValues[,3:138]))
detach(ctValues)
ctValues <- output

# Now attach our file paths to our output csv
ctValues <- merge(ctValues, ctImagePaths, by=c('bblid', 'scanid'))

# Now rm areas that should not have CT values
ctValues <- ctValues[,-seq(4,41)]

# Now write the csv
write.csv(ctValues, '/data/joy/BBL/projects/pncReproc2015/antsCT/jlfAntsValuesCT.csv', quote=F, row.names=F)
