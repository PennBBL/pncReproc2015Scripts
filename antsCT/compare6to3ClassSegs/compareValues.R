## Load library(s)
install_load('corrplot')

# Fiorst I need to prepare all of the values 
# I am going to do this first for the raw JLF values
system("/data/joy/BBL/applications/xcpEngine/utils/combineOutput -p /data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/ -f JLF3classexplore_antsGMDIsol_val.1D -o 3classJLFGMDValues.1D")
system("mv /data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/3classJLFGMDValues.1D /data/joy/BBL/projects/pncReproc2015/antsCT/compare6to3ClassSegs/")

# Now do the intersection values
system("/data/joy/BBL/applications/xcpEngine/utils/combineOutput -p /data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/ -f JLF6classexplore_antsGMDIsol_val.1D -o 6classJLFGMDValues.1D")
system("mv /data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/6classJLFGMDValues.1D /data/joy/BBL/projects/pncReproc2015/antsCT/compare6to3ClassSegs/")

# Now load our data
threeClass <- read.table('/data/joy/BBL/projects/pncReproc2015/antsCT/compare6to3ClassSegs/3classJLFGMDValues.1D', header=T)
sixClass <- read.table('/data/joy/BBL/projects/pncReproc2015/antsCT/compare6to3ClassSegs/6classJLFGMDValues.1D', header=T)
columnNames <- read.csv("/data/joy/BBL/projects/pncReproc2015/antsCT/gmdJlfNames.csv")
columnNumbers <- read.csv("/data/joy/BBL/projects/pncReproc2015/antsCT/justJLFColNamesafgrEdits.csv")

# Now limit to just non zero voxels
# Now I need to limit it to just the NZmeans 
nzCols <- grep('NZMean', names(threeClass))
nzCols <- append(c(1,2), nzCols)

threeClass <- threeClass[,nzCols]
sixClass <- sixClass[,nzCols]


# Now prepare the column names
colsOfInterest <- columnNumbers$ROI_INDEX[115:length(columnNumbers$ROI_INDEX)] + 2
colsOfInterest <- append(c(1,2), colsOfInterest)


# Now isolate columns of interest
threeClass <- threeClass[,colsOfInterest] 
sixClass <- sixClass[,colsOfInterest]

# and now change the name of the gmd columns
colnames(threeClass)[3:length(threeClass)] <- as.character(columnNames$X)
colnames(sixClass)[3:length(sixClass)] <- as.character(columnNames$X)


# Now the WM fix
threeClass <- threeClass[,-seq(41,55)]
sixClass <- sixClass[,-seq(41,55)]

# Now the scanid fix
threeClass[,2] <- strSplitMatrixReturn(threeClass[,2], 'x')[,2]
sixClass[,2] <- strSplitMatrixReturn(sixClass[,2], 'x')[,2]

# Now rm some more WM and ventricles 
colsToRM <- c(4,5,15,16,17,18,19,22,23,24,25,32,33,34,35,36)
colsToRM <- colsToRM-1
threeClass <- threeClass[,-colsToRM]
sixClass <- sixClass[,-colsToRM]

# Now we can compare our values!... finally
# first preparand old and new to our columsn
colnames(threeClass)[3:122] <- paste(names(threeClass[3:122]), '_stathis', sep='')
colnames(sixClass)[3:122] <- paste(names(sixClass[3:122]), '_pcook', sep='')

# First lets create a corellation plot
allVals <- merge(threeClass, sixClass, by=c('subject.0.', 'subject.1.'))
stathisCols <- grep('stathis', names(allVals))
cookCols <- grep('pcook', names(allVals))
corVals <- cor(allVals[,stathisCols[23:120]], allVals[,cookCols[23:120]], use='complete')

# Now extract the diag
vals <- diag(corVals)
