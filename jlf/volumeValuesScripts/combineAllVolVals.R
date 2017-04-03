# AFGR August 5 2016

##Usage##
# This script is oging to be used to combine all of the:
#	1.) JLF Volumes
#	2.) ANTsCT Volumes
#	3.) Manual QA Values

# Load library(s)
source('/home/arosen/adroseHelperScripts/R/afgrHelpFunc.R')
install_load('tools')

# Load data
jlfVals <- commandArgs()[5]
jlfVals <- read.csv(jlfVals)
jlfWmVals <- commandArgs()[10]
jlfWmVals <- read.csv(jlfWmVals)
ctVals <- commandArgs()[6]
ctVals <- read.csv(ctVals)
voxelDim <- commandArgs()[9]
voxelDim <- read.csv(voxelDim)
voxelDim <- voxelDim[which(duplicated(voxelDim)=='FALSE'),]
n1601.subjs <- read.csv('/data/joy/BBL/projects/pncReproc2015/antsCT/n1601_bblid_scanid_dateid.csv')
n1601.subjs <- n1601.subjs[,c(2,1)]

# Convert all of our voxel counts to mm3
jlfVals <- merge(jlfVals, voxelDim, by=c('subject.0.', 'subject.1.'))
jlfVals[,3:131] <- apply(jlfVals[,3:131], 2, function(x) (x * jlfVals$output))
jlfVals <- jlfVals[,-132]
jlfWmVals <- merge(jlfWmVals, voxelDim, by=c('subject.0.', 'subject.1.'))
jlfWmVals[, 3:14] <- apply(jlfWmVals[,3:14], 2, function(x) (x * jlfWmVals$output))
jlfWmVals <- jlfWmVals[,-15]
ctVals <- merge(ctVals, voxelDim, by=c('subject.0.', 'subject.1.'))
ctVals[,3:9] <- apply(ctVals[,3:9], 2, function(x) (x * ctVals$output))
ctVals <- ctVals[,-10]

# Now fix the column names
colnames(jlfVals)[1:2] <- c('bblid', 'scanid')
colnames(jlfWmVals)[1:2] <- c('bblid', 'scanid')
colnames(ctVals)[1:2] <- c('bblid', 'scanid')

# Now fix scanid
jlfVals[,2] <- strSplitMatrixReturn(charactersToSplit=jlfVals[,2], splitCharacter='x')[,2]
jlfWmVals[,2] <- strSplitMatrixReturn(charactersToSplit=jlfWmVals[,2], splitCharacter='x')[,2]
ctVals[,2] <- strSplitMatrixReturn(charactersToSplit=ctVals[,2], splitCharacter='x')[,2]

## Write the n2416 file's
write.csv(jlfVals, paste('/data/joy/BBL/studies/pnc/n2416_dataFreeze/neuroimaging/t1struct/n2416_jlfAntsCTIntersectionVol_',format(Sys.Date(), format="%Y%m%d"),'.csv', sep=''), quote=F, row.names=F)
write.csv(ctVals, paste('/data/joy/BBL/studies/pnc/n2416_dataFreeze/neuroimaging/t1struct/n2416_antsCtVol_',format(Sys.Date(), format="%Y%m%d"),'.csv', sep=''), quote=F, row.names=F)
write.csv(jlfWmVals, paste('/data/joy/BBL/studies/pnc/n2416_dataFreeze/neuroimaging/t1struct/n2416_jlfWmVol_',format(Sys.Date(), format="%Y%m%d"),'.csv', sep=''), quote=F, row.names=F)

## Now write the n1601 file
# Start with JLF volumes
n1601.vol.vals <- merge(n1601.subjs, jlfVals, by=c('bblid', 'scanid'))
n1601.vol.wm.vals <- merge(n1601.subjs, jlfWmVals, by=c('bblid', 'scanid'))
n1601.vol.ct.vals <- merge(n1601.subjs, ctVals, by=c('bblid', 'scanid'))

# Now write the output
write.csv(n1601.vol.vals, paste('/data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/t1struct/n1601_jlfAntsCTIntersectionVol_',format(Sys.Date(), format="%Y%m%d"),'.csv', sep='') quote=F, row.names=F)
write.csv(n1601.vol.wm.vals, paste('/data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/t1struct/n1601_jlfWmVol_',format(Sys.Date(), format="%Y%m%d"),'.csv', sep=''), quote=F, row.names=F)
write.csv(n1601.vol.ct.vals, paste('/data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/t1struct/n1601_antsCtVol_',format(Sys.Date(), format="%Y%m%d"),'.csv', sep=''), quote=F, row.names=F)
