# this is a subscript of QA.sh that should run at the end of the script.
# The other scripts called by QA.sh create some csvs with thickness, volume,
# surface area, and curvature. This script flags all of these based 2sd outliers.
# The measures that are flagged are based on comments here:
# http://saturn/wiki/index.php/QA

### ARGS ###
############
subjects.dir<-commandArgs(TRUE)[1]
#subjects.dir<-"/data/joy/BBL/projects/pncReproc2015/freesurfer/stats5_3"
calc_subset_list<-read.csv(commandArgs(TRUE)[2])
#calc_subset_list<-read.csv("/data/joy/BBL/projects/pncReproc2015/antsCT/n1601_bblid_scanid_dateid.csv")
sdthresh<-commandArgs(TRUE)[3]
#sdthresh<-2
manual_t1_qa<-read.csv(commandArgs(TRUE)[4])
#manual_t1_qa<-read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/t1struct/n1601_t1QaData_20170306.csv")
subjnum<-read.csv(commandArgs(TRUE)[5])
#subjnum<- "n2416"

### DIRS ###
############
#stats.dir<-file.path(subjects.dir, 'stats')
stats.dir<-file.path(subjects.dir)
aparc.dir<-file.path(stats.dir, 'aparc.stats')
aseg.dir<-file.path(stats.dir, 'aseg.stats')
area.dir<-file.path(stats.dir, 'aparc.stats/area')
curvature.dir<-file.path(stats.dir, 'aparc.stats/curvature')

### MEAN FILES ###
##################
mean.file<-file.path(aparc.dir, paste(subjnum, '_bilateral.meanthickness.totalarea.csv',sep=""))
cnr.file<-file.path(stats.dir, 'cnr', paste(subjnum, '_cnr_buckner.csv',sep=""))
snr.file<-file.path(stats.dir, 'cnr', paste(subjnum, '_snr.txt',sep=""))
aseg.volume.file<-file.path(aseg.dir, paste(subjnum, '_aseg.stats.volume.csv',sep=""))
lh.thickness.file<-file.path(aparc.dir, paste(subjnum, '_lh.aparc.stats.thickness.csv',sep=""))
rh.thickness.file<-file.path(aparc.dir, paste(subjnum, '_rh.aparc.stats.thickness.csv',sep=""))

### READ MEAN DATA ###
######################
mean.data<-read.csv(mean.file, strip.white=TRUE)
mean.data$meanthickness<-rowMeans(mean.data[, c('rh.meanthickness', 'lh.meanthickness')])
mean.data$totalarea<-rowSums(mean.data[, c('rh.totalarea', 'lh.totalarea')])
mean.data<-mean.data[,!(grepl('lh', names(mean.data)) | grepl('rh', names(mean.data)))]
cnr.data<-read.csv(cnr.file, strip.white=TRUE, header=FALSE)
full<-mean.data
full$cnr<- cnr.data$V3[match(full$scanid,cnr.data$V2)]
full$cnr<- as.numeric(as.character(full$cnr))

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

### CREATE DATA TO CALCULATE SD FROM ###
#########################################
lh.names<-grep('lh', names(thickness.data), value=TRUE)
rh.names<-sub('lh', 'rh', lh.names)


#subset data to only those in list and then also exclude any one that failed manual qa from that list
subset.data<-thickness.data[thickness.data$scanid %in% calc_subset_list$datexscanid,]
subset.data$scanid_short<- calc_subset_list$scanid[match(subset.data$scanid,calc_subset_list$datexscanid)]
subset.data$average_manual_qa<- manual_t1_qa$averageManualRating[match(subset.data$scanid_short,manual_t1_qa$scanid)]

subset.data<- subset.data[! subset.data$average_manual_qa=="0",]

tmp_lh<-data.frame(matrix(NA, nrow=(nrow(thickness.data)),ncol=length(lh.names)+1))
tmp_lh[1]<- thickness.data$scanid
colnames(tmp_lh)[1]<-"scanid"
colnames(tmp_lh)[2:ncol(tmp_lh)]<- lh.names

tmp_rh<-data.frame(matrix(NA, nrow=(nrow(thickness.data)),ncol=length(rh.names)+1))
tmp_rh[1]<- thickness.data$scanid
colnames(tmp_rh)[1]<-"scanid"
colnames(tmp_rh)[2:ncol(tmp_rh)]<- rh.names

#then calculate the 2SD cut off for each lh.name and rh.name and calculate if each subject in the full dataset is a SD outlier based on the threshold you set (sdthresh) calculated only one GO1 and non-0 manual QA subjects

for (i in lh.names){

sd_thresh<-(sdthresh*(sd(subset.data[,i])))

sd_above_value<- mean(subset.data[,i])+sd_thresh
sd_below_value<- mean(subset.data[,i])-sd_thresh

#x<- cbind(sd_above_value,sd_below_value) 
#output<- cbind(output,x)

tmp_lh[i]<- "0"
tmp_lh[i][thickness.data[i]>sd_above_value]<- "1"
tmp_lh[i][thickness.data[i]<sd_below_value]<- "1"

}
for (i in rh.names){

sd_thresh<-(sdthresh*(sd(subset.data[,i])))

sd_above_value<- mean(subset.data[,i])+sd_thresh
sd_below_value<- mean(subset.data[,i])-sd_thresh

tmp_rh[i]<- "0"
tmp_rh[i][thickness.data[i]>sd_above_value]<- "1"
tmp_rh[i][thickness.data[i]<sd_below_value]<- "1"

}

tmp<- cbind(tmp_lh,tmp_rh[2:ncol(tmp_rh)])
tmp2<-data.frame(sapply(tmp[2:ncol(tmp)], function(x) as.numeric(as.character(x))))
tmp2<- cbind(tmp[1],tmp2)

###get number of thickness ROIs (sum of 1's just calculated for each subject)
# count number of outlying regions for each subject
thickness.data$noutliers.thickness.rois<-rowSums(tmp2[2:ncol(tmp2)])

####number of outliers in laterality for each subject
tmp_laterality<-data.frame(matrix(NA, nrow=(nrow(thickness.data)),ncol=length(lh.names)+1))
tmp_laterality[1]<- thickness.data$scanid
colnames(tmp_laterality)[1]<-"scanid"
colnames(tmp_laterality)[2:ncol(tmp_laterality)]<- lh.names


for (z in seq(1, length(lh.names))){
i <- lh.names[z]
  
r_name<- paste("rh",substring(i,4,10000),sep="_")

sd_above_value<-(mean((subset.data[,i] - subset.data[,r_name])/(subset.data[,i] + subset.data[,r_name]))+(sdthresh*(sd((subset.data[,i] - subset.data[,r_name])/(subset.data[,i] + subset.data[,r_name])))))
sd_below_value<-(mean((subset.data[,i] - subset.data[,r_name])/(subset.data[,i] + subset.data[,r_name]))-(sdthresh*(sd((subset.data[,i] - subset.data[,r_name])/(subset.data[,i] + subset.data[,r_name])))))

tmp_laterality[,z+1]<- "0"
tmp_laterality[,z+1][which((thickness.data[,i] - thickness.data[,r_name])/(thickness.data[,i] + thickness.data[,r_name])>sd_above_value)]<- "1"
tmp_laterality[,z+1][which((thickness.data[,i] - thickness.data[,r_name])/(thickness.data[,i] + thickness.data[,r_name])<sd_below_value)]<- "1"

tmp_laterality[,z+1]<- as.numeric(tmp_laterality[,z+1])

}


thickness.data$noutliers.lat.thickness.rois<-rowSums(tmp_laterality[2:ncol(tmp_laterality)])


###DO THE SAME FOR MEAN FLAGS
#subset data to only those in list and then also exclude any one that failed manual qa from that list
subset.data.mean<-full[full$scanid %in% calc_subset_list$datexscanid,]
subset.data.mean$scanid_short<- calc_subset_list$scanid[match(subset.data.mean$scanid,calc_subset_list$datexscanid)]
subset.data.mean$average_manual_qa<- manual_t1_qa$averageManualRating[match(subset.data.mean$scanid_short,manual_t1_qa$scanid)]

subset.data.mean<- subset.data.mean[! subset.data.mean$average_manual_qa=="0",]

mean_names<- c('meanthickness', 'totalarea', "SubCortGrayVol", "CortexVol", "CorticalWhiteMatterVol", "cnr","snr")

tmp_mean<-data.frame(matrix(NA, nrow=(nrow(full)),ncol=length(mean_names)+1))
tmp_mean[1]<- full$scanid
colnames(tmp_mean)[1]<-"scanid"
colnames(tmp_mean)[2:ncol(tmp_mean)]<- mean_names

#then calculate the 2SD cut off for each mean and calculate if each subject in the full dataset is a SD outlier based on the threshold you set (sdthresh) calculated only one GO1 and non-0 manual QA subjects

for (i in mean_names){
  
  sd_thresh<-(sdthresh*(sd(subset.data.mean[,i])))
  
  sd_above_value<- mean(subset.data.mean[,i])+sd_thresh
  sd_below_value<- mean(subset.data.mean[,i])-sd_thresh
  
  tmp_mean[i]<- "0"
  tmp_mean[i][full[i]>sd_above_value]<- "1"
  tmp_mean[i][full[i]<sd_below_value]<- "1"
  
}
colnames(tmp_mean)[2:ncol(tmp_mean)]<- c(paste(mean_names, 'outlier', sep="_"))


### MERGE RESULTS OF ROI FLAGS WITH MEAN DATA ###
#################################################
thickness.data<-thickness.data[,c('bblid', 'scanid', 'noutliers.thickness.rois', 'noutliers.lat.thickness.rois')]
full$noutliers.thickness.rois<- thickness.data$noutliers.thickness.rois[match(full$scanid,thickness.data$scanid)]
full$noutliers.lat.thickness.rois<- thickness.data$noutliers.lat.thickness.rois[match(full$scanid,thickness.data$scanid)]
full$meanthickness_outlier<- tmp_mean$meanthickness_outlier[match(full$scanid,tmp_mean$scanid)]
full$totalarea_outlier<- tmp_mean$totalarea_outlier[match(full$scanid,tmp_mean$scanid)]
full$SubCortGrayVol_outlier<- tmp_mean$SubCortGrayVol_outlier[match(full$scanid,tmp_mean$scanid)]
full$CortexVol_outlier<- tmp_mean$CortexVol_outlier[match(full$scanid,tmp_mean$scanid)]
full$CorticalWhiteMatterVol_outlier<- tmp_mean$CorticalWhiteMatterVol_outlier[match(full$scanid,tmp_mean$scanid)]
full$cnr_outlier<- tmp_mean$cnr_outlier[match(full$scanid,tmp_mean$scanid)]
full$snr_outlier<- tmp_mean$snr_outlier[match(full$scanid,tmp_mean$scanid)]

### FLAG ON MEAN, CNR, SNR, AND NUMBER OF ROI FLAGS ###
#######################################################
flags<-names(full)[which(!names(full) %in% c('bblid', 'scanid'))]



### WRITE DATA OUT ###
######################
noutliers.flags<-grep('noutlier', names(full), value=T)
full[,paste(noutliers.flags, 'outlier', sep="_")]<-as.numeric(scale(full[,noutliers.flags])>sdthresh)
write.csv(full, file.path(stats.dir, paste('all.flags.go1.based.n' , nrow(full),'.csv', sep='')), quote=FALSE, row.names=FALSE)
cat('wrote file to', file.path(stats.dir, paste('all.flags.go1.based.n' , nrow(full),'.csv', sep='')), '\n')
