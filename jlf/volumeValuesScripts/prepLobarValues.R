# AFGR November 22 2016

##Usage##
# This script is going to be used to prepare the lobar values for Cobb Scott.
# Should be pretty simple just will take a while because of all of the find and fslstats hists I need to build

# Load any static data
leftValues <- read.csv('/home/arosen/pncReproc2015Scripts/jlf/wmSegmentation/lobeValuesLeft.csv', header=F)
rightValues <- read.csv('/home/arosen/pncReproc2015Scripts/jlf/wmSegmentation/lobeValuesRight.csv', header=F)

# Now prepare the data 
system("for i in `find /data/joy/BBL/studies/pnc/processedData/structural/jlf/ -name *jlfLobularSegmentaion.nii.gz` ; do vals=`fslstats ${i} -H 25 99 124` ; echo ${i} ${vals} ; done >> /data/joy/BBL/projects/pncReproc2015/jlf/volumeValues/lobarValues.txt")

# Now we need to edit the subject field's
system("R --slave -f /home/arosen/pncReproc2015Scripts/jlf/volumeValuesScripts/prepSubjFields.R /data/joy/BBL/projects/pncReproc2015/jlf/volumeValues/lobarValues.txt")

# Now we need to load the newley created data set
lobarValues <- read.csv('/data/joy/BBL/projects/pncReproc2015/jlf/volumeValues/lobarValuesproperSubjFields.csv')
voxelDim <- read.csv('/data/joy/BBL/projects/pncReproc2015/jlf/volumeValues/voxelVolume_20160805properSubjFields.csv')

# Now limit to fields of interest
colsOfInterest <- c(2,3,4,5,6,7,8,9,10,11,24,25)
lobarValues <- lobarValues[,c(1,2,colsOfInterest+2)]

# Now change our column names
colsNamesOfInterest <- c('Right_Limbic_Lobe', 'Left_Limbic_Lobe', 'Right_Insular_Lobe', 
                        'Left_Insular_Lobe', 'Right_Frontal_Lobe', 'Left_Frontal_Lobe', 
                        'Right_Parietal_Lobe', 'Left_Parietal_Lobe', 'Right_Occipital_Lobe', 
                        'Left_Occipital_Lobe', 'Right_Temporal_Lobe', 'Left_Temporal_Lobe')
colnames(lobarValues) <- c('bblid', 'scanid', colsNamesOfInterest)

# Now convert this to mm3
# First give our voxel values a scanid column
voxelDim[,2] <- strSplitMatrixReturn(voxelDim$subject.1., 'x')[,2]
colnames(voxelDim)[1:2] <- c('bblid', 'scanid')

# Now do the same for our lobar values
lobarValues[,2] <- strSplitMatrixReturn(lobarValues$scanid, 'x')[,2]

# Now merge the two
tmp <- merge(lobarValues, voxelDim, by=c('bblid', 'scanid'))

# Now create the mm3 values
tmp[,3:14] <- apply(tmp[,3:14], 2, function(x) (x * tmp$output))
lobarValues <- tmp[,1:14]

# Write the output file
write.csv(lobarValues, '/home/arosen/testValues.csv', quote=F, row.names=F)
