#set -x

#######add logs
logfile=""
logrun(){
run="$*"
lrn=$(($lrn+1))
printf ">> `date`: $lrn: ${run}\n" >> $logfile
$run 2>> $logfile
ec=$?
printf "exit code: $ec\n" #|tee -a $logfile
#[ ! $ec -eq 0 ] && printf "\nError running $exe; exit code: $ec; aborting.\n" |tee -a $logfile && exit 1
}

#input is the subject ID from the loop script

subjlist=$1

#cat /data/joy/BBL/studies/pnc/processedData/diffusion/pncDTI_2016_04/eons_joblist.txt | while read id

id=$(cat $subjlist|sed -n "${SGE_TASK_ID}p")  #only use for array jobs, comment out for non-grid testing
bblid=`echo $id | cut -d '_' -f1`
scanid=`echo $id |cut -d '_' -f2 |cut -d 'x' -f2`
sessionid=`echo $id |cut -d '_' -f2`
path=/data/joy/BBL/studies/pnc/processedData/diffusion/pncDTI_2016_04
dti_image_64=`ls $path/$bblid/$sessionid/DTI_64/raw_merged_dti/*merged.nii.gz`
dti_image_32=`ls $path/$bblid/$sessionid/DTI_32/raw_dti/$id"_raw_dti.nii.gz"`
acqparams=/data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/acqparams.txt
indexfile_64=/data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/index_64.txt
indexfile_32=/data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/index_32.txt
bvecs_64=`ls /data/joy/BBL/studies/pnc/processedData/diffusion/pncDTI_2016_04/$bblid/$sessionid/DTI_64/raw_merged_dti/*.bvec`
bvals_64=`ls /data/joy/BBL/studies/pnc/processedData/diffusion/pncDTI_2016_04/$bblid/$sessionid/DTI_64/raw_merged_dti/*.bval`
bvecs_32=`ls /data/joy/BBL/studies/pnc/processedData/diffusion/pncDTI_2016_04/$bblid/$sessionid/DTI_32/raw_dti/*bvec`
bvals_32=`ls /data/joy/BBL/studies/pnc/processedData/diffusion/pncDTI_2016_04/$bblid/$sessionid/DTI_32/raw_dti/*bval`
process_fail=/data/joy/BBL/studies/pnc/processedData/diffusion/pncDTI_2016_04/dti_process_fail.csv
date=`date +%Y-%m-%d`
logfile=/data/joy/BBL/studies/pnc/processedData/diffusion/pncDTI_2016_04/$bblid/$sessionid/$id"_logfile_process_"$date".log"
out_32=$path/$bblid/$sessionid/DTI_32/qa/$id"_quality".csv
out_64=$path/$bblid/$sessionid/DTI_64/qa/$id"_quality".csv

echo " Processing subject "$sessionid

#Make DTI coverage mask for each subject by backtransforming FSL's FMRIB58 DTI mask to native space

#Register single b=0 dwi image to FMRIB58 DTI FA map

if [ ! -e $path/$bblid/$sessionid/DTI_64/dtifit/dti_eddy_with_CNI_rotated_bvecs_FA.nii.gz ] ; then 

		
		echo "register b=0 to FMRIB58"
		if [ -e $path/$bblid/$sessionid/DTI_64/qa/$id".dti.merged_b0mean.nii.gz" ] ; then
		echo "move b=0 image to standard space"
		logrun flirt -dof 6 -in $path/$bblid/$sessionid/DTI_64/qa/$id".dti.merged_b0mean.nii.gz" -ref /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/FMRIB58_FA_1mm.nii.gz -out $path/$bblid/$sessionid/DTI_64/raw_merged_dti/$id"_dwi_n_standard_space.nii.gz" -omat $path/$bblid/$sessionid/DTI_64/raw_merged_dti/$id"_dwi_n_standard_space.mat"
		echo "dwi to std space done"
		else
		echo "ERROR: no mean b=0 image"
		error_msg1="ERROR: no b=0 image"
		fi		

#Invert transform
		echo "invert transform"		
		if [ -e $path/$bblid/$sessionid/DTI_64/raw_merged_dti/$id"_dwi_n_standard_space.mat" ] ; then
		logrun convert_xfm -omat $path/$bblid/$sessionid/DTI_64/raw_merged_dti/$id"_std_n_dwi_space.mat" -inverse $path/$bblid/$sessionid/DTI_64/raw_merged_dti/$id"_dwi_n_standard_space.mat"
		else
		echo "ERROR: dwi to standard not run"
		error_msg2="ERROR: dwi to standard not run"
		fi

#Transform FMRIB58 FA to single subject space
		echo "FMRIB to native"			
		if [ -e $path/$bblid/$sessionid/DTI_64/raw_merged_dti/$id"_std_n_dwi_space.mat" ] ; then
		logrun flirt -in /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/FMRIB58_mask.nii.gz -ref $path/$bblid/$sessionid/DTI_64/qa/$id".dti.merged_b0mean.nii.gz" -interp nearestneighbour -applyxfm -init $path/$bblid/$sessionid/DTI_64/raw_merged_dti/$id"_std_n_dwi_space.mat" -out $path/$bblid/$sessionid/DTI_64/raw_merged_dti/$id"_dtistd_2.mask.nii.gz"
		else
		echo "ERROR: inverse transformation matrix does not exist"
		error_msg3="ERROR: inverse transformation matrix does not exist"
		fi

#Run FSL EDDY for motion correction and eddy current correction (should be done before distortion correction -per FSL's Mark Jenkinson 
		echo "running eddy"
		if [ -e $path/$bblid/$sessionid/DTI_64/raw_merged_dti/*merged.nii.gz ] && [ ! -e $path/$bblid/$sessionid/DTI_64/eddy/$id"_eddy.nii.gz" ]; then
		logrun eddy --imain=$dti_image_64 --mask="$path/$bblid/$sessionid/DTI_64/raw_merged_dti/"$id"_dtistd_2.mask.nii.gz" --acqp=$acqparams --index=$indexfile_64 --bvecs=$bvecs_64 --bvals=$bvals_64 --out="$path/$bblid/$sessionid/DTI_64/eddy/"$id"_eddy"
		else
		echo "ERROR: merged DTI image does not exist"
		error_msg4="ERROR: merged DTI image does not exist"
		fi

#Extract Motion Parameters from EDDY Corrected data
		echo "extract motion parameters"
		if [ -e $path/$bblid/$sessionid/DTI_64/eddy/$id"_eddy.eddy_parameters" ] && [ ! -e $path/$bblid/$sessionid/DTI_64/eddy/$id"_6param_eddy_parameters" ]; then 
		echo "eddy was run....time to extract 6 motion parameters"
		cat $path/$bblid/$sessionid/DTI_64/eddy/$id"_eddy.eddy_parameters" | sed "s/  / /g" | cut  -d " " -f 1-6 > $path/$bblid/$sessionid/DTI_64/eddy/$id.6param.eddy_parameters
		else 
		echo "ERROR: EDDY motion parameters do not exist"
		error_msg5="ERROR: EDDY motion parameters do not exist"
		fi

#Rotate bvecs file after motion correction
		echo "rotate bvecs"		
		if [ -e $path/$bblid/$sessionid/DTI_64/eddy/$id"_eddy.eddy_parameters" ] ; then
		logrun /home/melliott/scripts/ME_rotate_bvecs.sh $bvecs_64 $path/$bblid/$sessionid/DTI_64/raw_merged_dti/$id".dti.merged_rotated.bvec" $path/$bblid/$sessionid/DTI_64/eddy/$id"_eddy.eddy_parameters"
		else 
		logrun echo "ERROR: EDDY motion parameters do not exist"
		error_msg5="ERROR: EDDY motion parameters do not exist"
		fi
		
#copy bvals from raw_merged
		
		if [ ! -e $path/$bblid/$sessionid/DTI_64/corrected_b_files/*.bval ]; then 
		echo "copy bvals"		
		cp $bvals_64 $path/$bblid/$sessionid/DTI_64/corrected_b_files/


		else 

		echo "bvals already exist" 

		fi

#copy bvecs from eddy
		echo "copy bvecs"		
		mv $path/$bblid/$sessionid/DTI_64/raw_merged_dti/$id".dti.merged_rotated.bvec" $path/$bblid/$sessionid/DTI_64/raw_merged_dti/$id"_dti_merged_rotated.bvec"	
	
		cp $path/$bblid/$sessionid/DTI_64/raw_merged_dti/$id"_dti_merged_rotated.bvec" $path/$bblid/$sessionid/DTI_64/corrected_b_files/


#Apply distortion correction using field map
		echo "apply distortion"		
		#if [ -e /data/joy/BBL/studies/pnc/processedData/b0mapwT2star/$bblid/$sessionid/*mag1_brain.nii* ] && [ -e /data/joy/BBL/studies/pnc/processedData/b0mapwT2star/$bblid/$sessionid/*rpsmap.nii* ] && [ -e /data/joy/BBL/studies/pnc/processedData/b0mapwT2star/$bblid/$sessionid/*mask.nii* ] && [ ! -e $path/$bblid/$sessionid/"$id".dico_dico.nii.gz ]; then
		#cd $path/$bblid/$sessionid/DTI_64/dico_corrected/
		#echo "running distortion correction"
		logrun /home/melliott/scripts/dico_correct_v2.sh -n -k -f /data/joy/BBL/studies/pnc/processedData/b0mapwT2star/$bblid/$sessionid/*mag1_brain.nii* -e /data/joy/BBL/studies/pnc/rawData/$bblid/$sessionid/DTI_2x32_35/dicoms/*00.dcm $path/$bblid/$sessionid/DTI_64/dico_corrected/$id".dico." /data/joy/BBL/studies/pnc/processedData/b0mapwT2star/$bblid/$sessionid/*rpsmap.nii* /data/joy/BBL/studies/pnc/processedData/b0mapwT2star/$bblid/$sessionid/*mask.nii* $path/$bblid/$sessionid/DTI_64/eddy/$id"_eddy".nii.gz
		cd $path
		#else 
		#logrun echo "ERROR: Distortion Correction could not be run. Check B0_map_new folder"
		3error_msg6="ERROR: Distortion Correction could not be run. Check B0_map_new folder"
		#fi

#Estimate tensors with and without motion regressors and rotated b-vectors file distortion correction
		if [ -e $path/$bblid/$sessionid/DTI_64/dico_corrected/$id".dico_dico.nii" ] ; then
		
		#Estimate tensor with confound regressors and with rotated b-vectors file distortion correction		
		echo "moving on to next, using 6 parameter motion as confound regressors and rotating bvecs"
		logrun dtifit -k $path/$bblid/$sessionid/DTI_64/dico_corrected/$id".dico_dico.nii" -o $path/$bblid/$sessionid/DTI_64/dtifit/"$id"_dti_eddy_rbvecs -m $path/$bblid/$sessionid/DTI_64/raw_merged_dti/$id"_dtistd_2.mask.nii.gz" -r $path/$bblid/$sessionid/DTI_64/corrected_b_files/$id"_dti_merged_rotated".bvec -b $path/$bblid/$sessionid/DTI_64/corrected_b_files/*.bval --cni=$path/$bblid/$sessionid/DTI_64/eddy/$id".6param.eddy_parameters"
		echo "running dtifit in standard FSL pipeline"
		

		elif [ -e $path/$bblid/$sessionid/DTI_64/dico_corrected/$id".dico_dico."nii.gz ] ; then
		
		#Estimate tensor with confound regressors and with rotated b-vectors file distortion correction		
		echo "moving on to next, using 6 parameter motion as confound regressors and rotating bvecs"
		logrun dtifit -k $path/$bblid/$sessionid/DTI_64/dico_corrected/$id".dico_dico".nii.gz -o $path/$bblid/$sessionid/DTI_64/dtifit/$id"_dti_eddy_rbvecs" -m $path/$bblid/$sessionid/DTI_64/raw_merged_dti/$id"dtistd_2.mask.nii.gz" -r $path/$bblid/$sessionid/DTI_64/corrected_b_files/$id"_dti_merged_rotated.bvec" -b $path/$bblid/$sessionid/DTI_64/corrected_b_files/*.bval --cni=$path/$bblid/$sessionid/DTI_64/eddy/$id".6param.eddy_parameters"
		echo "running dtifit in standard FSL pipeline"

		elif [ ! -e $path/$bblid/$sessionid/DTI_64/dico_corrected/$id".dico_dico.nii" ] ; then
		logrun dtifit -k $path/$bblid/$sessionid/DTI_64/eddy/$id"_eddy.nii.gz" -o $path/$bblid/$sessionid/DTI_64/dtifit/$id"_dti_eddy_rbvecs" -m $path/$bblid/$sessionid/DTI_64/raw_merged_dti/$id"_dtistd_2.mask.nii.gz" -r $path/$bblid/$sessionid/DTI_64/corrected_b_files/$id"_dti_merged_rotated".bvec -b $path/$bblid/$sessionid/DTI_64/corrected_b_files/*.bval --cni=$path/$bblid/$sessionid/DTI_64/eddy/$id.6param.eddy_parameters
		echo "running dtifit in standard FSL pipeline"

		else
		logrun echo "ERROR: DTIFIT fail NO distortion corrected image availabe"
		error_msg7="ERROR: DTIFIT fail NO distortion corrected image availabe"
		echo $sessionid $error_msg1 $error_msg2 $error_msg3 $error_msg4 $error_msg5 $error_msg6 $error_msg7 >> $process_fail
		fi


#echo "Pull 64 direction QA data" 

qafile_64=$path/$bblid/$sessionid/DTI_64/qa/$id.qa

		#cd $path/$bblid/$sessionid/DTI_64/qa
		

clipcount=$(cat $qafile_64|grep clipcount |awk '{print $2}')
tsnr=$(cat $qafile_64 | grep tsnr_bX | awk '{print $2}')
gmean=$(cat $qafile_64 | grep gmean_bX | awk '{print $2}')
drift=$(cat $qafile_64 | grep drift_bX | awk '{print $2}')
outmax=$(cat $qafile_64 | grep outmax_bX | awk '{print $2}')
outmean=$(cat $qafile_64 | grep outmean_bX | awk '{print $2}')
outcount=$(cat $qafile_64 | grep outcount_bX | awk '{print $2}')
meanABSrms=$(cat $qafile_64 | grep meanABSrms | awk '{print $2}')
meanRELrms=$(cat $qafile_64 | grep meanRELrms | awk '{print $2}')
maxABSrms=$(cat $qafile_64 | grep maxABSrms | awk '{print $2}')
maxRELrms=$(cat $qafile_64 | grep maxRELrms | awk '{print $2}')

echo "bblid", "sessionid", "date","clipcount", "temporal_signal-to-noise_ratio","gmean", "drift", "maximum_intensity_outlier", "mean_intensity_outlier", "count_outlier", "abs_mean_rms_motion","rel_mean_rms_motion","abs_max_rms_motion", "rel_max_rms_motion">>$out_64

echo $bblid $sessionid $date $clipcount $tsnr $gmean $drift $outmax $outmean $outcount $meanABSrms $meanRELrms $maxABSrms $maxRELrms >>$out_64

else 

logrun echo "dtifit already run" 

fi

echo "End of 64 direction processing, move on to 32 directions" 


#32 Directions processing

#Make DTI coverage mask for each subject by backtransforming FSL's FMRIB58 DTI mask to native space

#Register single b=0 dwi image to FMRIB58 DTI FA map
echo "Begin 32 direction processing" 
	

#if [ ! -e $path/$bblid/$sessionid/DTI_32/dtifit/*FA.nii.gz ] ; then 


		echo "register b=0 to FMRIB58"
		if [ -e $path/$bblid/$sessionid/DTI_32/qa/*b0mean.nii.gz ] ; then
		echo "move b=0 image to standard space"
		logrun flirt -dof 6 -in $path/$bblid/$sessionid/DTI_32/qa/*b0mean.nii.gz -ref /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/FMRIB58_FA_1mm.nii.gz -out $path/$bblid/$sessionid/DTI_32/raw_dti/$id"_dwi_n_standard_space.nii.gz" -omat $path/$bblid/$sessionid/DTI_32/raw_dti/$id"_dwi_n_standard_space.mat"
		echo "dwi to std space done"
		else
		echo "ERROR: no mean b=0 image"
		error_msg1="ERROR: no b=0 image"
		fi		

#Invert transform
		echo "invert transform"		
		if [ -e $path/$bblid/$sessionid/DTI_32/raw_dti/$id"_dwi_n_standard_space.mat" ] ; then
		logrun convert_xfm -omat $path/$bblid/$sessionid/DTI_32/raw_dti/$id"_std_n_dwi_space.mat" -inverse $path/$bblid/$sessionid/DTI_32/raw_dti/$id"_dwi_n_standard_space.mat"
		else
		echo "ERROR: dwi to standard not run"
		error_msg2="ERROR: dwi to standard not run"
		fi

#Transform FMRIB58 FA to single subject space
		echo "FMRIB to native"			
		if [ -e $path/$bblid/$sessionid/DTI_32/raw_dti/$id"_std_n_dwi_space.mat" ] ; then
		logrun flirt -in /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/FMRIB58_mask.nii.gz -ref $path/$bblid/$sessionid/DTI_32/qa/*b0mean.nii.gz -interp nearestneighbour -applyxfm -init $path/$bblid/$sessionid/DTI_32/raw_dti/$id"_std_n_dwi_space.mat" -out $path/$bblid/$sessionid/DTI_32/raw_dti/$id"_dtistd_2.mask.nii.gz"
		else
		echo "ERROR: inverse transformation matrix does not exist"
		error_msg3="ERROR: inverse transformation matrix does not exist"
		fi

#Run FSL EDDY for motion correction and eddy current correction (should be done before distortion correction -per FSL's Mark Jenkinson 
		echo "running eddy"
		if [ -e $dti_image_32 ] && [ ! -e $path/$bblid/$sessionid/DTI_32/eddy/$id"_eddy.nii.gz" ]; then
		logrun eddy --imain=$dti_image_32 --mask="$path/$bblid/$sessionid/DTI_32/raw_dti/"$id"_dtistd_2.mask.nii.gz" --acqp=$acqparams --index=$indexfile_32 --bvecs=$bvecs_32 --bvals=$bvals_32 --out="$path/$bblid/$sessionid/DTI_32/eddy/"$id"_eddy"
		else
		echo "ERROR: merged DTI image does not exist"
		error_msg4="ERROR: merged DTI image does not exist"
		fi

#Extract Motion Parameters from EDDY Corrected data
		echo "extract motion parameters"
		if [ -e $path/$bblid/$sessionid/DTI_32/eddy/$id"_eddy.eddy_parameters" ] ; then 
		echo "eddy was run....time to extract 6 motion parameters"
		cat $path/$bblid/$sessionid/DTI_32/eddy/$id"_eddy.eddy_parameters" | sed "s/  / /g" | cut  -d " " -f 1-6 > $path/$bblid/$sessionid/DTI_32/eddy/$id.6param.eddy_parameters
		else 
		echo "ERROR: EDDY motion parameters do not exist"
		error_msg5="ERROR: EDDY motion parameters do not exist"
		fi

#Rotate bvecs file after motion correction
		echo "rotate bvecs"		
		if [ -e $path/$bblid/$sessionid/DTI_32/eddy/$id"_eddy.eddy_parameters" ] ; then
		logrun /home/melliott/scripts/ME_rotate_bvecs.sh $bvecs_32 $path/$bblid/$sessionid/DTI_32/raw_dti/$id".dti.32_rotated.bvec" $path/$bblid/$sessionid/DTI_32/eddy/$id"_eddy.eddy_parameters"
		else 
		logrun echo "ERROR: EDDY motion parameters do not exist"
		error_msg5="ERROR: EDDY motion parameters do not exist"
		fi
		
#copy bvals from raw_dti
		echo "copy bvals"		
		cp $bvals_32 $path/$bblid/$sessionid/DTI_32/corrected_b_files/

#copy bvecs from raw_dti

		echo "copy bvecs"

		cp $path/$bblid/$sessionid/DTI_32/raw_dti/$id".dti.32_rotated.bvec" $path/$bblid/$sessionid/DTI_32/corrected_b_files/ 
		mv $path/$bblid/$sessionid/DTI_32/corrected_b_files/$id".dti.32_rotated.bvec" $path/$bblid/$sessionid/DTI_32/corrected_b_files/$id"_dti_32_rotated.bvec"



#Apply distortion correction using field map
		echo "apply distortion"		
		#if [ -e /data/joy/BBL/studies/pnc/processedData/b0mapwT2star/$bblid/$sessionid/*mag1_brain.nii* ] && [ -e /data/joy/BBL/studies/pnc/processedData/b0mapwT2star/$bblid/$sessionid/*rpsmap.nii* ] && [ -e /data/joy/BBL/studies/pnc/processedData/b0mapwT2star/$bblid/$sessionid/*mask.nii* ] ; then
		cd $path/$bblid/$sessionid/DTI_32/dico_corrected/
		#echo "running distortion correction"
		logrun /home/melliott/scripts/dico_correct_v2.sh -n -k -f /data/joy/BBL/studies/pnc/processedData/b0mapwT2star/$bblid/$sessionid/*mag1_brain.nii* -e /data/joy/BBL/studies/pnc/rawData/$bblid/$sessionid/DTI_2x32_35/*00.dcm $path/$bblid/$sessionid/DTI_32/dico_corrected/$id".dico." /data/joy/BBL/studies/pnc/processedData/b0mapwT2star/$bblid/$sessionid/*rpsmap.nii* /data/joy/BBL/studies/pnc/processedData/b0mapwT2star/$bblid/$sessionid/*mask.nii* $path/$bblid/$sessionid/DTI_32/eddy/$id"_eddy".nii.gz
		cd $path
		#else 
		#logrun echo "ERROR: Distortion Correction could not be run. Check B0_map_new folder"
		#error_msg6="ERROR: Distortion Correction could not be run. Check B0_map_new folder"
		#fi

#Estimate tensors with and without motion regressors and rotated b-vectors file distortion correction
		if [ -e $path/$bblid/$sessionid/DTI_32/dico_corrected/$id.dico_dico.nii ] ; then
		
		#Estimate tensor with confound regressors and with rotated b-vectors file distortion correction		
		echo "moving on to next, using 6 parameter motion as confound regressors and rotating bvecs"
		dtifit -k $path/$bblid/$sessionid/DTI_32/dico_corrected/$id.dico_dico.nii -o $path/$bblid/$sessionid/DTI_32/dtifit/$id"_dti_eddy_rbvecs" -m $path/$bblid/$sessionid/DTI_32/raw_dti/$id"_dtistd_2.mask.nii.gz" -r $path/$bblid/$sessionid/DTI_32/corrected_b_files/$id"_dti_32_rotated.bvec" -b $path/$bblid/$sessionid/DTI_32/corrected_b_files/*.bval --cni=$path/$bblid/$sessionid/DTI_32/eddy/$id".6param.eddy_parameters"
		echo "running dtifit in standard FSL pipeline"
		
		elif [ ! -e $path/$bblid/$sessionid/DTI_32/dico_corrected/$id.dico_dico.nii ] ; then
		dtifit -k $path/$bblid/$sessionid/DTI_32/eddy/$id"_eddy.nii.gz" -o $path/$bblid/$sessionid/DTI_32/dtifit/$id"_dti_eddy_rbvecs" -m $path/$bblid/$sessionid/DTI_32/raw_dti/$id"_dtistd_2.mask.nii.gz" -r $path/$bblid/$sessionid/DTI_32/corrected_b_files/$id"_dti_32_rotated.bvec" -b $path/$bblid/$sessionid/DTI_32/corrected_b_files/*.bval --cni=$path/$bblid/$sessionid/DTI_32/eddy/$id."6param.eddy_parameters"
		#echo "running dtifit in standard FSL pipeline"

		else
		logrun echo "ERROR: DTIFIT fail NO distortion corrected image availabe"
		error_msg7="ERROR: DTIFIT fail NO distortion corrected image availabe"
		echo $sessionid $error_msg1 $error_msg2 $error_msg3 $error_msg4 $error_msg5 $error_msg6 $error_msg7 >> $process_fail

		fi

#else 

#logrun echo "dtifit already run" 

#fi 

echo "End of 32 direction processing" 

#echo "Pull 32 direction QA data" 

#cd $path/$bblid/$sessionid/DTI_32/qa
qafile_32=$path/$bblid/$sessionid/DTI_32/qa/"$id".qa

clipcount=$(cat $qafile_32 | grep clipcount |awk '{print $2}')
tsnr=$(cat $qafile_32 | grep tsnr_bX | awk '{print $2}'); 
gmean=$(cat $qafile_32 | grep gmean_bX | awk '{print $2}');
drift=$(cat $qafile_32 | grep drift_bX | awk '{print $2}');
outmax=$(cat $qafile_32 | grep outmax_bX | awk '{print $2}');
outmean=$(cat $qafile_32 | grep outmean_bX | awk '{print $2}');
outcount=$(cat $qafile_32 | grep outcount_bX | awk '{print $2}');
meanABSrms=$(cat $qafile_32 | grep meanABSrms | awk '{print $2}');
meanRELrms=$(cat $qafile_32 | grep meanRELrms | awk '{print $2}');
maxABSrms=$(cat $qafile_32 | grep maxABSrms | awk '{print $2}');
maxRELrms=$(cat $qafile_32 | grep maxRELrms | awk '{print $2}');

echo "bblid", "sessionid", "date","clipcount", "temporal_signal-to-noise_ratio","gmean", "drift", "maximum_intensity_outlier", "mean_intensity_outlier", "count_outlier", "abs_mean_rms_motion","rel_mean_rms_motion","abs_max_rms_motion", "rel_max_rms_motion">>$out_32
echo $bblid, $sessionid, $date, $clipcount, $tsnr, $gmean, $drift, $outmax, $outmean, $outcount, $meanABSrms, $meanRELrms, $maxABSrms,$maxRELrms >>$out_32;

for l in $path/$bblid/$sessionid/DTI_32/dico_corrected/*.nii

do


/share/apps/fsl/5.0.8/bin/fslchfiletype NIFTI_GZ $l

done

for m in $path/$bblid/$sessionid/DTI_64/dico_corrected/*.nii

do


/share/apps/fsl/5.0.8/bin/fslchfiletype NIFTI_GZ $m

done

#Change file names to not have "." and have "_" instead 

if [ -e $path/$bblid/$sessionid/DTI_64/dtifit/*FA.nii.gz ]; then 

cd $path/$bblid/$sessionid/DTI_64/
logrun mv dico_corrected/"$id".dico_dico.nii.gz dico_corrected/"$id"_dico_dico.nii.gz
logrun mv dico_corrected/"$id".dico_magmap_coreg.nii.gz dico_corrected/"$id"_dico_magmap_coreg.nii.gz
logrun mv dico_corrected/"$id".dico_magmap_masked.nii.gz dico_corrected/"$id"_dico_magmap_masked.nii.gz
logrun mv dico_corrected/"$id".dico.mat dico_corrected/"$id"_dico.mat
logrun mv dico_corrected/"$id".dico_rpsmap_coreg.nii.gz dico_corrected/"$id"_dico_rpsmap_coreg.nii.gz
logrun mv dico_corrected/"$id".dico_rpsmap_mask_coreg.nii.gz dico_corrected/"$id"_dico_rpsmap_mask_coreg.nii.gz
logrun mv dico_corrected/"$id".dico_shiftmap.nii.gz dico_corrected/"$id"_dico_shiftmap.nii.gz
logrun mv dico_corrected/"$id".dico_shims.txt dico_corrected/"$id"_dico_shims.txt

logrun mv eddy/"$id".6param.eddy_parameters eddy/"$id"_6param_eddy_parameters
logrun mv eddy/"$id"_eddy.eddy_parameters eddy/"$id"_eddy_eddy_parameters

logrun mv raw_merged_dti/"$id".dti.merged.bval raw_merged_dti/"$id"_dti_merged.bval
logrun mv raw_merged_dti/"$id".dti.merged.bvec raw_merged_dti/"$id"_dti_merged.bvec
logrun mv raw_merged_dti/"$id".dti.merged_exampledicom.DCM raw_merged_dti/"$id"_dti_merged_exampledicom.DCM
logrun mv raw_merged_dti/"$id".dti.merged.log raw_merged_dti/"$id"_dti_merged.log
logrun mv raw_merged_dti/"$id".dti.merged.nii.gz raw_merged_dti/"$id"_dti_merged.nii.gz
logrun mv raw_merged_dti/"$id".mask.nii.gz raw_merged_dti/"$id"_mask.nii.gz
logrun mv raw_merged_dti/"$id"_dtistd_2.mask.nii.gz raw_merged_dti/"$id"_dtistd_2_mask.nii.gz

logrun mv corrected_b_files/"$id".dti.merged.bval corrected_b_files/"$id"_dti_merged.bval

logrun mv qa/"$id".dti.merged_b0_mc_abs.1D qa/"$id"_dti_merged_b0_mc_abs.1D
logrun mv qa/"$id".dti.merged_b0_mc_abs_mean.rms qa/"$id"_dti_merged_b0_mc_bas_mean.rms
logrun mv qa/"$id".dti.merged_b0_mc.mat qa/"$id"_dti_merged_b0_mc.mat
logrun mv qa/"$id".dti.merged_b0_mc.nii.gz qa/"$id"_dti_merged_b0_mc.nii.gz
logrun mv qa/"$id".dti.merged_b0_mc_rel.1D qa/"$id"_dti_merged_b0_mc_rel.1D
logrun mv qa/"$id".dti.merged_b0_mc_rel_mean.rms qa/"$id"_dti_merged_b0_mc_rel_mean.rms
logrun mv qa/"$id".dti.merged_b0mean.nii.gz qa/"$id"_dti_merged_b0mean.nii.gz
logrun mv qa/"$id".dti.merged_b0.nii.gz qa/"$id"_dti_merged_b0.nii.gz
logrun mv qa/"$id".dti.merged_bX_gsig.1D qa/"$id"_dti_merged_bX_gsig.1D
logrun mv qa/"$id".dti.merged_bX_mean.nii.gz qa/"$id"_dti_merged_bX_mean.nii.gz
logrun mv qa/"$id".dti.merged_bX.nii.gz qa/"$id"_dti_merged_bX.nii.gz
logrun mv qa/"$id".dti.merged_bX_outlist.1D qa/"$id"_dti_merged_bX_outlist.1D
logrun mv qa/"$id".dti.merged_bX_outsupra.1D qa/"$id"_dti_merged_bX_outsupra.1D
logrun mv qa/"$id".dti.merged_bX_std.nii.gz qa/"$id"_dti_merged_bX_std.nii.gz
logrun mv qa/"$id".dti.merged_bX_tsnr.nii.gz qa/"$id"_dti_merged_bX_tsnr.nii.gz
logrun mv qa/"$id".dti.merged_clipmask.nii.gz qa/"$id"_dti_merged_clipmask.nii.gz
logrun mv qa/"$id".dti.merged_qamask.nii.gz qa/"$id"_dti_merged_qamask.nii.gz
logrun mv qa/"$id".dti.merged_tsnrmask.nii.gz qa/"$id"_dti_merged_tsnrmask.nii.gz

fi 

if [ -e $path/$bblid/$sessionid/DTI_32/dtifit/*FA.nii.gz ] ; then 

cd $path/$bblid/$sessionid/DTI_32/
logrun mv dico_corrected/"$id".dico_dico.nii.gz dico_corrected/"$id"_dico_dico.nii.gz
logrun mv dico_corrected/"$id".dico_magmap_coreg.nii.gz dico_corrected/"$id"_dico_magmap_coreg.nii.gz
logrun mv dico_corrected/"$id".dico_magmap_masked.nii.gz dico_corrected/"$id"_dico_magmap_masked.nii.gz
logrun mv dico_corrected/"$id".dico.mat dico_corrected/"$id"_dico.mat
logrun mv dico_corrected/"$id".dico_rpsmap_coreg.nii.gz dico_corrected/"$id"_dico_rpsmap_coreg.nii.gz
logrun mv dico_corrected/"$id".dico_rpsmap_mask_coreg.nii.gz dico_corrected/"$id"_dico_rpsmap_mask_coreg.nii.gz
logrun mv dico_corrected/"$id".dico_shiftmap.nii.gz dico_corrected/"$id"_dico_shiftmap.nii.gz
logrun mv dico_corrected/"$id".dico_shims.txt dico_corrected/"$id"_dico_shims.txt

logrun mv eddy/"$id".6param.eddy_parameters eddy/"$id"_6param_eddy_parameters
logrun mv eddy/"$id"_eddy.eddy_parameters eddy/"$id"_eddy_eddy_parameters

logrun mv raw_dti/"$id".dti.32_rotated.bvec raw_dti/"$id"_dti_32_rotated.bvec
logrun mv raw_dti/"$id"_dtistd_2.mask.nii.gz raw_dti/"$id"_dtistd_2_mask.nii.gz

fi


#Rename and create RD and AD images

if [ -e $path/$bblid/$sessionid/DTI_64/dtifit/*L1.nii.gz ] ; then 

cp $path/$bblid/$sessionid/DTI_64/dtifit/*L1.nii.gz $path/$bblid/$sessionid/DTI_64/dtifit/"$id"_dti_eddy_rbvecs_AD.nii.gz 

fi

if [ -e $path/$bblid/$sessionid/DTI_32/dtifit/*L1.nii.gz ] ; then

cp $path/$bblid/$sessionid/DTI_32/dtifit/*L1.nii.gz $path/$bblid/$sessionid/DTI_32/dtifit/"$id"_dti_eddy_rbvecs_AD.nii.gz 

fi

if [ -e $path/$bblid/$sessionid/DTI_64/dtifit/*L2.nii.gz ] && [ -e $path/$bblid/$sessionid/DTI_64/dtifit/*L3.nii.gz ] ; then 

fslmaths $path/$bblid/$sessionid/DTI_64/dtifit/*L2.nii.gz -add $path/$bblid/$sessionid/DTI_64/dtifit/*L3.nii.gz $path/$bblid/$sessionid/DTI_64/dtifit/"$id"_RDtmp.nii.gz

fslmaths $path/$bblid/$sessionid/DTI_64/dtifit/"$id"_RDtmp.nii.gz -div 2 $path/$bblid/$sessionid/DTI_64/dtifit/"$id"_dti_eddy_rbvecs_RD.nii.gz

rm $path/$bblid/$sessionid/DTI_64/dtifit/"$id"_RDtmp.nii.gz

fi

if [ -e $path/$bblid/$sessionid/DTI_32/dtifit/*L2.nii.gz ] && [ -e $path/$bblid/$sessionid/DTI_32/dtifit/*L3.nii.gz ] ; then 

fslmaths $path/$bblid/$sessionid/DTI_32/dtifit/*L2.nii.gz -add $path/$bblid/$sessionid/DTI_32/dtifit/*L3.nii.gz $path/$bblid/$sessionid/DTI_32/dtifit/"$id"_RDtmp.nii.gz

fslmaths $path/$bblid/$sessionid/DTI_32/dtifit/"$id"_RDtmp.nii.gz -div 2 $path/$bblid/$sessionid/DTI_32/dtifit/"$id"_dti_eddy_rbvecs_RD.nii.gz

rm $path/$bblid/$sessionid/DTI_32/dtifit/"$id"_RDtmp.nii.gz

fi


