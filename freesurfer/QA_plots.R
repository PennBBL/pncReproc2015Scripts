#read in freesurfer QA aggregate file created by QA.sh 
data<- read.csv("/data/jag/BBL/studies/pnc/processedData/structural/freesurfer53/stats/all.flags.n2140.csv")

#read in go1 data release demographics
demos<- read.csv("/data/jag/BBL/studies/pnc/subjectData/n1601_go1_datarel_073015.csv")

#change scanid to only the scanid (not datexscanid) so can match demographics
data$scanid<- as.character(data$scanid)
data$scanid<- substring(data$scanid,nchar(data$scanid)-3,nchar(data$scanid))

#get age at go1 scan and diagnosis (dxpmr4) from go1 data release for the 1601 and merge to freesurfer qa data
data$ageatgo1scan<- demos$ageAtGo1Scan[match(data$scanid,demos$scanid)]
data$goassessDxpmr4<- demos$goassessDxpmr4[match(data$scanid,demos$scanid)]

#get rid of data without diagnosis
data<- data[! is.na(data$goassessDxpmr4),]

#create a dataframe which gets count of subjects that were excluded by different auto QA flags
outlier_names<- grep("_outlier",names(data),value=T)
auto_qa_flags<- data.frame(outlier_names,"count"=NA)
for (i in outlier_names){
  auto_qa_flags$count[auto_qa_flags$outlier_names==i]<- sum(data[,i]==1,na.rm=T)
}

#get number of subjects failed freesurfer
fail<- data.frame(outlier_names="failed_freesurfer",count=sum(is.na(data[,i])))

auto_qa_flags<- rbind(auto_qa_flags,fail)

write.csv(auto_qa_flags,"/data/jag/BBL/studies/pnc/subjectData/freesurfer/n1601_fs53_auto_qa_flag_counts.csv")

#do histograms of cnr and snr to see cut offs and scatter of cnr vs snr
#ps<- data[ data$goassessDxpmr4=="4PS",]
#ggplot(ps, aes(x=cnr)) +
#  geom_histogram(binwidth=.05, colour="black", fill="white")
#ggplot(ps, aes(x=snr)) +
#  geom_histogram(binwidth=.5, colour="black", fill="white")
#ggplot(data, aes(x=snr, y=cnr, color=goassessDxpmr4, label=scanid)) +
# geom_point(shape=1) +
#  geom_text(size=3)
#cor.test(data$cnr,data$snr,na.rm=T)

#make scatterplots of age by freesurfer QA split by dx
library(ggplot2)

pdf("/data/jag/BBL/studies/pnc/subjectData/freesurfer/n1601_fs53_age_by_dx_qa_scatterplots.pdf")
#pdf("/data/jag/BBL/studies/pnc/subjectData/freesurfer/n1601_fs53_age_by_dx_cnr_snr_scatterplots.pdf")
ggplot(data, aes(x=ageatgo1scan, y=cnr, color=goassessDxpmr4)) +
  geom_point(shape=1) +
  geom_hline(aes(yintercept=(mean(data$cnr,na.rm=T)-2*sd(data$cnr,na.rm=T))), colour="blue", linetype="dashed") +
  geom_hline(aes(yintercept=(mean(data$cnr,na.rm=T)-2.5*sd(data$cnr,na.rm=T))), colour="yellow", linetype="dashed") +
  geom_hline(aes(yintercept=(mean(data$cnr,na.rm=T)-3*sd(data$cnr,na.rm=T))), colour="orange", linetype="dashed") +
  geom_hline(aes(yintercept=(mean(data$cnr,na.rm=T)-3.5*sd(data$cnr,na.rm=T))), colour="red", linetype="dashed") +
  ggtitle("CNR")

ggplot(data, aes(x=ageatgo1scan, y=snr, color=goassessDxpmr4)) +
  geom_point(shape=1) +
  geom_hline(aes(yintercept=(mean(data$snr,na.rm=T)-2*sd(data$snr,na.rm=T))), colour="blue", linetype="dashed") +
  geom_hline(aes(yintercept=(mean(data$snr,na.rm=T)-2.5*sd(data$snr,na.rm=T))), colour="yellow", linetype="dashed") +
  geom_hline(aes(yintercept=(mean(data$snr,na.rm=T)-3*sd(data$snr,na.rm=T))), colour="orange", linetype="dashed") +
  geom_hline(aes(yintercept=(mean(data$snr,na.rm=T)-3.5*sd(data$snr,na.rm=T))), colour="red", linetype="dashed") +
  ggtitle("SNR")

#dev.off()

ggplot(data, aes(x=ageatgo1scan, y=meanthickness, color=goassessDxpmr4)) +
  geom_point(shape=1) +
  ggtitle("meanthickness")

ggplot(data, aes(x=ageatgo1scan, y=totalarea, color=goassessDxpmr4)) +
  geom_point(shape=1) +
  ggtitle("totalarea")

ggplot(data, aes(x=ageatgo1scan, y=SubCortGrayVol, color=goassessDxpmr4)) +
  geom_point(shape=1) +
  ggtitle("SubCortGrayVol")

ggplot(data, aes(x=ageatgo1scan, y=CortexVol, color=goassessDxpmr4)) +
  geom_point(shape=1) +
  ggtitle("CortexVol")

ggplot(data, aes(x=ageatgo1scan, y=CorticalWhiteMatterVol, color=goassessDxpmr4)) +
  geom_point(shape=1) +
  ggtitle("CorticalWhiteMatterVol")

dev.off()


#quartile the different whole brain measures and look at the breakdown of dx in each quartile

#cnr
cnr_quartile<- quantile(data$cnr,na.rm=T)
cnr_count_per_quartile<- data.frame(dx=c("1TD","2WK","3PC","4PS"),cnr_quartile1=NA,cnr_quartile2=NA,cnr_quartile3=NA,cnr_quartile4=NA)
cnr_count_per_quartile$cnr_quartile1[cnr_count_per_quartile$dx=="1TD"]<- NROW(data$bblid[which(data$cnr<=cnr_quartile[2][[1]] & data$goassessDxpmr4=="1TD")])
cnr_count_per_quartile$cnr_quartile2[cnr_count_per_quartile$dx=="1TD"]<- NROW(data$bblid[which(data$cnr>cnr_quartile[2][[1]] & data$cnr<=cnr_quartile[3][[1]] & data$goassessDxpmr4=="1TD")])
cnr_count_per_quartile$cnr_quartile3[cnr_count_per_quartile$dx=="1TD"]<- NROW(data$bblid[which(data$cnr>cnr_quartile[3][[1]] & data$cnr<cnr_quartile[4][[1]] & data$goassessDxpmr4=="1TD")])
cnr_count_per_quartile$cnr_quartile4[cnr_count_per_quartile$dx=="1TD"]<- NROW(data$bblid[which(data$cnr>=cnr_quartile[4][[1]] & data$goassessDxpmr4=="1TD")])

cnr_count_per_quartile$cnr_quartile1[cnr_count_per_quartile$dx=="2WK"]<- NROW(data$bblid[which(data$cnr<=cnr_quartile[2][[1]] & data$goassessDxpmr4=="2WK")])
cnr_count_per_quartile$cnr_quartile2[cnr_count_per_quartile$dx=="2WK"]<- NROW(data$bblid[which(data$cnr>cnr_quartile[2][[1]] & data$cnr<=cnr_quartile[3][[1]] & data$goassessDxpmr4=="2WK")])
cnr_count_per_quartile$cnr_quartile3[cnr_count_per_quartile$dx=="2WK"]<- NROW(data$bblid[which(data$cnr>cnr_quartile[3][[1]] & data$cnr<cnr_quartile[4][[1]] & data$goassessDxpmr4=="2WK")])
cnr_count_per_quartile$cnr_quartile4[cnr_count_per_quartile$dx=="2WK"]<- NROW(data$bblid[which(data$cnr>=cnr_quartile[4][[1]] & data$goassessDxpmr4=="2WK")])

cnr_count_per_quartile$cnr_quartile1[cnr_count_per_quartile$dx=="3PC"]<- NROW(data$bblid[which(data$cnr<=cnr_quartile[2][[1]] & data$goassessDxpmr4=="3PC")])
cnr_count_per_quartile$cnr_quartile2[cnr_count_per_quartile$dx=="3PC"]<- NROW(data$bblid[which(data$cnr>cnr_quartile[2][[1]] & data$cnr<=cnr_quartile[3][[1]] & data$goassessDxpmr4=="3PC")])
cnr_count_per_quartile$cnr_quartile3[cnr_count_per_quartile$dx=="3PC"]<- NROW(data$bblid[which(data$cnr>cnr_quartile[3][[1]] & data$cnr<cnr_quartile[4][[1]] & data$goassessDxpmr4=="3PC")])
cnr_count_per_quartile$cnr_quartile4[cnr_count_per_quartile$dx=="3PC"]<- NROW(data$bblid[which(data$cnr>=cnr_quartile[4][[1]] & data$goassessDxpmr4=="3PC")])

cnr_count_per_quartile$cnr_quartile1[cnr_count_per_quartile$dx=="4PS"]<- NROW(data$bblid[which(data$cnr<=cnr_quartile[2][[1]] & data$goassessDxpmr4=="4PS")])
cnr_count_per_quartile$cnr_quartile2[cnr_count_per_quartile$dx=="4PS"]<- NROW(data$bblid[which(data$cnr>cnr_quartile[2][[1]] & data$cnr<=cnr_quartile[3][[1]] & data$goassessDxpmr4=="4PS")])
cnr_count_per_quartile$cnr_quartile3[cnr_count_per_quartile$dx=="4PS"]<- NROW(data$bblid[which(data$cnr>cnr_quartile[3][[1]] & data$cnr<cnr_quartile[4][[1]] & data$goassessDxpmr4=="4PS")])
cnr_count_per_quartile$cnr_quartile4[cnr_count_per_quartile$dx=="4PS"]<- NROW(data$bblid[which(data$cnr>=cnr_quartile[4][[1]] & data$goassessDxpmr4=="4PS")])


#snr
snr_quartile<- quantile(data$snr,na.rm=T)
snr_count_per_quartile<- data.frame(dx=c("1TD","2WK","3PC","4PS"),snr_quartile1=NA,snr_quartile2=NA,snr_quartile3=NA,snr_quartile4=NA)
snr_count_per_quartile$snr_quartile1[snr_count_per_quartile$dx=="1TD"]<- NROW(data$bblid[which(data$snr<=snr_quartile[2][[1]] & data$goassessDxpmr4=="1TD")])
snr_count_per_quartile$snr_quartile2[snr_count_per_quartile$dx=="1TD"]<- NROW(data$bblid[which(data$snr>snr_quartile[2][[1]] & data$snr<=snr_quartile[3][[1]] & data$goassessDxpmr4=="1TD")])
snr_count_per_quartile$snr_quartile3[snr_count_per_quartile$dx=="1TD"]<- NROW(data$bblid[which(data$snr>snr_quartile[3][[1]] & data$snr<snr_quartile[4][[1]] & data$goassessDxpmr4=="1TD")])
snr_count_per_quartile$snr_quartile4[snr_count_per_quartile$dx=="1TD"]<- NROW(data$bblid[which(data$snr>=snr_quartile[4][[1]] & data$goassessDxpmr4=="1TD")])

snr_count_per_quartile$snr_quartile1[snr_count_per_quartile$dx=="2WK"]<- NROW(data$bblid[which(data$snr<=snr_quartile[2][[1]] & data$goassessDxpmr4=="2WK")])
snr_count_per_quartile$snr_quartile2[snr_count_per_quartile$dx=="2WK"]<- NROW(data$bblid[which(data$snr>snr_quartile[2][[1]] & data$snr<=snr_quartile[3][[1]] & data$goassessDxpmr4=="2WK")])
snr_count_per_quartile$snr_quartile3[snr_count_per_quartile$dx=="2WK"]<- NROW(data$bblid[which(data$snr>snr_quartile[3][[1]] & data$snr<snr_quartile[4][[1]] & data$goassessDxpmr4=="2WK")])
snr_count_per_quartile$snr_quartile4[snr_count_per_quartile$dx=="2WK"]<- NROW(data$bblid[which(data$snr>=snr_quartile[4][[1]] & data$goassessDxpmr4=="2WK")])

snr_count_per_quartile$snr_quartile1[snr_count_per_quartile$dx=="3PC"]<- NROW(data$bblid[which(data$snr<=snr_quartile[2][[1]] & data$goassessDxpmr4=="3PC")])
snr_count_per_quartile$snr_quartile2[snr_count_per_quartile$dx=="3PC"]<- NROW(data$bblid[which(data$snr>snr_quartile[2][[1]] & data$snr<=snr_quartile[3][[1]] & data$goassessDxpmr4=="3PC")])
snr_count_per_quartile$snr_quartile3[snr_count_per_quartile$dx=="3PC"]<- NROW(data$bblid[which(data$snr>snr_quartile[3][[1]] & data$snr<snr_quartile[4][[1]] & data$goassessDxpmr4=="3PC")])
snr_count_per_quartile$snr_quartile4[snr_count_per_quartile$dx=="3PC"]<- NROW(data$bblid[which(data$snr>=snr_quartile[4][[1]] & data$goassessDxpmr4=="3PC")])

snr_count_per_quartile$snr_quartile1[snr_count_per_quartile$dx=="4PS"]<- NROW(data$bblid[which(data$snr<=snr_quartile[2][[1]] & data$goassessDxpmr4=="4PS")])
snr_count_per_quartile$snr_quartile2[snr_count_per_quartile$dx=="4PS"]<- NROW(data$bblid[which(data$snr>snr_quartile[2][[1]] & data$snr<=snr_quartile[3][[1]] & data$goassessDxpmr4=="4PS")])
snr_count_per_quartile$snr_quartile3[snr_count_per_quartile$dx=="4PS"]<- NROW(data$bblid[which(data$snr>snr_quartile[3][[1]] & data$snr<snr_quartile[4][[1]] & data$goassessDxpmr4=="4PS")])
snr_count_per_quartile$snr_quartile4[snr_count_per_quartile$dx=="4PS"]<- NROW(data$bblid[which(data$snr>=snr_quartile[4][[1]] & data$goassessDxpmr4=="4PS")])

#meanthickness
meanthickness_quartile<- quantile(data$meanthickness,na.rm=T)
meanthickness_count_per_quartile<- data.frame(dx=c("1TD","2WK","3PC","4PS"),meanthickness_quartile1=NA,meanthickness_quartile2=NA,meanthickness_quartile3=NA,meanthickness_quartile4=NA)
meanthickness_count_per_quartile$meanthickness_quartile1[meanthickness_count_per_quartile$dx=="1TD"]<- NROW(data$bblid[which(data$meanthickness<=meanthickness_quartile[2][[1]] & data$goassessDxpmr4=="1TD")])
meanthickness_count_per_quartile$meanthickness_quartile2[meanthickness_count_per_quartile$dx=="1TD"]<- NROW(data$bblid[which(data$meanthickness>meanthickness_quartile[2][[1]] & data$meanthickness<=meanthickness_quartile[3][[1]] & data$goassessDxpmr4=="1TD")])
meanthickness_count_per_quartile$meanthickness_quartile3[meanthickness_count_per_quartile$dx=="1TD"]<- NROW(data$bblid[which(data$meanthickness>meanthickness_quartile[3][[1]] & data$meanthickness<meanthickness_quartile[4][[1]] & data$goassessDxpmr4=="1TD")])
meanthickness_count_per_quartile$meanthickness_quartile4[meanthickness_count_per_quartile$dx=="1TD"]<- NROW(data$bblid[which(data$meanthickness>=meanthickness_quartile[4][[1]] & data$goassessDxpmr4=="1TD")])

meanthickness_count_per_quartile$meanthickness_quartile1[meanthickness_count_per_quartile$dx=="2WK"]<- NROW(data$bblid[which(data$meanthickness<=meanthickness_quartile[2][[1]] & data$goassessDxpmr4=="2WK")])
meanthickness_count_per_quartile$meanthickness_quartile2[meanthickness_count_per_quartile$dx=="2WK"]<- NROW(data$bblid[which(data$meanthickness>meanthickness_quartile[2][[1]] & data$meanthickness<=meanthickness_quartile[3][[1]] & data$goassessDxpmr4=="2WK")])
meanthickness_count_per_quartile$meanthickness_quartile3[meanthickness_count_per_quartile$dx=="2WK"]<- NROW(data$bblid[which(data$meanthickness>meanthickness_quartile[3][[1]] & data$meanthickness<meanthickness_quartile[4][[1]] & data$goassessDxpmr4=="2WK")])
meanthickness_count_per_quartile$meanthickness_quartile4[meanthickness_count_per_quartile$dx=="2WK"]<- NROW(data$bblid[which(data$meanthickness>=meanthickness_quartile[4][[1]] & data$goassessDxpmr4=="2WK")])

meanthickness_count_per_quartile$meanthickness_quartile1[meanthickness_count_per_quartile$dx=="3PC"]<- NROW(data$bblid[which(data$meanthickness<=meanthickness_quartile[2][[1]] & data$goassessDxpmr4=="3PC")])
meanthickness_count_per_quartile$meanthickness_quartile2[meanthickness_count_per_quartile$dx=="3PC"]<- NROW(data$bblid[which(data$meanthickness>meanthickness_quartile[2][[1]] & data$meanthickness<=meanthickness_quartile[3][[1]] & data$goassessDxpmr4=="3PC")])
meanthickness_count_per_quartile$meanthickness_quartile3[meanthickness_count_per_quartile$dx=="3PC"]<- NROW(data$bblid[which(data$meanthickness>meanthickness_quartile[3][[1]] & data$meanthickness<meanthickness_quartile[4][[1]] & data$goassessDxpmr4=="3PC")])
meanthickness_count_per_quartile$meanthickness_quartile4[meanthickness_count_per_quartile$dx=="3PC"]<- NROW(data$bblid[which(data$meanthickness>=meanthickness_quartile[4][[1]] & data$goassessDxpmr4=="3PC")])

meanthickness_count_per_quartile$meanthickness_quartile1[meanthickness_count_per_quartile$dx=="4PS"]<- NROW(data$bblid[which(data$meanthickness<=meanthickness_quartile[2][[1]] & data$goassessDxpmr4=="4PS")])
meanthickness_count_per_quartile$meanthickness_quartile2[meanthickness_count_per_quartile$dx=="4PS"]<- NROW(data$bblid[which(data$meanthickness>meanthickness_quartile[2][[1]] & data$meanthickness<=meanthickness_quartile[3][[1]] & data$goassessDxpmr4=="4PS")])
meanthickness_count_per_quartile$meanthickness_quartile3[meanthickness_count_per_quartile$dx=="4PS"]<- NROW(data$bblid[which(data$meanthickness>meanthickness_quartile[3][[1]] & data$meanthickness<meanthickness_quartile[4][[1]] & data$goassessDxpmr4=="4PS")])
meanthickness_count_per_quartile$meanthickness_quartile4[meanthickness_count_per_quartile$dx=="4PS"]<- NROW(data$bblid[which(data$meanthickness>=meanthickness_quartile[4][[1]] & data$goassessDxpmr4=="4PS")])



#totalarea
totalarea_quartile<- quantile(data$totalarea,na.rm=T)
totalarea_count_per_quartile<- data.frame(dx=c("1TD","2WK","3PC","4PS"),totalarea_quartile1=NA,totalarea_quartile2=NA,totalarea_quartile3=NA,totalarea_quartile4=NA)
totalarea_count_per_quartile$totalarea_quartile1[totalarea_count_per_quartile$dx=="1TD"]<- NROW(data$bblid[which(data$totalarea<=totalarea_quartile[2][[1]] & data$goassessDxpmr4=="1TD")])
totalarea_count_per_quartile$totalarea_quartile2[totalarea_count_per_quartile$dx=="1TD"]<- NROW(data$bblid[which(data$totalarea>totalarea_quartile[2][[1]] & data$totalarea<=totalarea_quartile[3][[1]] & data$goassessDxpmr4=="1TD")])
totalarea_count_per_quartile$totalarea_quartile3[totalarea_count_per_quartile$dx=="1TD"]<- NROW(data$bblid[which(data$totalarea>totalarea_quartile[3][[1]] & data$totalarea<totalarea_quartile[4][[1]] & data$goassessDxpmr4=="1TD")])
totalarea_count_per_quartile$totalarea_quartile4[totalarea_count_per_quartile$dx=="1TD"]<- NROW(data$bblid[which(data$totalarea>=totalarea_quartile[4][[1]] & data$goassessDxpmr4=="1TD")])

totalarea_count_per_quartile$totalarea_quartile1[totalarea_count_per_quartile$dx=="2WK"]<- NROW(data$bblid[which(data$totalarea<=totalarea_quartile[2][[1]] & data$goassessDxpmr4=="2WK")])
totalarea_count_per_quartile$totalarea_quartile2[totalarea_count_per_quartile$dx=="2WK"]<- NROW(data$bblid[which(data$totalarea>totalarea_quartile[2][[1]] & data$totalarea<=totalarea_quartile[3][[1]] & data$goassessDxpmr4=="2WK")])
totalarea_count_per_quartile$totalarea_quartile3[totalarea_count_per_quartile$dx=="2WK"]<- NROW(data$bblid[which(data$totalarea>totalarea_quartile[3][[1]] & data$totalarea<totalarea_quartile[4][[1]] & data$goassessDxpmr4=="2WK")])
totalarea_count_per_quartile$totalarea_quartile4[totalarea_count_per_quartile$dx=="2WK"]<- NROW(data$bblid[which(data$totalarea>=totalarea_quartile[4][[1]] & data$goassessDxpmr4=="2WK")])

totalarea_count_per_quartile$totalarea_quartile1[totalarea_count_per_quartile$dx=="3PC"]<- NROW(data$bblid[which(data$totalarea<=totalarea_quartile[2][[1]] & data$goassessDxpmr4=="3PC")])
totalarea_count_per_quartile$totalarea_quartile2[totalarea_count_per_quartile$dx=="3PC"]<- NROW(data$bblid[which(data$totalarea>totalarea_quartile[2][[1]] & data$totalarea<=totalarea_quartile[3][[1]] & data$goassessDxpmr4=="3PC")])
totalarea_count_per_quartile$totalarea_quartile3[totalarea_count_per_quartile$dx=="3PC"]<- NROW(data$bblid[which(data$totalarea>totalarea_quartile[3][[1]] & data$totalarea<totalarea_quartile[4][[1]] & data$goassessDxpmr4=="3PC")])
totalarea_count_per_quartile$totalarea_quartile4[totalarea_count_per_quartile$dx=="3PC"]<- NROW(data$bblid[which(data$totalarea>=totalarea_quartile[4][[1]] & data$goassessDxpmr4=="3PC")])

totalarea_count_per_quartile$totalarea_quartile1[totalarea_count_per_quartile$dx=="4PS"]<- NROW(data$bblid[which(data$totalarea<=totalarea_quartile[2][[1]] & data$goassessDxpmr4=="4PS")])
totalarea_count_per_quartile$totalarea_quartile2[totalarea_count_per_quartile$dx=="4PS"]<- NROW(data$bblid[which(data$totalarea>totalarea_quartile[2][[1]] & data$totalarea<=totalarea_quartile[3][[1]] & data$goassessDxpmr4=="4PS")])
totalarea_count_per_quartile$totalarea_quartile3[totalarea_count_per_quartile$dx=="4PS"]<- NROW(data$bblid[which(data$totalarea>totalarea_quartile[3][[1]] & data$totalarea<totalarea_quartile[4][[1]] & data$goassessDxpmr4=="4PS")])
totalarea_count_per_quartile$totalarea_quartile4[totalarea_count_per_quartile$dx=="4PS"]<- NROW(data$bblid[which(data$totalarea>=totalarea_quartile[4][[1]] & data$goassessDxpmr4=="4PS")])


#SubCortGrayVol
SubCortGrayVol_quartile<- quantile(data$SubCortGrayVol,na.rm=T)
SubCortGrayVol_count_per_quartile<- data.frame(dx=c("1TD","2WK","3PC","4PS"),SubCortGrayVol_quartile1=NA,SubCortGrayVol_quartile2=NA,SubCortGrayVol_quartile3=NA,SubCortGrayVol_quartile4=NA)
SubCortGrayVol_count_per_quartile$SubCortGrayVol_quartile1[SubCortGrayVol_count_per_quartile$dx=="1TD"]<- NROW(data$bblid[which(data$SubCortGrayVol<=SubCortGrayVol_quartile[2][[1]] & data$goassessDxpmr4=="1TD")])
SubCortGrayVol_count_per_quartile$SubCortGrayVol_quartile2[SubCortGrayVol_count_per_quartile$dx=="1TD"]<- NROW(data$bblid[which(data$SubCortGrayVol>SubCortGrayVol_quartile[2][[1]] & data$SubCortGrayVol<=SubCortGrayVol_quartile[3][[1]] & data$goassessDxpmr4=="1TD")])
SubCortGrayVol_count_per_quartile$SubCortGrayVol_quartile3[SubCortGrayVol_count_per_quartile$dx=="1TD"]<- NROW(data$bblid[which(data$SubCortGrayVol>SubCortGrayVol_quartile[3][[1]] & data$SubCortGrayVol<SubCortGrayVol_quartile[4][[1]] & data$goassessDxpmr4=="1TD")])
SubCortGrayVol_count_per_quartile$SubCortGrayVol_quartile4[SubCortGrayVol_count_per_quartile$dx=="1TD"]<- NROW(data$bblid[which(data$SubCortGrayVol>=SubCortGrayVol_quartile[4][[1]] & data$goassessDxpmr4=="1TD")])

SubCortGrayVol_count_per_quartile$SubCortGrayVol_quartile1[SubCortGrayVol_count_per_quartile$dx=="2WK"]<- NROW(data$bblid[which(data$SubCortGrayVol<=SubCortGrayVol_quartile[2][[1]] & data$goassessDxpmr4=="2WK")])
SubCortGrayVol_count_per_quartile$SubCortGrayVol_quartile2[SubCortGrayVol_count_per_quartile$dx=="2WK"]<- NROW(data$bblid[which(data$SubCortGrayVol>SubCortGrayVol_quartile[2][[1]] & data$SubCortGrayVol<=SubCortGrayVol_quartile[3][[1]] & data$goassessDxpmr4=="2WK")])
SubCortGrayVol_count_per_quartile$SubCortGrayVol_quartile3[SubCortGrayVol_count_per_quartile$dx=="2WK"]<- NROW(data$bblid[which(data$SubCortGrayVol>SubCortGrayVol_quartile[3][[1]] & data$SubCortGrayVol<SubCortGrayVol_quartile[4][[1]] & data$goassessDxpmr4=="2WK")])
SubCortGrayVol_count_per_quartile$SubCortGrayVol_quartile4[SubCortGrayVol_count_per_quartile$dx=="2WK"]<- NROW(data$bblid[which(data$SubCortGrayVol>=SubCortGrayVol_quartile[4][[1]] & data$goassessDxpmr4=="2WK")])

SubCortGrayVol_count_per_quartile$SubCortGrayVol_quartile1[SubCortGrayVol_count_per_quartile$dx=="3PC"]<- NROW(data$bblid[which(data$SubCortGrayVol<=SubCortGrayVol_quartile[2][[1]] & data$goassessDxpmr4=="3PC")])
SubCortGrayVol_count_per_quartile$SubCortGrayVol_quartile2[SubCortGrayVol_count_per_quartile$dx=="3PC"]<- NROW(data$bblid[which(data$SubCortGrayVol>SubCortGrayVol_quartile[2][[1]] & data$SubCortGrayVol<=SubCortGrayVol_quartile[3][[1]] & data$goassessDxpmr4=="3PC")])
SubCortGrayVol_count_per_quartile$SubCortGrayVol_quartile3[SubCortGrayVol_count_per_quartile$dx=="3PC"]<- NROW(data$bblid[which(data$SubCortGrayVol>SubCortGrayVol_quartile[3][[1]] & data$SubCortGrayVol<SubCortGrayVol_quartile[4][[1]] & data$goassessDxpmr4=="3PC")])
SubCortGrayVol_count_per_quartile$SubCortGrayVol_quartile4[SubCortGrayVol_count_per_quartile$dx=="3PC"]<- NROW(data$bblid[which(data$SubCortGrayVol>=SubCortGrayVol_quartile[4][[1]] & data$goassessDxpmr4=="3PC")])

SubCortGrayVol_count_per_quartile$SubCortGrayVol_quartile1[SubCortGrayVol_count_per_quartile$dx=="4PS"]<- NROW(data$bblid[which(data$SubCortGrayVol<=SubCortGrayVol_quartile[2][[1]] & data$goassessDxpmr4=="4PS")])
SubCortGrayVol_count_per_quartile$SubCortGrayVol_quartile2[SubCortGrayVol_count_per_quartile$dx=="4PS"]<- NROW(data$bblid[which(data$SubCortGrayVol>SubCortGrayVol_quartile[2][[1]] & data$SubCortGrayVol<=SubCortGrayVol_quartile[3][[1]] & data$goassessDxpmr4=="4PS")])
SubCortGrayVol_count_per_quartile$SubCortGrayVol_quartile3[SubCortGrayVol_count_per_quartile$dx=="4PS"]<- NROW(data$bblid[which(data$SubCortGrayVol>SubCortGrayVol_quartile[3][[1]] & data$SubCortGrayVol<SubCortGrayVol_quartile[4][[1]] & data$goassessDxpmr4=="4PS")])
SubCortGrayVol_count_per_quartile$SubCortGrayVol_quartile4[SubCortGrayVol_count_per_quartile$dx=="4PS"]<- NROW(data$bblid[which(data$SubCortGrayVol>=SubCortGrayVol_quartile[4][[1]] & data$goassessDxpmr4=="4PS")])


#CortexVol
CortexVol_quartile<- quantile(data$CortexVol,na.rm=T)
CortexVol_count_per_quartile<- data.frame(dx=c("1TD","2WK","3PC","4PS"),CortexVol_quartile1=NA,CortexVol_quartile2=NA,CortexVol_quartile3=NA,CortexVol_quartile4=NA)
CortexVol_count_per_quartile$CortexVol_quartile1[CortexVol_count_per_quartile$dx=="1TD"]<- NROW(data$bblid[which(data$CortexVol<=CortexVol_quartile[2][[1]] & data$goassessDxpmr4=="1TD")])
CortexVol_count_per_quartile$CortexVol_quartile2[CortexVol_count_per_quartile$dx=="1TD"]<- NROW(data$bblid[which(data$CortexVol>CortexVol_quartile[2][[1]] & data$CortexVol<=CortexVol_quartile[3][[1]] & data$goassessDxpmr4=="1TD")])
CortexVol_count_per_quartile$CortexVol_quartile3[CortexVol_count_per_quartile$dx=="1TD"]<- NROW(data$bblid[which(data$CortexVol>CortexVol_quartile[3][[1]] & data$CortexVol<CortexVol_quartile[4][[1]] & data$goassessDxpmr4=="1TD")])
CortexVol_count_per_quartile$CortexVol_quartile4[CortexVol_count_per_quartile$dx=="1TD"]<- NROW(data$bblid[which(data$CortexVol>=CortexVol_quartile[4][[1]] & data$goassessDxpmr4=="1TD")])

CortexVol_count_per_quartile$CortexVol_quartile1[CortexVol_count_per_quartile$dx=="2WK"]<- NROW(data$bblid[which(data$CortexVol<=CortexVol_quartile[2][[1]] & data$goassessDxpmr4=="2WK")])
CortexVol_count_per_quartile$CortexVol_quartile2[CortexVol_count_per_quartile$dx=="2WK"]<- NROW(data$bblid[which(data$CortexVol>CortexVol_quartile[2][[1]] & data$CortexVol<=CortexVol_quartile[3][[1]] & data$goassessDxpmr4=="2WK")])
CortexVol_count_per_quartile$CortexVol_quartile3[CortexVol_count_per_quartile$dx=="2WK"]<- NROW(data$bblid[which(data$CortexVol>CortexVol_quartile[3][[1]] & data$CortexVol<CortexVol_quartile[4][[1]] & data$goassessDxpmr4=="2WK")])
CortexVol_count_per_quartile$CortexVol_quartile4[CortexVol_count_per_quartile$dx=="2WK"]<- NROW(data$bblid[which(data$CortexVol>=CortexVol_quartile[4][[1]] & data$goassessDxpmr4=="2WK")])

CortexVol_count_per_quartile$CortexVol_quartile1[CortexVol_count_per_quartile$dx=="3PC"]<- NROW(data$bblid[which(data$CortexVol<=CortexVol_quartile[2][[1]] & data$goassessDxpmr4=="3PC")])
CortexVol_count_per_quartile$CortexVol_quartile2[CortexVol_count_per_quartile$dx=="3PC"]<- NROW(data$bblid[which(data$CortexVol>CortexVol_quartile[2][[1]] & data$CortexVol<=CortexVol_quartile[3][[1]] & data$goassessDxpmr4=="3PC")])
CortexVol_count_per_quartile$CortexVol_quartile3[CortexVol_count_per_quartile$dx=="3PC"]<- NROW(data$bblid[which(data$CortexVol>CortexVol_quartile[3][[1]] & data$CortexVol<CortexVol_quartile[4][[1]] & data$goassessDxpmr4=="3PC")])
CortexVol_count_per_quartile$CortexVol_quartile4[CortexVol_count_per_quartile$dx=="3PC"]<- NROW(data$bblid[which(data$CortexVol>=CortexVol_quartile[4][[1]] & data$goassessDxpmr4=="3PC")])

CortexVol_count_per_quartile$CortexVol_quartile1[CortexVol_count_per_quartile$dx=="4PS"]<- NROW(data$bblid[which(data$CortexVol<=CortexVol_quartile[2][[1]] & data$goassessDxpmr4=="4PS")])
CortexVol_count_per_quartile$CortexVol_quartile2[CortexVol_count_per_quartile$dx=="4PS"]<- NROW(data$bblid[which(data$CortexVol>CortexVol_quartile[2][[1]] & data$CortexVol<=CortexVol_quartile[3][[1]] & data$goassessDxpmr4=="4PS")])
CortexVol_count_per_quartile$CortexVol_quartile3[CortexVol_count_per_quartile$dx=="4PS"]<- NROW(data$bblid[which(data$CortexVol>CortexVol_quartile[3][[1]] & data$CortexVol<CortexVol_quartile[4][[1]] & data$goassessDxpmr4=="4PS")])
CortexVol_count_per_quartile$CortexVol_quartile4[CortexVol_count_per_quartile$dx=="4PS"]<- NROW(data$bblid[which(data$CortexVol>=CortexVol_quartile[4][[1]] & data$goassessDxpmr4=="4PS")])


#CorticalWhiteMatterVol
CorticalWhiteMatterVol_quartile<- quantile(data$CorticalWhiteMatterVol,na.rm=T)
CorticalWhiteMatterVol_count_per_quartile<- data.frame(dx=c("1TD","2WK","3PC","4PS"),CorticalWhiteMatterVol_quartile1=NA,CorticalWhiteMatterVol_quartile2=NA,CorticalWhiteMatterVol_quartile3=NA,CorticalWhiteMatterVol_quartile4=NA)
CorticalWhiteMatterVol_count_per_quartile$CorticalWhiteMatterVol_quartile1[CorticalWhiteMatterVol_count_per_quartile$dx=="1TD"]<- NROW(data$bblid[which(data$CorticalWhiteMatterVol<=CorticalWhiteMatterVol_quartile[2][[1]] & data$goassessDxpmr4=="1TD")])
CorticalWhiteMatterVol_count_per_quartile$CorticalWhiteMatterVol_quartile2[CorticalWhiteMatterVol_count_per_quartile$dx=="1TD"]<- NROW(data$bblid[which(data$CorticalWhiteMatterVol>CorticalWhiteMatterVol_quartile[2][[1]] & data$CorticalWhiteMatterVol<=CorticalWhiteMatterVol_quartile[3][[1]] & data$goassessDxpmr4=="1TD")])
CorticalWhiteMatterVol_count_per_quartile$CorticalWhiteMatterVol_quartile3[CorticalWhiteMatterVol_count_per_quartile$dx=="1TD"]<- NROW(data$bblid[which(data$CorticalWhiteMatterVol>CorticalWhiteMatterVol_quartile[3][[1]] & data$CorticalWhiteMatterVol<CorticalWhiteMatterVol_quartile[4][[1]] & data$goassessDxpmr4=="1TD")])
CorticalWhiteMatterVol_count_per_quartile$CorticalWhiteMatterVol_quartile4[CorticalWhiteMatterVol_count_per_quartile$dx=="1TD"]<- NROW(data$bblid[which(data$CorticalWhiteMatterVol>=CorticalWhiteMatterVol_quartile[4][[1]] & data$goassessDxpmr4=="1TD")])

CorticalWhiteMatterVol_count_per_quartile$CorticalWhiteMatterVol_quartile1[CorticalWhiteMatterVol_count_per_quartile$dx=="2WK"]<- NROW(data$bblid[which(data$CorticalWhiteMatterVol<=CorticalWhiteMatterVol_quartile[2][[1]] & data$goassessDxpmr4=="2WK")])
CorticalWhiteMatterVol_count_per_quartile$CorticalWhiteMatterVol_quartile2[CorticalWhiteMatterVol_count_per_quartile$dx=="2WK"]<- NROW(data$bblid[which(data$CorticalWhiteMatterVol>CorticalWhiteMatterVol_quartile[2][[1]] & data$CorticalWhiteMatterVol<=CorticalWhiteMatterVol_quartile[3][[1]] & data$goassessDxpmr4=="2WK")])
CorticalWhiteMatterVol_count_per_quartile$CorticalWhiteMatterVol_quartile3[CorticalWhiteMatterVol_count_per_quartile$dx=="2WK"]<- NROW(data$bblid[which(data$CorticalWhiteMatterVol>CorticalWhiteMatterVol_quartile[3][[1]] & data$CorticalWhiteMatterVol<CorticalWhiteMatterVol_quartile[4][[1]] & data$goassessDxpmr4=="2WK")])
CorticalWhiteMatterVol_count_per_quartile$CorticalWhiteMatterVol_quartile4[CorticalWhiteMatterVol_count_per_quartile$dx=="2WK"]<- NROW(data$bblid[which(data$CorticalWhiteMatterVol>=CorticalWhiteMatterVol_quartile[4][[1]] & data$goassessDxpmr4=="2WK")])

CorticalWhiteMatterVol_count_per_quartile$CorticalWhiteMatterVol_quartile1[CorticalWhiteMatterVol_count_per_quartile$dx=="3PC"]<- NROW(data$bblid[which(data$CorticalWhiteMatterVol<=CorticalWhiteMatterVol_quartile[2][[1]] & data$goassessDxpmr4=="3PC")])
CorticalWhiteMatterVol_count_per_quartile$CorticalWhiteMatterVol_quartile2[CorticalWhiteMatterVol_count_per_quartile$dx=="3PC"]<- NROW(data$bblid[which(data$CorticalWhiteMatterVol>CorticalWhiteMatterVol_quartile[2][[1]] & data$CorticalWhiteMatterVol<=CorticalWhiteMatterVol_quartile[3][[1]] & data$goassessDxpmr4=="3PC")])
CorticalWhiteMatterVol_count_per_quartile$CorticalWhiteMatterVol_quartile3[CorticalWhiteMatterVol_count_per_quartile$dx=="3PC"]<- NROW(data$bblid[which(data$CorticalWhiteMatterVol>CorticalWhiteMatterVol_quartile[3][[1]] & data$CorticalWhiteMatterVol<CorticalWhiteMatterVol_quartile[4][[1]] & data$goassessDxpmr4=="3PC")])
CorticalWhiteMatterVol_count_per_quartile$CorticalWhiteMatterVol_quartile4[CorticalWhiteMatterVol_count_per_quartile$dx=="3PC"]<- NROW(data$bblid[which(data$CorticalWhiteMatterVol>=CorticalWhiteMatterVol_quartile[4][[1]] & data$goassessDxpmr4=="3PC")])

CorticalWhiteMatterVol_count_per_quartile$CorticalWhiteMatterVol_quartile1[CorticalWhiteMatterVol_count_per_quartile$dx=="4PS"]<- NROW(data$bblid[which(data$CorticalWhiteMatterVol<=CorticalWhiteMatterVol_quartile[2][[1]] & data$goassessDxpmr4=="4PS")])
CorticalWhiteMatterVol_count_per_quartile$CorticalWhiteMatterVol_quartile2[CorticalWhiteMatterVol_count_per_quartile$dx=="4PS"]<- NROW(data$bblid[which(data$CorticalWhiteMatterVol>CorticalWhiteMatterVol_quartile[2][[1]] & data$CorticalWhiteMatterVol<=CorticalWhiteMatterVol_quartile[3][[1]] & data$goassessDxpmr4=="4PS")])
CorticalWhiteMatterVol_count_per_quartile$CorticalWhiteMatterVol_quartile3[CorticalWhiteMatterVol_count_per_quartile$dx=="4PS"]<- NROW(data$bblid[which(data$CorticalWhiteMatterVol>CorticalWhiteMatterVol_quartile[3][[1]] & data$CorticalWhiteMatterVol<CorticalWhiteMatterVol_quartile[4][[1]] & data$goassessDxpmr4=="4PS")])
CorticalWhiteMatterVol_count_per_quartile$CorticalWhiteMatterVol_quartile4[CorticalWhiteMatterVol_count_per_quartile$dx=="4PS"]<- NROW(data$bblid[which(data$CorticalWhiteMatterVol>=CorticalWhiteMatterVol_quartile[4][[1]] & data$goassessDxpmr4=="4PS")])


quartile_counts<- cbind(cnr_count_per_quartile,snr_count_per_quartile,meanthickness_count_per_quartile,totalarea_count_per_quartile,SubCortGrayVol_count_per_quartile,CorticalWhiteMatterVol_count_per_quartile,CortexVol_count_per_quartile)
write.csv(quartile_counts,"/data/jag/BBL/studies/pnc/subjectData/freesurfer/n1601_fs53_quartile_dx_qa_counts.csv")
