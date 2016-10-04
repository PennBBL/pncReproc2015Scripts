joblist="/data/joy/BBL/projects/pncReproc2015/antsCT/submitPaths/individualCohorts0"
ntasks=$(cat ${joblist} | wc -l)

qsub -q all.q,basic.q -l h_vmem=1.9G,s_vmem=1.5G -S /bin/bash -t 1-${ntasks} /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/antsCT/runCombineWrapper.sh ${joblist}
