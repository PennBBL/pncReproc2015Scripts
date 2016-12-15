source('/home/arosen/adroseHelperScripts/R/afgrHelpFunc.R')
# Load data
# First we need to prep the GMD values
system("$XCPEDIR/utils/combineOutput -p /data/joy/BBL/studies/pnc/processedData/restbold/restbold_201607151621/ -f JLFintersect_val_reho.1D -o allJlfIntersectrehoVals.1D")
system("mv /data/joy/BBL/studies/pnc/processedData/restbold/restbold_201607151621/allJlfIntersectrehoVals.1D /data/joy/BBL/projects/pncReproc2015/restbold/prepareValues/")
columnNames <- read.csv("/data/joy/BBL/projects/pncReproc2015/restbold/prepareValues/rehoJlfNames.csv")
columnNumbers <- read.csv("/data/joy/BBL/projects/pncReproc2015/antsCT/justJLFColNamesafgrEdits.csv")
gmdValues <- read.table("/data/joy/BBL/projects/pncReproc2015/restbold/prepareValues/allJlfIntersectrehoVals.1D", header=T)
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
colsToRM <- c(4,5,15,16,17,18,19,22,23,24,25,32,33,34,35,36)
gmdValues <- gmdValues[,-colsToRM]
 
# Now rm datexscanid in order to avoid PHI issues
gmdValues <- gmdValues[,-3]

# Now write the csv
write.csv(gmdValues, '/data/joy/BBL/projects/pncReproc2015/restbold/prepareValues/jlfValuesReho.csv', quote=F, row.names=F)

# Now prepare the n1601 output csv
n1601.gmd.values <- merge(n1601.subjs, gmdValues, by=c('bblid', 'scanid'))
output.df <- n1601.gmd.values
# Now append extra subjects w/o data
bblidToAdd <- n1601.subjs$bblid[which(n1601.subjs$bblid %in% output.df$bblid == 'FALSE')]
scanidToAdd <- n1601.subjs$scanid[which(n1601.subjs$scanid %in% output.df$scanid == 'FALSE')]
tmpToAdd <- as.data.frame(matrix(rep(NA, length(bblidToAdd) * (ncol(output.df)-2)), nrow=length(bblidToAdd), ncol=(ncol(output.df)-2)))
tmpToAdd <- cbind(bblidToAdd, scanidToAdd, tmpToAdd)
colnames(tmpToAdd) <- colnames(output.df)
output.df <- rbind(output.df, tmpToAdd)


write.csv(output.df, '/data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/rest/n1601_jlfAntsCTIntersectionReHo.csv', quote=F, row.names=F)
