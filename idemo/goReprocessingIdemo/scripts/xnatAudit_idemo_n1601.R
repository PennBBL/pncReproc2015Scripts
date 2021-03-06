
#/import/speedy/scripts/hopsonr/download_and_audit/xnat_audit_v1.1.py -configfile ~/.xnat.cfg -project EONS_810366 -scan bbl1_idemo2_210,1

data1601 <- read.csv("~/data/n1601_go1_datarel_113015.csv")
data1601 <- data1601[c("bblid","scanid")]
data_audit <- read.csv("~/GO_idemo_xnat_audit.csv")
names(data_audit)[1] <- "scanid"

data1601 <- merge(data1601, data_audit, by=c("scanid","bblid"))

data1601 <- data1601[data1601$bbl1_idemo2_210 == 1, ]
data1601 <- data1601[c("bblid","scanid")]

write.csv(data1601, "/import/monstrum2/Users/angelgar/goReprocessingIdemo/n1601_xnatAudit_usableIdemo_2016Oct25.csv")
               