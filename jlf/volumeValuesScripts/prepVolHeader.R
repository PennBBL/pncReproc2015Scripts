# AFGR August 5 2016

##Usage##
# This script is going to be used to prepare the column names from the output of the fslhist command for JLF values

# Load library(s)
source('/home/arosen/adroseHelperScripts/R/afgrHelpFunc.R')
install_load('tools')

# Load data
inputDataValues <- commandArgs()[5]
valuesToFix <- read.csv(inputDataValues, header=T)
columnNames <- read.csv('/data/joy/BBL/projects/pncReproc2015/jlf/volumeValues/jlfVolNames.csv')
columnNumbers <- read.csv('/data/joy/BBL/projects/pncReproc2015/jlf/volumeValues/justMuseColNamesafgrEdits.csv')

# Now I need to take only the columns of interest
colsOfInterest <- columnNumbers$ROI_INDEX[115:length(columnNumbers$ROI_INDEX)] + 3
colsOfInterest <- append(c(1,2), colsOfInterest)

# Now limit volume values just to those of interest
volumeValues <- valuesToFix[,colsOfInterest]

# Now change the names
colnames(volumeValues)[3:length(volumeValues)] <- as.character(columnNames$X)

# Now rm the white matter columns because we don't have any values there...
volumeValues <- volumeValues[,-seq(41,55)]

# Now write the output csv
outputFileName <- paste(file_path_sans_ext(inputDataValues), "ProperColNames.csv", sep='')
write.csv(volumeValues, outputFileName, quote=F, row.names=F)
