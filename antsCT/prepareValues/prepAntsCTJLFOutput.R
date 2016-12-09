# AFGR August 5 2016

##Usage##
# This script is going to be used to prepare the antsCT JLF data
# Its going to rm extra columns and then prepare the data's header
# Might make this into one big function but we will see how that goes =/

# Load data
columnNames <- read.csv("/data/joy/BBL/projects/pncReproc2015/antsCT/ctJlfNames.csv")
columnNumbers <- read.csv("/data/joy/BBL/projects/pncReproc2015/antsCT/justJLFColNamesafgrEdits.csv")
# ctValues was created by using the command found below:
system("$XCPEDIR/utils/combineOutput -p /data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/ -f JLFintersect_antsCT_val.1D -o antsCT_JLF_vals.1D")
system("mv /data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/antsCT_JLF_vals.1D /data/joy/BBL/projects/pncReproc2015/antsCT/jlfAntsCTVals.1D") 
ctValues <- read.table("/data/joy/BBL/projects/pncReproc2015/antsCT/jlfAntsCTVals.1D", header=T)
manQAVal1 <- read.csv("/data/joy/BBL/studies/pnc/subjectData/n1601_t1RawManualQA.csv")
manQAVal2 <- read.csv("/data/joy/BBL/studies/pnc/subjectData/n368_t1RawManualQA_GO2.csv")
ctImagePaths <- read.table("/data/joy/BBL/projects/pncReproc2015/antsCT/antsCTImages.txt", header=F)
n1601.subjs <- read.csv('/data/joy/BBL/projects/pncReproc2015/antsCT/n1601_bblid_scanid_dateid.csv')
n1601.subjs <- n1601.subjs[,c(2,1)]

# Now I need to limit it to just the NZmeans 
nzCols <- grep('NZMean', names(ctValues))
nzCols <- append(c(1, 2), nzCols)

ctValues <- ctValues[,nzCols]

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
#ctValues <- merge(ctValues, ctImagePaths, by=c('bblid', 'scanid'))

# Now rm areas that should not have CT values
ctValues <- ctValues[,-seq(4,41)]

# Now rm datexscanid in order to avoid PHI issues
ctValues <- ctValues[,-3]

# Now write the csv
write.csv(ctValues, '/data/joy/BBL/projects/pncReproc2015/antsCT/jlfAntsValuesCT.csv', quote=F, row.names=F)

# Now do the n1601 specific csv
n1601.ct.vals <- merge(n1601.subjs, ctValues, by=c('bblid', 'scanid'))
write.csv(n1601.ct.vals, '/data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/t1struct/n1601_jlfAntsCTIntersectionCt.csv', quote=F, row.names=F)
