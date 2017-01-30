library(ANTsR)

data.path <- read.csv("/data/joy/BBL/projects/pncReproc2015/idemo/QA//n1601_idemo_FinalQA.csv")
data2416 <- read.csv("/data/joy/BBL/projects/pncReproc2015/idemo/goReprocessingLongitudinalVals/processing/n2416_go1_go2_go3_scans_info_112916.csv")

index <- 0

for (i in 1:1601) {
  temp <- which(data2416$bblid == data.path$bblid[i] & data2416$scanid == data.path$scanid[i])
  index <- c(index, temp)
}

index <- index[-1]

data2416 <- data2416[-index,1:2]

write.csv(data2416, "/data/joy/BBL/projects/pncReproc2015/idemo/goReprocessingLongitudinalVals/QA/n815_bblidscanid_list.csv", row.names=F)


data.path <- read.csv("/data/joy/BBL/projects/pncReproc2015/idemo/goReprocessingLongitudinalVals/QA/n815_idemo_listMask.csv")

names(data.path) <- c("bblid","scanid","maskPath")
data.path$maskPath <- as.character(data.path$maskPath)

data.path$QA.voxelCov <- 0

for (i in 1:dim(data.path)[1]) {
  if (data.path$maskPath[i] == "") {
    data.path$QA.voxelCov[i] <- NA
  } else {
    image <- as.array(antsImageRead(data.path$maskPath[i], dimension=3))
    data.path$QA.voxelCov[i] <- image[41,105,39] + image[34,103,35] + image[60,103,35] + image[61,47,17]
  }
}

write.csv(data.path, "/data/joy/BBL/projects/pncReproc2015/idemo/goReprocessingLongitudinalVals/QA/n1601_maskCoverage_QA.csv", row.names=F)


data.path <- data.path[which(data.path$QA.voxelCov == 4), ]
write.csv(data.path[,1:2], "/data/joy/BBL/projects/pncReproc2015/idemo/maskCoverageInclude_Subjects.csv", row.names=F)
