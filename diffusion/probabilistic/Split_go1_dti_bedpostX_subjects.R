#### Split up go1 DTI sample for BedpostX in chead ####

# Fullsample
Meg_samp_n1210 <- read.csv("/data/jag/BBL/studies/pnc/subjectData/full_go1_dti_qaInclude_n1210.csv",header=FALSE)

# Subjects left to run
to_be_run <- Meg_samp_n1210[c(451:1210),]
#write.csv(to_be_run,"/data/jag/BBL/studies/pnc/subjectData/to_be_run_bedpostX.csv",quote=FALSE,row.names=FALSE)

# Original batch (processed by GLB)
batch0 <- Meg_samp_n1210[c(1:450),]
write.csv(batch0,"/data/jag/BBL/studies/pnc/subjectData/go1_dti_qaInclude_GLB_batch0.csv",quote=FALSE,row.names=FALSE)

# First batch (to be processed by AFGR)
batch1 <- Meg_samp_n1210[c(451:600),]
write.csv(batch1,"/data/jag/BBL/studies/pnc/subjectData/go1_dti_qaInclude_AFGR_batch1.csv",quote=FALSE,row.names=FALSE)

# Second batch (to MQ)
batch2 <- Meg_samp_n1210[c(601:850),]
write.csv(batch2,"/data/jag/BBL/studies/pnc/subjectData/go1_dti_qaInclude_MQ_batch2.csv",quote=FALSE,row.names=FALSE)

# Third batch (RC)
batch3 <- Meg_samp_n1210[c(851:1000),]
write.csv(batch3,"/data/jag/BBL/studies/pnc/subjectData/go1_dti_qaInclude_RC_batch3.csv",quote=FALSE,row.names=FALSE)

# Fourth batch (GLB)
batch4 <- Meg_samp_n1210[c(1001:1210),]
write.csv(batch4,"/data/jag/BBL/studies/pnc/subjectData/go1_dti_qaInclude__GLB_batch4.csv",quote=FALSE,row.names=FALSE)

