joblist="/data/joy/BBL/projects/pncReproc2015/jlf/cohortList/individualCohorts0${1}"
ntasks=$(cat ${joblist} | wc -l)

qsub -l h_vmem=6.5G,s_vmem=6.0G -S /bin/bash -q all.q,basic.q -e /data/joy/BBL/projects/pncReproc2015/jlf/errorLogs/ -o /data/joy/BBL/projects/pncReproc2015/jlf/outputLogs/ -t 1-${ntasks} /home/arosen/pncReproc2015Scripts/jlf/procScripts/run_JLF_wrapper.sh ${joblist}
