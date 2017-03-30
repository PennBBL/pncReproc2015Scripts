# AFGR August 5 2016

##Usage##
# This script is going to be used to prepare the column names from the output of the fslhist command for JLF values

# Load library(s)
source('/home/arosen/adroseHelperScripts/R/afgrHelpFunc.R')
install_load('tools')

# Load data
inputDataValues <- commandArgs()[5]
valuesToFix <- read.csv(inputDataValues, header=T)
columnValues <- read.csv('/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/jlf/labelList/inclusionCheck.csv')

# Now I need to take only the columns of interest
colsOfInterest <- columnValues$Label.Number[which(columnValues$Volume==0)] + 3
colsOfInterest <- append(c(1,2), colsOfInterest)

# Now limit volume values just to those of interest
volumeValues <- valuesToFix[,colsOfInterest]

columnNames <- gsub(x=gsub(x=columnValues$JLF.Column.Names, pattern='%MODALITY%', replacement='mprage'), pattern='%MEASURE%', replacement='vol')[which(columnValues$Volume==0)]

# Now change the names
colnames(volumeValues)[3:length(volumeValues)] <- as.character(columnNames)

# Now write the output csv
outputFileName <- paste(file_path_sans_ext(inputDataValues), "ProperColNames.csv", sep='')
write.csv(volumeValues, outputFileName, quote=F, row.names=F)
