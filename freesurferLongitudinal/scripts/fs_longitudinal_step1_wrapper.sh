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
	tmpid=`echo $bblid".long"`

	#timepoint_count=`find $i/*x* | wc -l`
	timepoint_count=`find $SUBJECTS_DIR/*x* | wc -l`
	
	#print outs for troubleshooting
	#echo $SUBJECTS_DIR
	#echo "bblid is $bblid"
	#echo "tmpid is $tmpid"
	#echo "timepoint_count is $timepoint_count"

	if [ $timepoint_count == 2 ]; then

		subjid1=`find -P $SUBJECTS_DIR/*x* -maxdepth 0 | head -n 1 | cut -d "/" -f 12`
		subjid2=`find -P $SUBJECTS_DIR/*x* -maxdepth 0 | head -n 2 | tail -1 | cut -d "/" -f 12`
		qsub -V -e $logs -o $logs -q all.q -S /bin/bash $scriptsDir/fs_longitudinal_2tps.sh $subjid1 $subjid2 $tmpid $SUBJECTS_DIR


	elif [ $timepoint_count == 3 ]; then

		subjid1=`find -P $SUBJECTS_DIR/*x* -maxdepth 0 | head -n 1 | cut -d "/" -f 12`
		subjid2=`find -P $SUBJECTS_DIR/*x* -maxdepth 0 | head -n 2 | tail -1 | cut -d "/" -f 12`
		subjid3=`find -P $SUBJECTS_DIR/*x* -maxdepth 0 | tail -1 | cut -d "/" -f 12`
		qsub -V -e $logs -o $logs -q all.q -S /bin/bash $scriptsDir/fs_longitudinal_3tps.sh $subjid1 $subjid2 $subjid3 $tmpid $SUBJECTS_DIR
	fi
done 
