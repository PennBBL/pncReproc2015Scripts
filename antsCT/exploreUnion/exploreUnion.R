# AFGR November 28 2016
# This script is going to be used to compare the raw JLF gmd values vs the GMD values w/ the JLF segmentation masked by
# the ANTsCT tissue segmentation
# Won't be quick becaus eI will have to comebine all of the outputs and what not

## Load library(s)
install_load('corrplot')

# Fiorst I need to prepare all of the values 
# I am going to do this first for the raw JLF values
system("/data/joy/BBL/applications/xcpEngine/utils/combineOutput -p /data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/ -f JLF_antsGMD_val.1D -o rawJLFGMDValues.1D")
system("mv /data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/rawJLFGMDValues.1D /data/joy/BBL/projects/pncReproc2015/antsCT/exploreUnionValues/")

# Now do the intersection values
system("/data/joy/BBL/applications/xcpEngine/utils/combineOutput -p /data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/ -f JLF_Union_antsGMD_val.1D -o unionJLFGMDValues.1D")
system("mv /data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/unionJLFGMDValues.1D /data/joy/BBL/projects/pncReproc2015/antsCT/exploreUnionValues/")

# Now load the data
unionVals <- read.table('/data/joy/BBL/projects/pncReproc2015/antsCT/exploreUnionValues/unionJLFGMDValues.1D', header=T)
rawVals <- read.table('/data/joy/BBL/projects/pncReproc2015/antsCT/exploreUnionValues/rawJLFGMDValues.1D', header=T)
columnNames <- read.csv("/data/joy/BBL/projects/pncReproc2015/antsCT/gmdJlfNames.csv")
columnNumbers <- read.csv("/data/joy/BBL/projects/pncReproc2015/antsCT/justJLFColNamesafgrEdits.csv")


# Now I need to limit it to just the NZmeans 
nzCols <- grep('NZMean', names(rawVals))
nzCols <- append(c(1,2), nzCols)

unionVals <- unionVals[,nzCols]
rawVals <- rawVals[,nzCols]

# Now I am going to replicate the syntax used in this script to produce the proper column headers:
# Script here: https://github.com/PennBBL/pncReproc2015Scripts/blob/master/antsCT/prepAtroposGMDJLFOutput.R

# Now prepare the column names
colsOfInterest <- columnNumbers$ROI_INDEX[115:length(columnNumbers$ROI_INDEX)] + 2
colsOfInterest <- append(c(1,2), colsOfInterest)


# Now isolate columns of interest
unionVals <- unionVals[,colsOfInterest] 
rawVals <- rawVals[,colsOfInterest]

# and now change the name of the gmd columns
colnames(unionVals)[3:length(unionVals)] <- as.character(columnNames$X)
colnames(rawVals)[3:length(rawVals)] <- as.character(columnNames$X)

# Now the WM fix
unionVals <- unionVals[,-seq(41,55)]
rawVals <- rawVals[,-seq(41,55)]

# Now the scanid fix
unionVals[,2] <- strSplitMatrixReturn(unionVals[,2], 'x')[,2]
rawVals[,2] <- strSplitMatrixReturn(rawVals[,2], 'x')[,2]

# Now rm some more WM and ventricles 
colsToRM <- c(4,5,15,16,17,18,19,22,23,24,25,32,33,34,35,36)
colsToRM <- colsToRM-1
unionVals <- unionVals[,-colsToRM]
rawVals <- rawVals[,-colsToRM]

# Now we can compare our values!... finally
# first preparand old and new to our columsn
colnames(unionVals)[3:122] <- paste(names(unionVals[3:122]), '_new', sep='')
colnames(rawVals)[3:122] <- paste(names(rawVals[3:122]), '_old', sep='')



# First lets create a corellation plot
allVals <- merge(unionVals, rawVals, by=c('subject.0.', 'subject.1.'))
oldCols <- grep('old', names(allVals))
newCols <- grep('new', names(allVals))
corVals <- cor(allVals[,oldCols], allVals[,newCols], use='complete')

# Now extract the diag
vals <- diag(corVals)


# Now find difference in total mean vals
meanGMDUnion <- apply(unionVals[,25:122], 1, function(x) mean(x, na.rm=F))
meanGMDRaw <- apply(rawVals[,25:122], 1, function(x) mean(x, na.rm=F))
