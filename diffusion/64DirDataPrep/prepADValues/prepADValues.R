# AFGR 2017 Jan 3rd

# This script is going to be used to prepare all of the FA values for the n1601
# Prior to running this script though two things must be run outside of this in bash
# They can be found below:
# for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_ad_path_nativespace2_JHU-ICBM-tracts-maxprob-thr0-1mm-LPI-2dtitk_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepADValues/tmpVals1.csv
# for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_ad_path_nativespace_JHU-ICBM-tracts-maxprob-thr0-1mm-LPI-2dtitk_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepADValues/tmpVals2.csv
# And then run: ~/adroseHelperScripts/bash/mergeCSV.sh in the directory with the FA values


# load library(s)
source('/home/arosen/adroseHelperScripts/R/afgrHelpFunc.R')

# load data
faVals <- read.csv('/data/joy/BBL/projects/pncReproc2015/diffusion/prepADValues/merged.csv', header=F)
faVals <- faVals[,-c(21,22,23)]
n1601.subjs <- read.csv('/data/joy/BBL/projects/pncReproc2015/antsCT/n1601_bblid_scanid_dateid.csv')
n1601.subjs <- n1601.subjs[,c(2,1)]
original.data <- read.csv('/data/joy/BBL/studies/pnc/subjectData/n1601_go1_datarel_020716.csv')

# Now fix the subject identifier column
faVals[,1] <- strSplitMatrixReturn(strSplitMatrixReturn((strSplitMatrixReturn(strSplitMatrixReturn(faVals[,1], 'subjects/')[,2], 'dti'))[,1], 'x')[,2], '_')

# Now find the names we want to add to the fa values
namesToAdd <- names(original.data)[511:528]
namesToAdd <- gsub(x=namesToAdd, pattern='_fa_', replacement='_ad_')

# Now fix the column names
colnames(faVals) <- c('scanid', 'bblid', namesToAdd)

# Now I need to add rows for the subjects that do not have data for the n1601
output.df <- merge(n1601.subjs, faVals, by=c('bblid', 'scanid'))
bblidToAdd <- n1601.subjs$bblid[which(n1601.subjs$bblid %in% output.df$bblid == 'FALSE')]
scanidToAdd <- n1601.subjs$scanid[which(n1601.subjs$scanid %in% output.df$scanid == 'FALSE')]
tmpToAdd <- as.data.frame(matrix(rep(NA, length(bblidToAdd) * (ncol(output.df)-2)), nrow=length(bblidToAdd), ncol=(ncol(output.df)-2)))
tmpToAdd <- cbind(bblidToAdd, scanidToAdd, tmpToAdd)
colnames(tmpToAdd) <- colnames(output.df)
output.df <- rbind(output.df, tmpToAdd)
output.df <- output.df[!duplicated(output.df),]

# Now write the csv
write.csv(output.df, paste('/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/dti/n1601_JHUTractAD_',format(Sys.Date(), format="%Y%m%d"),'.csv', sep=''), quote=F, row.names=F)

# Load data
faVals <- read.csv('/data/joy/BBL/projects/pncReproc2015/diffusion/prepADValues/tmp/merged.csv', header=F)
faVals <- faVals[,-c(51)]

# Now fix the subject identifier column
faVals[,1] <- strSplitMatrixReturn(strSplitMatrixReturn((strSplitMatrixReturn(strSplitMatrixReturn(faVals[,1], 'subjects/')[,2], 'dti'))[,1], 'x')[,2], '_')

# Now find the names we want to add to the ad values
namesToAdd <- names(original.data)[529:576]
namesToAdd <- gsub(x=namesToAdd, pattern='_fa_', replacement='_ad_')

# Now fix the column names
colnames(faVals) <- c('scanid', 'bblid', namesToAdd)

# Now I need to add rows for the subjects that do not have data for the n1601
output.df <- merge(n1601.subjs, faVals, by=c('bblid', 'scanid'))
bblidToAdd <- n1601.subjs$bblid[which(n1601.subjs$bblid %in% output.df$bblid == 'FALSE')]
scanidToAdd <- n1601.subjs$scanid[which(n1601.subjs$scanid %in% output.df$scanid == 'FALSE')]
tmpToAdd <- as.data.frame(matrix(rep(NA, length(bblidToAdd) * (ncol(output.df)-2)), nrow=length(bblidToAdd), ncol=(ncol(output.df)-2)))
tmpToAdd <- cbind(bblidToAdd, scanidToAdd, tmpToAdd)
colnames(tmpToAdd) <- colnames(output.df)
output.df <- rbind(output.df, tmpToAdd)
output.df <- output.df[!duplicated(output.df),]

# Now write the output csv
write.csv(output.df, paste('/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/dti/n1601_JHULabelsAD_',format(Sys.Date(), format="%Y%m%d"),'.csv', sep=''), quote=F, row.names=F)
