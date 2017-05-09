data1601 <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze//neuroimaging//t1struct//n1601_jlfVol_20161006.csv")

datajlf <- read.csv("/data/joy/BBL/studies/pnc/n2416_dataFreeze/neuroimaging/idemo//n2416_idemo_jlf_roivals_20170426.csv")
dataglasser <- read.csv("/data/joy/BBL/studies/pnc/n2416_dataFreeze/neuroimaging/idemo//n2416_idemo_glasser_roivals_20170426.csv")



data1601jlf <- merge(data1601, datajlf, by=c("bblid","scanid"))
data1601glasser <- merge(data1601, dataglasser, by=c("bblid","scanid"))

write.csv(data1601jlf, "/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/idemo/n1601_idemo_jlf_roivals_20170426.csv")
write.csv(data1601glasser, "/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/idemo/n1601_idemo_glasser_roivals_20170426.csv")
