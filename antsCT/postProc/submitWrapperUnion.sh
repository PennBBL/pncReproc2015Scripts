joblist="/home/arosen/tempCohortListSplit/cohort_list.csv"
ntasks=$(cat ${joblist} | wc -l)

qsub -q all.q,basic.q -l h_vmem=1G,s_vmem=1G -S /bin/bash -t 1-${ntasks} /home/arosen/pncReproc2015Scripts/antsCT/postProc/runCombineWrapperUnion.sh ${joblist}
