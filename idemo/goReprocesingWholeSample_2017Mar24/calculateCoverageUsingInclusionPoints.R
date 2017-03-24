library(ANTsR)

data.path <- read.csv("/data/joy/BBL/projects/pncReproc2015/idemo/goReprocesingWholeSample_2017Mar24/n2416_listofMask.csv", header = F)
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

write.csv(data.path, "/data/joy/BBL/projects/pncReproc2015/idemo/goReprocesingWholeSample_2017Mar24/n2416_maskCoverage_QA.csv", row.names=F)
 

data.path <- data.path[which(data.path$QA.voxelCov == 4), ]
write.csv(data.path[,1:2], "/data/joy/BBL/projects/pncReproc2015/idemo/goReprocesingWholeSample_2017Mar24/maskCoverageInclude_Subjects.csv", row.names=F)
