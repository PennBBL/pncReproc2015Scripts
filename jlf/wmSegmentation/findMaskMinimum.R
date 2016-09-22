# AFGR September 21st 2016

##Usage##
# This script is going to be used to find the minimum value across a time series
# and return the value of the time point in place of that voxel
# This should be used wihtin the createDistanceMetricsMask.sh script


# Turn off warnings
options(warn=-1)

##Declare libraries
source('/home/arosen/adroseHelperScripts/R/afgrHelpFunc.R')
install_load('ANTsR', 'tools')

## Declare a function which will tell us where the local minimum belongs to given a vector
findMinimumLocation <- function(arrayOfValues){
  # find Minimum value
  minVal <- min(arrayOfValues, na.rm=T)
  # Now find index
  minLocation <- which(arrayOfValues == minVal)
  if(length(minLocation) > 1){
    minLocation <- NA
  }
  # Now return it
  return(minLocation)
}

# Declare a function which wil return the 3d coordinate of all TRUE logical values
multi.which <- function(A){
    if ( is.vector(A) ) return(which(A))
    d <- dim(A)
    T <- which(as.logical(A)) - 1
    nd <- length(d)
    t( sapply(T, function(t){
        I <- integer(nd)
        I[1] <- t %% d[1]
        sapply(2:nd, function(j){
            I[j] <<- (t %/% prod(d[1:(j-1)])) %% d[j]
        })
        I
    }) + 1 )
}

# Create a function which will return the Mode of all non 0 neighbors
findNeighbors <- function(matrixAll, x,y,z){
  # First find all neighbors
  allVals <- NULL
  for(s in 1:3){
    if(s == 1){
      tmpX <- x-1
    }
    if(s == 2){
      tmpX <- x
    }
    if(s == 3){
      tmpX <- x + 1
    }
    for(q in 1:3){
      if(q == 1){
        tmpY <- y-1
      }
      if(q == 2){
        tmpY <- y
      }
      if(q == 3){
        tmpY <- y+1
      }
      for(w in 1:3){
        if(w == 1){
          tmpZ <- z-1 
        }
        if(w == 2){
          tmpZ <- z
        }
        if(w == 3){
          tmpZ <- z+1
        }
        newVal <- c(tmpX, tmpY, tmpZ)
        allVals <- append(allVals, newVal)
      }
    }
  }
  allVals <- matrix(allVals, ncol=3, byrow=T)
  # Now rm our center voxel
  allVals <- allVals[-15,]
  
  # Now find the lobe segmentation of that value
  valuesToFind <- NULL
  for(i in 1:dim(allVals)[1]){
    tmpX <- allVals[i,1]
    tmpY <- allVals[i,2]
    tmpZ <- allVals[i,3]
    # Now find the value of this voxel
    valuesToFind <- valuesToFind[which(valuesToFind!=0)]
    valuesToFind <- append(valuesToFind,matrixAll[tmpX, tmpY, tmpZ])
  } 
  return(Mode(valuesToFind))
}

## Now load our data
timeSeries <- commandArgs()[5]
wmMaskOrig <- commandArgs()[6]

## Now we need to load our data
distanceValues <- antsImageRead(filename=timeSeries, dimension=4)
wmMask <- antsImageRead(filename=wmMaskOrig, dimension=3)

## Now lets convert our distance values into a matrix
toWorkWith <- timeseries2matrix(distanceValues, wmMask)

## Now find minimum across time 
lobeValues <- apply(toWorkWith, 2, findMinimumLocation)

# Now creage a segmentation with the new values
newMask <- array(0, dim=dim(wmMask))
newMask[wmMask==1] <- lobeValues

# Now lets deal with ties
logicalMask <- newMask
logicalMask[!is.na(logicalMask)] <- FALSE
logicalMask[is.na(logicalMask)] <- TRUE
coordinates <- multi.which(logicalMask)

# Now find the neighbors values and put that value into the NA
pb <- txtProgressBar(min = 0, max = dim(coordinates)[1], style = 3)
for(p in 1:dim(coordinates)[1]){
  xCoord <- coordinates[p,1]
  yCoord <- coordinates[p,2]
  zCoord <- coordinates[p,3]
  newMask[xCoord,yCoord,zCoord] <- findNeighbors(newMask, xCoord, yCoord, zCoord)
  setTxtProgressBar(pb, p)
}
close(pb)

newMask <- as.antsImage(newMask)
antsCopyImageInfo(wmMask, newMask)
antsImageWrite(image=newMask, filename=paste(file_path_sans_ext(wmMaskOrig, compression=T), "_WithLobeValues.nii.gz", sep=''))
