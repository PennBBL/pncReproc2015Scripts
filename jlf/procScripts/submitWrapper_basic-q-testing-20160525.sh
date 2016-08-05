joblist="/home/arosen/tempCohortListSplit/jlfPaths/submitPaths/individualCohorts0${1}"
ntasks=$(cat ${joblist} | wc -l)

qsub -q basic.q -binding linear:2 -l h_vmem=1.5G,s_vmem=1.0G -S /bin/bash -e /data/joy/BBL/projects/pncReproc2015/jlf/errorLogs/ -o /data/joy/BBL/projects/pncReproc2015/jlf/outputLogs/ -t 1-${ntasks} /data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/jlf/scripts/run_JLF_wrapper-basic-testing-20160525.sh ${joblist}
