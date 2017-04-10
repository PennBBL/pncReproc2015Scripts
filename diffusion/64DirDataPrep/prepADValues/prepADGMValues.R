# AFGR 2017 Jan 12rd

# This script is going to be used to prepare all of the FA values for the n1601
# Prior to running this script though two things must be run outside of this in bash
# They can be found below:
# for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_rd_path_nativespace_pncTemplateJLF_Labels_LPI_2dtitk_go1_n14_template_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDGMValues/tmpVals1.csv
# for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_rd_path_nativespace2_pncTemplateJLF_Labels_LPI_2dtitk_go1_n14_template_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDGMValues/tmpVals2.csv
# And then run: ~/adroseHelperScripts/bash/mergeCSV.sh in the directory with the MD values

# Source afgr startup script
source('/home/arosen/adroseHelperScripts/R/afgrHelpFunc.R')

# Load data
mdVals <- read.csv('/data/joy/BBL/projects/pncReproc2015/diffusion/prepADValues/merged.csv', header=F)
mdVals <- mdVals[,-c(136)]
n1601.subjs <- read.csv('/data/joy/BBL/projects/pncReproc2015/antsCT/n1601_bblid_scanid_dateid.csv')
n1601.subjs <- n1601.subjs[,c(2,1)]
columnNames <- read.csv('/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/jlf/labelList/inclusionCheck.csv')
columnNames <- columnNames[-31,]
namesToAdd <- gsub(x=gsub(x=columnNames$JLF.Column.Names, pattern='%MODALITY%', replacement='dti'), pattern='%MEASURE%', replacement='ad')

# Now fix the subject identifier column
mdVals[,1] <- strSplitMatrixReturn(strSplitMatrixReturn((strSplitMatrixReturn(strSplitMatrixReturn(mdVals[,1], 'subjects/')[,2], 'dti'))[,1], 'x')[,2], '_')

# Now fix the column names
colnames(mdVals) <- c('scanid', 'bblid', as.character(namesToAdd))

# Now remove ROI's we do not have confidence in 
mdVals <- mdVals[,c(1,2,which(columnNames$AD==0)+2)]

# Now I need to add rows for the subjects that do not have data for the n1601
output.df <- merge(n1601.subjs, mdVals, by=c('bblid', 'scanid'))
bblidToAdd <- n1601.subjs$bblid[which(n1601.subjs$bblid %in% output.df$bblid == 'FALSE')]
scanidToAdd <- n1601.subjs$scanid[which(n1601.subjs$scanid %in% output.df$scanid == 'FALSE')]
tmpToAdd <- as.data.frame(matrix(rep(NA, length(bblidToAdd) * (ncol(output.df)-2)), nrow=length(bblidToAdd), ncol=(ncol(output.df)-2)))
tmpToAdd <- cbind(bblidToAdd, scanidToAdd, tmpToAdd)
colnames(tmpToAdd) <- colnames(output.df)
output.df <- rbind(output.df, tmpToAdd)
output.df <- output.df[!duplicated(output.df),]

# Now write the csv
write.csv(output.df, paste('/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/dti/n1601_jlfADValues_',format(Sys.Date(), format="%Y%m%d"),'.csv', sep=''), quote=F, row.names=F)
