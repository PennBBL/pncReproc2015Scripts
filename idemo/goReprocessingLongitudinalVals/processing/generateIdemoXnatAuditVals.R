data1601 <- read.csv("/data/joy/BBL/projects/pncReproc2015/n1601QAT1/flaggingBasedonSD/n1601_go_QAFlags_Structural_final.csv")
data2416 <- read.csv("/data/joy/BBL/projects/pncReproc2015/idemo/goReprocessingLongitudinalVals/n2416_go1_go2_go3_scans_info_112916.csv")

index <- 0
for (i in 1:1601) {
  tmp <-which(data2416$bblid == data1601$bblid[i] &  data2416$scanid == data1601$scanid[i])
  index <- c(index, tmp)
}

index <- index[-1]

data2416 <- data2416[-index, ]

data2416 <- data2416[which(data2416$idemoMatchedXnat == 1), ]
rownames(data2416) <- NULL


write.csv(data2416, "/data/joy/BBL/projects/pncReproc2015/idemo/goReprocessingLongitudinalVals/n2416_listIdemo_xnatAudit.csv", row.names=F)


data1601 <- read.csv("/data/joy/BBL/projects/pncReproc2015/n1601QAT1/flaggingBasedonSD/n1601_go_QAFlags_Structural_final.csv")
data2416 <- read.csv("/data/joy/BBL/projects/pncReproc2015/idemo/goReprocessingLongitudinalVals/n2416_go1_go2_go3_scans_info_112916.csv")

data1601 <- merge(data1601, data2416, by=c("bblid","scanid"))

length(which(data1601$idemoMatchedXnat == 1))
