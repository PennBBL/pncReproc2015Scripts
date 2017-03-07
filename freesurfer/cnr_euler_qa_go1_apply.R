#MQ November 11,2015

#This script takes the CNR and Euler number output from 
#/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts_mv_20161007/freesurfer/cnr_euler_number_calculation.sh
#for GO1/GO2 Freesurfer version 5.3 reprocessing and does the following:
### 1) merges the files into an aggregate qa file and cleans data
### 2) compares the cnr measures to euler numbers as well as to other automatic qa measures 
###    (from /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts_mv_20161007/freesurfer/QA.sh)
### 3) creates descriptive statistics plots and tables of each cnr and euler measure
### 4) examine how these measures relate to diagnosis (dxpmr4)

#load libraries
library(ggplot2)

############################################
###########DATA PREP########################

#read in data
output.dir<-commandArgs(TRUE)[1]
#output.dir<-"/data/joy/BBL/projects/pncReproc2015/freesurfer/stats5_3"
subjnum<-commandArgs(TRUE)[4]
#subjnum<- "n2416"
cnr_data<- read.csv(paste(output.dir,"/cnr/",subjnum,"_cnr_buckner.csv",sep=""))
euler_data<- read.csv(paste(output.dir,"/cnr/",subjnum,"_euler_number.csv",sep=""))
calc_subset_list<-read.csv(commandArgs(TRUE)[2])
#calc_subset_list<-read.csv("/data/joy/BBL/projects/pncReproc2015/antsCT/n1601_bblid_scanid_dateid.csv")
manual_t1_qa<-read.csv(commandArgs(TRUE)[3])
#manual_t1_qa<-read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/t1struct/n1601_t1QaData_20170306.csv")
#demos<- read.csv("/data/joy/BBL/studies/pnc/subjectData/n1601_go1_datarel_073015.csv")
demos<-read.csv(commandArgs(TRUE)[5])

#merge the files together by datexscanid
data<- cnr_data
data$left_euler<- euler_data$left_euler[match(data$scanid,euler_data$scanid)]
data$right_euler<- euler_data$right_euler[match(data$scanid,euler_data$scanid)]

#exclude the subjects that failed freesurfer processing (in this sample 4 subjects failed due to very poor scan
#quality and high motion)
exclude_list<- c("3805","4047","5387","4981")
data$scanid_short<-substring(data$scanid,10,100)
data<- data[which(! data$scanid_short %in% exclude_list),]

############################################
###########MEASURE COMPARISON###############

####CNR AND EULER

#create data frame with correlation r value of cnr and euler numbers
cor_cnr_euler_table<- data.frame("measure"=c("gray/csf lh","gray/csf rh", "gray/white lh","gray/white rh","left_euler","right_euler"),"gray_csf_lh"=c(cor(data$graycsflh,data$graycsflh),cor(data$graycsflh,data$graycsfrh),cor(data$graycsflh,data$graywhitelh),cor(data$graycsflh,data$graywhiterh),cor(data$graycsflh,data$left_euler),cor(data$graycsflh,data$right_euler)),"gray_csf_rh"=c(cor(data$graycsfrh,data$graycsflh),cor(data$graycsfrh,data$graycsfrh),cor(data$graycsfrh,data$graywhitelh),cor(data$graycsfrh,data$graywhiterh),cor(data$graycsfrh,data$left_euler),cor(data$graycsfrh,data$right_euler)),"gray_white_lh"=c(cor(data$graywhitelh,data$graycsflh),cor(data$graywhitelh,data$graycsfrh),cor(data$graywhitelh,data$graywhitelh),cor(data$graywhitelh,data$graywhiterh),cor(data$graywhitelh,data$left_euler),cor(data$graywhitelh,data$right_euler)),"gray_white_rh"=c(cor(data$graywhiterh,data$graycsflh),cor(data$graywhiterh,data$graycsfrh),cor(data$graywhiterh,data$graywhitelh),cor(data$graywhiterh,data$graywhiterh),cor(data$graywhiterh,data$left_euler),cor(data$graywhiterh,data$right_euler)),"left_euler"=c(cor(data$left_euler,data$graycsflh),cor(data$left_euler,data$graycsfrh),cor(data$left_euler,data$graywhitelh),cor(data$left_euler,data$graywhiterh),cor(data$left_euler,data$left_euler),cor(data$left_euler,data$right_euler)),"right_euler"=c(cor(data$right_euler,data$graycsflh),cor(data$right_euler,data$graycsfrh),cor(data$right_euler,data$graywhitelh),cor(data$right_euler,data$graywhiterh),cor(data$right_euler,data$left_euler),cor(data$right_euler,data$right_euler)))

#write table out
write.csv(cor_cnr_euler_table, paste("/data/joy/BBL/studies/pnc/subjectData/freesurfer/go1_go2_go3_fs53_cnr_euler_correlation_table_",subjnum,".csv"))

####EULER AND AUTO QA MEASURES

#read in auto qa csv
auto_qa<- read.csv(paste("/data/joy/BBL/projects/pncReproc2015/freesurfer/stats5_3/all.flags.",subjnum,".csv",sep=""))

#subset auto qa to exclude those that failed freesurfer
auto_qa$scanid_short<-substring(auto_qa$scanid,10,100)
auto_qa<- auto_qa[which(! auto_qa$scanid_short %in% exclude_list),]

#create data frame with correlation r value of cnr/euler numbers vs autoqa
cor_autoqa_table<- data.frame("measure"=c("gray/csf lh","gray/csf rh", "gray/white lh","gray/white rh","left_euler","right_euler"),"meanthickness_outlier"=c(cor(auto_qa$meanthickness_outlier,data$graycsflh),cor(auto_qa$meanthickness_outlier,data$graycsfrh),cor(auto_qa$meanthickness_outlier,data$graywhitelh),cor(auto_qa$meanthickness_outlier,data$graywhiterh),cor(auto_qa$meanthickness_outlier,data$left_euler),cor(auto_qa$meanthickness_outlier,data$right_euler)),"totalarea_outlier"=c(cor(auto_qa$totalarea_outlier,data$graycsflh),cor(auto_qa$totalarea_outlier,data$graycsfrh),cor(auto_qa$totalarea_outlier,data$graywhitelh),cor(auto_qa$totalarea_outlier,data$graywhiterh),cor(auto_qa$totalarea_outlier,data$left_euler),cor(auto_qa$totalarea_outlier,data$right_euler)),"cnr_outlier"=c(cor(auto_qa$cnr_outlier,data$graycsflh),cor(auto_qa$cnr_outlier,data$graycsfrh),cor(auto_qa$cnr_outlier,data$graywhitelh),cor(auto_qa$cnr_outlier,data$graywhiterh),cor(auto_qa$cnr_outlier,data$left_euler),cor(auto_qa$cnr_outlier,data$right_euler)),"snr_outlier"=c(cor(auto_qa$snr_outlier,data$graycsflh),cor(auto_qa$snr_outlier,data$graycsfrh),cor(auto_qa$snr_outlier,data$graywhitelh),cor(auto_qa$snr_outlier,data$graywhiterh),cor(auto_qa$snr_outlier,data$left_euler),cor(auto_qa$snr_outlier,data$right_euler)),"noutliers.thickness.rois_outlier"=c(cor(auto_qa$noutliers.thickness.rois_outlier,data$graycsflh),cor(auto_qa$noutliers.thickness.rois_outlier,data$graycsfrh),cor(auto_qa$noutliers.thickness.rois_outlier,data$graywhitelh),cor(auto_qa$noutliers.thickness.rois_outlier,data$graywhiterh),cor(auto_qa$noutliers.thickness.rois_outlier,data$left_euler),cor(auto_qa$noutliers.thickness.rois_outlier,data$right_euler)),"noutliers.lat.thickness.rois_outlier"=c(cor(auto_qa$noutliers.lat.thickness.rois_outlier,data$graycsflh),cor(auto_qa$noutliers.lat.thickness.rois_outlier,data$graycsfrh),cor(auto_qa$noutliers.lat.thickness.rois_outlier,data$graywhitelh),cor(auto_qa$noutliers.lat.thickness.rois_outlier,data$graywhiterh),cor(auto_qa$noutliers.lat.thickness.rois_outlier,data$left_euler),cor(auto_qa$noutliers.lat.thickness.rois_outlier,data$right_euler)))

#write out table
write.csv(cor_autoqa_table, paste("/data/joy/BBL/studies/pnc/subjectData/freesurfer/go1_go2_go3_fs53_cnr_euler_autoqa_correlation_table_",subjnum,".csv"))

############################################
###########DEMOGRAPHICS###############

#create data frame called data2
data2<- data

#merge dxpmr4 and age into cnr and euler data
data2$age<- demos$ageAtGo1Scan[match(data2$scanid_short,demos$scanid)]
data2$dxpmr4<- demos$goassessDxpmr4[match(data2$scanid_short,demos$scanid)]

#subset data to only go1 data (only have go1 dx)
data2<- data2[! is.na(data2$dxpmr4),]

############################################
###########DISTRIBUTION PLOTS###############

#write graphs to a pdf
pdf(paste("/data/joy/BBL/studies/pnc/subjectData/freesurfer/go1_go2_go3_fs53_cnr_euler_distribution_plots_",subjnum,".pdf"))

#loop through columns in data and plot histogram and scatterplot for each measure
for (i in 3:9){
  
  #get range and dynamically create binwidth for histogram (cnr and euler numbers have very different value ranges)
  bw<- (max(data[,i])-min(data[,i]))/10
  
  #histogram
  g<- ggplot(data, aes(x=data[,i])) +
    geom_histogram(binwidth=bw,colour="black", fill="white") +
    ggtitle(colnames(data)[i]) +
    xlab(colnames(data)[i])
  
  print(g)
  
  #scatterplot
  h<- ggplot(data2, aes(x=age, y=data2[,i], color=dxpmr4)) +
    geom_point(shape=1) +
    ggtitle(paste("GO1",colnames(data2)[i],sep=" ")) +
    ylab(colnames(data2)[i]) +
    xlab("Age") +
    geom_hline(aes(yintercept=mean(data2[,i])), colour="blue", linetype="dashed") +
    geom_hline(aes(yintercept=mean(data2[,i])-2*sd(data2[,i])), colour="yellow", linetype="dashed") +
    geom_hline(aes(yintercept=mean(data2[,i])-2.5*sd(data2[,i])), colour="orange", linetype="dashed") +
    geom_hline(aes(yintercept=mean(data2[,i])-3*sd(data2[,i])), colour="red", linetype="dashed") 
  
  print(h)
  
}

dev.off()

#################################################
###########BINARY EXCLUSION FLAGS################

#create a dataframe which will get the flags based on euler and cnr calculations
flags<- data

#get mean values for gray/csf cnr, gray/white cnr and euler numbers (average across hemispheres)
flags$mean_euler<-(flags$left_euler+flags$right_euler)/2
flags$mean_graycsf_cnr<- (flags$graycsflh+flags$graycsfrh)/2
flags$mean_graywhite_cnr<- (flags$graywhitelh+flags$graywhiterh)/2

#subset data frame to only IDs and averages
flags<- flags[,c(1,2,11:13)]


#subset flags data to new data frame with only GO1 data without manual exclude of 0
calc_subset_list$average_manual_qa<- manual_t1_qa$averageManualRating[match(calc_subset_list$scanid,manual_t1_qa$scanid)]
calc_subset_list<- calc_subset_list[! calc_subset_list$average_manual_qa=="0",]

flags_go1<- flags[flags$scanid %in% calc_subset_list$datexscanid,]


#create variables that get the standard deviation for GO1 cnr and euler number averages
graycsf_cutoff<- mean(flags_go1$mean_graycsf_cnr-(2*sd(flags_go1$mean_graycsf_cnr)))
graywhite_cutoff<- mean(flags_go1$mean_graywhite_cnr-(2*sd(flags_go1$mean_graywhite_cnr)))
euler_cutoff<- mean(flags_go1$mean_euler-(2*sd(flags_go1$mean_euler)))

#create a binary flag column (1=yes, 0=no) for average cnr and euler numbers (<2 SD =1, >2 SD=0)
flags$graycsf_flag<- NA
flags$graywhite_flag<- NA
flags$euler_flag<- NA

for (i in 1:nrow(flags)){
  if (flags$mean_graycsf_cnr[i]<=graycsf_cutoff){
    flags$graycsf_flag[i]<- 1
  } else if (flags$mean_graycsf_cnr[i]>graycsf_cutoff){
    flags$graycsf_flag[i]<- 0 
  }
  if (flags$mean_graywhite_cnr[i]<=graywhite_cutoff){
    flags$graywhite_flag[i]<- 1
  } else if (flags$mean_graywhite_cnr[i]>graywhite_cutoff){
    flags$graywhite_flag[i]<- 0 
  }
  if (flags$mean_euler[i]<=euler_cutoff){
    flags$euler_flag[i]<- 1
  } else if (flags$mean_euler[i]>euler_cutoff){
    flags$euler_flag[i]<- 0 
  }
  
} # for (i in 1:nrow(flags)){

#merge in number of outliers roi thickness from the auto qa
flags$noutliers.thickness.rois_outlier<- auto_qa$noutliers.thickness.rois_outlier[match(flags$scanid,auto_qa$scanid)]

#subset data frame to only IDs and flags
flags<- flags[,c(1,2,6:9)]

#create a total outliers column which gets the number of total outliers and a column which gets a binary flag 1=yes, 0=no
flags$total_outliers<- NA
x<- cbind(flags$graycsf_flag,flags$graywhite_flag,flags$euler_flag,flags$noutliers.thickness.rois_outlier)
flags$total_outliers<- apply(x,1,sum)
flags$flagged<- flags$total_outliers
flags$flagged[flags$flagged>0]<- 1

#write out flagged data
write.csv(flags,paste("/data/joy/BBL/projects/pncReproc2015/freesurfer/stats5_3/cnr_euler_flags_go1_based_",subjnum,".csv"))

#################################################
###########EXCLUSIONS BY DIAGNOSIS###############

data2$flagged<- flags$flagged[match(data2$bblid,flags$bblid)]


table(data2$flagged,data2$dxpmr4)
table(data2$flagged,data2$age)

mean(data2$age[data2$flagged==1])
