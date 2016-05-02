subjlist=${1}
subj=$(cat $subjlist | sed -n "${SGE_TASK_ID}p")

/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/jlf/scripts/antsJLF_OASIS30CustomSubset_afgr.pl /data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/${subj}/ExtractedBrain0N4.nii.gz /data/joy/BBL/studies/pnc/processedData/structural/jlf/${subj}/jlf 1 1 Younger24


