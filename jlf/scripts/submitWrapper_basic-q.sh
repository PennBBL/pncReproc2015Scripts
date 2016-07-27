joblist="/home/arosen/tempCohortListSplit/jlfPaths/submitPaths/individualCohorts0${1}"
ntasks=$(cat ${joblist} | wc -l)

qsub -q basic.q -binding linear:2 -l h_vmem=6.5G,s_vmem=6.0G -S /bin/bash -e /data/joy/BBL/projects/pncReproc2015/jlf/errorLogs/ -o /data/joy/BBL/projects/pncReproc2015/jlf/outputLogs/ -t 1-${ntasks} /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/jlf/scripts/run_JLF_wrapper-basic.sh ${joblist}
