# AFGR August 5 2016

##Usage##
# This script is oging to be used to combine all of the:
#	1.) JLF Volumes
#	2.) ANTsCT Volumes
#	3.) Manual QA Values

# Load library(s)
source("/home/arosen/R/x86_64-unknown-linux-gnu-library/helperFunctions/afgrHelpFunc.R")
install_load('tools')

# Declare any functions
strSplitMatrixReturn <- function(charactersToSplit, splitCharacter){
  # Make sure we are dealing with characters
  classCheck <- class(charactersToSplit)
  if(identical(classCheck, "character")=="FALSE"){
    charactersToSplit <- as.character(charactersToSplit)
  }

  # Now we need to find how many columns our output will have 
  colVal <- length(strsplit(charactersToSplit[1], split=splitCharacter)[[1]])
  
  # Now return the matrix of characters!
  output <- matrix(unlist(strsplit(charactersToSplit, split=splitCharacter)), ncol=colVal, byrow=T)

  # Now return the output
  return(output) 
}

# Load data
jlfVals <- commandArgs()[5]
jlfVals <- read.csv(jlfVals)
ctVals <- commandArgs()[6]
ctVals <- read.csv(ctVals)
manQA1 <- commandArgs()[7]
manQA1 <- read.csv(manQA1)
manQA2 <- commandArgs()[8]
manQA2 <- read.csv(manQA2)

# Now make sure everyone has a scanid column
jlfVals$scanid <- strSplitMatrixReturn(jlfVals$subject.1., 'x')[,2]
ctVals$scanid <- strSplitMatrixReturn(ctVals$subject.1., 'x')[,2]

# Now combine the qa data
manQA1 <- manQA1[,-3]
qaData <- rbind(manQA1, manQA2)

output <- merge(jlfVals, ctVals, by='scanid')
output <- merge(output, qaData, by='scanid')

# Just going to do this manually although I know there is a more dynamic fix...
# Fixing column names...
rowsToRM <- NULL
rowsToRM <- grep('bblid', names(output))
rowsToRM <- append(rowsToRM, grep('subject.1..y', names(output))) 
rowsToRM <- append(rowsToRM, grep('subject.0..y', names(output))) 
output <- output[,-rowsToRM]
colnames(output)[2] <- 'bblid'
colnames(output)[3] <- 'datexscanid'

write.csv(output, '/data/joy/BBL/projects/pncReproc2015/jlf/volumeValues/jlfVolumeValues.csv', quote=F, row.names=F)
