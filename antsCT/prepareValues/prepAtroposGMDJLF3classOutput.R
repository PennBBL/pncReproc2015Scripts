# AFGR August 10 2016

# This script is going to be used to prepare the header info for the GMD values
# produced by the antsCTPostProcAndGMD.sh script
# Its going to follow the logic of prepAntsCTJLFOutput.R very closley 

# Load data
source('/home/arosen/adroseHelperScripts/R/afgrHelpFunc.R')

# First we need to prep the GMD values
system("$XCPEDIR/utils/combineOutput -p /data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/ -f JLFintersect_antsGMDIsol_val.1D -o antsGMD_JLF_vals.1D")
system("mv /data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/antsGMD_JLF_vals.1D /data/joy/BBL/projects/pncReproc2015/antsCT/")
columnNames <- read.csv("/data/joy/BBL/projects/pncReproc2015/antsCT/gmdJlfNames.csv")
columnNumbers <- read.csv("/data/joy/BBL/projects/pncReproc2015/antsCT/justJLFColNamesafgrEdits.csv")
gmdValues <- read.table("/data/joy/BBL/projects/pncReproc2015/antsCT/antsGMD_JLF_vals.1D", header=T)
n1601.subjs <- read.csv('/data/joy/BBL/projects/pncReproc2015/antsCT/n1601_bblid_scanid_dateid.csv')
n1601.subjs <- n1601.subjs[,c(2,1)]

# Now I need to limit it to just the NZmeans 
nzCols <- grep('NZMean', names(gmdValues))
nzCols <- append(c(1, 2), nzCols)

gmdValues <- gmdValues[,nzCols]

# Now prepare the column names
colsOfInterest <- columnNumbers$ROI_INDEX[115:length(columnNumbers$ROI_INDEX)] + 2
colsOfInterest <- append(c(1,2), colsOfInterest)

# Now limit the PCASL values to just the columns of interest
gmdValues <- gmdValues[,colsOfInterest] 

# and now change the name of the gmd columns
colnames(gmdValues)[3:length(gmdValues)] <- as.character(columnNames$X)

# And now do the WM fix
gmdValues <- gmdValues[,-seq(41,55)]

# Now prepare the subject fields with bblid, scanid, and datexscanid
gmdValues$scanid <- strSplitMatrixReturn(gmdValues$subject.1., 'x')[,2]
colnames(gmdValues)[1:2] <- c('bblid', 'datexscanid')
attach(gmdValues)
output <- as.data.frame(cbind(bblid, scanid, datexscanid, gmdValues[,3:138]))
detach(gmdValues)
gmdValues <- output

# Now rm columns we aren't concerned with
colsToRM <- c(4,5,15,16,17,18,19,22,23,24,25,32,33,34,35,36,40,41)
gmdValues <- gmdValues[,-colsToRM]
 
# Now rm datexscanid in order to avoid PHI issues
gmdValues <- gmdValues[,-3]

# Now write the csv
write.csv(gmdValues, '/data/joy/BBL/projects/pncReproc2015/antsCT/jlfAntsValuesGMD.csv', quote=F, row.names=F)
write.csv(gmdValues, paste('/data/joy/BBL/studies/pnc/n2416_dataFreeze/neuroimaging/t1struct/n2416_jlfAntsCTIntersectionGMD_',format(Sys.Date(), format="%Y%m%d"),'.csv', sep=''), quote=F, row.names=F)

# Now prepare the n1601 output csv
n1601.gmd.values <- merge(n1601.subjs, gmdValues, by=c('bblid', 'scanid'))
write.csv(n1601.gmd.values, paste('/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/t1struct/n1601_jlfAtroposIntersectionGMD_',format(Sys.Date(), format="%Y%m%d"),'.csv', sep=''), quote=F, row.names=F)
