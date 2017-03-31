# AFGR August 10 2016

# This script is going to be used to prepare the header info for the GMD values
# produced by the antsCTPostProcAndGMD.sh script
# Its going to follow the logic of prepAntsCTJLFOutput.R very closley 

# Load data
source('/home/arosen/adroseHelperScripts/R/afgrHelpFunc.R')

# First we need to prep the GMD values
system("$XCPEDIR/utils/combineOutput -p /data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/ -f JLFintersect_antsGMDIsol_val.1D -o antsGMD_JLF_vals.1D")
system("mv /data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/antsGMD_JLF_vals.1D /data/joy/BBL/projects/pncReproc2015/antsCT/")
columnValues <- read.csv("/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/jlf/labelList/inclusionCheck.csv")
gmdValues <- read.table("/data/joy/BBL/projects/pncReproc2015/antsCT/antsGMD_JLF_vals.1D", header=T)
n1601.subjs <- read.csv('/data/joy/BBL/projects/pncReproc2015/antsCT/n1601_bblid_scanid_dateid.csv')
n1601.subjs <- n1601.subjs[,c(2,1)]

# Now I need to limit it to just the NZmeans 
nzCols <- grep('NZMean', names(gmdValues))
nzCols <- append(c(1, 2), nzCols)

gmdValues <- gmdValues[,nzCols]

# Now prepare the column names
colsOfInterest <- columnValues$Label.Number[which(columnValues$GMD==0)] + 2
colsOfInterest <- append(c(1,2), colsOfInterest)

# Now limit the PCASL values to just the columns of interest
gmdValues <- gmdValues[,colsOfInterest] 

# and now change the name of the gmd columns
columnNames <- gsub(x=gsub(x=columnValues$JLF.Column.Names, pattern='%MODALITY%', replacement='mprage'), pattern='%MEASURE%', replacement='ct')[which(columnValues$GMD==0)]
colnames(gmdValues)[3:length(gmdValues)] <- as.character(columnNames)

# Now prepare the subject fields with bblid, scanid
gmdValues[,2] <- strSplitMatrixReturn(gmdValues$subject.1., 'x')[,2]
colnames(gmdValues)[1:2] <- c('bblid', 'scanid')

# Now write the csv
write.csv(gmdValues, '/data/joy/BBL/projects/pncReproc2015/antsCT/jlfAntsValuesGMD.csv', quote=F, row.names=F)
write.csv(gmdValues, paste('/data/joy/BBL/studies/pnc/n2416_dataFreeze/neuroimaging/t1struct/n2416_jlfAntsCTIntersectionGMD_',format(Sys.Date(), format="%Y%m%d"),'.csv', sep=''), quote=F, row.names=F)

# Now prepare the n1601 output csv
n1601.gmd.values <- merge(n1601.subjs, gmdValues, by=c('bblid', 'scanid'))
write.csv(n1601.gmd.values, paste('/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/t1struct/n1601_jlfAtroposIntersectionGMD_',format(Sys.Date(), format="%Y%m%d"),'.csv', sep=''), quote=F, row.names=F)
