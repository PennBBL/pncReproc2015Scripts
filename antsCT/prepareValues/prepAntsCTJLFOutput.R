# AFGR August 5 2016

##Usage##
# This script is going to be used to prepare the antsCT JLF data
# Its going to rm extra columns and then prepare the data's header
# Might make this into one big function but we will see how that goes =/

# Load data
source('/home/arosen/adroseHelperScripts/R/afgrHelpFunc.R')
columnValues <- read.csv("/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/jlf/labelList/inclusionCheck.csv")
# ctValues was created by using the command found below:
system("$XCPEDIR/utils/combineOutput -p /data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/ -f JLFintersect_antsCT_val.1D -o antsCT_JLF_vals.1D")
system("mv /data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/antsCT_JLF_vals.1D /data/joy/BBL/projects/pncReproc2015/antsCT/jlfAntsCTVals.1D") 
ctValues <- read.table("/data/joy/BBL/projects/pncReproc2015/antsCT/jlfAntsCTVals.1D", header=T)
n1601.subjs <- read.csv('/data/joy/BBL/projects/pncReproc2015/antsCT/n1601_bblid_scanid_dateid.csv')
n1601.subjs <- n1601.subjs[,c(2,1)]

# Now I need to limit it to just the NZmeans 
nzCols <- grep('NZMean', names(ctValues))
nzCols <- append(c(1, 2), nzCols)

ctValues <- ctValues[,nzCols]

# Now take only the column of interest
colsOfInterest <- columnValues$Label.Number[which(columnValues$CT==0)] + 2
colsOfInterest <- append(c(1,2), colsOfInterest)

# Now limit the PCASL values to just the columns of interest
ctValues <- ctValues[,colsOfInterest]

# Now change their names
columnNames <- gsub(x=gsub(x=columnValues$JLF.Column.Names, pattern='%MODALITY%', replacement='mprage'), pattern='%MEASURE%', replacement='ct')[which(columnValues$CT==0)]
colnames(ctValues)[3:length(ctValues)] <- as.character(columnNames)

# Now order and rename the files
ctValues[,2] <- strSplitMatrixReturn(ctValues$subject.1., 'x')[,2]
colnames(ctValues)[1:2] <- c('bblid', 'scanid')

# Now write the csv
write.csv(ctValues, '/data/joy/BBL/projects/pncReproc2015/antsCT/jlfAntsValuesCT.csv', quote=F, row.names=F)
write.csv(ctValues, paste('/data/joy/BBL/studies/pnc/n2416_dataFreeze/neuroimaging/t1struct/n2416_jlfAntsCTIntersectionCt_',format(Sys.Date(), format="%Y%m%d"),'.csv', sep=''), quote=F, row.names=F)

# Now do the n1601 specific csv
n1601.ct.vals <- merge(n1601.subjs, ctValues, by=c('bblid', 'scanid'))
write.csv(n1601.ct.vals, '/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/t1struct/n1601_jlfAntsCTIntersectionCt.csv', quote=F, row.names=F)
