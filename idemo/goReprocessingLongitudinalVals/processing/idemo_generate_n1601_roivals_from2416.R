QA <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/idemo/n1601_idemo_FinalQA.csv")

glasser <- read.csv("/data/joy/BBL/studies/pnc/n2416_dataFreezeJan2017/neuroimaging/idemo/n2416_idemo_glasser_roivals.csv")
jlf <- read.csv("/data/joy/BBL/studies/pnc/n2416_dataFreezeJan2017/neuroimaging/idemo/n2416_idemo_jlf_roivals.csv")
intersect <- read.csv("/data/joy/BBL/studies/pnc/n2416_dataFreezeJan2017/neuroimaging/idemo/n2416_idemo_jlf_intersect_roivals.csv")

index <- 0
for (i in 1:1601) {
  tmp <- which(glasser$bblid == QA$bblid[i] & glasser$scanid == QA$scanid[i])
  index <- c(index, tmp)
}

glasser <- glasser[index[-1], ]

write.csv(glasser, "/data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/idemo/n1601_idemo_glasser_roivals.csv")

index <- 0
for (i in 1:1601) {
  tmp <- which(jlf$bblid == QA$bblid[i] & jlf$scanid == QA$scanid[i])
  index <- c(index, tmp)
}

jlf <- jlf[index[-1], ]

write.csv(jlf, "/data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/idemo/n1601_idemo_jlf_roivals.csv")

index <- 0
for (i in 1:1601) {
  tmp <- which(intersect$bblid == QA$bblid[i] & intersect$scanid == QA$scanid[i])
  index <- c(index, tmp)
}

intersect <- intersect[index[-1], ]

write.csv(intersect, "/data/joy/BBL/studies/pnc/n1601_dataFreeze2016/neuroimaging/idemo/n1601_idemo_jlf_intersect_roivals.csv")
