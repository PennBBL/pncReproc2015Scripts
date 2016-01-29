#### Split up go1 DTI sample for BedpostX in chead ####

# Fullsample
Meg_samp_n1210 <- read.csv("/data/jag/BBL/studies/pnc/subjectData/go1_bedpostX/full_go1_dti_qaInclude_n1210.csv",header=FALSE)

# Subjects left to run
to_be_run <- Meg_samp_n1210[c(451:1210),]
# write.table(to_be_run,"/data/jag/BBL/studies/pnc/subjectData/go1_bedpostX/to_be_run_bedpostX.csv",quote=FALSE,row.names=FALSE,col.names=FALSE,sep=",")

# Original batch (processed by GLB)
batch0 <- Meg_samp_n1210[c(1:450),]
write.table(batch0,"/data/jag/BBL/studies/pnc/subjectData/go1_bedpostX/go1_dti_qaInclude_GLB_batch0.csv",quote=FALSE,row.names=FALSE,col.names=FALSE,sep=",")

# First batch (to be processed by AFGR)
batch1 <- Meg_samp_n1210[c(451:700),]
write.table(batch1,"/data/jag/BBL/studies/pnc/subjectData/go1_bedpostX/new_go1_dti_qaInclude_AFGR_batch1.csv",quote=FALSE,row.names=FALSE,col.names=FALSE,sep=",")

# Second batch (to MQ)
batch2 <- Meg_samp_n1210[c(701:1000),]
write.table(batch2,"/data/jag/BBL/studies/pnc/subjectData/go1_bedpostX/new_go1_dti_qaInclude_MQ_batch2.csv",quote=FALSE,row.names=FALSE,col.names=FALSE,sep=",")

# Third batch (GLB)
batch3 <- Meg_samp_n1210[c(1001:1210),]
write.table(batch3,"/data/jag/BBL/studies/pnc/subjectData/go1_bedpostX/new_go1_dti_qaInclude_GLB_batch3.csv",quote=FALSE,row.names=FALSE,col.names=FALSE,sep=",")

# Add column names to Meg_samp
colnames(Meg_samp_n1210) <- c("bblid", "scan_id", "dateOfScan","QA_Include")

# Read in deterministic pipeline DTI sample
detPipe <- read.csv("/data/jag/gbaum/PNC/n960_VolNorm_scale125_StreamlineConnectivity_PNC_detPipe_ICV_Motion.csv",header=TRUE)

# Merge batch0 (completed subjects) with detPipe to create sample for Probtrackx2 testing
PTx_sample <- merge(detPipe, batch0, by = "bblid", sort = FALSE)
