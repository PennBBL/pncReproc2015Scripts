# AFGR August 5 2016

##Usage##
# This script is going to be used to prepare the subject fields from the output of fslstats hist command

# Load library(s)
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

# Load the data
inputDataValues <- commandArgs()[5]
valuesToFix <- read.table(inputDataValues, header=F)

# Now find the bblid field
characterMatrix <- strSplitMatrixReturn(valuesToFix[,1], '/')
uniqueLengths <- apply(characterMatrix, 2, unique)
# Now find which lengths are longer then 1 for the unqiue length
longerThenOne <- NULL
for(i in seq(1, length(uniqueLengths))){
  lengthCheck <- length(uniqueLengths[[i]])
  if(lengthCheck > 1){
    longerThenOne <- append(longerThenOne, i)
  }
}

# Now do a file extension check to make sure we don't work with the field with file extensions
extCheck <- NULL
for(v in longerThenOne){
  extVal <- file_ext(characterMatrix[1,v])
  if(identical(extVal, "")){
    extCheck <- append(extCheck, v)
  }
}

# Now check to see the length of the values, the shorter will be bblid's
lengthVal1 <- nchar(characterMatrix[1,extCheck[1]])
lengthVal2 <- nchar(characterMatrix[1,extCheck[2]])
if(lengthVal1 < lengthVal2){
  bblidField <- extCheck[1]
  scanidField <- extCheck[2]
}
if(lengthVal1 > lengthVal2){
  bblidField <- extCheck[2]
  scanidField <- extCheck[1]
}

subject.0. <- characterMatrix[,bblidField]
subject.1. <- characterMatrix[,scanidField]

output <- valuesToFix[,-1]
output <- cbind(subject.0., subject.1., output)

outputFileName <- paste(file_path_sans_ext(inputDataValues), "properSubjFields.csv", sep='')
write.csv(output, outputFileName, quote=F, row.names=F)
