#this script runs step2 of the longitudinal processing pipeline (step 1 must be run prior to this)

export FREESURFER_HOME="/share/apps/freesurfer/5.3.0"
export PERL5LIB="/share/apps/freesurfer/5.3.0/mni/lib/perl5/5.8.5"

#slist=$(ls -d /data/joy/BBL/studies/pnc/processedData/structural/freesurferLongitudinal/fsData/*) 
slist=$(cat /data/joy/BBL/studies/pnc/subjectData/freesurfer/go1_go2_go3_fs_longitudinal_fail_rerun_list_05_19_16.csv)
logs=/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/freesurferLongitudinal/logs
scriptsDir=/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/freesurferLongitudinal/scripts

#for every subject in the subjects folder
for i in $slist; do
	#export SUBJECTS_DIR=$i
	#bblid=`echo $i | cut -d "/" -f 11`
	bblid=`echo $i`
	export SUBJECTS_DIR=`ls -d /data/joy/BBL/studies/pnc/processedData/structural/freesurferLongitudinal/fsData/$bblid`	
	templateid=`echo $bblid".long"`

#for each scanid run the longitudinal step 2
#for j in $i/*x*; do
for j in $SUBJECTS_DIR/*x*; do
	#subjid=`echo $j`
	subjid=`echo $j | cut -d "/" -f 12`
	qsub -V -e $logs -o $logs -q all.q -S /bin/bash $scriptsDir/fs_longitudinal_step2_submit.sh $subjid $templateid $SUBJECTS_DIR

done
done

