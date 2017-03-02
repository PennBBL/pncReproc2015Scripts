#!/bin/bash
#DRR adding comments for Wiki and GitHub
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


###check for necessary software/scripts
fsl=`ls $FSLDIR/bin/feat 2> /dev/null`
seq2nifti=`ls /home/melliott/scripts/sequence2nifti.sh 2> /dev/null`
dti_qa=`ls /home/melliott/scripts/qa_dti_v2.sh 2> /dev/null`
if [ ! -z $fsl ]  && [ ! -z $seq2nifti ] && [ ! -z $dti_qa ];then
echo "All necessary programs/scripts found."
echo "Checking for necessary files by subject."

####
#List of subjects to be analyzed (off of subject list or xnat audit)
subjects=/data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/sublists/redo_01092017.csv
#subjects=/data/joy/BBL/studies/pnc/processedData/diffusion/directions_64/imaging_variables/n1601_eons_xnat_audit_7_1_14.csv

#List to be populated for grid submission
joblist=/data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/eons_joblist.txt

#List of subjects missing base 64 direction DTI file
no_merge_dti=/data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/eons_dti_merged_missing.csv

#List of subjects missing base 32 direction DTI file
no_32_dti=/data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/no_32_dti.csv


#error file
process_fail=/data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/process_fail.csv

#Remove all previous versions of joblist and missing 
rm -f $joblist


for s in $(cat $subjects | tr "\r" "\n"); do 
	#if [ `echo $s | cut -d "," -f 10 | cut -c 1` == 0 ] ; then
	#bblid=`echo $s | cut -d "," -f 10 | cut -c 2-6`
	#else
	#bblid=`echo $s | cut -d "," -f 10`
	#fi
	#scanid=`echo $s |cut -d ',' -f1 | cut -c 3-6`;
	echo $s
	bblid=`echo $s | cut -d "_" -f1`
	echo $bblid
	sessionid=`echo $s | cut -d "_" -f2 | cut -d "x" -f2`
	echo $sessionid	
	scanid=`echo $s | cut -d "_" -f2 |cut -d "x" -f1`
	echo $scanid	
	subid=`echo $sessionid"x"$scanid`
	echo $subid
	dti_name=`echo $bblid"_"$subid`
	echo $dti_name	
	
	#has_dti=`echo $s | cut -d "," -f 3`
	date=`date +%Y-%m-%d`
	echo $date
	i=/data/joy/BBL/studies/pnc/processedData/diffusion/pncDTI_2016_04
	echo $i
	dti_nii_out_64=$i/$bblid/$subid/DTI_64/raw_merged_dti/$dti_name".dti.merged.nii" 
	echo $dti_nii_out_64
	dti_nii_out_32=$i/$bblid/$subid/DTI_32/raw_dti/*.nii
	echo $dti_nii_out_32
	dti_nii_gz_out_64=$i/$bblid/$subid/DTI_64/raw_merged_dti/$dti_name".dti.merged.nii.gz"
	echo $dti_nii_gz_out_64
	logfile=/data/joy/BBL/studies/pnc/processedData/diffusion/pncDTI_2016_04/$bblid/$subid/$dti_name"_logfile_pipeline_"$date".log"
	echo $logfile
	echo $i/$bblid/$subid
	echo " Processing subject $dti_name"

#Check if 'bbl' folder exists (dtifit is the last folder populated), if not make one
	if [ ! -e $i/$bblid/$subid/DTI_64/dtifit ] && [ ! -e $i/$bblid/$subid/DTI_32/dtifit ]; then
		echo "making bbl directory"
		mkdir $i/DTI

		#Make directories for 64 direction processing
		mkdir $i/$bblid
		mkdir $i/$bblid/$subid
		mkdir $i/$bblid/$subid/DTI_64
		mkdir $i/$bblid/$subid/DTI_64/raw_merged_dti
		mkdir $i/$bblid/$subid/DTI_64/qa
		mkdir $i/$bblid/$subid/DTI_64/eddy
		mkdir $i/$bblid/$subid/DTI_64/corrected_b_files
		mkdir $i/$bblid/$subid/DTI_64/dico_corrected
		mkdir $i/$bblid/$subid/DTI_64/dtifit
		mkdir $i/$bblid/$subid/DTI_64/dtitk/		
		mkdir $i/$bblid/$subid/DTI_64/dtitk/raw
		mkdir $i/$bblid/$subid/DTI_64/dtitk/transforms
		mkdir $i/$bblid/$subid/DTI_64/dtitk/output


		#Make directories for 32 direction processing
		mkdir $i/$bblid/$subid/DTI_32
		mkdir $i/$bblid/$subid/DTI_32/raw_dti
		mkdir $i/$bblid/$subid/DTI_32/qa
		mkdir $i/$bblid/$subid/DTI_32/eddy
		mkdir $i/$bblid/$subid/DTI_32/corrected_b_files
		mkdir $i/$bblid/$subid/DTI_32/dico_corrected
		mkdir $i/$bblid/$subid/DTI_32/dtifit
		mkdir $i/$bblid/$subid/DTI_32/dtitk
		mkdir $i/$bblid/$subid/DTI_32/dtitk/raw
		mkdir $i/$bblid/$subid/DTI_32/dtitk/transforms
		mkdir $i/$bblid/$subid/DTI_32/dtitk/output
		
	#else
		#echo "BBL DTI folder structure complete"
	fi

#Check if Merged DTI file is present, if not make one
		if [ ! -e /data/joy/BBL/studies/pnc/processedData/diffusion/pncDTI_2016_04/$bblid/$subid/DTI_64/raw_merged_dti/*merged.nii.gz ]; then
		#logrun echo "merged DTI file does not exist ..creating it now for this subject"
		echo "Merge 64 direction data"
		logrun /home/melliott/scripts/sequence2nifti.sh DTI_CONCAT /data/joy/BBL/studies/pnc/processedData/diffusion/pncDTI_2016_04/$bblid/$subid/DTI_64/raw_merged_dti/$dti_name".dti.merged".nii /data/joy/BBL/studies/pnc/rawData/$bblid/$subid/DTI*35*/dicoms/*.dcm /data/joy/BBL/studies/pnc/rawData/$bblid/$subid/DTI*36*/dicoms/*.dcm 
		#logrun echo "DTI data merged" 
		
		/share/apps/fsl/5.0.8/bin/fslchfiletype NIFTI_GZ $dti_nii_out_64

		else
	 	echo "merged data exists...skipping"
		fi

#Create DTI_35 series nifti, bvecs, and bvals from the raw dicoms 
		
	if [ ! -e $i/$bblid/$subid/DTI_32/raw_dti/$dti_name"_raw_dti.nii.gz" ]; then 
	echo "Creating 32 directions data" 

	logrun /share/apps/mricron/ver_2015_06_01/dcm2nii -g N -p N -d N -e N -i N -v Y -f Y -r N -o /data/joy/BBL/studies/pnc/processedData/diffusion/pncDTI_2016_04/$bblid/$subid/DTI_32/raw_dti/ /data/joy/BBL/studies/pnc/rawData/$bblid/$subid/DTI_2x32_35/* 

mv $i/$bblid/$subid/DTI_32/raw_dti/*.nii $i/$bblid/$subid/DTI_32/raw_dti/$dti_name"_raw_dti".nii
mv $i/$bblid/$subid/DTI_32/raw_dti/*.bval $i/$bblid/$subid/DTI_32/raw_dti/$dti_name.bval
mv $i/$bblid/$subid/DTI_32/raw_dti/*.bvec $i/$bblid/$subid/DTI_32/raw_dti/$dti_name.bvec

/share/apps/fsl/5.0.8/bin/fslchfiletype NIFTI_GZ $i/$bblid/$subid/DTI_32/raw_dti/$dti_name"_raw_dti".nii

	else 
	echo "DTI in 32 directions created. Move to QA" 

	fi

#If QA has already been run, then skip the next two steps
echo "Run QA for 64 directions"
qa_file_64=`ls $i/$bblid/$subid/DTI_64/qa/$dti_name.qa`

	
		#Run QA on merged DTI file
		if [ -e $i/$bblid/$subid/DTI_64/raw_merged_dti/*dti.merged.nii* ] && [ ! -e "$qa_file_64" ]; then		
		echo "running QA"
	logrun /home/melliott/scripts/qa_dti_v2.sh -keep /data/joy/BBL/studies/pnc/processedData/diffusion/pncDTI_2016_04/$bblid/$subid/DTI_64/raw_merged_dti/*dti.merged.nii* /data/joy/BBL/studies/pnc/processedData/diffusion/pncDTI_2016_04/$bblid/$subid/DTI_64/raw_merged_dti/*dti.merged.bval /data/joy/BBL/studies/pnc/processedData/diffusion/pncDTI_2016_04/$bblid/$subid/DTI_64/raw_merged_dti/*dti.merged.bvec /data/joy/BBL/studies/pnc/processedData/diffusion/pncDTI_2016_04/$bblid/$subid/DTI_64/qa/$bblid"_"$subid.qa 
		echo "QA complete"		
		else
		echo "QA Already Done"
		fi
for a in $i/$bblid/$subid/DTI_64/qa/*.nii

do

/share/apps/fsl/5.0.8/bin/fslchfiletype NIFTI_GZ $a

done


echo "Run QA for 32 directions"
qa_file_32=`ls $i/$bblid/$subid/DTI_32/qa/$dti_name.qa`

	
		#Run QA on DTI file
		

		if [ -e $i/$bblid/$subid/DTI_32/raw_dti/$dti_name"_raw_dti.nii.gz" ] && [ ! -e "$qa_file_32" ]; then		
		echo "running QA"
	logrun /home/melliott/scripts/qa_dti_v2.sh -keep /data/joy/BBL/studies/pnc/processedData/diffusion/pncDTI_2016_04/$bblid/$subid/DTI_32/raw_dti/*.nii.gz /data/joy/BBL/studies/pnc/processedData/diffusion/pncDTI_2016_04/$bblid/$subid/DTI_32/raw_dti/*.bval /data/joy/BBL/studies/pnc/processedData/diffusion/pncDTI_2016_04/$bblid/$subid/DTI_32/raw_dti/*.bvec /data/joy/BBL/studies/pnc/processedData/diffusion/pncDTI_2016_04/$bblid/$subid/DTI_32/qa/$bblid"_"$subid.qa 
		else
		echo "QA already run"
		fi

for t in $i/$bblid/$subid/DTI_32/qa/*.nii

do

/share/apps/fsl/5.0.8/bin/fslchfiletype NIFTI_GZ $t

done

		echo "QA complete"		
		#else
	
		#echo "QA Already Done"
		#fi

		#Create list of subjects to run DTI processing steps
		if [ -e $i/$bblid/$subid/DTI_32/raw_dti/$dti_name"_raw_dti".nii.gz ]; then 
			echo $dti_name >> $joblist

		else 
		
			echo $dti_name >> $no_32_dti
		fi
			
		if [ ! -e $i/$bblid/$subid/DTI_64/raw_merged_dti/$dti_name".dti.merged".nii.gz ]; then 

			echo $dti_name >> $no_merge_dti 

		fi
		
		if [ -e $i/$bblid/$subid/DTI_32/raw_dti/$dti_name"_raw_dti".nii.gz ] && [ ! -e $i/$bblid/$subid/DTI_32/qa/*.qa ] ; then

			echo $dti_name >> $process_fail
		fi

	
done

echo "done, ready to submit to Q"
ntasks=$(cat $joblist | wc -l)
echo "number of jobs in array is $ntasks"

#NOW SUBMIT TO SGE AS TASK ARRAY
# old version
#qsub -V -q all.q -S /bin/bash -o ~/eons_dti_logs -e ~/eons_dti_logs -t 1-${ntasks} /import/monstrum/eons_xnat/progs/DTI/GO1_DTI_process.sh $joblist 

#new
qsub -V -q all.q -S /bin/bash -j y -t 1-${ntasks} /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/GO1_DTI_process.sh $joblist
#/data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/GO1_DTI_process.sh $joblist

else
echo "*******"
echo "ERROR: One or more of the scripts required to quantify and register DTI is missing."
echo "FSL: "$fsl
echo "seq2nifiti: "$seq2nifiti
echo "dti_qa: "$dtiqa
echo "*******"

fi #if [ ! -z $fsl ]  && [ ! -z $seq2nifti ] && [ ! -z $dti_qa ];then
