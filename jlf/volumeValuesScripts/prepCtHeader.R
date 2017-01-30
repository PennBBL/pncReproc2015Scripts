# AFGR August 5 2016

##Usage##
# This script is going to be used to prepare the column names from the output of the fslhist command for antsCT

# Load library(s)
source('/home/arosen/adroseHelperScripts/R/afgrHelpFunc.R')
install_load('tools')

# Load data
inputDataValues <- commandArgs()[5]
valuesToFix <- read.csv(inputDataValues, header=T)
columnNames <- read.csv('/data/joy/BBL/projects/pncReproc2015/jlf/volumeValues/ctVolNames.csv')

# Now rm the background column
valuesToFix <- valuesToFix[,-3]

# Now change the names
colnames(valuesToFix)[3:length(valuesToFix)] <- as.character(columnNames$X)

# Now compute TBV
valuesToFix$mprage_antsCT_vol_TBV <- apply(valuesToFix[,3:8], 1, sum)

# Now write the output csv
outputFileName <- paste(file_path_sans_ext(inputDataValues), "ProperColNames.csv", sep='')
write.csv(valuesToFix, outputFileName, quote=F, row.names=F)
