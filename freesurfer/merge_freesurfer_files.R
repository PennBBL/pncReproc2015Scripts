#this script will merge the lh and rh freesurfer files on CFN so they are measure specific and only for n1601
n1601_ids<-read.csv("/data/joy/BBL/projects/pncReproc2015/antsCT/n1601_bblid_scanid_dateid.csv")

lh_thick<-read.csv("/data/joy/BBL/projects/pncReproc2015/freesurfer/stats5_3/aparc.stats/lh.aparc.stats.thickness.csv",sep="\t")
rh_thick<-read.csv("/data/joy/BBL/projects/pncReproc2015/freesurfer/stats5_3/aparc.stats/rh.aparc.stats.thickness.csv",sep="\t")

lh_area<-read.csv("/data/joy/BBL/projects/pncReproc2015/freesurfer/stats5_3/aparc.stats/lh.aparc.stats.area.csv",sep="\t")
rh_area<-read.csv("/data/joy/BBL/projects/pncReproc2015/freesurfer/stats5_3/aparc.stats/rh.aparc.stats.area.csv",sep="\t")

lh_vol<-read.csv("/data/joy/BBL/projects/pncReproc2015/freesurfer/stats5_3/aparc.stats/lh.aparc.stats.volume.csv",sep="\t")
rh_vol<-read.csv("/data/joy/BBL/projects/pncReproc2015/freesurfer/stats5_3/aparc.stats/rh.aparc.stats.volume.csv",sep="\t")

aseg<-read.csv("/data/joy/BBL/projects/pncReproc2015/freesurfer/stats5_3/aseg.stats/aseg.stats.volume.csv",sep="\t")

#merge files
thick<- merge(lh_thick,rh_thick,by.x="lh.aparc.thickness",by.y="rh.aparc.thickness",sort=FALSE)
area<- merge(lh_area,rh_area,by.x="lh.aparc.area",by.y="rh.aparc.area",sort=FALSE)
volume<- merge(lh_vol,rh_vol,by.x="lh.aparc.volume",by.y="rh.aparc.volume",sort=FALSE)

#make id columns
thick_id<- as.data.frame(matrix(unlist(strsplit(as.character(thick$lh.aparc.thickness),"/")),ncol=2,byrow=TRUE))
thick_scanid<- as.data.frame(matrix(unlist(strsplit(as.character(thick_id$V2),"x")),ncol=2,byrow=TRUE))[2]
thick<- cbind(thick_id$V1,thick_scanid,thick[2:ncol(thick)])
colnames(thick)[1:2]<- c("bblid","scanid")


area_id<- as.data.frame(matrix(unlist(strsplit(as.character(area$lh.aparc.area),"/")),ncol=2,byrow=TRUE))
area_scanid<- as.data.frame(matrix(unlist(strsplit(as.character(area_id$V2),"x")),ncol=2,byrow=TRUE))[2]
area<- cbind(area_id$V1,area_scanid,area[2:ncol(area)])
colnames(area)[1:2]<- c("bblid","scanid")


vol_id<- as.data.frame(matrix(unlist(strsplit(as.character(volume$lh.aparc.volume),"/")),ncol=2,byrow=TRUE))
vol_scanid<- as.data.frame(matrix(unlist(strsplit(as.character(vol_id$V2),"x")),ncol=2,byrow=TRUE))[2]
volume<- cbind(vol_id$V1,vol_scanid,volume[2:ncol(volume)])
colnames(volume)[1:2]<- c("bblid","scanid")


aseg_id<- as.data.frame(matrix(unlist(strsplit(as.character(aseg$Measure.volume),"/")),ncol=2,byrow=TRUE))
aseg_scanid<- as.data.frame(matrix(unlist(strsplit(as.character(aseg_id$V2),"x")),ncol=2,byrow=TRUE))[2]
aseg<- cbind(aseg_id$V1,aseg_scanid,aseg[2:ncol(aseg)])
colnames(aseg)[1:2]<- c("bblid","scanid")

#subset to n1601
thick<- thick[thick$scanid %in% n1601_ids$scanid,]
area<- area[area$scanid %in% n1601_ids$scanid,]
volume<- volume[volume$scanid %in% n1601_ids$scanid,]
aseg<- aseg[aseg$scanid %in% n1601_ids$scanid,]

#output files
write.csv(thick,file="/data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/t1struct/n1597_freesurferCt.csv",row.names=FALSE)
write.csv(area,file="/data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/t1struct/n1597_freesurferSurfaceArea.csv",row.names=FALSE)
write.csv(volume,file="/data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/t1struct/n1597_freesurferVol.csv",row.names=FALSE)
write.csv(aseg,file="/data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/t1struct/n1597_freesurferAsegVol.csv",row.names=FALSE)
