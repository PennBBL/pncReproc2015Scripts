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

#!/bin/bash

###check for necessary software/scripts
fsl=`ls $FSLDIR/bin/feat 2> /dev/null`
seq2nifti=`ls /home/melliott/scripts/sequence2nifti.sh 2> /dev/null`
dti_qa=`ls /home/melliott/scripts/qa_dti_v1.sh 2> /dev/null`
if [ ! -z $fsl ]  && [ ! -z $seq2nifti ] && [ ! -z $dti_qa ];then
echo "All necessary programs/scripts found."
echo "Checking for necessary files by subject."

####
#List of subjects to be analyzed (off of subject list or xnat audit)
subjects=/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/antsCT/cohort_list.csv
#subjects=/data/joy/BBL/studies/pnc/processedData/diffusion/directions_64/imaging_variables/n1601_eons_xnat_audit_7_1_14.csv

#List to be populated for grid submission
joblist=/data/joy/BBL/studies/pnc/processedData/diffusion/directions_64/imaging_variables/eons_joblist.txt

#List of subjects missing base DTI file
no_merge_dti=/data/joy/BBL/studies/pnc/processedData/diffusion/directions_64/imaging_variables/eons_dti_missing.csv

#error file
process_fail=/data/joy/BBL/studies/pnc/processedData/diffusion/directions_64/imaging_variables/dti_process_fail.csv

#Remove all previous versions of joblist and missing 
rm -f $joblist
rm -f $no_merge_dti
rm -f $process_fail

for s in $(cat $subjects); do 
	#if [ `echo $s | cut -d "," -f 10 | cut -c 1` == 0 ] ; then
	#bblid=`echo $s | cut -d "," -f 10 | cut -c 2-6`
	#else
	#bblid=`echo $s | cut -d "," -f 10`
	#fi
	#scanid=`echo $s |cut -d ',' -f1 | cut -c 3-6`;
	bblid=`echo $s | cut -d "_" -f 1`
	scanid=`echo $s | cut -d"_" -f 2`	
	sessionid=`echo $s | cut -d "_" -f 3`	
	subid=`echo $sessionid"s"$scanid`;	
	
	#has_dti=`echo $s | cut -d "," -f 3`
	date=`date +%Y-%m-%d`
	i=/data/joy/BBL/studies/pnc/processedData/diffusion/directions_64/subjects/$bblid
	dti_nii_out=/data/joy/BBL/studies/pnc/processedData/diffusion/directions_64/subjects/$bblid/$subid/DTI/bbl/raw_merged_dti/$scanid.dti.merged.nii 
	dti_nii_gz_out=/import/monstrum/eons_xnat/subjects/$subid/DTI/bbl/raw_merged_dti/$scanid.dti.merged.nii.gz
	logfile=/import/monstrum/eons_xnat/subjects/$subid/DTI/bbl/$scanid"_logfile_pipeline_"$date".log"
	echo $i
	echo " Processing subject "$subid

#Check if 'bbl' folder exists (dtifit is the last folder populated), if not make one
	#if [ ! -e $i/DTI/bbl/dtifit/dico_corrected/motion_regressors ] && [ $has_dti == 1 ]; then
		echo "making bbl directory"
		#mkdir $i/DTI
		mkdir $i/DTI/bbl
		mkdir $i/DTI/bbl/raw_merged_dti
		mkdir $i/DTI/bbl/qa
		mkdir $i/DTI/bbl/eddy_results
		mkdir $i/DTI/bbl/eddy_results/dico_corrected
		mkdir $i/DTI/bbl/dtifit
		mkdir $i/DTI/bbl/dtifit/dico_corrected
		mkdir $i/DTI/bbl/dtifit/non_dico_corrected
		mkdir $i/DTI/bbl/dtifit/non_dico_corrected/no_motion_regressors
		mkdir $i/DTI/bbl/dtifit/non_dico_corrected/motion_regressors
		mkdir $i/DTI/bbl/dtifit/dico_corrected/no_motion_regressors
		mkdir $i/DTI/bbl/dtifit/dico_corrected/motion_regressors
	#else
		echo "BBL DTI folder structure complete"
	#fi

#Check if Merged DTI file is present, if not make one
		#if [ ! -e "$dti_nii_out" ] && [ ! -e "$dti_nii_gz_out" ] && [ $has_dti == 1 ]; then 
		#logrun echo "merged DTI file does not exist ..creating it now for this subject"
		logrun /import/speedy/scripts/melliott/sequence2nifti.sh DTI_CONCAT /import/monstrum/eons_xnat/subjects/$subid/DTI/bbl/raw_merged_dti/"$scanid".dti.merged.nii /import/monstrum/eons_xnat/subjects/$subid/*DTI*35*/dicoms/*.dcm /import/monstrum/eons_xnat/subjects/$subid/*DTI*36*/dicoms/*.dcm 
		#logrun echo "DTI data merged" 
		#else
	 	#echo "merged data exists...skipping"
		#fi

#If QA has already been run, then skip the next two steps

qa_file=`ls $i/DTI/bbl/qa/"$scanid".qa`

	# if [ "X$qa_file" == "X" ] && [ $has_dti == 1 ]; then 
		#Run QA on merged DTI file
		if [ -e "$dti_nii_out" ] ; then		
		#echo "running QA"
	logrun /import/speedy/scripts/melliott/qa_dti_v1.sh -keep /import/monstrum/eons_xnat/subjects/$subid/DTI/bbl/raw_merged_dti/*dti.merged.nii /import/monstrum/eons_xnat/subjects/$subid/DTI/bbl/raw_merged_dti/*.bval /import/monstrum/eons_xnat/subjects/$subid/DTI/bbl/raw_merged_dti/*.bvec /import/monstrum/eons_xnat/subjects/$subid/DTI/bbl/qa/"$scanid".qa 
		#echo "QA complete"
		elif [ -e "$dti_nii_gz_out" ]; then
		#echo "running QA"
	logrun /import/speedy/scripts/melliott/qa_dti_v1.sh /import/monstrum/eons_xnat/subjects/$subid/DTI/bbl/raw_merged_dti/*dti.merged.nii.gz /import/monstrum/eons_xnat/subjects/$subid/DTI/bbl/raw_merged_dti/*.bval /import/monstrum/eons_xnat/subjects/$subid/DTI/bbl/raw_merged_dti/*.bvec /import/monstrum/eons_xnat/subjects/$subid/DTI/bbl/qa/"$scanid".qa
		#echo "QA complete"		
		#else
		#echo "no DTI, skipping"
		fi

		#Create list of subjects to run DTI processing steps
		if [ -e "$dti_nii_out" ]; then 
			echo $subid >> $joblist
		elif [ -e "$dti_nii_gz_out" ]; then 
			echo $subid >> $joblist
		else
			echo $subid >> $no_merge_dti "no DTI, skipping" 
		fi

	#elif [ ! "X$qa_file" == "X" ] ; then
	#echo "QA complete"
	#fi #if [ "X$qa_file" == "X" ] && [ $has_dti == 1 ]; then 

done #for s in $(cat $subjects); do

ntasks=$(cat $joblist | wc -l)
echo "number of jobs in array is $ntasks"

#NOW SUBMIT TO SGE AS TASK ARRAY
qsub -V -q all.q -S /bin/bash -o ~/eons_dti_logs -e ~/eons_dti_logs -t 1-${ntasks} /import/monstrum/eons_xnat/progs/DTI/GO1_DTI_process.sh $joblist 
 
else
echo "*******"
echo "ERROR: One or more of the scripts required to quantify and register DTI is missing."
echo "FSL: "$fsl
echo "seq2nifiti: "$seq2nifiti
echo "dti_qa: "$dtiqa
echo "*******"

fi #if [ ! -z $fsl ]  && [ ! -z $seq2nifti ] && [ ! -z $dti_qa ];then
