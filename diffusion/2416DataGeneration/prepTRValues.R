# AFGR 2017 Jan 3rd

# This script is going to be used to prepare all of the FA values for the n1601
# Prior to running this script though two things must be run outside of this in bash
# They can be found below:
# for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_tr_path_nativespace_JHU-ICBM-tracts-maxprob-thr0-1mm-LPI-2dtitk_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepTRValues/tmpVals1.csv
# for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_tr_path2_nativespace_JHU-ICBM-tracts-maxprob-thr0-1mm-LPI-2dtitk_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepTRValues/tmpVals2.csv
# And then run: ~/adroseHelperScripts/bash/mergeCSV.sh in the directory with the FA values


# load library(s)
source('/home/arosen/adroseHelperScripts/R/afgrHelpFunc.R')

# load data
faVals <- read.csv('/data/joy/BBL/projects/pncReproc2015/diffusion/prepTRValues/merged.csv', header=F)
faVals <- faVals[,-c(21,22,23)]
n1601.subjs <- read.csv('/data/joy/BBL/projects/pncReproc2015/antsCT/n2416_bblid_scanid.csv')
n1601.subjs <- n1601.subjs[,c(2,)]
original.data <- read.csv('/data/joy/BBL/studies/pnc/subjectData/n1601_go1_datarel_020716.csv')

# Now fix the subject identifier column
faVals[,1] <-  strSplitMatrixReturn(strSplitMatrixReturn((strSplitMatrixReturn(strSplitMatrixReturn(faVals[,1], 'subjects/')[,2], 'dti'))[,1], 'x')[,2], '_')

# Now find the names we want to add to the fa values
namesToAdd <- names(original.data)[511:528]
namesToAdd <- gsub(x=namesToAdd, pattern='_fa_', replacement='_tr_')

# Now fix the column names
colnames(faVals) <- c('scanid', 'bblid', namesToAdd)

# Now I need to add rows for the subjects that do not have data for the n1601
output.df <- merge(n1601.subjs, faVals, by=c('bblid', 'scanid'), all.x=T)

# Now write the csv
write.csv(output.df, '/data/joy/BBL/studies/pnc/n2416_dataFreezeJan2017/neuroimaging/dti/n2416_DTI_JHUTractTR.csv', quote=F, row.names=F)

# Now do the labels 
# for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_tr_path_nativespace_JHU-ICBM-Labels-1mm_LPI_2dtitk_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepTRValues/tmp/tmpValsL1.csv
# for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_tr_path2_nativespace_JHU-ICBM-Labels-1mm_LPI_2dtitk_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepTRValues/tmp/tmpValsL2.csv

# Load data
faVals <- read.csv('/data/joy/BBL/projects/pncReproc2015/diffusion/prepTRValues/tmp/merged.csv', header=F)
faVals <- faVals[,-c(51)]

# Now fix the subject identifier column
faVals[,1] <- strSplitMatrixReturn(strSplitMatrixReturn((strSplitMatrixReturn(strSplitMatrixReturn(faVals[,1], 'subjects/')[,2], 'dti'))[,1], 'x')[,2], '_')

# Now find the names we want to add to the ad values
namesToAdd <- names(original.data)[529:576]
namesToAdd <- gsub(x=namesToAdd, pattern='_fa_', replacement='_tr_')

# Now fix the column names
colnames(faVals) <- c('scanid', 'bblid', namesToAdd)

# Now I need to add rows for the subjects that do not have data for the n1601
output.df <- merge(n1601.subjs, faVals, by=c('bblid', 'scanid'), all.x=T)

# Now write the output csv
write.csv(output.df, '/data/joy/BBL/studies/pnc/n2416_dataFreezeJan2017/neuroimaging/dti/n2416_DTI_JHULabelsTR.csv', quote=F, row.names=F)
