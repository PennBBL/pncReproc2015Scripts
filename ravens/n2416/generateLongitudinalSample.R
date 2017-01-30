data1601 <- read.csv("/data/joy/BBL/projects/pncReproc2015/n1601QAT1/flaggingBasedonSD/n1601_go_QAFlags_Structural_final.csv")
data2416 <- read.csv("/data/joy/BBL/projects/pncReproc2015/n2416QAT1/flaggingBasedonSD/n2416_go_QAFlags_Structural_final_2016Dec12.csv")

index <- 0
for (i in 1:1601) {
  tmp <-which(data2416$bblid == data1601$bblid[i] &  data2416$scanid == data1601$scanid[i])
  index <- c(index, tmp)
}

index <- index[-1]

data2416 <- data2416[-index, ]

write.csv(data2416, "/data/joy/BBL/projects/pncReproc2015/ravens/n2416_analysis/n815_golongitudinal_subjects.csv", row.names=F)
