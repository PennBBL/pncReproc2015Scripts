joblist="/home/arosen/tempCohortListSplit/cohort_list.csv"
ntasks=$(cat ${joblist} | wc -l)

qsub -q all.q,basic.q -l h_vmem=4.0G,s_vmem=4.5G -S /bin/bash -t 1-${ntasks} /home/arosen/pncReproc2015Scripts/antsCT/postProc/runCombineWrappergrasp227.sh ${joblist}
