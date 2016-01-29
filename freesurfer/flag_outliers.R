# this is a subscript of QA.sh that should run at the end of the script.
# The other scripts called by QA.sh create some csvs with thickness, volume,
# surface area, and curvature. This script flags all of these based 2sd outliers.
# The measures that are flagged are based on comments here:
# http://saturn/wiki/index.php/QA

### ARGS ###
############
subjects.dir<-commandArgs(TRUE)[1]
sdthresh<-2

### DIRS ###
############
stats.dir<-file.path(subjects.dir, 'stats')
aparc.dir<-file.path(stats.dir, 'aparc.stats')
aseg.dir<-file.path(stats.dir, 'aseg.stats')
area.dir<-file.path(stats.dir, 'aparc.stats/area')
curvature.dir<-file.path(stats.dir, 'aparc.stats/curvature')

### MEAN FILES ###
##################
mean.file<-file.path(aparc.dir, 'bilateral.meanthickness.totalarea.csv')
cnr.file<-file.path(stats.dir, 'cnr/cnr_buckner.csv')
snr.file<-file.path(stats.dir, 'cnr/snr.txt')
aseg.volume.file<-file.path(aseg.dir, 'aseg.stats.volume.csv')
lh.thickness.file<-file.path(aparc.dir, 'lh.aparc.stats.thickness.csv')
rh.thickness.file<-file.path(aparc.dir, 'rh.aparc.stats.thickness.csv')

### READ MEAN DATA ###
######################
mean.data<-read.csv(mean.file, strip.white=TRUE)
mean.data$meanthickness<-rowMeans(mean.data[, c('rh.meanthickness', 'lh.meanthickness')])
mean.data$totalarea<-rowSums(mean.data[, c('rh.totalarea', 'lh.totalarea')])
mean.data<-mean.data[,!(grepl('lh', names(mean.data)) | grepl('rh', names(mean.data)))]
cnr.data<-read.csv(cnr.file, strip.white=TRUE, header=FALSE)
full<-mean.data
full$cnr<- cnr.data$V3[match(full$scanid,cnr.data$V2)]

# the snr evaluation is not robust
# if it seems to have something wrong with it
# this will ignore it.
snr.data<-try(read.table(snr.file, strip.white=TRUE, header=FALSE, col.names=c('subject', 'snr')))
if(is.data.frame(snr.data)){
	snr.data[,c('bblid', 'scanid')]<-apply(do.call(rbind, strsplit(as.character(snr.data$subject), split="/")), 2, as.character)
	snr.data<-snr.data[,-1]
	full$snr<- snr.data$snr[match(full$scanid,snr.data$scanid)]
}

aseg.volume.data<-read.table(aseg.volume.file, strip.white=TRUE, header=TRUE)
aseg.volume.data[,c('bblid', 'scanid')]<-apply(do.call(rbind, strsplit(as.character(aseg.volume.data$Measure.volume), split="/")), 2, as.character)
aseg.volume.data<-aseg.volume.data[,c("bblid", "scanid", "SubCortGrayVol", "CortexVol", "CorticalWhiteMatterVol")]
full$SubCortGrayVol<- aseg.volume.data$SubCortGrayVol[match(full$scanid,aseg.volume.data$scanid)]
full$CortexVol<- aseg.volume.data$CortexVol[match(full$scanid,aseg.volume.data$scanid)]
full$CorticalWhiteMatterVol<- aseg.volume.data$CorticalWhiteMatterVol[match(full$scanid,aseg.volume.data$scanid)]

### READ IN THICKNESS DATA ###
##############################
thickness.data<-read.table(lh.thickness.file, header=TRUE, strip.white=TRUE)
rh.thickness.data<-read.table(rh.thickness.file, header=TRUE, strip.white=TRUE)
thickness.data[,c('bblid', 'scanid')]<-apply(do.call(rbind, strsplit(as.character(thickness.data$lh.aparc.thickness), split="/")), 2, as.character)
rh.thickness.data[,c('bblid', 'scanid')]<-apply(do.call(rbind, strsplit(as.character(rh.thickness.data$rh.aparc.thickness), split="/")), 2, as.character)
rh.thickness.data<-rh.thickness.data[,-1]
thickness.data<-thickness.data[,-1]
thickness.data<-merge(thickness.data, rh.thickness.data, all=TRUE,by=c("scanid","bblid"))
rm('rh.thickness.data')

### FLAG ROI OUTLIERS ###
#########################
lh.names<-grep('lh', names(thickness.data), value=TRUE)
rh.names<-sub('lh', 'rh', lh.names)
# count number of outlying regions for each subject
thickness.data$noutliers.thickness.rois<-rowSums(abs(scale(thickness.data[,c(lh.names, rh.names)]))> sdthresh)
# number of outliers in laterality for each subject
thickness.data$noutliers.lat.thickness.rois<-rowSums(abs(scale(	(thickness.data[,lh.names] - thickness.data[,rh.names])/(thickness.data[,lh.names] + thickness.data[,rh.names])	))> sdthresh)

### MERGE RESULTS OF ROI FLAGS WITH MEAN DATA ###
#################################################
thickness.data<-thickness.data[,c('bblid', 'scanid', 'noutliers.thickness.rois', 'noutliers.lat.thickness.rois')]
full$noutliers.thickness.rois<- thickness.data$noutliers.thickness.rois[match(full$scanid,thickness.data$scanid)]
full$noutliers.lat.thickness.rois<- thickness.data$noutliers.lat.thickness.rois[match(full$scanid,thickness.data$scanid)]

### FLAG ON MEAN, CNR, SNR, AND NUMBER OF ROI FLAGS ###
#######################################################
flags<-names(full)[which(!names(full) %in% c('bblid', 'scanid'))]
mean.flags<-c('meanthickness', 'totalarea', "SubCortGrayVol", "CortexVol", "CorticalWhiteMatterVol")
full[,paste(mean.flags, 'outlier', sep="_")]<-as.numeric(abs(scale(full[,mean.flags]))>sdthresh)
full$cnr_outlier<-as.numeric(scale(full$cnr)<(-sdthresh))
#if(is.data.frame(snr.data))
full$snr_outlier<-as.numeric(scale(full$snr)<(-sdthresh))

noutliers.flags<-grep('noutlier', names(full), value=T)
full[,paste(noutliers.flags, 'outlier', sep="_")]<-as.numeric(scale(full[,noutliers.flags])>sdthresh)
write.csv(full, file.path(stats.dir, paste('all.flags.n' , nrow(full),'.csv', sep='')), quote=FALSE, row.names=FALSE)
cat('wrote file to', file.path(stats.dir, paste('all.flags.n' , nrow(full),'.csv', sep='')), '\n')
