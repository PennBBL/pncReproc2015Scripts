#subjects=$(cat /data/jag/cnds/emotionalRegulation/group_analyses/rsfc_mri/subject_lists/n136_incDepPtsdHcF_ids.txt)

#subjects=$(cat /data/jag/cnds/emotionalRegulation/lists/pipeline_subject_lists/regulate_subjects_n37.txt)

#subjects=$(cat /data/jag/cnds/emotionalRegulation/lists/pipeline_subject_lists/conflict_subjects_n45.txt)

if [[ $# -eq 0 ]]; then
  echo " $0 <subject> <task> "
  exit 1
fi

subjects=$1
task=$2

#define fixed arguments
config=/data/jag/cnds/RS_fMRI/scripts/config 
template=/data/jet/pcook/sheline/template/templateBrain2mm.nii.gz  #template to register timeseries to via T1
coreg_method=bbr	 	#must be a cost function recognized by flirt-- BBR reccomended!!! 

#define logs
logdir=/data/jag/cnds/emotionalRegulation/scripts/task_fmri/logs/wrapperLogs
t1_missing_log=$logdir/t1_missing_log.txt
t1_mult_log=$logdir/t1_mult_log.txt
run_log=$logdir/regApply_runlog.txt
complete_log=$logdir/regApply_complete.txt
incomplete_log=$logdir/regApply_incomplete.txt


#remove logs
rm -f $t1_missing_log
rm -f $t1_mult_log
rm -f $run_log
rm -f $outdir_log
rm -f $complete_log
rm -f $incomplete_log

for s in $subjects; do
	echo ""
	subj=$s

	subjdir=$(ls -d /data/jag/cnds/emotionalRegulation/fsl/${task}/feat/output/$subj) 

	echo $subjdir

	#get list of all feat directories across all timepoints for this subject
	feats=$(ls -d $subjdir/*/${subj}*.feat)
	echo "feat directories are: $feats"


	#now loop through each run 
	for feat in $feats; do 
		echo ""
		echo "*******"
		echo "feat directory is $feat"

		#get timepoint name for full ID from path
		tp_name=$(echo $feat | cut -d/ -f11)
		feat_name=$(basename $feat)
		run_num=$(echo $feat_name | cut -d_ -f8 | cut -d. -f1)

		echo "tp is $tp_name"
		echo "run is $run_num"


		subjID=${subj}_${tp_name}_run_${run_num}
 		echo "full subject ID is $subjID"

	        #get t1 directory
		mpragedirs=$(ls -d /data/jag/cnds/emotionalRegulation/antsct/$subj/*)  ###SET DIRECTORY TO T1 IMAGES
#		echo $mpragedirs
		#count number of mprage directories and log if >1
		num_mprage=$(echo $mpragedirs | wc | awk '{print $2}')
		echo "number of mpragedirs is $num_mprage"
		if [ "$num_mprage" -gt 1 ]; then
			echo "more than 1 mprage directory, will try to use mprage from the BOLD timepoint in question"
			echo "$subjID" >> $t1_mult_log
			
			mpragedir=$(ls -d /data/jag/cnds/emotionalRegulation/antsct/$subj/$tp_name)
			
			if [ ! -d "$mpragedir" ]; then
				echo "Multiple mprages present but none from this timepoint"
				echo "will use first timepoint"
				mpragedir=$(echo $mpragedirs | cut -d" " -f1)

			fi
		else
			echo "only one mpragedir is present"
			mpragedir=$mpragedirs
		fi

		echo "mpragedir is $mpragedir"
		
		#get t1 inputs
	        t1brain=$(ls $mpragedir/${subj}_*_ExtractedBrain0N4.nii.gz) #SET BRAIN EXTRACTED IMAGE
                t1seg=$(ls $mpragedir/${subj}_*_BrainSegmentation.nii.gz)  #SET SEGMENTED IMAGE
                ants_affine=$(ls $mpragedir/${subj}_*_SubjectToTemplate0GenericAffine.mat)
                ants_warp=$(ls $mpragedir/${subj}_*_SubjectToTemplate1Warp.nii.gz)
		ants_warp_inv=$(ls $mpragedir/${subj}_*_TemplateToSubject0Warp.nii.gz)
		##echo T1 inputs
		echo "mprage dir is $mpragedir"
		echo "t1brain is $t1brain"
		echo "t1seg is $t1seg"
		echo "t1 ffine is $ants_affine"
		echo "t1 warp is $ants_warp"
		echo "t1 inv warp is $ants_warp_inv"

	        #make sure all files are present
	        if [ ! -e "$t1brain" ] || [ ! -e "$t1seg" ] || [ ! -e "$ants_affine" ] || [ ! -e "$ants_warp" ] || [ ! -e "$ants_warp_inv" ]; then
        	        echo "one or more t1 inputs are missing; will log"
                	echo $subj >> $t1_missing_log
	                continue
        	fi

		#check if output is present
		outfile=$feat/${subjID}_mask_std.nii.gz
		if [ -e "$outfile" ]; then
			echo "output already present-- will skip this subject"
			echo "$subjID" >> $complete_log
			continue
		fi
	
		echo "running coregistration and normalization pipeline on subj $subjID"
		echo $subjID >> $run_log
		echo "feat directory is $feat"
#		/home/sattertt/rfsc_mri_github/restbold/task_coregister_normalize_20150302.sh --subj=$subjID --feat=$feat --t1brain=$t1brain --t1seg=$t1seg  --t1seg_vals=1,2,3 --template=$template --coreg_method=$coreg_method --config=$config --ants_warp=$ants_warp --ants_warp_inv=$ants_warp_inv --ants_affine=$ants_affine

	qsub -V -b y -cwd -l h_vmem=7.8G,s_vmem=7.6G -o $feat -e $feat /data/jag/cnds/emotionalRegulation/fsl/scripts/task_coregister_normalize_20150302.sh --subj=$subjID --feat=$feat --t1brain=$t1brain --t1seg=$t1seg  --t1seg_vals=1,2,3 --template=$template --coreg_method=$coreg_method --config=$config --ants_warp=$ants_warp --ants_warp_inv=$ants_warp_inv --ants_affine=$ants_affine


	done
done

