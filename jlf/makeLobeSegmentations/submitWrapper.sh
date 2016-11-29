joblist="/home/arosen/tempCohortListSplit/cohort_list.csv"
ntasks=$(cat ${joblist} | wc -l)

qsub -q all.q,basic.q -l h_vmem=.5G,s_vmem=.5G -S /bin/bash -t 1-${ntasks} /home/arosen/pncReproc2015Scripts/jlf/makeLobeSegmentations/runCombineWrapper.sh ${joblist}
