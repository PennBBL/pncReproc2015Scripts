data1601 <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze//neuroimaging//t1struct//n1601_jlfAntsCTIntersectionVol_20170412.csv")

datajlf <- read.csv("/data/joy/BBL/studies/pnc/n2416_dataFreeze/neuroimaging/idemo//n2416_idemo_jlf_roivals_20170426.csv")
dataglasser <- read.csv("/data/joy/BBL/studies/pnc/n2416_dataFreeze/neuroimaging/idemo//n2416_idemo_glasser_roivals_20170426.csv")
dataQA <- read.csv("/data/joy/BBL/studies/pnc/n2416_dataFreeze/neuroimaging/idemo//n2416_idemo_QA_20170426.csv")


data1601 <- data1601[,c(1,2)]


data1601jlf <- merge(data1601, datajlf, by=c("bblid","scanid"))
data1601glasser <- merge(data1601, dataglasser, by=c("bblid","scanid"))
dataQA <- merge(data1601, dataQA, by=c("bblid","scanid"))


#Old data structure path is no longer there
#write.csv(data1601jlf, "/data/joy/BBL-extend/tmp/datafreeze/n1601_idemo_jlf_roivals_20170710.csv", row.names=F)
#write.csv(data1601glasser, "//data/joy/BBL-extend/tmp/datafreeze/n1601_idemo_glasser_roivals_20170710.csv", row.names=F)
write.csv(dataQA, "/data/joy/BBL-extend/data_repository/Dec2016/pnc/n1601_idemo_jlf_QA_20170907.csv", row.names=F)
