#!/bin/sh

##########################################################
### Define working directory containing local git-pull ###
##########################################################
workingDir="~/pncReproc2015Scripts/diffusion/deterministic_20161201"

###############################################################
### Define subject list in 'bblid_scanid_dateidofscan' format ###
###############################################################
subject_list=$(cat /data/joy/BBL/projects/pncBaumDti/subject_lists/n1398_go1_full_64_dti_subjList.txt)

##############################################################
### Define directory structure and inputs for each subject ###
##############################################################

for name in ${subject_list}; do

	bblid=$(basename ${name} | cut -d_ -f1)
	scanid=$(basename ${name} | cut -d_ -f2)
	dateid=$(basename ${name} | cut -d_ -f3)


	echo $bblid
	echo $scanid
	echo $dateid

	roalfDir=/data/joy/BBL/studies/pnc/processedData/diffusion/pncDTI_2016_04/${bblid}/"${dateid}"x"${scanid}"/DTI_64
	
	outDir=/data/joy/BBL/studies/pnc/processedData/diffusion/deterministic_20161201/${bblid}/"${dateid}"x"${scanid}"

	log_dir=${outDir}/logfiles
	mkdir -p ${log_dir}

	########################################################################################
	### Assign image variables for DTI -- Use eddy, motion, and distortion-corrected DWI ###
	########################################################################################
	emoDico_Dti=${roalfDir}/dico_corrected/"${bblid}"_"${dateid}"x"${scanid}"_dico_dico.nii.gz

	echo " "
	echo "Eddy, Motion, and Distortion-corrected Image for Reconstruction and Tractography in DSI Studio"
	echo " "
	echo ${emoDico_Dti}

	################################################
	#### Define commands for processing scripts #### 
	################################################ 

	var1="pncReproc_run_deterministic_tractography --in=${emoDico_Dti} --subject=${bblid} --method=DTI --paramsdir=/data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles"

	echo " "
	echo "Process DTI call"
	echo " "
	echo ${var1}

	### Remove old executable scripts 	
	rm  ${log_dir}/PNC_DTI_deterministic_tractography_"${bblid}"_"${dateid}"x"${scanid}"_wholeBrain_1mill_10_400mm.*
	
	### Write out processing commands into executable file for qsub
	echo ${var1} >> ${log_dir}/PNC_DTI_deterministic_tractography_"${bblid}"_"${dateid}"x"${scanid}"_wholeBrain_1mill_10_400mm.sh

	########################################
	### SUBMIT qsub job for each subject ###
	########################################
	qsub -V -v emoDico_Dti="${emoDico_Dti}",workingDir="${workingDir}",roalfDir="${roalfDir}",bblid="${bblid}",scanid="${scanid}",dateid="${dateid}",outDir="${outDir}",log_dir="${log_dir}",tract_dir="${tract_dir}" -wd ${log_dir} -l h_vmem=6G,s_vmem=5.5G ${log_dir}/PNC_DTI_deterministic_tractography_"${bblid}"_"${dateid}"x"${scanid}"_wholeBrain_1mill_10_400mm.sh

	# rm ${log_dir}/PNC_DTI_deterministic_tractography_"${bblid}"_"${dateid}"x"${scanid}"_wholeBrain_1mill_10_400mm.sh

done
